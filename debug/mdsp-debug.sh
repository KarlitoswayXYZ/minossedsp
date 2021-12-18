#!/bin/bash

MDSP_BF_CONF="/tmp/mdsp-bf-conf.json"
MDSP_BF_DIRS="/data/INTERNAL/minossedsp/mdsp-sys-dirs.sh"

### Load folder and file locations
. "$MDSP_BF_DIRS"

_pstree(){
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "==================================== PSTREE ====================================="
	/bin/echo "================================================================================="
	/usr/bin/pstree -p | /bin/grep -E "mdsp-|mpdclient|gdbus|minosse"
	/bin/echo "................................................................................."
}

_ps(){
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "====================================== PS ======================================="
	/bin/echo "================================================================================="
	/bin/ps aux | /bin/grep -E "mdsp-|mpdclient|gdbus|minosse"
	/bin/echo "................................................................................."
}

_journalctl(){
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "================================== JOURNALCTL ==================================="
	/bin/echo "================================================================================="
	#/bin/journalctl | /bin/grep -B 1 -A 1 -E -i "minosse|mdsp-"
	/bin/journalctl | /bin/grep -E -i "minosse|mdsp-"
	/bin/echo "................................................................................."
}

_minosse_persistence(){
	
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "============================ MINOSSE DSP DATA FILE =============================="
	/bin/echo "================================================================================="
	/usr/bin/jq '.' "$MDSP_BF_CONF"
	/bin/echo "................................................................................."
}

_eq_preset(){
	
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "================================= EQ PRESETS ===================================="
	/bin/echo "================================================================================="
	/usr/bin/jq '.' "$coefficient_folder"eq10-preset.json
	/bin/echo "................................................................................."
}

_cpushield(){
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "============================== CPU SHIELD STATUS ================================"
	/bin/echo "================================================================================="
	NCPU=$(( $(/usr/bin/nproc --all)-1 ))
	if [ $NCPU -gt 0 ]
	then
		/usr/bin/cset shield
		echo ""
		/usr/bin/cset shield --shield -v
	else
		/bin/echo "Single CPU core detected, CPU shield not activable."
	fi
}

_brutefir(){
	
	DIRNAME="/data/INTERNAL/minosse/"
	
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "======================= BRUTEFIR STATUS AND CONFIGURATION ======================="
	/bin/echo "================================================================================="
	/bin/systemctl status mdsp-bf.service
	/bin/echo "................................................................................."
	/bin/cat "$brutefir_conf_file"
	/bin/echo "................................................................................."
	mdsp-bf-cmd.sh "lf"
	mdsp-bf-cmd.sh "lc"
	mdsp-bf-cmd.sh "li"
	mdsp-bf-cmd.sh "lo"
	/bin/echo "................................................................................."
}

_mpd(){
	/bin/echo ""
	/bin/echo "================================================================================="
	/bin/echo "====================== CORE LOOP STATUS AND CONFIGURATION ======================="
	/bin/echo "================================================================================="
	/bin/systemctl status mdsp-core.service
}

_journalctl
_pstree
_ps
_minosse_persistence
_eq_preset
_cpushield
_mpd
_brutefir

