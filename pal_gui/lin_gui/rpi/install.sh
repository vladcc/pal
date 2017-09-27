#!/bin/bash

HOME_BIN=$HOME"/bin"
PAL_ONLY=".pal_gui"
PAL_FULL=$HOME_BIN"/"$PAL_ONLY
LIB="libpallib.so"
PAL_PY="pal.py"
RUN_PAL="pal"

SHBNG="#!/bin/bash"
RUN_CMD="python ./"$PAL_PY" & disown %-"

mkdir -p $PAL_FULL;
cp $PAL_PY $PAL_FULL"/";
cp $LIB $PAL_FULL"/";
cd $PAL_FULL;
chmod +x $LIB;
chmod +x $PAL_PY;
cd ..;
echo -e $SHBNG"\ncd "$PAL_FULL"\n"$RUN_CMD > $RUN_PAL;
chmod +x $RUN_PAL;