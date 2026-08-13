CREATE PROCEDURE "informix".sp_actualiza_tasas_creditos(pnum_producto CHAR(4), ptasa_interes DECIMAL(9,6), ptasa_moratorios DECIMAL(9,6)) RETURNING CHAR(6);
	
-- Creacion: Abril 2019
-- Actualiza tasas de creditos activos de acuerdo a instruccion del area de Credito.

--------------------------------------------------------
-- DEFINICION VARIABLES 
--------------------------------------------------------
DEFINE cod_ret				CHAR(6);
DEFINE sql_err				INTEGER;
DEFINE v_num_credito		CHAR(20);
DEFINE v_numcte             CHAR(20);


--SET DEBUG FILE TO "/resplogifx/sp_actualiza_tasas_creditos.out";
--TRACE ON;


--------------------------------------------------------
--	VARIABLES 
--------------------------------------------------------

LET cod_ret				= "000000";
LET sql_err				= 0;
LET v_num_credito		= "";
LET v_numcte             = "";


BEGIN

	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF
	END EXCEPTION WITH RESUME ;
  
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	

	--SET DEBUG FILE TO "/informix/sp_actualiza_tasas_creditos.out";
	-- TRACE ON;
	
	FOREACH WITH HOLD 
	  SELECT {AVOID_FULL("informix".sd_maecred)} num_credito, numcte INTO v_num_credito, v_numcte 
	    FROM bdicred:sd_maecred WHERE num_producto = pnum_producto AND status_cred IN ('AA','BA','BT','E1','E2','E3')
	                                
		BEGIN;
			UPDATE bdicred:sd_maecred SET tasa_interes = ptasa_interes, tasa_moratorios = ptasa_moratorios WHERE num_credito = v_num_credito;
		COMMIT;		
	   
	END FOREACH;   
	
			
	RETURN cod_ret;
END;
END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_adn_cart_activa (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);

DEFINE dMontoFinanciado  DECIMAL(18,2);
DEFINE dIngresoMens  DECIMAL(18,2);
DEFINE dCapVig           DECIMAL(18,2);
DEFINE dCapTrans         DECIMAL(18,2);
DEFINE dCapVdoExig       DECIMAL(18,2);
DEFINE dCapVdoNoExig     DECIMAL(18,2);

DEFINE cCteCoppel    CHAR(20);
DEFINE cNumCte  	 CHAR(20);
DEFINE cNumCredito  	 CHAR(20);
DEFINE dtFechaSol    DATE;
DEFINE dtFechaApert     DATE;
DEFINE cStatusDesc     CHAR(50);
DEFINE cStatus     CHAR(2);
DEFINE cSucursal     CHAR(4);
DEFINE cFrecuenciaPago     CHAR(20);
DEFINE cSitPago     CHAR(20);
DEFINE iNumVenc     INTEGER;
DEFINE iMesesHist    INTEGER;
DEFINE cGrupo     CHAR(1);
DEFINE cMovil     CHAR(13);
DEFINE dtFechaHoy    DATE;
DEFINE dtFechaConsulta     DATE;

DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(800);
DEFINE cRuta 			CHAR(80);
DEFINE iContador 		INTEGER;
DEFINE iContador2 		INTEGER;
DEFINE dLinea 		 DECIMAL(18,2);
DEFINE dSaldoLC 		 DECIMAL(18,2);
DEFINE cCuentaNom 		CHAR(20);
DEFINE cStatusPago CHAR(10);
DEFINE dMontoFinanciadoPag  DECIMAL(18,2);
DEFINE iFrecuenciaPago  INTEGER;
DEFINE dtFechaMovPag DATE;
DEFINE dtFechaMov DATE;
DEFINE dtFechaMovAux DATE;
DEFINE act_aux      INTEGER;

LET act_aux         = 0;
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET dMontoFinanciado	  = 0;
LET dIngresoMens               = 0;
LET dCapVig               = 0;
LET dCapTrans             = 0;
LET dCapVdoExig           = 0;
LET dCapVdoNoExig         = 0;

LET cCteCoppel   = "";
LET cNumCte  	 = "";
LET cNumCredito  	 = "";
LET dtFechaSol   =DATE(1) ;
LET dtFechaApert    =  DATE(1);
LET cStatusDesc    = "";
LET cStatus    = "";
LET cSucursal     = "";
LET cFrecuenciaPago     = "";
LET cSitPago     = "";
LET iNumVenc    = 0;
LET iMesesHist  = 0;
LET cGrupo     = "";
LET cMovil    = "";

LET dtFechaHoy   =DATE(1) ;
LET dtFechaConsulta    =  DATE(1);

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";
LET iContador	= 0;
LET iContador2	= 0;
LET dLinea 		 = 0;
LET dSaldoLC 		= 0;
LET cCuentaNom 		= "";

LET cStatusPago = "";
LET dMontoFinanciadoPag = 0;
LET iFrecuenciaPago = 0;
LET dtFechaMovPag = null;
LET dtFechaMov = null;
LET dtFechaMovAux = null;
	
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_cart_activa.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy,pri_dia_mes - 1 units day
	INTO dtFechaHoy,dtFechaConsulta	
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;
			 
   --LET dtFechaHoy = mdy(05,05,2016);
   --LET dtFechaConsulta = mdy(04,30,2016);
   --LET dtFechaConsulta = mdy(05,31,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016);		
	
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Cartera_anticiponomina_')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Cartera_anticiponomina_aux')||TO_CHAR(dtFechaHoy,'%d%m%y')|| '.txt';
	
	FOREACH WITH HOLD 
		SELECT a.num_credito , a.fecha_apertura  ,a.numcte , a.status_cred , b.act ,
		a.sucursal,b.mto_fin_ven_trasp,b.sdo_capital, b.monto_vencido,mto_venc_trasp,cap_tras_no_venci,
		fecha_insert,DECODE(frecuencia_pgo,'1','MENSUAL','2','QUINCENAL','3','SEMANAL','MENSUAL'),movil_cuenta,	linea, saldocuenta_lc,cuenta_nomina,frecuencia_pgo
		INTO cNumCredito ,dtFechaApert ,cNumCte ,cStatus ,act_aux ,cSucursal, iNumVenc, 
		dCapVig,dCapTrans,dCapVdoExig,dCapVdoNoExig,
		dtFechaSol, cFrecuenciaPago,cMovil, dLinea, dSaldoLC, cCuentaNom,iFrecuenciaPago
		FROM sd_maecred a, sd_maesdos b , bdisolic:"informix".ss_adn_solicitudcuenta c
         WHERE a.num_credito   = b.num_credito
           AND a.empresa       = b.empresa    
		   AND a.num_credito   = c.num_solicitud
           AND a.empresa       = pEmpresa   
		   AND a.num_producto  = '7800'
		   AND a.status_cred  in('AA','BA','BT','E1','E2','E3')
           AND a.fecha_apertura <= dtFechaConsulta
	
			SELECT numcte_ref
			INTO cCteCoppel
			FROM bdinteg:"informix".si_cliente  
			WHERE numcte = cNumCte;

			SELECT descripcion
			INTO cStatusDesc
			FROM "informix".sd_tipocartera  
			WHERE status_cred = cStatus;
			
			SELECT situacion_pago , meses_historia, ingreso_mensual,grupo
				INTO cSitPago, iMesesHist, dIngresoMens, cGrupo
			FROM bdisolic:"informix".ss_resum_scor_fin  
			WHERE num_solicitud = cNumCredito;
		 
		 
		 IF NVL (dSaldoLC,0) = 0 THEN
			 SELECT NVL(monto_tot,0) 
				  INTO dSaldoLC
				  FROM bdicheq:"informix".sc_movhis mov
				INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
				 WHERE cuenta = cCuentaNom 
				   AND cancelad <> 'S'
				   AND fech_alt <= dtFechaApert
				   AND num_serial = (SELECT MAX(num_serial) FROM bdicheq:"informix".sc_movhis mov2
								INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov2.transacc AND tran.activo = 2)
									 WHERE cuenta = cCuentaNom 
									   AND cancelad <> 'S' 
									   AND fech_alt <= dtFechaApert);
									   
			 IF NVL (dSaldoLC,0) = 0 THEN						   
				 SELECT NVL(monto_tot,0) 
					  INTO dSaldoLC
					  FROM bdicheq:"informix".sc_movhis_old mov
					INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov.transacc AND tran.activo = 2)
					 WHERE cuenta = cCuentaNom 
					   AND cancelad <> 'S'
					   AND fech_alt <= dtFechaApert
					   AND num_serial = (SELECT MAX(num_serial) FROM bdicheq:"informix".sc_movhis_old mov2
									INNER JOIN bdicred:"informix".sd_transvalprod  tran ON (tran.transacc = mov2.transacc AND tran.activo = 2)
										 WHERE cuenta = cCuentaNom 
										   AND cancelad <> 'S' 
										   AND fech_alt <= dtFechaApert);						   
									   
				END IF;		
				
				UPDATE  bdisolic:"informix".ss_adn_solicitudcuenta 
					SET saldocuenta_lc = dSaldoLC
				WHERE empresa='001' 
				AND num_solicitud=cNumCredito; 
									   
		 END IF;
		 

		
		FOREACH WITH HOLD
		
			SELECT monto,fecha_mov
			INTO dMontoFinanciado, dtFechaMov
			FROM bdicred:sd_movhis
			where empresa='001'
			and num_credito =cNumCredito
			and transacc_suc='8174'
			AND MONTH(fecha_mov) = MONTH(dtFechaConsulta)
			ORDER BY fecha_mov DESC
			
			IF iFrecuenciaPago = 1 THEN--mensual
				LET dtFechaMovAux = MONTHADD(dtFechaMov,1) ;
			ELIF iFrecuenciaPago = 2 THEN --quinsenal
					LET dtFechaMovAux = dtFechaMov + 15 UNITS DAY ;	
			ELSE--semanal
				LET dtFechaMovAux = dtFechaMov + 7 UNITS DAY ;	
			END IF 
						
			SELECT SUM(monto),MAX(fecha_mov)
			INTO dMontoFinanciadoPag, dtFechaMovPag
			FROM bdicred:sd_movhis
			where empresa='001'
			and num_credito =cNumCredito
			and transacc_suc='8175'
			and codigo_fun ='074'
			and codigo_ref =1
			AND fecha_mov > dtFechaMov
			AND MONTH(fecha_mov) = MONTH(dtFechaConsulta)
			AND fecha_mov 	<= dtFechaMovAux;
			
			IF dMontoFinanciadoPag > 0 THEN 
				LET cStatusPago = "PAGADO";			
			ELSE 
				LET cStatusPago = "PENDIENTE DE PAGO";
			END IF;
			
			IF (cStatus <>  'AA' OR ( NVL(act_aux,-1) <> 0 and cStatus <> 'E1'))  THEN
				LET cStatusPago = "NO PAGADO";	
			END IF;
			
				LET cConsulta = TRIM(NVL(cCteCoppel,''))||'|'|| TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cNumCredito,''))||'|'||dtFechaSol||'|'|| TRIM(NVL(dtFechaApert,''))||'|'|| TRIM(NVL(cStatusDesc,''))||'|'||  NVL(dIngresoMens,0)||'|'|| NVL(dMontoFinanciado,0)||'|'|| TRIM(NVL(cSucursal,''))||'|'|| TRIM(NVL(cFrecuenciaPago,''))||'|'|| NVL(iNumVenc,0)||'|'|| TRIM(NVL(cSitPago,''))||'|'|| TRIM(NVL(iMesesHist,''))||'|'|| TRIM(NVL(cGrupo,''))||'|'|| TRIM(NVL(cMovil,''))||'|'|| NVL(dCapVig,0)||'|'|| NVL(dCapTrans,0)||'|'|| NVL(dCapVdoExig,0)||'|'|| NVL(dCapVdoNoExig,0)||'|'||NVL(dCapVig,0)||'|'||NVL(dLinea,0)||'|'||NVL(dSaldoLC,0)||'|'||NVL(dtFechaMov,'')||'|'||NVL(dtFechaMovPag,'')||'|'||NVL(dMontoFinanciadoPag,0)||'|'||NVL(cStatusPago,'');

		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
		LET iContador2	=  1; 	
			EXIT FOREACH;
		
		END FOREACH;

		
		
		
		
		

	IF iContador2 =0 THEN
		LET cConsulta = TRIM(NVL(cCteCoppel,''))||'|'|| TRIM(NVL(cNumCte,''))||'|'|| TRIM(NVL(cNumCredito,''))||'|'||dtFechaSol||'|'|| TRIM(NVL(dtFechaApert,''))||'|'||TRIM(NVL(cStatusDesc,''))||'|'||  NVL(dIngresoMens,0)||'|'|| NVL(dMontoFinanciado,0)||'|'|| TRIM(NVL(cSucursal,''))||'|'|| TRIM(NVL(cFrecuenciaPago,''))||'|'|| NVL(iNumVenc,0)||'|'|| TRIM(NVL(cSitPago,''))||'|'|| TRIM(NVL(iMesesHist,''))||'|'|| TRIM(NVL(cGrupo,''))||'|'|| TRIM(NVL(cMovil,''))||'|'|| NVL(dCapVig,0)||'|'|| NVL(dCapTrans,0)||'|'|| NVL(dCapVdoExig,0)||'|'|| NVL(dCapVdoNoExig,0)||'|'||NVL(dCapVig,0)||'|'||NVL(dLinea,0)||'|'||NVL(dSaldoLC,0)||'|'||NVL(dtFechaMov,'')||'|'||NVL(dtFechaMovPag,'')||'|'||NVL(dMontoFinanciadoPag,0)||'|'||NVL(cStatusPago,'');

		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;		
	END IF 	
	LET iContador	=  1; 
	LET iContador2	=  0; 
	LET cStatusPago = "";
	LET dMontoFinanciadoPag = 0;
	LET dMontoFinanciado = 0;
	LET dSaldoLC = 0;
	LET dtFechaMovPag = null;
	LET dtFechaMov = null;
	
    END FOREACH;

		IF iContador  > 0 THEN 	

			---se ejecuta para ponerle el encabezado 
			LET cEncabezado = 'echo "NÃ¯Â¿Â½mero de Cliente Coppel'||'|'||'NÃ¯Â¿Â½mero de Cliente BanCoppel'||'|'||'NÃ¯Â¿Â½mero de CrÃ¯Â¿Â½dito'||'|'||'Fecha de solicitud del CrÃ¯Â¿Â½dito'||'|'||'Fecha de Apertura del CrÃ¯Â¿Â½dito'||'|'||'Estatus'||'|'||'Ingreso mensual declarado'||'|'||'Monto prÃ¯Â¿Â½stado'||'|'||'Sucursal origen'||'|'||'Periodicidad de pago'||'|'||'Incumplimientos'||'|'||'Eficiencia de Pago Coppel'||'|'||'Meses de Historia Coppel'||'|'||'Grupo de OriginaciÃ¯Â¿Â½n'||'|'||'NÃ¯Â¿Â½mero de Celular'||'|'||'Capital Vigente'||'|'||'Capital transitorio'||'|'||'Capital Vencido Exigible'||'|'||'Capital Vencido No Exigible'||'|'||'Monto a pagar para liquidar el crÃ¯Â¿Â½dito'||'|'||'LÃ¯Â¿Â½nea otorgada'||'|'||'Ingreso utilizado para determinar la lÃ¯Â¿Â½nea de crÃ¯Â¿Â½dito'||'|'||'Fecha de Disposicion'||'|'||'Fecha de Pago'||'|'||'Suma de Pagos'||'|'||'Estatus de Pago'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		
	
			SYSTEM cEncabezado;

			LET cSql = cSql;
			LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
			SYSTEM cSql;


			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
			SYSTEM cSQL;   	

			RETURN cCodRet,cMensajeRet;

		ELSE
			LET cCodRet			= '00000';
			LET cMensajeRet			= 'No se encontro informaciÃ¯Â¿Â½n';
			RETURN cCodRet,cMensajeRet;
		END IF;			
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de NÃ¯Â¿Â½mina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_adn_res_general (pEmpresa CHAR (3))	
RETURNING CHAR(5),       -- Codigo de Retorno
		  CHAR(80);      -- Mensaje de Retorno

DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE cErrorInfo   VARCHAR(255,1);
DEFINE cCodRet      CHAR(6);
DEFINE cCod_ret      CHAR(6);
DEFINE cMensajeRet CHAR(80);


DEFINE cSql            	CHAR(2500);
DEFINE cNombreArchivo  	CHAR(150);
DEFINE cNombreArchivo1  CHAR(150);
DEFINE cConsulta		CHAR(2200);
DEFINE cEncabezado		CHAR(600);
DEFINE cRuta 			CHAR(80);

DEFINE	dtFechaHoy	DATE;
DEFINE	dtFechaFinMes	DATE;
DEFINE	dTFechaSD	DATE;

DEFINE dMontoTotal 		DECIMAL(18,2);
DEFINE dMontoCap 		DECIMAL(18,2);
DEFINE dTotalActAnticipo 		INTEGER;
DEFINE dTotalSolAnticipo 		INTEGER;
DEFINE dTotalSolAnticiport 		INTEGER;


LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = "00000";
LET cCod_ret         = "00000";
LET cMensajeRet     = "Proceso Exitoso";

LET cSql			= '';
LET cNombreArchivo  = '';
LET cNombreArchivo1  = '';
LET cConsulta		= '';
LET cEncabezado		= '';
LET cRuta	= "";

LET	dtFechaHoy	= DATE(1);
LET	dtFechaFinMes	= DATE(1);
LET	dTFechaSD	 =DATE(1);
LET	 dMontoTotal 		= 0;
LET	 dMontoCap 		= 0;
LET	 dTotalActAnticipo 		= 0;
LET	 dTotalSolAnticipo 		= 0;
LET	 dTotalSolAnticiport 	= 0;



BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
		RETURN iSqlErr,cErrorInfo ;
   END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/informix/jesus/RQM10617/sp_adn_res_general.out';
	--TRACE ON;

	IF NVL(pEmpresa,'') = ''  THEN
		RETURN  '00001','PARAMETROS DE ENTRADA INVALIDOS' ;
	ELSE
	
	
	
	  --RUTA PARA GENERAR EL ARCHIVO
	SELECT valor
	INTO cRuta
	FROM bdicred:"informix".sd_param  
	WHERE empresa = '001' 
	AND cod_param='081';
	
	--SINO EXISTE LA RUTA DEL ARCHIVO	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		LET cMensajeRet ='NO EXISTE PARAMETRO DE LA RUTA PARA GENERAR EL ARCHIVO';
		RETURN cCodRet,cMensajeRet;
	END IF;	 
	
	SELECT a.fecha_hoy
	INTO dtFechaHoy
	FROM "informix".sd_fechas a
	WHERE a.empresa = pEmpresa;

	--LET dtFechaHoy = mdy(05,05,2016);
	--LET dtFechaHoy = mdy(06,05,2016);
	--LET dtFechaHoy = mdy(07,05,2016);		 
			 
	--GENERA EL NOMBRE DEL ARCHIVO
	LET cNombreArchivo = TRIM('Resultados_Generales_ADN_Mes_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	LET cNombreArchivo1 = TRIM('Resultados_Generales_ADN_Mes_aux_')||TO_CHAR(dtFechaHoy,'%m%y')|| '.txt';
	
	LET dtFechaFinMes = mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)) - 1 units day;
	LET dTFechaSD = bdicred:MONTHADD(mdy(month(dtFechaHoy),01,YEAR(dtFechaHoy)), - 1);
	
	

		SELECT count(num_solicitud)
		INTO dTotalSolAnticipo
		FROM bdisolic:"informix".ss_solicitudes
		WHERE  empresa='001'
		and num_solicitud >=''
		and num_producto ='7800'
		and status_solicitud in ('RT','AT','AP')
		and fecha_insert BETWEEN dTFechaSD AND dtFechaFinMes;



		LET cConsulta = "No. Solicitudes efectuadas en el periodo"||'|'|| NVL(dTotalSolAnticipo,'')||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
			
			
		SELECT count(num_solicitud)
		INTO dTotalSolAnticipoRt
		FROM bdisolic:"informix".ss_solicitudes
		WHERE  empresa='001'
		and num_solicitud >=''
		and num_producto ='7800'
		and status_solicitud = 'RT'
		and fecha_insert BETWEEN dTFechaSD AND dtFechaFinMes;

		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito;

		LET cConsulta = "No. Anticipos Activados (Autorizados)"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

		--liquidados
		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		--and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito				
		and status_cred ='FF';

			LET cConsulta = "Liquidados"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
		--Pagados
		
		SELECT  SUM(a.monto), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM  bdicred:sd_maesdos b, bdicred:sd_maecred c, bdicred:sd_movhis  a
		WHERE  a.empresa='001' 
		and a.num_credito = b.num_credito 
		and a.num_credito = c.num_credito 
		AND  c.num_producto ='7800'
		and a.fecha_mov BETWEEN dTFechaSD AND dtFechaFinMes
		and a.transacc_suc = '8175'
		AND codigo_ref =1;

		LET cConsulta = "Pagados"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

		---disposiciones
		SELECT  SUM(a.monto), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM  bdicred:sd_maesdos b, bdicred:sd_maecred c, bdicred:sd_movhis  a
		WHERE  a.empresa='001' 
		and a.num_credito = b.num_credito 
		and a.num_credito = c.num_credito 
		AND  c.num_producto ='7800'
		and a.fecha_mov BETWEEN dTFechaSD AND dtFechaFinMes
		and a.transacc_suc = '8174'
		AND a.codigo_fun = '002'
		and a.codigo_ref =111;

		LET cConsulta = "Disposiciones"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	
			
		
		--vigentes
		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		--and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito				
		and a.status_cred IN ('AA','E1') and (b.monto_vencido + b.mto_venc_trasp) = 0;
		
		LET cConsulta = "Vigentes"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	

		--vencidos
		
		SELECT SUM(b.monto_otorgado), SUM(b.sdo_cap_insoluto) ,count(a.num_credito)
		INTO dMontoTotal,dMontoCap, dTotalActAnticipo
		FROM bdicred:"informix".sd_maecred a , bdicred:"informix".sd_maesdos b
		WHERE   a.empresa ='001'
		AND  a.num_producto ='7800'			
		--and a.fecha_apertura BETWEEN dTFechaSD AND dtFechaFinMes
		AND  a.empresa=b.empresa
		and a.num_credito = b.num_credito				
		and a.status_cred IN ('BA','BT','E1','E2','E3') AND (b.monto_vencido + b.mto_venc_trasp) > 0;

			LET cConsulta = "Vencidos"||'|'|| NVL(dTotalActAnticipo,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;			

		LET dMontoTotal=0;
		LET dMontoCap=0;

		LET cConsulta = "Rechazados"||'|'|| NVL(dTotalSolAnticipoRt,0)||'|'||NVL(dMontoTotal,0)||'|'||NVL(dMontoCap,0);
		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo " '||TRIM(cConsulta)||'" >> '||TRIM(cruta)|| cNombreArchivo1;  
		SYSTEM cEncabezado;	



		---se ejecuta para ponerle el encabezado 
		LET cEncabezado = 'echo "Conceptos'||'|'||'No. Anticipos'||'|'||'Monto Anticipo Autorizada'||'|'||'Saldo Insoluto'||'|'|| '" > '||TRIM(cruta)|| cNombreArchivo;  
		SYSTEM cEncabezado;

		LET cSql = cSql;
		LET cSql = "sed 's/|$//g' "|| TRIM(cRuta) || TRIM(cNombreArchivo1) || " >> " || TRIM(cRuta) || TRIM(cNombreArchivo);
		SYSTEM cSql;


		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cruta) || cNombreArchivo1;
		SYSTEM cSQL;   	

		RETURN cCodRet,cMensajeRet;

		
	END IF;		
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea procedimiento para validacion de los resultados del Anticipo de Nï¿½mina de forma general',
'AUTOR :  Jesus Manuel Aguilar',
'FECHA : 24/abril/2016',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_calculo_grupoa (cEmpresa CHAR(3), p_numproducto CHAR(4))
    RETURNING CHAR(5)  AS Codigo_retorno, 
              CHAR(80) AS Mensaje,              
              CHAR(25) AS StorePro;              

DEFINE vsqlerr          INTEGER; 
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

DEFINE v_codigo_retorno	CHAR(5);
DEFINE v_mensaje	  	CHAR(80);

DEFINE v_store_pro      CHAR(25);

DEFINE dtFechaHoy       DATE;
DEFINE dtFechaProx      DATE;
DEFINE dtFechaFinMes    DATE;
DEFINE dtFechaCortePrev DATE;
DEFINE dtFechaCorte1mes DATE;
DEFINE dtFechaHoy_aux   DATE;

DEFINE vc_crdcontproc   CHAR(1);
DEFINE vc_intcontproc 	CHAR(1);

DEFINE vc_numproducto   CHAR (4);
DEFINE vc_numcredito    CHAR(20);
DEFINE vc_numcte        CHAR(20); 
DEFINE vc_statuscred    CHAR(2);
DEFINE vd_motorgado     DECIMAL(18,2);
DEFINE vd_cap_insoluto  DECIMAL(18,2);
DEFINE vi_porcentaje_uso    DECIMAL(18,2);
DEFINE vi_porcentaje_usoUM  DECIMAL(18,2);

DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
DEFINE vf_vig_fecha_fac     DATE;
DEFINE vc_tipoproceso       CHAR(20);
DEFINE vf_fechapertu        DATE;
DEFINE vi_meses_antigdad    INTEGER;
DEFINE  vlNumCredito        CHAR(20);
--DEFINE ren_empresa  CHAR(3);
--DEFINE ren_producto CHAR(4);
--DEFINE ren_credito  CHAR(20);
DEFINE vi_meses_vigts       INTEGER;
DEFINE vd_usolinea_min      DECIMAL(5,2);
DEFINE vd_usolinea_max      DECIMAL(5,2);
DEFINE vcontador            SMALLINT;
DEFINE vs_dia_cort_prod     SMALLINT;
DEFINE vPorcUtil80          SMALLINT;

LET vc_numproducto      ='';
LET vc_numcredito       ='';
LET vc_numcte           =''; 
LET vc_statuscred       ='';
LET vd_motorgado        = 0; 
LET vd_cap_insoluto     = 0;
LET vi_porcentaje_uso   = 0;
LET vi_porcentaje_usoUM =0;
LET vd_capital_insol    = 0;
LET vd_mto_fin_ven_trasp   = 0;
LET vf_vig_fecha_fac    = DATE(1);
LET vc_tipoproceso      = '';
LET vf_fechapertu       = DATE(1);
LET dtFechaHoy_aux      = DATE(1);
LET vi_meses_antigdad   = 0;
--LET ren_empresa = '';
--LET ren_producto ='';
--LET ren_credito ='';
LET vi_meses_vigts      = 0;
LET vd_usolinea_min     = 0;
LET vd_usolinea_max     = 0;
LET vcontador           = 0;
LET vlNumCredito        = '';
LET vs_dia_cort_prod    = 0;
LET vPorcUtil80         = 0;

LET v_codigo_retorno    = "00000";
LET v_mensaje           = "Proceso Inicia Correctamente";
LET v_store_pro         = 'sp_calculo_grupoa';
--LET vc_tipoproceso    = 'FiltroGpo6_' || TRIM (p_numproducto);
LET vc_tipoproceso      = 'CalculoGpoA_' || TRIM (p_numproducto); 

--SET DEBUG FILE TO "/informix/mahr/sp_calculo_grupoa" ||p_numproducto|| ".out";
--TRACE ON;

SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr ,iIsamErr,cErrorInfo         
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = vsqlerr;
            LET v_mensaje = cErrorInfo;
            LET v_store_pro = 'sp_calculo_grupoa';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
    END IF;
   END EXCEPTION;


    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros	
	--Fecha Creacion: 05/JUNIO/2012 || Fecha Modifica: 16/OCTUBRE/2012
	--Objetivo: Valida Clientes que son candidatos al Grupo "A" 6, por tener buen comportamiento de Credito SP exclusivo para Tarjeta de Credito 
    --                
    -- Fecha Modificacion: Dic 2016. Se agregan productos de Tarjeta Platino y Tarjeta Oro. Se corrige proceso para evaluar a nivel cliente.          
	--*********************************************************--

    IF (p_numproducto <> '6001' ) AND (p_numproducto <> '7000' ) AND (p_numproducto <> '8100') THEN
        LET v_codigo_retorno = "00035";
        LET v_mensaje="NO. DE PRODUCTO, INVALIDO PARA EJECUTAR EN EL SP, VERIFIQUE!";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
     END IF;

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = cEmpresa;

         --FMV 6ago12: Validacion de los meses vigentes y los porcentajes de uso de linea en grupo A
    SELECT valor::integer
      INTO vi_meses_vigts
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '55';

    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_min
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '56';

    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00041";
        LET v_mensaje="Falta parametro del porcentaje minimo uso de linea";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_max
      FROM "informix".sd_param
     WHERE empresa = cEmpresa
       AND cod_param = '57';

    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00042";
        LET v_mensaje="Falta parametro del porcentaje maximo uso de linea";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    -- FMV 4-OCT-12 Omite validacion para 1a. corrida
    --      IF (DAY(dtFechaHoy) <> 20)
    --       THEN
    --              LET v_codigo_retorno = "00032";
    --              LET v_mensaje="DIA DE EJECUCION NO ES MESIVERSARIO EN DIA 20 DE MES ";
    --              LET v_store_pro = 'sp_calculo_grupoa';
    --          RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    --      END IF; 

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc
     WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPOA, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_calculo_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    IF (vc_intcontproc IS NULL) THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
               VALUES (cEmpresa,vc_tipoproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;  
    IF (vc_crdcontproc IS NULL) THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
               VALUES (cEmpresa,vc_tipoproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos grupoA');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA' WHERE empresa = cEmpresa AND fecha = dtFechaHoy AND proceso = vc_tipoproceso;
    END IF;
    /*LET dtFechaHoy = mdy(month(dtFechaHoy),'20',year(dtFechaHoy));
    SELECT first 1 num_credito into vlNumCredito FROM sd_maesdoshist  WHERE empresa = '001' AND FECHA= dtFechaHoy;
    IF '' = NVL(vlNumCredito,'') THEN     
        LET dtFechaHoy = dtFechaHoy -1 UNITS MONTH;
    END IF;*/

    -- Obtiene el dia de corte para cada producto, y armar asi la fecha de corte previo correspondiente.
    SELECT dia_cuota INTO vs_dia_cort_prod FROM bdicred:sd_definicion WHERE empresa = cEmpresa AND num_producto = p_numproducto;
    LET dtFechaHoy_aux = monthadd(dtFechaHoy,- 1);

    IF DAY(dtFechaHoy) <= vs_dia_cort_prod THEN
        --LET dtFechaCortePrev = mdy(month(dtFechaHoy -1 UNITS MONTH),vs_dia_cort_prod,year(dtFechaHoy));
        LET dtFechaCortePrev = mdy(month(dtFechaHoy_aux),vs_dia_cort_prod,year(dtFechaHoy_aux)); -- Fecha corte de mes anterior
    ELSE
        LET dtFechaCortePrev = mdy(month(dtFechaHoy),vs_dia_cort_prod,year(dtFechaHoy));
    END IF;
    
	LET vf_vig_fecha_fac = monthadd(dtFechaCortePrev,- vi_meses_vigts);

    FOREACH WITH HOLD                                   
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu, vc_statuscred, vd_motorgado, vd_cap_insoluto                        
          FROM bdicred:"informix".sd_maecred a,				        
               bdicred:"informix".sd_maesdoshist b, ---max
               bdicred:"informix".sd_maesdos d
         WHERE a.empresa = cEmpresa   
           AND a.empresa = b.empresa
           AND a.empresa = d.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = d.num_credito
           AND b.fecha = dtFechaCortePrev
           AND a.num_producto = p_numproducto
           AND a.status_cred IN ('AA','E1')
		   AND (d.monto_vencido + d.mto_venc_trasp) = 0
           --AND ((b.sdo_cap_insoluto/ b.monto_otorgado)*100)>=vd_usolinea_min
           --AND ((b.sdo_cap_insoluto/ b.monto_otorgado)*100)<=vd_usolinea_max
           AND b.monto_otorgado > 0
           AND d.monto_otorgado > 0
           AND A.fecha_apertura <= vf_vig_fecha_fac
           AND a.num_credito not in (select num_credito from bdicred:sd_grupo_credito where empresa = '001' and fecha_status = dtFechaHoy)

        LET vPorcUtil80 = 0;
        --LET vd_mto_venc_trasp = 0;  mto_fin_ven_trasp
        LET vd_mto_fin_ven_trasp = 0;

        SELECT count(*) INTO vPorcUtil80 FROM bdicred:sd_maesdoshist    -- Al menos uno de los meses previos tuvo 80% de utilizacion
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = cEmpresa AND num_credito = vc_numcredito
           AND ((sdo_cap_insoluto * 100) / monto_otorgado ) >= vd_usolinea_min
		   AND monto_otorgado > 0;

        SELECT NVL(SUM(mto_fin_ven_trasp),0) INTO vd_mto_fin_ven_trasp  FROM bdicred:"informix".sd_maesdoshist -- Los meses previos no haya tenido vencidos
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = cEmpresa AND num_credito = vc_numcredito;

        IF ( vPorcUtil80 = 0 OR vd_mto_fin_ven_trasp >= 1 ) THEN -- Si el cliente tuvo un vencido o no tuvo al menos un mes con 80%, no continua.
            CONTINUE FOREACH;
        END IF;

        LET vcontador = 0;
        IF vd_cap_insoluto <=0 THEN
            LET vi_porcentaje_uso = 0;
        ELSE
            LET vi_porcentaje_uso = ((vd_cap_insoluto * 100) / vd_motorgado);
        END IF;
                      
        --LET vcontador  = 0; 
        -- IF vi_porcentaje_usoUM > vd_usolinea_max THEN
        IF vi_porcentaje_uso > vd_usolinea_max THEN -- Rebasa el 100%, es decir, esta sobregirado en el ultimo corte
            LET vcontador  = 1; 
        END IF;   

        IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito WHERE empresa = cEmpresa
                          AND num_credito = vc_numcredito AND numcte = vc_numcte) AND (vcontador = 0)  THEN
                        
            --IF (vd_mto_fin_ven_trasp <= 0) THEN
            BEGIN WORK;                            
                INSERT INTO bdicred:"informix".sd_grupo_credito (empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                            status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(cEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,  --Calculo exclusivo de tarjeta
                                            vi_meses_vigts, 'Informix', dtFechaHoy);       
            COMMIT WORK;						
            --END IF; --IF vd_mto_fin_ven_trasp <= 0 AND                                                                
        ELSE 
            IF (vcontador = 0)  THEN
                BEGIN WORK;
                    UPDATE bdicred:sd_grupo_credito
                       SET fecha_status = dtFechaHoy,
                           status_cred  = vc_statuscred,
                           porcentaje_uso= vi_porcentaje_uso,
                           monto_autorizado=vd_motorgado,
                           num_historia_efic = num_historia_efic + 1
                     WHERE empresa = cEmpresa
                       AND num_credito = vc_numcredito
                       AND numcte  = vc_numcte;
                COMMIT WORK;
            END IF;
        END IF;  --IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito       
    END FOREACH;


    -- Incluye los nuevos creditos cuyo Cliente ya existe como grupo A. Ya que como son nuevos creditos el proceso anterior no los contempla por no cumplir 
    -- los 6 meses de antiguedad o en estatus vigente.
    LET dtFechaCorte1mes = monthadd(dtFechaHoy, - 1);
    LET dtFechaCorte1mes = dtFechaCorte1mes + 1 units day;
 
    FOREACH WITH HOLD
        SELECT a.num_producto, a.num_credito, a.numcte, a.fecha_apertura, a.status_cred, NVL(b.monto_otorgado,0), NVL(b.sdo_cap_insoluto,0)
          INTO vc_numproducto, vc_numcredito, vc_numcte, vf_fechapertu, vc_statuscred, vd_motorgado, vd_cap_insoluto
          FROM bdicred:"informix".sd_maecred a,
               bdicred:"informix".sd_maesdos b,
               bdisolic:ss_resum_scor_fin scor
         WHERE a.empresa = cEmpresa
           AND a.empresa = b.empresa
           AND a.empresa = scor.empresa
           AND a.num_credito = b.num_credito
           AND a.num_credito = scor.num_solicitud
           AND a.num_producto = p_numproducto
           AND a.status_cred IN ('AA','E1')
		   AND (b.monto_vencido + b.mto_venc_trasp) = 0
           AND b.monto_otorgado > 0
           AND a.fecha_apertura >= dtFechaCorte1mes AND a.fecha_apertura <= dtFechaHoy -- Fecha apertura desde la ultima  corrida a la fecha
           AND scor.grupo = 'A'
           AND a.numcte in (Select numcte From bdicred:sd_grupo_cliente)

        IF NOT EXISTS (SELECT * FROM bdicred:sd_grupo_credito WHERE empresa = cEmpresa AND num_credito = vc_numcredito AND numcte = vc_numcte) THEN
                        
            BEGIN WORK;                            
                INSERT INTO bdicred:"informix".sd_grupo_credito (empresa, num_producto, num_credito, numcte, grupo, tipo, status_cliente, fecha_status,
                                            status_cred, monto_autorizado, porcentaje_uso, num_historia_efic, user_insert, fecha_insert)
                     VALUES(cEmpresa, vc_numproducto, vc_numcredito, vc_numcte, 'A', 9, 'A', dtFechaHoy, vc_statuscred, vd_motorgado, vi_porcentaje_uso,  --Calculo exclusivo de tarjeta
                                            vi_meses_vigts, 'Informix', dtFechaHoy);       
            COMMIT WORK;						
        END IF;
    END FOREACH;


    -- /* FMV 9-AGO-12: Esta seccion de codigo se habilitarÃ¡ para la 2a. corrida
    --LET ren_empresa = cEmpresa;
    --LET ren_producto= p_numproducto;  
    --LET ren_credito = vc_numcredito;

    --FMV 5Jul12: Existe el registro en la sd_grupo_credito, entonces busco q no tenga vencido reciente          
    CALL "informix".sp_renueva_grupoa(cEmpresa, p_numproducto, vs_dia_cort_prod, dtFechaHoy) RETURNING v_codigo_retorno, v_mensaje, v_store_pro;
                  

    IF v_codigo_retorno = "00000" THEN           
        LET v_mensaje        = "Proceso filtro grupoa Tarjeta, Termino Correctamente";
        LET v_store_pro      = 'sp_calculo_grupoa';
        --LET vc_intcontproc   = 'F';
        --LET vc_crdcontproc   = 'F';

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT                      
         WHERE empresa = cEmpresa
           AND fecha   = dtFechaHoy 
           AND proceso = vc_tipoproceso;
 
        UPDATE bdicred:sd_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT,
		       mensaje = 'Filtro Grupo A Tarjeta, Termino Correctamente!'
         WHERE empresa = cEmpresa
           AND fecha = dtFechaHoy
           AND proceso = vc_tipoproceso;
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin    
END PROCEDURE;