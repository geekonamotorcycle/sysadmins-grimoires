# This script generates a summary of all ethernet ports on a MikroTik device.
# It includes details such as port name, MAC address, running status, speed, MTU, L2 MTU, link-down count, bridge association, and comments.
# The script dynamically detects the RouterOS version (6 or 7) and adjusts its behavior accordingly.
# SafeGet is a robust function that attempts to retrieve an attribute and handles errors by returning "ER" for failure or "N/A" for a missing value.
# The script also checks for the presence of attributes before attempting to retrieve them.
# This structure ensures compatibility with both RouterOS 6 and 7 while minimizing errors.
# Errors are logged with line numbers to simplify debugging.
# one liner to run the script "/tool fetch url="https://raw.githubusercontent.com/geekonamotorcycle/sysadmins-grimoires/refs/heads/main/scripts/firewall/routeros/list-ehernet-ports-v7.rsc" mode=https dst-path=list-ethernet-ports-v7.rsc && /import list-ethernet-ports-v7.rsc"


:put "=== Ethernet Port Summary ==="

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

    :if ([$hasAttribute $port "link-downs"]) do={
        :set linkStatus [$safeGet $port "link-downs" "25"];
    }

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
