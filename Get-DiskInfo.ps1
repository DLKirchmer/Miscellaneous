# Get-DiskInfo.ps1

$DateTime = Get-Date -Format FileDateTime
$DateTime

#region Test if Export file folder exists and create it if not found.
$ExportFilePath = "D:\Logs\DiskInfo"
$ExportFileName = "DiskInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"


if ( -Not (Test-Path $ExportFilePath)) {
    New-Item -ItemType "Directory" -Path "$ExportFilePath" -Verbose
}  

#endregion Test for the desired log file and create it if not found


 
$PSDisks = Get-Disk
$PSDrives = Get-PSDrive -PSProvider FileSystem
$PSPhysicalDisks = Get-PhysicalDisk
$WmiLogicalDisks = Get-CimInstance -ClassName Win32_LogicalDisk
$WmiDrives = Get-CimInstance -ClassName Win32_DiskDrive
$WmiDiskPartitions = Get-CimInstance -ClassName Win32_DiskPartition

#$WmiLogicalDisks | Get-member


#region PSDisks
$ExportFileName = "PSDisksInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"
$PSDisks = Get-Disk
$PSDisks | Select-Object -Property DiskNumber, FriendlyName, PartitionStyle, BusType, AllocatedSize, @{L = 'Size GB'; E = { "{0:N2}" -f (($_.Size) / 1GB) } } | Sort-Object -Property DiskNumber  |  Out-GridView
$PSDisks | Export-Excel -Path $ExportFile -AutoSize
$PSDisksIndexMax = ($PSDisks.Count - 1)
$PSDisksIndexes = 0..$PSDisksIndexMax
$PSDisksTotalStorage = $null
$PSDiskSizeGB = New-Object System.UInt64
foreach ($PSDisksIndex in $PSDisksIndexes) {
    $PSDiskSize = $PSDisks.Size[$PSDisksIndex] 
    $PSDiskSizeGB = $PSDiskSize / 1Gb
    $PSDisksTotalStorage = $PSDisksTotalStorage + $PSDiskSizeGB
}

$PSDisksTotalStorage
#endregion PSDisks

#region PSDrives
$ExportFileName = "PSDrivesInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"
$PSDrives = Get-PSDrive -PSProvider FileSystem
$PSDrives | Select-Object -Property * #Name, Root, @{L = 'Size'; E = { "{0:N0}" -f ($_.Used + $_.Free) } }, @{L = 'Size GB'; E = { "{0:N2}" -f (($_.Used + $_.Free)/1GB) } }, @{L = 'Used GB'; E = { "{0:N2}" -f (($_.Used)/1GB) } }, @{L = 'Free GB'; E = { "{0:N2}" -f (($_.Free)/1GB) } }, Description  |  Out-GridView
$PSDrives | Export-Excel -Path $ExportFile -AutoSize
$PSDrivesIndexMax = ($PSDrives.Count - 1)
$PSDrivesIndexes = 0..$PSDrivesIndexMax
$PSDrivesTotalStorage = $null
$PSDriveSizeGB = New-Object System.UInt64
foreach ($PSDrivesIndex in $PSDrivesIndexes) {
    $PSDriveSize = ($PSDrives.Used[$PSDrivesIndex] + $PSDrives.Free[$PSDrivesIndex])
    $PSDriveSizeGB = $PSDriveSize / 1Gb
    $PSDriveSizeGB
    $PSDrivesTotalStorage = $PSDrivesTotalStorage + $PSDriveSizeGB
}

$PSDrivesTotalStorage
#endregion PSDrives

#$PSDrives | Get-Member



$PSPhysicalDisks | Select-Object -Property FriendlyName, AllocatedSize, @{L = 'Size GB'; E = { "{0:N2}" -f (($_.Size)/1GB) }}, UniqueId, SerialNumber  |  Out-GridView
$ExportFileName = "PSPhysicalDisksInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"
$PSPhysicalDisks | Export-Excel -Path $ExportFile -AutoSize
$WmiDrives | Select-Object -Property *  |  Out-GridView
$ExportFileName = "WmiDrivesInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"
$WmiDrives | Export-Excel -Path $ExportFile -AutoSize
$WmiLogicalDisks | Select-Object -Property *  |  Out-GridView
$ExportFileName = "WmiLogicalDisksInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"
$WmiLogicalDisks | Export-Excel -Path $ExportFile -AutoSize
$WmiDiskPartitions | Select-Object -Property *  |  Out-GridView
$ExportFileName = "WmiDiskPartionsInfo-$DateTime.xlsx"
$ExportFile = "$ExportFilePath\" + "$ExportFileName"
$WmiDiskPartitions | Export-Excel -Path $ExportFile -AutoSize





$PSDrivesIndexMax = ($PSDrives.Count - 1)
$PSDrivesIndexes = 0..$PSDrivesIndexMax
$null = $TotalAvailableStorage
$TotalAttachedStorage = @()
$DriveSizeGB = New-Object System.UInt64
foreach ($PSDisksIndex in $PSDisksIndexes) {
    $DriveSize = $PSDisks.Size[$PSDisksIndex] 
    $DriveSizeGB = $DriveSize / 1Gb
    $TotalAttachedStorage += $DriveSizeGB
    $TotalAvailableStorage = $TotalAvailableStorage + $DriveSizeGB
}

$PSPhysicalDisks.Count

$WmiDrives.Count
$WmiLogicalDisks.Count
$WmiLogicalDisks.Size
$WmiLogicalDisks.FreeSpace

$WmiDiskPartitions.Count
$WmiDiskPartitions.Size



($TotalAttachedStorage[0]).GetType()

$TotalAvailableStorage


<#
Get-Help Export-Excel
Get-InstalledModule
Get-Module -ListAvailable

import-module ImportExcel

Find-Module -Name ImportExcel | Install-Module
#>

<#
$DriveSizeGB.GetType()

$DriveSize.Size = [math]::Round($size[$_] / 1Gb, 2)


$DriveSizeGB | Get-Member


#= @{L = 'Size GB'; E = { "{0:N2}" -f (($_.Size) / 1GB) } }
#$TotalAttachedStorage += $PSDisks.Size[$PSDisksIndex] 
#$TotalAttachedStorage
#@{L = 'Size GB'; E = { "{0:N2}" -f (($_.Size) / 1GB) } }



<#
$DriveSize | Select-Object -Property @{L = 'Size'; E = { "{0:N2}" -f (($_)/1GB) }}

$DriveSizeGB = New-Object System.UInt64
foreach ($PSDisksIndex in $PSDisksIndexes) {$DriveSize = $PSDisks.Size[$PSDisksIndex] ; $DriveSizeGB = $DriveSize | Select-Object -Property @{L = 'Size GB'; E = { "{0:N2}" -f (($_)/1GB) }}
}


 $freeBytesAvailable     = New-Object System.UInt64 # differs from totalNumberOfFreeBytes when per-user disk quotas are in place
    $totalNumberOfBytes     = New-Object System.UInt64
    $totalNumberOfFreeBytes = New-Object System.UInt64

#>