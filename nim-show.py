#!/usr/bin/env python

import glob
import os

TEMPDIR = os.path.join(os.environ['HOME'], 'tmp')
EDITOR = os.environ.get('EDITOR', 'vim')

def mtime(f):
    return os.stat(os.path.join(f)).st_mtime

file_h = max(glob.glob('{}/P_*.h'.format(TEMPDIR)), key=mtime)
file_cpp = max(glob.glob('{}/P_*.cpp'.format(TEMPDIR)), key=mtime)

os.system('clang-format -i {} {}'.format(file_h, file_cpp))

if EDITOR in ['vim', 'gvim', 'mvim']:
    editor = '{} -o'.format(EDITOR)  # Open all files in one window.
else:
    editor = EDITOR
os.system('{} {} {}'.format(editor, file_h, file_cpp))
