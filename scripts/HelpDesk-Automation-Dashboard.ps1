Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Help Desk AD Automation Dashboard"
$form.Size = New-Object System.Drawing.Size(700,520)
$form.StartPosition = "CenterScreen"

# Title
$title = New-Object System.Windows.Forms.Label
$title.Text = "PowerShell Help Desk Automation Dashboard"
$title.Font = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(25,20)
$form.Controls.Add($title)

# Username label
$userLabel = New-Object System.Windows.Forms.Label
$userLabel.Text = "Username:"
$userLabel.Location = New-Object System.Drawing.Point(30,75)
$userLabel.AutoSize = $true
$form.Controls.Add($userLabel)

# Username box
$userBox = New-Object System.Windows.Forms.TextBox
$userBox.Location = New-Object System.Drawing.Point(120,72)
$userBox.Size = New-Object System.Drawing.Size(220,25)
$form.Controls.Add($userBox)

# Password label
$passwordLabel = New-Object System.Windows.Forms.Label
$passwordLabel.Text = "New Password:"
$passwordLabel.Location = New-Object System.Drawing.Point(30,115)
$passwordLabel.AutoSize = $true
$form.Controls.Add($passwordLabel)

# Password box
$passwordBox = New-Object System.Windows.Forms.TextBox
$passwordBox.Location = New-Object System.Drawing.Point(120,112)
$passwordBox.Size = New-Object System.Drawing.Size(220,25)
$passwordBox.UseSystemPasswordChar = $true
$form.Controls.Add($passwordBox)

# Output box
$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(30,290)
$outputBox.Size = New-Object System.Drawing.Size(620,150)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

function Write-Status {
    param($Message)

    $outputBox.AppendText(
        "$(Get-Date -Format 'HH:mm:ss') - $Message`r`n"
    )
}

# Find User
$findButton = New-Object System.Windows.Forms.Button
$findButton.Text = "Find User"
$findButton.Location = New-Object System.Drawing.Point(30,165)
$findButton.Size = New-Object System.Drawing.Size(130,40)

$findButton.Add_Click({

    try {

        $user = Get-ADUser $userBox.Text -Properties Enabled,LockedOut

        Write-Status "User found: $($user.Name)"
        Write-Status "Username: $($user.SamAccountName)"
        Write-Status "Enabled: $($user.Enabled)"
        Write-Status "Locked Out: $($user.LockedOut)"

    }
    catch {
        Write-Status "ERROR: User not found."
    }

})

$form.Controls.Add($findButton)

# Unlock Account
$unlockButton = New-Object System.Windows.Forms.Button
$unlockButton.Text = "Unlock Account"
$unlockButton.Location = New-Object System.Drawing.Point(175,165)
$unlockButton.Size = New-Object System.Drawing.Size(130,40)

$unlockButton.Add_Click({

    try {

        Unlock-ADAccount -Identity $userBox.Text
        Write-Status "Account unlocked successfully: $($userBox.Text)"

    }
    catch {
        Write-Status "ERROR: Unable to unlock account."
    }

})

$form.Controls.Add($unlockButton)

# Reset Password
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = "Reset Password"
$resetButton.Location = New-Object System.Drawing.Point(320,165)
$resetButton.Size = New-Object System.Drawing.Size(130,40)

$resetButton.Add_Click({

    try {

        $securePassword = ConvertTo-SecureString `
            $passwordBox.Text `
            -AsPlainText `
            -Force

        Set-ADAccountPassword `
            -Identity $userBox.Text `
            -Reset `
            -NewPassword $securePassword

        Set-ADUser `
            -Identity $userBox.Text `
            -ChangePasswordAtLogon $true

        $passwordBox.Clear()

        Write-Status "Password reset successfully."
        Write-Status "User must change password at next logon."

    }
    catch {
        Write-Status "ERROR: Password reset failed."
    }

})

$form.Controls.Add($resetButton)

# Enable Account
$enableButton = New-Object System.Windows.Forms.Button
$enableButton.Text = "Enable Account"
$enableButton.Location = New-Object System.Drawing.Point(465,165)
$enableButton.Size = New-Object System.Drawing.Size(130,40)

$enableButton.Add_Click({

    try {

        Enable-ADAccount -Identity $userBox.Text
        Write-Status "Account enabled: $($userBox.Text)"

    }
    catch {
        Write-Status "ERROR: Unable to enable account."
    }

})

$form.Controls.Add($enableButton)

# Disable Account
$disableButton = New-Object System.Windows.Forms.Button
$disableButton.Text = "Disable Account"
$disableButton.Location = New-Object System.Drawing.Point(30,220)
$disableButton.Size = New-Object System.Drawing.Size(130,40)

$disableButton.Add_Click({

    $answer = [System.Windows.Forms.MessageBox]::Show(
        "Disable account $($userBox.Text)?",
        "Confirm",
        "YesNo",
        "Warning"
    )

    if ($answer -eq "Yes") {

        try {

            Disable-ADAccount -Identity $userBox.Text
            Write-Status "Account disabled: $($userBox.Text)"

        }
        catch {
            Write-Status "ERROR: Unable to disable account."
        }

    }

})

$form.Controls.Add($disableButton)

# Check Groups
$groupsButton = New-Object System.Windows.Forms.Button
$groupsButton.Text = "Check Groups"
$groupsButton.Location = New-Object System.Drawing.Point(175,220)
$groupsButton.Size = New-Object System.Drawing.Size(130,40)

$groupsButton.Add_Click({

    try {

        $groups = Get-ADPrincipalGroupMembership $userBox.Text |
                  Select-Object -ExpandProperty Name

        Write-Status "Groups for $($userBox.Text):"

        foreach ($group in $groups) {
            Write-Status " - $group"
        }

    }
    catch {
        Write-Status "ERROR: Unable to retrieve groups."
    }

})

$form.Controls.Add($groupsButton)

# Add to IT-Support
$groupButton = New-Object System.Windows.Forms.Button
$groupButton.Text = "Add to IT-Support"
$groupButton.Location = New-Object System.Drawing.Point(320,220)
$groupButton.Size = New-Object System.Drawing.Size(130,40)

$groupButton.Add_Click({

    try {

        Add-ADGroupMember `
            -Identity "IT-Support" `
            -Members $userBox.Text

        Write-Status "$($userBox.Text) added to IT-Support."

    }
    catch {
        Write-Status "ERROR: Unable to add user to IT-Support."
    }

})

$form.Controls.Add($groupButton)

# Clear output
$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Text = "Clear Output"
$clearButton.Location = New-Object System.Drawing.Point(465,220)
$clearButton.Size = New-Object System.Drawing.Size(130,40)

$clearButton.Add_Click({
    $outputBox.Clear()
})

$form.Controls.Add($clearButton)

[void]$form.ShowDialog()
