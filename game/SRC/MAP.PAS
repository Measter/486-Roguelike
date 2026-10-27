unit Map;
interface
uses Screen, Consts, Types;

type
	TRect = record
		TL, BR: TPos;
    end;

	TGameMap = object
    	Floor, Map: TMap;

        procedure Init;
        procedure ClearMap;
        procedure GenMap(var PlayerPos: TPos);
        procedure CutRoom(Box: TRect);
        procedure SplitBox(Box: TRect; var CentreOut: TPos);
        procedure Draw;
        function Walkable(X: TMapX; Y: TMapY): Boolean;
    end;

implementation
const
	FlrColLen = 3;

    FlrClr: Array[0..FlrColLen-1] of Byte = (
        ClrFloor1, ClrFloor2, ClrFloor3
    );
    FlrDarkClr: Array[0..FlrColLen-1] of Byte = (
		ClrFloorDark1, ClrFloorDark2, ClrFloorDark3
    );

procedure TGameMap.Init;
begin
end;

procedure TGameMap.ClearMap;
var
	I: Word;
begin
	for I := 0 to MapLength-1 do begin
		with Map[I] do begin
            Light.TileId := TileWall;
            Light.Fg := ClrWhite;
            Light.Bg := ClrClear;
            Dark.TileId := TileEmpty;
            Dark.Fg := ClrMidGrey;
			Dark.Bg := ClrClear;
            Transparent := True;
            Walkable := True;
        end;

		with Floor[I] do begin
            Light.TileId := TileEmpty;
            Light.Fg := ClrWhite;
            Light.Bg := ClrBlack;
			Dark.TileId := TileEmpty;
            Dark.Fg := ClrMidGrey;
			Dark.Bg := ClrBlack;
            Transparent := True;
            Walkable := True;
        end;

    end;
end;

procedure TGameMap.CutRoom(Box: TRect);
var
	X: TMapX;
    Y: TMapY;
    Row: Word;
begin
    for Y := Box.TL.Y+1 to Box.BR.Y-1 do begin
    	Row := Y * MapWidth;
        for X := Box.TL.X+1 to Box.BR.X-1 do begin
			with Map[Row + X] do begin
				Light.TileId := TileEmpty;
                Dark.TileId := TileEmpty;
            end;

        end;
    end;
end;

procedure TGameMap.SplitBox(Box: TRect; var CentreOut: TPos);
const
	RoomMin = 16;
    BoxPSMin = RoomMin div 2;
    RoomMax = 20;
type
	TSplitDir = (SDHor, SDVert);
var
	Width, Height: Word;
    First, Second: TRect;
    FirstCentre, SecondCentre: TPos;
    MustSplit, CanSplit: set of TSplitDir;
    DoSplit: Boolean;
    SplitDir: TSplitDir;
    NMin, NMax: Word;
begin
	Width := Box.BR.X - Box.TL.X;
    Height := Box.BR.Y - Box.TL.Y;
    MustSplit := [];
    CanSplit := [SdHor, SdVert];

    if Width > RoomMax then Include(MustSplit, SDHor);
    if Height > RoomMax then Include(MustSplit, SDVert);
    if Width <= RoomMin then Exclude(CanSplit, SDHor);
    if Height <= RoomMin then Exclude(CanSplit, SdVert);

    DoSplit := False;
    if MustSplit <> [] then DoSplit := True
    else if CanSplit = [] then DoSplit := False
	else if Random(2) = 0 then DoSplit := True;

    if DoSplit then begin
    	{ If we must split in both directions,
		  or we have no required direction }
		if (MustSplit = [SDHor, SDVert]) or (MustSplit = []) then begin
            { We can split in both directions, pick at random }
			if CanSplit = [SDHor, SDVert] then begin
				if Random(2) = 0 then SplitDir := SDHor
    	        else SplitDir := SDVert;
            end
            { We can only split in one direction, so do that }
			else if SdHor in CanSplit then SplitDir := SDHor
            else SplitDir := SDVert;
        end
        { We have one required direction, so do that }
		else if SDHor in MustSplit then SplitDir := SDHor
		else SplitDir := SDVert;

    	First := Box;
        Second := Box;

        if SplitDir = SDVert then begin
        	NMin := Box.TL.Y + BoxPSMin;
            NMax := Box.BR.Y - BoxPSMin;
            Height := Random(NMax - NMin) + NMin;
            First.BR.Y := Height;
            Second.TL.Y := Height;
        end else begin
        	NMin := Box.TL.X + BoxPSMin;
            NMax := Box.BR.X - BoxPSMin;
            Width := Random(NMax - NMin) + NMin;
            First.BR.X := Width;
            Second.TL.X := Width;
        end;

        SplitBox(First, FirstCentre);
        SplitBox(Second, SecondCentre);
        { Draw path between }
        CentreOut := FirstCentre;
    end else begin
    	CutRoom(Box);
        CentreOut.X := Box.TL.X + (Width div 2);
        CentreOut.Y := Box.TL.Y + (Height div 2);
	end;
end;

procedure TGameMap.GenMap(var PlayerPos: TPos);
var
	Box: TRect;
begin
	ClearMap;
    Box.TL.X := 0;
    Box.TL.Y := 0;
    Box.BR.X := MapWidth-1;
    Box.BR.Y := MapHeight-1;

    SplitBox(Box, PlayerPos);
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