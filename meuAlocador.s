.section .data

seg:
  .int 0
seg_ocupados:
  .int 0
byt_ocupados:
  .int 0
seg_livres:
  .int 0
byt_livres:
  .int 0
inte:
  .string "%#08x / %#08x\n"
head:
  .string "---------\nInício heap: %#010x\n"
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
search_var:
  .long 0
size_var:
  .int 0

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
  jle alloc_equal

  addl $8, %ecx
  cmpl %edx, %ecx
  jl alloc_lesser

next_mem:
  addl $8, %eax
  addl %edx, %eax #Próxima seção de memória

  jmp alloc_begin

alloc_equal:
  movl $UNAVAILABLE, 0(%eax) #Seta essa seção como ocupada
  movl %edx, 4(%eax)
  addl $8, %eax

  movl %ebp, %esp
  popl %ebp
  ret

alloc_lesser:
  subl $8, %ecx
  movl $UNAVAILABLE, 0(%eax)
  movl %ecx, 4(%eax) #Seta o tamanho da seção ocupada
  addl $8, %eax

  subl %ecx, %edx
  subl $8, %edx
  addl %eax, %ecx
  movl $AVAILABLE, 0(%ecx)
  movl %edx, 4(%ecx)

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
  subl $8, %eax #Aponta para o início real da seção de memória

  movl $AVAILABLE, 0(%eax)

  movl %eax, %ebx
  addl $8, %ebx
  addl 4(%eax), %ebx #Próxima seção de memória

  cmpl %ebx, current_break
  je fim

  cmpl $UNAVAILABLE, 0(%ebx) #isAvailable
  je fim

  movl 4(%ebx), %ecx
  addl $8, %ecx #ecx = tamanho da seção
  addl %ecx, 4(%eax) #junta as duas seções livres

fim:
  movl %ebp, %esp
  popl %ebp
  ret

.type imprMapa, @function
imprMapa:
  pushl %ebp
  movl %esp, %ebp

  movl $0, seg
  movl $0, seg_ocupados
  movl $0, byt_ocupados
  movl $0, seg_livres
  movl $0, byt_livres #Reseta os valores

  pushl current_break
  pushl $head
  call printf #---------
  addl $8, %esp #limpa a pilha

  movl heap_start, %eax
  movl %eax, search_var
  
begin_print:
  movl search_var, %eax
  movl current_break, %ebx
  cmpl %eax, %ebx #Chegou ao fim
  je end_print

  incl seg
  movl 4(%eax), %ebx
  movl %ebx, size_var 

  cmpl $UNAVAILABLE, 0(%eax) #isAvailable?
  je occp

  incl seg_livres
  movl size_var, %eax
  addl %eax, byt_livres

  pushl size_var
  pushl seg
  pushl $segmento
  call printf #Segmento X: xxx bytes
  addl $12, %esp

  pushl $livres
  call printf #livres
  addl $4, %esp

  addl $8, search_var
  movl size_var, %eax
  addl %eax, search_var

  jmp begin_print

occp:
  incl seg_ocupados
  movl size_var, %eax
  addl %eax, byt_ocupados

  pushl size_var
  pushl seg
  pushl $segmento
  call printf #Segmento X: xxx bytes
  addl $12, %esp

  pushl $ocupados
  call printf #ocupados
  addl $4, %esp

  addl $8, search_var
  movl size_var, %eax
  addl %eax, search_var

  jmp begin_print 

end_print:
  pushl byt_ocupados
  pushl seg_ocupados
  pushl $segocc
  call printf #Segmentos Ocupados: X / xxx bytes
  addl $12, %esp

  pushl byt_livres
  pushl seg_livres
  pushl $segfree
  call printf #Segmentos Livres: X / xxx bytes
  addl $12, %esp

  movl %ebp, %esp
  popl %ebp
  ret
