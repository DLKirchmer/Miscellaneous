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

#region Test for the log file path and create it if not found then start the transcript into the log file
$LogfilePath = "C:\Logs"
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
$SaveExecutionPolicy = Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Scope Currentuser
#endregion Save the current execution policy so it can be reset


#region Check if SpeculationControl Module is imported and import it if not found
$SpeculatoinControlImported = Get-Module -Name "SpeculationControl"
if ($null -eq $SpeculatoinControlImported){
    Import-Module SpeculationControl #-Verbose
}
#endregion Check if SpeculationControl Module is imported and import it if not found

#Get-SpeculationControlSettings

$SpeculationControlSettings = Get-SpeculationControlSettings
$SpeculationControlSettings

# Reset the execution policy to the original state
Set-ExecutionPolicy $SaveExecutionPolicy -Scope Currentuser
# Stop Logging
Stop-Transcript