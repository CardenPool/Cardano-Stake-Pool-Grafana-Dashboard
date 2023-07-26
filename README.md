# Stake-Pool-Grafana-Dashboard
Grafana Dashboard to monitor a bare-metal and sparse Cardano node.

This Grafana+Prometheus dashboard is designed to remotely monitor the most important metrics for the block producer and all relays of a bare-metal and sparse Cardano stakepool. Thanks to alarm presets, you'll receive real-time notifications via Telegram, minimizing reaction time in case of issues. The dashboard collects and organizes the keys performance indexes and, moreover, important information about P2P connections (the board shows P2P information only for relay #4 to since is our P2P enabled relay). This board is a melting pot of various existing dashboards provided by other SPOs, with added panels, optimizations, and other enhancements to make it compatible with the latest node developments and third-party sites (e.g., cexplorer.org).
Further improvements will be shared. Please, consider this work as a work in progress.

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

4) Copy and configure the provided script for leader-log scraping
```console
wget https://raw.github.com/.....
chmod +x getstats.sh
```
This script is a modified version of the leader-schedule script provided by XXXXXXXX . In addition to the original version, it creates a local JSON files containing the number of elected leader slot for the next epoch. The leader-schedule script must be run at least 1.5 days before the epoch ends. You have to edit your **block-producer's** cron again to automate the process:
```console
contab -e
```

```bash
#Run the leader schedule every day. leaderScheduleCheck.sh check if we're 1.5 days before epoch ends.
#Epoch in MAINNET starts at 21:45 UTC
55 23 * * * /home/zion/cardano-my-node/leaderScheduleCheck.sh > /home/zion/cardano-my-node/logs/leaderSchedule_logs.txt 2>&1
```
Save the file and agree with the cron update request. 

5) Install the board using your grafana front-end

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
