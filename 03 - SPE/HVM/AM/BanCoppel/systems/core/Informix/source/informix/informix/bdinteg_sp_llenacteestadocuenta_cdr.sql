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