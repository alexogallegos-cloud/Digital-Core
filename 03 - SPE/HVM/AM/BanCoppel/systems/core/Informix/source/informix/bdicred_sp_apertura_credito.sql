CREATE PROCEDURE "informix".sp_apertura_credito(P_EMPRESA       VARCHAR(3),
                                                P_SOLICITUD     VARCHAR(20),
                                                P_NUMTARJETA    CHAR(20),
                                                P_PLAZO         INTEGER,
                                                P_MTOSOL        DECIMAL(14,2),
                                                --P_MTOENGANCHE   DECIMAL(14,2), --SE REALIZA MODIFICACION PARA AGREGAR EL MONTO ENGACHE 
												P_MTOENGANCHE   DECIMAL(18,2),	 --A LA TABLA SD_MAECRECRD
                                                P_NUMCTE        CHAR(20),
                                                P_NUMCTA        CHAR(20),
                                                P_SUCURSAL      CHAR(4),
                                                P_TPSOL         CHAR(4),
                                                P_PRODUCTO      CHAR(4),
                                                P_EJECUTIVO     CHAR(8),
                                                P_MONTOADEUDO   CHAR(20))

	RETURNING CHAR(5)     ,  --CodRet
			  DECIMAL(9,6),  --TasaInteres
			  DECIMAL(9,6),  --TasaMora
			  DECIMAL(9,6),  --Cat
			  CHAR(1)     ;  --Mercadeo

	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	---Variables de control de errores
	DEFINE vCodRet            	VARCHAR(8);
	DEFINE CodRet             	VARCHAR(8);
	DEFINE p_mensaje           	VARCHAR(80);
	DEFINE error_info          	VARCHAR(80);
	DEFINE sql_err             	INTEGER;
	DEFINE isam_err            	INTEGER;
	DEFINE wBegin              	CHAR(1);
	DEFINE vFechaApertura      	DATE;
	DEFINE vFechaVenc          	DATE;
	DEFINE i                   	INTEGER;
	DEFINE vPlazo              	INTEGER;
	DEFINE vFactor_FAV         	CHAR(1);
	DEFINE vMercadeo           	CHAR(1);
	DEFINE vNumCredito         	CHAR(20);
	DEFINE vProducto           	CHAR(4);
	DEFINE vDivisa             	CHAR(2);
	DEFINE vSucursal           	CHAR(4);
	DEFINE vFolio	           	CHAR(16);
	DEFINE vFactor	           	CHAR(1);
	DEFINE vMensaje            	CHAR(200);
	DEFINE vPerPlazo           	CHAR(1);
	
	DEFINE vTipoCalculo        	CHAR(2);
	DEFINE vCodTasInt          	CHAR(8);
	DEFINE vFacSobreTAsa       	CHAR(1);
	DEFINE vTasaFijVar         	CHAR(1);
	DEFINE vCodTasaMora        	CHAR(8);
	DEFINE vFacSobretMora      	CHAR(1);
	DEFINE vPerPagCap          	CHAR(1);
	DEFINE vPerPagInt          	CHAR(1);
	DEFINE vFecApert           	DATE;
	DEFINE vFecVenc            	DATE;
	DEFINE vFechaT             	DATE;
	DEFINE vDiaCorte           	SMALLINT;
	DEFINE vCapDebe            	DECIMAL(14,2);
	DEFINE vPagCuota           	DECIMAL(14,2);
	DEFINE vCatIva             	DECIMAL(9,6);
	DEFINE vTasaInteres        	DECIMAL(9,6);
	DEFINE vTasaMora           	DECIMAL(9,6);
	DEFINE vSobretasa          	DECIMAL(9,6);
	DEFINE vTasaFavor          	DECIMAL(9,6);
	DEFINE vSobretMora         	DECIMAL(9,6);
	DEFINE vMtoReestruc        	CHAR(20);
	DEFINE vCuenta			   	SMALLINT;  -- BGM 21-May-2010 se define variable para nÃÂÃÂÃÂÃÂºmero de cuota
	DEFINE vproxfechapag       	DATE;
	--DEFINE vproxfechapagaux    DATE;
	--Variables de cargo y abono a cuenta
	DEFINE vt_sucursal      	CHAR(4);
	DEFINE vt_codigo_mn     	CHAR(2);
	DEFINE vt_sdocta        	DECIMAL(14,2);
	DEFINE vt_bloqueo       	CHAR(1);
	DEFINE vt_sdodisp       	MONEY(14,2);
	DEFINE vt_dummy         	CHAR(4);
	DEFINE vt_dummy1        	DATE;
	DEFINE vfechacheq       	DATE;
	--valida comisiones jomm ini
	DEFINE vcom_pendiente   	DECIMAL(9,6);
	--valida comisiones jomm fin
	DEFINE vExiste				INTEGER;
	DEFINE bEsNumero          	BOOLEAN;
	-- Valida que la sol existen sea del mismo cliente
	DEFINE vNumCredTdcAux   	CHAR(20);
	DEFINE vNumCteAux       	CHAR(20);
	--- Cuenta Clabe
	DEFINE vcod_ret				CHAR (6);
	DEFINE cta_Clabe			CHAR (18);
	DEFINE val_ifrs 			char(1);

	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "Principal.err";
		---TRACE sql_err||" * "||isam_err||" * "||error_info;
		-- FMV 15mar13: Seguimiento al error -268 rastreo de la causa
		INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
		('001', '6011', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info, user, today, current );
		LET vCodRet   = sql_err;
		LET p_mensaje = error_info;
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		ROLLBACK WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

      LET wBegin = "N";

      BEGIN WORK;

	--SET DEBUG FILE TO '/tmp/sp_apertura_credito.out';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

	--***********************
	--INICIALIZA VARIABLE
	--***********************
	LET  vCodRet        	 = '00000';
	LET  p_mensaje       	= 'PROCESO EXITOSO';
	LET  vTasaInteres   	= 0;
	LET  vTasaMora      	= 0;
	LET  vSobretasa     	= 0;
	LET  vTasaFavor     	= 0;
	LET  vFactor	  		= '';
	LET  vFechaApertura 	= '';
	LET  vFechaVenc     	= '';
	LET  vFactor_FAV    	= '';
	LET  vProducto      	= '';
	LET  vDivisa        	= '';
	LET  vSucursal      	= '';
	LET  vFolio	  			= '';
	LET  vMensaje       	= '';
	LET  vFechaT        	= '';
	LET  vDiaCorte      	= 0;
	LET  vCatIva	  		= 0;
	LET  vMercadeo      	= '';
	LET  vNumCredito    	= '';
	LET  i              	= 0;
	LET vCapDebe        	= 0;
	LET vPagCuota       	= 0;
	LET  vPerPlazo      	= '';
	LET  vPlazo         	= 0;
	LET  vDivisa        	= '';
	LET  vTipoCalculo   	= '';
	LET  vCodTasInt     	= '';
	LET  vFacSobreTAsa  	= '';
	LET  vTasaFijVar    	= '';
	LET  vCodTasaMora   	= '';
	LET  vFacSobretMora 	= '';
	LET  vSobretMora    	= 0;
	LET  vPerPagCap     	= '';
	LET  vPerPagInt     	= '';
	LET  vFecApert      	= '';
	LET  vFecVenc       	= '';
	LET  vMtoReestruc   	= '';
	LET  vCUenta = 1;  -- BGM 21-May-2010 se inicializa variable para nÃÂÃÂÃÂÃÂºmero de cuota
	LET  vt_sdocta      	= 0;
	LET  vt_bloqueo     	= '';
	LET vproxfechapag   	= DATE(1);
	LET vcom_pendiente  	= 0;
	LET bEsNumero       	= 't';
	LET vExiste 		 	=  0;

	LET  P_MTOSOL       	= P_MTOSOL;
	LET P_MTOENGANCHE   	= NVL(P_MTOENGANCHE,0);
	LET P_MONTOADEUDO   	= P_MONTOADEUDO;
	
	--- Cuenta Clabe
	LET vcod_ret			= '000';
	LET cta_Clabe			= '';	
	LET val_ifrs ='';	

	-- FMV 10-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
	EXECUTE PROCEDURE bdinteg:"informix".val_num (P_SOLICITUD) INTO bEsNumero;
	IF bEsNumero = 'f' OR trim(P_SOLICITUD) = '' OR P_SOLICITUD is null THEN
		LET vCodRet='242'; --EL NUMERO DE SOLICITUD NO EXISTE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;
	
	
	--Valida si esta activo el IFRS	
	select NVL(valor,'I') into val_ifrs from bdicred:"informix".sd_param where cod_param = '700';

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	--//Cat
	SELECT valor INTO vCatIva
	FROM   bdicred:"informix".sd_param
	WHERE  cod_param = '321';
	IF vCatIva IS NULL THEN
		LET vCatIva = 0;
	END IF;

	SELECT fecha_hoy
	INTO vFechaApertura
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = P_EMPRESA;

	--//Folio
	SELECT P_EJECUTIVO
	|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
	INTO vFolio
	FROM bdicred:"informix".sd_FECHAS; --PRODUCE SEQUENTIAL

	SELECT num_credito
	INTO vNumCredito
	FROM bdicred:"informix".sd_tarjeta
	WHERE empresa      = P_EMPRESA
	AND num_tarjeta  = P_NUMTARJETA;

	--//Sucursal
	SELECT sucursal
	INTO vt_sucursal
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = P_EMPRESA
	AND cuenta  = P_NUMCTA;

	--//Tipo de Moneda
	SELECT valor
	INTO vt_codigo_mn
	FROM bdinteg:"informix".si_param
	WHERE empresa = P_EMPRESA
	AND descripcion ="codigo mn";

	--------------------------------------------------------
	---     GENERA LA SOLICITUD DE REESTRUCTURA          ---
	--------------------------------------------------------
	-- CGP 18-12-2014 se modifica para evitar el error -268
	SELECT COUNT(num_solicitud) INTO vExiste FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD;
    --IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD) THEN
	IF vExiste = 0 THEN
		--FMV 20dic12 : Se eliminan las tablas previo a insertar datos por duplicidad y error -268 informix en el proceso.
		DELETE FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD; -- se le quita el estatus de la solicitud CGP

		DELETE FROM bdisolic:"informix".ss_anexosol WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD;

		DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD
														AND status_solicitud = 'PC';


		INSERT INTO bdisolic:"informix".ss_solicitudes
		(empresa         , num_solicitud, numcte           , sucursal  , tipo_solicitud,
		status_solicitud, num_producto , monto_solicitado ,user_insert, fecha_insert)
		VALUES
		(P_EMPRESA      , P_SOLICITUD   , P_NUMCTE   , P_SUCURSAL, P_TPSOL      ,
		"PC"           , P_PRODUCTO    , P_MTOSOL   ,P_EJECUTIVO, vFechaApertura);

		INSERT INTO bdisolic:"informix".ss_anexosol
		(empresa  , num_solicitud, fecha_sol   , ejecutivo_sol, otro_presta,
		user_insert, fecha_insert, otro_copresta,num_acta)
		VALUES
		(P_EMPRESA, P_SOLICITUD , vFechaApertura, P_EJECUTIVO  , P_MTOENGANCHE,
		P_EJECUTIVO, vFechaApertura, P_MONTOADEUDO, P_NUMTARJETA);

		INSERT INTO bdisolic:"informix".ss_autorizacion
		(empresa      , ejecutivo_auto, num_solicitud, status_solicitud, comentario,
		fecha_entrada, fecha_salida  , user_insert  , fecha_insert)
		VALUES
		(P_EMPRESA    , P_EJECUTIVO   , P_SOLICITUD  , "PC"            , "Solicitud Pre-Calificada  por sistema",
		vFechaApertura, vFechaApertura , P_EJECUTIVO  , vFechaApertura);

    ELSE
        --Obtiene el credito existen en base de datos y compara que sea el mismo cliente.
        SELECT limit 1 numcte, credito_externo INTO vNumCteAux, vNumCredTdcAux FROM bdicred:"informix".sd_maecredcrd 
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
        LET P_NUMCTE = P_NUMCTE;
        LET vNumCredito = vNumCredito;

        IF vNumCteAux != P_NUMCTE OR vNumCredTdcAux != vNumCredito THEN
			LET vCodRet = '366'; -- Ya existe registro previo del credito con cliente y credito 6001 diferente
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
    END IF;

  --------------------------------------------------------
  ---     GENERA MOVIMIENTO DE CARGO Y ABONO           ---
  --------------------------------------------------------
--//Valida comisiones pendientes JOM INI
--IFSRS - INI Se comenta para pruebas para no validar la bdicheq 

    SELECT NVL(com_pendiente ,0)
    INTO vcom_pendiente
    FROM bdicheq:"informix".sc_maechq 
    WHERE empresa = P_EMPRESA 
    AND cuenta = P_NUMCTA;

    IF vcom_pendiente > 0 then
		LET vCodRet='400';
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
        RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;

	--//Valida comisiones pendientes JOM INI

	---INI CAS
	--//Valida Saldo de la Cuenta
	EXECUTE PROCEDURE bdicheq:"informix".cons_saldo(P_NUMCTA)
	INTO vCodRet, vt_sdocta, vt_bloqueo;

    IF vCodRet = "000" AND vt_bloqueo='1' AND vt_sdocta >= P_MTOENGANCHE THEN

		SELECT fecha_proceso
		INTO vfechacheq
		FROM bdicheq:"informix".sc_maechq
		WHERE cuenta=P_NUMCTA;

		IF vfechacheq<>vFechaApertura THEN
			LET vCodRet='549';
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
		END IF;
		--//Aplicar el Abono del prestamo
		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
                                           P_NUMCTA, 0,P_MTOSOL - P_MTOENGANCHE, P_MTOSOL - P_MTOENGANCHE,
	                    		           0,0,0,vt_codigo_mn, TRIM(P_SOLICITUD) ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
	    INTO vCodRet;
       --//Verifica si el abono fue exitoso
        IF vCodRet <> "000" THEN
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
		--JMAH RQM 10 495 
        --//Ejecutar cargo total de la reestructura
        EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0279',"0000",vFolio,P_NUMCTA,0,P_MTOSOL,
                                    vt_codigo_mn,'REESTRUCTURA CREDITO',P_NUMTARJETA,p_ejecutivo)
        INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

       --//Verifica si el cargo fue exitoso
        IF vCodRet <> "000" THEN
			--//Ejecutar cargo igual al monto del abono de la reestructura
			--          EXECUTE PROCEDURE bdicheq:cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0227',"0000",vFolio,P_NUMCTA,0,P_MTOSOL - P_MTOENGANCHE,
			--                                      vt_codigo_mn,'REESTRUCTURA CREDITO',"",p_ejecutivo)
			--          INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

            EXECUTE PROCEDURE "informix".reversion(P_EMPRESA,vt_sucursal,p_ejecutivo,vFolio,'B')
            INTO vCodRet;

			IF vCodRet <> "000" THEN
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
			END IF;
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;

    ELSE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		IF vCodRet = "000" AND vt_sdocta < P_MTOENGANCHE THEN
		LET vCodRet = "400";
		ELIF vt_bloqueo<>'1' THEN
		LET vCodRet = "432";
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;
	---FIN CAS
 --IFSRS - FIN Se comenta para pruebas para no validar la bdicheq 

	-----------------------------------------------------------
	--- REVISA QUE NO EXISTA REESTRUCTURA EN TABLAS Y BORRA ---
	-----------------------------------------------------------

	DELETE FROM bdicred:"informix".sd_MAESDOSCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MOVDIA
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MOVDIACRD     --FMV 20dic12: Se adiciona por error informix -268
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDANEXOCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	UPDATE bdisolic:"informix".ss_solicitudes 
	SET status_solicitud = "AT"
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	DELETE FROM bdisolic:"informix".ss_autorizacion
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND status_solicitud = "AP";

	DELETE FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_ctascarg
	WHERE EMPRESA     = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_indicador_cred_crd  --FMV 15may13
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	-----------------------------------------
	--- PROCESO DE LIQUIDACION DE CREDITO ---
	-----------------------------------------
	CALL "informix".sp_liquida_credito(p_empresa,vNumCredito,vFolio) RETURNING vCodRet,p_mensaje;

	IF vCodRet <> '00000' THEN
	ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--**Monto Minimo Para Consulta Generalizada Y Tabla De Amortizacion
	SELECT MIN(fecha_cuota)
	INTO vFechaT
	FROM bdicred:"informix".sd_proyecta
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	LET vproxfechapag=vFechaT;

	IF DAY(vFechaT) = '17' THEN
		LET vDiaCorte = 17;
	ELIF DAY(vFechaT) = '02' THEN
		LET vDiaCorte = 2;
	END IF;

         --** Fecha Vencimiento Del Credito

	LET  vFechaVenc= (SELECT MAX(fecha_cuota)
						FROM bdicred:"informix".sd_proyecta
						WHERE empresa = P_EMPRESA
						AND num_solicitud = P_SOLICITUD);
	IF vfechavenc IS NULL THEN LET vfechavenc=DATE(1); END IF;

	-- ****************************
	-- Determina Tasas de Interes *
	-- ****************************
	--INTERES ORDINARIO
	SELECT c.valor, a.factor_sobretasa, a.sobretasa --, a.dia_cuota
	INTO vTasaInteres, vFactor, vSobretasa        --, vDiaCorte
	FROM bdicred:"informix".sd_definicion a, 
	bdisolic:"informix".ss_solicitudes b,
	bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_base
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_base);


	IF vFactor = "+" THEN
		LET vTasaInteres = vTasaInteres + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaInteres = vTasaInteres - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaInteres = vTasaInteres * vSobretasa;
	ELSE
		LET vTasaInteres = vTasaInteres / vSobretasa;
	END IF

	--INTERES MORATORIO
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		c.valor, a.fact_sobret_mora, a.sobretasa_mora
	INTO vTasaMora   , vFactor, vSobretasa
	FROM bdicred:"informix".sd_definicioncrd a, 
		bdisolic:"informix".ss_solicitudes b,
		bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_mora
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_mora);

	IF vFactor = "+" THEN
		LET vTasaMora = vTasaMora + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaMora = vTasaMora - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaMora = vTasaMora * vSobretasa;
	ELSE
		LET vTasaMora = vTasaMora / vSobretasa;
	END IF

        --INTERES A FAVOR DEL CLIENTE
        SELECT {+INDEX ("informix".sd_definicioncrd)}
			c.valor, a.factor_sobretasa, a.sobretasa
		INTO vTasaFavor   , vFactor_FAV, vSobretasa
		FROM bdicred:"informix".sd_definicioncrd a, 
			bdisolic:"informix".ss_solicitudes b,
			bdinteg:"informix".si_fechavalor c
         WHERE b.empresa = P_EMPRESA
			AND num_solicitud = P_SOLICITUD
			AND a.empresa = b.empresa
			AND a.num_producto = b.num_producto
			AND c.empresa = a.empresa
			AND c.tasa = a.cod_tasa_base
			AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
							WHERE r.empresa = P_EMPRESA
                            AND r.tasa = a.cod_tasa_base);



        IF vFactor_FAV = "+" THEN
            LET vTasaFavor = vTasaFavor + vSobretasa;
        ELIF vFactor_FAV = "-" THEN
            LET vTasaFavor = vTasaFavor - vSobretasa;
        ELIF vFactor_FAV = "*" THEN
            LET vTasaFavor = vTasaFavor * vSobretasa;
        ELSE
			LET vTasaFavor = vTasaFavor / vSobretasa;
        END IF
		
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,P_PRODUCTO)
		INTO vcod_ret, cta_Clabe;

	--**INSERTA LA CUENTA PARA COBRO
	INSERT INTO "informix".sd_ctascarg
		(EMPRESA           ,NUMERO          ,
		CON_CAP_INTE      ,NATURALEZA      ,
		NUM_CREDITO       ,TIPO_CTA        ,
		NUM_CTA           , NUM_NOMINA)
	VALUES
		(P_EMPRESA        , 0               ,
		''               , 'A'             ,
		P_SOLICITUD      , ''              ,
		P_NUMCTA         , ''              );


	--***** ACTUALIZA SD_MAECRED

	INSERT INTO bdicred:"informix".sd_maecredcrd
		(EMPRESA                ,NUM_CREDITO
		,NUM_PRODUCTO           ,EJECUTIVO
		,NUMCTE                 ,DIVISA
		,SUCURSAL               ,ID_ORIGEN
		,ORIGEN                 ,COD_TIPO_LINEA
		,COD_LINEA
		,STATUS_CRED            ,BANDERA_RENOVAC
		,BANDERA_PRORROGA       ,PERIODO_PLAZO
		,PLAZO                  ,FECHA_APERTURA
		,FECHA_VENCIM           ,PERIOD_PAGO_CAP
		,PERIOD_PAG_INT         ,DIAS_TRASP_CAP
		,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR
		,COD_TASA_BASE          ,FACTOR_SOBRETASA
		,SOBRETASA              ,TASA_INTERES
		,COD_TASA_MORA          ,SOBRETASA_MORA
		,FACT_SOBRET_MORA       ,TASA_MORATORIOS
		,FECHA_PAGO_CAP         ,FECHA_PAGO_INT
		,ES_FISICA              ,BANDERA_FI_FO
		,ACTIVIDAD
		,TIPO_CALCULO
		,NUM_APER_ANT           ,REV_TASA_VAR_PER
		,DIA_PARA_REVISAR       ,COD_PROD
		,BANDERA_MINISTRA
		,CREDITO_EXTERNO        ,PAGOS_SOSTENIDOS
		,CAMPO_TRAB1            ,CAMPO_TRAB2
		,CAMPO_TRAB3            ,CAMPO_TRAB4
		,valor_preferencial --PRUEBAS 16082018)
		,cuenta_clabe)
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		SOL.EMPRESA                ,P_SOLICITUD
		,SOL.NUM_PRODUCTO           ,ANX.EJECUTIVO_SOL
		,SOL.NUMCTE                 ,DEF.DIVISA
		,SOL.SUCURSAL               ,''
		,''                         ,''
		,''
		,'VP'                       ,'S'                   --** Credito Vencido Y Renovado Para Pago Sostenido
		,'N'                        ,DEF.PERIODO_PLAZO
		,P_PLAZO                    ,vFechaApertura
		,vFechaVenc               ,"3"
		,"2"                        ,CTR.DIAS_TRAS_CAP
		,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR
		,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
		,DEF.SOBRETASA              ,vTasaInteres
		,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
		,DEF.FACT_SOBRET_MORA       ,vTasaMora
		,''                         ,''
		,TIP.ES_FISICA              ,''
		,''
		,DEF.TIPO_CALCULO
		,''                         ,SOL.REV_TASA_VAR_PER
		,DEF.DIA_PARA_REVISAR       ,''
		,'M'
		,vNumCredito                ,0
		,0                          ,0
		,''                         ,''
		,P_MTOENGANCHE --PRUEBAS 16082018
		,cta_Clabe
	FROM   bdisolic:"informix".ss_SOLICITUDES SOL
		, bdisolic:"informix".ss_ANEXOSOL    ANX
		, bdinteg:"informix".si_CLIENTE      CLI
		, bdinteg:"informix".si_TIPPER       TIP
		, "informix".SD_CODTRASP             CTR
		, "informix".SD_DEFINICIONCRD           DEF
	WHERE  DEF.EMPRESA         = SOL.EMPRESA
	AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
	AND    CTR.PERIOD_PAG_INT  = "3"
	AND    CTR.PERIOD_PAGO_CAP = "2"
	AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
	AND    CTR.EMPRESA         = DEF.EMPRESA
	AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
	AND    CLI.NUMCTE          = SOL.NUMCTE
	AND    CLI.EMPRESA         = SOL.EMPRESA
	AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
	AND    ANX.EMPRESA         = SOL.EMPRESA
	AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
	AND    SOL.EMPRESA         = P_EMPRESA;

	--**ACTUALIZA  LA TARJETA CON EL NO. DE CREDITO REESTRUCTURADO

	UPDATE bdicred:"informix".sd_MAECRED
	SET credito_externo = P_SOLICITUD
	WHERE empresa     = P_EMPRESA
	AND num_credito = vNumCredito;

	--***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)
	-- CALL bdicred:"informix".monthadd(mdy(month(vFechaApertura),'01',year(vFechaApertura)),1) RETURNING vproxfechapagaux;
	-- CALL bdicred:"informix".sp_valfechabil(mdy(month(vproxfechapagaux),vDiaCorte,year(vproxfechapagaux)),'+') RETURNING vCodRet, vproxfechapag;

	INSERT INTO bdicred:"informix".sd_maecredanexocrd
			(empresa,               num_credito,
			dia_corte,             dias_gracia_mora,
			tp_dias_calc_mora,     dias_fecha_max_pago,
			tp_dias_fecha_pago,    cod_tasa_base_cte,
			factor_sobretasa_cte,  sobretasa_cte,
			tasa_interes_cte,      prox_fecha_pago,
			fecha_proceso)
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		   P_EMPRESA,               P_SOLICITUD,
		   vDiaCorte          ,           def.campo_3,
		   def.pago_adic_sig_cuota,   def.tpo_persona,
		   def.maneja_linea,        def.cod_tasa_base,
		   def.factor_sobretasa,    def.sobretasa,
		   vTasaFavor,            vproxfechapag,
		   vFechaApertura
	FROM bdicred:"informix".sd_definicioncrd def,
		bdisolic:"informix".ss_solicitudes c
	WHERE c.empresa = P_EMPRESA
	AND c.num_solicitud = P_SOLICITUD
	AND def.empresa = c.empresa
	AND def.num_producto = c.num_producto;

      --***** ACTUALIZA SD_MAESDOS
         INSERT INTO bdicred:"informix".sd_MAESDOScrd 
                                (EMPRESA                ,NUM_CREDITO
                                ,FECHA_ULT_MOV          ,SDO_INT_ANTICIP
                                ,SDO_INT_ANT_DEV        ,SDO_INTERESES
                                ,SDO_DIA_ANT_INT        ,SDO_MES_ANT_INT
                                ,SDO_ACUM_MES_INT       ,SDO_RETENIDO
                                ,SDO_ACUM_CAP_INT       ,SDO_EXIG_INT
                                ,SDO_NO_EXIG            ,PROVISION_NORMAL
                                ,DIAS_ACUM_INT          ,SDO_MORATORIO
                                ,SDO_DIA_ANT_MOR        ,SDO_MES_ANT_MOR
                                ,SDO_CONTAB_MORA        ,DIAS_ACUM_MORA
                                ,SDO_CAPITAL            ,SDO_CAP_INSOLUTO
                                ,SDO_DIA_ANT_CAP        ,SDO_MES_ANT_CAP
                                ,SDO_ACUM_MES_CAP       ,MTO_CAPITALIZADO
                                ,MTO_MINISTRA_CAP       ,CARGOS_DIA_CAP
                                ,ABONOS_DIA_CAP         ,CARGOS_MES_CAP
                                ,ABONOS_MES_CAP         ,DIAS_ACUM_CAP
                                ,MONTO_VENCIDO          ,MTO_VENC_TRASP
                                ,MONTO_FINANCIADO       ,MONTO_RESERVADO
                                ,SDO_ACUM_VENCIDO       ,DIAS_ACUM_INTPER
                                ,SDO_GLOBAL_INT         ,SDO_ACUM_INTPER
                                ,MONTO_OTORGADO         ,PROVI_VENC_NORMAL
                                ,PROVI_VENC_ANTICIP     ,CAP_TRAS_NO_VENCI
                                ,MTO_VENC_INT           ,MTO_VENC_TRA_INT
                                ,MTO_FINAN_VDO          ,MTO_RESER_INT
                                ,MTO_FIN_VEN_TRASP      ,MTO_FIN_VIG_TRASP
                                ,INT_TRA_NO_EXIG        ,SDO_TRAB4
								,ATR
                                )
                          SELECT SOL.EMPRESA            ,P_SOLICITUD
                                ,vFechaApertura         ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                --,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
								,CASE WHEN val_ifrs = 'A' THEN  SOL.MONTO_SOLICITADO-P_MTOENGANCHE	ELSE 0 END  , SOL.MONTO_SOLICITADO-P_MTOENGANCHE
                                ,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,vPagCuota              ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE   ,0
                              --  ,0                      ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
							    ,0					    ,CASE WHEN val_ifrs = 'A' THEN  0	ELSE SOL.MONTO_SOLICITADO-P_MTOENGANCHE END 
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,0
                                ,0                      ,vPagCuota
								,0
                          FROM   bdisolic:"informix".ss_SOLICITUDES SOL
                          WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
                          AND    SOL.EMPRESA   = P_EMPRESA;

	--  FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
	INSERT INTO bdicred:"informix".sd_indicador_cred_crd
			(empresa, num_credito, fecha_alta)
	VALUES (P_EMPRESA, P_SOLICITUD, vFechaApertura);

    -- *********************************************************
                  -- INSERTA LA  TABLA DE AMORTIZACIONES *
    -- *********************************************************
	
	FOREACH
		SELECT fecha_cuota,capital_cuota,sum(capital_cuota + interes_cuota + iva_cuota)
		INTO vFechaT, vCapDebe,vPagCuota
		FROM bdicred:"informix".sd_proyecta
		WHERE empresa = P_EMPRESA
		AND num_solicitud = P_SOLICITUD
		GROUP BY 1,2
		ORDER BY fecha_cuota  -- BGM 21-Mayo-10 se ordena por fecha cuota
		INSERT INTO sd_amortiza_creditocrd values   
				(P_EMPRESA,P_SOLICITUD,vFechaT,"3",vPagCuota,vCapDebe,0,"4","0","",  -- BGM 21-May-2010 se considera 4 estatus de capital
				0,0,"3","0","", 0,0,"1","0","", 0,0,0,0,0,0,0,"1", 0,0,"1","",   -- BGM 21-May-2010 se considera variable para nÃÂÃÂÃÂÃÂºmero de cuota en el campo num_pago
				vCuenta,0,0,"","");
			   
		LET vCuenta=vCuenta+1;  -- BGM 21-May-2010 se incrementa variable para nÃÂÃÂÃÂÃÂºmero de cuota en el campo num_pago

	END FOREACH;

	UPDATE bdicred:"informix".sd_amortiza_creditocrd set capital_status = '3'   -- BGM 21-May-2010 se actualiza capital status de primer cuota a 3
	WHERE num_credito = P_SOLICITUD AND num_pago = 1;

    -- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- Complemento De Datos                 *
    -- **************************************

    SELECT periodo_plazo    , plazo          , divisa          ,tipo_calculo,
			cod_tasa_base    , sobretasa      , factor_sobretasa,
			tasa_interes     , tasa_fija_o_var, cod_tasa_mora   ,
			fact_sobret_mora , sobretasa_mora , tasa_moratorios ,
			period_pago_cap  , period_pag_int , fecha_apertura  ,
			fecha_vencim
    INTO vPerPlazo          , vPlazo         , vDivisa         , vTipoCalculo,
			vCodTasInt         , vSobretasa     , vFacSobreTasa   ,
			vTasaInteres       , vTasaFijVar    , vCodTasaMora    ,
			vFacSobretMora     , vSobretMora    , vTasaMora       ,
			vPerPagCap         , vPerPagInt     , vFecApert       ,
			vFecVenc
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = P_EMPRESA
	AND num_credito = P_SOLICITUD;

    UPDATE bdisolic:"informix".ss_solicitudes
                SET status_solicitud = "AP",
                    tipo_prestamo    = "C",
                    periodo_plazo    = vPerPlazo,
                    plazo            = vPlazo,
                    divisa           = vDivisa,
                    tipo_calculo     = vTipoCalculo,
                    cod_tasa_base    = vCodTasInt,
                    sobretasa        = vSobretasa,
                    factor_sobretasa = vFacSobreTasa,
                    tasa_interes     = vTasaInteres,
                    tasa_fija_o_var  = vTasaFijVar ,
                    cod_tasa_mora    = vCodTasaMora,
                    factor_moratorio = vFacSobretMora,
                    sobretasa_mora   = vSobretMora,
                    tasa_moratorios  = vTasaMora ,
                    periodo_pag_cap  = vPerPagCap,
                    periodo_pag_int  = vPerPagInt,
                    fecha_apert_prop = vFecApert,
                    fecha_venc_prop  = vFecVenc,
                    co_numcte        = P_NUMCTA
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	SELECT nombre INTO vMensaje
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = P_EJECUTIVO
	AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:"informix".ss_autorizacion
        (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
         comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	    vFechaApertura, vFechaApertura, USER, TODAY);


    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008

    LET vTasaMora = vTasaMora - vTasaInteres;
    IF vTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET vTasaMora = vTasaMora * -1;
    END IF

	SELECT {+INDEX ("informix".sd_definicioncrd)}
		a.num_producto, a.divisa, b.monto_solicitado, b.sucursal
	INTO vProducto, vDivisa, P_MTOSOL, vSucursal
	FROM bdisolic:"informix".ss_solicitudes b, 
		bdicred:"informix".sd_definicioncrd a
	WHERE b.empresa = P_EMPRESA
	AND b.num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto;


	--** EXTRAE EL MONTO DE LA REESTRUCTURA
	SELECT otro_copresta
	INTO   vMtoReestruc
	FROM   bdisolic:"informix".ss_anexosol
	WHERE  num_solicitud = P_SOLICITUD;

	 --**GENERA MOVIMIENTO DE APERTURA

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
		vProducto       , 2,
		"001"           , vFechaApertura,
		P_MTOSOL-P_MTOENGANCHE        , vFolio,
		vSucursal       ,vDivisa,
		"0000","APERTURA REESTRUCTURA","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
					vProducto       , 1,
					"002"           , vFechaApertura,
					P_MTOSOL-P_MTOENGANCHE        , vFolio,
					vSucursal       ,vDivisa,
					"0000","APERTURA REESTRUCTURA","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
										   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
										   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;
	
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',2,P_NUMCTE, p_ejecutivo)
	INTO vCodRet, P_MENSAJE;
	
	LET vCodRet  = '00000';
	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
END PROCEDURE
DOCUMENT
'FOLIO: 438-RQM 10 1024-ActualizaciÃÂÃÂ³n de las tablas de amortizaciÃÂÃÂ³n para PrÃÂÃÂ©stamo Personal y Reestructura',
'MODIFICÃÂÃÂ: 95358897 - ISARAI BOJORQUEZ',
'MODIFICACIÃÂÃÂN: SE MODIFICA PROCEDIMIENTO PARA AGREGAR EL MONTO DE ENGANCHE AL CAMPO valor_preferencial DE LA TABLA sd_maecredcrd Y CAMBIAR',
'VALOR DEL PARAMETRO P_MTOENGANCHE DECIMAL (18,2)',
'FECHA: 29/08/2018 ',
'BD:BDICRED';

CREATE PROCEDURE "informix".sp_apertura_credito_restructura_prestamo(P_EMPRESA      VARCHAR(3),		P_SOLICITUD     VARCHAR(20),
																	P_SOLANTIGUA    CHAR(20),		P_PLAZO         INTEGER,
																	P_MTOSOL        DECIMAL(14,2),	P_MTOENGANCHE   DECIMAL(18,2),	
																	P_NUMCTE        CHAR(20),		P_NUMCTA        CHAR(20),
																	P_SUCURSAL      CHAR(4),		P_TPSOL         CHAR(4),
																	P_PRODUCTO      CHAR(4),		P_EJECUTIVO     CHAR(8),
																	P_MONTOADEUDO   CHAR(20),		P_PERIODOGRACIA  CHAR(2))

	RETURNING CHAR(5)     ,  --CodRet
			  DECIMAL(9,6),  --TasaInteres
			  DECIMAL(9,6),  --TasaMora
			  DECIMAL(9,6),  --Cat
			  CHAR(1)     ;  --Mercadeo

	--*****************************************************
	--DECLARACION DE VARIABLES
	--*****************************************************
	---Variables de control de errores
	DEFINE vCodRet            	VARCHAR(8);
	DEFINE CodRet             	VARCHAR(8);
	DEFINE p_mensaje           	VARCHAR(80);
	DEFINE error_info          	VARCHAR(80);
	DEFINE sql_err             	INTEGER;
	DEFINE isam_err            	INTEGER;
	DEFINE wBegin              	CHAR(1);
	DEFINE vFechaApertura      	DATE;
	DEFINE vFechaVenc          	DATE;
	DEFINE i                   	INTEGER;
	DEFINE vPlazo              	INTEGER;
	DEFINE vFactor_FAV         	CHAR(1);
	DEFINE vMercadeo           	CHAR(1);
	DEFINE vNumCredito         	CHAR(20);
	DEFINE vProducto           	CHAR(4);
	DEFINE vDivisa             	CHAR(2);
	DEFINE vSucursal           	CHAR(4);
	DEFINE vFolio	           	CHAR(16);
	DEFINE vFactor	           	CHAR(1);
	DEFINE vMensaje            	CHAR(200);
	DEFINE vPerPlazo           	CHAR(1);
	
	DEFINE vTipoCalculo        	CHAR(2);
	DEFINE vCodTasInt          	CHAR(8);
	DEFINE vFacSobreTAsa       	CHAR(1);
	DEFINE vTasaFijVar         	CHAR(1);
	DEFINE vCodTasaMora        	CHAR(8);
	DEFINE vFacSobretMora      	CHAR(1);
	DEFINE vPerPagCap          	CHAR(1);
	DEFINE vPerPagInt          	CHAR(1);
	DEFINE vFecApert           	DATE;
	DEFINE vFecVenc            	DATE;
	DEFINE vFechaT             	DATE;
	DEFINE vDiaCorte           	SMALLINT;
	DEFINE vCapDebe            	DECIMAL(14,2);
	DEFINE vPagCuota           	DECIMAL(14,2);
	DEFINE vCatIva             	DECIMAL(9,6);
	DEFINE vTasaInteres        	DECIMAL(9,6);
	DEFINE vTasaMora           	DECIMAL(9,6);
	DEFINE vSobretasa          	DECIMAL(9,6);
	DEFINE vTasaFavor          	DECIMAL(9,6);
	DEFINE vSobretMora         	DECIMAL(9,6);
	DEFINE vMtoReestruc        	CHAR(20);
	DEFINE vCuenta			   	SMALLINT;  -- BGM 21-May-2010 se define variable para nÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂºmero de cuota
	DEFINE vproxfechapag       	DATE;
	--DEFINE vproxfechapagaux    DATE;
	--Variables de cargo y abono a cuenta
	DEFINE vt_sucursal      	CHAR(4);
	DEFINE vt_codigo_mn     	CHAR(2);
	DEFINE vt_sdocta        	DECIMAL(14,2);
	DEFINE vt_bloqueo       	CHAR(1);
	DEFINE vt_sdodisp       	MONEY(14,2);
	DEFINE vt_dummy         	CHAR(4);
	DEFINE vt_dummy1        	DATE;
	DEFINE vfechacheq       	DATE;
	--valida comisiones jomm ini
	DEFINE vcom_pendiente   	DECIMAL(9,6);
	--valida comisiones jomm fin
	DEFINE vExiste				INTEGER;
	DEFINE bEsNumero          	BOOLEAN;
	-- Valida que la sol existen sea del mismo cliente
	DEFINE vNumCredTdcAux   	CHAR(20);
	DEFINE vNumCteAux       	CHAR(20);
	--- Cuenta Clabe
	DEFINE vcod_ret				CHAR (6);
	DEFINE cta_Clabe			CHAR (18);
	-- NUEVA DECLARACION DE VARIABLES PARA QUITAR INSERT-SELECT
	DEFINE mEmpresa				CHAR(3);
	DEFINE mNumProducto			CHAR(4);
	DEFINE mEjecutivoSol		CHAR(8);
	DEFINE mNumCte				CHAR(20);
	DEFINE mDivisa				CHAR(2);
	DEFINE mSucursal			CHAR(4);
	DEFINE mIdOrigen			CHAR(2);
	DEFINE mOrigen				CHAR(3);
	DEFINE mCodTipoLinea		CHAR(2);
	DEFINE mCodLinea			CHAR(4);
	DEFINE mStatusCred			CHAR(2);
	DEFINE mBanderaRenovac		CHAR(1);
	DEFINE mBanderaProrroga		CHAR(1);
	DEFINE mPeriodoPlazo		CHAR(1);	
	DEFINE mPeriodoPagoCap		CHAR(1);
	DEFINE mPeriodoPagoInt		CHAR(1);
	DEFINE mDiasTraspCap		INTEGER;
	DEFINE mDiasTraspInt		INTEGER;
	DEFINE mTasaFijaOVar		CHAR(1);
	DEFINE mCodTasaBase			CHAR(8);
	DEFINE mFactorSobreTasa		CHAR(1);
	DEFINE mSobretasa			DECIMAL(9,6);
	DEFINE mCodTasaMora			CHAR(8);
	DEFINE mSobretasaMora		DECIMAL(9,6);
	DEFINE mFactSobretMora		CHAR(1);
	DEFINE mFechaPagoCap		DATE;
	DEFINE mFechaPagoInt		DATE;
	DEFINE mEsFisica			CHAR(1);
	DEFINE mBanderaFiFo			CHAR(2);
	DEFINE mActividad			CHAR(3);
	DEFINE mTipoCalculo			CHAR(2);
	DEFINE mNumAperAnt			CHAR(20);
	DEFINE mRevTasaVarPer		CHAR(1);
	DEFINE mCodProd				CHAR(2);
	DEFINE mBanderaMinistra		CHAR(1);
	DEFINE mPagosSostenidos		INTEGER;
	DEFINE mCampoTrab1			DECIMAL(18,2);
	DEFINE mCampoTrab2			DECIMAL(18,2);
	DEFINE mCampoTrab3			CHAR(10);
	DEFINE mCampoTrab4			CHAR(10);
	DEFINE mxCampo3				INTEGER;
	DEFINE mxPagoAdicSigCuota	CHAR(1);
	DEFINE mxTpoPersona			CHAR(2);
	DEFINE mxManejaLinea		CHAR(1);
	DEFINE mxCodTasaBase		CHAR(8);
	DEFINE mxFactorSobreTasa	CHAR(1);
	DEFINE mxSobretasa			DECIMAL(9,6);
	DEFINE msEmpresa			CHAR(3);
	DEFINE msSdoIntAnticip		DECIMAL(18,2);
	DEFINE msSdoIntAntDev		DECIMAL(18,2);
	DEFINE msSdoIntereses		DECIMAL(18,2);
	DEFINE msSdoDiaAntInt		DECIMAL(18,2);
	DEFINE msSdoMesAntInt		DECIMAL(18,2);
	DEFINE msSdoAcumMesInt		DECIMAL(18,2);
	DEFINE msSdoRetenido		DECIMAL(18,2);
	DEFINE msSdoAcumCapInt		DECIMAL(18,2);
	DEFINE msSdoExigInt			DECIMAL(18,2);
	DEFINE msSdoNoExig			DECIMAL(18,2);
	DEFINE msProvisionNormal	DECIMAL(18,2);
	DEFINE msDiasAcumInt		INTEGER;
	DEFINE msSdoMoratorio		DECIMAL(18,2);
	DEFINE msSdoDiaAntMor		DECIMAL(18,2);
	DEFINE msSdoMesAntMor		DECIMAL(18,2);
	DEFINE msSdoContabMora		DECIMAL(18,2);
	DEFINE msDiasAcumMora		INTEGER;
	DEFINE msSdoCapital			DECIMAL(18,2);
	DEFINE msSdoCapInsoluto		DECIMAL(18,2);
	DEFINE msSdoDiaAntCap		DECIMAL(18,2);
	DEFINE msSdoMesAntCap		DECIMAL(18,2);
	DEFINE msSdoAcumMesCap		DECIMAL(18,2);
	DEFINE msMtoCapitalizado	DECIMAL(18,2);
	DEFINE msMtoMinistraCap		DECIMAL(18,2);
	DEFINE msCargosDiaCap		DECIMAL(18,2);
	DEFINE msAbonosDiaCap		DECIMAL(18,2);
	DEFINE msCargosMesCap		DECIMAL(18,2);
	DEFINE msAbonosMesCap		DECIMAL(18,2);
	DEFINE msDiasAcumCap		INTEGER;
	DEFINE msMontoVencido		DECIMAL(18,2);
	DEFINE msMtoVencTrasp		DECIMAL(18,2);
	DEFINE msMontoReservado		DECIMAL(18,2);
	DEFINE msSdoAcumVencido		DECIMAL(18,2);
	DEFINE msDiasAcumIntper		INTEGER;
	DEFINE msSdoGlobalInt		DECIMAL(18,2);
	DEFINE msSdoAcumIntper		DECIMAL(18,2);
	DEFINE msMontoOtorgado		DECIMAL(18,2);
	DEFINE msProviVencNormal	DECIMAL(18,2);	
	DEFINE msProviVencAnticip	DECIMAL(18,2);
	DEFINE msCapTrasNoVenci		DECIMAL(18,2);
	DEFINE msMtoVencInt			DECIMAL(18,2);
	DEFINE msMtoVencTraInt		DECIMAL(18,2);
	DEFINE msMtoFinanVdo		DECIMAL(18,2);
	DEFINE msMtoReserInt		DECIMAL(18,2);
	DEFINE msMtoFinVenTrasp		DECIMAL(18,2);
	DEFINE msMtoFinVigTrasp		DECIMAL(18,2);
	DEFINE msIntTraNoExig		DECIMAL(18,2);
	DEFINE val_ifrs char(1);

	ON EXCEPTION SET sql_err, isam_err, error_info
		--SET DEBUG FILE TO "Principal.err";
		---TRACE sql_err||" * "||isam_err||" * "||error_info;
		-- FMV 15mar13: Seguimiento al error -268 rastreo de la causa
		INSERT INTO  bdicred:"informix".sd_bitacora_mec values 
		('001', '8600', today, sql_err, 'isam_err:'||isam_err||':error_info:'||error_info, user, today, current );
		LET vCodRet   = sql_err;
		LET p_mensaje = error_info;
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		LET wBegin = "S";
		ROLLBACK WORK;
		BEGIN WORK;
	END EXCEPTION WITH RESUME;

      LET wBegin = "N";

      BEGIN WORK;

	--SET DEBUG FILE TO '/ifxsif01/joel/sp_apertura_credito.out';
	--TRACE ON;
	
--	SET DEBUG FILE TO '/RESPALDOS/PruebasIFSR/CNR/ReestructuraDePP/REE/sp_apertura_credito.out';
--	TRACE ON;

	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

	--***********************
	--INICIALIZA VARIABLE
	--***********************
	LET  vCodRet        	 = '00000';
	LET  p_mensaje       	= 'PROCESO EXITOSO';
	LET  vTasaInteres   	= 0;
	LET  vTasaMora      	= 0;
	LET  vSobretasa     	= 0;
	LET  vTasaFavor     	= 0;
	LET  vFactor	  		= '';
	LET  vFechaApertura 	= '';
	LET  vFechaVenc     	= '';
	LET  vFactor_FAV    	= '';
	LET  vProducto      	= '';
	LET  vDivisa        	= '';
	LET  vSucursal      	= '';
	LET  vFolio	  			= '';
	LET  vMensaje       	= '';
	LET  vFechaT        	= '';
	LET  vDiaCorte      	= 0;
	LET  vCatIva	  		= 0;
	LET  vMercadeo      	= '';
	LET  vNumCredito    	= '';
	LET  i              	= 0;
	LET vCapDebe        	= 0;
	LET vPagCuota       	= 0;
	LET  vPerPlazo      	= '';
	LET  vPlazo         	= 0;
	LET  vDivisa        	= '';
	LET  vTipoCalculo   	= '';
	LET  vCodTasInt     	= '';
	LET  vFacSobreTAsa  	= '';
	LET  vTasaFijVar    	= '';
	LET  vCodTasaMora   	= '';
	LET  vFacSobretMora 	= '';
	LET  vSobretMora    	= 0;
	LET  vPerPagCap     	= '';
	LET  vPerPagInt     	= '';
	LET  vFecApert      	= '';
	LET  vFecVenc       	= '';
	LET  vMtoReestruc   	= '';
	LET  vCUenta = 1;  -- BGM 21-May-2010 se inicializa variable para numero de cuota
	LET  vt_sdocta      	= 0;
	LET  vt_bloqueo     	= '';
	LET vproxfechapag   	= DATE(1);
	LET vcom_pendiente  	= 0;
	LET bEsNumero       	= 't';
	LET vExiste 		 	=  0;

	LET  P_MTOSOL       	= P_MTOSOL;
	LET P_MTOENGANCHE   	= NVL(P_MTOENGANCHE,0);
	LET P_MONTOADEUDO   	= P_MONTOADEUDO;
	
	--- Cuenta Clabe
	LET vcod_ret			= '000';
	LET cta_Clabe			= '';
	-- INICIALIZACION DE VARIABLES PARA QUITAR INSERT-SELECT
	LET mEmpresa			= '';
	LET mNumProducto		= '';
	LET mEjecutivoSol		= '';
	LET mNumCte				= '';
	LET mDivisa				= '';
	LET mSucursal			= '';
	LET mIdOrigen			= '';
	LET mOrigen				= '';
	LET mCodTipoLinea		= '';
	LET mCodLinea			= '';
	LET mStatusCred			= '';
	LET mBanderaRenovac		= '';
	LET mBanderaProrroga	= '';
	LET mPeriodoPlazo		= '';
	LET mPeriodoPagoCap		= '';
	LET mPeriodoPagoInt		= '';
	LET mDiasTraspCap		= 0;
	LET mDiasTraspInt		= 0;
	LET mTasaFijaOVar		= '';
	LET mCodTasaBase		= '';
	LET mFactorSobreTasa	= '';
	LET mSobretasa			= 0;
	LET mCodTasaMora		= '';
	LET mSobretasaMora		= 0;
	LET mFactSobretMora		= '';
	LET mFechaPagoCap		= '';
	LET mFechaPagoInt		= '';
	LET mEsFisica			= '';
	LET mBanderaFiFo		= '';
	LET mActividad			= '';
	LET mTipoCalculo		= '';
	LET mNumAperAnt			= '';
	LET mRevTasaVarPer		= '';
	LET mCodProd			= '';
	LET mBanderaMinistra	= '';
	LET mPagosSostenidos	= 0;
	LET mCampoTrab1			= 0;
	LET mCampoTrab2			= 0;
	LET mCampoTrab3			= '';
	LET mCampoTrab4			= '';
	LET mxCampo3			= 0;
	LET mxPagoAdicSigCuota	= '';
	LET mxTpoPersona		= '';
	LET mxManejaLinea		= '';
	LET mxCodTasaBase		= '';
	LET mxFactorSobreTasa	= '';
	LET mxSobretasa			= 0;
	LET msEmpresa			= '';
	LET msSdoIntAnticip		= 0;
	LET msSdoIntAntDev		= 0;
	LET msSdoIntereses		= 0;
	LET msSdoDiaAntInt		= 0;
	LET msSdoMesAntInt		= 0;
	LET msSdoAcumMesInt		= 0;
	LET msSdoRetenido		= 0;
	LET msSdoAcumCapInt		= 0;
	LET msSdoExigInt		= 0;
	LET msSdoNoExig			= 0;
	LET msProvisionNormal	= 0;
	LET msDiasAcumInt		= 0;
	LET msSdoMoratorio		= 0;
	LET msSdoDiaAntMor		= 0;
	LET msSdoMesAntMor		= 0;
	LET msSdoContabMora		= 0;
	LET msDiasAcumMora		= 0;
	LET msSdoCapital		= 0;
	LET msSdoCapInsoluto	= 0;
	LET msSdoDiaAntCap		= 0;
	LET msSdoMesAntCap		= 0;
	LET msSdoAcumMesCap		= 0;
	LET msMtoCapitalizado	= 0;
	LET msMtoministraCap	= 0;
	LET msCargosDiaCap		= 0;
	LET msAbonosDiaCap		= 0;
	LET msCargosMesCap		= 0;
	LET msAbonosMesCap		= 0;
	LET msDiasAcumCap		= 0;
	LET msMontoVencido		= 0;
	LET msMtoVencTrasp		= 0;
	LET msMontoReservado	= 0;
	LET msSdoAcumVencido	= 0;
	LET msDiasAcumIntper	= 0;
	LET msSdoGlobalInt		= 0;
	LET msSdoAcumIntper		= 0;
	LET msMontoOtorgado		= 0;
	LET msProviVencNormal	= 0;
	LET msProviVencAnticip	= 0;
	LET msCapTrasNoVenci	= 0;
	LET msMtoVencInt		= 0;
	LET msMtoVencTraInt		= 0;
	LET msMtoFinanVdo		= 0;
	LET msMtoReserInt		= 0;
	LET msMtoFinVenTrasp	= 0;
	LET msMtoFinVigTrasp	= 0;
	LET msIntTraNoExig		= 0;
	LET val_ifrs ='';
	
	-- FMV 10-JUL-2013: Se adiciona validacion al recibir incorrecto el No. Solicitud, por el error 24 tiempo de espera agotado
	EXECUTE PROCEDURE bdinteg:"informix".val_num (P_SOLICITUD) INTO bEsNumero;
	IF bEsNumero = 'f' OR trim(P_SOLICITUD) = '' OR P_SOLICITUD is null THEN
		LET vCodRet='242'; --EL NUMERO DE SOLICITUD NO EXISTE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
	--//Cat
	SELECT valor INTO vCatIva
	FROM   bdicred:"informix".sd_param
	WHERE  cod_param = '321';
	IF vCatIva IS NULL THEN
		LET vCatIva = 0;
	END IF;

	SELECT fecha_hoy
	INTO vFechaApertura
	FROM bdicred:"informix".sd_fechas
	WHERE empresa = P_EMPRESA;

	--//Folio
	SELECT P_EJECUTIVO
	|| REPLACE(REPLACE(CURRENT HOUR TO FRACTION,':',''),'.','') FOLIO
	INTO vFolio
	FROM bdicred:"informix".sd_FECHAS; --PRODUCE SEQUENTIAL

	SELECT num_credito
	INTO vNumCredito
	FROM "informix".sd_maecredcrd
	WHERE empresa      = P_EMPRESA
	AND num_credito = P_SOLANTIGUA;

	--//Sucursal
	SELECT sucursal
	INTO vt_sucursal
	FROM bdicheq:"informix".sc_maechq
	WHERE empresa = P_EMPRESA
	AND cuenta  = P_NUMCTA;

	--//Tipo de Moneda
	SELECT valor
	INTO vt_codigo_mn
	FROM bdinteg:"informix".si_param
	WHERE empresa = P_EMPRESA
	AND descripcion ="codigo mn";
	
	--VAlida si esta activo el IFRS	
	select nvl(valor,'I') into val_ifrs from sd_param where cod_param = '700';

	--------------------------------------------------------
	---     GENERA LA SOLICITUD DE REESTRUCTURA          ---
	--------------------------------------------------------
	-- CGP 18-12-2014 se modifica para evitar el error -268
	SELECT COUNT(num_solicitud) INTO vExiste FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD;
    --IF NOT EXISTS (SELECT num_solicitud FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA AND num_solicitud = P_SOLICITUD) THEN
	IF vExiste = 0 THEN
		--FMV 20dic12 : Se eliminan las tablas previo a insertar datos por duplicidad y error -268 informix en el proceso.
		DELETE FROM bdisolic:"informix".ss_solicitudes WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD; -- se le quita el estatus de la solicitud CGP

		DELETE FROM bdisolic:"informix".ss_anexosol WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD;

		DELETE FROM bdisolic:"informix".ss_autorizacion WHERE empresa = P_EMPRESA
														AND num_solicitud = P_SOLICITUD
														AND status_solicitud = 'PC';


		INSERT INTO bdisolic:"informix".ss_solicitudes
		(empresa         , num_solicitud, numcte           , sucursal  , tipo_solicitud,
		status_solicitud, num_producto , monto_solicitado ,user_insert, fecha_insert)
		VALUES
		(P_EMPRESA      , P_SOLICITUD   , P_NUMCTE   , P_SUCURSAL, P_TPSOL      ,
		"PC"           , P_PRODUCTO    , P_MTOSOL   ,P_EJECUTIVO, vFechaApertura);

		INSERT INTO bdisolic:"informix".ss_anexosol
		(empresa  , num_solicitud, fecha_sol   , ejecutivo_sol, otro_presta,
		user_insert, fecha_insert, otro_copresta,num_acta)
		VALUES
		(P_EMPRESA, P_SOLICITUD , vFechaApertura, P_EJECUTIVO  , P_MTOENGANCHE,
		P_EJECUTIVO, vFechaApertura, P_MONTOADEUDO, P_SOLANTIGUA);

		INSERT INTO bdisolic:"informix".ss_autorizacion
		(empresa      , ejecutivo_auto, num_solicitud, status_solicitud, comentario,
		fecha_entrada, fecha_salida  , user_insert  , fecha_insert)
		VALUES
		(P_EMPRESA    , P_EJECUTIVO   , P_SOLICITUD  , "PC"            , "Solicitud Pre-Calificada  por sistema",
		vFechaApertura, vFechaApertura , P_EJECUTIVO  , vFechaApertura);

    ELSE
        --Obtiene el credito existen en base de datos y compara que sea el mismo cliente.
        SELECT limit 1 numcte, credito_externo INTO vNumCteAux, vNumCredTdcAux FROM bdicred:"informix".sd_maecredcrd 
		WHERE empresa = P_EMPRESA AND num_credito = P_SOLICITUD;
        LET P_NUMCTE = P_NUMCTE;
        LET vNumCredito = vNumCredito;

        IF vNumCteAux != P_NUMCTE OR vNumCredTdcAux != vNumCredito THEN
			LET vCodRet = '366'; -- Ya existe registro previo del credito con cliente y credito 6001 diferente
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
    END IF;

  --------------------------------------------------------
  ---     GENERA MOVIMIENTO DE CARGO Y ABONO           ---
  --------------------------------------------------------
  --IFSR se comenta para pruebas de la linea 483 a la 580
--//Valida comisiones pendientes JOM INI
    SELECT NVL(com_pendiente ,0)
    INTO vcom_pendiente
    FROM bdicheq:"informix".sc_maechq 
    WHERE empresa = P_EMPRESA 
    AND cuenta = P_NUMCTA;

    IF vcom_pendiente > 0 then
		LET vCodRet='400';
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
        RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;

	--//Valida comisiones pendientes JOM INI

	---INI CAS
	--//Valida Saldo de la Cuenta
	EXECUTE PROCEDURE bdicheq:"informix".cons_saldo(P_NUMCTA)
	INTO vCodRet, vt_sdocta, vt_bloqueo;

    IF vCodRet = "000" AND vt_bloqueo='1' AND vt_sdocta >= P_MTOENGANCHE THEN

		SELECT fecha_proceso
		INTO vfechacheq
		FROM bdicheq:"informix".sc_maechq
		WHERE cuenta=P_NUMCTA;

		IF vfechacheq<>vFechaApertura THEN
			LET vCodRet='549';
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
		END IF;
		--//Aplicar el Abono del prestamo
--		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
		EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0509', "0000", vFolio,
                                           P_NUMCTA, 0,P_MTOSOL - P_MTOENGANCHE, P_MTOSOL - P_MTOENGANCHE,
	                    		           0,0,0,vt_codigo_mn, TRIM(P_SOLICITUD) ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
	    INTO vCodRet;
       --//Verifica si el abono fue exitoso
        IF vCodRet <> "000" THEN
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;
		--JMAH RQM 10 495 
        --//Ejecutar cargo total de la reestructura
        --EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0279',"0000",vFolio,P_NUMCTA,0,P_MTOSOL,
		EXECUTE PROCEDURE bdicheq:"informix".cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0508',"0000",vFolio,P_NUMCTA,0,P_MTOSOL,
                                    vt_codigo_mn,'REESTRUCTURA CREDITO',P_SOLANTIGUA,p_ejecutivo)
        INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

       --//Verifica si el cargo fue exitoso
        IF vCodRet <> "000" THEN
			--//Ejecutar cargo igual al monto del abono de la reestructura
			--          EXECUTE PROCEDURE bdicheq:cargo_ref(P_EMPRESA,vt_sucursal,p_ejecutivo,'0227',"0000",vFolio,P_NUMCTA,0,P_MTOSOL - P_MTOENGANCHE,
			--                                      vt_codigo_mn,'REESTRUCTURA CREDITO',"",p_ejecutivo)
			--          INTO vCodRet, vt_dummy,vt_dummy1,vt_sdodisp,vt_sdocta;

            EXECUTE PROCEDURE "informix".reversioncrd(P_EMPRESA,vt_sucursal,p_ejecutivo,vFolio,'B')
            INTO vCodRet;

			IF vCodRet <> "000" THEN
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
			END IF;
			ROLLBACK WORK;
			IF (wBegin = "S") THEN
				BEGIN WORK;
			END IF;
			RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
        END IF;

    ELSE
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;

		IF vCodRet = "000" AND vt_sdocta < P_MTOENGANCHE THEN
		LET vCodRet = "400";
		ELIF vt_bloqueo<>'1' THEN
		LET vCodRet = "432";
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
    END IF;
	---FIN CAS

	-----------------------------------------------------------
	--- REVISA QUE NO EXISTA REESTRUCTURA EN TABLAS Y BORRA ---
	-----------------------------------------------------------

	DELETE FROM bdicred:"informix".sd_MAESDOSCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;
/*
	DELETE FROM bdicred:"informix".sd_MOVDIA
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;
*/
	DELETE FROM bdicred:"informix".sd_MOVDIACRD     --FMV 20dic12: Se adiciona por error informix -268
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDANEXOCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	UPDATE bdisolic:"informix".ss_solicitudes 
	SET status_solicitud = "AT"
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	DELETE FROM bdisolic:"informix".ss_autorizacion
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND status_solicitud = "AP";

	DELETE FROM bdicred:"informix".sd_amortiza_creditocrd
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_MAECREDCRD
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_ctascarg
	WHERE EMPRESA     = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	DELETE FROM bdicred:"informix".sd_indicador_cred_crd  --FMV 15may13
	WHERE EMPRESA = P_EMPRESA
	AND NUM_CREDITO = P_SOLICITUD;

	-----------------------------------------
	--- PROCESO DE LIQUIDACION DE CREDITO ---
	-----------------------------------------
	CALL "informix".sp_liquida_prestamo_reestructura(p_empresa,vNumCredito,vFolio) RETURNING vCodRet,p_mensaje;

	IF vCodRet <> '00000' THEN
	ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA CREDITO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	--**Monto Minimo Para Consulta Generalizada Y Tabla De Amortizacion
	SELECT MIN(fecha_cuota)
	INTO vFechaT
	FROM bdicred:"informix".sd_proyecta
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	LET vproxfechapag=vFechaT;

	IF DAY(vFechaT) = '17' THEN
		LET vDiaCorte = 17;
	ELIF DAY(vFechaT) = '02' THEN
		LET vDiaCorte = 2;
	END IF;

         --** Fecha Vencimiento Del Credito

	LET  vFechaVenc= (SELECT MAX(fecha_cuota)
						FROM bdicred:"informix".sd_proyecta
						WHERE empresa = P_EMPRESA
						AND num_solicitud = P_SOLICITUD);
	IF vfechavenc IS NULL THEN LET vfechavenc=DATE(1); END IF;

	-- ****************************
	-- Determina Tasas de Interes *
	-- ****************************
	--INTERES ORDINARIO
	SELECT c.valor, a.factor_sobretasa, a.sobretasa --, a.dia_cuota
	INTO vTasaInteres, vFactor, vSobretasa        --, vDiaCorte
	FROM bdicred:"informix".sd_definicion a, 
	bdisolic:"informix".ss_solicitudes b,
	bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_base
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_base);


	IF vFactor = "+" THEN
		LET vTasaInteres = vTasaInteres + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaInteres = vTasaInteres - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaInteres = vTasaInteres * vSobretasa;
	ELSE
		LET vTasaInteres = vTasaInteres / vSobretasa;
	END IF

	--INTERES MORATORIO
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		c.valor, a.fact_sobret_mora, a.sobretasa_mora
	INTO vTasaMora   , vFactor, vSobretasa
	FROM bdicred:"informix".sd_definicioncrd a, 
		bdisolic:"informix".ss_solicitudes b,
		bdinteg:"informix".si_fechavalor c
	WHERE b.empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto
	AND c.empresa = a.empresa
	AND c.tasa = a.cod_tasa_mora
	AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
					WHERE r.empresa = P_EMPRESA
					AND r.tasa = a.cod_tasa_mora);

	IF vFactor = "+" THEN
		LET vTasaMora = vTasaMora + vSobretasa;
	ELIF vFactor = "-" THEN
		LET vTasaMora = vTasaMora - vSobretasa;
	ELIF vFactor = "*" THEN
		LET vTasaMora = vTasaMora * vSobretasa;
	ELSE
		LET vTasaMora = vTasaMora / vSobretasa;
	END IF

        --INTERES A FAVOR DEL CLIENTE
        SELECT {+INDEX ("informix".sd_definicioncrd)}
			c.valor, a.factor_sobretasa, a.sobretasa
		INTO vTasaFavor   , vFactor_FAV, vSobretasa
		FROM bdicred:"informix".sd_definicioncrd a, 
			bdisolic:"informix".ss_solicitudes b,
			bdinteg:"informix".si_fechavalor c
         WHERE b.empresa = P_EMPRESA
			AND num_solicitud = P_SOLICITUD
			AND a.empresa = b.empresa
			AND a.num_producto = b.num_producto
			AND c.empresa = a.empresa
			AND c.tasa = a.cod_tasa_base
			AND c.fecha = (SELECT MAX(r.fecha) FROM bdinteg:"informix".si_fechavalor r
							WHERE r.empresa = P_EMPRESA
                            AND r.tasa = a.cod_tasa_base);



        IF vFactor_FAV = "+" THEN
            LET vTasaFavor = vTasaFavor + vSobretasa;
        ELIF vFactor_FAV = "-" THEN
            LET vTasaFavor = vTasaFavor - vSobretasa;
        ELIF vFactor_FAV = "*" THEN
            LET vTasaFavor = vTasaFavor * vSobretasa;
        ELSE
			LET vTasaFavor = vTasaFavor / vSobretasa;
        END IF
		
	--- Genera cuenta Clabe
	EXECUTE PROCEDURE bdicred:"informix".sp_gen_clabe_interbancaria (P_EMPRESA,P_SOLICITUD,P_PRODUCTO)
		INTO vcod_ret, cta_Clabe;

	--**INSERTA LA CUENTA PARA COBRO
	INSERT INTO "informix".sd_ctascarg
		(EMPRESA           ,NUMERO          ,
		CON_CAP_INTE      ,NATURALEZA      ,
		NUM_CREDITO       ,TIPO_CTA        ,
		NUM_CTA           , NUM_NOMINA)
	VALUES
		(P_EMPRESA        , 0               ,
		''               , 'A'             ,
		P_SOLICITUD      , ''              ,
		P_NUMCTA         , ''              );


	--***** ACTUALIZA SD_MAECRED
/* --Comentado para quitar insert - select
	INSERT INTO bdicred:"informix".sd_maecredcrd
		(EMPRESA				,NUM_CREDITO				,NUM_PRODUCTO			,EJECUTIVO
		,NUMCTE                 ,DIVISA						,SUCURSAL               ,ID_ORIGEN
		,ORIGEN                 ,COD_TIPO_LINEA				,COD_LINEA				,STATUS_CRED            
		,BANDERA_RENOVAC		
		,BANDERA_PRORROGA		,PERIODO_PLAZO				,PLAZO					,FECHA_APERTURA			
		,FECHA_VENCIM          	,PERIOD_PAGO_CAP			,PERIOD_PAG_INT     	,DIAS_TRASP_CAP			
		,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR			,COD_TASA_BASE       	,FACTOR_SOBRETASA		
		,SOBRETASA             	,TASA_INTERES				,COD_TASA_MORA        	,SOBRETASA_MORA			
		,FACT_SOBRET_MORA      	,TASA_MORATORIOS			,FECHA_PAGO_CAP         ,FECHA_PAGO_INT			
		,ES_FISICA              ,BANDERA_FI_FO				,ACTIVIDAD				,TIPO_CALCULO			
		,NUM_APER_ANT           ,REV_TASA_VAR_PER			,DIA_PARA_REVISAR       ,COD_PROD				
		,BANDERA_MINISTRA		,CREDITO_EXTERNO        	,PAGOS_SOSTENIDOS		,CAMPO_TRAB1            
		,CAMPO_TRAB2			,CAMPO_TRAB3            	,CAMPO_TRAB4			,valor_preferencial --PRUEBAS 16082018)
		,cuenta_clabe)*/
	SELECT {+INDEX ("informix".sd_definicioncrd)}
		SOL.EMPRESA					,P_SOLICITUD			,SOL.NUM_PRODUCTO			,ANX.EJECUTIVO_SOL
		,SOL.NUMCTE                 ,DEF.DIVISA				,SOL.SUCURSAL               ,''
		,''                         ,''						,''							,'VP'                       
		,'S'                   --** Credito Vencido Y Renovado Para Pago Sostenido
		,'N'                        ,DEF.PERIODO_PLAZO		,P_PLAZO                    ,vFechaApertura
		,vFechaVenc               	,"3"					,"2"                        ,CTR.DIAS_TRAS_CAP
		,CTR.DIAS_TRAS_INT          ,DEF.TASA_FIJA_O_VAR	,DEF.COD_TASA_BASE          ,DEF.FACTOR_SOBRETASA
		,DEF.SOBRETASA              ,vTasaInteres			,DEF.COD_TASA_MORA          ,DEF.SOBRETASA_MORA
		,DEF.FACT_SOBRET_MORA       ,vTasaMora				,''                         ,''
		,TIP.ES_FISICA              ,''						,''							,DEF.TIPO_CALCULO
		,''                         ,SOL.REV_TASA_VAR_PER	,P_PERIODOGRACIA	        ,''
		,'M'						,vNumCredito            ,0							,0                          
		,0							,''                     ,''							,P_MTOENGANCHE --PRUEBAS 16082018
		,cta_Clabe
	INTO
		mEmpresa					,P_SOLICITUD			,mNumProducto				,mEjecutivoSol
		,mNumCte					,mDivisa				,mSucursal					,mIdOrigen
		,mOrigen					,mCodTipoLinea			,mCodLinea					,mStatusCred
		,mBanderaRenovac
		,mBanderaProrroga			,mPeriodoPlazo			,P_PLAZO					,vFechaApertura
		,vFechaVenc					,mPeriodoPagoCap		,mPeriodoPagoInt			,mDiasTraspCap
		,mDiasTraspInt				,mTasaFijaOVar			,mCodTasaBase				,mFactorSobreTasa
		,mSobretasa					,vTasaInteres			,mCodTasaMora				,mSobretasaMora
		,mFactSobretMora			,vTasaMora				,mFechaPagoCap				,mFechaPagoInt
		,mEsFisica					,mBanderaFiFo			,mActividad					,mTipoCalculo
		,mNumAperAnt				,mRevTasaVarPer			,P_PERIODOGRACIA			,mCodProd
		,mBanderaMinistra			,vNumCredito			,mPagosSostenidos			,mCampoTrab1
		,mCampoTrab2				,mCampoTrab3			,mCampoTrab4				,P_MTOENGANCHE
		,cta_Clabe	
	FROM   bdisolic:"informix".ss_SOLICITUDES SOL
		, bdisolic:"informix".ss_ANEXOSOL    ANX
		, bdinteg:"informix".si_CLIENTE      CLI
		, bdinteg:"informix".si_TIPPER       TIP
		, "informix".SD_CODTRASP             CTR
		, "informix".SD_DEFINICIONCRD           DEF
	WHERE  DEF.EMPRESA         = SOL.EMPRESA
	AND    DEF.NUM_PRODUCTO    = SOL.NUM_PRODUCTO
	AND    CTR.PERIOD_PAG_INT  = "3"
	AND    CTR.PERIOD_PAGO_CAP = "2"
	AND    CTR.NUM_PRODUCTO    = DEF.NUM_PRODUCTO
	AND    CTR.EMPRESA         = DEF.EMPRESA
	AND    TIP.TPO_PERSONA     = CLI.TPO_PERSONA
	AND    CLI.NUMCTE          = SOL.NUMCTE
	AND    CLI.EMPRESA         = SOL.EMPRESA
	AND    ANX.NUM_SOLICITUD   = SOL.NUM_SOLICITUD
	AND    ANX.EMPRESA         = SOL.EMPRESA
	AND    SOL.NUM_SOLICITUD   = P_SOLICITUD
	AND    SOL.EMPRESA         = P_EMPRESA;
	
	INSERT INTO bdicred:"informix".sd_maecredcrd
			(EMPRESA				,NUM_CREDITO				,NUM_PRODUCTO				,EJECUTIVO				,NUMCTE				,DIVISA				,SUCURSAL
			,ID_ORIGEN				,ORIGEN                 	,COD_TIPO_LINEA				,COD_LINEA				,STATUS_CRED       	,BANDERA_RENOVAC	,BANDERA_PRORROGA
			,PERIODO_PLAZO			,PLAZO						,FECHA_APERTURA				,FECHA_VENCIM          	,PERIOD_PAGO_CAP	,PERIOD_PAG_INT    	,DIAS_TRASP_CAP			
			,DIAS_TRASP_INT         ,TASA_FIJA_O_VAR			,COD_TASA_BASE       		,FACTOR_SOBRETASA		,SOBRETASA         	,TASA_INTERES		,COD_TASA_MORA
			,SOBRETASA_MORA			,FACT_SOBRET_MORA      		,TASA_MORATORIOS			,FECHA_PAGO_CAP         ,FECHA_PAGO_INT		,ES_FISICA          ,BANDERA_FI_FO
			,ACTIVIDAD				,TIPO_CALCULO				,NUM_APER_ANT           	,REV_TASA_VAR_PER		,DIA_PARA_REVISAR   ,COD_PROD			,BANDERA_MINISTRA
			,CREDITO_EXTERNO        ,PAGOS_SOSTENIDOS			,CAMPO_TRAB1				,CAMPO_TRAB2			,CAMPO_TRAB3       	,CAMPO_TRAB4		,valor_preferencial --PRUEBAS 16082018)
			,cuenta_clabe)
	VALUES	(mEmpresa				,P_SOLICITUD				,mNumProducto				,mEjecutivoSol			,mNumCte			,mDivisa			,mSucursal
			,mIdOrigen				,mOrigen					,mCodTipoLinea				,mCodLinea				,mStatusCred		,mBanderaRenovac	,mBanderaProrroga			
			,mPeriodoPlazo			,P_PLAZO					,vFechaApertura				,vFechaVenc				,mPeriodoPagoCap	,mPeriodoPagoInt	,mDiasTraspCap
			,mDiasTraspInt			,mTasaFijaOVar				,mCodTasaBase				,mFactorSobreTasa		,mSobretasa			,vTasaInteres		,mCodTasaMora
			,mSobretasaMora			,mFactSobretMora			,vTasaMora					,mFechaPagoCap			,mFechaPagoInt		,mEsFisica			,mBanderaFiFo
			,mActividad				,mTipoCalculo				,mNumAperAnt				,mRevTasaVarPer			,P_PERIODOGRACIA	,mCodProd			,mBanderaMinistra
			,vNumCredito			,mPagosSostenidos			,mCampoTrab1				,mCampoTrab2			,mCampoTrab3		,mCampoTrab4		,P_MTOENGANCHE
			,cta_Clabe);

	--**ACTUALIZA  LA TARJETA CON EL NO. DE CREDITO REESTRUCTURADO

	UPDATE bdicred:"informix".sd_maecredcrd
	SET credito_externo = P_SOLICITUD
	WHERE empresa     = P_EMPRESA
	AND num_credito = vNumCredito;

	--***** ACTUALIZA SD_MAECREDANEXO (DATOS PARA TARJETA DE CREDITO)
	-- CALL bdicred:"informix".monthadd(mdy(month(vFechaApertura),'01',year(vFechaApertura)),1) RETURNING vproxfechapagaux;
	-- CALL bdicred:"informix".sp_valfechabil(mdy(month(vproxfechapagaux),vDiaCorte,year(vproxfechapagaux)),'+') RETURNING vCodRet, vproxfechapag;
	
/*  -- Comentado para quitar insert - select
	INSERT INTO bdicred:"informix".sd_maecredanexocrd
			(empresa				,num_credito				,dia_corte				,dias_gracia_mora			,tp_dias_calc_mora
			,dias_fecha_max_pago	,tp_dias_fecha_pago			,cod_tasa_base_cte		,factor_sobretasa_cte		,sobretasa_cte
			,tasa_interes_cte		,prox_fecha_pago			,fecha_proceso)*/
	SELECT {+INDEX ("informix".sd_definicioncrd)}
			P_EMPRESA				,P_SOLICITUD				,vDiaCorte				,def.campo_3				,def.pago_adic_sig_cuota
			,def.tpo_persona		,def.maneja_linea			,def.cod_tasa_base		,def.factor_sobretasa		,def.sobretasa
			,vTasaFavor				,vproxfechapag				,vFechaApertura
	INTO	
			P_EMPRESA				,P_SOLICITUD				,vDiaCorte				,mxCampo3					,mxPagoAdicSigCuota
			,mxTpoPersona			,mxManejaLinea				,mxCodTasaBase			,mxFactorSobreTasa			,mxSobretasa
			,vTasaFavor				,vproxfechapag				,vFechaApertura
	FROM bdicred:"informix".sd_definicioncrd def,
		bdisolic:"informix".ss_solicitudes c
	WHERE c.empresa = P_EMPRESA
	AND c.num_solicitud = P_SOLICITUD
	AND def.empresa = c.empresa
	AND def.num_producto = c.num_producto;
	
	INSERT INTO bdicred:"informix".sd_maecredanexocrd
			(empresa				,num_credito				,dia_corte				,dias_gracia_mora				,tp_dias_calc_mora				,dias_fecha_max_pago,
			tp_dias_fecha_pago		,cod_tasa_base_cte			,factor_sobretasa_cte	,sobretasa_cte					,tasa_interes_cte				,prox_fecha_pago,
			fecha_proceso)
	VALUES	(P_EMPRESA				,P_SOLICITUD				,vDiaCorte				,mxCampo3						,mxPagoAdicSigCuota				,mxTpoPersona
			,mxManejaLinea			,mxCodTasaBase				,mxFactorSobreTasa		,mxSobretasa					,vTasaFavor						,vproxfechapag
			,vFechaApertura);
	
	--Actualiza Periodo de Gracia
	--UPDATE  bdicred:"informix".sd_maecredanexocrd SET periodo_gracia=P_PERIODOGRACIA
	--WHERE num_credito = P_SOLICITUD;

      --***** ACTUALIZA SD_MAESDOS
/*  INSERT INTO bdicred:"informix".sd_maesdoscrd 
			(EMPRESA							,NUM_CREDITO						,FECHA_ULT_MOV				,SDO_INT_ANTICIP
			,SDO_INT_ANT_DEV        			,SDO_INTERESES              		,SDO_DIA_ANT_INT	        ,SDO_MES_ANT_INT
			,SDO_ACUM_MES_INT       			,SDO_RETENIDO               		,SDO_ACUM_CAP_INT			,SDO_EXIG_INT
			,SDO_NO_EXIG            			,PROVISION_NORMAL           		,DIAS_ACUM_INT		        ,SDO_MORATORIO
			,SDO_DIA_ANT_MOR        			,SDO_MES_ANT_MOR            		,SDO_CONTAB_MORA	        ,DIAS_ACUM_MORA
			,SDO_CAPITAL            			,SDO_CAP_INSOLUTO           		,SDO_DIA_ANT_CAP	        ,SDO_MES_ANT_CAP
			,SDO_ACUM_MES_CAP       			,MTO_CAPITALIZADO           		,MTO_MINISTRA_CAP		    ,CARGOS_DIA_CAP
			,ABONOS_DIA_CAP         			,CARGOS_MES_CAP             		,ABONOS_MES_CAP    		    ,DIAS_ACUM_CAP
			,MONTO_VENCIDO          			,MTO_VENC_TRASP             		,MONTO_FINANCIADO		    ,MONTO_RESERVADO
			,SDO_ACUM_VENCIDO       			,DIAS_ACUM_INTPER           		,SDO_GLOBAL_INT		        ,SDO_ACUM_INTPER
			,MONTO_OTORGADO         			,PROVI_VENC_NORMAL          		,PROVI_VENC_ANTICIP		    ,CAP_TRAS_NO_VENCI
			,MTO_VENC_INT           			,MTO_VENC_TRA_INT           		,MTO_FINAN_VDO		        ,MTO_RESER_INT
			,MTO_FIN_VEN_TRASP      			,MTO_FIN_VIG_TRASP          		,INT_TRA_NO_EXIG 		    ,SDO_TRAB4)*/
	SELECT SOL.EMPRESA            				,P_SOLICITUD                		,vFechaApertura		        ,0
			,0                      			,0                          		,0  	                    ,0
			,0                      			,0                          		,0   		                ,0
			,0                      			,0                          		,0    		                ,0
			,0                      			,0                          		,0  	                    ,0
			,0                      			,SOL.MONTO_SOLICITADO-P_MTOENGANCHE ,0 		                    ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
			,0                      			,0		                            ,0		                    ,0
			,0                      			,0		                            ,0    		                ,0
			,0                      			,0	                                ,vPagCuota 		            ,0
			,0                      			,0	                                ,0                      	,0
			,SOL.MONTO_SOLICITADO-P_MTOENGANCHE ,0									,0		                    ,SOL.MONTO_SOLICITADO-P_MTOENGANCHE
			,0                      			,0									,0        		            ,0
			,0                      			,0									,0        		            ,vPagCuota
	INTO
			msEmpresa							,P_SOLICITUD						,vFechaApertura				,msSdoIntAnticip
			,msSdoIntAntDev						,msSdoIntereses						,msSdoDiaAntInt				,msSdoMesAntInt
			,msSdoAcumMesInt					,msSdoRetenido						,msSdoAcumCapInt			,msSdoExigInt
			,msSdoNoExig						,msProvisionNormal					,msDiasAcumInt				,msSdoMoratorio
			,msSdoDiaAntMor						,msSdoMesAntMor						,msSdoContabMora			,msDiasAcumMora
			,msSdoCapital						,msSdoCapInsoluto					,msSdoDiaAntCap				,msSdoMesAntCap
			,msSdoAcumMesCap					,msMtoCapitalizado					,msMtoMinistraCap			,msCargosDiaCap
			,msAbonosDiaCap						,msCargosMesCap						,msAbonosMesCap				,msDiasAcumCap
			,msMontoVencido						,msMtoVencTrasp						,vPagCuota					,msMontoReservado
			,msSdoAcumVencido					,msDiasAcumIntper					,msSdoGlobalInt				,msSdoAcumIntper
			,msMontoOtorgado					,msProviVencNormal					,msProviVencAnticip			,msCapTrasNoVenci
			,msMtoVencInt						,msMtoVencTraInt					,msMtoFinanVdo				,msMtoReserInt
			,msMtoFinVenTrasp					,msMtoFinVigTrasp					,msIntTraNoExig				,vPagCuota
	  FROM   bdisolic:"informix".ss_SOLICITUDES SOL
	  WHERE  SOL.NUM_SOLICITUD = P_SOLICITUD
	  AND    SOL.EMPRESA   = P_EMPRESA;
	  
	  
	 IF  val_ifrs = 'A' THEN	   
	    LET msSdoCapital = msCapTrasNoVenci;
		LET msCapTrasNoVenci = 0;

	 END IF;
		
				  
	INSERT INTO bdicred:"informix".sd_maesdoscrd 
			(EMPRESA				,NUM_CREDITO				,FECHA_ULT_MOV				,SDO_INT_ANTICIP				,SDO_INT_ANT_DEV				,SDO_INTERESES
			,SDO_DIA_ANT_INT	    ,SDO_MES_ANT_INT			,SDO_ACUM_MES_INT  			,SDO_RETENIDO	          		,SDO_ACUM_CAP_INT				,SDO_EXIG_INT
			,SDO_NO_EXIG       		,PROVISION_NORMAL      		,DIAS_ACUM_INT		        ,SDO_MORATORIO					,SDO_DIA_ANT_MOR       			,SDO_MES_ANT_MOR            		,SDO_CONTAB_MORA	        ,DIAS_ACUM_MORA
			,SDO_CAPITAL      		,SDO_CAP_INSOLUTO      		,SDO_DIA_ANT_CAP	        ,SDO_MES_ANT_CAP				,SDO_ACUM_MES_CAP      			,MTO_CAPITALIZADO
			,MTO_MINISTRA_CAP	    ,CARGOS_DIA_CAP				,ABONOS_DIA_CAP    			,CARGOS_MES_CAP           		,ABONOS_MES_CAP	    		    ,DIAS_ACUM_CAP
			,MONTO_VENCIDO 			,MTO_VENC_TRASP        		,MONTO_FINANCIADO		    ,MONTO_RESERVADO				,SDO_ACUM_VENCIDO      			,DIAS_ACUM_INTPER           		,SDO_GLOBAL_INT		        ,SDO_ACUM_INTPER
			,MONTO_OTORGADO			,PROVI_VENC_NORMAL     		,PROVI_VENC_ANTICIP		    ,CAP_TRAS_NO_VENCI				,MTO_VENC_INT          			,MTO_VENC_TRA_INT           		,MTO_FINAN_VDO		        ,MTO_RESER_INT
			,MTO_FIN_VEN_TRASP		,MTO_FIN_VIG_TRASP     		,INT_TRA_NO_EXIG 		    ,SDO_TRAB4						,ATR)
	VALUES	(msEmpresa				,P_SOLICITUD				,vFechaApertura				,msSdoIntAnticip				,msSdoIntAntDev					,msSdoIntereses						
	        ,msSdoDiaAntInt			,msSdoMesAntInt				,msSdoAcumMesInt		    ,msSdoRetenido				    ,msSdoAcumCapInt			    ,msSdoExigInt
			,msSdoNoExig			,msProvisionNormal			,msDiasAcumInt				,msSdoMoratorio					,msSdoDiaAntMor					,msSdoMesAntMor						,msSdoContabMora			,msDiasAcumMora
			,msSdoCapital			,msSdoCapInsoluto			,msSdoDiaAntCap				,msSdoMesAntCap					,msSdoAcumMesCap				,msMtoCapitalizado	
			,msMtoMinistraCap		,msCargosDiaCap				,msAbonosDiaCap				,msCargosMesCap					,msAbonosMesCap					,msDiasAcumCap
			,msMontoVencido			,msMtoVencTrasp				,vPagCuota					,msMontoReservado				,msSdoAcumVencido				,msDiasAcumIntper					,msSdoGlobalInt				,msSdoAcumIntper
			,msMontoOtorgado		,msProviVencNormal			,msProviVencAnticip			,msCapTrasNoVenci				,msMtoVencInt					,msMtoVencTraInt					,msMtoFinanVdo				,msMtoReserInt
			,msMtoFinVenTrasp		,msMtoFinVigTrasp			,msIntTraNoExig				,vPagCuota						, 0);

	--  FMV 23abr13: Inserta cascaron para indicadores de prestamo a plazo
	INSERT INTO bdicred:"informix".sd_indicador_cred_crd
			(empresa, num_credito, fecha_alta)
	VALUES (P_EMPRESA, P_SOLICITUD, vFechaApertura);

    -- *********************************************************
                  -- INSERTA LA  TABLA DE AMORTIZACIONES *
    -- *********************************************************
	
	FOREACH
		SELECT fecha_cuota,capital_cuota,sum(capital_cuota + interes_cuota + iva_cuota)
		INTO vFechaT, vCapDebe,vPagCuota
		FROM bdicred:"informix".sd_proyecta
		WHERE empresa = P_EMPRESA
		AND num_solicitud = P_SOLICITUD
		GROUP BY 1,2
		ORDER BY fecha_cuota  -- BGM 21-Mayo-10 se ordena por fecha cuota
		INSERT INTO sd_amortiza_creditocrd values   
				(P_EMPRESA,P_SOLICITUD,vFechaT,"3",vPagCuota,vCapDebe,0,"4","0","",  -- BGM 21-May-2010 se considera 4 estatus de capital
				0,0,"3","0","", 0,0,"1","0","", 0,0,0,0,0,0,0,"1", 0,0,"1","",   -- BGM 21-May-2010 se considera variable para numero de cuota en el campo num_pago
				vCuenta,0,0,"","");
			   
		LET vCuenta=vCuenta+1;  -- BGM 21-May-2010 se incrementa variable para numero de cuota en el campo num_pago

	END FOREACH;

	UPDATE bdicred:"informix".sd_amortiza_creditocrd set capital_status = '3'   -- BGM 21-May-2010 se actualiza capital status de primer cuota a 3
	WHERE num_credito = P_SOLICITUD AND num_pago = 1;

    -- **************************************
    -- Actualiza el Estatus de la Solicitud *
    -- Complemento De Datos                 *
    -- **************************************

    SELECT periodo_plazo    , plazo          , divisa          ,tipo_calculo,
			cod_tasa_base    , sobretasa      , factor_sobretasa,
			tasa_interes     , tasa_fija_o_var, cod_tasa_mora   ,
			fact_sobret_mora , sobretasa_mora , tasa_moratorios ,
			period_pago_cap  , period_pag_int , fecha_apertura  ,
			fecha_vencim
    INTO vPerPlazo          , vPlazo         , vDivisa         , vTipoCalculo,
			vCodTasInt         , vSobretasa     , vFacSobreTasa   ,
			vTasaInteres       , vTasaFijVar    , vCodTasaMora    ,
			vFacSobretMora     , vSobretMora    , vTasaMora       ,
			vPerPagCap         , vPerPagInt     , vFecApert       ,
			vFecVenc
	FROM bdicred:"informix".sd_maecredcrd
	WHERE empresa = P_EMPRESA
	AND num_credito = P_SOLICITUD;

    UPDATE bdisolic:"informix".ss_solicitudes
                SET status_solicitud = "AP",
                    tipo_prestamo    = "C",
                    periodo_plazo    = vPerPlazo,
                    plazo            = vPlazo,
                    divisa           = vDivisa,
                    tipo_calculo     = vTipoCalculo,
                    cod_tasa_base    = vCodTasInt,
                    sobretasa        = vSobretasa,
                    factor_sobretasa = vFacSobreTasa,
                    tasa_interes     = vTasaInteres,
                    tasa_fija_o_var  = vTasaFijVar ,
                    cod_tasa_mora    = vCodTasaMora,
                    factor_moratorio = vFacSobretMora,
                    sobretasa_mora   = vSobretMora,
                    tasa_moratorios  = vTasaMora ,
                    periodo_pag_cap  = vPerPagCap,
                    periodo_pag_int  = vPerPagInt,
                    fecha_apert_prop = vFecApert,
                    fecha_venc_prop  = vFecVenc,
                    co_numcte        = P_NUMCTA
	WHERE empresa = P_EMPRESA
	AND num_solicitud = P_SOLICITUD;

	SELECT nombre INTO vMensaje
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = P_EJECUTIVO
	AND empresa = P_EMPRESA;

    LET vMensaje = "Apertura de Credito Autorizada por: " || TRIM(vMensaje);

    INSERT INTO bdisolic:"informix".ss_autorizacion
        (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
         comentario, fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES(P_EMPRESA, P_EJECUTIVO, P_SOLICITUD, "AP", vMensaje,
	    vFechaApertura, vFechaApertura, USER, TODAY);


    -- Resta el Valor de la Tasa Moratoria con la de Intereses
    -- Solicitado por el Banco JLP 23May2008

    LET vTasaMora = vTasaMora - vTasaInteres;
    IF vTasaMora < 0 THEN --Si es Menor a Cero la vuelve Positivo
		LET vTasaMora = vTasaMora * -1;
    END IF

	SELECT {+INDEX ("informix".sd_definicioncrd)}
		a.num_producto, a.divisa, b.monto_solicitado, b.sucursal
	INTO vProducto, vDivisa, P_MTOSOL, vSucursal
	FROM bdisolic:"informix".ss_solicitudes b, 
		bdicred:"informix".sd_definicioncrd a
	WHERE b.empresa = P_EMPRESA
	AND b.num_solicitud = P_SOLICITUD
	AND a.empresa = b.empresa
	AND a.num_producto = b.num_producto;


	--** EXTRAE EL MONTO DE LA REESTRUCTURA
	SELECT otro_copresta
	INTO   vMtoReestruc
	FROM   bdisolic:"informix".ss_anexosol
	WHERE  num_solicitud = P_SOLICITUD;

	 --**GENERA MOVIMIENTO DE APERTURA

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
		vProducto       , 2,
		"001"           , vFechaApertura,
		P_MTOSOL-P_MTOENGANCHE        , vFolio,
		vSucursal       ,vDivisa,
		"0000","APERTURA REESTRUCTURA PRESTAMO PERSONAL","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
											   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
											   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA PRESTAMO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;

	EXECUTE PROCEDURE "informix".GENMOVCRD( P_EMPRESA       , P_SOLICITUD,
					vProducto       , 1,
					"002"           , vFechaApertura,
					P_MTOSOL-P_MTOENGANCHE        , vFolio,
					vSucursal       ,vDivisa,
					"0000","APERTURA REESTRUCTURA PRESTAMO PERSONAL","")
	INTO vCodRet, P_MENSAJE;

	IF vCodRet <> '000000' THEN
		ROLLBACK WORK;
		IF (wBegin = "S") THEN
			BEGIN WORK;
		END IF;
		IF P_MTOENGANCHE>0 THEN
			EXECUTE PROCEDURE bdicheq:"informix".abono_ref(P_EMPRESA, vt_sucursal, p_ejecutivo,'0243', "0000", vFolio,
										   P_NUMCTA, 0,P_MTOENGANCHE, P_MTOENGANCHE,
										   0,0,0,vt_codigo_mn, P_SOLICITUD ||' '||'REESTRUCTURA PRESTAMO','', p_ejecutivo)
			INTO vCodRet;
		END IF;
		RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
	END IF;
	
	--SE realiza el marcaje del cliente RQI 27 100 JMAH
	EXECUTE PROCEDURE bdisitesp:"informix".sp_marcajesitesp('001',2,P_NUMCTE, p_ejecutivo)
	INTO vCodRet, P_MENSAJE;
	
	LET vCodRet  = '00000';
	COMMIT WORK;
	IF (wBegin = "S") THEN
		BEGIN WORK;
	END IF;
	RETURN vCodRet,vTasaInteres,vTasaMora,vCatIva,vMercadeo;
END PROCEDURE
DOCUMENT
'FOLIO: 438-RQM 10 1024-Actualizacion de las tablas de amortizacion para Prestamo Personal y Reestructura',
'MODIFICA: 95358897 - ISARAI BOJORQUEZ',
'MODIFICACION: SE MODIFICA PROCEDIMIENTO PARA AGREGAR EL MONTO DE ENGANCHE AL CAMPO valor_preferencial DE LA TABLA sd_maecredcrd Y CAMBIAR',
'VALOR DEL PARAMETRO P_MTOENGANCHE DECIMAL (18,2)',
'FECHA: 29/08/2018 ',
'BD:BDICRED',
'Folio: 686',
'RQM 09 546 Reestructura PrÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamo Personal',
'Autor: 97879606 AdriÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡n Eduardo LizÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡rraga CÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡zares',
'BD: bdicred',
'Fecha: 2020/10/06',
'DescripciÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³n: Se genera un clon del sp proyecta para poder reestructurar los prÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ©stamos personales agregandoles periodo de gracia.',
'SolicitÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ³: Ricardo Sanchez';

CREATE PROCEDURE "informix".sp_consulta_sdocrd(pempresa CHAR(3), pcuenta  CHAR(20))
--EXECUTE PROCEDURE sp_consulta_sdocrd('001','630188012300');
-- FMV corrige nombre de campo
RETURNING 	CHAR(5),	   -- Codigo de Retorno
			DECIMAL(14,2), -- Capital
			DECIMAL(14,2), -- Interes Vigente
			DECIMAL(14,2), -- Interes Vencido
			DECIMAL(14,2), -- Iva Int. Vigente
			DECIMAL(14,2), -- Iva Int. Vencido
			DECIMAL(14,2), -- Mora Ord.
			DECIMAL(14,2), -- Iva Mora Ord.
			DECIMAL(14,2), -- Mora Copete
			DECIMAL(14,2), -- Iva Mora Copete
			CHAR(20)     ; --NumCte

   DEFINE vCodRet       CHAR(5);
   DEFINE sql_err       INTEGER;
   DEFINE vCapital      DECIMAL(14,2);
   DEFINE vIntVigente   DECIMAL(14,2);
   DEFINE vIntVencido   DECIMAL(14,2);
   DEFINE vIvaIntVig    DECIMAL(14,2);
   DEFINE vIvaIntVen    DECIMAL(14,2);
   DEFINE vMoraOrd      DECIMAL(14,2);
   DEFINE vIvaMoraOrd   DECIMAL(14,2);
   DEFINE vMoraCopete   DECIMAL(14,2);
   DEFINE vIvaMoraCope  DECIMAL(14,2);
   DEFINE vCuotasVenc   CHAR(4);
   DEFINE vCtaCuotas    INTEGER;
   DEFINE vNumCte       CHAR(20);
   DEFINE vSucursalCred CHAR(4);
   DEFINE vIvaSucursal  DECIMAL(5,3);
   DEFINE vIvaNominal   DECIMAL(14,2);
   DEFINE vdummy        CHAR(100);
   DEFINE vCartera	INTEGER;
   DEFINE vinteresvend  DECIMAL(14,2);
   DEFINE vivavend      DECIMAL(14,2);
   define vtasa         date;
   define vhoy          date;
   define vfecaper      date;
   define vfecuota      date;
   define vmensaje      char(80);
   define ccontar       integer;
   --- Inicializa Variables de Salida
    LET vCodRet        = "000";
    LET vCapital       = 0;
    LET vIntVigente    = 0;
    LET vIntVencido    = 0;
    LET vIvaIntVig     = 0;
    LET vIvaIntVen     = 0;
    LET vMoraOrd       = 0;
    LET vIvaMoraOrd    = 0;
    LET vMoraCopete    = 0;
    LET vIvaMoraCope   = 0;
    LET vCuotasVenc    = '';
    LET vCtaCuotas     = 0;
    LET vNumCTe        = '';
	LET vSucursalCred  = '';
	LET vIvaSucursal   = 0;
	LET vIvaNominal    = 0;
    let ccontar        = 0;

	
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
         LET vCodRet = sql_err;
           RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig, vIvaIntVen, vMoraOrd,
                  vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte;
      END IF;
   END EXCEPTION;

   --** No. De Cuotas Vencidas **--
--   SET DEBUG FILE TO "/tmp/sdo.out";
--   TRACE ON;

   SELECT valor
     INTO vCuotasVenc
     FROM sd_param
    WHERE empresa = pempresa
      AND cod_param ='111';

   IF vCuotasVenc Is Null THEN   -- FMV BGM 3-feb-10 se deja la validacion como estaba antes
      LET vCodRet  ='9';
           RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig, vIvaIntVen, vMoraOrd,
                  vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte;
   END IF;

  --** Verifica Si Existe El Credito **--
/*  LET pcuenta = pcuenta;
  LET ptarjeta = ptarjeta;
  IF pcuenta IS NOT NULL AND pcuenta <> ' '  THEN   --Busqueda Por Cliente
     LET vNumCte = pcuenta;

     FOREACH
          SELECT tar.num_credito,tar.num_tarjeta
            INTO pcuenta, vNumTarjeta
            FROM sd_tarjeta tar, sd_maecred mae
	   WHERE mae.empresa = tar.empresa
	     AND mae.num_credito = tar.num_credito
	     AND mae.numcte = vNumCte
             AND tipo_tarjeta  = 'T'
           ORDER BY status_tar

            EXIT FOREACH;
     END FOREACH

     IF vNumTarjeta IS NOT NULL AND vNumTarjeta <> "" THEN
           IF Exists (SELECT numcte
		                FROM sd_maecred
					   WHERE empresa = pempresa
					     AND num_credito = pcuenta
						 AND status_cred = 'FC') THEN
              LET vCodRet  ='7';
              RETURN vCodRet, vCapital   , vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
                     vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
	    END IF;
     END IF;
   ELSE
	 SELECT num_credito, numcte, num_tarjeta
	   INTO pcuenta, vNumCte, vNumTarjeta
	   FROM sd_tarjeta
	  WHERE empresa = pempresa
	    AND num_tarjeta = ptarjeta
	    AND tipo_tarjeta = "T";
--	    AND status_tar = "A";
     IF pcuenta IS NULL THEN
	    LET vCodRet ="008";
        RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig, vIvaIntVen, vMoraOrd,
               vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte, vNumTarjeta;
	 END IF
   END IF
*/
   --** Lectura De Cuotas Vencidas **--
   SELECT Count(*)
   INTO vCtaCuotas
   FROM sd_amortiza_creditocrd
   WHERE empresa = pempresa and num_credito = pcuenta and capital_status in ('2','7','6'); --IFSR se agrega el capital status 6

   --** Lectura De Existencia De Credito Reestructurado **--
   IF Exists (SELECT numcte FROM sd_maecredcrd WHERE empresa = pempresa AND num_credito  = pcuenta AND status_cred='FC' ) THEN
      LET vCodRet  ='7';
      RETURN vCodRet, vCapital   , vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
             vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte;
   ELSE
      IF vCtaCuotas < vCuotasVenc THEN
         LET vCodRet  ='10';
         RETURN vCodRet, vCapital   , vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
               vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte;
      END IF;
   END IF;

   -- BGM 28/ago/09 :Se valida que el credito este en cartera vendida
/*
   SELECT id_unidad_prod
   into vCartera
   FROM sd_maecred
   WHERE empresa = pempresa AND num_credito  = pcuenta;

   IF vCartera IS NOT NULL THEN
      LET vCodRet  ='15';
      RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
             vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte,vNumTarjeta;
   END IF;
*/
-- No se pueden reestructurar los clientes de prueba de grupo3 jom
/*    select count(*)
     into ccontar
     from bdisitesp:se_ctessitespcred 
    where empresa = pempresa
      and numcred  = pcuenta
      and situacion = 'P' 
      and causa = 61;*/
-- No se pueden reestructurar los clientes de prueba de grupo3 jom
/*
   IF ccontar > 0 THEN
      LET vCodRet  ='307';
      RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd   ,
             vIvaMoraOrd, vMoraCopete, vIvaMoraCope,vNumCte;--,vNumTarjeta;
   END IF;
*/
   -- BGM Termina validaciÃÂ³n cartera vendida

   --** Lectura De Saldos Para Reestructurar **--
   -- AVC Modifica la forma de obtener Capital
   --SELECT sdo_cap_insoluto, sdo_no_exig, (sdo_exig_int + int_tra_no_exig)
   --INTO vCapital, vIntVigente, vIntVencido
   --FROM sd_maesdos
   --WHERE empresa     = pempresa
   --  AND num_credito = pcuenta;

   -- AVC Obtiene la Sucursal del Credito
   SELECT sucursal
     INTO vSucursalCred
     FROM bdicred:sd_maecredcrd
	WHERE empresa = pempresa
	  AND num_credito = pcuenta;

   --** Lectura De Saldos Para Reestructurar **--
   -- AVC Modifica la forma de obtener Capital
   SELECT sdo_cap_insoluto
   INTO vCapital
   FROM sd_maesdoscrd
   WHERE empresa     = pempresa
     AND num_credito = pcuenta;

	-- AVC Modifica la forma de obtener el interes Vigente
	-- considerando como fecha de nuevo calculo (estatus capital) Dic/2008
	SELECT NVL(sum(interes_debe),0), NVL(sum(iva_debe - iva_pagado),0)
	INTO vIntVigente, vIvaIntVig
	FROM bdicred:sd_amortiza_creditocrd
    WHERE empresa     = pempresa
      AND num_credito = pcuenta
	  AND capital_status = '1';
	-- AVC FIN Modifica la forma de obtener el interes Vigente

	-- AVC Modifica la forma de obtener el interes Vencido
	-- considerando como fecha de nuevo calculo (estatus capital) Dic/2008
	SELECT NVL(sum(interes_debe - interes_pagado),0), NVL(sum(iva_debe - iva_pagado),0)
	INTO vIntVencido, vIvaIntVen
	FROM bdicred:sd_amortiza_creditocrd
    WHERE empresa     = pempresa
      AND num_credito = pcuenta
	  AND capital_status IN ('2','6'); --IFSR se agrega el capital status 6
	-- AVC FIN Modifica la forma de obtener el interes Vencido

   -- AVC Obtencion de los Moratorios
   SELECT NVL(sum(mora_provi_ordi +  mora_sdo_ordi - mora_sdo_ordi_pag),0),
          NVL(sum( mora_provi_cope+  mora_sdo_cope - mora_sdo_cope_pag),0)
          --NVL(sum(mora_iva_debe - mora_iva_pagado),0)
	 --INTO vMoraOrd , vMoraCopete, vIvaMoraOrd
     INTO vMoraOrd , vMoraCopete
     FROM bdicred:sd_amortiza_creditocrd
    WHERE empresa = pempresa
      AND num_credito = pcuenta
	  AND capital_status in ('1','2','7','6'); --IFSR se agrega el capital status 6

   --AVC Obtencion del IVA de la Sucursal
   SELECT iva
     INTO vIvaSucursal
     FROM bdinteg:si_sucursales
	WHERE empresa = pempresa
	  AND sucursal = vSucursalCred;

   --AVC Calcula el IVA de Mora Ordinaria y Copete
   LET vIvaNominal = (vMoraOrd + vMoraCopete) * vIvaSucursal;
   LET vIvaMoraOrd = vMoraOrd * vIvaSucursal;
   LET vIvaMoraCope = vIvaNominal - vIvaMoraOrd;
   select sdo_intereses into vinteresvend  
   from sd_maesdoscrd
    WHERE empresa = pempresa
         AND num_credito = pcuenta;
   if vinteresvend is null then let vinteresvend = 0; end if;
   
   if vinteresvend > 0 then
    select tasa_interes,fecha_apertura
      into vtasa,vfecaper
      from sd_maecredcrd
      WHERE empresa     = pempresa
         AND num_credito = pcuenta;
      select fecha_hoy into vhoy
        from sd_fechas;
     SELECT max(fecha_cuota)
	INTO vfecuota
	FROM bdicred:sd_amortiza_creditocrd
    WHERE empresa     = pempresa
      AND num_credito = pcuenta
	  AND capital_status = '1';
      call calc_iva_grav_pp(pempresa,pcuenta,vtasa,vIvaSucursal,vhoy,null,vfecaper,vfecuota,vinteresvend)
       returning    vCodRet,vivavend,vmensaje;
      let vIntVigente = vIntVigente + vinteresvend;
      let vIvaIntVig = vIvaIntVig + vivavend;
   end if
   -- AVC Ya se calculo arriba
   --SELECT sum(iva_debe - iva_pagado)
   --  INTO vIvaIntVig
   --  FROM sd_amortiza_credito
   -- WHERE empresa     = pempresa
   --   AND num_credito = pcuenta
   --   AND iva_status = '1';

   -- AVC Eliminar pues ya se tiene el NVL arriba
   --IF vIvaIntVig Is Null THEN
   --   LET vIvaIntVig = 0;
   --END IF;

   -- AVC Ya se calculo arriba
   --SELECT sum(iva_debe - iva_pagado)
   --  INTO vIvaIntVen
   --  FROM sd_amortiza_credito
   -- WHERE empresa     = pempresa
   --   AND num_credito = pcuenta
   --   AND iva_status IN ('2','3','7');

   -- AVC Eliminar pues ya se tiene el NVL arriba
   --IF vIvaIntVen Is Null THEN
   --    LET vIvaIntVen = 0;
   --END IF;

   RETURN vCodRet, vCapital, vIntVigente, vIntVencido, vIvaIntVig , vIvaIntVen , vMoraOrd,
          vIvaMoraOrd, vMoraCopete, vIvaMoraCope, vNumCte;
END
END PROCEDURE
;