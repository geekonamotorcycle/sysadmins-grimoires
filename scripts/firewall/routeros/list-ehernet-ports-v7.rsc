:foreach port in=[/interface ethernet find] do={
    :local portName [/interface ethernet get $port name]
    :local macAddress [/interface ethernet get $port mac-address]
    :local status [/interface ethernet get $port running]
    :put ("Port: " . $portName . " | MAC: " . $macAddress . " | Running: " . $status)
}