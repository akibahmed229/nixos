#### we need to setup into two part
- client side configuration
- server side configuration

#### Server Side Configuration: -
- To install nfs package 
	`sudo apt install nfs-utils libnfsidmap`
- Enable and start nfs service
	`sudo systemctl enable rpcbind, nfs-server`
	`sudo systemctl start rpcbind, nfs-server, rpc-statd, nfs-idmap`
- Create a directory for nfs and give all the permission 
  `mkdir -p $HOME/Desktop/NFS-Share`
  `sudo chmod 777 ~/Desktop/NFS-Share`
- Modify the /etc/exports file and add new shared filesystem 
	`/location <IP_allow>(rw,sync,no_root_squash)`
	`exportfs -rv`

#### Client Side Configuration:-
- To install nfs package
	`sudo apt install nfs-utils rpcbind`
- Enable and start the rpcbind service
	`sudo systemctl start rpcbind`
- To stop the firewall
	`sudo systemctl stop firewall / iptable`
- show mount from nfs server
	`showmount -e  <IP of server side>`
- Create a mount point (directory)
	`mkdir -p /mnt/share`
- Mount the NFS file system 
	`mount <IP_server>:/location /mnt/share`