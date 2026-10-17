# INC-009 — Windows Time Discovery Warnings and Controlled Service-Recovery Test

## Status
- Controlled service-recovery test: completed and verified.
- Original Event ID 129 investigation: inconclusive; root cause undetermined.
- Classification: simulated break/fix test with a separate, unresolved historical warning investigation.

## Environment
- Client: LAB-CLIENT01
- Domain: ad.lab
- Domain controller and time peer: LAB-DC01.ad.lab
- Client time source after recovery: LAB-DC01.ad.lab
- Evidence location: this incident folder

## Symptoms and impact
Historical Windows Time Event ID 129 warnings reported that NtpClient could not set a domain peer because of a discovery error: "The entry is not found. (0x800706E1)."

During the earlier investigation, the client temporarily reported that it was not synchronized and used Local CMOS Clock. Later checks showed successful domain-controller discovery, DNS resolution, direct NTP sampling, and synchronization with LAB-DC01.ad.lab. The original warnings stopped without a configuration change being made during this investigation.

The historical discovery warnings were not reproduced by the controlled test below. Their root cause and the reason for the spontaneous recovery remain undetermined.

## Expected versus actual
### Original warning investigation
- Expected: Windows Time discovers a valid domain time peer and synchronizes.
- Actual: Event ID 129 warnings occurred historically; subsequent checks showed an active LAB-DC01.ad.lab peer and successful synchronization.
- Conclusion: the available evidence does not establish why the original warnings occurred.

### Controlled service-recovery test
- Expected before fault: W32Time running and client synchronized with LAB-DC01.ad.lab.
- Deliberate fault: W32Time was stopped on LAB-CLIENT01.
- Observed result: service state was Stopped; querying time status returned "The service has not been started. (0x80070426)."
- Recovery: W32Time was started again.
- Verified result: service Running, startup type Manual, Leap Indicator 0 (no warning), active peer LAB-DC01.ad.lab, and a successful synchronization time of 2026-10-14 18:04:42.

## Diagnostic steps and evidence
1. Checked Windows Time service state, startup type, status, and peer.
2. Reviewed historical Event ID 129 warnings and later synchronization information.
3. Verified DNS resolution and domain-controller discovery during the original investigation.
4. Captured the pre-test baseline.
5. Stopped W32Time as a deliberate, reversible simulation.
6. Captured the stopped-service state and the actual query error.
7. Started W32Time and verified service state, synchronization status, and peer.
8. Read back the evidence files to verify their contents.

## Root cause
- Controlled test: the service outage was caused deliberately by stopping W32Time. This is a known cause of the simulated outage only.
- Original Event ID 129 warnings: undetermined. The evidence does not justify attributing them to DNS, domain-controller discovery, firewall configuration, or a specific Windows Time setting.

## Resolution
The controlled outage was resolved by starting W32Time. Subsequent checks confirmed that the service was running and the client reported successful synchronization with LAB-DC01.ad.lab.

No configuration change was made to claim resolution of the original Event ID 129 warnings.

## Verification
- [PASS] Fault evidence records W32Time as Stopped.
- [PASS] Query during the fault returned error 0x80070426.
- [PASS] Recovery evidence records W32Time as Running.
- [PASS] Startup type remained Manual.
- [PASS] Post-recovery status reported Leap Indicator 0 (no warning).
- [PASS] LAB-DC01.ad.lab was the active peer.
- [PASS] Post-recovery status reported a successful synchronization time.
- [INCOMPLETE] Original Event ID 129 root cause was not established.
- [INCOMPLETE] Long-term absence of recurrence was not established.
- [NOTE] Peer output included "PeerPoll Interval: 17 (out of valid range)." This was recorded but not diagnosed as a fault.

## Prevention and follow-up
- If Event ID 129 recurs, preserve the event details and timestamp before changing configuration.
- At recurrence, correlate the event with service state, domain-controller discovery, DNS SRV/A lookups, active peer, and synchronization status.
- Avoid changing time-service settings without evidence identifying a configuration problem.
- Review whether the peer-poll message recurs and investigate it only if corroborating evidence indicates a problem.
- Keep the controlled simulation clearly distinguished from the unresolved historical warning.

## Evidence files
- `INC-009_step1_baseline.txt` — pre-test service, synchronization, peer, and domain-controller discovery state.
- `INC-009_step2_fault.txt` — deliberate service stop and status-query failure.
- `INC-009_step3_recovery.txt` — post-recovery service, synchronization, and peer state.

## Scope and integrity note
This is a lab simulation and troubleshooting exercise, not evidence of professional employment experience. Findings are limited to the observations captured in the listed files and the investigation described above. Do not describe the original Event ID 129 issue as fixed.
