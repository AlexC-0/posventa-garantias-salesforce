# Matriz de aceptación de V1

**V1 preparada para revisión final y publicación manual de Alex.** Los doce criterios siguientes están satisfechos dentro de los límites indicados.

Base publicada de sesión 07: fae9fbe. Sesión 08 comprueba la versión local desplegada; no atribuye sus cambios al remoto ni a CI. Resultados finales y restauración en [STATUS](STATUS.md).

Las cinco suites Apex de esta sesión han pasado secuencialmente: Modelo 20, Seguridad 20, Garantía 25, Ciclo 28 y Consulta 13, **106/106**. Jest: **23/23**. Apex usa usuarios aislados y USER_MODE cuando prueba permisos; no equivale a una sesión REST ordinaria. Las demostraciones anteriores se identifican como históricas.

| Criterio del brief | Implementación | Evidencia concreta | Resultado y límite |
| --- | --- | --- | --- |
| 1. Creación, cola, asignación, seguimiento y cierre | Flow P04_EntradaCaso, P04Cola, P04Ciclo, acciones estándar | P04CicloTest: consultaYTomaMiembro, transicionesYNoOp, cierreDesdeEnCurso y cierreDesdePendiente; UI Agente sesión 06 | Satisfactorio: recorrido integrado ordinario actual hasta cierre, detallado en STATUS. Un usuario reutilizable, sin simultaneidad real. |
| 2. Límites inclusivos, días contiguos y bisiestos | P04Garantia.calcular | P04GarantiaTest: limiteInicial, limiteFinal, diaAnterior, diaPosterior, dentroYFebreroBisiesto e intervaloUnDia | Satisfactorio; política simulada y fechas Date. |
| 3. Datos ausentes/incoherentes y motivos | Validaciones, P04Integridad y servicio | P04GarantiaTest: faltaInicio, faltaFin, faltanAmbas, compraOpcional; P04ModeloTest | Satisfactorio; vacío no equivale a Pendiente_datos. |
| 4. Cliente/contacto/producto coherentes | Relaciones estándar, nueve validaciones y guardián | P04ModeloTest y pruebas integridadBajoAgente/integridadBajoResponsable de P04SeguridadTest | Satisfactorio; sin pruebas nuevas de fusiones/undelete o concurrencia. |
| 5. Reevaluación explícita e histórico cerrado | P04Garantia, instantánea de siete campos y P04Ciclo | P04GarantiaTest: productoNoRecalculaYReevaluacion, incidenciaNoRecalcula, cerradoConserva; P04CicloTest: cerradoInmutableYProductoNoRecalcula | Satisfactorio en Apex; evidencia UI integrada y comparación de instantáneas en STATUS. |
| 6. Asignación inicial no sobrescribe al editar | Flow de creación, no de actualización | P04CicloTest; UI sesión 06 y alta/seguimiento actual contrastados por autoría y propietario | Satisfactorio en UI actual: propietario individual conservado al editar; consultas administrativas solo contrastan persistencia. |
| 7. Transiciones y cierre también en servidor | Trigger P04Caso y P04Ciclo | saltosYRetrocesos, cierreSinEvaluar, resolucionYExplicacionObligatorias, cadaFechaDesactualizadaRechaza, ausenciaFechaTambienExigeReevaluar | Satisfactorio con DML USER_MODE/SYSTEM_MODE y automatización activa; no se afirma REST ordinaria con token propio. |
| 8. Permisos por función/objeto/campo/registro | Perfil mínimo, conjuntos, grupos, reglas, USER_MODE y ámbito P04 | 20 P04SeguridadTest; P04ConsultaCasoTest: camposRestringidosRechazanSinParcial, productoNoVisibleRechaza, casoAjenoNoRevelaExistencia, revocacionConsultaNoUsaCache; UI histórica sesión 04 | Satisfactorio; carpeta/informe y revocación actuales se documentan en STATUS. No se conceden privilegios generales. |
| 9. Individual y lotes de 200 | Servicios y triggers masivos | P04SeguridadTest.agenteProcesaLote200EnModoUsuario; P04CicloTest.responsableAsignaDoscientos y loteDoscientosRecorrido; lotes de Modelo/Garantía | Satisfactorio; no es una prueba de carga ni transacciones concurrentes. |
| 10. LWC: carga, vacío, error y acceso restringido | p04ConsultaCaso y P04ConsultaCaso | 23 Jest y 13 Apex Consulta; UI ordinaria sesión 07; actualización en recorrido actual | Satisfactorio por capas; Jest simula transporte, no permisos. Actualizar es explícito. |
| 11. Informe coherente con muestra conocida | CaseList, filtros, grupos, carpeta View | UI Responsable actual: filas originales/temporales, estados y propietarios, All Time, recuentos y cerrado excluido; definición Analytics contrastada | Satisfactorio: 5→6→5 filas; cerrados y control ajeno excluidos; denegado tras revocación. Sin fixture de CreatedDate antiguo; All Time confirmado por UI/definición. |
| 12. Despliegue reproducible y pruebas reales | Manifiestos incrementales y v1.xml, scripts existentes | Despliegue 08: cuatro componentes; 106 Apex y 23 Jest; conversión local del manifiesto completo | Satisfactorio para desarrollo incremental documentado. Instalación desde cero no ejecutada; procedimiento y dependencias en DESPLIEGUE-V1. |

## Decisiones y competencias demostradas

- Modelado CRM sobre Account, Contact, Asset y Case, con tipos y campos acotados: [DATA_MODEL](DATA_MODEL.md).
- Configuración declarativa para entrada y acciones de usuario; validación crítica en servidor, incluida una escritura de evaluación privilegiada y estrictamente limitada: [GARANTIA](GARANTIA.md) y [CICLO](CICLO.md).
- Separación entre controles de integridad y autorización, mínimo privilegio, compartición y FLS comprobados con usuarios aislados: [SECURITY](SECURITY.md).
- LWC de consulta con estados, accesibilidad básica, navegación estándar y protección frente a respuestas tardías: [CONSULTA](CONSULTA.md) y su suite Jest.
- Informe estándar sin tipo personalizado innecesario, con carpeta View, filtros reproducibles y recuentos contrastados: [INFORME](INFORME.md).
- Despliegue incremental versionado, regresión secuencial, evidencias separadas por identidad y restauración de la demostración: [DESPLIEGUE-V1](DESPLIEGUE-V1.md) y [TESTING](TESTING.md).

No se acreditan usuarios reales, ahorro económico, métricas de negocio, adopción, producción, carga, alta disponibilidad, móvil, integración externa ni auditoría integral de accesibilidad. CV, LinkedIn y portfolio permanecen fuera de esta entrega. El cierre definitivo se revisa después de la publicación manual de Alex.
