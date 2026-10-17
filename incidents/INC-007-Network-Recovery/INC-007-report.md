# INC-007 — Lab Network Address Recovery

## Classification
Troubleshooting exercise; original cause not determined.

## Symptoms
The LAB-CLIENT01 lab adapter (Ethernet 2) had IPv4 address 169.254.236.19 instead of the expected DHCP address in the 192.168.50.0/24 subnet.

## Diagnostics and evidence
1. Confirmed Ethernet 2 was Up and the adapter was operational.
2. Confirmed the DHCPServer service on LAB-DC01 was Running.
3. Confirmed the IT-LAB DHCP scope (192.168.50.100–192.168.50.199) was Active.
4. Confirmed DHCP was bound to the server lab interface at 192.168.50.10.
5. Confirmed the DHCP server had an active lease for LAB-CLIENT01 at 192.168.50.100.
6. Ping to 192.168.50.10 succeeded with 0% packet loss.
7. Ran ipconfig /renew "Ethernet 2". The client recovered address 192.168.50.100 and DNS suffix ad.lab.
8. Confirmed the client's configured DNS server was 192.168.50.10.
9. A DNS lookup briefly returned 192.168.50.1, but the authoritative A record on LAB-DC01 was 192.168.50.10. Subsequent direct and normal lookups returned 192.168.50.10.

## Root cause
Not determined. The available evidence establishes the initial APIPA condition and successful recovery after DHCP renewal, but does not establish why the client temporarily lacked its expected IPv4 address. The inconsistent DNS result was not reproduced.

## Resolution
Ran `ipconfig /renew "Ethernet 2"` on LAB-CLIENT01.

## Verification
- Ethernet 2 recovered IPv4 address 192.168.50.100/24.
- The DHCP server showed an active lease for LAB-CLIENT01 at 192.168.50.100.
- The client could ping 192.168.50.10 with 0% packet loss.
- The configured DNS server was 192.168.50.10.
- Subsequent DNS lookups for LAB-DC01.ad.lab returned 192.168.50.10.

## Prevention and lessons learned
- When an adapter has a 169.254.x.x address, check adapter state, DHCP service, scope, binding, and lease before changing configuration.
- Capture command output before and after recovery.
- Do not infer a root cause solely from a successful recovery action.
- Investigate inconsistent DNS results before modifying authoritative records.

## Evidence

- `evidence/INC-007-fault.txt` — retrospective record of the initial APIPA state (`169.254.236.19`); not an original command transcript captured directly at the time.
- `evidence/INC-007-dhcp-health.txt` — server-side DHCP service, scope, interface binding, and lease checks captured during the audit.
- `evidence/INC-007-connectivity.txt` — client adapter configuration, ping, and DNS lookup captured during the audit.
- `evidence/INC-007-recovery.txt` — post-recovery `ipconfig /all` output.

**Evidence limitation:** The initial APIPA state was not saved directly to a file when first observed. The fault record is explicitly retrospective, while the other files preserve subsequent diagnostic checks and the recovered state. The underlying cause remains undetermined.

## Lab disclaimer
This is a simulated lab troubleshooting exercise, not professional work experience. The original cause remains undetermined.
