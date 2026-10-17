# INC-006 — DHCP Configuration and Verification

## Type
Lab configuration and validation exercise; no DHCP outage was simulated.

## Environment
- DHCP server: LAB-DC01.ad.lab
- DHCP server IP: 192.168.50.10
- Client: LAB-CLIENT01.ad.lab
- Lab network: 192.168.50.0/24
- DHCP scope: IT-LAB

## Objective
Configure DHCP for the isolated IT-LAB network and verify that a Windows 11 client receives a valid lease and can resolve the domain controller.

## Configuration
- Installed the Windows DHCP Server role.
- Authorized LAB-DC01 in Active Directory.
- Created and activated the IT-LAB scope.
- Address pool: 192.168.50.100-192.168.50.199.
- Subnet mask: 255.255.255.0.
- DNS server option: 192.168.50.10.
- DNS domain option: ad.lab.
- Lease duration: 691200 seconds (8 days).
- Bound DHCP to the lab adapter at 192.168.50.10; the NAT adapter was not bound to DHCP service.

## Verification
- DHCPServer service: Running.
- Service startup mode: Automatic.
- Service exit code: 0.
- Client DHCP enabled: True.
- DHCP server reported by client: 192.168.50.10.
- Client address: 192.168.50.100.
- Client DNS server: 192.168.50.10.
- Client DNS suffix: ad.lab.
- Server-side lease state: Active.
- LAB-DC01.ad.lab resolved to 192.168.50.10.
- The lab adapter has no default gateway, as intended for the isolated network.
- VirtualBox adapter layout: Adapter 1 uses NAT for separate connectivity; Adapter 2 is attached to the isolated `IT-LAB` internal network. DHCP and DNS verification above refers to the lab adapter (`Ethernet 2`).

During a later verification check, `LAB-CLIENT01` was temporarily observed with the APIPA address `169.254.236.19` on its lab adapter, despite the DHCP server reporting an active lease for `192.168.50.100`. The DHCP Server service was running, the `IT-LAB` scope was active, and the lab interface binding was enabled. After `ipconfig /renew "Ethernet 2"`, the client received `192.168.50.100` with subnet mask `255.255.255.0` and DNS suffix `ad.lab`. `Resolve-DnsName LAB-DC01.ad.lab` then successfully returned `192.168.50.10`. The cause of the temporary APIPA state was not established. Client-side verification was saved as `evidence/INC-006-client-verification.txt`.

## Outcome
DHCP scope configuration, lease allocation, server-side lease state, service status, and DNS resolution were verified successfully.

## Limitations
This exercise validates configuration and successful operation. A DHCP failure and recovery were not simulated; therefore, this is not documented as a break/fix incident.

## Evidence
- `evidence/INC-006-dhcp-leases.txt`
- `evidence/INC-006-dhcp-scope.txt`
- `evidence/INC-006-dhcp-options.txt`
- `evidence/INC-006-dhcp-service.txt`
- `evidence/INC-006-client-verification.txt`

## Prevention and lessons learned
- Keep DHCP bound only to the intended lab network.
- Verify both client-side IP configuration and server-side lease records.
- Confirm DHCP DNS options match the Active Directory DNS configuration.
- Save and inspect evidence rather than relying only on command completion.
