#!/usr/bin/env python3

"""Entry point script for docker-enter utility."""

from main import main

def print_error(error: Exception) -> None:
    """Print error message to console.

    Args:
        error: The exception to print
    """
    print(f"Error: {error}")

def success() -> None:
    """Handle successful execution."""
    pass

if __name__ == '__main__':
    main(print_error, success)
