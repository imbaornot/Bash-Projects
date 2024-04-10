#!/bin/bash

HOME=$(pwd)

#variable for color
R="\e[31m"
E="\e[0m"
G="\e[32m"
C="\e[36m"
P="\e[35m"
O="\e[33m"
LR="\e[1;31m"
LP="\e[1;35m"
LB="\e[1;34m"
LC="\e[1;36m"

#variable that contains array for loop
SERVICES="ftp smb ssh telnet"

#variable with name holer to run the nmap nse scripts
SCRIPT1="ftp-brute.nse"
SCRIPT2="ssh-brute.nse"
SCRIPT3="smb-brute.nse"
SCRIPT4="telnet-brute.nse"

#scans the network and looking for weak passwords
function BASIC()
{
	echo -e "[${O}!${E}] Using Basic Version."
sleep 1 
	echo "[?] Type The Network Name"
		read NAME
	echo "[?] Type The Network IP"
		read NETWORK
	
	#Makes The Folder
	mkdir -p $HOME/Scan/$NAME
	
	echo -e "Scan Date :\n $(date)" >> $HOME/Scan/$NAME/Scan_Date.txt
	
	#scans hosts that are up	
	nmap $NETWORK -sn | grep for | awk '{print $5}' >> $HOME/Scan/$NAME/Active_Hosts.txt
	GATEWAY=$(route -n | awk '{print $2}' | head -3 | tail -1)
	grep -v "$GATEWAY" $HOME/Scan/$NAME/Active_Hosts.txt > $HOME/Scan/$NAME/Live_Hosts.txt
	
	echo -e "[${R}!${E}] Scanning About To Start , The Scan ${LR}Might Take A While${E} Please Stand By."
	echo ""
	#TCP Port Scanning
	for N in $(cat $HOME/Scan/$NAME/Live_Hosts.txt | awk '{print $1}')
	do

	mkdir $HOME/Scan/$NAME/$N
	echo ""
	
	echo -e "[!] Scanning IP : ${LC}$N${E}" 
	nmap $N -sV -T3 -p- >> $HOME/Scan/$NAME/$N/Results_$N.txt
	
	cat $HOME/Scan/$NAME/$N/Results_$N.txt | grep -w "open" >> $HOME/Scan/$NAME/$N/OP_$N.txt
		echo -e "[${G}+${E}] Checking Common Services."	
			
			if [ ! -s "$HOME/Scan/$NAME/$N/OP_$N.txt" ]; then
			echo -e "[${R}X${E}]No Open Port's Found"
		fi
		
		# Initialize an array to keep track of found services
				SERVICES_FOUND=()

#Check if the following host got the common services 
for SER in $SERVICES
do
    # Check if the service is present
    if grep -q "$SER" "$HOME/Scan/$NAME/$N/OP_$N.txt"; then
        echo -e "[${G}✓${E}] $SER was found" | tee -a  $HOME/Scan/$NAME/$N/open_services.txt
        # Keep track of the services and perform brute-forcing outside the loop
        SERVICES_FOUND+=("$SER")
    fi

done

# Perform brute-forcing for each service found
for SERVICE_FOUND in "${SERVICES_FOUND[@]}"
do
    case "$SERVICE_FOUND" in
        "ftp")
            echo -e "[${G}+${E}] Using ${O}ftp-brute${E} script against the target..."
			nmap $N -Pn --script=$SCRIPT1 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/Scan/$NAME/$N/Ftp_Cred.txt
            ;;
        "ssh")
            echo -e "[${G}+${E}] Using ${O}ssh-brute${E} script against the target..."
            nmap $N -Pn --script=$SCRIPT2 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/Scan/$NAME/$N/Ssh_Cred.txt
            ;;
        "smb")
            echo -e "[${G}+${E}] Using ${O}smb-brute${E} script against the target..."
            nmap $N -Pn --script=$SCRIPT3 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/Scan/$NAME/$N/Smb_Cred.txt
            ;;
        "telnet")
            echo -e "[${G}+${E}] Using ${O}telnet-brute${E} script against the target..."
            nmap $N -Pn --script=$SCRIPT4 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/Scan/$NAME/$N/Telnet_Cred.txt
            ;;
    esac

done
done
echo -e "[${G}✓${E}] ${LB}Scan Complete${E}"
echo""
Quest
}


#Scanning The Network And Extracts CVE's And Looking For Weakpasswords
function FULL()
{
	echo -e "[${O}!${E}] Using Full Version."

sleep 1 
	
	echo "[?] Type The Network Name"
		read NAME
	echo "[?] Type The Network IP"
		read NETWORK
	#makes the folder
	mkdir -p $HOME/F_Scan/$NAME
	
	echo -e "Scan Date :\n $(date)" >> $HOME/F_Scan/$NAME/Scan_Date.txt
	
	#scans hosts that are up and than removing your own route ip	
	nmap $NETWORK -sn | grep for | awk '{print $5}' >> $HOME/F_Scan/$NAME/Active_Hosts.txt
	GATEWAY=$(route -n | awk '{print $2}' | head -3 | tail -1)
	grep -v "$GATEWAY" $HOME/F_Scan/$NAME/Active_Hosts.txt > $HOME/F_Scan/$NAME/Live_Hosts.txt
	
	echo "[!] Scanning About To Start , The Scan Might Take A While Please Stand By."
	echo ""
	#TCP Port Scanning
	for N in $(cat $HOME/F_Scan/$NAME/Live_Hosts.txt | awk '{print $1}')
	do

	mkdir $HOME/F_Scan/$NAME/$N

echo ""

	echo "[!] Scanning $N" 
	
	nmap $N -sV -p- --script=vulners.nse >> $HOME/F_Scan/$NAME/$N/Vul_$N.txt
	
	cat $HOME/F_Scan/$NAME/$N/Vul_$N.txt | grep -w "open" >> $HOME/F_Scan/$NAME/$N/OP_$N.txt
	cat $HOME/F_Scan/$NAME/$N/Vul_$N.txt | grep -iw "CVE" >> $HOME/F_Scan/$NAME/$N/CVE_$N.txt
	echo -e "[${G}+${E}] Checking Common Services."
	
		if [ ! -s "$HOME/F_Scan/$NAME/$N/OP_$N.txt" ]; then
			echo -e "[${R}x${E}]No Open Port's Found"
		fi
		# Initialize an array to keep track of found services
				SERVICES_FOUND=()
#Check if the following host got the common services 
for SER in $SERVICES
do
    # Check if the service is present
    if grep -q "$SER" "$HOME/F_Scan/$NAME/$N/OP_$N.txt"; then
        echo -e "[${G}✓${E}] $SER was found" | tee -a $HOME/F_Scan/$NAME/$N/open_services.txt
        # Keep track of the services and perform brute-forcing outside the loop
        SERVICES_FOUND+=("$SER")
    fi

done

# Perform brute-forcing for each service found
for SERVICE_FOUND in "${SERVICES_FOUND[@]}"
do
    case "$SERVICE_FOUND" in
        "ftp")
            echo -e "[${G}+${E}] Using ${O}ftp-brute${E} against the target..."
            nmap $N -Pn --script=$SCRIPT1 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/F_Scan/$NAME/$N/Ftp_Cred.txt
            ;;
        "ssh")
            echo -e "[${G}+${E}] Using ${O}ssh-brute${E} against the target..."
            nmap $N -Pn --script=$SCRIPT2 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/F_Scan/$NAME/$N/Ssh_Cred.txt
            ;;
        "smb")
            echo -e "[${G}+${E}] Using ${O}smb-brute${E} against the target..."
            nmap $N -Pn --script=$SCRIPT3 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/F_Scan/$NAME/$N/Smb_Cred.txt
            ;;
        "telnet")
            echo -e "[${G}+${E}] Using ${O}telnet-brute${E} against the target..."
            nmap $N -Pn --script=$SCRIPT4 | grep -v "NSE" | grep -v "open" | grep "|" >> $HOME/F_Scan/$NAME/$N/Telnet_Cred.txt
            ;;
    esac

done
done
echo -e "[${G}✓${E}] ${LB}Scan Complete${E}"
echo""
Quest
}




#asking the user which option to pick
#than runs the function that were picked

function Quest()
{
printf ${LP}
figlet Network Scanning Script
printf ${E}
	
	echo -e "${LC}Made by Daniel Kov 🏴‍☠️ 🚩 ${E}"
 
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠾⠛⢉⣉⣉⣉⡉⠛⠷⣦⣄⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠋⣠⣴⣿⣿⣿⣿⣿⡿⣿⣶⣌⠹⣷⡀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠁⣴⣿⣿⣿⣿⣿⣿⣿⣿⣆⠉⠻⣧⠘⣷⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡇⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠈⠀⢹⡇⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⢸⣿⠛⣿⣿⣿⣿⣿⣿⡿⠃⠀⠀⠀⠀⢸⡇⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣷⠀⢿⡆⠈⠛⠻⠟⠛⠉⠀⠀⠀⠀⠀⠀⣾⠃⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣧⡀⠻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠃⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⠿⣦⣄⠀⠀⠀⠀⠀⠀⠀⣀⣴⠟⠁⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣦⠀⠀⠈⠉⠛⠓⠲⠶⠖⠚⠋⠉⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⣠⣾⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⣾⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⢀⣄⠈⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ "
sleep 0.5
	echo -e "[?] Pick Your Choice : \n{${O}basic${E}} scan , {${O}full${E}} scan , {${O}zip${E}} the results , {${R}e${E}}xit"
		read OPTION

case $OPTION in

	basic)
	#calls For (Basic) Function
		BASIC
	
	;;


	full)
	#calls for (FULL) Function
		FULL

	;;

	zip)
		echo""
		echo -e "[${G}+${E}] Zipping The Scan Results :"
		#Zips the result.
		zip -r Full_Scan_Results.zip ./F_Scan &> /dev/null && find . -name Full_Scan_Results.zip
		zip -r Scan_Results.zip ./Scan &> /dev/null && find . -name Scan_Results.zip
		
	;;
	e)
			echo -e "${LR}Exiting${E}"
			exit
	;;

	*)
		echo -e "${LR}wrong input please pick again${E}"
		Quest
	;;
esac
}
#calls for function "Quest"
Quest
