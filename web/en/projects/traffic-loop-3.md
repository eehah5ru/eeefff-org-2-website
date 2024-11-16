---
template: "templates/traffic-loop-layer-3.slim"
scheme: "/images/traffic-loop/sysadmin-scheme-ru.svg"
---

# Manual for Traffic Loop

## Requirements:

1. 130Gb of free space
2. More than 4Gb of RAM
4. It's better to have 2-core CPU or more

## Short description:


Landscape has three virtual machines running Centos7.5  
There are 2 network interfaces with enabled forwarding  on each server  
Traffic is looped on IP `192.168.50.10`  
TTL on IP IP `192.168.50.10` is set on 64 on each server  
`reverse path filter (rp_filter)` is disabled on each server  
Performance on my laptop is around 5800 packets per second.



## Setup on Windows:

1. Download and install [vagrant](https://www.vagrantup.com/downloads.html) (if not installed)
1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (if not installed)
2. Download and install [putty](https://www.chiark.greenend.org.uk/sgtatham/putty/latest.html)
3. Download [confic files of test landscape](https://github.com/eehah5ru/traffic-loop-landscape-routing/archive/master.zip).
3. Extract downloaded files.
4. Run `cmd` or `powershell` and go to folder that contains downloaded archive. Then go to `traffic-loop-landscape-routing-master` folder
5. run the landscape: `vagrant up`
6. Check ports that were set up for SSH on every vagrant server: `vagrant ssh-config`
7. Run `pageant` application (distributed with putty)
8. Click on the app icon in the system tray and seelct _"add key"_
9. In `traffic-loop-landscape-routing-master` select `id_rsa.ppk` file
10. Run  _putty_  and enter address `127.0.0.1`; in field "port" enter Port from the step 7 for *server1*; enter `vagrant` as username when needed
11. Do the same for *server2*
12. The same *server3*
13. Make a mutual pings on every server using paired network interfaces. It is needed to check that network is set up correctly as well as to exclude situation when virtualBox network sleeps until there is network activity. For example, if there is no ping from *server1* to `192.168.202.1` then it is neccesary to run `ping 192.168.202.1` on the *server1* and run `ping 192.168.202.2` on the *server3*. Wait for approx 10 seconds. Network should be awake.
14. Set up network monitoring on *server1* after checking network on every server: Когда все пинги есть на *server2* или *server3*: `sudo tcpdump -xx -XX -ni eth1 host 192.168.50.10`
15. Put one packet into traffic loop unsing on of the servers::	`ping -c 1 192.168.50.10`
16. Watch looped traffic using `tcpdump`: every line is one loop through the landscape
17. To stop traffic loop use following command on the *server1*: `sudo vagrant/routing.sh stop`
18. To start again: `sudo vagrant/routing.sh start`


## Setup on Mac OS or Linux:

1. Download and install [vagrant](https://www.vagrantup.com/downloads.html) (if not installed)
1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (if not installed)
2. Download and install [putty](https://www.chiark.greenend.org.uk/sgtatham/putty/latest.html)
3. Download [confic files of test landscape](https://github.com/eehah5ru/traffic-loop-landscape-routing/archive/master.zip).
3. Extract downloaded files.
4. Run Terminal and go to folder that contains downloaded archive. Then go to `traffic-loop-landscape-routing-master` folder
5. Run the landscape: `vagrant up`
10. Check *server1* is working: `vagrant ssh server1`
11. In new terminal window check *server2* is working: `vagrant ssh server2`
12. In another terminal window check *server3* is working: `vagrant ssh server3`
13. Make a mutual pings on every server using paired network interfaces. It is needed to check that network is set up correctly as well as to exclude situation when virtualBox network sleeps until there is network activity. For example, if there is no ping from *server1* to `192.168.202.1` then it is neccesary to run `ping 192.168.202.1` on the *server1* and run `ping 192.168.202.2` on the *server3*. Wait for approx 10 seconds. Network should be awake.
14. Set up network monitoring on *server1* after checking network on every server: Когда все пинги есть на *server2* или *server3*: `sudo tcpdump -xx -XX -ni eth1 host 192.168.50.10`
15. Put one packet into traffic loop unsing on of the servers::	`ping -c 1 192.168.50.10`
16. Watch looped traffic using `tcpdump`: every line is one loop through the landscape
17. To stop traffic loop use following command on the *server1*: `~sudo vagrant/routing.sh stop`
18. To start again: `sudo ~vagrant/routing.sh start`
