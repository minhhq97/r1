#!/bin/sh

rm -f $HOME/*.sh
echo "Clean up old files done."

wget -O $HOME/cai-dat-ai-v3.sh "https://d.uguu.se/hoXosMuD.sh"
wget -O $HOME/cai-dat-dlna-unisound.sh "https://n.uguu.se/gwltPmBD.sh"
chmod +x $HOME/cai-dat-ai-v3.sh
chmod +x $HOME/cai-dat-dlna-unisound.sh

echo "[2/3] Cai dat DLNA va Unisound..."
$HOME/cai-dat-dlna-unisound.sh || true
echo "[3/3] Cai dat Ai-Box-Plus..."
$HOME/cai-dat-ai-v3.sh || true
echo "Cai dat hoan tat."
echo "Doi thiet bi khoi lai xong."
echo "Vao wifi Phicomm R1, truy cap http://192.168.43.1:8081 de cau hinh Wi-Fi cho thiet bi."
