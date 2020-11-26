#!/bin/sh
set -x

rm -rf tmp
mkdir -p tmp
unzip -j CA2020_hw4.zip -d tmp
unzip -jo b07902143_hw4.zip -d tmp

(
    cd tmp
    iverilog *.v
    ./a.out
    diff output.txt output_ref.txt
)

rm -rf tmp
