
PE := main
DIR_BUILD := .\build
PY_XOR_SCRIPT := .\scripts\xor.py

all:
	nasm -fwin32 -o $(DIR_BUILD)\$(PE).obj $(PE).asm
	link /subsystem:console,5.1 /entry:main /section:.text,RWE /section:.data,RWE /SAFESEH:NO /version:5.1 /out:$(DIR_BUILD)\$(PE).exe $(DIR_BUILD)\$(PE).obj kernel32.lib
	python $(PY_XOR_SCRIPT) "xor" $(DIR_BUILD)\$(PE).exe "XOR_can_be_great" 0xA5