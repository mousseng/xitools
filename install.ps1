$addons = "$PSScriptRoot\addons\"
$config = "$PSScriptRoot\config\"
$scripts = "$PSScriptRoot\scripts\"

$tgt = "$($env:LocalAppData)\HorizonXI\Game\"

Copy-Item -Recurse -Container -Force -Path $addons -Destination $tgt
Copy-Item -Recurse -Container -Force -Path $config -Destination $tgt -Exclude *.png
Copy-Item -Recurse -Container -Force -Path $scripts -Destination $tgt
