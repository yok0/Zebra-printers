# Zebra printers
 Change SNMP via command line.
 
# Usage

Usage: $0 [-RW -D -P -p -s -r -h] <IP or hostname>"

-R 'string'	Read/get coommunity string
-W 'string'	Write/set community string
-D		Disable SNMP
-P port		Change printer current port to "port"
-p port		Connect on "port". If not specified defaults to: 5964
-s		Save the current configuration
-r		Reboot the printer [ all printers ]
-h 		Displays this help message

! Put SNMP community strings in single quotes - 'comunity_string'

# Examples:

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
 
