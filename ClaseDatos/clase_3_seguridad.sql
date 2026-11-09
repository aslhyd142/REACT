/* clase 3 seguridad en base de datos
objetivo: evidenciar que las contraseñas esten ENCRIPTADAS (HASH y SALT )  y aplicar practicas de seguridad sobre los datos
1. hash vs cifrado teoria 
2. Contraseñas con HASH + SALT (SHA2)
3. Procedimiento para registrar usuarios, hacer login y cambiar clave.
4. Cifrado reversible para datos sensibles (AES)
5. Auditorias con TRIGGER
6. Vistas que ocultan datos sensibles 
7. Usuarios y roles de MYSQL con minimo privilegio (GRANT / REVOKE)
8. Prevencion de sql Injeccion con consultas preparadas
*/

/* 1- HASH vs CIFRADO para contraseñas
- Convierte un texto en una huella de longitud fija
- No se puede revertir, para validar el login se calcula
el hash de la clave escrita y se compara con el guardado
- Salt texto aleatorio distinto para cada usuario que
se mezcla con la clave antes del hash así dos usuarios
con la misma clave tienen hashes diferentes y se frustra
la redundancia en las tablas

- cifrado (dos vias) Para datos sensibles que hay que
volver a leer
-con una llave se cifra y con la misma llave se descifra

* nunca guarda contraseñas en segundo plano*/
-- Demostracion del texto siempre da el mismo hash
SELECT SHA2('Clave123*', 256) AS hash_1;
SELECT SHA2('Clave123*', 256) AS hash_2;

-- Demostracion utilizando SALT misma clave salt distinto = hash distinto
SELECT SHA2(CONCAT('a1b2c3', 'Clave123*'), 256) AS hash_usuario_A;
SELECT SHA2(CONCAT('a9y8z7', 'Clave123*'), 256) AS hash_usuario_B;
--Generar un slat aleatorio de 32 caracteres hexadecimal
-- Mezclamos UUID (Identificador unico) + RAND() (numero al azar ) + la hora con milisegundos y
-- tomamos los 32 caracteres del resultado
-- En mysql 8 existe, HEX(RANDOM_BYTES(16)) mas robusto pero mariadb no lo tiene
SELECT LEFT(SHA2(CONCAT(UUID(), RAND(), NOW(6)), 256), 32) AS salt_aleatorio;
/*2 LO QUE NUNCA SE DEBE HACER CON CONTRASEÑAS (solo para mostrar el riesgo)
Si alguien roba la base de datos o un empleado curioso consulta la tabla veria las claves de todos
INSERT INTO usuarios (...) VALUES (..., 'Miclave123, ...); -- ¡MAL!
*/
/* 3. Procedimientos almacenados de autenticacion
- Centralizamos la logica de seguridad en 
procedimientos la aplicacion nunca toca directamente 
el hash solo llama a estos procedimientos
DELIMITER cambia el fin de la sentencia a // para poder 
usar ; dentro del procedimiento
*/
DROP PROCEDURE IF EXISTS sp_registrar_usuario;
DROP PROCEDURE IF EXISTS sp_login_usuario;
DROP PROCEDURE IF EXISTS sp_cambiar_password;

DELIMITER //

CREATE PROCEDURE sp_registrar_usuario(
    IN p_nombre_usuario VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(100),
    IN p_rol VARCHAR(20),
    IN p_id_cliente INT
)
BEGIN
    DECLARE v_salt CHAR(32);

    -- Validar la contraseña
    IF CHAR_LENGTH(p_password) < 8
       OR CAST(p_password AS BINARY) =
          CAST(LOWER(p_password) AS BINARY)
       OR p_password NOT REGEXP '[0-9]' THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'La contraseña debe tener mínimo 8 caracteres, una mayúscula y un número';
    END IF;

    -- Generar salt
    SET v_salt = LEFT(
        SHA2(CONCAT(UUID(), RAND(), NOW(6)), 256),
        32
    );

    -- Registrar usuario
    INSERT INTO usuarios (
        id_cliente,
        nombre_usuario,
        email,
        password_hash,
        salt,
        rol
    )
    VALUES (
        p_id_cliente,
        p_nombre_usuario,
        p_email,
        SHA2(CONCAT(v_salt, p_password), 256),
        v_salt,
        p_rol
    );

END //

DELIMITER ;
-- 3.2 login compara hashes cuenta intentos fallidos y bloquea el 3 intento

DELIMITER //

CREATE PROCEDURE sp_login(
    IN p_nombre_usuario VARCHAR(50),
    IN p_password VARCHAR(100),
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE v_id INT DEFAULT NULL;
    DECLARE v_hash CHAR(64);
    DECLARE v_salt CHAR(32);
    DECLARE v_bloqueado BOOLEAN DEFAULT FALSE;
    DECLARE v_intentos INT DEFAULT 0;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_id = NULL;

    SELECT id_usuario, password_hash, salt,
           bloqueado, intentos_fallidos
    INTO v_id, v_hash, v_salt,
         v_bloqueado, v_intentos
    FROM usuarios
    WHERE nombre_usuario = p_nombre_usuario
      AND activo = TRUE
    LIMIT 1;

    IF v_id IS NULL THEN

        SET p_resultado =
            'Usuario o contraseña incorrectos';

    ELSEIF v_bloqueado THEN

        SET p_resultado =
            'Usuario bloqueado. Contacte al administrador';

    ELSEIF v_hash = SHA2(
        CONCAT(v_salt, p_password), 256
    ) THEN

        UPDATE usuarios
        SET intentos_fallidos = 0,
            ultimo_acceso = NOW()
        WHERE id_usuario = v_id;

        SET p_resultado = 'Acceso concedido';

    ELSE

        UPDATE usuarios
        SET intentos_fallidos = v_intentos + 1,
            bloqueado = IF(v_intentos + 1 >= 5, TRUE, FALSE)
        WHERE id_usuario = v_id;

        SET p_resultado =
            'Usuario o contraseña incorrectos';

    END IF;

END //

DELIMITER ;

-- 3.3 Cambiar contraseña:exige la clave actual y genera salt nuevo
DELIMITER //

CREATE PROCEDURE sp_cambiar_password(
    IN p_nombre_usuario VARCHAR(50),
    IN p_password_actual VARCHAR(100),
    IN p_password_nueva VARCHAR(100),
    OUT p_resultado VARCHAR(100)
)
BEGIN
    DECLARE v_salt_nuevo CHAR(32);

    IF NOT EXISTS (
        SELECT 1 FROM usuarios
        WHERE nombre_usuario = p_nombre_usuario
        AND password_hash = SHA2(CONCAT(salt, p_password_actual), 256)
    ) THEN
        SET p_resultado = 'la contraseña actual no es correcta';

    ELSEIF CHAR_LENGTH(p_password_nueva) < 8
        OR CAST(p_password_nueva AS BINARY) = CAST(LOWER(p_password_nueva) AS BINARY)
        OR p_password_nueva NOT REGEXP '[0 - 9]' THEN

        SET p_resultado = 'La nueva contraseña no cumple la politica';

    ELSE
        SET v_salt_nuevo = LEFT(SHA2(CONCAT(UUID(), RAND(), NOW(6)), 256), 32);

        UPDATE usuarios
        SET salt = v_salt_nuevo,
            password_hash = SHA2(CONCAT(v_salt_nuevo, p_password_nueva), 256)
        WHERE nombre_usuario = p_nombre_usuario;

        SET p_resultado = 'contraseña actualizada';
    END IF;
END //





/* Auditoria trigger que registra eventos de seguridad INSERT, UPDATE, o DELETE sobre la tabla, Guardamos quien y cuando cambio una clave
o se bloqueo el usuario nunca se daña la contraseña en la auditoria*/
CREATE TABLE IF NOT EXISTS
auditoria_usuarios(
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL;
    accion VARCHAR(30)NOT NULL,
    detalle VARCHAR (255) NULL,
    usuario_bd VARCHAR(100)NOT NULL -- usuario de mysql ue hiz el cambio+
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP

) ENGINE = InnoDB;
DROP TRIGGER IF EXISTS trg_usuarios_auditoria

DELIMITER //
CREATE TRIGGER trg_usuarios_auditoria
AFTER UPDATE ON usuarios
FOR EACH ROW  --Se ejecuta por fila modificada
BEGIN
-- OLD = valores antes del UPDATE, NEW = Valores despues 
IF NEW.password_hash <> OLD.password_hash
THEN
INSERT INTO auditoria_usuarios(id_usuario, accion, detalle, uduario_bd)
VALUES (NEW.id_usuario, 'CAMBIO_PASSWORD', 'se cambio la contraseña', CURRENT_USER());
END IF;

IF NEW.bloqueado = TRUE AND OLD.bloqueado = FALSE THEN
INSERT INTO auditoria_usuarios(id_usuario, accion, detalle, usuario_bd)
VALUES (NEW.id_usuario,'BLOQUEO', 'Bloqueado por 3 intentos fallidos', CURRENT_USER());
END IF;
END//
DELIMITER;
/* PROBAR registro login bloqueo y cambio de clave 
-- registrar usuarios ( las claves solo viajan como parametro y nunca se guardan)*/
CALL sp_registrar_usuario('admin', 'admin@tienda.com', 'Admin*2026Seguro', 'ADMIN', NULL);
CALL sp_registrar_usuario('vendedor', 'ventas@tienda.com', 'Ventas#2026', 'VENDEDOR', NULL);
CALL sp_registrar_usuario('ana.gomez', 'ana.gomez@tienda.com', 'AnaGomez2026', 'CLENTE', 1);
CALL sp_registrar_usuario('carlos.perez', 'carlos.perez@tienda.com', 'Carlos2026!', 'CLENTE', 2);
CALL sp_registrar_usuario('debil', 'debil@tienda.com', '12345', 'CLENTE', NULL);-- lo debe rechazar por tener una contraseña debil

/* la contraseña no se ve en texto plano solo el hash y salt*/
SELECT id_usuario, nombre_usuario, rol, salt, password_hash
FROM usuarios;

/* login correcto*/
CALL sp_login('ana.gomez', 'AnaGomez2026', @resultado);
SELECT @resultado AS login_correcto; 

/* tres intentos  fallidos -> bloqueo*/
CALL sp_login('Carlos.perez', 'clave_mala', @r1);
CALL sp_login('Carlos.perez', 'clave_mala', @r2);
CALL sp_login('Carlos.perez', 'clave_mala', @r3);
CALL sp_login('Carlos.perez', 'Carlos2026!', @r4), -- aunque ahora sea correcta el usuario esta bloqueado
SELECT @r1,@r2,@r3,@r4;

SELECT nombre_usuario, intentos_fallidos, bloqueado, FROM usuarios;
--cambio de contraseña
CALL sp_cambiar_password('ana.gomez', 'AnaGomez2026', 'NuevaClave2026', @r);
SELECT @r AS cambio;

--evidencia de auditoria: aparecen el bloqueo y cambio de clave

SELECT * FROM auditoria_usuarios;

-- El administrador desbloquea al usuario
UPDATE usuarios SET bloqueado = FALSE, intentos_fallidos = 0
WHERE nombre_usuario ='carlos.perez';
