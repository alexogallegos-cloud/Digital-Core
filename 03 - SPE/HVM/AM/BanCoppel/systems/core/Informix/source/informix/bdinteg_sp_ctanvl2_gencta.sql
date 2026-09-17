CREATE PROCEDURE "informix".sp_ctanvl2_gencta( pNumCte CHAR(20) )
RETURNING CHAR(5)   AS codret,
          CHAR(20)  AS numcta,
          CHAR(18)  AS ctaclabe,
          CHAR(2)   AS ctenuevo,
          CHAR(104) AS nombrecte,
          CHAR(10)  AS fechanac,
          CHAR(10)  AS telmovil,
		  CHAR (1)	AS genfolio;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE dFecha DATE;
	DEFINE dUltPagoCap DATE;
	DEFINE dUltPagoInt DATE;
	DEFINE cExiste CHAR(1);
	DEFINE cTipoCte CHAR(1);
	DEFINE cTipoPersona CHAR(2);
	DEFINE cEsFisica CHAR(1);
	DEFINE cMarcaRet CHAR(1);
	DEFINE cPlaza CHAR(3);
	DEFINE iLongCta SMALLINT;
	DEFINE cPagoInteres CHAR(1);
	DEFINE dFechaIniApe DATETIME MONTH TO DAY;
	DEFINE dFechaFinApe DATETIME MONTH TO DAY;
	DEFINE cTpCteValido CHAR(5);
	DEFINE cIdCta CHAR(1);
	DEFINE cTipoCte1 CHAR(1);
	DEFINE cTipoCte2 CHAR(1);
	DEFINE cTipoCte3 CHAR(1);
	DEFINE cTipoCte4 CHAR(1);
	DEFINE cTipoCte5 CHAR(1);
	DEFINE dFecha_ini DATE;
	DEFINE dFecha_fin DATE;
	DEFINE cParamSigCta CHAR(20);
	DEFINE iSigNumCta INTEGER;
	DEFINE iDiferencia SMALLINT;
	DEFINE i SMALLINT;
	DEFINE cDigVerif CHAR(1);
	DEFINE cNumCta CHAR(20);
	DEFINE cCtaClabe CHAR(18);
	
	--
	DEFINE cSucursal CHAR(4);
	DEFINE cProducto CHAR(4);
    DEFINE cEjecutivo CHAR(8);
    DEFINE iExisCtaNvl2 SMALLINT;
    DEFINE cNombreCte CHAR(104);
    DEFINE cFechaNac CHAR(10);
    DEFINE cTelMovil CHAR(10);
    DEFINE dFechaInsert DATE;
    DEFINE cCteNuevo CHAR(2);
	DEFINE cEmail CHAR(100);
	DEFINE cNombre CHAR(26);
	DEFINE cApellido CHAR(26);
	--
	DEFINE vcodret CHAR(5);
	DEFINE vFolio  CHAR(12);
	DEFINE vmensaje CHAR(6);
	DEFINE vgenfolio CHAR(1);
	DEFINE iExisFolio SMALLINT;
	
	DEFINE vFechInicio DATETIME YEAR TO FRACTION(5);
	DEFINE vFechFin DATETIME YEAR TO FRACTION(5);
	DEFINE vExiCta  INTEGER;
	
	--Cancelacion apertura clientes prospectos
	DEFINE vtipo_cliente CHAR(1);
	
	LET cCodRet = '000';
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET dFecha = '';
	LET dUltPagoCap = '';
	LET dUltPagoInt = '';
	LET cExiste = '';
	LET cTipoCte = '';
	LET cTipoPersona = '';
	LET cEsFisica = '';
	LET cMarcaRet = '0';
	LET cPlaza = '';
	LET iLongCta = 0;
	LET cPagoInteres = '';
	LET dFechaIniApe = '';
	LET dFechaFinApe = '';
	LET cTpCteValido = '';
	LET cIdCta = '';
	LET cTipoCte1 = '';
	LET cTipoCte2 = '';
	LET cTipoCte3 = '';
	LET cTipoCte4 = '';
	LET cTipoCte5 = '';
	LET dFecha_ini = '';
	LET dFecha_fin = '';
	LET cParamSigCta = '';
	LET iSigNumCta = '';
	LET iDiferencia = 0;
	LET i = 0;
	LET cDigVerif = '';
	LET cNumCta = '';
	LET cCtaClabe = '';
	--
	LET cSucursal = '5001';
	LET cProducto = '2900';
    LET cEjecutivo = USER;
    LET iExisCtaNvl2 = 0;
    LET cNombreCte = '';
    LET cFechaNac = '';
    LET cTelMovil = '';
    LET dFechaInsert = '';
    LET cCteNuevo = '';
	LET cEmail = '';
	
	LET vcodret = '';
	LET vFolio  = '';
	LET vmensaje= '';
	LET vgenfolio = 'F';
	LET iExisFolio = 0;
	
	LET vFechInicio = '';
	LET vFechFin = '';
	LET vExiCta = 0;
	
	--Cancelacion apertura clientes prospectos
	LET vtipo_cliente = "";

	BEGIN
	
    ON EXCEPTION SET iSqlErr
        IF iSqlerr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-243, -242)
        LET cExiste = '1';
        --- LET cCodRet = '411';
        --- RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil;
    END EXCEPTION WITH RESUME;
    
     --SET DEBUG FILE TO '/ifxsif01/Angel/sp_ctanvl2_gencta.out';
     --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
	
	------------------------------------------------------------------------------------------------------------
	---VALIDA SI EL CLIENTE ES PROSPECTO; SI SI ES SE LE CANCELA LA APERTURA DE CUENTA
	SELECT  count (*)--tipo_cliente
	INTO 	vtipo_cliente
	FROM	bdinteg:si_cliente
	WHERE 	numcte = pNumCte and tipo_cliente='2' and sucursal <> '5001' and fecha_alta <> today;
	
	IF vtipo_cliente = "1" THEN
		LET cCodRet = '127';
	--	ELSE
	--	LET cCodRet = '127';
		RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
	END IF;
	-------------------------------------------------------------------------------------------------------------
     
    --- VALIDA CAMPOS REQUERIDOS
    IF pNumCte IS NULL OR pNumCte = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF;
	
	SELECT COUNT(*)
	INTO   vExiCta 
	FROM   bdinteg:si_ctanvl2_ctrl
	WHERE  numcte = pNumCte
	AND    DATE (fechora_inicio ) = TODAY;
	
	IF  vExiCta = 1 THEN 
		--BANDERA DE INICO DE PROCESO (5) PARA DEPURACION  
		LET vFechInicio = CURRENT YEAR TO FRACTION(5);
		UPDATE bdinteg:si_ctanvl2_ctrl
		SET    proceso        =  5,
			   estatus        = 'I',
			   fechora_inicio = vFechInicio,
			   fechora_fin    = ""	  
		WHERE  numcte         = pNumCte;
	ELIF   
	    vExiCta = 0 THEN 
	    --BANDERA DE INICO DE PROCESO (1) PARA DEPURACION  
        LET vFechInicio = CURRENT YEAR TO FRACTION(5);
	    LET vFechFin    = "";
	    INSERT INTO bdinteg:si_ctanvl2_ctrl VALUES (pNumCte,'6','I',vFechInicio,vFechFin,"");
	END IF; 
		
		
    --- VALIDA SI EL CLIENTE EXISTE
    SELECT {+INDEX (bdinteg:si_cliente idx_si_cliente5)} 1, tipo_cliente, tpo_persona 
      INTO cExiste, cTipoCte, cTipoPersona
      FROM bdinteg:si_cliente
     WHERE empresa = cEmpresa 
       AND numcte = pNumCte;
	  
	  
	SELECT COUNT(*)
	INTO iExisFolio
	FROM bdinteg:"informix".si_bpiusuarios 
	WHERE numcte = pNumCte 
	AND id_status BETWEEN '10' and '98';
	
	IF iExisFolio > 0 THEN
		LET vgenfolio = 'F';
	ELSE
		LET vgenfolio = 'T';
		--SE INSERTA EL REGISTRO PARA IDENTIFICAR QUE CREO UN NUEVO FOLIO.
		LET vFechInicio = CURRENT YEAR TO FRACTION(5);
	    LET vFechFin    = CURRENT YEAR TO FRACTION(5);
	    INSERT INTO bdinteg:si_ctanvl2_ctrl VALUES (pNumCte,'7','F',vFechInicio,vFechFin,"");
	END IF;
	   
    IF cExiste IS NULL THEN
        LET cCodRet = '384';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF;
    
    --- VALIDA QUE EL CLIENTE NO TENGA UNA CUENTA NIVEL 2 ACTIVA
    SELECT COUNT(*)
      INTO iExisCtaNvl2
      FROM bdicheq:sc_maechq
     WHERE num_cte = pNumCte
       AND producto = cProducto
       AND status_cta IN('1','3','4','5', '6', '8');
       
    IF iExisCtaNvl2 > 0 THEN
        LET cCodRet = '388';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF; 
    
    --- VALIDA CLIENTE PRODUCTO
    EXECUTE PROCEDURE bdicheq:valcteprod( cEmpresa, pNumCte, cProducto )
    INTO cCodRetSp;
    
    IF cCodRetSp <> '000' THEN
        LET cCodRet = '386';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF;
    
    -- // OBTIENE FECHAS DEL SISTEMA
    SELECT {+INDEX (bdicheq:sc_fechas idx_fechas1)} fecha_hoy 
      INTO dFecha
      FROM bdicheq:sc_fechas
     WHERE empresa = cEmpresa;
    
    LET dUltPagoCap = dFecha;
    LET dUltPagoInt = dFecha;
    
    --- VALIDA TIPO DE PERSONA
    SELECT {+INDEX (bdinteg:si_tipper ix193_1)} UPPER(es_fisica) 
      INTO cEsFisica
      FROM bdinteg:si_tipper
     WHERE tpo_persona = cTipoPersona;
    
    IF cEsfisica IS NULL THEN
        LET cCodRet = '385';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    ELSE
        IF cEsFisica = 'N' THEN
            LET cMarcaRet = '1';
        ELSE
            LET cMarcaRet = '0';
        END IF;
    END IF;
	
	LET cMarcaRet = '1';
    
    -- // OBTIENE PARAMETROS
    SELECT valor
      INTO cSucursal
      FROM si_param
     WHERE cod_param = 491;
     
    SELECT valor
      INTO cProducto
      FROM si_param
     WHERE cod_param = 492;
    
    --- VALIDA SUCURSAL
    SELECT {+INDEX (bdinteg:si_sucursales idx_sucursal)} 1, plaza 
      INTO cExiste,cPlaza
      FROM bdinteg:si_sucursales
     WHERE sucursal = cSucursal;
    
    IF cExiste IS NULL THEN
        LET cCodRet = '111';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF;
    
    --- VALIDA LONGITUD DE LA CUENTA
    SELECT {+INDEX (bdicheq:sc_param idx_param1)} valor 
      INTO iLongCta
      FROM bdicheq:sc_param
     WHERE empresa = cEmpresa 
       AND codparam = 'longcta';
    
    IF iLongCta IS NULL THEN
        LET cCodRet = '105';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF;
    
    --- VALIDA PRODUCTO
    SELECT {+INDEX (bdicheq:sc_producto idx_producto1)} tipo_dias_calc, feciniape, fecfinape, tpcte_valido, manten_valor
      INTO cPagoInteres, dFechaIniApe, dFechaFinApe, cTpCteValido, cIdCta
      FROM bdicheq:sc_producto
     WHERE empresa = cEmpresa 
       AND producto = cProducto;
    
    --- VALIDA EL TIPO DE CLIENTE PERMITIDO
    LET cTpCteValido = RPAD(TRIM(cTpCteValido),5,'X');
    LET cTipoCte1 = SUBSTR(cTpCteValido,1,1);
    LET cTipoCte2 = SUBSTR(cTpCteValido,2,1);
    LET cTipoCte3 = SUBSTR(cTpCteValido,3,1);
    LET cTipoCte4 = SUBSTR(cTpCteValido,4,1);
    LET cTipoCte5 = SUBSTR(cTpCteValido,5,1);
    
    /*
    IF cTipoCte <> cTipoCte1 AND cTipoCte <> cTipoCte2 AND cTipoCte <> cTipoCte3 AND cTipoCte <> cTipoCte4 AND cTipoCte <> cTipoCte5 THEN
        LET cCodRet = '386';
        RETURN cCodRet, cNumCta, cCtaClabe;
    END IF
    */
    
    --- VALIDA EL PERIODO DE APERTURA DE LA CUENTA
    LET dFecha_ini = MDY(MONTH(dFechaIniApe),DAY(dFechaIniApe),YEAR(dFecha));
    LET dFecha_fin = MDY(MONTH(dFechaFinApe),DAY(dFechaFinApe),YEAR(dFecha));

    IF dFecha_ini > dFecha THEN
        LET dFecha_ini = dFecha_ini - 1 UNITS YEAR;
    END IF

    IF dFecha_fin <= dFecha_ini THEN
        LET dFecha_fin = dFecha_fin + 1 UNITS YEAR;
    END IF

    IF dFecha BETWEEN dFecha_ini AND dFecha_fin THEN
    ELSE
        LET cCodRet = '387';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF
    
    --- EXTRAE CONSECUTIVO DE ACUERDO AL PRODUCTO
    IF cProducto <= '2000' THEN
        LET cParamSigCta = 'signumcta'||TRIM(cIdCta);
    ELSE
        LET cParamSigCta = 'signumcta'||SUBSTR(cProducto,1,2);
    END IF;
	
	LET cExiste = '1';
	WHILE cExiste = '1'
	
		SET LOCK MODE TO WAIT 3;
		
		--- DETERMINA NUMERO DE CUENTA
		IF cNumCta IS NULL OR cNumCta = '' THEN
			SELECT {+INDEX (bdicheq:sc_param idx_param1)} valor 
			  INTO iSigNumCta
			  FROM bdicheq:sc_param
			 WHERE empresa = cEmpresa
			   AND codparam = TRIM(cParamSigCta);
			
			IF iSigNumCta IS NULL THEN
				LET cCodRet = '105';
				RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
			END IF;
			
			LET cNumCta = iSigNumCta;
			LET iSigNumCta = iSigNumCta + 1;
			
			UPDATE {+INDEX (bdicheq:sc_param idx_param1)} bdicheq:sc_param
			   SET valor = iSigNumCta
			 WHERE empresa = cEmpresa
			   AND codparam = TRIM(cParamSigCta);
			
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				--LET cCodRet = '222';
				--RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
			--END IF;
			
				LET iDiferencia = iLongCta - LENGTH(cNumCta) - 3;
			
				IF iDiferencia > 0 THEN
					FOR i = 1 TO iDiferencia
						LET cNumCta = '0'||cNumCta;
					END FOR;
				END IF;
			
				IF cProducto <= '2000' THEN
					LET cNumCta = '1'||TRIM(cIdCta)||TRIM(cNumCta);
				ELSE
					LET cNumCta = SUBSTR(cProducto,1,2)|| TRIM(cNumCta);
				END IF;
			
				CALL bdicheq:digver11( cNumCta )
				RETURNING cCodRetSp, cDigVerif;
			
				LET cNumCta = TRIM(cNumCta)||cDigVerif;
			
				SELECT 1 
				INTO cExiste
				FROM bdicheq:sc_maechq 
				WHERE cuenta = cNumCta;
				
			END IF;

			IF cExiste = 1 THEN
			   LET cNumCta = ' ';
			END IF;
		END IF;
	END WHILE;
    
    --- SE VALIDA QUE LA LONGITUD DE LA CUENTA SEA LA CORRECTA Y QUE SOLO SEAN NUMEROS
    IF LENGTH(cNumCta) = iLongCta AND bdinteg:val_num(cNumCta) THEN
        --SELECT 1 
        --  INTO cExiste
        --  FROM bdicheq:sc_maechq 
        -- WHERE cuenta = cNumCta;
        
        --IF cExiste IS NOT NULL THEN
            --LET cCodRet = '388';
            --RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
        --END IF;
        
        --- SE GENERA CUENTA CLABE
        CALL bdicheq:ctaclabe( cEmpresa, cNumCta, cSucursal )
        RETURNING cCodRetSp, cCtaClabe;
        
        IF cCodRetSp <> '000' THEN
            LET cCodRet = '389';
            RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
        END IF;
        
        INSERT INTO bdicheq:sc_maechq
        ( empresa, cuenta, sucursal, plaza, producto, num_cte, status_cta, motivo, ult_chq, colateral, fec_ult_mov, fec_cancelac, lim_chq_sbc, imp_chq_sbc, fech_alta_sbc,
          fech_venc_sbc, lim_chq_rem, imp_chq_rem, fech_alta_rem, fech_venc_rem, lim_sbg_ccc, imp_sbg_ccc, tipo_linea, fec_alta_ccc, fech_venc_ccc, imp_int_ccc,
          sdo_retenido, chq_exp_mes, chq_dev, monto_dev, chq_dev_obco, sdo_cong, num_cgos_mes, imp_cgos_mes, num_abonos_mes, imp_abonos_mes, sdo_actual, sdo_dia_ant,
          marca_ret, direcc_envio, com_pendiente, imp_chq_sbg, imp_int_sbg, fecha_proceso, cuenta_rel, saldo_sbc, fecultdep, fecultret, ultpagocap, ultpagoint, plazo,
          cobraisr, proced_aperturacta, proced_mantenercta, monto_mensual, depositos_cantidad, depositos_monto, retiros_cantidad, retiros_monto, cuenta_clabe )
        VALUES
        ( cEmpresa, cNumCta, cSucursal, cPlaza, cProducto, pNumCte, '1', ' ', 0, 'N', dFecha, ' ', 0, 0, ' ',
          ' ', 0, 0, ' ', ' ', 0, 0, '0', ' ', ' ', 0, 
          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
          cMarcaRet, 0, 0, 0, 0, ' ', ' ', 0, ' ', ' ', dUltPagoCap, dUltPagoInt, 0,
          ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', cCtaClabe );
        
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '379';
            RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
        END IF;
        
        INSERT INTO bdicheq:sc_maenoc
        ( empresa, cuenta, num_cot, clase_cta, reg_firmas, tipo_bca, ejecutivo, envio_direcc, porc_sdoprom_sbc, porc_sdoprom_rem, tasa_int_ccc, sobretasa_ccc,
          cta_en_legal, fec_tras_legal, dias_ccc, acum_ccc, dia_sdo_pos, acum_sdo_pos, sdo_prom_mesant, acum_sbc, acum_rem, sdo_mes_ant, adicionado, fecha_alta,
          modificado, fecha_mod, int_acum, isr_acum, capitalizacion, paga_interes, ret_mes_ant, cong_mes_ant, dias_acum_int, acum_sdo_int )
        VALUES
        ( cEmpresa, cNumCta, '00', ' ', ' ', ' ', cEjecutivo, ' ', 0, 0, ' ', 0,
          ' ', ' ', 0, 0, 0, 0, 0, 0, 0, 0, ' ', dFecha,
          ' ', ' ', 0, 0, ' ', ' ', 0, 0, 0, 0 );
        
        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '379';
            RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
        END IF;
       
        
        INSERT INTO bdicheq:sc_firmantes
        ( empresa, cuenta, secuencia, numcte, apellidos, nombre, reg_firma, tipo_firma, combinacion, parentesco )
        VALUES
        ( cEmpresa, cNumCta, 1, pNumCte, '', '', 'I', 'I', '', '' );
		
	    IF DBINFO('sqlca.sqlerrd2') = 0 THEN
            LET cCodRet = '379';
            RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
        END IF;
        
        /* #######################################################
		-- //   CREA FOLIO		
		EXECUTE PROCEDURE sp_obtfolioCN2 ('001')
		INTO vcodret,vFolio;
		
		--INSERTA REGISTRO A LA TABLA si_bpiusuarios
		EXECUTE PROCEDURE sp_acivarserviciobpi(
		'1',
		cEmpresa,
		pNumCte,
		10,
		vFolio,
		cSucursal,
		'transBPI',
		'127.0.0.3',
        	2)
		INTO vcodret, vmensaje;
        ####################################################### */
			
        --- SELECT NVL(TRIM(cte.nombre1),'')||' '||NVL(TRIM(cte.nombre2),'')||' '||NVL(TRIM(cte.apell_paterno),'')||' '||NVL(TRIM(cte.apell_materno),''),
        SELECT NVL(TRIM(cte.nombre1),''),
               TO_CHAR(cpf.fecha_nac, '%d/%m/%Y'), TRIM(tel.telefono), cte.fecha_insert, correo.correo_elec, NVL(TRIM(cte.nombre1),''), NVL(TRIM(cte.apell_paterno),'')
			   INTO cNombreCte, cFechaNac, cTelMovil, dFechaInsert, cEmail, cNombre, cApellido
          FROM bdinteg:si_cliente cte
         INNER JOIN bdinteg:si_ctepf cpf ON (cpf.numcte = cte.numcte)
          LEFT OUTER JOIN bdinteg:si_telefonos_actual tel ON (tel.numcte = cte.numcte AND tel.tipo_tel = 2 AND tel.status_tel = 'A')
		  LEFT OUTER JOIN bdinteg:si_correos correo ON(correo.numcte = cte.numcte AND correo.status_correo = 'A' AND correo.tipo_correo = 1) 
         WHERE cte.numcte = pNumCte;
		 
		-- // NOTIFICACION SMS
        --- EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CCTAS_CN2S','CTAS_CN2S','000000000','','','1','','','','','','','','','','','',cTelMovil,1,0,0,0,0,'','')
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CCTAS_CN2S','CTAS_CN2S','000000000','','','1','','','','','','',cNombre,cApellido,'','','',cTelMovil,1,0,0,0,0,'','')
  		INTO vcodret;
		
		-- //NOTIFICACION MAIL
        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CCTAS_CN2','CTAS_CN2','000000000',cNumCta,'','1','','','','','','App BanCoppel',cNombre,cApellido,'','',cEmail,'',1,0,0,0,0,CURRENT,'')		
		INTO vcodret;
         
        IF dFechaInsert = dFecha THEN
            LET cCteNuevo = 'SI';
        ELSE
            LET cCteNuevo = 'NO';
        END IF;
            
        /* ###############################################################################################
        -- // GENERACION DE DOCUMENTOS (CONTRATO, CARATULA, PORTADA)
        EXECUTE PROCEDURE sp_ctanvl2_generapdf(pNumCte, cNumCta)
        INTO cCodRetSp;
        
        IF cCodRetSp <> '000' THEN
            LET cCodRet = '174';
            RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil;
        END IF;
        ############################################################################################### */
    ELSE
        LET cCodRet = '390';
        RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
    END IF;
	
	IF  vExiCta = 1 THEN 
	    --BANDERA FINAL DEL PROCESO (5) PARA LA DEPURACION
	    LET vFechFin = CURRENT YEAR TO FRACTION(5);
	    UPDATE bdinteg:si_ctanvl2_ctrl
	    SET    estatus     = 'F',
	      	   fechora_fin = vFechFin	  
	    WHERE  numcte      = pNumCte
	    AND    proceso     = '5';
	
	ELIF vExiCta = 0 THEN 
	   --BANDERA FINAL DEL PROCESO (5) PARA LA DEPURACION
	   LET vFechFin = CURRENT YEAR TO FRACTION(5);
	   UPDATE bdinteg:si_ctanvl2_ctrl
	   SET    estatus     = 'F',
	     	   fechora_fin = vFechFin	  
	   WHERE  numcte      = pNumCte
	   AND    proceso     = '6';
	 END IF; 
	
	
    RETURN cCodRet, cNumCta, cCtaClabe, cCteNuevo, cNombreCte, cFechaNac, cTelMovil, vgenfolio;
		
	END;
    
END PROCEDURE;