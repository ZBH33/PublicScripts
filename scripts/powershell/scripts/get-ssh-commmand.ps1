<#
.SYNOPSIS
	get-ssh-commmand
.DESCRIPTION
	This PowerShell script is a sample script writing "the ssh command for the current client" to the console.
.LINK
	https://github.com/ZBH33/PublicScripts\scripts\powershell\scripts\Hello-World.ps1
.NOTES
	Author: ZBH33
#>

$IP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet" | Where-Object {$_.IPAddress -notlike "169.*"}).IPAddress

if (-not $IP) { $IP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi" | Where-Object {$_.IPAddress -notlike "169.*"}).IPAddress }

$User = $env:USERNAME

Write-Host "ssh $User@$IP"
exit 0