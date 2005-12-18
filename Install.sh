#!/bin/bash
# Install.sh - TIGCC binary installation wizard
#
# Copyright (C) 2004-2005 Kevin Kofler
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

# Try to find a suitable dialog program
if [ -z "$DIALOG" ]
then xdpyinfo >/dev/null 2>/dev/null && { type kdialog >/dev/null 2>/dev/null && export DIALOG=kdialog || { type xdialog >/dev/null 2>/dev/null && export DIALOG=xdialog || { type gdialog >/dev/null 2>/dev/null && export DIALOG=gdialog || { type cdialog >/dev/null 2>/dev/null && export DIALOG=cdialog || { type dialog >/dev/null 2>/dev/null && export DIALOG=dialog || { export DIALOG=none; }; }; }; }; }; } || { type cdialog >/dev/null 2>/dev/null && export DIALOG=cdialog || { type dialog >/dev/null 2>/dev/null && export DIALOG=dialog || { export DIALOG=none; }; }; }
fi

# If we don't have a dialog program, present a simple bash interface
if [ "$DIALOG" = none ]
then

echo "TIGCC Installation Wizard"
if [ -z "$TIGCC" ]
then TIGCC="/usr/local/tigcc"
fi
echo -n "Destination directory ($TIGCC): "
read TIGCCnew
if [ ! -z "$TIGCCnew" ]
then TIGCC="$TIGCCnew"
fi
export TIGCC

# Get current PWD.
OLDPWD="`pwd`"

# Unpack the binaries to the destination directory
mkdir $TIGCC
cd $TIGCC
tar -x -j --no-same-owner --same-permissions -f "$OLDPWD/tigcc_bin.tar.bz2"

# Now offer to install environment variables
echo -n "Add environment settings (\$TIGCC, \$PATH) to bashrc [Y/n]? "
read -n 1 AddEnvSettings
echo
if [ -z "$AddEnvSettings" -o "$AddEnvSettings" = y -o "$AddEnvSettings" = Y ]
then { $TIGCC/bin/envreg; echo "Done. You must restart bash for the new environment settings to take effect."; exit 0; }
fi

echo "Done. Make sure you set \$TIGCC to \"$TIGCC\" and add \$TIGCC/bin to your \$PATH before using TIGCC."
exit 0
fi

# cdialog and xdialog output to stderr by default.
if [ "$DIALOG" = dialog -o "$DIALOG" = cdialog -o "$DIALOG" = xdialog ]
then DIALOG="$DIALOG --stdout"
fi

# Now this is stupid. dialog REQUIRES size parameters (which can be "0 0" for
# auto-sizing). kdialog does NOT like them.
if [ "$DIALOG" = kdialog ]
then DLGSIZE=""
else DLGSIZE="0 0"
fi

# Now this is just as stupid. Zenity's gdialog script does NOT allow --,
# everything else REQUIRES it for strings starting with a dash. It is also
# broken with respect to escaping.
if [ -z "`$DIALOG --version | grep zenity`" ]
then DASHDASH="--";BACKSLASH=""
else DASHDASH="";BACKSLASH="\\"
fi

if [ -z "$TIGCC" ]
then TIGCC="/usr/local/tigcc"
fi
TIGCC="`$DIALOG --title "TIGCC Installation Wizard" --inputbox "Destination directory:" $DLGSIZE $DASHDASH "$TIGCC"`"
if [ $? != 0 ]
then { echo Install.sh: Canceled by user; exit 1; }
fi
export TIGCC

# Get current PWD.
OLDPWD="`pwd`"

# Unpack the binaries to the destination directory
mkdir $TIGCC
cd $TIGCC
tar -x -j --no-same-owner --same-permissions -f "$OLDPWD/tigcc_bin.tar.bz2"

# Now offer to install environment variables
$DIALOG --title "TIGCC Installation Wizard" --yesno "Add environment settings ($BACKSLASH\$TIGCC, $BACKSLASH\$PATH) to bashrc?" $DLGSIZE && { $TIGCC/bin/envreg; $DIALOG --title "TIGCC Installation Wizard" --msgbox "Done. You must restart bash for the new environment settings to take effect." $DLGSIZE; exit 0; }

$DIALOG --title "TIGCC Installation Wizard" --msgbox "Done. Make sure you set $BACKSLASH\$TIGCC to $BACKSLASH\"$TIGCC$BACKSLASH\" and add $BACKSLASH\$TIGCC/bin to your $BACKSLASH\$PATH before using TIGCC." $DLGSIZE
