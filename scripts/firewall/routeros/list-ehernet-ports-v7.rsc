:foreach port in=[/interface ethernet find] do={
    :local portName [/interface ethernet get $port name]
    :local macAddress [/interface ethernet get $port mac-address]
    :local status [/interface ethernet get $port running]
    :local comment [/interface ethernet get $port comment]
    :local linkStatus [/interface ethernet get $port link-downs]
    :local rxBytes [/interface ethernet get $port rx-byte]
    :local txBytes [/interface ethernet get $port tx-byte]
    :local speed [/interface ethernet get $port speed]
    :local mtu [/interface ethernet get $port mtu]
    :local l2mtu [/interface ethernet get $port l2mtu]
    :local type [/interface ethernet get $port type]

    :local bridgeName ""
    :foreach bridge in=[/interface bridge port find where interface=$portName] do={
        :set bridgeName [/interface bridge port get $bridge bridge]
    }

    :put ("Port: " . $portName . " | MAC: " . $macAddress . " | Running: " . $status)
    :put ("    Type: " . $type . " | Speed: " . $speed . " | MTU: " . $mtu . " | L2 MTU: " . $l2mtu)
    :put ("    Link-Downs: " . $linkStatus . " | RX: " . $rxBytes . " bytes | TX: " . $txBytes . " bytes")
    :put ("    Bridge: " . ([:len $bridgeName] ? $bridgeName : "None"))
    :put ("    Comment: " . $comment)
}