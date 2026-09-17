CREATE PROCEDURE "informix".sp_reporte_cac_compingreso(pFechaInicial CHAR(10),pFechaFinal CHAR(10))
RETURNING CHAR(6)       AS COD_RET,
		  VARCHAR(80)   AS DESCRIPCION,
		  VARCHAR(4,1)  AS cod_docto,
		  VARCHAR(50,1) AS descripcion_grupo,
		  INTEGER       AS numero_doctos,
		  DECIMAL(5,2)  AS porcentaje_total_grupos,
		  INTEGER       AS validos_grupo,
		  DECIMAL(5,2)  AS porcentaje_validos_grupo,
		  INTEGER       AS invalidos_grupo,
		  DECIMAL(5,2)  AS porcentaje_invalidos_grupo,
		  DECIMAL(5,2)  AS porcentaje_final_grupo,
		  INTEGER       AS indice_grupo;
		  		  
---DECLARACIONES
DEFINE iSqlErr			        INTEGER;
DEFINE iIsamErr			        INTEGER;
DEFINE cErrorInfo		        VARCHAR(80);
DEFINE cCodRet			        CHAR(6);
DEFINE cMensajeRet		        VARCHAR(80);
DEFINE iNumTotal		        INTEGER;
DEFINE cNomCodDoc		        VARCHAR(50,1);
DEFINE cNomGrupo		        CHAR(7);
DEFINE cCompValido		        CHAR(1);
DEFINE iNumDoc			        INTEGER;
DEFINE dPorcentaje		        DECIMAL(5,2);
DEFINE cBandExitosa		        CHAR(1);
DEFINE dtFechaInsertI           DATE;
DEFINE dtFechaInsertF           DATE;
DEFINE vNumSolic                VARCHAR(20,1);
DEFINE cComprobValido           CHAR(1);
DEFINE cRevisado                CHAR(1);
DEFINE sMesesHist               SMALLINT;
DEFINE vDescripcion             VARCHAR(50,1);
DEFINE vCodDocto                VARCHAR(4,1);
DEFINE iIdGrupo_ndg1            INTEGER;
DEFINE iIdGrupo_ndg2            INTEGER;
DEFINE iIdGrupo_ndg3            INTEGER;
DEFINE iCont_ndg1               INTEGER;
DEFINE iNum_casos_grupo1_ndg1   INTEGER;
DEFINE iNum_casos_grupo2_ndg2   INTEGER;
DEFINE iNum_casos_grupo3_ndg3   INTEGER;
DEFINE iNumRow                  INTEGER;
DEFINE iNumDoctos               INTEGER;
DEFINE dPorTt                   DECIMAL(18,2);
DEFINE iTt_v   	                INTEGER;
DEFINE dPorc_v                  DECIMAL(18,2);
DEFINE iTt_inv                  INTEGER;
DEFINE dPorc_inv                DECIMAL(18,2);
DEFINE dPorTt_gpo1              DECIMAL(18,2);
DEFINE dPorc_gpo1v              DECIMAL(18,2);
DEFINE dPorc_gpo1inv            DECIMAL(18,2);
DEFINE dPorc_totalgpo1          DECIMAL(18,2);
DEFINE dPorTt_gpo2              DECIMAL(18,2);
DEFINE dPorc_gpo2v              DECIMAL(18,2);
DEFINE dPorc_gpo2inv            DECIMAL(18,2);
DEFINE dPorc_totalgpo2          DECIMAL(18,2);
DEFINE dPorTt_gpo3              DECIMAL(18,2);
DEFINE dPorc_gpo3v              DECIMAL(18,2);
DEFINE dPorc_gpo3inv            DECIMAL(18,2);
DEFINE dPorc_totalgpo3          DECIMAL(18,2);
DEFINE iTtgpo1 					INTEGER;
DEFINE iTtgpo1_v                INTEGER;
DEFINE iTtgpo1_inv              INTEGER;
DEFINE iTtgpo2                  INTEGER;
DEFINE iTtgpo2_v                INTEGER;
DEFINE iTtgpo2_inv              INTEGER;
DEFINE iTtgpo3                  INTEGER;
DEFINE iTtgpo3_v                INTEGER;
DEFINE iTtgpo3_inv              INTEGER;
DEFINE i                        INTEGER;
DEFINE iTtgpoT					INTEGER;
DEFINE iTtgpoT_v				INTEGER;
DEFINE iTtgpoT_inv				INTEGER;

			
---INICIALIZACIONES
LET iSqlErr				     = 0;
LET iIsamErr			     = 0;
LET cErrorInfo			     = '';
LET cCodRet				     = '000000';
LET cMensajeRet			     = 'PROCESO EXITOSO';
LET iNumTotal			     = 0;
LET cNomCodDoc			     = '';
LET cNomGrupo			     = '';
LET cCompValido			     = '';
LET iNumDoc				     = 0;
LET dPorcentaje			     = 0.0;
LET cBandExitosa		     = 'N';
LET dtFechaInsertI           = DATE(1);
LET dtFechaInsertF           = DATE(1);
LET vNumSolic                = '';
LET cComprobValido           = '';
LET cRevisado                = '';
LET sMesesHist               = 0;
LET vDescripcion             = '';
LET vCodDocto                = '';
LET iIdGrupo_ndg1            = 1;
LET iIdGrupo_ndg2            = 2;
LET iIdGrupo_ndg3            = 3;
LET iCont_ndg1               = 0;
LET iNum_casos_grupo1_ndg1   = 0;
LET iNum_casos_grupo2_ndg2   = 0;
LET iNum_casos_grupo3_ndg3   = 0;
LET iNumRow                  = 0;
LET iNumDoctos               = 0;
LET dPorTt                   = 0.0;
LET iTt_v   	             = 0;
LET dPorc_v                  = 0.0;
LET iTt_inv                  = 0;
LET dPorc_inv                = 0.0;
LET dPorTt_gpo1              = 0.0;
LET dPorc_gpo1v              = 0.0;
LET dPorc_gpo1inv            = 0.0;
LET dPorc_totalgpo1          = 0.0;
LET dPorTt_gpo2              = 0.0;
LET dPorc_gpo2v              = 0.0;
LET dPorc_gpo2inv            = 0.0;
LET dPorc_totalgpo2          = 0.0;
LET dPorTt_gpo3              = 0.0;
LET dPorc_gpo3v              = 0.0;
LET dPorc_gpo3inv            = 0.0;
LET dPorc_totalgpo3          = 0.0;
LET iTtgpo1 				 = 0;
LET iTtgpo1_v                = 0;
LET iTtgpo1_inv              = 0;
LET iTtgpo2                  = 0;
LET iTtgpo2_v                = 0;
LET iTtgpo2_inv              = 0;
LET iTtgpo3                  = 0;
LET iTtgpo3_v                = 0;
LET iTtgpo3_inv              = 0;
LET i                        = 0;
LET  iTtgpoT				= 0;
LET  iTtgpoT_v				= 0;
LET  iTtgpoT_inv			= 0;

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
	  LET cCodRet = iSqlErr;
	  LET cMensajeRet = cErrorInfo;
	  RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''), NVL(vDescripcion,''), NVL(iNumDoctos,0),
		NVL(dPorTt,0), NVL(iTt_v,0), NVL(dPorc_v,0), NVL(iTt_inv,0), NVL(dPorc_inv,0),NVL(dPorTt,0),1 WITH RESUME;
   END IF;
END EXCEPTION;
/*
cod_grupo	cod_docto	descripcion
006		0008		Declaracion de Impuestos           
006		0010		Recibo de Nomina                   
006		0070		Recibo de Pensión                  
006		0071		Edo Cta. Cheques "Nomina o Pensión"
006		0073		Recibo pago de Impuestos "REPECOS" 
006		0074		Facturas de Emp "Vtas por Catalogo"
*/

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/paulq/sp_reporte_cac_compingreso.out';
--TRACE ON;

-- VALIDA QUE LOS PARAMETROS NO VENGAN VACIOS
IF NVL(pFechaInicial,'') = '' OR NVL(pFechaFinal,'') = '' THEN
	LET cCodRet = '000001';
	LET cMensajeRet = 'FALTA UNO O MAS PARAMETROS';
	RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''), NVL(vDescripcion,''), NVL(iNumDoctos,0),
	NVL(dPorTt,0), NVL(iTt_v,0), NVL(dPorc_v,0), NVL(iTt_inv,0), NVL(dPorc_inv,0),NVL(dPorTt,0),1 WITH RESUME;
END IF;

IF pFechaInicial > pFechaFinal THEN
		LET cCodRet = '000002';
		LET cMensajeRet = 'LA FECHA INICIAL ES MAYOR A LA FECHA FINAL';
		RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''), NVL(vDescripcion,''), NVL(iNumDoctos,0),
		NVL(dPorTt,0), NVL(iTt_v,0), NVL(dPorc_v,0), NVL(iTt_inv,0), NVL(dPorc_inv,0),NVL(dPorTt,0),1 WITH RESUME;
END IF;

-- SE INICIALIZA LA TABLA TEMPORAL FIJA DEL REPORTE DE COMPROBANTE DE INGRESOS
--DELETE FROM 'informix'.tmp_rlc_reportecomprobingresos;

LET dtFechaInsertI = pFechaInicial::DATE;
LET dtFechaInsertF = pFechaFinal::DATE;

--AAME INC 27 023 Derivado de la obsvr 4 se corrige el query para obtener el numero de documentos digitalizados para el cliente ya sean validos o no validos.
SELECT COUNT(d.cod_docto)
INTO iTtgpoT
FROM bdisolic:"informix".ss_solicitudes_cac a,
   bdisolic:"informix".ss_resum_scor_fin b,
   bdidigital@coppelimg_tcp:"informix".dg_tipodocumento c,
   bdidigital@coppelimg_tcp:"informix".dg_expediente d
WHERE a.empresa = b.empresa
AND a.num_solicitud = b.num_solicitud
AND c.cod_grupo = '006'
AND c.cod_docto = d.cod_docto
--AND d.cliente = a.numcte
--AND d.cod_docto = c.cod_docto
AND d.fecha_alta <=a.fecha_insert
AND a.revisado = 'S'
AND a.comprobante_valido_cac IN ('S','N')
AND d.secuencia IN (SELECT MAX(g.secuencia)
                        FROM bdidigital@coppelimg_tcp:'informix'.dg_expediente g, 
                           bdidigital@coppelimg_tcp:'informix'.dg_tipodocumento h
                        WHERE --g.cliente=a.numcte 
                       -- AND 
						g.cod_docto = h.cod_docto
                        AND h.cod_grupo = '006'
                        AND g.fecha_alta::DATE <=a.fecha_insert)
AND a.fecha_insert >= dtFechaInsertI AND a.fecha_insert <= dtFechaInsertF;   


IF iTtgpoT > 0 THEN 

	FOREACH WITH HOLD
--AAME INC 27 023 Derivado de la obsvr 4 se corrige el query para obtener el numero de documentos digitalizados para el cliente ya sean validos o no validos.
		SELECT d.cod_docto, c.descripcion,
			   SUM ( CASE WHEN b.meses_historia >= 13 THEN 1 ELSE 0 END) AS grupo1,
			   SUM ( CASE WHEN b.meses_historia >= 13 AND comprobante_valido_cac  = "S"  THEN 1 ELSE 0 END) AS grupo1_valido,
			   SUM ( CASE WHEN b.meses_historia >= 13 AND comprobante_valido_cac  = "N"  THEN 1 ELSE 0 END) AS grupo1_invalido,
			   SUM ( CASE WHEN b.meses_historia >= 6 AND b.meses_historia < 13 THEN 1 ELSE 0 END) AS grupo2,
			   SUM ( CASE WHEN b.meses_historia >= 6 AND b.meses_historia < 13 AND comprobante_valido_cac  = "S"  THEN 1 ELSE 0 END) AS grupo2_valido,
			   SUM ( CASE WHEN b.meses_historia >= 6 AND b.meses_historia < 13 AND comprobante_valido_cac  = "N"  THEN 1 ELSE 0 END) AS grupo2_invalido,
			   SUM ( CASE WHEN b.meses_historia < 6 THEN  1 ELSE 0 END) AS grupo3,     
			   SUM ( CASE WHEN b.meses_historia < 6 AND comprobante_valido_cac = "S" THEN 1 ELSE 0 END) AS grupo3_valido, 
			   SUM ( CASE WHEN b.meses_historia < 6 AND comprobante_valido_cac = "N" THEN 1 ELSE 0 END) AS grupo3_invalido
		  INTO vCodDocto, vDescripcion, iTtgpo1, iTtgpo1_v, iTtgpo1_inv, iTtgpo2, iTtgpo2_v, iTtgpo2_inv, iTtgpo3, iTtgpo3_v, iTtgpo3_inv
		  FROM "informix".ss_solicitudes_cac a,
			   "informix".ss_resum_scor_fin b,
			   bdidigital@coppelimg_tcp:"informix".dg_tipodocumento c,
			   bdidigital@coppelimg_tcp:"informix".dg_expediente d
		 WHERE a.empresa = b.empresa
            AND a.num_solicitud = b.num_solicitud
            AND c.cod_grupo = '006'
            AND c.cod_docto = d.cod_docto
            --AND d.cliente = a.numcte
            --AND d.cod_docto = c.cod_docto
            AND d.fecha_alta <=a.fecha_insert
            AND a.revisado = 'S'
            AND a.comprobante_valido_cac IN ('S','N')
            AND d.secuencia IN (SELECT MAX(g.secuencia)
                                    FROM bdidigital@coppelimg_tcp:'informix'.dg_expediente g, 
                                       bdidigital@coppelimg_tcp:'informix'.dg_tipodocumento h
                                    WHERE --g.cliente=a.numcte 
                                    --AND 
									g.cod_docto = h.cod_docto
                                    AND h.cod_grupo = '006'
                                    AND g.fecha_alta::DATE <=a.fecha_insert)
            AND a.fecha_insert >= dtFechaInsertI AND a.fecha_insert <= dtFechaInsertF
	  GROUP BY 1,2
	  ORDER BY 1
	  
	  

	  
			LET iNumRow =1;
			LET iNumDoctos =  NVL(iTtgpo1,0) + NVL(iTtgpo2,0) + NVL(iTtgpo3,0);
			--LET iNumDoctos = iTtgpoT;
			LET dPorTt = CASE WHEN iTtgpoT > 0 THEN (iNumDoctos * 100 / iTtgpoT) ELSE 0 END;
			LET iTt_v   = NVL(iTtgpo1_v,0) + NVL(iTtgpo2_v,0) + NVL(iTtgpo3_v,0);
			LET dPorc_v = CASE WHEN iTtgpoT > 0 THEN iTt_v * 100 / iTtgpoT ELSE 0 END;
			LET iTt_inv = NVL(iTtgpo1_inv,0) + NVL(iTtgpo2_inv,0) + NVL(iTtgpo3_inv,0);
			LET dPorc_inv = CASE WHEN iTtgpoT > 0 THEN iTt_inv * 100 / iTtgpoT ELSE 0 END;
			
			RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''), NVL(vDescripcion,''), NVL(iNumDoctos,0),
			NVL(dPorTt,0), NVL(iTt_v,0), NVL(dPorc_v,0), NVL(iTt_inv,0), NVL(dPorc_inv,0),NVL(dPorTt,0),1 WITH RESUME;
			
				--LET iTtgpoT =iTtgpoT +iNumDoctos;
				LET iTtgpoT_v =iTtgpoT_v +iTt_v;
				LET iTtgpoT_inv =iTtgpoT_inv +iTt_inv;
				
			
			WHILE i < 4 
				IF i = 1 THEN
					LET dPorTt_gpo1 = CASE WHEN iTtgpoT > 0 THEN (iTtgpo1 * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_gpo1v = CASE WHEN iTtgpoT > 0 THEN (iTtgpo1_v * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_gpo1inv = CASE WHEN iTtgpoT > 0 THEN (iTtgpo1_inv * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_totalgpo1 = NVL(dPorTt_gpo1,0) + NVL(dPorc_gpo1v,0) + NVL(dPorc_gpo1inv,0);
					RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''),'Grupo 1',NVL(iTtgpo1,0),NVL(dPorTt_gpo1,0),NVL(iTtgpo1_v,0),NVL(dPorc_gpo1v,0),NVL(iTtgpo1_inv,0),NVL(dPorc_gpo1inv,0),NVL(dPorc_totalgpo1,0),2 WITH RESUME;
				ELIF i = 2 THEN
					LET dPorTt_gpo2 = CASE WHEN iTtgpoT > 0 THEN (iTtgpo2 * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_gpo2v = CASE WHEN iTtgpoT > 0 THEN (iTtgpo2_v * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_gpo2inv = CASE WHEN iTtgpoT > 0 THEN (iTtgpo2_inv * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_totalgpo2 = NVL(dPorTt_gpo2,0) + NVL(dPorc_gpo2v,0) + NVL(dPorc_gpo2inv,0);
					RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''),'Grupo 2',NVL(iTtgpo2,0),NVL(dPorTt_gpo2,0),NVL(iTtgpo2_v,0),NVL(dPorc_gpo2v,0),NVL(iTtgpo2_inv,0),NVL(dPorc_gpo2inv,0),NVL(dPorc_totalgpo2,0),2 WITH RESUME;
				ELIF i = 3 THEN
					LET dPorTt_gpo3 = CASE WHEN iTtgpoT > 0 THEN (iTtgpo3 * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_gpo3v = CASE WHEN iTtgpoT > 0 THEN (iTtgpo3_v * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_gpo3inv = CASE WHEN iTtgpoT > 0 THEN (iTtgpo3_inv * 100 / iTtgpoT) ELSE 0 END;
					LET dPorc_totalgpo3 = NVL(dPorTt_gpo3,0) + NVL(dPorc_gpo3v,0) + NVL(dPorc_gpo3inv,0);
					RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''),'Grupo 3',NVL(iTtgpo3,0),NVL(dPorTt_gpo3,0),NVL(iTtgpo3_v,0),NVL(dPorc_gpo3v,0),NVL(iTtgpo3_inv,0),NVL(dPorc_gpo3inv,0),NVL(dPorc_totalgpo3,0),2 WITH RESUME;			
				END IF
				LET i = i + 1 ;
			END WHILE;      
				LET i = 0;
			-- RETURN TRIM(cCodRet), cMensajeRet, NVL(cNomCodDoc,''), NVL(cNomGrupo,''), NVL(cCompValido,''), NVL(iNumDoc,0), NVL(dPorcentaje,0.0) WITH RESUME;
			-- INSERT INTO bdisolic:'informix'.tmp_rlc_reportecomprobingresos (cod_docto, grupo, valido, num_doc)
	END FOREACH;
END IF;
--LET iNumRow = dbinfo("sqlca.sqlerrd2");
IF iNumRow > 0 THEN
	
	LET dPorTt_gpo1 = CASE WHEN iTtgpoT > 0 THEN (iTtgpoT_v * 100 / iTtgpoT) ELSE 0 END;
    LET dPorc_gpo1v = CASE WHEN iTtgpoT > 0 THEN (iTtgpoT_inv * 100 / iTtgpoT) ELSE 0 END;
	
	RETURN TRIM(cCodRet), cMensajeRet, NVL('000000',''),'TOTALES',NVL(iTtgpoT,0),NVL(100,0),
		NVL(iTtgpoT_v,0),NVL(dPorTt_gpo1,0),NVL(iTtgpoT_inv,0),NVL(dPorc_gpo1v,0),NVL(100,0),1 WITH RESUME;			
			
ELSE
	LET cCodRet = '000003';
	LET cMensajeRet = 'NO HAY DATOS PARA ESTE REPORTE, VERIFICAR FECHAS';
	RETURN TRIM(cCodRet), cMensajeRet, NVL(vCodDocto,''), NVL(vDescripcion,''), NVL(iNumDoctos,0),
	NVL(dPorTt,0), NVL(iTt_v,0), NVL(dPorc_v,0), NVL(iTt_inv,0), NVL(dPorc_inv,0),NVL(dPorTt,0),1 WITH RESUME;
END IF;
	  
END;
END PROCEDURE
