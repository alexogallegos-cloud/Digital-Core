CREATE PROCEDURE "informix".sp_consulta_matcheshuellacte(pNvoCteBco CHAR(20))

	--RETORNOS-
	RETURNING
	CHAR(6)      AS codigo_ret,
	CHAR(20)     AS numcte_match,
	CHAR(4)      AS empresa,
	CHAR(25)     AS descripcion,
	CHAR(4)      AS sucursal,
	SMALLINT     AS bandera;

	--DECLARACION DE VARIABLES--
	DEFINE iSql_err		    INTEGER; 
	DEFINE cCodret		    CHAR(6);
	DEFINE cTicket          CHAR(20);
	DEFINE cClienteMatch    CHAR(20);
	DEFINE cEmpresa         CHAR(4);
	DEFINE cDescripcion     CHAR(25);
	DEFINE sCteExiste       SMALLINT;
	DEFINE cSucursal        CHAR(4);
	DEFINE cSecuenciacpl	CHAR(2);
	DEFINE vscountonline	  INTEGER;

	--INICIALIZACION DE VARIABLES--
	LET iSql_err		     = 0;
	LET cCodret		         = '000000';
	LET cTicket              = '';
	LET cClienteMatch        = '';
	LET cEmpresa             = '';
	LET cDescripcion         = '';
	LET sCteExiste           = 0;
	LET cSucursal            = '';
	LET vscountonline = 0;

	--INICIO--
	BEGIN
		--CONTROL DE ERRORES--
		ON EXCEPTION SET iSql_err 
			IF iSql_err <> 0 THEN
				LET cCodret = iSql_err;
				RETURN TRIM(cCodret), TRIM(NVL(cClienteMatch,'')), TRIM(NVL(cEmpresa,'')), TRIM(NVL(cDescripcion,'')),NVL(cSucursal,''), NVL(sCteExiste,0);
			END IF;
		END EXCEPTION;
			
		--SET DEBUG FILE TO '/informix/cristo/sp_consulta_matcheshuellacte.out';
		--TRACE ON;
		
		  SET ISOLATION TO DIRTY READ;
		  SET LOCK MODE TO WAIT 3;
		  
		 --************************************************************************************
		 ---------------****************BLOQUE DE CONSULTA*************************************
		 --************************************************************************************

			--SE OBTIENE LA SUCURSAL
			SELECT LIMIT 1 {+AVOID_FULL("informix".si_bitacora_comparaciones)} sucursal 
			INTO cSucursal
			FROM "informix".si_bitacora_comparaciones
			WHERE numcte = TRIM(pNvoCteBco)
			AND status_alerta not in ('3','4');
			
			
			--SE OBTIENE EL TICKET DEL CLIENTE
			SELECT ticket {+AVOID_FULL("informix".si_huella_linea)}
			INTO cTicket
			FROM "informix".si_huella_linea
			WHERE numcte = TRIM(pNvoCteBco)
			AND status_consulta = '3'
			AND respuesta_msj601= '1';
			
			--NO HAY RESPUESTA DE LA COMPARACION DE HUELLAS
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCodret = '000001'; 
				RETURN TRIM(cCodret), TRIM(NVL(cClienteMatch,'')), TRIM(NVL(cEmpresa,'')), TRIM(NVL(cDescripcion,'')),NVL(cSucursal,''), NVL(sCteExiste,0);
			END IF;
			
			SELECT  count(*) into vscountonline FROM
			"informix".si_huella_linea_resultado			
			WHERE ticket = TRIM(cTicket);
			
			IF  vscountonline > 0 THEN
				FOREACH
						--SE OBTIENE CLIENTE/EMPLEADOMATCH Y EMPRESA USANDO EL NUMERO DE TICKET PREVIAMENTE OBTENIDO
						
						SELECT {+AVOID("informix".si_huella_linea_resultado)} cliente::CHAR(20), empresa ,max(secuenciacpl)
						INTO cClienteMatch, cEmpresa,cSecuenciacpl
						FROM "informix".si_huella_linea_resultado
						WHERE ticket = TRIM(cTicket)
						AND cliente not in  ('0',TRIM(pNvoCteBco))
						AND num_mensaje = '602'
						group by cliente,empresa

						
						--EN CASO QUE TENGA EMPRESA ASIGNADA, SE VERIFICA SU DESCRIPCION
						SELECT descripcion 
						INTO cDescripcion
						FROM "informix".si_empresa_huella
						WHERE numempresa = TRIM(cEmpresa);

						--EN CASO QUE NO TENGA EMPRESA ASIGNADA SE DEJA LA DESCRIPCION EN BLANCO
						IF cDescripcion IS NULL THEN
							LET cDescripcion = ''; 
						END IF;
						
						--SE REALIZA UN FORMAT PARA NUMERO DE CLIENTE BANCOPPEL.
						IF cEmpresa = '5' THEN
							LET cClienteMatch = LPAD(TRIM(cClienteMatch),9,'0');
							IF EXISTS(SELECT {+INDEX("informix".si_fuscliente idx_fcte)} numcte from "informix".si_fuscliente where numcte=cClienteMatch and empresa='001') THEN
								CONTINUE FOREACH;
							END IF;
							
						END IF;
						
						--EN CASO QUE EL NUEVO CLIENTE BANCO Y EL CLIENTE MATCH EXISTAN EN LA SI_BITACORA_DICTAMENTES SE PRENDE LA BANDERA
						IF EXISTS (SELECT numcte FROM "informix".si_bitacora_dictamenes WHERE numcte = pNvoCteBco AND numcte_coinc = cClienteMatch) THEN
							LET sCteExiste = 1;
						
						--SE AMARRA QUE ENTRE AL ELSE EN CASO QUE SE QUEDE PEGADO UN VALOR DE LA VUELTA ANTERIOR DEL FOREACH
						ELSE 
							LET sCteExiste = 0; 
						END IF;
						
						RETURN TRIM(cCodret), TRIM(NVL(cClienteMatch,'')), TRIM(NVL(cEmpresa,'')), TRIM(NVL(cDescripcion,'')),NVL(cSucursal,''), NVL(sCteExiste,0) WITH RESUME;
				END FOREACH;
				
				
			ELSE	
				--inicia huella hist
						FOREACH
						--SE OBTIENE CLIENTE/EMPLEADOMATCH Y EMPRESA USANDO EL NUMERO DE TICKET PREVIAMENTE OBTENIDO
						
						SELECT {+AVOID("informix".si_huella_linea_resultado_hist)} cliente::CHAR(20), empresa ,max(secuenciaspl)
						INTO cClienteMatch, cEmpresa,cSecuenciacpl
						FROM "informix".si_huella_linea_resultado_hist
						WHERE ticket = TRIM(cTicket)
						AND cliente not in  ('0',TRIM(pNvoCteBco))
						AND num_mensaje = '602'
						group by cliente,empresa

						
						--EN CASO QUE TENGA EMPRESA ASIGNADA, SE VERIFICA SU DESCRIPCION
						SELECT descripcion 
						INTO cDescripcion
						FROM "informix".si_empresa_huella
						WHERE numempresa = TRIM(cEmpresa);

						--EN CASO QUE NO TENGA EMPRESA ASIGNADA SE DEJA LA DESCRIPCION EN BLANCO
						IF cDescripcion IS NULL THEN
							LET cDescripcion = ''; 
						END IF;
						
						--SE REALIZA UN FORMAT PARA NUMERO DE CLIENTE BANCOPPEL.
						IF cEmpresa = '5' THEN
							LET cClienteMatch = LPAD(TRIM(cClienteMatch),9,'0');
							IF EXISTS(SELECT {+INDEX("informix".si_fuscliente idx_fcte)} numcte from "informix".si_fuscliente where numcte=cClienteMatch and empresa='001') THEN
								CONTINUE FOREACH;
							END IF;
							
						END IF;
						
						--EN CASO QUE EL NUEVO CLIENTE BANCO Y EL CLIENTE MATCH EXISTAN EN LA SI_BITACORA_DICTAMENTES SE PRENDE LA BANDERA
						IF EXISTS (SELECT numcte FROM "informix".si_bitacora_dictamenes WHERE numcte = pNvoCteBco AND numcte_coinc = cClienteMatch) THEN
							LET sCteExiste = 1;
						
						--SE AMARRA QUE ENTRE AL ELSE EN CASO QUE SE QUEDE PEGADO UN VALOR DE LA VUELTA ANTERIOR DEL FOREACH
						ELSE 
							LET sCteExiste = 0; 
						END IF;
						
						RETURN TRIM(cCodret), TRIM(NVL(cClienteMatch,'')), TRIM(NVL(cEmpresa,'')), TRIM(NVL(cDescripcion,'')),NVL(cSucursal,''), NVL(sCteExiste,0) WITH RESUME;
				END FOREACH;
				--termina huella hist
			END IF;
		--OCURRIO UN PROBLEMA DE AMBIENTACION
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000002'; 
			RETURN TRIM(cCodret), TRIM(NVL(cClienteMatch,'')), TRIM(NVL(cEmpresa,'')), TRIM(NVL(cDescripcion,'')),NVL(cSucursal,''), NVL(sCteExiste,0);
		END IF;		
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÃ?Â?N: PROCEDIMIENTO QUE RECIBE NÃ?Â?MERO DE CLIENTE Y VERIFICA SI HA HABIDO RESPUESTA DE LA COMPARACION DE HUELLAS, DE SER ASÃ?Â REGRESA LOS DISTINTOS NUMEROS DE CLIENTE RELACIONADOS A LA MISMA PERSONA QUE TIENEN ALGUNA SITUACION, O BIEN QUE SON EMPLEADOS DE ALGUNA EMPRESA DEL GRUPO COPPEL. EN CASO DE QUE SEA EMPLEADO EL PROCEDIMIENTO REGRESARA UNA BANDERA ENCENDIDA (1), CASO CONTRARIO REGRESARA UN CERO (0).',
'FECHA DE CREACIÃ?Â?N: 06 DE NOVIEMBRE DE 2013',
'BASE DE DATOS: BDINTEG',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 20131106.1900',
'DESCRIPCIÃ?Â?N: SE DESCARTAN MATCH DUPLICADOS Y MATCH CON EL MISMO CLIENTE DE CONSULTA',
'FECHA DE MODIFICACION: 03/AGO/2015',
'DESCRIPCIÃ?Â?N: SE SEPARAN CONSULTA DE SUCURSAL Y TICKET DEBIDO A ALERTAS DUPLICADAS',
'FECHA DE MODIFICACION: 21/SEP/2015',
'BASE DE DATOS: BDINTEG',
'MODIFICADO: CRISTO LUGO';

CREATE PROCEDURE "informix".sp_verifica_cel_tarjper(pNumCte CHAR(9), pNumCel CHAR(10) )
RETURNING CHAR(5), INTEGER  ;

DEFINE sCodRet		CHAR(5);
DEFINE iVerificado  INTEGER;
DEFINE iVerificado2  INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE iDias        INTEGER;

LEt sCodRet     =   '00000';
LET iVerificado =   0;
LET iVerificado2 =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;
LET iDias       =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iVerificado;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/scarlett/sp_valida_cel_tarjper.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
  
	-- Valida si el celular fue verificado hace mÃ¡s de 90 dÃ­as
	SELECT count(*) INTO iVerificado FROM bdinteg:si_bitsmstels 
	WHERE telefono = pNumCel AND numcte = pNumCte AND bandera = 't' AND date(fecha) < (TODAY - 90);
    
    IF iVerificado >= 1 THEN
        LET sCodRet='289';			-- Verificado hace mas de 90 dias

	END IF;

	-- Valida si el celular fue verificado en los Ãºltimos 90 dÃ­as
    SELECT count(*) INTO iVerificado2 FROM bdinteg:si_bitsmstels 
	WHERE telefono = pNumCel AND numcte = pNumCte AND bandera = 't' AND date(fecha) > (TODAY - 90);
    
    IF iVerificado2 = 0 THEN
        LET sCodRet='290';			-- No verificado
        LET iVerificado = iVerificado2;
	END IF;

    

RETURN NVL(sCodRet,'000'), NVL(iVerificado,0);

END
END PROCEDURE;