.section .data

heap_start:
        .long 0

current_break:
        .long 0

.equ HEADER_SIZE, 8
.equ HDR_AVAIL_OFFSET, 0
.equ HDR_SIZE_OFSSET, 4

.equ UNAVAILABLE, 0
.equ AVAILABLE, 1
.equ BREAK, 45
.equ SYSCALL, 0x80

.section .text
.globl initAloc
.globl meuAlocaMem
.globl meuLiberaMem
.globl imprMapa

.type initAloc, @funtion
initAloc:
        pushl %ebp
        movl %esp, %ebp

        movl BREAK, %eax

.type meuAlocaMem, @function
meuAlocaMem:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax

        

	popl %ebp
	ret

.type meuLiberaMem, @function
meuLiberaMem:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	movl (%eax), %ebx
	#######Algoritmo#######
	popl %ebp
	ret

.type imprMapa, @function
imprMapa:
	pushl %ebp
	movl %esp, %ebp
	###Algoritmo###
	popl %ebp
	ret
