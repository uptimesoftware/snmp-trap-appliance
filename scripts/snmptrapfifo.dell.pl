#!/usr/bin/perl
# HP TRAP HANDLER FOR UPTIME 


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
   
    	#TRAP: SNMPv2-SMI::enterprises.232.6.2.9.3.1.1 1 (Chassis number)
   			#TRAP: SNMPv2-SMI::enterprises.232.6.2.9.3.1.2 3 (Bay number)
      	
      	#SERVER POWER SUPPLY FAILURE
      	case /.1.3.6.1.4.1.674.10892.1.0.1354/ { 
      		
      		$eventType = "Dell Poweredge Power Supply Event";
      		$monitorName= "Dell Power Supply Monitor";
      		$psIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to CRIT \n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The fault tolerant power supply condition has been set to failed for the specified index: $psIndex \"" );
      	
      	}
      	
  			#SERVER POWER SUPPLY DEGRADED
      	case /.1.3.6.1.4.1.674.10892.1.0.1353/ { 
      		
      		$eventType = "Dell Poweredge Power Supply Event";
      		$monitorName= "Dell Power Supply Monitor";
      		$psIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to WARN \n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The fault tolerant power supply condition has been set to failed for the specified index: $psIndex \ \"" );
      		
      	}
				
				#SERVER POWER SUPPLY OK
      	case /.1.3.6.1.4.1.674.10892.1.0.1352/ { 
      		
      		$eventType = "Dell Poweredge Power Supply Event";
      		$monitorName= "Dell Power Supply Monitor";
      		$psIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to OK\n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The Fault Tolerant Power Supplies have lost redundancy for the specified index: $psIndex \"" );
      		
      	}
      												
		## --- END POWER SUPPLY MONITORING
		
		## --- START NIC MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapNetworkAdapterFailed 10.0.0.1 6 26 "" ibmSystemTrapNetworkAdapterFailedSeverity i "0" ibmSystemTrapNetworkAdapterFailedComponentID i "5"
      	
      	#Broadcom NIC Failover has occoured (warn)
      	case /.1.3.6.1.4.1.4413.1.2.3.0.1/ { 
      		
      		$eventType = "Dell Broadcom Network Interface Monitor Event";
      		$monitorName= "Dell Broadcom Network Interface Monitor";
      		$interfaceName= &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.4413.1.2.3.1'});
      		      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Network Event Failover\n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - the network interface named $interfaceName has experienced a failover event. \"" );
      		
      	}
      						
		## --- END NIC MONITORING

		## --- START TEMPERATURE MONITORING
   		
   		#TEMPERATURE CRITICAL THERMAL SHUTDOWN
      case /.1.3.6.1.4.1.674.10892.1.0.1004/ { 
      					
      					$eventType = "Dell Temperature Monitor Event";
      					$monitorName= "Dell Temperature Monitor";
    							
      					
      					if ($debug==1) {print TRAPFILE "$messageHeader $eventType - DELL TEMP Status Set to CRIT \n";}
      					system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Thermal protection initiated on this system, the system is going down. \" " );
      							
      						}
      
      #TEMPERATURE CRITICAL 
      case /.1.3.6.1.4.1.674.10892.1.0.1054/ { 
      					
      					$eventType = "Dell Temperature Monitor Event";
      					$monitorName= "Dell Temperature Monitor";
    							
      					
      					if ($debug==1) {print TRAPFILE "$messageHeader $eventType - DELL TEMP Status Set to CRIT \n";}
      					system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature status on one or more temperature probes in the system is set to failure. \" " );
      							
      						}
      
      
      #TEMPERATURE WARN					
      case /.1.3.6.1.4.1.674.10892.1.0.1053/ { 
      	
      					$eventType = "Dell Temperature Monitor Event";
      					$monitorName= "Dell Temperature Monitor";
    						
    						#$deviceName=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.2.3'});
      		
      					if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CHASSIS TEMP Status Set to WARN \n";}
      					system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature status on one or more temperature probes in the system is set to warning.  \" " );
      	
      
      						}
   		#TEMPERATURE OK					
      case /.1.3.6.1.4.1.674.10892.1.0.1052/ { 
      	
    						$eventType = "Dell Temperature Monitor Event";
      					$monitorName= "Dell Temperature Monitor";
    							
      						if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CHASSIS TEMP Status Set to OK \n";}
      						system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Temperature status on one or more temperature probes in the system is set to ok.  \" " );
      	
      						}
      									
		## --- END TEMPERATURE MONITORING
		
		## --- START COOLING DEVICE MONITORING
   
      
      #Cooling Device FAILURE
      case /.1.3.6.1.4.1.674.10892.1.0.1104/ { 
      							
      							$eventType = "Dell Cooling Device Monitor Event";
      							$monitorName= "Dell Cooling Device";
      							$coolingIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      							
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - cooling device status set to FAILURE \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - A cooling device with the index $coolingIndex has failed in this system.\" " );
      							
      						}
      #Cooling Device WARN
      case /.1.3.6.1.4.1.674.10892.1.0.1103/ { 
      							
      							$eventType = "Dell Cooling Device Monitor Event";
      							$monitorName= "Dell Cooling Device";
      							$coolingIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      							
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - cooling device status set to WARN \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - A cooling device with the index $coolingIndex has entered a warning state in this system. \" " );
      							
      						
      						}
      #Cooling device OK
      case /.1.3.6.1.4.1.674.10892.1.0.1102/ {
      	
      							
      							$eventType = "Dell Cooling Device Monitor Event";
      							$monitorName= "Dell Cooling Device";
      							$coolingIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      												
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - cooling device status set to OK \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - A cooling device with the index $coolingIndex has returned to a normal state in this system. \" " );
      							
      						
      						}
  
      ## -- END SYSTEM FAN MONITOR	
      
     

		## --- START HARD DISK MONITORING
   
   		#Open Manage Array Manager MUST be running
   		
   		#Array Disk Failure
      	case /.1.3.6.1.4.1.674.10893.1.20.200.0.904/ { 
      		
      		$eventType = "Dell Disk Array Manager Monitor Event";
      		$monitorName= "Dell Disk Array Manager Monitor";
      		$diskName= &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10893.1.20.200.4.'});
      		$descriptionEvent =  &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10893.1.20.200.2'});
      		      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Disk Failure\n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - System has experienced a disk failure in disk $diskName with the event described as $eventDescription by the server. \"" );
      		
      	}

				#Array Disk Warn
      	case /.1.3.6.1.4.1.674.10893.1.20.200.0.903/ { 
      		
      		$eventType = "Dell Disk Array Manager Monitor Event";
      		$monitorName= "Dell Disk Array Manager Monitor";
      		$diskName= &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10893.1.20.200.4'});
      		$descriptionEvent =  &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10893.1.20.200.2'});
      		      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Disk Warning\n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - System has experienced a disk warning in disk $diskName with the event described as $eventDescription by the server. \"" );
      		
      	}
      	
      	#Array Disk OK
      	case /.1.3.6.1.4.1.674.10893.1.20.200.0.902/ { 
      		
      		$eventType = "Dell Disk Array Manager Monitor Event";
      		$monitorName= "Dell Disk Array Manager Monitor";
      		$diskName= &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10893.1.20.200.4'});
      		$descriptionEvent =  &noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10893.1.20.200.2'});
      		      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Disk OK\n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - System has experienced a disk recovery in disk $diskName with the event described as $eventDescription by the server. \"" );
      		
      	}
   
      #NOT YET IMPLEMENTED FOR Dell (Requires Dell Open Manager)
      
		## --- END HARD DISK MONITORING
		
		## --- START MEMORY MONITORING
   
      
      #SERVER MEMORY WARNING
      case /.1.3.6.1.4.1.674.10892.1.0.1403/ { 
			      	
			      		$eventType = "Dell Memory Error Monitor Event";
      					$monitorName= "Dell Memory Error Monitor";
      					$memoryIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      					
      							
      						if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - MEMORY Status Set to WARN \n";}
      						system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - A correctable memory error occurred. The error has been corrected. The memory device in the system has an index of $memoryIndex \" " );		
      							
      						}
  		
  		#SERVER MEMORY FAILURE
      case /.1.3.6.1.4.1.674.10892.1.0.1404/ {
      			
      					$eventType = "Dell Memory Error Monitor Event";
      					$monitorName= "Dell Memory Error Monitor";
      					$memoryIndex=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.1.3.6.1.4.1.674.10892.1.5000.10.2'});
      							
      						if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - MEMORY Status Set to CRIT \n";}
      						system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The frequency of errors is so high that the error tracking logic has been temporarily disabled. The last known number of errors is $numErrors \" " );		
      						
      	
      						}
      						
		## --- END MEMORY MONITORING
		
		

				
		## --- START CATCHALL For this file		
				
				else { 
  							if ($debug==1) {print TRAPFILE "NO MATCH IN HP HARDWARE MIB - DEAD TRAP" }
  						
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

