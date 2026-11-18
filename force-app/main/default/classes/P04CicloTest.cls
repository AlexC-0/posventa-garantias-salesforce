@IsTest
private class P04CicloTest {
    @TestSetup static void preparar(){
        Id perfil=[SELECT Id FROM Profile WHERE Name='P04_Minimo' WITH SYSTEM_MODE].Id;
        List<User> users=new List<User>();
        for(String alias:new List<String>{'p06a','p06b','p06r','p06fuera','p06sin'})users.add(new User(Alias=alias,LastName=alias,
            Email=alias+'@example.invalid',Username=alias+'.'+Crypto.getRandomLong()+'@example.invalid',ProfileId=perfil,
            TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US'));
        System.runAs(new User(Id=UserInfo.getUserId())){
            insert as system users;
            Map<String,Id> ps=new Map<String,Id>();for(PermissionSet p:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('P04_Agente','P04_Responsable') WITH SYSTEM_MODE])ps.put(p.Name,p.Id);
            List<PermissionSetAssignment> permisos=new List<PermissionSetAssignment>();List<GroupMember> miembros=new List<GroupMember>();
            for(Integer i=0;i<5;i++){
                if(i<4)permisos.add(new PermissionSetAssignment(AssigneeId=users[i].Id,PermissionSetId=ps.get(i==2?'P04_Responsable':'P04_Agente')));
                if(i!=3)miembros.add(new GroupMember(GroupId=P04Cola.idCola(),UserOrGroupId=users[i].Id));
            }
            insert as system permisos;insert as system miembros;
        }
        Account ac=new Account(Name='P06 cliente',P04_Posventa__c=true);insert as system ac;
        Contact co=new Contact(LastName='P06 contacto',AccountId=ac.Id);insert as system co;
        Asset a=new Asset(Name='P06 producto',AccountId=ac.Id,ContactId=co.Id,RecordTypeId=P04Integridad.PRODUCTO,
            PurchaseDate=Date.newInstance(2024,1,1),P04_InicioGarantia__c=Date.newInstance(2024,2,1),P04_FinGarantia__c=Date.newInstance(2024,3,1));insert as system a;
        List<AccountShare> acs=new List<AccountShare>();List<AssetShare> ass=new List<AssetShare>();
        for(User u:users){acs.add(new AccountShare(AccountId=ac.Id,UserOrGroupId=u.Id,AccountAccessLevel='Read',CaseAccessLevel='None',OpportunityAccessLevel='None'));
            ass.add(new AssetShare(AssetId=a.Id,UserOrGroupId=u.Id,AssetAccessLevel='Read'));}
        insert as system acs;insert as system ass;
        Case c=nuevo(a,'P06 cola');c.OwnerId=P04Cola.idCola();insert as system c;
    }
    private static User usuario(String alias){return [SELECT Id FROM User WHERE Alias=:alias WITH SYSTEM_MODE];}
    private static Asset producto(){return [SELECT Id,AccountId,ContactId,PurchaseDate,P04_InicioGarantia__c,P04_FinGarantia__c FROM Asset WHERE Name='P06 producto' WITH SYSTEM_MODE];}
    private static Case caso(){return [SELECT Id,OwnerId,Status FROM Case WHERE Subject='P06 cola' WITH SYSTEM_MODE];}
    private static Case nuevo(Asset a,String asunto){return new Case(Subject=asunto,RecordTypeId=P04Integridad.CASO,AccountId=a.AccountId,ContactId=a.ContactId,AssetId=a.Id,
        Status='P04_Nuevo',Origin='Web',P04_FechaIncidencia__c=Date.newInstance(2024,2,20));}
    private static void rechazo(Database.SaveResult r){System.assertEquals(false,r.isSuccess());System.assert(r.getErrors().size()>0);}
    private static void estado(Id id,String esperado){System.assertEquals(esperado,[SELECT Status FROM Case WHERE Id=:id WITH SYSTEM_MODE].Status);}
    private static void tomar(Id id){update as user new Case(Id=id,OwnerId=UserInfo.getUserId());}
    private static void evaluar(Id id){P04Garantia.Resultado r=P04Garantia.evaluar(new List<String>{id})[0];System.assert(r.correcto,r.codigo);}
    private static Case cierre(Id id){return new Case(Id=id,Status='P04_Cerrado',P04_TipoResolucion__c='Reparacion',P04_ExplicacionResolucion__c='Prueba ficticia de resolución');}
    private static void prepararCierre(Id id){tomar(id);update as user new Case(Id=id,Status='P04_EnCurso');evaluar(id);}

    @IsTest static void entradaFlowYTomaSinReasignacion(){User u=usuario('p06a');Asset a=producto();System.runAs(u){
        Case c=nuevo(a,'P06 creada');insert as user c;
        System.assertEquals(P04Cola.idCola(),[SELECT OwnerId FROM Case WHERE Id=:c.Id WITH USER_MODE].OwnerId);estado(c.Id,'P04_Nuevo');
        tomar(c.Id);update as user new Case(Id=c.Id,Subject='P06 editada',Status='P04_EnCurso');
        System.assertEquals(u.Id,[SELECT OwnerId FROM Case WHERE Id=:c.Id WITH USER_MODE].OwnerId);estado(c.Id,'P04_EnCurso');
    }}
    @IsTest static void consultaYTomaMiembro(){Case c=caso();User u=usuario('p06a');System.runAs(u){System.assertEquals(1,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);tomar(c.Id);}
        System.assertEquals(u.Id,[SELECT OwnerId FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].OwnerId);
        System.runAs(usuario('p06b')){System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);rechazo(Database.update(new Case(Id=c.Id,OwnerId=UserInfo.getUserId()),false,AccessLevel.SYSTEM_MODE));}}
    @IsTest static void permisoSinMembresiaNoAbreCola(){Case c=caso();Asset a=producto();System.runAs(usuario('p06fuera')){
        System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);
        rechazo(Database.update(new Case(Id=c.Id,OwnerId=UserInfo.getUserId()),false,AccessLevel.USER_MODE));
        rechazo(Database.update(new Case(Id=c.Id,OwnerId=UserInfo.getUserId()),false,AccessLevel.SYSTEM_MODE));
        rechazo(Database.insert(nuevo(a,'No autorizado'),false,AccessLevel.USER_MODE));}}
    @IsTest static void membresiaSinPermisoNoAbreCola(){Case c=caso();System.runAs(usuario('p06sin')){
        Boolean denied=false;try{System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);denied=true;}catch(QueryException e){denied=true;}catch(SecurityException e){denied=true;}System.assert(denied);
        rechazo(Database.update(new Case(Id=c.Id,OwnerId=UserInfo.getUserId()),false,AccessLevel.SYSTEM_MODE));}}
    @IsTest static void revocarMembresia(){Case c=caso();User u=usuario('p06a');
        System.runAs(u){System.assertEquals(1,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);System.assert(P04Cola.miembros(new Set<Id>{u.Id}).contains(u.Id));}
        System.runAs(new User(Id=UserInfo.getUserId())){delete as system [SELECT Id FROM GroupMember WHERE GroupId=:P04Cola.idCola() AND UserOrGroupId=:u.Id WITH SYSTEM_MODE];}
        System.runAs(u){System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);System.assert(!P04Cola.miembros(new Set<Id>{u.Id}).contains(u.Id));rechazo(Database.update(new Case(Id=c.Id,OwnerId=u.Id),false,AccessLevel.SYSTEM_MODE));}}
    @IsTest static void responsableAsignaYReasigna(){Case c=caso();User r=usuario('p06r'),a=usuario('p06a'),b=usuario('p06b');System.runAs(r){update as user new Case(Id=c.Id,OwnerId=a.Id);}
        // En tests las reglas de criterios no se recalculan: share explícito después de transferir.
        insert as system new CaseShare(CaseId=c.Id,UserOrGroupId=r.Id,CaseAccessLevel='Edit');
        System.runAs(r){update as user new Case(Id=c.Id,OwnerId=b.Id);}System.assertEquals(b.Id,[SELECT OwnerId FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].OwnerId);}
    @IsTest static void responsableNoAsignaFuera(){Case c=caso();User fuera=usuario('p06fuera'),sin=usuario('p06sin');System.runAs(usuario('p06r')){
        rechazo(Database.update(new Case(Id=c.Id,OwnerId=fuera.Id),false,AccessLevel.USER_MODE));rechazo(Database.update(new Case(Id=c.Id,OwnerId=sin.Id),false,AccessLevel.USER_MODE));}
        System.assertEquals(P04Cola.idCola(),caso().OwnerId);}
    @IsTest static void agenteNoAsignaAOtroNiDevuelveCola(){Case c=caso();User b=usuario('p06b');System.runAs(usuario('p06a')){
        rechazo(Database.update(new Case(Id=c.Id,OwnerId=b.Id),false,AccessLevel.SYSTEM_MODE));tomar(c.Id);
        rechazo(Database.update(new Case(Id=c.Id,OwnerId=P04Cola.idCola()),false,AccessLevel.SYSTEM_MODE));}}
    @IsTest static void altasSoloNuevo(){Asset a=producto();System.runAs(usuario('p06a')){for(String s:new List<String>{'P04_EnCurso','P04_PendienteInformacion','P04_Cerrado'}){
        Case c=nuevo(a,'P06 estado inválido');c.Status=s;rechazo(Database.insert(c,false,AccessLevel.USER_MODE));}System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Subject='P06 estado inválido' WITH USER_MODE]);}}
    @IsTest static void transicionesYNoOp(){Case c=caso();System.runAs(usuario('p06a')){tomar(c.Id);
        for(String s:new List<String>{'P04_Nuevo','P04_EnCurso','P04_EnCurso','P04_PendienteInformacion','P04_PendienteInformacion','P04_EnCurso'}){update as user new Case(Id=c.Id,Status=s);estado(c.Id,s);}}}
    @IsTest static void saltosYRetrocesos(){Case c=caso();System.runAs(usuario('p06a')){tomar(c.Id);
        for(String s:new List<String>{'P04_PendienteInformacion','P04_Cerrado','New'})rechazo(Database.update(new Case(Id=c.Id,Status=s),false,AccessLevel.USER_MODE));estado(c.Id,'P04_Nuevo');
        update as user new Case(Id=c.Id,Status='P04_EnCurso');rechazo(Database.update(new Case(Id=c.Id,Status='P04_Nuevo'),false,AccessLevel.USER_MODE));
        update as user new Case(Id=c.Id,Status='P04_PendienteInformacion');rechazo(Database.update(new Case(Id=c.Id,Status='P04_Nuevo'),false,AccessLevel.USER_MODE));estado(c.Id,'P04_PendienteInformacion');}}
    @IsTest static void cierreDesdeEnCurso(){Case c=caso();System.runAs(usuario('p06a')){prepararCierre(c.Id);update as user cierre(c.Id);estado(c.Id,'P04_Cerrado');}}
    @IsTest static void cierreDesdePendiente(){Case c=caso();System.runAs(usuario('p06a')){prepararCierre(c.Id);update as user new Case(Id=c.Id,Status='P04_PendienteInformacion');update as user cierre(c.Id);estado(c.Id,'P04_Cerrado');}}
    @IsTest static void colaNoCierra(){Case c=caso();update as system new Case(Id=c.Id,Status='P04_EnCurso');rechazo(Database.update(cierre(c.Id),false,AccessLevel.SYSTEM_MODE));estado(c.Id,'P04_EnCurso');}
    @IsTest static void cierreSinEvaluar(){Case c=caso();System.runAs(usuario('p06a')){tomar(c.Id);update as user new Case(Id=c.Id,Status='P04_EnCurso');rechazo(Database.update(cierre(c.Id),false,AccessLevel.USER_MODE));estado(c.Id,'P04_EnCurso');}}
    @IsTest static void resolucionYExplicacionObligatorias(){Case c=caso();System.runAs(usuario('p06a')){prepararCierre(c.Id);Case patch=cierre(c.Id);patch.P04_TipoResolucion__c=null;rechazo(Database.update(patch,false,AccessLevel.USER_MODE));
        for(String text:new List<String>{null,'','   ','\t\n'}){patch=cierre(c.Id);patch.P04_ExplicacionResolucion__c=text;rechazo(Database.update(patch,false,AccessLevel.USER_MODE));}estado(c.Id,'P04_EnCurso');}}
    @IsTest static void pendienteDatosSoloSinActuacion(){Case c=caso();Asset a=producto();update as system new Asset(Id=a.Id,P04_FinGarantia__c=null);System.runAs(usuario('p06a')){prepararCierre(c.Id);
        for(String tipo:new List<String>{'Reparacion','Sustitucion','Fuera_cobertura'}){Case p=cierre(c.Id);p.P04_TipoResolucion__c=tipo;rechazo(Database.update(p,false,AccessLevel.USER_MODE));}
        Case p=cierre(c.Id);p.P04_TipoResolucion__c='Sin_actuacion';update as user p;estado(c.Id,'P04_Cerrado');}}
    @IsTest static void sinRestriccionesInventadas(){Case c=caso();Asset a=producto();update as system new Asset(Id=a.Id,P04_FinGarantia__c=Date.newInstance(2024,2,10));System.runAs(usuario('p06a')){
        prepararCierre(c.Id);System.assertEquals('Fuera_cobertura',[SELECT P04_ResultadoGarantia__c FROM Case WHERE Id=:c.Id WITH USER_MODE].P04_ResultadoGarantia__c);update as user cierre(c.Id);estado(c.Id,'P04_Cerrado');}}
    @IsTest static void cadaFechaDesactualizadaRechaza(){Case c=caso();Asset a=producto();User u=usuario('p06a');System.runAs(u){prepararCierre(c.Id);}
        for(String field:new List<String>{'PurchaseDate','P04_InicioGarantia__c','P04_FinGarantia__c'}){
            Asset p=new Asset(Id=a.Id);p.put(field,((Date)a.get(field)).addDays(-1));update as system p;
            System.runAs(u){rechazo(Database.update(cierre(c.Id),false,AccessLevel.USER_MODE));}
            p.put(field,a.get(field));update as system p;
        }
        System.runAs(u){update as user new Case(Id=c.Id,P04_FechaIncidencia__c=Date.newInstance(2024,2,21));rechazo(Database.update(cierre(c.Id),false,AccessLevel.USER_MODE));
            evaluar(c.Id);update as user cierre(c.Id);estado(c.Id,'P04_Cerrado');}}
    @IsTest static void ausenciaFechaTambienExigeReevaluar(){Case c=caso();Asset a=producto();User u=usuario('p06a');System.runAs(u){prepararCierre(c.Id);}update as system new Asset(Id=a.Id,PurchaseDate=null);
        System.runAs(u){rechazo(Database.update(cierre(c.Id),false,AccessLevel.USER_MODE));evaluar(c.Id);update as user cierre(c.Id);estado(c.Id,'P04_Cerrado');}}
    @IsTest static void cerradoInmutableYProductoNoRecalcula(){Case c=caso();User u=usuario('p06a');System.runAs(u){prepararCierre(c.Id);update as user cierre(c.Id);
        for(String s:new List<String>{'P04_Nuevo','P04_EnCurso','P04_PendienteInformacion'})rechazo(Database.update(new Case(Id=c.Id,Status=s),false,AccessLevel.USER_MODE));
        Map<String,Object> changes=new Map<String,Object>{'Subject'=>'Otro','Description'=>'Otra','Priority'=>'High','Origin'=>'Phone','P04_ExplicacionResolucion__c'=>'Otra','P04_TipoResolucion__c'=>'Sustitucion','P04_FechaIncidencia__c'=>Date.newInstance(2024,2,21)};
        for(String f:changes.keySet()){Case p=new Case(Id=c.Id);p.put(f,changes.get(f));rechazo(Database.update(p,false,AccessLevel.USER_MODE));}
        update as user new Case(Id=c.Id,Status='P04_Cerrado');System.assertEquals('CASO_CERRADO',P04Garantia.evaluar(new List<String>{c.Id})[0].codigo);
    }
        Case before=[SELECT P04_EvaluadaEl__c,P04_FinEvaluado__c,P04_ResultadoGarantia__c FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE];
        update as system new Asset(Id=producto().Id,P04_FinGarantia__c=Date.newInstance(2024,2,10));System.assertEquals(before,[SELECT P04_EvaluadaEl__c,P04_FinEvaluado__c,P04_ResultadoGarantia__c FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE]);}
    @IsTest static void propietarioRevocadoNoCierra(){Case c=caso();User u=usuario('p06a');System.runAs(u){prepararCierre(c.Id);}
        System.runAs(new User(Id=UserInfo.getUserId())){delete as system [SELECT Id FROM GroupMember WHERE GroupId=:P04Cola.idCola() AND UserOrGroupId=:u.Id WITH SYSTEM_MODE];}
        rechazo(Database.update(cierre(c.Id),false,AccessLevel.SYSTEM_MODE));estado(c.Id,'P04_EnCurso');}
    @IsTest static void propietarioInactivoNoCierra(){Case c=caso();User u=usuario('p06a');System.runAs(u){prepararCierre(c.Id);}
        System.runAs(new User(Id=UserInfo.getUserId())){update as system new User(Id=u.Id,IsActive=false);}rechazo(Database.update(cierre(c.Id),false,AccessLevel.SYSTEM_MODE));}
    @IsTest static void membresiaPorGrupoReal(){User u=usuario('p06fuera');Case c=caso();
        System.runAs(new User(Id=UserInfo.getUserId())){insert as system new GroupMember(GroupId=[SELECT Id FROM Group WHERE DeveloperName='P04_Agentes' AND Type='Regular' WITH SYSTEM_MODE].Id,UserOrGroupId=u.Id);}
        System.runAs(u){System.assert(P04Cola.habilitados(new Set<Id>{u.Id}).contains(u.Id));System.assertEquals(1,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);tomar(c.Id);}
        System.assertEquals(u.Id,caso().OwnerId);
    }
    @IsTest static void responsableRevocadoNoTomaNiEditaCola(){Case c=caso();User u=usuario('p06r');
        System.runAs(new User(Id=UserInfo.getUserId())){delete as system [SELECT Id FROM GroupMember WHERE GroupId=:P04Cola.idCola() AND UserOrGroupId=:u.Id WITH SYSTEM_MODE];}
        System.runAs(u){System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);rechazo(Database.update(new Case(Id=c.Id,OwnerId=u.Id),false,AccessLevel.SYSTEM_MODE));rechazo(Database.update(new Case(Id=c.Id,Subject='No'),false,AccessLevel.SYSTEM_MODE));}
    }
    @IsTest static void responsableNoAsignaInactivo(){Case c=caso();User u=usuario('p06b');System.runAs(new User(Id=UserInfo.getUserId())){update as system new User(Id=u.Id,IsActive=false);}
        System.runAs(usuario('p06r')){rechazo(Database.update(new Case(Id=c.Id,OwnerId=u.Id),false,AccessLevel.SYSTEM_MODE));}System.assertEquals(P04Cola.idCola(),caso().OwnerId);
    }
    @IsTest static void responsableAsignaDoscientos(){Asset a=producto();User target=usuario('p06b');List<Case> rows=new List<Case>();
        for(Integer i=0;i<200;i++){Case c=nuevo(a,'P06 asignación '+i);c.OwnerId=P04Cola.idCola();rows.add(c);}insert as system rows;
        Set<Id> ids=new Map<Id,Case>(rows).keySet();System.runAs(usuario('p06r')){List<Case> edits=new List<Case>();for(Case c:rows)edits.add(new Case(Id=c.Id,OwnerId=target.Id));Test.startTest();update as user edits;Test.stopTest();}
        System.assertEquals(200,[SELECT COUNT() FROM Case WHERE Id IN :ids AND OwnerId=:target.Id WITH SYSTEM_MODE]);
    }
    @IsTest static void loteDoscientosRecorrido(){Asset a=producto();System.runAs(usuario('p06a')){
        List<Case> rows=new List<Case>();for(Integer i=0;i<200;i++)rows.add(nuevo(a,'P06 lote '+i));
        Test.startTest();insert as user rows;Set<Id> ids=new Map<Id,Case>(rows).keySet();System.assertEquals(200,[SELECT COUNT() FROM Case WHERE Id IN :ids AND OwnerId=:P04Cola.idCola() WITH USER_MODE]);
        List<Case> patches=new List<Case>();List<String> requests=new List<String>();for(Case c:rows){patches.add(new Case(Id=c.Id,OwnerId=UserInfo.getUserId(),Status='P04_EnCurso'));requests.add(c.Id);}update as user patches;
        for(P04Garantia.Resultado r:P04Garantia.evaluar(requests))System.assert(r.correcto,r.codigo);
        patches.clear();for(Case c:rows)patches.add(cierre(c.Id));update as user patches;Test.stopTest();System.assertEquals(200,[SELECT COUNT() FROM Case WHERE Id IN :ids AND IsClosed=true AND OwnerId=:UserInfo.getUserId() WITH USER_MODE]);}}
}
