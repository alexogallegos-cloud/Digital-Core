CREATE PROCEDURE "informix".sp_cons_detenvios_token_pba(pEmpresa char(3), pSolicitud char(10))
   returning char(5),char(16), char(20), date, char(4), money(16,2);


      --------------------------------------------------------------------------------------------
	-- Realizó: Pedro Enrique Zavala Valdez
	-- Actividad: Calcula el cargo total del token
	-- Solicitó: Mauricio León
	-- Fecha de Solicitud: 25/11/2009
	---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE vCodRet char(5);
    DEFINE vFolioSuc char(16);
    DEFINE vCuenta char(20);
	DEFINE vCliente char(9);
    DEFINE vFecha date;
    DEFINE vSucursal char(4);
    DEFINE vCargoTot money(16,2);
    DEFINE vMonto money(16,2);
	DEFINE vFechaReg datetime year to second;
    DEFINE sql_err integer;
	DEFINE v_sNomTablaChq CHAR(50);
	DEFINE v_sNomTablaCred CHAR(50);
	DEFINE v_sNumSesion CHAR(50);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET vCodRet = "00000";
   LET vFolioSuc = '';
   LET vCuenta  = '';
   LET vCliente  = '';
   LET vFecha  = '01/01/1900';
   LET vSucursal = '';
   LET vCargoTot = 0;
   LET vMonto = 0;
   --LET vFechaReg  = '1900-01-01 00:00:00';
   LET vFechaReg  = current;
   LET sql_err = 0;
   LET v_sNomTablaChq = '';
   LET v_sNomTablaCred = '';
   LET v_sNumSesion = '';

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            IF v_sNomTablaChq <> '' THEN
                IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabid > 99 and tabtype = "T" and tabname = 'tmp_movcheques') THEN
                    DROP TABLE tmp_movcheques;
                END IF
            END IF

            IF v_sNomTablaCred <> '' THEN
                IF EXISTS ( SELECT tabname FROM sysmaster:systabnames WHERE tabid > 99 and tabtype = "T" and tabname = 'tmp_movcredito') THEN
                    DROP TABLE tmp_movcredito;
                END IF
            END IF

            LET vCodRet = sql_err;
            RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
        END IF
    END EXCEPTION;

	SELECT DBINFO('sessionid')
	INTO v_sNumSesion
	FROM systables
	WHERE tabname = 'systables';

	LET v_sNomTablaChq = 'tmpmovchq'||v_sNumSesion;
	LET v_sNomTablaCred = 'tmpmovcred'||v_sNumSesion;

    SET ISOLATION DIRTY READ;

    SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} folio_suc, numcte INTO vFolioSuc, vCliente
    FROM bdibpi:bpi_tokensolicitud
    WHERE empresa = pEmpresa AND solicitud = pSolicitud;

	SELECT {+INDEX(bdinteg:si_bpitoken idx_bpitoken)} LIMIT 1 f_registro INTO vFechaReg
    FROM bdinteg:si_bpitoken
    WHERE empresa = pEmpresa AND num_cliente = vCliente;

    IF NVL(vFolioSuc,'') <> "" THEN
        SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)} cuenta, fech_alt, sucursal, monto_tot
		FROM bdicheq:sc_movhis
		WHERE empresa = pEmpresa AND cuenta <> "" AND fech_alt = Extend(vFechaReg , year to day)
		AND cancelad <> "S" AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
		UNION
		SELECT {+INDEX(bdicheq:sc_movdia idx_movdia1a)} cuenta, fech_alt, sucursal, monto_tot
		FROM bdicheq:sc_movdia
		WHERE empresa = pEmpresa AND cuenta <> "" AND fech_alt = Extend(vFechaReg , year to day)
		AND cancelad <> "S" AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
		INTO TEMP v_sNomTablaChq WITH NO LOG;

		FOREACH
            SELECT cuenta, fech_alt, sucursal, monto_tot
			INTO vCuenta, vFecha, vSucursal, vMonto
			FROM v_sNomTablaChq

			LET vCargoTot = vCargoTot + vMonto;
			LET vMonto = 0;
        END FOREACH
		DROP TABLE v_sNomTablaChq;

        IF vCuenta = '' THEN
			SELECT num_credito, fecha_mov, sucursal, monto
			FROM bdicred:sd_movdia
			WHERE codigo_fun = '039' AND codigo_ref in ('28','29')  AND folio_suc = vFolioSuc
			UNION
			SELECT num_credito, fecha_mov, sucursal, monto
			FROM bdicred:sd_movhis
			WHERE codigo_fun = '039' AND codigo_ref in ('28','29')  AND folio_suc = vFolioSuc
			INTO TEMP v_sNomTablaCred WITH NO LOG;

            FOREACH
				SELECT num_credito, fecha_mov, sucursal, monto
				INTO vCuenta, vFecha, vSucursal, vMonto
				FROM v_sNomTablaCred

                LET vCargoTot = vCargoTot + vMonto;
                LET vMonto = 0;

            END FOREACH
			DROP TABLE v_sNomTablaCred;
        END IF

        IF(vCuenta = '') THEN
            LET vCodRet = '002'; --No existe registro de cargo
        END IF
    ELSE
        LET vCodRet = '001'; --No tiene folio de sucursal asignado
    END IF

    RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;

END
END PROCEDURE
DOCUMENT
"AUTOR: Marcos Antonio Cuevas Rodriguez",
"FECHA: 27/Abril/2010",
"BD   : bdibpi",
"DESC : Se modifica para que cree temporales sin log en la consulta",
"       a los historicos de cheques y credito";

CREATE PROCEDURE "informix".sp_cons_detenvios_token_prueba(pEmpresa char(3), pSolicitud char(10))
   returning char(5),char(16), char(20), date, char(4), money(16,2);


      --------------------------------------------------------------------------------------------
	-- Realizó: Pedro Enrique Zavala Valdez
	-- Actividad: Calcula el cargo total del token
	-- Solicitó: Mauricio León
	-- Fecha de Solicitud: 25/11/2009
	---------------------------------------------------------------------------------------------

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE vCodRet char(5);
    DEFINE vFolioSuc char(16);
    DEFINE vCuenta char(20);
	DEFINE vCliente char(9);
    DEFINE vFecha date;
    DEFINE vFechaHoy date;
    DEFINE vSucursal char(4);
    DEFINE vCargoTot money(16,2);
    DEFINE vMonto money(16,2);
	DEFINE vFechaReg datetime year to second;
    DEFINE sql_err integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET vCodRet = "00000";
   LET vFolioSuc = '';
   LET vCuenta  = '';
   LET vCliente  = '';
   LET vFecha  = '01/01/1900';
   LET vFechaHoy  = '01/01/1900';
   LET vSucursal = '';
   LET vCargoTot = 0;
   LET vMonto = 0;
   --LET vFechaReg  = '1900-01-01 00:00:00';
   LET vFechaReg  = current;
   LET sql_err = 0;

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
      END IF
   END exception;

    SET ISOLATION DIRTY READ ;

    SELECT {+INDEX(bpi_tokensolicitud idx_tokensolicitud)} folio_suc, numcte
    INTO vFolioSuc, vCliente
    FROM bdibpi:bpi_tokensolicitud
    WHERE empresa = pEmpresa AND solicitud = pSolicitud;

    SELECT {+INDEX(bdinteg:si_bpitoken idx_bpitoken)} LIMIT 1 f_registro
    INTO vFechaReg
    FROM bdinteg:si_bpitoken
    WHERE empresa = pEmpresa AND num_cliente = vCliente;

    LET vFechaReg = EXTEND(vFechaReg, YEAR TO DAY);

    SELECT fecha_hoy
    INTO vFechaHoy
    FROM bdicheq:sc_fechas;

    IF NVL(vFolioSuc,'') <> "" THEN

        IF vFechaHoy = vFechaReg THEN

            SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
            INTO vCuenta, vFecha, vSucursal, vMonto
            FROM bdicheq:sc_movdia
            WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
            AND fech_alt = vFechaReg AND cancelad <> "S"
            AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
            GROUP BY cuenta, fech_alt, sucursal;

        ELSE

            SELECT cuenta, fech_alt, sucursal, SUM(monto_tot)
            INTO vCuenta, vFecha, vSucursal, vMonto
            FROM bdicheq:sc_movhis
            WHERE empresa = pEmpresa AND cuenta IN ( SELECT cuenta FROM bdicheq:sc_maechq WHERE empresa = pEmpresa AND num_cte = vCliente )
            AND fech_alt = vFechaReg AND cancelad <> "S"
            AND transacc in ('3005','0260') AND  folio_suc = vFolioSuc
            GROUP BY cuenta, fech_alt, sucursal;

        END IF

        IF NVL(vCuenta,'') = '' THEN

            SELECT fecha_hoy
            INTO vFechaHoy
            FROM bdicred:sd_fechas;

            IF vFechaHoy = vFechaReg THEN

                SELECT num_credito, fecha_mov, sucursal, SUM(monto)
                INTO vCuenta, vFecha, vSucursal, vMonto
                FROM bdicred:sd_movdia
                WHERE codigo_fun = '039' AND codigo_ref in ('28','29')  AND folio_suc = vFolioSuc
                AND num_credito IN ( SELECT num_credito FROM bdicred:sd_maecred WHERE numcte = vCliente )
                GROUP BY num_credito, fecha_mov, sucursal;

            ELSE

                SELECT num_credito, fecha_mov, sucursal, SUM(monto)
                INTO vCuenta, vFecha, vSucursal, vMonto
                FROM bdicred:sd_movhis
                WHERE codigo_fun = '039' AND codigo_ref in ('28','29')  AND folio_suc = vFolioSuc
                AND num_credito IN ( SELECT num_credito FROM bdicred:sd_maecred WHERE numcte = vCliente )
                GROUP BY num_credito, fecha_mov, sucursal;

            END IF
        END IF

        LET vCargoTot = vMonto;

        IF NVL(vCuenta,'') = '' THEN
            LET vCodRet = '002'; --No existe registro de cargo
        END IF

     ELSE

        LET vCodRet = '001'; --No tiene folio de sucursal asignado

     END IF

     RETURN vCodRet, vFolioSuc, vCuenta, vFecha, vSucursal, vCargoTot;
END
END PROCEDURE
DOCUMENT
'MODIFICO    : Julio Cesar Polanco Inzunza ',
'SOLICITO    : Ismael Hernandez Monroy',
'FECHA       : 30/10/2010',
'BD          : bdibpi ',
'DESCRIPCION : Se optimizan consultas a las tablas de movimientos diarios',
'              e historicas de cheques y credito, eliminando foreach y ',
'              utilizando indices en las consultas a las tablas de bdibpi';

CREATE PROCEDURE "informix".sp_reporte_inventario_token(pTipoCons smallint, pNumToken char(9), pFecIni date, pFecFin date, pReg int)
        RETURNING char(5) AS codRetorno,  --Cod. Retorno
				  char(9) AS numSerie,    --Num. Serie Token
				  char(10) AS solcitud,	  --Num. Solicitud
				  smallint AS idStatus,   --Id Status 
				  char(9) AS numCliente,  --Num. Cliente
				  date AS fecSolicitud,   --Fecha Solicitud
				  char(8) AS perSolicita, --Persona que solicita
				  char(4) AS sucursal,    --Sucursal
				  date AS fecAsigacion,   --Fecha Asigancion a cliente
				  date AS fecEnvio,       --Fecha Envio
				  char(8) AS perEnvio,    --Persona que envio
				  date AS fecConfirmacion,--Fecha Conf. de Entrega
				  char(8) AS perConfirma; --Persona que confirma entrega

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obtiene un reporte de inventario de tokens asignados, enviados y entregados
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 11/05/2010

	DEFINE vcodret			char(5);
	DEFINE vNumToken		char(9);
	DEFINE vSolicitud		char(10);
	DEFINE vIdStatus		smallint;
	DEFINE vNumCliente		char(9);
	DEFINE vFecSolicitud	date;
	DEFINE vPerSolicita		char(8);
	DEFINE vSucursal		char(4);
	DEFINE vFecAsignacion	date;
	DEFINE vFecEnvio		date;
	DEFINE vPerEnvio		char(8);
	DEFINE vFecEntrega		date;
	DEFINE vPerConfirma		char(8);
	DEFINE sql_err			integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
       END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_reporte_inventario_token.out";
--TRACE ON;

LET vcodret = '000';
LET vNumToken = '';
LET vSolicitud = '';
LET vIdStatus = 0;
LET vNumCliente = '';
LET vFecSolicitud = '01-01-1900';
LET vPerSolicita = '';
LET vSucursal = '';
LET vFecAsignacion = '01-01-1900';
LET vFecEnvio = '01-01-1900';
LET vPerEnvio = '';
LET vFecEntrega = '01-01-1900';
LET vPerConfirma = '';

BEGIN

	IF pTipoCons = 2 THEN
		IF NOT EXISTS(SELECT ns_token FROM tkn_nseries WHERE ns_token = pNumToken) THEN
			RETURN '001', vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
		END IF;
	
		IF NOT EXISTS(SELECT ns_token FROM tkn_nseries WHERE ns_token = pNumToken AND (id_status = 110 OR id_status = 120 OR id_status = 130)) THEN
			RETURN '002', vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
		END IF;
		
		SELECT ns_token, id_status 
		INTO vNumToken, vIdStatus
		FROM tkn_nseries 
		WHERE ns_token = pNumToken AND (id_status = 110 OR id_status = 120 OR id_status = 130);
		
		SELECT solicitud, numcte, f_solicitud, usr_solicita, sucursal
		INTO vSolicitud, vNumCliente, vFecSolicitud, vPerSolicita, vSucursal
		FROM bpi_tokensolicitud
		WHERE ns_token = pNumToken;
		
		SELECT MAX(f_cambio_status)
		INTO vFecAsignacion
		FROM tkn_status_token
		WHERE ns_token = pNumToken AND actual = 110 AND anterior = 105;
		
		SELECT f_envio
		INTO vFecEnvio
		FROM tkn_envios
		WHERE solicitud = vSolicitud;
		
		SELECT usr_cambio_status
		INTO vPerEnvio
		FROM tkn_status_token
		WHERE ns_token = pNumToken AND actual = 120 AND anterior = 110;
		
		SELECT MAX(f_cambio_status), usr_cambio_status
		INTO vFecEntrega, vPerConfirma
		FROM tkn_status_token
		WHERE ns_token = pNumToken AND actual = 130 AND anterior = 120
		GROUP BY usr_cambio_status;
		
		RETURN vcodret, vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
			   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma;
	ELSE
		FOREACH
			SELECT SKIP pReg FIRST 10 ns_token, id_status 
			INTO vNumToken, vIdStatus
			FROM tkn_nseries 
			WHERE f_status::date BETWEEN pFecIni AND pFecFin AND (id_status = 110 OR id_status = 120 OR id_status = 130)
			ORDER BY ns_token
			
			SELECT solicitud, numcte, f_solicitud, usr_solicita, sucursal
			INTO vSolicitud, vNumCliente, vFecSolicitud, vPerSolicita, vSucursal
			FROM bpi_tokensolicitud
			WHERE ns_token = vNumToken;
			
			SELECT MAX(f_cambio_status)
			INTO vFecAsignacion
			FROM tkn_status_token
			WHERE ns_token = vNumToken AND actual = 110 AND anterior = 105;
			
			SELECT f_envio
			INTO vFecEnvio
			FROM tkn_envios
			WHERE solicitud = vSolicitud;
			
			SELECT usr_cambio_status
			INTO vPerEnvio
			FROM tkn_status_token
			WHERE ns_token = vNumToken AND actual = 120 AND anterior = 110;
			
			SELECT MAX(f_cambio_status), usr_cambio_status
			INTO vFecEntrega, vPerConfirma
			FROM tkn_status_token
			WHERE ns_token = vNumToken AND actual = 130 AND anterior = 120
			GROUP BY usr_cambio_status;
		
			RETURN vcodret, vNumToken, vSolicitud, vIdStatus, vNumCliente, vFecSolicitud, vPerSolicita, 
				   vSucursal, vFecAsignacion, vFecEnvio, vPerEnvio, vFecEntrega, vPerConfirma WITH RESUME;
		END FOREACH;
	END IF;
	
END;

END PROCEDURE;