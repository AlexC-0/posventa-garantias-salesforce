# Comprobaciones del ciclo — sesión 06

Base publicada 70ecc63; destino exclusivo p04-posventa-dev, API 68.0. Leer [CICLO](CICLO.md) y [STATUS](STATUS.md). Confirmar organización y administrador con P04-Common antes de escribir. Revisar diferencias remotas pertinentes y conservar cambios posteriores del usuario. No usar destinos predeterminados, destructivos ni recuperaciones masivas.

## Repetición del despliegue y pruebas

El manifiesto final contiene 17 componentes distintos y presupone las sesiones 03–05 ya desplegadas. Comando reproducible:

```powershell
sf project deploy start --manifest manifest/sesion06.xml --target-org p04-posventa-dev --test-level RunSpecifiedTests --tests P04ModeloTest --tests P04SeguridadTest --tests P04GarantiaTest --tests P04CicloTest --wait 5 --json
```

Para ejecutar solo la regresión sobre la versión desplegada:

```powershell
./scripts/Test-Ciclo.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
```

Resultados realmente ejecutados: despliegue principal de 16 componentes, Succeeded y **93/93 pruebas** (20 modelo + 20 seguridad + 25 garantía + 28 ciclo), cero errores. Después, acción de cierre y layout: dos componentes, Succeeded, sin modificar Apex. La acción final se verificó en UI. El layout común hace que el manifiesto final reúna 17 componentes; no se afirma haber ejecutado después un despliegue único de esos 17 con otra repetición de suites. Test-Ciclo queda reproducible y comprobado sintácticamente; las 93 pruebas se ejecutaron en el despliegue.

## Aserciones y contextos

| Área | Persistencia y rechazo comprobados |
| --- | --- |
| Entrada y edición | Alta ordinaria acaba en cola/Nuevo; toma y edición conservan propietario individual |
| Acceso efectivo | Miembro habilitado consulta/toma; otro agente no ve el caso tras la toma |
| Separación de condiciones | Permiso sin membresía y membresía sin permiso no habilitan la operación |
| Revocación | Retirar membresía elimina consulta/toma; responsable revocado tampoco edita cola |
| Asignación | Responsable asigna/reasigna a miembros habilitados; rechaza fuera de equipo e inactivos |
| Estados | Nuevo, En curso, Pendiente y ambos cierres válidos; saltos, retrocesos y reapertura rechazados |
| Guardado idéntico | No constituye una transición; se permite también en cerrado |
| Cierre | Cola, propietario revocado/inactivo, resolución ausente, explicación null/vacía/espacios y evaluación ausente rechazados |
| Vigencia | Cada fecha modificada y compra que pasa a null exigen reevaluar; después se permite cerrar |
| Pendiente_datos | Solo Sin_actuacion; sin restricciones nuevas para otros resultados |
| Cerrado | Edición funcional/reapertura/evaluación rechazadas; modificar producto conserva instantánea |
| Volumen | Asignación de 200 y recorrido alta→cola→toma→evaluación→cierre de 200 |
| Regresión | Las tres suites conservan 65 pruebas y sus objetivos de modelo, acceso y servicio |

Sin SeeAllData ni usuarios persistentes nuevos. Fixtures administrativos y shares explícitos de tests se distinguen de las operaciones USER_MODE bajo runAs. Las reglas de criterios no se recalculan en esos fixtures: el responsable recibe un CaseShare de prueba tras transferir, sin ampliar reglas reales. Una prueba adicional comprueba pertenencia por el grupo P04 real, además de membresías directas de cola aisladas. No hay caché de permisos/membresías que oculte revocación.

Las nuevas reglas obligan a adaptar fixtures antiguos: alta Nuevo, toma, En curso, evaluación y resolución antes de cerrar. El antiguo cerrado sin evaluar deja de ser persistible; se comprueba primero el rechazo y la ausencia de evaluación, y después el rechazo de evaluar un cerrado válido. No se introduce bypass de test ni se desactivan validaciones. El canal administrativo de preparación con propietario explícito permanece, separado de la creación ordinaria cuyo Flow sí se ejecuta en tests.

Cobertura del despliegue: P04Cola 21/21, P04Ciclo 38/38, P04Caso 3/3, P04Autorizacion 67/68 ubicaciones; Flow de entrada 4/4 elementos. Sin extrapolar a toda la organización ni afirmar concurrencia real.

## Demostración ordinaria ejecutada

Un único usuario existente con escenario Agente y un Case temporal: creación estándar → cola → toma propia → En curso → evaluación desde Screen Flow → Pendiente de información → rechazo de cierre incompleto → cierre válido → rechazo de reapertura → CASO_CERRADO al reevaluar. Se verificaron propietario, estados, resolución y siete campos persistidos; creador/autor de escrituras corresponden al usuario ordinario. Las consultas de contraste fueron administrativas.

Repetición detallada, incluida presentación del Flow en Feed/Create new..., en CICLO. Los nombres de ejemplo llevan prefijo P04 S06 TEMP. Identificar el temporal antes de eliminarlo; no tocar los dos casos originales. Para preparar y restaurar el usuario:

```powershell
./scripts/Set-SecurityScenario.ps1 -ExpectedOrgId '<P04 verificada>' -ExpectedUserId '<usuario de prueba existente>' -Scenario Agente
# Ejecutar la demostración y sus comprobaciones; salir de la sesión ordinaria.
./scripts/Set-SecurityScenario.ps1 -ExpectedOrgId '<P04 verificada>' -ExpectedUserId '<usuario de prueba existente>' -Scenario Ninguno
```

Restaurar también cualquier ajuste temporal de Login As y comprobarlo tras recarga. Resultado final de esta sesión: ocho originales, cero temporales activos, usuario mínimo sin concesiones ni casos propios, administrador conservado, dos licencias ocupadas. Ambos Flows activos y cola con solo los dos grupos previstos. No se envió correo.

Demo-Garantia sigue siendo una herramienta administrativa, adaptada al cierre válido: ahora requiere el usuario existente temporalmente habilitado y miembro para que sea propietario elegible. Revierte sus dos registros. No se volvió a ejecutar en sesión 06 ni sustituye el recorrido ordinario recién demostrado. Los comandos y resultados siguientes se conservan únicamente como históricos; antes de repetirlos hay que aplicar el contrato actual.

## Histórico — Sesión 05

Las cifras, comandos y limitaciones siguientes corresponden a la sesión anterior, no al estado actual.

# Comprobaciones de evaluación — sesión 05

Base publicada 4cfaf0b, exclusivamente organización P04. Leer GARANTIA para contrato, acceso y errores. Confirmar identidad mediante scripts/P04-Common.ps1 y revisar cambios remotos pertinentes antes de escribir; no usar alias predeterminado ni otra organización.

## Despliegue y regresión ejecutados

```powershell
sf project deploy start --manifest manifest/sesion05.xml --target-org p04-posventa-dev --test-level RunSpecifiedTests --tests P04ModeloTest --tests P04SeguridadTest --tests P04GarantiaTest --wait 3 --json
```

Succeeded: siete componentes (servicio, adaptador, test, autorización y tres permission sets), 65 pruebas y cero errores. Un primer intento se revirtió por una conversión de Id que ocultaba el nombre del tipo en Apex; la corrección se desplegó con las tres suites completas. No se modificaron aserciones ni clases de tests anteriores.

| Pruebas nuevas | Evidencia |
| --- | --- |
| Interior, ambos límites y días contiguos | Resultado y fechas persistidas |
| Un solo día y 29/02/2024 | Cobertura inclusiva |
| Inicio, fin o ambos ausentes | Pendiente_datos, motivo exacto y nulls |
| Compra ausente/conocida | Ausencia permitida e instantánea completa |
| Producto/incidencia modificados | Instantánea histórica hasta reevaluación explícita |
| Cerrado evaluado/sin evaluar | Rechazo sin alterar instantánea |
| Agente, responsable, sin permisos | Contextos System.runAs y lecturas USER_MODE |
| Caso ajeno, Master o solo lectura | NO_AUTORIZADO |
| Escritura directa tras evaluar | FLS y guardián siguen rechazándola |
| Lote mixto válido/cerrado | Atomicidad y conservación anterior |
| Vacíos, null, mal formados, otro objeto, inexistentes | Respuestas seguras y ordenadas |
| Duplicados del invocable | Dos respuestas, mismo resultado, un registro |
| 200 casos | Persistencia de los 200, un DML y como máximo ocho consultas |
| 201 solicitudes | Rechazo sin escribir |
| Datos inválidos imposibles de persistir | Validador privado con datos en memoria; reglas intactas |

P04GarantiaTest: 25/25. P04ModeloTest: 20/20. P04SeguridadTest: 20/20. Los fixtures usan privilegios administrativos solo para preparar datos/comparticiones; la llamada al servicio se ejecuta como el usuario aislado. Su escritura SYSTEM_MODE limitada es parte del diseño comprobado, no una sustitución de la autorización.

Cobertura informada de las clases desplegadas: P04Garantia 90/93, P04EvaluarGarantiaAccion 4/4 y P04Autorizacion 62/63; total 156/160 ubicaciones. No trasladar esa cifra a toda la organización o a P04Integridad, que no cambió. No se ha provocado un fallo real de concurrencia, de límite de plataforma ni un rechazo DML posterior a una prevalidación correcta; no atribuir esa evidencia al lote mixto, que se rechaza antes del DML.

## Demostración ejecutada y repetición opcional

```powershell
./scripts/Demo-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
./scripts/Test-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
```

Demo-Garantia sí se ejecutó: evaluación inicial persistida, conservación al corregir producto, reevaluación mediante el adaptador, rechazo de cerrado y reversión de los dos registros temporales. Es una comprobación administrativa. No hubo nueva UI ni REST con identidad ordinaria ni cambios de permisos del usuario persistente.

Test-Garantia queda como wrapper reproducible y se comprueba su sintaxis; no se ejecutó una segunda suite innecesaria: las 65 pruebas se ejecutaron en el despliegue. La demo y los tests no modifican los ocho registros originales. Auditoría final en STATUS.

## Histórico — sesiones 03 y 04

El contenido siguiente conserva sus resultados y procedimientos; no describe una repetición de aquellas pruebas UI/API en sesión 05.


# Comprobaciones de seguridad y modelo

## Sesión 04: preparación y despliegue

Destino exclusivo P04, alias p04-posventa-dev, API 68.0. Comparar Organization.Id/OrganizationType y usuario administrativo con la referencia privada antes de escribir. Los scripts exigen ExpectedOrgId y no exportan autenticación. No usar el Playground anterior, Gmail ni destinos predeterminados.

Antes de repetir, revisar diferencias remotas y conservar cualquier cambio posterior del usuario. Los archivos SharingRules contienen las cinco reglas propias y la referencia original estaba vacía: si existen reglas nuevas, reconciliarlas antes de desplegar. No usar destructivos ni sobrescribir reglas ajenas. Los manifiestos de CustomObject incorporan también los hijos propios ya existentes en formato DX.

Orden ejecutado: compartición primero; preparación de permisos/grupos; despliegue completo con ambas clases de tests. Esperar a que termine cada despliegue y el recálculo antes de interpretar acceso. Salesforce exigió Opportunity Private como dependencia de Account Private.

```powershell
sf project deploy start --manifest manifest/sesion04-comparticion.xml --target-org p04-posventa-dev --test-level NoTestRun --wait 3 --json
sf project deploy start --manifest manifest/sesion04-preparacion.xml --target-org p04-posventa-dev --test-level NoTestRun --wait 3 --json
sf project deploy start --manifest manifest/sesion04.xml --target-org p04-posventa-dev --test-level RunSpecifiedTests --tests P04ModeloTest --tests P04SeguridadTest --wait 3 --json
```

Resultado real final: Succeeded, 56 componentes, 40 pruebas, cero errores. Preparación previa: 30 componentes de compartición y 49 de permisos/configuración. Los intentos fallidos por dependencias y fixtures se revirtieron; no son despliegues satisfactorios. No se repitieron suites tras documentación o codificación PowerShell.

## Usuarios y escenarios reproducibles

Los siguientes valores son referencias privadas del operador, nunca literales que deban subirse a Git:

```powershell
./scripts/New-SecurityUser.ps1 -ExpectedOrgId '<P04 verificada>'
./scripts/New-SecuritySample.ps1 -ExpectedOrgId '<P04 verificada>'
./scripts/Set-SecurityScenario.ps1 -ExpectedOrgId '<P04 verificada>' -ExpectedUserId '<usuario de prueba>' -Scenario Ninguno
./scripts/Set-SecurityScenario.ps1 -ExpectedOrgId '<P04 verificada>' -ExpectedUserId '<usuario de prueba>' -Scenario Agente
./scripts/Set-SecurityScenario.ps1 -ExpectedOrgId '<P04 verificada>' -ExpectedUserId '<usuario de prueba>' -Scenario Responsable
./scripts/Set-SecurityScenario.ps1 -ExpectedOrgId '<P04 verificada>' -ExpectedUserId '<usuario de prueba>' -Scenario Ninguno
./scripts/Remove-SecuritySample.ps1 -ExpectedOrgId '<P04 verificada>'
```

No ejecutar la lista de escenarios seguida sin sus comprobaciones intermedias. New-SecurityUser verifica licencia disponible y crea/reutiliza un único usuario de perfil mínimo y sin rol; no envía correos. New-SecuritySample requiere los clientes de sesión 03, los marca P04 y crea solo dos casos, abortando si ya hay temporales. IDs en .local/s04-user.json y s04-records.json.

Para probar propiedad, asignar administrativamente el primer caso temporal al usuario antes del escenario Agente. No asignar la muestra original. En cada escenario consultar PermissionSetAssignment (incluido PermissionSetGroupId), GroupMember y UserRecordAccess para cliente, contacto, producto y casos propio/ajeno. Validar primero los IDs privados, no pegarlos a documentación pública. El script de escenarios aborta ante permisos o membresías ajenos a su alcance.

Secuencia UI:

1. Entrar como usuario ordinario mediante Login As autorizado y comprobar su identidad. Registrar el valor previo de Login Access Policies; si se habilita para la prueba, restaurarlo al final. No leer ni establecer contraseñas.
2. Agente: abrir caso temporal propio, editar asunto y guardar; consultar producto sin edición de compra/garantía; abrir por URL un caso P04 de otro propietario, que debe denegarse sin asunto.
3. Retirar concesiones del agente, aplicar responsable y renovar contexto. Corregir temporalmente garantía con fecha válida; verificar persistencia y restaurar el valor original. Reasignar el segundo caso temporal al integrante activo del equipo, con Send notification email desactivado.
4. Retirar conjuntos y grupos; comprobar en servidor cero acceso, incluso manteniendo la propiedad. Recargar/acceder por URL al caso propio en el navegador ordinario: denegación efectiva.
5. Salir del usuario, eliminar solo temporales con Remove-SecuritySample y restaurar la política administrativa. Comprobar ocho registros originales, garantía original y usuario mínimo.

Se ejecutaron New-SecurityUser, New-SecuritySample, Set-SecurityScenario y Remove-SecuritySample. Las escrituras UI de agente, garantía y reasignación se confirmaron mediante lectura administrativa; esa consulta no se atribuye al usuario ordinario. Evidencias filtradas en .local. Sin OAuth ordinario independiente: no se afirma prueba REST restringida.

## Pruebas Apex y resultados

```powershell
./scripts/Test-Seguridad.ps1 -ExpectedOrgId '<P04 verificada>'
```

El wrapper queda para repetición independiente y se revisó su sintaxis; las 40 pruebas de esta entrega se ejecutaron realmente dentro del despliegue RunSpecifiedTests, no mediante una segunda ejecución del wrapper.

P04SeguridadTest: 20 pruebas con dos agentes aislados, responsable y usuario sin permisos. Acciones restringidas con USER_MODE dentro de System.runAs; fixtures administrativos en modo sistema y comparticiones explícitas de fixtures. Dos pruebas adicionales SYSTEM_MODE verifican el guardián y no sustituyen CRUD/FLS. Sin SeeAllData. La compartición por criterios desplegada se comprueba aparte con el usuario persistente.

| Contexto | Acción | Esperado y obtenido |
| --- | --- | --- |
| Agente USER_MODE | Crear/editar propio, lote 200 | Permitido |
| Agente USER_MODE | Caso ajeno/no compartido, padres y garantía | Rechazado |
| Responsable USER_MODE | Altas P04, corrección y casos de equipo | Permitido |
| Responsable USER_MODE | Reasignación dentro/fuera de equipo | Permitida/rechazada |
| Ambos USER_MODE | Siete campos de evaluación y borrados | Rechazados |
| Sin permisos y revocación USER_MODE | Lectura/escritura aun siendo propietario | Rechazadas |
| Ambos USER_MODE | Incoherencias del modelo anterior | Rechazadas |
| UI agente | Edición propia, producto solo lectura, URL ajena | Persistencia/solo lectura/denegación |
| UI responsable | Garantía y reasignación sin correo | Persistencia confirmada |
| UI tras revocación | URL del caso propio | Acceso denegado |

P04ModeloTest: 20/20 de regresión. Dos fixtures Master ahora usan un administrador aislado sin la concesión P04 de tipos, manteniendo aserciones de ámbito y comprobando RecordTypeId null. No se alteraron asignaciones del administrador real. El resto del contrato de integridad permanece.

Cobertura informada por el despliegue de sesión 04: P04Autorizacion 61/62 ubicaciones y cuatro triggers 10/10; total 71/72 de los componentes Apex informados. P04Integridad no cambió y no aparece en ese informe de cobertura; no atribuirle esa cifra ni trasladar la cobertura histórica a esta ejecución. Sin pruebas de concurrencia, colas, fusiones/undelete ni motor de evaluación.

## Histórico — sesión 03

El contenido siguiente describe la ejecución administrativa anterior y sus procedimientos, no el estado final ni las restricciones ordinarias de sesión 04.


# Comprobación del modelo — sesión 03

Usar únicamente la organización P04 identificada, alias p04-posventa-dev, API 68.0. Nunca establecer destinos predeterminados. No ejecutar en el Playground anterior ni consultar Gmail. No se necesita reinstalar herramientas.

## Despliegue acotado

manifest/sesion03.xml enumera 36 componentes, sin comodines ni destructivos: 12 campos, nueve validaciones, dos tipos de registro, un proceso de soporte, CaseStatus, dos layouts, una aplicación, un permiso administrativo, asignaciones de layout Admin, dos clases y cuatro triggers.

CaseStatus conserva los cuatro valores originales New/Working/Escalated/Closed y añade cuatro P04. Antes de repetir un despliegue, contrastar el estado actual: si alguien ha añadido o modificado valores fuera de este paquete, reconciliarlos expresamente antes de enviar el archivo. No desactivar valores ajenos. El perfil contiene solo dos asignaciones de layout por tipo P04, no permisos generales ni asignaciones master.

```powershell
sf data query --target-org p04-posventa-dev --query 'SELECT Id, OrganizationType FROM Organization' --json
sf project deploy start --metadata StandardValueSet:CaseStatus --target-org p04-posventa-dev --test-level NoTestRun --wait 2 --json
sf project deploy start --manifest manifest/sesion03.xml --target-org p04-posventa-dev --test-level RunSpecifiedTests --tests P04ModeloTest --wait 2 --json
```

Comprobar el identificador contra el destino conocido antes de escribir, sin copiarlo a Git. Si un despliegue sigue en curso, consultar su identificador con project deploy report, no iniciar otro. Un despliegue completo fallido revierte sus cambios; los pasos anteriores ya completados permanecen. La vista previa de CLI no está disponible aquí por ausencia de source tracking; revisar manifiesto, XML y dependencias antes del envío.

El proceso de soporte referencia las etiquetas de CaseStatus; validaciones y registros usan los nombres API P04_*. El layout estándar exige SuppliedEmail presente y OwnerId editable, no marcado Required. SuppliedEmail permanece vacío en la muestra: no se envían comunicaciones.

## Pruebas Apex

```powershell
./scripts/Test-Modelo.ps1 -ExpectedOrgId '<identificador P04 verificado>'
```

La identidad es obligatoria y se comprueba antes de ejecutar. Las 20 pruebas no usan SeeAllData; crean fixtures propios que Salesforce revierte automáticamente. En API 68.0 el acceso por defecto de Apex es modo usuario: las pruebas de integridad emplean DML/SOQL en modo sistema explícito para no depender de asignaciones de permisos aún no aplicadas durante el despliegue. Las consultas del guardián también declaran WITH SYSTEM_MODE para detectar referencias aunque el usuario no pueda verlas. Esto no otorga acceso de lectura al usuario ni sustituye pruebas CRUD/FLS. [Cambio oficial del modo predeterminado](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/versioned-behavior-changes.html).

| Comprobación | Resultado esperado |
| --- | --- |
| Recorrido válido | Guardado y resultado/momento/motivo de garantía vacíos |
| Campos obligatorios | Rechazo explícito, sin persistencia |
| Contacto del producto/caso de otro cliente o sin cliente | Rechazo |
| Producto de otro cliente o fuera de P04 | Rechazo |
| Fin de garantía anterior al inicio | Rechazo; fechas iguales admitidas |
| Garantía incompleta/contacto de producto opcional | Aceptados; no se calcula evaluación |
| Incidencia futura | Rechazo; día actual admitido |
| Incidencia anterior a compra | Rechazo; mismo día admitido |
| Edición inválida | Rechazo y conservación de valores previos |
| Estados y cambio de tipo de registro | Cuatro estados propios; no salir de P04; Cerrado implica IsClosed |
| Cambio de cliente de contacto utilizado | Rechazo, tanto si referencia producto como solo caso |
| Cambio de cliente/compra del producto con casos | Rechazo si rompe contrato; compra igual a incidencia o vacía admitida |
| Cambio válido de garantía del producto | No modifica ni genera evaluación |
| Borrados de padres referenciados | Rechazo; borrado ordenado de datos propios permitido |
| Registros fuera del ámbito P04 | No se aplican restricciones P04 |
| Lote de 200 casos válidos | 200 inserciones y 200 ediciones correctas |
| Lote mixto de 200 | 100 guardados y 100 rechazados con motivo esperado |
| Lote de 200 contactos y 200 productos con casos | 400 cambios incoherentes rechazados |
| Producto sin casos | Puede cambiar de cliente si mantiene coherencia de contacto |

La fecha de referencia en Apex es Date.today(), del usuario ejecutor, como TODAY() en validación. Los tests no prueban concurrencia ni fusiones/undelete. No hay motor de evaluación ni máquina de estados completa; el test de estados comprueba disponibilidad e IsClosed, no autoriza afirmar transiciones restringidas.

## Demostración y API real

Después de un despliegue satisfactorio, asignar P04_DemoAdmin solo al administrador actual, previa comprobación de identidad y perfil. El permiso no concede ModifyAllData ni permisos CRUD amplios; habilita los campos propios, tipos y app. No crear usuarios para esta sesión.

```powershell
sf org assign permset --name P04_DemoAdmin --target-org p04-posventa-dev --json
./scripts/New-Demo.ps1 -ExpectedOrgId '<identificador P04 verificado>'
./scripts/Test-Api.ps1 -ExpectedOrgId '<identificador P04 verificado>'
```

La muestra deja ocho registros: dos clientes, dos contactos sin datos de comunicación, dos productos y dos casos. AccountNumber P04-S03-DEMO-A/B permite encontrarlos. Un producto tiene garantía completa y el otro incompleta; ambos casos siguen sin evaluar. Si la muestra ya existe, el script se detiene sin duplicarla ni modificarla. Sus identificadores solo se guardan en .local/s03-demo.json, ignorado. No borrar la muestra al finalizar: queda para revisión de Alex.

Test-Api crea un caso temporal y verifica creación, edición, rechazo de fecha futura, rechazo de contacto de otro cliente y consulta de valores conservados. Finalmente elimina únicamente los identificadores devueltos por sus propias creaciones; no elimina la muestra ni registros ajenos. La fecha futura usa UTC+2 días, que supera el día local actual de cualquier zona; la prueba del límite exacto del día se realiza en Apex. Una eliminación ordinaria puede dejar un registro temporal en papelera; no ejecutar purgas globales.

## Interfaz estándar

Abrir la aplicación P04 Posventa. Consultar el cliente/contacto, el producto y el caso de muestra. En producto: comprobar cliente, contacto, compra y fechas de garantía. En caso: comprobar relaciones, incidencia, estado y evaluación vacía; editar asunto y guardar. Confirmar por API la persistencia. Verificar que el layout propio corresponde solo al tipo P04 y que las asignaciones master originales se conservan.

Registrar resultados reales en STATUS, incluidos despliegue, pruebas Apex/API, consulta/edición UI y datos residuales. Una prueba administrativa no acredita acceso de agente, responsable o usuario sin permisos. La siguiente fase será esa seguridad por función con la única plaza Salesforce libre.
## Resultado ejecutado

20/20 pruebas Apex y cinco comprobaciones API satisfactorias. Cobertura del guardián y triggers: 74/74 ubicaciones según el despliegue. Consulta y edición reales de producto y caso en la interfaz estándar confirmadas por lectura API; layouts Master conservados. Se abrieron los controles por evento DOM ante problemas de coordenadas. Tras comprobar el campo editado, el guardado se realizó enfocando Save y pulsando Enter; los intentos previos sin persistencia no se contaron como éxito. No se omitió validación de Salesforce.

Las 20 pruebas se ejecutaron con el despliegue completo mediante RunSpecifiedTests/P04ModeloTest. El script Test-Modelo.ps1 queda como procedimiento para repetirlas por separado; se comprobó su sintaxis, pero no se atribuye otra ejecución independiente a ese script. New-Demo.ps1 y Test-Api.ps1 sí se ejecutaron en la organización identificada, conservando la muestra y eliminando únicamente el caso temporal de la prueba API.

La prueba de cambio de tipo no trata null como cambio: Master puede fallar por una restricción nativa antes de llegar al trigger. Se comprueba ese rechazo y el tipo persistido, y el guardián se verifica además directamente mediante sus errores. No se confunden las dos evidencias.

La muestra conserva ocho registros ficticios. Los fixtures Apex se revirtieron; el caso temporal API se eliminó. Cifras y límites finales en STATUS. La siguiente fase de seguridad por función aún no se ha ejecutado.
