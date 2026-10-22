program rltut;
uses Svga, Crt;

const
    BoxSize = 30;
    BoxSpacing = 5;
    StartX = 10;
    StartY = 10;

var
    InSvga: Boolean;
    X, Y, Clr: Byte;
    DrawX, DrawY: Word;
begin
    InSvga := init_svga;

    if InSvga = False then begin
       Writeln('Failed to initialize SVGA');
       halt(1);
    end;

    init_palette;
    draw_box(0, 0, 0, 800, 600);

    for Y := 0 to $F do begin
        DrawY := StartY + Word(Y) * (BoxSize + BoxSpacing);
        for X := 0 to $F do begin
            Clr := (Y shl 4) or X;
            DrawX := StartX + Word(X) * (BoxSize + BoxSpacing);
            draw_box(Clr, DrawX, DrawY, BoxSize, BoxSize);
        end;
    end;

    present;

    ReadKey;
    
    deinit_svga;
end.
