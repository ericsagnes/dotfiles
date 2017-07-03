#! /usr/bin/env bash

unread=$(sqlite3 ~/.newsbeuter/cache.db 'select count(*) from rss_item where unread = 1;')
if [ "$unread" -gt 50 ]; then color="red"
elif [ "$unread" -gt 15 ]; then color="orange"
else color="gray"
fi
printf "<fc=%s>%s</fc>" "$color" "$unread" 
