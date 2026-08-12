CREATE PROCEDURE "informix".sp_encabezadoreportetransaccionesprogramadas(p_NumCte CHAR(20), p_cve_pagoprog CHAR(10), p_TipoRep SMALLINT)
RETURNING
     CHAR(5), ---cod_ret
     CHAR(20), ---num cliente
     CHAR(70), ---nombre cliente
     CHAR(20), ---descripcion
     DATE, ---fecha programacion
     CHAR(8), ---hora de la programcion
     CHAR(30), ---canal programacion
     CHAR(40), ---cuenta origen
     CHAR(30), ---tipo cuenta origen
     CHAR(60), ---nombre beneficiario
     CHAR(40), ---banco receptor
     CHAR(20), ---cuenta destino
     CHAR(60), ---concepto pago
     MONEY(16,2), ---Importe
     MONEY(16,2), ---ImporteIva
     CHAR(40), ---referencia1
     CHAR(20), ---referencia2
     DATE, ---fecha pago programacion
     CHAR(70), ---tipo pago
     CHAR(30), ---notificacion
     CHAR(30), ---notificacion2
     CHAR(30), ---estado
     DATE, ---fecha de cancelacion
	 CHAR(4);
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
    DEFINE vDesErr              CHAR(60);
    DEFINE v_NumCte             CHAR(20);
    DEFINE v_NomCte             CHAR(70);
    DEFINE v_Descripcion        CHAR(20);
    DEFINE v_FechaProg          DATE;
    DEFINE v_HoraProg           CHAR(8);
    DEFINE v_Canal              CHAR(30);
    DEFINE v_CtaOrigen          CHAR(40);
    DEFINE v_TipoCtaOrigen      CHAR(30);
    DEFINE v_NomBeneficiario    CHAR(60);
    DEFINE v_BancoReceptor      CHAR(40);
    DEFINE v_CtaDestino         CHAR(20);
    DEFINE v_ConceptoPago       CHAR(60);
    DEFINE v_Importe            MONEY(16,2);
    DEFINE v_ImporteIva         MONEY(16,2);
    DEFINE v_Referencia1        CHAR(40);
    DEFINE v_Referencia2        CHAR(20);
    DEFINE v_FechaPagoProg      DATE;
    DEFINE v_TipoPago           CHAR(70);
    DEFINE v_Notificacion       CHAR(30);
    DEFINE v_Notificacion2      CHAR(30);
    DEFINE v_Estado             CHAR(30);
    DEFINE v_FechaCanc          DATE;
	DEFINE v_CvePago            CHAR(2);
	DEFINE v_HoraPago			CHAR(4);
	DEFINE cHoraActual			DATETIME HOUR TO SECOND;
--- Declaraciones
    LET v_cod_ret            = "000000";
    LET iSqlErr              = 0;
    LET iSamErr              = 0;
    LET vDesErr              = "";
    LET v_NumCte             = "";
    LET v_NomCte             = "";
    LET v_Descripcion        = "";
    LET v_FechaProg          = "";
    LET v_HoraProg           = "00:00:00";
    LET v_Canal              = "";
    LET v_CtaOrigen          = "";
    LET v_TipoCtaOrigen      = "";
    LET v_NomBeneficiario    = "";
    LET v_BancoReceptor      = "";
    LET v_CtaDestino         = "";
    LET v_ConceptoPago       = "";
    LET v_Importe            = 0;
    LET v_ImporteIva         = 0;
    LET v_Referencia1        = "";
    LET v_Referencia2        = "";
    LET v_FechaPagoProg      = "";
    LET v_TipoPago           = "";
    LET v_Notificacion       = "";
    LET v_Notificacion2      = "";
    LET v_Estado             = "";
    LET v_FechaCanc          = "";
	LET v_CvePago            = "";
	LET v_HoraPago			 = "";

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_encabezadorep.out";
    --TRACE ON;

	---Obtiene la hora de ejecucion de pagos programados
	SELECT TRIM(valor) INTO v_HoraPago FROM bdiprog:pp_parametros where cve_param = '21';
	
    --Obtiene la notificacion del emisor
    SELECT tp.descripcion AS DESCNOTIFICACION2
    INTO v_Notificacion2
    FROM bdiprog: pp_pagoprog pp, bdiprog: pp_tpnotifica tp
    WHERE pp.cve_pagoprog = p_cve_pagoprog
    AND pp.num_cte = p_NumCte
    AND pp.cve_notifica_emi = tp.cve_notifica;


    IF p_TipoRep = 2 THEN
    --- CONSULTA DE TRANSACCIONES PROGRAMADAS
		IF  EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog WHERE num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND cve_pago = '01') THEN
			SELECT {+INDEX(si_bancos idx_banco)}
					pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
	               , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA
				   , TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMBENEFICIARIO, b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
                   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS
	        INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
                , v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado
	        FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
	              , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
	        WHERE  pp.cve_pagoprog = p_cve_pagoprog
	        AND pp.num_cte = p_NumCte
	        AND pp.num_cte = c.numcte
	        AND pp.cve_canal = can.cve_canal
	        AND pp.cve_cuenta_ori = cta.cve_cuenta
	        AND pp.banco_destino = b.banco
	        AND pp.cve_pago = p.cve_pago
	        AND pp.cve_notifica = n.cve_notifica
	        AND pp.cve_estado = e.cve_estado;
		ELSE
		    IF  EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct WHERE pp.num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco) THEN 
			    SELECT cve_pago 
				INTO v_CvePago 
				FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct 
				WHERE pp.num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco;

                IF v_CvePago <> '04' THEN
				    SELECT {+INDEX(si_bancos idx_banco)}
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
					   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ct.nombre AS NOMBENEFICIARIO, b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
					   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS
					INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,
						v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_ctasterceros ct, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta, 
						  bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
					WHERE pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ct.num_cte
					AND pp.cuenta_destino = ct.cuenta
					AND pp.banco_destino = ct.cve_banco
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					AND pp.banco_destino = b.banco
					AND pp.cve_pago = p.cve_pago 
					AND pp.cve_notifica = n.cve_notifica 
					AND pp.cve_estado = e.cve_estado;
				ELSE
					SELECT pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
						   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ct.nombre AS NOMBENEFICIARIO, '000 NO APLICA' AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
						   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS
					INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe,
						 v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_ctasterceros ct, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
					  , bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
					WHERE  pp.cve_pagoprog = p_cve_pagoprog AND pp.num_cte = p_NumCte 
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ct.num_cte
					AND pp.cuenta_destino = ct.cuenta
					--AND pp.banco_destino = ct.cve_banco
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					--AND pp.banco_destino = '000'
					AND pp.cve_pago = p.cve_pago 
					AND pp.cve_notifica = n.cve_notifica 
					AND pp.cve_estado = e.cve_estado; 
			     END IF     				
			
			ELSE
				IF  EXISTS(
					SELECT {+INDEX(si_bancos idx_banco)}
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION,
					   pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ta.nombre AS NOMBENEFICIARIO, 
					   b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE, pp.importe_iva AS IMPORTEIVA, 
					   pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, 
					   e.descripcion AS DESCESTADOS					   
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdicred: sd_tarjeta ta, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta, bdinteg: si_bancos b, 
							  bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ta.numcte
					AND pp.cuenta_destino = ta.num_tarjeta
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					AND pp.banco_destino = b.banco 
					AND pp.cve_pago = p.cve_pago 
					AND pp.cve_notifica = n.cve_notifica 
					AND pp.cve_estado = e.cve_estado)THEN
				    
					 SELECT {+INDEX(si_bancos idx_banco)}
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION,
					   pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ta.nombre AS NOMBENEFICIARIO, 
					   b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE, pp.importe_iva AS IMPORTEIVA, 
					   pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, 
					   e.descripcion AS DESCESTADOS
				INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
					, v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado					   
				FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdicred: sd_tarjeta ta, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta, bdinteg: si_bancos b, 
							  bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
				WHERE  pp.cve_pagoprog = p_cve_pagoprog
				AND pp.num_cte = p_NumCte
				AND pp.num_cte = c.numcte
				AND pp.num_cte = ta.numcte
				AND pp.cuenta_destino = ta.num_tarjeta
				AND pp.cve_canal = can.cve_canal
				AND pp.cve_cuenta_ori = cta.cve_cuenta
				AND pp.banco_destino = b.banco 
				AND pp.cve_pago = p.cve_pago 
				AND pp.cve_notifica = n.cve_notifica 
				AND pp.cve_estado = e.cve_estado;
				ELSE
					LET v_cod_ret = '10142';
					--LET vcMsgError = 'CLAVE DE PROGRAMACION NO EXISTE, ERROR AL IMPRIMIR COMPROBANTE DE CONSULTA TRANSACCION PROGRAMADA, CLIENTE: ' ||p_NumCte ||', CLAVE DE PROGRAMACION: ' || p_cve_pagoprog;
					LET cHoraActual = CURRENT HOUR TO SECOND;
		
					INSERT INTO bdiprog:pp_errores(cod_error,descripcion,fecha,hora)
					VALUES (v_cod_ret,'[ERTP]NO SE ENCONTRO REGISTRO DE ENCABEZADO, CONSULTA DE PROGRAMACION, T. REPORTE: -'|| p_TipoRep ||'-, CTE: -' ||p_NumCte ||'-, CLAVE:-' || p_cve_pagoprog ||'-',CURRENT::DATE,cHoraActual);
				
				END IF
			 
			 END IF
			 
		END IF

        IF v_NumCte IS NULL THEN
            LET v_NumCte = '' ;
        END IF
        IF v_NomCte IS NULL THEN
            LET v_NomCte = '' ;
        END IF
        IF v_Descripcion IS NULL THEN
            LET v_Descripcion = '' ;
        END IF
        IF v_FechaProg IS NULL THEN
            LET v_FechaProg = '01/01/1900' :: DATE;
        END IF
        IF v_HoraProg IS NULL THEN
            LET v_HoraProg = '' ;
        END IF
        IF v_Canal IS NULL THEN
            LET v_Canal = '' ;
        END IF
        IF v_CtaOrigen IS NULL THEN
            LET v_CtaOrigen = '' ;
        END IF
        IF v_TipoCtaOrigen IS NULL THEN
            LET v_TipoCtaOrigen = '' ;
        END IF
        IF v_NomBeneficiario IS NULL THEN
            LET v_NomBeneficiario = '' ;
        END IF
        IF v_BancoReceptor IS NULL THEN
            LET v_BancoReceptor = '' ;
        END IF
        IF v_CtaDestino IS NULL THEN
            LET v_CtaDestino = '' ;
        END IF
        IF v_ConceptoPago IS NULL THEN
            LET v_ConceptoPago = '' ;
        END IF
        IF v_Importe IS NULL THEN
            LET v_Importe = 0 ;
        END IF
        IF v_ImporteIva IS NULL THEN
            LET v_ImporteIva = 0 ;
        END IF
        IF v_Referencia1 IS NULL THEN
            LET v_Referencia1 = '' ;
        END IF
        IF v_Referencia2 IS NULL THEN
            LET v_Referencia2 = '' ;
        END IF
        IF v_FechaPagoProg IS NULL THEN
            LET v_FechaPagoProg = '01/01/1900' :: DATE;
        END IF
        IF v_TipoPago IS NULL THEN
            LET v_TipoPago = '' ;
        END IF
        IF v_Notificacion IS NULL THEN
            LET v_Notificacion = '' ;
        END IF
        IF v_Notificacion2 IS NULL THEN
            LET v_Notificacion2 = '' ;
        END IF
        IF v_Estado IS NULL THEN
            LET v_Estado = '' ;
        END IF
        IF v_FechaCanc IS NULL THEN
            LET v_FechaCanc = '01/01/1900' :: DATE;
        END IF

        RETURN v_cod_ret, v_NumCte, v_NomCte,v_Descripcion, v_FechaProg, v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago
            ,v_Importe,v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Notificacion2,v_Estado,'01/01/1900' :: DATE,v_HoraPago;

    ELIF p_TipoRep = 3 THEN
    --- CANCELACION DE TRANSACIONES PROGRAMADAS
		IF  EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog WHERE num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND cve_pago = '01') THEN
			SELECT {+INDEX(si_bancos idx_banco)}
					pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
	               , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMBENEFICIARIO
				   , b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
	               , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS, pp.fecha_cancela AS FECHACANCELA
	        INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
	            , v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado,v_FechaCanc
	        FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
	              , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
	        WHERE  pp.cve_pagoprog = p_cve_pagoprog
	        AND pp.num_cte = p_NumCte
	        AND pp.num_cte = c.numcte
	        AND pp.cve_canal = can.cve_canal
	        AND pp.cve_cuenta_ori = cta.cve_cuenta
	        AND pp.banco_destino = b.banco
	        AND pp.cve_pago = p.cve_pago
	        AND pp.cve_notifica = n.cve_notifica
	        AND pp.cve_estado = e.cve_estado;
		ELSE
		    IF  EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct WHERE pp.num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco) THEN  
			    SELECT cve_pago 
				INTO v_CvePago 
				FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct 
				WHERE pp.num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco;

                IF v_CvePago <> '04' THEN
					SELECT {+INDEX(si_bancos idx_banco)}
							pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
						   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ct.nombre AS NOMBENEFICIARIO, b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
						   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS, pp.fecha_cancela AS FECHACANCELA
					INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
						, v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado,v_FechaCanc
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_ctasterceros ct, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
						  , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ct.num_cte
					AND pp.cuenta_destino = ct.cuenta
					AND pp.banco_destino = ct.cve_banco
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					AND pp.banco_destino = b.banco
					AND pp.cve_pago = p.cve_pago
					AND pp.cve_notifica = n.cve_notifica
					AND pp.cve_estado = e.cve_estado;
					---AND pp.cve_estado = '02';
				ELSE
				     SELECT pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
						   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ct.nombre AS NOMBENEFICIARIO, '000 NO APLICA' AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
						   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS, pp.fecha_cancela AS FECHACANCELA
					INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
						, v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado,v_FechaCanc
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_ctasterceros ct, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
						  , bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ct.num_cte
					AND pp.cuenta_destino = ct.cuenta
					--AND pp.banco_destino = ct.cve_banco
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					--AND pp.banco_destino = '000'
					AND pp.cve_pago = p.cve_pago
					AND pp.cve_notifica = n.cve_notifica
					AND pp.cve_estado = e.cve_estado;

                END IF 				
			ELSE
			    IF EXISTS(
					SELECT {+INDEX(si_bancos idx_banco)}
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
					   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ta.nombre AS NOMBENEFICIARIO, b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
					   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS, pp.fecha_cancela AS FECHACANCELA
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdicred: sd_tarjeta ta, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
					  , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ta.numcte
					AND pp.cuenta_destino = ta.num_tarjeta
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					AND pp.banco_destino = b.banco
					AND pp.cve_pago = p.cve_pago
					AND pp.cve_notifica = n.cve_notifica
					AND pp.cve_estado = e.cve_estado) THEN
				
				SELECT {+INDEX(si_bancos idx_banco)}
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
					   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS DESCCTA, ta.nombre AS NOMBENEFICIARIO, b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
					   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, pp.fecha_inicio AS FECPAGOPROG, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION, e.descripcion AS DESCESTADOS, pp.fecha_cancela AS FECHACANCELA
				INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
					, v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Estado,v_FechaCanc
				FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdicred: sd_tarjeta ta, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
					  , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n, bdiprog:pp_estados e
				WHERE  pp.cve_pagoprog = p_cve_pagoprog
				AND pp.num_cte = p_NumCte
				AND pp.num_cte = c.numcte
				AND pp.num_cte = ta.numcte
				AND pp.cuenta_destino = ta.num_tarjeta
				AND pp.cve_canal = can.cve_canal
				AND pp.cve_cuenta_ori = cta.cve_cuenta
				AND pp.banco_destino = b.banco
				AND pp.cve_pago = p.cve_pago
				AND pp.cve_notifica = n.cve_notifica
				AND pp.cve_estado = e.cve_estado;
				ELSE 
				
					LET v_cod_ret = '10142';
					--LET vcMsgError = 'CLAVE DE PROGRAMACION NO EXISTE, ERROR AL IMPRIMIR COMPROBANTE DE CONSULTA TRANSACCION PROGRAMADA, CLIENTE: ' ||p_NumCte ||', CLAVE DE PROGRAMACION: ' || p_cve_pagoprog;
					LET cHoraActual = CURRENT HOUR TO SECOND;
		
					INSERT INTO bdiprog:pp_errores(cod_error,descripcion,fecha,hora)
					VALUES (v_cod_ret,'[ERTP]NO SE ENCONTRO REGISTRO DE ENCABEZADO, CANCELACION DE PROGRAMACION, T. REPORTE: -'|| p_TipoRep ||'-, CTE: -' ||p_NumCte ||'-, CLAVE:-' || p_cve_pagoprog ||'-',CURRENT::DATE,cHoraActual);
				
				END IF			
			
			END IF 
			
		END IF

        IF v_NumCte IS NULL THEN
            LET v_NumCte = '' ;
        END IF
        IF v_NomCte IS NULL THEN
            LET v_NomCte = '' ;
        END IF
        IF v_Descripcion IS NULL THEN
            LET v_Descripcion = '' ;
        END IF
        IF v_FechaProg IS NULL THEN
            LET v_FechaProg = '01/01/1900' :: DATE;
        END IF
        IF v_HoraProg IS NULL THEN
            LET v_HoraProg = '' ;
        END IF
        IF v_Canal IS NULL THEN
            LET v_Canal = '' ;
        END IF
        IF v_CtaOrigen IS NULL THEN
            LET v_CtaOrigen = '' ;
        END IF
        IF v_TipoCtaOrigen IS NULL THEN
            LET v_TipoCtaOrigen = '' ;
        END IF
        IF v_NomBeneficiario IS NULL THEN
            LET v_NomBeneficiario = '' ;
        END IF
        IF v_BancoReceptor IS NULL THEN
            LET v_BancoReceptor = '' ;
        END IF
        IF v_CtaDestino IS NULL THEN
            LET v_CtaDestino = '' ;
        END IF
        IF v_ConceptoPago IS NULL THEN
            LET v_ConceptoPago = '' ;
        END IF
        IF v_Importe IS NULL THEN
            LET v_Importe = 0 ;
        END IF
        IF v_ImporteIva IS NULL THEN
            LET v_ImporteIva = 0 ;
        END IF
        IF v_Referencia1 IS NULL THEN
            LET v_Referencia1 = '' ;
        END IF
        IF v_Referencia2 IS NULL THEN
            LET v_Referencia2 = '' ;
        END IF
        IF v_FechaPagoProg IS NULL THEN
            LET v_FechaPagoProg = '01/01/1900' :: DATE;
        END IF
        IF v_TipoPago IS NULL THEN
            LET v_TipoPago = '' ;
        END IF
        IF v_Notificacion IS NULL THEN
            LET v_Notificacion = '' ;
        END IF
        IF v_Estado IS NULL THEN
            LET v_Estado = '' ;
        END IF
        IF v_FechaCanc IS NULL THEN
            LET v_FechaCanc = '01/01/1900' :: DATE;
        END IF

        RETURN v_cod_ret, v_NumCte, v_NomCte,v_Descripcion, v_FechaProg, v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago
            ,v_Importe,v_ImporteIva,v_Referencia1,v_Referencia2, v_FechaPagoProg,v_TipoPago,v_Notificacion,v_Notificacion2,v_Estado,v_FechaCanc,v_HoraPago;
    ELIF p_TipoRep = 1 THEN
    --- COMPROBANTE DE TRANSACCIONES PROGRAMADAS
		IF  EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog WHERE num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND cve_pago = '01') THEN
			SELECT {+INDEX(si_bancos idx_banco)}
					pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
	               , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS NOMBENEFICIARIO
				   , TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno), b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
	               , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION
	        INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
	            , v_ImporteIva,v_Referencia1,v_Referencia2, v_TipoPago,v_Notificacion
	        FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
	              , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n
	        WHERE  pp.cve_pagoprog = p_cve_pagoprog
	        AND pp.num_cte = p_NumCte
	        AND pp.num_cte = c.numcte
	        AND pp.cve_canal = can.cve_canal
	        AND pp.cve_cuenta_ori = cta.cve_cuenta
	        AND pp.banco_destino = b.banco
	        AND pp.cve_pago = p.cve_pago
	        AND pp.cve_notifica = n.cve_notifica;
		ELSE
		    IF  EXISTS(SELECT cve_pago FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct WHERE pp.num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco) THEN 
			    SELECT cve_pago 
				INTO v_CvePago 
				FROM bdiprog:pp_pagoprog pp, bdiprog: pp_ctasterceros ct 
				WHERE pp.num_cte = p_NumCte AND cve_pagoprog = p_cve_pagoprog AND pp.num_cte = ct.num_cte AND pp.cuenta_destino = ct.cuenta AND pp.banco_destino = ct.cve_banco;

                IF v_CvePago <> '04' THEN
					SELECT {+INDEX(si_bancos idx_banco)}
							pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
						   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS NOMBENEFICIARIO, ct.nombre, b.descripcion AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
						   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION
					INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
						, v_ImporteIva,v_Referencia1,v_Referencia2, v_TipoPago,v_Notificacion
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_ctasterceros ct, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
						  , bdinteg: si_bancos b, bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ct.num_cte
					AND pp.cuenta_destino = ct.cuenta
					AND pp.banco_destino = ct.cve_banco
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					AND pp.banco_destino = b.banco
					AND pp.cve_pago = p.cve_pago
					AND pp.cve_notifica = n.cve_notifica;
				ELSE
				    SELECT pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION
						   , pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS NOMBENEFICIARIO, ct.nombre, '000 NO APLICA' AS DESCBANCO, pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE
						   , pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, pp.referencia2 AS REFERENCIA2, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION
					INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
					    , v_ImporteIva,v_Referencia1,v_Referencia2, v_TipoPago,v_Notificacion
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdiprog: pp_ctasterceros ct, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta
						  , bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte 
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ct.num_cte
					AND pp.cuenta_destino = ct.cuenta
					--AND pp.banco_destino = ct.cve_banco
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					--AND pp.banco_destino = '000'
					AND pp.cve_pago = p.cve_pago
					AND pp.cve_notifica = n.cve_notifica;
                END IF 				
				
			ELSE
			    
					IF EXISTS(
					SELECT {+INDEX(si_bancos idx_banco)}
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION, 
						pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS NOMBENEFICIARIO, ta.nombre, b.descripcion AS DESCBANCO, 
						pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE, pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, 
						pp.referencia2 AS REFERENCIA2, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION
					FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdicred: sd_tarjeta ta, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta, bdinteg: si_bancos b, 
							 bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n
					WHERE  pp.cve_pagoprog = p_cve_pagoprog
					AND pp.num_cte = p_NumCte
					AND pp.num_cte = c.numcte
					AND pp.num_cte = ta.numcte
					AND pp.cuenta_destino = ta.num_tarjeta
					AND pp.cve_canal = can.cve_canal
					AND pp.cve_cuenta_ori = cta.cve_cuenta
					AND pp.banco_destino = b.banco 
					AND pp.cve_pago = p.cve_pago 
					AND pp.cve_notifica = n.cve_notifica)THEN
				
				  SELECT {+INDEX(si_bancos idx_banco)} 
						pp.num_cte AS NUMCTE, TRIM(c.nombre1) || "  " || TRIM(c.nombre2) || "  " || TRIM(c.apell_paterno) || "  " || TRIM(c.apell_materno) AS NOMCTE, pp.descripcion AS DESCRIPCION, 
						pp.fecha_insert AS FECPROG, can.descripcion AS DESCCANAL, pp.cuenta_origen AS CTAORIG, cta.descripcion AS NOMBENEFICIARIO, ta.nombre, b.descripcion AS DESCBANCO, 
						pp.cuenta_destino AS CTADESTINO, pp.concepto AS CONCEPTO, pp.importe AS IMPORTE, pp.importe_iva AS IMPORTEIVA, pp.referencia1 AS REFERENCIA1, 
						pp.referencia2 AS REFERENCIA2, p.descripcion AS DESCPAGO, n.descripcion AS DESCNOTIFICACION
				INTO v_NumCte, v_NomCte,v_Descripcion, v_FechaProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago,v_Importe
					, v_ImporteIva,v_Referencia1,v_Referencia2, v_TipoPago,v_Notificacion		
				FROM  bdiprog: pp_pagoprog pp,  bdinteg:si_cliente c, bdicred: sd_tarjeta ta, bdiprog: pp_tpcanal can, bdiprog: pp_tpcuenta cta, bdinteg: si_bancos b, 
							 bdiprog: pp_tppago p, bdiprog: pp_tpnotifica n
				WHERE  pp.cve_pagoprog = p_cve_pagoprog
				AND pp.num_cte = p_NumCte
				AND pp.num_cte = c.numcte
				AND pp.num_cte = ta.numcte
				AND pp.cuenta_destino = ta.num_tarjeta
				AND pp.cve_canal = can.cve_canal
				AND pp.cve_cuenta_ori = cta.cve_cuenta
				AND pp.banco_destino = b.banco 
				AND pp.cve_pago = p.cve_pago 
				AND pp.cve_notifica = n.cve_notifica;
					
				ELSE
				
					LET v_cod_ret = '10142';					
					LET cHoraActual = CURRENT HOUR TO SECOND;
		
					INSERT INTO bdiprog:pp_errores(cod_error,descripcion,fecha,hora)
					VALUES (v_cod_ret,'[ERTP]NO SE ENCONTRO REGISTRO DE ENCABEZADO, ALTA DE PROGRAMACION, T. REPORTE: -'|| p_TipoRep ||'-, CTE: -' ||p_NumCte ||'-, CLAVE:-' || p_cve_pagoprog ||'-',CURRENT::DATE,cHoraActual);
	
				END IF 			
			
			END IF 	
				
		END IF

        IF v_NumCte IS NULL THEN
            LET v_NumCte = '' ;
        END IF
        IF v_NomCte IS NULL THEN
            LET v_NomCte = '' ;
        END IF
        IF v_Descripcion IS NULL THEN
            LET v_Descripcion = '' ;
        END IF
        IF v_FechaProg IS NULL THEN
            LET v_FechaProg = '01/01/1900' :: DATE;
        END IF
        IF v_HoraProg IS NULL THEN
            LET v_HoraProg = '' ;
        END IF
        IF v_Canal IS NULL THEN
            LET v_Canal = '' ;
        END IF
        IF v_CtaOrigen IS NULL THEN
            LET v_CtaOrigen = '' ;
        END IF
        IF v_TipoCtaOrigen IS NULL THEN
            LET v_TipoCtaOrigen = '' ;
        END IF
        IF v_NomBeneficiario IS NULL THEN
            LET v_NomBeneficiario = '' ;
        END IF
        IF v_BancoReceptor IS NULL THEN
            LET v_BancoReceptor = '' ;
        END IF
        IF v_CtaDestino IS NULL THEN
            LET v_CtaDestino = '' ;
        END IF
        IF v_ConceptoPago IS NULL THEN
            LET v_ConceptoPago = '' ;
        END IF
        IF v_Importe IS NULL THEN
            LET v_Importe = 0 ;
        END IF
        IF v_ImporteIva IS NULL THEN
            LET v_ImporteIva = 0 ;
        END IF
        IF v_Referencia1 IS NULL THEN
            LET v_Referencia1 = '' ;
        END IF
        IF v_Referencia2 IS NULL THEN
            LET v_Referencia2 = '' ;
        END IF
        IF v_TipoPago IS NULL THEN
            LET v_TipoPago = '' ;
        END IF
        IF v_Notificacion IS NULL THEN
            LET v_Notificacion = '' ;
        END IF
        IF v_Estado IS NULL THEN
            LET v_Estado = '' ;
        END IF

        RETURN v_cod_ret, v_NumCte, v_NomCte,v_Descripcion, v_FechaProg, v_HoraProg,v_Canal,v_CtaOrigen,v_TipoCtaOrigen,v_NomBeneficiario,v_BancoReceptor,v_CtaDestino,v_ConceptoPago
            ,v_Importe,v_ImporteIva,v_Referencia1,v_Referencia2, '01/01/1900' :: DATE,v_TipoPago,v_Notificacion,v_Notificacion2,v_Estado,'01/01/1900' :: DATE,v_HoraPago;

    END IF

END;
--##############################################################################
--## Procedimiento   : sp_EncabezadoReporteTransaccionesProgramadas
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--## Descripcion     : Consulta  la programacion general para el reporte de consulta, cancelacion y comprobante de transacciones
--## Modifico        : Jesus Montoya, Saul Ivanhoe
--## Fecha           : 24-Feb-2009
--## Descripcion     : Se agrega para que obtenga la notificacion del Emisor, Obtiene las cuentas propias de credito del cliente 
--## Modifico        : Alejandro Osuna
--## Fecha           : 26-May-2009
--## Descripcion     : Se agrega para que obtenga la hora de ejecucion de las trasaccciones, v_HoraPago
--##############################################################################
END PROCEDURE
DOCUMENT
'AUTOR : José Angel Rodriguez',
'MODIFICACION: Se modifica para que cuando no existan registros asociados a la clave de programacion y cliente recibido como parámetro .',
'             el SP regrese un codigo de retorno indicando el estado del proceso',
'             las caracteristicas de las mismas solicitadas por la misma empresa ',
'EQUIPO DE TRABAJO: Incidencias',
'EJECUTADO O LLAMADO POR: PLPAGPRO.EXE',
'FECHA : 04/NOV/2009',
'VERSION: 20091104.1636',
'AUTOR : FRG',
'MODIFICACION: Se agrega busqueda por indice a la tabla bdinteg:si_bancos',
'FECHA : 20/FEB/2012',
'VERSION: 20120220.1204',
'BD    : bdiprog';

CREATE PROCEDURE "informix".sp_consultarprogramaciongeneral_bpi(p_empresa Char(3),p_snum_cte Char(20),p_sestado Char(2), pDesde INTEGER, pHasta INTEGER)
      RETURNING   CHAR(5),    --Código Retorno
                        CHAR(250),  --Mensaje Retorno
                        CHAR(10),   --Clave de Pago de Programación
                        CHAR(2),    --Clave de Estado
                        CHAR(20),   --Concepto de Pago
                        DATE,       --Fecha Programación
                        CHAR(30),   --Frecuencia
                        MONEY(16,2),--Monto
                        DATE,       --Fecha Inicio
                        CHAR(40),   --Canal Programación
                        CHAR(20),   --Cuenta Destino
                        CHAR(60),   --Beneficiario
                        CHAR(40),   --Banco
                        CHAR(20),   --Cuenta Origen
                        CHAR(70),   --Tipo Operación
                        CHAR(40),   --Tipo Cuenta Origen
                        CHAR(30),   --Notifica Cliente
                        CHAR(30),   --Notifica Receptor
                        CHAR(2),    --clave de tipo de operación
                        CHAR(40),   --Referencia1
                        CHAR(20),   --Referencia2
                        CHAR(5),    --Convenio
                        CHAR(1);    --tipo pago: 1-fijo,2-minimo, 3-porcentaje
                        
      ---**********************************************************
      -- Realizo   :Alejandro Osuna    
      --Solicito : Aymme Osuna
      -- Proyecto :  Pagos Programados
      -- Actividad : Tener un procedimiento que permitirá consultar las transacciones programadas
    --                    para un cliente determinado
      -- Fecha     :18 de  Novimebre  de 2008
      --******************************************************
      -- Realizó:       Walber Castro
      -- Solicitó:      Mauricio León
      -- Proyecto:      Pagos Programados BPI
      -- Actividad:     Se clona SP para modificar los parámetros de salida e implementar paginación.
      -- Fecha:         2011/05/16
      --******************************************************
      -- Realizó:       Walber Castro
      -- Solicitó:      Mauricio León
      -- Proyecto:      Pagos Programados BPI
      -- Actividad:     Se cambia la tabla de donde se toma la descripcion del canal y se agregan 3 parametros de salida mas (ref1,ref2 y convenio).
      -- Fecha:         2011/05/16
      --******************************************************
      -- Realizó:       Walber Castro
      -- Solicitó:      Mauricio León
      -- Proyecto:      Pagos Programados BPI
      -- Actividad:     Se le agrega el orden DESC a las consultas para que aparezcan las últimas mas nuevas en la interfaz.
      -- Fecha:         2011/10/11
	  --********************************************************
	  -- Bibiana Gaxiola Verdugo
	  -- Se modificó la forma en que se extrae el nombre del beneficiario para Pago TDC BanCoppel Propia y Pago TDC terceros mismo banco
	  -- Fecha: 22/11/2013
	  --*********************************************************
      --Definicion de Variables  
      DEFINE v_sCodRet CHAR(5);
      DEFINE v_sMensajeRet CHAR(250);
            
      DEFINE sCve_PagoProg         CHAR(10);
      DEFINE aCve_Estado                 CHAR(2);
      DEFINE sConcepto_Pago        CHAR(20);
      DEFINE sFecha_Programacion   DATE;
      DEFINE sFrecuencia                 CHAR(30);
      DEFINE sMonto                      MONEY(16,2);
      DEFINE sFecha_Inicio         DATE;
      DEFINE sCanal_Programacion   CHAR(40);
      DEFINE sCuenta_Destino       CHAR(20);
      DEFINE sBeneficiario         CHAR(60);
      DEFINE sBanco_Descrip        CHAR(40);
      DEFINE sCuenta_Origen        CHAR(20);
      DEFINE sTipo_Operacion       CHAR(70);
      DEFINE sCve_Notifica_Emi     CHAR(2);
      DEFINE sCve_Notifica         CHAR(2);
      DEFINE sTipo_Cta_Origen      CHAR(40);
      DEFINE sNotifica_Cte         CHAR(30);
      DEFINE sNotifica_Recep       CHAR(30);
      DEFINE sCveOperacion         CHAR(2);
    DEFINE sFecha_Cancelacion DATE;
    DEFINE v_dfecha                DATE;
    DEFINE iContador               INT;
      DEFINE sReferencia1                CHAR(40);
      DEFINE sReferencia2                CHAR(20);
      DEFINE sConvenio             CHAR(5);
      DEFINE sTipo_Pago            CHAR(1);
      DEFINE iNo_Repet             INT;
      DEFINE sFecha_Fin            DATE;
	  DEFINE vNumcte CHAR(9);
                  
      --Inicializacion de Variables
      LET v_sCodRet = '';
      LET v_sMensajeRet = '';
      LET sCve_PagoProg = '';
      LET aCve_Estado = '';
      LET sConcepto_Pago = '';
      LET sFecha_Programacion = '';
      LET sFrecuencia = '';
      LET sMonto = 0;
      LET sFecha_Inicio = '';
      LET sCanal_Programacion = '';
      LET sCuenta_Destino = '';
      LET sBeneficiario = '';
      LET sBanco_Descrip = '';
      LET sCuenta_Origen = '';
      LET sTipo_Operacion = '';
      LET sCve_Notifica_Emi = '';
      LET sCve_Notifica = '';
      LET sTipo_Cta_Origen = '';
      LET sNotifica_Cte = '';
      LET sNotifica_Recep = '';
      LET sCveOperacion = '';
    LET sFecha_Cancelacion = '';
    LET v_dfecha = '';        
    LET iContador = 0;
      LET sReferencia1 = '';
      LET sReferencia2 = '';
      LET sConvenio = '';
      LET sTipo_Pago = '';
      LET iNo_Repet = 0;
      LET sFecha_Fin = '';
	  LET vNumcte = '';
      
      --debug
      --SET DEBUG FILE TO "/tmp/sp_ConsultarProgramacionGeneral_BPI.out";
    --TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
SET ISOLATION COMMITTED READ;
      
      --Cuerpo del procedimiento.
      BEGIN
            SET LOCK MODE TO WAIT 10;
        SELECT fecha_hoy INTO v_dfecha FROM bdinteg:'informix'.si_fechas;

            --Valida que los parametros de entrada sean diferentes a nulos o blancos
            IF (NVL(p_snum_cte,'') <> '')  THEN
            ELSE
                  SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '104';
                  RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
            END IF;
            IF (NVL(p_sestado,'') <> '')  THEN
            ELSE
                  SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '126';
                  RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
            END IF;
                  --se valida que el cliente exista
                  IF EXISTS(SELECT empresa  FROM bdinteg:'informix'.si_cliente WHERE numcte =  p_snum_cte) THEN
                        --SE EXCLUYEN LOS ESTADOS QUE NO APLICAN PARA CONSULTA DE PROGRAMACION GENERAL
                        IF (p_sestado = '03') or (p_sestado = '05') or (p_sestado = '06') THEN
                             SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '86';
                             RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                        END IF;
                        --SE VALIDA EL VALOR DE ESTADO PERMITIDO
                        IF p_sestado = '99' THEN
                             --SE validaq que existan pagos programados para ese cliente
                                   IF EXISTS(SELECT descripcion FROM bdiprog:'informix'.pp_pagoprog WHERE num_cte = p_snum_cte) THEN
                                         --Se seleccionan todos los pagos programados de ese cliente.
                                         FOREACH     
                                               SELECT SKIP pDesde a.cve_pagoprog,a.cve_estado,a.descripcion as concepto_pago,a.fecha_insert as fecha_programacion,
                                               NVL(b.descripcion,'No Definida') as frecuencia, NVL(a.importe,0) + NVL(a.importe_iva,0) as monto,a.fecha_inicio,
                                               NVL(c.descripcion,'No Definido') as canal_programacion,a.cuenta_destino,NVL(d.nombre,'No Definido') as beneficiario,
                                               e.descripcion as banco_descrip, a.cuenta_origen,f.descripcion as tipo_operacion,
                                               a.cve_notifica_emi,a.cve_notifica,f.cve_pago,a.fecha_cancela, a.referencia1, a.referencia2, a.convenio,
                                               CASE WHEN TRIM(f.cve_pago) == '05' AND a.tipo_spei IN (1,2,3) THEN a.tipo_spei ELSE 1 END, NVL(a.no_repeticiones,0), a.fecha_fin
                                               INTO sCve_PagoProg,aCve_Estado,sConcepto_Pago,sFecha_Programacion,
                                               sFrecuencia,sMonto,sFecha_Inicio,
                                               sCanal_Programacion,sCuenta_Destino,sBeneficiario,
                                               sBanco_Descrip,sCuenta_Origen,sTipo_Operacion,
                                               sCve_Notifica_Emi,sCve_Notifica,sCveOperacion, sFecha_Cancelacion, sReferencia1, sReferencia2, sConvenio,
                                               sTipo_Pago, iNo_Repet, sFecha_Fin
                                               FROM bdiprog:'informix'.pp_pagoprog a LEFT JOIN bdiprog:'informix'.pp_tpprograma b ON (a.cve_programa = b.cve_programa)
                                               LEFT JOIN bdiprog:'informix'.pp_tpcanal c ON (a.cve_canal = c.cve_canal)
                                               LEFT JOIN bdiprog:'informix'.pp_ctasterceros d ON (a.num_cte = d.num_cte and a.cuenta_destino = d.cuenta)
                                               LEFT JOIN bdinteg:'informix'.si_bancos e ON ( a.banco_destino = e.banco )
                                               LEFT JOIN bdiprog:'informix'.pp_tppago f ON (a.cve_pago = f.cve_pago)
                                               WHERE a.num_cte = p_snum_cte
                                               ORDER BY a.cve_estado,a.fecha_insert DESC,b.cve_programa

                                                                IF ( iContador = pHasta ) THEN
                                                                    EXIT foreach;
                                                                END IF;

                                                                IF ( TRIM(aCve_Estado) != '01'  ) THEN
                                                                                                    IF (TRIM(aCve_Estado) = '04'  ) THEN
                                                                                                          IF(iNo_Repet != 0) THEN
                                                                                                                SELECT fecha_prog INTO sFecha_Fin FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg 
                                                                                                                     AND consecutivo = (SELECT MAX(consecutivo) FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg);
                                                                                                          END IF;
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Fin,+6) returning sFecha_Fin;
                                                                                                          IF (sFecha_Fin < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF; 
                                                                                                    ELSE
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Cancelacion,+6) returning sFecha_Cancelacion;
                                                                                                          IF (sFecha_Cancelacion < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF;                                                                
                                                                                                    END IF;
                                                                END IF;                                              
                                                                
                                                                    SELECT limit 1 b.nombre_prod
                                                                    INTO sTipo_Cta_Origen
                                                                    FROM bdicred:'informix'.sd_maecred a
                                                                    JOIN bdicred:'informix'.sd_definicion b ON (a.num_producto=b.num_producto and a.empresa=b.empresa)
                                                                    WHERE a.num_credito = sCuenta_Origen and a.empresa = p_empresa;

                                                                    IF NVL(sTipo_Cta_Origen,'') = '' THEN
                                                                            SELECT limit 1 b.nombre
                                                                            INTO sTipo_Cta_Origen
                                                                            FROM bdicheq:'informix'.sc_maechq a
                                                                            JOIN bdicheq:'informix'.sc_producto b ON (a.producto=b.producto and a.empresa=b.empresa)
                                                                            WHERE a.cuenta = sCuenta_Origen and a.empresa = p_empresa;
                                                                    END IF;

                                                                                                    IF sCveOperacion = '01' THEN --Se obtiene nombre de beneficiario en caso de ser propia
                                                                                                          SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
                                                                                                          INTO sBeneficiario
                                                                                                          FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																									ELIF sCveOperacion = '05' THEN
																										SELECT numcte INTO vNumcte FROM bdicred:"informix".sd_tarjeta where empresa = '001' AND num_tarjeta = sCuenta_Destino;
																										IF vNumcte = sBeneficiario THEN
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																										ELSE
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = vNumcte;
																										END IF;
                                                                                                    END IF;
                                                                                                    
                                                                    SELECT descripcion
                                                                    INTO sNotifica_Cte
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica_Emi;

                                                                    SELECT descripcion
                                                                    INTO sNotifica_Recep
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica;

                                                                    SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '00';
                                                                    LET iContador = iContador + 1;
                                                                    RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago  WITH RESUME;
                                         END FOREACH;
                                   ELSE
                                   --Se informa que no existen pagos programados para ese cliente
                                         SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '88';
                                         RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                                   END IF;
                        ELSE
                             --se valida que exista en la tabla de estados
                             IF EXISTS(SELECT descripcion FROM bdiprog:'informix'.pp_estados WHERE cve_estado = p_sestado) THEN
                                   --SE validaq que existan pagos programados para ese cliente y ese estado
                                   IF EXISTS(SELECT descripcion FROM bdiprog:'informix'.pp_pagoprog WHERE num_cte = p_snum_cte AND cve_estado = p_sestado) THEN
                                         --Se seleccionan todos los pagos programados de ese cliente y ese estado
                                          FOREACH
                                               SELECT SKIP pDesde FIRST pHasta a.cve_pagoprog,a.cve_estado,a.descripcion as concepto_pago,a.fecha_insert as fecha_programacion,
                                               NVL(b.descripcion,'No Definida') as frecuencia, NVL(a.importe,0) + NVL(a.importe_iva,0) as monto,a.fecha_inicio,
                                               NVL(c.descripcion,'No Definido') as canal_programacion,a.cuenta_destino,NVL(d.nombre,'No Definido') as beneficiario,
                                               e.descripcion as banco_descrip, a.cuenta_origen,f.descripcion as tipo_operacion,
                                               a.cve_notifica_emi,a.cve_notifica,f.cve_pago,a.fecha_cancela, a.referencia1, a.referencia2, a.convenio,
                                               CASE WHEN TRIM(f.cve_pago) == '05' AND a.tipo_spei IN (1,2,3) THEN a.tipo_spei ELSE 1 END, NVL(a.no_repeticiones,0), a.fecha_fin
                                               INTO sCve_PagoProg,aCve_Estado,sConcepto_Pago,sFecha_Programacion,
                                               sFrecuencia,sMonto,sFecha_Inicio,
                                               sCanal_Programacion,sCuenta_Destino,sBeneficiario,
                                               sBanco_Descrip,sCuenta_Origen,sTipo_Operacion,
                                               sCve_Notifica_Emi,sCve_Notifica, sCveOperacion,sFecha_Cancelacion, sReferencia1, sReferencia2, sConvenio,
                                               sTipo_Pago, iNo_Repet, sFecha_Fin
                                               FROM bdiprog:'informix'.pp_pagoprog a LEFT JOIN bdiprog:'informix'.pp_tpprograma b ON (a.cve_programa = b.cve_programa)
                                               LEFT JOIN bdiprog:'informix'.pp_tpcanal c ON (a.cve_canal = c.cve_canal)
                                               LEFT JOIN bdiprog:'informix'.pp_ctasterceros d ON (a.num_cte = d.num_cte and a.cuenta_destino = d.cuenta)
                                               LEFT JOIN bdinteg:'informix'.si_bancos e ON ( a.banco_destino = e.banco )
                                               LEFT JOIN bdiprog:'informix'.pp_tppago f ON (a.cve_pago = f.cve_pago)
                                               WHERE a.num_cte = p_snum_cte AND a.cve_estado = p_sestado
                                               ORDER BY a.cve_estado,a.fecha_insert DESC,b.cve_programa
                                               
                                                                 IF ( iContador = pHasta ) THEN
                                                                    EXIT foreach;
                                                                END IF;

                                                                IF ( TRIM(aCve_Estado) != '01'  ) THEN
                                                                                                    IF (TRIM(aCve_Estado) = '04'  ) THEN
                                                                                                          IF(iNo_Repet != 0) THEN
                                                                                                                SELECT fecha_prog INTO sFecha_Fin FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg 
                                                                                                                     AND consecutivo = (SELECT MAX(consecutivo) FROM bdiprog:pp_pagospend WHERE cve_pagoprog = sCve_PagoProg);
                                                                                                          END IF;
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Fin,+6) returning sFecha_Fin;
                                                                                                          IF (sFecha_Fin < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF; 
                                                                                                    ELSE
                                                                                                          CALL bdicred:"informix".monthadd(sFecha_Cancelacion,+6) returning sFecha_Cancelacion;
                                                                                                          IF (sFecha_Cancelacion < v_dfecha) THEN
                                                                                                                CONTINUE foreach;
                                                                                                          END IF;                                                                
                                                                                                    END IF;
                                                                END IF;     
                                               
                                                                    SELECT limit 1 b.nombre_prod
                                                                    INTO sTipo_Cta_Origen
                                                                    FROM bdicred:'informix'.sd_maecred a
                                                                    JOIN bdicred:'informix'.sd_definicion b ON (a.num_producto=b.num_producto and a.empresa=b.empresa)
                                                                    WHERE a.num_credito = sCuenta_Origen and a.empresa = p_empresa;

                                                                    IF NVL(sTipo_Cta_Origen,'') = '' THEN
                                                                            SELECT limit 1 b.nombre
                                                                            INTO sTipo_Cta_Origen
                                                                            FROM bdicheq:'informix'.sc_maechq a
                                                                            JOIN bdicheq:'informix'.sc_producto b ON (a.producto=b.producto and a.empresa=b.empresa)
                                                                            WHERE a.cuenta = sCuenta_Origen and a.empresa = p_empresa;
                                                                    END IF;

                                                                                                    IF sCveOperacion = '01' THEN --Se obtiene nombre de beneficiario en caso de ser propia
                                                                                                          SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
                                                                                                          INTO sBeneficiario
                                                                                                          FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																									ELIF sCveOperacion = '05' THEN
																										SELECT numcte INTO vNumcte FROM bdicred:"informix".sd_tarjeta where empresa = '001' AND num_tarjeta = sCuenta_Destino;
																										IF vNumcte = sBeneficiario THEN
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = p_snum_cte;
																										ELSE
																											SELECT TRIM(nombre1)|| ' ' || TRIM(nombre2)|| ' ' || TRIM(apell_paterno)|| ' ' ||  TRIM(apell_materno) as nombre
																											INTO sBeneficiario
																											FROM  bdinteg:"informix".si_cliente WHERE numcte = vNumcte;
																										END IF;
                                                                                                    END IF;
                                                                                                    
                                                                    SELECT descripcion
                                                                    INTO sNotifica_Cte
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica_Emi;

                                                                    SELECT descripcion
                                                                    INTO sNotifica_Recep
                                                                    FROM bdiprog:'informix'.pp_tpnotifica
                                                                    WHERE cve_notifica = sCve_Notifica;

                                                                    SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '00';
                                                                    LET iContador = iContador + 1;
                                                                    RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago  WITH RESUME;
                                         END FOREACH;      
                                   ELSE
                                   --Se informa que no existen pagos programados para ese cliente y ese estado
                                         SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '88';
                                         RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                                   END IF;
                             --se informa que el estado no existe
                             ELSE
                                   SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '87';
                                   RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                             END IF;
                        END IF;                 
                  --Se informa que el cliente exista
                  ELSE
                        SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:'informix'.pp_mensajes where cve_mensaje = '04';
                        RETURN v_sCodRet, v_sMensajeRet, sCve_PagoProg, aCve_Estado, sConcepto_Pago, sFecha_Programacion, sFrecuencia, sMonto, sFecha_Inicio,sCanal_Programacion, 
                        sCuenta_Destino, sBeneficiario, sBanco_Descrip, sCuenta_Origen, sTipo_Operacion, sTipo_Cta_Origen, sNotifica_Cte, sNotifica_Recep, sCveOperacion, sReferencia1, sReferencia2, sConvenio, sTipo_Pago;
                        END IF;
      END;
END PROCEDURE;