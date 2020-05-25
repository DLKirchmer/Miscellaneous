#region Determine if PSGallery is Registered as a Trusted PSRepository
$PSRepositoryPSGallery = Get-PSRepository -Name PSGallery #-Verbose

# If PSGallery is not registered yet, Register PSGallery as a Trusted PSRepository
if ($null -eq $PSRepositoryPSGallery) {
    Register-PSRepository -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted #-Verbose
}

# If PSGallery is registered but Untrusted, Set the Installation Policy to "Trusted"
if ($PSRepositoryPSGallery.InstallationPolicy -ne "Trusted"){
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted #-Verbose
}
#endregion Determine if PSGallery is Registered as a Trusted PSRepository

#region Determine if SpeculationControl Module is installed
$SpeculationControlModule = Get-InstalledModule -Name SpeculationControl #-Verbose

# If SpeculationControl Module is not installed, find it in PSGallery and Install it
if ($null -eq $SpeculationControlModule) {
    Find-Module -Name SpeculationControl | Install-Module #-Verbose  
}
#endregion Determine if SpeculationControl Module is installed

$DateTimeStamp = Get-Date -Format FileDateTime
#region Test for the desired log file and create it if not found
$LogfilePath = "C:\Logs"
$LogfileName = "SpeculationControl-"+"$DateTimeStamp.log"
$Logfile = "$LogfilePath\"+"$LogfileName"
if (Test-Path $LogfilePath) {
    New-Item -ItemType "File" -Path "$Logfile"
    Start-Transcript -Path "$Logfile" -UseMinimalHeader
} 
else {
    New-Item -ItemType "Directory" -Path "$LogfilePath" #-Verbose
    New-Item -ItemType "File" -Path $Logfile
    Start-Transcript -Path "$Logfile" -UseMinimalHeader
}

#endregion Test for the desired log file and create it if not found

<#
To query the state of configurable mitigations:
#>
# Save the current execution policy so it can be reset
$SaveExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope Currentuser

# Check if SpeculationControl Module is imported and import it if not found
$SpeculatoinControlImported = Get-Module -Name "SpeculationControl"
if ($null -eq $SpeculatoinControlImported){
    Import-Module SpeculationControl #-Verbose
}

#Get-SpeculationControlSettings

$SpeculationControlSettings = Get-SpeculationControlSettings
$SpeculationControlSettings

#region Mitigate $SpeculationControlSettings.SSBDWindowsSupportEnabledSystemWide vulnerability
# If result contains: "SSBDWindowsSupportEnabledSystemWide : False" apply registry keys to mitigate the vulnerability
# This maps to the Speculation control settings for CVE-2018-3639 [speculative store bypass]: Windows OS support for Speculative Store Bypass Disable is enabled system-wide: True/False result
if ($SpeculationControlSettings.SSBDWindowsSupportEnabledSystemWide -ne "True"){
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 72 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f
}
#endregion Mitigate $SpeculationControlSettings.SSBDWindowsSupportEnabledSystemWide vulnerability

$SpeculationControlSettings = Get-SpeculationControlSettings
$SpeculationControlSettings

# Reset the execution policy to the original state
Set-ExecutionPolicy $SaveExecutionPolicy -Scope Currentuser
# Stop Logging
Stop-Transcript