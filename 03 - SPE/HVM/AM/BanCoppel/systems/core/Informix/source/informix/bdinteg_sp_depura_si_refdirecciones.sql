CREATE PROCEDURE "informix".sp_depura_si_refdirecciones(pFecha DATE)
--execute procedure sp_depura_si_refdirecciones(mdy('02','28','2010'));
RETURNING 
CHAR(6),     -- codigo de retorno
CHAR(150);    -- mensaje

DEFINE cCodRet      	CHAR(6); 
DEFINE cMensaje     	CHAR(150); 
DEFINE vNumCred     	VARCHAR(20,1);
DEFINE vNumCredAux  	VARCHAR(20,1);
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE Error_Info   	VARCHAR(80);
--DEFINE pFecha 	DATE;
DEFINE vFecha 			DATE;
DEFINE dFechaAProcesar 	DATE;
DEFINE vnum_credito 	CHAR(20);
DEFINE vfecha_corte 	DATE;
DEFINE cFechaDepura 	CHAR(10);
DEFINE iDepura			INTEGER;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;
DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso					CHAR(1);
DEFINE iCuentasaDepurar					INTEGER;
DEFINE iCount_restantes					INTEGER;
DEFINE iCuentasaDepurarNulo				INTEGER;

DEFINE cProceso			CHAR(04);
DEFINE P_COD_RET    	VARCHAR(6);
DEFINE P_MENSAJE    	VARCHAR(150);
DEFINE v_sql        CHAR(1200);
DEFINE v_sql1       CHAR(500);
DEFINE v_sql2       CHAR(500);
DEFINE vRuta		CHAR(50);
DEFINE dFechaIni	DATE;
DEFINE dFechaFin	DATE;
DEFINE dFechaEmision DATE;
DEFINE cReinicio	CHAR(02);
DEFINE vNumCliente	CHAR(20);
DEFINE vFechaDelete	DATE;
DEFINE vFechaDeleteNulo	DATE;

LET vFechaDelete	= '';
LET vFechaDeleteNulo = '';
LET vNumCliente		= '';
LET v_sql       	= "";
LET v_sql1      	= "";
LET v_sql2      	= "";
LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
--LET pFecha 	= DATE(1);
LET vFecha 			= DATE(1);
LET dFechaAProcesar = DATE(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;
LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasaDepurar				= 0;
LET iCount_restantes				= 0;
LET iCuentasaDepurarNulo			= 0;
LET cProceso		= '0005';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= '';
LET vRuta      		= '/RESPALDOSNEW/'; --"/resplogifx/archivoscartera/";
LET dFechaIni	= DATE(1);
LET dFechaFin	= DATE(1);
LET dFechaEmision = DATE(1);
LET cReinicio 		= '';

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	';		
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;
            RETURN cCodRet,cMensaje;
		END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;
	
	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/ulises/sp_depura_tabla_si_refdirecciones.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
	-- ULTIMA FECHA DEPURACION CUENTAS CANCELADAS  FORMATO --> 12/31/2018
    SELECT valor
	INTO vFecha
	FROM bdicred:sd_param
	WHERE cod_param = '120';

    IF vFecha = '' OR vFecha IS NULL THEN
		INSERT INTO bdicred:"informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '120', 'ULTIMA FECHA DEPURACION DE TABLA si_refdirecciones', '12/31/2018', user, TODAY);
			
		LET vFecha = mdy('12','31','2018');
	END IF;	
	
	IF pFecha = date(1) THEN
		LET pFecha = MDY(MONTH(today),01,YEAR(today));
	ELSE
		LET pFecha = MDY(MONTH(pFecha),01,YEAR(pFecha));
		IF  pFecha > vFecha THEN
		   LET P_MENSAJE  = 'Excediste fecha a depurar';
		   LET P_COD_RET = '000001';
		   CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, P_COD_RET, P_MENSAJE, '02') RETURNING P_COD_RET;
		   RETURN P_COD_RET,P_MENSAJE;
		END IF;
	END IF;
	
	-- PARAMETRO DE HORAS A PROCESAR CUENTAS CANCELADAS      VALOR --> 5	
	SELECT valor::SMALLINT
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '121';

	 IF sHorasProceso IS NULL THEN 
		INSERT INTO bdicred:"informix".sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert) 
			VALUES('001', '121', 'PARAMETRO DE HORAS A PROCESAR DEPURACION SI_REFDIRECCIONES', '5', user, TODAY);
		
		LET sHorasProceso = '5';
	END IF;
	
	--Se obtiene la ruta para descargar archivos.
	/*SELECT valor::CHAR INTO vRuta
	FROM bdicred:sd_param 
	where cod_param = '033';
*/	
	SELECT valor
      INTO cReinicio
      FROM bdinteg:"informix".si_param
     WHERE empresa = '001' AND cod_param = '408';
	 
	 -- Si no existe el parametro 063 insertar informacion.
 
	 IF cReinicio IS NULL THEN
		LET cReinicio = '0';
		BEGIN WORK;
		INSERT INTO bdinteg:"informix".si_param(empresa,cod_param,descripcion,valor,user_insert,fecha_insert)
		VALUES ('001','408','Control reinicio descarga de tabla si_refdirecciones',cReinicio,USER,today);
		COMMIT WORK;
	
	ELIF cReinicio = '' THEN
		LET cReinicio = '0';
		BEGIN WORK;
		UPDATE bdinteg:"informix".si_param SET valor = cReinicio
		WHERE cod_param = '408';
		COMMIT WORK;
	END IF;
	
	-- Se Obtiene rango de fecha por anio
	LET dFechaIni = MDY(01,01,YEAR(pFecha));
	LET dFechaFin = (dFechaIni + 1 UNITS YEAR) - 1 UNITS DAY;
	
	if dFechaFin > vFecha then
		LET P_MENSAJE  = 'Sobrepasa rango de fecha limite a depurar';
		LET P_COD_RET = '000002'; 
		RETURN P_COD_RET,P_MENSAJE;
	end if;	

	If cReinicio = '0' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicio de descarga de tabla si_refdirecciones', '02') RETURNING P_COD_RET;
		-- Descargar de informaciÃ³n sd_indicador_cred_hist
		LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';

        LET v_sql1 = ' echo "UNLOAD TO '|| trim(vRuta) ||'si_refdirecciones_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdinteg:si_refdirecciones where fecha_insert >= '''||dFechaIni||''' and fecha_insert <= '''||dFechaFin||'''; " > '|| trim(vRuta) ||'queryRefDir.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdinteg "|| trim(vRuta) ||"queryRefDir.sql";
        system v_sql;
		
		LET cReinicio = '1';
		BEGIN WORK;
		update bdinteg:"informix".si_param
		set valor = cReinicio
		where empresa = '001' AND cod_param='408';
		COMMIT WORK;
		
		LET v_sql = '';
		LET v_sql = "gzip " || trim(vRuta) ||'si_refdirecciones_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
		SYSTEM v_sql;	
	end if;
		
	-- INICIA LA DEPURACION DE TABLAS OPERATIVAS
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia depuracion de tabla si_refdirecciones', '02') RETURNING P_COD_RET;
	
	FOREACH WITH HOLD
		select numcte, fecha_insert INTO vNumCliente, vFechaDelete from bdinteg:si_refdirecciones where fecha_insert >= dFechaIni and fecha_insert <= dFechaFin
		
		LET iCuentasaDepurar = iCuentasaDepurar + 1;
		
		BEGIN WORK;
			delete from bdinteg:si_refdirecciones where fecha_insert = vFechaDelete and numcte = vNumCliente;
        COMMIT WORK;
		
		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			EXIT FOREACH;
		END IF;
	END FOREACH;
	
	LET cReinicio = '0';
		
	update bdinteg:"informix".si_param
	set valor = cReinicio
	where empresa = '001' AND cod_param='408';
	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

	LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
	LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
	LET	sHoraFinal = sHoraFinal - sHoraInicial;

	IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
		LET cReinicio = 'X';
	END IF;
	
	If cReinicio = '0' then
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicio de descarga con fecha_insert nulos', '02') RETURNING P_COD_RET;
		-- Descargar de informaciÃ³n si_refdirecciones
		LET v_sql1 = '';
        LET v_sql2 = '';
		LET v_sql = '';

        LET v_sql1 = ' echo "UNLOAD TO '|| trim(vRuta) ||'si_refdirecciones_nulos_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
        LET v_sql2 = ' select * from bdinteg:si_refdirecciones where fecha_insert is null " > '|| trim(vRuta) ||'queryRefDirNulos.sql';

        LET v_sql = trim(v_sql1) || v_sql2;
        system v_sql;
		
        LET v_sql = "dbaccess bdinteg "|| trim(vRuta) ||"queryRefDirNulos.sql";
        system v_sql;
		
		LET v_sql = '';
		LET v_sql = "gzip " || trim(vRuta) ||'si_refdirecciones_nulos_'||to_char(dFechaFin, '%d%m%Y')||'.unl';
		SYSTEM v_sql;
		
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicio de depuracion con fecha_insert nulos', '02') RETURNING P_COD_RET;
		
		LET vNumCliente = '';
		
		FOREACH WITH HOLD
			select numcte INTO vNumCliente from bdinteg:si_refdirecciones where fecha_insert is null
			
			LET iCuentasaDepurarNulo = iCuentasaDepurarNulo + 1;
		
			BEGIN WORK;
				delete from bdinteg:si_refdirecciones where fecha_insert is null and numcte = vNumCliente;
			COMMIT WORK;	
					
		END FOREACH;	
	end if;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, 'Inicia actualizacion de estadisticas a si_refdirecciones', '02') RETURNING P_COD_RET;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:si_refdirecciones;
	
	--CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;
	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasaDepurar;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
	IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

	LET P_MENSAJE = 'El proceso DEPURA TABLA si_refdirecciones termino exitosamente. Cuentas procesadas ' || iCuentasaDepurar;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;