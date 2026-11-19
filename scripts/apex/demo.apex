// Ocho registros ficticios. Si ya existe la muestra, se detiene sin modificarla.
System.assertEquals(0, [SELECT COUNT() FROM Account WHERE AccountNumber IN ('P04-S03-DEMO-A','P04-S03-DEMO-B')],
    'P04: la muestra ya existe; consultar los registros conservados, no duplicarla.');
List<Account> clientes=new List<Account>{
    new Account(Name='P04 DEMO - Taller Norte (ficticio)',AccountNumber='P04-S03-DEMO-A',Description='Muestra ficticia de posventa. Sin comunicaciones reales.'),
    new Account(Name='P04 DEMO - Taller Sur (ficticio)',AccountNumber='P04-S03-DEMO-B',Description='Muestra ficticia de posventa. Sin comunicaciones reales.')
};
insert clientes;
List<Contact> contactos=new List<Contact>{
    new Contact(LastName='Contacto Norte (ficticio)',AccountId=clientes[0].Id),
    new Contact(LastName='Contacto Sur (ficticio)',AccountId=clientes[1].Id)
};
insert contactos;
List<Asset> productos=new List<Asset>{
    new Asset(Name='P04 DEMO - Impresora N1',SerialNumber='P04-FICT-N1',RecordTypeId=P04Integridad.PRODUCTO,
        AccountId=clientes[0].Id,ContactId=contactos[0].Id,PurchaseDate=Date.today().addDays(-30),
        P04_InicioGarantia__c=Date.today().addDays(-30),P04_FinGarantia__c=Date.today().addDays(335)),
    new Asset(Name='P04 DEMO - Impresora S1',SerialNumber='P04-FICT-S1',RecordTypeId=P04Integridad.PRODUCTO,
        AccountId=clientes[1].Id,ContactId=contactos[1].Id,PurchaseDate=Date.today().addDays(-60))
};
insert productos;
List<Case> casos=new List<Case>();
for(Integer i=0;i<2;i++)casos.add(new Case(Subject='P04 DEMO - Incidencia de impresión '+(i+1),
    Description='Datos ficticios. Modelo y coherencia comprobados; garantía todavía sin evaluar.',
    AccountId=clientes[i].Id,ContactId=contactos[i].Id,AssetId=productos[i].Id,
    RecordTypeId=P04Integridad.CASO,Status='P04_Nuevo',Origin='Web',P04_FechaIncidencia__c=Date.today().addDays(-1)));
insert casos;
Map<String,Object> ids=new Map<String,Object>{'accountA'=>clientes[0].Id,'accountB'=>clientes[1].Id,
    'contactA'=>contactos[0].Id,'contactB'=>contactos[1].Id,'assetA'=>productos[0].Id,'assetB'=>productos[1].Id,
    'caseA'=>casos[0].Id,'caseB'=>casos[1].Id,'caseRecordType'=>P04Integridad.CASO,
    'incidentDate'=>String.valueOf(Date.today().addDays(-1))};
System.debug(LoggingLevel.ERROR,'P04_DEMO_JSON='+JSON.serialize(ids));