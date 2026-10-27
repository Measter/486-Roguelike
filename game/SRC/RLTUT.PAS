program rltut;
uses Crt, Screen, Consts, Types, Entity, Map;

const
	NumEntities = 32;

var
    GameMap: TGameMap;
    Player: TEntity;
    Entities: array[1..NumEntities] of TEntity;

procedure InitEntities;
var
	I: Byte;
begin
	for I := 1 to NumEntities do begin
		Entities[I].State := Unused;
    end;
end;

procedure DrawEntities;
var
	I: Byte;
begin
	for I := 1 to NumEntities do begin
		if Entities[I].State <> Unused then
        	Entities[I].Draw;
    end;
end;

procedure UpdateViewport;
begin
    if Player.Pos.X <= (ScreenWidth div 2) then
        ViewportX := 0
    else if Player.Pos.X >= (MapWidth - (ScreenWidth div 2)) then
        ViewportX := MapWidth - ScreenWidth
    else
        ViewportX := Player.POs.X - (ScreenWidth div 2);

    if Player.Pos.Y <= (ScreenHeight div 2) then
        ViewportY := 0
    else if Player.Pos.Y >= (MapHeight - (ScreenHeight div 2)) then
        ViewportY := MapHeight - ScreenHeight
    else
        ViewportY := Player.Pos.Y - (ScreenHeight div 2);
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

    Player.Init(
		0,
        0,
        TilePlayer,
        ClrWhite,
        ClrClear
    );

    Randomize;
    GameMap.Init;
    GameMap.GenMap(Player.Pos);
    InitEntities;

    Entities[1].Init(10, 20, TilePlayer, ClrRed, ClrClear);

    UpdateViewport;

    {We only need to do this bit once, to make sure the VRAM
     doesn't have garbage}
    Screen.Clear;

    while True do begin
        Screen.SetTiles;
        GameMap.Draw;
        DrawEntities;
        Player.Draw;
        Screen.Present;

		GetEvent(Event);
        case Event.Kind of
			EscapeAction: Break;
            MoveAction: begin
				Player.Move(GameMap, Event.Dir);
                UpdateViewport;
            end
        end;
    end;

    Screen.Deinit;
end.
