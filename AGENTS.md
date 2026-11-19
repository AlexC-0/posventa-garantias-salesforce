# Instrucciones del proyecto — Posventa y garantías

## Alcance y documentación

Trabajar exclusivamente en `posventa-garantias-salesforce`. No inspeccionar, copiar, modificar ni integrar otros proyectos. Antes de modificar, confirmar ruta, instrucciones aplicables y existencia de Git; comprobar raíz, rama, remotos y `git status --short --branch`. Conservar cambios previos, incluidos los preparados en staging. Leer README.md, docs/PROJECT_BRIEF.md, docs/STATUS.md y docs/ENVIRONMENT.md. Escribir principalmente en castellano.

Documentar únicamente objetivos, configuración, funcionalidades, decisiones, cambios, comprobaciones y limitaciones del proyecto. Utilizar redacción técnica directa. Excluir relatos de conversaciones, asignaciones personales, firmas automáticas y detalles internos de elaboración. Mantener identificaciones legítimas de autoría, licencias y créditos de terceros.

## Estado y límites de V1

V1 implementada y preparada para revisión final. Incluye modelo estándar, seguridad por función, evaluación explícita, cola y ciclo, consulta LWC e informe de pendientes. Evidencia final registrada: despliegue incremental de cuatro componentes, 106/106 Apex secuenciales y 23/23 Jest; recorrido ordinario hasta cierre, recuentos 5→6→5, histórico, revocación y restauración comprobados. Matriz de doce criterios en docs/ACEPTACION-V1.md.

El informe incluye los tres estados abiertos, cola y personas, sin filtro temporal, agrupado por estado y propietario y con detalles antiguos primero. Carpeta propia compartida para consulta con responsables, permisos mínimos y acceso desde la aplicación. Metadatos sin IDs privados. Manifiesto completo convertido localmente; instalación desde cero no ejecutada. No ampliar el alcance ni iniciar nuevas fases automáticamente.

Conservar los ocho registros originales. La última comprobación registra diez temporales eliminados, usuario mínimo sin concesiones adicionales y Login As false tras recarga. Reutilizar evidencia válida sin repetir demostraciones por rutina. Conservar contratos de seguridad, actualización explícita e instantánea histórica.

## Protección de organizaciones y datos

Utilizar exclusivamente la Developer Edition dedicada y autorizada de P04. No reutilizar automáticamente Playground, organización autenticada ni destino predeterminado. Antes de conectar, comprobar identidad del destino; el alias `p04-posventa-dev` por sí solo no la acredita. Comprobar que esté libre o corresponda a P04 antes de autenticar. Usar destino explícito en cada comando remoto. Creación, activación, contraseña y MFA exclusivamente mediante navegador oficial; nunca solicitar credenciales por chat ni exportar autenticaciones.

No acceder a Gmail mediante navegador, conectores ni otras herramientas. El acceso a Salesforce no incluye buzones, otras pestañas ni organizaciones ajenas. No enviar comunicaciones ni gestionar enlaces de recuperación fuera del flujo oficial del entorno correcto.

No cambiar destinos globales ni configuraciones de otras tareas. No imprimir ni versionar tokens, contraseñas, claves, archivos de autenticación, URLs reutilizables de acceso ni salidas completas que puedan contenerlos. No usar `sf org display` para producir informes. Metadatos por nombres API; evidencias privadas en rutas ignoradas.

Datos ficticios y garantía simulada. Sin producción, compra de licencias, comunicaciones reales, dashboards ni integraciones externas. No instalar ni actualizar herramientas globales sin autorización expresa. Conservar Salesforce CLI, Salesforce Extension Pack y JDK 21 existentes; mantener Java 8 y configurar el JDK nuevo solo en este proyecto. La conexión existente de Playwright a Chrome se limita a Salesforce y no autoriza consultar otras pestañas.

No crear más usuarios persistentes ni ampliar privilegios para hacer pasar pruebas. Dos licencias Salesforce ocupadas: conservar el administrador y reutilizar la cuenta ordinaria activa P04_Minimo, sin rol, conjuntos P04, grupos ni casos propios activos al finalizar. No habilitar Login Access Policies sin necesidad explícita; registrar el valor anterior, restaurarlo y comprobarlo tras recarga. Eliminar únicamente temporales identificados y restaurar permisos, membresías y ajustes.

## Contratos técnicos y verificación

Account, Contact, Asset y Case son la base implementada. No sustituirlos por objetos personalizados sin documentar impedimento y alternativa. Preservar P04_Minimo, permisos, grupos, reglas y guardián de autorización. OWD Account/Asset/Case/Opportunity Private y Contact ControlledByParent; Opportunity es dependencia necesaria de Account. Account.P04_Posventa__c delimita clientes sin convertir datos ajenos.

No conceder ViewAllData, ModifyAllData ni View All/Modify All de objetos a usuarios ordinarios. Separar autorización e integridad; acciones restringidas bajo USER_MODE. Conservar la finalidad limitada de P04Integridad en modo sistema. No atribuir consultas con token administrativo a pruebas API ordinarias.

P04Garantia centraliza la evaluación explícita y P04EvaluarGarantiaAccion adapta IDs sin duplicar cálculo. Lecturas USER_MODE, acceso de edición y rol comprobados, escritura SYSTEM_MODE solo de siete campos mediante un contexto privado y predicado sin setter público. No exponer ni hacer TestVisible ese contexto. Lote atómico de hasta 200 solicitudes; duplicados deduplicados para DML, respuestas en el mismo orden. Cerrados rechazados, instantáneas conservadas al editar producto/incidencia y reevaluación solo explícita. La evaluación automática queda fuera. Conservar Flow, ciclo y cola según docs/CICLO.md y consulta de solo lectura según docs/CONSULTA.md.

Distinguir inspección local, futura CI y pruebas con Salesforce. Jest no prueba permisos ni integración real. No añadir CI vacía, pruebas ficticias o cifras de cobertura sin ejecución. Registrar comandos, resultados reales, límites y pendientes técnicos en STATUS. Distinguir pruebas administrativas, Apex con usuarios aislados y UI ordinaria; la demostración administrativa de garantía no acredita UI/REST ordinarias. Ejecutar las cinco suites Apex secuencialmente para evitar bloqueos de fixtures compartidos. No repetir suites completas por cambios exclusivamente editoriales. Revisar enlaces, coherencia, exclusiones, secretos y espacios en blanco.

## Git y entregas

No ejecutar staging, commit ni push; dejar los cambios preparados para revisión. No crear remotos, tags ni releases; no cambiar de rama, reescribir historial, alterar autores ni publicar por API. No desplegar sin encargo explícito; cuando esté autorizado, comprobar identidad antes de escribir y usar un despliegue acotado sin destructivos ni recuperaciones masivas.

Entregar ruta y estado Git inicial/final, archivos modificados, comprobaciones, versiones pertinentes, límites y siguiente paso. Convención: `tipo: descripción en castellano`, sin ámbitos innecesarios. Usar docs, chore, feat, fix o test según el cambio real. La Description explica resultado, verificación y pendientes técnicos sin atribuir funcionalidades inexistentes ni incluir relatos de elaboración.
