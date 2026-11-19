# Ciclo de atención posventa

La [consulta LWC](CONSULTA.md) presenta datos de solo lectura sin nuevos campos ni cambios en las reglas de garantía/ciclo. Lecturas USER_MODE, hasta cinco relacionados visibles y actualización explícita; resultados actuales en STATUS.

El recorrido ordinario usa Case, la cola `P04_Entrada`, acciones estándar y la acción **Evaluar garantía**. El ciclo no realiza comunicaciones ni duplica el cálculo de cobertura; el LWC complementa la ficha con consulta de datos. Los resultados ejecutados se registran en [STATUS](STATUS.md); este documento describe el contrato.

## Entrada y asignación

`P04_EntradaCaso` es un Flow activo anterior al guardado, exclusivamente de creación. Busca el RecordType por DeveloperName y SobjectType y la cola por DeveloperName y Type; normaliza comparaciones con CASESAFEID. No contiene IDs ni depende de su etiqueta. En el alta ordinaria propia sustituye el propietario inicial por la cola. El trigger exige Nuevo, cola y usuario habilitado con membresía; rechaza altas dirigidas a otro agente. Una edición no ejecuta esta asignación.

Se conserva el canal administrativo ya existente (`P04_Administrar`) para preparación/importación explícita con propietario indicado. Ese canal no ejecuta el Flow de entrada y no elude las reglas de estados, cierre o inmutabilidad. No se concede a usuarios ordinarios. Las pruebas de creación con Flow usan usuarios ordinarios; los fixtures administrativos no acreditan ese recorrido.

La cola contiene los grupos públicos P04_Agentes y P04_Responsables. Ambos mantienen membresía directa y sin superiores; la cola también excluye superiores y no envía correos. No se añaden roles ni grupos anidados. P04Cola comprueba las relaciones efectivas GroupMember de la cola y sus dos grupos conocidos, además de asignación directa P04_Agente/P04_Responsable y usuario activo. También admite miembros directos de la cola, usados en fixtures aislados. No guarda en caché membresías ni permisos, por lo que una retirada se comprueba de nuevo.

Pertenecer a la cola no concede CRUD/FLS. Tener un permission set no da por sí solo pertenencia. El agente puede tomar un caso de la cola para sí, pero no apropiarse de otro agente ni devolver/reasignar libremente. El responsable miembro asigna y reasigna a personas activas, habilitadas y miembros del equipo. Las nuevas asignaciones a cola después de la entrada no forman parte del recorrido ordinario.

Case sigue Private. Mientras pertenece a la cola, lo consultan sus miembros con permisos. Tras la toma, el propietario lo gestiona y otros agentes dejan de verlo; la compartición existente con responsables conserva la supervisión. No se comparte individualmente con todo el grupo de agentes. Los responsables pertenecen a la cola a través del mismo grupo que recibe la compartición de casos; retirar ese grupo revoca ambas vías. La política presupone que no se añaden otras concesiones ajenas, roles o shares manuales en producción de esta demo.

## Estados y cierre en servidor

| Estado actual | Cambios permitidos |
| --- | --- |
| Nuevo | En curso |
| En curso | Pendiente de información, Cerrado |
| Pendiente de información | En curso, Cerrado |
| Cerrado | Ninguno |

P04Ciclo comprueba la matriz en el trigger, también para SYSTEM_MODE y administración. Crear directamente en otro estado o saltar estados falla; guardar sin cambiar estado no es una transición.

El cierre exige propietario individual activo con permiso P04 y membresía, tipo de resolución, explicación no vacía, evaluación con momento/resultado/motivo y coincidencia exacta de compra, inicio, fin e incidencia con las fechas evaluadas (incluidos null). Lee y bloquea el producto al comprobar la instantánea; no calcula cobertura. Si cambiaron fechas, hay que reevaluar explícitamente. Pendiente_datos solo admite Sin_actuacion explicado. No se imponen otras asociaciones entre cobertura y resolución.

Un cerrado no admite cambios en Status, OwnerId, RecordTypeId, AccountId, ContactId, AssetId, Subject, Description, Origin, Priority, SuppliedEmail/Name/Phone/Company, Type, Reason, ParentId, IsEscalated, fecha de incidencia, tipo/explicación de resolución ni los siete campos de evaluación. El control se aplica también a administración. Un guardado idéntico se admite; los campos técnicos de auditoría de Salesforce no se bloquean. El borrado ordinario ya está prohibido; administración conserva el borrado explícito de temporales. El cambio posterior de garantía del producto no reescribe casos cerrados.

## Evaluación desde la ficha

El QuickAction Case.P04_EvaluarGarantia abre P04_EvaluarGarantia, Screen Flow en DefaultMode (contexto de usuario). Recibe recordId, pide la evaluación explícita y llama a P04EvaluarGarantiaAccion. No escribe registros por su cuenta. Solo muestra confirmación cuando correcto=true y codigo=OK; en rechazo muestra codigo y mensaje seguros, y en fallo técnico un texto genérico sin $Flow.FaultMessage.

El servicio conserva lecturas USER_MODE, autorización por registro y su escritura sellada de siete campos. Esos campos siguen sin FLS de edición para agente/responsable. RunFlow y acceso al Flow habilitan la interacción, no un permiso administrativo. La acción no sustituye los controles del servicio. Los botones estándar Editar y Cambiar propietario siguen disponibles.

En la ficha Case de esta organización, Evaluar garantía aparece en el publicador de Feed. Si está contraído, seleccionar la pestaña y pulsar **Create new...** para desplegar su pantalla; después **Evaluar y guardar**. Finish termina la acción. Es presentación estándar de Salesforce, sin componente propio.

El cierre se ofrece con **Cerrar caso P04**, QuickAction estándar Update `Case.CloseCaseLightning_P04`. Propone Status=P04_Cerrado y recoge resolución/explicación; P04Ciclo vuelve a validarlo todo. El prefijo CloseCaseLightning permite la presentación específica de cierre en Lightning. Se evita modificar el ajuste general de soporte que oculta estados cerrados en la edición normal. La acción solo se añade al layout P04. Referencia: [acción estándar de cierre](https://help.salesforce.com/s/articleView?id=service.cases_set_up_lex_close_case.htm&language=en_US&type=5).

## Demostración reproducible

1. Confirmar organización dedicada y usuario reutilizable; aplicar escenario Agente con Set-SecurityScenario. Renovar sesión. No crear usuarios.
2. Desde P04 Posventa, crear un caso ficticio con prefijo **P04 S06 TEMP**, cliente/contacto/producto originales relacionados, incidencia válida y Nuevo. Comprobar propietario P04 Entrada posventa.
3. Tomarlo mediante la acción estándar de propietario o desde la vista de cola. Editar a En curso y comprobar que conserva propietario individual.
4. Ejecutar Evaluar garantía y comprobar confirmación y siete campos persistidos. Pasar a Pendiente de información y volver a En curso si procede.
5. Usar Cerrar caso P04 e intentar guardar sin resolución/explicación: debe rechazarse. Completar ambos y cerrar. Intentar reapertura desde Editar y evaluación desde el Flow: deben rechazarse sin cambiar la instantánea. El detalle del rechazo de edición puede estar dentro del aviso Error del formulario.
6. Contrastar las escrituras con lectura administrativa, distinguiendo ambas identidades. Reasignación entre dos agentes y revocaciones también se prueban con usuarios Apex aislados, sin licencias persistentes adicionales.
7. Eliminar únicamente los temporales identificados, volver a Ninguno, comprobar ocho originales y restaurar Login Access Policies si se utilizó Login As.

El script administrativo Demo-Garantia requiere ahora que el usuario reutilizable tenga temporalmente el escenario Agente para ser propietario válido del cierre. Sigue revirtiendo sus dos registros; no constituye demostración ordinaria. La evidencia de la interfaz ordinaria se registra por separado en STATUS.

Referencias oficiales: [colas y miembros](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-queue.html), [asignación de casos](https://help.salesforce.com/s/articleView?id=service.cases_assign.htm&language=en_US&type=5) y [acciones Flow](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-quickaction.html). Sin garantía adicional sobre concesiones administrativas ajenas ni concurrencia no probada.
