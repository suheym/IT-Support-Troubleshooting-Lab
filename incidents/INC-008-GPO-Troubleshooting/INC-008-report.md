# INC-008 — Group Policy Security Filtering Failure

## Incident classification
- **Type:** Simulated lab incident
- **Area:** Active Directory / Group Policy
- **Affected user:** `AD\Lab.TestUser`
- **Affected computer:** `LAB-CLIENT01`
- **Domain controller:** `LAB-DC01.ad.lab`
- **Test GPO:** `LAB-INC008-Security-Filter-Test`
- **Target security group:** `INC008-Policy-Targets`
- **Status:** Recovery verified; earlier token-refresh discrepancy remains unexplained

## Symptoms
After the test GPO's security filtering was restricted, the client reported the GPO as `Denied (Security)` in `gpresult`. The expected registry marker was absent:

`HKCU\Software\Policies\Lab\INC008\IncidentMarker`

The separate GPO `LAB-INC004-User-Policy-Test` continued to apply.

## Expected result
The user, `AD\Lab.TestUser`, is a member of `INC008-Policy-Targets`. The target group has `Apply Group Policy` permission on the test GPO. `Authenticated Users` retains read permission but not Apply permission.

When the user's logon token contains the target group SID, the test GPO should apply and set `IncidentMarker` to `INC008-EXPECTED`.

## Diagnostic steps and evidence

1. **Established a baseline.** Verified the existing user policy and registry setting, checked that OU inheritance was not blocked, and confirmed the test GPO link location. Baseline evidence is in `evidence/INC-008_step1-client-baseline.txt`, `evidence/INC-008_step2-gpresult-baseline.txt`, and `evidence/INC-008_step3-gpo-inheritance-baseline.txt`.

2. **Verified healthy test-policy behavior before restricting filtering.** Refreshed user policy and confirmed that the marker was `INC008-EXPECTED`. See `evidence/INC-008_step4-healthy-policy-baseline.txt`.

3. **Captured the filtering failure.** At 14:33, `gpresult /r /scope user` listed `LAB-INC008-Security-Filter-Test` as `Denied (Security)`. The target group was absent from the groups listed in the user's token, and the marker was absent. See `evidence/INC-008_step5-security-filter-failure.txt`.

4. **Checked server-side configuration.** Verified that the user was a member of `INC008-Policy-Targets`, that the group had `GpoApply` permission, and that `Authenticated Users` had `GpoRead`. The GPO report contained the expected registry policy. See `evidence/INC-008_step6-server-permissions.txt`.

5. **Investigated token and session state.** Active Directory's calculated `tokenGroups` included the target group SID, while the client's initial `whoami /groups` output did not. A previous sign-out/sign-in attempt did not resolve the discrepancy. The reason that attempt failed to refresh the effective token was not established.

6. **Restarted the client and verified recovery.** After restart and sign-in, `whoami /groups` included `AD\INC008-Policy-Targets` with SID ending `-1105`. The test GPO appeared under Applied Group Policy Objects, and the registry marker was restored. See `evidence/INC-008_step7-recovery-verification.txt`.

## Root cause and contributing condition
The immediate cause of the GPO filtering denial was that the active user logon token did not contain the target security group SID required by the GPO's security filter.

The evidence does **not** establish why the earlier sign-out/sign-in attempt failed to update the effective token. Do not attribute that behavior to a specific authentication, replication, or operating-system defect without further evidence.

## Resolution
Restarted `LAB-CLIENT01`, signed in as `AD\Lab.TestUser`, refreshed user Group Policy, and confirmed that the required group SID was present and the test GPO applied.

No additional changes to GPO permissions were needed during recovery.

## Verification
- `whoami /groups` lists `AD\INC008-Policy-Targets`.
- `gpupdate /target:user /force` completed successfully.
- `gpresult /r /scope user` lists `LAB-INC008-Security-Filter-Test` as applied.
- `Get-ItemProperty` confirms `IncidentMarker : INC008-EXPECTED`.
- `gpresult` identifies `LAB-DC01.ad.lab` as the policy source.
- The existing `LAB-INC004-User-Policy-Test` remained applied.

The recovery evidence was saved and read back. The file was confirmed to exist and have non-zero length.

## Prevention and operational lessons
- When troubleshooting security-filtered GPOs, check both the GPO's permissions and the user's effective logon-token group membership.
- Compare `gpresult` with `whoami /groups`; directory membership alone does not prove that the current logon token contains a group SID.
- After a group-membership change, establish a fresh logon session when appropriate, then verify the effective token and policy result.
- Capture evidence before changing permissions, and preserve both failure and recovery output.
- Do not infer an underlying authentication defect when the available evidence only establishes the immediate condition and successful recovery.

## Evidence inventory
- `evidence/INC-008_step1-client-baseline.txt`
- `evidence/INC-008_step2-gpresult-baseline.txt`
- `evidence/INC-008_step3-gpo-inheritance-baseline.txt`
- `evidence/INC-008_step4-healthy-policy-baseline.txt`
- `evidence/INC-008_step5-security-filter-failure.txt`
- `evidence/INC-008_step6-server-permissions.txt`
- `evidence/INC-008_step7-recovery-verification.txt`

## Limitations
This is a simulated lab incident, not professional work experience. The recovery is verified, but the reason the earlier sign-out/sign-in attempt did not produce a token containing the target group SID remains undetermined.
