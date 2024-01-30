# EMQX Server Node Main Content Steps
___
1. Access the Proxmox hypervisor web interface using a web browser and enter the following url in the specified format:  
    **https://PROXMOX-Server-IP-Address:8006/** 
2. If a base ubuntu template (**base-ubuntu-template**) is available, then see the 
   [EMQX Server Node Setup ](#emqx-server-node-setup) section, if not continue in **this section** to **step 3**.
3. If no base Ubuntu template is available then see the **base-ubuntu build sheet** document which should be located under 
   the **scada** share on the research **NAS**.
4. Create the EMQX HAProxy servers using the **emqx_haproxy** document. 

## EMQX Server Node Setup
___
1. Right-click and perform a full clone of the base Ubuntu template (**base-ubuntu-template**) and set the following settings below:  

   > Mode = Full Clone  
   > Target Storage = Same as source  
   > Name = emq-XX (where XX is the server number being created)  
   > Resource Pool = None  
   > Format = QEMU image format  

   > NOTE: If the virtual machine needs to be under a different PROXMOX node (pm-01, pm-02, ...pm-XX) then initiate a **migration** 
     to the necessary PROXMOX node before modifying or starting the virtual machine.  

2. Update the VM configuration settings by accessing the VM management interface and selecting on the VM:  
   1. **Hardware Settings:**  
        
      > **Memory:**  
        Memory (MiB) = 8192  
        Minimum memory (MiB) = 1024  
        Ballooning Device = True  
        All other parameters = Default
      
      See the image below for modifying the **Hardware Memory** settings:   
      ![](img/vm_hardware_memory.png)   
   
      > **Processors:**  
        Processors Sockets = 2   
        Processors Cores = 2    
        All other parameters = Default

      See the image below for modifying the **Hardware Processor** settings:    
      ![](img/vm_hardware_processors.png)   
   
   2. **Options Settings**:     
      > **QEMU Guest Agent:**   
        Use QEMU Guest Agent  = True  
        All other parameters = Default    
       
      See the image below for modifying the **Option QEMU Guest Agent** settings:    
      ![](img/vm_options_qemu_guest_agent.png)   

      > **Start at boot:**   
        Start at boot = True  
      
      See the image below for modifying the **Option Start At Boot** settings:    
      ![](img/vm_options_start_at_boot.png)   
 
3. Start the virtual machine using the **Start** button.  
4. Update and upgrade the operating system using the following commands:   
   ```shell
   sudo apt update && sudo apt upgrade -y
   ```
   **NOTE:** If prompted to select which daemon services should be restarted, then accept the default selections, 
   press the **tab** key to navigate between the selections. 
5. Update the hostname from **baseubuntu** to **emq-XX** (where XX is the server instance being created) using the following command:
   ```shell
   sudo nano /etc/hostname
   ```
6. Update the hosts file using the following command:  
   ```shell
   sudo nano /etc/hosts
   ```
   Remove, update, and uncomment the lines based on the image below with respect to the server being configured:  
    ```shell
    127.0.0.1 localhost
    10.20.XX.XX emq-XX.research.pemo emq-XX
    10.20.1.13 ad-01.research.pemo ad-01
    10.20.5.13 ad-02.research.pemo ad-02
    10.20.3.13 ad-03.research.pemo ad-03
    ```
   ![](img/server_ad_hosts_file.png)  
   **NOTE**: IP Address per node server should fall within the following subnets:  
   
   > emq-01 - 10.20.1.18/24 and gateway 10.20.1.1  
   > emq-02 - 10.20.5.18/24 and gateway 10.20.5.1  
   > emq-03 - 10.20.3.18/24 and gateway 10.20.3.1  

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
9. Change the network interface IP address from DHCP to Static by editing the **00-installer-config.yaml** file using the following command:   
    ```shell
    sudo nano /etc/netplan/00-installer-config.yaml
    ```
   Under the network interface key comment out the **dhcp4** key:value pair and then uncomment the remaining lines and configure the network settings accordingly see the image below:  
   ![](img/netplan_config_static_ip.png)  
   **NOTE**: IP Address per node server should fall within the following subnets:  
   
   > emq-01 - 10.20.1.18/24 and gateway 10.20.1.1  
   > emq-02 - 10.20.5.18/24 and gateway 10.20.5.1  
   > emq-03 - 10.20.3.18/24 and gateway 10.20.3.1  
   
10. Restart the machine using the following command:  
    ```shell
    sudo reboot
    ```
11. Allow incoming connections on the following ports, using the following commands: 
    ```shell
    sudo ufw allow 1883/tcp
    sudo ufw allow 4370/tcp
    sudo ufw allow 5370/tcp
    sudo ufw allow 8080/tcp
    sudo ufw allow 8084/tcp
    sudo ufw allow 8404/tcp
    sudo ufw allow 18083/tcp
    ```
    Verify the firewall rules were accepted using the following command:  
    ```shell
    sudo ufw status numbered
    ```
12. Goto any MariaDB server (mdb-01, mdb-02, or mdb-03) and create an mqtt database, user to access the database, 
    table in the database, and user in the table, using the following commands:  
    1. Access the MariaDB shell:  
       ```shell 
       sudo mariadb -u root -p
       ```
    2. Create the **mqtt** database:  
       ```mariadb 
       CREATE DATABASE mqtt;
       ```
    3. Create a user to access the **mqtt** database, using the following sql commands:   
       1. Use the new more secure password hashing method when creating or changing passwords.
          ```mariadb 
          SET old_passwords=0;
          ```
       2. Create a new user with a password.
          ```mariadb 
          CREATE USER 'emqx'@'10.20.%' identified by 'T1ger$$$$$';
          ```
       3. Grant the newly created user access to the tables in the database. 
          ```mariadb 
          GRANT ALL PRIVILEGES ON mqtt.* TO 'emqx'@'10.20.%';
          ```
       4. Apply the changes.
          ```mariadb 
          FLUSH PRIVILEGES;
          ```
       5. Check that the user was created. 
          ```mariadb
          SELECT user, host FROM mysql.user;
          ```
    4. Access the **mqtt** database:  
       ```mariadb 
       USE mqtt;
       ```
    5. Create the **mqtt_user** table in the **mqtt** database:  
       ```mariadb
       CREATE TABLE `mqtt_user` (
       `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
       `username` varchar(100) DEFAULT NULL,
       `password_hash` varchar(100) DEFAULT NULL,
       `salt` varchar(35) DEFAULT NULL,
       `is_superuser` tinyint(1) DEFAULT 0,
       `created` datetime DEFAULT NULL,
       PRIMARY KEY (`id`),
       UNIQUE KEY `mqtt_username` (`username`)
       )    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
       ```
    6. Create a user in the **mqtt_user** table. 
       ```mariadb
       INSERT INTO mqtt_user(username, password_hash, salt, is_superuser) 
       VALUES ('mqtt', SHA2("V#2Rs%2E7%vem8", 256), NULL, 0);
       ```
    7. Check that the user was created. 
       ```mariadb
       SELECT * FROM mqtt.mqtt_user;
       ```
    **NOTE**: This only has to be executed once, which should have been when creating the first EMQX node.
    If yes, skip **step 12** and continue to **step 13** below.   
13. Install EMQX on Ubuntu using the following commands: 
    1. Download the EMQX repository:  
       ```shell
       curl -s https://assets.emqx.com/scripts/install-emqx-deb.sh | sudo bash
       ```
    2. Install EMQX:
       ```shell
       sudo apt install emqx
       ```
    3. Start EMQX:
       ```shell
       sudo systemctl start emqx
       ```
    4. Reset the default administrative user password, to access the EMQX dashboard using the following command:  
       ```shell
       emqx ctl admins passwd admin <one_extra_rich_capital_pound>
       ```
       **NOTE**: Only reset the default administrative user password on the first node, once the remaining 
       nodes join the cluster, the credentials will be propagated to the nodes.    
    5. Access the EMQX dashboard and verify the login by using the domain name or IP address of the host where 
       EMQX is being configured, using the url below:  

       > **http://EMQX-Server-IP-Address:18083/** 
       
       **NOTE**: Only login with the updated credentials on the first node in the cluster, for the remaining nodes 
       just verify the EMQX dashboard is accessible. 
14. Edit the main EMQX broker configuration file using the following command:  
    ```shell 
    sudo nano /etc/emqx/emqx.conf
    ```
    Overwrite the existing configuration file with the configuration below, keep the existing comments and add the new
    comments from below:  
    ```shell
    # Human-Optimized Config Object Notation (HOCON) File
    # EMQX Docs for verison 5.4 can be found at https://www.emqx.io/docs/en/v5.4/
    node {
      # XX represents the last two octets where EMQX is being configured.
      # Check the cluster.static.seeds parameter for the IP addresses of the nodes in the cluster. 
      name = "emqx@10.20.XX.XX"
      cookie = "5u#k4UGe9nX#^9"
      data_dir = "/var/lib/emqx"
    }

    cluster {
      name = emqxcl
      # Auto clustering by static node list
      discovery_strategy = static
      static {seeds = ["emqx@10.20.1.18", "emqx@10.20.5.18", "emqx@10.20.3.18"]}
      autoheal = true
      autoclean = 5m
      # Allow the nodes to connect via TCP IPv4
      proto_dist = inet_tcp
    }
    
    # MariaDB Authentication
    mysql {
      enable = true
      backend = "mysql"
      mechanism = "password_based"
    
      server = "mdb.research.pemo:3306"
      database = "mqtt_user"
      username = "emqx"
      password = "T1ger$$$$$"
      pool_size = 8

      password_hash_algorithm.simple {name = "sha256", salt_position = "suffix"}
      query = "SELECT password_hash, salt FROM mqtt_user where username = ${username} LIMIT 1"
      query_timeout = "5s"
    }

    dashboard {
        listeners.http {
          bind = 18083
          max_connections = 512
          # proxy_header = true
        }
    }
    
    listeners.tcp.default {
      bind = "0.0.0.0:1883"
      proxy_protocol = true
      # Defaults to infinity
      # max_connections = 1024000
    }
    
    log {
      file_handlers.default {
      enable = true
      level = debug
      file = "log/emqx.log"
      rotation = 10
      rotation_size = 50MB
      formatter = json
      }
      console_handler {
         enable = true
         level = warning
         formatter = json
      }
    }
    ```
    **NOTE**: The **node.name** should be the only parameter in the configuration file that should have to change per
              node in the cluster.  
15. Join the EMQX server to the Active Directory:  
    1. Install the necessary Samba and Kerberos packages to integrate with a Windows OS network using the command below:  
       ```shell
       sudo apt install samba krb5-config krb5-user winbind libnss-winbind libpam-winbind -y 
       ```
       **NOTE**: When prompt for the kerberos default realm type **RESEARCH.PEMO** then highlight over **Ok** 
       and press enter as in the image below:  
       ![](img/default_kerberos_realm.png)  
    2. Edit the Kerberos configuration file using the **nano** command:   
       ```shell
       sudo nano /etc/krb5.conf
       ```
       Add the following to the end of **[realms]** section:  
       ```ini
       RESEARCH.PEMO = {
               kdc = AD-01.RESEARCH.PEMO
               kdc = AD-02.RESEARCH.PEMO
               kdc = AD-03.RESEARCH.PEMO
               default_domain = RESEARCH.PEMO
       }
       ```
       Add the following to the end of **[domain_realm]** section:  
       ```ini
       .research.pemo = .RESEARCH.PEMO
       research.pemo = RESEARCH.PEMO
       ```
    3. Edit the Samba configuration file using the following command:
       ```shell 
       sudo nano /etc/samba/smb.conf
       ```
    4. Add the following text to the **[global]** section:  
       ```ini
       workgroup = RESEARCH
       netbios name = EMQX-01
       realm = RESEARCH.PEMO
       server string = 
       security = ads
       encrypt passwords = yes
       password server = AD-01.RESEARCH.PEMO
       log file = /var/log/samba/%m.log
       max log size = 50
       socket options = TCP_NODELAY SO_RCVBUF=8192 SO_SNDBUF=8192
       preferred master = False
       local master = No
       domain master = No
       dns proxy = No
       idmap uid = 10000-20000
       idmap gid = 10000-20000
       winbind enum users = yes
       winbind enum groups = yes
       winbind use default domain = yes
       client use spnego = yes
       template shell = /bin/bash
       template homedir = /home/%U
       ```
       **NOTE 1**: Comment out any existing variable names that are similar to the names in the new configuration 
       for the **[global]** section above.
       Variables that are existing and need to be commented out:  
       
       >  **workgroup**  
          **server string**  
          **log file**  
          **max log size**  
       
       **NOTE 2**: The **netbios name** parameter should match the name of server where the configuration file is 
         being configured.
       
       `netbios name = EMQ-01 or EMQ-02, or EMQ-03`
    
    5. Edit the name service switch configuration file using the following command:
       ```shell
        sudo nano /etc/nsswitch.conf
       ```
       Replace the existing text in the file with the following: 
       ```shell
       passwd: compat winbind files systemd
       group: compat winbind files systemd
       shadow: compat winbind files
       gshadow: files
       
       hosts: files dns
       networks: files
       
       protocols: db files
       services: db files
       ethers: db files
       rpc: db files
       
       netgroup: nis
       ```
    6. Edit the **sudoers (/etc/sudoers.tmp)** configuration using the command below:  
       ```shell
       sudo visudo
       ```
       Add the following line to the end of the file:  
       ```text
       %cansudo ALL=(ALL:ALL) ALL
       ```
    7. Join the machine to active directory domain using the following command:  
       ```shell
       sudo net ads join -S AD-01.RESEARCH.PEMO -U <user_in_ad_domain>
       ```
       **NOTE:** **<user_in_ad_domain>** - is a user who has privileges in the AD domain to add a computer.  
    8. Restart the **Samba** service using the following command:   
       ```shell
       sudo systemctl restart smbd
       ```
    9. Restart the **winbind** service using the following command:  
       ```shell
       sudo systemctl enable --now winbind
       ```
       Verify that **winbind** service established a connection to the active directory domain by running the command below:  
       ```shell
       sudo wbinfo -u
       ```
       **NOTE:** This command will return a list of users from the domain that is connected via **winbind**.   

    10. Verify AD login acceptance into the machine by logging out/in with an AD account.  
16. Install **SentinelOne** cybersecurity software to detect, protect, and remove malicious software.   
    > The following sub steps will explain how to install **SentinelOne** by mounting a NAS (network attached storage) 
      device, then accessing the installation files on the NAS. There are other methods for installation along with uninstalling, 
      and upgrading **SentinelOne**, if any other method is needed then see the **SentinelOne** setup document 
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
       If the NFS share is not available, then check the following on the NAS:  
       - Ensure the share folder is created.  
       - Check the location of the share folder.  
       - Check the NFS permission rules.  
       - See **step 5** under [Galera Cluster Setup](#galera-cluster-setup) section for more solutions.  

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
17. Repeat steps 1–21 above, for every MariaDB server node created.  
18. Jump to step 4 in the [EMQX Server Node Main Content Setup](#emqx-server-node-main-content-steps) section.
