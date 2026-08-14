CREATE PROCEDURE "informix".sp_validapass_bei(
    pNumCte CHAR(20),
    pNombreUsuario CHAR(50),
    pEmpresa CHAR(3)
)
   RETURNING CHAR(5),CHAR(50),CHAR(50), CHAR(50),CHAR(50), CHAR(50), CHAR(26), CHAR(13), CHAR(13), DATE, DATE ;

   DEFINE cCod_ret CHAR(5);
   DEFINE sql_err INTEGER;
   DEFINE cUsuario, cPass, cPass1, cPass2, cPass3 CHAR(50);
   DEFINE cNombre CHAR(26);
   DEFINE cTelefono1, cTelefono2 CHAR(13);
   DEFINE dFecha_constitucion, dFecha_actual DATE;
   DEFINE cIdusuario INTEGER;

   LET cCod_ret       = "000";
   LET cUsuario = "";
   LET cPass = "";
   LET cPass1 = "";
   LET cPass2 = "";
   LET cPass3 = "";
   LET cNombre = "";
   LET cTelefono1 = "";
   LET cTelefono2 = "";
   LET dFecha_constitucion = null;
   LET dFecha_actual = CURRENT ;
 	
	--*********************************************
	--SET debug FILE TO "/home/informix/BereniceOut/sp_validapass_bei.out";
	--Trace ON;
	--*********************************************
	
 	--****************************************************************************************************
	-- DESCRIPCION:  VObtiene informacion del cliente de BEI
	-- AUTOR : SOLSER
	-- FECHA : 08/07/2013
	-- BD: BDIBEI
    -- Modificacion: Se cambia para que no consulte los telefonos en la tabla si_direcciones_actual sino 
	-- que los consulte en la tabla de usuario.
	-- Modifica: Berenice Noriega
	-- Fecha modificación: 23/Junio/2014
	--***************************************************************************************************

	BEGIN
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCod_ret = sql_err;
				RETURN cCod_ret, cUsuario, cPass, cPass1, cPass2, cPass3, cNombre, cTelefono1, cTelefono2,  dFecha_constitucion, dFecha_actual;
			END IF
		END EXCEPTION;

        SET LOCK MODE TO WAIT ;
        SET ISOLATION DIRTY READ ;

        SELECT usuario.usuario_bei, usuario.pass , usuario.pass1 , usuario.pass2, usuario.pass3, usuario.id_usuario
        INTO cUsuario, cPass, cPass1, cPass2, cPass3, cIdusuario
        FROM "informix".bei_usuario AS usuario
            INNER JOIN "informix".bei_servicio AS servicio
                ON usuario.id_usuario = servicio.id_usuario
                AND usuario.num_cliente = servicio.num_cliente
        WHERE usuario.usuario_bei = pNombreUsuario
        AND usuario.num_cliente = pNumCte;

        IF(cUsuario IS NULL) THEN
            LET cCod_ret = '00001'; --No existe cliente
            RETURN cCod_ret, NVL(cUsuario,''),NVL(cPass,''), NVL(cPass1,''), NVL(cPass2,''), NVL(cPass3,''), cNombre, NVL(cTelefono1,''), NVL(cTelefono2,''),  dFecha_constitucion, dFecha_actual;
        END IF;

        SELECT LIMIT 1 nombre_corto, fecha_constitct
            INTO cNombre, dFecha_constitucion
        FROM bdinteg:"informix".si_ctepm
        WHERE empresa = pEmpresa
        AND numcte =  pNumCte;

      	--***CONSULTA TELEFONO DE USUARIO********--
		SELECT tel_celular
		INTO cTelefono1
		FROM bdibei:"informix".bei_datos_usuario
		WHERE id_usuario = cIdusuario
		AND activo='t';
		--***************************************--


		RETURN cCod_ret, NVL(cUsuario,''),NVL(cPass,''), NVL(cPass1,''), NVL(cPass2,''), NVL(cPass3,''), cNombre, NVL(cTelefono1,''), NVL(cTelefono2,''),  dFecha_constitucion, dFecha_actual;
	END
END PROCEDURE;