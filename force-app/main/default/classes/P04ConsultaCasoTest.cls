@IsTest
private class P04ConsultaCasoTest {
    @TestSetup static void preparar() {
        Id perfil = [SELECT Id FROM Profile WHERE Name='P04_Minimo' WITH SYSTEM_MODE].Id;
        List<User> usuarios = new List<User>();
        for (String alias : new List<String>{'p07a','p07b','p07r','p07sin','p07fls'}) {
            usuarios.add(new User(Alias=alias,LastName=alias,Email=alias+'@example.invalid',
                Username=alias+'.'+Crypto.getRandomLong()+'@example.invalid',ProfileId=perfil,
                TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US'));
        }
        System.runAs(new User(Id=UserInfo.getUserId())) {
            insert as system usuarios;
            Map<String,Id> permisos = new Map<String,Id>();
            for(PermissionSet p:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('P04_Agente','P04_Responsable') WITH SYSTEM_MODE]) permisos.put(p.Name,p.Id);
            List<PermissionSetAssignment> asignaciones = new List<PermissionSetAssignment>();
            List<GroupMember> miembros = new List<GroupMember>();
            for(Integer i=0;i<3;i++) {
                asignaciones.add(new PermissionSetAssignment(AssigneeId=usuarios[i].Id,PermissionSetId=permisos.get(i==2?'P04_Responsable':'P04_Agente')));
                miembros.add(new GroupMember(GroupId=P04Cola.idCola(),UserOrGroupId=usuarios[i].Id));
            }
            // Concesión aislada de lectura sin SerialNumber: prueba real de FLS, no un mock.
            PermissionSet limitado = new PermissionSet(Name='P07LecturaSinSerie',Label='P07 lectura sin serie');
            insert as system limitado;
            insert as system new SetupEntityAccess(ParentId=limitado.Id,SetupEntityId=[SELECT Id FROM CustomPermission WHERE DeveloperName='P04_Usar' WITH SYSTEM_MODE].Id);
            List<ObjectPermissions> objetos = new List<ObjectPermissions>();
            for(String objeto:new List<String>{'Account','Contact','Asset','Case'}) objetos.add(new ObjectPermissions(ParentId=limitado.Id,SobjectType=objeto,PermissionsRead=true));
            insert as system objetos;
            List<FieldPermissions> campos = new List<FieldPermissions>();
            for(FieldPermissions f:[SELECT SobjectType,Field FROM FieldPermissions WHERE ParentId=:permisos.get('P04_Agente') AND PermissionsRead=true WITH SYSTEM_MODE]) {
                if(f.Field!='Asset.SerialNumber') campos.add(new FieldPermissions(ParentId=limitado.Id,SobjectType=f.SobjectType,Field=f.Field,PermissionsRead=true));
            }
            insert as system campos;
            asignaciones.add(new PermissionSetAssignment(AssigneeId=usuarios[4].Id,PermissionSetId=limitado.Id));
            insert as system asignaciones; insert as system miembros;
        }
        Account ac = new Account(Name='P07 cliente',P04_Posventa__c=true); insert as system ac;
        Contact co = new Contact(LastName='P07 contacto',AccountId=ac.Id); insert as system co;
        List<Asset> productos = new List<Asset>();
        for(String nombre:new List<String>{'P07 producto','P07 opcional','P07 oculto'}) productos.add(new Asset(Name=nombre,AccountId=ac.Id,ContactId=co.Id,
            RecordTypeId=P04Integridad.PRODUCTO,SerialNumber=nombre=='P07 opcional'?null:'SERIE-FICTICIA',
            PurchaseDate=nombre=='P07 opcional'?null:Date.newInstance(2024,1,1),P04_InicioGarantia__c=null,P04_FinGarantia__c=null));
        insert as system productos;
        List<AccountShare> cuentas = new List<AccountShare>(); List<AssetShare> assets = new List<AssetShare>();
        for(User u:usuarios) {
            cuentas.add(new AccountShare(AccountId=ac.Id,UserOrGroupId=u.Id,AccountAccessLevel='Read',CaseAccessLevel='None',OpportunityAccessLevel='None'));
            for(Integer i=0;i<2;i++) assets.add(new AssetShare(AssetId=productos[i].Id,UserOrGroupId=u.Id,AssetAccessLevel='Read'));
        }
        insert as system cuentas; insert as system assets;
        List<Case> casos = new List<Case>();
        for(Integer i=0;i<10;i++) casos.add(nuevo(productos[0],i==0?'P07 actual':'P07 relacionado '+i,i==9?usuarios[1].Id:usuarios[0].Id));
        casos.add(nuevo(productos[1],'P07 ausentes',usuarios[0].Id));
        casos.add(nuevo(productos[2],'P07 producto oculto',usuarios[0].Id));
        insert as system casos;
        List<CaseShare> shares = new List<CaseShare>();
        for(Case c:casos) {
            shares.add(new CaseShare(CaseId=c.Id,UserOrGroupId=usuarios[2].Id,CaseAccessLevel='Edit'));
            shares.add(new CaseShare(CaseId=c.Id,UserOrGroupId=usuarios[4].Id,CaseAccessLevel='Read'));
        }
        insert as system shares;
    }
    private static Case nuevo(Asset a,String asunto,Id owner) {
        return new Case(Subject=asunto,OwnerId=owner,RecordTypeId=P04Integridad.CASO,AccountId=a.AccountId,ContactId=a.ContactId,
            AssetId=a.Id,Status='P04_Nuevo',Origin='Web',P04_FechaIncidencia__c=Date.newInstance(2024,2,20));
    }
    private static User usuario(String alias) { return [SELECT Id FROM User WHERE Alias=:alias WITH SYSTEM_MODE]; }
    private static Case caso(String asunto) { return [SELECT Id,AssetId,LastModifiedDate FROM Case WHERE Subject=:asunto WITH SYSTEM_MODE]; }
    private static Map<String,Object> consulta(Id id,String alias) { Map<String,Object> r; System.runAs(usuario(alias)){r=P04ConsultaCaso.consultar(id);}return r; }
    private static void denegado(Map<String,Object> r) { System.assertEquals(new Map<String,Object>{'codigo'=>'NO_DISPONIBLE'},r); }

    @IsTest static void agenteConsultaPropia() {
        Case c=caso('P07 actual');Map<String,Object> r=consulta(c.Id,'p07a');System.assertEquals('OK',r.get('codigo'));
        System.assertEquals(c.Id,((Map<String,Object>)r.get('caso')).get('id'));
        System.assertEquals('SERIE-FICTICIA',((Map<String,Object>)r.get('producto')).get('serie'));
    }
    @IsTest static void responsableConsultaPermitida() {
        System.assertEquals('OK',consulta(caso('P07 relacionado 9').Id,'p07r').get('codigo'));
    }
    @IsTest static void casoAjenoNoRevelaExistencia() {
        denegado(consulta(caso('P07 relacionado 9').Id,'p07a'));
    }
    @IsTest static void sinPermisosAunquePropietario() {
        Case c=caso('P07 actual');update as system new Case(Id=c.Id,OwnerId=usuario('p07sin').Id);
        denegado(consulta(c.Id,'p07sin'));
    }
    @IsTest static void camposRestringidosRechazanSinParcial() {
        Case c=caso('P07 actual');System.runAs(usuario('p07fls')) {
            System.assert(Schema.sObjectType.Asset.isAccessible());
            System.assert(!Schema.sObjectType.Asset.fields.SerialNumber.isAccessible());
            System.assertEquals(1,[SELECT COUNT() FROM Case WHERE Id=:c.Id WITH USER_MODE]);
            denegado(P04ConsultaCaso.consultar(c.Id));
        }
    }
    @IsTest static void productoNoVisibleRechaza() {
        denegado(consulta(caso('P07 producto oculto').Id,'p07a'));
    }
    @IsTest static void relacionadosLimiteOrdenExclusionYOcultos() {
        for(Case row:[SELECT Id,Subject FROM Case WHERE Subject LIKE 'P07 relacionado %' WITH SYSTEM_MODE]) {
            Integer numero=Integer.valueOf(row.Subject.substringAfterLast(' '));
            Test.setCreatedDate(row.Id,Datetime.newInstanceGmt(2024,3,1,12,0,0).addDays(numero==9?30:numero));
        }
        Case c=caso('P07 actual');Id oculto=caso('P07 relacionado 9').Id;
        List<Case> lista=(List<Case>)consulta(c.Id,'p07a').get('relacionados');System.assertEquals(5,lista.size());
        for(Integer i=0;i<5;i++) {System.assertEquals('P07 relacionado '+(8-i),lista[i].Subject);System.assertNotEquals(c.Id,lista[i].Id);System.assertNotEquals(oculto,lista[i].Id);}
    }
    @IsTest static void desempatePorIdDescendente() {
        List<Case> casos=[SELECT Id FROM Case WHERE Subject LIKE 'P07 relacionado %' AND Subject!='P07 relacionado 9' WITH SYSTEM_MODE ORDER BY Id DESC];
        for(Case c:casos)Test.setCreatedDate(c.Id,Datetime.newInstanceGmt(2024,4,1,0,0,0));
        List<Case> lista=(List<Case>)consulta(caso('P07 actual').Id,'p07a').get('relacionados');
        for(Integer i=0;i<5;i++)System.assertEquals(casos[i].Id,lista[i].Id);
    }
    @IsTest static void relacionadosSegunAccesoResponsable() {
        for(Case row:[SELECT Id,Subject FROM Case WHERE Subject LIKE 'P07 relacionado %' WITH SYSTEM_MODE])
            Test.setCreatedDate(row.Id,Datetime.newInstanceGmt(2024,3,1,12,0,0).addDays(Integer.valueOf(row.Subject.substringAfterLast(' '))));
        List<Case> lista=(List<Case>)consulta(caso('P07 actual').Id,'p07r').get('relacionados');
        System.assertEquals(5,lista.size());System.assertEquals('P07 relacionado 9',lista[0].Subject);
    }
    @IsTest static void opcionalesYSinEvaluarYSinRelacionados() {
        Map<String,Object> r=consulta(caso('P07 ausentes').Id,'p07a');System.assertEquals('OK',r.get('codigo'));
        Map<String,Object> p=(Map<String,Object>)r.get('producto'),c=(Map<String,Object>)r.get('caso');
        for(String campo:new List<String>{'serie','compra','inicio','fin'})System.assertEquals(null,p.get(campo));
        System.assertEquals(null,c.get('resultado'));System.assertEquals(null,c.get('evaluadaEl'));
        System.assertEquals(0,((List<Case>)r.get('relacionados')).size());
    }
    @IsTest static void conservaInstantaneaYConsultaSinEscribir() {
        Case c=caso('P07 actual');System.runAs(usuario('p07a')){P04Garantia.Resultado evaluacion=P04Garantia.evaluar(new List<String>{c.Id})[0];System.assert(evaluacion.correcto,evaluacion.codigo+': '+evaluacion.mensaje);}
        update as system new Asset(Id=c.AssetId,P04_InicioGarantia__c=Date.newInstance(2024,1,1),P04_FinGarantia__c=Date.newInstance(2025,1,1));
        Case antes=caso('P07 actual');System.runAs(usuario('p07a')) {
            Test.startTest();Integer dml=Limits.getDmlStatements();Map<String,Object> r=P04ConsultaCaso.consultar(c.Id);
            System.assertEquals(dml,Limits.getDmlStatements());Test.stopTest();
            System.assertEquals('Pendiente_datos',((Map<String,Object>)r.get('caso')).get('resultado'));
            System.assertEquals(null,((Map<String,Object>)r.get('caso')).get('fin'));
            System.assertEquals(Date.newInstance(2025,1,1),((Map<String,Object>)r.get('producto')).get('fin'));
        }
        System.assertEquals(antes.LastModifiedDate,caso('P07 actual').LastModifiedDate);
    }
    @IsTest static void entradasInvalidasEinexistente() {
        Case temporal=caso('P07 ausentes');delete as system temporal;
        System.runAs(usuario('p07a')) {
            for(String id:new List<String>{null,'','no-es-id',String.valueOf(temporal.Id),String.valueOf(temporal.AssetId)})denegado(P04ConsultaCaso.consultar(id));
        }
    }
    @IsTest static void revocacionConsultaNoUsaCache() {
        Case c=caso('P07 actual');User u=usuario('p07a');System.assertEquals('OK',consulta(c.Id,'p07a').get('codigo'));
        System.runAs(new User(Id=UserInfo.getUserId())){delete as system [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:u.Id AND PermissionSet.Name='P04_Agente' WITH SYSTEM_MODE];}
        denegado(consulta(c.Id,'p07a'));
    }
}
