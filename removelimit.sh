#/bin/sh
tc qdisc del dev $(ip route show default | awk 'NR==1 {print $5}') root