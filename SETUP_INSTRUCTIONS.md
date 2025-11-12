# ChatDBG Setup and Testing Instructions

## Prerequisites

- Python 3.9 or higher
- An OpenAI API key (required)

## Step 1: Check Your Python Version

```bash
python --version
```

Should show Python 3.9 or higher. If not, you'll need to upgrade Python.

## Step 2: Create a Virtual Environment (Recommended)

This keeps ChatDBG's dependencies isolated from your system Python.

```bash
# Create virtual environment
python -m venv venv

# Activate it (Windows)
venv\Scripts\activate

# Activate it (Mac/Linux)
source venv/bin/activate
```

You should see `(venv)` in your prompt after activation.

## Step 3: Install ChatDBG in Development Mode

From the ChatDBG-1 directory:

```bash
# Install in editable mode with all dependencies
pip install -e .
```

This will:
- Install all dependencies listed in pyproject.toml
- Create the `chatdbg` command
- Allow you to edit the code and see changes immediately

**Alternative: Install from PyPI (stable release)**
```bash
pip install chatdbg
```

## Step 4: Set Up Your OpenAI API Key

ChatDBG requires an OpenAI API key to work.

### Get an API Key
1. Go to https://platform.openai.com/api-keys
2. Create a new API key
3. Copy it (you won't be able to see it again)

**Important:** You need at least $0.50-$1.00 in credits on your OpenAI account for GPT-4 access.
Check your balance: https://platform.openai.com/account/usage

### Set the API Key

**Option A: Environment Variable (Recommended)**

Windows (PowerShell):
```powershell
$env:OPENAI_API_KEY="sk-your-key-here"
```

Windows (Command Prompt):
```cmd
set OPENAI_API_KEY=sk-your-key-here
```

Mac/Linux:
```bash
export OPENAI_API_KEY="sk-your-key-here"
```

**Option B: Add to Your Shell Profile (Persistent)**

Add to `~/.bashrc`, `~/.zshrc`, or `~/.bash_profile`:
```bash
export OPENAI_API_KEY="sk-your-key-here"
```

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## Step 5: Verify Installation

Check that ChatDBG is installed:

```bash
chatdbg --help
```

You should see the help text.

Check the command is accessible:
```bash
which chatdbg     # Mac/Linux
where chatdbg     # Windows
```

## Step 6: Run Your First Test

### Test 1: Simple Division by Zero

Run the provided test script:

```bash
chatdbg -c continue test_chatdbg.py
```

The script will crash with a `ZeroDivisionError`. At the debugger prompt:

```
(ChatDBG) why
```

Or ask a more specific question:
```
(ChatDBG) what caused this error?
```

ChatDBG will analyze the bug and suggest a fix!

### Test 2: Create Your Own Buggy Script

Create a file `my_bug.py`:

```python
def calculate_average(numbers):
    return sum(numbers) / len(numbers)

# Bug: empty list causes ZeroDivisionError
result = calculate_average([])
print(f"Average: {result}")
```

Run it:
```bash
chatdbg -c continue my_bug.py
```

When it crashes, type:
```
(ChatDBG) why
```

## Common Commands

### At the Debugger Prompt

**Ask questions (main feature):**
```
(ChatDBG) why
(ChatDBG) why is x null?
(ChatDBG) what went wrong?
(ChatDBG) how do I fix this?
(ChatDBG) explain what this function does
```

**Traditional pdb commands still work:**
```
(ChatDBG) p variable          # Print variable
(ChatDBG) pp variable         # Pretty print
(ChatDBG) bt                  # Backtrace
(ChatDBG) l                   # List source code
(ChatDBG) up                  # Move up stack frame
(ChatDBG) down                # Move down stack frame
(ChatDBG) c                   # Continue execution
(ChatDBG) n                   # Next line
(ChatDBG) s                   # Step into
(ChatDBG) q                   # Quit
```

**ChatDBG-specific commands:**
```
(ChatDBG) renew               # Start fresh conversation
(ChatDBG) config              # Show current config
(ChatDBG) config --help       # Show config options
```

## Configuration Options

### Environment Variables

Set these before running ChatDBG:

```bash
# Use a different model
export CHATDBG_MODEL=gpt-4o

# Use plain text output (no markdown)
export CHATDBG_FORMAT=text

# Use simple markdown theme
export CHATDBG_FORMAT=md:basic

# Disable "take the wheel" (LLM can't run commands)
export CHATDBG_TAKE_THE_WHEEL=false

# Show library frames in stack traces
export CHATDBG_SHOW_LIBS=true

# Hide local variables
export CHATDBG_SHOW_LOCALS=false

# Change context lines shown
export CHATDBG_CONTEXT=5

# Disable safety sandbox (only for trusted code!)
export CHATDBG_UNSAFE=1
```

### Command-Line Flags

```bash
chatdbg --model=gpt-4o test_chatdbg.py
chatdbg --format=text test_chatdbg.py
chatdbg --take_the_wheel=false test_chatdbg.py
```

## Troubleshooting

### "Command not found: chatdbg"

**Solution:** Make sure you activated your virtual environment and pip installed successfully.

```bash
# Activate venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux

# Reinstall
pip install -e .
```

### "OpenAI API Error: Invalid API Key"

**Solution:** Check your API key is set correctly:

```bash
echo $OPENAI_API_KEY  # Mac/Linux
echo %OPENAI_API_KEY%  # Windows CMD
$env:OPENAI_API_KEY   # Windows PowerShell
```

Make sure it starts with `sk-` and has no extra spaces or quotes.

### "You exceeded your current quota"

**Solution:** Add credits to your OpenAI account at https://platform.openai.com/account/billing

### "Module not found" errors

**Solution:** Reinstall dependencies:

```bash
pip install -e . --force-reinstall
```

### IPython/ipdb errors

**Solution:** Try upgrading ipython:

```bash
pip install --upgrade ipython ipdb
```

### Rich formatting looks weird

**Solution:** Try a different format:

```bash
chatdbg --format=text test_chatdbg.py
```

Or use the basic theme:
```bash
chatdbg --format=md:basic test_chatdbg.py
```

## Testing in IPython

You can also use ChatDBG in an IPython shell:

```bash
# Start IPython with debugger on exceptions
ipython --pdb

# Import ChatDBG
from chatdbg.chatdbg_pdb import load_ipython_extension
load_ipython_extension(get_ipython())

# Now run buggy code
def divide(a, b):
    return a / b

divide(10, 0)  # Crashes, drops into ChatDBG
```

At the prompt, type `why` to get AI assistance.

## Viewing Logs

All your ChatDBG sessions are logged. To view:

```bash
print_chatdbg_log
```

This shows:
- All questions you asked
- All AI responses
- Commands the AI ran ("take the wheel")
- Token usage and costs
- Timestamps

Log file location: `log.yaml` in your current directory

## Cost Estimates

Typical costs (using GPT-4o):
- Simple "why" query: $0.01 - $0.05
- Complex debugging session: $0.05 - $0.20
- Conversation with multiple questions: $0.10 - $0.50

The more context (stack frames, variables, history), the higher the cost.

Tips to reduce costs:
- Use `--context=5` to show fewer lines of code
- Use `--show_locals=false` to hide variables
- Use `renew` command to start fresh (clears history)
- Consider using a cheaper model: `--model=gpt-4o-mini`

## Next Steps

1. Try debugging your own Python code with ChatDBG
2. Experiment with different questions to see what works best
3. Try the "take the wheel" feature by enabling it and watching the AI explore your code
4. Check out the logs to see what prompts are sent to the LLM
5. Customize the configuration to your preferences

## Example Session

```bash
$ chatdbg -c continue test_chatdbg.py

# Program crashes...

(ChatDBG) why

   The root cause of this error is that the function `divide_numbers`
   is being called with b=0 on line 25, which causes a ZeroDivisionError
   when attempting to divide 10 by 0.

   ##### Recommendation

   Add input validation to check if b is zero before dividing:

   ```python
   def divide_numbers(a, b):
       if b == 0:
           raise ValueError("Cannot divide by zero")
       return a / b
   ```

(ChatDBG) why did I pass 0 as the second argument?

   Looking at line 25 in your code, you explicitly called
   `divide_numbers(10, 0)`. This appears to be a test case
   to demonstrate the division by zero error. If this wasn't
   intentional, you may want to check where the value 0 is
   coming from.

(ChatDBG) q
```

## Getting Help

- ChatDBG help: `chatdbg --help`
- Config help: `chatdbg` then `(ChatDBG) config --help`
- Check logs: `print_chatdbg_log`
- GitHub issues: https://github.com/plasma-umass/ChatDBG/issues
