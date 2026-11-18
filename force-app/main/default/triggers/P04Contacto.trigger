trigger P04Contacto on Contact (before insert, before update, before delete) {
    P04Autorizacion.contactos(Trigger.isDelete?Trigger.old:Trigger.new,Trigger.isInsert?null:Trigger.oldMap,Trigger.isDelete);
    if(Trigger.isUpdate)P04Integridad.actualizarContactos(Trigger.new,Trigger.oldMap);
    else if(Trigger.isDelete)P04Integridad.borrarContactos(Trigger.old);
}
