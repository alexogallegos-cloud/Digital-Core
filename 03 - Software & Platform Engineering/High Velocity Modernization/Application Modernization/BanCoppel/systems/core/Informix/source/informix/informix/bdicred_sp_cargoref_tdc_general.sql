CREATE PROCEDURE "informix".sp_cargoref_tdc_general(pEmpresa  CHAR(3),
												 pSucursal CHAR(4),
												 pUsuario  CHAR(8),
												 pTarjeta  CHAR(20),
												 pMonto    DECIMAL(14,2),
												 pTransuc  CHAR(4),
												 pFolioSuc  CHAR(16),
												 pReferencia  CHAR(40))
RETURNING CHAR(5)     AS codigo_retorno,
          CHAR(4)     AS terminacion_tarjeta,
          CHAR(60)    AS nombre_cte,
          MONEY(16,2) AS monto_cargo,
		  MONEY(16,2) AS monto_comision,
		  MONEY(16,2) AS iva_comision;
		  
DEFINE nrows              INTEGER;
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE vCodRet            CHAR(5);	  

DEFINE cod_ret            CHAR(5);
DEFINE v_codparam	   	  CHAR(4);
DEFINE v_fecha            DATE;
DEFINE Saldo              MONEY(14,2);
DEFINE MtoCgo		  	  MONEY(14,2);
DEFINE cod_ret2           CHAR(5);
DEFINE SaldoCom           MONEY(14,2);
DEFINE MtoCom		   	  MONEY(12,2);
DEFINE v_num_credito      CHAR(20);
DEFINE v_divisa           CHAR(2);
DEFINE vsucorig           CHAR(4);
DEFINE vNumCte            CHAR(20);
DEFINE vNombreCte         CHAR(60);
DEFINE vTerminacion       CHAR(4);
DEFINE vIvaCom            MONEY(16,2);

LET nrows                 = 0;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET vCodRet               = '000';

LET cod_ret               = "000";
LET v_codparam	   	      = "";
LET v_fecha               = DATE(1);
LET Saldo                 = 0;
LET MtoCgo		  	      = 0;
LET cod_ret2              = "";
LET SaldoCom              = 0;
LET MtoCom		   	      = 0;
LET v_num_credito         = "";
LET v_divisa              = "";
LET vsucorig              = "";
LET vNumCte               = "";
LET vNombreCte            = "";
LET vTerminacion          = "";
LET vIvaCom               = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;
    END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/informix/paulq/cargoref_tdc_general.out";
-- TRACE ON;
	  
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT a.num_credito, b.divisa, b.sucursal, b.numcte
  INTO v_num_credito, v_divisa, vsucorig, vNumCte
  FROM bdicred:"informix".sd_tarjeta a,
       bdicred:"informix".sd_maecred b
 WHERE a.empresa     = pEmpresa
   AND a.num_tarjeta = pTarjeta
   AND b.empresa     = a.empresa
   AND b.num_credito = a.num_credito;

IF v_num_credito IS NULL THEN
	LET cod_ret = "8";
	RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;
END IF

SELECT TRIM(NVL(razon_social, ' ')) ||
TRIM(nombre1) || " " ||
--TRIM(NVL(nombre2, ' ')) || " " ||
TRIM(apell_paterno)
--TRIM(apell_materno)
INTO vNombreCte
FROM bdinteg:"informix".si_cliente
WHERE numcte = vNumCte;

LET vTerminacion = SUBSTR(pTarjeta,LENGTH(pTarjeta)-3,LENGTH(pTarjeta));
		
EXECUTE PROCEDURE bdicred:"informix".cargo_ref_cel(pTarjeta, pSucursal, pUsuario,
					                               pTransuc, pTransuc, pFolioSuc,
												   v_num_credito, 1, pMonto, 0,
												   " ", " ", v_divisa, pReferencia,  
												   pSucursal, pUsuario, "",
												   "", "", v_num_credito,
												   1, 0, v_divisa, " ", "2",
												   "F"," ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;
		 
    LET vIvaCom = MtoCgo - pMonto - MtoCom;
		
RETURN cod_ret, vTerminacion, vNombreCte, MtoCgo, MtoCom, vIvaCom;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para la realización del cargo',
'por retiro de efectivo TDC desde alguna plataforma',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_consulta_retiro_tdc(pEmpresa     CHAR(3),
												   pSucursal    CHAR(4),
												   pCuenta      CHAR(20),
												   pNumTarjeta  CHAR(20),
												   pMonto       DECIMAL(14,2),
												   pDivisa      CHAR(2))
RETURNING CHAR(5)         AS codigo_retorno,
          DECIMAL(14,2)   AS importe_retiro,
		  DECIMAL(14,2)   AS importe_comision,
		  DECIMAL(14,2)   AS importe_iva_comision;
									
DEFINE nrows              INTEGER;
DEFINE iSqlErr            INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE vCodRet            CHAR(5);

DEFINE vNumCte            CHAR(20);
DEFINE vEmpresa           CHAR(3);
DEFINE vSucursal          CHAR(4);
DEFINE vDivisa            CHAR(2);
DEFINE vNumProducto       CHAR(4);
DEFINE vStatusCred        CHAR(2);
DEFINE vSaldo             MONEY(16,2);
DEFINE vTipoCredito       CHAR(2);
DEFINE vTasaIva           DECIMAL(5,3);
DEFINE vFechaHoy          DATE;
DEFINE vSdoPos            DECIMAL(14,2);
DEFINE vBloqueo           INTEGER;
DEFINE vCodCaracter       CHAR(2);
DEFINE v_codparam         CHAR(4);
DEFINE v_faplica          CHAR(1);
DEFINE vMtoComDisp        DECIMAL(14,2);
DEFINE v_factor           DECIMAL(9,6);
DEFINE v_rangos           CHAR(1);
DEFINE v_rmax             MONEY(14,2);
DEFINE vMtoComDisp_iva    DECIMAL(14,2);
DEFINE vIva               DECIMAL(14,2);

LET nrows                 = 0;
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = '';
LET vCodRet               = '000';

LET vNumCte               = '';
LET vEmpresa              = '';
LET vSucursal             = '';
LET vDivisa               = '';
LET vNumProducto          = '';
LET vStatusCred           = '';
LET vSaldo                = 0;
LET vTipoCredito          = '';
LET vTasaIva              = 0;
LET vFechaHoy             = DATE(1);
LET vSdoPos               = 0;
LET vBloqueo              = 0;
LET vCodCaracter          = '';
LET v_codparam            = '';
LET v_faplica             = '';
LET vMtoComDisp           = 0;
LET v_factor              = 0;
LET v_rangos              = '';
LET v_rmax                = 0;
LET vMtoComDisp_iva       = 0;
LET vIva                  = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
		LET vCodRet = iSqlErr;
		RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/informix/paulq/sp_consulta_retiro_tdc.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

IF NOT EXISTS( SELECT empresa FROM bdinteg:"informix".si_empresas WHERE empresa = pEmpresa) THEN
	LET vCodRet = "1070";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NOT EXISTS(SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = pEmpresa AND sucursal = pSucursal) THEN
	LET vCodRet = "1077";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NOT EXISTS(SELECT divisa FROM bdinteg:"informix".si_divisas where divisa = pDivisa) THEN
	LET vCodRet = "1078";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF NVL(pMonto,0) <= 0 THEN
	LET vCodRet = "1079";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF TRIM(NVL(pNumTarjeta,'')) = '' AND TRIM(NVL(pCuenta,'')) = '' THEN
	LET vCodRet = "1076";
	RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
END IF;

IF TRIM(NVL(pCuenta,'')) = '' THEN 
	SELECT num_credito
	  INTO pCuenta
	  FROM bdicred:"informix".sd_tarjeta
	 WHERE empresa = pEmpresa
	   AND num_tarjeta = pNumTarjeta
	   AND tipo_tarjeta = "T"
	   AND status_tar = "A";

	IF pCuenta IS NULL THEN
		LET vCodRet = "8";
		RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
	END IF
END IF;

SELECT a.empresa, a.sucursal, a.divisa, a.num_producto, a.status_cred,
	   b.monto_otorgado - (b.sdo_cap_insoluto + sdo_retenido),
       c.cod_tipcred, d.iva, e.fecha_proceso,
       CASE WHEN sdo_capital < 0 THEN  sdo_capital * -1 ELSE 0 END,
       a.id_unidad_prod, numcte,Cod_caract_2
  INTO vEmpresa, vSucursal, vDivisa, vNumProducto, vStatusCred,
	   vSaldo, vTipoCredito, vTasaIva, vFechaHoy, vSdoPos,
	   vBloqueo, vNumCte, vCodCaracter
  FROM "informix".sd_maecred a, "informix".sd_maesdos b, "informix".sd_definicion c, "informix".sd_maecredanexo e,
       bdinteg:"informix".si_sucursales d
 WHERE a.num_credito = pCuenta
   AND a.empresa = pEmpresa
   AND b.num_credito = a.num_credito
   AND a.empresa = b.empresa
   AND c.num_producto = a.num_producto
   AND e.num_credito = a.num_credito
   AND e.empresa = a.empresa
   AND d.empresa = a.empresa
   AND d.sucursal = pSucursal;
   
	IF vNumCte IS NULL THEN
			LET vCodRet = "100";
			RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);
	END IF
   
SELECT valor
  INTO v_codparam
  FROM "informix".sd_param
 WHERE empresa = '001'
   AND cod_param = "334";

SELECT form_aplica, monto, apli_factor, consi_rango, monto_max
  INTO v_faplica, vMtoComDisp, v_factor, v_rangos, v_rmax
  FROM "informix".sd_tpcomis
 WHERE empresa = '001'
   AND cod_comis = v_codparam;
   
IF v_faplica = 2 THEN
	LET vMtoComDisp = pMonto * (v_factor/100);
END IF
   
IF v_rangos = "1" THEN
	IF vMtoComDisp < v_rmax THEN
		LET vMtoComDisp = v_rmax;
	END IF
END IF;

LET vMtoComDisp_iva = vMtoComDisp * vTasaIva;
LET vIva = vMtoComDisp_iva;

RETURN vCodRet, NVL(pMonto,0), NVL(vMtoComDisp,0), NVL(vIva,0);

END
END PROCEDURE
DOCUMENT
'Se realiza el calculo de la comisión',
'por retiro de efectivo TDC',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 08/09/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_cac_rep_perfil_usuario(pFechaIni CHAR (10), pFechaFin CHAR(10))
RETURNING CHAR(6)                         AS codigo_retorno,
          CHAR(80)                        AS mensaje_retorno,
		  CHAR(8)                         AS Numempleado,
		  CHAR(45)                        AS Nombre,
		  CHAR (25)                       AS Perfil_Puesto,
		  INTEGER                         AS Atendidas,
		  DECIMAL(18,2)                   AS PorcAtendidas,
		  INTEGER                         AS Canceladas,
		  DECIMAL(18,2)                   AS PorcCanceladas,
		  INTEGER                         AS Rechazadas,
		  DECIMAL(18,2)                   AS PorcRechazadas,
		  INTEGER                         AS Autorizadas,
		  DECIMAL(18,2)                   AS PorcAutorizadas,
		  
		  INTEGER                         AS TotalAtendidas,
		  DECIMAL(18,2)                   AS TotalPorcAtendidas,
		  INTEGER                         AS TotalCanceladas,
		  DECIMAL(18,2)                   AS TotalPorcCanceladas,
		  INTEGER                         AS TotalRechazadas,
		  DECIMAL(18,2)                   AS TotalPorcRechazadas,
		  INTEGER                         AS TotalAutorizadas,
		  DECIMAL(18,2)                   AS TotalPorcAutorizadas;

---DECLARACIONES   
DEFINE cCodRet              CHAR(6); 
DEFINE cMensajeRet          CHAR(80);
DEFINE iSqlErr      	    INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE dPorcAtendidas		DECIMAL(18,2);	
DEFINE dPorcCanceladas		DECIMAL(18,2);
DEFINE dPorcRechazadas		DECIMAL(18,2);
DEFINE dPorcAutorizados	    DECIMAL(18,2);
DEFINE cDescripcion 		CHAR(25);
DEFINE cNombre				CHAR(45);
DEFINE cBandera 			CHAR(1);
DEFINE iCanceladas			INTEGER;
DEFINE iAutorizadas	     	INTEGER;
DEFINE iRechazadas		    INTEGER;
DEFINE cEjecutivo           CHAR(8);
DEFINE cPuesto 				CHAR(2);
DEFINE cRangoAutorizacion	CHAR(2);
DEFINE iTotalReg 			INTEGER;
DEFINE iTotalPerfil			INTEGER;

DEFINE dTotalPorcAtendidas		DECIMAL(18,2);	
DEFINE dTotalPorcCanceladas		DECIMAL(18,2);
DEFINE dTotalPorcRechazadas		DECIMAL(18,2);
DEFINE dTotalPorcAutorizados	    DECIMAL(18,2);

DEFINE iTotalTotalPerfil			INTEGER;
DEFINE iTotalCanceladas			INTEGER;
DEFINE iTotalAutorizadas	     	INTEGER;
DEFINE iTotalRechazadas		    INTEGER;
---INICIALIZACIONES

LET iSqlErr                  = 0;
LET iIsamErr                 = 0;
LET cErrorInfo               = "";
LET cCodRet                  = "000000";
LET cMensajeRet              = "Se realizó la consulta correctamente";
LET dPorcAtendidas		     = 0;
LET dPorcCanceladas		     = 0;
LET dPorcRechazadas		     = 0;
LET dPorcAutorizados	     = 0;
LET iCanceladas		     	 = 0;
LET iAutorizadas	     	 = 0;
LET iRechazadas		     	 = 0;
LET cEjecutivo				 = "";
LET cPuesto 				 = "";
LET cRangoAutorizacion		 = "";
LET iTotalReg				 = 0;
LET cDescripcion			 = "";
LET cNombre 				 = "";
LET cBandera				 = "";
LET iTotalPerfil			 = 0;

LET dTotalPorcAtendidas		     = 0;
LET dTotalPorcCanceladas		     = 0;
LET dTotalPorcRechazadas		     = 0;
LET dTotalPorcAutorizados	     = 0;

LET iTotalTotalPerfil			 = 0;
LET iTotalCanceladas		     	 = 0;
LET iTotalAutorizadas	     	 = 0;
LET iTotalRechazadas		     	 = 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
    LET cCodRet= iSqlErr;
	LET cMensajeRet=cErrorInfo;
       RETURN cCodRet, cMensajeRet, NVL(cEjecutivo,' '), NVL(cNombre,' '), NVL(cDescripcion,' '), NVL(iTotalPerfil,0), NVL(dPorcAtendidas,0), NVL(iCanceladas,0), NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
   END IF;
END EXCEPTION;

	--set debug file to "/informix/jesus/sp_cac_rep_perfil_usuario.out";
	--trace on;

--se validan los parametros de entrada.
IF NVL(pFechaini,"") = "" OR NVL(pFechaFin,"")="" THEN
	LET cCodRet = "000001";
	LET cMensajeRet = "Falta un parámetro de fecha requerido para realizar  la consulta";
	RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
		NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
----se obtiene el total de registros de solicitudes atendidas.
			
	SELECT {+INDEX (bdicred:sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} COUNT( b.num_solicitud) --total atendidas 
	INTO iTotalReg
	FROM  bdicred:"informix".sd_historica_cac_aumlincred h ,
	bdicred:"informix".sd_bitacora_aumlincred b			  
	WHERE  h.empresa = b.empresa 
	AND h.solicitud  = b.num_solicitud
	AND h.fecha_insert between  b.fecha_insert and b.fecha_status
	AND b.fecha_insert >= pFechaIni
	AND b.fecha_insert <= pFechaFin
	AND b.origen = "S";
	
	
	IF iTotalReg = 0 THEN
		LET cCodRet = "000003";
		LET cMensajeRet =  "No hay información con el rango de fechas solicitado";		
		RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
			NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0);
	END IF;	
	--Ciclo para obtener la cantidad de solicitudes atendidas por puesto y ejecutivo
	FOREACH WITH HOLD	
		SELECT {+INDEX (bdicred:sd_historica_cac_aumlincred idx1_sd_historica_cac_aumlincred)} h.puesto,h.ejecutivo,COUNT( b.num_solicitud), --total atendidas por usuario	
		SUM(CASE WHEN b.status='CM' THEN 1 ELSE 0 END),--Canceladas
		SUM(CASE WHEN b.status='RT' THEN 1 ELSE 0 END),--Rechazadas
		SUM(CASE WHEN b.status in ('AT','AP','IN') THEN 1 ELSE 0 END)--Autorizadas
		INTO cPuesto,cEjecutivo,iTotalPerfil,iCanceladas,iRechazadas,iAutorizadas
		FROM bdicred:"informix".sd_bitacora_aumlincred b, bdicred:"informix".sd_historica_cac_aumlincred h
		WHERE  h.empresa = b.empresa 
		AND h.solicitud  = b.num_solicitud
		AND h.fecha_insert between  b.fecha_insert and b.fecha_status
		AND b.fecha_insert >= pFechaIni
		AND b.fecha_insert <= pFechaFin
		AND b.origen = "S"
		GROUP BY h.puesto,h.ejecutivo
		ORDER BY h.puesto,h.ejecutivo		
			
			LET dPorcCanceladas	=0;
			LET dPorcRechazadas	=0;
			LET dPorcAutorizados=0;
			LET dPorcAtendidas  =0;
			
			--Se obtiene el nombre del ejecutivo
			SELECT nombre
			INTO cNombre
			FROM bdinteg:"informix".si_ejecut
			WHERE ejecutivo=cEjecutivo;
			--Se obtiene la descripcion del puesto del ejecutivo
			SELECT descripcion_puesto
			INTO cDescripcion
			FROM bdicred:"informix".sd_puestos_cac_aumlincred
			WHERE puesto=cPuesto;
			
			--Calculo para obtener los porcentajes de las solicitudes atendidas,  canceladas, rechazadas y autorizadas. 
			IF NVL(iTotalPerfil,0) <> 0 THEN
			LET dPorcAtendidas = ((iTotalPerfil * 100) / iTotalReg);
			--Total
			LET iTotalTotalPerfil = iTotalTotalPerfil + iTotalPerfil;
			
			END IF;
			IF NVL(iCanceladas,0) <> 0 THEN
				LET dPorcCanceladas = ((iCanceladas * 100) / iTotalPerfil);
				--Total
				LET iTotalCanceladas = iTotalCanceladas + iCanceladas;
				
			END IF;
			IF NVL(iRechazadas,0) <> 0 THEN
				LET dPorcRechazadas	= ((iRechazadas * 100) / iTotalPerfil);
				--Total
				LET iTotalRechazadas = iTotalRechazadas + iRechazadas;
				
			END IF;
			IF NVL(iAutorizadas,0) <> 0 THEN
				LET dPorcAutorizados =((iAutorizadas * 100) / iTotalPerfil);
				--Total
				LET iTotalAutorizadas = iTotalAutorizadas + iAutorizadas;
				
			END IF;						
			
			LET dTotalPorcAtendidas = ((iTotalTotalPerfil * 100) / iTotalTotalPerfil); 
			LET dTotalPorcCanceladas = ((iTotalCanceladas * 100) / iTotalTotalPerfil);
			LET dTotalPorcRechazadas = ((iTotalRechazadas * 100) / iTotalTotalPerfil); 
			LET dTotalPorcAutorizados = ((iTotalAutorizadas * 100) / iTotalTotalPerfil);
			
			RETURN cCodRet, cMensajeRet,NVL(cEjecutivo,""),NVL(cNombre,""),NVL(cDescripcion,""),NVL(iTotalPerfil,0),NVL(dPorcAtendidas,0),NVL(iCanceladas,0),NVL(dPorcCanceladas,0),NVL(iRechazadas,0),NVL(dPorcRechazadas,0),NVL(iAutorizadas,0),NVL(dPorcAutorizados,0),
				NVL(iTotalTotalPerfil,0), NVL(dTotalPorcAtendidas,0), NVL(iTotalCanceladas,0), NVL(dTotalPorcCanceladas,0),NVL(iTotalRechazadas,0),NVL(dTotalPorcRechazadas,0),NVL(iTotalAutorizadas,0),NVL(dTotalPorcAutorizados,0) WITH RESUME;
		
	END FOREACH;	
	
END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se realiza procedimiento para obtener los registros para el reporte por perfil de usuario en un periodo de fecha',
'AUTOR: MARIA ELENA ANGULO AISPURO, HECTOR MANUEL BOJORQUEZ RUELAS',
'FECHA: SEPTIEMBRE 2011',
'VERSION: 20111021.0902',
'BD: BDICRED',
'----------------------------------------------------------------------------------',
'Autor: Daniel Lazalde',
'Modificación: Se agregan los totales de las atendidas, autorizadas, canceladas y rechazadas',
'Fecha de modificación: 08/Febrero/2014',
'BD : bdicred',
'----------------------------------------------------------------------------------';

create procedure "informix".sp_depura_incrementos()
--execute procedure sp_depura_incrementos()
RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;
			
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);	

DEFINE vnum_credito        	CHAR(12);	
DEFINE vnum_cte     		VARCHAR(20);	
DEFINE vstatus				CHAR(2);	
DEFINE fh_inicio			char(19);DEFINE fh_fin				char(19);DEFINE vfecha				DATE;

LET cCodRet = "000000";
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";

LET vnum_credito			="";
LET vnum_cte				="";
LET vstatus					="";
LET fh_inicio				=date(1);
LET fh_fin					=date(1);
LET vfecha					=date(1);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;


--SET DEBUG FILE TO "/RESPALDOS/ipcb/pruebas/sp_depura_incrementos.out";
--TRACE ON; 

set isolation to dirty read;
set lock mode to wait 3;

SELECT num_solicitud,fecha_insert
FROM bdicred:sd_bitacora_aumlincred 
WHERE status = 'RT' AND fecha_insert = mdy('12','10','2015') AND origen = 'C' 
INTO TEMP tot_creditos  WITH NO LOG;

CREATE INDEX idx_totcreditos ON tot_creditos (num_solicitud);	
update statistics medium for table tot_creditos;		

select first 1 today||" "||current HOUR TO SECOND   INTO fh_inicio
from systables;

  foreach with hold
    SELECT num_solicitud,fecha_insert INTO  vnum_credito, vfecha
	FROM tot_creditos

    begin;
		DELETE FROM "informix".sd_autorizacion_aumlincred WHERE num_solicitud = vnum_credito  AND fecha_insert  = vfecha;
		DELETE FROM "informix".sd_clientes_clean_behavior WHERE fecha_reporte  = vfecha AND num_credito = vnum_credito;
		DELETE FROM "informix".sd_bitacora_aumlincred WHERE empresa="001" AND num_solicitud = vnum_credito AND status = "RT" AND fecha_insert  = vfecha;
	commit;	
  END FOREACH

select first 1 today||" "||current HOUR TO SECOND   INTO fh_fin
from systables;

LET cCodRet     = "00000";
LET cMensajeRet = "DEPURA INCREMENTOS INICIO:"||fh_inicio ||" FIN:"||fh_fin;

RETURN cCodRet, cMensajeRet; 
END;
END PROCEDURE;