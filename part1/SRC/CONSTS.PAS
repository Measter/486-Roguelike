unit Consts;
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
    ScreenLength = ScreenWidth * ScreenHeight;

    MapWidth = 80;
    MapHeight = 50;
    MapLength = MapHeight * MapWidth;

{$I tiles.pas}

implementation
end.