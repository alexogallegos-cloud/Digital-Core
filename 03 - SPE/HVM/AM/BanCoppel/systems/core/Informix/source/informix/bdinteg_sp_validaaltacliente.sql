CREATE PROCEDURE "informix".sp_validaaltacliente(cEempresa char(3), cNumCte char(20))

-- *******************
-- DATOS A REGRESAR
-- *******************
    RETURNING
    CHAR(5), -- Codigo de Retorno
	CHAR(1), -- Tipo de Cliente
    CHAR(20) -- Cadena de Dlls a Llamar
-- ******************
-- DEFINE VARIABLES
-- ******************
    DEFINE iSqlErr        INT;
    DEFINE cCodRet         CHAR(5);
    DEFINE cDlls           CHAR(20);
	DEFINE cTipoCliente    CHAR(1);
-- ******************
-- INICIALIZACION DE VARIABLES
-- ******************
    LET iSqlErr = 0;
    LET cCodRet = '000';
	LET cTipoCliente = '0';
    LET cDlls = '00000000000000000000';

--DOCUMENTACION:
--Realizó: Frank Gaxiola
--Fecha: 31/01/2009
--Funcionalidad: Consulta el status del alta del cliente

    --SET DEBUG FILE TO "/tmp/sp_ValidaAltaCliente.out";
    --TRACE ON;

BEGIN

    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, cTipoCliente, cDlls;
        END IF;
    END EXCEPTION;

	SELECT tipo_cliente INTO cTipoCliente FROM si_cliente WHERE numcte = cNumCte;
	
	IF cTipoCliente = '2' THEN
		LET cDlls = '11111100000000000000';
	ELIF cTipoCliente = '3' THEN
		IF NOT EXISTS(SELECT 1 FROM bdinteg:si_direcciones WHERE numcte = cNumCte) THEN
	        LET cDlls = '01111100000000000000';
	    --ELIF NOT EXISTS(SELECT 1 FROM bdinteg:si_ingresos WHERE numcte= cNumCte) THEN
	        --LET cDlls = '00111100000000000000';
	    ELIF NOT EXISTS(SELECT 1 FROM bdinteg:si_cteppes WHERE numcte= cNumCte) THEN
			LET cDlls = '00011100000000000000';
			
			IF EXISTS(SELECT 1 FROM bdinteg:si_cte_huella WHERE numcte = cNumCte) THEN
				LET cDlls = '00010100000000000000';
			END IF;
			
			IF EXISTS(SELECT 1 FROM bdidigital:dg_expediente_img WHERE empresa = cEempresa AND cliente = cNumCte AND cod_docto 
		                IN ('0001', '0003', '0013', '0014', '0022', '0027', '0028', '0029', '0030', 
						    '0047', '0048', '0049', '0050')) THEN
				LET cDlls = '00010000000000000000';
			END IF;	
		ELIF NOT EXISTS(SELECT 1 FROM bdinteg:si_cte_huella WHERE numcte = cNumCte) THEN
	        LET cDlls = '00001100000000000000';
		ELIF NOT EXISTS(SELECT 1 FROM bdidigital:dg_expediente_img WHERE empresa = cEempresa AND cliente = cNumCte AND cod_docto 
		                IN ('0001', '0003', '0013', '0014', '0022', '0027', '0028', '0029', '0030', 
						    '0047', '0048', '0049', '0050')) THEN
	        LET cDlls = '00000100000000000000';
	    END IF;
	ELIF cTipoCliente = '1' THEN
		IF NOT EXISTS(SELECT 1 FROM bdinteg:si_cte_huella WHERE numcte = cNumCte) THEN
	        LET cDlls = '00001100000000000000';
		END IF;
	END IF;
	
	IF (cDlls = '00000000000000000000' OR cDlls = '00010000000000000000') AND (cTipoCliente = '3' OR cTipoCliente = '2') THEN
		UPDATE si_cliente SET tipo_cliente = '1' WHERE numcte = cNumCte;
		LET cTipoCliente = '1'; 
	END IF;
	
    RETURN cCodRet, cTipoCliente, cDlls;

END;

END PROCEDURE;