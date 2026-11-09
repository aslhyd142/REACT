/* 
DDL = lenguaje de definicion de datos son los datos que nos permiten crear, modificar, eliminar y consultar
la estructura de la base de datos no los datos que se registren en ella
- create crear base de datos
- alter modificar la estructura de las tablas de las bases de datos 
- drop eliminar base de datos o tablas 
- truncate vacia una tabla de base de datos y reinicia el contador de autoincremento 
- rename cambiar el nombre de una tabla
*/









-- Eliminar base de datos si existe con todo su contenido
DROP DATABASE IF EXISTS tienda_adso;

-- Crear base de datos
CREATE DATABASE tienda_adso 
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Utilizar la base de datos creada
USE tienda_adso;

-- Crear base de datos
CREATE TABLE categorias (
  id_categoria INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR (50) NOT NULL,
    descripcion VARCHAR (255) NULL,
    CONSTRAINT pk_categorias  PRIMARY KEY  (id_categoria),
 	CONSTRAINT uq_categorias_nombre UNIQUE (nombre)
    ) ENGINE= InnoDB;

-- Tabla productos
  id_productos INT NOT NULL AUTO_INCREMENT,
    id_categoria INT NOT NULL, 
    nombre VARCHAR (100) NOT NULL,
    precio DECIMAL (12,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_productos PRIMARY KEY (id_productos), 
    CONSTRAINT ck_productos_precio CHECK (precio > 0),
    CONSTRAINT ck_productos_stock CHECK (stock >= 0),
    
    CONSTRAINT fk_productos_categorias FOREIGN KEY (id_categoria)
    REFERENCES categorias (id_categoria)
	ON DELETE RESTRICT
    ON UPDATE CASCADE
    ) ENGINE = INNODB; 

-- Tabla cliente

CREATE TABLE cliente (
    id_cliente INT NOT NULL AUTO_INCREMENT,
    tipo_documento  VARCHAR(3) NOT NULL DEFAULT 'CC',
    numero_documento VARCHAR (10) NOT NULL ,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    telefono VARCHAR (10) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
    CONSTRAINT uq_clientes_documento UNIQUE (numero_documento),
    CONSTRAINT uq_clientes_email UNIQUE (email),
    -- Campos disponibles para tipo documento
    CONSTRAINT ck_clientes_tipo_documento CHECK (tipo_documento IN ('CC','TI','CE','PASS'))
    ) ENGINE = INNODB; 
  
  --tabla pedido
  CREATE TABLE pedidos (
    id_pedido INT NOT NULL AUTO_INCREMENT,
 id_cliente INT NOT NULL,
    fecha_pedido DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
     estado VARCHAR (20) NOT NULL DEFAULT 'Pendiente',
  totaL VARCHAR(60) NOT NULL DEFAULT 0,
     CONSTRAINT pk_pedidos PRIMARY KEY (id_pedido),
    CONSTRAINT ck_pedidos_estado CHECK (estado IN ('Pendiente','Pagado','Enviado','Cancelado')),
     CONSTRAINT ck_pedidos_total CHECK (total > 0),
   CONSTRAINT fk_pedidos_clientes FOREIGN KEY (id_cliente)
      REFERENCES clientes (id_cliente)
      ON DELETE RESTRICT
      ON UPDATE CASCADE
)ENGINE = InnoDB;

-- Tabla detalle_pedido
CREATE TABLE detalle_pedidos(
    id_detalle_pedidos INT NOT NULL AUTO_INCREMENT,
    id_pedidos INT NOT NULL, 
    id_productos INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 0,
    precio_unitario DECIMAL (12,2) NOT NULL,
     CONSTRAINT pk_detalle_pedidos PRIMARY KEY (id_detalle_pedidos),
    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio_producto CHECK (precio_unitario > 0),
   	CONSTRAINT uq_detalles_productos UNIQUE (id_pedidos, id_productos),
    CONSTRAINT fk_detalles_pedidos FOREIGN KEY (id_pedidos)
    REFERENCES pedidos (id_pedido)
    ON DELETE CASCADE,
    CONSTRAINT fk_detalles_productos FOREIGN KEY (id_productos)
    REFERENCES productos (id_productos)
    ON DELETE RESTRICT
    ) ENGINE = INNODB ;

  -- Tabla user
  CREATE TABLE usuarios (
    id_usuario INT NOT NULL AUTO_INCREMENT,
    id_cliente INT NULL, 
    nombre_usuario VARCHAR (50), 
    email VARCHAR (50),
    password_hash CHAR (64) NOT NULL,
    -- cambia la encriptacion para que no quede la misma
    salt CHAR (32) NOT NULL,
    rol VARCHAR (20) NOT NULL DEFAULT 'CLIENTE',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    intentos_fallidos INT NOT NULL DEFAULT 0,
    bloqueado BOOLEAN NOT NULL DEFAULT FALSE,
    ultimo_acceso DATETIME NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuarios PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuarios_nombre UNIQUE (nombre_usuario),
    CONSTRAINT uq_usuarios_email UNIQUE (email),
    CONSTRAINT ck_usuarios_rol CHECK (rol IN ('ADMIN', 'VENDEDOR', 'CLIENTE')),
    CONSTRAINT fk_usuarios_clientes FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente)
  -- se puede eliminar un cliente
    ON DELETE SET NULL
    ) ENGINE = INNODB

    --MIRAR LAS TABLAS DE UNA BASE DE DATOS
    SHOW TABLES;
    -- DESCRIBE LA TABLA
    DESCRIBE productos;
    --codigo para ver el sricpt de la creacionde la tabla
    SHOW CREATE TABLE pedidos;

  -- Crear diccionario de datos
  SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'tienda_adso'
ORDER BY table_name, constraint_type;

-- agregar una columna a una tabla existente 
ALTER TABLE clientes ADD COLUMN fecha_nacimiento DATE NULL AFTER ciudad, apellidos;

-- cambiar el tipo / tamanio de una columna
ALTER TABLE clientes MODIFY COLUMN telefono VARCHAR (50) NULL;

-- renombrar una columna CHANGE COLUMN pide nombre viejo, nuevo nombre
-- y la definicion de la columna completa 
ALTER TABLE clientes
CHANGE COLUMN ciudad ciudad_residenca VARCHAR (50) NOT NULL;

-- la devolvemos a la tabla original

ALTER TABLE clientes  CHANGE COLUMN ciudad_residenca ciudad VARCHAR (50) NOT NULL;

-- Eliminar una columna de una tabla
ALTER TABLE clientes DROP COLUMN fecha_nacimiento; 

-- Agregrar una descripcion a una tabla existente 

ALTER TABLE productos
ADD CONSTRAINT uq_productos_nombre UNIQUE (nombre);

-- Eliminar una restriccion de una tabla existente
ALTER TABLE productos 
DROP INDEX uq_productos_nombre;

-- crear indices para busquedas mas rapidas 
CREATE INDEX  idx_productos_nombre ON productos (nombre);
CREATE INDEX idx_pedidos_fecha ON pedidos (fecha_pedido);
CREATE INDEX idx_clientes_apellidos ON clientes (apellidos, nombres);
-- indice compuesto por dos columnas 

SHOW INDEX FROM productos; 


--  crear una tabla llamada tabla_practica campos id y detalle

CREATE TABLE tabla_practica (
  id INT AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR (50)
);
 
 -- Insertar datos en la tabla practica
 INSERT INTO tabla_practica (detalle) VALUES ('fila 1'), ('fila 2');

 -- borrar todas las filas de golpe y reinicia el auto increment 
 TRUNCATE TABLE tabla_practica;

 --Cambiar el nombre de una tabla 
 RENAME TABLE tabla_practica TO tabla_borrador;

 -- eliminar tabla
 DROP TABLE tabla_borrar;




 
