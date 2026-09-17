CREATE PROCEDURE "informix".sp_valmontomax_ordenpago (pMonto MONEY(14,2),	pNombre1 CHAR(26),	pNombre2 CHAR(26),	pApellPat CHAR(26),	pApellMat CHAR(26))
	RETURNING  CHAR(5) ;

	DEFINE cCodRet 				CHAR(5);
	DEFINE iSqlErr				INTEGER;
	DEFINE isam_error			INTEGER;

	DEFINE dFechaActual			DATE;
	DEFINE cMontoMax			CHAR(100);
	DEFINE mMontoEnvio			MONEY(16,2);
	DEFINE mMonto 				MONEY;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		
	BEGIN
		ON EXCEPTION SET iSqlErr,isam_error
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/informix/bibiana/sp_valmontomax_ordenpago.out";
		--TRACE ON;	

		LET cCodRet 				= '00000';
		LET iSqlErr					= 0;
		LET isam_error				= 0;
		
		LET cMontoMax				= '';
		LET dFechaActual 			= '';
		LET mMontoEnvio 			= 0;
		LET mMonto					= 0;


		-- OBTIENE EL MONTO MAXIMO POR ENVIO
		SELECT VALOR 
		INTO cMontoMax
		FROM BDISAC:"informix".SAC_PARAM 
		WHERE COD_PARAM='230003';

		-- OBTIENE FECHA ACTUAL
		SELECT FECHA_HOY 
		INTO dFechaActual
		FROM BDISAC:"informix".SAC_FECHAS 
		WHERE EMPRESA='001';

		-- SE OBTIENE LA SUMA DE ENVIOS 
		SELECT SUM(IMPORTE_ENVIO) 
		INTO mMontoEnvio
		FROM BDISAC:"informix".SAC_ENVIOSDINEROYA
		WHERE FECHA_ENVIO = dFechaActual
		AND PRI_NOM_BEN = (CASE WHEN pNombre1 = '' THEN PRI_NOM_BEN ELSE pNombre1 END)
		AND SEG_NOM_BEN = (CASE WHEN pNombre2 = '' THEN SEG_NOM_BEN ELSE pNombre2 END)
		AND APELL_PAT_BEN = (CASE WHEN pApellPat = '' THEN APELL_PAT_BEN ELSE pApellPat END)
		AND APELL_MAT_BEN = (CASE WHEN pApellMat = '' THEN APELL_MAT_BEN ELSE pApellMat END);
		
		-- SE SUMA EL MONTO DE ENVIO CON EL IMPORTE 
		LET mMonto = mMontoEnvio + pMonto;
		
		IF ( mMonto > cMontoMax ) THEN
			LET cCodRet = '00001';
		END IF;
		
		RETURN cCodRet;
	END
END PROCEDURE
Document
'DESCRIPCION: Valida que una orden de pago para un beneficiario no rebase el limite diario por beneficiario', 
'AUTOR: Ilse Gomez',
'FECHA:  15 de enero de 2015',
'VERSION: 20141216.0900',
'BD: BDIPROG';

CREATE PROCEDURE "informix".sp_consultacuentasdestino_bpi_pba(p_NumCte CHAR(20), p_CvePago CHAR(2), p_Registros SMALLINT)
RETURNING
     CHAR(6), ---cod_ret
	 CHAR(20), ---cuenta
	 CHAR(100), ---nombre
	 CHAR(50), ---banco
	 CHAR(2), ---compañia celular
	 CHAR(10), ---numero celular
	 CHAR(40), ---correo electronico
	 CHAR(2), ---cve cuenta
     CHAR(20), ---desc cuenta
     CHAR(13), ---rfc
	 MONEY(16,2); ---Monto Máximo

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
	
	SET LOCK MODE TO WAIT 10;

BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_ConsultaCuentasDestino.out";
	--TRACE ON;

	SELECT cod_ret
	INTO v_cod_ret
	FROM  bdiprog:"informix".PP_MENSAJES
	WHERE cve_mensaje = "00";

	select banco || " " ||
		(CASE
			WHEN TRIM(vchrnombrecorto) = ''
				THEN descripcion
			ELSE
				vchrnombrecorto
		END) 
	INTO v_Banco
	FROM bdinteg:"informix".si_bancos
	WHERE banco = "137";

	IF (p_NumCte <> "" AND p_NumCte IS NOT NULL) AND (p_CvePago <> "" AND p_CvePago IS NOT NULL)  THEN
 		IF EXISTS (SELECT ct.cuenta FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp WHERE ct.num_cte = p_NumCte AND ct.cve_cuenta = cp.cve_cuenta)  THEN
            IF TRIM(p_CvePago) = '04' THEN
                FOREACH
                    SELECT ct.cuenta, ct.nombre, ct.cve_banco, ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0)
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    --AND ct.cve_banco = '000'
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'

--                    LET v_ContReg = v_ContReg + 1;

--                  IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                       CONTINUE FOREACH;
--                    END IF;
					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
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

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo  WITH RESUME;
                END FOREACH;
            ELSE
                FOREACH
                    SELECT ct.cuenta, ct.nombre, b.banco|| "  " ||
					(CASE
						WHEN TRIM(vchrnombrecorto) = ''
						THEN descripcion
					ELSE
					vchrnombrecorto
					END), ct.cve_compania, ct.no_celular, ct.direc_correo, ct.cve_cuenta,ct.descrip_cta, ct.rfc, ct.canal_alta, ct.fecha_insert, ct.hora_insert, NVL(ct.monto_maximo,0)
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc, v_Canal, v_FechaInsert, v_HoraInsert, v_MontoMaximo
                    FROM bdiprog:"informix".pp_ctasterceros ct, bdinteg:"informix".si_bancos b, bdiprog:"informix".pp_cuentapago cp
                    WHERE ct.num_cte = p_NumCte
                    AND ct.cve_banco = b.banco
                    AND ct.cve_cuenta = cp.cve_cuenta
                    AND cp.cve_pago = p_CvePago
                    AND ct.cve_estado = '01'
                    UNION
                    --SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','','1900-01-01'::date, current hour to second
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,'','',mdy(1,1,1900), current hour to second,0
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago = '05'
					ORDER BY ct.descrip_cta, ct.nombre

--                    LET v_ContReg = v_ContReg + 1;

--                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
--                        CONTINUE FOREACH;
--                    END IF;
					
					-- Si el canal es de internet, devolvera solo los registros que tengan 30 minutos o mas transcurridos despues de su alta
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

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc, v_MontoMaximo  WITH RESUME;
                END FOREACH;
            END IF;
        ELSE
            IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta Where numcte == p_NumCte )  THEN
                FOREACH
                    SELECT num_tarjeta ,nombre,'137  BANCOPPEL, S. A.' ,'','','','04','CUENTA PROPIA' ,''
                    INTO v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta, v_Rfc
                    FROM bdicred:"informix".sd_tarjeta
                    WHERE numcte = p_NumCte
                    AND tipo_tarjeta='T'
                    AND status_tar='A'
                    AND p_CvePago ="05"

                    LET v_ContReg = v_ContReg + 1;

                    IF v_ContReg <= p_Registros THEN -- Si el registro no es mayor al numero de registro recibido, no regresa nada y continua con el siguiente registro
                        CONTINUE FOREACH;
                    END IF;

                    RETURN v_cod_ret, v_CtaDestino,v_Nombre,v_Banco,v_CompCel,v_NumCel,v_CorreoE,v_CveCuenta,v_DescCta,v_Rfc,v_MontoMaximo  WITH RESUME;
                END FOREACH;
            ELSE
                SELECT cod_ret
                INTO v_cod_ret
                FROM  BDIPROG:"informix".PP_MENSAJES
                WHERE cve_mensaje = "13";

                RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
            END IF
		END IF
	ELSE
		SELECT cod_ret
		INTO v_cod_ret
		FROM  BDIPROG:"informix".PP_MENSAJES
		WHERE cve_mensaje = "01";

        RETURN v_cod_ret, NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL;
	END IF
END;
--##############################################################################
--## Procedimiento   : sp_ConsultaCuentasDestino
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--## Descripcion     : Consulta las cuentas destino que tiene registrado un cliente
--## Modifico        : Saúl Ivanhoe
--## Fecha Modificacion: 25-Feb-2009
--## Descripcion     : Obtiene las cuentas propias de credito del cliente
--##Modifico		 : Javier Chávez
--##Fecha Modificacion: 18/03/2010
--##Descripcion      : Obtiene las cuentas ordenadas alfabeticamente por alias y nombre
--##Modifico		 : Javier Calderón
--##Fecha Modificacion: 20/04/2010
--##Descripcion      : Obtiene solo las cuentas que ya hayan transcurrido 30 minutos desde su alta (Solo para Internet)
--##Modifico		 : Walber Castro
--##Fecha Modificacion: 17/11/2011
--##Descripcion      : Se agrega un parámetro de salida del monto máximo.
--##############################################################################
END PROCEDURE;