# Entorno y preparación

Inspección propia de Codex: 17 de noviembre de 2026. Windows de 64 bits, versión de sistema 10.0.19045.0. Carpeta independiente: `C:\Users\kaosk\source\repos\posventa-garantias-salesforce`.

## Herramientas observadas

| Herramienta | Resultado |
| --- | --- |
| Git | 2.56.1.windows.1 |
| VS Code | 1.146.0, x64 |
| Node.js | v24.13.0 |
| npm | 11.6.2 |
| Salesforce CLI sf / sfdx | No encontrados en PATH ni en las ubicaciones habituales comprobadas |
| Extensiones Salesforce | Ninguna en la lista devuelta por code |
| Java activo | JRE 1.8.0_503, 64 bits |
| JDK | Carpeta jdk1.8.0_111 detectada; javac no disponible en PATH. No se detectó JDK 21 en las ubicaciones comprobadas |
| JAVA_HOME / JDK_HOME | Sin definir en esta sesión |

Comandos ejecutados: `Get-Command` para git/code/sf/sfdx/node/npm/java/javac, `git --version`, `node --version`, `npm --version`, `code --version`, `code --list-extensions --show-versions`, `java -version`, comprobación de existencia de rutas habituales y lectura de versión del sistema mediante .NET.

VS Code devolvió versión y extensiones, pero emitió errores de acceso a crashpad y al directorio de logs dentro del entorno restringido. No se ha demostrado el funcionamiento de las extensiones Salesforce. La consulta CIM del sistema fue denegada; se usó .NET para versión y arquitectura. La inspección de instalaciones fue acotada, no una búsqueda exhaustiva del disco.

## Compatibilidad documental

Fuentes oficiales consultadas el 17 de noviembre de 2026:

- [Requisitos Salesforce CLI](https://developer.salesforce.com/docs/platform/sfdx-setup/guide/sfdx-setup-sys-req.html): Windows de 64 bits compatible; instalador con Node incluido. Para instalación npm se recomienda Node Active LTS. No se ha verificado una combinación concreta de CLI con Node/npm locales.
- [Instalación CLI](https://developer.salesforce.com/docs/platform/sfdx-setup/guide/sfdx-setup-install-cli.html): elegir un único método; se propone instalador Windows x64, sin actualizar Node/npm globales.
- [Extensiones Salesforce](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/install.html): mínimo VS Code 1.90, superado por la versión observada; requieren CLI y JDK compatible.
- [Java para Apex](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/java-setup.html): JDK 21 recomendado. Java 8 activo no cumple el requisito.
- [Developer Edition y API](https://developer.salesforce.com/docs/platform/api/guide/sforce-api-quickstart-steps-obtain-dev-org.html): alta independiente y permiso API Enabled.
- [Autenticación web de CLI](https://github.com/salesforcecli/plugin-auth): autenticación en navegador con alias; no establecer destino predeterminado.

No se ha instalado, actualizado ni configurado software global. No se fija versión de API ni configuración DX: faltan CLI y comprobación remota.

## Organización: pendiente

No hay organización dedicada identificada o autenticada en esta sesión. Las carpetas habituales de autenticación `~/.sf` y `~/.sfdx` no existen. Esto no demuestra que Alex carezca de una organización en el navegador. No se han leído credenciales ni contactado organizaciones Salesforce.

| Comprobación remota | Estado |
| --- | --- |
| Identidad, tipo y edición | Pendiente |
| Versiones API y permiso API Enabled | Pendiente |
| Account, Contact, Asset y Case; campos/relaciones necesarios | Pendiente |
| Apex, Flow, LWC, colas e informes | Pendiente |
| Licencias, usuarios activos y plazas disponibles para pruebas | Pendiente |
| Permisos para despliegue y ejecución de tests | Pendiente |
| Límites de almacenamiento y API relevantes | Pendiente |

No se deducen estas capacidades por el nombre Developer Edition. En sesión 02, comprobar identidad con Alex antes de consultar. Usar siempre destino explícito `--target-org p04-posventa-dev`. Consultar solo metadatos/capacidades y recuentos necesarios; registrar resultados filtrados sin usuarios, dominios privados ni secretos. La comprobación de permisos de despliegue por lectura no equivaldrá a un despliegue exitoso.

## Pasos pendientes para Alex

1. Abrir esta carpeta del Proyecto 04 como espacio de trabajo independiente en VS Code.
2. Instalar Salesforce CLI con el [instalador oficial](https://developer.salesforce.com/tools/salesforcecli) Windows x64, usando un único método. Reabrir terminal y comprobar `sf --version`. No reinstalar herramientas que ya funcionan.
3. Instalar Salesforce Extension Pack de Salesforce (`salesforce.salesforcedx-vscode`) y JDK 21 siguiendo la guía oficial. Conservar el Java existente si otras tareas lo requieren; configurar `salesforcedx-vscode-apex.java.home` solo para este espacio de trabajo con una ruta local, sin publicarla.
4. Crear una Developer Edition exclusivamente para este proyecto en el [alta oficial](https://developer.salesforce.com/signup), activar la cuenta desde el correo y completar el acceso en el navegador. Si ya existe una dedicada, identificarla primero sin compartir credenciales.
5. Tras confirmar que la sesión del navegador corresponde a esa organización, autenticar:

```powershell
sf org login web --alias p04-posventa-dev --instance-url https://login.salesforce.com
```

No añadir `--set-default` ni `--set-default-dev-hub`. El alias es propuesto y todavía no existe. No pegar salidas de autenticación ni URLs de acceso en chats o documentos.

6. El repositorio local ya está inicializado en main. En GitHub Desktop usar File > Add local repository (Ctrl+O), seleccionar `C:\Users\kaosk\source\repos\posventa-garantias-salesforce` y pulsar Add repository. Revisar los seis archivos, introducir Summary y Description y realizar el primer commit manualmente. Después, Publish repository permite a Alex crear el remoto y publicar el commit, revisando cuenta, nombre y visibilidad antes de confirmar. No crear otra carpeta ni otro repositorio local.

## Preparación DX posterior

Una vez disponible CLI, revisar su ayuda y generar la estructura estándar mínima sin ejemplos en una ubicación temporal exclusiva dentro de este proyecto, para revisar e incorporar solo los archivos DX necesarios sin sobrescribir README, AGENTS o docs. No se ha ejecutado generación en esta sesión. Toda API de plantilla será provisional hasta contrastarla con la organización. No añadir CI ni tests vacíos.
