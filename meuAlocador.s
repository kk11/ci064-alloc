.section .data

seg:
  .int 1
seg_ocupados:
  .int 0
byt_ocupados:
  .int 0
seg_livres:
  .int 0
byt_livres:
  .int 0
head:
  .string "---------\n"
inicio:
  .string "Início heap: %#010x\n"
segmento:
  .string "Segmento %d: %03d bytes "
ocupados:
  .string "ocupados\n"
livres:
  .string "livres\n"
segocc:
  .string "Segmentos Ocupados: %d / %d bytes\n"
segfree:
  .string "Segmentos Livres: %d / %d bytes\n"

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
  addl $8, %eax
  addl %edx, %eax #Próxima seção de memória

  jmp alloc_begin

alloc:
  movl $UNAVAILABLE, 0(%eax) #Seta essa seção como ocupada
  movl %ecx, 4(%eax) #Seta o tamanho da seção
  addl $8, %eax

  movl %ebx, current_break

  movl %ebp, %esp
  popl %ebp
  ret

more_mem:
  addl $8, %ebx
  addl %ecx, %ebx #Adiciona o tanto de memória a mais que se precisa no break

  pushl %eax
  pushl %ecx
  pushl %ebx 

  movl $BREAK, %eax
  int $SYSCALL #Reseta o break

  cmpl $0, %eax
  je error #erro

  popl %ebx
  popl %ecx
  popl %eax

  movl $UNAVAILABLE, 0(%eax)
  movl %ecx, 4(%eax)
  addl $8, %eax

  movl %ebx, current_break

  movl %ebp, %esp
  popl %ebp
  ret

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

  pushl $head
  call printf #---------

  movl heap_start, %eax #eax para procura
  movl current_break, %ebx

begin_print:
  cmpl %eax, %ebx #Chegou ao fim
  je end_print

  cmpl $UNAVAILABLE, 0(%eax) #isAvailable?
  je occp

  incl $seg_livres
  movl 4(%eax), %ecx #ecx = tamanho da seção
  addl %ecx, $byt_livres

  pushl %ecx
  pushl $seg
  call printf #Segmento X: xxx bytes

  pushl $livres
  call printf #livres

  incl $seg
  addl $8, %eax
  addl %ecx, %eax

  jmp begin_print

occp:
  incl $seg_ocupados
  movl 4(%eax), %ecx #ecx = tamanho da seção
  addl %ecx, $byt_ocupados

  pushl %ecx
  pushl $seg
  call printf #Segmento X: xxx bytes

  pushl $ocupados
  call printf #ocupados

  incl $seg
  addl $8, %eax
  addl %ecx, %eax

  jmp begin_print

end_print:
  pushl $byt_ocupados
  pushl $seg_ocupados
  pushl $segocc
  call printf #Segmentos Ocupados: X / xxx bytes

  pushl $byt_livres
  pushl $seg_livres
  pushl $segfree
  call printf #Segmentos Livres: X / xxx bytes

  movl %ebp, %esp
  popl %ebp
  ret
