<#
.SYNOPSIS
Creates Active Directory lab user accounts from a CSV file.

.DESCRIPTION
Validates the CSV columns and records, checks the target organizational
units and existing account identities, and creates eligible lab accounts.
New accounts are enabled and configured to require a password change at
the next sign-in.

The script requires the ActiveDirectory PowerShell module and suitable
permissions in the target domain. Run it in an authorized lab environment.

.PARAMETER CsvPath
Path to the CSV input file. Defaults to NewUsers.csv in the script directory.

.EXAMPLE
.\New-LabUsers.ps1 -WhatIf

Previews the operations using the default CSV without creating accounts.

.EXAMPLE
.\New-LabUsers.ps1 -CsvPath .\NewUsers.csv -WhatIf

Previews operations using the specified CSV file.

.EXAMPLE
.\New-LabUsers.ps1 -CsvPath .\NewUsers.csv

Prompts for a temporary password and attempts to create eligible accounts.

.NOTES
The CSV must contain FirstName, LastName, SamAccountName,
UserPrincipalName, and OU columns.

One temporary password is used for accounts created during a run.
Creation is not transactional; accounts created before a later failure
may remain. Use lab-only accounts and test the CSV with -WhatIf first.

This script is intended for a controlled learning lab, not unreviewed
production use.
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$CsvPath = (Join-Path $PSScriptRoot 'NewUsers.csv')
)

$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

# 1. Validate the CSV file and required columns.
if (-not (Test-Path -LiteralPath $CsvPath -PathType Leaf)) {
    throw "CSV file not found: $CsvPath"
}

$requiredColumns = @(
    'FirstName', 'LastName', 'SamAccountName',
    'UserPrincipalName', 'OU'
)

$users = @(Import-Csv -LiteralPath $CsvPath)

if ($users.Count -eq 0) {
    throw 'The CSV contains no user records.'
}

$actualColumns = @($users[0].PSObject.Properties.Name)
$missingColumns = @(
    $requiredColumns | Where-Object { $_ -notin $actualColumns }
)

if ($missingColumns.Count -gt 0) {
    throw "Missing CSV columns: $($missingColumns -join ', ')"
}

# 2. Validate every CSV row before changing Active Directory.
$seenSam = @{}
$seenUpn = @{}
$seenNames = @{}

$validatedUsers = @(
    foreach ($row in $users) {
        foreach ($field in $requiredColumns) {
            if ([string]::IsNullOrWhiteSpace($row.$field)) {
                throw "A required field is blank: $field"
            }
        }

        $first = $row.FirstName.Trim()
        $last  = $row.LastName.Trim()
        $sam   = $row.SamAccountName.Trim()
        $upn   = $row.UserPrincipalName.Trim()
        $ou    = $row.OU.Trim()

        $samKey = $sam.ToLowerInvariant()
        $upnKey = $upn.ToLowerInvariant()

        if ($seenSam.ContainsKey($samKey)) {
            throw "Duplicate SamAccountName in CSV: $sam"
        }

        if ($seenUpn.ContainsKey($upnKey)) {
            throw "Duplicate UPN in CSV: $upn"
        }

        $seenSam[$samKey] = $true
        $seenUpn[$upnKey] = $true

        $targetOU = Get-ADOrganizationalUnit -Identity $ou
        $displayName = "$first $last"
        $nameKey = "$($targetOU.DistinguishedName.ToLowerInvariant())|$($displayName.ToLowerInvariant())"

        if ($seenNames.ContainsKey($nameKey)) {
            throw "Duplicate name in CSV for the same OU: $displayName"
        }

        $seenNames[$nameKey] = $true

        [PSCustomObject]@{
            FirstName         = $first
            LastName          = $last
            DisplayName       = $displayName
            SamAccountName    = $sam
            UserPrincipalName = $upn
            OU                = $targetOU.DistinguishedName
        }
    }
)

# 3. Check existing accounts and conflicts before creating anything.
$accountsToCreate = @()

foreach ($user in $validatedUsers) {
    $existingSam = Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'"
    $existingUpn = Get-ADUser -Filter "UserPrincipalName -eq '$($user.UserPrincipalName)'"

    if ($existingSam) {
        $actualOU = $existingSam.DistinguishedName -replace '^[^,]+,', ''

        if ($existingSam.UserPrincipalName -ne $user.UserPrincipalName -or
            $actualOU -ne $user.OU) {
            throw "Existing account identity or OU mismatch: $($user.SamAccountName)"
        }

        if ($existingUpn -and
            $existingUpn.SamAccountName -ne $user.SamAccountName) {
            throw "UPN belongs to another account: $($user.UserPrincipalName)"
        }

        Write-Output "Skipping existing account: $($user.SamAccountName)"
        continue
    }

    if ($existingUpn) {
        throw "UPN belongs to another account: $($user.UserPrincipalName)"
    }

    # Escape LDAP filter characters in the common name.
    $escapedCN = $user.DisplayName.Replace('\', '\5c').
        Replace('*', '\2a').Replace('(', '\28').
        Replace(')', '\29')

    $nameConflict = Get-ADObject -SearchBase $user.OU `
        -SearchScope OneLevel `
        -LDAPFilter "(cn=$escapedCN)"

    if ($nameConflict) {
        throw "CN conflict in target OU: $($user.DisplayName)"
    }

    $accountsToCreate += $user
}

if ($accountsToCreate.Count -eq 0) {
    Write-Output 'No new accounts to create.'
    return
}

# In preview mode, show planned operations without requesting a password.
if ($WhatIfPreference) {
    foreach ($user in $accountsToCreate) {
        $null = $PSCmdlet.ShouldProcess($user.SamAccountName, 'Create AD user')
    }
    return
}

# 4. Request the initial password securely.
$password = Read-Host 'Enter the temporary password for new lab accounts' -AsSecureString

# 5. Create only accounts that passed validation.
foreach ($user in $accountsToCreate) {
    $parameters = @{
        Name                  = $user.DisplayName
        GivenName             = $user.FirstName
        Surname               = $user.LastName
        DisplayName           = $user.DisplayName
        SamAccountName        = $user.SamAccountName
        UserPrincipalName     = $user.UserPrincipalName
        Path                  = $user.OU
        AccountPassword       = $password
        Enabled               = $true
        ChangePasswordAtLogon = $true
    }

    if ($PSCmdlet.ShouldProcess($user.SamAccountName, 'Create AD user')) {
        New-ADUser @parameters
        Write-Output "Created: $($user.SamAccountName)"
    }
}

