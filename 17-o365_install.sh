#!/bin/sh
# chmod +x 17-o365_install.sh

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
localIP=$(hostname -I | sed 's_ __g')
echo "浏览器地址"
echo "------------------------------"
echo "http://"${localIP}":9527/"
echo "------------------------------"
red "如果你是Azure, Oracle等, 上面IP不正确,请手工替换"
red "回车,重启系统,等待1分钟就可以使用o365啦"
read -p "回车确认" -t600
reboot
}

killPID(){

myPID=$(ps -ef | grep o365 | grep -v grep | grep -v install | awk '{print $2}')
for PID in ${myPID[@]}; do
  kill -9 $PID
done

}
red "打开端口 9527"
read -p "回车确认" -t60
checkJava
killPID
getLast
# THE END
