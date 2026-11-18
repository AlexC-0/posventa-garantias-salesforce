# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna con datos ficticios y garantía simulada.

## Estado actual

**Sesión 05: servicio único de evaluación de garantía implementado y desplegado en P04.** P04Garantia evalúa casos abiertos respecto a su fecha de incidencia y guarda resultado, motivo, fechas utilizadas y momento. P04EvaluarGarantiaAccion prepara la entrada para un futuro Flow reutilizando exactamente el mismo servicio.

La cobertura incluye ambos límites. Si falta inicio o fin, el resultado es pendiente de datos y explica qué falta; la compra es opcional. Datos incoherentes son errores. La evaluación inicial y la reevaluación son explícitas: modificar producto o incidencia no recalcula la instantánea. Los casos cerrados se rechazan conservando su evaluación.

Se mantienen las restricciones de sesión 04: agente sobre sus casos, responsable sobre casos editables del equipo, usuario sin permisos denegado. Los siete campos siguen sin edición directa ordinaria. La escritura privilegiada está limitada a los registros autorizados y valores calculados, sin bypass público.

Comprobado en esta sesión: **7 componentes desplegados, 65/65 pruebas Apex** (25 de garantía, 20 de modelo y 20 de seguridad), lotes de 200 y demostración administrativa de evaluación/reevaluación/cierre con reversión de temporales. No se realizaron nuevas pruebas UI/REST con identidad ordinaria; esa autorización se comprobó en Apex bajo usuarios aislados.

El lote es atómico: un rechazo impide guardar todas sus evaluaciones. Duplicados se procesan una vez conservando una respuesta por solicitud. Se mantienen los ocho registros originales de muestra, con sus dos casos sin evaluar; la demostración usa registros temporales revertidos. No hay campos nuevos: siguen siendo 13.

Continúan pendientes Flow de asignación, cola, ciclo completo de estados/cierre, informes y LWC. No hay pruebas de concurrencia entre transacciones ni despliegue de producción.

## Proyecto y entrega

Ruta: C:\Users\kaosk\source\repos\posventa-garantias-salesforce.

Repositorio: [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), main. Inicio limpio en 4cfaf0bf3709d373fcaa75fc7a76b73dbd2cbbb3, publicado por Alex según el encargo y presente en HEAD/origin/main locales. Sin nueva comprobación de la punta remota. Los resultados de sesión 05 corresponden al árbol nuevo desplegado, no al commit anterior ni a CI.

Los cambios quedan sin staging; Alex hace commit y push. API 68.0 y destino explícito p04-posventa-dev. Herramientas conservadas: CLI 2.158.7, extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13. No hubo instalaciones, nuevas cuentas persistentes ni cambios de política de acceso.

## Documentación y demostración

- [Servicio, invocación, atomicidad y seguridad](docs/GARANTIA.md).
- [Resultados, límites y propuesta de commit](docs/STATUS.md).
- [Despliegue y pruebas reproducibles](docs/TESTING.md).
- [Modelo e instantáneas](docs/DATA_MODEL.md).
- [Seguridad por función](docs/SECURITY.md).
- [Alcance V1](docs/PROJECT_BRIEF.md).
- [Entorno histórico](docs/ENVIRONMENT.md).
- [Reglas de trabajo](AGENTS.md).

```powershell
./scripts/Demo-Garantia.ps1 -ExpectedOrgId '<identificador privado P04 verificado>'
```

La demo administrativa evalúa un caso temporal, comprueba que corregir su producto no recalcula, reevalúa mediante el invocable y rechaza otra evaluación tras cerrar. Revierte producto/caso temporales y verifica su ausencia. No modifica la muestra ni envía correo.

El usuario de pruebas permanece activo en perfil mínimo, sin rol, permisos P04 ni grupos; ambas licencias Salesforce siguen ocupadas. La siguiente fase se revisará antes de empezar. Esta sesión termina con la entrega para revisión y publicación manual de Alex.
