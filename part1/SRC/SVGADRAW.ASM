IDEAL
MODEL MEDIUM, PASCAL
P486
        PUBLIC present
        PUBLIC set_tiles
        PUBLIC draw_tile
        PUBLIC draw_tiles
        PUBLIC draw_box

INCLUDE "tseng.inc"

        DATASEG
EXTRN   DrawBuffer:Byte

TRANSP  EQU     0FFh

        CODESEG
        LOCALS

; Flips between the two draw buffers
; We do this by setting the linear scan address to
; 0 or 800*600
PROC present FAR
        cmp     [BYTE DrawBuffer], 1
        je      @@buffer1

        ; Buffer 0 lives at 000000h
        cli
        mov     dx, 03D4h

        ; Address bits 7:0
        mov     ax, 000Dh
        out     dx, ax

        ; Address bits 15:8
        mov     ax, 000Ch
        out     dx, ax

        ; Address bits 19:16. This register also has the
        ; cursor address, so let's not clobber that
        mov     al, 33h
        out     dx, al
        inc     dx
        in      al, dx
        and     al, NOT 7h
        out     dx, al

        sti
        mov     [DrawBuffer], 1

        jmp     @@exit
@@buffer1:
        ; Buffer 1 lives at 75300h, but the address is a DWORD offset
        ; so we divide by 4 to get 1D4C0h
        cli
        mov     dx, 03D4h

        ; Address bits 7:0
        mov     ax, 0C00Dh
        out     dx, ax

        ; Address bits 15:8
        mov     ax, 0D40Ch
        out     dx, ax

        ; Address bits 19:16
        mov     al, 33h
        out     dx, al
        inc     dx
        in      al, dx
        and     al, NOT 7h
        or      al, 01h
        out     dx, al

        sti
        mov     [BYTE DrawBuffer], 0

@@exit: ret
ENDP present

PROC draw_box FAR
        ARG     @@Colour: BYTE, @@X: WORD, @@Y: WORD, \
                @@Width: WORD, @@Height:WORD
        USES    edx, eax, ecx, fs

        ; Don't draw 0-width boxes
        mov     ax, [WORD @@Width]
        cmp     ax, 0
        jz      @@exit
        mov     ax, [WORD @@Height]
        cmp     ax, 0
        jz      @@exit

        mov     ax, MemMapRegSeg
        mov     fs, ax

        ; Calculate location of the colour pattern
        movzx   eax, [BYTE @@Colour]
        lea     eax, [eax * 4 + PatternVidAddress]

        ; Set up the pattern
        mov     [DWORD FS:ACLPA], eax
        mov     [WORD FS:ACLPYO], 3
        mov     [BYTE FS:ACLPW], PXWR_4B or PYWR_1L

        mov     [WORD FS:ACLDYO], 799
        ; These need to be zero at the start of an op
        mov     [WORD FS:ACLXP], 0
        mov     [WORD FS:ACLYP], 0

        ; Calculate byte position of the start.
        movzx   eax, [WORD @@Y]
        xor     edx, edx
        mov     ecx, 800
        mul     ecx
        movzx   ecx, [WORD @@X]
        add     eax, ecx
        cmp     [BYTE DrawBuffer], 1
        jne     @@setdest
        add     eax, Buffer1Address
@@setdest:
        mov     [DWORD FS:ACLDA], eax

        mov     ax, [WORD @@Width]
        dec     ax
        mov     [WORD FS:ACLXC], ax
        mov     ax, [WORD @@Height]
        dec     ax
        mov     [WORD FS:ACLYC], ax

        mov     [BYTE FS:ACLXYD], XYDR_RIGHT or XYDR_DOWN
        mov     [BYTE FS:ACLFROP], 0F0h
        mov     [BYTE FS:ACLBROP], 0F0h
        mov     [BYTE FS:ACLRC], ADRO_NONE or DARO_NONE

@@waitacl:
        test    [BYTE FS:ACLAS], XYST_BN
        jnz     @@waitacl

        mov     [BYTE FS:ACLOS], RMO OR RSO

@@exit: ret
ENDP draw_box

PROC set_tiles FAR
        mov     ax, MemMapRegSeg
        mov     fs, ax

        ; Enable the accelerated aperture
        mov     al, [FS:MMUCR]
        and     al, not MMUCR_APT_MASK
        or      al, MMUCR_APT0
        mov     [FS:MMUCR], al

        ; Configure the ACL for 16x16 tiles.
        mov     [WORD FS:ACLPYO], 3
        mov     [BYTE FS:ACLPW], PXWR_4B or PYWR_1L

        mov     [WORD FS:ACLSYO], 3
        mov     [BYTE FS:ACLSW], PXWR_4B or PYWR_1L

        mov     [WORD FS:ACLDYO], 799
        mov     [WORD FS:ACLXP], 0
        mov     [WORD FS:ACLYP], 0

        mov     [WORD FS:ACLXC], 15
        mov     [WORD FS:ACLYC], 15

        mov     [BYTE FS:ACLXYD], XYDR_RIGHT or XYDR_DOWN
        mov     [BYTE FS:ACLRC], ADRO_NONE or DARO_MIX
        mov     [BYTE FS:ACLVBS], 0

        ret
ENDP set_tiles

TILEID          EQU 0
TILEFG          EQU 1
TILEBG          EQU 2
TILESIZE        EQU 3

PROC draw_tile FAR
        ARG     @@TileData: DWORD,\
                @@TileId: BYTE, @@Fg: BYTE, @@Bg: Byte,\
                @@X: BYTE, @@Y: BYTE

        mov     ax, MMU0Aperture
        mov     es, ax

        mov     ax, MemMapRegSeg
        mov     fs, ax


        ; X and Y are in tile coordinates relative to the top
        ; left of the viewport
        xor     edx, edx
        movzx   eax, [BYTE @@Y]
        imul    eax, eax, 800
        movzx   ebx, [BYTE @@X]
        add     eax, ebx
        shl     eax, 4

        cmp     [BYTE DrawBuffer], 1
        jne     @@setmmu
        add     eax, Buffer1Address

@@setmmu:
        mov     [DWORD FS:MMU0MBP], eax

        ; Set FG
        movzx   eax, [BYTE @@Fg]
        cmp     eax, TRANSP
        jne     @@fgsol

        mov     [BYTE FS:ACLFROP], 0AAh ; Destination
        jmp     @@donefg

@@fgsol:
        lea     eax, [eax * 4 + PatternVidAddress]
        mov     [DWORD FS:ACLPA], eax
        mov     [BYTE FS:ACLFROP], 0F0h ; Pattern

@@donefg:
        ; Set BG
        movzx   eax, [BYTE @@Bg]
        cmp     eax, TRANSP
        jne     @@bgsol

        mov     [BYTE FS:ACLBROP], 0AAh ; Destination
        jmp     @@donebg
@@bgsol:
        lea     eax, [eax * 4 + PatternVidAddress]
        mov     [DWORD FS:ACLSA], eax
        mov     [BYTE FS:ACLBROP], 0CCh ; Source

@@donebg:
        lgs     di, [DWORD @@TileData]
        movzx   ax, [BYTE @@TileId]
        shl     ax, 5
        add     di, ax          ; GS:DI: Points to current tile data

        mov     cx, 32
@@write_loop:
        mov     al, [BYTE GS:DI]
        mov     [BYTE ES:00], al
        inc     di
        loop    @@write_loop

        ret
ENDP draw_tile

PROC draw_tiles FAR
        ARG     @@Map: DWORD, @@TileData: DWORD, @@ViewX: BYTE, @@ViewY: BYTE
        USES    ds

        mov     ax, MMU0Aperture
        mov     es, ax

        mov     ax, MemMapRegSeg
        mov     fs, ax

        lgs     si, [DWORD @@Map]
        lds     di, [DWORD @@TileData]

        ; Offset for the start of the viewport
        movzx   ax, [BYTE @@ViewY]
        imul    ax, ax, 50
        movzx   cx, [Byte @@ViewX]
        add     ax, cx
        imul    ax, ax, TILESIZE
        add     si, ax
        
        ; Draw loop
        mov     cx, 36              ; CX = Row Count

        ; Find out which buffer to draw into
        cmp     [BYTE DrawBuffer], 1
        je      @@buffer1
        mov     [DWORD FS:MMU0MBP], Buffer0Address
        jmp     @@row_loop
@@buffer1:
        mov     [DWORD FS:MMU0MBP], Buffer1Address

@@row_loop:
        mov     edx, 0
        mov     bx, 0
@@col_loop:
                                ; FS: ACL Registers
                                ; ES: MMU Aperture
                                ; GS: Map
                                ; DS: TileData
                                ; SI: Map Index
                                ; DI: TileData Index
                                ; BX: MMU Index

        ; Set FG
        movzx   eax, [BYTE GS:SI + TILEFG]
        cmp     eax, TRANSP
        jne     @@fgsol

        mov     [BYTE FS:ACLFROP], 0AAh ; Destination
        jmp     @@donefg

@@fgsol:
        lea     eax, [eax * 4 + PatternVidAddress]
        mov     [DWORD FS:ACLPA], eax
        mov     [BYTE FS:ACLFROP], 0F0h ; Pattern

@@donefg:
        ; Set BG
        movzx   eax, [BYTE GS:SI + TILEBG]
        cmp     eax, TRANSP
        jne     @@bgsol

        mov     [BYTE FS:ACLBROP], 0AAh ; Destination
        jmp     @@donebg
@@bgsol:
        lea     eax, [eax * 4 + PatternVidAddress]
        mov     [DWORD FS:ACLSA], eax
        mov     [BYTE FS:ACLBROP], 0CCh ; Source

@@donebg:

        push    di cx
        movzx   ax, [BYTE GS:SI]
        shl     ax, 5
        add     di, ax          ; DI: Points to current tile data
        mov     cx, 32          ; CX: loop counter
@@write_loop:
        mov     al, [BYTE DS:DI + TILEID]
        mov     [BYTE ES:BX], al
        inc     di
        loop    @@write_loop

        pop     cx di
        add     bx, 2
        add     si, TILESIZE
        inc     dx
        cmp     dx, 50
        jne     @@col_loop

        ; Set MMU0 Aperture location per row
        ; We move down by one row of tiles
        add     [DWORD FS:MMU0MBP], 800 * 16

        dec     cx
        jnz     @@row_loop

@@exit: ret
ENDP draw_tiles
END
