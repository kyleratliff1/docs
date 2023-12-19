# MariaDB HAProxy Server Node Setup
Ensure that there exist a functional MariaDB Galera Cluster before creating the HAProxy Load Balancers.
HAProxy is a software package that can be installed on Linux flavored operating systems which in turn allows the OS to act as a reverse proxy and 
load balancer.  
> **Reverse Proxy** - sits in front of your server and accepts request from clients on its behalf.   
> **Load Balancer** - will split incoming requests among a cluster of servers, keeps track of which server got the 
                      last request, and the server that should get the next request utilizing the cluster equally. 
___
1. Access the Proxmox hypervisor web interface using a web browser and enter the following url in the specified format:  
    `https://Your-Servers-IP-Address:8006/` 
2. If a base haproxy template (`base-haproxy-template`) is available right click and clone the VM template and set the following settings below, if not continue in `this` section to **step** 3:  
   > Mode = Full Clone  
   > Target Storage = Same as source  
   > Name = mdbh-XX (where XX is the server number being created)  
   > Resource Pool = None  
   > Format = QEMU image format    
   > VM ID = <next_available_address>  

   > If a migration is needing to be performed to another PROXMOX node then perform the migration first before modifying or starting the virtual machine. 

   1. Jump to the `Creating MariaDB HAProxy Nodes` section.
   2. Jump to **step** 5 in `this` section.
3. If a base ubuntu template (`base-ubuntu-template`) is available right click and clone the VM template and set the following settings below, if not continue in `this` section to **step** 4:

   > Mode = Full Clone  
   > Target Storage = Same as source  
   > Name = base-haproxy-template  
   > Resource Pool = None  
   > Format = QEMU image format  
   > VM ID = <next_available_address_in_the_thousands>  
   
   1. Following the steps in the `base_haproxy_vm_setup` document then return to this document.
   2. Jump to **step 2** in `this` section.
4. If no base Ubuntu template is available then see the `base-ubuntu build sheet` document which should be located under the `scada` share on the research `NAS`.
   1. Jump to **step 3** in `this` section.
___   
## Create MariaDB HAProxy Nodes
1. Create the `haproxy` file for load balancing and high-availability using the following command:  
   ```shell
   sudo nano /etc/haproxy/haproxy.cfg
   ```
   Place the following text into the `keepalived.conf` file: