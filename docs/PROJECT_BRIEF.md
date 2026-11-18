# Proyecto 04 — Alcance y diseño propuesto

Actualizado en la sesión 04, 18 de noviembre de 2026. Se conserva el alcance V1. La base Account/Contact/Asset/Case, validaciones y seguridad por función están implementadas y desplegadas en P04. Contrato en [DATA_MODEL](DATA_MODEL.md), permisos en [SECURITY](SECURITY.md) y resultados en [STATUS](STATUS.md). Evaluación, ciclo completo, cola/asignación, informe y LWC siguen pendientes.

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

Objetos y relaciones estándar verificados. La sesión 03 incorporó 12 campos, nueve reglas de validación, tipos/proceso propios y protecciones Apex. La sesión 04 añade un campo de ámbito de cliente (13 propios en total), seguridad por función, compartición y autorización separada de integridad. Los nombres API y la distinción entre vacío/sin evaluar y pendiente de datos están en DATA_MODEL. No hay todavía servicio de evaluación, Flow ni LWC. Pendientes: evaluación/reevaluación y coordinación del ciclo.

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

Decisiones fijadas en sesión 03: incoherencias se rechazan en servidor antes de evaluar; datos válidos incompletos podrán producir pendiente de datos; cobertura futura inclusiva. Incidencia futura respecto a TODAY() del usuario ejecutor, sin conversiones DateTime. Un guardado inválido, incluido un intento de cierre, se rechaza. El cierre con evaluación pendiente se limitará a Sin_actuacion explicado cuando se implemente el ciclo. Las validaciones pueden devolver más de un error; todavía no existe un servicio que ordene motivos de evaluación. Las instantáneas futuras no son fórmulas ni se actualizan automáticamente.

## Consulta y permisos propuestos

La matriz de seguridad ordinaria ya está implementada y comprobada en sesión 04; el acceso a cola de la V1 siguiente todavía no existe. Se utilizó un único usuario persistente con permisos secuenciales y dos agentes aislados en Apex, preservando al administrador. Los resultados y límites concretos prevalecen sobre las propuestas siguientes.

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

Los controles locales y una futura CI pueden comprobar formato, análisis y pruebas unitarias del LWC. Jest no acredita permisos ni integración Salesforce. La sesión 03 tiene evidencia de integridad y lotes de 200; la sesión 04 añade 20 pruebas de seguridad, regresión 20/20, interfaz ordinaria y revocación. Esto no acredita evaluación de cobertura, flujo completo ni todos los criterios V1. Próxima fase recomendada: servicio único de evaluación de garantía, sin iniciarlo automáticamente.
