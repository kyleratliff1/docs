!/bin/bash

# You will need to mount the scada share on cnas-01 to perform one of following to run this shell script:
# 1. Change directories to the /cnas-01.research.pemo/scada/program_install_files/sentinel_one after mounting.
# 2. Copy /cnas-01.research.pemo/scada/program_install_files/sentinel_one to the local machine and then 'cd' to the directory and install.

# You only have to change the following two variables if there's a newer SentinelOne version or the site token changes.
package_name="SentinelAgent_linux_x86_64_v23_4_1_4.deb"
site_token="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMTQuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjllYTg0Mjk3NTA4NjkxYWQifQ=="

# You don't have do the command [chmod +x "$package_name"] as the dpkg handles the installation.
dpkg -i "$package_name"
apt install -f
# Access the sentinelctl utility to perform instructions.
/opt/sentinelone/bin/sentinelctl management token set "$site_token"
/opt/sentinelone/bin/sentinelctl control start