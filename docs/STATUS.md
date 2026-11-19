# Estado de V1 y evidencias de verificación

18 de noviembre de 2026. **V1 implementada y preparada para revisión final.** Informe de pendientes implementado y comprobado, recorrido integrado completado y doce criterios relacionados en [ACEPTACION-V1](ACEPTACION-V1.md).

## Entorno de la verificación

Identidad de organización y administrador comprobada antes de escrituras, destino explícito p04-posventa-dev y API 68.0. CLI 2.158.7, Node 24.13.0, npm 11.6.2, runner sfdx-lwc-jest 8.0.0 y herramientas Salesforce/Java existentes conservados. Sin instalaciones nuevas ni cuentas persistentes adicionales; sin comunicaciones ni cambios en otras organizaciones.

## Informe y acceso

Tipo estándar CaseList suficiente para los ocho conceptos solicitados. Formato Summary: estado/propietario como columnas de agrupación, y número, asunto, cliente, apertura, incidencia y resultado como detalles. Orden de apertura ascendente dentro de cada grupo; no se promete orden global entre grupos.

Filtros conjuntos: tipo Case.P04_Posventa, cliente marcado P04, los tres estados abiertos e IsClosed=false. Alcance All cases sujeto al usuario ejecutor, incluidos cola y propietarios individuales. All Time, sin fechas inicial/final ni filtro por incidencia. El resultado vacío se muestra como `-` y significa Sin evaluar; el informe consume la instantánea, no calcula cobertura.

Carpeta propia P04_Posventa con View únicamente para P04_Responsables. P04_Responsable añade RunReports y pestaña Reports; la aplicación incluye esa pestaña. No se añaden edición de informes, administración de carpetas, View All, Modify All, reglas de compartición, dashboards, suscripciones ni exportaciones automáticas. La carpeta no sustituye CRUD/FLS ni acceso a registros. Contrato y referencias en [INFORME](INFORME.md).

Antes de desplegar se recuperaron aplicación y permiso: sin diferencias funcionales inesperadas respecto a la base (el servidor añadía valores false por defecto al permiso). Despliegue final incremental: **cuatro componentes, Succeeded, cero errores**, NoTestRun porque no cambia Apex. Recuperación final y describe de Analytics confirman filtros, agrupaciones, orden y carpeta View. No se modificaron Apex, Flows, LWC, modelo, pruebas ni dependencias.

## Muestra e informe ejecutado como Responsable

Preparación administrativa identificada: un producto temporal, cuatro casos de muestra (Nuevo en cola, En curso evaluado, Pendiente de información sin evaluar y Cerrado), y control ajeno con cliente sin marca P04/contacto/producto/caso propios. El caso del recorrido se creó después mediante UI ordinaria. Se registraron filas, grupos y recuentos esperados mediante consultas administrativas **antes** de las respectivas lecturas del informe. Esas consultas no se atribuyen al usuario ordinario.

| Lectura UI ordinaria | Originales abiertos | Temporales abiertos | Nuevo | En curso | Pendiente de información | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Inicial, muestra preparada | 2 | 3 | 3 | 1 | 1 | **5** |
| Recorrido en Pendiente de información | 2 | 4 | 3 | 1 | 2 | **6** |
| Tras cerrar el recorrido | 2 | 3 | 3 | 1 | 1 | **5** |

En Nuevo: dos originales del administrador y un temporal en cola. En curso y Pendiente pertenecen al usuario ordinario Responsable. Se contrastaron números de caso, grupos, propietarios y totales. El cerrado de muestra queda fuera en las tres lecturas; el control ajeno ya existía en las dos últimas y también queda fuera. El caso cerrado durante el recorrido desaparece de la última lectura.

La UI confirma All Time y apertura oldest-to-newest; Analytics confirma CUSTOM sin extremos. Las incidencias de 2020 siguen visibles, pero **no se preparó un registro con CreatedDate antiguo**: la ausencia de filtro temporal se acredita por definición/UI, sin presentar la incidencia como antigüedad de creación. No se garantiza consistencia entre consultas concurrentes.

Tras retirar conjunto y membresías se volvió a abrir la URL directa del informe con la misma identidad ordinaria y contexto recargado. Ya no mostró definición ni filas: Salesforce redirigió a Analytics y devolvió «sObject type 'Report' is not supported». La aplicación P04 dejó de estar disponible. Es una denegación tras revocación conjunta, no una prueba aislada de retirar solo la carpeta ni una nueva autenticación REST ordinaria.

## Recorrido integrado real

1. Responsable ordinario creó un caso ficticio desde la UI con relaciones válidas. Persistencia contrastada: autor ordinario, Nuevo, propietario cola y Sin evaluar.
2. Tomó el caso para sí mediante Change Owner, sin correo. Editó seguimiento y pasó a En curso: la asignación inicial no sobrescribió el propietario individual.
3. Ejecutó Evaluar garantía y confirmó En cobertura. Antes de Actualizar, el LWC seguía Sin evaluar; después recuperó resultado y siete valores registrados.
4. Administración corrigió solo el fin del producto temporal. Comparación de los cinco casos asociados confirmó estados e instantáneas intactos. Actualizar mostró fechas actuales diferentes y aviso de reevaluación.
5. Intentó cerrar con resolución y explicación válidas: rechazo explícito «los datos han cambiado; reevalúe explícitamente antes de cerrar». El caso siguió abierto, con propietario e instantánea anteriores.
6. Reevaluó mediante la acción existente: Fuera de cobertura. Actualizar recuperó las nuevas fechas utilizadas y el resultado. Pasó a Pendiente de información; el informe mostró seis abiertos y dos en ese grupo.
7. Cerró desde Pendiente con Atención fuera de cobertura y explicación ficticia. Persistencia confirmó Cerrado, propietario/autor ordinarios y evaluación conservada. Después se corrigió otra vez solo el producto temporal: las cinco instantáneas permanecieron iguales. Actualizar mostró «Caso cerrado: evaluación histórica conservada», fin actual nuevo y fin utilizado anterior. El informe bajó de seis a cinco.

El recorrido usa una sola identidad ordinaria Responsable. Las restricciones Agente se reutilizan de la UI histórica y pruebas aisladas identificadas en la matriz; no se inventa simultaneidad. Se descartaron como evidencia de éxito los timeouts del navegador: cada paso se confirmó por estado posterior. Chrome ocultaba la pestaña y la promoción Go Mobile tapaba controles; se activó la ventana Salesforce y se cerró ese aviso, sin cambiar el producto ni preferencias globales.

## Pruebas y despliegue reproducible

| Suite final de esta verificación | Resultado |
| --- | --- |
| P04ModeloTest | 20/20 |
| P04SeguridadTest | 20/20 |
| P04GarantiaTest | 25/25 |
| P04CicloTest | 28/28 |
| P04ConsultaCasoTest | 13/13 |
| Total Apex, cinco suites secuenciales | **106/106** |
| Jest LWC | **23/23** |

Comandos reales: cinco `sf apex run test --class-names <suite> --synchronous --code-coverage --target-org p04-posventa-dev --json`, después `npm run test:lwc -- --json --outputFile=.local/s08-jest.json`. No hubo cambios de código entre esa ejecución y el cierre de la verificación funcional del 18/11/2026. No se repitieron instalación, auditoría npm ni cobertura frontend; los resultados históricos no se presentan como mediciones nuevas. No son resultados de CI remota.

`manifest/v1.xml` reúne **73 miembros explícitos**, sin comodines/destructivos; conversión local a Metadata API satisfactoria. [DESPLIEGUE-V1](DESPLIEGUE-V1.md) documenta dependencias, CaseStatus, paquete conjunto, permisos/grupos/cola, Flows, página, carpeta, pruebas y restauración. El despliegue completo o una instalación desde cero **no se han ejecutado**. Solo se acredita el incremental de cuatro componentes sobre la base existente.

Incidencias de preparación resueltas: Salesforce rechazó primero el filtro de RecordType por etiqueta y después repetir agrupaciones como columnas de detalle; ambos despliegues se revirtieron. La versión final usa Case.P04_Posventa y columnas de agrupación. La preparación inicial de un control con tipo Master falló y revirtió la transacción; el control viable usa tipo P04 y cliente sin marca, creado administrativamente, sin ampliar privilegios ni convertir clientes originales.

## Restauración y revisión local

Eliminados solo los IDs registrados: **seis casos, dos productos, un contacto y un cliente temporales**, en ese orden y sin purga. Se validaron nombres, relaciones y exclusividad del cliente temporal antes de borrar. Ningún original se incluyó en el borrado.

Auditoría final satisfactoria: **ocho originales**, dos casos originales sin evaluar, garantía y serie originales conservadas; cero temporales desde las pruebas de seguridad hasta la validación integrada pendientes en las comprobaciones previstas. Usuario reutilizable activo P04_Minimo, sin rol, conjuntos adicionales, grupos ni casos propios. Administrador y P04_DemoAdmin preservados; dos licencias Salesforce usadas de dos. Salida de Login As y política restaurada a **false**, comprobada tras recarga.

Consulta final de configuración: ambos Flows activos; cola con exactamente los grupos Agentes y Responsables; RunReports habilitado en P04_Responsable, CreateCustomizeReports/ViewAllData/ModifyAllData deshabilitados. Resultado privado en `.local/s08-final-config.json`.

Evidencias privadas ignoradas: `.local/s08-deploy-3.json`, `s08-report-describe.json`, `s08-final-metadata/`, `s08-tests-*.json`, `s08-jest.json`, `s08-expected-*.json`, `s08-ui-report-*.json`, `s08-ui-closed-historical.json`, `s08-case-*.json`, `s08-product-after-close.json`, `s08-cleanup.json`, `s08-final-audit.json`, `s08-policy-restored.json` y `s08-local-verification.json`. No se publican IDs, usuarios internos, URLs de sesión ni capturas privadas.

Revisión local final satisfactoria: 144 archivos UTF-8, 83 XML, 13 scripts PowerShell, 83 enlaces locales y 195 referencias de miembros de manifiestos. Cinco exclusiones privadas comprobadas; barrido de identidades/secretos, espacios en archivos nuevos y `git diff --check` sin incidencias. Los históricos siguientes conservan sus propias cifras.

## Entrega y límites

Matriz de doce criterios satisfactoria dentro del alcance: [ACEPTACION-V1](ACEPTACION-V1.md). Guion de unos cinco minutos y preparación/restauración separadas: [DEMO-V1](DEMO-V1.md). Competencias y decisiones referenciadas a implementación y pruebas, sin métricas de negocio inventadas.

No quedan defectos funcionales conocidos dentro del alcance comprobado. Límites: garantía simulada; un usuario reutilizable; sin producción, carga/concurrencia real, móvil, API ordinaria con OAuth propio, CI remota ni instalación limpia acreditada. No se transforma la comprobación de permisos en una auditoría integral de seguridad o accesibilidad.

## Histórico — Consulta LWC publicada en fae9fbe

Los resultados siguientes corresponden a la incorporación de la consulta. El informe y la validación integrada se incorporaron después.

18 de noviembre de 2026. LWC de consulta integrado y comprobado en Salesforce. Informe de pendientes, integraciones y cierre global V1 quedan fuera.

Organización P04 y administrador contrastados antes de escribir; API 68.0 y alias explícito p04-posventa-dev. Sin Gmail, otras organizaciones, comunicaciones o cuentas persistentes nuevas. CLI 2.158.7, extensiones Salesforce 68.10.0 y JDK 21.0.13 conservados. Node 24.13.0 y npm 11.6.2 existentes. No había herramientas frontend en el repositorio: se añade un paquete raíz privado con el runner oficial sfdx-lwc-jest 8.0.0 y package-lock.json, exclusivamente desarrollo local.

### Implementación

`p04ConsultaCaso` usa componentes estándar Lightning, etiquetas castellanas y disposición adaptable. Muestra producto/serie/fechas actuales, incidencia, siete valores de evaluación y hasta cinco relacionados visibles. Distingue Sin evaluar y Pendiente_datos; compara cuatro fechas incluyendo ausencias para avisar de reevaluación en abiertos, sin calcular cobertura. Cerrados se presentan como históricos. Date conserva el día con UTC; DateTime muestra zona.

`P04ConsultaCaso.consultar` acepta solo caseId, resuelve el Asset desde el caso autorizado, exige ámbito/permisos P04 y consulta con with sharing y USER_MODE. Rechazo completo y genérico ante falta de acceso a objetos, campos o relaciones; no presenta restricciones como null. Relacionados del mismo producto, P04, excluyendo actual, CreatedDate DESC e Id DESC, LIMIT 5 después del acceso, sin recuentos ni filtrado de ocultos en cliente. Sin DML ni helpers de integridad para retornar datos.

Actualización imperativa sin caché de cliente, mediante Actualizar. La evaluación sigue siendo la acción existente y exige otra actualización del panel. Cada petición limpia contenido anterior; navegación, errores y desconexión invalidan respuestas tardías. Se conservan permisos de edición de los siete campos, compartición y todos los controles del ciclo.

Página propia P04_Caso y asignaciones versionadas en P04_Posventa: Case.P04_Posventa, P04_Minimo y Admin, Large. Cabecera, detalles y publicador en pestaña estándar Gestión del caso. Los tres permission sets solo añaden acceso a la clase de consulta. La recuperación previa de la aplicación confirmó que no había asignaciones de página propias; sus cuatro flags de navegación existentes se preservan explícitamente. No se modifican otras aplicaciones, páginas, perfiles o ajustes globales de soporte. Detalle en [CONSULTA](CONSULTA.md).

### Despliegue y pruebas reales

Despliegue satisfactorio de **8 componentes**, con **13/13 pruebas nuevas**, cero errores. Después se ajustó únicamente la FlexiPage (un componente ya incluido), Succeeded y cero errores, para alojar el publicador en una pestaña estándar. El manifiesto final conserva ocho componentes distintos. La página final fue comprobada en la interfaz; no hubo cambios Apex después de la regresión satisfactoria.

| Suite | Resultado final |
| --- | --- |
| P04ModeloTest | 20/20 |
| P04SeguridadTest | 20/20 |
| P04GarantiaTest | 25/25 |
| P04CicloTest | 28/28 |
| P04ConsultaCasoTest | 13/13 |
| Total Apex | **106/106** |
| LWC Jest | **23/23** |

La regresión final se ejecutó clase por clase con apex run test --synchronous --code-coverage. Un intento asíncrono paralelo anterior produjo UNABLE_TO_LOCK_ROW en preparación de membresías de cola compartida entre suites; no cuenta como éxito. Se resolvió ejecutando secuencialmente, sin cambiar configuración global, aserciones ni clases anteriores. Test-Consulta reproduce los mismos comandos, con comprobación de destino; no se volvió a ejecutar otra regresión redundante usando el wrapper.

Apex nuevo: agente propio, responsable permitido, ajeno y usuario sin permisos rechazados; FLS real de SerialNumber ausente mediante permiso aislado de test, con caso visible; producto inaccesible; cinco relacionados, orden/empate/exclusión y oculto más reciente; opcionales/null/sin evaluación/vacío; revocación; entradas inválidas/eliminadas; cero DML y conservación de instantánea/LastModifiedDate al consultar. Los usuarios son aislados; fixtures y shares administrativos se distinguen de llamadas restringidas USER_MODE. Las cuatro suites publicadas permanecen sin cambios.

Jest: carga accesible, secciones y campos, fechas y zona, sin evaluar/Pendiente_datos, diferencias de las cuatro fechas y nulls, histórico cerrado, opcionales, vacío visible, navegación estándar, actualización tras evaluar, error/acceso/reintento, respuestas inválidas, respuesta/error tardíos y desconexión. Mocks de frontend no acreditan permisos Salesforce. Cobertura JavaScript del runner final: 98,18 % líneas y 93,75 % ramas; no es cobertura Apex ni una auditoría integral de accesibilidad.

Instalación reproducible npm ci y npm ls --all sin problemas de engines/peers. npm audit final: **cero vulnerabilidades**, incluidas dependencias de desarrollo. Persisten avisos de obsolescencia de dependencias transitivas del runner oficial. No se usan force, legacy-peer-deps ni cambios globales.

### Interfaz ordinaria comprobada

Un único usuario reutilizable, perfil mínimo y escenario Agente temporal. Preparación administrativa: un Asset ficticio y tres Cases identificados (principal y relacionado propios; tercero reservado al administrador), referenciando cliente/contacto originales. Sin correos. Las escrituras de preparación no se atribuyen al usuario ordinario.

1. Página P04 real: producto/fechas actuales, Sin evaluar y solo el relacionado visible. El caso reservado no aparece. Navegación estándar al relacionado confirmada por ruta, título y nuevo contenido.
2. Evaluar garantía mediante la acción existente: confirmación guardada. Antes de pulsar Actualizar, el panel aún decía Sin evaluar; después mostró En cobertura y los siete valores persistidos. Lectura administrativa confirma propietario y autor ordinarios.
3. Se corrigió solo el fin del producto temporal y se vació su serie. Actualizar mostró fin actual distinto, No consta en serie, instantánea anterior En cobertura y aviso de reevaluación. Lectura posterior confirmó que los siete campos y la autoría del caso no cambiaron.
4. Revisión visual en escritorio a ancho de ventana 1536 y 960; panel estrecho de 456 px sin desbordamiento horizontal propio (scrollWidth=clientWidth). Se restauró el tamaño anterior. El aviso promocional estándar Go Mobile puede superponerse; no forma parte del LWC ni se cambió una preferencia global para ocultarlo.

Los rechazos de acceso/relación/FLS, límites/empates y revocación se acreditan en Apex y estados visuales en Jest; no se afirma nueva UI de responsable/revocación ni REST ordinaria independiente. El histórico cerrado se prueba en Jest y se conserva la regresión del ciclo; esta verificación no repitió el cierre UI del ciclo. Las consultas administrativas de contraste no son pruebas ejecutadas como usuario ordinario.

### Incidencias resueltas y límites

El primer despliegue se revirtió por el nombre del componente estándar de detalles; se corrigió a force:detailPanel. Un fixture nuevo combinaba modificación artificial de CreatedDate con escritura sellada de garantía y recibía GUARDADO_RECHAZADO; las fechas artificiales se acotaron a las pruebas de orden, manteniendo la aserción de evaluación y sin tocar el servicio publicado. Los posteriores 13 tests y la regresión completa pasaron.

El runner inicialmente consultado por defecto era 7.9.0; la auditoría señalaba tres avisos bajos corregidos en 8.0.0, cuya disponibilidad se comprobó. Se fijó 8.0.0. Su resolver dirigía lwc al main ESM incompatible con Jest 29; jest.config.js lo dirige a la distribución CJS oficial del mismo paquete, sin parchear node_modules ni sustituir el motor por un mock. Las 23 pruebas volvieron a pasar después de npm ci.

Tras activar la página, Lightning conservaba la presentación anterior hasta una recarga completa. El publicador mostró carga diferida inconsistente y se integró en Gestión del caso mediante componentes estándar; la evaluación real confirma su disponibilidad final. Los timeouts/selectores y capturas anteriores no se contabilizan como pruebas exitosas.

No se acreditan concurrencia real, dispositivo móvil, API ordinaria con OAuth propio, producción ni CI remota. El panel requiere Actualizar después de otras acciones; no se promete sincronización automática. Informe, integraciones y cierre global V1 pendientes de un incremento posterior.

### Restauración, revisión local y entrega

Se salió de Login As, se retiraron conjuntos y membresías temporales y se eliminaron exclusivamente los tres casos registrados y después su Asset temporal, sin purga. Auditoría final: ocho originales preservados, dos casos originales sin evaluar, garantía/serie originales conservadas; usuario activo P04_Minimo sin rol, conjuntos adicionales, grupos ni casos propios; administrador preservado y dos licencias Salesforce ocupadas. Login Access Policies vuelve a false, verificado tras recarga.

Revisión local final: 136 archivos UTF-8 válidos, 79 XML analizados, 13 scripts PowerShell sin errores sintácticos, 49 enlaces locales y 118 referencias de miembros de manifiestos resueltas. Cinco exclusiones privadas comprobadas, barrido de identidades/secretos y git diff --check satisfactorios. No se versionan identidades, autenticaciones ni evidencias privadas. Resultados en .local/s07-local-verification.json, s07-deploy-4.json, s07-page-deploy.json, s07-tests-*.json, s07-jest.json, s07-npm-audit.json, s07-ui-*.json, s07-api-*.json, s07-final-audit.json y s07-policy-restored.json. Los intentos fallidos se conservan aparte como históricos de diagnóstico.

Archivos: LWC y sus tests; P04ConsultaCaso/P04ConsultaCasoTest; FlexiPage y aplicación; tres accesos de clase; manifiesto; package/lock/Jest; Test-Consulta; documentación e instrucciones. Sin cambios en las cuatro suites publicadas, servicio de garantía, ciclo, triggers, modelo o compartición.

## Histórico — Implementación del ciclo publicada en eca51b8

Los resultados siguientes son históricos; sus límites no describen la V1 completa.

18 de noviembre de 2026. Recorrido de creación, cola, gestión individual, evaluación explícita, seguimiento y cierre implementado y demostrado. Informe, LWC e integraciones quedan fuera.

Los resultados siguientes corresponden al árbol desplegado del ciclo, no a CI. Organización dedicada y administrador contrastados antes de escribir; destino explícito p04-posventa-dev y API 68.0. CLI 2.158.7; extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13 conservados, sin instalaciones. Sin Gmail, otras organizaciones, comunicaciones ni nuevos usuarios persistentes.

### Implementación y decisiones

- Cola P04_Entrada con los grupos P04_Agentes y P04_Responsables, sin superiores ni correo. P04Cola verifica membresía efectiva, usuario activo y asignación directa del conjunto de permisos; no confunde estas condiciones.
- Flow P04_EntradaCaso anterior al guardado y solo de creación: resuelve tipo/cola por DeveloperName y normaliza IDs con CASESAFEID. P04Autorizacion admite entrada, toma propia y reasignación acotadas. Case sigue Private; tomar no comparte casos individuales con otros agentes.
- P04Ciclo, invocado por P04Caso, impone matriz, propietario habilitado, resolución/explicación, evaluación y vigencia exacta de compra/inicio/fin/incidencia, incluidos null. Pendiente_datos solo permite Sin_actuacion. Cerrado inmutable en los campos definidos en CICLO, incluso frente a administración.
- Screen Flow P04_EvaluarGarantia y acción de ficha reutilizan P04EvaluarGarantiaAccion en contexto de usuario. Solo correcto=true/codigo=OK confirma éxito. Los siete campos siguen sin edición ordinaria y P04Garantia no cambia.
- Acción estándar Cerrar caso P04 con estado cerrado predefinido y resolución/explicación; evita cambiar la configuración global de soporte. Las reglas críticas siguen en servidor.

Se conserva el canal administrativo de preparación/importación con propietario explícito mediante el permiso P04_Administrar existente. No ejecuta el Flow inicial, pero tampoco elude estados, cierre o inmutabilidad. No es una concesión nueva al usuario ordinario. No se añaden campos, perfiles, reglas de compartición ni permisos ViewAll/ModifyAll. Contrato y campos protegidos en [CICLO](CICLO.md).

### Despliegue y pruebas reales

Despliegue principal: **Succeeded, 16 componentes, 93 pruebas y cero errores**. El cliente perdió la respuesta de seguimiento con MetadataTransferError/fetch failed; la consulta posterior al despliegue confirmó su finalización correcta y el resultado íntegro de las cuatro suites. No se trató el fallo de comunicación como éxito sin comprobar el servidor.

Después se desplegaron **dos componentes de interfaz**, acción estándar de cierre y layout, con Succeeded y cero errores. No se modificó Apex después de sus 93 pruebas. La acción definitiva se probó con el usuario ordinario. El layout participa en ambos despliegues: el manifiesto final contiene **17 componentes distintos**, no 18. El procedimiento de repetición en [TESTING](TESTING.md) usa ese manifiesto y las cuatro suites; no se presenta como un comando final de 17 componentes ya ejecutado.

| Suite | Resultado |
| --- | --- |
| P04ModeloTest | 20/20 |
| P04SeguridadTest | 20/20 |
| P04GarantiaTest | 25/25 |
| P04CicloTest | 28/28 |
| Total | **93/93** |

Pruebas nuevas: creación con Flow y propietario persistido; toma, separación posterior, permiso sin membresía y membresía sin permiso; revocación; asignación/reasignación del responsable y destinatarios fuera de equipo/inactivos; matriz y guardados sin transición; ambos cierres válidos; rechazo por cola, evaluación ausente, resolución o explicación vacías; fechas desactualizadas y ausencia de fecha; reevaluación explícita; Pendiente_datos; inmutabilidad; lotes de 200 para asignación y recorrido completo. Las acciones restringidas usan usuarios aislados y USER_MODE; las pruebas explícitas SYSTEM_MODE comprueban que el guardián tampoco se elude por esa vía.

Se conservan las tres suites anteriores y sus objetivos. Los fixtures ahora toman el caso y recorren estados válidos antes del cierre; se prepara membresía en los usuarios aislados. El antiguo fixture cerrado sin evaluación ya no es persistible: se comprueba el rechazo del cierre sin evaluar, la ausencia de instantánea y, tras un cierre válido, el rechazo de evaluación del cerrado. No se desactivan controles para preparar datos.

Cobertura informada del despliegue principal: P04Cola 21/21 ubicaciones, P04Ciclo 38/38, P04Caso 3/3 y P04Autorizacion 67/68. P04_EntradaCaso cubre sus cuatro elementos. Estas cifras no son cobertura global de la organización.

Incidencias resueltas: orden de elementos en PermissionSet y navegación de Screen Flow; comparación de IDs de 15/18 caracteres mediante CASESAFEID; layout de acción estándar con dos columnas. La edición normal ocultaba Cerrado por una opción global: se resolvió con la acción específica P04, sin cambiar esa opción. Los intentos fallidos y guardados sin persistencia no cuentan como demostraciones satisfactorias.

### Recorrido comprobado en la interfaz

Identidad ordinaria reutilizable verificada, escenario Agente temporal. Un único Case ficticio del ciclo, relacionado con cliente/contacto/producto originales; no se crearon otros registros de negocio persistentes.

1. Alta estándar: Nuevo y propietario cola, creados por el usuario ordinario.
2. Cambiar propietario a sí mismo, con notificación por correo desactivada; posterior edición a En curso conserva propietario individual.
3. Evaluar garantía desde Feed, desplegando Create new...: confirmación real y En_cobertura. Los siete valores quedan guardados por el usuario ordinario.
4. Seguimiento mediante Pendiente de información, persistido.
5. Cerrar caso P04 sin resolución/explicación: rechazo del servidor. Completar Reparacion y explicación: Cerrado persistido y los siete valores de evaluación conservados.
6. Editar a En curso: rechazo de reapertura. Evaluar de nuevo mediante Flow: CASO_CERRADO, sin pantalla de éxito. La lectura posterior confirmó estado, propietario, resolución e instantánea intactos.

Las consultas posteriores fueron administrativas y corroboran las escrituras UI; no son una prueba REST ordinaria. Reasignación entre dos agentes y revocación de cola se acreditan mediante Apex aislado, no mediante una nueva sesión UI de responsable. Guía breve reproducible en CICLO.

### Limpieza, estado final y límites

Auditoría satisfactoria: **ocho originales conservados** (dos clientes, contactos, productos y casos); sus dos casos siguen sin evaluar y la garantía/serie originales permanecen iguales. Se eliminó únicamente el Case temporal identificado del ciclo, sin purga. Cero temporales activos de las pruebas de seguridad, garantía y ciclo.

Usuario de pruebas activo en P04_Minimo, sin rol, conjuntos adicionales, grupos ni casos propios activos. Administrador preservado y único titular de P04_DemoAdmin. Dos licencias Salesforce, ambas ocupadas; ninguna cuenta nueva. La cola mantiene únicamente los dos grupos públicos previstos, sin usuarios directos ni superiores. Ambos Flows están activos.

Se salió de Login As, se restauró Administrators Can Log in as Any User a **false** y se verificó tras recargar la página. No se manipularon contraseñas. Los ocho registros de muestra no se utilizaron como casos de trabajo; solo como referencias del temporal.

No se prueban concurrencia real entre transacciones, roles/grupos anidados, shares administrativos ajenos, producción ni nuevas llamadas REST con token ordinario. El bloqueo del producto al cerrar no se presenta como una prueba de carrera real. Informe y LWC pendientes de un incremento posterior.

Evidencia privada excluida de Git: .local/s06-after-transfer-error.json (despliegue principal y tests), s06-close-action-deploy-2.json (acción/layout), s06-ui-*.json y s06-api-*.json (interfaz/persistencia), s06-final-audit.json, s06-policy-restored.json y s06-local-verification.json. Los archivos públicos no incluyen IDs privados, autenticaciones ni URLs de acceso.

### Revisión local y entrega

Revisión final satisfactoria: 120 archivos públicos UTF-8, 74 XML válidos, 12 scripts PowerShell sin errores de sintaxis, 38 enlaces locales existentes y 110 referencias de manifiestos resueltas sin comodines. Cinco exclusiones comprobadas (.local, .sf, .sfdx, .env y node_modules); búsqueda de identidades privadas y patrones de secretos sin hallazgos. git diff --check correcto. Los avisos LF/CRLF proceden de la configuración Git existente, que se conserva. Las pruebas Apex no se repiten por cambios documentales o formato.

Archivos del cambio: P04Cola/P04Ciclo/P04CicloTest y metadatos; adaptación de P04Autorizacion, P04Caso y fixtures de las tres suites; cola, dos Flows, dos acciones, layout y tres permission sets; manifest/sesion06.xml, Test-Ciclo, adaptación de la demo administrativa anterior; README, AGENTS y documentación de ciclo, modelo, seguridad, garantía, pruebas, alcance y estado.

## Histórico — Evaluación de garantía publicada en 70ecc63

Los resultados siguientes corresponden a la incorporación del servicio de garantía, anterior al ciclo y la consulta.

18 de noviembre de 2026. Servicio único de evaluación de garantía desplegado y comprobado en P04. En esta versión aún no estaban implementados Flow, cola, ciclo completo, informes ni LWC.

Organización dedicada y API 68.0 comprobadas antes de escribir; clases base activas en esa versión. Alias explícito p04-posventa-dev en cada operación. Herramientas conservadas, sin instalaciones: CLI 2.158.7, Core/Apex/LWC 68.10.0 y JDK 21.0.13. Sin Gmail, otras organizaciones ni nuevos usuarios persistentes.

### Implementación y decisiones

P04Garantia recibe solo identificadores, valida rol, CRUD, lectura de registros/campos y acceso efectivo de edición, recupera datos en USER_MODE y calcula cobertura respecto a incidencia. Límites inclusivos, compra opcional, garantía incompleta pendiente de datos con motivo específico; incoherencias son errores. Guarda los siete campos existentes sin añadir campos al modelo.

P04EvaluarGarantiaAccion es un adaptador invocable sin cálculo ni DML propio. Los tres permission sets incorporan acceso a las dos clases; no se amplían CRUD/FLS, grupos ni compartición. P04Autorizacion solo permite los valores exactos calculados para los IDs autorizados por un contexto privado transitorio, sin setter público ni permiso global. Los campos continúan sin edición directa ordinaria.

La instantánea permanece histórica al modificar producto o incidencia. La reevaluación requiere otra petición explícita y usa los datos actuales. Un caso cerrado se rechaza sin modificar su evaluación; no se implementa el resto del ciclo.

Se decidió atomicidad por llamada (hasta 200 solicitudes). Duplicados se deduplican para consulta/cálculo/DML, manteniendo una respuesta por posición. Si una entrada falla, las otras no se guardan. Vacíos, mal formados, no visibles, fuera de ámbito y límites tienen códigos seguros. Detalle y ejemplos en [GARANTIA](GARANTIA.md).

### Despliegue y pruebas reales

Comando ejecutado, previa comprobación de identidad:

```powershell
sf project deploy start --manifest manifest/sesion05.xml --target-org p04-posventa-dev --test-level RunSpecifiedTests --tests P04ModeloTest --tests P04SeguridadTest --tests P04GarantiaTest --wait 3 --json
```

Resultado final: **Succeeded, siete componentes, 65 pruebas y cero errores**. Cuatro clases (servicio, adaptador, tests y autorización) y tres permission sets. El primer intento se revirtió por un error de conversión de Id en Apex; se corrigió sin cambiar el contrato ni reducir aserciones. El segundo despliegue ejecutó y superó las tres suites.

| Contexto | Comprobación | Resultado |
| --- | --- | --- |
| P04GarantiaTest | 25 pruebas nuevas | 25/25 |
| P04ModeloTest | Regresión del modelo | 20/20 |
| P04SeguridadTest | Regresión de seguridad | 20/20 |
| Agente, servicio bajo runAs | Evaluación propia y denegación ajena | Correcto |
| Responsable, servicio bajo runAs | Casos editables de equipo / caso solo lectura | Permitido / rechazado |
| Sin permisos | Operación, aunque sea propietario | Rechazada |
| Cobertura persistida | Interior, límites, días contiguos, un día y bisiesto | Correcta |
| Datos incompletos | Inicio, fin, ambos; compra opcional | Motivos y nulls correctos |
| Instantánea | Producto/incidencia cambian sin recalcular | Conservada; reevaluación explícita correcta |
| Cerrados | Con y sin evaluación anterior | Rechazados sin alterar instantánea |
| Privilegios | Escritura directa después del servicio | Rechazada en USER_MODE y por guardián |
| Lote mixto | Abierto válido y cerrado | Ninguna instantánea modificada |
| Entradas | Duplicados, null/vacíos, otro objeto, inexistente | Correspondencia y errores seguros |
| Lote de 200 | Todos persistidos | Un DML y como máximo ocho consultas |
| Más de 200 | Rechazo sin escribir | Correcto |
| Datos inválidos no persistibles | Validación defensiva en memoria | Rechazo; reglas no desactivadas |
| Demo administrativa | Evaluar, conservar, reevaluar, rechazar cerrado | Correcto; temporales revertidos |

Las llamadas restringidas usan usuarios Apex aislados; las lecturas dentro del servicio conservan USER_MODE. Los fixtures administrativos y la escritura privilegiada limitada del servicio se distinguen. No se modificaron P04ModeloTest ni P04SeguridadTest.

Cobertura informada de clases desplegadas: P04Garantia 90/93 ubicaciones, P04EvaluarGarantiaAccion 4/4 y P04Autorizacion 62/63; 156/160 en total. No es cobertura global ni de P04Integridad, que permanece sin cambios.

La demo se ejecutó mediante scripts/Demo-Garantia.ps1: dos registros temporales propios y savepoint, verificación de resultados persistidos dentro de la transacción, corrección del producto sin recálculo, reevaluación por invocable, cerrado rechazado y rollback comprobado. Es evidencia administrativa, no UI/REST ordinaria. El wrapper Test-Garantia.ps1 queda reproducible y se revisa sintaxis; las 65 pruebas reales se ejecutaron durante el despliegue, sin repetición innecesaria por documentos.

### Estado final y límites

Auditoría final satisfactoria: ocho registros originales (dos clientes/contactos/productos/casos), ambos casos de muestra sin evaluar y garantía/serie originales conservadas. Cero temporales de evaluación de garantía, cero temporales activos de seguridad. Administrador activo y P04_DemoAdmin reservado a él.

Usuario persistente activo en P04_Minimo, sin rol, conjuntos adicionales, grupos ni casos propios activos. Dos licencias Salesforce ocupadas; no se creó otra cuenta. No se cambiaron asignaciones personales ni Login Access Policies en esta verificación, ni se utilizó el navegador o Gmail.

No se han realizado nuevas pruebas UI/REST ordinarias: la autorización del servicio se acredita mediante Apex/runAs con lecturas USER_MODE y regresión. No se han provocado concurrencia real, límites irrecuperables ni rechazo DML posterior a prevalidación correcta. Los errores de datos que las reglas impiden guardar se verificaron en el validador privado con datos en memoria. No atribuir esas pruebas a una escritura inválida persistida.

Evidencia privada, excluida de Git: .local/s05-deploy-1.json (fallo revertido), s05-deploy-2.json (éxito y tests) y s05-final-audit.json. Documentación funcional en GARANTIA, modelo en DATA_MODEL, seguridad en SECURITY y procedimiento en TESTING.

Revisión local final: 106 archivos públicos comprobados como UTF-8 estricto, 65 XML válidos, 11 scripts PowerShell sin errores de sintaxis, 28 enlaces locales existentes y 93 referencias de manifiestos resueltas sin comodines. Cinco exclusiones comprobadas (.local, .sf, .sfdx, .env y node_modules); sin identidades privadas ni patrones de secretos en los archivos revisados. git diff --check correcto. Los avisos LF/CRLF corresponden a la configuración existente, que no se cambió. No se repitieron suites por cambios solo documentales.

### Archivos y procedimiento

Cambios: P04Garantia/P04EvaluarGarantiaAccion/P04GarantiaTest con metadatos API 68; adaptación de P04Autorizacion; acceso a clases en tres conjuntos; manifest/sesion05.xml; Demo-Garantia y Test-Garantia con plantilla Apex de demo; documentación y AGENTS. No hay cambios de campos, reglas de validación, triggers, perfiles o compartición.

```powershell
./scripts/Demo-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
```

El ciclo y la asignación se incorporaron en la versión posterior.

## Histórico — Implementación de seguridad publicada en 4cfaf0b

Los resultados siguientes corresponden a la incorporación de seguridad por función.

18 de noviembre de 2026. Seguridad por función implementada, desplegada y comprobada exclusivamente en P04. No se ha iniciado la evaluación automática de garantía.

API 68.0 y alias explícito p04-posventa-dev. Se contrastaron identidad Developer Edition y administrador antes de escribir. Sin otras organizaciones ni Gmail. Herramientas conservadas: CLI 2.158.7, extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13; sin instalaciones en esta verificación.

### Implementación y despliegue

- Perfil P04_Minimo; conjuntos P04_Agente/P04_Responsable y permiso administrativo reservado.
- Tres permisos personalizados, dos grupos directos, cinco reglas de criterios y dos layouts adicionales de cliente/contacto.
- Account.P04_Posventa__c como único campo adicional de ámbito; 13 campos propios totales.
- Account/Asset/Case Private, Contact ControlledByParent y Opportunity Private por dependencia exigida. Se preservaron los 18 roles originales, los datos de formación y el administrador.
- P04Autorizacion separado de P04Integridad; cuatro triggers extendidos. Sin evaluación de garantía ni cambio de las nueve validaciones funcionales.
- P04SeguridadTest nuevo, más ajuste de dos fixtures Master de P04ModeloTest para preservar su ámbito bajo las concesiones actuales.

Despliegues satisfactorios: compartición 30 componentes; preparación 49; completo manifest/sesion04.xml, **56 componentes, 40 pruebas y cero errores**. El manifiesto incluye objetos padres y sus hijos DX propios ya existentes; 56 no significa 56 componentes nuevos.

El primer intento de preparación detectó la dependencia de Opportunity, requisitos de layout y orden de compartición, y se revirtió. Las primeras ejecuciones completas detectaron ContactAccessLevel no escribible con herencia de Account y selección implícita de tipo P04 en fixtures. Se corrigieron antes del despliegue final. Para los fixtures Master se usa un administrador aislado sin los tipos concedidos por P04_DemoAdmin, comprobando RecordTypeId null; no se retiraron permisos del administrador real ni se debilitaron aserciones.

### Resultados comprobados

| Contexto | Acción | Esperado | Obtenido |
| --- | --- | --- | --- |
| Agente, Apex USER_MODE | Crear y editar propios, lote de 200 | Permitido | Correcto |
| Agente, Apex USER_MODE | Caso ajeno/no compartido; editar padres o garantía | Rechazo | Correcto |
| Agente, UI ordinaria | Guardar asunto propio | Persistencia | Confirmada por lectura administrativa |
| Agente, UI ordinaria | Producto y URL de otro caso | Solo lectura / denegación | Correcto, sin asunto del caso bloqueado |
| Responsable, Apex USER_MODE | Altas, corrección y gestión de equipo | Permitido | Correcto |
| Responsable, Apex USER_MODE | Reasignar dentro/fuera del equipo | Permitir/rechazar | Correcto |
| Responsable, UI ordinaria | Garantía y reasignación al integrante activo | Persistencia, sin correo | Confirmadas; garantía restaurada |
| Ambos, Apex USER_MODE | Siete campos de evaluación y borrados | Rechazo | Correcto |
| Sin permisos, Apex USER_MODE | Lectura/escritura aun siendo dueño | Rechazo | Correcto |
| Revocación, usuario persistente | Retirar permisos y grupos | Sin acceso a seis registros | Confirmado por UserRecordAccess |
| Revocación, UI ordinaria | URL del caso propio | Denegación | «You don't have access to this record» |
| Integridad bajo ambos roles | Relaciones/fechas incoherentes | Rechazo | Correcto |
| Regresión P04ModeloTest | 20 pruebas previas | Sin fallos | 20/20 |
| P04SeguridadTest | 20 pruebas nuevas | Sin fallos | 20/20 |

Las acciones restringidas de Apex usan USER_MODE dentro de System.runAs. Fixtures administrativos y pruebas adicionales SYSTEM_MODE del guardián se identifican aparte. La compartición de fixtures no se confunde con las reglas reales: estas se contrastaron con el usuario persistente después del recálculo.

Auditoría de permisos desplegados: cero ViewAllData/ModifyAllData, cero View All/Modify All de objetos, cero borrado y cero edición de evaluación. Perfil base sin lectura de los cuatro objetos. UserRecordAccess: agente lee cliente/contacto/producto, edita propio y no lee otros casos; responsable lee/edita todos los registros P04 comprobados; tras revocación, cero lectura/edición/borrado/transferencia en los seis registros consultados.

Salesforce muestra Change Owner e indica HasTransferAccess al agente propietario; la reasignación está bloqueada por P04Autorizacion, comprobada en servidor. No se afirma que ocultar el botón sea una protección. La aplicación P04 Posventa y sus cuatro pestañas se vieron con el responsable.

Cobertura informada del despliegue: P04Autorizacion 61/62 ubicaciones y cuatro triggers 10/10, total 71/72 de componentes informados. P04Integridad permaneció sin cambios y no está incluido en esa cifra. Sin nueva ejecución independiente de Test-Seguridad.ps1: el wrapper queda reproducible y las pruebas reales se ejecutaron durante el despliegue.

Los fallos de selectores, aperturas o guardados no persistidos de Lightning no se contaron como éxito. Se comprobó identidad por indicador Login As/enlace del perfil y persistencia después de cada escritura positiva. No se omitieron validaciones.

### Cierre de organización

Auditoría final satisfactoria:

- Administrador activo y P04_DemoAdmin exclusivamente asignado a él.
- Usuario de pruebas activo, P04_Minimo, sin rol, conjuntos adicionales ni grupos; cero casos propios activos. Dos licencias Salesforce disponibles y dos ocupadas, para reutilizar este usuario secuencialmente.
- Ocho registros originales conservados: dos clientes, dos contactos, dos productos y dos casos sin evaluar. Clientes marcados P04; serie y asunto revisados del modelo conservados.
- Garantía Norte restaurada al 19/10/2027; compra/inicio 19/10/2026. Cero casos temporales activos. Eliminación acotada mediante Remove-SecuritySample, sin purga de papelera.
- Sesión ordinaria cerrada. Administrators Can Log in as Any User restaurado a false, comprobado tras recargar. El acceso administrativo se conserva.

Evidencias privadas: .local/s04-full-4.json, s04-effective-metadata.json, s04-access-Agente/Responsable/Ninguno.json, s04-agent-persisted.json, s04-manager-persisted.json, s04-transfer-persisted.json, s04-revoked-own-case.json, s04-final-audit.json y s04-policy-final.json. No incluirlas en Git ni publicar identificadores.

### Límites y revisión local

No hay autenticación OAuth ordinaria independiente: no se afirma una prueba REST con token ordinario. UI ordinaria y Apex USER_MODE acreditan restricciones; CLI/API administrativos preparan y contrastan. No se probaron concurrencia, colas, nuevas jerarquías, fusiones/undelete ni concesiones futuras. Los rótulos de pestañas previamente abiertas pueden quedar en caché; la revocación impide nuevas consultas, no borra lo ya visto.

No hay motor de evaluación, ciclo completo, asignación automática, informe ni LWC. Detalle en [SECURITY](SECURITY.md) y [TESTING](TESTING.md).

Revisión local final: 95 archivos públicos leídos como UTF-8 estricto, 61 XML válidos, nueve scripts PowerShell sin errores de sintaxis, 22 enlaces locales existentes y 86 referencias de miembros de manifiestos resueltas sin comodines. Cinco exclusiones comprobadas (.local, .sf, .sfdx, .env y node_modules); sin identidades privadas ni patrones de secretos en los archivos revisados. git diff --check correcto. Los avisos LF/CRLF corresponden a la configuración existente de Git; no se modificó configuración global. Estas comprobaciones incluyen archivos nuevos, que git diff por sí solo no enumera.

### Archivos y procedimiento

Archivos de implementación: clases P04Autorizacion/P04SeguridadTest, fixtures de P04ModeloTest, cuatro triggers, perfil, permisos/grupos/reglas, layouts y configuración de compartición. Tres manifiestos acotados. Procedimientos New-SecurityUser, New-SecuritySample, Set-SecurityScenario, Remove-SecuritySample y Test-Seguridad, con plantillas Apex. Documentación: README, AGENTS, SECURITY, TESTING, DATA_MODEL, PROJECT_BRIEF y este STATUS.

## Histórico — Implementación del modelo completada

18 de noviembre de 2026. Primera base funcional implementada, desplegada y comprobada en P04. El usuario ya puede trabajar con los datos ficticios relacionados desde la interfaz estándar. Evaluación de garantía, ciclo completo y seguridad por función siguen pendientes.

Implementación y despliegue acotados a datos ficticios exclusivamente en P04. Antes de escribir se contrastó Organization y, antes de asignar el permiso, la identidad de sesión del administrador esperado. Sin otras organizaciones, destinos predeterminados, usuarios nuevos ni acceso a Gmail.

### Implementación y despliegue

Manifiesto explícito manifest/sesion03.xml, 36 componentes y 11 tipos de metadatos:

| Elemento | Cantidad | Resultado |
| --- | --- | --- |
| Campos propios | 12 | Dos de garantía en Asset y diez en Case, incluidos campos futuros de evaluación/resolución |
| Reglas de validación | 9 | Obligatoriedad, coherencia de relaciones, intervalo, incidencia y estados |
| Tipos de registro y proceso | 2 + 1 | Asset.P04_Producto, Case.P04_Posventa y proceso de soporte propio |
| CaseStatus | 1 | Cuatro valores P04 añadidos, conservando New/Working/Escalated/Closed |
| Layouts y aplicación | 2 + 1 | Consulta/edición estándar; app P04 Posventa |
| Permiso y perfil | 1 + 1 | P04_DemoAdmin asignado solo al administrador; Admin contiene solo asignaciones de los layouts P04 |
| Apex | 2 clases + 4 triggers | Guardián de integridad y pruebas; sin motor de evaluación |

Despliegue completo final: Succeeded, 36 componentes, cero errores de componentes, 20 tests completados y cero errores. Después se desplegó un único ajuste de visibilidad de la pestaña Asset en P04_DemoAdmin: Succeeded, un componente, sin cambios de Apex. La nueva navegación quedó comprobada visualmente.

Los layouts Master y sus asignaciones predeterminadas de Asset y Case permanecen iguales a la referencia previa. No se recuperaron masivamente metadatos ni se usaron destructivos. Los valores CaseStatus se recuperaron y conservaron antes de ampliarlos. Detalles del modelo en [DATA_MODEL](DATA_MODEL.md).

### Comprobaciones reales

| Prueba | Esperado | Obtenido |
| --- | --- | --- |
| Recorrido Account → Contact → Asset → Case | Guardado coherente, evaluación vacía | Correcto |
| Obligatoriedad de cliente/contacto/producto/incidencia/asunto | Rechazo sin guardar | Correcto |
| Contacto o producto de otro cliente; producto ajeno a P04 | Rechazo | Correcto |
| Fin anterior al inicio | Rechazo; igualdad admitida | Correcto |
| Garantía incompleta y contacto opcional en Asset | Admitidos, sin evaluación implícita | Correcto |
| Incidencia futura o anterior a compra | Rechazo; hoy y día de compra admitidos | Correcto |
| Edición inválida | Conservar los valores anteriores | Correcto |
| Cambios de cliente/compra en padres utilizados | Rechazar si rompen las relaciones o fechas | Correcto |
| Borrados de padres referenciados | Rechazo; eliminación ordenada propia admitida | Correcto |
| Registros ajenos al ámbito P04 | No aplicar las restricciones P04 | Correcto en fixtures aislados |
| Estados P04 y ámbito | Valores propios; Cerrado con IsClosed; impedir salida de ámbito | Correcto, con distinción entre rechazo nativo y guardián |
| 200 casos válidos | 200 inserciones y 200 ediciones | Correcto |
| 200 casos mixtos | 100 éxitos y 100 rechazos esperados | Correcto |
| 200 contactos + 200 productos con casos | Rechazar 400 cambios incoherentes | Correcto |
| API directa | Crear/editar; rechazar fecha futura/contacto ajeno; conservar valores; limpiar caso temporal | 5/5 comprobaciones |
| Interfaz estándar | Consultar y editar producto/caso; comprobar persistencia por API | Correcto: serie y asunto actualizados |

Suite P04ModeloTest: **20/20**, sin SeeAllData. El despliegue informa 70/70 ubicaciones cubiertas en P04Integridad y 1/1 en cada trigger: 74/74, 100 % de esas ubicaciones; no equivale a cobertura de todas las funcionalidades futuras. Las pruebas de integridad usan modo sistema explícito y no acreditan CRUD/FLS de usuarios ordinarios.

La prueba de salida de ámbito distingue: null no cambia el tipo; Master puede rechazarse por la plataforma antes del trigger. Se comprueba el rechazo DML y la conservación del tipo y, por separado, se invoca el guardián y se comprueba su error específico. No se atribuye al trigger un rechazo nativo.

Interfaz: app y layouts consultados con Playwright, edición de serie por el control inline de Asset y asunto por el formulario estándar de Case. Se abrieron controles por su evento DOM cuando fallaron las coordenadas. Los primeros intentos de guardar con clic DOM no persistieron, incluso después de Tab, y no se contaron como éxito. La comprobación final confirmó el valor y el indicador de edición, enfocó el botón Save y lo activó con Enter. La lectura posterior por API confirma serie P04-FICT-N1-REV y asunto P04 DEMO - Caso revisado desde interfaz, con evaluación todavía vacía. No se atribuye la causa exacta a Salesforce ni se omite su validación.

### Datos y evidencia

Quedan ocho registros de demostración: dos Account, dos Contact, dos Asset y dos Case. AccountNumber P04-S03-DEMO-A/B identifica la muestra; no hay correos reales en los contactos. Se conservaron la muestra y los datos de origen. La última lectura cuenta 2 productos P04 y 2 casos P04 activos, cero cuentas P04 TEST y cero casos temporales P04 API activos. Las pruebas Apex revierten sus fixtures; Test-Api elimina solo su propio caso temporal. No se purga la papelera.

Límites finales observados: almacenamiento de datos máximo 5 MB y restante 5 MB según la unidad/redondeo del endpoint; API máximo 15000, restante 14755 en esa lectura. Los valores restantes son una instantánea, no una reserva. Se conservan dos licencias Salesforce, una libre para la fase de permisos.

Evidencia local ignorada: s03-deploy-6.json, s03-api-results.json, s03-layout-checks.json, s03-nav-deploy.json y s03-final-remote.json dentro de .local. s03-demo.json contiene identificadores privados y nunca se versiona. El [procedimiento reproducible](TESTING.md) separa despliegue, tests, API y demostración.

### Incidencias corregidas y límites

- Referencias del proceso de soporte corregidas a las etiquetas de CaseStatus; los registros y las fórmulas usan nombres API. Se desplegaron estados/proceso por separado durante el diagnóstico; los intentos completos fallidos se revirtieron.
- Layout Case corregido para incluir SuppliedEmail y mantener OwnerId editable, no Required. La muestra no envía comunicaciones.
- Apex 68.0 aplica modo usuario por defecto. Fixtures y consultas internas del guardián pasan a modo sistema explícito para verificar integridad, sin conceder permisos amplios a nuevos usuarios.
- Prueba de tipo corregida para distinguir null, Master y el rechazo propio del guardián.
- Pestaña Asset añadida al permiso administrativo tras detectar su ausencia en navegación.
- Se resolvieron selectores ocultos y confirmación de campos en Lightning. Windows rechazó temporalmente nuevos procesos con error 5; después volvió a permitir la ejecución, sin desactivar protecciones ni cambiar configuración global. El conector MCP antiguo probado como alternativa era incompatible con la extensión; se abandonó y se continuó con la CLI compatible ya instalada.

Se verifican operaciones secuenciales y lotes, no concurrencia entre transacciones ni fusiones/undelete. La cuenta administrativa puede tener privilegios superiores a los campos configurados como Readonly; no se considera protección de roles. El motor de garantía, transiciones, cierre completo, asignación, informe y LWC no están implementados. La condición de cierre con Pendiente_datos se mantiene como contrato futuro; la evaluación no se precarga.

### Archivos y revisión local

Modificados: AGENTS, README, PROJECT_BRIEF, ENVIRONMENT y STATUS. Nuevos: DATA_MODEL, TESTING, 36 XML de metadatos, seis fuentes Apex/triggers, manifest/sesion03.xml y cinco archivos de scripts. No cambian sfdx-project.json, .gitignore ni .forceignore; API 68.0 y herramientas se conservan.

Revisión local sobre los 59 archivos versionables, incluidos los nuevos: 37 XML válidos (36 metadatos y manifiesto), correspondencia exacta de los 36 componentes en 11 tipos, cuatro scripts PowerShell analizados sin errores, 15 enlaces Markdown locales resueltos, 11 exclusiones privadas y cinco rutas versionables comprobadas. Sin caracteres de sustitución, coincidencias con los patrones de datos privados revisados ni espacios finales; git diff --check satisfactorio. Esto no constituye un escaneo exhaustivo de secretos. No se repitió la suite remota tras cambios exclusivamente documentales; el resultado Apex procede del despliegue real indicado arriba. Evidencia local: .local/s03-local-review.json.

## Histórico — Preparación del entorno

17–18 de noviembre de 2026. Herramientas y estructura DX preparadas; arranque e indexación inicial de Apex con JDK 21 comprobados. Organización dedicada identificada y autenticada, API 68.0 contrastada y capacidades administrativas verificadas. Estas comprobaciones preceden a la implementación funcional y no acreditan por sí solas pruebas de producto ni despliegues. Versiones, comandos, licencias, límites y diagnóstico de acceso en [ENVIRONMENT](ENVIRONMENT.md).
