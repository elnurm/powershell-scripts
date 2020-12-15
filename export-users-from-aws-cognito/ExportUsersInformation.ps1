param(
    [string]$Region,
    [string]$UserPoolID,
    [string]$ClientID,
    [string]$cognitoFilePath
)

$ErrorActionPreference = "Stop"

Write-Output "Checking if awscli installed."
if ((Get-Command aws -ErrorAction SilentlyContinue) -eq $null) {
    try {
        Write-Warning "awscli is not installed, downloading..."
        $dlurl = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
        $installerPath = Join-Path $env:TEMP (Split-Path $dlurl -Leaf)
        Invoke-WebRequest $dlurl -OutFile $installerPath
        Write-Verbose "Downloaded, installing..."
        Start-Process -FilePath msiexec -Args "/i $installerPath /passive /quiet" -Verb RunAs -Wait
        Remove-Item $installerPath
        Write-Verbose "Successfully installed."
        aws --version
    }
    catch {
        Write-Error $_
    }
}
else {
    Write-Output "awscli installed."
}

# saving users information for import job to json and csv file
$allCognitoUsers = Get-Content -Path $cognitoFilePath -Raw | ConvertFrom-Json
$cognitoUsers = @()
$cognitoUsers += $allCognitoUsers.where{$_.Client -eq $ClientID}
Write-Host "There are" $cognitoUsers.Count "users with client id $ClientID in database"

Write-Output "Getting users information from AWS Cognito Pool ID => $UserPoolID"
$usersInformation = @()
$usersInformation += $(aws --region $Region cognito-idp list-users --user-pool-id $UserPoolID --output json --query 'Users[?UserStatus != `EXTERNAL_PROVIDER`]')
$usersInformation = $usersInformation | ConvertFrom-Json
Write-Output "Done"

if ($LASTEXITCODE -ne 0) {
    throw $_
}

$defaultAttributes = @('name','given_name','family_name','middle_name','nickname','preferred_username',
                       'profile','picture','website','gender','birthdate','locale','address','updated_at',
                       'custom:password_expire_at','custom:first_login_at','custom:last_login_at',
                       'custom:invalid_login_at','custom:password_updated_at')

$users = @()
$finalUsersInfo = @()
foreach($user in $usersInformation) {
    foreach($attr in $user.Attributes) {
        $user | Add-Member -Type NoteProperty -Name $attr.Name -Value $attr.Value
    }
    $user.PSObject.Properties.Remove('Attributes')
    $user.PSObject.Properties.Remove('Username')
    $user.PSObject.Properties.Remove('sub')
    $user.PSObject.Properties.Remove('UserStatus')
    $user.PSObject.Properties.Remove('UserCreateDate')
    $user.PSObject.Properties.Remove('Enabled')
    $user.PSObject.Properties.Remove('UserLastModifiedDate')
    $user.PSObject.Properties.Remove('email_verified')
    $user | Add-Member -Type NoteProperty -Name 'phone_number' -Value ''
    $user | Add-Member -Type NoteProperty -Name 'phone_number_verified' -Value 'false'
    $user | Add-Member -Type NoteProperty -Name 'cognito:mfa_enabled' -Value 'false'
    $user | Add-Member -Type NoteProperty -Name 'email_verified' -Value 'true'
    $user | Add-Member -Type NoteProperty -Name 'cognito:username' -Value $user.email

    foreach($defaultAttr in $defaultAttributes) {
        if ($user.$defaultAttr -eq $null) {
            $user | Add-Member -type NoteProperty -Name $defaultAttr -Value ''
        }
    }

    $users += $user
}

foreach($user in $users) {
    foreach($cognitoUser in $cognitoUsers) {
        if($user.email -eq $cognitoUser.Email) {
            $finalUsersInfo += $user
        } 
    }
}

$finalUsersInfo | ConvertTo-Json -Depth 100 > .\usersInfoClient_$ClientID.json
$finalUsersInfo = $finalUsersInfo | ConvertTo-Csv -NoTypeInformation | % {$_ -replace '"',''} | Out-File .\usersInfoClient_$ClientID.csv -Encoding utf8

# Converting csv file encoding to UTF8 without BOM
$csvFileName = "usersInfoClient_$ClientID.csv"
$csvFileContent = Get-Content -Raw $csvFileName
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[IO.File]::WriteAllLines(($csvFileName | Resolve-Path), $csvFileContent, $Utf8NoBomEncoding)