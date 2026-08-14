CREATE PROCEDURE "informix".consbeneficiario(pEmpresa CHAR(3), pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	CHAR(20), -- Numero de Cuenta
	CHAR(20), -- Numero de Cliente
	CHAR(9),  -- Porcentaje
	CHAR(26), -- Apellido Paterno
	CHAR(26), -- Apellido Materno
	CHAR(26), -- Nombre1
	CHAR(26), -- Nombre2
	CHAR(13), -- RFC
	CHAR(10), -- Fecha Nacimiento
	CHAR(20); -- Parentesco

	--DEFINICION DE VARIABLES--
	DEFINE iSqlErr		INTEGER;
	DEFINE sCantReg		SMALLINT;
	DEFINE cCodRet		CHAR(5);
	DEFINE cNumCuenta	CHAR(20);
	DEFINE cNumCliente	CHAR(20);
	DEFINE cPorcentaje  CHAR(9);
	DEFINE cApePat		CHAR(26);
	DEFINE cApeMat		CHAR(26);
	DEFINE cNombre1		CHAR(26);
	DEFINE cNombre2		CHAR(26);
	DEFINE cRFC			CHAR(13);
	DEFINE cFechaNac	CHAR(10);
	DEFINE cParentesco	CHAR(20);
	DEFINE cProducto	CHAR(4);
	DEFINE cProdTransfer	CHAR(4);

	--INICIALIZACION DE VARIABLES--
	LET iSqlErr		= 0;
	LET sCantReg 	= 0;
	LET cCodRet 	= '000';
	LET cNumCuenta 	= '';
	LET cNumCliente = '';
	LET cPorcentaje = '';
	LET cApePat 	= '';
	LET cApeMat 	= '';
	LET cNombre1 	= '';
	LET cNombre2 	= '';
	LET cRFC 		= '';
	LET cFechaNac 	= '';
	LET cParentesco = '';
	LET cProducto	= '';
	LET cProdTransfer= '';

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		LET cCodRet = iSqlErr;
		RETURN cCodRet, cNumCuenta, cNumCliente, cPorcentaje, cApePat, cApeMat, cNombre1, cNombre2, cRFC, cFechaNac, cParentesco;		
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/consbeneficiario.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pNumeroCuenta,'') <> '' THEN

		FOREACH
			SELECT bdi_scbene.cuenta,bdi_scbene.numcte,bdi_scbene.porcentaje,bdi_scbene.parentesco,bdi_sicte.apell_paterno,bdi_sicte.apell_materno,bdi_sicte.nombre1,bdi_sicte.nombre2,bdi_sicte.rfc,bdi_sictepf.fecha_nac
			INTO cNumCuenta, cNumCliente, cPorcentaje, cParentesco, cApePat, cApeMat, cNombre1, cNombre2, cRFC, cFechaNac
			FROM bdicheq:"informix".sc_beneficiario bdi_scbene, bdinteg:"informix".si_cliente bdi_sicte, bdinteg:"informix".si_ctepf bdi_sictepf
			WHERE bdi_scbene.empresa = pEmpresa AND bdi_scbene.cuenta = pNumeroCuenta AND bdi_scbene.numcte = bdi_sicte.numcte
			AND bdi_sicte.empresa = pEmpresa AND bdi_sicte.tpo_persona = '01' AND bdi_sicte.numcte = bdi_sictepf.numcte

			LET sCantReg = sCantReg + 1;
			RETURN cCodRet, cNumCuenta, cNumCliente, cPorcentaje, cApePat, cApeMat, cNombre1, cNombre2, cRFC, cFechaNac, cParentesco WITH RESUME;
		END FOREACH;

		IF sCantReg = 0 THEN
			SELECT valor INTO cProdTransfer
			FROM bditransfer:"informix".tf_param
			WHERE empresa = pEmpresa AND cod_param = '4';

			SELECT producto	INTO cProducto
			FROM bditransfer:"informix".tf_maecte
			WHERE empresa = pEmpresa AND cuenta_tf = pNumeroCuenta;

			IF NVL(cProducto,'') = '' THEN
				SELECT producto	INTO cProducto
				FROM bdicheq:"informix".sc_maechq
				WHERE empresa = pEmpresa AND cuenta = pNumeroCuenta;
			END IF
			
			IF NVL(cProdTransfer,'') = NVL(cProducto,'') THEN
				LET cCodRet	= '01221';			ELSE
				LET cCodRet	= '128';			END IF

			RETURN cCodRet, cNumCuenta, cNumCliente, cPorcentaje, cApePat, cApeMat, cNombre1, cNombre2, cRFC, cFechaNac, cParentesco;
		END IF
	ELSE
		LET cCodRet	= '128';
		RETURN cCodRet, cNumCuenta, cNumCliente, cPorcentaje, cApePat, cApeMat, cNombre1, cNombre2, cRFC, cFechaNac, cParentesco;
	END IF
END;
END PROCEDURE
DOCUMENT
'000 - exito',
'128 - sin beneficiarios bancoppel',
'01221 - sin beneficiarios tranfer',
'MODIFICO : Claudio Almodovar',
'FECHA : 16/06/2015',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_validador24d(pfechaejecuta date) 
    RETURNING VARCHAR(5),VARCHAR(255);
	
	DEFINE cVarDataErr              VARCHAR(64);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iSamErr                  INTEGER;
    DEFINE vCodRet                  CHAR(5);
	DEFINE vdesc 					VARCHAR(255);
	DEFINE v_extracdia              INTEGER; 
    --VARIABLES CONTROL CICLO RECORRIDO DEL 
	--DEFINE v_tipo					CHAR(1);
	DEFINE v_porcentaje				FLOAT;
	DEFINE v_ultimodia              INTEGER;
	DEFINE v_dias_ret    			INTEGER;
	DEFINE v_rango					CHAR(5);
	
	LET vcodret = '00000';
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
BEGIN
--Manejo del error
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
         SET DEBUG FILE TO "/informix/Cheques/sp_validador24d.err";
			IF iSqlErr <> 0 THEN
				LET vCodret=iSqlErr;
				RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
			END IF;
		END EXCEPTION;  
		
		--SET DEBUG FILE TO "/informix/Cheques/sp_validador24d.out";
        --TRACE ON;	 
									
-- // Valida la fecha del Movimiento
    IF (pfechaejecuta is null) or (pfechaejecuta = '') then
        LET vcodret = '00001'; -- Falta parametro Fecha de Operacion
        LET cVarDataErr = 'Falta parametro Fecha de Operacion';
        RETURN vcodret, cVarDataErr;
    END IF;
	
	
	-- GENERA LA EXTRACCION DE LA INFORMACION
	    LET v_ultimodia = day(pfechaejecuta);
	WHILE v_ultimodia > 0  
		
		IF NOT EXISTS (SELECT fecha FROM sc_fechvalr24d WHERE fecha = pfechaejecuta) THEN	
			INSERT INTO sc_valr24d
			SELECT {+INDEX("informix".sc_movhis idx_movhisnew4)} 
			a.fech_alt, a.transacc, sum (a.monto_tot) as montototal, count(a.transacc) as numerotransacciones
			FROM bdicheq:sc_movhis as a, bdinteg: si_transacc as b
			WHERE a.empresa= '001'
			AND a.fech_alt = pfechaejecuta
			AND a.cancelad <> 'S'
			AND a.transacc = b.numero
			AND b.regulatorios = '1'
			GROUP BY 1,2;
			--ORDER BY 2;
			
			
			INSERT INTO sc_fechvalr24d(fecha)
			VALUES (pfechaejecuta);
		END IF
						
	   LET v_ultimodia = v_ultimodia - 1;
	   LET pfechaejecuta = pfechaejecuta - 1 UNITS DAY;
	   
	END WHILE
	
	return vcodret, 'Exitoso';
		
END;	
END PROCEDURE;