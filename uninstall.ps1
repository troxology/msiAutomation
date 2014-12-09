<#
.SYNOPSIS
	This script removes any software registered via Windows Installer from a computer.    
.NOTES
	Created on:   	December 9, 2014
	Created by:   	Tim Troxler
	Filename:       uninstall.ps1
	Requirements:   Assumes a locally cached copy of the MSI file exists and 
		executionn is on a 64-bit Windows platform.
.DESCRIPTION
	This script queries the uninstall info in the registry for all applications
	that match the input product name.  It then uninstalls all matching apps.
.EXAMPLE
    .\uninstall.ps1 -ProductName 'Adobe Reader'
.PARAMETER ProductName
	This is the name of the application to search for.
#>

# Define script inputs
param (
	[Parameter(Mandatory = $True,
			   ValueFromPipeline = $True,
			   ValueFromPipelineByPropertyName = $True)]
	[string]$ProductName
)

# Construct the registry query
$registryPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$displayName = "*$ProductName*"
Write-Host "Querying $registryPath for $ProductName"

# Populate hash map with all matching apps
$apps= @{}
Get-ChildItem $registryPath | 
    Where-Object -FilterScript {$_.getvalue('DisplayName') -like $displayName} | 
		ForEach-Object -process {$apps.Set_Item(
			$_.Name,
			$_.getvalue('DisplayName'))
		}

# Uninstall each matching app
foreach ($uninstall_string in $apps.GetEnumerator()) {
	Write-Host "Attempting to uninstall" + $uninstall_string.value
	$temp = $uninstall_string.name -split '\\'
	$uninstall_app = "MsiExec.exe"
	$uninstall_arg = "/x" + $temp[-1] + " /quiet /passive"
	Write-Host $uninstall_app $uninstall_arg
	(start-process -FilePath $uninstall_app -ArgumentList $uninstall_arg -PassThru -Wait).ExitCode
}