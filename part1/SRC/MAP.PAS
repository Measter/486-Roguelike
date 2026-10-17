unit Map;
interface
uses Screen, Consts, Types;

type
	TGameMap = object
    	Floor, Map: TMap;

        procedure Init;
        procedure Draw;
        function Walkable(X: TMapX; Y: TMapY): Boolean;
    end;

implementation

procedure TGameMap.Init;
const
    FlrClr: Array[0..4] of Byte = (
        ClrFloor1, ClrFloor2, ClrFloor3, ClrFloor4, ClrFloor5
    );
    FlrDarkClr: Array[0..4] of Byte = (
		ClrFloorDark1, ClrFloorDark2, ClrFloorDark3, ClrFloorDark1,
        ClrFloorDark3
    );
var
    T: Tile;
	I, Rt: Word;
begin
	for I := 0 to MapLength-1 do begin
    	{Map Layer}
        Map[I].Light.TileId := TileEmpty;
        Map[I].Light.Fg := ClrWhite;
        Map[I].Light.Bg := ClrClear;
        Map[I].Dark.TileId := TileEmpty;
        Map[I].Dark.Fg := ClrMidGrey;
        Map[I].Dark.Bg := ClrClear;
        Map[I].Transparent := True;
        Map[I].Walkable := True;

        {Floor layer}
        Rt := Random(20);
        if Rt < 2 then T := TileFloorA
        else if Rt < 4 then T := TileFloorB
        else T := TileEmpty;

        Rt := Random(5);
        Floor[I].Light.TileId := T;
        Floor[I].Light.Fg := FlrClr[Rt];
        Floor[I].Light.Bg := ClrBlack;
        Floor[I].Dark.TileId := T;
        Floor[I].Dark.Fg := FlrDarkClr[Rt];
        Floor[I].Dark.Bg := ClrBlack;
        Floor[I].Transparent := True;
        Floor[I].Walkable := True;
    end;

    for I := 1790 to 1792 do begin
		Map[I].Light.TileId := TileWall;
        Map[I].Dark.TileId := TileWall;
        Map[I].Transparent := False;
        Map[I].Walkable := False;
    end;
end;

procedure TGameMap.Draw;
begin
	Screen.DrawTiles(@Floor);
    Screen.DrawTiles(@Map);
end;

function TGameMap.Walkable(X: TMapX; Y: TMapY): Boolean;
var	I: Word;
begin
	I := (Word(Y) * MapWidth) + Word(X);
	Walkable := Map[I].Walkable;
end;

end.