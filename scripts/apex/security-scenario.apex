// Se ejecuta por administración: cambia solo el usuario ordinario identificado.
System.assert(FeatureManagement.checkPermission('P04_Administrar'),'P04: falta autorización administrativa.');
Id expected='__P04_USER__';String scenario='__P04_SCENARIO__';
System.assert(new Set<String>{'Ninguno','Agente','Responsable'}.contains(scenario),'P04: escenario inválido.');
User ordinary=[SELECT Id,Alias,Profile.Name,UserRoleId,IsActive FROM User WHERE Id=:expected WITH USER_MODE];
System.assert(ordinary.Id!=UserInfo.getUserId()&&ordinary.Alias=='p04test'&&ordinary.Profile.Name=='P04_Minimo'&&ordinary.UserRoleId==null&&ordinary.IsActive,'P04: usuario de destino inesperado.');
List<PermissionSetAssignment> assigned=[SELECT Id,PermissionSet.Name,PermissionSetGroupId FROM PermissionSetAssignment
    WHERE AssigneeId=:expected AND PermissionSet.IsOwnedByProfile=false WITH USER_MODE];
for(PermissionSetAssignment assignment:assigned)System.assert(assignment.PermissionSetGroupId==null&&new Set<String>{'P04_Agente','P04_Responsable'}.contains(assignment.PermissionSet.Name),'P04: hay otra fuente de permisos; revisar sin eliminarla.');
Map<String,Id> groups=new Map<String,Id>();for(Group g:[SELECT Id,DeveloperName FROM Group WHERE DeveloperName IN ('P04_Agentes','P04_Responsables') AND Type='Regular' WITH USER_MODE])groups.put(g.DeveloperName,g.Id);
System.assertEquals(2,groups.size(),'P04: faltan grupos.');Set<Id> groupIds=new Set<Id>(groups.values());
List<GroupMember> members=[SELECT Id,GroupId FROM GroupMember WHERE UserOrGroupId=:expected WITH USER_MODE];
for(GroupMember member:members)System.assert(groupIds.contains(member.GroupId),'P04: membresía ajena; revisar sin eliminarla.');
delete as user assigned;delete as user members;
if(scenario!='Ninguno'){
    String name='P04_'+scenario;PermissionSet permission=[SELECT Id FROM PermissionSet WHERE Name=:name WITH USER_MODE];
    insert as user new PermissionSetAssignment(AssigneeId=expected,PermissionSetId=permission.Id);
    insert as user new GroupMember(GroupId=groups.get(scenario=='Agente'?'P04_Agentes':'P04_Responsables'),UserOrGroupId=expected);
}
System.debug(LoggingLevel.ERROR,'P04_SCENARIO_OK='+scenario);
