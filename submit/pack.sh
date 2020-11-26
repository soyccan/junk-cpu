#!/bin/sh
set -x

sdir="src"
ddir="b07902143_hw4"

mkdir -p "$ddir/codes"

cp report.pdf "$ddir/b07902143_hw4_report.pdf"
cp "$sdir"/* "$ddir/codes"

rm -f b07902143_hw4.zip
zip -r b07902143_hw4.zip b07902143_hw4
rm -rf "$ddir"
