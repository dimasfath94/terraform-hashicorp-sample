# 1. Konfigurasi Vault dan SQL Server
$VaultUrl = "https://127.0.0.1:8200/v1/ldap/static-cred/app-ldap-role"
$VaultToken = "YOUR_VAULT_TOKEN"
$SqlServer = "localhost"
$DbUserToUpdate = "svc-database"

# Ambil password admin SQL Server dari Environment Variable (sesi lokal atau User Environment Variable Windows)
$DbAdminPassword = $env:db_pass
if (-not $DbAdminPassword) {
    $DbAdminPassword = [System.Environment]::GetEnvironmentVariable("db_pass", "User")
}

# Validasi apakah environment variable terisi
if (-not $DbAdminPassword) {
    Write-Error "Error: Environment variable 'db_pass' tidak ditemukan atau kosong di sistem!"
    exit 1
}

# 2. Ambil password dari Vault menggunakan curl.exe bawaan Windows
try {
    $jsonOutput = & curl.exe -s -k --header "X-Vault-Token: $VaultToken" $VaultUrl
    $jsonResponse = $jsonOutput | ConvertFrom-Json
    $rawPassword = $jsonResponse.data.password
}
catch {
    Write-Error "Gagal mengambil data dari Vault via curl.exe: $_"
    exit 1
}

# Validasi apakah password dari Vault berhasil didapatkan
if (-not $rawPassword) {
    Write-Error "Error: Password baru dari Vault kosong atau gagal di-parse!"
    exit 1
}

# Escape karakter petik tunggal (') agar tidak merusak string query T-SQL
$newPassword = $rawPassword -replace "'", "''"

# 3. Cek / Buat Login di SQL Server jika belum ada, lalu update password-nya
$checkQuery = "IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'$DbUserToUpdate') CREATE LOGIN [$DbUserToUpdate] WITH PASSWORD = '$newPassword'; ELSE ALTER LOGIN [$DbUserToUpdate] WITH PASSWORD = '$newPassword';"

Write-Host "Menyelaraskan password baru ke SQL Server untuk akun [$DbUserToUpdate]..."
Invoke-Sqlcmd -ServerInstance $SqlServer -Query $checkQuery -Username "sa" -Password $DbAdminPassword

Write-Host "Berhasil menyelaraskan password service account ke SQL Server!" -ForegroundColor Green
