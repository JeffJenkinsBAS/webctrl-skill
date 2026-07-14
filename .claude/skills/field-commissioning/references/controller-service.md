# Controller Service — Replacement, Restore/Recovery, and LED Reference

## OptiFlex Controller Replacement

### Quick Setup Guide for Service Technicians

**1. Record the Existing Controller Settings**

Before removing/replacing, check the live system and record:

- IP Address
- Subnet Mask
- Default Gateway
- Device Instance

Write down or photograph for reference — saves time, prevents addressing errors.

**2. Required Cable**

A **USB 2.0 to USB 2.0 cable** long enough to reach the controller.

**3. Connect to the Controller**

1. Plug the USB cable into the **Service Port** on the controller.
2. Connect the other end to your laptop.
3. Open a web browser; browse to:
   ```
   http://local.access
   ```
   or
   ```
   http://169.254.1.1
   ```
   This opens the controller configuration page.

**4. Set the Network Settings**

Before connecting the Ethernet cable, configure the controller first via the **Ports tab**:

- IP Address
- Subnet Mask
- Default Gateway

Use values recorded from the original controller.

**5. Set the Device Instance**

Go to the **BACnet settings** page. Enter the Device Instance number from the original controller. Each controller must have a **unique device instance** on the network.

**6. Set the BACnet/IP Network Number**

Locate the BACnet/IP Network Number setting; enter the same network number used by the existing system. Wrong network number can prevent communication.

**7. Save the Configuration**

- Click **Save**.
- Allow reboot if required.
- Verify settings remain after saving.

**8. Connect the Network**

1. Plug in the Ethernet cable.
2. Allow the controller to join the network.
3. Verify controller appears in WebCTRL — check it's **online**, points are updating, no communication errors.

### Quick Setup Checklist

- [ ] IP Address set
- [ ] Subnet Mask set
- [ ] Default Gateway set
- [ ] Device Instance set
- [ ] BACnet/IP Network Number set
- [ ] Settings saved

---

## Restoring an OptiFlex Controller [Gen5]

### TLDR — DSC-Button Controllers

1. Format USB as FAT32.
2. Copy Gen5 driver to USB root directory.
3. Remove controller power.
4. Hold DSC button.
5. Restore power while holding DSC.
6. Release DSC when Sys and Net flash magenta.
7. Insert USB drive.
8. Wait for Sys solid green and Net solid magenta.
9. Remove power.
10. Remove USB.
11. Restore power.
12. Reconfigure communication.
13. Assign driver in SiteBuilder.
14. Download all content.
15. Perform controller and equipment checkout.

### TLDR — G5CE/G5RE Controllers

1. Format USB as FAT32.
2. Copy Gen5 driver to USB root directory.
3. Record normal rotary-switch address.
4. Remove power.
5. Set rotary switches to `911`.
6. Restore power.
7. Wait for magenta recovery indication.
8. Insert USB.
9. Wait for Sys solid green.
10. Remove power.
11. Remove USB.
12. Restore normal rotary-switch address.
13. Restore power.
14. Reconfigure communication.
15. Assign driver in SiteBuilder.
16. Download all content.
17. Perform controller and equipment checkout.

### Purpose

Restores a supported ALC OptiFlex controller to factory-default state, loads the selected Gen5 `drv_fwex` driver from a USB flash drive. Technicians call it "formatting," but technically it is a **firmware recovery and factory-default reset**, not a disk format.

**Use when:**

- Controller won't download or operate normally.
- Firmware appears corrupted.
- Network/config problems can't be cleared normally.
- Controller is being repurposed.
- ALC Technical Support recommends factory-default recovery.

Many current OptiFlex controllers include a USB 2.0 port supporting this process.

### Important Warning

**WARNING: This process erases archived information and user-configured settings stored in the controller.**

May need to restore/reconfigure after recovery:

- BACnet Device Instance
- BACnet Network Number
- IP address / Subnet mask / Default gateway
- BBMD settings
- Foreign-device settings
- Firewall settings
- Serial-port configuration
- Controller programs
- Parameters and setpoints
- Schedules
- Trend archives stored locally in the controller
- Third-party integration configuration

Verify WebCTRL database has correct controller config/programs/parameters before beginning. Coordinate the equipment outage — controlled equipment may stop, restart, or remain uncontrolled while offline.

### Required Materials

- Windows computer
- USB flash drive, **8 GB to 32 GB** preferred
- Current Gen5 controller driver
- Local access to the controller
- Ability to remove/restore controller power
- Current SiteBuilder/WebCTRL database
- Controller addressing and IP information
- Small screwdriver (if needed for rotary switches/access)

**Recommended USB Drive:** Basic USB 2.0 or 3.x, 8–32 GB.
**Avoid:** Encrypted drives, drives with security software, multiple partitions, very large drives, exFAT/NTFS formatting, USB hubs/extension cables.

### Section 1: Create a FAT32 USB Flash Drive

**Option A: Format via Windows File Explorer**

1. Insert USB drive.
2. Open File Explorer (`Windows Key + E`) → **This PC**.
3. Identify correct USB drive under Devices and drives — verify drive letter and capacity.
   - **CAUTION:** Formatting deletes everything on the selected drive; confirm correct drive.
4. Right-click USB drive → **Format**.
5. Configure format settings:
   | Setting | Required Selection |
   |---|---|
   | File system | FAT32 |
   | Allocation unit size | Default allocation size |
   | Volume label | `ALC_RECOVERY` or similar |
   | Format options | Quick Format checked |
6. Click **Start**; acknowledge warning; wait for "Format Complete."
7. Right-click drive → Properties → confirm file system shows `FAT32`.

**When FAT32 Is Not Available:** Windows may not offer FAT32 for USB drives >~32 GB. Use a drive ≤32 GB. exFAT is NOT equivalent — recovery specifically requires FAT32.

**Option B: Create FAT32 Partition via Disk Management** (use only if no suitable smaller drive available)

1. Right-click Start → **Disk Management**.
2. Identify the USB drive by capacity.
3. Right-click USB volume → **Delete Volume** (removes all data/partitions).
4. Right-click unallocated space → **New Simple Volume**; enter size ≤ `32768 MB`.
5. Format: File system **FAT32**, Allocation unit **Default**, Volume label `ALC_RECOVERY`, **Quick format checked**. Complete wizard.
6. Verify via File Explorer → Properties → confirm FAT32.

### Section 2: Prepare the Gen5 Driver

1. Download the latest approved Gen5 `drv_fwex` driver from the Automated Logic Partner Community. Filename similar to `drv_fwex_<version>.driverx`.
2. Verify compatibility against: controller model, driver assigned in SiteBuilder, WebCTRL version, current ALC technical documentation, project-specific restrictions. Don't install newest driver just because the number is bigger — confirm WebCTRL version support.
3. Copy driver to USB **root directory**.
   - Correct: `E:\drv_fwex_<version>.driverx`
   - Incorrect: `E:\Drivers\drv_fwex_<version>.driverx`
   - Incorrect: `E:\Gen5\Current\drv_fwex_<version>.driverx`
4. Remove unnecessary files (old drivers, ZIPs, PDFs, text files, SiteBuilder backups, other firmware). Extract the ZIP first — don't copy the compressed package.
5. Safely eject the USB drive (right-click → Eject; wait for confirmation).

### Section 3: Pre-Recovery Documentation

Before removing power, record:

**Controller Information Checklist:**

- Controller model
- Controller name
- Equipment served
- BACnet Device Instance
- BACnet Network Number
- Controller MAC address
- IP address
- Subnet mask
- Default gateway
- BBMD or Foreign Device settings
- Port S1 configuration
- Port S2 configuration
- Modbus settings
- Firewall settings
- Existing driver version
- New driver version
- Normal rotary-switch address, if applicable

**WebCTRL Backup Checks:**

1. Confirm correct controller exists in SiteBuilder.
2. Confirm controller assigned to correct equipment.
3. Confirm required programs are present.
4. Confirm important parameters/setpoints available.
5. Confirm database backed up or replicated.
6. Note any locked values needing manual restoration.
7. Notify affected personnel of equipment offline status.

### Section 4: Recovery for E2 and Similar DSC-Button Controllers

Applies to controllers using the **DSC-button recovery method**, including many newer E2 application controllers:

- OF022-E2, OF141-E2, OF253A-E2, OF253T-E2, OF342-E2, OF561-E2, OF561T-E2, OF683-E2, OF683T-E2, OF683XT-E2

Always verify Technical Instructions for the exact model first.

**Procedure:**

1. Verify USB drive is FAT32, correct driver in root directory, no conflicting driver files.
2. Remove controller's 24 VAC or 24 VDC power; verify LEDs turn off.
3. Press and hold the **DSC** button.
4. While holding DSC, restore controller power.
5. Continue holding until **Sys LED flashes magenta** and **Net LED flashes magenta**; release DSC after both flash magenta.
6. Insert prepared FAT32 USB flash drive into controller's USB port.
7. Do not remove power or USB while recovery runs (may take several minutes). Wait until **Sys LED solid green** and **Net LED solid magenta**.
   - **WARNING:** Removing power/USB before finish may corrupt firmware.
8. Remove controller power.
9. Remove USB drive.
10. Restore controller power — controller now runs the new driver, restored to default state (previous config missing until restored).

### Section 5: Recovery for G5CE and G5RE Controllers

Uses the **rotary-switch 911 recovery method**. Applies to:

- G5CE OptiFlex BACnet Integrator
- G5RE OptiFlex BACnet Router

**Procedure:**

1. Record/photograph the normal rotary-switch address before changing anything.
2. Remove power; verify LEDs off.
3. Set the three rotary switches to `9-1-1`.
4. Apply power; allow boot sequence to complete.
5. After boot: **Sys LED indicates magenta**, **Net LED indicates magenta**.
6. Insert prepared FAT32 USB drive.
7. During recovery, Sys LED blinks more rapidly as the driver installs. Wait until **Sys LED turns solid green**. Do not remove power/USB while Sys LED is blinking through recovery.
8. Remove power once Sys LED is solid green.
9. Remove USB drive.
10. Restore the rotary switches to the recorded normal address — **do not leave switches at 911**.
11. Apply power — controller now runs the installed driver, in default state.

### Section 6: Restore Controller Communication

1. Connect locally via supported method (Ethernet service port, direct Ethernet, local network, or USB Link Kit where applicable).
2. Restore basic network info: BACnet Device Instance, BACnet Network Number, BACnet/IP network, IP address, subnet mask, default gateway, UDP port (if nonstandard), BBMD settings, Foreign Device settings, serial-port settings, firewall configuration.
3. Confirm SiteBuilder settings:
   1. Select controller in Network tree.
   2. Confirm correct controller model.
   3. Confirm Device Instance.
   4. Confirm Network Number.
   5. Confirm controller address.
   6. Assign the newly installed Gen5 driver version.
   7. Save database changes.
   8. Update or reload the system database as required.
   - Duplicate BACnet Device Instances or wrong network numbers can make a recovered controller appear dead.

### Section 7: Download the Controller

1. Navigate to the Downloads page.
2. Locate the recovered controller.
3. Select **Download all content**.
4. Monitor until complete.
5. Confirm controller returns online.
6. Confirm correct driver version displayed.
7. Confirm all required programs present.
8. Confirm parameters/setpoints restored.
9. Review the download report for failures/rejected content.

Some configuration values may require manual entry after download.

### Section 8: Post-Recovery Checkout

**Communication Verification:**

- Controller online in WebCTRL Network tree.
- No duplicate Device Instance.
- No duplicate IP address.
- BACnet Network Number correct.
- Controller MAC address correct.
- Port S1 and Port S2 configured correctly.
- Downstream controllers/third-party devices online.
- BBMD or Foreign Device registration operating.
- No excessive communication alarms.

**Program Verification:**

- Correct control programs running.
- Programs assigned to proper equipment.
- Schedules present.
- Setpoints reasonable.
- Network points bound.
- Integration points communicating.
- No required values remain locked.
- No program errors present.

**Physical I/O Verification (check before returning equipment to normal operation):**

- Safety circuits
- Fan proof
- Pump proof
- Freezestat
- Smoke shutdown
- Emergency stop
- Valve outputs
- Damper outputs
- VFD enable
- VFD speed command
- Temperature inputs
- Pressure inputs
- Current switches
- Equipment status

**Operational Verification:**

1. Equipment starts/stops correctly.
2. Safeties remain active.
3. Outputs not left forced or locked.
4. HOA switches returned to proper position.
5. Valves/dampers respond correctly.
6. Alarms enabled.
7. Trends enabled.
8. Network points updating.
9. Checkout notes document the recovery.
10. PM or Project Engineer notified of completion.

### Troubleshooting

**Controller Does Not Enter Recovery Mode:**

- Controller power fully removed before starting.
- DSC button held before power applied.
- DSC button held until both LEDs flashed magenta.
- G5CE/G5RE switches correctly set to `911`.
- Rotary switches fully seated at selected numbers.
- Correct controller-specific method used.

**Controller Does Not Read the USB Drive:**

- USB formatted as FAT32.
- Driver in root directory.
- Driver extracted from ZIP.
- Driver filename/extension intact.
- Only one applicable driver file on drive.
- USB drive ≤32 GB.
- Another basic USB drive tested.
- Driver compatible with controller model.
- USB inserted only after controller entered recovery mode.

**Sys LED Never Turns Solid Green — possible causes:**

- Incorrect driver
- Corrupted driver file
- Unsupported driver version
- USB drive not recognized
- USB formatted incorrectly
- Recovery interrupted
- Controller firmware or hardware failure
- Remove power only after allowing sufficient time; if process doesn't complete, contact ALC Technical Support before repeatedly cycling power.

**Controller Recovers but Does Not Communicate — check:**

- Device Instance
- Network Number
- MAC address
- IP address
- Subnet mask
- Default gateway
- UDP port
- BBMD configuration
- Foreign Device configuration
- SiteBuilder controller model
- Assigned driver version
- Duplicate BACnet addresses
- Ethernet link LEDs
- Local firewall settings

---

## Performing a 9-1-1 Reset (Legacy, Non-E2 Controllers/Routers)

**WARNING:** This process only works for **OptiFlex Controllers/Routers without the E2 configuration**, and it erases all archived information and user-configured settings. When recovery is complete, you must connect locally to the controller and manually reconfigure all BACnet, IP, and firewall information. Highly recommended to revert to default settings only under the guidance of Automated Logic Technical Support.

### Procedure

1. Copy the newest driver to the root directory of a FAT32-formatted USB flash drive.
   - NOTE: To verify the latest driver version, check the Automated Logic Partner Community website and compare to the G5CE's driver in SiteBuilder.
2. Remove power from the G5CE.
3. Set the rotary switches to **911**.
4. Apply power to the G5CE.
   - NOTE: The Sys and Net LEDs change to **magenta** after the boot sequence.
5. Plug the USB drive into the controller's USB port.
   - NOTES: Sys LED blinks faster when recovery is in progress; Sys LED turns **solid green** when the process is complete.
6. Remove power from the G5CE.
7. Remove the USB drive from the USB port.
8. Set the rotary switches back to the normal address.
9. Apply power to the G5CE.
   - NOTE: The controller is now running the new firmware version and is in the default state.

**Post-recovery in SiteBuilder:**

- Configure the Device Instance, Network Number, and address so the controller can communicate with the server (set via the Network tree).
- Assign the new driver version to the controller.
- To recover previous parameters and programs, click **Download all content** from the WebCTRL Downloads page.

*(Note: this rotary-switch-911 method is superseded for Gen5 hardware by the fuller "Restoring an OptiFlex Controller [Gen5]" procedure above, which covers both the rotary-switch-911 method for G5CE/G5RE and the DSC-button method for E2-configuration controllers.)*

---

## OF342-E2 LED Quick Reference

Troubleshooting the OF342-E2's connectivity begins at the LEDs (assuming power is present). The color and blink pattern indicate the condition.

### NET (Network Status) Tricolor LED — RED

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Red | On | Ethernet connection problem | No Ethernet Link | Connect Ethernet Cable; Check other network components |
| Red | 1 Blink | BACnet/IP (Ethernet) DLL reporting issue: unable to create tasks / unable to open socket for BACnet port | BACnet/IP error | Cycle power |

### NET (Network Status) Tricolor LED — BLUE

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Blue | On | Port communication firmware did not load properly / not running / invalid protocol selected | MSTP firmware error | Change protocol using USB Service Port; Cycle power |
| Blue | 1 Blink | Invalid address selected for protocol | Invalid address selection for MSTP | Change MAC address to unique address using USB Service Port |
| Blue | 2 Blinks | Router has same MAC address as another connected device | Duplicate address on MSTP | Change rotary switch to unique address |
| Blue | 3 Blinks | Router is the only device on the network | No other devices detected on MSTP | Check that network cable is connected properly; Check that baud rate is correct |
| Blue | 4 Blinks | Excessive errors detected over 3 second period | Excessive communication errors on MSTP | Check network cable connection; Check baud rate |

### NET (Network Status) Tricolor LED — GREEN

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Green | On | All enabled networks are functioning properly | No errors | No action required |

### NET (Network Status) Tricolor LED — Magenta

| Color | Pattern | Condition | Message | Solution |
|---|---|---|---|---|
| Magenta | — | Operating system changes are downloading. **WARNING**: could take several minutes. Do **NOT** power off during download. | N/A | No action required |

### NET (Network Status) Tricolor LED — White

| Color | Pattern | Condition | Message | Solution |
|---|---|---|---|---|
| White | 1 blink/sec for 15 sec | The Blink button on the controller setup Local Network tab was pressed | N/A | No action required |

### SYS (System Status) Tricolor LED — RED

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Red | 2 Blinks | Restarting after an abnormal exit | Auto restart delay due to system error on startup | After 5 minute delay expires, if condition recurs, cycle power |
| Red | 4 Blinks | Firmware image is corrupt | Firmware error | Download driver again |
| Red | Fast Blinking | Firmware error caused firmware to exit and restart | Fatal error detected | No action required |

### SYS (System Status) Tricolor LED — GREEN

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Green | 1 Blink | No errors | Operational | No action required |
| Green | 2 Blinks | Download of driver is in progress | Download in progress | No action required |
| Green | 3 Blinks | BACnet Device ID is not set | Download required | Download the controller |
| Green | Fast Blinking | Installation of recently downloaded driver occurring | N/A | No action required |

### SYS (System Status) Tricolor LED — BLUE

| Color | Pattern | Condition | Message | Solution |
|---|---|---|---|---|
| Blue | On | Router is starting up | N/A | No action required |
| Blue | Slow Blinking | Linux (OS) is starting up | N/A | No action required |
| Blue | Fast Blinking | Linux running but could not start the firmware application | N/A | Download driver |

### SYS (System Status) Tricolor LED — Magenta

| Color | Pattern | Condition | Message | Solution |
|---|---|---|---|---|
| Magenta | — | Operating system changes are downloading. **WARNING**: could take several minutes. Do **NOT** power off during download. | N/A | No action required |

### SYS (System Status) Tricolor LED — White

| Color | Pattern | Condition | Message | Solution |
|---|---|---|---|---|
| White | 1 blink/sec for 15 sec | The Blink button on the controller setup Local Network tab was pressed | N/A | No action required |

### To Use the Locator LED

The Locator LED turns on when you:

- Power on the controller
- Change the driver
- Click the Blink button

Click the **Blink** button to prompt the Locator LED to flash for **15 seconds**, allowing you to verify the controller's physical location. After flashing, whenever the actuator moves, the LED rotates in the same direction. LED rotation is automatically disabled after **1 hour** and can be re-enabled by pressing the Blink button again.

**The Blink button is located in:**

- Controller setup Local Network tab → Local Devices table.
- WebCTRL interface on the Driver page.
- Test & Balance tool on the Test and Balance tab.

---

## G5CE LED Quick Reference

Troubleshooting the G5CE's connectivity begins at the LEDs (assuming power is present). The color and blink pattern indicate the condition.

### NET (Network Status) Tricolor LED — RED

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Red | On | Ethernet connection problem | No Ethernet Link | Connect Ethernet Cable; Check other network components |
| Red | 1 Blink | BACnet/IP (Ethernet) DLL reporting issue: unable to create tasks / unable to open socket for BACnet port | BACnet/IP error | Cycle power |
| Red | 2 Blinks | Current default IP address does not match the current rotary switch | Default IP address mismatch | Use controller setup Ports tab to set IP address; Cycle power to accept new IP; Change rotary switches to match current default IP address |
| Red | 3 Blinks | Unable to get address from DHCP server | Error unable to find DHCP server | Check with network administrator |

### NET (Network Status) Tricolor LED — BLUE

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Blue | On | Port communication firmware did not load properly / not running / invalid protocol selected | ARCNET/MSTP firmware error | Change rotary switch to select valid protocol; Cycle power |
| Blue | 1 Blink | Invalid address selected for protocol | Invalid address selection for ARCNET/MSTP | Change rotary switch to valid address |
| Blue | 2 Blinks | Router has same MAC address as another connected device | Duplicate address on ARCNET/MSTP | Change rotary switch to unique address |
| Blue | 3 Blinks | Router is the only device on the network | No other devices detected on ARCNET/MSTP | Check network cable connection; Check baud rate |
| Blue | 4 Blinks | Excessive errors detected over 3 second period | Excessive communication errors on ARCNET/MSTP | Check network cable connection; Check baud rate |
| Blue | 5 Blinks | ARCNET traffic overload — possibly circular router or excessive COVs (change of values) | Event System Error — FPGA RX FIFO full | Check network configuration for a circular route; Increase time between COVs to reduce excessive COV traffic |

### NET (Network Status) Tricolor LED — GREEN

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Green | On | All enabled networks are functioning properly | No errors | No action required |

### SYS (System Status) Tricolor LED — RED

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Red | 1 Blink | System non-operational due to excessive control program abnormal exits | No control programs started due to frequent system errors | Remove control programs and download |
| Red | 2 Blinks | Restarting after an abnormal exit | Auto restart delay due to system error on startup | After 5 minute delay expires, if condition recurs, cycle power |
| Red | 3 Blinks | System non-operational due to one or more control programs halted | Control program stopped due to program error | Remove control program and download |
| Red | 4 Blinks | Firmware image is corrupt | Firmware error | Download driver again |
| Red | Fast Blinking | Firmware error caused firmware to exit and restart | Fatal error detected | No action required |

### SYS (System Status) Tricolor LED — GREEN

| Color | Pattern | Condition | Message in Module Status | Possible Solution |
|---|---|---|---|---|
| Green | 1 Blink | No errors | Operational | No action required |
| Green | 2 Blinks | Download of driver is in progress | Download in progress | No action required |
| Green | 3 Blinks | BACnet Device ID is not set | Download required | Download the controller |
| Green | Fast Blinking | Installation of recently downloaded driver occurring | N/A | No action required |

### SYS (System Status) Tricolor LED — BLUE

| Color | Pattern | Condition | Message | Solution |
|---|---|---|---|---|
| Blue | On | Router is starting up | N/A | No action required |
| Blue | Slow Blinking | Linux (OS) is starting up | N/A | No action required |
| Blue | Fast Blinking | Linux running but could not start the firmware application | N/A | Download driver |

**Note:** Compared to the OF342-E2 LED reference above — the G5CE NET-RED table includes two additional conditions (2 Blinks: IP/rotary switch mismatch; 3 Blinks: DHCP failure) and its NET-BLUE table includes a 5th blink pattern (ARCNET traffic overload) not present on the OF342-E2. The G5CE SYS-RED table also includes an additional 1-Blink condition (non-operational due to excessive abnormal exits) not listed for the OF342-E2.
