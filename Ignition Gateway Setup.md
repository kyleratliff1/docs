# Ignition Remote Certificate Hostname Fix
This issue seems to appear if the hostname is changed after Igntion is installed. When approving incoming connections under Gateway Network the old hostname appears as the "Common Name" instead of the new/current hostname.
___
1. Stop Ignition Gateway.
    ```
    sudo service Ignition-Gateway stop
    ```
2. Remove metro-keystore file from the webserver folder found in the Ignition install directory.
    ```
    rm /usr/local/bin/ignition/webserver/metro-keystore
    ```
3. Start Ignition Gateway.
    ```
    sudo service Ignition-Gateway start
    ```
4. Go to the Ignition gateway that had the hostname change. Look under Config->Gateway Network->Outgoing Connections and note the *outgoing connections*.
5. Go to each Ignition gateway for those *outgoing connections* and delete the *incoming connection* for the gateway that has the incorrect hostname. Then re-approve the connection. The correct hostname should display now.
