cd c:\usr\bin


REM ---- TEST SYSTEM FAN FAILURE

REM SEND TRAP FOR FAN CRIT
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalSystemFanFailed 10.0.0.1 6 6006 "" 
pause

REM SEND TRAP FOR FAN WARN
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalSystemFanDegraded 10.0.0.1 6 6007 ""
pause

REM SEND TRAP FOR FAN OK
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalSystemFanOk 10.0.0.1 6 6008 ""
pause

REM ---- TEST CPU FAN MONITORING 

REM SEND TRAP FOR CPU FAN FAILURE
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalCpuFanFailed 10.0.0.1 6 6009 ""
pause

REM SEND TRAP FOR CPU FAN OK
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalCpuFanOk 10.0.0.1 6 6010 ""
pause


REM ---- TEST CHASSIS TEMP MONITORING 

REM SEND TRAP FOR CHASSIS TEMP FAILURE
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalTempFailed 10.0.0.1 6 6003 ""
pause

REM SEND TRAP FOR CHASSIS TEMP DEGRADED
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalTempDegraded 10.0.0.1 6 6004 ""
pause

REM SEND TRAP FOR CHASSIS TEMP OK
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHeThermalTempOk 10.0.0.1 6 6005 ""
pause


REM ---- TEST MEMORY ERRORS MONITORING 

REM SEND TRAP FOR CORRECTABLE MEMORY ERRORS with 2000 correctable errors occuring
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHe2CorrectableMemoryError 10.0.0.1 6 6001 "" cpqHeCorrMemTotalErrs i "2000"
pause

REM SEND TRAP FOR EXCESSIVE MEMORY ERRORS CAUSING LOG DISABLING
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHe2CorrectableMemoryLogDisabled 10.0.0.1 6 6002 ""
pause


REM ---- TEST POWER SUPPLY MONITORING 

REM SEND TRAP FOR POWER SUPPLY DEGRADED Chassis 1 Bay 3 cpqHeFltTolPowerSupplyChassis cpqHeFltTolPowerSupplyBay
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHe3FltTolPowerSupplyDegraded 10.0.0.1 6 6030 "" cpqHeFltTolPowerSupplyChassis i "1" cpqHeFltTolPowerSupplyBay i "3"
pause

REM SEND TRAP FOR POWER SUPPLY FAILURE Chassis 3 Bay 5
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHe3FltTolPowerSupplyFailed 10.0.0.1 6 6031 "" cpqHeFltTolPowerSupplyChassis i "3" cpqHeFltTolPowerSupplyBay i "5"
pause

REM SEND TRAP FOR POWER SUPPLY REDUNDANCY LOST Chassis 5
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyLost 10.0.0.1 6 6032 "" cpqHeFltTolPowerSupplyChassis i "5"
pause

REM SEND TRAP FOR POWER SUPPLY REPLACED  Chassis 99 bay 65
snmptrap -v 1 -c public 127.0.0.1 CPQHLTH-MIB::cpqHe3FltTolPowerSupplyInserted 10.0.0.1 6 6033 "" cpqHeFltTolPowerSupplyChassis i "99" cpqHeFltTolPowerSupplyBay i "65"
pause

cd c:\usr\bin\scripts
