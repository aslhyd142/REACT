-- Tabla proveedores

CREATE TABLE proveedores(

  id_proveedor INT NOT NULL AUTO_INCREMENT,
  nit INT NOT  NULL,
  razon_social  VARCHAR (50) INT NOT NULL,
  email VARCHAR (20) INT NOT NULL,
  telefono VARCHAR (20) INT NOT NULL,
  ciudad BOOLEAN NOT NULL DEFAULT TRUE,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
  CONSTRAINT uq_proveedor_nit UNIQUE (nit),
  CONSTRAINT uq_proveedor_email UNIQUE (email),
  CONSTRAINT uq_proveedor_telefono UNIQUE (telefono)
)ENGINE = InnoDB

-- productos_proveedor
ALTER TABLE productos ADD COLUMN id_proveedor INT NULL AFTER id_productos
--agregar foreing key
ALTER TABLE productos
ADD CONSTRAINT fk_productos_proveedores FOREIGN KEY (id_proveedor)
REFERENCES proveedores (id_proveedor)
ON DELETE SET NULL;

--Tabla direcciones envio
CREATE TABLE direcciones_envio (
id_direccion INT NOT NULL  AUTO_INCREMENT,
id_cliente INT NULL,
direccion VARCHAR(20) NOT NULL,
barrio VARCHAR(20) NOT NULL,
ciudad VARCHAR (20) NOT NULL,
es_principal BOOLEAN NOT NULL DEFAULT FALSE,
CONSTRAINT pk_direcciones_envio PRIMARY KEY (id_direccion),
CONSTRAINT fk_direcciones_cliente FOREIGN KEY (id_cliente)
REFERENCES clientes (id_cliente)
ON DELETE CASCADE

) ENGINE = INNODB

-- Restriccion productos
ALTER TABLE productos
ADD CONSTRAINT ck_productos_precio_max CHECK (precio =< 50000000)
;

--INDEX
CREATE INDEX  idx_clientes_ciudad ON clientes (ciudad);

--Tabla pruebas

CREATE TABLE tabla_prueba(
  id INT AUTO_INCREMENT PRIMARY KEY,
  detalle VARCHAR (20)
)
 RENAME TABLE tabla_prueba TO pruebas_old;

  DROP TABLE pruebas_old;

 
