#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/catppuccin

cpu() {
	cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

	printf "^c$black^ ^b$green^ CPU"
	printf "^c$white^ ^b$grey^ $cpu_val"
}

mem() {
	printf "^c$blue^^b$black^  "
	printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^" ;;
    esac
    ssid=$(nmcli -t -f active,ssid dev wifi | grep -E '^yes' | cut -d\' -f2 | sed 's/.*://g')
    [ -z "$ssid" ] && ssid="Not Connected"
	printf "^b$black^ ^c$blue^ %s " $ssid
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆 "
	printf "^c$black^^b$blue^ $(date '+%d(%a) %h %y %H:%M:%S')"
}

volume() {
	printf "^c$black^ ^b$darkblue^ %s " $(volicon)
	printf "^b$black^ ^c$darkblue^ %s " $(amixer sget Master | grep -o '[0-9]*%' | sed 's/%//' | head -n1)
}

brightness() {
	printf "^c$black^^b$red^  "
	printf "^b$black^^c$red^ %s "$(echo "$(xrandr --verbose | awk '/Brightness/ { print $2; exit }') * 100.0" | bc | sed "s/\..*$//g")
}

kb_lang() {
	printf "^b$black^^c$green^ $(xkb-switch)"
}

recording_icon() {
    printf "^b$black^^c$red^ %s " $(cat /tmp/recordingicon)
}

nettraf_update() {
    sum=0
    for arg; do
        read -r i < "$arg"
        sum=$(( sum + i ))
    done
    cache=/tmp/${1##*/}
    [ -f "$cache" ] && read -r old < "$cache" || old=0
    printf %d\\n "$sum" > "$cache"
    printf %d\\n $(( sum - old ))
}

nettraf() {
    rx=$(nettraf_update /sys/class/net/[ew]*/statistics/rx_bytes)
    tx=$(nettraf_update /sys/class/net/[ew]*/statistics/tx_bytes)

    printf "^c$green^%4sB^c$red^ %4sB\\n" $(numfmt --to=iec $rx $tx)
}

while true; do

	# [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
	# interval=$((interval + 1))

    sleep 1 && xsetroot -name "$(recording_icon) $(volume) $(brightness) $(cpu) $(mem) $(wlan) $(nettraf) $(clock) $(kb_lang)"
done
