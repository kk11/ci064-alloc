.section .data
A: .int 0
B: .int 0
.section .text
.globl _start
_start:

meuAlocaMem:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	#######Algoritmo#######
	#return eax = endereço#
	popl %ebp
	ret

meuLiberaMem:
	pushl %ebp
	movl %exp, %ebp
	movl 8(%ebp), %eax
	movl (%eax), %ebx
	#######Algorimo#######
	popl %ebp
	ret

imprMapa:
	pushl %ebp
	movl %exp, %ebp
	###Algorimo###
	popl %ebp
	ret


_start: