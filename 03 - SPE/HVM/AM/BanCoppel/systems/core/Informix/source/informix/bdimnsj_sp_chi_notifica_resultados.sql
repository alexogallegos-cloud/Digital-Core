CREATE PROCEDURE "informix".sp_chi_notifica_resultados (
		p_ccodproc CHAR(3), p_cstatusproc CHAR(5)
	)
	RETURNING CHAR(5) AS codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Creado por: Isaac Flores Ruiz
	--Fecha de creación: 23/03/2021
	--Peticion: RQM 10 1404
	--Modificado por: Isaac Flores Ruiz
	--Fecha de modificación: 08/07/2021, 24/11/2021
	--Modificación: Obtención de fecha current en lugar de fecha sistema de bdicred:sd_fechas.
	--				Se agrega armado formato de fecha para su envio a plantilla.
	--BD: bdimnsj
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err             INTEGER;
    DEFINE     	isam_err            INTEGER;
    DEFINE     	error_info          CHAR(40);
    DEFINE     	cod_ret             CHAR(5);
	DEFINE	   	mensaje_ret			VARCHAR(255);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE 		v_cempresa			CHAR(3);
	DEFINE 		v_cdesc_area		VARCHAR(20);
	DEFINE 		v_cnombre_proc		VARCHAR(60);
	DEFINE 		v_ctipoMsj			CHAR(1);
	DEFINE 		v_cidMsj			VARCHAR(10);
	DEFINE 		v_cidPlantilla		VARCHAR(12);
	DEFINE 		v_cnumclt			VARCHAR(20);
	DEFINE 		v_cnumcta			VARCHAR(20);
	DEFINE 		v_cnumTarjeta		VARCHAR(16);
	DEFINE 		v_ctipoproc			CHAR(1);
	DEFINE 		v_cstr1				CHAR(30);
	DEFINE 		v_cstr2				VARCHAR(30);
	DEFINE 		v_cstr3				VARCHAR(30);
	DEFINE 		v_cstr4				VARCHAR(30);
	DEFINE 		v_cstr5				VARCHAR(150);
	DEFINE 		v_cstr6				VARCHAR(100);
	DEFINE 		v_cstr7				VARCHAR(60);
	DEFINE 		v_cstr8				VARCHAR(60);
	DEFINE 		v_cstr9				VARCHAR(15);
	DEFINE 		v_cstr10			VARCHAR(100);
	DEFINE 		v_ccorreo_alterno	VARCHAR(100);
	DEFINE 		v_ccelular_alterno	VARCHAR(10);
	DEFINE 		v_cdia				CHAR(2);
	DEFINE 		v_cmes				CHAR(2);
	DEFINE 		v_cyear				CHAR(4);
	DEFINE 		v_cfechahoy			CHAR(10);
	DEFINE 		v_mimporte1			MONEY (16,2);
	DEFINE 		v_mimporte2			MONEY (16,2);
	DEFINE 		v_mimporte3			MONEY (16,2);
	DEFINE 		v_mimporte4			MONEY (16,2);
	DEFINE 		v_mimporte5			MONEY (16,2);
	DEFINE 		v_dfecha1			DATETIME YEAR TO FRACTION(3);
	DEFINE 		v_dfecha2			DATETIME YEAR TO FRACTION(3);
	DEFINE 		v_id_registro		INTEGER;
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      		= 0;
	LET 		isam_err     		= 0;
    LET 	   	cod_ret 			= '00000'; 
	LET 	   	mensaje_ret 		= 'PROCESO EXITOSO';
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 		v_cempresa			= '001';
	LET 		v_cdesc_area		= '';
	LET 		v_cnombre_proc		= '';
	LET 		v_ctipoMsj			= '';
	LET 		v_cidMsj			= '';
	LET 		v_cidPlantilla		= '';
	LET 		v_cnumclt			= '';
	LET 		v_cnumcta			= '';
	LET 		v_cnumTarjeta		= '';
	LET 		v_ctipoproc			= '';
	LET 		v_cstr1				= '';
	LET 		v_cstr2				= '';
	LET 		v_cstr3				= '';
	LET 		v_cstr4				= '';
	LET 		v_cstr5				= '';
	LET 		v_cstr6				= '';
	LET 		v_cstr7				= '';
	LET 		v_cstr8				= '';
	LET 		v_cstr9				= '';
	LET 		v_cstr10			= '';
	LET 		v_ccorreo_alterno	= '';
	LET 		v_ccelular_alterno	= '';
	LET 		v_cdia				= LPAD(DAY(DATE(1)), 2, '0');
	LET 		v_cmes				= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		v_cyear				= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		v_cfechahoy			= '';
	LET 		v_mimporte1			= 0.0;
	LET 		v_mimporte2			= 0.0;
	LET 		v_mimporte3			= 0.0;
	LET 		v_mimporte4			= 0.0;
	LET 		v_mimporte5			= 0.0;
	LET 		v_dfecha1			= today;
	LET 		v_dfecha2			= today;
	LET 		v_id_registro		= 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
    BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '00000';	
								
				ROLLBACK WORK;
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
	    --SET DEBUG FILE TO '/tmp/sp_chi_notifica_resultados.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
		
		SELECT LPAD(YEAR(CURRENT), 4, '0'), LPAD(MONTH(CURRENT), 2, '0'), LPAD(DAY(CURRENT), 2, '0')
		INTO v_cyear, v_cmes, v_cdia
		FROM bdicred:sd_fechas 
		WHERE empresa = '001';
		LET v_cfechahoy = v_cdia || '/' || v_cmes || '/' || v_cyear;
				
		FOREACH WITH HOLD
			
			SELECT desc_area, pTipoMsj, pIdMsj, pIdPlantilla, pNumclt, 
				pNumcta, pNumTarjeta, pTipoproc, pStr1, pStr2, 
				pStr3, pStr4, pStr5, pStr6, pStr7, 
				pStr8, pStr9, pStr10, pcorreo_alterno, pcelular_alterno, 
				pImporte1, pImporte2, pImporte3, pImporte4, pImporte5, 
				pfecha1, pfecha2, nombre_proceso
			INTO v_cdesc_area, v_ctipoMsj, v_cidMsj, v_cidPlantilla, v_cnumclt, 
				v_cnumcta, v_cnumTarjeta, v_ctipoproc, v_cstr1, v_cstr2, 
				v_cstr3, v_cstr4, v_cstr5, v_cstr6, v_cstr7, 
				v_cstr8, v_cstr9, v_cstr10, v_ccorreo_alterno, v_ccelular_alterno, 
				v_mimporte1, v_mimporte2, v_mimporte3, v_mimporte4, v_mimporte5, 
				v_dfecha1, v_dfecha2, v_cnombre_proc
			FROM bdimnsj:"informix".mnsj_chi_notifica_resultados
			WHERE empresa = v_cempresa
				AND codigo_proceso = p_ccodproc
				AND status_proceso = p_cstatusproc
				AND status = '1'
										
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento ( 
				TRIM(v_ctipoMsj), v_cidMsj, v_cidPlantilla, v_cnumclt, v_cnumcta, 
				v_cnumTarjeta, TRIM(v_ctipoproc), TRIM(v_cstr1) || ' ' || v_cdesc_area, v_cstr2, v_cstr3 || ' ', 
				TRIM(v_cfechahoy), v_cnombre_proc || ' ' || v_cstr5, v_cstr6, v_cstr7, v_cstr8, 
				TRIM(v_cfechahoy), v_cstr10, v_ccorreo_alterno, v_ccelular_alterno, TRIM(REPLACE(CAST(v_mimporte1 AS CHAR(18)), '$', '')), 
				TRIM(REPLACE(CAST(v_mimporte2 AS CHAR(18)), '$', '')), TRIM(REPLACE(CAST(v_mimporte3 AS CHAR(18)), '$', '')), TRIM(REPLACE(CAST(v_mimporte4 AS CHAR(18)), '$', '')), TRIM(REPLACE(CAST(v_mimporte5 AS CHAR(18)), '$', '')), v_dfecha1, 
				v_dfecha2
			)
			INTO cod_ret;
			
			SELECT MAX(id_registro)
			INTO v_id_registro
			FROM bdimnsj:"informix".mnsj_chi_notifica_resultados_hist
			WHERE id_registro > 0 
				AND fecha_envio IS NOT NULL;
			
			INSERT INTO bdimnsj:"informix".mnsj_chi_notifica_resultados_hist VALUES (
				(NVL(v_id_registro, 0) + 1), v_cfechahoy, cod_ret,
				TRIM(v_ctipoMsj), v_cidMsj, v_cidPlantilla, v_cnumclt, v_cnumcta, 
				v_cnumTarjeta, TRIM(v_ctipoproc), TRIM(v_cstr1) || ' ' || v_cdesc_area, v_cstr2, v_cstr3 || ' ', 
				TRIM(v_cfechahoy), v_cnombre_proc || ' ' || v_cstr5, v_cstr6, v_cstr7, v_cstr8, 
				TRIM(v_cfechahoy), v_cstr10, v_ccorreo_alterno, v_ccelular_alterno, TRIM(REPLACE(CAST(v_mimporte1 AS CHAR(18)), '$', '')), 
				TRIM(REPLACE(CAST(v_mimporte2 AS CHAR(18)), '$', '')), TRIM(REPLACE(CAST(v_mimporte3 AS CHAR(18)), '$', '')), TRIM(REPLACE(CAST(v_mimporte4 AS CHAR(18)), '$', '')), TRIM(REPLACE(CAST(v_mimporte5 AS CHAR(18)), '$', '')), v_dfecha1, 
				v_dfecha2
			);
			
		END FOREACH;
		
		IF cod_ret <> '00000' THEN
			LET cod_ret = '11111';
		END IF;

		RETURN cod_ret;	
    END	
END PROCEDURE;