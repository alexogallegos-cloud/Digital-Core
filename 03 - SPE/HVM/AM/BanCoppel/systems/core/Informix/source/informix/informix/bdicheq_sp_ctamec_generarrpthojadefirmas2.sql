CREATE PROCEDURE "informix".sp_ctamec_generarrpthojadefirmas2(pEmpresa CHAR(3), pCuenta CHAR(20))

	-- DATOS A REGRESAR --
RETURNING	CHAR(6)		AS COD_RET,			 -- Codigo de retorno
			CHAR(60)	AS MENSAJE_EJEC,	 -- Mensaje de la ejecucion
			CHAR(40)	AS DESC_PRODUCTO,	 -- Descripcion del producto
			CHAR(20)	AS NUM_CTE,			 -- Numero de cliente
			CHAR(104) 	AS NOMBRE_CTE,    	 -- Nombre de cliente
			CHAR(4)		AS COD_SUCURSAL,	 -- Codigo de sucursal
			CHAR(30)	AS DESC_MONEDA,		 -- Descripcion de la moneda
			DATE		AS FECHA_ALTA,		 -- Fecha de alta de la cuenta
			DATE		AS FECHA_MODIFIC,	 -- Fecha de modificacion de firmantes
			CHAR(20)	AS REGIMEN,			 -- Regimen de firma relacionado a la cuenta
			CHAR(20)    AS ESPECIF_MANEJO,	 -- Especificaciones de manejo del regimen de la firma
			CHAR(104)	AS NOMBRE_FIRMANTE1,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE1,
			CHAR(104)	AS NOMBRE_FIRMANTE2,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE2,
			CHAR(104)	AS NOMBRE_FIRMANTE3,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE3,
			CHAR(104)	AS NOMBRE_FIRMANTE4,  -- Nombre del firmante	
			CHAR(20)    AS FIRMANTE4;
	
	--	VARIABLES CONTROL DE ERRORES --
	
	DEFINE cCodRet			CHAR(6);
	DEFINE sql_err			INTEGER;
	DEFINE cMensaje			CHAR(60);
	
	-- VARIABLES --
	
	DEFINE cNumcte			CHAR(20);
	DEFINE cNombre			CHAR(104);
	DEFINE cCodSuc			CHAR(4);	
	DEFINE cCodProd			CHAR(4);
	DEFINE cNomProd			CHAR(40);
	DEFINE cCodMoneda		CHAR(2);
	DEFINE dfecha_alta		DATE;
	DEFINE cCodRegimen		CHAR(1);
	DEFINE cDescRegimen		CHAR(20);
	DEFINE cCombinacion		CHAR(20);
	DEFINE cDescMoneda		CHAR(30);
	DEFINE dUltModif		DATE;
	DEFINE cNumcteFirm		CHAR(20);
	DEFINE cNombreFirm		CHAR(104);
	DEFINE cNombreFirm1		CHAR(104);
	DEFINE cFirma1          CHAR(20);
	DEFINE cNombreFirm2		CHAR(104);
	DEFINE cFirma2          CHAR(20);
	DEFINE cNombreFirm3		CHAR(104);
	DEFINE cFirma3          CHAR(20);
	DEFINE cNombreFirm4		CHAR(104);
	DEFINE cFirma4          CHAR(20);
    DEFINE sSecuencia       SMALLINT;
    DEFINE iNumRegs         INTEGER;
    DEFINE iContador        INTEGER;
	DEFINE cSufijo          CHAR(60);	--DSB 16/05/2013
	DEFINE sTipoFirma		CHAR(1);
	
	-- INICIALIZACION DE VARIABLES --
	
	LET cCodRet			= '000000';
	LET cMensaje		= 'LA EJECUCION SE REALIZO EXITOSAMENTE';
	LET cCodSuc			= '';
	LET cNumcte			= '';
	LET cCodProd		= '';
	LET cNomProd		= '';
	LET cCodMoneda		= '';
	LET cNombre			= '';
	LET dfecha_alta		= '';
	LET cCodRegimen		= '';
	LET cDescRegimen	= '';
	LET cCombinacion	= '';
	LET cDescMoneda		= '';
	LET dUltModif		= '01/01/2000';
	LET cNumcteFirm		= '';
	LET cNombreFirm     = '';
	LET cNombreFirm1    = '';
	LET cFirma1         = 'C A N C E L A D O';
	LET cNombreFirm2    = '';
	LET cFirma2         = 'C A N C E L A D O';
	LET cNombreFirm3    = '';
	LET cFirma3         = 'C A N C E L A D O';
    LET cNombreFirm4    = '';
    LET cFirma4         = 'C A N C E L A D O';
    LET sSecuencia      = 0;
    LET iNumRegs        = 0;
    LET iContador       = 0;
	LET cSufijo         = '';	--DSB 16/05/2013
	LET sTipoFirma 		= '';

	-- CONTROL DE ERRORES --	
	BEGIN
	ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            LET cMensaje = 'ERROR INESPERADO EN LA EJECUCION';
			
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
        END IF
	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    --SET DEBUG FILE TO "/respaldosbd/joseluis/sp_ctamec_generarrpthojadefirmas2.out";
    --TRACE ON;
	
	-- VALIDACION DE PARAMETROS
	IF pEmpresa = '' OR pEmpresa IS NULL OR pCuenta = '' OR pCuenta IS NULL THEN
		LET cCodRet = '100';
		LET cMensaje = 'ERROR EN LOS PARAMETROS; AMBOS PARAMETROS SON OBLIGATORIOS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
					
	ELIF LENGTH(pEmpresa) <> 3 OR pEmpresa <> '001' THEN
		LET cCodRet = '500';
		LET cMensaje = 'PARAMETRO EMPRESA NO VALIDO; VERIFIQUE';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- CONSULTA DE INFORMACION DE LA CUENTA
	SELECT sucursal, num_cte, producto
	INTO cCodSuc, cNumcte, cCodProd
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE VALIDA SI LA CUENTA EXISTE
	IF cNumcte IS NULL OR cNumcte = '' THEN
		LET cCodRet = '200';
		LET cMensaje = 'ERROR; NO EXISTE LA CUENTA';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA INFORMACION DE LA MONEDA
	SELECT nombre, divisa
	INTO cNomProd, cCodMoneda
	FROM bdicheq:"informix".sc_producto
	WHERE empresa = pEmpresa
	AND producto = cCodProd;
	
	-- SE VALIDA SI EL PRODUCTO EXISTE
	IF cNomProd IS NULL OR cNomProd = '' THEN
		LET cCodRet = '210';
		LET cMensaje = 'ERROR; NO EXISTE EL PRODUCTO';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;

	-- SE TOMA EL NOMBRE DEL CLIENTE .. YA SEA PERSONA FISICA O MORAL
	SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno) || ' ' || TRIM(razon_social)
	INTO cNombre
	FROM bdinteg:"informix".si_cliente
	WHERE empresa = pEmpresa
	AND numcte = cNumcte;	
	
	--DSB 16/05/2013
	SELECT NVL(descripcion, '')
	INTO cSufijo
	FROM bdinteg:"informix".si_sufijos suf,
	bdinteg:"informix".si_ctepm cte
	WHERE suf.codigo = cte.sufijo 
	AND cte.numcte = cNumCte;
	LET cNombre = TRIM(cNombre)||" "||TRIM(NVL(cSufijo, ''));
	
	-- SE CONSULTA INFORMACION DE LA CUENTA
	SELECT fecha_alta, reg_firmas
	INTO dfecha_alta, cCodRegimen
	FROM bdicheq:"informix".sc_maenoc
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE CONSULTA INFORMACION DEL REGIMEN DE FIRMA RELACIONADO CON LA CUENTA
	SELECT descripcion, combinacion
	INTO cDescRegimen, cCombinacion
	FROM bdicntchq:"informix".sq_catregimen
	WHERE cve_regimen = cCodRegimen;
	
	-- SE VALIDA QUE EL REGIMEN ES CORRECTO
	IF cDescRegimen IS NULL OR cDescRegimen = '' THEN
		LET cCodRet = '220';
		LET cMensaje = 'ERROR; NO EXISTE EL REGIMEN DE FIRMAS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA INFORMACION DE LA MONEDA
	SELECT descripcion
	INTO cDescMoneda
	FROM bdinteg:"informix".si_divisas
	WHERE divisa = cCodMoneda;
	
	-- SE VALIDA QUE LA MONEDA EXISTE
	IF cDescMoneda IS NULL OR cDescMoneda = '' THEN
		LET cCodRet = '230';
		LET cMensaje = 'ERROR; NO EXISTE LA MONEDA';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	END IF;
	
	-- SE TOMA LA FECHA DEL MAS RECIENTE REGISTRO DE FIRMANTES
	SELECT MAX(fecha_insert)
	INTO dUltModif
	FROM bdinteg:"informix".si_cterelacionado
	WHERE empresa = pEmpresa
	AND cuenta = pCuenta;
	
	-- SE VALIDA QUE EXISTAN FIRMANTES
	IF dUltModif IS NULL OR dUltModif = '' THEN
		LET cCodRet = '333';
		LET cMensaje = 'LA CUENTA NO TIENE FIRMANTES RELACIONADOS';
		
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	
	ELIF dfecha_alta = dUltModif THEN -- NO EXISTE FECHA DE MODIFICACION, SOLO DE CREACION
		LET dUltModif = '01/01/2000';	
	END IF;
	
	-- SE HACE MAYUSCULA LA DESCRIPCION DEL REGIMEN
	LET cDescRegimen = UPPER(cDescRegimen);	
  
	-- SE CONSULTAN LOS FIRMANTES RELACIONADOS CON LA CUENTA
	FOREACH
		SELECT numcte, secuencia, tipo_firma
		INTO cNumcteFirm, sSecuencia, sTipoFirma
		FROM bdicheq:"informix".sc_firmantes
		WHERE empresa = pEmpresa
		AND cuenta = pCuenta
		ORDER BY tipo_firma, secuencia
		
		-- SE INCREMENTA CONTADOR PARA IDENTIFICAR LA POSICION QUE OCUPARA EN EL REPORTE
		LET iContador = iContador + 1;
		
		-- SE CONSULTA EL NOMBRE DEL FIRMANTE .. SOLO PERSONA FISICA
		SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno)
		INTO cNombreFirm
		FROM bdinteg:"informix".si_cliente
		WHERE empresa = pEmpresa
		AND numcte = cNumcteFirm;
		
			-- SE VALIDA SI ES EL FIRMANTE TITULAR DE LA CUENTA
			IF iContador = 1 THEN
			   LET cNombreFirm1 = cNombreFirm;
			   IF cNombreFirm1 <> '' THEN
			       LET cFirma1 = '';
			   END IF;
			   
			ELIF iContador = 2 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 1 DE LA CUENTA
			   LET cNombreFirm2 = cNombreFirm;
			   IF cNombreFirm2 <> '' THEN
			       LET cFirma2 = '';
			   END IF;
			   
			ELIF iContador = 3 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 2 DE LA CUENTA
			   LET cNombreFirm3 = cNombreFirm;
			   IF cNombreFirm3 <> '' THEN
			       LET cFirma3 = '';
			   END IF;
			   
			ELIF iContador = 4 THEN -- SE VALIDA SI ES EL FIRMANTE ADICIONAL 3 DE LA CUENTA
			   LET cNombreFirm4 = cNombreFirm;
			   IF cNombreFirm4 <> '' THEN
			       LET cFirma4 = '';
			   END IF;

			END IF;
            
	END FOREACH;
		-- SE REALIZA SOLO UN RETORNO QUE INCLUYE TODA LA INFORMACION DE LA CUENTA.
		RETURN	TRIM(cCodRet), TRIM(cMensaje), TRIM(cNomProd), TRIM(cNumcte), TRIM(cNombre), TRIM(cCodSuc), TRIM(cDescMoneda), dfecha_alta, dUltModif, TRIM(cDescRegimen), TRIM(cCombinacion),
				TRIM(cNombreFirm1), TRIM(cFirma1), TRIM(cNombreFirm2), TRIM(cFirma2), TRIM(cNombreFirm3), TRIM(cFirma3), TRIM(cNombreFirm4), TRIM(cFirma4);
	
END
END PROCEDURE 
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 20 de Junio del 2011',
'DESCRIPCION: Procedimiento que llena el reporte de hoja de firmas.',
'VERSION: 20110620.1042',
'BD: BDICHEQ',
'Modifico: Jose Luis Polanco B.',
'Fecha: DSB 16/05/2013',
'Descripcion: Se agrega el "sufijo" a la variable de retorno "cNombre" para que aparesca en los reportes',
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 10/10/2016',
'DESCRIPCION: SPL clonado para ordenar los registros de firmantes de acuerdo al tipo al que pertenezcan',
'ID MANTIS: 0006773',
'BD: bdicheq';

CREATE PROCEDURE "informix".crea_maehis_esp( eEmpresa CHAR(3), eFechaPago DATE )
RETURNING CHAR(5);
    
    DEFINE vgtrans_pag_int          CHAR(4);
    DEFINE vgtransisr               CHAR(4);
    
    DEFINE CodRet	                CHAR(5);
    DEFINE CodRet2                  CHAR(5);
    DEFINE CodRet3	                CHAR(50);
    DEFINE sql_err                  INTEGER;
    DEFINE isam_err                 INTEGER;
    DEFINE desc_err                 CHAR(50);
    DEFINE vsdo_mes_ant             DECIMAL(14,2);
    DEFINE vcuantos                 SMALLINT;
    DEFINE vtotdepositos            DECIMAL(14,2);
    DEFINE vtotretiros              DECIMAL(14,2);
    DEFINE vtotcomcobrada           DECIMAL(14,2);
    DEFINE vtotcombonif             DECIMAL(14,2);
    DEFINE vtotivacobrado           DECIMAL(14,2);
    DEFINE vtotivabonif             DECIMAL(14,2);
    DEFINE vtotintpag               DECIMAL(14,2);
    DEFINE vtotisrcobrado           DECIMAL(14,2);
    DEFINE vdia                     CHAR(2);
    DEFINE vcuenta_clabe            CHAR(20);
    DEFINE vsucursal                CHAR(4);
    DEFINE vproducto                CHAR(4);
    DEFINE vnum_cte	                CHAR(20);
    DEFINE vstatus_cta              CHAR(1);
    DEFINE vmotivo                  CHAR(2);
    DEFINE vfec_cancelac            DATE;
    DEFINE vsdo_retenido            DECIMAL(16,2);
    DEFINE vsdo_cong                DECIMAL(16,2);
    DEFINE vsdo_actual              DECIMAL(16,2);
    DEFINE venvio_direcc            CHAR(1);
    DEFINE vdirecc_envio            SMALLINT;
    DEFINE vacum_sdo_pos            DECIMAL(18,2);
    DEFINE vdia_sdo_pos             SMALLINT;
    DEFINE vacum_sdo_int            DECIMAL(18,2);
    DEFINE vdias_acum_int           SMALLINT;
    DEFINE vret_mes_ant             DECIMAL(16,2);
    DEFINE vcong_mes_ant            DECIMAL(16,2);
    DEFINE vlim_sbg_ccc             DECIMAL(16,2);
    DEFINE vimp_sbg_ccc             DECIMAL(16,2);
    DEFINE vimp_chq_sbg             DECIMAL(16,2);
    DEFINE vsaldo_sbc               DECIMAL(16,2);
    DEFINE vint_acum                DECIMAL(18,2);
    DEFINE visr_acum                DECIMAL(18,2);
    DEFINE vmaxsecuencia            SMALLINT;
    DEFINE vnum_tarjeta             CHAR(20);
    DEFINE vfechafin                DATE;
    DEFINE vfechaini                DATE;
    DEFINE vaniomes                 CHAR(6);
    DEFINE vtasa_bruta              DECIMAL(9,6);
    DEFINE vmonto_tot               DECIMAL(16,2);
    DEFINE vtransacc                CHAR(4);
    DEFINE vnaturaleza              CHAR(1);
    DEFINE vtipo_tran               CHAR(2);
    DEFINE vfechainimovhis          CHAR(10);
    DEFINE vfechainimovhisold       CHAR(10);
    DEFINE vultfechafin             DATE;
    DEFINE vdifdias                 INTEGER;
    DEFINE vtran_efec               CHAR(4);
    DEFINE vtotretirosefec          DECIMAL(18,2);
    DEFINE vtototroscargos          DECIMAL(18,2);
    DEFINE vgat                     DECIMAL(9,6);
    DEFINE vprodcrec                CHAR(4);
    DEFINE vtrandepotrobco          CHAR(4);
    DEFINE vtrandevotrobco          CHAR(4);
    DEFINE vtasa_gat                DECIMAL(9,6);
    DEFINE vgat_real                DECIMAL(9,6);
    DEFINE eCuenta                  CHAR(20);
    DEFINE eFechaAlta               DATE;
    DEFINE eAcumSdoPos              DECIMAL(18,2);
    DEFINE eDiaSdoPos               INTEGER;
    
    LET vgtrans_pag_int = '3276';
    LET vgtransisr      = '3277';
    LET CodRet          = '000';
    LET vtran_efec      = '';
    LET vfechafin       = eFechaPago;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/tmp/crea_maehis_esp.err";
        TRACE ON;
        LET CodRet = sql_err;
        LET CodRet2 = isam_err;
        LET CodRet3 = desc_err;
        RETURN CodRet;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/crea_maehis_esp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    FOREACH
        SELECT UNIQUE cuenta
          INTO eCuenta
          FROM sc_movhis
         WHERE cuenta in(SELECT cuenta FROM sc_valcierre)
           AND fech_alt = '12/07/2016'
        
        SELECT fecha_alta, acum_sdo_pos, dia_sdo_pos
          INTO eFechaAlta, eAcumSdoPos, eDiaSdoPos
          FROM sc_maenoc
         WHERE cuenta = eCuenta;
        
        LET vdia = DAY(eFechaAlta);

        -- // CALCULA EL INICIO DEL PERIODO
        CALL sp_mes_siguiente(eFechaPago, -1, vdia)
        RETURNING CodRet, vfechaini, eDiaSdoPos;

        IF vdia = '01' OR vdia = '1' THEN
            LET vfechaini = vfechaini + 1 UNITS MONTH;
        END IF;
        
        IF vdia = '31' AND (lpad(month(vfechaini), 2, '0') = '02' OR 
                            lpad(month(vfechaini), 2, '0') = '04' OR
                            lpad(month(vfechaini), 2, '0') = '06' OR 
                            lpad(month(vfechaini), 2, '0') = '09' OR
                            lpad(month(vfechaini), 2, '0') = '11') THEN
            LET vfechaini = vfechaini + 1 UNITS DAY;
        END IF;
        
        SELECT fechafin
          INTO vultfechafin
          FROM sc_maehis
         WHERE empresa = Eempresa
           AND cuenta = eCuenta
           AND aniomes = ( SELECT MAX(aniomes)
                             FROM sc_maehis
                            WHERE empresa = Eempresa
                              AND cuenta = eCuenta);
                              
        IF vultfechafin is null THEN
            LET vultfechafin = '01/01/2007';
        END IF;
                              
        IF vultfechafin = vfechaini THEN
            LET vfechaini = vfechaini + 1 UNITS DAY;
        END IF;
        
        LET eDiaSdoPos = (vfechafin - vfechaini) + 1;

        SELECT CASE WHEN SUBSTR( MAX( aniomes ) + 1, 5 ) > 12 THEN
                   ( SELECT SUBSTR( SUBSTR( MAX(aniomes), 1, 4 ) + 1, 1, 4 ) || '01'
                       FROM sc_maehis
                      WHERE empresa = Eempresa
                        AND cuenta = eCuenta )
               ELSE
                   ( SELECT SUBSTR( MAX(aniomes) + 1, 1, 6 )
                      FROM sc_maehis
                     WHERE empresa = Eempresa
                       AND cuenta = eCuenta )
               END
          INTO vaniomes
          FROM sc_maehis
         WHERE empresa = Eempresa
           AND cuenta = eCuenta;

        IF vaniomes is null or vaniomes = '' THEN
            LET vaniomes = YEAR(eFechaAlta)||LPAD(MONTH(eFechaAlta  ),2,'0');
        END IF;

        -- // OBTIENE INFORMACIÓN GENERAL DE LA CUENTA
        SELECT mc.cuenta_clabe, mc.sucursal, mc.producto, mc.num_cte,
               mc.status_cta, mc.motivo, mc.fec_cancelac, mc.sdo_retenido, mc.sdo_cong,
               mc.sdo_actual, mn.envio_direcc, mc.direcc_envio, mn.sdo_mes_ant,
               mn.acum_sdo_pos, mn.dia_sdo_pos, mn.acum_sdo_int, mn.dias_acum_int,
               mn.ret_mes_ant, mn.cong_mes_ant, mc.lim_sbg_ccc, mc.imp_sbg_ccc,
               mc.imp_chq_sbg, mc.saldo_sbc, mn.int_acum, mn.isr_acum
          INTO vcuenta_clabe, vsucursal, vproducto, vnum_cte,
               vstatus_cta, vmotivo, vfec_cancelac, vsdo_retenido, vsdo_cong,
               vsdo_actual, venvio_direcc, vdirecc_envio, vsdo_mes_ant,
               vacum_sdo_pos, vdia_sdo_pos, vacum_sdo_int, vdias_acum_int,
               vret_mes_ant, vcong_mes_ant, vlim_sbg_ccc, vimp_sbg_ccc,
               vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum
          FROM sc_maechq mc,
               sc_maenoc mn,
               sc_producto pr
         WHERE mc.empresa = eEmpresa
           AND mc.cuenta = eCuenta
           AND mn.empresa = mc.empresa
           AND mn.cuenta = mc.cuenta
           AND pr.empresa = mn.empresa
           AND pr.producto = mc.producto;

        -- // INICIALIZA VARIABLES DE SALDOS
        LET vtotdepositos   = 0;
        LET vtotretiros     = 0;
        LET vtotintpag      = 0;
        LET vtotcomcobrada  = 0;
        LET vtotcombonif    = 0;
        LET vtotivacobrado  = 0;
        LET vtotivabonif    = 0;
        LET vtotisrcobrado  = 0;
        LET vtotretirosefec = 0;
        LET vtototroscargos = 0;
        LET vgat            = 0;
        LET vgat_real       = 0;
        
        -- // OBTIENE FECHAS DE CONSULTAS EN HISTORICOS
        SELECT valor
          INTO vfechainimovhis
          FROM sc_param
         WHERE empresa = eEmpresa
           AND codparam = 'fechcon_movhis';
           
        SELECT valor
          INTO vfechainimovhisold
          FROM sc_param
         WHERE empresa = eEmpresa
           AND codparam = 'FechIniCon_movhis_ol';
           
        SELECT valor
          INTO vtrandepotrobco
          FROM sc_param
         WHERE empresa = eEmpresa
           AND codparam = 'trandepobco';
           
        SELECT valor
          INTO vtrandevotrobco
          FROM sc_param
         WHERE empresa = eEmpresa
           AND codparam = 'trandevobco';
        

        -- // OBTIENE CARGOS Y ABONOS DEL HISTORICO
        FOREACH           
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              INTO vmonto_tot, vtransacc, vnaturaleza, vtipo_tran, vtran_efec
              FROM sc_movhis mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = eEmpresa
               AND mv.cuenta = eCuenta
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc = tr.numero
            UNION ALL
            SELECT mv.monto_tot, mv.transacc, tr.naturaleza, tr.tipo_tran, NVL(efe.transaccion, '0000')
              FROM sc_movhis_old mv
             INNER JOIN bdinteg:si_transacc tr ON (tr.empresa = mv.empresa AND tr.numero = mv.transacc AND tr.se_emite_edocta = 'S')
              LEFT OUTER JOIN sc_transacc_efectivo efe ON (efe.transaccion = mv.transacc)
             WHERE mv.empresa = eEmpresa
               AND mv.cuenta = eCuenta
               AND mv.fech_alt BETWEEN vfechaini AND vfechafin
               AND mv.fech_alt >= vfechainimovhisold
               AND mv.fech_alt < vfechainimovhis
               AND mv.cancelad <> 'S'
               AND mv.transacc = tr.numero
               
            -- // ABONOS
            IF vnaturaleza = 'A' THEN 
                IF (vtransacc <> vgtrans_pag_int AND vtransacc <> vtrandepotrobco) THEN -- TOTAL DEPOSITOS
                    LET vtotdepositos = vtotdepositos + vmonto_tot;
                END IF;

                IF vtipo_tran in('01','05','09') THEN -- TOTAL COMISIONES BONIFICADAS
                    LET vtotcombonif = vtotcombonif + vmonto_tot;
                END IF;

                IF vtipo_tran in('02','04','06','08') THEN -- TOTAL IVA BONIFICADO
                    LET vtotivabonif = vtotivabonif + vmonto_tot;
                END IF;
            -- // CARGOS
            ELIF vnaturaleza = 'C' THEN 
                IF (vtipo_tran IN('00','30') AND vtransacc <> vgtransisr AND vtransacc <> vtrandevotrobco) THEN -- TOTAL RETIROS
                    LET vtotretiros = vtotretiros + vmonto_tot;
                    LET vtototroscargos = vtototroscargos + vmonto_tot;
                END IF;
                
                IF vtran_efec = vtransacc THEN
                    LET vtotretirosefec = vtotretirosefec + vmonto_tot;
                END IF;

                IF vtipo_tran in('01','31') THEN -- TOTAL COMISIONES COBRADAS
                    LET vtotcomcobrada = vtotcomcobrada + vmonto_tot;
                END IF;

                IF vtipo_tran in('02','32') THEN -- TOTAL IVA COBRADO
                    LET vtotivacobrado = vtotivacobrado + vmonto_tot;
                END IF;
            END IF;
             
            IF vtransacc = vgtrans_pag_int THEN -- TOTAL PAGO DE INTERESES
                LET vtotintpag = vtotintpag + vmonto_tot;
            END IF;

            IF vtransacc = vgtransisr THEN -- TOTAL ISR COBRADO
                LET vtotisrcobrado = vtotisrcobrado + vmonto_tot;
            END IF;
        END FOREACH;

        IF vtotdepositos IS NULL THEN -- DEPOSITOS
            LET vtotdepositos = 0;
        END IF;

        IF vtotretiros is null OR vtotretiros < 0 THEN -- RETIROS
            LET vtotretiros = 0;
        END IF;

        IF vtotcomcobrada IS NULL THEN -- COMISIONES COBRADAS
            LET vtotcomcobrada = 0;
        END IF;

        IF vtotcombonif IS NULL THEN -- COMISIONES BONIFICADAS
            LET vtotcombonif = 0;
        END IF;

        LET vtotcomcobrada = vtotcomcobrada - vtotcombonif; -- COMISION TOTAL

        IF vtotivacobrado IS NULL THEN -- IVA COBRADO
            LET vtotivacobrado = 0;
        END IF;

        IF vtotivabonif IS NULL THEN -- IVA BONIFICADO
            LET vtotivabonif = 0;
        END IF;

        LET vtotivacobrado = vtotivacobrado - vtotivabonif;  -- IVA TOTAL

        IF vtotintpag IS NULL THEN -- INTERESES
            LET vtotintpag = 0;
        END IF;

        IF vtotisrcobrado IS NULL THEN -- ISR
            LET vtotisrcobrado = 0;
        END IF;
        
        IF vtotretirosefec IS NULL THEN
            LET vtotretirosefec = 0;
        END IF;
        
        LET vtototroscargos = vtototroscargos - vtotretirosefec;
        
        IF vtototroscargos is null OR vtototroscargos < 0 THEN
            LET vtototroscargos = 0;
        END IF;

        -- // OBTIENE LA TASA
        LET vtasa_bruta = 0;
        LET vcuantos = 0;

        SELECT NVL(SUM(md.tasa_aplicada), 0), COUNT(*)
          INTO vtasa_bruta, vcuantos
          FROM sc_movhis md
         WHERE md.empresa = eEmpresa
           AND md.cuenta = eCuenta
           AND md.fech_alt = vfechafin
           AND md.cancelad <> 'S'
           AND md.transacc = vgtrans_pag_int;

        IF vcuantos > 0 THEN
            LET vtasa_bruta = vtasa_bruta / vcuantos;
        END IF;
        
        IF vtasa_bruta is null OR vtasa_bruta = '' THEN
            LET vtasa_bruta = 0;
        END IF;
        
        -- // EXTRAE SALDO DEL MES ANTERIOR
        SELECT sdo_actual
          INTO vsdo_mes_ant
          FROM sc_maehis
         WHERE empresa = eEmpresa
           AND cuenta = eCuenta
           AND aniomes = (SELECT MAX(aniomes)
                            FROM sc_maehis
                           WHERE empresa = eEmpresa
                             AND cuenta = eCuenta);

        IF vsdo_mes_ant is null THEN
            LET vsdo_mes_ant = 0;
        END IF;
        
        LET vdifdias = vfechaini - vultfechafin;
        
        IF vdifdias > 31 THEN
            LET vaniomes = YEAR(vfechaini)||LPAD(MONTH(vfechaini),2,'0');
            LET vsdo_mes_ant = vsdo_actual - vtotdepositos + vtotretiros + vtotcomcobrada + vtotivacobrado - vtotintpag + vtotisrcobrado;
        END IF;
        
        -- // OBTIENE VALOR GAT PARA INVERSIONES CRECIENTES
        SELECT valor
          INTO vprodcrec
          FROM sc_param
         WHERE empresa = eEmpresa
           AND codparam = 'PRODCREC';
           
        IF vproducto = vprodcrec THEN            
            SELECT valor_tasa
              INTO vtasa_gat
              FROM sc_tasa_variable
             WHERE empresa = eEmpresa
               AND cuenta = eCuenta
               AND inicio_periodo < vfechafin
               AND tipo_tasa = 'P';
               
            SELECT gat_nominal, gat_real
              INTO vgat, vgat_real
              FROM sc_gat
             WHERE producto = vprodcrec
               AND tasa = vtasa_gat;
        END IF;

        -- // INSERTA REGISTRO HISTORICO
        INSERT INTO sc_maehis VALUES
        (eEmpresa, vaniomes, eCuenta, vfechaini, vfechafin, vcuenta_clabe, '', vsucursal, vproducto, 
         vnum_cte, vstatus_cta, vmotivo, vfec_cancelac, vsdo_retenido, vsdo_cong, vsdo_actual, venvio_direcc, vdirecc_envio,
         vsdo_mes_ant, eAcumSdoPos, eDiaSdoPos, vacum_sdo_int, vdias_acum_int, vtasa_bruta, vret_mes_ant, vcong_mes_ant,
         vlim_sbg_ccc, vimp_sbg_ccc, vimp_chq_sbg, vsaldo_sbc, vint_acum, visr_acum, vtotdepositos, vtotretiros, vtotintpag,
         vtotcomcobrada, vtotivacobrado, vtotisrcobrado, vtotretirosefec, vtototroscargos, vgat, vgat_real);

        -- // LIMPIA CARGOS Y ABONOS EN EL MAESTRO DE CHEQUES
        UPDATE sc_maechq
           SET num_cgos_mes = 0,
               imp_cgos_mes = 0,
               num_abonos_mes = 0,
               imp_abonos_mes = 0
         WHERE empresa = eEmpresa
           AND cuenta = eCuenta;
           
        UPDATE sc_maenoc
           SET dia_sdo_pos   = 0,
               acum_sdo_pos  = 0.00,
               dias_acum_int = 0,
               acum_sdo_int  = 0.00,
               int_acum      = 0.00
         WHERE cuenta = eCuenta;
           
    END FOREACH;
    
    END;

    RETURN CodRet;

END PROCEDURE;