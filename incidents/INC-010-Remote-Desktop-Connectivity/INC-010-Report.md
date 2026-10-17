# INC-010 — Remote Desktop Connectivity Failure

**Status:** Controlled fault reproduced and repaired; evidence audit completed with one documented inconsistency  
**Environment:** Windows Server 2025 Standard Evaluation (`LAB-DC01`) and Windows 11 Pro (`LAB-CLIENT01`)  
**Lab network:** `192.168.50.0/24`  
**Server:** `LAB-DC01` — `192.168.50.10`  
**Client:** `LAB-CLIENT01` — `192.168.50.100`  
**Service/port:** Remote Desktop Services / TCP 3389  
**Fault type:** Deliberately simulated firewall-rule misconfiguration

## 1. User-reported symptom

A user cannot establish a new Remote Desktop connection to the lab server, although the server remains reachable over the lab network.

This was a controlled lab simulation, not a production incident or professional work experience.

## 2. Baseline and preparation

Before introducing the fault, the existing RDP configuration was found disabled. To establish a known-good baseline, the lab operator:

1. Created the `INC-010-Pre-RDP-Setup` recovery snapshot.
2. Set `fDenyTSConnections` to `0`.
3. Started `TermService`.
4. Enabled the `Remote Desktop - User Mode (TCP-In)` firewall rule.
5. Verified TCP 3389 from `LAB-CLIENT01` to `LAB-DC01`.
6. Established an interactive RDP session as `AD\Administrator` and verified the remote hostname as `LAB-DC01`.
7. Created the `INC-010-RDP-Baseline-Verified` snapshot.

The original RDP-disabled configuration was pre-existing setup state, not the simulated incident fault.

## 3. Symptoms and diagnostics

The client baseline test to `192.168.50.10:3389` returned `TcpTestSucceeded: True`.

The controlled fault was introduced by disabling only the inbound `Remote Desktop - User Mode (TCP-In)` rule. During the fault:

- The firewall rule was verified as disabled.
- `TermService` remained running.
- `fDenyTSConnections` remained `0`.
- The client could still ping `192.168.50.10`.
- The client's TCP 3389 test returned `TcpTestSucceeded: False`.

This combination isolated the simulated failure to the inbound TCP RDP firewall rule, rather than a stopped RDP service, disabled RDP configuration, or total loss of IP connectivity.

## 4. Root cause

**Confirmed simulated root cause:** The inbound Windows Defender Firewall rule `Remote Desktop - User Mode (TCP-In)` was disabled, preventing new inbound TCP connections to the RDP listener.

The root cause was confirmed by correlating the server-side firewall-rule state with the client-side failed TCP 3389 test, while basic ping connectivity and the RDP service remained available.

## 5. Resolution

Re-enabled the specific rule:

`Enable-NetFirewallRule -DisplayName 'Remote Desktop - User Mode (TCP-In)'`

No global firewall disablement was performed. The repair did not require changing the RDP registry setting or stopping/restarting the RDP service.

## 6. Verification

After the repair:

- The firewall rule was verified as enabled, inbound, and `Allow`.
- `TermService` was verified as `Running`.
- `fDenyTSConnections` was verified as `0`.
- The client TCP 3389 test returned `TcpTestSucceeded: True`.
- A subsequent four-packet ping test succeeded with approximately 1 ms response times.

A post-repair interactive RDP session was recorded under `AD\Administrator` at `2026-10-15 20:24:25 +03:00`; see `03-Recovery/INC-010-server-recovery-rdp-session.txt`.

### Evidence limitation

The saved `INC-010-client-recovery-tcp3389.txt` output reported `PingSucceeded: False` while `TcpTestSucceeded: True`. A later fresh TCP test succeeded, and a separate four-packet ping test also succeeded. The cause of the discrepancy was not determined. The original evidence was preserved, and the later successful ping was saved separately as `INC-010-client-recovery-ping-final.txt`.

## 7. Prevention

- Keep the required inbound RDP rule enabled only on the intended lab network profile.
- Avoid disabling the entire Windows Firewall to troubleshoot a single application or port.
- Verify the service state, RDP configuration, firewall rule, listener, and client-side TCP connection independently.
- Capture before/during/after evidence for controlled configuration changes.
- Maintain a verified baseline snapshot before fault injection.
- In a real environment, restrict RDP access to authorized management networks and accounts; do not expose TCP 3389 directly to the public internet.

## 8. Evidence inventory

Evidence is stored in this incident folder:

`\\VBOXSVR\IT-Support-Lab\incidents\INC-010`

The evidence audit found 19 files totaling 10,769 bytes:

- Server baseline: 5 files
- Client baseline, fault, and recovery: 7 files
- Server fault and recovery: 7 files

Key files include:

- `INC-010-baseline-firewall.txt`
- `INC-010-baseline-service.txt`
- `INC-010-baseline-rdp-setting.txt`
- `INC-010-client-baseline-tcp3389.txt`
- `INC-010-client-fault-tcp3389.txt`
- `INC-010-server-fault-firewall.txt`
- `INC-010-server-recovery-firewall.txt`
- `INC-010-client-recovery-tcp3389.txt`
- `INC-010-client-recovery-ping-final.txt`

## 9. Final audit

| Requirement | Result |
|---|---|
| Verified working network-level baseline | Pass |
| Snapshot before RDP setup changes | Pass |
| Verified baseline snapshot before fault | Pass |
| Single controlled firewall-rule fault | Pass |
| Fault state recorded on server | Pass |
| Client-side failure demonstrated | Pass |
| Root cause supported by evidence | Pass |
| Specific rule restored | Pass |
| Client TCP recovery verified | Pass |
| Server recovery state recorded | Pass |
| Evidence consolidated and inventory checked | Pass |
| Recovery ping discrepancy investigated to root cause | Incomplete |
| New interactive RDP login after repair | Pass — verified as AD\Administrator; evidence saved in INC-010-server-recovery-rdp-session.txt |

**Conclusion:** INC-010 demonstrates a reproducible, controlled RDP connectivity failure caused by a disabled inbound firewall rule, followed by successful TCP connectivity recovery after the rule was re-enabled. The ping discrepancy remains an explicitly documented limitation. This is a lab exercise and should not be represented as professional work experience.