/** Integridad del ciclo para cualquier ejecutor, incluido administración. No calcula cobertura. */
public without sharing class P04Ciclo {
    private static final Set<String> PROTEGIDOS=new Set<String>{
        'Status','OwnerId','RecordTypeId','AccountId','ContactId','AssetId','Subject','Description','Origin','Priority',
        'SuppliedEmail','SuppliedName','SuppliedPhone','SuppliedCompany','Type','Reason','ParentId','IsEscalated',
        'P04_FechaIncidencia__c','P04_TipoResolucion__c','P04_ExplicacionResolucion__c',
        'P04_ResultadoGarantia__c','P04_MotivoGarantia__c','P04_CompraEvaluada__c','P04_InicioEvaluado__c',
        'P04_FinEvaluado__c','P04_IncidenciaEvaluada__c','P04_EvaluadaEl__c'
    };
    public static void comprobar(List<Case> rows,Map<Id,Case> anteriores){
        Set<Id> productos=new Set<Id>(),propietarios=new Set<Id>();
        for(Case c:rows)if(c.RecordTypeId==P04Integridad.CASO&&c.Status=='P04_Cerrado'&&anteriores!=null&&anteriores.get(c.Id).Status!='P04_Cerrado'){
            productos.add(c.AssetId);propietarios.add(c.OwnerId);
        }
        Set<Id> habilitados=P04Cola.habilitados(propietarios);
        Map<Id,Asset> assets=new Map<Id,Asset>();
        if(!productos.isEmpty())assets=new Map<Id,Asset>([SELECT Id,PurchaseDate,P04_InicioGarantia__c,P04_FinGarantia__c
            FROM Asset WHERE Id IN :productos WITH SYSTEM_MODE FOR UPDATE]);
        for(Case c:rows){
            Case old=anteriores==null?null:anteriores.get(c.Id);
            if(c.RecordTypeId!=P04Integridad.CASO&&(old==null||old.RecordTypeId!=P04Integridad.CASO))continue;
            if(old!=null&&old.Status=='P04_Cerrado'){
                for(String campo:PROTEGIDOS)if(c.get(campo)!=old.get(campo)){c.addError('P04: un caso cerrado no admite reapertura ni cambios funcionales.');break;}
                continue;
            }
            if(old==null){if(c.Status!='P04_Nuevo')c.addError('P04: el caso debe crearse en Nuevo; solo se admiten los cuatro estados P04.');continue;}
            if(old.Status==c.Status)continue;
            Boolean valido=(old.Status=='P04_Nuevo'&&c.Status=='P04_EnCurso')||
                (old.Status=='P04_EnCurso'&&(c.Status=='P04_PendienteInformacion'||c.Status=='P04_Cerrado'))||
                (old.Status=='P04_PendienteInformacion'&&(c.Status=='P04_EnCurso'||c.Status=='P04_Cerrado'));
            if(!valido){c.addError('P04: transición de estado no permitida.');continue;}
            if(c.Status!='P04_Cerrado')continue;
            if(!habilitados.contains(c.OwnerId)){c.addError('P04: cierre requiere propietario individual activo, habilitado y miembro del equipo.');continue;}
            if(String.isBlank(c.P04_TipoResolucion__c)||String.isBlank(c.P04_ExplicacionResolucion__c)){
                c.addError('P04: cierre requiere tipo de resolución y explicación con contenido.');continue;
            }
            if(c.P04_EvaluadaEl__c==null||String.isBlank(c.P04_ResultadoGarantia__c)||String.isBlank(c.P04_MotivoGarantia__c)){
                c.addError('P04: evalúe explícitamente la garantía antes de cerrar.');continue;
            }
            if(c.P04_ResultadoGarantia__c=='Pendiente_datos'&&c.P04_TipoResolucion__c!='Sin_actuacion'){
                c.addError('P04: pendiente de datos solo permite cierre Sin_actuacion explicado.');continue;
            }
            Asset a=assets.get(c.AssetId);
            if(a==null||c.P04_CompraEvaluada__c!=a.PurchaseDate||c.P04_InicioEvaluado__c!=a.P04_InicioGarantia__c||
                c.P04_FinEvaluado__c!=a.P04_FinGarantia__c||c.P04_IncidenciaEvaluada__c!=c.P04_FechaIncidencia__c)
                c.addError('P04: los datos han cambiado; reevalúe explícitamente antes de cerrar.');
        }
    }
}
