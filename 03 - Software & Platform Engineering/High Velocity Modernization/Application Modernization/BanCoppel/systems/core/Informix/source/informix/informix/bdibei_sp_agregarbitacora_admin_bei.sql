CREATE PROCEDURE "informix".sp_agregarbitacora_admin_bei(
    pFechaOper DATETIME YEAR TO SECOND, 
    pIdOperacion CHAR(4),
    pIpUsuario CHAR(15),
    pIdAdmin INTEGER,
    pIdOperador INTEGER,
    pFechaAplic DATE,
    pCtaOrigen CHAR(12),
    pCtaDestino CHAR(12),
    pToken CHAR(9),
    pCgen3 CHAR(50),
    pCgen4 CHAR(50),
    pCgen5 CHAR(50),
    pCgen6 CHAR(50)
    )

RETURNING CHAR(5), INTEGER;

	-- ****************************************************************************************************
	-- DESCRIPCION: SP para la insercion en bei_bitacora_admin
	-- AUTOR : Lili PV
	-- FECHA : 04/Mayo/2018
	-- FECHA LIBERACIÓN PRODUCCIÓN: 02-AGOSTO-2018
	-- BASE DE DATOS: BDIBEI
	-- ****************************************************************************************************

 --DEFINICION DE VARIABLES
DEFINE cod_ret CHAR(5);
DEFINE sql_err INTEGER;
DEFINE cNumCliente CHAR(50);
DEFINE cNombreAdmin CHAR(150);
DEFINE cNombreOperador CHAR(150);
DEFINE sIdBitacoraAdmin INTEGER;

--INICIALIZA VARIABLES
LET cod_ret  = "00000";
LET cNombreAdmin = "";
LET cNombreOperador = "";
LET sIdBitacoraAdmin = 0;

BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret, sIdBitacoraAdmin;
      END IF;
    END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION DIRTY READ;
	
	
    IF pIdAdmin IS NOT NULL THEN
        SELECT num_cliente
    	INTO cNumCliente
    	FROM bei_usuario
    	WHERE id_usuario = pIdAdmin;
	ELSE
		LET cod_ret = '00001';
		RETURN cod_ret, sIdBitacoraAdmin;
    END IF

    IF pIdAdmin IS NOT NULL THEN
        SELECT nombre 
        INTO cNombreAdmin
        FROM bdibei:bei_datos_usuario
        WHERE id_usuario = pIdAdmin;
    END IF

   IF pIdOperador IS NOT NULL THEN
        SELECT nombre 
        INTO cNombreOperador
        FROM bdibei:bei_datos_usuario
        WHERE id_usuario = pIdOperador;
    END IF

    INSERT INTO bdibei:"informix".bei_bitacora_admin(id_bitacora_admin,
         fecha_oper,
         id_operacion,
         num_cliente,
         ipusuario,
         id_admin,
         id_operador,
         fecha_aplic,
         cuenta_origen,
         destino,
         token,
         cgenerico1, -- Para el nombre del id_admin
         cgenerico2, -- Para el nombre del id_operador
         cgenerico3,
         cgenerico4,
         cgenerico5,
         cgenerico6
         ) VALUES (0,
              pFechaOper,
              pIdOperacion,
              cNumCliente,
              pIpUsuario,
              pIdAdmin,
              pIdOperador,
              pFechaAplic,
              pCtaOrigen,
              pCtaDestino,
              pToken,
              cNombreAdmin,               
              cNombreOperador,               
              pCgen3,
              pCgen4,
              pCgen5,
              pCgen6);
              
    LET sIdBitacoraAdmin = DBINFO('sqlca.sqlerrd1');

    RETURN cod_ret, sIdBitacoraAdmin;

END;
END PROCEDURE;