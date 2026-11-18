param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$root=Split-Path $PSScriptRoot -Parent
$sample=Get-Content (Join-Path $root '.local/s04-records.json') -Raw|ConvertFrom-Json
foreach($id in @($sample.ownCase,$sample.teamCase,$sample.account)){
    if($id -notmatch '^[A-Za-z0-9]{15}([A-Za-z0-9]{3})?$'){throw 'Identificador temporal no válido.'}
}
if($sample.ownCase -eq $sample.teamCase){throw 'Identificadores de casos duplicados.'}
$source=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'apex/security-cleanup.apex'))
$source=$source.Replace('__OWN__',$sample.ownCase).Replace('__TEAM__',$sample.teamCase).Replace('__ACCOUNT__',$sample.account)
$file=Join-Path $root '.local/s04-cleanup.apex'
[IO.File]::WriteAllText($file,$source,[Text.UTF8Encoding]::new($false))
$j=Invoke-P04Sf -Arguments @('apex','run','--file',$file,'--target-org','p04-posventa-dev')
if(-not $j.result.success -or $j.result.logs -notmatch 'P04_SECURITY_CLEANUP_OK'){throw 'No se confirmó la limpieza acotada.'}
'Casos temporales eliminados; muestra original conservada. Sin purga de papelera.'
