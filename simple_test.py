"""
Ultra-simple test for ChatDBG - just a division by zero bug
"""

def divide(a, b):
    return a / b

# This will crash with ZeroDivisionError
result = divide(10, 0)
print(f"Result: {result}")
