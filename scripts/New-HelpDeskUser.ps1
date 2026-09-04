
Import-Module ActiveDirectory

$FirstName = Read-Host "Enter first name"
$LastName  = Read-Host "Enter last name"
$Username  = Read-Host "Enter username"
$Password  = Read-Host "Enter temporary password" -AsSecureString

$FullName = "$FirstName $LastName"
$UPN = "$Username@corp.navtejlab.com"
$OU = "OU=Employees,DC=corp,DC=navtejlab,DC=com"
$Group = "IT-Support"

try {

    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "User $Username already exists."
        return
    }

    New-ADUser `
        -Name $FullName `
        -GivenName $FirstName `
        -Surname $LastName `
        -SamAccountName $Username `
        -UserPrincipalName $UPN `
        -Path $OU `
        -AccountPassword $Password `
        -Enabled $true `
        -ChangePasswordAtLogon $true `
        -ErrorAction Stop

    Add-ADGroupMember `
        -Identity $Group `
        -Members $Username `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Employee onboarding completed successfully."
    Write-Host "Name: $FullName"
    Write-Host "Username: $Username"
    Write-Host "Group: $Group"

}
catch {
    Write-Host "ERROR: $($_.Exception.Message)"
}
