param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$j=Invoke-P04Sf -Arguments @('apex','run','test','--class-names','P04ModeloTest','--class-names','P04SeguridadTest','--wait','5','--code-coverage','--result-format','json','--target-org','p04-posventa-dev')
if($j.result.summary.outcome -ne 'Passed'){throw 'Regresión o pruebas de seguridad sin resultado satisfactorio.'}
$j.result.summary|Select-Object outcome,testsRan,passing,failing,testRunCoverage
