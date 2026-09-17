CREATE PROCEDURE "informix".sp_migra_sorteorem()

	RETURNING
		CHAR	(25) as archivo,
		CHAR	(5) as codret,
		CHAR	(100) as mensaje;

	-- DECLARACION DE VARIABLES
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	DEFINE cProceso			CHAR(100);
	DEFINE cCodRet			CHAR(5);
	DEFINE cVarError		CHAR(100);

	DEFINE vConsecutivo  	INTEGER;
    DEFINE vEstado          char(30);
    DEFINE vCiudad          char(30);
    DEFINE vSucursal        char(4);
    DEFINE vServicio		CHAR(20);
    DEFINE vFecha_movto	 	CHAR(19);
    DEFINE vNom_cte			VARCHAR(100);
    DEFINE vTelefono		CHAR(10);
    DEFINE vTipo_tel		CHAR(1);
    DEFINE vCorreo			VARCHAR(100);
    DEFINE vRemesa 			CHAR(12);
    DEFINE vFolio_suc	   	CHAR(18);
    DEFINE vNumcte			CHAR(9);
    DEFINE vNumconvenio		CHAR(3);
    DEFINE vFecha_cheques	DATE;
    DEFINE vEnviado			CHAR(1);
    DEFINE vUser_insert 	CHAR(8);
    DEFINE vFecha_insert	DATETIME YEAR to SECOND;

	
	-- INICIALIZAN LAS VARIABLES
	LET cProceso = 'sp_migra_sorteorem';
	LET cCodRet = '00000';
	LET cVarError = 'Ejecucion Exitosa';

	LET vConsecutivo = '';
	LET vEstado = '';
	LET vCiudad = '';
	LET vSucursal = '';
	LET vServicio = '';
	LET vFecha_movto = '';
	LET vNom_cte = '';
	LET vTelefono = '';
	LET vTipo_tel = '';
	LET vCorreo = '';
	LET vRemesa = '';
	LET vFolio_suc = '';
	LET vNumcte = '';
	LET vNumconvenio = '';
	LET vFecha_cheques = '';
	LET vEnviado = '';
	LET vUser_insert = '';
	LET vFecha_insert = '';
	

	BEGIN

	-- CONTROL DE ERRORES
	ON EXCEPTION SET iSqlErr, iSamErr, cVarError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cVarError = 'Error No Controlado';

			SET DEBUG FILE TO "/informix/RESPALDOSNEW/sp_migra_sorteorem.out";
			TRACE ON;

			INSERT INTO "informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
  			VALUES(trim(cProceso) || ': ' || iSqlErr, Today, '0', 'informix', current, 1, 'sp_migra_sorteorem', 'Migra registros de tabla Sorteo Remesas 2021');


			RETURN cProceso, cCodRet, cVarError;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/RESPALDOSNEW/noe/sp_migra_sorteorem.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	
--ACTUALIZA ESTATUS ENVIADO DE LOS REGISTROS

	FOREACH SELECT consecutivo, estado, ciudad, sucursal, servicio, fecha_movto, nom_cte, telefono, tipo_tel, correo, remesa, folio_suc, numcte, numconvenio, fecha_cheques, enviado, user_insert, fecha_insert
		INTO vConsecutivo, vEstado, vCiudad, vSucursal, vServicio, vFecha_movto, vNom_cte, vTelefono, vTipo_tel, vCorreo, vRemesa, vFolio_suc, vNumcte, vNumconvenio, vFecha_cheques, vEnviado, vUser_insert, vFecha_insert
		FROM "informix".sac_sorteo_remesas
	
		INSERT INTO "informix".sac_sorteo_remesas_his VALUES(vConsecutivo, vEstado, vCiudad, vSucursal, vServicio, vFecha_movto, vNom_cte, vTelefono, vTipo_tel, vCorreo, vRemesa, vFolio_suc, vNumcte, vNumconvenio, vFecha_cheques, vEnviado, vUser_insert, vFecha_insert, CURRENT);
		
    END FOREACH;

--RESETEA SERIAL
    INSERT INTO "informix".sac_sorteo_remesas VALUES(2147483647, vEstado, vCiudad, vSucursal, vServicio, vFecha_movto, vNom_cte, vTelefono, vTipo_tel, vCorreo, vRemesa, vFolio_suc, vNumcte, vNumconvenio, vFecha_cheques, vEnviado, 'RESETFOLIO', CURRENT);
	TRUNCATE TABLE "informix".sac_sorteo_remesas;

	
	RETURN cProceso, cCodRet, cVarError;

END;
END PROCEDURE;