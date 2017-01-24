from PyInstaller.__main__ import run
import sys
import os

if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__))
    opts = ['AutoSetupClient/app.py', '-F']
    run(opts)
