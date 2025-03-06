#!/usr/bin/env bash
# Declare color variables
RED="\033[0;31m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[0;33m"
CLEAR="\033[0m"

# Create function net array with nics
createnicsarray() {
	declare -a NETARRAY
	local NETARRAY=()

	for NIC in $(ls /sys/class/net)
	do
		NETARRAY+=("${NIC}")
	done
	echo "${NETARRAY[@]}"
	return 0
}

echo -e "${CYAN}Show nics with ipv4 addresses:${CLEAR}"

# Create function with nics and ipv4 addresses
createnicsipv4() {
	for NET in $(createnicsarray)
	do
		if [[ "${NET}" == "lo" ]]
		then
			continue
		fi

		if [[ -n "$(ip a show ${NET} | grep -Pw 'inet')" ]]
		then
			if [[ "$(ip a show ${NET} | grep -Pw 'inet' | sed -r 's/^\s+//g' | awk '{print $2}' | wc -l )" -gt 1 ]]
			then
				echo -e "${GREEN}${NET}:$(ip a show ${NET} | grep -Pw 'inet' | sed -r 's/^\s+//g' | awk '{print $2}' | paste -s -d ',')${CLEAR}"
			else
				echo -e "${GREEN}${NET}:$(ip a show ${NET} | grep -Pw 'inet' | sed -r 's/^\s+//g' | awk '{print $2}')${CLEAR}"
			fi
		else
			continue
		fi
	done
	return 0
}

# Show results nics with ipv4 or empty
if [[ -n "$(createnicsipv4)" ]]
then
	createnicsipv4
else
	echo -e "${YELLOW}No such nics!${CLEAR}"
fi

echo

echo -e "${CYAN}Show nics without ipv4 addresses:${CLEAR}"

# Create function with nics and without ipv4 addresses
createnicswithout() {
	for NET in $(createnicsarray)
	do
        	if [[ "${NET}" == "lo" ]]
        	then
                	continue
        	fi

        	if [[ -z "$(ip a show ${NET} | grep -Pw 'inet')" ]]
        	then
               		echo -e "${RED}${NET}:--not defined--${CLEAR}"
		else
			continue
		fi
	done
	return 0
}

# Show result nics without ipv4 or empty
if [[ -z "$(createnicswithout)" ]]
then
	echo -e "${YELLOW}No such nics!${CLEAR}"
else
	createnicswithout
fi

exit 0
