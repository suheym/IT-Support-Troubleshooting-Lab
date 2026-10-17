# INC-003 — SMB file-share access denied

**Status:** RESOLVED AND VERIFIED
**Incident type:** Simulated SMB share-permission fault
**Date:** 2026-10-13
**Client:** LAB-CLIENT01
**Server:** LAB-DC01
**Domain:** ad.lab
**Affected account:** AD\\Lab.TestUser
**Share:** \\LAB-DC01.ad.lab\\DeptShare
**Local path:** C:\\LabShares\\DeptShare

## 1\. Symptoms

A file-creation attempt from LAB-CLIENT01 failed with
System.UnauthorizedAccessException and the message "Access is denied."

The failure occurred after the explicit SMB share permission for
AD\\Lab.TestUser was deliberately removed during this lab simulation.

## 2\. Baseline and diagnostic checks

Before introducing the fault:

* Verified AD DS and DNS services were running with automatic startup.
* Verified LAB-CLIENT01 could discover LAB-DC01 at 192.168.50.10.
* Verified the client was joined to ad.lab and signed in as AD\\Lab.TestUser.
* Confirmed TCP port 445 was reachable from the client.
* Recorded existing server shares and left ADMIN$, C$, IPC$, NETLOGON,
and SYSVOL unchanged.
* Recorded the folder's NTFS access-control entries.
* Created DeptShare with Change access for AD\\Lab.TestUser and Full
access for AD\\Domain Admins.
* Successfully created, read, modified, and deleted a baseline test file
from the client.

## 3\. Fault introduced

On LAB-DC01, removed the explicit share-level permission for AD\\Lab.TestUser
using Revoke-SmbShareAccess.

The observed resulting share ACL showed AD\\Domain Admins with Allow / Full.
The explicit Allow / Change entry for AD\\Lab.TestUser was absent.

Evidence limitation: this fault-time ACL output was observed during the
session but was not saved as a contemporaneous transcript. Its observed
result is documented in the clearly labelled retrospective evidence note.

## 4\. Negative test and evidence

From LAB-CLIENT01, attempted to create INC-003\_fault-access-test.txt
through the share.

Observed result:

* Exception: System.UnauthorizedAccessException
* Message: Access is denied.

The result was saved in evidence/INC-003\_fault-negative-access.txt.

The NTFS ACL was inspected while the fault was active. Its entries matched
the recorded baseline. The evidence supports that the simulated fault was
at the SMB share-permission layer, not caused by a change to the folder's
NTFS ACL.

## 5\. Root cause

The explicit SMB share-level Change permission for AD\\Lab.TestUser had been
removed. The client's file-creation attempt then failed with Access is
denied. The observed share ACL, negative test, and unchanged NTFS ACL
support this diagnosis.

## 6\. Resolution

On LAB-DC01, restored the share-level permission using Grant-SmbShareAccess
for AD\\Lab.TestUser with AccessRight Change.

The resulting share ACL showed:

* AD\\Lab.TestUser — Allow / Change
* AD\\Domain Admins — Allow / Full

No change was made to the folder's NTFS ACL as part of the repair.

## 7\. Recovery verification

From LAB-CLIENT01, signed in as AD\\Lab.TestUser, tested file operations
through the share after repair:

* CREATE: PASS
* READ: PASS
* MODIFY: PASS
* DELETE: PASS

The recovery results were saved in
evidence/INC-003\_recovery-client-file-access.txt.

Final server checks confirmed the intended share permissions, and the
NTFS ACL summary matched the baseline. All three temporary test-file paths
were confirmed absent.

## 8\. Prevention and lessons learned

* Check both SMB share permissions and NTFS permissions when investigating
file-share access failures.
* Use the affected user's actual access attempt to verify symptoms.
* Change only the permission layer supported by diagnostic evidence.
* Retest create, read, modify, and delete operations after repair.
* Preserve baseline, fault, and recovery evidence, including the distinction
between contemporaneous captures and retrospective notes.
* Use dedicated lab resources and leave system shares untouched.

## 9\. Limitations

This was a controlled lab simulation, not a production incident or
professional work experience. The negative test directly demonstrated
a file-creation failure after the share permission was removed. It did not
independently test every possible read, modify, or delete denial while
the fault was active. Those four operations passed at baseline and after
recovery.

The fault-time share ACL note is retrospective, based on the command output
observed during the session. It is not a raw transcript or contemporaneous
capture. This limitation is retained explicitly rather than presenting the
note as stronger evidence than it is.

## 10\. Evidence inventory

The following files were present and non-empty at the final inventory
check:

* evidence/INC-003\_baseline-client-file-access.txt (553 bytes)
* evidence/INC-003\_baseline-client-ipconfig.txt (2355 bytes)
* evidence/INC-003\_baseline-existing-shares.txt (499 bytes)
* evidence/INC-003\_baseline-ntfs-acl.txt (1188 bytes)
* evidence/INC-003\_baseline-services.txt (138 bytes)
* evidence/INC-003\_baseline-share-permissions.txt (241 bytes)
* evidence/INC-003\_baseline-smb-connectivity.txt (195 bytes)
* evidence/INC-003\_fault-negative-access.txt (448 bytes)
* evidence/INC-003\_fault-ntfs-acl-check.txt (1188 bytes)
* evidence/INC-003\_fault-share-permissions-retrospective.txt (1146 bytes)
* evidence/INC-003\_final-ntfs-acl.txt (448 bytes)
* evidence/INC-003\_final-share-permissions.txt (241 bytes)
* evidence/INC-003\_recovery-client-file-access.txt (453 bytes)

The incident report is stored at incident-report.md in the incident root.

## 11\. Final outcome

The simulated share-level permission fault was introduced, the
access-denied symptom was reproduced, the NTFS ACL was found unchanged,
and the share permission was restored. All four file operations passed
after repair, and the final server configuration and test-file cleanup
were verified.

The report and evidence inventory were checked before declaring this
incident complete.

