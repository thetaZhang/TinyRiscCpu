addi x10, x0, 100
loop1:
  addi x1, x1, 2
  sw x1, 0(x2)
  addi x2, x2, 4
  addi x3, x3, 1
  bne x3, x10, loop1
addi x0, x0, 0
addi x0, x0, 0
addi x0, x0, 0