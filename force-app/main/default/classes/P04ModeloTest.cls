// Pruebas de integridad en modo sistema; no acreditan CRUD/FLS de roles.
@IsTest
private class P04ModeloTest {
    @TestSetup static void preparar() {
        List<Account> clientes = new List<Account>{new Account(Name='P04 TEST A'), new Account(Name='P04 TEST B')};
        insert as system clientes;
        insert as system new List<Contact>{new Contact(LastName='P04 TEST A', AccountId=clientes[0].Id), new Contact(LastName='P04 TEST B', AccountId=clientes[1].Id)};
        List<Contact> personas = [SELECT Id, AccountId, LastName FROM Contact WITH SYSTEM_MODE ORDER BY LastName];
        List<Asset> productos = new List<Asset>();
        for (Contact persona : personas) {
            productos.add(new Asset(Name=persona.LastName, RecordTypeId=P04Integridad.PRODUCTO,
                AccountId=persona.AccountId, ContactId=persona.Id, PurchaseDate=Date.today().addDays(-30),
                P04_InicioGarantia__c=Date.today().addDays(-30), P04_FinGarantia__c=Date.today().addDays(300)));
        }
        insert as system productos;
    }
    private static Asset producto(String letra) {
        String nombre='P04 TEST '+letra;
        return [SELECT Id, Name, RecordTypeId, AccountId, ContactId, PurchaseDate, P04_InicioGarantia__c, P04_FinGarantia__c FROM Asset WHERE Name=:nombre WITH SYSTEM_MODE LIMIT 1];
    }
    private static Case caso(Asset a) {
        return new Case(RecordTypeId=P04Integridad.CASO, AccountId=a.AccountId, ContactId=a.ContactId,
            AssetId=a.Id, Subject='P04 prueba ficticia', Origin='Web', Status='P04_Nuevo',
            P04_FechaIncidencia__c=Date.today().addDays(-1));
    }
    private static Id masterType(Schema.SObjectType objectType) {
        for (Schema.RecordTypeInfo info : objectType.getDescribe().getRecordTypeInfos()) {
            if (info.isMaster()) return info.getRecordTypeId();
        }
        System.assert(false, 'Debe existir el tipo master de la plataforma.');
        return null;
    }
    private static void rechazo(Database.SaveResult r, String pista) {
        System.assertEquals(false, r.isSuccess(), 'Debía rechazar '+pista);
        System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, r.getErrors()[0].getStatusCode());
        System.assert(r.getErrors()[0].getMessage().contains(pista), r.getErrors()[0].getMessage());
    }
    private static User administradorFixtureMaster(){
        User u=new User(Alias='p04mfix',LastName='P04 fixture Master',Email='p04.fixture@example.invalid',
            Username='p04.master.'+String.valueOf(Crypto.getRandomLong())+'@example.invalid',ProfileId=UserInfo.getProfileId(),
            TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',LanguageLocaleKey='en_US',EmailEncodingKey='UTF-8');
        System.runAs(new User(Id=UserInfo.getUserId())){
            insert as system u;
            PermissionSet ps=new PermissionSet(Name='P04_FixtureModelo',Label='P04 fixture de test');insert as system ps;
            Id permission=[SELECT Id FROM CustomPermission WHERE DeveloperName='P04_Administrar' WITH SYSTEM_MODE].Id;
            insert as system new SetupEntityAccess(ParentId=ps.Id,SetupEntityId=permission);
            insert as system new PermissionSetAssignment(AssigneeId=u.Id,PermissionSetId=ps.Id);
        }
        return u;
    }
    @IsTest static void recorridoValidoSinEvaluacion() {
        Case c=caso(producto('A')); insert as system c;
        c=[SELECT Status, IsClosed, P04_ResultadoGarantia__c, P04_EvaluadaEl__c, P04_MotivoGarantia__c FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE];
        System.assertEquals('P04_Nuevo', c.Status); System.assertEquals(false,c.IsClosed);
        System.assertEquals(null,c.P04_ResultadoGarantia__c); System.assertEquals(null,c.P04_EvaluadaEl__c);
        System.assertEquals(null,c.P04_MotivoGarantia__c);
    }
    @IsTest static void obligatoriosCasoYProducto() {
        Asset a=producto('A');
        for (String campo : new List<String>{'AccountId','ContactId','AssetId','P04_FechaIncidencia__c','Subject'}) {
            Case c=caso(a); c.put(campo,null); rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'P04:');
        }
        Asset sinCliente=new Asset(Name='Sin cliente',RecordTypeId=P04Integridad.PRODUCTO,ContactId=a.ContactId);
        rechazo(Database.insert(sinCliente, false, AccessLevel.SYSTEM_MODE),'P04:');
    }
    @IsTest static void contactoAjenoEnProducto() {
        Asset a=producto('A'), b=producto('B'); a.ContactId=b.ContactId;
        rechazo(Database.update(a, false, AccessLevel.SYSTEM_MODE),'contacto del producto');
        Contact sinCliente=new Contact(LastName='Sin cliente'); insert as system sinCliente;
        a.ContactId=sinCliente.Id; rechazo(Database.update(a, false, AccessLevel.SYSTEM_MODE),'contacto del producto');
    }
    @IsTest static void relacionesAjenasEnCaso() {
        Asset a=producto('A'), b=producto('B');
        Case c=caso(a); c.ContactId=b.ContactId; rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'contacto del caso');
        c=caso(a); c.AssetId=b.Id; rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'producto debe');
        Asset ajeno=new Asset(Name='Ajeno',AccountId=a.AccountId);
        User fixtureAdmin=administradorFixtureMaster();System.runAs(fixtureAdmin){insert as system ajeno;}
        System.assertEquals(null,[SELECT RecordTypeId FROM Asset WHERE Id=:ajeno.Id WITH SYSTEM_MODE].RecordTypeId);
        c=caso(a); c.AssetId=ajeno.Id; rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'producto debe');
    }
    @IsTest static void intervaloInvalidoYLimiteIgual() {
        Asset a=producto('A'); a.P04_FinGarantia__c=a.P04_InicioGarantia__c.addDays(-1);
        rechazo(Database.update(a, false, AccessLevel.SYSTEM_MODE),'fin de garantía');
        a.P04_FinGarantia__c=a.P04_InicioGarantia__c; update as system a;
        System.assertEquals(a.P04_InicioGarantia__c,[SELECT P04_FinGarantia__c FROM Asset WHERE Id=:a.Id WITH SYSTEM_MODE].P04_FinGarantia__c);
    }
    @IsTest static void fechasIncompletasYContactoOpcional() {
        Asset a=producto('A'); a.ContactId=null; a.PurchaseDate=null;
        a.P04_InicioGarantia__c=null; update as system a;
        a.P04_InicioGarantia__c=Date.today(); a.P04_FinGarantia__c=null; update as system a;
        a.P04_InicioGarantia__c=null; update as system a;
        Contact persona=[SELECT Id FROM Contact WHERE AccountId=:a.AccountId WITH SYSTEM_MODE LIMIT 1];
        Case c=caso(a); c.ContactId=persona.Id; c.P04_FechaIncidencia__c=Date.today().addYears(-2); insert as system c;
        System.assertEquals(null,[SELECT P04_ResultadoGarantia__c FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].P04_ResultadoGarantia__c);
    }
    @IsTest static void incidenciaFuturaYDiaActual() {
        Case c=caso(producto('A')); c.P04_FechaIncidencia__c=Date.today().addDays(1);
        rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'incidencia no puede ser futura');
        c.P04_FechaIncidencia__c=Date.today(); insert as system c; System.assertNotEquals(null,c.Id);
    }
    @IsTest static void incidenciaAnteriorYDiaDeCompra() {
        Asset a=producto('A'); Case c=caso(a); c.P04_FechaIncidencia__c=a.PurchaseDate.addDays(-1);
        rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'incidencia no puede ser anterior');
        c.P04_FechaIncidencia__c=a.PurchaseDate; insert as system c; System.assertNotEquals(null,c.Id);
    }
    @IsTest static void edicionValidaEInvalida() {
        Case c=caso(producto('A')); insert as system c;
        c.Subject='P04 editado'; update as system c;
        c.P04_FechaIncidencia__c=Date.today().addDays(1); rechazo(Database.update(c, false, AccessLevel.SYSTEM_MODE),'incidencia no puede ser futura');
        Case guardado=[SELECT Subject, P04_FechaIncidencia__c FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE];
        System.assertEquals('P04 editado',guardado.Subject);
        System.assertEquals(Date.today().addDays(-1),guardado.P04_FechaIncidencia__c);
    }
    @IsTest static void estadosYTipoInmutables() {
        Case c=caso(producto('A')); c.Status='New'; rechazo(Database.insert(c, false, AccessLevel.SYSTEM_MODE),'cuatro estados');
        c.Status='P04_Nuevo'; insert as system c;
        for(String estado:new List<String>{'P04_EnCurso','P04_PendienteInformacion','P04_Cerrado'}) {c.Status=estado; update as system c;}
        System.assertEquals(true,[SELECT IsClosed FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].IsClosed);
        Case anterior=[SELECT Id, RecordTypeId FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE];
        c.RecordTypeId=masterType(Case.SObjectType);
        Database.SaveResult rc=Database.update(c,false,AccessLevel.SYSTEM_MODE);
        System.assertEquals(false,rc.isSuccess(),'La plataforma no debe permitir el cambio a Master.');
        System.assertEquals(P04Integridad.CASO,[SELECT RecordTypeId FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].RecordTypeId);
        // Master puede ser rechazado antes del trigger por la plataforma. Comprobar también el guardián.
        Case intento=new Case(Id=c.Id,RecordTypeId=null);
        P04Integridad.actualizarCasos(new List<Case>{intento},new Map<Id,Case>{c.Id=>anterior});
        System.assert(intento.hasErrors());System.assert(intento.getErrors()[0].getMessage().contains('retirar un caso'));
        Asset a=producto('A');Asset antes=a.clone(true,false,false,false);
        a.RecordTypeId=masterType(Asset.SObjectType);
        Database.SaveResult ra=Database.update(a,false,AccessLevel.SYSTEM_MODE);
        System.assertEquals(false,ra.isSuccess());
        System.assertEquals(P04Integridad.PRODUCTO,[SELECT RecordTypeId FROM Asset WHERE Id=:a.Id WITH SYSTEM_MODE].RecordTypeId);
        Asset intentoProducto=antes.clone(true,false,false,false);intentoProducto.RecordTypeId=null;
        P04Integridad.actualizarProductos(new List<Asset>{intentoProducto},new Map<Id,Asset>{a.Id=>antes});
        System.assert(intentoProducto.hasErrors());System.assert(intentoProducto.getErrors()[0].getMessage().contains('retirar un producto'));
    }
    @IsTest static void cambioClienteContactoConProducto() {
        Asset a=producto('A'), b=producto('B');
        Contact persona=new Contact(Id=a.ContactId,AccountId=b.AccountId);
        rechazo(Database.update(persona, false, AccessLevel.SYSTEM_MODE),'contacto utilizado');
        persona.AccountId=a.AccountId; persona.LastName='P04 contacto editado'; update as system persona;
        System.assertEquals('P04 contacto editado',[SELECT LastName FROM Contact WHERE Id=:persona.Id WITH SYSTEM_MODE].LastName);
    }
    @IsTest static void cambioClienteContactoSoloCaso() {
        Asset a=producto('A'), b=producto('B'); Contact extra=new Contact(LastName='P04 extra',AccountId=a.AccountId); insert as system extra;
        Case c=caso(a); c.ContactId=extra.Id; insert as system c;
        extra.AccountId=b.AccountId; rechazo(Database.update(extra, false, AccessLevel.SYSTEM_MODE),'contacto utilizado');
    }
    @IsTest static void cambioClienteYCompraConCasos() {
        Asset a=producto('A'), b=producto('B'); Case c=caso(a); insert as system c;
        a.AccountId=b.AccountId; a.ContactId=b.ContactId; rechazo(Database.update(a, false, AccessLevel.SYSTEM_MODE),'producto con casos');
        a.AccountId=c.AccountId; a.ContactId=c.ContactId; a.PurchaseDate=Date.today();
        rechazo(Database.update(a, false, AccessLevel.SYSTEM_MODE),'compra no puede ser posterior');
        a.PurchaseDate=c.P04_FechaIncidencia__c; update as system a;
        a.PurchaseDate=null; update as system a;
        System.assertEquals(null,[SELECT PurchaseDate FROM Asset WHERE Id=:a.Id WITH SYSTEM_MODE].PurchaseDate);
    }
    @IsTest static void cambioPadreValidoSinReevaluacion() {
        Asset a=producto('A'); Case c=caso(a); insert as system c;
        a.P04_InicioGarantia__c=Date.today().addDays(2); a.P04_FinGarantia__c=Date.today().addDays(50); update as system a;
        Case guardado=[SELECT P04_ResultadoGarantia__c,P04_EvaluadaEl__c,P04_InicioEvaluado__c FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE];
        System.assertEquals(null,guardado.P04_ResultadoGarantia__c); System.assertEquals(null,guardado.P04_EvaluadaEl__c);
        System.assertEquals(null,guardado.P04_InicioEvaluado__c);
    }
    @IsTest static void borradosProtegidosYLimpiezaPropia() {
        Asset a=producto('A'); Case c=caso(a); insert as system c;
        for(SObject padre:new List<SObject>{new Account(Id=a.AccountId),new Contact(Id=a.ContactId),new Asset(Id=a.Id)}) {
            Database.DeleteResult r=Database.delete(padre, false, AccessLevel.SYSTEM_MODE); System.assertEquals(false,r.isSuccess());
            System.assert(r.getErrors()[0].getMessage().contains('P04:'),r.getErrors()[0].getMessage());
        }
        delete as system c; delete as system a; delete as system new Contact(Id=a.ContactId); delete as system new Account(Id=a.AccountId);
        System.assertEquals(0,[SELECT COUNT() FROM Account WHERE Id=:a.AccountId WITH SYSTEM_MODE]);
    }
    @IsTest static void registrosFueraDeAmbitoConservados() {
        User fixtureAdmin=administradorFixtureMaster();System.runAs(fixtureAdmin){
        Account cliente=new Account(Name='Ajeno creado solo en test'); insert as system cliente;
        Contact persona=new Contact(LastName='Ajeno',AccountId=cliente.Id); insert as system persona;
        persona.AccountId=producto('B').AccountId; update as system persona;
        Asset a=new Asset(Name='Ajeno',AccountId=cliente.Id,P04_InicioGarantia__c=Date.today(),P04_FinGarantia__c=Date.today().addDays(-1)); insert as system a;
        System.assertEquals(null,[SELECT RecordTypeId FROM Asset WHERE Id=:a.Id WITH SYSTEM_MODE].RecordTypeId);
        a.Name='Ajeno editado'; update as system a;
        Case c=new Case(Subject='Ajeno',Status='New',Origin='Web',P04_FechaIncidencia__c=Date.today().addDays(10)); insert as system c;
        c.Subject='Ajeno editado'; update as system c;
        delete as system c; delete as system a; delete as system persona; delete as system cliente;
        }
    }
    @IsTest static void lote200CasosValidos() {
        Asset a=producto('A'); List<Case> casos=new List<Case>();
        for(Integer i=0;i<200;i++)casos.add(caso(a));
        Test.startTest(); insert as system casos;
        for(Case c:casos)c.Subject='P04 lote editado'; update as system casos; Test.stopTest();
        System.assertEquals(200,[SELECT COUNT() FROM Case WHERE AssetId=:a.Id WITH SYSTEM_MODE]);
    }
    @IsTest static void lote200MixtoConExitoParcial() {
        Asset a=producto('A'),b=producto('B'); List<Case> casos=new List<Case>();
        for(Integer i=0;i<200;i++){Case c=caso(a);if(Math.mod(i,2)==1)c.ContactId=b.ContactId;casos.add(c);}
        Test.startTest(); List<Database.SaveResult> resultados=Database.insert(casos, false, AccessLevel.SYSTEM_MODE); Test.stopTest();
        Integer bien=0,mal=0;
        for(Integer i=0;i<200;i++){if(Math.mod(i,2)==0){System.assert(resultados[i].isSuccess());bien++;}else{rechazo(resultados[i],'contacto del caso');mal++;}}
        System.assertEquals(100,bien);System.assertEquals(100,mal);
        System.assertEquals(100,[SELECT COUNT() FROM Case WHERE AssetId=:a.Id WITH SYSTEM_MODE]);
    }
    @IsTest static void lote200PadresProtegidos() {
        Asset a=producto('A'),b=producto('B');List<Contact> personas=new List<Contact>();
        for(Integer i=0;i<200;i++)personas.add(new Contact(LastName='P04 lote '+i,AccountId=a.AccountId)); insert as system personas;
        List<Asset> productos=new List<Asset>();
        for(Contact p:personas)productos.add(new Asset(Name='P04 lote',RecordTypeId=P04Integridad.PRODUCTO,AccountId=a.AccountId,ContactId=p.Id,PurchaseDate=Date.today().addDays(-10)));
        insert as system productos; List<Case> casos=new List<Case>();for(Asset p:productos)casos.add(caso(p));insert as system casos;
        for(Contact p:personas)p.AccountId=b.AccountId;
        for(Asset p:productos)p.PurchaseDate=Date.today();
        Test.startTest();List<Database.SaveResult> rc=Database.update(personas, false, AccessLevel.SYSTEM_MODE);List<Database.SaveResult> ra=Database.update(productos, false, AccessLevel.SYSTEM_MODE);Test.stopTest();
        System.assertEquals(200,rc.size());System.assertEquals(200,ra.size());
        for(Database.SaveResult r:rc)rechazo(r,'contacto utilizado');for(Database.SaveResult r:ra)rechazo(r,'compra no puede ser posterior');
    }
    @IsTest static void productoSinCasosPuedeCambiarDeCliente() {
        Asset a=producto('A'),b=producto('B');a.AccountId=b.AccountId;a.ContactId=b.ContactId;update as system a;
        System.assertEquals(b.AccountId,[SELECT AccountId FROM Asset WHERE Id=:a.Id WITH SYSTEM_MODE].AccountId);
    }
}
