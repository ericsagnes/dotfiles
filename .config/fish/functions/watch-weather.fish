function watch-weather
  while true; clear; date; curl -s -4 http://wttr\.in  | head -n 7; echo; sleep 1800; end
end
