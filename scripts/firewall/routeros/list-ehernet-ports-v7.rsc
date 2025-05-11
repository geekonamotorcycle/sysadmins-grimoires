:put "=== Ethernet Port Summary ==="

# Detect RouterOS version
:local rosVersion [/system resource get version];
:local isROS7 false;
:if ([:find $rosVersion "7."] != 0) do={
    :set isROS7 true;
}

:global safeGet do={
    :local iface $1;
    :local attribute $2;
    :local step $3;
    :local result "";
    :do {
        :set result [/interface ethernet get $iface $attribute];
        :if ([:typeof $result] = "nil" || $result = "") do={
            :return "N/A";
        }
        :return [:tostr $result];
    } on-error={
        :put ("[ERROR] Line " . $step . " failed attribute: " . $attribute);
        :return "ER";
    }
}

:global hasAttribute do={
    :local iface $1;
    :local attribute $2;
    :if ([:len [/interface ethernet print where name=$iface]] > 0) do={
        :if ([:len [/interface ethernet get $iface $attribute]] > 0) do={
            :return true;
        }
    }
    :return false;
}

:foreach port in=[/interface ethernet find] do={
    :local portName [/interface ethernet get $port name];
    :local macAddress [$safeGet $port "mac-address" "22"];
    :local status [$safeGet $port "running" "23"];
    :local comment [$safeGet $port "comment" "24"];
    :local linkStatus "N/A";
    :local type "N/A";

    # Check for link-downs only if the attribute exists
    :if ([$hasAttribute $port "link-downs"]) do={
        :set linkStatus [$safeGet $port "link-downs" "25"];
    }

    # Only try to get type if not ROS 7
    :if (!$isROS7) do={
        :if ([$hasAttribute $port "type"]) do={
            :set type [$safeGet $port "type" "31"];
        }
    }

    :local rxBytes [$safeGet $port "rx-byte" "26"];
    :local txBytes [$safeGet $port "tx-byte" "27"];
    :local speed [$safeGet $port "speed" "28"];
    :local mtu [$safeGet $port "mtu" "29"];
    :local l2mtu [$safeGet $port "l2mtu" "30"];

    :local bridgeName "None";
    :foreach bridge in=[/interface bridge port find where interface=$portName] do={
        :set bridgeName [$safeGet $bridge "bridge" "42"];
    }

    :put "-------------------------------";
    :put ("Port: " . $portName . " | MAC: " . $macAddress . " | Running: " . $status);
    :put ("    Type: " . $type . " | Speed: " . $speed . " | MTU: " . $mtu . " | L2 MTU: " . $l2mtu);
    :put ("    Link-Downs: " . $linkStatus . " | RX: " . $rxBytes . " bytes | TX: " . $txBytes . " bytes");
    :put ("    Bridge: " . $bridgeName);
    :put ("    Comment: " . $comment);
}
:put "=== End of Ethernet Port Summary ==="
