# Entorno y preparación — Sesión 02

Fecha de comprobación: 17 de noviembre de 2026.
Proyecto: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.

## Herramientas instaladas y verificadas

| Herramienta | Resultado |
| --- | --- |
| Git | 2.56.1.windows.1 |
| VS Code | 1.146.0, x64 |
| Node.js / npm | v24.13.0 / 11.6.2, conservados |
| Salesforce CLI | @salesforce/cli 2.158.7, win32-x64, ejecutada con Node 24.13.0 |
| Salesforce Extension Pack | salesforce.salesforcedx-vscode 68.10.0 instalado |
| Extensiones Apex, Core y LWC | 68.10.0 instaladas |
| Apex Language Server Extension | 0.10.0 instalada; no equivale a integración JDK validada |
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

VS Code abrió una ventana para posventa-garantias-salesforce, comprobada mediante code --status. La presencia de las extensiones, los binarios Java y la configuración del workspace están comprobados. **La activación del servidor Apex con ese JDK dentro de este workspace sigue pendiente**: no se atribuyen logs de otras ventanas al proyecto. Una vez activada la extensión, comprobar Output > Apex y problemas de inicio; no crear componentes ficticios para aparentar esa comprobación.

## Estructura DX

Generada con la CLI instalada en una carpeta temporal ignorada:

```powershell
sf template generate project --name posventa-garantias-salesforce --template empty --output-dir .dx-staging --json
```

La CLI advierte que project generate es un alias obsoleto; se usó template generate project para la generación real.

Se incorporaron sfdx-project.json y .forceignore de la plantilla, y force-app/main/default/.gitkeep para conservar el directorio vacío en Git. Se añadieron exclusiones locales y del marcador a .forceignore. No se incorporaron el README de ejemplo ni la definición scratch: el destino previsto es una Developer Edition independiente, sin Dev Hub.

**sourceApiVersion: 68.0, provisional**, generada por la plantilla. La organización todavía no existe de forma confirmada; no se ha contrastado esta API con Salesforce.

Comprobación local ejecutada:

```powershell
sf project list ignored --source-dir force-app --json
```

Resultado: solo force-app/main/default/.gitkeep ignorado. JSON de proyecto válido; packageDirectories apunta al directorio existente force-app. Sin componentes, manifiesto con comodines, CI vacía, pruebas ficticias ni despliegues.

.gitignore separa autenticación (.sf/.sfdx), herramientas y diagnósticos (.local), plantilla temporal (.dx-staging), configuración de editor (.vscode), dependencias y resultados. sfdx-project.json, .forceignore y futuros metadatos bajo force-app son versionables.

## Navegador y alta de organización

Alex autorizó conectar con su perfil de Chrome exclusivamente para Salesforce. El conector MCP integrado 0.0.69 agotaba el tiempo; se utilizó temporalmente @playwright/cli 0.1.24 con la extensión oficial Playwright 0.5.0 instalada por Alex. Tras la autorización de conexión en el navegador, se accedió al perfil Trailblazer indicado y al alta oficial. No se modificó el perfil ni se reutilizó un Playground. El perfil de formación no demuestra capacidades de una organización.

Alex aceptó las condiciones e intentó el alta personalmente. El servicio ogs.digital.salesforce.com/v1/forms devolvió HTTP 400. En un intento manual observado se extrajo únicamente el error filtrado:

> Monocle API error: Monocle Validation Failed indicating potential fraud

Es un rechazo del control antifraude del alta; no se conoce la señal que lo activó. No implica que se haya demostrado fraude del usuario. No hay confirmación de creación de organización ni autenticación CLI.

Se detuvieron los reintentos y se desconectó la sesión Playwright p04. Al desconectar, la herramienta cerró su pestaña de alta; se reabrió el formulario normalmente en Chrome. Alex aportó después una captura de error genérico en a.sfdcstatic.com/digital/pmp/trial-oops.html tras iniciar sesión, sin Playwright conectado. Esa captura confirma persistencia del problema, pero no aporta una nueva respuesta HTTP ni permite atribuirle una causa concreta.

No se exportaron cookies, autenticaciones ni tokens. Diagnósticos y descargas locales quedan fuera de Git. No reproducir solicitudes de alta fuera de su flujo oficial ni intentar eludir el control antifraude.

## Organización y comprobaciones pendientes

Antes del intento de alta, sf alias list --json confirmó que p04-posventa-dev estaba libre. sf config get target-org target-dev-hub --json confirmó ambos destinos sin configurar. Las salidas se filtraron; no se estableció ninguna organización ni Dev Hub predeterminados.

| Comprobación | Estado |
| --- | --- |
| Organización independiente, identidad y edición | Sin alta confirmada |
| Autenticación CLI p04-posventa-dev | Pendiente |
| API 68.0 frente a organización | Provisional, sin contrastar |
| Account, Contact, Asset y Case | Pendiente de lectura |
| Apex, Flow, LWC, colas e informes | Pendiente de lectura |
| Licencias y plazas de usuarios para pruebas | Pendiente |
| Permisos efectivos de despliegue/tests | Pendiente |
| Límites de API y almacenamiento | Pendiente |

No hay una estrategia de usuarios restringidos validada sin conocer las licencias. Cuando exista la organización, consultar UserLicense y recuentos de usuarios activos sin publicar identidades. Evaluar usuarios ordinarios para agente, responsable y sin permisos. Si no caben simultáneamente, documentar pruebas secuenciales como alternativa antes de aprobarla. No crear usuarios ni permisos durante este encargo. Un administrador no sustituye pruebas de usuarios restringidos.

Cuando Alex confirme el alta/activación, volver a comprobar la ocupación del alias, identificar el destino y autenticar mediante navegador:

```powershell
sf org login web --alias p04-posventa-dev --instance-url https://login.salesforce.com
```

No añadir --set-default ni --set-default-dev-hub. Toda consulta posterior usará --target-org p04-posventa-dev. No usar sf org display ni exportar autenticaciones. Contraseña, activación y MFA se completan en navegador.

## Siguiente paso ante el error

Solicitar orientación o revisión por los canales oficiales de Salesforce, adjuntando el mensaje anterior y la captura sin datos sensibles. No enviar automáticamente mensajes ni solicitudes a terceros. El acceso a casos depende de los derechos de la cuenta; Salesforce también remite a Developer Community para usuarios de Developer Edition.

Texto preparado para que Alex lo envíe manualmente:

> No puedo completar el alta oficial de una Developer Edition independiente para un proyecto personal de desarrollo. El 17 de noviembre de 2026, con país España y condiciones aceptadas, el formulario devolvió HTTP 400 y el mensaje «Monocle API error: Monocle Validation Failed indicating potential fraud». Posteriormente, sin conexión de automatización al navegador, apareció trial-oops.html después del inicio de sesión. ¿Podéis revisar el rechazo o indicarme el procedimiento oficial para completar el alta?

## Fuentes oficiales

- [Instalación de Salesforce CLI](https://developer.salesforce.com/docs/platform/sfdx-setup/guide/sfdx-setup-install-cli.html).
- [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode).
- [Configuración Java para Apex](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/java-setup.html).
- [Temurin JDK 21](https://adoptium.net/temurin/releases/?version=21&os=windows&arch=x64).
- [Generador oficial de plantillas DX](https://github.com/salesforcecli/plugin-templates).
- [Alta Developer Edition](https://developer.salesforce.com/signup). La pantalla observada advierte de posible terminación tras 45 días de inactividad; no se ha comprobado una política dentro de una organización.
- [Acceso a ayuda de Salesforce y Developer Community](https://help.salesforce.com/s/articleView?id=000380292&language=en_US&type=1).
