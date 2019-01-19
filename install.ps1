[Security.Principal.WindowsPrincipal]$role = [Security.Principal.WindowsIdentity]::GetCurrent()
[Security.Principal.WindowsBuiltInRole]$admin = 'Administrator'

if (!$role.IsInRole($admin)) {
    Start-Process powershell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath"
}
else {
    Set-Location $PSScriptRoot
    Copy-Item -Recurse -Container -Force -Path 'addons' -Destination "$([Environment]::GetEnvironmentVariable("ProgramFiles(x86)"))\PlayOnline\Ashita\"
}
