.section .data
.section .text
.globl meuAlocaMem
.globl meuLiberaMem
.globl imprMapa

.type meuAlocaMem, @function
meuAlocaMem:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	#######Algoritmo#######
	#return eax = endereço#
	popl %ebp
	ret

.type meuLiberaMem, @function
meuLiberaMem:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	movl (%eax), %ebx
	#######Algorimo#######
	popl %ebp
	ret

.type imprMapa, @function
imprMapa:
	pushl %ebp
	movl %esp, %ebp
	###Algorimo###
	popl %ebp
	ret
