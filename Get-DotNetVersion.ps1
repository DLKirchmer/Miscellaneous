#Get-DotNetVersion.ps1

$DotNetVersions = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'}  | Select-Object PSChildName, version 

$DotNetVersions

$DotNetUpdates = Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Updates | Where-Object {$_.name -like
    "*.NET Framework*"}
   
   ForEach($Version in $DotNetUpdates){
   
      $Updates = Get-ChildItem $Version.PSPath
       $Version.PSChildName
       ForEach ($Update in $Updates){
          $Update.PSChildName
          }
   }

<#

#$DotNetVersion.Count

ForEach ($DotNetVersion in $DotNetVersions) {
    Write-Output $DotNetVersion.version
}
#>