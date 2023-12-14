## Brand New Machine Setup From Vendor
- Verify windows is activated and has the latest updates.
- 
## Machine Setup after system reset
- Setup For Personal Use
  - setup offline account, should be an option for this type of account in the lower left corner after selecting **For Personal Use**.
  - click limited experience in the lower left corner.
  - Local User will be `Automation` with password `1richcat`.
  - setup three security question to all have an answer of `alcon` all lowercase.
- Verify windows is activated and has the latest updates.
- Change Computer Name
  - Client: IGH-\<BUILDING-AREA>-\<INDEX>.
    - Ex: IGH-CONNERH-01.
  - Server: IGS-\<BUILDING-NAME>-\<INDEX>. 
    - Ex: IGS-CONNER-01.
- BIOS settings, see **BIOS Settings** section below.
 - Map the cnas drive
    - `\\cnas-01\scada`
 - Install software from the cnas-drive
    - Atera: `\Admin\Program_Install_Files\Atera\setup_alcon_pemo`
    - SentinelOne: `\Admin\Program_Install_Files\SentinelOne\install_sentinel_64bit_pemo`
 - Domain settings, see **Domain Settings** section below.
 - Ignition install, see **Ignition Install** section below.

## BIOS Settings
#### Press Del Key on startup/power cycle
- Numlock
  - `Boot\Bootup Numlock State` set to **On**
- Power Fail State
  - `Chipset\PCH-IO Configuration\Restore AC Power Loss` set to **Last State**
  
## Domain Setup
- Access AD-01 and set up an autologin user for the machine and assign to appropriate domain group. 
  - user will have a similar name to the machine name.
- Using the local user account join the machine to the `alcon.pemo` domain and restart the machine.
  - `Settings\About\System Info\Advanced System Settings`
- Login with new user account created in the AD.
- Drag the `autologin.reg` file from the nas onto the desktop and edit the file with the new user and run the file.
  - open the command prompt as an administrator and cd into directory where the `autologin.reg` file was placed to run the file.
- Restart the computer to verify the autologin with the new user.

## Ignition Install
- Client Machine
    - drag DeployClient8.bat file from the cnas and run it.
        - `\Admin\Program_Install_Files\InductiveAutomation\ClientSetup`
    - Set up the default screen for the machine and touch capabilities. 
- Server Machine 
  - Install the latest ignition version from the cnas.
      - `\Admin\Program_Install_Files\InductiveAutomation\Ignition X.X.X`
      - if the latest version isn't in the cnas download it and place into the cnas.


