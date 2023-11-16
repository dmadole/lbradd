#!/bin/sh

if [ $# -lt 2 ]
then
  echo "usage: lbradd output input ..."
  exit 0
fi

lbr="$1"
shift

result=0

while [ -n "$1" ]
do
  if [ ! -f "$1" ]
  then
    echo "$1 not found or not regular file, skipping..." >&2
    result=1
  else

    name="${1##*/}"
    name="${name%.bin}"

    if [ -z "${name%%*[!.0-9A-Za-z_]*}" ]
    then
      echo "$1 has illegal Elf/OS filename, skipping..." >&2
      result=1
    else

      size=`stat -c %s "$1"`

      test -n "${1%%*.bin}"
      flag="$?"

      echo "adding $name $flag $size"

      size=`printf '\\%o\\%o\\%o\\%o' \
              $(($size/256/256/256)) \
              $(($size/256/256%256)) \
              $(($size/256%256)) \
              $(($size%256))`

      printf "%s\\0\\$flag$size" "$name" >> "$lbr"
      cat "$1" >> "$lbr"

    fi
  fi

  shift
done

exit $result

