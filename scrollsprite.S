.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014

.define JOYPAD1 $4016

.define SCROLL_X $00
.define buttons $01

start:
    LDA #%10010000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK

    ;loadpalette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    ;color
    LDA #$12
    STA PPUDATA
    LDA #$14
    STA PPUDATA
    LDA #$16
    STA PPUDATA
    LDA #$18
    STA PPUDATA
        
    ;nametables 0 and 1
    LDA #$20
    STA PPUADDR
    LDA #00
    STA PPUADDR
    JSR logoaiv
    LDA #$24
    STA PPUADDR
    LDA #00
    STA PPUADDR
    JSR logoaiv
    ; load first sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$22
    STA PPUDATA
    LDA #$24
    STA PPUDATA
    LDA #$26
    STA PPUDATA
    LDA #$28
    STA PPUDATA

    ; load second sprite palette
    LDA #$16
    STA PPUDATA
    LDA #$17
    STA PPUDATA
    LDA #$18
    STA PPUDATA
    LDA #$19
    STA PPUDATA

    ;load logoaiv
    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDA #$08
    STA PPUDATA
    LDA #$02
    STA PPUDATA
    LDA #$04
    STA PPUDATA
    LDA #$08
    STA PPUDATA
    
    ;sprite
    LDA #28
    STA OAMDATA 
    STA $10
    LDA #$22
    STA OAMDATA
    LDA #%01000001
    STA OAMDATA 
    LDA #23
    STA OAMDATA 
    STA $11

    logoaiv: 
        LDA #$10  
        STA $10  
        STA $11  
    loopLogo:
        STX PPUDATA
        INX
        DEC $10
        BNE loopLogo
        STA $10
    loop2:
        STY PPUDATA
        DEC $10
        BNE loop2
        STA $10
        DEC $11
        BNE loopLogo
        RTS    

    loop:
        JMP loop

    readjoy:
        LDA #$01
        STA JOYPAD1
        STA buttons
        LSR A
        STA JOYPAD1
    joyloop:
        LDA JOYPAD1
        LSR A 
        ROL buttons
        BCC joyloop
        RTS

    nmi:
        PHA
        JSR readjoy
        JMP check_down        
        PLA
        RTI

    check_down:
        LDA buttons
        AND #%0000100 ; down
        BEQ go_down_done
        LDA SCROLL_X
        CMP #224
        BEQ go_down_done
        ;go_down
        INC SCROLL_X 
        LDA #0
        STA OAMADDR
        LDA SCROLL_X
        STA OAMDATA
        JMP loadscroll
    go_down_done:
        JMP check_up

    check_up:
        LDA buttons
        AND #%00001000 ; up
        BEQ go_up_done
        LDA SCROLL_X
        CMP #8
        BEQ go_up_done
        ;go_up
        DEC SCROLL_X
        LDA #0
        STA OAMADDR
        LDA SCROLL_X
        STA OAMDATA
        JMP loadscroll
    go_up_done:
        JMP check_right


    check_right:
        LDA buttons
        AND #%00000001 ; right
        BEQ go_right_done
        LDA SCROLL_X
        CMP #248
        BEQ go_right_done
        ;go_right
        INC SCROLL_X 
        LDA #3
        STA OAMADDR
        LDA SCROLL_X
        STA OAMDATA
        JMP loadscroll
    go_right_done:
        JMP check_left


    check_left:
        LDA buttons
        AND #%00000010 ; left
        BEQ go_left_done
        LDA SCROLL_X
        CMP #0
        BEQ go_left_done
        ;go_left
        DEC SCROLL_X 
        LDA #3
        STA OAMADDR
        LDA SCROLL_X
        STA OAMDATA
        JMP loadscroll
    go_left_done:
        RTI

    loadscroll:
        LDA SCROLL_X
        STA PPUSCROLL
        LDA #0
        STA PPUSCROLL
        RTI

    irq:
        RTI

    .goto $FFFA

    .dw nmi
    .dw start
    .dw irq

    .incbin mario0.chr
    .incbin aiv256.chr