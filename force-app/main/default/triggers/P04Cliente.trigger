trigger P04Cliente on Account (before delete) { P04Integridad.borrarCuentas(Trigger.old); }
