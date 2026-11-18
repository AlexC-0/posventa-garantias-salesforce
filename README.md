# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna con datos ficticios y garantía simulada.

## Estado actual

**Sesión 03 completada: primera base funcional desplegada en P04.** Ya se pueden consultar y editar clientes/contactos, productos registrados y casos relacionados desde la aplicación Lightning **P04 Posventa**. Los productos y casos usan tipos de registro propios y validaciones en servidor para relaciones y fechas coherentes, también al escribir por API.

Entregado: 12 campos propios, nueve reglas de validación, protecciones Apex para cambios en padres y borrados, cuatro estados de caso y proceso de soporte, dos layouts y acceso administrativo acotado. Se conservan los datos de origen, los cuatro estados estándar y las asignaciones de layout Master.

Comprobado: despliegue de 36 componentes, **20/20 pruebas Apex**, lotes de 200, cinco comprobaciones API y consulta/edición de producto y caso en la interfaz estándar con persistencia verificada por API. La muestra deja ocho registros ficticios: dos clientes, dos contactos, dos productos y dos casos. Un producto tiene garantía completa y otro incompleta; ambos casos siguen **sin evaluar**.

No están implementados el motor de evaluación, el ciclo completo de atención, la asignación automatizada, la seguridad por función, el informe ni el LWC. Las pruebas administrativas no acreditan permisos de agente/responsable ni concurrencia entre transacciones.

## Proyecto y revisión

Carpeta: C:\Users\kaosk\source\repos\posventa-garantias-salesforce.

Repositorio: [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama main. Base de esta sesión: cierre de entorno 4daa849421a9cfe91746a502cab6c2749eed1f83, publicado por Alex según el encargo y presente en HEAD/origin/main locales. No se atribuyen las comprobaciones nuevas a ese commit ni a CI.

La entrega de sesión 03 queda local y sin staging; Alex realiza commit y push. API 68.0; alias explícito p04-posventa-dev, sin destinos predeterminados. Se conservan CLI 2.158.7, Core/Apex/LWC 68.10.0 y JDK 21.0.13; Java 8 del equipo no cambia.

## Documentación y demostración

- [Estado, resultados, incidencias y propuesta de commit](docs/STATUS.md).
- [Modelo, campos y contratos implementados/futuros](docs/DATA_MODEL.md).
- [Despliegue, pruebas y muestra reproducibles](docs/TESTING.md).
- [Alcance V1](docs/PROJECT_BRIEF.md).
- [Herramientas y evidencia histórica del entorno](docs/ENVIRONMENT.md).
- [Reglas de trabajo](AGENTS.md).

En Salesforce, abrir P04 Posventa y localizar los clientes P04 DEMO, sus contactos, productos y casos. El caso revisado desde la interfaz se titula **P04 DEMO - Caso revisado desde interfaz**; el producto Norte conserva la serie **P04-FICT-N1-REV**. Los identificadores privados están solo en .local, no en Git. No volver a crear la muestra si ya existe.

Siguiente fase: **seguridad por función**, con pruebas secuenciales usando la única plaza Salesforce libre y conservando el administrador. No se crean usuarios ni se inicia esa fase automáticamente. Fuera de alcance: producción, datos reales, comunicaciones reales, compra de licencias e integración con otros proyectos.
