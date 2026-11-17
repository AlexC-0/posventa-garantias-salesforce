# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna propuesta para agentes de soporte y una persona responsable, con datos ficticios y una política de garantía simulada.

## Estado actual

**Parcialmente preparado — sesión 02, 17 de noviembre de 2026.** Salesforce CLI 2.158.7, Salesforce Extension Pack 68.10.0 y JDK 21.0.13 instalados; Java 8 conservado. Estructura DX mínima creada con API 68.0 provisional. El alta de Developer Edition devuelve un rechazo antifraude de Salesforce; no hay organización confirmada ni autenticación. Capacidades, licencias, API remota e integración Apex/JDK pendientes. Sin aplicación, pruebas de producto ni despliegues.

Carpeta: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Repositorio: [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama `main`, remoto `origin`. Base documental publicada por Alex en [d90c228](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/d90c2286b9103aedf03a636567403c8369a2572d), comprobada localmente y mediante el conector GitHub. Los cambios de esta sesión quedan sin staging; Alex realiza commits y push.

## Alcance V1

Clientes y productos registrados, casos vinculados, evaluación de garantía, asignación inicial a cola, seguimiento y cierre, informe de pendientes, un LWC de consulta y permisos por función. Incluye como objetivos futuros pruebas, demostración y despliegue reproducibles.

Quedan fuera portal público, Experience Cloud, comunicaciones reales, OmniChannel avanzado, IA, integraciones externas, conexión con proyectos anteriores, datos reales, compra de licencias y producción.

## Documentación

- [Reglas de trabajo](AGENTS.md).
- [Alcance, diseño propuesto y aceptación](docs/PROJECT_BRIEF.md).
- [Estado y siguiente paso](docs/STATUS.md).
- [Entorno, requisitos y preparación pendiente](docs/ENVIRONMENT.md).

El encargo vigente permite preparar las herramientas, autenticar la organización dedicada, comprobarla en lectura y generar DX mínimo. Completar primero los [pasos del entorno](docs/ENVIRONMENT.md). No implementar todavía modelo, permisos, Flow, Apex ni LWC.
