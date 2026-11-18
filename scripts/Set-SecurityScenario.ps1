param([Parameter(Mandatory)][string]$ExpectedOrgId,[Parameter(Mandatory)][string]$ExpectedUserId,[Parameter(Mandatory)][ValidateSet('Ninguno','Agente','Responsable')][string]$Scenario)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
if($ExpectedUserId -notmatch '^005[A-Za-z0-9]{12}([A-Za-z0-9]{3})?$'){throw 'Id ordinario no válido.'}
$root=Split-Path $PSScriptRoot -Parent
$local=Join-Path $root '.local'
[IO.Directory]::CreateDirectory($local)|Out-Null
$source=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'apex/security-scenario.apex'))
$source=$source.Replace('__P04_USER__',$ExpectedUserId).Replace('__P04_SCENARIO__',$Scenario)
$script=Join-Path $local 's04-scenario.apex'
[IO.File]::WriteAllText($script,$source,(New-Object System.Text.UTF8Encoding($false)))
$j=Invoke-P04Sf -Arguments @('apex','run','--file',$script,'--target-org','p04-posventa-dev')
if(-not $j.result.success -or $j.result.logs -notmatch 'P04_SCENARIO_OK=([A-Za-z]+)'){throw 'No se confirmó el cambio de escenario.'}
"Escenario $Scenario aplicado. Renovar contexto y contrastar permisos efectivos y compartición antes de interpretar las pruebas."
