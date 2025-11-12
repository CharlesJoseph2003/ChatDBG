"""
Simple test script for ChatDBG with intentional bugs
"""

def divide_numbers(a, b):
    """Divide two numbers - has a bug!"""
    return a / b

def process_list(items):
    """Process a list - has a bug!"""
    total = 0
    for i in range(len(items) + 1):  # Bug: off-by-one error
        total += items[i]
    return total

def greet(name):
    """Greet someone - has a bug!"""
    message = f"Hello, {name.upper()}"  # Bug: missing exclamation
    return message

# Test 1: Division by zero
print("Test 1: Division")
result = divide_numbers(10, 0)
print(f"Result: {result}")

# Test 2: Index out of range (won't reach due to test 1)
print("\nTest 2: List processing")
numbers = [1, 2, 3, 4, 5]
total = process_list(numbers)
print(f"Total: {total}")

# Test 3: None type error (won't reach due to test 1)
print("\nTest 3: Greeting")
greeting = greet(None)
print(greeting)
