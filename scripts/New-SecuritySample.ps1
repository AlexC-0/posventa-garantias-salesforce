param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$j=Invoke-P04Sf -Arguments @('apex','run','--file',(Join-Path $PSScriptRoot 'apex/security-sample.apex'),'--target-org','p04-posventa-dev')
if(-not $j.result.success -or $j.result.logs -notmatch 'P04_SECURITY_SAMPLE=(\{[^\r\n]+\})'){throw 'No se confirmó la muestra temporal.'}
$sample=$Matches[1]|ConvertFrom-Json
$local=Join-Path (Split-Path $PSScriptRoot -Parent) '.local';[IO.Directory]::CreateDirectory($local)|Out-Null
[IO.File]::WriteAllText((Join-Path $local 's04-records.json'),($sample|ConvertTo-Json),(New-Object System.Text.UTF8Encoding($false)))
'Dos casos temporales preparados. Clientes de muestra marcados P04; identificadores solo en .local.'
