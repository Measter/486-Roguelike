MACRO bitmask name, width, shift
    IF width EQ 32
       name EQU (0FFFFFFFFh SHL shift)
    ELSE
       name EQU (((1 SHL width) - 1) SHL shift)
    ENDIF
ENDM

MACRO ShowValueImpl name, value
    DISPLAY "&name = &value"
ENDM

MACRO ShowValue name
    ShowValueImpl name, %(name)
ENDM

MemMapRegSeg            EQU     0BFF0h
MMU0Aperture            EQU     0B800h

MMU0MBP                 EQU     00h
MMU1MBP                 EQU     04h
MMU2MBP                 EQU     08H

MMUCR                   EQU     13h
BitMask MMUCR_APT_MASK, 3, 0
MMUCR_APT0              EQU     001b
MMUCR_APT1              EQU     010b
MMUCR_APT2              EQU     100b

ACLOS           EQU     031h        ; Operation State
RMO             EQU     1 SHL 3
RSO             EQU     1 SHL 0

ACLSE           EQU     032h        ; Sync Enable
ACLSE_SE        EQU     1 SHL 0

ACLAS           EQU     036h        ; Accelerator State
XYST_BN         EQU     2
WRST_BN         EQU     0

ACLPA           EQU     080h        ; Pattern Address
ACLSA           EQU     084h        ; Source Address
ACLPYO          EQU     088h        ; Pattern Y Offset
ACLSYO          EQU     08Ah        ; Source Y Offset
ACLDYO          EQU     08Ch        ; Destination Y Offset

ACLVBS          EQU     08Eh        ; Virtual Bus Size
VBS_1B          EQU     00h

ACLXYD          EQU     08Fh        ; X/Y Direction
XYDR_RIGHT      EQU     00b
XYDR_LEFT       EQU     01b
XYDR_DOWN       EQU     00h
XYDR_UP         EQU     10h

ACLPW           EQU     090h        ; Pattern Wrap
ACLSW           EQU     092h        ; Source Wrap
PXWR_4B         EQU     010b SHL 0
PXWR_8B         EQU     011b SHL 0
PXWR_16B        EQU     100b SHL 0
PXWR_32B        EQU     101b SHL 0
PXWR_64B        EQU     110b SHL 0
PXWR_NONE       EQU     111b SHL 0
PYWR_1L         EQU     000b SHL 4
PYWR_2L         EQU     001b SHL 4
PYWR_4L         EQU     010b SHL 4
PYWR_8L         EQU     011b SHL 4
PYWR_NONE       EQU     111b SHL 4

ACLXP           EQU     094h    ; X Position
ACLYP           EQU     096h    ; Y Position
ACLXC           EQU     098h    ; X Count
ACLYC           EQU     09Ah    ; Y Count

ACLRC           EQU     09Ch    ; Routing Control
BitMask ACLRC_ADRO_MASK, 2, 4
ADRO_NONE       EQU     00b SHL 4
ADRO_DEST       EQU     01b SHL 4
BitMask ACLRC_DARO_MASK 3, 0
DARO_NONE       EQU     000b
DARO_SRC        EQU     001b
DARO_MIX        EQU     010b
DARO_XC         EQU     100b
DARO_YC         EQU     101b


ACLRLC          EQU     09Dh    ; Reload Control
ER_PAT          EQU     10b
ER_SRC          EQU     01b
ER_NONE         EQU     00b

ACLBROP         EQU     09Eh    ; Background ROP
ACLFROP         EQU     09Fh    ; Foreground ROP
ACLDA           EQU     0A0h    ; Destination Address

PatternVidAddress       EQU     800000 ; Above frame buffer
