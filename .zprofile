if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	exec startx /usr/bin/i3
fi
