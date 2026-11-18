param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$root=Split-Path $PSScriptRoot -Parent
$local=Join-Path $root '.local'
[IO.Directory]::CreateDirectory($local)|Out-Null
$j=Invoke-P04Sf -Arguments @('apex','run','--file',(Join-Path $PSScriptRoot 'apex/security-user.apex'),'--target-org','p04-posventa-dev')
if(-not $j.result.success -or $j.result.logs -notmatch 'P04_SECURITY_USER=(\{[^\r\n]+\})'){throw 'No se pudo confirmar el usuario de pruebas.'}
$identity=$Matches[1]|ConvertFrom-Json
[IO.File]::WriteAllText((Join-Path $local 's04-user.json'),($identity|ConvertTo-Json),(New-Object System.Text.UTF8Encoding($false)))
'Usuario ordinario preparado sin correo de bienvenida. Identidad guardada solo en .local/s04-user.json.'
