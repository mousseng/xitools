$src = "$PSScriptRoot\addons\"
$tgt = "$($env:LocalAppData)\PlayOnline\Ashita\"

Copy-Item -Recurse -Container -Force -Path $src -Destination $tgt
