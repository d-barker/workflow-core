#!/usr/bin/env bash

#!/bin/bash

for i in `find ../. -name '*.cs'` # or whatever other pattern...
do
  echo $i
  if ! grep -q Copyright $i
  then
    filename="${i##*/}"
    base="${filename%.[^.]*}"
    ext="${filename:${#base} + 1}"                
    sed s/{{file}}/$base.$ext/ < copyright.txt > copyright.new
    cat copyright.new $i >$i.new && mv $i.new $i
  fi
done
