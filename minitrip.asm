
org 100h
; MIDI data:
    db 0xC4, 89, 0x94       ; compiles to harmless les bx,[bx+di-0x6c]
    db 0x1C, -0x93          ; compiles to sbb al, -0x93, setting the video mode
    int     10h             ; set video mode
    mov     dx, 0x330       ; MIDI port
    rep outsb               ; dump the whole code to MIDi port
    push    0xA000 - 10     ; setup segment, shift half a line to center in X
    pop     es
main:
    mov     cl, 63          ; maximum number of step is 63
    xor     bx, bx          ; bl = z
    inc     dword [si-2]    ; increase dword time, each screen [si] increases by 1
cast:
    inc     bx              ; advance z
    mov     ax, 0xCCCD      ; rrrola trick!
    mul     di              ; dx is the screencoords, dl = u, dh = v
    mov     al, dh          ; al = v
    sub     al, 100         ; shift v to center
    imul    bl              ; y=v*z
    xchg    ax, dx          ; dh is now y, al is now u
    imul    bl              ; x=u*z
    mov     al, bl          ; z
    add     ax, [si]        ; z+t, also shifts x slightly
    imul    ah              ; (z+t)*x
    imul    dh              ; (z+t)*x*y
    inc     ax              ; lot of zero in that, so increase by one to avoid a lot of walls
    test    al, 1 + 4 + 32 + 128
    loopnz  cast
    lea     ax, [bx+64]
    shr     al, 2
    stosb                   ; put pixel on screen
    imul    di, 85          ; "random" dithering
    jmp     main
