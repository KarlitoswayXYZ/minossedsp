#!/bin/bash

VUSER="volumio"
VGROUP="volumio"

MDSP_BF_CONF="/tmp/mdsp-bf-conf.json"
MDSP_BF_DIRS="/data/INTERNAL/minossedsp/mdsp-sys-dirs.sh"

### Load required parameters
bf_client_connection=$(/bin/cat "$MDSP_BF_CONF" | /usr/bin/jq -r '.bf_client_connection')

### Load folder and file locations
. "$MDSP_BF_DIRS"

COUNT=0
ATTEMPTS=20
while [[ $COUNT -le $ATTEMPTS ]]
do
	if [[ -S "$bf_client_connection" ]]
	then
		/bin/chown "$VUSER":"$VGROUP" "$bf_client_connection"
		
		### Add Brutefir processes to CPU shield
		NCPU=$(( $(/usr/bin/nproc --all)-1 ))
		if [ $NCPU -gt 0 ]
		then
			NBRU=$(/bin/pidof -x brutefir | /bin/sed 's/ /,/g')
			/usr/bin/cset shield -s -p $NBRU
			NBRE=$(/bin/pidof -x brutefir.real | /bin/sed 's/ /,/g')
			/usr/bin/cset shield -s -p $NBRE
		fi
		
		exit 0
		#break
		
	fi
	(( COUNT++ ))
	/bin/sleep 0.5
done

exit 1
