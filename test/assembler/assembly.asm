addi x1,x0,2
addi x2,x1,3
addi x3,x1,4
addi x4,x1,5
add x5,x2,x3
add x5,x5,x4 ;;
sw x5,12(x0) ;;verify:18
addi x6,x0,1
addi x6,x6,1
addi x6,x6,2
sw x6,12(x0)
 ;; verify: 4
lw x7,16(x0)
sw x7,12(x0) ;; MEM/WB Forwarding to MEM_write (verify: 5)
lw x7,24(x0)
addi x7,x7,2
sw x7,12(x0) ;;(verify: 9)
lw x8,20(x0)
sw x1,6(x8) ;; need stall(verify: 2)
addi x0,x0,1
addi x0,x0,1
addi x0,x0,1
addi x3,x0,3 ;;x3=3
add x5,x3,x4 ;;x3=3 x4=7 x5=10
add x6,x1,x2 ;;2 5 7
add x7,x5,x6 ;;10 7 h11
sw x7,12(x0) ;; verify: h11
lw x0,12(x0) ;; don't load
sw x0,12(x0) ;; verify: 0