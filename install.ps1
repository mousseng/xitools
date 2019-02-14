$addons = "$PSScriptRoot\addons\"
$config = "$PSScriptRoot\config\"

$tgt = "$($env:LocalAppData)\PlayOnline\Ashita\"

Copy-Item -Recurse -Container -Force -Path $addons -Destination $tgt
Copy-Item -Recurse -Container -Force -Path $config -Destination $tgt
