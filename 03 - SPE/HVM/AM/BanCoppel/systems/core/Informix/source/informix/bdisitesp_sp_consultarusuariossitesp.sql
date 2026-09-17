CREATE PROCEDURE "informix".sp_consultarusuariossitesp(
													  pEmpresa	CHAR(3)
													 )

	RETURNING
	CHAR(6),  --cod retorno
	CHAR(8),  --Usuario
	CHAR(40); --Nombre

	--Declaracion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;

	DEFINE v_Usuario	CHAR(8);
	DEFINE v_Nombre		CHAR(40);

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

	LET v_Usuario	= "";
	LET v_Nombre	= "";

	--******************************************************
	--09-03-2009
	--Realizo:
	--Abraham Ayala
	--Obtener los usuarios que han realizado marcaciones a cuentas o cliente de Situaciones especiales.
	--******************************************************
	--21-04-2010
	--Modificó: Bernardo Carlos Baez Gonzalez
	--Se modifica para solo contemplar SE y Causas que apliquen a clientes
	--******************************************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, v_Usuario, v_Nombre;
	        END IF;
	    END EXCEPTION;

	--SET debug FILE TO '/tmp/sp_ConsultarUsuariosSitEsp.out';
	--trace ON;

	    --checar valores nulos en los parametros
	    IF pEmpresa = "" THEN

	        LET v_codret = "999";	--Faltan parametros
	        RETURN v_codret, v_Usuario, v_Nombre;
	    ELSE	--Seccion para consultar todos los datos
			--Consultamos todos los clientes que han realizado movimientos de situaciones especiales
			FOREACH
				/*SELECT {+INDEX (se_ctessitespcred_his se_ctessitespcred_his_idx3)} DISTINCT(CASE WHEN tipomovto IN ("S", "E") THEN usrmodifica ELSE usralta END) AS usuario
				INTO v_Usuario
				FROM bdisitesp:se_ctessitespcred_his
				WHERE empresa = pEmpresa
				UNION*/
				SELECT {+INDEX (se_ctessitespcte_his se_ctessitespcte_his_idx1)} DISTINCT(CASE WHEN tipomovto IN ("S", "E") THEN usrmodifica ELSE usralta END) AS usuario
				  INTO v_Usuario
				  FROM bdisitesp:se_ctessitespcte_his
				 WHERE empresa = pEmpresa

				--Obtenemos el nombre del usuario
				SELECT SUBSTR(nombre, 0, 40)
				  INTO v_Nombre
				  FROM bdinteg:si_ejecut
				 WHERE ejecutivo = v_Usuario
				   AND empresa = pEmpresa;

				RETURN v_codret, v_Usuario, v_Nombre WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE;