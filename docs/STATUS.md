# Estado — Sesión 01

Fecha: 17 de noviembre de 2026. **Parcialmente preparado**: documentación inicial disponible; entorno Salesforce y viabilidad de organización pendientes.

## Comprobado por Codex

- Entorno Windows de 64 bits. La carpeta propuesta no existía y no se encontraron carpetas equivalentes por nombre posventa/garant/salesforce en el directorio habitual.
- No se encontraron AGENTS.md ni marcadores Git en los directorios superiores de la carpeta propuesta.
- Contexto inicial recibido: Proyecto 03. Solo se comprobó su ubicación y estado Git antes de cambiar de alcance: raíz entrega-fiable-eventos-pedidos, rama main, origin AlexC-0/entrega-fiable-eventos-pedidos, estado `## main...origin/main`, sin cambios. No se leyó ni copió su contenido.
- Herramientas y límites de la inspección registrados en [ENVIRONMENT](ENVIRONMENT.md).
- No se detectó Salesforce CLI ni extensiones Salesforce. Java activo 8; falta un JDK compatible detectado.
- No existe autenticación local en las ubicaciones habituales; organización dedicada no identificada.
- Se contrastaron requisitos con documentación oficial; no se ejecutaron comprobaciones remotas de Salesforce.

## Base local y Git

Ruta: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.

Estado inicial: carpeta inexistente, sin repositorio.
Primera entrega: carpeta documental sin Git. Corrección posterior solicitada expresamente por Alex: Codex ejecutó `git init --initial-branch=main` en esta carpeta. Estado actual: `## No commits yet on main`, seis archivos sin seguimiento y sin staging, índice vacío y ningún remoto. Ningún commit, push o creación remota ejecutado por Codex.

Archivos de la base:

- README.md
- AGENTS.md
- .gitignore
- docs/PROJECT_BRIEF.md
- docs/STATUS.md
- docs/ENVIRONMENT.md

No se genera DX sin CLI. Sin versión de API, dependencias, lockfile, código, metadatos funcionales, CI, datos de aplicación ni pruebas ficticias.

## Verificación de la base

- Inventario: 6 archivos; 5 Markdown y .gitignore.
- Enlaces locales: 6 comprobados, 0 destinos inexistentes. Fuentes oficiales externas consultadas durante la inspección.
- Revisión de contenido: alcance, límites, 12 criterios de aceptación y separación entre evidencia local y futura verificación Salesforce.
- Formato y codificación: 0 señales de espacios al final o caracteres de sustitución.
- Revisión de secretos: 0 coincidencias en patrones de claves privadas, URLs de autenticación, credenciales en URL y asignaciones de tokens; revisión del contenido creado. Es una revisión acotada, no una certificación mediante escáner especializado.
- Exclusiones: autenticación Salesforce, secretos, dependencias, logs, resultados, compilados y configuración local del editor contemplados. Tras la inicialización se comprobó su efecto mediante `git check-ignore` sobre rutas representativas, sin crear secretos ni archivos de prueba.
- `git -c core.autocrlf=false diff --no-index --check -- NUL <archivo>`: 6 archivos comprobados, sin diagnósticos. En comparación no-index, código 1 indica diferencias respecto al archivo vacío; no equivale por sí solo a fallo de formato. El primer control se detuvo al tratar ese código como error; se corrigió el control, sin cambiar la configuración Git.
- Antes de inicializar, `git rev-parse --show-toplevel` devolvía «not a git repository». Tras la corrección devuelve la raíz posventa-garantias-salesforce; `git symbolic-ref --short HEAD` devuelve main, `git remote -v` y `git ls-files --stage` no devuelven entradas. No existe carpeta de proyecto anidada.
- Comprobación final del contexto anterior: `git status --short --branch` sigue en `## main...origin/main`; diff de trabajo e índice vacíos. No se inspeccionaron los proyectos 01/02 ni se escribieron archivos en proyectos anteriores.

No se han ejecutado tests, cobertura, despliegues ni validaciones en Salesforce. No se atribuyen resultados de proyectos anteriores a este proyecto.

## Bloqueos y decisiones pendientes

CLI y extensiones ausentes; Java compatible pendiente. Organización pendiente de alta o identificación/autenticación. Capacidad real, API, objetos, licencias, usuarios y límites sin verificar. Diseño funcional documentado como propuesta, con ambigüedades explícitas en PROJECT_BRIEF.

La preferencia es Developer Edition independiente. No se ha aprobado una alternativa ni la sustitución de objetos estándar.

## Intervención y sesión 02

Alex debe completar los pasos de [ENVIRONMENT](ENVIRONMENT.md): abrir la nueva carpeta, instalar lo que falta, crear o identificar y autenticar una organización dedicada y añadir el repositorio local ya creado a GitHub Desktop para realizar personalmente commit y publicación cuando lo revise.

Sesión 02 recomendada: confirmar estado Git y herramientas, verificar organización/capacidades/licencias solo en lectura con destino explícito y preparar estructura DX mínima con API contrastada. Resolver impedimentos antes de autorizar la implementación. No avanzar automáticamente al modelo, permisos, Flow, Apex o LWC.

## Propuesta para GitHub Desktop

Convención propuesta ante ausencia de otra especificada: Conventional Commits con descripción en castellano.

Summary: `docs(inicio): preparar alcance y entorno del proyecto de posventa`

Description:

- Documenta la V1, reglas propuestas, criterios de aceptación y límites de la sesión inicial.
- Añade instrucciones operativas, exclusiones Git y diagnóstico del entorno.
- Registra los requisitos pendientes de Salesforce CLI, extensiones, JDK y organización independiente.
- No incluye aplicación, generación DX, pruebas de producto ni despliegues.
