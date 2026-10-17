# IT Support & Troubleshooting Lab

A hands-on, virtualized IT support lab built to practise and document entry-level Help Desk, Desktop Support, and IT Technician tasks.

## Lab Environment

| Component | Configuration |
|---|---|
| Host | Windows 11, HP Victus 15 |
| Virtualization | Oracle VirtualBox 7.2.20 |
| Server | Windows Server 2025 Standard Evaluation |
| Client | Windows 11 Pro |
| Active Directory domain | `ad.lab` |
| Domain controller | `LAB-DC01` |
| Client computer | `LAB-CLIENT01` |
| Lab subnet | `192.168.50.0/24` |
| Domain controller lab IP | `192.168.50.10` |
| DHCP client address observed | `192.168.50.100` |

The lab uses isolated virtual-machine networking for hands-on configuration and simulated troubleshooting.

## Skills Practised

The following skills were practised in a controlled virtual lab. The incident reports and evidence files document the specific exercises.

| Skill area | Hands-on work |
|---|---|
| Active Directory | Domain, OU, user, group, account-state and membership checks |
| DNS | Name resolution, DNS configuration checks and troubleshooting |
| DHCP | Scope, lease and client network-configuration verification |
| Group Policy | GPO links, security filtering, `gpresult` analysis and recovery checks |
| File services | SMB share access, share permissions, NTFS ACL inspection and file-operation tests |
| Windows services | Print Spooler and Windows Time service troubleshooting |
| Network troubleshooting | IP configuration, connectivity checks and recovery verification |
| Remote Desktop | RDP service, listener, firewall-rule and connection testing |
| PowerShell | CSV validation, Active Directory user onboarding, existing-account checks and `-WhatIf` preview |
| Technical documentation | Incident reports, evidence collection, verification results and architecture documentation |

Architecture: [View the lab architecture document](docs/architecture/Architecture.md).

All items describe self-directed lab exercises. They should not be interpreted as production experience or proof of certification.

## Troubleshooting Portfolio

Ten Markdown reports are included, with supporting evidence where available. INC-001–INC-005 and INC-007–INC-010 document troubleshooting exercises; INC-006 is a DHCP configuration and validation exercise, not a break/fix incident. The reports disclose relevant limitations and unresolved findings. These are simulated lab exercises, not production support cases.

| Incident | Topic |
|---|---|
| [INC-001](incidents/INC-001-DNS-Configuration/incident-report.md) | DNS configuration and name resolution |
| [INC-002](incidents/INC-002-Account-Disabled/incident-report.md) | Disabled Active Directory account |
| [INC-003](incidents/INC-003-File-Share-Permissions/incident-report.md) | File-share permissions |
| [INC-004](incidents/INC-004-Group-Policy/INC-004-report.md) | Group Policy troubleshooting |
| [INC-005](incidents/INC-005-Print-Spooler/INC-005-report.md) | Print Spooler service |
| [INC-006](incidents/INC-006-DHCP-Configuration/INC-006-DHCP-Configuration.md) | DHCP configuration |
| [INC-007](incidents/INC-007-Network-Recovery/INC-007-report.md) | Network connectivity recovery |
| [INC-008](incidents/INC-008-GPO-Troubleshooting/INC-008-report.md) | Group Policy security filtering |
| [INC-009](incidents/INC-009-Windows-Time/INC-009_Report.md) | Windows Time service |
| [INC-010](incidents/INC-010-Remote-Desktop-Connectivity/INC-010-Report.md) | Remote Desktop connectivity and firewall rules |

These are simulated lab incidents. They are not presented as production support cases or professional work experience.

## PowerShell Script

[`New-LabUsers.ps1`](scripts/New-LabUsers.ps1) provisions lab user accounts from [`NewUsers.csv`](scripts/NewUsers.csv).

The script includes CSV validation, checks for existing account identities and naming conflicts, secure password prompting, and `-WhatIf` preview support.

The current version was tested on LAB-DC01 (Windows Server 2025 Standard Evaluation) against the `ad.lab` domain.

Verification record: [`CSV-Onboarding-Test-Results-2026-10-17.txt`](scripts/evidence/CSV-Onboarding-Test-Results-2026-10-17.txt).

The recorded tests passed:
- Existing accounts were skipped.
- `-WhatIf` displayed the planned creation of `Lab.Onboard03`; a follow-up query confirmed the preview did not create the account.
- The actual run created `Lab.Onboard03`.
- Active Directory queries verified the account's enabled state, display name, UPN, OU placement, and requirement to change the password at next sign-in.
- A repeat run skipped the existing account and reported that no new accounts needed to be created.

The test used a temporary lab password that was not recorded. This is a lab test, not professional work experience.

Known limitations: the script uses one temporary password for all accounts created during a run, and creation is not transactional. If a later creation fails, earlier accounts may remain.

## Repository Structure

```text
.
|-- .gitignore
|-- README.md
|-- docs/
|   `-- architecture/
|       `-- Architecture.md
|-- incidents/
|   |-- INC-001-DNS-Configuration/
|   |-- INC-002-Account-Disabled/
|   |-- INC-003-File-Share-Permissions/
|   |-- INC-004-Group-Policy/
|   |-- INC-005-Print-Spooler/
|   |-- INC-006-DHCP-Configuration/
|   |-- INC-007-Network-Recovery/
|   |-- INC-008-GPO-Troubleshooting/
|   |-- INC-009-Windows-Time/
|   `-- INC-010-Remote-Desktop-Connectivity/
`-- scripts/
    |-- New-LabUsers.ps1
    |-- NewUsers.csv
    `-- evidence/
        `-- CSV-Onboarding-Test-Results-2026-10-17.txt
```

The repository structure is assembled. The architecture diagram and skills table have been checked. The incident-report review and final publishing audit remain before Version 1 is considered finished.

## Responsible Lab Practices

- Use lab-only accounts and non-sensitive test data.
- Do not store passwords or secrets in scripts, CSV files, evidence, or the repository.
- Review files and screenshots for sensitive information before public release.
- Clearly label simulated incidents and distinguish tested results from assumptions.
- Do not claim a task is complete until its result has been verified.

## Disclaimer

This project demonstrates self-directed practice in a controlled virtual environment. It is intended to support learning and interview discussions and does not represent professional employment experience.
