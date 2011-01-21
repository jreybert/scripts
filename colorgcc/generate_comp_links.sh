#!/bin/bash

#color="/usr/bin/colorgcc"
color="./color_cc.py"


if test "$1" = "clean" ; then
  echo $1
  rm -f gcc* g++* cpp* c++* cc* nvcc icc icpc gfortran* mpic* mpif*;
  exit;
fi

rm -f gcc* g++* cpp* c++* cc* nvcc icc icpc gfortran* mpic* mpif*

ln -s $color cc
ln -s $color c++

ln -s $color nvcc

ln -s $color icc
ln -s $color icpc

for i in $( ls /usr/bin/gfortran* | cut -d '/' -f4); do
  ln -s $color $i
done

for i in $( ls /usr/bin/mpic* | cut -d '/' -f4); do
  ln -s $color $i
done

for i in $( ls /usr/bin/mpif* | cut -d '/' -f4); do
  ln -s $color $i
done

for i in $( ls /usr/bin/gcc* | cut -d '/' -f4); do
  ln -s $color $i
done

for i in $( ls /usr/bin/g++* | cut -d '/' -f4); do
  ln -s $color $i
done

for i in $( ls /usr/bin/cpp* | cut -d '/' -f4); do
  ln -s $color $i
done
