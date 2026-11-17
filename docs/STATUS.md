# Estado — Sesión 02

Fecha: 17 de noviembre de 2026. **Parcialmente preparado**. Herramientas instaladas y estructura DX mínima creada. El alta de la organización independiente está bloqueada por una respuesta de Salesforce; el entorno no está listo para implementar el modelo.

## Git y evidencia de publicación

Ruta: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Rama main, remoto origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

La sesión 02 comenzó con árbol limpio y HEAD/origin/main locales en `d90c2286b9103aedf03a636567403c8369a2572d`, título `docs: preparar alcance y entorno del proyecto de posventa`. La continuación conservó los cuatro cambios documentales aún sin staging.

La publicación de Alex se contrastó mediante el conector GitHub: existen main y [d90c228](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/d90c2286b9103aedf03a636567403c8369a2572d). git ls-remote falló por Schannel SEC_E_NO_CREDENTIALS; no se modificaron credenciales ni remotos. La referencia local origin/main no sustituye una lectura actual de la punta remota.

Los cambios y verificaciones siguientes son posteriores al commit publicado. Codex no realizó staging, commits, push, tags ni publicación.

## Preparación completada localmente

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

## Bloqueo de la organización

La conexión con Chrome funcionó mediante Playwright CLI 0.1.24 y extensión 0.5.0 después de que Alex aceptara la conexión. Se consultó su perfil Trailblazer como contexto de formación; no equivale a una organización de desarrollo.

Alex intentó personalmente el alta oficial. El servicio devolvió HTTP 400 y, en el intento manual observado:

> Monocle API error: Monocle Validation Failed indicating potential fraud

Se conoce el rechazo antifraude, no su causa concreta. Se detuvieron los reintentos y se desconectó Playwright. La herramienta cerró su pestaña de alta al desconectar; se reabrió el formulario normalmente. Alex mostró después el error genérico trial-oops.html tras iniciar sesión, sin Playwright conectado. No hay confirmación de alta completada.

Pendientes: organización/edición, autenticación, API, objetos estándar, capacidades, permisos efectivos, licencias, plazas de usuarios y límites. No hay estrategia de usuarios restringidos validada. No se reutilizó un Playground ni se crearon datos o configuración de negocio.

## Archivos de la entrega

Modificados: README.md, AGENTS.md, docs/ENVIRONMENT.md y docs/STATUS.md.
Nuevos: sfdx-project.json, .forceignore y force-app/main/default/.gitkeep.

PROJECT_BRIEF.md y .gitignore se conservan. Descargas, plantilla temporal, diagnósticos de navegador y configuración local del editor están ignorados. Sin código funcional, permisos, Flow, Apex, LWC, CI, tests de producto ni despliegues.

## Verificación local

- Nueve archivos versionados o candidatos revisados; seis enlaces locales válidos, cero rotos.
- git diff --check correcto para cambios existentes y revisión no-index correcta para los tres archivos nuevos.
- Once rutas representativas de autenticación, herramientas, diagnósticos, editor y resultados ignoradas por Git.
- Cuatro rutas DX versionables no excluidas por error.
- Cero coincidencias en los patrones de secretos revisados y cero caracteres de sustitución. Revisión acotada al contenido versionable.
- sfdx-project.json válido, API 68.0 provisional y directorio force-app existente.
- sf project list ignored --source-dir force-app --json: éxito, un marcador .gitkeep ignorado.
- PROJECT_BRIEF.md y .gitignore sin cambios. Cero archivos en staging.
- Estado final: main, cuatro documentos modificados y tres archivos nuevos; HEAD permanece en d90c228. No se ejecutaron pruebas de producto, despliegues ni consultas a una organización Salesforce.

## Histórico

Sesión 01: se crearon cinco documentos y .gitignore. Codex inicializó Git por petición expresa; Alex publicó después d90c228. El estado anterior «sin commits ni remoto» queda histórico.

Primera parte de sesión 02: se renovó la inspección y se actualizaron cuatro documentos; siete enlaces locales válidos, nueve exclusiones comprobadas, cuatro rutas DX no excluidas, diff --check correcto y ningún archivo en staging. Después Alex autorizó las instalaciones realizadas en esta continuación.

## Intervención y siguiente paso

Resolver el rechazo del alta mediante los canales oficiales de Salesforce; hay un texto preparado en ENVIRONMENT para envío manual de Alex. No se ha contactado a terceros automáticamente. La creación/activación, contraseña y MFA siguen en navegador.

Una vez exista organización dedicada: comprobar identidad y alias, autenticar, verificar capacidades/licencias solo en lectura y contrastar API 68.0. Comprobar activación Apex/JDK en este workspace antes de declarar el entorno preparado. No avanzar automáticamente a funcionalidades.

## Propuesta para GitHub Desktop

Summary: `chore: preparar herramientas y estructura Salesforce DX`

Description:

- Incorpora la estructura DX mínima con API 68.0 provisional.
- Registra la instalación y comprobación de Salesforce CLI, extensiones y JDK 21, conservando Java 8.
- Actualiza las instrucciones y documenta el rechazo del alta de Developer Edition.
- Deja pendientes la organización, las licencias, la API remota y la integración Apex/JDK; sin implementación funcional ni despliegues.
