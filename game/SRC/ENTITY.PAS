unit Entity;
interface
uses Types, Consts, Screen, Map;

type
    TState = (Live, Dead, Unused);
	TEntity = object
		Pos: TPos;
       	T: Tile;
        Fg, Bg: Byte;
        State: TState;

        procedure Init(NX: TMapX; NY: TMapY; NT: Tile; NFg, NBg: Byte);
        procedure Draw;
        procedure Move(var GameMap: TGameMap; Dir: TDir);
    end;

implementation

procedure TEntity.Init(NX: TMapX; NY: TMapY; NT: Tile; NFg, NBg: Byte);
begin
	State := Live;
	Pos.X := NX;
    Pos.Y := NY;
    T := NT;
    Fg := NFg;
    Bg := NBg;
end;

procedure TEntity.Draw;
begin
    if (Pos.X >= ViewportX) and (Pos.X < (ViewPortX + ScreenWidth))
    	and (Pos.Y >= ViewportY) and (Pos.Y < (ViewportY + ScreenWidth))
        then
			Screen.DrawTile(Pos.X, Pos.Y, T, Fg, Bg);
end;

procedure TEntity.Move(var GameMap: TGameMap; Dir: TDir);
var
	TargetX: TMapX;
    TargetY: TMapY;
begin
	TargetX := Pos.X;
    TargetY := Pos.Y;
    if (Dir = Left) and (Pos.X > 0) then Dec(TargetX)
    else if (Dir = Right) and (Pos.X < MapWidth-1) then Inc(TargetX)
    else if (Dir = Up) and (Pos.Y > 0) then Dec(TargetY)
    else if (Dir = Down) and (Pos.Y < MapHeight-1) then Inc(TargetY);

    if GameMap.Walkable(TargetX, TargetY) then begin
		Pos.X := TargetX;
        Pos.Y := TargetY;
    end;
end;

end.