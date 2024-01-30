# Main Content Steps
___
1. [Brand New Machine Setup From Vendor](#brand-new-machine-setup-from-vendor) Section
2. [Machine Setup After System Reset](#machine-setup-after-system-reset) Section
3. [BIOS Settings](#bios-settings) Section
4. [Domain Setup](#domain-setup) Section
5. [Ignition Install](#ignition-install) Section

## Brand New Machine Setup From Vendor
1. Verify windows is activated and has the latest updates.

## Machine Setup After System Reset
1. Join to Domain:  
   > Local User = **Automation**, Password = **1richcat**.  
   > setup three security question to all have an answer of **alcon** all lowercase.  
2. Verify windows os is activated and the latest updates are installed.  
3. Change Computer Name:  
   1. Client: IGH-\<BUILDING-AREA and SUB AREA (if exist)\>-\<INDEX\>  
      > Ex: **IGH-CONNERH-01.**  
   2. Server: IGS-\<BUILDING-AREA and SUB AREA (if exist)\>-\<INDEX\>  
      > Ex: **IGS-CONNERH-01.**  
4. BIOS settings, see [BIOS Settings](#bios-settings) section.  
5. Map the cnas-01 drive:
    > **\\cnas-01\scada**  
   
   Install the following software from the cnas-01 drive:  
   
   > Atera: \Admin\Program_Install_Files\Atera\setup_alcon_pemo  
   > SentinelOne: \Admin\Program_Install_Files\SentinelOne\install_sentinel_64bit_pemo  

6. Domain settings, see [Domain Setup](#domain-setup) section.  
7. Ignition install, see [Ignition Install](#ignition-install) section.  

## BIOS Settings
1. Numlock:

   > Boot\Bootup Numlock State = **On**

2. Power Fail State:

   > Chipset\PCH-IO Configuration\Restore AC Power Loss = **Last State**

## Domain Setup
1. Access AD-01 and set up an autologin user for the machine and assign to appropriate domain group. 
   **NOTE**: user will have a similar name to the machine name.
2. Using the local user account join the machine to the **alcon.pemo** domain and restart the machine.  

   > Settings\About\System Info\Advanced System Settings

3. Login with new user account created in the AD.
4. Drag the `autologin.reg` file from the nas onto the desktop and edit the file with the new user and run the file.
   **NOTE**: open the command prompt as an administrator and cd into directory
   where the **autologin.reg** file was placed to run the file.  
5. Restart the computer to verify the autologin with the new user.

## Ignition Install
This section needs to be updated!!!


