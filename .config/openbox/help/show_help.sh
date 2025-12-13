#!/bin/bash

killall aosd_cat 2>/dev/null

HELP_FILE=$HOME/.config/openbox/help/hot_keys_help-$1.txt

tr '\n' '\r' < $HELP_FILE | sed 's/.$//' | aosd_cat -p 0 -x 20 -y 20 -e 0 -B black -b 130 -R '#00ff00' -n "courier 13" -d 13
