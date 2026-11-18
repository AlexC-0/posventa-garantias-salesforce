# Estado — Sesión 03 completada

18 de noviembre de 2026. Primera base funcional implementada, desplegada y comprobada en P04. El usuario ya puede trabajar con los datos ficticios relacionados desde la interfaz estándar. Evaluación de garantía, ciclo completo y seguridad por función siguen pendientes.

## Git y alcance

Ruta y raíz: C:\Users\kaosk\source\repos\posventa-garantias-salesforce. Rama main; origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

Inicio: árbol limpio y HEAD/origin/main locales en 4daa849421a9cfe91746a502cab6c2749eed1f83, cierre de sesión 02 publicado por Alex según el encargo. Ese commit se comprobó en el historial local; no se ha hecho una lectura nueva de la punta remota. Los resultados siguientes pertenecen al trabajo posterior, no a ese commit ni a CI. Codex no realiza staging, commits ni push.

El encargo de sesión 03 autoriza implementación, despliegue acotado y datos ficticios exclusivamente en P04. Antes de escribir se contrastó Organization y, antes de asignar el permiso, la identidad de sesión del administrador esperado. Sin otras organizaciones, destinos predeterminados, usuarios nuevos ni acceso a Gmail.

## Implementación y despliegue

Manifiesto explícito manifest/sesion03.xml, 36 componentes y 11 tipos de metadatos:

| Elemento | Cantidad | Resultado |
| --- | --- | --- |
| Campos propios | 12 | Dos de garantía en Asset y diez en Case, incluidos campos futuros de evaluación/resolución |
| Reglas de validación | 9 | Obligatoriedad, coherencia de relaciones, intervalo, incidencia y estados |
| Tipos de registro y proceso | 2 + 1 | Asset.P04_Producto, Case.P04_Posventa y proceso de soporte propio |
| CaseStatus | 1 | Cuatro valores P04 añadidos, conservando New/Working/Escalated/Closed |
| Layouts y aplicación | 2 + 1 | Consulta/edición estándar; app P04 Posventa |
| Permiso y perfil | 1 + 1 | P04_DemoAdmin asignado solo al administrador; Admin contiene solo asignaciones de los layouts P04 |
| Apex | 2 clases + 4 triggers | Guardián de integridad y pruebas; sin motor de evaluación |

Despliegue completo final: Succeeded, 36 componentes, cero errores de componentes, 20 tests completados y cero errores. Después se desplegó un único ajuste de visibilidad de la pestaña Asset en P04_DemoAdmin: Succeeded, un componente, sin cambios de Apex. La nueva navegación quedó comprobada visualmente.

Los layouts Master y sus asignaciones predeterminadas de Asset y Case permanecen iguales a la referencia previa. No se recuperaron masivamente metadatos ni se usaron destructivos. Los valores CaseStatus se recuperaron y conservaron antes de ampliarlos. Detalles del modelo en [DATA_MODEL](DATA_MODEL.md).

## Comprobaciones reales

| Prueba | Esperado | Obtenido |
| --- | --- | --- |
| Recorrido Account → Contact → Asset → Case | Guardado coherente, evaluación vacía | Correcto |
| Obligatoriedad de cliente/contacto/producto/incidencia/asunto | Rechazo sin guardar | Correcto |
| Contacto o producto de otro cliente; producto ajeno a P04 | Rechazo | Correcto |
| Fin anterior al inicio | Rechazo; igualdad admitida | Correcto |
| Garantía incompleta y contacto opcional en Asset | Admitidos, sin evaluación implícita | Correcto |
| Incidencia futura o anterior a compra | Rechazo; hoy y día de compra admitidos | Correcto |
| Edición inválida | Conservar los valores anteriores | Correcto |
| Cambios de cliente/compra en padres utilizados | Rechazar si rompen las relaciones o fechas | Correcto |
| Borrados de padres referenciados | Rechazo; eliminación ordenada propia admitida | Correcto |
| Registros ajenos al ámbito P04 | No aplicar las restricciones P04 | Correcto en fixtures aislados |
| Estados P04 y ámbito | Valores propios; Cerrado con IsClosed; impedir salida de ámbito | Correcto, con distinción entre rechazo nativo y guardián |
| 200 casos válidos | 200 inserciones y 200 ediciones | Correcto |
| 200 casos mixtos | 100 éxitos y 100 rechazos esperados | Correcto |
| 200 contactos + 200 productos con casos | Rechazar 400 cambios incoherentes | Correcto |
| API directa | Crear/editar; rechazar fecha futura/contacto ajeno; conservar valores; limpiar caso temporal | 5/5 comprobaciones |
| Interfaz estándar | Consultar y editar producto/caso; comprobar persistencia por API | Correcto: serie y asunto actualizados |

Suite P04ModeloTest: **20/20**, sin SeeAllData. El despliegue informa 70/70 ubicaciones cubiertas en P04Integridad y 1/1 en cada trigger: 74/74, 100 % de esas ubicaciones; no equivale a cobertura de todas las funcionalidades futuras. Las pruebas de integridad usan modo sistema explícito y no acreditan CRUD/FLS de usuarios ordinarios.

La prueba de salida de ámbito distingue: null no cambia el tipo; Master puede rechazarse por la plataforma antes del trigger. Se comprueba el rechazo DML y la conservación del tipo y, por separado, se invoca el guardián y se comprueba su error específico. No se atribuye al trigger un rechazo nativo.

Interfaz: app y layouts consultados con Playwright, edición de serie por el control inline de Asset y asunto por el formulario estándar de Case. Se abrieron controles por su evento DOM cuando fallaron las coordenadas. Los primeros intentos de guardar con clic DOM no persistieron, incluso después de Tab, y no se contaron como éxito. La comprobación final confirmó el valor y el indicador de edición, enfocó el botón Save y lo activó con Enter. La lectura posterior por API confirma serie P04-FICT-N1-REV y asunto P04 DEMO - Caso revisado desde interfaz, con evaluación todavía vacía. No se atribuye la causa exacta a Salesforce ni se omite su validación.

## Datos y evidencia

Quedan ocho registros de demostración: dos Account, dos Contact, dos Asset y dos Case. AccountNumber P04-S03-DEMO-A/B identifica la muestra; no hay correos reales en los contactos. Se conservaron la muestra y los datos de origen. La última lectura cuenta 2 productos P04 y 2 casos P04 activos, cero cuentas P04 TEST y cero casos temporales P04 API activos. Las pruebas Apex revierten sus fixtures; Test-Api elimina solo su propio caso temporal. No se purga la papelera.

Límites finales observados: almacenamiento de datos máximo 5 MB y restante 5 MB según la unidad/redondeo del endpoint; API máximo 15000, restante 14755 en esa lectura. Los valores restantes son una instantánea, no una reserva. Se conservan dos licencias Salesforce, una libre para la fase de permisos.

Evidencia local ignorada: s03-deploy-6.json, s03-api-results.json, s03-layout-checks.json, s03-nav-deploy.json y s03-final-remote.json dentro de .local. s03-demo.json contiene identificadores privados y nunca se versiona. El [procedimiento reproducible](TESTING.md) separa despliegue, tests, API y demostración.

## Incidencias corregidas y límites

- Referencias del proceso de soporte corregidas a las etiquetas de CaseStatus; los registros y las fórmulas usan nombres API. Se desplegaron estados/proceso por separado durante el diagnóstico; los intentos completos fallidos se revirtieron.
- Layout Case corregido para incluir SuppliedEmail y mantener OwnerId editable, no Required. La muestra no envía comunicaciones.
- Apex 68.0 aplica modo usuario por defecto. Fixtures y consultas internas del guardián pasan a modo sistema explícito para verificar integridad, sin conceder permisos amplios a nuevos usuarios.
- Prueba de tipo corregida para distinguir null, Master y el rechazo propio del guardián.
- Pestaña Asset añadida al permiso administrativo tras detectar su ausencia en navegación.
- Se resolvieron selectores ocultos y confirmación de campos en Lightning. Windows rechazó temporalmente nuevos procesos con error 5; después volvió a permitir la ejecución, sin desactivar protecciones ni cambiar configuración global. El conector MCP antiguo probado como alternativa era incompatible con la extensión; se abandonó y se continuó con la CLI compatible ya instalada.

Se verifican operaciones secuenciales y lotes, no concurrencia entre transacciones ni fusiones/undelete. La cuenta administrativa puede tener privilegios superiores a los campos configurados como Readonly; no se considera protección de roles. El motor de garantía, transiciones, cierre completo, asignación, informe y LWC no están implementados. La condición de cierre con Pendiente_datos se mantiene como contrato futuro; la evaluación no se precarga.

## Archivos, revisión y siguiente fase

Modificados: AGENTS, README, PROJECT_BRIEF, ENVIRONMENT y STATUS. Nuevos: DATA_MODEL, TESTING, 36 XML de metadatos, seis fuentes Apex/triggers, manifest/sesion03.xml y cinco archivos de scripts. No cambian sfdx-project.json, .gitignore ni .forceignore; API 68.0 y herramientas se conservan.

Al retomar el cierre había tres documentos modificados y los archivos funcionales pendientes; se conservaron. Estado final: main...origin/main, cinco archivos modificados y 50 nuevos, todos sin staging. HEAD continúa en 4daa849; no se ha ejecutado commit ni push.

Revisión local sobre los 59 archivos versionables, incluidos los nuevos: 37 XML válidos (36 metadatos y manifiesto), correspondencia exacta de los 36 componentes en 11 tipos, cuatro scripts PowerShell analizados sin errores, 15 enlaces Markdown locales resueltos, 11 exclusiones privadas y cinco rutas versionables comprobadas. Sin caracteres de sustitución, coincidencias con los patrones de datos privados revisados ni espacios finales; git diff --check satisfactorio. Esto no constituye un escaneo exhaustivo de secretos. No se repitió la suite remota tras cambios exclusivamente documentales; el resultado Apex procede del despliegue real indicado arriba. Evidencia local: .local/s03-local-review.json.

Alex revisa, realiza staging, commit y push; después se contrasta su publicación. Siguiente fase: **seguridad por función**, con pruebas secuenciales para agente, responsable y sin permisos compatibles con una sola plaza Salesforce libre. No se inicia automáticamente.

Summary: feat: implementar el modelo inicial de posventa y sus validaciones

Description:

- Incorpora campos, relaciones, tipos de registro, estados y presentación administrativa sobre Account, Contact, Asset y Case.
- Valida coherencia y fechas en servidor y protege cambios de padres y borrados en el ámbito P04.
- Despliega el conjunto acotado y comprueba 20 pruebas Apex, lotes de 200, API y edición real en la interfaz estándar.
- Conserva una muestra ficticia de ocho registros y documenta reproducción, límites y seguridad por función como siguiente fase.

## Histórico — Sesión 02 cerrada, publicada en 4daa849


Fecha: 18 de noviembre de 2026. **Entorno preparado para comenzar el diseño del modelo.** Herramientas operativas, integración inicial Apex/JDK comprobada, organización dedicada identificada y autenticada, API 68.0 contrastada y capacidades/limitaciones documentadas. No hay un bloqueo conocido para iniciar la sesión 03; su ejecución requiere el encargo correspondiente. Sin implementación funcional, pruebas de producto ni despliegues.

### Git y publicación

Ruta y raíz Git: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Rama main; origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

La continuación del 18 de noviembre comenzó con árbol limpio; al retomar la comprobación final ya había cuatro documentos modificados sin staging. Se conservaron y completaron. HEAD y referencia local origin/main permanecen en `a9e7a9677232d36908a7d57e790abee0f93ed01d`. El conector GitHub confirmó la existencia de [a9e7a96](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/a9e7a9677232d36908a7d57e790abee0f93ed01d), `chore: preparar herramientas y estructura Salesforce DX`; esa comprobación no establece una nueva lectura de la punta remota actual.

Ese commit publicado por Alex contiene la preparación anterior. Las comprobaciones de este cierre son posteriores y no se atribuyen a ese commit ni a CI. Estado local de entrega: main...origin/main, cuatro documentos modificados, sin archivos nuevos ni staging. Alex realiza exclusivamente staging, commit y push.

### Problemas resueltos y evidencia

- **Apex/JDK:** VS Code 1.146.0 reconoce el proyecto DX y activa Core/Apex 68.10.0. Árbol de procesos y registros de la ventana P04 vinculan ApexLanguageServerLauncher con Temurin 21.0.13+9. El canal Apex Language Server finaliza biblioteca e indexación inicial a las 15:21:47, con cero archivos Apex/objetos personalizados/archivos con error. java/javac terminan con salida 0. No se probó autocompletado interactivo ni compilación remota; Java predeterminado 1.8.0_503 se conserva.
- **Organización:** el alta directa rechazada por Monocle queda histórica y sin causa concreta conocida. Tras explicar la alternativa, Alex creó P04 Posventa Garantías como Playground nuevo. Su identidad coincide entre Trailhead, Setup, autenticación y consulta API Organization; Developer Edition, IsSandbox=false. El Playground anterior no se reutiliza.
- **Contraseña y usuario:** las capturas de los primeros correos correspondían al Playground antiguo. Se abrió la pantalla de credenciales del nuevo; Alex completó su contraseña. Después se corrigió el uso del correo receptor como nombre de usuario, proporcionando el usuario real de la organización. No se leyeron contraseñas ni respuestas de seguridad. Gmail queda expresamente fuera de acceso en AGENTS.
- **CLI:** tras dos intentos caducados, autenticación web oficial completada con salida 0 y organización esperada. Alias p04-posventa-dev comprobado libre antes de conectarlo. Usuario activo con perfil System Administrator y licencia Salesforce. target-org y target-dev-hub siguen sin configurar; todas las lecturas usan destino explícito.
- **API:** REST devuelve API 68.0, publicada como Winter '27 y Latest Release; HTTP 200. Metadata API describe correctamente los tipos en 68.0. sourceApiVersion conserva 68.0, ahora contrastada. La validación inicial que esperaba una única entrada se corrigió al observar las dos etiquetas para la misma versión.

Herramientas conservadas: Git 2.56.1.windows.1, Node v24.13.0, npm 11.6.2, Salesforce CLI 2.158.7, VS Code 1.146.0, Core/Apex/LWC 68.10.0 y Temurin JDK 21.0.13+9. También está instalada Apex Language Server Extension 0.10.0; su servidor JavaScript no se usa como evidencia del JDK. No hubo reinstalaciones ni cambios de configuración global en este cierre.

### Organización: capacidades y límites

- Account, Contact, Asset y Case descritos por API como estándar; consulta y CRUD disponibles para el administrador. Relaciones principales confirmadas, incluido Case.OwnerId con Group/User. No se crearon ni consultaron registros de negocio.
- Nueve tipos de metadatos relevantes habilitados: ApexClass, ApexTrigger, Flow, LightningComponentBundle, Queue, Report, ReportType, PermissionSet y CustomObject.
- UserPermissionAccess confirma ApiEnabled, AuthorApex, ModifyMetadata, ModifyAllData, CustomizeApplication, ViewSetup, ManageInteraction, RunReports, CreateCustomizeReports y LightningExperienceUser. RunFlow y CreateReportInLightning figuran falsos y no se cambian. Se documenta la diferencia entre gestión de Flow, acceso específico de futuros flujos y diseñador Lightning de informes. Permisos observados no equivalen a despliegues ni tests ejecutados.
- UserLicense: Salesforce 2/1/1, Platform 3/0/3, Integration 1/0/1 e Identity 10/0/10 (totales/usadas/libres), todas activas. Conservar administrador y proponer pruebas secuenciales de agente/responsable/sin permisos con la otra plaza Salesforce. No caben los tres simultáneamente; Platform/Identity no sustituyen automáticamente la licencia para Case. Identidades, activación, propiedad de registros y sesiones se concretarán antes de probar; no se crean usuarios ahora.
- Límites API observados: 15.000 solicitudes/24 h, 5 MB de datos, 20 MB de archivos y 250.000 ejecuciones Apex asíncronas diarias. Instantánea y otros límites en [ENVIRONMENT](ENVIRONMENT.md). No se prueba carga ni se autorizan comunicaciones reales.

La lectura de tipos y permisos verifica disponibilidad administrativa para el trabajo futuro. Las pruebas funcionales, el acceso de usuarios ordinarios, los flujos concretos, el diseñador de informes y el despliegue reproducible pertenecen a los encargos posteriores. No impiden comenzar el diseño del modelo y no se presentan como ya resueltos.

### Verificación y archivos

Archivos modificados: AGENTS.md, README.md, docs/ENVIRONMENT.md y docs/STATUS.md. AGENTS refleja la prohibición de Gmail y el estado de cierre; los otros documentos registran resultados, límites e históricos. PROJECT_BRIEF, sfdx-project.json, .gitignore, .forceignore y el marcador de fuente se conservan. Sin nuevas dependencias, código funcional ni configuración del editor.

Comprobaciones locales finales: nueve archivos versionados revisados; siete enlaces internos válidos y cero rotos; cero archivos con coincidencias en los patrones acotados de secretos/identificadores privados o caracteres de sustitución. Once de once rutas locales/de autenticación ignoradas y cuatro de cuatro rutas DX versionables. JSON válido, API 68.0 contrastada, paquete force-app existente y un único archivo fuente: el marcador .gitkeep. Cero archivos en staging y git diff --check correcto. Las lecturas remotas anteriores terminaron con estado 0; las solicitudes REST contrastadas respondieron HTTP 200. No se ejecutaron suites, despliegues ni CI.

La evidencia Apex/JDK conserva su alcance de arranque e indexación inicial. Durante el diagnóstico hubo restricciones del sandbox y avisos de las envolturas PowerShell; las lecturas autorizadas y ejecuciones directas posteriores dieron los resultados descritos. No se añadió safe.directory global ni se modificaron credenciales de otras tareas. Autenticaciones y diagnósticos permanecen fuera de Git.

### Intervención de Alex y siguiente paso

No queda ninguna intervención de acceso pendiente. Revisar los cuatro documentos y realizar staging, commit y push manuales desde GitHub Desktop; después contrastar el commit publicado. No se declara publicado este cierre antes de hacerlo.

Sesión 03 propuesta: concretar campos/relaciones sobre Account, Contact, Asset y Case; resolver precedencia de errores de garantía, fecha y zona horaria de referencia, cierre con datos inválidos y reevaluación explícita de abiertos; definir evaluaciones cerradas inmutables y estrategia secuencial de usuarios para permisos. Esta sesión no se ha ejecutado ni se inicia automáticamente.

### Propuesta para GitHub Desktop

Summary: `docs: cerrar la preparación del entorno Salesforce`

Description:

- Registra la comprobación de Apex con JDK 21 en el proyecto y conserva Java 8.
- Documenta la organización dedicada, la recuperación del acceso y la autenticación web de Salesforce CLI.
- Contrasta API 68.0, objetos estándar, tipos de metadatos, permisos administrativos, licencias y límites mediante lecturas remotas.
- Conserva el diagnóstico anterior como histórico y recoge la prohibición de acceder a Gmail.
- Cierra la sesión 02 y propone el modelo de datos para la siguiente sesión, sin funcionalidades, tests de producto ni despliegues.

### Histórico — entrega del 17 de noviembre, publicada en a9e7a96

El texto siguiente conserva el estado y las comprobaciones anteriores a esa publicación. Su propuesta de commit ya fue utilizada por Alex; sus pendientes locales Apex/JDK quedan actualizados arriba.

Fecha: 17 de noviembre de 2026. **Parcialmente preparado**. Herramientas instaladas y estructura DX mínima creada. El alta de la organización independiente está bloqueada por una respuesta de Salesforce; el entorno no está listo para implementar el modelo.

#### Git y evidencia de publicación

Ruta: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Rama main, remoto origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

La sesión 02 comenzó con árbol limpio y HEAD/origin/main locales en `d90c2286b9103aedf03a636567403c8369a2572d`, título `docs: preparar alcance y entorno del proyecto de posventa`. La continuación conservó los cuatro cambios documentales aún sin staging.

La publicación de Alex se contrastó mediante el conector GitHub: existen main y [d90c228](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/d90c2286b9103aedf03a636567403c8369a2572d). git ls-remote falló por Schannel SEC_E_NO_CREDENTIALS; no se modificaron credenciales ni remotos. La referencia local origin/main no sustituye una lectura actual de la punta remota.

Los cambios y verificaciones siguientes son posteriores al commit publicado. Codex no realizó staging, commits, push, tags ni publicación.

#### Preparación completada localmente

Alex autorizó expresamente instalar las herramientas y acceder exclusivamente a Salesforce mediante su perfil de Chrome.

- Salesforce CLI 2.158.7 instalada con npm y ejecutada con Node v24.13.0; engines Node >=22 comprobado. El instalador Windows oficial falló al descargar; no se instalaron sustitutos de terceros.
- Salesforce Extension Pack 68.10.0 y extensiones dependientes instalados; Apex/Core/LWC 68.10.0 comprobados.
- Temurin JDK 21.0.13+9: ZIP oficial con SHA256 verificado, java y javac operativos. Java predeterminado 1.8.0_503 conservado.
- JDK configurado solo en .vscode/settings.json, ignorado. No se alteraron PATH ni JAVA_HOME de Java.
- VS Code 1.146.0 abrió una ventana de este proyecto. Integración del servidor Apex con el JDK en este workspace todavía pendiente de comprobar.
- Git 2.56.1.windows.1 y npm 11.6.2 conservados.
- Plantilla DX empty generada mediante sf template generate project. Configuración y directorio fuente vacío incorporados; sin ejemplos, dependencias de proyecto ni configuración scratch.
- API de plantilla 68.0 **provisional**, sin contraste remoto.
- sf project list ignored reconoce únicamente el marcador .gitkeep dentro de force-app. JSON válido y directorio de paquete existente.
- Alias p04-posventa-dev libre en la comprobación; target-org y target-dev-hub sin configurar. Sin autenticación CLI.

Comandos y detalles reproducibles en [ENVIRONMENT](ENVIRONMENT.md).

#### Bloqueo de la organización

La conexión con Chrome funcionó mediante Playwright CLI 0.1.24 y extensión 0.5.0 después de que Alex aceptara la conexión. Se consultó su perfil Trailblazer como contexto de formación; no equivale a una organización de desarrollo.

Alex intentó personalmente el alta oficial. El servicio devolvió HTTP 400 y, en el intento manual observado:

> Monocle API error: Monocle Validation Failed indicating potential fraud

Se conoce el rechazo antifraude, no su causa concreta. Se detuvieron los reintentos y se desconectó Playwright. La herramienta cerró su pestaña de alta al desconectar; se reabrió el formulario normalmente. Alex mostró después el error genérico trial-oops.html tras iniciar sesión, sin Playwright conectado. No hay confirmación de alta completada.

Pendientes: organización/edición, autenticación, API, objetos estándar, capacidades, permisos efectivos, licencias, plazas de usuarios y límites. No hay estrategia de usuarios restringidos validada. No se reutilizó un Playground ni se crearon datos o configuración de negocio.

#### Archivos de la entrega

Modificados: README.md, AGENTS.md, docs/ENVIRONMENT.md y docs/STATUS.md.
Nuevos: sfdx-project.json, .forceignore y force-app/main/default/.gitkeep.

PROJECT_BRIEF.md y .gitignore se conservan. Descargas, plantilla temporal, diagnósticos de navegador y configuración local del editor están ignorados. Sin código funcional, permisos, Flow, Apex, LWC, CI, tests de producto ni despliegues.

#### Verificación local

- Nueve archivos versionados o candidatos revisados; seis enlaces locales válidos, cero rotos.
- git diff --check correcto para cambios existentes y revisión no-index correcta para los tres archivos nuevos.
- Once rutas representativas de autenticación, herramientas, diagnósticos, editor y resultados ignoradas por Git.
- Cuatro rutas DX versionables no excluidas por error.
- Cero coincidencias en los patrones de secretos revisados y cero caracteres de sustitución. Revisión acotada al contenido versionable.
- sfdx-project.json válido, API 68.0 provisional y directorio force-app existente.
- sf project list ignored --source-dir force-app --json: éxito, un marcador .gitkeep ignorado.
- PROJECT_BRIEF.md y .gitignore sin cambios. Cero archivos en staging.
- Estado final: main, cuatro documentos modificados y tres archivos nuevos; HEAD permanece en d90c228. No se ejecutaron pruebas de producto, despliegues ni consultas a una organización Salesforce.

#### Histórico

Sesión 01: se crearon cinco documentos y .gitignore. Codex inicializó Git por petición expresa; Alex publicó después d90c228. El estado anterior «sin commits ni remoto» queda histórico.

Primera parte de sesión 02: se renovó la inspección y se actualizaron cuatro documentos; siete enlaces locales válidos, nueve exclusiones comprobadas, cuatro rutas DX no excluidas, diff --check correcto y ningún archivo en staging. Después Alex autorizó las instalaciones realizadas en esta continuación.

#### Intervención y siguiente paso

Resolver el rechazo del alta mediante los canales oficiales de Salesforce; hay un texto preparado en ENVIRONMENT para envío manual de Alex. No se ha contactado a terceros automáticamente. La creación/activación, contraseña y MFA siguen en navegador.

Una vez exista organización dedicada: comprobar identidad y alias, autenticar, verificar capacidades/licencias solo en lectura y contrastar API 68.0. Comprobar activación Apex/JDK en este workspace antes de declarar el entorno preparado. No avanzar automáticamente a funcionalidades.

#### Propuesta para GitHub Desktop

Summary: `chore: preparar herramientas y estructura Salesforce DX`

Description:

- Incorpora la estructura DX mínima con API 68.0 provisional.
- Registra la instalación y comprobación de Salesforce CLI, extensiones y JDK 21, conservando Java 8.
- Actualiza las instrucciones y documenta el rechazo del alta de Developer Edition.
- Deja pendientes la organización, las licencias, la API remota y la integración Apex/JDK; sin implementación funcional ni despliegues.
