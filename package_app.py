import subprocess
import os

def build_with_pyinstaller(spec_path, output_dir):
    """
    Build a Python script into a standalone executable using PyInstaller.

    :param spec_path: Path to the .spec file to be used for building.
    :param output_dir: Directory where the build output will be stored.
    """
    if not os.path.isfile(spec_path):
        raise FileNotFoundError(f"The .spec file '{spec_path}' does not exist.")

    if not os.path.isdir(output_dir):
        os.makedirs(output_dir, exist_ok=True)

    # Command to run PyInstaller
    command = [
        'pyinstaller',
        '--distpath', os.path.join(output_dir, 'dist'),
        '--workpath', os.path.join(output_dir, 'build'),
        spec_path
    ]

    # Run the command
    subprocess.run(command, check=True)

if __name__ == "__main__":
    build_with_pyinstaller('./screenr.spec', './outputs')
