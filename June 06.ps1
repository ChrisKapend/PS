connect-azuread
Connect-MsolService

Set-MsolUserPassword -UserPrincipalName LAlberts@dathcom.com -ForceChangePassword $true -ForceChangePasswordOnly $true


#Force password change first create an azuread password profile object then add it to a user
$pass = New-Object Microsoft.Open.AzureAD.Model.PasswordProfile
$pass
$pass.ForceChangePasswordNextLogin($true)
$pass.ForceChangePasswordNextLogin = $true
Get-AzureADUser -filter "Displayname eq 'Lukas Alberts'" | Set-AzureADUser -PasswordProfile $pass
