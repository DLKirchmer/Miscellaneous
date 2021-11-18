function Set-PSPrompt
{
"PS " + "$env:COMPUTERNAME" + "\" + (Get-Location) + "> "
}