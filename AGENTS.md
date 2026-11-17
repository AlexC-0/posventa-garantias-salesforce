# Instrucciones para Codex — Proyecto 04

## Alcance y entorno

Trabaja exclusivamente en `posventa-garantias-salesforce`. No inspecciones, copies, modifiques ni integres proyectos anteriores. ChatGPT navegador coordina y revisa; Codex trabaja con el entorno real. No existe sincronización automática.

Antes de modificar, confirma ruta, instrucciones aplicables y existencia de Git; si existe, comprueba raíz, rama, remotos y `git status --short --branch`. Conserva cambios del usuario. Lee README.md, docs/PROJECT_BRIEF.md, docs/STATUS.md y docs/ENVIRONMENT.md. Escribe principalmente en castellano.

Sesión 01: inspección, viabilidad y documentación inicial. No implementar todavía aplicación, modelo, permisos, Flow, Apex ni LWC; tampoco desplegar ni modificar organizaciones. El siguiente encargo debe delimitar la continuación.

## Protección de organizaciones y datos

Preferir Developer Edition independiente si las capacidades reales permiten la V1. No reutilizar automáticamente Playground, organización autenticada ni destino predeterminado. Antes de conectar, confirmar que el destino pertenece a este proyecto y está autorizado; usar alias explícito en cada comando remoto. Un alias por sí solo no prueba la identidad.

No cambiar destinos globales ni configuraciones de otras tareas. No imprimir ni versionar tokens, contraseñas, claves, archivos de autenticación, URLs reutilizables de acceso ni salidas completas que puedan contenerlos. No usar `sf org display` para producir informes ni exportar autenticaciones. Acceso y MFA exclusivamente mediante navegador oficial, nunca credenciales por chat.

Datos de aplicación ficticios y política de garantía simulada. Sin producción, compras de licencias, comunicaciones reales ni integraciones externas. No instalar ni actualizar herramientas globales automáticamente. Documentar los requisitos que falten.

## Diseño y verificación

Account, Contact, Asset y Case son la base propuesta. No sustituirlos por objetos personalizados sin documentar impedimento y alternativa. No presentar capacidades, licencias, API o resultados como verificados sin evidencia de la organización dedicada.

La garantía debe tener una única lógica de evaluación; evitar duplicarla entre Flow, Apex y LWC. Las reglas funcionales y de autorización deberán aplicarse también fuera de la interfaz. Preservar evaluaciones cerradas; reevaluación explícita de abiertos. Estas son obligaciones futuras, no funcionalidades existentes.

Distinguir inspección local, futura CI y pruebas con Salesforce. Jest no prueba permisos ni integración real. No añadir CI vacía, pruebas ficticias o cifras de cobertura sin ejecución. Registrar comandos, resultados reales, límites y pendientes en STATUS. Revisar enlaces, coherencia, exclusiones, secretos y espacios en blanco.

## Git y entregas

Alex realiza exclusivamente staging, commits, push y creación del remoto. A petición expresa posterior de Alex, Codex inicializó este repositorio local en main; esa operación ya está completada. Codex no ejecuta `git add/commit/push`, tags, releases, cambios de remoto, reescritura de historial, publicación ni equivalentes por API. No desplegar sin encargo explícito.

Dejar archivos sin staging. Entregar ruta y estado Git inicial/final, archivos, versiones, comprobaciones y límites, intervención de Alex y siguiente paso.

Convención inicial propuesta: `tipo(ámbito): descripción en castellano`, con tipos como docs, chore, feat, fix o test según el cambio real. No se ha recibido una nomenclatura previa más específica: adaptar si Alex la facilita. La Description explica resultado, verificación y pendientes sin atribuir funcionalidades inexistentes.
