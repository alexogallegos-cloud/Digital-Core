CREATE PROCEDURE "informix".sp_portabprocesaalta( pOrigenAlta CHAR(20), 
                                                  pSucAlta CHAR(4), 
                                                  pNumCte CHAR(20), 
                                                  pNumCtaOrigen CHAR(20),
                                                  pBancoDest CHAR(3), 
                                                  pClabeDest CHAR(20), 
                                                  pTarjDest CHAR(20), 
                                                  pDiasDep CHAR(60),
                                                  pUsuario CHAR(8) )
RETURNING CHAR (5) AS CodigoRetorno,
		  CHAR (110) AS MensajeEjecucion;

    -- // DESCRIPCION DE LOS PARAMETROS DE ENTRADA
    /*  pOrigenAlta:   Origen de la alta. Valores esperados SIF(central), OFI(sucursal) y WEB(internet)
    pSucAlta:      Sucursal donde se realizo la alta del servicio de portabilidad
    pNumCte:       Numero del cliente que realizo la alta del servicio de portabilidad
    pNumCtaOrigen: Numero de la cuenta a la que se le activo el servicio de portabilidad
    pBancoDest:    Codigo del banco al que se le va a realizar la transferencia (deposito)
    pClabeDest:    Cuenta CLABE a la que se le realizara la transferencia (deposito)
    pTarjDest:     Numero de tarjeta de debito a la que se le realizara la transferencia (deposito)
    pDiasDep:      Dias que el cliente declaro sus ingresos
    pUsuario:	   Numero del usuario que realiza la alta 
    */

    -- // DECLARACION DE VARIABLES
    DEFINE iSqlErr INTEGER;				-- ERROR DE INFORMIX
    DEFINE cCodRet CHAR(5);				-- CODIGO DEL ERROR

    DEFINE cMensajeEjec  CHAR(110);		-- MENSAJE DE LA EJECUCION DEL PROCEDIMIENTO
    DEFINE cEstCta 	       CHAR(1);		-- ESTATUS DE LA CUENTA DE CAPTACION
    DEFINE cProdCta        CHAR(4);		-- PRODUCTO DE LA CUENTA DE CAPTACION
    DEFINE iSecuencia      INTEGER;		-- NUMERO DE SECUENCIA
    DEFINE cEstPortab      CHAR(2);		-- ESTATUS DEL SERVICIO DE PORTABILIDAD DE LA CUENTA
    DEFINE dfechahoy          DATE;		-- FECHA EN QUE SE DA DE ALTA LA CUENTA CON EL SERVICIO DE PORTABILIDAD
    DEFINE cNombreCte	 CHAR(110);		-- NOMBRE DEL CLIENTE BANCOPPEL
    DEFINE cRFC	          CHAR(20);		-- RFC DEL CLIENTE BANCOPPEL
    DEFINE cCorreo	     CHAR(100);		-- CORREO ELECTRONICO DEL CLIENTE BANCOPPEL
    DEFINE cCel		      CHAR(13);		-- TELEFONO CELULAR DEL CLIENTE BANCOPPEL
    DEFINE cCveCuenta	   CHAR(2);		-- CLAVE DE LA CUENTA
    DEFINE cCuenta	      CHAR(20);		-- CUENTA A INSERTAR EN LA TABLA PP_CTASTERCEROS
    DEFINE cDescripCta	  CHAR(20);		-- DESCRIPCION DE LA CUENTA A INSERTAR EN LA TABLA PP_CTASTERCEROS
    DEFINE cConsecutivo	   CHAR(2);		-- CONSECUTIVO CADENA
    DEFINE iConsec	       INTEGER;		-- CONSECUTIVO ENTERO
    DEFINE iCodRetdv1	   INTEGER;	    -- CODIGO DE RETORNO 1 DE LA EJECUCION DEL PROCEDIMIENTO sp_validadv
    DEFINE iCodRetdv2	   INTEGER;	    -- CODIGO DE RETORNO 2 DE LA EJECUCION DEL PROCEDIMIENTO sp_validadv
	DEFINE cNumerico	   CHAR(2);     -- VALIDA SI ES NUMERICO.
	
	
	
	
    -- // INICIALIZACION DE VARIABLES
    LET iSqlErr = 0;
    LET cCodRet = '00000';

    LET cMensajeEjec = 'LA ALTA DEL SERVICIO DE PORTABILIDAD SE HA REALIZADO EXITOSAMENTE';
    LET cEstCta      = '';
    LET cProdCta     = '';
    LET iSecuencia   =  0;
    LET cEstPortab   = '';
    LET dfechahoy    = '';
    LET cNombreCte   = '';
    LET cRFC		 = '';
    LET cCorreo		 = '';
    LET cCel		 = '';
    LET cCveCuenta   = '';
    LET cCuenta	     = '';
    LET cDescripCta  = 'PORTABILIDAD';
    LET cConsecutivo = '';
    LET iConsec      = 0;
    LET iCodRetdv1   = 0;
    LET iCodRetdv2   = 0;
	LET cNumerico	 = '';
	
	
    BEGIN
    
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cMensajeEjec = 'ERROR INESPERADO EN LA EJECUCION DEL PROCEDIMIENTO';
            RETURN cCodRet, cMensajeEjec;
        END IF;
    END EXCEPTION;

       --SET DEBUG FILE TO "/informix/VILLELA/sp_portabprocesaalta.out";
	   --TRACE ON;
	

    SET ISOLATION TO DIRTY READ;

    -- se valida que los parametros traigan datos
    IF pOrigenAlta = '' OR pOrigenAlta IS NULL OR pSucAlta = '' OR pSucAlta IS NULL OR pNumCte = '' OR pNumCte IS NULL OR
       pNumCtaOrigen = '' OR pNumCtaOrigen IS NULL OR pBancoDest = '' OR pBancoDest IS NULL OR pDiasDep = '' OR pDiasDep IS NULL OR
       pUsuario = '' OR pUsuario IS NULL THEN
        LET cCodRet = '00001';
        LET cMensajeEjec = 'ERROR EN LOS PARAMETROS; TODOS LOS PARAMETROS SON OBLIGATORIOS. VERIFIQUE';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que la CLABE y el numero de tarjeta no vengan vacios al mismo tiempo
    IF (pClabeDest = '' OR pClabeDest IS NULL) AND (pTarjDest = '' OR pTarjDest IS NULL) THEN
        LET cCodRet = '00002';
        LET cMensajeEjec = 'ERROR EN LOS PARAMETROS; NO PUEDEN RECIBIRSE CUENTA CLABE Y NUMERO DE TARJETA VACIOS. VERIFIQUE';
        RETURN cCodRet, cMensajeEjec;	
    END IF;

    -- se valida que la CLABE y el numero de tarjeta no vengan llenos al mismo tiempo
    IF (pClabeDest <> '') AND (pTarjDest <> '') THEN
        LET cCodRet = '00003';
        LET cMensajeEjec = 'ERROR EN LOS PARAMETROS; NO PUEDEN RECIBIRSE CUENTA CLABE Y NUMERO DE TARJETA LLENOS. VERIFIQUE';
        RETURN cCodRet, cMensajeEjec;	
    END IF;

    -- se valida que exista la sucursal de la alta
    IF NOT EXISTS (SELECT sucursal FROM bdinteg:si_sucursales WHERE empresa = '001' and sucursal = pSucAlta) THEN	
        LET cCodRet = '00004';
        LET cMensajeEjec = 'CODIGO DE SUCURSAL NO VALIDO; NO EXISTE EN EL CATALOGO DE SUCURSALES';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que exista el cliente bancoppel
    IF NOT EXISTS (SELECT numcte FROM bdinteg:si_cliente WHERE empresa = '001' and numcte = pNumCte) THEN
        LET cCodRet = '00005';
        LET cMensajeEjec = 'NUMERO DE CLIENTE NO VALIDO; NO EXISTE EN EL MAESTRO DE CLIENTES BANCOPPEL';
        RETURN cCodRet, cMensajeEjec;
    END IF;	

    -- se obtiene el estatus y el producto de la cuenta de cheques
    SELECT status_cta, producto
      INTO cEstCta, cProdCta
      FROM bdicheq:sc_maechq
     WHERE empresa = '001'
       AND cuenta = pNumCtaOrigen;

    -- se valida que exista la cuenta de cheques
    IF cProdCta IS NULL OR cProdCta = '' THEN
        LET cCodRet = '00006';
        LET cMensajeEjec = 'NUMERO DE CUENTA NO VALIDO; NO EXISTE EN EL MAESTRO DE CUENTAS DE CHEQUES';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que exista el codigo del banco
    IF NOT EXISTS (SELECT banco FROM bdinteg:si_bancos WHERE banco = pBancoDest) THEN
        LET cCodRet = '00007';
        LET cMensajeEjec = 'CODIGO DEL BANCO DESTINO NO VALIDO; NO EXISTE EN EL CATALOGO DE BANCOS';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que exista el usuario
    IF NOT EXISTS (SELECT ejecutivo FROM bdinteg:si_ejecut WHERE empresa = '001' and ejecutivo = pUsuario) THEN
        LET cCodRet = '00008';
        LET cMensajeEjec = 'CODIGO DEL USUARIO NO VALIDO; NO EXISTE EN EL CATALOGO DE EJECUTIVOS';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se valida que venga la cuenta clabe y no el numero de tarjeta
    IF pClabeDest <> '' AND pTarjDest = '' THEN
        -- se valida que la longitud de la cuenta clabe sea de 18 caracteres
        IF LENGTH(pClabeDest) <> 18 THEN
            LET cCodRet = '00011';
            LET cMensajeEjec = 'LA CUENTA CLABE ES INCORRECTA; EL NUMERO DE CARACTERES DE LA CUENTA CLABE ES INCORRECTO';
            RETURN cCodRet, cMensajeEjec;
        END IF;
        
        -- se valida que la cuenta clabe sea correcta al comparar los primeros 3 digitos con el codigo del banco
        IF pBancoDest = SUBSTR(pClabeDest, 1, 3) THEN
            -- se ejecuta un procedimiento para validar si el digito verificador de la cuenta clabe es valido
            EXECUTE PROCEDURE bdispei:sp_validadv(pClabeDest) 
            INTO iCodRetdv1, iCodRetdv2;
            
            -- se valida que el digito verificador es valido
            IF iCodRetdv1 = 0 AND iCodRetdv2 = 1 THEN
                LET cCveCuenta = '02';
                LET cCuenta = TRIM(pClabeDest);
            ELSE
                -- se valida que el digito verificador es invalido
                LET cCodRet = '00012';
                LET cMensajeEjec = 'LA CUENTA CLABE ES INCORRECTA; ULTIMO NUMERO (DIGITO VERIFICADOR) INVALIDO';
                RETURN cCodRet, cMensajeEjec;			
            END IF;			
        ELSE
            LET cCodRet = '00009';
            LET cMensajeEjec = 'LA CUENTA CLABE ES INCORRECTA; LOS PRIMEROS 3 DIGITOS NO SON IGUALES AL CODIGO DEL BANCO';
            RETURN cCodRet, cMensajeEjec;
        END IF;
    -- se valida que venga el numero de tarjeta y no la cuenta clabe
    ELIF pTarjDest <> '' AND pClabeDest = '' THEN
        LET cCveCuenta = '03';
        LET cCuenta = TRIM(pTarjDest);
    END IF;

    -- se valida que el estatus no este cancelada
    IF cEstCta IN('2','6','7','8') THEN
        LET cCodRet = '10000';
        LET cMensajeEjec = 'LA CUENTA BANCOPPEL SE ENCUENTRA CANCELADA';
        RETURN cCodRet, cMensajeEjec;
    END IF;	

    -- se valida que el producto de la cuenta de captacion aplica para la activacion del servicio de portabilidad	
    IF NOT EXISTS(SELECT valor 
                    FROM bdicheq:sc_param 
                   WHERE empresa = '001'
                     AND codparam = 'PORTAPRODPERM'
                     AND valor LIKE '%'||cProdCta||'%') THEN
        LET cCodRet = '00010';
        LET cMensajeEjec = 'EL PRODUCTO DE LA CUENTA NO ES SUSCEPTIBLE PARA LA ACTIVACION DEL SERVICIO DE PORTABILIDAD';
        RETURN cCodRet, cMensajeEjec;
    END IF;	

    -- se obtiene la maxima secuencia del registro para la cuenta de cheques con el servicio de portabilidad
    SELECT MAX(secuencia)
      INTO iSecuencia
      FROM bdicheq:sc_portabilidadnomina 
     WHERE empresa = '001'
       AND cliente = pNumCte
       AND cuenta_abono = pNumCtaOrigen;

    -- se obtiene el estatus del registro de la maxima secuencia para la cuenta de cheques con el servicio de portabilidad
    SELECT estatus
      INTO cEstPortab
      FROM bdicheq:sc_portabilidadnomina
     WHERE empresa = '001'
       AND cliente = pNumCte
       AND cuenta_abono = pNumCtaOrigen
       AND secuencia = iSecuencia;

    -- se valida que el estatus no este activo
    IF cEstPortab = '01' THEN
        LET cCodRet = '20000';
        LET cMensajeEjec = 'LA CUENTA BANCOPPEL YA CUENTA CON EL SERVICIO DE PORTABILIDAD ACTIVO';
        RETURN cCodRet, cMensajeEjec;
    END IF;

    -- se obtiene la fecha de la alta del servicio de portabilidad
    SELECT fecha_hoy
      INTO dfechahoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';

    -- se obtiene el nombre, el rfc, el email y el celular del cliente bancoppel
    SELECT TRIM(cte.nombre1) || ' ' || TRIM(cte.nombre2) || ' ' || TRIM(cte.apell_paterno) || ' ' || TRIM(cte.apell_materno),
           TRIM(cte.rfc), TRIM(core.correo_elec), TRIM(tel2.telefono)
      INTO cNombreCte,cRFC, cCorreo, cCel
      FROM bdinteg:si_cliente cte
      left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
      left outer join bdinteg:si_correos core on (core.numcte = cte.numcte and core.tipo_correo = 1 and core.status_correo ='A')
     WHERE cte.numcte = pNumCte;
    --- AND c.secuencia = (SELECT MAX(secuencia) 
    --- FROM bdinteg:si_direcciones 
    --- WHERE numcte = pNumCte
    --- AND tipo_dir = 1
    --- AND (c.tipo_telef2 = 'C' OR c.tipo_telef2 = ''))

    -- se valida que la cuenta de cheques es la primera vez que se le activa el servicio de portabilidad
    IF iSecuencia IS NULL THEN
        LET iSecuencia = 1;
    ELSE
        -- se valida que la cuenta de cheques ya tuvo el servicio de portabilidad
        LET iSecuencia = iSecuencia + 1;		
    END IF;

    -- se registra la activacion del servicio de portabilidad en la tabla de cheques
    INSERT INTO bdicheq:sc_portabilidadnomina 
    (empresa, cliente, cuenta_abono, secuencia, banco_ref,
     cuenta_ref, tarjeta_ref, fecha_deposito, estatus, user_cancel, fecha_cancel,
     origen_alta, sucursal_alta, origen_cancel, sucursal_cancel, user_insert, fecha_insert)
    VALUES 
    ('001', TRIM(pNumCte), TRIM(pNumCtaOrigen), iSecuencia, TRIM(pBancoDest),
     TRIM(pClabeDest), TRIM(pTarjDest), TRIM(UPPER(pDiasDep)), '01', NULL, NULL,
     UPPER(pOrigenAlta), TRIM(pSucAlta), NULL, NULL, TRIM(pUsuario), dfechahoy);

    -- se valida que si el celular viene con lada se borre la lada por el tamaño del campo en la tabla bdiprog:pp_ctasterceros
    IF LENGTH(cCel) > 10 THEN
        LET cCel = SUBSTR(cCel, 4, 13);	
    END iF;

	
    -- se valida que el registro para el cliente, la cuenta destino y la clave del banco destino sea diferente a las existentes
    IF EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco <> pBancoDest) THEN
        -- se valida que el registro para el cliente, la cuenta destino y la clave del banco destino existan
        IF EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco = pBancoDest) THEN
            -- se actualiza el registro correspondiente a la activacion del servicio segun el cliente, cuenta y banco recibido
            UPDATE bdiprog:pp_ctasterceros
               SET cve_cuenta = cCveCuenta,
                   nombre = cNombreCte,
                   cve_compania = '00',
                   cve_estado = '01',
                   no_celular = TRIM(cCel),
                   canal_baja = NULL,
                   fecha_estado = dfechahoy,
                   user_insert = pUsuario, 
                   fecha_insert = dfechahoy, 
                   hora_insert = CURRENT HOUR TO SECOND
             WHERE num_cte = pNumCte
               AND cuenta = cCuenta
               AND cve_banco = pBancoDest;

            RETURN cCodRet, cMensajeEjec;
        END IF;		

		
		
		   -- se obtiene el maximo valor del numero diferenciador
          SELECT (SUBSTR(descrip_cta, 16, 2))
          INTO cNumerico
          FROM bdiprog:pp_ctasterceros
          WHERE num_cte = pNumCte
          AND cuenta = cCuenta;
		
		
		IF  bdiprog:isnumeric(cNumerico ) = '1'  THEN
		
				-- se obtiene el maximo valor del numero diferenciador
				SELECT (MAX(SUBSTR(descrip_cta, 16, 2)) + 1)::INTEGER
				  INTO iConsec
				  FROM bdiprog:pp_ctasterceros
				 WHERE num_cte = pNumCte
				   AND cuenta = cCuenta;

		ELSE  
		   
		LET iConsec = '01';    
		   
		END IF   
		   
        -- se le anexa un '0' a la izquierda al valor obtenido en caso de que sea un valor de un solo digito
        LET cConsecutivo = LPAD(iConsec, 2, '0');

        -- se concantena la descripcion del proceso (PORTABILIDAD) mas un '-' con el consecutivo armado
        LET cDescripCta = TRIM(cDescripCta) || ' - ' || cConsecutivo;

        -- se inserta en la tabla para cuando no sea el primero registro para la cuenta y cliente, y para un diferente banco
        INSERT INTO bdiprog:pp_ctasterceros 
        (num_cte, cuenta, cve_banco, descrip_cta, cve_cuenta,
         nombre, rfc, direc_correo, cve_compania, cve_estado, no_celular, canal_alta, canal_baja,
         fecha_estado, user_insert, fecha_insert, hora_insert)
        VALUES 
        (TRIM(pNumCte), TRIM(cCuenta), TRIM(pBancoDest), TRIM(cDescripCta), cCveCuenta,
         TRIM(cNombreCte), TRIM(cRFC), TRIM(cCorreo), '00', '01', TRIM(cCel), '01', NULL,
         dfechahoy, TRIM(pUsuario), dfechahoy, CURRENT HOUR TO SECOND);

    -- se valida que no exista el registro para el cliente, cuenta y banco recibido
    ELIF NOT EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco = pBancoDest) THEN

        -- se concantena la descripcion del proceso (PORTABILIDAD) mas un '-' con el consecutivo inicial
        LET cDescripCta = TRIM(cDescripCta) || ' - ' || '01';

        -- se inserta en la tabla para cuando sea el primer registro para la cuenta, cliente y banco
        INSERT INTO bdiprog:pp_ctasterceros 
        (num_cte, cuenta, cve_banco, descrip_cta, cve_cuenta,
         nombre, rfc, direc_correo, cve_compania, cve_estado, no_celular, canal_alta, canal_baja,
         fecha_estado, user_insert, fecha_insert, hora_insert)
        VALUES 
        (TRIM(pNumCte), TRIM(cCuenta), TRIM(pBancoDest), TRIM(cDescripCta), cCveCuenta,
         TRIM(cNombreCte), TRIM(cRFC), TRIM(cCorreo), '00', '01', TRIM(cCel), '01', NULL,
         dfechahoy, TRIM(pUsuario), dfechahoy, CURRENT HOUR TO SECOND);

    -- se valida que exista el registro para el cliente, cuenta y banco recibido
    ELIF EXISTS (SELECT num_cte FROM bdiprog:pp_ctasterceros WHERE num_cte = pNumCte AND cuenta = cCuenta AND cve_banco = pBancoDest) THEN

        -- se actualiza el registro correspondiente a la activacion del servicio segun el cliente, cuenta y banco recibido
        UPDATE bdiprog:pp_ctasterceros
           SET cve_cuenta = cCveCuenta,
               nombre = cNombreCte,
               cve_compania = '00',
               cve_estado = '01',
               no_celular = TRIM(cCel),
               canal_baja = NULL,
               fecha_estado = dfechahoy,
               user_insert = pUsuario, 
               fecha_insert = dfechahoy, 
               hora_insert = CURRENT HOUR TO SECOND
         WHERE num_cte = pNumCte 
           AND cuenta = cCuenta 
           AND cve_banco = pBancoDest;
    END IF;

    RETURN cCodRet, cMensajeEjec;
    
    END
    
END PROCEDURE

DOCUMENT
'DESCRIPCION: Genera la alta del servicio de portabilidad de una cuenta',
'AUTOR: Clemente Angulo Ballardo',
'FECHA: 08 de Junio de 2010',
'VERSION: 20100608.1800',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_archivo_indicadores
(
)
RETURNING
	CHAR(6),
	CHAR(80)
---DECLARACIONES
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE cErrorInfo		CHAR(80);
	DEFINE cCodRet			CHAR(6);
	DEFINE cDescRet			CHAR(80);

	DEFINE cRuta			CHAR(100);
	DEFINE v_sql        	CHAR(1000);
	DEFINE cArchivo			CHAR(27);
	DEFINE cFechaHoy		CHAR(10);
	DEFINE cAnioMesAnte		CHAR(6);


	---INICIALIZACIONES
	LET iSqlErr             = 0;
	LET iIsamErr            = 0;
	LET cErrorInfo          = "";
	LET cCodRet             = "000000";
	LET cDescRet			= "PROCESO EXITOSO";

	LET cRuta				= "";
	LET v_sql  				= "";
	LET cArchivo			= "";
	LET cFechaHoy			= "";
	LET cAnioMesAnte		= "";


BEGIN
    ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescRet = cErrorInfo;
			RETURN cCodRet, cDescRet;
			END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	--SET DEBUG FILE TO '/informix/vamilan/sp_archivo_indicadores.out';
	--TRACE ON;
	
	LET cRuta = "/resplogifx/indicadores/";
	
	SELECT fecha_hoy, YEAR(fecha_hoy - 1 units MONTH) || LPAD(MONTH(fecha_hoy - 1 units MONTH),2,"0")
	INTO cFechaHoy, cAnioMesAnte
	FROM "informix".sc_fechas
	WHERE empresa = "001";
	
	LET cArchivo = SUBSTR(YEAR(cFechaHoy),3,2) || LPAD(MONTH(cFechaHoy),2,"0") || LPAD(DAY(cFechaHoy),2,"0") || "_internet_indicadores";

	--// HACE LA DESCARGA DEL ARCHIVO DE INDICADORES DE LOS CLIENTES CON INTERNET
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cArchivo) || '.txt' || 
		' SELECT t1.anio_mes, t3.numcte, t1.cuenta, t1.producto, num_depositos_vent, imp_acum_depositos_vent, ' ||
		' num_depositos_entrecta, imp_acum_depositos_entrecta, num_depositos_terc, imp_acum_depositos_terc, ' ||
		' num_depositos_corresp, imp_acum_depositos_corresp, num_deposito_spei, imp_acum_deposito_spei, ' ||
		' num_retiros_vent, imp_acum_retiros_vent, num_retiros_entrecta, imp_acum_retiros_entrecta, ' ||
		' num_retiros_terc, imp_acum_retiros_terc, num_retiros_atm, imp_acum_retiros_atm, ' ||
		' num_retiros_cashback, imp_acum_retiros_cashback, num_compra_pos, imp_acum_compra_pos, ' ||
		' num_compra_interred, imp_acum_compra_interred, num_retiro_spei, imp_acum_retiro_spei ' ||
		' FROM "informix".sc_indicadores t1, "informix".sc_maechq t2, bdinteg: "informix".si_cliente t3 ' ||
		' WHERE t1.anio_mes = ''' || cAnioMesAnte || ''' AND t1.cuenta = t2.cuenta AND t2.num_cte = t3.numcte AND t1.internet = 1; "'||
		' > query_descarga_archivo_internet_indicadores.sql';
	LET v_sql = TRIM(v_sql);
	SYSTEM v_sql;
	LET v_sql = "dbaccess bdicheq query_descarga_archivo_internet_indicadores.sql";
	SYSTEM v_sql;
	
	LET cArchivo = SUBSTR(YEAR(cFechaHoy),3,2) || LPAD(MONTH(cFechaHoy),2,"0") || LPAD(DAY(cFechaHoy),2,"0") || "_sdoprom_indicadores";
	LET v_sql = "";
	
	--// HACE LA DESCARGA DEL ARCHIVO DE INDICADORES DE LOS CLIENTES CON SU SALDO PROMEDIO Y SALDO MAXIMO EN EL MES
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cRuta) || TRIM(cArchivo) || '.txt' || 
	    ' SELECT {+ MULTI_INDEX(informix.sc_indicadores)} t1.anio_mes, t3.numcte, t1.cuenta, t1.producto, t1.saldo_maximo_mes, t1.saldo_promedio ' ||
		' FROM "informix".sc_indicadores t1, "informix".sc_maechq t2, bdinteg: "informix".si_cliente t3 ' ||
		' WHERE t1.anio_mes = ''' || cAnioMesAnte || ''' AND t1.cuenta = t2.cuenta AND t2.num_cte = t3.numcte; "'||
		' > query_descarga_archivo_sdoprom_indicadores.sql';
	LET v_sql = TRIM(v_sql);
	SYSTEM v_sql;
	LET v_sql = "dbaccess bdicheq query_descarga_archivo_sdoprom_indicadores.sql";
	SYSTEM v_sql;
	
	RETURN cCodRet, cDescRet;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para ',
'BD: bdicheq', 
'AUTOR: Mohamed Carreón ',
'FECHA: Agosto 2014';

CREATE PROCEDURE "informix".sp_generarchivoportab(pfecha_reg date,pnombrearchivo CHAR(30))
RETURNING 	CHAR(3),   --COT_RET
			INTEGER,   --TOTAL SOLICITUDES
			CHAR(80);  -- RUTA ARCHIVO


DEFINE sql_err		INTEGER;
DEFINE vcodret1     CHAR(5);

DEFINE vtotalSol	INTEGER;
DEFINE vruta		CHAR(80);
DEFINE vsSQL 		CHAR(1400);
DEFINE vsSQL1 		CHAR(400);
DEFINE vsSQL2 		CHAR(1500);
DEFINE vsSQL3 		CHAR(350);
DEFINE vsSQL4 		CHAR(350);
DEFINE vsumario		CHAR(360);
DEFINE vfiltra		CHAR(200);
DEFINE vencabezado	CHAR(100);
DEFINE vsumFuturo	CHAR(255);
DEFINE vRegistros	CHAR(7);
DEFINE vfecha_reg	CHAR(8);
DEFINE vsecuencia	CHAR(7);
DEFINE vRegisTot	SMALLINT;

LET vcodret1 = "001";
LET sql_err  = 0;

LET vtotalSol 	= "";
LET vruta 		= "";
LET vsSQL 		= "";
LET vsSQL1 		= "";
LET vsSQL2 		= "";
LET vsSQL3 		= "";
LET vsSQL4 		= "";
LET vsumario	= "";
LET vfiltra	    = "";
LET vencabezado	= "";
LET vRegistros	= "";
LET vfecha_reg	= "";
LET vsecuencia  = "";
LET vRegisTot   = 0;
LET vsumFuturo  = LPAD('',255);


BEGIN
	
	------  Control de Errores no Controlados
		ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            Let vcodret1 = sql_err;    
            RETURN vcodret1, vtotalSol, vruta;
        END IF;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/VILLELA/sp_generarchivoportab.out";
		--TRACE ON;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF LENGTH(NVL(pfecha_reg,'')) = 0 OR LENGTH(NVL(pnombrearchivo,'')) = 0 THEN
			LET vcodret1='001';
			RETURN vcodret1, vtotalSol, vruta;
		END IF;

        LET vfecha_reg = TRIM(YEAR(pfecha_reg)||LPAD(MONTH(pfecha_reg),2,0)||LPAD(DAY(pfecha_reg),2,0));

        SELECT valor
		INTO vruta 
		FROM BDICHEQ:sc_param 
		WHERE empresa = "001" 
		AND codparam = 'rta_ptsol';

        SELECT count(*)
        INTO vRegistros
		FROM sc_portacec_archivotemp;


        -- PROCESO DE GENERACION DE ARCHIVO
            LET vsecuencia= vRegistros + 2;
       
        IF vRegistros < 10 THEN
            LET vRegistros= LPAD(cast(vRegistros as CHAR(1)),7,'0');						
       
	    ELIF  vRegistros >= 10  AND  vRegistros < 100  THEN
            LET vRegistros= LPAD(cast(vRegistros as CHAR(2)),7,'0');			
       
	    ELSE		
		    LET vRegistros= LPAD(cast(vRegistros as CHAR(3)),7,'0');

        END IF;
        
	   	   
        IF vsecuencia < 10 THEN
            LET vsecuencia= LPAD(cast(vsecuencia as CHAR(1)),7,'0');
			
		ELIF  vsecuencia >= 10  AND vsecuencia < 100   THEN 
             LET vsecuencia= LPAD(cast(vsecuencia as CHAR(2)),7,'0');		
        ELSE
            LET vsecuencia= LPAD(cast(vsecuencia as CHAR(3)),7,'0');

        END IF;

   
		LET vsSQL1 = 'echo " SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vruta) ||  'Solicitudes.txt';
LET vsSQL2 = "SELECT '0100000012040137E" || vfecha_reg || "'||LPAD('',248) FROM sc_portacec_archivotemp UNION " ||
"SELECT  '02'||CASE WHEN secuencia+1 <= 9 THEN LPAD(cast(secuencia+1 as char(1)),7,'0') WHEN  secuencia+1 >= 10 AND  secuencia+1 < 100 THEN  TRIM(LPAD(cast(secuencia+1 as char(2)),7,'0'))ELSE TRIM(LPAD(cast(secuencia+1 as char(3)),7,'0')) END||'20'||folio_solicitud||fecha_solicitud||nombre_cte||" ||
"CASE WHEN rfc_cte is null or rfc_cte = '' or (length(rfc_cte) < 13) then 'ND' ||LPAD('',11) else rfc_cte end||cta_receptora||" ||
"tipo_cta_receptora||bco_receptor||CASE WHEN (length(cta_ordenante)<18) then '00'||TRIM(cta_ordenante) else cta_ordenante end||" ||
 "CASE WHEN (length(tipo_cta_ordenante)<2) then '0'||TRIM(tipo_cta_ordenante) else tipo_cta_ordenante end||bco_ordenante||fecha_nacimiento||" ||
"CASE WHEN rfc_empresa is null or rfc_empresa = '' or (length(rfc_empresa) < 13) or valrfcemp_cecoban(rfc_empresa) = '1' then 'ND' ||LPAD('',11) else rfc_empresa end||estatus_respuesta||" || 

"fecha_respuesta||CASE WHEN (curp_cte is null or curp_cte = '') or (length(curp_cte) < 18) then 'ND' ||LPAD('',16) else curp_cte end||" ||
"LPAD('',13) FROM sc_portacec_archivotemp";
	
			 
		LET vsSQL3 = '" >' || TRIM(vruta) || 'queryTem.sql';
		LET vsSQL = TRIM(vsSQL1) || ' ' || TRIM(vsSQL2) || ' ' || TRIM(vsSQL3);
  
        LET vfiltra= "sed 's/|$//g;/^$/d' " ||  TRIM(vruta) ||  "Solicitudes.txt " || " > " || TRIM(vruta) || TRIM(pnombrearchivo)||'.txt';
        LET vsumario = "echo '09"|| vsecuencia || "20" || vRegistros || vsumFuturo || "' >> " || TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
        
        
			IF LENGTH(NVL(vsSQL,'')) > 0 THEN
				SYSTEM vsSQL;
				LET vsSQL4 = '';
				LET vsSQL4 = '/ifxsif01/bin/dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
                --LET vsSQL4 = 'dbaccess bdicheq ' || TRIM(vruta) || 'queryTem.sql';
				SYSTEM vsSQL4;
                LET vcodret1='000';
            END IF
        
        
        SYSTEM vfiltra;
        SYSTEM vsumario;
       
       -- PROCESO DE ACTUALIZACION DE SOLICITUDES

           IF vcodret1='000' THEN
                           
				UPDATE {+ INDEX(sc_portacec_solicitud idx_sc_portacec_solicitud2)} sc_portacec_solicitud SET fecha_presentacion=vfecha_reg, estatus_cecoban='', fecha_estatus_cecoban='' 
				WHERE folio_solicitud IN(SELECT {+ INDEX(sc_portacec_archivotemp idx_sc_portacec_archivotemp)} folio_solicitud FROM sc_portacec_archivotemp);

				LET vcodret1='000';
				LET vtotalSol=vRegistros;
				LET vruta=TRIM(vruta) ||  TRIM(pnombrearchivo)||'.txt';
           END IF;

        RETURN vcodret1, vtotalSol, vruta;
END
END PROCEDURE
;