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
