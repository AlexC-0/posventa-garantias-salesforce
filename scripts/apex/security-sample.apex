// Preparación administrativa de dos casos temporales. Sin notificaciones.
System.assert(FeatureManagement.checkPermission('P04_Administrar'),'P04: falta autorización administrativa.');
List<Account> clients=[SELECT Id,AccountNumber,P04_Posventa__c FROM Account WHERE AccountNumber IN ('P04-S03-DEMO-A','P04-S03-DEMO-B') WITH USER_MODE];
System.assertEquals(2,clients.size(),'P04: debe existir la muestra de sesión 03.');
for(Account a:clients)a.P04_Posventa__c=true;
update as user clients;
System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Subject LIKE 'P04 S04 TEMP %' WITH USER_MODE],'P04: ya existe una muestra temporal; no duplicarla.');
Asset asset=[SELECT Id,AccountId,ContactId FROM Asset WHERE Name='P04 DEMO - Impresora N1' AND RecordType.DeveloperName='P04_Producto' WITH USER_MODE LIMIT 1];
List<Case> cases=new List<Case>();
for(String name:new List<String>{'Agente','Equipo'}){
 Case c=new Case(Subject='P04 S04 TEMP '+name,RecordTypeId=P04Integridad.CASO,AccountId=asset.AccountId,
     ContactId=asset.ContactId,AssetId=asset.Id,Status='P04_Nuevo',Origin='Web',P04_FechaIncidencia__c=Date.today());
 Database.DMLOptions options=new Database.DMLOptions();options.EmailHeader.triggerUserEmail=false;options.EmailHeader.triggerAutoResponseEmail=false;options.EmailHeader.triggerOtherEmail=false;c.setOptions(options);cases.add(c);
}
insert as user cases;
System.debug(LoggingLevel.ERROR,'P04_SECURITY_SAMPLE='+JSON.serialize(new Map<String,Object>{'ownCase'=>cases[0].Id,'teamCase'=>cases[1].Id,'account'=>asset.AccountId,'contact'=>asset.ContactId,'asset'=>asset.Id}));
