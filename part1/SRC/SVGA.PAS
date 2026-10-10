unit Svga;
interface
function init_svga: Boolean;
procedure init_palette;
procedure deinit_svga;

procedure present;
procedure set_tiles;
procedure draw_tile(TileData: Pointer; Id, Fg, Bg, X, Y: Byte);
procedure draw_tiles(Map, TileData: Pointer; ViewX, ViewY: Byte);
procedure draw_box(Colour: Byte; X, Y, Width, Height: Word);

implementation
var
    DrawBuffer: Byte;

{$L SVGAINIT.OBJ}
function init_svga: Boolean; external;
procedure init_palette; external;
procedure deinit_svga; external;

{$L SVGADRAW.OBJ}
procedure present; External;
procedure set_tiles; External;
procedure draw_tile(TileData: Pointer; Id, Fg, Bg, X, Y: Byte); External;
procedure draw_tiles(Map, TileData: Pointer; ViewX, ViewY: Byte); external;
procedure draw_box(Colour: Byte; X, Y, Width, Height: Word); External;
end.
