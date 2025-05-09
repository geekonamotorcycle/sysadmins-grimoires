# Find-DhcpHost.ps1

## Description

This PowerShell script searches for DHCPv4 and DHCPv6 leases matching a given hostname on the local server.  
It verifies that it is running on a Windows Server with DHCP and DNS roles before performing the search.  
The script logs all results and errors with timestamps to a single log file.

## Features

- Searches for both IPv4 and IPv6 DHCP leases.
- Verifies that the server has the DHCP and DNS roles installed.
- Logs all results and errors to `C:\Logs\Find-DhcpHost.log`.
- Accepts hostname input via:
  - Command-line switch `-Hostname`
  - User prompt if the switch is not provided.
- Uses robust error handling with try-catch blocks.
- Appends to the log file if it already exists.

## Prerequisites

- PowerShell (run as Administrator).
- Windows Server with DHCP and DNS roles installed.
- DHCP Server PowerShell module installed.

## Usage

### Run with Command-Line Argument

```powershell
.\Find-DhcpHost.ps1 -Hostname thunderhead
```
