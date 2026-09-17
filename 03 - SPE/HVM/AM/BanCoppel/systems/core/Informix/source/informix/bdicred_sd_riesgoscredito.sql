CREATE PROCEDURE "informix".sd_riesgoscredito()
RETURNING CHAR(70);

--------------------------------------------------------------
--ACTIVIDAD:Recopila los datos de credito del cliente y los
--guarda en la tabla sd_riesgoscred. Borra la tabla primero
--y despues inserta en ella.
--------------------------------------------------------------

--Definicion de variables
DEFINE    chrcodret             CHAR(70);
DEFINE    chrcodret1            CHAR(5);
DEFINE    chrnumcredito         CHAR(20);
DEFINE    chrnumcte             CHAR(20);
DEFINE    chrcalifant           CHAR(2);
DEFINE    chrcalifactual        CHAR(2);
DEFINE    chractividad          CHAR(3);
DEFINE    chrocupacion          CHAR(30);
DEFINE    chrtipores            CHAR(40);
DEFINE    chredocivil           CHAR(2);
DEFINE    chrsexo               CHAR(1);
DEFINE    chrciudad             CHAR(15);
DEFINE    chrsucursal           CHAR(4);
DEFINE    chrdescstatus         CHAR(60);

DEFINE    intcodret             INTEGER;

DEFINE    intnumperiodos        SMALLINT;
DEFINE    intciclosmora         SMALLINT;
DEFINE    inttiempodomact       SMALLINT;
DEFINE    intdependientes       SMALLINT;
DEFINE    intnumpagos           SMALLINT;
--jom
DEFINE    intnumpagosvenc       SMALLINT;
--jom

DEFINE    decsaldodisp          DECIMAL(18,2);
DEFINE    decmontovenc          DECIMAL(18,2);
DEFINE    decmtovenctrasp       DECIMAL(18,2);
DEFINE    decpagominimo         DECIMAL(18,2);
DEFINE    deceficpond           DECIMAL(5,2);
DEFINE    declincred            DECIMAL(18,2);
DEFINE    dectasainteres        DECIMAL(9,6);
DEFINE    deccapvgte            DECIMAL(18,2);
DEFINE    decintvgte            DECIMAL(18,2);
DEFINE    decintvcdotrans       DECIMAL(18,2);
DEFINE    decintvcdotrasp       DECIMAL(18,2);
DEFINE    deccapvenctraspnoexig DECIMAL(18,2);
DEFINE    decivaintereses       DECIMAL(14,2);
DEFINE    decintmora            DECIMAL(18,2);
DEFINE    deccompendientes      DECIMAL(18,2);
DEFINE    decivacom             DECIMAL(18,2);
DEFINE    decpagosacum          DECIMAL(18,2);
DEFINE    deccargosacum         DECIMAL(18,2);
DEFINE    dectotalcap           DECIMAL(18,2);
DEFINE    dectotalint           DECIMAL(18,2);
DEFINE    dectotalotros         DECIMAL(18,2);
DEFINE    decsdonoexig          DECIMAL(18,2);

DEFINE    vchrtiempotrabact     VARCHAR(80);
DEFINE    vchrtiempotrabant     VARCHAR(80);

DEFINE    dtefechanac           DATE;
DEFINE    dtefechaalta          DATE;
DEFINE    dtefecprimermov       DATE;
DEFINE    dtefecultmov          DATE;
DEFINE    dtefechahoy           DATE;
DEFINE    dtefechavencto        DATE;
DEFINE    dtefechaayer          DATE;
DEFINE    dtefechacuota         DATE;

--DEBUG FLAG
--SET debug file to "sd_riesgoscredito.out";
--TRACE ON;

set isolation to dirty read;
--set pdqpriority 20;
--set lock mode to wait 5;
--lock mode page;

BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret=intcodret;
            RETURN chrcodret;
		END IF;
    END EXCEPTION;

    --Inicializacion de variables
    LET    chrcodret            ="000";
    LET    chrnumcredito        ="";
    LET    chrnumcte            ="";
    LET    chrcalifant          ="";
    LET    chrcalifactual       ="";
    LET    chractividad         ="";
    LET    chrocupacion         ="";
    LET    chrtipores           ="";
    LET    chredocivil          ="";
    LET    chrsexo              ="";
    LET    chrciudad            ="";
    LET    chrsucursal          ="";
    LET    chrdescstatus        ="";

    LET    intcodret            =0;

    LET    intnumperiodos       =0;
    LET    intciclosmora        =0;
    LET    inttiempodomact      =0;
    LET    intdependientes      =0;
    LET    intnumpagos          =0;
--jom
    LET    intnumpagosvenc      =0;
--jom

    LET    decsaldodisp         =0;
    LET    decmontovenc         =0;
    LET    decmtovenctrasp      =0;
    LET    decpagominimo        =0;
    LET    deceficpond          =0;
    LET    declincred           =0;
    LET    dectasainteres       =0;
    LET    deccapvgte           =0;
    LET    decintvgte           =0;
    LET    decintvcdotrans      =0;
    LET    decintvcdotrasp      =0;
    LET    deccapvenctraspnoexig=0;
    LET    decivaintereses      =0;
    LET    decintmora           =0;
    LET    deccompendientes     =0;
    LET    decivacom            =0;
    LET    decpagosacum         =0;
    LET    deccargosacum        =0;
    LET    dectotalcap          =0;
    LET    dectotalint          =0;
    LET    dectotalotros        =0;
    LET    decsdonoexig         =0;

    LET    vchrtiempotrabact    ="";
    LET    vchrtiempotrabant    ="";

--    drop table sd_riesgoscred;
    TRUNCATE TABLE sd_riesgoscred;

{    CREATE TABLE sd_riesgoscred ( 
        empresa           	CHAR(3),
        numcredito        	CHAR(20),
        numcte            	CHAR(20),
        califant          	CHAR(2),
        califactual       	CHAR(2),
        numperiodos       	SMALLINT,
        saldodispuesto    	DECIMAL(18,2),
        pagominimo        	DECIMAL(18,2),
        eficponderada     	DECIMAL(5,2),
        lincred           	DECIMAL(18,2),
        tasainteres       	DECIMAL(9,6),
        ciclosmora        	SMALLINT,
        fechaalta         	DATE,
        sucursal          	CHAR(4),
        fecprimermov      	DATE,
        fecultmov         	DATE,
        pagosmes          	DECIMAL(18,2),
        numpagos          	SMALLINT,
        numpagosvenc      	SMALLINT,
        cargosmes         	DECIMAL(18,2),
        capvgte           	DECIMAL(18,2),
        capvenctrans      	DECIMAL(18,2),
        capvenctrasp      	DECIMAL(18,2),
        capvenctraspnoexig	DECIMAL(18,2),
        totalcap          	DECIMAL(18,2),
        intvgte           	DECIMAL(18,2),
        intvcdotrans      	DECIMAL(18,2),
        intvcdotrasp      	DECIMAL(18,2),
        ivaintereses      	DECIMAL(14,2),
        totalint          	DECIMAL(18,2),
        interesesmora     	DECIMAL(18,2),
        compend           	DECIMAL(18,2),
        ivacom            	DECIMAL(18,2),
        totalotros        	DECIMAL(18,2),
        statuscred        	CHAR(60),
--        actividad         	CHAR(3),
--        ocupacion         	CHAR(30),
--        tiporesidencia    	CHAR(40),
--        edocivil          	CHAR(2),
--        sexo              	CHAR(1),
--        tiempodomact      	SMALLINT,
--        tiempotrabact     	VARCHAR(80),
--        tiempotrabant     	VARCHAR(80),
--        dependientes      	SMALLINT,
        ciudad            	CHAR(15),
--        fechanac          	DATE,
        fechainsert       	DATE 
        );

    alter table sd_riesgoscred TYPE (RAW);
}

    SELECT fecha_hoy,fecha_ant INTO dtefechahoy,dtefechaayer FROM bdicred:sd_fechas;

    Let chractividad = "";
    let dtefechaalta = date(1);
    let chredocivil = "";
    let chrsexo = "";
    let chrtipores = "";
    let inttiempodomact = 0;
    let chrocupacion = "";
    let dtefechanac = date(1);
    let intdependientes = 0;
    let dtefechanac = date(1);


	FOREACH

        SELECT 
               mae.num_credito, NVL(mae.tasa_interes,0), mae.numcte, NVL(mae.sucursal,''), NVL(sdo.sdo_cap_insoluto,0),
               NVL(sdo.monto_vencido,0), NVL(sdo.mto_venc_trasp,0), NVL(sdo.monto_financiado,0), NVL(sdo.monto_otorgado,0),
               NVL(sdo.sdo_contab_mora,0), NVL(sdo.sdo_capital,0),NVL(sdo.mto_venc_int,0),
               NVL(sdo.cap_tras_no_venci,0),NVL(sdo.mto_venc_tra_int,0),NVL(tip.descripcion,''),NVL(sdo.sdo_no_exig,0)
        INTO chrnumcredito,dectasainteres,chrnumcte,chrsucursal,decsaldodisp,
             decmontovenc,decmtovenctrasp,decpagominimo,declincred,
             decintmora,deccapvgte,decintvcdotrans,
             deccapvenctraspnoexig,decintvcdotrasp,chrdescstatus,decsdonoexig
        FROM sd_maecred mae
        INNER JOIN sd_maesdos     sdo ON (sdo.num_credito=mae.num_credito   AND sdo.empresa=mae.empresa)
        INNER JOIN sd_tipocartera tip ON (tip.status_cred = mae.status_cred AND tip.empresa=mae.empresa)
        WHERE mae.status_cred <> 'CC'AND mae.empresa = '001'

        --Obtiene calificacion de cartera
        SELECT FIRST 1 NVL(calif_ant,''),NVL(calif_actual,''),NVL(num_periodos,0)
        INTO chrcalifant,chrcalifactual,intnumperiodos
        FROM bdicred:sd_histvalcon
        WHERE empresa = '001' AND num_credito = chrnumcredito AND fecha_alta =
        (
            SELECT MAX(fecha_alta) FROM bdicred:sd_histvalcon WHERE empresa = '001' AND num_credito = chrnumcredito
        );

        IF chrcalifant IS NULL THEN
            LET chrcalifant = '';
        END IF;

        IF chrcalifactual IS NULL THEN
            LET chrcalifactual = '';
        END IF;

        IF intnumperiodos IS NULL THEN
            LET intnumperiodos = 0;
        END IF;

        --Obtiene datos socioeconomicos del cliente
--        SELECT FIRST 1 cli.actividad_princ,cli.fecha_alta,cte.estado_civil,cte.sexo,hab.descripcion,
--               cte.anios_habita,pro.descripcion,cte.fecha_nac,cte.dependientes
--        INTO chractividad,dtefechaalta,chredocivil,chrsexo,chrtipores,
--            inttiempodomact,chrocupacion,dtefechanac,intdependientes
--        FROM bdinteg:si_cliente cli
--        LEFT OUTER JOIN bdinteg:si_ctepf cte ON(cli.empresa=cte.empresa AND cli.numcte=cte.numcte)
--        LEFT OUTER JOIN bdinteg:si_profesion pro ON(cte.profesion=pro.profesion)
--        LEFT OUTER JOIN bdinteg:si_habitaen hab ON(cte.empresa=hab.empresa AND cte.habita_en=hab.habita_en)
--        WHERE cli.empresa = '001' AND cli.numcte = chrnumcte;


        --Obtiene el interes vigente
--        SELECT MIN(s.fecha_cuota) INTO dtefechacuota
--        FROM sd_pagocapit s, sd_fechas d
--        WHERE s.num_credito = chrnumcredito AND s.fecha_cuota >= d.fecha_hoy;

--        IF dtefechacuota IS NOT NULL THEN
--            SELECT NVL(monto_cuota - monto_real_pag, 0) INTO decintvgte
--            FROM bdicred:sd_paginter
--            WHERE num_credito = chrnumcredito AND fecha_cuota = dtefechacuota;
--        ELSE
            LET decintvgte = decsdonoexig;
--        END IF;

        IF decintvgte IS NULL THEN
            LET decintvgte = 0;
        END IF;

        --Obtiene el IVA de los intereses
        SELECT NVL(SUM(iva_debe - iva_pagado),0) INTO decivaintereses
        FROM bdicred:sd_amortiza_credito WHERE num_credito = chrnumcredito AND empresa ='001';

        --Obtiene las Comisiones Pendientes e Iva de las Comisiones
        SELECT NVL(SUM(DECODE(tc.comi_o_seg, '1', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0) AS com_pend,
               NVL(SUM(DECODE(tc.comi_o_seg, '4', NVL(dc.monto_com,0) - NVL(dc.monto_pag,0), 0)),0) AS iva_com
        INTO deccompendientes,decivacom
        FROM bdicred:sd_detcomi dc, bdicred:sd_tpcomis tc
        WHERE dc.empresa = '001' AND dc.num_credito = chrnumcredito AND dc.estado_com = 'A'
        AND dc.empresa = tc.empresa AND dc.cod_comis = tc.cod_comis AND tc.comi_o_seg in ('1','4');

        --Obtiene totales de capital, interes y otros
        LET dectotalcap = deccapvgte + decmontovenc + decmtovenctrasp + deccapvenctraspnoexig;
        LET dectotalint = decintvgte + decintvcdotrasp + decintvcdotrans + decivaintereses;
        LET dectotalotros = decintmora + deccompendientes + decivacom;

        --Obtiene la fecha del primer y ultimo movimiento
        SELECT MAX(fecha_mov),MIN(fecha_mov) INTO dtefecultmov,dtefecprimermov
        FROM bdicred:sd_movhis WHERE empresa='001' AND num_credito = chrnumcredito;

         --Obtiene la ciudad del cliente
        SELECT FIRST 1 a.nombreciudad INTO chrciudad
        FROM bdinteg:si_catciudades a,bdinteg:si_direcciones b
        WHERE b.numcte = chrnumcte AND b.numerociudad = a.numerociudad
        AND b.tipo_dir = '1' AND b.secuencia = 1;

        --Obtiene la fecha de vencimiento para obtener los ciclos en mora
        SELECT FIRST 1 fecha_vencto INTO dtefechavencto FROM bdicred:sd_maecredanexo
        WHERE empresa='001' AND num_credito = chrnumcredito;

        IF dtefechahoy IS NOT NULL AND dtefechavencto IS NOT NULL THEN
            LET intciclosmora = ( dtefechahoy - dtefechavencto ) / 30;
        ELSE
            LET intciclosmora = 0;
        END IF;

        --Obtiene el saldo vencido del cliente
        --LET decsaldovenc = decmontovenc + decmtovenctrasp;

        --Obtiene la eficiencia ponderada BanCoppel
        IF NOT EXISTS ( SELECT NVL(a.situacion_pago,0)
                       FROM bdisolic:ss_resum_scor_fin a,bdicred:sd_maecred b
                       WHERE a.empresa = b.empresa AND a.num_solicitud = b.num_credito
                       AND a.empresa='001' AND b.num_credito = chrnumcredito ) THEN
            LET deceficpond = 0;
        ELSE
            SELECT FIRST 1 NVL(a.situacion_pago,0) INTO deceficpond
            FROM bdisolic:ss_resum_scor_fin a,bdicred:sd_maecred b
            WHERE a.empresa = b.empresa AND a.num_solicitud = b.num_credito
            AND a.empresa='001' AND b.num_credito = chrnumcredito;
        END IF;

--jom
        --Obtiene numero de pagos vencidos
        select nvl(count(*),0)
         into intnumpagosvenc
         from bdicred:sd_amortiza_credito
        where empresa = '001'
          and num_credito = chrnumcredito
          and capital_status in (2,7,6);
--jom

        Let vchrtiempotrabact = 0;
        Let vchrtiempotrabant = 0;

        --Obtiene el tiempo de su ocupacion actual y anterior
--        EXECUTE PROCEDURE bdicred:sd_obtienetiempolaboral(chrnumcredito)
--        INTO chrcodret,vchrtiempotrabact,vchrtiempotrabant;
--        IF chrcodret::INTEGER < 0 THEN
--            RETURN chrcodret;
--        END IF;

        --Obtiene el total de los pagos acumulados en el mes
        EXECUTE PROCEDURE bdicred:sd_obtienepagosacum(chrnumcredito,dtefechahoy)
        INTO chrcodret1,decpagosacum,intnumpagos;
        IF chrcodret1::INTEGER < 0 THEN
            let chrcodret = chrcodret1;
            RETURN chrcodret;
        END IF;

        Let deccargosacum = 0;

        --Obtiene el total de los cargos acumulados en el mes
--        EXECUTE PROCEDURE bdicred:sd_obtienecargosacum(chrnumcredito,dtefechahoy)
--        INTO chrcodret,deccargosacum;
--        IF chrcodret::INTEGER < 0 THEN
--            RETURN chrcodret;
--        END IF;

        --Inserta en tabla registros obtenidos
--        INSERT INTO bdicred:sd_riesgoscred ( empresa,numcredito,numcte,califant,califactual,numperiodos,
--                    saldodispuesto,pagominimo,eficponderada,lincred,tasainteres,ciclosmora,
--                    actividad,ocupacion,tiporesidencia,edocivil,sexo,tiempodomact,tiempotrabact,
--                    tiempotrabant,dependientes,ciudad,fechanac,fechaalta,sucursal,fecprimermov,
--                    fecultmov,fechainsert,capvgte,capvenctrans,capvenctrasp,capvenctraspnoexig,
--                    ivaintereses,interesesmora,compend,ivacom,intvgte,intvcdotrasp,intvcdotrans,
--                    totalcap,totalint,totalotros,pagosmes,cargosmes,statuscred,numpagos, numpagosvenc  )
--        VALUES ( '001',chrnumcredito,chrnumcte,chrcalifant,chrcalifactual,intnumperiodos,
--                 decsaldodisp,decpagominimo,deceficpond,declincred,dectasainteres,intciclosmora,
--                 chractividad,chrocupacion,chrtipores,chredocivil,chrsexo,inttiempodomact,vchrtiempotrabact,
--                 vchrtiempotrabant,intdependientes,chrciudad,dtefechanac,dtefechaalta,chrsucursal,dtefecprimermov,
--                 dtefecultmov,dtefechahoy,deccapvgte,decmontovenc,decmtovenctrasp,deccapvenctraspnoexig,
--                 decivaintereses,decintmora,deccompendientes,decivacom,decintvgte,decintvcdotrasp,decintvcdotrans,
--                 dectotalcap,dectotalint,dectotalotros,decpagosacum,deccargosacum,chrdescstatus,intnumpagos, intnumpagosvenc);

        INSERT INTO bdicred:sd_riesgoscred ( empresa,numcredito,numcte,califant,califactual,numperiodos,
                    saldodispuesto,pagominimo,eficponderada,lincred,tasainteres,ciclosmora,
                    ciudad,fechaalta,sucursal,fecprimermov,
                    fecultmov,fechainsert,capvgte,capvenctrans,capvenctrasp,capvenctraspnoexig,
                    ivaintereses,interesesmora,compend,ivacom,intvgte,intvcdotrasp,intvcdotrans,
                    totalcap,totalint,totalotros,pagosmes,cargosmes,statuscred,numpagos, numpagosvenc  )
        VALUES ( '001',chrnumcredito,chrnumcte,chrcalifant,chrcalifactual,intnumperiodos,
                 decsaldodisp,decpagominimo,deceficpond,declincred,dectasainteres,intciclosmora,
                 chrciudad,dtefechaalta,chrsucursal,dtefecprimermov,
                 dtefecultmov,dtefechahoy,deccapvgte,decmontovenc,decmtovenctrasp,deccapvenctraspnoexig,
                 decivaintereses,decintmora,deccompendientes,decivacom,decintvgte,decintvcdotrasp,decintvcdotrans,
                 dectotalcap,dectotalint,dectotalotros,decpagosacum,deccargosacum,chrdescstatus,intnumpagos, intnumpagosvenc);


	END FOREACH;


      --alter table sd_riesgoscred TYPE (STANDARD);
--      create index idx_riesgoscred on sd_riesgoscred (empresa,numcredito,numcte) using btree ONLINE;
      update statistics high for table sd_riesgoscred (empresa,numcredito,numcte);
      let chrcodret = trim(chrcodret) || " Proceso de generación de informacion terminado Exitosamente ...";
      
RETURN chrcodret ;
END;

END PROCEDURE;