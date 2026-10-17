unit Types;
interface
uses Consts;

type
	TTile = record
    	TileID: Tile;
        Fg, Bg: Byte;
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