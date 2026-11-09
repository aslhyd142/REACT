



--1. Inserte 3 proveedores y asígnelos con UPDATE: proveedor 1 a los productos de Tecnología, proveedor 2 a Hogar y proveedor 3 a Papelería.

SELECT*FROM productos;
SELECT*FROM proveedores 



INSERT INTO proveedores (nit, razon_social, email, telefono, ciudad,activo)
VALUES
('1001001-1', 'Parque tecnologico SAS', 'contacto@parquetecnologico.com', '3001001001', 'Bogota', 1),
('2002002-2', 'Hogar feliz SAS', 'ventas@hogarfeliz.com', '3002002002', 'Siberia', 1),
('3003003-3', 'Puerto Papel SAS', 'info@puertopapel.com', '3003003003', 'Bogota', 1);

UPDATE Productos
SET id_proveedor = 1
WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nombre= 'Tecnologia');
UPDATE Productos
SET id_proveedor = 2
WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nombre= 'Hogar');
UPDATE Productos
SET id_proveedor = 3
WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nombre= 'Papeleria');

2. Liste TODOS los productos con su categoría y el nombre de su proveedor (los que no tienen proveedor deben aparecer igual).
SELECT p.nombre AS productos,c.nombre AS categoria,pr.razon_social AS proveedores
FROM productos p
LEFT JOIN categorias c ON p.id_categoria = c.id_categoria
LEFT JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor;
3. Muestre el total vendido por ciudad del cliente (sin cancelados), ordenado de mayor a menor.
SELECT
    c.ciudad,
    SUM(dp.cantidad * dp.precio_unitario) AS total_vendido, estado AS estado
FROM pedidos p
INNER JOIN clientes c
    ON p.id_cliente = c.id_cliente
INNER JOIN detalle_pedidos dp
    ON p.id_pedido = dp.id_pedidos
WHERE p.estado <> 'CANCELADO'
GROUP BY c.ciudad
ORDER BY total_vendido DESC;
4. ¿Cuál es el producto con más unidades vendidas? (use LIMIT)
SELECT 
  p.nombre,
  SUM(dp.cantidad) AS unidades_vendidas
FROM productos p
JOIN detalle_pedidos dp ON p.id_productos = dp.id_productos
GROUP BY p.id_productos, p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 1;
5. Liste los clientes cuyo total comprado es mayor al promedio de compra por cliente (use subconsulta en el HAVING).
SELECT 
    CONCAT(cl.nombres, ' ', cl.apellidos) AS cliente,
    SUM(pe.total) AS total_comprado
FROM clientes cl
INNER JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
WHERE pe.estado <> 'Cancelado'
GROUP BY cl.id_cliente, cl.nombres, cl.apellidos
HAVING total_comprado > (
    SELECT ROUND(AVG(t.total_cliente), 2)
    FROM (
        SELECT id_cliente, SUM(total) AS total_cliente
        FROM pedidos
        WHERE estado <> 'Cancelado'
        GROUP BY id_cliente
    ) AS t
);
6. Liste las categorías de las que NO se ha vendido ningún producto
SELECT p.nombre AS producto,
 c.nombre AS categoria,
 'NO VENDIDO' AS estado
FROM productos p
INNER JOIN categorias c
 ON p.id_categoria = c.id_categoria
WHERE NOT EXISTS (
 SELECT 1
 FROM detalle_pedidos d
 INNER JOIN pedidos pe
 ON pe.id_pedido = d.id_pedidos
 WHERE d.id_productos = p.id_productos
 AND pe.estado <> 'CANCELADO'
);
7. Dentro de una transacción suba 10% el precio de los productos de Papelería, consulte el resultado y deshaga el cambio con ROLLBACK.
START TRANSACTION;
UPDATE productos SET precio = precio * 1.10 WHERE id_categoria = (SELECT id_categoria FROM categorias WHERE nombre = 'Papelería');
SELECT p.nombre AS producto, p.precio AS precio_actualizado FROM productos p JOIN categorias c ON c.id_categoria = p.id_categoria 
WHERE c.nombre = 'Papelería';
ROLLBACK;
8. Elimine los pedidos CANCELADOS y verifique que su detalle también se eliminó (ON DELETE CASCADE).
SELECT p.id_pedido, pr.nombre AS producto, p.estado 
FROM pedidos p 
JOIN detalle_pedidos d ON d.id_pedidos = p.id_pedido
JOIN productos pr ON pr.id_productos = d.id_productos 
WHERE p.estado = 'CANCELADO';
DELETE FROM pedidos WHERE estado = 'CANCELADO';
SELECT * FROM pedidos WHERE estado = 'CANCELADO';
SELECT COUNT(*) FROM detalle_pedidos