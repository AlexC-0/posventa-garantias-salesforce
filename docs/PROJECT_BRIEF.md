# Proyecto 04 — Alcance y diseño propuesto

Actualizado en la sesión 06, 18 de noviembre de 2026. Se conserva el alcance V1. La base Account/Contact/Asset/Case, validaciones, seguridad por función y servicio único de evaluación explícita están implementados y desplegados en P04. Contrato en [DATA_MODEL](DATA_MODEL.md), permisos en [SECURITY](SECURITY.md), servicio en [GARANTIA](GARANTIA.md) y resultados en [STATUS](STATUS.md). La sesión 06 implementa ciclo y cola/asignación: [CICLO](CICLO.md). Informe y LWC siguen pendientes.

## Propósito y V1

Atención posventa interna para agentes y una persona responsable: clientes empresariales y sus contactos, productos registrados, casos vinculados, evaluación de garantías mediante fechas y reglas acotadas, asignación inicial a una cola, seguimiento y resolución, informe de pendientes, un LWC de consulta y permisos por función. Pruebas, demostración y despliegue reproducibles forman parte de la V1; código y metadatos se mantienen en el repositorio propio.

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

Objetos y relaciones estándar verificados. La sesión 03 incorporó 12 campos, nueve reglas de validación, tipos/proceso propios y protecciones Apex. La sesión 04 añade un campo de ámbito de cliente (13 propios en total), seguridad por función, compartición y autorización separada de integridad. La sesión 05 incorpora evaluación/reevaluación explícita y un adaptador invocable, sin campos nuevos ni Flow. El cálculo se centraliza en P04Garantia; ningún otro componente lo duplica. La sesión 06 incorpora coordinación, asignación y cierre. Pendientes: informe y LWC.

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

Decisiones fijadas en sesión 03 y concretadas en sesión 05: incoherencias se rechazan antes de evaluar; garantía incompleta produce pendiente de datos, pero compra ausente por sí sola no lo produce. Cobertura inclusiva. Incidencia futura respecto al día del usuario ejecutor, sin conversiones DateTime. El servicio distingue errores de datos y motivos de cobertura; la instantánea no es una fórmula ni se actualiza automáticamente. El cierre con evaluación pendiente se limita a Sin_actuacion explicado desde sesión 06.

## Consulta y permisos propuestos

La matriz de seguridad ordinaria ya está implementada y comprobada en sesión 04; la sesión 06 incorpora el acceso a cola con comprobación efectiva de membresía. Se utilizó un único usuario persistente con permisos secuenciales y dos agentes aislados en Apex, preservando al administrador. Los resultados y límites concretos prevalecen sobre las propuestas siguientes.

El LWC en la ficha del caso mostrará producto, garantía, evaluación registrada y una lista acotada de casos relacionados accesibles. Debe cubrir carga, vacío, error y acceso restringido. El límite y la ordenación de casos relacionados están pendientes.

| Función | Acceso previsto |
| --- | --- |
| Agente | Consulta necesaria de clientes/productos, creación de casos, acceso a cola compartida y gestión de sus casos asignados |
| Responsable | Gestión de casos del equipo, reasignación y corrección de garantía |
| Sin permisos de posventa | Acceso restringido |

Comprobar licencias y usuarios disponibles antes de comprometer el esquema de pruebas. Un administrador no sustituye pruebas con usuarios ordinarios. Si las licencias limitan los perfiles simultáneos, documentar el impedimento y un procedimiento reproducible sin compras ni falsas garantías.

## Criterios de aceptación V1

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

Los controles locales y una futura CI pueden comprobar formato, análisis y pruebas unitarias del LWC. Jest no acredita permisos ni integración Salesforce. La sesión 05 supera 65 pruebas (20 modelo, 20 seguridad y 25 garantía) y una demostración administrativa revertida. No se atribuyen UI/REST ordinarias nuevas a esta ejecución. Esto no acredita flujo completo ni todos los criterios V1. La sesión 06 se verifica por separado en STATUS: 93 pruebas y recorrido ordinario completo hasta cierre. Esa evidencia no se atribuye a los resultados históricos de sesión 05 ni completa los criterios de informe/LWC. La siguiente fase requiere otro encargo.
