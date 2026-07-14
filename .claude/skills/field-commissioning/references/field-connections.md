# Field Connections — Local & Remote Connection Procedures

## RNET Connection Setup (Legacy/Pre-OptiFlex E2 Controllers)

1. Job files must be loaded into the WebCTRL webroot (pre-8.5) or **WebCTRL8.5\programdata\systems folder (v8.5)** before local database communication can be established.
2. On-site, have the computer set up and turned on.
3. Plug the USB cable into the computer.
4. Identify the COM port used by the USB cable: press the Windows key, search "device manager." The COM port number appears beside **CP210X USB to UART Bridge Controller**.
5. Go to the WebCTRL folder and start the WebCTRL Server.
6. Open an internet browser.
7. Type `http://localhost` in the address bar.
8. Log into WebCTRL with username and password.
9. In the WebCTRL CFG tree, select **Connections**.
10. On the Configure tab, click **Add**.
11. From the dropdown, select **BACnet/Rnet Local Access Connection**.
12. Type in the computer's COM port number for the USB cable.
13. Set the **Baud rate to 115200** for a 5-pin connection.
14. Click **OK**.
15. On the View tab, click the dropdown arrow next to the device's network connection, then select **BACnet/Rnet Local Access Connection**.
16. Click **OK**.
17. If successful, the BACnet/Rnet Local Access Connection status shows **"connected."**
18. Go to the WebCTRL window's **Net** page.
19. Find the correct module in the window tree and click the module status button — if properly connected, a modstat page appears, confirming connection to the module.
20. Perform a manual command: **CTRL+M**, then type **`rnet here`** to align the local database connection to the currently connected controller.

Once connected, proceed to the Powering Up & Downloading Memory procedure (`commissioning-workflow.md`, Step 2) to download memory/programming.

---

## OptiFlex Local Connection Setup (Dual Ethernet Port / E2 Controllers)

1. Have your laptop's connections window open, USB 2.0 cable plugged into the laptop's USB port, and the other end plugged into the controller's USB access port.
   - Once connected on both ends with the controller powered up, a new virtual ethernet connection appears in the connections window (created by the controller), providing access to the controller's local setup page. From this connection you can:
     1. View the controller's modstat.
     2. Check firmware and device instance settings.
     3. Adjust the device instance and controller port settings.
2. Change the IP address of the controller and all other controllers connected via ethernet to it.
3. Verify MAC addresses of all connected controllers.
4. Enable a **"blink" mode** on E2 VAV controllers — blinks the large round LED indicator on the controller's front to help locate it among others (limited by VAV box covers/ceiling obstructions blocking view).

Once connected, proceed to the Powering Up & Downloading Memory procedure (`commissioning-workflow.md`, Step 2) to download memory/programming.

---

## TCP/IP Manager (Switching IP Profiles Between Sites)

### Introduction

TCP/IP Manager is a lightweight networking tool for switching between multiple IP configurations with a single click — useful moving between home, office, or remote sites.

### Step 1: Installing TCP/IP Manager

1. Download and run the TCP/IP Manager installation software.
2. Follow on-screen prompts to complete installation.
3. Launch the application from the Start Menu or Desktop shortcut.

### Step 2: Initial Configuration

1. Open TCP/IP Manager.
2. Click the **"Options"** button (toolbar or menu).
3. In the Options window, check:
   - **Start TCP/IP Manager on Windows Startup**
   - **Open TCP/IP Manager in taskbar**
4. Click **OK** or **Apply** to save.

### Step 3: Creating a New Network Profile

1. On first run, the profile list is blank.
2. In the profile configuration window, enter network details:
   - IP Address
   - Subnet Mask
   - Default Gateway
   - DNS Servers
3. Select the **"Network connection name"** for the Ethernet port from the dropdown.
4. Example IP settings:
   - **IP Address:** 192.168.168.200
   - **Subnet mask:** 255.255.255.0
   - **Default gateway:** 192.168.168.1
   - **Primary DNS:** 8.8.8.8
   - **Secondary DNS:** 1.1.1.1
5. Click **"Save Current Profile"** and assign a Profile Name (e.g., "168.200" or "Localhost" if that's the WebCTRL server IP).
6. Click **"Create a new profile"** to repeat for additional configs.
7. Repeat to create a **DHCP/Auto Configuration** profile:
   - Leave network settings blank; click "Obtain an IP address automatically."
   - Click "Save Current Profile."
   - Name it something like **"DHCP or Auto."**

### Step 4: Switching Between Profiles

1. From the main profile dropdown, click the desired profile name.
2. Click **"Apply settings"** at the bottom to activate.
3. Notifications appear confirming the change is in progress (expect several notifications as changes are made).
4. A final notification confirms the change was successfully applied.

### Tips for Effective Use

- Use descriptive profile names (e.g., "XYZ School," "DHCP," "MyModule Setup") for quick identification.
- Keep a default DHCP profile as a fallback in case of misconfiguration.

### Software Download

Referenced download location: `https://tcpipmanager.sourceforge.io/download.html`

---

## Connecting to WebCTRL via Wi-Fi (GL-SFT1200-Opal)

### Objective

Connect to the WebCTRL Server located at **`192.168.168.100`** over a local Wi-Fi network created by the **GL-SFT1200-Opal** router.

### Equipment Needed

- Laptop or tablet with Wi-Fi capability
- GL-iNet GL-SFT1200-Opal wireless router (pre-connected to the control system network via Ethernet)
- Power supply for the GL-SFT1200-Opal (can be powered via USB from laptop, power pack, or hotspot; box includes a wall-outlet power block)
- Static IP configuration privileges

### Step-by-Step Instructions

**1. Power up and confirm router connection**

- Ensure the GL-SFT1200-Opal is powered and connected via Ethernet LAN port to one of the controllers (example range in diagram: between `192.168.168.8` and `192.168.168.7`).
- The router can also connect to a network switch anywhere in the ALC controller building network, as long as it has a path back to the WebCTRL Server.
- Confirm the router is broadcasting a Wi-Fi SSID (e.g., "GL-SFT1200" or a customized name).

**2. Connect your device to the router's Wi-Fi**

- Open Wi-Fi settings; connect to the router's SSID (check instructions/router label for password).

**3. Assign a static IP address**

- Go to **Network Settings > WiFi > Adapter Settings** (varies by Windows version).
- Set a manual/static IPv4 address:
  - **IP Address:** a unique address such as `192.168.168.99` (or `.98`, `.97`, etc.)
  - **Subnet Mask:** `255.255.255.0`
  - **Gateway:** optional — leave blank or use `192.168.168.1`
- **Each technician must use a different IP address** to avoid conflicts.

**4. Access the WebCTRL Server**

- Open a browser and go to: `http://192.168.168.100`
- The WebCTRL login screen should appear — enter credentials and begin the session.

### Troubleshooting

| Issue | Solution |
|---|---|
| Can't connect to Wi-Fi | Reboot the router and try again. |
| Page won't load | Double-check IP settings and ensure you're on the correct subnet. |
| IP conflict | Use a different `.99`, `.98`, `.97` static IP. |
| Connection drops | Move closer to the GL-SFT1200 or check for controller power issues. |

### Notes

- **Do not** enable DHCP on your laptop or router — this network uses **static IPs only**.
- Always disconnect from other Wi-Fi networks to avoid routing conflicts.
- This setup assumes no internet — local access only to the control system.

---

## Remote Desktop Connection to FIELDSERVER

### System Details

- **Server Name pattern:** `FIELDSERVER(X)` — X = number (example: `FIELDSERVER4`)
- **Username:** `Automated Controls`
- **Password:** (leave blank)
- **RDP Access:** enabled with a no-password policy already configured on these servers.

### Step-by-Step Instructions

1. **Open Remote Desktop Connection**
   - Press **Windows + R** to open Run.
   - Type **`mstsc`** and press Enter.
2. **Enter the Computer Name**
   - In the Computer field, type the server name, e.g., **`FIELDSERVER4`**.
3. **Click "Show Options."**
4. **Enter the User Name**
   - In the User name field, type: **`Automated Controls`**.
5. **Leave Password Blank** — do not enter a password.
6. **Click "Connect."**
7. **Accept the Certificate Prompt** — if warned about the remote computer's certificate, click **Yes** to continue.
8. **Confirm connection** — you should now be connected to `FIELDSERVER4` as `Automated Controls`.

### Notes

- Your device must be on the **same IP range as the WebCTRL server**. Example: if the WebCTRL server's IP is `192.168.7.200`, set your Ethernet connection to a static IP such as `192.168.7.197` or any IP **less than** `192.168.7.200` in the same subnet, so your computer can communicate directly with `FIELDSERVER4` over the local network.
- If you get an error about blank passwords not being allowed, verify **secpol.msc** was updated properly on the server:
  - Navigate to: **Local Policies > Security Options > Accounts: Limit local account use of blank passwords to console logon only**
  - Set this to **Disabled**.
- If `FIELDSERVER4` cannot be resolved by name, verify connectivity by opening a browser and typing the WebCTRL server's IP address directly.
