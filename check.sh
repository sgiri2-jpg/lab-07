#!/bin/bash

overall_fail=0

for number in 1 2 3 4
do
    folder="Testcase$number"
    output="${folder}Diff"
    failed=0
    has_differences=0

    for first in "$folder"/*.1.txt
    do
        second="${first%.1.txt}.2.txt"
        name="${first##*/}"
        name="${name%.1.txt}"
        result="$output/${name}Diff.txt"

        diff -q "$first" "$second" > /dev/null
        status=$?

        if [ "$status" -eq 0 ]; then
            # Identical pairs must not have an output file.
            if [ -e "$result" ]; then
                failed=1
            fi

        elif [ "$status" -eq 1 ]; then
            has_differences=1

            if [ ! -f "$result" ]; then
                failed=1
            else
                # Compare everything after the timestamp headers.
                if ! cmp -s \
                    <(diff -u "$first" "$second" | tail -n +3) \
                    <(tail -n +3 "$result")
                then
                    failed=1
                fi
            fi

        else
            # diff encountered an error.
            failed=1
        fi
    done

    # A difference folder must exist only when needed.
    if [ "$has_differences" -eq 1 ]; then
        if [ ! -d "$output" ]; then
            failed=1
        fi
    else
        if [ -e "$output" ]; then
            failed=1
        fi
    fi

    if [ "$failed" -eq 0 ]; then
        echo "$folder: PASS"
    else
        echo "$folder: FAIL"
        overall_fail=1
    fi
done

exit "$overall_fail"

