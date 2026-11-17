# Proyecto 04 — Alcance y diseño propuesto

Fecha de referencia: 17 de noviembre de 2026. La elección del proyecto está cerrada. Las decisiones siguientes son propuestas pendientes de contraste con una organización Salesforce dedicada; no describen una aplicación implementada.

## Propósito y V1

Atención posventa interna para agentes y una persona responsable: clientes empresariales y sus contactos, productos registrados, casos vinculados, evaluación de garantías mediante fechas y reglas acotadas, asignación inicial a una cola, seguimiento y resolución, informe de pendientes, un LWC de consulta y permisos por función. Pruebas, demostración y despliegue reproducibles forman parte de la V1 futura; código y metadatos tendrán repositorio propio.

Solo datos ficticios y garantía simulada. Excluidos: portal público, Experience Cloud, comunicaciones reales, OmniChannel avanzado, IA, integraciones externas, otros proyectos, datos reales, compra de licencias y producción.

## Modelo y reparto técnico propuestos

| Elemento | Uso previsto |
| --- | --- |
| Account | Cliente empresarial |
| Contact | Contacto del cliente |
| Asset | Producto registrado |
| Case | Incidencia y evaluación registrada |
| Configuración estándar y validaciones | Coherencia de datos y restricciones |
| Flow | Asignación inicial y coordinación |
| Servicio Apex | Evaluación única de garantía |
| LWC | Consulta desde la ficha del caso |

La disponibilidad de objetos, campos y relaciones se comprobará antes de diseñar metadatos. No sustituir objetos estándar sin justificar un impedimento real. Pendientes: nombres API de campos, mecanismo de reevaluación, orden de validaciones, seguridad de registros y reparto preciso entre Flow y Apex.

## Estados y cierre

Estados: Nuevo, En curso, Pendiente de información y Cerrado.

| Origen | Destinos permitidos |
| --- | --- |
| Nuevo | En curso |
| En curso | Pendiente de información, Cerrado |
| Pendiente de información | En curso, Cerrado |
| Cerrado | Ninguno; reapertura fuera de V1 |

El cierre requiere responsable individual, tipo de resolución y explicación. Tipos: reparación, sustitución, atención fuera de cobertura y cierre sin actuación. La cola sirve para la asignación inicial; esa automatización no debe sobrescribir después al responsable.

## Garantía simulada

- Evaluar respecto a la fecha de incidencia, incluyendo inicio y fin de garantía.
- Fuera del intervalo: fuera de cobertura, con motivo.
- Fechas de garantía ausentes: pendiente de datos.
- Fin anterior al inicio, incidencia futura o anterior a compra conocida: dato inválido.
- Cliente, contacto y producto deben ser coherentes.
- Registrar en Case resultado, motivo, fechas utilizadas y momento de evaluación.
- Corregir Asset no cambia silenciosamente las evaluaciones existentes.
- Los casos abiertos podrán reevaluarse explícitamente. Los cerrados conservarán la evaluación.
- Con evaluación pendiente de datos, solo admitir cierre sin actuación, explicado.

Quedan por concretar la precedencia entre errores simultáneos, la referencia de fecha/zona horaria para incidencia futura y el tratamiento de cierre con dato inválido. No resolver estas ambigüedades silenciosamente durante la implementación.

## Consulta y permisos propuestos

El LWC en la ficha del caso mostrará producto, garantía, evaluación registrada y una lista acotada de casos relacionados accesibles. Debe cubrir carga, vacío, error y acceso restringido. El límite y la ordenación de casos relacionados están pendientes.

| Función | Acceso previsto |
| --- | --- |
| Agente | Consulta necesaria de clientes/productos, creación de casos, acceso a cola compartida y gestión de sus casos asignados |
| Responsable | Gestión de casos del equipo, reasignación y corrección de garantía |
| Sin permisos de posventa | Acceso restringido |

Comprobar licencias y usuarios disponibles antes de comprometer el esquema de pruebas. Un administrador no sustituye pruebas con usuarios ordinarios. Si las licencias limitan los perfiles simultáneos, documentar el impedimento y un procedimiento reproducible sin compras ni falsas garantías.

## Criterios de aceptación futuros

1. Recorrido completo: creación, cola, asignación individual, seguimiento y cierre.
2. Cobertura inclusiva en ambos límites, días contiguos y fechas bisiestas.
3. Datos ausentes e incoherentes, con resultados y motivos verificables.
4. Coherencia entre cliente, contacto y producto.
5. Reevaluación explícita de abiertos y conservación de casos cerrados.
6. Asignación inicial sin sobrescribir responsables posteriormente.
7. Transiciones y cierre controlados también mediante API y automatizaciones.
8. Pruebas positivas y negativas de permisos por función, objeto, campo y registro.
9. Operaciones individuales y lotes de 200 casos.
10. LWC con carga, vacío, error y acceso restringido.
11. Informe de pendientes coherente con los datos ficticios conocidos.
12. Despliegue reproducible con resultados reales de pruebas.

Los controles locales y una futura CI pueden comprobar formato, análisis y pruebas unitarias del LWC. Jest no acredita permisos ni integración Salesforce. Apex, automatizaciones, acceso efectivo, informes y despliegue requieren evidencia en una organización. No hay todavía tests, cobertura, despliegues ni criterios aceptados por ejecución.
