# Seguridad por función — V1

El informe dispone de la carpeta P04_Posventa compartida únicamente con P04_Responsables en nivel View. P04_Responsable recibe RunReports y la pestaña Reports; no recibe creación/edición de informes, administración de carpetas, View All ni Modify All. La carpeta no concede acceso a los registros: el informe aplica permisos, compartición y ámbito P04. Ejecución ordinaria y revocación por URL directa en [STATUS](STATUS.md); contrato en [INFORME](INFORME.md).

La [consulta LWC](CONSULTA.md) presenta datos de solo lectura sin nuevos campos ni cambios en las reglas de garantía/ciclo. Lecturas USER_MODE, hasta cinco relacionados visibles y actualización explícita; resultados actuales en STATUS.

Evaluación de garantía: [P04Garantia](GARANTIA.md) permite evaluación explícita de casos propios del agente y casos editables del responsable. Conserva CRUD/FLS, grupos y compartición. Los conjuntos solo añaden acceso a las clases del servicio/adaptador. La excepción de escritura se limita a siete valores calculados e IDs autorizados mediante contexto privado, sin interruptor público; el guardián sigue rechazando ediciones directas. Regresión de estas 20 pruebas de seguridad y las 20 de modelo: sin fallos, junto con 25 pruebas nuevas de garantía. La evidencia UI descrita abajo corresponde a la comprobación inicial de seguridad, no una ejecución nueva.

Implementada en P04, API 68.0. Despliegue completo: 56 componentes y 40 pruebas Apex satisfactorias (20 de modelo y 20 de seguridad). Cierre operativo y revisión local en [STATUS](STATUS.md).

Ciclo: [CICLO](CICLO.md) incorpora entrada a cola, toma propia y asignación del responsable con permiso y membresía efectiva. La cola incluye los dos grupos existentes; Case continúa Private y no se amplía la compartición individual con agentes. Las cifras anteriores son evidencia histórica. Los resultados de la V1 se registran en STATUS.

## Matriz

| Capacidad | Agente | Responsable | Sin permisos P04 |
| --- | --- | --- | --- |
| Clientes, contactos y productos P04 compartidos | Lectura | Lectura, alta y edición | Sin acceso |
| Crear caso P04 | Sí, inicialmente en cola | Sí, inicialmente en cola | No |
| Consultar/tomar cola | Con permiso y membresía, toma para sí | Con permiso y membresía, asigna a miembro habilitado | No |
| Editar caso propio | Sí | Sí | No |
| Casos de otros agentes | Sin acceso por defecto | Gestión del equipo P04 | Sin acceso |
| Compra y garantía | Solo lectura | Edición con validaciones | Sin acceso |
| Siete campos de evaluación | Solo lectura | Solo lectura | Sin acceso |
| Reasignar casos | Solo toma inicial de cola para sí | Solo a integrantes activos habilitados y miembros del equipo | No |
| Consultar y ejecutar informe P04 | Sin concesión | Sí, carpeta View y RunReports | Sin acceso |
| Borrar los cuatro objetos de negocio | No | No | No |

Los permisos CRUD/FLS y la compartición se combinan; las concesiones se acumulan. Compartir un registro no concede CRUD ni FLS. La propiedad tampoco evita esos controles. Los tipos de registro delimitan funcionalidad y criterios de compartición, pero no son una barrera de seguridad por sí mismos. El guardián añade restricciones de negocio en servidor.

## Perfil y permisos efectivos

P04_Minimo usa licencia Salesforce, sin lectura/alta/edición/borrado de Account, Contact, Asset ni Case. Conserva capacidades mínimas de interfaz y asigna layouts P04. P04_Agente y P04_Responsable conceden los objetos, campos, aplicación y tipos necesarios. ApiEnabled está en ambos conjuntos, no en el perfil base.

Se comprobaron los permisos realmente desplegados: cero ViewAllData/ModifyAllData, cero View All/Modify All de objetos, cero borrado y cero edición de evaluación. Los siete campos de evaluación tienen lectura en ambos conjuntos (14 concesiones). La consulta de asignaciones del usuario incluye conjuntos adicionales y grupos de conjuntos; retirar un conjunto no basta si otra fuente sigue concediendo acceso.

P04_DemoAdmin continúa reservado al administrador. Añade P04_Administrar para el guardián y acceso al nuevo campo de ámbito. P04_Agente concede P04_Usar y P04_Responsable concede P04_Gestionar. No asignar estos permisos personalizados por separado a personas ordinarias. El responsable necesita TransferAnyCase para la acción estándar; el guardián restringe ámbito y destinatarios.

Los campos protegidos de Case son P04_ResultadoGarantia__c, P04_MotivoGarantia__c, P04_CompraEvaluada__c, P04_InicioEvaluado__c, P04_FinEvaluado__c, P04_IncidenciaEvaluada__c y P04_EvaluadaEl__c. Con el servicio de garantía, los calcula exclusivamente el servicio explícito, manteniendo la prohibición de edición directa ordinaria.

## Compartición y efecto sobre la organización

| Objeto | Acceso interno anterior | Aplicado |
| --- | --- | --- |
| Account | ReadWrite | Private |
| Contact | ReadWrite | ControlledByParent |
| Asset | ReadWrite | Private |
| Case | ReadWriteTransfer | Private |
| Opportunity | ReadWrite | Private, dependencia de Account |

El acceso externo era Private y no se amplió. Se conservaron los 18 roles originales y los datos de formación. El usuario de pruebas no tiene rol. Los grupos P04_Agentes y P04_Responsables no incluyen superiores automáticamente y usan miembros directos. La cola P04_Entrada incorpora estos dos grupos, también sin superiores. Cualquier rol o grupo anidado adicional exige revisar la herencia.

Salesforce rechazó Account Private mientras Opportunity seguía ReadWrite. Se cambió únicamente sharingModel de Opportunity; no se concedió CRUD ordinario ni se modificaron sus datos. El cambio reduce la visibilidad general en esta organización dedicada, incluidos datos de formación, y conserva el acceso administrativo. La referencia está en .local/s04-baseline-*.json. No había reglas de compartición previas en los cuatro objetos.

Account.P04_Posventa__c es el único identificador adicional, false por defecto. Evita depender de nombres de clientes. El guardián marca altas del responsable y rechaza incorporar cuentas ajenas o quitar la marca. Administración marcó solo los dos clientes originales de demostración. Contact se delimita por Account; Asset y Case mantienen sus tipos P04.

Cinco reglas de criterios en tres archivos comparten clientes/productos en lectura con agentes y edición con responsables; los casos P04 solo se comparten en edición con responsables. Account no concede acceso adicional a Case ni Opportunity. Contact hereda Account. Las reglas de tipos emplean la etiqueta requerida por Metadata API. El procedimiento asigna conjuntamente permiso y grupo.

Resultados de UserRecordAccess después del recálculo, mediante consulta administrativa:

| Escenario | Cliente/contacto/producto | Caso propio | Otros casos P04 |
| --- | --- | --- | --- |
| Agente | Lectura, sin edición | Lectura y edición | Sin lectura ni edición |
| Responsable | Lectura y edición | Lectura y edición | Lectura y edición |
| Permisos y grupos retirados | Sin acceso | Sin acceso pese a propiedad | Sin acceso |

El acceso implícito de Account no abrió otros casos al agente. Salesforce indica HasTransferAccess y muestra Change Owner para un caso propio; el guardián rechaza su reasignación. Ese indicador nativo no es autorización final de negocio.

Estos resultados de UserRecordAccess pertenecen a la comprobación inicial de seguridad, cuando no existía cola. En la verificación del ciclo se comprueban consulta, toma y revocación de cola mediante Apex, y el recorrido de agente en UI; detalle en STATUS y TESTING.

## Autorización y modos de ejecución

P04Autorizacion se invoca desde los cuatro triggers antes de P04Integridad, incluyendo before delete. Restringe escrituras al proyecto, propiedad, destinatarios, evaluación y borrado. El alta ordinaria entra en cola y el agente miembro habilitado puede tomarla para sí; después solo edita sus casos. El responsable asigna/reasigna a usuarios activos con asignación directa de P04_Agente o P04_Responsable y membresía efectiva. Permiso y grupo cumplen funciones distintas. No se permite devolver casos a cola mediante una reasignación ordinaria libre.

La clase usa without sharing y consultas WITH SYSTEM_MODE exclusivamente para comprobar condiciones de autorización, incluida la marca de cliente, propiedad y habilitación del actor/destinatario. P04Cola consulta membresías y permisos con la misma finalidad limitada. No expone endpoints ni devuelve datos a personas usuarias. El rechazo es genérico: «P04: operación no autorizada». P04Integridad mantiene su finalidad separada: detectar referencias incluso no visibles para evitar incoherencias. Ninguno de estos usos acredita permisos de consulta ordinaria.

Las acciones de autorización de P04SeguridadTest usan consultas/DML USER_MODE dentro de System.runAs. Los fixtures administrativos y dos pruebas adicionales del guardián en SYSTEM_MODE están separados; estas últimas no sustituyen CRUD/FLS. Referencias: [modos de acceso versionados](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/versioned-behavior-changes.html), [operaciones en modo usuario](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-classes-enforce-usermode.html) y [arquitectura de compartición](https://architect.salesforce.com/docs/architect/fundamentals/guide/platform-sharing-architecture.html).

## Evidencia histórica de seguridad y procedimiento

Un único usuario persistente ocupa la segunda licencia Salesforce, sin rol, correo de bienvenida ni contraseña manipulada. El administrador permanece activo. Los usuarios Apex aislados (dos agentes, responsable, sin permisos y administrador de fixtures) se revierten con sus datos; no representan plazas persistentes adicionales.

P04ModeloTest conserva las 20 pruebas. Dos fixtures Master usan ahora un administrador aislado sin los tipos concedidos por P04_DemoAdmin: con el administrador real se observó que omitir RecordTypeId seleccionaba P04. Los fixtures comprueban que el tipo persistido es null/Master. No se retiraron permisos al administrador real ni se redujeron aserciones.

Los 20 tests nuevos cubren alta/edición propia, separación entre agentes, registros no compartidos, padres y garantía, gestión y reasignación dentro/fuera del equipo, siete campos de evaluación, borrado de los cuatro objetos, ámbito del responsable, revocación aun siendo propietario, integridad bajo ambos roles y lote de 200 casos. Los fixtures comparten registros explícitamente para aislar capas; las reglas de criterios reales se contrastaron aparte con el usuario persistente.

Secuencia: Ninguno → Agente → Responsable → Ninguno. Set-SecurityScenario retira conjuntos y grupos conocidos, aborta ante concesiones ajenas y aplica solo el escenario solicitado. Renovar contexto al cambiar de función y contrastar permisos y acceso efectivo. Procedimiento en [TESTING](TESTING.md).

En UI ordinaria: agente edita su caso, ve garantía de solo lectura y recibe denegación por URL de otro caso sin revelar su asunto; responsable modifica garantía y reasigna un caso a un integrante activo, con correo desactivado. Las tres escrituras persistieron, comprobadas mediante lectura administrativa posterior. No se atribuye esa lectura al usuario ordinario. La garantía se restauró al valor original. La app P04 Posventa y sus cuatro pestañas quedaron accesibles al responsable.

Después de retirar conjuntos y grupos, la URL del caso propio devolvió «You don't have access to this record» en el navegador ordinario. La auditoría confirmó ausencia de acceso a los seis registros comprobados, incluidos ambos casos temporales aún de su propiedad. No se interpreta un mero cambio visual como revocación. Los rótulos de pestañas ya abiertas pueden permanecer en caché; no se afirma que se borren datos ya vistos.

## Límites, limpieza y estado final

No se obtuvo autenticación OAuth independiente del usuario ordinario. No hay prueba REST con token ordinario: la evidencia restringida es UI y Apex USER_MODE; CLI/API administrativos preparan y contrastan. En la verificación de seguridad no se probaron colas; el ciclo añade las comprobaciones descritas en CICLO y TESTING. Siguen sin probarse concurrencia, jerarquías nuevas, fusiones/undelete y concesiones administrativas futuras.

Los resultados privados están en .local, fuera de Git. El usuario permanece activo en P04_Minimo, sin rol, conjuntos P04 ni grupos; puede reutilizarse secuencialmente sin crear otra plaza. Se conservaron los ocho registros originales, incluida la marca P04 de sus dos clientes. Remove-SecuritySample eliminó solo los dos casos temporales registrados, sin purga de papelera.

Login Access Policies estaba desactivado y se habilitó temporalmente para Login As sin credenciales. Se cerró la sesión ordinaria y se restauró Administrators Can Log in as Any User a false, comprobado tras recarga. No se accedió a Gmail. Los fallos de selectores o intentos de guardado sin persistencia no se contaron como éxito.

La evaluación se describe en [GARANTIA](GARANTIA.md); cola, asignación y cierre en [CICLO](CICLO.md). La consulta LWC y el informe están implementados y documentados en [CONSULTA](CONSULTA.md) e [INFORME](INFORME.md). STATUS conserva por separado los resultados y la restauración de cada verificación.
