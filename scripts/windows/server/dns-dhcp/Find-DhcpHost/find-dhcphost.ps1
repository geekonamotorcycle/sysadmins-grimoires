<#
.SYNOPSIS
    Searches for DHCPv4 and DHCPv6 leases matching a given hostname on the local server.

.DESCRIPTION
    This script searches all local DHCPv4 and DHCPv6 servers for leases matching a specified hostname.
    The hostname can be provided as a command-line argument or entered manually when prompted.
    The script checks if it is running on a Windows Server with DHCP and DNS roles before proceeding.

.PARAMETER Hostname
    The NetBIOS name or FQDN to search for. If not provided, the script prompts for input.

.EXAMPLE
    .\Find-DhcpHost.ps1 -Hostname thunderhead

.NOTES
    Author: Your Name
    Date: 2025-05-09
    Version: 1.0
    Log File: C:\Logs\Find-DhcpHost.log
#>

# Log file path
$logFile = "C:\Logs\Find-DhcpHost.log"

# Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $Message"
    Write-Output $entry
    Add-Content -Path $logFile -Value $entry
}

# Ensure the log file directory exists
if (!(Test-Path -Path (Split-Path -Path $logFile))) {
    New-Item -ItemType Directory -Path (Split-Path -Path $logFile) -Force
}

# Function to check server environment
function Check-ServerEnvironment {
    try {
        if (-not (Get-WindowsFeature -Name DHCP, DNS | Where-Object { $_.Installed })) {
            throw "This script must be run on a Windows Server with DHCP and DNS roles installed."
        }
        Log-Message "Environment verification successful: DHCP and DNS roles detected."
    } catch {
        Log-Message "Environment verification failed: $_"
        Write-Error "Error: $_"
        exit 1
    }
}

# Function to find all local DHCP servers
function Get-LocalDhcpServers {
    try {
        Get-Service -Name DhcpServer, DhcpV6Server -ErrorAction Stop |
        Where-Object { $_.Status -eq 'Running' } |
        Select-Object -ExpandProperty Name
    } catch {
        Log-Message "Error retrieving DHCP services: $_"
        Write-Error "Error: $_"
    }
}

# Function to search DHCP leases for a specific hostname
function Search-DhcpLeases {
    param (
        [string]$ServerType,
        [string]$HostName
    )
    try {
        if ($ServerType -eq 'DhcpServer') {
            # Search for IPv4 leases
            $leases = Get-DhcpServerv4Scope |
                ForEach-Object { Get-DhcpServerv4Lease -ScopeId $_.ScopeId } |
                Where-Object { $_.HostName -match $HostName }
        } elseif ($ServerType -eq 'DhcpV6Server') {
            # Search for IPv6 leases
            $leases = Get-DhcpServerv6Scope |
                ForEach-Object { Get-DhcpServerv6Lease -ScopeId $_.ScopeId } |
                Where-Object { $_.HostName -match $HostName }
        } else {
            throw "Unknown server type: $ServerType"
        }

        # Log and display results
        if ($leases) {
            foreach ($lease in $leases) {
                $result = "Server: $ServerType | ClientId: $($lease.ClientId) | IP: $($lease.IPAddress) | Host: $($lease.HostName) | State: $($lease.AddressState)"
                Log-Message $result
                Write-Output $result
            }
        } else {
            $msg = "No hosts named '$HostName' found on $ServerType."
            Log-Message $msg
            Write-Output $msg
        }
    } catch {
        Log-Message "Error while searching leases: $_"
        Write-Error "Error: $_"
    }
}

# Main script execution
param (
    [string]$Hostname
)

try {
    # Validate environment
    Check-ServerEnvironment

    # Get hostname if not provided
    if (-not $Hostname) {
        $Hostname = Read-Host "Enter the NetBIOS or FQDN hostname to search"
    }

    if (-not $Hostname) {
        throw "Hostname cannot be empty."
    }

    # Log start of search
    Log-Message "Starting DHCP lease search for hostname: $Hostname"

    # Get DHCP servers and search for leases
    $servers = Get-LocalDhcpServers

    if (-not $servers) {
        throw "No local DHCP servers found."
    }

    foreach ($server in $servers) {
        Search-DhcpLeases -ServerType $server -HostName $Hostname
    }

    # Log completion
    Log-Message "Search completed for hostname: $Hostname"

} catch {
    Log-Message "Script error: $_"
    Write-Error "Error: $_"
}
