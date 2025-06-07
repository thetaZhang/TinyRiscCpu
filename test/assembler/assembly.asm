addi x2, x0, 400
loop:
  addi x1, x1, 4
  sw x1, 0(x1)
  blt x1, x2, loop
addi x0, x0, 0
addi x0, x0, 0