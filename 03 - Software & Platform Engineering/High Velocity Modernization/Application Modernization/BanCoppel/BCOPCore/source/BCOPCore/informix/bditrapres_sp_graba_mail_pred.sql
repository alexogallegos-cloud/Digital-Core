CREATE PROCEDURE "informix".sp_graba_mail_pred(pEjecutivo CHAR(8), 
											   pApePat CHAR(26), 
											   pApeMat CHAR(26), 
											   pNom1 CHAR(26), 
											   pNom2 CHAR(26), 
											   pIP CHAR(20),
											   pEmpresa CHAR(3),
											   pNumCliente CHAR(20),
											   pEmail CHAR(60))

--DATOS A REGRESAR---
	RETURNING
	CHAR(6)  AS codigo_retorno;
	
--DEFINICION DE VARIABLES--
	DEFINE iSqlErr			INTEGER;
	DEFINE cCodRet     		CHAR(6);
	DEFINE cErrorInfo 		CHAR(80);
	DEFINE vExisteCorreo    SMALLINT;
	DEFINE vExisteCte       INTEGER;
    DEFINE vTpoPersona      CHAR(2);
	
--INICIALIZACION DE VARIABLES--
	LET iSqlErr       = 0;
	LET cCodRet       = '000000';
	LET cErrorInfo	  = '';
	LET vExisteCorreo = 0;
	LET vExisteCte    = 0;
    LET vTpoPersona   = '';
	

	--SET DEBUG FILE TO "sp_graba_mail_pred.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,''));
			END IF;
			
		END EXCEPTION;

		--Valida parámetros de entrada
		IF NVL(TRIM(pEjecutivo),'') = ''  THEN
			LET cCodRet = '000001';
		ELIF NVL(TRIM(pApePat),'') = ''  THEN
			LET cCodRet = '000002';
		ELIF NVL(TRIM(pNom1),'') = ''  THEN
			LET cCodRet = '000003';
		ELIF NVL(TRIM(pIP),'') = ''  THEN
			LET cCodRet = '000004';
		ELIF NVL(TRIM(pEmpresa),'') = ''  THEN
			LET cCodRet = '000005';
		ELIF NVL(TRIM(pNumCliente),'') = ''  THEN
			LET cCodRet = '000006';
		ELIF NOT EXISTS (SELECT ip FROM bdicobranza: "informix".cb_ips_predictivo 
						 WHERE TRIM(ip) = TRIM(pIP)) THEN
			LET cCodRet = '000008';
		ELIF NVL(TRIM(pEmail),'') = '' THEN
			LET cCodRet = '110';
		END IF;
		
		IF TRIM(cCodRet) = '000000' THEN
			--Se valida si el Cliente existe
			SELECT tpo_persona, COUNT(*)
			INTO vTpoPersona, vExisteCte
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = pNumCliente
			GROUP BY 1;
		 
			IF NVL(vExisteCte,0) = 0 THEN
				LET cCodRet = '104';			
			END IF;
		END IF;
		
		IF TRIM(cCodRet) = '000000' THEN
			--Se valida se el correo Existe
			SELECT COUNT(*)
			INTO vExisteCorreo
			FROM bdinteg:"informix".si_correos
			WHERE correo_elec = TRIM(pEmail)
			AND status_correo = 'A';
		   
			IF NVL(vExisteCorreo,0) > 0 THEN
				LET cCodRet = '999';        
			END IF;
		END IF;
    
			
		IF TRIM(cCodRet)<>'000000' THEN
			--Párametros de entrada vacíos
			-- Se Guarda en Bitacora
			INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo 
			(transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno)
			VALUES('GRAMAIL',NVL(TRIM(pIP),''),TODAY,CURRENT HOUR TO SECOND,'',NVL(TRIM(pNumCliente),''),NVL(TRIM(pEjecutivo),''),NVL(TRIM(pApePat),''),
					NVL(TRIM(pApeMat),''),NVL(TRIM(pNom1),''),NVL(TRIM(pNom2),''),cCodRet);
		ELSE
			--Se guarda el Email
			EXECUTE PROCEDURE bdinteg:"informix".sp_grabaremail(pEmpresa,pNumCliente,pEmail) INTO cCodRet,cErrorInfo;

            IF cCodRet = '000' THEN LET cCodRet = '000000'; END IF;
			-- Se Guarda en Bitacora
			INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo 
			(transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno)
			VALUES('GRAMAIL',NVL(TRIM(pIP),''),TODAY,CURRENT HOUR TO SECOND,'',NVL(TRIM(pNumCliente),''),NVL(TRIM(pEjecutivo),''),NVL(TRIM(pApePat),''),
					NVL(TRIM(pApeMat),''),NVL(TRIM(pNom1),''),NVL(TRIM(pNom2),''),cCodRet);
			
			IF NVL(TRIM(cCodRet),'')= '000' THEN
				LET cCodRet = '000000';
			END IF;
		END IF;
		RETURN TRIM(cCodRet);
	END
END PROCEDURE
DOCUMENT
'FECHA: 22/Jun/2015',
'FOLIO :1728',
'PROYECTO: ReingenieriaPredictivoBancoppel',
'DESCRIPCION: Procedimineto para grabar el Email del Cliente',
'AUTOR: Obed Vega',
'BD: bditrapres';

CREATE PROCEDURE "informix".sp_graba_convenio_pred(pEjecutivo CHAR(8), 
												   pApePat CHAR(26), 
												   pApeMat CHAR(26), 
												   pNom1 CHAR(26), 
												   pNom2 CHAR(26), 
												   pIP CHAR(20),
												   pEmpresa CHAR(3),
												   pEmpleado_Captura INT,
												   pNumCliente CHAR(20),
												   pNumCuenta CHAR(20),
												   pTipo_Compac CHAR(1),
												   pPlazo CHAR(2),
												   pImporte DECIMAL(18,2),
												   pOrigen SMALLINT,
												   pEfectuo_compac INT,
												   pSucursal CHAR(4),
												   pFechaSistema DATE,
												   pQuien_Convenio CHAR(15),
												   pNom_QuienConvenio CHAR(40),
												   pEmail CHAR(60),
												   pReferenciaCoppel CHAR(20))

--DATOS A REGRESAR---
	RETURNING
	CHAR(6)  AS codigo_retorno;
	
--DEFINICION DE VARIABLES--
	DEFINE iSqlErr     INTEGER;
	DEFINE cCodRet     CHAR(6);
	DEFINE cNombreEfectuo	CHAR(40);
	DEFINE cNumProducto	CHAR(4);
--INICIALIZACION DE VARIABLES--
	LET iSqlErr     = 0;
	LET cCodRet     = '000000';
	LET cNombreEfectuo = '';
	LET cNumProducto   = '';

	--SET DEBUG FILE TO "sp_graba_convenio_pred.out";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
		
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN TRIM(NVL(cCodRet,''));
			END IF;
			
		END EXCEPTION;

		--Valida parámetros de entrada
		IF NVL(TRIM(pEjecutivo),'') = ''  THEN
			LET cCodRet = '000001';
		ELIF NVL(TRIM(pApePat),'') = ''  THEN
			LET cCodRet = '000002';
		ELIF NVL(TRIM(pNom1),'') = ''  THEN
			LET cCodRet = '000003';
		ELIF NVL(TRIM(pIP),'') = ''  THEN
			LET cCodRet = '000004';
		ELIF NVL(TRIM(pEmpresa),'') = ''  THEN
			LET cCodRet = '000005';
		ELIF NVL(TRIM(pNumCliente),'') = ''  THEN
			LET cCodRet = '000006';
		ELIF NVL(TRIM(pNumCuenta),'') = ''  THEN
			LET cCodRet = '000007';
		ELIF NOT EXISTS (SELECT ip FROM bdicobranza: "informix".cb_ips_predictivo 
						 WHERE TRIM(ip) = TRIM(pIP)) THEN
			LET cCodRet = '000008';
		END IF;
		
			
		IF TRIM(cCodRet)<>'000000' THEN
			--Párametros de entrada vacíos
			-- Se Guarda en Bitacora
			INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo 
			(transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno)
			VALUES('GRACONV',NVL(TRIM(pIP),''),TODAY,CURRENT HOUR TO SECOND,NVL(TRIM(pNumCuenta),''),NVL(TRIM(pNumCliente),''),NVL(TRIM(pEjecutivo),''),NVL(TRIM(pApePat),''),
					NVL(TRIM(pApeMat),''),NVL(TRIM(pNom1),''),NVL(TRIM(pNom2),''),cCodRet);
		ELSE
			--Se arma el cNombreEfectuo
			LET cNombreEfectuo = TRIM(pNom1)||CASE WHEN LENGTH(TRIM(pNom2)) > 0 THEN ' ' ||TRIM(pNom2) ELSE '' END||' '||TRIM(pApePat)||CASE WHEN LENGTH(TRIM(pApeMat)) > 0 THEN ' '||TRIM(pApeMat) ELSE '' END;
			LET cNombreEfectuo = SUBSTR(TRIM(cNombreEfectuo),1,40);

            --SELECT num_producto INTO cNumProducto FROM bdicred:sd_maecred WHERE empresa='001' and num_credito = pNumCuenta;

            --IF cNumProducto IS NULL THEN LET cNumProducto = ''; END IF;

            --IF cNumProducto != ''  THEN
                --Se guarda el Convenio
                EXECUTE PROCEDURE bdicobranza:"informix".sp_grabacompac(pEmpresa,pEmpleado_Captura,pNumCliente,pNumCuenta,pTipo_Compac,pPlazo,pImporte,pOrigen,pEfectuo_compac,pSucursal,pFechaSistema,
                                                            pQuien_Convenio,pNom_QuienConvenio,pEmail,pReferenciaCoppel,TRIM(cNombreEfectuo)) INTO cCodRet;
            /*ELSE

			   INSERT INTO bdicobranza:"informix".cb_compac
                      (empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, activo, flag_pago, efectuo_compac, nombre_efectuo, fecha_compac, fecha_insert, quien_convenio, nom_convenio, email, referenciacoppel, imp_pagado, hora_insert, pago_programado) 
  	           VALUES 
              (pEmpresa, pSucursal, pOrigen, pEmpleado_Captura, pNumCliente, pNumCuenta, pPlazo , pImporte, pTipo_Compac, '1', '0', pEfectuo_compac, trim(cNombreEfectuo), today, TODAY,  pQuien_Convenio, pNom_QuienConvenio,  pEmail , pReferenciaCoppel , 0, current, '');

			    INSERT INTO bdicobranza:"informix".cb_compac_his
				      (empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, activo, flag_pago, efectuo_compac, tipo_movto, nombre_efectuo,  fecha_compac,  fecha_insert, keyx,imp_pagado )
        		SELECT empresa, sucursal, origen, empleado_captura, numcliente, numcuenta, plazo, importe, tipo_compac, '0',    flag_pago, efectuo_compac, '',         nombre_efectuo,  fecha_compac,  today,        keyx, nvl(imp_pagado, 0)
					    FROM bdicobranza:CB_COMPAC 
					   WHERE empresa = pEmpresa 	
				       AND numcuenta = pNumCuenta;

		        DELETE FROM BDICOBRANZA:CB_COMPAC WHERE empresa = pEmpresa and numcuenta = pNumCuenta;

            END IF;*/

                -- Se Guarda en Bitacora
            INSERT INTO bdicobranza:"informix".cb_bitacora_predictivo 
                (transaccion,ip,fecha,hora,num_credito,numcte,ejecutivo,apellido_pat,apellido_mat,pri_nombre,seg_nombre,codigo_retorno)
               VALUES('GRACONV',NVL(TRIM(pIP),''),TODAY,CURRENT HOUR TO SECOND,NVL(TRIM(pNumCuenta),''),NVL(TRIM(pNumCliente),''),NVL(TRIM(pEjecutivo),''),NVL(TRIM(pApePat),''),
                        NVL(TRIM(pApeMat),''),NVL(TRIM(pNom1),''),NVL(TRIM(pNom2),''),cCodRet);
			
            IF NVL(TRIM(cCodRet),'')= '000' THEN
               LET cCodRet = '000000';
            END IF;

		END IF;
		RETURN TRIM(cCodRet);
	END
END PROCEDURE
DOCUMENT
'FECHA: 22/Jun/2015',
'FOLIO :1728',
'PROYECTO: ReingenieriaPredictivoBancoppel',
'DESCRIPCION: Procedimineto para grabar convenio realizado al Cliente',
'AUTOR: Obed Vega',
'BD: bditrapres';

CREATE PROCEDURE "informix".rev_trans_abono
( 
psucursal char(4), 
pusuario char(8), 
pfolio char(16) 
)
RETURNING CHAR(3);

    DEFINE sql_err             integer;
    DEFINE isam_err            integer;
    DEFINE cod_ret1            char(3);
    DEFINE cod_ret2            char(3);
    DEFINE vtransaccion 	   integer;
    DEFINE vexiste_folio       smallint;

    LET sql_err = 0;
    LET isam_err = 0;
    LET cod_ret1 = "000";
    LET cod_ret2 = "000";
    LET vtransaccion = 0;
    LET vexiste_folio = 0;

     --SET DEBUG FILE TO "/informix/moha/rev_trans_abono.out";
    --TRACE ON;

    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err
        IF (sql_err <> 0) THEN
            -- SET DEBUG FILE TO "/resplogifx/conciliachq/rev_trans_abono.err";
            -- TRACE ON;
            LET cod_ret1 = sql_err;
            LET cod_ret2 = isam_err;
            IF vtransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            RETURN cod_ret1;
        END IF;
    END EXCEPTION;

    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH resume;

    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF (psucursal is null OR psucursal = '' OR LENGTH(psucursal) <> 4) OR
       (pusuario is null OR pusuario = '' OR LENGTH(pusuario) <> 8) OR
       (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) THEN
        
        LET cod_ret1 = '005';
        
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        RETURN cod_ret1;
    ELSE
        EXECUTE PROCEDURE bdicheq:reversion( '001',     -- empresa
                                             psucursal, -- sucursal
                                             pusuario,  -- usuario
                                             pfolio,    -- folio
                                             'A')       -- tipo reversion
        INTO cod_ret1;
        
        IF cod_ret1 = '000' THEN
			SELECT COUNT(*)
			INTO vexiste_folio
			FROM bdicheq:sc_acumtrapres
			WHERE folio_suc = pfolio;

			IF vexiste_folio > 0 THEN
				DELETE FROM bdicheq:sc_acumtrapres
				WHERE folio_suc = pfolio;
			END IF;
        ELSE
            IF cod_ret1 = '413' THEN
                LET cod_ret1 = '413';
            END IF;
            
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF;
            
            RETURN cod_ret1;
        END IF;
    END IF;
    
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK; 
    END IF;
    
    RETURN cod_ret1;

    END;

END PROCEDURE;