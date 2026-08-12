CREATE PROCEDURE "informix".sps_consulta_tdcbcfrecuentes(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6) as cod_ret, ---cod_ret
	 CHAR(20) as cuenta, ---cuenta
	 CHAR(100) as nombre, ---nombre
	 CHAR(50) as banco, ---banco
	 CHAR(2) as compania_cel, ---compañia celular
	 CHAR(10) as celular, ---numero celular
	 CHAR(40) as correo_elec, ---correo electronico
	 CHAR(2) as cve_cuenta, ---cve cuenta
     CHAR(20) as desc_cuenta, ---desc cuenta
     CHAR(13) as rfc , ---rfc
	 MONEY(16,2) as monto_maximo, ---Monto Máximo
	 CHAR(1) as cve_caducidad, -- tipo de caducidad
	 CHAR(1) as activarBPI; -- Estatus de referencia bpi
	 

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
	DEFINE v_ContReg			SMALLINT;
	DEFINE v_DescCta			CHAR(20);
    DEFINE v_Rfc                CHAR(13);
	DEFINE v_Canal				CHAR(2);
	DEFINE v_FechaInsert		DATE;
	DEFINE v_HoraInsert			DATETIME HOUR TO SECOND;
	DEFINE v_FechaHoraInsert	DATETIME YEAR TO FRACTION;
	DEFINE v_MontoMaximo		MONEY(16,2);
	DEFINE v_CveCaducidad		INTEGER;
	DEFINE v_ExisteCuenta		CHAR(20);
	DEFINE v_ActivaBPI			CHAR(1);
    DEFINE vv_Banco             CHAR(5);
    DEFINE v_vchrnombrecorto    CHAR(50);
    DEFINE v_descripcion        CHAR(50);
    DEFINE v_provisional        CHAR(50);
	DEFINE p_MontoMax			MONEY(16,2);

	LET v_CodDesc			    = "";
	LET v_CvePago				= "";
	LET v_CtaDestino			= "";
	LET v_Nombre				= "";
	LET v_Banco					= "";
	LET v_CompCel				= "";
	LET v_NumCel				= "";
	LET v_CorreoE				= "";
	LET v_CveCuenta				= "";
	LET v_ContReg			 	= 0;
	LET v_DescCta				= "";
    LET v_Rfc                   = "";
	LET v_Canal					= "";
	LET v_MontoMaximo			= 0.00;
	LET v_CveCaducidad			= "";
	LET v_ExisteCuenta			= NULL;
	LET v_ActivaBPI				= "";
	LET vv_Banco				= "";
    LET v_vchrnombrecorto		= "";
    LET v_descripcion		    = "";
	LET v_provisional			= "";
	LET p_MontoMax				= 200000.00;
	

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

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sps_consulta_tdcbcfrecuentes.out";
	--TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
    SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	SELECT banco, vchrnombrecorto, descripcion --|| " " || 
	INTO vv_Banco, v_vchrnombrecorto, v_descripcion
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";
	
    LET v_vchrnombrecorto=TRIM(v_vchrnombrecorto);
	LET v_descripcion=TRIM(v_descripcion);
	LET vv_Banco=TRIM(vv_Banco);
	
	IF (v_vchrnombrecorto='') THEN 
	LET v_provisional= v_descripcion;
	ELSE 
	LET v_provisional= v_vchrnombrecorto;
	END IF;
	Let v_Banco= vv_Banco|| " " ||v_provisional;


	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		--IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
		--SELECT LIMIT 1 ct.cuenta INTO v_ExisteCuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta;
		
		SELECT LIMIT 1 t.cuenta
		INTO v_ExisteCuenta
		FROM (SELECT ct.cuenta 
              FROM bdiprog:"informix".pp_ctasterceros ct
              left outer join bdiprog:"informix".pp_cuentapago cp on (ct.cve_cuenta = cp.cve_cuenta)
              WHERE ct.num_cte = p_NumCte
			UNION
			SELECT bex.cuenta
			FROM bdiprog:"informix".pp_ctasterceros_bex bex, bdiprog:"informix".pp_cuentapago cps 
			WHERE bex.num_cte = p_NumCte
			AND bex.cve_cuenta = cps.cve_cuenta
		) t;
		
		IF (v_ExisteCuenta IS NOT NULL) THEN
		
            FOREACH
				SELECT ct.cuenta, ct.nombre, b.banco, b.vchrnombrecorto, b.descripcion, -- || "  " ||
				ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0), ct.cve_caducidad, '1' AS activaBPI
				INTO v_CtaDestino,v_Nombre,vv_Banco,v_vchrnombrecorto, v_descripcion,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo, v_CveCaducidad, v_ActivaBPI
				
				FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
					
				WHERE ct.num_cte = p_NumCte
				AND ct.cve_banco = b.banco
				AND ct.cve_cuenta = cp.cve_cuenta
				AND cp.cve_pago = p_CvePago
				AND ct.cve_estado = '01'
				UNION
				SELECT bex.cuenta, bex.nombre, '137  BANCOPPEL', sb.vchrnombrecorto,sb.descripcion,bex.cve_compania, bex.no_celular, bex.direc_correo, bex.cve_cuenta, bex.descrip_cta, bex.rfc, bex.canal_alta, bex.fecha_insert, bex.hora_insert, NVL(bex.monto_maximo,0), bex.cve_caducidad, '0' AS activaBPI
				FROM bdiprog:"informix".pp_ctasterceros_bex bex, bdinteg:"informix".si_bancos sb, bdiprog:"informix".pp_cuentapago cps
            	WHERE bex.num_cte = p_NumCte
				AND bex.cve_banco = sb.banco
                AND bex.cve_cuenta = cps.cve_cuenta
                AND cps.cve_pago = p_CvePago
                AND bex.cve_estado = '01'
				ORDER BY activaBPI ASC
				
				IF v_MontoMaximo= 0 THEN 
						LET v_MontoMaximo = p_MontoMax;
					END IF 
				
				-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
				
				LET v_vchrnombrecorto=TRIM(v_vchrnombrecorto);
				LET v_descripcion=TRIM(v_descripcion);
				LET vv_Banco=TRIM(vv_Banco);
				
					IF (v_vchrnombrecorto='') THEN 
					LET v_provisional= v_descripcion;
					ELSE 
					LET v_provisional= v_vchrnombrecorto;
					END IF;
					
					Let v_Banco= vv_Banco|| " " ||v_provisional;
				
				IF v_Canal = '03' THEN
					LET v_FechaHoraInsert = ( YEAR(v_FechaInsert) || '-' || MONTH(v_FechaInsert) || '-' || DAY(v_FechaInsert) || ' ' || v_HoraInsert)::DATETIME YEAR TO FRACTION;
					IF (current - v_FechaHoraInsert) < '0 00:30:00' THEN
						CONTINUE FOREACH;
					END IF;
				END IF;
				
				LET v_ContReg = v_ContReg + 1;

				IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
					CONTINUE FOREACH;
				END IF;					

				RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc, v_MontoMaximo, v_CveCaducidad, v_ActivaBPI  WITH RESUME;
			END FOREACH;
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
END PROCEDURE;