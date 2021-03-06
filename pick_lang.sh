#!/usr/bin/env bash

# picks a random programming language and updates variables-list _in-file_

LANGUAGES=(perl d fortran nim cobol racket)
DONE=(go ruby scala elixir rust swift haskell dart c++ elm haxe kotlin pascal erlang assembly php javascript bash python)

if [ ${#LANGUAGES[@]} -eq 0 ]; then
  echo "no more languages to pick from" && exit 1
fi

SELF=`basename "$0"`
NEXT=${LANGUAGES[RANDOM%${#LANGUAGES[@]}]}
sed -i -e "0,/LANGUAGES=/s/${NEXT}//g" ${SELF}
sed -i -e "1,/DONE=/s/DONE=(/DONE=(${NEXT} /g" ${SELF}

echo "todays language: ${NEXT}"
