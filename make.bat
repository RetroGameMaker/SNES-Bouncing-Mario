ca65 --cpu 65816 -o main.o main.asm
ld65 -C memmap.cfg main.o -o game.sfc
C:\nsrt34w\nsrt.exe -deint "C:\rgm\SNES Programming - Part 02 [Bouncing Mario]\code\game.sfc"
C:\Users\mserb\Downloads\snes9x-1.60-win32-x64\snes9x-x64.exe "C:\rgm\SNES Programming - Part 02 [Bouncing Mario]\code\game.sfc"
