#!/bin/bash

for number in 1 2 3 4
do
    folder="Testcase$number"
    output="${folder}Diff"

    # Remove results from any previous run.
    rm -rf -- "$output"

    for first in "$folder"/*.1.txt
    do
        second="${first%.1.txt}.2.txt"

        if diff -q "$first" "$second" > /dev/null
        then
            continue
        else
            status=$?

            if [ "$status" -ne 1 ]; then
                echo "Could not compare $first and $second" >&2
                exit 1
            fi

            mkdir -p "$output"

            name="${first##*/}"
            name="${name%.1.txt}"

            diff -u "$first" "$second" \
                > "$output/${name}Diff.txt"
        fi
    done
done
