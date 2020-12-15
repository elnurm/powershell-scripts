# Script for alert users about expired password
# Created by Elnur Mammadov  (elnur.mammadov.n@hotmail.com)

$smtpServer="some_smpt_server"
$expireindays = 7
$from = "IT Notification service <itnotify@example.com>"
$mailbox =  'itnotify@example.com'

Import-Module ActiveDirectory
$users = get-aduser -filter * -SearchBase "ou=ALL BRANCHES,dc=example,dc=local" -properties mail, passwordneverexpires, passwordexpired | where {$_.Enabled -eq "True"} | where { $_.passwordneverexpires -eq $false } | where { $_.passwordexpired -eq $false }

foreach ($user in $users)
{
	$Name = (Get-ADUser $user | foreach { $_.Name})


	$emailaddress = $user.mail
	$passwordSetDate = (get-aduser $user -properties * | foreach { $_.PasswordLastSet })
	$PasswordPol = (Get-AduserResultantPasswordPolicy $user)
  
	# Check for Fine Grained Password
	if (($PasswordPol) -ne $null)
	{
		$maxPasswordAge = ($PasswordPol).MaxPasswordAge
	}
  
	else
	{
		$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
	}
  
  
	$expireson = $passwordsetdate + $maxPasswordAge
	$today = (get-date)
	$daystoexpire = (New-TimeSpan -Start $today -End $expireson).Days
    
	if (($daystoexpire -lt $expireindays) -and ($daystoexpire -gt 0))
	{
		$subject="Your password will expire in $daystoExpire days"
		$body ="
		Dear $name,
		<p> Your Password will expire in $daystoexpire days and must be changed.</p>
		<p> New password must meet the following <u>requirements</u>: 8 symbols minimum, contain UPPERCASE and lowercase letters, numbers (or special symbols) and should not resemble the old password.</p
        <p><u>Please, do not reply to this message.</u></p>"

	
		Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress  -subject $subject  -body $body -bodyasHTML -priority High
	    Add-Content -Value "$today : $daystoexpire days remain till expiration Date for $name, notify msg have been sent." -Path  D:\notify_log.txt

    }