IDEAL
MODEL MEDIUM, PASCAL
P486
        PUBLIC init_svga
        PUBLIC init_palette
        PUBLIC deinit_svga

INCLUDE "tseng.inc"

        DATASEG
EXTRN   DrawBuffer:Byte

; Place to store the previous mode so we can restore it
TextMode        DB ?
TextModePage    DB ?
TextModeCharHt  DW ?

        CODESEG
        LOCALS

; Restores the text mode saved from calling save_text_mode.
; save_text_mode *must* have been called first.
PROC restore_text_mode NEAR
        USES    ax, bx

        mov     ah, 00h         ; BIOS: Set Video Mode
        mov     al, [TextMode]
        int     10h

        mov     ah, 05h         ; BIOS: Select Display Page
        mov     al, [TextModePage]
        int     10h

        mov     bx, [TextModeCharHt]
        cmp     bx, 8
        je      @@font8
        cmp     bx, 14
        je      @@font14

        ; Leave at default
        jmp     @@exit

@@font8:
        mov     ax, 1112h       ; BIOS: Video - Load ROM 8x8 Font
        mov     bl, 0
        int     10h
        jmp     @@exit

@@font14:
        mov     ax, 1111h       ; BIOS: Video - Load ROM 8x14 Font
        mov     bl, 0
        int     10h

@@exit: ret
ENDP restore_text_mode

; Saves the current video mode and font size for later restoration.
PROC save_text_mode NEAR
        USES    ax, bx, es

        mov     ah, 0Fh         ; BIOS: Get current video mode
        int     10h
        ; AH:   Number of colunms
        ; AL:   Display Mode
        ; BH:   Active page

        mov     [TextModePage], bh
        mov     [TextMode], al

        ; Read character height
        mov     ax, 0
        mov     es, ax
        mov     ax, [es:0485h]
        mov     [TextModeCharHt], ax

        ret
ENDP save_text_mode

; Determine if the VGA is in colour or mono mode,
; and return the port address.
; Output:
;       DX: 3D0 (Colour) or 3B0 (Mono)
PROC mono_or_colour NEAR
        USES    ax

        mov     dx, 3CCh        ; Point to Misc Register
        in      al, dx          ; Read register
        test    al, 1           ; Bit 0 stores mono/colour
        jz      @@mono

        mov     dx, 3D0h        ; Colour port
        jmp     @@exit

@@mono: mov     dx, 3B0h        ; Mono port
@@exit: ret
ENDP mono_or_colour       

PROC init_palette FAR
        USES    eax, es, fs, si

        mov     ax, MemMapRegSeg
        mov     es, ax

        mov     ax, MMU0Aperture
        mov     fs, ax

        mov     [DWORD ES:MMU0MBP], PatternVidAddress

        mov     eax, 0
        mov     si, 0
@@start:
        mov     [FS:SI], eax
        add     si, 4
        add     eax, 01010101h
        jnc     @@start

@@exit: ret
ENDP init_palette

; Attempts to change the mode to 640x480 8bpp.
; Output:
;       AL: False on failure, true on success.
PROC init_svga FAR
        USES    dx, bx, es
        call    mono_or_colour
        cmp     dx, 3D0h
        jne     @@err

        call    save_text_mode
        mov     ax, 0030h       ; BIOS Set SVGA Mode
        int     10h             ; 640x480 8bpp

        cli
        ; Enable the MMU and memory map the registers.
        mov     dx, 03D4h       ; CRTC 36h: Video System Configuration 1
        mov     al, 36h
        out     dx, al
        inc     dx
        in      al, dx
        and     al, NOT 00101000b ; Bit 5: Enable Memory Mapped Registers
        or      al, 00101000b     ; Bit 3: Enable MMU Apertures
        out     dx, al

        ; Set the VGA Memory Map
        mov     dx, 03CEh       ; GDC 6h: Miscellaneous
        mov     al, 6h
        out     dx, al
        inc     dx
        in      al, dx
        and     al, NOT 00001100b ; Bits <2:3>: Memory map control
        or      al, 00000100b
        out     dx, al

        sti

        mov     ax, MemMapRegSeg
        mov     es, ax

        ; Enable sync
        mov     [BYTE ES:ACLSE], 1

        ; Set the MMU Apertures to direct VRAM
        mov     al, [ES:MMUCR]
        and     al, not MMUCR_APT_MASK
        mov     [ES:MMUCR], al
        mov     [BYTE ES:ACLRLC], ER_NONE

        ; Start drawing into the offscreen buffer
        mov     [BYTE DrawBuffer], 1

@@yay:  mov     al, 1
        jmp     @@exit
@@err:  mov     al, 0

@@exit: ret

ENDP init_svga

PROC deinit_svga FAR
        call    restore_text_mode
        ret
ENDP deinit_svga
END
