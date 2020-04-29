#!/bin/bash
output="$PWD/dat"
exe=ls

function usage()
{
  echo
  echo "Usage: $0 [ -p pid ] [cp1 [cp2]]"
  echo
  echo "  cp1 : use this checkpoint to compare against current"
  echo "  cp1 and cp2 : use history and compare"
  echo
  exit 1
}

function exists()
{
  if [ ! -f "$1" ]; then
    echo "No checkpoint file ($1)"
    exit
  fi
}

while [ "$1" != "" ]; do
  if [ "$1" == -p ]; then
    shift
    pid=$1
    exe="binary-$pid"
  else
    if [ "$cp1" == "" ]; then
      cp1=$1
    else if [ "$cp2" == "" ]; then
      cp2=$1
    else
      echo "-> Spurious arg ($1)"
      usage
    fi fi
  fi
  shift
done

[ "$pid" == "" ] && pid=$(pidof $exe)
[ "$pid" == "" ] && echo "No pid" && exit 1

if [ "$cp1" != "" -a "$cp2" != "" ]; then
  f1="$output/mem-$pid-$cp1"
  f2="$output/mem-$pid-$cp2"
  exists "$f1"
  exists "$f2"
  vimdiff "$f1" "$f2"
  exit 0
fi

mkdir -p "$output"
for i in {0..99}; do
  file="$output/mem-$pid-$i"
  echo "file=$file"
  if [ -f "$file" ]; then
    prevfile="$file"
  else
    memfile="$file"
    break
  fi
done

if [ "$cp1" != "" ]; then
  prevfile="$output/mem-$pid-$cp1"
  exists "$prevfile"
fi
echo "memfile $memfile"
echo "prvfile $prevfile"
echo "Pid : $pid ($exe)" >> "$memfile"
echo "Date: `date`" >> "$memfile"
cat /proc/$pid/smaps >> "$memfile"
echo "---" >> "$memfile"
cat /proc/$pid/maps >> "$memfile"
if [ "$prevfile" != "" ]; then
  diff "$prevfile" "$memfile" > /dev/null
  if [ "$res" != "0" ]; then
    echo vimdiff "$prevfile" "$memfile"
    vimdiff "$prevfile" "$memfile"
  fi
fi

