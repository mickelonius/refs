#!/bin/bash
# Basic example script to process args bash

#$ ./script -d 'hello bumblebee' -ac
#Got the -a option
#Got the -c option
#Option -d: hello bumblebee
#
#$ ./script
#Option -d: no value given
#
#$ ./script -q
#script: illegal option -- q
#error in command line parsing
#
#$ ./script -adboo 1 2 3
#Got the -a option
#Option -d: boo
#Further operands:
#        1
#        2
#        3
#
#$ ./script -d -a -- -c -b
#Option -d: -a
#Further operands:
#        -c
#        -b

if [[ $# -ne 1 ]]; then
    echo 'Too many/few arguments, expecting one' >&2
    exit 1
fi

case $1 in
    a|b|c)  # Ok
        ;;
    *)
        # The wrong first argument.
        echo 'Expected "a", "b", or "c"' >&2
        exit 1
esac

# rest of code here

# Default values:
opt_a=false
opt_b=false
opt_c=false
opt_d='no value given'

# It's the : after d that signifies that it takes an option argument.

while getopts abcd: opt; do
    case $opt in
        a) opt_a=true ;;
        b) opt_b=true ;;
        c) opt_c=true ;;
        d) opt_d=$OPTARG ;;
        *) echo 'error in command line parsing' >&2
           exit 1
    esac
done

shift "$(( OPTIND - 1 ))"

# Command line parsing is done now.
# The code below acts on the used options.
# This code would typically do sanity checks,
# like emitting errors for incompatible options,
# missing options etc.

"$opt_a" && echo 'Got the -a option'
"$opt_b" && echo 'Got the -b option'
"$opt_c" && echo 'Got the -c option'

printf 'Option -d: %s\n' "$opt_d"