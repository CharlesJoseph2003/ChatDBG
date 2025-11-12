#!/bin/bash
# Quick setup script for ChatDBG on Mac/Linux

echo "============================================"
echo "ChatDBG Quick Setup"
echo "============================================"
echo ""

# Check Python version
python3 --version
echo ""

# Create virtual environment
echo "Creating virtual environment..."
python3 -m venv venv
echo ""

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
echo ""

# Install ChatDBG in development mode
echo "Installing ChatDBG and dependencies..."
pip install -e .
echo ""

echo "============================================"
echo "Setup Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Set your OpenAI API key:"
echo '   export OPENAI_API_KEY="sk-your-key-here"'
echo ""
echo "2. Test ChatDBG:"
echo "   chatdbg -c continue test_chatdbg.py"
echo ""
echo "3. At the debugger prompt, type: why"
echo ""
echo "For detailed instructions, see SETUP_INSTRUCTIONS.md"
echo "============================================"
