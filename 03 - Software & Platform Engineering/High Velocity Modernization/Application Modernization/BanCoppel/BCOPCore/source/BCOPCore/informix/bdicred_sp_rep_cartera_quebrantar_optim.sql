CREATE PROCEDURE "informix".sp_rep_cartera_quebrantar_optim(pEmpresa char(3))
returning char(06) AS resultado,
          char(80) AS mensaje;

DEFINE cMensajeRet  CHAR(80);
DEFINE cSucursal, cUltMov, cNumSucursal, cNumproducto char(4);
DEFINE cNumCredito, cNumCte, cNumCredito_rees, cApellido1,cApellido2,cNombre1,cNombre2,cCurp, cNumTarjeta, cRefCoppel char(20);
DEFINE pPagos, pNum_Vencidos, cdiacorte Smallint;
DEFINE cRfc, cTelefono, cTelTrab, cExtTrab char(13);
DEFINE cApellidoCasada          char(26);
DEFINE cSector,cEdoCivil        char(2);
DEFINE dFechaNac                date;
DEFINE cSexo                    char(1);
DEFINE cNumIdentificacion       char(30);
DEFINE cEmail                   char(60);
DEFINE cTipoIdentificacion      char(40);
DEFINE cNacionalidad            char(15);
DEFINE cNumEstado,cNumCiudad integer;
DEFINE cPoblacion, cComplemento,cDescripcion, cDescripPermTrabajo char(80);
DEFINE cNumColonia, cNumCalle integer;
DEFINE cNumExterior, cNumInterior char(10);
DEFINE cCodPostal, cCodPostalTrab char(5);
DEFINE cPuntoCardinal           char(1);
DEFINE iManzana, iandador, iEtapa, iLote, iEdificio, iEntrada, iManzanaTrab, iandadorTrab, iEtapaTrab, iLoteTrab, iEdificioTrab, iEntradaTrab, iContadorRegistros integer;
DEFINE cDepartamento, cDepartamentoTrab char(6);
DEFINE cEntreCalles, cEntreCallesTrab char(40);
DEFINE sOtros, sElementoRes, sElemResTrabajo, iOtrosTrab, sCausa, iContador, sNumVencidos smallint;
DEFINE mIngresoMensual          money(14,2);
DEFINE cPuesto                  char(3);
DEFINE cLugarTrabajo            char(25);
DEFINE cActividad         char(45);
---Domicilio de Trabajo
DEFINE cNumEstadoTrab, cNumCiudadTrab, cNumColoniaTrab, cNumCalleTrab integer;
DEFINE cPoblacionTrab, cComplementoTrab  char(80);
DEFINE cNumExteriorTrab, cNumInteriorTrab char(10);
DEFINE cPuntoCardinalTrab,cSituacion, cEvaluacionCC,cBegin char(1);
------- PENDIENTES DE GENERAR
DEFINE cExisteCC                char(2);
-----
DEFINE dFechaMovtoSit, dFechaUltPago, dFechaHoy, dFechaCapAux, vfechamax, dFechaUltDisp, dFechaUltCapitalizacion, dFechaUltMov date;
DEFINE iMaxSecDisp, iCuantosDisp, iRef, cMesesVencidos, iMaxSecPago, iCuantosPagos Integer;
DEFINE fIntenPago, fIntenPago_pres, fMontoUltDisp, fMontoComi, fAbonoMensual, fSaldoMesAnt, mMonto, mMontoInteresCap, mMontoIvaIntCap, fSaldoMesActual decimal(14,2);
DEFINE cFolioSuc                char(16);
DEFINE fMontoUltMov, mMontoInteresCapMesAnt, mMontoIvaIntCapMesAnt, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fMontoPago decimal(14,2);
DEFINE mIntVencido_bal, mIvaIntVencido_bal decimal(14,2);
DEFINE SQL_ERR, ISAM_ERR INTEGER;
DEFINE ERROR_INFO,P_MENSAJE VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE cNombreArchivo1, cNombreArchivo2	CHAR(50);
-- jom ini
define cNumRegTotal_TC, cNumRegTotal_Rees, cNumRegTotal_Pres, cMesesHistoria integer;
define sSaldoActTotal_TC, sSaldoActTotal_Rees, sSaldoActTotal_Pres, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado, mIvaIntMoraTotal, pMonto_otorgado decimal(14,2);
define sFechadeCorte, cFechaApertura, fecha_mesant, dfechapridiames, dfechaultdiames date;
-- jom fin
define var_rga                char(05);
define Ccodcaract             char(03);
DEFINE cTelefonoCel           char(13);
DEFINE cSituacionPago         decimal(5,2);
DEFINE cEvaluacc              char(01);
DEFINE vmonto50, vmonto4meses,vsdo_cap_insoluto decimal(18,2);
DEFINE existe, utili_80, motivoexclusion  smallint;
DEFINE dFechaAlta date;
DEFINE cStatusCred          CHAR(02);
DEFINE dSdoCapital decimal(18,2);
DEFINE dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra decimal(18,2);
DEFINE dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra date;

--SET DEBUG FILE TO '/pisa/ricardo/ventacartera/sp_rep_cartera_quebrantar.out';
--TRACE ON;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;

--        drop table temp_cb_rep_cart_quebrantar;
        IF  cNumProducto = '6001' then
            LET cMensajeRet = 'ERROR en el proceso VENTA DE CARTERA  ' || cNumCredito;
--            RETURN P_COD_RET || ' ' || cNumCredito;
            RETURN P_COD_RET,cMensajeRet;
        ELSE
            LET cMensajeRet = 'ERROR en el proceso VENTA DE CARTERA  ' || cNumCredito_rees;
--            RETURN P_COD_RET || ' ' || cNumCredito_rees;
            RETURN P_COD_RET,cMensajeRet;
        END IF;
        IF cBegin = 'S' then
            RollBack WORK;
		END IF;
    END EXCEPTION;

LET cBegin = 'N';
LET vfechamax = null;
LET cMensajeRet  = '' ;
LET cNumProducto, cNumCredito, cNumCte, cNumCredito_rees, cNumTarjeta, cRefCoppel = '', '', '', '', '','';
LET cApellido1,cApellido2,cNombre1,cNombre2,cCurp = '','','','','';
--jom ini
LET cNumRegTotal_TC, sSaldoActTotal_TC , cNumRegTotal_Rees, sSaldoActTotal_Rees, cNumRegTotal_Pres, sSaldoActTotal_Pres = 0, 0, 0, 0, 0 ,0 ; 
--jom fin
LET cNumSucursal, P_COD_RET = '0000', '000000';
LET pNum_Vencidos, fIntenPago, fIntenPago_pres, cdiacorte, mPorcIva, mIntVencido_ord, mIvaIntVencido_ord, mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope, fSaldoMesVencido = 0,0,0,0,0,0,0,0,0,0,0,0;
LET sSaldoActTotal_TC, sSaldoActTotal_Rees, sSaldoActTotal_Pres, fSaldoMesVencido, fSaldoMesNoExig, mIvaIntMoraPagado,mIvaIntMoraTotal, pMonto_otorgado = 0,0,0,0,0,0,0,0;
LET mIntVencido_bal, mIvaIntVencido_bal = 0,0;
LET Ccodcaract, cSituacion = '', '';
LET iContador,sCausa,sNumVencidos  = 0, 0, 0;
LET vmonto50, vmonto4meses,vsdo_cap_insoluto = 0.00, 0.00, 0.00;
LET existe, utili_80, motivoexclusion,dSdoCapital  = 0, 0, 0, 0;
LET dFechaAlta = date(1);
let dAtmDispMonto, dMontoUltimoPago,dMontoUltimaCompra =0,0,0;
let dtAtmDispFecha,dtFechaUltimoPago,dtFechaUltimaCompra = date(1),date(1),date(1);

	SELECT Fecha_Hoy, pri_dia_mes, ult_dia_mes
    INTO dFechaHoy, dfechapridiames, dfechaultdiames
    FROM bdicred:sd_fechas
    WHERE empresa = '001';
--rss remporal para pruebas
--LET dFechaHoy = MDY('09','26','2012');
--LET dfechapridiames = MDY('09','01','2012');
--LET dfechaultdiames = MDY('09','30','2012');
--rss remporal para pruebas

LET cNombreArchivo1= '/pisa/CarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';
LET cNombreArchivo2= '/pisa/CifrasCarteraQuebrantada' || LPAD(TRIM(MONTH(CURRENT::date)::CHAR(2)),2,'0') ||YEAR(CURRENT::date) || '.txt';

    BEGIN WORK;
       LET cBegin = 'S';
       DELETE FROM bdicobranza:cb_rep_cart_quebrantar_cifras_optim WHERE fechareporte = date(CURRENT);
    COMMIT WORK;

	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar_cifras_optim;

    BEGIN WORK;
       DELETE FROM bdicobranza:cb_rep_cart_quebrantar_optim WHERE fechareporte = date(CURRENT);
    COMMIT WORK;

	UPDATE statistics medium FOR table bdicobranza:cb_rep_cart_quebrantar_optim;

    BEGIN WORK;
       DELETE FROM bdicred:sd_exclusiones_ventacartera WHERE fecha_exclusion = date(CURRENT);
    COMMIT WORK;

    UPDATE statistics medium FOR table bdicred:sd_exclusiones_ventacartera;

    LET cBegin = 'N';

    SELECT cod_fun 
     FROM bdicred:sd_conceptospagomanualcrd 
    WHERE num_producto = '6300'
    group by 1
    into temp paso_pres;

    create unique index inx_paso_pres on paso_pres(cod_fun);
    update statistics high for table paso_pres;

    SELECT cod_fun 
     FROM bdicred:sd_conceptospagomanualcrd 
    WHERE num_producto = '6011'
    group by 1
    into temp paso_rees;

    create unique index inx_paso_rees on paso_rees(cod_fun);
    update statistics high for table paso_rees;

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
      ,b.mto_fin_ven_trasp, b.monto_otorgado
    FROM bdicred:sd_maecred a, bdicred:sd_maesdos b
    WHERE a.empresa= '001'
      AND a.empresa = b.empresa
      AND a.num_credito = b.num_credito
	  AND mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
      AND status_cred = 'BT'
      AND NVL(Cod_caract_2,'') = ''
      AND sdo_cap_insoluto >= 1000
    INTO temp selec_credito_optim WITH NO LOG;

-- agregan a la venta los clientes conflicto

    INSERT INTO selec_credito_optim
    SELECT  a.num_producto, a.num_credito, numcte, cod_caract_2,0,0,mto_fin_ven_trasp, b.monto_otorgado
    FROM bdicred:sd_maecred a,
         bdicred:sd_maesdos b,
         bdicred:sd_maecredanexo c
    WHERE a.empresa = '001'
      AND a.empresa = b.empresa
      AND a.num_credito = b.num_credito
      AND a.empresa = c.empresa
      AND a.num_credito = c.num_credito
	  AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '062')
      AND b.mto_fin_ven_trasp < (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '060')
      AND c.fecha_ult_pago is null
      AND sdo_cap_insoluto >= 1000
      AND a.num_credito not IN (SELECT num_credito FROM selec_credito_optim);

   INSERT INTO selec_credito_optim
   SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado
     FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
    WHERE a.empresa = '001'
	  AND a.empresa = b.empresa
	  AND a.num_producto = '6011'
	  AND a.num_credito = b.num_credito
	  AND a.empresa = c.empresa
	  AND a.num_credito = c.num_credito
      AND a.status_cred != 'CV'
	  AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '061')
      AND sdo_cap_insoluto >= 1000
	  AND a.num_credito not IN (SELECT num_credito FROM selec_credito_optim);

   INSERT INTO selec_credito_optim
   SELECT a.num_producto, a.num_credito, a.numcte, a.id_origen,0,0,b.mto_fin_ven_trasp, b.monto_otorgado
     FROM bdicred:sd_maecredcrd a, bdicred:sd_maesdoscrd b, bdicred:sd_maecredanexocrd c--, bdicred:sd_amortiza_creditocrd d
    WHERE a.empresa = '001'
	  AND a.empresa = b.empresa
	  AND a.num_producto = '6300'
	  AND a.num_credito = b.num_credito
	  AND a.empresa = c.empresa
	  AND a.num_credito = c.num_credito
      AND a.status_cred != 'CV'
	  AND b.mto_fin_ven_trasp >= (SELECT valor::INTEGER FROM bdicred:sd_param WHERE cod_param = '064') 
	  AND sdo_cap_insoluto >= 1000
	  AND a.num_credito not IN (SELECT num_credito FROM selec_credito_optim)
	  AND ( DAY(a.fecha_apertura) < day(dFechaHoy) - 1
            or 
			DAY(a.fecha_apertura) > day(dFechaHoy) + 1
		  );

--temporal solo para pruebas
--   select num_producto, num_credito, numcte, cod_caract_2, monto as monto50, monto_2 as monto4meses, mto_fin_ven_trasp, monto_otorgado
--    from bdicred:sd_selec_credito_optim_muestra
--   INTO temp selec_credito_optim WITH NO LOG;
--temporal solo para pruebas
--crea indices
    create index inx_selec_credito_optim on selec_credito_optim(num_credito);
    create index inx_selec_credito_optim2 on selec_credito_optim(numcte);
--actualiza estadisticas
    UPDATE statistics high FOR table selec_credito_optim;
	
--Agregar a tabla sd_exclusiones_vtacartera creditos a excluir
--convenios
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'01' as motivoexclusion from selec_credito_optim a
	inner join bdicobranza:cb_compac b on(b.numcuenta = a.num_credito and (b.fecha_compac + (b.plazo*7)) >= dFechaHoy)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
	
	DELETE FROM selec_credito_optim WHERE num_credito IN (SELECT numcuenta  FROM bdicobranza:cb_compac  WHERE (fecha_compac + (plazo*7)) >=dFechaHoy);
--defunciones
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'02' as motivoexclusion from selec_credito_optim a
	inner join bdisitesp:se_ctessitespcte b on(b.numcte = a.numcte and b.situacion = 'F' and b.causa = 42)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT)and num_credito = a.num_credito);
	
    DELETE FROM selec_credito_optim WHERE numcte IN (SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE situacion = 'F' AND causa = 42);
--prospectos reestructuras
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)  
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'03' as motivoexclusion from selec_credito_optim a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 35 )
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
	
    DELETE FROM selec_credito_optim WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 35);
--clientes testigo
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)    
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'04' as motivoexclusion from selec_credito_optim a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 60)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
	
    DELETE FROM selec_credito_optim WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 60);
--clientes prueba grupo3
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)      
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'05' as motivoexclusion from selec_credito_optim a
	inner join bdisitesp:se_ctessitespcred b on(b.numcred = a.num_credito and b.situacion = 'P' AND b.causa = 61)
	where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
	
    DELETE FROM selec_credito_optim WHERE num_credito IN (SELECT numcred FROM bdisitesp:se_ctessitespcred WHERE situacion = 'P' AND causa = 61);
--aclaraciones en proceso
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)           
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'06' as motivoexclusion 
	from selec_credito_optim a
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
	AND a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
--rss  poner copy
      DELETE FROM selec_credito_optim WHERE num_credito IN
         (SELECT pro.numero_cuenta
          FROM bdiaclaracion:acl_aclaracion  acl,
                bdiaclaracion:acl_tipo_evento eve,
                bdiaclaracion:acl_producto pro,
                bdiaclaracion:acl_movimiento mov
            WHERE acl.fky_tipo_evento = eve.pky_tipo_evento
            AND pro.pky_producto = acl.fky_producto
            AND acl.pky_aclaracion = mov.fky_aclaracion
            AND  acl.fky_estatus_aclaracion = 2);
--======================
--clientes con email
	insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)        
	select '001',a.num_producto,a.num_credito,a.numcte,date(CURRENT) as fechaexclusion,'07' as motivoexclusion from selec_credito_optim a
	inner join bdinteg:si_ctepf b on(b.numcte = a.numcte and b.email != '')
	where a.num_producto = '6300'
	and a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito);
--elimina clientes con email
    DELETE FROM selec_credito_optim WHERE numcte IN (SELECT numcte FROM bdinteg:si_ctepf WHERE numcte IN (SELECT numcte FROM selec_credito_optim WHERE num_producto = '6300') AND email != '' ) ;

	select a.num_producto,a.num_credito,a.numcte,a.mto_fin_ven_trasp,b.fecha_alta 
      from selec_credito_optim a
	inner join bdinteg:si_huella_temp b on (b.numcte = a.numcte and b.secuencia = (select max(secuencia) from bdinteg:si_huella_temp where numcte = b.numcte)
--                and round((date(today) - date(b.fecha_alta)) / 30.4,0) - 4 = a.mto_fin_ven_trasp 
                and b.status = 'M' )
    where a.num_credito not in (select num_credito from bdicred:sd_exclusiones_ventacartera where empresa = '001' and fecha_exclusion = date(CURRENT) and num_credito = a.num_credito)
    into temp posible_fraude with no log;

    create index idxtemp_credito on posible_fraude(num_credito);

    update statistics high for table posible_fraude;

    foreach with hold
        select num_producto, num_credito, numcte, mto_fin_ven_trasp,date(fecha_alta) 
          INTO cNumProducto, cNumCredito, cNumCte, pNum_Vencidos, dFechaAlta
          from posible_fraude

        if day(dFechaAlta) > 20 then 
           execute procedure bdicred:monthadd(date(dFechaAlta),+1) into dFechaAlta;
           let dFechaAlta = mdy(month(dFechaAlta),20,year(dFechaAlta));
        else
           let dFechaAlta = mdy(month(dFechaAlta),20,year(dFechaAlta));
        end if;

        select nvl(monto_vencido + mto_venc_trasp + cap_tras_no_venci,0),nvl(mto_fin_ven_trasp,0) into dSdoCapital,sNumVencidos
          from bdicred:sd_maesdoshist
         where fecha = dFechaAlta 
           and empresa = '001' 
           and num_credito = cNumCredito
           and monto_vencido + mto_venc_trasp + cap_tras_no_venci > 0;

--        if dSdoCapital is null or dSdoCapital = '' then let dSdoCapital = 0; end if;

        if dSdoCapital > 0 and round((date(today) - date(dFechaAlta)) / 30.42,0) - 3 = pNum_Vencidos -3 and sNumVencidos = 1 then
           insert into bdicred:sd_exclusiones_ventacartera (empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
                values ('001',cNumProducto, cNumCredito, cNumCte, date(CURRENT), '13');
           delete from selec_credito_optim where num_credito = cNumCredito;
        end if;
        let dFechaAlta = date(1);
        let sNumVencidos = 0;
    end foreach;
--rss  poner copy

	FOREACH WITH hold
	SELECT num_producto, num_credito, numcte, cod_caract_2, monto50, monto4meses, mto_fin_ven_trasp, monto_otorgado
	INTO   cNumProducto, cNumCredito, cNumCte, Ccodcaract, vmonto50, vmonto4meses, pNum_Vencidos, pMonto_otorgado
	FROM selec_credito_optim 

	IF  cNumProducto = '6001' then
		SELECT sdo_cap_insoluto
		INTO vsdo_cap_insoluto
		FROM bdicred:sd_maesdos 
		WHERE empresa  ='001'
		  AND num_credito = cNumCredito;

		if (vmonto50 > 50) then
			INSERT INTO bdicred:sd_exclusiones_ventacartera
			(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
			values 
			('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '10');

			continue FOREACH;
		end if;
		
		if (vmonto4meses > round((vsdo_cap_insoluto *.20),2)) then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '11');
			
			continue FOREACH;
		end if;
		
		IF (cNumCredito is null or cNumCredito = '') then
		   continue FOREACH;
		END IF;

	ELSE

		IF  cNumProducto = '6011' then

            LET cNumCredito_rees = cNumCredito;

            SELECT numcte, status_cred
            INTO cNumCte, cStatusCred
            FROM bdicred:sd_maecredcrd
            WHERE empresa = '001'
            AND num_credito= cNumCredito;

            SELECT dia_corte 
            INTO cdiacorte
            FROM bdicred:sd_maecredanexocrd
            WHERE empresa= pEmpresa
            AND num_credito = cNumCredito_rees; 

            LET fecha_mesant = dfechapridiames - 1;
			LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant));
					
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM bdicred:sd_movhiscrd
			WHERE empresa = pEmpresa
			AND fecha_mov > fecha_mesant -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			AND fecha_mov < MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy))
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_rees) 
			AND codigo_ref = 1
			AND reversado = 'N';
			
			SELECT capital_mto_cuota
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd a
			WHERE a.empresa   = pEmpresa
			AND a.num_credito = cNumCredito_rees
			AND a.fecha_cuota = (SELECT min(fecha_cuota)
								  FROM bdicred:sd_amortiza_creditocrd
								 WHERE empresa  = pEmpresa
								   AND num_credito = cNumCredito_rees
								   AND capital_status IN ("2","7")
								);
			
			IF fIntenPago >= (fAbonoMensual * .5) then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '08');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;

		ELIF  cNumProducto = '6300' then

			LET cNumCredito_rees = cNumCredito;
			
            SELECT dia_corte 
            INTO cdiacorte
            FROM bdicred:sd_maecredanexocrd
            WHERE empresa= pEmpresa
            AND num_credito = cNumCredito; 
		
		    LET fecha_mesant = dfechapridiames - 1;
			
--- BLOQUE PARA EVITAR GENERAR FECHAS INEXISTENTES USANDO MDY (MES,cdiacorte, AÑO) Y HACER EL CAMBIO DE ESTA VARIABLE SI ES NECESARIO

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
			FROM bdicred:sd_movhiscrd
			WHERE empresa = pEmpresa
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			AND codigo_ref = 1
			AND reversado = 'N';
			
			IF pNum_Vencidos < 7 AND fIntenPago > 0 THEN -- Punto 1.3 RQM 09 274
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				VALUES 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '09');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
			
			LET fIntenPago = 0;

			SELECT NVL(SUM(monto),0)
			INTO fIntenPago
			FROM bdicred:sd_movhiscrd
			WHERE empresa = pEmpresa
			AND fecha_mov > fecha_mesant  -- ">= fecha_mesant" reemplazo esta condicion porque es a partir del primero de mes y no un dia antes
			AND fecha_mov < (CASE WHEN cdiacorte > DAY(dfechaultdiames)
			                      then MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 1 UNITS DAY
								  ELSE MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) + 0 UNITS DAY
						     END
							) 
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			AND codigo_ref = 1
			AND reversado = 'N';
			
			SELECT nvl(capital_mto_cuota,0)
			INTO fAbonoMensual 
			FROM bdicred:sd_amortiza_creditocrd
			WHERE empresa   = pEmpresa
			  AND num_credito = cNumCredito_rees
              and num_pago = 1;
			
			IF fIntenPago >= (fAbonoMensual * .5) then -- Punto 2.1 RQM 09 274
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '08');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
			
			IF fIntenPago >= 50 then -- Punto 2.2 RQM 09 274 Inciso B
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '10');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
			
			LET fecha_mesant = dfechapridiames - 3 UNITS MONTH;
			LET fecha_mesant = fecha_mesant - 1 UNITS DAY;
			--LET fecha_mesant = fecha_mesant - 3 UNITS MONTH; marco eror en credito 630000045512
			--LET fecha_mesant = MDY(MONTH(fecha_mesant),cdiacorte,YEAR(fecha_mesant)); con esta condicion se cambia para que sea de corte a corte
			
			SELECT NVL(SUM(monto),0)
			INTO fIntenPago_pres
			FROM bdicred:sd_movhiscrd
			WHERE empresa   = pEmpresa
			AND fecha_mov >= fecha_mesant 
			AND fecha_mov <= dFechaHoy --MDY(MONTH(dFechaHoy),cdiacorte,YEAR(dFechaHoy)) con esta condicion se cambia para que sea de corte a corte
			AND num_credito = cNumCredito_rees 
			AND codigo_fun IN (SELECT cod_fun FROM paso_pres) 
			AND codigo_ref = 1
			AND reversado = 'N';
			
			IF fIntenPago_pres >= ( SELECT (monto_otorgado * .2) FROM bdicred:sd_maesdoscrd WHERE empresa = pEmpresa AND num_credito = cNumCredito_rees ) then
				INSERT INTO bdicred:sd_exclusiones_ventacartera
				(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
				values 
				('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '11');
				LET cNumProducto, cNumCredito_rees, cNumCredito, cNumCte, fIntenPago, fIntenPago_pres, fAbonoMensual = '','','','',0,0,0;
				CONTINUE FOREACH;
			END IF;
		END IF;
	END IF;

	IF (pNum_Vencidos > 0) then
        LET cMesesVencidos = pNum_Vencidos;

			SELECT  LIMIT 1
						rpad(TRIM(NVL(cte.apell_paterno,'')),20,' ') AS apellpaterno,       --apellido 1
						rpad(TRIM(NVL(cte.apell_materno,'')),20,' ') AS apellmaterno,     --apellido 2
						rpad(TRIM(NVL(cte.nombre1,'')),20,' ') AS nombre1,      -- nombre 1
						rpad(TRIM(NVL(cte.nombre2,'')),20,' ') AS nombre2,      -- nombre 2
						rpad(TRIM(NVL(cte.rfc,'')),13,' ')     as rfc, -- rfc
						rpad(TRIM(NVL(cte.apell_casada,'')),26,' ') as apellcasada, -- apellido de casada
						rpad(TRIM(NVL(cte.sector,'')),2,' ') AS sector, -- sector
						lpad(TRIM(NVL(actesp.descripcion,'')),45,' ') as actividad, --actividad o giro de negocio

						NVL(ctepf.fecha_nac, date(1)) AS anionac,    -- año de nacimiento
						rpad(trim(NVL(ctepf.curp,'')),20,' ') as curp, -- curp
						rpad(trim(NVL(ctepf.sexo,'')),1,' ') as sexo, -- sexo
						rpad(trim(NVL(ctepf.estado_civil,'')),2,' ') as edocivil, -- estado civil
						rpad(trim(NVL(ctepf.numidentifi,'')),30,' ') as numidentificacion, --numero de identificación
						rpad(TRIM(NVL(ctepf.email,'')),60,' ') as email, -- correo electronico

						rpad(TRIM(NVL(tipoidentif.descripcion,'')),40,' ') as tipoidentificacion, -- tipo de identificación

						rpad(TRIM(NVL(nac.descripcion,'')),15,' ') as nacionalidad, -- nacionalidad

						rpad(TRIM(NVL(ing.nombre_empresa,'')),25,' ') AS lugartrabajo,    -- lugar de trabajo
						NVL(ing.ingreso_mensual, 0) AS ingresomensual,     -- ingreso mensual
						rpad(TRIM(NVL(ing.puesto,'')),3,'0') as puesto -- descripcion puesto
			INTO
						cApellido1, cApellido2, cNombre1, cNombre2, cRfc, cApellidoCasada,
						cSector, cActividad, dFechaNac, cCurp, cSexo, cEdoCivil, cNumIdentificacion,
						cEmail, cTipoIdentificacion, cNacionalidad, cLugarTrabajo, mIngresoMensual, cPuesto

			FROM  bdinteg:si_cliente cte
			LEFT OUTER JOIN bdinteg:si_actesp  actesp  ON (actesp.empresa= cte.empresa AND actesp.codigo=cte.actividad_esp)
			LEFT OUTER JOIN bdinteg:si_ctepf   ctepf   ON (ctepf.empresa=cte.empresa AND ctepf.numcte = cte.numcte)
			LEFT OUTER JOIN bdinteg:si_tipoidentif tipoidentif ON (tipoidentif.codidentif=ctepf.codidentifi)
			LEFT OUTER JOIN bdinteg:si_nacion nac  ON (nac.nacion = ctepf.nacionalidad)
		    LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.empresa=cte.empresa AND ing.tipo_ingreso = 'T' AND ing.numcte = cte.numcte AND ing.sec_ingreso= (SELECT MAX(sec_ingreso)
                                                                                                                                              FROM bdinteg:si_ingresos ing1
                                                                                                                                              WHERE ing1.empresa=cte.empresa
                                                                                                                                              AND ing1.numcte = cte.numcte
																																			  AND ing1.tipo_ingreso= 'T'))
			WHERE cte.empresa= pEmpresa
			AND cte.numcte= cNumCte;

        SELECT
            --rpad(TRIM(NVL(edo1.nombre,'')),30,' ') as estado, -- descripcion del estado
            dir1.estado as estado, -- numero de estado
            case when (zonas1.numerociudadcoppel is null or zonas1.numerociudadcoppel = '' or zonas1.numerociudadcoppel = 0)
                 then dir1.numerociudad
                 ELSE zonas1.numerociudadcoppel
            END ciudad, -- numero de ciudad
            NVL(zonas1.poblacionzona, '')as poblacion,
            case when (zonas1.numerociudadcoppel is null or zonas1.numerociudadcoppel = '' or zonas1.numerociudadcoppel = 0)
                 then dir1.numerocolonia
                 ELSE zonas1.numerocoloniacoppel
            END colonia,  -- numero de colonia
            dir1.numerocalle as calle, -- numero de calle
            TRIM(dir1.numeroextcalle) AS numextcalle,   -- numero exterior
            TRIM(dir1.numerointcalle) AS numintecalle,  -- numero interior
            lpad(TRIM(dir1.cod_postal),5,'0') AS cod_postal,     -- codigo postal
            rpad(TRIM(dir1.puntocardinal),1,' ') AS puntocardinal,   -- punto cardinal
            lpad(dir1.manzana,5,'0') AS manzana,     -- manzana
            lpad(dir1.andador,5,'0') AS andador,     -- andador
            lpad(dir1.etapa,5,'0')   AS etapa,     --etapa

            lpad(dir1.lote,5,'0')    AS lote,       -- lote
            lpad(dir1.edificio,5,'0') AS edificio,   --edificio
            lpad(dir1.entrada,5,'0') AS entrada,   -- entrada
            rpad(TRIM(dir1.departamento),6,' ') AS departamento,     -- departamento
            rpad(TRIM(dir1.observaciones),80,' ') AS complemento,  --   complemento
            rpad(TRIM(dir1.entre_calles),40,' ') AS entre_calles,    -- entre calles

            lpad(dir1.otros,2,'0') AS otros,     -- otros
            rpad(NVL(dir1.telefono1,''), 13, ' ') as Telefono,
            rpad(NVL(dir1.telefono2,''), 13, ' ') as TelefonoCel,
            rpad(NVL(dir2.telefono3,''), 13, ' ') as TelTrab,
            rpad(NVL(dir2.extension,''), 13, ' ') as ExtTrab,

            --Domiclio de Trabajo
            dir2.estado as estadoTrab, --Numero de estado
            case when (zonas2.numerociudadcoppel is null or zonas2.numerociudadcoppel = '' or zonas2.numerociudadcoppel = 0)
                 then dir2.numerociudad
                 ELSE zonas2.numerociudadcoppel
            END ciudad, -- numero de ciudad trabajo
            NVL(zonas2.poblacionzona, '')as poblacionTrab,
            case when (zonas2.numerociudadcoppel is null or zonas2.numerociudadcoppel = '' or zonas2.numerociudadcoppel = 0)
                 then dir2.numerocolonia
                 ELSE zonas2.numerocoloniacoppel
            END colonia,  -- numero de colonia trabajo
            dir2.numerocalle as calle, -- numero de calle
            TRIM(dir2.numeroextcalle) AS numextcalleTrab,   -- numero exterior
            TRIM(dir2.numerointcalle) AS numintecalleTrab,  -- numero interior
            lpad(TRIM(dir2.cod_postal),5,'0') AS cod_postalTrab,     -- codigo postal
            rpad(TRIM(dir2.puntocardinal),1,' ') AS puntocardinalTrab,   -- punto cardinal
            lpad(dir2.manzana,5,'0') AS manzanaTrab,     -- manzana
            lpad(dir2.andador,5,'0') AS andadorTrab,     -- andador
            lpad(dir2.etapa,5,'0')   AS etapaTrab,     --etapa

            lpad(dir2.lote,5,'0')    AS loteTrab,       -- lote
            lpad(dir2.edificio,5,'0') AS edificioTrab,   --edificio
            lpad(dir2.entrada,5,'0') AS entradaTrab,   -- entrada
            rpad(TRIM(dir2.departamento),6,' ') AS departamentoTrab,     -- departamento
            rpad(TRIM(dir2.observaciones),80,' ') AS complementoTrab,  --   complemento
            rpad(TRIM(dir2.entre_calles),40,' ') AS entre_callesTrab,    -- entre calles
            lpad(dir2.otros,2,'0') AS otrosTrab
        INTO
            cNumEstado,     cNumCiudad,      cPoblacion,     cNumColonia,       cNumCalle,      cNumExterior,
            cNumInterior,   cCodPostal,      cPuntoCardinal, iManzana,          iandador,       iEtapa,
            iLote,          iEdificio,       iEntrada,       cDepartamento,     cComplemento,   cEntreCalles,
            sOtros,         cTelefono,       cTelefonoCel,   cTelTrab,          cExtTrab,

            cNumEstadoTrab,     cNumCiudadTrab,     cPoblacionTrab,     cNumColoniaTrab,    cNumCalleTrab,      cNumExteriorTrab,
            cNumInteriorTrab,   cCodPostalTrab,     cPuntoCardinalTrab, iManzanaTrab,       iandadorTrab,       iEtapaTrab,
            iLoteTrab,          iEdificioTrab,      iEntradaTrab,       cDepartamentoTrab,  cComplementoTrab,   cEntreCallesTrab,
            iOtrosTrab
        FROM bdinteg:si_cliente cte
            LEFT OUTER JOIN bdinteg:si_direcciones_actual dir1        ON (dir1.numcte = cte.numcte AND dir1.tipo_dir  = '1')
            Left Outer Join bdinteg:si_catzonas    zonas1      On (dir1.numerociudad = zonas1.numerociudad AND dir1.numerocolonia = zonas1.numerocolonia)
            LEFT OUTER JOIN bdinteg:si_direcciones_actual dir2        ON (dir2.numcte = cte.numcte AND dir2.tipo_dir = '2')
            Left Outer Join bdinteg:si_catzonas    zonas2      On (dir2.numerociudad = zonas2.numerociudad AND dir2.numerocolonia = zonas2.numerocolonia)
        WHERE cte.NumCte     = cNumCte;

        -- Se obtiene el elemento respondido en la pregunta tiempo de residencia

        SELECT elemento
        INTO sElementoRes
        FROM bdisolic:ss_detalle_scoring
        WHERE num_solicitud= cNumCredito
        AND seccion= 2
        AND grupo  = 6;

        -- Se obtiene la descripcion del elemento respondido en la pregunta tiempo de residencia
        SELECT descripcion
        INTO cDescripcion
        FROM bdisolic:ss_scoring_element
        WHERE seccion = 2
        AND grupo = 6
        AND elemento = sElementoRes;

        --  Se obtiene el elemento respondido en la pregunta Tiempo de permanencia en la ocupacion actual

		SELECT elemento
        INTO sElemResTrabajo
        FROM bdisolic:ss_detalle_scoring
        WHERE num_solicitud = cNumCredito
        AND seccion = 2
        AND grupo = 8;

        -- Se obtiene la descripcion del elemento respondido  en la pregunta Tiempo de permanencia en la ocupacion actual
        SELECT descripcion
        INTO cDescripPermTrabajo
        FROM bdisolic:ss_scoring_element
        WHERE seccion=2
        AND grupo=8
        AND elemento= sElemResTrabajo;

----SEGUNDA PARTE DE CAMPOS

		IF  cNumProducto = '6001' then
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

            -- se agrega los meses de historia, eficiencia coppel y variable hit o no hit
            SELECT NVL(situacion_pago,0), NVL(meses_historia,0), case when NVL(evalua_cc,'') = 'X' then 'NO HIT' ELSE 'HIT' END
            INTO cSituacionPago, cMesesHistoria, cEvaluacc
            FROM bdisolic:ss_resum_scor_fin
            WHERE empresa = pEmpresa
            AND num_solicitud = cNumCredito;
		
		IF  cNumProducto = '6001' then
--dFechaUltDisp,fMontoUltDisp,
--dFechaUltMov,cUltMov,fMontoUltMov
--NVL(max(fecha_mov), date(1))
/*
            SELECT atm_disp_monto,nvl(atm_disp_fecha, date(1)),nvl(fecha_ultimo_pago, date(1)),monto_ultimo_pago,
                   nvl(fecha_ultima_compra, date(1)),monto_ultima_compra
              INTO dAtmDispMonto,dtAtmDispFecha,dtFechaUltimoPago,dMontoUltimoPago,
                   dtFechaUltimaCompra,dMontoUltimaCompra
*/
--            INTO dFechaUltDisp, iMaxSecDisp, iCuantosDisp

            SELECT nvl(fecha_ultimo_pago, date(1)),monto_ultimo_pago,
                   nvl(fecha_ultima_compra, date(1)),monto_ultima_compra
              INTO dtFechaUltimoPago,dMontoUltimoPago,
                   dtFechaUltimaCompra,dMontoUltimaCompra
            FROM bdicred:"informix".sd_indicador_cred
            WHERE empresa   = pEmpresa
            AND num_credito = cNumCredito;

            IF dMontoUltimaCompra > 0 then
/*                if dAtmDispMonto not in (null,'',0,date(1)) then 
                   let dFechaUltDisp = dtAtmDispFecha;
                   let fMontoUltDisp = dAtmDispMonto; 
                elif dMontoUltimaCompra not in (null,'',0,date(1)) then
                   let dFechaUltDisp = dtFechaUltimaCompra;
                   let fMontoUltDisp = dMontoUltimaCompra; 
                end if;*/

                let dFechaUltDisp = dtFechaUltimaCompra;
                let fMontoUltDisp = dMontoUltimaCompra; 

                SELECT limit 1 folio_suc into cFolioSuc
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                  AND fecha_mov = dFechaUltDisp
                  AND num_credito = cNumCredito
                  AND codigo_fun = '002' --and codigo_ref=40
                  AND reversado = 'N'
    and monto = dMontoUltimaCompra;

                SELECT {+INDEX (bdicred:sd_movhis inx_movhis6)} NVL(max(Monto),0)
                INTO fMontoComi
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                  AND fecha_mov = dFechaUltDisp
                  AND num_credito = cNumCredito
                  AND codigo_fun = '339'
                  AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19)
                  AND reversado = 'N'
and folio_suc = cFolioSuc;
            ELSE
                LET fMontoUltDisp,fMontoComi = 0, 0;
            END IF;
--======================================
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
--======================================
            LET fAbonoMensual,fSaldoMesAnt = 0, 0;

            FOREACH
                SELECT NVL(monto_financiado,0), --NVL(sdo_capinsoluto,0),
                       NVL(sdo_capital,0) + NVL(monto_vencido,0) + NVL(mto_venc_trasp,0) + NVL(cap_tras_no_venci,0)
                INTO fAbonoMensual, fSaldoMesAnt --, fSaldoMesAnt_2
                FROM bdicred:sd_maesdoshist
                WHERE empresa= pEmpresa
                AND num_credito = cNumCredito
--                AND fecha = MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy)) - 2 units month;
                AND fecha = 
                     (
                      SELECT NVL(max(fecha), dFechaHoy)
                      FROM bdicred:sd_maesdoshist
                      WHERE fecha < MDY(MONTH(dFechaHoy),20,YEAR(dFechaHoy))
                      AND empresa= pEmpresa
                      AND num_credito = cNumCredito
                     )

            END FOREACH;

            LET mMontoInteresCap, mMontoIvaIntCap = 0, 0;
            LET dFechaUltCapitalizacion = dFechaHoy;
            LET vfechamax = null;

           SELECT NVL(Max(fecha_mov), dFechaHoy)
           INTO vfechamax
            FROM bdicred:sd_movhis
            WHERE empresa = pEmpresa
            AND num_credito = cNumCredito
            AND fecha_mov >= date(0)
            AND reversado = 'N'
            AND codigo_fun  = '605';

            FOREACH
                SELECT codigo_ref, monto, fecha_mov
                INTO iRef, mMonto, dFechaUltCapitalizacion
                FROM bdicred:sd_movhis
                WHERE empresa   = pEmpresa
                AND fecha_mov = vfechamax
                AND num_credito = cNumCredito
                AND codigo_fun  = '605'
                and codigo_ref in ('2','3')
                AND reversado   = 'N'

                IF iRef = '2' then
                    LET mMontoInteresCap = mMonto;
                ELIF iRef = '3' then
                    LET mMontoIvaIntCap  = mMonto;
                END IF;
            END FOREACH;

            SELECT --sdo_capinsoluto,
                NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0) + NVL(b.cap_tras_no_venci,0)),0),
                NVL(SUM(NVL(b.monto_vencido,0) + NVL(b.mto_venc_trasp,0)),0),
                NVL(SUM(NVL(b.sdo_capital,0) + NVL(b.cap_tras_no_venci,0)),0)
            INTO fSaldoMesActual , --, fSaldoMesActual_2
                 fSaldoMesVencido,
                 fSaldoMesNoExig
            FROM bdicred:sd_maesdos b
            WHERE empresa= pEmpresa
            AND num_credito = cNumCredito;

            LET mMontoInteresCapMesAnt = 0;
            LET mMontoIvaIntCapMesAnt  = 0;

            SELECT NVL(Max(fecha_mov),dFechaHoy)
            INTO dFechaCapAux
            FROM bdicred:sd_movhis
            WHERE empresa = pEmpresa
            AND num_credito = cNumCredito
            AND codigo_fun  = '605'
            AND reversado = 'N'
            AND fecha_mov < NVL(dFechaUltCapitalizacion, dFechaHoy);
			
            FOREACH
                SELECT codigo_ref, monto
                INTO iRef, mMonto
                FROM bdicred:sd_movhis
                WHERE empresa = pEmpresa
                AND num_credito = cNumCredito
                AND codigo_fun  = '605'
                AND reversado = 'N'
                AND fecha_mov = dFechaCapAux

                IF iRef = '2' then
                    LET mMontoInteresCap = mMontoInteresCap + mMonto;
                ELIF iRef = '3' then
                    LET mMontoIvaIntCap  = mMontoIvaIntCap + mMonto;
                END IF;
            END FOREACH;

            --- Se obtiene la Sucursal del Credito
           SELECT 	sucursal, NVL(fecha_apertura,date(1))
           INTO  cNumSucursal, cFechaApertura
           FROM sd_maecred b
           WHERE b.empresa = pempresa
           AND b.num_credito = cNumCredito;

          -- Se  Obtiene el iva correspondiente a la sucursal que se asoció al Credito
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

           --  Se obtiene el Iva de los Intereses Vigentes
           SELECT SUM(iva_debe - iva_pagado)
           INTO mIvaIntVencido_ord
           FROM sd_amortiza_credito d
           WHERE d.empresa = pEmpresa
           AND d.num_credito = cNumCredito
           AND capital_status IN ('1','2','7');

         IF (fSaldoMesActual <= 1000) then
			INSERT INTO bdicred:sd_exclusiones_ventacartera
			(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
			VALUES
			('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '12');
			
			continue FOREACH;
		 END IF;
			
			
		 IF (cEmail <> '' ) then
			INSERT INTO bdicred:sd_exclusiones_ventacartera
			(empresa,num_producto,num_credito,numcte,fecha_exclusion,motivo_exclusion)
			VALUES 
			('001',cNumProducto,cNumCredito,cNumCte,date(CURRENT), '07');
			
			continue FOREACH;
         END IF;

     -- Se obtiene el Iva de Intereses Moratorio pagado
         SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
         INTO mIvaIntMoraTotal
         FROM sd_amortiza_credito
         WHERE empresa = pempresa 
         AND num_credito = cNumCredito
         AND capital_status IN ("2","7")
         AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;

          -- Se obtiene el Interes Moratorio Copete
          SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
                 NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
                 NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
                 NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
          INTO mIntMoraCope,
               mIvaIntMoraCope,
               mIntMoraOrdi,
               mIvaIntMoraOrdi
          FROM sd_amortiza_credito
          WHERE  empresa = pempresa
          AND num_credito = cNumCredito
          AND capital_status IN ("2","7");

		   IF  mIntMoraCope IS NULL OR  mIntMoraCope < 0 THEN
                LET mIntMoraCope = 0;
          END IF;

          IF  mIntMoraOrdi IS NULL OR  mIntMoraOrdi < 0 THEN
                LET mIntMoraOrdi = 0;
          END IF;

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
          end if;
		  
          SELECT limit 1 num_tarjeta
          INTO cNumTarjeta
          FROM bdicred:sd_tarjeta
          WHERE empresa = pEmpresa
          AND tipo_tarjeta = 'T'
          AND status_tar = 'A'
          AND num_credito  = cNumCredito;

		  IF cNumTarjeta is null then
			SELECT limit 1 num_tarjeta
			INTO cNumTarjeta
			FROM bdicred:sd_tarjeta
			WHERE empresa = pEmpresa
			AND tipo_tarjeta = 'T'
			AND num_credito  = cNumCredito
			AND secuencia =
				(
				 SELECT NVL(max(secuencia),0)
				 FROM bdicred:sd_tarjeta
				 WHERE empresa = pEmpresa
				 AND tipo_tarjeta = 'T'
				 AND num_credito  = cNumCredito
				);
		  END IF;

            LET cNumTarjeta = NVL(cNumTarjeta, '');

            LET cRefCoppel = '';
            FOREACH
                SELECT numcte_ref
                INTO cRefCoppel
                FROM bdinteg:si_cliente
                WHERE NumCte = cNumCte
            END FOREACH;

		ELSE --- Campos para Reestructura y Préstamo Personal

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
			AND fecha =
				 (
					SELECT NVL(max(fecha), dFechaHoy)
					FROM bdicred:sd_maesdoshistcrd
					WHERE fecha >= fecha_mesant
					AND empresa= pEmpresa
					AND num_credito = cNumCredito_rees
				 );
				
            if (cNumProducto = '6300') then
                SELECT NVL(max(fecha_mov), date(1)), MAX(SECUENCIA), COUNT(*)
                INTO dFechaUltPago, iMaxSecPago, iCuantosPagos
                FROM bdicred:sd_movhiscrd
                WHERE empresa = pEmpresa
                AND num_credito = cNumCredito_rees
                AND codigo_fun IN (SELECT cod_fun FROM paso_pres)
                AND codigo_ref = 1
                AND reversado = 'N';

                SELECT NVL(SUM(monto),0)
                INTO fMontoPago
                FROM bdicred:sd_movhiscrd
                WHERE empresa = pEmpresa
                AND fecha_mov = dFechaUltPago
                AND num_credito = cNumCredito_rees
                AND codigo_fun IN (SELECT cod_fun FROM paso_pres)
                AND codigo_ref = 1
                AND reversado = 'N';

            else
                SELECT NVL(max(fecha_mov), date(1)), MAX(SECUENCIA), COUNT(*)
                INTO dFechaUltPago, iMaxSecPago, iCuantosPagos
                FROM bdicred:sd_movhiscrd
                WHERE empresa = pEmpresa
                AND num_credito = cNumCredito_rees
                AND codigo_fun IN (SELECT cod_fun FROM paso_rees)
                AND codigo_ref = 1
                AND reversado = 'N';

                SELECT NVL(SUM(monto),0)
                INTO fMontoPago
                FROM bdicred:sd_movhiscrd
                WHERE empresa = pEmpresa
                AND fecha_mov = dFechaUltPago
                AND num_credito = cNumCredito_rees
                AND codigo_fun IN (SELECT cod_fun FROM paso_rees)
                AND codigo_ref = 1
                AND reversado = 'N';

            end if;
		
		--- Se obtiene la Sucursal del Credito
		   SELECT sucursal, NVL(fecha_apertura,date(1))
		   INTO cNumSucursal, cFechaApertura
		   FROM sd_maecredcrd b
		   WHERE b.empresa = pempresa
		   AND b.num_credito = cNumCredito_rees;
			
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
                --balanza
                    select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                    INTO mIntVencido_bal, mIvaIntVencido_bal
                    from bdicred:sd_amortiza_creditocrd
                    where empresa = pEmpresa
                    and num_credito = cNumCredito_rees
                    and capital_status in ('2','7')
                    and fecha_cuota <= (
                                        select max(fecha_mov)
                                        from bdicred:sd_movhiscrd
                                        where empresa = pEmpresa
                                        and num_credito = cNumCredito_rees
                                        and codigo_fun = '602'
                                        and codigo_ref = 2
                                        and reversado = 'N');
                --orden
                    select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                    INTO mIntVencido_ord, mIvaIntVencido_ord
                    from bdicred:sd_amortiza_creditocrd
                    where empresa = pEmpresa
                    and num_credito = cNumCredito_rees
                    and capital_status in ('2','7')
                    and fecha_cuota > (
                                        select max(fecha_mov)
                                        from bdicred:sd_movhiscrd
                                        where empresa = pEmpresa
                                        and num_credito = cNumCredito_rees
                                        and codigo_fun = '602'
                                        and codigo_ref = 2
                                        and reversado = 'N');
                ELSE
                    select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) INTO mIntVencido_ord, mIvaIntVencido_ord
                    FROM bdicred:sd_amortiza_creditocrd
                    WHERE empresa = pEmpresa
                    AND num_credito= cNumCredito_rees
                    AND capital_status in ('2','7');
                END IF;
			   
				LET mIntMoraOrdi, mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope = 0,0,0,0;
			   
			ELIF cNumProducto = '6300' THEN
            --balanza
                select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                INTO mIntVencido_bal, mIvaIntVencido_bal
                from bdicred:sd_amortiza_creditocrd
                where empresa = pEmpresa
                and num_credito = cNumCredito_rees
                and capital_status in ('2','7')
                and fecha_cuota <= (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumCredito_rees
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');
            --orden
                select nvl(sum(interes_debe - interes_pagado),0), nvl(sum(iva_debe - iva_pagado),0) 
                INTO mIntVencido_ord, mIvaIntVencido_ord
                from bdicred:sd_amortiza_creditocrd
                where empresa = pEmpresa
                and num_credito = cNumCredito_rees
                and capital_status in ('2','7')
                and fecha_cuota > (
                                    select max(fecha_mov)
                                    from bdicred:sd_movhiscrd
                                    where empresa = pEmpresa
                                    and num_credito = cNumCredito_rees
                                    and codigo_fun = '026'
                                    and codigo_ref = 3
                                    and reversado = 'N');
			
				LET mPorcIva = '';
				
				SELECT iva
				INTO mPorcIva
				FROM bdinteg:si_sucursales
				WHERE empresa = pempresa
				AND sucursal = cNumSucursal;
				   
				-- Se obtiene el Iva de Intereses Moratorio pagado
				SELECT NVL(SUM(mora_iva_debe+((mora_provi_ordi+mora_provi_cope) * mPorcIva) - mora_iva_pagado),0)
				INTO mIvaIntMoraTotal
				FROM sd_amortiza_creditocrd
				WHERE empresa = pempresa
				AND num_credito = cNumCredito_rees
				AND capital_status IN ("2","7")
				AND (mora_iva_debe - mora_iva_pagado + ((mora_provi_ordi+mora_provi_cope) * mPorcIva)) > 0;

				 -- Se obtiene el Interes Moratorio Copete
				 SELECT NVL(SUM(mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag),0),
						NVL(SUM((mora_sdo_cope + mora_provi_cope - mora_sdo_cope_pag) * mPorcIva),0),
						NVL(SUM(mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag),0),
						NVL(SUM((mora_sdo_ordi + mora_provi_ordi - mora_sdo_ordi_pag) * mPorcIva),0)
				  INTO mIntMoraCope,
					   mIvaIntMoraCope,
					   mIntMoraOrdi,
					   mIvaIntMoraOrdi
				  FROM sd_amortiza_creditocrd
				  WHERE empresa = pempresa
				  AND num_credito = cNumCredito_rees
				  AND capital_status IN ("2","7");
			   
		   END IF;
		   
		   LET cNumTarjeta = '';
		   
		   SELECT numcte_ref
		   INTO cRefCoppel
		   FROM bdinteg:si_cliente
		   WHERE NumCte = cNumCte;

		END IF;

		BEGIN WORK;
		
		   INSERT INTO bdicobranza:cb_rep_cart_quebrantar_optim
			(   Num_Credito,    NumCte,
				Apellido1,      Apellido2,          Nombre1,            Nombre2,            Rfc        ,    ApellidoCasada,
				Sector,         FechaNac,           Curp,               Sexo,               EdoCivil   ,    NumIdentificacion,
				Email,          TipoIdentificacion, Nacionalidad,

				NumEstado,      NumCiudad,          Poblacion,          NumColonia,         NumCalle,       NumExterior,
				NumInterior,    CodPostal,          PuntoCardinal,      Manzana,            andador,        Etapa      ,
				Lote,           Edificio,           Entrada,            Departamento,       Complemento,    EntreCalles,
				Otros,          SituacionEsp,       CausaSitEsp,

				IngresoMensual, Puesto,             LugarTrabajo,       Telefono,           TelTrab,        ExtTrab,
				AntigDomic,     AntigTrab,          Actividad,

				NumEstadoTrab,  NumCiudadTrab,      PoblacionTrab,      NumColoniaTrab,     NumCalleTrab,   NumExteriorTrab,
				NumInteriorTrab,CodPostalTrab,      PuntoCardinalTrab,  ManzanaTrab,        andadorTrab,    EtapaTrab,
				LoteTrab,       EdificioTrab,       EntradaTrab,        DepartamentoTrab,   ComplementoTrab,EntreCallesTrab,
				OtrosTrab,

				Sucursal,               Fecha_Ult_Disp,         Monto_Ult_Disp,
				Monto_Comi_Ult_Disp ,   Abono_Mensual_Al_Qub,   Int_Capit,          Iva_Int_Capit ,
				Sdo_Mes_Ant,            Sdo_Actual          ,   Sdo_Vencido,        Sdo_No_Exig,        Fecha_Ult_Mov,      Tipo_Ult_Mov  ,
				Monto_Ult_Mov,          Int_Vencido,   Iva_Int_Vencido, Int_Vencido_bal,   Iva_Int_Vencido_bal ,
				Int_Mora_Ordi, Iva_Int_Mora_Ordi ,  Int_Mora_Cope , Iva_Int_Mora_Cope , Meses_Vencidos, Numero_Tarjeta,
				--NumCliente   ,
			   ReferenciaCoppel, fechareporte,
			   fechaapertura, telefonocel, situacionpago, meseshistoria, evaluacc, monto_otorgado, producto
			)
			Values
			(   case when CNumproducto = '6001' then cNumCredito ELSE cNumCredito_rees END ,        
				cNumCte,
				cApellido1,         cApellido2,         cNombre1,           cNombre2,           cRfc,               cApellidoCasada,
				cSector,            dFechaNac,          cCurp,              cSexo,              cEdoCivil,          cNumIdentificacion,
				cEmail,             cTipoIdentificacion,cNacionalidad,

				cNumEstado,         cNumCiudad,         cPoblacion,         cNumColonia,           cNumCalle,             cNumExterior,
				cNumInterior,       cCodPostal,         cPuntoCardinal,     iManzana,           iandador,           iEtapa,
				iLote,              iEdificio,          iEntrada,           cDepartamento,      cComplemento,       cEntreCalles,
				sOtros,             cSituacion,         sCausa,

				mIngresoMensual,    cPuesto,            cLugarTrabajo,      cTelefono,          cTelTrab,           cExtTrab,
				cDescripcion,       cDescripPermTrabajo,cActividad,

				cNumEstadoTrab,     cNumCiudadTrab,     cPoblacionTrab,     cNumColoniaTrab,    cNumCalleTrab,      cNumExteriorTrab,
				cNumInteriorTrab,   cCodPostalTrab,     cPuntoCardinalTrab, iManzanaTrab,       iandadorTrab,       iEtapaTrab,
				iLoteTrab,          iEdificioTrab,      iEntradaTrab,       cDepartamentoTrab,  cComplementoTrab,   cEntreCallesTrab,
				iOtrosTrab,
	----
				cNumSucursal,           dFechaUltDisp ,          fMontoUltDisp,
				fMontoComi,             fAbonoMensual,          mMontoInteresCap,       mMontoIvaIntCap,
				fSaldoMesAnt,           fSaldoMesActual,        fSaldoMesVencido,       fSaldoMesNoExig,    dFechaUltMov,           cUltMov,
				fMontoUltMov,			mIntVencido_ord,   mIvaIntVencido_ord, mIntVencido_bal, mIvaIntVencido_bal, 
                mIntMoraOrdi , mIvaIntMoraOrdi, mIntMoraCope, mIvaIntMoraCope , cMesesVencidos, cNumTarjeta,
				--cNumCte,
				cRefCoppel, date(CURRENT),
				cFechaApertura, cTelefonoCel, cSituacionPago, cMesesHistoria, cEvaluacc, pMonto_otorgado, cNumproducto
			);
	-- jom ini
			
			IF  cNumProducto = '6001' then 
			
				LET cNumRegTotal_TC = cNumRegTotal_TC + 1;
				LET sSaldoActTotal_TC = sSaldoActTotal_TC + fSaldoMesActual;
/* rss se comenta para ejecución en paralelo con la venta de cartera original
				UPDATE sd_maecred
				   SET id_unidad_prod = 1
				WHERE empresa = pEmpresa
				  AND num_credito = cNumCredito;
*/		 
			ELIF cNumProducto = '6011' then 
			
				LET cNumRegTotal_Rees = cNumRegTotal_Rees + 1;
				LET sSaldoActTotal_Rees = sSaldoActTotal_Rees + fSaldoMesActual;
/* rss se comenta para ejecución en paralelo con la venta de cartera original
				UPDATE sd_maecredcrd
				   SET id_origen = 1
				WHERE empresa = pEmpresa
				  AND num_credito = cNumCredito_rees;
*/
			ELIF cNumProducto = '6300' then 
				
				LET cNumRegTotal_pres = cNumRegTotal_Pres + 1;
				LET sSaldoActTotal_Pres = sSaldoActTotal_Pres + fSaldoMesActual;
/* rss se comenta para ejecución en paralelo con la venta de cartera original
				UPDATE sd_maecredcrd
				   SET id_origen = 1
				WHERE empresa = pEmpresa
				  AND num_credito = cNumCredito_rees;
*/
			END IF;
			
		 		 	
		COMMIT WORK;
-- jom fin
    
	END IF;
	
    LET mIntVencido_bal, mIvaIntVencido_bal, mIntVencido_ord, mIvaIntVencido_ord = 0,0,0,0;
    END FOREACH;

    INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras_optim values ('6001', cNumRegTotal_TC,sSaldoActTotal_TC,date(CURRENT));
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras_optim values ('6011', cNumRegTotal_Rees,sSaldoActTotal_Rees,date(CURRENT));
	INSERT INTO bdicobranza:cb_rep_cart_quebrantar_cifras_optim values ('6300', cNumRegTotal_Pres,sSaldoActTotal_Pres,date(CURRENT));

    EXECUTE PROCEDURE "informix".sp_gen_rep_cartera_quebrantar_optim('001') INTO P_COD_RET;

    IF P_COD_RET <> '000000' then
       LET cMensajeRet = 'ERROR en la descarga de archivos para el reporte VENTA DE CARTERA';
       RETURN P_COD_RET, cMensajeRet;
    END IF;

    LET cMensajeRet = 'El proceso de VENTA DE CARTERA se realizó correctamente';

    LET P_COD_RET = '000000';

    RETURN P_COD_RET,cMensajeRet;

END;
END procedure;