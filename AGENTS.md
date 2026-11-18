# Instrucciones para Codex — Proyecto 04

## Alcance y entorno

Trabaja exclusivamente en `posventa-garantias-salesforce`. No inspecciones, copies, modifiques ni integres proyectos anteriores. ChatGPT navegador coordina y revisa; Codex trabaja con el entorno real. No existe sincronización automática.

Antes de modificar, confirma ruta, instrucciones aplicables y existencia de Git; si existe, comprueba raíz, rama, remotos y `git status --short --branch`. Conserva cambios del usuario. Lee README.md, docs/PROJECT_BRIEF.md, docs/STATUS.md y docs/ENVIRONMENT.md. Escribe principalmente en castellano.

Encargo vigente — sesión 04: implementar y comprobar seguridad de agente, responsable y usuario sin permisos exclusivamente en P04. Se autorizan metadatos, configuración de compartición y un usuario ordinario persistente en la plaza libre, sin notificaciones ni correos. Preservar administrador, muestra de ocho registros y datos/metadatos de origen. Pruebas secuenciales, revocación efectiva, UI ordinaria y regresión del modelo. Detalle y evidencia en docs/SECURITY.md y STATUS.

La evaluación automática, ciclo completo, asignación, informes y LWC quedan para fases posteriores. No crear más usuarios persistentes ni ampliar privilegios para hacer pasar pruebas. Comprobar identidad antes de escribir; despliegue explícito sin destructivos ni recuperaciones masivas. No conceder ViewAllData, ModifyAllData ni View All/Modify All de objetos a usuarios ordinarios. Separar autorización e integridad; acciones restringidas bajo USER_MODE. No atribuir a un token administrativo una prueba API ordinaria. Conservar la finalidad limitada de P04Integridad en modo sistema.

Estado de sesión 03: modelo y validaciones publicados en de1bfdb; 20 pruebas Apex y comprobaciones API/UI administrativas completadas. No atribuir esos resultados a roles ordinarios. La sesión 04 está autorizada por el encargo posterior; su próxima fase será el servicio único de evaluación, sin iniciarlo automáticamente.

Sesión 04 completada: 56 componentes desplegados, 40/40 pruebas (20 modelo + 20 seguridad), UI ordinaria y revocación verificadas. Cambios locales pendientes de staging, commit y push manuales de Alex. Preservar P04_Minimo, permisos/grupos/reglas y guardián de autorización. OWD Account/Asset/Case/Opportunity Private y Contact ControlledByParent; Opportunity es dependencia necesaria de Account. Account.P04_Posventa__c delimita clientes sin convertir datos ajenos.

Usuario persistente de pruebas activo, sin rol, conjuntos P04 ni grupos; cero casos propios activos. Dos licencias Salesforce ocupadas; reutilizar esa cuenta, no crear otra. Ocho registros originales conservados, dos temporales eliminados y garantía original restaurada. Login Access Policies volvió a false, comprobado tras recarga. No volver a habilitarla sin necesidad del encargo y posterior restauración. No atribuir consultas API administrativas a un usuario ordinario: las pruebas restringidas fueron UI y Apex USER_MODE. Cola, evaluación, ciclo completo, informes y LWC siguen pendientes. Siguiente paso: revisión y publicación manual de Alex; la fase posterior requiere nuevo encargo.

## Protección de organizaciones y datos

Preferir Developer Edition independiente si las capacidades reales permiten la V1. No reutilizar automáticamente Playground, organización autenticada ni destino predeterminado. Antes de conectar, confirmar que el destino pertenece a este proyecto y está autorizado. Comprobar que el alias p04-posventa-dev no esté ocupado por otra organización antes de autenticar mediante navegador; usar destino explícito en cada comando remoto. Un alias por sí solo no prueba la identidad. La creación de cuenta, activación, contraseña y MFA corresponden a Alex.

Alex ha prohibido acceder a su Gmail: no consultar su correo mediante navegador, conectores ni otras herramientas. Alex gestiona por su cuenta los enlaces de activación/restablecimiento y las respuestas de seguridad. El acceso autorizado a Salesforce no incluye su buzón.

No cambiar destinos globales ni configuraciones de otras tareas. No imprimir ni versionar tokens, contraseñas, claves, archivos de autenticación, URLs reutilizables de acceso ni salidas completas que puedan contenerlos. No usar `sf org display` para producir informes ni exportar autenticaciones. Acceso y MFA exclusivamente mediante navegador oficial, nunca credenciales por chat.

Datos de aplicación ficticios y política de garantía simulada. Sin producción, compras de licencias, comunicaciones reales ni integraciones externas. No instalar ni actualizar herramientas globales automáticamente salvo autorización expresa. En la sesión 02 Alex autorizó a Codex instalar Salesforce CLI, Salesforce Extension Pack y JDK 21; conservar Java 8 y configurar el nuevo JDK solo para este proyecto. También autorizó conectar Playwright a su perfil de Chrome para trabajar exclusivamente en Salesforce. Estas autorizaciones no permiten consultar otras pestañas ni modificar organizaciones ajenas. Documentar versiones, verificaciones y límites reales.

## Diseño y verificación

Account, Contact, Asset y Case son la base implementada de la sesión 03. No sustituirlos por objetos personalizados sin documentar impedimento y alternativa. No presentar capacidades, licencias, API o resultados como verificados sin evidencia de la organización dedicada.

La garantía debe tener una única lógica de evaluación; evitar duplicarla entre Flow, Apex y LWC. Las reglas funcionales y de autorización deberán aplicarse también fuera de la interfaz. Preservar evaluaciones cerradas; reevaluación explícita de abiertos. Estas son obligaciones futuras, no funcionalidades existentes.

Distinguir inspección local, futura CI y pruebas con Salesforce. Jest no prueba permisos ni integración real. No añadir CI vacía, pruebas ficticias o cifras de cobertura sin ejecución. Registrar comandos, resultados reales, límites y pendientes en STATUS. Revisar enlaces, coherencia, exclusiones, secretos y espacios en blanco.

## Git y entregas

Alex realiza exclusivamente staging, commits, push y creación del remoto. A petición expresa posterior de Alex, Codex inicializó este repositorio local en main; esa operación ya está completada. Codex no ejecuta `git add/commit/push`, tags, releases, cambios de remoto, reescritura de historial, publicación ni equivalentes por API. No desplegar sin encargo explícito.

Dejar archivos sin staging. Entregar ruta y estado Git inicial/final, archivos, versiones, comprobaciones y límites, intervención de Alex y siguiente paso.

Convención indicada por Alex: `tipo: descripción en castellano`, sin ámbitos innecesarios como `(inicio)`. Usar docs, chore, feat, fix o test según el cambio real. La Description explica resultado, verificación y pendientes sin atribuir funcionalidades inexistentes.
