# Estado — Sesión 06 completada, pendiente de commit y push de Alex

18 de noviembre de 2026. Recorrido de creación, cola, gestión individual, evaluación explícita, seguimiento y cierre implementado y demostrado. Informe, LWC e integraciones quedan fuera; no se inicia otra fase.

## Punto de partida y Git

Ruta/raíz: C:\Users\kaosk\source\repos\posventa-garantias-salesforce. Rama main; origin https://github.com/AlexC-0/posventa-garantias-salesforce.git. Inicio limpio en HEAD/origin/main locales 70ecc63cd69c9bdced0337ec686352199e90c97b, publicado por Alex según el encargo. No se ha vuelto a consultar la punta remota. Se conserva HEAD; todos los cambios quedan locales sin staging. Codex no hizo staging, commit, push, tags ni releases.

Los resultados siguientes corresponden al árbol desplegado de sesión 06, no a ese commit base ni a CI. Organización dedicada y administrador contrastados antes de escribir; destino explícito p04-posventa-dev y API 68.0. CLI 2.158.7; extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13 conservados, sin instalaciones. Sin Gmail, otras organizaciones, comunicaciones ni nuevos usuarios persistentes.

## Implementación y decisiones

- Cola P04_Entrada con los grupos P04_Agentes y P04_Responsables, sin superiores ni correo. P04Cola verifica membresía efectiva, usuario activo y asignación directa del conjunto de permisos; no confunde estas condiciones.
- Flow P04_EntradaCaso anterior al guardado y solo de creación: resuelve tipo/cola por DeveloperName y normaliza IDs con CASESAFEID. P04Autorizacion admite entrada, toma propia y reasignación acotadas. Case sigue Private; tomar no comparte casos individuales con otros agentes.
- P04Ciclo, invocado por P04Caso, impone matriz, propietario habilitado, resolución/explicación, evaluación y vigencia exacta de compra/inicio/fin/incidencia, incluidos null. Pendiente_datos solo permite Sin_actuacion. Cerrado inmutable en los campos definidos en CICLO, incluso frente a administración.
- Screen Flow P04_EvaluarGarantia y acción de ficha reutilizan P04EvaluarGarantiaAccion en contexto de usuario. Solo correcto=true/codigo=OK confirma éxito. Los siete campos siguen sin edición ordinaria y P04Garantia no cambia.
- Acción estándar Cerrar caso P04 con estado cerrado predefinido y resolución/explicación; evita cambiar la configuración global de soporte. Las reglas críticas siguen en servidor.

Se conserva el canal administrativo de preparación/importación con propietario explícito mediante el permiso P04_Administrar existente. No ejecuta el Flow inicial, pero tampoco elude estados, cierre o inmutabilidad. No es una concesión nueva al usuario ordinario. No se añaden campos, perfiles, reglas de compartición ni permisos ViewAll/ModifyAll. Contrato y campos protegidos en [CICLO](CICLO.md).

## Despliegue y pruebas reales

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

## Recorrido comprobado en la interfaz

Identidad ordinaria reutilizable verificada, escenario Agente temporal. Un único Case ficticio de sesión 06, relacionado con cliente/contacto/producto originales; no se crearon otros registros de negocio persistentes.

1. Alta estándar: Nuevo y propietario cola, creados por el usuario ordinario.
2. Cambiar propietario a sí mismo, con notificación por correo desactivada; posterior edición a En curso conserva propietario individual.
3. Evaluar garantía desde Feed, desplegando Create new...: confirmación real y En_cobertura. Los siete valores quedan guardados por el usuario ordinario.
4. Seguimiento mediante Pendiente de información, persistido.
5. Cerrar caso P04 sin resolución/explicación: rechazo del servidor. Completar Reparacion y explicación: Cerrado persistido y los siete valores de evaluación conservados.
6. Editar a En curso: rechazo de reapertura. Evaluar de nuevo mediante Flow: CASO_CERRADO, sin pantalla de éxito. La lectura posterior confirmó estado, propietario, resolución e instantánea intactos.

Las consultas posteriores fueron administrativas y corroboran las escrituras UI; no son una prueba REST ordinaria. Reasignación entre dos agentes y revocación de cola se acreditan mediante Apex aislado, no mediante una nueva sesión UI de responsable. Guía breve reproducible en CICLO.

## Limpieza, estado final y límites

Auditoría satisfactoria: **ocho originales conservados** (dos clientes, contactos, productos y casos); sus dos casos siguen sin evaluar y la garantía/serie originales permanecen iguales. Se eliminó únicamente el Case temporal identificado de sesión 06, sin purga. Cero temporales activos de sesiones 04–06.

Usuario de pruebas activo en P04_Minimo, sin rol, conjuntos adicionales, grupos ni casos propios activos. Administrador preservado y único titular de P04_DemoAdmin. Dos licencias Salesforce, ambas ocupadas; ninguna cuenta nueva. La cola mantiene únicamente los dos grupos públicos previstos, sin usuarios directos ni superiores. Ambos Flows están activos.

Se salió de Login As, se restauró Administrators Can Log in as Any User a **false** y se verificó tras recargar la página. No se manipularon contraseñas. Los ocho registros de muestra no se utilizaron como casos de trabajo; solo como referencias del temporal.

No se prueban concurrencia real entre transacciones, roles/grupos anidados, shares administrativos ajenos, producción ni nuevas llamadas REST con token ordinario. El bloqueo del producto al cerrar no se presenta como una prueba de carrera real. Informe y LWC pendientes de otro encargo.

Evidencia privada excluida de Git: .local/s06-after-transfer-error.json (despliegue principal y tests), s06-close-action-deploy-2.json (acción/layout), s06-ui-*.json y s06-api-*.json (interfaz/persistencia), s06-final-audit.json, s06-policy-restored.json y s06-local-verification.json. Los archivos públicos no incluyen IDs privados, autenticaciones ni URLs de acceso.

## Revisión local y entrega

Revisión final satisfactoria: 120 archivos públicos UTF-8, 74 XML válidos, 12 scripts PowerShell sin errores de sintaxis, 38 enlaces locales existentes y 110 referencias de manifiestos resueltas sin comodines. Cinco exclusiones comprobadas (.local, .sf, .sfdx, .env y node_modules); búsqueda de identidades privadas y patrones de secretos sin hallazgos. git diff --check correcto. Estado final: main/70ecc63 conservados, 18 archivos modificados, 14 nuevos y cero en staging. Los avisos LF/CRLF proceden de la configuración Git existente, que se conserva. Las pruebas Apex no se repiten por cambios documentales o formato.

Archivos del cambio: P04Cola/P04Ciclo/P04CicloTest y metadatos; adaptación de P04Autorizacion, P04Caso y fixtures de las tres suites; cola, dos Flows, dos acciones, layout y tres permission sets; manifest/sesion06.xml, Test-Ciclo, adaptación de la demo administrativa anterior; README, AGENTS y documentación de ciclo, modelo, seguridad, garantía, pruebas, alcance y estado.

Alex revisa el diff y realiza staging, commit y push manualmente. Después se podrá comprobar el commit publicado. No se inicia el siguiente encargo.

Summary: `feat: completar el ciclo de atención posventa`

Description:

- Añade cola y asignación inicial con Flow, toma autorizada y reasignación por permiso y membresía.
- Aplica transiciones, cierre con evaluación vigente e inmutabilidad del cerrado en servidor.
- Incorpora evaluación explícita desde la ficha y acción estándar de cierre, conservando permisos e instantáneas.
- Supera 93 pruebas Apex y demuestra el recorrido con usuario ordinario; restaura concesiones y ajuste temporal, elimina el caso de demo y conserva los ocho originales.
- Actualiza manifiesto, pruebas reproducibles y documentación. Informe y LWC quedan para otro encargo.

## Histórico — Sesión 05 publicada en 70ecc63

La entrega siguiente se conserva como evidencia histórica de sesión 05. Sus pendientes, cifras y estados de publicación no describen el estado actual de sesión 06.

# Estado — Sesión 05 completada, pendiente de commit y push de Alex

18 de noviembre de 2026. Servicio único de evaluación de garantía desplegado y comprobado en P04. La sesión termina aquí: Flow, cola, ciclo completo, informes y LWC no se han iniciado.

## Punto de partida y Git

Ruta/raíz: C:\Users\kaosk\source\repos\posventa-garantias-salesforce. Rama main, origin https://github.com/AlexC-0/posventa-garantias-salesforce.git. Inicio limpio en HEAD/origin/main locales 4cfaf0bf3709d373fcaa75fc7a76b73dbd2cbbb3, publicación de sesión 04 indicada por Alex. No se hizo una nueva comprobación de la punta remota.

Se conservó ese HEAD y el trabajo queda sin staging. Codex no hizo commit, push, tags ni releases. Los resultados siguientes corresponden al árbol desplegado de sesión 05, no al commit anterior ni a CI.

Organización dedicada y API 68.0 comprobadas antes de escribir; clases base activas en esa versión. Alias explícito p04-posventa-dev en cada operación. Herramientas conservadas, sin instalaciones: CLI 2.158.7, Core/Apex/LWC 68.10.0 y JDK 21.0.13. Sin Gmail, otras organizaciones ni nuevos usuarios persistentes.

## Implementación y decisiones

P04Garantia recibe solo identificadores, valida rol, CRUD, lectura de registros/campos y acceso efectivo de edición, recupera datos en USER_MODE y calcula cobertura respecto a incidencia. Límites inclusivos, compra opcional, garantía incompleta pendiente de datos con motivo específico; incoherencias son errores. Guarda los siete campos existentes sin añadir campos al modelo.

P04EvaluarGarantiaAccion es un adaptador invocable sin cálculo ni DML propio. Los tres permission sets incorporan acceso a las dos clases; no se amplían CRUD/FLS, grupos ni compartición. P04Autorizacion solo permite los valores exactos calculados para los IDs autorizados por un contexto privado transitorio, sin setter público ni permiso global. Los campos continúan sin edición directa ordinaria.

La instantánea permanece histórica al modificar producto o incidencia. La reevaluación requiere otra petición explícita y usa los datos actuales. Un caso cerrado se rechaza sin modificar su evaluación; no se implementa el resto del ciclo.

Se decidió atomicidad por llamada (hasta 200 solicitudes). Duplicados se deduplican para consulta/cálculo/DML, manteniendo una respuesta por posición. Si una entrada falla, las otras no se guardan. Vacíos, mal formados, no visibles, fuera de ámbito y límites tienen códigos seguros. Detalle y ejemplos en [GARANTIA](GARANTIA.md).

## Despliegue y pruebas reales

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

## Estado final y límites

Auditoría final satisfactoria: ocho registros originales (dos clientes/contactos/productos/casos), ambos casos de muestra sin evaluar y garantía/serie originales conservadas. Cero temporales de sesión 05, cero temporales activos de sesión 04. Administrador activo y P04_DemoAdmin reservado a él.

Usuario persistente activo en P04_Minimo, sin rol, conjuntos adicionales, grupos ni casos propios activos. Dos licencias Salesforce ocupadas; no se creó otra cuenta. No se cambiaron asignaciones personales ni Login Access Policies en esta sesión, ni se utilizó el navegador o Gmail.

No se han realizado nuevas pruebas UI/REST ordinarias: la autorización del servicio se acredita mediante Apex/runAs con lecturas USER_MODE y regresión. No se han provocado concurrencia real, límites irrecuperables ni rechazo DML posterior a prevalidación correcta. Los errores de datos que las reglas impiden guardar se verificaron en el validador privado con datos en memoria. No atribuir esas pruebas a una escritura inválida persistida.

Evidencia privada, excluida de Git: .local/s05-deploy-1.json (fallo revertido), s05-deploy-2.json (éxito y tests) y s05-final-audit.json. Documentación funcional en GARANTIA, modelo en DATA_MODEL, seguridad en SECURITY y procedimiento en TESTING.

Revisión local final: 106 archivos públicos comprobados como UTF-8 estricto, 65 XML válidos, 11 scripts PowerShell sin errores de sintaxis, 28 enlaces locales existentes y 93 referencias de manifiestos resueltas sin comodines. Cinco exclusiones comprobadas (.local, .sf, .sfdx, .env y node_modules); sin identidades privadas ni patrones de secretos en los archivos revisados. git diff --check correcto. Resultado: main/4cfaf0b conservados, 11 archivos modificados, 11 nuevos y cero en staging. Los avisos LF/CRLF corresponden a la configuración existente, que no se cambió. No se repitieron suites por cambios solo documentales.

## Entrega y siguiente paso

Cambios: P04Garantia/P04EvaluarGarantiaAccion/P04GarantiaTest con metadatos API 68; adaptación de P04Autorizacion; acceso a clases en tres conjuntos; manifest/sesion05.xml; Demo-Garantia y Test-Garantia con plantilla Apex de demo; documentación y AGENTS. No hay cambios de campos, reglas de validación, triggers, perfiles o compartición.

Alex revisa y publica manualmente. Demostración breve:

```powershell
./scripts/Demo-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
```

La siguiente fase se revisará antes de iniciarse. No se ha implementado automáticamente el ciclo/asignación ni otros componentes.

Summary: `feat: implementar evaluación explícita de garantías`

Description:

- Centraliza cobertura, motivos e instantáneas en un servicio Apex con adaptador invocable.
- Permite evaluación y reevaluación explícita de abiertos; conserva históricos y rechaza cerrados.
- Mantiene FLS y autorización, limitando la escritura privilegiada a siete campos y casos autorizados.
- Define lotes atómicos de hasta 200 solicitudes y respuestas ordenadas con errores seguros.
- Despliega siete componentes y supera 65 pruebas: 25 de garantía y 40 de regresión.
- Incluye demo administrativa revertida, documentación y verificación de conservación de la muestra; sin Flow, cola, informes ni LWC.

## Histórico — Sesión 04 publicada en 4cfaf0b

El contenido siguiente conserva la entrega anterior; sus estados de publicación y pruebas pertenecen a aquella sesión.


# Estado — Sesión 04 completada, pendiente de commit y push de Alex

18 de noviembre de 2026. Seguridad por función implementada, desplegada y comprobada exclusivamente en P04. No se ha iniciado la evaluación automática de garantía.

## Git y entorno

Ruta y raíz: C:\Users\kaosk\source\repos\posventa-garantias-salesforce. Rama main; origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

Inicio limpio en HEAD/origin/main locales de1bfdb0f413ae750abbe39da83db1d62782c30f, sesión 03 publicada por Alex según el encargo. No se realizó una nueva lectura de la punta remota. HEAD se conserva; cambios locales sin staging. No hay commit, push, tags, releases ni CI atribuibles a esta sesión.

API 68.0 y alias explícito p04-posventa-dev. Se contrastaron identidad Developer Edition y administrador antes de escribir. Sin otras organizaciones ni Gmail. Herramientas conservadas: CLI 2.158.7, extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13; sin instalaciones en esta sesión.

## Implementación y despliegue

- Perfil P04_Minimo; conjuntos P04_Agente/P04_Responsable y permiso administrativo reservado.
- Tres permisos personalizados, dos grupos directos, cinco reglas de criterios y dos layouts adicionales de cliente/contacto.
- Account.P04_Posventa__c como único campo adicional de ámbito; 13 campos propios totales.
- Account/Asset/Case Private, Contact ControlledByParent y Opportunity Private por dependencia exigida. Se preservaron los 18 roles originales, los datos de formación y el administrador.
- P04Autorizacion separado de P04Integridad; cuatro triggers extendidos. Sin evaluación de garantía ni cambio de las nueve validaciones funcionales.
- P04SeguridadTest nuevo, más ajuste de dos fixtures Master de P04ModeloTest para preservar su ámbito bajo las concesiones actuales.

Despliegues satisfactorios: compartición 30 componentes; preparación 49; completo manifest/sesion04.xml, **56 componentes, 40 pruebas y cero errores**. El manifiesto incluye objetos padres y sus hijos DX propios ya existentes; 56 no significa 56 componentes nuevos.

El primer intento de preparación detectó la dependencia de Opportunity, requisitos de layout y orden de compartición, y se revirtió. Las primeras ejecuciones completas detectaron ContactAccessLevel no escribible con herencia de Account y selección implícita de tipo P04 en fixtures. Se corrigieron antes del despliegue final. Para los fixtures Master se usa un administrador aislado sin los tipos concedidos por P04_DemoAdmin, comprobando RecordTypeId null; no se retiraron permisos del administrador real ni se debilitaron aserciones.

## Resultados comprobados

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

Los fallos de selectores, aperturas o guardados no persistidos de Lightning no se contaron como éxito. Se comprobó identidad por indicador Login As/enlace del perfil y persistencia después de cada escritura positiva. No se omitieron validaciones. Una interrupción por límite de la revisión automática detuvo el cierre; se reanudó mediante la misma vía autorizada y se completó la limpieza.

## Cierre de organización

Auditoría final satisfactoria:

- Administrador activo y P04_DemoAdmin exclusivamente asignado a él.
- Usuario de pruebas activo, P04_Minimo, sin rol, conjuntos adicionales ni grupos; cero casos propios activos. Dos licencias Salesforce disponibles y dos ocupadas, para reutilizar este usuario secuencialmente.
- Ocho registros originales conservados: dos clientes, dos contactos, dos productos y dos casos sin evaluar. Clientes marcados P04; serie y asunto revisados de sesión 03 conservados.
- Garantía Norte restaurada al 19/10/2027; compra/inicio 19/10/2026. Cero casos temporales activos. Eliminación acotada mediante Remove-SecuritySample, sin purga de papelera.
- Sesión ordinaria cerrada. Administrators Can Log in as Any User restaurado a false, comprobado tras recargar. El acceso administrativo se conserva.

Evidencias privadas: .local/s04-full-4.json, s04-effective-metadata.json, s04-access-Agente/Responsable/Ninguno.json, s04-agent-persisted.json, s04-manager-persisted.json, s04-transfer-persisted.json, s04-revoked-own-case.json, s04-final-audit.json y s04-policy-final.json. No incluirlas en Git ni publicar identificadores.

## Límites y revisión local

No hay autenticación OAuth ordinaria independiente: no se afirma una prueba REST con token ordinario. UI ordinaria y Apex USER_MODE acreditan restricciones; CLI/API administrativos preparan y contrastan. No se probaron concurrencia, colas, nuevas jerarquías, fusiones/undelete ni concesiones futuras. Los rótulos de pestañas previamente abiertas pueden quedar en caché; la revocación impide nuevas consultas, no borra lo ya visto.

No hay motor de evaluación, ciclo completo, asignación automática, informe ni LWC. Detalle en [SECURITY](SECURITY.md) y [TESTING](TESTING.md).

Revisión local final: 95 archivos públicos leídos como UTF-8 estricto, 61 XML válidos, nueve scripts PowerShell sin errores de sintaxis, 22 enlaces locales existentes y 86 referencias de miembros de manifiestos resueltas sin comodines. Cinco exclusiones comprobadas (.local, .sf, .sfdx, .env y node_modules); sin identidades privadas ni patrones de secretos en los archivos revisados. git diff --check correcto. Estado final: 12 archivos modificados, 36 nuevos y cero en staging; HEAD de1bfdb y main conservados. Los avisos LF/CRLF corresponden a la configuración existente de Git; no se modificó configuración global. Estas comprobaciones incluyen archivos nuevos, que git diff por sí solo no enumera.

## Entrega y siguiente paso

Archivos de implementación: clases P04Autorizacion/P04SeguridadTest, fixtures de P04ModeloTest, cuatro triggers, perfil, permisos/grupos/reglas, layouts y configuración de compartición. Tres manifiestos acotados. Procedimientos New-SecurityUser, New-SecuritySample, Set-SecurityScenario, Remove-SecuritySample y Test-Seguridad, con plantillas Apex. Documentación: README, AGENTS, SECURITY, TESTING, DATA_MODEL, PROJECT_BRIEF y este STATUS.

Alex revisa el diff, hace staging, commit y push manualmente. Después se podrá comprobar el nuevo commit sin atribuirle automáticamente las pruebas de un árbol distinto. Próxima fase recomendada: servicio único de evaluación de garantía; no iniciada.

Summary: `feat: implementar seguridad por función en posventa`

Description:

- Añade perfil mínimo, permisos de agente/responsable, compartición acotada y autorización Apex.
- Protege casos por propietario, compra/garantía, evaluación, borrado y reasignación dentro del equipo.
- Despliega 56 componentes y supera 40 pruebas Apex, incluidas las 20 de regresión.
- Comprueba edición y restricciones en UI ordinaria, permisos efectivos y revocación por URL.
- Conserva la muestra original, elimina temporales, retira concesiones de prueba y restaura la política administrativa.
- Documenta procedimientos y límites; la evaluación de garantía queda para la siguiente fase.


## Histórico — Sesión 03 completada

18 de noviembre de 2026. Primera base funcional implementada, desplegada y comprobada en P04. El usuario ya puede trabajar con los datos ficticios relacionados desde la interfaz estándar. Evaluación de garantía, ciclo completo y seguridad por función siguen pendientes.

## Git y alcance

Ruta y raíz: C:\Users\kaosk\source\repos\posventa-garantias-salesforce. Rama main; origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

Inicio: árbol limpio y HEAD/origin/main locales en 4daa849421a9cfe91746a502cab6c2749eed1f83, cierre de sesión 02 publicado por Alex según el encargo. Ese commit se comprobó en el historial local; no se ha hecho una lectura nueva de la punta remota. Los resultados siguientes pertenecen al trabajo posterior, no a ese commit ni a CI. Codex no realiza staging, commits ni push.

El encargo de sesión 03 autoriza implementación, despliegue acotado y datos ficticios exclusivamente en P04. Antes de escribir se contrastó Organization y, antes de asignar el permiso, la identidad de sesión del administrador esperado. Sin otras organizaciones, destinos predeterminados, usuarios nuevos ni acceso a Gmail.

## Implementación y despliegue

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

## Comprobaciones reales

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

## Datos y evidencia

Quedan ocho registros de demostración: dos Account, dos Contact, dos Asset y dos Case. AccountNumber P04-S03-DEMO-A/B identifica la muestra; no hay correos reales en los contactos. Se conservaron la muestra y los datos de origen. La última lectura cuenta 2 productos P04 y 2 casos P04 activos, cero cuentas P04 TEST y cero casos temporales P04 API activos. Las pruebas Apex revierten sus fixtures; Test-Api elimina solo su propio caso temporal. No se purga la papelera.

Límites finales observados: almacenamiento de datos máximo 5 MB y restante 5 MB según la unidad/redondeo del endpoint; API máximo 15000, restante 14755 en esa lectura. Los valores restantes son una instantánea, no una reserva. Se conservan dos licencias Salesforce, una libre para la fase de permisos.

Evidencia local ignorada: s03-deploy-6.json, s03-api-results.json, s03-layout-checks.json, s03-nav-deploy.json y s03-final-remote.json dentro de .local. s03-demo.json contiene identificadores privados y nunca se versiona. El [procedimiento reproducible](TESTING.md) separa despliegue, tests, API y demostración.

## Incidencias corregidas y límites

- Referencias del proceso de soporte corregidas a las etiquetas de CaseStatus; los registros y las fórmulas usan nombres API. Se desplegaron estados/proceso por separado durante el diagnóstico; los intentos completos fallidos se revirtieron.
- Layout Case corregido para incluir SuppliedEmail y mantener OwnerId editable, no Required. La muestra no envía comunicaciones.
- Apex 68.0 aplica modo usuario por defecto. Fixtures y consultas internas del guardián pasan a modo sistema explícito para verificar integridad, sin conceder permisos amplios a nuevos usuarios.
- Prueba de tipo corregida para distinguir null, Master y el rechazo propio del guardián.
- Pestaña Asset añadida al permiso administrativo tras detectar su ausencia en navegación.
- Se resolvieron selectores ocultos y confirmación de campos en Lightning. Windows rechazó temporalmente nuevos procesos con error 5; después volvió a permitir la ejecución, sin desactivar protecciones ni cambiar configuración global. El conector MCP antiguo probado como alternativa era incompatible con la extensión; se abandonó y se continuó con la CLI compatible ya instalada.

Se verifican operaciones secuenciales y lotes, no concurrencia entre transacciones ni fusiones/undelete. La cuenta administrativa puede tener privilegios superiores a los campos configurados como Readonly; no se considera protección de roles. El motor de garantía, transiciones, cierre completo, asignación, informe y LWC no están implementados. La condición de cierre con Pendiente_datos se mantiene como contrato futuro; la evaluación no se precarga.

## Archivos, revisión y siguiente fase

Modificados: AGENTS, README, PROJECT_BRIEF, ENVIRONMENT y STATUS. Nuevos: DATA_MODEL, TESTING, 36 XML de metadatos, seis fuentes Apex/triggers, manifest/sesion03.xml y cinco archivos de scripts. No cambian sfdx-project.json, .gitignore ni .forceignore; API 68.0 y herramientas se conservan.

Al retomar el cierre había tres documentos modificados y los archivos funcionales pendientes; se conservaron. Estado final: main...origin/main, cinco archivos modificados y 50 nuevos, todos sin staging. HEAD continúa en 4daa849; no se ha ejecutado commit ni push.

Revisión local sobre los 59 archivos versionables, incluidos los nuevos: 37 XML válidos (36 metadatos y manifiesto), correspondencia exacta de los 36 componentes en 11 tipos, cuatro scripts PowerShell analizados sin errores, 15 enlaces Markdown locales resueltos, 11 exclusiones privadas y cinco rutas versionables comprobadas. Sin caracteres de sustitución, coincidencias con los patrones de datos privados revisados ni espacios finales; git diff --check satisfactorio. Esto no constituye un escaneo exhaustivo de secretos. No se repitió la suite remota tras cambios exclusivamente documentales; el resultado Apex procede del despliegue real indicado arriba. Evidencia local: .local/s03-local-review.json.

Alex revisa, realiza staging, commit y push; después se contrasta su publicación. Siguiente fase: **seguridad por función**, con pruebas secuenciales para agente, responsable y sin permisos compatibles con una sola plaza Salesforce libre. No se inicia automáticamente.

Summary: feat: implementar el modelo inicial de posventa y sus validaciones

Description:

- Incorpora campos, relaciones, tipos de registro, estados y presentación administrativa sobre Account, Contact, Asset y Case.
- Valida coherencia y fechas en servidor y protege cambios de padres y borrados en el ámbito P04.
- Despliega el conjunto acotado y comprueba 20 pruebas Apex, lotes de 200, API y edición real en la interfaz estándar.
- Conserva una muestra ficticia de ocho registros y documenta reproducción, límites y seguridad por función como siguiente fase.

## Histórico — Sesión 02 cerrada, publicada en 4daa849


Fecha: 18 de noviembre de 2026. **Entorno preparado para comenzar el diseño del modelo.** Herramientas operativas, integración inicial Apex/JDK comprobada, organización dedicada identificada y autenticada, API 68.0 contrastada y capacidades/limitaciones documentadas. No hay un bloqueo conocido para iniciar la sesión 03; su ejecución requiere el encargo correspondiente. Sin implementación funcional, pruebas de producto ni despliegues.

### Git y publicación

Ruta y raíz Git: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Rama main; origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

La continuación del 18 de noviembre comenzó con árbol limpio; al retomar la comprobación final ya había cuatro documentos modificados sin staging. Se conservaron y completaron. HEAD y referencia local origin/main permanecen en `a9e7a9677232d36908a7d57e790abee0f93ed01d`. El conector GitHub confirmó la existencia de [a9e7a96](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/a9e7a9677232d36908a7d57e790abee0f93ed01d), `chore: preparar herramientas y estructura Salesforce DX`; esa comprobación no establece una nueva lectura de la punta remota actual.

Ese commit publicado por Alex contiene la preparación anterior. Las comprobaciones de este cierre son posteriores y no se atribuyen a ese commit ni a CI. Estado local de entrega: main...origin/main, cuatro documentos modificados, sin archivos nuevos ni staging. Alex realiza exclusivamente staging, commit y push.

### Problemas resueltos y evidencia

- **Apex/JDK:** VS Code 1.146.0 reconoce el proyecto DX y activa Core/Apex 68.10.0. Árbol de procesos y registros de la ventana P04 vinculan ApexLanguageServerLauncher con Temurin 21.0.13+9. El canal Apex Language Server finaliza biblioteca e indexación inicial a las 15:21:47, con cero archivos Apex/objetos personalizados/archivos con error. java/javac terminan con salida 0. No se probó autocompletado interactivo ni compilación remota; Java predeterminado 1.8.0_503 se conserva.
- **Organización:** el alta directa rechazada por Monocle queda histórica y sin causa concreta conocida. Tras explicar la alternativa, Alex creó P04 Posventa Garantías como Playground nuevo. Su identidad coincide entre Trailhead, Setup, autenticación y consulta API Organization; Developer Edition, IsSandbox=false. El Playground anterior no se reutiliza.
- **Contraseña y usuario:** las capturas de los primeros correos correspondían al Playground antiguo. Se abrió la pantalla de credenciales del nuevo; Alex completó su contraseña. Después se corrigió el uso del correo receptor como nombre de usuario, proporcionando el usuario real de la organización. No se leyeron contraseñas ni respuestas de seguridad. Gmail queda expresamente fuera de acceso en AGENTS.
- **CLI:** tras dos intentos caducados, autenticación web oficial completada con salida 0 y organización esperada. Alias p04-posventa-dev comprobado libre antes de conectarlo. Usuario activo con perfil System Administrator y licencia Salesforce. target-org y target-dev-hub siguen sin configurar; todas las lecturas usan destino explícito.
- **API:** REST devuelve API 68.0, publicada como Winter '27 y Latest Release; HTTP 200. Metadata API describe correctamente los tipos en 68.0. sourceApiVersion conserva 68.0, ahora contrastada. La validación inicial que esperaba una única entrada se corrigió al observar las dos etiquetas para la misma versión.

Herramientas conservadas: Git 2.56.1.windows.1, Node v24.13.0, npm 11.6.2, Salesforce CLI 2.158.7, VS Code 1.146.0, Core/Apex/LWC 68.10.0 y Temurin JDK 21.0.13+9. También está instalada Apex Language Server Extension 0.10.0; su servidor JavaScript no se usa como evidencia del JDK. No hubo reinstalaciones ni cambios de configuración global en este cierre.

### Organización: capacidades y límites

- Account, Contact, Asset y Case descritos por API como estándar; consulta y CRUD disponibles para el administrador. Relaciones principales confirmadas, incluido Case.OwnerId con Group/User. No se crearon ni consultaron registros de negocio.
- Nueve tipos de metadatos relevantes habilitados: ApexClass, ApexTrigger, Flow, LightningComponentBundle, Queue, Report, ReportType, PermissionSet y CustomObject.
- UserPermissionAccess confirma ApiEnabled, AuthorApex, ModifyMetadata, ModifyAllData, CustomizeApplication, ViewSetup, ManageInteraction, RunReports, CreateCustomizeReports y LightningExperienceUser. RunFlow y CreateReportInLightning figuran falsos y no se cambian. Se documenta la diferencia entre gestión de Flow, acceso específico de futuros flujos y diseñador Lightning de informes. Permisos observados no equivalen a despliegues ni tests ejecutados.
- UserLicense: Salesforce 2/1/1, Platform 3/0/3, Integration 1/0/1 e Identity 10/0/10 (totales/usadas/libres), todas activas. Conservar administrador y proponer pruebas secuenciales de agente/responsable/sin permisos con la otra plaza Salesforce. No caben los tres simultáneamente; Platform/Identity no sustituyen automáticamente la licencia para Case. Identidades, activación, propiedad de registros y sesiones se concretarán antes de probar; no se crean usuarios ahora.
- Límites API observados: 15.000 solicitudes/24 h, 5 MB de datos, 20 MB de archivos y 250.000 ejecuciones Apex asíncronas diarias. Instantánea y otros límites en [ENVIRONMENT](ENVIRONMENT.md). No se prueba carga ni se autorizan comunicaciones reales.

La lectura de tipos y permisos verifica disponibilidad administrativa para el trabajo futuro. Las pruebas funcionales, el acceso de usuarios ordinarios, los flujos concretos, el diseñador de informes y el despliegue reproducible pertenecen a los encargos posteriores. No impiden comenzar el diseño del modelo y no se presentan como ya resueltos.

### Verificación y archivos

Archivos modificados: AGENTS.md, README.md, docs/ENVIRONMENT.md y docs/STATUS.md. AGENTS refleja la prohibición de Gmail y el estado de cierre; los otros documentos registran resultados, límites e históricos. PROJECT_BRIEF, sfdx-project.json, .gitignore, .forceignore y el marcador de fuente se conservan. Sin nuevas dependencias, código funcional ni configuración del editor.

Comprobaciones locales finales: nueve archivos versionados revisados; siete enlaces internos válidos y cero rotos; cero archivos con coincidencias en los patrones acotados de secretos/identificadores privados o caracteres de sustitución. Once de once rutas locales/de autenticación ignoradas y cuatro de cuatro rutas DX versionables. JSON válido, API 68.0 contrastada, paquete force-app existente y un único archivo fuente: el marcador .gitkeep. Cero archivos en staging y git diff --check correcto. Las lecturas remotas anteriores terminaron con estado 0; las solicitudes REST contrastadas respondieron HTTP 200. No se ejecutaron suites, despliegues ni CI.

La evidencia Apex/JDK conserva su alcance de arranque e indexación inicial. Durante el diagnóstico hubo restricciones del sandbox y avisos de las envolturas PowerShell; las lecturas autorizadas y ejecuciones directas posteriores dieron los resultados descritos. No se añadió safe.directory global ni se modificaron credenciales de otras tareas. Autenticaciones y diagnósticos permanecen fuera de Git.

### Intervención de Alex y siguiente paso

No queda ninguna intervención de acceso pendiente. Revisar los cuatro documentos y realizar staging, commit y push manuales desde GitHub Desktop; después contrastar el commit publicado. No se declara publicado este cierre antes de hacerlo.

Sesión 03 propuesta: concretar campos/relaciones sobre Account, Contact, Asset y Case; resolver precedencia de errores de garantía, fecha y zona horaria de referencia, cierre con datos inválidos y reevaluación explícita de abiertos; definir evaluaciones cerradas inmutables y estrategia secuencial de usuarios para permisos. Esta sesión no se ha ejecutado ni se inicia automáticamente.

### Propuesta para GitHub Desktop

Summary: `docs: cerrar la preparación del entorno Salesforce`

Description:

- Registra la comprobación de Apex con JDK 21 en el proyecto y conserva Java 8.
- Documenta la organización dedicada, la recuperación del acceso y la autenticación web de Salesforce CLI.
- Contrasta API 68.0, objetos estándar, tipos de metadatos, permisos administrativos, licencias y límites mediante lecturas remotas.
- Conserva el diagnóstico anterior como histórico y recoge la prohibición de acceder a Gmail.
- Cierra la sesión 02 y propone el modelo de datos para la siguiente sesión, sin funcionalidades, tests de producto ni despliegues.

### Histórico — entrega del 17 de noviembre, publicada en a9e7a96

El texto siguiente conserva el estado y las comprobaciones anteriores a esa publicación. Su propuesta de commit ya fue utilizada por Alex; sus pendientes locales Apex/JDK quedan actualizados arriba.

Fecha: 17 de noviembre de 2026. **Parcialmente preparado**. Herramientas instaladas y estructura DX mínima creada. El alta de la organización independiente está bloqueada por una respuesta de Salesforce; el entorno no está listo para implementar el modelo.

#### Git y evidencia de publicación

Ruta: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.
Rama main, remoto origin: https://github.com/AlexC-0/posventa-garantias-salesforce.git.

La sesión 02 comenzó con árbol limpio y HEAD/origin/main locales en `d90c2286b9103aedf03a636567403c8369a2572d`, título `docs: preparar alcance y entorno del proyecto de posventa`. La continuación conservó los cuatro cambios documentales aún sin staging.

La publicación de Alex se contrastó mediante el conector GitHub: existen main y [d90c228](https://github.com/AlexC-0/posventa-garantias-salesforce/commit/d90c2286b9103aedf03a636567403c8369a2572d). git ls-remote falló por Schannel SEC_E_NO_CREDENTIALS; no se modificaron credenciales ni remotos. La referencia local origin/main no sustituye una lectura actual de la punta remota.

Los cambios y verificaciones siguientes son posteriores al commit publicado. Codex no realizó staging, commits, push, tags ni publicación.

#### Preparación completada localmente

Alex autorizó expresamente instalar las herramientas y acceder exclusivamente a Salesforce mediante su perfil de Chrome.

- Salesforce CLI 2.158.7 instalada con npm y ejecutada con Node v24.13.0; engines Node >=22 comprobado. El instalador Windows oficial falló al descargar; no se instalaron sustitutos de terceros.
- Salesforce Extension Pack 68.10.0 y extensiones dependientes instalados; Apex/Core/LWC 68.10.0 comprobados.
- Temurin JDK 21.0.13+9: ZIP oficial con SHA256 verificado, java y javac operativos. Java predeterminado 1.8.0_503 conservado.
- JDK configurado solo en .vscode/settings.json, ignorado. No se alteraron PATH ni JAVA_HOME de Java.
- VS Code 1.146.0 abrió una ventana de este proyecto. Integración del servidor Apex con el JDK en este workspace todavía pendiente de comprobar.
- Git 2.56.1.windows.1 y npm 11.6.2 conservados.
- Plantilla DX empty generada mediante sf template generate project. Configuración y directorio fuente vacío incorporados; sin ejemplos, dependencias de proyecto ni configuración scratch.
- API de plantilla 68.0 **provisional**, sin contraste remoto.
- sf project list ignored reconoce únicamente el marcador .gitkeep dentro de force-app. JSON válido y directorio de paquete existente.
- Alias p04-posventa-dev libre en la comprobación; target-org y target-dev-hub sin configurar. Sin autenticación CLI.

Comandos y detalles reproducibles en [ENVIRONMENT](ENVIRONMENT.md).

#### Bloqueo de la organización

La conexión con Chrome funcionó mediante Playwright CLI 0.1.24 y extensión 0.5.0 después de que Alex aceptara la conexión. Se consultó su perfil Trailblazer como contexto de formación; no equivale a una organización de desarrollo.

Alex intentó personalmente el alta oficial. El servicio devolvió HTTP 400 y, en el intento manual observado:

> Monocle API error: Monocle Validation Failed indicating potential fraud

Se conoce el rechazo antifraude, no su causa concreta. Se detuvieron los reintentos y se desconectó Playwright. La herramienta cerró su pestaña de alta al desconectar; se reabrió el formulario normalmente. Alex mostró después el error genérico trial-oops.html tras iniciar sesión, sin Playwright conectado. No hay confirmación de alta completada.

Pendientes: organización/edición, autenticación, API, objetos estándar, capacidades, permisos efectivos, licencias, plazas de usuarios y límites. No hay estrategia de usuarios restringidos validada. No se reutilizó un Playground ni se crearon datos o configuración de negocio.

#### Archivos de la entrega

Modificados: README.md, AGENTS.md, docs/ENVIRONMENT.md y docs/STATUS.md.
Nuevos: sfdx-project.json, .forceignore y force-app/main/default/.gitkeep.

PROJECT_BRIEF.md y .gitignore se conservan. Descargas, plantilla temporal, diagnósticos de navegador y configuración local del editor están ignorados. Sin código funcional, permisos, Flow, Apex, LWC, CI, tests de producto ni despliegues.

#### Verificación local

- Nueve archivos versionados o candidatos revisados; seis enlaces locales válidos, cero rotos.
- git diff --check correcto para cambios existentes y revisión no-index correcta para los tres archivos nuevos.
- Once rutas representativas de autenticación, herramientas, diagnósticos, editor y resultados ignoradas por Git.
- Cuatro rutas DX versionables no excluidas por error.
- Cero coincidencias en los patrones de secretos revisados y cero caracteres de sustitución. Revisión acotada al contenido versionable.
- sfdx-project.json válido, API 68.0 provisional y directorio force-app existente.
- sf project list ignored --source-dir force-app --json: éxito, un marcador .gitkeep ignorado.
- PROJECT_BRIEF.md y .gitignore sin cambios. Cero archivos en staging.
- Estado final: main, cuatro documentos modificados y tres archivos nuevos; HEAD permanece en d90c228. No se ejecutaron pruebas de producto, despliegues ni consultas a una organización Salesforce.

#### Histórico

Sesión 01: se crearon cinco documentos y .gitignore. Codex inicializó Git por petición expresa; Alex publicó después d90c228. El estado anterior «sin commits ni remoto» queda histórico.

Primera parte de sesión 02: se renovó la inspección y se actualizaron cuatro documentos; siete enlaces locales válidos, nueve exclusiones comprobadas, cuatro rutas DX no excluidas, diff --check correcto y ningún archivo en staging. Después Alex autorizó las instalaciones realizadas en esta continuación.

#### Intervención y siguiente paso

Resolver el rechazo del alta mediante los canales oficiales de Salesforce; hay un texto preparado en ENVIRONMENT para envío manual de Alex. No se ha contactado a terceros automáticamente. La creación/activación, contraseña y MFA siguen en navegador.

Una vez exista organización dedicada: comprobar identidad y alias, autenticar, verificar capacidades/licencias solo en lectura y contrastar API 68.0. Comprobar activación Apex/JDK en este workspace antes de declarar el entorno preparado. No avanzar automáticamente a funcionalidades.

#### Propuesta para GitHub Desktop

Summary: `chore: preparar herramientas y estructura Salesforce DX`

Description:

- Incorpora la estructura DX mínima con API 68.0 provisional.
- Registra la instalación y comprobación de Salesforce CLI, extensiones y JDK 21, conservando Java 8.
- Actualiza las instrucciones y documenta el rechazo del alta de Developer Edition.
- Deja pendientes la organización, las licencias, la API remota y la integración Apex/JDK; sin implementación funcional ni despliegues.
