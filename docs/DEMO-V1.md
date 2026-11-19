# Demostración de V1 — unos cinco minutos

Guion para una muestra preparada y conocida. Los tiempos son orientativos; la preparación, esperas de Salesforce y limpieza se hacen aparte. Datos ficticios y garantía simulada. Los resultados realmente ejecutados se distinguen en STATUS: este guion no los sustituye.

## Antes de comenzar

Confirmar P04, identidad ordinaria y escenario Responsable con el usuario reutilizable; no crear otra cuenta. Preparar producto temporal y casos conocidos: Nuevo en cola, En curso evaluado, Pendiente de información sin evaluar y Cerrado excluido. Registrar IDs privados, originales y recuentos esperados. El administrador prepara fixtures; esa preparación no es actividad del usuario ordinario. Usar fechas de apertura conocidas y comprobar All Time; una incidencia antigua no acredita una fecha de creación antigua.

Si se usa Login As, registrar su valor persistido tras recarga y restaurarlo después. Desactivar notificaciones en cambios de propietario. No mostrar barras de sesión, identificadores ni datos de usuarios al publicar capturas.

## Recorrido

| Tiempo | Acción y mensaje |
| --- | --- |
| 0:00–0:40 | P04 Posventa: explicar cliente/contacto/producto/caso. Crear un caso temporal Nuevo con relaciones coherentes y fecha válida. Confirmar entrada a P04 Entrada posventa y Sin evaluar. |
| 0:40–1:20 | Tomarlo para el usuario habilitado sin correo. Pasar a En curso y escribir seguimiento. Confirmar que editar no lo devuelve a cola. |
| 1:20–2:00 | En Gestión del caso, Evaluar garantía → Evaluar y guardar. Pulsar Actualizar en el LWC: separar fechas actuales de los siete valores registrados. |
| 2:00–3:00 | Corregir solo una fecha del producto temporal, sin invalidar relaciones. Actualizar: aviso de reevaluación, instantánea intacta. Intentar cerrar con resolución/explicación: rechazo por datos cambiados. Reevaluar explícitamente. |
| 3:00–4:00 | Pasar por Pendiente de información; refrescar informe y comprobar cambio de grupo. Cerrar con resolución y explicación. Actualizar LWC: histórico cerrado. Una corrección posterior del producto no cambia la evaluación cerrada. |
| 4:00–5:00 | Abrir P04 Casos pendientes desde Reports. Refresh: cerrado ausente, recuento reducido en uno, estados/propietarios y originales coherentes. Mostrar All Time, orden antiguo primero y significado de `-` como Sin evaluar. |

La función Responsable permite conectar todo el recorrido con una sola identidad; no hace falta simular dos usuarios simultáneos. Las capacidades y restricciones del Agente se acreditan por las pruebas aisladas y las demostraciones ordinarias anteriores, identificadas en la matriz.

## Después

Retirar conjuntos y membresías y comprobar denegación por URL directa de carpeta/informe en la sesión renovada. Salir de Login As. Eliminar exclusivamente temporales registrados: casos, después productos y, para el control ajeno, contacto y cliente. No purgar ni editar los ocho originales. Restaurar política administrativa y verificarla tras recarga, junto con usuario mínimo, administrador y licencias.

No enviar informes, suscribir, exportar ni publicar capturas privadas. Para repetir, usar [DESPLIEGUE-V1](DESPLIEGUE-V1.md), [INFORME](INFORME.md) y [TESTING](TESTING.md).
