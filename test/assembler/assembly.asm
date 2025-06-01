
addi x1, x0, 0          
addi x2, x0, 0          
addi x3, x0, 0          

test1loop:
    addi x1, x1, 1         
    add x2, x2, x1         
    addi x4, x0, 10        
    blt x1, x4, test1loop  

    addi x1, x0, 0        
test2loop:
    addi x1, x1, 1          
    addi x5, x0, 1
    and x6, x1, x5          
    beq x6, x0, even

    addi x2, x2, 1
    jal x0, test2continue

even:
    addi x2, x2, 2

test2continue:
    addi x4, x0, 10
    blt x1, x4, test2loop  


    addi x1, x0, 0          

outerloop:
    addi x1, x1, 1          
    addi x7, x0, 0          
    
innerloop:
    add x2, x2, x1          
    addi x7, x7, 1          
    addi x8, x0, 2          
    blt x7, x8, innerloop
    
    addi x9, x0, 3          
    blt x1, x9, outerloop


    addi x10, x0, 82        
    beq x2, x10, success    
    

    addi x3, x0, 0          
    jal x0, endtest
    
success:
    addi x3, x0, 1          

endtest:

    add x30, x0, x2         
    add x31, x0, x3         
    