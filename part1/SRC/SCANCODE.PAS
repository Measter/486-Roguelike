program ScanCode;
uses Crt;

function Hex(B: Char): String;
const
    Digits : String[16] = '0123456789ABCDEF';
var
	Bt: Byte;
begin
	Bt := Byte(B);
	Hex := Digits[(Bt shr 4) + 1] +
    	   Digits[(Bt and $F) + 1];
end;

var
    Ch: Char;
begin
    CheckBreak := True;
    while True do begin
        Ch := ReadKey;
        if Ch = #0 then begin
            Ch := ReadKey;
            Writeln('Scan Code: ', Hex(Ch), ' (Ext)');
        end else begin
            Writeln('Scan Code: ', Hex(Ch));
        end;
    end;
end.