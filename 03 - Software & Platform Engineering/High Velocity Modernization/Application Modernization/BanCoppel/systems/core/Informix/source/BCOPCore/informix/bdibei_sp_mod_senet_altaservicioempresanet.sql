CREATE PROCEDURE "informix".sp_mod_senet_altaservicioempresanet(pNumCte CHAR(20), pUsuario CHAR(8), pNoTokens smallint)

	RETURNING CHAR(5) AS cCodRet;

	
    -- DEFINICIONES
    DEFINE iSql_Err         INTEGER;
    DEFINE cCodRet          CHAR(5);
    DEFINE sSecuencia       SMALLINT;
    DEFINE cSolicitud       CHAR(10);
    DEFINE cFolioSucursal   CHAR(16);
    DEFINE cRandon1         CHAR(6);
    DEFINE cRandon2         CHAR(2);
    DEFINE cRepLegal		CHAR(104);
	DEFINE vTotal_admin		SMALLINT;
	DEFINE vNoTokens_oper	SMALLINT;
	DEFINE dMonto			DECIMAL(12,2);
	DEFINE cEstatus 		SMALLINT;
	
    -- INICIALIZACIONES
    LET iSql_Err           	= 0;
    LET cCodRet           	= '000000';
    LET sSecuencia        	= 0;
    LET cSolicitud        	= '';
    LET cFolioSucursal    	= '';
    LET cRandon1          	= '';
    LET cRandon2         	= '';
	LET cRepLegal			= '';
	LET vTotal_admin		= 0;
   	LET vNoTokens_oper		= 0;
	LET dMonto				= 0.00;
	LET cEstatus			= 0;

    BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        RETURN cCodRet;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/mfinis/sp_senet_altaservicioempresanet.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Valida los parametros de entrada.
	IF NVL(pNumCte,'') = '' OR NVL(pUsuario,'') = '' OR NVL(pNoTokens,0) = 0 THEN
        LET cCodRet = '00001';
        RETURN cCodRet;
    END IF;

	--validamos que el número de tokens sea correcto
	IF pNoTokens < 2 OR pNoTokens > 10 THEN
	    LET cCodRet = '00002';
        RETURN cCodRet;
	END IF;	
	
	---------------------------------------------------------------------------------------------------------------------------------
	--Se resta al total de tokens la cantidad de administradores -------------------------------------------
	--Consulta el numero de administradores---
	SELECT COUNT(num_cliente) 
	INTO vTotal_admin
	FROM bdibei:bei_servicio 
	WHERE num_cliente=pNumCte;
	--Actualiza el parametros de total de tokens para operadores--
	LET vNoTokens_oper = pNoTokens - vTotal_admin;
	
	SELECT status_contrato
	INTO cEstatus
	FROM bdibei:"informix".bei_contratacion
	WHERE num_cliente = pNumCte;
	
	-- Actualizacion solicitud de token 
	UPDATE bdibei:"informix".bei_contratacion SET oper_no_token = vNoTokens_oper, rep_legal = cRepLegal, f_registro = TODAY, num_empleado = pUsuario, 
	fecha_movto = CURRENT, usuario_atiende = pUsuario, status_contrato = (CASE cEstatus WHEN 99 THEN 30 ELSE status_contrato END) 
	WHERE num_cliente = pNumCte;
	
	-- Consultamos la maxima secuencia del domicilio del cliente.
    SELECT secuencia 
      INTO sSecuencia
      FROM bdinteg:"informix".si_direcciones_actual 
     WHERE numcte = pNumCte
       AND tipo_dir = 1;

    IF sSecuencia IS NULL THEN
        SELECT MAX(secuencia) 
          INTO sSecuencia 
          FROM bdinteg:"informix".si_direcciones
         WHERE numcte = pNumCte
           AND tipo_dir = 1;
    END IF

    -- Consulta el maximo regitro + 1
    SELECT (NVL(MAX(solicitud),'0')::INTEGER + 1) 
      INTO cSolicitud
      FROM bdibei:"informix".bei_solicitudtoken;

    IF cSolicitud IS NULL THEN
        LET cSolicitud = '1';
    END IF;

    LET cSolicitud = LPAD(TRIM(cSolicitud), 10, '0');	
	
    -- Consultamos la hora para generar el folio.
    SELECT SUBSTR(DBINFO('utc_to_datetime', sh_curtime),12,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),15,2) || SUBSTR(DBINFO('utc_to_datetime', sh_curtime),18,2)
      INTO cRandon1
      FROM sysmaster:sysshmvals;

    -- Generamos un Randon para completar el valor del folio.
    EXECUTE PROCEDURE bdicheq:"informix".sp_random()
    INTO cRandon2;

    LET cFolioSucursal = 'SINCOMIS'||cRandon1||LPAD(TRIM(cRandon2), 2, '0');
	
    UPDATE bdibei:"informix".bei_solicitudtoken SET solicitud = cSolicitud, id_status = '100', unidades = pNoTokens, 
	folio_suc = cFolioSucursal, usr_solicita = pUsuario, sec_domicilio = sSecuencia, f_solicitud = CURRENT
	WHERE numcte = pNumCte;

	INSERT INTO bdibei:"informix".bei_stasolicitud (solicitud, anterior, actual, f_registro)
	VALUES (cSolicitud, '100', '100', CURRENT);
	
	-- Obtiene datos faltantes para el registro de conciliación	
	IF TRIM(SUBSTR(cFolioSucursal,1,8)) = 'SINCOMIS' THEN
		LET dMonto = 0.00;
	END IF;
	
	-- Inserta el registro de conciliación
	UPDATE bdibpi: "informix".tkn_solcobranza SET solicitud = cSolicitud, id_status = '100', f_solicitud = CURRENT, folio_suc = cFolioSucursal, 
	f_cobro = dMonto
	WHERE Numcte = pNumCte;
	
	INSERT INTO bdicnweb:"informix".sw_regbitacora_empresanet (usuario_insert, num_cliente, operacion, fecha) 
	VALUES (pUsuario, pNumCte, 'MODIFICACION ADMO.', CURRENT);
	
    RETURN cCodRet;

 END;    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se desarrollo SP para realizar la actualización de información del Servicio de Empresa NET',
'AUTOR:  Veronica Sanchez Tlacomulco',   
'FECHA DE CREACION: 08/07/2022',
'BD: bdibei';

CREATE PROCEDURE "informix".sp_consulta_dynatrace ()
RETURNING CHAR(5);
    DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE fechaMonitoreo CHAR(50);

    LET codRet = '00000';
    LET viSqlErr = 0;
    LET fechaMonitoreo = CURRENT;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET codRet = viSqlErr;
                RETURN codRet;
            END IF;	
        END EXCEPTION;


        SELECT fecha INTO fechaMonitoreo FROM bdibei:"informix".bei_monitoreo_dynatrace;
        IF fechaMonitoreo  <> '' AND fechaMonitoreo <> 'NULL' THEN
            UPDATE bdibei:"informix".bei_monitoreo_dynatrace SET fecha = CURRENT;
        ELSE
            INSERT INTO bdibei:"informix".bei_monitoreo_dynatrace(fecha)
            VALUES(CURRENT);
        END IF;


        RETURN codRet;
    END;
END PROCEDURE
;