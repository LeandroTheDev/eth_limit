#!/bin/sh

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <port> <limit>"
    echo "Example: $0 27000 500kbps"
    exit 1
fi

PORT=$1
LIMIT=$2

# Get default network interface
IFACE=$(ip route show default | awk 'NR==1 {print $5}')

echo "Applying bandwidth limit on interface $IFACE for port $PORT with limit $LIMIT..."

# Clear previous rules
tc qdisc del dev "$IFACE" root 2>/dev/null

# Create root qdisc
tc qdisc add dev "$IFACE" root handle 1: htb default 10

# Create limited class
tc class add dev "$IFACE" parent 1: classid 1:10 htb rate "$LIMIT"

# Filter outgoing traffic for the specified port
tc filter add dev "$IFACE" protocol ip parent 1: prio 1 u32 \
    match ip dport "$PORT" 0xffff flowid 1:10
