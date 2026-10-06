unit Screen;
interface
const
	ClrWhite = $1D;
    ClrBlack = $10;
    ClrFloor1 = $EA;
    ClrFloor2 = $D1;
    ClrFloor3 = $D2;
    ClrFloor4 = $D3;
    ClrFloor5 = $BB;
    ClrClear = $FF;

    ScreenWidth = 50;
    ScreenHeight = 36;

{$I tiles.pas}

type
	TTile = record
    	TileId: Tile;
		Fg, Bg: Byte;
    end;

var
	Enabled: Boolean;
    ViewportX, ViewportY: Byte;

function Init: Boolean;
procedure Deinit;
procedure LoadTiles;

procedure SetTiles;
procedure DrawTile(X, Y: Byte; TileId : Tile; Fg, Bg: Byte);
procedure DrawTiles(Screen: Pointer);

implementation
uses Svga;

const
    ScreenLength = ScreenWidth * ScreenHeight;
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

procedure SetTiles;
begin
    if Enabled = True then set_tiles;
end;

procedure DrawTile(X, Y: Byte; TileId: Tile; Fg, Bg: Byte);
begin
    if Enabled = True then
        draw_tile(@TileData,
                  Byte(TileId), Fg, Bg,
                  X - ViewportX, Y - ViewportY
        );
end;

procedure DrawTiles(Screen: Pointer);
begin
    if Enabled = True then
        draw_tiles(Screen, @TileData, ViewportX, ViewportY);
end;

end.
