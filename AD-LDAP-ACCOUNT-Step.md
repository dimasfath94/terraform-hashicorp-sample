add tools 
```bash
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
```

create ou hashicorp
```bash
New-ADOrganizationalUnit -Name "Hashicorp" -Path "DC=example,DC=local" -Description "OU untuk layanan HashiCorp"
```

create AD Account
```bash
$password = ConvertTo-SecureString "YOUR_PASS" -AsPlainText -Force

New-ADUser `
  -Name "svc-database" `
  -SamAccountName "svc-database" `
  -UserPrincipalName "svc-database@example.local" `
  -Path "OU=Hashicorp,DC=example,DC=local" `
  -AccountPassword $password `
  -Enabled $true `
  -PasswordNeverExpires $true `
  -Description "Service Account for Database"
```

verification
```bash
Get-ADUser -Identity "svc-database" -Properties DistinguishedName, Enabled, UserPrincipalName
```


delete ad account
```bash
Remove-ADUser -Identity "CN=svc-database,OU=Hashicorp,DC=example,DC=local" -Confirm:$false
```

delete ou
```bash
Set-ADOrganizationalUnit -Identity "OU=Hashicorp,DC=example,DC=local" -ProtectedFromAccidentalDeletion $false
Remove-ADOrganizationalUnit -Identity "OU=Hashicorp,DC=example,DC=local" -Confirm:$false
```

delete all
```bash
Get-CimInstance Win32_UserProfile | Where-Object { $_.LocalPath -like "*svc-database*" } | Remove-CimInstance
if (Test-Path "C:\Users\svc-database") {
  Remove-Item -Path "C:\Users\svc-database" -Recurse -Force
}
```

