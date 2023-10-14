#!/usr/bin/zsh

BACKLIGHT_PATH="/sys/class/backlight/intel_backlight/brightness"

if [ $# -ne 1 ] && [ $# -ne 2 ];
then
	echo "Usage: ${0} [backlight]"
	echo "Usage: ${0} {-l | -h} [backlight]"
	echo "backlight range: [0,100]"
	exit 1
fi

y1=24242
y0=50
x0=0
x1=100

interpolate() {
	local x=$1
	local y=$(((y0*(x1-val)+y1*(val-x0))/(x1-x0)))
	echo $y
}

reverse_interpolate() {
	local y=$1
	local x=$(((x0*(y1-y)+x1*(y-y0))/(y1-y0)))
	echo $x
}

if [ $# -eq 1 ];
then	
	val=$1

	if (( $val >= 0 && $val <= 100 )); 
	then
		y=$(interpolate $val)
		echo "${y}" | tee "${BACKLIGHT_PATH}"	
	else
		echo "Number has to be in range [0,100]"
	fi
else
	val=$2
	add=0
	subtract=0

	if [ $1 = "-l" ];
	then
		subtract=$(interpolate $val)
	else
		add=$(interpolate $val)
	fi

	curr=$(cat "${BACKLIGHT_PATH}")
	new=$((curr+add-subtract))
	if (( $new >= $y0 && $new <= $y1 ));
	then
		echo "${new}" | tee "${BACKLIGHT_PATH}"
	else
		echo "Operation exceeds backlight interpolation range"
	fi	
fi


