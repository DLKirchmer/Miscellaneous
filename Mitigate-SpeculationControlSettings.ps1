
<# 
.Synopsis
    Mitigate    Short description

.DESCRIPTION
   Long description

.EXAMPLE
   Example of how to use this cmdlet

.EXAMPLE
   Another example of how to use this cmdlet

.INPUTS
   Inputs to this cmdlet (if any)

.OUTPUTS
   Output from this cmdlet (if any)

.NOTES References:
    Understanding Get-SpeculationControlSettings PowerShell script output
        https://support.microsoft.com/help/4074629

    Windows client guidance for IT Pros to protect against speculative execution side-channel vulnerabilities
        https://support.microsoft.com/help/4073119

    Windows Server guidance to protect against speculative execution side-channel vulnerabilities
        https://support.microsoft.com/help/4072698

.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
 #>


#region Test for the log file path and create it if not found then start the transcript into the log file
$LogfilePath = "D:\Logs"
$DateTimeStamp = Get-Date -Format FileDateTime
$LogfileName = "SpeculationControl-"+"$DateTimeStamp.log"
$Logfile = "$LogfilePath\"+"$LogfileName"
if (Test-Path $LogfilePath) {
    New-Item -ItemType "File" -Path "$Logfile"
    Start-Transcript -Path "$Logfile" -IncludeInvocationHeader
} 
else {
    New-Item -ItemType "Directory" -Path "$LogfilePath"
    New-Item -ItemType "File" -Path $Logfile
    Start-Transcript -Path "$Logfile" -IncludeInvocationHeader
}
#endregion Test for the log file path and create it if not found then start the transcript into the log file


#region Save the current execution policy so it can be reset
$SavedExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope Currentuser
#endregion Save the current execution policy so it can be reset

#region Backup the registry keys for recovery, if needed.
REG EXPORT "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" $RegKeysFile
#endregion Backup the registry keys for recovery, if needed.


#region Determine if PSGallery is Registered as a Trusted PSRepository
$PSGalleryTrusted = Get-PSRepository -Name PSGallery

# If PSGallery is not yet registered, Register PSGallery as a Trusted PSRepository
if ($null -eq $PSGalleryTrusted) {
    Register-PSRepository -SourceLocation "https://www.powershellgallery.com/api/v2" -InstallationPolicy Trusted
}

# If PSGallery is registered but Untrusted, Set the Installation Policy to "Trusted"
if ($PSGalleryTrusted.InstallationPolicy -ne "Trusted"){
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}
#endregion Determine if PSGallery is Registered as a Trusted PSRepository


#region Determine if SpeculationControl Module is installed
$SpeculationControlModule = Get-InstalledModule -Name SpeculationControl

# If SpeculationControl Module is not installed, find it in PSGallery and Install it
if ($null -eq $SpeculationControlModule) {
    Find-Module -Name SpeculationControl | Install-Module 
}
#endregion Determine if SpeculationControl Module is installed


#region Check if SpeculationControl Module is imported and import it if not found
$SpeculatoinControlImported = Get-Module -Name "SpeculationControl"
if ($null -eq $SpeculatoinControlImported){
    Import-Module SpeculationControl #-Verbose
}
#endregion Check if SpeculationControl Module is imported and import it if not found


#region Get-SpeculationControlSettings Results before mitigation
$SpeculationControlResultsBefore = Get-SpeculationControlSettings
$SpeculationControlResultsBefore          #Displays to console so Transcript will log results
#endregion Get-SpeculationControlSettings Results before mitigation

# * Suggested actions
 
<# 
* Hardware support for branch target injection mitigation is present: False
    The required hardware features are not present, and therefore the branch target injection mitigation cannot be enabled.
#>
 
 
<# 
* Windows OS support for branch target injection mitigation is present: False
    If it is False, the January 2018 update has not been installed on the system, and the branch target injection
    mitigation cannot be enabled.
#>

#region Mitigate "Windows OS support for speculative store bypass disable is enabled system-wide: False" vulnerability

<#
* Windows OS support for Speculative Store Bypass Disable is enabled system-wide: True/False result
    To enable mitigations for Intel® Transactional Synchronization Extensions (Intel® TSX) Transaction Asynchronous
    Abort vulnerability (CVE-2019-11135) and Microarchitectural Data Sampling (CVE-2018-11091, CVE-2018-12126,
    CVE-2018-12127, CVE-2018-12130) along with Spectre (CVE-2017-5753 & CVE-2017-5715) and Meltdown (CVE-2017-5754)
    variants, including Speculative Store Bypass Disable (SSBD) (CVE-2018-3639) as well as L1 Terminal Fault (L1TF)
    (CVE-2018-3615, CVE-2018-3620, and CVE-2018-3646) without disabling Hyper-Threading:
 
 * If result contains: "SSBDWindowsSupportEnabledSystemWide : False" apply registry keys to mitigate the vulnerability
#>
if ($SpeculationControlResults.SSBDWindowsSupportEnabledSystemWide -ne "True"){
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 72 /f
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" /v MinVmVersionForCpuBasedMitigations /t REG_SZ /d "1.0" /f
}
#endregion Mitigate "Windows OS support for speculative store bypass disable is enabled system-wide: False" vulnerability


#region Get-SpeculationControlSettings Results after mitigation
$SpeculationControlResultsAfter = Get-SpeculationControlSettings
$SpeculationControlResultsAfter
#endregion Get-SpeculationControlSettings Results after mitigation


#region Reset the execution policy to the original state
Set-ExecutionPolicy $SavedExecutionPolicy -Scope Currentuser
#endregion Reset the execution policy to the original state

#region Stop Logging
Stop-Transcript
#endregion Stop Logging