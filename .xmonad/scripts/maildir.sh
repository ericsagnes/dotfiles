#! /usr/bin/env bash

unread=$(find ~/.mail/$1 -type f -regextype sed -regex ".*,$" | wc -l)
flags=$(find ~/.mail/$1 -type f -regextype sed -regex ".*,[PRSTD]*F[PRSTD]*$" | wc -l)
if [ "$unread" -gt 10 ]; then color="red"
elif [ "$unread" -gt 5 ]; then color="orange"
else color="gray"
fi
if [ "$flags" -gt 0 ]; then fl="(<fc=orange>$flags</fc>)"
else fl=""
fi
printf "<fc=%s>%s</fc>%s" "$color" "$unread" "$fl" 
