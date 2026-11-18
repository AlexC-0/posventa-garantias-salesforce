param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$j = Invoke-P04Sf -Arguments @('apex','run','test','--class-names','P04ModeloTest','--synchronous','--code-coverage','--result-format','json','--target-org','p04-posventa-dev')
if ($j.result.summary.outcome -ne 'Passed') { throw 'La suite Apex no ha pasado.' }
$j.result.summary | Select-Object outcome, testsRan, passing, failing, testRunCoverage