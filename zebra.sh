#!/bin/bash

################################################################
################################################################
## Script to set parameters on Zebra printers (ZM400, ZM600)
## 
## :Version	: 0.1.3:											
## :License	: MIT
################################################################
## TODO:
##	- add pasword reset function
## 	- add support for gx's
## 	- add suppoet for uploading the config files
## 	X test SNMP		- tested
## 	- move all commands from SGD to ZPL ( maybe )
## 	- rewirte script in python
################################################################
################################################################

# Variables and switches
snmp_read=''
snmp_write=''
snmp_disable=false
#snmp_enable=false
new_port=0
conn_port=5964
reboot=false
IP=""
OFF="off"
save_config=false

# Commands
printer_reboot="~JR" #zbi.control.restart  # device.reset
printer_port="internal_wired.ip.port"
printer_snmp_disable="ip.snmp.enable" # choices on/off
printer_snmp_get="ip.snmp.get_community_name"
printer_snmp_set="ip.snmp.set_community_name"
printer_save_config="^JUS"
printer_apply_active_config="^JUa"


# functions which do the connection
f_snmp_disable(){ conn_set $printer_snmp_disable $OFF $IP $conn_port; }
f_snmp_get(){ conn_set $printer_snmp_get $snmp_read $IP $conn_port; } 
f_snmp_set(){ conn_set $printer_snmp_set $snmp_write $IP $conn_port; }
f_change_port(){ conn_set $printer_port $new_port $IP $conn_port; }
f_reboot(){ conn_set_short $printer_reboot $IP $conn_port; }
f_save_config(){ 
	conn_set_short $printer_apply_active_config $IP $conn_port
	conn_set_short $printer_save_config $IP $conn_port
}

# function takes arguments : cmd, value, ip, port
conn_set(){
echo -n "Current value is : "
	conn_get_value $1 $IP $conn_port
	echo  '! U1 setvar '\"$1\"' '\"$2\" | nc -w 1 $3 $4 
echo
}
# function takes arguments : cmd, ip, port
conn_set_short(){
	echo  '! U1 '\"$1\"| nc -w 1 $2 $3
echo
}
# function takes arguments : cmd, ip, port
conn_get_value(){
	echo  '! U1 getvar '\"$1\"| nc -w 1 $2 $3
}

# Usage function
usage() { echo "Usage: $0 [-RW -D -P -p -s -r -h] <IP or hostname> ";exit 1; }

# Help function -h
helpme() { 
echo "Usage: $0 [-RW -D -P -p -s -r -h] <IP or hostname>"
cat <<DESC 

-R 'string'	Read/get coommunity string
-W 'string'	Write/set community string
-D		Disable SNMP
-P port		Change printer current port to "port"
-p port		Connect on "port". If not specified defaults to: 5964
-s		Save the current configuration
-r		Reboot the printer [ all printers ]
-h 		Displays this help message

! Put SNMP community strings in single quotes - 'comunity_string'

Examples:
Set community strings and reboot
 ./zebra.sh -R 'READ_string' -W 'WRITE_string' -r 192.168.100.155
Disable SNMP on the printer
 ./zebra.sh -D 192.168.100.155
Change default port from 9100 to 5964
 ./zebra.sh -P 5964 192.168.100.155 -p 9100
Change default port and community strings, save configuration and reload
 ./zebra.sh -P 5694 -s -r -R 'READ_string' -W 'WRITE_string' 192.168.100.155 -p 9100
Reboot the printer 
 ./zebra.sh -r 192.168.100.155
DESC
exit 1
}

[ $# -eq 0 ] && usage # if there is no arguments given display usage and exit
# looping trough the switches
while getopts ":hsrDR:W:P:p:" arg; do
	case "${arg}" in
		R)
			snmp_read=${OPTARG}
			;;
		W)
			snmp_write=${OPTARG}
			;;
		D)
			snmp_disable=true
			;;
		P)
			new_port=${OPTARG}
			;;
		p)
			conn_port=${OPTARG}
			;;
		r)
			reboot=true
			;;
		s)
			save_config=true
			;;
		h)
			helpme
			;;
		*)
			echo "other"
			usage
			exit 0
			;;
	esac
done
#shift $(($OPTIND - 1))

IP=${@:$OPTIND:1} # Assign positional parameter to IP

# If there is no IP or host provided, exit displaying usage
if [ -z "$IP" ]; then echo "No IP address provided"; usage; fi

# check if port should be changed
if [ "$new_port" -ne 0 ]; then
			echo "Changing default port to $new_port..."
      conn_port=$new_port
			f_change_port
fi

if [ "$snmp_disable" == true ]; then
			echo "Disabling SNMP..."
			f_snmp_disable
fi
		
if [[  -n "$snmp_read"  &&   -n "$snmp_write" ]]; then
			echo "Setting up new SNMP community strings..."
			f_snmp_get
			f_snmp_set
fi

# save configuration if required
if [ "$save_config" == true ]; then
			echo "Saving configuration..."
			f_save_config
			sleep 3
fi
# reboot if need be
if [ "$reboot" == true ]; then
			echo "Rebooting..."
			f_reboot
fi

