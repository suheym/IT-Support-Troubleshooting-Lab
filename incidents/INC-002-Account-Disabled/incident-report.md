# INC-002 — Domain account disabled

**Status:** RESOLVED AND VERIFIED  
**Incident type:** Simulated Active Directory account issue  
**Affected account:** AD\Lab.TestUser  
**Affected client:** LAB-CLIENT01  
**Directory server:** LAB-DC01  
**Date:** 2026-10-13

## 1. Symptoms

A fresh authentication attempt using `AD\Lab.TestUser` was blocked while the account was intentionally disabled for this lab exercise.

The existing client session was left open during testing. The negative test used `runas` to attempt a new authentication, avoiding the assumption that disabling an account automatically terminates an existing session.

## 2. Diagnostic steps and evidence

1. Checked the account on LAB-DC01 using `Get-ADUser -Identity "Lab.TestUser" -Properties Enabled`.
2. Confirmed the account was enabled before introducing the fault.
3. Intentionally disabled the lab account with `Disable-ADAccount -Identity "Lab.TestUser"`.
4. Confirmed `Enabled : False` on LAB-DC01.
5. Attempted fresh authentication from LAB-CLIENT01 using `runas /user:AD\Lab.TestUser "cmd /k whoami"`.
6. Observed error 1327: account restrictions were preventing sign-in.
7. Rechecked Active Directory and independently confirmed the account was disabled.
8. Re-enabled the account with `Enable-ADAccount -Identity "Lab.TestUser"`.
9. Confirmed `Enabled : True` and successfully authenticated a new process. `whoami` returned `ad\lab.testuser`.

## 3. Root cause

The lab account was deliberately disabled in Active Directory to simulate an account-access incident. The disabled account state was confirmed on the domain controller.

Error 1327 is a generic account-restriction message; by itself, it does not prove that the account was disabled. The independently verified `Enabled : False` state supports the diagnosis.

## 4. Resolution

Re-enabled the account on LAB-DC01 using:

`Enable-ADAccount -Identity "Lab.TestUser"`

No password reset or group-membership change was performed as part of the repair.

## 5. Verification and test results

| Test | Expected result | Observed result |
|---|---|---|
| Baseline account state | Enabled | Pass — `True` |
| Baseline fresh authentication | New process starts as test user | Pass — `ad\lab.testuser` was captured |
| Disabled-account state | Enabled is False | Pass — `False` confirmed on DC |
| Negative fresh authentication | Authentication blocked | Pass — `runas` returned error 1327 |
| Recovery account state | Enabled is True | Pass — `True` confirmed on DC |
| Recovery fresh authentication | New process starts as test user | Pass — `whoami` returned `ad\lab.testuser` |

## 6. Evidence inventory

Evidence is stored in the accompanying `evidence` folder.

- `INC-002_baseline-account-state.txt` — initial account state.
- `INC-002_positive-authentication.txt` — successful baseline authentication output.
- `INC-002_fault-account-disabled.txt` — account state after introducing the fault.
- `INC-002_confirmed-disabled-state.txt` — independently rechecked disabled state.
- `INC-002_negative-authentication-transcript.txt` — negative test transcript and error 1327.
- `INC-002_recovery-authentication-transcript.txt` — recovery test transcript.
- `INC-002_recovery-whoami.txt` — recorded successful recovery `whoami` output.

The evidence files were listed and their non-zero sizes verified. The recovery transcript does not itself contain the separate Command Prompt output; that output is recorded in `INC-002_recovery-whoami.txt`.

## 7. Prevention and lessons learned

- Check the account's enabled state before resetting passwords or changing unrelated client settings.
- Confirm the diagnosis using both directory state and the client's observed authentication result.
- Keep the existing session open while testing fresh authentication when practical.
- After repair, verify both the directory account state and a new authentication attempt.
- Preserve baseline, fault, negative-test, and recovery evidence.
- Use dedicated lab accounts for simulated incidents and avoid using real personal data.

## 8. Scope and limitations

This was a controlled lab simulation, not a production incident or professional work experience. The tests demonstrate account-state diagnosis and recovery for this scenario; they do not establish that every possible account-restriction cause has been tested.

## 9. Final outcome

**Resolved and verified:** the account was intentionally disabled, the disabled state was confirmed, fresh authentication failed during the fault, the account was re-enabled, and fresh authentication succeeded afterward.
