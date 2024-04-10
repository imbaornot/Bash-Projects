#!/bin/bash

#made by daniel kov 

#adding colors to text with echo -e
R="\e[31m"
E="\e[0m"
G="\e[32m"
B="\e[34m"
C="\e[36m"
P="\e[35m"

#using var EXILE as $(whoami) to set a user
EXILE=$(whoami)

#var to set the default home for me to use
home=/home/$(whoami)/Desktop

#var to make the animation happen
Spin=( '|' '/' '-' '\' )


echo ███████████████████████████
echo ███████▀▀▀░░░░░░░▀▀▀███████
echo ████▀░░░░░░░░░░░░░░░░░▀████
echo ███│░░░░░░░░░░░░░░░░░░░│███
echo ██▌│░░░░░░░░░░░░░░░░░░░│▐██
echo ██░└┐░░░░░░░░░░░░░░░░░┌┘░██
echo ██░░└┐░░░░░░░░░░░░░░░┌┘░░██
echo ██░░┌┘▄▄▄▄▄░░░░░▄▄▄▄▄└┐░░██
echo ██▌░│██████▌░░░▐██████│░▐██
echo ███░│▐███▀▀░░▄░░▀▀███▌│░███
echo ██▀─┘░░░░░░░▐█▌░░░░░░░└─▀██
echo ██▄░░░▄▄▄▓░░▀█▀░░▓▄▄▄░░░▄██
echo ████▄─┘██▌░░░░░░░▐██└─▄████
echo █████░░▐█─┬┬┬┬┬┬┬─█▌░░█████
echo ████▌░░░▀┬┼┼┼┼┼┼┼┬▀░░░▐████
echo █████▄░░░└┴┴┴┴┴┴┴┘░░░▄█████
echo ███████▄░░░░░░░░░░░▄███████
echo ██████████▄▄▄▄▄▄▄██████████

echo "Welcome let the show begin"
echo ""
sleep 1

echo "[?] Hello the following script will need your user password to work fluently."
sleep 1
echo "[!] please insert your password :"

read -s PASS

echo ""

#this function will update the system to prevent error's with installitions
function update()
{
echo -e "[${R}!${E}] Updating the machine to prevent error's"
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
	#installs tor to make nipe work
	echo "$PASS" | sudo -S apt-get install tor -y &> /dev/null

}
update

echo ""

#this function will check if exe nmap is installed on the opreation system and if not , it will install nmap
function nmapcheck()
{
if [ -e "/usr/bin/nmap" ] 
	then
			echo "[#] Nmap Exist"

	else 
		 sudo apt-get -y install nmap &> /dev/null
	echo ""
	sleep 1
		echo "[^] Nmap Install Complete"
fi
}
nmapcheck

sleep 1
#this function will check if directory geoip-bin exist 
function geoiplookupcheck()
{

if [ -d "/usr/share/doc/geoip-bin" ]
		then
			echo "[#] Geoiplookup Exist"
		
		else
						
			 echo "$PASS" sudo -S apt-get install geoip-bin -y &> /dev/null
			
	sleep 1
			echo "[^] Geoiplookup Install Complete"
fi
	 
}
geoiplookupcheck

#this function will check if the nipe is installed and if not than it will install nipe.
function nipecheck()
{
#using var to locate the nipe folder and easier path
nipepwd=$(locate */nipe)
	if [ -d "$nipepwd" ]
	then 
		echo "[#] Nipe Exist"
	
	else
		cd ~
		cd /home/$EXILE/Desktop
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
printf ${G}
figlet -f standard Checkup Complete
printf ${E}
sleep 1
	
	
	
copy()	
{	
	#echo the text will color's
	echo -e "${R}I${E}${G}n${E}${C}i${E}${B}z${E}${P}e${E}${R}l${E}${B}i${E}${G}z${E}${C}i${E}${B}n${E}${P}g${E} ${B}s${E}${G}t${E}${P}a${E}${R}r${E}${P}t${E}${G}u${E}${R}p${E}${B}s${E}"
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
		# n stands for dont create new line , \r resets the lines 
		echo -ne "\r$i"
		sleep 0.2
	done
done
}


#this function will start nipe service from the folder which the nipe located and will indicate from where the ip.	
function stealth()
{
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
#this section will ask about the login info required to start ssh connection.
		echo "[!] please insert the server ip u want to enter : "

		read usrip

	echo "[!] SSH Username :"
		read user

	echo "[!] SSH Password : "
		read -s PASSWORD
 
#this function will establish connection with the server 
function SSHConnect()
{
 
	sleep 1
	sshpass -p "$PASSWORD" ssh -o stricthostkeychecking=no  $user@$usrip  'cd /home/'$user'/Desktop ; mkdir /home/'$user'/Desktop/Scanner' &> /dev/null
    sshpass -p "$PASSWORD" scp -o stricthostkeychecking=no /home/$EXILE/Desktop/ProjectB.sh $user@$usrip:/home/$user/Desktop/Scanner 
	sshpass -p "$PASSWORD" ssh -o stricthostkeychecking=no  $user@$usrip 'cd /home/'$user'/Desktop/Scanner ; bash /home/'$user'/Desktop/Scanner/ProjectB.sh'
}	
SSHConnect

sleep 1

#this function will copy from the server the scan log , and will remove the folder from the server.
function ENDGAME()
{
	cd $home
	mkdir RemoteResults &> /dev/null
	sshpass -p "$PASSWORD" scp -ro stricthostkeychecking=no $user@$usrip:/home/$user/Desktop/Scanner /home/$EXILE/Desktop/RemoteResults
	sshpass -p "$PASSWORD" ssh -o stricthostkeychecking=no $user@$usrip 'cd /home/'$user'/Desktop ; rm -r Scanner'
}
ENDGAME

exit
#Thank you for using my stealth scan script . good bye bip bop
