@IsTest
private class P04GarantiaTest {
    @TestSetup static void preparar(){
        Id profile=[SELECT Id FROM Profile WHERE Name='P04_Minimo' WITH SYSTEM_MODE].Id;
        List<User> users=new List<User>();
        for(String alias:new List<String>{'p05ag','p05otro','p05resp','p05sin'})users.add(new User(Alias=alias,LastName=alias,
            Email=alias+'@example.invalid',Username=alias+'.'+Crypto.getRandomLong()+'@example.invalid',ProfileId=profile,
            TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US'));
        User fixture=new User(Alias='p05fix',LastName='Fixture P05',Email='fixture@example.invalid',Username='p05fix.'+Crypto.getRandomLong()+'@example.invalid',
            ProfileId=UserInfo.getProfileId(),TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US');
        System.runAs(new User(Id=UserInfo.getUserId())){
            insert as system users;insert as system fixture;
            PermissionSet ps=new PermissionSet(Name='P05_Fixture',Label='Fixture P05');insert as system ps;
            insert as system new SetupEntityAccess(ParentId=ps.Id,SetupEntityId=[SELECT Id FROM CustomPermission WHERE DeveloperName='P04_Administrar' WITH SYSTEM_MODE].Id);
            insert as system new PermissionSetAssignment(AssigneeId=fixture.Id,PermissionSetId=ps.Id);
            Map<String,Id> sets=new Map<String,Id>();for(PermissionSet p:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('P04_Agente','P04_Responsable') WITH SYSTEM_MODE])sets.put(p.Name,p.Id);
            for(Integer i=0;i<3;i++)insert as system new PermissionSetAssignment(AssigneeId=users[i].Id,PermissionSetId=sets.get(i==2?'P04_Responsable':'P04_Agente'));
        }
        System.runAs(fixture){
            Account a=new Account(Name='P05 cliente',P04_Posventa__c=true);insert as system a;
            Contact c=new Contact(LastName='P05 contacto',AccountId=a.Id);insert as system c;
            Asset product=new Asset(Name='P05 producto',AccountId=a.Id,ContactId=c.Id,RecordTypeId=P04Integridad.PRODUCTO,
                PurchaseDate=Date.newInstance(2024,1,1),P04_InicioGarantia__c=Date.newInstance(2024,2,1),P04_FinGarantia__c=Date.newInstance(2024,3,1));insert as system product;
            List<Case> issues=new List<Case>();
            for(Integer i=0;i<4;i++)issues.add(nuevo(product,'P05 '+i,users[i].Id,Date.newInstance(2024,2,29)));
            issues.add(nuevo(product,'P05 lectura',fixture.Id,Date.newInstance(2024,2,29)));
            issues.add(new Case(Subject='P05 Master',AccountId=a.Id,Status='New',Origin='Web',OwnerId=users[2].Id));
            insert as system issues;
            System.assertEquals(null,[SELECT RecordTypeId FROM Case WHERE Id=:issues[5].Id WITH SYSTEM_MODE].RecordTypeId);
            List<AccountShare> ac=new List<AccountShare>();List<AssetShare> ast=new List<AssetShare>();
            for(Integer i=0;i<3;i++){
                ac.add(new AccountShare(AccountId=a.Id,UserOrGroupId=users[i].Id,AccountAccessLevel='Read',CaseAccessLevel='None',OpportunityAccessLevel='None'));
                ast.add(new AssetShare(AssetId=product.Id,UserOrGroupId=users[i].Id,AssetAccessLevel='Read'));
            }
            insert as system ac;insert as system ast;
            insert as system new List<CaseShare>{new CaseShare(CaseId=issues[0].Id,UserOrGroupId=users[2].Id,CaseAccessLevel='Edit'),
                new CaseShare(CaseId=issues[1].Id,UserOrGroupId=users[2].Id,CaseAccessLevel='Edit'),
                new CaseShare(CaseId=issues[4].Id,UserOrGroupId=users[2].Id,CaseAccessLevel='Read')};
        }
    }
    private static User user(String alias){return [SELECT Id FROM User WHERE Alias=:alias WITH SYSTEM_MODE];}
    private static Asset asset(){return [SELECT Id,AccountId,ContactId,RecordTypeId,PurchaseDate,P04_InicioGarantia__c,P04_FinGarantia__c FROM Asset WHERE Name='P05 producto' WITH SYSTEM_MODE];}
    private static Case caso(String name){return [SELECT Id,OwnerId,RecordTypeId,AccountId,ContactId,AssetId,P04_FechaIncidencia__c,Status,IsClosed FROM Case WHERE Subject=:name WITH SYSTEM_MODE];}
    private static Case nuevo(Asset a,String name,Id owner,Date day){return new Case(Subject=name,OwnerId=owner,RecordTypeId=P04Integridad.CASO,AccountId=a.AccountId,ContactId=a.ContactId,AssetId=a.Id,P04_FechaIncidencia__c=day,Status='P04_Nuevo',Origin='Web');}
    private static Case snapshot(Id id){return [SELECT Id,OwnerId,Subject,P04_ResultadoGarantia__c,P04_MotivoGarantia__c,P04_CompraEvaluada__c,P04_InicioEvaluado__c,P04_FinEvaluado__c,P04_IncidenciaEvaluada__c,P04_EvaluadaEl__c FROM Case WHERE Id=:id WITH SYSTEM_MODE];}
    private static P04Garantia.Resultado evaluar(Id id,String role){List<P04Garantia.Resultado> r;System.runAs(user(role)){r=P04Garantia.evaluar(new List<String>{String.valueOf(id)});}return r[0];}
    private static void ok(P04Garantia.Resultado r){System.assert(r.correcto,r.codigo+': '+r.mensaje);System.assertEquals('OK',r.codigo);}
    private static void no(P04Garantia.Resultado r,String code){System.assertEquals(false,r.correcto);System.assertEquals(code,r.codigo);System.assertEquals(null,r.cobertura);}
    private static void fecha(Date day,String coverage){Case c=caso('P05 0');update as system new Case(Id=c.Id,P04_FechaIncidencia__c=day);ok(evaluar(c.Id,'p05ag'));Case s=snapshot(c.Id);System.assertEquals(coverage,s.P04_ResultadoGarantia__c);System.assertEquals(day,s.P04_IncidenciaEvaluada__c);System.assertNotEquals(null,s.P04_EvaluadaEl__c);}

    @IsTest static void dentroYFebreroBisiesto(){fecha(Date.newInstance(2024,2,29),'En_cobertura');}
    @IsTest static void limiteInicial(){fecha(Date.newInstance(2024,2,1),'En_cobertura');}
    @IsTest static void limiteFinal(){fecha(Date.newInstance(2024,3,1),'En_cobertura');}
    @IsTest static void diaAnterior(){fecha(Date.newInstance(2024,1,31),'Fuera_cobertura');System.assert(snapshot(caso('P05 0').Id).P04_MotivoGarantia__c.contains('anterior'));}
    @IsTest static void diaPosterior(){fecha(Date.newInstance(2024,3,2),'Fuera_cobertura');System.assert(snapshot(caso('P05 0').Id).P04_MotivoGarantia__c.contains('posterior'));}
    @IsTest static void intervaloUnDia(){Asset a=asset();update as system new Asset(Id=a.Id,P04_InicioGarantia__c=Date.newInstance(2024,2,29),P04_FinGarantia__c=Date.newInstance(2024,2,29));fecha(Date.newInstance(2024,2,29),'En_cobertura');}
    private static void incompleta(Boolean inicio,Boolean fin,String reason){Asset a=asset();update as system new Asset(Id=a.Id,P04_InicioGarantia__c=inicio?null:a.P04_InicioGarantia__c,P04_FinGarantia__c=fin?null:a.P04_FinGarantia__c);Case c=caso('P05 0');System.assertEquals(null,snapshot(c.Id).P04_ResultadoGarantia__c);ok(evaluar(c.Id,'p05ag'));Case s=snapshot(c.Id);System.assertEquals('Pendiente_datos',s.P04_ResultadoGarantia__c);System.assertEquals(reason,s.P04_MotivoGarantia__c);System.assertEquals(inicio?null:a.P04_InicioGarantia__c,s.P04_InicioEvaluado__c);System.assertEquals(fin?null:a.P04_FinGarantia__c,s.P04_FinEvaluado__c);}
    @IsTest static void faltaInicio(){incompleta(true,false,'Falta el inicio de garantía.');}
    @IsTest static void faltaFin(){incompleta(false,true,'Falta el fin de garantía.');}
    @IsTest static void faltanAmbas(){incompleta(true,true,'Faltan inicio y fin de garantía.');}
    @IsTest static void compraOpcional(){Asset a=asset();update as system new Asset(Id=a.Id,PurchaseDate=null);fecha(Date.newInstance(2024,2,29),'En_cobertura');System.assertEquals(null,snapshot(caso('P05 0').Id).P04_CompraEvaluada__c);}
    @IsTest static void instantaneaCompleta(){Case c=caso('P05 0');Asset a=asset();ok(evaluar(c.Id,'p05ag'));Case s=snapshot(c.Id);System.assertEquals(a.PurchaseDate,s.P04_CompraEvaluada__c);System.assertEquals(a.P04_InicioGarantia__c,s.P04_InicioEvaluado__c);System.assertEquals(a.P04_FinGarantia__c,s.P04_FinEvaluado__c);System.assertEquals(c.OwnerId,s.OwnerId);System.assertEquals('P05 0',s.Subject);}
    @IsTest static void productoNoRecalculaYReevaluacion(){Case c=caso('P05 0');ok(evaluar(c.Id,'p05ag'));Case before=snapshot(c.Id);update as system new Asset(Id=c.AssetId,P04_FinGarantia__c=Date.newInstance(2024,2,20));System.assertEquals(before,snapshot(c.Id));ok(evaluar(c.Id,'p05ag'));Case after=snapshot(c.Id);System.assertEquals('Fuera_cobertura',after.P04_ResultadoGarantia__c);System.assertEquals(Date.newInstance(2024,2,20),after.P04_FinEvaluado__c);System.assert(after.P04_EvaluadaEl__c>=before.P04_EvaluadaEl__c);}
    @IsTest static void incidenciaNoRecalcula(){Case c=caso('P05 0');ok(evaluar(c.Id,'p05ag'));Case before=snapshot(c.Id);System.runAs(user('p05ag')){update as user new Case(Id=c.Id,P04_FechaIncidencia__c=Date.newInstance(2024,3,2));}System.assertEquals(before,snapshot(c.Id));ok(evaluar(c.Id,'p05ag'));System.assertEquals(Date.newInstance(2024,3,2),snapshot(c.Id).P04_IncidenciaEvaluada__c);}
    @IsTest static void cerradoConserva(){Case c=caso('P05 0');ok(evaluar(c.Id,'p05ag'));Case before=snapshot(c.Id);update as system new Case(Id=c.Id,Status='P04_Cerrado');no(evaluar(c.Id,'p05ag'),'CASO_CERRADO');System.assertEquals(before,snapshot(c.Id));}
    @IsTest static void cerradoSinEvaluar(){Case c=caso('P05 0');update as system new Case(Id=c.Id,Status='P04_Cerrado');no(evaluar(c.Id,'p05ag'),'CASO_CERRADO');System.assertEquals(null,snapshot(c.Id).P04_EvaluadaEl__c);}
    @IsTest static void responsableEquipo(){Case c=caso('P05 1');ok(evaluar(c.Id,'p05resp'));System.assertEquals('En_cobertura',snapshot(c.Id).P04_ResultadoGarantia__c);}
    @IsTest static void responsableSoloLectura(){Case c=caso('P05 lectura');no(evaluar(c.Id,'p05resp'),'NO_AUTORIZADO');System.assertEquals(null,snapshot(c.Id).P04_EvaluadaEl__c);}
    @IsTest static void ajenoYSinPermisosYMaster(){no(evaluar(caso('P05 1').Id,'p05ag'),'NO_AUTORIZADO');no(evaluar(caso('P05 3').Id,'p05sin'),'NO_AUTORIZADO');no(evaluar(caso('P05 Master').Id,'p05resp'),'NO_AUTORIZADO');}
    @IsTest static void escrituraDirectaSigueBloqueada(){Case c=caso('P05 0');for(String role:new List<String>{'p05ag','p05resp'}){
        ok(evaluar(c.Id,role));Case before=snapshot(c.Id);
        System.runAs(user(role)){
            System.assertEquals(false,P04Garantia.escrituraLegitima(new Case(Id=c.Id),c));
            System.assertEquals(false,Database.update(new Case(Id=c.Id,P04_ResultadoGarantia__c='Fuera_cobertura'),false,AccessLevel.USER_MODE).isSuccess());
            System.assertEquals(false,Database.update(new Case(Id=c.Id,P04_ResultadoGarantia__c='Fuera_cobertura'),false,AccessLevel.SYSTEM_MODE).isSuccess());
            System.assertEquals(false,Database.update(new Case(Id=c.Id,P04_EvaluadaEl__c=System.now().addDays(-1)),false,AccessLevel.SYSTEM_MODE).isSuccess());
        }System.assertEquals(before,snapshot(c.Id));
    }}
    @IsTest static void loteMixtoAtomico(){Case valid=caso('P05 0'),closed=caso('P05 1');ok(evaluar(valid.Id,'p05ag'));Case before=snapshot(valid.Id);update as system new Case(Id=closed.Id,Status='P04_Cerrado');update as system new Asset(Id=valid.AssetId,P04_FinGarantia__c=Date.newInstance(2024,2,20));
        System.runAs(user('p05resp')){List<P04Garantia.Resultado> r=P04Garantia.evaluar(new List<String>{valid.Id,closed.Id});no(r[0],'LOTE_RECHAZADO');no(r[1],'CASO_CERRADO');}System.assertEquals(before,snapshot(valid.Id));}
    @IsTest static void entradasYDuplicadosInvocable(){Case c=caso('P05 0');System.runAs(user('p05ag')){
        System.assertEquals(0,P04Garantia.evaluar(null).size());System.assertEquals(0,P04Garantia.evaluar(new List<String>()).size());
        List<P04Garantia.Resultado> invalid=P04Garantia.evaluar(new List<String>{c.Id,null,'','no-es-id',String.valueOf(c.AssetId)});System.assertEquals(5,invalid.size());no(invalid[0],'LOTE_RECHAZADO');for(Integer i=1;i<5;i++)no(invalid[i],'ENTRADA_INVALIDA');
        P04EvaluarGarantiaAccion.Solicitud s=new P04EvaluarGarantiaAccion.Solicitud();s.casoId=String.valueOf(c.Id);
        List<P04Garantia.Resultado> r=P04EvaluarGarantiaAccion.ejecutar(new List<P04EvaluarGarantiaAccion.Solicitud>{s,s});System.assertEquals(2,r.size());ok(r[0]);ok(r[1]);System.assertEquals(r[0].cobertura,r[1].cobertura);
        r=P04EvaluarGarantiaAccion.ejecutar(new List<P04EvaluarGarantiaAccion.Solicitud>{s,null});no(r[0],'LOTE_RECHAZADO');no(r[1],'ENTRADA_INVALIDA');
    }System.assertEquals('En_cobertura',snapshot(c.Id).P04_ResultadoGarantia__c);}
    @IsTest static void inexistenteSinFiltracion(){Case c=nuevo(asset(),'P05 eliminado',user('p05ag').Id,Date.newInstance(2024,2,29));insert as system c;delete as system c;P04Garantia.Resultado missing=evaluar(c.Id,'p05ag'),hidden=evaluar(caso('P05 1').Id,'p05ag');no(missing,'NO_AUTORIZADO');System.assertEquals(hidden.mensaje,missing.mensaje);}
    @IsTest static void doscientosSinConsultasPorRegistro(){Asset a=asset();User u=user('p05ag');List<Case> rows=new List<Case>();for(Integer i=0;i<200;i++)rows.add(nuevo(a,'P05 lote '+i,u.Id,Date.newInstance(2024,2,29)));insert as system rows;List<String> ids=new List<String>();for(Case c:rows)ids.add(c.Id);
        System.runAs(u){Test.startTest();Integer q=Limits.getQueries(),d=Limits.getDmlStatements();List<P04Garantia.Resultado> r=P04Garantia.evaluar(ids);System.assert(Limits.getQueries()-q<=8,'Sin consultas por registro');System.assertEquals(1,Limits.getDmlStatements()-d);Test.stopTest();System.assertEquals(200,r.size());for(P04Garantia.Resultado item:r)ok(item);System.assertEquals(200,[SELECT COUNT() FROM Case WHERE Id IN :ids AND P04_ResultadoGarantia__c='En_cobertura' AND P04_EvaluadaEl__c!=null WITH USER_MODE]);}
    }
    @IsTest static void limiteSinEscritura(){Case c=caso('P05 0');List<String> ids=new List<String>();for(Integer i=0;i<201;i++)ids.add(c.Id);System.runAs(user('p05ag')){List<P04Garantia.Resultado> r=P04Garantia.evaluar(ids);System.assertEquals(201,r.size());for(P04Garantia.Resultado item:r)no(item,'LIMITE_LOTE');}System.assertEquals(null,snapshot(c.Id).P04_EvaluadaEl__c);}
    @IsTest static void datosInvalidosDefensaPura(){
        // Las validaciones impiden persistir estos estados: se comprueba la validación defensiva sin desactivarlas.
        Case c=caso('P05 0');Asset a=asset();Account account=new Account(Id=c.AccountId,P04_Posventa__c=true);Contact contact=new Contact(Id=c.ContactId,AccountId=c.AccountId);
        System.assertEquals(null,P04Garantia.errorDatos(c,a,account,contact,contact));
        c.P04_FechaIncidencia__c=Date.today().addDays(1);System.assert(P04Garantia.errorDatos(c,a,account,contact,contact).contains('futura'));
        c.P04_FechaIncidencia__c=Date.newInstance(2023,12,31);System.assert(P04Garantia.errorDatos(c,a,account,contact,contact).contains('compra'));
        c.P04_FechaIncidencia__c=Date.newInstance(2024,2,29);a.P04_FinGarantia__c=Date.newInstance(2024,1,1);System.assert(P04Garantia.errorDatos(c,a,account,contact,contact).contains('invertido'));
        a.P04_FinGarantia__c=Date.newInstance(2024,3,1);contact.AccountId=null;System.assert(P04Garantia.errorDatos(c,a,account,contact,contact).contains('incoherentes'));
        contact.AccountId=c.AccountId;account.P04_Posventa__c=false;System.assertNotEquals(null,P04Garantia.errorDatos(c,a,account,contact,contact));
        account.P04_Posventa__c=true;c.P04_FechaIncidencia__c=null;System.assertNotEquals(null,P04Garantia.errorDatos(c,a,account,contact,contact));
    }
}
