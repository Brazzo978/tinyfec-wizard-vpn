## Server installation 

Run this single command as root:
SupportedOS : debian 10 or later 
To install simply copy this command to the console/ssh and follow the instruction
```bash
sudo bash -c 'curl -fsSL https://raw.githubusercontent.com/Brazzo978/tinyfec-wizard-vpn/refs/heads/main/tinyfecvpn_server.sh -o tinyfecvpn_server.sh && chmod +x tinyfecvpn_server.sh && ./tinyfecvpn_server.sh'
```
The script will ask the user the port for the tunnel (4096 default), then its gonna ask the Fec parameter (20:10 default) , the password for the tunnel (secret is the default please change it ) and the subnet used by the tunel (10.22.22.0 is the default).


Once completed if you rerun the script you will be presented with a menù with the following option:
1) Check if TinyFecVPN service is running : will print if the tunnel service is running or if its not
2) Restart TinyFecVPN service : will try to restart the tunnel service
3) Stop TinyFecVPN service : will stop the tunnel service
4) Remove TinyFecVPN service : Completly remove everything tunnel related from the system 
5) Exit : exit from the menù.

## Client installation

Precompiled packages are available for openwrt , just download install them via the luci page and a new voice for vpn should appear , compile with the data the server script gave you and everything should work once enabled.


This project uses tinyfecvpn , all rights to the owner of the project , if you want to learn moreo go [here](https://github.com/wangyu-/tinyfecVPN).
