ASCII="
    ▄███▌█████▌█░████████▐▀█▄
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

# Final general layout
output+=$ASCII
output+="#Architecture: $(uname -a)"
output+="\n#CPU physical : $(lscpu | grep 'Sock' | awk '{print $2}')"
output+="\n#vCPU : $(nproc --all)"
output+="\n#Memory Usage: $(awk 'NR==1 {total=int($2 / 1024)} NR==2 {free=int($2 / 1024)} {used=total-free} END \
    {print used"/"total"MB ("sprintf("%.2f", used*100/total)"%)"}' </proc/meminfo)"
output+="\n#Disk usage: $(df -t ext4 --output=used,size,pcent --total | awk 'END {printf "%.2f/%.2fGb (%s)", $1/(1024^2), $2/(1024^2), $3}')"
output+="\n#CPU load: $(vmstat 1 2 | tail -1 | awk '{printf("%.1f%%", 100 - $15)}')%"
output+="\n#Last boot: $(uptime -s | cut -c1-16)"
output+="\n#LVM use: $(lsblk -o TYPE | grep -q lvm && echo yes || echo no)"
output+="\n#Connections TCP : $(ss -t | grep ESTAB | wc -l) ESTABLISHED"
output+="\n#User log: $(who | awk '{print $1}' | sort -u | wc -l)"
output+="\n#Network: IP $(hostname -I | awk '{print $1}') ($(ip link | grep "link/ether" | awk '{print $2}'))"
output+="\n#Sudo : $(journalctl -q _COMM=sudo | grep -c COMMAND=) cmd"

echo -e "$output" | wall
