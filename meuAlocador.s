.section .data

heap_start:
  .long 0

current_break:
  .long 0

.equ UNAVAILABLE, 0
.equ AVAILABLE, 1
.equ BREAK, 45
.equ SYSCALL, 0x80

.section .text
.globl initAloc
.globl meuAlocaMem
.globl meuLiberaMem
.globl imprMapa

.type initAloc, @function
initAloc:
  pushl %ebp
  movl %esp, %ebp

  movl $BREAK, %eax  #Get Break
  movl $0, %ebx
  int $SYSCALL

  incl %eax
  mov %eax, current_break #Salva o break atual

  movl %eax, heap_start #Como estamos inicializando, o heap atual é o inicial

  movl %ebp, %esp
  popl %ebp
  ret

.type meuAlocaMem, @function
meuAlocaMem:
  pushl %ebp
  movl %esp, %ebp

  movl 8(%ebp), %ecx #ecx agora tem o tamanho a ser alocado

  movl heap_start, %eax #eax agora tem a localização atual da pesquisa
  movl current_break, %ebx

alloc_begin:
  cmpl %eax, %ebx #Procura chegou ao fim
  je more_mem

  movl 4(%eax), %edx #edx = tamanho da seção de memória
  cmpl $UNAVAILABLE, 0(%eax) #isAvailable?
  je next_mem

  cmpl %edx, %ecx #if ecx <= edx, aloca aqui
  jle alloc

next_mem:
  addl 8, %eax
  addl %edx, %eax #Próxima seção de memória

  jmp alloc_begin

alloc:
  movl $UNAVAILABLE, 0(%eax) #Seta essa seção como ocupada
  movl %ecx, 4(%eax) #Seta o tamanho da seção
  addl 8, %eax

  movl %ebx, current_break

  movl %ebp, %esp
  popl %ebp
  ret

more_mem:
  addl 8, %ebx
  addl %ecx, %ebx #Adiciona o tanto de memória a mais que se precisa no break

  pushl %eax
  pushl %ebx
  pushl %ecx #salva os registradores para a chamada de função

  movl $BREAK, %eax
  int $SYSCALL #Reseta o break

  cmpl $0, %eax
  je error #erro

  popl %ecx
  popl %ebx
  popl %eax

  jmp alloc

error:
  movl $0, %eax #Em erro, retorna 0
  movl %ebp, %esp
  popl %ebp
  ret

.type meuLiberaMem, @function
meuLiberaMem:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %eax
  movl (%eax), %ebx
  #######Algoritmo#######
  movl %ebp, %esp
  popl %ebp
  ret

.type imprMapa, @function
imprMapa:
  pushl %ebp
  movl %esp, %ebp
  ###Algoritmo###
  movl %ebp, %esp
  popl %ebp
  ret
