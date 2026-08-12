CREATE PROCEDURE "informix".sp_ctanvl2_regdomicilio( pNumCte CHAR(20),
                                                     pCalle CHAR(40),
                                                     pColonia CHAR(60),
                                                     pMunicipio CHAR(40),
                                                     pEntre_Calles CHAR(40),
                                                     pEntidad CHAR(2),
                                                     pLocalidad CHAR(3),
                                                     pCodPostal CHAR(5),
                                                     pNoCiudad CHAR(3),
                                                     pNoExt CHAR(10),
                                                     pNoInt CHAR(10),
                                                     pDepto CHAR(6),
                                                     pPais CHAR(3),
                                                     pNoCalle INTEGER,
                                                     pNoColonia INTEGER,
                                                     pUniHabi CHAR(1),
                                                     pManz SMALLINT,
                                                     pAndador SMALLINT,
                                                     pLote SMALLINT,
                                                     pEdif SMALLINT,
                                                     pObserva CHAR(80) )
RETURNING CHAR(5) AS codret;
    
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cExiste CHAR(1);
	DEFINE iExiste INTEGER;
	DEFINE iSecuencia INTEGER;
	DEFINE o_tipo_dir CHAR(1);
	DEFINE o_calle CHAR(40);
	DEFINE o_colonia VARCHAR(60);
	DEFINE o_entre_calles CHAR(40);
	DEFINE o_pais CHAR(3);
	DEFINE o_estado CHAR(2);
	DEFINE o_ciudad CHAR(3);
	DEFINE o_municipio CHAR(5);
	DEFINE o_cod_postal CHAR(5);
	DEFINE o_numerociudad SMALLINT;
	DEFINE o_numeroextcalle CHAR(10);
	DEFINE o_numerointcalle CHAR(10);
	DEFINE o_departamento CHAR(6);
	DEFINE o_numerocalle INTEGER;
	DEFINE o_numerocolonia INTEGER;
	DEFINE o_unidadhabitac CHAR(1);
	DEFINE o_manzana SMALLINT;
	DEFINE o_andador SMALLINT;
	DEFINE o_lote SMALLINT;
	DEFINE o_edificio SMALLINT;
	DEFINE o_observaciones VARCHAR(80);
	DEFINE cCoincideDir CHAR(1);
    DEFINE vFechInicio DATETIME YEAR TO FRACTION(5);
	DEFINE vFechFin DATETIME YEAR TO FRACTION(5);
	
	LET cCodRet = '000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cExiste = '';
	LET iExiste = 0;
	LET iSecuencia = 0;
	LET o_tipo_dir = '';
	LET o_calle = '';
	LET o_colonia = '';
	LET o_entre_calles = '';
	LET o_pais = '';
	LET o_estado = '';
	LET o_ciudad = '';
	LET o_municipio = '';
	LET o_cod_postal = '';
	LET o_numerociudad = 0;
	LET o_numeroextcalle = '';
	LET o_numerointcalle = '';
	LET o_departamento = '';
	LET o_numerocalle = 0;
	LET o_numerocolonia = 0;
	LET o_unidadhabitac = '';
	LET o_manzana = 0;
	LET o_andador = 0;
	LET o_lote = 0;
	LET o_edificio = 0;
	LET o_observaciones = '';
	LET cCoincideDir = '';
	LET vFechInicio = '';
	LET vFechFin = '';
	
	BEGIN
	
    ON EXCEPTION SET iSqlErr
        IF iSqlerr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // BANDERA DE INICO DE PROCESO (2) PARA DEPURACION  
    LET vFechInicio = CURRENT YEAR TO FRACTION(5);
    
    UPDATE bdinteg:si_ctanvl2_ctrl
       SET proceso        = 2,
           estatus        = 'I',
           fechora_inicio = vFechInicio,
           fechora_fin    = ""	  
     WHERE numcte         = pNumCte;
    
    -- // VALIDA CAMPOS REQUERIDOS
    IF pNumCte IS NULL OR pNumCte = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet;
		
    ELSE
        -- // ASIGNACION DE VALORES
      LET pEntidad = LPAD(TRIM(pEntidad),2,'0');
       -- LET pMunicipio = LPAD(TRIM(pMunicipio),5,'0');
	
	SELECT FIRST 1 {+INDEX (bdinteg:"informix".si_ciudades idx_estado_movil)} ciudad 
	INTO pLocalidad
	FROM bdinteg:si_ciudades WHERE nombre = pMunicipio AND estado=pEntidad; 

	LET pMunicipio = '00'|| pLocalidad;
	
	IF pLocalidad IS NULL OR pLocalidad= '' THEN
	      LET pLocalidad= '00' ;
		  LET pMunicipio= '0000';
		  
		  else 
			LET pMunicipio= '00'|| pLocalidad;

	 END IF;
    END IF;
    
    -- // VALIDA SI EL CLIENTE EXISTE
    SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente5)} 1 
      INTO cExiste
      FROM bdinteg:"informix".si_cliente
     WHERE empresa = cEmpresa 
       AND numcte = pNumCte;
    
    IF cExiste IS NULL THEN
        LET cCodRet = '384';
        RETURN cCodRet;
    END IF;
    
    -- // VALIDA ENTIDAD FEDERATIVA
    SELECT {+INDEX (bdinteg:"informix".si_estados inx_estado)} 1 
      INTO cExiste
      FROM bdinteg:"informix".si_estados
     WHERE estado = pEntidad;
    
    IF cExiste IS NULL THEN
        LET cCodRet = '402';
        RETURN cCodRet;
    END IF;
    
    -- // VALIDA PAIS
    SELECT 1 
      INTO cExiste
      FROM bdinteg:"informix".si_paises
     WHERE pais = pPais;
    
    IF cExiste IS NULL THEN
        LET cCodRet = '405';
        RETURN cCodRet;
    END IF;
    
    SELECT {+INDEX (bdinteg:"informix".si_direcciones idx_numcte)} MAX(secuencia) 
      INTO iSecuencia
      FROM bdinteg:"informix".si_direcciones 
     WHERE numcte = pNumCte;
    
    IF iSecuencia IS NULL THEN
        LET iSecuencia = 1;
        LET cCoincideDir = 'f';
    ELSE
        LET iSecuencia = iSecuencia + 1;
    END IF;
    
    IF iSecuencia > 1 THEN		
        -- // VALIDA SI LA DIRECCION DEL CLIENTE YA SE ENCUENTRA REGISTRADA
        SELECT {+INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_ctetpo)} 
               tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, 
               numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, 
               unidadhabitac, manzana, andador, lote, edificio, observaciones
          INTO o_tipo_dir, o_calle, o_colonia, o_entre_calles, o_pais, o_estado, o_ciudad, o_municipio, o_cod_postal, 
               o_numerociudad, o_numeroextcalle, o_numerointcalle, o_departamento, o_numerocalle, o_numerocolonia, 
               o_unidadhabitac, o_manzana, o_andador, o_lote, o_edificio, o_observaciones
          FROM bdinteg:"informix".si_direcciones_actual
         WHERE numcte = pNumCte 
           AND tipo_dir = '1';
        
        IF ( o_tipo_dir IS NOT NULL AND o_calle = pCalle AND o_colonia = pColonia AND
             o_entre_calles = pEntre_Calles AND o_pais = pPais AND o_estado = pEntidad AND
             o_ciudad = pLocalidad AND o_municipio = pMunicipio AND o_cod_postal = pCodPostal AND
             o_numerociudad = pNoCiudad AND o_numeroextcalle = pNoExt AND o_numerointcalle = pNoInt AND
             o_departamento = pDepto AND o_numerocalle = pNoCalle AND o_numerocolonia = pNoColonia AND
             o_unidadhabitac = pUniHabi AND o_manzana = pManz AND o_andador  = pAndador AND
             o_lote = pLote AND o_edificio = pEdif AND o_observaciones = pObserva ) THEN
            LET cCoincideDir = 't';
        ELSE
            LET cCoincideDir = 'f';
        END IF;
    END IF;
    
    -- // SE REGISTRA DIRECCION
    IF iSecuencia = 1 OR cCoincideDir = 'f' THEN
        IF o_tipo_dir is null OR o_tipo_dir = '' THEN
            LET o_tipo_dir = '1';
        END IF;
        
        INSERT INTO bdinteg:"informix".si_direcciones
        ( numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, numerociudad,  
          numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, unidadhabitac, manzana, andador, lote, edificio, observaciones )
        VALUES
        ( pNumCte, iSecuencia, o_tipo_dir, pCalle, pColonia, pEntre_Calles, pPais, pEntidad, pLocalidad, pMunicipio, pCodPostal, pNoCiudad,  
          pNoExt, pNoInt, pDepto, pNoCalle, pNoColonia, pUniHabi, pManz, pAndador, pLote, pEdif, pObserva );
            
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '379';
            RETURN cCodRet;
        END IF;
    END IF;
    
    -- // BANDERA FINAL DEL PROCESO (2) PARA LA DEPURACION
    LET vFechFin = CURRENT YEAR TO FRACTION(5);
    
    UPDATE bdinteg:si_ctanvl2_ctrl
       SET estatus     = 'F',
           fechora_fin = vFechFin	  
     WHERE numcte      = pNumCte
       AND proceso     = '2';
    
    RETURN cCodRet;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leon Amador',
'FECHA: 24/06/2020',
'DESCRIPCION: SPL encargado de realizar la validacion y registro del domicilio del cliente.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_limite_max(pNumcte CHAR(10),
                                          pCuenta CHAR(16),
                                          pOperacion CHAR(2),
                                          pCanal CHAR(2),         -- 01 - ATM, 02 - POS, 03 - PORTAL, 15 - EMPRESANET, 17 - BANCOPPEL MOVIL ONLINE.
                                          pFecha DATE,
                                          pMto_tot DECIMAL(16,2),
                                          pnumtarjeta CHAR (20))
RETURNING CHAR(5), CHAR (80), CHAR(1);

-- Declaracion de variables

    DEFINE sql_err      	    INTEGER;
    DEFINE isam_err     	    INTEGER;
    DEFINE vCodret1     	    CHAR(5);

    DEFINE vMtoacumcta          DECIMAL(16,2);
    DEFINE vLim_canal_pesos     DECIMAL(16,2);
    DEFINE vExiste              INTEGER;
    DEFINE vTipo_mensaje        CHAR(2);
    DEFINE vRestriccion         CHAR(2);
    DEFINE vMax_pesos           DECIMAL(16,2);
    DEFINE vMensaje1            CHAR (80);
    DEFINE vEnviar              CHAR(1);
    DEFINE vEmpresa             CHAR(3);
    DEFINE vEmail               CHAR(80);
    DEFINE vCorreoElec          CHAR(100); -- se agrega por la reingenieria
    DEFINE vNombre              CHAR(104);
    DEFINE vIndicador           CHAR(1);
    DEFINE vImporte             DECIMAL(16,2);
    DEFINE vEnviarMensaje       CHAR(60);
	DEFINE vOperacion           CHAR(2);   -- BGM SE DECLARA VARIABLE DE VOPERACION
    DEFINE Vtipo_tarjeta        CHAR(20);  -- RRG TIPO DE TARJETA TITULAR O ADICIONAL
	DEFINE vImporte2            CHAR(16);
	DEFINE vMontoTotal			CHAR(16);

	DEFINE vActivar_Limite      CHAR(100);
	DEFINE vCod_param           SMALLINT;
	DEFINE vMensaje2            CHAR (80);

	DEFINE v_fecha1             CHAR(200);
	DEFINE v_fecha              CHAR(06);
	DEFINE v_ano_wk             CHAR(04);
	DEFINE v_longitud           INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_cuenta				INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_subcadena			CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_mail_incorrecto	CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico

    DEFINE vExisteCta           SMALLINT;
    DEFINE vSistema             CHAR(2);
    DEFINE vSist                CHAR(2);

    DEFINE vTipoCorreo      	SMALLINT;
    DEFINE vStatusCorreo    	CHAR(1);
	
    DEFINE vsidmensaje 			CHAR(10);

	DEFINE vMax_pesos1 			DECIMAL(16,2);
	DEFINE vMax_pesos2 			DECIMAL(16,2);
	DEFINE vlimite_personalizado_rest1 SMALLINT;
	DEFINE vlimite_personalizado_rest2 SMALLINT;
	
	DEFINE vMax_pesosAC         DECIMAL(16,2);
	DEFINE vEnviarMensajeAC     CHAR(60);
	DEFINE vTipo_mensajeAC      CHAR(2);
	DEFINE vsidmensajeAC		CHAR(10);
	DEFINE vCambioPlantilla  	CHAR(1);
	DEFINE cRet					CHAR(5);
	DEFINE vValorUdi			DECIMAL(14,6);
	DEFINE vfecha				DATE;
	

-- Inicializacion de variables

    LET sql_err   = 0;
    LET isam_err  = 0;
    LET vCodret1  = '00000';

    LET vMtoacumcta         = 0.00;
    LET vLim_canal_pesos    = 0.00;
    LET vExiste             = 0;
    LET vTipo_mensaje       = '';
    LET vRestriccion        = '';
    LET vMax_pesos          = 0.00;
    LET vMensaje1           = 'El proceso concluyo exitosamente';
    LET vEnviar             = '';
    LET vEmpresa            = '001';
    LET vEmail              = '';
    LET vCorreoElec         = '';   -- se agrega por la reingenieria
    LET vNombre             = '';
    LET vIndicador          = '0';
    LET vImporte            = 0.00;
    LET vEnviarMensaje      = '';
	LET vImporte2			= '';
	LET vMontoTotal			= '';

    LET vActivar_Limite     = '';
    LET vCod_param          = 110;
    LET vMensaje2           = 'Validacion Inactiva';

    LET v_ano_wk            = YEAR(TODAY);
    LET v_ano_wk            = v_ano_wk[3,4];

    LET v_fecha             = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
	LET v_longitud          = 0;    -- BGM 31-08-2010 Variable para validacion de correo electronico
	LET v_cuenta            = 1;    -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_subcadena         = '';   -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_mail_incorrecto   = 'F';  -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET Vtipo_tarjeta       = '';   -- RRG 07-11-2011 Variable para tipo de tarjeta Titular o Adicional

    LET vExisteCta          = 0;
    LET vSistema            = '';

    LET vTipoCorreo = 0;
    LET vStatusCorreo = '';
	
	LET vMax_pesos1=0.00; --Variable para limites EmpresaNetPlus restriccion 01
	LET vMax_pesos2=0.00; --Variable para limites EmpresaNetPlus restriccion 02
	LET vlimite_personalizado_rest1=0;
	LET vlimite_personalizado_rest2=0;
	
	LET vMax_pesosAC        = 0.00;
	LET vEnviarMensajeAC    = '';
	LET vTipo_mensajeAC     = '';
    LET vsidmensajeAC	    = '';
	LET vCambioPlantilla	= 'F';
	LET cRet				= '';
	LET vValorUdi			= 0.00;
	LET vfecha				= DATE(1);

    --**************************************************************
     -- Creado por Raul Ramirez    01/Jul/2010
     -- Capitulo X Acumulado Diario y Preparacion para el envio de Mensaje
     -- Modificado el 03/03/2011, Se modifica el sp para envio de mensaje
     -- con informacion en particular para credito y debito, de transacciones
     -- realizadas en ATM y POS.
     -- Modificado el 17/01/2011, Se agrega el numero de tarjeta y el tipo
     -- para el armado del envio de mensaje.
     -- Se modifica el proceso por la reigenieria del Correo Electronico 26/03/12
	 
	 --Modificacion: para que consulte la tabla nueva de limites por empresa.
	 -- se agregan dos nuevas restricciones para EmpresaNetPlus.
	 --Fecha: 18 Agosto 2014
	 --Por: Berenice Noriega
	 --Liberado a produccion: 30-Enero-2015 	 
     --**************************************************************

    	--SET DEBUG FILE TO "/tmp/cristo/sp_limite_max.out";
    	--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err  --, isam_err
		--- GENERA BITACORA DIARIA DE ERROR SIN INTERRUMPIR EL PROCESO DE JOM
		SET DEBUG FILE TO 'log'||to_char(today, '%Y%m%d')||'.err' WITH APPEND;
		TRACE ON;

		IF sql_err <> 0 THEN
			LET vCodret1 = sql_err;
		END IF;

		LET vMensaje1 = 'Se produjo un error inesperado';  ---- 21/07/2010
		LET vIndicador = '0';                              ---- 21/07/2010

		RETURN vcodret1,vMensaje1,vIndicador;   -- Termina proceso del SP 21/07/2010

	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
            --------    AGREGAR LA VALIDACION DEL NUMETO DE TARJETA
    IF (pNumcte is null OR pNumcte = '') OR --LENGTH(pNumcte) <> 10) OR
       (pCuenta is null OR pCuenta = '') OR --LENGTH(pCuenta) <> 16) OR
       (pOperacion is null OR pOperacion = '' OR pOperacion = '00' OR LENGTH(pOperacion) <> 2) OR
       (pCanal is null OR pCanal = '' OR pCanal <= '00' OR LENGTH(pCanal) <> 2) OR
       (pFecha is null OR pFecha = '') AND
       (pMto_tot is null OR pMto_tot <= 0.00) THEN


        LET vcodret1 = '00030';
        LET vMensaje1 = 'Se genero algÃÂºn error en la ejecucion';

        RETURN vcodret1,vMensaje1,vIndicador;
    END IF;

	-- Obtiene el Parametro para su Validacion y asignar el valor indicado en VACTIVAR_LIMITES
	SELECT valor
	INTO vActivar_Limite
	FROM bdinteg:"informix".si_param
	WHERE empresa = vEmpresa
	AND cod_param = vCod_param;

    IF vActivar_Limite = 'F' THEN              -- Validacion del Parametro de la tabla si_param
       RETURN vcodret1,vMensaje2,vIndicador;   -- Termina proceso del SP
    END IF;

	-- Verifica si ya existe un registro en la tabla si_limite_diario, para esa combinacion de cuenta / canal.
	-- En caso de que no exista, lo inserta.

	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACIÃÂN DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		LET vOperacion = pOperacion;
	ELSE
		LET vOperacion = '00';
	END IF;

	SELECT {+index (si_limite_diario idx_limite_dia)} count (*)
	INTO vExiste
	FROM bdinteg:si_limite_diario
	WHERE f_operacion = pFecha
	AND cuenta = pCuenta
	AND numcte = pNumcte
	AND id_canal = pCanal
	AND id_operacion = vOperacion;  -- BGM SE CAMBIA VARIABLE A VOPERACION


	IF vExiste = 0 THEN
		INSERT INTO bdinteg:si_limite_diario VALUES
		(pFecha, pCuenta, pNumcte, pCanal, vOperacion, 0.00);  -- BGM SE MODIFICA VARIABLE PARA PARAMETRO DE ID OPERACION
	END IF;

	-- Si ya existe un registro en si_limite_diario, se asegura que el campo importe_dia tenga un valor vÃÂ¡lido.

	IF vExiste >= 1 THEN
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION

		IF vImporte is null or vImporte = '' THEN
			UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario SET importe_dia = 0.00
			WHERE f_operacion = pFecha
			AND cuenta = pCuenta
			AND numcte = pNumcte
			AND id_canal = pCanal
			AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
			
			LET vImporte = 0.00;
		END IF
	END IF;
	
	    --- Validacion para indentificar la cuenta, para el envio de mensaje correspondiente debito o credito.
	SELECT {+index (bdicheq:sc_maechq idx_maechq1)} COUNT(*)
	INTO vExisteCta
	FROM bdicheq:sc_maechq
	WHERE empresa = vEmpresa
	AND cuenta = pCuenta;

    IF vExisteCta > 0 THEN
        LET vSist = '01';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en debito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    ELSE
		LET vSist = '06';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en credito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    END IF;

	---- VALIDACION DE MONTO POR CANAL
	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACIÃÂN DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		 LET vOperacion = pOperacion;

		--******************************************************************************************************************--
		---INICIA PRIMERA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
		--******************************************************************************************************************--
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND num_cta= pcuenta
			AND id_restriccion='01'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos1
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND num_cta= pcuenta
			AND id_restriccion = '01'; --En la tabla si_plimites_empresas la restruccion 01 es por el ACUMULADO por cuenta-operacion-cliente
			
			LET vlimite_personalizado_rest1=1;		
			
		END IF;	
		
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND id_restriccion='02'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos2
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND id_restriccion = '02'; --En la tabla si_plimites_empresas la restriccion 02 es por CADA OPERACION.
			
			LET vlimite_personalizado_rest2=1;					
		END IF;	

		IF vlimite_personalizado_rest1= 0 THEN --
			--**TERMINA PRIMERA PARTE DE MODIFICACION***************************************************************************--			 
			SELECT {+index (si_plimites idx_plimites)} tope_max_pesos
			INTO vMax_pesos
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND id_restriccion = '02'
			AND sistema = vSist;

		END IF;
	ELSE --Else, si no se trata de canal pCanal = '03' OR pCanal = '15' OR pCanal = '17' 
		LET vOperacion = '00';
		SELECT {+index (si_canales idx_canal)} limite_canal_pesos
		INTO vMax_pesos
		FROM bdinteg:si_canales
		WHERE id_canal = pCanal;
	END IF

	IF vlimite_personalizado_rest2=1 and pMto_tot > vMax_pesos2 THEN --si existe un limite por operacion,vMax_pesos es de si_plimites_empresas
		LET vcodret1 = '00035'; --00036
		LET vMensaje1 = 'Importe de la operacion excede el lÃÂ­mite diario permitido para el transaccion';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;
		
	ELIF vlimite_personalizado_rest1=1 and (pMto_tot + vImporte) > vMax_pesos1 THEN --Si existe limite por cuenta-operacion, 
		LET vcodret1 = '00035'; --00037
		LET vMensaje1 = 'Importe de la operacion excede el lÃÂ­mite diario permitido para el cuenta';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;

	ELIF vlimite_personalizado_rest1=0 and (pMto_tot + vImporte) > vMax_pesos   THEN --se agrega el if vlimite_personalizado=0
		LET vcodret1 = '00035';
		LET vMensaje1 = 'Importe de la transaccion excede el lÃÂ­mite diario permitido para el canal';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador; -- Termina proceso del SP
	ELSE
		--  SELECCIONA EL IMPORTE QUE TIENE PARA PROCEDER CON LA ACTUALIZACION
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;	-- BGM SE MODIFICA VALOR DE ID OPERACION

		--  ACTUALIZA ACUMULADO
		UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario
		SET importe_dia = vImporte + pMto_tot
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
		LET vIndicador = '0';
		--END IF;
		--RETURN vCodret1, vMensaje1, vIndicador WITH RESUME;  --------*****************
	END IF;

    LET venviar = 'F';

    --- Validacion para indentificar la cuenta, para el envio de mensaje correspondiente debito o credito.
	SELECT {+index (bdicheq:sc_maechq idx_maechq1)} COUNT(*)
	INTO vExisteCta
	FROM bdicheq:sc_maechq
	WHERE empresa = vEmpresa
	AND cuenta = pCuenta;

    IF vExisteCta > 0 THEN
        LET vSist = '01';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en debito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    ELSE
		LET vSist = '06';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en credito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    END IF
	

	--******************************************************************************************************************--
	--INICIA SEGUNDA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
	--******************************************************************************************************************--
	IF vlimite_personalizado_rest1=0 THEN --Si no se encontro en la tabla de limites entonces entra a validar los limites generales
		--**TERMINA SEGUNDA PARTE DE LA MODIFICACION************************************************************************--

		FOREACH

			SELECT {+index (si_plimites idx_plimites)} id_restriccion, tope_max_pesos, envio_mensaje, id_tipo_mensaje,sistema, id_mensaje
			INTO vRestriccion, vMax_pesos, vEnviarMensaje, vTipo_mensaje, vSistema, vsidmensaje
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND sistema = vSist


			IF vRestriccion = '01' THEN  -- OBTIENE IMPORTE DEL CAMPO IMPORTE_DIA y lo asigna en variable vImporte
				IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACIÃÂN DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
					LET vOperacion = pOperacion;
				ELSE
					LET vOperacion = '00';
				END IF

				SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
				INTO vImporte
				FROM bdinteg:si_limite_diario
				WHERE f_operacion = pFecha
				AND cuenta = pCuenta
				AND numcte = pNumcte
				AND id_canal = pCanal
				AND id_operacion = vOperacion;	-- BGM se usara la variable vOperacion en lugar del parametro pOperacion

				IF vImporte > vMax_pesos THEN
					LET vEnviar = 'V';              -- ACTUALIZA VARIABLE vEnviar
				END IF;
				
			END IF;

			IF vlimite_personalizado_rest2=0 THEN --Si la empresa no tiene personalisado para cada operacion
				IF vRestriccion = '02' THEN  --  Se valida que el monto de la transaccion sea mayor al limite en pesos
					
					EXECUTE PROCEDURE intercard:"informix".sp_obtener_udi('001',today)
					INTO cRet,vValorUdi,vfecha;
					
					-- Se obtiene valor del tope de acumulado para transaccion POS DEB y CRED 600 UDIS
					SELECT {+index (si_plimites idx_plimites)} (tope_max_udis*vValorUdi), envio_mensaje, id_tipo_mensaje,id_mensaje
					INTO vMax_pesosAC, vEnviarMensajeAC, vTipo_mensajeAC,  vsidmensajeAC
					FROM bdinteg:si_plimites
					WHERE id_operacion = '09'
					AND id_canal = pCanal
					AND sistema = vSist
					AND id_restriccion = '02';
					

					
					IF (vImporte+pMto_tot) > vMax_pesosAC AND NVL(vMax_pesosAC,0) > 0 THEN
						LET vImporte = vImporte+pMto_tot;
						LET vEnviar = 'V';
						
						IF vImporte > vMax_pesosAC AND vEnviarMensajeAC = 'V' THEN
							LET vCambioPlantilla= 'V';
							LET vEnviarMensaje = vEnviarMensajeAC;
							LET vTipo_mensaje = vTipo_mensajeAC;
							LET vsidmensaje = vsidmensajeAC;
						END IF;
					
					ELIF pMto_tot > vMax_pesos THEN
						LET vImporte = pMto_tot;
						LET vEnviar = 'V';

					END IF;
				END IF;
			END IF;

			IF vEnviar = 'V' and vEnviarMensaje = 'V' THEN -- VALIDA EL VALOR DE LA VARIABLE vEnviar y vEnviarMensaje, si es V

				--Divide el importe en millares para alertas de mensajeria
				LET vImporte2 = trim (to_char(vImporte,"###,###,###,###.##"));
				LET vMontoTotal = trim (to_char(pMto_tot,"###,###,###,###.##"));				

				IF vCambioPlantilla = 'F' THEN--Envio acumulado de 600 UDIS CLS 17/05/2016
					-- *** Registro de Evento por sms	  -- Graba en la nueva tabla de eventos 20/07/2012 ENVÃÂO SMS => TIPO '2'
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2' , TRIM(SUBSTR(vsidmensaje,1,9))||'S', pNumcte, pCuenta, pnumtarjeta, '1', 
					Vtipo_tarjeta, vImporte2, '', '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
				ELSE
					-- Se envia alerta con plantilla distinta
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2' , TRIM(SUBSTR(vsidmensajeAC,1,9))||'S',TRIM(SUBSTR(vsidmensaje,1,9))||'S2', pNumcte, pCuenta, pnumtarjeta, '1', 
					Vtipo_tarjeta, vImporte2, vMontoTotal, '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
				END IF;
				
				-- se obtiene nombre del cliente
				SELECT (TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(nombre1)||' '||TRIM(nombre2))
				INTO vNombre
				FROM bdinteg:si_cliente
				WHERE numcte = pNumcte
				AND empresa = vEmpresa;
				
				-- se obtiene correo del cliente
				EXECUTE PROCEDURE "informix".sp_consulta_correos('001', pNumcte, 1, '0')   -- se agrega por la reingenieria
				INTO vcodret1, vCorreoElec, vTipoCorreo, vStatusCorreo;
				   
				LET vEmail = vCorreoElec;
			  
				-- *** Registro de Evento por Email
				-- Valida si el cliente tiene email para inserta en la tabla si_mensajes_enviar
				IF vCorreoElec is null or vCorreoElec = '' THEN
				--             CONTINUE FOREACH;
				ELSE
					--LET v_longitud = length(vEmail);    -- se comenta por la reingenieria
					LET v_longitud = length(vCorreoElec);
					
					FOR v_cuenta = 1 to v_longitud
						--LET v_subcadena = SUBSTR(vEmail,v_cuenta,1);    -- se comenta por la reingenieria
						LET v_subcadena = SUBSTR(vCorreoElec,v_cuenta,1);
						IF v_subcadena not in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
									 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
									 '1','2','3','4','5','6','7','8','9','0','@','_','-','.') THEN
							
							LET v_mail_incorrecto = 'T';

							-- Se dejan de grabar mensajes de ATM Y POS en esta tabla, todo se va por Latinia. JGP 16-08-2012
							IF vTipo_mensaje not in ('01', '04','05','06') THEN
								INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, num_tarjeta, tipo_tarjeta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
								VALUES(CURRENT, pNumcte, pCuenta, pnumtarjeta, Vtipo_tarjeta, vNombre, vEmail, vImporte, vTipo_mensaje, 'V',current,'DIRECCION DE CORREO INCORRECTA');
							END IF;
							
							IF vCambioPlantilla = 'F' THEN--Envio acumulado de 600 UDIS CLS 17/05/2016
								-- Graba en la nueva tabla de eventos 20/07/2012 con un ID inexistente para ser descartado.
								EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'*', pNumcte, pCuenta, pnumtarjeta, '1', 
								Vtipo_tarjeta, vImporte2, '', '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
							ELSE
								-- Se envia alerta con plantilla distinta
								EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'*',TRIM(SUBSTR(vsidmensaje,1,9))||'*2', pNumcte, pCuenta, pnumtarjeta, '1', 
								Vtipo_tarjeta, vImporte2, vMontoTotal, '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
							END IF;
							
							EXIT FOR;
							
						ELSE
							CONTINUE FOR;
						END IF;
					END FOR
					
					IF v_mail_incorrecto = 'F' THEN
						-- Se dejan de grabar mensajes de ATM Y POS en esta tabla, todo se va por Latinia. JGP 16-08-2012
						IF vTipo_mensaje not in ('01', '04','05','06') THEN	
						   INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, num_tarjeta, tipo_tarjeta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado)
						   VALUES(CURRENT, pNumcte, pCuenta, pnumtarjeta, Vtipo_tarjeta, vNombre, vEmail, vImporte, vTipo_mensaje, 'F');
						END IF;  
						
						IF vCambioPlantilla = 'F' THEN--Envio acumulado de 600 UDIS CLS 17/05/2016
							-- Graba en la nueva tabla de eventos 20/07/2012 ENVÃÂO EMAIL => TIPO '1'
							EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'E', pNumcte, pCuenta, pnumtarjeta, '1', 
							Vtipo_tarjeta, vImporte2, '', '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
						ELSE
							-- Se envia alerta con plantilla distinta
							EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1' , TRIM(SUBSTR(vsidmensaje,1,9))||'E',TRIM(SUBSTR(vsidmensaje,1,9))||'E2', pNumcte, pCuenta, pnumtarjeta, '1', 
							Vtipo_tarjeta, vImporte2, vMontoTotal, '', '', '', '', '', '', '', '', '', vImporte, pMto_tot,'', '', '', CURRENT, '') INTO vCodret1;
						END IF;

					END IF;
				END IF;
			  
			ELSE
				  LET vEnviar = 'F';

			END IF;

		END FOREACH;
	END IF;
END
    RETURN vCodret1, vMensaje1, vIndicador;

END PROCEDURE;