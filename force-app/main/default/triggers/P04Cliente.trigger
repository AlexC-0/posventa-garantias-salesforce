trigger P04Cliente on Account (before insert, before update, before delete) {
    P04Autorizacion.cuentas(Trigger.isDelete?Trigger.old:Trigger.new,Trigger.isInsert?null:Trigger.oldMap,Trigger.isDelete);
    if(Trigger.isDelete)P04Integridad.borrarCuentas(Trigger.old);
}
