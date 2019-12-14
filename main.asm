; This is 65816 code
.p816

.define INIDISP  $2100 ; initial settings for screen
.define OBJSEL   $2101 ; object size $ object data area designation
.define OAMADDL  $2102 ; address for accessing OAM
.define OAMADDH  $2103
.define OAMREAD  $2138 ; OAM read register
.define OAMWRITE $2104 ; data for OAM write
.define VMAINC   $2115 ; VRAM address increment value designation
.define VMADDL   $2116 ; address for VRAM read and write
.define VMADDH   $2117
.define VMDATAL  $2118 ; data for VRAM write
.define VMDATAH  $2119 ; data for VRAM write
.define CGADD    $2121 ; address for CGRAM read and write
.define CGDATA   $2122 ; data for CGRAM write
.define TM       $212c ; main screen designation
.define NMITIMEN $4200 ; enable flag for v-blank
.define RDNMI    $4210 ; read the

.define UP 0
.define DOWN 1
.define LEFT 0
.define RIGHT 1

.segment "BSS"

DirX: .byte LEFT
DirY: .byte UP
SpritesX: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
SpritesY: .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.segment "CODE"

.proc SNESInit
 	sei 	 	; Disabled interrupts
 	clc 	 	; clear carry to switch to native mode
 	xce 	    ; Xchange carry & emulation bit. native mode
.i16
 	rep #$18 	; Binary mode (decimal mode off), X/Y 16 bit
    ldx #$1FFF  ; set stack to $1FFF
    ;txs
 	sep #$30    ; X,Y,A are 8 bit numbers
.i8
 	lda #$8F    ; screen off, full brightness
 	sta $2100   ; brightness + screen enable register
 	stz $2101   ; Sprite register (size + address in VRAM)
 	stz $2102   ; Sprite registers (address of sprite memory [OAM])
 	stz $2103   ;    ""                       ""
 	stz $2105   ; Mode 0, = Graphic mode register
 	stz $2106   ; noplanes, no mosaic, = Mosaic register
 	stz $2107   ; Plane 0 map VRAM location
 	stz $2108   ; Plane 1 map VRAM location
 	stz $2109   ; Plane 2 map VRAM location
 	stz $210A   ; Plane 3 map VRAM location
 	stz $210B   ; Plane 0+1 Tile data location
 	stz $210C   ; Plane 2+3 Tile data location
 	stz $210D   ; Plane 0 scroll x (first 8 bits)
 	stz $210D   ; Plane 0 scroll x (last 3 bits) #$0 - #$07ff
 	lda #$FF    ; The top pixel drawn on the screen isn't the top one in the tilemap, it's the one above that.
 	sta $210E   ; Plane 0 scroll y (first 8 bits)
 	sta $2110   ; Plane 1 scroll y (first 8 bits)
 	sta $2112   ; Plane 2 scroll y (first 8 bits)
 	sta $2114   ; Plane 3 scroll y (first 8 bits)
 	lda #$07    ; Since this could get quite annoying, it's better to edit the scrolling registers to fix this.
 	sta $210E   ; Plane 0 scroll y (last 3 bits) #$0 - #$07ff
 	sta $2110   ; Plane 1 scroll y (last 3 bits) #$0 - #$07ff
 	sta $2112   ; Plane 2 scroll y (last 3 bits) #$0 - #$07ff
 	sta $2114   ; Plane 3 scroll y (last 3 bits) #$0 - #$07ff
 	stz $210F   ; Plane 1 scroll x (first 8 bits)
 	stz $210F   ; Plane 1 scroll x (last 3 bits) #$0 - #$07ff
 	stz $2111   ; Plane 2 scroll x (first 8 bits)
 	stz $2111   ; Plane 2 scroll x (last 3 bits) #$0 - #$07ff
 	stz $2113   ; Plane 3 scroll x (first 8 bits)
 	stz $2113   ; Plane 3 scroll x (last 3 bits) #$0 - #$07ff
 	lda #$80    ; increase VRAM address after writing to $2119
 	sta $2115   ; VRAM address increment register
 	stz $2116   ; VRAM address low
 	stz $2117   ; VRAM address high
 	stz $211A   ; Initial Mode 7 setting register
 	stz $211B   ; Mode 7 matrix parameter A register (low)
 	lda #$01
 	sta $211B   ; Mode 7 matrix parameter A register (high)
 	stz $211C   ; Mode 7 matrix parameter B register (low)
 	stz $211C   ; Mode 7 matrix parameter B register (high)
 	stz $211D   ; Mode 7 matrix parameter C register (low)
 	stz $211D   ; Mode 7 matrix parameter C register (high)
 	stz $211E   ; Mode 7 matrix parameter D register (low)
 	sta $211E   ; Mode 7 matrix parameter D register (high)
 	stz $211F   ; Mode 7 center position X register (low)
 	stz $211F   ; Mode 7 center position X register (high)
 	stz $2120   ; Mode 7 center position Y register (low)
 	stz $2120   ; Mode 7 center position Y register (high)
 	stz $2121   ; Color number register ($0-ff)
 	stz $2123   ; BG1 & BG2 Window mask setting register
 	stz $2124   ; BG3 & BG4 Window mask setting register
 	stz $2125   ; OBJ & Color Window mask setting register
 	stz $2126   ; Window 1 left position register
 	stz $2127   ; Window 2 left position register
 	stz $2128   ; Window 3 left position register
 	stz $2129   ; Window 4 left position register
 	stz $212A   ; BG1, BG2, BG3, BG4 Window Logic register
 	stz $212B   ; OBJ, Color Window Logic Register (or,and,xor,xnor)
 	sta $212C   ; Main Screen designation (planes, sprites enable)
 	stz $212D   ; Sub Screen designation
 	stz $212E   ; Window mask for Main Screen
 	stz $212F   ; Window mask for Sub Screen
 	lda #$30
 	sta $2130   ; Color addition & screen addition init setting
 	stz $2131   ; Add/Sub sub designation for screen, sprite, color
 	lda #$E0
 	sta $2132   ; color data for addition/subtraction
 	stz $2133   ; Screen setting (interlace x,y/enable SFX data)
 	stz $4200   ; Enable V-blank, interrupt, Joypad register
 	lda #$FF
 	sta $4201   ; Programmable I/O port
 	stz $4202   ; Multiplicand A
 	stz $4203   ; Multiplier B
 	stz $4204   ; Multiplier C
 	stz $4205   ; Multiplicand C
 	stz $4206   ; Divisor B
 	stz $4207   ; Horizontal Count Timer
 	stz $4208   ; Horizontal Count Timer MSB (most significant bit)
 	stz $4209   ; Vertical Count Timer
 	stz $420A   ; Vertical Count Timer MSB
 	stz $420B   ; General DMA enable (bits 0-7)
 	stz $420C   ; Horizontal DMA (HDMA) enable (bits 0-7)
 	stz $420D	; Access cycle designation (slow/fast rom)
 	cli 	 	; Enable interrupts
 	rts
.endproc

.proc CopySetup
    sei
    clc
    xce
    lda #$8f
    sta INIDISP
    stz NMITIMEN
    rts
.endproc

.proc CopyPixels
    stz VMADDL
    stz VMADDH
    lda #$80
    sta VMAINC

    ldx #0
@LoopBlank:
    lda SpritePixelsBlank, x
    sta VMDATAL
    inx
    lda SpritePixelsBlank, x
    sta VMDATAH
    inx
    cpx #32
    bcc @LoopBlank

    ldx #0
@LoopMain:
    lda SpritePixelsMain, x
    sta VMDATAL
    inx
    lda SpritePixelsMain, x
    sta VMDATAH
    inx
    cpx #128
    bcc @LoopMain
    rts
.endproc

.proc CopyPalette
    lda #128
    sta CGADD
    ldx #0
@Loop:
    lda SpritePalette, x
    sta CGDATA
    inx
    lda SpritePalette, x
    sta CGDATA
    inx
    cpx #128
    bne @Loop
    rts
.endproc

.proc Sprite_Init_All
    lda #0
    ; Zero First parameter (SpritesX).
    ldx #0
@Loop_X:
    sta SpritesX, x
    inx
    cpx #128
    bne @Loop_X
    ; Zero Second parameter (SpritesY).
    ldx #0
@Loop_Y:
    sta SpritesY, x
    inx
    cpx #128
    bne @Loop_Y
    rts
.endproc

.proc Sprite_Init_Head
    ; Horizontal positions.
    ldx #0
    lda #(256/2 - 8)
    sta SpritesX, x
    inx
    lda #(256/2)
    sta SpritesX, x
    inx
    lda #(256/2 - 8)
    sta SpritesX, x
    inx
    lda #(256/2)
    sta SpritesX, x
    ; Vertical positions.
    ldx #0
    lda #(224/2 - 8)
    sta SpritesY, x
    inx
    lda #(224/2 - 8)
    sta SpritesY, x
    inx
    lda #(224/2)
    sta SpritesY, x
    inx
    lda #(224/2)
    sta SpritesY, x
    rts
.endproc

.proc Sprite_Copy_OAM
    stz OAMADDL
    stz OAMADDH
    ldx #0
@LoopMain:
    lda SpritesX, x
    sta OAMWRITE
    lda SpritesY, x
    sta OAMWRITE
    txa
    inc
    sta OAMWRITE
    stz OAMWRITE
    inx
    cpx #4
    bne @LoopMain
@LoopBlank:
    stz OAMWRITE
    stz OAMWRITE
    stz OAMWRITE
    stz OAMWRITE
    inx
    cpx #128
    bne @LoopBlank
    rts
.endproc

.proc Sprite_Dir_Left
    lda #LEFT
    sta DirX
    rts
.endproc

.proc Sprite_Dir_Right
    lda #RIGHT
    sta DirX
    rts
.endproc

.proc Sprite_Dir_Up
    lda #UP
    sta DirY
    rts
.endproc

.proc Sprite_Dir_Down
    lda #DOWN
    sta DirY
    rts
.endproc

.proc Sprite_Update_Move
    lda DirX
    cmp #RIGHT
    beq Sprite_Update_Add_X
    jmp Sprite_Update_Sub_X
Sprite_Update_Add_X:
    ldx #0
@Add_X_Loop:
    lda SpritesX, x
    inc
    sta SpritesX, x
    inx
    cpx #4
    bne @Add_X_Loop
    jmp Sprite_Update_Move_Check_Y

Sprite_Update_Sub_X:
    ldx #0
@Sub_X_Loop:
    lda SpritesX, x
    dec
    sta SpritesX, x
    inx
    cpx #4
    bne @Sub_X_Loop

Sprite_Update_Move_Check_Y:
    lda DirY
    cmp #DOWN
    beq Sprite_Update_Add_Y
    jmp Sprite_Update_Sub_Y
Sprite_Update_Add_Y:
    ldx #0
@Add_Y_Loop:
    lda SpritesY, x
    inc
    sta SpritesY, x
    inx
    cpx #4
    bne @Add_Y_Loop
    jmp Sprite_Update_Move_Out

Sprite_Update_Sub_Y:
    ldx #0
@Sub_Y_Loop:
    lda SpritesY, x
    dec
    sta SpritesY, x
    inx
    cpx #4
    bne @Sub_Y_Loop
Sprite_Update_Move_Out:
    rts
.endproc

.proc Sprite_Update_Toggle
    ldx #0
    lda SpritesX, x
    cmp #0
    beq Sprite_Update_Toggle_Min_X
    jmp Sprite_Update_Toggle_Check_Max_X
Sprite_Update_Toggle_Min_X:
    jsr Sprite_Dir_Right
    jmp Sprite_Update_Toggle_Check_Min_Y

Sprite_Update_Toggle_Check_Max_X:
    ldx #0
    lda SpritesX, x
    cmp #(255-16)
    beq Sprite_Update_Toggle_Max_X
    jmp Sprite_Update_Toggle_Check_Min_Y
Sprite_Update_Toggle_Max_X:
    jsr Sprite_Dir_Left

Sprite_Update_Toggle_Check_Min_Y:
    ldx #0
    lda SpritesY, x
    cmp #0
    beq Sprite_Update_Toggle_Min_Y
    jmp Sprite_Update_Toggle_Check_Max_Y
Sprite_Update_Toggle_Min_Y:
    jsr Sprite_Dir_Down
    jmp Sprite_Update_Toggle_Out

Sprite_Update_Toggle_Check_Max_Y:
    ldx #0
    lda SpritesY, x
    cmp #(224-16)
    beq Sprite_Update_Toggle_Max_Y
    jmp Sprite_Update_Toggle_Out
Sprite_Update_Toggle_Max_Y:
    jsr Sprite_Dir_Up
Sprite_Update_Toggle_Out:
    rts
.endproc

.proc Wait
    lda #0
Slow:
    inc
    cmp $ffff
    bcc Slow
    rts
.endproc

.proc ResetHandler
    ; Initialize the SNES.
    jsr SNESInit
    jsr CopySetup
    jsr CopyPixels
    jsr CopyPalette
    jsr Sprite_Init_All
    jsr Sprite_Init_Head
    jsr Sprite_Copy_OAM
    ; make Objects visible
    lda #$10
    sta TM
    ; release forced blanking, set screen to full brightness
    lda #$0f
    sta INIDISP
    ; enable NMI, turn on automatic joypad polling
    lda #$81
    sta NMITIMEN
    cli

    jsr Sprite_Dir_Left
    jsr Sprite_Dir_Up

 Forever:
    jsr Sprite_Update_Move
    jsr Sprite_Update_Toggle
    wai
    jsr Sprite_Copy_OAM
    jmp Forever
    rts
 .endproc

 .proc NMIHandler
    lda $4210
    rti
.endproc

.segment "SPRITEDATA"
SpritePixelsMain:  .incbin "data/sprite.pix"
SpritePixelsBlank: .incbin "data/blank.pix"
SpritePalette:     .incbin "data/sprite.pal"


.segment "HEADER"
.word $1337
.byte "SNES"
.byte 0, 0, 0, 0, 0, 0, 0
.byte 0
.byte 0
.byte 0
.byte "BOUNCING MARIO       "
.byte $30
.byte 0
.byte $09
.byte 0
.byte 0
.byte $33
.byte 1
.word $AAAA, $5555

;-------------------------------------------------------------------------------
;   Interrupt and Reset vectors for the 65816 CPU
;-------------------------------------------------------------------------------

.segment "VECTOR"
; native mode   COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           NMIHandler, $0000,      $0000
.word           $0000,      $0000    ; four unused bytes
; emulation m.  COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           $0000 ,     ResetHandler, $0000
