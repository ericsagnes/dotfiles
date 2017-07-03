# resolution 75|100|200|300|600|1200
function scan
  scanimage -d 'hpaio:/net/ENVY_5530_series?ip=192.168.11.99' -p --mode Color --resolution $argv[1]
end
