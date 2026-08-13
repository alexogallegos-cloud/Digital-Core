CREATE PROCEDURE "informix".sc_cons_ctasdos_bpi( pempresa CHAR(3), pnum_cte CHAR(20), pRegistro SMALLINT )
returning char(5), char(20), money(14,2), money(14,2), money(14,2), char(40), money(14,2), char(18), char(1),char(1),char(1);
    
    -- ***************************************************************************        
    -- Objetivo:            Consulta las cuentas efectivas
    -- Creado por:			Autor desconocido
    -- ModIFicacion por:    Walber Castro
    -- Ultima ModIFicacion: 2012/07/04    
    -- Razon:				Se agrega parametro de salida del status de la cuenta
    -- ***************************************************************************
    -- Modificacion por:    Roberto Castro
    -- Ultima Modificacion: 2014/03/24    
    -- Razon:				Se agrega parametro de salida del status del servicio
	--						de emision de estados de cuenta CFDI
    -- ***************************************************************************
    -- Modificacion por:    Moises Soriano
    -- Ultima Modificacion: 2015/02/15    
    -- Razon:				Se agrega parametro de salida del status del servicio
	--						de portabilidad de nomina.
    -- ***************************************************************************
    --Modificado por:       Eric E. Armenta Perez
    --Ultima mpodificacion: 2025/06/03
    --Razon:                Se agrega la nueva variable sdo_sbc (saldo buen cobro) 
    --                      a la operacion aritmetica para el nuevo calculo de 
    --                      saldo disponible.
    -- ***************************************************************************


    --- Definicion de variables
    define vCodRet char(5);
    define vCodRet2 char(5);
    define vCodRet3 char(80);
    define sql_err integer;
    define isam_err integer;
    define desc_err char(80);
    define vCuenta char(20);
    define vSdoCta money(14,2);
    define vSdoRet money(14,2);
    define vSdoCong money(14,2);
    define vSdoDisp money(14,2);
    define vImpChqSbg money(14,2);
    --RQM 09 704. Se crea la siguiente variable. EEAP 
    define mSaldoSBC money(14,2);
    define vProducto char(4);
    define vProdNom char(35);
    define vDescripcion char(40);
    define vCtaClabe char(18);
    define iCont integer;
	define vedo_cta char(1);
	DEFINE vstatus_serv char(1);
	DEFINE vcPortabilidadFlag char(1);

    --- Inicializa Variables de Salida
    let vCodRet = "000";
    let vCodRet2 = "";
    let vCodRet3 = "";
    let sql_err = 0;
    let isam_err = 0;
    let desc_err = "";
    let vCuenta = "";
    let vSdoDisp = 0 ;
    let vSdoRet = 0 ;
    let vSdoCta = 0 ;
    let vDescripcion = "";
    let vSdoCong = 0 ;
    let vProducto = " ";
    let vProdNom = " ";
    let vCtaClabe = "";
    let vImpChqSbg = 0;
    -- RQM 09 704. Se inicializa la variable creada. EEAP
    let mSaldoSBC = 0;
    let iCont = 0;
	let vedo_cta = "";
	LET vstatus_serv = "";
	LET vcPortabilidadFlag = "";
	
	BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sc_cons_ctasdos_bpi.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            LET vCodRet2 = isam_err;
            LET vCodRet3 = desc_err;
            RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, vstatus_serv,vcPortabilidadFlag;
        END IF ;
    END EXCEPTION ;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sc_cons_ctasdos_bpi.out";
    --- TRACE ON;

    --- Valida que el cliente no sea Blanco
    IF pnum_cte = "000000000" THEN
        let vCodRet = "110";
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF ;

    SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT {+INDEX(bdicheq:sc_maechq maecheques), 
                +INDEX(bdicheq:sc_producto idxscproductopba)}
               SKIP pRegistro FIRST 10  
                --RQM 09 704. Se agrega el campo saldo_sbc y la variable mSaldoSBC en la consulta. EEAP
               mc.cuenta, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual, mc.producto, pr.nombre, mc.cuenta_clabe, mc.imp_chq_sbg, mc.status_cta, mc.saldo_sbc
          INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg, vedo_cta, mSaldoSBC
          FROM bdicheq:sc_maechq as mc, 
               bdicheq:sc_producto as pr
         WHERE mc.num_cte = pnum_cte
           AND mc.status_cta in ('1','3','4','5')
           AND pr.producto = mc.producto
         ORDER BY mc.cuenta
         
        IF vSdoRet < 0 THEN 
            LET vSdoRet = vSdoRet * -1; 
        END IF;
        
        IF vSdoCong < 0 THEN 
            LET vSdoCong = vSdoCong * -1; 
        END IF;
        
        IF vImpChqSbg < 0 THEN 
            LET vImpChqSbg = vImpChqSbg * -1;
        END IF;
        
        --RQM 09 704. Se crea la siguiente validacion para la nueva variable mSaldoSBC. EEAP 
        IF mSaldoSBC < 0 THEN 
            LET mSaldoSBC = mSaldoSBC * -1;
        END IF;
        
        --RQM 09 704. Se agrega la variable mSaldoSBC al calculo del saldo disponible. EEAP
        LET vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg - mSaldoSBC;
        
        /* ####################
        IF vSdoDisp < 0 THEN
            let vSdoDisp = 0;
        END IF 
        #################### */

        LET iCont = iCont + 1;

        LET vDescripcion = vProducto || " " || vProdNom;
		
		SELECT {+INDEX(bdiedoelec:edelec_alta_serv idx02_edelec_alta_serv)}
               status_serv_elec
		  INTO vstatus_serv
		  FROM bdiedoelec:edelec_alta_serv
		 WHERE cuenta = vCuenta;
		
		SELECT CASE WHEN estatus = '01' THEN '1' ELSE '0' END
		  INTO vcPortabilidadFlag
		  FROM bdicheq:sc_portabilidadnomina
		 WHERE empresa = pempresa
           AND cliente = pnum_cte
           AND cuenta_abono = vCuenta
		   AND secuencia > 0
		   AND estatus = '01';

        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0") WITH RESUME;
    END FOREACH;
    
    IF ( iCont = 0 AND pRegistro = 0 ) THEN
        LET vCodRet = '101'; --- Cliente No tiene cuentas
        RETURN vCodRet, vCuenta, vSdoDisp, vSdoRet, vSdoCta, vDescripcion, vSdoCong, vCtaClabe, vedo_cta, NVL(vstatus_serv, ""),NVL(vcPortabilidadFlag,"0");
    END IF

    END
    
END PROCEDURE;