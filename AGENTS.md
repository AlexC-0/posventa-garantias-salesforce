# Instrucciones para Codex — Proyecto 04

## Alcance y entorno

Trabaja exclusivamente en `posventa-garantias-salesforce`. No inspecciones, copies, modifiques ni integres proyectos anteriores. ChatGPT navegador coordina y revisa; Codex trabaja con el entorno real. No existe sincronización automática.

Antes de modificar, confirma ruta, instrucciones aplicables y existencia de Git; si existe, comprueba raíz, rama, remotos y `git status --short --branch`. Conserva cambios del usuario. Lee README.md, docs/PROJECT_BRIEF.md, docs/STATUS.md y docs/ENVIRONMENT.md. Escribe principalmente en castellano.

Encargo vigente — sesión 07: base publicada eca51b8e12a8af438859f80e214eca3a5497f602. Implementar LWC de solo consulta en página Case propia, limitada a aplicación P04, tipo P04 y perfiles correspondientes. Producto/fechas actuales separados de instantánea histórica; aviso de reevaluación en abiertos, sin calcular ni escribir. Relacionados: mismo producto, P04, excluir actual, cinco accesibles como máximo, CreatedDate DESC e Id DESC. Lecturas con CRUD/FLS/compartición efectivos, sin helpers de integridad para devolver datos. Actualización explícita y protección frente a respuestas tardías. Pruebas Jest significativas y Apex de consulta más regresión de las cuatro suites; despliegue y demo con usuario ordinario existente. Preservar ocho originales y restaurar concesiones/ajustes temporales. Alex hace staging, commit y push. Sin informe, integraciones ni cierre global V1; detener al entregar.

Sesión 07 completada: consulta de solo lectura desplegada, 106/106 Apex en ejecución secuencial y 23/23 Jest; demostración ordinaria y restauración documentadas en STATUS. Cambios sin staging, pendientes de revisión/publicación manual de Alex. El informe y cierre global V1 requieren otro encargo.

Sesión 06 completada: 93/93 pruebas (20 modelo, 20 seguridad, 25 garantía, 28 ciclo); cola y ambos Flows activos; recorrido UI ordinario hasta cierre y rechazos comprobados. Ocho originales conservados, temporal eliminado, usuario mínimo sin concesiones y Login Access Policies restaurada a false tras recarga. Detalle y límites en docs/STATUS.md y docs/CICLO.md. Sesión 06 publicada por Alex en eca51b8. La sesión 07 está autorizada por el nuevo encargo.

Los párrafos de sesiones 03–05 siguientes son antecedentes; las menciones a cola/Flow/ciclo pendientes quedan sustituidas por este encargo. No se amplía el resto de autorizaciones.
La evaluación automática e informes quedan fuera. El LWC de consulta forma parte del encargo 07; el ciclo publicado se conserva. No crear más usuarios persistentes ni ampliar privilegios para hacer pasar pruebas. Comprobar identidad antes de escribir; despliegue explícito sin destructivos ni recuperaciones masivas. No conceder ViewAllData, ModifyAllData ni View All/Modify All de objetos a usuarios ordinarios. Separar autorización e integridad; acciones restringidas bajo USER_MODE. No atribuir a un token administrativo una prueba API ordinaria. Conservar la finalidad limitada de P04Integridad en modo sistema.

Estado de sesión 03: modelo y validaciones publicados en de1bfdb; 20 pruebas Apex y comprobaciones API/UI administrativas completadas. No atribuir esos resultados a roles ordinarios. La sesión 04 está autorizada por el encargo posterior; su próxima fase será el servicio único de evaluación, sin iniciarlo automáticamente.

Sesión 04 publicada en 4cfaf0b: 56 componentes desplegados, 40/40 pruebas (20 modelo + 20 seguridad), UI ordinaria y revocación verificadas. Preservar P04_Minimo, permisos/grupos/reglas y guardián de autorización. OWD Account/Asset/Case/Opportunity Private y Contact ControlledByParent; Opportunity es dependencia necesaria de Account. Account.P04_Posventa__c delimita clientes sin convertir datos ajenos.

Usuario persistente de pruebas activo, sin rol, conjuntos P04 ni grupos; cero casos propios activos. Dos licencias Salesforce ocupadas; reutilizar esa cuenta, no crear otra. Ocho registros originales conservados, temporales de sesión 04 eliminados y los de sesión 05 revertidos. Login Access Policies volvió a false al cerrar sesión 04 y no se modificó en sesión 05. No volver a habilitarla sin necesidad del encargo y posterior restauración. No atribuir consultas API administrativas a un usuario ordinario: sesión 04 tuvo UI y Apex USER_MODE; sesión 05 tuvo Apex bajo usuarios aislados y demo administrativa, sin nueva UI/REST ordinaria. En aquel cierre de sesión 04 quedaban pendientes cola y ciclo; sesión 06 ya los implementa. La sesión 07 implementa el LWC de consulta; el informe sigue pendiente. Siguiente paso: revisión y publicación manual de Alex; la fase posterior requiere nuevo encargo.

## Protección de organizaciones y datos

Preferir Developer Edition independiente si las capacidades reales permiten la V1. No reutilizar automáticamente Playground, organización autenticada ni destino predeterminado. Antes de conectar, confirmar que el destino pertenece a este proyecto y está autorizado. Comprobar que el alias p04-posventa-dev no esté ocupado por otra organización antes de autenticar mediante navegador; usar destino explícito en cada comando remoto. Un alias por sí solo no prueba la identidad. La creación de cuenta, activación, contraseña y MFA corresponden a Alex.

Alex ha prohibido acceder a su Gmail: no consultar su correo mediante navegador, conectores ni otras herramientas. Alex gestiona por su cuenta los enlaces de activación/restablecimiento y las respuestas de seguridad. El acceso autorizado a Salesforce no incluye su buzón.

No cambiar destinos globales ni configuraciones de otras tareas. No imprimir ni versionar tokens, contraseñas, claves, archivos de autenticación, URLs reutilizables de acceso ni salidas completas que puedan contenerlos. No usar `sf org display` para producir informes ni exportar autenticaciones. Acceso y MFA exclusivamente mediante navegador oficial, nunca credenciales por chat.

Datos de aplicación ficticios y política de garantía simulada. Sin producción, compras de licencias, comunicaciones reales ni integraciones externas. No instalar ni actualizar herramientas globales automáticamente salvo autorización expresa. En la sesión 02 Alex autorizó a Codex instalar Salesforce CLI, Salesforce Extension Pack y JDK 21; conservar Java 8 y configurar el nuevo JDK solo para este proyecto. También autorizó conectar Playwright a su perfil de Chrome para trabajar exclusivamente en Salesforce. Estas autorizaciones no permiten consultar otras pestañas ni modificar organizaciones ajenas. Documentar versiones, verificaciones y límites reales.

## Diseño y verificación

Account, Contact, Asset y Case son la base implementada de la sesión 03. No sustituirlos por objetos personalizados sin documentar impedimento y alternativa. No presentar capacidades, licencias, API o resultados como verificados sin evidencia de la organización dedicada.

P04Garantia centraliza la evaluación explícita y P04EvaluarGarantiaAccion adapta IDs sin duplicar cálculo. Lecturas USER_MODE, acceso de edición y rol comprobados, escritura SYSTEM_MODE solo de siete campos mediante un contexto privado y predicado sin setter público. No exponer ni hacer TestVisible ese contexto. Lote atómico de hasta 200 solicitudes; duplicados deduplicados para DML, respuestas en el mismo orden. Cerrados rechazados, instantáneas históricas conservadas al editar producto/incidencia y reevaluación solo explícita. La sesión 06 añade Flow, ciclo y cola según CICLO; la sesión 07 incorpora la consulta LWC sin duplicar evaluación; el informe permanece fuera. Detalle en docs/GARANTIA.md. Sesión 05 desplegada con 65/65 pruebas y demo administrativa revertida; no atribuir UI/REST ordinarias nuevas a esa evidencia. Alex debe revisar y publicar los cambios; detenerse sin iniciar la siguiente fase.

Distinguir inspección local, futura CI y pruebas con Salesforce. Jest no prueba permisos ni integración real. No añadir CI vacía, pruebas ficticias o cifras de cobertura sin ejecución. Registrar comandos, resultados reales, límites y pendientes en STATUS. Revisar enlaces, coherencia, exclusiones, secretos y espacios en blanco.

## Git y entregas

Alex realiza exclusivamente staging, commits, push y creación del remoto. A petición expresa posterior de Alex, Codex inicializó este repositorio local en main; esa operación ya está completada. Codex no ejecuta `git add/commit/push`, tags, releases, cambios de remoto, reescritura de historial, publicación ni equivalentes por API. No desplegar sin encargo explícito.

Dejar archivos sin staging. Entregar ruta y estado Git inicial/final, archivos, versiones, comprobaciones y límites, intervención de Alex y siguiente paso.

Convención indicada por Alex: `tipo: descripción en castellano`, sin ámbitos innecesarios como `(inicio)`. Usar docs, chore, feat, fix o test según el cambio real. La Description explica resultado, verificación y pendientes sin atribuir funcionalidades inexistentes.
