# Wrapper so that `make` works from PowerShell / Windows Terminal.
# GNU make runs recipes with cmd.exe here (no sh on PATH).
# make.bat does the work: BeebAsm, pucrunch, then the disc image pop-beeb.ssd.
.PHONY: all build help
all: build

build:
	cmd /c .\make.bat

help:
	@echo make        - build pop-beeb.ssd (runs make.bat; assembler output in compile.txt)
	@echo make help   - this list
	@echo See START_HERE.md
