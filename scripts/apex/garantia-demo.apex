// Demostración administrativa, no prueba de identidad ordinaria. Solo dos registros propios, revertidos.
System.assert(FeatureManagement.checkPermission('P04_Administrar'),'P04: falta permiso administrativo.');
Account client=[SELECT Id FROM Account WHERE AccountNumber='P04-S03-DEMO-A' AND P04_Posventa__c=true WITH USER_MODE];
Contact contact=[SELECT Id FROM Contact WHERE AccountId=:client.Id WITH USER_MODE LIMIT 1];
Savepoint point=Database.setSavepoint();
Id temporaryCase,temporaryAsset;
try{
    Asset product=new Asset(Name='P04 S05 TEMP producto',AccountId=client.Id,ContactId=contact.Id,RecordTypeId=P04Integridad.PRODUCTO,
        PurchaseDate=Date.today().addDays(-30),P04_InicioGarantia__c=Date.today().addDays(-10),P04_FinGarantia__c=Date.today().addDays(10));
    insert as user product;temporaryAsset=product.Id;
    Case issue=new Case(Subject='P04 S05 TEMP caso',AccountId=client.Id,ContactId=contact.Id,AssetId=product.Id,RecordTypeId=P04Integridad.CASO,
        Status='P04_Nuevo',Origin='Web',P04_FechaIncidencia__c=Date.today().addDays(-1));
    Database.DMLOptions options=new Database.DMLOptions();options.EmailHeader.triggerUserEmail=false;options.EmailHeader.triggerAutoResponseEmail=false;options.EmailHeader.triggerOtherEmail=false;issue.setOptions(options);
    insert as user issue;temporaryCase=issue.Id;
    System.assert(P04Garantia.evaluar(new List<String>{issue.Id})[0].correcto);
    Case first=[SELECT P04_ResultadoGarantia__c,P04_FinEvaluado__c,P04_EvaluadaEl__c FROM Case WHERE Id=:issue.Id WITH USER_MODE];
    System.assertEquals('En_cobertura',first.P04_ResultadoGarantia__c);
    update as user new Asset(Id=product.Id,P04_FinGarantia__c=Date.today().addDays(-2));
    Case historic=[SELECT P04_ResultadoGarantia__c,P04_FinEvaluado__c,P04_EvaluadaEl__c FROM Case WHERE Id=:issue.Id WITH USER_MODE];
    System.assertEquals(first,historic,'No debe recalcularse al editar producto.');
    P04EvaluarGarantiaAccion.Solicitud request=new P04EvaluarGarantiaAccion.Solicitud();request.casoId=issue.Id;
    System.assert(P04EvaluarGarantiaAccion.ejecutar(new List<P04EvaluarGarantiaAccion.Solicitud>{request})[0].correcto);
    Case second=[SELECT P04_ResultadoGarantia__c,P04_FinEvaluado__c,P04_EvaluadaEl__c FROM Case WHERE Id=:issue.Id WITH USER_MODE];
    System.assertEquals('Fuera_cobertura',second.P04_ResultadoGarantia__c);
    System.assertEquals(Date.today().addDays(-2),second.P04_FinEvaluado__c);
    update as user new Case(Id=issue.Id,Status='P04_Cerrado');
    System.assertEquals('CASO_CERRADO',P04Garantia.evaluar(new List<String>{issue.Id})[0].codigo);
    System.assertEquals(second,[SELECT P04_ResultadoGarantia__c,P04_FinEvaluado__c,P04_EvaluadaEl__c FROM Case WHERE Id=:issue.Id WITH USER_MODE]);
}finally{Database.rollback(point);}
System.assertEquals(0,[SELECT COUNT() FROM Case WHERE Id=:temporaryCase WITH USER_MODE]);
System.assertEquals(0,[SELECT COUNT() FROM Asset WHERE Id=:temporaryAsset WITH USER_MODE]);
System.debug(LoggingLevel.ERROR,'P04_GARANTIA_DEMO_OK');
