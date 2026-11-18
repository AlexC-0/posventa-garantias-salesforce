trigger P04Producto on Asset (before update, before delete) { if (Trigger.isUpdate) P04Integridad.actualizarProductos(Trigger.new, Trigger.oldMap); else P04Integridad.borrarProductos(Trigger.old); }
