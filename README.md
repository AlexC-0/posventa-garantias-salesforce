# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna propuesta para agentes de soporte y una persona responsable, con datos ficticios y una política de garantía simulada.

## Estado actual

**Sesión 02 cerrada — 18 de noviembre de 2026.** Herramientas y arranque/indexación inicial de Apex con JDK 21 comprobados; Java 8 conservado. El Playground nuevo `P04 Posventa Garantías` está identificado como Developer Edition y autenticado por web en Salesforce CLI mediante el alias `p04-posventa-dev`, sin destinos predeterminados. API 68.0 contrastada; Account, Contact, Asset y Case, tipos de metadatos, permisos administrativos, licencias y límites comprobados por API. El alta directa sigue rechazada como antecedente, pero el entorno dedicado alternativo permite comenzar el modelo. Sin implementación funcional, pruebas de producto ni despliegues.

Límites relevantes: dos licencias Salesforce, una usada y una libre; pruebas ordinarias propuestas de forma secuencial. Almacenamiento: 5 MB de datos y 20 MB de archivos; máximo de 15.000 solicitudes API/24 h. Manage Flow está habilitado; los indicadores separados Run Flows y Report Builder (Lightning Experience) figuran desactivados. Los permisos y accesos funcionales concretos se diseñarán y probarán después. Detalles en ENVIRONMENT y STATUS.

Carpeta: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Repositorio: [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama `main`, remoto `origin`. La preparación de herramientas y DX fue publicada por Alex en [a9e7a96](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/a9e7a9677232d36908a7d57e790abee0f93ed01d), comprobado en Git local y mediante el conector GitHub. La continuación del 18 de noviembre actualiza documentación y queda sin staging; Alex realiza commits y push.

## Alcance V1

Clientes y productos registrados, casos vinculados, evaluación de garantía, asignación inicial a cola, seguimiento y cierre, informe de pendientes, un LWC de consulta y permisos por función. Incluye como objetivos futuros pruebas, demostración y despliegue reproducibles.

Quedan fuera portal público, Experience Cloud, comunicaciones reales, OmniChannel avanzado, IA, integraciones externas, conexión con proyectos anteriores, datos reales, compra de licencias y producción.

## Documentación

- [Reglas de trabajo](AGENTS.md).
- [Alcance, diseño propuesto y aceptación](docs/PROJECT_BRIEF.md).
- [Estado y siguiente paso](docs/STATUS.md).
- [Entorno, requisitos y preparación pendiente](docs/ENVIRONMENT.md).

El encargo vigente permite preparar las herramientas, autenticar la organización dedicada, comprobarla en lectura y generar DX mínimo. Las [comprobaciones del entorno](docs/ENVIRONMENT.md) quedan completadas dentro del alcance de lectura. Siguiente paso propuesto, pendiente del encargo de sesión 03: concretar modelo de datos y reglas de garantía. No implementar todavía modelo, permisos, Flow, Apex ni LWC.
