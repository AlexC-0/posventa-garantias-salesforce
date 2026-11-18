/** Fixtures SYSTEM_MODE; acciones restringidas USER_MODE. Sin SeeAllData ni usuarios persistentes. */
@IsTest
private class P04SeguridadTest {
    @TestSetup static void preparar() {
        Id profileId=[SELECT Id FROM Profile WHERE Name='P04_Minimo' WITH SYSTEM_MODE].Id;
        User admin=new User(Id=UserInfo.getUserId());
        List<User> users=new List<User>();
        for(String alias:new List<String>{'p04sa','p04sb','p04sr','p04sn'})users.add(new User(
            Alias=alias,LastName='P04 seguridad '+alias,Email=alias+'@example.invalid',
            Username=alias+'.'+UserInfo.getOrganizationId()+'.'+String.valueOf(Crypto.getRandomLong())+'@example.invalid',
            ProfileId=profileId,TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',
            EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US'));
        // Administrador de fixtures sin P04_DemoAdmin: no hereda su tipo de registro de inserción.
        User fixtureAdmin=new User(Alias='p04sfix',LastName='P04 fixture admin',Email='p04.fixture@example.invalid',
            Username='p04.fixture.'+String.valueOf(Crypto.getRandomLong())+'@example.invalid',ProfileId=UserInfo.getProfileId(),
            TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US');
        System.runAs(admin){
            insert as system users;
            insert as system fixtureAdmin;
            PermissionSet fixturePermission=new PermissionSet(Name='P04_FixtureSeguridad',Label='P04 fixture de test');insert as system fixturePermission;
            Id customPermission=[SELECT Id FROM CustomPermission WHERE DeveloperName='P04_Administrar' WITH SYSTEM_MODE].Id;
            insert as system new SetupEntityAccess(ParentId=fixturePermission.Id,SetupEntityId=customPermission);
            insert as system new PermissionSetAssignment(AssigneeId=fixtureAdmin.Id,PermissionSetId=fixturePermission.Id);
            Map<String,Id> ps=new Map<String,Id>();
            for(PermissionSet p:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('P04_Agente','P04_Responsable') WITH SYSTEM_MODE])ps.put(p.Name,p.Id);
            insert as system new List<PermissionSetAssignment>{
                new PermissionSetAssignment(AssigneeId=users[0].Id,PermissionSetId=ps.get('P04_Agente')),
                new PermissionSetAssignment(AssigneeId=users[1].Id,PermissionSetId=ps.get('P04_Agente')),
                new PermissionSetAssignment(AssigneeId=users[2].Id,PermissionSetId=ps.get('P04_Responsable'))
            };
        }
        System.runAs(admin){List<GroupMember> ms=new List<GroupMember>();for(Integer i=0;i<3;i++)ms.add(new GroupMember(GroupId=P04Cola.idCola(),UserOrGroupId=users[i].Id));insert as system ms;}
        System.runAs(fixtureAdmin){
            List<Account> accounts=new List<Account>{
                new Account(Name='P04 SEG A',P04_Posventa__c=true),new Account(Name='P04 SEG B',P04_Posventa__c=true),
                new Account(Name='P04 SEG externo',P04_Posventa__c=false)};
            insert as system accounts;
            List<Contact> contacts=new List<Contact>();
            for(Account a:accounts)contacts.add(new Contact(LastName=a.Name,AccountId=a.Id));
            insert as system contacts;
            List<Asset> assets=new List<Asset>();
            for(Integer i=0;i<3;i++){
                Asset asset=new Asset(Name=accounts[i].Name,AccountId=accounts[i].Id,ContactId=contacts[i].Id,
                    PurchaseDate=Date.today().addDays(-30),P04_InicioGarantia__c=Date.today().addDays(-30),P04_FinGarantia__c=Date.today().addDays(300));
                if(i<2)asset.RecordTypeId=P04Integridad.PRODUCTO;assets.add(asset);
            }
            insert as system assets;
            System.assertEquals(null,[SELECT RecordTypeId FROM Asset WHERE Id=:assets[2].Id WITH SYSTEM_MODE].RecordTypeId,'Fixture externo debe ser Master');
            List<Case> cases=new List<Case>{
                nuevo(assets[0],'P04 SEG propio',users[0].Id),nuevo(assets[0],'P04 SEG otro',users[1].Id),
                nuevo(assets[1],'P04 SEG no compartido',admin.Id),nuevo(assets[0],'P04 SEG sin permisos',users[3].Id),
                new Case(Subject='P04 SEG externo',AccountId=accounts[2].Id,Status='New',Origin='Web')};
            insert as system cases;
            // Shares explícitos SOLO de fixtures: aíslan la capa CRUD/FLS/propietario.
            // Las reglas desplegadas se contrastan aparte con el usuario persistente.
            List<AccountShare> accountShares=new List<AccountShare>();List<AssetShare> assetShares=new List<AssetShare>();
            for(Integer i=0;i<3;i++)for(Integer a=0;a<(i==2?2:1);a++){
                String access=i==2?'Edit':'Read';
                accountShares.add(new AccountShare(AccountId=accounts[a].Id,UserOrGroupId=users[i].Id,
                    AccountAccessLevel=access,CaseAccessLevel='None',OpportunityAccessLevel='None',RowCause=Schema.AccountShare.RowCause.Manual));
                assetShares.add(new AssetShare(AssetId=assets[a].Id,UserOrGroupId=users[i].Id,AssetAccessLevel=access,RowCause=Schema.AssetShare.RowCause.Manual));
            }
            insert as system accountShares;insert as system assetShares;
            List<CaseShare> caseShares=new List<CaseShare>();
            for(Integer i=0;i<4;i++)caseShares.add(new CaseShare(CaseId=cases[i].Id,UserOrGroupId=users[2].Id,CaseAccessLevel='Edit',RowCause=Schema.CaseShare.RowCause.Manual));
            insert as system caseShares;
        }
    }
    private static User usuario(String alias){return [SELECT Id FROM User WHERE Alias=:alias WITH SYSTEM_MODE LIMIT 1];}
    private static Asset producto(String suffix){String n='P04 SEG '+suffix;return [SELECT Id,AccountId,ContactId,PurchaseDate,P04_InicioGarantia__c,P04_FinGarantia__c FROM Asset WHERE Name=:n WITH SYSTEM_MODE];}
    private static Case caso(String suffix){String n='P04 SEG '+suffix;return [SELECT Id,OwnerId,AccountId,ContactId,AssetId,RecordTypeId,P04_FechaIncidencia__c FROM Case WHERE Subject=:n WITH SYSTEM_MODE];}
    private static Case nuevo(Asset a,String subject,Id owner){return new Case(Subject=subject,OwnerId=owner,RecordTypeId=P04Integridad.CASO,AccountId=a.AccountId,ContactId=a.ContactId,AssetId=a.Id,Status='P04_Nuevo',Origin='Web',P04_FechaIncidencia__c=Date.today().addDays(-1));}
    private static void denegado(Database.SaveResult r){System.assertEquals(false,r.isSuccess(),'Escritura debía rechazarse');System.assert(!r.getErrors().isEmpty());}
    private static void sinConsulta(String query){Boolean denied=false;try{List<SObject> rows=Database.query(query,AccessLevel.USER_MODE);denied=rows.isEmpty();}catch(QueryException e){denied=true;}System.assert(denied,'Consulta no autorizada');}

    @IsTest static void minimoSinCrudNiDatos(){
        User u=usuario('p04sn');Case own=caso('sin permisos');Asset a=producto('A');
        System.runAs(u){
            System.assertEquals(false,Schema.sObjectType.Case.isAccessible());
            for(String obj:new List<String>{'Account','Contact','Asset','Case'})sinConsulta('SELECT Id FROM '+obj);
            denegado(Database.update(new Case(Id=own.Id,Subject='Bloqueado'),false,AccessLevel.USER_MODE));
            denegado(Database.insert(nuevo(a,'Bloqueado',u.Id),false,AccessLevel.USER_MODE));
        }
    }
    @IsTest static void agenteCreaYEditaPropio(){
        User u=usuario('p04sa');Asset a=producto('A');
        System.runAs(u){
            Case c=nuevo(a,'P04 SEG nuevo',u.Id);insert as user c;
            update as user new Case(Id=c.Id,OwnerId=u.Id);
            update as user new Case(Id=c.Id,Subject='P04 SEG editado');
            Case saved=[SELECT Subject,P04_ResultadoGarantia__c FROM Case WHERE Id=:c.Id WITH USER_MODE];
            System.assertEquals('P04 SEG editado',saved.Subject);System.assertEquals(null,saved.P04_ResultadoGarantia__c);
        }
    }
    @IsTest static void agenteNoAccedeACasoAjeno(){
        User u=usuario('p04sa');Case other=caso('otro');
        System.runAs(u){
            System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:other.Id WITH USER_MODE]);
            denegado(Database.update(new Case(Id=other.Id,Subject='No permitido'),false,AccessLevel.USER_MODE));
        }
    }
    @IsTest static void clienteCompartidoNoAbreOtrosCasos(){
        User u=usuario('p04sa');Asset a=producto('A');
        System.runAs(u){
            System.assertEquals(1,[SELECT COUNT() FROM Account WHERE Id=:a.AccountId WITH USER_MODE]);
            System.assertEquals(1,[SELECT COUNT() FROM Contact WHERE Id=:a.ContactId WITH USER_MODE]);
            System.assertEquals(1,[SELECT COUNT() FROM Asset WHERE Id=:a.Id WITH USER_MODE]);
            System.assertEquals(1,[SELECT COUNT() FROM Case WHERE AccountId=:a.AccountId WITH USER_MODE]);
        }
    }
    @IsTest static void agenteNoLeeRegistrosNoCompartidos(){
        User u=usuario('p04sa');Asset b=producto('B'),externo=producto('externo');Case hidden=caso('no compartido');
        System.runAs(u){
            System.assertEquals(0,[SELECT COUNT() FROM Account WHERE Id IN :new Set<Id>{b.AccountId,externo.AccountId} WITH USER_MODE]);
            System.assertEquals(0,[SELECT COUNT() FROM Contact WHERE Id=:b.ContactId WITH USER_MODE]);
            System.assertEquals(0,[SELECT COUNT() FROM Asset WHERE Id IN :new Set<Id>{b.Id,externo.Id} WITH USER_MODE]);
            System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:hidden.Id WITH USER_MODE]);
        }
    }
    @IsTest static void agenteNoEditaCompraGarantiaNiPadres(){
        User u=usuario('p04sa');Asset a=producto('A');
        System.runAs(u){
            System.assertEquals(false,Schema.sObjectType.Asset.fields.PurchaseDate.isUpdateable());
            System.assertEquals(false,Schema.sObjectType.Asset.fields.P04_InicioGarantia__c.isUpdateable());
            denegado(Database.update(new Asset(Id=a.Id,PurchaseDate=Date.today()),false,AccessLevel.USER_MODE));
            denegado(Database.update(new Asset(Id=a.Id,P04_FinGarantia__c=Date.today()),false,AccessLevel.USER_MODE));
            denegado(Database.update(new Account(Id=a.AccountId,Name='No'),false,AccessLevel.USER_MODE));
            denegado(Database.update(new Contact(Id=a.ContactId,LastName='No'),false,AccessLevel.USER_MODE));
        }
    }
    @IsTest static void responsableCorrigeProductoYGestionaCasos(){
        User u=usuario('p04sr');Asset a=producto('A');Case other=caso('otro');
        System.runAs(u){
            update as user new Asset(Id=a.Id,PurchaseDate=Date.today().addDays(-40),P04_InicioGarantia__c=Date.today().addDays(-40),P04_FinGarantia__c=Date.today().addDays(350));
            update as user new Case(Id=other.Id,Subject='P04 SEG responsable');
            System.assertEquals(Date.today().addDays(350),[SELECT P04_FinGarantia__c FROM Asset WHERE Id=:a.Id WITH USER_MODE].P04_FinGarantia__c);
            System.assertEquals('P04 SEG responsable',[SELECT Subject FROM Case WHERE Id=:other.Id WITH USER_MODE].Subject);
        }
    }
    @IsTest static void responsableReasignaDentroDelEquipo(){
        User manager=usuario('p04sr'),target=usuario('p04sb');Case c=caso('propio');
        System.runAs(manager){update as user new Case(Id=c.Id,OwnerId=target.Id);}
        System.assertEquals(target.Id,[SELECT OwnerId FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].OwnerId);
    }
    @IsTest static void responsableNoReasignaFueraDelEquipo(){
        User manager=usuario('p04sr'),target=usuario('p04sn');Case c=caso('propio');
        System.runAs(manager){denegado(Database.update(new Case(Id=c.Id,OwnerId=target.Id),false,AccessLevel.USER_MODE));}
        System.assertEquals(c.OwnerId,[SELECT OwnerId FROM Case WHERE Id=:c.Id WITH SYSTEM_MODE].OwnerId);
    }
    @IsTest static void agenteNoReasignaNiUsaPropiedadAjena(){
        User agent=usuario('p04sa'),target=usuario('p04sb');Asset a=producto('A');Case c=caso('propio');
        System.runAs(agent){
            denegado(Database.update(new Case(Id=c.Id,OwnerId=target.Id),false,AccessLevel.USER_MODE));
            denegado(Database.insert(nuevo(a,'No',target.Id),false,AccessLevel.USER_MODE));
        }
    }
    @IsTest static void evaluacionNoEditablePorNingunaFuncion(){
        Case c=caso('propio');
        Map<String,Object> values=new Map<String,Object>{'P04_ResultadoGarantia__c'=>'En_cobertura','P04_MotivoGarantia__c'=>'No',
            'P04_CompraEvaluada__c'=>Date.today(),'P04_InicioEvaluado__c'=>Date.today(),'P04_FinEvaluado__c'=>Date.today(),
            'P04_IncidenciaEvaluada__c'=>Date.today(),'P04_EvaluadaEl__c'=>System.now()};
        for(String role:new List<String>{'p04sa','p04sr'}){
            User u=usuario(role);System.runAs(u){
                for(String field:values.keySet()){
                    System.assertEquals(false,Schema.sObjectType.Case.fields.getMap().get(field).getDescribe().isUpdateable());
                    Case edit=new Case(Id=c.Id);edit.put(field,values.get(field));denegado(Database.update(edit,false,AccessLevel.USER_MODE));
                }
            }
        }
    }
    @IsTest static void ningunaFuncionPuedeBorrar(){
        Asset a=producto('A');Case c=caso('propio');
        for(String role:new List<String>{'p04sa','p04sr'}){
            User u=usuario(role);System.runAs(u){
                for(SObject row:new List<SObject>{new Account(Id=a.AccountId),new Contact(Id=a.ContactId),new Asset(Id=a.Id),new Case(Id=c.Id)}){
                    Database.DeleteResult result=Database.delete(row,false,AccessLevel.USER_MODE);System.assertEquals(false,result.isSuccess());
                }
            }
        }
    }
    @IsTest static void responsableRegistraRecorridoAcotado(){
        User u=usuario('p04sr');System.runAs(u){
            Account a=new Account(Name='P04 SEG alta ordinaria');insert as user a;
            System.assertEquals(true,[SELECT P04_Posventa__c FROM Account WHERE Id=:a.Id WITH USER_MODE].P04_Posventa__c);
            Contact c=new Contact(LastName='Ficticio',AccountId=a.Id);insert as user c;
            Asset product=new Asset(Name='Ficticio',AccountId=a.Id,ContactId=c.Id,RecordTypeId=P04Integridad.PRODUCTO);insert as user product;
            Case issue=nuevo(product,'P04 SEG alta completa',u.Id);insert as user issue;System.assertNotEquals(null,issue.Id);
        }
    }
    @IsTest static void responsableNoConvierteDatosAjenos(){
        User u=usuario('p04sr');Asset foreign=producto('externo');
        // Incluso una propiedad concedida por administración no habilita mezclar aplicaciones.
        update as system new Account(Id=foreign.AccountId,OwnerId=u.Id);
        System.runAs(u){denegado(Database.update(new Account(Id=foreign.AccountId,Name='No'),false,AccessLevel.USER_MODE));}
    }
    @IsTest static void retirarPermisoRevocaCrudAunqueSeaPropietario(){
        User u=usuario('p04sa');Case c=caso('propio');
        System.runAs(new User(Id=UserInfo.getUserId())){delete as system [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:u.Id AND PermissionSet.Name='P04_Agente' WITH SYSTEM_MODE];}
        System.runAs(u){
            System.assertEquals(false,Schema.sObjectType.Case.isAccessible());
            sinConsulta('SELECT Id FROM Case');
            denegado(Database.update(new Case(Id=c.Id,Subject='No'),false,AccessLevel.USER_MODE));
        }
    }
    @IsTest static void integridadBajoAgente(){
        User u=usuario('p04sa');Asset a=producto('A');
        System.runAs(u){
            Case missing=nuevo(a,'P04 SEG inválido',u.Id);missing.ContactId=null;
            Database.SaveResult result=Database.insert(missing,false,AccessLevel.USER_MODE);denegado(result);System.assert(result.getErrors()[0].getMessage().contains('P04:'));
            Case future=nuevo(a,'P04 SEG futuro',u.Id);future.P04_FechaIncidencia__c=Date.today().addDays(1);
            result=Database.insert(future,false,AccessLevel.USER_MODE);denegado(result);System.assert(result.getErrors()[0].getMessage().contains('incidencia no puede ser futura'));
        }
    }
    @IsTest static void integridadBajoResponsable(){
        User u=usuario('p04sr');Asset a=producto('A'),b=producto('B');
        System.runAs(u){
            Database.SaveResult result=Database.update(new Asset(Id=a.Id,P04_FinGarantia__c=Date.today().addDays(-100)),false,AccessLevel.USER_MODE);
            denegado(result);System.assert(result.getErrors()[0].getMessage().contains('fin de garantía'));
            Case c=nuevo(a,'P04 SEG incoherente',u.Id);c.ContactId=b.ContactId;
            result=Database.insert(c,false,AccessLevel.USER_MODE);denegado(result);System.assert(result.getErrors()[0].getMessage().contains('contacto del caso'));
        }
    }
    @IsTest static void guardianNoDependeDeModoUsuario(){
        User u=usuario('p04sa');Case own=caso('propio'),other=caso('otro');Asset a=producto('A');
        System.runAs(u){
            // Prueba distinta: defensa del trigger frente a una llamada interna privilegiada.
            denegado(Database.update(new Case(Id=own.Id,P04_ResultadoGarantia__c='En_cobertura'),false,AccessLevel.SYSTEM_MODE));
            denegado(Database.update(new Case(Id=other.Id,Subject='No'),false,AccessLevel.SYSTEM_MODE));
            denegado(Database.update(new Asset(Id=a.Id,PurchaseDate=Date.today()),false,AccessLevel.SYSTEM_MODE));
        }
    }
    @IsTest static void sinFuncionNoEscribeP04DesdeModoSistema(){
        User u=usuario('p04sn');Case c=caso('sin permisos');System.runAs(u){
            Database.SaveResult r=Database.update(new Case(Id=c.Id,Subject='No'),false,AccessLevel.SYSTEM_MODE);denegado(r);System.assertEquals('P04: operación no autorizada.',r.getErrors()[0].getMessage());
        }
    }
    @IsTest static void agenteProcesaLote200EnModoUsuario(){
        User u=usuario('p04sa');Asset a=producto('A');System.runAs(u){
            List<Case> rows=new List<Case>();for(Integer i=0;i<200;i++)rows.add(nuevo(a,'P04 SEG lote',u.Id));
            Test.startTest();insert as user rows;
            List<Case> tomas=new List<Case>();for(Case c:rows)tomas.add(new Case(Id=c.Id,OwnerId=u.Id));update as user tomas;
            List<Case> edits=new List<Case>();for(Case c:rows)edits.add(new Case(Id=c.Id,Subject='P04 SEG lote editado'));update as user edits;Test.stopTest();
            System.assertEquals(200,[SELECT COUNT() FROM Case WHERE Subject='P04 SEG lote editado' WITH USER_MODE]);
        }
    }
}
