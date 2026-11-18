/** Único servicio de evaluación. Entrada por IDs; lectura USER_MODE y escritura sellada de siete campos. */
public with sharing class P04Garantia {
    private static final Set<String> CAMPOS = new Set<String>{
        'P04_ResultadoGarantia__c','P04_MotivoGarantia__c','P04_CompraEvaluada__c',
        'P04_InicioEvaluado__c','P04_FinEvaluado__c','P04_IncidenciaEvaluada__c','P04_EvaluadaEl__c'
    };
    // Sin setter público ni @TestVisible: solo evaluar puede preparar esta capacidad transitoria.
    private static Map<Id,Case> escrituras = new Map<Id,Case>();
    public class Resultado {
        @InvocableVariable public Boolean correcto;
        @InvocableVariable public String codigo;
        @InvocableVariable public String mensaje;
        @InvocableVariable public String cobertura;
    }
    private static Resultado respuesta(String codigo,String mensaje){
        Resultado r=new Resultado();r.correcto=false;r.codigo=codigo;r.mensaje=mensaje;return r;
    }
    private static Resultado denegada(){return respuesta('NO_AUTORIZADO','P04: caso no disponible para esta operación.');}
    private static List<Resultado> abortar(List<Resultado> rows){
        for(Integer i=0;i<rows.size();i++)if(rows[i]==null||rows[i].correcto)rows[i]=respuesta('LOTE_RECHAZADO','P04: no se guardó el lote porque alguna solicitud fue rechazada.');
        return rows;
    }

    /** 0..200 solicitudes. Duplicados comparten cálculo, no DML; cualquier error rechaza todo el lote. */
    public static List<Resultado> evaluar(List<String> solicitudes){
        List<Resultado> results=new List<Resultado>();
        if(solicitudes==null||solicitudes.isEmpty())return results;
        for(String ignored:solicitudes)results.add(null);
        if(solicitudes.size()>200){for(Integer i=0;i<results.size();i++)results[i]=respuesta('LIMITE_LOTE','P04: máximo 200 solicitudes por operación.');return results;}
        Boolean admin=FeatureManagement.checkPermission('P04_Administrar');
        Boolean manager=FeatureManagement.checkPermission('P04_Gestionar');
        Boolean agent=FeatureManagement.checkPermission('P04_Usar');
        if((!admin&&!manager&&!agent)||!Schema.sObjectType.Case.isUpdateable()||!escrituras.isEmpty()){
            for(Integer i=0;i<results.size();i++)results[i]=denegada();return results;
        }
        List<Id> ordered=new List<Id>();Set<Id> ids=new Set<Id>();Boolean bad=false;
        for(Integer i=0;i<solicitudes.size();i++){
            Id id;
            try{if(String.isBlank(solicitudes[i]))throw new EntradaException();id=(Id)solicitudes[i].trim();if(id.getSObjectType()!=Case.SObjectType)throw new EntradaException();}
            catch(Exception e){results[i]=respuesta('ENTRADA_INVALIDA','P04: indique un identificador de caso válido.');bad=true;}
            ordered.add(id);if(id!=null)ids.add(id);
        }
        if(bad)return abortar(results);
        Map<Id,Case> cases;Map<Id,Asset> assets;Map<Id,Account> accounts;Map<Id,Contact> contacts;
        Set<Id> editable=new Set<Id>();
        try{
            // Bloqueo del caso: no evaluar un estado leído antes de un cierre concurrente.
            cases=new Map<Id,Case>([SELECT Id,OwnerId,RecordTypeId,IsClosed,AccountId,ContactId,AssetId,P04_FechaIncidencia__c
                FROM Case WHERE Id IN :ids WITH USER_MODE FOR UPDATE]);
            for(UserRecordAccess access:[SELECT RecordId,HasEditAccess FROM UserRecordAccess
                WHERE UserId=:UserInfo.getUserId() AND RecordId IN :ids WITH USER_MODE])if(access.HasEditAccess)editable.add(access.RecordId);
            Set<Id> assetIds=new Set<Id>(),accountIds=new Set<Id>(),contactIds=new Set<Id>();
            for(Case c:cases.values()){
                if(c.RecordTypeId==P04Integridad.CASO&&editable.contains(c.Id)&&(admin||manager||c.OwnerId==UserInfo.getUserId())){
                    assetIds.add(c.AssetId);accountIds.add(c.AccountId);contactIds.add(c.ContactId);
                }
            }
            assetIds.remove(null);accountIds.remove(null);contactIds.remove(null);
            assets=new Map<Id,Asset>([SELECT Id,RecordTypeId,AccountId,ContactId,PurchaseDate,P04_InicioGarantia__c,P04_FinGarantia__c
                FROM Asset WHERE Id IN :assetIds WITH USER_MODE FOR UPDATE]);
            for(Asset a:assets.values())if(a.ContactId!=null)contactIds.add(a.ContactId);
            accounts=new Map<Id,Account>([SELECT Id,P04_Posventa__c FROM Account WHERE Id IN :accountIds WITH USER_MODE]);
            contacts=new Map<Id,Contact>([SELECT Id,AccountId FROM Contact WHERE Id IN :contactIds WITH USER_MODE]);
        }catch(QueryException e){for(Integer i=0;i<results.size();i++)results[i]=denegada();return results;}
        Map<Id,Case> updates=new Map<Id,Case>();Map<Id,Resultado> outcomes=new Map<Id,Resultado>();
        Datetime evaluatedAt=System.now();
        for(Id id:ids){
            Case c=cases.get(id);Asset a=c==null?null:assets.get(c.AssetId);
            if(c==null||c.RecordTypeId!=P04Integridad.CASO||!editable.contains(id)||(!admin&&!manager&&c.OwnerId!=UserInfo.getUserId())||
                a==null||!accounts.containsKey(c.AccountId)||!contacts.containsKey(c.ContactId)||(a.ContactId!=null&&!contacts.containsKey(a.ContactId))){outcomes.put(id,denegada());bad=true;continue;}
            if(c.IsClosed){outcomes.put(id,respuesta('CASO_CERRADO','P04: un caso cerrado conserva su evaluación.'));bad=true;continue;}
            String error=errorDatos(c,a,accounts.get(c.AccountId),contacts.get(c.ContactId),contacts.get(a.ContactId));
            if(error!=null){outcomes.put(id,respuesta('DATOS_INVALIDOS',error));bad=true;continue;}
            Case patch=calcular(c,a,evaluatedAt);updates.put(id,patch);
            Resultado r=respuesta('OK','P04: evaluación guardada.');r.correcto=true;r.cobertura=patch.P04_ResultadoGarantia__c;outcomes.put(id,r);
        }
        for(Integer i=0;i<ordered.size();i++)results[i]=outcomes.get(ordered[i]);
        if(bad)return abortar(results);
        try{
            escrituras=updates.deepClone();
            // Única escritura privilegiada: solo IDs autorizados y los siete campos calculados.
            Database.update(updates.values(),true,AccessLevel.SYSTEM_MODE);
        }catch(DmlException e){
            for(Integer i=0;i<results.size();i++)results[i]=respuesta('GUARDADO_RECHAZADO','P04: no se guardó ninguna evaluación; revise los datos o reintente la operación.');
        }finally{escrituras.clear();}
        return results;
    }
    private class EntradaException extends Exception {}

    /** Predicado de solo lectura para el trigger. No concede permisos ni admite habilitar el contexto. */
    public static Boolean escrituraLegitima(Case actual,Case anterior){
        if(actual==null||anterior==null||anterior.IsClosed||!escrituras.containsKey(actual.Id))return false;
        Case expected=escrituras.get(actual.Id);
        for(String field:CAMPOS)if(actual.get(field)!=expected.get(field))return false;
        Map<String,Object> oldValues=anterior.getPopulatedFieldsAsMap(),newValues=actual.getPopulatedFieldsAsMap();
        Set<String> keys=new Set<String>();keys.addAll(oldValues.keySet());keys.addAll(newValues.keySet());
        for(String key:keys)if(!CAMPOS.contains(key)&&oldValues.get(key)!=newValues.get(key))return false;
        return true;
    }

    // Validación defensiva de datos ya recuperados. TestVisible no da acceso al contexto de escritura.
    @TestVisible private static String errorDatos(Case c,Asset a,Account account,Contact contact,Contact productContact){
        if(c.AccountId==null||c.ContactId==null||c.AssetId==null||c.P04_FechaIncidencia__c==null||
            !account.P04_Posventa__c||a.RecordTypeId!=P04Integridad.PRODUCTO||a.Id!=c.AssetId||a.AccountId!=c.AccountId||
            contact.AccountId!=c.AccountId||(a.ContactId!=null&&(productContact==null||productContact.AccountId!=a.AccountId)))return 'P04: relaciones o datos obligatorios incoherentes.';
        Date day=c.P04_FechaIncidencia__c;
        if(day>Date.today())return 'P04: la incidencia no puede ser futura.';
        if(a.PurchaseDate!=null&&day<a.PurchaseDate)return 'P04: la incidencia no puede ser anterior a la compra.';
        if(a.P04_InicioGarantia__c!=null&&a.P04_FinGarantia__c!=null&&a.P04_InicioGarantia__c>a.P04_FinGarantia__c)return 'P04: el intervalo de garantía está invertido.';
        return null;
    }
    private static Case calcular(Case c,Asset a,Datetime evaluatedAt){
        String coverage,reason;
        if(a.P04_InicioGarantia__c==null||a.P04_FinGarantia__c==null){
            coverage='Pendiente_datos';
            reason=a.P04_InicioGarantia__c==null?(a.P04_FinGarantia__c==null?'Faltan inicio y fin de garantía.':'Falta el inicio de garantía.'):'Falta el fin de garantía.';
        }else if(c.P04_FechaIncidencia__c<a.P04_InicioGarantia__c){coverage='Fuera_cobertura';reason='La incidencia es anterior al inicio de garantía.';}
        else if(c.P04_FechaIncidencia__c>a.P04_FinGarantia__c){coverage='Fuera_cobertura';reason='La incidencia es posterior al fin de garantía.';}
        else{coverage='En_cobertura';reason='La incidencia está dentro del intervalo de garantía, incluidos sus límites.';}
        return new Case(Id=c.Id,P04_ResultadoGarantia__c=coverage,P04_MotivoGarantia__c=reason,
            P04_CompraEvaluada__c=a.PurchaseDate,P04_InicioEvaluado__c=a.P04_InicioGarantia__c,P04_FinEvaluado__c=a.P04_FinGarantia__c,
            P04_IncidenciaEvaluada__c=c.P04_FechaIncidencia__c,P04_EvaluadaEl__c=evaluatedAt);
    }
}
