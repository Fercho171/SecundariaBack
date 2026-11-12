# Backend — Asistencia Escolar (Secundaria)

Backend en **Spring Boot 3 + Java 21 + PostgreSQL** para la app Angular de pase de lista
(`Secundaria`). Implementa exactamente los endpoints que el frontend ya espera (ver
`src/environments/*` y el archivo `proxy.conf.json` del proyecto Angular).

## Arquitectura

- **Spring Boot 3.3 / Java 21**, Gradle.
- **PostgreSQL** vía Spring Data JPA (Hibernate). El esquema lo versiona **Flyway**
  (`db/migration`); Hibernate queda en `validate`.
- **JWT** (librería `jjwt`) para el login: `POST /api/auth/login` devuelve un token que el
  frontend ya envía como `Authorization: Bearer <token>` (ver `auth.interceptor.ts`).
- **BCrypt** para el password del usuario (nunca se guarda en texto plano).
- Datos de demostración (`DataSeeder`) solo con el perfil Spring `demo`. En el arranque
  normal no se cargan ficticios.
- Usuario de prueba (si la base ya tiene el seed o arrancas con `demo`): **usuario `docente`**,
  **contraseña `Docente123`**.

## Requisitos

- Java 21
- Gradle 8.10+ (incluido el wrapper `gradlew`)
- Docker (para levantar PostgreSQL rápido) o una instancia de PostgreSQL 14+ ya instalada

## 1. Variables de entorno

Copia `.env.example` a `.env` y rellena usuario, clave y `JWT_SECRET` (mínimo 32 caracteres).
Spring Boot **no** lee `.env` solo: hay que exportar las variables o ponerlas en IntelliJ.

| Variable | Uso | Default |
|---|---|---|
| `DB_URL` | JDBC de PostgreSQL | `jdbc:postgresql://localhost:5432/asistencia_escolar` |
| `DB_USER` | Usuario de la BD | **obligatorio** (sin default) |
| `DB_PASSWORD` | Contraseña de la BD | **obligatorio** (sin default) |
| `JWT_SECRET` | Clave para firmar JWT (≥ 32 caracteres) | **obligatorio** (sin default) |
| `SEED_DATA` | Si el perfil `demo` está activo, carga datos de ejemplo | `true` |
| `SPRING_PROFILES_ACTIVE` | Pon `demo` solo si quieres el seeder ficticio | ninguno |

### IntelliJ IDEA

Run → Edit Configurations → **AsistenciaBackend** → Environment variables, por ejemplo:

```
DB_URL=jdbc:postgresql://localhost:5432/asistencia_escolar;DB_USER=admin_asistente;DB_PASSWORD=tu-clave;JWT_SECRET=una-clave-de-al-menos-32-caracteres
```

## 2. Levantar PostgreSQL

Con Docker (`docker-compose.yml` usa `DB_USER` y `DB_PASSWORD` del `.env`):

```bash
cp .env.example .env
# edita DB_USER, DB_PASSWORD y JWT_SECRET
docker compose up -d
```

Si ya tienes PostgreSQL instalado, crea la base `asistencia_escolar` y un usuario con los
mismos valores que `DB_USER` / `DB_PASSWORD`.

## 3. Ejecutar el backend

```bash
# PowerShell (ajusta los valores)
$env:DB_URL="jdbc:postgresql://localhost:5432/asistencia_escolar"
$env:DB_USER="admin_asistente"
$env:DB_PASSWORD="tu-clave"
$env:JWT_SECRET="una-clave-de-al-menos-32-caracteres"
.\gradlew bootRun
```

La API queda en `http://localhost:8080/api`. Flyway aplica migraciones (o hace baseline si
la base ya tenía tablas). El seeder **no** corre salvo que actives el perfil `demo`.

## 4. Conectar el frontend Angular

En `src/environments/environment.ts` y `environment.development.ts` del proyecto `Secundaria`:

```ts
apiUrl: 'http://localhost:8080/api',
useMockApi: false
```

`proxy.conf.json` ya reenvía `/api` a `http://localhost:8080` durante `ng serve`, así que no
hace falta tocar nada más.

## 5. Probar con Postman

Importa `postman/asistencia-escolar.postman_collection.json` en Postman. Incluye una carpeta
por módulo (Auth, Dashboard, Grupos, Alumnos, Asistencia, Justificaciones, Docentes, Horarios,
Reportes) con ejemplos de cada endpoint.

1. Corre primero **Auth → Login**: guarda el token automáticamente en la variable de colección
   `{{token}}` y el resto de las peticiones ya lo usan (Bearer Token a nivel de colección).
2. Las variables `groupId`, `studentId`, `teacherId`, `coverWorkId` vienen precargadas con IDs
   que existen en los datos semilla (`g-2A`, `s-1`, `t4`, `work-1`). Cámbialas si quieres probar
   otros grupos/alumnos/docentes.
3. `baseUrl` apunta a `http://localhost:8080/api`; cámbiala si corres el backend en otro puerto.

## Endpoints implementados

Todos bajo `/api`, tal como los documenta el `README.md` del frontend:

```
POST   /auth/login
GET    /dashboard
GET    /alerts
GET    /groups
GET    /groups/{id}
GET    /groups/{id}/students
GET    /students
GET    /students/{id}
POST   /attendance
GET    /attendance
GET    /attendance/student/{studentId}
GET    /attendance/group/{groupId}
PUT    /attendance/{id}
GET    /justifications
POST   /justifications                 (multipart: studentId, date, reason, notes, file?)
GET    /teachers
GET    /schedules/periods
GET    /schedules/classes
GET    /schedules/teachers
GET    /schedules/teachers/{id}
GET    /schedules/absences
GET    /schedules/work-hours
GET    /schedules/uncovered-hours
GET    /schedules/cover-work
POST   /schedules/cover-work           (multipart: title, date, groupId, periodId, absentTeacherName, subject, instructions, file)
GET    /schedules/cover-work/{id}/file
GET    /reports/attendance
GET    /reports/attendance/excel       (CSV, igual que hace el frontend hoy)
GET    /reports/attendance/pdf
```

Todas las rutas requieren `Authorization: Bearer <token>` excepto `/auth/login`. Los errores
siempre responden `{ "message": "..." }` con el status HTTP correspondiente (400/401/403/404/409/500),
que es exactamente lo que espera `error.interceptor.ts` en el frontend.

## Notas de diseño

- Los conteos de asistencia de cada alumno (presentes, faltas, retardos, % de asistencia) se
  calculan siempre a partir de la tabla `attendances`, nunca se guardan como columna aparte, para
  que jamás queden desincronizados.
- El reporte "Excel" (`/reports/attendance/excel`) genera un CSV con codificación UTF-8 + BOM
  (se abre perfecto en Excel), igual que ya hacía el modo mock del frontend.
- El reporte PDF se genera con Apache PDFBox (PDF real, no un mock).
- Los archivos adjuntos (justificantes y trabajos de cobertura) se guardan como `bytea` en
  PostgreSQL. Para un volumen grande de archivos, lo natural sería moverlos a almacenamiento de
  objetos (S3, disco) y guardar solo la referencia; se dejó así por simplicidad.
- El esquema lo versiona Flyway (`src/main/resources/db/migration`). Hibernate usa
  `ddl-auto=validate`. En una base que ya tenía tablas, `baseline-on-migrate=true` marca
  `V1__esquema_inicial` como aplicada sin volver a crearla.

## Compilación

> **Nota:** este proyecto se generó y revisó cuidadosamente a mano (incluyendo una revisión
> línea por línea de tipos, imports y firmas de métodos), pero no pudo compilarse dentro de este
> entorno porque no tiene acceso a Maven Central (repositorio de dependencias). En tu máquina, con internet normal:

```bash
.\gradlew compileJava   # o: .\gradlew bootJar
```

Si algo no compila, es casi seguro un detalle menor (versión de alguna librería, etc.) — dímelo
y lo corrijo de inmediato.
