#!/bin/sh
sdir="/mnt/hgfs/Documents/ca/junk-cpu/src"
ddir="b07902143_hw4"
src='CPU Control ALU ALU_Control Sign_Extend Const'

mkdir -p "$ddir/codes"

cp report.pdf "$ddir/b07902143_hw4_report.pdf"

for f in $src; do
    cp "$sdir/$f.v" "$ddir/codes"
done

rm b07902143_hw4.zip
zip -r b07902143_hw4.zip b07902143_hw4
rm -rf "$ddir"
