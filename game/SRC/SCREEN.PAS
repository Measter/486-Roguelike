unit Screen;
interface
uses Consts, Types;
var
	Enabled: Boolean;
    ViewportX: TMapX;
	ViewportY: TMapY;

function Init: Boolean;
procedure Deinit;
procedure LoadTiles;

procedure SetTiles;
procedure DrawTile(X: TMapX; Y: TMapY; TileId : Tile; Fg, Bg: Byte);
procedure DrawTiles(Screen: Pointer);
procedure Clear;
procedure Present;

implementation
uses Svga;

const
	TileDataLength = TileCount * 32;

type
	TTileData = array[0..TileDataLength-1] of Byte;

var
    TileData: TTileData;

function Init: Boolean;
var
	Ok: Boolean;
begin
	if Enabled = True then begin
		Ok := init_svga;
	    if Ok then init_palette;
    end;
    Init := Ok;
end;

procedure Deinit;
begin
	if Enabled = True then deinit_svga;
end;

procedure LoadTiles;
var
	F: File of TTileData;
begin
	Assign(F, 'tiles.bin');
    Reset(F);
    Read(F, TileData);
    Close(F);
end;

procedure Clear;
begin
    Svga.draw_box(0, 0, 0, 800, 600);
    Present;
    Svga.draw_box(0, 0, 0, 800, 600);
end;

procedure Present;
begin
    if Enabled = True then svga.present;
end;

procedure SetTiles;
begin
    if Enabled = True then set_tiles;
end;

procedure DrawTile(X: TMapX; Y: TMapY; TileId: Tile; Fg, Bg: Byte);
begin
    if Enabled = True then
        draw_tile(@TileData,
                  Byte(TileId), Fg, Bg,
                  Byte(X - ViewportX), Byte(Y - ViewportY)
        );
end;

procedure DrawTiles(Screen: Pointer);
begin
    if Enabled = True then
        draw_tiles(Screen, @TileData, ViewportX, ViewportY);
end;

end.
