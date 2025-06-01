addi x1,x0,10
sw x1,0(x0)
lw x2,0(x0)
jal x3,loop
addi x3,x3,8
loop:
addi x3,x3,1