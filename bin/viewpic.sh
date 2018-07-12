#!/usr/bin/env bash

convert -colorspace gray $1 $$.pgm
echo q | aview -driver stdout -kbddriver stdin -contrast 32 $$.pgm | sed -n '27,+24p'
rm $$.pgm
