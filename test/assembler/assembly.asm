
addi x1, x0, 0          ; x1 = 0 (计数器)
addi x2, x0, 0          ; x2 = 0 (累加器)
addi x3, x0, 0          ; x3 = 0 (测试结果)

; test1loop:
;     addi x1, x1, 1          ; 计数器加1
;     add x2, x2, x1          ; 累加
;     addi x4, x0, 10         ; 循环上限
;     blt x1, x4, test1loop  ; 循环条件

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
    jal x18, test2continue
    
even:
    addi x2, x2, 2          ; 偶数加2
    
test2continue:
    addi x4, x0, 10
    blt x1, x4, test2loop  ; 循环10次

addi x0, x0, 0
addi x0, x0, 0
    