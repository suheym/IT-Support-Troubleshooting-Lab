# INC-001 — Incorrect DNS Configuration Prevents Domain Name Resolution

## Incident Summary

| Field | Details |
|---|---|
| Incident ID | INC-001 |
| Incident title | Incorrect DNS Configuration Prevents Domain Name Resolution |
| Environment | Windows Server 2025 Active Directory lab with a Windows 11 Pro client |
| Domain | `ad.lab` |
| Domain controller | `LAB-DC01` |
| Domain controller IP | `192.168.50.10` |
| Client | `LAB-CLIENT01` |
| Client internal adapter | `Ethernet 2` |
| Faulty DNS server configured on client | `192.168.50.99` |
| Correct internal DNS server | `192.168.50.10` |
| Incident type | Simulated DNS configuration fault |
| Status | Resolved and verified |

## 1. Incident Overview

A simulated DNS configuration fault was introduced on the Windows 11 client, `LAB-CLIENT01`, in the `ad.lab` Active Directory lab environment.

The client's internal network adapter was configured to use the incorrect DNS server address `192.168.50.99` instead of the domain controller's DNS address, `192.168.50.10`.

The incorrect configuration prevented the client from successfully resolving the `ad.lab` domain through its configured DNS server.

The fault was investigated using DNS queries and Windows domain-controller discovery tools. The client's internal DNS configuration was then restored, and DNS resolution and domain-controller discovery were tested again.

**Outcome:** DNS resolution was restored, and the client successfully discovered `LAB-DC01.ad.lab` at `192.168.50.10`.

**Lab disclaimer:** This was a deliberately simulated troubleshooting incident in a home lab. It is not presented as professional work experience.

## 2. Symptoms and Expected Behaviour

### Symptoms

During the simulated fault:

- The client's internal adapter used the incorrect DNS server address `192.168.50.99`.
- A direct DNS query to the incorrectly configured server timed out.
- A normal lookup of `ad.lab` failed.
- A direct query to the correct DNS server, `192.168.50.10`, succeeded, helping isolate the issue to the client's DNS configuration rather than a complete failure of the domain's DNS service.

The original troubleshooting session reported `DNS_ERROR_RCODE_NAME_ERROR` for the normal lookup. During the follow-up evidence-collection session, the saved normal-lookup output displayed `DNS name does not exist`. These are recorded as the outputs observed in their respective sessions.

### Expected behaviour

The client should use `192.168.50.10` as its DNS server on the internal lab adapter.

With the correct DNS configuration:

- DNS queries for `ad.lab` should succeed.
- The domain's DNS records should be resolvable.
- The client should be able to discover the domain controller through Windows domain discovery tools.

## 3. Diagnostic Process

### 3.1 Baseline configuration — reconstructed during follow-up

The intended baseline configuration for the client's internal adapter was:

- Adapter: `Ethernet 2`
- DNS server: `192.168.50.10`

The baseline DNS configuration and a direct SOA query against the correct DNS server were captured during the follow-up evidence-collection session.

The baseline SOA query returned information for the `ad.lab` zone, including:

- Primary name server: `lab-dc01.ad.lab`
- Responsible mailbox field: `hostmaster.ad.lab`
- SOA serial number: `60`

The baseline files were collected during the follow-up session. They should not be interpreted as files captured during the original troubleshooting session.

Evidence:

- `INC-001_baseline-dns-config.txt`
- `INC-001_baseline-soa-query.txt`

### 3.2 Confirming the faulty client configuration

The internal adapter's DNS configuration was checked after the fault was introduced.

The adapter was configured to use:

`192.168.50.99`

This was inconsistent with the intended lab configuration, in which the domain controller at `192.168.50.10` provides DNS for the `ad.lab` domain.

Evidence:

- `INC-001_fault-dns-config.txt`

### 3.3 Testing the incorrectly configured DNS server

A direct query to the incorrectly configured DNS server was performed.

The query timed out, indicating that the client did not receive a successful DNS response from `192.168.50.99` during the test.

A normal lookup of `ad.lab` was also performed and failed.

The original troubleshooting output reported `DNS_ERROR_RCODE_NAME_ERROR`. The separately saved follow-up output reported `DNS name does not exist`. The report preserves this distinction rather than treating the two captured outputs as identical.

Evidence:

- `INC-001_fault-timeout.txt`
- `INC-001_fault-normal-lookup.txt`

### 3.4 Testing the correct DNS server directly

While the client was still configured to use the incorrect DNS server, a direct SOA query was sent to `192.168.50.10`.

The query succeeded and returned SOA information for `ad.lab`.

This test provided evidence that the correct DNS server could answer the query even while the client was configured with the wrong DNS server address.

The result supported the diagnosis of a client-side DNS configuration fault rather than a complete failure of the domain's DNS service.

Evidence:

- `INC-001_fault-correct-server-test.txt`

### 3.5 Evidence collection

The evidence was collected across the original troubleshooting session and a follow-up session.

During the follow-up session, baseline and fault-state evidence was reproduced, saved to the shared evidence directory, and read back to confirm that the files existed and contained the expected command output.

The follow-up session also repeated the restoration and verification steps. The later domain-controller discovery, SOA query, and LDAP SRV query results have been consolidated into the existing evidence files. Their collection timestamps and commands have been retained where captured.

This distinction is important: the follow-up session documents reproduced fault and recovery checks rather than claiming that all evidence was saved during the original investigation.

## 4. Root Cause

**Root cause:** The Windows 11 client's internal network adapter was configured with an incorrect DNS server address.

The intended DNS server was the domain controller at `192.168.50.10`, but the client was configured to use `192.168.50.99`.

As a result, DNS queries sent to the configured server did not successfully resolve the `ad.lab` domain during the fault test.

The successful direct SOA query against `192.168.50.10` supported the conclusion that the incorrect client DNS setting was the cause of the observed failure.

## 5. Resolution

The incorrect DNS configuration was replaced with the correct internal DNS server address.

The following PowerShell command was used to restore the DNS setting on the client:

```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 192.168.50.10
```

The command configures the `Ethernet 2` network adapter to use `192.168.50.10` as its DNS server.

The final adapter configuration was then checked to confirm that the correct DNS address was configured.

Evidence:

- `INC-001_final-restored-dns.txt`

## 6. Verification

Verification was performed after restoring the DNS configuration. The recovery checks were saved to the evidence directory and read back for confirmation.

### Test 1 — Verify the restored DNS configuration

**Expected result:** The internal adapter uses `192.168.50.10`.

**Actual result:** The saved output showed that `Ethernet 2` was configured to use `192.168.50.10`.

**Result:** Pass.

Evidence:

- `INC-001_final-restored-dns.txt`

### Test 2 — Query the domain's DNS records

**Expected result:** A query to the correct DNS server returns SOA information for `ad.lab`.

**Actual result:** The baseline SOA query succeeded, and the separate direct query to the correct server during the reproduced fault also succeeded. The consolidated baseline SOA evidence file preserves the baseline result and the dated October 14 follow-up result.

**Result:** Pass.

Evidence:

- `INC-001_baseline-soa-query.txt`
- `INC-001_fault-correct-server-test.txt`

### Test 3 — Resolve `ad.lab` after recovery

**Expected result:** The client resolves `ad.lab` to the domain controller's IP address.

**Actual result:** The saved post-repair lookup returned `192.168.50.10` for `ad.lab`.

**Result:** Pass.

Evidence:

- `INC-001_final-dns-lookup.txt`

### Test 4 — Discover the domain controller

The following Windows command was used to test domain-controller discovery:

```powershell
nltest /dsgetdc:ad.lab
```

**Expected result:** Windows discovers a domain controller for `ad.lab`.

**Actual result:** The command completed successfully and identified `LAB-DC01.ad.lab` at `192.168.50.10`. The consolidated discovery evidence file contains the original verification and the dated October 14 discovery and DNS SRV query results.

**Result:** Pass.

Evidence:

- `INC-001_final-dc-discovery.txt`

### Verification conclusion

The final DNS configuration, domain-name lookup, and domain-controller discovery checks all succeeded.

This verifies that the specific DNS configuration fault was corrected and that the tested domain-resolution and discovery functions worked after recovery.

It does not, by itself, prove that every Active Directory service or every possible domain-join and logon scenario is healthy.

### Follow-up checks — 14 October 2026

These checks were collected during a later follow-up session and are separate from the original recovery tests.

- **SOA query:** A direct query to `192.168.50.10` returned SOA information for `ad.lab`, identifying `lab-dc01.ad.lab` as the primary server. The original SOA serial number `60` and the later serial number `71` are both preserved in the consolidated evidence file. No cause is inferred for the serial-number difference.
- **LDAP service-locator query:** The query for `_ldap._tcp.dc._msdcs.ad.lab` returned `lab-dc01.ad.lab` on port `389`. This verifies the DNS locator record, not a successful LDAP connection or authentication.
- **Domain-controller discovery:** `nltest /dsgetdc:ad.lab` succeeded and identified `LAB-DC01.ad.lab` at `192.168.50.10`.

During this follow-up session, the client temporarily had an APIPA address (`169.254.236.19`) and a direct DNS query timed out. Later, the client obtained `192.168.50.100`, and the DNS and discovery checks succeeded. The cause of the temporary address and timeout was not established.

Consolidated follow-up evidence:

- `INC-001_baseline-soa-query.txt`
- `INC-001_final-dc-discovery.txt`

## 7. Prevention and Lessons Learned

### Prevention

- Configure domain-joined Windows clients to use the lab domain controller's DNS service for internal Active Directory name resolution.
- Verify the DNS server assigned to the correct network adapter when troubleshooting domain-resolution failures.
- Test DNS directly against the intended DNS server to help distinguish a client configuration issue from a DNS service issue.
- Confirm both DNS resolution and domain-controller discovery after changing DNS settings.
- Capture command output during troubleshooting and verify that evidence files are actually saved.
- Keep baseline, fault-state, and recovery evidence clearly separated so that the report accurately represents when each observation was made.

### Lessons learned

- A DNS failure affecting an Active Directory domain does not automatically mean that Active Directory itself is broken.
- Checking the DNS server configured on the relevant adapter is an important early diagnostic step.
- A direct query to the intended DNS server can help isolate a client-side configuration fault.
- Recovery should be demonstrated by testing the affected function again, rather than assuming that changing a setting resolved the problem.
- Incident reports should distinguish original observations from later reproduced tests and should not claim evidence was captured at a time when it was not.

## 8. Skills Demonstrated

This simulated incident demonstrates practice with:

- Windows 11 network adapter configuration
- DNS client troubleshooting
- Active Directory domain name resolution
- SOA DNS queries
- DNS SRV record verification
- PowerShell command execution
- Windows domain-controller discovery using `nltest`
- Root-cause analysis
- Post-repair verification
- Evidence collection and incident documentation

These are lab-practised skills, not a claim of professional employment experience.

## 9. Evidence Inventory

The host evidence directory is:

`Documents\IT-Support-Lab\incidents\INC-001-DNS-Configuration\evidence`

The evidence was accessed through the VirtualBox shared folder at:

`\\VBOXSVR\IT-Support-Lab\incidents\INC-001-DNS-Configuration\evidence`

The current host-side inventory contains **9 evidence files**.

### Baseline evidence

1. `INC-001_baseline-dns-config.txt`
2. `INC-001_baseline-soa-query.txt`

### Fault-state and diagnostic evidence

3. `INC-001_fault-correct-server-test.txt`
4. `INC-001_fault-dns-config.txt`
5. `INC-001_fault-normal-lookup.txt`
6. `INC-001_fault-timeout.txt`

### Final recovery and verification evidence

7. `INC-001_final-dc-discovery.txt`
8. `INC-001_final-dns-lookup.txt`
9. `INC-001_final-restored-dns.txt`

The final recovery files were read back and checked for the expected DNS configuration, successful domain lookup, and successful domain-controller discovery output. The final domain-controller discovery file also contains the dated follow-up discovery and LDAP SRV DNS query results. The baseline SOA file contains the baseline and follow-up SOA results.

The baseline and fault-state files were collected during the follow-up session and are identified separately from the original troubleshooting observations. Redundant post-repair and separate follow-up files were removed after their relevant results were consolidated into the retained evidence files.

## 10. Final Status

**Status: Resolved and verified in the lab.**

The incorrect client DNS configuration was reproduced, diagnosed, and corrected. Final checks confirmed that the internal adapter used `192.168.50.10`, `ad.lab` resolved to `192.168.50.10`, and `nltest /dsgetdc:ad.lab` successfully discovered `LAB-DC01.ad.lab`.

The evidence folder currently contains nine files. The baseline and fault-state evidence was captured and verified during the follow-up session; it is identified separately from the original troubleshooting observations.

**Incident closure:** Technical recovery verified. The evidence inventory has been consolidated to nine files, with the later SOA, domain-controller discovery, and LDAP SRV query results preserved in existing evidence files. The unexplained APIPA and DNS-timeout anomaly remains documented separately from the original DNS configuration fault.
