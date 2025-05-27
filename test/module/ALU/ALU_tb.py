import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import random
# 操作码定义 (与GlobalDefine.v中定义匹配)
NONE = 0
ADD = 1
SUB = 2
AND = 3
OR = 4
XOR = 5
SLL = 6
SRL = 7
LT = 8
LTU = 9

# 辅助函数：模拟有符号数比较
def signed_lt(a, b, width=32):
    """模拟有符号数比较"""
    # 转换为有符号数表示
    a_signed = a if a < (1 << (width - 1)) else a - (1 << width)
    b_signed = b if b < (1 << (width - 1)) else b - (1 << width)
    return 1 if a_signed < b_signed else 0

# 辅助函数：检测溢出
def check_overflow(a, b, is_sub=False, width=32):
    """检测加减法操作是否会溢出"""
    # 转换为有符号数表示
    a_signed = a if a < (1 << (width - 1)) else a - (1 << width)
    
    if is_sub:
        b = (~b + 1) & ((1 << width) - 1)  # 二进制补码
    
    b_signed = b if b < (1 << (width - 1)) else b - (1 << width)
    
    result = (a + b) & ((1 << width) - 1)
    result_signed = result if result < (1 << (width - 1)) else result - (1 << width)
    
    # 如果a和b符号相同，但结果符号不同，则发生溢出
    return ((a_signed >= 0 and b_signed >= 0 and result_signed < 0) or 
            (a_signed < 0 and b_signed < 0 and result_signed >= 0))

@cocotb.test()
async def test_alu_add(dut):
    """测试加法操作"""
    for _ in range(100):
        a = random.randint(0, (1 << 32) - 1)
        b = random.randint(0, (1 << 32) - 1)
        
        dut.op_ctrl.value = ADD
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        
        await Timer(10, units="ns")
        
        expected = (a + b) & 0xFFFFFFFF
        assert dut.data_out.value == expected, f"加法错误: {a} + {b} = {expected}, 得到 {int(dut.data_out.value)}"
        
        # 检查进位
        carry = 1 if (a + b) >= (1 << 32) else 0
        assert dut.carry.value == carry, f"进位错误: 期望 {carry}, 得到 {int(dut.carry.value)}"
        
        # 检查零标志
        zero = 1 if expected == 0 else 0
        assert dut.zero.value == zero, f"零标志错误: 期望 {zero}, 得到 {int(dut.zero.value)}"
        
        # 检查溢出
        overflow = 1 if check_overflow(a, b) else 0
        assert dut.overflow.value == overflow, f"溢出标志错误: 期望 {overflow}, 得到 {int(dut.overflow.value)}"

@cocotb.test()
async def test_alu_sub(dut):
    """测试减法操作"""
    for _ in range(100):
        a = random.randint(0, (1 << 32) - 1)
        b = random.randint(0, (1 << 32) - 1)
        
        dut.op_ctrl.value = SUB
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        
        await Timer(10, units="ns")
        
        expected = (a - b) & 0xFFFFFFFF
        assert dut.data_out.value == expected, f"减法错误: {a} - {b} = {expected}, 得到 {int(dut.data_out.value)}"
        
        # 检查零标志
        zero = 1 if expected == 0 else 0
        assert dut.zero.value == zero, f"零标志错误: 期望 {zero}, 得到 {int(dut.zero.value)}"
        
        # 检查溢出
        overflow = 1 if check_overflow(a, b, True) else 0
        assert dut.overflow.value == overflow, f"溢出标志错误: 期望 {overflow}, 得到 {int(dut.overflow.value)}"

@cocotb.test()
async def test_alu_logical(dut):
    """测试逻辑操作 (AND, OR, XOR)"""
    for _ in range(50):
        a = random.randint(0, (1 << 32) - 1)
        b = random.randint(0, (1 << 32) - 1)
        
        # 测试AND
        dut.op_ctrl.value = AND
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        await Timer(10, units="ns")
        expected = a & b
        assert dut.data_out.value == expected, f"AND错误: {a} & {b} = {expected}, 得到 {int(dut.data_out.value)}"
        
        # 测试OR
        dut.op_ctrl.value = OR
        await Timer(10, units="ns")
        expected = a | b
        assert dut.data_out.value == expected, f"OR错误: {a} | {b} = {expected}, 得到 {int(dut.data_out.value)}"
        
        # 测试XOR
        dut.op_ctrl.value = XOR
        await Timer(10, units="ns")
        expected = a ^ b
        assert dut.data_out.value == expected, f"XOR错误: {a} ^ {b} = {expected}, 得到 {int(dut.data_out.value)}"

@cocotb.test()
async def test_alu_shifts(dut):
    """测试移位操作 (SLL, SRL)"""
    for _ in range(50):
        a = random.randint(0, (1 << 32) - 1)
        b = random.randint(0, 31)  # 只使用低5位
        
        # 测试SLL
        dut.op_ctrl.value = SLL
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        await Timer(10, units="ns")
        expected = (a << b) & 0xFFFFFFFF
        assert dut.data_out.value == expected, f"SLL错误: {a} << {b} = {expected}, 得到 {int(dut.data_out.value)}"
        
        # 测试SRL
        dut.op_ctrl.value = SRL
        await Timer(10, units="ns")
        expected = a >> b
        assert dut.data_out.value == expected, f"SRL错误: {a} >> {b} = {expected}, 得到 {int(dut.data_out.value)}"

@cocotb.test()
async def test_alu_comparisons(dut):
    """测试比较操作 (LT, LTU)"""
    test_cases = [
        (0, 1),                   # 简单情况
        (1, 0),                   # 简单情况
        (0x7FFFFFFF, 0x80000000), # 最大正数和最小负数
        (0x80000000, 0x7FFFFFFF), # 最小负数和最大正数
        (0x80000000, 0),          # 最小负数和0
        (0, 0x80000000),          # 0和最小负数
    ]
    
    # 加入一些随机测试
    for _ in range(10):
        test_cases.append((random.randint(0, (1 << 32) - 1), random.randint(0, (1 << 32) - 1)))
    
    for a, b in test_cases:
        # 测试有符号比较 (LT)
        dut.op_ctrl.value = LT
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        await Timer(10, units="ns")
        
        expected = signed_lt(a, b)
        assert dut.data_out.value & 1 == expected, f"LT错误: {a} < {b} (有符号) = {expected}, 得到 {int(dut.data_out.value) & 1}"
        
        # 测试无符号比较 (LTU)
        dut.op_ctrl.value = LTU
        await Timer(10, units="ns")
        
        expected = 1 if a < b else 0
        assert dut.data_out.value & 1 == expected, f"LTU错误: {a} < {b} (无符号) = {expected}, 得到 {int(dut.data_out.value) & 1}"

@cocotb.test()
async def test_edge_cases(dut):
    """测试边界条件"""
    # 测试0 + 0
    dut.op_ctrl.value = ADD
    dut.data_in_1.value = 0
    dut.data_in_2.value = 0
    await Timer(10, units="ns")
    assert dut.zero.value == 1, "0+0应该设置零标志"
    
    # 测试最大值 + 1 (溢出)
    dut.op_ctrl.value = ADD
    dut.data_in_1.value = 0xFFFFFFFF
    dut.data_in_2.value = 1
    await Timer(10, units="ns")
    assert dut.carry.value == 1, "0xFFFFFFFF+1应该产生进位"
    assert dut.zero.value == 1, "0xFFFFFFFF+1结果应该为0"
    
    # 测试最小负数比较 (特殊情况)
    dut.op_ctrl.value = LT
    dut.data_in_1.value = 0x80000000  # 最小负数
    dut.data_in_2.value = 0x80000000  # 最小负数
    await Timer(10, units="ns")
    assert dut.data_out.value & 1 == 0, "相等值的LT比较应该为0"

@cocotb.test()
async def test_zero_flag(dut):
    """专门测试零标志在各种操作下的行为"""
    operations = [ADD, SUB, AND, OR, XOR, SLL, SRL]
    
    for op in operations:
        # 测试结果为0的情况
        if op in [SUB]:
            a, b = 5, 5 
        elif op in [AND, OR, XOR]:
            a, b = 0, 0
        elif op in [SLL, SRL]:
            a, b = 0, 1
        elif op in [ADD]:
            a, b = 0, 0
        
        dut.op_ctrl.value = op
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        await Timer(10, units="ns")
        
        assert dut.zero.value == 1, f"操作 {op} 结果为0时应设置零标志,{dut.data_out.value}"
        
        # 测试结果不为0的情况
        if op in [ADD, SUB]:
            a, b = 5, 3
        elif op in [AND, OR, XOR]:
            a, b = 0xFF, 0xF0
        elif op in [SLL, SRL]:
            a, b = 100, 2
        
        dut.op_ctrl.value = op
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        await Timer(10, units="ns")
        
        assert dut.zero.value == 0, f"操作 {op} 结果不为0时不应设置零标志"