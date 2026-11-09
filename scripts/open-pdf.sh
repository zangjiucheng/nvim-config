#!/bin/sh
# Open a PDF with the Windows default viewer from WSL (explorer.exe needs a
# Windows path, so the Linux path is converted with wslpath).
exec explorer.exe "$(wslpath -w "$1")"
