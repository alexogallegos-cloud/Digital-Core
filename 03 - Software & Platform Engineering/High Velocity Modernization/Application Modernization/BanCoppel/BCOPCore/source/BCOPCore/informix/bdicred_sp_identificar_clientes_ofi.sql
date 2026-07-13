CREATE PROCEDURE "informix".sp_identificar_clientes_ofi(pEmpresa CHAR(3))										
														
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;          
---DECLARACIONES          
DEFINE cNumCte              		CHAR(20);
DEFINE cNum_cred            		CHAR(20);
DEFINE cRiesgo      	    		CHAR(02);
DEFINE dMontoOtor           		DECIMAL(18,2);
DEFINE dMontoReserva        		DECIMAL(18,2);

DEFINE dtFechaHoy		    		DATE;
DEFINE dtFechaInsert	    		DATE;
DEFINE dtPriDiaMes  	    		DATE;
DEFINE dtFechaAnt2m		    		DATE;
DEFINE dtFechaAnt3m		    		DATE;
DEFINE dtFechaAnt6m		    		DATE;
DEFINE dtFechaAnt6mAtrasos			DATE;
DEFINE dtFechaAnt6mIncrementos  	DATE;
DEFINE dtFechaAnt12m	    		DATE;
DEFINE dtFechains		    		DATE;
DEFINE cCodRet              		CHAR(6); 
DEFINE cMensajeRet          		CHAR(80);
DEFINE iSqlErr      	    		INTEGER;
DEFINE iIsamErr             		INTEGER;
DEFINE cErrorInfo           		CHAR(80);
DEFINE dValorsm			    		DECIMAL(18,2);
DEFINE sIncprev             		SMALLINT;
DEFINE dUtili               		DECIMAL(18,2);
DEFINE cStatus			    		CHAR(2);
DEFINE cCausa			    		CHAR(3);
DEFINE dValorlinutilcred    		DECIMAL(18,2);
DEFINE iDiasvigencia        		INTEGER;
DEFINE cNumprod        	    		CHAR(4);
DEFINE cUSER        	    		CHAR(20);
DEFINE sDiasMinimosAper     		SMALLINT;
DEFINE sLineaCredito        		SMALLINT;
DEFINE sNumIncremPrevios 			SMALLINT;
DEFINE sNumVencidos 				SMALLINT;
DEFINE sMesesTrancurridos   		SMALLINT;
DEFINE dtFecha_apertura     		DATE;

DEFINE dAum2 			  			DECIMAL(18,2);
DEFINE dAum1 		      			DECIMAL(18,2);
DEFINE dLineaSugerida     			DECIMAL(18,2);
DEFINE dLincredSolicitada 			DECIMAL(18,2);
DEFINE smblinsug          			DECIMAL(18,2);
DEFINE iStatusTarjetas    			INTEGER;
DEFINE iStatusPrestamos   			INTEGER;
DEFINE iNumVencidosTarjeta 			INTEGER;
DEFINE iVencidos            		INTEGER;
DEFINE iNumVencidosPrestamos  		INTEGER;

DEFINE iExcepciones    				INTEGER;
DEFINE iSitEspRechazo  				INTEGER;
DEFINE cMotivo         				CHAR(1);
DEFINE cTipoRech       				CHAR(1);
DEFINE dMaxMtoUdi      				DECIMAL(14,2);
DEFINE dValorUdi       				DECIMAL(14,6);
DEFINE cCodUdi         				CHAR(2);
DEFINE cClase          				CHAR(1);
DEFINE sLineaCreditoBC      		SMALLINT;
DEFINE sLineaCreditoCAC     		INTEGER;  
DEFINE iBanderaUtilizacion  		SMALLINT;  
DEFINE cBegin  						CHAR(1);  
DEFINE cPregunta  					CHAR(200); 
DEFINE cSucursal  					CHAR(4); 
DEFINE cComIngreso  				CHAR(2); 
DEFINE cNumctecop  					CHAR(20); 
DEFINE dValor_reserva       		DECIMAL(18,2);
DEFINE dValorreserva        		DECIMAL(18,2);
DEFINE iRevisionCac        			SMALLINT;
DEFINE iNumMesesAtrasos        		SMALLINT;
DEFINE iNumMesesIncrementosPrevios  SMALLINT;
DEFINE cEjecutivo         			CHAR(8);

--Homologacion.
DEFINE iDiasVigenciaHomo  			INTEGER;
DEFINE cNumSolSIC  					CHAR(20);
DEFINE dtFechaSic 					DATE;
DEFINE cConsultaSic  				CHAR(2);
DEFINE cCod_ret                		CHAR(5);
--Declaracion variables sp_valida_respuesta_bc_ofi.
DEFINE cCodigoRetorno 				CHAR(6);
DEFINE vcDescripcionError			VARCHAR(255);
DEFINE cMensajeResp					VARCHAR(200);
--IPCB se integra variable para lectura de la instituciÃ³n de la consulta a BC
DEFINE institucion_sic              CHAR(2);
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
DEFINE ccausaRT    					CHAR(4);
	
---INICIALIZACIONES
LET cNumCte                			= "";
LET cNum_cred              			= "";
LET cRiesgo                			= "";
LET dMontoOtor             			= 0;
LET dMontoReserva          			= 0;

LET dtFechaHoy			   			= DATE(1);
LET dtFechaInsert		   			= DATE(1);
LET dtPriDiaMes            			= DATE(1);
LET dtFechains			   			= DATE(1);
LET dtFechaAnt2m		   			= DATE(1);
LET dtFechaAnt3m		   			= DATE(1);
LET dtFechaAnt6m		   			= DATE(1);
LET dtFechaAnt6mAtrasos		   		= DATE(1);
LET dtFechaAnt6mIncrementos	   		= DATE(1);
LET dtFechaAnt12m		   			= DATE(1);
LET dValorsm				   		= 0;
LET dValorlinutilcred	   			= 0;
LET sIncprev			       		= 0;
LET dUtili			       			= 0;
LET cStatus                			= "";
LET cCausa                 			= "";
LET iDiasvigencia	       			= 0;
LET cNumprod               			= "";
LET cUSER                  			= USER;
LET iSqlErr                			= 0;
LET iIsamErr               			= 0;
LET cErrorInfo             			= "";
LET cCodRet                			= "000000";
LET cMensajeRet            			= "Se realizÃ³ la consulta correctamente";
LET sDiasMinimosAper       			= 0;
LET sLineaCredito      				= 0;
LET sNumIncremPrevios 				= 0;
LET sNumVencidos 					= 0;
LET sMesesTrancurridos 				= 0;
LET dtFecha_apertura 				= DATE(1);

LET dAum2 							= 0;
LET dAum1 							= 0;
LET dLineaSugerida 					= 0;
LET smblinsug 						= 0;
LET iStatusTarjetas 				= 0;
LET iStatusPrestamos 				= 0;
LET iNumVencidosTarjeta 			= 0;
LET iVencidos 						= 0;
LET iNumVencidosPrestamos 			= 0;

LET iExcepciones    				= 0;
LET iSitEspRechazo  				= 0;
LET cMotivo         				= "";
LET cTipoRech       				= "";
LET dMaxMtoUdi      				= 0;
LET dValorUdi       				= 0;
LET cCodUdi         				= "";
LET cClase          				= "";
LET cCodRet         				= "000000";  
LET sLineaCreditoBC  				= 0;
LET sLineaCreditoCAC  				= 0;
LET iBanderaUtilizacion  			= 0;
LET dLincredSolicitada  			= 0;
LET cBegin  						= "N";
LET cPregunta  						= "";
LET cSucursal  						= "";
LET cComIngreso  					= "";
LET cNumctecop  					= "";
LET dValor_reserva     				= 0;
LET dValorreserva      				= 0;
LET iRevisionCac      				= 0;
LET iNumMesesAtrasos      			= 0;
LET iNumMesesIncrementosPrevios     = 0;
LET cEjecutivo      				= "";

--Homologacion.
LET iDiasVigenciaHomo				= 7;
LET cNumSolSIC 						= ""; 
LET dtFechaSic 						= DATE(1);
LET cConsultaSic 					= "";
LET cCod_ret                		= "000";
--Declaracion variables sp_valida_respuesta_bc_ofi.
LET cCodigoRetorno 					= "000000";
LET vcDescripcionError 				= "";
LET cMensajeResp 				= "";
--IPCB se integra variable para lectura de la instituciÃ³n de la consulta a BC
LET institucion_sic                 ='BC';
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
LET ccausaRT 						= "";
--SET DEBUG FILE TO '/home/sysifx/jesusm/sp_identificar_clientes_ofi.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
    LET cMensajeRet= cErrorInfo;
    RETURN cCodRet, cMensajeRet;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--/////////////////////////////////////////////////////////
--  obtiene la fecha del dÃ­a
    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;
-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual menor a 1.27 sm 
SELECT valor 
  INTO dAum2
  FROM bdicred:"informix".sd_param 
 WHERE empresa   = pEmpresa 
   AND cod_param = '017';	

-- validacion de los parametros.
IF NVL(dAum2,"") = "" THEN
    LET cCodRet     = "000001";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos menores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum1
  FROM bdicred:"informix".sd_param 
 WHERE empresa = pEmpresa 
   AND cod_param = '016';

-- validacion de los parametros.
IF NVL(dAum1,"") = "" THEN
    LET cCodRet     = "000002";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

--////////////////////////////////////////////////////////
SELECT pri_dia_mes 
  INTO dtPriDiaMes
  FROM bdicred:"informix".sd_fechas
 WHERE empresa = pEmpresa;
	  
IF NVL(pEmpresa,"") = "" THEN
    LET cCodRet     = "000003";
	LET cMensajeRet = "ParÃ¡metro requerido esta vacÃ­o";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor del salario minimo de la zona C
SELECT valor 
  INTO dValorsm
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '013'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(dValorsm,"")  = "" THEN
    LET cCodRet     = "000004";
	LET cMensajeRet = "Error al obtener el parÃ¡metro del valor del salario mÃ­nimo";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor del procentaje de utilizacion para los crÃ©ditos
SELECT valor 
  INTO dValorlinutilcred
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '019'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(dValorlinutilcred,"") = "" THEN
    LET cCodRet     = "000005";
	LET cMensajeRet = "Error al obtener el parÃ¡metro de la cantidad de utilizaciÃ³n de la lÃ­nea de crÃ©dito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor de los dias de vigencia de los crÃ©ditos
SELECT valor 
  INTO iDiasvigencia
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '011'
   AND empresa = pEmpresa ;

-- validaciÃ³n de los parametros.
IF NVL(iDiasvigencia,"") = "" THEN
    LET cCodRet     = "000006";
	LET cMensajeRet = "Error al obtener el parÃ¡metro de los dÃ­as de vigencia del crÃ©dito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- DÃ­as mÃ­nimos de apertura de crÃ©ditos
SELECT valor 
  INTO sDiasMinimosAper
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '021'
   AND empresa = pEmpresa ;

IF NVL(sDiasMinimosAper,"") = "" THEN
    LET cCodRet     = "000007";
	LET cMensajeRet = "Error al obtener los dÃ­as mÃ­nimos de apertura de crÃ©ditos";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara crÃ©d con lÃ­n crÃ©d MN para increm lÃ­nea
SELECT valor 
  INTO sLineaCredito
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '023'
   AND empresa = pEmpresa ;

IF NVL(sLineaCredito,"") = "" THEN
    LET cCodRet     = "000008";
	LET cMensajeRet = "Error al obtener la lÃ­nea de crÃ©dito a comparar para incrementos de lÃ­nea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- NÃºmero incrementos previos para increm lÃ­nea
SELECT valor 
  INTO sNumIncremPrevios
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '024'
   AND empresa = pEmpresa ;

IF NVL(sNumIncremPrevios,"") = "" THEN
    LET cCodRet     = "000009";
	LET cMensajeRet = "Error al obtener el nÃºmero incrementos previos para incrementos de lÃ­nea";
	RETURN cCodRet, cMensajeRet;
END IF;


-- Compara lÃ­nea crÃ©dito para enviar a BC 
SELECT valor 
  INTO sLineaCreditoBC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '027'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoBC,"") = "" THEN
    LET cCodRet     = "000010";
	LET cMensajeRet = "Error al obtener la lÃ­nea crÃ©dito para enviar a BC para incrementos de lÃ­nea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara lÃ­nea crÃ©dito para enviar aL CAC 
SELECT valor 
  INTO sLineaCreditoCAC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '043'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoCAC,"") = "" THEN
    LET cCodRet     = "000011";
	LET cMensajeRet = "Error al obtener la lÃ­nea crÃ©dito para enviar al CAC para incrementos de lÃ­nea";
	RETURN cCodRet, cMensajeRet;
END IF;
-- obtener el valor del de la reserva
SELECT valor 
  INTO dValor_reserva
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '018'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(dValor_reserva,"") = "" THEN
    LET cCodRet     = "000012";
	LET cMensajeRet = "Error al obtener el parÃ¡metro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;

-----------------------------------------------
-- obtener el valor del de la reserva
SELECT valor 
  INTO iNumMesesAtrasos
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '008'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(iNumMesesAtrasos,"") = "" THEN
    LET cCodRet     = "000013";
	LET cMensajeRet = "Error al obtener el parÃ¡metro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;


-- obtener el valor del de la reserva
SELECT valor 
  INTO iNumMesesIncrementosPrevios
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '009'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(iNumMesesIncrementosPrevios,"") = "" THEN
    LET cCodRet     = "000014";
	LET cMensajeRet = "Error al obtener el parÃ¡metro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;


LET dValorreserva = (dValor_reserva * dValorsm) * 30.42;

CALL bdicred:monthadd(dtFechaHoy,-2)  RETURNING dtFechaAnt2m; -- 60 dÃ­as
CALL bdicred:monthadd(dtFechaHoy,-3)  RETURNING dtFechaAnt3m; -- 90 dÃ­as
CALL bdicred:monthadd(dtFechaHoy,-6)  RETURNING dtFechaAnt6m; -- 180 dÃ­as
CALL bdicred:monthadd(dtFechaHoy,-iNumMesesAtrasos)  RETURNING dtFechaAnt6mAtrasos; 
CALL bdicred:monthadd(dtFechaHoy,-iNumMesesIncrementosPrevios)  RETURNING dtFechaAnt6mIncrementos; 

CALL bdicred:monthadd(dtFechaHoy,-12) RETURNING dtFechaAnt12m; -- 360 dÃ­as
FOREACH 
	SELECT a.num_credito,
           a.numcte, 
           c.grado_riesgo,
           b.monto_otorgado,
           nvl(c.reserva_calificacion,0),
           a.num_producto,
		   a.fecha_apertura,
		   d.sucursal,
		   d.fecha_insert,
		   d.comp_ingreso,
		   d.numcte_cop,
		   d.lincred_solicitada,
		   d.user_insert,mensaje 
      INTO cNum_cred, cNumCte, cRiesgo, dMontoOtor, dMontoReserva,cNumprod,dtFecha_apertura,cSucursal,
		  dtFechaInsert,cComIngreso,cNumctecop,dLincredSolicitada,cEjecutivo,cMensajeResp
	  FROM bdicred:"informix".sd_bitacora_aumlincred d
	  INNER JOIN bdicred:"informix".sd_maecredcont a ON d.num_solicitud = a.num_credito 
	  JOIN bdicred:"informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
	  LEFT OUTER JOIN bdicred:"informix".sd_hist_reserva c ON c.empresa = b.empresa AND c.num_credito = b.num_credito AND c.fecha_cierre = dtPriDiaMes - 1
	  WHERE d.origen = "S"
	  AND status = "PC"
	   AND a.fecha = dtPriDiaMes - 1
       AND a.empresa     = pEmpresa
	   AND a.num_credito = d.num_solicitud       
	   AND (a.id_unidad_prod is null or a.id_unidad_prod = '')
       AND (a.cod_caract is null or a.cod_caract = '')
       AND (a.cod_caract_2 is null or a.cod_caract_2 = '')
	   
	IF  NVL(cNum_cred,"") = "" THEN 		
		CONTINUE FOREACH;
	END IF;
						----Calculo de la linea de crÃ©dito
---*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*-	  
--Si la lÃ­nea de crÃ©dito actual es menor a 2100 MN (1.27 SM zona C aproximadamente), se autoriza el incremento por parte del banco y queda pendiente la autorizaciÃ³n del cliente
	IF (dMontoOtor < sLineaCredito) THEN --se compara en pesos y no en salarios mÃ­nimos
        LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAum2),-2);      
    ELSE
        LET dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAum1),-2);
    END IF;
    LET smblinsug = dLineaSugerida / (30.42 * dValorsm);

	 -----Se Guarda el registro en bitacora

	--se actualiza la informaciÃ³n de la solicitud
	UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	SET lincred_actual = dMontoOtor,
		lincred_sugerida = dLineaSugerida,
		smb_lincred = smblinsug,
		grado_riesgo = cRiesgo,
		monto_reserva = dMontoReserva
	WHERE fecha_insert  = dtFechaInsert
	AND numcte          = cNumCte
	AND num_solicitud   = cNum_cred
	AND empresa         = pEmpresa;	
     -------------------------
	LET cStatus     = "";
---*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*-

	IF cRiesgo IS NULL THEN LET cRiesgo = ""; END IF;

	---Se valida el que el cliente este al corriente de sus pagos....
		SELECT COUNT (*)		--IFRS MACF
		INTO iStatusTarjetas
		FROM bdicred:"informix".sd_maesdos a
		WHERE a.num_credito = cNum_cred
		AND (a.monto_vencido + a.mto_venc_trasp) > 0;

		IF iStatusTarjetas = 0 THEN --checar los prestamos con los que cuenta el cliente y verificar si presenta algun vencido
			SELECT COUNT (*)		--IFRS MACF
			INTO iStatusTarjetas
			FROM bdicred:"informix".sd_maecredcrd a,
			     bdicred:"informix".sd_maesdoscrd b
			WHERE a.numcte = cNumCte
			AND a.num_credito = b.num_credito
			AND (b.monto_vencido + b.mto_venc_trasp) > 0 ;
		
								 
		END IF;
--Si la lÃ­nea de crÃ©dito actual del crÃ©dito es menor a 2100 MN (1.27 SM zona C aproximadamente) se precalifica
--    IF dMontoOtor < 2100 THEN -- compara la linea de credito en pesos y ya no en salarios mÃ­nimos  
   IF dMontoOtor < sLineaCredito THEN -- compara la linea de credito en pesos y ya no en salarios mÃ­nimos  			
		--si existe algun status se cancela la solicitud con causa CVB
		IF ( iStatusTarjetas > 0) THEN
			LET cStatus = "CN";
			LET cCausa  = "CVB";	
		ELSE --se apertura
			LET cStatus = "AT";
			LET cCausa  = "";	
		END IF;		
   ELSE
			IF ( iStatusTarjetas > 0) THEN
					LET cStatus = "CN";
					LET cCausa  = "CVB";					
			ELSE
				--Se descartan los crÃ©ditos con grado de riesgo D, E y C (para este Ãºltimo con monto de reserva mayor a 600 MN (0.37 SM zona C aproximadamente))
				IF (cRiesgo NOT IN ("A","B1","B2")) OR ((cRiesgo = "C") AND (dMontoReserva > dValorreserva)) THEN -- se compara en pesos y ya no en salarios mÃ­nimos
					LET cStatus = "RT";
					LET cCausa  = "RGR";					
				ELSE
					IF dtFecha_apertura  > dtFechaHoy - sDiasMinimosAper THEN
						--se cumple una excepcion y se guarda en la tabla de excepciones
						INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
						(empresa,num_solicitud,excepciones,usuario,fecha_insert)
						VALUES (pEmpresa, cNum_cred,"001",USER,CURRENT);
						LET iExcepciones = 1;
					END IF;
					---Se busca si tiene el crÃ©dito atrasos durante los ultimos 6 meses
					SELECT COUNT(num_credito)
						INTO iNumVencidosTarjeta
					FROM bdicred:"informix".sd_amortiza_credito
					WHERE empresa        = pEmpresa
					AND num_credito    = cNum_cred
					--AND capital_status_ant IN ("2","7")
					AND capital_status_ant IN ("2","7","6")   -- IFRS MACF
					AND fecha_cuota BETWEEN dtFechaAnt6mAtrasos AND dtFechaHoy;
					IF(iNumVencidosTarjeta > sNumVencidos) THEN
						LET iVencidos = 1;
					ELSE
						SELECT COUNT(num_credito)
						INTO iNumVencidosPrestamos
						FROM bdicred:"informix".sd_amortiza_creditocrd
						WHERE empresa        = pEmpresa
						AND num_credito    = cNum_cred
						--AND capital_status_ant IN ("2","7")
						AND capital_status_ant IN ("2","7","6") -- IFRS MACF
						AND fecha_cuota BETWEEN dtFechaAnt6mAtrasos AND dtFechaHoy;
						IF(iNumVencidosPrestamos > sNumVencidos) THEN
							LET iVencidos = 1;
						END IF;
					END IF; 

					IF iVencidos = 1 THEN
						INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
						(empresa,num_solicitud,excepciones,usuario,fecha_insert)
						VALUES (pEmpresa, cNum_cred,"002",USER,CURRENT);	
						LET iExcepciones = 1;						
					END IF;
					---clientes que cuenten con 6 meses desde el ultimo incremento en su TDC

					SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)} MAX(fecha_status)
						INTO dtFechains
					FROM bdicred:"informix".sd_bitacora_aumlincred 
					WHERE numcte  = cNumCte
					AND empresa = pEmpresa
					AND status = 'AP';

					IF dtFechains IS NULL OR dtFechains = '' THEN LET dtFechains = date(1); END IF;

					IF dtFechains >= dtFechaAnt6m  AND dtFechains <= today THEN  --6 meses
						--se guarda la excepcion 3
						INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
						(empresa,num_solicitud,excepciones,usuario,fecha_insert)
						VALUES (pEmpresa, cNum_cred,"003",USER,CURRENT);	
						LET iExcepciones = 1;						
					END IF;		

					--Cuenta los incrementos que ha tenido el crÃ©dito
					SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)} nvl(count(status),0)
						INTO sIncprev
					FROM bdicred:"informix".sd_bitacora_aumlincred 
					WHERE numcte  = cNumCte
					AND empresa = pEmpresa
					AND status = 'AP';

					--Cuenta con mÃ¡s de 3 incrementos previos
					IF (sIncprev > sNumIncremPrevios) THEN 
						--Se busca si el crÃ©dito tiene una utilizaciÃ³n de la lÃ­nea igual o mayor al 80% en los Ãºltimos 12 meses
						SELECT COUNT(num_credito) 
						INTO dUtili
						FROM bdicred:"informix".sd_hist_reserva
						WHERE empresa     = pEmpresa
						AND num_credito = cNum_cred
						AND fecha_cierre BETWEEN dtFechaAnt12m AND dtFechaHoy
						AND porcentaje_uso >= dValorlinutilcred;
						-- LÃ­nea utilizaciÃ³n del 80% 
						IF (dUtili < 2) THEN       
							LET iBanderaUtilizacion=1;
						END IF;	
					ELSE
						SELECT COUNT(num_credito) 
						INTO dUtili
						FROM bdicred:"informix".sd_hist_reserva
						WHERE empresa        = pEmpresa
						AND num_credito    = cNum_cred
						AND fecha_cierre BETWEEN dtFechaAnt6mIncrementos AND dtFechaHoy
						AND porcentaje_uso >= dValorlinutilcred;

						IF (dUtili < 1) THEN        
							LET iBanderaUtilizacion=1;
						END IF;
					END IF;
					
					IF (iBanderaUtilizacion = 1) THEN --excepcion 4
						INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
						(empresa,num_solicitud,excepciones,usuario,fecha_insert)
						VALUES (pEmpresa, cNum_cred,"004",USER,CURRENT);
						LET iExcepciones = 1;
					END IF;
					
					--Validar Comprobante de ingresos:
					IF (cComIngreso = "S") THEN
						INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
						(empresa,num_solicitud,excepciones,usuario,fecha_insert)
						VALUES (pEmpresa, cNum_cred,"005",USER,CURRENT);
						LET iExcepciones = 1;
					END IF;
					--Validar linea de credito  > 21000
					IF (dLineaSugerida >= sLineaCreditoCAC) THEN
						INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
						(empresa,num_solicitud,excepciones,usuario,fecha_insert)
						VALUES (pEmpresa, cNum_cred,"006",USER,CURRENT);
						LET iExcepciones = 1;
						
					END IF;								
				END IF;	--valdiacion de los grados de riesgo
			END IF;   END IF; ---if de la validacion de los 2100 pesos   
   			
	IF iExcepciones	> 0 AND NVL(cNumctecop,"") <> "" THEN	----Validacion de clientes Coppel 		
		--SE GUARDA UN REGISTRO PARA ENVIAR A CONSULTAR EN COPPEL
		LET cStatus     = "EC";		
		INSERT INTO bdicred:"informix".sd_consultar_infoctecoppel
		(empresa, numcte, numcte_ref, num_solicitud, fecha_envio, hora_envio, status_envio, user_insert, fecha_insert,user_tramite,sucursal)
		VALUES(pEmpresa,cNumCte,cNumctecop,cNum_cred,TODAY,CURRENT HOUR TO FRACTION,0,USER,CURRENT,cEjecutivo,cSucursal);			
	END IF;	--IF (dLineaSugerida >= sLineaCreditoBC) AND cStatus = ""  THEN --se compara en pesos y no en salarios mÃ­nimos
	IF cStatus = ""  THEN --se compara en pesos y no en salarios mÃ­nimos
		LET cStatus     = "BC";
	ELSE
		IF ((dLineaSugerida >= sLineaCreditoCAC) AND cStatus = "") OR (iExcepciones > 0 AND cStatus = "") THEN --se compara en pesos y no en salarios mÃ­nimos
		   LET cStatus     = "AC";		ELIF ((dLineaSugerida < sLineaCreditoCAC) AND cStatus = "") AND (iExcepciones = 0  AND cStatus = "") THEN 
		   LET cStatus     = "AT";		END IF;
	END IF;
	 
	UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	SET status          = cStatus,
		causa_status 	= cCausa,
		fecha_status    = today,
		hora_status     = CURRENT,
		revisioncac     = iExcepciones
	WHERE fecha_insert  = dtFechaInsert
	AND numcte          = cNumCte
	AND num_solicitud   = cNum_cred
	AND empresa         = pEmpresa;
	
	INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
	VALUES(pEmpresa, cNum_cred, cStatus, cCausa, cUSER, dtFechaHoy, dtFechaHoy, 0);
	
	
	IF cstatus= "AT" AND iExcepciones	= 0 THEN		
		EXECUTE PROCEDURE bdicred:"informix".sp_registrarrespuestacte(pEmpresa,cNum_cred,'1',cMensajeResp,cSucursal,'sistema') INTO cCodRet, cMensajeRet;
		CONTINUE FOREACH;
	END IF;		
	
	IF cStatus= "BC" THEN ------Envio a Buro de crÃ©dito				
		--------------------------------HOMOLOGACION CON PROCESO PRODUCTIVO ----------------------------------		
		------Obtencion del parametro de dias de vigencia de consultas SIC
		SELECT valor
		INTO iDiasVigenciaHomo
		FROM bdisolic:"informix".ss_param
		WHERE empresa = pEmpresa
		AND secuencia = 362;
		
		IF NVL(iDiasVigenciaHomo,0) = 0 THEN
			LET iDiasVigenciaHomo = 0; 
		END IF;   	    
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB --se extrae el nuevo campo causa_rt, para validar los rechazos		
		SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
		INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT			   
		FROM bdisolic:"informix".ss_solicitudes_sic
		WHERE rowid = (SELECT MAX(rowid)
					   FROM bdisolic:"informix".ss_solicitudes_sic
					   WHERE numcte= cNumCte
					   AND (fecha_sic >= dtFechaHoy - iDiasVigenciaHomo or fecha_sic IS NULL));
					   
		--IPCB se integra variable para lectura de la instituciÃ³n de la consulta a BC
		SELECT status_solicitud
		  INTO institucion_sic
		  FROM bdisolic:"informix".ss_status_sol 
	     WHERE empresa = pEmpresa 
		   AND tipo_auto = '1';							   
						   
		IF cNumSolSIC IS NULL THEN 
			INSERT INTO bdisolic:"informix".ss_solicitudes_sic
				(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
			VALUES(pEmpresa,cNumCte,cNum_cred,cNum_cred,institucion_sic,dtFechaHoy,NULL);
			
			--se guarda en tabla de control para envios a consulta SIC's de incrementos de linea
			INSERT INTO bdicred:"informix".sd_solicitudes_aumlincred_sucursal
			(empresa, institucion, num_credito, numcte, status, origen, sucursal, fecha_envio, fecha_respuesta) 
			VALUES (pEmpresa, 'BC', cNum_cred, cNumCte, 'BC', 'S',cSucursal,TODAY,null);
				
		   EXECUTE PROCEDURE bdiburo:"informix".burocred(pEmpresa, "0001", "BC", cNum_cred, 0) 
		   INTO cCod_ret;
		ELSE
			IF dtFechaSic IS NULL THEN 
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic
				(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
				VALUES(pEmpresa,cNumCte,cNum_cred,cNumSolSIC,institucion_sic,dtFechaHoy,NULL);
			ELSE
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic
				(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic,causa_rt)
				VALUES(pEmpresa,cNumCte,cNum_cred,cNumSolSIC,cConsultaSic,dtFechaHoy,dtFechaSic,ccausaRT);			
			   	IF ( cConsultaSic = 'CC' ) THEN	--pasar status a CC
					UPDATE bdicred:"informix".sd_bitacora_aumlincred 
					SET status          = cStatus,
						fecha_status    = today,
						hora_status     = CURRENT,
						revisioncac     = iRevisionCac
					WHERE fecha_insert  = dtFechaInsert
					AND numcte          = cNumCte
					AND num_solicitud   = cNum_cred
					AND empresa         = pEmpresa;
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, cStatus, cCausa, cUSER, dtFechaHoy, dtFechaHoy, 0);	
				END IF;
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB	
				IF ccausaRT = 'RCB' THEN				
					UPDATE bdicred:"informix".sd_bitacora_aumlincred 
					SET status          = 'RT',
						causa_status 	= 'RCB',
						fecha_status    = dtFechaHoy,
						hora_status     = CURRENT,
						revisioncac     = 0
					WHERE fecha_insert  = dtFechaHoy
					AND numcte          = cNumCte
					AND num_solicitud   = cNum_cred
					AND empresa         = pEmpresa;
			
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, 'RT', 'RCB', 'sistema', dtFechaHoy, dtFechaHoy, 0);

					IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = cNumCte and num_Solicitud = cNum_cred and fecha_sic is null) THEN
						UPDATE bdisolic:"informix".ss_solicitudes_sic set fecha_sic = dtFechaHoy, causa_rt = 'RCB'
						WHERE numcte = cNumCte and num_Solicitud = cNum_cred and fecha_sic is null;					
					END IF;
				ELSE
					EXECUTE PROCEDURE bdiburo:"informix".sp_valida_respuesta_bc_ofi(pEmpresa,cNumSolSIC)
					INTO cCodigoRetorno,vcDescripcionError;
				END IF;				
			END IF;
		END IF;
		--------------------------------FIN DE HOMOLOGACION CON PROCESO PRODUCTIVO ---------------------------			
	END IF;	
	LET cCausa = "";
	LET cStatus = "";
	LET cMensajeResp = "";
	LET iExcepciones = 0;
	
END FOREACH;
LET cCodRet         = "000000"; 
LET cMensajeRet     = "Se realizÃ³ la consulta correctamente";
  RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se crea procedimiento para evaluacion de creditos para ver si son prospectos a un incremento de su linea de credito',
'AUTOR : JesÃºs Manuel Aguilar Heredia',
'FECHA : 14/NOVIEMBRE/2011',
'BD    : BDICRED',
'VERSION:20111114.1530',
'MODIFICACION: Se modifico para hacer la homologacion con proceso productivo',
'AUTOR: Guadalupe Payan',
'FECHA: Junio 2012',
'VERSION: 20120612.1024';

CREATE PROCEDURE "informix".sp_identificar_clientes_ofi(pEmpresa CHAR(3),pSolicitud CHAR(20))										
														
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;          
---DECLARACIONES          
DEFINE cNumCte              		CHAR(20);
DEFINE cNum_cred            		CHAR(20);
DEFINE cRiesgo      	    		CHAR(02);
DEFINE dMontoOtor           		DECIMAL(18,2);
DEFINE dMontoReserva        		DECIMAL(18,2);

DEFINE dtFechaHoy		    		DATE;
DEFINE dtFechaInsert	    		DATE;
DEFINE dtPriDiaMes  	    		DATE;
DEFINE dtFechaAnt2m		    		DATE;
DEFINE dtFechaAnt3m		    		DATE;
DEFINE p_FechaAnt4m         		DATE;
DEFINE dtFechaAnt6m		    		DATE;
DEFINE dtFechaAnt6mAtrasos			DATE;
DEFINE dtFechaAnt6mIncrementos  	DATE;
DEFINE dtFechaAnt12m	    		DATE;
DEFINE dtFechains		    		DATE;
DEFINE cCodRet              		CHAR(6); 
DEFINE cMensajeRet          		CHAR(80);
DEFINE iSqlErr      	    		INTEGER;
DEFINE iIsamErr             		INTEGER;
DEFINE cErrorInfo           		CHAR(80);
DEFINE dValorsm			    		DECIMAL(18,2);
DEFINE sIncprev             		SMALLINT;
DEFINE dUtili               		DECIMAL(18,2);
DEFINE cStatus			    		CHAR(2);
DEFINE cCausa			    		CHAR(3);
DEFINE dValorlinutilcred    		DECIMAL(18,2);
DEFINE dPorcMaxUti          		DECIMAL(18,2);
DEFINE iDiasvigencia        		INTEGER;
DEFINE cNumprod        	    		CHAR(4);
DEFINE cUSER        	    		CHAR(20);
DEFINE sDiasMinimosAper     		SMALLINT;
DEFINE sLineaCredito        		SMALLINT;
DEFINE sNumIncremPrevios 			SMALLINT;
DEFINE sNumVencidos 				SMALLINT;
DEFINE sMesesTrancurridos   		SMALLINT;
DEFINE dtFecha_apertura     		DATE;
DEFINE iFlagRtPagMin    			INTEGER;
DEFINE dtFechaPago            		DATE;
DEFINE dPagoMin            			DECIMAL(18,2);
DEFINE dtFechaAux            		DATE;
DEFINE dPagado            			DECIMAL(18,2);
DEFINE vgrupo						CHAR(1);

DEFINE dAum2 			  			DECIMAL(18,2);
DEFINE dAum1 		      			DECIMAL(18,2);
DEFINE dAum3            			DECIMAL(18,2);
DEFINE dLineaSugerida     			DECIMAL(18,2);
DEFINE dLincredSolicitada 			DECIMAL(18,2);
DEFINE smblinsug          			DECIMAL(18,2);
DEFINE iStatusTarjetas    			INTEGER;
DEFINE iStatusPrestamos   			INTEGER;
DEFINE iNumVencidosTarjeta 			INTEGER;
DEFINE iVencidos            		INTEGER;
DEFINE iNumVencidosPrestamos  		INTEGER;

DEFINE iExcepciones    				INTEGER;
DEFINE iSitEspRechazo  				INTEGER;
DEFINE cMotivo         				CHAR(1);
DEFINE cTipoRech       				CHAR(1);
DEFINE dMaxMtoUdi      				DECIMAL(14,2);
DEFINE dValorUdi       				DECIMAL(14,6);
DEFINE cCodUdi         				CHAR(2);
DEFINE cClase          				CHAR(1);
DEFINE sLineaCreditoBC      		SMALLINT;
DEFINE sLineaCreditoCAC     		INTEGER;  
DEFINE iBanderaUtilizacion  		SMALLINT;  
DEFINE cBegin  						CHAR(1);  
DEFINE cPregunta  					CHAR(200); 
DEFINE cSucursal  					CHAR(4); 
DEFINE cComIngreso  				CHAR(2); 
DEFINE cNumctecop  					CHAR(20); 
DEFINE dValor_reserva       		DECIMAL(18,2);
DEFINE dValorreserva        		DECIMAL(18,2);
DEFINE iRevisionCac        			SMALLINT;
DEFINE iNumMesesAtrasos        		SMALLINT;
DEFINE iNumMesesIncrementosPrevios  SMALLINT;
DEFINE cEjecutivo         			CHAR(8);

--Homologacion.
DEFINE iDiasVigenciaHomo  			INTEGER;
DEFINE cNumSolSIC  					CHAR(20);
DEFINE dtFechaSic 					DATE;
DEFINE cConsultaSic  				CHAR(2);
DEFINE cCod_ret                		CHAR(5);
--Declaracion variables sp_valida_respuesta_bc_ofi.
DEFINE cCodigoRetorno 				CHAR(6);
DEFINE vcDescripcionError			VARCHAR(255);
DEFINE cMensajeResp					VARCHAR(200);
--IPCB se integra variable para lectura de la institución de la consulta a BC
DEFINE institucion_sic      		CHAR(2);
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
DEFINE ccausaRT    					CHAR(4);
DEFINE vsituacion					CHAR(1);
DEFINE vcausas						SMALLINT;
DEFINE vsitesp						CHAR(1);
DEFINE sLineaCreditoMax				INTEGER;

---INICIALIZACIONES
LET cNumCte                			= "";
LET cNum_cred              			= "";
LET cRiesgo                			= "";
LET dMontoOtor             			= 0;
LET dMontoReserva          			= 0;

LET dtFechaHoy			   			= DATE(1);
LET dtFechaInsert		   			= DATE(1);
LET dtPriDiaMes            			= DATE(1);
LET dtFechains			   			= DATE(1);
LET dtFechaAnt2m		   			= DATE(1);
LET dtFechaAnt3m		   			= DATE(1);
LET p_FechaAnt4m            		= DATE(1);
LET dtFechaAnt6m		   			= DATE(1);
LET dtFechaAnt6mAtrasos		   		= DATE(1);
LET dtFechaAnt6mIncrementos	   		= DATE(1);
LET dtFechaAnt12m		   			= DATE(1);
LET dValorsm				   		= 0;
LET dValorlinutilcred	   			= 0;
LET dPorcMaxUti						= 0;
LET sIncprev			       		= 0;
LET dUtili			       			= 0;
LET cStatus                			= "";
LET cCausa                 			= "";
LET iDiasvigencia	       			= 0;
LET cNumprod               			= "";
LET cUSER                  			= USER;
LET iSqlErr                			= 0;
LET iIsamErr               			= 0;
LET cErrorInfo             			= "";
LET cCodRet                			= "000000";
LET cMensajeRet            			= "Se realizó la consulta correctamente";
LET sDiasMinimosAper       			= 0;
LET sLineaCredito      				= 0;
LET sNumIncremPrevios 				= 0;
LET sNumVencidos 					= 0;
LET sMesesTrancurridos 				= 0;
LET dtFecha_apertura 				= DATE(1);
LET iFlagRtPagMin     				= 0;
LET dtFechaPago         			= DATE(1);
LET dPagoMin     					= 0;
LET dtFechaAux            			= DATE(1);
LET dPagado            				= 0;
LET vgrupo							= '';

LET dAum2 							= 0;
LET dAum1 							= 0;
LET dAum3            				= 0;
LET dLineaSugerida 					= 0;
LET smblinsug 						= 0;
LET iStatusTarjetas 				= 0;
LET iStatusPrestamos 				= 0;
LET iNumVencidosTarjeta 			= 0;
LET iVencidos 						= 0;
LET iNumVencidosPrestamos 			= 0;

LET iExcepciones    				= 0;
LET iSitEspRechazo  				= 0;
LET cMotivo         				= "";
LET cTipoRech       				= "";
LET dMaxMtoUdi      				= 0;
LET dValorUdi       				= 0;
LET cCodUdi         				= "";
LET cClase          				= "";
LET cCodRet         				= "000000";  
LET sLineaCreditoBC  				= 0;
LET sLineaCreditoCAC  				= 0;
LET iBanderaUtilizacion  			= 0;
LET dLincredSolicitada  			= 0;
LET cBegin  						= "N";
LET cPregunta  						= "";
LET cSucursal  						= "";
LET cComIngreso  					= "";
LET cNumctecop  					= "";
LET dValor_reserva     				= 0;
LET dValorreserva      				= 0;
LET iRevisionCac      				= 0;
LET iNumMesesAtrasos      			= 0;
LET iNumMesesIncrementosPrevios     = 0;
LET cEjecutivo      				= "";

--Homologacion.
LET iDiasVigenciaHomo				= 7;
LET cNumSolSIC 						= ""; 
LET dtFechaSic 						= DATE(1);
LET cConsultaSic 					= "";
LET cCod_ret                		= "000";
--Declaracion variables sp_valida_respuesta_bc_ofi.
LET cCodigoRetorno 					= "000000";
LET vcDescripcionError 				= "";
LET cMensajeResp 				= "";
--IPCB se integra variable para lectura de la institución de la consulta a BC
LET institucion_sic ='BC';
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB 
LET ccausaRT 						= "";
LET vsituacion						= "";
LET vcausas							= 0;
LET vsitesp							= "";
LET sLineaCreditoMax				= 0;

--SET DEBUG FILE TO '/RESPALDOS/Carlos/Solicitud_'||TRIM(pSolicitud)||'.out';
--TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    LET cCodRet= iSqlErr;
    LET cMensajeRet= cErrorInfo;
    RETURN cCodRet, cMensajeRet;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--/////////////////////////////////////////////////////////
--  obtiene la fecha del día
    SELECT fecha_hoy
      INTO dtFechaHoy
      FROM bdicred:"informix".sd_fechas
     WHERE empresa = pEmpresa;
-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual menor a 1.27 sm 
SELECT valor 
  INTO dAum2
  FROM bdicred:"informix".sd_param 
 WHERE empresa   = pEmpresa 
   AND cod_param = '017';	

-- validacion de los parametros.
IF NVL(dAum2,"") = "" THEN
    LET cCodRet     = "000001";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos menores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum1
  FROM bdicred:"informix".sd_param 
 WHERE empresa = pEmpresa 
   AND cod_param = '016';

-- validacion de los parametros.
IF NVL(dAum1,"") = "" THEN
    LET cCodRet     = "000002";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del porcentaje para calcuar la linea de clientes con su linea actual mayor o igual a 1.27 sm 
SELECT valor 
  INTO dAum3
  FROM bdicred:"informix".sd_param 
 WHERE empresa = pEmpresa 
   AND cod_param = '092';

-- validacion de los parametros.
IF NVL(dAum3,"") = "" THEN
    LET cCodRet     = "000016";
	LET cMensajeRet = "Error al obtener el parametro de porcentaje de incremento para salarios minimos mayores a 1.27";
	RETURN cCodRet, cMensajeRet;
END IF;

--////////////////////////////////////////////////////////
SELECT pri_dia_mes 
  INTO dtPriDiaMes
  FROM bdicred:"informix".sd_fechas
 WHERE empresa = pEmpresa;
	  
IF NVL(pEmpresa,"") = "" THEN
    LET cCodRet     = "000003";
	LET cMensajeRet = "Parámetro requerido esta vacío";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor del salario minimo de la zona C
SELECT valor 
  INTO dValorsm
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '013'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(dValorsm,"")  = "" THEN
    LET cCodRet     = "000004";
	LET cMensajeRet = "Error al obtener el parámetro del valor del salario mínimo";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor del procentaje de utilizacion para los créditos
SELECT valor 
  INTO dValorlinutilcred
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '019'
   AND empresa   = pEmpresa;

-- validacion de los parametros.
IF NVL(dValorlinutilcred,"") = "" THEN
    LET cCodRet     = "000005";
	LET cMensajeRet = "Error al obtener el parámetro de la cantidad de utilización de la línea de crédito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor maximo del procentaje de utilizacion para los créditos
SELECT valor INTO dPorcMaxUti
FROM bdicred:"informix".sd_param 
WHERE cod_param = '112' AND empresa   = pEmpresa;

IF NVL(dPorcMaxUti,"") = "" THEN
    LET cCodRet     = "000015";
	LET cMensajeRet = "Error al obtener el parámetro de la cantidad maxima de utilización de la línea de crédito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- obtener el valor de los dias de vigencia de los créditos
SELECT valor 
  INTO iDiasvigencia
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '011'
   AND empresa = pEmpresa ;

-- validación de los parametros.
IF NVL(iDiasvigencia,"") = "" THEN
    LET cCodRet     = "000006";
	LET cMensajeRet = "Error al obtener el parámetro de los días de vigencia del crédito";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Días mínimos de apertura de créditos
SELECT valor 
  INTO sDiasMinimosAper
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '021'
   AND empresa = pEmpresa ;

IF NVL(sDiasMinimosAper,"") = "" THEN
    LET cCodRet     = "000007";
	LET cMensajeRet = "Error al obtener los días mínimos de apertura de créditos";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara créd con lín créd MN para increm línea
SELECT valor 
  INTO sLineaCredito
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '023'
   AND empresa = pEmpresa ;

IF NVL(sLineaCredito,"") = "" THEN
    LET cCodRet     = "000008";
	LET cMensajeRet = "Error al obtener la línea de crédito a comparar para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Número incrementos previos para increm línea
SELECT valor 
  INTO sNumIncremPrevios
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '047'
   AND empresa = pEmpresa;

IF NVL(sNumIncremPrevios,"") = "" THEN
    LET cCodRet     = "000009";
	LET cMensajeRet = "Error al obtener el número incrementos previos para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara línea crédito para enviar a BC 
SELECT valor 
  INTO sLineaCreditoBC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '027'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoBC,"") = "" THEN
    LET cCodRet     = "000010";
	LET cMensajeRet = "Error al obtener la línea crédito para enviar a BC para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Compara línea crédito para enviar aL CAC 
SELECT valor 
  INTO sLineaCreditoCAC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '043'
   AND empresa = pEmpresa ;

IF NVL(sLineaCreditoCAC,"") = "" THEN
    LET cCodRet     = "000011";
	LET cMensajeRet = "Error al obtener la línea crédito para enviar al CAC para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;
-- obtener el valor del de la reserva
SELECT valor 
  INTO dValor_reserva
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '018'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(dValor_reserva,"") = "" THEN
    LET cCodRet     = "000012";
	LET cMensajeRet = "Error al obtener el parámetro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;

-----------------------------------------------
-- obtener el valor del de la reserva
SELECT valor 
  INTO iNumMesesAtrasos
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '008'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(iNumMesesAtrasos,"") = "" THEN
    LET cCodRet     = "000013";
	LET cMensajeRet = "Error al obtener el parámetro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;


-- obtener el valor del de la reserva
SELECT valor 
  INTO iNumMesesIncrementosPrevios
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '009'
   AND empresa = pEmpresa;

-- validacion de los parametros.
IF NVL(iNumMesesIncrementosPrevios,"") = "" THEN
    LET cCodRet     = "000014";
	LET cMensajeRet = "Error al obtener el parámetro del monto de reserva";
	RETURN cCodRet, cMensajeRet;
END IF;

-- Línea de crédito Maxima para incrementos de línea
SELECT valor INTO sLineaCreditoMax
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '046' AND empresa = pEmpresa ;
IF NVL(sLineaCreditoMax,"") = "" THEN
	LET cCodRet     = "000017";
	LET cMensajeRet = "Error al obtener la línea de crédito maxima para incrementos de línea";
	RETURN cCodRet, cMensajeRet;
END IF;	

LET dValorreserva = (dValor_reserva * dValorsm) * 30.42;

CALL bdicred:monthadd(dtFechaHoy,-2)  RETURNING dtFechaAnt2m; -- 60 días
CALL bdicred:monthadd(dtFechaHoy,-3)  RETURNING dtFechaAnt3m; -- 90 días
CALL bdicred:"informix".monthadd(dtFechaHoy,-4)  RETURNING p_FechaAnt4m; -- 120 días
CALL bdicred:monthadd(dtFechaHoy,-6)  RETURNING dtFechaAnt6m; -- 180 días
CALL bdicred:monthadd(dtFechaHoy,-iNumMesesAtrasos)  RETURNING dtFechaAnt6mAtrasos; 
CALL bdicred:monthadd(dtFechaHoy,-iNumMesesIncrementosPrevios)  RETURNING dtFechaAnt6mIncrementos; 

CALL bdicred:monthadd(dtFechaHoy,-12) RETURNING dtFechaAnt12m; -- 360 días
FOREACH 
	SELECT a.num_credito,
           a.numcte, 
           c.grado_riesgo,
           b.monto_otorgado,
           nvl(c.reserva_calificacion,0),
           a.num_producto,
		   a.fecha_apertura,
		   d.sucursal,
		   d.fecha_insert,
		   d.comp_ingreso,
		   d.numcte_cop,
		   d.lincred_solicitada,
		   d.user_insert,mensaje 
      INTO cNum_cred, cNumCte, cRiesgo, dMontoOtor, dMontoReserva,cNumprod,dtFecha_apertura,cSucursal,
		  dtFechaInsert,cComIngreso,cNumctecop,dLincredSolicitada,cEjecutivo,cMensajeResp
	  FROM bdicred:"informix".sd_bitacora_aumlincred d
	  LEFT JOIN bdicred:"informix".sd_maecred a ON d.num_solicitud = a.num_credito 
	  JOIN bdicred:"informix".sd_maesdos b ON a.empresa = b.empresa AND a.num_credito = b.num_credito
	  LEFT OUTER JOIN bdicred:"informix".sd_hist_reserva c ON c.empresa = b.empresa AND c.num_credito = b.num_credito AND c.fecha_cierre = dtPriDiaMes - 1
	  WHERE b.empresa = pEmpresa
	  AND d.num_solicitud = pSolicitud
	  and d.origen = "S"
	  AND status = "PC"
	  --AND a.fecha = dtPriDiaMes - 1
	  AND a.empresa     = pEmpresa
	  AND a.num_credito = d.num_solicitud   
	  AND d.num_solicitud NOT in (SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred WHERE empresa='001' AND status IN ("BC","CC","AC","EC","AC")) ----JMAH	   
	  AND (a.id_unidad_prod is null or a.id_unidad_prod = '')
	  AND (a.cod_caract is null or a.cod_caract = '')
	  AND (a.cod_caract_2 is null or a.cod_caract_2 = '')
	   
	IF  NVL(cNum_cred,"") = "" THEN 		
		CONTINUE FOREACH;
	END IF;
						----Calculo de la linea de crédito
---*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*-	  
--Si la línea de crédito actual es menor a 2100 MN (1.27 SM zona C aproximadamente), se autoriza el incremento por parte del banco y queda pendiente la autorización del cliente
/*	IF (dMontoOtor < sLineaCredito) THEN --se compara en pesos y no en salarios mínimos
        LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAum2),-2);      
    ELSE
        LET dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAum1),-2);
    END IF;*/
	
	SELECT grupo INTO vgrupo
	FROM bdisolic:ss_resum_scor_fin
	WHERE empresa = pEmpresa
	AND num_solicitud = cNum_cred;
	
	IF (NVL(vgrupo,'') in ('3','5')) THEN --se compara en pesos y no en salarios mínimos
        LET dLineaSugerida  = round(dMontoOtor + (dMontoOtor * dAum3),-2);      
    ELSE
        LET dLineaSugerida = round(dMontoOtor + (dMontoOtor * dAum1),-2);
    END IF;
	
    LET smblinsug = dLineaSugerida / (30.42 * dValorsm);

	 -----Se Guarda el registro en bitacora

	--se actualiza la información de la solicitud
	UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	SET lincred_actual = dMontoOtor,
		lincred_sugerida = dLineaSugerida,
		smb_lincred = smblinsug,
		grado_riesgo = cRiesgo,
		monto_reserva = dMontoReserva
	WHERE fecha_insert  = dtFechaInsert
	AND numcte          = cNumCte
	AND num_solicitud   = cNum_cred
	AND empresa         = pEmpresa;	
     -------------------------
	LET cStatus     = "";
	LET vgrupo		= "";
---*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*----*-
	
	IF cRiesgo IS NULL THEN LET cRiesgo = ""; END IF;

	---Se valida el que el cliente este al corriente de sus pagos....
		SELECT COUNT (*)		
		INTO iStatusTarjetas
		FROM bdicred:"informix".sd_maesdos
		WHERE num_credito = cNum_cred
		AND (monto_vencido + mto_venc_trasp) > 0;		

		IF iStatusTarjetas = 0 THEN --checar los prestamos con los que cuenta el cliente y verificar si presenta algun vencido
			SELECT COUNT(*)
			INTO iStatusTarjetas
			FROM bdicred:"informix".sd_maecredcrd a,
				 bdicred:sd_maesdoscrd b
			WHERE a.numcte = cNumCte
			  and a.num_credito = b.num_credito
			  AND (b.monto_vencido + b.mto_venc_trasp) > 0;								 
		END IF;     
--Si la línea de crédito actual del crédito es menor a 2100 MN (1.27 SM zona C aproximadamente) se precalifica
--    IF dMontoOtor < 2100 THEN -- compara la linea de credito en pesos y ya no en salarios mínimos  
/*   IF dMontoOtor < sLineaCredito THEN -- compara la linea de credito en pesos y ya no en salarios mínimos  			
		--si existe algun status se cancela la solicitud con causa CVB
		IF iStatusTarjetas = 1  OR iStatusPrestamos > 0 THEN
			LET cStatus = "CN";
			LET cCausa  = "CVB";	
		ELSE --se apertura
			LET cStatus = "AT";
			LET cCausa  = "";	
		END IF;		
   ELSE*/
			IF ( iStatusTarjetas > 0 ) THEN -- Validacion 1 - Estar al corriente en TDC y PP en el mes del Incremento.
					LET cStatus = "CN";
					LET cCausa  = "CVB";					
			ELSE
				SELECT FIRST 1 situacion, causa
				INTO vsituacion, vcausas
				FROM bdisitesp:"informix".se_ctessitespcte
				WHERE numcte = cNumCte;
				
				IF(NVL(vsituacion,"") = "F") AND (NVL(vcausas,0) IN(42,48)) THEN
					LET vsitesp = "1";
				END IF;
					
				IF(NVL(vsituacion,"") = "P") AND (NVL(vcausas,0) IN(9,10,14,31,45,49,108,201,203)) THEN
					LET vsitesp = "1";
				END IF;
				
				IF(NVL(vsituacion,"") = "X") AND (NVL(vcausas,0) = 31) THEN
					LET vsitesp = "1";
				END IF;
				
				IF(NVL(vsituacion,"") = "U") AND (NVL(vcausas,0) IN(66,60)) THEN
					LET vsitesp = "1";
				END IF;
				
				IF(NVL(vsituacion,"") = "G") AND (NVL(vcausas,0) = 1) THEN
					LET vsitesp = "1";
				END IF;

				IF (vsitesp = "1") THEN -- Validación 2 - Se validan las Situación Especial
					LET cStatus = "RT";
					LET cCausa = "RSE";
				ELSE
					SELECT grupo INTO vgrupo
					FROM bdisolic:ss_resum_scor_fin
					WHERE empresa = pEmpresa
					AND num_solicitud = cNum_cred;
					
					IF (vgrupo IN('6','8')) THEN -- Validacion 3 - No estar en el grupo 6 u 8.
						LET cstatus = 'RT';
						LET cCausa = 'RGP';
					ELSE
						IF dtFecha_apertura  >= dtFechaAnt12m /*dtFechaHoy - sDiasMinimosAper*/ THEN -- Validacion 4 - Se valida que cumpla con la antigüedad >= a 12 meses
							/*--se cumple una excepcion y se guarda en la tabla de excepciones
							INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
							(empresa,num_solicitud,excepciones,usuario,fecha_insert)
							VALUES (pEmpresa, cNum_cred,"001",USER,CURRENT);
							LET iExcepciones = 1;*/
							LET cstatus = "CN";
							LET cCausa = "CHR";
						ELSE
							SELECT COUNT(num_credito)
								INTO iNumVencidosTarjeta
							FROM bdicred:"informix".sd_amortiza_credito
							WHERE empresa        = pEmpresa
							AND num_credito    = cNum_cred
							--AND capital_status_ant IN ("2","7")
							AND capital_status_ant IN ("2","7","6")  --IFRS MACF
							AND fecha_cuota BETWEEN dtFechaAnt12m /*dtFechaAnt6mAtrasos*/ AND dtFechaHoy;
							IF(iNumVencidosTarjeta > sNumVencidos) THEN
								LET iVencidos = 1;
							ELSE
								SELECT COUNT(num_credito)
								INTO iNumVencidosPrestamos
								FROM bdicred:"informix".sd_amortiza_creditocrd
								WHERE empresa        = pEmpresa
								AND num_credito    = cNum_cred
								--AND capital_status_ant IN ("2","7")
								AND capital_status_ant IN ("2","7","6")  --IFRS MACF
								AND fecha_cuota BETWEEN dtFechaAnt12m /*dtFechaAnt6mAtrasos*/ AND dtFechaHoy;
								IF(iNumVencidosPrestamos > sNumVencidos) THEN
									LET iVencidos = 1;
								END IF;
							END IF; 

							IF iVencidos = 1 THEN -- Validacion 5 - Se busca si tiene el crédito atrasos durante los ultimos 12 meses
								/*INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
								(empresa,num_solicitud,excepciones,usuario,fecha_insert)
								VALUES (pEmpresa, cNum_cred,"002",USER,CURRENT);	
								LET iExcepciones = 1;						*/
								LET cstatus = "RT";
								LET cCausa = "RBE";
							ELSE
								SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)} MAX(fecha_status)
									INTO dtFechains
								FROM bdicred:"informix".sd_bitacora_aumlincred 
								WHERE numcte  = cNumCte
								AND empresa = pEmpresa
								AND status = 'AP';

								IF dtFechains IS NULL OR dtFechains = '' THEN LET dtFechains = date(1); END IF;

								IF dtFechains >= dtFechaAnt12m /*dtFechaAnt6m*/ AND dtFechains <= today THEN  -- Validacion 6 - Clientes que cuenten con 12 meses desde el ultimo incremento en su TDC
									/*--se guarda la excepcion 3
									INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
									(empresa,num_solicitud,excepciones,usuario,fecha_insert)
									VALUES (pEmpresa, cNum_cred,"003",USER,CURRENT);	
									LET iExcepciones = 1;						*/
									LET cstatus = "CN";
									LET cCausa = "CUI";
								ELSE
									--Se descartan los créditos con grado de riesgo D, E y C (para este último con monto de reserva mayor a 600 MN (0.37 SM zona C aproximadamente))
									--IF (cRiesgo NOT IN ("A","B1","B2","")) OR ((cRiesgo = "C") AND (dMontoReserva > dValorreserva)) THEN -- se compara en pesos y ya no en salarios mínimos
									IF (cRiesgo NOT IN ("A1","A2","B1","B2","B3","C1","C2")) THEN -- PIQV RQM 09 320-5 -- Validacion 7 - Se valida el grado de riesgo.
										LET cStatus = "RT";
										LET cCausa  = "RGR";					
									ELSE
										SELECT COUNT(num_credito) 
										INTO dUtili
										FROM bdicred:"informix".sd_hist_reserva
										WHERE empresa     = pEmpresa
										AND num_credito = cNum_cred
										AND fecha_cierre BETWEEN dtFechaAnt12m AND dtFechaHoy
										AND porcentaje_uso >= dValorlinutilcred
										AND porcentaje_uso <= dPorcMaxUti;

										IF (dUtili < 1) THEN       
											LET iBanderaUtilizacion=1;
										END IF;	
									
										IF (iBanderaUtilizacion = 1) THEN -- Validacion 8 - Se busca si el crédito tiene una utilización de la línea igual o mayor al 70% y menor = 94% en los últimos 12 meses
											/*INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
											(empresa,num_solicitud,excepciones,usuario,fecha_insert)
											VALUES (pEmpresa, cNum_cred,"004",USER,CURRENT);
											LET iExcepciones = 1;*/
											LET cStatus = "CN";
											LET cCausa  = "CUL";
										ELSE
											LET iFlagRtPagMin =0;
											FOREACH WITH HOLD
												SELECT fecha, monto_financiado
													INTO dtFechaPago,dPagoMin 
												FROM bdicred:"informix".sd_maesdoshist
												WHERE empresa        = pEmpresa
												AND num_credito    = cNum_cred	
												AND fecha BETWEEN p_FechaAnt4m AND dtFechaHoy 
												ORDER BY fecha DESC
												
												LET  dtFechaAux = monthadd (dtFechaPago,-1) + 1 units day;
												SELECT SUM(monto)
													INTO dPagado
												FROM bdicred:sd_movhis a
												WHERE a.empresa       = pEmpresa
												AND num_credito     = cNum_cred
												AND reversado       = 'N'					
												AND a.codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)		      
												AND fecha_mov BETWEEN dtFechaAux AND  dtFechaPago;

												IF dPagado <= dPagoMin  THEN
													LET iFlagRtPagMin= 1;
													EXIT FOREACH;
												END IF 
												
											END FOREACH;

											IF iFlagRtPagMin= 1 THEN -- Validacion 9 - Haber efectuardo pago mayor al pago mínimo en los últimos 4 meses.
												LET cStatus = "RT";
												LET cCausa  = "RPM";
											ELSE		
												--Cuenta los incrementos que ha tenido el crédito
												SELECT {+INDEX(bdicred:sd_bitacora_aumlincred idx_bitacora_status)} nvl(count(status),0)
													INTO sIncprev
												FROM bdicred:"informix".sd_bitacora_aumlincred 
												WHERE numcte  = cNumCte
												AND empresa = pEmpresa
												AND status = 'AP';

												/*--Cuenta con más de 3 incrementos previos
												IF (sIncprev > sNumIncremPrevios) THEN 
													--Se busca si el crédito tiene una utilización de la línea igual o mayor al 80% en los últimos 12 meses
													SELECT COUNT(num_credito) 
													INTO dUtili
													FROM bdicred:"informix".sd_hist_reserva
													WHERE empresa     = pEmpresa
													AND num_credito = cNum_cred
													AND fecha_cierre BETWEEN dtFechaAnt12m AND dtFechaHoy
													AND porcentaje_uso >= dValorlinutilcred;
													-- Línea utilización del 80% 
													IF (dUtili < 2) THEN       
														LET iBanderaUtilizacion=1;
													END IF;	
												ELSE
													SELECT COUNT(num_credito) 
													INTO dUtili
													FROM bdicred:"informix".sd_hist_reserva
													WHERE empresa        = pEmpresa
													AND num_credito    = cNum_cred
													AND fecha_cierre BETWEEN dtFechaAnt6mIncrementos AND dtFechaHoy
													AND porcentaje_uso >= dValorlinutilcred;

													IF (dUtili < 1) THEN        
														LET iBanderaUtilizacion=1;
													END IF;
												END IF;
												
												IF (iBanderaUtilizacion = 1) THEN --excepcion 4
													INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
													(empresa,num_solicitud,excepciones,usuario,fecha_insert)
													VALUES (pEmpresa, cNum_cred,"004",USER,CURRENT);
													LET iExcepciones = 1;
												END IF;*/
												
												IF (sIncprev > sNumIncremPrevios) OR (dMontoOtor > sLineaCreditoMax) THEN -- Incrementos > 4 o Monto otorgado > 100000
													LET cStatus = "RT";
													LET cCausa  = "RCI";
												ELSE
													--Validar Comprobante de ingresos:
													IF (cComIngreso = "S") THEN
														INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
														(empresa,num_solicitud,excepciones,usuario,fecha_insert)
														VALUES (pEmpresa, cNum_cred,"005",USER,CURRENT);
														LET iExcepciones = 1;
													END IF;
													/*--Validar linea de credito  > 21000
													IF (dLineaSugerida >= sLineaCreditoCAC) THEN
														INSERT INTO bdicred:"informix".sd_sol_excepciones_aumlincred  
														(empresa,num_solicitud,excepciones,usuario,fecha_insert)
														VALUES (pEmpresa, cNum_cred,"006",USER,CURRENT);
														LET iExcepciones = 1;
														
													END IF;*/
												END IF -- Validacion de los Incrementos topados a 4 por Cliente o $100,000
											END IF;										END IF;									END IF;	--Validacion 7 - Se valida el grado de riesgo.
								END IF; -- Validacion 6 - Clientes que cuenten con 12 meses desde el ultimo incremento en su TDC
							END IF; -- Validacion 5 - Se busca si tiene el crédito atrasos durante los ultimos 12 meses
						END IF; --Validacion 4 - Se valida que cumpla con la antigüedad >= a 12 meses
					END IF; -- Validacion 3 - No estar en el grupo 6 u 8.
				END IF; --Validación 2 - Se validan las Situación Especial
			END IF; --Validacion 1 - Estar al corriente en TDC y PP en el mes del Incremento.  --END IF; ---if de la validacion de los 2100 pesos   
   
	IF iExcepciones	> 0 AND NVL(cNumctecop,"") <> "" THEN	----Validacion de clientes Coppel 		
		--SE GUARDA UN REGISTRO PARA ENVIAR A CONSULTAR EN COPPEL
		LET cStatus     = "EC";		
		INSERT INTO bdicred:"informix".sd_consultar_infoctecoppel
		(empresa, numcte, numcte_ref, num_solicitud, fecha_envio, hora_envio, status_envio, user_insert, fecha_insert,user_tramite,sucursal)
		VALUES(pEmpresa,cNumCte,cNumctecop,cNum_cred,TODAY,CURRENT HOUR TO FRACTION,0,USER,CURRENT,cEjecutivo,cSucursal);			
	END IF;	--IF (dLineaSugerida >= sLineaCreditoBC) AND cStatus = ""  THEN --se compara en pesos y no en salarios mínimos    
	IF cStatus = ""  THEN --se compara en pesos y no en salarios mínimos
		LET cStatus     = "BC";
	ELSE
		IF ((dLineaSugerida >= sLineaCreditoCAC) AND cStatus = "") OR (iExcepciones > 0 AND cStatus = "") THEN --se compara en pesos y no en salarios mínimos
		   LET cStatus     = "AC";		ELIF ((dLineaSugerida < sLineaCreditoCAC) AND cStatus = "") AND (iExcepciones = 0  AND cStatus = "") THEN 
		   LET cStatus     = "AT";		END IF;
	END IF;
	 
	UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	SET status          = cStatus,
		causa_status 	= cCausa,
		fecha_status    = today,
		hora_status     = CURRENT,
		revisioncac     = iExcepciones
	WHERE fecha_insert  = dtFechaInsert
	AND numcte          = cNumCte
	AND num_solicitud   = cNum_cred
	AND empresa         = pEmpresa;
	
	INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
	VALUES(pEmpresa, cNum_cred, cStatus, cCausa, cUSER, dtFechaHoy, dtFechaHoy, 0);
	
	
	IF cstatus= "AT" AND iExcepciones	= 0 THEN		
		EXECUTE PROCEDURE bdicred:"informix".sp_registrarrespuestacte(pEmpresa,cNum_cred,'1',cMensajeResp,cSucursal,'sistema') INTO cCodRet, cMensajeRet;
		CONTINUE FOREACH;
	END IF;		
	
	IF cStatus= "BC" THEN ------Envio a Buro de crédito				
		--------------------------------HOMOLOGACION CON PROCESO PRODUCTIVO ----------------------------------		
		------Obtencion del parametro de dias de vigencia de consultas SIC
		SELECT valor
		INTO iDiasVigenciaHomo
		FROM bdisolic:"informix".ss_param
		WHERE empresa = pEmpresa
		AND secuencia = 362;
		
		IF NVL(iDiasVigenciaHomo,0) = 0 THEN
			LET iDiasVigenciaHomo = 0; 
		END IF;   	    
--IPCB junio2017//RECHAZO POR CREDITO BLOQUEADO RCB --se extrae el nuevo campo causa_rt, para validar los rechazos	
		SELECT num_solicitud_sic, fecha_sic, institucion,causa_rt
		INTO cNumSolSIC, dtFechaSic, cConsultaSic, ccausaRT				   
		FROM bdisolic:"informix".ss_solicitudes_sic
		WHERE rowid = (SELECT MAX(rowid)
					   FROM bdisolic:"informix".ss_solicitudes_sic
					   WHERE numcte= cNumCte
					   AND (fecha_sic >= dtFechaHoy - iDiasVigenciaHomo or fecha_sic IS NULL));
					   
		
		--IPCB se integra variable para lectura de la institución de la consulta a BC
		SELECT status_solicitud
		  INTO institucion_sic
		  FROM bdisolic:"informix".ss_status_sol 
	     WHERE empresa = pEmpresa 
		   AND tipo_auto = '1';				
						   
		IF cNumSolSIC IS NULL THEN 
			INSERT INTO bdisolic:"informix".ss_solicitudes_sic
				(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
			VALUES(pEmpresa,cNumCte,cNum_cred,cNum_cred,institucion_sic,dtFechaHoy,NULL);
			
			--se guarda en tabla de control para envios a consulta SIC's de incrementos de linea
			INSERT INTO bdicred:"informix".sd_solicitudes_aumlincred_sucursal
			(empresa, institucion, num_credito, numcte, status, origen, sucursal, fecha_envio, fecha_respuesta) 
			VALUES (pEmpresa, 'BC', cNum_cred, cNumCte, 'BC', 'S',cSucursal,TODAY,null);
				
		   EXECUTE PROCEDURE bdiburo:"informix".burocred(pEmpresa, "0001", "BC", cNum_cred, 0) 
		   INTO cCod_ret;
		ELSE
			IF dtFechaSic IS NULL THEN 
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic
				(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic)
				VALUES(pEmpresa,cNumCte,cNum_cred,cNumSolSIC,institucion_sic,dtFechaHoy,NULL);
			ELSE
				INSERT INTO bdisolic:"informix".ss_solicitudes_sic
				(empresa,numcte,num_solicitud,num_solicitud_sic,institucion,fecha_insert,fecha_sic,causa_rt)
				VALUES(pEmpresa,cNumCte,cNum_cred,cNumSolSIC,cConsultaSic,dtFechaHoy,dtFechaSic,ccausaRT);			
			   	IF ( cConsultaSic = 'CC' ) THEN	--pasar status a CC
					UPDATE bdicred:"informix".sd_bitacora_aumlincred 
					SET status          = cStatus,
						fecha_status    = today,
						hora_status     = CURRENT,
						revisioncac     = iRevisionCac
					WHERE fecha_insert  = dtFechaInsert
					AND numcte          = cNumCte
					AND num_solicitud   = cNum_cred
					AND empresa         = pEmpresa;
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, cStatus, cCausa, cUSER, dtFechaHoy, dtFechaHoy, 0);	
				END IF;
--IPCB junio2017 //RECHAZO POR CREDITO BLOQUEADO RCB	
				IF ccausaRT = 'RCB' THEN				
					UPDATE bdicred:"informix".sd_bitacora_aumlincred 
					SET status          = 'RT',
						causa_status 	= 'RCB',
						fecha_status    = dtFechaHoy,
						hora_status     = CURRENT,
						revisioncac     = 0
					WHERE fecha_insert  = dtFechaHoy
					AND numcte          = cNumCte
					AND num_solicitud   = cNum_cred
					AND empresa         = pEmpresa;
			
					INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
					VALUES(pEmpresa, cNum_cred, 'RT', 'RCB', 'sistema', dtFechaHoy, dtFechaHoy, 0);

					IF EXISTS (SELECT fecha_sic  FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = cNumCte and num_Solicitud = cNum_cred and fecha_sic is null) THEN
						UPDATE bdisolic:"informix".ss_solicitudes_sic set fecha_sic = dtFechaHoy, causa_rt = 'RCB'
						WHERE numcte = cNumCte and num_Solicitud = cNum_cred and fecha_sic is null;					
					END IF;
				ELSE
					EXECUTE PROCEDURE bdiburo:"informix".sp_valida_respuesta_bc_ofi(pEmpresa,cNum_cred)
					INTO cCodigoRetorno,vcDescripcionError;
				END IF;				
			END IF;
		END IF;
		--------------------------------FIN DE HOMOLOGACION CON PROCESO PRODUCTIVO ---------------------------			
	END IF;	
	LET cCausa = "";
	LET cStatus = "";
	LET cMensajeResp = "";
	LET iExcepciones = 0;
	
END FOREACH;
LET cCodRet         = "000000"; 
LET cMensajeRet     = "Se realizó la consulta correctamente";
  RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se crea procedimiento para evaluacion de creditos para ver si son prospectos a un incremento de su linea de credito',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 14/NOVIEMBRE/2011',
'BD    : BDICRED',
'VERSION:20111114.1530',
'MODIFICACION: Se modifico para hacer la homologacion con proceso productivo',
'AUTOR: Guadalupe Payan',
'FECHA: Junio 2012',
'VERSION: 20120612.1024',
'MODIFICACION: Se cambio sd_maecredcont por sd_maecred, y se agrego el espacio en blanco en la condición cRiesgo NOT IN ("A","B1","B2","")) para que los créditos que se hayan calidficado sigan su proceso normal por ser cliente con muy poca historia',
'AUTOR: Juan Daniel Lazalde',
'FECHA: Febrero 2014',
'VERSION: 20140213.0001';

create procedure "informix".sp_inserta_creditos_indicador(pempresa CHAR(3), pFechaI DATE ,pFechaF DATE ) 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vCodFun         CHAR(3);
DEFINE	vCodRef         SMALLINT;
DEFINE	vPagoCliente	CHAR(1);

------------------------------------------------
DEFINE vlFecha	DATE; 
DEFINE	vlEmpresa	CHAR(3);
DEFINE	vlNumCredito	CHAR(20);
DEFINE	vlFechaApertura	DATE;


------------------------------------------------

--SET DEBUG FILE TO '/temp/sp_graba_indicador.out';
--TRACE ON;

    LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
	LET vCodFun       = '';
	LET vCodRef       = '';
	LET vPagoCliente  = '';		  
    LET vlFecha = '05-21-2007';
	
	LET	vlEmpresa	='001';
	LET	vlNumCredito =	'';
	LET	vlFechaApertura	=DATE(1);
	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            RETURN cCod_ret;
        END EXCEPTION;
				
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		LET vlFecha =pFechaI;
		FOREACH WITH HOLD
		SELECT EMPRESA, NUM_CREDITO , fecha_apertura
		  INTO vlEmpresa, vlNumCredito, vlFechaApertura
		  FROM bdicred:sd_maecred
		  where empresa ='001'
		    and fecha_apertura >= vlFecha AND fecha_apertura <=pFechaF
			--and status_cred in ('BT','BA','AA')
			and status_cred in ('BT','BA','AA','E1','E2','E3')   --IFRS MACF
			and num_credito not in( select num_credito from bdicred:"informix".sd_indicador_cred) 
		
		BEGIN WORK;		    
		  INSERT INTO bdicred:"informix".sd_indicador_cred
		       (empresa,num_credito, fecha_alta)
            VALUES(vlempresa,vlNumCredito, vlFechaApertura);			
			--LET vlFecha =	vlFecha +1 UNITS DAY;
		  COMMIT WORK;	
		END FOREACH;
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza el indicador de CrÃ©dito',
'AUTOR : Faviola MartÃ­nez JuÃ¡rez',
'FECHA : 01/Agosto/2011',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".sp_liquida_pp(c_empresa CHAR(3),
                                          c_sucursal CHAR(4),
			                              c_usuario CHAR(8),
                                          c_num_credito CHAR(20),
                                          c_monto   DECIMAL(14,2))

RETURNING CHAR(5),CHAR(16)

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE scod_ret             CHAR(5);
DEFINE vcod_ret             CHAR(5);
DEFINE smen_ret             CHAR(125);
DEFINE vsqlerr              INTEGER;
DEFINE v_folio              CHAR(16);
DEFINE v_val                DECIMAL(18,2);
DEFINE v_val1               CHAR(20);
DEFINE v_val2               CHAR(17);
DEFINE v_val3               DECIMAL(18,2);
DEFINE vIvaSuc              DECIMAL(9,6);
DEFINE vFecCuota            DATE;
DEFINE vFechaHoy            DATE;
DEFINE dAplicaReverso       INTEGER;
DEFINE dSeAplicoReverso     INTEGER;
DEFINE v_montopago          DECIMAL(14,2);
DEFINE v_pagominsal         DECIMAL(18,2);
DEFINE v_pagominamor        DECIMAL(18,2);
DEFINE v_cuentavenci        INTEGER;
DEFINE v_accesoriosa        DECIMAL(18,2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret              = "000";
LET vcod_ret              = "000";
LET vsqlerr               = 0;
LET vFechaHoy             = "";
LET v_folio               = "";
LET vFecCuota             = '';
LET smen_ret              = '';
LET dAplicaReverso        = 0;
LET dSeAplicoReverso      = 0;
LET v_val1                = '';
LET v_val2                = '';
LET v_val3                = 0;
LET v_montopago           = 0;
LET v_pagominsal          = 0;
LET v_pagominamor         = 0;
LET v_cuentavenci         = 0;
LET v_accesoriosa         = 0;
LET vIvaSuc               = 0;
LET g_dtFechaHoy          = DATE(1);

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      ROLLBACK WORK;
      LET scod_ret=vsqlerr;
      RETURN scod_ret,v_folio;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/pisa/cas/sp_liquida_pp.out";
-- TRACE ON;

-- Valida los Nulos en los Parametros de Entrada
IF c_empresa = "" OR c_sucursal = "" OR c_usuario = "" OR
   c_num_credito = "" OR c_monto = "" THEN
   LET scod_ret = "110";
   RETURN scod_ret,v_folio;
END IF;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT valor::decimal(9,6)
      INTO vIvaSuc
      FROM bdinteg:si_param 
     WHERE cod_param=47;

     IF vIvaSuc IS NULL THEN
       LET scod_ret = "110";
       RETURN scod_ret,v_folio;
     END IF;

  SELECT fecha_hoy
    INTO vFechaHoy
    FROM sd_fechas
   WHERE empresa=c_empresa;
  LET g_dtFechaHoy=vFechaHoy;

  LET v_folio = "SIFPP"||SUBSTR(CURRENT HOUR TO FRACTION(2),1,2) ||
      SUBSTR(CURRENT HOUR TO FRACTION(2),4,2) ||
      SUBSTR(CURRENT HOUR TO FRACTION(2),7,2);

    SELECT nvl(monto_financiado,0)
      INTO v_pagominsal
      FROM bdicred:sd_maesdoscrd
     WHERE empresa=c_empresa
       AND num_credito=c_num_credito;

    SELECT sum(capital_debe-capital_pagado),
           sum(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)+
           (sum(mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)* vIvaSuc),
           count(*)
      INTO v_pagominamor,v_accesoriosa,v_cuentavenci
      FROM bdicred:sd_amortiza_creditocrd
     WHERE empresa=c_empresa
       AND num_credito=c_num_credito
       AND capital_status IN ('1','2','7','6');

    IF v_pagominsal IS NULL THEN LET v_pagominsal=0; END IF;
    IF v_pagominamor IS NULL THEN LET v_pagominamor=0; END IF;
    IF v_accesoriosa IS NULL THEN LET v_accesoriosa=0; END IF;
    IF v_cuentavenci IS NULL THEN LET v_cuentavenci=0; END IF;

    IF v_pagominsal <> v_pagominamor THEN ---Validació® °ara detectar si el credito esta descuadrado
       LET scod_ret="111";
       RETURN scod_ret,v_folio;
    END IF;

    LET v_pagominsal = v_pagominsal + v_accesoriosa;

  IF c_monto > 0  AND v_cuentavenci = 0 THEN
      EXECUTE PROCEDURE "informix".sp_pago_anticipado_pp(c_empresa,c_num_credito,c_usuario,c_sucursal,v_folio,'7469',c_monto,'1')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6300'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;

       Insert into "informix".sd_log_cobroaut
       (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
       values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

        RETURN scod_ret,v_folio;
      ELSE
          -- Por si tiene que hacer algo
         LET c_monto = 0;
         LET scod_ret='000';
      END IF;
   ELIF c_monto > 0 AND v_cuentavenci > 0 AND v_pagominsal > 0 AND c_monto <= v_pagominsal  THEN
      EXECUTE PROCEDURE "informix".sp_principal_pp(c_empresa,c_num_credito,1,c_monto,c_usuario,c_sucursal,v_folio,'7506')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6300'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;

       Insert into "informix".sd_log_cobroaut
       (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
       values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

          RETURN scod_ret,v_folio;
      ELSE
          -- Por si tiene que hacer algo
         LET c_monto = 0;
         LET scod_ret='000';
      END IF;
   ELIF c_monto > 0 AND v_cuentavenci > 0 AND v_pagominsal > 0 AND c_monto > v_pagominsal THEN

      LET v_montopago = c_monto - v_pagominsal;

      EXECUTE PROCEDURE "informix".sp_principal_pp(c_empresa,c_num_credito,1,v_pagominsal,c_usuario,c_sucursal,v_folio,'7506')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6300'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;

       Insert into "informix".sd_log_cobroaut
       (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
       values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

          RETURN scod_ret,v_folio;

      ELSE

        SELECT COUNT(*)
          INTO v_cuentavenci
          FROM bdicred:sd_amortiza_creditocrd
         WHERE empresa=c_empresa
           AND num_credito=c_num_credito
           AND capital_status IN ('1','2','7','6');

           IF v_cuentavenci > 0  and c_monto > 0 THEN

              LET scod_ret='112';

              Insert into "informix".sd_log_cobroaut
              (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
              values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

              RETURN scod_ret,v_folio;

           END IF;

          EXECUTE PROCEDURE "informix".sp_pago_anticipado_pp(c_empresa,c_num_credito,c_usuario,c_sucursal,v_folio,'7469',v_montopago,'0')
          INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;

          IF scod_ret <> "00000" THEN
            EXECUTE PROCEDURE "informix".reversioncrd(c_empresa,c_sucursal,c_usuario,v_folio,"A")
            INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;

              Insert into "informix".sd_log_cobroaut
              (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
              values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

              RETURN scod_ret,v_folio;
          END IF;
          -- Por si tiene que hacer algo
         LET c_monto = 0;
         LET scod_ret='000';
      END IF;
   END IF;

   Insert into "informix".sd_log_cobroaut
   (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
   values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

END
   RETURN scod_ret,v_folio;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_mantto_relcteemp(pempresa CHAR(3),pproducto CHAR(4),popcion CHAR(1))
RETURNING CHAR(5) AS cod_ret,VARCHAR(80) AS mens_ret,VARCHAR(80) AS mens_ctrl;

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE iSqlErr		INTEGER;
DEFINE iIsamErr		INTEGER;
DEFINE cErrorInfo	CHAR(80);
DEFINE cCodRet		CHAR(5);
DEFINE cMensaje		CHAR(80);
DEFINE cMensajeCtrl	CHAR(80);
DEFINE cStatus_emp	CHAR(1);

DEFINE v_numcte_banco	CHAR(20);
DEFINE v_num_empleado	CHAR(10);
DEFINE v_fecha_hoy		DATE;
DEFINE iContInacNoExis	INTEGER;
DEFINE iContInacExis	INTEGER;
DEFINE iContInexis		INTEGER;
DEFINE v_valor			DECIMAL (10,2);
DEFINE v_num_credito	CHAR(20);
DEFINE dTasa_Interes	DECIMAL(9,6);		--	RQM 10 1224
DEFINE dTasa_Int_Aux	DECIMAL(9,6);		
DEFINE dTasa_Mora       DECIMAL(9,6);	
DEFINE cCodRetTDif		CHAR(6);

--*****************************************************
--- Inicializar variables
--*****************************************************
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cMensaje           	  = "";
LET cMensajeCtrl       	  = "Validar";

LET v_numcte_banco = '';
LET v_num_empleado = '';
LET cStatus_emp = '';
LET v_fecha_hoy = '';
LET iContInacNoExis = 0;
LET iContInacExis = 0;
LET iContInexis = 0;
LET v_valor = 0;
LET v_num_credito = '';
LET dTasa_Interes = 0;						--	RQM 10 1224
LET dTasa_Int_Aux = 0;	
LET dTasa_Mora    = 0;
LET cCodRetTDif	  = '';



BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet     = iSqlErr;
			LET cMensaje = cErrorInfo;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/aplicacion/ifxsif01/Control-M/sp_mantto_relcteemp.out";
	--TRACE ON;

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	--- Se validan los parametros de entrada con los cuales se ejecuta en SP
	--- Se valida parametro de EMPRESA	
	IF pempresa IS NULL OR pempresa = '' THEN
		LET cCodRet = '00001'; LET cMensaje = 'Parametro -EMPRESA- incorrecto';
	
	--- Se valida parametro de NUMERO CREDITO
	ELIF pproducto IS NULL OR pproducto = '' THEN
		LET cCodRet = '00002'; LET cMensaje = 'Parametro -PRODUCTO- incorrecto';
	
	--- Se valida parametro de NUMERO CREDITO
	ELIF popcion NOT IN ('2') THEN
		LET cCodRet = '00003'; LET cMensaje = 'Parametro -OPCION- incorrecto';
	
	--- Opciones correctas o con valores permitidos
	ELSE
		
		SELECT fecha_hoy
		INTO v_fecha_hoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pempresa;				

		SELECT b.valor
		INTO dTasa_Int_Aux
		FROM bdicred:"informix".sd_definicion a, bdinteg:"informix".si_fechavalor b
		WHERE --a.empresa = pempresa AND
		      a.num_producto = pproducto
		  AND b.empresa = pempresa  	  
		  AND b.tasa = a.cod_tasa_base
		  AND b.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
						WHERE r.empresa = pempresa
						AND r.tasa = a.cod_tasa_base);

		
		FOREACH

			SELECT numcte_banco, num_empleado 
			INTO v_numcte_banco, v_num_empleado
			FROM bdinteg:"informix".si_baja_rel_cte_emp
			WHERE fecha_registro = 	v_fecha_hoy
			
			FOREACH
					
				--- Se actualiza (INACTIVA)la relación cliente-empleado	
				EXECUTE PROCEDURE bdicred:"informix".inserta_rel_cte_emp(pempresa,v_numcte_banco,v_num_empleado, popcion, 'BAJA EMPLEADO', '', '', '', '')
				INTO cCodRet,cStatus_emp,cMensaje
				
				IF cCodRet = '00000' THEN
					LET iContInacNoExis = iContInacNoExis + 1;

					---Se actualiza la tasa de interes del crédito, de tasa preferencial a tasa base, de acuerdo al producto
					SELECT first 1 num_credito INTO v_num_credito FROM bdicred:"informix".sd_maecred WHERE numcte = v_numcte_banco AND num_producto = pproducto AND status_cred in ('AA','BA','BT','E1','E2','E3');
						
					EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pempresa, v_num_credito, pproducto) INTO cCodRetTDif, dTasa_Interes, dTasa_Mora;
					IF cCodRetTDif <> '000000' OR NVL(dTasa_Interes,0) = 0 THEN
						LET v_valor = dTasa_Int_Aux;
					ELSE
						LET v_valor = dTasa_Interes;
					END IF;
						
					UPDATE bdicred:"informix".sd_maecred  
					SET tasa_interes = v_valor  
					where empresa = pempresa and numcte = v_numcte_banco and num_producto = pproducto;
						
					--EXECUTE PROCEDURE bdicred:sp_registra_crecta_cobroaut(pempresa,v_num_credito,'','0',popcion)
					--INTO cCodRet,cMensaje;
						
				ELIF cCodRet  = '00006' THEN
					LET iContInacExis = iContInacExis + 1; 
	
				ELIF cCodRet = '00007' THEN
					LET iContInexis = iContInexis + 1; 
				END IF
			END FOREACH
			
		END FOREACH
		
		LET cCodRet = '00000'; LET cMensaje = "Se realizo el proceso correctamente";	
		LET cMensajeCtrl = 'Actualizados : '||cast(iContInacNoExis as char(6))||', No Actualizados : '||cast(iContInacExis as char(6))||', No Existentes : '||cast(iContInexis as char(6))||'';
			   
	END IF

	RETURN cCodRet,cMensaje,cMensajeCtrl;
END
END PROCEDURE;