trigger P04Caso on Case (before update) { P04Integridad.actualizarCasos(Trigger.new, Trigger.oldMap); }
