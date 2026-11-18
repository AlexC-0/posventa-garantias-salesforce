trigger P04Caso on Case (before insert, before update, before delete) {
    P04Autorizacion.casos(Trigger.isDelete?Trigger.old:Trigger.new,Trigger.isInsert?null:Trigger.oldMap,Trigger.isDelete);
    if(Trigger.isUpdate)P04Integridad.actualizarCasos(Trigger.new,Trigger.oldMap);
}
