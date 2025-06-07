    addi x8, x0, 0 ; x8 = baseA
    addi x9, x0, 16 ; x9 = baseB 
    addi x10, x0, 32 ; x10 = baseC 

    addi x15, x0, 2       ; x15 = N 

    ; A = [[1, 2], [3, 4]]


    addi x17, x0, 1      
    sw x17, 0(x8)        
    addi x17, x0, 2      
    sw x17, 4(x8)        
    addi x17, x0, 3      
    sw x17, 8(x8)        
    addi x17, x0, 4      
    sw x17, 12(x8)       

    ; B = [[5, 6], [7, 8]]


    addi x17, x0, 5       
    sw x17, 0(x9)         
    addi x17, x0, 6       
    sw x17, 4(x9)         
    addi x17, x0, 7       
    sw x17, 8(x9)         
    addi x17, x0, 8       
    sw x17, 12(x9)        


    addi x5, x0, 0        ; x5 = i = 0

loopi:
    sub x20, x5, x15 
    blt x20, x0, loopjinit 

    jal x0, endmatrixmult

loopjinit:
    addi x6, x0, 0        ; x6 = j = 0

loopj:
    sub x20, x6, x15      
    blt x20, x0, loopkinit 

    addi x5, x5, 1        ; i++
    jal x0, loopi      

loopkinit:
    addi x13, x0, 0       ; x13 = Cijsum = 0
    addi x7, x0, 0        ; x7 = k = 0

loopk:
    sub x20, x7, x15      ; x20 = k - N
    blt x20, x0, matrixelementcalc 

    addi x26, x0, 1
    sll x14, x5, x26       ; x14 = i * 2
    add x14, x14, x6      ; x14 = (i * N) + j
    addi x26, x0, 2
    sll x14, x14, x26      ; x14 = ((i * N) + j) * 4
    add x14, x10, x14     ; x14 = C[i][j] addres

    sw x13, 0(x14)        

    addi x6, x6, 1        ; j++
    jal x0, loopj       

matrixelementcalc:

    addi x26, x0, 1
    sll x14, x5, x26      ; x14 = i * 2 
    add x14, x14, x7      ; x14 = (i * N) + k
    addi x26, x0, 2
    sll x14, x14, x26     ; x14 = ((i * N) + k) * 4 
    add x14, x8, x14      ; x14 = A[i][k] address
    lw x11, 0(x14)        ; x11 = A[i][k] 

    addi x26, x0, 1
    sll x14, x7, x26       ; x14 = k * 2 
    add x14, x14, x6      ; x14 = (k * N) + j
    addi x26, x0, 2
    sll x14, x14, x26      ; x14 = ((k * N) + j) * 4 
    add x14, x9, x14      ; x14 = B[k][j] 
    lw x12, 0(x14)        ; x12 = B[k][j]


    addi x17, x0, 0       ; x17 = product = 0
    addi x18, x12, 0      ; x18 = tempBkj

multiplyloop:
    beq x18, x0, endmultiplyloop 
    add x17, x17, x11    
    addi x18, x18, -1    
    jal x0, multiplyloop 

endmultiplyloop:
    
    add x13, x13, x17     

    addi x7, x7, 1       
    jal x0, loopk        

endmatrixmult:

    ; C[0][0] -> x28
    ; C[0][1] -> x29
    ; C[1][0] -> x30
    ; C[1][1] -> x31


    lw x28, 0(x10)        

  
    lw x29, 4(x10)      

  
    lw x30, 8(x10)        

   
    lw x31, 12(x10)       

   
halt:
    beq x0, x0, halt 