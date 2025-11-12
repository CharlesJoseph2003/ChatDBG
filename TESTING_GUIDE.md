# ChatDBG Testing Guide

## Quick Start (3 Steps)

### Step 1: Install ChatDBG

**Windows:**
```bash
.\quick_setup.bat
```

**Mac/Linux:**
```bash
./quick_setup.sh
```

This will:
- Create a virtual environment
- Install ChatDBG and all dependencies
- Set up the `chatdbg` command

### Step 2: Set Your OpenAI API Key

**Get a key:** https://platform.openai.com/api-keys

**Set it (Windows PowerShell):**
```powershell
$env:OPENAI_API_KEY="sk-your-actual-key-here"
```

**Set it (Mac/Linux):**
```bash
export OPENAI_API_KEY="sk-your-actual-key-here"
```

**Verify it's set:**
```bash
# Windows PowerShell
$env:OPENAI_API_KEY

# Mac/Linux
echo $OPENAI_API_KEY
```

### Step 3: Run Your First Test

```bash
chatdbg -c continue simple_test.py
```

When the program crashes, type:
```
(ChatDBG) why
```

Watch the AI analyze the bug and suggest a fix! ✨

---

## Test Scripts Included

I've created several test scripts for you:

### 1. **simple_test.py** - Easiest
A basic division by zero error. Perfect for your first test.

```bash
chatdbg -c continue simple_test.py
```

**Try asking:**
- `why`
- `what went wrong?`
- `how do I fix this?`
- `why is b zero?`

### 2. **test_chatdbg.py** - More Complex
Multiple bugs to explore:
- Division by zero
- Index out of bounds
- None type error

```bash
chatdbg -c continue test_chatdbg.py
```

**Try asking:**
- `why`
- `what's the root cause?`
- `show me the fix`
- `explain this function`

---

## Testing Different Features

### Feature 1: "Take the Wheel" (AI Runs Commands)

By default, ChatDBG lets the AI execute debugger commands to investigate.

```bash
chatdbg -c continue simple_test.py
```

At the prompt:
```
(ChatDBG) why
```

**Watch for:** You'll see the AI running commands like:
```
(ChatDBG) p b
0

(ChatDBG) bt
[stack trace...]
```

These are the AI autonomously exploring your code!

**To disable:**
```bash
chatdbg --take_the_wheel=false -c continue simple_test.py
```

### Feature 2: Different Output Formats

**Markdown (default) - Pretty formatting:**
```bash
chatdbg --format=md -c continue simple_test.py
```

**Plain text - No fancy formatting:**
```bash
chatdbg --format=text -c continue simple_test.py
```

**Basic markdown - Simpler colors:**
```bash
chatdbg --format=md:basic -c continue simple_test.py
```

### Feature 3: Conversation History

ChatDBG remembers your conversation:

```bash
chatdbg -c continue simple_test.py
```

```
(ChatDBG) why
[AI explains the bug]

(ChatDBG) can you show me a better fix?
[AI provides alternative solution]

(ChatDBG) what if I want to handle this with exceptions?
[AI shows exception handling approach]
```

**Start fresh conversation:**
```
(ChatDBG) renew
```

### Feature 4: Traditional Debugger Commands

All standard pdb commands work:

```bash
chatdbg -c continue test_chatdbg.py
```

```
(ChatDBG) bt                    # Show backtrace
(ChatDBG) p a                   # Print variable 'a'
(ChatDBG) pp locals()           # Pretty-print all locals
(ChatDBG) l                     # List source code
(ChatDBG) up                    # Move up stack frame
(ChatDBG) down                  # Move down stack frame
(ChatDBG) why                   # Ask AI (ChatDBG feature!)
```

### Feature 5: Examining Variables

```bash
chatdbg -c continue test_chatdbg.py
```

```
(ChatDBG) p b                   # Traditional: print variable
0

(ChatDBG) why is b zero?        # AI: explain why b has this value
[AI traces back to where b was set]

(ChatDBG) explain the divide_numbers function
[AI explains the function's purpose and bug]
```

### Feature 6: View Logs

After any session:

```bash
print_chatdbg_log
```

This shows:
- All your questions
- All AI responses
- Commands the AI ran
- Token usage and costs
- Timestamps

Log file: `log.yaml` in current directory

### Feature 7: Configuration

Check current config:
```bash
chatdbg -c continue simple_test.py
```

```
(ChatDBG) config
```

Shows all current settings.

Change settings:
```bash
chatdbg --model=gpt-4o --context=5 --show_locals=false -c continue simple_test.py
```

---

## Example Test Session

Here's what a complete test session looks like:

```bash
$ chatdbg -c continue simple_test.py

Python 3.11.8
[... script output ...]
ZeroDivisionError: division by zero
Uncaught exception. Entering post mortem debugging
> C:\Users\chuck\Documents\ChatDBG-1\simple_test.py(6)divide()
-> return a / b
(ChatDBG) why

   The root cause of this error is that the function `divide` is
   being called with b=0, which causes a ZeroDivisionError when
   attempting to compute a / b.

   Looking at line 9, you explicitly pass 0 as the second argument:

   ```python
   result = divide(10, 0)
   ```

   ##### Recommendation

   Add validation to prevent division by zero:

   ```python
   def divide(a, b):
       if b == 0:
           raise ValueError("Cannot divide by zero")
       return a / b
   ```

[Cost: ~$0.02 USD]

(ChatDBG) what if I want to return None instead of raising an error?

   That's a valid alternative approach. Here's how you could modify
   the function:

   ```python
   def divide(a, b):
       if b == 0:
           return None
       return a / b
   ```

   However, be aware that returning None means you'll need to check
   the result before using it:

   ```python
   result = divide(10, 0)
   if result is not None:
       print(f"Result: {result}")
   else:
       print("Cannot divide by zero")
   ```

[Cost: ~$0.01 USD]

(ChatDBG) q

$ print_chatdbg_log

[Shows complete log with costs, timing, etc.]
```

---

## Testing Checklist

Use this checklist to verify everything works:

- [ ] Installation completed without errors
- [ ] `chatdbg --help` shows help text
- [ ] API key is set correctly
- [ ] `simple_test.py` crashes and enters debugger
- [ ] Typing `why` gets an AI response
- [ ] Response includes code formatting
- [ ] Response includes a fix recommendation
- [ ] Can ask follow-up questions
- [ ] `renew` command starts fresh conversation
- [ ] `config` command shows current settings
- [ ] Traditional pdb commands work (`p`, `bt`, `l`)
- [ ] `print_chatdbg_log` shows session logs
- [ ] Different formats work (`--format=text`, `--format=md`)
- [ ] Can disable "take the wheel" (`--take_the_wheel=false`)

---

## Troubleshooting

### "chatdbg: command not found"

You need to activate the virtual environment:

**Windows:**
```bash
venv\Scripts\activate
```

**Mac/Linux:**
```bash
source venv/bin/activate
```

You should see `(venv)` in your prompt.

### "Invalid API key"

Check that your key is set:
```bash
# Windows PowerShell
$env:OPENAI_API_KEY

# Mac/Linux
echo $OPENAI_API_KEY
```

Make sure it starts with `sk-` and has no quotes or spaces.

### "You exceeded your current quota"

You need to add credits to your OpenAI account:
https://platform.openai.com/account/billing

Minimum: $0.50-$1.00 for GPT-4 access

### Import errors

Reinstall dependencies:
```bash
pip install -e . --force-reinstall
```

### Rich/markdown formatting issues

Try plain text mode:
```bash
chatdbg --format=text -c continue simple_test.py
```

---

## Creating Your Own Test Cases

### Template for Test Scripts

```python
"""
Your test description
"""

def buggy_function(param):
    # Intentional bug here
    return param / 0  # Or other bug

# Call it to trigger the bug
result = buggy_function(42)
print(result)
```

### Good Bugs to Test

1. **Division by zero** - Easy to understand
2. **Index out of range** - List/array access
3. **None type errors** - Calling methods on None
4. **Key errors** - Dictionary access
5. **Attribute errors** - Wrong attribute names
6. **Type errors** - Wrong types in operations
7. **Logic errors** - Wrong algorithm/calculation

### Running Your Test

```bash
chatdbg -c continue your_test.py
```

Then ask questions!

---

## Advanced Testing

### Test Different Models

```bash
# GPT-4 (more expensive, better quality)
chatdbg --model=gpt-4 -c continue simple_test.py

# GPT-4o (default, good balance)
chatdbg --model=gpt-4o -c continue simple_test.py

# GPT-4o-mini (cheaper, faster, less accurate)
chatdbg --model=gpt-4o-mini -c continue simple_test.py
```

### Test with IPython

```bash
ipython --pdb
```

In IPython:
```python
from chatdbg.chatdbg_pdb import load_ipython_extension
load_ipython_extension(get_ipython())

# Now run buggy code
10 / 0  # Crashes into ChatDBG
```

Type `why` at the prompt.

### Test in Unsafe Mode

For trusted code only! Disables security sandbox:

```bash
chatdbg --unsafe=true -c continue simple_test.py
```

---

## Questions to Try

Here are interesting questions to test with ChatDBG:

**Root cause analysis:**
- `why did this crash?`
- `what's the root cause?`
- `where did this value come from?`

**Fix suggestions:**
- `how do I fix this?`
- `show me a fix`
- `what's the best way to handle this?`

**Code understanding:**
- `explain this function`
- `what does this code do?`
- `why is this approach used?`

**Debugging strategy:**
- `how should I debug this?`
- `what should I check next?`
- `what tests should I write?`

**Edge cases:**
- `what other edge cases should I consider?`
- `could this bug occur elsewhere?`
- `what similar bugs should I look for?`

---

## Next Steps After Testing

1. ✅ Try debugging your own Python code
2. ✅ Experiment with different question phrasings
3. ✅ Test the "take the wheel" feature by watching AI commands
4. ✅ Try different output formats (text, markdown, themes)
5. ✅ Check the logs to see what's sent to the LLM
6. ✅ Configure settings to your preferences
7. ✅ Use ChatDBG in your actual development workflow!

---

## Getting Help

- Full setup guide: `SETUP_INSTRUCTIONS.md`
- ChatDBG help: `chatdbg --help`
- Config help: `chatdbg` then `config --help`
- View logs: `print_chatdbg_log`

Enjoy AI-powered debugging! 🐛🤖
