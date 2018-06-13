#!/bin/bash

# ZenityWattMan (c) 2018 by crt0mega

#ToDo: Enumerate render devices with sysfs
########################################################################

#Depending on the workloads, user can echo "0/1/2/3/4"
#pp_power_profile_mode to select 
#3D_FULL_SCREEN/POWER_SAVING/VIDEO/VR/COMPUTE mode. 
#
#echo "5 * * * * * * * *" pp_power_profile_mode to config custom mode.
#"5 * * * * * * * *" mean "CUSTOM enable_sclk SCLK_UP_HYST
#SCLK_DOWN_HYST SCLK_ACTIVE_LEVEL enable_mclk MCLK_UP_HYST
#MCLK_DOWN_HYST MCLK_ACTIVE_LEVEL"

if [ "$(id -u)" != "0" ]; then
  pkexec $0
fi

CARD="card0"
ENABLERPATH="/sys/class/drm/$CARD/device/power_dpm_force_performance_level"
WATTPATH="/sys/class/drm/$CARD/device/pp_power_profile_mode"
CURRENTMODE="$(cat $WATTPATH|grep -e "*"|tr -s ' '|cut -d ' ' -f 2)"
CUSTOMMODE="$(cat $WATTPATH|grep -e "CUSTOM"|tr -s ' '|cut -d ' ' -f 2)"
echo $CURRENTMODE
# NUM MODE_NAME BUSY_SET_POINT FPS USE_RLC_BUSY MIN_ACTIVE_LEVEL

RESP="$(tail -n+2 $WATTPATH | tr -d ':' | \
awk '{ print $1"\n"$2"\n"$3"\n"$4"\n"$5"\n"$6 }' | \
zenity --list --column "#" --column "Mode Name" \
 --column "Busy Set Point" --column "FPS" \
 --column "Use RLC Busy" --column "Min Active Level"\
 --title="ZenityWattMan"  --width 640 --text "Pick a mode")"

if [ $RESP == $CUSTOMMODE ]; then
# ToDo: Custom mode support
########################################################################
	zenity --error --title "ZenityWattMan" --text \
	 "Custom mode not supported yet!" --width 320
	exit
fi

if [ -z $RESP ]; then
	exit
else
	echo "manual" > $ENABLERPATH
	echo $RESP > $WATTPATH
fi

