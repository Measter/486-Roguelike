use std::{
    fs::File,
    io::{BufWriter, Write},
};

use image::{GenericImageView, GrayImage, ImageReader};
use serde::Deserialize;

#[derive(Debug, Deserialize)]
struct TileDef {
    name: String,
    x: u32,
    y: u32,
}

#[derive(Debug)]
struct Tile {
    data: [u8; 32],
    name: String,
}

fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;

    let tilemap = ImageReader::open("../../kenney_1-bit-pack/Tilesheet/monochrome.png")?
        .decode()?
        .to_luma8();

    let tiles = std::fs::read_to_string("tiles.json")?;
    let tiles: Vec<TileDef> = serde_json::from_str(&tiles)?;

    assert!(tiles.len() < 255);
    assert!(tiles.len() > 0);

    let tile_data = read_tile_data(&tiles, &tilemap);

    let tile_bin_file = File::create("tiles.bin")?;
    let mut tile_bin_file = BufWriter::new(tile_bin_file);
    let tile_def_file = File::create("tiles.pas")?;
    let mut tile_def_file = BufWriter::new(tile_def_file);

    writeln!(&mut tile_def_file, "const")?;
    writeln!(&mut tile_def_file, "    TileCount = {};", tile_data.len())?;
    writeln!(&mut tile_def_file)?;
    writeln!(&mut tile_def_file, "type")?;
    writeln!(&mut tile_def_file, "    Tile = (")?;
    let [tile_data_first @ .., tile_data_last] = &*tile_data else {
        unreachable!()
    };

    for tile in tile_data_first {
        tile_bin_file.write_all(&tile.data)?;
        writeln!(&mut tile_def_file, "        Tile{},", tile.name)?
    }
    tile_bin_file.write_all(&tile_data_last.data)?;
    writeln!(&mut tile_def_file, "        Tile{}", tile_data_last.name)?;
    writeln!(&mut tile_def_file, "    );")?;

    Ok(())
}

fn read_tile_data(tile_defs: &[TileDef], map: &GrayImage) -> Vec<Tile> {
    let mut tiles = Vec::new();

    for tile in tile_defs.iter() {
        let pixel_data = read_pixel_data(tile, map);
        tiles.push(Tile {
            data: pixel_data,
            name: tile.name.clone(),
        });
    }

    tiles
}

fn read_pixel_data(tile: &TileDef, map: &GrayImage) -> [u8; 32] {
    let mut pixels = [0; 32];
    let tile_image = map.view(tile.x, tile.y, 16, 16);

    let mut pixels_iter = pixels.iter_mut();
    for row in 0..16 {
        for col in 0..2 {
            let packed = pixels_iter.next().unwrap();
            let pixel_block = tile_image.view(8 * col, row, 8, 1);
            *packed = pixel_block
                .pixels()
                .map(|(x, _, c)| (x, (c.0[0] > 0) as u8))
                .fold(0, |a, (shift, is_white)| a | (is_white << shift));
        }
    }

    pixels
}
