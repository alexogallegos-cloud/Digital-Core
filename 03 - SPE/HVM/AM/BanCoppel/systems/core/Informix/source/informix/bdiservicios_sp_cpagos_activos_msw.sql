CREATE PROCEDURE "informix".sp_cpagos_activos_msw(pcOrigen CHAR(4)) 
	RETURNING
		CHAR (5) 	AS cCodigo,
		CHAR (30) 	AS cMensaje,
		CHAR (2) 	AS cCategoria,
		CHAR (3) 	AS cConvenio,
		CHAR (20) 	AS cDescripcion,
		CHAR (8) 	AS cFecha;
	
	---DECLARACION DE VARIABLES
	DEFINE iSqlErr  INTEGER;
	DEFINE cPCodRet CHAR(5);
	DEFINE cCodigo CHAR(5);
	DEFINE cMensaje CHAR(30);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio  CHAR(3);
	DEFINE cDescripcion CHAR(20);
	DEFINE cFecha CHAR(12);
	
			
	---INICIALIZACION DE VARIABLES
	LET iSqlErr = 0;
	LET cPCodRet = '0';
	LET cCodigo ='00000';
	LET cMensaje ='';
	LET cCategoria ='';
	LET cConvenio  ='';
	LET cDescripcion ='';
	LET cFecha ='';
				
--SET DEBUG FILE TO '/informix/andrescrespo/sp_cpagos_activos_msw.out';
--TRACE ON;

    BEGIN
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN--manejador de errores
            LET cCodigo = '500';
			LET cPCodRet = iSqlErr;
			LET cMensaje='Error desconocido';
							
            RETURN cPCodRet, cMensaje,cCategoria,cConvenio,cDescripcion,cFecha;
        END IF;
    END EXCEPTION;
	
--SET ISOLATION TO DIRTY READ;
--SET LOCK MODE TO WAIT 10;

foreach	
	EXECUTE PROCEDURE bdisac:"informix".sp_pagos_activos_msw(pcOrigen)
	into cCodigo, cMensaje,cCategoria,cConvenio,cDescripcion,cFecha	
	RETURN cCodigo, cMensaje,cCategoria,cConvenio,cDescripcion,cFecha
	with resume;
end foreach;
		
		
	
	
	
	
	END;
END PROCEDURE;