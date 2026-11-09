/* el Dml nos permite manipular la base de datos en 4 acciones 
crear,consultar,modificar,eliminar
realizar cosultas con select con filtros orden y limites
joins (Ineer, left, reght, full emulado)
agregaciones count sum avs min max group by, having
subconsultas
insertar datos de prueba y verificar que existen 
DML= lenguaje de manipulacion de datos

*/ 

/* insertar datos de prueba (CRUD - C =Crear)
Si se insertan datos en una tabla se debe tener en cuenta el orden de los campos
el tipo de campos y la llave foranea
*/

INSERT INTO categorias (nombre, descripcion) 
VALUES ('tecnologia', 'computadores , perisfericos, accesorios');

INSERT INTO categorias (nombre, descripcion) 
VALUES ('Hogar', 'Electrodomesticos y articulos para el hogar');
('papeleria', 'utiles escolares y oficina');
('deportes', 'implementos deportivos');
('juguetes', 'categoria nueva, aun sin productos');


/* insertar datos en una tabla de relacion */
INSERT INTO  productos (id_categoria, nombre, precio, stock)
VALUES 
(1, 'portatil lenovo ideapad', 2500000, 15),
(1, 'teclado mecanico',180000,40),
(1, 'mouse inalambrico', 45000,120),
(1, 'monitor 24 pulgadas', 650000, 25),
(2, 'licuadora Oster', 220000,30),
(2, 'juego de ollas',310000,18),
(2, 'lampara led', 60000,75),
(3, 'cuaderno de 100 hojas',8500,500),
(3, 'resma de papel carta', 22000, 200),
(3, 'kit de marcadores', 15000, 150),
(4, 'balon de futbol', 85000,60),
(4, 'bicicleta estatica', 1200000,5);

/* insertar datos de clientes el ultimo no tiene telefono */

INSERT INTO clientes (tipo_documento, numero_documento, nombres, apellidos, email, telefono, ciudad)
VALUES ('CC', '1001001001', 'Ana Maria', 'Gomez Ruiz', 'ana.gomez@correo.com', '3001112233', 'Medellin'),
('CC', '1002002002', 'Carlos Andres', 'Perez Diaz', 'carlos.perez@correo.com', '3002223344', 'Bogota'),
('CC', '1003003003', 'Luisa Fernanda', 'Martinez Rios', 'luisa.martinez@correo.com', '30023334455', 'Cali'),
('TI', '1004004004', 'Juan David', 'Restrepo Toro', 'juan.restrepo@correo.com', '30034445566', 'Medellin'),
('CE', '1005005005', 'Valentina', 'Herrera Lopez', 'valentina.herrera@correo.com', '30045556677', 'Barranquilla'),
('CC', '1006006006', 'Santiago', 'Ramirez Castro', 'santiago.ramirez@correo.com', '30056667788', 'Bogota'),
('CC', '1007007007', 'Daniela', 'Ospina Vargas', 'daniela.ospina@correo.com', '30067778899', 'Medellin'),
('CC', '1008008008', 'Mateo', 'Londoño Giraldo', 'mateo.londoño@correo.com', 'null', 'Pereira');

/* Pedidos vamos a relizar pedidos con 2 relaciones con cliente */

INSERT INTO pedidos (id_cliente, fecha_pedido, estado, total)
VALUES 
(1, '2026-08-01 10:15:00', 'Pagado'),
(2, '2026-08-03 14:30:00', 'Enviado'),
(1, '2026-08-10 09:00:00', 'Enviado'),
(3,'2026-08-15 16:45:00', 'Pagado'),
(4,'2026-08-20 11:20:00', 'Cancelado'), 
(5,'2026-09-02 8:10:00', 'Pendiente'),
(6,'2026-09-05 19:00:00', 'Pagado'),
(2,'2026-09-12 12:00:00', 'Pagado'),
(7,'2026-09-20 17:30:00', 'Enviado'),
(3,'2026-09-28 10:05:00', 'Pendiente');
/* ajuste tabla pedidos*/

ALTER TABLE pedidos MODIFY COLUMN total DECIMAL (12,2) NOT NULL
DEFAULT 0;
ALTER TABLE pedidos DROP CONSTRAINT IF EXISTS ck_pedidos_total;

ALTER TABLE pedidos ADD CONSTRAINT ck_pedidos_total CHECK (total >=0);

/* Detalle de pedidos se maneja con 2 relaciones con productos y pedidos*/
INSERT INTO detalle_pedido (id_pedido, id_productos, cantidad, precio_unitario)
VALUES
(1, 1, 1, 2500000), (1, 2, 2, 45000),
(2, 4, 2, 650000), (2, 3, 1, 45000),
(3, 8, 10, 8500), (3, 9, 2, 45000),
(4, 5, 1, 220000), (4, 7, 2, 60000),
(5, 11, 1, 85000),
(6, 6, 1, 3100000), (6, 2, 2, 45008),
(7, 1, 1, 2500000), (7, 4, 1, 650000), (7, 2, 1, 45000),
(8, 10, 5, 15000), (8, 8, 20, 8500),
(9, 3, 2, 180000), (9, 7, 1, 60000),
(10, 11, 2, 2580000), (10, 9, 3, 22000),

/* Trabajo con los datos de una base de datos */
/* Calcular el total de cada pedido con un UPDATE + consultas correlacionada 
para cada pedido "p" suma cantidad * precio detalles
*/  

UPDATE pedidos p
SET p.total=(SELECT sum(d.cantidad * d.precio_unitario )
FROM detalle_pedidos d
WHERE d.id_pedidos = p.id_pedido);

 SELECT id_pedido,id_cliente, estado, total  FROM pedidos;

 /* Consultas basicas read de una base de datos 
 1. columnas especificas con alias AS para nombrarlas mejor
  */
SELECT nombre AS producto, precio AS precio_venta, stock AS unidades FROM productos;

/* where con operadores de comparacion y logicos AND OR NOT */
SELECT nombre, precio, stock
FROM productos
WHERE precio >100000 AND stock >= 20;
-- BETWEEN (rango,incluye los extremos)
SELECT nombre, precio FROM productos
WHERE precio BETWEEN 20000 AND 200000;


/*  3. CONSULTAS BÁSICAS (la "R" de CRUD: Read)*/

-- 3.1 Columnas específicas con ALIAS (AS) para nombrarlas mejor
SELECT nombres AS producto, precio AS precio_venta, stock AS unidades
FROM productos;

-- 3.2 WHERE con operadores de comparación y lógicos (AND / OR / NOT)
SELECT nombres, precio, stock
FROM productos
WHERE precio > 100000 AND stock >= 20;

-- 3.3 BETWEEN (rango, incluye los extremos)
    SELECT nombres, precio FROM productos
    WHERE precio BETWEEN 20000 AND 200000;

-- 3.4 IN (lista de valores)
SELECT nombres, apellidos, ciudad FROM clientes
WHERE ciudad IN ('Medellín', 'Bogotá');

-- 3.5 LIKE: % = cualquier cantidad de caracteres, _ = exactamente un carácter
SELECT nombres, apellidos, email FROM clientes
WHERE apellidos LIKE 'R%'; -- apellidos que empiezan por R

-- 3.6 IS NULL / IS NOT NULL (¡NULL no se compara con =!)
SELECT nombres, apellidos FROM clientes
WHERE telefono IS NULL;

-- 3.7 ORDER BY (ASC ascendente por defecto, DESC descendente) y LIMIT
SELECT nombres, precio FROM productos
ORDER BY precio DESC
LIMIT 3; -- los 3 productos más caros

-- 3.8 DISTINCT: valores sin repetir
SELECT DISTINCT ciudad FROM clientes ORDER BY ciudad;

-- 3.9 Columnas calculadas y funciones de texto
SELECT CONCAT(nombres, ' ', apellidos) AS cliente_completo,
       UPPER(ciudad) AS ciudad_mayuscula,
       CHAR_LENGTH(email) AS largo_email
FROM clientes;

-- 3.10 CASE: lógica condicional dentro de la consulta
SELECT nombres, stock,
    CASE
        WHEN stock < 20 THEN 'Stock bajo'
        WHEN stock < 100 THEN 'Stock medio'
        ELSE 'Stock alto'
    END AS nivel_stock
FROM productos;

/* 4. JOINs - CONSULTAR VARIAS TABLAS RELACIONADAS
   INNER JOIN -> solo las filas que tienen pareja en ambas tablas
   LEFT JOIN -> todas las de la izquierda + las parejas (o NULL)
    RIGHT JOIN -> todas las de la derecha + las parejas (o NULL)
    FULL JOIN -> todas las de ambas (MySQL no lo tiene: se emula con UNION)
Se usan alias cortos (p, c...) para no repetir el nombres de la tabla.*/

-- 4.1 INNER JOIN: productos con el nombres de su categoría
SELECT p.nombres AS producto, c.nombres AS categoria, p.precio
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
ORDER BY c.nombres, p.nombres;

-- 4.2 INNER JOIN: pedidos con el nombres del cliente
SELECT pe.id_pedido, pe.fecha_pedido, pe.estado, pe.total,
       CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente
FROM pedidos pe
INNER JOIN clientes cl ON cl.id_cliente = pe.id_cliente
ORDER BY pe.fecha_pedido;

-- 4.3 JOIN de 4 tablas: la "factura" detallada de cada pedido
SELECT pe.id_pedido,
       CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente,
       pr.nombres AS producto,
       d.cantidad,
       d.precio_unitario,
       d.cantidad * d.precio_unitario AS subtotal
FROM pedidos pe
INNER JOIN clientes cl ON cl.id_cliente = pe.id_cliente
INNER JOIN detalle_pedidos d ON d.id_pedido = pe.id_pedido
INNER JOIN productos pr ON pr.id_producto = d.id_producto
ORDER BY pe.id_pedido, pr.nombres;

-- 4.4 LEFT JOIN: TODOS los clientes, tengan o no pedidos
SELECT cl.nombres, cl.apellidos, pe.id_pedido, pe.total
FROM clientes cl
LEFT JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
ORDER BY cl.id_cliente;

-- 4.5 LEFT JOIN + IS NULL: clientes que NUNCA han comprado
SELECT cl.nombres, cl.apellidos, cl.ciudad_residencia
FROM clientes cl
LEFT JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
WHERE pe.id_pedido IS NULL; -- Resultado esperado: Mateo

-- 4.6 LEFT JOIN + IS NULL: productos que nunca se han vendido
SELECT pr.nombres, pr.stock
FROM productos pr
LEFT JOIN detalle_pedidos d ON d.id_producto = pr.id_producto
WHERE d.id_detalle IS NULL; -- Resultado esperado: Bicicleta estática

-- 4.7 RIGHT JOIN: todas las categorías aunque no tengan productos
SELECT c.nombres AS categoria, p.nombres AS producto
FROM productos p
RIGHT JOIN categorias c ON c.id_categoria = p.id_categoria
ORDER BY c.nombres; -- Juguetes aparece con producto NULL

-- 4.8 FULL OUTER JOIN emulado (LEFT JOIN UNION RIGHT JOIN)
SELECT c.nombres AS categoria, p.nombres AS producto
FROM categorias c LEFT JOIN productos p ON p.id_categoria = c.id_categoria
UNION
SELECT c.nombres, p.nombres
FROM categorias c RIGHT JOIN productos p ON p.id_categoria = c.id_categoria;

/*  5. FUNCIONES DE AGREGACIÓN, GROUP BY y HAVING
   COUNT, SUM, AVG, MIN, MAX resumen muchas filas en un solo valor.
   GROUP BY -> agrupa las filas para calcular el resumen por grupo.
   HAVING -> filtra GRUPOS (WHERE filtra filas ANTES de agrupar).
   Regla: toda columna del SELECT que no esté en una función de
   agregación debe ir en el GROUP BY. */

-- 5.1 Resumen general de productos
SELECT COUNT(*) AS total_productos,
       SUM(stock) AS unidades_en_bodega,
       ROUND(AVG(precio), 2) AS precio_promedio,
       MIN(precio) AS precio_minimo,
       MAX(precio) AS precio_maximo
FROM productos;

-- 5.2 Cantidad de productos y valor del inventario por categoría
SELECT c.nombres AS categoria,
       COUNT(p.id_producto) AS cantidad_productos,
       SUM(p.precio * p.stock) AS valor_inventario
FROM categorias c
LEFT JOIN productos p ON p.id_categoria = c.id_categoria
GROUP BY c.nombres
ORDER BY valor_inventario DESC;

-- 5.3 Total comprado por cliente (sin pedidos cancelados)
SELECT CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente,
       COUNT(pe.id_pedido) AS numero_pedidos,
       SUM(pe.total) AS total_comprado
FROM clientes cl
INNER JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
WHERE pe.estado <> 'CANCELADO' 
GROUP BY cl.id_cliente, cl.nombres, cl.apellidos
ORDER BY total_comprado DESC;

-- 5.4 HAVING: clientes que han comprado más de 1.000.000
SELECT CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente,
       SUM(pe.total) AS total_comprado
FROM clientes cl
INNER JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
WHERE pe.estado <> 'CANCELADO'
GROUP BY cl.id_cliente, cl.nombres, cl.apellidos
HAVING SUM(pe.total) > 1000000; -- HAVING: filtra los grupos

-- 5.5 Ventas por mes
SELECT DATE_FORMAT(fecha_pedido, '%Y-%m') AS mes,
       COUNT(*) AS pedidos,
       SUM(total) AS ventas
FROM pedidos
WHERE estado <> 'CANCELADO'
GROUP BY DATE_FORMAT(fecha_pedido, '%Y-%m')
ORDER BY mes;

-- 5.6 Unidades vendidas por producto
SELECT pr.nombres, SUM(d.cantidad) AS unidades_vendidas
FROM detalle_pedidos d
INNER JOIN productos pr ON pr.id_producto = d.id_producto
INNER JOIN pedidos pe ON pe.id_pedido = d.id_pedido
WHERE pe.estado <> 'CANCELADO'
GROUP BY pr.id_producto, pr.nombres
ORDER BY unidades_vendidas DESC;

-- 5.7 Pedidos por estado
SELECT estado, COUNT(*) AS cantidad, SUM(total) AS valor
FROM pedidos
GROUP BY estado;

/* subconsultas una cosulta dentro de la otra */
/* subconsulta en where (valor unico) productos mas caros que el promedio*/
SELECT nombre,precio
FROM productos
WHERE precio > (SELECT AVG (precio)FROM productos);
-- subconsultas con IN (lista) clientes que han hecho al menos un pedido 
SELECT nombres, apellidos
FROM clientes
WHERE id_cliente IN(SELECT id_cliente FROM pedidos);
--NOT EXISTS: categorias que no tienen productos
SELECT c.nombre
FROM categorias c 
WHERE NOT EXISTS (SELECT 1 FROM productos p WHERE p.id_categoria = c.id_categoria);
--Subconsultas escalar en el select : numero de pedidos cada cliente
SELECT cl.nombres, cl.apellidos,
(SELECT COUNT(*)FROM pedidos pe WHERE pe.id_cliente = cl.id_cliente)AS cantidad_pedidos FROM clientes cl;
--subconsulta en FROM (tabla derivado)promedio de compra por cliente 
SELECT ROUND (AVG(t.total_cliente),2)
AS promedio_compra_por_cliente
FROM (SELECT id_cliente, SUM(total) AS total_cliente
FROM pedidos 
WHERE estado <> 'CANCELADO'
GROUP BY id_cliente) AS t;
-- En mysql una tabla derivada necesita un alias en este caso "t" y
--no se puede usar el alias en la misma consulta, por eso se hace una subconsulta en from

--subconsulta correlacionado productos mas caros que el promedio de su categoria

SELECT p.nombre, p.precio, p.id_categoria
FROM productos p
WHERE p.precio>(SELECT AVG(p2.precio)
FROM productos p2
WHERE p2.id_categoria = p.id_categoria)

--subconsulta el pedido de mayor valor con MAX
SELECT id_pedido, id_cliente,total
FROM pedidos
WHERE total = (SELECT MAX (total)FROM pedidos);


/* CRUD COMPLETO + TRANSACCIONES
 Una transaccion agrupa varias sentencias en una sola
unidad o se guardan TODAS en un commit o no se guarda
ninguna ROLLBACK
 propiedades: ACID: Atomicidad, Consistencia,
Aislamineto, Durabilidad */

-- C = create registrar un cliente nuevo
INSERT INTO clientes (tipo_documento,
numero_documeto, nombres, apellidos, email, telefono,
ciudad)
VALUES ('CC', '1009009009', 'Sofia', 'Cardona Mejia',
'sofia.cardona@correo.com', '3109990000', 'Manizales');
-- R = Read consultarlo
SELECT * FROM clientes WHERE numero_documento = 
'1009009009';
-- U = UPDATE modificar un cliente existente
UPDATE clientes
SET telefono = '3201234567',
ciudad = 'Armenia'
WHERE numero_documento = '1009009009';

SELECT * FROM clientes WHERE numero_documento = '1009009009';
--DELETE Eliminar siempre con WHERE por que sin WHERE elimina toda la tabla 
DELETE FROM Clientes WHERE numero_documento = '1009009009';

--transacciones: con rolback simulados una venta y nos arrepentimos de la venta y nos arrepentimos de la venta y no se guarda nada en la base de datos
START TRANSACTION;
INSERT INTO pedidos (id_cliente, estado) VALUES (8,'PENDIENTE');
SET @nuevo_pedido_id = LAST_INSERT_ID(); -- ID generado por el ultimo INSERT
INSERT INTO detalle_pedidos (id_pedidos, id_productos, cantidad, precio_unitario)
VALUES (@nuevo_pedido_id, 12, 1, 1200000);

UPDATE productos SET stock = stock -1 WHERE id_producto = 12;

SELECT * FROM pedidos WHERE id_pedido = @nuevo_pedido_id;
--dentro de la transaccion se puede consultar lo que se ha hecho pero no se ve desde afuera 
ROLLBACK ; -- deshaceer la transaccion y no se guarda nada en la base de datos

SELECT * FROM pedidos WHERE id_pedido = @nuevo_pedido_id,

--ya no existe

SELECT stock FROM productos WHERE id_producto =12;

--el stock debe seguir en 5

START TRANSACTION
UPDATE productos
SET precio = ROUND(precio*1.05,0)
WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nombre = 'Deportes');
COMMIT;
--confirma el cambio de forma permanente 
SELECT nombre, precio FROM productos WHERE id_categoria = 4;
--DELETE en cascada: al borrar un pedido se borran sus detalles
INSERT INTO pedidos (id_cliente, estado)
VALUES (8, 'Pendiente');
SET @pedidoo_tem = LAST_INSERT_ID();
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (@pedido_tem, 2, 1, 45000);

SELECT COUNT (*) AS detalles_antes FROM detalle_pedido
WHERE id_pedido = @pedido_tem; -1
DELETE FROM pedidos WHERE id_pedido = @pedido_tem;
SELECT COUNT(*) AS detalle_despues FROM detalle_pedido WHERE id_pedido = @pedido_tem; --0