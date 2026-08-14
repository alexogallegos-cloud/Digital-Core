CREATE PROCEDURE "informix".sc_cons_ctasdos_bpii_pba1(pempresa CHAR(3),
                                                pnum_cte CHAR(20),
                                                pRegistro SMALLINT )
returning char(5), char(20), money(14,2), money(14,2), money(14,2), char(40), money(14,2), char(18), char(1),char(1),char(1);

					 
    -- Definición de variables
    define vCodRet             char(5);
    define vCuenta              char(20);
    define vSdoCta             money(14,2);
    define vSdoRet             money(14,2);
    define vSdoCong            money(14,2);
    define vSdoDisp            money(14,2);
    define vImpChqSbg         money(14,2);
    define vProducto            char(4);
    define vProdNom             char(35);
    define vDescripcion            char(40);
    define vCtaClabe           char(18);
    define sql_err              integer;
    define iCont		integer;
	define vedo_cta             char(1);
	DEFINE vstatus_serv		char(1);
	DEFINE vcPortabilidadFlag	char(1);

    --- Inicializa Variables de Salida
    let vCodRet   = "000";
    let vCuenta    = "";
    let vSdoDisp  = 0 ;
    let vSdoRet   = 0 ;
    let vSdoCta   = 0 ;
    let vDescripcion = "";
    let vSdoCong  = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vCtaClabe = "";
    let vImpChqSbg = 0;
    let iCont =0;
	let vedo_cta   = "";
	LET vstatus_serv	= "";
	LET vcPortabilidadFlag = "";
	
	-- ***************************************************************************        
    -- Objetivo:            Consulta las cuentas efectivas
    -- Creado por:			Autor desconocido
    -- ModIFicacion por:    Walber Castro
    -- Ultima ModIFicacion: 2012/07/04    
    -- Razón:				Se agrega parámetro de salida del status de la cuenta
    -- ***************************************************************************
    -- Modificacion por:    Roberto Castro
    -- Ultima Modificacion: 2014/03/24    
    -- Razón:				Se agrega parámetro de salida del status del servicio
	--						de emisión de estados de cuenta CFDI
    -- ***************************************************************************
    -- Modificación por:    Moisés Soriano
    -- Ultima Modificacion: 2015/02/15    
    -- Razón:				Se agrega parámetro de salida del status del servicio
	--						de portabilidad de nómina.
    -- ***************************************************************************

    BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            let vCodRet = sql_err;
            RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, vstatus_serv,vcPortabilidadFlag;
        END IF ;
    END EXCEPTION ;

    --SET DEBUG FILE TO "/home/sysifx/moises/bdicheq/cons_sdos1.out";
    --TRACE ON;

    --- Valida que el cliente no sea Blanco
    IF pnum_cte = "000000000" THEN
        let vCodRet = "110";
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF ;

    SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT SKIP pRegistro FIRST 10  mc.cuenta, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual,
               mc.producto, pr.nombre, mc.cuenta_clabe, mc.imp_chq_sbg, mc.status_cta
          INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg, vedo_cta
          FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
     --- WHERE num_cte = pnum_cte 
         WHERE mc.num_cte = pnum_cte
           AND mc.status_cta not in ('2')
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
         ORDER BY mc.cuenta

        let vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg;

        /* ####################
        IF vSdoDisp < 0 THEN
            let vSdoDisp = 0;
        END IF 
        #################### */

        LET iCont = iCont + 1;

        let vDescripcion = vProducto || " " || vProdNom;
		
		SELECT status_serv_elec
		INTO vstatus_serv
		FROM bdiedoelec:"informix".edelec_alta_serv
		WHERE cuenta = vCuenta;
		
		SELECT CASE WHEN estatus = '01' THEN '1' ELSE '0' END
		INTO vcPortabilidadFlag
		FROM bdicheq:"informix".sc_portabilidadnomina
		WHERE cuenta_abono = vCuenta
		AND cliente = pnum_cte
		AND estatus = '01';

        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0") WITH RESUME;
    END FOREACH;
    
    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET vCodRet = '101'; --- Cliente No tiene cuentas
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF

    END
    
END PROCEDURE ;