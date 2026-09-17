CREATE PROCEDURE "informix".sp_detallereportetransaccionesprogramadas(p_NumCte CHAR(20), p_cve_pagoprog CHAR(10), p_TipoRep SMALLINT, siRegistros SMALLINT)
RETURNING
     CHAR(5), ---cod_ret
     DATE, ---fecha de programacion
     MONEY(16,2), ---Importe
     CHAR(30), ---estado
     DATE, ---fecha de estado
     DATE, ---fecha de cancelacion
     INTEGER; --- consecutivo

---  Declaraciones
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
    DEFINE v_Importe            MONEY(16,2);
    DEFINE v_Estado             CHAR(30);
    DEFINE v_FecEstado          DATE;
    DEFINE v_FecCanc            DATE;
    DEFINE v_FecProg            DATE;
    DEFINE v_Consecutivo        INTEGER;
    DEFINE siCiclo              SMALLINT;
	--DEFINE vcMsgError           CHAR(50);
	DEFINE cHoraActual			DATETIME HOUR TO SECOND;
--- Inicializaciones
    LET v_cod_ret            = "00000";
    LET iSqlErr              = 0;
    LET iSamErr              = 0;
    LET vDesErr              = "";
    LET v_Importe            = 0;
    LET v_Estado             = "";
    LET v_FecEstado          = "";
    LET v_FecCanc            = "";
    LET v_FecProg            = "";
    LET v_Consecutivo        = 0;
    LET siCiclo              = 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

    ---SET DEBUG FILE TO "/tmp/has/sp_DetalleReporteTransaccionesProgramadas.out";
    ---TRACE ON;

    IF p_TipoRep = 2 THEN
    --- CONSULTA DE TRANSACCIONES PROGRAMADAS
    IF EXISTS (SELECT  ppe.fecha_prog FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
                WHERE ppe.cve_pagoprog = pp.cve_pagoprog AND ppe.cve_pagoprog  = p_cve_pagoprog AND pp.num_cte = p_NumCte AND ppe.estado = e.cve_estado) THEN
        FOREACH
            SELECT  ppe.fecha_prog, pp.importe, e.descripcion, decode(ppe.estado,'02',ppe.fecha_cancela,'06',ppe.fecha_cancela,'05',ppe.fecha_aplic)
            INTO v_FecProg, v_Importe, v_Estado, v_FecEstado
            FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
            WHERE ppe.cve_pagoprog = pp.cve_pagoprog
            AND ppe.cve_pagoprog  = p_cve_pagoprog
            AND pp.num_cte = p_NumCte
            AND ppe.estado = e.cve_estado
            ORDER BY ppe.consecutivo

            IF v_FecProg IS NULL THEN
                LET v_FecProg = '01/01/1900' :: DATE;
            END IF

            IF v_FecEstado IS NULL THEN
                LET v_FecEstado = '01/01/1900' :: DATE;
            END IF

            LET siCiclo = siCiclo + 1;

            IF siCiclo <= siRegistros THEN
            CONTINUE FOREACH;
            END IF;

            RETURN v_cod_ret, v_FecProg, v_Importe, v_Estado, v_FecEstado, '01/01/1900'::DATE,0 WITH RESUME;
         END FOREACH;
    ELSE
	
			LET v_cod_ret = '10142';
			--LET vcMsgError = 'CLAVE DE PROGRAMACION NO EXISTE, ERROR AL IMPRIMIR COMPROBANTE DE CONSULTA TRANSACCION PROGRAMADA, CLIENTE: ' ||p_NumCte ||', CLAVE DE PROGRAMACION: ' || p_cve_pagoprog;
			LET cHoraActual = CURRENT HOUR TO SECOND;
		
			INSERT INTO bdiprog:pp_errores(cod_error,descripcion,fecha,hora)
			VALUES (v_cod_ret,'[DRTP] NO SE ENCONTRO DETALLE DE PROGRAMACION,  CONSULTA TRANSACCION, T. REPORTE:-' || p_TipoRep || '-, CTE: -' ||p_NumCte ||'-, CVE: -' || p_cve_pagoprog || '-',CURRENT::DATE,cHoraActual);
			
        RETURN v_cod_ret, '01/01/1900'::DATE, 0, '', '01/01/1900'::DATE, '01/01/1900'::DATE,0 ;
    END IF

    ELIF p_TipoRep = 3 THEN
    --- CANCELACION DE TRANSACIONES PROGRAMADAS
    IF EXISTS (SELECT  ppe.fecha_prog FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
        WHERE ppe.cve_pagoprog = pp.cve_pagoprog AND ppe.cve_pagoprog  = p_cve_pagoprog AND pp.num_cte = p_NumCte
        AND ppe.estado = e.cve_estado AND ppe.estado = '02') THEN
        FOREACH
            SELECT  ppe.fecha_prog, pp.importe, e.descripcion,ppe.fecha_cancela
            INTO v_FecProg, v_Importe, v_Estado, v_FecCanc
            FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
            WHERE ppe.cve_pagoprog = pp.cve_pagoprog
            AND ppe.cve_pagoprog  = p_cve_pagoprog
            AND pp.num_cte = p_NumCte
            AND ppe.estado = e.cve_estado
            AND ppe.estado = '02'
            ORDER BY ppe.consecutivo

            IF v_FecProg IS NULL THEN
                LET v_FecProg = '01/01/1900' :: DATE;
            END IF

            IF v_FecCanc IS NULL THEN
                LET v_FecCanc = '01/01/1900' :: DATE;
            END IF

            LET siCiclo = siCiclo + 1;

            IF siCiclo <= siRegistros THEN
            CONTINUE FOREACH;
            END IF;

            RETURN v_cod_ret, v_FecProg, v_Importe, v_Estado, '01/01/1900'::DATE, v_FecCanc, 0 WITH RESUME;
         END FOREACH;
    ELSE
	
			LET v_cod_ret = '10142';
			--LET vcMsgError = 'CLAVE DE PROGRAMACION NO EXISTE, ERROR AL IMPRIMIR COMPROBANTE DE CANCELACION, CLIENTE: ' ||p_NumCte ||', CLAVE DE PROGRAMACION: ' || p_cve_pagoprog;
			LET cHoraActual = CURRENT HOUR TO SECOND;
		
			INSERT INTO bdiprog:pp_errores(cod_error,descripcion,fecha,hora)
			VALUES (v_cod_ret,'[DRTP] NO SE ENCONTRO DETALLE DE PROGRAMACION,  CANCELACION TRANSACCION, T. REPORTE:-' || p_TipoRep || '-, CTE: -' ||p_NumCte ||'-, CVE: -' || p_cve_pagoprog || '-',CURRENT::DATE,cHoraActual);
			
        RETURN v_cod_ret, '01/01/1900' :: DATE, 0, '', '01/01/1900'::DATE, '01/01/1900'::DATE, 0;
    END IF

    ELIF p_TipoRep = 1 THEN
    --- COMPROBANTE DE TRANSACCIONES PROGRAMADAS
    IF EXISTS (SELECT  ppe.fecha_prog FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
                WHERE ppe.cve_pagoprog = pp.cve_pagoprog AND ppe.cve_pagoprog  = p_cve_pagoprog  AND pp.num_cte = p_NumCte AND ppe.estado = e.cve_estado) THEN
        FOREACH
            SELECT  ppe.fecha_prog, pp.importe, e.descripcion, ppe.fecha_insert, ppe.consecutivo
            INTO v_FecProg, v_Importe, v_Estado, v_FecEstado, v_Consecutivo
            FROM  bdiprog: pp_pagospend ppe, bdiprog: pp_pagoprog pp, bdiprog: pp_estados e
            WHERE ppe.cve_pagoprog = pp.cve_pagoprog
            AND ppe.cve_pagoprog  = p_cve_pagoprog
            AND pp.num_cte = p_NumCte
            AND ppe.estado = e.cve_estado
            ORDER BY ppe.consecutivo

            IF v_FecProg IS NULL THEN
                LET v_FecProg = '01/01/1900' :: DATE;
            END IF

            IF v_FecEstado IS NULL THEN
                LET v_FecEstado = '01/01/1900' :: DATE;
            END IF

            LET siCiclo = siCiclo + 1;

            IF siCiclo <= siRegistros THEN
            CONTINUE FOREACH;
            END IF;
		
            RETURN v_cod_ret, v_FecProg, v_Importe, v_Estado, v_FecEstado, '01/01/1900'::DATE, v_Consecutivo WITH RESUME;
         END FOREACH;
    ELSE
			LET v_cod_ret = '10142';
			--LET vcMsgError = 'CLAVE DE PROGRAMACION NO EXISTE, ERROR AL IMPRIMIR COMPROBANTE DE ALTA DE PROGRAMACION, CLIENTE: ' ||p_NumCte ||', CLAVE DE PROGRAMACION: ' || p_cve_pagoprog;
			LET cHoraActual = CURRENT HOUR TO SECOND;
		
			INSERT INTO bdiprog:pp_errores(cod_error,descripcion,fecha,hora)
			VALUES (v_cod_ret,'[DRTP] NO SE ENCONTRO DETALLE DE PROGRAMACION,  ALTA TRANSACCION, T. REPORTE:-' || p_TipoRep || '-, CTE: -' ||p_NumCte ||'-, CVE: -' || p_cve_pagoprog || '-',CURRENT::DATE,cHoraActual);
			
        RETURN v_cod_ret, '01/01/1900'::DATE, 0, '', '01/01/1900'::DATE, '01/01/1900'::DATE, 0;
    END IF

    END IF

END;
--##############################################################################
--## Procedimiento   : sp_DetalleReporteTransaccionesProgramadas
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--##Descripcion : Consulta el detalle de la programacion para el reporte de consulta, cancelacion y comprobante de transacciones
--##############################################################################
END PROCEDURE

DOCUMENT
'AUTOR : José Angel Rodriguez',
'MODIFICACION: Se modifica para que cuando no existan registros asociados a la clave de programacion y cliente recibido como parámetro .',
'             el SP regrese un codigo de retorno indicando el estado del proceso',
'             las caracteristicas de las mismas solicitadas por la misma empresa ',
'EQUIPO DE TRABAJO: Incidencias',
'EJECUTADO O LLAMADO POR: PLPAGPRO.EXE',
'FECHA : 04/NOV/2009',
'VERSION: 20091104.1636',
'BD    : bdiprog';

CREATE PROCEDURE "informix".sp_consultacuentasdestino2(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20), ---cuenta
	 CHAR(100), ---nombre
	 CHAR(50), ---banco
	 CHAR(2), ---compaÃ±ia celular
	 CHAR(10), ---numero celular
	 CHAR(100), ---correo electronico
	 CHAR(2), ---cve cuenta
     CHAR(20), ---desc cuenta
     CHAR(13); ---rfc

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(100);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;

	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	
	SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_ConsultaCuentasDestino2.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  BDIPROG:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	SELECT banco|| "  " ||descripcion
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";


	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
            IF TRIM(p_CvePago) = '04' THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert
                    FROM bdiprog:"informix".pp_ctasterceros ct, pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    --AND ct.cve_banco = '000'
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'

--                    LET v_ContReg = v_ContReg + 1;

--                  IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                       CONTINUE FOREACH;
--                    END IF;
					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							CONTINUE FOREACH;
						END IF;
					END IF;

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
                END FOREACH;
            ELSE
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||b.descripcion, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:si_bancos b, pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
                    UNION
                    --SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','','1900-01-01'::date, current hour to second
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','',mdy(1,1,1900), current hour to second
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05'
					ORDER BY ct.descrip_cta, ct.nombre

--                    LET v_ContReg = v_ContReg + 1;

--                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                        CONTINUE FOREACH;
--                    END IF;
					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
					IF v_Canal = '03' THEN
						LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							CONTINUE FOREACH;
						END IF;
					END IF;
					
                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;					

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
                END FOREACH;
            END IF;
        ELSE
            IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta Where numcte == p_NumCte )  THEN
                FOREACH
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,''
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago ="05"

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc  WITH RESUME;
                END FOREACH;
            ELSE
                SELECT cod_ret
                INTO v_cod_ret
                FROM  BDIPROG:"informix".PP_MENSAJES
                WHERE cve_mensaje = "13";

                RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
            END IF
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
--##############################################################################
--## Procedimiento   : sp_consultacuentasdestino2
--## Version         : 1.0
--## Creado por      : Pedro Portugal
--## Fecha creacion  : 23 de Mayo de 2017
--## Descripcion     : Consulta las cuentas destino que tiene registrado un cliente
--##############################################################################
END PROCEDURE;