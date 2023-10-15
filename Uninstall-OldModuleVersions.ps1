#Uninstall-OldModuleVersions.ps1
Enable-PSWSManCombinedTrace

Start-Transcript
#Start-Trace
$AllInstalledModules = Get-InstalledModule

$AllInstalledModules

$AllInstalledModulesNames = $AllInstalledModules.Name

$AllInstalledModulesNames

For ( $index = 0; $index -lt $AllInstalledModulesNames.count; $index++) {
  #$index;
  $Latest = Get-InstalledModule $AllInstalledModulesNames[$index];
  #$Latest;
  Get-InstalledModule $AllInstalledModulesNames[$index] -AllVersions -Verbose
  | Where-Object { $_.Version -ne $Latest.Version }
  | Uninstall-Module -Verbose -WhatIf 
}
#Stop-Trace
Stop-Transcript
#Export-ModuleMember -Variable 'AllInstalledModules'