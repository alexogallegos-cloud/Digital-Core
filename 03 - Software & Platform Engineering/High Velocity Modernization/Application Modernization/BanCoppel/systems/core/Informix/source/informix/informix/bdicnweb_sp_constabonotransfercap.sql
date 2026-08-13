CREATE PROCEDURE "informix".sp_constabonotransfercap(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		 CHAR(4)	AS transacc, 
		 CHAR(80)	AS	descripcion;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTransacc    CHAR(4);
    DEFINE cDescripcion CHAR(80);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cTransacc    = '';
    LET cDescripcion = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTransacc,cDescripcion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_constabonotransfercap.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTransacc,cDescripcion;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTransacc,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH  
			 EXECUTE PROCEDURE bdicnweb:"informix".sp_trxsabonotransfersoc('001')
				INTO cCodRetSp,cTransacc,cDescripcion
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_trxsabonotransfersoc';
			ELIF cCodRetSp::INTEGER = 999  THEN
				LET cCodRet = '00710';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cTransacc,UPPER(TRIM(cDescripcion)) WITH RESUME;
		END FOREACH;
		
		IF iNoRegistros = 0  THEN 
				LET cCodRet ='00017';
				RETURN cCodRet,cTransacc,cDescripcion;
			END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 29/10/2015',
'MODULO: DÉBITO',
'FUNCIONALIDAD:DEPÓSITO A CUENTAS TRANSFER DE DÉBITO',
'DESCRIPCION: SPL que consulta las transaciones de abono de transfer del soc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_constdepositoctstransfercap(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20))
		RETURNING CHAR(5) AS codret,
		DECIMAL (16,2) AS saldo_cuenta;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE dSaldoCuenta DECIMAL(16,2);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET dSaldoCuenta = 0.00;
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dSaldoCuenta;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_constdepositoctstransfercap.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pCuenta= '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dSaldoCuenta;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dSaldoCuenta;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdicnweb:"informix".sp_consdoctatransfersoc(pCuenta)
			INTO cCodRetSp, dSaldoCuenta;		
			LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
		RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consdoctatransfersoc';
			ELIF cCodRetSp::INTEGER = 999  THEN
			LET cCodRet = '00710';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, dSaldoCuenta;
	
		IF iNoRegistros = 0  THEN 
			LET cCodRet ='00017';
			RETURN cCodRet, dSaldoCuenta;
		END IF;		
	END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 29/10/2015',
'MODULO: DÉBITO',
'FUNCIONALIDAD:DEPÓSITO A CUENTAS TRANSFER DE DÉBITO',
'DESCRIPCION: SPL que consulta el deposito de  transfer para el soc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultacargotransfercap(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		 CHAR(4) AS  tranfer,
		 CHAR(80) AS descripcion;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cTransacc    CHAR(4);
    DEFINE cDescripcion CHAR(80);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cTransacc    = '';
    LET cDescripcion = '';
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTransacc,cDescripcion;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultacargotransfercap.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTransacc,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTransacc,cDescripcion;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH  
			 EXECUTE PROCEDURE bdicnweb:"informix".sp_trxscargotransfersoc('001')
				INTO cCodRetSp, cTransacc,cDescripcion
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_trxscargotransfersoc';
			ELIF cCodRetSp::INTEGER = 999  THEN
				LET cCodRet = '00710';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cTransacc, UPPER(TRIM(cDescripcion)) WITH RESUME;	
		END FOREACH;
		
		IF iNoRegistros = 0  THEN 
				LET cCodRet ='00017';
				RETURN cCodRet,cTransacc,cDescripcion;
			END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 29/10/2015',
'MODULO: DÉBITO',
'FUNCIONALIDAD:DEPÓSITO A CUENTAS TRANSFER DE DÉBITO',
'DESCRIPCION: SPL que consulta las transacciones de cargo para transfer del soc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultactastransfercap(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS  cuenta,
		CHAR(16) AS  tarjeta,
		CHAR(40) AS  producto,
		CHAR(18) AS  clabe,
		CHAR(10) AS  fecha_alta,
		CHAR(10) AS  status_tarj,
		CHAR(10) AS  status_cta,	
		CHAR(4)  AS  sucursal,
		CHAR(8)  AS  ejecutivo,
		CHAR(10) AS  fecha_canc;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cCuenta 		CHAR(20);  
	DEFINE cTarjeta 	CHAR(16);  
	DEFINE cProducto 	CHAR(40);  
	DEFINE cClabe 		CHAR(18);  
	DEFINE cFechaAlta  	CHAR(10);  
	DEFINE cStatusTarj 	CHAR(10);  
	DEFINE cStatusCta	CHAR(10);  
	DEFINE cSucursal 	CHAR(4);  
	DEFINE cEjecutivo 	CHAR(8);  
	DEFINE cFechaCanc 	CHAR(10); 
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cCuenta 	= '';  
	LET cTarjeta 	= '';  
	LET cProducto 	= '';  
	LET cClabe 		= '';  
	LET cFechaAlta  = '';  
	LET cStatusTarj = '';  
	LET cStatusCta	= '';  
	LET cSucursal 	= ''; 
	LET cEjecutivo 	= ''; 
	LET cFechaCanc 	= '';  
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cTarjeta, cProducto, cClabe, cFechaAlta, cStatusTarj, cStatusCta, cSucursal, cEjecutivo, cFechaCanc;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultactastransfercap.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cTarjeta, cProducto, cClabe, cFechaAlta, cStatusTarj, cStatusCta, cSucursal, cEjecutivo, cFechaCanc;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cTarjeta, cProducto, cClabe, cFechaAlta, cStatusTarj, cStatusCta, cSucursal, cEjecutivo, cFechaCanc;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH  
			 EXECUTE PROCEDURE bdicnweb:"informix".sp_consctastransfersoc(pNumCte)
				INTO cCodRetSp, cCuenta, cTarjeta, cProducto, cClabe, cFechaAlta, cStatusTarj, cStatusCta, cSucursal, cEjecutivo, cFechaCanc
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consctastransfersoc';
			ELIF cCodRetSp::INTEGER = 104  THEN
				LET cCodRet = '00009';
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cCuenta, cTarjeta,UPPER(TRIM(cProducto)), cClabe, cFechaAlta, UPPER(TRIM(cStatusTarj)), UPPER(TRIM(cStatusCta)), cSucursal, cEjecutivo, cFechaCanc WITH RESUME;	
		END FOREACH;
		
		IF iNoRegistros = 0  THEN 
				LET cCodRet ='00017';
				RETURN cCodRet, cCuenta, cTarjeta, cProducto, cClabe, cFechaAlta, cStatusTarj, cStatusCta, cSucursal, cEjecutivo, cFechaCanc;		
			END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 29/10/2015',
'MODULO: DÉBITO',
'FUNCIONALIDAD:DEPÓSITO A CUENTAS TRANSFER DE DÉBITO',
'DESCRIPCION: SPL consulta las cuentas de transfer para el soc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consultactetransfercap(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCte CHAR(20))
		RETURNING CHAR(5) AS codret,
		CHAR(104)	AS nombre_cte,
		CHAR(13)	AS rfc,
		CHAR(10)	AS tipo_cte;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cNombreCte CHAR(104);
    DEFINE cRFC CHAR(13);
    DEFINE cTipoCte CHAR(10);
	DEFINE iNoRegistros INTEGER;
		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cNombreCte  = '';
    LET cRFC = '';
    LET cTipoCte = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreCte, cRFC,cTipoCte;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultactetransfercap.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreCte, cRFC,cTipoCte;
		END IF;
	
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreCte, cRFC,cTipoCte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		  
		 EXECUTE PROCEDURE bdicnweb:"informix".sp_consctetransfersoc(pNumCte)
			INTO cCodRetSp,cNombreCte,cRFC,cTipoCte;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_consctetransfersoc';
		ELIF cCodRetSp::INTEGER = 104  THEN
			LET cCodRet = '00022';
		END IF;
		LET iNoRegistros = iNoRegistros + 1;
		RETURN cCodRet,UPPER(TRIM(cNombreCte)),UPPER(TRIM(cRFC)), UPPER(TRIM(cTipoCte));
			
		IF iNoRegistros = 0  THEN 
				LET cCodRet ='00017';
				RETURN cCodRet,cNombreCte, cRFC,cTipoCte;
			END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez',
'FECHA: 29/10/2015',
'MODULO: DÉBITO',
'FUNCIONALIDAD:DEPÓSITO A CUENTAS TRANSFER DE DÉBITO',
'DESCRIPCION: SPL que consulta los clientes de transfer del soc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_trxsabonotransfersoc( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(4), CHAR(80);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cTransacc    CHAR(4);
    DEFINE cDescripcion CHAR(80);
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
    LET cTransacc    = '';
    LET cDescripcion = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_trxsabonotransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cTransacc, cDescripcion;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_trxsabonotransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_trxtrfabonosoc
     WHERE transacc = transacc;
       
    IF iExiste = 0 THEN
        LET cCodRet1 = '999';
        RETURN cCodRet1, cTransacc, cDescripcion;
    END IF;
    
    FOREACH
        SELECT transacc, descripcion
          INTO cTransacc, cDescripcion
          FROM bdicheq:sc_trxtrfabonosoc
         WHERE transacc = transacc
         ORDER BY transacc
         
        RETURN cCodRet1, cTransacc, cDescripcion WITH RESUME;
    
        LET cTransacc = '';
        LET cDescripcion = '';
    END FOREACH

    END;
    
END PROCEDURE;