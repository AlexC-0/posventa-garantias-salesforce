param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
# Los fixtures comparten la cola de metadatos. Evitar contencion de GroupMember entre clases.
foreach($suite in @('P04ModeloTest','P04SeguridadTest','P04GarantiaTest','P04CicloTest','P04ConsultaCasoTest')) {
    $j=Invoke-P04Sf -Arguments @('apex','run','test','--class-names',$suite,'--synchronous','--code-coverage','--result-format','json','--target-org','p04-posventa-dev')
    if($j.result.summary.outcome -ne 'Passed'){throw "Consulta o regresion sin resultado satisfactorio: $suite"}
    $j.result.summary|Select-Object @{Name='suite';Expression={$suite}},outcome,testsRan,passing,failing,testRunCoverage
}
