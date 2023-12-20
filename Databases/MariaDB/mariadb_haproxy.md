# MariaDB HAProxy Main Content Steps
Ensure that there exist a functional MariaDB Galera Cluster before creating the HAProxy Load Balancers.
HAProxy is a software package that can be installed on Linux flavored operating systems which in turn allows the OS to act as a reverse proxy and 
load balancer.  
> **Reverse Proxy** - sits in front of your server and accepts request from clients on its behalf.   
> **Load Balancer** - will split incoming requests among a cluster of servers, keeps track of which server got the 
                      last request, and the server that should get the next request utilizing the cluster equally. 
___
1. Access the Proxmox hypervisor web interface using a web browser and enter the following url in the specified format:  
    `https://Your-Servers-IP-Address:8006/` 
2. If a base haproxy template (**base-haproxy-template**) is available see the
   [MariaDB HAProxy Server Node Setup](#Mariadb-haproxy-server-node-setup) section, if not continue to **step 3** in this section:
3. If a base ubuntu template (`base-ubuntu-template`) is available see **haproxy_template** document then return to this document 
   and jump to **step 2** in **this** section, if not continue in **this** section to **step 4**.
4. If no base Ubuntu template is available then see the **base-ubuntu build sheet** document which should be located 
   under the **scada** share on the research **NAS**, then return to **this** section and jump to **step 3**.
5. None 
___   
## MariaDB HAProxy Server Node Setup
1. Perform a full clone of base haproxy template (**base-haproxy-template**) by right-clicking and then set the following 
   settings below:  

   > Mode = Full Clone  
   > Target Storage = Same as source  
   > Name = mdbh-XX (where XX is the server number being created)  
   > Resource Pool = None  
   > Format = QEMU image format    
   > VM ID = <next_available_address>  

   > If a migration is needing to be performed to another PROXMOX node then perform the migration first before modifying or starting the virtual machine. 

2. Set the `Start at boot` checkbox to `true` using the `Options` section from the content panel:  
   ![](img/options_start_at_boot.png)   
3. Start the virtual machine using the `Start` button.
4. Update the hostname from `-template` to `mdb-XX` (where XX is the server number being creating) using the following command:
   ```shell
   sudo nano /etc/hostname
   ```
5. Update the hosts file using the following command:  
   ```shell
   sudo nano /etc/hosts
   ```
   Remove, update, and uncomment the lines based on the image below with respect to the server being configured:  
   ![](img/server_ad_hosts_file.png)  
6. Reset the machine ID using the following commands:
   ```shell
   sudo  rm  -f  /etc/machine-id /var/lib/dbus/machine-id
   sudo dbus-uuidgen --ensure=/etc/machine-id
   sudo dbus-uuidgen --ensure
   ```
7. Regenerate ssh keys using the following commands:
   ```shell
   sudo rm /etc/ssh/ssh_host_*
   sudo dpkg-reconfigure openssh-server
   ```
8. Change the network interface IP address from DHCP to Static by editing the `00-installer-config.yaml` file using the following command:   
    ```shell
    sudo nano /etc/netplan/00-installer-config.yaml
    ```
   Under the network interface key comment out the `dhcp4` key:value pair and then uncomment the remaining lines and configure the network settings accordingly see the image below:  
   ![](img/netplan_config_static_ip.png)  
   IP Address per node server should fall within the following subnets:
   > mdbh-01 - 10.20.1.14/24 and gateway 10.20.1.1  
   > mdbh-02 - 10.20.5.14/24 and gateway 10.20.5.1

    Accept the network settings by issuing the command below:
    ```shell
    sudo netplan try
    ```
9. Restart the machine using the following command `sudo reboot`.
10. Check for OS updates by issuing the following commands in the order below:  
    ```shell
    sudo apt-get update
    sudo apt-get upgrade
    ```

11. Create the `haproxy` file for load balancing and high-availability using the following command:  
    ```shell
    sudo nano /etc/haproxy/haproxy.cfg
    ```
    Place the following text into the `keepalived.conf` file:

12. Join the MariaDB server to the Active Directory:
    1. Edit the Samba configuration file using the following command:
       ```shell 
       sudo nano /etc/samba/smb.conf
       ```
       Update the value of the variable `netbios name` to the server node name being created in the `[global]` section. This 
       should be the only variable that needs to be updated across each server node configuration file. See the image
       below for clarification:  
       ![](img/samba_server_config_file.png)  
    2. Enable and restart the `Samba` service to start up automatically at boot using the following commands:   
       ```shell
       sudo systemctl enable smbd
       ``` 
       ```shell
       sudo systemctl restart smbd
       ```
    3. Join the machine to active directory domain using the following command:
       ```shell
       sudo net ads join -S AD-01.RESEARCH.PEMO -U <user_in_ad_domain>
       ```
       `<user_in_ad_domain>` - is a user who has privileges in the AD domain to add a computer.  
    4. Enable and restart the `winbind` service to start up automatically at boot using the following commands:
       ```shell
       sudo systemctl enable winbind
       ```
       ```shell
       sudo systemctl restart winbind
       ```
       Verify that `winbind` service established a connection to the active directory domain by running the command below:
       ```shell
       sudo wbinfo -u
       ```
       This command will return a list of users from the domain that is connected via `winbind`.  

    5. Verify AD login acceptance into the machine by logging out and in with your AD account. 
13. Install `SentinelOne` cybersecurity software to detect, protect, and remove malicious software. The following sub steps
    will explain how to install `SentinelOne` by mounting a NAS (network attached storage) device then accessing the install files
    on the NAS. There are other methods for installation along with uninstalling, and upgrading `SentinelOne`, if any
    other method is needed then see the `SentinelOne` setup document that's under a PEMO Site Automation GitHub repository.  
    1. Check that the latest `SentinelOne` package is on the research scada share if not then you can download the last package
       then replace the existing package, see the image below on finding the latest package on the web management console:  
       ![](./img/sentinels_packages.png)  
    2. Make note and verify the site token for the site that the machine will join, the site token for a site can be found using
       the following image for reference, click the site to find the site token:  
       ![](./img/settings_sites.png)  
    3. Install the network file system packages if not already installed using the following command:   
       ```shell
       sudo apt install nfs-common
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
       If the NFS share is not available then check the following on the NAS:  
       - Ensure the share folder is created.  
       - Check the location of the share folder.  
       - Check the NFS permission rules.  
       - See step 5 under `Deploy Galera Arbitrator` section for more solutions.  

    7. Mount the external NFS share on machine using a similar command to the following:  
       ```shell
       sudo mount -t nfs cnas-01.research.pemo:/volume1/scada /mnt/scada/nas
       ```
    8. Change directories to the location where the files and shell script are located using a similar command to the following:  
       ```shell
       sudo cd /mnt/scada/nas/program_install_files/sentinel_one
       ```
       If denied access to the NFS share then change owner of the directory using a similar command to the following:  
       ```shell
       sudo chown <user or user:group> /mnt/scada/nas
       ```
    9. Once in the `SentinelOne` directory execute the shell script `sentinelone_linux_agent_install.sh` using the following command:  
       ```shell
       sudo ./sentinelone_linux_agent_install.sh
       ```
       Ensure that the latest packages from step 1 is in the directory and that the shell script contains the correct path 
       to the latest package and site token (with respect to the site that the machine will join).
       Use the following command to open the shell script, if necessary:  
       ```shell
       sudo nano sentinelone_linux_agent_install.sh
       ```
    10. Open up the `SentinelOne` web management console and verify the machine joined the Sentinels endpoint list, check the image below:  
        ![](./img/sentinels_endpoints.png)  
14. Repeat steps 1 - 12 above for every MariaDB HAProxy server node created.  
15. Jump to step 5 in the [MariaDB HAProxy Main Content Steps](#mariadb-haproxy-main-content-steps) section.