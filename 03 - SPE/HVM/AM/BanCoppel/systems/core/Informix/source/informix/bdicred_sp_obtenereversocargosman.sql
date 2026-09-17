CREATE PROCEDURE "informix".sp_obtenereversocargosman(pFolio CHAR(16))
RETURNING CHAR(5), CHAR(80), CHAR(20),CHAR(20), CHAR(40) , CHAR(20),CHAR(150) , DECIMAL(18,2),DECIMAL (18,2), DECIMAL(18,2),DECIMAL(18,2),
DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2),DECIMAL(18,2), CHAR(20), CHAR(50);

--DECLARACION DE VARIABLES
DEFINE vCodRet    CHAR(5);
DEFINE vSqlErr, vIsamErr INTEGER;
DEFINE cNumCred   CHAR(20);
DEFINE cFolio     CHAR(16);
DEFINE cCodigo_retorno CHAR(6);
DEFINE cMensaje_retorno CHAR (80);
DEFINE cNumero_credito	CHAR(20);
DEFINE cNumero_cliente	CHAR(20);
DEFINE cNombre_producto	CHAR(40);
DEFINE cNumero_tarjeta	CHAR(20);
DEFINE cNombre_cliente	CHAR (150);	
DEFINE cImporte_Cargo		DECIMAL(18,2);
DEFINE cCapital_vigente	DECIMAL(18,2);
DEFINE cCapital_transitorio DECIMAL(18,2);
DEFINE cCapital_vencido DECIMAL(18,2);
DEFINE cCapital_vencido_no_exigible DECIMAL(18,2);
DEFINE cInteres_vigente DECIMAL(18,2);
DEFINE cIva_de_interes_vigente DECIMAL(18,2);
DEFINE cInteres_vencido DECIMAL(18,2);
DEFINE cIva_de_interes_vencido DECIMAL(18,2);
DEFINE cInteres_moratorio DECIMAL(18,2);
DEFINE cIva_interesmoratorio	 DECIMAL(18,2);
DEFINE cCapital_Total	DECIMAL(18,2);
DEFINE cConcepto		CHAR(20);
DEFINE cDescripcion     CHAR(200);
--INICIALIZACION DE VARIABLES

LET vCodRet = "00000";
LET cNumCred = '';
LET cFolio   = '';
LET cCodigo_retorno = 0;
LET cMensaje_retorno  = 0;
LET cNumero_credito	 = 0;
LET cNumero_cliente	 = 0;
LET cNombre_producto	 = 0;
LET cNumero_tarjeta	 = 0;
LET cNombre_cliente	 = 0;
LET cImporte_Cargo		 = 0;
LET cCapital_vigente	 = 0;
LET cCapital_transitorio  = 0;
LET cCapital_vencido  = 0;
LET cCapital_vencido_no_exigible  = 0;
LET cInteres_vigente  = 0;
LET cIva_de_interes_vigente  = 0;
LET cInteres_vencido  = 0;
LET cIva_de_interes_vencido = 0;
LET cInteres_moratorio  = 0;
LET cIva_interesmoratorio	  = 0;
LET cCapital_Total	 = 0;
LET cConcepto		='';
LET cDescripcion   = '';

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_obtenereversocargosman.out";
	--TRACE ON;

BEGIN
	--MANEJO DE ERRORES
	ON EXCEPTION SET vSqlErr, vIsamErr
		IF vSqlErr != 0 THEN
			LET vCodRet = vSqlErr;
			RETURN vCodRet,'', '', '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;
		END IF;
	END EXCEPTION;

	IF NOT EXISTS( SELECT num_credito FROM "informix".sd_bitacora_cargos WHERE folio = pFolio) THEN              --El folio recibido no se trata de un cargo manual
		LET vCodRet= '20000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;
	END IF;

	IF EXISTS ( SELECT num_credito FROM "informix".sd_bitacora_cargos WHERE folio = pFolio AND reverso = 'S') THEN
		LET vCodRet= '30000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','', '', '','', '', '','', '', '','','' ;			
	END IF;

	--VALIDACION PARA REVERSAR PAGO MANUAL

	SELECT Limit 1 trim(num_credito)
	INTO cNumCred
	FROM "informix".sd_movdia
	WHERE folio_suc = pFolio;	

	SELECT folio_suc 
		INTO cFolio
	FROM  "informix".sd_movdia
	WHERE num_credito = cNumCred
	AND reversado <> 'S'
	AND secuencia = (SELECT MAX(secuencia)  
					 FROM  "informix".sd_movdia
					 WHERE num_credito = cNumCred 
					 AND reversado <> 'S');
	

	IF  cFolio <> pFolio THEN            --El folio recibido no es el ultimo movimiento
		LET vCodRet= '10000';
		RETURN vCodRet,'', cNumCred, '', '', '', '', '', '', '','','', '', '','', '', '','', '','','' ;
	END IF;		

	CALL "informix".sp_consulta_datos_general('001', '', cNumCred,'','','','')
	RETURNING cCodigo_retorno, cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente;

	FOREACH

		SELECT importe_cargo, cap_vig_ant, cap_tran_ant, cap_venc_ant, cap_venc_noexi_ant,cap_total_ant, int_vig_ant, iva_int_vig_ant, 
				int_ven_ant, iva_int_ven_ant, int_mora_ant,  iva_int_mora_ant, cod_cargo, observaciones
		INTO cImporte_Cargo, cCapital_vigente, cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total, cInteres_vigente, 
			cIva_de_interes_vigente, cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio, cIva_interesmoratorio, cConcepto, cDescripcion
		FROM "informix".sd_bitacora_cargos
		WHERE folio= pFolio	
		AND reverso =  'N'

		RETURN vCodRet,cMensaje_retorno, cNumero_credito, cNumero_cliente, cNombre_producto, cNumero_tarjeta, cNombre_cliente, cImporte_Cargo, cCapital_vigente,
				cCapital_transitorio, cCapital_vencido, cCapital_vencido_no_exigible,cCapital_Total ,cInteres_vigente, cIva_de_interes_vigente, 
				cInteres_vencido, cIva_de_interes_vencido, cInteres_moratorio, cIva_interesmoratorio, cConcepto, cDescripcion WITH RESUME;

	END FOREACH
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE DATOS GENERALES, DETALLE DE APLICACION Y SALDOS NUEVOS',
'AUTOR: HECTOR MANUEL BOJORQUEZ RUELAS,Jesus Manuel Aguilar Heredia',
'FECHA: JULIO 2011',
'VERSION: 20110714.1408',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_obtenerinforeversioncargo(pFolio_grupo  CHAR(16))
RETURNING  CHAR(6), CHAR(50), CHAR(20), MONEY(14,2), CHAR(2), char(100), CHAR(100), CHAR(16), CHAR(1);


DEFINE cCodRet 		     CHAR(6);
DEFINE iSqlErr           INTEGER;
DEFINE cMensaje          CHAR(50);
DEFINE iReg              INTEGER; 

DEFINE cCredito		     CHAR(20);
DEFINE iImporte          MONEY(14,2);
DEFINE cCodigo_cargo      CHAR(2);
DEFINE cDesc_cargo        CHAR(100);
DEFINE cResultado        CHAR(16);
DEFINE cFolio            CHAR(16);
DEFINE cReverso          CHAR(1);

LET cCodRet           = '000000';
LET iSqlErr	          = 0;
LET cMensaje          = 'Proceso Exitoso!!!';
LET iReg              = 0;

LET cCredito		  = '';
LET iImporte          = 0;
LET cCodigo_cargo      = '';
LET cDesc_cargo        = '';
LET cResultado        = '';
LET cFolio            = '';
LET cReverso          = '';

BEGIN
ON EXCEPTION SET iSqlErr
    IF iSqlErr != 0 THEN
        LET cCodRet= iSqlErr;
        RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso;
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/respaldosbd/hectorb/sp_obtenerinforeversioncargo.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


	FOREACH WITH HOLD
		
		SELECT num_credito, importe_cargo, cod_cargo, desc_cargo, resultado, folio, reverso
		INTO  cCredito, iImporte, cCodigo_cargo, cDesc_cargo, cResultado, cFolio, cReverso
		FROM "informix".sd_bitacora_cargos
		WHERE folio_grupo = pFolio_grupo
	
		
		RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso WITH RESUME;

	END FOREACH
			
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "000002";
		LET cMensaje = "No se encontraron registros del folio solicitado";
		RETURN cCodRet,cMensaje,cCredito,iImporte,cCodigo_cargo,cDesc_cargo,cResultado,cFolio,cReverso;
	END IF;
		
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: OBTIENE INFORMACION DE TODOS LOS REVERSOS DE CARGOS DEL FOLIO GRUPAL SOLICITADO', 
'AUTOR: HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: JULIO 2011',
'VERSION: 20110712.1822',
'BD: BDICRED';

CREATE PROCEDURE "informix".sp_select_muestras
(
pEmpresa 	CHAR(3)
)
RETURNING
	CHAR(6) AS COD_RET,
	CHAR(20) AS NUM_CRED,
	CHAR(20) AS NUM_TARJ,
	CHAR(60) AS STA_MES_ANT,
	CHAR(60) AS STA_MES_ACT,
	SMALLINT AS FLAG_AUTO,
	CHAR(2) AS TIPO_LOGICA;

	---DECLARACIONES
    DEFINE iSqlErr				INTEGER;
    DEFINE cCodRet         		CHAR(6);
	DEFINE cNumCredito			CHAR(20);
	DEFINE cNumTarjeta			CHAR(20);
	DEFINE cStatusMesAnt		CHAR(60);
	DEFINE cStatusMesAct		CHAR(60);
	DEFINE sFlagAutomatico		SMALLINT;
	DEFINE dtFechaUltCorte		DATE;
	DEFINE dtFechaHoy			DATE;
	DEFINE sMesUFC 				SMALLINT;
	DEFINE sDiaUFC 				SMALLINT;
	DEFINE sAnioUFC 			SMALLINT;
	DEFINE sMesHoy 				SMALLINT;
	DEFINE sDiaHoy 				SMALLINT;
	DEFINE sAnioHoy 			SMALLINT;
    DEFINE iNRows           	INTEGER;
	DEFINE cTipoLogica			CHAR(2);
	DEFINE dtFechaSigCorte		date;
	

	---INICIALIZACIONES
    LET iSqlErr            		= 0;
    LET cCodRet            		= '000000';
	LET cNumCredito				= '';
	LET cNumTarjeta				= '';
	LET cStatusMesAnt			= '';
	LET cStatusMesAct			= '';
	LET sFlagAutomatico			= 0;
	LET dtFechaUltCorte			= DATE(1);
	LET dtFechaHoy				= DATE(1);
	LET sMesUFC 				= 0;
	LET sDiaUFC 				= 0;
	LET sAnioUFC 				= 0;
	LET sMesHoy 				= 0;
	LET sDiaHoy 				= 0;
	LET sAnioHoy 				= 0;
	LET iNRows              	= 0;
	LET cTipoLogica				= '';
	LET dtFechaSigCorte			= DATE(1);
	

BEGIN
    
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
          RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	---SET DEBUG FILE TO '/home/sysifx/has/sp_select_muestras.out';
	---TRACE ON;
	
	IF NVL(pEmpresa,'') = '' THEN
		LET cCodRet = '000001';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	-- OBTIENE LA ULTIMA FECHA DE CORTE DEL REPOSITORIO DE MUESTRAS
	SELECT MAX(fecha_corte)
	INTO dtFechaUltCorte
	FROM bdicred:'informix'.sd_muestra_edocta
	WHERE empresa = pEmpresa
	AND flag_generacion < 2
	AND fecha_corte = fecha_corte;
	
	--- VALIDA QUE LA ULTIMA FECHA DE CORTE NO ESTE VACIA
	IF NVL(dtFechaUltCorte,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000002';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET sMesUFC = MONTH(dtFechaUltCorte);
	LET sDiaUFC = DAY(dtFechaUltCorte);
	LET sAnioUFC = YEAR(dtFechaUltCorte);
	
	-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;

	
	--- VALIDA QUE LA FECHA DLEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000003';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
	
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE EL ULTIMO CORTE EN LAS MUESTRAS SEA EL CORTE DEL MES EN CURSO
	/*IF sAnioUFC <> sAnioHoy OR sMesUFC <> sMesHoy OR sDiaUFC <> 20 OR sDiaHoy < 20 THEN
		LET cCodRet = '000004';
		RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF*/
	
	--LET dtFechaSigCorte	=  dtFechaUltCorte - 1 UNITS MONTH - 1 units day;
	
	-- OBTIENE LOS DATOS DE LAS MUESTRAS SELECCIONADAS
	FOREACH WITH HOLD
		SELECT	TRIM(NVL(num_credito,'')), 
				TRIM(NVL(num_tarjeta,'')), 
				TRIM(CASE WHEN NVL(estatus_mes_anterior,'') = '' THEN '' ELSE (SELECT descripcion FROM 'informix'.sd_tipocartera WHERE empresa = '001' AND status_cred = estatus_mes_anterior) END), 
				TRIM(CASE WHEN NVL(estatus_mes_actual,'') = '' THEN '' ELSE (SELECT descripcion FROM 'informix'.sd_tipocartera WHERE empresa = '001' AND status_cred = estatus_mes_actual) END),
				NVL(flag_automatico,0),
				tipo_logica
		INTO cNumCredito, cNumTarjeta, cStatusMesAnt, cStatusMesAct, sFlagAutomatico, cTipoLogica
		FROM bdicred:'informix'.sd_muestra_edocta
		WHERE empresa = pEmpresa
		AND fecha_corte = dtFechaUltCorte
		AND flag_generacion < 2
		

		RETURN cCodRet,cNumCredito,cNumTarjeta,cStatusMesAnt,cStatusMesAct,sFlagAutomatico,cTipoLogica WITH RESUME;
	END FOREACH
	
    LET iNRows = dbinfo("sqlca.sqlerrd2");
    
    IF iNRows = 0 THEN
        LET cCodRet = "000005";
        RETURN cCodRet,NULL,NULL,NULL,NULL,NULL,NULL;
    END IF
	
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para obtener las muestras ya seleeccionadas para se candidatas a a generar posteriormente el estado de cuenta', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2011',
'VERSION: 20110805.1813';

CREATE PROCEDURE "informix".sp_valida_numcredito(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaCorte DATE)
RETURNING CHAR (6) AS Codret, 
		  CHAR(100) AS Descripcion,
		  CHAR(20) AS NumCliente,
		  CHAR(20) AS NumCredito,		  
		  CHAR(20) AS NumTarjeta,
		  DATE AS Fecha,
		  DECIMAL(20,2) AS MontoFinVenTrasp,
		  CHAR(2) AS CodStatusAct,
		  CHAR(60) AS DescStatusAct,
		  CHAR (2) AS CodStatusAnt,
		  CHAR(60) AS DescStatusAnt;

---Definicion de Variables          
DEFINE cCodRet               CHAR(6); 
DEFINE cMensajeRet           CHAR(100);
DEFINE iSqlErr      	     INTEGER;
DEFINE iIsamErr              INTEGER;
DEFINE cErrorInfo            CHAR(80);
DEFINE dtFechaCorte           DATE;
DEFINE dtFechaCorteAnt		 DATE;
DEFINE cNumCredito           CHAR(20);
DEFINE cNumTarjeta			 CHAR(20);
DEFINE cNumCte               CHAR(20);
DEFINE dtFecha                DATE;
DEFINE dMtoFinVenTrasp       DECIMAL(20,2);
DEFINE cStatusAct            CHAR(2);
DEFINE cDescStatusAct		 CHAR(60);
DEFINE cStatusAnt            CHAR(2);
DEFINE cDescStatusAnt		 CHAR(60);
DEFINE scont                 SMALLINT;
DEFINE dtFechaHoy 			 DATE;
DEFINE sMesHoy 				SMALLINT;
DEFINE sDiaHoy 				SMALLINT;
DEFINE sAnioHoy 			SMALLINT;


---Inicializaciones
LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Credito Valido";
LET dtFechaCorte				 = MDY(1,1,1900);
LET dtFechaCorteAnt			 = MDY(1,1,1900);         
LET cNumCredito            	 = "";
LET cNumTarjeta            	 = "";
LET cNumCte            	     = "";
LET dtFecha                 	 = MDY(1,1,1900);
LET dMtoFinVenTrasp        	 = 0;
LET cStatusAct             	 = "";
LET cDescStatusAct		  	 = "";
LET cStatusAnt            	 = "";
LET cDescStatusAnt		 	 = "";
LET scont                    = 0;
LET dtFechaHoy				 = MDY(1,1,1900);
LET sMesHoy 				= 0;
LET sDiaHoy 				= 0;
LET sAnioHoy 				= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
     LET cCodRet= iSqlErr;
	 LET cMensajeRet=cErrorInfo;
     RETURN cCodRet, cMensajeRet,'','','','',0,'','','','';
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/informix/sp_valida_numcredito.out';
--TRACE ON;

	--Validacion de parametros de entrada
	IF (pEmpresa='') OR (pFechaCorte='') OR (pNumCredito='') OR (pEmpresa IS NULL) OR (pFechaCorte IS NULL) OR (pNumCredito IS NULL) THEN
		LET cCodRet = "000001";
		LET cMensajeRet="Uno o mas parametros de entrada son invalidos";
	ELSE		
		--Se obtienen las fechas de corte
		--LET dtFechaCorte=pFechaCorte;
		--LET dtFechaCorteAnt=mdy(MONTH(pFechaCorte),'20',YEAR(pFechaCorte)) - 1 units MONTH;
			
		-- OBTIENE LA FECHA DEL SISTEMA
	SELECT fecha_hoy
	INTO dtFechaHoy
	FROM bdicred:'informix'.sd_fechas
	WHERE empresa = pEmpresa;
	--- VALIDA QUE LA FECHA DLEL SISTEMA NO ESTE VACIA
	IF NVL(dtFechaHoy,DATE(1)) = DATE(1) THEN
		LET cCodRet = '000001';
		LET cMensajeRet = 'LA FECHA DEL SISTEMA ESTA VACIA';
	END IF
	LET sMesHoy = MONTH(dtFechaHoy);
	LET sDiaHoy = DAY(dtFechaHoy);
	LET sAnioHoy = YEAR(dtFechaHoy);
	
	--- VALIDA QUE EL ULTIMO CORTE EN LAS MUESTRAS SEA EL CORTE DEL MES EN CURSO
	IF sDiaHoy < 20 THEN
	LET dtFechaCorte = dtFechaHoy - 1 units MONTH;
	LET dtFechaCorte = mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)); 
	LET dtFechaCorteAnt=mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)) - 1 units MONTH;
	ELSE
	LET dtFechaCorte = mdy(MONTH(dtFechaHoy),'20',YEAR(dtFechaHoy));
	LET dtFechaCorteAnt=mdy(MONTH(dtFechaCorte),'20',YEAR(dtFechaCorte)) - 1 units MONTH;
	END IF
		
		IF NOT EXISTS (SELECT num_credito FROM bdicred:"informix".sd_muestra_edocta 
									WHERE num_credito = pNumCredito) THEN
									
			--Se consulta la información del cliente con el credito recibido.					
			SELECT a.num_credito,c.numcte,c.num_tarjeta, a.fecha, a.mto_fin_ven_trasp, 				 
			(CASE WHEN a.monto_vencido > 0 THEN 'BA' WHEN a.mto_venc_trasp > 0 THEN 'BT' WHEN a.sdo_capital = a.sdo_cap_insoluto THEN 'AA' END)estatus_actual,
			(CASE WHEN b.monto_vencido > 0 THEN 'BA' WHEN b.mto_venc_trasp > 0 THEN 'BT' WHEN b.sdo_capital = b.sdo_cap_insoluto THEN 'AA' END)estatus_anterior
			INTO cNumCredito,cNumCte,cNumTarjeta,dtFecha,dMtoFinVenTrasp,cStatusAct,cStatusAnt
			FROM bdicred:"informix".sd_maecred d, 
            bdicred:"informix".sd_maesdoshist a  , 
            bdicred:"informix".sd_tarjeta c, 
            bdicred:"informix".sd_maesdoshist b  
			WHERE d.empresa = '001' 
			AND d.num_credito = pNumCredito
			AND a.num_credito = d.num_credito				
			AND a.fecha=dtFechaCorte
			AND a.empresa = '001'
			AND a.empresa = c.empresa
			AND a.num_credito = c.num_credito
			AND c.secuencia = 
            (SELECT MAX(tar2.secuencia) 
                    FROM bdicred:"informix".sd_tarjeta tar2 
                    WHERE tar2.empresa = a.empresa
                    AND tar2.num_credito = a.num_credito AND tar2.tipo_tarjeta ='T')
			AND c.tipo_tarjeta ='T'
      		AND b.num_credito= d.num_credito
			AND b.empresa=c.empresa
			AND b.num_credito= c.num_credito
			AND b.fecha=dtFechaCorteAnt;
			
			LET scont = dbinfo("sqlca.sqlerrd2");
			IF scont = 0 THEN
				LET cCodRet= "000003";
				LET cMensajeRet= "Numero de Credito no valido";			
			END IF;
			---Se obtienen las descripciones de los estatus
			SELECT descripcion
			INTO cDescStatusAct
			FROM bdicred:"informix".sd_tipocartera
			WHERE status_cred=cStatusAct;
			
			SELECT descripcion
			INTO cDescStatusAnt
			FROM bdicred:"informix".sd_tipocartera
			WHERE status_cred=cStatusAnt;				
		ELSE 
			LET cCodRet = "000002";
			LET cMensajeRet="El credito ya existe como muestra para la fecha de corte";
		END IF;
	END IF;
	RETURN cCodRet, cMensajeRet,NVL(cNumCte,''),NVL(cNumCredito,''),NVL(cNumTarjeta,''),NVL(dtFecha,MDY(1,1,1900)),NVL(dMtoFinVenTrasp,0),NVL(cStatusAct,''),NVL(cDescStatusAct,''),NVL(cStatusAnt,''),NVL(cDescStatusAnt,'');
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para validar si existe el credito y obtener la información del cliente Titular del credito',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 13/JULIO/2011',
'BD: BDICRED',
'VERSION:20110713.1030';

CREATE PROCEDURE "informix".calculamesiversario(diacorte INTEGER, fechatrab DATE, cantidad INTEGER, TpDiasFechaPago INTEGER)
     RETURNING
       CHAR(5)        AS Cod_Ret,
       DATE           AS fecha_mes;

     DEFINE d1            DATE;
     DEFINE cCodRet       CHAR(5);
     DEFINE FechaMes      DATE;
     DEFINE FechaAux      DATE;
     DEFINE ldiaMes       INTEGER;
     DEFINE d2            DATE;

    LET d1      = DATE(1);
    LET cCodRet ='00000';
    LET FechaMes = DATE(1);
    LET FechaAux = DATE(1);

  --  set debug file to "/pisa/cas/calculamesiversario.out";
  --  trace on;

    LET fechatrab = MDY(MONTH(fechatrab),'01',YEAR(fechatrab));

    if (TpDiasFechaPago = 2) then  -- indicador calculos quincenales
        if (diacorte <= 15) then
            CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
        else
            let FechaMes = fechatrab;
        end if;
    else
        CALL "informix".monthadd(fechatrab,cantidad) RETURNING FechaMes;
    end if;

    LET FechaAux = FechaMes;

    WHILE (day(FechaAux) <> diacorte and month(FechaAux) = month(FechaMes))
        LET FechaAux = FechaAux + 1;
    END WHILE

        IF month(FechaAux) <> month(FechaMes) THEN
           LET FechaAux = FechaAux - 1;
        END IF;

    CALL "informix".sp_valfechabil(FechaAux,'+') RETURNING cCodRet, FechaMes;

    RETURN cCodRet, FechaMes;

END PROCEDURE;