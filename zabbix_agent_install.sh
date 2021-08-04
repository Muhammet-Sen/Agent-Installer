###########################################
##                                       ##
##	Zabbix Agent install Script	 ##
##				         ##
###########################################

#!/bin/bash

#Zabbix_agetd.conf dosyasını düzenlerken kullanılan degiskenlerdir.
SERVER="monitor.crypttech.com"       #Zabbix-server adress
SERVERACTIVE="monitor.crypttech.com" 
WINVERSION="4.2.1"          #Windows, zabbix-agent version
CENTOSVERSION="7"           #Centos, zabbix-agent version
RPMPACKAGE="zabbix-release-4.0-1.el7.noarch.rpm"  #Centos, zabbix-agent paket adı
WINPACKAGE="zabbix_agents-4.2.1-win-amd64-openssl.zip" #Windows, zabbix-agent paket adı
WINLOGFILE="c:\\\zabbix\\\zabbix_agentd.log" #Windows Zabbix-agent log tutma yolu
WINHOSTNAME="Windows host" #Zabbix windows makine adı
OTHERHOSTNAME="" #Zabbix linux,centos,macos makine adı
#Log gelip gelmediğini kontrol etmek istediğiniz dosyanın yolunu veriniz.Logun icerisinde yazildi ifadesini kontrol eder.
USERPARAMETER='log.question,tail -n 1000 /opt/cryptolog/audit/cryptolog.log |grep -a $(date +"%Y.%m.%d")|egrep "yazildi|written" | wc -l'
ZABBIXPSKID="" #Her makine için uniq bir değer olması gerekmektedir.
DATABASE_USER="" #cryptologdan lisans ve destek bitiş tarihlerini çekmek için gerekli
DATABASE_PSWD="" #cryptologdan lisans ve destek bitiş tarihlerini çekmek için gerekli

#Macos sistemlerde .plist uzantılı dosyayı olusturmak icin kullanılır.
MacPlist(){

 printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' \
 '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
 '<plist version="1.0">' \
 '<dict>' \
 '       <key>Label</key>' \
 '       <string>org.zabbix.zabbix_agent</string>' \
 '       <key>ProgramArguments</key>' \
 '       <array>' \
 '               <string>/usr/local/sbin/zabbix_agentd</string>' \
 '       </array>' \
 '       <key>RunAtLoad</key>' \
 '       <true/>' \
 '       <key>UserName</key>' \
 '       <string>zabbix-agent</string>' \
 '</dict>' \
 '</plist>' | sudo tee /Library/LaunchDaemons/org.zabbix.zabbix_agent.plist

}

#Sertifika olusturmayı ve zabbix_agentd.conf dosyasını duzenlemeyi saglar.
SetConfFile(){
     
   if [[ "$OSTYPE" == "cygwin"* ]]; then
        #Zabbix_agent.conf dosyasını duzenlemeyi saglar (or, Eski_ifade/Yeni_ifade).
        sed -i "s/Hostname=Windows host/Hostname=$WINHOSTNAME/" zabbix_agentd.conf
        sed -i "s/# EnableRemoteCommands=0/EnableRemoteCommands=1/" zabbix_agentd.conf    
        sed -i "s/# LogRemoteCommands=0/LogRemoteCommands=1/" zabbix_agentd.conf
        sed -i "s/Server=127.0.0.1/Server=$SERVER/" zabbix_agentd.conf
        sed -i "s/ServerActive=127.0.0.1/ServerActive=$SERVERACTIVE/" zabbix_agentd.conf
        sed -i "s/# TLSConnect=unencrypted/TLSConnect=psk/" zabbix_agentd.conf
        sed -i "s/# TLSAccept=unencrypted/TLSAccept=psk/" zabbix_agentd.conf
        sed -i "s/# TLSPSKIdentity=/TLSPSKIdentity=$ZABBIXPSKID/" zabbix_agentd.conf
        sed -i "s/# TLSPSKFile=/TLSPSKFile=$ZABBIXPSKFILE/" zabbix_agentd.conf
        sed -i "s/# UserParameter=/UserParameter=$USERPARAMETER/" zabbix_agentd.conf
   else  
      #Zabbix_agent.conf dosyasını duzenlemeyi saglar (or, Eski_ifade/Yeni_ifade).
      sed -i "s:Hostname=Zabbix server:Hostname=$OTHERHOSTNAME:" zabbix_agentd.conf	  
      sed -i "s:# EnableRemoteCommands=0:EnableRemoteCommands=1:" zabbix_agentd.conf    
      sed -i "s:# LogRemoteCommands=0:LogRemoteCommands=1:" zabbix_agentd.conf
      sed -i "s:Server=127.0.0.1:Server=$SERVER:" zabbix_agentd.conf
      sed -i "s:ServerActive=127.0.0.1:ServerActive=$SERVERACTIVE:" zabbix_agentd.conf
      sed -i "s:# TLSConnect=unencrypted:TLSConnect=psk:" zabbix_agentd.conf
      sed -i "s:# TLSAccept=unencrypted:TLSAccept=psk:" zabbix_agentd.conf
      sed -i "s:# TLSPSKIdentity=:TLSPSKIdentity=$ZABBIXPSKID:" zabbix_agentd.conf
      sed -i "s:# TLSPSKFile=:TLSPSKFile=$ZABBIXPSKFILE:" zabbix_agentd.conf
	  sed -i "s:# UserParameter=:UserParameter=$USERPARAMETER:" zabbix_agentd.conf
	  printf '%s\n' "UserParameter=$CRYPTOSIM_LISBITTAR" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=crypLisKalGun.question,$CRYPTOSIM_LISKALGUN" >> zabbix_agentd.conf
      printf '%s\n' "UserParameter=$CRYPTOSIM_DESBITTAR" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=crypDesKalGun.question,$CRYPTOSIM_DESKALGUN" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=mysql.question,ps ax | grep mysql | grep -v grep | wc -l" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=cryptolog.question,ps ax | grep cryptolog | grep -v grep | wc -l" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=chilli.question,ps ax | grep chilli | grep -v grep | wc -l" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=freeradius.question,ps ax | grep freeradius | grep -v grep | wc -l" >> zabbix_agentd.conf
	  printf '%s\n' "UserParameter=apache2.question,ps ax | grep apache2 | grep -v grep | wc -l" >> zabbix_agentd.conf
    fi
}

#Ubuntu ve Centos'da zabbix-agent kurulumunu gerceklestirir.
UbuntuAndCentos(){

 if [ -x /usr/bin/apt-get ]; then
    
   DISTRIB_CODENAME=`lsb_release -c -s`
   #check for distrib codename of ubuntu
   if [[ $DISTRIB_CODENAME == "bionic" ]]; then
       DEBPACKAGE="zabbix-release_4.0-2+bionic_all.deb"  #16.04,Ubuntu, zabbix-agent paket adı
	   VERSION="4.0"
   elif [[ $DISTRIB_CODENAME == "trusty" ]]; then
       DEBPACKAGE="zabbix-release_3.2-1+trusty_all.deb"  #14.04,Ubuntu, zabbix-agent paket adı
	   VERSION="3.2"
   elif [[ $DISTRIB_CODENAME == "xenial" ]]; then
       DEBPACKAGE="zabbix-release_4.0-2+xenial_all.deb"  #18.04,Ubuntu, zabbix-agent paket adı
	   VERSION="4.0"
   elif [[ $DISTRIB_CODENAME == "precise" ]]; then
       DEBPACKAGE="zabbix-release_2.2-2+precise_all.deb"  #12.04,Ubuntu, zabbix-agent paket adı
	   VERSION="2.2"
   fi
   
   apt-get update
   wget https://repo.zabbix.com/zabbix/$VERSION/ubuntu/pool/main/z/zabbix-release/$DEBPACKAGE
   #apt-get install ./$DEBPACKAGE
   dpkg -i $DEBPACKAGE
   apt-get update
   apt-get install zabbix-agent

 elif [ -x /usr/bin/yum ]; then

   rpm -ivh http://repo.zabbix.com/zabbix/$VERSION/rhel/$CENTOSVERSION/x86_64/$RPMPACKAGE
   yum -y update
   yum -y install zabbix-agent

 fi

 cd  /etc/zabbix/
 if [[ $DISTRIB_CODENAME != "precise" ]]; then
	 #Linux PSK
     openssl rand -hex 32 |  tee zabbix_agentd.psk
     ZABBIXPSKFILE="/etc/zabbix/zabbix_agentd.psk"
 fi
 SetConfFile
   
 #Olusturulan dosyaların zabbix-agent tarafından kullanılmasına ızın verir.
 chown -R zabbix: .
   
 /etc/init.d/zabbix-agent start
 /etc/init.d/zabbix-agent enable
 /etc/init.d/zabbix-agent status
}

#Windowsda zabbix-agent kurulumunu gerceklestirir.
Windows(){

 #Komut istemini administrator yetkisinde calıstırmayı unutmayın
 #Windows üzerinde cygwin kurulumunu gerçekleştir.Kurulum sırasında vim, unzip,ve  wget'i install etmeyi unutma.
 wget https://www.zabbix.com/downloads/$WINVERSION/$WINPACKAGE
 
 #Windows PSK
 openssl rand -hex 32 |  tee zabbix_agentd.psk
 ZABBIXPSKFILE="c:\\\zabbix\\\zabbix_agentd.psk"
 
 unzip $WINPACKAGE -d Zabbix
 #chgrp -Rv "Authenticated Users" $PWD/*
 chmod -vR 755 $PWD/*
 
 mkdir c:/zabbix/
 mv $PWD/zabbix_agentd.psk $PWD/Zabbix/bin/zabbix_agentd.exe $PWD/Zabbix/bin/zabbix_get.exe $PWD/Zabbix/bin/zabbix_sender.exe $PWD/Zabbix/conf/zabbix_agentd.conf -t  c:/zabbix/
 
 cd c:/zabbix/
 
 sed -i "s/LogFile=c:\\\zabbix_agentd.log/LogFile=$WINLOGFILE/" zabbix_agentd.conf

 SetConfFile 
 
 c:/zabbix/zabbix_agentd.exe --config c:/zabbix/zabbix_agentd.conf --install
 c:/zabbix/zabbix_agentd.exe --config c:/zabbix/zabbix_agentd.conf --start
 
}

#Macos da zabbix-agent kurulumunu gerceklestirir. Mac OS X Sierra üzerinde test edildi.
MacOSX(){

 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
 brew install zabbix
 brew install gnu-sed
 ln -s /usr/local/bin/gsed /usr/local/bin/sed
 hash -r
 
 cd /usr/local/etc/zabbix/

 #MacOsX PSK
 openssl rand -hex 32 |  tee zabbix_agentd.psk
 ZABBIXPSKFILE="/usr/local/etc/zabbix/zabbix_agentd.psk"
 
 chmod 755 /usr/local/etc/zabbix/
 
 SetConfFile

 #Zabbix agent'ı calistirmayi saglıyor. 
 /usr/local/sbin/zabbix_agentd
 
 MacPlist
  
}


# Kullanıcıdan zabbix'in kurulu olduğu host name'i, ve database user ve password bilgilerini istiyor . Alınan hostname'i aynı zamanda psk 'ya atama işlemini yapıyor.
while [[ $OTHERHOSTNAME == "" || $DATABASE_USER == "" || $DATABASE_PSWD == "" ]]
do
  read  -p "Please Enter Unique Host Name: " OTHERHOSTNAME
  read -p "Please Enter Database User: "  DATABASE_USER
  read -sp "Hello $DATABASE_USER . Please Enter Database Password: " DATABASE_PSWD
  printf '%s\n'
done
ZABBIXPSKID=$OTHERHOSTNAME
WINHOSTNAME=$OTHERHOSTNAME
#Lisans ve destek bitis tarihlerinin veritabanından alarak kalan gün sayısını hesaplar
CRYPTOSIM_LISBITTAR="crypLisBitTar.question,mysql cryptolog -u$DATABASE_USER -p$DATABASE_PSWD -e'select LisBitTar from lisans ;'  2> /dev/null |grep -v LisBitTar"
CRYPTOSIM_DESBITTAR="crypDesBitTar.question,mysql cryptolog -u$DATABASE_USER -p$DATABASE_PSWD -e'select DesBitTar from lisans ;'  2> /dev/null |grep -v DesBitTar"
CRYPTOSIM_LISKALGUN='echo $(( ($(date --date="$(mysql cryptolog -u'$DATABASE_USER' -p'$DATABASE_PSWD' -e"select LisBitTar from lisans ;"  2> /dev/null |grep -v LisBitTar)" +%s) - $(date --date="$(date +"%Y-%m-%d %T")" +%s))/(60*60*24) ))'
CRYPTOSIM_DESKALGUN='echo $(( ($(date --date="$(mysql cryptolog -u'$DATABASE_USER' -p'$DATABASE_PSWD' -e"select DesBitTar from lisans ;"  2> /dev/null |grep -v DesBitTar)" +%s) - $(date --date="$(date +"%Y-%m-%d %T")" +%s))/(60*60*24) ))'

#Main fonksiyonu burdan itibaren baslıyor.
#Root kontrolu saglar
if [[ "$OSTYPE" == "linux"* ]]; then
     echo "linux"
     if [ "$UID" -ne 0 ]; then
        echo "Please run as root"
	  else
	    UbuntuAndCentos
	  fi    
elif [[ "$OSTYPE" == "cygwin"* ]]; then
     echo "windows"
	    Windows    
elif [[ "$OSTYPE" == "darwin"* ]]; then
     echo "mac"
	    MacOSX    
fi
