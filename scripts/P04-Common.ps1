# Utilidades mínimas para comprobaciones del modelo. Nunca exportan autenticación.
$ErrorActionPreference = 'Stop'
function Invoke-P04Sf {
    param([string[]]$Arguments, [switch]$AllowFailure)
    $raw = & (Get-Command sf.cmd -ErrorAction Stop).Source @Arguments --json
    $exitCode = $LASTEXITCODE
    $result = ($raw -join [Environment]::NewLine) | ConvertFrom-Json
    if (-not $AllowFailure -and ($exitCode -ne 0 -or $result.status -ne 0)) {
        throw ('Salesforce: {0}: {1}' -f $result.name, $result.message)
    }
    return $result
}
function Assert-P04Target {
    param([Parameter(Mandatory)][string]$ExpectedOrgId)
    if ($ExpectedOrgId -notmatch '^00D[A-Za-z0-9]{12}([A-Za-z0-9]{3})?$') { throw 'Id esperado no válido.' }
    $j = Invoke-P04Sf -Arguments @('data','query','--target-org','p04-posventa-dev','--query','SELECT Id, OrganizationType FROM Organization')
    $org = @($j.result.records)[0]
    if ($org.Id.Substring(0,15) -cne $ExpectedOrgId.Substring(0,15) -or $org.OrganizationType -ne 'Developer Edition') {
        throw 'Destino distinto del P04 verificado. No se realizará ninguna escritura.'
    }
}