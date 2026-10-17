unit Entity;
interface
uses Types, Consts, Screen, Map;

type
    TState = (Live, Dead, Unused);
	TEntity = object
		X: TMapX;
       	Y: TMapY;
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
	X := NX;
    Y := NY;
    T := NT;
    Fg := NFg;
    Bg := NBg;
end;

procedure TEntity.Draw;
begin
    if (X >= ViewportX) and (X < (ViewPortX + ScreenWidth))
    	and (Y >= ViewportY) and (Y < (ViewportY + ScreenWidth))
        then
			Screen.DrawTile(X, Y, T, Fg, Bg);
end;

procedure TEntity.Move(var GameMap: TGameMap; Dir: TDir);
var
	TargetX: TMapX;
    TargetY: TMapY;
begin
	TargetX := X;
    TargetY := Y;
    if (Dir = Left) and (X > 0) then Dec(TargetX)
    else if (Dir = Right) and (X < MapWidth-1) then Inc(TargetX)
    else if (Dir = Up) and (Y > 0) then Dec(TargetY)
    else if (Dir = Down) and (Y < MapHeight-1) then Inc(TargetY);

    if GameMap.Walkable(TargetX, TargetY) then begin
		X := TargetX;
        Y := TargetY;
    end;
end;

end.