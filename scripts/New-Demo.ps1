param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$j = Invoke-P04Sf -Arguments @('apex','run','--file',(Join-Path $PSScriptRoot 'apex/demo.apex'),'--target-org','p04-posventa-dev')
if (-not $j.result.success) { throw 'La creación de muestra no terminó correctamente.' }
if ($j.result.logs -notmatch 'P04_DEMO_JSON=(\{[^\r\n]+\})') { throw 'No se recibió el identificador de la muestra.' }
$ids = $Matches[1] | ConvertFrom-Json
$local = Join-Path (Split-Path $PSScriptRoot -Parent) '.local'
[IO.Directory]::CreateDirectory($local) | Out-Null
[IO.File]::WriteAllText((Join-Path $local 's03-demo.json'), ($ids | ConvertTo-Json), (New-Object System.Text.UTF8Encoding($false)))
Write-Output 'Muestra creada: dos clientes, dos contactos, dos productos y dos casos. Identificadores guardados únicamente en .local.'