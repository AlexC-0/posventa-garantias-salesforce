// Solo los dos identificadores devueltos por New-SecuritySample. Sin búsqueda masiva para borrar.
System.assert(FeatureManagement.checkPermission('P04_Administrar'),'P04: falta autorización administrativa.');
Set<Id> ids=new Set<Id>{'__OWN__','__TEAM__'};
List<Case> rows=[SELECT Id,Subject,AccountId,Account.AccountNumber,RecordTypeId FROM Case WHERE Id IN :ids WITH USER_MODE];
for(Case row:rows){
    System.assert(row.Subject.startsWith('P04 S04 TEMP '),'P04: asunto temporal inesperado.');
    System.assertEquals('__ACCOUNT__',String.valueOf(row.AccountId),'P04: cliente inesperado.');
    System.assertEquals('P04-S03-DEMO-A',row.Account.AccountNumber,'P04: cliente fuera de muestra.');
    System.assertEquals(P04Integridad.CASO,row.RecordTypeId,'P04: tipo inesperado.');
}
delete as user rows;
System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id IN :ids WITH USER_MODE]);
System.assertEquals(2,[SELECT COUNT() FROM Case WHERE Subject LIKE 'P04 DEMO - %' AND RecordTypeId=:P04Integridad.CASO WITH USER_MODE],'P04: revisar muestra original.');
System.debug(LoggingLevel.ERROR,'P04_SECURITY_CLEANUP_OK');
