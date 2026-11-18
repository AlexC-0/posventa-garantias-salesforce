// Solo aprovisionamiento administrativo. No establece contraseña ni envía correos.
Profile base=[SELECT Id FROM Profile WHERE Name='P04_Minimo' WITH USER_MODE];
List<User> found=[SELECT Id,Username,ProfileId,IsActive,UserRoleId FROM User WHERE Alias='p04test' WITH USER_MODE];
System.assert(found.size()<=1,'P04: alias de pruebas ambiguo.');
User ordinary;
if(found.isEmpty()){
    UserLicense license=[SELECT TotalLicenses,UsedLicenses FROM UserLicense WHERE Name='Salesforce' WITH USER_MODE];
    System.assert(license.UsedLicenses<license.TotalLicenses,'P04: no hay plaza libre.');
    ordinary=new User(Alias='p04test',LastName='P04 Pruebas Seguridad',Email='p04.seguridad@example.invalid',
        Username='p04.seguridad.'+UserInfo.getOrganizationId()+'.'+String.valueOf(System.now().getTime())+'@example.invalid',
        ProfileId=base.Id,IsActive=true,TimeZoneSidKey='Europe/Madrid',LocaleSidKey='es_ES',LanguageLocaleKey='en_US',EmailEncodingKey='UTF-8');
    Database.DMLOptions options=new Database.DMLOptions();
    options.EmailHeader.triggerUserEmail=false;options.EmailHeader.triggerAutoResponseEmail=false;options.EmailHeader.triggerOtherEmail=false;
    ordinary.setOptions(options);
    insert as user ordinary;
}else{
    ordinary=found[0];
    System.assert(ordinary.ProfileId==base.Id&&ordinary.IsActive&&ordinary.UserRoleId==null,'P04: usuario existente incompatible; conservar y revisar.');
}
System.debug(LoggingLevel.ERROR,'P04_SECURITY_USER='+JSON.serialize(new Map<String,Object>{'userId'=>ordinary.Id,'username'=>ordinary.Username}));
