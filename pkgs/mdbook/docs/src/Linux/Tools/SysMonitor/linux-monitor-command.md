# Linux Command for System Administrator  

## Basic command for system monitoring

1. `sudo du -a / | sort -n -r | head -n 20` \# list disk usage
2. `journalctl | grep "error"` \# log messages, kernel messages, and other system-related information
3. `dmesg --ctime | grep error` \# Show kernel ring buffer
4. `sudo journalctl -p 3 -xb` \# Check the lock file
5. `sudo systemctl --failed` \# Service that failed to load
6. `du -sh .config` \# File size of a specific directory
7. `find . -type f -exec grep -l "/dev/nvme0n1" {} +` \# find file and exce command with grep, {} is the output for each & +,\\; is the terminator

## Reset password (for forgotten password)
Reser Root 
1. `init=/bin/bash` \# from grub commnad mode, find the kernel line containing linux then add at the end of linux command
2. `ctrl+x` or `F10` \# to save the changes and boot 
3. `mount -o remount,rw /` \# mount the root system for (r,w)
4. `passwd` # change the password 
5. `reboot -f` \# force reboot, after that you can boot with new passwd you set

Reser User 
1. `rw init=/bin/bash` \# from grub commnad mode, find the kernel line containing linux then add at the end of linux command
2. `ctrl+x` or `F10` \# to save the changes and boot 
3. `passwd username` # change the password 
4. `reboot -f` \# force reboot, after that you can boot with new passwd you set


## Some useful Command
1. `grep -Irl "akib" .` \# this will find file contain akib in the current dir
2. `grep -A 3 -B 3 "nvme" flake.nix` \# this will find nvme in flake.nix file with before and after with 3,3 line
3. `sed -i "s/akib/withNewText/g" file.txt` \# sed will changes the all occurance with new text in a file
4. `cat /etc/passwd | column -t -s ":" -N USERNAME,PW,UID,GUID,COMMENT,HOME,INTERPRETER -J -n passwdFile` \# will seperate passwd file based on ":" delemeter and show as column format then the "-J" flag will convert it into json file
5. `cat /etc/passwd | awk -F: 'BEGIN {printf "user\tPW\tUID\tGUID\tCOMMENT\tHOME\tINTERPRETER\n"} {printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5, $6, $7}'`
6. `cat /etc/passwd | column -t -s ":" -N USERNAME,PW,UID,GUID,COMMENT,HOME,INTERPRETER -H PW -O UID,USERNAME,GUID,COMMENT,HOME,INTERPRETER` \# "-H" remove specific column "-O" reorder column
