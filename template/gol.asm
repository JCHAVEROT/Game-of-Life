    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01

main:
    ;; TODO

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4


; BEGIN:procedure_name
procedure_name:
    ; your implementation code
    ret
; END:procedure_name

; BEGIN:clear_leds
clear_leds:
    stw zero, LEDS(zero)
    stw zero, LEDS+4(zero)
    stw zero, LEDS+8(zero)
    ret
; END:clear_leds

; BEGIN:set_pixel
set_pixel:
    addi t0, a0, 0          ; t0 = x-pos
    slli t1, a1, 2          ; t1 = y-pos*4
    addi t2, zero, LEDS     ; t2 = led array address
    addi t3, zero, 4        ; t3 = number of columns in a led array
    jmpi loop1_cond
    loop1:                  ; to choose the right led array
        sub t0, t0, t3
        add t2, t2, t3
    loop1_cond:
        bgeu t0, t3, loop1
    ldw t4, 0(t2)           ; t4 = load the led array at address t2
    add t5, t0, t1          ; t5 = x + y*4
    addi t6, zero, 1        ; t6 = 1
    sll t6, t6, t5          ; t6 = shift the '1' at the right place
    or t7, t4, t6           ; t7 = turn on the led
    stw t7, 0(t2)           ; MEM(t2) = t7
    jmp ra
; END:set_pixel

; BEGIN:wait
wait: 
    addi t0, zero, 1            ; initial counter of 2e19: set to 1 then ssli 19 
    slli t0, t0, 19             ; times since 2e19 can't be represent with 16 bits
    loop2:
        ldw t1, SPEED(zero)     ; decrement of the counter depends on the game speed
        sub t0, t0, t1
        bne t0, zero, loop2
    ret
; END:wait

; --------------------------------------------- JEREMY

; BEGIN:get_gsa
get_gsa:
    ldw t0, GSA_ID(zero)
    sll t1, a0, 2             ; t1 = a0 * 4 
    ldw v0, GSA0(t1)          ; v0 = MEM(a0 * 4 + GSA0)
    beq t0, zero, end         ; end if GSA_ID = 0
    ldw v0, GSA1(t1)          ; v0 = MEM(a0 * 4 + GSA1)
    end: 
        jmp ra
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
    ldw t0, GSA_ID(zero)
    sll t1, a0, 2                 ; t1 = a0 * 4 
    bne t0, zero, set_id1         ; jump to set_id1 if GSA_ID = 1
    set_id0:
        stw a1, GSA0(t1)          ; MEM(a0 * 4 + GSA0) = a1 
        jmpi end
    set_id1:
        stw a1, GSA1(t1)          ; MEM(a0 * 4 + GSA1) = a1
    end: 
        jmp ra
; END:set_gsa

; BEGIN:random_gsa
random_gsa:
    ldw t0, GSA_ID(zero)         ; t0 = current GSA in use
    addi t1, zero, 8             ; t1 = number of arrays
    addi t2, zero, 12            ; t2 = number of pixels in an array
    addi t3, zero, 0             ; t3 = current array number
    addi t4, zero, 0             ; t4 = current pixel number
    addi t5, zero, 0             ; t5 = the generated array
    addi t6, zero, GSA0          ; t6 = current array address, depend on GSA_ID
    beq t0, zero, generate_pixel ; evaluate which GSA array to use
    addi t6, zero, GSA1
    jmpi generate_pixel
    next_pixel:
        addi t4, t4, 1            ; t4 += 1 : next pixel
    generate_pixel:
        ldw t0, RANDOM_NUM(zero)  ; t0 = draw a random number
        andi t0, t0, 1            ; t0 = t0 % 2
        slli t5, t5, 1            ; shift left logical by 1 the generated array t5
        or t5, t5, t0             ; copy the generated pixel in the array
        bne t4, t2, next_pixel    ; evaluate if next pixel, i.e. if t4 != t2
    next_array:
        stw t5, 0(t6)                ; save array
        addi t4, zero, 0             ; t4 = 0 : reset pixel counter
        addi t3, t3, 1               ; t3 += 1 : next array
        addi t6, t6, 4               ; t6 += 4 : next array address
        bne t3, t1, generate_pixel   ; evaluate if next array, i.e. if t3 != t1
    jmp ra
; END:random_gsa

; --------------------------------------------- SEB
;; BEGIN:wait
;wait: 
;    addi t0, zero, 0x80000
;    loop:
;        addi t0, t0, -1
;        bne t0, zero, loop
;    ret
;; END:wait


; BEGIN:get_gsa
get_gsa:
    ldw t0, GSA_ID(zero)
    bne t0, zero, gamesa1_1
    slli a0, a0, 2              ;do y*4 to get a valid address
    ldw v0, GSA0(a0)
    jmpi end
    gamesa1_1:
        ldw v0, GSA1(a0)
    end:
    ret v0
; END:get_gsa

; BEGIN:set_gsa
set_gsa:
    ldw t0, GSA_ID(zero)
    bne t0, zero, gamesa1_2
    slli a1, a1, 2              ;do y*4 to get a valid address
    stw a0, GSA0(a1)
    jmpi end
    gamesa1_2:
        stw a0, GSA1(a1)
    end:
    
    ret
; END:set_gsa

; BEGIN:draw_gsa
draw_gsa:
    call clear_leds
    ldw t0, GSA_ID(zero)
    
    addi t1, zero, 0            ;line of the gsa 
    addi t2, zero, 0            ;line
    addi t3, zero, 0            ;column
    addi t4, zero, 1            ;mask to only take the first bit (000...001)
    
    bne t0, zero, gamesa1_3
    
    gamesa1_3:

    ret
; END:draw_gsa