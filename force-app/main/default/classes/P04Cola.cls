/** Solo comprobaciones de autorización; no expone datos de casos ni concede acceso. */
public without sharing class P04Cola {
    private static Id identificador;
    public static Id idCola(){
        if(identificador==null){
            List<Group> rows=[SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName='P04_Entrada' WITH SYSTEM_MODE];
            if(!rows.isEmpty())identificador=rows[0].Id;
        }
        return identificador;
    }
    /** Contrato reproducible: usuarios directos o los dos grupos públicos P04, sin roles ni grupos anidados. */
    public static Set<Id> miembros(Set<Id> candidatos){
        Set<Id> result=new Set<Id>(),grupos=new Set<Id>();
        if(candidatos.isEmpty()||idCola()==null)return result;
        for(GroupMember m:[SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:idCola() WITH SYSTEM_MODE]){
            if(candidatos.contains(m.UserOrGroupId))result.add(m.UserOrGroupId);
            else if(m.UserOrGroupId.getSObjectType()==Group.SObjectType)grupos.add(m.UserOrGroupId);
        }
        if(!grupos.isEmpty())for(GroupMember m:[SELECT UserOrGroupId FROM GroupMember
            WHERE GroupId IN :grupos AND Group.DeveloperName IN ('P04_Agentes','P04_Responsables')
            AND UserOrGroupId IN :candidatos WITH SYSTEM_MODE])result.add(m.UserOrGroupId);
        return result;
    }
    public static Set<Id> habilitados(Set<Id> candidatos){
        Set<Id> miembros=miembros(candidatos),result=new Set<Id>();
        if(!miembros.isEmpty())for(PermissionSetAssignment p:[SELECT AssigneeId FROM PermissionSetAssignment
            WHERE AssigneeId IN :miembros AND Assignee.IsActive=true
            AND PermissionSet.Name IN ('P04_Agente','P04_Responsable') WITH SYSTEM_MODE])result.add(p.AssigneeId);
        return result;
    }
}
