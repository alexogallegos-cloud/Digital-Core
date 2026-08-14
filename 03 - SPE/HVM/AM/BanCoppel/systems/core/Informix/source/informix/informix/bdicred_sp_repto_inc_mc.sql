CREATE PROCEDURE "informix".sp_repto_inc_mc(pEmpresa CHAR(3), pPeriodoIni DATE, pPeriodoFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(6)        AS codigo_retorno,
			  VARCHAR(80,1)  AS mensaje_retorno,
			  DATE           AS fecha_origen,
			  VARCHAR(20,1)  AS num_solicitud,
			  CHAR(1)        AS origen,
			  VARCHAR(20,1)  AS num_cliente,
			  VARCHAR(110,1) AS nombre,
			  DECIMAL(18,2)  AS lin_cred_actual,
			  DECIMAL(18,2)  AS lin_cred_sugerida,
			  DECIMAL(18,2)  AS porcentaje,
			  CHAR(2)        AS status,
			  CHAR(8)        AS ejecutivo_uno,
			  CHAR(8)        AS ejecutivo_dos,
			  CHAR(8)        AS ejecutivo_tres,
			  VARCHAR(120,1) AS motivo,
			  INTEGER        AS num_registros;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6);
DEFINE cMensajeRet      CHAR(80);
DEFINE cEmpresaAux         CHAR(3);
DEFINE dFechaOrigen        DATE;
DEFINE vNumSolicitud       VARCHAR(20,1);
DEFINE cOrigen             CHAR(1);
DEFINE vNumCte             VARCHAR(20,1);
DEFINE vNomCte             VARCHAR(110,1);
DEFINE dcLinCredActual     DECIMAL(18,2);
DEFINE dcLinCredSugerida   DECIMAL(18,2);
DEFINE dcPorcentaje        DECIMAL(18,2);
DEFINE cStatus             CHAR(2);
DEFINE cEjecutivo1         CHAR(8);
DEFINE cEjecutivo2         CHAR(8);
DEFINE cEjecutivo3         CHAR(8);
DEFINE cMotivo             VARCHAR(120,1);
DEFINE iAux                INTEGER;
DEFINE iDias               INTEGER;
LET iSqlErr      	    = 0;
LET  iIsamErr           = 0;
LET  cErrorInfo         = '';
LET  cCodRet            = '000000';
LET  cMensajeRet        = 'Se realizo la consulta correctamente';
LET cEmpresaAux         = '';
LET dFechaOrigen        = DATE(1);
LET vNumSolicitud       = '';
LET cOrigen             = '';
LET vNumCte             = '';
LET vNomCte             = '';
LET dcLinCredActual     = 0;
LET dcLinCredSugerida   = 0;
LET dcPorcentaje        = 0;
LET cStatus             = '';
LET cEjecutivo1         = '';
LET cEjecutivo2         = '';
LET cEjecutivo3         = '';
LET cMotivo             = '';
LET iAux                = 0;
LET iDias               = 0;
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
   END IF;
END EXCEPTION;
 --SET DEBUG FILE TO '/informix/sp_repto_inc_mc.out';
 --TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 5;
SELECT empresa
  INTO cEmpresaAux
  FROM bdinteg:"informix".si_empresas
 WHERE empresa = pEmpresa;
IF TRIM(NVL(cEmpresaAux,'')) = '' THEN
	LET cCodRet     = '000001';
    LET cMensajeRet = 'La empresa indicada no es valida';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
IF NVL(pPeriodoIni,DATE(1)) = DATE(1) OR NVL(pPeriodoFin,DATE(1)) = DATE(1) THEN
	LET cCodRet     = '000002';
    LET cMensajeRet = 'El periodo indicado no es valido';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
IF NVL(pPeriodoIni,DATE(1)) >  NVL(pPeriodoFin,DATE(1)) THEN
	LET cCodRet     = '000003';
    LET cMensajeRet = 'El periodo indicado no es correcto';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
LET iDias = NVL(pPeriodoFin,DATE(1)) - NVL(pPeriodoIni,DATE(1));
IF  iDias > 31 THEN
	LET cCodRet     = '000004';
    LET cMensajeRet = 'El periodo de consulta indicado no es valido';
    RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
    SELECT COUNT(a.num_solicitud)
	  INTO iAux
	  FROM "informix".sd_bitacora_aumlincred a
INNER JOIN bdinteg:"informix".si_cliente cte ON cte.empresa ='001' AND cte.numcte =a.numcte
INNER JOIN "informix".sd_historica_cac_aumlincred h1 ON h1.solicitud = a.num_solicitud AND h1.fecha_insert = a.fecha_insert AND h1.puesto = '01'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h2 ON h2.solicitud = a.num_solicitud AND h2.fecha_insert = a.fecha_insert AND h2.puesto = '02'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h3 ON h3.solicitud = a.num_solicitud AND h3.fecha_insert = a.fecha_insert AND h3.puesto = '03'
     WHERE a.empresa = pEmpresa
       AND num_solicitud > ''
       AND a.fecha_insert BETWEEN pPeriodoIni AND pPeriodoFin
       AND a.status IN ('RT','CM','AP')
       AND a.origen = 'S';
IF iAux < 1 THEN
      LET cCodRet     = '000005';
      LET cMensajeRet = 'No hay datos de consulta para el filtro indicado';
      RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0);
END IF;
FOREACH WITH HOLD
	SELECT SKIP pRegistros FIRST pRecuperacion
	       a.fecha_insert, TRIM(a.num_solicitud), TRIM(a.origen), TRIM(a.numcte),
		   TRIM(NVL(cte.nombre1, ''))||' '||TRIM(NVL(cte.nombre2,''))||' '||TRIM(NVL(cte.apell_paterno, ''))||' '||TRIM(NVL(cte.apell_materno, '')),
		   NVL(a.lincred_actual,0), NVL(a.lincred_sugerida,0),
		   CASE WHEN (a.lincred_sugerida - a.lincred_actual) > 0 THEN ROUND(((a.lincred_sugerida - a.lincred_actual) / a.lincred_sugerida) * 100) ELSE 0 END CASE,
		   TRIM(a.status), TRIM(h1.ejecutivo), TRIM(h2.ejecutivo), TRIM(h3.ejecutivo),
		   CASE WHEN status <> "AP" THEN  (SELECT descripcion FROM bdicred:"informix".sd_causas_aumlincred WHERE status = a.status AND causa_status = a.causa_status) ELSE '' END CASE
	  INTO dFechaOrigen, vNumSolicitud, cOrigen, vNumCte, vNomCte, dcLinCredActual, dcLinCredSugerida,
		   dcPorcentaje, cStatus, cEjecutivo1, cEjecutivo2, cEjecutivo3, cMotivo
	  FROM "informix".sd_bitacora_aumlincred a
INNER JOIN bdinteg:"informix".si_cliente cte ON cte.empresa ='001' AND cte.numcte =a.numcte
INNER JOIN "informix".sd_historica_cac_aumlincred h1 ON h1.solicitud = a.num_solicitud AND h1.fecha_insert = a.fecha_insert AND h1.puesto = '01'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h2 ON h2.solicitud = a.num_solicitud AND h2.fecha_insert = a.fecha_insert AND h2.puesto = '02'
 LEFT JOIN "informix".sd_historica_cac_aumlincred h3 ON h3.solicitud = a.num_solicitud AND h3.fecha_insert = a.fecha_insert AND h3.puesto = '03'
     WHERE a.empresa = pEmpresa
       AND num_solicitud > ''
       AND a.fecha_insert BETWEEN pPeriodoIni AND pPeriodoFin
       AND a.status IN ('RT','CM','AP')
       AND a.origen = 'S'
	   ORDER BY a.fecha_insert

	   RETURN NVL(cCodRet,''), NVL(cMensajeRet,''),NVL(dFechaOrigen,DATE(1)), NVL(vNumSolicitud,''), NVL(cOrigen,''), NVL(vNumCte,''), NVL(vNomCte,''), NVL(dcLinCredActual,0), NVL(dcLinCredSugerida,0), NVL(dcPorcentaje,0), NVL(cStatus,''), NVL(cEjecutivo1,''), NVL(cEjecutivo2,''), NVL(cEjecutivo3,''), NVL(cMotivo,''), NVL(iAux,0)  WITH RESUME;
END FOREACH;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para reporte mensual',
'de incrementos via web',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 03/Febrero/2015',
'BD    : BDICRED';

CREATE PROCEDURE "informix".movimientos_edoctacrd_pp(cEmpresa CHAR(3), cNumCredito CHAR(20), dFechaEmision DATE,sNumRegistros SMALLINT)

    RETURNING CHAR(5), DATE, CHAR(20), SMALLINT, SMALLINT, DATE, CHAR(50),DECIMAL(14,2), DECIMAL(14,2);


    -- DECLARACION DE VARIABLES --
    DEFINE sSqlErr SMALLINT;
    DEFINE cCodRet CHAR(5);
    DEFINE cNumeroCredito CHAR(20);
    DEFINE v_maximo SMALLINT;
    DEFINE v_contador SMALLINT;
    DEFINE v_fecha_mov_aux DATE;
------------------------------------------------
    DEFINE v_concepto        CHAR(50);
    DEFINE v_cargos          DECIMAL(14,2);
    DEFINE v_abonos          DECIMAL(14,2);
    DEFINE v_monto_det       DECIMAL(14,2);
    DEFINE v_naturaleza      CHAR (1);
    DEFINE v_cod_ref         INTEGER;
    DEFINE v_cod_fun         CHAR(3);
    DEFINE v_descripcion_det CHAR(255);
    DEFINE v_num_pago_am     INTEGER;
    DEFINE v_plazo           INTEGER;  
    DEFINE v_num_producto    CHAR(4);
    DEFINE vfechacentral     DATE;
    DEFINE v_periodo_tc_ini  DATE;		
    DEFINE v_periodo_tc_fin  DATE;		
    DEFINE v_cod_ret_otro	 CHAR(5);
    DEFINE v_periodo_anterior DATE;
    DEFINE v_dias_periodo_tc INTEGER;
    DEFINE v_fecha_mora DATE;
    define vfechaapertura date;
    define vfechamovimiento date;



    -- INICIALIZACION DE VARIABLES --
    LET sSqlErr          = 0;
    LET cCodRet          = '000';
--    LET dFechaDeEmision = '';
    LET cNumeroCredito   = '';
    LET v_maximo         = 0;
    LET v_contador       = 0;
    -----------------------------------------
    LET v_cargos         = 0;
    LET v_abonos         = 0;
    LET v_monto_det      = 0;
    LET v_naturaleza     = "";
    LET v_cod_ref        = 0;
    LET v_cod_fun        = "";
    LET  v_concepto      = ""; 
    LET v_descripcion_det = "";
    LET v_num_pago_am    = 0;
    LET v_fecha_mov_aux  = DATE(1); 
    LET v_plazo          = 0;
    LET v_num_producto   = "";
    LET vfechacentral    = DATE(1);
    LET v_periodo_tc_ini    = " ";		
    LET v_periodo_tc_fin    = " ";		
    LET v_cod_ret_otro      = "000";	
    LET v_periodo_anterior  = " ";
    LET v_dias_periodo_tc 	= 0;
    LET v_fecha_mora = DATE(1);
    let vfechaapertura = DATE(1); 
    let vfechamovimiento = DATE(1);   


--    SET DEBUG FILE TO "/pisa/leo/detalle_movs_edoctacrd.out";
--    TRACE ON;


    BEGIN
        ON EXCEPTION SET sSqlErr
            LET cCodRet = sSqlErr;
            RETURN cCodRet, dFechaEmision, cNumeroCredito, v_maximo, v_contador, v_fecha_mov_aux,
                   v_concepto,v_cargos,v_abonos;
        END EXCEPTION;


        SELECT num_producto,plazo,fecha_apertura
          INTO v_num_producto,v_plazo, vfechaapertura
          FROM "informix".sd_maecredcrd
         WHERE empresa = cEmpresa
           AND num_credito = cNumCredito;
         

        SELECT fecha_hoy INTO vfechacentral
        FROM bdicred:sd_fechas;
--          LET vfechacentral = mdy('04','02','2011');


            IF (vfechacentral <= dFechaEmision) then
                EXECUTE PROCEDURE sp_mes_siguiente(dFechaEmision,-1,DAY(dFechaEmision)) 
                INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
                LET v_periodo_tc_ini = v_periodo_anterior + 1 units day;
                LET v_periodo_tc_fin = vfechacentral;
            ELIF (vfechacentral >= dFechaEmision) then  
                let v_periodo_tc_ini = dFechaEmision + 1 units day;
                let v_periodo_tc_fin = vfechacentral;
            ELSE
                LET cCodRet = "001";
                RETURN cCodRet, dFechaEmision, NVL(cNumCredito, ""), NVL(v_maximo, 0), NVL(v_contador, 0),
                       NVL(v_fecha_mov_aux, ""), NVL(v_descripcion_det, 0), NVL(v_cargos, 0), NVL(v_abonos, 0)
                  WITH RESUME;
               
            END IF;

            -- Generación de los Detalles de Movimientos del Estado de Cuenta
			-- AAME 20150430 RQM 10 550 Se contemplan los dos nuevos productos de prestamo para que se muestre los movimientos
            IF v_num_producto IN ('6300','7600','7700') THEN

                if (date(v_periodo_tc_ini - 1 UNITS MONTH) = vfechaapertura) then 
                    let v_periodo_tc_ini = date(v_periodo_tc_ini - 1 UNITS MONTH);
                else
                    let v_periodo_tc_ini = date(v_periodo_tc_ini - 1 UNITS MONTH + 1 units day);
                END IF;

                FOREACH
                    SELECT lpad(month(a.fecha_mov),2,0)||'/'||
                           lpad(day(a.fecha_mov),2,0)||'/'|| lpad(year(a.fecha_mov),4,0),
                           a.referencia,b.descripcion,a.monto,c.naturaleza,a.codigo_fun,a.codigo_ref, fecha_mov
                    INTO v_fecha_mov_aux,
                         v_concepto,
                         v_descripcion_det,
                         v_monto_det,
                         v_naturaleza,
                         v_cod_fun,
                         v_cod_ref,
                         vfechamovimiento
                         FROM "informix".sd_movhiscrd a,
                          "informix".sd_transfun b,
                          bdinteg:si_transacc  c,
                          "informix".sd_definicion d
                    WHERE a.codigo_fun = b.codigo_fun 
                      AND a.codigo_ref  = b.codigo_ref
                      AND c.numero = b.transacc 
                      AND c.se_emite_edocta = "S"
                      AND a.fecha_mov  between v_periodo_tc_ini and v_periodo_tc_fin
    --                  WHEN date(v_periodo_tc_ini - 1 UNITS MONTH) = (select fecha_apertura from bdicred:sd_maecredcrd where a.empresa = empresa  and a.num_credito = num_credito)
    --                  THEN date(v_periodo_tc_ini - 1 UNITS MONTH)
    --                  ELSE date(v_periodo_tc_ini - 1 UNITS MONTH + 1 units day) end
    --                  AND a.fecha_mov <= v_periodo_tc_fin
                      AND a.num_credito = cNumCredito
                      AND a.reversado = "N"
                      AND a.num_producto = v_num_producto
                      AND a.num_producto = d.num_producto
--                      order by secuencia


--                if  (vfechamovimiento > v_periodo_tc_fin or vfechamovimiento < v_periodo_tc_ini) then
--                    continue foreach;
--                end if;

                LET v_contador = v_contador + 3;    

                IF v_naturaleza = "A" THEN
                    LET v_abonos = v_monto_det;
                    LET v_cargos = 0;
                ELSE
                    LET v_cargos = v_monto_det;
                    LET v_abonos = 0;
                END IF

                IF v_cod_fun in ("020","021","022","023","024","025") AND v_cod_ref = 1 THEN
                   LET v_descripcion_det = "";
                   LET v_descripcion_det = TRIM(v_concepto) || " " || v_abonos;
                   LET  v_cargos = 0;
                   LET  v_abonos = 0;

                ELIF v_cod_fun = "002" AND v_cod_ref = 66 THEN
                   LET v_descripcion_det = Trim(v_descripcion_det);

                ELIF v_cod_ref in (43,44) THEN

                ELIF v_cod_fun in ("023") AND v_cod_ref in (2,3) THEN

                     LET v_fecha_mora = v_fecha_mov_aux;
                     LET v_fecha_mov_aux = DATE(1);
                ELSE
                   LET v_fecha_mov_aux = DATE(1);
                   LET v_descripcion_det = Trim(v_descripcion_det) || " " || Trim(v_concepto) || "/" || v_plazo;
                END IF


                IF v_cod_fun = "023" and v_cod_ref = 2 THEN
                   LET v_descripcion_det = substr(Trim(v_descripcion_det),3,17);
                ELIF  v_cod_fun = "023" and v_cod_ref = 3 THEN
                    LET v_descripcion_det = substr(Trim(v_descripcion_det),3,19);
                END IF;

                IF substr(trim(v_descripcion_det),1,1) = "-" THEN
                    LET v_contador = v_contador + 1;   
                ELSE
                    LET v_maximo = v_maximo + 3;
                    LET v_contador = 0;			    
                    LET v_contador = v_contador + 1;			
                END IF;                


                RETURN cCodRet, dFechaEmision, NVL(cNumCredito, ""), NVL(v_maximo, 0), NVL(v_contador, 0),
                       NVL(v_fecha_mov_aux, ""), NVL(v_descripcion_det, 0), NVL(v_cargos, 0), NVL(v_abonos, 0)
                  WITH RESUME;


                LET v_fecha_mov_aux  = date(1);
                LET v_concepto       = "";
                LET v_cargos         = 0;
                LET v_abonos         = 0;

            END FOREACH
        END IF
        END;


END PROCEDURE
DOCUMENT
"Genera el Detalle de los Movimientos del Estado de Cuenta de Crédito Reestructurado",
"AUTOR: Iris Arias Zazueta",
"FECHA: 06/08/2009",
"BD: bdicred";

CREATE PROCEDURE "informix".sp_conciliarsaldoscredito_pba(cEmpresa CHAR(3),cFecha date, cTipoProd integer)
												
--------------------------------------------------------------------
--DOCUMENTACIÓN
--Regresa la conciliacion de los saldos y movimientos de credito vs la balanza contable
--Realizó: Richar 
--Fecha: 06/01/2015
--------------------------------------------------------------------													
--cTipoConcil = tipo de conciliacion 1=Saldos 2 = movimientos
--cTipoProd = 1 TDC, 2 credinomina, 3 prestamos personal y 4 Reestructura

							
    --DATOS A REGRESAR---	
	RETURNING CHAR(5);	--codret
              

			  /*
			   CHAR(40),	--nomproducto
              Char(40), --Concepto
              Char(20), --Nivel contable
              Money(18,2), --Saldo Operativo
              Money(18,2), --Saldo contable
			  */
			  
	--DEFINICION DE VARIABLES--			  
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    ---------------------------
	DEFINE vNomProducto	CHAR(40);
	DEFINE vConcepto 	CHAR(40);
	DEFINE vNivelCon	CHAR(14);
	DEFINE vSaldoOpe	MONEY(18,2);
	DEFINE vSaldoCon	MONEY(18,2);
	DEFINE vDiferencia	MONEY(18,2);
	DEFINE vDiferenciaAbono	MONEY(18,2);
	DEFINE vDiferenciaCargo	MONEY(18,2);
	
	DEFINE vMesactual 	Integer;
	DEFINE vMesmodulo 	Integer;
		
	--	Variables para las cuentas ***********
	DEFINE vCtaCapVig 		Char(14);
	DEFINE vCtaCapTrans 	Char(14);
	DEFINE vCtaCapVenNoNeg 	Char(14);
	DEFINE vCtaCapVenExig	Char(14);
	DEFINE vCtaSdoFavor		Char(14);
	DEFINE vCtaIntVig		Char(14);
	DEFINE vCtaIntVenXTrans	Char(14);
	DEFINE vCtaInteresVen	Char(14);
	DEFINE vCtaIVAIntVig	Char(14);
	DEFINE vCtaIVAInteres	Char(14);
	DEFINE vCtaInteresVenOrd Char(14);
	DEFINE vCtaIVAInteresOrd Char(14);
	
	--  ***********
	DEFINE vDescripcion		Char(50);
	DEFINE vCC			  	Char(50);
	DEFINE vsdoCargos		Money(18,2);
	DEFINE vsdoAbonos		Money(18,2);
	DEFINE vSdoInicioDia	Money(18,2);
	DEFINE vSdoFinDia		Money(18,2);	
	DEFINE vSdoConta 		Money(18,2);	
	DEFINE vsdoCargosConta	Money(18,2);
	DEFINE vsdoAbonosConta	Money(18,2);
		
	--Variables para los saldos del sif
	DEFINE vSdoCapVig 		Money(18,2);
	DEFINE vSdoCapTrans  	Money(18,2);
	DEFINE vSdoCapVenNoNeg	Money(18,2);
	DEFINE vSdoCapVenExig	Money(18,2);
	DEFINE vSdoSdoFavor		Money(18,2);
	DEFINE vSdoInteresVen	Money(18,2);
	DEFINE vSdoIVAInteres	Money(18,2);
	
	
	--Variables para los saldos del sif Abono
	DEFINE vSdoCapVig_a 		Money(18,2);
	DEFINE vSdoCapTrans_a  	Money(18,2);
	DEFINE vSdoCapVenNoNeg_a	Money(18,2);
	DEFINE vSdoCapVenExig_a	Money(18,2);
	DEFINE vSdoSdoFavor_a		Money(18,2);
	DEFINE vSdoInteresVen_a	Money(18,2);
	DEFINE vSdoIVAInteres_a	Money(18,2);
	
	
	--Variables para los saldos de contabilidad	
	DEFINE vSdoCapVigCont 		Money(18,2);
	DEFINE vSdoCapTransCont  	Money(18,2);
	DEFINE vSdoCapVenNoNegCont	Money(18,2);
	DEFINE vSdoCapVenExigCont	Money(18,2);
	DEFINE vSdoSdoFavorCont		Money(18,2);
	DEFINE vSdoInteresVenCont	Money(18,2);
	DEFINE vSdoIVAInteresCont	Money(18,2);
	
	DEFINE vSdoCapVigCont_a 		Money(18,2);
	DEFINE vSdoCapTransCont_a  		Money(18,2);
	DEFINE vSdoCapVenNoNegCont_a	Money(18,2);
	DEFINE vSdoCapVenExigCont_a		Money(18,2);
	DEFINE vSdoSdoFavorCont_a		Money(18,2);
	DEFINE vSdoInteresVenCont_a		Money(18,2);
	DEFINE vSdoIVAInteresCont_a		Money(18,2);	
	
	--Variables para la naturaleza
	DEFINE vSdoCapVigNat 		CHAR(1);
	DEFINE vSdoCapTransNat  	CHAR(1);
	DEFINE vSdoCapVenNoNegNat	CHAR(1);
	DEFINE vSdoCapVenExigNat	CHAR(1);
	DEFINE vSdoSdoFavorNat		CHAR(1);
	DEFINE vSdoInteresVenNat	CHAR(1);
	DEFINE vSdoIVAInteresNat	CHAR(1);
	

	--Banderas
	DEFINE v_paso				varchar(50);
	
	--INICIALIZACION DE VARIABLES--
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET vDiferencia=0;
	LET vDiferenciaAbono=0;
	LET vDiferenciaCargo=0;
	LET vsdoAbonos=0;
	LET vsdoCargos=0;
	LET vsdoAbonosConta=0;
	LET vsdoCargosConta=0;
	
	LET vDescripcion='';	
		
	--LET vMesactual = month(today); --Producción
	LET vMesactual = '01'; --Desarrollo
	LET vMesmodulo = month(cFecha);
	
	--Definimos todas las cuentas contables de TDC
	
	LET vCtaCapVig = '13110101010032';
	LET vCtaCapTrans = '13110101030032';
	LET vCtaCapVenNoNeg = '13610101010232';
	LET vCtaCapVenExig = '13610101010132';
	LET vCtaSdoFavor = '24029014000032';
    LET vCtaIntVig = '13110101020032';
	LET vCtaIntVenXTrans = '13110101040032';
	LET vCtaInteresVen = '13610101020132';
	LET vCtaIVAIntVig ='14020305110132'; --Iva de Interes Vigente
	LET vCtaInteresVenOrd = '77106101010132';
	LET vCtaIVAInteresOrd = '78376101010132';
		
				
	LET vSdoCapVig =0;
	LET vSdoCapTrans =0;
	LET vSdoCapVenNoNeg =0;
	LET vSdoCapVenExig =0;
	LET vSdoSdoFavor =0;
	LET vSdoInteresVen =0;
	LET vSdoIVAInteres =0;
	
	LET vSdoCapVig_a =0;
	LET vSdoCapTrans_a =0;
	LET vSdoCapVenNoNeg_a =0;
	LET vSdoCapVenExig_a =0;
	LET vSdoSdoFavor_a =0;
	LET vSdoInteresVen_a =0;
	LET vSdoIVAInteres_a =0;
	
	LET vSdoCapVigCont =0;
	LET vSdoCapTransCont =0;
	LET vSdoCapVenNoNegCont =0;
	LET vSdoCapVenExigCont =0;
	LET vSdoSdoFavorCont =0;
	LET vSdoInteresVenCont =0;
	LET vSdoIVAInteresCont =0;
	
	LET vSdoCapVigCont_a =0;
	LET vSdoCapTransCont_a =0;
	LET vSdoCapVenNoNegCont_a =0;
	LET vSdoCapVenExigCont_a =0;
	LET vSdoSdoFavorCont_a =0;
	LET vSdoInteresVenCont_a =0;
	LET vSdoIVAInteresCont_a =0;
	
	
	LET v_paso ='';
		
	--SET DEBUG FILE TO "/home/sysifx/sp_conciliarsaldoscredito.out";
	SET DEBUG FILE TO "/resplogifx/P-BD-20150601-01/bdicred/spl/sp_conciliarsaldoscredito.trc";
	TRACE ON;	

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;	

	-- INICIO DEL PROCEDIMIENTO	 
	BEGIN
	-- MANEJADOR DE ERRORES	
		ON EXCEPTION SET iSqlErr
			--LET cCodRet = v_paso;
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--Borramos la tabla donde se va guardando la informacion para el reporte
		delete from sd_conciliacredito;
		
		
				--Valida parámetros de entrada
	IF (cTipoProd=1) THEN		--Tarjeta de credito		
		
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='TDC' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaSdoFavor,vCtaIntVig,vCtaIntVenXTrans,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;
					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Tarjeta de credito',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;
				
				
				LET cCodRet = '00000';
			
				RETURN cCodRet	WITH RESUME;		
				
				
		ElIF (cTipoProd=2) THEN		--Credinomina
		
				LET vCtaCapVig = '13110203010032';
				LET vCtaCapTrans = '13110203030032';
				LET vCtaCapVenNoNeg = '13610203010232';
				LET vCtaCapVenExig = '13610203010132';
				LET vCtaIntVig = '13110203020032';
				LET vCtaInteresVen = '13610203020132';
				LET vCtaInteresVenOrd = '77106102030132';	
				LET vCtaIVAIntVig ='14020305110332'; --Iva de Interes	
				LET vCtaIVAInteresOrd = '78376102030132';
									
		
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='CDN' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;
					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Credinomina',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;
				
				
				LET cCodRet = '00000';
			
				RETURN cCodRet	WITH RESUME;		
				
		ElIF (cTipoProd=3) THEN		--Prestamo personal
		
				LET vCtaCapVig = '13110202010032';
				LET vCtaCapTrans = '13110202030032';
				LET vCtaCapVenNoNeg = '13610202010232';
				LET vCtaCapVenExig = '13610202010132';
				LET vCtaIntVig = '13110202020032';
				LET vCtaInteresVen = '13610202020132';
				LET vCtaInteresVenOrd = '77106102020132';	
				LET vCtaIVAIntVig ='14020305110232'; --Iva de Interes	
				LET vCtaIVAInteresOrd = '78376102020132';
											
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='PP' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Prestamo Personal',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;				
				
				LET cCodRet = '00000';			
				RETURN cCodRet	WITH RESUME;		
		
	ElIF (cTipoProd=4) THEN		--Restrucutra
		
				LET vCtaCapVig = '13110102010032';				
				LET vCtaCapVenExig = '13610102010132';
				LET vCtaCapVenNoNeg = '13610102010232';				
				LET vCtaCapTrans = '13110102030032';				
				LET vCtaIntVig = '13110102020032';				
				LET vCtaInteresVen = '13610102020032';				
				LET vCtaInteresVenOrd = '77106101020132';				
				LET vCtaIVAIntVig ='14020305110432'; --Iva de Interes					
				LET vCtaIVAInteresOrd = '78376101020132';
											
				FOREACH
				select descripcion,cc,cargos_dia,abonos_dia,saldo_inicio_dia,saldo_fin_de_dia
				into vDescripcion,vCC,vsdoCargos,vsdoAbonos,vSdoInicioDia,vSdoFinDia
				from bdicred:sd_histsdodias SDH
				left join bdicred:sd_catalogocc SDC on SDH.cc=SDC.cuentacontable
				where SDH.producto='RTC' and mes_dia=cFecha 
				and cc in (vCtaCapVig,vCtaCapTrans,vCtaCapVenNoNeg,vCtaCapVenExig,vCtaIntVig,vCtaInteresVen,vCtaIVAIntVig,vCtaInteresVenOrd,vCtaIVAInteresOrd)
				order by ordenar
					
					  if vMesactual=vMesmodulo then	--Si es el mismo mes buscar en la tabla co_sdodias
					  
						--Sacamos los saldos para la cuenta diario
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_sdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  else --Si es diferente buscar en la tabla historica
					  
						  --Sacamos los saldos para cada uno de la historica si el mes no es el actual
						  select  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then saldo_fin_de_dia else 0 end),0) as Sdo_Cont,
    							  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then abonos_dia  else 0 end),0) as Sdo_Cap_Vig_Cont_A,
								  nvl(sum(Case when trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector)=vCC then cargos_dia else 0 end),0) as Sdo_Cap_Vig_Cont
						  into vSdoConta,vsdoAbonosConta,vsdoCargosConta
						  from bdicont:co_histsdodias
						  where trim(ccmayor)||trim(ccsub)||trim(ccsubsub)||trim(ccssubsub)||trim(ccsssubsub)||trim(sector) = (vCC)
						  And mes_dia=cFecha;						  
						  
					  End if;
					  
					  -- Capital vigente
					  
					  if vSdoFinDia<0 then
						LET vDiferencia = (vSdoFinDia * -1) - vSdoConta;
					  elif vSdoConta<0 then
						LET vDiferencia = vSdoFinDia - (vSdoConta * -1);
					  else
						LET vDiferencia = vSdoFinDia - vSdoConta;
					  End if;
					  
					  
					  LET vDiferenciaAbono = vsdoAbonos -  vsdoAbonosConta;
					  LET vDiferenciaCargo = vsdoCargos -  vsdoCargosConta;
					  Insert into bdicred:sd_conciliacredito (producto,concepto,nivelcontable,abono_operativo,cargo_operativo,sdoperativo,abono_conta,cargo_conta,sdocontable,sdodif,abonos_dif,cargos_dif,fechasys)
							values('Reestructura',vDescripcion,vCC,vsdoAbonos,vsdoCargos,vSdoFinDia,vsdoAbonosConta,vsdoCargosConta,vSdoConta,vDiferencia,vDiferenciaAbono,vDiferenciaCargo,today);
						
														
				End FOREACH;
				
				
				LET cCodRet = '00000';
			
				RETURN cCodRet	WITH RESUME;
		
		ELSE
		
			--Parámetro de entrada vacío
			LET cCodRet = '00001';
			
				RETURN cCodRet					   					   
				  WITH RESUME;
			
		END IF;
		



	END;
	
END PROCEDURE;