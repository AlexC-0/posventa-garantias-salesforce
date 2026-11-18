param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$j=Invoke-P04Sf -Arguments @('apex','run','--file',(Join-Path $PSScriptRoot 'apex/garantia-demo.apex'),'--target-org','p04-posventa-dev')
if(-not $j.result.success -or $j.result.logs -notmatch 'P04_GARANTIA_DEMO_OK'){throw 'Demostración no confirmada; revisar el resultado privado sin publicar datos de autenticación.'}
'Demostración administrativa: evaluación, instantánea histórica, reevaluación y cierre correctos. Producto y caso temporales revertidos.'
