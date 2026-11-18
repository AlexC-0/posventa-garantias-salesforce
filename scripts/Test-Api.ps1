param([Parameter(Mandatory)][string]$ExpectedOrgId)
. (Join-Path $PSScriptRoot 'P04-Common.ps1')
Assert-P04Target -ExpectedOrgId $ExpectedOrgId
$ids = Get-Content -LiteralPath (Join-Path (Split-Path $PSScriptRoot -Parent) '.local/s03-demo.json') -Raw | ConvertFrom-Json
foreach($id in @($ids.caseA,$ids.caseB)) { if($id -notmatch '^[A-Za-z0-9]{15}([A-Za-z0-9]{3})?$'){throw 'Id de muestra no válido.'} }
$query="SELECT Id, Subject, RecordTypeId, RecordType.DeveloperName, AccountId, ContactId, AssetId, P04_FechaIncidencia__c FROM Case WHERE Id IN ('$($ids.caseA)','$($ids.caseB)')"
$read = Invoke-P04Sf -Arguments @('data','query','--target-org','p04-posventa-dev','--query',$query)
$records=@($read.result.records)
if($records.Count -ne 2){throw 'Falta la muestra; no se escribirá.'}
foreach($row in $records){if($row.RecordType.DeveloperName -ne 'P04_Posventa' -or $row.Subject -notlike 'P04 DEMO -*'){throw 'La muestra no coincide.'}}
$a=$records|Where-Object {$_.Id -eq $ids.caseA}
$b=$records|Where-Object {$_.Id -eq $ids.caseB}
if($a.AccountId -eq $b.AccountId){throw 'Se requieren clientes distintos.'}
$created=New-Object System.Collections.Generic.List[string]
$checks=New-Object System.Collections.Generic.List[object]
function Assert-Rejected($result,$label){
    if($result.status -eq 0){
        if($result.result.id -and -not $created.Contains([string]$result.result.id)){$created.Add([string]$result.result.id)}
        throw ('La API aceptó un registro inválido: '+$label)
    }
    if(($result|ConvertTo-Json -Depth 8 -Compress) -notmatch 'P04:'){throw ('Rechazo inesperado: '+$label)}
    $checks.Add([pscustomobject]@{Check=$label;Expected='Rechazo P04';Actual='Rechazo P04';Passed=$true})
}
try {
    $values="RecordTypeId='$($a.RecordTypeId)' AccountId='$($a.AccountId)' ContactId='$($a.ContactId)' AssetId='$($a.AssetId)' P04_FechaIncidencia__c='$($a.P04_FechaIncidencia__c)' Subject='P04 API temporal' Origin='Web' Status='P04_Nuevo'"
    $j=Invoke-P04Sf -Arguments @('data','create','record','--sobject','Case','--values',$values,'--target-org','p04-posventa-dev')
    if(-not $j.result.id){throw 'La API no devolvió el registro creado.'}
    $created.Add([string]$j.result.id)
    $id=$created[0]
    $checks.Add([pscustomobject]@{Check='Creación por API';Expected='Aceptada';Actual='Aceptada';Passed=$true})
    $null=Invoke-P04Sf -Arguments @('data','update','record','--sobject','Case','--record-id',$id,'--values',"Subject='P04 API editado'",'--target-org','p04-posventa-dev')
    # +2 días UTC siempre supera el día local actual de cualquier zona Salesforce.
    $future=[DateTime]::UtcNow.AddDays(2).ToString('yyyy-MM-dd')
    $bad=Invoke-P04Sf -AllowFailure -Arguments @('data','update','record','--sobject','Case','--record-id',$id,'--values',"P04_FechaIncidencia__c='$future'",'--target-org','p04-posventa-dev')
    Assert-Rejected $bad 'Edición con incidencia futura'
    $badValues=$values.Replace("ContactId='$($a.ContactId)'","ContactId='$($b.ContactId)'")
    $bad=Invoke-P04Sf -AllowFailure -Arguments @('data','create','record','--sobject','Case','--values',$badValues,'--target-org','p04-posventa-dev')
    Assert-Rejected $bad 'Creación con contacto de otro cliente'
    $read=Invoke-P04Sf -Arguments @('data','query','--query',"SELECT Subject, P04_FechaIncidencia__c, P04_ResultadoGarantia__c FROM Case WHERE Id='$id'",'--target-org','p04-posventa-dev')
    $row=@($read.result.records)[0]
    if($row.Subject -ne 'P04 API editado' -or $row.P04_FechaIncidencia__c -ne $a.P04_FechaIncidencia__c -or $null -ne $row.P04_ResultadoGarantia__c){throw 'Valores persistidos inesperados.'}
    $checks.Add([pscustomobject]@{Check='Lectura tras edición válida y rechazo';Expected='Edición conservada, fecha anterior y sin evaluar';Actual='Edición conservada, fecha anterior y sin evaluar';Passed=$true})
} finally {
    # Solo identificadores devueltos por las creaciones de esta ejecución.
    foreach($id in $created){$null=Invoke-P04Sf -Arguments @('data','delete','record','--sobject','Case','--record-id',$id,'--target-org','p04-posventa-dev')}
}
$checks.Add([pscustomobject]@{Check='Limpieza de casos temporales';Expected='Eliminados solo los creados';Actual='Eliminados solo los creados';Passed=$true})
$checks | ConvertTo-Json -Depth 4