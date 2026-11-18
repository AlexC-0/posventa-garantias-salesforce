# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna con datos ficticios y garantía simulada.

## Estado actual

**Sesión 07 completada: consulta LWC integrada en la ficha P04.** El panel separa producto/fechas actuales de la evaluación registrada y permite navegar a un máximo de cinco casos relacionados accesibles. La página propia conserva detalles y acciones de evaluación, propietario y cierre; solo se asigna a P04 Posventa, tipo Case P04 y perfiles previstos, en escritorio.

Sin evaluar, Pendiente de datos y evaluación histórica son estados distintos. En abiertos con fechas modificadas se avisa de reevaluación antes del cierre; los cerrados conservan su instantánea. **Actualizar solo consulta:** después de evaluar o editar hay que pulsarlo para recuperar datos nuevos. El panel no calcula cobertura ni escribe.

P04ConsultaCaso aplica compartición explícita y USER_MODE, incluidos CRUD/FLS, ámbito y relaciones. El producto se resuelve desde el caso autorizado. Los relacionados se limitan en servidor tras aplicar acceso; sin recuentos de ocultos. Los errores no exponen detalles internos y las respuestas tardías no sustituyen el registro actual.

Comprobado: **106/106 pruebas Apex** en cinco suites secuenciales y **23/23 pruebas Jest**. Demostración real con usuario ordinario: sin evaluar, relacionado visible y navegación, evaluación mediante la acción existente, actualización explícita, producto corregido frente a instantánea conservada y opcional ausente. Panel revisado a dos anchos, sin desbordamiento horizontal propio en el estrecho. Evidencias y límites en STATUS.

Se conserva el ciclo publicado en sesión 06: alta ordinaria a cola, toma autorizada, gestión individual, evaluación explícita y cierre en servidor. Ocho originales preservados; tres casos y un producto temporales eliminados. Usuario reutilizable sin concesiones adicionales y Login As restaurado. No hay nuevas cuentas persistentes, Gmail ni comunicaciones.

## Proyecto y entrega

Ruta: C:\Users\kaosk\source\repos\posventa-garantias-salesforce.

Repositorio [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama main. Inicio limpio en eca51b8e12a8af438859f80e214eca3a5497f602, sesión 06 publicada por Alex según el encargo y coincidente con HEAD/origin/main locales. Sin nueva consulta de la punta remota. Los resultados actuales son del árbol local desplegado, no de ese commit ni de CI.

Cambios sin staging; Alex hace staging, commit y push. API 68.0 y destino explícito p04-posventa-dev. CLI 2.158.7 y herramientas Salesforce/Java conservadas. Node 24.13.0, npm 11.6.2; único paquete raíz privado y runner oficial sfdx-lwc-jest 8.0.0 con lockfile. Dependencias de desarrollo locales, sin instalaciones globales.

## Uso y documentación

Abrir P04 Posventa → caso P04 → **Consulta de posventa**. Ejecutar **Evaluar garantía** en **Gestión del caso**, desplegando Create new... si está contraída, y pulsar **Actualizar** en el panel después de confirmar. Los casos relacionados se abren por su número. Puede ser necesaria una recarga completa tras desplegar la asignación de página.

- [Consulta, seguridad, estados y demostración](docs/CONSULTA.md).
- [Resultados, incidencias, limpieza y commit](docs/STATUS.md).
- [Pruebas y despliegue reproducibles](docs/TESTING.md).
- [Ciclo y cierre](docs/CICLO.md).
- [Servicio único de garantía](docs/GARANTIA.md).
- [Modelo](docs/DATA_MODEL.md) y [seguridad por función](docs/SECURITY.md).
- [Alcance V1](docs/PROJECT_BRIEF.md), [entorno histórico](docs/ENVIRONMENT.md) e [instrucciones](AGENTS.md).

El informe de pendientes y el cierre global V1 quedan para otro encargo. No se han añadido integraciones ni se declara producción, concurrencia real, prueba móvil o nueva autenticación REST ordinaria. La sesión termina para revisión y publicación manual de Alex.
