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

				
      	
      	
      	#SERVER POWER SUPPLY DEGRADED
      	case /.1.3.6.1.4.1.232.0.6030/ { 
      		
      		$eventType = "HP Power Supply Event";
      		$monitorName= "HP Power Supply Monitor";
      		$chassisNumber=&noQuotes($hash{ 'NMPv2-SMI::enterprises.232.6.2.9.3.1.1'});
      		$bayNumber=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.232.6.2.9.3.1.2'});
      		
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to WARN \n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The fault tolerant power supply condition has been set to degraded for the specified chassis and bay location. Chassis Number: $chassisNumber Bay Number: $bayNumber \"" );
      	
      	}
      	
  			#SERVER POWER SUPPLY FAILURE
      	case /.1.3.6.1.4.1.232.0.6031/ { 
      		
      		$eventType = "HP Power Supply Event";
      		$monitorName= "HP Power Supply Monitor";
      		$chassisNumber=&noQuotes($hash{ 'NMPv2-SMI::enterprises.232.6.2.9.3.1.1'});
      		$bayNumber=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.232.6.2.9.3.1.2'});
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to CRIT \n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The fault tolerant power supply condition has been set to failed for the specified chassis and bay location. Chassis Number: $chassisNumber Bay Number: $bayNumber \"" );
      		
      	}
				
				#SERVER POWER SUPPLY REDUNDANCY LOST
      	case /.1.3.6.1.4.1.232.0.6032/ { 
      		
      		$eventType = "HP Power Supply Event";
      		$monitorName= "HP Power Supply Monitor";
      		$chassisNumber=&noQuotes($hash{ 'NMPv2-SMI::enterprises.232.6.2.9.3.1.1'});
      		$bayNumber=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.232.6.2.9.3.1.2'});
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to WARN \n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The Fault Tolerant Power Supplies have lost redundancy for the specified chassis. Chassis Number: $chassisNumber Bay Number: $bayNumber \"" );
      		
      	}
      											
      	#SERVER POWER SUPPLY REPLACED
      	case /.1.3.6.1.4.1.232.0.6033/ {
      		
      		$eventType = "HP Power Supply Event";
      		$monitorName= "HP Power Supply Monitor";
      		$chassisNumber=&noQuotes($hash{ 'NMPv2-SMI::enterprises.232.6.2.9.3.1.1'});
      		$bayNumber=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.232.6.2.9.3.1.2'});
      		
      		if ($debug==1) {print TRAPFILE "$messageHeader $eventType - Power Supply Status Set to CRIT \n";}
      		system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - A Fault Tolerant Power Supply has been inserted into the specified chassis and bay location. Chassis Number: $chassisNumber Bay Number: $bayNumber \"" );
      		
      	}
      						
		## --- END POWER SUPPLY MONITORING
		
		## --- START NIC MONITORING
   
      	#snmptrap -v 1 -c public 10.1.4.178 IBM-SYSTEM-TRAP-MIB::ibmSystemTrapNetworkAdapterFailed 10.0.0.1 6 26 "" ibmSystemTrapNetworkAdapterFailedSeverity i "0" ibmSystemTrapNetworkAdapterFailedComponentID i "5"
      	
      	#NOT IMPLEMENTED
      						
		## --- END NIC MONITORING
		## --- START TEMPERATURE MONITORING
   		
   		#CHASSIS TEMPERATURE CRITICAL
      case /.1.3.6.1.4.1.232.0.6003/ { 
      					
      					$eventType = "HP Chassis Temperature Monitor Event";
      					$monitorName= "HP Chassis Temperature Monitor";
    							
      					
      					if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CHASSIS TEMP Status Set to CRITICAL \n";}
      					system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The temperature status has been set to failed. The system will be shutdown due to this thermal condition. \" " );
      							
      						}
      #CHASSIS TEMPERATURE WARN					
      case /.1.3.6.1.4.1.232.0.6004/ { 
      	
      					$eventType = "HP Chassis Temperature Monitor Event";
      					$monitorName= "HP Chassis Temperature Monitor";
    						#$deviceName=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.2.6.159.1.1.0.2.3'});
      		
      					if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CHASSIS TEMP Status Set to WARN \n";}
      					system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The temperature status has been set to degraded. The server's temperature is outside of the normal operating range.  The server will be shutdown if the temperature status fails. \" " );
      	
      
      						}
   		#CHASSIS TEMPERATURE OK					
      case /.1.3.6.1.4.1.232.0.6005/ { 
      	
      						$eventType = "HP Chassis Temperature Monitor Event";
      						$monitorName= "HP Chassis Temperature Monitor";
    							
      						if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CHASSIS TEMP Status Set to OK \n";}
      						system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The temperature status has been set to degraded. The temperature status has been set to ok. The server's temperature has returned to the normal operating range. \" " );
      	
      						}
      									
		## --- END TEMPARATURE MONITORING
		
		## --- START FAN MONITORING
   
   		## -- START SYSTEM FAN MONITOR
      
      #SYSTEM FAN FAILURE
      case /.1.3.6.1.4.1.232.0.6006/ { 
      							
      							$eventType = "HP System Fan Monitor Event";
      							$monitorName= "HP System Fan Monitor";
      							
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - FAN Status Set to FAILURE \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - Required fan not operating normally.  Shutdown may occur. \" " );
      							
      						}
      #SYSTEM FAN WARN
      case /.1.3.6.1.4.1.232.0.6007/ { 
      							
      							$eventType = "HP System Fan Monitor Event";
      							$monitorName= "HP System Fan Monitor";
      							
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - FAN Status Set to WARN \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The system fan status has been set to degraded. An optional system fan is not operating normally. \" " );
      							
      						
      						}
      #SYSTEM FAN OK
      case /.1.3.6.1.4.1.232.0.6008/ { print TRAPFILE "$date SERVER IP:$ip SERVER HOSTNAME:$hostname - The system fan status has been set to ok. Any previously non-operational system fans have returned to normal operation.\n"; 
      							
      							$eventType = "HP System Fan Monitor Event";
      							$monitorName= "HP System Fan Monitor";
      							
      							system("/perl/bin/perl /usr/bin/scripts/extevent.pl --status=\"0\" --monitorName=\"Enterprise HP CHASSIS FAN Status Monitor\" --message=\"SERVER IP:$ip SERVER HOSTNAME:$hostname - The system fan status has been set to ok. Any previously non-operational system fans have returned to normal operation.\"" );
      							
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - FAN Status Set to OK \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - he system fan status has been set to ok. Any previously non-operational system fans have returned to normal operation. \" " );
      							
      						
      						}
  
      ## -- END SYSTEM FAN MONITOR	
      
      ## -- START CPU FAN MONITOR
    
      
      #CPU FAN FAILURE
      case /.1.3.6.1.4.1.232.0.6009/ { 
      	
      							$eventType = "HP CPU Fan Monitor Event";
      							$monitorName= "HP CPU Fan Monitor";
      			
      							if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CPU FAN Status Set to FAILED \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"2\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The CPU fan status has been set to failed. A processor fan is not operating normally.  The server will be shutdown. \" " );
      							
      						}

      #CPU FAN OK						
     	case /.1.3.6.1.4.1.232.0.6010/ { 
     		
     								$eventType = "HP CPU Fan Monitor Event";
      							$monitorName= "HP CPU Fan Monitor";
     	
     								if ($debug==1) {print TRAPFILE "$messageHeader $eventType - CPU FAN Status Set to OK \n";}
      							system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"0\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - The CPU fan status has been set to ok. Any previously non-operational processor fans have returned to normal operation. \" " );
      						
      						}

      
      ## --  END CPU FAN MONITOR
      
    						
		## --- END FAN MONITORING

		## --- START HARD DISK MONITORING
   
      #NOT YET IMPLEMENTED FOR HP
      						
		## --- END HARD DISK MONITORING
		
		## --- START MEMORY MONITORING
   
      	
      #SNMPv2-SMI::enterprises.232.6.2.3.3 = number of errors (cpqHeCorrMemTotalErrs)
      case /.1.3.6.1.4.1.232.0.6001/ { 
			      	
			      		$eventType = "HP Server MEMORY ERRORS Monitor Event";
      					$monitorName= "HP Memory Monitor";
      					$numErrors=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.232.6.2.3.3'});
      							
      						if ($debug==1) {print TRAPFILE "$ messageHeader $eventType - MEMORY Status Set to WARN \n";}
      						system("/usr/bin/perl /uptime4/scripts/extevent.pl --status=\"1\" --monitorName=\"$monitorName\" --message=\"$messageHeader - $eventType - A correctable memory error occurred. The error has been corrected.  The current number of correctable memory errors is reported in the variable cpqHeCorrMemTotalErrs= $numErrors \" " );		
      							
      						}
  		#SERVER EXCESSIVE MEMORY ERRORS
      case /.1.3.6.1.4.1.232.0.6002/ {
      			
      					$eventType = "HP Server MEMORY ERRORS Monitor Event";
      					$monitorName= "HP Memory Monitor";
      					$numErrors=&noQuotes($hash{ 'SNMPv2-SMI::enterprises.232.6.2.3.3'});
      							
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

