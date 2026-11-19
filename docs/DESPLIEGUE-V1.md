# Despliegue y comprobación de V1

Destino: exclusivamente la Developer Edition dedicada y verificada de P04, API 68.0. Este procedimiento describe la composición final; **no acredita una instalación desde cero**. En la validación integrada de V1 se desplegaron incrementalmente cuatro componentes sobre modelo, seguridad, garantía, ciclo y consulta. No crear otra organización ni reiniciar datos para repetirlo.

## Preparación y dependencias

1. Confirmar raíz Git, rama, remotos, estado y cambios posteriores. Leer AGENTS y STATUS. No ejecutar staging, commit ni push; dejar los cambios preparados para revisión.
2. Verificar identidad de organización y administrador; alias `p04-posventa-dev` explícito en cada comando. `scripts/P04-Common.ps1` expone `Assert-P04Target -ExpectedOrgId '<ID privado verificado>'`. No usar `org display` ni publicar autenticaciones.
3. Usar herramientas existentes: Node 24.x, npm 11.x, Salesforce CLI y API 68.0. `npm ci` solo cuando haga falta reconstruir dependencias locales desde el lockfile; no instalar herramientas globales por rutina.
4. Antes de enviar metadatos compartidos, contrastar CaseStatus, perfiles/layouts, aplicación y reglas OWD/compartición con el destino. Preservar valores y concesiones ajenas. Los archivos Admin contienen asignaciones P04; no son una sustitución integral del perfil. Account Private depende de Opportunity Private, incluidos conjuntamente. Esta política afecta a la organización dedicada y no debe aplicarse automáticamente en otro entorno.

`manifest/v1.xml` reúne explícitamente los miembros de los incrementos funcionales, sin comodines ni destructivos. No ejecutar sucesivamente los manifiestos históricos sobre los archivos finales: los triggers y permisos actuales dependen de componentes añadidos después.

Dependencias del paquete final: CaseStatus → proceso/tipos y campos/validaciones; permisos personalizados y grupos → autorización y cola; modelo + cola → ciclo y Flow de entrada; servicio → adaptador y Flow de evaluación → acción/layout; Apex de consulta → LWC → FlexiPage → asignaciones de aplicación; grupo Responsable → carpeta View → informe. Los conjuntos referencian las clases/Flow/tipos existentes. Metadata API resuelve las referencias del paquete conjunto.

## Comandos

Para el incremento del informe, con modelo, seguridad, garantía, ciclo y consulta ya presentes:

```powershell
sf project deploy start --manifest manifest/sesion08.xml --target-org p04-posventa-dev --test-level NoTestRun --wait 3 --json
```

Para reconstruir la composición completa en la **misma Developer Edition**, solo tras revisar diferencias y necesidad:

```powershell
sf project deploy start --metadata StandardValueSet:CaseStatus --target-org p04-posventa-dev --test-level NoTestRun --wait 3 --json
sf project deploy start --manifest manifest/v1.xml --target-org p04-posventa-dev --test-level NoTestRun --wait 5 --json
```

NoTestRun se limita aquí al despliegue de desarrollo; **no sustituye** las cinco suites posteriores ni describe un despliegue productivo. Si la CLI pierde la respuesta o devuelve un trabajo pendiente, consultar `sf project deploy report --job-id '<ID privado>' --target-org p04-posventa-dev --wait 5 --json` hasta conocer el resultado. No iniciar otro despliegue a ciegas.

Después del despliegue:

```powershell
./scripts/Test-Consulta.ps1 -ExpectedOrgId '<ID privado verificado>'
npm run test:lwc
git diff --check
```

Test-Consulta ejecuta Modelo, Seguridad, Garantía, Ciclo y Consulta **secuencialmente**, con cobertura. La ejecución paralela de las suites durante la comprobación de la consulta LWC bloqueó fixtures compartidos de cola; no cambiar controles ni ajustes globales. Los resultados finales reales se registran en STATUS; un comando documentado no implica que se haya vuelto a ejecutar.

## Configuración y validación funcional

- Confirmar ambos Flows `P04_EntradaCaso` y `P04_EvaluarGarantia` activos, cola P04 con sus dos grupos y sin correo, guardián/ciclo vigentes.
- P04_DemoAdmin solo para el administrador autorizado. Reutilizar el usuario P04_Minimo sin rol; nunca crear otra plaza por rutina. Conjuntos y grupos se aplican conjuntamente mediante Set-SecurityScenario. IDs privados se obtienen y contrastan en el entorno, no se versionan.
- Crear los ocho registros originales con New-Demo solo en un entorno donde no existan: el script aborta ante muestra previa. En esta organización **no ejecutarlo de nuevo** ni alterar originales. La demostración usa temporales identificados.
- Comprobar la página Case P04 asignada solo a app/tipo/perfiles Large, con evaluación, propietario, cierre y LWC. Recarga completa si Lightning mantiene la asignación anterior.
- Carpeta P04 Posventa compartida con P04_Responsables como View; permiso RunReports sin edición/administración de informes. Abrir desde Reports y contrastar filtros, filas y recuentos con el Responsable, después denegar acceso al retirar concesiones.
- Realizar [DEMO-V1](DEMO-V1.md), conservar los originales y restaurar concesiones, membresías y política Login As. Eliminar solo IDs de temporales registrados, sin purgar.

La instalación completa debe contrastarse en un futuro entorno autorizado antes de atribuirle éxito desde cero. No se declaran CI remota, producción, carga, concurrencia ni envío de comunicaciones. El despliegue versiona la definición; asignar personas reales y aceptar autenticación/MFA siguen siendo operaciones explícitas del entorno.
