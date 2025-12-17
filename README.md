# Backend - API de To-Do List

## Instalar:

Necesitas tener instalado:
- Node.js (versión 18 o superior)
- MySQL (versión 8.0 o superior)
- npm (viene con Node.js)

## Configuración:

### Paso 1: Crear la Base de Datos

Primero lo primero: necesitamos una base de datos MySQL. Prisma genera el resto.

Abrir terminal de MySQL:

```bash
mysql -u root -p
```

Y ejecuta estos comandos (cambiar el nombre de usuario y contraseña opcional):

```sql
CREATE DATABASE test_db;
CREATE USER 'test_user'@'localhost' IDENTIFIED BY 'tu_contraseña';
GRANT ALL PRIVILEGES ON test_db.* TO 'test_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Paso 2: Instalar las dependencias del proyecto:

```bash
npm install
```

### Paso 3: Configurar la Conexión a la Base de Datos

Crea un archivo `.env` en la raíz del proyecto backend con esta configuración:

```env
# Conexión a la base de datos
DATABASE_URL="mysql://test_user:tu_contraseña@localhost:3306/test_db"

# Clave secreta para JWT
JWT_SECRET="clave_secreta_jwt"

# Cuánto tiempo dura la sesión
JWT_EXPIRES_IN="7d"

# Puerto donde levanta el servidor
PORT=3000
```

### Paso 4: Ejecutar Prisma para crear las tablas


```bash
# Esto genera el cliente de Prisma
npx prisma generate

# Y esto crea las tablas en tu base de datos
npx prisma migrate dev --name init
```

### Paso 5: Levantar el proyecto


```bash
npm run start:dev
```

Aparece algo como:

```
[Nest] INFO [Bootstrap] Application is running on: http://localhost:3000
[Nest] INFO [Bootstrap] Environment: development
[Nest] INFO [PrismaService] Database connection established
```

El backend está corriendo en `http://localhost:3000`
