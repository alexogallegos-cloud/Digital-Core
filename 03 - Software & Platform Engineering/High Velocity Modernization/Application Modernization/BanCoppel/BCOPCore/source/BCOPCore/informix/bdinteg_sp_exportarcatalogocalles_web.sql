CREATE PROCEDURE "informix".sp_exportarcatalogocalles_web(pCatalogo CHAR(1), pFechaAct DATE, pSeparador CHAR(1), pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (3000);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(30);
DEFINE vNomArchAux                      CHAR(40);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: JosÃ¯Â¿Â½ de JesÃ¯Â¿Â½s Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de exportar el total o una parcialidad de las zonas del catalogo

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parÃ¯Â¿Â½metro pEjecucion para determinar si es AutmÃ¯Â¿Â½tica o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catcalles_web';
LET vNomArchAux   = 'si_catcalles_web_Aux';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/informix/vic/sp_ExportarCatalogoCallesWeb.out";
--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas WHERE empresa = '001';
    
    if pEjecucion = 'A' then
        select trim(valor) into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    else
        select trim(valor) || '/tmp/' into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    end if;
    LET vPath = TRIM(vPath);

    LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);

IF (pCatalogo = 1) THEN
        
          				
		  LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerocalle, limpia_cadenaweb(a.nombrecalle) '                
                || ' FROM BDINTEG:si_catcalles a '
                --|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' VALIDACION SEPOMEX
		    	|| '" >' || trim(vPath) ||'corre_si_catcalles_web.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 
    
    
ELIF (pCatalogo = 0) THEN
     
LET cCadena = 'echo " unload to ' || trim(vPath) || trim(vNomArchAux)  || ' DELIMITER ''' || pSeparador || ''' SELECT a.numerocalle, limpia_cadenaweb(a.nombrecalle) '                                
				|| ' FROM BDINTEG:si_catcalles a '
				--|| ', BDINTEG:si_catsepomex b, BDINTEG:si_estados c, BDINTEG:si_ciudades d  '
				--|| ' where c.estado = d.estado and lpad(a.codigopostalzona,5,''0'') = b.d_codigo and c.estado = b.c_estado and a.numerociudad = d.ciudad_coppel '
                --|| ' and TRIM(a.nomzona_spmx) = b.d_asenta and TRIM(a.mnpio_spmx) = b.d_mnpio and d.ciudad_coppel > 0 and d.elegir IS NULL and nvl(a.nomzona_spmx,'''') <> '''' and nvl(a.pobzona_spmx,'''')<>'''' '
                --|| ' and nvl(a.mnpio_spmx,'''') <>'''' ' VALIDACION SEPOMEX
                || '  where f_inserta >= ''' || pFechaAct || ''''
				|| '" >' || trim(vPath) ||'corre_si_catcalles_web.sql'; 
				
				
          System cCadena;

          let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;

		  
          LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
          SYSTEM cCadena;

          let cCadena = 'rm ' || trim(vPath) || 'corre_si_catcalles_web.sql';
          System cCadena;    
          let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
          System cCadena; 

   
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parametro de Catalogo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Victor D. Vazquez',
'FECHA: 2023/06/12',
'DESCRIPCION: Se modifica para agregar la depuracion de caracteres especiales en algunos campos para SIWEB',
'BD: bdinteg',
'VERSION:20230612.100';

CREATE PROCEDURE "informix".sp_genera_reporte_tipo_cte()
RETURNING 
CHAR(5) AS CodRet;

----------------DEFINE VARIABLES----------------------
DEFINE sFechaEjecucion    CHAR(10);
DEFINE cCodRet        	  CHAR(5);
DEFINE cCodRetC           CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE iCtesTotl		  INTEGER;
DEFINE iCtesNorm		  INTEGER;
DEFINE iCtesECpl		  INTEGER;
DEFINE iCtesEBpl		  INTEGER;
DEFINE iCtesVip 		  INTEGER;
DEFINE iCtesRel 		  INTEGER;
DEFINE iEstatusSnRes 	  INTEGER;
DEFINE iEstatusCteNA 	  INTEGER;
DEFINE iEstatusReus 	  INTEGER;
DEFINE iEstatusDerArc 	  INTEGER;
DEFINE iEstatusVip   	  INTEGER;

DEFINE sDescMes           CHAR(10);   
DEFINE svt_fecha_hoy      DATE;
DEFINE svt_fecha_udia     DATE;
DEFINE sUdia              CHAR(2);
DEFINE sDiaP              CHAR(2);
DEFINE sMesP              CHAR(2);
DEFINE sAnoP              CHAR(4);

DEFINE iAcumuladoNorm     INTEGER;
DEFINE iAcumulaEbcp       INTEGER;
DEFINE iAcumulaEcpl       INTEGER;
DEFINE iAcumulaRel        INTEGER;
DEFINE iAcumulaVip        INTEGER;
DEFINE iAcumulaEsinRes    INTEGER;
DEFINE iAcumulaEcteNA     INTEGER;
DEFINE iAcumulaReus       INTEGER;
DEFINE iAcumulaDerArc     INTEGER;
DEFINE iAcumulaEstVip     INTEGER;

DEFINE iContador     	  INTEGER;
DEFINE cNumcte 		 	  CHAR(20);
DEFINE bEnTransaccion 	  BOOLEAN;
DEFINE cStatus_cred	  CHAR(2);

----------------INICIALIZA VARIABLES------------------
LET sFechaEjecucion     = '';
LET cCodRet             ='00000';
LET cCodRetC            ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET iCtesTotl           = 0;
LET iCtesNorm           = 0;
LET iCtesECpl           = 0;
LET iCtesEBpl           = 0;
LET iCtesVip            = 0;
LET iCtesRel            = 0;
LET iEstatusSnRes       = 0;
LET iEstatusCteNA       = 0;
LET iEstatusReus        = 0;
LET iEstatusDerArc      = 0;
LET iEstatusVip         = 0;

LET sDescMes            ='';
LET svt_fecha_hoy       ='';
LET sUdia               ='';
LET sDiaP               ='';
LET sMesP               ='';
LET sAnoP               ='';

LET iAcumuladoNorm      = 0;
LET iAcumulaEbcp        = 0;
LET iAcumulaEcpl        = 0;
LET iAcumulaRel         = 0;
LET iAcumulaVip         = 0;
LET iAcumulaEsinRes     = 0;
LET iAcumulaEcteNA      = 0;
LET iAcumulaReus        = 0;
LET iAcumulaDerArc      = 0;
LET iAcumulaEstVip      = 0;

LET iContador 			= 0;
LET cNumcte 			= '';
LET bEnTransaccion 		= 'f';
LET cStatus_cred       = '00';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
			IF bEnTransaccion = 't' THEN
				ROLLBACK WORK;
			END IF;
			RETURN cCodRet;
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/OMC/sp_genera_reporte_tipo_cte.out";
	--TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-------------------------------------OBTIENE FECHA-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} add_months(fecha_hoy,-1) INTO svt_fecha_hoy
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

    LET sDiaP = SUBSTR(svt_fecha_hoy,4,2);
    LET sMesP = SUBSTR(svt_fecha_hoy,0,2);
    LET sAnoP = SUBSTR(svt_fecha_hoy,7,4);
	
	SELECT LAST_DAY(mdy(sMesP,sDiaP,sAnoP)) INTO svt_fecha_udia
	FROM systables WHERE tabid = 1;
	
	LET sUdia = SUBSTR(svt_fecha_udia,4,2);
	---------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------
	IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'si_tipo_prom_paso') THEN
		DROP TABLE "informix".si_tipo_prom_paso;
	END IF;
			
	CREATE TABLE "informix".si_tipo_prom_paso(
	numcte CHAR(20)
	);
	
	--set pdqpriority 5;

	--begin;
		CREATE INDEX "informix".idx_numcte_tipo_promo_paso
		ON "informix".si_tipo_prom_paso(numcte) using btree in datos00 online;
	--commit;

	--set pdqpriority 0;

	update statistics medium for table "informix".si_tipo_prom_paso;
	--IFRS Se contemplan los nuevos estatus por Etapas
	BEGIN WORK;
		LET bEnTransaccion = 't';
		FOREACH WITH HOLD
		
			SELECT {+INDEX (bdicred:"informix".sd_maecred idx_sd_maecred4)}	numcte,status_cred
			INTO cNumcte, cStatus_cred
				from bdicred:sd_maecred 
				where empresa = '001' 
				and num_producto in ('6600','6500','7000','8100','6001')
				
			 
			IF(cStatus_cred)in ('AA','BA','BT','E1','E2','E3') THEN
			
			INSERT INTO si_tipo_prom_paso(numcte) VALUES (cNumcte);
			LET iContador = iContador+1;
			
			END IF;
			
			IF(iContador == 1000) THEN
				COMMIT WORK;
				LET iContador = 0;
				BEGIN WORK;
			END IF;
		
		END FOREACH;
	COMMIT WORK;
	LET bEnTransaccion = 'f';
	------------------------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES TOTAL-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_tipo_prom_paso idx_numcte_tipo_promo_paso)} COUNT(DISTINCT a.numcte) 
	INTO iCtesTotl
	FROM si_cliente a
		INNER JOIN si_tipo_prom_paso c
				ON a.numcte = c.numcte
	WHERE empresa = '001' AND tpo_persona = 01;

	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES NORMALES-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_tipo_prom_paso idx_numcte_tipo_promo_paso)} COUNT(*) 
	INTO iCtesNorm
	FROM si_cliente a 
		INNER JOIN si_calificacion_cliente b
				ON a.numcte = b.numcte
		INNER JOIN si_tipo_prom_paso c
				ON b.numcte = c.numcte
	WHERE a.empresa = '001' AND a.tpo_persona = 01
	AND b.calificacion_cliente = 0;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES EMPLEADO COPPEL-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesECpl
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 1;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES EMPLEADO BANCOPPEL-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesEBpl
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 2;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES VIP-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesVip
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 3;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES RELACIONADOS-------------------------------------------
	SELECT COUNT(*) 
	INTO iCtesRel
	FROM si_calificacion_cliente 	
	WHERE calificacion_cliente = 4;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES SIN RESTRICCIONES-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusSnRes
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 1;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES NO ACEPTAN-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusCteNA
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 2;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES REUS-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusReus
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 3;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES DERECHOS ARCO-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusDerArc
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 4;
	--------------------------------------------------------------------------------
	
	-------------------------------------CLIENTES ESTATUS VIP-------------------------------------------
	SELECT COUNT(*) 
	INTO iEstatusVip
	FROM si_calificacion_cliente 	
	WHERE estatus_cliente = 5;
	--------------------------------------------------------------------------------
	
	-----------------------------------VALIDA CIFRAS---------------------------------	
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)}
	SUBSTR(LOWER(DECODE(MONTH(svt_fecha_hoy),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(svt_fecha_hoy)),0,3)
	||'-'|| SUBSTR(sAnoP,3,2)
	INTO sDescMes  
	FROM bdinteg:si_fechas
	WHERE empresa = '001';			
			
	IF(iCtesNorm = '' OR iCtesNorm IS NULL) THEN
		LET iCtesNorm=0;
	END IF;
	
	IF(iCtesEBpl = '' OR iCtesEBpl IS NULL) THEN
		LET iCtesEBpl=0;
	END IF;
	
	IF(iCtesECpl = '' OR iCtesECpl IS NULL) THEN
		LET iCtesECpl=0;
	END IF;
	
	IF(iCtesRel = '' OR iCtesRel IS NULL) THEN
		LET iCtesRel=0;
	END IF;
	
	IF(iCtesVip = '' OR iCtesVip IS NULL) THEN
		LET iCtesVip=0;
	END IF;
	
	IF(iEstatusSnRes = '' OR iEstatusSnRes IS NULL) THEN
		LET iEstatusSnRes=0;
	END IF;
	
	IF(iEstatusCteNA = '' OR iEstatusCteNA IS NULL) THEN
		LET iEstatusCteNA=0;
	END IF;
	
	IF(iEstatusReus = '' OR iEstatusReus IS NULL) THEN
		LET iEstatusReus=0;
	END IF;
	
	IF(iEstatusDerArc = '' OR iEstatusDerArc IS NULL) THEN
		LET iEstatusDerArc=0;
	END IF;
	
	IF(iEstatusVip = '' OR iEstatusVip IS NULL) THEN
		LET iEstatusVip=0;
	END IF;
	
	LET iCtesNorm = iCtesTotl - iCtesNorm;

	---------------------------------------------------------------------------------		
	--INSERT INTO "informix".si_reporte_tipo_cliente(mes, norm, ebcp, ecop, rel, vip, sin_restricciones, cliente_no_acepta, reus, derechos_arco, estatus_vip) 
    --VALUES(sDescMes, iCtesNorm, iCtesEBpl, iCtesECpl, iCtesRel, iCtesVip, iEstatusSnRes, iEstatusCteNA, iEstatusReus, iEstatusDerArc, iEstatusVip);
    --------------------------------------------------------------------------------
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'NORM',iCtesNorm, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'EBCP',iCtesEBpl, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'ECOP',iCtesECpl, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'REL',iCtesRel, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'VIP',iCtesVip, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'SIN RESTRICCIONES',iEstatusSnRes, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'CLIENTE NO ACEPTA',iEstatusCteNA, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
	VALUES(sDescMes, 'REUS',iEstatusReus, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'DERECHOS ARCO',iEstatusDerArc, 0);
	INSERT INTO "informix".si_reporte_tipo_cliente(mes, tipo, valor_mes, acumulado)
    VALUES(sDescMes, 'ESTATUS VIP',iEstatusVip, 0);
	
	LET iAcumuladoNorm = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'NORM');
	LET iAcumulaEbcp = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'EBCP');
	LET iAcumulaEcpl = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'ECOP');
	LET iAcumulaRel = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'REL');
	LET iAcumulaVip = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'VIP');
	
	LET iAcumulaEsinRes = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'SIN RESTRICCIONES');
	LET iAcumulaEcteNA = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'CLIENTE NO ACEPTA');
	LET iAcumulaReus = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'REUS');
	LET iAcumulaDerArc = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'DERECHOS ARCO');
	LET iAcumulaEstVip = (SELECT SUM(valor_mes) FROM si_reporte_tipo_cliente WHERE tipo = 'ESTATUS VIP');
	
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumuladoNorm WHERE tipo = 'NORM';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEbcp WHERE tipo = 'EBCP';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEcpl WHERE tipo = 'ECOP';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaRel WHERE tipo = 'REL';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaVip WHERE tipo = 'VIP';
	
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEsinRes WHERE tipo = 'SIN RESTRICCIONES';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEcteNA WHERE tipo = 'CLIENTE NO ACEPTA';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaReus WHERE tipo = 'REUS';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaDerArc WHERE tipo = 'DERECHOS ARCO';
	UPDATE "informix".si_reporte_tipo_cliente SET acumulado = iAcumulaEstVip WHERE tipo = 'ESTATUS VIP';
	
	LET cDesc= 'PROCESO EXITOSO';
	RETURN cCodRet;
END 
END PROCEDURE;