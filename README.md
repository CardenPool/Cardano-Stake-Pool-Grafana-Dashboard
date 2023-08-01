# Stake-Pool-Grafana-Dashboard
Grafana Dashboard to monitor a bare-metal and sparse Cardano node.

This Grafana+Prometheus dashboard is designed to remotely monitor the most important metrics for the block producer and all relays of a bare-metal and sparse Cardano stakepool. Thanks to alarm presets, you'll receive real-time notifications via Telegram, minimizing reaction time in case of issues. The dashboard collects and organizes the keys performance indexes and, moreover, important information about P2P connections (the board shows P2P information only for relay #4 to since is our P2P enabled relay). This board is a melting pot of various existing dashboards provided by other SPOs, with added panels, optimizations, and other enhancements to make it compatible with the latest node developments and third-party sites (e.g., cexplorer.org).

### KES, minting and performance section
![kes e minting](https://github.com/CardenPool/Stake-Pool-Grafana-Dashboard/assets/86101039/3d8bef42-a150-484c-b06f-8471f2167a51)

### DDoS / Flood monitoring
![Flood](https://github.com/CardenPool/Stake-Pool-Grafana-Dashboard/assets/86101039/a879aaf7-bed2-4fbb-a81e-36e76b2b9c60)
<sub>(Yep...screenshot taken at the end of and DDoS attack...)<sub>

### System load section
![load](https://github.com/CardenPool/Stake-Pool-Grafana-Dashboard/assets/86101039/e6b7d121-99bd-463a-aeb8-bef0827c7fbe)

### Time synchronization section
![Time synchronization](https://github.com/CardenPool/Stake-Pool-Grafana-Dashboard/assets/86101039/2462676a-55c8-4665-ac8e-d7df310424f7)

### Temperatures section
![Temperatures](https://github.com/CardenPool/Stake-Pool-Grafana-Dashboard/assets/86101039/7a65d69a-4d34-4d25-8153-f6a2ee846baf)

### Node and chain state
![Node and chain](https://github.com/CardenPool/Stake-Pool-Grafana-Dashboard/assets/86101039/57bd1e89-d8d9-475d-ae9d-473201f6a85b)


This script is for SPO use only. Further improvements will be shared. Please, consider this work as a work in progress.

## Installation
To make this board fully working, you need to :

1) A working installation of Grafana and Prometheus for each physical server ([Guide: How to install Gradana and Prometheus](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node/part-iii-operation/setting-up-dashboards))

2) Install the Clock and Simpod JSON plugins for Grafana
```console
grafana-cli plugins install grafana-clock-panel
grafana-cli plugins install simpod-json-datasource
```

3) Copy and configure the provided script for JSON data scraping from cexplorer.org
```console
mkdir grafana-scripts
cd grafana-scripts
wget https://raw.github.com/.....
chmod +x getstats.sh
```
You have to edit this script adding your pool ID (BECH 32 format). To edit the file, you can use nano:
```console
nano getstats.sh
```
This script downloads the most updated information about your stake pool from cexplorer.org. The information is stored in a local JSON file (poolStat.prom created within the script directory). These information are used to populate the related graphic panels within the board. Now, let's set up a cron job to programmatically. On the machine **running the Grafana core**, open the cron editor executing the command:
```console
contab -e
```
Add this line at the end of the file:
```bash
#Get data from Cexplorer every day at 06:00
0 */3 * * * /home/your-user-name/grafana-scripts/getstats.sh
```
Save the file and agree with the cron update request. 

4) Edit the leader schedule scipt [Guide: Configuring slot leader calculation](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node/part-iii-operation/configuring-slot-leader-calculation). In addition to the original version, it creates a local JSON files containing the number of elected leader slot for the next epoch. At line 119, before the closing }, add the following lines:


```bash
#Count assigned slots
# Verify input file existence
if [ -f "$DIRECTORY/logs/leaderSchedule_$next_epoch.txt" ]; then
    # Count single values within the column "SlotNo" (exluding the first line)
    count=$(awk 'NR>2 {sum+=1} END {print sum}' "$DIRECTORY/logs/leaderSchedule_$next_epoch.txt")
if [ $count ]; then
    # Save the result within the output file
    echo "leaderScript_AssignedSlots $count" > "$DIRECTORY/logs/prometheus/leaderSchedule.prom"
else
#Save "leaderScript_AssignedSlots 0" within output file
    echo "leaderScript_AssignedSlots 0" > "$DIRECTORY/logs/prometheus/leaderSchedule.prom"
fi
else
    # If input file doesn't exists, save "leaderScript_AssignedSlots 0" within the output file
    echo "leaderScript_AssignedSlots -9999" > "$DIRECTORY/logs/prometheus/leaderSchedule.prom"
fi

```

Since the installation of the leader log script requires adding a cron task for its execution, the JSON file will be created with each run.

5) Install the board using your grafana front-end
Visit your grafana page with your browser and auteticate. ........

You're done!

## Dashboard customization
The current dashboard monitors four relays (only one with P2P enabled) accessible through our DNS, and the core is reached using a static and local IP address. While using aliases, you'll need to modify individual visualizations by setting your own IP addresses and ports. This setup allows me to effectively monitor the network's performance and respond promptly to any issues.

To make the adaptation of the dashboard on your infrastructure simpler, following there is the actual CRPL infrastructure so you can take understand how the Dashboard is structure and where intevene.

**LOCAL NETWORK (static private IP)**
- Relay 1 (run the Grafana core - scrape data from cexplorer with ***getstats.sh***)
- Relay 2 (Prometheus node exporter)
- Core (Prometheus node exporter - scrape data from the leaderlog with ***getstats.sh***)


**WAN NETWORK (dns pointing the public static address of each remote machine)**
- Relay 3 (Prometheus node exporter)
- Relay 4 (Prometheus node exporter)
