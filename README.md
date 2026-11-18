# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna con datos ficticios y garantía simulada.

## Estado actual

**Sesión 04: seguridad por función implementada y comprobada en P04.** El agente consulta clientes/contactos/productos compartidos y crea o edita sus casos. El responsable gestiona los casos del equipo y corrige clientes, contactos, productos y garantía. Ambos tienen los siete campos de evaluación en solo lectura y carecen de borrado. Sin permisos P04, el usuario no accede a los registros protegidos, aunque sea propietario.

La protección combina perfil mínimo, conjuntos de permisos, compartición privada con reglas de criterios y autorización Apex. No depende de ocultar campos ni de los tipos de registro. No hay ViewAllData/ModifyAllData ni View All/Modify All de objetos en los permisos ordinarios.

Comprobado: despliegue de **56 componentes, 40/40 pruebas Apex**, auditoría de permisos y acceso efectivo, edición UI del agente, garantía y reasignación UI del responsable, denegación de caso ajeno y revocación por URL del caso propio. Las escrituras UI persistieron y se contrastaron con lecturas administrativas. No se presenta esa lectura como una prueba API ordinaria.

Se conservan los ocho registros ficticios de sesión 03 y sus validaciones. Solo se añade Account.P04_Posventa__c como identificador de ámbito: 13 campos propios en total. Los casos siguen sin evaluar. Los dos casos temporales de seguridad se eliminaron y la fecha de garantía modificada para la prueba volvió a su valor original.

No están implementados el motor de evaluación, ciclo completo, asignación automatizada, cola, informes ni LWC. No hay prueba REST con autenticación ordinaria independiente ni pruebas de concurrencia. Detalles y límites en SECURITY y STATUS.

## Proyecto y revisión

Carpeta: C:\Users\kaosk\source\repos\posventa-garantias-salesforce.

Repositorio: [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama main. Base de sesión 04: de1bfdb0f413ae750abbe39da83db1d62782c30f, presente en HEAD/origin/main locales y publicado por Alex según el encargo. No se hizo una nueva comprobación de la punta remota. Los resultados nuevos pertenecen al trabajo local y desplegado de sesión 04, no a ese commit ni a CI.

Los cambios quedan **sin staging**; Alex realiza commit y push. API 68.0; alias explícito p04-posventa-dev, sin destinos predeterminados. Se conservan CLI 2.158.7, extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13, sin reinstalación en esta sesión ni cambios a Java 8.

## Documentación y demostración

- [Estado, resultados y propuesta de commit](docs/STATUS.md).
- [Seguridad, matriz, compartición y límites](docs/SECURITY.md).
- [Despliegue y pruebas reproducibles](docs/TESTING.md).
- [Modelo y contratos](docs/DATA_MODEL.md).
- [Alcance V1](docs/PROJECT_BRIEF.md).
- [Evidencia histórica del entorno](docs/ENVIRONMENT.md).
- [Reglas de trabajo](AGENTS.md).

En P04 Posventa, el administrador conserva la muestra P04 DEMO: dos clientes, dos contactos, dos productos y dos casos. El caso revisado se titula **P04 DEMO - Caso revisado desde interfaz**; el producto Norte conserva la serie **P04-FICT-N1-REV**. Identificadores solo en .local, fuera de Git. No duplicar la muestra.

El usuario de pruebas queda activo con perfil mínimo, sin rol, permisos P04 ni grupos. La segunda licencia queda ocupada para reutilizarlo secuencialmente; no crear otra cuenta. La próxima fase recomendada es el **servicio único de evaluación de garantía**, sin iniciarla automáticamente. Fuera de alcance: producción, datos reales, comunicaciones reales, compras e integración con otros proyectos.
