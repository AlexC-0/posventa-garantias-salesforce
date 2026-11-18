/** Consulta acotada y sin DML. No utiliza los helpers de integridad en modo sistema. */
public with sharing class P04ConsultaCaso {
    private static Map<String,Object> rechazo(String codigo) {
        return new Map<String,Object>{'codigo'=>codigo};
    }

    // Invocación imperativa sin caché de cliente: Actualizar vuelve a autorizar y consultar.
    @AuraEnabled
    public static Map<String,Object> consultar(String caseId) {
        if (!FeatureManagement.checkPermission('P04_Usar') &&
            !FeatureManagement.checkPermission('P04_Gestionar') &&
            !FeatureManagement.checkPermission('P04_Administrar')) return rechazo('NO_DISPONIBLE');
        Id id;
        try {
            id = (Id)caseId;
            if (id == null || id.getSObjectType() != Case.SObjectType) return rechazo('NO_DISPONIBLE');
        } catch (Exception e) { return rechazo('NO_DISPONIBLE'); }
        try {
            // USER_MODE aplica CRUD, FLS (también filtros/relaciones) y acceso a registros.
            List<Case> casos = [SELECT Id, AssetId, AccountId, IsClosed, P04_FechaIncidencia__c,
                P04_ResultadoGarantia__c, P04_MotivoGarantia__c, P04_CompraEvaluada__c,
                P04_InicioEvaluado__c, P04_FinEvaluado__c, P04_IncidenciaEvaluada__c, P04_EvaluadaEl__c
                FROM Case WHERE Id = :id AND RecordType.DeveloperName = 'P04_Posventa'
                AND Account.P04_Posventa__c = true WITH USER_MODE LIMIT 1];
            if (casos.isEmpty() || casos[0].AssetId == null) return rechazo('NO_DISPONIBLE');
            Case c = casos[0];
            List<Asset> productos = [SELECT Id, Name, SerialNumber, PurchaseDate,
                P04_InicioGarantia__c, P04_FinGarantia__c
                FROM Asset WHERE Id = :c.AssetId AND AccountId = :c.AccountId
                AND RecordType.DeveloperName = 'P04_Producto' WITH USER_MODE LIMIT 1];
            if (productos.isEmpty()) return rechazo('NO_DISPONIBLE');
            Asset a = productos[0];
            // El límite se aplica en la consulta autorizada, nunca filtrando ocultos en JavaScript.
            List<Case> relacionados = [SELECT Id, CaseNumber, Subject, Status, CreatedDate
                FROM Case WHERE AssetId = :c.AssetId AND Id != :c.Id
                AND RecordType.DeveloperName = 'P04_Posventa' AND Account.P04_Posventa__c = true
                WITH USER_MODE ORDER BY CreatedDate DESC, Id DESC LIMIT 5];
            return new Map<String,Object>{
                'codigo'=>'OK',
                'caso'=>new Map<String,Object>{'id'=>c.Id, 'cerrado'=>c.IsClosed,
                    'incidencia'=>c.P04_FechaIncidencia__c, 'resultado'=>c.P04_ResultadoGarantia__c,
                    'motivo'=>c.P04_MotivoGarantia__c, 'compra'=>c.P04_CompraEvaluada__c,
                    'inicio'=>c.P04_InicioEvaluado__c, 'fin'=>c.P04_FinEvaluado__c,
                    'incidenciaEvaluada'=>c.P04_IncidenciaEvaluada__c, 'evaluadaEl'=>c.P04_EvaluadaEl__c},
                'producto'=>new Map<String,Object>{'nombre'=>a.Name, 'serie'=>a.SerialNumber,
                    'compra'=>a.PurchaseDate, 'inicio'=>a.P04_InicioGarantia__c, 'fin'=>a.P04_FinGarantia__c},
                'relacionados'=>relacionados
            };
        } catch (QueryException e) {
            // Rechazo completo ante campos/relaciones restringidos: nunca confundirlos con null.
            return rechazo('NO_DISPONIBLE');
        } catch (SecurityException e) {
            return rechazo('NO_DISPONIBLE');
        } catch (Exception e) {
            return rechazo('ERROR_CONSULTA');
        }
    }
}
