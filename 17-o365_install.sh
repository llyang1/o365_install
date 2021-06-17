#!/bin/sh
# chmod +x 17-o365_install.sh
# curl -OL https://raw.githubusercontent.com/llyang1/o365_install/main/17-o365_install.sh; bash 17-o365_install.sh

red(){
 echo -e "\033[31m\033[01m$1\033[0m"
}

checkJava(){
myJava=$(which java)
if [[ ${#myJava} -le 2 ]]; then
 apt-get install default-jre -y; yum install default-jre -y
 apt-get install default-jdk -y; yum install default-jdk -y
fi
myJava=$(which java)
}

getLast(){

myURI=$(curl https://github.com/vanyouseea/o365/releases | sed '/o365.*download.*jar/!d' | sed '1!d' | awk -F'"' '{print $2}')
myURI="https://github.com"$myURI
myFile=$(echo $myURI | sed 's_.*[/]\(.*\)_\1_')
cd /home/
curl -OL $myURI

(crontab -l | grep -v 'o365') | crontab
(crontab -l ; echo "@reboot ${myJava} -jar /home/${myFile}") | crontab -
(crontab -l ; echo "11 * * * * /usr/bin/rclone copy /root/data/o365.mv.db Dropbox:/VPN") | crontab -
localIP=$(curl https://checkip.amazonaws.com) #curl https:/api.infoip.io/ip | curl http://ipecho.net/plain
echo "浏览器地址"
echo "------------------------------"
echo "http://"${localIP}":9527/"
echo "------------------------------"
red "重启中,等待1分钟就可以使用o365啦"
reboot
}

killPID(){
myPID=$(ps -ef | grep o365 | grep -v grep | grep -v install | awk '{print $2}')
for PID in ${myPID[@]}; do
  kill -9 $PID
done
}

port9527(){

checkUFW=$(ufw status)
checkFireD=$(firewall-cmd --list-all)
checkIptables=$(service iptables status)

if [[ ${#checkUFW} -ge 5 ]]; then
 checkPort=$(ufw status | grep 9527)
 if [[ ${#checkPort} -le 2 ]]; then
  echo "Open 9527 ..."
  ufw allow 9527/tcp
 fi
  ufw reload
  ufw status
 return 1
fi

if [[ ${#checkFireD} -ge 5 ]]; then
 checkPort=$(firewall-cmd --list-all | grep 9527)
 if [[ ${#checkPort} -le 2 ]]; then
  echo "Open 9527 ..."
  firewall-cmd --zone=public --permanent --add-port=9527/tcp
 fi
  firewall-cmd --reload
  firewall-cmd --list-all
 return 2
fi

if [[ $checkIptables =~ active ]] && [[ $checkIptables =~ loaded ]] ; then
  echo "Open 9527 ..."
  iptables -A INPUT -p tcp --dport 9527 -j ACCEPT
  service iptables save
  systemctl restart iptables
  iptables -L
 return 3
fi

}
red "自动开启端口 9527 (iptables未测试)"
red "自动备份数据库(每小时), 手工修改Dropbox:/VPN成你的rclone地址"
read -p "回车确认安装"
port9527
checkJava
killPID
getLast
# THE END
