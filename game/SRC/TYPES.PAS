unit Types;
interface
uses Consts;

type
	{ If these are changed then update rendering code }
    TGraphic = record
		TileID: Tile;
        Fg, Bg: Byte;
    end;
	TTile = record
    	Light, Dark: TGraphic;
        Walkable, Transparent: Boolean;
    end;
    TMap = array[0..MapLength-1] of TTile;
    TMapX = 0..MapWidth-1;
    TMapY = 0..MapHeight-1;

    TAction = (NoAction, EscapeAction, MoveAction);
    TDir = (Left, Right, Up, Down);

    TEvent = record
		case Kind: TAction of
			NoAction: ();
			EscapeAction: ();
            MoveAction: (Dir: TDir);
    end;
implementation
end.