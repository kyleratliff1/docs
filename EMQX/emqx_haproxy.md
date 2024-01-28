# EMQX HAProxy Main Content Steps
Ensure that there exist a functional EMQX Cluster before creating the HAProxy Load Balancers.
HAProxy is a software package that can be installed on Linux flavored operating systems which 
in turn allows the OS to act as a reverse proxy and load balancer.  

> **Reverse Proxy** - sits in front of your server and accepts request from clients on its behalf.   
> **Load Balancer** - will split incoming requests among a cluster of servers, keeps track of which server got the 
                      last request, and the server that should get the next request utilizing the cluster equally. 
___
1. Access the Proxmox hypervisor web interface using a web browser and enter the following url in the specified format:  
    [https://Your-Servers-IP-Address:8006/ ](https://Your-Servers-IP-Address:8006/)
2. If a base haproxy template (**base-haproxy-template**) is available see the
   [MariaDB HAProxy Server Node Setup](#Mariadb-haproxy-server-node-setup) section, if not continue to **step 3** in **this section**:
3. If a base ubuntu template (**base-ubuntu-template**) is available see the **haproxy_template** document then return 
   to **this document** and jump to **step 2** in **this section**, if not continue in **this section** to **step 4**.
4. If no base Ubuntu template is available then see the **base-ubuntu build sheet** document which should be located 
   under the **scada** share on the research **NAS**, then return to **this section** and jump to **step 3**.
5. Steps Complete. 

## EMQX HAProxy Server Node Setup
___
1. Perform a full clone of base haproxy template (**base-haproxy-template**) by right-clicking and then set the following 
   settings below:  

   > Mode = Full Clone  
   > Target Storage = Same as source  
   > Name = emqh-XX (where XX is the server number being created)  
   > Resource Pool = None  
   > Format = QEMU image format    
   > VM ID = <next_available_address>  

   > If the virtual machine needs to be under a different PROXMOX node (pm-01, pm-02, ...pm-XX) then initiate a **migration** 
     to the necessary PROXMOX node before modifying or starting the virtual machine.  

2. Update the **Hardware** setting parameters to the values below:  
    
   **Memory**:   
   > Memory (MiB) = 4096  
   > Minimum memory (MiB) = 1024  
   > Ballooning Device = True  
   > All other parameters = Default 

   **Processors**:  
   > Processors Sockets = 1  
   > Processors Cores = 4  
   > All other parameters = Default  

3. Set the **Start at boot** checkbox to **true** using the **Options** section from the content panel:  
   ![](img/options_start_at_boot.png)   
4. Start the virtual machine using the **Start** button.
5. Update the hostname from **base-haproxy-template** to **emqh-XX** (where XX is the server number being creating) using the following command:
   ```shell
   sudo nano /etc/hostname
   ```
6. Update the hosts file using the following command:  
   ```shell
   sudo nano /etc/hosts
   ```
   Remove, update, and uncomment the lines based on the image below with respect to the server being configured:  
   ![](img/hosts_file_mariadb_haproxy.png)  
   **NOTE:** IP Address per node server should fall within the following subnets:  
   
   > emqh-01 - 10.20.20.18/24 and gateway 10.20.20.1  
   > emqh-02 - 10.20.20.19/24 and gateway 10.20.20.1

7. Reset the machine ID using the following commands:
   ```shell
   sudo  rm  -f  /etc/machine-id /var/lib/dbus/machine-id
   sudo dbus-uuidgen --ensure=/etc/machine-id
   sudo dbus-uuidgen --ensure
   ```
8. Regenerate ssh keys using the following commands:
   ```shell
   sudo rm /etc/ssh/ssh_host_*
   sudo dpkg-reconfigure openssh-server
   ```
9. Change the network interface IP address from **DHCP** to **Static** by editing the **00-installer-config.yaml** file, using the following command:   
    ```shell
    sudo nano /etc/netplan/00-installer-config.yaml
    ```
   Under the network interface key comment out the **dhcp4** key:value pair and then uncomment the remaining lines and configure the network settings accordingly see the image below:  
   ![](img/netplan_config_mariadb_haproxy.png)  
   **NOTE:** IP Address per node server should fall within the following subnets:  
   
   > emqh-01 - 10.20.20.18/24 and gateway 10.20.20.1  
   > emqh-02 - 10.20.20.19/24 and gateway 10.20.20.1
   
10. Update and upgrade the operating system using the following commands:   
    ```shell
    sudo apt update && sudo apt upgrade -y
    ```
    **NOTE:** If prompted to select which daemon services should be restarted, then accept the default selections, 
    press the **tab** key to navigate between the selections.
11. Edit the **Network Device** from the **Hardware** settings of the VM, and assign **VLAN Tag** 20, as in the image below:  
    ![](img/vm_nic_vlan_tag.png)   
12. Reboot the machine using the following command:  
     ```shell
     sudo reboot
     ```
13. Setup the firewall rules to allow incoming traffic from the following types of traffic:  
    **MariaDB database:**
    ```shell
    sudo ufw allow 3306/tcp
    ```
    If HAProxy is being setup on **mdbh-01**, then allow traffic from **mdbh-02
    (10.20.20.13)** using the following command:   
    ```shell
    sudo ufw allow from 10.20.20.13
    ```
    If HAProxy is being setup on **mdbh-02**, then allow traffic from **mdbh-01
    (10.20.20.12)** using the following command:   
    ```shell
    sudo ufw allow from 10.20.20.12
    ```
14. Update the **keepalived** file for load balancing and high-availability using the following command:  
    ```shell
    sudo nano /etc/keepalived/keepalived.conf
    ```
    Update **keepalived.conf** file according to the image below:  
    ![](img/keepalived_mariadb_haproxy.png)   
    
    **NOTE**: The configuration file will need to be updated and the following parameters will change per MASTER/BACKUP pair:  

   > **state** - If one node is the MASTER, the other will be the BACKUP.  
   > **interface** - Check the interface name being used.   
   > **virtual_router_id** - Use the last octet of the virtual IP address.  
   > **priority** - The MASTER (101) will have a higher priority than the BACKUP (100).  
   > **virtual_ipaddress** - Check the available IP network reserved for virtual routers.  
   
15. Update the **haproxy** file for load balancing and high-availability using the following command:   
    ```shell
    sudo nano /etc/haproxy/haproxy.cfg
    ```
    Placing the following text at the end of the file:  
    ```shell
    # Enable two instances of the stats webpage for display, monitoring, and health status.
    frontend stats
            mode http
            # The shared virtual IP and port number that'll be used to access the stats web page. 
            bind 10.20.20.11:8404
            # The MASTER/BACKUP IP address and port number used to create another instance of the stats web server 
            # to allow a haproxy load balancer listen section to be created and displayed on the stats web page 
            # that'll show the health status of the haproxy load balancers. 
            
            # Only uncomment one bind parameter that's based on the localhost for which the configuration is being configured for. 
            #bind 10.20.20.12:10404
            #bind 10.20.20.13:10404
            stats enable
            stats uri /stats
            stats refresh 10s
            stats admin if LOCALHOST
    
    # The shared virtual IP and port number that's used to check the health status of the haproxy load balancers.
    listen mariadb_load_balancers
            bind 10.20.20.11:10404 transparent
            balance source
            server mdbh-01 10.20.20.12:10404 check
            server mdbh-02 10.20.20.13:10404 check

    # The shared virtual IP and port number that's used to pass client request to the MariaDB Galera Cluster.
    listen mariadb_galera_cluster
            bind 10.20.20.11:3306 transparent
            balance source
            mode tcp
            option tcpka
            option mysql-check user haproxy
            server mdb-01 10.20.1.14:3306 check weight 1
            server mdb-02 10.20.5.14:3306 check weight 1
            server mdb-03 10.20.3.14:3306 check weight 1
    ```
    The updated **haproxy.cfg** file should look similar to the image below:  
    ![](img/haproxy_config_mariadb.png)  

   **listen mariadb_galera_cluster section**:   
   > **listen mariadb_galera_cluster** - Create a listen configuration named "mariadb_galera_cluster".  
   > **bind 10.20.20.11:3306 transparent** - HAProxy will listen on the specified IP address using transparent proxying,
     preserving client connection information.  
   > **balance source** - The load balancing algorithm is set to source, meaning it will choose which server to send client
     requests to based on the client's IP address.  
   > **option tcpka** - This enables TCP keep-alive on client and server sides.   
   > **option mysql-check user haproxy** - Enables a health check that specifically checks if a MariaDB server is healthy.
     The user haproxy is used for performing health checks, this user needs to be created in each MariaDB server and should
     have enough privileges to log in and execute commands, necessary for the health check.  
   > **server mdb-XX 10.20.Y.Y:3306 check weight 1** - Defines a server within a backend or listening group. The "check" word 
     tells HAProxy to periodically check the health of the MariaDB server by attempting a connection and if the server doesn't respond 
     to the health check then HAProxy will stop sending traffic until the server starts responding to health check again.
     The "weight 1" option informs HAProxy of the server's importance relative to other servers in the cluster. A higher weight
     means it will handle more connections. In this case all servers are treated equally. 
   
16. Go to each **MariaDB Server** and specify the **MariaDB HAProxy Servers** from which the HAProxy User 
    can connect to the **MariaDB Server Databases**, using the following SQL commands from the **MariaDB Server Shell**.   
    Access the MariaDB shell as the root user and prompt for the root password:  
    ```shell
    sudo mariadb -u root -p
    ```
    Create the haproxy user using the following SQL command:  
    ```sql
    CREATE USER 'haproxy'@'10.20.20.12';
    CREATE USER 'haproxy'@'10.20.20.13';
    ```
    Verify the user and hosts were created by executing the following SQL command:  
    ```sql
    SELECT User, Host FROM mysql.user;  
    ```
    **NOTE:** Since a MariaDB Galera cluster exists, the initial creation of the haproxy user should have been 
    propagated to the other MariaDB servers, access the MariaDB shell from the other servers and issue the SQL command 
    above to verify. 

17. Go back to the **HAProxy Server** and start and enable the **keepalived** and **haproxy** services using the following commands:  
    ```shell
    sudo systemctl enable --now keepalived
    ```
    ```shell
    sudo systemctl enable --now haproxy
    ```
    The status of the **keepalived** and **haproxy** services can be checked using the following commands:   
    ```shell
    sudo systemctl is-active keepalived
    ```
    ```shell
    sudo systemctl is-active haproxy
    ```
18. You can verify the state of each Keepalived service by examining the Keepalived logs on each MariaDB HAProxy node:  
    ```shell
    sudo grep "Keepalived" /var/log/syslog
    ```
    **NOTE:** This command will go through the 'syslog' file, line by line, and print out any lines that contain 
    the word "Keepalived".  
19. Open a web browser and type the url [http://10.20.20.11:8404/stats](http://10.20.20.11:8404/stats)
    to access the HAProxy stats web page.  
    If all the MariaDB and HAproxy servers are operating correctly, then frontend and listen tables will be displayed, where 
    each row corresponds to a server and a color green indicates the server is active and up. A legend is displayed that'll See the image below:   
    ![](img/mariadb_haproxy_stats_page.png)  
20. Access AD-01 and bind the virtual IP to the hostname **mdb.research.pemo** using the following steps:  
    1. Open the **DNS** tools from the **Microsoft Server Manager**, see the image below:   
       ![](img/dns_tools_server_manager.png)  
    2. Create a new host in the **research.pemo** domain under the **Foward Lookup Zones**, see the image below:  
       ![](img/research_domain_in_ad.png)
    3. Bind a new hostname to the virtual IP, see the image below:  
       ![](img/new_host_in_research_domain.png)  
21. Open a web browser and type the url [http://mdb.research.pemo:8404/stats](http://mdb.research.pemo:8404/stats)
    to verify that the binding of the new hostname and virtual IP.  
22. Join the MariaDB HAProxy server to the Active Directory:  
    1. Edit the Samba configuration file using the following command:
       ```shell 
       sudo nano /etc/samba/smb.conf
       ```
       Update the value of the variable **netbios name** to the server node name being created in the **[global]** section. This 
       should be the only variable that needs to be updated across each server node configuration file. See the image   
       below for clarification:  
       ![](img/samba_server_config_mariadb_haproxy.png)  
    2. Start and enable the **Samba** service using the following command:   
       ```shell
       sudo systemctl enable --now smbd
       ```
    3. Join the machine to active directory domain using the following command:  
       ```shell
       sudo net ads join -S AD-01.RESEARCH.PEMO -U <user_in_ad_domain>
       ```
       **<user_in_ad_domain>** - is a user who has privileges in the AD domain to add a computer.  
    4. Start and enable the **winbind** service using the following command:  
       ```shell
       sudo systemctl enable --now winbind
       ```
       Verify that **winbind** service established a connection to the active directory domain by running the command below:
       ```shell
       sudo wbinfo -u
       ```
       **NOTE:** This command will return a list of users from the domain that is connected via **winbind**.  

    5. Verify AD login acceptance into the machine by logging out and in with your AD account. 
23. Install **SentinelOne** cybersecurity software to detect, protect, and remove malicious software.   
    > The following sub steps will explain how to install **SentinelOne** by mounting a NAS (network attached storage) 
      device, then accessing the installation files on the NAS. There are other methods for installation along with uninstalling, 
      and upgrading **SentinelOne**, if any other method is needed then see the **SentinelOne** setup document that's 
      under a PEMO Site Automation GitHub repository.  
    
    1. Check that the latest **SentinelOne** package is on the research scada share if not then you can download the last package
       then replace the existing package, see the image below on finding the latest package on the web management console:  
       ![](./img/sentinels_packages.png)  
    2. Make note and verify the site token for the site that the machine will join, the site token for a site can be found using
       the following image for reference, click the site to find the site token:  
       ![](./img/settings_sites.png)  
    3. Install the network file system packages if not already installed using the following command:   
       ```shell
       sudo apt install nfs-common -y
       ```
    4. Create a NFS directory on the local machine to share using a similar command to the following:  
       ```shell
       sudo mkdir -p /mnt/scada/nas
       ```
    5. Allow full permissions (read, write, execute) for the owner, group and others using a similar command to the following:  
       ```shell
       sudo chmod 777 /mnt/scada/nas
       ```
    6. Check that the correct NFS share is available on the NFS server using a similar command to the following:  
       ```shell
       showmount -e cnas-01.research.pemo
       ```
       The following image will show the NFS shares available, from issuing the above command:  
       ![](./img/nfs_shares_available_on_server.png)   
       If the NFS share is not available then check the following on the NAS:  
       - Ensure the share folder is created.  
       - Check the location of the share folder.  
       - Check the NFS permission rules.  

    7. Mount the external NFS share on machine using a similar command to the following:  
       ```shell
       sudo mount -t nfs cnas-01.research.pemo:/volume1/scada /mnt/scada/nas
       ```
    8. Change directories to the location where the files and shell script are located using a similar command to the following:  
       ```shell
       cd /mnt/scada/nas/program_install_files/sentinel_one
       ```
       **NOTE:** If denied access to the NFS share then change owner of the directory using a similar command to the following:  
       ```shell
       sudo chown <user or user:group> /mnt/scada/nas
       ```
    9. Once in the **SentinelOne** directory execute the shell script **sentinelone_linux_agent_install.sh** using the following command:  
       ```shell
       sudo ./sentinelone_linux_agent_install.sh
       ```
       **NOTE:** Ensure that the latest packages from step 1, are in the directory and that the shell script 
       contains the correct path to the latest package and site token (with respect to the site that the machine will join).
       Use the following command to open the shell script, if necessary:  
       ```shell
       sudo nano sentinelone_linux_agent_install.sh
       ```
    10. Open up the **SentinelOne** web management console and verify the machine joined the Sentinels endpoint list, check the image below:  
        ![](./img/sentinels_endpoints.png)     
24. Repeat steps 1–23 above for every MariaDB HAProxy server node created.  
25. Jump to step 5 in the [MariaDB HAProxy Main Content Steps](#mariadb-haproxy-main-content-steps) section.  