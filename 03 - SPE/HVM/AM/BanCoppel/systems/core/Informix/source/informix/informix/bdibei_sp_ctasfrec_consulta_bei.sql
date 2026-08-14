CREATE PROCEDURE "informix".sp_ctasfrec_consulta_bei
	(
	pNum_Cte CHAR(20), 
    pAlias CHAR(20),
    pClave_banco INTEGER, 
    pOtro  CHAR(20), --numero de cuenta
    pOtro2  CHAR(60), --nombre titular
    p_CvePago  CHAR(2), --SPEI 03 o TERCEROS 02
    pTipoBusqueda SMALLINT, --Todos=1 Alias=2, Banco=3, cuenta=4 y titular=5
	pSalto SMALLINT
	)
	
RETURNING
     CHAR(6) as cod_ret, ---cod_ret
	 CHAR(20) as cuenta, ---cuenta
	 CHAR(100) as nombre, ---nombre
	 CHAR(50) as banco, ---banco
	 CHAR(2) as compania_cel, ---compaÃÂÃÂ±ia celular
	 CHAR(10) as celular, ---numero celular
	 CHAR(40) as correo_elec, ---correo electronico
	 CHAR(2) as cve_cuenta, ---cve cuenta
     CHAR(20) as desc_cuenta, ---desc cuenta
     CHAR(13) as rfc , ---rfc
	 MONEY(16,2) as monto_maximo, ---Monto MÃÂÃÂ¡ximo
	 CHAR(1) as cve_caducidad, -- tipo de caducidad
 	 SMALLINT as status_habilitado; -- 1 Habilitado 2 Deshabilitado

 
--##################################################################################################
--##Crea		 : Berenice Noriega G. - BanCoppel - CoordinaciÃÂÃÂ³n Internet - G3
--##Fecha        : 28/Febrero/2019
--##Descripcion  : Se crea con el proposito de consultar las cuentas frecuentees tanto las 
--##				habilitadas como las que no, con filtros de busqueda para el portal de 
--##				Empresas.
--##				De consulta de cuentas frecuentes TERCEROS MISMO BANCO y de SPEI
--##Modificado   : Se ordena por descripciÃÂ³n, y por estatus.
--##Fecha		 : 01/Abril/2019
--##Modificado   : Se agrega consulta por nombre de titular y por cuenta.
--##Fecha		 : 17/Junio/2019
--###################################################################################################

    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
	DEFINE v_CodDesc			CHAR(50);
	DEFINE v_CvePago			CHAR(2);
	DEFINE v_CtaDestino			CHAR(20);
	DEFINE v_Nombre				CHAR(100);
	DEFINE v_Banco				CHAR(50);
	DEFINE v_CompCel			CHAR(2);
	DEFINE v_NumCel				CHAR(10);
	DEFINE v_CorreoE			CHAR(40);
	DEFINE v_CveCuenta			CHAR(2);
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_CveCaducidad		INTEGER;
	DEFINE v_StatusHabilitado	SMALLINT;
	DEFINE v_Alias 				CHAR(20);
    DEFINE v_descripcion        CHAR(40); 
    DEFINE v_vchrnombrecorto    VARCHAR(20);
	DEFINE v_Otro  				CHAR(20);
    DEFINE v_Otro2  			CHAR(60);

	--Set Debug File To '/home/informix/BereniceOut/sp_ctasfrec_consulta_bei.out';
	--Trace On;
 
	LET v_cod_ret  				= '00000';
	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_CveCaducidad			= "";
	LET v_StatusHabilitado		= 1;
	LET v_Alias 				= ('%' || TRIM(pAlias) || '%');
    LET v_descripcion           = ""; 
    LET v_vchrnombrecorto       = "";
	LET v_Otro  				= ('%' || TRIM(pOtro) || '%');
    LET v_Otro2  				= ('%' || TRIM(pOtro2) || '%');

	
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

		
		--***VALIDAR DATOS DE ENTRADA************************************************
        IF NVL(pNum_Cte,'')=='' THEN
            LET v_cod_ret = '00002'; --Numero de cliente vacio
	        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
		
        IF NVL(p_CvePago,'')=='' THEN
            LET v_cod_ret = '00003'; -- Clave de de pago vacio
	        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
		
        IF NVL(pTipoBusqueda,'')=='' THEN
            LET v_cod_ret = '00004'; --Tipo de busqueda vacio
	        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
		
		IF ((NVL(p_CvePago,'')=='02') AND ((pClave_banco<>'137') OR ( NVL(pClave_banco,'')==''))) THEN
            LET v_cod_ret = '00005'; --Banco no valido para consulta de CF terceros
	        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
		
		IF NVL(pSalto,'')=='' THEN
            LET v_cod_ret = '00008'; --Dato para saldo de paguinacion vacio
	        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
        END IF;
	 --*************************************************************************************************
  

	IF NVL(pTipoBusqueda,'')=='1'  THEN ---Busqueda Todos 
			FOREACH
                SELECT SKIP pSalto FIRST 10
                    ct2.cuenta, 
                    ct2.nombre, 
                    ct2.cve_banco, 
                    ct2.cve_compania, 
                    ct2.no_celular, 
                    ct2.direc_correo, 
                    ct2.cve_cuenta,
                    ct2.descrip_cta, 
                    ct2.rfc, 
                    ct2.canal_alta, 
                    ct2.fecha_insert, 
                    ct2.hora_insert, 
                    NVL(ct2.monto_maximo,0),
                    ct2.cve_caducidad,
                    status_cta
                INTO 
                    v_CtaDestino,
                    v_Nombre,
                    v_Banco,
                    v_CompCel,
                    v_NumCel,
                    v_CorreoE,
                    v_CveCuenta,
                    v_DescCta, 
                    v_Rfc, 
                    v_Canal, 
                    v_FechaInsert, 
                    v_HoraInsert, 
                    v_MontoMaximo, 
                    v_CveCaducidad,
                    v_StatusHabilitado
      			FROM (
                 SELECT
                    ct.cuenta, 
                    ct.nombre, 
                    ct.cve_banco, 
                    ct.cve_compania, 
                    ct.no_celular, 
                    ct.direc_correo, 
                    ct.cve_cuenta,
                    ct.descrip_cta, 
                    ct.rfc, 
                    ct.canal_alta, 
                    ct.fecha_insert, 
                    ct.hora_insert, 
                    ct.monto_maximo,
                    ct.cve_caducidad,
                    CASE
                        WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) < '0 00:30:00') THEN 2
                        WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) >= '0 00:30:00') THEN 1
                        ELSE 0
                    END AS status_cta
                  FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = pNum_Cte
                     AND ct.cve_cuenta = cp.cve_cuenta
                     AND ct.cve_estado = '01'
                     AND cp.cve_pago = p_CvePago 
                  ORDER BY status_cta DESC, ct.descrip_cta ASC    
                 ) ct2 
    
					
				-- Si el canal es de internet, distingira entre habilitados y no habilitados (registros que tengan menos de 30 minutos transcurridos despues de su alta)
				--IF (v_Canal = '03') OR (v_Canal = '15') THEN
					--LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
					--IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
					--	LET v_StatusHabilitado=2; --deshabilitado 
					--ELSE LET v_StatusHabilitado=1;  --habilitado
					--END IF;
				--END IF;
         

                    select descripcion, vchrnombrecorto 
                    INTO v_descripcion, v_vchrnombrecorto
                    from bdinteg:"informix".si_bancos where banco=v_Banco;
               
                    IF (v_vchrnombrecorto is not null) OR (v_descripcion is not null) THEN
                        IF TRIM(v_vchrnombrecorto)  = ''  THEN
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_descripcion);
                        ELSE
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_vchrnombrecorto);
                        END IF;
                    END IF;

                RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, v_StatusHabilitado  WITH RESUME;
            END FOREACH;
 
	ELIF NVL(pTipoBusqueda,'')=='2' THEN ---Busqueda por Alias
			IF ((pAlias IS NULL) or ( NVL(pAlias,'')=='')) THEN
				 LET v_cod_ret = '00006'; -- Alias vacio, necesario para busqueda por Alias
				 RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
			ElSE								  
	  			FOREACH
					 SELECT SKIP pSalto FIRST 10
                        ct2.cuenta, 
                        ct2.nombre, 
                        ct2.cve_banco, 
                        ct2.cve_compania, 
                        ct2.no_celular, 
                        ct2.direc_correo, 
                        ct2.cve_cuenta,
                        ct2.descrip_cta, 
                        ct2.rfc, 
                        ct2.canal_alta, 
                        ct2.fecha_insert, 
                        ct2.hora_insert, 
                        NVL(ct2.monto_maximo,0),
                        ct2.cve_caducidad,
                        status_cta
					INTO 
                        v_CtaDestino,
                        v_Nombre,
                        v_Banco,
                        v_CompCel,
                        v_NumCel,
                        v_CorreoE,
                        v_CveCuenta,
                        v_DescCta, 
                        v_Rfc, 
                        v_Canal, 
                        v_FechaInsert, 
                        v_HoraInsert, 
                        v_MontoMaximo, 
                        v_CveCaducidad,
                        v_StatusHabilitado
					FROM ( 
                        SELECT
                            ct.cuenta, 
                            ct.nombre, 
                            ct.cve_banco, 
                            ct.cve_compania, 
                            ct.no_celular, 
                            ct.direc_correo, 
                            ct.cve_cuenta,
                            ct.descrip_cta, 
                            ct.rfc, 
                            ct.canal_alta, 
                            ct.fecha_insert, 
                            ct.hora_insert, 
                            ct.monto_maximo,
                            ct.cve_caducidad,
                            CASE
                                WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) < '0 00:30:00') THEN 2
                                WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) >= '0 00:30:00') THEN 1
                                ELSE 0
                            END AS status_cta
                        from  bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                        WHERE ct.num_cte = pNum_Cte
                            AND ct.cve_cuenta = cp.cve_cuenta
                            AND ct.cve_estado = '01'
                            AND cp.cve_pago = p_CvePago    ---02Tercero 03SPEI
                            AND ct.descrip_cta like v_Alias					
                        ORDER BY status_cta DESC, ct.descrip_cta ASC   
                        ) ct2 
				
                	-- Si el canal es de internet, distingira entre habilitados y no habilitados (registros que tengan menos de 30 minutos transcurridos despues de su alta)
					--IF (v_Canal = '03') OR (v_Canal = '15') THEN
						--LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						--IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
						--	LET v_StatusHabilitado=2; --deshabilitado 
						--ELSE LET v_StatusHabilitado=1;  --habilitado
						--END IF;
					--END IF;


                    select descripcion, vchrnombrecorto 
                    INTO v_descripcion, v_vchrnombrecorto
                    from bdinteg:"informix".si_bancos where banco=v_Banco;
               
                    IF (v_vchrnombrecorto is not null) OR (v_descripcion is not null) THEN
                        IF TRIM(v_vchrnombrecorto)  = ''  THEN
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_descripcion);
                        ELSE
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_vchrnombrecorto);
                        END IF;
                    END IF;
					
					RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, v_StatusHabilitado  WITH RESUME;
				END FOREACH;
			END IF;

    ELIF NVL(pTipoBusqueda,'')=='3' THEN --Busqueda por Banco
			  IF (p_CvePago <> '03') THEN
				 LET v_cod_ret = '00007'; -- clave de pago no corresponde para la busqueda por banco
				 RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
			  ElSE
				  FOREACH
					SELECT SKIP pSalto FIRST 10 
                        ct2.cuenta, 
                        ct2.nombre, 
                        ct2.cve_banco, 
                        ct2.cve_compania, 
                        ct2.no_celular, 
                        ct2.direc_correo, 
                        ct2.cve_cuenta,
                        ct2.descrip_cta, 
                        ct2.rfc, 
                        ct2.canal_alta, 
                        ct2.fecha_insert, 
                        ct2.hora_insert, 
                        NVL(ct2.monto_maximo,0), 
                        ct2.cve_caducidad,
                        status_cta
					INTO
                        v_CtaDestino,
                        v_Nombre,
                        v_Banco,
                        v_CompCel,
                        v_NumCel,
                        v_CorreoE,
                        v_CveCuenta,
                        v_DescCta, 
                        v_Rfc, 
                        v_Canal, 
                        v_FechaInsert, 
                        v_HoraInsert, 
                        v_MontoMaximo, 
                        v_CveCaducidad,
                        v_StatusHabilitado
                    FROM  ( 
                        SELECT
                        ct.cuenta, 
                        ct.nombre, 
                        ct.cve_banco, 
                        ct.cve_compania, 
                        ct.no_celular, 
                        ct.direc_correo, 
                        ct.cve_cuenta,
                        ct.descrip_cta, 
                        ct.rfc, 
                        ct.canal_alta, 
                        ct.fecha_insert, 
                        ct.hora_insert, 
                        ct.monto_maximo, 
                        ct.cve_caducidad,
                        CASE
                            WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) < '0 00:30:00') THEN 2
                            WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) >= '0 00:30:00') THEN 1
                            ELSE 0
                        END AS status_cta
                      FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                      WHERE ct.num_cte = pNum_Cte
                        AND ct.cve_cuenta = cp.cve_cuenta
                        AND ct.cve_estado = '01'
                        AND cp.cve_pago = p_CvePago    ---03SPEI	
                        AND ct.cve_banco = pClave_banco					
                     ORDER BY status_cta DESC, ct.descrip_cta ASC
               	 ) ct2

					-- Si el canal es de internet, distingira entre habilitados y no habilitados (registros que tengan menos de 30 minutos transcurridos despues de su alta)
					--IF (v_Canal = '03') OR (v_Canal = '15') THEN
						--LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
						--IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
							--LET v_StatusHabilitado=2; --deshabilitado 
						--ELSE LET v_StatusHabilitado=1;  --habilitado
						--END IF;
					--END IF;

                    select descripcion, vchrnombrecorto 
                    INTO v_descripcion, v_vchrnombrecorto
                    from bdinteg:"informix".si_bancos where banco=v_Banco;
               
                    IF (v_vchrnombrecorto is not null) OR (v_descripcion is not null) THEN
                        IF TRIM(v_vchrnombrecorto)  = ''  THEN
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_descripcion);
                        ELSE
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_vchrnombrecorto);
                        END IF;
                    END IF;
					
					RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, v_StatusHabilitado  WITH RESUME;
				END FOREACH;
				  
			   END IF;
			   
	ELIF NVL(pTipoBusqueda,'')=='4' THEN --Busqueda por cuenta
			IF ((pOtro IS NULL) or ( NVL(pOtro,'')=='')) THEN
				 LET v_cod_ret = '00008'; -- pOtro cuenta vacio, necesario para busqueda por numero de cuenta
				 RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
			ElSE
			FOREACH
					SELECT SKIP pSalto FIRST 10 
                        ct2.cuenta, 
                        ct2.nombre, 
                        ct2.cve_banco, 
                        ct2.cve_compania, 
                        ct2.no_celular, 
                        ct2.direc_correo, 
                        ct2.cve_cuenta,
                        ct2.descrip_cta, 
                        ct2.rfc, 
                        ct2.canal_alta, 
                        ct2.fecha_insert, 
                        ct2.hora_insert, 
                        NVL(ct2.monto_maximo,0), 
                        ct2.cve_caducidad,
                        status_cta
					INTO
                        v_CtaDestino,
                        v_Nombre,
                        v_Banco,
                        v_CompCel,
                        v_NumCel,
                        v_CorreoE,
                        v_CveCuenta,
                        v_DescCta, 
                        v_Rfc, 
                        v_Canal, 
                        v_FechaInsert, 
                        v_HoraInsert, 
                        v_MontoMaximo, 
                        v_CveCaducidad,
                        v_StatusHabilitado
                    FROM  ( 
                        SELECT
                        ct.cuenta, 
                        ct.nombre, 
                        ct.cve_banco, 
                        ct.cve_compania, 
                        ct.no_celular, 
                        ct.direc_correo, 
                        ct.cve_cuenta,
                        ct.descrip_cta, 
                        ct.rfc, 
                        ct.canal_alta, 
                        ct.fecha_insert, 
                        ct.hora_insert, 
                        ct.monto_maximo, 
                        ct.cve_caducidad,
                        CASE
                            WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) < '0 00:30:00') THEN 2
                            WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) >= '0 00:30:00') THEN 1
                            ELSE 0
                        END AS status_cta
                      FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                      WHERE ct.num_cte = pNum_Cte
                        AND ct.cve_cuenta = cp.cve_cuenta
                        AND ct.cve_estado = '01'
                        AND cp.cve_pago = p_CvePago  
                        AND ct.cuenta like v_Otro 	--cuenta
                     ORDER BY status_cta DESC, ct.descrip_cta ASC
               	 ) ct2

                    select descripcion, vchrnombrecorto 
                    INTO v_descripcion, v_vchrnombrecorto
                    from bdinteg:"informix".si_bancos where banco=v_Banco;
               
                    IF (v_vchrnombrecorto is not null) OR (v_descripcion is not null) THEN
                        IF TRIM(v_vchrnombrecorto)  = ''  THEN
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_descripcion);
                        ELSE
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_vchrnombrecorto);
                        END IF;
                    END IF;
					
					RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, v_StatusHabilitado  WITH RESUME;
				END FOREACH;
		END IF;
	
	ELIF NVL(pTipoBusqueda,'')=='5' THEN --Busqueda por nombre titular
			IF ((pOtro2 IS NULL) or ( NVL(pOtro2,'')=='')) THEN
				 LET v_cod_ret = '00008'; -- pOtro2 nombre titular vacio, necesario para busqueda por nombre titular
				 RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
			ElSE
			FOREACH
					SELECT SKIP pSalto FIRST 10 
                        ct2.cuenta, 
                        ct2.nombre, 
                        ct2.cve_banco, 
                        ct2.cve_compania, 
                        ct2.no_celular, 
                        ct2.direc_correo, 
                        ct2.cve_cuenta,
                        ct2.descrip_cta, 
                        ct2.rfc, 
                        ct2.canal_alta, 
                        ct2.fecha_insert, 
                        ct2.hora_insert, 
                        NVL(ct2.monto_maximo,0), 
                        ct2.cve_caducidad,
                        status_cta
					INTO
                        v_CtaDestino,
                        v_Nombre,
                        v_Banco,
                        v_CompCel,
                        v_NumCel,
                        v_CorreoE,
                        v_CveCuenta,
                        v_DescCta, 
                        v_Rfc, 
                        v_Canal, 
                        v_FechaInsert, 
                        v_HoraInsert, 
                        v_MontoMaximo, 
                        v_CveCaducidad,
                        v_StatusHabilitado
                    FROM  ( 
                        SELECT
                        ct.cuenta, 
                        ct.nombre, 
                        ct.cve_banco, 
                        ct.cve_compania, 
                        ct.no_celular, 
                        ct.direc_correo, 
                        ct.cve_cuenta,
                        ct.descrip_cta, 
                        ct.rfc, 
                        ct.canal_alta, 
                        ct.fecha_insert, 
                        ct.hora_insert, 
                        ct.monto_maximo, 
                        ct.cve_caducidad,
                        CASE
                            WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) < '0 00:30:00') THEN 2
                            WHEN ((current - (( YEAR(ct.fecha_insert) || '-' || MONTH(ct.fecha_insert) || '-' || DAY(ct.fecha_insert) || ' ' || ct.hora_insert)::DATETIME YEAR TO FRACTION)) >= '0 00:30:00') THEN 1
                            ELSE 0
                        END AS status_cta
                      FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                      WHERE ct.num_cte = pNum_Cte
                        AND ct.cve_cuenta = cp.cve_cuenta
                        AND ct.cve_estado = '01'
                        AND cp.cve_pago = p_CvePago    
                        AND ct.nombre like v_Otro2 --Nombre titular					
                     ORDER BY status_cta DESC, ct.descrip_cta ASC
               	 ) ct2

				    select descripcion, vchrnombrecorto 
                    INTO v_descripcion, v_vchrnombrecorto
                    from bdinteg:"informix".si_bancos where banco=v_Banco;
               
                    IF (v_vchrnombrecorto is not null) OR (v_descripcion is not null) THEN
                        IF TRIM(v_vchrnombrecorto)  = ''  THEN
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_descripcion);
                        ELSE
                            LET v_Banco= TRIM(v_Banco) || "  " || TRIM(v_vchrnombrecorto);
                        END IF;
                    END IF;
					
					RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo,v_CveCaducidad, v_StatusHabilitado  WITH RESUME;
				END FOREACH;
			END IF;
	
    END IF;
			       
END;

END PROCEDURE;