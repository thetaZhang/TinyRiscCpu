addi x1,x0,2
addi x2,x1,3
 ;; EX/MEM Forwarding to ALU_in
addi x3,x1,4
 ;; MEM/WB Forwarding to ALU_in
addi x4,x1,5
 ;; write back first, then ID read reg x4=7
addi x7,x0,1
jal x1,loop
add x5,x2,x3
add x5,x5,x4
sw x5,12(x0);;
loop:
addi x6,x0,1
sll x7,x7,x7
blt x7,x4,loop
sw x7,12(x0);; verify 8
or x8,x2,x3
sw x8,12(x0);; verify 7
and x9,x8,x7
sw x9,12(x0);; verify 0
addi x10,x0,4
addi x11,x0,1
loop2:
srl x7,x7,x11
beq x7,x10,loop2
sw x7,12(x0);;verify 2