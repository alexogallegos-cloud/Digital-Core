CREATE PROCEDURE "informix".sp_consfechasreestructmensual(pAnio CHAR(4))

----------RETORNOS----------
RETURNING
CHAR(6) AS cod_ret,
CHAR(4) AS anio_mes;

------DECLARACION DE VARIABLES------
DEFINE iSql_err             INTEGER;
DEFINE cCodret              CHAR(6);
DEFINE cFechaRetorno        CHAR(4);

-------INICIALIZACION DE VARIABLES-------
LET iSql_err                = 0 ;
LET cCodret                 = '000000'; --EJECUCION EXITOSA
LET cFechaRetorno           = '' ;

BEGIN
	--CONTROL DE ERRORES INFORMIX--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret), TRIM(NVL(cFechaRetorno,''));
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/dbexportb/carlos/cobranza/sp_consfechasreestructmensual.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--**************************************************************************************
	--****************************   CONSULTA   *******************************************
	
	IF NVL(pAnio,'') = '' THEN --SI NO MANDAN AÑO SE CONSULTAN LOS AÑOS 
		FOREACH
			SELECT DISTINCT YEAR (fecha)
			INTO cFechaRetorno
			FROM "informix".sd_medicion_reestructura
			WHERE fecha = fecha      ---PARA ACTIVAR EL INDICE
			AND sucursal = sucursal  ---PARA ACTIVAR EL INDICE
			ORDER BY YEAR (fecha) DESC

			RETURN TRIM(cCodret), TRIM(NVL(cFechaRetorno,'')) WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000001'; --NO SE ENCONTRARON AÑOS/MESES
			RETURN TRIM(cCodret), TRIM(NVL(cFechaRetorno,''));
		END IF	 
	ELIF NVL(pAnio,'') <> '' THEN

		FOREACH
			SELECT DISTINCT MONTH (fecha)
			INTO cFechaRetorno
			FROM "informix".sd_medicion_reestructura
			WHERE YEAR(fecha) = TRIM(pAnio)
			AND sucursal = sucursal ---PARA ACTIVAR EL INDICE
			ORDER BY MONTH (fecha) 

			RETURN TRIM(cCodret), TRIM(NVL(cFechaRetorno,'')) WITH RESUME;
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000001'; --NO SE ENCONTRARON AÑOS/MESES
			RETURN TRIM(cCodret), TRIM(NVL(cFechaRetorno,''));
		END IF	 

	END IF;
		
	


END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: VERIFICA Y REGRESA LOS AÑOS O MESES EN LOS CUALES HAY REGISTROS EN LA TABLA', 
'	          sd_medicion_reestructura DE LA BDICRED.',
'FECHA DE CREACIÓN: 22-FEBRERO-2013',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 220220131500';

CREATE PROCEDURE "informix".sp_vta_consulta_cifras( cnumcredito char(20), sfecha date)
	returning 
			  CHAR(3) 			as resultado,
			  CHAR(80)			as mensaje,
			  CHAR(4) 			as producto,
			  INTEGER			as clientes,
			  DECIMAL (14,2)  	as sdo_actual,
			  DECIMAL (14,2)  	as sdo_vencido,
			  DECIMAL (14,2)  	as sdo_no_exig,
			  DECIMAL (14,2)  	as int_vencido,
			  DECIMAL (14,2)  	as iva_int_vencido,
			  DECIMAL (14,2)  	as int_mora_ordi,
			  DECIMAL (14,2)  	as iva_int_mora_ordi,
			  DECIMAL (14,2)  	as int_mora_cope,
			  DECIMAL (14,2)  	as iva_int_mora_cope;
			  
	---DECLARACIONES DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cErrorInfo           CHAR(80);
    DEFINE cCodRet              CHAR(3);
    DEFINE cMensajeRet          CHAR(80);
    DEFINE cProducto	        CHAR(4);
    DEFINE iClientes     		INTEGER;
    DEFINE dSdoActual         	DECIMAL (14,2);	  
	DEFINE dSdoVencido        	DECIMAL (14,2);	 
	DEFINE dSdoNoExig        	DECIMAL (14,2);	 	
	DEFINE dIntVencido        	DECIMAL (14,2);	
	DEFINE dIvaIntVencido       DECIMAL (14,2);
	DEFINE dIntMoraOrdi       	DECIMAL (14,2);	
 	DEFINE dIvaIntMoraOrdi     	DECIMAL (14,2);	
	DEFINE dIntMoraCope     	DECIMAL (14,2);	
	DEFINE dIvaIntMoraCope     	DECIMAL (14,2);	
	--DEFINE dtFechaAnioMes     	CHAR(10);	
	DEFINE dtFechaReporte     	DATE;
	DEFINE dtFechaHoy     		DATE;	
		
	--SET DEBUG FILE TO "/informix/marcov/sp_vta_consulta_cifras.out";
    --TRACE ON; 
	
	---INICIALIZACIONES DE VARIABLES
		
    LET iSqlErr                 = 0;
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";
    LET cCodRet                 = "000";
    LET cMensajeRet             = "";
    LET cProducto           	= "";
    LET iClientes		        = 0;
    LET dSdoActual              = 0;
	LET dSdoVencido             = 0;
	LET dSdoNoExig              = 0;
	LET dIntVencido             = 0;
	LET dIvaIntVencido          = 0;
	LET dIntMoraOrdi	        = 0;
	LET dIvaIntMoraOrdi	        = 0;
	LET dIntMoraCope	        = 0;
	LET dIvaIntMoraCope	        = 0;
	--LET dtFechaAnioMes	        = "";
	LET dtFechaReporte	        = DATE(1);
	LET dtFechaHoy		        = DATE(1);
	
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          LET cMensajeRet = cErrorInfo;
          RETURN cCodRet, cMensajeRet, cProducto, iClientes, dSdoActual, dSdoVencido, dSdoNoExig,
				 dIntVencido, dIvaIntVencido, dIntMoraOrdi, dIvaIntMoraOrdi, dIntMoraCope, dIvaIntMoraCope;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	
	-- VALIDA LOS PARAMETROS DE ENTRADA
    IF cnumcredito IS NULL OR sfecha IS NULL THEN
        LET cCodRet = "001";
        LET cMensajeRet = "PARAMETROS INVALIDOS";
        RETURN cCodRet, cMensajeRet, cProducto, iClientes, dSdoActual, dSdoVencido, dSdoNoExig,
			   dIntVencido, dIvaIntVencido, dIntMoraOrdi, dIvaIntMoraOrdi, dIntMoraCope, dIvaIntMoraCope;
	END IF
	
	---Para obtener la fecha completa a partir de la fecha mes-año
	
	--LET dtFechaAnioMes = ((SUBSTR(sfecha,5,2)) || '01' ||(SUBSTR(sfecha,1,4)));
	
	--Para obtener la fecha en que se sacará el reporte
	LET dtFechaReporte = mdy(month(sfecha)+1,1,year(sfecha)) - 1 units day;
	
	--Seleccionamos Fecha de hoy
	SELECT NVL(fecha_hoy ,today) 
	INTO dtFechaHoy
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';	
	
			
		
		IF (year(sfecha) || month(sfecha)) = (year(dtFechaHoy) || month(dtFechaHoy)) THEN
		  select max(fechareporte) INTO dtFechaReporte from bdicobranza:cb_rep_cart_quebrantar;
    ELSE      
      select max(fechareporte) INTO dtFechaReporte from bdicobranza:cb_rep_cart_quebrantar where to_char(fechareporte,'%m%Y') = to_char( sfecha,'%m%Y');    
		END IF;
		
			
			
				FOREACH
						select producto, count(*)  clientes , sum(sdo_actual) sdo_actual, sum(sdo_vencido)sdo_vencido,
						sum(sdo_no_exig) sdo_no_exig, (sum(int_vencido) + sum(int_vencido_bal) ) int_vencido,  (sum(iva_int_vencido) +
						sum(iva_int_vencido_bal))  iva_int_vencido,  sum(int_mora_ordi) int_mora_ordi,
						sum(iva_int_mora_ordi) iva_int_mora_ordi, sum(int_mora_cope) int_mora_cope, sum(iva_int_mora_cope) iva_int_mora_cope
						into cProducto, iClientes, dSdoActual, dSdoVencido, dSdoNoExig,
					    dIntVencido, dIvaIntVencido, dIntMoraOrdi, dIvaIntMoraOrdi, dIntMoraCope, dIvaIntMoraCope
						from  bdicobranza:cb_rep_cart_quebrantar  a
						where a.fechareporte = dtFechaReporte
						and nvl(a.excluido,'') =''
            and ( a.num_credito = cnumcredito  or cnumcredito=0) 
						group by producto
						
						RETURN cCodRet, cMensajeRet, cProducto, iClientes, dSdoActual, dSdoVencido, dSdoNoExig,
					    dIntVencido, dIvaIntVencido, dIntMoraOrdi, dIvaIntMoraOrdi, dIntMoraCope, dIvaIntMoraCope WITH RESUME;
				
				END FOREACH;

END;
END PROCEDURE 
DOCUMENT
'Se realiza procedimiento para consultar las cifras de la venta de créditos por producto ya sea de un crédito en específico o de todos',
'AUTOR : Marco Antonio Valenzuela León',
'FECHA : 03/Abril/2013',
'BD    : BDISOLIC',
'Version: ',
'Modificación : ',
'AUTOR : ',
'FECHA : ',
'BD    : ';

CREATE PROCEDURE "informix".sp_consreestructmensual(pSucursal CHAR(4), pMes CHAR(2), pAnio CHAR(4), pRegion SMALLINT, pDivision SMALLINT)

----------RETORNOS----------
RETURNING
CHAR(6)           AS cod_ret,
CHAR (8)          AS periodo, 
CHAR (4)          AS sucursal,
CHAR (1)          AS calif, 
INTEGER           AS ctes_candi,
DECIMAL (5,2)     AS porcen_reestructu,
DECIMAL (18,2)    AS meta_mensual,
INTEGER           AS ctes_reestruct,
DECIMAL (18,2)    AS porcen_cumpli;

------DECLARACION DE VARIABLES------
DEFINE iSql_err              INTEGER;
DEFINE cCodret               CHAR (6);
DEFINE cPeriodo              CHAR (8);
DEFINE cSucursal             CHAR(4);
DEFINE cCalificacion         CHAR (1);
DEFINE iCtes_candidatos      INTEGER ;
DEFINE dPorcen_reestructu    DECIMAL (5,2);
DEFINE dMeta_mensual         DECIMAL (18,2);
DEFINE iCtes_reestructu      INTEGER ;
DEFINE dPorcen_cumpli        DECIMAL (18,2);
DEFINE dFechafinal           DATE;
DEFINE dFechaSeleccionada    DATE;
DEFINE cMes                  CHAR(2);
DEFINE dFechaLimite          DATE;

-------INICIALIZACION DE VARIABLES-------
LET iSql_err                  = 0 ;
LET cCodret                   = '000000'; --EJECUCION EXITOSA
LET cPeriodo                  = '' ;
LET cSucursal                 = '' ;
LET cCalificacion             = '' ;
LET iCtes_candidatos          = 0 ;
LET dPorcen_reestructu        = 0.0 ;
LET dMeta_mensual             = 0.0 ;
LET iCtes_reestructu          = 0 ;
LET dPorcen_cumpli            = 0.0;
LET dFechafinal               = DATE(1);
LET dFechaSeleccionada        = DATE(1);
LET cMes                      = '';
LET dFechaLimite              = DATE(1);


BEGIN
	--CONTROL DE ERRORES INFORMIX--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN TRIM(cCodret), TRIM(NVL(cPeriodo,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cCalificacion,'')), NVL(iCtes_candidatos, 0), NVL(dPorcen_reestructu, 0.0), NVL(dMeta_mensual, 0), NVL(iCtes_reestructu, 0), NVL(dPorcen_cumpli, 0.0);
		END IF;
	END EXCEPTION;
		
	--SET DEBUG FILE TO '/dbexportb/carlos/cobranza/sp_consreestructmensual.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--------------------------CONTROL DE ERRORES POR PARAMETRO--------------------------
	IF NVL(pMes,'') = '' OR NVL(pAnio,'') = ''  THEN  
		LET cCodret = '000001'; --ERROR EN LOS PARAMETROS
        RETURN TRIM(cCodret), TRIM(NVL(cPeriodo,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cCalificacion,'')), NVL(iCtes_candidatos, 0), NVL(dPorcen_reestructu, 0.0), NVL(dMeta_mensual, 0), NVL(iCtes_reestructu, 0), NVL(dPorcen_cumpli, 0.0);
	END IF;

--************************************BLOQUE DE CONSULTAS****************************************
LET dFechafinal = MDY(TRIM(pMes),'20',TRIM(pAnio)); --VACIADO DE MES Y AÑO EN VARIABLE 
    LET dFechaLimite = (dFechafinal - 12 UNITS MONTH );
	FOREACH	
			--SE SELECCIONA LA LISTA DE SUCURSALES A TRABAJAR
			SELECT mr.sucursal, mr.fecha, (NVL(mr.ctes_candidatos,0) * NVL(mtr.pct_meta,0)), NVL(mr.ctes_reestructurados,0), NVL(mr.ctes_candidatos,0), ROUND(NVL(mtr.pct_meta ,0.00),2)
			INTO cSucursal, dFechaSeleccionada, dMeta_mensual, iCtes_reestructu, iCtes_candidatos, dPorcen_reestructu
			FROM "informix".sd_medicion_reestructura mr
			LEFT OUTER JOIN "informix".sd_meta_reestructura mtr ON(mtr.fecha = mr.fecha AND mtr.activo = 1)
			LEFT OUTER JOIN bdinteg:"informix".si_sucursales suc ON (suc.sucursal = mr.sucursal AND suc.sucursal = DECODE(TRIM(NVL(pSucursal,'')),'',suc.sucursal,pSucursal))
			LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciud ON (ciud.pais=suc.pais AND ciud.estado=suc.estado AND ciud.ciudad = suc.ciudad)
			LEFT OUTER JOIN bdinteg:"informix".si_catciudades ciu ON (ciu.numerociudad = ciud.ciudad_coppel)
			LEFT OUTER JOIN bdinteg:"informix".si_regiones reg ON (reg.numero_region = DECODE(NVL(pRegion,0),0,ciu.numero_region,pRegion) AND reg.division = DECODE(NVL(pDivision,0),0,reg.division,pDivision))
			WHERE mr.fecha <= dFechafinal
			AND mr.sucursal = mr.sucursal
			AND mr.fecha > dFechaLimite
			AND suc.sucursal = mr.sucursal
			AND ciu.numero_region = reg.numero_region
			ORDER BY suc.sucursal , mr.fecha DESC
			 
			-------------------------------------------------------------
			--SE GUARDA SOLO EL MES PARA HACER LA COMPARACION			
			LET cMes = MONTH(dFechaSeleccionada); 

			--TRADUCCION DE NÚMERO A MES
			IF cMes = '12' THEN
				LET cPeriodo = 'Dic'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '11' THEN
				LET cPeriodo = 'Nov'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '10' THEN
				LET cPeriodo = 'Oct'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '9' THEN
				LET cPeriodo = 'Sep'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '8' THEN
				LET cPeriodo = 'Ago'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '7' THEN
				LET cPeriodo = 'Jul'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '6' THEN
				LET cPeriodo = 'Jun'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '5' THEN
				LET cPeriodo = 'May'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '4' THEN
				LET cPeriodo = 'Abr'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '3' THEN
				LET cPeriodo = 'Mar'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '2' THEN
				LET cPeriodo = 'Feb'||'-'||YEAR(dFechaSeleccionada);
			ELIF cMes = '1' THEN
				LET cPeriodo = 'Ene'||'-'||YEAR(dFechaSeleccionada);
			END IF;

			IF NVL(dMeta_mensual,0) <> 0 THEN
			--CALCULO DE PORCENTAJE DE CUMPLIMIENTO
				LET dPorcen_cumpli = (iCtes_reestructu::DECIMAL / dMeta_mensual)*100;
			ELIF NVL(dMeta_mensual,0) = 0 THEN --SE EVITA LA DIVISION ENTRE 0
				LET dPorcen_cumpli = 0.0;
			END IF;

			--CALCULO DE CALIFICACION
			IF dPorcen_cumpli >= 100 THEN
				LET dPorcen_cumpli = 100;
				LET cCalificacion = 'A';
			ELIF dPorcen_cumpli >= 90 AND dPorcen_cumpli < 100 THEN
				LET cCalificacion = 'B';
			ELIF dPorcen_cumpli < 90 THEN
				LET cCalificacion = 'C';
			END IF;

			--RETORNOS
			RETURN TRIM(cCodret), TRIM(NVL(cPeriodo,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cCalificacion,'')), NVL(iCtes_candidatos, 0), NVL(dPorcen_reestructu, 0.0), NVL(dMeta_mensual, 0), NVL(iCtes_reestructu, 0), NVL(dPorcen_cumpli, 0.0) WITH RESUME;
			
		END FOREACH; 

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '000002'; --NO SE ENCONTRARON DATOS CON LOS PARAMETROS PROPORCINADOS
		END IF	 
		
		IF NVL(cCodret,'') <> '000000' THEN
			RETURN TRIM(cCodret), TRIM(NVL(cPeriodo,'')), TRIM(NVL(cSucursal,'')), TRIM(NVL(cCalificacion,'')), NVL(iCtes_candidatos, 0), NVL(dPorcen_reestructu, 0.0), NVL(dMeta_mensual, 0), NVL(iCtes_reestructu, 0), NVL(dPorcen_cumpli, 0.0);
		END IF;
				
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN: PROCEDIMIENTO QUE CONSULTA EL CONTENIDO DE LA TABLA sd_medicion_reestructura DE LA BDICRED',
'POR SUCURSAL, DIVISION, REGION, O FECHA.',
'FECHA DE CREACIÓN: 21-FEBRERO-2013',
'BASE DE DATOS: BDICRED',
'CREADOR: CARLOS OCHOA VALENZUELA',
'VERSION: 201302211537',
'FECHA:08-ABRIL-2013',
'MODIFICO:ISARAI BOJORQUEZ AGUIRRE',
'DESCRIPCION: SE MODIFICO PARA AGREGAR EL CAMPO "activo" A LA TABLA sd_meta_reestructura.sql';

CREATE PROCEDURE "informix".sp_meta_reestruct_adminval(pTipoOperacion SMALLINT, pFechaPct DATE, pPctMeta DECIMAL (5,2), pUsuario CHAR(8), pFechaInsert DATE)
                                                                                                                                                             
RETURNING
CHAR(6)                 AS Cod_Ret,
CHAR(6)					AS CodRetPctMt,
DATE                    AS Fecha_PorcMeta,
SMALLINT				AS Secuencia,
DECIMAL(5,2)    		AS Porc_Meta,
CHAR(8)                 AS User_Insert,
DATE                    AS Fecha_Insert,
SMALLINT				AS Activo;

-----DECLARACION DE VARIABLES-----
DEFINE cCodRetPctMt     CHAR(6);
DEFINE cCodRet          CHAR(6);
DEFINE iSql_Err         INTEGER;
DEFINE dtFecha_PorcMeta DATE;
DEFINE dPorc_Meta       DECIMAL(5,2);
DEFINE cCve_Usuario     CHAR(8);
DEFINE dtFec_Insert     DATE;
DEFINE sSecuencia		SMALLINT;
DEFINE sActivo			SMALLINT;

-----INICIALIZACION DE VARIABLES-----
LET cCodRetPctMt ='000000';
LET cCodRet ='000000';
LET iSql_Err =0;
LET dtFecha_PorcMeta='';
LET dPorc_Meta =0;
LET cCve_Usuario='';
LET dtFec_Insert ='';
LET sSecuencia=0;
LET sActivo=0;

	--SET DEBUG FILE TO '/respaldosbd/isarai/sp_meta_reectruct2.out';
	--TRACE ON;

BEGIN
        --CONTROL DE ERRORES INFORMIX--
        ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				LET cCodRetPctMt = '165';
				RETURN TRIM(cCodRet), TRIM(cCodRetPctMt), NVL(dtFecha_PorcMeta,DATE(1)), NVL(sSecuencia,0), NVL(dPorc_Meta,0.00), NVL(cCve_Usuario,""), NVL(dtFec_Insert,DATE(1)), NVL(sActivo,0);
			END IF;
		END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		--**CONTROL DE ERRORES DE PARAMETROS
		--SI EL TIPO DE OPERACION NO ES 1,2,3 O 4; INDICARA QUE LOS PARAMETROS RECIBIDOS SON INVALIDOS.		
        IF pTipoOperacion NOT IN (1,2,3,4) THEN
			LET cCodRetPctMt = '361'; --PARAMETROS INVALIDOS
			RETURN TRIM(cCodRet), TRIM(cCodRetPctMt), NVL(dtFecha_PorcMeta,DATE(1)), NVL(sSecuencia,0), NVL(dPorc_Meta,0.00), NVL(cCve_Usuario,""), NVL(dtFec_Insert,DATE(1)), NVL(sActivo,0);
        END IF;
		
		--*CONSULTAR*--
        IF pTipoOperacion = 1 THEN 
		
			--SI LOS PARAMETROS RECIBIDOS SON INCORRECTOS RETURNARA CODIGO "361" INDICANDO COMO PARAMETROS INVALIDOS.
			IF NVL(pFechaPct, '') = '' AND NVL(pPctMeta, 0.00) = 0.00 AND NVL(pUsuario, '') = '' AND NVL(pFechaInsert,'')=''  THEN
			
				--CONSULTA TODAS LAS FECHAS DEL PORCENTAJE META QUE EXISTEN EN LA TABLA.
				FOREACH
					SELECT  fecha, secuencia, pct_meta, user_insert, fecha_insert, activo
					INTO dtFecha_PorcMeta, sSecuencia, dPorc_Meta, cCve_Usuario, dtFec_Insert, sActivo
					FROM "informix".sd_meta_reestructura
					WHERE activo = 1
					ORDER BY 1 DESC
					
					RETURN TRIM(cCodRet), TRIM(cCodRetPctMt), NVL(dtFecha_PorcMeta,DATE(1)), NVL(sSecuencia,0), NVL(dPorc_Meta,0.00), NVL(cCve_Usuario,""), NVL(dtFec_Insert,DATE(1)), NVL(sActivo,0) WITH RESUME;
				END FOREACH
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRetPctMt = '166'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA 
					RETURN TRIM(cCodRet), TRIM(cCodRetPctMt), NVL(dtFecha_PorcMeta,DATE(1)), NVL(sSecuencia,0), NVL(dPorc_Meta,0.00) , NVL(cCve_Usuario,""), NVL(dtFec_Insert,DATE(1)), NVL(sActivo,0);	
				END IF
				
			ELSE
			
				LET cCodRetPctMt = '361'; --PARAMETROS INVALIDOS
				RETURN TRIM(cCodRet), TRIM(cCodRetPctMt), NVL(dtFecha_PorcMeta,DATE(1)), NVL(sSecuencia,0), NVL(dPorc_Meta,0.00) , NVL(cCve_Usuario,""), NVL(dtFec_Insert,DATE(1)), NVL(sActivo,0);
			END IF

		--*INSERTAR*--	
        ELIF pTipoOperacion = 2 THEN 
		
			--SI LOS PARAMETROS RECIBIDOS SON INCORRECTOS RETURNARA CODIGO "361" INDICANDO COMO PARAMETROS INVALIDOS.
			IF NVL(pFechaPct, '') = '' OR NVL(pPctMeta, 0.00) = 0.00 OR NVL(pUsuario, '') = '' OR NVL(pFechaInsert,'')=''  THEN
				LET cCodRetPctMt = '361'; --PARAMETROS INVALIDOS
			ELSE
				--SELECCIONA EL VALOR MAXIMO DEL CAMPO SECUENCIA + 1 Y SI EL CAMPO ACTIVO ES NULO CAMBIA A ACTIVO = 0.
				SELECT NVL(MAX(secuencia),0) + 1, NVL(SUM(activo) ,0)
				INTO sSecuencia, sActivo
				FROM "informix".sd_meta_reestructura 
				WHERE fecha = pFechaPct;
				
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN -- SI NO EXISTE EL REGISTRO PERMITE REALIZAR EL ALTA DEL PROCENTAJE
					
					INSERT INTO "informix".sd_meta_reestructura(fecha, secuencia, pct_meta, user_insert, fecha_insert, activo)
					VALUES( pFechaPct, sSecuencia, pPctMeta, pUsuario, pFechaInsert, 1);

					LET cCodRetPctMt = '155'; --REGISTRO AGREGADO CORRECTAMENTE
					
				ELSE
					-- SI EL REGISTRO ESTA ELIMINADO GUARDAMOS EL NUEVO REGISTRO CON LA MAX(SECUENCIA) + 1 Y ACTIVO = 1.
					IF sActivo = 0 THEN
						
						INSERT INTO "informix".sd_meta_reestructura(fecha, secuencia, pct_meta, user_insert, fecha_insert, activo)
						VALUES( pFechaPct, sSecuencia, pPctMeta, pUsuario, pFechaInsert, 1 );
					
						LET cCodRetPctMt = '155'; --REGISTRO AGREGADO CORRECTAMENTE
					ELSE--
					
						LET cCodRetPctMt = '156'; --PORCENTAJE PARA FECHA INDICADA YA EXISTE
					END IF
				END IF
			END IF

		 --*MODIFICAR*--	
        ELIF pTipoOperacion = 3 THEN
		
			--SI LOS PARAMETROS RECIBIDOS SON INCORRECTOS RETURNARA CODIGO "361" INDICANDO COMO PARAMETROS INVALIDOS.
			IF NVL(pFechaPct, '') = '' OR NVL(pPctMeta, 0.00) = 0.00 OR NVL(pUsuario, '') = '' OR NVL(pFechaInsert,'')=''  THEN
				LET cCodRetPctMt = '361'; --PARAMETROS INVALIDOS
			ELSE
				IF pFechaInsert > pFechaPct  THEN -- SI FECHA_INSERT ES MAYOR A FECHA_PCT_META ENTONCES:
					LET cCodRetPctMt ='157';      --NO SE PUEDE MODIFICAR PORCENTAJE CON FECHA MENOR A LA ACTUAL
				ELSE					
					SELECT NVL(secuencia,0) INTO sSecuencia FROM "informix".sd_meta_reestructura WHERE Fecha = pFechaPct AND activo = 1;
					
					IF DBINFO("sqlca.sqlerrd2") = 1 THEN--SI EXISTE REGISTRO PERMITE REALIZAR LA MODIFICACION DEL PORCENTAJE.
					
						--SE ACTUALIZA EL CAMPO "ACTIVO" = 0
						UPDATE "informix".sd_meta_reestructura SET activo = 0 WHERE Fecha = pFechaPct AND activo = 1;
						
						LET sSecuencia = sSecuencia + 1; --INCREMENTA EL CAMPO "SECUENCIA" 	
						
						INSERT INTO "informix".sd_meta_reestructura(fecha, secuencia, pct_meta, user_insert, fecha_insert, activo)
						VALUES( pFechaPct, sSecuencia, pPctMeta, pUsuario, pFechaInsert,1);	--SE INSERTARA LA MISMA FECHA PERO CON EL CAMPO "SECUENCIA"
																							--INCREMENTADO Y EL CAMPO "ACTIVO" = 1.	
						LET cCodRetPctMt = '163'; --MODIFICACIÓN REALIZADA
					
					ELIF DBINFO("sqlca.sqlerrd2") > 1 THEN
					
						LET cCodRetPctMt = '165';					
					ELSE
						LET cCodRetPctMt = '166';					
					END IF					
					
				END IF
			END IF

		--*ELIMINAR*--	
        ELIF pTipoOperacion = 4 THEN
		
			--SI LOS PARAMETROS RECIBIDOS SON INCORRECTOS RETURNARA CODIGO "361" INDICANDO COMO PARAMETROS INVALIDOS.
			IF NVL(pFechaPct, '') = '' AND NVL(pPctMeta, 0.00) = 0.00 AND NVL(pUsuario, '') = '' AND NVL(pFechaInsert,'')=''  THEN
					LET cCodRetPctMt = '361'; --PARAMETROS INVALIDOS
			ELSE
				IF pFechaInsert > pFechaPct THEN
						LET cCodRetPctMt = '158'; --NO SE PUEDE ELIMINAR PORCENTAJE CON FECHA MENOR A LA ACTUAL
				ELSE
					--SE ACTUALIZA PARA QUE A AL MOMENTO DE REALIZAR LA CONSULTA, SE MUESTREN SOLO LAS FECHAS DEL PCT_META CON ACTIVO = 1 
					--Y ESTA FECHA PCT_META CON ACTIVO = 0 ESTE COMO ELIMINADA.
					UPDATE "informix".sd_meta_reestructura 
					SET activo = 0, user_insert  = pUsuario , fecha_insert = pFechaInsert
					WHERE Fecha = pFechaPct 
					AND activo = 1;
					
					IF DBINFO("sqlca.sqlerrd2") = 0 THEN--SI NO EXISTEN REGISTROS NO REALIZA LA ELIMINACION-
					
						LET cCodRetPctMt = '166'; --NO EXISTEN REGISTROS CON EL CRITERIO DE CONSULTA 
					ELSE	
						LET cCodRetPctMt = '160'; --REGISTRO ELIMINADO
					END IF
					
				END IF
			END IF	
        END IF;
		
		IF cCodRet::INTEGER <> 0 OR pTipoOperacion IN(2,3,4) THEN
			RETURN TRIM(cCodRet), TRIM(cCodRetPctMt), NVL(dtFecha_PorcMeta,DATE(1)),NVL(sSecuencia,0), NVL(dPorc_Meta,0.00), NVL(cCve_Usuario,""), NVL(dtFec_Insert,DATE(1)), NVL(sActivo,0);
        END IF;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCIÓN:CONSULTA, INSERTA, MODIFICA O ELIMINA EL CAMPO PORCENTAJE META EN LA TABLA sd_meta_reestructura',
'FECHA DE CREACIÓN: 27-MARZO-2013',
'BASE DE DATOS: BDICRED',
'CREADOR: ISARAI BOJORQUEZ AGUIRRE';

CREATE PROCEDURE "informix".respalda(pEmpresa    CHAR(3), 
                          tp_Respaldo CHAR(1))
RETURNing char(5);

   define CodRet      char(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   define v_directorio char(50);
   define v_dia        char(2);
   define v_mes        char(2);
   define v_ano        char(4);
   define v_tabla      char(20);
   define v_tablaid    integer;
   define v_colnomb    char(20);
   define v_sql        char(1000);
   define nomb_tabla   char(400);
   define v_proceso    char(10);
   define vfecha       DATE;
   define wdir         CHAR(2000);
   define v_numreg     integer;
   define v_hora_ini   datetime hour to fraction;
   DEFINE vMensaje     VARCHAR(100);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "/respaldos/respalda.err";
      TRACE ON;

      LET CodRet = sql_err;
      LET wdir = wdir;
      LET v_sql = v_sql;
 
      UPDATE sd_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             cod_ret     = CodRet,
             mensaje     = vMensaje
       WHERE empresa     = pEmpresa
         AND proceso     = 'RespaldoCred'
         AND fecha       = vFecha;

      UPDATE bdinteg:sx_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             codret      = CodRet 
       WHERE empresa = pEmpresa
         AND proceso = 'RespaldoCred'
         AND fecha   = vFecha;

          RETURN CodRet;
 
   END EXCEPTION;


-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET CodRet         = "000";
   LET v_directorio    = " ";
   LET v_dia           = " ";
   LET v_mes           = " ";
   LET v_ano           = " ";
   LET v_tabla         = " ";
   LET v_tablaid       = 0;
   LET v_colnomb       = " ";
   LET v_sql           = " ";
   LET nomb_tabla      = " ";
   LET v_proceso       = "RespaldoCred";
   LET v_numreg        = 0;
   LET v_hora_ini      = current;
   LET vMensaje        = " ";
-- ***************************************************************************
-- Procesa Informacion
-- ***************************************************************************
   --SET DEBUG FILE TO "respalda.out";
   --TRACE ON;


   SELECT fecha_hoy
     INTO vFecha
     FROM sd_fechas
    WHERE empresa = pEmpresa;

   SELECT COUNT(*)
     INTO v_numreg
     FROM sd_contproc
    WHERE empresa = pEmpresa
      AND proceso = 'RespaldoCred'
      AND fecha   = vFecha;

    IF v_numreg = 0 THEN
	
      INSERT INTO sd_contproc VALUES
         (pEmpresa, 'RespaldoCred', vfecha, 'C', USER, CURRENT, CURRENT,
          CodRet, "No existe param. de ruta de respaldo");

	INSERT INTO bdinteg:sx_contproc
	 (empresa, proceso, fecha, sistema, status_proc,
        ejecutivo, hora_ini, hora_fin, codret)
	VALUES
	 (pEmpresa, 'RespaldoCred', vfecha, '06', 'C',
	  USER, CURRENT, NULL, '000');

    END IF

   SELECT valor
     INTO v_directorio
     FROM sd_param
    WHERE empresa = pempresa
      AND cod_param = '44';

   IF (v_directorio is null OR v_directorio = " ") THEN
      LET CodRet = "120";
      -- Actualiza control de procesos
     UPDATE sd_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             cod_ret     = CodRet,
             mensaje     = vMensaje
       WHERE empresa     = pEmpresa
         AND proceso     = 'RespaldoCred'
         AND fecha       = vFecha;

      UPDATE bdinteg:sx_contproc
         SET status_proc = 'C',
             hora_fin    = CURRENT,
             codret      = CodRet
       WHERE empresa = pEmpresa
         AND proceso = 'RespaldoCred'
         AND fecha   = vFecha;

      RETURN CodRet;
   ELSE
      LET v_directorio = TRIM(v_directorio)||'/';
   END IF
   LET v_dia = DAY(vfecha);
   LET v_mes = MONTH(vfecha);
   LET v_ano = YEAR(vfecha);

   IF v_dia <= 9 THEN
      LET v_dia = "0" || v_dia;
   END IF

   IF v_mes <= 9 THEN
      LET v_mes = "0"||v_mes;
   END IF

   BEGIN
   ON EXCEPTION IN (-668) SET sql_err 
      SET DEBUG FILE TO TRIM(v_tabla) || " respalda.err";
      TRACE ON;
       LET CodRet = "000";
       LET wdir = wdir;
   END EXCEPTION WITH RESUME;
     --BORRA EL CONTENIDO DE LA CARPETA PARA EJEJCUTAR UN POSIBLE RESPALDO
     LET WDIR = 'rm ' || TRIM(v_directorio) || TRIM (tp_Respaldo) || TRIM(v_mes) ||
                TRIM(v_dia) || TRIM (v_ano) || '/sd_*';
     SYSTEM wdir;

     LET WDIR = 'rmdir -p ' || TRIM(v_directorio) || TRIM (tp_Respaldo) || TRIM(v_mes) ||
                TRIM(v_dia) || TRIM (v_ano);
     SYSTEM wdir;


   LET wdir = 'mkdir -p ' ||TRIM(v_directorio)||TRIM(tp_Respaldo)||TRIM(v_mes)||
              TRIM(v_dia)||TRIM(v_ano);
   SYSTEM wdir;
   END;

   SET ISOLATION TO DIRTY READ;
   FOREACH
      SELECT trim(nombre_tabla) INTO v_tabla
      FROM sd_tablas

      LET v_tabla = TRIM(v_tabla);

      SELECT tabid INTO v_tablaid
      FROM systables
      where tabname = v_tabla;

      -- Tabla no existe en la base de datos
      IF v_tablaid is null THEN
         LET CodRet = "121";
          -- Actualiza control de procesos
          INSERT INTO sd_contproc VALUES
                (pEmpresa, 'RespaldoCred', vfecha,
                'C', USER, CURRENT, CURRENT,
                 CodRet, "La Tabla no existe en la Base de Datos");

	    INSERT INTO bdinteg:sx_contproc
	       (empresa, proceso, fecha, sistema, status_proc,
              ejecutivo, hora_ini, hora_fin, codret)
	    VALUES
	       (pEmpresa, 'RespaldoCred', vfecha, '06', 'C',
	        USER, CURRENT, NULL, '000');

         RETURN CodRet;
      END IF

      LET nomb_tabla = TRIM(v_directorio)||
                       TRIM(tp_Respaldo)||TRIM(v_mes)||
                       TRIM(v_dia)||TRIM(v_ano)||'/'||
                       TRIM(v_tabla)||"."||
                       v_dia||v_mes||v_ano||
                       "a"||pempresa;

      LET nomb_tabla = TRIM(nomb_tabla);

      SELECT colname INTO v_colnomb
        FROM syscolumns
       WHERE tabid = v_tablaid
         AND colname = "empresa";

      IF v_colnomb IS NULL THEN
         LET v_sql = 'echo "             '||
              'SET ISOLATION TO DIRTY READ                   ; '||
              'UNLOAD TO ' || nomb_tabla ||' SELECT * FROM '||v_tabla ||';' ||
              '"' ||
              ' > querycred.sql';            
      ELSE
         LET v_sql = 'echo "             '||
              'SET ISOLATION TO DIRTY READ                   ; '||
              'UNLOAD TO ' || nomb_tabla ||' SELECT * FROM '||v_tabla ||';' ||
              '"' ||
              ' > querycred.sql';            
                     
      END IF

      SYSTEM v_sql;
      LET v_sql = "dbaccess bdicred querycred.sql ";
      SYSTEM v_sql;

   END FOREACH
    -- Actualiza control de procesos
   LET CodRet = TRIM(codret);
   IF CodRet = '000' THEN
        UPDATE sd_contproc 
           SET status_proc = 'F',
               hora_inicio = v_hora_ini,
               hora_fin = current,
               cod_ret  = CodRet
         WHERE proceso = 'RespaldoCred'
           AND fecha = vfecha
           AND empresa = pempresa;

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin    = CURRENT,
               codret      = CodRet
         WHERE empresa = pEmpresa
           AND proceso = 'RespaldoCred'
           AND fecha   = vFecha;

   ELSE
        UPDATE sd_contproc 
           SET status_proc = 'C',
               hora_inicio = v_hora_ini,
               hora_fin = current,
               cod_ret  = CodRet
         WHERE proceso = 'RespaldoCred'
           AND fecha = vfecha
           AND empresa = pempresa;

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'C',
               hora_fin    = CURRENT,
               codret      = CodRet
         WHERE empresa = pEmpresa
           AND proceso = 'RespaldoCred'
           AND fecha   = vFecha;

   END IF;
   RETURN CodRet;
END procedure;