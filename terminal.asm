;---------------------------------------
;----------------------Terminal-Start---
        org 20000
        bits 16

        mov cx, 0
        mov dx, 0

        %define NEXL 0x0D, 0x0A
	
	push ax
	push bx
	push cx
	push dx
	push si
	
        jmp .main
;---------------------------------------
;-------------------------Load-Driver---

.loaddriver:
        mov ah, 0x02
        mov al, 1
        int 0x13

        jmp bx

;---------------------------------------
;---------------------Compare-Strings---

.compare:
        push si
.compareloop:
        lodsb
        scasb
        jne .notequal
        test al, al
        jnz .compareloop
        pop si
        ret

.notequal:
        pop si
        ret

;---------------------------------------
;--------------------------------Main---

.main:                                  ; Prompt
        mov si, tty
        mov cl, 6
        mov bx, 10000
        call .loaddriver

                                        ; Read driver, returns at SI
        mov cl, 5
        mov bx, 9000
        call .loaddriver

;---------------------------------------
;----------------------------Commands---

                                        ; Clear, setting video mode
        mov di, clear
        call .compare
        je .clear

                                        ; Reboot, call reboot driver
        mov di, reboot
        call .compare
        je .reboot

                                        ; Reload, call reload kernel driver
        mov di, reload
        call .compare
        je .reload

                                        ; Exit, return to kernl
        mov di, exit
        call .compare
        je .loadkernel

                                        ; Lines, cool program
        mov di, lines
        call .compare
        je .lines

        mov di, help
        call .compare
        je .help

                                        ; If nothing, echo given command
        mov cl, 6
        mov bx, 10000
        call .loaddriver

        jmp .main

.loadkernel:

	pop si
	pop dx
	pop cx
	pop bx
	pop ax

        ret

;---------------------------------------
;--------------------Command-Handlers---

.clear:
        mov ah, 0h
        mov al, 3h
        int 0x10
        jmp .main

.reboot:
        mov cl, 4
        mov bx, 9000
        call .loaddriver

.reload:
        mov cl, 3
        mov bx, 9000
        call .loaddriver

.lines:
        mov cl, 11
        mov bx, 31000
        call .loaddriver
        jmp .main

.help:
        mov si, helpmsg
        mov cl, 6
        mov bx, 10000
        call .loaddriver
        jmp .main

;---------------------------------------
;--------------------------------Data---

tty:
        db NEXL, '] ', 0

helpmsg:
        db 'reboot, clear, reload, exit, lines, help', 0

reboot:
        db 'reboot', 0

clear:
        db 'clear', 0

reload:
        db 'reload', 0

exit:
        db 'exit', 0

lines:
        db 'lines', 0

help:
        db 'help', 0
