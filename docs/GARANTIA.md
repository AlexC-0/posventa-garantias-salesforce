# Evaluación de garantía — sesiones 05–06

Sesión 07 añade [CONSULTA](CONSULTA.md), LWC de solo lectura sin nuevos campos ni cambios en las reglas de garantía/ciclo. Lecturas USER_MODE, hasta cinco relacionados visibles y actualización explícita; resultados actuales en STATUS.

Implementación: P04Garantia, adaptador P04EvaluarGarantiaAccion y pruebas P04GarantiaTest. API 68.0. Resultado de ejecución y límites de la evidencia en [STATUS](STATUS.md).

## Contrato de cálculo

El único cálculo está en P04Garantia.calcular. La fecha de referencia es Case.P04_FechaIncidencia__c; los límites de garantía son inclusivos.

| Datos válidos | Resultado | Motivo |
| --- | --- | --- |
| Incidencia entre inicio y fin, incluidos ambos | En_cobertura | Dentro del intervalo |
| Incidencia anterior al inicio | Fuera_cobertura | Anterior al inicio |
| Incidencia posterior al fin | Fuera_cobertura | Posterior al fin |
| Falta inicio, fin o ambos | Pendiente_datos | Identifica exactamente qué falta |
| Compra ausente, garantía completa | Se evalúa normalmente | Compra opcional |

Vacío sigue significando sin evaluar. No se genera Pendiente_datos por la ausencia de compra. Relaciones incoherentes, incidencia futura/anterior a compra e intervalo invertido son errores, nunca resultados de cobertura. Se conserva Date.today() del usuario ejecutor para el día actual; las fechas Date no se convierten a DateTime para compararlas. System.now() se usa solo para el momento de evaluación.

El servicio vuelve a validar los datos recuperados. No desactiva ni sustituye las nueve validaciones ni P04Integridad. Estas validaciones defensivas no son una segunda implementación del cálculo de cobertura.

## Instantánea y reevaluación

En una única actualización se guardan los siete campos existentes: resultado, motivo, compra/inicio/fin/incidencia utilizados y momento. Las fechas opcionales ausentes se copian como null, también al reevaluar una instantánea anterior.

Se admite primera evaluación y reevaluación explícita mientras el caso está abierto. Ambas usan los datos actuales del servidor. Modificar Asset o la fecha de incidencia del Case no cambia silenciosamente la instantánea: puede dejarla histórica respecto a los datos actuales. El resultado refleja lo utilizado en su momento, no un cálculo vivo. Solo otra petición explícita reemplaza esa instantánea.

Los casos cerrados se rechazan, evaluados o no; se conserva su instantánea anterior. La sesión 06 aplica transiciones, condiciones de resolución y prohibición de reapertura mediante P04Ciclo: véase [CICLO](CICLO.md). Un caso nuevo ya no puede llegar a Cerrado sin evaluación.

## Entrada y correspondencia de resultados

Apex, un caso o varios:

```apex
List<P04Garantia.Resultado> respuestas =
    P04Garantia.evaluar(new List<String>{String.valueOf(casoId)});
```

Invocable, acción «Evaluar garantía P04»:

```apex
P04EvaluarGarantiaAccion.Solicitud solicitud =
    new P04EvaluarGarantiaAccion.Solicitud();
solicitud.casoId = String.valueOf(casoId);
List<P04Garantia.Resultado> respuestas =
    P04EvaluarGarantiaAccion.ejecutar(
        new List<P04EvaluarGarantiaAccion.Solicitud>{solicitud});
```

El llamante aporta únicamente identificadores. No puede suministrar cobertura, fechas calculadas, usuario a suplantar ni flags de privilegios. El adaptador solo transforma la lista y llama al mismo servicio, sin cálculo o DML propio. La sesión 06 añade P04_EvaluarGarantia en contexto de usuario y la acción de ficha, sin duplicar cálculo ni escribir registros desde Flow.

La respuesta de cada posición contiene correcto, codigo, mensaje y cobertura. Esta última solo se devuelve cuando el lote se guardó. El número y orden coinciden con las solicitudes, también en errores y duplicados. Lista null/vacía devuelve lista vacía. Más de 200 solicitudes devuelve LIMITE_LOTE para cada una sin consultar ni escribir.

Las cadenas se recortan y convierten a Id; una vacía, null, mal formada o de otro objeto es ENTRADA_INVALIDA. Los IDs de Case se normalizan y deduplican: se consultan/calculan/actualizan una sola vez, manteniendo las respuestas de las posiciones repetidas. Un ID bien formado pero inexistente, no visible o fuera de P04 recibe el mismo NO_AUTORIZADO que otro caso no permitido.

## Lotes atómicos y errores

La política es **todo o nada por llamada**, no éxito parcial. Con una entrada rechazada no se escribe ninguna evaluación. Esa posición devuelve su error y las posiciones que habrían sido válidas reciben LOTE_RECHAZADO. Las instantáneas previas permanecen intactas.

| Código | Significado |
| --- | --- |
| OK | Instantánea guardada |
| ENTRADA_INVALIDA | No se proporcionó un identificador de Case válido |
| LIMITE_LOTE | Más de 200 solicitudes |
| NO_AUTORIZADO | Operación/datos no disponibles para el ejecutor; no distingue existencia |
| CASO_CERRADO | Solo para un caso autorizado; conserva evaluación |
| DATOS_INVALIDOS | Datos incoherentes de un caso autorizado |
| LOTE_RECHAZADO | Otro elemento impide guardar el lote |
| GUARDADO_RECHAZADO | DML rechazado; ninguna evaluación de la llamada guardada |

Las lecturas fallidas no exponen mensajes internos, IDs ni detalles de campos ocultos. La escritura usa Database.update con allOrNone=true; un DmlException se traduce a error seguro. Los límites irrecuperables de plataforma no se capturan artificialmente: abortan la transacción. El Screen Flow de sesión 06 interpreta correcto/codigo antes de mostrar confirmación.

No hay consultas ni DML por registro. El servicio bloquea los casos y productos consultados durante la transacción y realiza una sola actualización de las instantáneas. La llamada no hace callouts. No se afirma una prueba de concurrencia entre transacciones ni garantías adicionales sobre cambios simultáneos de permisos/padres.

## Seguridad y escritura privilegiada

La entrada comprueba permisos personalizados P04_Usar/P04_Gestionar o P04_Administrar y CRUD de edición de Case. El agente solo evalúa sus casos; el responsable evalúa casos P04 editables de su equipo. El administrador conserva su vía explícita para preparación/demostración, sin usarla como prueba de permisos ordinarios.

Todas las lecturas de negocio usan WITH USER_MODE, incluidos clientes, contactos, productos y sus campos. UserRecordAccess comprueba HasEditAccess para el usuario actual; se combina con la lectura USER_MODE porque ese indicador por sí solo no aplica todas las restricciones. Un responsable con solo lectura tampoco puede evaluar. Si falta acceso a datos necesarios, se rechaza sin exponerlos.

Solo después de autorizar y calcular el lote se construye un mapa privado con los IDs y siete valores esperados. El servicio escribe exclusivamente esos siete campos con SYSTEM_MODE para superar únicamente su FLS de edición, que sigue desactivado para agente/responsable. No actualiza propietario, estado, asunto ni relaciones.

P04Autorizacion consulta un predicado público de solo lectura, escrituraLegitima: exige contexto privado preparado por el servicio, ID exacto, caso anterior abierto, siete valores exactos y ausencia de diferencias en cualquier otro campo. No hay setter público, bypass global ni @TestVisible sobre ese contexto. Finalmente se limpia, tanto si guarda como si falla. El resto del guardián y P04Integridad siguen ejecutándose.

Los conjuntos P04_Agente/P04_Responsable/P04_DemoAdmin solo añaden acceso a las dos clases de entrada; no se amplían CRUD/FLS ni grupos/compartición. La acción de sesión 06 conserva la seguridad de clase Apex y añade RunFlow y acceso al Flow, sin ampliar FLS. Referencias oficiales: [invocables y correspondencia de resultados](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-classes-annotation-invocablemethod.html), [UserRecordAccess y sus límites](https://developer.salesforce.com/docs/platform/object-reference/references/standard-objects/object-userrecordaccess.html), [modos de acceso Apex](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-classes-enforce-usermode.html).

## Demostración y comprobaciones

```powershell
./scripts/Demo-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
./scripts/Test-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
```

Demo-Garantia verifica organización y permiso administrativo. Crea un producto y un caso temporales relacionados con un cliente/contacto de muestra; evalúa dentro de cobertura, corrige el producto, comprueba conservación histórica, reevalúa explícitamente mediante el adaptador y rechaza reevaluación tras cerrar. Un savepoint revierte exclusivamente las operaciones de la demo, también si falla. Se comprueba que ambos registros ya no existen. No modifica productos/casos originales ni envía notificaciones.

La demo es administrativa. Las pruebas de agente, responsable y sin permisos están en Apex con usuarios aislados y acciones del servicio ejecutadas bajo System.runAs; las consultas del servicio conservan USER_MODE. No se afirma una prueba UI/REST ordinaria nueva. No se crea otro usuario persistente ni se cambia Login Access Policies.

Pruebas de datos inválidos imposibles de persistir por las validaciones existentes usan el validador defensivo privado expuesto solo a tests, con datos en memoria, sin desactivar reglas. Se distinguen de los casos positivos y negativos con consultas y resultados persistidos. Resultados concretos, regresiones y cobertura se registran tras el despliegue en STATUS.
