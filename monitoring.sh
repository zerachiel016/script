ASCII="    ▄███▌█████▌█░████████▐▀█▄
  ▄█████░█████▌░█░▀██████▌█▄▄▀▄        _____________
  ▌███▌█░▐███▌▌░░▄▄░▌█▌███▐███░▀     /               \\
 ▐ ▐██░░▄▄▐▀█░░░▐▄█▀▌█▐███▐█         | Arch > Debian  |
   ███░▌▄█▌░░▀░░▀██░░▀██████▌         \______________/
    ▀█▌▀██▀░▄░░░░░░░░░███▐███       /
     ██▌░░░░░░░░░░░░░▐███████▌     /
     ███░░░░░▀█▀░░░░░▐██▐███▀▌
     ▌█▌█▄░░░░░░░░░▄▄████▀░▀
       █▀██▄▄▄░▄▄▀▀▒█▀█░
\n"

# Data Initialization
t1=$(awk 'NR==1 {total=($2+$3+$4+$5+$6+$7+$8+$9)} {idle=($5+$6)} END {print(total, idle)}' </proc/stat)
sleep 2s
t2=$(awk 'NR==1 {total=($2+$3+$4+$5+$6+$7+$8+$9)} {idle=($5+$6)} END {print(total, idle)}' </proc/stat)
d_total=$(echo $t2 $t1 | awk '{print ($1 - $3)}')
d_idle=$(echo $t2 $t1 | awk '{print ($2 - $4)}')

# Final general layout
output+=$ASCII
output+="#Architecture: $(uname -a)"
output+="\n#CPU physical : $(grep '^cpu cores' /proc/cpuinfo | uniq | awk '{print $NF}')"
output+="\n#vCPU : $(nproc --all)"
output+="\n#Memory Usage: $(awk 'NR==1 {total=int($2 / 1024)} NR==2 {free=int($2 / 1024)} {used=total-free} END \
    {print used"/"total"MB ("sprintf("%.2f", used*100/total)"%)"}' </proc/meminfo)"
output+="\n#Disk usage: $(df -t ext4 --output=used,size,pcent --total | awk 'END {printf "%.2f/%.2fGb (%s)", $1/(1024^2), $2/(1024^2), $3}')"
output+="\n#CPU load: $(echo $d_total $d_idle | awk '{print sprintf("%.1f", ($1 - $2) / $1 * 100)}')%"
output+="\n#Last boot: $(uptime -s | cut -c1-16)"
output+="\n#LVM use: $(lsblk -o TYPE | grep -q lvm && echo yes || echo no)"
output+="\n#Connections TCP : $(ss -t | grep ESTAB | wc -l) ESTABLISHED"
output+="\n#User log: $(who | awk '{print $1}' | sort -u | wc -l)"
output+="\n#Network: IP $(hostname -I | awk '{print $1}') ($(ip link | grep "link/ether" | awk '{print $2}'))"
output+="\n#Sudo : $(journalctl -q _COMM=sudo | grep -c COMMAND=)"

echo -e "$output"
