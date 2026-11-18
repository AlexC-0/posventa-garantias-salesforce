# Entorno y preparación — Sesión 02

Fecha de cierre: 18 de noviembre de 2026. **Preparación completada dentro del alcance acordado.** La evidencia local y la inspección remota permiten comenzar el diseño del modelo; no acreditan todavía una aplicación, pruebas funcionales ni un despliegue.

Proyecto: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.

## Resultado vigente

- Herramientas conservadas: Salesforce CLI 2.158.7, Node v24.13.0, VS Code 1.146.0 y extensiones Core/Apex/LWC 68.10.0. JDK Temurin 21.0.13+9 operativo; Java predeterminado 1.8.0_503 conservado. No se reinstalaron ni cambiaron configuraciones globales en este cierre.
- Apex/JDK: proceso Java de la ventana de P04 vinculado al JDK 21 local, activación por sfdx-project.json y carga/indexación inicial completadas a las 15:21:47. Workspace vacío: cero archivos Apex, objetos personalizados o archivos con error. No se probó autocompletado interactivo ni compilación remota.
- Organización nueva P04 Posventa Garantías: Playground dedicado, Developer Edition, IsSandbox=false. Identificador coincidente entre Trailhead, Setup, resultado de autenticación y consulta Organization. No se reutiliza el Playground anterior.
- Autenticación web oficial completada con salida 0 y alias p04-posventa-dev. Usuario activo, perfil System Administrator, licencia Salesforce. target-org y target-dev-hub permanecen sin configurar; todas las operaciones remotas usan destino explícito. No se publican identificadores personales, dominios privados ni archivos de autenticación.
- API 68.0 compatible. GET /services/data/ devuelve 68.0 como Winter '27 y también como Latest Release; basta que exista una coincidencia. Metadata API y REST v68.0 responden correctamente. sourceApiVersion conserva 68.0: deja de ser provisional sin cambiar el JSON.

## Capacidades y permisos observados por API

| Comprobación | Resultado de lectura |
| --- | --- |
| Account, Contact, Asset, Case | custom=false; queryable, createable, updateable y deletable=true para el usuario administrador conectado |
| Relaciones relevantes | Contact.AccountId; Asset.AccountId y ContactId; Case.AccountId, ContactId y AssetId |
| Propietario de Case | OwnerId admite Group y User; asignación real a una cola aún no implementada ni probada |
| Tipos habilitados por Metadata API | ApexClass, ApexTrigger, Flow, LightningComponentBundle, Queue, Report, ReportType, PermissionSet y CustomObject |
| Permisos efectivos verdaderos en UserPermissionAccess | ApiEnabled, AuthorApex, ModifyMetadata, ModifyAllData, CustomizeApplication, ViewSetup, ManageInteraction (Manage Flow), RunReports, CreateCustomizeReports y LightningExperienceUser |
| Indicadores efectivos falsos | RunFlow y CreateReportInLightning (Report Builder de Lightning Experience) |

Los nombres de permisos de la tabla llevan el prefijo API Permissions. Los permisos de Apex y metadatos, junto al acceso de lectura a Metadata API, verifican los requisitos administrativos observables; **no se han desplegado componentes ni ejecutado tests**. Los indicadores falsos se conservan sin modificar permisos. Manage Flow habilitado acredita gestión de flujos, no que cualquier flujo futuro sea ejecutable por cualquier usuario. Report y ReportType están disponibles por API y el administrador tiene RunReports/CreateCustomizeReports; no se declara probado el diseñador de informes de Lightning.

El acceso por flujo, los permisos de los usuarios ordinarios y el uso del diseñador de informes se concretarán y verificarán en sus encargos funcionales. Referencias oficiales: [permisos de Metadata API](https://developer.salesforce.com/docs/platform/api-metadata/guide/meta-metadata-perm.html), [permisos efectivos del usuario](https://developer.salesforce.com/docs/platform/object-reference/references/standard-objects/object-userpermissionaccess.html) y [acceso granular a Flow](https://help.salesforce.com/s/articleView?id=platform.flow_distribute_security.htm&language=en_US&type=5). No se deduce una prueba funcional a partir de esos permisos.

## Licencias y límites

UserLicense confirma licencias activas:

| Licencia | Total | Usadas | Libres |
| --- | --- | --- | --- |
| Salesforce | 2 | 1 | 1 |
| Salesforce Platform | 3 | 0 | 3 |
| Salesforce Integration | 1 | 0 | 1 |
| Identity | 10 | 0 | 10 |

Propuesta para probar permisos sin compras: conservar el administrador y utilizar la segunda plaza Salesforce en escenarios secuenciales de agente, responsable y sin permisos. Concretar identidades, activación/desactivación, propiedad y sesiones antes de implementarlos; no se crean usuarios ahora. No caben tres usuarios ordinarios completos simultáneos. Platform/Identity no se asumen sustitutos para trabajar con Case. Las pruebas con administrador no sustituyen estas pruebas futuras.

GET /services/data/v68.0/limits devuelve, en la lectura del 18/11/2026:

| Límite | Máximo | Restante en esa lectura |
| --- | --- | --- |
| DailyApiRequests | 15.000 | 14.994 |
| DataStorageMB | 5 MB | 5 MB |
| FileStorageMB | 20 MB | 20 MB |
| DailyAsyncApexExecutions | 250.000 | 250.000 |
| ConcurrentAsyncGetReportInstances | 200 | 200 |
| DailyWorkflowEmails | 405 | 405 |
| SingleEmail | 15 | 15 |

Los restantes son una instantánea anterior a terminar las comprobaciones, no una reserva ni una cifra final. Los límites de correo no autorizan comunicaciones reales. No se prueba carga ni se infiere capacidad ilimitada. El Playground incluye el paquete y datos de formación propios de su aprovisionamiento; no se añadieron ejemplos ni configuración de negocio.

## Recuperación del acceso

El rechazo Monocle del alta directa no se ha resuelto ni se atribuye a una causa concreta. Se utilizó la alternativa oficial de Playground nuevo después de explicar sus límites; Alex realizó su creación. Los correos de recuperación mostrados inicialmente por Alex pertenecían al Playground anterior. Se identificó el error de destino, se abrió Get Your Login Credentials del entorno nuevo y Alex completó personalmente su contraseña.

Después se aclaró que el correo receptor no era el nombre de usuario de acceso de la organización. Dos intentos CLI anteriores caducaron con AuthTimeoutError; el intento posterior al uso del usuario correcto terminó con salida 0 y correspondencia de organización confirmada. La sesión 02 ya no está bloqueada por el acceso. No se leyó la contraseña ni se cambió la pregunta de seguridad; Gmail queda fuera del acceso autorizado.

## Comprobaciones reproducibles de lectura

Después de la autenticación web y de verificar identidad, usar siempre el destino explícito:

```powershell
sf data query --target-org p04-posventa-dev --query 'SELECT Id, OrganizationType, IsSandbox FROM Organization' --json
sf api request rest '/services/data/' --target-org p04-posventa-dev --method GET --json
sf org list metadata-types --target-org p04-posventa-dev --api-version 68.0 --json
sf sobject describe --sobject Account --target-org p04-posventa-dev --json
sf sobject describe --sobject Contact --target-org p04-posventa-dev --json
sf sobject describe --sobject Asset --target-org p04-posventa-dev --json
sf sobject describe --sobject Case --target-org p04-posventa-dev --json
sf data query --target-org p04-posventa-dev --query 'SELECT Name, TotalLicenses, UsedLicenses, Status FROM UserLicense ORDER BY Name' --json
sf data query --target-org p04-posventa-dev --query 'SELECT PermissionsApiEnabled, PermissionsAuthorApex, PermissionsModifyMetadata, PermissionsModifyAllData, PermissionsCustomizeApplication, PermissionsViewSetup, PermissionsManageInteraction, PermissionsRunFlow, PermissionsRunReports, PermissionsCreateCustomizeReports, PermissionsCreateReportInLightning, PermissionsLightningExperienceUser FROM UserPermissionAccess' --json
sf api request rest '/services/data/v68.0/limits' --target-org p04-posventa-dev --method GET --json
sf config get target-org target-dev-hub --json
```

Las consultas de permisos se ejecutaron en dos consultas complementarias tras describir sus campos; arriba se presenta su unión para reproducción. La identidad y el usuario activo se contrastaron con resultados filtrados en memoria. REST --json entrega statusCode/headers/body; se utilizó body para analizar datos y no se imprimieron cabeceras. La primera comprobación local de versiones exigía una coincidencia única y dio falso al recibir dos entradas 68.0; se corrigió a presencia y se confirmó HTTP 200. Ninguno de estos comandos escribe datos funcionales.

## Siguiente paso

Alex revisa y publica manualmente este cierre documental. Sesión 03 propuesta: definir el modelo basado en Account/Contact/Asset/Case, relaciones y campos, precedencia de reglas de garantía, fecha/zona horaria de referencia, cierre con datos inválidos y reevaluación de casos abiertos. Concretar también la estrategia secuencial de usuarios ordinarios. No se ejecuta esta propuesta en la sesión 02.

## Histórico — preparación y diagnóstico anteriores al cierre

El contenido siguiente conserva los estados y pendientes que existieron durante la preparación. Los resultados y acciones vigentes son los de las secciones anteriores; las llamadas a soporte y los intentos caducados no son tareas actuales.

### Herramientas instaladas y verificadas

| Herramienta | Resultado |
| --- | --- |
| Git | 2.56.1.windows.1 |
| VS Code | 1.146.0, x64 |
| Node.js / npm | v24.13.0 / 11.6.2, conservados |
| Salesforce CLI | @salesforce/cli 2.158.7, win32-x64, ejecutada con Node 24.13.0 |
| Salesforce Extension Pack | salesforce.salesforcedx-vscode 68.10.0 instalado |
| Extensiones Apex, Core y LWC | 68.10.0 instaladas |
| Apex Language Server Extension | 0.10.0 instalada; servidor Java independiente comprobado el 18 de noviembre |
| JDK para el proyecto | Temurin 21.0.13+9, java y javac ejecutados correctamente |
| Java predeterminado del equipo | 1.8.0_503, conservado |

La primera inspección de sesión 02 detectó herramientas ausentes. Alex autorizó después expresamente su instalación por Codex. No se actualizaron Node, npm ni Java 8.

El instalador Windows oficial de Salesforce no pudo descargarse: el servidor devolvió una página de error. La consulta winget no ofreció la CLI sf oficial actual; no se instalaron paquetes alternativos de terceros ni sfdx antiguo. Se utilizó el método npm oficial, comprobando antes engines Node >=22:

```powershell
npm view @salesforce/cli version engines --json
npm install --global @salesforce/cli@2.158.7 --no-audit --no-fund
sf --version
code --install-extension salesforce.salesforcedx-vscode
```

CLI instalada en el prefijo npm de usuario. No se añadieron dependencias ni lockfile al proyecto. El instalador del Extension Pack añadió sus extensiones dependientes; esto no amplía el alcance funcional ni autoriza funciones de IA.

JDK descargado como ZIP desde Adoptium y extraído en una carpeta de herramientas de usuario fuera del repositorio. SHA256 comprobado contra la API oficial:

`a4dbaa05fca4bd89d84584e58c459bd732efebb1722af80ab13c6516832004f9`

Archivo: OpenJDK21U-jdk_x64_windows_hotspot_21.0.13_9.zip.
Se configuró únicamente `salesforcedx-vscode-apex.java.home` en .vscode/settings.json, ignorado por Git. No se modificaron PATH ni JAVA_HOME de Java. No versionar esa ruta personal.

### Comprobación Apex/JDK del 18 de noviembre

El pendiente de activación registrado el día 17 queda resuelto hasta el arranque e indexación inicial del workspace vacío, sin reinstalar herramientas ni cambiar configuración.

- `code --status` identifica la ventana `[1]` de posventa-garantias-salesforce y su extension-host. El proceso hijo ejecuta `apex-jorje-lsp.jar` de la extensión Apex 68.10.0 mediante el binario del JDK 21 configurado en este proyecto.
- En los registros de esa misma ventana, `exthost.log` registra la activación de Salesforce Core y Apex por `workspaceContains:sfdx-project.json` a las 15:20:59.
- El canal `Apex Language Server` termina de cargar la biblioteca estándar y de explorar el código del workspace a las 15:21:47. Informa de cero archivos Apex, cero objetos personalizados y cero archivos con error. Los 19 objetos estándar enumerados son biblioteca local, no evidencia de objetos disponibles en una organización.
- Evidencia local: `%APPDATA%\Code\logs\20261118T150244\window1\exthost\output_logging_20261118T152048\4-Apex Language Server.log`; se contrastó con el árbol de procesos de esa ventana. Los registros no se copian a Git.
- `java --version` y `javac --version` del JDK configurado devuelven 21.0.13 con salida 0. Java predeterminado sigue informando 1.8.0_503.
- También arranca Apex Language Server Extension 0.10.0, basado en workers JavaScript; no se utiliza ese registro como prueba del JDK.

Esto comprueba reconocimiento DX, activación, uso efectivo del JDK y trabajo inicial del servidor. No acredita compilación/despliegue en Salesforce ni una prueba interactiva de autocompletado o diagnósticos sobre código de negocio. No hizo falta crear archivos Apex temporales.

La consulta inicial de `code --status` encontró una restricción de acceso del entorno de ejecución; se repitió con acceso autorizado y produjo la evidencia anterior. No fue un fallo del JDK. No se modificaron la confianza del workspace, configuración global, PATH ni JAVA_HOME.

### Estructura DX

Generada con la CLI instalada en una carpeta temporal ignorada:

```powershell
sf template generate project --name posventa-garantias-salesforce --template empty --output-dir .dx-staging --json
```

La CLI advierte que project generate es un alias obsoleto; se usó template generate project para la generación real.

Se incorporaron sfdx-project.json y .forceignore de la plantilla, y force-app/main/default/.gitkeep para conservar el directorio vacío en Git. Se añadieron exclusiones locales y del marcador a .forceignore. No se incorporaron el README de ejemplo ni la definición scratch: el destino previsto es una Developer Edition independiente, sin Dev Hub.

**sourceApiVersion: 68.0, provisional**, generada por la plantilla. En la generación inicial todavía no existía una organización confirmada. Ahora existe el Playground dedicado descrito más abajo; su API sigue sin contrastar.

Comprobación local ejecutada:

```powershell
sf project list ignored --source-dir force-app --json
```

Resultado: solo force-app/main/default/.gitkeep ignorado. JSON de proyecto válido; packageDirectories apunta al directorio existente force-app. Sin componentes, manifiesto con comodines, CI vacía, pruebas ficticias ni despliegues.

.gitignore separa autenticación (.sf/.sfdx), herramientas y diagnósticos (.local), plantilla temporal (.dx-staging), configuración de editor (.vscode), dependencias y resultados. sfdx-project.json, .forceignore y futuros metadatos bajo force-app son versionables.

### Navegador y alta de organización

Alex autorizó conectar con su perfil de Chrome exclusivamente para Salesforce. El conector MCP integrado 0.0.69 agotaba el tiempo; se utilizó temporalmente @playwright/cli 0.1.24 con la extensión oficial Playwright 0.5.0 instalada por Alex. Tras la autorización de conexión en el navegador, se accedió al perfil Trailblazer indicado y al alta oficial. No se modificó el perfil ni se reutilizó un Playground. El perfil de formación no demuestra capacidades de una organización.

Alex aceptó las condiciones e intentó el alta personalmente. El servicio ogs.digital.salesforce.com/v1/forms devolvió HTTP 400. En un intento manual observado se extrajo únicamente el error filtrado:

> Monocle API error: Monocle Validation Failed indicating potential fraud

Es un rechazo del control antifraude del alta; no se conoce la señal que lo activó. No implica que se haya demostrado fraude del usuario. No hay confirmación de creación de organización ni autenticación CLI.

Se detuvieron los reintentos y se desconectó la sesión Playwright p04. Al desconectar, la herramienta cerró su pestaña de alta; se reabrió el formulario normalmente en Chrome. Alex aportó después una captura de error genérico en a.sfdcstatic.com/digital/pmp/trial-oops.html tras iniciar sesión, sin Playwright conectado. Esa captura confirma persistencia del problema, pero no aporta una nueva respuesta HTTP ni permite atribuirle una causa concreta.

No se exportaron cookies, autenticaciones ni tokens. Diagnósticos y descargas locales quedan fuera de Git. No reproducir solicitudes de alta fuera de su flujo oficial ni intentar eludir el control antifraude.

Al inicio de la continuación del 18 de noviembre Alex confirmó que no había creado ni activado una organización y que solo tenía abierto su perfil Trailblazer. Este estado precede a la creación del Playground dedicado documentada más abajo. `sf alias list --json` confirma alias p04-posventa-dev ausente; `sf org list auth --json`, cero autenticaciones guardadas; `sf config get target-org target-dev-hub --json`, ambos destinos sin configurar. Salidas filtradas, sin credenciales. No se repitió el alta ni se conectó de nuevo Playwright. El rechazo HTTP 400 pertenece al diagnóstico del día 17, no a una nueva ejecución.

### Organización y comprobaciones pendientes

Antes del intento de alta, sf alias list --json confirmó que p04-posventa-dev estaba libre. sf config get target-org target-dev-hub --json confirmó ambos destinos sin configurar. Las salidas se filtraron; no se estableció ninguna organización ni Dev Hub predeterminados.

| Comprobación | Estado |
| --- | --- |
| Organización independiente, identidad y edición | P04 Posventa Garantías creado por Alex el 18/11/2026; Playground nuevo; identificador coincidente en Trailhead y Setup; Developer Edition |
| Autenticación CLI p04-posventa-dev | Pendiente |
| API 68.0 frente a organización | Provisional, sin contrastar |
| Account, Contact, Asset y Case | Confirmados como objetos estándar desde Object Manager; lectura API pendiente |
| Apex, Flow, LWC, colas e informes | Pendiente de lectura |
| Licencias y plazas de usuarios para pruebas | Setup: Salesforce 2 totales, 1 usada y 1 libre; Platform 3 libres; Integration 1 libre; Identity 10 libres |
| Permisos efectivos de despliegue/tests | Pendiente |
| Límites de API y almacenamiento | Setup muestra máximo de 15.000 solicitudes API/24 h; almacenamiento y límites por API pendientes |

Propuesta de pruebas acorde a las licencias observadas en Setup: conservar la plaza administrativa y usar la otra plaza Salesforce para escenarios secuenciales con usuarios ordinarios de agente, responsable y sin permisos; cerrar sesiones y comprobar permisos en cada escenario. Sus identidades/propiedad de registros y la activación secuencial se concretarán en el diseño posterior. No se prometen tres usuarios completos simultáneos ni pruebas ya ejecutadas. Las plazas Platform e Identity no se consideran sustitutos automáticos para trabajar y cerrar Case. Queda contrastar UserLicense, permisos y asignaciones por API. No crear usuarios ni permisos en este encargo; el administrador no sustituye las pruebas ordinarias.

Cuando Alex complete el acceso al nuevo entorno, volver a comprobar la ocupación del alias, identificar el destino y autenticar mediante navegador (preferir el dominio confirmado de P04):

```powershell
sf org login web --alias p04-posventa-dev --instance-url https://login.salesforce.com
```

No añadir --set-default ni --set-default-dev-hub. Toda consulta posterior usará --target-org p04-posventa-dev. No usar sf org display ni exportar autenticaciones. Contraseña, activación y MFA se completan en navegador.

### Alternativa oficial en preparación — Playground dedicado

Alex descarta la llamada a soporte y pide continuar por una vía técnica. El rechazo del alta directa sigue sin resolverse; el contacto telefónico queda como histórico, no como tarea pendiente de Alex.

Salesforce documenta que un [Trailhead Playground es una Developer Edition](https://trailhead.salesforce.com/content/learn/modules/trailhead_playground_management/create-a-trailhead-playground) con datos y un paquete específico de Trailhead. Su [guía de desarrollo](https://trailhead.salesforce.com/content/learn/projects/get-started-with-salesforce-development/get-ready-to-develop) utiliza un Playground nuevo con CLI, VS Code, Apex y LWC. Se plantea crear uno nuevo reservado exclusivamente para P04; el Playground anterior de formación no se utiliza ni se modifica.

Diferencias y límites antes de adoptarlo: el entorno no parte completamente vacío, puede incluir datos y metadatos de ejemplo, sus licencias y capacidad son limitadas y exige mantener actividad. La documentación de formación no acredita disponibilidad efectiva de Account/Contact/Asset/Case, Flow, colas, informes, permisos de despliegue o API 68.0 en el destino concreto. Esas lecturas siguen siendo obligatorias, igual que la verificación de licencias antes de definir las pruebas de usuarios. No se instalan ejemplos ni se amplía la V1.

Alex pulsó Crear en el formulario preparado y Salesforce completó el aprovisionamiento de `P04 Posventa Garantías` el 18/11/2026. Codex abrió exclusivamente su tarjeta nueva y contrastó el identificador entre Trailhead y Company Information, que muestra Developer Edition. El entorno anterior de formación permanece intacto. El nombre de empresa heredado del perfil no se usa para identificar el destino: se contrasta su identificador de organización. No se modifica ese dato en este encargo.

La sesión Playwright se reconectó con autorización de Alex, limitada al trabajo en Salesforce. Los scripts auxiliares de inspección permanecen en .local ignorado; no se incorporan credenciales ni diagnósticos sin filtrar al repositorio.
#### Acceso y restablecimiento en curso

El alias p04-posventa-dev se volvió a comprobar libre. Se inició `sf org login web` contra el dominio del entorno nuevo, con navegador Chrome, alias explícito y sin --set-default ni --set-default-dev-hub. Solicitó credenciales propias del Playground y caducó con AuthTimeoutError mientras se preparaba la contraseña; no se registra autenticación completada.

Se abrió Get Your Login Credentials para Alex. Tras comunicar que no recibía el correo, Codex comprobó únicamente en Salesforce que el usuario pertenece al perfil System Administrator, tiene licencia Salesforce y una dirección Gmail con verificación pendiente. Deliverability está en All email; no se modificó. En las veinte entradas visibles de Setup Audit Trail no se identificó un restablecimiento; eso no demuestra ausencia de envío. La verificación pendiente tampoco demuestra su causa: Salesforce documenta que el restablecimiento de un usuario interno puede verificar su correo.

Alex informó después de que el enlace llegó a Gmail. Sus capturas posteriores muestran que el usuario y dominio de ese correo y de la pregunta de seguridad corresponden al Playground antiguo. No acreditan un restablecimiento del entorno nuevo. Debe solicitarse desde Get Your Login Credentials de P04 Posventa Garantías, verificando primero el usuario mostrado y usando el correo dirigido a ese mismo usuario. No repetir el flujo del Playground anterior ni intentar adivinar su respuesta de seguridad. Alex completa su contraseña personalmente; no se leen sus campos ni se utilizan enlaces de recuperación compartidos. Se intentó una consulta al conector Gmail para localizar el mensaje, sin obtener correos utilizables. Alex prohibió expresamente ese acceso: se abandonó esa vía y no se continuará por ese canal. La prohibición queda recogida en AGENTS.

La conexión Playwright quedó cerrada durante la revisión posterior, confirmado mediante la lista local de sesiones vacía. No se conoce la causa y no se afirma que Alex completara la contraseña. Después Alex aceptó una nueva conexión. Codex abrió Get Your Login Credentials del entorno dedicado y confirmó, en el marco de esa pantalla, el usuario esperado y el botón Reset My Password. Se dejó delante para que Alex solicite el enlace correspondiente a P04, sin usar el del Playground antiguo. Cuando confirme el acceso, iniciar una autenticación web nueva (la anterior caducó), comprobar identidad y continuar con lecturas por CLI. No exportar cookies, sesiones ni tokens para sustituir ese flujo.

Alex confirmó después haber completado el restablecimiento del entorno correcto. Codex observó Personal Information en el dominio del Playground nuevo; no leyó contraseñas ni respuestas de seguridad. Tras comprobar nuevamente que el alias estaba libre, inició otra autenticación web dirigida a P04. El segundo intento terminó con AuthTimeoutError, código de salida 1, sin confirmación de autorización. No se inició otro automáticamente. Una sesión abierta de navegador no acredita autenticación de CLI; queda retomar el flujo cuando Alex pueda completar esa pantalla.

### Histórico: consulta de soporte del 18 de noviembre

No se ha encontrado en las fuentes oficiales consultadas un procedimiento público específico que resuelva el mensaje Monocle. Se conserva el diagnóstico y se solicita orientación de Salesforce. No hay resolución confirmada ni plazo conocido.

**Ruta consultada por Alex:** [Salesforce Help](https://help.salesforce.com/s/?language=en_US), iniciando sesión con la cuenta Trailblazer de Alex. En el selector de contexto elegir **Trailhead**, si está disponible, y abrir **Help Agent / Ask Agentforce**. Las [FAQ oficiales de Trailhead](https://help.salesforce.com/s/articleView?id=000388013&language=en_US&type=1) indican ese contexto para consultar a su equipo de soporte. Aquí se solicita orientación o derivación sobre el alta independiente; no se afirma que Trailhead gestione el control antifraude de Developer Edition.

El acceso ordinario a soporte de producto depende de licencias y planes; la [guía de soporte](https://help.salesforce.com/s/articleView?id=000384365&language=en_US&type=1) excluye el chat humano para organizaciones gratuitas/de prueba. No se presupone un derecho de Alex a abrir casos ni se le pide una organización que todavía no tiene. Las capturas aportadas por Alex el 18 de noviembre confirman que pudo consultar a Help Agent. La respuesta visible de Agentforce (15:31) deriva al teléfono de soporte y cita el artículo 000390297; no muestra un caso creado ni una revisión humana del rechazo.

**Derivación telefónica indicada por Help Agent, descartada por Alex.** Se contrastó el [artículo citado sobre Developer Edition](https://help.salesforce.com/s/articleView?id=000390297&language=en_US&type=1): excluye la creación de casos desde Help para esa edición y remite a soporte telefónico. Su procedimiento contempla disponer de Org ID; Alex aún no lo tiene. Por tanto, la derivación es una vía para solicitar revisión u orientación, no una garantía de alta ni una confirmación de que se haya aceptado su solicitud.

El [directorio oficial de teléfonos](https://help.salesforce.com/s/articleView?id=customer-support-phone-numbers&language=en_US&type=1), consultado el 18 de noviembre, publica **900 997 355** para España, gratuito desde España, en español e inglés. Para español en EMEA indica lunes a viernes, **09:00–17:30 CET** (hora peninsular española en noviembre). Si solicitan Org ID, explicar que el alta falló antes de crear la organización; no usar el identificador de un Playground u otra organización.

Guion breve: «Help Agent me remite a este teléfono. No puedo crear una Developer Edition: recibo HTTP 400 con Monocle Validation Failed indicando potential fraud. Solo tengo perfil Trailblazer y no dispongo de Org ID porque el alta no se ha completado. ¿Podéis revisar el rechazo o derivarme al equipo responsable del alta?». Tener disponibles para el interlocutor oficial el correo usado, fecha 17/11/2026, país España y mensaje del error. No incorporarlos al repositorio. Pedir una referencia de atención y el siguiente paso oficial si pueden facilitarlo. No se ha realizado la llamada ni consta desbloqueo.

**Alternativa comunitaria si soporte no puede tramitar la consulta:** la comunidad oficial de Salesforce admite la cuenta Trailblazer existente sin licencia de Slack. Entrar desde [Trailblazer Community](https://trailhead.salesforce.com/trailblazer-community), seguir el acceso oficial a la comunidad en Slack y consultar en el canal de Developers disponible. La [FAQ de transición](https://help.salesforce.com/s/articleView?id=005461278&language=en_US&type=1) explica el acceso y que los foros web están en modo lectura desde el 30 de octubre: no intentar publicar en el foro antiguo. Es ayuda comunitaria para localizar el equipo adecuado, no un ticket ni garantía de desbloqueo. El acceso con la cuenta de Alex y el nombre exacto del canal no se han probado. Si no aparece el acceso de la transición, conservar ese impedimento y solicitar orientación desde Help; no inventar una invitación ni comprar soporte.

**Asunto para el envío manual:** `Alta de Developer Edition bloqueada por Monocle — sin organización creada`.

**Texto preparado para Alex:**

> No puedo crear una Developer Edition independiente para un proyecto personal de desarrollo. El 17/11/2026, desde el alta oficial developer.salesforce.com/signup, con país España y condiciones aceptadas, recibí HTTP 400 y «Monocle API error: Monocle Validation Failed indicating potential fraud». Un intento manual posterior, sin conexión de automatización al navegador, mostró trial-oops.html después del inicio de sesión. El 18/11/2026 sigo sin organización creada o activada; únicamente accedo a mi perfil Trailblazer y no tengo una organización para abrir un caso. ¿Podéis indicar el canal encargado de revisar este rechazo o el procedimiento oficial para completar el alta? No solicito reutilizar un Playground.

Adjuntar, si se solicita, solo una captura recortada del error. Codex no ha enviado mensajes ni abierto casos; Alex realiza cualquier contacto posterior; su consulta inicial a Help Agent ya está acreditada por las capturas. No cambiar identidad, repetir automáticamente el alta ni reproducir solicitudes del formulario. Creación, condiciones, activación, contraseña y MFA siguen a cargo de Alex en el navegador oficial.

Una vez resuelto: identificar la organización dedicada, volver a comprobar el alias, autenticar por web sin predeterminados y ejecutar las lecturas de la tabla anterior. La sesión 02 y el comienzo del modelo siguen pendientes hasta completar esas comprobaciones.

### Fuentes oficiales

- [Instalación de Salesforce CLI](https://developer.salesforce.com/docs/platform/sfdx-setup/guide/sfdx-setup-install-cli.html).
- [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode).
- [Configuración Java para Apex](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/java-setup.html).
- [Temurin JDK 21](https://adoptium.net/temurin/releases/?version=21&os=windows&arch=x64).
- [Generador oficial de plantillas DX](https://github.com/salesforcecli/plugin-templates).
- [Alta Developer Edition](https://developer.salesforce.com/signup). La pantalla observada advierte de posible terminación tras 45 días de inactividad; no se ha comprobado una política dentro de una organización.
- [Acceso a ayuda de Salesforce y Developer Community](https://help.salesforce.com/s/articleView?id=000380292&language=en_US&type=1).
