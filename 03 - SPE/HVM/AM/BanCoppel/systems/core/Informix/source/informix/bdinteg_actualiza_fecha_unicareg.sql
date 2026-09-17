CREATE PROCEDURE "informix".actualiza_fecha_unicareg()

--RETURNING CHAR(5) as cod_ret,CHAR(60) as nombre_completo ,CHAR(20) as numcte,CHAR(13) as rfc,CHAR(2) as tipo_cte;
RETURNING CHAR(5) as cod_ret, INTEGER as r_actualizados;

DEFINE sql_err 			  INTEGER;
DEFINE v_cod_ret		CHAR (5);
DEFINE v_r_actualizado 		      INTEGER;
DEFINE v_empresa 		      CHAR(4);
DEFINE v_numcte 		      CHAR(9);
DEFINE v_id_status 		      CHAR(4);
DEFINE v_f_registro		DATETIME YEAR to SECOND;

--set debug file to "ConsultarNombreNumCliente.out";
--trace on;

LET v_cod_ret = "00000";
LET v_r_actualizado = 0;
LET v_empresa = '';
LET v_numcte = '';
LET v_id_status = '';
LET v_f_registro = CURRENT;

BEGIN
  ON EXCEPTION SET sql_err
     IF sql_err <> 0 THEN
   	     LET v_cod_ret = sql_err;
	     RETURN v_cod_ret,v_r_actualizado;
     END IF;
   END EXCEPTION;

--SET ISOLATION TO DIRTY READ;
set lock mode to wait 3; 

    FOREACH
        SELECT empresa,numcte,id_status,f_registro
 	    INTO v_empresa,v_numcte,v_id_status,v_f_registro
        FROM bdinteg:si_bpiusuarios
        WHERE empresa = '001'
        and numcte <> ''
        and id_status <> '99'
        and f_unico_reg IS NOT NULL
        ORDER BY numcte

	IF v_f_registro IS NOT NULL OR v_f_registro <> "" THEN
		LET v_r_actualizado = v_r_actualizado + 1;
			
		UPDATE bdinteg:si_bpiusuarios
		SET f_unico_reg = v_f_registro
		WHERE empresa = '001'
		AND numcte = v_numcte
		AND id_status = v_id_status;
		
	END IF;

    END FOREACH;

        RETURN v_cod_ret,v_r_actualizado;

END;
END PROCEDURE
DOCUMENT
'Registra la fecha unica de registro para el regulatorio',
'AUTOR : Ismael Hernandez',
'FECHA : 19/11/2010',
'BD    : bdinteg',
'VER   : 1.0';

CREATE PROCEDURE "informix".sp_asigna_premio (pClaveSort CHAR(5),
                                              pFechaActual DATE,
                                              pIdSucursal CHAR(4),
                                              pIdPremio CHAR(2),
                                              pFolioPremio CHAR(16),
                                              pTipoOperacion CHAR(2),
                                              pNumCliente CHAR(10),
                                              pFolioOperacion CHAR(16),
                                              pImporte MONEY,
                                              pUsuario CHAR(10),
							                                pEtapa CHAR(1))  -- BGM 3-Sep-2010: parámetro para confirmar impresión de ticket.

RETURNING CHAR (5) AS Codigo, CHAR(5) AS Clave_Sorteo, CHAR (80) AS Mensaje;

--- DECLARACION DE VARIABLES

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE v_Codret         CHAR(5);
    DEFINE vRetorno         CHAR(5);
    DEFINE vMensaje         CHAR(80);
    DEFINE vEstatus         CHAR(1);
    DEFINE vId_sucursal     CHAR(4);
    DEFINE vId_premio       CHAR(2);
    DEFINE vFolio_premio    CHAR(16);
    DEFINE vNumeroCliente   CHAR(10);
    DEFINE vCve_sorteo      CHAR(5);
    DEFINE vTipo            SMALLINT;
    
    DEFINE vNcliente        INTEGER;
    
    DEFINE cCodRet          CHAR(3);
	DEFINE vFechaHoy		DATE;
	DEFINE vFechaPremio		DATE;

--- INICIALIZACION DE VARIABLES

    LET sql_err         = 0;
    LET isam_err        = 0;
    LET v_Codret        = '00000';
    LET vRetorno        = '00000';
    LET vMensaje        = 'El proceso concluyó exitosamente';
    LET vEstatus        = '';
    LET vId_sucursal    = '';
    LET vId_premio      = '';
    LET vFolio_premio   = '';
    LET vNumeroCliente  = '';
    LET vCve_sorteo     = '0';
    LET vTipo           = '';
    
    LET vNcliente       = 0;
    
    LET cCodRet         = '';

     --**************************************************************
     -- Creado por Raúl Ramírez    19/Agosto/2010
     -- Asignacion de Premio Sorteo Instantaneo
     --**************************************************************

BEGIN

    ON EXCEPTION SET sql_err

        IF sql_err <> 0  THEN
            LET v_Codret = sql_err;
            LET v_Codret = v_Codret;
            LET vRetorno = '117';
            LET vMensaje = 'ERROR EN LA EJECUCION';

            RETURN v_Codret, vRetorno, vMensaje;           -- Termina proceso del SP
        END IF;
    END EXCEPTION;

        --SET DEBUG FILE TO "/ids10_uc9/raul/sorteo/sp_asigna_premio.out";
        --TRACE ON;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF  (pClaveSort IS NULL OR pClaveSort = '' OR LENGTH(pClaveSort) <> 5) OR    -- OR LENGTH(pClaveSort) <> 5
        (pFechaActual IS NULL OR pFechaActual = '') OR
        (pIdSucursal IS NULL OR pIdSucursal = '') OR
        (pIdPremio IS NULL OR pIdPremio = '' OR pIdPremio = '00' OR LENGTH(pIdPremio) <> 2) OR
        (pFolioPremio IS NULL OR pFolioPremio = '' OR LENGTH(pFolioPremio) <> 12) OR
        (pTipoOperacion IS NULL OR pTipoOperacion = '') OR
        (pNumCliente IS NULL OR pNumCliente = '') OR
        (pFolioOperacion IS NULL OR pFolioOperacion = '' OR LENGTH(pFolioOperacion) <> 16) OR
        (pImporte IS NULL OR pImporte = '' OR pImporte <= 0.00) OR
        (pUsuario IS NULL OR pUsuario = '') OR 
	     	(pEtapa IS NULL OR pEtapa = '') THEN               -- BGM 3-Sep-2010: se valida parámetro de Etapa.

        LET v_Codret = '117';
        LET vMensaje = 'Se generó algún error de parametros en la ejecución';

        RETURN v_Codret, vRetorno, vMensaje;               -- Termina proceso del SP
    END IF;

	SELECT {+INDEX(si_fechas idx_si_fechas)} fecha_hoy INTO vFechaHoy
	FROM bdinteg:si_fechas
	WHERE empresa = '001';
	
	IF (NOT EXISTS (SELECT {+index (si_horario_premio idx_si_horario_premio2)} f_sorteo FROM si_horario_premio WHERE f_sorteo = today)) 
		OR (NOT EXISTS (SELECT {+index (si_horario_premio idx_si_horario_premio2)} f_sorteo FROM si_horario_premio WHERE f_sorteo = vFechaHoy))
		OR (vFechaHoy <> pFechaActual) THEN
			LET v_Codret = '118';
			LET vMensaje = 'ERROR DE DATOS';
			RETURN v_Codret, vRetorno, vMensaje;    -- Hoy no es día de entrega de premios
	END IF;
	
    IF pTipoOperacion = 11 OR pTipoOperacion = 10 THEN                           -- Validacion del tipo de Operacion
	
	    IF pEtapa = '1' THEN -- BGM 3-Sep-2010: se valida si es la etapa 1 de asignación de premio
	    
	            EXECUTE PROCEDURE "informix".validarclienteempleado(1, pNumCliente)
                           INTO cCodRet;
                       
          IF cCodRet = '000' THEN
			 LET v_Codret = '118';
			 LET vMensaje = 'EL CLIENTE ES EMPLEADO DE BANCO';
			 RETURN v_Codret, vRetorno, vMensaje;           -- Termina proceso del SP
		  END IF;
        END IF;  
          
          
              SELECT {+index (si_premios_suc idx_si_premiossuc)} cve_sorteo, estatus, id_sucursal, id_premio, folio_premio
              INTO vCve_sorteo, vEstatus, vId_sucursal, vId_premio, vfolio_premio
              FROM bdinteg:si_premios_suc
              WHERE cve_sorteo = pClaveSort
              AND id_sucursal = pIdSucursal
              AND id_premio = pIdPremio
              AND folio_premio = pFolioPremio;

              IF (vCve_sorteo IS NULL OR vCve_sorteo = '') OR
                 (vEstatus IS NULL OR vEstatus = '') OR
                 (vId_sucursal IS NULL OR vId_sucursal = '') OR
                 (vId_premio IS NULL OR  vId_premio = '') OR
                 (vFolio_premio IS NULL OR vFolio_premio = '') THEN         -- Validacion de datos
                   LET v_Codret = '117';
                   LET vMensaje = 'ERROR DE DATOS';
                   RETURN v_Codret, vRetorno, vMensaje;    -- Termina proceso del SP
              END IF;

		    IF vEstatus = '2' AND pEtapa = '1' THEN                             -- Validacion ya fue entregado el premio
               LET v_Codret = '119';
               LET vMensaje = 'EL PREMIO NO EXISTE O YA FUE ASIGNADO';
               RETURN v_Codret, vRetorno, vMensaje;           -- Termina proceso del SP
            END IF;
		
		IF vEstatus = '1' and pEtapa = '1' THEN  -- BGM 3-Sep-2010: se agrega validación de Etapa para confirmar asignación de premio
            UPDATE {+index (si_premios_suc idx_si_premiossuc)} bdinteg:si_premios_suc   -- Actualiza el estatus del premio como ya entregado
            SET estatus = '2', tipo_operacion = pTipoOperacion, Num_cte = pNumCliente,
                foliosuc = pFolioOperacion, Importe = pImporte, f_asignado = pFechaActual,
                usr_registro = pUsuario,impreso = '0'
            WHERE cve_sorteo = vCve_sorteo
            AND id_sucursal = pIdSucursal
            AND id_premio = pIdPremio
            AND folio_premio = pFolioPremio;
        END IF;
		
        IF vEstatus = '2' and pEtapa = '2' THEN  -- BGM 3-Sep-2010: se agrega validación de Etapa para confirmar impresión de ticket
            UPDATE {+index (si_premios_suc idx_si_premiossuc)} bdinteg:si_premios_suc   
            SET impreso = '1'
            WHERE cve_sorteo = vCve_sorteo
            AND id_sucursal = pIdSucursal
            AND id_premio = pIdPremio
            AND folio_premio = pFolioPremio;
        END IF;

        IF (vEstatus = '1') AND (pEtapa = '2') THEN
           LET v_Codret = '119';
            LET vMensaje = 'EL PREMIO NO EXISTE O YA FUE ASIGNADO';
            RETURN v_Codret, vRetorno, vMensaje;
        END IF;
		
	ELSE -- BGM 3-Sep-2010: si el tipo de operación no es 10 ni 11, hay un error en datos
        LET v_Codret = '117';
        LET vMensaje = 'ERROR DE DATOS';
        RETURN v_Codret, vRetorno, vMensaje;
    END IF;
	
END

    RETURN v_Codret, vRetorno, vMensaje;                   -- Termina proceso del SP

END PROCEDURE;