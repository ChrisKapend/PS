import-csv users.csv | Sort-Object UserPrincipalName | where-object{$_.userprincipalname -notlike ""} | foreach-object{
Write-Host -ForegroundColor Yellow "Changing User $($_.SamAccountName) ImmutableID to $([system.convert]::ToBase64String([GUID]::New($_.ObjectGUID).tobytearray()))"
Set-MsolUser -UserPrincipalName ($_.UserPrincipalName) -ImmutableId "$([system.convert]::ToBase64String([GUID]::New($_.ObjectGUID).tobytearray()))"
Write-Host -ForegroundColor "Value Changed"
Write-Host -ForegroundColor Green "**********************************************************"
}

import-csv users.csv | Sort-Object UserPrincipalName | where-object{$_.userprincipalname -notlike ""} | foreach-object{
Write-Host -ForegroundColor Yellow "Changing User $($_.SamAccountName) ImmutableID to $([system.convert]::ToBase64String([GUID]::New($_.ObjectGUID).tobytearray()))"
Get-MsolUser -UserPrincipalName ($_.UserPrincipalName) -ErrorAction SilentlyContinue | Set-MsolUser -ImmutableId "$([system.convert]::ToBase64String([GUID]::New($_.ObjectGUID).tobytearray()))"
Write-Host -ForegroundColor yELLOW "Value Changed"
Write-Host -ForegroundColor Green "**********************************************************"
}