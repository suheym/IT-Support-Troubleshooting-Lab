# INC-005 - Print Spooler Service Unavailable

## Incident classification
- **Type:** Controlled lab break/fix simulation
- **System:** LAB-CLIENT01
- **Component:** Windows Print Spooler (`Spooler`)
- **Severity:** Simulated workstation printing-service interruption
- **Status:** Resolved and verified
- **Environment:** Isolated IT support lab; not a real production incident

## Summary
The Print Spooler service was deliberately stopped to simulate a printing-service interruption. While the service was stopped, a `Get-Printer` query failed because the spooler service was not reachable. The service was restarted, printer enumeration worked again, and a recovery PDF was generated and opened successfully.

## User-facing symptom and impact
The printer-management query could not enumerate installed printers while the Print Spooler service was stopped.

**Scope limitation:** A print attempt was not documented while the service was stopped. This report therefore does not claim that a print job was attempted or failed during the fault.

## Baseline
Before introducing the fault:
- `Spooler` was **Running**.
- Startup mode was **Automatic**.
- Service exit code was `0`.
- Microsoft Print to PDF was installed, using the Microsoft Print To PDF driver and `PORTPROMPT:`.
- A baseline PDF was generated and opened successfully.

A baseline PDF was generated and opened during the lab test. The PDF is retained locally but omitted from the public repository because its rendered view may expose host-specific paths. Its recorded metadata and the user-confirmed test text are documented in `INC-005_step1_baseline.txt`.

## Diagnostic procedure and results

| Step | Diagnostic action | Expected result | Actual result |
|---|---|---|---|
| 1 | Inspect `Spooler` service state before the test | Service running | Running; startup mode Automatic; exit code 0 |
| 2 | Enumerate installed printers using `Get-Printer` before the test | Printer list returned | Microsoft Print to PDF listed |
| 3 | Stop `Spooler` to simulate service unavailability | Service becomes stopped | Service state was checked and showed Stopped |
| 4 | Run `Get-Printer` while the service is stopped | Query may fail because the spooler is unavailable | Error reported that the spooler service was not reachable; HRESULT `0x800706ba` |
| 5 | Start `Spooler` | Service returns to Running | Service state showed Running |
| 6 | Run `Get-Printer` after recovery | Installed printer list returns | Microsoft Print to PDF listed again |
| 7 | Generate and open a recovery PDF | PDF generation succeeds and contents can be inspected | User confirmed successful generation and opening |

The fault record was written retrospectively after recovery. It preserves the reported observations and explicitly identifies that evidence limitation.

## Root cause
**Confirmed cause within this simulation:** the Print Spooler service was deliberately stopped as the fault injection.

This exercise does not establish an underlying spontaneous service failure, a printer-driver defect, or a hardware fault. Those were not demonstrated.

## Resolution
Restarted the Print Spooler service using `Start-Service -Name Spooler`.

No driver reinstall, printer removal, registry modification, or system-file repair was needed for this scenario.

## Verification
Post-recovery checks established that:
- The service was **Running**.
- Startup mode remained **Automatic**.
- Service exit code was `0`.
- Microsoft Print to PDF appeared in `Get-Printer`.
- The recovery PDF was recorded as existing at 37,679 bytes; the original is retained locally and omitted from the public repository.
- The user confirmed the recovery PDF opened and displayed the expected test text.

The recovery PDF metadata and service/printer checks are recorded in `INC-005_step4_verification.txt`.

## Prevention and support lessons
1. Check the Print Spooler service state when printer enumeration or printing management fails.
2. Use `Get-Service Spooler` or `Get-CimInstance Win32_Service -Filter "Name='Spooler'"` to inspect service status and startup mode.
3. Check whether printer enumeration works after the service is restored before pursuing more invasive driver or operating-system repairs.
4. Preserve the original error text and service state before making changes in a real incident.
5. Verify recovery with a practical end-to-end test, not just a service-state check.
6. Record evidence at the time of the fault whenever possible; label retrospective notes clearly.

## Evidence index
- `INC-005_step1_baseline.txt` - baseline service/printer state and baseline PDF metadata.
- `INC-005_step2_fault.txt` - retrospective record of the simulated fault and `Get-Printer` error.
- `INC-005_step3_recovery.txt` - service and printer state after recovery.
- `INC-005_step4_verification.txt` - final service/printer checks and recovery PDF metadata.
- Baseline and recovery PDFs - local-only supporting artifacts; omitted from the public repository to avoid exposing host-specific paths. Their original files remain on the lab system.

## Evidence limitations
- The fault record was created after the service had been restored, not captured contemporaneously.
- No print attempt was documented while the service was stopped.
- The baseline and recovery PDFs are not included in the public repository. The original local artifacts are retained separately; the TXT records remain as supporting evidence.
- This is a deliberately simulated training scenario, not a real user ticket or professional work experience.

## Interview talking point
"In my Windows support lab, I simulated an unavailable Print Spooler service, checked how printer enumeration behaved during the interruption, restarted the service, and verified recovery using service-state checks, printer enumeration, and a successfully generated PDF. I documented the evidence and called out the limitations of my fault capture."

---

