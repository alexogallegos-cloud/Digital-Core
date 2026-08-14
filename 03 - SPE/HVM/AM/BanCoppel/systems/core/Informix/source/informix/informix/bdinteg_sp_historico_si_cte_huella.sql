CREATE PROCEDURE "informix".sp_historico_si_cte_huella(dFecha_hoy DATE)

RETURNING CHAR(5);

-- VARIABLES
DEFINE cCodRet        CHAR(5);
DEFINE cInfoErr       CHAR(100);
DEFINE iSqlErr        INTEGER;
DEFINE iIsamErr       INTEGER;
					  
DEFINE vnumcte        CHAR(20);
DEFINE vsecuencia     SMALLINT;
DEFINE vestado        CHAR(1);
DEFINE vdmapa         CHAR(942);
DEFINE vimapa         CHAR(942);
DEFINE vusuario       CHAR(8);
DEFINE vsucursal      CHAR(4);
DEFINE vfecha_alta    DATE;
DEFINE vusuario_camb  CHAR(8);
DEFINE vfecha_camb    DATE;
DEFINE vfech_ult_camb DATETIME YEAR TO SECOND;

DEFINE vCont INT;

LET cCodRet = '00000';
LET vCont = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            ROLLBACK WORK;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

    BEGIN WORK;

    FOREACH c_huella WITH HOLD FOR

        SELECT numcte, secuencia, estado, dmapa, imapa, usuario, sucursal,
               fecha_alta, usuario_camb, fecha_camb, fech_ult_camb
        INTO vnumcte, vsecuencia, vestado, vdmapa, vimapa, vusuario,
             vsucursal, vfecha_alta, vusuario_camb, vfecha_camb, vfech_ult_camb
        FROM informix.si_cte_huella
        WHERE estado = 'I'

        -- INSERT
        INSERT INTO informix.si_cte_huella_old
        VALUES (vnumcte, vsecuencia, vestado, vdmapa, vimapa, vusuario,
                vsucursal, vfecha_alta, vusuario_camb, vfecha_camb,
                vfech_ult_camb, CURRENT::DATE);

        -- DELETE EXACTO
        DELETE FROM informix.si_cte_huella
        WHERE CURRENT OF c_huella;

        LET vCont = vCont + 1;

        -- COMMIT CADA 1000
        IF vCont >= 1000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vCont = 0;
        END IF;

    END FOREACH;

    COMMIT WORK;

    RETURN cCodRet;

END;

END PROCEDURE

DOCUMENT
'AUTOR : Victor Manuel Hernandez Lopez',
'DESCRIPCION: Se genera sp, para llenar la tabla historica si_cte_huella_old',
'EJECUTADO O LLAMADO POR:',
'sp_historico_si_cte_huella.sh',
'FECHA : Marzo 2026',
'VERSION: 20260310',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_llenacteestadocuenta()
returning char (50);

-- Martha Aguirre 08-Sep-09 Se agrega filtro por tipo de ingreso en la bâ??squeda de tabla si_ingresos
-- MACF 2011-12-05 Agregar validaciâ??n de telâ??fonos.
-- MAHR 2012-01-19 Se agrego el campo numcte_ref a la tabla: si_cteestadocuenta
-- MAHR Junio 2012. Se genera estado de cobranza con informacion en Cartera en Lâ??nea: sd_sdos_cartera_linea.
-- MAHR Agosto 2012. Se obtiene informacion de telefonos de tabla: bdinteg:si_telefonos_actual
-- DUCM Sept 2019. Se generan archivos vacios Reestructuras y Carta Invitaciâ??n para evitar alarmado en cifrado los dâ??as 23.
-- AAR Agosto 2023. Se optimiza el procedimiento.                 
-- JAHJ Enero  2024 Se agregan commits de acuerdo a la solicitud bd
   
--  execute procedure "informix".sp_llenacteestadocuenta();

define cNumCredito, cNumCliente, cNumcte_ref                                    char(20);
define cNumTarjeta                                                              char(16);
define mSaldoActual, mSaldoVencido, mSaldoContabMora, mSaldoContabMoraTotal     money(18,2);
define cSalarioMinimoaux                                                        decimal(14,2);
define cSucursal, cNumCiudadRef, cNumColoniaRef                                 char(4);
define cNombre1, cNombre2, cApellido1, cApellido2                               char(26);
define cNombreCalle, cNombreCalle_t, cNomCalleRef,cColRef                       char(30);
define cNumInterio, cNumInterio_t, cNumExterior, cNumExterior_t, var_rga2       char(10);
define cColonia, cColonia_t, cManzana, cManzana_t, cProceso                     char(30);
define cOtros, cOtros_t, cAndador, cAndador_t, cEtapa, cEtapa_t, cLote,cLote_t  char(5);
define cEdificio, cEdificio_t, cEntrada, cEntrada_t, cSalarioMinimo             char(5);
define cDepartamento, cDepartamento_t, cNumCentro, cNumCalleCte, cDeptoRef, cNumCalleCte_t, cNumCentro_t  char(6);
define cCodPostal, cCodPostal_t, cExtensionTrabajo                              char(5);
define cPuntoCardinal, cPuntoCardinal_t, cSituacionEspecial, cSexo, cTipoDirPart, cTipoDirTrab   char(1);
define cComplemento, cComplemento_t, cComplementoRef                            char(80);
define cEntreCalles, cEntreCalles_t, cEntreCallesRef                            char(40);
define cDelegacionMunicipio, cDelegacionMunicipio_t, cEstado,cEstado_t          char(25);
define cTelefonoCasa, cTelefonoTrabajo, cCelular, cTelefonoRef                  char(13);
define cEstadoCivil, cTipoCasa, cDiaUltimoPago, cMesUltimoPago                  char(2);
define cAnioAlta, cAnioNacimiento, cNumCiudadCte, cNumCiudadCte_t               char(4);
define cNumJefe, cNumSupervisor, cPlazoCompromiso, cNumJefe_t, cNumSupervisor_t char(8);
define cNumColoniacte, cNumColoniacte_t, cAnioUltimoPago, cAnioUltimoCompac     char(4);
define cLugarTrabajo                                                            char(60);
define dFechaUltimoPago, dFechaUltimocompac, dFechaCumpliocompromiso, dfecha_prim_comp, dFh_alta  date;
define cImpteUltimocompromiso, cImpteCompromisocumplido, vlMontoUltimoPago      char(5);
define cDiaUltimoCompac, cMesUltimoCompac char(2);
define vTotalRegistros, vTotalCommit, sAbonosVdos   integer;
define mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado money(18);
define mSaldoTotalAcumulado_2, mSaldoVencidoAcumulado_2, mSaldoMoratorioAcumulado_2 money(18);
define vfechaini, vfechafin, vfecha_hoy, vfecha_ultimo, vfechavenci, dFHoy_1m, dFHoy_13m  Date;
define cEmpresa, vempresa                                                       char(3);
define sNumAvisos, cPuntoCardinalRef, cTipodecliente, cCumplioCompromiso        char(1);
define cNombreRef, cNomConyugeoFamiliar                                         char(78);
define cNumExtRef, cNumIntRef                                                   char(10);
define cManzanaRef, cOtrosRef, cAndadorRef, cEtapaRef, cLoteRef, cEdificioRef,cEntradaRef, cCpRef,var_rga char(5);
define cDelegacionMunicipioRef, cEstadoRef  char(25);
define cTelConyugeoFamiliar, vRFC           char(13);
define cNombreArchivo, cNombreArchivo2      char(70);
define cSql                                 char(3000);
define cSql1                                char(100);
define cSql2                                CHAR(900);
define cSql3                                CHAR(700);
define cpagominimo, cSalvenci, cMoraaux, cInteresaux, cInteresV                 money(18,2);
define vmensualidades_min, vmensualidades_max, salariominban                    integer;
define vmontodeudaabogmin, iDiasTrans                                          integer;
define cSaldovencido1, cSaldovencido2, cSaldovencido3, cSaldovencido4           money(18,2);
define cSaldovencido5, cSaldovencido6, cInteresmoratorio1, cInteresmoratorio2   money(18,2);
define cInteresmoratorio3, cInteresmoratorio4                                   money(18,2);
define cInteresmoratorio5, cInteresmoratorio6, cproyecmora                      decimal(18,2);
DEFINE sPaso, vTpoVdoCte, cCausasituacionespecial                               SMALLINT; --CAS
DEFINE SQL_ERR, ISAM_ERR, cPrimerReg        INTEGER;
DEFINE ERROR_INFO, P_MENSAJE                VARCHAR(80);
DEFINE P_COD_RET, cRutaArch                 VARCHAR(50);
DEFINE mmSaldoMoratorioAcumulado, mmSaldoTotalAcumulado, mmSaldoVencidoAcumulado MONEY(18);
DEFINE cnum_producto                        char(4);
DEFINE p_resultado                          CHAR(6);
DEFINE pmensaje                             CHAR(80);
DEFINE vdia, vCuentaConSitEspL, vCountOnMaecred, vvTotalRegistros, i,j,k       INTEGER;
DEFINE cMensaje                                     CHAR(150);
DEFINE cRegs_DirecModif                     CHAR(1);
DEFINE cNombreArchivo3 char(50);
DEFINE dHoy date;
DEFINE diaHoy  char(2);
DEFINE vMes  char(2);
DEFINE vAnio char(4);

LET cProceso = '0022'; LET vempresa = '001'; LET p_resultado = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
--        Set debug file to "/informix/c90260202/llenacuenta/sp_llena.out";    --  *** comentar
        Set debug file to "/resplogifx/archivoscartera/sp_llena.out";

        trace on;
        LET P_COD_RET = SQL_ERR; LET P_MENSAJE = cNumCredito ||'-' ||ERROR_INFO;
        LET cNumCredito = cNumCredito;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, P_MENSAJE, '02') RETURNING p_resultado;
        -- ROLLBACK WORK;
        IF P_COD_RET = -668 THEN
            RETURN "No copio el archivo al servidor destino " ||  P_COD_RET;
        ELSE
            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_creda_tab';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_paso_creda_tab;
            END IF;
            RETURN P_COD_RET;
        END IF;
    END EXCEPTION;

--SET DEBUG FILE TO "/informix/c90260202/llenacuenta/sp_llenacteestadocuenta.out";													---  comentar
--TRACE ON;																																--- comentar

LET  cNumCredito  = ""; LET  cNumCliente =  ""; LET  cNumTarjeta  =  ""; LET  mSaldoActual = 0;
LET  mSaldoVencido = 0; LET  cSalarioMinimoaux=0; LET  cSalarioMinimo  =  ""; LET  cSucursal  =  "";
LET  cNombre1  =  ""; LET  cNombre2  =  ""; LET  cApellido1  =  ""; LET  cApellido2  =  "";
LET  cNombreCalle  =  ""; LET  cNumInterio  =  ""; LET  cNumExterior   =  ""; LET  cColonia  =  "";
LET  cManzana  =  ""; LET  cOtros  =  ""; LET  cAndador  =  ""; LET  cEtapa  =  ""; LET  cLote  =  "";
LET  cEdificio  =  ""; LET  cEntrada  =  ""; LET  cDepartamento  =  ""; LET  cCodPostal  =  "";
LET  cPuntoCardinal  =  ""; LET  cComplemento  =  ""; LET  cEntreCalles   =  ""; LET  cDelegacionMunicipio  =  "";
LET  cEstado  =  ""; LET  cTelefonoCasa  =  ""; LET  cTelefonoTrabajo  =  ""; LET  cExtensionTrabajo   =  "";
LET  cCelular   =  ""; LET  cEstadoCivil   =  ""; LET  cTipoCasa   =  ""; LET  cSexo   =  "";
LET  cAnioAlta   =  ""; LET  cAnioNacimiento   =  ""; LET  cNumCiudadCte   =  ""; LET  cNumCentro   =  ""; LET cNumCentro_t = "";
LET  cNumJefe   =  ""; LET  cNumSupervisor   =  ""; LET  cNumColoniacte   =  ""; LET  cNumCalleCte   =  ""; LET vRFC = ""; LET cNumJefe_t = "";  LET cNumSupervisor_t = "";
LET  cLugarTrabajo   =  ""; LET  dFechaUltimoPago  = date(1); LET  cDiaUltimoPago   =  ""; LET  cMesUltimoPago   =  "";
LET  cAnioUltimoPago   =  ""; LET  cPlazoCompromiso  = ""; LET  cImpteCompromisocumplido  = ""; LET vlMontoUltimoPago= "";
LET  dFechaCumpliocompromiso  = date(1); LET  cDiaUltimoCompac = ""; LET  cMesUltimoCompac = "";
LET  cAnioUltimoCompac = ""; LET  vTotalRegistros = 0; LET  mSaldoTotalAcumulado = 0; LET  mSaldoVencidoAcumulado = 0;
LET  mSaldoMoratorioAcumulado = 0; LET  mSaldoContabMora = 0; LET  mSaldoContabMoraTotal = 0;
LET  vfecha_hoy= date(1); LET  vfechaini= date(1); LET vfecha_ultimo= date(1); LET  vfechafin= date(1);
LET  cEmpresa=""; LET  sAbonosVdos =0; LET  sNumAvisos =0; LET  cNombreRef=""; LET  cNomCalleRef="";
LET  cNumExtRef=""; LET  cNumIntRef=""; LET  cColRef=""; LET  cManzanaRef=""; LET  cOtrosRef="";
LET  cAndadorRef=""; LET  cEtapaRef=""; LET  cLoteRef=""; LET  cEdificioRef=""; LET  cEntradaRef="";
LET  cDeptoRef=""; LET  cCpRef=""; LET  cPuntoCardinalRef=""; LET  cComplementoRef=""; LET  cEntreCallesRef="";
LET  cDelegacionMunicipioRef=""; LET  cEstadoRef=""; LET  cTelefonoRef=""; LET  cNumCiudadRef=""; LET  cNumColoniaRef="";
LET  cNomConyugeoFamiliar=""; LET  cTelConyugeoFamiliar="";
LET  cNombreCalle_t=""; LET  cNumExterior_t=""; LET  cNumInterio_t=""; LET  cColonia_t=""; LET  cManzana_t="";
LET  cOtros_t=""; LET  cAndador_t=""; LET  cEtapa_t=""; LET  cLote_t=""; LET  cEdificio_t=""; LET  cEntrada_t="";
LET  cDepartamento_t=""; LET  cCodPostal_t=""; LET  cPuntoCardinal_t=""; LET  cComplemento_t=""; LET  cEntreCalles_t="";
LET  cDelegacionMunicipio_t=""; LET  cEstado_t=""; LET  cNumCiudadCte_t=""; LET  cNumColoniacte_t=""; LET  cSaldovencido1=0;
LET  cSaldovencido2=0; LET  cSaldovencido3=0; LET  cSaldovencido4=0; LET  cSaldovencido5=0; LET  cSaldovencido6=0;
LET  cInteresmoratorio1=0; LET  cInteresmoratorio2=0; LET  cInteresmoratorio3=0; LET  cInteresmoratorio4=0; LET  cInteresmoratorio5=0;
LET  cInteresmoratorio6=0; LET  cInteresaux=0; LET  cInteresV=0; LET  cpagominimo=0; -- LET  ctasamora=0;
LET  cSQL = ""; LET  vTotalCommit=0; LET  vmensualidades_min = 0; LET  vmensualidades_max = 0; LET  var_rga = ""; LET  vfechavenci=date(0);
LET  vvTotalRegistros = 0; LET  mmSaldoTotalAcumulado = 0; LET  mmSaldoVencidoAcumulado = 0; LET  mmSaldoMoratorioAcumulado = 0;
LET  cnum_producto = ''; LET vdia = 0; LET cTipoDirPart = '1';  LET cTipoDirTrab = '2'; LET vCuentaConSitEspL = 0;
LET  vCountOnMaecred = 0; LET  var_rga2 = ""; LET cMensaje = 'PROCESO EXITOSO';
LET  mSaldoTotalAcumulado_2 = 0; LET mSaldoVencidoAcumulado_2 = 0; LET mSaldoMoratorioAcumulado_2 = 0; LET cNumCalleCte_t = '';
LET  vmontodeudaabogmin = 0; LET cRutaArch = ''; LET cRegs_DirecModif = '';
LET cNombreArchivo3 = '';
LET dHoy  = '';
LET diaHoy  = '';
LET vMes  = '';
LET vAnio = '';

let dHoy  = date((Select fecha_hoy from bdicred:sd_fechas where empresa = '001')) ;
LET diaHoy = lpad(day(dHoy),2,'0');
LET vMes = lpad(month(dHoy),2,'0');
LET vAnio = lpad(year(dHoy),4,'0');
LET i = 0;LET j = 0;LET k = 0;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', cMensaje, '01') RETURNING p_resultado;

    -- Obtiene parâ??metros.
    SELECT valor INTO salariominban FROM bdisolic:ss_param WHERE secuencia='303' AND empresa = '001' ;
    SELECT date(fecha_ant), date (ult_dia_mes) INTO vfecha_hoy, vfecha_ultimo FROM bdicred:sd_fechas WHERE empresa = vempresa;
    SELECT (valor+0) INTO vmensualidades_min FROM bdinteg:si_param WHERE empresa = vempresa AND cod_param = '60';
    SELECT (valor+0) INTO vmensualidades_max FROM bdinteg:si_param WHERE empresa = vempresa AND cod_param = '61';
    SELECT (valor+0) INTO vmontodeudaabogmin FROM bdinteg:si_param WHERE empresa = vempresa AND cod_param = '109';
    SELECT valor INTO cRutaArch FROM bdinteg:"informix".si_param WHERE cod_param = 137;

	--LET cRutaArch = '/informix/c90260202/llenacuenta/';																							--****** comentar

    -- Fechas del periodo (inicio = fecha de la ultima ejecucion del Edo de Cobranza. Si no existe fecha, se cargan todos como ctes nuevos.
	-- JAHJ SE ESTABLECE FECHA MAXIMA
--    SELECT LIMIT 1 fecha_movto INTO vfechaini FROM bdinteg:si_cteestadocuenta; -- Toma la ultima ejecucion del Edo de Cobranza y le suma un dia.
    SELECT MAX(fecha_movto) INTO vfechaini FROM bdinteg:si_cteestadocuenta; -- Toma la ultima ejecucion del Edo de Cobranza
	
	IF vfechaini IS NOT NULL THEN       -- Existen datos en cteestado cuenta.
        LET vfechaini = vfechaini + 1 units day;
        LET vfechafin = vfecha_hoy;
    END IF;
    LET cNombreArchivo = trim(cRutaArch) || 'EdoCuentaAbogadoBancoppel' || LPAD(TRIM(MONTH(vfecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(vfecha_hoy),3,2) || '.txt';
    LET cNombreArchivo2 = trim(cRutaArch) || 'CifraAbogadoBancoppel' || LPAD(TRIM(MONTH(vfecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(vfecha_hoy),3,2) || '.txt';

    LET P_COD_RET = "000000";
    SET ISOLATION TO DIRTY READ;

    --SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_creda_tab';
    --IF NVL(sPaso,0) > 0 THEN DROP TABLE sd_paso_creda_tab; END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga  CarteraLinea y Sit esp', '02') RETURNING p_resultado;
    -- Obtiene la informacion de los clientes de cartera en linea que cumplan con las condiciones.


    SELECT numcte, num_credito, num_tarjeta, sdo_cap_insoluto, mto_venc_trasp, monto_vencido, fecha_ult_pago, monto_financiado, num_producto, 
			saldovencido1, saldovencido2, saldovencido3, saldovencido4, saldovencido5, saldovencido6, 
			interesmoratorio1, interesmoratorio2, interesmoratorio3, interesmoratorio4, interesmoratorio5, interesmoratorio6, 
			interes_iva, mto_fin_ven_trasp, '0' AS otros_ref
        FROM bdicred:sd_sdos_cartera_linea cart
    WHERE cart.num_producto IN ('6001', '8100')
		AND cart.sdo_cap_insoluto >= vmontodeudaabogmin
        AND cart.mto_fin_ven_trasp BETWEEN vmensualidades_min AND vmensualidades_max
        AND cart.status_cred in('E1','E2','E3') 
		AND (cart.monto_vencido + cart.mto_venc_trasp) > 0
    INTO temp CarteraLinea WITH NO LOG;
				
    create index ix_CarteraLinea on CarteraLinea (numcte);
    create unique index ix_CarteraLinea_cre on CarteraLinea (num_credito);
    UPDATE STATISTICS medium FOR TABLE CarteraLinea;

    /*CREATE TABLE sd_paso_creda_tab (num_credito CHAR(20));
    -- Identifica los registros con situacion especial.
    SELECT num_credito FROM CarteraLinea WHERE numcte IN (select numcte from bdisitesp:se_ctessitespcte a,
                bdisitesp:se_situacionaccion b where a.situacion = b.situacion  and a.causa  = b.causa and b.idaccion = 5 and b.instruccion = '0')  -- ORIGINAL
        GROUP BY 1
        INTO temp paso_sitesp_sdocart with no log;

    INSERT INTO sd_paso_creda_tab
        SELECT * from paso_sitesp_sdocart group by 1;
    create unique index inx_sd_paso_cred_t on sd_paso_creda_tab(num_credito);
    UPDATE STATISTICS medium FOR TABLE sd_paso_creda_tab;*/

        /* **************************************************************************************************************
                SE CREA TABLA TEMPORAL DE LOS CLIENTES CON SITUACIâ??N ESPECIAL y LOS CRâ??DITOS QUE ESTâ??N DADOS DE BAJA
        ************************************************************************************************************** */
        SELECT num_credito
        FROM CarteraLinea
        WHERE numcte IN (select numcte from bdisitesp:se_ctessitespcte a,
        bdisitesp:se_situacionaccion b where a.situacion = b.situacion  and a.causa  = b.causa and b.idaccion = 5 and b.instruccion = '0')  -- ORIGINAL
        UNION
        SELECT num_credito FROM bdicred:sd_maecred where campo_trab3 = 'BAJA'
    INTO temp paso_sitesp_sdocart with no log;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Elimina registros y crea catalogos temporales', '02') RETURNING p_resultado;
    -- Elimina de cartera en linea temporal los clientes con situacion especial.
        --DELETE FROM CarteraLinea WHERE num_credito IN ( select num_credito from sd_paso_creda_tab);
	BEGIN;
		DELETE FROM CarteraLinea WHERE num_credito IN ( select num_credito from paso_sitesp_sdocart);
    COMMIT;
	-- Elimina de cartera en linea los creditos que estan en BAJA.
        --DELETE FROM CarteraLinea WHERE num_credito IN ( select num_credito from bdicred:sd_maecred where campo_trab3 = 'BAJA' );


    -- Elimina Registros de si_cteestadocuenta que ya se no encuentran en la cartera en linea o que ya no cumplan con las condiciones principales.

	--JAHJ 01/2024 DELETE FROM bdinteg:si_cteestadocuenta WHERE numero_credito NOT IN ( select num_credito from CarteraLinea );

	BEGIN;
		DELETE FROM bdinteg:si_cteestadocuenta a
		WHERE NOT EXISTS (SELECT * FROM CarteraLinea b
							WHERE a.numero_credito = b.num_credito);
	COMMIT;

		
    -- Elimina registros de si_cteestadocuenta de Prestamo personal y reestuctura
	BEGIN;
		DELETE FROM bdinteg:si_cteestadocuenta WHERE num_producto IN ('6300', '6011','6400', '7600', '7700'); --A.L.L. '7600', '7700'
		-- Elimina los registros con situacion especial L y M y los insertara como nuevos si continuan con esa situacion.
		DELETE FROM bdinteg:si_cteestadocuenta WHERE situacioespecial IN ('L', 'M');
	COMMIT;
	
    -- Elimina los registros de clientes fusionados, el foreach no los procesa ya que se borraron de tablas ctepf y cliente
    --SELECT edo.numcte FROM bdinteg:si_cteestadocuenta edo JOIN bdinteg:si_fuscliente fus ON (edo.numcte = fus.numcte) INTO temp ctesfusionados with no log;
    --create index ix_ctesfus on ctesfusionados (numcte);
--    ****************************************************************************************************************
	--DELETE FROM bdinteg:si_cteestadocuenta WHERE numcte in (select numcte from ctesfusionados);

	--SELECT {+INDEX(si_cteestadocuenta inx3_cteedocta)} edo.numcte 
	SELECT fus.numcte, fus.empresa
	FROM bdinteg:si_fuscliente fus 
	INNER JOIN bdinteg:si_cteestadocuenta edo ON fus.numcte = edo.numcte AND fus.empresa = '001'
	INTO temp tmp_fuscte with no log;
	
    BEGIN;
		DELETE FROM bdinteg:si_cteestadocuenta 
		WHERE numcte in (select numcte from tmp_fuscte);

		-- Elimina los clientes cuya calle esta nula
		--DELETE {+INDEX(bdinteg:si_cteestadocuenta inx7_cteedocta)} 
		DELETE FROM bdinteg:"informix".si_cteestadocuenta WHERE num_callecte IS NULL;
		
		
		UPDATE STATISTICS medium FOR TABLE bdinteg:si_cteestadocuenta;

		--Elimina de Cartera, Ctes procesados HOY (no se procecen nvamente, -hasta el ultimo de los DELETE'S-)
		DELETE FROM CarteraLinea WHERE num_credito IN ( select numero_credito 
														from bdinteg:si_cteestadocuenta 
														where fecha_movto = vfecha_hoy 
														and num_producto IN ('6001', '8100'));

		TRUNCATE bdinteg:si_cifracontrolabogado;
	COMMIT;
	
    SELECT numerocalle, nombrecalle from bdinteg:si_catcalles into temp CatCalles with no log; create index ix_calles on CatCalles (numerocalle);
    UPDATE STATISTICS medium FOR TABLE CatCalles;
	
	SELECT numerociudad, numerocolonia FROM bdinteg:si_catzonas 
	into temp CatZonas2 with no log;
	create index ix_zonas2 on CatZonas2 (numerociudad, numerocolonia);
    
	SELECT a.numerociudad, a.numerocolonia, nombrezona, numerociudadcoppel, centro, jefegrupozona,
			supervisorzona, numerocoloniacoppel 
	--from bdinteg:si_catzonas  
	FROM CatZonas2 a 
	INNER JOIN bdinteg:si_catzonas b ON a.numerociudad = b.numerociudad AND a.numerocolonia = b.numerocolonia
	into temp CatZonas with no log; 
	create index ix_zonas on CatZonas (numerociudad, numerocolonia);
    
	UPDATE STATISTICS medium FOR TABLE CatZonas;
    
	SELECT numerociudad, nombreciudad from bdinteg:si_catciudades  
	into temp Catciudades with no log; 
	create index ix_ciudades on CatCiudades (numerociudad) ;
    
	UPDATE STATISTICS medium FOR TABLE CatCiudades;

    -- Se crea tabla temporal para almacenar informacion de direcciones_actual, se crea tabla fisica.
    CREATE temp TABLE direc_paso (
        numcte CHAR(20),    tipo_dir CHAR(1),       numeroextcalle CHAR(10), numerointcalle CHAR(10), manzana SMALLINT,     otros SMALLINT,
        andador SMALLINT,   etapa SMALLINT,         lote SMALLINT,          edificio SMALLINT,        entrada SMALLINT,     departamento CHAR(6),
        cod_postal CHAR(5), puntocardinal CHAR(1),  observaciones CHAR(80), entre_calles CHAR(40),    numerociudad SMALLINT,/*extension CHAR(5),*/
        numerocolonia INTEGER,    numerocalle INTEGER,  estado CHAR(2) );
    CREATE INDEX ix_idx_direc_1 on direc_paso (numcte, tipo_dir);

    IF vfechaini IS NOT NULL THEN -- Si no existen datos anteriores ( fecha_movto=NULL, esta vacia la tabla y no carga dir modificadas, todas nuevas)

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga direcciones modificadas', '02') RETURNING p_resultado;

        /*-- Obtiene las direcciones de los clientes con direcciones modificadas de direcciones actual.
        SELECT  dir.numcte , dir.tipo_dir, dir.numeroextcalle, replace(dir.numerointcalle, '|','') numerointcalle, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote,
                dir.edificio, dir.entrada, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.observaciones, dir.entre_calles,
                dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.estado
          FROM bdinteg:si_direcciones_actual dir
         WHERE dir.fecha_insert >= mdy(month(vfechaini), day(vfechaini), year(vfechaini) )
           AND dir.fecha_insert <= mdy(month(vfechafin), day(vfechafin), year(vfechafin) )
        INTO temp direc_Modificadas with no log;
        create index ix_dir_modificadas on direc_Modificadas (numcte);
        UPDATE STATISTICS medium FOR TABLE direc_Modificadas;

        -- Obtiene las direcciones de los clientes con direcciones modificadas a utilizar en el proceso.
        INSERT INTO direc_paso
            SELECT  dir.numcte , dir.tipo_dir, dir.numeroextcalle, dir.numerointcalle, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote,
                    dir.edificio, dir.entrada, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.observaciones, dir.entre_calles,
                    dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.estado
               FROM direc_Modificadas dir
               JOIN CarteraLinea cart ON (dir.numcte = cart.numcte);
        --INTO temp direc_paso with no log;
        UPDATE STATISTICS medium FOR TABLE direc_paso;

        -- Obtiene informacion (direcciones) de clientes cuya zona/colonia asignada, sufrio modificaciones en su catalogo (catzonas).
        SELECT dir.numcte , dir.tipo_dir, dir.numeroextcalle, replace(dir.numerointcalle, '|','') numerointcalle, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote,
               dir.edificio, dir.entrada, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.observaciones, dir.entre_calles,
               dir.numerociudad,  dir.numerocolonia, dir.numerocalle, dir.estado
            FROM bdinteg:si_direcciones_actual dir
            JOIN CarteraLinea cart ON (dir.numcte = cart.numcte)
            JOIN bdinteg:si_catzonas zon ON (dir.ciudad = zon.numerociudad AND dir.numerocolonia = zon.numerocolonia)
                WHERE f_modifica >= mdy(month(vfechaini), day(vfechaini), year(vfechaini) )
                  AND f_modifica <= mdy(month(vfechafin), day(vfechafin), year(vfechafin) )
        INTO temp dir_zon_cam with no log;
        UPDATE STATISTICS medium FOR TABLE dir_zon_cam;
                    -- elimina registros duplicados de direcciones modificadas y de registros de zonas modificadas.
        DELETE FROM dir_zon_cam WHERE numcte IN (select numcte from direc_paso );
        INSERT INTO direc_paso
            SELECT numcte, tipo_dir, numeroextcalle, numerointcalle, manzana, otros, andador, etapa, lote,
                    edificio, entrada, departamento, cod_postal, puntocardinal, observaciones, entre_calles,
                    numerociudad, numerocolonia, numerocalle, estado FROM dir_zon_cam;*/
		BEGIN;
			INSERT INTO direc_paso
			SELECT  numcte, tipo_dir, numeroextcalle, numerointcalle, manzana, otros, andador, etapa, lote,
				edificio, entrada, departamento, cod_postal, puntocardinal, observaciones, entre_calles,
				numerociudad,  numerocolonia, numerocalle, estado FROM
				(SELECT DISTINCT dir.numcte , dir.tipo_dir, dir.numeroextcalle, replace(dir.numerointcalle, '|','') numerointcalle, dir.manzana,
								dir.otros, dir.andador, dir.etapa, dir.lote,
				dir.edificio, dir.entrada, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.observaciones, dir.entre_calles,
				dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.estado
			FROM bdinteg:si_direcciones_actual dir
					JOIN CarteraLinea cart ON (dir.numcte = cart.numcte)
			WHERE dir.fecha_insert >= vfechaini
			   AND dir.fecha_insert <= vfechafin
					UNION
			SELECT dir.numcte , dir.tipo_dir, dir.numeroextcalle, replace(dir.numerointcalle, '|','') numerointcalle, dir.manzana, dir.otros, dir.andador, dir.etapa, dir.lote,
			   dir.edificio, dir.entrada, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.observaciones, dir.entre_calles,
			   dir.numerociudad,  dir.numerocolonia, dir.numerocalle, dir.estado
			FROM bdinteg:si_direcciones_actual dir
			JOIN CarteraLinea cart ON (dir.numcte = cart.numcte)
			JOIN bdinteg:si_catzonas zon ON (dir.ciudad = zon.numerociudad AND dir.numerocolonia = zon.numerocolonia)
					WHERE f_modifica >= vfechaini
					  AND f_modifica <= vfechafin);
		COMMIT;
		
		UPDATE STATISTICS medium FOR TABLE direc_paso;
        -- Marca los registros de cteestadocuenta. 1 = Direc modif, 0 = Existe en edocob y direc no modificada NULL = Reg Nvo. ddirec_paso solo tiene las direc modif

		BEGIN;
			UPDATE CarteraLinea SET otros_ref = '1' WHERE numcte IN ( select numcte from direc_paso );

			-- Elimina registros con direcciones modificadas. Se insertaran como nuevos
			DELETE FROM bdinteg:si_cteestadocuenta WHERE numcte IN ( select numcte from direc_paso );
		COMMIT;

        UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:si_cteestadocuenta;
        UPDATE STATISTICS MEDIUM FOR TABLE direc_paso;
	

    END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga direcciones de ctes nuevos', '02') RETURNING p_resultado; -- borra
    -- Carga datos de direcciones de clientes nuevos para el Edo de Cobranza (estan en cartera en linea pero no en edo de cobranza).
    SELECT cart.numcte FROM CarteraLinea cart
        WHERE cart.numcte NOT IN ( Select numcte From bdinteg:si_cteestadocuenta ) INTO temp cte_sdo_cart WITH NO LOG;
    create index indx_ctesdocart on cte_sdo_cart (numcte);
    UPDATE STATISTICS MEDIUM FOR TABLE cte_sdo_cart;
    -- Elimina los q ya esten en los clientes con direcciones modificadas y sean nuevas para el estado de cob (no repetir).
        -- (prueba, se comenta DELETE para verificar si no elimina registro de mas que ocasiona calles nulas)-
    --DELETE FROM cte_sdo_cart WHERE numcte IN ( select numcte from direc_paso );
    -- Marca los registros nuevos para el estado de cobranza.
    UPDATE CarteraLinea SET otros_ref = '1' WHERE numcte IN ( select numcte from cte_sdo_cart );

	BEGIN;
		INSERT INTO direc_paso
			SELECT dir.numcte, dir.tipo_dir, dir.numeroextcalle, replace(dir.numerointcalle, '|','') numerointcalle, dir.manzana, dir.otros, dir.andador, dir.etapa,
				dir.lote, dir.edificio, dir.entrada, dir.departamento, dir.cod_postal, dir.puntocardinal, dir.observaciones, dir.entre_calles,
				dir.numerociudad, dir.numerocolonia, dir.numerocalle, dir.estado-- , '0' otros_ref
				FROM bdinteg:si_direcciones_actual dir
				JOIN cte_sdo_cart tabaux ON dir.numcte = tabaux.numcte;
		UPDATE STATISTICS MEDIUM FOR TABLE direc_paso;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga indicador cred', '02') RETURNING p_resultado;
	COMMIT;
	
	BEGIN;
		SELECT  cart.num_credito, cred.monto_ult_convenio, cred.fecha_ult_convenio, cred.cumplio_convenio, cred.monto_ultimo_pago, cred.f_primer_compra,
			cred.fecha_alta
			FROM bdicred:sd_indicador_cred cred
			JOIN CarteraLinea cart ON (cred.num_credito = cart.num_credito)
			WHERE empresa = vempresa
			AND monto_ult_convenio is not null
			INTO  temp indicador WITH NO LOG;
			create index inx_indicad on indicador (num_credito);
			update statistics medium for table indicador;
	COMMIT;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga cb_compac y  cb_compac_his', '02') RETURNING p_resultado;
    SELECT compac.numcliente, compac.numcuenta, ind.monto_ult_convenio, compac.fecha_compac, 'P' cumplio_convenio,  --ind.cumplio_convenio
        ind.monto_ultimo_pago, compac.plazo
        FROM bdicobranza:cb_compac compac,
             indicador ind
        WHERE compac.numcuenta = ind.num_credito
          and compac.fecha_compac = ind.fecha_ult_convenio
     into temp ultconvenio with no log;

    BEGIN;
		INSERT INTO ultconvenio
		SELECT compac.numcliente, compac.numcuenta, ind.monto_ult_convenio, compac.fecha_compac, case when ind.cumplio_convenio = '0' then 'N' else 'S' end cumplio_convenio ,    -- ind.cumplio_convenio,
			ind.monto_ultimo_pago, compac.plazo
			FROM bdicobranza:cb_compac_his compac,
				 indicador ind
			WHERE compac.numcuenta = ind.num_credito
			  and compac.fecha_compac = ind.fecha_ult_convenio;
		 create index inx_ultconvenio on ultconvenio(numcuenta);
		 UPDATE STATISTICS MEDIUM FOR TABLE ultconvenio;

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga se_ctessitespcte', '02') RETURNING p_resultado;
		 SELECT sitcte.numcte, situacion, causa
		   FROM bdisitesp:se_ctessitespcte sitcte
		   JOIN CarteraLinea cart ON (cart.numcte = sitcte.numcte)
		   INTO temp sitcte WITH NO LOG;
		 create index inx_sitcte on sitcte(numcte);
		 update statistics medium for table sitcte;

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga ss_resum_scor_fin', '02') RETURNING p_resultado;
		 SELECT num_solicitud, NVL(ingreso_mensual,0) / salariominban SalarioMinimo
		   FROM bdisolic:ss_resum_scor_fin resum
		   JOIN CarteraLinea cart ON (cart.num_credito = resum.num_solicitud)
		  WHERE empresa = vempresa
		   INTO temp temp_resum with no log;
		 create unique index inx_temp_resum on temp_resum(num_solicitud);
		 update statistics medium for table temp_resum;

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga si_ingresos', '02') RETURNING p_resultado;
		SELECT ing.numcte, ing.nombre_empresa
			FROM bdinteg:si_ingresos ing
			JOIN CarteraLinea cart ON (ing.numcte = cart.numcte )
			WHERE ing.sec_ingreso =(select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 where ing1.numcte= cart.numcte and ing1.tipo_ingreso= 'T')
			  AND ing.tipo_ingreso = 'T'
			INTO temp ingresos WITH NO LOG;
		 CREATE INDEX inx_tmp_ingresos on ingresos( numcte );
		 UPDATE STATISTICS MEDIUM FOR TABLE ingresos;

		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Carga telefonos', '02') RETURNING p_resultado;
		SELECT tel.* FROM bdinteg:si_telefonos_actual tel
			JOIN CarteraLinea cart ON (tel.numcte = cart.numcte)
			INTO temp telefonos WITH NO LOG;
		CREATE INDEX inx_tel ON telefonos (numcte, tipo_tel, status_tel, cofetel);
		UPDATE STATISTICS MEDIUM FOR TABLE telefonos;
	COMMIT;
	
    -- Obtiene fechas para identificar tipo de cliente para la clabe de cobranza
    EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(vfecha_hoy, -1 , day(vfecha_hoy)) INTO p_resultado, dFHoy_1m, iDiasTrans;
    EXECUTE PROCEDURE bdicred:"informix".sp_mes_siguiente(vfecha_hoy, -13, day(vfecha_hoy)) INTO p_resultado, dFHoy_13m, iDiasTrans;

    LET cPrimerReg = 0; LET vCuentaConSitEspL = 0;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Inicia foreach', '02') RETURNING p_resultado;

    -- Modifica los registros de clientes con direcciones modificadas e inserta los registros de clientes nuevos al Edo de Cobranza.
    FOREACH WITH HOLD
	    SELECT nvl(vempresa,' '), nvl(cart.num_credito,''), nvl(cart.numcte,' '), nvl(cart.num_tarjeta,' '),nvl(cart.sdo_cap_insoluto,0),
            nvl(cart.mto_venc_trasp + cart.monto_vencido,0),  -- saldo vencido
            nvl(cart.fecha_ult_pago,date(1)), nvl(cart.monto_financiado,0), nvl(cart.num_producto, ''),
            nvl(saldovencido1,0), nvl(saldovencido2,0), nvl(saldovencido3,0), nvl(saldovencido4,0), nvl(saldovencido5,0), nvl(saldovencido6,0),
            nvl(interesmoratorio1,0), nvl(interesmoratorio2,0), nvl(interesmoratorio3,0), nvl(interesmoratorio4,0), nvl(interesmoratorio5,0),
            nvl(interesmoratorio6,0), nvl(interes_iva,0), nvl(mto_fin_ven_trasp::INTEGER,0),
            lpad(TRIM(cte.sucursal),4,'0') AS sucursal, rpad(TRIM(cte.nombre1),20,' ') AS nombre1,
            rpad(TRIM(cte.nombre2),20,' ') AS nombre2, rpad(TRIM(cte.apell_paterno),20,' ') AS apellpaterno,
            rpad(TRIM(cte.apell_materno),20,' ') AS apellmaterno, rpad(TRIM(ctepf.estado_civil),2,' ') AS edo_civil,
            TRIM(decode(ctepf.habita_en,'01','P','02','R','03','F','04','G','05','H',ctepf.habita_en)) AS tipo_casa,
            rpad(TRIM(ctepf.sexo),1,' ') AS sexo, lpad(year(cte.fecha_alta),4,'0') AS ayoalta,
            lpad(year(ctepf.fecha_nac),4,'0') AS ayonac, cte.rfc,
            nvl(case when bdinteg:val_num(cte.numcte_ref) then cte.numcte_ref else '0' end,'0'), otros_ref
            INTO cEmpresa, cNumCredito, cNumCliente, cNumTarjeta, mSaldoActual, mSaldoVencido, dFechaUltimoPago, cpagominimo, cnum_producto,
                cSaldovencido1, cSaldovencido2, cSaldovencido3, cSaldovencido4, cSaldovencido5, cSaldovencido6,
                cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3, cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6,
                cInteresV, sAbonosVdos, cSucursal, cNombre1, cNombre2, cApellido1, cApellido2,  cEstadoCivil, cTipoCasa, cSexo, cAnioAlta,
                cAnioNacimiento, vRFC, cNumcte_ref, cRegs_DirecModif
            FROM CarteraLinea cart, bdinteg:si_cliente cte, bdinteg:si_ctepf ctepf
            WHERE cart.numcte = cte.numcte AND cart.numcte = ctepf.numcte
    
		if cPrimerReg  = 0 then
           CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'TerminaResolver Consulta', '02') RETURNING p_resultado;
        end if;
        LET cPrimerReg =1;

        IF vTotalCommit=0 THEN begin work; END IF;

        IF NOT val_num(cNumcte_ref) THEN LET cNumcte_ref = '0'; END IF;

        SELECT SalarioMinimo INTO cSalarioMinimoaux FROM temp_resum WHERE num_solicitud = cNumCredito;
        IF cSalarioMinimoaux >= 22 THEN     LET cSalarioMinimo = LPAD(22,2,'0');
        ELSE  LET cSalarioMinimo = LPAD(cSalarioMinimoaux::INTEGER::VARCHAR(2),2,'0');    END IF;
        IF (TRIM(cNumcte_ref) = '' OR cNumcte_ref IS NULL)  THEN LET cNumcte_ref = '0';  END IF;

        IF (cRegs_DirecModif = '1' OR cRegs_DirecModif IS NULL ) THEN -- Clientes con direccion modificada o Cliente Nuevo
            SELECT limit 1
                rpad(TRIM(calle.nombrecalle),30,' ') AS calle, TRIM(dir.numeroextcalle) AS numextcalle, TRIM(dir.numerointcalle) AS numintecalle,
                rpad(TRIM(zon.nombrezona),30,' ') AS colonia,lpad(dir.manzana,5,'0') AS manzana, lpad(dir.otros,5,'0') AS otros,
                lpad(dir.andador,5,'0') AS andador,  lpad(dir.etapa,5,'0') AS etapa, lpad(dir.lote,5,'0') AS lote, lpad(dir.edificio,5,'0') AS edificio,
                lpad(dir.entrada,5,'0') AS entrada, rpad(TRIM(dir.departamento),6,' ') AS departamento,
                lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal,
                rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal, rpad(TRIM(dir.observaciones),80,' ') AS complemento,
                rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles,  rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,
                rpad(TRIM(edo.nombre),25,' ') AS estado,
                case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
                     then lpad(dir.numerociudad,4,'0') else lpad(zon.numerociudadcoppel,4,'0') end numciudad,  -- numero ciudad cliente
                lpad(zon.centro,6,'0') AS numcentro, lpad(zon.jefegrupozona,8,'0') AS numjefe, lpad(zon.supervisorzona,8,'0') AS numsupervisor,
                case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
                     then lpad(dir.numerocolonia,4,'0') else lpad(zon.numerocoloniacoppel,4,'0')  end numcolonia,
                lpad(dir.numerocalle,6,'0') AS numcalle --, nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo
                Into cNombreCalle, cNumExterior, cNumInterio, cColonia,
                cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento,
                cEntreCalles, cDelegacionMunicipio, cEstado, cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor,
                cNumColoniacte, cNumCalleCte --, cLugarTrabajo
                FROM direc_paso  dir
                LEFT JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
                LEFT JOIN catcalles calle ON (dir.numerocalle = calle.numerocalle)
                LEFT JOIN catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
                LEFT JOIN catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
                WHERE dir.numcte = cNumCliente AND dir.tipo_dir = '1';
                  -- Obtiene la informacion si la calle es nula, es decir, si no se obtuvo la informacion se carga de direcciones.
            IF cNumCalleCte IS NULL THEN
                SELECT limit 1
                    rpad(TRIM(calle.nombrecalle),30,' ') AS calle, TRIM(dir.numeroextcalle) AS numextcalle, replace(dir.numerointcalle, '|','') AS numintecalle,
                    rpad(TRIM(zon.nombrezona),30,' ') AS colonia,lpad(dir.manzana,5,'0') AS manzana, lpad(dir.otros,5,'0') AS otros,
                    lpad(dir.andador,5,'0') AS andador,  lpad(dir.etapa,5,'0') AS etapa, lpad(dir.lote,5,'0') AS lote, lpad(dir.edificio,5,'0') AS edificio,
                    lpad(dir.entrada,5,'0') AS entrada, rpad(TRIM(dir.departamento),6,' ') AS departamento,
                    lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal,
                    rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal, rpad(TRIM(dir.observaciones),80,' ') AS complemento,
                    rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles,  rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,
                    rpad(TRIM(edo.nombre),25,' ') AS estado, case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = ''
                    or zon.numerociudadcoppel = 0) then lpad(dir.numerociudad,4,'0') else lpad(zon.numerociudadcoppel,4,'0') end numciudad,
                    lpad(zon.centro,6,'0') AS numcentro, lpad(zon.jefegrupozona,8,'0') AS numjefe, lpad(zon.supervisorzona,8,'0') AS numsupervisor,
                    case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0) then lpad(dir.numerocolonia,4,'0')
                    else lpad(zon.numerocoloniacoppel,4,'0')  end numcolonia, lpad(dir.numerocalle,6,'0') AS numcalle
                INTO cNombreCalle, cNumExterior, cNumInterio, cColonia, cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento,
                cCodPostal, cPuntoCardinal, cComplemento,cEntreCalles, cDelegacionMunicipio, cEstado, cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor,
                cNumColoniacte, cNumCalleCte FROM bdinteg:si_direcciones_actual dir
                LEFT JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
                LEFT JOIN catcalles calle ON (dir.numerocalle = calle.numerocalle)
                LEFT JOIN catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
                LEFT JOIN catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
                WHERE dir.numcte = cNumCliente AND dir.tipo_dir = '1';

                IF cNumCalleCte IS NULL THEN LET vTotalCommit=vTotalCommit+1; CONTINUE FOREACH; END IF; -- si no esta direccion Tipo_dir = 1 que continue
            END IF;

            SELECT FIRST 1 nvl(rpad(TRIM(nombre_empresa),25,' '),' ') AS lugartrabajo INTO cLugarTrabajo
                FROM ingresos
                WHERE numcte = cNumCliente;
            SELECT limit 1
                rpad(TRIM(calle.nombrecalle),30,' ') AS calle, TRIM(dir.numeroextcalle) AS numextcalle, TRIM(dir.numerointcalle) AS numintecalle,
                rpad(TRIM(zon.nombrezona),30,' ') AS colonia, lpad(dir.manzana,5,'0') AS manzana, lpad(dir.otros,5,'0') AS otros,
                lpad(dir.andador,5,'0') AS andador, lpad(dir.etapa,5,'0') AS etapa, lpad(dir.lote,5,'0') AS lote, lpad(dir.edificio,5,'0') AS edificio,
                lpad(dir.entrada,5,'0') AS entrada, rpad(TRIM(dir.departamento),6,' ') AS departamento,
                lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal,
                rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal, rpad(TRIM(dir.observaciones),80,' ') AS complemento,
                rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles, rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,
                rpad(TRIM(edo.nombre),25,' ') AS estado,
                case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
                     then lpad(dir.numerociudad,4,'0') else lpad(zon.numerociudadcoppel,4,'0') end numciudad,
                lpad(zon.centro,6,'0') AS numcentro, lpad(zon.jefegrupozona,8,'0') AS numjefe, lpad(zon.supervisorzona,8,'0') AS numsupervisor,
                case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
                     then lpad(dir.numerocolonia,4,'0') else lpad(zon.numerocoloniacoppel,4,'0') end numcolonia,
                lpad(dir.numerocalle,6,0) as numerocalle
                Into cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t,
                cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
                cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t, cDelegacionMunicipio_t, cEstado_t,
                cNumCiudadCte_t, cNumCentro_t, cNumJefe_t, cNumSupervisor_t, cNumColoniacte_t, cNumCalleCte_t  --esta ultima var agregada por MACF
                FROM direc_paso  dir , catzonas zon, bdinteg:si_estados edo, catcalles calle , catciudades ciudad
                WHERE dir.numcte = cNumCliente
                  AND dir.tipo_dir = '2'
                  and edo.estado = dir.estado
                  and zon.numerociudad = dir.numerociudad
                  and  zon.numerocolonia = dir.numerocolonia
                  and dir.numerocalle = calle.numerocalle
                  and ciudad.numerociudad = dir.numerociudad;

            --- Obtiene la informacion de direcciones, si el registro no esta en la temporal direc_paso
            IF cNumCalleCte_t IS NULL THEN
                SELECT limit 1
                    rpad(TRIM(calle.nombrecalle),30,' ') AS calle, TRIM(dir.numeroextcalle) AS numextcalle, replace(dir.numerointcalle, '|','') AS numintecalle,
                    rpad(TRIM(zon.nombrezona),30,' ') AS colonia, lpad(dir.manzana,5,'0') AS manzana, lpad(dir.otros,5,'0') AS otros,
                    lpad(dir.andador,5,'0') AS andador, lpad(dir.etapa,5,'0') AS etapa, lpad(dir.lote,5,'0') AS lote, lpad(dir.edificio,5,'0') AS edificio,
                    lpad(dir.entrada,5,'0') AS entrada, rpad(TRIM(dir.departamento),6,' ') AS departamento,
                    lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal,
                    rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal, rpad(TRIM(dir.observaciones),80,' ') AS complemento,
                    rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles, rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,
                    rpad(TRIM(edo.nombre),25,' ') AS estado, case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
                    then lpad(dir.numerociudad,4,'0') else lpad(zon.numerociudadcoppel,4,'0') end numciudad, lpad(zon.centro,6,'0') AS numcentro,
                    lpad(zon.jefegrupozona,8,'0') AS numjefe, lpad(zon.supervisorzona,8,'0') AS numsupervisor, case when (zon.numerociudadcoppel is null
                    or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0) then lpad(dir.numerocolonia,4,'0') else lpad(zon.numerocoloniacoppel,4,'0')
                    end numcolonia, lpad(dir.numerocalle,6,0) as numerocalle
                Into cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t, cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t,
                cEntrada_t, cDepartamento_t, cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t, cDelegacionMunicipio_t, cEstado_t,
                cNumCiudadCte_t, cNumCentro_t, cNumJefe_t, cNumSupervisor_t, cNumColoniacte_t, cNumCalleCte_t
                FROM bdinteg:si_direcciones_actual dir, catzonas zon, bdinteg:si_estados edo, catcalles calle , catciudades ciudad
                WHERE dir.numcte = cNumCliente AND dir.tipo_dir = '2' and edo.estado = dir.estado
                  and zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia
                  and dir.numerocalle = calle.numerocalle and ciudad.numerociudad = dir.numerociudad;

            END IF;

            SELECT FIRST 1 nombre_ref, telefono_ref into cNombreRef, cTelefonoRef FROM bdisolic:ss_refpersonales
                WHERE empresa = cEmpresa And numcte= cNumCliente  And nombre_ref is not null;

        END IF;

        -- Obtienen los telefonos de la tabla: si_telefonos_actual
        SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' ')
            INTO cTelefonoCasa FROM telefonos WHERE numcte = cNumCliente AND tipo_tel = 1 AND status_tel = 'A'
            AND cofetel = 'V' AND telefono <> '';
        SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' ')
            INTO cCelular FROM telefonos WHERE numcte = cNumCliente AND tipo_tel = 2 AND status_tel = 'A'
            AND cofetel = 'V' AND telefono <> '';
        SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' '),
            nvl(extension, '')  INTO cTelefonoTrabajo, cExtensionTrabajo FROM telefonos WHERE numcte = cNumCliente AND tipo_tel = 3
            AND status_tel = 'A' AND cofetel = 'V' AND telefono <> '';
        IF cTelefonoTrabajo IS NULL THEN
            SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' '),
                nvl(extension, '') INTO cTelefonoTrabajo, cExtensionTrabajo FROM telefonos WHERE numcte = cNumCliente AND tipo_tel = 4
                AND status_tel = 'A' AND cofetel = 'V' AND telefono <> '';
        END IF;

        IF   sAbonosVdos = 1 THEN LET cTipodecliente='1'; LET sNumAvisos='1';
        ELIF sAbonosVdos = 2 THEN LET cTipodecliente='1'; LET sNumAvisos='2';
        ELIF sAbonosVdos = 3 THEN LET cTipodecliente='2'; LET sNumAvisos='3';
        ELIF sAbonosVdos = 4 THEN LET cTipodecliente='3'; LET sNumAvisos='3';
        ELIF sAbonosVdos = 5 THEN LET cTipodecliente='4'; LET sNumAvisos='4';
        ELIF sAbonosVdos >=6 THEN
            IF sAbonosVdos > 6 THEN LET cTipodecliente='5'; ELSE LET cTipodecliente='4'; END IF;
            LET sNumAvisos='V';
        END IF;

        LET mSaldoContabMora = cInteresmoratorio1 + cInteresmoratorio2 + cInteresmoratorio3 + cInteresmoratorio4 + cInteresmoratorio5 + cInteresmoratorio6;
        LET mSaldoVencido = mSaldoVencido + cInteresV;
        LET mSaldoActual = mSaldoActual + cInteresV;
        LET cpagominimo= cpagominimo + cInteresV;
        LET cImpteUltimocompromiso  = 0;
        LET dFechaUltimocompac  = date(1);
        LET dFechaCumpliocompromiso = date(1);
        LET cCumplioCompromiso=" ";
        LET cPlazoCompromiso=" ";
        LET cImpteCompromisocumplido=" ";
        LET vlMontoUltimoPago = "";

        SELECT first 1 monto_ult_convenio, fecha_compac, cumplio_convenio, monto_ultimo_pago, nvl(plazo,'0')
          INTO cImpteUltimocompromiso, dFechaUltimocompac,cCumplioCompromiso, vlMontoUltimoPago, cPlazoCompromiso
          FROM ultconvenio
         WHERE numcuenta = cNumCredito;

        IF cCumplioCompromiso IS NULL OR cCumplioCompromiso=" " THEN LET cCumplioCompromiso='-'; END IF;
        LET vlMontoUltimoPago = nvl(vlMontoUltimoPago,'0');
        IF cCumplioCompromiso='S' THEN
            LET cImpteCompromisocumplido = vlMontoUltimoPago;  LET dFechaCumpliocompromiso=dFechaUltimoPago;
        END IF;
        IF cImpteUltimocompromiso IS NULL OR cImpteUltimocompromiso=" " THEN LET cImpteUltimocompromiso='00000'; END IF;
        LET cSituacionEspecial="";         LET cCausasituacionespecial=0;

        SELECT FIRST 1 situacion,causa INTO cSituacionEspecial,cCausasituacionespecial
          FROM sitcte WHERE numcte = cNumCliente;

        IF cSituacionEspecial IS NULL or cSituacionEspecial="" THEN LET cSituacionEspecial="-"; END IF;
        IF cCausasituacionespecial IS NULL THEN LET cCausasituacionespecial=0; END IF;
        IF (mSaldoContabMora < 0 or mSaldoContabMora is null) then let mSaldoContabMora = 0; end if;
        LET mSaldoContabMoraTotal = mSaldoContabMora;
        LET mSaldoTotalAcumulado   = mSaldoTotalAcumulado   + mSaldoActual;
        LET mSaldoVencidoAcumulado = mSaldoVencidoAcumulado + mSaldoVencido;
        LET mSaldoMoratorioAcumulado = mSaldoMoratorioAcumulado  + mSaldoContabMoraTotal;
        IF dFechaUltimoPago IS NULL THEN LET dFechaUltimoPago=DATE(1); END IF;
        LET cDiaUltimoPago    = lpad(day  (dFechaUltimoPago),2,"0");
        LET cMesUltimoPago    = lpad(month(dFechaUltimoPago),2,"0");
        LET cAnioUltimoPago   = lpad(year (dFechaUltimoPago),4,"0");
        IF dFechaUltimocompac IS NULL THEN LET dFechaUltimocompac=DATE(1); END IF;
        LET cDiaUltimoCompac  = lpad(day  (dFechaUltimocompac),2,"0");
        LET cMesUltimoCompac  = lpad(month(dFechaUltimocompac),2,"0");
        LET cAnioUltimoCompac = lpad(year (dFechaUltimocompac),4,"0");
        -- Determina la clave para el tipo de cliente a agregar para la clabe de cobranza.
        SELECT f_primer_compra, fecha_alta INTO dfecha_prim_comp, dFh_alta FROM indicador WHERE num_credito = cNumCredito;

        IF ( sAbonosVdos = 1 AND dfecha_prim_comp > dFHoy_1m AND dFh_alta >= dFHoy_13m ) THEN LET vTpoVdoCte = 1;
        ELIF sAbonosVdos <= 3 THEN LET vTpoVdoCte = 2;
        ELSE --sAbonosVdos > 3 THEN LET vTpoVdoCte = 3; END IF;
            LET vTpoVdoCte = 3; END IF;

        IF (cRegs_DirecModif = '1' OR cRegs_DirecModif IS NULL ) THEN -- Inserta clientes con dir modificada y nuevos

                Insert into bdinteg:si_cteestadocuenta(     --- DOM. PART
                --Insert into bdinteg:si_cteestadocta_sdo_cart(     --- DOM. PART
                empresa,sucursal,numcte ,nombre1,nombre2,apellido1,apellido2,calle,numeroextcalle ,numerointcalle ,colonia,
                manzana,otros,andador,etapa,lote,edificio,entrada,departamento,cod_postal ,puntocardinal,complemento,
                entre_calles,delegacion_municipio,estado ,telefono_casa, celular, numero_credito ,num_tarjeta_credito,situacioespecial,estado_civil,
                tipo_casa,sexo,salarios_minimos,anio_alta,anio_nacimiento,saldo_actual,saldo_vencido,saldo_moratorio,pagominimo ,fecha_ultimoabono,
                impte_ultimocompromiso ,fecha_ultimocompac ,plazo_compromiso,impte_compromisocumplido,fecha_cumpliocompromiso,cumplio_convenio,num_ciudadcte,
                num_centro ,num_jefe,num_supervisor ,num_coloniacte ,num_callecte,num_casacte,pago_vencido,fecha_diaultimopago,
                fecha_mesultimopago,fecha_anioultimopago,fecha_diaultimoacuerdo, fecha_mesultimoacuerdo ,fecha_anioultimoacuerdo,
                tipodecliente,causasituacionespecial ,abonos_vdos,num_avisos ,nom_ref,nom_calle_ref,num_ext_ref,num_int_ref,col_ref,
                manzana_ref,otros_ref,andador_ref,etapa_ref,lote_ref,edificio_ref,entrada_ref,depto_ref,cp_ref ,punto_cardinal_ref ,
                complemento_ref,entre_calles_ref,delegacion_municipio_ref,estado_ref ,telefono_ref,num_ciudad_ref ,
                num_coloniaref ,nom_conyugeofamiliar,tel_conyugeofamiliar,saldovencido1,saldovencido2,saldovencido3,saldovencido4,
                saldovencido5,saldovencido6,interesmoratorio1,interesmoratorio2,interesmoratorio3,interesmoratorio4,interesmoratorio5,
                interesmoratorio6,fecha_movto, num_producto, num_cta, rfc,imp_ult_abono, tipo_dir,numcte_ref, tipovencido )
                VALUES ('001',cSucursal,cNumCliente,cNombre1,cNombre2,cApellido1,cApellido2,cNombreCalle,cNumExterior,cNumInterio,cColonia,
                cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento,
                cEntreCalles,cDelegacionMunicipio, cEstado, cTelefonoCasa, cCelular, cNumCredito,cNumTarjeta,cSituacionEspecial,cEstadoCivil,
                cTipoCasa, cSexo,cSalarioMinimo,cAnioAlta, cAnioNacimiento,mSaldoActual,mSaldoVencido,mSaldoContabMoraTotal,cpagominimo,dFechaUltimoPago,
                cImpteUltimocompromiso, dFechaUltimocompac, cPlazoCompromiso, cImpteCompromisocumplido, dFechaCumpliocompromiso,cCumplioCompromiso,cNumCiudadCte,
                cNumCentro, cNumJefe, cNumSupervisor,cNumColoniacte, cNumCalleCte, cNumExterior,mSaldoVencido, cDiaUltimoPago,
                cMesUltimoPago, cAnioUltimoPago,cDiaUltimoCompac, cMesUltimoCompac, cAnioUltimoCompac, cTipodecliente,cCausasituacionespecial,sAbonosVdos, sNumAvisos,
                cNombreRef, cNomCalleRef, cNumExtRef, cNumIntRef, cColRef, cManzanaRef, cOtrosRef, cAndadorRef,cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef,
                cCpRef, cPuntoCardinalRef, cComplementoRef, cEntreCallesRef,cDelegacionMunicipioRef, cEstadoRef,cTelefonoRef, cNumCiudadRef, cNumColoniaRef,
                cNomConyugeoFamiliar, cTelConyugeoFamiliar,cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4, cSaldovencido5,cSaldovencido6,
                cInteresmoratorio1,cInteresmoratorio2,cInteresmoratorio3,cInteresmoratorio4,cInteresmoratorio5, cInteresmoratorio6, vfecha_hoy, cnum_producto,
                '', vRFC,vlMontoUltimoPago, cTipoDirPart,cNumcte_ref, vTpoVdoCte );

            IF cSituacionEspecial IN ('L', 'M' ) then           ---Validar si cte con sit. especial
                IF cNumCalleCte_t IS NULL THEN LET vTotalCommit=vTotalCommit+1; CONTINUE FOREACH; END IF; -- si no esta direccion Tipo_dir = 2 que continue
                Insert into bdinteg:si_cteestadocuenta(     --- DOM. TRABAJO
                --Insert into bdinteg:si_cteestadocta_sdo_cart(     --- DOM. TRABAJO
                empresa,sucursal,numcte ,nombre1,nombre2,apellido1,apellido2,calle, numeroextcalle ,numerointcalle ,colonia,
                manzana,otros,andador,etapa,lote,edificio,entrada,departamento,cod_postal ,puntocardinal,complemento,
                entre_calles,delegacion_municipio,estado , telefono_trabajo, extension_trabajo, lugar_trabajo,
                numero_credito ,num_tarjeta_credito,situacioespecial,estado_civil, tipo_casa,sexo,salarios_minimos,anio_alta,anio_nacimiento,saldo_actual,saldo_vencido,
                saldo_moratorio,pagominimo ,fecha_ultimoabono, impte_ultimocompromiso ,fecha_ultimocompac ,plazo_compromiso,impte_compromisocumplido,
                fecha_cumpliocompromiso,cumplio_convenio,num_ciudadcte, num_centro ,num_jefe,num_supervisor ,num_coloniacte ,num_callecte,num_casacte,pago_vencido,
                fecha_diaultimopago, fecha_mesultimopago,fecha_anioultimopago,fecha_diaultimoacuerdo ,fecha_mesultimoacuerdo ,fecha_anioultimoacuerdo, tipodecliente,
                causasituacionespecial ,abonos_vdos,num_avisos ,nom_ref,nom_calle_ref,num_ext_ref,num_int_ref,col_ref, manzana_ref,otros_ref,andador_ref,etapa_ref,
                lote_ref,edificio_ref,entrada_ref,depto_ref,cp_ref ,punto_cardinal_ref, complemento_ref,entre_calles_ref,delegacion_municipio_ref,estado_ref ,telefono_ref,
                num_ciudad_ref, num_coloniaref ,nom_conyugeofamiliar,tel_conyugeofamiliar,saldovencido1,saldovencido2,saldovencido3,saldovencido4, saldovencido5,
                saldovencido6,interesmoratorio1,interesmoratorio2,interesmoratorio3,interesmoratorio4,interesmoratorio5, interesmoratorio6,fecha_movto, num_producto,
                num_cta, rfc,imp_ult_abono, tipo_dir, numcte_ref, tipovencido )
                Values ('001',cSucursal,cNumCliente,cNombre1,cNombre2,cApellido1,cApellido2, cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t,
                cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t, cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t,
                cDelegacionMunicipio_t, cEstado_t,  cTelefonoTrabajo, cExtensionTrabajo, cLugarTrabajo, cNumCredito,cNumTarjeta,cSituacionEspecial,cEstadoCivil,
                cTipoCasa, cSexo,cSalarioMinimo,cAnioAlta, cAnioNacimiento,mSaldoActual,mSaldoVencido,mSaldoContabMoraTotal,cpagominimo,dFechaUltimoPago,
                cImpteUltimocompromiso, dFechaUltimocompac, cPlazoCompromiso, cImpteCompromisocumplido, dFechaCumpliocompromiso,cCumplioCompromiso,cNumCiudadCte_t,
                cNumCentro_t, cNumJefe_t, cNumSupervisor_t,cNumColoniacte_t, cNumCalleCte_t, cNumExterior,mSaldoVencido, cDiaUltimoPago, cMesUltimoPago, cAnioUltimoPago,cDiaUltimoCompac,
                cMesUltimoCompac, cAnioUltimoCompac, cTipodecliente,cCausasituacionespecial,sAbonosVdos, sNumAvisos, cNombreRef, cNomCalleRef, cNumExtRef, cNumIntRef,
                cColRef, cManzanaRef, cOtrosRef, cAndadorRef,cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef, cCpRef, cPuntoCardinalRef, cComplementoRef, cEntreCallesRef,
                cDelegacionMunicipioRef, cEstadoRef,cTelefonoRef, cNumCiudadRef, cNumColoniaRef, cNomConyugeoFamiliar, cTelConyugeoFamiliar,cSaldovencido1,cSaldovencido2,
                cSaldovencido3,cSaldovencido4, cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2,cInteresmoratorio3,cInteresmoratorio4,cInteresmoratorio5,
                cInteresmoratorio6, vfecha_hoy, cnum_producto, '', vRFC,vlMontoUltimoPago, cTipoDirTrab, cNumcte_ref, vTpoVdoCte );

                LET vCuentaConSitEspL = 1;
                LET mSaldoTotalAcumulado_2 = mSaldoTotalAcumulado_2 + mSaldoActual;
                LET mSaldoVencidoAcumulado_2 = mSaldoVencidoAcumulado_2 +  mSaldoVencido;
                LET mSaldoMoratorioAcumulado_2 = mSaldoMoratorioAcumulado_2 + mSaldoContabMoraTotal;

            END IF;

        ELSE  -- cRegs_DirecModif = '0'; Actualiza saldos de clientes con direcciones NO modificadas ( NO se tienen los datos en direc_paso).

            UPDATE bdinteg:si_cteestadocuenta SET
                telefono_casa = cTelefonoCasa, celular = cCelular, num_tarjeta_credito = cNumTarjeta, situacioespecial = cSituacionEspecial,
                estado_civil = cEstadoCivil, tipo_casa = cTipoCasa, sexo = cSexo, salarios_minimos = cSalarioMinimo, anio_alta = cAnioAlta,
                anio_nacimiento = cAnioNacimiento, saldo_actual = mSaldoActual, saldo_vencido = mSaldoVencido, saldo_moratorio = mSaldoContabMoraTotal,
                pagominimo = cpagominimo, fecha_ultimoabono = dFechaUltimoPago, impte_ultimocompromiso = cImpteUltimocompromiso,
                fecha_ultimocompac = dFechaUltimocompac, plazo_compromiso = cPlazoCompromiso, impte_compromisocumplido = cImpteCompromisocumplido,
                fecha_cumpliocompromiso = dFechaCumpliocompromiso, cumplio_convenio = cCumplioCompromiso, pago_vencido = mSaldoVencido,
                fecha_diaultimopago = cDiaUltimoPago, fecha_mesultimopago = cMesUltimoPago, fecha_anioultimopago = cAnioUltimoPago,
                fecha_diaultimoacuerdo = cDiaUltimoCompac, fecha_mesultimoacuerdo = cMesUltimoCompac, fecha_anioultimoacuerdo = cAnioUltimoCompac,
                tipodecliente = cTipodecliente, causasituacionespecial = cCausasituacionespecial, abonos_vdos = sAbonosVdos, num_avisos = sNumAvisos,
                saldovencido1 = cSaldovencido1, saldovencido2 = cSaldovencido2, saldovencido3 = cSaldovencido3, saldovencido4 = cSaldovencido4,
                saldovencido5 = cSaldovencido5, saldovencido6 = cSaldovencido6, interesmoratorio1 = cInteresmoratorio1, interesmoratorio2 = cInteresmoratorio2,
                interesmoratorio3 = cInteresmoratorio3, interesmoratorio4 = cInteresmoratorio4, interesmoratorio5 = cInteresmoratorio5,
                interesmoratorio6 = cInteresmoratorio6, fecha_movto = vfecha_hoy, imp_ult_abono = vlMontoUltimoPago, numcte_ref = cNumcte_ref,
                tipovencido = vTpoVdoCte
                WHERE empresa = vempresa AND numcte = cNumCliente AND numero_credito = cNumCredito  AND tipo_dir = '1';

            -- Actualiza tipo dir, solamente si existen dos registros del credito ( personal y trabajo)
            IF cSituacionEspecial IN ('L', 'M' ) then           ---Validar si cte con sit. especial
                UPDATE bdinteg:si_cteestadocuenta SET
                    telefono_casa = cTelefonoCasa, celular = cCelular, num_tarjeta_credito = cNumTarjeta, situacioespecial = cSituacionEspecial,
                    estado_civil = cEstadoCivil, tipo_casa = cTipoCasa, sexo = cSexo ,salarios_minimos = cSalarioMinimo, anio_alta = cAnioAlta,
                    anio_nacimiento = cAnioNacimiento, saldo_actual = mSaldoActual, saldo_vencido = mSaldoVencido, saldo_moratorio = mSaldoContabMoraTotal,
                    pagominimo = cpagominimo, fecha_ultimoabono = dFechaUltimoPago, impte_ultimocompromiso = cImpteUltimocompromiso,
                    fecha_ultimocompac = dFechaUltimocompac, plazo_compromiso = cPlazoCompromiso, impte_compromisocumplido = cImpteCompromisocumplido,
                    fecha_cumpliocompromiso = dFechaCumpliocompromiso, cumplio_convenio = cCumplioCompromiso, pago_vencido = mSaldoVencido,
                    fecha_diaultimopago = cDiaUltimoPago, fecha_mesultimopago = cMesUltimoPago, fecha_anioultimopago = cAnioUltimoPago,
                    fecha_diaultimoacuerdo = cDiaUltimoCompac, fecha_mesultimoacuerdo = cMesUltimoCompac, fecha_anioultimoacuerdo = cAnioUltimoCompac,
                    tipodecliente = cTipodecliente, causasituacionespecial = cCausasituacionespecial, abonos_vdos = sAbonosVdos, num_avisos = sNumAvisos,
                    saldovencido1 = cSaldovencido1, saldovencido2 = cSaldovencido2, saldovencido3 = cSaldovencido3, saldovencido4 = cSaldovencido4,
                    saldovencido5 = cSaldovencido5, saldovencido6 = cSaldovencido6, interesmoratorio1 = cInteresmoratorio1, interesmoratorio2 = cInteresmoratorio2,
                    interesmoratorio3 = cInteresmoratorio3, interesmoratorio4 = cInteresmoratorio4, interesmoratorio5 = cInteresmoratorio5,
                    interesmoratorio6 = cInteresmoratorio6, fecha_movto = vfecha_hoy, imp_ult_abono = vlMontoUltimoPago, numcte_ref = cNumcte_ref,
                    tipovencido = vTpoVdoCte
                    WHERE empresa = vempresa AND numcte = cNumCliente AND numero_credito = cNumCredito  AND tipo_dir = '2';

                LET vCuentaConSitEspL = 1;
                LET mSaldoTotalAcumulado_2 = mSaldoTotalAcumulado_2 + mSaldoActual;
                LET mSaldoVencidoAcumulado_2 = mSaldoVencidoAcumulado_2 +  mSaldoVencido;
                LET mSaldoMoratorioAcumulado_2 = mSaldoMoratorioAcumulado_2 + mSaldoContabMoraTotal;

            END IF;
        END IF;

        LET vTotalRegistros = vTotalRegistros + vCuentaConSitEspL + 1;
        LET vTotalCommit=vTotalCommit+1;
        IF vTotalCommit>=1000 THEN
            COMMIT WORK;
            LET vTotalCommit=0;
        END IF;

        LET vCuentaConSitEspL = 0;  LET cRegs_DirecModif = '';
        LET sAbonosVdos=0;          LET cSaldovencido1=0;       LET cSaldovencido2=0;       LET cSaldovencido3=0;       LET cSaldovencido4=0;
        LET cSaldovencido5=0;       LET cSaldovencido6=0;       LET cInteresmoratorio1=0;   LET cInteresmoratorio2=0;   LET cInteresmoratorio3=0;
        LET cInteresmoratorio4=0;   LET cInteresmoratorio5=0;   LET cInteresmoratorio6=0;   LET cInteresV=0;            LET cproyecmora=0;

    END FOREACH;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Termina foreach. Inicia cdr', '02') RETURNING p_resultado;
    IF vTotalCommit>0 THEN
        COMMIT WORK;
        Update statistics medium for table bdinteg:si_cteestadocuenta;
    END IF;

    CALL bdinteg:sp_llenacteestadocuenta_cdr(vfecha_hoy, vfecha_ultimo) -- archivo paralelo
        RETURNING P_COD_RET, vvTotalRegistros, mmSaldoTotalAcumulado, mmSaldoVencidoAcumulado, mmSaldoMoratorioAcumulado;

    LET vTotalRegistros             = vTotalRegistros + vvTotalRegistros;
    LET mSaldoTotalAcumulado        = mSaldoTotalAcumulado + mmSaldoTotalAcumulado + mSaldoTotalAcumulado_2;
    LET mSaldoVencidoAcumulado      = mSaldoVencidoAcumulado + mmSaldoVencidoAcumulado + mSaldoVencidoAcumulado_2;
    LET mSaldoMoratorioAcumulado    = mSaldoMoratorioAcumulado + mmSaldoMoratorioAcumulado + mSaldoMoratorioAcumulado_2;

    -- Obtiene saldos desde tabla
    SELECT count(*),  sum(saldo_actual) as saldo_total, sum(saldo_vencido), sum(saldo_moratorio) --, vfecha_hoy
        INTO vTotalRegistros, mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado
        FROM bdinteg:si_cteestadocuenta WHERE fecha_movto = vfecha_hoy;

    Insert into si_cifracontrolabogado(empresa, numero_registros, saldo_total, saldo_vencido, saldo_moratorio, fecha_movto)
            values('001', vTotalRegistros, mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado , vfecha_hoy);

    ---NUEVA PARTE PARA CILOC
    LET vvTotalRegistros = 0;
    LET mmSaldoTotalAcumulado = 0;
    LET mmSaldoVencidoAcumulado = 0;
    LET mmSaldoMoratorioAcumulado = 0;

/*  Probablemente se ingresarâ?? despuâ??s este llamado
    CALL bdinteg:sp_llenacteestadocuenta_loc()
        RETURNING P_COD_RET, vvTotalRegistros, mmSaldoTotalAcumulado, mmSaldoVencidoAcumulado, mmSaldoMoratorioAcumulado;   */
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Termina crd e Inicia armasentencia', '02') RETURNING p_resultado;

    CALL bdinteg:sp_armasentencia_edocob(vfecha_hoy) RETURNING var_rga2;

    -- Generacion del Archivo de Cifras Control Abogado.
    LET cSql = ' echo "UNLOAD TO ' || trim(cRutaArch) || 'CifrasControlAbogadoRegistros.unl DELIMITER ' || '''|'''  ||
            ' SELECT d.numero_registros, d.saldo_total, d.saldo_vencido, d.saldo_moratorio, d.fecha_movto ' ||
            ' FROM bdinteg:si_cifracontrolabogado d WHERE year(d.fecha_movto) = ' || year(vfecha_hoy) ||
            ' and month(d.fecha_movto) = ' || month(vfecha_hoy)||' and day(d.fecha_movto) = ' || day(vfecha_hoy) || ';' ||
            ' " > CifrasControlAbogado.sql';
    SYSTEM cSql;  LET cSql = '';
    LET cSql = 'dbaccess bdinteg CifrasControlAbogado.sql';
    SYSTEM cSql;
    LET cSql = "sed 's/|$//g' " || trim(cRutaArch) || "CifrasControlAbogadoRegistros.unl > " || cNombreArchivo2;
    SYSTEM cSql;  LET cSql = '';
    LET cSql = 'rm EstadoCtaAbogado.sql CifrasControlAbogado.sql ' || trim(cRutaArch) || 'CtaAbogadoRegistros.unl ';
    SYSTEM cSql; LET cSql = '';
    LET cSql = 'rm ' || trim(cRutaArch) || 'CifrasControlAbogadoRegistros.unl ' || trim(cRutaArch) || 'paso001.txt';
    SYSTEM cSql;
    LET cSql = '';

    --DROP TABLE sd_paso_creda_tab;

    LET vdia = day(vfecha_hoy);  LET p_resultado = '';
    IF vdia < 20 THEN

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', 'Inicia sp_cartareest_catpromo', '02') RETURNING p_resultado;

        CALL bdinteg:"informix".sp_cartareest_catpromo('001') RETURNING p_resultado, pmensaje;
        IF p_resultado <> '000000' THEN
              RETURN "PROCESO sp_cartareest_catpromo NO FINALIZâ?? EXITOSAMENTE " || p_resultado;
        END IF;
        ELSE
                -- Genera archivo vacio Reestructuras_XXXXXXXX.txt
                let cNombreArchivo3 = trim('Reestructuras_' || trim(diaHoy) || trim(vMes) || trim(vAnio) || '.txt');
                let cSql = 'echo " Set Isolation to dirty read; Unload to ' ||  trim(cRutaArch) || cNombreArchivo3;

                let cSql='';
                let cSql = 'echo "Archivo vacio generado del dâ??a 23'|| '-Favor de borrar' ||
                                   ' " > ' || trim(cRutaArch) || cNombreArchivo3;
                SYSTEM cSql;

                 -- Genera archivo vacio Carta_Invitacion_ReestXXXXXXXX.txt
                let cNombreArchivo3 = trim('Carta_Invitacion_Reest' || trim(diaHoy) || trim(vMes) || trim(vAnio) || '.txt');
                let cSql = 'echo " Set Isolation to dirty read; Unload to ' || trim(cRutaArch) || cNombreArchivo3;

                let cSql='';
                let cSql = 'echo "Archivo vacio generado del dâ??a 23'|| '-Favor de borrar' ||
                                   ' " > ' || trim(cRutaArch) || cNombreArchivo3;
                SYSTEM cSql;
    END IF;


    IF P_COD_RET = "000000" THEN
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,'', '','03' )
        RETURNING p_resultado;
    END IF;


    RETURN P_COD_RET;

END;
END PROCEDURE
DOCUMENT
'AUTOR      : MACF',
'DESCRIPCION: Modificaciones para el IFRS, BD(bdinteg)',
'FECHA      : 2022/01/07';

CREATE PROCEDURE "informix".sp_llenacteestadocuenta_cdr(pdFecha_hoy DATE, pdFecha_ultimo DATE)
returning char (50), integer, money(18), money(18), money(18);
-- MACF 2011-12-05 Validación de teléfonos.
-- Martha Aguirre 08-Sep-09 Se agrega filtro por tipo de ingreso en la búsqueda de tabla si_ingresos
-- MAHR 2012-01-19 Se agrego el campo numcte_ref a la tabla: si_cteestadocuenta
-- MAHR Junio 2012. Se genera estado de cobranza con informacion en Cartera en Línea: sd_sdos_cartera_linea.
-- MAHR Agosto 2012. Se obtiene informacion de telefonos de tabla: bdinteg:si_telefonos_actual
-- MAHR Dic 2012. Optimización de querys.
--  execute procedure "informix".sp_llenacteestadocuenta_cdr('04-29-215','04-30-2015')

define cNumCredito,cNumCliente, cNumcte_ref                                 char(20);
--define cNumTarjeta                                                          char(16);
define mSaldoActual,mSaldoVencido,mSaldoContabMora,mSaldoContabMoraTotal    money(18,2);
define cSalarioMinimoaux                                                    decimal(14,2);
define cSucursal,cNumCiudadRef,cNumColoniaRef                               char(4);
define cNombre1,cNombre2,cApellido1,cApellido2                              char(26);
define cNombreCalle,cNombreCalle_t,cNomCalleRef,cColRef                     char(30);
define cNumInterio,cNumInterio_t,cNumExterior,cNumExterior_t                char(10);
define cColonia,cColonia_t,cManzana,cManzana_t                              char(30);
define cOtros,cOtros_t,cAndador,cAndador_t,cEtapa,cEtapa_t,cLote,cLote_t    char(5);
define cEdificio,cEdificio_t,cEntrada,cEntrada_t,cSalarioMinimo             char(5);
define cDepartamento,cDepartamento_t,cNumCentro,cNumCalleCte,cDeptoRef, vvcCod_ret  char(6);
define cCodPostal,cCodPostal_t,cExtensionTrabajo                            char(5);
define cPuntoCardinal,cPuntoCardinal_t,cSituacionEspecial,cSexo, cTipoDirPart, cTipoDirTrab char(1);
define cComplemento,cComplemento_t,cComplementoRef                          char(80);
define cEntreCalles,cEntreCalles_t,cEntreCallesRef                          char(40);
define cDelegacionMunicipio,cDelegacionMunicipio_t,cEstado,cEstado_t        char(25);
define cTelefonoCasa,cTelefonoTrabajo,cCelular,cTelefonoRef                 char(13);
define cEstadoCivil,cTipoCasa,cDiaUltimoPago,cMesUltimoPago                 char(2);
define cAnioAlta,cAnioNacimiento,cNumCiudadCte,cNumCiudadCte_t              char(4);
define cNumJefe,cNumSupervisor,cPlazoCompromiso                             char(8);
define cNumColoniacte,cNumColoniacte_t,cAnioUltimoPago,cAnioUltimoCompac    char(4);
define cLugarTrabajo                                                        char(60);
define dFechaUltimoPago,dFechaUltimocompac,dFechaCumpliocompromiso     date;
define cImpteUltimocompromiso,cImpteCompromisocumplido,vlMontoUltimoPago    char(5);
define cDiaUltimoCompac,cMesUltimoCompac                    char(2);
define vTotalRegistros,vTotalCommit,sAbonosVdos                             integer;
define mSaldoTotalAcumulado,mSaldoVencidoAcumulado,mSaldoMoratorioAcumulado money(18);
--define mIvaSucursal                                                         money(5,3);
define vfechaini,vfechafin,vfecha_hoy,vfecha_ultimo,vfechavenci, dfh1erVenc, dfhUltVenc Date;
define cEmpresa, vempresa                                                   char(3);
define sNumAvisos,cPuntoCardinalRef,cTipodecliente,cCumplioCompromiso       char(1);
define cNombreRef,cNomConyugeoFamiliar                                      char(78);
define cNumExtRef,cNumIntRef                                                char(10);
define cManzanaRef,cOtrosRef,cAndadorRef,cEtapaRef,cLoteRef,cEdificioRef    char(5);
define cEntradaRef,cCpRef,var_rga                                           char(5);
define cDelegacionMunicipioRef,cEstadoRef                                   char(25);
define cTelConyugeoFamiliar                                                 char(13);
define cNombreArchivo,cNombreArchivo2                                       char(70);
define cSql                                                                 char(2500);
define cpagominimo,cSalvenci,cMoraaux,cInteresaux,cInteresV                 money(18,2);
define vmensualidades_min,vmensualidades_max,salariominban                  integer;
define vmontodeudaabogmin                                                   integer;
define cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4          money(18,2);
define cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2  money(18,2);
define cInteresmoratorio3,cInteresmoratorio4                                money(18,2);
define cInteresmoratorio5,cInteresmoratorio6,cproyecmora                    decimal(18,2);
--define ctasamora                                                            decimal(9,6);
DEFINE sPaso, vTpoVdoCte, cCausasituacionespecial                           SMALLINT; --CAS
DEFINE cnum_producto, cProceso                                              char(4);
define cnum_cta                                                             char(20);
DEFINE vRFC                                                                 CHAR(13);
DEFINE SQL_ERR,ISAM_ERR                                                     INTEGER;
DEFINE ERROR_INFO,P_MENSAJE                                                 VARCHAR(80);
--DEFINE P_COD_RET                 VARCHAR(5);   
DEFINE P_COD_RET                                                            VARCHAR(6);  --MACF

LET cProceso = '0023'; LET vempresa = '001';  LET P_COD_RET = '000000';  LET vvcCod_ret = '';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION TO DIRTY READ;

BEGIN 
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        Set debug file to "/resplogifx/archivoscartera/sp_llena.out"; 
        trace on;
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = cNumCredito || '-' ||ERROR_INFO;
        let cNumCredito = cNumCredito;
        -- ROLLBACK WORK;
  	    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
               RETURNING vvcCod_ret;
        
        if P_COD_RET = -668 then
            RETURN "No copio el archivo al servidor destino " ||  P_COD_RET, vTotalRegistros, mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado;
        else
            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_credacrd_tab';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_paso_credacrd_tab;
            END IF;
            RETURN P_COD_RET, vTotalRegistros, mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado;
        end if;  
    END EXCEPTION;

--SET DEBUG FILE TO "/informix/sp_llenacteestadocuenta_cdr.out";
--TRACE ON;

LET cNumCredito  = ""; LET  cNumCliente =  ""; LET  mSaldoActual = 0; -- LET  cNumTarjeta  =  "";
LET mSaldoVencido = 0; LET  cSalarioMinimoaux=0; LET  cSalarioMinimo  =  ""; LET  cSucursal  =  "";
LET cNombre1  =  ""; LET  cNombre2  =  ""; LET  cApellido1  =  ""; LET  cApellido2  =  "";
LET cNombreCalle  =  ""; LET  cNumInterio  =  ""; LET  cNumExterior   =  ""; LET  cColonia  =  "";
LET cManzana  =  ""; LET  cOtros  =  ""; LET  cAndador  =  ""; LET  cEtapa  =  ""; LET  cLote  =  "";
LET cEdificio  =  ""; LET  cEntrada  =  ""; LET  cDepartamento  =  ""; LET  cCodPostal  =  "";
LET cPuntoCardinal  =  ""; LET  cComplemento  =  ""; LET  cEntreCalles   =  ""; LET  cDelegacionMunicipio  =  "";
LET cEstado  =  ""; LET  cTelefonoCasa  =  ""; LET  cTelefonoTrabajo  =  ""; LET  cExtensionTrabajo   =  "";
LET cCelular   =  ""; LET  cEstadoCivil   =  ""; LET  cTipoCasa   =  ""; LET  cSexo   =  ""; 
LET cAnioAlta   =  ""; LET  cAnioNacimiento   =  ""; LET  cNumCiudadCte   =  ""; LET  cNumCentro   =  "";
LET cNumJefe   =  ""; LET  cNumSupervisor   =  ""; LET  cNumColoniacte   =  ""; LET  cNumCalleCte   =  "";
LET cLugarTrabajo   =  ""; LET  dFechaUltimoPago  = date(1); LET  cDiaUltimoPago   =  ""; LET  cMesUltimoPago   =  "";
LET cAnioUltimoPago   =  ""; LET  cPlazoCompromiso  = ""; LET  cImpteCompromisocumplido  = ""; LET vlMontoUltimoPago= "";
LET dFechaCumpliocompromiso  = date(1); LET  cDiaUltimoCompac = ""; LET  cMesUltimoCompac = "";
LET cAnioUltimoCompac = ""; LET  vTotalRegistros = 0; LET  mSaldoTotalAcumulado = 0; LET  mSaldoVencidoAcumulado = 0;
LET mSaldoMoratorioAcumulado = 0; LET  mSaldoContabMora = 0; LET  mSaldoContabMoraTotal = 0;
LET vfecha_hoy= date(1); LET  vfechaini= date(1); LET vfecha_ultimo= date(1); LET  vfechafin= date(1);
LET cEmpresa=""; LET  sAbonosVdos =0; LET  sNumAvisos =0; LET  cNombreRef=""; LET  cNomCalleRef="";
LET cNumExtRef=""; LET  cNumIntRef=""; LET  cColRef=""; LET  cManzanaRef=""; LET  cOtrosRef=""; 
LET cAndadorRef=""; LET  cEtapaRef=""; LET  cLoteRef=""; LET  cEdificioRef=""; LET  cEntradaRef="";
LET cDeptoRef=""; LET  cCpRef=""; LET  cPuntoCardinalRef=""; LET  cComplementoRef=""; LET  cEntreCallesRef="";
LET cDelegacionMunicipioRef=""; LET  cEstadoRef=""; LET  cTelefonoRef=""; LET  cNumCiudadRef=""; LET  cNumColoniaRef="";
LET cNomConyugeoFamiliar=""; LET  cTelConyugeoFamiliar=""; LET cTipoDirPart = '1'; LET cTipoDirTrab = '2';
--INI CAS
LET cNombreCalle_t=""; LET  cNumExterior_t=""; LET  cNumInterio_t=""; LET  cColonia_t=""; LET  cManzana_t="";
LET cOtros_t=""; LET  cAndador_t=""; LET  cEtapa_t=""; LET  cLote_t=""; LET  cEdificio_t=""; LET  cEntrada_t="";
LET cDepartamento_t=""; LET  cCodPostal_t=""; LET  cPuntoCardinal_t=""; LET  cComplemento_t=""; LET  cEntreCalles_t="";
LET cDelegacionMunicipio_t=""; LET  cEstado_t=""; LET  cNumCiudadCte_t=""; LET  cNumColoniacte_t=""; LET  cSaldovencido1=0;
LET cSaldovencido2=0; LET  cSaldovencido3=0; LET  cSaldovencido4=0; LET  cSaldovencido5=0; LET  cSaldovencido6=0; 
LET cInteresmoratorio1=0; LET  cInteresmoratorio2=0; LET  cInteresmoratorio3=0; LET  cInteresmoratorio4=0; LET  cInteresmoratorio5=0;
LET cInteresmoratorio6=0; LET  cInteresaux=0; LET  cInteresV=0; LET  cpagominimo=0; --LET  ctasamora=0;  
--FIN CAS
LET cSQL = ""; LET  vTotalCommit=0; 
LET vmensualidades_min = 0; LET vmensualidades_max = 0; LET vmontodeudaabogmin = 0;
LET var_rga = ""; LET  vfechavenci=date(0); 
LET cnum_producto = '';
let cnum_cta = '';


    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, '', '', '01') RETURNING vvcCod_ret;

    --Select date(fecha_ant), date (ult_dia_mes) Into vfecha_hoy, vfecha_ultimo From bdicred:sd_fechas; 
    LET vfecha_hoy = pdFecha_hoy;       -- Se pasa por parametro la fecha
    LET vfecha_ultimo = pdFecha_ultimo;
    select valor into salariominban from bdisolic:ss_param  where empresa= vempresa and secuencia='303';
    Select (valor+0) Into vmensualidades_min From bdinteg:si_param  where empresa= vempresa and cod_param = '119';
    Select (valor+0) Into vmensualidades_max From bdinteg:si_param  where empresa= vempresa and cod_param = '120';
    Select (valor+0) Into vmontodeudaabogmin From bdinteg:si_param  where empresa= vempresa and cod_param = '109';
    --------------------------------------------------------------------------------------------------

    SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_credacrd_tab';
    IF NVL(sPaso,0) > 0 THEN
        DROP TABLE "informix".sd_paso_credacrd_tab;
    END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Carga  CarteraLinea CRD y si esp 1', '02') RETURNING vvcCod_ret;

    -- Carga informacion de Cartera en linea.
    SELECT * FROM bdicred:sd_sdos_cartera_linea cart
        WHERE cart.num_producto IN ('6300', '6011','6400','7600', '7700') --A.L.L. '7600', '7700')
        AND cart.sdo_cap_insoluto >= vmontodeudaabogmin
        AND cart.mto_fin_ven_trasp between vmensualidades_min and vmensualidades_max
        --AND cart.status_cred in ('BA','BT','VP')
		--AND cart.status_cred in('E1','E2','E3','VP') AND (cart.monto_vencido + cart.mto_venc_trasp) > 0
        AND (cart.monto_vencido + cart.mto_venc_trasp) > 0
		INTO temp CarteraLinea_crd WITH NO LOG;
    CREATE INDEX ix_CarteraLineacrd_1 ON CarteraLinea_crd (numcte);
    CREATE UNIQUE INDEX ix_CarteraLineacrd_2 ON CarteraLinea_crd (num_credito);
    UPDATE STATISTICS medium FOR TABLE CarteraLinea_crd;

    -- Identifica clientes con situacion especial (no se imprimiran si cuentan con situacion especial)
    CREATE TABLE "informix".sd_paso_credacrd_tab (num_credito CHAR(20));
    SELECT num_credito FROM CarteraLinea_crd WHERE numcte in (select numcte from bdisitesp:se_ctessitespcte a, 
        bdisitesp:se_situacionaccion b where a.situacion = b.situacion and a.causa = b.causa and idaccion = 5 and instruccion = '0')
        GROUP BY 1 INTO temp paso_sitespcrd_sdocart with no log;

    INSERT INTO "informix".sd_paso_credacrd_tab
        SELECT * FROM paso_sitespcrd_sdocart group by 1;
    CREATE UNIQUE INDEX inx_sd_paso_credcrd_t on "informix".sd_paso_credacrd_tab(num_credito);
    UPDATE STATISTICS medium FOR TABLE "informix".sd_paso_credacrd_tab;

    -- Eliminar de la cartera en linea, los creditos que tienen situacion especial.
    DELETE FROM CarteraLinea_crd WHERE num_credito IN (select num_credito from sd_paso_credacrd_tab);
    -- Eliminar de la cartera en linea, los creditos que se encuentran en BAJA.
    DELETE FROM CarteraLinea_crd WHERE num_credito IN (select num_credito from bdicred:sd_maecredcrd where campo_trab3 = 'BAJA');

    -- Genera catalogos en tablas temporales.
    --SELECT * from bdinteg:si_catcalles into temp CatCallescrd with no log; 
	SELECT numerocalle, nombrecalle from bdinteg:si_catcalles into temp tmp_CatCallescrd with no log; 
	SELECT a.* from bdinteg:si_catcalles a INNER JOIN tmp_CatCallescrd b ON a.numerocalle = b.numerocalle into temp CatCallescrd with no log; 
	create index ix_callescrd on CatCallescrd (numerocalle);
    UPDATE STATISTICS medium FOR TABLE CatCallescrd;
	
    --SELECT * from bdinteg:si_catzonas  into temp CatZonascrd with no log; 
	SELECT numerociudad, numerocolonia from bdinteg:si_catzonas  into temp tmp_CatZonascrd with no log; 
	SELECT a.* from bdinteg:si_catzonas a INNER JOIN tmp_CatZonascrd b ON a.numerociudad = b.numerociudad AND a.numerocolonia = b.numerocolonia into temp CatZonascrd with no log;
	create index ix_zonascrd on CatZonascrd (numerociudad, numerocolonia);
    UPDATE STATISTICS medium FOR TABLE CatZonascrd;
    --SELECT * from bdinteg:si_catciudades  into temp Catciudadescrd with no log; 
	SELECT numerociudad, numeroestado from bdinteg:si_catciudades into temp tmp_Catciudadescrd with no log; 
	SELECT a.* from bdinteg:si_catciudades a INNER JOIN tmp_Catciudadescrd b ON a.numerociudad = b.numerociudad AND a.numeroestado = b.numeroestado into temp Catciudadescrd with no log; 
	create index ix_ciudadescrd on Catciudadescrd (numerociudad) ;
    UPDATE STATISTICS medium FOR TABLE Catciudadescrd;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Carga  Direcciones CRD y sit esp 2', '02') RETURNING vvcCod_ret;

    -- Carga informacion de direcciones de Clientes.
    SELECT dir.numcte,              dir.tipo_dir,           dir.numeroextcalle,
           replace(dir.numerointcalle, '|','') numerointcalle,  dir.manzana,  dir.otros,
           dir.andador,             dir.etapa,              dir.lote,
           dir.edificio,            dir.entrada,            dir.departamento,
           dir.cod_postal,          dir.puntocardinal,      dir.observaciones,
           dir.entre_calles,        dir.numerociudad,      /* dir.extension,*/
           dir.numerocolonia,       dir.numerocalle,        dir.estado
    FROM bdinteg:si_direcciones_actual dir
    JOIN CarteraLinea_crd cart ON (dir.numcte = cart.numcte)
    INTO temp direc_paso_pp_res WITH NO LOG;
    /*WHERE numcte IN ( select numcte from CarteraLinea_crd )
           (SELECT numcte
                FROM bdicred:sd_sdos_cartera_linea cart
                where cart.num_credito NOT IN (select num_credito from sd_paso_credacrd_tab) --CAS NO SE IMPRIMEN EDOCOBRANZA SI PRESENTAN SITUACION ESPECIAL
                AND cart.num_producto IN ('6300', '6011','6400')
                AND cart.status_cred in ('BA','BT','VP') 
                --AND cart.sdo_cap_insoluto >= (Select (valor+0) From bdinteg:si_param where empresa = vempresa and cod_param = '109')
                AND cart.sdo_cap_insoluto >= vmontodeudaabogmin
                AND cart.mto_fin_ven_trasp between vmensualidades_min and vmensualidades_max) */
    create index inx_direc_paso_pp_res on direc_paso_pp_res(numcte, tipo_dir);
    update statistics medium for table direc_paso_pp_res;

    -- Carga informacion de situaciones especiales (situacion, causa)
     SELECT sitcrd.numcte, situacion, causa 
       FROM bdisitesp:se_ctessitespcte sitcrd
       JOIN CarteraLinea_crd cart ON (cart.numcte = sitcrd.numcte)
       INTO temp sitctecrd WITH NO LOG;
     CREATE INDEX inx_sitctecrd ON sitctecrd ( numcte );
     UPDATE STATISTICS MEDIUM FOR TABLE sitctecrd; 


    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Carga  ss_resum_scor_fin CRD e ingresos', '02') RETURNING vvcCod_ret;

     -- Carga informacion de ss_resum_scor_fin ( para obtener salario minimo)
     SELECT num_solicitud, NVL(ingreso_mensual,0) / salariominban SalarioMinimo
       FROM bdisolic:ss_resum_scor_fin resum
       JOIN CarteraLinea_crd cart ON (cart.num_credito = resum.num_solicitud)
      WHERE empresa = vempresa
       INTO temp temp_resumcrd with no log;
     CREATE UNIQUE INDEX inx_resum_crd ON temp_resumcrd ( num_solicitud );
     UPDATE STATISTICS MEDIUM FOR TABLE temp_resumcrd;

     -- Carga informacion de ingresos
    SELECT ing.numcte, ing.nombre_empresa
        FROM bdinteg:si_ingresos ing
        JOIN CarteraLinea_crd cart ON (ing.numcte = cart.numcte )
        WHERE ing.sec_ingreso =(select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 where ing1.numcte= cart.numcte and ing1.tipo_ingreso= 'T')
          AND ing.tipo_ingreso = 'T'
        INTO temp ingresoscrd WITH NO LOG;
     CREATE INDEX inx_ingresoscrd on ingresoscrd( numcte );
     UPDATE STATISTICS MEDIUM FOR TABLE ingresoscrd;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Carga  sd_movhiscrd, cb_compac', '02') RETURNING vvcCod_ret;

    -- Carga sd_conceptospagomanualcrd
    SELECT codigo FROM bdicred:sd_conceptospagomanualcrd INTO temp conceptospagomanualcrd1 WITH NO LOG;
	SELECT cod_fun FROM bdicred:sd_conceptospagomanualcrd a INNER JOIN conceptospagomanualcrd1 b ON a.codigo = b.codigo INTO temp tmp_conceptospagomanualcrd WITH NO LOG;

    -- Carga cb_compac
    SELECT empresa, numcliente, numcuenta, plazo, importe, fecha_compac, keyx 
      FROM bdicobranza:cb_compac compc
      JOIN CarteraLinea_crd cart ON (compc.empresa = vempresa AND compc.numcliente = cart.numcte)
    INTO temp tmp_compac WITH NO LOG;
    CREATE INDEX inx1_compac ON tmp_compac (empresa, numcliente, numcuenta);
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_compac;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Carga telefonos crd', '02') RETURNING vvcCod_ret;
    SELECT tel.* FROM bdinteg:si_telefonos_actual tel
        JOIN CarteraLinea_crd cart ON (tel.numcte = cart.numcte)
        INTO temp telefonoscrd WITH NO LOG;
    CREATE INDEX inx_telcrd ON telefonoscrd (numcte, tipo_tel, status_tel, cofetel);
    UPDATE STATISTICS MEDIUM FOR TABLE telefonoscrd;


    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Inicia foreach CRD ', '02') RETURNING vvcCod_ret;

    FOREACH WITH HOLD
        SELECT nvl(vempresa,' '), nvl(cart.num_credito,''), nvl(cart.numcte,' '), nvl(cart.sdo_cap_insoluto,0), 
            nvl(cart.mto_venc_trasp + cart.monto_vencido,0), nvl(cart.fecha_ult_pago,date(1)), nvl(cart.monto_financiado,0), 
            nvl(cart.num_producto, ''), nvl(cart.num_cta, ''), 
            nvl(cart.saldovencido1,0), nvl(cart.saldovencido2,0), nvl(cart.saldovencido3,0), nvl(cart.saldovencido4,0), nvl(cart.saldovencido5,0), 
            nvl(cart.saldovencido6,0), nvl(cart.interesmoratorio1,0), nvl(cart.interesmoratorio2,0), nvl(cart.interesmoratorio3,0), 
            nvl(cart.interesmoratorio4,0), nvl(cart.interesmoratorio5,0), nvl(cart.interesmoratorio6,0), 
            nvl(cart.interes_iva,0), nvl(cart.mto_fin_ven_trasp::INTEGER,0),
            lpad(TRIM(cte.sucursal),4,'0') AS sucursal, rpad(TRIM(cte.nombre1),20,' ') AS nombre1,
            rpad(TRIM(cte.nombre2),20,' ') AS nombre2, rpad(TRIM(cte.apell_paterno),20,' ') AS apellpaterno,
            rpad(TRIM(cte.apell_materno),20,' ') AS apellmaterno, rpad(TRIM(ctepf.estado_civil),2,' ') AS edo_civil,
            TRIM(decode(ctepf.habita_en,'01','P','02','R','03','F','04','G','05','H',ctepf.habita_en)) AS tipo_casa,
            rpad(TRIM(ctepf.sexo),1,' ') AS sexo, lpad(year(cte.fecha_alta),4,'0') AS ayoalta, 
            lpad(year(ctepf.fecha_nac),4,'0') AS ayonac, cte.rfc, --nvl(cte.numcte_ref,'0')    -- lugar de trabajo
            nvl(case when bdinteg:val_num(cte.numcte_ref) then cte.numcte_ref else '0' end,'0')
            INTO cEmpresa, cNumCredito, cNumCliente, mSaldoActual, mSaldoVencido, dFechaUltimoPago, cpagominimo, cnum_producto, cnum_cta,
                cSaldovencido1, cSaldovencido2, cSaldovencido3, cSaldovencido4, cSaldovencido5, cSaldovencido6, 
                cInteresmoratorio1, cInteresmoratorio2, cInteresmoratorio3, cInteresmoratorio4, cInteresmoratorio5, cInteresmoratorio6, 
                cInteresV, sAbonosVdos, cSucursal, cNombre1, cNombre2, cApellido1, cApellido2, cEstadoCivil, cTipoCasa, cSexo, 
                cAnioAlta, cAnioNacimiento, vRFC, cNumcte_ref 
            FROM CarteraLinea_crd cart, -- bdicred:sd_sdos_cartera_linea cart, 
                 bdinteg:si_cliente cte, 
                 bdinteg:si_ctepf ctepf
            WHERE cart.numcte = cte.numcte
              AND cart.numcte = ctepf.numcte
            --cart.num_credito NOT IN (select num_credito from sd_paso_credacrd_tab) --CAS NO SE IMPRIMEN EDOCOBRANZA SI PRESENTAN SITUACION ESPECIAL
            -- AND cart.num_producto IN ('6300', '6011','6400')
            --AND cart.status_cred in ('BA','BT','VP') AND
            --AND cart.sdo_cap_insoluto >= vmontodeudaabogmin
            --AND cart.mto_fin_ven_trasp between vmensualidades_min and vmensualidades_max

        IF vTotalCommit=0 THEN begin work; END IF;

        /*SELECT NVL(ingreso_mensual,0) / salariominban INTO cSalarioMinimoaux
             FROM bdisolic:ss_resum_scor_fin WHERE empresa = cEmpresa AND num_solicitud = cNumCredito;*/
        SELECT limit 1 SalarioMinimo INTO cSalarioMinimoaux
          FROM temp_resumcrd WHERE num_solicitud = cNumCredito; 
        IF cSalarioMinimoaux >= 22 THEN
            LET cSalarioMinimo = LPAD(22,2,'0');
        ELSE
           LET cSalarioMinimo = LPAD(cSalarioMinimoaux::INTEGER::VARCHAR(2),2,'0');
        END IF;


        SELECT limit 1
        rpad(TRIM(calle.nombrecalle),30,' ') AS calle,      -- nombre de calle
        TRIM(dir.numeroextcalle) AS numextcalle,   -- numero exterior -- se modifica para quitar el formato
        TRIM(dir.numerointcalle) AS numintecalle,  -- numero interior -- Se modifica para quitar el formato
        rpad(TRIM(zon.nombrezona),30,' ') AS colonia,   -- colonia
        lpad(dir.manzana,5,'0') AS manzana,     -- manzana
        lpad(dir.otros,5,'0') AS otros,     -- otros
        lpad(dir.andador,5,'0') AS andador,     -- andador
        lpad(dir.etapa,5,'0') AS etapa,     --etapa
        lpad(dir.lote,5,'0') AS lote,       -- lote
        lpad(dir.edificio,5,'0') AS edificio,   --edificio
        lpad(dir.entrada,5,'0') AS entrada,   -- entrada
        rpad(TRIM(dir.departamento),6,' ') AS departamento,     -- departamento
        lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal,     -- codigo postal
        rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal,   -- punto cardinal
        rpad(TRIM(dir.observaciones),80,' ') AS complemento,  --   complemento
        rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles,    -- entre calles
        rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,    -- delegacion / municipio
        rpad(TRIM(edo.nombre),25,' ') AS estado,    -- estado
        case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
             then lpad(dir.numerociudad,4,'0') else lpad(zon.numerociudadcoppel,4,'0') end numciudad,  -- numero ciudad cliente
        lpad(zon.centro,6,'0') AS numcentro, -- numero de centro
        lpad(zon.jefegrupozona,8,'0') AS numjefe, -- numero de jefe
        lpad(zon.supervisorzona,8,'0') AS numsupervisor, -- numero de supervisor
        case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
             then lpad(dir.numerocolonia,4,'0') else lpad(zon.numerocoloniacoppel,4,'0') end numcolonia,  -- numero de colonia de cliente
        lpad(dir.numerocalle,6,'0') AS numcalle --, -- numero de calle de cliente
        --nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo  -- lugar de trabajo
        --cte.rfc, nvl(cte.numcte_ref,'0')
        Into cNombreCalle, cNumExterior, cNumInterio, cColonia,
        cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento,
        cEntreCalles, cDelegacionMunicipio, cEstado, cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor,
        cNumColoniacte, cNumCalleCte--, cLugarTrabajo
        FROM direc_paso_pp_res dir
        LEFT OUTER JOIN CatCallescrd calle ON (dir.numerocalle = calle.numerocalle)
        LEFT OUTER JOIN CatZonascrd zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
        LEFT OUTER JOIN Catciudadescrd ciudad ON (ciudad.numerociudad = dir.numerociudad)
        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
        --LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.numcte= dir.numcte AND ing.tipo_ingreso = 'T' and ing.sec_ingreso= (select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 
        --                                                                                                                     where ing1.numcte= dir.numcte and ing1.tipo_ingreso= 'T'))
        WHERE dir.numcte = cNumCliente
        and dir.tipo_dir = '1';

        -- Salta al siguiente registro si no existe domicilio de este registro ( si num calle es nula). 
        IF cNumCalleCte IS NULL THEN LET vTotalCommit=vTotalCommit+1; CONTINUE FOREACH; END IF; 

        SELECT limit 1 nvl(rpad(TRIM(nombre_empresa),25,' '),' ') AS lugartrabajo INTO cLugarTrabajo
            FROM ingresoscrd WHERE numcte = cNumCliente;

                        -- Obtienen los telefonos de la tabla: si_telefonos_actual 
        SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' ')
            INTO cTelefonoCasa FROM telefonoscrd WHERE numcte = cNumCliente AND tipo_tel = 1 AND status_tel = 'A' 
            AND cofetel = 'V' AND trim(telefono) <> '' ;
 
        SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' ')
            INTO cCelular FROM telefonoscrd WHERE numcte = cNumCliente AND tipo_tel = 2 AND status_tel = 'A' 
            AND cofetel = 'V' AND trim(telefono) <> '';

        SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' '),
            nvl(extension, '')  INTO cTelefonoTrabajo, cExtensionTrabajo FROM telefonoscrd WHERE numcte = cNumCliente AND tipo_tel = 3 
            AND status_tel = 'A' AND cofetel = 'V' AND trim(telefono) <> '';
        IF cTelefonoTrabajo IS NULL THEN
            SELECT limit 1 rpad(TRIM( nvl(case when val_num(telefono) then replace(replace(replace(telefono,'.',''),'-',''),',','') else '' end,'') ),13,' '),
                nvl(extension, '') INTO cTelefonoTrabajo, cExtensionTrabajo FROM telefonoscrd WHERE numcte = cNumCliente AND tipo_tel = 4 
                AND status_tel = 'A' AND cofetel = 'V' AND trim(telefono) <> '';
        END IF;

        IF (TRIM(cNumcte_ref) = '' OR cNumcte_ref IS NULL)  THEN LET cNumcte_ref = '0'; END IF

        SELECT limit 1
        rpad(TRIM(calle.nombrecalle),30,' ') AS calle,      -- nombre de calle
        TRIM(dir.numeroextcalle) AS numextcalle,   -- numero exterior -- se modifica para quitar el formato
        TRIM(dir.numerointcalle) AS numintecalle,  -- numero interior -- Se modifica para quitar el formato
        rpad(TRIM(zon.nombrezona),30,' ') AS colonia,   -- colonia
        lpad(dir.manzana,5,'0') AS manzana,     -- manzana
        lpad(dir.otros,5,'0') AS otros,     -- otros
        lpad(dir.andador,5,'0') AS andador,     -- andador
        lpad(dir.etapa,5,'0') AS etapa,     --etapa
        lpad(dir.lote,5,'0') AS lote,       -- lote
        lpad(dir.edificio,5,'0') AS edificio,   --edificio
        lpad(dir.entrada,5,'0') AS entrada,   -- entrada
        rpad(TRIM(dir.departamento),6,' ') AS departamento,     -- departamento
        lpad(TRIM(REPLACE(REPLACE(dir.cod_postal,'S-CP','00000'),'S-CP4','00000')),5,'0') AS cod_postal,     -- codigo postal
        rpad(TRIM(dir.puntocardinal),1,' ') AS puntocardinal,   -- punto cardinal
        rpad(TRIM(dir.observaciones),80,' ') AS complemento,  --   complemento
        rpad(TRIM(dir.entre_calles),40,' ') AS entre_calles,    -- entre calles
        rpad(TRIM(ciudad.nombreciudad),25,' ') AS municipio,    -- delegacion / municipio
        rpad(TRIM(edo.nombre),25,' ') AS estado,    -- estado
        case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
             then lpad(dir.numerociudad,4,'0') else lpad(zon.numerociudadcoppel,4,'0') end numciudad,  -- numero ciudad cliente
        case when (zon.numerociudadcoppel is null or zon.numerociudadcoppel = '' or zon.numerociudadcoppel = 0)
             then lpad(dir.numerocolonia,4,'0') else lpad(zon.numerocoloniacoppel,4,'0') end numcolonia  -- numero de colonia de cliente
        Into cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t, 
        cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
        cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t, cDelegacionMunicipio_t, cEstado_t,
        cNumCiudadCte_t, cNumColoniacte_t
        FROM direc_paso_pp_res  dir
        LEFT OUTER JOIN CatCallescrd calle ON (dir.numerocalle = calle.numerocalle)
        LEFT OUTER JOIN CatZonascrd zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
        LEFT OUTER JOIN Catciudadescrd ciudad ON (ciudad.numerociudad = dir.numerociudad)
        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
        Where dir.numcte = cNumCliente
        and dir.tipo_dir = '2';

        /*Select iva Into mIvaSucursal 
          From bdinteg:si_sucursales 
         Where sucursal = cSucursal;*/

        IF sAbonosVdos=1 THEN   LET cTipodecliente='1'; LET sNumAvisos='1';
        ELIF sAbonosVdos=2 THEN LET cTipodecliente='1'; LET sNumAvisos='2';
        ELIF sAbonosVdos=3 THEN LET cTipodecliente='2'; LET sNumAvisos='3';
        ELIF sAbonosVdos=4 THEN LET cTipodecliente='3'; LET sNumAvisos='3';
        ELIF sAbonosVdos=5 THEN LET cTipodecliente='4'; LET sNumAvisos='4';
        ELIF sAbonosVdos>=6 THEN 
            IF sAbonosVdos>6 THEN LET cTipodecliente='5'; ELSE LET cTipodecliente='4';  END IF;
            LET sNumAvisos='V';
        END IF;

        LET mSaldoContabMora = cInteresmoratorio1 + cInteresmoratorio2 + cInteresmoratorio3 + cInteresmoratorio4 + cInteresmoratorio5 + cInteresmoratorio6;
        LET mSaldoVencido = mSaldoVencido + cInteresV; 
        LET mSaldoActual = mSaldoActual + cInteresV;
        LET cpagominimo = cpagominimo + cInteresV;
        LET cImpteUltimocompromiso = 0; 
        LET dFechaUltimocompac = date(1);
        LET dFechaCumpliocompromiso = date(1); 
        LET cCumplioCompromiso = " ";   
        LET  cPlazoCompromiso = " ";    
        LET  cImpteCompromisocumplido = " "; 
        LET vlMontoUltimoPago = ""; 
        --LET vlMontoUltimoPago = "";

        SELECT limit 1 LPAD(round(importe),5,"0")importe,fecha_compac,
                CASE WHEN dFechaUltimoPago BETWEEN fecha_compac AND DATE((fecha_compac::date)+((plazo::integer)*7) units day) AND dFechaUltimoPago IS NOT NULL
                THEN (case when importe>=(SELECT sum(monto)/2 
                                          FROM bdicred:sd_movhiscrd --FROM bdicred:sd_movhiscrd
                                          WHERE empresa=cEmpresa
                                          AND fecha_mov=dFechaUltimoPago
                                          AND num_credito=numcuenta
                                          AND codigo_fun in (select cod_fun from tmp_conceptospagomanualcrd ) --bdicred:sd_conceptospagomanualcrd
                                          AND codigo_ref=1
                                          AND reversado='N') then 'S' 
                      ELSE CASE WHEN vfecha_hoy BETWEEN fecha_compac AND DATE((fecha_compac::date)+((plazo::integer)*7) units day) THEN 'P'
                           ELSE 'N' END END)
                  ELSE CASE WHEN vfecha_hoy BETWEEN fecha_compac AND DATE((fecha_compac::date)+((plazo::integer)*7) units day) THEN 'P'
                       ELSE 'N' END END,plazo
        INTO cImpteUltimocompromiso,dFechaUltimocompac,cCumplioCompromiso,cPlazoCompromiso
	    FROM tmp_compac -- bdicobranza:cb_compac
	    WHERE empresa =cEmpresa
	    AND numcliente=cNumCliente
	    AND numcuenta = cNumCredito
        and keyx=(select max(keyx) 
                  from tmp_compac -- bdicobranza:cb_compac 
                  WHERE empresa =cEmpresa
                  AND numcliente=cNumCliente
                  AND numcuenta = cNumCredito);
      
        SELECT LPAD(round(sum(monto)),5,"0")
            INTO vlMontoUltimoPago
            FROM bdicred:sd_movhiscrd -- bdicred:sd_movhiscrd 
            WHERE empresa=cEmpresa
            AND fecha_mov=dFechaUltimoPago
            AND num_credito=cNumCredito 
            AND codigo_fun in (select cod_fun from tmp_conceptospagomanualcrd) --bdicred:sd_conceptospagomanualcrd)
            AND codigo_ref=1
            AND reversado='N';             

        /*  SELECT monto_ult_convenio, fecha_ult_convenio, cumplio_convenio, '1', monto_ultimo_pago 
            INTO cImpteUltimocompromiso, dFechaUltimocompac,cCumplioCompromiso,cPlazoCompromiso, vlMontoUltimoPago
            FROM bdicred:sd_indicador_cred WHERE num_credito = cNumCredito; --Quitar comentario para cuando sd_indicador_cred ya almacene
                                                                            datos de Prestamo y Reestructura (sustituye dos ultimos querys)             */

        IF cCumplioCompromiso='S' THEN
            LET cImpteCompromisocumplido = vlMontoUltimoPago; 
            LET dFechaCumpliocompromiso=dFechaUltimoPago;
        END IF;
        IF cImpteUltimocompromiso IS NULL OR cImpteUltimocompromiso=" " THEN LET cImpteUltimocompromiso='00000'; END IF;
        IF cCumplioCompromiso IS NULL OR cCumplioCompromiso=" " THEN LET cCumplioCompromiso='-'; END IF;
        LET cSituacionEspecial="";         LET cCausasituacionespecial=0;

       /* SELECT situacion,causa INTO cSituacionEspecial,cCausasituacionespecial
            FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumCliente;*/

        SELECT FIRST 1 situacion,causa 
          INTO cSituacionEspecial,cCausasituacionespecial
          FROM sitctecrd
         WHERE numcte = cNumCliente;
        
        IF cSituacionEspecial IS NULL or cSituacionEspecial="" THEN LET cSituacionEspecial="-"; END IF;
        IF cCausasituacionespecial IS NULL THEN LET cCausasituacionespecial=0; END IF;
        --if (mIvaSucursal is null)then let mIvaSucursal = 0;  end if;
        if (mSaldoContabMora < 0 or mSaldoContabMora is null) then let mSaldoContabMora = 0; end if;       
        LET mSaldoContabMoraTotal = mSaldoContabMora;
        LET mSaldoTotalAcumulado   = mSaldoTotalAcumulado   + mSaldoActual;
        LET mSaldoVencidoAcumulado = mSaldoVencidoAcumulado + mSaldoVencido;
        LET mSaldoMoratorioAcumulado = mSaldoMoratorioAcumulado  + mSaldoContabMoraTotal;
        IF dFechaUltimoPago IS NULL THEN LET dFechaUltimoPago=DATE(1); END IF;      
        LET cDiaUltimoPago    = lpad(day  (dFechaUltimoPago),2,"0");
        LET cMesUltimoPago    = lpad(month(dFechaUltimoPago),2,"0");
        LET cAnioUltimoPago   = lpad(year (dFechaUltimoPago),4,"0");
        IF dFechaUltimocompac IS NULL THEN LET dFechaUltimocompac=DATE(1); END IF;
        LET cDiaUltimoCompac  = lpad(day  (dFechaUltimocompac),2,"0");
        LET cMesUltimoCompac  = lpad(month(dFechaUltimocompac),2,"0");
        LET cAnioUltimoCompac = lpad(year (dFechaUltimocompac),4,"0");

        Select limit 1 nombre_ref, telefono_ref into cNombreRef, cTelefonoRef
            From bdisolic:ss_refpersonales
            Where empresa = cEmpresa And numcte= cNumCliente
            And nombre_ref is not null;

        -- Determina la clave para el tipo de cliente a identificar en la clabe de cobranza. Obtiene si es su primer vencido.
        SELECT anex.fecha_vencto, ind.fecha_vencido INTO dfh1erVenc, dfhUltVenc
          FROM bdicred:sd_maecredanexocrd anex, bdicred:sd_indicador_cred_crd ind
         WHERE anex.num_credito = ind.num_credito AND anex.num_credito = cNumCredito;

        --- 1er vencido     Y ultimo vencido es = su primer vencido 
        IF sAbonosVdos = 1 AND dfh1erVenc = dfhUltVenc THEN -- AND dfhAlta >= dFHoy_13m AND dfhAlta <= pdFecha_hoy
            LET vTpoVdoCte = 1; 
        ELIF sAbonosVdos <= 3 THEN 
            LET vTpoVdoCte = 2;
        --ELIF sAbonosVdos > 3 THEN LET vTpoVdoCte = 3; END IF;
        ELSE
            LET vTpoVdoCte = 3; 
        END IF;

        Insert into bdinteg:si_cteestadocuenta(
        --Insert into bdinteg:si_cteestadocta_sdo_cart(
            empresa,sucursal,numcte ,nombre1,nombre2,apellido1,apellido2,calle,numeroextcalle ,numerointcalle ,colonia,
            manzana,otros,andador,etapa,lote,edificio,entrada,departamento,cod_postal ,puntocardinal,complemento,
            entre_calles,delegacion_municipio,estado ,telefono_casa,telefono_trabajo,extension_trabajo,celular,
            lugar_trabajo,nombrecalletrabajo ,numeroexteriortrabajo,numerointeriortrabajo,coloniatrabajo ,manzanatrabajo ,
            otrostrabajo,andadortrabajo ,etapatrabajo,lotetrabajo,edificiotrabajo,entradatrabajo ,departamentotrabajo,
            codigopostaltrabajo,puntocardinaltrabajo,complementotrabajo ,entrecallestrabajo,delegacion_municipiotrabajo,
            estadotrabajo,numerociudadtrabajo,numerocoloniatrabajo,numero_credito ,num_tarjeta_credito,situacioespecial,estado_civil,
            tipo_casa,sexo,salarios_minimos,anio_alta,anio_nacimiento,saldo_actual,saldo_vencido,saldo_moratorio,pagominimo ,fecha_ultimoabono,
            impte_ultimocompromiso ,fecha_ultimocompac ,plazo_compromiso,impte_compromisocumplido,fecha_cumpliocompromiso,cumplio_convenio,num_ciudadcte,
            num_centro ,num_jefe,num_supervisor ,num_coloniacte ,num_callecte,num_casacte,pago_vencido,fecha_diaultimopago,
            fecha_mesultimopago,fecha_anioultimopago,fecha_diaultimoacuerdo ,fecha_mesultimoacuerdo ,fecha_anioultimoacuerdo,
            tipodecliente,causasituacionespecial ,abonos_vdos,num_avisos ,nom_ref,nom_calle_ref,num_ext_ref,num_int_ref,col_ref,
            manzana_ref,otros_ref,andador_ref,etapa_ref,lote_ref,edificio_ref,entrada_ref,depto_ref,cp_ref ,punto_cardinal_ref ,
            complemento_ref,entre_calles_ref,delegacion_municipio_ref,estado_ref ,telefono_ref,num_ciudad_ref ,
            num_coloniaref ,nom_conyugeofamiliar,tel_conyugeofamiliar,saldovencido1,saldovencido2,saldovencido3,saldovencido4,
            saldovencido5,saldovencido6,interesmoratorio1,interesmoratorio2,interesmoratorio3,interesmoratorio4,interesmoratorio5,
            interesmoratorio6,fecha_movto, num_producto, num_cta,imp_ult_abono, rfc, tipo_dir, numcte_ref, tipovencido )  --llevan tipo_dir 1 por default
        Values (vempresa,cSucursal,cNumCliente,cNombre1,cNombre2,cApellido1,cApellido2,cNombreCalle,cNumExterior,cNumInterio,cColonia,
            cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento,        
            cEntreCalles,cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,
            cLugarTrabajo,cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t, 
            cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
            cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t,cDelegacionMunicipio_t,
            cEstado_t,cNumCiudadCte_t, cNumColoniacte_t,cNumCredito,'',cSituacionEspecial,cEstadoCivil, 
            cTipoCasa, cSexo,cSalarioMinimo,cAnioAlta, cAnioNacimiento,mSaldoActual,mSaldoVencido,mSaldoContabMoraTotal,cpagominimo,dFechaUltimoPago,
            cImpteUltimocompromiso, dFechaUltimocompac, cPlazoCompromiso, cImpteCompromisocumplido, dFechaCumpliocompromiso,cCumplioCompromiso,cNumCiudadCte,
            cNumCentro, cNumJefe, cNumSupervisor,cNumColoniacte, cNumCalleCte, cNumExterior,mSaldoVencido, cDiaUltimoPago,
            cMesUltimoPago, cAnioUltimoPago,cDiaUltimoCompac, cMesUltimoCompac, cAnioUltimoCompac,
            cTipodecliente,cCausasituacionespecial,sAbonosVdos, sNumAvisos, cNombreRef, cNomCalleRef, cNumExtRef, cNumIntRef, cColRef, 
            cManzanaRef, cOtrosRef, cAndadorRef,cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef, cCpRef, cPuntoCardinalRef,
            cComplementoRef, cEntreCallesRef,cDelegacionMunicipioRef, cEstadoRef,cTelefonoRef, cNumCiudadRef,
            cNumColoniaRef, cNomConyugeoFamiliar, cTelConyugeoFamiliar,cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4,
            cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2,cInteresmoratorio3,cInteresmoratorio4,cInteresmoratorio5,
            cInteresmoratorio6, vfecha_hoy, cnum_producto, cnum_cta,vlMontoUltimoPago, vRFC, '1', cNumcte_ref, vTpoVdoCte ); --llevan tipo_dir 1 por default

        LET vTotalRegistros = vTotalRegistros +1;
        LET vTotalCommit=vTotalCommit+1;
        IF vTotalCommit=10000 THEN
            COMMIT WORK;
            LET vTotalCommit=0;
        END IF;

        LET sAbonosVdos=0; LET cSaldovencido1=0; LET cSaldovencido2=0; LET cSaldovencido3=0; LET cSaldovencido4=0;
        LET cSaldovencido5=0; LET cSaldovencido6=0; LET cInteresmoratorio2=0; LET cInteresmoratorio3=0;
        LET cInteresmoratorio4=0; LET cInteresmoratorio5=0;  LET cInteresmoratorio6=0; LET cInteresV=0; LET cproyecmora=0;

    END FOREACH;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, P_COD_RET, 'Termina foreach CRD ', '02') RETURNING vvcCod_ret;

    IF vTotalCommit>0 THEN
       COMMIT WORK;
       update statistics medium for table bdinteg:si_cteestadocuenta;
    END IF; 
    --Insert into si_cifracontrolabogado(empresa, numero_registros, saldo_total, saldo_vencido, saldo_moratorio, fecha_movto) 
    -- values('001', vTotalRegistros, mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado , vfecha_hoy);
		-- No se inserta registro, se regresan cantidades al proceso principal, para insertar un solo registro a si_cifracontrolabogado.

    LET vvccod_ret = '';
    IF P_COD_RET = "000000" THEN
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso,'', '','03' )
        RETURNING vvccod_ret;
    END IF;
    
    RETURN P_COD_RET, nvl(vTotalRegistros,0), nvl(mSaldoTotalAcumulado,0), nvl(mSaldoVencidoAcumulado,0), nvl(mSaldoMoratorioAcumulado,0);

END;
END PROCEDURE
DOCUMENT
'AUTOR      : MACF',
'DESCRIPCION: Modificaciones para el IFRS, BD(bdinteg)',
'FECHA      : 2022/01/07';

CREATE PROCEDURE "informix".sp_agregarbitacora_bpi(
pFechaOper datetime year to second,
pNumTrans char(4),
pNumSuc char(4),
pIdUsuario integer,
pIpUsuario char(15),
pFechaApli date,
pCtaOrigen char(12),
pCtaDesti char(20),  --CAMBIA
pMonto money,
pSecTrans char(16),
pCgen1 char(100),  --CAMBIA
pCgen2 char(200),  --CAMBIA
pCgen3 char(60),  --CAMBIA
pCgen4 char(60),  --CAMBIA
pCgen5 char(60),  --NUEVO
pCgen6 char(100),  --NUEVO
pCgen7 char(60), --NUEVO SPEI
pCgen8 char(60), -- NUEVO SPEI
pReferencia char(100),  --NUEVO
pFolio char(16),
tipo_token char(1),  --NUEVO
pLatitud char(100), --NUEVO
pLongitud char(100), --NUEVO
pVersion char(10) --NUEVO
)
 returning char(5);

    -- Realizo   : Javier Alonso ChÃ?Ã¥Ãvez Trujillo
    -- Actividad : Agrega Bitacora
    -- SolicitÃ?Ã¥?  : Mauricio Leon
    -- Fecha     : 25/11/2008
        --//////////////////////////////////////////
        -- Realizo   : Walber Castro
        -- Actividad : se modifica el tipo de dato del parametro de entrada Monto ya que redondeaba las cifras grandes.
        -- SolicitÃ?Ã¥?  : Mauricio Leon
        -- Fecha     : 23/08/2010
        -- ////////////////////////////////////////
        -- Bibiana Gaxiola Verdugo
        -- Se agrega la actualizaciÃ?Ã¥?n del movimiento en la tabla de cuentas frecuentes para la caducidad de las mismas.
        -- 21/01/2013
        -- ING. ALFONSO CRUZ
        -- Modificacion en la bitacora en la que se agregaron parametros a la misma.
        -- 08/07/2013
        -- ////////////////////////////////////////
        -- Realizo       : L.I. Manuel Ramos Figueroa
        -- Actividad : Se aumento a 100 el tamaÃ?Ã¥Â±o del parametro pCgen6
        -- SolicitÃ?Ã¥?  : Bibiana Gaxiola Verdugo
        -- Fecha         : 16/01/2014
        --//////////////////////////////////////////
        -- Realizo       : L.I. Manuel Ramos Figueroa
        -- Actividad : Se aumento a 200 el tamaÃ?Ã¥Â±o del parametro pCgen2
        -- SolicitÃ?Ã¥?  : Bibiana Gaxiola Verdugo
        -- Fecha         : 06/02/2014
        --//////////////////////////////////////////
        -- Realizo       : Solser
        -- Actividad : Se agregÃ? tipo_token como parÃÃmetro de entrada y nuevo parÃÃmetro de tabla bpi_bitacora
        -- Solicita  : Gabriela Aguilar
        -- Fecha         : 07/01/2021
    --//////////////////////////////////////////
        -- Realizo       : Solser
        -- Actividad : Se agregan parï¿½metros de latitud, longitud y versiï¿½n, para RQM Geolocaliczaciï¿½n y se guardan en nueva tabla ""
        -- Solicita  : Gabriela Aguilar
        -- Fecha         : 29/03/2021
        --//////////////////////////////////////////
        -- Realizo       : Ricardo Ravago Acosta
        -- Actividad : Se agregan parametros pCgen7 y pCgen8 y se guardan en nueva tabla
        -- SolicitÃ?Ã¥?  : Bibiana Gaxiola Verdugo
        -- Fecha         : 17/02/2026
 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;
DEFINE vCtasFrec CHAR(1);
DEFINE vNumCte CHAR(10);
DEFINE vCveCaducidad CHAR(1);
DEFINE vClaveBanco CHAR(60);

--INICIALIZA VARIABLES
LET cod_ret  = "000";
LET vClaveBanco = pCgen4;

--SET DEBUG FILE TO "/informix/gaby/INC-Activacion_bitacoraTKNPass/sp_agregarbitacora_bpi.out";
--TRACE ON;

BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;


        IF(pNumTrans IN ('1011','1015','2015','2100') ) THEN
                SELECT FIRST 1 vchrnombrecorto
                INTO pCgen4
                FROM BDINTEG:"informix".si_bancos
                WHERE banco = TRIM(vClaveBanco);
        END IF;

        INSERT INTO bdibpi:"informix".bpi_bitacora(fecha_oper,
                             id_operacion,
                             sucursal,
                             id_usuario,
                             ipusuario,
                             fecha_aplic,
                             cuenta_origen,
                             destino,
                             monto_oper,
                             sec_transaccion,
                             cgenerico1,
                             cgenerico2,
                             cgenerico3,
                             cgenerico4,
                                 cgenerico5,
                                 cgenerico6,
                                 cgenerico7,
                                 cgenerico8,
                                 referencia,
                                 folio,
                                 tipo_token,    
                                 latitud,
                                 longitud,
                                 version) VALUES (pFechaOper,
                                                  pNumTrans,
                                                  pNumSuc,
                                                  pIdUsuario,
                                                  pIpUsuario,
                                                  pFechaApli,
                                                  pCtaOrigen,
                                                  pCtaDesti,
                                                  pMonto,
                                                  pSecTrans,
                                                  pCgen1,
                                                  pCgen2,
                                                  pCgen3,
                                                  pCgen4,
                                                  pCgen5,
                                                  pCgen6,
                                                  pCgen7,
                                                  pCgen8,
                                                  pReferencia,
                                                  pFolio,
						  tipo_token,
                                                  pLatitud,
                                                  pLongitud,
                                                  pVersion);
                IF (pLatitud <> '' AND pLongitud <> '' AND pVersion <> '' AND pNumTrans IN('1008', '1011', '1015', '1016', '1017', '1020', '1021','1022', '1023', '1024', '1025', '1026', '1027', '1033', '1034', '1041', '1050', '1070', '2020', '2021', '2027', '2100')) THEN
                        INSERT INTO bdibpi:"informix".bpi_geolocalizacion(id_operacion,
                                                fecha_oper,
                                                folio,
                                                cuenta_origen,
                                                destino,
                                                ipusuario,
                                                latitud,
                                                longitud,
                                                version) VALUES(pNumTrans,
                                                                pFechaOper,
                                                                pFolio,
                                                                pCtaOrigen,
                                                                pCtaDesti,
                                                                pIpUsuario,
                                                                pLatitud,
                                                                pLongitud,
                                                                pVersion);
                END IF;

                SELECT ctas_frec INTO vCtasFrec FROM bdibpi:"informix".bpi_cat_operaciones WHERE id_oper = pNumTrans;

                IF (vCtasFrec = '1') THEN --- Significa que son operaciones que involucran cuentas frecuentes

                        SELECT numcliente INTO vNumCte FROM bdibpi:"informix".bpi_usuario WHERE id_usuario = pIdUsuario AND st_portal = 'activo';

                        SELECT cve_caducidad INTO vCveCaducidad FROM bdiprog:"informix".pp_ctasterceros WHERE cuenta = pCtaDesti AND num_cte = vNumCte;

                        IF (vCveCaducidad = '3') THEN
                                UPDATE bdiprog:"informix".pp_ctasterceros SET fecha_movtos = today WHERE cuenta = pCtaDesti AND num_ctE = vNumCte;
                                RETURN cod_ret;
                        ELSE
                                RETURN cod_ret;
                        END IF;

                END IF;

        RETURN cod_ret;
END;
END PROCEDURE;