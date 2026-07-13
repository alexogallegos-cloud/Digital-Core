create procedure "informix".cons_chq(pempresa char(3), pnum_cte char(20), pmoneda char(2))
returning char(5),char(20), DECIMAL(14,2);

    -- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_numcte,v_cuenta char(20);
    define longitud,v_long_cte smallint;
    define prenglon, v_conta, v_ciclo smallint;
    define v_sdoactual, v_sdoretenido, v_sdocong, v_sdodisp,
    v_limccc, v_impccc, v_dispccc DECIMAL(14,2);
    --RQM 09 704. Se crea la siguiente variable "mSaldoSBC". EEAP 
    define mSaldoSBC money(14,2);
    define v_venccc, v_fechoy date;
    define vprodcrec char(4);

    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret       = "000";
    let v_cuenta      = " ";
    let v_conta       = 0;
    let v_ciclo       = 0;
    let prenglon      = 0;
    LET v_sdoactual   =0;
    LET v_sdoretenido =0;
    LET v_sdocong     =0;
    LET v_sdodisp     =0;
    LET vprodcrec     = "";
    -- RQM 09 704. Se inicializa la variable creada. EEAP
    LET mSaldoSBC     =0;
    
    --set debug file to "cons_chq.out";
    --trace on;

    begin
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_cuenta, v_sdodisp;
        end if
    end exception;
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION  TO DIRTY READ;


    select fecha_hoy 
      into v_fechoy
      from sc_fechas 
     where empresa = pempresa;

    select numcte 
      into v_numcte 
      from bdinteg:si_cliente
     where numcte = pnum_cte;
     
    if v_numcte is null then
        let cod_ret = "104";
        return cod_ret,v_cuenta, v_sdodisp;
    end if

    -- Carga el Parametro del Producto Creciente
    SELECT valor 
      INTO vprodcrec
      FROM sc_param
     WHERE codparam = "PRODCREC"
       AND empresa = pempresa;

    let v_conta = 0;
    
    foreach
        --RQM 09 704. Se agrega el campo saldo_sbc y la variable mSaldoSBC en la consulta. EEAP
        select cuenta, sdo_actual, sdo_retenido, sdo_cong, lim_sbg_ccc, imp_sbg_ccc, fech_venc_ccc, saldo_sbc 
          into v_cuenta, v_sdoactual, v_sdoretenido, v_sdocong, v_limccc, v_impccc, v_venccc, mSaldoSBC
          from sc_maechq mc, 
               sc_producto pr
         where mc.empresa = pempresa 
           and mc.empresa = pr.empresa 
           and mc.producto = pr.producto 
           and mc.num_cte = pnum_cte 
           and mc.status_cta not in("2","6","7")
           and pr.divisa = pmoneda
           and mc.producto != vprodcrec
         order by cuenta
         
        if v_cuenta is null then
            let cod_ret = 100;
            return cod_ret,v_cuenta, v_sdodisp;
        end if
        
        let v_dispccc = v_limccc - v_impccc;
        
        if v_dispccc is null then
            let v_dispccc = 0;
        end if
        
        if v_dispccc > 0 and v_venccc < v_fechoy then
            let v_dispccc = 0;
        end if
        
        --RQM 09 704. Se agrega la variable mSaldoSBC al calculo del saldo disponible. EEAP
        LET v_sdodisp = v_sdoactual - v_sdoretenido - v_sdocong - mSaldoSBC + v_dispccc;
        let v_conta = v_conta + 1;
        let v_ciclo = v_ciclo + 1;
        
        if v_ciclo <= prenglon then
            continue foreach;
        end if;
        
        return cod_ret, v_cuenta, v_sdodisp WITH RESUME;
    end foreach
    
    end
    
end procedure


DOCUMENT 
'MODIFICO : Eric Emilio Armenta Perez',
'FECHA : 02-06-2025',
'MODIFICACION : Se modifica la formula del calculo de saldo disponible para considerar un nuevo campo',
'               Se crea una nueva variable mSaldoSBC para almacenar el valor del nuevo campo saldo_sbc',
'PROYECTO : RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.2';

CREATE PROCEDURE "informix".sc_cons_ctasdos_bpi_mx(pempresa CHAR(3),
                                                pnum_cte CHAR(20),
                                                pRegistro SMALLINT )
returning char(5), char(20), money(14,2), money(14,2), money(14,2), char(40), money(14,2), char(18), char(1),char(1),char(1);

					 
    -- Definicion de variables
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
	--RQM 09 704. Se crea la siguiente variable . DHG
	DEFINE mSaldoSBC  			MONEY; 		--Obtiene el saldo_sbc de la maestra de cheques.
	
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
	--RQM 09 704. Se inicializa la siguiente variable generada. DHG
	LET mSaldoSBC				=0.00;

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
    -- Modifico:    		Daniel Hernandez Garcia
    -- Fecha: 				05-06-2025    
    -- Modificacion: 		Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible
	-- PROYECTO: 			RQM 09 704 Cobranza Automatica en cuentas de captacion
	-- BD    : 				bdicheq
	-- VERSION:				1.5
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

    SET ISOLATION DIRTY READ ;
	SET LOCK MODE TO WAIT 3;

    FOREACH
        --RQM 09 704. Se agrega la variable mSaldoSBC para almacenar el dato de la columna saldo_sbc. DHG
		SELECT SKIP pRegistro FIRST 10  mc.cuenta, mc.sdo_retenido, mc.sdo_cong, mc.sdo_actual,
               mc.producto, pr.nombre, mc.cuenta_clabe, mc.imp_chq_sbg, mc.status_cta, mc.saldo_sbc
          INTO vCuenta, vSdoRet, vSdoCong, vSdoCta, vProducto, vProdNom, vCtaClabe, vImpChqSbg, vedo_cta, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq as mc, bdicheq:"informix".sc_producto as pr
     --- WHERE num_cte = pnum_cte 
         WHERE mc.num_cte = pnum_cte
           AND mc.status_cta not in ('2')
           AND pr.empresa = mc.empresa 
           AND pr.producto = mc.producto
         ORDER BY mc.cuenta

		--RQM 09 704. Se agrega la variable mSaldoSBC en el calculo de saldo disponible. DHG
        let vSdoDisp = vSdoCta - vSdoRet - vSdoCong - vImpChqSbg - mSaldoSBC;

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
    
END PROCEDURE 
DOCUMENT
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 05-06-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicheq',
'VER   : 1.1';

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