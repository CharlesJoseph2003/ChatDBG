# ChatDBG

by [Emery Berger](https://emeryberger.com), [Stephen Freund](https://www.cs.williams.edu/~freund/index.html), [Kyla Levin](https://khlevin.github.io/KylaHLevin/index.html), [Nicolas van Kempen](https://nvankempen.com/) (ordered alphabetically)

[![PyPI Latest Release](https://img.shields.io/pypi/v/chatdbg.svg)](https://pypi.org/project/chatdbg/)
[![Downloads](https://static.pepy.tech/badge/chatdbg)](https://pepy.tech/project/chatdbg)
[![Downloads](https://static.pepy.tech/badge/chatdbg/month)](https://pepy.tech/project/chatdbg)

[Read the paper!](https://raw.githubusercontent.com/plasma-umass/ChatDBG/main/ChatDBG.pdf)

[Watch the talk!](https://www.youtube.com/watch?v=XsFGMKKaYSo)

[![Watch the talk!](https://img.youtube.com/vi/XsFGMKKaYSo/0.jpg)](https://www.youtube.com/watch?v=XsFGMKKaYSo)

ChatDBG is an AI-based debugging assistant for Python code that integrates large language models into the standard Python debugger (`pdb`) to help debug your code. With ChatDBG, you can engage in a dialog with your debugger, asking open-ended questions about your program, like `why is x null?`. ChatDBG will _take the wheel_ and steer the debugger to answer your queries. ChatDBG can provide error diagnoses and suggest fixes.

As far as we are aware, ChatDBG is the _first_ debugger to automatically perform root cause analysis and to provide suggested fixes.

**Watch ChatDBG in action!**

<a href="https://asciinema.org/a/qulxiJTqwVRJPaMZ1hcBs6Clu" target="_blank"><img src="https://raw.githubusercontent.com/plasma-umass/ChatDBG/main/media/pdb.svg" /></a>

For technical details and a complete evaluation, see our FSE'25 paper, [_ChatDBG: An AI-Powered Debugging Assistant_](https://dl.acm.org/doi/10.1145/3729355) ([PDF](https://raw.githubusercontent.com/plasma-umass/ChatDBG/main/ChatDBG.pdf)).


## Installation

> [!IMPORTANT]
>
> ChatDBG currently needs to be connected to an [OpenAI account](https://openai.com/api/). _Your account will need to have a positive balance for this to work_ ([check your balance](https://platform.openai.com/account/usage)). If you have never purchased credits, you will need to purchase at least \$1 in credits (if your API account was created before August 13, 2023) or \$0.50 (if you have a newer API account) in order to have access to GPT-4, which ChatDBG uses. [Get a key here.](https://platform.openai.com/account/api-keys)
>
> Once you have an API key, set it as an environment variable called `OPENAI_API_KEY`.
>
> ```bash
> export OPENAI_API_KEY=<your-api-key>
> ```

Install ChatDBG using `pip`:

```bash
python3 -m pip install chatdbg
```

## Usage

### Debugging Python

To use ChatDBG to debug Python programs, simply run your Python script as follows:

```bash
chatdbg -c continue yourscript.py
```

ChatDBG is an extension of the standard Python debugger `pdb`. Like
`pdb`, when your script encounters an uncaught exception, ChatDBG will
enter post mortem debugging mode.

Unlike other debuggers, you can then use the `why` command to ask
ChatDBG why your program failed and get a suggested fix. After the LLM responds,
you may issue additional debugging commands or continue the conversation by entering
any other text.

#### IPython and Jupyter Support

To use ChatDBG as the default debugger for IPython or inside Jupyter Notebooks,
create a IPython profile and then add the necessary exensions on startup. (Modify
these lines as necessary if you already have a customized profile file.)

```bash
ipython profile create
echo "c.InteractiveShellApp.extensions = ['chatdbg.chatdbg_pdb', 'ipyflow']" >> ~/.ipython/profile_default/ipython_config.py
```

On the command line, you can then run:

```bash
ipython --pdb yourscript.py
```

Inside Jupyter, run your notebook with the [ipyflow kernel](https://github.com/ipyflow/ipyflow) and include this line magic at the top of the file.

```
%pdb
```


### Example

<details>
<summary>
<B>ChatDBG example in Python</B>
</summary>

```python
Traceback (most recent call last):
  File "yourscript.py", line 9, in <module>
    print(tryme(100))
  File "yourscript.py", line 4, in tryme
    if x / i > 2:
ZeroDivisionError: division by zero
Uncaught exception. Entering post mortem debugging
Running 'cont' or 'step' will restart the program
> yourscript.py(4)tryme()
-> if x / i > 2:
```

Ask `why` to have ChatDBG provide a helpful explanation why this program failed, and suggest a fix:

```python
(ChatDBG Pdb) why
The root cause of the error is that the code is attempting to
divide by zero in the line "if x / i > 2". As i ranges from 0 to 99,
it will eventually reach the value of 0, causing a ZeroDivisionError.

A possible fix for this would be to add a check for i being equal to
zero before performing the division. This could be done by adding an
additional conditional statement, such as "if i == 0: continue", to
skip over the iteration when i is zero. The updated code would look
like this:

def tryme(x):
    count = 0
    for i in range(100):
        if i == 0:
            continue
        if x / i > 2:
            count += 1
    return count

if __name__ == '__main__':
    print(tryme(100))
```

</details>
