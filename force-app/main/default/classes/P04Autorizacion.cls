/** Autorización de escritura P04. No es un servicio de consulta ni evalúa garantías. */
public without sharing class P04Autorizacion {
    private static final String DENEGADO = 'P04: operación no autorizada.';
    private static final List<String> EVALUACION = new List<String>{
        'P04_ResultadoGarantia__c','P04_MotivoGarantia__c','P04_CompraEvaluada__c',
        'P04_InicioEvaluado__c','P04_FinEvaluado__c','P04_IncidenciaEvaluada__c','P04_EvaluadaEl__c'
    };
    private static Boolean administrador() { return FeatureManagement.checkPermission('P04_Administrar'); }
    private static Boolean responsable() { return FeatureManagement.checkPermission('P04_Gestionar'); }
    private static Boolean agente() { return FeatureManagement.checkPermission('P04_Usar'); }

    // Solo devuelve pertenencia al ámbito al trigger, nunca datos a una API/UI.
    private static Set<Id> clientesProyecto(Set<Id> ids) {
        Set<Id> encontrados=new Set<Id>();
        if (!ids.isEmpty()) for (Account a : [SELECT Id FROM Account WHERE Id IN :ids AND P04_Posventa__c=true WITH SYSTEM_MODE]) encontrados.add(a.Id);
        return encontrados;
    }

    public static void cuentas(List<Account> rows, Map<Id,Account> anteriores, Boolean borrar) {
        if (administrador()) return;
        Boolean gestiona=responsable(), usa=agente();
        for (Account row:rows) {
            Account old=anteriores==null?null:anteriores.get(row.Id);
            Boolean proyecto=row.P04_Posventa__c || (old!=null && old.P04_Posventa__c);
            if (!proyecto && !gestiona && !usa) continue; // No altera otras aplicaciones.
            if (borrar || !gestiona || (old!=null && (!old.P04_Posventa__c || !row.P04_Posventa__c))) row.addError(DENEGADO);
            else if (old==null) row.P04_Posventa__c=true;
            else if (row.OwnerId!=old.OwnerId) row.addError(DENEGADO);
        }
    }

    public static void contactos(List<Contact> rows, Map<Id,Contact> anteriores, Boolean borrar) {
        if (administrador()) return;
        Set<Id> ids=new Set<Id>();
        for(Contact row:rows){ids.add(row.AccountId);if(anteriores!=null)ids.add(anteriores.get(row.Id).AccountId);}
        ids.remove(null); Set<Id> clientes=clientesProyecto(ids);
        Boolean gestiona=responsable(), usa=agente();
        for(Contact row:rows){
            Contact old=anteriores==null?null:anteriores.get(row.Id);
            Boolean proyecto=clientes.contains(row.AccountId)||(old!=null&&clientes.contains(old.AccountId));
            if(!proyecto&&!gestiona&&!usa)continue;
            if(borrar||!gestiona||!clientes.contains(row.AccountId)||(old!=null&&!clientes.contains(old.AccountId))||(old!=null&&row.OwnerId!=old.OwnerId))row.addError(DENEGADO);
        }
    }

    public static void productos(List<Asset> rows, Map<Id,Asset> anteriores, Boolean borrar) {
        if(administrador())return;
        Set<Id> ids=new Set<Id>();for(Asset row:rows)ids.add(row.AccountId);ids.remove(null);
        Set<Id> clientes=clientesProyecto(ids);Boolean gestiona=responsable(),usa=agente();
        for(Asset row:rows){
            Asset old=anteriores==null?null:anteriores.get(row.Id);
            Boolean proyecto=row.RecordTypeId==P04Integridad.PRODUCTO||(old!=null&&old.RecordTypeId==P04Integridad.PRODUCTO);
            if(!proyecto&&!gestiona&&!usa)continue;
            if(borrar||!gestiona||row.RecordTypeId!=P04Integridad.PRODUCTO||!clientes.contains(row.AccountId)||(old!=null&&old.RecordTypeId!=P04Integridad.PRODUCTO)||(old!=null&&row.OwnerId!=old.OwnerId))row.addError(DENEGADO);
        }
    }

    public static void casos(List<Case> rows, Map<Id,Case> anteriores, Boolean borrar) {
        if(administrador())return;
        Boolean gestiona=responsable(),usa=agente();
        Set<Id> cuentas=new Set<Id>(),destinos=new Set<Id>();
        for(Case row:rows){
            cuentas.add(row.AccountId);
            if(gestiona&&!borrar&&(anteriores==null||row.OwnerId!=anteriores.get(row.Id).OwnerId))destinos.add(row.OwnerId);
        }
        cuentas.remove(null);destinos.remove(null);
        Set<Id> clientes=clientesProyecto(cuentas),equipo=new Set<Id>();
        if(!destinos.isEmpty())for(PermissionSetAssignment psa:[
            SELECT AssigneeId FROM PermissionSetAssignment
            WHERE AssigneeId IN :destinos AND Assignee.IsActive=true
            AND PermissionSet.Name IN ('P04_Agente','P04_Responsable') WITH SYSTEM_MODE
        ])equipo.add(psa.AssigneeId);
        for(Case row:rows){
            Case old=anteriores==null?null:anteriores.get(row.Id);
            Boolean proyecto=row.RecordTypeId==P04Integridad.CASO||(old!=null&&old.RecordTypeId==P04Integridad.CASO);
            if(!proyecto&&!gestiona&&!usa)continue;
            Boolean permitido=!borrar&&(gestiona||usa)&&row.RecordTypeId==P04Integridad.CASO&&clientes.contains(row.AccountId)&&(old==null||old.RecordTypeId==P04Integridad.CASO);
            if(!gestiona){
                permitido=permitido&&row.OwnerId==UserInfo.getUserId()&&(old==null||old.OwnerId==UserInfo.getUserId());
            }else if(old==null||row.OwnerId!=old.OwnerId){permitido=permitido&&equipo.contains(row.OwnerId);}
            for(String field:EVALUACION)if(row.get(field)!=(old==null?null:old.get(field)))permitido=false;
            if(!permitido)row.addError(DENEGADO);
        }
    }
}
