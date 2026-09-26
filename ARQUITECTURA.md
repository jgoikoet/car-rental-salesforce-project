# Documento técnico de arquitectura — AlquilaVehículo S.L (VRT)

## 1. Contexto y alcance

Este proyecto implementa, sobre Salesforce, la gestión de alquiler de una flota de vehículos para AlquilaVehículo S.L.: disponibilidad, reservas, cálculo dinámico de tarifas, aprobación financiera de alquileres de importe elevado, seguimiento del estado del vehículo (ITV/inspección), consola operativa (LWC) y facturación automática en PDF.

El proyecto nace en un Track I (modelo de datos, automatización básica, reports/dashboards) y evoluciona en un Track II centrado en robustez, escalabilidad y automatización avanzada: motor de precios sin intervención manual, control estricto de solapamiento de fechas, doble aprobación financiera, consola operativa en LWC, facturación asíncrona y buscador global de flota.

## 2. Modelo de datos

| Objeto | Propósito | Relaciones |
|---|---|---|
| `VRT_Vehicle__c` | Ficha de cada vehículo de la flota (marca, modelo, matrícula, kilometraje, condición, disponibilidad, fecha de última ITV) | — |
| `VRT_Rental__c` | Registro de cada alquiler (fechas, coste, estado, pago) | Lookup a `Account` y a `VRT_Vehicle__c` |
| `Log__c` | Trazabilidad de eventos relevantes del ciclo de vida de un alquiler (creación, intentos de actualización no permitidos, resultado de facturación) | Lookup a `VRT_Rental__c` |
| `Forbidden_Rental_Update_Event__e` | Platform Event usado para registrar en `Log__c` un intento de actualización no válida sin que un rollback posterior lo elimine (ver 3.7) | — |

Ambos objetos principales (`VRT_Vehicle__c`, `VRT_Rental__c`) llevan reglas de validación declarativas para invariantes básicos (fechas coherentes, coste/kilometraje/pasajeros no negativos, formato de matrícula, disponibilidad del vehículo).

## 3. Decisiones de arquitectura

### 3.1. Patrón Trigger Handler (1 trigger por objeto)

`VRT_TRG_Rental` no contiene lógica de negocio: delega en `VRT_TRG_RentalHandler`, que orquesta por evento (before/after insert/update) y a su vez delega en clases helper especializadas. Objetivo: un único punto de entrada por objeto, testabilidad y separación de responsabilidades.

Rutas de ejecución principales del trigger:
1. **`onBeforeInsert`**: `VRT_TRG_RentalHandlerHelper` reparte el trabajo en dos ramas independientes: cálculo del coste total (`VRT_CLS_RentalHAndlerHelperTotalCost`) y comprobación de disponibilidad del vehículo por solapamiento de fechas (`VRT_CLS_CheckVehicleDataDisponibility`).
2. **`onAfterInsert`**: registra un `Log__c` de creación, envía a aprobación (`Approval.process`) los alquileres de importe > 3.000 €, y para el resto actualiza el uso/condición del vehículo.
3. **`onBeforeUpdate`**: si un alquiler pasa a "En curso" sin que el pago esté "Pagado", publica un Platform Event (`Forbidden_Rental_Update_Event__e`) en lugar de insertar el `Log__c` directamente (ver 3.7); además revalida disponibilidad si un alquiler sale de "Cancelado".
4. **`onAfterUpdate`**: actualiza el kilometraje del vehículo y calcula penalizaciones por retraso cuando un alquiler pasa a "Completado".

### 3.2. Motor de precios sin intervención manual

El coste total (`VRT_DIV_TotalCost__c`) se calcula siempre en `before insert` (`VRT_CLS_RentalHAndlerHelperTotalCost.calculateCost`), nunca lo introduce el usuario. La tarifa depende del tipo de vehículo y del mes de cada día del alquiler (temporada alta/media/baja), y se aplica un 5% de descuento por fidelidad si la cuenta tiene más de 2 alquileres completados en los últimos 12 meses. El mismo cálculo se expone también a los LWC vía `VRT_CLS_LWC_CalculateTotalCost` (simulación de precio antes de guardar desde la consola operativa).

### 3.3. Control de disponibilidad de flota

`VRT_CLS_CheckVehicleDataDisponibility` comprueba, mediante SOQL agrupado por vehículo, que no exista otro alquiler no cancelado que se solape en fechas (`inicio < fin_existente AND fin > inicio_existente`) antes de permitir la inserción o la reactivación de un alquiler previamente cancelado. Es una comprobación centralizada en Apex (no en Validation Rule) porque necesita consultar otros registros, algo que una Validation Rule no puede hacer de forma nativa.

### 3.4. Sistema de aprobación financiera escalonado

Los alquileres con `VRT_DIV_TotalCost__c > 3000` se envían automáticamente al proceso de aprobación `Alquiler_ammount` (`Approval.process` desde `onAfterInsert`), con el perfil `Gerente` como primer aprobador. El propio Flow de aprobación (`Alquiler_big_amount`) implementa un segundo escalón para importes superiores a 10.000 €, en el que interviene además el `Responsable Financiero`.

Para que la doble aprobación sea efectiva se ajustó el perfil `Gerente`: al crearlo con permisos de administrador de sistema, el Gerente podía aprobar también el segundo paso (destinado al Responsable Financiero) y modificar el registro durante el proceso. Se le retiraron los permisos `Modify All Data`, `Approval Admin` y "Modify All" sobre `VRT_Rental__c`, de forma que tras su aprobación no puede ni ejecutar el siguiente paso ni editar el alquiler en curso de aprobación. Se añadió además la related list **Approval History** al layout de Alquiler para poder auditar el proceso.

### 3.5. UI custom con LWC + Apex imperativo

Los dos LWC usan llamadas Apex imperativas en vez de `@wire`, porque la mayoría de acciones son bajo demanda, no datos reactivos:

- **`alquilerConsole`** (consola operativa, embebida en la página de `Account`): usa el módulo `handleAlquiler.js` (fechas, disponibilidad dinámica de vehículos con imagen) y `getVehicleURL.js`, y llama a los Apex `VRT_CLS_checkVeicleDisponibilityForLWC`, `VRT_CLS_GetActiveRentals`, `VRT_CLS_LWC_CreateNewRent`, `VRT_CLS_LWC_CalculateTotalCost` y `VRT_CLS_LWC_GetRentFullData`. Permite listar alquileres activos, filtrarlos/ordenarlos, crear un alquiler nuevo simulando el coste y el descuento en tiempo real según las fechas elegidas, y marcar el pago como inmediato.
- **`buscadorGlobalFlota`**: usa `getVehicleURL.js` y llama a `VRT_CLS_LWC_SearchVehicles`, mostrando una ficha con imagen del vehículo para cada resultado.

### 3.6. Mejora sobre el campo Name de Vehículo

El enunciado pedía `Name` como AutoNumber en `VRT_Vehicle__c`. Se cambió a tipo texto y se añadió el Flow `Creates_vehicle_name` (Record-Triggered Before Save) que compone el nombre a partir del tipo de vehículo, la marca y el modelo. Motivo: con AutoNumber, el selector de vehículo al crear un alquiler mostraba una lista de números sin ninguna información útil; con el nombre compuesto, se ve directamente qué vehículo se está seleccionando.

### 3.7. Trazabilidad de intentos de actualización no permitidos vía Platform Event

Se decidió ampliar el registro de `Log__c` (que el enunciado pedía solo al completar un alquiler) para cubrir también la creación del alquiler y los intentos de pasarlo a "En curso" sin que el pago esté "Pagado". Este último caso choca con la Validation Rule correspondiente: al ejecutarse en `before update`, un `insert` de `Log__c` hecho directamente en el trigger se deshace en el rollback que provoca la Validation Rule al bloquear la operación. La solución fue publicar un Platform Event (`Forbidden_Rental_Update_Event__e`) desde el trigger —que no se ve afectado por el rollback de la transacción que lo originó— y delegar la creación del `Log__c` a un Flow suscrito a ese evento: **`Creación de Log para update prohibido de alquiler`**.

### 3.8. Corrección de lógica en la Validation Rule de reserva

Se desactivó `VRT_ReservaValida_ValidationRule`, que impedía guardar un alquiler en estado "Reservado" si el pago no estaba "Pagado". Se consideró un error de diseño: "Reservado" es el primer estado del ciclo de vida del alquiler, y el propio picklist de estado de pago admite "Pendiente" y "Atrasado" además de "Pagado", por lo que no tiene sentido exigir el pago completo en ese punto. El control de pago correcto se aplica más adelante, al pasar de "Reservado" a "En curso" (`VRT_PagoPendienteNoInicia_ValidationRule`, sigue activa).

### 3.9. Revisión de ITV basada en última inspección, no solo en antigüedad

El batch `VRT_CLS_CheckVehicleRevision` (programado a diario a las 10:00 mediante `VRT_CLS_VehicleRevisionSchedule`) originalmente solo miraba la antigüedad del vehículo (4 años para coches, 3 para motos) para marcar `VRT_FLG_NeedsInspection__c`. Esto provocaba que, tras pasar la ITV y desmarcar la casilla manualmente, el job la volviera a marcar al día siguiente. Se añadió el campo `VRT_DAT_LastITV__c` en `VRT_Vehicle__c` y se amplió la lógica del batch para tener en cuenta también la fecha de la última ITV, de forma que la casilla solo se marca cuando realmente corresponde revisar el vehículo de nuevo.

### 3.10. Fault Path en el Screen Flow de creación de alquiler

El Screen Flow `VRT_FLW_CreateRental` (lanzado desde la Quick Action **Crear un Alquiler** en `Account`) originalmente no gestionaba el fallo del `Create Records` del alquiler (por ejemplo, si no se cumple una Validation Rule): el usuario veía un error genérico sin poder reintentar ni salir con claridad. Se añadió un Fault Path que captura el error, muestra al usuario el motivo exacto y ofrece la opción de reintentar (volver atrás) o salir del flujo.

### 3.11. Facturación asíncrona desacoplada

La generación de la factura sigue usando una página Visualforce (`FacturaRentalPDF`) porque Lightning no genera PDFs de forma nativa. Se invoca desde el Flow `Automatización Factura PDF` (Record-Triggered After Save sobre `VRT_Rental__c`) mediante un método `@InvocableMethod` en `VRT_CLS_RentalPDFGenerator`, y el trabajo pesado (render a PDF + envío de email) se ejecuta en un método `@future(callout=true)` para no bloquear la transacción y poder hacer el callout de email de forma asíncrona.

### 3.12. Seguridad y acceso

Modelo basado en **Profiles**: perfiles custom `Gerente`, `Responsable Financiero`, `Responsable de equipo`, `Trabajador`, además de los roles jerárquicos equivalentes. Las clases Apex que exponen datos a LWC son `with sharing`.

## 4. Riesgos y puntos a verificar antes de producción

- **Tarifas hardcodeadas:** el precio por día y tipo de vehículo está definido en Apex (`VRT_CLS_RentalHAndlerHelperTotalCost` y, de forma duplicada, en `VRT_CLS_LWC_CalculateTotalCost`), no en una configuración administrable; un cambio de tarifa requiere modificar y volver a desplegar código en dos sitios.
- **Manejo de excepciones de callout:** la generación de PDF captura la excepción de `getContentAsPDF()` para que no falle en tests; conviene revisar si ese mismo manejo es suficiente en producción real.

## 5. Estructura del repositorio

```
force-app/main/default/
├── applications/     # App Lightning AlquilaVehículo S.L (VRT_VehicleRentalSL)
├── classes/          # Apex: trigger handler, batch/schedulable, controllers LWC, PDF generator, tests
├── dashboards/       # Dashboard operativo (VRT AlquilaVehículo S.L Dashboard)
├── flexipages/       # Lightning Record/App/Home pages
├── flows/            # Screen flow, record-triggered flows, flow de aprobación
├── layouts/          # Page layouts
├── lwc/              # alquilerConsole, buscadorGlobalFlota (con tests unitarios)
├── objects/          # VRT_Vehicle__c, VRT_Rental__c, Log__c, Forbidden_Rental_Update_Event__e, etc.
├── pages/            # FacturaRentalPDF (Visualforce)
├── profiles/         # Perfiles estándar + custom (Gerente, Trabajador, Responsable de equipo, Responsable Financiero)
├── quickActions/     # Crear un Alquiler (lanza el Screen Flow)
├── reportTypes/ reports/ dashboards/  # Informes y dashboard de flota/alquileres
├── staticresources/  # Imágenes de vehículos usadas en LWC
├── tabs/             # Pestañas de los objetos custom
└── triggers/         # VRT_TRG_Rental

manifest/package.xml          # Manifiesto de despliegue
config/project-scratch-def.json  # Definición de Scratch Org
scripts/apex/insertSampleData.apex  # Carga de datos de ejemplo (Accounts, Vehículos, Alquileres)
data/*.csv                    # Datos de ejemplo usados por el script anterior
```
