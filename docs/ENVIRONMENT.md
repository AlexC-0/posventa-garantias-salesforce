# Entorno y preparación

Este documento registra las comprobaciones iniciales del entorno, anteriores a la implementación funcional. Los despliegues y pruebas posteriores están en [STATUS](STATUS.md), [DATA_MODEL](DATA_MODEL.md) y [TESTING](TESTING.md); las afirmaciones históricas de ausencia de componentes no describen ya el estado actual.

Fecha de cierre: 18 de noviembre de 2026. **Preparación completada dentro del alcance acordado.** La evidencia local y la inspección remota permiten comenzar el diseño del modelo; no acreditan todavía una aplicación, pruebas funcionales ni un despliegue.

Proyecto: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.

## Resultado de la preparación inicial

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

Los nombres de permisos de la tabla llevan el prefijo API Permissions. Los permisos de Apex y metadatos, junto al acceso de lectura a Metadata API, verifican los requisitos administrativos observables; **en esta comprobación inicial no se desplegaron componentes ni ejecutaron tests**. Los indicadores falsos se conservan sin modificar permisos. Manage Flow habilitado acredita gestión de flujos, no que cualquier flujo futuro sea ejecutable por cualquier usuario. Report y ReportType están disponibles por API y el administrador tiene RunReports/CreateCustomizeReports; no se declara probado el diseñador de informes de Lightning.

Esta lectura de permisos no prueba acceso ordinario a flujos ni uso del diseñador de informes. Las comprobaciones funcionales posteriores se registran en STATUS. Referencias oficiales: [permisos de Metadata API](https://developer.salesforce.com/docs/platform/api-metadata/guide/meta-metadata-perm.html), [permisos efectivos del usuario](https://developer.salesforce.com/docs/platform/object-reference/references/standard-objects/object-userpermissionaccess.html) y [acceso granular a Flow](https://help.salesforce.com/s/articleView?id=platform.flow_distribute_security.htm&language=en_US&type=5). No se deduce una prueba funcional a partir de esos permisos.

## Licencias y límites

UserLicense confirma licencias activas:

| Licencia | Total | Usadas | Libres |
| --- | --- | --- | --- |
| Salesforce | 2 | 1 | 1 |
| Salesforce Platform | 3 | 0 | 3 |
| Salesforce Integration | 1 | 0 | 1 |
| Identity | 10 | 0 | 10 |

La disponibilidad inicial permitió conservar el administrador y reservar la segunda plaza Salesforce para escenarios secuenciales de agente, responsable y sin permisos. Ambas plazas están ocupadas al cierre de V1, como registra STATUS. No caben tres usuarios ordinarios completos simultáneos. Platform/Identity no se asumen sustitutos para trabajar con Case. Las pruebas administrativas no sustituyen las pruebas ordinarias.

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

## Autenticación del entorno

Autenticación web oficial completada con salida 0 y correspondencia de organización confirmada. Dos intentos anteriores caducaron con AuthTimeoutError. El nombre de usuario de Salesforce se contrastó con la organización dedicada; no debe confundirse con el correo receptor. Contraseña y MFA se gestionan exclusivamente en el navegador oficial. Gmail queda fuera del acceso autorizado.

Si es necesario renovar la autenticación, comprobar primero la identidad del destino y que el alias esté libre o corresponda a P04:

```powershell
sf org login web --alias p04-posventa-dev --instance-url https://login.salesforce.com
```

No añadir `--set-default` ni `--set-default-dev-hub`. Completar el acceso en el navegador oficial y contrastar la organización antes de operar.

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

## Histórico — Preparación y diagnóstico anteriores al cierre

El contenido siguiente conserva los estados y pendientes que existieron durante la preparación. Los resultados y acciones vigentes son los de las secciones anteriores; los intentos caducados no son tareas actuales.

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

La preparación incluyó las herramientas de la tabla; Node, npm y Java 8 se conservaron.

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

La plantilla generó sourceApiVersion 68.0. La compatibilidad se contrastó posteriormente mediante REST y Metadata API en el entorno dedicado.

Comprobación local ejecutada:

```powershell
sf project list ignored --source-dir force-app --json
```

Resultado: solo force-app/main/default/.gitkeep ignorado. JSON de proyecto válido; packageDirectories apunta al directorio existente force-app. Sin componentes, manifiesto con comodines, CI vacía, pruebas ficticias ni despliegues.

.gitignore separa autenticación (.sf/.sfdx), herramientas y diagnósticos (.local), plantilla temporal (.dx-staging), configuración de editor (.vscode), dependencias y resultados. sfdx-project.json, .forceignore y futuros metadatos bajo force-app son versionables.

### Diagnóstico del alta y alternativa adoptada

El alta directa devolvió HTTP 400 con «Monocle Validation Failed indicating potential fraud». No se determinó su causa ni se acredita su resolución. Se detuvieron los reintentos; no se reprodujeron solicitudes fuera del flujo oficial ni se eludió el control.

Se adoptó un Playground nuevo y dedicado a P04, aprovisionado el 18/11/2026. Su identificador se contrastó entre Trailhead, Setup, autenticación y Organization. Salesforce documenta que un [Trailhead Playground es una Developer Edition](https://trailhead.salesforce.com/content/learn/modules/trailhead_playground_management/create-a-trailhead-playground) y su [guía de desarrollo](https://trailhead.salesforce.com/content/learn/projects/get-started-with-salesforce-development/get-ready-to-develop) utiliza ese entorno con CLI, VS Code, Apex y LWC. La disponibilidad concreta se acredita mediante las lecturas anteriores, no solo mediante documentación general.

El entorno incluye datos y paquete de formación, tiene capacidad limitada y requiere actividad. No se reutilizaron otras organizaciones. Los diagnósticos de navegador, descargas y autenticaciones permanecen fuera de Git.

### Fuentes oficiales

- [Instalación de Salesforce CLI](https://developer.salesforce.com/docs/platform/sfdx-setup/guide/sfdx-setup-install-cli.html).
- [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode).
- [Configuración Java para Apex](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/java-setup.html).
- [Temurin JDK 21](https://adoptium.net/temurin/releases/?version=21&os=windows&arch=x64).
- [Generador oficial de plantillas DX](https://github.com/salesforcecli/plugin-templates).
