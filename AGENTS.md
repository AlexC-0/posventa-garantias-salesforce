# Instrucciones para Codex — Proyecto 04

## Alcance y entorno

Trabaja exclusivamente en `posventa-garantias-salesforce`. No inspecciones, copies, modifiques ni integres proyectos anteriores. ChatGPT navegador coordina y revisa; Codex trabaja con el entorno real. No existe sincronización automática.

Antes de modificar, confirma ruta, instrucciones aplicables y existencia de Git; si existe, comprueba raíz, rama, remotos y `git status --short --branch`. Conserva cambios del usuario. Lee README.md, docs/PROJECT_BRIEF.md, docs/STATUS.md y docs/ENVIRONMENT.md. Escribe principalmente en castellano.

Encargo vigente — sesión 03: implementar y desplegar exclusivamente en P04 el modelo mínimo Account/Contact/Asset/Case, campos, validaciones de coherencia y presentación administrativa. Se autorizan pruebas reales y una muestra ficticia pequeña, con rollback/limpieza acotada de pruebas. Preservar metadatos y datos de origen. Este encargo sustituye la prohibición temporal de implementación de la sesión 02.

La evaluación automática, ciclo completo, asignación, LWC y seguridad por función quedan para fases posteriores. No crear usuarios. La siguiente fase será seguridad por función con la plaza Salesforce libre. Comprobar identidad antes de escribir; despliegue explícito sin destructivos ni recuperaciones masivas. Documentar diferencias entre pruebas administrativas, despliegue y comportamiento funcional. No declarar coherencia global sin cubrir las actualizaciones de padres y los límites conocidos.

Estado de sesión 03: modelo y validaciones desplegados; 20 pruebas Apex y comprobaciones API/UI administrativas completadas. No atribuir esos resultados a roles ordinarios. La fase siguiente de seguridad requiere un nuevo encargo.

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
