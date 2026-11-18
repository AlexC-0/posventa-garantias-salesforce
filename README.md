# Atención posventa y seguimiento de garantías en Salesforce

Proyecto 04 de CHAMBA DIARIA. Aplicación interna con datos ficticios y garantía simulada.

## Estado actual

**Sesión 06 completada y desplegada en P04:** creación ordinaria en Nuevo y cola, toma autorizada, gestión individual, evaluación explícita, seguimiento y cierre controlado en servidor. La asignación inicial mediante Flow solo se ejecuta al crear; editar no devuelve el caso a la cola.

Los agentes necesitan permiso y membresía para consultar/tomar la cola. Tras la toma conservan la separación entre casos individuales. El responsable puede asignar y reasignar dentro del equipo habilitado. Los casos cerrados no admiten reapertura ni edición funcional. Cerrar exige propietario individual habilitado, resolución, explicación y evaluación vigente respecto a las cuatro fechas utilizadas; Pendiente_datos solo admite Sin_actuacion explicado.

La acción **Evaluar garantía** llama desde un Screen Flow al servicio único P04Garantia, mediante su adaptador. No duplica cálculo ni concede edición directa de los siete campos calculados. **Cerrar caso P04** es una acción estándar de actualización validada por el mismo servidor. Siguen existiendo 13 campos propios.

Comprobado: **93/93 pruebas Apex**, incluidos lotes de 200, y recorrido real con el usuario ordinario hasta cierre, con rechazo de cierre incompleto, reapertura y reevaluación del cerrado. Las lecturas administrativas posteriores confirmaron persistencia. Despliegue principal de 16 componentes con las 93 pruebas; después, acción estándar de cierre y layout (dos componentes, sin cambios Apex), comprobados en la interfaz. El manifiesto final reúne 17 componentes distintos.

Se conservan los ocho registros originales y sus dos casos sin evaluar. El único caso temporal de esta demostración se eliminó; usuario reutilizable activo en perfil mínimo, sin rol, conjuntos adicionales, grupos ni casos propios activos. Login Access Policies restaurada a false y verificada tras recarga. Ambas licencias Salesforce siguen ocupadas.

Pendientes para otros encargos: informe y LWC. Sin integraciones, producción, pruebas de concurrencia real ni nueva autenticación REST ordinaria. No se atribuye esta ejecución a CI.

## Proyecto y entrega

Ruta: C:\Users\kaosk\source\repos\posventa-garantias-salesforce.

Repositorio: [AlexC-0/posventa-garantias-salesforce](https://github.com/AlexC-0/posventa-garantias-salesforce), rama main. Inicio limpio en HEAD/origin/main locales 70ecc63cd69c9bdced0337ec686352199e90c97b, sesión 05 publicada por Alex según el encargo. No se ha vuelto a consultar la punta remota. Los resultados actuales corresponden al árbol local desplegado de sesión 06.

Cambios sin staging: Alex hace staging, commit y push. API 68.0 y destino explícito p04-posventa-dev. CLI 2.158.7; extensiones Core/Apex/LWC 68.10.0 y JDK 21.0.13 conservados, sin reinstalaciones. No se crearon cuentas persistentes ni se accedió a Gmail.

## Documentación y demostración

- [Ciclo, visibilidad y demostración paso a paso](docs/CICLO.md).
- [Resultados, limpieza, límites y propuesta de commit](docs/STATUS.md).
- [Despliegue y pruebas reproducibles](docs/TESTING.md).
- [Servicio único de garantía](docs/GARANTIA.md).
- [Modelo e instantáneas](docs/DATA_MODEL.md).
- [Seguridad por función](docs/SECURITY.md).
- [Alcance V1](docs/PROJECT_BRIEF.md).
- [Entorno histórico](docs/ENVIRONMENT.md).
- [Reglas de trabajo](AGENTS.md).

La demostración usa el usuario existente con escenario Agente temporal: crear → tomar → En curso → Evaluar garantía → Pendiente de información → Cerrar caso P04. Al terminar, eliminar solo el temporal identificado y volver a Ninguno. El procedimiento completo incluye verificaciones negativas y restauración. La sesión termina con la entrega para revisión y publicación manual de Alex.
