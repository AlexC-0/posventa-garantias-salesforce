# Consulta de posventa en la ficha del caso — sesión 07

`p04ConsultaCaso` presenta datos de lectura dentro de **P04 Posventa → caso P04**, en la página propia `P04_Caso`. La asignación se versiona en CustomApplication, para el tipo `Case.P04_Posventa`, perfil ordinario `P04_Minimo` y perfil administrativo, escritorio/Large. No sustituye la página general de Case ni páginas de otras aplicaciones. La ficha conserva cabecera de acciones, detalles y publicador estándar; evaluación, propietario y cierre siguen usando las acciones de sesión 06.

## Qué muestra

- **Datos actuales del producto:** nombre, serie, compra, inicio y fin de garantía, más incidencia del caso.
- **Evaluación registrada:** resultado, motivo, compra/inicio/fin/incidencia utilizados y momento de evaluación. Vacío significa **Sin evaluar**; Pendiente_datos significa que sí se evaluó, con información incompleta.
- **Otros casos visibles del producto:** número, asunto, estado y creación, con navegación estándar al registro.

Las fechas Date se presentan con UTC para conservar el día; el momento DateTime incluye zona horaria. Los datos opcionales autorizados ausentes dicen **No consta**. Una lectura denegada no se representa como un valor vacío.

En abiertos, las cuatro fechas actuales se comparan con las utilizadas, tratando null como ausencia. Si difieren, se avisa de que requiere reevaluación antes del cierre. Es una comparación visual, sin calcular cobertura ni autorizar escrituras. En cerrados se indica que la evaluación histórica se conserva, aunque el producto cambie después. El cierre sigue validándose en P04Ciclo.

## Contrato y seguridad

`P04ConsultaCaso.consultar(String caseId)` solo acepta el identificador del caso. Clase `with sharing`; todas las consultas utilizan `WITH USER_MODE`. Exige un permiso funcional P04 y acceso real a objetos, campos y registros. Resuelve el producto desde el caso autorizado y comprueba tipos P04 y cliente marcado; no acepta AssetId, filtros, límites, orden ni usuario aportados por el navegador. No utiliza P04Integridad/P04Cola para devolver datos.

Respuesta correcta: codigo=OK, caso con su instantánea, producto con fechas actuales y relacionados. Rechazos: NO_DISPONIBLE sin datos, indistinguible para identificador inválido, inexistente, inaccesible, ajeno al ámbito o campos/relación restringidos. Un fallo inesperado devuelve ERROR_CONSULTA. La interfaz ignora los detalles técnicos recibidos y presenta mensajes fijos sin consultas, trazas, IDs ocultos ni mensajes internos.

La política ante FLS insuficiente es **rechazo completo**: no se devuelve una sección parcial que pueda confundirse con ausencia de datos. No se conceden nuevas lecturas de campos, edición, grupos ni compartición; los tres conjuntos P04 añaden únicamente acceso a esta clase. Su invocación directa en Apex de tests comprueba la autorización del método; los permisos de clase Lightning se contrastan mediante la interfaz real.

Los relacionados se consultan en servidor: mismo Asset resuelto, tipo P04, cliente del ámbito, distinto del caso actual, `ORDER BY CreatedDate DESC, Id DESC LIMIT 5`, después de las restricciones USER_MODE. No se recuperan ocultos para filtrarlos en JavaScript, no hay recuento global ni paginación. El vacío dice **No hay otros casos visibles de este producto**, sin afirmar que no existan otros. El desempate por Id hace estable el orden si coinciden fechas.

La consulta no tiene DML, no llama al servicio de evaluación, no bloquea registros ni expone datos de los helpers de integridad en modo sistema. Se prueban ausencia de DML y conservación de la evaluación/fecha de modificación. No se atribuye una instantánea transaccional global ni protección frente a concurrencia real no probada.

## Actualización y estados

La lectura es imperativa, sin caché de cliente Apex: carga al recibir recordId y al pulsar **Actualizar**. No existe sincronización automática con el Screen Flow. Después de evaluar o editar hay que pulsar Actualizar; el botón no escribe ni reevalúa.

Cada petición limpia datos previos y muestra carga accesible. El componente distingue datos, sin evaluar, opcionales ausentes, vacío visible, acceso restringido y error recuperable. Actualizar permite reintentar. Un contador de solicitudes invalida respuestas anteriores al cambiar de registro, actualizar o desconectar; una respuesta o error tardíos no sustituyen el caso actual.

Usa Lightning Card, Button, Spinner, Formatted Text y Formatted Date Time, títulos/secciones legibles y avisos textuales, no solo color. Los campos se adaptan al ancho disponible; los relacionados son una lista que evita una tabla ancha. La asignación de esta entrega es de escritorio; no se declara aplicación móvil verificada.

## Demostración reproducible

1. Confirmar organización dedicada y usuario reutilizable. Aplicar escenario Agente temporal. Si se usa Login As, registrar y restaurar su valor previo.
2. Preparar administrativamente un Asset ficticio y tres casos `P04 S07 TEMP`: principal y relacionado para el usuario ordinario; tercero reservado al administrador. Usar cliente/contacto originales como referencias, sin editarlos. Desactivar notificaciones de correo. Registrar IDs de los temporales solo en .local.
3. Entrar con identidad ordinaria y aplicación P04. Abrir el principal: producto/fechas actuales, Sin evaluar y únicamente el relacionado accesible. Abrir el relacionado por su número y comprobar navegación.
4. Volver al principal, ejecutar Evaluar garantía desde el publicador existente y pulsar Actualizar en el panel. Contrastar la instantánea persistida mediante lectura administrativa, diferenciando las identidades.
5. Cambiar solo una fecha del Asset temporal administrativamente. Actualizar: los datos actuales cambian, la instantánea permanece y el abierto avisa de reevaluación. El panel no evalúa al consultar.
6. Si se demuestra cerrado, recorrer estados válidos, reevaluar explícitamente antes del cierre y completar resolución/explicación. Una corrección posterior del producto temporal debe dejar la instantánea intacta y mostrar aviso histórico al actualizar.
7. Salir del usuario, retirar concesiones, eliminar solo los tres casos identificados y después su Asset temporal; restaurar Login As si se utilizó. Auditar los ocho originales y el usuario mínimo.

Resultados reales por capa, incidencias y límites en [STATUS](STATUS.md) y [TESTING](TESTING.md). No interpretar este procedimiento como evidencia de todos sus pasos hasta contrastar aquellos resultados.

Referencias oficiales: [lectura segura en Apex](https://developer.salesforce.com/docs/platform/lwc/guide/apex-security), [invocación imperativa](https://developer.salesforce.com/docs/platform/lwc/guide/apex-call-imperative), [asignaciones de página](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-profileactionoverride.html) y [tests Jest de LWC](https://developer.salesforce.com/docs/platform/lwc/guide/unit-testing-using-jest-installation.html).
