    addi x8, x0, 0 ; x8 = baseA (假设 matrixA 从这个地址开始)
    addi x9, x0, 16 ; x9 = baseB (matrixB 从这个地址开始)
    addi x10, x0, 32 ; x10 = baseC (matrixC 从这个地址开始)

    addi x15, x0, 2       ; x15 = N (矩阵维度 = 2)

    ; --- 初始化 matrixA 的数据 ---
    ; A = [[1, 2], [3, 4]]


    addi x17, x0, 1       ; x17 = 1
    sw x17, 0(x8)         ; 存储 1 到 baseA + 0 (A[0][0])
    addi x17, x0, 2       ; x17 = 2
    sw x17, 4(x8)         ; 存储 2 到 baseA + 4 (A[0][1])
    addi x17, x0, 3       ; x17 = 3
    sw x17, 8(x8)         ; 存储 3 到 baseA + 8 (A[1][0])
    addi x17, x0, 4       ; x17 = 4
    sw x17, 12(x8)        ; 存储 4 到 baseA + 12 (A[1][1])

    ; --- 初始化 matrixB 的数据 ---
    ; B = [[5, 6], [7, 8]]


    addi x17, x0, 5       ; x17 = 5
    sw x17, 0(x9)         ; 存储 5 到 baseB + 0 (B[0][0])
    addi x17, x0, 6       ; x17 = 6
    sw x17, 4(x9)         ; 存储 6 到 baseB + 4 (B[0][1])
    addi x17, x0, 7       ; x17 = 7
    sw x17, 8(x9)         ; 存储 7 到 baseB + 8 (B[1][0])
    addi x17, x0, 8       ; x17 = 8
    sw x17, 12(x9)        ; 存储 8 到 baseB + 12 (B[1][1])


    ; --- 外层循环 (i) ---
    addi x5, x0, 0        ; x5 = i = 0

loopi:
    sub x20, x5, x15 
    blt x20, x0, loopjinit 

    ; 如果 i >= N, 结束矩阵乘法
    jal x0, endmatrixmult ; 无条件跳转到 endmatrixmult

loopjinit:
    addi x6, x0, 0        ; x6 = j = 0

loopj:
    sub x20, x6, x15      
    blt x20, x0, loopkinit 

    addi x5, x5, 1        ; i++
    jal x0, loopi        ; 无条件跳转回外层循环

loopkinit:
    addi x13, x0, 0       ; x13 = Cijsum = 0
    addi x7, x0, 0        ; x7 = k = 0

loopk:
    sub x20, x7, x15      ; x20 = k - N
    blt x20, x0, matrixelementcalc 
    ; 最内层循环 (k) 结束后
    ; 存储 C[i][j] 到内存
    ; 计算 C[i][j] 的地址偏移: (i * N + j) * 4
    addi x26, x0, 1
    sll x14, x5, x26       ; x14 = i * 2 (因为 N=2)
    add x14, x14, x6      ; x14 = (i * N) + j
    addi x26, x0, 2
    sll x14, x14, x26       ; x14 = ((i * N) + j) * 4 (字节偏移)
    add x14, x10, x14     ; x14 = C[i][j] 的内存地址

    sw x13, 0(x14)        ; 在 C[i][j] 的地址处存储 Cijsum

    addi x6, x6, 1        ; j++
    jal x0, loopj        ; 无条件跳转回中间循环

matrixelementcalc:
    ; 计算 A[i][k] 的地址: (i * N + k) * 4
    addi x26, x0, 1
    sll x14, x5, x26      ; x14 = i * 2 (因为 N=2)
    add x14, x14, x7      ; x14 = (i * N) + k
    addi x26, x0, 2
    sll x14, x14, x26     ; x14 = ((i * N) + k) * 4 (字节偏移)
    add x14, x8, x14      ; x14 = A[i][k] 的内存地址
    lw x11, 0(x14)        ; x11 = A[i][k] 的值

    ; 计算 B[k][j] 的地址: (k * N + j) * 4
    addi x26, x0, 1
    sll x14, x7, x26       ; x14 = k * 2 (因为 N=2)
    add x14, x14, x6      ; x14 = (k * N) + j
    addi x26, x0, 2
    sll x14, x14, x26      ; x14 = ((k * N) + j) * 4 (字节偏移)
    add x14, x9, x14      ; x14 = B[k][j] 的内存地址
    lw x12, 0(x14)        ; x12 = B[k][j] 的值

    ; --- 模拟乘法: x17 = x11 * x12 (Aik * Bkj) ---
    ; 使用重复加法进行乘法模拟，效率极低，但符合指令限制
    addi x17, x0, 0       ; x17 = product = 0
    addi x18, x12, 0      ; x18 = tempBkj (复制 Bkj 作为循环计数器)

multiplyloop:
    beq x18, x0, endmultiplyloop ; 如果 x18 == 0, 结束乘法循环
    add x17, x17, x11     ; product += Aik
    addi x18, x18, -1     ; tempBkj--
    jal x0, multiplyloop ; 无条件跳转回乘法循环

endmultiplyloop:
    ; 将乘积添加到 Cijsum
    add x13, x13, x17     ; Cijsum += product

    addi x7, x7, 1        ; k++
    jal x0, loopk        ; 无条件跳转回内层循环

endmatrixmult:
    ; --- 验证结果 ---
    ; 将矩阵C的特定元素加载到寄存器中以便验证
    ; C[0][0] -> x28
    ; C[0][1] -> x29
    ; C[1][0] -> x30
    ; C[1][1] -> x31

    ; 加载 C[0][0] (地址 baseC + 0)
    lw x28, 0(x10)        ; x28 = C[0][0] (预期值: 19)

    ; 加载 C[0][1] (地址 baseC + 4)
    lw x29, 4(x10)        ; x29 = C[0][1] (预期值: 22)

    ; 加载 C[1][0] (地址 baseC + 8)
    lw x30, 8(x10)        ; x30 = C[1][0] (预期值: 43)

    ; 加载 C[1][1] (地址 baseC + 12)
    lw x31, 12(x10)       ; x31 = C[1][1] (预期值: 50)

    ; 程序结束。进入无限循环以暂停处理器。
halt:
    beq x0, x0, halt      ; 无限循环