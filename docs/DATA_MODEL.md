# Modelo de datos

La [consulta LWC](CONSULTA.md) presenta datos de solo lectura sin nuevos campos ni cambios en las reglas de garantía/ciclo. Lecturas USER_MODE, hasta cinco relacionados visibles y actualización explícita; resultados actuales en STATUS.

Contrato del modelo. API 68.0. Datos ficticios; garantía simulada.

La implementación de seguridad añade exclusivamente Account.P04_Posventa__c (Checkbox, false por defecto) como identificador de clientes del proyecto. El responsable crea clientes marcados mediante P04Autorizacion; no puede convertir cuentas ajenas ni desmarcar clientes. Solo administración incorpora los dos clientes de demostración existentes. Contact hereda el acceso de Account; productos y casos conservan sus tipos. Hay 13 campos propios en total. Autorización y compartición se detallan en [SECURITY](SECURITY.md); las restricciones de integridad siguientes permanecen vigentes. Las conversiones de registros ajenos mencionadas en el contrato original requieren ahora administración.

## Ámbito y relaciones

Account representa un cliente empresarial y Contact una persona de ese cliente. Se conservan sus campos y disposiciones estándar. Asset usa el tipo de registro P04_Producto (Producto de posventa) y Case P04_Posventa (Caso de posventa). Las reglas se limitan a esos tipos; un caso P04 debe referenciar un Asset P04. No se convierten registros de origen.

Account 1 → N Contact; Account 1 → N Asset; Account 1 → N Case. Asset.ContactId es opcional; Case.ContactId y AssetId son obligatorios para P04. No se exige que el contacto del caso sea el contacto opcional del producto, solo que ambos pertenezcan al cliente correcto.

Tipos de registro delimitan funcionalidad, no constituyen seguridad por función. Los triggers impiden sacar un registro ya P04 de su tipo para eludir restricciones. Convertir un registro ajeno a P04 implica validarlo al guardar; no se convirtieron datos de origen.

## Campos reutilizados y propios

| Objeto | Nombre API | Tipo | Contrato |
| --- | --- | --- | --- |
| Account | Name | Texto estándar | Nombre de cliente obligatorio por plataforma |
| Contact | LastName, FirstName, AccountId | Texto, relación | Apellidos requeridos por plataforma; cliente obligatorio cuando se usa en relaciones P04 |
| Asset | Name, SerialNumber | Texto estándar | Nombre/modelo requerido; serie opcional |
| Asset | AccountId, ContactId | Relaciones estándar | Cliente requerido; contacto opcional del mismo cliente |
| Asset | PurchaseDate | Date estándar | Compra opcional; si existe limita la fecha de incidencia |
| Asset | P04_InicioGarantia__c, P04_FinGarantia__c | Date | Opcionales; con ambas fechas, fin >= inicio |
| Case | AccountId, ContactId, AssetId | Relaciones estándar | Las tres requeridas y del mismo cliente; Asset de tipo P04 |
| Case | Subject, Description | Texto estándar | Asunto requerido en P04; descripción opcional |
| Case | Status, OwnerId, Origin | Campos estándar | Estado P04, propietario estándar y origen; se conserva su mecánica de plataforma |
| Case | P04_FechaIncidencia__c | Date | Requerida, <= día actual del usuario y >= compra conocida |
| Case | P04_ResultadoGarantia__c | Picklist restringida | Vacío = sin evaluar; valores En_cobertura, Fuera_cobertura, Pendiente_datos, sin valor por defecto |
| Case | P04_MotivoGarantia__c | Text(255) | Motivo calculado por P04Garantia; vacío hasta evaluar |
| Case | P04_CompraEvaluada__c, P04_InicioEvaluado__c, P04_FinEvaluado__c, P04_IncidenciaEvaluada__c | Date | Instantánea explícita de los datos usados; ausencias copiadas como null |
| Case | P04_EvaluadaEl__c | DateTime | Momento de evaluación, vacío inicialmente |
| Case | P04_TipoResolucion__c | Picklist restringida | Reparacion, Sustitucion, Fuera_cobertura, Sin_actuacion; sin defecto |
| Case | P04_ExplicacionResolucion__c | LongTextArea(2000) | Explicación con contenido obligatoria al cerrar |

Etiquetas y ayudas propias en castellano. Los siete campos de evaluación son de solo lectura para agente/responsable mediante FLS y guardián. P04Garantia permite exclusivamente su escritura calculada tras autorizar la operación. El administrador conserva sus permisos administrativos. Los ocho registros originales de muestra siguen sin evaluar; la demostración del servicio usa registros temporales revertidos.

## Reglas de integridad

Validaciones en servidor al guardar Asset/Case, también por API: campos obligatorios; coherencia de cliente/contacto/producto; intervalo de garantía; incidencia no futura ni anterior a compra; estados limitados a los cuatro valores P04. Cada comparación de fechas opcionales comprueba explícitamente null antes de comparar.

Se usa TODAY() para fechas futuras y Date.today() en las pruebas: día del usuario ejecutor, sin convertir a DateTime ni usar el reloj del equipo. Las fechas no tienen zona horaria; el límite diario sí depende de la zona del usuario. Un mismo instante puede dar días distintos a usuarios de zonas distintas. [Referencia de TODAY](https://help.salesforce.com/s/articleView?id=platform.customize_functions_today.htm&language=en_US&type=5).

P04Integridad protege padres sin calcular cobertura: rechaza cambio de cliente de Contact referenciado, cambio de cliente de Asset con casos y compra posterior a una incidencia existente. Quitar la compra sigue permitido. Corregir garantía no cambia la evaluación. Protege el borrado de padres referenciados; el borrado administrativo ordenado de datos propios es posible, pero la seguridad por función prohíbe borrado ordinario a agente/responsable.

Los controles son masivos y se ejecutan sin depender de visibilidad ni permisos de campo (without sharing y consultas WITH SYSTEM_MODE explícitas, limitado a comprobaciones de integridad). No constituyen una API para leer datos. Se prueban escrituras secuenciales y lotes hasta 200; concurrencia entre transacciones, importaciones que omitan triggers y efectos especiales de fusiones/undelete no se declaran garantizados. No se deshabilitan automatismos de origen.

## Estados y presentación

Se añaden P04_Nuevo (Nuevo), P04_EnCurso (En curso), P04_PendienteInformacion (Pendiente de información) y P04_Cerrado (Cerrado, closed=true) a CaseStatus conservando todos los valores previos. Proceso de soporte P04_Posventa, por defecto P04_Nuevo, y tipo de registro propio. No se alteran procesos ajenos. La API se valida expresamente porque un tipo de registro no restringe por sí solo todos los valores escritos por API.

Layouts de producto/caso y aplicación Lightning P04 Posventa. Case incluye SuppliedEmail por requisito de plataforma, vacío en la muestra; OwnerId tiene control estándar y autorización de servidor. Se conservan los layouts ajenos. P04_Minimo también asigna los layouts propios y añade cliente/contacto; permisos ordinarios separados de P04_DemoAdmin, reservado al administrador. Con el servicio de garantía, los conjuntos incorporan acceso a las clases de evaluación sin ampliar FLS de edición.

## Evaluación y ciclo

1. Rechazar primero relaciones y fechas incoherentes. Los errores no son un resultado de garantía.
2. Con datos válidos pero sin fechas necesarias, resultado Pendiente_datos; no confundir con vacío/sin evaluar.
3. Con datos completos, evaluar la fecha de incidencia con límites inclusivos de garantía.
4. Registrar resultado, motivo, compra/inicio/fin/incidencia utilizados y momento. Editar Asset no recalcula casos.
5. Reevaluación explícita solo de abiertos; cerrados conservan evaluación.
6. P04Ciclo exige propietario individual activo, habilitado y miembro; resolución/explicación; evaluación registrada y fechas vigentes. Pendiente_datos solo permite Sin_actuacion explicado. Matriz, inmutabilidad y Flow de cola en [CICLO](CICLO.md).

Los puntos 1–5 corresponden al servicio único de garantía; el punto 6, al control de ciclo. La compra es opcional: sin ella puede existir cobertura si inicio y fin están presentes. Una edición posterior de producto o incidencia no recalcula la instantánea, que queda histórica hasta otra petición explícita. Detalle de atomicidad, seguridad y códigos en [GARANTIA](GARANTIA.md). Garantía, ciclo, consulta LWC e [informe](INFORME.md) utilizan los campos existentes, sin añadir otros.
