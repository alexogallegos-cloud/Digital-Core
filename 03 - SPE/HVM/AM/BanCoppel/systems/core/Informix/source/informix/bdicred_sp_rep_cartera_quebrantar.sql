CREATE PROCEDURE "informix".sp_rep_cartera_quebrantar(pEmpresa char(3))
returning char(06) AS resultado,char(80) AS mensaje;

DEFINE cMensajeRet  CHAR(80);
DEFINE cSucursal, cUltMov, cNumSucursal, cNumproducto char(4);
DEFINE cNumCredito, cNumCte, cNumCredito_rees, cNumSolicitud, cApellido1,cApellido2,cNombre1,cNombre2,cCurp, cNumTarjeta, cRefCoppel, cCreditoExterno, cCreditoGrupo char(20);
DEFINE pPagos, pNum_Vencidos, cdiacorte Smallint;
DEFINE cRfc, cTelefono, cTelTrab, cExtTrab char(13);
DEFINE cApellidoCasada char(26);
DEFINE cSector,cEdoCivil char(2);
DEFINE dFechaNac date;
DEFINE cSexo char(1);
DEFINE cNumIdentificacion char(30);
DEFINE cEmail char(60);
DEFINE cTipoIdentificacion char(40);
DEFINE cNacionalidad char(15);
DEFINE cNumEstado,cNumCiudad integer;
DEFINE cPoblacion, cComplemento,cDescripcion, cDescripPermTrabajo char(80);
DEFINE cNumColonia, cNumCalle integer;
DEFINE cNumExterior, cNumInterior char(10);
DEFINE cCodPostal, cCodPostalTrab char(5);
DEFINE cPuntoCardinal char(1);
DEFINE iManzana, iandador, iEtapa, iLote, iEdificio, iEntrada, iManzanaTrab, iandadorTrab, iEtapaTrab, iLoteTrab, iEdificioTrab, iEntradaTrab, iContadorRegistros integer;
DEFINE cDepartamento, cDepartamentoTrab char(6);
DEFINE cEntreCalles, cEntreCallesTrab char(40);
DEFINE sOtros, sElementoRes, sElemResTrabajo, iOtrosTrab, sCausa, iContador, sNumVencidos smallint;
DEFINE mIngresoMensual money(14,2);
DEFINE cPuesto char(3);
DEFINE cLugarTrabajo char(25);
DEFINE cActividad char(45);
--Domicilio de Trabajo
DEFINE cNumEstadoTrab, cNumCiudadTrab, cNumColoniaTrab, cNumCalleTrab integer;
DEFINE cPoblacionTrab, cComplementoTrab char(80);
DEFINE cNumExteriorTrab, cNumInteriorTrab char(10);
DEFINE cPuntoCardinalTrab,cSituacion, cEvaluacionCC,cBegin char(1);
--PENDIENTES DE GENERAR
DEFINE cExisteCC char(2);
DEFINE dFechaMovtoSit, dFechaUltPago, dFechaHoy, dFechaAnt, dFechaCapAux, dFechaUltDisp, dFechaUltMov date;
DEFINE iMaxSecDisp, iCuantosDisp, iRef, cMesesVencidos, iCuantosPagos Integer;
DEFINE fIntenPago, fIntenPago_pres, fMontoUltDisp, fMontoComi, fAbonoMensual, fSaldoMesAnt, mMonto, mMontoInteresCap, mMontoIvaIntCap, fSaldoMesActual decimal(14,2);
DEFINE cFolioSuc char(16);
DEFINE fMontoUltMov, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fMontoPago decimal(14,2);
DEFINE mIntVencido_bal, mIvaIntVencido_bal decimal(14,2);
DEFINE SQL_ERR, ISAM_ERR INTEGER;
DEFINE ERROR_INFO,P_MENSAJE VARCHAR(80);
DEFINE P_COD_RET VARCHAR(6);
--Archivo
DEFINE cNombreArchivo1,cNombreArchivo2,cNombreArchivo3,cNombreArchivo4 CHAR(50);
DEFINE cSql            CHAR(2034);
-- jom ini
define cNumRegTotal_TC, cNumRegTotal_TCO, cNumRegTotal_TGC, cNumRegTotal_TCP, cNumRegTotal_Rees, cNumRegTotal_Pres, cMesesHistoria, cNumRegTotal_cnom,cNumRegTotal_Pres18,cNumRegTotal_Pres24,cNumRegTotal_Presflex integer;
define sSaldoActTotal_TC, sSaldoActTotal_TCO, sSaldoActTotal_TGC, sSaldoActTotal_TCP, sSaldoActTotal_Rees, sSaldoActTotal_Pres, sSaldoActTotal_cnom, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado, mIvaIntMoraTotal, pMonto_otorgado,sSaldoActTotal_Pres18,sSaldoActTotal_Pres24,sSaldoActTotal_Presflex   decimal(14,2);
define sFechadeCorte, cFechaApertura, fecha_mesant, dfechapridiames, dfechaultdiames date;
-- jom fin
define var_rga char(05);
define Ccodcaract char(03);
DEFINE cTelefonoCel char(13);
DEFINE cSituacionPago decimal(5,2);
DEFINE cEvaluacc, cGrupo, cTipoGrupo char(01);
DEFINE vmonto50, vmonto4meses,vsdo_cap_insoluto decimal(18,2);
DEFINE existe, utili_80, motivoexclusion  smallint;
DEFINE dFechaAlta date;
DEFINE cStatusCred CHAR(02);
DEFINE dSdoCapital decimal(18,2);
DEFINE dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra decimal(18,2);
DEFINE dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra,vfmov date;

define vintbal         money(14,2);
define vivaintbal      money(14,2);
define vintorden       money(14,2);
define vivaintorden    money(14,2);    
DEFINE v_sql           VARCHAR(250);
DEFINE lname           CHAR(50);	
Define	vlCreditoBal	char(20);
-- RQM 09 441
DEFINE	vEnvioMC		smallint;
DEFINE	vAtendidaMC		smallint;
DEFINE	vRespuestaMc	char(1);
--IPCB 062018/RQM 09 484
DEFINE cflag_cteconf   CHAR(1); 
DEFINE dfec_ult_pag	   DATE;	
DEFINE vciudadcop      integer;
DEFINE vcoloniacop     integer;
DEFINE vciudadbanco	   integer;
DEFINE vciudadtmp	   integer;
DEFINE vcoloniatmp	   integer;
DEFINE i integer;
DEFINE psaldoInteresApoyo DECIMAL(14,2);
DEFINE psaldoIvaApoyo 	DECIMAL(14,2);
DEFINE iCant_VtaProgApoyo INTEGER;
DEFINE iCant_VtaProgApoyo_his  INTEGER;
DEFINE cNum_credito_VtaProgApoyo  CHAR(20);
DEFINE cNum_credito_VtaProgApoyo_his  CHAR(20);

DEFINE cAct                     INTEGER;
DEFINE cAtr                     INTEGER;
DEFINE v_fecha_vencido  DATE;
DEFINE v_dias_vencido   INTEGER;    



--IPCB 062018/RQM 09 484
let vintbal     		=0;
let vivaintbal  		=0;
let vintorden		=0;
let	vivaintorden	=0;
let vlCreditoBal = '';
--AAME RQM 10 393 20150623 Se contemplan los 2 nuevos productos(7600,7700)
let cNumRegTotal_Pres18=0;
let cNumRegTotal_Pres24=0;
let cNumRegTotal_Presflex=0; 
let sSaldoActTotal_Pres18=0;
let sSaldoActTotal_Pres24=0;
let sSaldoActTotal_Presflex=0;

-- RQM 09 441
LET vEnvioMC		= 0;
LET vAtendidaMC		= 0;
LET vRespuestaMc	= '';
--RQI CV productos (8100,7000)
LET cNumRegTotal_TCO=0;
LET cNumRegTotal_TCP=0;
LET sSaldoActTotal_TCO=0;
LET sSaldoActTotal_TCP=0; 
--(8500)
LET cNumRegTotal_TGC=0;
LET sSaldoActTotal_TGC=0;  
--IPCB 062018/RQM 09 484
LET cflag_cteconf      = ""; 
LET dfec_ult_pag	   =DATE(0);	
LET vciudadcop         = "";
LET vcoloniacop        = "";
LET vciudadbanco       = "";
LET vciudadtmp         = "";
LET vcoloniatmp		   = "";
LET i = 0;
--IPCB 062018/RQM 09 484
--- Se agregan variables para interes e iva del programa de apoyo
LET psaldoInteresApoyo = 0;
LET psaldoIvaApoyo 	= 0;
LET iCant_VtaProgApoyo = 0;
LET iCant_VtaProgApoyo_his = 0;
LET cNum_credito_VtaProgApoyo = '';
LET cNum_credito_VtaProgApoyo_his = '';


LET v_fecha_vencido  = DATE(1);
LET v_dias_vencido   =0;  
LET cAct                        = 0;
LET cAtr                        = 0;


--SET DEBUG FILE TO '/ifxsif01/PEDRO/rep_cart_quebrantar/sp_rep_cartera_quebrantar.out';
--TRACE ON;																 
 
BEGIN

	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET = SQL_ERR;
		LET P_MENSAJE = ERROR_INFO;
		IF cNumProducto IN ('6001','8100','7000','8500') then
			LET cMensajeRet = ERROR_INFO ||'ERROR en el proceso VENTA DE CARTERA TC ' || cNumCredito;
			RETURN P_COD_RET,cMensajeRet;
		ELSE
			LET cMensajeRet = ERROR_INFO ||'ERROR en el proceso VENTA DE CARTERA ' || cNumCredito_rees;
			RETURN P_COD_RET,cMensajeRet;
		END IF;
		IF cBegin = 'S' then
			RollBack WORK;
		END IF;
	END EXCEPTION;
	

LET cBegin = 'N';
LET cMensajeRet = '' ;
LET cNumProducto, cNumCredito, cNumCte, cNumCredito_rees, cNumSolicitud, cNumTarjeta, cRefCoppel, cCreditoExterno, cCreditoGrupo = '','','','', '', '', '','','';
LET cApellido1,cApellido2,cNombre1,cNombre2,cCurp = '','','','','';
--jom ini
LET cNumRegTotal_TC,sSaldoActTotal_TC,cNumRegTotal_TGC,sSaldoActTotal_TGC,cNumRegTotal_TCO,sSaldoActTotal_TCO,cNumRegTotal_TCP,sSaldoActTotal_TCP,cNumRegTotal_Rees,sSaldoActTotal_Rees,cNumRegTotal_Pres,sSaldoActTotal_Pres,cNumRegTotal_cnom,sSaldoActTotal_cnom = 0,0,0,0,0,0,0,0,0,0,0,0,0,0;
--jom fin
LET cNumSucursal, P_COD_RET = '0000', '000000';
LET pNum_Vencidos, fIntenPago, fIntenPago_pres, cdiacorte, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fSaldoMesVencido = 0,0,0,0,0,0,0,0,0,0,0,0;
LET sSaldoActTotal_TC, sSaldoActTotal_TGC, sSaldoActTotal_TCO, sSaldoActTotal_TCP, sSaldoActTotal_Rees, sSaldoActTotal_Pres, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado,mIvaIntMoraTotal, pMonto_otorgado = 0,0,0,0,0,0,0,0,0,0,0;
LET mIntVencido_bal, mIvaIntVencido_bal = 0,0;
LET Ccodcaract, cSituacion = '', '';
LET iContador,sCausa,sNumVencidos  = 0, 0, 0;
LET vmonto50, vmonto4meses,vsdo_cap_insoluto = 0.00, 0.00, 0.00;
LET existe, utili_80, motivoexclusion,dSdoCapital, fAbonoMensual = 0, 0, 0, 0, 0;
LET dFechaAlta = date(1);
let dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra =0,0,0;
let dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra, dFechaUltDisp = date(1),date(1),date(1),date(1);

set isolation to dirty read;
set lock mode to wait 3;	

	SELECT Fecha_Hoy, fecha_ant, pri_dia_mes,     ult_dia_mes
	  INTO dFechaHoy, dFechaAnt, dfechapridiames, dfechaultdiames
	  FROM bdicred:sd_fechas
	 WHERE empresa = '001';
	

	
	LET cNombreArchivo1= '/pisa/CarteraQuebrantada' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';
	LET cNombreArchivo2= '/pisa/CifrasCarteraQuebrantada' || LPAD(TRIM(MONTH(dFechaHoy)::CHAR(2)),2,'0') ||YEAR(dFechaHoy) || '.txt';

	
	BEGIN WORK;
		LET cBegin = 'S';
		DELETE FROM bdicobranza:cb_rep_cart_quebrantar_cifras WHERE fechareporte = dFechaHoy;		
	COMMIT WORK;

	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar_cifras;
	BEGIN WORK;
		DELETE FROM bdicobranza:cb_rep_cart_quebrantar WHERE fechareporte = dFechaHoy;
	COMMIT WORK;
	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar;
	BEGIN WORK;
		DELETE FROM bdicred:sd_exclusiones_ventacartera WHERE fecha_exclusion = dFechaHoy;
	COMMIT WORK;
	UPDATE statistics medium FOR table bdicred:sd_exclusiones_ventacartera;
	LET cBegin = 'N';
	
	-- SE MODIFICA QUERY PARA QUITAR BUSQUEDAS SECUENCIALES A LA TABLA sd_conceptospagomanual
	SELECT a.num_producto, a.num_credito, a.numcte, cod_caract_2,
	NVL((SELECT SUM(monto)
		--FROM bdicred:sd_movhis
		FROM bdicred:sd_movhis d, bdicred:sd_conceptospagomanual cp
		WHERE empresa = '001'
		AND a.num_credito = num_credito
		--AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
		AND d.codigo_fun = cp.cod_fun
		AND codigo_ref = 1
		AND fecha_mov >= date(MDY(MONTH(dFechaHoy),'20',YEAR(dFechaHoy)) - 1 units MONTH)
		AND reversado = 'N'),0) monto50,NVL((SELECT SUM(monto)
											FROM bdicred:sd_movhis sdm, bdicred:sd_conceptospagomanual scpg
											WHERE empresa = '001'
											AND a.num_credito = num_credito
											--AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
											AND sdm.codigo_fun = scpg.cod_fun
											AND codigo_ref = 1
											AND fecha_mov >= date(MDY(MONTH(dFechaHoy),'20',YEAR(dFechaHoy)) - 4 units MONTH)
											AND reversado = 'N'),0) monto4meses,b.mto_fin_ven_trasp, b.monto_otorgado,
		sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, 20 dia_corte, sdo_cap_insoluto 
		,'' cte_conflicto,fecha_ult_pago, b.act, 0 as atr
	FROM bdicred:sd_maecred a, bdicred:sd_maesdos b
		, bdicred:sd_maecredanexo c	
	WHERE a.empresa= '001'
	AND a.empresa = b.empresa
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito	
	AND mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060') 
	AND status_cred IN  ('BT','E2','E3')  
	--AND a.campo_trab3 = '' --FMJ DIC VENTA DE BAJA
	AND NVL(Cod_caract_2,'') = ''
	AND sdo_cap_insoluto >= 500
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND a.num_producto<> '7800' 
	INTO temp selec_credito WITH NO LOG; 

	-- agregan a la venta los clientes conflicto
	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, numcte, cod_caract_2,0,0,mto_fin_ven_trasp, b.monto_otorgado,
	sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto,'C' cte_conflicto,fecha_ult_pago, b.act, 0 as atr
	FROM bdicred:sd_maecred a,
		bdicred:sd_maesdos b,
		bdicred:sd_maecredanexo c
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.status_cred IN ('BT','E2','E3') 
	--AND a.campo_trab3 = '' --FMJ DIC VENTA DE BAJA
	AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '062')
	AND b.mto_fin_ven_trasp < (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
	AND c.fecha_ult_pago is null
	AND sdo_cap_insoluto >= 500
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	AND a.num_producto<> '7800';
	
	--CREDITOS VENTA PROGRAMA DE APOYO
	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, numcte, cod_caract_2,0,0,mto_fin_ven_trasp, b.monto_otorgado,
	sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto,'C' cte_conflicto,fecha_ult_pago, b.act, 0 as atr
	FROM bdicred:sd_maecred a,
		bdicred:sd_maesdos b,
		bdicred:sd_maecredanexo c,
		bdicred:creditos_venta_progapoyo d
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_credito = b.num_credito
	AND a.num_credito = d.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.status_cred IN  ('BT','E2','E3') 
	AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '069')---> DAR FDE ALTA PARAMETRO  CON VALOR 2
	AND sdo_cap_insoluto >= 500
	AND a.campo_trab3 <> 'INMATERIAL'
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
	
	--AAME RQM 10 393 20150623 Se contempla Prestamos(7600,7700) para los clientes Conflictos >=5 meses vdos y no tenga pagos desde su apertura
	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado,
		sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
	,'C' cte_conflicto,nvl(fecha_ult_pago,date(1)) 	fec_ult_pago, 0 as act, b.atr
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c --bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_producto IN ('6300','7600','7700','6800') ---> AGREGAR 6800    IFSR se comenta para pruebas
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.status_cred IN ('BT','E2','E3')
	--AND a.campo_trab3 = '' --FMJ DIC VENTA DE BAJA
	AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '064') 
	AND sdo_cap_insoluto >= 500
	AND c.fecha_ult_pago is null
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	AND ( DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1);

	--- CRÃDITOS VENTA PROGRAMA DE APOYO CRD PP 2021-04-08 MACF
	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado,
		sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
	,'C' cte_conflicto,nvl(fecha_ult_pago,date(1)) 	fec_ult_pago, 0 as act, b.atr
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c, --bdicred:sd_amortiza_creditocrd d
	     bdicred:creditos_venta_progapoyo d
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_producto IN ('6300','7600','7700','6800','6400') ---> AGREGAR 6800   IFSR se comenta para pruebas
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.num_credito = d.num_credito
	AND a.status_cred IN ('BT','E2','E3')
	AND b.mto_fin_ven_trasp >=  (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '069')---> DAR FDE ALTA PARAMETRO  CON VALOR 2
	AND sdo_cap_insoluto >= 500
	--AND c.fecha_ult_pago is null
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	AND ( DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1);
		
	--Primer validacion en moras como reestrutura
    INSERT INTO selec_credito
    SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp,
        b.monto_otorgado,sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
        ,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
    FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
    WHERE a.empresa = '001'
    AND a.empresa = b.empresa
    AND a.num_producto = '6011'
    AND a.num_credito = b.num_credito
    AND a.empresa = c.empresa
    AND a.num_credito = c.num_credito
    AND a.status_cred in ('BT','VP','E2','E3')
    and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
    and (b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065')
    or (TRUNC(MONTHS_BETWEEN (dFechaHoy, (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6'))))) >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065'))
    AND sdo_cap_insoluto >= 500
    AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
    AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
	
	--segunda validacion en tdc + moras consecutivas sin pago
    INSERT INTO selec_credito
    SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp,
        b.monto_otorgado,sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
        ,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
    FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
    WHERE a.empresa = '001'
    AND a.empresa = b.empresa
    AND a.num_producto = '6011'
    AND a.num_credito = b.num_credito
    AND a.empresa = c.empresa
    AND a.num_credito = c.num_credito
    AND a.status_cred in ('BT','VP','E2','E3')
    and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
    and b.mto_fin_ven_trasp >= 1
    and (select count (*) from bdicred:sd_amortiza_creditocrd where empresa=pEmpresa and num_credito = a.num_credito and num_pago = 1 and capital_status in ('2','7','6')) >= 1
    AND ((b.mto_fin_ven_trasp +
		(SELECT mto_fin_ven_trasp FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo AND fecha in (SELECT MAX (fecha) FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo))) >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065')
    or
        ((TRUNC(MONTHS_BETWEEN (dFechaHoy, (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6'))))) +
		(SELECT mto_fin_ven_trasp FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo AND fecha in (SELECT MAX (fecha) FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo))) >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065'))
    AND sdo_cap_insoluto >= 500
    AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
    AND a.num_credito not IN (SELECT num_credito FROM selec_credito);

	--tercera validacion- 2 meses consecutivos despues de un pago sumando TDC

    INSERT INTO selec_credito
    SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp,
        b.monto_otorgado,sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
        ,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
    FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
    WHERE a.empresa = '001'
    AND a.empresa = b.empresa
    AND a.num_producto = '6011'
    AND a.num_credito = b.num_credito
    AND a.empresa = c.empresa
    AND a.num_credito = c.num_credito
    AND a.status_cred = 'VP'
    and (b.mto_fin_ven_trasp >= 2
     or (TRUNC(MONTHS_BETWEEN (dFechaHoy, (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6'))))) >= 2)
    and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
    AND sdo_cap_insoluto >= 500
    AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
    AND a.num_credito not IN (SELECT num_credito FROM selec_credito);

----- CRÃDITOS VENTA PROGRAMA DE APOYO REE 2021-04-08 MACF
	INSERT INTO selec_credito
    SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp,
        b.monto_otorgado,sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
        ,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
    FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c, bdicred:creditos_venta_progapoyo d
    WHERE a.empresa = '001'
    AND a.empresa = b.empresa
    AND a.num_producto = '6011'
    AND a.num_credito = b.num_credito
    AND a.empresa = c.empresa
    AND a.num_credito = c.num_credito
	AND a.num_credito = d.num_credito
    AND a.status_cred in ('BT','VP','E2','E3')
    and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
    and (b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '069')---> DAR FDE ALTA PARAMETRO  CON VALOR 2
    or (TRUNC(MONTHS_BETWEEN (dFechaHoy, (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6'))))) >= 2)
    AND sdo_cap_insoluto >= 500
    AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
    AND a.num_credito not IN (SELECT num_credito FROM selec_credito);

/*
	--Segunda validaciÃ³n 6011
		INSERT INTO selec_credito
		SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,
			(b.mto_fin_ven_trasp +
				NVL((SELECT mto_fin_ven_trasp FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo
					AND fecha in (SELECT MAX (fecha) FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo)),0)),
			b.monto_otorgado,sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
			,'' cte_conflicto,fecha_ult_pago
		FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
		WHERE a.empresa = '001'
		AND a.empresa = b.empresa
		AND a.num_producto = '6011'
		AND a.num_credito = b.num_credito
		AND a.empresa = c.empresa
		AND a.num_credito = c.num_credito
		AND a.status_cred in ('BT','VP')
		and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
		and b.mto_fin_ven_trasp >1 --MESES VENCIDOS CUANDO SE HACE REESTRUCTURA DANDOLE UN CICLO COMPLETO
		--AND a.campo_trab3 = '' --FMJ DIC VENTA DE BAJA
		AND sdo_cap_insoluto >= 500
		AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
		and (select count (*) from bdicred:sd_amortiza_creditocrd 
			where empresa=pEmpresa and num_credito = a.num_credito and num_pago <=(SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065') and capital_status ='5')< (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065')
		AND (b.mto_fin_ven_trasp +
		(SELECT mto_fin_ven_trasp FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo
			AND fecha in (SELECT MAX (fecha) FROM bdicred:sd_maesdos_vendida 
					WHERE num_credito = a.credito_externo))) >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '061')
		AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
*/	

	INSERT INTO selec_credito
	SELECT a.num_producto,a.num_credito,a.numcte,a.id_origen,0,0,b.mto_fin_ven_trasp,b.monto_otorgado,sucursal,NVL(fecha_apertura,date(1)) fecha_apertura,
	status_cred, dia_corte, sdo_cap_insoluto
	,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c, bdisolic:ss_sol_nomina d--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001' AND a.empresa = b.empresa AND a.num_producto = '6400' AND a.num_credito = b.num_credito AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito AND a.status_cred in  ('BT','E2','E3')
	--AND a.campo_trab3 = ''  --FMJ DIC VENTA DE BAJA
	AND (b.mto_fin_ven_trasp/d.frecuencia_pgo) >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND sdo_cap_insoluto >= 500 
	AND d.empresa = a.empresa AND d.num_solicitud = a.num_credito AND d.numcte = a.numcte 
 	AND a.num_credito not IN (SELECT num_credito FROM selec_credito);	

	--AAME RQM 10 393 20150623 Se contempla Prestamos(7600,7700)
	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado,
		sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
		,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_producto IN ('6300','7600','7700','6800') ---> AGREGAR 6800   IFSR se comenta para pruebas
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.status_cred in  ('BT','E2','E3')
	--AND a.campo_trab3 = '' --FMJ DIC VENTA DE BAJA
	AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060') 
	AND sdo_cap_insoluto >= 500
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	AND (DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1);	
	--AAME RQM 10 393 20150623 Se contemplan los 2 nuevos productos (7600,7700)
	--RQM 09 274-2 MAVL
	INSERT INTO selec_credito
	SELECT first 10000 a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,(select count(*) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')), b.monto_otorgado,
	sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto
	,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_producto IN ('6300','7600','7700','6800') ---> AGREGAR 6800    IFSR se comenta para pruebas
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.status_cred in ('BT','E2','E3')
	AND sdo_cap_insoluto >= 500
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	and (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')) < monthadd(dFechaHoy,(-1*(SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')))
	AND (DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1); --IPCB: cuando se instale IFRS este bloque se omite

	/*
	--Primer validaciÃ³n 6011
		INSERT INTO selec_credito
		SELECT first 10000 a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp,
		b.monto_otorgado, sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto
		,'' cte_conflicto,fecha_ult_pago
		FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
		WHERE a.empresa = '001'
		AND a.empresa = b.empresa
		AND a.num_producto = '6011'
		AND a.num_credito = b.num_credito
		AND a.empresa = c.empresa
		AND a.num_credito = c.num_credito
		AND a.status_cred in ('BT','VP')
		and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
		and b.mto_fin_ven_trasp >1 --MESES VENCIDOS CUANDO SE HACE REESTRUCTURA DANDOLE UN CICLO COMPLETO
		AND sdo_cap_insoluto >= 500
		AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
		and (select count (*) from bdicred:sd_amortiza_creditocrd 
			where empresa=pEmpresa and num_credito = a.num_credito and num_pago <=(SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065') and capital_status ='5') >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065')
		AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
		
	--Segunda validaciÃ³n 6011
		INSERT INTO selec_credito
		SELECT first 10000 a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,
		((SELECT count(*) FROM bdicred:sd_amortiza_creditocrd WHERE a.empresa = empresa AND a.num_credito = num_credito AND capital_status IN ('2','7')) + 
			NVL((SELECT mto_fin_ven_trasp FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo
					AND fecha in (SELECT MAX (fecha) FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo)),0)),
		b.monto_otorgado, sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto
		,'' cte_conflicto,fecha_ult_pago
		FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c
		WHERE a.empresa = '001'
		AND a.empresa = b.empresa
		AND a.num_producto = '6011'
		AND a.num_credito = b.num_credito
		AND a.empresa = c.empresa
		AND a.num_credito = c.num_credito
		AND a.status_cred in ('BT','VP')
		and (b.monto_vencido + b.mto_venc_trasp)>0 --SALDO EXIGIBLE>0 
		and b.mto_fin_ven_trasp >1 --MESES VENCIDOS CUANDO SE HACE REESTRUCTURA DANDOLE UN CICLO COMPLETO
		AND sdo_cap_insoluto >= 500
		AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
		and (select count (*) from bdicred:sd_amortiza_creditocrd 
		where empresa=pEmpresa and num_credito = a.num_credito and num_pago <=(SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065') and capital_status ='5') < (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '065')
		AND (TRUNC(MONTHS_BETWEEN (dFechaHoy, (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7')))) + 
			NVL((SELECT mto_fin_ven_trasp FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo AND fecha in (SELECT MAX (fecha) FROM bdicred:sd_maesdos_vendida WHERE num_credito = a.credito_externo)),0))
			>= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '061')
		AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
*/

--IFRS se comenta por que no se probo el producto
	--Insertando Producto CrediNomina RQM 09 329 para Clientes >= 8 meses vencidos
	INSERT INTO selec_credito
	SELECT a.num_producto,a.num_credito,a.numcte,a.id_origen,0,0,b.mto_fin_ven_trasp,b.monto_otorgado,sucursal,NVL(fecha_apertura,date(1)) fecha_apertura,
	status_cred, dia_corte, sdo_cap_insoluto
	,'' cte_conflicto,fecha_ult_pago, 0 as act, b.atr
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c, bdisolic:ss_sol_nomina d--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001' AND a.empresa = b.empresa AND a.num_producto = '6400' AND a.num_credito = b.num_credito AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito AND a.status_cred in ('BT','E3')
	--AND a.campo_trab3 = ''  --FMJ DIC VENTA DE BAJA
	AND (b.mto_fin_ven_trasp/d.frecuencia_pgo) >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060') 
	AND a.campo_trab3 <> 'INMATERIAL' --JMAH RQM 09 343-3
	AND sdo_cap_insoluto >= 500 
	AND d.empresa = a.empresa AND d.num_solicitud = a.num_credito AND d.numcte = a.numcte 
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito)
	--AND ( DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1);
	and (select min(fecha_cuota) from bdicred:sd_amortiza_creditocrd where a.empresa = empresa and a.num_credito = num_credito and capital_status in ('2','7','6')) < monthadd(dFechaHoy,(-1*(SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')));

	--IPCB: Al instalar IFRS (migracion) se omite este bloque, se cubre con bloque linea 456

	
	--Insertando Producto CrediNomina RQM 09 329 para clientes >= 5 meses vencidos y sin ningun pago 
	/*INSERT INTO selec_credito
	SELECT a.num_producto,a.num_credito,a.numcte,a.id_origen,0,0,b.mto_fin_ven_trasp,b.monto_otorgado,sucursal, NVL(fecha_apertura,date(1)) fecha_apertura,
	status_cred, dia_corte, sdo_cap_insoluto
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001' AND a.empresa = b.empresa AND a.num_producto = '6400' AND a.num_credito = b.num_credito AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito AND a.status_cred = 'BT' AND a.campo_trab3 = ''
	AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '062')
	--AND b.mto_fin_ven_trasp < (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
	AND nvl(c.fecha_ult_pago, date(1)) = date(1)
	AND sdo_cap_insoluto >= 1000 AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
	--AND ( DAY(a.fecha_apertura) < day(dFechaHoy) - 1 OR DAY(a.fecha_apertura) > day(dFechaHoy) + 1);*/

--crea indices
	create index inx_selec_credito on selec_credito(num_credito);
	create index inx_selec_credito2 on selec_credito(numcte);
--actualiza estadisticas
	UPDATE statistics medium FOR table selec_credito;

--Agregar a tabla sd_exclusiones_vtacartera creditos a excluir
--convenios
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'01' as motivoexclusion from selec_credito a
	inner join bdicobranza:cb_compac b on(b.numcuenta = a.num_credito and (b.fecha_compac + (b.plazo*7)) >= dFechaHoy)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = dFechaHoy and num_credito = a.num_credito)
	AND a.mto_fin_ven_trasp < 13;

	DELETE FROM selec_credito WHERE num_credito IN (SELECT numcuenta  FROM bdicobranza:cb_compac  WHERE (fecha_compac + (plazo*7)) >=dFechaHoy)
		AND mto_fin_ven_trasp < 13;
--defunciones
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'02' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcte b on(b.numcte = a.numcte and b.situacion = 'F' and b.causa = 42)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = dFechaHoy and num_credito = a.num_credito);

	DELETE FROM selec_credito WHERE numcte IN (SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE situacion = 'F' AND causa = 42);

--reestructuras que se aperturan el mismo mes

	INSERT INTO bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
    SELECT '001',num_producto,num_credito,numcte, dFechaHoy as fechaexclusion,'15' as motivoexclusion 
    FROM selec_credito
    WHERE fecha_apertura >= date(MDY(MONTH(dFechaHoy),'01',YEAR(dFechaHoy)))
		AND num_producto='6011';

	DELETE FROM selec_credito WHERE numcte IN (SELECT numcte FROM selec_credito 
		WHERE fecha_apertura >= date(MDY(MONTH(dFechaHoy),'01',YEAR(dFechaHoy))) AND num_producto='6011');


--prospectos reestructuras
/*	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)  
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'03' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 35 )
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = dFechaHoy and num_credito = a.num_credito)
	AND a.mto_fin_ven_trasp < 13;
	
	DELETE FROM selec_credito WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 35) AND mto_fin_ven_trasp < 13;*/

--clientes prueba grupo3
/*	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)      
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'05' as motivoexclusion from selec_credito a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 61)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = dFechaHoy and num_credito = a.num_credito)
	AND a.mto_fin_ven_trasp < 13;
DELETE FROM selec_credito WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 61) AND mto_fin_ven_trasp < 13;*/

--aclaraciones en proceso

	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'06' as motivoexclusion 
	from selec_credito a
	where a.num_credito in
	(SELECT pro.numero_cuenta
		FROM bdiaclaracion:acl_aclaracion  acl,
		bdiaclaracion:acl_tipo_evento eve,
		bdiaclaracion:acl_producto pro,
		bdiaclaracion:acl_movimiento mov
		WHERE acl.fky_tipo_evento = eve.pky_tipo_evento
		AND pro.pky_producto = acl.fky_producto
		AND acl.pky_aclaracion = mov.fky_aclaracion
		AND  acl.fky_estatus_aclaracion = 2)
		AND a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = dFechaHoy and num_credito = a.num_credito);
		--AND mto_fin_ven_trasp < 13;
--rss poner copy
	DELETE FROM selec_credito WHERE num_credito IN
		(SELECT pro.numero_cuenta
		FROM bdiaclaracion:acl_aclaracion  acl,
		bdiaclaracion:acl_tipo_evento eve,
		bdiaclaracion:acl_producto pro,
		bdiaclaracion:acl_movimiento mov
		WHERE acl.fky_tipo_evento = eve.pky_tipo_evento
		AND pro.pky_producto = acl.fky_producto
		AND acl.pky_aclaracion = mov.fky_aclaracion
		AND  acl.fky_estatus_aclaracion = 2);
		--AND mto_fin_ven_trasp < 13;

	select a.num_credito
		from selec_credito a,
		bdinteg:si_huella_temp b
		where b.numcte = a.numcte
		and b.fecha_alta >= bdicred:monthadd(mdy(month(dFechaHoy),1,year(dFechaHoy)), case when dia_corte > day(dFechaHoy) then mto_fin_ven_trasp::integer + 1 * -1 else mto_fin_ven_trasp::integer * -1 end) 
		and b.fecha_alta <= bdicred:monthadd(mdy(month(dFechaHoy),1,year(dFechaHoy)), case when dia_corte > day(dFechaHoy) then mto_fin_ven_trasp::integer * -1 else mto_fin_ven_trasp::integer - 1 * -1 end) 
		and status = 'M'
		group by 1
		into temp posible_fraude with no log;

	create index idxtemp_credito on posible_fraude(num_credito);
	update statistics medium for table posible_fraude;

--clientes fraude huella
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'13' as motivoexclusion from selec_credito a
	where a.num_credito in (select num_credito from posible_fraude);

	DELETE FROM selec_credito WHERE num_credito IN (select num_credito from posible_fraude);

--Agregando excepcion: Clientes que no han llegado a su fecha facturacion RQM 09 329
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte, dFechaHoy as fechaexclusion,'14' as motivoexclusion 
	from selec_credito a, bdisolic:ss_sol_nomina d
	--where a.mto_fin_ven_trasp =6
	where (a.mto_fin_ven_trasp/d.frecuencia_pgo) < (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060') 
	and a.dia_corte >= day(dFechaHoy)
	and a.num_producto = '6400' 
	and a.num_credito not in (select num_credito from bdicred:creditos_venta_progapoyo)
	and d.empresa = '001' AND d.num_solicitud = a.num_credito AND d.numcte = a.numcte
	and a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = dFechaHoy);

--Borrando de la selec_credito todas las exclusiones insertadas en la bdicred:sd_exclusiones_ventacartera
	DELETE FROM selec_credito WHERE num_credito IN (SELECT num_credito FROM bdicred:sd_exclusiones_ventacartera 
		WHERE empresa = '001' and fecha_exclusion = dFechaHoy );

	
	--AAME RQM 10 393 20150623 Se contemplan los dos nuevos productos (7600,7700) 
	SELECT cod_fun 
	FROM bdicred:sd_conceptospagomanualcrd 
	WHERE num_producto IN ('6300','7600','7700','6800') ---> AGREGAR 6800
	group by 1
	into temp paso_pres;
	create unique index inx_paso_pres on paso_pres(cod_fun);
	update statistics medium for table paso_pres;

	set isolation to dirty read;
	SELECT cod_fun 
	FROM bdicred:sd_conceptospagomanualcrd 
	WHERE num_producto = '6011'
	group by 1
	into temp paso_rees;
	create unique index inx_paso_rees on paso_rees(cod_fun);
	update statistics medium for table paso_rees;

	--Creando tabla temporal paso_cnom para los cod_fun de CrediNomina
	set isolation to dirty read;
	SELECT cod_fun 
	FROM bdicred:sd_conceptospagomanualcrd 
	WHERE num_producto = '6400'
	group by 1
	into temp paso_cnom;
	create unique index inx_paso_cnom on paso_cnom(cod_fun);
	update statistics medium for table paso_cnom;

-- Seleccion de movimientos, historico CRD
	SELECT a.num_credito, codigo_fun, codigo_ref, fecha_mov, monto
	FROM bdicred:sd_movhiscrd a, selec_credito b
	WHERE a.empresa = '001'
	AND a.num_credito = b.num_credito
	AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
	AND codigo_ref = 1
	AND reversado = 'N'
	into temp movcrd with no log;

---> IPCB si bandera intereses de orden funciona bien se omite este bloque
/*
	insert into movcrd
	SELECT a.num_credito, codigo_fun, codigo_ref, max(fecha_mov), 0
	FROM bdicred:sd_movhiscrd a, selec_credito b
	WHERE a.empresa = '001'
	AND a.num_credito = b.num_credito
	AND codigo_fun = '602'
	AND codigo_ref = 2   
	AND reversado = 'N'
	group by 1,2,3;

	insert into movcrd
	SELECT a.num_credito, codigo_fun, codigo_ref, max(fecha_mov), 0
	FROM bdicred:sd_movhiscrd a, selec_credito b
	WHERE a.empresa = '001'
	AND a.num_credito = b.num_credito
	AND codigo_fun = '026'
	AND codigo_ref = 3
	AND reversado = 'N'
	group by 1,2,3;
*/
	create index inx_movcrdvta on movcrd(num_credito,codigo_fun,codigo_ref,fecha_mov);

	FOREACH WITH hold
	SELECT num_producto, num_credito, numcte, cod_caract_2, monto50, monto4meses, mto_fin_ven_trasp, monto_otorgado,
			sucursal, fecha_apertura, status_cred, nvl(dia_corte,0), sdo_cap_insoluto,cte_conflicto,fecha_ult_pago,act, atr
	INTO cNumProducto, cNumCredito, cNumCte, Ccodcaract, vmonto50, vmonto4meses, pNum_Vencidos, pMonto_otorgado,
			cNumSucursal, cFechaApertura, cStatusCred, cdiacorte, vsdo_cap_insoluto,cflag_cteconf, dfec_ult_pag, cAct, cAtr
	FROM selec_credito 

			IF cNumProducto = '6600' THEN
				CONTINUE FOREACH;
			END IF;
	
		LET cDescripcion="";
		LET cDescripPermTrabajo="";
			LET cNumCredito_rees = cNumCredito;
	
		IF cNumProducto in ('8100','7000') THEN
			SELECT NVL(credito_externo,'') into cNumSolicitud
			  FROM bdicred:sd_maecred
			 WHERE empresa = pEmpresa
			   AND num_credito = cNumCredito;	
		ELSE
			LET cNumSolicitud = '';
		END IF;
	
		--reestructura 
		IF cNumProducto = '6011' then

			LET fecha_mesant = dfechapridiames - 1;
			LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));

			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE fecha_mov > fecha_mesant -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			AND fecha_mov < MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy))
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_rees) 
			AND codigo_ref = 1;

			SELECT capital_mto_cuota
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd a
			WHERE a.empresa   = pEmpresa
			AND a.num_credito = cNumCredito_rees
			AND a.fecha_cuota = (SELECT min(fecha_cuota)
				FROM bdicred:sd_amortiza_creditocrd
				WHERE empresa  = pEmpresa
				AND num_credito = cNumCredito_rees
				AND capital_status IN ("2","7","6"));

		--AAME RQM 10 393 20150623 Se contemplan los dos nuevos productos (7600,7700) 
		ELIF  cNumProducto in ('6300','7600','7700','6800') then  ---> AGREGAR 6800
			--LET cNumCredito_rees = cNumCredito;
			LET fecha_mesant = dfechapridiames - 1;

--BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, ANIO) Y HACER EL CAMBIO DE ESTA VARIABLE SI ES NECESARIO

			IF cdiacorte > DAY(fecha_mesant) then
			LET fecha_mesant = MDY(MONTH(fecha_mesant),DAY(fecha_mesant),YEAR(fecha_mesant));
			ELSE
			LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
			END IF;

			IF cdiacorte > DAY(dfechaultdiames) then
			LET cdiacorte = DAY(dfechaultdiames);
			END IF;

--- BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, ANIO) Y HACER EL CAMIO DE ESTA VARIABLE SI ES NECESARIO
			
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			  AND codigo_ref = 1;
			
			/*IF pNum_Vencidos < 7 AND fIntenPago > 0 THEN -- Punto 1.3 RQM 09 274
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				VALUES 
				('001',cNumProducto,cNumCredito,cNumCte, dFechaHoy, '09');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;*/

			LET fIntenPago = 0;

			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE fecha_mov > fecha_mesant  -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			AND fecha_mov < (CASE WHEN cdiacorte > DAY(dfechaultdiames)
					then MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 1 UNITS DAY
					ELSE MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 0 UNITS DAY
					END) 
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			AND codigo_ref = 1;

			SELECT nvl(capital_mto_cuota,0)
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd
			WHERE empresa   = pEmpresa
			AND num_credito = cNumCredito_rees
			and num_pago = 1;

			LET fecha_mesant = dfechapridiames - 3 UNITS MONTH;
			LET fecha_mesant = fecha_mesant - 1 UNITS DAY;

			SELECT NVL(SUM(monto),0)
			INTO fIntenPago_pres
			FROM movcrd
			WHERE fecha_mov >= fecha_mesant 
			AND fecha_mov <= dFechaHoy --MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) con esta condicion se cambia para que sea de corte a corte
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			AND codigo_ref = 1;
		---SE AGREGA PARA PRODUCTO CREDINOMINA
		ELIF  cNumProducto = '6400' then

			--LET cNumCredito_rees = cNumCredito;
			LET fecha_mesant = dfechapridiames - 1;

---BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, ANIO) Y HACER EL CAMBIO DE ESTA VARIABLE SI ES NECESARIO

			IF cdiacorte > DAY(fecha_mesant) then
				LET fecha_mesant = MDY(MONTH(fecha_mesant),DAY(fecha_mesant),YEAR(fecha_mesant));
			ELSE
				LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
			END IF;
			
			IF cdiacorte > DAY(dfechaultdiames) then
			   LET cdiacorte = DAY(dfechaultdiames);
			END IF;

			---BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, ANIO) Y HACER EL CAMIO DE ESTA VARIABLE SI ES NECESARIO

			/*SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_cnom) 
			  AND codigo_ref = 1;
			
			IF pNum_Vencidos < 7 AND fIntenPago > 0 THEN -- Punto 1.3 RQM 09 274
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				VALUES 
				('001',cNumProducto,cNumCredito,cNumCte, dFechaHoy, '09');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;*/

			LET fIntenPago = 0;

			---Generando la Intencion de Pago del credito
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE fecha_mov > fecha_mesant  -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			AND fecha_mov < (CASE WHEN cdiacorte > DAY(dfechaultdiames) then MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 1 UNITS DAY ELSE MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 0 UNITS DAY END)
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_cnom) 
			AND codigo_ref = 1;

			----Agregando excepcion: Muestren una intencion de pago de al menos 50% del monto que les corresponde de la mensualidad mas antigua
			SELECT nvl(capital_mto_cuota,0)
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd
			WHERE empresa   = pEmpresa
			AND num_credito = cNumCredito_rees
			and num_pago = 1;

			/*IF fIntenPago >= (fAbonoMensual * .5) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte, dFechaHoy, '08');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;

			----Agregando excepcion: Haber efectuado un pago = a $50.00 antes del ultimo corte
			IF fIntenPago >= 50 AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte, dFechaHoy, '10');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;*/

			---Agregando excepcion: Haber cubierto al menos el 20% del adeudo en los ultimos 4 meses
			LET fecha_mesant = dfechapridiames - 3 UNITS MONTH;
			LET fecha_mesant = fecha_mesant - 1 UNITS DAY;

			SELECT NVL(SUM(monto),0)
			INTO fIntenPago_pres
			FROM movcrd
			WHERE fecha_mov >= fecha_mesant 
			  AND fecha_mov <= dFechaHoy --MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) con esta condicion se cambia para que sea de corte a corte
			  AND num_credito = cNumCredito_rees
			  AND codigo_fun IN (SELECT cod_fun FROM paso_cnom) 
			  AND codigo_ref = 1;

			/*IF fIntenPago_pres >= ( SELECT (monto_otorgado * .2) FROM bdicred:sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = cNumCredito_rees ) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte, dFechaHoy, '11');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;*/
		END IF;
	--END IF;

	IF (pNum_Vencidos > 0) then
		LET cMesesVencidos = pNum_Vencidos;

	SELECT  LIMIT 1
		rpad(TRIM(NVL(cte.apell_paterno,'')),20,' ') AS apellpaterno, --apellido 1
		rpad(TRIM(NVL(cte.apell_materno,'')),20,' ') AS apellmaterno, --apellido 2
		rpad(TRIM(NVL(cte.nombre1,'')),20,' ') AS nombre1, --nombre 1
		rpad(TRIM(NVL(cte.nombre2,'')),20,' ') AS nombre2, --nombre 2
		rpad(TRIM(NVL(cte.rfc,'')),13,' ')     as rfc, --rfc
		rpad(TRIM(NVL(cte.apell_casada,'')),26,' ') as apellcasada, --apellido de casada
		rpad(TRIM(NVL(cte.sector,'')),2,' ') AS sector, --sector
		lpad(TRIM(NVL(actesp.descripcion,'')),45,' ') as actividad, --actividad o giro de negocio
		NVL(ctepf.fecha_nac, date(1)) AS anionac, --anio de nacimiento
		rpad(trim(NVL(ctepf.curp,'')),20,' ') as curp, --curp
		rpad(trim(NVL(ctepf.sexo,'')),1,' ') as sexo, --sexo
		rpad(trim(NVL(ctepf.estado_civil,'')),2,' ') as edocivil, --estado civil
		rpad(trim(NVL(ctepf.numidentifi,'')),30,' ') as numidentificacion, --numero de identificaciÃ³n
		rpad(TRIM(NVL(em.correo_elec,'')),60,' ') as email, --correo electronico
		rpad(TRIM(NVL(tipoidentif.descripcion,'')),40,' ') as tipoidentificacion, --tipo de identificaciÃ³n
		rpad(TRIM(NVL(nac.descripcion,'')),15,' ') as nacionalidad, --nacionalidad
		rpad(TRIM(NVL(ing.nombre_empresa,'')),25,' ') AS lugartrabajo, --lugar de trabajo
		NVL(ing.ingreso_mensual, 0) AS ingresomensual, --ingreso mensual
		rpad(TRIM(NVL(ing.puesto,'')),3,'0') as puesto, --descripcion puesto
		rpad(trim(NVL(cte.numcte_ref,'')),20,' ') as referencia_coppel
	INTO
		cApellido1, cApellido2, cNombre1, cNombre2, cRfc, cApellidoCasada,
		cSector, cActividad, dFechaNac, cCurp, cSexo, cEdoCivil, cNumIdentificacion,
		cEmail, cTipoIdentificacion, cNacionalidad, cLugarTrabajo, mIngresoMensual, cPuesto, cRefCoppel
	FROM  bdinteg:si_cliente cte
	LEFT OUTER JOIN bdinteg:si_actesp  actesp  ON (actesp.empresa= cte.empresa AND actesp.codigo=cte.actividad_esp)
	LEFT OUTER JOIN bdinteg:si_ctepf   ctepf   ON (ctepf.empresa=cte.empresa AND ctepf.numcte = cte.numcte)
	LEFT OUTER JOIN bdinteg:si_tipoidentif tipoidentif ON (tipoidentif.codidentif=ctepf.codidentifi)
	LEFT OUTER JOIN bdinteg:si_nacion nac  ON (nac.nacion = ctepf.nacionalidad)
	LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.empresa=cte.empresa AND ing.tipo_ingreso = 'T' AND ing.numcte = cte.numcte AND ing.sec_ingreso= (SELECT MAX(sec_ingreso) FROM bdinteg:si_ingresos ing1 WHERE ing1.empresa=cte.empresa AND ing1.numcte = cte.numcte AND ing1.tipo_ingreso= 'T'))
	LEFT OUTER JOIN bdinteg:si_correos em ON (em.empresa=cte.empresa and em.numcte = cte.numcte and em.status_correo  = 'A' AND em.secuencia= (SELECT MAX(secuencia) FROM bdinteg:si_correos ema WHERE ema.empresa=cte.empresa AND ema.numcte = cte.numcte AND ema.status_correo= 'A'))
	WHERE cte.numcte= cNumCte;

	SELECT LIMIT 1
		--rpad(TRIM(NVL(edo1.nombre,'')),30,' ') as estado, -- descripcion del estado
		dir1.estado as estado, -- numero de estado
		case when (zonas1.numerociudadcoppel is null or zonas1.numerociudadcoppel = '' or zonas1.numerociudadcoppel = 0) then dir1.numerociudad ELSE zonas1.numerociudadcoppel END ciudad, --numero de ciudad
		NVL(zonas1.poblacionzona, '')as poblacion,
		case when (zonas1.numerociudadcoppel is null or zonas1.numerociudadcoppel = '' or zonas1.numerociudadcoppel = 0) then dir1.numerocolonia ELSE zonas1.numerocoloniacoppel END colonia, --numero de colonia
		dir1.numerocalle as calle, --numero de calle
		TRIM(dir1.numeroextcalle) AS numextcalle, --numero exterior
		TRIM(dir1.numerointcalle) AS numintecalle,  --numero interior
		lpad(TRIM(dir1.cod_postal),5,'0') AS cod_postal, --codigo postal
		rpad(TRIM(dir1.puntocardinal),1,' ') AS puntocardinal, --punto cardinal
		lpad(dir1.manzana,5,'0') AS manzana, --manzana
		lpad(dir1.andador,5,'0') AS andador, --andador
		lpad(dir1.etapa,5,'0') AS etapa, --etapa
		lpad(dir1.lote,5,'0')    AS lote, --lote
		lpad(dir1.edificio,5,'0') AS edificio, --edificio
		lpad(dir1.entrada,5,'0') AS entrada, --entrada
		rpad(TRIM(dir1.departamento),6,' ') AS departamento, --departamento
		rpad(TRIM(dir1.observaciones),80,' ') AS complemento, --complemento
		rpad(TRIM(dir1.entre_calles),40,' ') AS entre_calles, --entre calles
		lpad(dir1.otros,2,'0') AS otros, -- otros 

		--Domiclio de Trabajo
		dir2.estado as estadoTrab, --Numero de estado
		case when (zonas2.numerociudadcoppel is null or zonas2.numerociudadcoppel = '' or zonas2.numerociudadcoppel = 0) then dir2.numerociudad ELSE zonas2.numerociudadcoppel END ciudad, --numero de ciudad trabajo
		NVL(zonas2.poblacionzona, '')as poblacionTrab,
		case when (zonas2.numerociudadcoppel is null or zonas2.numerociudadcoppel = '' or zonas2.numerociudadcoppel = 0) then dir2.numerocolonia ELSE zonas2.numerocoloniacoppel END colonia,  --numero de colonia trabajo
		dir2.numerocalle as calle, --numero de calle
		TRIM(dir2.numeroextcalle) AS numextcalleTrab, --numero exterior
		TRIM(dir2.numerointcalle) AS numintecalleTrab, --numero interior
		lpad(TRIM(dir2.cod_postal),5,'0') AS cod_postalTrab, --codigo postal
		rpad(TRIM(dir2.puntocardinal),1,' ') AS puntocardinalTrab, --punto cardinal
		lpad(dir2.manzana,5,'0') AS manzanaTrab, --manzana
		lpad(dir2.andador,5,'0') AS andadorTrab, --andador
		lpad(dir2.etapa,5,'0')   AS etapaTrab, --etapa
		lpad(dir2.lote,5,'0')    AS loteTrab, --lote
		lpad(dir2.edificio,5,'0') AS edificioTrab, --edificio
		lpad(dir2.entrada,5,'0') AS entradaTrab, --entrada
		rpad(TRIM(dir2.departamento),6,' ') AS departamentoTrab, --departamento
		rpad(TRIM(dir2.observaciones),80,' ') AS complementoTrab, --complemento
		rpad(TRIM(dir2.entre_calles),40,' ') AS entre_callesTrab, --entre calles
		lpad(dir2.otros,2,'0') AS otrosTrab
	INTO
		cNumEstado, cNumCiudad, cPoblacion, cNumColonia, cNumCalle, cNumExterior, cNumInterior, cCodPostal, cPuntoCardinal, iManzana, iandador, iEtapa,
		iLote, iEdificio, iEntrada, cDepartamento, cComplemento, cEntreCalles, sOtros, /*cTelefono, cTelefonoCel, cTelTrab, cExtTrab,*/

		cNumEstadoTrab, cNumCiudadTrab, cPoblacionTrab, cNumColoniaTrab, cNumCalleTrab, cNumExteriorTrab, cNumInteriorTrab, cCodPostalTrab, cPuntoCardinalTrab, iManzanaTrab, iandadorTrab, iEtapaTrab,
		iLoteTrab, iEdificioTrab, iEntradaTrab, cDepartamentoTrab, cComplementoTrab, cEntreCallesTrab, iOtrosTrab
	FROM bdinteg:si_cliente cte
	LEFT OUTER JOIN bdinteg:si_direcciones_actual dir1 ON (dir1.numcte = cte.numcte AND dir1.tipo_dir  = '1')
	Left Outer Join bdinteg:si_catzonas zonas1 On (dir1.numerociudad = zonas1.numerociudad AND dir1.numerocolonia = zonas1.numerocolonia)
	LEFT OUTER JOIN bdinteg:si_direcciones_actual dir2 ON (dir2.numcte = cte.numcte AND dir2.tipo_dir = '2')
	Left Outer Join bdinteg:si_catzonas zonas2 On (dir2.numerociudad = zonas2.numerociudad AND dir2.numerocolonia = zonas2.numerocolonia)
	WHERE cte.NumCte = cNumCte;
	
	--IPCB 062018/RQM 09 484_inicio
	--Validacion DirecciÃ³n Casa Cliente
		let vciudadcop = cNumCiudad;
		let vcoloniacop = cNumColonia;

		IF vciudadcop is null OR vcoloniacop is null THEN  --Si no existe la correspondencia
		LET i = 0;
			SELECT ciudad 
			  INTO vciudadbanco 
			FROM bdinteg:"informix".si_sucursales WHERE sucursal = cNumSucursal; --Trae la ciudad de la sucursal
			
			FOREACH WITH HOLD	
				SELECT numerociudadcoppel,numerocoloniacoppel 
				INTO vciudadcop, vcoloniacop
				FROM bdinteg:"informix".si_catzonas 
			   WHERE numerociudad = vciudadbanco
				 AND numerociudadcoppel is not null
				 AND numerociudadcoppel <> 0
				 AND numerocoloniacoppel is not null
				 AND numerocoloniacoppel <> 0
				 ORDER BY numerocolonia		 
				LET i = 1;
				IF i = 1 THEN
					EXIT FOREACH; 
				END IF; 
		    END FOREACH;
			
			IF vciudadcop is null OR vcoloniacop is null THEN -- Si no trae la ciudad de la sucursal, busca la primera del catalogo
				LET i = 0;
				
				FOREACH WITH HOLD		
					SELECT numerociudadcoppel,numerocoloniacoppel 
					INTO vciudadcop, vcoloniacop
					 FROM bdinteg:"informix".si_catzonas 
					WHERE numerociudadcoppel is not null
					  AND numerociudadcoppel <> 0
					  AND numerocoloniacoppel is not null
					  AND numerocoloniacoppel <> 0
					  ORDER BY numerociudad,numerocolonia
					LET i = 1;
					IF i = 1 THEN
						EXIT FOREACH; 
					END IF; 
				END FOREACH;	
			END IF; 

			LET cNumCiudad = vciudadcop;
		    LET cNumColonia = vcoloniacop;
		END IF;
	
	 --Validacion DirecciÃ³n Trabajo Cliente
		let vciudadcop = cNumCiudadTrab;
		let vcoloniacop = cNumColoniaTrab;
		
      	IF vciudadcop is null OR vcoloniacop is null THEN  --Si no existe la correspondencia
		LET i = 0;
			SELECT ciudad 
			  INTO vciudadbanco 
			FROM bdinteg:"informix".si_sucursales WHERE sucursal = cNumSucursal; --Trae la ciudad de la sucursal
			
			FOREACH WITH HOLD	
				SELECT numerociudadcoppel,numerocoloniacoppel 
				INTO vciudadcop, vcoloniacop
				FROM bdinteg:"informix".si_catzonas 
			   WHERE numerociudad = vciudadbanco
				 AND numerociudadcoppel is not null
				 AND numerociudadcoppel <> 0
				 AND numerocoloniacoppel is not null
				 AND numerocoloniacoppel <> 0
				 ORDER BY numerocolonia		 
				LET i = 1;
				IF i = 1 THEN
					EXIT FOREACH; 
				END IF; 
		    END FOREACH;
			
			IF vciudadcop is null OR vcoloniacop is null THEN -- Si no trae la ciudad de la sucursal, busca la primera del catalogo
				LET i = 0;
				LET i = 0;
				
				FOREACH WITH HOLD		
					SELECT numerociudadcoppel,numerocoloniacoppel 
					INTO vciudadcop, vcoloniacop
					 FROM bdinteg:"informix".si_catzonas 
					WHERE numerociudadcoppel is not null
					  AND numerociudadcoppel <> 0
					  AND numerocoloniacoppel is not null
					  AND numerocoloniacoppel <> 0
					  ORDER BY numerociudad,numerocolonia
					LET i = 1;
					IF i = 1 THEN
						EXIT FOREACH; 
					END IF; 
				END FOREACH;	
			END IF; 

			LET cNumCiudadTrab = vciudadcop;
		    LET cNumColoniaTrab = vcoloniacop;
		END IF;	
	--IPCB 062018/RQM 09 484_fin
	
	--Se obtiene el elemento para de residencia
	IF cNumSolicitud <> '' then
		SELECT elemento
		INTO sElementoRes
		FROM bdisolic:ss_detalle_scoring 
		WHERE seccion= 2
		AND grupo  = 6 
		AND	num_solicitud=cNumSolicitud;
	ELSE
		SELECT NVL(elemento,"")
		INTO sElementoRes
		FROM bdisolic:ss_detalle_scoring 
		WHERE num_solicitud= cNumCredito
		AND seccion= 2
		AND grupo  = 6;	
	END IF;

		
	--Se obtiene la descripcion del elemento para el tiempo de residencia
	IF 	sElementoRes != "" THEN
		SELECT descripcion
		INTO cDescripcion
		FROM bdisolic:ss_scoring_element
		WHERE seccion = 2
		AND grupo = 6
		AND elemento = sElementoRes;
	ELSE
		LET cDescripcion="";
	END IF;
	
	--Se obtiene el elemento respondido en la pregunta Tiempo de permanencia en la ocupacion actual
	IF cNumSolicitud <> '' then
		SELECT elemento
		INTO sElemResTrabajo
		FROM bdisolic:ss_detalle_scoring 
		WHERE seccion= 2
		AND grupo  = 8 
		AND	num_solicitud=cNumSolicitud;
	ELSE
		SELECT NVL(elemento,"")
		INTO sElemResTrabajo
		FROM bdisolic:ss_detalle_scoring
		WHERE num_solicitud = cNumCredito
		AND seccion = 2
		AND grupo = 8;
	END IF;	

	--Se obtiene la descripcion del elemento respondido  en la pregunta Tiempo de permanencia en la ocupacion actual
	IF 	sElemResTrabajo !="" THEN
		SELECT descripcion
		INTO cDescripPermTrabajo
		FROM bdisolic:ss_scoring_element
		WHERE seccion=2
		AND grupo=8
		AND elemento= sElemResTrabajo;
	ELSE
		LET cDescripPermTrabajo="";
	END IF;
	
	select limit 1 nvl(rpad(TRIM(telefono),13,' '),' ')
	into cTelefono
	from bdinteg:si_telefonos_actual 
	where numcte = cNumCte
	and tipo_tel = 1 and cofetel ='V';

	select  nvl(rpad(TRIM(telefono),13,' '),' ')
	into  cTelefonoCel
	from bdinteg:si_telefonos_actual 
	where numcte = cNumCte 
	and tipo_tel = 2 and cofetel ='V';

		select  nvl(rpad(TRIM(telefono),13,' '),' ') ,rpad(NVL(extension,''), 13, ' ')
		into  cTelTrab, cExtTrab
		from bdinteg:si_telefonos_actual 
		where numcte = cNumCte 
		and tipo_tel = 3 and cofetel ='V';

--SEGUNDA PARTE DE CAMPOS
	--IF cNumProducto ='6001' then
	IF cNumproducto in ('6001','8500') then
		
		SELECT sucursal
		INTO cSucursal
		FROM bdisolic:ss_solicitudes 
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumCredito;
		
	ELSE
				
		IF 	cNumSolicitud <> '' THEN
			SELECT sucursal 
			INTO cSucursal
			FROM bdisolic:ss_solicitudes 
			WHERE num_solicitud = cNumSolicitud;
		ELSE	
			SELECT sucursal
			INTO cSucursal
			FROM bdisolic:ss_solicitudes
			WHERE empresa = pEmpresa
			AND num_solicitud = cNumCredito_rees;
		END IF;
		
	END IF;




	--obteniendo credito anterior a la reestructura 
		IF cNumProducto = '6011' then
			select credito_externo into cCreditoExterno
			from bdicred:sd_maecredcrd 
			WHERE empresa = pEmpresa
			AND num_credito = cNumCredito_rees;

			SELECT NVL(situacion_pago,0), NVL(meses_historia,0), case when NVL(evalua_cc,'') = 'X' then 'NO HIT' ELSE 'HIT' END, NVL(grupo,'')
			INTO cSituacionPago, cMesesHistoria, cEvaluacc, cGrupo
			FROM bdisolic:ss_resum_scor_fin
			WHERE empresa = pEmpresa
			AND num_solicitud = cCreditoExterno;
		ELSE
			IF (cNumSolicitud <> '') THEN
				SELECT NVL(situacion_pago,0), NVL(meses_historia,0), case when NVL(evalua_cc,'') = 'X' then 'NO HIT' ELSE 'HIT' END, NVL(grupo,'')
				INTO cSituacionPago, cMesesHistoria, cEvaluacc, cGrupo
				FROM bdisolic:ss_resum_scor_fin
				WHERE empresa = pEmpresa
				AND num_solicitud =cNumSolicitud;
			ELSE
			--se agrega los meses de historia, eficiencia coppel, variable hit o no hit, grupo
				SELECT NVL(situacion_pago,0), NVL(meses_historia,0), case when NVL(evalua_cc,'') = 'X' then 'NO HIT' ELSE 'HIT' END, NVL(grupo,'')
				INTO cSituacionPago, cMesesHistoria, cEvaluacc, cGrupo
				FROM bdisolic:ss_resum_scor_fin
				WHERE empresa = pEmpresa
				AND num_solicitud = cNumCredito;
			END IF;
		END IF;

	
		--Asignacion de creditos a Grupo
		IF cNumProducto = '6011' THEN
			LET cCreditoGrupo = cCreditoExterno;
		ELSE 
			LET cCreditoGrupo = cNumCredito;
		END IF;


		--para grupo vacio
		IF cGrupo = '' THEN
			select 
			case when ((cMesesHistoria >= 13 and cSituacionPago >= 85) or (cMesesHistoria >= 6 AND cSituacionPago >= 0 AND cSituacionPago < 85)) and cGrupo not in ('6')  then '1'
			when cMesesHistoria >= 6 and cMesesHistoria < 13 and cSituacionPago >= 85 and cGrupo not in ('6') then '2'
			when ((cMesesHistoria < 6 and cSituacionPago > 0) or (cMesesHistoria > 0 and cMesesHistoria < 6 and cSituacionPago <= 0) or (cSituacionPago = -1)) and cGrupo not in ('6') then '3'
			when cMesesHistoria = 0 and cSituacionPago = 0 and cGrupo not in ('6') then '5'
			when cGrupo = '6' then '6'
				else grupo end into cTipoGrupo
				from bdisolic:ss_resum_scor_fin
				where empresa = pEmpresa and num_solicitud = cCreditoGrupo;
		ELSE
			let cTipoGrupo = cGrupo;
		END IF;
		
		
		IF  cNumProducto IN ('6001','8100','7000','8500') then
			SELECT nvl(fecha_ultimo_pago, date(1)),monto_ultimo_pago, nvl(fecha_ultima_compra, date(1)),monto_ultima_compra
			INTO dtFechaUltimoPago,dMontoUltimoPago, dtFechaUltimaCompra,dMontoUltimaCompra
			FROM bdicred:"informix".sd_indicador_cred
			WHERE empresa   = pEmpresa
			AND num_credito = cNumCredito;

			IF dMontoUltimaCompra > 0 then

				let dFechaUltDisp = dtFechaUltimaCompra;
				let fMontoUltDisp = dMontoUltimaCompra; 

				SELECT limit 1 max(folio_suc) into cFolioSuc
				FROM bdicred:sd_movhis
				WHERE empresa = pEmpresa
				AND fecha_mov = dFechaUltDisp
				AND num_credito = cNumCredito
				AND codigo_fun = '002' --and codigo_ref=40
				AND reversado = 'N'
				AND monto = dMontoUltimaCompra;
				--order by secuencia desc;
				
				IF nvl(cFolioSuc,'') ='' THEN
				  SELECT limit 1 max(folio_suc) into cFolioSuc
					FROM bdicred:sd_movhis_new
					WHERE empresa = pEmpresa
					AND fecha_mov = dFechaUltDisp
					AND num_credito = cNumCredito
					AND codigo_fun = '002' --and codigo_ref=40
					AND reversado = 'N'
					AND monto = dMontoUltimaCompra;
				END IF;
								

				SELECT {+INDEX (bdicred:sd_movhis inx_movhis6)} NVL(max(Monto),0)  --IPCB Aldo validara si hay cambio en codigo fun o ref 
					INTO fMontoComi
				FROM bdicred:sd_movhis
				WHERE empresa = pEmpresa
				AND fecha_mov = dFechaUltDisp
				AND num_credito = cNumCredito
				AND codigo_fun = '339'
				AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19)
				AND reversado = 'N'
				AND folio_suc = cFolioSuc;
				
				IF NVL(fMontoComi,0) = 0 THEN 
					SELECT {+INDEX (bdicred:sd_movhis inx_movhis6)} NVL(max(Monto),0)					
					INTO fMontoComi
					FROM bdicred:sd_movhis_new
					WHERE empresa = pEmpresa
					AND fecha_mov = dFechaUltDisp
					AND num_credito = cNumCredito
					AND codigo_fun = '339'
					AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19)
					AND reversado = 'N'
					AND folio_suc = cFolioSuc;
				END IF;	
			ELSE
					LET fMontoUltDisp,fMontoComi = 0, 0;
			END IF;
--==============
			IF dtFechaUltimoPago > dFechaUltDisp then
				LET cUltMov      = 'PAGO';
				LET dFechaUltMov = dtFechaUltimoPago;
			ELIF dtFechaUltimoPago = dFechaUltDisp then
				IF dtFechaUltimoPago = date(1) then
					LET cUltMov      = ''; --'NO hubo nada'
					LET dFechaUltMov = dtFechaUltimoPago;
				ELSE
					LET cUltMov      = 'PAGO';
					LET dFechaUltMov = dtFechaUltimoPago;
				END IF;
			ELSE
				LET cUltMov      = 'DISP';
				LET dFechaUltMov = dFechaUltDisp;
			END IF;

			IF cUltMov = 'PAGO' then
				LET fMontoUltMov = NVL(dMontoUltimoPago,0);
			ELIF cUltMov = 'DISP' then
				LET fMontoUltMov = fMontoUltDisp;
			ELSE
				LET fMontoUltMov = 0;
			END IF;
--==========
				LET fAbonoMensual,fSaldoMesAnt = 0, 0;

			FOREACH
				SELECT NVL(monto_financiado,0), --NVL(sdo_capinsoluto,0),
					NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
					INTO fAbonoMensual, fSaldoMesAnt --, fSaldoMesAnt_2
				FROM bdicred:sd_maesdoshist
				WHERE empresa= pEmpresa
				AND num_credito = cNumCredito
				--AND fecha = MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy)) - 2 units month;
				AND fecha = (SELECT NVL(max(fecha), dFechaHoy) FROM bdicred:sd_maesdoshist WHERE fecha < MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy)) AND empresa= pEmpresa AND num_credito = cNumCredito)
			

			END FOREACH;

		LET mMontoInteresCap, mMontoIvaIntCap = 0, 0;

			SELECT --sdo_capinsoluto,
				NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0),
				NVL(SUM(NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0)),0),
				NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0)),0),
				NVL(SUM(NVL(b.mto_venc_tra_int,0)),0) -- INTERES CAPITALIZADO
				INTO fSaldoMesActual , --, fSaldoMesActual_2
					fSaldoMesVencido,
					fSaldoMesNoExig, 
					mMontoInteresCap
			FROM bdicred:sd_maesdos b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito;

			--IVA CAPITALIZADO
			FOREACH-----------IPCB: Se integran nuevos codigo ref 126,128
				SELECT first 2 fecha_mov, monto
				INTO vfmov , mMonto
				FROM bdicred:sd_movhis
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito
				AND  codigo_fun  = '605'
				AND codigo_ref in  (3,126,128)
				AND reversado = 'N'
				union all
				SELECT fecha_mov, monto				
				FROM bdicred:sd_movhis_new
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito
				AND codigo_fun  = '605'
				AND codigo_ref in  (3,126,128)
				AND reversado = 'N'
				order by fecha_mov desc

				LET mMontoIvaIntCap  = mMontoIvaIntCap + mMonto;

			END FOREACH;

		--Se Obtiene el iva correspondiente a la sucursal que se asocio al Credito
			SELECT iva
			INTO mPorcIva
			FROM bdinteg:si_sucursales
			WHERE empresa = pempresa
			AND sucursal = cNumSucursal;

		-- Se obtiene los Intereses orden
			SELECT d.int_tra_no_exig
			INTO mIntVencido_ord
			FROM bdicred:sd_maesdos d
			WHERE d.empresa= pEmpresa
			AND d.num_credito= cNumCredito;

		--Se obtiene el Iva de los Intereses Vigentes
			SELECT SUM(iva_debe - iva_pagado)
			INTO mIvaIntVencido_ord
			FROM sd_amortiza_credito d
			WHERE d.empresa = pEmpresa
			AND d.num_credito = cNumCredito
			AND capital_status IN ('1','2','7','6');

			IF (fSaldoMesActual < 500) AND pNum_Vencidos < 13 then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				VALUES
				('001',cNumProducto,cNumCredito,cNumCte,dFechaHoy, '12');

				continue FOREACH;
			 END IF;

		--Se obtiene el Iva de Intereses Moratorio pagado
/*
			SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
			INTO mIvaIntMoraTotal
			FROM sd_amortiza_credito
			WHERE empresa = pempresa 
			AND num_credito = cNumCredito
			AND capital_status IN ("2","7")
			AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;

*/

		-- Se obtiene el Interes Moratorio Copete
			SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
				NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
				NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
				NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
				INTO mIntMoraCope, mIvaIntMoraCope, mIntMoraOrdi, mIvaIntMoraOrdi
			FROM sd_amortiza_credito
			WHERE  empresa = pempresa
			AND num_credito = cNumCredito
			AND capital_status IN ("2","7","6");

			IF mIntMoraCope IS NULL OR  mIntMoraCope < 0 THEN
				LET mIntMoraCope = 0;
			END IF;

			IF mIvaIntMoraCope IS NULL OR  mIvaIntMoraCope < 0 THEN
				LET mIvaIntMoraCope = 0;
			END IF;

			IF mIntMoraOrdi IS NULL OR  mIntMoraOrdi < 0 THEN
				LET mIntMoraOrdi = 0;
			END IF;

			IF mIvaIntMoraOrdi IS NULL OR  mIvaIntMoraOrdi < 0 THEN
				LET mIvaIntMoraOrdi = 0;
			END IF;


/*
			if (mIntMoraCope + mIntMoraOrdi) > 0 then
				let mIvaIntMoraTotal = (mIvaIntMoraCope + mIvaIntMoraOrdi) - mIvaIntMoraTotal;
			else
				let mIvaIntMoraTotal = 0;
			end if;

			IF (mIvaIntMoraCope >= mIvaIntMoraTotal) then
				let mIvaIntMoraCope = mIvaIntMoraCope - mIvaIntMoraTotal;
				let mIvaIntMoraTotal = 0;
			else
				let mIvaIntMoraTotal = mIvaIntMoraTotal - mIvaIntMoraCope;
				let mIvaIntMoraCope = 0;
			end if;

			IF (mIvaIntMoraOrdi >= mIvaIntMoraTotal) then
				let mIvaIntMoraOrdi = mIvaIntMoraOrdi - mIvaIntMoraTotal;
				let mIvaIntMoraTotal = 0;
			else
				let mIvaIntMoraTotal = mIvaIntMoraTotal - mIvaIntMoraOrdi;
				let mIvaIntMoraOrdi = 0;
			end if;*/

			SELECT limit 1 num_tarjeta
			INTO cNumTarjeta
			FROM bdicred:sd_tarjeta
			WHERE empresa = pEmpresa
			AND tipo_tarjeta = 'T'
			AND status_tar = 'A'
			AND num_credito = cNumCredito;

			IF cNumTarjeta is null then
				SELECT limit 1 num_tarjeta
				INTO cNumTarjeta
				FROM bdicred:sd_tarjeta
				WHERE empresa = pEmpresa
				AND tipo_tarjeta = 'T'
				AND num_credito  = cNumCredito
				AND secuencia = (SELECT NVL(max(secuencia),0) FROM bdicred:sd_tarjeta WHERE empresa = pEmpresa AND tipo_tarjeta = 'T' AND num_credito  = cNumCredito);
			END IF;

				LET cNumTarjeta = NVL(cNumTarjeta, '');

		ELSE --Campos para Reestructura, Prestamo Personal y CrediNomina    ---> ENTRA FLEXIBLE

			SELECT monto_otorgado,0
			INTO fMontoUltDisp,fMontoComi
			FROM bdicred:sd_maesdoscrd b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito_rees;

			SELECT NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0),
					NVL(SUM(NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0)),0),
					NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0)),0)
			INTO fSaldoMesActual,
				 fSaldoMesVencido,
				 fSaldoMesNoExig
			FROM bdicred:sd_maesdoscrd b
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito_rees;
			
			LET mMontoInteresCap, mMontoIvaIntCap = 0,0;
			
			LET fecha_mesant = dfechapridiames - 1 UNITS MONTH; 
			
			SELECT NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
			INTO fSaldoMesAnt
			FROM bdicred:sd_maesdoshistcrd
			WHERE empresa= pEmpresa
			AND num_credito = cNumCredito_rees
			AND fecha =  ( SELECT NVL(max(fecha), dFechaHoy) FROM bdicred:sd_maesdoshistcrd WHERE fecha >= fecha_mesant AND empresa= pEmpresa AND num_credito = cNumCredito_rees);
			--AAME RQM 10 393 20150623 Se contemplan los nuevos productos(7600,7700) 

			if cNumProducto in ('6300','7600','7700','6800') then  ---> AGREGAR 6800
				SELECT NVL(max(fecha_mov), date(1)), COUNT(*)
				INTO dFechaUltPago, iCuantosPagos
				FROM movcrd
				WHERE num_credito = cNumCredito_rees
				AND codigo_fun IN (SELECT cod_fun FROM paso_pres)
				AND codigo_ref = 1;

				SELECT NVL(SUM(monto),0)
				INTO fMontoPago
				FROM movcrd
				WHERE fecha_mov = dFechaUltPago
				AND num_credito = cNumCredito_rees
				AND codigo_fun IN (SELECT cod_fun FROM paso_pres)
				AND codigo_ref = 1;

			elif (cNumProducto = '6011') then
				SELECT NVL(max(fecha_mov), date(1)), COUNT(*)
				INTO dFechaUltPago, iCuantosPagos
				FROM movcrd
				WHERE num_credito = cNumCredito_rees
				AND codigo_fun IN (SELECT cod_fun FROM paso_rees)
				AND codigo_ref = 1;

				SELECT NVL(SUM(monto),0)
				INTO fMontoPago
				FROM movcrd
				WHERE fecha_mov = dFechaUltPago
				AND num_credito = cNumCredito_rees
				AND codigo_fun IN (SELECT cod_fun FROM paso_rees)
				AND codigo_ref = 1;

			--Se Agrega Producto CrediNomina de acuerdo a RQM 09 329
			elif (cNumProducto = '6400') then
				SELECT NVL(max(fecha_mov), date(1)), COUNT(*)
				INTO dFechaUltPago, iCuantosPagos
				FROM movcrd
				WHERE num_credito = cNumCredito_rees AND codigo_fun IN (SELECT cod_fun FROM paso_cnom) AND codigo_ref = 1;

				SELECT NVL(SUM(monto),0)
				INTO fMontoPago
				FROM movcrd
				WHERE fecha_mov = dFechaUltPago AND num_credito = cNumCredito_rees AND codigo_fun IN (SELECT cod_fun FROM paso_cnom) AND codigo_ref = 1;

			end if;
		
			LET dFechaUltDisp = cFechaApertura;

			IF dFechaUltPago > cFechaApertura then
				LET cUltMov      = 'PAGO';
				LET dFechaUltMov = dFechaUltPago;
				LET fMontoUltMov = NVL(fMontoPago,0);
			ELSE
				LET cUltMov      = 'APER';
				LET dFechaUltMov = cFechaApertura;
				LET fMontoUltMov = NVL(fMontoUltDisp,0);
			   
			END IF;

--			IF cNumProducto = '6011' THEN   --si es Reestructura o prestamos  entra aqui
			 /*	IF cStatusCred in 'BT' THEN  --quitar 
				--balanza y orden
					select nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(interes_debe - interes_pagado,0) else 0 end),0),
						nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(iva_debe - iva_pagado,0) else 0 end),0),
						nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
						nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
					INTO mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord
					from bdicred:sd_amortiza_creditocrd a, movcrd b
					where a.empresa = pEmpresa
					and a.num_credito = cNumCredito_rees
					and a.num_credito = b.num_credito
					and a.capital_status in ('2','7','6')
					and b.codigo_fun = '602'   --traspaso a e3
					and b.codigo_ref = 2;
				ELSE
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO mIntVencido_ord, mIvaIntVencido_ord
					FROM bdicred:sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito= cNumCredito_rees
					AND capital_status in ('2','7','6');
				END IF;*/
				
--balanza y orden
					select nvl(sum(case when a.campo_trabajo3 = '' then nvl(interes_debe - interes_pagado,0) else 0 end),0),
						nvl(sum(case when a.campo_trabajo3 = '' then nvl(iva_debe - iva_pagado,0) else 0 end),0),
						nvl(sum(case when a.campo_trabajo3 = 'V'  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
						nvl(sum(case when  a.campo_trabajo3 = 'V'  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
					INTO mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord
					from bdicred:sd_amortiza_creditocrd a--, movcrd b
					where a.empresa = pEmpresa
					and a.num_credito = cNumCredito_rees
					and a.capital_status in ('2','7','6'); 
					---IPCB Validar si funciona correctamente en producciÃ³n la bandera de interes de Orden  para poder liberar
			
					IF cNumProducto in ('6300','7600','7700') THEN 
				
						--- se obtienen los  montos de INT e IVA de la maeretenido del programa de apoyo
						SELECT monto
							INTO psaldoInteresApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = cNumCredito_rees
							AND transacc = '8374'
							AND estatus = 'R';

							IF psaldoInteresApoyo IS NULL THEN
								LET psaldoInteresApoyo = 0;
							END IF;

						SELECT monto
							INTO psaldoIvaApoyo
						FROM bdicred:sd_maeretenido 
						WHERE num_credito = cNumCredito_rees
							AND transacc ='8375'
							AND estatus = 'R';

						IF psaldoIvaApoyo IS NULL THEN
							LET psaldoIvaApoyo = 0;
						END IF;
				
						LET mIntVencido_bal = mIntVencido_bal + psaldoInteresApoyo;
						LET mIvaIntVencido_bal = mIvaIntVencido_bal + psaldoIvaApoyo;
						
					END IF;
					--LET mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope = 0,0,0,0;  
			--AAME RQM 10 393 20150623 Se contemplan los nuevos productos (7600,7700) 

		/*	ELIF cNumProducto in ('6300','6400','7600','7700','6800') THEN	---> AGREGAR 6800

				--balanza y orden
				select nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(interes_debe - interes_pagado,0) else 0 end),0),
					nvl(sum(case when a.fecha_cuota <= b.fecha_mov then nvl(iva_debe - iva_pagado,0) else 0 end),0),
					nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(interes_debe - interes_pagado,0) else 0 end),0),
					nvl(sum(case when a.fecha_cuota > b.fecha_mov  then nvl(iva_debe - iva_pagado,0) else 0 end),0)
				INTO mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord
				from bdicred:sd_amortiza_creditocrd a, movcrd b
				where a.empresa = pEmpresa
				and a.num_credito = cNumCredito_rees
				and a.num_credito = b.num_credito
				and a.capital_status in ('2','7')
				and b.codigo_fun = '026' 
				and b.codigo_ref = 3;

				LET mPorcIva = '';
				SELECT iva
				INTO mPorcIva
				FROM bdinteg:si_sucursales
				WHERE empresa = pempresa
				AND sucursal = cNumSucursal;
				
				IF cNumProducto in ('6300','7600','7700') THEN 
				
					--- se obtienen los  montos de INT e IVA de la maeretenido del programa de apoyo
					SELECT monto
						INTO psaldoInteresApoyo
					FROM bdicred:sd_maeretenido 
					WHERE num_credito = cNumCredito_rees
						AND transacc = '8374'
						AND estatus = 'R';

						IF psaldoInteresApoyo IS NULL THEN
							LET psaldoInteresApoyo = 0;
						END IF;

					SELECT monto
						INTO psaldoIvaApoyo
					FROM bdicred:sd_maeretenido 
					WHERE num_credito = cNumCredito_rees
						AND transacc ='8375'
						AND estatus = 'R';

					IF psaldoIvaApoyo IS NULL THEN
						LET psaldoIvaApoyo = 0;
					END IF;
			
					LET mIntVencido_bal = mIntVencido_bal + psaldoInteresApoyo;
					LET mIvaIntVencido_bal = mIvaIntVencido_bal + psaldoIvaApoyo;
			
				END IF;*/

				-- Se obtiene el Iva de Intereses Moratorio pagado
/*
				SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
				INTO mIvaIntMoraTotal
				FROM sd_amortiza_creditocrd
				WHERE empresa = pempresa
				AND num_credito = cNumCredito_rees
				AND capital_status IN ("2","7")
				AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;
*/

					 -- Se obtiene el Interes Moratorio Copete
					SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
						NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
						NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
						NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
					INTO mIntMoraCope, mIvaIntMoraCope, mIntMoraOrdi, mIvaIntMoraOrdi
					FROM sd_amortiza_creditocrd
					WHERE empresa = pempresa
					AND num_credito = cNumCredito_rees
					AND capital_status IN ("2","7","6");
				--END IF;
--			END IF;

			LET cNumTarjeta = '';	

		END IF;
		
		/* Se agrega consultas para validar solicitudes que se enviaron a MC*/
		
		IF cNumSolicitud <> '' then 
			SELECT nvl(revisado,'')
			INTO vRespuestaMc
			FROM bdisolic:ss_solicitudes_mc
			WHERE num_solicitud = cNumSolicitud;
		ELSE
			SELECT nvl(revisado,'')
			INTO vRespuestaMc
			FROM bdisolic:ss_solicitudes_mc
			WHERE num_solicitud = cNumCredito_rees  
			AND empresa = pEmpresa;	
		END IF;
		
		IF vRespuestaMc <> '' THEN
			LET vEnvioMC = 1;
			IF vRespuestaMc = 'S' THEN
				LET vAtendidaMC = 1;
			END IF;
		END IF;
		
		--NUEVOS CAMPOS ADENDUM RQM 04 127
		IF CNumproducto in ('6001','8500','7800','7000','8100') then
            SELECT dias_atraso  --fecha_vencido, 
            INTO v_dias_vencido --v_fecha_vencido,
            FROM sd_indicador_cred
            WHERE num_credito=cNumCredito;
			
			select fecha_vencto
			into v_fecha_vencido
			from bdicred:sd_maecredanexo
			where num_credito=cNumCredito;
                        
        ELSE 
		    SELECT dias_atraso  --fecha_vencido,
            INTO v_dias_vencido -- v_fecha_vencido,
            FROM sd_indicador_cred_crd
            WHERE num_credito=cNumCredito_rees;
			
			select fecha_vencto
			into v_fecha_vencido
			from bdicred:sd_maecredanexocrd
			where num_credito=cNumCredito_rees;
                
            
        END IF;
		
		
	
		
		BEGIN WORK;
			INSERT INTO bdicobranza:cb_rep_cart_quebrantar
			(	Num_Credito, NumCte,
				Apellido1, Apellido2, Nombre1, Nombre2, Rfc, ApellidoCasada,
				Sector, FechaNac, Curp, Sexo, EdoCivil, NumIdentificacion,
				Email, TipoIdentificacion, Nacionalidad,
				NumEstado, NumCiudad, Poblacion, NumColonia, NumCalle, NumExterior,
				NumInterior, CodPostal, PuntoCardinal, Manzana, andador, Etapa,
				Lote, Edificio, Entrada, Departamento, Complemento, EntreCalles,
				Otros, SituacionEsp, CausaSitEsp,
				IngresoMensual, Puesto, LugarTrabajo, Telefono, TelTrab, ExtTrab,
				AntigDomic, AntigTrab, Actividad,
				NumEstadoTrab, NumCiudadTrab, PoblacionTrab, NumColoniaTrab, NumCalleTrab, NumExteriorTrab,
				NumInteriorTrab, CodPostalTrab, PuntoCardinalTrab, ManzanaTrab, andadorTrab, EtapaTrab,
				LoteTrab, EdificioTrab, EntradaTrab, DepartamentoTrab, ComplementoTrab, EntreCallesTrab,
				OtrosTrab,
				Sucursal, Fecha_Ult_Disp, Monto_Ult_Disp,
				Monto_Comi_Ult_Disp, Abono_Mensual_Al_Qub, Int_Capit, Iva_Int_Capit ,
				Sdo_Mes_Ant, Sdo_Actual, Sdo_Vencido, Sdo_No_Exig, Fecha_Ult_Mov, Tipo_Ult_Mov,
				Monto_Ult_Mov, Int_Vencido, Iva_Int_Vencido, Int_Vencido_bal, Iva_Int_Vencido_bal,
				Int_Mora_Ordi, Iva_Int_Mora_Ordi, Int_Mora_Cope, Iva_Int_Mora_Cope, Meses_Vencidos, Numero_Tarjeta,
				ReferenciaCoppel, fechareporte,
				fechaapertura, telefonocel, situacionpago, meseshistoria, grupo, evaluacc, monto_otorgado, producto,
				ban_envio_mc, ban_atendio_mc
				,cte_conflicto,fecha_ult_pago,act, atr,fecha_vencido, dias_vencido--IPCB
			)
			Values
			(	case when CNumproducto IN ('6001','8100','7000','8500') then cNumCredito ELSE cNumCredito_rees END,
				cNumCte,
				cApellido1, cApellido2, cNombre1, cNombre2, cRfc, cApellidoCasada,
				cSector, dFechaNac, cCurp, cSexo, cEdoCivil, cNumIdentificacion,
				cEmail, cTipoIdentificacion, cNacionalidad,
				cNumEstado, cNumCiudad, cPoblacion, cNumColonia, cNumCalle, cNumExterior,
				cNumInterior, cCodPostal, cPuntoCardinal, iManzana, iandador, iEtapa,
				iLote, iEdificio, iEntrada, cDepartamento, cComplemento, cEntreCalles,
				sOtros, cSituacion, sCausa,
				mIngresoMensual, cPuesto, cLugarTrabajo, cTelefono, cTelTrab, cExtTrab,
				cDescripcion, cDescripPermTrabajo, cActividad,
				cNumEstadoTrab, cNumCiudadTrab, cPoblacionTrab, cNumColoniaTrab, cNumCalleTrab, cNumExteriorTrab,
				cNumInteriorTrab, cCodPostalTrab, cPuntoCardinalTrab, iManzanaTrab, iandadorTrab, iEtapaTrab,
				iLoteTrab, iEdificioTrab, iEntradaTrab, cDepartamentoTrab, cComplementoTrab, cEntreCallesTrab,
				iOtrosTrab,
				cNumSucursal, dFechaUltDisp, fMontoUltDisp,
				fMontoComi, fAbonoMensual, mMontoInteresCap, mMontoIvaIntCap,
				fSaldoMesAnt, fSaldoMesActual, fSaldoMesVencido, fSaldoMesNoExig, dFechaUltMov, cUltMov,
				fMontoUltMov, mIntVencido_ord, mIvaIntVencido_ord, mIntVencido_bal, mIvaIntVencido_bal,
				mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, cMesesVencidos, cNumTarjeta,
				--cNumCte,
				cRefCoppel, dFechaHoy,
				cFechaApertura, cTelefonoCel, cSituacionPago, cMesesHistoria, cTipoGrupo, cEvaluacc, pMonto_otorgado, cNumproducto,
				vEnvioMC, vAtendidaMC
				,cflag_cteconf, dfec_ult_pag,cAct, cAtr, v_fecha_vencido, v_dias_vencido --IPCB
			);
			--RQI CV productos (8100,7000)
			IF cNumProducto in ('6001','8100','7000','8500') then
				IF cNumProducto = '6001' then		--TDC Clasica
					LET cNumRegTotal_TC = cNumRegTotal_TC + 1;
					LET sSaldoActTotal_TC = sSaldoActTotal_TC + fSaldoMesActual;
				ELIF cNumProducto = '8100' then		--TDC Oro
					LET cNumRegTotal_TCO = cNumRegTotal_TCO + 1;
					LET sSaldoActTotal_TCO = sSaldoActTotal_TCO + fSaldoMesActual;
				ELIF cNumProducto = '7000' then     --TDC Platino
					LET cNumRegTotal_TCP = cNumRegTotal_TCP + 1;
					LET sSaldoActTotal_TCP = sSaldoActTotal_TCP + fSaldoMesActual;	
				ELIF cNumProducto = '8500' then     --TDC Grupo Coppel
					LET cNumRegTotal_TGC = cNumRegTotal_TGC + 1;
					LET sSaldoActTotal_TGC = sSaldoActTotal_TGC + fSaldoMesActual;	
				END IF;				
				UPDATE sd_maecred
				SET id_unidad_prod = 1 
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito;				
				
			ELIF cNumProducto = '6011' then
				LET cNumRegTotal_Rees = cNumRegTotal_Rees + 1;
				LET sSaldoActTotal_Rees = sSaldoActTotal_Rees + fSaldoMesActual;
				UPDATE sd_maecredcrd
				SET id_origen = 1
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito_rees;
				
			--AAME RQM 10 393 20150623 Se contemplan los dos nuevos productos (7600,7700) 				
			ELIF cNumProducto in ('6300','7600','7700','6800') then  ---> AGREGAR 6800  Y AGREGAR UN ELIF 6800 CON VARIABLES NUEVAS  cNumRegTotal_presflex y sSaldoActTotal_PresFlex
				IF cNumProducto = '6300' then
					LET cNumRegTotal_pres = cNumRegTotal_Pres + 1;
					LET sSaldoActTotal_Pres = sSaldoActTotal_Pres + fSaldoMesActual;
				ELIF cNumProducto = '7600' then			
					LET cNumRegTotal_pres18 = cNumRegTotal_Pres18 + 1;
					LET sSaldoActTotal_Pres18 = sSaldoActTotal_Pres18 + fSaldoMesActual;
				ELIF cNumProducto = '7700' then
					LET cNumRegTotal_pres24 = cNumRegTotal_Pres24 + 1;
					LET sSaldoActTotal_Pres24 = sSaldoActTotal_Pres24 + fSaldoMesActual;	
				ELIF cNumProducto = '6800' then
					LET cNumRegTotal_presflex = cNumRegTotal_Presflex + 1;
					LET sSaldoActTotal_Presflex = sSaldoActTotal_Presflex + fSaldoMesActual;	
				END IF;				
				UPDATE sd_maecredcrd
				SET id_origen = 1
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito_rees;
			--Se agrega actualizacion de este campo cuando el producto sea CrediNomina RQM 09 329
			ELIF cNumProducto = '6400' then
				LET cNumRegTotal_cnom = cNumRegTotal_cnom + 1;
				LET sSaldoActTotal_cnom = sSaldoActTotal_cnom + fSaldoMesActual;
				UPDATE sd_maecredcrd
				SET id_origen = 1
				WHERE empresa = pEmpresa AND num_credito = cNumCredito_rees;
			END IF;
		COMMIT WORK;
	END IF;
		LET mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord = 0,0,0,0;
		LET vEnvioMC	= 0;
		LET vAtendidaMC = 0;
	END FOREACH;

	--AAME RQM 10 393 20150623 Se contemplan los dos nuevos productos (7600,7700) 
	FOREACH 
	 SELECT num_credito  into vlCreditoBal
	  from bdicobranza:cb_rep_cart_quebrantar
	  where fechareporte = dFechaHoy
	  and producto IN ('6300','7600','7700','6800')  ---> AGREGAR 6800
		
	LET v_sql = "select int_venc_bal"||day(dFechaAnt) ||", ivaint_venc_bal"||day(dFechaAnt) ||","|| 
	            " intvenc"||day(dFechaAnt) || "- int_venc_bal"||day(dFechaAnt) ||
				",ivaintvenc"||day(dFechaAnt) || "-ivaint_venc_bal"||day(dFechaAnt)  ||
             	" from bdicred:sd_sdodiariocrd a " ||
				" where a.num_credito ='"|| trim(vlCreditoBal)||"'"||
				"   and a.fecha = mdy('" || month(dFechaHoy) || "', '01','" || year(dFechaHoy)||"')";
    prepare xsql from v_sql;
    declare xcur cursor for xsql; 
    OPEN xcur;
    FETCH xcur into mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord;
    CLOSE xcur;
    FREE xcur;
    FREE xsql;
		update bdicobranza:cb_rep_cart_quebrantar 
		  set Int_Vencido_bal = mIntVencido_bal, 
		      Iva_Int_Vencido_bal =mIvaIntVencido_bal ,
			  Int_Vencido = mIntVencido_ord, 
			  Iva_Int_Vencido =mIvaIntVencido_ord
		where fechareporte = dFechaHoy
		and  num_credito = vlCreditoBal;
		
	END FOREACH;  


	
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6001', cNumRegTotal_TC,sSaldoActTotal_TC, dFechaHoy);
	--(8500)
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('8500', cNumRegTotal_TGC,sSaldoActTotal_TGC, dFechaHoy); -- TDC Grupo Coppel
	--RQI CV productos (8100,7000)
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('8100', cNumRegTotal_TCO,sSaldoActTotal_TCO, dFechaHoy); -- TDC Oro
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('7000', cNumRegTotal_TCP,sSaldoActTotal_TCP, dFechaHoy); -- TDC Platino
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6011', cNumRegTotal_Rees,sSaldoActTotal_Rees, dFechaHoy);
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6300', cNumRegTotal_Pres,sSaldoActTotal_Pres, dFechaHoy);
	--AAME RQM 10 393 20150623 Se contemplan los dos nuevos productos (7600,7700) 
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('7600', cNumRegTotal_Pres18,sSaldoActTotal_Pres18, dFechaHoy);
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('7700', cNumRegTotal_Pres24,sSaldoActTotal_Pres24, dFechaHoy);
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6400', cNumRegTotal_cnom,sSaldoActTotal_cnom, dFechaHoy); --se agregÃ³ de acuerdo a RQM 09 329
    INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras values ('6800', cNumRegTotal_Presflex,sSaldoActTotal_Presflex, dFechaHoy);
---> AGREGAR 6800 INSERT PARA 6800 CON LAS VALIABLES NUEVAS 

 
	EXECUTE PROCEDURE "informix".sp_gen_rep_cartera_quebrantar('001') INTO P_COD_RET;

	IF P_COD_RET <> '000000' then
		LET cMensajeRet = 'ERROR en la descarga de archivos para el reporte VENTA DE CARTERA';
		RETURN P_COD_RET, cMensajeRet;
	END IF;

	---**************************************************
	-- INI Respaldo y depuraciÃ³n de tabla creditos_venta_progapoyo (RQM 09 586. MACF) 2021-03-23
	SELECT count(*) INTO iCant_VtaProgApoyo
	  FROM bdicred:creditos_venta_progapoyo;

	LET iCant_VtaProgApoyo = NVL(iCant_VtaProgApoyo,0);
	
    IF iCant_VtaProgApoyo > 0 THEN
	
		select {+INDEX(bdicred:creditos_venta_progapoyo_his idx_creds_vta_progapoyo_his)} num_credito, fecha 
			from bdicred:creditos_venta_progapoyo_his where fecha = dFechaHoy AND num_credito != '' into temp crd_vta_apoyohis with no log;
	   
	   FOREACH WITH HOLD
	     SELECT num_credito INTO cNum_credito_VtaProgApoyo
	       FROM bdicred:creditos_venta_progapoyo
		   where num_credito not in(SELECT num_credito FROM crd_vta_apoyohis where fecha = dFechaHoy)
		 
		/*SELECT num_credito INTO cNum_credito_VtaProgApoyo_his
		   FROM bdicred:creditos_venta_progapoyo_his
		   WHERE num_credito = cNum_credito_VtaProgApoyo
		     AND fecha = dFechaHoy;
		   
		   LET cNum_credito_VtaProgApoyo_his = nvl(cNum_credito_VtaProgApoyo_his,'');
		   IF cNum_credito_VtaProgApoyo_his = '' THEN*/
		   LET cNum_credito_VtaProgApoyo = nvl(cNum_credito_VtaProgApoyo,'');
		   
		   IF cNum_credito_VtaProgApoyo <> '' THEN
		      INSERT INTO bdicred:creditos_venta_progapoyo_his (num_credito, fecha)
			  VALUES(cNum_credito_VtaProgApoyo, dFechaHoy);
		   
		   END IF;
		   
	   END FOREACH;	   
	   
	   
    END IF;	
	-- Fin Respaldo y depuraciÃ³n de tabla creditos_venta_progapoyo (RQM 09 586. MACF) 2021-03-23

	LET cMensajeRet = 'El proceso de VENTA DE CARTERA se realizo correctamente';

	LET P_COD_RET = '000000';

	---Actualizando tabla de parametros con valor igual a 0 cuando este sp se ejecute correctamente para que se puedan excluir los nuevos creditos
	IF  P_COD_RET = '000000' then
						UPDATE bdicred:sd_param
							SET valor = '0'
							WHERE cod_param = '108';
							
						-- SE GUARDA INFORMACION EN TABLA TEMPORAL PARA ELIMINAR BUSQUEDA SECUENCIAL.
						select {+INDEX(bdicred:creditos_venta_progapoyo_his idx_creds_vta_progapoyo_his)} num_credito, fecha 
							from bdicred:creditos_venta_progapoyo_his where fecha = dFechaHoy AND num_credito <> '' into temp crd_vta_apoyohis_2 with no log;
							
						SELECT count(*) INTO iCant_VtaProgApoyo_his
	                      FROM crd_vta_apoyohis_2
		                 WHERE fecha = dFechaHoy;
		
                        LET iCant_VtaProgApoyo_his = NVL(iCant_VtaProgApoyo_his,0);
		
		                IF iCant_VtaProgApoyo_his > 0 AND (iCant_VtaProgApoyo_his = iCant_VtaProgApoyo) THEN  --- y agregar comparar la cant de conteo de la creditos_venta_progapoyo
	   
	                       TRUNCATE bdicred:creditos_venta_progapoyo;
		 
	                    END IF;	
							
	END IF;
	TRUNCATE TABLE bdicred:sd_ctes_excluidos_vta;
	
	RETURN P_COD_RET,cMensajeRet;

END;
END procedure
DOCUMENT
'Version: 20130419.1116',
'Modificacion : Se Modifico SP para actualizar la tabla bdicred:sd_param con el campo valor = 0 cuando termine de ejecutarse correctamente el proceso',
'AUTOR: Marco Antonio Valenzuela Leon',
'FECHA: 19 Abril 2013',
'BD: bdicred',
'ModificaciÃ³n Se agregÃ³ producto 8100 y 7000 - TDC Oro y Platino realizando las adecuaciones necesarias para el nÃºmero de solicitud / crÃ©dito externo',
'AUTOR : Anayeli Alba Cano',
'FECHA : 25/May/2017',
'BD    : bdicred',
'ModificaciÃ³n Se agregÃ³ validaciÃ³n de Saldo Exigible para reestructuras, dandole un cliclo completo de vencimiento y 8 pagos consecutivos para que se cuenten solo meses de reestructura',
'AUTOR : Anayeli Alba Cano',
'FECHA : 25/May/2017',
'BD    : bdicred';

CREATE PROCEDURE "informix".sp_gen_pago_quitacondonacion ()
--EXECUTE PROCEDURE "informix".sp_gen_pago_quitacondonacion();
RETURNING CHAR(5), VARCHAR(90);    

DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr     		INTEGER;
DEFINE cErrorInfo   		VARCHAR(255,1);
DEFINE COD_RET      		CHAR(5);
DEFINE cCodRet2				CHAR(6);
DEFINE cCodRet      	    CHAR(6);
DEFINE cMen_ret 			VARCHAR(100,1);
DEFINE cNumeroFolio 	    CHAR(16);
DEFINE P_MENSAJE		    VARCHAR(90);
DEFINE v_empresa 		    CHAR(3);

DEFINE vNumCredito  	    CHAR(20);
DEFINE vNumCte 			    CHAR(20);
DEFINE vNumProducto         CHAR(4);
DEFINE vIndProc			    CHAR(1);
DEFINE vSucursal            CHAR(4);
DEFINE vFechaHoy            DATE;
DEFINE vCodRetFolio         CHAR(3);

DEFINE vFechaAplicacion     DATE;
DEFINE CodRet               CHAR(5); 
DEFINE g_Remanente			MONEY(14,2);
DEFINE g_IntMoraCob			MONEY(14,2);
DEFINE g_IntVencCob			MONEY(14,2);
DEFINE g_CapVencCob			MONEY(14,2);
DEFINE g_IntVigCob			MONEY(14,2);
DEFINE g_CapVigCob			MONEY(14,2); 
DEFINE g_Impuesto			MONEY(14,2);
DEFINE g_Comision			MONEY(14,2);
DEFINE g_Seguro				MONEY(14,2);
DEFINE cSQL                 CHAR(1000);
DEFINE cParamInsumo			CHAR(100);
DEFINE cParamRepCanMarcaje	CHAR(100);
DEFINE cRutaArch            CHAR(100);
DEFINE cRutaInsumo          CHAR(100);
DEFINE vSdoActual           DECIMAL(18,2);
DEFINE vCodRet              CHAR(5);
DEFINE vMontoPagoDia		DECIMAL(18,2);
DEFINE vTransacc     		CHAR(4);
DEFINE vExiste              SMALLINT;
DEFINE vExisteC             SMALLINT;
DEFINE vFechaCAut           DATE;

DEFINE vSaldoCred			DECIMAL(18,2);
DEFINE vSdoCapVigente		DECIMAL(18,2);
DEFINE vCapVencido			DECIMAL(18,2);
DEFINE vIntVigente			DECIMAL(18,2);
DEFINE vIntVencido			DECIMAL(18,2);
DEFINE vIntMora				DECIMAL(18,2);
DEFINE vIvaIntVig			DECIMAL(18,2); 
DEFINE vIvaIntVencido		DECIMAL(18,2); 
DEFINE vIvaIntMora			DECIMAL(18,2);
DEFINE vPagoTotal           DECIMAL(18,2);
DEFINE vFechaAplica         DATE;
DEFINE vFechaPagoTot        DATE;

DEFINE vCtaCheques			CHAR(20);
DEFINE vPagoRealizar		DECIMAL(18,2); 
DEFINE vPagoQuitaPorc		DECIMAL(18,2); 
DEFINE vFechaLimite  		DATE;
DEFINE vFechaUltPago		DATE;
DEFINE vBandera             CHAR(1);
DEFINE vFechTransac         DATE;
DEFINE vCrdbitacora         CHAR(20);
DEFINE v_indicador          CHAR(1);

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general   
DEFINE csg_codigo_ret			CHAR(6);
DEFINE csg_mensaje_ret			CHAR(80);
DEFINE csg_num_credito			CHAR(20);
DEFINE csg_cod_tipcred			CHAR(2);
DEFINE cStatus					CHAR(2);
DEFINE csg_fec_origen			DATE;
DEFINE csg_fec_prox_pago		DATE;
DEFINE csg_pago_min				MONEY(18,2);
DEFINE csg_fec_ult_pago			DATE;
DEFINE csg_plazo				INTEGER;
DEFINE csg_pagos_realizados		INTEGER;
DEFINE csg_linea_otorgada		MONEY(18,2);
DEFINE csg_tasa_interes			DECIMAL(9,6);
DEFINE csg_tasa_moratorios		DECIMAL(9,6);
DEFINE csg_monto_sbc			DECIMAL(14,2);
DEFINE csg_cap_vig				MONEY(18,2);
DEFINE csg_cap_trans			MONEY(18,2);
DEFINE csg_cap_vdo_exig			MONEY(18,2);
DEFINE csg_cap_vdo_no_exig		MONEY(18,2);
DEFINE csg_sdo_act_total_cap	MONEY(18,2);
DEFINE csg_int_vig				MONEY(18,2);
DEFINE csg_int_vdo				MONEY(18,2);
DEFINE csg_int_moratorios		MONEY(18,2);
DEFINE csg_int_mes				MONEY(18,2);
DEFINE csg_sdo_act_total_int	MONEY(18,2);
DEFINE csg_iva_int_vig			MONEY(18,2);
DEFINE csg_iva_int_vdo			MONEY(18,2);
DEFINE csg_iva_int_moratorios	MONEY(18,2);
DEFINE csg_iva_int_mes			MONEY(18,2);
DEFINE csg_sdo_act_total_iva	MONEY(18,2);
DEFINE csg_com_pend				MONEY(18,2);
DEFINE csg_iva_com				MONEY(18,2);
DEFINE csg_sdo_retenido			MONEY(18,2);
DEFINE csg_tot_liquidacion		MONEY(18,2);
DEFINE csg_int_devengado		MONEY(18,2);
DEFINE csg_iva_int_devengado	MONEY(18,2);
DEFINE csg_linea_disp			MONEY(18,2);
DEFINE csg_pagos_vdos			MONEY(18,2);
DEFINE csg_desc_status_cred		CHAR(60);
DEFINE csg_id_bloqueo_cred		INTEGER;
DEFINE csg_bloqueo_cta			CHAR(60);
DEFINE csg_id_causa_bloq_cred	CHAR(3);
DEFINE csg_causa_bloqueo_cta	CHAR(50);
DEFINE csg_id_sit_esp_cte		CHAR(1);
DEFINE csg_id_causa_esp_cte		INTEGER;
DEFINE csg_sit_esp_cte			CHAR(75);
DEFINE csg_id_sit_esp_cred		CHAR(1);
DEFINE csg_id_causa_esp_cred	INTEGER;
DEFINE csg_sit_esp_cred			CHAR(75);
DEFINE csg_dMoraBase        	DECIMAL(18,2);
DEFINE csg_dMoraCopete     		DECIMAL(18,2);
DEFINE csg_dIvamoraBase     	DECIMAL(18,2);
DEFINE csg_dIvaMoraCopete   	DECIMAL(18,2);
DEFINE g_Folio              	CHAR(16);

--Variables para realizar el cobro automatico del cliente
DEFINE cCodRetAux               CHAR(5);
DEFINE GLOBAL g_TranRet         CHAR(4)        DEFAULT "";
DEFINE GLOBAL g_FechaCargo      DATE           DEFAULT "";
DEFINE GLOBAL g_SdoDisp         DECIMAL(14,2)  DEFAULT 0;
DEFINE GLOBAL g_MtoRet          DECIMAL(14,2)  DEFAULT 0;
DEFINE cDivisa	                CHAR(2);
DEFINE g_SdoCta                 DECIMAL(14,2);
DEFINE g_StatusCtaCap           CHAR(1);
--DEFINE g_SdoDisp	            DECIMAL(14,2);
--DEFINE g_MtoRet	                DECIMAL(14,2);

DEFINE g_NumCredito             CHAR(20); 
DEFINE g_NumProducto            CHAR(4); 
DEFINE g_NumCte                 CHAR(20); 
DEFINE g_NombreCte              CHAR(150); 
DEFINE g_PagoEfectivo           DECIMAL(18,2);
DEFINE g_PagoCta                DECIMAL(18,2); 
DEFINE g_MontoOperacion         DECIMAL(18,2) ; 
DEFINE g_StatusActual           CHAR(60);

DEFINE g_SdoAnt                 DECIMAL(18,2);    
DEFINE g_IvaCom                 DECIMAL(18,2); 
DEFINE g_IntMora                DECIMAL(18,2); 
DEFINE g_IvaIntMora             DECIMAL(18,2); 
DEFINE g_IntVdo                 DECIMAL(18,2); 
DEFINE g_IvaIntVdo              DECIMAL(18,2); 
DEFINE g_IntOrdi                DECIMAL(18,2); 
DEFINE g_IvaIntOrdi             DECIMAL(18,2); 
DEFINE g_Capital                DECIMAL(18,2); 
DEFINE g_MtoPago                DECIMAL(18,2); 
DEFINE g_CtaEje                 CHAR(20); 
DEFINE g_SdoActual              DECIMAL(18,2); 
DEFINE g_PagoMin                DECIMAL(18,2); 
DEFINE g_FechaLimite            CHAR(17);
DEFINE vDescripcion             CHAR(95);
DEFINE vEstatus                 CHAR(2);
DEFINE wBegin                   CHAR(1);
DEFINE cRuta CHAR (50);


ON EXCEPTION SET iSqlErr	
		LET COD_RET = iSqlErr;
			LET P_MENSAJE = 'Error al ejecutar el proceso.';
			ROLLBACK WORK;
			  IF (wBegin = "S") THEN
				 BEGIN WORK;
			  END IF;
			RETURN COD_RET,P_MENSAJE;
    END EXCEPTION;
    
    ON EXCEPTION IN (-255)
        LET wBegin = "S";
        ROLLBACK WORK;
        BEGIN WORK;
    END EXCEPTION WITH RESUME;
    
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    LET wBegin = "N";
	
	
LET iSqlErr         		= 0;
LET iIsamErr        		= 0;
LET cErrorInfo      		= "";
LET COD_RET         		= "00000";
LET cMen_ret     			= "";
LET cNumeroFolio            = "";
LET cCodRet2                = '';
LET P_MENSAJE               = 'PROCESO EXITOSO';

LET vNumCredito             = '';
LET vNumCte                 = '';
LET vNumProducto            = '';
LET vIndProc                = '';
LET vSucursal               = '';
--LET vTransaccQuita		    = '';
LET vTransacc        		= '';
LET v_empresa 		        = '001';
LET vFechaHoy               = DATE(1);
LET cCodRet      	        = '';
LET vCodRetFolio            = '';

LET vCodRet					= '';
LET vMontoPagoDia			= 0;
--LET vSucursalDia			= '';
--LET vFolioDia				= '';

--LET vMontoPagoHis			= 0;
--LET vSucursalHis			= '';
--LET vFolioHis				= '';			

LET vSaldoCred			    = 0;
LET vSdoCapVigente			= 0;
LET vCapVencido				= 0;
LET vIntVigente				= 0;
LET vIntVencido			    = 0;
LET vIntMora				= 0;
LET vIvaIntVig				= 0; 
LET vIvaIntVencido			= 0; 
LET vIvaIntMora				= 0;
LET vExiste                 = 0;
LET vExisteC                = 0;
LET vFechaCAut              = '';
LET vPagoTotal              = 0;
LET vFechaAplica            = DATE(1);
LET vFechaPagoTot           = '';

LET vCtaCheques				= '';
LET vPagoRealizar			= 0; 
LET vPagoQuitaPorc			= 0; 
LET vFechaLimite  			= DATE(1);
LET vFechaUltPago			= '';
LET vSdoActual              = 0;
LET vBandera				= '0';
LET vFechTransac            = '';
LET vCrdBitacora            = '';
LET v_indicador             = '0';
LET g_Folio                 = '';
LET g_Remanente             = 0;
LET g_IntMoraCob 			= 0; 
LET g_IntVencCob 			= 0; 
LET g_CapVencCob 			= 0; 
LET g_IntVigCob 			= 0; 
LET g_CapVigCob 			= 0; 
LET g_Impuesto 				= 0; 
LET g_Comision 				= 0; 
LET g_Seguro 				= 0;

---VARIABLES PARA CACHAR LOS CAMPOS DEL PROCEDMIENTO DE sp_consulta_saldos_general
LET csg_codigo_ret				= "000000";
LET csg_mensaje_ret				= "";
LET csg_num_credito				= "";
LET csg_cod_tipcred				= "";
LET cStatus						= "";
LET csg_fec_origen				= DATE(1);
LET csg_fec_prox_pago			= DATE(1);
LET csg_pago_min				= 0.0;
LET csg_fec_ult_pago			= DATE(1);
LET csg_plazo					= 0;
LET csg_pagos_realizados		= 0;
LET csg_linea_otorgada			= 0.0;
LET csg_tasa_interes			= 0.0;
LET csg_tasa_moratorios			= 0.0;
LET csg_monto_sbc				= 0.0;
LET csg_cap_vig					= 0.0;
LET csg_cap_trans				= 0.0;
LET csg_cap_vdo_exig			= 0.0;
LET csg_cap_vdo_no_exig			= 0.0;
LET csg_sdo_act_total_cap		= 0.0;
LET csg_int_vig					= 0.0;
LET csg_int_vdo					= 0.0;
LET csg_int_moratorios			= 0.0;
LET csg_int_mes					= 0.0;
LET csg_sdo_act_total_int		= 0.0;
LET csg_iva_int_vig				= 0.0;
LET csg_iva_int_vdo				= 0.0;
LET csg_iva_int_moratorios		= 0.0;
LET csg_iva_int_mes				= 0.0;
LET csg_sdo_act_total_iva		= 0.0;
LET csg_com_pend				= 0.0;
LET csg_iva_com					= 0.0;
LET csg_sdo_retenido			= 0.0;
LET csg_tot_liquidacion			= 0.0;
LET csg_int_devengado			= 0.0;
LET csg_iva_int_devengado		= 0.0;
LET csg_linea_disp				= 0.0;
LET csg_pagos_vdos				= 0.0;
LET csg_desc_status_cred		= "";
LET csg_id_bloqueo_cred			= 0;
LET csg_bloqueo_cta				= "";
LET csg_id_causa_bloq_cred		= "";
LET csg_causa_bloqueo_cta		= "";
LET csg_id_sit_esp_cte			= "";
LET csg_id_causa_esp_cte		= 0;
LET csg_sit_esp_cte				= "";
LET csg_id_sit_esp_cred			= "";
LET csg_id_causa_esp_cred		= 0;
LET csg_sit_esp_cred			= "";
LET csg_dMoraBase               = "";
LET csg_dMoraCopete             = "";
LET csg_dIvamoraBase            = "";
LET csg_dIvaMoraCopete          = "";

--Variables para el cargo del pago del cliente a su cuenta de captacion

LET cCodRetAux                  = "00000";
LET cDivisa	                    = '';
LET g_SdoCta	                = 0;
LET g_StatusCtaCap              = '';
--LET g_SdoDisp	                = 0;
--LET g_MtoRet	                = 0;

LET g_NumCredito                = ''; 
LET g_CtaEje                    = ''; 
LET g_NumProducto               = ''; 
LET g_NumCte                    = ''; 
LET g_NombreCte                 = ''; 
LET g_PagoEfectivo              = 0;
LET g_PagoCta                   = 0; 
LET g_MontoOperacion            = 0; 
LET g_SdoActual                 = 0; 
LET g_StatusActual              = '';

LET g_SdoAnt                    = 0;   
LET g_IvaCom                    = 0; 
LET g_IntMora                   = 0; 
LET g_IvaIntMora                = 0; 
LET g_IntVdo                    = 0; 
LET g_IvaIntVdo                 = 0; 
LET g_IntOrdi                   = 0;  
LET g_IvaIntOrdi                = 0;  
LET g_Capital                   = 0;  
LET g_MtoPago                   = 0;    
LET g_PagoMin                   = 0;  
LET g_FechaLimite               = ''; 

LET g_TranRet                   = '';
LET g_FechaCargo                = date(1);
LET g_SdoDisp                   = 0;
LET g_MtoRet                    = 0;
LET vDescripcion                = '';

LET vEstatus                    = 0;
				
BEGIN

    --SET debug FILE TO "/informix/sp_gen_pago_quitacondonacion2.out";
	--TRACE ON;
				
	SELECT fecha_hoy, fecha_hoy + 2 UNITS day, fecha_hoy - 2 UNITS day  INTO vFechaHoy, vFechaCAut, vFechaPagoTot FROM bdicred:"informix".sd_fechas WHERE empresa = v_empresa;
 	--LET vFechaPagoTot = mdy('08','10','2021'); --dos dias antes
	--LET vFechaHoy = mdy('08','12','2021'); --fecha actual
	--LET vFechaCAut = mdy('08','14','2021'); --dos dias despues																		 
 
	
--Pago de Condonacion y Quita/Castigos	
FOREACH WITH HOLD
--Buscar el credito en la tabla de insumos 
SELECT  fecha_insert,num_producto, a.numcte, a.num_credito, num_cuenta_chq, CASE WHEN indicador_proceso = 'Q' THEN mto_quita ELSE monto_condonado END pago_realizar, porc_quita, fecha_negociacion, a.indicador_proceso, a.estatus_proceso
INTO vFechaAplica, vNumProducto, vNumCte, vNumCredito, vCtaCheques, vPagoRealizar, vPagoQuitaPorc, vFechaLimite, vIndProc, vEstatus
FROM bdicred:"informix".sd_bitacora_quitacondonacion a 
WHERE a.estatus_proceso = 'PR'

BEGIN WORK;
	IF vCtaCheques IS NULL OR vCtaCheques = '' OR vCtaCheques = '0' THEN LET vCtaCheques = ''; END IF;
	    LET vFechaHoy=mdy(MONTH(vFechaHoy),DAY(vFechaHoy),YEAR(vFechaHoy)); --fecha actual
	    LET vFechaLimite=mdy(MONTH(vFechaLimite),DAY(vFechaLimite),YEAR(vFechaLimite)); --fecha negociacion		
	IF vFechaHoy > vFechaLimite THEN
		UPDATE bdicred:"informix".sd_bitacora_quitacondonacion SET estatus_proceso = 'CN', fecha_status = TODAY WHERE 
				num_credito = vNumCredito and estatus_proceso = vEstatus and fecha_insert = vFechaAplica;
		COMMIT WORK;
		CONTINUE FOREACH;
	END IF;

	IF vNumProducto NOT IN ('6300','7600','7700','6011','6800') THEN COMMIT WORK; CONTINUE FOREACH; END IF;
		
	IF vPagoRealizar > 0 AND vFechaHoy <= vFechaLimite THEN --Se aplica el pago de Condonacion o Quita/Castigo
	    --Para conocer si se realiza cobro automatico
		IF vCtaCheques != '' THEN --Si cuenta de cheques tiene saldo para realizar el pago
		  --Busqueda de saldo de cuenta de cliente
            SELECT divisa, sucursal
			INTO cDivisa, vSucursal
			FROM bdicred:"informix".sd_maecredcrd
			WHERE empresa  = '001' 
			AND num_credito = vNumCredito 
			AND num_producto IN ('6300','6800','7600','7700','6011')  
			AND status_cred NOT IN ('FF','FC','CV');
			
			-- Se obtiene el saldo de la cuenta identificada.
			CALL bdicheq:"informix".cons_saldo(vCtaCheques) RETURNING cCodRetAux,g_SdoCta,g_StatusCtaCap;

			IF (TRIM(cCodRetAux) <> "000") THEN
			    COMMIT WORK;
				CONTINUE FOREACH;
			END IF;

			-- Valida el saldo obtenido de la cuenta.
			IF NVL(g_SdoCta,0) <= 0 THEN
			    COMMIT WORK;
				CONTINUE FOREACH;
			END IF;

		   --Se realiza el cobro solo cuando la cuenta de captacion tenga todo el monto completo para realizar el cobro automatico 
            IF g_SdoCta >= vPagoRealizar AND vFechaCAut <=  vFechaLimite THEN 
				--*** Cobro automatico INICIO								
				-- SE GENERA EL FOLIO
				CALL bdicheq:"informix".sp_generafolionomina('CONDONACIONQUITA') RETURNING cCodRetAux, cNumeroFolio;		
				
				--Aplica el pago de Condonacion y Quita
				IF vNumProducto IN ('6300','7600','7700','6800','8100') THEN --Para PP y Prestamo Digital
					LET vTransacc = '620'; --PAGO CON CGO. A CTA. EN VENT. PREST. PERS.					
					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr(v_empresa,vNumCredito,vNumProducto,0,vPagoRealizar,'informix',vSucursal,NVL(cNumeroFolio,''),vTransacc)
					INTO CodRet, P_MENSAJE, g_NumCredito, g_CtaEje, g_NumProducto, g_NumCte, g_NombreCte, g_PagoEfectivo, g_PagoCta, g_MontoOperacion, g_SdoActual, g_StatusActual;
				ELIF vNumProducto IN ('6011') THEN --Para Reestructura	
					LET vTransacc = '620';
					LET vSucursal = '9290';
					EXECUTE PROCEDURE bdicred:sp_principal_suc_rr(v_empresa,vNumCredito,vNumProducto,0,vPagoRealizar,'informix',vSucursal,NVL(cNumeroFolio,''),vTransacc)
					INTO CodRet, P_MENSAJE, g_NumCredito, g_CtaEje, g_NumProducto, g_NumCte, g_NombreCte, g_PagoEfectivo, g_PagoCta, g_MontoOperacion, g_SdoActual, g_StatusActual;
				END IF;

			    --LET CodRet = '00000';
				IF CodRet::INTEGER <> 0	 THEN
				--insertar en bitacora de rechazos
				        LET vDescripcion = CodRet || ' ' ||P_MENSAJE;
				        INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
				        VALUES (vNumCredito, vNumCte, vIndProc, vDescripcion ,TODAY);
						COMMIT WORK;      ---KSOV SE AGREGA COMMIT INC 25 435 
						CONTINUE FOREACH; ---KSOV SE AGREGA CONTINUE FOREARCH INC 25 435 
				    --RETURN COD_RET,P_MENSAJE;--SE COMENTA PARA NO INTERRUMPIR EL FOREACH
				END IF;
			ELSE
--			   LET COD_RET = '00002';
			   LET P_MENSAJE = 'Hubieron cuentas SIN saldo suficiente para realizar el pago';
				INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
					VALUES (vNumCredito, vNumCte, vIndProc, 'La cuenta del cargo NO tiene saldo suficiente para realizar el pago' ,TODAY);
			   COMMIT WORK;
			   CONTINUE FOREACH;
			END IF;
		ELSE
--		   LET COD_RET = '00003';
		   LET P_MENSAJE = 'Hubieron cuentas sin cuenta de captacion asociada';
			INSERT INTO bdicred:"informix".sd_cuentas_rechazo_cq (num_credito, numcte, indicador_proceso, descripcion,fecha_insert)
				VALUES (vNumCredito, vNumCte, vIndProc, 'El credito no cuenta con una cuenta de captacion asociada' ,TODAY);
			COMMIT WORK;
		   CONTINUE FOREACH;
		END IF;   
  END IF; 
COMMIT WORK;

END FOREACH


RETURN COD_RET,P_MENSAJE;

END
END PROCEDURE;