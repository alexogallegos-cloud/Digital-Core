CREATE PROCEDURE "informix".sp_calcula_rfc()
    RETURNING CHAR(5) AS codret;

DEFINE cCodRet      CHAR(5);
DEFINE iSqlErr	    INTEGER;
DEFINE cNumcte      CHAR(20);
DEFINE cApell_Pat   CHAR(26);
DEFINE cApell_Mat   CHAR(26);
DEFINE cNombre      CHAR(55);
DEFINE cFecNac      CHAR(10);
DEFINE cRFCOrig     CHAR(13);
DEFINE cRFCNuevo    CHAR(13);
DEFINE cNombre1		CHAR(26);
DEFINE cNombre2		CHAR(26);
DEFINE cCteDup		CHAR(13);

LET cCodRet      ='00000';
LET iSqlErr		 =0;
LET cNumcte      ='';
LET cApell_Pat   ='';
LET cApell_Mat   ='';
LET cNombre      ='';
LET cFecNac      ='';
LET cRFCOrig     ='';
LET cRFCNuevo    ='';
LET cNombre1	 ='';
LET cNombre2	 ='';
LET cCteDup	     ='';

BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;

        --SET DEBUG FILE TO '/informix/VH/soc_fase3/calculo_rfc.out';
		--TRACE ON;
        
        set isolation to dirty read;
        FOREACH  
                
				SELECT numcte
					INTO cNumcte
					from si_rfc_calculados
				
				SELECT c.rfc,trim(c.apell_paterno),trim(c.apell_materno),trim(c.nombre1),trim(c.nombre2),f.fecha_nac,trim(c.nombre1)||' '||trim(c.nombre2)
					INTO cRFCOrig,	cApell_Pat,	cApell_Mat,	cNombre1,cNombre2,cFecNac,cNombre
					from si_cliente c inner join si_ctepf f on c.numcte=f.numcte
					WHERE C.numcte=cNumcte;

				
             EXECUTE PROCEDURE bdicnweb:"informix".sp_calcularrfc(cApell_Pat, cApell_Mat, cNombre, cFecNac)
                INTO cCodRet, cRFCNuevo;
       			   	
					
					SELECT numcte--TRAE EL CLIENTE
					INTO cCteDup
					FROM si_cliente
					WHERE rfc=cRFCNuevo--SE VA A TRAER EL CLIENTE DONDE EL RFC=RFC_NUEVO
					AND	numcte <> cNumcte;
																   

				update bdinteg:si_rfc_calculados
				 set rfc_original=cRFCOrig,
					rfc_calculado=cRFCNuevo,
					apell_paterno=cApell_Pat,
					apell_materno=cApell_Mat,
					nombre1=cNombre1,
					nombre2=cNombre2,
					fecha_nac=cFecNac,
					duplicado=cCteDup
				where numcte=cNumcte;
            							
        END FOREACH;
				
       set isolation to dirty read;
        FOREACH 
				SELECT numcte,rfc_calculado
				INTO cNumcte, cRFCNuevo
				from si_rfc_calculados where duplicado is null --trae el cliente donde se hata encontrado un cliente con el mismo rfc
				update  bdinteg:si_cliente set rfc=cRFCNuevo where numcte=cNumcte;
					
        END FOREACH;		
		
		
		RETURN cCodRet;
	END;
			
END PROCEDURE;