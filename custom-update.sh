#!/bin/bash -e

### Load folder and file locations
MDSP_BF_DIRS="/data/plugins/audio_interface/minossedsp/conf/mdsp-sys-dirs.sh"
. "$MDSP_BF_DIRS"

IDSTR="MinosseDSP::custom-update.sh: "
LOCKDIR='/var/lock/mdsp-custom-update-lock'

VUSER="volumio"
VGROUP="volumio"

trap '/usr/bin/sudo /bin/rm -v -r -f "$LOCKDIR"' EXIT

_cleanup() {
	
	set +e
	
	echo "========== Erasing installation files... =========="
	#/usr/bin/sudo /bin/rm -r -f "$PWD"*
	#/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"bin
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"brutefir
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"conf
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"img
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"core
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"debug
	#/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"gui
	
	### Unwanted Git and Eclipse folders
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"*git
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"*project
	/usr/bin/sudo /bin/rm -r -f "$minosse_plugin_folder"*settings

}

_deps() {
	
	# If you need to differentiate install for armhf and i386 you can get the variable like this
	#DPKG_ARCH=`dpkg --print-architecture`
	# Then use it to differentiate your install
	
	/bin/echo "$IDSTR""============ Installing Minosse dependencies... ============"
	/usr/bin/sudo apt-get update
	# Install the required packages via apt-get
	/usr/bin/sudo apt-get -y install  --no-install-recommends
	
}

_copy() {
	
	/bin/echo "$IDSTR""============ Copying files... ============"
	
	### Copy core commands
	/usr/bin/sudo cp -f "$minosse_plugin_folder"brutefir/mdsp-*.sh "$minosse_bin_folder"
	/usr/bin/sudo cp -f "$minosse_plugin_folder"core/mdsp-*.sh "$minosse_bin_folder"
	/usr/bin/sudo cp -f "$minosse_plugin_folder"core/mdsp-*.js "$minosse_bin_folder"
	/usr/bin/sudo cp -f "$minosse_plugin_folder"core/mdsp-*.pl "$minosse_bin_folder"
	/usr/bin/sudo cp -f "$minosse_plugin_folder"debug/mdsp-*.sh "$minosse_bin_folder"
	/usr/bin/sudo chmod +x "$minosse_bin_folder"mdsp-* > /dev/null 2>&1
	
	### mdsp-bf.service as a system service
	/usr/bin/sudo cp -f "$minosse_plugin_folder"brutefir/mdsp-*.service /etc/systemd/system/
	### mdsp-mpd.service as a system service
	/usr/bin/sudo cp -f "$minosse_plugin_folder"core/mdsp-*.service /etc/systemd/system/
	
	### Copy configuration files
	/usr/bin/sudo cp -r -f "$minosse_plugin_folder"img/ "$minosse_data_folder"
	/usr/bin/sudo cp -f "$minosse_plugin_folder"conf/mdsp-* "$minosse_data_folder"
	/usr/bin/sudo cp -f "$minosse_plugin_folder"conf/override.conf "$minosse_data_folder"
	/usr/bin/sudo chown -R "$VUSER":"$VGROUP" "$minosse_data_folder" > /dev/null 2>&1
		
}

if /bin/mkdir "$LOCKDIR"
then
	
	CTMPL='/data/INTERNAL/minossedsp/mdsp-bf-conf.json.tmpl'
	current_version=$(/bin/cat "$CTMPL" | /usr/bin/jq -r '.current_version')
	MVER=$(/usr/bin/jq '.version' /data/plugins/audio_interface/minossedsp/package.json | /bin/sed 's#"##g')
	if $(/usr/bin/dpkg --compare-versions "$MVER" "gt" "$current_version")
	then
		#_deps
		_copy
		_cleanup
		RETVAL="$(/usr/bin/jq '.current_version = "'"$MVER"'"' "$CTMPL")" && echo "${RETVAL}" > "$CTMPL"
		/bin/echo '{"event":"pushmsg","data":{"type":"warning","content":"UPDATE_REBOOT","extra":""}}' > "$core_fifo"
	else
		/bin/sleep 10
	fi
	
fi
