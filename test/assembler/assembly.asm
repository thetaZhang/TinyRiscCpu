; RISC-V RV32I Simple Branch Prediction Test

; 初始化寄存器
    addi x1, x0, 0          ; x1 = 0 (计数器)
    addi x2, x0, 0          ; x2 = 0 (累加器)
    addi x3, x0, 0          ; x3 = 0 (测试结果)

; 测试1: 简单循环 (10次)
; 预期: x2 += 55 (1+2+...+10)
test1loop:
    addi x1, x1, 1          ; 计数器加1
    add x2, x2, x1          ; 累加
    addi x4, x0, 10         ; 循环上限
    blt x1, x4, test1loop  ; 循环条件

; 测试2: 奇偶分支 (10次)
; 预期: x2 += 15 (5次奇数+1, 5次偶数+2)
    addi x1, x0, 0          ; 重置计数器

test2loop:
    addi x1, x1, 1          ; 计数器加1
    addi x5, x0, 1
    and x6, x1, x5          ; 检查最低位(奇偶)
    beq x6, x0, even        ; 偶数跳转
    
    ; 奇数分支
    addi x2, x2, 1          ; 奇数加1
    jal x0, test2continue
    
even:
    addi x2, x2, 2          ; 偶数加2
    
test2continue:
    addi x4, x0, 10
    blt x1, x4, test2loop  ; 循环10次

; 测试3: 嵌套循环 (外层3次，内层2次)
; 预期: x2 += 12 (1*2 + 2*2 + 3*2)
    addi x1, x0, 0          ; 外层计数器

outerloop:
    addi x1, x1, 1          ; 外层计数器加1
    addi x7, x0, 0          ; 内层计数器
    
innerloop:
    add x2, x2, x1          ; 累加外层计数器值
    addi x7, x7, 1          ; 内层计数器加1
    addi x8, x0, 2          ; 内层循环2次
    blt x7, x8, innerloop
    
    addi x9, x0, 3          ; 外层循环3次
    blt x1, x9, outerloop

; 验证结果
; 预期总和: 55 + 15 + 12 = 82
    addi x10, x0, 82        ; 预期结果
    beq x2, x10, success    ; 如果结果正确
    
    ; 失败
    addi x3, x0, 0          ; x3 = 0 (失败)
    jal x0, endtest
    
success:
    addi x3, x0, 1          ; x3 = 1 (成功)

endtest:
    ; 最终结果
    add x30, x0, x2         ; x30 = 累加结果 (应该是82)
    add x31, x0, x3         ; x31 = 验证结果 (1=成功, 0=失败)

    
