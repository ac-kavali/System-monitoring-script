#!/bin/bash

# ARCH
arch=$(uname -a)

# CPU PHYSICAL
cpuf=$(grep "physical id" /proc/cpuinfo | sort -u | wc -l)

# CPU VIRTUAL
cpuv=$(grep -c "processor" /proc/cpuinfo)

# RAM
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_percent=$(awk "BEGIN {printf \"%.2f\", ($ram_use/$ram_total)*100}")

# DISK
disk_total=$(df -m | grep "^/dev/" | grep -v "/boot" | awk '{t+=$2} END {printf "%.1f", t/1024}')
disk_use=$(df -m | grep "^/dev/" | grep -v "/boot" | awk '{u+=$3} END {printf "%.1f", u/1024}')
disk_percent=$(df -m | grep "^/dev/" | grep -v "/boot" | awk '{u+=$3; t+=$2} END {printf "%d", (u/t)*100}')

# CPU LOAD
idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
cpu_fin=$(awk "BEGIN {printf \"%.1f\", 100 - $idle}")

# LAST BOOT
lb=$(who -b | awk '$1=="system" {print $3 " " $4}')

# LVM USE
lvmu=$(if lsblk | grep -q "lvm"; then echo "yes"; else echo "no"; fi)

# TCP CONNECTIONS
tcpc=$(ss -ta | grep -c ESTAB)

# USER LOG
ulog=$(users | wc -w)

# NETWORK
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# SUDO
cmnd=$(journalctl _COMM=sudo 2>/dev/null | grep -c COMMAND)

wall "Architecture: $arch
CPU physical: $cpuf
vCPU: $cpuv
Memory Usage: ${ram_use}MB/${ram_total}MB (${ram_percent}%)
Disk Usage: ${disk_use}GB/${disk_total}GB (${disk_percent}%)
CPU load: ${cpu_fin}%
Last boot: $lb
LVM use: $lvmu
Connections TCP: $tcpc ESTABLISHED
User log: $ulog
Network: IP $ip ($mac)
Sudo: $cmnd cmd"
