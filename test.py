"""
Simple test for ChatDBG
"""

def divide(a, b):
    """Divide two numbers"""
    return a / b

def calculate(x, y):
    """Calculate something"""
    result = divide(x, y)
    return result * 2

# This will crash
print("Starting calculation...")
answer = calculate(10, 0)
print(f"Answer: {answer}")
