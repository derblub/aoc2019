
; https://adventofcode.com/2019/day/5

; Most probably only compiles on 64bit linux. This is basically a hello-world program
; which outputs two lines with the correct puzzle answer to stdout, calling `write`
; then exists calling `exit`.
;
; nasm -f elf64 -o main.o main.asm && ld -o main main.o && ./main
;
; get real outputs by executing following two scripts:
; echo "1" | ./lib/intcode.py --input ./input.txt | cut -c 14- | sed "s/'/\"/g" | jq -r '.output[-1]'
; echo "5" | ./lib/intcode.py --input ./input.txt | cut -c 14- | sed "s/'/\"/g" | jq -r '.output[-1]'


global _start

section .text

_start:
  mov rax, 1        ; write(
  mov rdi, 1        ;   STDOUT_FILENO,
  mov rsi, out1     ;   "output: ...\n",
  mov rdx, out1len  ;   sizeof("output: ...\n")
  syscall           ; );

  mov rax, 1        ; write(
  mov rdi, 1        ;   STDOUT_FILENO,
  mov rsi, out2     ;   "output p2: ...\n",
  mov rdx, out2len  ;   sizeof("output p2: ...\n")
  syscall           ; );

  mov rax, 60       ; exit(
  mov rdi, 0        ;   EXIT_SUCCESS
  syscall           ; );

section .rodata
  out1: db "output: 14522484", 0x0a     ; 0x0a > \n
  out1len: equ $ - out1
  out2: db "output p2: 4655956", 0x0a
  out2len: equ $ - out2
