# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna para registrar incidencias de productos, repartir el trabajo de posventa, evaluar una garantía simulada y seguir cada caso hasta su resolución. Solo utiliza datos ficticios.

## V1 implementada

- Clientes, contactos, productos y casos sobre Account, Contact, Asset y Case, con relaciones y validaciones propias de P04.
- Entrada de casos a una cola, toma y asignación autorizadas, seguimiento y cierre protegido también en servidor.
- Evaluación explícita respecto a la incidencia. Guarda resultado, motivo y fechas utilizadas; corregir el producto no recalcula el histórico.
- LWC de consulta: producto actual, evaluación registrada y hasta cinco casos relacionados accesibles. **Actualizar** recupera datos después de evaluar o editar; no calcula ni escribe.
- Informe estándar **P04 Casos pendientes**, en carpeta **P04 Posventa**: tres estados abiertos, cola y personas, agrupación por estado/propietario, recuentos y detalles antiguos primero. Sin límite temporal. Excluye cerrados y clientes ajenos.
- Permisos por función, compartición y CRUD/FLS. Responsable consulta y ejecuta el informe mediante carpeta View y RunReports, sin administrar su definición.

La configuración estándar aporta objetos, validaciones, acciones, seguridad e informe. Flow coordina entrada y evaluación; Apex centraliza autorización, integridad, garantía y ciclo. El LWC presenta datos autorizados sin duplicar esas reglas.

## Desplegar, probar y demostrar

1. Seguir [DESPLIEGUE-V1](docs/DESPLIEGUE-V1.md): identidad del destino, dependencias, manifiesto completo y configuración de miembros. La instalación desde cero está documentada, pero no se ha ejecutado en otra organización.
2. Ejecutar las cinco suites Apex **secuencialmente** con `scripts/Test-Consulta.ps1` y Jest con `npm run test:lwc`. [TESTING](docs/TESTING.md) distingue comprobaciones actuales e históricas.
3. Abrir **P04 Posventa → Cases** para el recorrido y **Reports → All Folders → P04 Posventa** para el informe. Seguir el [guion de cinco minutos](docs/DEMO-V1.md); preparación y restauración son pasos separados.

Validación integrada de V1 (18/11/2026): despliegue incremental de cuatro componentes, **106/106 Apex y 23/23 Jest** satisfactorios. El informe y el recorrido integrado se contrastan en Salesforce con el usuario ordinario. La [matriz de doce criterios](docs/ACEPTACION-V1.md) relaciona implementación, evidencia y límites. [STATUS](docs/STATUS.md) registra resultados, restauración y estado de entrega.

## Documentación funcional

- [Alcance y criterios](docs/PROJECT_BRIEF.md), [modelo](docs/DATA_MODEL.md) y [seguridad](docs/SECURITY.md).
- [Garantía](docs/GARANTIA.md), [ciclo y cierre](docs/CICLO.md), [consulta LWC](docs/CONSULTA.md) e [informe](docs/INFORME.md).
- [Entorno e histórico](docs/ENVIRONMENT.md) e [instrucciones](AGENTS.md).

## Entorno y entrega

Repositorio [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama main. Las pruebas registradas corresponden a la versión desplegada en la organización dedicada; no son resultados de CI.

API 68.0, destino explícito `p04-posventa-dev`, CLI 2.158.7, Node 24.13.0, npm 11.6.2 y runner oficial sfdx-lwc-jest 8.0.0. Herramientas y dependencias conservadas, sin nuevas instalaciones.

Garantía simulada, sin interpretación contractual ni uso productivo. No se acreditan carga, concurrencia real, móvil, integraciones, comunicaciones, métricas de negocio ni instalación limpia.
