# list-ethernet-ports-v7.rsc

## 📄 Description

`list-ethernet-ports-v7.rsc` is a MikroTik RouterOS script designed to provide a comprehensive summary of all Ethernet
interfaces on devices running RouterOS 7+. The script retrieves essential details for each Ethernet port, including MAC
address, running status, speed, MTU, RX/TX bytes, and bridge membership.

### 🔧 Features

- Displays the following attributes for each Ethernet port:
  - Port name
  - MAC address
  - Running status (true/false)
  - Interface type (if available)
  - Speed (if available)
  - MTU and L2 MTU
  - Link-down count (if available)
  - RX and TX bytes
  - Associated bridge (if any)
  - Comment (if available)
- Error handling for missing or unavailable attributes:
  - Displays `N/A` for attributes that are not set.
  - Displays `ER` when an error occurs while fetching an attribute.
- Robust error logging to indicate which attribute failed to retrieve.

---

## Installation

### Step 1: Upload the Script

1. Open your MikroTik device via serial console (e.g., using MobaXterm).
2. Use `xmodem` to transfer the file:  
  
   ```bash
   /import xmodem
   ```  

3. Start the xmodem transfer from your terminal client.  

### Step 2: Remove Previous Versions (if any)

To remove an old version of the script:

```bash
/system script remove [find name=list-ethernet-ports-v7]
```

### Step 3: Add the Script

After uploading the file, add it to RouterOS:

```bash
/system script add name=list-ethernet-ports-v7 source=""
/system script edit list-ethernet-ports-v7 source
```

Copy and paste the script content using the built-in editor.

---

## Usage

Run the script using:

```bash
/system script run list-ethernet-ports-v7
```

### Example Output  

```text
=== Ethernet Port Summary ===
-------------------------------
Port: ether1 | MAC: F4:1E:57:87:E5:1F | Running: true
    Type: N/A | Speed: N/A | MTU: 1500 | L2 MTU: 1596
    Link-Downs: N/A | RX: 0 bytes | TX: 359106 bytes
    Bridge: None
    Comment: N/A
=== End of Ethernet Port Summary ===
```

---

## Notes

- The script has been tested on RouterOS 7+ and should work on any MikroTik device running this version.
- The script is designed to handle variations between RouterOS 6 and 7. It will print `N/A` if an attribute is not
available on the current RouterOS version.
- Uses robust error handling to ensure the script continues to run even if an attribute retrieval fails.

---

## Version History

- **Release 1.0:**
  - Initial release with comprehensive error handling and detailed interface information.
  - Dynamic handling of RouterOS version differences.

---

## Contributing

If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

---

## 📜 License

This script is provided under the MIT License. Feel free to use and modify it as needed.
