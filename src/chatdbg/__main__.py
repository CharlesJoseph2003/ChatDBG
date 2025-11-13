import sys
import warnings
from getopt import GetoptError
from pathlib import Path

# Suppress Pydantic serialization warnings from LiteLLM
warnings.filterwarnings("ignore", category=UserWarning, module="pydantic")

# Load environment variables from .env file BEFORE any other imports
try:
    from dotenv import load_dotenv
    # Look for .env in current directory or parent directories
    load_dotenv(dotenv_path=Path.cwd() / '.env', override=True)
except ImportError:
    pass  # dotenv not installed, skip

import ipdb

from chatdbg.chatdbg_pdb import ChatDBG
from chatdbg.util.config import chatdbg_config


def print_help():
    """Print help message for ChatDBG."""
    print("ChatDBG - AI-assisted debugging")
    print("\nUsage: chatdbg [options] <script> [script arguments]")
    print("\nOptions:")
    print(chatdbg_config.user_flags_help())


def main() -> None:
    ipdb.__main__._get_debugger_cls = lambda: ChatDBG

    args = chatdbg_config.parse_user_flags(sys.argv[1:])

    if "-h" in args or "--help" in args:
        print_help()

    sys.argv = [sys.argv[0]] + args

    try:
        ipdb.__main__.main()
    except GetoptError as e:
        print(f"Unrecognized option: {e.opt}\n")
        print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
