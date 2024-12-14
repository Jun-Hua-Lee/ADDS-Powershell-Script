# Import Active Directory module for running AD cmdlets
Import-Module ActiveDirectory

# Store the data from NewUsersFinal.csv in the $ADUsers variable
$ADUsers = Import-Csv -Delimiter "," "C:\Users\Administrator\Desktop\users.csv"

# Define UPN
$UPN = "brown27d.net"

# Loop through each row containing user details in the CSV file
foreach ($User in $ADUsers) {

    # Read user data from each field in each row and assign the data to a variable
    $username = $User.logonname
    $firstname = $User.firstname
    $lastname = $User.lastname
    $password = $User.password
    $OU = $User.ou 
    $email = $User.email
    $streetaddress = $User.streetaddress
    $city = $User.city
    $zipcode = $User.zipcode
    $state = $User.state
    $country = $User.country
    $telephone = $User.telephone
    $jobtitle = $User.jobtitle
    $company = $User.company
    $department = $User.department
    $NetworkSharePath = "\\dcd-files\users$"

    # Construct the UNC path for the home drive
    $HomeDrive = "U:"
    $HomeDirectory = Join-Path $NetworkSharePath $username

    # Check to see if the user already exists in AD
    if (Get-ADUser -Filter "SamAccountName -eq '$username'") {

        # If the user already exists, give a warning
        Write-Warning "A user account with username $username already exists in Active Directory."
    }
    else {

        # User does not exist, proceed to create the new user account
        # Account will be created in the OU provided by the $OU variable read from the CSV file
        New-ADUser `
            -SamAccountName $username `
            -UserPrincipalName "$username@$UPN" `
            -Name "$firstname $lastname" `
            -GivenName $firstname `
            -Surname $lastname `
            -Enabled $True `
            -Path $OU `
            -City $city `
            -PostalCode $zipcode `
            -Country $country `
            -State $state `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (ConvertTo-secureString $password -AsPlainText -Force) -ChangePasswordAtLogon $True `

        # Set the home drive for the user
        Set-ADUser -Identity $username -HomeDrive $HomeDrive -HomeDirectory $HomeDirectory

        $groups = $User.MemberOf -split ','
        foreach ($group in $groups) {
            Add-ADGroupMember -Identity $group.Trim() -Members $User.LogonName
            }

        # If user is created, show message
        Write-Host "The user account $username is created with a home drive." -ForegroundColor Green
    }
}
