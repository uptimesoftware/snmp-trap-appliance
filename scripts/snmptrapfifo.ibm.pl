#!/usr/bin/perl
# A simple trap handler


#AVAILABLE UPTIME MONITORS:
#
#
#


#use strict;
use Switch;

my $oid;
my $val;
my @vars;
my %hash = ();
#my $date = `date '+%Y-%m-%d %H:%M:%S'`;
my $hostname = <STDIN>;
my $ip;
if ( $hostname =~ /^.\d\..\d..\d..\d$/ ) {
   $ip = $hostname;
}else{
   $ip = <STDIN>;
}
my $key;
my $value;

#$date = `date /t`;

#chomp( $date);
chomp( $hostname );
chomp( $ip );


my $TRAP_FILE = "/uptime4/logs/traps.fifo.log";	

while ( my $var = <STDIN> ) {
   @vars = split( / /, $var, 2 );
   $oid = shift( @vars );
   chomp( $oid );
   $val = shift( @vars );
   chomp( $val );
   $hash{ $oid } = $val;
}


open(TRAPFILE, ">> $TRAP_FILE");


# lets get the current date

@f = (localtime)[3..5]; # grabs year/month/day values
#    printf TRAPFILE "%d-%d-%d ", $f[2] + 1900, $f[1] +1,$f[0];

# lets get the current time

@current_time = localtime;
    #print TRAPFILE "$current_time[2]:$current_time[1]:$current_time[0] ";
    # or using an array slice and join...
    #print "\tTime is: ", join(":", @current_time[2,1,0]), "\n";

#print TRAPFILE "$date $ip $hash{ 'SNMPv2-MIB::snmpTrapOID.0' }\n";




#Trap Handler Logic to call the uptime external event handler

#SYSTEM FAN HANDLER
#SNMPv2-SMI::enterprises.232.0.6006.0.6006 (FAN FAIL)

# go through the gambit and figure out what's going on and call the Uptime External Event Monitor Asynchronous Event Updater
switch ($hash{ 'SNMPv2-MIB::snmpTrapOID.0' }) {


my $debug;
$debug = 0;

#define message header for alerts passed back to uptime      
my $messageHeader;
$messageHeader = "$date SERVER IP:$ip SERVER HOSTNAME:$hostname";

my $eventType;
$eventType= "NOT SET";

my $monitorName;
$monitorName= "NOT SET";

  	## --- START POWER SUPPLY MONITORING
   
      
      	
      	case /enterprises.2.6.159.1.1.0.23/ { 
      		
      					$eventType = "IBM Power Supply Event";
      					$monitorName= "IBM Power Supply Monitor";
      		
      					if($debug==1){		print TRAPFILE "$eventType\n"; }
      							
      							#Event 0 - Supply OK -
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.23.4'} == 0 ){
      								if ($debug=1) {print TRAPFILE "$ messageHeader $eventType - Power Supply Status Set to OK }\n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Power supply operation has been restored \" " );
      							}
      							
      							#Event 1 - Supply Failure - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.23.4'} == 1 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - Power Supply Status Set to Critical Failure/Redundancy Lost }\n";;}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader -  $eventType Power Supply Status Set to Critical Failure/Redundancy Lost. \" " );
      							}
      							
      						}	
      						
		## --- END POWER SUPPLY MONITORING
		
		## --- START NIC MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapNetworkAdapterFailed 10.0.0.1 6 26 "" ibmSystemTrapNetworkAdapterFailedSeverity i "0" ibmSystemTrapNetworkAdapterFailedComponentID i "5"
      	
      	case /enterprises.2.6.159.1.1.0.26/ { 
      					
      					$eventType = "IBM NIC Adapter Event";
      					$monitorName= "IBM NIC Monitor";
      					if($debug==1){		print TRAPFILE "$eventType\n"; }
      							
      							#Event 0 - NIC OK -
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.26.4'} == 0 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - NIC Status Set to OK }\n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - NIC operation has been restored for NIC in slot $hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.26.7'}\" " );
      							}
      							
      							#Event 2 - NIC Failure - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.26.4'} == 2 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - NIC Status Set to Critical Failure for slot:  $hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.23.4'}      }\n";;}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - NIC status Set to critical failure for NIC in slot: $hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.26.7'}\" " );
      							}
      							
      						}	
      						
		## --- END NIC MONITORING
		## --- START TEMPERATURE MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapNetworkAdapterFailed 10.0.0.1 6 26 "" ibmSystemTrapNetworkAdapterFailedSeverity i "0" ibmSystemTrapNetworkAdapterFailedComponentID i "5"
      	
      	case /enterprises.2.6.159.1.1.0.2/ { 
      					
      					$eventType = "IBM Temperature Monitor Event";
      					$monitorName= "IBM Temperature Monitor";
      					$deviceName=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.2.3'});
      					
      					if($debug==1){		print TRAPFILE "$eventType\n"; }
      							
      							#Event 0 - TEMP OK -
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.2.4'} == 0 ){
      								if ($debug==1) {print TRAPFILE "/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature OK for device: $deviceName \" \n" ;}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature OK for device: $deviceName \" " );
      							}
      							
      							#Event 1 - TEMP Warning - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.2.4'} == 1 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType\n";;}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature WARN for device: $deviceName \" " );
      							}
      							
      							#Event 2 - TEMP Critical - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.2.4'} == 2 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - Temperature  Critical Failure for device:  $deviceName      }\n";;}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature CRITICAL for device: $deviceName \" " );
      							}
      						
      						
      						
      						}	
      						
		## --- END TEMPARATURE MONITORING
		## --- START FAN MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapFan 10.0.0.1 6 5 "" ibmSystemTrapFanSeverity i "0" ibmSystemTrapFanAlertingManagedElement s "Chassis"
      	
      	case /enterprises.2.6.159.1.1.0.5/ { 
      					
      					$eventType = "IBM Fan Monitor Event";
      					$monitorName= "IBM Fan Monitor";
      					$deviceName=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.5.3'});
      					
      					if($debug==1){		print TRAPFILE "$eventType\n"; }
      							
      							#Event 0 - FAN OK -
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.5.4'} == 0 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - FAN Status Set to OK \n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - FAN OK for device: $deviceName \" " );
      							}
      							
      							#Event 1 - FAN Warning - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.5.4'} == 1 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - FAN Status Set to WARN\n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - FAN WARN for device: $deviceName \" " );
      							}
      							
      							#Event 2 - FAN Critical - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.5.4'} == 2 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - FAN Status Set to Critical.\n";;}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - FAN CRITICAL for device: $deviceName \" " );
      							}
      						
      						
      						
      						}	
      						
		## --- END FAN MONITORING

		## --- START HARD DISK MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapSMART 10.0.0.1 6 9 "" ibmSystemTrapSMARTSeverity i "0" ibmSystemTrapSMARTAlertingManagedElement s "Disk 0"
      	
      	case /enterprises.2.6.159.1.1.0.9/ { 
      					
      					$eventType = "IBM Disk SMART Monitor Event";
      					$monitorName= "IBM Disk SMART Monitor";
      					$deviceName=&noQuotes($hash{'SNMPv2-SMI::enterprises.2.6.159.1.1.0.9.3'});
      					
      					#print TRAPFILE "\n--> $deviceName\n";
      					
      					if($debug==1){		print TRAPFILE "$eventType\n"; }
      							
      							#Event 0 - DISK OK -
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.9.4'} == 0 ){
      								if ($debug==1) {print TRAPFILE "/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Disk Reports SMART STATUS OK for device: $deviceName \" ";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Disk SMART STATUS OK device: $deviceName \" " );
      							
      							}
      							
      							#Event 2 - DISK FAILURE IMMINENT - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.9.4'} == 2 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - DISK Status Set to CRITICAL\n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Disk Reports SMART STATUS Critical for device: $deviceName \" " );
      							}
      												
      						
      						}	
      						
		## --- END HARD DISK MONITORING
		
		## --- START MEMORY MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapSMART 10.0.0.1 6 9 "" ibmSystemTrapSMARTSeverity i "0" ibmSystemTrapSMARTAlertingManagedElement s "Disk 0"
      	
      	case /enterprises.2.6.159.1.1.0.35/ { 
      					
      					$eventType = "IBM Memory Monitor Event";
      					$monitorName= "IBM Memory Monitor";
      					$deviceName=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.35.3'});
      					
      					if($debug==1){print TRAPFILE "$eventType\n"; }
      							
      							#Event 0 - MEMORY OK -
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.35.4'} == 0 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - MEMORY Status Set to OK \n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Physical Memory Device Reports STATUS OK for device: $deviceName \" " );
      							}
      							
      							#Event 1 - MEMORY FAILURE IMMINENT - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.35.4'} == 1 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - MEMORY Status Set to WARN\n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Physical Memory Device Reports STATUS WARN for device: $deviceName \" " );
      							}
      							
      							#Event 2 - MEMORY FAILURE IMMINENT - 
      							
      							if ($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.35.4'} == 2 ){
      								if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - MEMORY Status Set to CRITICAL\n";}
      								system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Physical Memory Device Reports STATUS CRITICAL for device failure imminent: $deviceName \" " );
      							}
      												
      						
      						}	
      						
		## --- END MEMORY MONITORING
		
		

				
		## --- START CATCHALL For this file		
				
				else { 
  							if ($debug==1) {print TRAPFILE "NO MATCH IN IBM HARDWARE MIB - DEAD TRAP" }
  						
  						}
		## -- END CATCHALL FOR THIS FILE
}





#let's get the date and time from the system instead because it reacts right when the trap is received



#print(TRAPFILE "New trap received: $date for $OID\n\nHOST: $host\nIP: $ip\n");
#foreach(@vars) {
#        print(TRAPFILE "TRAP: $_\n");
#}
#print(TRAPFILE "\n----------\n");
close(TRAPFILE);


sub noQuotes(){ 

   #-------------------------------------------------------------------#
   #  two possible input arguments - $promptString, and $defaultValue  #
   #  make the input arguments local variables.                        #
   #-------------------------------------------------------------------#

	my $inputStr;
	my $newString;

	$inputStr=@_[0];

        #print "$inputStr\n" ;

	$newString = substr $inputStr, 0 , -1;
	$newString = substr $newString, 1;
		
	return $newString;	
}

