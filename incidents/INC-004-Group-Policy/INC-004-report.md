# INC-004 — Group Policy Application Failure

**Status:** Resolved and verified
**Environment:** Windows Server 2025 (`LAB-DC01`) and Windows 11 Pro (`LAB-CLIENT01`)
**Domain:** `ad.lab`
**Affected account:** `AD\\Lab.TestUser`
**Incident classification:** Simulated lab incident; not professional work experience

## 1\. Symptoms

After the dedicated test GPO link was disabled on the `Lab-Users` OU and user policy was refreshed, the test policy was no longer applied.

Observed results:

* `gpresult /r /scope user` reported Applied Group Policy Objects: N/A.
* `LAB-INC004-User-Policy-Test` was filtered out with the reason `Disabled (Link)`.
* The expected `ScreenSaveActive` registry value was absent after the refresh.

## 2\. Diagnostic steps and baseline

Before introducing the fault:

* Confirmed `LAB-CLIENT01` was joined to `ad.lab` and `AD\\Lab.TestUser` was signed in.
* `nltest /dsgetdc:ad.lab` successfully located `LAB-DC01.ad.lab` at `192.168.50.10`.
* `NTDS` and `DNS` were Running with Automatic startup.
* DC diagnostic tests Connectivity, Advertising, SysVolCheck, and NetLogons passed.
* Created a dedicated GPO named `LAB-INC004-User-Policy-Test` and linked it to `OU=Lab-Users,DC=ad,DC=lab`.
* Configured `HKCU\\Software\\Policies\\Microsoft\\Windows\\Control Panel\\Desktop\\ScreenSaveActive` as string `0`.
* Refreshed user policy. `gpresult` listed the test GPO as applied, and the registry query returned `ScreenSaveActive REG\_SZ 0`.

## 3\. Root cause

**Confirmed root cause:** the link for `LAB-INC004-User-Policy-Test` on `OU=Lab-Users,DC=ad,DC=lab` was disabled.

The fault-state `gpresult` explicitly identified the filtering reason as `Disabled (Link)`. This prevented the test GPO from applying after policy refresh.

This fault was deliberately introduced as a reversible lab exercise. It was not an independently discovered production issue.

## 4\. Resolution

Re-enabled the GPO link on the `Lab-Users` OU with `Set-GPLink -LinkEnabled Yes`, then refreshed user policy on `LAB-CLIENT01`.

Neither `Default Domain Policy` nor `Default Domain Controllers Policy` was modified.

## 5\. Verification

After recovery:

* `Get-GPInheritance` showed `LAB-INC004-User-Policy-Test \[Enabled=True]`.
* `gpresult /r /scope user` listed the test GPO under Applied Group Policy Objects.
* The registry value returned as `ScreenSaveActive REG\_SZ 0`.
* `NTDS` and `DNS` remained Running/Automatic.
* Final `dcdiag` checks for Connectivity, Advertising, SysVolCheck, and NetLogons all passed.
* Final DC health output was saved and read back from `INC-004\_final-health.txt`.

## 6\. Evidence

Evidence is stored in the `evidence` subfolder. The verified inventory included:

* `INC-004\_baseline-client-identity.txt`
* `INC-004\_baseline-client-ipconfig.txt`
* `INC-004\_baseline-dc-discovery.txt`
* `INC-004\_baseline-dc-services.txt`
* `INC-004\_baseline-dcdiag.txt`
* `INC-004\_baseline-gpo-inventory.txt`
* `INC-004\_baseline-ou-inventory.txt`
* `INC-004\_baseline-gpresult-user.txt`
* `INC-004\_baseline-gpupdate-user.txt`
* `INC-004\_known-good-gpresult.txt`
* `INC-004\_known-good-registry.txt`
* `INC-004\_fault-disabled-link.txt`
* `INC-004\_fault-gpresult.txt`
* `INC-004\_fault-registry.txt`
* `INC-004\_recovery-gpresult.txt`
* `INC-004\_recovery-registry.txt`
* `INC-004\_final-health.txt`

## 7\. Prevention and lessons learned

* Inspect GPO link state and the filtering reason in `gpresult` when a user policy is missing.
* Do not assume DNS or domain-controller failure when domain discovery and DC health checks pass.
* Verify policy from the affected user's session; a successful `gpupdate` alone does not prove the intended GPO applied.
* Compare before-and-after `gpresult` and registry evidence.
* Keep lab policies separate from default domain policies and restore their intended state after testing.

## 8\. Scope and limitations

This exercise demonstrates a controlled GPO-link failure and recovery. The earlier baseline showing `Applied Group Policy Objects: N/A` was captured before the dedicated test GPO was created and linked; it is not, by itself, evidence of a fault.

The baseline evidence shows `Lab.TestUser` in the default `Users` container, while the fault and recovery evidence show the account in `OU=Lab-Users`. The reason for this difference was not established during this audit. The GPO-link fault and recovery are supported by the recorded policy results.

The registry checks verified the configured value's presence or absence. End-user screen-saver behavior was not independently tested through the Windows interface.

**Outcome:** The simulated fault was reproduced, its filtering reason was captured, the link was restored, and policy application was verified again.
