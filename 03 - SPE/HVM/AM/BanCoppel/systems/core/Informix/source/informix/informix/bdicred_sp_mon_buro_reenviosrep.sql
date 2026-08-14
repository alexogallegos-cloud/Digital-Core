CREATE PROCEDURE "informix".sp_mon_buro_reenviosrep(pModo SMALLINT, pTipoSolicitud CHAR(1), pNumSolicitud CHAR(20), pNumCte CHAR(20),pEstatus CHAR(2), pFechaIni DATE, pFechaFin DATE)


--RETORNOS-
RETURNING
CHAR(6)         AS codigo_ret,
CHAR(20)        AS retorno_01, --tiposol / numanalista
CHAR(104)       AS retorno_02, --producto /  nomanalista
CHAR(25)        AS retorno_03, --numsolic / perfilusuario
CHAR(20)        AS retorno_04, --numcte / errorcve01
CHAR(4)         AS retorno_05, --numsuc / errorcve02 
CHAR(104)       AS retorno_06, --nomcte / errorcve03
CHAR(10)        AS retorno_07, --fechasol / errorcve04
CHAR(12)        AS retorno_08, --hora / errorcve05
CHAR(4)         AS retorno_09, --estatus / errorcve06
CHAR(4)         AS retorno_10, --reenvio_exit SI o NO / errorcve07
CHAR(10)        AS retorno_11, --fecha_reenvio / errorcve08
CHAR(4)			AS retorno_12, --estatus fin / errorcve09
CHAR(80)        AS retorno_13, --motivo_reenvio/ totalbc
CHAR(104)       AS retorno_14, --nombre_analista / totalcc
CHAR(10)        AS retorno_15; -- totalglobal


--DECLARACION DE VARIABLES--
DEFINE cCodret				    CHAR(6);
DEFINE iSql_err				    INTEGER; 
DEFINE VSQL                     CHAR(5000);
DEFINE cReenvioExitoso          CHAR(1);
DEFINE cRetorno1                CHAR(20);
DEFINE cRetorno2                CHAR(104);   
DEFINE cRetorno3                CHAR(25);      
DEFINE cRetorno4                CHAR(20);       
DEFINE cRetorno5                CHAR(4);         
DEFINE cRetorno6                CHAR(104);       
DEFINE cRetorno7                CHAR(10);       
DEFINE cRetorno8                CHAR(12);        
DEFINE cRetorno9                CHAR(4);        
DEFINE cRetorno10               CHAR(4);        
DEFINE cRetorno11               CHAR(10);        
DEFINE cRetorno12               CHAR(4);         
DEFINE cRetorno13               CHAR(80);         
DEFINE cRetorno14               CHAR(104); 
DEFINE cRetorno15               CHAR(10);  
DEFINE cCve_grupo               CHAR(2);
DEFINE cSegmento                CHAR(2);
DEFINE cEtiqueta                CHAR(2);
DEFINE cDescripcion1            CHAR(100);
DEFINE cDescripcion2            CHAR(100);
DEFINE icontador                INTEGER;
DEFINE iSecuencia               INTEGER;
DEFINE iMaxSecuencia            INTEGER;

    
--INICIALIZACION DE VARIABLES--
LET cCodret				    = '000000';
LET iSql_err				= 0 ;
LET VSQL                    = '';
LET cReenvioExitoso         = '';
LET cRetorno1               = '';
LET cRetorno2               = '';
LET cRetorno3               = '';
LET cRetorno4               = '';
LET cRetorno5               = '';
LET cRetorno6               = '';
LET cRetorno7               = '';
LET cRetorno8               = '';
LET cRetorno9               = '';
LET cRetorno10              = '';
LET cRetorno11              = '';
LET cRetorno12              = '';
LET cRetorno13              = '';
LET cRetorno14              = '';
LET cRetorno15              = '';
LET cCve_grupo              = '';
LET cSegmento               = '';
LET cEtiqueta               = '';
LET cDescripcion1           = '';
LET cDescripcion2           = '';
LET icontador               = 0;
LET iSecuencia              = 0;
LET iMaxSecuencia           = 0;

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,''))   ;    	
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/informix/Malena/reenvios.out';
	--TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;
	  
	  --CONTROL DE ERRORES POR PARAMETRO--
	  
		IF NVL(pModo, 0) = 0 AND NVL(pTipoSolicitud, '') = '' AND NVL(pNumSolicitud, '') = '' AND NVL(pNumCte, '') = '' AND NVL(pEstatus, '') = '' AND NVL(pFechaIni, DATE(1)) = DATE(1) AND NVL(pFechaFin, DATE(1)) = DATE(1) THEN
			LET cCodret = '000001'; --PROCEDIMIENTO EJECUTADO SIN PROPORCIONAR PARAMETROS
			RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,'')) ; 
		END IF;
	  
		IF NVL(pModo,0) <> 1 AND NVL(pModo,0) <>2 AND NVL(pModo,0) <> 3 THEN
			LET cCodret = '000002'; --MODO DE EJECUCION INEXISTENTE
			RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,'')) ; 
		END IF;
	  
		IF pFechaIni IS NULL THEN
			LET pFechaIni = DATE(1);
		END IF;
		
		IF pFechaFin IS NULL THEN
			LET pFechaFin = TODAY;
		END IF;
				
	 IF pModo = 1 OR pModo = 2 THEN ---1 REENVIO DE SOLIC. O 2 REENVIO EXITOSO
		 IF pModo = 2 THEN
			LET cReenvioExitoso = '1' ;
		 END IF;
		-- SE ELIMINA EL CURSOR QUE SE ESTABA UTILIZANDO ADEMAS DE LA RELACION DE TABLAS,YA QUE SE REQUIERE SE 
		-- OBTENGA EL ESTATUS DE LA SOLICITUD DE LA TABLA DE SOLICITUDES Y/O BITACORA SEGUN SEA EL CASO.
		FOREACH WITH HOLD
		        
                SELECT rep.secuencia, rep.tipo_sol, rep.producto, rep.numsolicitud, rep.numcte, rep.sucursal,rep.nombre_cte, 
				rep.fecha_sol,rep.hora, rep.estatus,(CASE WHEN rep.reenvio_exit='1' AND (CASE WHEN rep.tipo_sol=1 THEN 
				aut.status_solicitud ELSE auto.status END) NOT IN ("BC","CC") OR (rep.reenvio_exit='0' AND rep.producto='6500' AND rep.estatus_fin NOT IN ('','BC')) THEN "SI" ELSE "NO" END) AS reenvio_exitoso, 
				rep.fecha_reenvio,rep.estatus_fin AS estatus_reenvio,(CASE WHEN rep.tipo_sol=1 THEN aut.status_solicitud ELSE auto.status END)AS estatus_fin ,rep.cve_grupo, rep.cve_segmento, rep.cve_etiqueta, 
				rep.nombre_analista,rep.motivo_reenvio 
				INTO iSecuencia,cRetorno1, cRetorno2, cRetorno3, cRetorno4,cRetorno5, cRetorno6,cRetorno7, cRetorno8,cRetorno9, 
				cRetorno10, cRetorno11, cRetorno12,cRetorno15, cCve_grupo, cSegmento, cEtiqueta, cRetorno14, cRetorno13
				FROM bdisolic:"informix".ss_mon_buro_rep rep
				LEFT JOIN bdicred:"informix".sd_bitacora_aumlincred bta ON (rep.empresa=bta.empresa 
							AND rep.numsolicitud=bta.num_solicitud
							AND bta.origen='S'
							AND rep.fecha_sol = bta.fecha_insert)
				LEFT JOIN bdicred:"informix".sd_autorizacion_aumlincred auto ON (rep.numsolicitud=auto.num_solicitud		
							AND bta.fecha_insert BETWEEN rep.fecha_sol AND auto.fecha_insert
							AND auto.status NOT IN ('PC','BC','CC') 
							AND auto.status IN (SELECT MIN(status) 
												FROM bdicred:"informix".sd_autorizacion_aumlincred 
												WHERE empresa = "001"
												AND status IN ('AC','AT','RT')
												AND fecha_insert = auto.fecha_insert
												AND num_solicitud=auto.num_solicitud))
				LEFT JOIN bdisolic:"informix".ss_autorizacion aut ON (rep.numsolicitud=aut.num_solicitud		
							AND aut.ROWID = (SELECT MIN(ROWID)
											 FROM bdisolic:ss_autorizacion WHERE empresa='001' 
											 AND status_solicitud NOT IN ('PC','BC','CC') 
											 AND num_solicitud=aut.num_solicitud))     
				WHERE rep.empresa = "001"
				AND rep.numsolicitud >=''
				AND rep.numsolicitud = DECODE (pNumSolicitud,'',rep.numsolicitud,pNumSolicitud)
				AND rep.numcte = DECODE (pNumCte,'',rep.numcte,pNumCte)
				AND rep.estatus = DECODE (pEstatus,'',rep.estatus,pEstatus)
				AND rep.reenvio_exit = rep.reenvio_exit
				AND rep.tipo_sol = DECODE (pTipoSolicitud,'',rep.tipo_sol,pTipoSolicitud)			
				AND rep.fecha_reenvio BETWEEN pFechaIni AND pFechaFin	
				ORDER BY rep.secuencia,rep.fecha_reenvio DESC				
				
		 	 	--2014-01-30 AAME INC 27 053 SE AGREGA VALIDACION PARA LOS CASOS DE LOS DE COPPEL QUE NO CAMBIA EL CAMPO DE REENVÍO EXITOSO
				IF cRetorno12 NOT IN ("BC","CC") AND cReenvioExitoso='1' THEN		
					 IF cRetorno2='6500' AND cRetorno10 ='NO' AND cRetorno12 <> '' THEN 
						LET cRetorno10 ='SI';
					 ELIF (cRetorno2 <>'6500' AND cRetorno10 ='NO') OR cRetorno12 ='' THEN 
					 	CONTINUE FOREACH;
					 END IF;
				ELIF cRetorno12 IN ("BC","CC") AND cReenvioExitoso='1' OR cRetorno2='6500' THEN
					IF cRetorno2='6500' AND NVL(cRetorno15,'BC') <> 'BC' THEN					
						SELECT MAX(secuencia)
						INTO iMaxSecuencia
						FROM bdisolic:ss_mon_buro_rep
						WHERE numsolicitud=cRetorno3;
						
						IF iSecuencia=iMaxSecuencia THEN
							LET cRetorno10 ='SI';
							LET cRetorno12 = cRetorno15;
						ELIF cReenvioExitoso='1' THEN
							CONTINUE FOREACH;
						END IF;
					ELIF cReenvioExitoso='1' THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				SELECT descripcion 
				INTO cRetorno1
				FROM "informix".sd_mon_buro_cattiposol
				WHERE SUBSTR(cve_tipo_sol,2,1) = TRIM(cRetorno1);
				
				LET cRetorno8 = SUBSTR(TRIM(cRetorno8),1,8);
				
				SELECT nombre_prod
				INTO cRetorno2
				FROM "informix".sd_definicion
				WHERE empresa = '001'
				AND num_producto = TRIM(cRetorno2);			
				
				LET icontador = icontador + 1;

				RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), 
				TRIM(NVL(cRetorno4,'')), TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), 
				TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')),
				TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), TRIM(NVL(cRetorno15,'')) WITH RESUME; 								
			
		END FOREACH;			
		
	 ELIF pModo = 3 THEN --CONSULTA POR ANALISTA
	 
		 FOREACH WITH HOLD
				SELECT  numempanalista,nombre_analista, perfil_usu, SUM (CASE WHEN cve_grupo = "01" THEN 1 ELSE 0 END) AS Total_cve01, 
				SUM (CASE WHEN cve_grupo = "02" THEN 1 ELSE 0 END) AS Total_cve02, SUM (CASE WHEN cve_grupo = "03" THEN 1 ELSE 0 END) AS Total_cve03, 
				SUM (CASE WHEN cve_grupo = "04" THEN 1 ELSE 0 END) AS Total_cve04, SUM (CASE WHEN cve_grupo = "05" THEN 1 ELSE 0 END) AS Total_cve05,
				SUM (CASE WHEN cve_grupo = "06" THEN 1 ELSE 0 END) AS Total_cve06, SUM (CASE WHEN cve_grupo = "07" THEN 1 ELSE 0 END) AS Total_cve07, 
				SUM (CASE WHEN cve_grupo = "08" THEN 1 ELSE 0 END) AS Total_cve08,SUM (CASE WHEN cve_grupo = "09" THEN 1 ELSE 0 END) AS Total_cve09, 
				SUM (CASE WHEN estatus = "BC" THEN 1 ELSE 0 END) AS Total_BC, SUM (CASE WHEN estatus = "CC" THEN 1 ELSE 0 END) AS Total_CC 
				INTO cRetorno1, cRetorno2, cRetorno3, cRetorno4,cRetorno5, cRetorno6,cRetorno7, cRetorno8,cRetorno9, cRetorno10, cRetorno11, cRetorno12, cRetorno13,cRetorno14
				FROM bdisolic: "informix".ss_mon_buro_rep 
				WHERE  empresa = "001"
				AND tipo_sol = DECODE (pTipoSolicitud,'',tipo_sol,pTipoSolicitud)
				AND estatus = DECODE (pEstatus,'',estatus,pEstatus)
				AND fecha_reenvio BETWEEN pFechaIni AND pFechaFin 
				GROUP BY numempanalista,nombre_analista, perfil_usu   
				
				LET cRetorno15 = cRetorno13::INTEGER + cRetorno14::INTEGER;
				
				LET icontador = icontador + 1;

				RETURN cCodret, TRIM(NVL(cRetorno1,'')), TRIM(NVL(cRetorno2,'')), TRIM(NVL(cRetorno3,'')), TRIM(NVL(cRetorno4,'')), 
				TRIM(NVL(cRetorno5,'')), TRIM(NVL(cRetorno6,'')), TRIM(NVL(cRetorno7,'')), TRIM(NVL(cRetorno8,'')), TRIM(NVL(cRetorno9,'')), 
				TRIM(NVL(cRetorno10,'')), TRIM(NVL(cRetorno11,'')), TRIM(NVL(cRetorno12,'')), TRIM(NVL(cRetorno13,'')), TRIM(NVL(cRetorno14,'')), 
				TRIM(NVL(cRetorno15,'')) WITH RESUME;			


		END FOREACH;
		
	END IF;	IF icontador = 0 THEN
		LET cCodret = '000003'; --CONSULTA SIN RESULTADOS

		RETURN cCodret,'', '', '','','', '','', '','','','','','','',''; 	
	END IF;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO PARA LA PANTALLA DE REPORTERIA DE monitor_buro, QUE CONSULTA', 'A TRAVÉS DE 3 MODALIDADES DIFERENTES Y GENERA UN RESÚMEN ESTRUCTURADO DEL', '              CONTENIDO DE LA TABLA br_mon_buro_rep DE LA BASE DE DATOS BDIBURO. ',
'FECHA DE CREACIÓN: 07 DE JUNIO DE 2013',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 201306071200';

CREATE PROCEDURE "informix".sp_ce_aplicareversion (v_FolioSUC CHAR(16), v_usuario CHAR(8))

RETURNING CHAR(5);
    
    ------------------------------------------------------------------------------>
    -- Objetivo: Sp para reversion de cargo a cuenta de cheques por pago de crédito empresarial - Orión
    -- Autor: SADCV
    -- Fecha: 30/09/2013
    ------------------------------------------------------------------------------>
    
    ------------------------------------------------------------------------------>
	--// Inicializa de Variables 

    DEFINE vSqlErr 			INTEGER;
    DEFINE cCodRet  		CHAR (5);
	

	DEFINE cod_ret 		CHAR (5);
	
    ------------------------------------------------------------------------------>
	--// Inicializa variables
	
    LET vSqlErr 			= 0;
    LET cCodRet 			= '00000';
	
	LET cod_ret 			= '';
	
	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Desactivar Debug   
   -- SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicareversion.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
		
    ------------------------------------------------------------------------------>
	--//
    
    BEGIN

    ON EXCEPTION SET vSqlErr
        IF vSqlErr <> 0 THEN
            let cCodRet = vSqlErr;
            -- ROLLBACK WORK;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

	------------------------------------------------------------------------------>
	--//

    SET ISOLATION DIRTY READ;
	
	CALL bdicheq:reversion('001','9550', v_usuario, v_FolioSUC, '0') 
	RETURNING cod_ret;
	
	LET cCodRet = LPAD (TRIM(cod_ret), 5, '0');
	
    RETURN cCodRet;
    
	END;
	
END PROCEDURE;