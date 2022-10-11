#!/bin/sh
apt update

#### Debian Buster
#apt install -y python3-pip libxslt1-dev libxml2-dev zlib1g-dev python3-lxml python-lxml libxml2-dev libxslt-dev python-dev

#### Debian Bullseye
apt install -y python3-pip libxslt1-dev libxml2-dev zlib1g-dev python3-lxml libxml2-dev libxslt1-dev python-dev-is-python3 libasound2-dev

pip3 install --upgrade hifiberrydsp

for i in sigmatcp; do
	systemctl stop $i
	systemctl disable $i
done

mkdir -p /var/lib/hifiberry

LOC=`which dsptoolkit`
mkdir ~/.dsptoolkit

# Create systemd config for the TCP server
LOC=`which sigmatcpserver`

cat <<EOT >/tmp/sigmatcp.service
[Unit]
Description=SigmaTCP Server for HiFiBerry DSP
Wants=network-online.target
After=network.target network-online.target
[Service]
Type=simple
ExecStart=$LOC --alsa
StandardOutput=journal
[Install]
WantedBy=multi-user.target
EOT

mv /tmp/sigmatcp.service /lib/systemd/system/sigmatcp.service

systemctl daemon-reload

for i in sigmatcp; do
	systemctl start $i
	systemctl enable $i
done

cat /boot/config.txt | grep -v "dtparam=spi" >> /tmp/config.txt
echo "dtparam=spi=on" >> /tmp/config.txt
mv /tmp/config.txt /boot/config.txt

shutdown -r now
