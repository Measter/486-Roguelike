program rltut;
uses Crt, Screen, Consts, Types;

var
    Floor: TMap;
    Map: TMap;
    PlayerX: TMapX;
    PlayerY: TMapY;

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

procedure Move(D: TDir);
begin
    if (D = Left) and (PlayerX > 0) then Dec(PlayerX)
    else if (D = Right) and (PlayerX < MapWidth-1) then Inc(PlayerX)
    else if (D = Up) and (PlayerY > 0) then Dec(PlayerY)
    else if (D = Down) and (PlayerY < MapHeight-1) then Inc(PlayerY);

    UpdateViewport;
end;

procedure DrawEntity(X: TMapX; Y: TMapY; T: Tile; Fg, Bg: Byte);
begin
	Screen.DrawTile(
        X, Y,
        T, Fg, Bg
    );
end;

procedure GetEvent(var Event: TEvent);
var
    InputKey: Char;
    InputFunc: Boolean;
begin
	InputKey := ReadKey;
    if InputKey <> #0 then InputFunc := False else
    begin
        InputFunc := True;
        InputKey := ReadKey;
    end;

    Event.Kind := NoAction;
    if InputKey = #$1B {Escape} then Event.Kind := EscapeAction;
    if InputFunc then
		if InputKey = #$4B then begin
        	Event.Kind := MoveAction;
			Event.Dir := Left;
        end else if InputKey = #$4D then begin
            Event.Kind := MoveAction;
			Event.Dir := Right;
        end else if InputKey = #$48 then begin
            Event.Kind := MoveAction;
			Event.Dir := Up;
        end else if InputKey = #$50 then begin
            Event.Kind := MoveAction;
			Event.Dir := Down;
        end;
end;

var
    IsOk: Boolean;
	Event: TEvent;
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

    {We only need to do this bit once, to make sure the VRAM
     doesn't have garbage}
    Screen.Clear;

    while True do begin
        Screen.SetTiles;
        Screen.DrawTiles(@Floor);
        Screen.DrawTiles(@Map);
        DrawEntity(PlayerX, PlayerY, TilePlayer, ClrWhite, ClrClear);
        Screen.Present;

		GetEvent(Event);
        case Event.Kind of
			EscapeAction: Break;
            MoveAction: Move(Event.Dir);
        end;
    end;

    Screen.Deinit;
end.
