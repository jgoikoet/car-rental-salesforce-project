# AlquilaVehículo S.L — VRT (Vehicle Rental Tool)

Aplicación Salesforce para la gestión del alquiler de una flota de vehículos: precios dinámicos, control de disponibilidad, aprobación financiera escalonada, consola operativa (LWC), facturación automática y buscador global de flota.

Ver [`ARQUITECTURA.md`](./ARQUITECTURA.md) para el detalle de las decisiones de diseño.

## Requisitos previos

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) (`sf`) instalado (`sf --version` para comprobar).
- Acceso a un org destino: Developer Edition, Sandbox o Scratch Org (con Dev Hub habilitado si se usa Scratch Org — este proyecto incluye `config/project-scratch-def.json`).
- Git.
- Permisos de administrador en el org destino (se despliegan perfiles, flows y un proceso de aprobación).

## 1. Clonar el proyecto

```bash
git clone <url-del-repositorio>
cd car-rental-salesforce-project
```

El proyecto ya incluye `sfdx-project.json` apuntando a `force-app/` como paquete por defecto.

## 2. Autenticar o crear el org destino

**Opción A — Org existente (Sandbox / Developer Edition):**

```bash
sf org login web --alias vrt-org --instance-url https://login.salesforce.com
```

Usa `https://test.salesforce.com` si el destino es un Sandbox.

**Opción B — Scratch Org (requiere Dev Hub):**

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias vrt-scratch --duration-days 30
sf config set target-org=vrt-scratch
```

## 3. Desplegar el metadata

El repositorio incluye `manifest/package.xml` con todos los tipos de metadata del proyecto (Apex, Flows, objetos custom, LWC, perfiles, static resources, etc.):

```bash
sf project deploy start --manifest manifest/package.xml --target-org vrt-org
```

Alternativa desplegando directamente desde el código fuente local (útil si has hecho cambios que aún no están en el manifest):

```bash
sf project deploy start --source-dir force-app --target-org vrt-org
```

Notas:
- `staticresources/` incluye imágenes de vehículos (varios MB), por lo que el primer despliegue puede tardar más de lo habitual.
- Si el despliegue de `profiles/` falla por conflictos con perfiles estándar ya existentes en el org destino, repite el despliegue excluyendo temporalmente ese tipo de metadata y despliégalo aparte.

## 4. Cargar datos de ejemplo

El proyecto incluye un script Apex que inserta Accounts, Vehículos y Alquileres de ejemplo (definidos en `data/*.csv`, cargados en línea en el propio script):

```bash
sf apex run -f scripts/apex/insertSampleData.apex --target-org vrt-org
```

- Los `Account` y `VRT_Vehicle__c` se cargan con `upsert` usando `VRT_TXT_ExternalId__c` como Id externo, por lo que el script puede relanzarse sin duplicar estos registros.
- Los `VRT_Rental__c` se insertan siempre como nuevos; para una carga limpia, borra los existentes antes de relanzar el script.
- Más detalle en [`scripts/README.md`](./scripts/README.md).

## 5. Configuración manual post-despliegue

1. **Proceso de aprobación de alquileres (`Alquiler_ammount`)**
   Verifica en **Configuración → Procesos de aprobación** que el proceso `Alquiler_ammount` esté activo, con el perfil `Gerente` como aprobador del primer escalón (> 3.000 €) y `Responsable Financiero` como segundo escalón (> 10.000 €).

2. **Permisos del perfil Gerente**
   Confirma que el perfil `Gerente` desplegado **no** tiene `Modify All Data`, `Approval Admin` ni permisos de modificación total sobre `VRT_Rental__c` — se retiraron deliberadamente para que el Gerente no pueda ejecutar también el segundo paso de aprobación reservado al Responsable Financiero (ver `ARQUITECTURA.md`, sección 3.4).

3. **Asignación de perfiles**
   El modelo de acceso se basa en perfiles custom (`Gerente`, `Responsable Financiero`, `Responsable de equipo`, `Trabajador`). Asigna el perfil correspondiente a cada usuario desde **Configuración → Usuarios**.

4. **Suscriptor del Platform Event `Forbidden_Rental_Update_Event__e`**
   El trigger de `VRT_Rental__c` publica este evento para registrar en `Log__c` los intentos de pasar un alquiler a "En curso" sin que el pago esté "Pagado" (ver `ARQUITECTURA.md`, sección 3.7). El Flow suscrito se llama **`Creación de Log para update prohibido de alquiler`**; si al desplegar por manifest no se incluye automáticamente, tráelo al proyecto local desde el Org Browser de VS Code (Metadata Type `Flows` → buscarlo por su API Name) y añádelo al manifest o vuelve a desplegarlo explícitamente.

5. **Programar el batch de revisión de vehículos (ITV)**
   El job `VRT_CLS_VehicleRevisionSchedule` no se autoprograma al desplegar. Prográmalo a diario a las 10:00, por ejemplo mediante Anonymous Apex:
   ```apex
   System.schedule('Revision ITV Vehiculos VRT', '0 0 10 * * ?', new VRT_CLS_VehicleRevisionSchedule());
   ```

6. **Página Visualforce de factura**
   Comprueba que la página `FacturaRentalPDF` esté habilitada para los perfiles que van a generar facturas (Configuración de Visualforce → Security), y que la organización tenga habilitado el envío de emails salientes.

## 6. Ejecutar los tests Apex

```bash
sf apex run test --target-org vrt-org --test-level RunLocalTests --code-coverage --result-format human --wait 10
```

El proyecto incluye clases de test para el trigger de `VRT_Rental__c`, el flujo de aprobación, el cálculo de penalización, el batch/schedulable de ITV, los controladores Apex de ambos LWC y el generador de PDF, además de tests unitarios de los propios componentes LWC (`__tests__`).

## 7. Verificación post-despliegue

- Abre la app **AlquilaVehículo S.L** desde el App Launcher.
- Crea un vehículo de prueba (`VRT_Vehicle__c`) y comprueba que el campo Nombre se autogenera con tipo + marca + modelo (Flow `Creates_vehicle_name`).
- Desde una ficha de `Account`, usa la Quick Action **Crear un Alquiler** y completa el Screen Flow; prueba a forzar un error (por ejemplo, fechas inválidas) para comprobar que el Fault Path informa correctamente y permite reintentar.
- Desde la consola operativa (`alquilerConsole`) en la ficha de cuenta, crea un alquiler y verifica que el coste y el descuento se recalculan dinámicamente al cambiar las fechas.
- Simula un alquiler con importe superior a 3.000 € y comprueba que entra en proceso de aprobación; con más de 10.000 €, comprueba el segundo escalón (Responsable Financiero) y que el Gerente no puede aprobarlo también.
- Marca un alquiler como `Completado` y comprueba que se genera y adjunta la factura en PDF en la pestaña Files del registro.
- Prueba el buscador global de flota (`buscadorGlobalFlota`) por matrícula, marca y modelo parciales.
