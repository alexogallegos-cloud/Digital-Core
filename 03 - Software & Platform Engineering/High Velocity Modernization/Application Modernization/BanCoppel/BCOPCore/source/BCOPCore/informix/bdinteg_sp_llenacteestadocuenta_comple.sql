CREATE PROCEDURE "informix".sp_llenacteestadocuenta_comple()
returning char (50);
--Martha Aguirre
--08-Sep-09
--Se agrega filtro por tipo de ingreso en la búsqueda de tabla si_ingresos
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
define cDiaUltimoCompac,cMesUltimoCompac,cCausasituacionespecial            char(2);
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
define cSql                                                                 char(2500);
define cpagominimo,cSalvenci,cMoraaux,cInteresaux,cInteresV                 money(18,2);
define vmensualidades_min,vmensualidades_max,salariominban                  integer;
define cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4          money(18,2);
define cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2  money(18,2);
define cInteresmoratorio3,cInteresmoratorio4                                money(18,2);
define cInteresmoratorio5,cInteresmoratorio6,cproyecmora                    decimal(18,2);
define ctasamora                                                            decimal(9,6);
DEFINE sPaso                                                                SMALLINT; --CAS
    DEFINE SQL_ERR,ISAM_ERR          INTEGER;
    DEFINE ERROR_INFO,P_MENSAJE      VARCHAR(80);
    DEFINE P_COD_RET                 VARCHAR(5);

BEGIN 
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        -- ROLLBACK WORK;
        if P_COD_RET = -668 then
            RETURN "No copio el archivo al servidor destino " ||  P_COD_RET;
        else
            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_creda';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE sd_paso_creda;
            END IF;
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
--FIN CAS
LET  cSQL = ""; LET  vTotalCommit=0; LET  vmensualidades_min = 0; LET  vmensualidades_max = 0; LET  var_rga = ""; LET  vfechavenci=date(0); 

set isolation to dirty read;

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
    LET  cNombreArchivo2 = 'CifraAbogadoBancoppel' || LPAD(TRIM(MONTH(vfecha_hoy)::CHAR(2)),2,'0') || substr(YEAR(vfecha_hoy),3,2) || '.txt';
    --Begin Work;
    Let P_cod_ret = "00000";
    truncate bdinteg:si_cteestadocuenta;
    truncate bdinteg:si_cifracontrolabogado;
---INI NO SE IMPRIMEN EDOCOBRANZA SI PRESENTAN SITUACION ESPECIAL
            SELECT COUNT(tabid) INTO sPaso FROM systables WHERE tabname= 'sd_paso_creda';
            IF NVL(sPaso,0) > 0 THEN
                DROP TABLE "informix".sd_paso_creda;
            END IF;
                CREATE TABLE "informix".sd_paso_creda 
                (num_credito CHAR(20));
            select numcred 
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
              and instruccion = '0')
            group by 1
            into temp paso_sitesp with no log;
            insert into "informix".sd_paso_creda
            select * from paso_sitesp group by 1;
            create unique index inx_sd_paso_cred on "informix".sd_paso_creda(num_credito);
            UPDATE STATISTICS medium FOR TABLE "informix".sd_paso_creda;    
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
        join bdicred:sd_valedocta edo on (mcr.empresa = edo.empresa and mcr.num_credito = edo.num_credito and fecha_proc = mdy('02','25','2010'))
        LEFT OUTER JOIN  bdicred:sd_maecredanexo mca ON (mcr.empresa = mca.empresa and  mca.num_credito = mcr.num_credito)
        LEFT OUTER JOIN  bdicred:sd_tarjeta tar ON 
                         (mcr.empresa = tar.empresa 
                          and tar.num_credito = mcr.num_credito 
                          and tar.tipo_tarjeta = 'T' 
                          and tar.status_tar = 'A' 
                          and secuencia = (select max(secuencia) from bdicred:sd_tarjeta where mcr.empresa = empresa and mcr.num_credito = num_credito and tipo_tarjeta = 'T' and status_tar = 'A'))
        LEFT OUTER JOIN  bdicred:sd_maesdos msd ON (mcr.empresa = msd.empresa and  msd.num_credito = mcr.num_credito)
        where  mcr.empresa = '001'
           -- IFRS Se contempla el nuevo estatus por Etapas and mcr.status_cred = 'BT'
		   and mcr.status_Cred IN ('BT','E2','E3')
           and mcr.num_credito not in (select num_credito from sd_paso_creda) --CAS NO SE IMPRIMEN EDOCOBRANZA SI PRESENTAN SITUACION ESPECIAL
           and msd.monto_financiado >= 150
           and  (select count(*)
                 from bdicred:sd_amortiza_credito amor
                where mcr.empresa = amor.empresa
                  and mcr.num_credito = amor.num_credito
				  --IFRS se comenta linea para contemplar status 6 and amor.capital_status in (2,7)
                  and amor.capital_status in (2,7,6)
                  and fecha_cuota >= date(0)) >= vmensualidades_min
          and  (select count(*)
                 from bdicred:sd_amortiza_credito amor
                where mcr.empresa = amor.empresa
                  and mcr.num_credito = amor.num_credito
				  --IFRS se comenta linea para contemplar status 6 and amor.capital_status in (2,7)
                  and amor.capital_status in (2,7,6)
                  and fecha_cuota >= date(0)) <= vmensualidades_max
--         and mcr.sucursal in ('0183','0210','0182','0037')
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
        SELECT limit 1
        lpad(TRIM(cte.sucursal),4,'0') AS sucursal,         -- sucursal
        rpad(TRIM(cte.nombre1),20,' ') AS nombre1,      -- nombre 1
        rpad(TRIM(cte.nombre2),20,' ') AS nombre2,      -- nombre 2
        rpad(TRIM(cte.apell_paterno),20,' ') AS apellpaterno,       --apellido 1
        rpad(TRIM(cte.apell_materno),20,' ') AS apellmaterno,     --apellido 2
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
        rpad(TRIM(dir.telefono1),13,' ') AS tel_casa,   -- telefono casa
        rpad(TRIM(dir.telefono3),13,' ') AS tel_trabajo, -- telefono trabajo
        rpad(TRIM(dir.extension),5,' ') AS ext_trabajo,     -- extension trabajo
        rpad(TRIM(dir.telefono2),13,' ') AS celular,    -- celular
        rpad(TRIM(ctepf.estado_civil),2,' ') AS edo_civil,      -- estado  civil
        TRIM(decode(ctepf.habita_en,'01','P','02','R','03','F','04','G','05','H',ctepf.habita_en)) AS tipo_casa,     -- tipo de casa
        rpad(TRIM(ctepf.sexo),1,' ') AS sexo,   --sexo
        lpad(year(cte.fecha_alta),4,'0') AS ayoalta,    -- año de alta
        lpad(year(ctepf.fecha_nac),4,'0') AS ayonac,    -- año de nacimiento
        lpad(dir.numerociudad,4,'0') AS numciudad,  -- numero ciudad cliente
        lpad(zon.centro,6,'0') AS numcentro, -- numero de centro
        lpad(zon.jefegrupozona,8,'0') AS numjefe, -- numero de jefe
        lpad(zon.supervisorzona,8,'0') AS numsupervisor, -- numero de supervisor
        lpad(dir.numerocolonia,4,'0') AS numcolonia,  -- numero de colonia de cliente
        lpad(dir.numerocalle,6,'0') AS numcalle,  -- numero de calle de cliente
        nvl(rpad(TRIM(ing.nombre_empresa),25,' '),' ') AS lugartrabajo    -- lugar de trabajo
        Into cSucursal, cNombre1, cNombre2, cApellido1, cApellido2, cNombreCalle, cNumExterior, cNumInterio, cColonia,
        cManzana, cOtros, cAndador, cEtapa, cLote, cEdificio, cEntrada, cDepartamento, cCodPostal, cPuntoCardinal, cComplemento,
        cEntreCalles, cDelegacionMunicipio, cEstado, cTelefonoCasa, cTelefonoTrabajo, cExtensionTrabajo, cCelular,     
        cEstadoCivil, cTipoCasa, cSexo, cAnioAlta, cAnioNacimiento, cNumCiudadCte, cNumCentro, cNumJefe, cNumSupervisor,
        cNumColoniacte, cNumCalleCte, cLugarTrabajo
        FROM bdinteg:si_cliente cte
        LEFT OUTER JOIN bdinteg:si_ctepf ctepf ON (ctepf.numcte = cte.numcte)
        LEFT OUTER JOIN bdinteg:si_direcciones  dir ON (dir.numcte = cte.numcte)
        LEFT OUTER JOIN bdinteg:si_catcalles calle ON (dir.numerocalle = calle.numerocalle)
        LEFT OUTER JOIN bdinteg:si_catzonas zon ON (zon.numerociudad = dir.numerociudad and  zon.numerocolonia = dir.numerocolonia )
        LEFT OUTER JOIN bdinteg:si_catciudades ciudad ON (ciudad.numerociudad = dir.numerociudad)
        LEFT OUTER JOIN bdinteg:si_estados edo ON (edo.estado = dir.estado)
        LEFT OUTER JOIN bdinteg:si_ingresos ing ON (ing.numcte= cte.numcte AND ing.tipo_ingreso = 'T' and ing.sec_ingreso= (select max(ing1.sec_ingreso) from bdinteg:si_ingresos ing1 where ing1.numcte= cte.numcte and ing1.tipo_ingreso= 'T'))
        WHERE cte.numcte = cNumCliente		
        and dir.tipo_dir = 1
        and dir.secuencia = ( Select max(secuencia)
                              From bdinteg:si_direcciones dir1 Where dir1.tipo_dir = '1' and dir1.numcte = cNumCliente );
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
        and dir.tipo_dir = 2
        and dir.secuencia = ( Select max(secuencia)
                              From bdinteg:si_direcciones 
                              Where tipo_dir = '2' and numcte = cNumCliente );
        Select iva
        Into mIvaSucursal
        From bdinteg:si_sucursales
        Where sucursal = cSucursal;
        LET sAbonosVdos=0; LET cSaldovencido1=0; LET cSaldovencido2=0; LET cSaldovencido3=0; LET cSaldovencido4=0;
        LET cSaldovencido5=0; LET cSaldovencido6=0; LET cInteresmoratorio2=0; LET cInteresmoratorio3=0;
        LET cInteresmoratorio4=0; LET cInteresmoratorio5=0;  LET cInteresmoratorio6=0; LET cInteresV=0; LET cproyecmora=0;
		
       FOREACH
            Select nvl((capital_debe-capital_pagado),0), 
            NVL(((mora_provi_ordi+mora_provi_cope+mora_sdo_ordi-mora_sdo_ordi_pag+mora_sdo_cope-mora_sdo_cope_pag)*(1 + s.iva)),0),
            NVL((interes_debe-interes_pagado+iva_debe-iva_pagado),0)            
            Into cSalvenci,cMoraaux,cInteresaux
            From  bdicred:sd_amortiza_credito b,bdicred:sd_maecred a, bdinteg:si_sucursales s
            Where b.empresa= cEmpresa 
			And b.num_credito = a.num_credito
			AND a.sucursal = s.sucursal
			And b.num_credito = cNumCredito 
			--IFRS se comenta linea para contemplar status 6 b.capital_status in (2,7)
			And b.capital_status in (2,7,6)
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
                    LET sNumAvisos='V';
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
        LET cSituacionEspecial="";         LET cCausasituacionespecial="";
        SELECT situacion,causa
        INTO cSituacionEspecial,cCausasituacionespecial
        FROM bdisitesp:se_ctessitespcte
        WHERE numcte = cNumCliente;
        
        IF cSituacionEspecial IS NULL or cSituacionEspecial="" THEN LET cSituacionEspecial="-"; END IF;
        IF cCausasituacionespecial IS NULL or cCausasituacionespecial="" THEN LET cCausasituacionespecial="000"; END IF;
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
        IF vTotalCommit=0 THEN
            begin work;
        END IF;
        Insert into bdinteg:si_cteestadocuenta(
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
        interesmoratorio6,fecha_movto)
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
        cTipodecliente,cCausasituacionespecial,sAbonosVdos, sNumAvisos, cNombreRef, cNomCalleRef, cNumExtRef, cNumIntRef, cColRef, 
        cManzanaRef, cOtrosRef, cAndadorRef,cEtapaRef, cLoteRef, cEdificioRef, cEntradaRef, cDeptoRef, cCpRef, cPuntoCardinalRef,
        cComplementoRef, cEntreCallesRef,cDelegacionMunicipioRef, cEstadoRef,cTelefonoRef, cNumCiudadRef,
        cNumColoniaRef, cNomConyugeoFamiliar, cTelConyugeoFamiliar,cSaldovencido1,cSaldovencido2,cSaldovencido3,cSaldovencido4,
        cSaldovencido5,cSaldovencido6,cInteresmoratorio1,cInteresmoratorio2,cInteresmoratorio3,cInteresmoratorio4,cInteresmoratorio5,
        cInteresmoratorio6, vfecha_hoy);
       LET vTotalRegistros = vTotalRegistros +1;
        LET vTotalCommit=vTotalCommit+1;
        IF vTotalCommit=1000 THEN
            COMMIT WORK;
            update statistics medium for table bdinteg:si_cteestadocuenta;
            LET vTotalCommit=0;
        END IF;
    End ForEach;
    IF vTotalCommit>0 THEN
       COMMIT WORK;
       update statistics medium for table bdinteg:si_cteestadocuenta;
    END IF; 
    Insert into si_cifracontrolabogado(empresa, numero_registros, saldo_total, saldo_vencido, saldo_moratorio, fecha_movto)
    values('001', vTotalRegistros, mSaldoTotalAcumulado, mSaldoVencidoAcumulado, mSaldoMoratorioAcumulado , vfecha_hoy);
           let cSql = "";
            let cSql = ' UNLOAD TO ' || '''CtaAbogadoRegistros.unl''' || ' DELIMITER ' || '''"|"''';
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  SELECT nvl"("c.numcte,' || '''" "''' || '")", nvl"("c.sucursal,' || '''" "''' || '")",';
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.nombre1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ';
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.nombre2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ';
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.apellido1,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.apellido2,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.calle,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.numeroextcalle,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.numerointcalle,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.colonia,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.manzana,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.otros,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.andador,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.etapa,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.lote,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.edificio,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.entrada,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.departamento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.cod_postal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.puntocardinal,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.complemento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.entre_calles,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.delegacion_municipio,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.estado,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.telefono_casa,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.telefono_trabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.extension_trabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.celular,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.lugar_trabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.nombrecalletrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.numeroexteriortrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.numerointeriortrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.coloniatrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.manzanatrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.otrostrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.andadortrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.etapatrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.lotetrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.edificiotrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.entradatrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.departamentotrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.codigopostaltrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.puntocardinaltrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.complementotrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.entrecallestrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.delegacion_municipiotrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.estadotrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.numerociudadtrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.numerocoloniatrabajo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.numero_credito,' || '''" "''' || '")", nvl"("c.num_tarjeta_credito,' || '''" "''' || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.situacioespecial,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.estado_civil,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.tipo_casa,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.sexo,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.salarios_minimos,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.anio_alta,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.anio_nacimiento,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.saldo_actual,0")", nvl"("c.saldo_vencido,0")", nvl"("c.saldo_moratorio,0")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.pagominimo,0")", nvl"("c.fecha_ultimoabono,date"("1")"")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.impte_ultimocompromiso,' || '''" "''' || '")", nvl"("c.fecha_ultimocompac,date"("1")"")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.plazo_compromiso,' || '''" "''' || '")", nvl"("c.impte_compromisocumplido,' || '''" "''' || '")", '; 
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.fecha_cumpliocompromiso,date"("1")"")", nvl"("c.cumplio_convenio,''"-"''")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_ciudadcte,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_centro,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_jefe,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_supervisor,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_coloniacte,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_callecte,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_casacte,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.pago_vencido,0")", nvl"("c.fecha_diaultimopago,' || '''" "''' || '")", nvl"("c.fecha_mesultimopago,' || '''" "''' || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.fecha_anioultimopago,' || '''" "''' || '")", nvl"("c.fecha_diaultimoacuerdo,' || '''" "''' || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.fecha_mesultimoacuerdo,' || '''" "''' || '")", nvl"("c.fecha_anioultimoacuerdo,' || '''" "''' || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.tipodecliente,' || '''" "''' || '")", nvl"("c.causasituacionespecial,' || '''" "''' || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.abonos_vdos,0")", nvl"("c.num_avisos,0")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.nom_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.nom_calle_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_ext_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_int_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.col_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.manzana_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.otros_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.andador_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.etapa_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.lote_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.edificio_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.entrada_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.depto_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.cp_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.punto_cardinal_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.complemento_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.entre_calles_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.delegacion_municipio_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.estado_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.telefono_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_ciudad_ref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.num_coloniaref,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.nom_conyugeofamiliar,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("replace"("replace"("c.tel_conyugeofamiliar,' || '''"|"'''  || ', ' || '''" "''' || '")",' || '''"\"'''  || ',' || '''" "'''  || '")", ' || '''" "'''  || '")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.saldovencido1,0")", nvl"("c.saldovencido2,0")", nvl"("c.saldovencido3,0")", nvl"("c.saldovencido4,0")", nvl"("c.saldovencido5,0")", nvl"("c.saldovencido6,0")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.interesmoratorio1,0")", nvl"("c.interesmoratorio2,0")", nvl"("c.interesmoratorio3,0")", ' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  nvl"("c.interesmoratorio4,0")", nvl"("c.interesmoratorio5,0")", nvl"("c.interesmoratorio6,0")"' ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  FROM bdinteg:si_cteestadocuenta c WHERE year"("c.fecha_movto")" = ' || year(vfecha_hoy) ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  and month"("c.fecha_movto")" = ' || month(vfecha_hoy) ;
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            let cSql =  '  and day"("c.fecha_movto")" = ' || day(vfecha_hoy) || '";"';
            call bdicred:sp_genera_archivo ('EstadoCtaAbogado.sql',cSql) returning var_rga;
            LET cSql = '';
            LET cSql = 'dbaccess bdinteg EstadoCtaAbogado.sql';
            SYSTEM cSql;
            LET cSql = "sed 's/|$//g' CtaAbogadoRegistros.unl > paso001.txt ";
            SYSTEM cSql;                                   
            LET cSql = '';
            LET cSql = "sed 's/" || '"' ||  "//g' paso001.txt > " || cNombreArchivo;
            SYSTEM cSql;
            LET cSql = '';
-- Generacion del Archivo de Cifras Control Abogado.. 
            let cSql = 'echo "UNLOAD TO ' || '''CifrasControlAbogadoRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
                        ' SELECT d.numero_registros, d.saldo_total, d.saldo_vencido, d.saldo_moratorio, d.fecha_movto ' ||
                        ' FROM bdinteg:si_cifracontrolabogado d WHERE year(d.fecha_movto) = ' || year(vfecha_hoy) || 
                        ' and month(d.fecha_movto) = ' || month(vfecha_hoy)||' and day(d.fecha_movto) = ' || day(vfecha_hoy) || ';' ||
                        ' " > CifrasControlAbogado.sql';
            SYSTEM cSql; 
            LET cSql = '';
            LET cSql = 'dbaccess bdinteg CifrasControlAbogado.sql';
            SYSTEM cSql; 
            LET cSql = "sed 's/|$//g' CifrasControlAbogadoRegistros.unl > " || cNombreArchivo2;
            SYSTEM cSql; 
            LET cSql = '';
            LET cSql = 'rm EstadoCtaAbogado.sql CtaAbogadoRegistros.unl CifrasControlAbogadoRegistros.unl CifrasControlAbogado.sql paso001.txt';
            SYSTEM cSql; 
            LET cSql = '';
            LET cSql = "cp " || trim(cNombreArchivo) || " /resplogifx/archivoscartera";
            SYSTEM cSql; 
            LET cSql = "cp " || trim(cNombreArchivo2) || " /resplogifx/archivoscartera";
            SYSTEM cSql;
            LET cSql = '';
             LET cSql = '';
             LET cSql = 'rm '|| trim(cNombreArchivo2) ||' '||trim(cNombreArchivo);
            SYSTEM cSql;

    DROP TABLE sd_paso_creda;

    RETURN P_COD_RET; 
end;
end procedure;