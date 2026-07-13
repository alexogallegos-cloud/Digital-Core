CREATE PROCEDURE "informix".sp_cierre_credito_mx(pEmpresa CHAR(3))
RETURNING
   CHAR(6)        AS Cod_Ret,
   CHAR(80)       AS Mens_Ret;
   
--EXECUTE PROCEDURE "informix".sp_cierre_credito('001');

-- Modifico: Roque Solis
-- : 2009/30/12 
-- Modificacion: Se cambiaron los llamados del genmovcrd y se agrego 
--              una descripcion a los movimientos de la provision,
--              Se controlo la creacion de la tabla temporal 
--              tmp_sucursales_pp

-- Modifico: Roque Solis
-- Fechas: 2010/05/01 
-- Modificacion: se agrego la actualizacion del campo mto_finan_vdo

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/20
-- Comentario: * Se agrega la actualizaciÃÂ³n del campo capital_status_ant
--             * Se agrega la actualizaciÃÂ³n del campo mto_fin_ven_trasp
--             * Se agrega la actualizaciÃÂ³n del campo dias_acum_mora
--             * Se agrega la actualizaciÃÂ³n del campo dias_acum_cap
--             * Se modifica el calculo de el parÃÂ¡metro de la tasa
--               de interes mora copete
-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 2010/01/21
-- Comentario: Se modifica la actualizacion al campo sdo_global_int

-- Modifico: Roque Enrique Solis
-- Fecha: 12/02/2010
-- Comentario: Se resto la parte que se provisiono de intereses e ivas en el fin de mes en la facturacion.

-- Modifico: Paul Ivan Quintero Varela
-- Fecha: 12/02/2010
-- Comentario: * Se agrega validaciÃÂ³n para que la inserciÃÂ³n del historico de saldos (tabla sd_maesdoshistcrd)
--               tambien se realice en su facturaciÃÂ³n.
--             * Se modifica para que la condiciÃÂ³n del traspaso a los 90 dias no este ligado a que sea realizada siempre
--               el mismo dia en que cumple su mesiversario.

-- FMV 21-ENE-2011: Devengamiento de Interes para la cuota que vence si el capital no es pagado.


DEFINE iSqlErr              INTEGER;
DEFINE iIsamErr             INTEGER;
DEFINE cErrorInfo           CHAR(80);
DEFINE cCodRet              CHAR(6);
DEFINE cMensajeRet          CHAR(125);

DEFINE cBegin               CHAR(1);
DEFINE cFolio         	    CHAR(16);
DEFINE cEmpresa             CHAR(3);
DEFINE cNumCredito          CHAR(20);
DEFINE cStatusCred    	    CHAR(2);
DEFINE cStatusCredAnt 	    CHAR(2);
DEFINE cDivisa              CHAR(2);
DEFINE cNumProducto   	    CHAR(4);
DEFINE dtFechaApert         DATE;
DEFINE iDiaCorte            INTEGER;
DEFINE cSucursal      	    CHAR(4); 
DEFINE cPlaza         	    CHAR(3);
DEFINE dIvaSuc              DECIMAL(5,3);
DEFINE cCodTipCred          CHAR(2);
DEFINE iDiasCalc            INTEGER;
DEFINE dtFechaHoy           DATE;
DEFINE dtFechaHoyAux        DATE;
DEFINE dtFechaProx          DATE;
DEFINE dtFechaFinMes        DATE;
DEFINE dtFechaFinMesAnt     DATE;
DEFINE dtFechaProxCuota     DATE;
DEFINE dtFechaVencto        DATE;
DEFINE iDiasInt             INTEGER;
DEFINE iDiasInt_inh         INTEGER;

DEFINE dIntDiario           DECIMAL(18,2);
DEFINE dIntDiario_inh       DECIMAL(18,2);
DEFINE dTasaInter           DECIMAL(9,6);
DEFINE dSdoCapital          DECIMAL(18,2);
DEFINE dMntVencido          DECIMAL(18,2);
DEFINE dMntVencTras         DECIMAL(18,2);
DEFINE dCapTrasNoVen        DECIMAL(18,2);
DEFINE dSdoCapInso          DECIMAL(18,2);
DEFINE dSdoNoExig           DECIMAL(18,2);
DEFINE dSdoInt              DECIMAL(18,2);
DEFINE dSdodiaantint        DECIMAL(18,2);
DEFINE dSdoInt_inh          DECIMAL(18,2);
DEFINE dSdomesantint        DECIMAL(18,2);
DEFINE dMontofinanciado     DECIMAL(18,2);
DEFINE dIvaIntVencido       DECIMAL(18,2);
DEFINE dIvaIntVigente       DECIMAL(18,2);
DEFINE dSdotrab4            DECIMAL(18,2);
DEFINE dSdo                 DECIMAL(18,2);
DEFINE dtFechaCuota         DATE;
DEFINE dtFechaCuotaAnt      DATE;
DEFINE dProvInt       	    DECIMAL(14,2);
DEFINE dProvInt_inh   	    DECIMAL(14,2);
DEFINE dIvaPag        	    DECIMAL(14,2);
--ini cas
DEFINE dIntGrav      	    DECIMAL(14,2);
DEFINE dIntExen       	    DECIMAL(14,2);
DEFINE cInserta             INTEGER;
--fin cas
DEFINE dIntGrav_inh   	    DECIMAL(14,2);  --FMV 
DEFINE dIntExen_inh    	    DECIMAL(14,2);  --FMV 

DEFINE dtIvaFechaPag        DATE;
DEFINE dCapMtoCuota         DECIMAL(14,2);
DEFINE iNumPago             INTEGER;
DEFINE dProvIva       	    DECIMAL(14,2);
DEFINE dProvIva_inh    	    DECIMAL(14,2);
DEFINE dIntVdo              DECIMAL(18,2); 
DEFINE dTraspCap            DECIMAL(14,2);
DEFINE dTraspInt            DECIMAL(18,2);
DEFINE cCapStatusCuota      CHAR(1);
DEFINE iContCorte           INTEGER;
DEFINE cIdProc1             CHAR(1);
DEFINE cIdProc2             CHAR(1);
DEFINE cIdProc3             CHAR(1);
DEFINE cIdProc4             CHAR(1);    --FMV 9ene13
DEFINE dIntProvFinMes       DECIMAL(18,2);
DEFINE dIvaProvFinMes       DECIMAL(18,2);
DEFINE dIvaIntReal          DECIMAL(18,2);
DEFINE dIvaIntReal_inh      DECIMAL(18,2);
DEFINE dtFechaMesiversario  DATE;
DEFINE cBanTemp             CHAR(1);
DEFINE iNumVdos             INTEGER;
DEFINE iFechaVencto			DATE;
DEFINE iDiasTrasp           INTEGER;
DEFINE credcontproc 	    char(1);
DEFINE intecontproc 	    char(1);
DEFINE CodigoRefProvIva     INTEGER;
DEFINE CodigoRefProvInt     INTEGER;
DEFINE dIntPeriodo          DECIMAL(18,2);
DEFINE dIvaPeriodo          DECIMAL(18,2);


--FMV 21-ENE-11
DEFINE dCapTrasVen_Amort DECIMAL(14,2);

--FMV 3-MAR-11
DEFINE dCapdebe_Amort DECIMAL(14,2);

--SDFM 16-FEB-12
DEFINE v_marca_ayuda CHAR(2);

--FMV 24abr13: Indicadores de buro
DEFINE vf_fecha_ult_pago DATE;
DEFINE vdias_atraso      INTEGER;

DEFINE Campotrabajo3 CHAR(10);
DEFINE vFechahist    DATE;

  -- RQM 09 473
DEFINE vSdoTotLiquidar 			decimal(18,2);
DEFINE vPagoMinimo 				decimal (18,2);
DEFINE vSdoTotVencido 			decimal(18,2);
  -- RQM 09 473

DEFINE wbandera_apoyo 		CHAR(1);
DEFINE v_historico_apoyo	INTEGER;
  
LET cBegin              = "N";
LET cFolio         	    = "";
LET cEmpresa            = "";
LET cNumCredito         = "";
LET cStatusCred    	    = "";
LET cStatusCredAnt 	    = "";
LET cNumProducto   	    = "";
LET cDivisa             = "";
LET dtFechaApert        = DATE(1);
LET iDiaCorte           = 0;
LET cSucursal      	    = "";
LET cPlaza         	    = "";
LET dIvaSuc             = 0;
LET cCodTipCred         = "";
LET iDiasCalc           = 0;
LET dtFechaHoy          = DATE(1);
LET dtFechaHoyAux       = DATE(1);
LET dtFechaProx         = DATE(1);
LET dtFechaFinMes       = DATE(1);
LET dtFechaFinMesAnt    = DATE(1);
LET dtFechaProxCuota    = DATE(1);
LET dtFechaVencto       = DATE(1);
LET iDiasInt            = 0;
LET iDiasInt_inh        = 0;
LET dIntDiario          = 0;
LET dIntDiario_inh      = 0;
LET dTasaInter          = 0;
LET dSdoCapital         = 0;
LET dMntVencido         = 0;
LET dMntVencTras        = 0;
LET dCapTrasNoVen       = 0;
LET dSdoCapInso         = 0;
LET dSdoNoExig          = 0;
LET dSdoInt             = 0;
LET dSdodiaantint       = 0;
LET dSdoInt_inh         = 0;
LET dSdomesantint       = 0;
LET dMontofinanciado    = 0;
LET dIvaIntVencido      = 0;
LET dIvaIntVigente      = 0;
LET dSdotrab4           = 0;
LET dSdo                = 0;
LET dtFechaCuota        = DATE(1);
LET dtFechaCuotaAnt     = DATE(1);
LET dProvInt       	    = 0;
LET dProvInt_inh   	    = 0;
LET dIvaPag        	    = 0;
LET dtIvaFechaPag       = DATE(1);
LET dCapMtoCuota        = 0;
LET iNumPago            = 0;
LET dProvIva       	    = 0;
LET dProvIva_inh   	    = 0;
LET dIntVdo             = 0;
LET dTraspCap           = 0;
LET dTraspInt           = 0;
LET cCapStatusCuota     = "";
LET iContCorte          = 0;
LET cIdProc1            = "";
LET cIdProc2            = "";
LET cIdProc3            = "";
LET cIdProc4            = ""; --FMV 9ene13

LET dIntProvFinMes      = 0;
LET dIvaProvFinMes      = 0;
LET dtFechaMesiversario = DATE(1);
LET cBanTemp            = 'N';
LET iNumVdos            = 0;
LET iFechaVencto		= DATE(1);
LET iDiasTrasp          = 0;
LET dIntGrav            = 0;
LET dIntExen            = 0;
LET dIntGrav_inh        = 0;
LET dIntExen_inh        = 0;
LET ccodret             ='000';
LET CodigoRefProvIva    = 0;
LET CodigoRefProvInt    = 0;
LET cInserta            = 0;
LET dIntPeriodo         = 0;
LET dIvaPeriodo         = 0;
LET v_marca_ayuda       = '';

-- FMV 21-ENE-11 INICIO DE LA VARIABLE PARA EL CALCULO DE INTERES EN VENCIMIENTO, STATUS 1 DE AMORTIZA
LET dCapTrasVen_Amort = 0;
--FMV 3-MAR-11
LET dCapdebe_Amort =  0;

LET vf_fecha_ult_pago = DATE(1);
LET vdias_atraso = 0;

LET Campotrabajo3 = 0;
LET vFechahist = DATE(1);

  -- RQM 09 473 TRIAD
LET vSdoTotLiquidar 		= 0;
LET vPagoMinimo				= 0;
LET vSdoTotVencido 			= 0;
  -- RQM 09 473

LET wbandera_apoyo 		= '';
LET v_historico_apoyo 	= 0;

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= trim(cErrorInfo) ||'-'||cNumCredito;
      IF cBegin = "S" THEN
          ROLLBACK WORK;
      END IF;

          UPDATE "informix".sd_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 cod_ret     = cCodRet,
                 mensaje     = cMensajeRet
           WHERE empresa     = cEmpresa
             AND proceso     = "CierreReesDia"
             AND fecha       = dtFechaHoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "C",
                 hora_fin    = CURRENT,
                 codret      = cCodRet
           WHERE empresa     = cEmpresa
             AND proceso     = "CierreReesDia"
             AND fecha       = dtFechaHoy;

	  IF cBanTemp ='S' THEN
	     DROP TABLE tmp_sucursales_pp;
	  END IF;
	  
   RETURN cCodRet,cMensajeRet;
   END IF;
END EXCEPTION;

SET DEBUG FILE TO '/tmp/sp_cierre_credito.out';
TRACE ON;

-- *******************************************************
--  VALIDACIONES DE EJECUCIÃÂN DE PROCESO                 *
-- *******************************************************
SELECT a.empresa 
  INTO cEmpresa
  FROM bdinteg:si_empresas a
 WHERE a.empresa = pEmpresa;

IF NVL(cEmpresa,"") = "" THEN 
     LET cCodRet     = "000001";
     LET cMensajeRet = "La empresa no existe";
     RETURN cCodRet, cMensajeRet;
END IF;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes,
       USER||DAY(CURRENT)||MONTH(CURRENT)||SUBSTR(CURRENT,3,2)
           ||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)
           ||SUBSTR(CURRENT,18,2)
  INTO dtFechaHoy, dtFechaProx, dtFechaFinMes,
       cFolio
  FROM "informix".sd_fechas a
 WHERE a.empresa = cEmpresa;


-- *******************************************************
--  INSERTA PARA EJECUCIÃÂN DE PROCESO                 *
-- *******************************************************
--INI CAS

    SELECT status_proc 
    INTO intecontproc
    FROM bdinteg:sx_contproc
    WHERE fecha= dtFechaHoy 
      and proceso ='CierreReesDia';

    if (intecontproc='F') then
        LET cMensajeRet="YA EJECUTADO ANTERIORMENTE";
        RETURN cCodRet,cMensajeRet;
     end if;

    SELECT status_proc  
    INTO credcontproc
    FROM bdicred:sd_contproc
    WHERE fecha= dtFechaHoy 
      and proceso ='CierreReesDia';
              
    IF (intecontproc IS NULL) THEN
      INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
      VALUES ('001','CierreReesDia',dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    end if;  
    
    if (credcontproc IS NULL) THEN
      INSERT INTO  sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
      VALUES ('001','CierreReesDia',dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Iniciamos');
    end if;
    
    UPDATE bdinteg:sx_contproc 
       SET status_proc='I'
     WHERE fecha= dtFechaHoy 
       and proceso ='CierreReesDia';

     UPDATE bdicred:sd_contproc 
        SET status_proc='I' ,mensaje = 'Iniciamos'
      WHERE fecha= dtFechaHoy 
        and proceso ='CierreReesDia';
--FIN CAS

SELECT a.cod_tipcred
  INTO cCodTipCred
  FROM "informix".sd_tipcred a
 WHERE a.cod_tipcred  = '03'
   AND a.empresa      = cEmpresa;

IF NVL(cCodTipCred,"") = "" THEN 
     LET cCodRet     = "000002";
     LET cMensajeRet = "El tipo de crÃÂ©dito indicado no existe";
     RETURN cCodRet, cMensajeRet;
END IF;


SELECT a.valor
  INTO iDiasCalc     -- 360 dias para calculo
  FROM "informix".sd_param a
 WHERE a.cod_param = "24";   

IF iDiasCalc IS NULL THEN
    LET cCodRet     = "000003";
    LET cMensajeRet = "Parametro para los dias de calculo de interes no encontrado";
    RETURN cCodRet, cMensajeRet;
END IF;
   
-- Dias de interes.
LET iDiasInt = dtFechaProx - dtFechaHoy;

IF NVL(iDiasInt,0) <= 0 THEN
    LET cCodRet     = "000004";
    LET cMensajeRet = "Fechas incorrectas";
    RETURN cCodRet, cMensajeRet;
END IF;

SELECT a.empresa, a.sucursal, a.iva, a.plaza
  FROM bdinteg:si_sucursales a
 WHERE a.tpo_sucursal = "S"
  INTO TEMP tmp_sucursales_pp;
CREATE INDEX indx_sucursal_pp ON tmp_sucursales_pp (empresa, sucursal);

LET cBanTemp = 'S';

--CALL "informix".monthadd(dtFechaFinMes,-1) RETURNING dtFechaFinMesAnt;
LET dtFechaFinMesAnt=DATE(MDY(MONTH(dtFechaFinMes),'01',YEAR(dtFechaFinMes))-1);
CALL "informix".sp_valfechabil(dtFechaHoy+1,'+') RETURNING cCodRet, dtFechaHoyAux;

-- *******************************************************
--  SELECCIÃÂN DE CRÃÂDITOS PARA PROCESAR                  *
-- *******************************************************


    SELECT
        a.num_credito ,	    	a.status_cred ,		a.num_producto ,  		a.sucursal ,	  	a.divisa ,				a.fecha_apertura ,
        a.tasa_interes ,		b.sdo_capital ,		b.monto_vencido ,		b.mto_venc_trasp ,	b.cap_tras_no_venci ,	b.sdo_cap_insoluto ,
        b.sdo_no_exig , 		b.sdo_intereses ,	C.dia_corte ,			b.int_tra_no_exig ,	C.fecha_vencto ,		C.prox_fecha_pago ,
        b.provision_normal ,	b.sdo_global_int ,	d.dias_traspaso_cap ,	b.sdo_dia_ant_int ,	b.sdo_mes_ant_int ,
        b.monto_financiado ,	b.mto_venc_int ,	b.mto_finan_vdo ,		b.sdo_trab4 ,		a.id_origen , 			c.fecha_ult_pago,
        a.campo_trab3
    FROM
        sd_maecredcrd a, sd_maesdoscrd b, sd_maecredanexocrd C,	sd_definicion d 
    WHERE 	a.num_credito = b.num_credito 
      AND	a.empresa = b.empresa 	
      AND	C.num_credito = a.num_credito 
      AND	C.empresa = a.empresa 
      AND	d.num_producto = a.num_producto 
      AND	d.empresa = C.empresa  
      AND	a.empresa = cEmpresa 
      AND	a.status_cred NOT IN ("FM","CC","FC","CV") 
      AND	C.fecha_proceso = dtFechaHoy 
      AND	d.cod_tipcred = cCodTipCred 
	  into temp paso_ree with no log;

      create unique index inx_paso_ree on paso_ree(num_credito);
      update statistics high for table paso_ree force;

FOREACH WITH HOLD 
    SELECT
        num_credito ,	    status_cred ,	num_producto ,  sucursal ,	  divisa ,	fecha_apertura ,
        tasa_interes ,	sdo_capital ,	monto_vencido ,	mto_venc_trasp ,	cap_tras_no_venci ,	sdo_cap_insoluto ,
        sdo_no_exig , 	sdo_intereses ,	dia_corte ,	int_tra_no_exig ,	fecha_vencto ,	prox_fecha_pago ,
        provision_normal ,	sdo_global_int ,	dias_traspaso_cap ,	sdo_dia_ant_int ,	sdo_mes_ant_int ,
        monto_financiado ,	mto_venc_int ,	mto_finan_vdo ,	sdo_trab4 ,	id_origen , fecha_ult_pago,
        campo_trab3
    INTO
        cNumCredito ,	cStatusCred ,	cNumProducto ,	cSucursal ,	cDivisa ,	dtFechaApert ,
        dTasaInter ,	dSdoCapital ,	dMntVencido ,	dMntVencTras ,	dCapTrasNoVen ,	dSdoCapInso ,
        dSdoNoExig ,	dSdoInt ,	iDiaCorte ,	dIntVdo ,	dtFechaVencto ,	dtFechaMesiversario ,
        dIntProvFinMes ,	dIvaProvFinMes ,	iDiasTrasp ,	dSdodiaantint ,	dSdomesantint ,	
        dMontofinanciado ,	dIvaIntVencido ,	dIvaIntVigente ,	dSdotrab4 ,	v_marca_ayuda , vf_fecha_ult_pago,
        Campotrabajo3
    FROM paso_ree
	  

	  LET cBegin = "S";

            BEGIN WORK;
            
            LET cStatusCredAnt     = cStatusCred;
            LET cIdProc1           = "";
            LET cIdProc2           = "";
            LET cIdProc3           = "";            
            LET cIdProc4           = "";  
            LET dIvaIntReal        = 0;            
            LET dIvaIntReal_inh    = 0;    
            LET dProvIva           = 0;
            LET dProvIva_inh       = 0;
            LET dProvInt           = 0;
            LET dProvInt_inh       = 0;
            LET dCapMtoCuota       = 0;
            LET dIntPeriodo         = 0;
            LET dIvaPeriodo         = 0;
            LET dSdoInt_inh        = 0;
            LET dProvInt_inh       = 0;
            LET dIntGrav_inh       = 0;         
            LET dIntExen_inh       = 0;
            LET iDiasInt_inh       = 0;
            LET dIntDiario_inh     = 0;
			
			SELECT bandera INTO wbandera_apoyo
               FROM sd_programa_apoyo2018crd
              WHERE num_credito = cNumCredito;
			IF ( wbandera_apoyo is null ) THEN LET wbandera_apoyo = ''; END IF;

            IF ( Campotrabajo3 is null ) then
                LET Campotrabajo3 = '';
            END IF;

		-- PIQV INI Graba historico para generar estados de cuenta de creditos cancelados
		--IF (cStatusCred = "FF") THEN
		IF (cStatusCred IN ("FF","FI")) THEN ----RQM  09 343-0 JMAH
			LET vFechahist = mdy(month(dtFechaHoy),iDiaCorte,year(dtFechaHoy));
			IF (day(dtFechaHoy)::smallint > iDiaCorte) THEN
				LET vFechahist = monthadd(vFechahist,1);
			END IF; 

              IF NOT EXISTS ( SELECT num_credito
                       FROM "informix".sd_maesdoshistcrd
                       WHERE empresa = cEmpresa
     			         AND num_credito = cNumCredito
                       AND fecha = vFechahist) THEN
 
			INSERT INTO "informix".sd_maesdoshistcrd SELECT vFechahist, * FROM "informix".sd_maesdoscrd WHERE num_credito = cNumCredito AND empresa = cEmpresa;	
            END IF;

			COMMIT WORK;
			CONTINUE FOREACH;
		END IF;
		-- PIQV INI Graba historico para generar estados de cuenta de creditos cancelados



-- *******************************************************
--  IDENTIFICACIÃÂN DE PROCESOS POR REALIZAR              *
-- *******************************************************

          -- ValidaciÃÂ³n para identificar un (Cierre de Mes).
          IF dtFechaHoy = dtFechaFinMes THEN  
            LET cIdProc1 = "C";
          END IF;			

          -- Validaciones para dÃÂ­as inhabiles y cambios de mes. (FacturaciÃÂ³n)
          IF (dtFechaHoyAux = dtFechaMesiversario and dtFechaHoyAux <> DATE(dtFechaHoy+1)) OR DATE(dtFechaHoy+1) = dtFechaMesiversario THEN
                LET cIdProc2 = "F"; 
                CALL "informix".monthadd(mdy(month(dtFechaMesiversario),day(iDiaCorte),year(dtFechaMesiversario)),1) RETURNING dtFechaProxCuota;
                CALL "informix".sp_valfechabil(dtFechaProxCuota,'+') RETURNING cCodRet, dtFechaProxCuota;
          END IF;
         
          -- Validaciones para identificar un (Mesiversario)
          IF dtFechaHoy = dtFechaMesiversario THEN
             LET cIdProc3 = "M";
                CALL "informix".monthadd(mdy(month(dtFechaMesiversario),day(iDiaCorte),year(dtFechaMesiversario)),1) RETURNING dtFechaProxCuota;
                CALL "informix".sp_valfechabil(dtFechaProxCuota,'+') RETURNING cCodRet, dtFechaProxCuota;
          END IF;

         --FMV 9ene13 Validacion 4o. Proceso, Provision a fin de mes cuando el siguiente dia es inhabil              
          IF (cIdProc1 = "C" AND dtFechaHoyAux > DATE(dtFechaHoy+1) AND iDiaCorte = 2) THEN
             LET cIdProc4 = "I";   --Inhabil, debe provisionar Interes e Iva con fecha a fin de mes.
             LET iDiasInt_inh = iDiasInt - 1; -- Se resta el dia inhabil 
             --LET iDiasInt = iDiasInt - 1;  --Se quita un dia ya que provisionarÃÂ¡ los q no tienen vencimiento el dia 2
          END IF;



			
-- Venta de Cartera Reestructurada 
			IF ( v_marca_ayuda = '1' OR cStatusCred = 'CV' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV') OR wbandera_apoyo ='A') THEN 
				CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)  
										  WHEN cIdProc2 = "F" THEN (dSdoNoExig-dProvInt) 
										  ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
									(CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva) 
										  WHEN cIdProc2 = "F" THEN (dIvaIntVigente-dProvIva) 
										  ELSE (dIvaIntVigente + dIvaProvFinMes) END),
									dIvaIntVencido,0,0,dMontofinanciado,dtFechaHoy) 
				 RETURNING cCodRet;

				IF (cCodRet <> "000") THEN
					 LET cCodRet     = "000002";
					 LET cMensajeRet = "Error al grabar en tabla saldos diarios";
					 RETURN cCodRet, cMensajeRet;
				END IF;

                IF ( v_marca_ayuda = '1' OR ( Campotrabajo3 = 'BAJA' AND cStatusCred <> 'CV') OR wbandera_apoyo ='A') THEN

                  SELECT COUNT(*), min(fecha_cuota)
                     INTO iNumVdos, iFechaVencto
                     FROM "informix".sd_amortiza_creditocrd a
                    WHERE a.empresa        = cEmpresa
                      AND a.num_credito    = cNumCredito
                      AND a.capital_status IN ("2","7");

                   IF iNumVdos IS NULL THEN
                      LET iNumVdos = 0;
                   END IF;

                   IF iFechaVencto IS NULL THEN 
                     LET iFechaVencto= NULL; 
                   END IF;

                    UPDATE sd_maesdoscrd 
                    SET mto_fin_ven_trasp = iNumVdos
                    WHERE  empresa = cEmpresa
                      AND  num_credito = cNumCredito;


                    UPDATE "informix".sd_maecredanexocrd
                       SET fecha_proceso  = dtFechaProx,
                            fecha_vencto  = iFechaVencto
                     WHERE num_credito    = cNumCredito
                       AND empresa        = cEmpresa;

                     IF ( cIdProc1 = "C"  or day(dtFechaHoy)=20 ) THEN
                           INSERT INTO "informix".sd_maesdoscontcrd
                                SELECT dtFechaHoy, *
                                  FROM informix.sd_maesdoscrd
                                 WHERE num_credito = cNumCredito
                                   AND empresa     = cEmpresa;

                           INSERT INTO "informix".sd_maecredcontcrd
                                SELECT dtFechaHoy, *
                                  FROM informix.sd_maecredcrd
                                 WHERE num_credito = cNumCredito
                                   AND empresa     = cEmpresa;
                     END IF;

                    IF ( cIdProc3 = "M" OR cIdProc2 = "F" ) THEN
                        IF ( cIdProc3 = "M" ) THEN
                            UPDATE "informix".sd_maecredanexocrd
                               SET prox_fecha_pago = dtFechaProxCuota 
                              WHERE num_credito     = cNumCredito
                                AND empresa         = cEmpresa;
                        END IF; 

                        INSERT INTO "informix".sd_maesdoshistcrd
                             SELECT dtFechaHoy, *
                               FROM informix.sd_maesdoscrd
                              WHERE num_credito = cNumCredito
                                AND empresa     = cEmpresa;

                    END IF; 
					
					IF (  cIdProc2 = "F" or cIdProc3 = "M") AND (wbandera_apoyo ='A' or Campotrabajo3 = 'BAJA') THEN
						 INSERT INTO "informix".sd_maesdoscrd_apoyo2018
						 SELECT dtFechaHoy, * FROM informix.sd_maesdoscrd
						 WHERE num_credito = cNumCredito AND empresa = cEmpresa;
						
							SELECT COUNT(*) INTO v_historico_apoyo FROM bdicred:"informix".sd_amortiza_creditocrd_apoyo2018
							WHERE num_credito = cNumCredito AND empresa = pEmpresa;
							
							IF v_historico_apoyo =0 THEN 
							 INSERT INTO bdicred:"informix".sd_amortiza_creditocrd_apoyo2018
							 SELECT dtFechaHoy, * FROM bdicred:"informix".sd_amortiza_creditocrd
							  WHERE num_credito = cNumCredito AND empresa = pEmpresa;					  
							END IF;
						 if  cIdProc3 = "M" then
						   update bdicred:"informix".sd_amortiza_creditocrd
							  set fecha_cuota = monthadd(fecha_cuota,1)
							where capital_status in (3,7,1)
							  AND num_credito = cNumCredito
							  AND empresa = pEmpresa;
						 end if;
					END IF;
					
    				IF cIdProc1 = "C"  THEN					 
					   SELECT min(fecha_cuota)
					     INTO  iFechaVencto
				 	     FROM "informix".sd_amortiza_creditocrd a
					    WHERE a.empresa        = cEmpresa
						  AND a.num_credito    = cNumCredito
						  AND a.capital_status IN ("2","7");
					  
                      IF iFechaVencto IS NULL THEN 
						 LET vdias_atraso= 0; 
					  ELIF cStatusCred = 'AA' then  
                        let vdias_atraso = 0;
					  ELSE
                        LET vdias_atraso = (dtFechaFinMes - nvl(iFechaVencto,dtFechaFinMes) + 1);               				      
				     END IF;	

					 UPDATE "informix".sd_indicador_cred_crd 
				        SET dias_atraso   = nvl(vdias_atraso,0)
				      WHERE empresa = cEmpresa
				        AND num_credito = cNumCredito;
				   END IF;   
               END IF;
           
				COMMIT WORK;
				CONTINUE FOREACH;
			END IF
-- Venta de cartera reestructurada 

			
-- *******************************************************
--  CALCULO DE INTERESES DIARIOS                         *
-- *******************************************************
 
   --FMV 20-ENE-11  Calcula el interes sobre el saldo capital sin el monto de traspaso ya calculado en la facturacion
            SELECT sum(capital_debe - capital_pagado)
               INTO dCapTrasVen_Amort
              FROM sd_amortiza_creditocrd
             WHERE empresa = cEmpresa
               AND num_credito = cNumCredito
               AND capital_status = '1';

               IF dCapTrasVen_Amort IS NULL
                 THEN
                    LET dCapTrasVen_Amort = 0;
               END IF;


                  --calculo de los intereses diarios
            LET dIntDiario = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt;
              
           IF cIdProc4 = "I"  THEN
              LET dIntDiario_inh = (((dSdoCapital + dCapTrasNoVen - dCapTrasVen_Amort) * dTasaInter) / (iDiasCalc * 100)) * iDiasInt_inh;             
              LET dSdoInt_inh  = dSdoInt_inh + dSdoInt + dIntDiario_inh;
           END IF;      
                
                  --Actualizacion de los intereses diarios en maestro de saldos (sd_maesdoscrd)
                  LET dSdodiaantint = dSdoInt;
                  LET dSdoInt       = dSdoInt + dIntDiario;

                  

                  --Actualizacion de los intereses diarios en sd_amortiza_creditocrd
                  UPDATE "informix".sd_amortiza_creditocrd
                     SET interes_debe = interes_debe + dIntDiario
                   WHERE empresa        = cEmpresa
                     AND num_credito    = cNumCredito
                     AND capital_status = "3";

                  --Se actualiza la fecha del prÃÂ³ximo proceso
                  UPDATE "informix".sd_maecredanexocrd
                     SET fecha_proceso  = dtFechaProx
                   WHERE num_credito    = cNumCredito
                     AND empresa        = cEmpresa;

 
		  

-- *******************************************************
--  Calculo de Iva de Interes                            *
-- *******************************************************
		 SELECT a.iva, a.plaza
		   INTO dIvaSuc, cPlaza
		   FROM tmp_sucursales_pp a
		  WHERE empresa  = cEmpresa
			AND sucursal = cSucursal;

-- *******************************************************
--  PROVISIÃÂN POR FIN DE MES EN DIA INHABIL SIGUIENTE    *
-- *******************************************************

IF (cIdProc1 = "C" AND cIdProc4 = "I") and (dSdoCapital + dCapTrasNoVen) > 0 THEN

           SELECT a.fecha_cuota,
                --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),
                  NVL(num_pago,1)
             INTO dtFechaCuota,
                 -- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,
                  iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

-- LET dSdoInt = dSdoInt + dIntDiario;
 LET dProvInt_inh = dSdoInt_inh;
	IF dTasaInter > 0 THEN   --FMV 26-AGO-14: Si la tasa de interes es mayor a cero, genero calculo de interes Real.
	  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
									  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt_inh) 
	  RETURNING cCodRet,dIvaIntReal_inh,cMensajeRet;

	  IF cCodRet <> "000000" THEN
			LET cCodRet      = "000005";
			LET cMensajeRet  = "OcurriÃÂ³ un error al realizar calculo de iva de interes";
			ROLLBACK WORK;
			RETURN cCodRet,cMensajeRet;
	  END IF;
	END IF;  --FMV

               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

       LET dProvIva_inh = dIvaIntReal_inh; -- dIvaProvFinMes;
       
       IF  cStatusCred in ('BT','VP') THEN
            LET CodigoRefProvIva    = 25;
            LET CodigoRefProvInt    = 2;
       ELSE
            LET CodigoRefProvIva    = 24;
            LET CodigoRefProvInt    = 3;
       END IF;

        IF dProvInt_inh > 0 THEN
		
        --LET dProvInt_inh = dProvInt_inh - dIntProvFinMes; FMV  se omite restar fin de mes en esta provision previo dia inhabil
        --LET dProvInt_inh = dProvInt_inh;

---Se genera la provision de interes en fin de mes o Facturacion
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt, 
				                          "606", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "F" 
                                                       and cIdProc4 = "I" then dtFechaHoy end, dProvInt_inh, cFolio, 
										  cSucursal, cDivisa, "0000",'PROV','')
				RETURNING cCodRet,cMensajeRet;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = "000006";
                       LET cMensajeRet = "OcurriÃÂ³ un error al registrar la provisiÃÂ³n de interes";
                       ROLLBACK WORK;
                       RETURN cCodRet,cMensajeRet;    
                END IF;

                --LET dProvIva_inh = dProvIva_inh - dIvaProvFinMes; FMV 13FEB13 NO SE DESCUENTA PROVISION FIN DE MES y PROVISIONA IVA

                IF dProvIva_inh > 0 THEN
---Se genera la provision de iva de interes real en fin de mes o Facturacion
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva, 
				                          "222", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "F" 
                                                       and cIdProc4 = "I" then dtFechaHoy end, dProvIva_inh, cFolio, 
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar la provisiÃÂ³n de iva de interes";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
                IF dProvInt_inh>0 and dProvIva_inh<=0 then 
                    LET dIntGrav_inh = dProvInt_inh; 
                    LET dIntExen_inh = 0;
                ELSE
                    LET dIntGrav_inh = dProvIva_inh/dIvaSuc;
                    IF dIntGrav_inh>dProvInt_inh THEN LET dIntGrav_inh=dProvInt_inh; END IF;
                    LET dIntExen_inh = dProvInt_inh-dIntGrav_inh;
                END IF;

                IF dIntGrav_inh>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12, 
				                          "606", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "F" 
                                                       and cIdProc4 = "I" then dtFechaHoy end, dIntGrav_inh, cFolio, 
										  cSucursal, cDivisa, "0000",'GRAV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar el InterÃÂ©s Gravado";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;
                END IF;
                IF dIntExen_inh>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
				                          "606", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "F" 
                                                       and cIdProc4 = "I" then dtFechaHoy end, dIntExen_inh, cFolio, 
										  cSucursal, cDivisa, "0000",'EXEN','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar el InterÃÂ©s Exento";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;
                END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento
        END IF;
END IF;
-- **********************************************************************
--  FIN DE PROVISIÃÂN POR REGISTROS DE MOVTO EN FIN MES POR DIA INHABIL  *
-- **********************************************************************




-- *******************************************************
--  PROVISIÃÂN                                            *
-- *******************************************************

IF (cIdProc1 = "C" OR cIdProc2 = "F") and (dSdoCapital + dCapTrasNoVen) > 0 THEN


           SELECT a.fecha_cuota,
                --  a.iva_pagado,
                  a.iva_fecha_pago,
                  NVL(a.capital_mto_cuota,0),
                  NVL(num_pago,1)
             INTO dtFechaCuota,
                 -- dIvaPag,
                  dtIvaFechaPag,
                  dCapMtoCuota,
                  iNumPago
             FROM "informix".sd_amortiza_creditocrd a
            WHERE a.empresa        = cEmpresa
              AND a.num_credito    = cNumCredito
              AND a.capital_status = "3";

               IF dtFechaCuota IS NOT NULL THEN
                   LET dtFechaCuotaAnt = dtFechaCuota;
               END IF;

                -- LET dSdoInt = dSdoInt + dIntDiario;
                  IF cIdProc4 = '' THEN
                     LET dProvInt = dSdoInt;
                  ELSE     
                     LET dProvInt = dSdoInt - dProvInt_inh;
                  END IF;

	IF dTasaInter > 0 THEN   --FMV 26-AGO-14: Si la tasa de interes es mayor a cero, genero calculo de interes Real.
	  CALL "informix".calc_iva_grav_pp(cEmpresa,cNumCredito,dTasaInter,dIvaSuc,dtFechaHoy+1,
									  dtIvaFechaPag,dtFechaApert,dtFechaCuota,dSdoInt) 
	  RETURNING cCodRet,dIvaIntReal,cMensajeRet;

	  IF cCodRet <> "000000" THEN
			LET cCodRet      = "000005";
			LET cMensajeRet  = "OcurriÃÂ³ un error al realizar calculo de iva de interes";
			ROLLBACK WORK;
			RETURN cCodRet,cMensajeRet;
	  END IF;
	END IF;  --FMV

               IF dIntProvFinMes is null THEN LET dIntProvFinMes=0; END IF;
               IF dIvaProvFinMes is null THEN LET dIvaProvFinMes=0; END IF;

                IF cIdProc4 = '' THEN
                   LET dProvIva = dIvaIntReal; -- dIvaProvFinMes;
                ELSE
                   LET dProvIva = dIvaIntReal - dProvIva_inh;
                END IF;   

       IF  cStatusCred in ('BT','VP') THEN
            LET CodigoRefProvIva    = 25;
            LET CodigoRefProvInt    = 2;
       ELSE
            LET CodigoRefProvIva    = 24;
            LET CodigoRefProvInt    = 3;
       END IF;

        IF dProvInt > 0 THEN
		
            
            IF cIdProc4 = '' THEN
                LET dProvInt = dProvInt - dIntProvFinMes;
            ELSE 
                --LET dProvInt = dProvInt - dIntProvFinMes - dProvInt_inh; FMV 
                --LET dProvInt = dProvInt - dProvInt_inh;
            END IF;

---Se genera la provision de interes en fin de mes o Facturacion
				CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto ,CodigoRefProvInt, 
				                          "606", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dProvInt, cFolio, 
										  cSucursal, cDivisa, "0000",'PROV','')
				RETURNING cCodRet,cMensajeRet;

                IF (cCodRet <> "000000") THEN
                       LET cCodRet      = "000006";
                       LET cMensajeRet = "OcurriÃÂ³ un error al registrar la provisiÃÂ³n de interes";
                       ROLLBACK WORK;
                       RETURN cCodRet,cMensajeRet;    
                END IF;

                    LET dProvIva = dProvIva - dIvaProvFinMes;



                IF dProvIva > 0 THEN
---Se genera la provision de iva de interes real en fin de mes o Facturacion
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , CodigoRefProvIva, 
				                          "222", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dProvIva, cFolio, 
										  cSucursal, cDivisa, "0000",'PROV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar la provisiÃÂ³n de iva de interes";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;
                END IF;
---ini cas, Se agrega el movimiento aplicativo de interes gravable y exento
                IF dProvInt>0 and dProvIva<=0 then 
                    LET dIntGrav = dProvInt; 
                    LET dIntExen = 0;
                ELSE
                    LET dIntGrav = dProvIva/dIvaSuc;
                    IF dIntGrav>dProvInt THEN LET dIntGrav=dProvInt; END IF;
                    LET dIntExen = dProvInt-dIntGrav;
                END IF;

                IF dIntGrav>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 12, 
				                          "606", case when cIdProc1 = "C" 
                                                       and cIdProc2 = ""  then dtFechaHoy else dtFechaMesiversario end, dIntGrav, cFolio, 
										  cSucursal, cDivisa, "0000",'GRAV','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar el InterÃÂ©s Gravado";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;
                END IF;
                IF dIntExen>0 THEN
						CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 13,
				                          "606", case when cIdProc1 = "C" 
                                                       and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIntExen, cFolio, 
										  cSucursal, cDivisa, "0000",'EXEN','')
				        RETURNING cCodRet,cMensajeRet;
                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000007";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar el InterÃÂ©s Exento";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;
                END IF;
---fin cas, Se agrega el movimiento aplicativo de interes gravable y exento
        END IF;
END IF;

-- *******************************************************

-- FACTURACIÃÂN                                           *
-- *******************************************************

-- FMV 25-ENE-2011: RealizarÃÂ¡ la facturaciÃÂ³n siempre y cuando la suma de Saldos vencidos sean mayores a cero
IF cIdProc2 = "F" AND (dSdoCapital + dCapTrasNoVen) > 0 THEN 
         LET iNumPago = iNumPago + 1 ;
           IF (dSdoCapital + dCapTrasNoVen - dCapMtoCuota) < 0  and (dSdoCapital + dCapTrasNoVen) > 0 THEN                      
              LET dCapMtoCuota = dSdoCapital + dCapTrasNoVen + dProvInt + dProvIva + dIntProvFinMes + dIvaProvFinMes;
                UPDATE "informix".sd_amortiza_creditocrd 
                   SET capital_mto_cuota   = dCapMtoCuota
                 WHERE empresa             = cEmpresa
                   AND num_credito         = cNumCredito
                   AND capital_status      = "3"; 
           END IF;
          

         
         LET dMontofinanciado = dMontofinanciado + dCapMtoCuota - dProvInt - dProvIva - dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
         LET dSdotrab4 = dSdotrab4  + dCapMtoCuota - dProvInt - dProvIva- dIntProvFinMes - dIvaProvFinMes - dProvInt_inh - dProvIva_inh;
         LET dSdomesantint = dSdoInt;
         LET dSdoNoExig = dSdoNoExig + dSdoInt;
         LET dSdoInt = 0;
         LET dIvaIntVigente = dIvaIntVigente + dIvaIntReal;

         IF cIdProc2 = "F" THEN LET dIntProvFinMes=0; LET dIvaProvFinMes=0; END IF;

                    UPDATE "informix".sd_amortiza_creditocrd 
                       SET capital_debe        = capital_mto_cuota - (interes_debe - interes_pagado) - (dIvaIntReal) + capital_pagado,
                           iva_debe            = iva_debe + dIvaIntReal,
                           capital_status      = "1",
                           capital_status_ant  = "3"
                     WHERE empresa             = cEmpresa
                       AND num_credito         = cNumCredito
                       AND capital_status      = "3";

                   -- FMV 3-MAR-11: Se adiciona el capital debe de amortiza cuando el estatus es 1
                    select capital_debe, 
                           interes_debe,
                           iva_debe
                      into dCapdebe_Amort,
                           dIntPeriodo,
                           dIvaPeriodo
                      from "informix".sd_amortiza_creditocrd 
                     where empresa             = cEmpresa
                       AND num_credito         = cNumCredito
                       AND capital_status      = "1";

                       IF dIntPeriodo IS NULL THEN LET dIntPeriodo=0; END IF;
                       IF dIvaPeriodo IS NULL THEN LET dIvaPeriodo=0; END IF;

                        IF dIntPeriodo>0 THEN
                                CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 43, 
                                                  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIntPeriodo, cFolio, 
                                                  cSucursal, cDivisa, "0000",'INT','')
                                RETURNING cCodRet,cMensajeRet;
                                IF (cCodRet <> "000000") THEN
                                       LET cCodRet      = "000007";
                                       LET cMensajeRet = "OcurriÃÂ³ un error al registrar el InterÃÂ©s Periodo";
                                       ROLLBACK WORK;
                                       RETURN cCodRet,cMensajeRet;    
                                END IF;
                        END IF;
                        IF dIvaPeriodo>0 THEN
                                CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 44, 
                                                  "222", case when cIdProc1 = "C" and cIdProc2 = "" then dtFechaHoy else dtFechaMesiversario end, dIvaPeriodo, cFolio, 
                                                  cSucursal, cDivisa, "0000",'INT','')
                                RETURNING cCodRet,cMensajeRet;
                                IF (cCodRet <> "000000") THEN
                                       LET cCodRet      = "000007";
                                       LET cMensajeRet = "OcurriÃÂ³ un error al registrar el InterÃÂ©s Periodo";
                                       ROLLBACK WORK;
                                       RETURN cCodRet,cMensajeRet;    
                                END IF;
                        END IF;
                      
                     -- FMV 03-MAR-11  Se sustituye linea para incluir solo el Capital_debe de la Cuota, y no
                    -- el total de la cuota completa dCapdebe_Amort
                    -- IF (dSdoCapital + dCapTrasNoVen - dCapMtoCuota) >  0 THEN
                       IF (dSdoCapital + dCapTrasNoVen - dCapdebe_Amort) >  0 THEN 
                    

                             SELECT COUNT(*) 
                              INTO cInserta
                              FROM sd_amortiza_creditocrd
                             WHERE empresa             = cEmpresa
                               AND num_credito         = cNumCredito
                               AND fecha_cuota         = dtFechaProxCuota;

                           IF cInserta>0 THEN

                                UPDATE "informix".sd_amortiza_creditocrd 
                                   SET capital_status      = "3",
                                       capital_status_ant  = "4"
                                 WHERE empresa             = cEmpresa
                                   AND num_credito         = cNumCredito
                                   AND fecha_cuota         = dtFechaProxCuota;
                           ELSE
                                   INSERT INTO "informix".sd_amortiza_creditocrd
                                            (
                                                empresa, 		    num_credito, 
                                                fecha_cuota, 		tipo_cuota, 
                                                capital_mto_cuota, 	capital_debe, 
                                                capital_pagado, 	capital_status, 
                                                capital_status_ant, capital_fecha_pago, 
                                                interes_debe, 		interes_pagado, 
                                                interes_status, 	interes_status_ant, 
                                                interes_fecha_pago, iva_debe, 
                                                iva_pagado, 		iva_status, 
                                                iva_status_ant, 	iva_fecha_pago, 
                                                mora_provi_ordi, 	mora_provi_cope, 
                                                mora_sdo_ordi, 		mora_sdo_ordi_pag, 
                                                mora_sdo_cope, 		mora_sdo_cope_pag, 
                                                mora_bonificado, 	mora_status, 
                                                mora_iva_debe, 		mora_iva_pagado, 
                                                mora_iva_status, 	mora_iva_fecha_pago, 
                                                num_pago, 		    campo_trabajo1, 
                                                campo_trabajo2, 	campo_trabajo3, 
                                                campo_trabajo4
                                            )
                                        VALUES
                                            (   cEmpresa,		    cNumCredito,
                                                dtFechaProxCuota,	"3",
                                                dCapMtoCuota,        0,
                                                0,			        "3",
                                                "3",         		"",
                                                0,			         0,
                                                "1",                "1",
                                                NULL,			     0,
                                                0,			        "1",
                                                "1",                 "",
                                                0,			         0,
                                                0,			         0,
                                                0,			         0,
                                                0,			         "1",
                                                0,			          0,
                                                "1",			     "",
                                                iNumPago,		      0,
                                                0,			         "",
                                                ""
                                            );
                           END IF;
                       END IF;
END IF;

-- *******************************************************
-- TRASPASOS                                             *
-- *******************************************************
    -- Traspaso de Vigente a Vencido Transitorio.
    IF cIdProc3 = "M" THEN

               SELECT NVL(a.capital_debe - a.capital_pagado,0),NVL(a.interes_debe - a.interes_pagado,0)
                 INTO dTraspCap,dTraspInt
                 FROM "informix".sd_amortiza_creditocrd a
                WHERE a.empresa        = cEmpresa
                  AND a.num_credito    = cNumCredito
                  AND a.capital_status = "1";

             IF dTraspCap IS NULL THEN LET dTraspCap=0; END IF;
             IF dTraspInt IS NULL THEN LET dTraspInt=0; END IF;

        IF cStatusCred = 'AA' THEN
           IF dTraspCap>0 THEN

               LET dMntVencido = dMntVencido + dTraspCap;
               LET dSdoCapital = dSdoCapital - dTraspCap;

                UPDATE "informix".sd_amortiza_creditocrd 
                   SET capital_status = "7",
                       capital_status_ant  = "1"
                 WHERE empresa        = cEmpresa 
                   AND num_credito    = cNumCredito 
                   AND capital_status = "1"; 


              --Se actualiza la fecha de vencimiento
              UPDATE "informix".sd_maecredanexocrd
                 SET fecha_vencto  = dtFechaHoy
               WHERE num_credito    = cNumCredito
                 AND empresa        = cEmpresa;

                LET cStatusCred ='BA';

             --FMV 25Abr13: Actualiza indicador del 1er. vencido y dias de atraso
              UPDATE "informix".sd_indicador_cred_crd
                 SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)                     
               WHERE num_credito   = cNumCredito
                 AND empresa       = cEmpresa;


              -- Traspaso capital vigente a transitorio.
                CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3, 
                        "602", dtFechaHoy, dTraspCap, cFolio, 
                        cSucursal, cDivisa, "0000",'TCVAT','')
                RETURNING cCodRet,cMensajeRet;

               IF (cCodRet <> "000000") THEN
                      LET cCodRet      = "000009";
                      LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso capital vigente a transitorio";
                      ROLLBACK WORK;
                      RETURN cCodRet,cMensajeRet;  
                END IF;

               IF dTraspInt > 0 THEN
                  -- Traspaso interes vigente a transitorio.
                  CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 4, 
                          "605", dtFechaHoy, dTraspInt, cFolio, 
                          cSucursal, cDivisa, "0000",'TCVAT','')
                  RETURNING cCodRet,cMensajeRet;
                    IF (cCodRet <> "000000") THEN
                           LET cCodRet      = "000009";
                           LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso capital vigente a transitorio";
                           ROLLBACK WORK;
                           RETURN cCodRet,cMensajeRet;  
                     END IF;
               END IF;
           END IF;
        ELSE
              IF cStatusCred = 'BA' THEN

                    LET dCapTrasNoVen = dSdoCapital;
                    LET dMntVencTras = dMntVencido;
                    LET dIntVdo = dSdoNoExig - dTraspInt;
                    LET dIvaIntVencido = dIvaIntVigente;
                    LET dIvaIntVigente = 0;
                    LET dSdoNoExig = 0;

                    UPDATE "informix".sd_amortiza_creditocrd 
                       SET capital_status = "2",
                           capital_status_ant  = "7"
                     WHERE empresa        = cEmpresa 
                       AND num_credito    = cNumCredito 
                       AND capital_status = "7";

                      IF (dSdoCapital - dTraspCap)>0 THEN
                          -- Traspaso capital vigente a vdo no exigible.
                          CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 2, 
                                  "602", dtFechaHoy, dSdoCapital, cFolio, 
                                  cSucursal, cDivisa, "0000",'TCVAVNE','')
                          RETURNING cCodRet,cMensajeRet;

                            IF (cCodRet <> "000000") THEN
                                   LET cCodRet      = "000010";
                                   LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso capital vigente a vdo no exigible";
                                   ROLLBACK WORK;
                                   RETURN cCodRet,cMensajeRet;    
                            END IF;
                      END IF;

                      IF dMntVencido>0 THEN
                          -- Traspaso capital transitorio a exigible.
                          CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3, 
                                  "601", dtFechaHoy, dMntVencido, cFolio, 
                                  cSucursal, cDivisa, "0000",'TCTAE','')
                          RETURNING cCodRet,cMensajeRet;

                            IF (cCodRet <> "000000") THEN
                                   LET cCodRet      = "000011";
                                   LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso capital transitorio a exigible";
                                   ROLLBACK WORK;
                                   RETURN cCodRet,cMensajeRet;    
                            END IF;
                      END IF;

                      IF dIntVdo>0 THEN
                          -- Traspaso interes vigente a vdo.
                          CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3, 
                                  "604", dtFechaHoy, dIntVdo, cFolio, 
                                  cSucursal, cDivisa, "0000",'TIVAV','')
                          RETURNING cCodRet,cMensajeRet;

                            IF (cCodRet <> "000000") THEN
                                   LET cCodRet      = "000012";
                                   LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso interes vigente a vdo";
                                   ROLLBACK WORK;
                                   RETURN cCodRet,cMensajeRet;    
                            END IF;
                      END IF;
                /*      -- ProvisiÃÂ³n de interes ordinario a provisiÃÂ³n de cartera vencida
                      CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 8, 
                              "606", dtFechaHoy, dIntVdo, cFolio, 
                              cSucursal, cDivisa, "0000",'PIOACV','')
                      RETURNING cCodRet,cMensajeRet;

                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000013";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar provisiÃÂ³n de interes ordinario";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;*/

                    LET dSdoCapital = 0;
                    LET dMntVencido = 0;
                    LET cStatusCred = 'BT';

              END IF;

           IF dTraspCap>0 AND cStatusCred IN ('BT','VP') THEN

                LET dMntVencTras = dMntVencTras + dTraspCap;
                LET dCapTrasNoVen = dCapTrasNoVen - dTraspCap;

                LET dIntVdo = dIntVdo + dTraspInt;
                LET dIvaIntVencido = dIvaIntVencido + dIvaIntVigente;
                LET dIvaIntVigente=0;
                LET dSdoNoExig = 0;

                UPDATE "informix".sd_amortiza_creditocrd 
                   SET capital_status = "2",
                       capital_status_ant  = "1"
                 WHERE empresa        = cEmpresa 
                   AND num_credito    = cNumCredito 
                   AND capital_status = "1"; 

             -- Actualizo fecha de 1er Vencido con estatus VP o BT        
             -- VP  + PAGO SOSTENIDO = 0

              UPDATE "informix".sd_indicador_cred_crd
                 SET fecha_vencido =  DECODE (nvl(fecha_vencido,date(1)) ,date(1), dtFechaHoy, fecha_vencido)                       
               WHERE num_credito   = cNumCredito
                 AND empresa       = cEmpresa;



                   IF  cStatusCredAnt <> cStatusCred THEN
                      -- Traspaso interes vigente a vdo.
                      CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 3, 
                              "604", dtFechaHoy, dTraspInt, cFolio, 
                              cSucursal, cDivisa, "0000",'TIVAV','')
                      RETURNING cCodRet,cMensajeRet;

                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000012";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso interes vigente a vdo";
                               ROLLBACK WORK;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;

                      -- ProvisiÃÂ³n de interes ordinario a provisiÃÂ³n de cartera vencida
                /*      CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 2, 
                              "606", dtFechaHoy, dTraspInt, cFolio, 
                              cSucursal, cDivisa, "0000",'PIOACV','')
                      RETURNING cCodRet,cMensajeRet;

                        IF (cCodRet <> "000000") THEN
                               LET cCodRet      = "000013";
                               LET cMensajeRet = "OcurriÃÂ³ un error al registrar provisiÃÂ³n de interes ordinario";
                               IF cBegin = "S" THEN
                                  ROLLBACK WORK;
                               END IF;
                               RETURN cCodRet,cMensajeRet;    
                        END IF;*/
                   END IF;
                   LET dSdoNoExig = 0;

                  -- Traspaso capital vencido no exigible a vencido exigible.
                   CALL "informix".genmovcrd(cEmpresa,cNumCredito, cNumProducto , 4, 
                          "601", dtFechaHoy, dTraspCap, cFolio, 
                          cSucursal, cDivisa, "0000",'TCVNEAVE','')
                  RETURNING cCodRet,cMensajeRet;

                    IF (cCodRet <> "000000") THEN
                           LET cCodRet      = "000014";
                           LET cMensajeRet = "OcurriÃÂ³ un error al registrar traspaso capital vencido no exigible a vencido exigible";
                           ROLLBACK WORK;
                           RETURN cCodRet,cMensajeRet;    
                    END IF;             
           END IF;
        END IF;

        UPDATE "informix".sd_maecredanexocrd
           SET prox_fecha_pago = dtFechaProxCuota
          WHERE num_credito     = cNumCredito
            AND empresa         = cEmpresa;

        UPDATE "informix".sd_maecredcrd 
           SET status_cred = (CASE WHEN status_cred=cStatusCred  THEN status_cred ELSE cStatusCred END),
               fecha_pago_cap = dtFechaProxCuota,
               fecha_pago_int = dtFechaProxCuota,
               pagos_sostenidos = (CASE WHEN status_cred='VP' AND dTraspCap>0  THEN 0 ELSE pagos_sostenidos END)
         WHERE num_credito = cNumCredito
           AND empresa     = cEmpresa;
END IF;

  SELECT COUNT(*), min(fecha_cuota)
     INTO iNumVdos, iFechaVencto
     FROM "informix".sd_amortiza_creditocrd a
    WHERE a.empresa        = cEmpresa
      AND a.num_credito    = cNumCredito
      AND a.capital_status IN ("2","7");

   IF iNumVdos IS NULL THEN
      LET iNumVdos = 0;
   END IF;
   IF iFechaVencto IS NULL THEN 
     LET iFechaVencto= NULL; 
   END IF;
   --FMJ Actualiza fecha de vecimiento con base a la cuota mas antigua
    UPDATE "informix".sd_maecredanexocrd
       SET fecha_vencto  = iFechaVencto
     WHERE num_credito    = cNumCredito
        AND empresa        = cEmpresa;
		
    UPDATE sd_maesdoscrd 
    SET fecha_ult_mov = dtFechaHoy,
        sdo_int_anticip = 0,
        sdo_int_ant_dev = 0,
        sdo_intereses = dSdoInt,
        sdo_dia_ant_int = dSdodiaantint,
        sdo_mes_ant_int = dSdomesantint,
        sdo_acum_mes_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE dSdoInt END),
        sdo_retenido = 0,
        sdo_acum_cap_int = 0,
        sdo_exig_int = 0,
        sdo_no_exig = dSdoNoExig, 
        provision_normal = (CASE WHEN cIdProc1 = "C" THEN (provision_normal + dSdoInt) ELSE dIntProvFinMes END),
        dias_acum_int = (CASE WHEN cIdProc2 = "F" THEN 0 ELSE (dias_acum_int + iDiasInt) END), 
        sdo_dia_ant_cap = sdo_cap_insoluto,
        sdo_mes_ant_cap = 0,
        sdo_acum_mes_cap = 0,
        sdo_capital = dSdoCapital,
        sdo_cap_insoluto = dSdoCapInso,
        --mto_capitalizado = 0,
        mto_ministra_cap = 0, 
        dias_acum_cap = (dias_acum_cap + iDiasInt),
        monto_vencido = dMntVencido,
        mto_venc_trasp = dMntVencTras,
        monto_financiado = dMontofinanciado, 
        sdo_global_int = (CASE WHEN cIdProc1 = "C" THEN (sdo_global_int + dProvIva) ELSE dIvaProvFinMes END),
        cap_tras_no_venci = dCapTrasNoVen,
        mto_venc_int = dIvaIntVencido,
        mto_finan_vdo = dIvaIntVigente,
        int_tra_no_exig = dIntVdo,
        sdo_trab4 = dSdotrab4,
        mto_fin_ven_trasp = iNumVdos
    WHERE  empresa = cEmpresa
      AND  num_credito = cNumCredito;



-- *******************************************************
-- RESPALDO DE INFORMACIÃÂN CONTABILIDAD A FIN DE MES     *
-- *******************************************************
     IF cIdProc1 = "C"  or day(dtFechaHoy)=20 THEN
           INSERT INTO "informix".sd_maesdoscontcrd
                SELECT dtFechaHoy, *
                  FROM informix.sd_maesdoscrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

           INSERT INTO "informix".sd_maecredcontcrd
                SELECT dtFechaHoy, *
                  FROM informix.sd_maecredcrd
                 WHERE num_credito = cNumCredito
                   AND empresa     = cEmpresa;

     END IF;

-- *******************************************************
-- GENERAR HISTORICO DE SALDOS                           *
-- *******************************************************
    IF cIdProc3 = "M" OR cIdProc2 = "F" THEN
        INSERT INTO "informix".sd_maesdoshistcrd
             SELECT dtFechaHoy, *
               FROM informix.sd_maesdoscrd
              WHERE num_credito = cNumCredito
                AND empresa     = cEmpresa;
           
            LET iContCorte = iContCorte + 1;

            IF iContCorte = 30000 THEN
                LET iContCorte = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
            END IF;
    END IF;

-- *******************************************************
-- GUARDA SALDOS FIN DE DIA                              *
-- *******************************************************

    CALL sp_actsdodiariocrd(cNumCredito,cSucursal,dSdoCapital,dMntVencido,dCapTrasNoVen,dMntVencTras,
                        (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)  
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig-dProvInt) 
                              ELSE (dSdoNoExig + dIntProvFinMes)  END), dIntVdo,
                        (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva) 
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente-dProvIva) 
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END),
                        dIvaIntVencido,0,0,dMontofinanciado,dtFechaHoy) 
     RETURNING cCodRet;

        IF (cCodRet <> "000") THEN
             LET cCodRet     = "000002";
             LET cMensajeRet = "Error al grabar en tabla saldos diarios";
             RETURN cCodRet, cMensajeRet;
        END IF;

-- *******************************************************
-- FIN DEL PROCESO                                       *
-- *******************************************************

        COMMIT WORK;
		LET cBegin = "N";
		
--FMV 25abr13: Calcula indicadores para los prestamos por sus dias de atraso en vencidos
--FMV 30may13: Actualizacion de indicadores al final del cambio de estatus de vencidos a vigentes
    IF (dtFechaHoy = dtFechaFinMes) THEN
        IF ((cStatusCred = 'AA') OR (cStatusCred = 'VP' and iNumVdos <= 0)) THEN         
            LET vdias_atraso = 0;
        ELSE
            LET vdias_atraso = (dtFechaFinMes - nvl(iFechaVencto,dtFechaFinMes) + 1);
        END IF;
       
         UPDATE "informix".sd_indicador_cred_crd 
            SET dias_atraso   = vdias_atraso,
                fecha_ultimo_pago = vf_fecha_ult_pago,
                fecha_ultimo_pago_h = vf_fecha_ult_pago
          WHERE empresa = cEmpresa
            AND num_credito = cNumCredito;
			

    END IF; --(dtFechaHoy = dtFechaFinMes)
	
-- *******************************************************
-- 	RQM 09 473: TRIAD	                                 *
-- *******************************************************	
	LET vSdoTotLiquidar 	= dSdoCapInso + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig-dProvInt) 
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente-dProvIva) 
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido;
							  
	LET vPagoMinimo 	    = dMontofinanciado + 
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig-dProvInt) 
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente-dProvIva)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido;
							  
	LET vSdoTotVencido 		=  dMntVencido + dMntVencTras +
	                          (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
                              WHEN cIdProc2 = "F" THEN (dSdoNoExig-dProvInt) 
                              ELSE (dSdoNoExig + dIntProvFinMes)  END) + 
							  dIntVdo +
							  (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dIvaIntVigente+dProvIva)
                              WHEN cIdProc2 = "F" THEN (dIvaIntVigente-dProvIva)
                              ELSE (dIvaIntVigente + dIvaProvFinMes) END) +
							  dIvaIntVencido;
	
	-- Actualizacion DIARIA.
	UPDATE "informix".sd_indicador_cred_crd
		SET sdo_tot_liquidar 	= vSdoTotLiquidar,
			pago_minimo 		= vPagoMinimo,
			sdo_tot_vencido 	= vSdoTotVencido,
			saldo_maximo_hist   = CASE WHEN(vSdoTotLiquidar > NVL(saldo_maximo_hist,0)) THEN dSdoCapInso ELSE NVL(saldo_maximo_hist,0) END
	WHERE 	empresa				= cEmpresa
	AND 	num_credito 		= cNumCredito;

	--Actualizacion al CORTE.
	IF cIdProc3 = "M" THEN 
		
		UPDATE "informix".sd_indicador_cred_crd
		SET num_vencidos_ch 	= CASE WHEN num_vencidos_ch IS NULL OR num_vencidos_ch = '' THEN 0 ELSE iNumVdos END,
			sdo_tot_liquidar_ch = vSdoTotLiquidar,
			pago_minimo_ch  	= vPagoMinimo,
			intereses_periodo_ch = (CASE WHEN cIdProc1 = "C" AND cIdProc2 = "" THEN (dSdoNoExig + dSdoInt)
									WHEN cIdProc2 = "F" THEN (dSdoNoExig-dProvInt) 
									ELSE (dSdoNoExig + dIntProvFinMes)  END),
			sdo_tot_vencido_ch 	= vSdoTotVencido,
			fecha_primera_mora  = CASE WHEN fecha_primera_mora IS NULL OR fecha_primera_mora = '' THEN iFechaVencto ELSE fecha_primera_mora END,
			fecha_ultima_mora	= CASE WHEN iFechaVencto IS NOT NULL THEN iFechaVencto ELSE fecha_ultima_mora END,
			max_mora_hist       = CASE WHEN iNumVdos > NVL(max_mora_hist,0) THEN iNumVdos ELSE NVL(max_mora_hist,0) END
		WHERE empresa			= cEmpresa
		AND num_credito 		= cNumCredito;
	END IF;	

	--ActualizaciÃÂ³n a FIN DE MES.
	IF cIdProc1 = "C" THEN
		UPDATE "informix".sd_indicador_cred_crd 
		SET sdo_tot_liquidar_h = vSdoTotLiquidar,
		pago_minimo_h 		   = vPagoMinimo,
		sdo_tot_vencido_h 	   = vSdoTotVencido
		WHERE empresa = cEmpresa
		AND num_credito = cNumCredito;
    END IF;
	-- RQM 09 473: TRIAD - FIN	
	
END FOREACH;


    IF iContCorte > 0 THEN
       UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_movdiacrd;
    END IF;

   LET cCodRet = "000";
   LET cMensajeRet = "PROCESO CONCLUIDO";

    UPDATE "informix".sd_contproc
       SET status_proc = "F",
           hora_fin    = CURRENT,
           cod_ret     = cCodRet,
           mensaje     = cMensajeRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierreReesDia"
       AND fecha       = dtFechaHoy;

    UPDATE bdinteg:sx_contproc
       SET status_proc = "F",
           hora_fin    = CURRENT,
           codret      = cCodRet
     WHERE empresa     = cEmpresa
       AND proceso     = "CierreReesDia"
       AND fecha       = dtFechaHoy;

	   IF cBanTemp = 'S' THEN
	       DROP TABLE tmp_sucursales_pp;
	       LET cBanTemp ='N';
	   END IF;

 RETURN cCodRet,cMensajeRet;
 
END;
END PROCEDURE;