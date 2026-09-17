CREATE PROCEDURE "informix".sp_rep_cartera_quebrantar_baja(pEmpresa char(3))
returning char(06) AS resultado,char(80) AS mensaje;

DEFINE cMensajeRet  CHAR(80);
DEFINE cSucursal, cUltMov, cNumSucursal, cNumproducto char(4);
DEFINE cNumCredito, cNumCte, cNumCredito_rees, cApellido1,cApellido2,cNombre1,cNombre2,cCurp, cNumTarjeta, cRefCoppel, cCreditoExterno, cCreditoGrupo char(20);
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
DEFINE dFechaMovtoSit, dFechaUltPago, dFechaHoy, dFechaCapAux, dFechaUltDisp, dFechaUltMov, dfechaant date;
DEFINE iMaxSecDisp, iCuantosDisp, iRef, cMesesVencidos, iCuantosPagos Integer;
DEFINE fIntenPago, fIntenPago_pres, fMontoUltDisp, fMontoComi, fAbonoMensual, fSaldoMesAnt, mMonto, mMontoInteresCap, mMontoIvaIntCap, fSaldoMesActual decimal(14,2);
DEFINE cFolioSuc char(16);
DEFINE fMontoUltMov, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fMontoPago decimal(14,2);
DEFINE mIntVencido_bal, mIvaIntVencido_bal decimal(14,2);
DEFINE SQL_ERR, ISAM_ERR INTEGER;
DEFINE ERROR_INFO,P_MENSAJE VARCHAR(80);
DEFINE P_COD_RET VARCHAR(6);
DEFINE cNombreArchivo1, cNombreArchivo2 CHAR(50);
-- jom ini
define cNumRegTotal_TC, cNumRegTotal_Rees, cNumRegTotal_Pres, cMesesHistoria, cNumRegTotal_cnom integer;
define sSaldoActTotal_TC, sSaldoActTotal_Rees, sSaldoActTotal_Pres, sSaldoActTotal_cnom, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado, mIvaIntMoraTotal, pMonto_otorgado decimal(14,2);
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

let vintbal     		=0;
let vivaintbal  		=0;
let vintorden		=0;
let	vivaintorden	=0;
let vlCreditoBal = '';

--SET DEBUG FILE TO 'sp_rep_cartera_quebrantar.out';
--TRACE ON;

BEGIN

	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
		LET P_COD_RET = SQL_ERR;
		LET P_MENSAJE = ERROR_INFO;
		IF cNumProducto = '6001' then
			LET cMensajeRet = ERROR_INFO ||'ERROR en el proceso VENTA DE CARTERA  ' || cNumCredito;
			RETURN P_COD_RET,cMensajeRet;
		ELSE
			LET cMensajeRet = ERROR_INFO ||'ERROR en el proceso VENTA DE CARTERA  ' || cNumCredito_rees;
			RETURN P_COD_RET,cMensajeRet;
		END IF;
		IF cBegin = 'S' then
			RollBack WORK;
		END IF;
	END EXCEPTION;

LET cBegin = 'N';
LET cMensajeRet = '' ;
LET cNumProducto, cNumCredito, cNumCte, cNumCredito_rees, cNumTarjeta, cRefCoppel, cCreditoExterno, cCreditoGrupo = '', '', '', '', '','','','';
LET cApellido1,cApellido2,cNombre1,cNombre2,cCurp = '','','','','';
--jom ini
LET cNumRegTotal_TC,sSaldoActTotal_TC,cNumRegTotal_Rees,sSaldoActTotal_Rees,cNumRegTotal_Pres,sSaldoActTotal_Pres,cNumRegTotal_cnom,sSaldoActTotal_cnom = 0,0,0,0,0,0,0,0;
--jom fin
LET cNumSucursal, P_COD_RET = '0000', '000000';
LET pNum_Vencidos, fIntenPago, fIntenPago_pres, cdiacorte, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fSaldoMesVencido = 0,0,0,0,0,0,0,0,0,0,0,0;
LET sSaldoActTotal_TC, sSaldoActTotal_Rees, sSaldoActTotal_Pres, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado,mIvaIntMoraTotal, pMonto_otorgado = 0,0,0,0,0,0,0,0;
LET mIntVencido_bal, mIvaIntVencido_bal = 0,0;
LET Ccodcaract, cSituacion = '', '';
LET iContador,sCausa,sNumVencidos  = 0, 0, 0;
LET vmonto50, vmonto4meses,vsdo_cap_insoluto = 0.00, 0.00, 0.00;
LET existe, utili_80, motivoexclusion,dSdoCapital, fAbonoMensual = 0, 0, 0, 0, 0;
LET dFechaAlta = date(1);
let dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra =0,0,0;
let dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra, dFechaUltDisp = date(1),date(1),date(1),date(1);

	SELECT Fecha_Hoy, pri_dia_mes, ult_dia_mes, fecha_ant
	INTO dFechaHoy, dfechapridiames, dfechaultdiames, dfechaant
	FROM bdicred:sd_fechas
	WHERE empresa = '001';

LET cNombreArchivo1= '/pisa/CarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';
LET cNombreArchivo2= '/pisa/CifrasCarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';

	
	BEGIN WORK;
		delete from bdicobranza:cb_rep_cart_quebrantar_baja;
	COMMIT WORK;
	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar_baja;
	
	LET cBegin = 'N';

	SELECT a.num_producto, a.num_credito, a.numcte, cod_caract_2,
	NVL((SELECT SUM(monto)
	FROM bdicred:sd_movhis
	WHERE empresa = '001'
	AND a.num_credito = num_credito
	AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
	AND codigo_ref = 1
	AND fecha_mov >= date(MDY(MONTH(dFechaHoy),'20',YEAR(dFechaHoy)) - 1 units MONTH)
	AND reversado = 'N'),0) monto50,
	NVL((SELECT SUM(monto)
	FROM bdicred:sd_movhis
	WHERE empresa = '001'
	AND a.num_credito = num_credito
	AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanual)
	AND codigo_ref = 1
	AND fecha_mov >= date(MDY(MONTH(dFechaHoy),'20',YEAR(dFechaHoy)) - 4 units MONTH)
	AND reversado = 'N'),0) monto4meses
	,b.mto_fin_ven_trasp, b.monto_otorgado,
	sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, 20 dia_corte, sdo_cap_insoluto 
	FROM bdicred:sd_maecred a, bdicred:sd_maesdos b
	WHERE a.empresa= '001'
	AND a.empresa = b.empresa
	AND a.num_credito = b.num_credito	
	AND a.campo_trab3 = 'BAJA' --FMJ DIC VENTA DE BAJA	
    AND a.status_cred <> 'CV'
	INTO temp selec_credito WITH NO LOG;


	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado,
		sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_producto = '6011'
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito
	AND a.campo_trab3 = 'BAJA' --FMJ DIC VENTA DE BAJA	
    AND a.status_cred <> 'CV'
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito);

	INSERT INTO selec_credito
	SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado,
		sucursal, NVL(fecha_apertura,date(1)) fecha_apertura, status_cred, dia_corte, sdo_cap_insoluto 
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001'
	AND a.empresa = b.empresa
	AND a.num_producto = '6300'
	AND a.num_credito = b.num_credito
	AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito	
	AND a.campo_trab3 = 'BAJA' --FMJ DIC VENTA DE BAJA	
    AND a.status_cred <> 'CV'
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito);	

	--Insertando Producto CrediNómina RQM 09 329 para Clientes >= 7 meses vencidos
	INSERT INTO selec_credito
	SELECT a.num_producto,a.num_credito,a.numcte,a.id_origen,0,0,b.mto_fin_ven_trasp,b.monto_otorgado,sucursal,NVL(fecha_apertura,date(1)) fecha_apertura,
	status_cred, dia_corte, sdo_cap_insoluto
	FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
	WHERE a.empresa = '001' AND a.empresa = b.empresa AND a.num_producto = '6400' AND a.num_credito = b.num_credito AND a.empresa = c.empresa
	AND a.num_credito = c.num_credito --AND a.status_cred = 'BT'
	AND a.campo_trab3 = 'BAJA'  --FMJ DIC VENTA DE BAJA	
    AND a.status_cred <> 'CV'
	AND a.num_credito not IN (SELECT num_credito FROM selec_credito);
	

--crea indices
	create index inx_selec_credito on selec_credito(num_credito);
	create index inx_selec_credito2 on selec_credito(numcte);
--actualiza estadisticas
	UPDATE statistics high FOR table selec_credito;

--Agregar a tabla sd_exclusiones_vtacartera creditos a excluir
--convenios
--defunciones
--prospectos reestructuras
--clientes fraude huella
--Agregando excepción: Clientes que no han llegado a su fecha facturación RQM 09 329

	SELECT cod_fun 
	FROM bdicred:sd_conceptospagomanualcrd 
	WHERE num_producto = '6300'
	group by 1
	into temp paso_pres;
	create unique index inx_paso_pres on paso_pres(cod_fun);
	update statistics high for table paso_pres;

	set isolation to dirty read;
	SELECT cod_fun 
	FROM bdicred:sd_conceptospagomanualcrd 
	WHERE num_producto = '6011'
	group by 1
	into temp paso_rees;
	create unique index inx_paso_rees on paso_rees(cod_fun);
	update statistics high for table paso_rees;

	--Creando tabla temporal paso_cnom para los cod_fun de CrediNomina
	set isolation to dirty read;
	SELECT cod_fun 
	FROM bdicred:sd_conceptospagomanualcrd 
	WHERE num_producto = '6400'
	group by 1
	into temp paso_cnom;
	create unique index inx_paso_cnom on paso_cnom(cod_fun);
	update statistics high for table paso_cnom;

-- Seleccion de movimientos, historico CRD
	SELECT a.num_credito, codigo_fun, codigo_ref, fecha_mov, monto
	FROM bdicred:sd_movhiscrd a, selec_credito b
	WHERE a.empresa = '001'
	AND a.num_credito = b.num_credito
	AND codigo_fun IN (SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd)
	AND codigo_ref = 1
	AND reversado = 'N'
	into temp movcrd with no log;

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

	create index inx_movcrdvta on movcrd(num_credito,codigo_fun,codigo_ref,fecha_mov);

	FOREACH WITH hold
	SELECT num_producto, num_credito, numcte, cod_caract_2, monto50, monto4meses, mto_fin_ven_trasp, monto_otorgado,
			sucursal, fecha_apertura, status_cred, nvl(dia_corte,0), sdo_cap_insoluto
	INTO cNumProducto, cNumCredito, cNumCte, Ccodcaract, vmonto50, vmonto4meses, pNum_Vencidos, pMonto_otorgado,
			cNumSucursal, cFechaApertura, cStatusCred, cdiacorte, vsdo_cap_insoluto
	FROM selec_credito 

	LET cNumCredito_rees = cNumCredito;

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
				AND capital_status IN ("2","7"));

		ELIF  cNumProducto = '6300' then

			--LET cNumCredito_rees = cNumCredito;
			LET fecha_mesant = dfechapridiames - 1;

--BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMBIO DE ESTA VARIABLE SI ES NECESARIO

			IF cdiacorte > DAY(fecha_mesant) then
			LET fecha_mesant = MDY(MONTH(fecha_mesant),DAY(fecha_mesant),YEAR(fecha_mesant));
			ELSE
			LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
			END IF;

			IF cdiacorte > DAY(dfechaultdiames) then
			LET cdiacorte = DAY(dfechaultdiames);
			END IF;

--- BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMIO DE ESTA VARIABLE SI ES NECESARIO
			
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE num_credito = cNumCredito_rees 
			  AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			  AND codigo_ref = 1;

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

			LET fecha_mesant = dfechapridiames - 1;

---BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMBIO DE ESTA VARIABLE SI ES NECESARIO

			IF cdiacorte > DAY(fecha_mesant) then
				LET fecha_mesant = MDY(MONTH(fecha_mesant),DAY(fecha_mesant),YEAR(fecha_mesant));
			ELSE
				LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
			END IF;
			
			IF cdiacorte > DAY(dfechaultdiames) then
			   LET cdiacorte = DAY(dfechaultdiames);
			END IF;

			---BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMIO DE ESTA VARIABLE SI ES NECESARIO

			LET fIntenPago = 0;

			---Generando la Intención de Pago del crédito
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM movcrd
			WHERE fecha_mov > fecha_mesant  -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			AND fecha_mov < (CASE WHEN cdiacorte > DAY(dfechaultdiames) then MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 1 UNITS DAY ELSE MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 0 UNITS DAY END)
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_cnom) 
			AND codigo_ref = 1;

			----Agregando excepción: Muestren una intención de pago de al menos 50% del monto que les corresponde de la mensualidad mas antigua
			SELECT nvl(capital_mto_cuota,0)
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd
			WHERE empresa   = pEmpresa
			AND num_credito = cNumCredito_rees
			and num_pago = 1;


			---Agregando excepción: Haber cubierto al menos el 20% del adeudo en los últimos 4 meses
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

		END IF;
	--END IF;

	--IF (pNum_Vencidos > 0) then
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
		NVL(ctepf.fecha_nac, date(1)) AS anionac, --año de nacimiento
		rpad(trim(NVL(ctepf.curp,'')),20,' ') as curp, --curp
		rpad(trim(NVL(ctepf.sexo,'')),1,' ') as sexo, --sexo
		rpad(trim(NVL(ctepf.estado_civil,'')),2,' ') as edocivil, --estado civil
		rpad(trim(NVL(ctepf.numidentifi,'')),30,' ') as numidentificacion, --numero de identificación
		rpad(TRIM(NVL(em.correo_elec,'')),60,' ') as email, --correo electronico
		rpad(TRIM(NVL(tipoidentif.descripcion,'')),40,' ') as tipoidentificacion, --tipo de identificación
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

	SELECT
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

	--Se obtiene el elemento respondido en la pregunta tiempo de residencia
	SELECT elemento
	INTO sElementoRes
	FROM bdisolic:ss_detalle_scoring
	WHERE num_solicitud= cNumCredito
	AND seccion= 2
	AND grupo  = 6;

	--Se obtiene la descripcion del elemento respondido en la pregunta tiempo de residencia
	SELECT descripcion
	INTO cDescripcion
	FROM bdisolic:ss_scoring_element
	WHERE seccion = 2
	AND grupo = 6
	AND elemento = sElementoRes;

	--Se obtiene el elemento respondido en la pregunta Tiempo de permanencia en la ocupacion actual
	SELECT elemento
	INTO sElemResTrabajo
	FROM bdisolic:ss_detalle_scoring
	WHERE num_solicitud = cNumCredito
	AND seccion = 2
	AND grupo = 8;

	--Se obtiene la descripcion del elemento respondido  en la pregunta Tiempo de permanencia en la ocupacion actual
	SELECT descripcion
	INTO cDescripPermTrabajo
	FROM bdisolic:ss_scoring_element
	WHERE seccion=2
	AND grupo=8
	AND elemento= sElemResTrabajo;

	select nvl(rpad(TRIM(telefono),13,' '),' ')
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
	IF cNumProducto = '6001' then
		SELECT sucursal
		INTO cSucursal
		FROM bdisolic:ss_solicitudes
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumCredito;
	ELSE
		SELECT sucursal
		INTO cSucursal
		FROM bdisolic:ss_solicitudes
		WHERE empresa = pEmpresa
		AND num_solicitud = cNumCredito_rees;
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
			--se agrega los meses de historia, eficiencia coppel, variable hit o no hit, grupo
			SELECT NVL(situacion_pago,0), NVL(meses_historia,0), case when NVL(evalua_cc,'') = 'X' then 'NO HIT' ELSE 'HIT' END, NVL(grupo,'')
			INTO cSituacionPago, cMesesHistoria, cEvaluacc, cGrupo
			FROM bdisolic:ss_resum_scor_fin
			WHERE empresa = pEmpresa
			AND num_solicitud = cNumCredito;
		END IF;

		IF cNumProducto = '6011' THEN
			LET cCreditoGrupo = cCreditoExterno;
		ELSE 
			LET cCreditoGrupo = cNumCredito;
		END IF;

		--Obteniendo el tipo de grupo al que pertenece el crédito
		select 
		case when ((cMesesHistoria >= 13 and cSituacionPago >= 85) or (cMesesHistoria >= 6 AND cSituacionPago >= 0 AND cSituacionPago < 85)) and cGrupo not in ('6')  then '1'
		when cMesesHistoria >= 6 and cMesesHistoria < 13 and cSituacionPago >= 85 and cGrupo not in ('6') then '2'
		when ((cMesesHistoria < 6 and cSituacionPago > 0) or (cMesesHistoria > 0 and cMesesHistoria < 6 and cSituacionPago <= 0) or (cSituacionPago = -1)) and cGrupo not in ('6') then '3'
		when cMesesHistoria = 0 and cSituacionPago = 0 and cGrupo not in ('6') then '5'
		when cGrupo = '6' then '6'
		else grupo end into cTipoGrupo
		from bdisolic:ss_resum_scor_fin
		where empresa = pEmpresa and num_solicitud = cCreditoGrupo;

		IF  cNumProducto = '6001' then

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
								

				SELECT {+INDEX (bdicred:sd_movhis inx_movhis6)} NVL(max(Monto),0)
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
			FOREACH
				SELECT first 2 fecha_mov, monto
				INTO vfmov , mMonto
				FROM bdicred:sd_movhis
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito
				AND codigo_fun  = '605'
				AND codigo_ref = 3
				AND reversado = 'N'
				union all
				SELECT fecha_mov, monto				
				FROM bdicred:sd_movhis_new
				WHERE empresa = pEmpresa
				AND num_credito = cNumCredito
				AND codigo_fun  = '605'
				AND codigo_ref = 3
				AND reversado = 'N'
				order by fecha_mov desc

				LET mMontoIvaIntCap  = mMontoIvaIntCap + mMonto;

			END FOREACH;

		--Se Obtiene el iva correspondiente a la sucursal que se asoció al Credito
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
			AND capital_status IN ('1','2','7');

			

		--Se obtiene el Iva de Intereses Moratorio pagado

		-- Se obtiene el Interes Moratorio Copete
			SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
				NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
				NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
				NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
				INTO mIntMoraCope, mIvaIntMoraCope, mIntMoraOrdi, mIvaIntMoraOrdi
			FROM sd_amortiza_credito
			WHERE  empresa = pempresa
			AND num_credito = cNumCredito
			AND capital_status IN ("2","7");

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

		ELSE --Campos para Reestructura, Préstamo Personal y CrediNomina

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

			if (cNumProducto = '6300') then
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

			IF cNumProducto = '6011' THEN
				IF cStatusCred = 'BT' THEN
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
					and b.codigo_fun = '602' 
					and b.codigo_ref = 2;
				ELSE
					select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO mIntVencido_ord, mIvaIntVencido_ord
					FROM bdicred:sd_amortiza_creditocrd
					WHERE empresa = pEmpresa
					AND num_credito= cNumCredito_rees
					AND capital_status in ('2','7');
				END IF;

				LET mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope = 0,0,0,0;

			ELIF cNumProducto in ('6300','6400') THEN

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
				AND capital_status IN ("2","7");

			END IF;

			LET cNumTarjeta = '';	

		END IF;		
		IF cNumProducto = '6300' then
		  LET mIntVencido_bal =0; 
		  LET mIvaIntVencido_bal =0;
		  LET mIntVencido_ord=0; 
		  LET mIvaIntVencido_ord=0;
		END IF;		
		BEGIN WORK;
			INSERT INTO bdicobranza:cb_rep_cart_quebrantar_baja
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
				fechaapertura, telefonocel, situacionpago, meseshistoria, grupo, evaluacc, monto_otorgado, producto
			)
			Values
			(	case when CNumproducto = '6001' then cNumCredito ELSE cNumCredito_rees END,
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
				cFechaApertura, cTelefonoCel, cSituacionPago, cMesesHistoria, cTipoGrupo, cEvaluacc, pMonto_otorgado, cNumproducto
			);
			IF cNumProducto = '6001' then 
				LET cNumRegTotal_TC = cNumRegTotal_TC + 1;
				LET sSaldoActTotal_TC = sSaldoActTotal_TC + fSaldoMesActual;
				
			ELIF cNumProducto = '6011' then
				LET cNumRegTotal_Rees = cNumRegTotal_Rees + 1;
				LET sSaldoActTotal_Rees = sSaldoActTotal_Rees + fSaldoMesActual;
				
			ELIF cNumProducto = '6300' then
				LET cNumRegTotal_pres = cNumRegTotal_Pres + 1;
				LET sSaldoActTotal_Pres = sSaldoActTotal_Pres + fSaldoMesActual;
				
			--Se agrega actualización de este campo cuando el producto sea CrediNomina RQM 09 329
			ELIF cNumProducto = '6400' then
				LET cNumRegTotal_cnom = cNumRegTotal_cnom + 1;
				LET sSaldoActTotal_cnom = sSaldoActTotal_cnom + fSaldoMesActual;
				
			END IF;
		COMMIT WORK;
	--END IF;
		LET mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord = 0,0,0,0;
	END FOREACH;

	FOREACH
	  SELECT num_credito  into vlCreditoBal
	  from bdicobranza:cb_rep_cart_quebrantar_baja
	  where fechareporte = dFechaHoy
	    and producto = '6300'
		
	LET v_sql = "select int_venc_bal"||day(dfechaant) ||", ivaint_venc_bal"||day(dfechaant) ||","|| 
	            " intvenc"||day(dfechaant) || "- int_venc_bal"||day(dfechaant) ||
				",ivaintvenc"||day(dfechaant) || "-ivaint_venc_bal"||day(dfechaant)  ||
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
		update bdicobranza:cb_rep_cart_quebrantar_baja 
		  set Int_Vencido_bal = mIntVencido_bal, 
		      Iva_Int_Vencido_bal =mIvaIntVencido_bal ,
			  Int_Vencido = mIntVencido_ord, 
			  Iva_Int_Vencido =mIvaIntVencido_ord
		where fechareporte = dFechaHoy
		and  num_credito = vlCreditoBal
	    and producto = '6300';
		
	END FOREACH;  
	
	LET cMensajeRet = 'El proceso de descarga de saldos de BAJA se realizo correctamente';

	LET P_COD_RET = '000000';

	
	RETURN P_COD_RET,cMensajeRet;

END;
END procedure
DOCUMENT
'Version: 20130419.1116',
'Modificación : Se Modificó SP para actualizar la tabla bdicred:sd_param con el campo valor = 0 cuando termine de ejecutarse correctamente el proceso',
'AUTOR: Marco Antonio Valenzuela León',
'FECHA: 19 Abril 2013',
'BD: bdicred';

CREATE PROCEDURE "informix".sp_rep_excluidos_ctesclean_behavior(pEmpresa CHAR(3))
							
RETURNING 
          CHAR(06) AS resultado,    CHAR(80) AS mensaje;

--GEV 201502 Proceso para generar reporte que fueron excluidos de la tabla clean behavior.
DEFINE vproceso         CHAR(4);
DEFINE cCod_RetIB       CHAR(6);
DEFINE dFechaHoy        DATE;
DEFINE dFechaAumLinCrd  DATE;
DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);
DEFINE cRutaArch        CHAR(100);
DEFINE cParamNomArch    CHAR(100);
DEFINE cNomArchivo      CHAR(150);
DEFINE cNomArchivo1      CHAR(150);
DEFINE cNomArchEjecSql  CHAR(100);
DEFINE cSQL             CHAR(2500);


--SET DEBUG FILE TO "sp_reporte_ctes_clean_behavior.out";
--TRACE ON;

LET vproceso        = '3401';
LET cCod_RetIB      = '000000';
LET dFechaHoy       = DATE(0); 
LET iSqlErr         = 0;
LET iIsamErr        = 0;
LET cErrorInfo      = "";
LET cCodRet         = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';    
LET cRutaArch       = '';
LET cNomArchivo     = '';
LET cNomArchivo1    = '';
LET cNomArchEjecSql = '';
LET cSQL            = '';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
        LET cCodRet = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, trim(cMensajeRet) || "-" || iIsamErr::CHAR, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 10;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '01') Returning cCod_RetIB;

    IF ( NVL(pEmpresa,"") = "" ) THEN
        LET cCodRet= '102005'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = pempresa;
    IF ( dFechaHoy IS NULL ) THEN
        LET cCodRet= '20013'; 
        SELECT descripcion INTO cMensajeRet
        FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
	END IF;

    SELECT trim(valor) INTO cParamNomArch FROM bdicred:sd_param WHERE cod_param = 110;
    IF ( NVL(cParamNomArch, "") = "" ) THEN
        LET cCodRet= '104006';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    SELECT trim(valor) INTO cRutaArch  FROM bdicred:sd_param WHERE cod_param = 103;
    IF ( NVL(cRutaArch, "") = "" ) THEN
        LET cCodRet = '104005';
        SELECT descripcion INTO cMensajeRet FROM bdicobranza:"informix".cb_errores WHERE origen = 3 AND codigo_error = cCodRet;
        IF cMensajeRet IS NULL THEN LET cMensajeRet = ""; END IF;
        CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '02') Returning cCod_RetIB;
        RETURN cCodRet, cMensajeRet;
    END IF;

    LET cNomArchivo = trim(cParamNomArch) || '_' || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchivo1 = trim(cParamNomArch) || '_Aux_' || lpad(day(dFechaHoy),2,'0') || lpad(month(dFechaHoy),2,'0') || lpad(year(dFechaHoy),4,'0') || '.txt';
    LET cNomArchEjecSql = 'Reporte_exclusion_Ctes_Clean.sql';
    
    -- Obtiene el reporte
    LET cSQL = '';
	LET cSQL = ' echo "Numero Credito|Puntaje|Monto de la linea Original|Increment Sugerido|Incremento Otorgados|No de Descartes|Candidato a revision de Buró| "> ' || TRIM(cRutaArch) || TRIM(cNomArchivo);
	SYSTEM cSQL;


    LET cSQL = '';
    LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRutaArch) || TRIM(cNomArchivo1) || " DELIMITER " || '''|'''
        || ' SELECT num_credito, score, monto_lcr_original, incremento_sugerido, increm_otorgados_actual, num_descartes_increm, '
        || ' candidato_buro FROM bdicred:sd_clientes_clean_behavior WHERE status_bit = ''RT'' and month(fecha_reporte) = month( ' || '''' || dFechaHoy || '''' 
        || ' ) AND year(fecha_reporte) = year( ' || '''' || dFechaHoy || '''' || '); ">' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql); 
    SYSTEM cSQL;

    LET cSQL = '';
    LET cSQL = 'chmod 777 '|| TRIM(cRutaArch)|| TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql);
    SYSTEM cSQL;

    LET cSQL = ''; 
    LET cSQL = "sed 's/|$//g' " || TRIM(cRutaArch) || TRIM(cNomArchivo1) || " >> " || TRIM(cRutaArch) || TRIM(cNomArchivo);
    SYSTEM cSQL;

    LET cSQL = '' ;
    LET cSQL = 'rm ' || TRIM(cRutaArch) || TRIM(cNomArchEjecSql) || '  ' ||  TRIM(cRutaArch) || TRIM(cNomArchivo1);
    SYSTEM cSQL;

    CALL bdicred:"informix".sp_inserta_bitacora(pEmpresa, vproceso, cCodRet, cMensajeRet, '03') Returning cCod_RetIB;

    RETURN cCodRet,cMensajeRet;

END
END PROCEDURE;