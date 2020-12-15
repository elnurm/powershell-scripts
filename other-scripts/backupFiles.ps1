# Script for backup yesterday's audio files from Call Center server to Windows Shared Folder
# Created by Elnur Mammadov ( elnur.mammadov.n@hotmail.com )
 
Import-Module -Name posh-ssh
 
# Converting plain text password to secure string
$Password = ConvertTo-SecureString "XXX" -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ("root",$Password)
 
# Call Center server's ssh port is 23
$Session = New-SFTPSession -Port 23 -ComputerName 'XXXXXXXX' -Credential $Credentials
Set-SFTPLocation -SessionId 0 "/var/spool/asterisk/monitor/"
$Files = Get-SFTPChildItem -SessionId 0
$Yesterday = (Get-Date).AddDays(-1)
 
New-Item -ItemType directory -Path "F:\Shared_Data\Main_Office\Call_Center_Chat\CallCenter_records\$($Yesterday.ToString('yyyy-MM-dd'))"
 
foreach ($File in $Files) {
    if ( ($File.LastWriteTime).ToShortDateString() -eq $Yesterday.ToShortDateString() ) {
         
        Get-SFTPFile -SFTPSession $Session -RemoteFile $File.Name -LocalPath "F:\Shared_Data\Main_Office\Call_Center_Chat\CallCenter_records\$($Yesterday.ToString('yyyy-MM-dd'))"
        $File.Name + " copied" >> "F:\Shared_Data\Main_Office\Call_Center_Chat\CallCenter_records\$($Yesterday.ToString('yyyy-MM-dd'))\log.txt"
    }
}
 
Remove-SFTPSession $Session