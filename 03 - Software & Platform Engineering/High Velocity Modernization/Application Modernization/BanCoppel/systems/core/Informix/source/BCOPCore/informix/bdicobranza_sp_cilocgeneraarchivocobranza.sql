CREATE PROCEDURE "informix".sp_cilocgeneraarchivocobranza(cNumCte CHAR(20))
returning char (50);

define cNumCredito,cNumCliente                                              char(20);
define cNumTarjeta                                                          char(16);
define mSaldoActual,mSaldoVencido,mSaldoContabMora,mSaldoContabMoraTotal    money(18,2);
define cSalarioMinimoaux                                                    decimal(14,2);
define cSucursal,cNumCiudadRef,cNumColoniaRef                               char(4);
define cNombre1,cNombre2,cApellido1,cApellido2                              char(26);
define cNombreCalle,cNombreCalle_t,cNomCalleRef,cColRef                     char(30);
define cNumInterio,cNumInterio_t,cNumExterior,cNumExterior_t                char(10);
define cColonia,cColonia_t,cManzana,cManzana_t                              char(30);
define cOtros,cOtros_t,cAndador,cAndador_t,cEtapa,cEtapa_t,cLote,cLote_t    char(5);
define cEdificio,cEdificio_t,cEntrada,cEntrada_t,cSalarioMinimo             char(5);
define cDepartamento,cDepartamento_t,cNumCentro,cNumCalleCte,cDeptoRef      char(6);
define cCodPostal,cCodPostal_t,cExtensionTrabajo                            char(5);
define cPuntoCardinal,cPuntoCardinal_t,cSituacionEspecial,cSexo             char(1);
define cComplemento,cComplemento_t,cComplementoRef                          char(80);
define cEntreCalles,cEntreCalles_t,cEntreCallesRef                          char(40);
define cDelegacionMunicipio,cDelegacionMunicipio_t,cEstado,cEstado_t        char(25);
define cTelefonoCasa,cTelefonoTrabajo,cCelular,cTelefonoRef                 char(13);
define cEstadoCivil,cTipoCasa,cDiaUltimoPago,cMesUltimoPago                 char(2);
define cAnioAlta,cAnioNacimiento,cNumCiudadCte,cNumCiudadCte_t              char(4);
define cNumJefe,cNumSupervisor,cPlazoCompromiso                             char(8);
define cNumColoniacte,cNumColoniacte_t,cAnioUltimoPago,cAnioUltimoCompac    char(4);
define cLugarTrabajo                                                        char(60);
define dFechaUltimoPago,dFechaUltimocompac,dFechaCumpliocompromiso          date;
define cImpteUltimocompromiso,cImpteCompromisocumplido                      char(5);
define cDiaUltimoCompac,cMesUltimoCompac                                    char(2);
define sCausasituacionespecial                                              SMALLINT;
define vTotalRegistros,vTotalCommit,sAbonosVdos                             integer;
define mSaldoTotalAcumulado,mSaldoVencidoAcumulado,mSaldoMoratorioAcumulado money(18);
define mIvaSucursal                                                         money(5,3);
define vfechaini,vfechafin,vfecha_hoy,vfecha_ultimo,vfechavenci             Date;
define cEmpresa                                                             char(3);
define sNumAvisos,cPuntoCardinalRef,cTipodecliente,cCumplioCompromiso       char(1);
define cNombreRef,cNomConyugeoFamiliar                                      char(78);
define cNumExtRef,cNumIntRef                                                char(10);
define cManzanaRef,cOtrosRef,cAndadorRef,cEtapaRef,cLoteRef,cEdificioRef    char(5);
define cEntradaRef,cCpRef,var_rga                                           char(5);
define cDelegacionMunicipioRef,cEstadoRef                                   char(25);
define cTelConyugeoFamiliar                                                 char(13);
define cNombreArchivo,cNombreArchivo2                                       char(50);
define cSql                                                                 char(1500);
define cSql3																CHAR(900);
define cpagominimo,cSalvenci,cMoraaux,cInteresaux,cInteresV                 money(18,2);
define vmensualidades_min,vmensualidades_max,salariominban                  integer;
define cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4          money(18,2);
define cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2  money(18,2);
define cInteresmoratorio3,cInteresmoratorio4                                money(18,2);
define cInteresmoratorio5,cInteresmoratorio6,cproyecmora                    decimal(18,2);
define ctasamora                                                            decimal(9,6);
DEFINE sPaso                                                                SMALLINT; --CAS
DEFINE SQL_ERR,ISAM_ERR          											INTEGER;
DEFINE ERROR_INFO,P_MENSAJE      											VARCHAR(80);
DEFINE P_COD_RET                 											VARCHAR(5);
DEFINE v_banderRoll															INTEGER;
DEFINE v_origen																INTEGER;
DEFINE vCont																INTEGER;
DEFINE cTipoDomicilio                                                       CHAR(2); 
DEFINE v_nombreArchivo														CHAR(30);
DEFINE v_nombreArchivof														CHAR(30);
DEFINE v_ruta																CHAR(20);
DEFINE vsSQL1                     											CHAR (300);
DEFINE vsSQL2                     											CHAR (300);
DEFINE v_separador															CHAR(5);
DEFINE cEstatus                     										CHAR (2);
DEFINE dtFecha																DATE;
DEFINE bandera																INTEGER;
Define vCodRetparam															CHAR(5);
define dFechaparam															DATE;
define vrutaparam															CHAR(100);

	--SET DEBUG FILE TO "sp_llenacteestadocobranza.out";
	--TRACE ON;
BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		--IF v_banderRoll = 1 then
		--	ROLLBACK WORK;
		--END IF;
        if P_COD_RET = -668 then
            RETURN "No copio el archivo al servidor destino " ||  P_COD_RET;
        else
            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_creda';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_paso_creda;
            END IF;
            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'paso_sitesp';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE paso_sitesp;
            END IF;
			
			
--		    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_paso_creda'  AND dbsname = 'bdicobranza') THEN
--               DROP TABLE sd_paso_creda;
--			END IF;			
		    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'paso_sitesp'  AND dbsname = 'bdicobranza') THEN
               DROP TABLE paso_sitesp;
			END IF;
			--IF v_banderRoll = 1 then
			--	ROLLBACK WORK;
			--END IF;
            RETURN P_COD_RET;
        end if;
    END EXCEPTION;
LET  cNumCredito  = ""; LET  cNumCliente =  ""; LET  cNumTarjeta  =  ""; LET  mSaldoActual = 0;
LET  mSaldoVencido = 0; LET  cSalarioMinimoaux=0; LET  cSalarioMinimo  =  ""; LET  cSucursal  =  "";
LET  cNombre1  =  ""; LET  cNombre2  =  ""; LET  cApellido1  =  ""; LET  cApellido2  =  "";
LET  cNombreCalle  =  ""; LET  cNumInterio  =  ""; LET  cNumExterior   =  ""; LET  cColonia  =  "";
LET  cManzana  =  ""; LET  cOtros  =  ""; LET  cAndador  =  ""; LET  cEtapa  =  ""; LET  cLote  =  "";
LET  cEdificio  =  ""; LET  cEntrada  =  ""; LET  cDepartamento  =  ""; LET  cCodPostal  =  "";
LET  cPuntoCardinal  =  ""; LET  cComplemento  =  ""; LET  cEntreCalles   =  ""; LET  cDelegacionMunicipio  =  "";
LET  cEstado  =  ""; LET  cTelefonoCasa  =  ""; LET  cTelefonoTrabajo  =  ""; LET  cExtensionTrabajo   =  "";
LET  cCelular   =  ""; LET  cEstadoCivil   =  ""; LET  cTipoCasa   =  ""; LET  cSexo   =  "";
LET  cAnioAlta   =  ""; LET  cAnioNacimiento   =  ""; LET  cNumCiudadCte   =  ""; LET  cNumCentro   =  "";
LET  cNumJefe   =  ""; LET  cNumSupervisor   =  ""; LET  cNumColoniacte   =  ""; LET  cNumCalleCte   =  "";
LET  cLugarTrabajo   =  ""; LET  dFechaUltimoPago  = date(1); LET  cDiaUltimoPago   =  ""; LET  cMesUltimoPago   =  "";
LET  cAnioUltimoPago   =  ""; LET  cPlazoCompromiso  = ""; LET  cImpteCompromisocumplido  = "";
LET  dFechaCumpliocompromiso  = date(1); LET  cDiaUltimoCompac = ""; LET  cMesUltimoCompac = "";
LET  cAnioUltimoCompac = ""; LET  vTotalRegistros = 0; LET  mSaldoTotalAcumulado = 0; LET  mSaldoVencidoAcumulado = 0;
LET  mSaldoMoratorioAcumulado = 0; LET  mSaldoContabMora = 0; LET  mIvaSucursal = 0; LET  mSaldoContabMoraTotal = 0;
LET  vfecha_hoy= date(1); LET  vfechaini= date(1); LET vfecha_ultimo= date(1); LET  vfechafin= date(1);
LET  cEmpresa=""; LET  sAbonosVdos =0; LET  sNumAvisos =0; LET  cNombreRef=""; LET  cNomCalleRef="";
LET  cNumExtRef=""; LET  cNumIntRef=""; LET  cColRef=""; LET  cManzanaRef=""; LET  cOtrosRef="";
LET  cAndadorRef=""; LET  cEtapaRef=""; LET  cLoteRef=""; LET  cEdificioRef=""; LET  cEntradaRef="";
LET  cDeptoRef=""; LET  cCpRef=""; LET  cPuntoCardinalRef=""; LET  cComplementoRef=""; LET  cEntreCallesRef="";
LET  cDelegacionMunicipioRef=""; LET  cEstadoRef=""; LET  cTelefonoRef=""; LET  cNumCiudadRef=""; LET  cNumColoniaRef="";
LET  cNomConyugeoFamiliar=""; LET  cTelConyugeoFamiliar="";
--INI CAS
LET  cNombreCalle_t=""; LET  cNumExterior_t=""; LET  cNumInterio_t=""; LET  cColonia_t=""; LET  cManzana_t="";
LET  cOtros_t=""; LET  cAndador_t=""; LET  cEtapa_t=""; LET  cLote_t=""; LET  cEdificio_t=""; LET  cEntrada_t="";
LET  cDepartamento_t=""; LET  cCodPostal_t=""; LET  cPuntoCardinal_t=""; LET  cComplemento_t=""; LET  cEntreCalles_t="";
LET  cDelegacionMunicipio_t=""; LET  cEstado_t=""; LET  cNumCiudadCte_t=""; LET  cNumColoniacte_t=""; LET  cSaldovencido1=0;
LET  cSaldovencido2=0; LET  cSaldovencido3=0; LET  cSaldovencido4=0; LET  cSaldovencido5=0; LET  cSaldovencido6=0;
LET  cInteresmoratorio1=0; LET  cInteresmoratorio2=0; LET  cInteresmoratorio3=0; LET  cInteresmoratorio4=0; LET  cInteresmoratorio5=0;
LET  cInteresmoratorio6=0; LET  cInteresaux=0; LET  cInteresV=0; LET  cpagominimo=0; LET  ctasamora=0;

LET cSaldovencido2=0; LET cSaldovencido3=0; LET cSaldovencido4=0;
LET cSaldovencido5=0; LET cSaldovencido6=0; LET cInteresmoratorio2=0; LET cInteresmoratorio3=0;
LET cInteresmoratorio4=0; LET cInteresmoratorio5=0;  LET cInteresmoratorio6=0; LET cproyecmora=0;

LET cSituacionEspecial="";         LET sCausasituacionespecial=0;

--FIN CAS
LET  cSQL = ""; LET  vTotalCommit=0; LET  vmensualidades_min = 0; LET  vmensualidades_max = 0; LET  var_rga = ""; LET  vfechavenci=date(0);
LET v_banderRoll = 0;
LET v_origen = 0;
LET cTipoDomicilio ="";
LET v_nombreArchivo = "";
LET v_ruta = "";
LET vsSQL1 = "";
LET vsSQL2 = "";
LET cSql3 = "";
LET v_separador = "'/'";
let cTipodecliente = '';
let cEstatus = '';
let dtFecha =date(1);
LET bandera = 0;

LET vCodRetparam = "";
LET dFechaparam = "";
LET vrutaparam = date(1);

    select valor
    into salariominban
    from bdisolic:ss_param
    where empresa='001'
      and secuencia='303';
    Select date(fecha_ant), date (ult_dia_mes)
    Into vfecha_hoy, vfecha_ultimo
    From bdicred:sd_fechas;
    Select (valor+0) Into vmensualidades_min From bdinteg:si_param  where empresa='001' and cod_param = '60';
    Select (valor+0) Into vmensualidades_max From bdinteg:si_param  where empresa='001' and cod_param = '61';
    LET  cNombreArchivo = 'EdoCuentaAbogadoBancoppel' || LPAD(TRIM(MONTH(vfecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(vfecha_hoy),3,2) || '.txt';
    --LET  cNombreArchivo2 = 'CifraAbogadoBancoppel' || LPAD(TRIM(MONTH(vfecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(vfecha_hoy),3,2) || '.txt';
    --Begin Work;
    Let P_cod_ret = "00000";

    --truncate  bdinteg:si_cteestadocuenta;
   -- truncate bdinteg:si_cifracontrolabogado;
---INI NO SE IMPRIMEN EDOCOBRANZA SI PRESENTAN SITUACION ESPECIAL

            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_creda';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_paso_creda; --"informix".sd_paso_creda;
            END IF;

            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'paso_sitesp';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE paso_sitesp; --"informix".sd_paso_creda;
            END IF;

--		    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'sd_paso_creda'  AND dbsname = 'bdicobranza') THEN
--               DROP TABLE sd_paso_creda;--			END IF;			
--		    IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'paso_sitesp'  AND dbsname = 'bdicobranza') THEN
--               DROP TABLE paso_sitesp;--			END IF;

			CREATE TABLE sd_paso_creda --"informix".sd_paso_creda
                (num_credito CHAR(20));
            /*select numcred

             from bdisitesp:se_ctessitespcred a,
                  bdisitesp:se_situacionaccion b
            where a.situacion = b.situacion
              and a.causa     = b.causa
              and idaccion = 5
              and instruccion = '0'
            union all
            select num_credito
            from bdicred:sd_maecred
            where empresa  ='001'
            and numcte in (
            select numcte
             from bdisitesp:se_ctessitespcte a,
                  bdisitesp:se_situacionaccion b
            where a.situacion = b.situacion
              and a.causa     = b.causa
              and idaccion = 5
              and instruccion = '0')*/
		  
			select num_credito
			from bdicred:sd_maecred
			where empresa  ='001'
			and numcte in (	select unique (numcte)
							FROM bdisitesp:se_ctessitespcte
							where situacion = "L")							
            group by 1
            into temp paso_sitesp with no log;

            insert into sd_paso_creda			
            select * from paso_sitesp group by 1;
            create unique index inx_sd_paso_cred on sd_paso_creda(num_credito);
            UPDATE STATISTICS medium FOR TABLE sd_paso_creda;
---FIN NO SE IMPRIMEN EDOCOBRANZA SI PRESENTAN SITUACION ESPECIAL
--    update statistics high for table bdinteg:si_cifracontrolabogado;
      ForEach with hold
          Select
            nvl(mcr.empresa,' '),    -- numero de credito
            nvl(mcr.num_credito,' '),    -- numero de credito
            nvl(mcr.numcte,' '),     --  numero de cliente
            nvl(tar.num_tarjeta,' '),    -- numero de tarjeta de credito
            nvl(msd.sdo_cap_insoluto,0),   -- saldo actual
            nvl(msd.mto_venc_trasp+msd.monto_vencido,0),  -- saldo vencido
            nvl(mca.fecha_ult_pago,date(1)), --fecha_ultimo_pago
--            nvl((msd.sdo_contab_mora+msd.sdo_moratorio)*1.15,0),
            nvl(msd.monto_financiado,0),
            nvl(mcr.tasa_moratorios,0)
        Into cEmpresa, cNumCredito, cNumCliente, cNumTarjeta, mSaldoActual, mSaldoVencido, dFechaUltimoPago,
             cpagominimo,ctasamora
        From bdicred:sd_maecred mcr
        LEFT OUTER JOIN  bdicred:sd_maecredanexo mca ON (mcr.empresa = mca.empresa and  mca.num_credito = mcr.num_credito)
        LEFT OUTER JOIN  bdicred:sd_tarjeta tar ON
                         (mcr.empresa = tar.empresa
                          and tar.num_credito = mcr.num_credito
                          and tar.tipo_tarjeta = 'T'
                          and tar.status_tar = 'A'
                          and secuencia = (select max(secuencia) from bdicred:sd_tarjeta where mcr.empresa = empresa and mcr.num_credito = num_credito and tipo_tarjeta = 'T' and status_tar = 'A'))
        LEFT OUTER JOIN  bdicred:sd_maesdos msd ON (mcr.empresa = msd.empresa and  msd.num_credito = mcr.num_credito)
        where  mcr.empresa = '001'
		and mcr.num_credito in (select num_credito from sd_paso_creda)
		--Validacion para que solo se haga la consulta por numero de cliente cuando se reciba como parametro de entrada
		and mcr.numcte = CASE when cNumCte = '' THEN  mcr.numcte ELSE cNumCte END 
		
        SELECT NVL(ingreso_mensual,0) / salariominban
        INTO cSalarioMinimoaux
        FROM   bdisolic:ss_resum_scor_fin
        WHERE  empresa = cEmpresa
        AND num_solicitud = cNumCredito;

        IF cSalarioMinimoaux >= 22 THEN
           LET cSalarioMinimo = LPAD(22,2,'0');
        ELSE
           LET cSalarioMinimo = LPAD(cSalarioMinimoaux::INTEGER::VARCHAR(2),2,'0');
        END IF;

		ForEach 
			SELECT NVL(origen,0),tipo_domicilio
			INTO v_origen,cTipoDomicilio
			from bdicobranza:cb_marcacliente
			WHERE tipo_marca = "LV"
			AND estatus = "SA"
			AND numcte = cNumCliente

			LET vCont = dbinfo("sqlca.sqlerrd2");
			IF vCont = 0 THEN
				--indica  que el numero de cliente no tiene una marca pero si esta tiene una situacioespecial  por  lo tanto se va  a generar el estado de cobranza con los 3 tipos de direcciones del cleinte
			            ---------------Domicilio Particular
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
				        rpad(TRIM(tel1.telefono),13,' ') AS tel_casa,   -- telefono casa
				        rpad(TRIM(tel3.telefono),13,' ') AS tel_trabajo, -- telefono trabajo
				        rpad(TRIM(tel3.extension),5,' ') AS ext_trabajo,     -- extension trabajo
				        rpad(TRIM(tel2.telefono),13,' ') AS celular,    -- celular
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(zon.centro,6,'0') AS numcentro, -- numero de centro
				        lpad(zon.jefegrupozona,8,'0') AS numjefe, -- numero de jefe
				        lpad(zon.supervisorzona,8,'0') AS numsupervisor, -- numero de supervisor
				        lpad(dir.numerocolonia,4,'0') AS numcolonia,  -- numero de colonia de cliente
				        lpad(dir.numerocalle,6,'0') AS numcalle,  -- numero de calle de cliente
				        nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo    -- lugar de trabajo
				        Into cNombreCalle, cNumExterior, cNumInterio, cColonia, cManzana, cOtros, cAndador, cEtapa, cLote, 
						cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento, cEntreCalles,
						cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,
				        cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor, cNumColoniacte, cNumCalleCte, cLugarTrabajo
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.numcte= cte.numcte AND ing.tipo_ingreso = 'T' and ing.sec_ingreso= (select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 where ing1.numcte= cte.numcte and ing1.tipo_ingreso= 'T'))
						left join bdinteg:si_telefonos tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1 and 
						  tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 1))
						left join bdinteg:si_telefonos tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2 and 
						  tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 2))
						left join bdinteg:si_telefonos tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3 and 
						  tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 3))
				        WHERE cte.numcte = cNumCliente
				        and dir.tipo_dir = '1'
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones dir1
			                                  Where dir1.tipo_dir = '1' and dir1.numcte = cNumCliente );
				        ---------------Domicilio de Casa
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
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(dir.numerocolonia,4,'0') AS numcolonia  -- numero de colonia de cliente
				        Into cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t,
				        cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
				        cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t, cDelegacionMunicipio_t, cEstado_t,
				        cNumCiudadCte_t, cNumColoniacte_t
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        Where cte.numcte = cNumCliente
				        and dir.tipo_dir = '2'
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones
				                              Where tipo_dir = '2' and numcte = cNumCliente );

				        ---------------Domicilio del Trabajo					
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
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(dir.numerocolonia,4,'0') AS numcolonia  -- numero de colonia de cliente
				        Into cNomCalleRef, cNumExtRef, cNumIntRef, cColRef,cManzanaRef,
				        cOtrosRef, cAndadorRef, cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef,
				        cCpRef, cPuntoCardinalRef, cComplementoRef,cEntreCallesRef, cDelegacionMunicipioRef, cEstadoRef,
				        cNumCiudadRef, cNumColoniaRef
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        Where cte.numcte = cNumCliente
				        and dir.tipo_dir = '3'    ---- Falta ambientar tabla si_direcciones para la informacion de la referencia
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones
				                              Where tipo_dir = '3' and numcte = cNumCliente );	
			       
			END IF;

					SELECT limit 1
					lpad(TRIM(cte.sucursal),4,'0') AS sucursal,         -- sucursal
					rpad(TRIM(cte.nombre1),20,' ') AS nombre1,      -- nombre 1
					rpad(TRIM(cte.nombre2),20,' ') AS nombre2,      -- nombre 2
					rpad(TRIM(cte.apell_paterno),20,' ') AS apellpaterno,       --apellido 1
					rpad(TRIM(cte.apell_materno),20,' ') AS apellmaterno,     --apellido 2
					lpad(year(cte.fecha_alta),4,'0') AS ayoalta,    -- año de alta
					rpad(TRIM(ctepf.estado_civil),2,' ') AS edo_civil,      -- estado  civil
					TRIM(decode(ctepf.habita_en,'01','P','02','R','03','F','04','G','05','H',ctepf.habita_en)) AS tipo_casa,     -- tipo de casa
					rpad(TRIM(ctepf.sexo),1,' ') AS sexo,   --sexo
					lpad(year(ctepf.fecha_nac),4,'0') AS ayonac    -- año de nacimiento
                    Into cSucursal, cNombre1, cNombre2, cApellido1, cApellido2, cAnioAlta,
			        cEstadoCivil, cTipoCasa, cSexo, cAnioNacimiento
					FROM bdinteg:si_cliente cte
					LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
			        WHERE cte.numcte = cNumCliente;
		
				   Select iva
			        Into mIvaSucursal
			        From bdinteg:si_sucursales
			        Where sucursal = cSucursal;
		
				IF v_origen = 1  THEN
			        
				    if  cTipoDomicilio = "1" then                           ---------------Domicilio Particular
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
				        rpad(TRIM(tel1.telefono),13,' ') AS tel_casa,   -- telefono casa
				        rpad(TRIM(tel3.telefono),13,' ') AS tel_trabajo, -- telefono trabajo
				        rpad(TRIM(tel3.extension),5,' ') AS ext_trabajo,     -- extension trabajo
				        rpad(TRIM(tel2.telefono),13,' ') AS celular,    -- celular
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(zon.centro,6,'0') AS numcentro, -- numero de centro
				        lpad(zon.jefegrupozona,8,'0') AS numjefe, -- numero de jefe
				        lpad(zon.supervisorzona,8,'0') AS numsupervisor, -- numero de supervisor
				        lpad(dir.numerocolonia,4,'0') AS numcolonia,  -- numero de colonia de cliente
				        lpad(dir.numerocalle,6,'0') AS numcalle,  -- numero de calle de cliente
				        nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo    -- lugar de trabajo
				        Into cNombreCalle, cNumExterior, cNumInterio, cColonia, cManzana, cOtros, cAndador, cEtapa, cLote, 
						cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento, cEntreCalles,
						cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,
				        cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor, cNumColoniacte, cNumCalleCte, cLugarTrabajo
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.numcte= cte.numcte AND ing.tipo_ingreso = 'T' and ing.sec_ingreso= (select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 where ing1.numcte= cte.numcte and ing1.tipo_ingreso= 'T'))
				        left join bdinteg:si_telefonos tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1 and 
						  tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 1))
						left join bdinteg:si_telefonos tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2 and 
						  tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 2))
						left join bdinteg:si_telefonos tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3 and 
						  tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 3))
						WHERE cte.numcte = cNumCliente
				        and dir.tipo_dir = cTipoDomicilio
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones dir1
			                                  Where dir1.tipo_dir = cTipoDomicilio and dir1.numcte = cNumCliente );
				    elif  cTipoDomicilio = "2" then                           ---------------Domicilio de Casa
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
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(dir.numerocolonia,4,'0') AS numcolonia  -- numero de colonia de cliente
				        Into cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t,
				        cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
				        cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t, cDelegacionMunicipio_t, cEstado_t,
				        cNumCiudadCte_t, cNumColoniacte_t
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        Where cte.numcte = cNumCliente
				        and dir.tipo_dir = cTipoDomicilio
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones
				                              Where tipo_dir = cTipoDomicilio and numcte = cNumCliente );

				    elif  cTipoDomicilio = "3" then                           ---------------Domicilio del Trabajo
					-------------- Falta defin de donde se tomaran los datos de la referncia
					------------------------------------------------------------
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
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(dir.numerocolonia,4,'0') AS numcolonia  -- numero de colonia de cliente
				        Into cNomCalleRef, cNumExtRef, cNumIntRef, cColRef,cManzanaRef,
				        cOtrosRef, cAndadorRef, cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef,
				        cCpRef, cPuntoCardinalRef, cComplementoRef,cEntreCallesRef, cDelegacionMunicipioRef, cEstadoRef,
				        cNumCiudadRef, cNumColoniaRef
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        Where cte.numcte = cNumCliente
				        and dir.tipo_dir = cTipoDomicilio    ---- Falta ambientar tabla si_direcciones para la informacion de la referencia
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones
				                              Where tipo_dir = cTipoDomicilio and numcte = cNumCliente );
					end if;				
				END IF;
				IF v_origen > 1  THEN
				--ELSE   ----------------------------------------------------------------------------------------------------------------------------Para los Tipos de Origenes 2 (CENTRAL) y 3(WEB)
				    if  cTipoDomicilio = "1" then                           ---------------Domicilio Particular
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
				         rpad(TRIM(tel1.telefono),13,' ') AS tel_casa,   -- telefono casa
				        rpad(TRIM(tel3.telefono),13,' ') AS tel_trabajo, -- telefono trabajo
				        rpad(TRIM(tel3.extension),5,' ') AS ext_trabajo,     -- extension trabajo
				        rpad(TRIM(tel2.telefono),13,' ') AS celular,    -- celular
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(zon.centro,6,'0') AS numcentro, -- numero de centro
				        lpad(zon.jefegrupozona,8,'0') AS numjefe, -- numero de jefe
				        lpad(zon.supervisorzona,8,'0') AS numsupervisor, -- numero de supervisor
				        lpad(dir.numerocolonia,4,'0') AS numcolonia,  -- numero de colonia de cliente
				        lpad(dir.numerocalle,6,'0') AS numcalle,  -- numero de calle de cliente
				        nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo    -- lugar de trabajo
				        Into cNombreCalle, cNumExterior, cNumInterio, cColonia, cManzana, cOtros, cAndador, cEtapa, cLote, 
						cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento, cEntreCalles,
						cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,
				        cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor, cNumColoniacte, cNumCalleCte, cLugarTrabajo
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_direcciones_loc  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.numcte= cte.numcte AND ing.tipo_ingreso = 'T' and ing.sec_ingreso= (select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 where ing1.numcte= cte.numcte and ing1.tipo_ingreso= 'T'))
				        left join bdinteg:si_telefonos tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1 and 
						  tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 1))
						left join bdinteg:si_telefonos tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2 and 
						  tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 2))
						left join bdinteg:si_telefonos tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3 and 
						  tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos where numcte = cte.numcte and tipo_tel = 3))
						WHERE cte.numcte = cNumCliente
				        and dir.tipo_dir = cTipoDomicilio
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones dir1
			                                  Where dir1.tipo_dir = cTipoDomicilio and dir1.numcte = cNumCliente );
				    elif  cTipoDomicilio = "2" then                           ---------------Domicilio de Casa
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
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(dir.numerocolonia,4,'0') AS numcolonia  -- numero de colonia de cliente
				        Into cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t,
				        cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
				        cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t, cDelegacionMunicipio_t, cEstado_t,
				        cNumCiudadCte_t, cNumColoniacte_t
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_direcciones_loc  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        Where cte.numcte = cNumCliente
				        and dir.tipo_dir = cTipoDomicilio
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones_loc
				                              Where tipo_dir = cTipoDomicilio and numcte = cNumCliente );

				    elif  cTipoDomicilio = "3" then                           ---------------Domicilio del Trabajo
-------------- Falta defin de donde se tomaran los datos de la referncia
------------------------------------------------------------
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
				        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
				        lpad(dir.numerocolonia,4,'0') AS numcolonia  -- numero de colonia de cliente
				        Into cNomCalleRef, cNumExtRef, cNumIntRef, cColRef,cManzanaRef,
				        cOtrosRef, cAndadorRef, cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef,
				        cCpRef, cPuntoCardinalRef, cComplementoRef,cEntreCallesRef, cDelegacionMunicipioRef, cEstadoRef,
				        cNumCiudadRef, cNumColoniaRef
				        FROM bdinteg:si_cliente cte
				        LEFT OUTER JOIN bdinteg:si_direcciones_loc  dir ON (dir.numcte = cte.numcte)
				        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
				        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
				        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
				        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
				        Where cte.numcte = cNumCliente
				        and dir.tipo_dir = cTipoDomicilio    ---- Falta ambientar tabla si_direcciones_loc para la informacion de la referencia
				        and dir.secuencia = ( Select max(secuencia)
				                              From bdinteg:si_direcciones
				                              Where tipo_dir = cTipoDomicilio and numcte = cNumCliente );

					end if;		         

			END IF;
			
		END FOREACH;
	
        FOREACH
            Select nvl((capital_debe-capital_pagado),0),
            NVL((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*(1 + s.iva),0),
            NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0)
            Into cSalvenci,cMoraaux,cInteresaux
            From  bdicred:sd_amortiza_credito b,bdicred:sd_maecred a, bdinteg:si_sucursales s
            Where b.empresa= cEmpresa 
			And b.num_credito = a.num_credito
			AND a.sucursal = s.sucursal
			And b.num_credito = cNumCredito 
			And b.capital_status in ('2','7','6')
            And b.fecha_cuota >= date(0) order by fecha_cuota
            IF cSalvenci>0 or cSalvenci is not null THEN
                LET sAbonosVdos=sAbonosVdos+1;
                IF sAbonosVdos=1 THEN
                    LET cSaldovencido1=cSalvenci+cInteresaux;
                    LET cInteresmoratorio1=cMoraaux+(cSalvenci*ctasamora/ 36000)*17.25;
                    LET cTipodecliente='1';
                    LET sNumAvisos='1';
                END IF;
                IF sAbonosVdos=2 THEN
                    LET cSaldovencido2=cSalvenci+cInteresaux;
                    LET cInteresmoratorio2=cMoraaux+(cSalvenci*ctasamora/ 36000)*17.25;
                    LET cTipodecliente='1';
                    LET sNumAvisos='2';
                END IF;
                IF sAbonosVdos=3 THEN
                    LET cSaldovencido3=cSalvenci+cInteresaux;
                    LET cInteresmoratorio3=cMoraaux+(cSalvenci*ctasamora/ 36000)*17.25;
                    LET cTipodecliente='2';
                    LET sNumAvisos='3';
                END IF;
                IF sAbonosVdos=4 THEN
                    LET cSaldovencido4=cSalvenci+cInteresaux;
                    LET cInteresmoratorio4=cMoraaux+(cSalvenci*ctasamora/ 36000)*17.25;
                    LET cTipodecliente='3';
                    LET sNumAvisos='3';
                END IF;
                IF sAbonosVdos=5 THEN
                    LET cSaldovencido5=cSalvenci+cInteresaux;
                    LET cInteresmoratorio5=cMoraaux+(cSalvenci*ctasamora/ 36000)*17.25;
                    LET cTipodecliente='4';
                    LET sNumAvisos='4';
                END IF;
                IF sAbonosVdos>=6 THEN
                    LET cSaldovencido6=cSalvenci+cInteresaux;
                    LET cInteresmoratorio6=cMoraaux+(cSalvenci*ctasamora/ 36000)*17.25;
                       IF sAbonosVdos>6 THEN LET cTipodecliente='5'; ELSE LET cTipodecliente='4';  END IF;
                    LET sNumAvisos='9999';
                END IF;
            END IF;
           LET cInteresV=cInteresaux+cInteresV;
        END FOREACH;

		LET mSaldoContabMora=cInteresmoratorio1+cInteresmoratorio2+cInteresmoratorio3+cInteresmoratorio4+cInteresmoratorio5+cInteresmoratorio6;
		LET mSaldoVencido=mSaldoVencido+cInteresV;     LET mSaldoActual=mSaldoActual+cInteresV;         LET cpagominimo=cpagominimo+cInteresV;
		LET  cImpteUltimocompromiso  = 0;     LET  dFechaUltimocompac  = date(1);     LET  dFechaCumpliocompromiso = date(1);
		LET  cCumplioCompromiso=" ";    LET  cPlazoCompromiso=" ";    LET  cImpteCompromisocumplido=" ";

        SELECT LPAD(round(importe),5,"0")importe,fecha_compac,
                CASE WHEN dFechaUltimoPago BETWEEN fecha_compac AND DATE((fecha_compac::date)+((plazo::integer)*7) units day) AND dFechaUltimoPago IS NOT NULL
                THEN (case when importe>=(SELECT sum(monto)/2
                                          FROM bdicred:sd_movhis
                                          WHERE empresa=cEmpresa
                                          AND fecha_mov=dFechaUltimoPago
                                          AND num_credito=numcuenta
                                          AND codigo_fun in ('033','334','335','336','337','904')
                                          AND codigo_ref=1
                                          AND reversado='N') then 'S'
                      ELSE CASE WHEN vfecha_hoy BETWEEN fecha_compac AND DATE((fecha_compac::date)+((plazo::integer)*7) units day) THEN 'P'
                           ELSE 'N' END END)
                  ELSE CASE WHEN vfecha_hoy BETWEEN fecha_compac AND DATE((fecha_compac::date)+((plazo::integer)*7) units day) THEN 'P'
                       ELSE 'N' END END,plazo
        INTO cImpteUltimocompromiso,dFechaUltimocompac,cCumplioCompromiso,cPlazoCompromiso
	    FROM bdicobranza:cb_compac
	    WHERE empresa =cEmpresa
	    AND numcliente=cNumCliente
        and keyx=(select max(keyx)
                  from bdicobranza:cb_compac
                  WHERE empresa =cEmpresa
                  AND numcliente=cNumCliente);

            
     IF cCumplioCompromiso='S' THEN
         SELECT LPAD(round(sum(monto)),5,"0")
         INTO cImpteCompromisocumplido
         FROM bdicred:sd_movhis
         WHERE empresa=cEmpresa
         AND fecha_mov=dFechaUltimoPago
         AND num_credito=cNumCredito
         AND codigo_fun in ('033','334','335','336','337','904')
         AND codigo_ref=1
         AND reversado='N';
        LET dFechaCumpliocompromiso=dFechaUltimoPago;
     END IF;

        IF cImpteUltimocompromiso IS NULL OR cImpteUltimocompromiso=" " THEN LET cImpteUltimocompromiso='00000'; END IF;
        IF cCumplioCompromiso IS NULL OR cCumplioCompromiso=" " THEN LET cCumplioCompromiso='-'; END IF;

	SELECT situacion,causa
        INTO cSituacionEspecial,sCausasituacionespecial
	FROM bdisitesp:se_ctessitespcte 
	WHERE  numcte=cNumCliente
	AND idmovto = ( SELECT MAX(idmovto )
                                FROM bdisitesp:se_ctessitespcte 
                                WHERE  numcte=cNumCliente);
     
		IF cSituacionEspecial IS NULL or cSituacionEspecial="" THEN LET cSituacionEspecial="-"; END IF;
        IF sCausasituacionespecial IS NULL or sCausasituacionespecial= 0 THEN LET sCausasituacionespecial= 0; END IF;
        if (mIvaSucursal is null)then let mIvaSucursal = 0;  end if;
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
		
         -- se obtiene el nombre de la referencia y el telefono de la referencia.
		Select limit 1 nombre_ref, telefono_ref
        into cNombreRef, cTelefonoRef
        From bdisolic:ss_refpersonales
        Where empresa = cEmpresa
        And numcte= cNumCliente;

		--IF v_banderRoll = 0 THEN        --    begin work;		--	LET v_banderRoll = 1;        --END IF;
		LET bandera = 0;
		
		SELECT status,fecha_movto
		 INTO	cEstatus,dtFecha
		FROM bdicobranza:cb_cteedocobloc 
		WHERE numcte = cNumCliente 
		AND fecha_movto = (SELECT MAX(fecha_movto)
						FROM bdicobranza:cb_cteedocobloc 
						WHERE numcte = cNumCliente );
		
		IF cEstatus = '' or  cEstatus is null THEN
			LET bandera = 1;
		END IF;
		IF (cEstatus <> "NP"  and dtFecha <> vfecha_hoy)  OR (bandera=1)  THEN		
        --IF NOT  exists (SELECT  numcte FROM bdicobranza:cb_cteedocobloc WHERE numcte = cNumCliente AND status = "NP" ) then
			Insert into bdicobranza:cb_cteedocobloc(
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
	        interesmoratorio6,fecha_movto,status)
	        Values ('001',cSucursal,cNumCliente,cNombre1,cNombre2,cApellido1,cApellido2,cNombreCalle,cNumExterior,cNumInterio,cColonia,
	        cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento,
	        cEntreCalles,cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,
	        cLugarTrabajo,cNombreCalle_t, cNumExterior_t, cNumInterio_t, cColonia_t,cManzana_t,
	        cOtros_t, cAndador_t, cEtapa_t, cLote_t, cEdificio_t, cEntrada_t, cDepartamento_t,
	        cCodPostal_t, cPuntoCardinal_t, cComplemento_t,cEntreCalles_t,cDelegacionMunicipio_t,
	        cEstado_t,cNumCiudadCte_t, cNumColoniacte_t,cNumCredito,cNumTarjeta,cSituacionEspecial,cEstadoCivil,
	        cTipoCasa, cSexo,cSalarioMinimo,cAnioAlta, cAnioNacimiento,mSaldoActual,mSaldoVencido,mSaldoContabMoraTotal,cpagominimo,dFechaUltimoPago,
	        cImpteUltimocompromiso, dFechaUltimocompac, cPlazoCompromiso, cImpteCompromisocumplido, dFechaCumpliocompromiso,cCumplioCompromiso,cNumCiudadCte,
	        cNumCentro, cNumJefe, cNumSupervisor,cNumColoniacte, cNumCalleCte, cNumExterior,mSaldoVencido, cDiaUltimoPago,
	        cMesUltimoPago, cAnioUltimoPago,cDiaUltimoCompac, cMesUltimoCompac, cAnioUltimoCompac,
	        cTipodecliente,sCausasituacionespecial,sAbonosVdos, sNumAvisos, cNombreRef, cNomCalleRef, cNumExtRef, cNumIntRef, cColRef,
	        cManzanaRef, cOtrosRef, cAndadorRef,cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef, cCpRef, cPuntoCardinalRef,
	        cComplementoRef, cEntreCallesRef,cDelegacionMunicipioRef, cEstadoRef,cTelefonoRef, cNumCiudadRef,
	        cNumColoniaRef, cNomConyugeoFamiliar, cTelConyugeoFamiliar,cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4,
	        cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2,cInteresmoratorio3,cInteresmoratorio4,cInteresmoratorio5,
	        cInteresmoratorio6, vfecha_hoy, "NP");
			LET vTotalRegistros = vTotalRegistros +1;
			--LET vTotalCommit=vTotalCommit+1;
		END IF;
		
        --IF vTotalCommit=60000 THEN         --   COMMIT WORK;		--	LET v_banderRoll = 0;
        --    update statistics medium for table bdicobranza:cb_cteedocobloc;
       --     LET vTotalCommit=0;		--	LET v_banderRoll = 0;
        --END IF;
    End ForEach;
    --IF vTotalCommit>0 or v_banderRoll = 1 THEN    --   COMMIT WORK;
	--   LET v_banderRoll = 0;    --   update statistics medium for table bdicobranza:cb_cteedocobloc;    --END IF;

    DROP TABLE sd_paso_creda;
	
	IF cNumCte = '' THEN      ---Se agrego Validacion para crear el archivo solamente cuando no se reciva el numero de cliente como parametro
		--LET v_nombreArchivo = "EdoCobranzaBanco";
		LET v_nombreArchivo = "EdoCobranzaBanco"  || (select lpad(DAY(fecha_hoy),2,0) from bdinteg:si_fechas) || (select lpad(MONTH(fecha_hoy),2,0) from bdinteg:si_fechas) || (select lpad(YEAR(fecha_hoy),4,0) from bdinteg:si_fechas);
		--LET v_nombreArchivo2 = "EdoCobranzaBancoppel";
		--LET v_nombreArchivof = "EdoCobranzaBancoppel"  || (select lpad(DAY(fecha_hoy),2,0) from bdinteg:si_fechas) || (select lpad(MONTH(fecha_hoy),2,0) from bdinteg:si_fechas) || (select lpad(YEAR(fecha_hoy),4,0) from bdinteg:si_fechas);
		LET v_nombreArchivof = "edocobloc_"  || (select lpad(DAY(fecha_hoy),2,0) from bdinteg:si_fechas) || (select lpad(MONTH(fecha_hoy),2,0) from bdinteg:si_fechas) || (select lpad(YEAR(fecha_hoy),4,0) from bdinteg:si_fechas);
	
		EXECUTE PROCEDURE bdicobranza:sp_consultaparamcobranza('20') INTO vCodRetparam,dFechaparam, vrutaparam; 

		--let v_ruta = "/home/sysifx/hector/";
		let v_ruta =  vrutaparam;
		let v_ruta = trim(v_ruta);
		let vsSQL1 = 	'echo "UNLOAD TO ' || trim(v_ruta) || trim(v_nombreArchivo) || ' DELIMITER ' || '''|''' ;
		LET vsSQL1 = trim(vsSQL1);
		let cSql3 = ' SELECT Numcte,Nombre1,Nombre2,Apellido1,Apellido2,Calle,Numeroextcalle,Numerointcalle, ' ||
					' entre_calles,telefono_casa,colonia,delegacion_municipio,lugar_trabajo, ' ||
					' telefono_trabajo,extension_trabajo,numero_credito,tipodecliente,Situacioespecial, ' ||
					' estado_civil,tipo_casa,sexo,salarios_minimos,anio_alta,anio_nacimiento,saldo_actual, ' ||
					' saldo_vencido,fecha_ultimoabono,impte_ultimocompromiso,fecha_ultimocompac, ' ||
					' cumplio_convenio,num_avisos,Pagominimo,num_jefe,num_supervisor, "999-9999", ' ||
					' nom_ref,nom_calle_ref,num_ext_ref,num_int_ref,manzana_ref,entre_calles_ref,col_ref,' ||
					' delegacion_municipio_ref,telefono_ref,pago_vencido, ' ||
					' fecha_diaultimopago ||' || v_separador || '|| fecha_mesultimopago ||' || v_separador || '|| fecha_anioultimopago, ' ||
					' fecha_diaultimoacuerdo  ||' || v_separador || '||  fecha_mesultimoacuerdo  ||' || v_separador || '||  fecha_anioultimoacuerdo ' ||
					' FROM bdicobranza:cb_cteedocobloc;  '  ;
		LET vsSQL2 = ' " >' || trim(v_ruta ) || 'EdoCobranza.sql';
		LET cSql = vsSQL1 || cSql3 || vsSQL2;
		SYSTEM cSql;
		LET vsSQL1 = "";
		LET vsSQL1 = "dbaccess bdicobranza " || trim(v_ruta) ||  "EdoCobranza.sql";
	    SYSTEM vsSQL1;
		LET vsSQL1 = "";
	    LET vsSQL1 = "sed 's/|$//g' " || trim(v_ruta) || v_nombreArchivo || " > " || trim(v_ruta) || v_nombreArchivof;
	    SYSTEM vsSQL1;
	    LET vsSQL1 = '';
	    LET vsSQL1 = "rm " || trim(v_ruta) || v_nombreArchivo;
	    SYSTEM vsSQL1;
		 LET vsSQL1 = '';
	    LET vsSQL1 = "rm " || trim(v_ruta) || 'EdoCobranza.sql';
	    SYSTEM vsSQL1;
		
		UPDATE bdicobranza:cb_cteedocobloc set status = "PR" where status="NP";
	END IF;
	
	DROP TABLE paso_sitesp;
    RETURN P_COD_RET;
end;
end procedure
DOCUMENT
'AUTORES: Hector Manuel Bojorquez Ruelas','Jesus Manuel Aguilar Heredia',
'DESCRIPCION: GENERA EL ARCHIVO DE COBRANZA','BD: BDICOBRANZA','VERSION: 20100903.1757';

CREATE PROCEDURE "informix".sp_cilocobtenrespuestaedocob()
		RETURNING   CHAR(5) as Codigo,	--codret
					CHAR(75) as Descripcion;	---Declaracion de variables				
	DEFINE  cCodRet CHAR(5);
	DEFINE  cCodRet2 CHAR(5);
	DEFINE  iCont   INTEGER;
	DEFINE  iSqlErr INTEGER;
	DEFINE  cDescripcion CHAR(75);
	DEFINE  cNumcte CHAR(20);
	DEFINE  cUsuario CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSitEspecial CHAR(1);
	DEFINE sCausaSE SMALLINT;
	DEFINE cNumCredito  CHAR(20);
	DEFINE  cTipoMarca_loc CHAR(4); 
	DEFINE  cTipoMarca_tra CHAR(4);
	DEFINE  cTipoMarca_ref CHAR(4);
	DEFINE  vCausa SMALLINT;
	DEFINE  vSituacionEsp CHAR(1);

	--Se inicializan las variables

	LET cCodRet = '00000';
	LET cCodRet2 = '00000';
	LET iSqlErr = 0;
	LET icont=0;
	LET cDescripcion= 'PROCESO EXITOSO';
	LET cNumcte='';
	LET cUsuario='';
	LET cEmpresa='';
	LET cSitEspecial='';
	LET sCausaSE=0;
	LET cNumCredito='';
	LET cTipoMarca_loc =''; 
	LET cTipoMarca_tra ='';
	LET cTipoMarca_ref ='';
	LET vCausa=0;
	LET vSituacionEsp='';

	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_CiLocObtenRespuestaEdoCob.out';
	--TRACE ON;
	--------------------------------------------------------------------------	
	BEGIN
	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		LET cDescripcion='Error de Informix';
		RETURN cCodRet,cDescripcion;
	END EXCEPTION;		
	
	SET ISOLATION TO dirty READ; -- Lectura de tablas bloqueadas.
	--Se obtienen los valores que se encuentran parametrizados en la tabla cb_param que serán necesarios durante este proceso.
	SELECT NVL(valor,0)
	INTO cUsuario				--Usuario Necesario para la ejecución de los sps: sp_eliminarse y sp_sustituirse.
	FROM bdicobranza:cb_param 
	WHERE cod_param = '19';

	SELECT NVL(valor,0)
	INTO vCausa					--Causa Necesaria para la ejecucion del sp_sustituirse, Causa por la cual será reemplazada la anterior.
	FROM bdicobranza:cb_param 
	WHERE cod_param = '31';
	
	SELECT NVL(valor,0)
	INTO vSituacionEsp			--Situación Necesaria para la ejecucion del sp_sustituirse, Situacion por la cual será reemplazada la anterior.
	FROM bdicobranza:cb_param 
	WHERE cod_param = '30';

	---Se checa si existen clientes con situacion especial L 
	IF EXISTS(SELECT numcte FROM bdisitesp:se_ctessitespcte WHERE situacion in ('L')) THEN

	FOREACH WITH HOLD
		--Se obtiene un cliente, su empresa, situacion y causa , solo con situaciones L.
		SELECT NVL(empresa,0),NVL(numcte,0),NVL(situacion,0),NVL(causa,0)
		INTO cEmpresa,cNumcte,cSitEspecial,sCausaSE
		FROM bdisitesp:se_ctessitespcte
		WHERE situacion in ('L')
		--Se obtienen el numero de credito del cliente con los siguientes estatus: 'AA','BT','BA'
		SELECT NVL(num_credito,0) 
		INTO cNumCredito
		FROM bdicred:sd_maecred 
		WHERE numcte=cNumcte AND status_cred IN ('AA','BT','BA','E1','E2','E3');
			---Se checa si existe el cliente en el catalogo de marcas
			IF EXISTS (SELECT numcte FROM bdicobranza:cb_marcacliente WHERE numcte=cNumcte) THEN
				---Se obtiene el tipo de Marca de cada domicilio del cliente solo con estatus sin atender.
				SELECT NVL(Tipo_Marca,'')
				INTO cTipoMarca_loc
				FROM bdicobranza:cb_marcacliente
				WHERE numcte=cNumcte AND tipo_domicilio='1' AND estatus='SA'; 
	
				SELECT NVL(Tipo_Marca,'')
				INTO cTipoMarca_tra
				FROM bdicobranza:cb_marcacliente
				WHERE numcte=cNumcte AND tipo_domicilio='2' AND estatus='SA'; 
			
				SELECT NVL(Tipo_Marca,'')
				INTO cTipoMarca_ref
				FROM bdicobranza:cb_marcacliente
				WHERE numcte=cNumcte AND tipo_domicilio='3' AND estatus='SA'; 

				IF cTipoMarca_Loc IS NULL THEN 
				    LET cTipoMarca_Loc='PL';
				END IF;
				IF cTipoMarca_tra IS NULL THEN 
					LET cTipoMarca_tra='PL';
				END IF;
				IF cTipoMarca_ref IS NULL THEN 
					LET cTipoMarca_ref='PL';				
				END IF;
				
			--Significados de las marcas:
				--* CM.- Candidato a M 
				--* LV.- L a verificar 
				--* BL.- Borrar a L
				--* PL.- Sin repuesta
				
			--Se realiza las validaciones necesarias para determinar el resulta final del estado de cobranza		
			IF (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='PL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL') 
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
					OR (cTipoMarca_loc='LV' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL')
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL')					
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
					OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV') THEN

					---Se ejecuta el sp que inserta en la tabla cb_cteedocobloc por numero de cliente.
							EXECUTE PROCEDURE bdicobranza:sp_CiLocGeneraArchivoCobranza(cNumcte) INTO cCodRet2;
						CONTINUE FOREACH;
				
			ELIF (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV') 
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL') 
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM') 
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='BL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV') THEN 
					--En esta condicion se requiere realizar el desmarcaje del estatus L, debido a esto se hace el llamado al procedimiento que realiza dicha operación.
							EXECUTE PROCEDURE bdisitesp:sp_eliminarse(cNumcte,
								 cEmpresa,
								 cNumCredito,
								 cSitEspecial,
								 sCausaSE	,
								 cUsuario,
								 cUsuario,
								 1 ,	--1.- Cliente, 2.- Credito
								 1		--1.- Individual, 2.- General
								) INTO cCodRet2;
						
			ELIF (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM') THEN 
					--En esta condicion se requiere realizar el marcaje a estatus M, debido a esto se hace el llamado al procedimiento que realiza dicha operación.	
							EXECUTE PROCEDURE bdisitesp:sp_sustituirse(cNumcte,
								 cEmpresa,
								 cNumCredito,
								 vSituacionEsp,
								 vCausa,
								 cUsuario,
								 cUsuario,
								 1 	--1.- Cliente, 2.- Credito
								 ) INTO cCodRet2;
			
			ELIF (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='CM' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='LV' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='BL' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='CM' AND cTipoMarca_ref='PL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='LV')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='BL')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='CM')
				  OR (cTipoMarca_loc='PL' AND cTipoMarca_tra='PL' AND cTipoMarca_ref='PL') THEN 
					---Esta condición no realiza operación debido a que su resultado final es permanecer en estatus L.
			END IF;
		END IF;
		IF cCodRet2 <> 0 THEN
			LET cCodRet='00002'; 
			LET cDescripcion='En almenos algún llamado no se completo exitosamente';
		END IF;
	END FOREACH;
	ELSE
			LET cCodRet='00001';  
			LET cDescripcion='No Hay clientes con situacion especial';
	END IF;
	RETURN cCodRet,cDescripcion;
	END;	 
END PROCEDURE

DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Realiza un proceso de evaluacion final referente a los clientes con situacion especial',
'FECHA       : 31 de Agosto de 2010',
'VERSION     : 20100831.1230',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_clientevencido(pEmpresa CHAR(3), pNumCliente CHAR(20))

    RETURNING VARCHAR (6);

    -- 15/07/2008
    -- Creado por:
    -- Abraham Ayala Aguilar
    -- Consulta si el cliente tiene creditos vencidos.

	-- 10-10-2008
	-- Modifico:
	-- Abraham Ayala
	-- Se sustituyo la manera de consultar si el cliente tiene cuentas vencidas, ahora se calcula conforme a la fecha de vencido,
    -- atraves del SP_dias_vencido.

    -- 30-10-2008
    -- Modifico:
    -- Walberto Castro
    -- Se agrego la validacion de cuando los días vencidos sean mayor que 165 días se regrese el codigo de retorno 003.

    -- 12-06-2009
    -- Modifico:
    -- Bernardo Carlos Báez González
    -- Se modifico para revisar si el Cliente-Cuenta tiene un compromiso o acuerdo vigente y Marcar los compromisos cumplidos.
    -- Esto solo aplicara cuando se efectue un pago de tarjeta de credito en bdicred:sd_movdia para el cliente-Cuenta que se esta
    -- evaluando.
	--19-09-2012
	--Se depura codigo que no se utiliza y se agrega validación para tomar en cuenta solo creditos con estatus BA y BT para realizar convenios.

--DEFINICION DE VARIABLES--
    DEFINE vCod_Ret       VARCHAR (6);
    DEFINE iSqlErr        INTEGER;
    DEFINE vStatus       INTEGER;
    DEFINE vNumCredito    CHAR(20);
	DEFINE vmSuma   MONEY(18,2);
    DEFINE vmCatidadAcordada    MONEY(18,2);
    DEFINE vdFechaAcuerdo DATE;

--    Set debug file to '/tmp/sp_clientevencido_pba.out';
--    trace on;

    BEGIN
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                LET vCod_Ret = iSqlErr;
                RETURN vCod_Ret;
            END IF;
        END EXCEPTION;


--INICIALIZACION DE VARIABLES--
        LET vCod_Ret = "000";   --No tiene cuentas vencidas
        LET vmSuma = 0.00;
        LET vmCatidadAcordada = 0.00;
		

        IF (pEmpresa IS NOT NULL and pEmpresa <> '') AND (pNumCliente IS NOT NULL and pNumCliente <> '') THEN

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		       FOREACH
			   
                SELECT a.num_credito INTO vNumCredito
                FROM bdicred:"informix".sd_maecred a
				INNER JOIN bdicred:sd_maesdos b ON b.num_credito = a.num_credito
                WHERE a.empresa = pEmpresa AND a.numcte = pNumCliente
				AND a.status_cred IN ('BA','BT','E1','E2','E3')       -- solo se deben de realizar convenios sobre creditos BT y  BA
				AND (b.monto_vencido + b.mto_venc_trasp) > 0
				
				
				
						EXECUTE PROCEDURE bdicred:"informix".sp_dias_vencido(pEmpresa, vNumCredito) INTO vCod_Ret, vStatus;

						IF EXISTS(SELECT * FROM bdicobranza:"informix".cb_compac WHERE empresa= '001' AND numcliente = pNumCliente) THEN
							LET vCod_Ret = "004";   --Tiene convenio vigente
							Return vCod_Ret;
						END IF;

						IF vCod_Ret = '000' THEN
								IF vStatus > 0 THEN
								   
										LET vCod_Ret = "001";   --Tiene cuentas vencidas
									
								END IF;
						ELSE
							
							LET vCod_Ret = "002";   --Error al calcular dias vencidos
							
							
						END IF;
						
						Return vCod_Ret;
						
            END FOREACH;

        ELSE

            LET vCod_Ret = "999";   --Faltan valores

        END IF;

        RETURN vCod_Ret;

    END;

END PROCEDURE;