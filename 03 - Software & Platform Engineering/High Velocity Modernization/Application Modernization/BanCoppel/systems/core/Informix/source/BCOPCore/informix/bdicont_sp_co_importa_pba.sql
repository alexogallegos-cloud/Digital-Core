CREATE PROCEDURE "informix".sp_co_importa_pba(p_empresa CHAR(3),p_usuario CHAR(8),p_fecha_captura DATE)
        RETURNING CHAR(5), INTEGER, VARCHAR(255)

	--Variables Exception
   DEFINE cVarDataErr					VARCHAR(64);
   DEFINE iSqlErr						INTEGER;
   DEFINE iSamErr						INTEGER;
   DEFINE cod_ret						CHAR(5);
   DEFINE v_mensaje					    VARCHAR(255);

   DEFINE v_contador                    INTEGER;
   DEFINE v_cuenta_auxiliar             INTEGER;
   DEFINE v_cuenta_divisa               INTEGER;
   DEFINE v_empresa                     CHAR(3);
   DEFINE v_ccosto_orig                 CHAR(4);
   DEFINE v_usuario                     CHAR(8);
   DEFINE v_fecha_captura               DATE;
   DEFINE v_cuenta                      CHAR(4);
   DEFINE v_subcta                      CHAR(2);
   DEFINE v_subsubcta                   CHAR(2);
   DEFINE v_ssubsubcta                  CHAR(2);
   DEFINE v_sssubsubcta                 CHAR(2);
   DEFINE v_sector                      CHAR(2);
   DEFINE v_regional                    CHAR(3);
   DEFINE v_sucursal                    CHAR(4);
   DEFINE v_nro_auxiliar                CHAR(12);
   DEFINE v_fecha                       DATE;
   DEFINE v_moneda                      CHAR(2);
   DEFINE v_naturaleza                  CHAR(1);
   DEFINE v_importe                     MONEY(18,2);
   DEFINE v_concepto                    CHAR(80);

   DEFINE credito1                      MONEY(16,2);
   DEFINE debito1                       MONEY(16,2);
   DEFINE v_descripcion                 CHAR(80);
   DEFINE v_contaerror                  INTEGER;
   DEFINE i                             INTEGER;
   DEFINE j                             INTEGER;
   DEFINE wcuantos                      INTEGER;
   DEFINE wcuantos1                     INTEGER;
   DEFINE w_cap_cargo_mn                MONEY(16,2);
   DEFINE v_cap_cargo_dls               MONEY(16,2);
   DEFINE v_cap_abono_mn                MONEY(16,2);
   DEFINE v_cap_abono_dls               MONEY(16,2);
   DEFINE v_control_poliza              INTEGER;
   DEFINE v_ciudad                      CHAR(3);
   DEFINE v_cIFra_mn                    MONEY(16,2);
   DEFINE v_cIFra_dls                   MONEY(16,2);


   DEFINE w_SUMa_cargos                 MONEY(18,2);
   DEFINE w_SUMa_abonos                 MONEY(18,2);

   DEFINE v_cuenta_ccosto_orig      	INTEGER;
   DEFINE v_cuenta_ccosto_dest      	INTEGER;
   DEFINE v_ctarestrin_ori          	CHAR(1);
   DEFINE v_ctarestrin_des          	CHAR(1);

   DEFINE v_dias                    	INTEGER;
   DEFINE v_dias_valor              	INTEGER;
   DEFINE v_maneja_aux              	CHAR(1);
   DEFINE v_enl_cc_mayor            	CHAR(10);
   DEFINE v_enl_cc_sub              	CHAR(10);
   DEFINE v_enl_cc_ss               	CHAR(10);
   DEFINE v_enl_cc_sss              	CHAR(10);
   DEFINE v_enl_cc_ssss             	CHAR(10);
   DEFINE v_enl_cc_sector           	CHAR(10);
   DEFINE v_ctaord_ini              	CHAR(10);
   DEFINE v_ctaord_fin              	CHAR(10);
   DEFINE v_ctacor_ini              	CHAR(10);
   DEFINE v_ctacor_fin              	CHAR(10);
   DEFINE v_SUMa_orden              	MONEY(18,2);
   DEFINE v_SUMa_corre              	MONEY(18,2);

   DEFINE v_suc                     	CHAR(4);
   DEFINE v_cuentacom               	CHAR(14);
   DEFINE v_fecha_habil             	DATE;
   DEFINE v_fecha_hoy               	DATE;
   DEFINE v_usu			    			CHAR(8);	

   
	ON EXCEPTION
		SET iSqlErr, iSamErr, cVarDataErr
		IF iSqlErr <> 0 THEN
			LET cod_ret=iSqlErr;
			LET v_control_poliza = 0;
				RETURN cod_ret, v_control_poliza, iSamErr || ' ' ||cVarDataErr;
			END IF
	END EXCEPTION;

	--set debug file to '/tmp/sp_co_importa.out';
	--trace on;

   SET LOCK MODE TO WAIT 3;

   LET v_contador = 0;

   LET v_empresa    = '';
   LET v_ccosto_orig ='';
   LET v_usuario = '';

   LET v_fecha_captura = today;
   LET v_fecha = today;
   LET v_fecha_habil = today;
   LET v_fecha_hoy = today;

   LET v_cuenta      = '';
   LET v_subcta      = '';
   LET v_subsubcta   = '';
   LET v_ssubsubcta  = '';
   LET v_sssubsubcta = '';
   LET v_sector      = '';
   LET v_regional    = '';
   LET v_sucursal    = '';
   LET v_nro_auxiliar  = '';
   LET v_moneda      = '';
   LET v_naturaleza  = '';
   LET v_importe = ' ';
   LET v_concepto = ' ';
   LET credito1    = 0;
   LET debito1     = 0;
   LET w_cap_cargo_mn  = 0;
   LET v_cap_cargo_dls = 0;
   LET v_cap_abono_mn  = 0;
   LET v_cap_abono_dls = 0;
   LET v_control_poliza = 0;
   LET v_ciudad    = ' ';
   LET v_cIFra_mn  = 0;
   LET v_cIFra_dls = 0;
   LET v_ctarestrin_ori = '';
   LET v_ctarestrin_des = '';
   LET v_dias             =0;
   LET v_dias_valor  =0;
   LET v_enl_cc_mayor      ='';
   LET v_enl_cc_sub          ='';
   LET v_enl_cc_ss            ='';
   LET v_enl_cc_sss          ='';
   LET v_enl_cc_ssss        ='';
   LET v_enl_cc_sector      ='';
   LET v_ctaord_ini              ='';
   LET v_ctaord_fin              ='';
   LET v_ctacor_ini              ='';
   LET v_ctacor_fin              ='';
   LET v_SUMa_orden = 0;
   LET v_SUMa_corre = 0;
   LET v_suc    = ' ';
   LET v_cuentacom = '';
   LET v_dias_valor = 0;
   LET v_usu = '';
   LET v_mensaje = "IMPORTACIÓN SATISFACTORIA";

   SELECT
      fecha_hoy 
   INTO
      v_fecha_hoy 
   FROM
      bdicont:co_fechas
   WHERE
      bdicont:co_fechas.empresa = p_empresa;

   LET cod_ret = '000'; --Exito

----inicia nuevo proceso
     SELECT TRIM(enl_cc_mayor),
            TRIM(enl_cc_sub),
            TRIM(enl_cc_ss),
            TRIM(enl_cc_sss),
            TRIM(enl_cc_ssss),
            TRIM(enl_cc_sector),
            TRIM(cta_ord_inic),
            TRIM(cta_ord_final),
            TRIM(cta_correl_inic),
            TRIM(cta_correl_final)
     INTO v_enl_cc_mayor,
          v_enl_cc_sub,
          v_enl_cc_ss,
          v_enl_cc_sss,
          v_enl_cc_ssss,
          v_enl_cc_sector,
          v_ctaord_ini,
          v_ctaord_fin,
          v_ctacor_ini,
          v_ctacor_fin
     FROM bdicont:"informix".co_param
     WHERE empresa = p_empresa;

   LET i  = 0;
   LET j  = 0;
   LET v_contaerror = 0;

 --  Eliminar Bitacora de  Errores.
	DELETE 
	  FROM bdicont:co_auditerr 
	WHERE fecha_captura = p_fecha_captura AND usuario = p_usuario;

  -- NO hay información por Procesar
  SELECT COUNT(*) 
	  INTO v_contador 
	  FROM bdicont:"informix".co_integracion
     WHERE usuario_int = p_usuario;

	IF v_contador IS NULL OR  v_contador=0 THEN
		LET cod_ret = '174';

        INSERT INTO bdicont:"informix".co_auditerr
             VALUES(p_usuario, v_control_poliza, p_fecha_captura, 1,
                    p_empresa, '0000','00', '00', '00', '00', '00', '00', cod_ret);

	END IF 

 --- Valida que el importe no sea 0
    SELECT COUNT(*) 
	  INTO v_contador 
	  FROM bdicont:"informix".co_integracion
     WHERE usuario_int = p_usuario
       AND importe = 0;

    IF v_contador > 0 THEN
		LET cod_ret = '175';

        INSERT INTO bdicont:"informix".co_auditerr
             VALUES(p_usuario, v_control_poliza, p_fecha_captura, 1,
                    p_empresa, '0000','00', '00', '00', '00', '00', '00', cod_ret);
    END IF      

 --- Determinar si la poliza esta cuadrada
	SELECT SUM(importe) 
	  INTO w_SUMa_abonos 
	  FROM bdicont:"informix".co_integracion
     WHERE usuario_int=p_usuario
	   AND naturaleza = 'D';
  
    IF w_SUMa_abonos IS NULL THEN
		LET w_SUMa_abonos = 0;
	END IF

	SELECT SUM(importe) 
	  INTO w_SUMa_cargos 
	  FROM bdicont:"informix".co_integracion
     WHERE usuario_int=p_usuario
       AND naturaleza = 'C' ;
  
	IF w_SUMa_cargos IS NULL THEN
       LET w_SUMa_cargos = 0;
    END IF

  ----Poliza descuadrada
	IF w_SUMa_abonos != w_SUMa_cargos THEN
		LET cod_ret = '106';

        INSERT INTO bdicont:"informix".co_auditerr
        VALUES(p_usuario, v_control_poliza ,p_fecha_captura , 1,
               p_empresa, '0000', '00', '00', '00', '00', '00', w_SUMa_cargos,cod_ret);
	END IF

  --- Valida el Usuario de Integración
	SELECT COUNT(*) 
	  INTO v_contador
      FROM bdinteg:"informix".si_ejecut
	 WHERE ejecutivo = p_usuario
	   AND empresa = p_empresa;

	IF v_contador = 0 THEN
		SELECT COUNT(*) 
		  INTO v_contador
	      FROM bdinteg:"informix".si_usuarios
		 WHERE usuario = p_usuario;

	END IF

	IF v_contador = 0 THEN
		LET cod_ret = '177';

        INSERT INTO bdicont:"informix".co_auditerr
             VALUES(p_usuario, v_control_poliza, p_fecha_captura, 1,
                    p_empresa, '0000','00', '00', '00', '00', '00', '00', cod_ret);
	END IF

     -- Solo una Fecha Captura para toda la Póliza
	SELECT COUNT(DISTINCT fecha_captura) 
	  INTO v_contador
	  FROM bdicont:"informix".co_integracion
	 WHERE usuario_int = p_usuario;

	IF v_contador > 1 THEN
		LET cod_ret = '666';

        INSERT INTO bdicont:"informix".co_auditerr
             VALUES(p_usuario, v_control_poliza, p_fecha_captura, 1,
                    p_empresa, '0000','00', '00', '00', '00', '00', '00', cod_ret);
	END IF

	-- Solo una Fecha Valida para toda la Póliza
	SELECT COUNT(DISTINCT fecha) 
	  INTO v_contador
	  FROM bdicont:"informix".co_integracion
	 WHERE usuario_int = p_usuario;

	IF v_contador > 1 THEN
		LET cod_ret = '666';

        INSERT INTO bdicont:"informix".co_auditerr
             VALUES(p_usuario, v_control_poliza, p_fecha_captura, 1,
                    p_empresa, '0000','00', '00', '00', '00', '00', '00', cod_ret);
	END IF

	IF cod_ret <> '666' THEN

		SELECT 	fecha_captura,fecha
		  INTO v_fecha_captura,v_fecha
		  FROM bdicont:"informix".co_integracion
		 WHERE usuario_int = p_usuario
	  GROUP BY fecha_captura,fecha;

		IF EXISTS (SELECT * FROM bdinteg:si_feriado WHERE fecha in (v_fecha_captura,v_fecha) AND empresa = p_empresa AND laborable = 'N' ) THEN 

			LET cod_ret = '666';

	        INSERT INTO bdicont:"informix".co_auditerr
	             VALUES(p_usuario, v_control_poliza, p_fecha_captura, 1,
	                    p_empresa, '0000','00', '00', '00', '00', '00', '00', cod_ret);

		END IF
	END IF

	IF cod_ret = '000' THEN
   
	   LET v_contaerror = 0;

	   FOREACH
	      SELECT *
	      INTO v_empresa,
	       v_ccosto_orig,
	       v_usuario,
	       v_fecha_captura,
	       v_cuenta,
	       v_subcta,
	       v_subsubcta,
	       v_ssubsubcta,
	       v_sssubsubcta,
	       v_sector,
	       v_regional,
	       v_sucursal,
	       v_nro_auxiliar,
	       v_fecha,
	       v_moneda,
	       v_naturaleza,
	       v_importe,
	       v_concepto,
	       v_usu
	    FROM
	       bdicont:"informix".co_integracion
	    WHERE usuario_int = p_usuario

	      --Extrae Valores Iniciales.
	       LET v_descripcion = 'Movimientos del Dia';

	       LET wcuantos = 0;
	       LET i = i + 1;

	        IF v_sucursal IS NULL or TRIM(v_sucursal) = '' THEN
	             LET cod_ret = '165';

	             INSERT INTO bdicont:"informix".co_auditerr
	               VALUES(p_usuario,
	               v_control_poliza,
	               v_fecha_captura,
	               i,
	               p_empresa,
	               v_cuenta,
	               v_subcta,
	               v_subsubcta,
	               v_ssubsubcta,
	               v_sssubsubcta,
	               v_sector,
	               v_importe,
	               cod_ret);
	        END IF

	        SELECT COUNT(*) 
			  INTO v_contador 
			 FROM bdinteg:si_sucursales
	         WHERE empresa=p_empresa
	          AND sucursal=v_sucursal;

	        IF v_contador =0 THEN

	             LET cod_ret = '165';

	             INSERT INTO bdicont:"informix".co_auditerr
	               VALUES(p_usuario,
	               v_control_poliza,
	               v_fecha_captura,
	               i,
	               p_empresa,
	               v_cuenta,
	               v_subcta,
	               v_subsubcta,
	               v_ssubsubcta,
	               v_sssubsubcta,
	               v_sector,
	               v_importe,
	               cod_ret);
	        END IF

	       --Valida Cuantos Registros Existen

	        SELECT COUNT(*) INTO wcuantos
	          FROM bdinteg:si_catalog
	         WHERE empresa = p_empresa
	           AND ccmayor = v_cuenta
	           AND ccsub = v_subcta
	           AND ccsubsub = v_subsubcta
	           AND ccssubsub = v_ssubsubcta
	           AND ccsssubsub = v_sssubsubcta
	           AND sector = v_sector;

	        IF wcuantos = 0 THEN
				LET cod_ret = '100';
	            INSERT INTO bdicont:"informix".co_auditerr
	            VALUES(p_usuario,
	                   v_control_poliza,
	                   v_fecha_captura,
	                   i,
	                   p_empresa,
	                   v_cuenta,
	                   v_subcta,
	                   v_subsubcta,
	                   v_ssubsubcta,
	                   v_sssubsubcta,
	                   v_sector,
	                   v_importe,
	                   cod_ret);
	        ELSE
	            LET v_ctaord_ini = v_ctaord_ini;
	            LET v_ctaord_fin = v_ctaord_fin;
	            LET v_cuenta = v_cuenta;
	            LET v_subcta = v_subcta;
	            LET v_subsubcta = v_subsubcta;
	            LET v_ssubsubcta = v_ssubsubcta;
	            LET v_sssubsubcta = v_sssubsubcta;
	            LET v_sector = v_sector;

	            IF v_cuenta = v_enl_cc_mayor AND v_subcta = v_enl_cc_sub AND
	               v_subsubcta = v_enl_cc_ss AND v_ssubsubcta = v_enl_cc_sss AND
	               v_sssubsubcta = v_enl_cc_ssss AND v_sector = v_enl_cc_sector THEN
	                    LET cod_ret = '169';
	                    INSERT INTO bdicont:"informix".co_auditerr
	                    VALUES(p_usuario,
							   v_control_poliza,
	                           v_fecha_captura,
	                           i,
	                           p_empresa,
	                           v_cuenta,
	                           v_subcta,
	                           v_subsubcta,
	                           v_ssubsubcta,
	                           v_sssubsubcta,
	                           v_sector,
	                           v_importe,
	                           cod_ret);
	                END IF
			END IF

	        IF wcuantos > 0 THEN
	              ----verIFica que sea cuenta de detalle
	         LET wcuantos1 = 0;

	         SELECT COUNT(*) INTO wcuantos1
	           FROM bdinteg:si_catalog
	          WHERE empresa = p_empresa
	            AND ccmayor = v_cuenta
	            AND ccsub = v_subcta
	            AND ccsubsub = v_subsubcta
	            AND ccssubsub = v_ssubsubcta
	            AND ccsssubsub = v_sssubsubcta
	            AND sector = v_sector
	            AND tipo_cuenta = 'D';

	            -----la cuenta no es de detalle
				IF wcuantos1 = 0 THEN

					LET cod_ret = '144';

					INSERT INTO bdicont:"informix".co_auditerr
	                VALUES(p_usuario,
	                       v_control_poliza,
						   v_fecha_captura,
	                       i,
						   p_empresa,
						   v_cuenta,
						   v_subcta,
						   v_subsubcta,
						   v_ssubsubcta,
						   v_sssubsubcta,
						   v_sector,
						   v_importe,
						   cod_ret);
	            END IF
	     
		        SELECT auxiliar 
				  INTO v_maneja_aux
		          FROM bdinteg:si_catalog
		         WHERE empresa = p_empresa
		           AND ccmayor = v_cuenta
		           AND ccsub = v_subcta
		           AND ccsubsub = v_subsubcta
		           AND ccssubsub = v_ssubsubcta
		           AND ccsssubsub = v_sssubsubcta
		           AND sector = v_sector;

				IF v_maneja_aux = 'S' THEN
	                IF v_nro_auxiliar <> '' THEN

	                    SELECT COUNT(numero) 
					      INTO v_cuenta_auxiliar 
					      FROM bdicont:"informix".co_auxiliar
	                     WHERE empresa = v_empresa
	                      AND numero = v_nro_auxiliar;

	                    IF v_cuenta_auxiliar = 0 THEN
	                      LET cod_ret = '102';

	                      INSERT INTO bdicont:"informix".co_auditerr
	                        VALUES(p_usuario,
	                        v_control_poliza,
	                        v_fecha_captura,
	                        i,
	                        p_empresa,
	                        v_cuenta,
	                        v_subcta,
	                        v_subsubcta,
	                        v_ssubsubcta,
	                        v_sssubsubcta,
	                        v_sector,
	                        v_importe,
	                        cod_ret);
	                    END IF
	                ELSE
	                      LET cod_ret = '102';

	                      INSERT INTO bdicont:"informix".co_auditerr
	                        VALUES(p_usuario,
	                        v_control_poliza,
	                        v_fecha_captura,
	                        i,
	                        p_empresa,
	                        v_cuenta,
	                        v_subcta,
	                        v_subsubcta,
	                        v_ssubsubcta,
	                        v_sssubsubcta,
	                        v_sector,
	                        v_importe,
	                        cod_ret);
	                END IF
				ELSE
					IF v_nro_auxiliar <> '' THEN
	                      LET cod_ret = '118';

	                      INSERT INTO bdicont:"informix".co_auditerr
	                        VALUES(p_usuario,
	                        v_control_poliza,
	                        v_fecha_captura,
	                        i,
	                        p_empresa,
	                        v_cuenta,
	                        v_subcta,
	                        v_subsubcta,
	                        v_ssubsubcta,
	                        v_sssubsubcta,
	                        v_sector,
	                        v_importe,
	                        cod_ret);
					END IF
				END IF ;

	         ----validar que la moneda  este permitida para la cuenta---
				SELECT moneda  
				  INTO v_cuenta_divisa FROM bdinteg:si_catalog
				 WHERE empresa       = p_empresa      
				   AND ccmayor       = v_cuenta       
				   AND ccsub         = v_subcta       
				   AND ccsubsub      = v_subsubcta    
				   AND ccssubsub     = v_ssubsubcta   
				   AND ccsssubsub    = v_sssubsubcta  
				   AND sector        = v_sector;

				IF v_cuenta_divisa = '' THEN
					LET v_contaerror = v_contaerror +1;
	                LET cod_ret = '145';

	                INSERT INTO bdicont:"informix".co_auditerr
	                VALUES(p_usuario,
	                       v_control_poliza,
						   v_fecha_captura,
	                       i,
	                       p_empresa,
	                       v_cuenta,
	                       v_subcta,
	                       v_subsubcta,
	                       v_ssubsubcta,
	                       v_sssubsubcta,
	                       v_sector,
	                       v_importe,
	                       cod_ret);
				ELSE
					IF (v_cuenta_divisa='2' AND v_moneda<>'02') OR (v_cuenta_divisa='1' AND v_moneda<>'01') THEN
						LET v_contaerror = v_contaerror +1;
						LET cod_ret = '145';

						INSERT INTO bdicont:"informix".co_auditerr
		                VALUES(p_usuario,
							   v_control_poliza,
		                       v_fecha_captura,
							   i,
							   p_empresa,
							   v_cuenta,
							   v_subcta,
							   v_subsubcta,
							   v_ssubsubcta,
							   v_sssubsubcta,
							   v_sector,
							   v_importe,
							   cod_ret);
					END IF
				END IF

	            SELECT cta_restringida_orig INTO v_ctarestrin_ori
	            FROM bdinteg:si_catalog
	            WHERE empresa = p_empresa
	               AND ccmayor = v_cuenta
	               AND ccsub   = v_subcta
	               AND ccsubsub = v_subsubcta
	               AND ccssubsub = v_ssubsubcta
	               AND ccsssubsub = v_sssubsubcta
	               AND sector =     v_sector;

	            IF v_ctarestrin_ori='S' THEN
	                    ----- VALIDAR C COSTO ORIGEN
	                    LET v_cuenta_ccosto_orig = 0;

	                    SELECT COUNT(*) 
						  INTO  v_cuenta_ccosto_orig
	                      FROM bdicont:"informix".co_cta_ccorig
	                     WHERE empresa = p_empresa
	                       AND ccmayor = v_cuenta
	                       AND ccsub   = v_subcta
	                       AND ccsubsub = v_subsubcta
	                       AND ccssubsub = v_ssubsubcta
	                       AND ccsssubsub = v_sssubsubcta
	                       AND sector =     v_sector
	                       AND sucursal =   v_ccosto_orig;

	                    IF v_cuenta_ccosto_orig = 0 THEN  ----cuenta no permitida para cc
	                       LET cod_ret = '148';

	                       INSERT INTO bdicont:"informix".co_auditerr
	                          VALUES(p_usuario,
	                                 v_control_poliza,
	                                 v_fecha_captura,
	                                 i,
	                                 p_empresa,
	                                 v_cuenta,
	                                 v_subcta,
	                                 v_subsubcta,
	                                 v_ssubsubcta,
	                                 v_sssubsubcta,
	                                 v_sector,
	                                 v_importe,
	                                 cod_ret);
	                    END IF
				END IF

	            SELECT cta_restringida_dest 
				  INTO v_ctarestrin_des
	              FROM bdinteg:si_catalog
	             WHERE empresa = p_empresa
	               AND ccmayor = v_cuenta
	               AND ccsub   = v_subcta
	               AND ccsubsub = v_subsubcta
	               AND ccssubsub = v_ssubsubcta
	               AND ccsssubsub = v_sssubsubcta
	               AND sector =     v_sector;

	            IF v_ctarestrin_des='S' THEN
	                      ----- VALIDAR C COSTO DESTINO
	                    LET v_cuenta_ccosto_orig = 0;

	                    SELECT COUNT(*) 
						  INTO  v_cuenta_ccosto_dest
	                      FROM bdicont:"informix".co_cta_ccdest
	                     WHERE empresa = p_empresa
	                       AND ccmayor = v_cuenta
	                       AND ccsub   = v_subcta
	                       AND ccsubsub = v_subsubcta
	                       AND ccssubsub = v_ssubsubcta
	                       AND ccsssubsub = v_sssubsubcta
	                       AND sector =     v_sector
	                       AND sucursal =   v_sucursal;

	                    IF v_cuenta_ccosto_dest = 0 THEN  ----cuenta no permitida para cc
	                       LET cod_ret = '149';

	                       INSERT INTO bdicont:"informix".co_auditerr
	                          VALUES(p_usuario,
	                                 v_control_poliza,
	                                 v_fecha_captura,
	                                 i,
	                                 p_empresa,
	                                 v_cuenta,
	                                 v_subcta,
	                                 v_subsubcta,
	                                 v_ssubsubcta,
	                                 v_sssubsubcta,
	                                 v_sector,
	                                 v_importe,
	                                 cod_ret);
	                    END IF
	            END IF
	        END IF
	    END FOREACH;
	END IF

	IF cod_ret = '000' THEN	

	   FOREACH
	      SELECT cuenta||subcta||subsubcta||ssubsubcta||sssubsubcta||sector,naturaleza,sucursal,SUM(importe)
	      INTO
	        v_cuentacom,v_naturaleza,v_suc,v_importe
	      FROM
	        bdicont:"informix".co_integracion
	      WHERE
	        usuario_int=p_usuario
	      GROUP BY 1,2,3
	      ORDER BY 1,2,3

	        LET v_cuentacom[2,4]=v_cuentacom[2,4];
	        LET v_cuentacom[5,6]=v_cuentacom[5,6];
	        LET v_cuentacom[7,8]=v_cuentacom[7,8];
	        LET v_cuentacom[9,10]=v_cuentacom[9,10];
	        LET v_cuentacom[11,12]=v_cuentacom[11,12];
	        LET v_cuentacom[13,14]=v_cuentacom[13,14];

	        IF v_cuentacom[1,4] >= v_ctacor_ini AND v_cuentacom[1,4] <= v_ctacor_fin THEN
	                
	                IF v_naturaleza='C' THEN
	                    SELECT SUM(importe) INTO v_SUMa_orden FROM bdicont:"informix".co_integracion
	                    WHERE cuenta =v_ctaord_ini[1,1]||v_cuentacom[2,4]
	                    AND subcta = v_cuentacom[5,6]
	                    AND subsubcta = v_cuentacom[7,8]
	                    AND ssubsubcta = v_cuentacom[9,10]
	                    AND sssubsubcta = v_cuentacom[11,12]
	                    AND sector = v_cuentacom[13,14]
	                    AND naturaleza = 'D'
	                    AND sucursal = v_suc
	                    AND usuario_int = p_usuario;

	                    LET v_SUMa_orden=v_SUMa_orden;
	                    LET v_importe=v_importe;

	                    IF v_importe != v_SUMa_orden THEN
	                        LET cod_ret = '167';

	                        INSERT INTO bdicont:"informix".co_auditerr
	                        VALUES(p_usuario,
	                        v_control_poliza,
	                        v_fecha_captura,
	                        i,
	                        p_empresa,
	                        v_cuentacom[1,4],
	                        v_cuentacom[5,6],
	                        v_cuentacom[7,8],
	                        v_cuentacom[9,10],
	                        v_cuentacom[11,12],
	                        v_cuentacom[13,14],
	                        v_importe,
	                        cod_ret);

	                    END IF
	                END IF

	                IF v_naturaleza='D' THEN
	                    SELECT SUM(importe) INTO v_SUMa_orden FROM bdicont:"informix".co_integracion
	                    WHERE cuenta =v_ctaord_ini[1,1]||v_cuentacom[2,4]
	                    AND subcta = v_cuentacom[5,6]
	                    AND subsubcta = v_cuentacom[7,8]
	                    AND ssubsubcta = v_cuentacom[9,10]
	                    AND sssubsubcta = v_cuentacom[11,12]
	                    AND sector = v_cuentacom[13,14]
	                    AND naturaleza = 'C'
	                    AND sucursal = v_suc
	                    AND usuario_int = p_usuario;

	                    LET v_SUMa_orden=v_SUMa_orden;
	                    LET v_importe=v_importe;

	                        IF v_importe != v_SUMa_orden THEN
	                            LET cod_ret = '167';

	                            INSERT INTO bdicont:"informix".co_auditerr
	                            VALUES(p_usuario,
	                            v_control_poliza,
	                            v_fecha_captura,
	                            i,
	                            p_empresa,
	                            v_cuentacom[1,4],
	                            v_cuentacom[5,6],
	                            v_cuentacom[7,8],
	                            v_cuentacom[9,10],
	                            v_cuentacom[11,12],
	                            v_cuentacom[13,14],
	                            v_importe,
	                            cod_ret);
	                        END IF
	                END IF
	        END IF

	        IF v_cuentacom[1,4] >= v_ctaord_ini AND v_cuentacom[1,4] <= v_ctaord_fin THEN

	                IF v_naturaleza='C' THEN

	                    SELECT SUM(importe) INTO v_SUMa_corre FROM bdicont:"informix".co_integracion
	                    WHERE cuenta =v_ctacor_ini[1,1]||v_cuentacom[2,4]
	                    AND subcta = v_cuentacom[5,6]
	                    AND subsubcta = v_cuentacom[7,8]
	                    AND ssubsubcta = v_cuentacom[9,10]
	                    AND sssubsubcta = v_cuentacom[11,12]
	                    AND sector = v_cuentacom[13,14]
	                    AND naturaleza = 'D'
	                    AND sucursal = v_suc
	                    AND usuario_int = p_usuario;

	                    LET v_SUMa_corre=v_SUMa_corre;
	                    LET v_importe=v_importe;

	                        IF v_importe != v_SUMa_corre THEN
	                            LET cod_ret = '167';

	                            INSERT INTO bdicont:"informix".co_auditerr
	                            VALUES(p_usuario,
	                            v_control_poliza,
	                            v_fecha_captura,
	                            i,
	                            p_empresa,
	                            v_cuentacom[1,4],
	                            v_cuentacom[5,6],
	                            v_cuentacom[7,8],
	                            v_cuentacom[9,10],
	                            v_cuentacom[11,12],
	                            v_cuentacom[13,14],
	                            v_importe,
	                            cod_ret);
	                        END IF
	                END IF

	                IF v_naturaleza='D' THEN

	                    SELECT SUM(importe) INTO v_SUMa_corre FROM bdicont:"informix".co_integracion
	                    WHERE cuenta =v_ctacor_ini[1,1]||v_cuentacom[2,4]
	                    AND subcta = v_cuentacom[5,6]
	                    AND subsubcta = v_cuentacom[7,8]
	                    AND ssubsubcta = v_cuentacom[9,10]
	                    AND sssubsubcta = v_cuentacom[11,12]
	                    AND sector = v_cuentacom[13,14]
	                    AND naturaleza = 'C'
	                    AND sucursal = v_suc
	                    AND usuario_int = p_usuario;

	                    LET v_SUMa_corre=v_SUMa_corre;
	                    LET v_importe=v_importe;

	                        IF v_importe != v_SUMa_corre THEN
	                            LET cod_ret = '167';

	                            INSERT INTO bdicont:"informix".co_auditerr
	                            VALUES(p_usuario,
	                            v_control_poliza,
	                            v_fecha_captura,
	                            i,
	                            p_empresa,
	                            v_cuentacom[1,4],
	                            v_cuentacom[5,6],
	                            v_cuentacom[7,8],
	                            v_cuentacom[9,10],
	                            v_cuentacom[11,12],
	                            v_cuentacom[13,14],
	                            v_importe,
	                            cod_ret);
	                        END IF
	                END IF
	        END IF
	    END FOREACH;
	END IF

	IF cod_ret = '000' THEN

		LET i  = 1;
		LET j  = 0;

	--- ASIGNA EL NUMERO CONSECUTIVO DE POLIZA
		LET v_control_poliza = 0;

		SELECT MAX(numero) 
		  INTO v_control_poliza 
		  FROM bdicont:"informix".co_ctrlpoliza;

		IF v_control_poliza IS NULL  OR  v_control_poliza = 0  THEN
		    LET v_control_poliza = 0;
		END IF

		LET v_control_poliza = v_control_poliza + 1;

		UPDATE bdicont:"informix".co_ctrlpoliza SET numero = v_control_poliza;

	--- CLAVE RETROACTIVA
	    SELECT COUNT(*) 
		  INTO v_contador
		  FROM bdicont:"informix".co_clv_retroact
	     WHERE fecha_captura =v_fecha_hoy 
		   AND fecha_inicial <=v_fecha 
           AND fecha_final   >=v_fecha 
		   AND usuario_solicita=v_usuario 
		   AND estatus_uso='N';
		   
		FOREACH
			SELECT empresa,ccosto_orig,usuario,fecha_captura,cuenta,subcta,
	               subsubcta,ssubsubcta,sssubsubcta,sector,regional,sucursal,
	               nro_auxiliar,fecha,moneda,naturaleza,importe,concepto,usuario_int    
			  INTO v_empresa,v_ccosto_orig,v_usuario,v_fecha_captura,v_cuenta,v_subcta,
				   v_subsubcta,v_ssubsubcta,v_sssubsubcta, v_sector, v_regional,v_sucursal,
				   v_nro_auxiliar,v_fecha,v_moneda,v_naturaleza,v_importe,v_concepto,v_usu
	          FROM bdicont:"informix".co_integracion
			  WHERE usuario_int = p_usuario

	      --Extrae Valores Iniciales.
			LET v_descripcion =v_concepto ;
			LET v_ciudad = v_regional||'1';

			IF (v_fecha_captura < v_fecha_hoy) OR (v_fecha_captura>= v_fecha_hoy AND v_fecha_captura <> v_fecha AND v_fecha > v_fecha_hoy ) 
			   OR (v_fecha > v_fecha_captura  ) THEN

				LET cod_ret = '163';

				INSERT INTO bdicont:"informix".co_auditerr
                     VALUES(p_usuario,
		                    v_control_poliza,
		                    v_fecha_captura,
		                    i,
							p_empresa,
							v_cuenta,
							v_subcta,
							v_subsubcta,
							v_ssubsubcta,
							v_sssubsubcta,
							v_sector,
							v_importe,
							cod_ret);

			END IF
   
			IF cod_ret = '000' THEN

				LET v_fecha_habil=v_fecha_hoy;
				LET v_dias_valor=0;

				IF v_contador=0 THEN

					SELECT dias_retroact 
					  INTO v_dias 
					  FROM bdicont:"informix".co_param;

					WHILE v_dias_valor < v_dias

						LET v_fecha_habil=v_fecha_habil - 1;

						SELECT COUNT(*) 
						  INTO v_contador
						  FROM bdinteg:si_feriado
						 WHERE fecha = v_fecha_habil
						   AND empresa = p_empresa
	                       AND laborable = 'N' ;

						IF v_contador > 0 THEN

						ELSE
							LET v_dias_valor=v_dias_valor + 1;
						END IF

					END WHILE;

					IF  v_fecha < v_fecha_habil THEN
						LET cod_ret = '164';

					 INSERT INTO bdicont:"informix".co_auditerr
	                        VALUES(p_usuario,
	                        v_control_poliza,
	                        v_fecha_captura,
	                        i,
	                        p_empresa,
	                        v_cuenta,
	                        v_subcta,
	                        v_subsubcta,
	                        v_ssubsubcta,
	                        v_sssubsubcta,
	                        v_sector,
	                        v_importe,
	                        cod_ret);

					END IF
				END IF
			END IF

			IF cod_ret = '000' THEN
				IF v_naturaleza = 'D' THEN
				    IF v_importe !=0 THEN
				        IF v_moneda='01' THEN
				            LET debito1 = v_importe;
				            LET w_cap_cargo_mn = w_cap_cargo_mn + debito1;

				            INSERT INTO bdicont:"informix".co_detpol VALUES(v_usuario,
				                      v_control_poliza,
				                      v_fecha_captura,
				                      i, p_empresa,
				                      v_cuenta,
				                      v_subcta,
				                      v_subsubcta,
				                      v_ssubsubcta,
				                      v_sssubsubcta,
				                      v_sector,
				                      v_regional,
				                      v_sucursal,
				                      v_nro_auxiliar,
				                      v_naturaleza,
				                      debito1,
				                      v_descripcion,
				                      v_fecha,
				                      v_moneda,
				                      0,0,' ',v_usuario, '',
				                      v_ccosto_orig);
				            LET i=i + 1;
				        ELSE
				            LET debito1=v_importe;
				            LET v_cap_cargo_dls=v_cap_cargo_dls+debito1;

				            INSERT INTO bdicont:"informix".co_detpol VALUES(v_usuario, v_control_poliza,
				                        v_fecha_captura,
				                        i, p_empresa,
				                        v_cuenta,
				                        v_subcta,
				                        v_subsubcta,
				                        v_ssubsubcta,
				                        v_sssubsubcta,
				                        v_sector,
				                        v_regional,
				                        v_sucursal,
				                        v_nro_auxiliar,
				                        v_naturaleza,
				                        debito1,
				                        v_descripcion,
				                        v_fecha,
				                        v_moneda,
				                        0,0,' ',v_usuario, '',
				                        v_ccosto_orig);
				                LET i=i + 1;
				        END IF
					END IF
				END IF

				IF v_naturaleza = 'C'  THEN
					IF v_importe !=0 THEN
						IF v_moneda='01' THEN
							LET credito1 = v_importe;
							LET v_cIFra_mn=v_cIFra_mn+credito1;
							LET v_cap_abono_mn = v_cap_abono_mn + credito1;

				            INSERT INTO bdicont:"informix".co_detpol VALUES(v_usuario,
				                                         v_control_poliza,  
				                                         v_fecha_captura,
				                                         i,p_empresa,
				                                         v_cuenta,
				                                         v_subcta,
				                                         v_subsubcta,
				                                         v_ssubsubcta,
				                                         v_sssubsubcta,
				                                         v_sector,
				                                         v_regional,
				                                         v_sucursal,
				                                         v_nro_auxiliar,
				                                         v_naturaleza,
				                                         credito1,
				                                         v_descripcion,
				                                         v_fecha,
				                                         v_moneda,
				                                         0,0,' ',v_usuario, '',
				                                         v_ccosto_orig);
				                                         LET i=i + 1;
						ELSE
							LET credito1 = v_importe;
							LET v_cIFra_dls=v_cIFra_dls+credito1;
							LET v_cap_abono_dls=v_cap_abono_dls + credito1;

				            INSERT INTO bdicont:"informix".co_detpol VALUES(v_usuario, v_control_poliza,
				                                         v_fecha_captura,
				                                         i,p_empresa,
				                                         v_cuenta,
				                                         v_subcta,
				                                         v_subsubcta,
				                                         v_ssubsubcta,
				                                         v_sssubsubcta,
				                                         v_sector,
				                                         v_regional,
				                                         v_sucursal,
				                                         v_nro_auxiliar,
				                                         v_naturaleza,
				                                         credito1,
				                                         v_descripcion,
				                                         v_fecha,
				                                         v_moneda,
				                                         0,0,' ',v_usuario, '',
				                                         v_ccosto_orig);
				                                         LET i=i + 1;
						END IF
					END IF
				END IF
			END IF
		END FOREACH;

		IF v_cIFra_dls > 0 THEN

			INSERT INTO bdicont:"informix".co_poliza 
	             VALUES(p_empresa,
						v_usuario,
						v_control_poliza,
						v_fecha_captura,
						v_cIFra_dls,
						v_cap_cargo_dls,
	                    v_cap_abono_dls,
	                    '02',
	                    v_descripcion);
		ELSE

			DELETE FROM bdicont:"informix".co_detpol
				  WHERE fecha_captura=v_fecha_captura 
					AND usuario=v_usuario 
					AND control_poliza=v_control_poliza 
					AND moneda='02';
	    END IF

		IF v_cIFra_mn > 0 THEN

			INSERT INTO bdicont:"informix".co_poliza 
			     VALUES (p_empresa,
						 v_usuario,
	                     v_control_poliza,    
	                     v_fecha_captura,
	                     v_cIFra_mn,
	                     w_cap_cargo_mn,
	                     v_cap_abono_mn,
	                     '01',
	                     v_descripcion);
		ELSE
			
			DELETE FROM bdicont:"informix".co_detpol
			      WHERE fecha_captura=v_fecha_captura 
				    AND usuario=v_usuario 
				    AND control_poliza=v_control_poliza 
				    AND moneda='01';
		END IF

{		IF cod_ret = '000' THEN
			-------nivelacion por centros de costo -----------
			CALL nivelacion_ccostos(p_empresa,v_fecha) RETURNING cod_ret;
		END IF
}
	END IF

	DELETE FROM bdicont:"informix".co_integracion WHERE usuario_int=p_usuario;

	IF cod_ret != '000' THEN
		LET v_mensaje = "ERROR AL GENERAR IMPORTACIÓN";
		LET v_control_poliza= 0;
	END IF

RETURN cod_ret,v_control_poliza, v_mensaje;

END PROCEDURE;