#!/bin/sh

if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` gcc_version"
  exit 1
fi

new_version=$1
dir="/usr/bin"

if [ ! -e $dir/gcc-$new_version ]; then
  echo "gcc-$new_version does not exists!"
  exit 1
fi

if [ ! -e $dir/g++-$new_version ]; then
  echo "g++-$new_version does not exists!"
  exit 1
fi

if [ "$(whoami)" != "root" ]; then
  echo "This script needs root privileges";
  exit 1
fi

rm /usr/bin/gcc
ln -s /usr/bin/gcc-$new_version /usr/bin/gcc

rm /usr/bin/g++
ln -s /usr/bin/g++-$new_version /usr/bin/g++
