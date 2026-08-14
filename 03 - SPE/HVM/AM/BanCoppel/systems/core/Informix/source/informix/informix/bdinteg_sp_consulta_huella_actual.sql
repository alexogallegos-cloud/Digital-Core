CREATE PROCEDURE "informix".sp_consulta_huella_actual(pNumcte CHAR(20))

RETURNING CHAR(5)       AS  cCodRet,
		  LVARCHAR(942) AS  cTemplate1,
		  LVARCHAR(942) AS  cTemplate2,
		  LVARCHAR(942) AS  cTemplate3,
		  LVARCHAR(942) AS  cTemplate4,
		  LVARCHAR(942) AS  cTemplate5,
		  LVARCHAR(942) AS  cTemplate6,
		  LVARCHAR(942) AS  cTemplate7,
		  LVARCHAR(942) AS  cTemplate8,
		  LVARCHAR(942) AS  cTemplate9,
		  LVARCHAR(942) AS  cTemplate10,
		  SMALLINT      AS sNfiq1,
		  SMALLINT      AS sNfiq2, 
		  SMALLINT      AS sNfiq3, 
		  SMALLINT      AS sNfiq4, 
		  SMALLINT      AS sNfiq5, 
		  SMALLINT      AS sNfiq6, 
		  SMALLINT      AS sNfiq7, 
		  SMALLINT      AS sNfiq8, 
		  SMALLINT      AS sNfiq9, 
		  SMALLINT      AS sNfiq10,
		  SMALLINT      AS sMinucias1,
          SMALLINT      AS sMinucias2,
          SMALLINT      AS sMinucias3,
          SMALLINT      AS sMinucias4,
          SMALLINT      AS sMinucias5,
          SMALLINT      AS sMinucias6,
          SMALLINT      AS sMinucias7,
		  SMALLINT      AS sMinucias8,
		  SMALLINT      AS sMinucias9,
		  SMALLINT      AS sMinucias10,
		  SMALLINT      AS sSecuencia;
	 	
		--DEFINICION DE VARIABLES
		 DEFINE cCodRet 	 CHAR(5);
		 DEFINE cTemplate1   LVARCHAR(942);
		 DEFINE cTemplate2   LVARCHAR(942);
		 DEFINE cTemplate3   LVARCHAR(942);
		 DEFINE cTemplate4   LVARCHAR(942);
		 DEFINE cTemplate5   LVARCHAR(942);
		 DEFINE cTemplate6   LVARCHAR(942);
		 DEFINE cTemplate7   LVARCHAR(942);
		 DEFINE cTemplate8   LVARCHAR(942);
		 DEFINE cTemplate9   LVARCHAR(942);
         DEFINE cTemplate10  LVARCHAR(942);
		 DEFINE tampNumCte   CHAR(2);
		 DEFINE iSqlErr      INTEGER;
		 DEFINE i            INTEGER;
		 DEFINE cId_template SMALLINT;
		 DEFINE cTemplate    LVARCHAR(942);
		 DEFINE sNfiq        SMALLINT;
		 DEFINE sMinucias    SMALLINT;
		 
		 DEFINE sNfiq1       SMALLINT;
		 DEFINE sNfiq2       SMALLINT;
		 DEFINE sNfiq3       SMALLINT;
		 DEFINE sNfiq4       SMALLINT;
		 DEFINE sNfiq5       SMALLINT;
		 DEFINE sNfiq6       SMALLINT;
		 DEFINE sNfiq7       SMALLINT;
		 DEFINE sNfiq8       SMALLINT;
		 DEFINE sNfiq9       SMALLINT;
		 DEFINE sNfiq10      SMALLINT;
		 
		 DEFINE sMinucias1   SMALLINT;
		 DEFINE sMinucias2   SMALLINT;
		 DEFINE sMinucias3   SMALLINT;
		 DEFINE sMinucias4   SMALLINT;
		 DEFINE sMinucias5   SMALLINT;
		 DEFINE sMinucias6   SMALLINT;
		 DEFINE sMinucias7   SMALLINT;
		 DEFINE sMinucias8   SMALLINT;
		 DEFINE sMinucias9   SMALLINT;
		 DEFINE sMinucias10  SMALLINT;
		 
		 DEFINE sSecuencia   SMALLINT;	 
		 
		 LET cCodRet      = '00000';
		 LET cTemplate1   = '';
		 LET cTemplate2   = '';
		 LET cTemplate3   = '';
		 LET cTemplate4   = '';
		 LET cTemplate5   = '';
		 LET cTemplate6   = '';
		 LET cTemplate7   = '';
		 LET cTemplate8   = '';
		 LET cTemplate9   = '';
         LET cTemplate10  = '';
		 LET tampNumCte   = LENGTH(pNumcte);
		 LET iSqlErr      = 0;
		 LET i            = 0;
		 LET cId_template = 0;
		 LET cTemplate    = '';
		 LET sNfiq        = 0;
		 
		 LET sNfiq1  = 0;
		 LET sNfiq2  = 0;
		 LET sNfiq3  = 0;
		 LET sNfiq4  = 0;
		 LET sNfiq5  = 0;
		 LET sNfiq6  = 0;
		 LET sNfiq7  = 0;
		 LET sNfiq8  = 0;
		 LET sNfiq9  = 0;
		 LET sNfiq10 = 0;
		 
		 LET sMinucias1 = 0; 
		 LET sMinucias2 = 0; 
		 LET sMinucias3 = 0; 
		 LET sMinucias4 = 0; 
		 LET sMinucias5 = 0; 
		 LET sMinucias6 = 0; 
		 LET sMinucias7 = 0; 
		 LET sMinucias8 = 0; 
		 LET sMinucias9 = 0; 
		 LET sMinucias10 = 0;
		 
		 LET sSecuencia = 0;
		 
BEGIN
   ON EXCEPTION SET iSqlErr
      IF iSqlErr !=0 THEN
		RETURN TRIM (isqlerr),cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
	  END IF
	
   END EXCEPTION
	
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
	
   --SET DEBUG FILE TO '/home/sysifx/Brms/sp_consulta_huella_actual.out';
   --TRACE ON;
	
    --VALIDAR DATOS VACIOS
    IF NVL(pNumcte,'') = '' THEN
       LET cCodRet = '00001'; 
       RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
    ELSE
       IF (tampNumCte < 9) THEN
          LET pNumcte = to_char(pNumcte, '&&&&&&&&&');
       END IF;
		
       FOREACH
          SELECT id_template,template,nfiq,minucias,secuencia 
          INTO cId_template,cTemplate, sNfiq, sMinucias, sSecuencia
          FROM si_cte_huella_dec_actual 
          WHERE numcte = pNumcte
          ORDER BY id_template ASC
			
          IF (i = 0) THEN
             LET cTemplate1 = cTemplate;
             LET sNfiq1 = sNfiq;
             LET sMinucias1 = sMinucias;
          END IF;
				
          IF (i = 1) THEN
             LET cTemplate2 = cTemplate;
             LET sNfiq2 = sNfiq;
             LET sMinucias2 = sMinucias;
          END IF;
				
          IF (i = 2) THEN
             LET cTemplate3 = cTemplate;
             LET sNfiq3 = sNfiq;
             LET sMinucias3 = sMinucias;
          END IF;
						
          IF (i = 3) THEN
             LET cTemplate4 = cTemplate;
             LET sNfiq4 = sNfiq;
             LET sMinucias4 = sMinucias;
          END IF;
				
          IF (i = 4) THEN
             LET cTemplate5 = cTemplate;
             LET sNfiq5 = sNfiq;
             LET sMinucias5 = sMinucias;
          END IF;	
				
          IF (i = 5) THEN
             LET cTemplate6 = cTemplate;
             LET sNfiq6 = sNfiq;
             LET sMinucias6 = sMinucias;
          END IF;
				
          IF (i = 6) THEN
             LET cTemplate7 = cTemplate;
             LET sNfiq7 = sNfiq;
             LET sMinucias7 = sMinucias;
          END IF;
					 
          IF (i = 7) THEN
             LET cTemplate8 = cTemplate;
             LET sNfiq8 = sNfiq;
             LET sMinucias8 = sMinucias;
          END IF;
						
          IF (i = 8) THEN
             LET cTemplate9 = cTemplate;
             LET sNfiq9 = sNfiq;
             LET sMinucias9 = sMinucias;
         END IF;
				
         IF (i = 9) THEN
            LET cTemplate10 = cTemplate;
            LET sNfiq10 = sNfiq;
            LET sMinucias10 = sMinucias;
         END IF;	
			
         LET i = i + 1;
      END FOREACH;		
    END IF;

   IF dbinfo('sqlca.sqlerrd2') = 0 THEN
      LET cCodRet= '00002';
   END IF;	
	
   RETURN  cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
END

END PROCEDURE
DOCUMENT
'Creacion: Aracely UreÃÂ±a',
'BD: bdinteg',
'Descripcion: Se crea sp para consulta de huellas actuales de cliente, 10 huellas',
'Peticion: 399 - Implementacion 442 para verificacion y enrolamiento ';

CREATE PROCEDURE "informix".sp_limite_max(pNumcte CHAR(10),
                                          pCuenta CHAR(16),
                                          pOperacion CHAR(2),
                                          pCanal CHAR(2),         -- 01 - ATM, 02 - POS, 03 - PORTAL, 15 - EMPRESANET, 17 - BANCOPPEL MOVIL ONLINE.
                                          pFecha DATE,
                                          pMto_tot DECIMAL(16,2),
                                          pnumtarjeta CHAR (20),
										  pfolsuc      char(16),
										  preferencia  char(40))
RETURNING CHAR(5), CHAR (80), CHAR(1);

--SP limite_max sobrecargado para requerimiento normativo CUB RQI 62 991 Modificaciones a bdinteg sp_limite_max

-- Declaracion de variables

    DEFINE sql_err      	    INTEGER;
    DEFINE isam_err     	    INTEGER;
    DEFINE vCodret1     	    CHAR(5);
	--DEFINE vCodret2     	    CHAR(3);

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
	
	DEFINE cLugar_oper          CHAR(40);
	DEFINE cFolio_suc           CHAR(16);
	DEFINE cDescOper			CHAR(40);
	DEFINE cDescTar 			CHAR(40);
	DEFINE cReferencia          CHAR(40);
	DEFINE cfolsuc CHAR(16);
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_limite_max.out';
	--TRACE ON; 
-- Inicializacion de variables

    LET sql_err   = 0;
    LET isam_err  = 0;
    LET vCodret1  = '00000';
	--LET vCodret2  = '000';

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
	
	LET cLugar_oper = '';
    LET cFolio_suc = '';
	LET cDescOper= '';
	LET cDescTar = '';
	LET cReferencia = '';
	LET cfolsuc = '';

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
		-- 10/02/2021 SET DEBUG FILE TO 'log'||to_char(today, '%Y%m%d')||'.err' WITH APPEND;
		-- 10/02/2021 TRACE ON;

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
        LET vMensaje1 = 'Se genero algun error en la ejecucion';

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

	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
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

	-- Si ya existe un registro en si_limite_diario, se asegura que el campo importe_dia tenga un valor valido.

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

	---- VALIDACION DE MONTO POR CANAL
	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
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
			AND id_restriccion = '02';

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
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el transaccion';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;
		
	ELIF vlimite_personalizado_rest1=1 and (pMto_tot + vImporte) > vMax_pesos1 THEN --Si existe limite por cuenta-operacion, 
		LET vcodret1 = '00035'; --00037
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el cuenta';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;

	ELIF vlimite_personalizado_rest1=0 and (pMto_tot + vImporte) > vMax_pesos   THEN --se agrega el if vlimite_personalizado=0
		LET vcodret1 = '00035';
		LET vMensaje1 = 'Importe de la transaccion excede el limite diario permitido para el canal';
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
				IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
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

				--IF vImporte > vMax_pesos THEN
					--LET vEnviar = 'V';              -- ACTUALIZA VARIABLE vEnviar
				--END IF;
				
				--vSist = '01' ATM_DEB   vSist = '06' ATM_CRED
				--IF vSist = '01' THEN
					IF (NVL(pMto_tot,0) > 0 OR pMto_tot <> '') THEN
							IF pMto_tot > vMax_pesos THEN
								LET vEnviar = 'V';
							ELSE
								LET vEnviar = 'F';
							END IF;
						ELSE
							LET vEnviar = 'F';
					END IF;
				--END IF;
				
			END IF;

			IF vlimite_personalizado_rest2=0 THEN --Si la empresa no tiene personalisado para cada operacion
				IF vRestriccion = '02' THEN  --  Se valida que el monto de la transaccion sea mayor al limite en pesos
										
					IF NVL(pMto_tot,0) > 0 OR pMto_tot <> '' THEN
						IF pMto_tot > vMax_pesos THEN
							LET vImporte = pMto_tot;
							LET vEnviar = 'V';
						ELSE
							LET vEnviar = 'F';
						END IF;
					ELSE
						LET vEnviar = 'F';
					END IF;
				END IF;
			END IF;

			IF vEnviar = 'V' and vEnviarMensaje = 'V' THEN -- VALIDA EL VALOR DE LA VARIABLE vEnviar y vEnviarMensaje, si es V


				LET vsidmensaje=trim(vsidmensaje);
				
				IF vsidmensaje = 'ATM_CRED' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'ATM_DEB' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_DEB' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_CRED' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';					
				ELSE
					LET cDescOper= 'Un Movimiento';
					LET cDescTar = 'Cuenta';
					LET pnumtarjeta = '';
				END IF;
	
				--Divide el importe en millares para alertas de mensajeria
				LET vImporte2 = trim (to_char(vImporte,"###,###,###,###.##"));
				LET vMontoTotal = trim (to_char(pMto_tot,"###,###,###,###.##"));

				LET cReferencia = NVL(preferencia,'');
				LET cfolsuc = NVL(pfolsuc,'');
				
				LET cLugar_oper = SUBSTRING(TRIM(cReferencia) from 1 for 20);
				LET cFolio_suc = TRIM(cfolsuc);
				
				-- Optimizacion de SMS Se usara solo la plantilla CUB_EMAIL para las notificaciones de tarjetas de credito y debito. Descartando CUB_SMS
				EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
				pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				cLugar_oper,cDescTar,cFolio_suc,'','',
				'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				
				IF vCodret1 <> '00000' THEN
					LET vMensaje1 = 'Error Registra Evento';
				END IF;

				--Codigo original antes de modificacion del proyecto de Optimizacion de SMS
				/*EXECUTE PROCEDURE "informix".sp_consulta_correos('001', pNumcte, 1, '0')   -- se agrega por la reingenieria
				INTO vcodret2, vCorreoElec, vTipoCorreo, vStatusCorreo;
				   
				
				IF vcodret2 = '000' AND (NVL(vCorreoElec,'') <> '' OR vCorreoElec <> '')  THEN
				
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
					pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
					cLugar_oper,cDescTar,cFolio_suc,'','',
					'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
					
				ELSE 	
					LET cDescOper = REPLACE(cDescOper, 'Una ', '');
					LET cDescOper = REPLACE(cDescOper, 'Un ', '');
					
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2','CUB_SMS','NOT_MOV_TJT',
					pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
					cLugar_oper,cDescTar,'','','',
					'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				
				END IF;*/

			ELSE
				  LET vEnviar = 'F';

			END IF;

		END FOREACH;
	END IF;
END
    RETURN vCodret1, vMensaje1, vIndicador;

END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		BDINTEG',
'FECHA :        28-11-2025',
'MODIFICACION : La plantilla de mensajes CUB_SMS se descarto y solo se considerara la plantilla CUB_EMAIL para optimizar' ,
			   'las notificaciones de movimiento tarjeta, ya que las plantillas comparten el mismo contenido y tipo de transacciones',
'PROYECTO :     Optimizacion de SMS',
'VERSION :      1.0.2';

CREATE PROCEDURE "informix".sp_limite_max99(pNumcte CHAR(10),
                                          pCuenta CHAR(16),
                                          pOperacion CHAR(2),
                                          pCanal CHAR(2),         -- 01 - ATM, 02 - POS, 03 - PORTAL, 15 - EMPRESANET, 17 - BANCOPPEL MOVIL ONLINE.
                                          pFecha DATE,
                                          pMto_tot DECIMAL(16,2),
                                          pnumtarjeta CHAR (20),
										  pfolsuc      char(16),
										  preferencia  char(40))
RETURNING CHAR(5), CHAR (80), CHAR(1);

--SP limite_max sobrecargado para requerimiento normativo CUB RQI 62 991 Modificaciones a bdinteg sp_limite_max

-- Declaracion de variables

    DEFINE sql_err      	    INTEGER;
    DEFINE isam_err     	    INTEGER;
    DEFINE vCodret1     	    CHAR(5);
	--DEFINE vCodret2     	    CHAR(3);

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
	
	DEFINE cLugar_oper          CHAR(40);
	DEFINE cFolio_suc           CHAR(16);
	DEFINE cDescOper			CHAR(40);
	DEFINE cDescTar 			CHAR(40);
	DEFINE cReferencia          CHAR(40);
	DEFINE cfolsuc CHAR(16);
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_limite_max.out';
	--TRACE ON; 
-- Inicializacion de variables

    LET sql_err   = 0;
    LET isam_err  = 0;
    LET vCodret1  = '00000';
	--LET vCodret2  = '000';

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
	
	LET cLugar_oper = '';
    LET cFolio_suc = '';
	LET cDescOper= '';
	LET cDescTar = '';
	LET cReferencia = '';
	LET cfolsuc = '';

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
		-- 10/02/2021 SET DEBUG FILE TO 'log'||to_char(today, '%Y%m%d')||'.err' WITH APPEND;
		-- 10/02/2021 TRACE ON;

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
        LET vMensaje1 = 'Se genero algun error en la ejecucion';

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

	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
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

	-- Si ya existe un registro en si_limite_diario, se asegura que el campo importe_dia tenga un valor valido.

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

	---- VALIDACION DE MONTO POR CANAL
	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
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
			AND id_restriccion = '02';

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
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el transaccion';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;
		
	ELIF vlimite_personalizado_rest1=1 and (pMto_tot + vImporte) > vMax_pesos1 THEN --Si existe limite por cuenta-operacion, 
		LET vcodret1 = '00035'; --00037
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el cuenta';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;

	ELIF vlimite_personalizado_rest1=0 and (pMto_tot + vImporte) > vMax_pesos   THEN --se agrega el if vlimite_personalizado=0
		LET vcodret1 = '00035';
		LET vMensaje1 = 'Importe de la transaccion excede el limite diario permitido para el canal';
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
				IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
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

				--IF vImporte > vMax_pesos THEN
					--LET vEnviar = 'V';              -- ACTUALIZA VARIABLE vEnviar
				--END IF;
				
				--vSist = '01' ATM_DEB   vSist = '06' ATM_CRED
				--IF vSist = '01' THEN
					IF (NVL(pMto_tot,0) > 0 OR pMto_tot <> '') THEN
							IF pMto_tot > vMax_pesos THEN
								LET vEnviar = 'V';
							ELSE
								LET vEnviar = 'F';
							END IF;
						ELSE
							LET vEnviar = 'F';
					END IF;
				--END IF;
				
			END IF;

			IF vlimite_personalizado_rest2=0 THEN --Si la empresa no tiene personalisado para cada operacion
				IF vRestriccion = '02' THEN  --  Se valida que el monto de la transaccion sea mayor al limite en pesos
										
					IF NVL(pMto_tot,0) > 0 OR pMto_tot <> '' THEN
						IF pMto_tot > vMax_pesos THEN
							LET vImporte = pMto_tot;
							LET vEnviar = 'V';
						ELSE
							LET vEnviar = 'F';
						END IF;
					ELSE
						LET vEnviar = 'F';
					END IF;
				END IF;
			END IF;

			IF vEnviar = 'V' and vEnviarMensaje = 'V' THEN -- VALIDA EL VALOR DE LA VARIABLE vEnviar y vEnviarMensaje, si es V


				LET vsidmensaje=trim(vsidmensaje);
				
				IF vsidmensaje = 'ATM_CRED' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'ATM_DEB' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_DEB' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_CRED' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';					
				ELSE
					LET cDescOper= 'Un Movimiento';
					LET cDescTar = 'Cuenta';
					LET pnumtarjeta = '';
				END IF;
	
				--Divide el importe en millares para alertas de mensajeria
				LET vImporte2 = trim (to_char(vImporte,"###,###,###,###.##"));
				LET vMontoTotal = trim (to_char(pMto_tot,"###,###,###,###.##"));

				LET cReferencia = NVL(preferencia,'');
				LET cfolsuc = NVL(pfolsuc,'');
				
				LET cLugar_oper = SUBSTRING(TRIM(cReferencia) from 1 for 20);
				LET cFolio_suc = TRIM(cfolsuc);
				
				-- Optimizacion de SMS Se usara solo la plantilla CUB_EMAIL para las notificaciones de tarjetas de credito y debito. Descartando CUB_SMS
				EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
				pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				cLugar_oper,cDescTar,cFolio_suc,'','',
				'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				
				IF vCodret1 <> '00000' THEN
					LET vMensaje1 = 'Error Registra Evento';
				END IF;

				--EXECUTE PROCEDURE "informix".sp_consulta_correos('001', pNumcte, 1, '0')   -- se agrega por la reingenieria
				--INTO vcodret2, vCorreoElec, vTipoCorreo, vStatusCorreo;
				--   
				--
				--IF vcodret2 = '000' AND (NVL(vCorreoElec,'') <> '' OR vCorreoElec <> '')  THEN
				--
				--	EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
				--	pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				--	cLugar_oper,cDescTar,cFolio_suc,'','',
				--	'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				--	
				--ELSE 	
				--	LET cDescOper = REPLACE(cDescOper, 'Una ', '');
				--	LET cDescOper = REPLACE(cDescOper, 'Un ', '');
				--	
				--	EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2','CUB_SMS','NOT_MOV_TJT',
				--	pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				--	cLugar_oper,cDescTar,'','','',
				--	'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				--
				--END IF;

			ELSE
				  LET vEnviar = 'F';

			END IF;

		END FOREACH;
	END IF;
END
    RETURN vCodret1, vMensaje1, vIndicador;

END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		BDINTEG',
'FECHA :        28-11-2025',
'MODIFICACION : La plantilla de mensajes CUB_SMS se descarto y solo se considerara la plantilla CUB_EMAIL para optimizar' ,
			   'las notificaciones de movimiento tarjeta, ya que las plantillas comparten el mismo contenido y tipo de transacciones',
'PROYECTO :     Optimizacion de SMS',
'VERSION :      1.0.2';

CREATE PROCEDURE "informix".sp_genera_numcte( pEmpresa CHAR(3) )
RETURNING CHAR(5) AS cCodRet, CHAR(20) AS cNumCte;

    -- 1. DefiniciÃ³n de Variables
    -- Solo declaramos las necesarias para que funcione tu bloque de cÃ³digo
    DEFINE cCodret      CHAR(5);
    DEFINE cNumcte      CHAR(20);
    DEFINE iSignumcte   INT;           -- Entero para poder sumar
    DEFINE sLong_cte    SMALLINT;      -- Variable para el parÃ¡metro 7
    DEFINE sDiferencia  SMALLINT;      -- Variable para el cÃ¡lculo de ceros
    DEFINE sI           SMALLINT;      -- Contador del ciclo FOR
    DEFINE iSqlerr      INTEGER;       -- Para control de excepciones

    -- 2. InicializaciÃ³n
    LET cCodret = "000";
    LET cNumcte = "";

BEGIN
    -- Manejo de Excepciones
    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret, cNumcte;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- 3. TU LÃGICA (Insertada textualmente como solicitaste)
    
          SELECT valor
            INTO sLong_cte
            FROM bdinteg:"informix".si_param
           WHERE cod_param = 7
             AND empresa = pEmpresa;

        IF sLong_cte IS NULL THEN
            LET cCodret = "105";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT valor
              INTO iSignumcte
              FROM bdinteg:"informix".si_param
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            IF iSignumcte IS NULL THEN
                LET iSignumcte = 1;
            END IF

            LET cNumcte = iSignumcte;
            LET iSignumcte = iSignumcte + 1;

            UPDATE bdinteg:"informix".si_param
               SET (valor) = (iSignumcte)
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            -- Nota: AsegÃºrate que cNumcte no tenga espacios al final para que LENGTH funcione bien
            LET sDiferencia = sLong_cte - LENGTH(cNumcte); 

            IF sDiferencia > 0 THEN
                FOR sI = 1 TO sDiferencia
                    LET cNumcte = "0" || cNumcte;
                END FOR;
            END IF
        END IF;

    -- 4. Retorno final (Si todo saliÃ³ bien)
    RETURN cCodret, cNumcte;
    END;

END PROCEDURE;