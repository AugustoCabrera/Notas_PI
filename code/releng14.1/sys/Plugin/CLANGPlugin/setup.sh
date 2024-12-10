#!/bin/sh

echo ""
echo "[INFO] Compilando CLang plugin para insertar metadata en ELF exe."
echo ""

DIR=$(pwd)

CLANG_TUTOR_DIR="$DIR"
Clang_DIR=$(dirname "$(locate ClangConfig.cmake)")

export CLANG_TUTOR_DIR
export Clang_DIR

cd "$DIR" || exit
mkdir build
cd "$DIR"/build || exit
cmake -DCT_Clang_INSTALL_DIR="$Clang_DIR" "$CLANG_TUTOR_DIR"


cd "$DIR"/build || exit
make
echo ""
echo "[SUCCESS] CLang plugin compilado."
echo ""