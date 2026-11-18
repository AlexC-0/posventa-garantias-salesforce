trigger P04Producto on Asset (before insert, before update, before delete) {
    P04Autorizacion.productos(Trigger.isDelete?Trigger.old:Trigger.new,Trigger.isInsert?null:Trigger.oldMap,Trigger.isDelete);
    if(Trigger.isUpdate)P04Integridad.actualizarProductos(Trigger.new,Trigger.oldMap);
    else if(Trigger.isDelete)P04Integridad.borrarProductos(Trigger.old);
}
