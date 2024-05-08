include \masm32\include\masm32rt.inc

.data
balance dw 1000
jackpot dw 100000
payoutBuf db 32 dup (?)

slot_1 dd 4 dup(?)
slot_2 dd 4 dup(?)
slot_3 dd 4 dup(?)
slot_4 dd 4 dup(?)
slot_5 dd 4 dup(?)
slot_6 dd 4 dup(?)
slot_7 dd 4 dup(?)
slot_8 dd 4 dup(?)
slot_9 dd 4 dup(?)

prng_x  DD 0 ; calculation state for RNG
prng_a  DD 1099433 ; current seed for RNG

title_screen db "Welcome to the Slot Machine game!",13,10,0
bal_screen db "Your current balance is: ",0
print_bal_buf db 16 DUP(0) ; Fixed the variable name
prompt_screen db "Press enter to spin the slot machine!",13,10,0
spinslot_buff db 256 DUP(?)
roll_screen db "Spinning the slots!...",13,10,0
win_screen db "You have won ",0
win_screen2 db " credits!",13,10,0
newline db " ",13,10,0

sloticon0 db "??",0 ; Watermelon
sloticon1 db "??",0 ; Bell
sloticon2 db "??",0 ; Cherry
sloticon3 db "??",0 ; Diamond
sloticon4 db "??",0 ; Money Bag/Jackpot

divider1 db "[ ",0
divider2 db " ] [ ",0
divider3 db " ]",13,10,0

buf dw 00000b

.code

start:
 invoke StdOut, offset title_screen
 invoke StdOut, offset bal_screen
 call print_balance

game PROC
 invoke StdOut, offset prompt_screen
 invoke StdIn, 4, offset spinslot_buff ; Wait until user presses enter
 sub balance, 5      ; Subtract cost of spin from balance when user spins slot
 invoke StdOut, offset roll_screen
 call spin_slots     ; Generates new values for the slot positions
 call display_slots  ; Prints the slot icons rolled to the console
 call row1_cmp       ; Checks if any row has 3 of the same icon, handles payouts
game ENDP

display_slots PROC

 ; Row 1
 invoke StdOut, offset divider1
 push slot_1
 call display_icon
 invoke StdOut, offset divider2
 push slot_2
 call display_icon
 invoke StdOut, offset divider3
 push slot_3
 call display_icon
 
 ; Row 2
 invoke StdOut, offset divider1
 push slot_4
 call display_icon
 invoke StdOut, offset divider2
 push slot_5
 call display_icon
 invoke StdOut, offset divider3
 push slot_6
 call display_icon
 
 ;Row 3
 invoke StdOut, offset divider1
 push slot_7
 call display_icon
 invoke StdOut, offset divider2
 push slot_8
 call display_icon
 invoke StdOut, offset divider3
 push slot_9
 call display_icon

 ret
display_slots ENDP

display_icon PROC slot_number:DWORD
 cmp slot_number, 0
 je zero
 cmp slot_number, 1
 je one
 cmp slot_number, 2
 je two
 cmp slot_number, 3
 je three
 cmp slot_number, 4
 je four

zero:
 invoke StdOut, offset sloticon0
 jmp end_disp
one:
 invoke StdOut, offset sloticon1
 jmp end_disp
two:
 invoke StdOut, offset sloticon2
 jmp end_disp
three:
 invoke StdOut, offset sloticon3
 jmp end_disp
four:
 invoke StdOut, offset sloticon4

end_disp:
 ret
display_icon ENDP

spin_slots PROC
 push 99
 call PrngGet
 mov [slot_1], eax
 push 99
 call PrngGet
 mov [slot_2], eax
 push 99
 call PrngGet
 mov [slot_3], eax
 push 99
 call PrngGet
 mov [slot_4], eax
 push 99
 call PrngGet
 mov [slot_5], eax
 push 99
 call PrngGet
 mov [slot_6], eax
 push 99
 call PrngGet
 mov [slot_7], eax
 push 99
 call PrngGet
 mov [slot_8], eax
 push 99
 call PrngGet
 mov [slot_9], eax

 call numberToSlots ; converts the random number to a slot icon
 ret
spin_slots ENDP

numberToSlots PROC
    mov eax, OFFSET slot_1
    push eax
    call numberToSlot
    mov [slot_1], eax      ; Move the value returned by numberToSlot into slot_1

    mov eax, OFFSET slot_2
    push eax
    call numberToSlot
    mov [slot_2], eax      ; Move the value returned by numberToSlot into slot_2

    mov eax, OFFSET slot_3
    push eax
    call numberToSlot
    mov [slot_3], eax      ; Move the value returned by numberToSlot into slot_3

    mov eax, OFFSET slot_4
    push eax
    call numberToSlot
    mov [slot_4], eax      ; Move the value returned by numberToSlot into slot_4

    mov eax, OFFSET slot_5
    push eax
    call numberToSlot
    mov [slot_5], eax      ; Move the value returned by numberToSlot into slot_5

    mov eax, OFFSET slot_6
    push eax
    call numberToSlot
    mov [slot_6], eax      ; Move the value returned by numberToSlot into slot_6

    mov eax, OFFSET slot_7
    push eax
    call numberToSlot
    mov [slot_7], eax      ; Move the value returned by numberToSlot into slot_7

    mov eax, OFFSET slot_8
    push eax
    call numberToSlot
    mov [slot_8], eax      ; Move the value returned by numberToSlot into slot_8

    mov eax, OFFSET slot_9
    push eax
    call numberToSlot
    mov [slot_9], eax      ; Move the value returned by numberToSlot into slot_9

    ret
numberToSlots ENDP

numberToSlot PROC number:DWORD
 cmp number, 59
 jg zero
 cmp number, 29
 jg one
 cmp number, 9
 jg two
 cmp number, 0
 jg three
 cmp number, 0
 je four

zero:
 mov eax, 0
 jmp end_numberToSlot
one:
 mov eax, 1
 jmp end_numberToSlot
two:
 mov eax, 2
 jmp end_numberToSlot
three:
 mov eax, 3
 jmp end_numberToSlot
four:
 mov eax, 4

end_numberToSlot:
 ret
numberToSlot ENDP

calc_payout PROC slot_number:DWORD  ; Calculates how much to pay out for a given winning number
 invoke StdOut, offset win_screen

 cmp slot_number, 0
 je zero
 cmp slot_number, 1
 je one
 cmp slot_number, 2
 je two
 cmp slot_number, 3
 je three
 cmp slot_number, 4
 je four

zero:
 add balance, 20
 mov buf, 20
 movzx eax, buf
 jmp end_calc_payout
one:
 add balance, 40
 mov buf, 40
 movzx eax, buf
 jmp end_calc_payout
two:
 add balance, 60
 mov buf, 60
 movzx eax, buf
 jmp end_calc_payout
three:
 add balance, 100
 mov buf, 100
 movzx eax, buf
 jmp end_calc_payout
four:
 movzx eax, jackpot
 add balance, eax
 movzx eax, jackpot

end_calc_payout:
 lea edi, payoutBuf
 call to_string                 ; convert user winning amount to a string
 invoke StdOut, addr payoutBuf  ; print how much the user won
 invoke StdOut, offset win_screen2
 
 ret
calc_payout ENDP

row1_cmp PROC   ; not sure if make this proc or label
 cmp slot_1, slot_2
 je eql
 jmp row2_cmp

eql:
 cmp slot_2, slot_3
 je payout

payout:
 push slot_1
 call calc_payout  ; determine how much to payout to the user

 call row2_cmp
 ret 
row1_cmp ENDP

row2_cmp PROC   ; not sure if make this proc or label
 cmp slot_4, slot_5
 je eql
 jmp row3_cmp

eql:
 cmp slot_5, slot_6
 je payout

payout:
 push slot_4
 call calc_payout  ; determine how much to payout to the user

 call row3_cmp
 ret 
row2_cmp ENDP

row3_cmp PROC   ; not sure if make this proc or label
 cmp slot_7, slot_8
 je eql

eql:
 cmp slot_8, slot_9
 je payout

payout:
 push slot_7
 call calc_payout  ; determine how much to payout to the user

 ret 
row3_cmp ENDP

print_balance PROC
 mov print_bal_buf, 0           ; replace the balance string with zeroes
 movzx eax, balance
 lea edi, print_bal_buf
 call to_string                    ; Convert decimal balance to ascii string
 invoke StdOut, addr print_bal_buf ; Print the user's balance
 invoke StdOut, offset newline

 ret
print_balance ENDP

PrngGet PROC range:DWORD             ; Generate a random number in range

    ; count the number of cycles since
    ; the machine has been reset
    invoke GetTickCount

    ; accumulate the value in eax and manage
    ; any carry-spill into the x state var
    adc eax, edx
    adc eax, prng_x

    ; multiply this calculation by the seed
    mul prng_a

    ; manage the spill into the x state var
    adc eax, edx
    mov prng_x, eax

    ; put the calculation in range of what
    ; was requested
    mul range

    ; ranged-random value in eax
    mov eax, edx

    ret

PrngGet ENDP

to_string PROC                     ; Convert a decimal to ascii
 mov ebx, 10
 xor ecx, ecx

 repeated_division:
  xor edx, edx
  div ebx
  push dx
  add cl,1
  or eax,eax
  jnz repeated_division

 load_digits:
  pop ax
  or al, 00110000b ; transforms to ascii
  stosb  ; store al into edi. edi = pointer to buffer
  loop load_digits
  mov byte ptr [edi], 0
  
 ret
to_string ENDP

end start
