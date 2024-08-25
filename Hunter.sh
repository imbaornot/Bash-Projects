#!/bin/bash

#################################
# Script Made By Daniel Kov		#
#################################

#uses pwd to indicate where the script ran
HOME=$(pwd)
#gets the date 
DATE=$(date)
#used to scan the network with user ip
IPSRC=$(ifconfig | grep inet | head -1 | awk '{print $2}' | awk -F. '{print $1"."$2"."$3"."0"/"24}')

##############################################
# All Logs Will Be Saved To /HuntLogs/Logs   #
##############################################

#color code for coloring
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
LG="\e[1;32m"


#variable for file loop
n=1
#variable for loop 
loop_number=1

printf ${LP}
figlet "Tshark Live Script"
printf ${E}


echo " ___________________"
echo " | _______________ |"
echo " | |$ tshark~~~~~| |"
echo " | |~~~~~~~~~~~~~| |"
echo " | |~~~~~~~~~~~~~| |"
echo " | |~~~~~~~~~~~~~| |"
echo " | |~~~~~~~~~~~~~| |"
echo " |_________________|"
echo "     _[_______]_"
echo " ___[___________]___"
echo "|         [_____] []|__"
echo "|         [_____] []|  \__"
echo "L___________________J     \ \___\/"
echo " ___________________      /\ "
echo "/###################\    (__)"

echo""




#function that downloads ioc lists
function download()
{
	#create dir report
	mkdir $HOME/HuntLogs &> /dev/null
	#create dir for IOC's
	mkdir $HOME/HuntLogs/HuntLogIOC &> /dev/null
	#create dir for logs
	mkdir $HOME/HuntLogs/Logs &> /dev/null
		
		#checks if the ioc list already exists
			if [ -e "$HOME/HuntLogs/HuntLogIOC/IOC2.log" ] 
			then

				echo -e "[${LG}+${E}] IOC list Found"
			
			#if not found downloads
			else 
		
				#downloads the ioc list
				wget https://feeds.dshield.org/top10-2.txt -O $HOME/HuntLogs/HuntLogIOC/IOC2.log &> /dev/null
	
				#extracting the url ioc list from it
				cat $HOME/HuntLogs/HuntLogIOC/IOC2.log | awk '{print $2}' | grep -v "NX" | sort | uniq >> $HOME/HuntLogs/URLIOC.txt 2> /dev/null
			#ends the statement
			fi

			#checks if the ioc list already exist
			if [ -e "$HOME/HuntLogs/HuntLogIOC/hashioc.txt" ] 
			then 
	
			echo -e "[${LG}+${E}] HASH IOC Found"
			#if not found downloads
			else
		
			#downloads hash ioc list
			wget https://raw.githubusercontent.com/Neo23x0/signature-base/master/iocs/hash-iocs.txt -O $HOME/HuntLogs/HuntLogIOC/hashioc.txt 2> /dev/null

			fi


	
}
#calling the function
download

#runs the tshark
while true; do
    echo -e "////// ${LP}Hunter${E} Is *${LG}Live${E}* //////"
    echo -e "[${LG}+${E}] Capturing Network"
    echo -e "[${LG}+${E}] Logs Saved At: $HOME/HuntLogs , Loop number $loop_number" 
		echo ""


    # Declare file names as variables
    pcap_file="LAN_$n.pcap" 
    # Declare file names as variables
    log_file="LAN_$n.log" 


	# Here we capture the packets using Tshark, for 30 seconds, using specific filters, and it will save it into both pcap and log files to use. Note that the filters and fields and duration can and should be diffirent for your needs.
    tshark -i eth0 -a duration:30 -w "$HOME/HuntLogs/$pcap_file" -T fields -e frame.number -e ip.src -e ip.dst -e http.user_agent "net $IPSRC" > "$HOME/HuntLogs/Logs/$log_file" 2>&1 & 
    
    # here we get the PID of the command that was executed, in this case the shark command
    tshark_pid=$!
	
	# Sleep for 30 seconds to allow tshark to capture packets
    sleep 30
	


#function that checks if tshark found mailcious ip					
function Malicious()
{
	echo "Analysing Network: $IPSRC"
	tshark -r $HOME/HuntLogs/$pcap_file -Y 'ip.addr' -T fields -e 'ip.src' -e 'ip.dst' >> $HOME/HuntLogs/HuntLogIOC/newfile$N.txt
		
		cat $HOME/HuntLogs/HuntLogIOC/newfile$N.txt | awk '{print $1,"Accssed",$2}' >> $HOME/HuntLogs/HuntLogIOC/Sorted$N.txt 2> /dev/null
				
			#for ioc list 
			for NETIOC in $(cat $HOME/HuntLogs/HuntLogIOC/IOC2.log | awk '{print $1}')
			#does
			do 	
				#if ip from ioc list found
				if  
					grep -q $NETIOC "$HOME/HuntLogs/HuntLogIOC/newfile$N.txt"
				
				then
					#informs the user the ip that found and saves to logs
					HIP=$(cat "$HOME/HuntLogs/HuntLogIOC/Sorted$N.txt" | grep -w $NETIOC | head -1)
					echo -e "[${LR}!${E}] Warning ${LR}Malicous${E} Ip Detected"	
					echo -e "$DATE: $HIP " | tee -a $HOME/HuntLogs/Logs/MaliciousIP_$n.txt
				
				#ends the if statment
				fi
			#ends the for loop
			done

	#making blank space
	echo""
	
}
#calls the function
Malicious


#function that extracts files found in the monitoring
function FILES()
{
	#variable to use the 1mb delete later on
	LIMIT=1000000
	#makes dir to where files will be downloaded
	mkdir $HOME/HuntLogs/Files 2> /dev/null
		
		#extracts from tshark files found in http , tftp , smb ,imf
		tshark -r $HOME/HuntLogs/$pcap_file --export-objects tftp,$HOME/HuntLogs/Files	&> /dev/null
	
		tshark -r $HOME/HuntLogs/$pcap_file --export-objects http,$HOME/HuntLogs/Files	&> /dev/null
	
		tshark -r $HOME/HuntLogs/$pcap_file --export-objects smb,$HOME/HuntLogs/Files	&> /dev/null
	
		tshark -r $HOME/HuntLogs/$pcap_file --export-objects imf,$HOME/HuntLogs/Files	&> /dev/null
	
	#for loop in dir Files
		for filelong in $(find "$HOME/HuntLogs/Files")
		do
			sleep 0.1
    
			#shortcut for the filename
			fileshort=$(basename "$filelong")
    
			#if statment for extracting size per file
			if [[ -f "$filelong" && $(stat -c%s "$filelong") -ge $LIMIT ]]; then
        
				#removes the files found with higher than 1mb
				rm "$HOME/HuntLogs/Files/$fileshort" && echo -e "[${LG}+${E}] Deleted $fileshort : Larger Than 1mb" | tee -a $HOME/HuntLogs/Logs/RemovedFiles_$n.txt || echo "Error: Failed to delete $fileshort" 
   
			#ends the if statment
			fi

		#ends the for loop
		done

#blank space
echo "" 	

}
#calling the function
FILES

#function that indicates the user if a malicious file found
function FileIOC()
{

	#sorts the ioc list
	cat $HOME/HuntLogs/HuntLogIOC/hashioc.txt | awk '{print $1}' | grep -v "#" | grep -v '^$' | awk -F";" '{print $1}' >> $HOME/HuntLogs/HuntLogIOC/HASHIOC.txt

	#runs md5sum on the dir than saves it to txt report
	md5sum $HOME/HuntLogs/Files/* > $HOME/HuntLogs/HuntLogIOC/File_M5_hash.txt 2> /dev/null
	
	#checks if the hashes were extracted if does , makes a loop 	
	if [ -e $HOME/HuntLogs/HuntLogIOC/File_M5_hash.txt ]
	then
	#for loop that runs on hash ioclist 
	for M5 in $(cat $HOME/HuntLogs/HuntLogIOC/HASHIOC.txt) 
	do
		#if malicious file found
			if 
				grep -q $M5 $HOME/HuntLogs/HuntLogIOC/File_M5_hash.txt 
			then
				#informs the user the file found at which date
				grepout=$(cat $HOME/HuntLogs/HuntLogIOC/File_M5_hash.txt | grep -w $M5)
				echo -e "[${LR}!${E}] Warning ${LR}Malicous${E} file located"
				echo "$DATE: $grepout" | tee -a $HOME/HuntLogs/Logs/MaliciousFiles_$n.txt
			#ends the if statment 
			fi
	#ends the for loop
		done
fi

#blank space
echo""		

}
#calling the function
FileIOC




#function that checks if the tshark found mailcious url
function URLS()
{
	#makes dir for the urls
	mkdir $HOME/HuntLogs/URLS 2> /dev/null
	#extracting with tshark http records
	tshark -r $HOME/HuntLogs/$pcap_file -Y 'http' -T fields -e 'http.host' | grep -v "^$" | sort | uniq > $HOME/HuntLogs/URLS/Url.txt 2> /dev/null
	
		#for url list
		for DN in $(cat $HOME/HuntLogs/URLIOC.txt)
		
		do
			#if malicious url found 
			if 
			grep -q $DN $HOME/HuntLogs/URLS/Url.txt
			
			then
		#informs the user that malicious url found
		echo -e "[${LR}!${E}] Warning ${LR}Malicious${E} Url Detected"
		echo -e "$DATE: $DN" | tee -a $HOME/HuntLogs/Logs/MaliciousUrls_$n.txt
			#ends the if statment
			fi
		#ends the for loop
		done	
}
#calling the function
URLS


# Kill the tshark process
    kill $tshark_pid  2> /dev/null

#note the variables on top. after every loop, it will add +1 to the current value. first loop would be 1.
    ((n++)) 
    #same here
    ((loop_number++)) 

#black space
echo ""

#stops the while true
done

