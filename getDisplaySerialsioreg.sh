#!/bin/bash
displaySerials=$(ioreg -k DisplayAttributes -r -d 1 | sed -n 's/.*"AlphanumericSerialNumber"="\([^"]*\)".*/\1/p' | tr '\n' ';' | sed 's/;$//')

echo $displaySerials

