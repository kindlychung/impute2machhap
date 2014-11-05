#!/usr/bin/env python3

# def which(program):
#     import os
#     def is_exe(fpath):
#         return os.path.isfile(fpath) and os.access(fpath, os.X_OK)
#
#     fpath, fname = os.path.split(program)
#     if fpath:
#         if is_exe(program):
#             return program
#     else:
#         for path in os.environ["PATH"].split(os.pathsep):
#             path = path.strip('"')
#             exe_file = os.path.join(path, program)
#             if is_exe(exe_file):
#                 return exe_file
#
#     return None

import subprocess
from shutil import which
print("Compiling impute2machhap...")
if which("gdc-4.8"):
    subprocess.call(["gdc-4.8", "impute2machhap.d"])
elif which("ldc2"):
    subprocess.call(["ldc2", "impute2machhap.d"])
else:
    raise Exception("You need gdc-4.8 or ldc2 installed and in your PATH.")

import shutil
print("Copying files...")
subprocess.call(["cp", "-avi", "impute2machhap", "i2mh", "i2mh.py", "/usr/local/bin/"])
