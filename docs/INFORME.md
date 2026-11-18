# Informe de casos pendientes

En **P04 Posventa → Reports/Informes → All Reports/Todos los informes**, abrir **P04 Casos pendientes**, carpeta **P04 Posventa**. También se encuentra en las carpetas compartidas. La pestaña estándar se incluye en la aplicación y se hace visible al Responsable.

## Contrato

Informe estándar de formato Summary, tipo estándar **Cases / CaseList**. Ese tipo ofrece todas las columnas y filtros necesarios; no se crea un ReportType propio, fórmula de cobertura ni dashboard.

- Tipo de caso `Case.P04_Posventa` y cliente con `Account.P04_Posventa__c=true`.
- Estados Nuevo, En curso y Pendiente de información; además `IsClosed=false`. Cerrado queda fuera.
- Alcance All cases, que incluye cola y personas, siempre sujeto al acceso efectivo del ejecutor. No significa acceso administrativo.
- Apertura **All Time**: rango CUSTOM sin fecha inicial ni final. Tampoco se filtra por incidencia.
- Agrupaciones por estado y después propietario. La cola aparece como **P04 Entrada posventa**, las personas por su nombre; recuentos por grupo y total.
- Detalles: número, asunto, cliente, apertura, incidencia y resultado registrado. Estado y propietario se presentan en las columnas de agrupación: Salesforce rechaza duplicarlos como columnas de detalle.
- Orden de los detalles por apertura ascendente dentro de cada grupo. No se promete un orden global entre grupos ni desempate por otro campo.

El resultado vacío se presenta como `-` en el informe estándar y significa **Sin evaluar**, explicado en su descripción. Pendiente de datos es un resultado registrado distinto. Ejecutar/Refresh vuelve a consultar; no evalúa ni reescribe casos. Los recuentos representan los registros visibles en esa ejecución, no una instantánea garantizada entre operaciones concurrentes.

## Acceso

`reports/P04_Posventa.reportFolder-meta.xml` comparte la carpeta con el grupo público existente `P04_Responsables`, exclusivamente `View`. El conjunto `P04_Responsable` añade `RunReports` y visibilidad de la pestaña estándar. No añade CreateCustomizeReports, administración de carpetas, exportación, suscripciones, View All, Modify All ni nuevas reglas de compartición.

La carpeta habilita el acceso al informe; CRUD/FLS y compartición siguen delimitando sus datos. Las asignaciones de grupo y conjunto se gestionan conjuntamente con `Set-SecurityScenario`; no basta con cambiar un rótulo de la interfaz. Retirar ambas concesiones y volver a cargar la URL debe denegar el acceso. Los datos vistos anteriormente pueden permanecer en una pestaña ya cargada hasta renovar la consulta.

Los campos de agrupación y los ocho conceptos solicitados ya están autorizados por el conjunto vigente. El responsable conserva sus permisos de gestión de casos; ver un control estándar de edición de campos en el visor no concede edición de la definición del informe.

## Metadatos y comprobación

`manifest/sesion08.xml` contiene carpeta, informe, aplicación y conjunto Responsable. Referencias por nombres API, sin IDs privados. El filtro de tipo usa `Case.P04_Posventa` en Metadata API; Analytics lo devuelve como la etiqueta `Caso de posventa`. No sustituirlo por un ID ni confundir ambos formatos.

La definición se contrasta con Analytics `/reports/{id}/describe` y con la interfaz ordinaria. Preparar y registrar antes de ejecutar una muestra con los tres estados abiertos, cola/persona, evaluados/sin evaluar y cerrado. Comparar números de caso, grupos y total; volver a ejecutar después de una transición o cierre. Distinguir originales, temporales y consultas administrativas. Evidencias reales y limitaciones en [STATUS](STATUS.md); recorrido integrado en [DEMO-V1](DEMO-V1.md).

No hay suscripciones, envíos, exportaciones automáticas, filtros temporales implícitos ni configuración manual adicional del informe. Los usuarios/grupos efectivos son datos de configuración del entorno; la definición de carpeta, permisos y navegación está versionada.

Referencias: [Report](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-report.html), [FolderShare y nivel View](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-foldershare.html), [metadatos del tipo de informe](https://developer.salesforce.com/docs/analytics/salesforce-analytics-rest-api/guide/analytics-api-reporttypes-reference-reporttype.html).
