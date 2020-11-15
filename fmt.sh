#!/bin/bash

declare -a translation_map  # array
translation_map=(
    'begin {'
    'endmodule }'
    'endcase }'
    'end }'
)

txt=$(< "$1")
echo '>>>>>>>>>>>>>>'
echo "$txt"
echo '<<<<<<<<<<<<<<'
echo

for rule_str in "${translation_map[@]}"; do
    rule_arr=($rule_str)

    pat="${rule_arr[0]}"
    repl="${rule_arr[1]}"

    txt="${txt//$pat/$repl}"

    echo "rule_str=$rule_str rule_arr=${rule_arr[@]} pat=$pat repl=$repl"
    echo '>>>>>>>>>>>>>>'
    echo "$txt"
    echo '<<<<<<<<<<<<<<'
    echo
done

echo "$txt" | clang-format
