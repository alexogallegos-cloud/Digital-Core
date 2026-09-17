CREATE PROCEDURE "informix".sp_obtenfechahrasistema()
RETURNING
	CHAR(5) 						AS cod_ret,
	CHAR(10)						AS fecha,
	DATETIME HOUR TO FRACTION(3)	AS hora;

	---DECLARACIONES
    DEFINE iSqlErr			INTEGER;
    DEFINE cCodRet			CHAR(5);
	DEFINE cFechaHoy		CHAR(10);
	DEFINE dtHora			DATETIME HOUR TO FRACTION(3);

	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET cCodRet				= '00000';
	LET cFechaHoy			= "";
	LET dtHora				= "";

BEGIN
    ON EXCEPTION SET iSqlErr
       IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, "",  "";
       END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	-- SE OBTIENE LA FECHA Y LA HORA DEL SISTEMA DE INTEGRAL 
	SELECT fecha_hoy, CURRENT HOUR TO FRACTION(3)
	INTO cFechaHoy , dtHora
	FROM bdinteg: "informix".si_fechas;
	
	RETURN cCodRet, cFechaHoy,  dtHora;
	
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Proceso para obtener la fecha y la hora del servidor', 
'BASE DE DATOS: bdinteg', 
'AUTOR: Mohamed Carreón ',
'FECHA: AGOSTO 2012',
'VERSION: 20120829.1620';

CREATE PROCEDURE "informix".sp_actualiza_numcelular_ctebm(pNumCliente CHAR(9),pNumCelular CHAR(15))
	RETURNING CHAR(5);
	
	--***************************************************************************
	-- FUNCIONALIDAD: Actualiza el número celular del cliente para la banca móvil.
	-- Autor: Francisco Rodrìguez
	-- Solicito: José de Jesús Nevarez
	-- Fecha: 13/09/2011
	--***************************************************************************
	
	--DECLARACION DE VARIABLES

	DEFINE vsCodRet  		CHAR(5);
	DEFINE vSqlErr          INTEGER;
	
	DEFINE v_codret1      CHAR(5);
    DEFINE v_Empresa     CHAR(3); 
    DEFINE v_TipoTel     SMALLINT;
    DEFINE v_Extension   CHAR(5); 
    DEFINE v_Canal       SMALLINT;
    DEFINE v_CiaCel      SMALLINT;
	DEFINE pReg_numemp	 CHAR(8);
	
	--Asignacion de variables
	LET vsCodRet = '00000';
	LET vSqlErr = 0;
	
	LET v_codret1 = '00000';
	LET v_Empresa = '001';
	LET v_TipoTel    = 2; 
    LET v_Extension  = ''; 
    LET v_Canal      = 3; 
    LET v_CiaCel = 1;
	LET pReg_numemp = 'transBPI';
	
	BEGIN
		ON EXCEPTION SET vSqlErr
	      IF vSqlErr <> 0 THEN
	            let vsCodRet = vSqlErr;
	            RETURN vsCodRet;
	      END IF;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO "/tmp/manuel/celularbm.out";
		-- TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		
		UPDATE bdinteg:"informix".si_bm_usuarios SET numcel = pNumCelular WHERE numcte = pNumCliente;
		--UPDATE bdinteg:"informix".si_direcciones_actual SET tipo_telef2 = 'C', telefono2= pNumCelular WHERE numcte = pNumCliente;
		
		RETURN vsCodRet;
	END;
END PROCEDURE;