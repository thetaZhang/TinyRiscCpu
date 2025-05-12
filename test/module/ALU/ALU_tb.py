import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue
import random

# 操作码定义
ADD = 0b0000
SUB = 0b0001
AND = 0b0010
OR  = 0b0011
XOR = 0b0100
LT  = 0b0101
NE  = 0b0110
LTU = 0b0111

# 辅助函数：计算有符号数比较
def signed_lt(a, b, width=32):
    # 检查最高位（符号位）
    a_sign = (a >> (width-1)) & 1
    b_sign = (b >> (width-1)) & 1
    
    if a_sign != b_sign:
        return a_sign > b_sign
    else:
        return (a & ((1 << width) - 1)) < (b & ((1 << width) - 1))

# 辅助函数：检测溢出
def check_overflow(a, b, result, width=32):
    a_sign = (a >> (width-1)) & 1
    b_sign = (b >> (width-1)) & 1
    result_sign = (result >> (width-1)) & 1
    
    # 当两个操作数符号相同但结果符号不同时发生溢出
    return (a_sign == b_sign) and (result_sign != a_sign)

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
        assert dut.data_out.value == expected, f"加法错误: {a} + {b} = {expected}, 得到 {dut.data_out.value}"
        
        # 检查进位
        carry = 1 if (a + b) > 0xFFFFFFFF else 0
        assert dut.carry.value == carry, f"进位错误: 期望 {carry}, 得到 {dut.carry.value}"
        
        # 检查零标志
        zero = 1 if expected == 0 else 0
        assert dut.zero.value == zero, f"零标志错误: 期望 {zero}, 得到 {dut.zero.value}"
        
        # 检查溢出
        overflow = 1 if check_overflow(a, b, expected) else 0
        assert dut.overflow.value == overflow, f"溢出标志错误: 期望 {overflow}, 得到 {dut.overflow.value}"

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
        assert dut.data_out.value == expected, f"减法错误: {a} - {b} = {expected}, 得到 {dut.data_out.value}"
        
        # 检查零标志
        zero = 1 if expected == 0 else 0
        assert dut.zero.value == zero, f"零标志错误: 期望 {zero}, 得到 {dut.zero.value}"

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
        assert dut.data_out.value == expected, f"AND错误: {a} & {b} = {expected}, 得到 {dut.data_out.value}"
        
        # 测试OR
        dut.op_ctrl.value = OR
        await Timer(10, units="ns")
        expected = a | b
        assert dut.data_out.value == expected, f"OR错误: {a} | {b} = {expected}, 得到 {dut.data_out.value}"
        
        # 测试XOR
        dut.op_ctrl.value = XOR
        await Timer(10, units="ns")
        expected = a ^ b
        assert dut.data_out.value == expected, f"XOR错误: {a} ^ {b} = {expected}, 得到 {dut.data_out.value}"

@cocotb.test()
async def test_alu_comparisons(dut):
    """测试比较操作 (LT, LTU)"""
    for _ in range(100):
        # 使用一些特殊情况进行测试
        test_cases = [
            (0, 1),                   # 简单情况
            (0, 0),
            (1, 0),                   # 简单情况
            (0x7FFFFFFF, 0x80000000), # 最大正数和最小负数
            (0x80000000, 0x7FFFFFFF), # 最小负数和最大正数
            (random.randint(0, (1 << 32) - 1), random.randint(0, (1 << 32) - 1))  # 随机情况
        ]
        
        for a, b in test_cases:
            # 测试有符号比较 (LT)
            dut.op_ctrl.value = LT
            dut.data_in_1.value = a
            dut.data_in_2.value = b
            await Timer(10, units="ns")
            
            expected = 1 if signed_lt(a, b) else 0
            assert dut.data_out.value == expected, f"LT错误: {a} < {b} (有符号) = {expected}, 得到 {dut.data_out.value}"
            
            # 测试无符号比较 (LTU)
            dut.op_ctrl.value = LTU
            await Timer(10, units="ns")
            
            expected = 1 if (a < b) else 0
            assert dut.data_out.value == expected, f"LTU错误: {a} < {b} (无符号) = {expected}, 得到 {dut.data_out.value}, carry = {dut.carry.value}"

@cocotb.test()
async def test_alu_ne(dut):
    """测试不等于操作 (NE)"""
    for _ in range(100):
        a = random.randint(0, (1 << 32) - 1)
        b = random.randint(0, (1 << 32) - 1)
        
        dut.op_ctrl.value = NE
        dut.data_in_1.value = a
        dut.data_in_2.value = b
        
        await Timer(10, units="ns")
        
        # 检查零标志 - 如果结果为0表示相等
        expected_zero = 1 if a == b else 0
        assert dut.zero.value == expected_zero, f"NE操作零标志错误: {a} == {b} 期望零标志 = {expected_zero}, 得到 {dut.zero.value}"