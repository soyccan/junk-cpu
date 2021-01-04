#!/bin/sh
set -ex
prefix="teamImPastaBlackTea_project2"

mkdir -p "${prefix}/codes"
cp report.pdf "${prefix}/${prefix}_report.pdf"
cp src/*.v "${prefix}/codes"

rm -f "${prefix}.zip"
zip -r "${prefix}.zip" "${prefix}"
rm -rf "${prefix}"
