addi x3, x0, 100
loop:
  addi x1, x1, 1
  add x2,x2, x1
  blt x1, x3, loop
addi x0, x0, 0
addi x0, x0, 0