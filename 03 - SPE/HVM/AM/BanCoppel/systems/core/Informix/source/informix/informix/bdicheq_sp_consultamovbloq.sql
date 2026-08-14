CREATE PROCEDURE "informix".sp_consultamovbloq(pEmpresa CHAR(3), 
									 pCuenta CHAR(20))
RETURNING   CHAR(5)   AS Retorno,
            CHAR(3) as motivo,
            
            CHAR (2) as clavearea,
            CHAR (2) as clave,
            Char (2) as tipobloqueo,
            char(2) as opcion;


	DEFINE cCod_ret      	 CHAR(5);
	DEFINE cRazon       	 CHAR(3);
    DEFINE iSqlErr      	 INTEGER;
    DEFINE cOpcionbl         char(2);
    DEFINE cCvearea          CHAR (2);
    DEFINE cCve              CHAR (2);
    DEFINE cCvetipobloq      Char (2);

	LET cCod_ret     	  = "00000";
	LET cRazon    	 	  = "";
    LET iSqlErr      	  = 0;
    LET cOpcionbl         ='';
    LET cCvearea          ='';
    LET cCve              ='';
    LET cCvetipobloq      ='';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,cRazon,cCvearea,cCve,cCvetipobloq,cOpcionbl;
			END IF;
		END EXCEPTION;		  

        select a.motivo, b.clave,b.opcion,b.cve_area,b.cve_tipobloq
        into cRazon,cCve  ,cOpcionbl,cCvearea, cCvetipobloq
        from sc_maechq a, sc_ctabloqueo b where a.cuenta=pCuenta and status_cta='3' and a.cuenta=b.cuenta;        

        let cRazon= trim(cRazon);

        IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
            let cCod_ret='001'; -- No se encontro numero de cuenta
        	--RETURN cCod_ret,cRazon;
            RETURN cCod_ret,cRazon,cCvearea,cCve,cCvetipobloq,cOpcionbl;
        End if;

          -- if cCve =

            --if cRazon=1
        --RETURN cCod_ret,cRazon;
          RETURN cCod_ret,cRazon,cCvearea,cCve,cCvetipobloq,cOpcionbl;  



end;
End procedure;