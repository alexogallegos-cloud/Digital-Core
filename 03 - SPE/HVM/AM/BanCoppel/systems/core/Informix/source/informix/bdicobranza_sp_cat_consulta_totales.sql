CREATE PROCEDURE "informix".sp_cat_consulta_totales(pEmpresa       CHAR(3),
													pProducto	   CHAR(4),
													pCampania      CHAR(1),
													pPagosVencMin  INTEGER,
													pPagosVencMax  INTEGER,
													pMontoMin      DECIMAL(18,2),
													pMontoMax      DECIMAL(18,2),
													pEstado        CHAR(2),
													pNumCiudad     CHAR(3),
													pRegion        SMALLINT ,
													pSitEsp        CHAR(1),
													pCausa	       SMALLINT,
													pStatus        CHAR(2),
													pTipoMov       INTEGER,
													pTipoResul     SMALLINT,
													pExepcion      CHAR(6),
													pLogica        SMALLINT,
													pRegistros     INTEGER,
													pAgrupar       INTEGER,												
													pSaldos		   INTEGER)

RETURNING CHAR(6)   	AS Codigo_Retorno,
		  CHAR(1)  	 	AS Tipo_campania,
		  SMALLINT 	 	AS Logica,
          CHAR(1)		AS Situacion,
		  SMALLINT 	 	AS Causa,
  		  CHAR(100) 	AS Status,
		  CHAR(30) 	 	AS Tipo_movto,
		  CHAR(7)		AS intento_llamada,
		  SMALLINT		AS totExito,
		  SMALLINT		AS totFallido,
		  CHAR(30) 	 	AS Resultado,
		  CHAR(6)   	AS Excepcion,
		  CHAR(30) 	 	AS Region,
		  DECIMAL(18,2) AS Pago_Min,
		  DECIMAL(18,2) AS Saldo_Total,				
		  DECIMAL(18,2) AS MontUltPago,
		  DECIMAL(18,2) AS dCapVdoExig,--Pago Vencido
		  DECIMAL(18,2) AS PagoMinSinVdo,
		  INTEGER  	 	AS TotalCliente,
		  INTEGER 	 	AS Total;		  

--Modificado por: Enrique Lizárraga Lugo
--Fecha de Modificación: 24/Ene/2011
--Se quitan consultas a la tabla cb_cat_resultado_llamada y en su lugar se añaden a la consulta principal
--los nuevos campos codigo_resultado y fecha_ultimo_contacto

--DECLARACION DE VARIABLES
----------------------------------------------------------------------------------------------------------
DEFINE cCodRet                CHAR(6);
DEFINE iSqlErr      	      INTEGER;
DEFINE iIsamErr               INTEGER;
DEFINE cErrorInfo             CHAR(80);
DEFINE cCodRet2               CHAR(6); 
DEFINE cMensajeRet2           CHAR(80);
DEFINE cNumCte       	      CHAR(20);
DEFINE sLogica				  SMALLINT;
DEFINE cSitEsp        	      CHAR(2);
DEFINE cEstatus        	      CHAR(2);
DEFINE cTipoMovto			  SMALLINT;
DEFINE cDescMovto			  CHAR(30);
DEFINE iCausa       	      INTEGER;
DEFINE cDescripcionEstatus    CHAR(100);
DEFINE cDescripcionRegion     CHAR(30);
DEFINE iTotal      		      INTEGER;
DEFINE iTotalCliente	      INTEGER;
DEFINE contador     	      INTEGER;
DEFINE cExcepcion 		      CHAR(6);
DEFINE iResultado      		  SMALLINT;
DEFINE cDescripcionResultado  CHAR(100);
DEFINE cCampania      	      CHAR(1);
DEFINE cEmpresa 		      CHAR(3);
DEFINE cNumCredAux            CHAR(20);
DEFINE dtFechaAux             DATE;
DEFINE dMontoUltPag			  DECIMAL(18,2);
DEFINE dPagoMinSinVdo         DECIMAL(18,2);
DEFINE dtFechaRep		      DATE;
DEFINE dtFechaUltPago         DATE;

------------------------VARiABLES DEL LLAMADO AL SP_CONSULTASALDOSGENERAL----------------------------------
DEFINE cNumCredito            CHAR(20);
DEFINE cCodTipCred            CHAR(2);
DEFINE cDescStatusCred        CHAR(60);
DEFINE dtFechaOrigen          DATE;
DEFINE dtFechaProxPago        DATE;
DEFINE dPagoMinimo            DECIMAL(18,2);
DEFINE iPlazo                 INTEGER;
DEFINE iPagosRealizados       INTEGER;
DEFINE dLineaOtorgada         DECIMAL(18,2);
DEFINE dTasaInteres           DECIMAL(9,6);
DEFINE dTasaMoratorios        DECIMAL(9,6);
DEFINE dMontoSBC              DECIMAL(14,2);
DEFINE dCapVig                DECIMAL(18,2);
DEFINE dCapTrans              DECIMAL(18,2);
DEFINE dCapVdoNoExig          DECIMAL(18,2);
DEFINE dSdoActCap             DECIMAL(18,2);
DEFINE dIntVig                DECIMAL(18,2);
DEFINE dIntVdo                DECIMAL(18,2);
DEFINE dIntMoratorio          DECIMAL(18,2);
DEFINE dIntMes                DECIMAL(18,2);
DEFINE dSdoActInt             DECIMAL(18,2);
DEFINE dIvaIntVig             DECIMAL(18,2);
DEFINE dIvaIntVdo             DECIMAL(18,2);
DEFINE dIvaIntMoratorio       DECIMAL(18,2);
DEFINE dIvaIntMes             DECIMAL(18,2);
DEFINE dSdoActIvaInt          DECIMAL(18,2);
DEFINE dComPend               DECIMAL(18,2);
DEFINE dIvaCom                DECIMAL(18,2);
DEFINE dSdoRetenido           DECIMAL(18,2);
DEFINE dtIvaFechaPag          DATE;
DEFINE dIntDevengado          DECIMAL(18,2);
DEFINE dIvaIntDevengado       DECIMAL(18,2);
DEFINE dLineaDisponible       DECIMAL(18,2);
DEFINE dPagosVdos             DECIMAL(18,2);
DEFINE dSdoTotalLiq           DECIMAL(18,2);
DEFINE dCapVdoExig            DECIMAL(18,2);
DEFINE iIdBloqCred            INTEGER;  
DEFINE cDescBloqueoCta        CHAR(60);
DEFINE cCausaBloqCred         CHAR(3);
DEFINE cDescCausaBloqueoCta   CHAR(50);
DEFINE cSitCte                CHAR(1);
DEFINE cCausaCte              INTEGER;
DEFINE cDescSitEspCte         CHAR(75);
DEFINE cSitCred              CHAR(1);
DEFINE cCausaCred            INTEGER;
DEFINE cDescSitEspCred       CHAR(75);
DEFINE cIntentoLlamada		 CHAR(1);
DEFINE cIntentoLlamadaDesc	 CHAR(7); 
DEFINE iExito				 SMALLINT;
DEFINE iFallido				 SMALLINT;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--INICALIZACION DE VARIABLES
LET cCodRet                   = '000000';
LET iSqlErr                   = 0;
LET iIsamErr                  = 0;
LET cErrorInfo                = '';
LET cCodRet2				  = '000000';
LET cMensajeRet2			  = '';
LET cNumCte 	              = '';
LET sLogica					  = 0;
LET cSitEsp			          = '';
LET cEstatus				  = '';
LET cTipoMovto                = 0;
LET cDescMovto				  = '';
LET iCausa			          = 0;
LET cDescripcionEstatus	      = '';
LET cDescripcionRegion	      = '';
LET iTotal			          = 0;
LET iTotalCliente	          = 0;
LET contador		          = 0;
LET cExcepcion		          = '';
LET iResultado		          = 0;
LET cDescripcionResultado	  = '';
LET cCampania		          = 0;
LET cEmpresa		          = '';
LET cNumCredAux               = '';
LET dtFechaAux                = DATE(1); 
LET dMontoUltPag			  = 0;
LET dPagoMinSinVdo            = 0;
LET dtFechaRep				  = DATE(1);
LET dtFechaUltPago            = DATE(1);

---------------------INCIALIZACION DE VARiABLES DEL LLAMADO AL SP_CONSULTASALDOSGENERAL--------------------------

LET cCodTipCred               = '';
LET cNumCredito 	          = '';
LET cDescStatusCred           = '';
LET dtFechaOrigen             = DATE(1);
LET dtFechaProxPago           = DATE(1);
LET dPagoMinimo               = 0;
LET iPlazo                    = 0;
LET iPagosRealizados          = 0;
LET dLineaOtorgada            = 0;
LET dTasaInteres              = 0;
LET dTasaMoratorios           = 0;
LET dMontoSBC                 = 0;
LET dCapVig                   = 0;
LET dCapTrans                 = 0;
LET dCapVdoNoExig             = 0;
LET dSdoActCap                = 0;
LET dIntVig                   = 0;
LET dIntVdo                   = 0;
LET dIntMoratorio             = 0;
LET dIntMes                   = 0;
LET dSdoActInt                = 0;
LET dIvaIntVig                = 0;
LET dIvaIntVdo                = 0;
LET dIvaIntMoratorio          = 0;
LET dIvaIntMes                = 0;
LET dSdoActIvaInt             = 0;
LET dComPend                  = 0;
LET dIvaCom                   = 0;
LET dSdoRetenido              = 0;
LET dtIvaFechaPag             = DATE(1);
LET dIntDevengado             = 0;
LET dIvaIntDevengado          = 0;
LET dLineaDisponible          = 0;
LET dPagosVdos                = 0;
LET dSdoTotalLiq              = 0;
LET dCapVdoExig               = 0;
LET iIdBloqCred				  = 0;
LET cDescBloqueoCta           = '';
LET cCausaBloqCred            = '';
LET cDescCausaBloqueoCta      = '';
LET cSitCte                   = '';
LET cCausaCte                 = 0;
LET cDescSitEspCte            = '';
LET cSitCred                  = '';
LET cCausaCred                = 0;
LET cDescSitEspCred           = '';
LET cIntentoLlamada		 	  = '';
LET cIntentoLlamadaDesc	 	  = ''; 
LET iExito				 	  = 0;
LET iFallido				  = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet = iSqlErr;
	  IF cCodRet = '-206' OR cCodRet = '-214' OR cCodRet = '-958' OR cCodRet = '-310' THEN
		 LET  cCodRet ='105009';
			RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),
			NVL(cDescMovto,''), NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0), NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),
			NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0), NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);

	  END IF;
		IF EXISTS (SELECT tabname FROM systables  WHERE tabname = 'temp_consulta_total') THEN
		   DROP TABLE temp_consulta_total;
		END IF;
			RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
			NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
			NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0) ;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO '/tmp/sp_cat_consulta_totales.out';
 --SET DEBUG FILE TO '/home/informix/macf/sp_cat_consulta_totales.out';
 --TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;

	-- VALIDACION DE LOS PARAMETROS DE ENTRADA
	IF NVL(pEmpresa,'') = '' THEN
	  LET cCodRet = '105001';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;   

  -- Crear una tabla temporal para insertar los datos de la consulta, si ya existe se borra la tabla.
	IF EXISTS (SELECT tabname FROM "informix".systables  WHERE tabname = 'temp_consulta_total') THEN
	    DROP TABLE temp_consulta_total;
	END IF;

   --SE OBTIENE FECHA DE REPORTE  
   	SELECT fecha_hoy
	INTO dtFechaRep
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = pEmpresa;
	
   --Se obtiene fecha de integral como auxiliar 
   --SELECT fecha_hoy 
   --INTO dtFechaAux 
   --FROM bdinteg:"informix".si_fechas;    ---SOLO PRUEBA MACF		

	-- Se valida que la empresa exista
	SELECT empresa
	  INTO cEmpresa
	  FROM bdinteg:"informix".si_empresas
	 WHERE empresa = pEmpresa;

	-- Se valida que la campañia exista
	SELECT tipo_cobranza
	  INTO cCampania
	  FROM bdicobranza:"informix".cb_cat_campania
	 WHERE empresa       = pEmpresa
	   AND tipo_cobranza = pCampania
	   AND modulo_cob=3;	
   
	--Se verifican que los campos  no se encuentren vacíos.   
	IF NVL(cEmpresa,'') = '' THEN
	  LET cCodRet = '105002';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;

	IF NVL(pCampania,'') = '' THEN
	  LET cCodRet = '105003';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;
	
	IF NVL(cCampania,'') = '' THEN
	  LET cCodRet = '105004';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;

	IF NVL(pRegistros,'') = '' THEN
	   LET cCodRet = '105005';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);	 
	END IF;

	IF (pPagosVencMin > pPagosVencMax)  THEN
	   LET cCodRet = '105006';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;

	IF (pMontoMin > pMontoMax)  THEN
	   LET cCodRet = '105007';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;

	IF pAgrupar NOT IN (0,1) THEN
	   LET cCodRet = '105010';
		RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
		NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
		NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
	END IF;

  -- Crear una tabla temporal para insertar los datos de la consulta, si ya existe se borra la tabla.  (lo muevo para arriba a ver si así no envia error) 
	

	-- Se crea la tabla de trabajo
	    CREATE TEMP TABLE temp_consulta_total
	    (
		  Tipo_campania   CHAR(1),
		  Logica   SMALLINT,
		  Situacion   CHAR(1),
		  Causa		SMALLINT,
		  Status_cliente	CHAR(100),
		  tipo_movto	CHAR(100),
		  cod_resultado	SMALLINT,
		  tipo_resultado 	CHAR(100),
		  Excepcion     CHAR(6),
	      Region   CHAR(30),
		  Pago_Min DECIMAL(18,2),
		  Saldo_Total DECIMAL(18,2),
		  MontUltPago  DECIMAL(18,2),
		  CapVdoExig   DECIMAL(18,2),
		  PagoMinSinVdo  DECIMAL(18,2),
		  intento_llamada CHAR(7),
		  exito			SMALLINT,
		  fallido		SMALLINT
		  )WITH NO LOG;
		  
	IF pProducto = '6001' OR pProducto = '6600' THEN	  

	-- Se obtiene la informacion de la consulta de acuerdo a los criterios de busqueda
		FOREACH WITH HOLD
			SELECT dc.tipo_cobranza,dc.tipo_logica,NVL(dc.situacion, ''),NVL(dc.causa, 0),NVL(dc.status_cliente, ''),dc.tipo_movto,NVL(dc.excepcion, ''),
			NVL(reg.nombre_region,''),NVL(dc.pago_minimo, 0),dc.numcte,NVL(dc.codigo_resultado,0),dc.num_credito, dc.intento_llamada
		    INTO cCampania,sLogica,cSitEsp,iCausa,cEstatus,cTipoMovto,cExcepcion,cDescripcionRegion,dPagoMinimo,cNumCte,iResultado,cNumcredito, cIntentoLlamada
			FROM bdicobranza:"informix".cb_cat_directorio_cte dc
			INNER JOIN bdicred:"informix".sd_maecred mae ON ( mae.numcte = dc.numcte)
			-- LEFT JOIN bdinteg:"informix".si_estados est         ON (est.estado = NVL(dc.estado, ''))
			LEFT OUTER JOIN bdinteg:"informix".si_estados est         ON (est.estado = NVL(dc.estado, ''))  -- Modif MACF
			--LEFT JOIN bdinteg:"informix".si_ciudades ciu        ON (ciu.ciudad = NVL(dc.ciudad, '')) AND (est.estado= ciu.estado)
			LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciu        ON (ciu.ciudad = NVL(dc.ciudad, '')) AND (est.estado= ciu.estado)  --Modif MACF
			INNER JOIN bdinteg:"informix".si_catciudades catciu ON (ciu.ciudad_coppel = catciu.numerociudad  --Tmbn talvez se tenga q modificar
																AND catciu.numero_region = CASE WHEN pRegion = 0 THEN catciu.numero_region ELSE pRegion END)
			--LEFT JOIN bdinteg:"informix".si_regiones reg ON (reg.numero_region= catciu.numero_region)
			LEFT OUTER JOIN bdinteg:"informix".si_regiones reg ON (reg.numero_region= catciu.numero_region)  --Modif MACF
			WHERE dc.numcte          > cNumCredAux
			AND dc.tipo_cobranza   = pCampania
			AND dc.fecha_insert    > dtFechaAux	
			AND dc.empresa         = pEmpresa
			AND mae.num_producto = pProducto
			AND NVL(dc.status_cliente, '')  = CASE WHEN pStatus = '' THEN  NVL(dc.status_cliente, '') ELSE pStatus END
			AND NVL(dc.tipo_movto, 0)      = CASE WHEN pTipoMov = 0 THEN  NVL(dc.tipo_movto, 0) ELSE pTipoMov END
			AND (NVL(dc.estado, '')         = CASE WHEN  pEstado        = ''  THEN  NVL(dc.estado, '')           ELSE  pEstado        END)
			AND (NVL(dc.ciudad, '')         = CASE WHEN  pNumCiudad     = ''  THEN  NVL(dc.ciudad, '')           ELSE  pNumCiudad     END)
			AND (NVL(dc.situacion, '')      = CASE WHEN  pSitEsp        = ''  THEN  NVL(dc.situacion, '')        ELSE  pSitEsp        END)
			AND (NVL(dc.causa, 0)          = CASE WHEN  pCausa         = 0   THEN  NVL(dc.causa, 0)            ELSE  pCausa         END)
			AND (NVL(dc.excepcion, '')      = CASE WHEN  pExepcion      = ''  THEN  NVL(dc.excepcion, '')        ELSE  pExepcion      END)
			AND (NVL(dc.pago_venc, 0)     >= CASE WHEN  pPagosVencMin  = 0   THEN  NVL(dc.pago_venc, 0)        ELSE  pPagosVencMin  END
			AND  NVL(dc.pago_venc, 0)     <= CASE WHEN  pPagosVencMax  = 0   THEN  NVL(dc.pago_venc, 0)        ELSE  pPagosVencMax  END)
			AND (NVL(dc.pago_minimo, 0)   >= CASE WHEN  pMontoMin      = 0   THEN  NVL(dc.pago_minimo, 0)      ELSE  pMontoMin      END
			AND  NVL(dc.pago_minimo, 0)   <= CASE WHEN  pMontoMax      = 0   THEN  NVL(dc.pago_minimo, 0)      ELSE  pMontoMax      END)
			AND  (NVL(dc.codigo_resultado, 0)   = CASE WHEN  pTipoResul      = 0   THEN  NVL(dc.codigo_resultado, 0)      ELSE  pTipoResul      END)
			AND NVL(dc.tipo_logica,0)	   = CASE WHEN  pLogica        = 0   THEN  NVL(dc.tipo_logica,0)      ELSE  pLogica 		END

				IF pSaldos = 1 THEN
				    -- Se realiza la busqueda de información de los saldos haciendo el llamado al procedimiento.
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa, cNumcredito)
					INTO cCodRet2, cMensajeRet2, cNumCredito, cCodTipCred, dtFechaOrigen, dtFechaProxPago,  dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados,
							dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, 
							dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes, dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio,
							dIvaIntMes, dSdoActIvaInt, dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, 
							dLineaDisponible,dPagosVdos, cDescStatusCred, iIdBloqCred, cDescBloqueoCta, cCausaBloqCred, cDescCausaBloqueoCta,
							cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred;
							
					IF cCodRet2 <> 0 THEN
						LET cCodRet = '000001';
							RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
							NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
							NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
						continue foreach;
					END IF;
					-- Se calcula el pago minimo  sin vencido		
					LET dPagoMinSinVdo = dPagoMinimo - (dIntVdo+ dIntMoratorio+ dIvaIntVdo +dIvaIntMoratorio);
					
					--Se obtiene el Monto del ultimo pago a según como sea la fecha de ultimo pago
					IF dtFechaUltPago= dtFechaRep THEN 
						SELECT {+INDEX bdicred:"informix".sd_movdia mov4)} NVL(SUM(monto),0)
						INTO dMontoUltPag
						FROM bdicred:"informix".sd_movdia
						WHERE empresa     = pEmpresa
						AND fecha_mov   = dtFechaUltPago
						AND num_credito = cNumCredito
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
						AND codigo_ref =1
						AND reversado = "N";
					ELSE 
						SELECT {+INDEX bdicred:"informix".sd_movhis inx_movhis)} NVL(SUM(monto),0)
						INTO dMontoUltPag
						FROM bdicred:"informix".sd_movhis
						WHERE empresa     = pEmpresa
						AND fecha_mov   = dtFechaUltPago
						AND num_credito = cNumCredito
						AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanual)
						AND codigo_ref =1
						AND reversado = "N";
					END IF;

				END IF;		
				--Obtener la descripcion del tipo de resultado
					SELECT  descripcion
					INTO cDescripcionResultado
					FROM bdicobranza:"informix".cb_cat_tipo_resultado
					WHERE codigo_resultado =NVL(iResultado,0);
				--obtener descripcion del tipo de movimiento
				   	SELECT descripcion
					INTO cDescMovto
					FROM Bdicobranza:"informix".cb_param_campania
					WHERE empresa= pEmpresa
					AND tipo_campania = 1
					AND grupo_parametro = 'TIPOMOVTO'
					AND num_parametro=cTipoMovto;

				-- Obtener la descripcion del estatus del cliente
					SELECT descripcion
					INTO cDescripcionEstatus
					FROM bdicobranza:"informix".cb_param_campania
					WHERE empresa          = pEmpresa
					AND tipo_campania    = 1
					AND grupo_parametro  = 'STATUSCTE'
					AND valor_alfabetico = cEstatus;
					
					IF cIntentoLlamada = 'E' THEN
						LET cIntentoLlamadaDesc = 'Exitosa';
						LET iExito= 1;
						LET iFallido= 0;
					ELSE
						LET cIntentoLlamadaDesc = 'Fallida';
						LET iExito= 0;
						LET iFallido= 1;
					END IF;					

					INSERT INTO bdicobranza:"informix".temp_consulta_total(Tipo_campania,Logica,Situacion,Causa,Status_cliente,tipo_movto, cod_resultado, tipo_resultado,Excepcion,
					Region,Pago_Min,Saldo_Total,MontUltPago,CapVdoExig,PagoMinSinVdo, intento_llamada, exito, fallido)
					VALUES(cCampania,sLogica,cSitEsp,iCausa,cDescripcionEstatus,cDescMovto,iResultado, cDescripcionResultado,cExcepcion,cDescripcionRegion,dPagoMinimo,dSdoTotalLiq,
					dMontoUltPag,dCapVdoExig, dPagoMinSinVdo, cIntentoLlamadaDesc, iExito, iFallido);

		END FOREACH;
	ELSE
		-- Se obtiene la informacion de la consulta de acuerdo a los criterios de busqueda
		FOREACH WITH HOLD
			SELECT dc.tipo_cobranza,dc.tipo_logica,NVL(dc.situacion, ''),NVL(dc.causa, 0),NVL(dc.status_cliente, ''),dc.tipo_movto,NVL(dc.excepcion, ''),
			NVL(reg.nombre_region,''),NVL(dc.pago_minimo, 0),dc.numcte,NVL(dc.codigo_resultado,0),dc.num_credito, dc.intento_llamada
		    INTO cCampania,sLogica,cSitEsp,iCausa,cEstatus,cTipoMovto,cExcepcion,cDescripcionRegion,dPagoMinimo,cNumCte,iResultado,cNumcredito, cIntentoLlamada
			FROM bdicobranza:"informix".cb_cat_directorio_cte dc
			INNER JOIN bdicred:"informix".sd_maecredcrd mae ON ( mae.numcte = dc.numcte)
			--LEFT JOIN bdinteg:"informix".si_estados est         ON (est.estado = NVL(dc.estado, ''))
			LEFT OUTER JOIN bdinteg:"informix".si_estados est         ON (est.estado = NVL(dc.estado, ''))  -- Modif MACF
			--LEFT JOIN bdinteg:"informix".si_ciudades ciu        ON (ciu.ciudad = NVL(dc.ciudad, '')) AND (est.estado= ciu.estado)
			LEFT OUTER JOIN bdinteg:"informix".si_ciudades ciu        ON (ciu.ciudad = NVL(dc.ciudad, '')) AND (est.estado= ciu.estado)  --Modif MACF
			INNER JOIN bdinteg:"informix".si_catciudades catciu ON (ciu.ciudad_coppel = catciu.numerociudad   --Tmbn talvez se tenga q modificar
																AND catciu.numero_region = CASE WHEN pRegion = 0 THEN catciu.numero_region ELSE pRegion END)
			--LEFT JOIN bdinteg:"informix".si_regiones reg ON (reg.numero_region= catciu.numero_region)
			LEFT OUTER JOIN bdinteg:"informix".si_regiones reg ON (reg.numero_region= catciu.numero_region)  --Modif MACF
			WHERE dc.numcte          > cNumCredAux
			AND dc.tipo_cobranza   = pCampania
			AND dc.fecha_insert    > dtFechaAux	
			AND dc.empresa         = pEmpresa
			AND mae.num_producto = pProducto
			AND NVL(dc.status_cliente, '')  = CASE WHEN pStatus = '' THEN  NVL(dc.status_cliente, '') ELSE pStatus END
			AND NVL(dc.tipo_movto, 0)      = CASE WHEN pTipoMov = 0 THEN  NVL(dc.tipo_movto, 0) ELSE pTipoMov END
			AND (NVL(dc.estado, '')         = CASE WHEN  pEstado        = ''  THEN  NVL(dc.estado, '')           ELSE  pEstado        END)
			AND (NVL(dc.ciudad, '')         = CASE WHEN  pNumCiudad     = ''  THEN  NVL(dc.ciudad, '')           ELSE  pNumCiudad     END)
			AND (NVL(dc.situacion, '')      = CASE WHEN  pSitEsp        = ''  THEN  NVL(dc.situacion, '')        ELSE  pSitEsp        END)
			AND (NVL(dc.causa, 0)          = CASE WHEN  pCausa         = 0   THEN  NVL(dc.causa, 0)            ELSE  pCausa         END)
			AND (NVL(dc.excepcion, '')      = CASE WHEN  pExepcion      = ''  THEN  NVL(dc.excepcion, '')        ELSE  pExepcion      END)
			AND (NVL(dc.pago_venc, 0)     >= CASE WHEN  pPagosVencMin  = 0   THEN  NVL(dc.pago_venc, 0)        ELSE  pPagosVencMin  END
			AND  NVL(dc.pago_venc, 0)     <= CASE WHEN  pPagosVencMax  = 0   THEN  NVL(dc.pago_venc, 0)        ELSE  pPagosVencMax  END)
			AND (NVL(dc.pago_minimo, 0)   >= CASE WHEN  pMontoMin      = 0   THEN  NVL(dc.pago_minimo, 0)      ELSE  pMontoMin      END
			AND  NVL(dc.pago_minimo, 0)   <= CASE WHEN  pMontoMax      = 0   THEN  NVL(dc.pago_minimo, 0)      ELSE  pMontoMax      END)
			AND  (NVL(dc.codigo_resultado, 0)   = CASE WHEN  pTipoResul      = 0   THEN  NVL(dc.codigo_resultado, 0)      ELSE  pTipoResul      END)
			AND NVL(dc.tipo_logica,0)	   = CASE WHEN  pLogica        = 0   THEN  NVL(dc.tipo_logica,0)      ELSE  pLogica 		END

				IF pSaldos = 1 THEN
				    -- Se realiza la busqueda de información de los saldos haciendo el llamado al procedimiento.
					EXECUTE PROCEDURE bdicred:"informix".sp_consulta_saldos_general(cEmpresa, cNumcredito)
					INTO cCodRet2, cMensajeRet2, cNumCredito, cCodTipCred, dtFechaOrigen, dtFechaProxPago,  dPagoMinimo, dtFechaUltPago, iPlazo, iPagosRealizados,
							dLineaOtorgada, dTasaInteres, dTasaMoratorios, dMontoSBC, dCapVig, dCapTrans, dCapVdoExig, dCapVdoNoExig, 
							dSdoActCap, dIntVig, dIntVdo, dIntMoratorio, dIntMes, dSdoActInt, dIvaIntVig, dIvaIntVdo, dIvaIntMoratorio,
							dIvaIntMes, dSdoActIvaInt, dComPend, dIvaCom, dSdoRetenido, dSdoTotalLiq, dIntDevengado,dIvaIntDevengado, 
							dLineaDisponible,dPagosVdos, cDescStatusCred, iIdBloqCred, cDescBloqueoCta, cCausaBloqCred, cDescCausaBloqueoCta,
							cSitCte, cCausaCte, cDescSitEspCte, cSitCred, cCausaCred, cDescSitEspCred;
							
					IF cCodRet2 <> 0 THEN
						LET cCodRet = '000001';
							RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
							NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
							NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
						continue foreach;
					END IF;
					-- Se calcula el pago minimo  sin vencido		
					LET dPagoMinSinVdo = dPagoMinimo - (dIntVdo+ dIntMoratorio+ dIvaIntVdo +dIvaIntMoratorio);
					
					--Se obtiene el Monto del ultimo pago a según como sea la fecha de ultimo pago
					IF dtFechaUltPago= dtFechaRep THEN 
						SELECT {+INDEX bdicred:"informix".sd_movdia mov4)} NVL(SUM(monto),0)
						INTO dMontoUltPag
						FROM bdicred:"informix".sd_movdiacrd
						WHERE empresa     = pEmpresa
						AND fecha_mov   = dtFechaUltPago
						AND num_credito = cNumCredito
						AND codigo_fun IN (SELECT cod_fun FROM bdicred:"informix".sd_conceptospagomanual)
						AND codigo_ref =1
						AND reversado = "N";
					ELSE 
						SELECT {+INDEX bdicred:"informix".sd_movhis inx_movhis)} NVL(SUM(monto),0)
						INTO dMontoUltPag
						FROM bdicred:"informix".sd_movhiscrd
						WHERE empresa     = pEmpresa
						AND fecha_mov   = dtFechaUltPago
						AND num_credito = cNumCredito
						AND codigo_fun IN (select cod_fun from bdicred:"informix".sd_conceptospagomanual)
						AND codigo_ref =1
						AND reversado = "N";
					END IF;

				END IF;		
				--Obtener la descripcion del tipo de resultado
					SELECT  descripcion
					INTO cDescripcionResultado
					FROM bdicobranza:"informix".cb_cat_tipo_resultado
					WHERE codigo_resultado =NVL(iResultado,0);
				--obtener descripcion del tipo de movimiento
				   	SELECT descripcion
					INTO cDescMovto
					FROM Bdicobranza:"informix".cb_param_campania
					WHERE empresa= pEmpresa
					AND tipo_campania = 1
					AND grupo_parametro = 'TIPOMOVTO'
					AND num_parametro=cTipoMovto;

				-- Obtener la descripcion del estatus del cliente
					SELECT descripcion
					INTO cDescripcionEstatus
					FROM bdicobranza:"informix".cb_param_campania
					WHERE empresa          = pEmpresa
					AND tipo_campania    = 1
					AND grupo_parametro  = 'STATUSCTE'
					AND valor_alfabetico = cEstatus;					
					
					IF cIntentoLlamada = 'E' THEN
						LET cIntentoLlamadaDesc = 'Exitosa';
						LET iExito= 1;
						LET iFallido= 0;
					ELSE
						LET cIntentoLlamadaDesc = 'Fallida';
						LET iExito= 0;
						LET iFallido= 1;
					END IF;

					INSERT INTO bdicobranza:"informix".temp_consulta_total(Tipo_campania,Logica,Situacion,Causa,Status_cliente,tipo_movto, cod_resultado, tipo_resultado,Excepcion,
					Region,Pago_Min,Saldo_Total,MontUltPago,CapVdoExig,PagoMinSinVdo, intento_llamada, exito, fallido)
					VALUES(cCampania,sLogica,cSitEsp,iCausa,cDescripcionEstatus,cDescMovto, iResultado, cDescripcionResultado,cExcepcion,cDescripcionRegion,dPagoMinimo,dSdoTotalLiq,
					dMontoUltPag,dCapVdoExig, dPagoMinSinVdo, cIntentoLlamadaDesc, iExito, iFallido);

		END FOREACH;
		
	END IF;	
	
	  --Se obtiene el total del clientes.
	  SELECT COUNT(Status_cliente)
      INTO iTotal
      FROM bdicobranza:"informix".temp_consulta_total;

		IF iTotal = 0 THEN
			LET cCodRet = '105008';
			DROP TABLE temp_consulta_total;
					RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
					NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
					NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0);
		END IF;

	--consultar la tabla temporal para obtener el total de clientes y una muestra
	LET cCodRet = '000000';

		IF pAgrupar=  0 THEN
				FOREACH WITH HOLD	
						--Consulta de información sin agrupar por region
						SELECT Tipo_campania,Logica,Situacion,Causa,Status_cliente,tipo_movto,tipo_resultado,
						Excepcion,Region,SUM(Pago_Min), COUNT(Status_cliente), SUM(Saldo_Total),
						SUM(MontUltPago),SUM(CapVdoExig),SUM(PagoMinSinVdo), intento_llamada, cod_resultado,
						SUM(exito) , SUM(fallido)
                        INTO cCampania,sLogica,cSitEsp,iCausa,cDescripcionEstatus,cDescMovto,cDescripcionResultado,
						cExcepcion,cDescripcionRegion,dPagoMinimo,iTotalCliente, dSdoTotalLiq,dMontoUltPag,
						dCapVdoExig, dPagoMinSinVdo, cIntentoLlamadaDesc, iResultado, iExito, iFallido
                        FROM bdicobranza:"informix".temp_consulta_total
                        GROUP BY Tipo_campania,Logica,Situacion,Causa,Status_cliente,tipo_movto,tipo_resultado,
						cod_resultado, intento_llamada, Excepcion,Region
                        ORDER BY Status_cliente, region, Logica, Situacion,Causa, cod_resultado

                    LET contador = contador + 1;

                    IF (pRegistros <> 0) AND (contador>pRegistros)THEN
                        EXIT FOREACH;
                    END IF;
					-- Se realizo correctamente la consulta
					RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
					NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
					NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0) WITH RESUME;
                END FOREACH;
		ELSE
                FOREACH WITH HOLD
						--Consulta de información agrupado por region
                       SELECT Tipo_campania,Logica,Status_cliente,Region,SUM(Pago_Min), 
					   COUNT(Status_cliente),SUM(Saldo_Total),SUM(MontUltPago),SUM(CapVdoExig),
					   SUM(PagoMinSinVdo)
                        INTO cCampania,sLogica,cDescripcionEstatus,cDescripcionRegion,dPagoMinimo,iTotalCliente,dSdoTotalLiq,dMontoUltPag,dCapVdoExig,dPagoMinSinVdo						
                        FROM bdicobranza:"informix".temp_consulta_total
                        GROUP BY Tipo_campania,Logica,Status_cliente,Region
                        ORDER BY Region,Status_cliente

                        LET contador = contador + 1;

                        IF (pRegistros <> 0) AND (contador>pRegistros)THEN
                            EXIT FOREACH;
                        END IF;
                        
					-- Se realizo correctamente la consulta
					RETURN NVL(cCodRet,''),NVL(cCampania,''),NVL(sLogica,0),NVL(cSitEsp,''),NVL(iCausa,0),NVL(cDescripcionEstatus,''),NVL(cDescMovto,''),
					NVL(cIntentoLlamadaDesc, ''), NVL(iExito,0), NVL(iFallido,0) ,NVL(cDescripcionResultado,''),NVL(cExcepcion,''),NVL(cDescripcionRegion,''),NVL(dPagoMinimo,0),NVL(dSdoTotalLiq, 0),NVL(dMontoUltPag,0),
					NVL(dCapVdoExig, 0), NVL(dPagoMinSinVdo, 0),NVL(iTotalCliente,0), NVL(iTotal,0) WITH RESUME;
				END FOREACH;
		END IF;
		DROP TABLE temp_consulta_total;
END
END PROCEDURE
DOCUMENT
'DESCRIPCION	 : Se realiza procedimiento para obtener el total de los clientes, ya sea agrupado por region o no',
				' que se mostrara en la pantalla de desponibilidad de clientes',
'AUTOR			 : Jesús Manuel Aguilar Heredia',
'FECHA			 : 29/SEPTIEMBRE/2010',
'BD    			 : BDICOBRANZA',
'MODIFICACION : Se agrega filtro Tipo de Logica, tambien se agrupan con los filtros para mostrar se, causa, region, estatus, etc ',  
'CAMBIO		 : Se agregan los campos correspondientes a los saldos para anexar al archivo, además se agrega como parametro el campo psaldo.',
'MODIFICÓ		 : Maria Elena Angulo',   
'CAMBIO		 : Se agrega filtro de consulta por producto, se valida producto y se agrega llamada_intento, se agrega agrupacion por codigo resultado e intento llamada ',
'MODIFICÓ		 : Abigail Vasavilbazo Cañedo',     
'VERSION		 : 20111206.1040';

CREATE PROCEDURE "informix".sp_cilocalertacte(pNumCte CHAR(20) ,pSucursal CHAR(4), pOrigen INTEGER,pTpoDir CHAR(1))
RETURNING CHAR(5) AS CODIGORET1,CHAR(5) AS CODIGOret2;
				
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret1                        CHAR(5);
DEFINE cCod_ret2                        CHAR(5);
DEFINE cSucursal						CHAR(4);
DEFINE iContador						INTEGER;
DEFINE vCont							INTEGER;
DEFINE iNumalerta						INTEGER;
DEFINE dtFecha							DATE;
DEFINE dtFechaActual					DATE;
DEFINE cSituacionEsp					CHAR(1);
DEFINE iCausa							SMALLINT;
DEFINE cAaccionOrigen					CHAR(4);
DEFINE cNumcte							CHAR(20);
DEFINE cMotivoDesmarcaje				CHAR(100);


-----------------------------------------------------
LET cCod_ret1  = '00000';
LET cCod_ret2  = '00000';
LET sql_err   = 0;
LET iContador = 0;
LET vCont = 0;
LET iNumalerta = 0;
LET cSituacionEsp='';
LET iCausa = 0;
LET cAaccionOrigen = '';
LET cMotivoDesmarcaje = '';


  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret1 = sql_err;
		RETURN cCod_ret1,cCod_ret2;					
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/jesusm/sp_CiLocAlertaCte.out";
	--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
	
	IF pNumCte = ' ' OR pNumCte IS NULL THEN
		--numero de cliente invalido
		LET cCod_ret2 = '00001';
		RETURN cCod_ret1,cCod_ret2;	
	END IF
	
	SELECT numcte
	INTO cNumcte
    FROM bdinteg:si_cliente  
	WHERE numcte= pNumCte;
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
	--indica  que el numero de cliente no existe
		LET cCod_ret2 = '00002';
		RETURN cCod_ret1,cCod_ret2;	
	END IF;
	
	IF pSucursal = '' OR pSucursal IS NULL THEN
		--numero de sucursal invalido
		LET cCod_ret2 = '00003';
		RETURN cCod_ret1,cCod_ret2;	
	END IF
	
	SELECT sucursal
	INTO cSucursal
    FROM bdinteg:si_sucursales  
	WHERE sucursal= pSucursal;
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
	--indica  que el numero de sucursal no existe
		LET cCod_ret2 = '00004';
		RETURN cCod_ret1,cCod_ret2;	
	END IF;
	--Se realiza cambio para contemplar las nuevas definiciones del cliente sobre el origen.
	--solo se aceptan como datos de entrada para el dato origen  1 = CC, 2 = OFI,  3 = CAT, 4=WEB, 5=SIF
	IF pOrigen=1 THEN
		LET cAaccionOrigen='CC';
	ELIF pOrigen=2 THEN
		LET cAaccionOrigen='OFI';
	ELIF pOrigen=3 THEN
		LET cAaccionOrigen='CAT';
	ELIF pOrigen=4 THEN
		LET cAaccionOrigen='WEB';
	ELIF pOrigen=5 THEN
		LET cAaccionOrigen='SIF';
	ELSE
	--origen invalido 
		LET cCod_ret2 = '00005';
		RETURN cCod_ret1,cCod_ret2;		
	END IF;
	
	SELECT fecha_hoy 
      INTO dtFechaActual
      FROM bdicred:sd_fechas;
	
	LET vCont = 0; 

	SELECT situacion, causa, fchalta::DATE,NVL(motivo_desmarcaje,'')
	INTO cSituacionEsp, iCausa,dtFecha,cMotivoDesmarcaje
	FROM bdisitesp:se_ctessitespcte 
	WHERE  numcte=pNumcte
	AND situacion ='L'
	AND idmovto = ( SELECT MAX(idmovto )
                                FROM bdisitesp:se_ctessitespcte 
                                WHERE  numcte=pNumcte
                                 AND situacion ='L' );
	
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
	--indica  que el numero de cliente no tiene una situacion especial L activa
		LET cCod_ret2 = '00000';
		RETURN cCod_ret1,cCod_ret2;	
	END IF;
	
	IF TRIM(cMotivoDesmarcaje) <> "" THEN
		--no es necesario enviar la alerta
		LET cCod_ret2 = '00000';
		RETURN cCod_ret1,cCod_ret2;	
	END IF
	
	SELECT NVL(numalerta,0)
	INTO iNumalerta
	FROM bdicobranza:cb_alerta_succliente 
	WHERE  numcte=pNumcte
	AND fecha BETWEEN dtFecha AND dtFechaActual
	AND tipo_domicilio=pTpoDir
	AND numalerta = (SELECT MAX(NVL(numalerta,0))
                         FROM bdicobranza:cb_alerta_succliente
						 WHERE  numcte=pNumcte
						 AND tipo_domicilio=pTpoDir
					     AND fecha BETWEEN dtFecha AND dtFechaActual)  ;
	LET vCont = dbinfo("sqlca.sqlerrd2");
	IF vCont = 0 THEN
		LET iNumalerta=0;
	END IF;
		SELECT count(m.numcte)
		INTO iContador
		FROM bdicobranza:cb_marcacliente  m, bdinteg:si_direcciones_loc d 
		WHERE m.numcte =  pNumcte
		AND m.tipo_marca = 'LV'
		AND m.estatus IN ('AT','SA')
		AND m.tipo_domicilio=pTpoDir
		AND m.fecha_insert BETWEEN dtFecha AND dtFechaActual
		AND d.numcte= m.numcte 
		AND d.tipo_dir=m.tipo_domicilio
		AND d.dom_verificado='S' 
		AND d.secuencia = (SELECT MAX(dir_aux.secuencia) 
						 FROM bdinteg:si_direcciones_loc dir_aux
						 WHERE dir_aux.numcte= m.numcte 
						 AND dir_aux.tipo_dir=pTpoDir
						 AND dir_aux.fecha_insert BETWEEN dtFecha AND dtFechaActual);
		
		IF iContador > 0 THEN
			--retorno indica que no es necesario enviar la alarma
			LET cCod_ret2  = '00000';
			RETURN cCod_ret1,cCod_ret2;	
		END IF;	
		
		INSERT INTO  bdicobranza:cb_alerta_succliente (numalerta, fecha, numcte, hora, tipo_alerta, estatus, sucursal, accion_origen, situacion, causa,origen,tipo_domicilio) 
		VALUES (iNumalerta+1, dtFechaActual, pNumcte, CURRENT HOUR TO FRACTION ,'CI', 'SA  ', pSucursal, cAaccionOrigen, cSituacionEsp,iCausa,pOrigen,pTpoDir);
			--insertar en la tabla de alertas
		LET cCod_ret2  = '00006';	
		RETURN cCod_ret1,cCod_ret2;		
	
END;
END PROCEDURE
DOCUMENT
'AUTOR: JESUS MANUEL AGUILAR HEREDIA',
'DESCRIPCION: VALIDA SI EL CLIENTE ESTA EN SITUACION ESPECIAL L, Y NO TENGA UNA ALERTA REGISTRADA, ENVIA UN CODIGO PARA INDICAR QUE NECESITA ENVIARSE UNA ALERTA',
'CASO QUE SI EXISTA UNA ALERTA, VALIDA SI YA REALIZO EL CAMBIO DE DOMICILIO, PARA NO ENVIAR LA ALERTA.',
'BD: BDICOBRANZA',
'VERSION: 20100831.1127',
'MODIFICÓ: MARIA ELENA ANGULO AISPURO',
'MODIFICACIÓN: SE REALIZA CAMBIO PARA CONTEMPLAR LAS NUEVAS DEFINICIONES DEL CLIENTE CON RESPECTO AL ORIGEN DEL MARCAJE',
'VERSION: 20110218.1612';

CREATE PROCEDURE "informix".sp_cilocobteninfociloc(pcNumCte CHAR(20),pcTipoDir CHAR(1))
		RETURNING   
					CHAR(5) AS Codigo,	--codret
					CHAR(26) AS ApellPaterno,--Apellido Paterno
					CHAR(26) AS ApellMaterno,--Apellido Materno
					CHAR(26) AS Nombre1, --Primer nombre de cliente
					CHAR(26) AS Nombre2, --Segundo nombre de cliente
					DATE AS FechaNac,--Fecha de nacimiento
					VARCHAR(60) AS Calle,--Calle
					CHAR(10) AS Numero,--Numero
					VARCHAR(60) AS NomColonia,--Colonia
					VARCHAR(60) AS NomCiudad,--Ciudad
					CHAR(27) AS NomMunicipio,--Municipio
					CHAR(5) AS CodPostal, --Codigo Postal
					CHAR(30) as Estado ; -- Estado
					
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE cApellPaterno	CHAR(26); 
	DEFINE cApellMaterno	CHAR(26);
	DEFINE cNombre1			CHAR(26);
	DEFINE cNombre2			CHAR(26);
	DEFINE dFecha_nac		DATE;
	DEFINE cNumCalle 		CHAR(10);
	DEFINE cNomCalle		VARCHAR(60);
	DEFINE cNumColonia 		CHAR(60);
	DEFINE cNomColonia		VARCHAR(60);
	DEFINE cNumCiudad		CHAR(3);
	DEFINE cNumEstado		CHAR(3);
	DEFINE cNomCiudad		VARCHAR(60);
	DEFINE cNomMunicipio    CHAR(27);
	DEFINE cCodPostal		CHAR(5);
	DEFINE cEstado			CHAR(30);
	DEFINE iCont			INTEGER;
	DEFINE cNumextCalle 		CHAR(10);
	-- Se inicializan las variables.
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cApellPaterno=''; 
	LET cApellMaterno='';
	LET cNombre1='';
	LET cNombre2='';
	LET dFecha_nac = date(1);
	LET cNumCalle ='';
	LET cNomCalle ='';
	LET cNumColonia ='';
	LET cNomColonia='';
	LET cNumCiudad ='';
	LET cNumEstado ='';
	LET cNomCiudad ='';
	LET cNomMunicipio ='';
	LET cCodPostal	= '';
	LET cEstado ='';
	LET iCont=0;
	LET cNumextCalle = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocObtenInfoCiLoc.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cApellPaterno,cApellMaterno,cNombre1,cNombre2,dFecha_nac,cNomCalle,cNumCalle,cNomColonia,cNomCiudad,cNomMunicipio,cCodPostal,cEstado;
		END EXCEPTION;		
		
	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
	-->>>Tipos de domicilio
	--1--Domicilio particular
	--2--Domicilio Trabajo
	--3--Domicilio Referencia
		-- SE CHECA SI EL CLIENTE EXISTE
	IF NOT EXISTS (SELECT SIC.numcte FROM bdinteg:si_cliente AS SIC
					INNER JOIN bdinteg:si_ctepf AS SCT ON (SIC.numcte=SCT.numcte)
					WHERE SIC.numcte=pcNumCte) THEN
		LET cCodret='00001'; --'EL CLIENTE NO ESTA DADO DE ALTA';
		RETURN cCodRet,NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cNombre1,''),NVL(cNombre2,''),dFecha_nac,NVL(cNomCalle,''),NVL(cNumCalle,''),NVL(cNomColonia,''),NVL(cNomCiudad,''),NVL(cNomMunicipio,''),NVL(cCodPostal,''), NVL(cEstado,'');	
	END IF;
	
		IF NOT EXISTS(SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE numcte=pcNumCte and situacion='L') THEN 
			LET cCodret='00002'; --'El cliente no tiene situacion especial L por lo tanto no se le puede realizar ninguna marca';
		END IF;
				--Checa si existe cliente en la Si direcciones_loc
					IF EXISTS(SELECT numcte FROM bdinteg:si_direcciones_loc WHERE numcte=pcNumCte AND  tipo_dir=pcTipoDir) THEN 
							--Se obtienen los datos del cliente.
							SELECT NVL(SIC.apell_paterno,''),NVL(SIC.apell_materno,''),NVL(SIC.nombre1,''),NVL(SIC.nombre2,''),NVL(SCT.fecha_nac,''),NVL(SID.numerocalle,''),NVL(SID.numerocolonia,''),NVL(SID.ciudad,''),NVL(SID.estado,''),NVL(SID.cod_postal,''),NVL(SID.numeroextcalle,'')
							INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2,dFecha_nac,cNumCalle,cNumColonia,cNumCiudad,cNumEstado,cCodPostal,cNumextCalle
							FROM bdinteg:si_direcciones_loc AS SID 
							INNER JOIN bdinteg:si_cliente AS SIC ON SID.numcte=SIC.numcte
							INNER JOIN bdinteg:si_ctepf AS SCT ON SIC.numcte=SCT.numcte
							WHERE SID.numcte=pcNumCte AND SID.tipo_dir=pcTipoDir AND SID.secuencia=(SELECT MAX(secuencia)
																									 FROM bdinteg:si_direcciones_loc 
																									 WHERE tipo_dir=pcTipoDir AND numcte=pcNumCte);
																									 						
					ELIF EXISTS(SELECT numcte FROM bdinteg:si_direcciones_actual WHERE numcte=pcNumCte AND  tipo_dir=pcTipoDir) THEN--SI NO EXISTE EN LA si_direcciones_loc SE CONSULTA EN LA si_direcciones
							--Se obtienen los datos del cliente.			
							SELECT NVL(SIC.apell_paterno,''),NVL(SIC.apell_materno,''),NVL(SIC.nombre1,''),NVL(SIC.nombre2,''),SCT.fecha_nac,NVL(SID.numerocalle,''),NVL(SID.numerocolonia,''),NVL(SID.numerociudad,''),NVL(SID.estado,''),NVL(SID.cod_postal,''),NVL(SID.numeroextcalle,'') 
							INTO cApellPaterno,cApellMaterno,cNombre1,cNombre2,dFecha_nac,cNumCalle,cNumColonia,cNumCiudad,cNumEstado,cCodPostal,cNumextCalle 
							FROM bdinteg:si_direcciones_actual AS SID 
							INNER JOIN bdinteg:si_cliente AS SIC ON SID.numcte=SIC.numcte
							INNER JOIN bdinteg:si_ctepf AS SCT ON SIC.numcte=SCT.numcte
							WHERE SID.numcte=pcNumCte AND SID.tipo_dir=pcTipoDir;
				
					ELIF iCont == 0 THEN 
							LET cCodret='00003'; --'EL CLIENTE AUN NO TIENE DADA DE ALTA UNA DIRECCION ';
					END IF;
						--Se obtiene el nombre de la ciudad.																			 																		 
						SELECT NVL(nombre,'')
						INTO cNomCiudad
						FROM bdinteg:si_ciudades 
						WHERE ciudad_coppel=cNumCiudad AND estado=cNumEstado;
						
						--- Se obtienen el nombre de la colonia y nombre del municipio
						SELECT NVL(nombrezona,''),NVL(municipiozona,'')
						INTO cNomColonia,cNomMunicipio
						FROM bdinteg:si_catzonas 
						WHERE numerociudad = cNumCiudad 
						AND numerocolonia = cNumColonia;
				
						--Se obtiene el nombre de la calle
						SELECT NVL(nombrecalle,'')
						INTO cNomCalle
						FROM bdinteg:si_catcalles 
						WHERE numerocalle =cNumCalle;
						
						--Se obtiene el nombre del estado
						Select NVL(nombre,'')
						INTO cEstado 
						FROM bdinteg:si_estados 
						WHERE pais = '001' 
						AND estado = cNumEstado;
	
			RETURN cCodRet,NVL(cApellPaterno,''),NVL(cApellMaterno,''),NVL(cNombre1,''),NVL(cNombre2,''),dFecha_nac,NVL(cNomCalle,''),NVL(cNumextCalle,''),NVL(cNomColonia,''),NVL(cNomCiudad,''),NVL(cNomMunicipio,''),NVL(cCodPostal,''), NVL(cEstado,'') WITH RESUME;
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se devuelve un registro con la información referente al numero de cliente y el tipo de domicilio a consultar por el usuario',
'Se modifica para que regrese el nombre del estado',
'FECHA       : 23 de Agosto de 2010',
'VERSION     : 20100917.1837',
'MODIFICO    : Jesús Antonio Bastidas López',
'DESCRIPCION : Se agrega el campo estado a la consulta y retorno de proceso, se modifica al campo numerocalle y numerocolonia',
'FECHA       : 17/03/2011',
'VERSION     : 20110317.1315',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cilocconsultasituacionesespeciales()
		RETURNING   CHAR(5) as Codigo,	--codret
					CHAR(40) as Situacion; --situacion
					
	DEFINE cCodRet 			CHAR(5);
	DEFINE iCont            INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE cSituacion    CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cSituacion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocConsultaSituacionesEspeciales.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cSituacion = 'Error de Informix';
			RETURN cCodRet,cSituacion;
		END EXCEPTION;		
		
	--Se realiza consulta a la tabla se_catsitesp para obtener las situaciones especiales.	
	
	set isolation to dirty read; -- Lectura de tablas bloqueadas.
	
		FOREACH   
			SELECT {+FULL} distinct(situacion)
			INTO  cSituacion
			FROM bdisitesp:se_catsitesp
			LET icont=icont+1;
            RETURN cCodret,cSituacion WITH RESUME;
		END FOREACH;		
		
        IF icont == 0 THEN 
			LET cCodret='00001'; 
			LET cSituacion='No hay Informacion en la tabla';
            RETURN cCodret,cSituacion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado de las situaciones especiales existentes en la tabla se_catsitesp',
'FECHA       : 13 de Agosto de 2010',
'VERSION     : 20100813.0430',
'BD          : BDICOBRANZA',
'MODIFICACION: Volver a crear SP con usuario informix.',
'AUTOR: Marco A. Campos 2012-02-21';

CREATE PROCEDURE "informix".sp_cat_ivr_gen_arcctesexcluidos(pEmpresa  CHAR(3),
                                                           pFecha_ex DATE)
RETURNING CHAR(6) AS codigo_retorno;


-- 'AUTOR : Abrham Lopez Lopez.', 'FECHA : 22/JUNIO/2010', 'BD    : BDICOBRANZA';
-- 'El SP genera un archivo que extrae información de los clientes excluidos para campaña IVR',
-- Modificado por: MAHR. Abril 2012. Se asigna proceso: 2002, a fin de no repetir numero asignado con otros proceso.

          
DEFINE cCodRet             CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cSql                CHAR(2204);
DEFINE cNombreArchivo1     CHAR(50);
DEFINE cNombreArchivo      CHAR(50);
DEFINE cRuta               CHAR(100);
DEFINE iNumreg             INTEGER;
DEFINE iDatos              INTEGER;
DEFINE cEmpresa            CHAR(3);
DEFINE cNombre             CHAR(100);
DEFINE cdelimitador        CHAR(1);
DEFINE cValor_status       CHAR(20);
DEFINE cHora               CHAR(8);
DEFINE cUsuario            CHAR(8);
DEFINE cSql1               CHAR(100);
DEFINE cSql2               CHAR(2004);
DEFINE cSql3               CHAR(100);
DEFINE dDia                DATE;
DEFINE cFechaGenArchivo    CHAR(8);
DEFINE cCodRetIB           CHAR(6);
DEFINE cMensaje            CHAR(80);
DEFINE cProceso            CHAR(4);


LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cCodRet                = "000000";
LET cRuta                  = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET iNumreg                = 0;
LET iDatos                 = 0;
LET cEmpresa               = "";
LET cNombre                = '';
LET cdelimitador           = '';
LET cSql                   = "";
LET cValor_status          = "";
LET cHora                  = "";
LET dDia                   = DATE(1);
LET cMensajeRet            = 'PROCESO EXITOSO';
LET cProceso               = '2002';
LET cUsuario               = USER;
LET cSql1                  = "";
LET cSql2                  = "";
LET cSql3                  = "";
LET cFechaGenArchivo       = "";
LET cCodRetIB              = "000000";
LET cMensaje               = "";

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        IF iSqlErr != 0 THEN
            LET cCodRet     = iSqlErr;
            LET cMensajeRet = cErrorInfo;
            EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensajeRet,"02")
                     INTO cCodRetIB;
            RETURN cCodRet; 
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    --SET DEBUG FILE TO '/home/syscobra/cat/envios/sp_ctbcpl_gen_arcctesexcluidos.out';
    --TRACE ON;

    -- Inserta bitacora de procesos
    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,"","","01")
             INTO cCodRetIB;
        
    -- Validacion de los datos de entrada
    IF NVL(pEmpresa,"") = "" THEN
        LET cCodRet     = "104007";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen        = 3
            AND codigo_error    = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
    
    SELECT empresa
        INTO cEmpresa 
        FROM bdinteg:si_empresas
        WHERE empresa = pEmpresa;
    
    IF NVL(cEmpresa,"")= "" then
        LET cCodRet = "104002";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    IF NVL(pFecha_ex,"") = "" THEN
        LET cCodRet     = "104008";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
    SELECT valor_alfabetico 
        INTO cRuta
        FROM bdicobranza:cb_param_campania
        WHERE empresa         = pEmpresa
        AND tipo_campania   = '1'
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro   = 3;
        
    IF NVL(cRuta,"")    = "" THEN
        LET cCodRet     = "104005";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                  INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    -- Se obtiene del nombre del archivo
    SELECT valor_alfabetico 
        INTO cNombre
        FROM bdicobranza:cb_param_campania
        WHERE empresa         = pEmpresa
        AND tipo_campania   = '1'
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro   = 28;

    IF NVL(cNombre,"") = "" THEN
        LET cCodRet = "104006";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;


    --Obtener caracter delimitador
    SELECT trim(valor_alfabetico)
        INTO cdelimitador
        FROM bdicobranza:cb_param_campania
        WHERE empresa = pempresa
        AND tipo_campania = 1
        AND grupo_parametro = 'ARCHIVOS'
        AND num_parametro = 25;
    
	IF NVL(cdelimitador,"") = "" THEN
        LET cCodRet     = "104004";
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
     
	LET cNombreArchivo1 = 'prueba.txt';
    LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
   
    FOREACH
        SELECT trim(valor_alfabetico)
	    INTO cValor_status
		FROM bdicobranza:cb_param_campania
		WHERE empresa         = pEmpresa
		AND tipo_campania   = '1'
        AND grupo_parametro = 'STATARCHCE'
        AND valor_alfabetico IN ('EX','IN', 'AC')  -- mahr. solo se contemplan estos status para CAT
     
		SELECT COUNT (numcte)
            INTO iNumreg
			FROM bdicobranza:cb_cat_directorio_cte
			WHERE status_cliente       = cValor_status
			AND fecha_modificacion   = pFecha_ex
		    AND empresa              = pEmpresa
            AND tipo_cobranza        = 'P';

        IF iNumreg = 0 THEN
            CONTINUE FOREACH;
        END IF;

		LET iDatos = iDatos + 1;
			
		--se ejecuta para ponerle el encabezado
		let cSql='';
		let csql = 'echo "cliente'||','||'nombre'||','||'tipoproducto'||','||'telcasa'||','||'telcelular'||','||
				 'fechalimitepago'||','||'fechacorte'||'">'||TRIM(cruta)|| cNombreArchivo;   
		system csql; 

        -- para generar el archivo 
		LET cSql1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM (cNombreArchivo1) || " DELIMITER '" || cdelimitador || "'";
				
		LET cSql2 = " select  a.numcte as cliente , "
				|| " trim (h.apell_paterno) ||' '|| trim (h.apell_materno)||' '|| trim(h.nombre1) ||' '|| trim(h.nombre2) as nombre , "
				|| " f.num_producto as tipoproducto, " 
				|| " nvl(b.telefono,' ') as telcasa, "
				|| " nvl((case when d.numero_carrier = 1 then 6 || d.telefono  when d.numero_carrier = 2 then 7 || d.telefono  else 7 || d.telefono end),' ') as telcelular ,1, "
				|| " (e.prox_fecha_pago) as fechalimitepago, "
				|| " (day(e.prox_fecha_pago+4 units day))||'/'||lpad(month(e.prox_fecha_pago),2,'0')||'/'||(year(e.prox_fecha_pago-1 units month))fechacorte "
				|| " from bdicobranza:cb_cat_directorio_cte  a "
				|| " join bdicred:sd_maecred f  on (a.empresa = f.empresa and a.numcte = f.numcte ) "
				|| " join bdinteg:si_cliente h on (h.empresa = a.empresa and h.numcte = a.numcte) "    
				|| " left outer join bdicobranza:cb_telefonos b on ( b.empresa = a.empresa and b.numcte = a.numcte and b.tipo_telefono = 1) "
				|| " left outer join bdicobranza:cb_telefonos d on ( d.empresa = a.empresa and d.numcte = a.numcte and d.tipo_telefono = 2) "
				|| " join bdicred:sd_maecredanexo e   on (e.empresa= a.empresa and e.num_credito = a.num_credito) "
				|| " where a.empresa = '001' "
				|| " and a.tipo_cobranza = 'P' "
                || " and a.status_cliente = '" || trim(cValor_status) || "'"   --  IN ('EX','IN') " -- MAHR
                || " and a.fecha_modificacion  = '" || pFecha_ex || "'"
				|| " and ((nvl(b.telefono,'')<> '') or (nvl(d.telefono,'') <> '')) ";
						
        LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
            
        LET cSql1 = TRIM(cSql1);
        LET cSql3 = TRIM(cSql3);
            
        LET cSql = cSql1 || cSql2 || cSql3;
			
		SYSTEM cSQL;
		--Permiso para la creacion de archivo.
		LET cSQL = '' ;
		LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql' ;
		LET cSQL = '' ;
		LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
		SYSTEM cSQL;
			
		LET cSql = "sed 's/"||cdelimitador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
        SYSTEM cSql;

		--Borra el archivo de control.
		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_GenArchivoTelefonos.sql';
		SYSTEM cSQL;

		LET cSQL = '' ;
		LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
		SYSTEM cSQL;
		
    END FOREACH;

    -- Por si el archivo no  se genera 
    IF iDatos = 0 THEN
        LET cCodRet = '104009';
        SELECT descripcion
            INTO cMensaje
            FROM bdicobranza:"informix".cb_errores
            WHERE origen       = 3
            AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,cProceso,cCodRet,cMensajeRet,"03")
             INTO cCodRetIB;

    RETURN cCodRet;

END
END PROCEDURE;