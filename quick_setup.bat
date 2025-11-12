@echo off
REM Quick setup script for ChatDBG on Windows

echo ============================================
echo ChatDBG Quick Setup
echo ============================================
echo.

REM Check Python version
python --version
echo.

REM Create virtual environment
echo Creating virtual environment...
python -m venv venv
echo.

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat
echo.

REM Install ChatDBG in development mode
echo Installing ChatDBG and dependencies...
pip install -e .
echo.

echo ============================================
echo Setup Complete!
echo ============================================
echo.
echo Next steps:
echo 1. Set your OpenAI API key:
echo    $env:OPENAI_API_KEY="sk-your-key-here"
echo.
echo 2. Test ChatDBG:
echo    chatdbg -c continue test_chatdbg.py
echo.
echo 3. At the debugger prompt, type: why
echo.
echo For detailed instructions, see SETUP_INSTRUCTIONS.md
echo ============================================
