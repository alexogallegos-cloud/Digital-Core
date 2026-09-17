CREATE PROCEDURE "informix".sp_ce_aplicareversioncom(
   v_folio_suc_com      CHAR(20),     -- Folio identificador del pago Comision
   v_folio_suc_iva      CHAR(20),     -- Folio identificador del pago IVA
   v_usuario        	CHAR(8)      -- Usuario
)
RETURNING CHAR(5),CHAR(5);
--*******************************************************************************************************
--
-- Objetivo:   SP aplica reversion de comision e iva Transact
-- Autor:     90314722 - Brayam Jair AndrÃ©s ZÃºÃ±iga
-- Fecha:     20/06/2025 - SP para aplicar el reverso de una comision mas iva
--
--
--*******************************************************************************************************
--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************

   DEFINE vSqlErr INTEGER;
   DEFINE cCodRetCom CHAR(5);
   DEFINE cCodRetIva CHAR(5);

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************
   LET vSqlErr = 0;
   LET cCodRetCom = '';
   LET cCodRetIva = '';

--*****************************************************
-- INICIALIZACION DE VARIABLES
--*****************************************************

--*****************************************************
-- ACTIVAR / INACTIVAR TRACE
--*****************************************************

   --SET DEBUG FILE TO "/informix/SD/Orion/sp_ce_aplicapago_"||TRIM(v_num_credito)||"_"||TRIM(v_num_cuenta)||"_"||cast(v_tipo_moneda as char(2))||".out";
   --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

--*****************************************************
-- INICIA PROCESO
--*****************************************************
BEGIN
		ON EXCEPTION SET vSqlErr
			IF vSqlErr <> 0 THEN
				LET cCodRetIva = vSqlErr;
				LET cCodRetCom = vSqlErr;
				--ROLLBACKWORK;
				RETURN cCodRetCom, cCodRetIva;
			END IF;
		END EXCEPTION;
		
		--***********************
		-- REVERSO
		--***********************
		CALL sp_ce_aplicareversion(v_folio_suc_iva,v_usuario)
		RETURNING cCodRetIva; --> IVA
		
		IF cCodRetIva = '00000' THEN
		
			CALL sp_ce_aplicareversion(v_folio_suc_com,v_usuario)
			RETURNING cCodRetCom; --> Comision
					
		END IF;
	
	RETURN cCodRetCom, cCodRetIva;
END;
END PROCEDURE;