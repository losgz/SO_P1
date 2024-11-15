#!/bin/bash
cp -a src/audio.mp3 bak1/audio.mp3
mkdir bak1/dirA
cp -a src/dirA/code.c bak1/dirA/code.c
While backuping src/dirA: 0 Errors; 0 Warnings; 0 Updated; 1 Copied (2500B); 0 Deleted (0B)
WARNING: backup entry bak1/file1.txt is newer than src/file1.txt; Should not happen
cp -a src/text2.txt bak1/text2.txt
cp -a src/text.txt bak1/text.txt
While backuping src: 0 Errors; 1 Warnings; 1 Updated; 2 Copied (200B); 0 deleted (0B)
