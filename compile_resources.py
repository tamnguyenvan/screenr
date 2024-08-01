#!/usr/bin/env python3

import subprocess
import os

def run_command(command):
    try:
        subprocess.run(command, check=True, shell=True)
        print(f"Command executed successfully: {command}")
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {command}")
        print(f"Error details: {e}")

def main():
    # Ensure the src directory exists
    if not os.path.exists('src'):
        os.makedirs('src')
        print("Created 'src' directory")

    # Commands to run
    commands = [
        "pyside6-rcc -o src/rc_main.py main.qrc",
        "pyside6-rcc -o src/rc_icons.py icons.qrc",
        "pyside6-rcc -o src/rc_images.py images.qrc"
    ]

    # Execute each command
    for command in commands:
        run_command(command)

if __name__ == "__main__":
    main()
