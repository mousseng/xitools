$addons = "$PSScriptRoot\addons\"
$config = "$PSScriptRoot\config\"

$tgt = "$($env:LocalAppData)\HorizonXI\Game\"

Copy-Item -Recurse -Container -Force -Path $addons -Destination $tgt
Copy-Item -Recurse -Container -Force -Path $config -Destination $tgt
