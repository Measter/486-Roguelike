program rltut;
uses Crt, Screen;

const
	MapWidth = 80;
    MapHeight = 50;
    MapLength = MapHeight * MapWidth;

type
	Dir = (Left, Right, Up, Down);
    TMap = array[0..MapLength-1] of TTile;

var
    Floor: TMap;
    Map: TMap;
    PlayerX, PlayerY: Byte;

procedure InitFloor;
const
    FlrClr: Array[0..4] of Byte = (
        ClrFloor1, ClrFloor2, ClrFloor3, ClrFloor4, ClrFloor5
    );
var
    I, Rt: Word;
    T: Tile;
begin
    for I := 0 to MapLength-1 do begin
        Rt := Random(20);
        if Rt < 2 then T := TileFloorA
        else if Rt < 4 then T := TileFloorB
        else T := TileEmpty;

        Rt := Random(5);
        Floor[I].TileId := T;
        Floor[I].Fg := FlrClr[Rt];
        Floor[I].Bg := ClrBlack;
    end;
end;

procedure InitMap;
var
    I: Word;
begin
    for I := 0 to MapLength-1 do begin
        Map[I].TileId := TileEmpty;
        Map[I].Fg := ClrWhite;
        Map[I].Bg := ClrClear;
    end;
end;

procedure DrawMap(var M: TMap);
var
    ScreenX, ScreenY, MapX, MapY: Byte;
    TileI: Word;
begin
    for ScreenY := 0 to ScreenHeight-1 do begin
        MapY := ViewportY + ScreenY;
        for ScreenX := 0 to ScreenWidth-1 do begin
            MapX := ViewportX + ScreenX;
            TileI := MapY * MapWidth + MapX;
            Screen.DrawTile(
                ScreenX, ScreenY,
                M[TileI].TileId,
                M[TileI].Fg,
                M[TileI].Bg
            );
        end;
    end;
end;

var
    IsOk: Boolean;
    InputKey: Char;
    InputFunc: Boolean;

procedure UpdateViewport;
begin
    if PlayerX <= (ScreenWidth div 2) then
        ViewportX := 0
    else if PlayerX >= (MapWidth - (ScreenWidth div 2)) then
        ViewportX := MapWidth - ScreenWidth
    else
        ViewportX := PlayerX - (ScreenWidth div 2);

    if PlayerY <= (ScreenHeight div 2) then
        ViewportY := 0
    else if PlayerY >= (MapHeight - (ScreenHeight div 2)) then
        ViewportY := MapHeight - ScreenHeight
    else
        ViewportY := PlayerY - (ScreenHeight div 2);
end;

procedure Move(D: Dir);
begin
    if (D = Left) and (PlayerX > 0) then Dec(PlayerX)
    else if (D = Right) and (PlayerX < MapWidth-1) then Inc(PlayerX)
    else if (D = Up) and (PlayerY > 0) then Dec(PlayerY)
    else if (D = Down) and (PlayerY < MapHeight-1) then Inc(PlayerY);

    UpdateViewport;
end;

procedure DrawEntity(X, Y: Byte; T: Tile; Fg, Bg: Byte);
begin
	Screen.DrawTile(
        X, Y,
        T, Fg, Bg
    );
end;

begin
    Screen.LoadTiles;
    Screen.Enabled := True;

    IsOk := Screen.Init;
	if IsOk = False then begin
       Writeln('Failed to initialize SVGA');
       halt(1);
    end;

    Randomize;
    InitFloor;
    InitMap;

    PlayerX := MapWidth div 2;
    PlayerY := MapHeight div 2;
    UpdateViewport;

    while True do begin
        Screen.SetTiles;
        Screen.DrawTiles(@Floor);
        Screen.DrawTiles(@Map);
        DrawEntity(PlayerX, PlayerY, TilePlayer, ClrWhite, ClrClear);

        InputKey := ReadKey;
        if InputKey <> #0 then InputFunc := False else
        begin
            InputFunc := True;
            InputKey := ReadKey;
        end;

        if InputKey = #$1B then Break;
        if InputFunc then
			if InputKey = #$4B then Move(Left)
            else if InputKey = #$4D then Move(Right)
            else if InputKey = #$48 then Move(Up)
            else if InputKey = #$50 then Move(Down);
    end;

    Screen.Deinit;
end.
