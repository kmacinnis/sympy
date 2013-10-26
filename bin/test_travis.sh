#! /usr/bin/env bash

# Exit on error
set -e
# Echo each command
set -x

if [[ "${TEST_SPHINX}" == "true" ]]; then
    cd doc
    make html-errors
    make clean
    make latex
    cd _build/latex
    export LATEXOPTIONS="-interaction=nonstopmode"
    make all
elif [[ "${TEST_SAGE}" == "true" ]]; then
    sage -v
    sage -python bin/test sympy/external/tests/test_sage.py
else
    # We change directories to make sure that we test the installed version of
    # sympy.
    mkdir empty
    cd empty

    if [[ "${TEST_DOCTESTS}" == "true" ]]; then
        cat << EOF | python
import sympy
if not sympy.doctest():
    raise Exception('Tests failed')
EOF
        cd ..
        bin/doctest doc/
    elif [[ "${TEST_SLOW}" == "true" ]]; then
        cat << EOF | python
import sympy
if not sympy.test(slow=True, timeout=180):
    # Travis times out if no activity is seen for 10 minutes. It also times
    # out if the whole tests run for more than 50 minutes.
    raise Exception('Tests failed')
EOF
    elif [[ "${TEST_THEANO}" == "true" ]]; then
        cat << EOF | python
import sympy
if not sympy.test('*theano*'):
    raise Exception('Tests failed')
EOF
    else
        cat << EOF | python
import sympy
if not sympy.test(split='${SPLIT}'):
    raise Exception('Tests failed')
EOF
        fi
fi
