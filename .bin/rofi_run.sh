#!/bin/sh

exec rofi \
	-modes combi,run,drun -combi-modes drun,run -show combi \
	-matching prefix -show-icons -theme arthur \
	-terminal konsole -run-shell-command '{terminal} -e /bin/bash -ic "{cmd} && read"'
