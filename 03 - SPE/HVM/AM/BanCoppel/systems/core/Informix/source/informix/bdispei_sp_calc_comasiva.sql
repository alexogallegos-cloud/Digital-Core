CREATE PROCEDURE "informix".sp_calc_comasiva(pEmpresa  CHAR(3), 
                                             pSucursal CHAR(4), 
                                             pUsuario  CHAR(8), 
                                             pImporte MONEY(16,2), 
                                             pCuenta CHAR(20), 
                                             pTipoCta SMALLINT)

RETURNING CHAR(5), CHAR(100), MONEY(14,2), MONEY(14,2), CHAR(70), CHAR(20), CHAR(20);

	-- ***************************************************************************
	-- sp_calc_comasiva
	-- Version              1.0.0
	-- Obejtivo:            Obtiene el monto de la comision, el iva y otros
	-- Creado por:          Alejandro Rueda Sanchez
	-- Modificado por:		Alejandra Barranco Arenas
	-- Ultima Modificacion: Agosto - 2022
	-- Creacion de SPL:	Agosto - 2007
	-- ***************************************************************************
	
	-- ***************************************************************************
	
	DEFINE sql_err     			INTEGER;
	DEFINE v_codret    			CHAR(5);
	DEFINE vDesErr     			CHAR(100);
	DEFINE vComision   			MONEY(14,2);
	DEFINE vIvacom     			MONEY(14,2);
	DEFINE vIva        			DECIMAL(5,2);
	DEFINE vNombre     			CHAR(105);
	DEFINE vCuenta     			CHAR(20);
	DEFINE vRfc        			CHAR(20);
	DEFINE vStatus     			CHAR(1);
	DEFINE vCargo      			CHAR(1);
	DEFINE vsdo_actual 			MONEY(14,2);
	DEFINE vretenido   			MONEY(14,2);
	DEFINE vcongelado  			MONEY(14,2);
	DEFINE vlimccc     			MONEY(14,2);
	DEFINE vutilccc    			MONEY(14,2);
	DEFINE vdispccc    			MONEY(14,2);
	DEFINE vdisponible 			MONEY(14,2);
	DEFINE vfechaccc   			DATE;
	DEFINE vfecha_hoy  			DATE;
	DEFINE intcontador 			INTEGER;
	DEFINE vproducto   			CHAR(4);
    DEFINE vmotivo     			CHAR(2);
    DEFINE vimpchqsbg  			MONEY(14,2);
    DEFINE vValidaPrd  			CHAR(4);
	DEFINE vValidaCtaNomina 	INTEGER; --ALEBARRANCO
	DEFINE vValidaEstatusCtaNom INTEGER; --ALEBARRANCO 
	DEFINE vPrjExclusionCtaNom 	INTEGER; --ALEBARRANCO
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. DHG.
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo inmovilizado (Salvo buen cobro)
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

	
	LET vComision   			= 0;
	LET vIva        			= 0;
	LET vIvacom     			= 0;
	LET v_codret    			= '000';
	LET vStatus     			= '0';
	LET vDesErr     			= "";
	LET vNombre     			= "";
	LET vCuenta     			= "";
	LET vRfc        			= "";
	LET vCargo      			= "";
	LET vsdo_actual 			= 0;
	LET vretenido   			= 0;
	LET vcongelado  			= 0;
	LET vlimccc     			= 0;
	LET vutilccc    			= 0;
	LET vdispccc    			= 0;
	LET vdisponible 			= 0;
	LET vproducto   			= '';
    LET vmotivo     			= '';
    LET vimpchqsbg  			= 0;
    LET pCuenta     			= TRIM(pCuenta);
	LET vValidaCtaNomina 		= 0; 	--ALEBARRANCO
	LET vValidaEstatusCtaNom 	= 0;	--ALEBARRANCO
	LET vPrjExclusionCtaNom 	= 0;	--ALEBARRANCO
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. DHG.
	LET mSaldoSBC			= 0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';

	-- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_calc_comasiva.out";
	-- TRACE ON;

	BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <>  0 THEN
            LET v_codret = sql_err;
            RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
        END IF
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Valida Parametros de entrada
    IF ( pCuenta is null OR pCuenta = '' OR pTipoCta is null OR pTipoCta = '' OR pTipoCta NOT IN(40, 3, 10) ) THEN
        LET v_codret = '002';
        LET vDesErr = "Tipo de cuenta incorrecto";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    END IF

/*
    -- // Verifica que la operacion se encuentre dentro del horario de servicio.
    IF pSucursal <> "5003" THEN
        SELECT COUNT(*)
          INTO intcontador
          FROM "informix".tblhorario
         WHERE intpkhorario = 1
           AND CURRENT BETWEEN tmhorainicio AND tmhoralimite;
    
        IF intcontador = 0 THEN
            LET v_codret = '013';
            LET vDesErr = 'Operacion fuera de horario de servicio';
            RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
        END IF;
    END IF;
*/
    -- // Calcula el iva de la sucursal origen
    SELECT iva
      INTO vIva
      FROM bdinteg:"informix".si_sucursales
     WHERE sucursal = pSucursal;

    -- // Si el valor del iva es nulo, lo extrae del central
    IF vIva IS NULL THEN
        SELECT valor
          INTO vIva
          FROM bdinteg:"informix".si_param
         WHERE cod_param = '47'
           AND empresa   = pEmpresa;
    END IF;

    -- // Obtener el importe y transaccion de la comision a cobrar
    SELECT FIRST 1 mnycomision
      INTO vComision
      FROM "informix".tblcomision
     WHERE vchrcvecomision = 'TARIFA 0';

    -- // Iva de la comision de SPEI
    LET vIvacom = vComision * vIva;

    -- // Extrae la cuenta con la cuenta clabe
    IF LENGTH(TRIM(pCuenta)) = 18 AND pTipoCta = 40  THEN
        SELECT cuenta
          INTO pCuenta
          FROM bdicheq:"informix".sc_maechq mto
         WHERE empresa = pEmpresa
           AND cuenta = SUBSTR(pCuenta, 7, 11)
           AND cuenta_clabe = pCuenta;
    ELIF LENGTH(TRIM(pCuenta)) = 10 AND pTipoCta = 10  THEN
        SELECT cuenta
          INTO pCuenta
          FROM bdicheq:sc_cuenta_telefono
         WHERE telefono = pCuenta;
    ELIF LENGTH(TRIM(pCuenta)) <>  11 AND pTipoCta = 40 THEN
        LET v_codret = '003';
        LET vDesErr = "El No. Cuenta no existe.";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    END IF
    
    IF pTipoCta IN(40, 10) THEN
        
        -- // Extrae la cuenta, nombre y rfc del Ordenante por cuenta
        SELECT mto.cuenta_clabe, NVL(TRIM(cte.nombre1),'')||' '||NVL(TRIM(cte.nombre2),'')||' '||NVL(TRIM(cte.apell_paterno),'')||' '||NVL(TRIM(cte.apell_materno),'') as nombre,
               cte.rfc, mto.status_cta, mto.sdo_actual, mto.sdo_retenido, mto.sdo_cong, mto.lim_sbg_ccc, mto.imp_sbg_ccc, mto.fech_venc_ccc, mto.fecha_proceso, mto.producto, mto.motivo, mto.imp_chq_sbg,mto.saldo_sbc
          INTO vCuenta, vNombre, vRfc, vStatus, vsdo_actual, vretenido, vcongelado, vlimccc, vutilccc, vfechaccc, vfecha_hoy, vproducto, vmotivo, vimpchqsbg,mSaldoSBC
          FROM bdicheq:"informix".sc_maechq mto,
               bdinteg:"informix".si_cliente cte
         WHERE mto.num_cte = cte.numcte
           AND mto.cuenta = pCuenta;
        
    ELSE
        
        -- // Extrae la cuenta, nombre y rfc del Ordenante por tarjeta debito
        SELECT mto.cuenta_clabe, NVL(TRIM(cte.nombre1),'')||' '||NVL(TRIM(cte.nombre2),'')||' '||NVL(TRIM(cte.apell_paterno),'')||' '||NVL(TRIM(cte.apell_materno),'') as nombre,
               cte.rfc, mto.status_cta, mto.sdo_actual, mto.sdo_retenido, mto.sdo_cong, mto.lim_sbg_ccc, mto.imp_sbg_ccc, mto.fech_venc_ccc, mto.fecha_proceso, mto.producto, mto.motivo, mto.imp_chq_sbg,mto.saldo_sbc
          INTO vCuenta, vNombre, vRfc, vStatus, vsdo_actual, vretenido, vcongelado, vlimccc, vutilccc, vfechaccc, vfecha_hoy, vproducto, vmotivo, vimpchqsbg, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq mto,
               bdinteg:"informix".si_cliente cte,
               bdicheq:"informix".sc_tarjeta tarj
         WHERE mto.empresa = pEmpresa
           AND mto.num_cte = cte.numcte
           AND tarj.empresa = pEmpresa
           AND tarj.cuenta = mto.cuenta
           AND tarj.secuencia = ( SELECT MAX(secuencia) 
                                    FROM bdicheq:"informix".sc_tarjeta 
                                   WHERE empresa = pEmpresa 
                                     AND num_tarjeta = pCuenta 
                                     AND status_tar = 'A' )
           AND tarj.num_tarjeta = pCuenta
           AND tarj.status_tar = 'A';
           
    END IF;
		
	SELECT producto 
	INTO   vValidaPrd
	FROM   bdispei:tblcomision_no_comision
    WHERE  producto = vproducto;
		
	IF vValidaPrd IS NULL THEN 
	   LET vcomision = vcomision;
       LET vivacom   = vivacom;
	ELSE 
	   LET vcomision = 0;
       LET vivacom   = 0;
	END IF;
	
	IF pSucursal IN ('5003','5008','5007','5011','8501') THEN 
	   LET vcomision = 0;
       LET vivacom   = 0;
	END IF 
	
	--VALIDA SI ES CUENTA DE NOMINA
	IF NOT(vcomision = 0 AND vivacom = 0) THEN
		--Se valida si el parametro CTA_NOMINA esta activo
		SELECT valor INTO vValidaCtaNomina FROM bdiadminnomina:"informix".sn_parametros WHERE id = 'CTA_NOMINA_SPEI';
		
		IF vValidaCtaNomina = 1 THEN
			--Se valida el estatus de la Cuenta de Nomina y el porcentaje de exclusion de comision - ALEBARRANCO
			SELECT nomina.estatus,  100-(beneficio.porcentaje) As pct
			INTO vValidaEstatusCtaNom, vPrjExclusionCtaNom
			FROM   bdiadminnomina:"informix".sn_cte_cta_nomina nomina
				INNER JOIN bdiadminnomina:"informix".sn_relacion_gpo_beneficios_cta_nomina gpoBeneficios
					ON gpoBeneficios.idGrupo = nomina.grupoBeneficios
				INNER JOIN bdiadminnomina:"informix".sn_beneficios_cta_nomina beneficio
					ON gpoBeneficios.idBeneficio = beneficio.idBeneficio
			WHERE  beneficio.idbeneficio = 2
				AND nomina.numcta = pCuenta ;
			
			IF vValidaEstatusCtaNom = 1 THEN --Si es una cuenta de nomina calcula la comision de acuerdo al grupo de beneficios - ALEBARRANCO
				LET vcomision = (vcomision * vPrjExclusionCtaNom) / 100;
				LET vivacom   = (vcomision * vIva * vPrjExclusionCtaNom) /100;
			ELSE
				LET vcomision = vcomision;
				LET vivacom   = vivacom;
			END IF;
		END IF;
	END IF;
	    
    -- // VERIFICA QUE LA CUENTA NO ESTA BLOQUEADA O CANCELADA
    IF vStatus IN('2', '6', '7', '8') THEN
        LET v_codret = '004';
        LET vDesErr = "La cuenta esta Cancelada";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    ELIF vStatus = '3' THEN
            SELECT opcion
              INTO vCargo
              FROM bdicheq:sc_ctabloqueo
             WHERE cuenta = vCuenta;
             
            IF vCargo is null THEN
                SELECT cargo
                  INTO vCargo
                  FROM bdicheq:"informix".sc_bloqueo
                 WHERE codigo = vmotivo;
            END IF
            
            IF vCargo IN ('3','4', 'N') THEN
                LET v_codret = '005';
                LET vDesErr = "La cuenta esta Bloqueada";
                RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
            END IF;
    ELIF vStatus = '0' OR vStatus IS NULL THEN
        LET v_codret = '006';
        LET vDesErr = "Numero de Cuenta/Tarjeta no registrado o la Tarjeta no encuentra activa.";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    END IF;

    -- // VERIFICA QUE LA CUENTA TENGA EL SALDO SUFICIENTE
    LET vdispccc = vlimccc - vutilccc;
    
    IF vfechaccc is null OR vfechaccc = '' THEN
        LET vfechaccc = '01/01/1900';
    END IF;

    IF vfechaccc < vfecha_hoy OR vdispccc IS NULL THEN
        LET vdispccc = 0;
    END IF;
	
	--RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vretenido,vcongelado,mSaldoSBC,vimpchqsbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisponible;        
	--LET vdisponible = ( vsdo_actual + vdispccc ) - ( vretenido + vcongelado + vimpchqsbg );
	LET vdisponible = vdisponible + vdispccc;

    IF ( pImporte + vComision + vIvacom ) > vdisponible  THEN
        LET v_codret = '001';
        LET vDesErr = "La cuenta no tiene los fondos suficientes incluyendo la Comision y el IVA";
    END IF

    RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    
	END
    
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento para que tambien consulte por tipo de consulta igual a 10',
'AUTOR: Vazquez Herrera Hugo',
'FECHA DE CREACION: 20 de OCTUBRE DE 2014',
'VERSION: 20141020.1311',
'FOLIO: 1463',
'BD: bdispei',
'MODIFICO : Alejandra Barranco',
'DESCRIPCION: Se agrega validacion para verificar si es una Cuenta de Nomina para la exclusion de comisiones',
'VERSION: 20220728',
'FECHA : 28/07/2022',
'BD: bdispei',
'MODIFICO : Alejandra Barranco',
'DESCRIPCION: Se mofica el formato de la fecha de la variable vfechaccc',
'VERSION: 20220824',
'FECHA : 24/08/2022',
'BD: bdispei',
'MODIFICO : Alejandra Barranco',
'DESCRIPCION: Se agrega validacion y registro en bitacora excentacion de comision de cuentas de nomina',
'VERSION: 20220912',
'FECHA : 12/09/2022',
'BD: bdispei',
'MODIFICO: Daniel Hernandez Garcia | Osiel Alfredo Camacho Mendoza',
'FECHA: 05-08-2025',
'MODIFICACION: Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDISPEI',
'VERSION: 1.5';

CREATE PROCEDURE "informix".sp_calc_comasiva_web(pEmpresa  CHAR(3), 
                                             pSucursal CHAR(4), 
                                             pUsuario  CHAR(8), 
                                             pImporte MONEY(16,2), 
                                             pCuenta CHAR(20), 
                                             pTipoCta SMALLINT)

RETURNING CHAR(5), CHAR(100), MONEY(14,2), MONEY(14,2), CHAR(70), CHAR(20), CHAR(20);

	-- ***************************************************************************
	-- sp_calc_comasiva
	-- Version              1.0.0
	-- Obejtivo:            Obtiene el monto de la comision, el iva y otros
	-- Creado por:          Alejandro Rueda Sanchez
	-- ModIFicado por:
	-- Ultima Modificacion: Agosto - 2007
	--                      Creacion de SPL
	-- ***************************************************************************
	
	DEFINE sql_err     INTEGER;
	DEFINE v_codret    CHAR(5);
	DEFINE vDesErr     CHAR(100);
	DEFINE vComision   MONEY(14,2);
	DEFINE vIvacom     MONEY(14,2);
	DEFINE vIva        DECIMAL(5,2);
	DEFINE vNombre     CHAR(105);
	DEFINE vCuenta     CHAR(20);
	DEFINE vRfc        CHAR(20);
	DEFINE vStatus     CHAR(1);
	DEFINE vCargo      CHAR(1);
	DEFINE vsdo_actual MONEY(14,2);
	DEFINE vretenido   MONEY(14,2);
	DEFINE vcongelado  MONEY(14,2);
	DEFINE vlimccc     MONEY(14,2);
	DEFINE vutilccc    MONEY(14,2);
	DEFINE vdispccc    MONEY(14,2);
	DEFINE vdisponible MONEY(14,2);
	DEFINE vfechaccc   DATE;
	DEFINE vfecha_hoy  DATE;
	DEFINE intcontador INTEGER;
	DEFINE vproducto   CHAR(4);
    DEFINE vmotivo     CHAR(2);
    DEFINE vimpchqsbg  MONEY(14,2);
	DEFINE vValidaPrd  CHAR(4);
	DEFINE vValidaCtaNomina 	INTEGER; --ALEBARRANCO
	DEFINE vValidaEstatusCtaNom INTEGER; --ALEBARRANCO 
	DEFINE vPrjExclusionCtaNom 	INTEGER; --ALEBARRANCO
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo. DHG.
	DEFINE mSaldoSBC			MONEY(14,2); --Monto del saldo inmovilizado.
	DEFINE cCodRetConsSdo		CHAR(5); --Codigo de retorno de SP de consulta de saldo.
	DEFINE cMensajeRetConsSdo 	CHAR(50); --Mensaje de retorno de SP de consulta de saldo.
	
	LET vComision   = 0;
	LET vIva        = 0;
	LET vIvacom     = 0;
	LET v_codret    = '00000';
	LET vStatus     = '0';
	LET vDesErr     = "";
	LET vNombre     = "";
	LET vCuenta     = "";
	LET vRfc        = "";
	LET vCargo      = "";
	LET vsdo_actual = 0;
	LET vretenido   = 0;
	LET vcongelado  = 0;
	LET vlimccc     = 0;
	LET vutilccc    = 0;
	LET vdispccc    = 0;
	LET vdisponible = 0;
	LET vproducto   = '';
    LET vmotivo     = '';
    LET vimpchqsbg  = 0;
    LET pCuenta     = TRIM(pCuenta);
	LET vValidaCtaNomina 		= 0; 	--ALEBARRANCO
	LET vValidaEstatusCtaNom 	= 0;	--ALEBARRANCO
	LET vPrjExclusionCtaNom 	= 0;	--ALEBARRANCO
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo. DHG.
	LET mSaldoSBC			=0.00;
	LET cCodRetConsSdo		= '00000';
	LET cMensajeRetConsSdo	= '';
	
	--- set debug file to "/tmp/sp_calc_comasiva.out";
	--- trace on;

	BEGIN
    
    ON EXCEPTION SET sql_err
        IF sql_err <>  0 THEN
            LET v_codret = sql_err;
            RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
        END IF
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // Valida Parametros de entrada
    IF ( pCuenta is null OR pCuenta = '' OR pTipoCta is null OR pTipoCta = '' OR pTipoCta NOT IN(40, 3, 10) ) THEN
        LET v_codret = '00002';
        LET vDesErr = "Tipo de cuenta incorrecto";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    END IF

    -- // Calcula el iva de la sucursal origen
    SELECT iva
      INTO vIva
    FROM bdinteg:"informix".si_sucursales
    WHERE sucursal = pSucursal;

    -- // Si el valor del iva es nulo, lo extrae del central
    IF vIva IS NULL THEN
        SELECT valor
          INTO vIva
        FROM bdinteg:"informix".si_param
        WHERE cod_param = '47'
           AND empresa   = pEmpresa;
    END IF;

    -- // Obtener el importe y transaccion de la comision a cobrar
    SELECT FIRST 1 mnycomision
      INTO vComision
    FROM "informix".tblcomision
    WHERE vchrcvecomision = 'TARIFA 0';

    -- // Iva de la comision de SPEI
    LET vIvacom = vComision * vIva;

    -- // Extrae la cuenta con la cuenta clabe
    IF LENGTH(TRIM(pCuenta)) = 18 AND pTipoCta = 40  THEN
        SELECT cuenta
          INTO pCuenta
        FROM bdicheq:"informix".sc_maechq mto
        WHERE empresa = pEmpresa
           AND cuenta = SUBSTR(pCuenta, 7, 11)
           AND cuenta_clabe = pCuenta;
    ELIF LENGTH(TRIM(pCuenta)) = 10 AND pTipoCta = 10  THEN
        SELECT cuenta
          INTO pCuenta
        FROM bdicheq:sc_cuenta_telefono
        WHERE telefono = pCuenta;
    ELIF LENGTH(TRIM(pCuenta)) <>  11 AND pTipoCta = 40 THEN
        LET v_codret = '00003';
        LET vDesErr = "El No. Cuenta no existe.";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    END IF
    
    IF pTipoCta IN(40, 10) THEN
        
        -- // Extrae la cuenta, nombre y rfc del Ordenante por cuenta
        SELECT mto.cuenta_clabe, NVL(TRIM(cte.nombre1),'')||' '||NVL(TRIM(cte.nombre2),'')||' '||NVL(TRIM(cte.apell_paterno),'')||' '||NVL(TRIM(cte.apell_materno),'') as nombre,
               cte.rfc, mto.status_cta, mto.sdo_actual, mto.sdo_retenido, mto.sdo_cong, mto.lim_sbg_ccc, mto.imp_sbg_ccc, mto.fech_venc_ccc, mto.fecha_proceso, mto.producto, mto.motivo, mto.imp_chq_sbg,mto.saldo_sbc
          INTO vCuenta, vNombre, vRfc, vStatus, vsdo_actual, vretenido, vcongelado, vlimccc, vutilccc, vfechaccc, vfecha_hoy, vproducto, vmotivo, vimpchqsbg, mSaldoSBC
          FROM bdicheq:"informix".sc_maechq mto,
               bdinteg:"informix".si_cliente cte
         WHERE mto.num_cte = cte.numcte
           AND mto.cuenta = pCuenta;
        
    ELSE       
        -- // Extrae la cuenta, nombre y rfc del Ordenante por tarjeta debito
        SELECT mto.cuenta_clabe, NVL(TRIM(cte.nombre1),'')||' '||NVL(TRIM(cte.nombre2),'')||' '||NVL(TRIM(cte.apell_paterno),'')||' '||NVL(TRIM(cte.apell_materno),'') as nombre,
               cte.rfc, mto.status_cta, mto.sdo_actual, mto.sdo_retenido, mto.sdo_cong, mto.lim_sbg_ccc, mto.imp_sbg_ccc, mto.fech_venc_ccc, mto.fecha_proceso, mto.producto, mto.motivo, mto.imp_chq_sbg,mto.saldo_sbc
          INTO vCuenta, vNombre, vRfc, vStatus, vsdo_actual, vretenido, vcongelado, vlimccc, vutilccc, vfechaccc, vfecha_hoy, vproducto, vmotivo, vimpchqsbg, mSaldoSBC
        FROM bdicheq:"informix".sc_maechq mto,
               bdinteg:"informix".si_cliente cte,
               bdicheq:"informix".sc_tarjeta tarj
         WHERE mto.empresa = pEmpresa
           AND mto.num_cte = cte.numcte
           AND tarj.empresa = pEmpresa
           AND tarj.cuenta = mto.cuenta
           AND tarj.secuencia = ( SELECT MAX(secuencia) 
                                    FROM bdicheq:"informix".sc_tarjeta 
                                   WHERE empresa = pEmpresa 
                                     AND num_tarjeta = pCuenta 
                                     AND status_tar = 'A' )
           AND tarj.num_tarjeta = pCuenta
           AND tarj.status_tar = 'A';
           
    END IF;
    
	SELECT producto 
	INTO   vValidaPrd
	FROM   bdispei:tblcomision_no_comision
    WHERE  producto = vproducto;
		
	IF vValidaPrd IS NULL THEN 
	   LET vcomision = vcomision;
       LET vivacom   = vivacom;
	ELSE 
	   LET vcomision = 0;
       LET vivacom   = 0;
	END IF;
	
	IF pSucursal IN ('5003','5008','5007','5011','8501') THEN 
	   LET vcomision = 0;
       LET vivacom   = 0;
	END IF
	
	--VALIDA SI ES CUENTA DE NOMINA
	IF NOT(vcomision = 0 AND vivacom = 0) THEN
		--Se valida si el parametro CTA_NOMINA esta activo
		SELECT valor INTO vValidaCtaNomina FROM bdiadminnomina:"informix".sn_parametros WHERE id = 'CTA_NOMINA_SPEI';
		
		IF vValidaCtaNomina = 1 THEN
			--Se valida el estatus de la Cuenta de Nomina y el porcentaje de exclusion de comision - ALEBARRANCO
			SELECT nomina.estatus,  100-(beneficio.porcentaje) As pct
			INTO vValidaEstatusCtaNom, vPrjExclusionCtaNom
			FROM   bdiadminnomina:"informix".sn_cte_cta_nomina nomina
				INNER JOIN bdiadminnomina:"informix".sn_relacion_gpo_beneficios_cta_nomina gpoBeneficios
					ON gpoBeneficios.idGrupo = nomina.grupoBeneficios
				INNER JOIN bdiadminnomina:"informix".sn_beneficios_cta_nomina beneficio
					ON gpoBeneficios.idBeneficio = beneficio.idBeneficio
			WHERE  beneficio.idbeneficio = 2
				AND nomina.numcta = pCuenta ;
			
			IF vValidaEstatusCtaNom = 1 THEN --Si es una cuenta de nomina calcula la comision de acuerdo al grupo de beneficios - ALEBARRANCO
				LET vcomision = (vcomision * vPrjExclusionCtaNom) / 100;
				LET vivacom   = (vcomision * vIva * vPrjExclusionCtaNom) /100;
			ELSE
				LET vcomision = vcomision;
				LET vivacom   = vivacom;
			END IF;
		END IF;
	END IF;
	
    -- // VERIFICA QUE LA CUENTA NO ESTA BLOQUEDAD o CANCELADA
    IF vStatus IN('2', '6', '7', '8') THEN
        LET v_codret = '00004';
        LET vDesErr = "La cuenta esta Cancelada";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    ELIF vStatus = '3' THEN
		SELECT opcion
		  INTO vCargo
		FROM bdicheq:sc_ctabloqueo
		WHERE cuenta = vCuenta;
		 
		IF vCargo is null THEN
			SELECT cargo
			  INTO vCargo
			FROM bdicheq:"informix".sc_bloqueo
			WHERE codigo = vmotivo;
		END IF
		
		IF vCargo IN ('3','4', 'N') THEN
			LET v_codret = '00005';
			LET vDesErr = "La cuenta esta Bloqueada";
			RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
		END IF;
    ELIF vStatus = '0' OR vStatus IS NULL THEN
        LET v_codret = '00006';
        LET vDesErr = "Numero de Cuenta/Tarjeta no registrado o la Tarjeta no encuentra activa.";
        RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
    END IF;

    -- // VERIFICA QUE LA CUENTA TENGA EL SALDO SUFICIENTE
    LET vdispccc = vlimccc - vutilccc;
    
    IF vfechaccc is null OR vfechaccc = '' THEN
        LET vfechaccc = '01/01/1900';
    END IF;

    IF vfechaccc < vfecha_hoy OR vdispccc IS NULL THEN
        LET vdispccc = 0;
    END IF;

    --RQM 09 704.Se agrega el llamado al SP de consulta de saldo con el tipo de calculo requerido para esta operacion.DHG
	EXECUTE PROCEDURE bdicheq:sp_cons_sdodisp_x_tpcalculo('',vsdo_actual,vretenido,vcongelado,mSaldoSBC,vimpchqsbg,0.00,0.00,'F',1) INTO cCodRetConsSdo,cMensajeRetConsSdo,vdisponible;        
	--LET vdisponible = ( vsdo_actual + vdispccc ) - ( vretenido + vcongelado + vimpchqsbg );
	LET vdisponible = vdisponible + vdispccc;	

    IF ( pImporte + vComision + vIvacom ) > vdisponible  THEN
        LET v_codret = '00001';
        LET vDesErr = "La cuenta no tiene los fondos suficientes incluyendo la Comision y el IVA";
    END IF

    RETURN v_codret,vDesErr, vComision, vIvacom, vNombre, vCuenta, vRfc;
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se modifica procedimiento para que tambien consulte por tipo de consulta igual a 10',
'AUTOR: Vazquez Herrera Hugo',
'FECHA DE CREACION: 20 de OCTUBRE DE 2014',
'VERSION: 20141020.1311',
'FOLIO: 1463',
'BD: bdispei',
'MODIFICO : Alejandra Barranco',
'DESCRIPCION: Se agrega validacion para verificar si es una Cuenta de Nomina para la exclusion de comisiones',
'VERSION: 20220728',
'FECHA : 28/07/2022',
'BD: bdispei',
'MODIFICO : Alejandra Barranco',
'DESCRIPCION: Se mofica el formato de la fecha de la variable vfechaccc',
'VERSION: 20220824',
'FECHA : 24/08/2022',
'BD: bdispei','MODIFICO : Alejandra Barranco',
'DESCRIPCION: Se agrega validacion y registro en bitacora excentacion de comision de cuentas de nomina',
'VERSION: 20220912',
'FECHA : 12/09/2022',
'BD: bdispei',
'MODIFICO: Daniel Hernandez Garcia | Osiel Alfredo Camacho Mendoza',
'FECHA: 05-08-2025',
'MODIFICACION: Se modifican la forma de calcular el saldo disponible para considerar un nuevo campo', 
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD: BDISPEI',
'VERSION: 1.5';

CREATE PROCEDURE "informix".spei_depuratblabono_por_dia() 
RETURNING CHAR(5); 
    
    DEFINE Sql_Err              INTEGER;
    DEFINE Isam_Err             INTEGER;
    DEFINE Desc_Err             CHAR(50);
    DEFINE vCodRet1             CHAR(5);
    DEFINE vCodRet2             CHAR(5);
    DEFINE vCodRet3             CHAR(50);
    DEFINE vContador1           INTEGER;
    DEFINE vContador2           INTEGER;
    DEFINE vContador3           INTEGER;
    DEFINE vComienza            SMALLINT;
    DEFINE vAbierto             CHAR(1);
    DEFINE wintnumserial        integer;
    DEFINE wmnyimporte          decimal(19,2);
    DEFINE wcvecesifbcoord      integer;
    DEFINE wchrestatusenvio     char(1);
    DEFINE wvchrnombreord       varchar(40,0);
    DEFINE wvchrcuentaord       varchar(20,0);
    DEFINE wvchrrfcord          varchar(18,0);
    DEFINE wintcvetipoctaord    integer;
    DEFINE wvchrnombrebenef     varchar(40,0);
    DEFINE wintcvetipoctabene   integer;
    DEFINE wvchrcuentabenef     varchar(20,0);
    DEFINE wintrefnumerica      decimal(7,0);
    DEFINE wvchrrefcobranza     varchar(40,0);
    DEFINE wvchrconceptopago2   varchar(40,0);
    DEFINE wdtfechavalor        date;
    DEFINE wdtfechacaptura      date;
    DEFINE wvchrclaverastreo    varchar(30,0);
    DEFINE wvchrcuentachq       varchar(20,0);
    DEFINE wvchrnumctechq       varchar(20,0);
    DEFINE wvchrctabenefemail   varchar(20,0);
    DEFINE wvchrtpoctabenefmsg  varchar(25,0);
    DEFINE wvchrtransacc        char(4);
    DEFINE wvchrfoliosuc        varchar(30,0);
    DEFINE wchrtipopago         CHAR(2);
    DEFINE wchridmjc            CHAR(20);
    DEFINE wchrfchmjc           CHAR(20);
    DEFINE wchrnumcelord        CHAR(10);
    DEFINE wintdigidord         INTEGER;
    DEFINE wchrnumcelben        CHAR(20);
    DEFINE wintdigidben         INTEGER;
    DEFINE wchrnumseriecert     CHAR(20);
    DEFINE iCommit              INTEGER;    
    DEFINE pfecha_hoy           DATE;
	DEFINE fecha				DATE;
	DEFINE pfecha_ant			DATE;
    
    DEFINE wfechalimpago CHAR(16);
    DEFINE wpagocomision INTEGER;
    DEFINE wcomision 		DECIMAL(14,2);
    DEFINE wfolioplataforma CHAR(20);
    DEFINE wvchrfirma       CHAR(512);
    
    LET Sql_Err	            = 0;
    LET Isam_Err            = 0;
    LET Desc_Err            = '';
    LET vCodRet1            = '000';
    LET vCodRet2            = '';
    LET vCodRet3            = '';  
    LET vContador1          = 0;
    LET vContador2          = 0;
    LET vContador3          = 0;
    LET vComienza           = -1;
    LET vAbierto            = '0';
    LET wintnumserial       = 0;
    LET wmnyimporte         = 0.00;
    LET wcvecesifbcoord     = 0;
    LET wchrestatusenvio    = '';
    LET wvchrnombreord      = '';
    LET wvchrcuentaord      = '';
    LET wvchrrfcord         = '';
    LET wintcvetipoctaord   = 0;
    LET wvchrnombrebenef    = '';
    LET wintcvetipoctabene  = 0;
    LET wvchrcuentabenef    = '';
    LET wintrefnumerica     = 0.00;
    LET wvchrrefcobranza    = '';
    LET wvchrconceptopago2  = '';
    LET wdtfechavalor       = '';
    LET wdtfechacaptura     = '';
    LET wvchrclaverastreo   = '';
    LET wvchrcuentachq      = '';
    LET wvchrnumctechq      = '';
    LET wvchrctabenefemail  = '';
    LET wvchrtpoctabenefmsg = '';
    LET wvchrtransacc       = '';
    LET wvchrfoliosuc       = '';
    LET wchrtipopago        = '';
    LET wchridmjc           = '';
    LET wchrfchmjc          = '';
    LET wchrnumcelord       = '';
    LET wintdigidord        = 0;
    LET wchrnumcelben       = '';
    LET wintdigidben        = 0;
    LET wchrnumseriecert    = '';
    LET iCommit             = 1000;
    LET pfecha_hoy          = '';
	LET fecha				= TODAY;
	LET pfecha_ant			= '';
    
    LET wfechalimpago    = '';
    LET wpagocomision    = 0;
    LET wcomision 	     = 0.00;
    LET wfolioplataforma = '';
    LET wvchrfirma       = '';
    
    BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_depuratblabono_test.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vAbierto = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_depuratblabono.out";
	--- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
   
	
	FOREACH WITH HOLD
        SELECT 
               intnumserial, vchrclaverastreo
          INTO wintnumserial,wvchrclaverastreo
          FROM tblhistabono 
         WHERE dtfechavalor = today - 1
        
        IF vComienza = -1 THEN
            LET vComienza = 0;
            BEGIN WORK;
            LET vAbierto = '1';
        END IF;
        
            DELETE FROM tblhistabono
             WHERE dtfechavalor = today - 1
               AND vchrclaverastreo = wvchrclaverastreo
               AND intnumserial = wintnumserial;
               
     
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= iCommit THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
    END FOREACH;
    
    IF vAbierto = '1' THEN
        COMMIT WORK;
        LET vAbierto = '0';
    END IF;
    
    END; 
    
    RETURN vCodRet1;
    
END PROCEDURE;