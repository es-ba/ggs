# CLAUDE.md — ggs

@node_modules/dmencu/CLAUDE.md

Encuesta de Generación y Género (GGS2026). App que corre sobre Backend-Plus y PostgreSQL y **extiende `dmencu`** (dependencia npm, ver `package.json`) mediante la clase `AppGgs` en `src/server/app-ggs.ts`. Funciona en dispositivos móviles mediante offline-first (PWA con service worker), igual que dmencu.

Lo que es común a todos los relevamientos (hoja de ruta, asignaciones, motor de tareas, metadatos de formularios) vive en `dmencu`, `meta-enc` y `backend-plus`. Acá sólo van las diferencias de ggs. Antes de tocar comportamiento general, seguir las reglas de dmencu importadas arriba (`node_modules/dmencu/CLAUDE.md`). Las apps hermanas `etoi` y `repsic` siguen el mismo patrón y sirven de referencia.

---

## Estructura de archivos

- `src/server/` — backend. Cada tabla tiene su archivo `table-*.ts`. El código del operativo está en `src/server/def-config.ts`, no en este archivo.
  - `app-ggs.ts`: clase `AppGgs` que extiende a la de dmencu (menús, `clientIncludes`, `createResourcesForCacheJson`, colores y manifest de la PWA, etc.). Acá también se agregan las tablas propias a los menús.
  - `def-config.ts`: configuración estática (`defConfig`), incluye los scripts de instalación de la base (`install.dump.scripts`). Los scripts `post-adapt` cargan la lógica de dmencu, meta-enc y consistencias.
  - `procedures-ggs.ts`: procedimientos propios; se suman a los de dmencu en `getProcedures`.
  - `types-ggs.ts`: tipos propios y re-exports de dmencu.
  - `server-ggs.ts`: punto de entrada. Arma la app por composición de mixins (ver abajo) y fija `OperativoGenerator.mainTD` (`viviendas`) y `mainTDPK` (`vivienda`), además de `pgWhiteList`.
  - Tablas propias: `viviendas`, `hogares`, `personas`, `visitas`, `visitas_web`, `visitas_tel`, `visitas_pres`, `visitas_sup`, `hogares_sup`, `personas_sup`, `rea_sin_blaise`, `tem_blaise`, `backups`, `lotes`, `match_id`.
- `src/client/` — `menu.ts` (menú propio del cliente).
- `src/unlogged/` — formulario de relevamiento sin login.
  - `my-bypass-formulario.ts` y `my-render-formulario.ts`: ganchos propios que se conectan a `dmencu/dist/unlogged/unlogged/*`. Acá viven reglas como el cálculo de "rea" / "no rea" (`esRealizada`, `esNoRea`, `esNoReaSup`).
  - `offline.jade`, `img/`: plantilla, íconos y logos (variantes `_test` y `_capa` para los otros entornos).
- `src/test/test.ts` — tests (hoy vacío, ver sección de tests).
- `install/` — datos y scripts de instalación. `operaciones/` — scripts SQL con fecha (`AAAAMMDD-*.sql`) para aplicar cambios en bases ya existentes.
- `dist/` — salida generada por el build. Está en `.gitignore`, no editar ni versionar.
- `sessions/`, `local-*.sql`, `local-*.yaml`: locales, no se versionan.

> 📝 Antes de trabajar con cualquier tabla, leer su `table-*.ts`. Si una tabla de dmencu necesita un cambio para ggs, hacerlo con `be.appendToTableDefinition(...)` en `app-ggs.ts` antes que copiar el archivo entero.

---

### Stack

- **Base de datos**: PostgreSQL, esquema `base`. Hay dos usuarios: un owner (`ggs2026_owner`) que crea tablas y procedimientos, y un admin (`ggs2026_admin`) que usa el backend. Sus datos de configuración están en `def-config.ts` y en `local-config.yaml`.
- **Dependencias clave**: `dmencu` (ver `package.json`). Al actualizarla, revisar que los imports de `dmencu/dist/...` sigan existiendo.
- **Puerto y ruta**: `server.port` 3070 y `base-url` `/ggs2026` en `def-config.ts`.

---

## Variantes y configuración local

- `local-config.yaml` (y cualquier `local-*` o `*-local.*`) contiene credenciales y **no se versiona** (`.gitignore`). `example-local-config.yaml` es la plantilla. **Nunca copiar contraseñas, secretos ni credenciales de esos archivos a este CLAUDE.md, a commits o a la documentación.**
- `def-config.ts` tiene los valores base; la configuración local los pisa.
- La variante se elige con la variable de entorno `BACKEND_PLUS_LOCAL_CONFIG`, que apunta al archivo de configuración local. `.vscode/launch.json` tiene perfiles para back office (`local-config.yaml`), backups (`local-config-backups.yaml`) y DM (`local-config-dm.yaml`). Los perfiles "Launch" compilan antes; los "Fast Launch" no compilan.
- `install.table-data-dir` en la configuración local apunta a datos fuera del repo (`../dmencu-data/ggs2026`). No copiar esos datos al repo.
- Para probar una variante, cambiar la variable de entorno o usar el perfil del `launch.json`; no editar `def-config.ts` para eso.

---

## Compilación

- `npm run build` compila en orden `src/unlogged`, `src/client`, `src/server` y luego corre `mixin-patch`. Cada paso se puede correr por separado (`build-client`, `build-server`, `build-unlogged`).
- `npm run dump` / `npm run bdump` regeneran la base desde la configuración; `bdump` compila antes.
- Los tipos de React tienen que ser los de la versión 17 que usa dmencu (`@types/react`, `@types/react-dom`, `@types/react-redux` en devDependencies). Si se instala `@types/react` 19, el build falla dentro de los `.tsx` de `node_modules/dmencu/dist`.

---

## Checklist para actualizar dmencu

Hacer siempre estos pasos antes de dar por actualizado dmencu (comparar la versión instalada contra la nueva, por ejemplo con `git diff vX vY` en el repo de dmencu):

1. **Scripts de operaciones**: buscar archivos nuevos en `operaciones/` de dmencu. Adaptarlos a ggs (usuarios `ggs2026_owner` / `ggs2026_admin`, valores de `operativo`, columnas que ggs ya hubiera agregado) en un único script propio `operaciones/AAAAMMDD-actualizar_dmencu_X_Y_Z.sql`. Probarlo en la base local dentro de una transacción con `rollback`.
2. **Triggers y funciones nuevos**: comparar la lista `install.dump.scripts` de `node_modules/dmencu/dist/server/server/def-config.js` contra `src/server/def-config.ts` y agregar los nuevos en el mismo orden.
3. **SQL modificados**: revisar el diff de `install/*.sql` de dmencu. Si cambia una función que ggs ya carga, el script de operaciones la tiene que recrear.
4. **SQL propios afectados**: si dmencu cambia tipos de columnas (por ejemplo `no_rea` pasó de `text` a `integer`), buscar en `operaciones/` e `install/` de ggs las funciones y triggers que las usen y recrearlas corregidas en el script de operaciones.
5. **Tablas**: revisar los cambios en `table-*.ts` de dmencu. Los campos que ggs agregaba con `appendToTableDefinition` y ahora trae dmencu se sacan de `app-ggs.ts`. Los `splice` por posición en `app-ggs.ts` se rompen si dmencu reordena campos.
6. **Ganchos del formulario**: revisar las firmas exportadas en `dmencu/dist/unlogged/unlogged/*` que usan `my-bypass-formulario.ts` y `my-render-formulario.ts` (por ejemplo `setCalculoReaNoRea`).
7. **Build** limpio (`rm -rf dist && npm run build`) sin errores.

---

## Composición de la app

La app se arma por **composición de mixins** en `src/server/server-ggs.ts`, de adentro hacia afuera:

```ts
var AppGgs = emergeAppGgs(                // capa propia de ggs (app-ggs.ts)
    emergeAppDmEncu(                      // dmencu: hoja de ruta, tareas, DM
        emergeAppProcesamiento(
            emergeAppConsistencias(
                emergeAppDatosExt(
                    emergeAppMetaEnc(
                        emergeAppRelEnc(
                            emergeAppVarCal(
                                emergeAppOperativos(AppBackend)  // base: backend-plus
                            )
                        )
                    )
                )
            )
        )
    )
);
new AppGgs().start();
```

- La capa **más externa** es la que sobreescribe; la más interna es la base. Un método de `AppGgs` pisa al de dmencu, y así sucesivamente.
- Para agregar una capa, el mixin tiene que recibir una clase `Base` y devolver `class ... extends Base`.
- `OperativoGenerator.mainTD`, `mainTDPK` y `pgWhiteList` son globales: cambiarlos afecta a todas las variantes que compartan el proceso.

---

## Contexto de base de datos — esquema `base`

Todos los objetos pertenecen al esquema `base`. Los nombres están en castellano.

### Lógica de negocio en PostgreSQL

Muchas reglas de negocio críticas están implementadas como **funciones almacenadas y triggers en PostgreSQL**, no en el backend Node.js. Esto es una decisión arquitectónica deliberada: garantiza que esas reglas no puedan saltearse aunque alguien modifique el backend.

Los scripts de esa lógica vienen de `dmencu`, `meta-enc`, `consistencias`, `varcal`, `operativos` y de los propios `install/` (`schema-backups.sql`) y se cargan desde `def-config.ts` (`install.dump.scripts.prepare` y `post-adapt`). Ejemplos: `sincronizacion_tem.sql`, `control_cargado_tareas_tem_trg.sql`, `generador_accion_cumple_condicion.sql`, `tarea_cumple_condicion.sql`, `casilleros_orden_total_fun.sql`.

> ⚠️ Si Claude Code necesita entender o modificar una regla de negocio importante, debe buscar primero si existe una función o trigger en PostgreSQL que la implemente — no asumir que toda la lógica está en TypeScript. Reimplementar en el backend lógica que ya existe en la base de datos introduce duplicación y riesgo de inconsistencia. Buscar en `node_modules/dmencu/install/`, `node_modules/meta-enc/install/`, `install/` y `operaciones/` antes de agregar lógica nueva.

### Cambios sobre bases existentes

- Un cambio que haya que desplegar sobre datos reales se agrega en `operaciones/` como script con fecha (`AAAAMMDD-*.sql` o `AAAAMMDD_actualizar_*.sql`), no sólo en `install/`.
- `install/pre-adapt.sql` y los scripts de `def-config.ts` se aplican en la instalación; no asumir que se reaplican sobre una base viva.

---

## Casos de prueba

- **Estado actual**: `package.json` define `npm test` como `mocha ... test/`, pero no existe carpeta `test/` en la raíz y `src/test/test.ts` está vacío. Hoy no hay tests propios de ggs.
- Cuando se agreguen, seguir el esquema de dmencu / repsic: compilar `src/test` a `dist/test/` y correr mocha sobre `dist/test/test.js`. Alinear `package.json` con esa estructura antes de escribir tests.
- Los tests de base deben revertir todo lo que escriben (cada test en una transacción con `begin` / `rollback`). No dejar escrituras que sobrevivan al test.
- Si un test se saltea por falta de credenciales, no es un test verde: avisarlo al reportar.

---

## Documentación

- Este repo no tiene `docs/` ni `ayuda/` propios. La documentación para desarrolladores y la ayuda en línea de la familia de apps están en `dmencu`.

---

## Git

- Rama principal: `main`.
- Commits en español, en imperativo corto, como los existentes (`agregar campos del backup...`, `renombro archivo de trigger...`).
- No commitear ni publicar sin pedido explícito. No commitear `local-*`, `dist/`, `node_modules/` ni `sessions/`.
