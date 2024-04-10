#!/bin/bash

#made by daniel kov


#var to make the animation happen
Spin=( '|' '/' '-' '\' )

#adding colors to text with echo -e
R="\e[31m"
E="\e[0m"
G="\e[32m"
B="\e[34m"
C="\e[36m"
P="\e[35m"
YG="\e[92m"
echo""
user=$(whoami)
echo "[^_^] Activating second script bip bop" 
echo""
echo "[!] whats your server password : "
 read -s PASS &> /dev/null

echo""

#this function will update the system to prevent error's with installitions
function update()
{
echo -e "[${R}!${E}] Updating the Server to Prevent Error's *"
echo "*first time might take some time to update*"
echo "$PASS" | sudo -S apt update -y  &> /dev/null
sleep 1
echo "$PASS" | sudo -S apt-get upgrade -y &> /dev/null
sleep 1

##program that make locate work.
	echo "$PASS" | sudo -S apt-get install plocate -y &> /dev/null
	sleep 1
##updates the database    
	sleep 1
	sudo updatedb  &> /dev/null
	sleep 1
	echo "$PASS" | sudo -S apt-get install tor -y &> /dev/null

}
update

echo ""


function timecheck()
{
	echo "[+]Server stats : "
	yourip=$(ifconfig  | grep inet | awk '{print $2}' |head -1)
	echo "Server Uptime : $(uptime)"
	echo "Server ip : $(ifconfig  | grep inet | awk '{print $2}' |head -1)"
	whois $yourip | grep "Country:"
}
timecheck

echo ""
sleep 1

#this function will check if nmap is installed on the opreation system and if not , it will install nmap
function nmapcheck()
{
if [ -e "/usr/bin/nmap" ] 
	then
			echo "[#] Nmap Exist"
	
	else 
		 #echo "$PASS" | sudo -S apt-get install nmap &> /dev/null
		 sudo apt-get -y install nmap &> /dev/null
	echo ""
	sleep 1
		echo "[^] Nmap Install Complete"
fi
}
nmapcheck

#this function will check if geoiplookup is installed on the system and if not , it will install it
function geoiplookupcheck()
{

if [ -d "/usr/share/doc/geoip-bin" ]
		then
			echo "[#] Geoiplookup Exist"
		
		else
						
			 sudo apt-get install geoip-bin -y &> /dev/null
			
	sleep 1
			echo "[^] Geoiplookup Install Complete"
fi
	 
}
geoiplookupcheck

#this function will check if the nipe is installed and if not than it will install nipe.
function nipecheck()
{
#using var to locate the nipe folder and easier path
nipepwd=$(locate */nipe | head -1)
	if [ -d "$nipepwd" ]
	then 
		echo "[#] Nipe Exist"
	
	else
		cd ~
		cd /home/$user/Desktop
		echo "$PASS" | sudo -S git clone https://github.com/htrgouvea/nipe &> /dev/null
		sleep 1
					   sudo updatedb
		sleep 1
		cd nipe
		echo "$PASS" | sudo -S cpan install try::Tiny Config::Simple JSON &> /dev/null
		sleep 1
		echo "$PASS" | sudo -S nipe.pl install &> /dev/null
	sleep 1
		echo "[^] Nipe Install Complete"
		
fi
}	
nipecheck


#this function will check if sshpass is installed in the operation system and if not, an install will begin.
function sshpasscheck()
{
sshpcheck=$(which sshpass)
if [ -f "$sshpcheck" ]
	then 
		echo "[#] Sshpass Exist"
	else
		echo "$PASS" | sudo -S apt-get install sshpass &> /dev/null
	sleep 1
		echo "[^] Sshpass Install Complete"
fi
}
sshpasscheck

#adding color to the figlet
printf ${YG}
figlet -f standard Server Checkup Complete
printf ${E}

copy()	
{	
	#echo the text will color's
	echo -e "${G}I${E}${R}n${E}${B}i${E}${C}z${E}${P}e${E}${R}l${E}${B}i${E}${G}z${E}${C}i${E}${B}n${E}${P}g${E} ${B}s${E}${G}t${E}${P}a${E}${R}r${E}${P}t${E}${G}u${E}${R}p${E}${B}s${E}"
	spin &
	#making the pid of this function
	pid=$!
	#creates sequance that count's till 5
	for i in $(seq 1 5)
	do sleep 1
	done
	#kills the Process ID
	kill $pid
	echo ""
}
spin(){
	while [ 1 ] 
	do
	#loops for each arrey
	for i in "${Spin[@]}"
	do
		# n stands for dont create new line , \r resets the line  
		echo -ne "\r$i"
		sleep 0.2
	done
done
}
	
#this function will start nipe service from the folder which the nipe located and will indicate from where the ip.	
function stealth()
{
	#Var command to locate nipe path on the system
	nipepwd=$(locate */nipe | head -1)
	cd ~
	cd $nipepwd
	cd $nipepwd
	sleep 3
	echo "$PASS" | sudo -S perl nipe.pl start 
	sleep 1
	echo "$PASS" | sudo -S perl nipe.pl restart 
	#calling the function copy we wrote above ^
	copy
	
	#using var's to get ip , country .
	ip=$(echo "$PASS" | sudo -S perl nipe.pl status 2> /dev/null | grep "Ip:" | awk '{print $3}')
	countryshort=$(geoiplookup $ip | awk -F "," '{print $1}' | awk '{print $4}')
	countrylong=$(geoiplookup $ip | awk '{print $5}')
	
	
	if [ "$countryshort" == "IL" ]
	then 
		echo "[!] you are not Disguised exiting"
	exit
	
	else
		echo "[+] You are Disguised" 
		echo "[-] Your current ip : *$ip* ."
		echo "[-] Your current country : *$countryshort* = *$countrylong* ." 
fi
}	
stealth	

sleep 1

echo ""

#this function will allow the user to scan ip for open ports operation system and port versions. from single ip and a list
function nmap()
{
	echo "[?] would u like to scan [single/multi] ip's"
	
	read answer
	
	if [ $answer = "single" ] 
	then
	echo "[!] type the ip u would like to scan"
	
	read ip
	
	echo "[?] Pick speed [1~5] 5 might cause problems with scan"
	read speed
	
	echo ""
	echo "[!] scanning the ip"
	
			echo "$PASS" | sudo -S nmap -p- $ip -sV -T$speed -Pn --open -oA /home/$user/Desktop/Scanner/metal &> /dev/null
			
			echo "$PASS" | sudo -S whois $ip >> /home/$user/Desktop/Scanner/targetip.txt 
		echo "[+] Scanning Complete"
	elif [ $answer = "multi" ] 
	then
		echo "insert the full path of your ip list"
		read list
		echo "pick your speed [1~5] speed 5 might cause problems with scan"
		read speed
		echo""
		echo "Scanning the list of ip's"
		
			echo "$PASS" | sudo -S nmap -p- -iL $list -sV -T$speed -Pn --open -oA /home/$user/Desktop/Scanner/MetalMulti &> /dev/null
		   
		echo "scanning complete"
	else
		echo "[!] *Wrong Input* try again"
		nmap

fi
}		
nmap	

#this fucntion will stop nipe service at the end and will delete nipe from your server :)
function FINAL()
{
	nipepwd=$(locate */nipe | head -1)
	cd $nipepwd
	sleep 1
	echo "$PASS" | sudo -S perl nipe.pl stop
	sleep 1
	cd $nipepwd 
	cd ..
	echo "$PASS" | sudo -S chmod 777 nipe 
	sudo rm -rd nipe
	rm -r /home/$user/Desktop/Scanner/ProjectB.sh
	#updating locate database to not show nipe as existing
	sudo updatedb
}
FINAL

exit 10

