#!/bin/sh

echo "**** Child $$ starting: y to debug"
read input
if [ "$input" = "y" ] ; then
  gdb --args $*
else
  $*
fi
