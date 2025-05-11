:put "=== Ethernet Port Summary ==="

:global safeGet do={
    :local cmd $1;
    :local step $2;
    :local attribute $3;
    :local result "";
    :do {
        :set result [:execute $cmd];
        :if ([:typeof $result] = "nil" || $result = "") do={
            :return "N/A";
        }
        :return [:tostr $result];
    } on-error={
        :put ("[ERROR] Line " . $step . " failed attribute: " . $attribute);
        :return "ER";
    }
}

:foreach port in=[/interface ethernet find] do={
    :local portName [/interface ethernet get $port name];

    :local macAddress [$safeGet ("/interface ethernet get " . $portName . " mac-address") "27" "mac-address"];
    :local status [$safeGet ("/interface ethernet get " . $portName . " running") "28" "running"];
    :local comment [$safeGet ("/interface ethernet get " . $portName . " comment") "29" "comment"];
    :local linkStatus [$safeGet ("/interface ethernet get " . $portName . " link-downs") "30" "link-downs"];
    :local rxBytes [$safeGet ("/interface ethernet get " . $portName . " rx-byte") "31" "rx-byte"];
    :local txBytes [$safeGet ("/interface ethernet get " . $portName . " tx-byte") "32" "tx-byte"];
    :local speed [$safeGet ("/interface ethernet get " . $portName . " speed") "33" "speed"];
    :local mtu [$safeGet ("/interface ethernet get " . $portName . " mtu") "34" "mtu"];
    :local l2mtu [$safeGet ("/interface ethernet get " . $portName . " l2mtu") "35" "l2mtu"];
    :local type [$safeGet ("/interface ethernet get " . $portName . " type") "36" "type"];

    :if ($type = "N/A") do={
        :set type [$safeGet ("/interface get " . $portName . " type") "39" "interface-type"];
    }
    :if ($speed = "N/A") do={
        :set speed [$safeGet ("/interface get " . $portName . " speed") "42" "interface-speed"];
    }

    :local bridgeName "None";
    :foreach bridge in=[/interface bridge port find where interface=$portName] do={
        :set bridgeName [$safeGet ("/interface bridge port get " . $bridge . " bridge") "47" "bridge"];
    }

    :put "-------------------------------";
    :put ("Port: " . $portName . " | MAC: " . $macAddress . " | Running: " . $status);
    :put ("    Type: " . $type . " | Speed: " . $speed . " | MTU: " . $mtu . " | L2 MTU: " . $l2mtu);
    :put ("    Link-Downs: " . $linkStatus . " | RX: " . $rxBytes . " bytes | TX: " . $txBytes . " bytes");
    :put ("    Bridge: " . $bridgeName);
    :put ("    Comment: " . $comment);
}
:put "=== End of Ethernet Port Summary ==="
