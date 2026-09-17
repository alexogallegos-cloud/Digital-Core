CREATE PROCEDURE "informix".sp_actualiza_rep_ctas_tel_mail()
RETURNING 
CHAR(5) AS CodRet,
CHAR(50) AS Mensaje;

----------------DEFINE VARIABLES----------------------
DEFINE cCodRet        	  CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE cNumcte            CHAR(20);
DEFINE cCorreo            CHAR(100);
DEFINE cTelefono          CHAR(10);
DEFINE sCommit            SMALLINT;
DEFINE iContador          INTEGER;
DEFINE cCuenta		      CHAR(20);

----------------INICIALIZA VARIABLES------------------
LET cCodRet             ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET cNumcte             ='';
LET cCorreo             ='';
LET cTelefono           ='';
LET sCommit             = 0;
LET iContador           = 0;
LET cCuenta             ='';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD
    SELECT {+INDEX ("informix".si_rep_ctas_tel_mail idx_rep_ctas_tel_mail)} cuenta
	INTO cCuenta
	FROM si_rep_ctas_tel_mail
		
        SELECT LIMIT 1 num_cte INTO cNumcte FROM bdicheq:sc_maechq WHERE cuenta = cCuenta;        
        SELECT LIMIT 1 correo_elec INTO cCorreo FROM si_correos WHERE status_correo = 'A' AND numcte = cNumcte AND secuencia = (select max(secuencia) from si_correos where  numcte = cNumcte); 
        SELECT LIMIT 1 telefono INTO cTelefono FROM si_telefonos_actual WHERE status_tel='A' AND tipo_tel=2 AND numcte = cNumcte;               

        IF (sCommit = 0) THEN
            BEGIN WORK;
            LET iContador = 0;
            LET sCommit = -1;
        END IF;			        

        UPDATE si_rep_ctas_tel_mail SET numcte = NVL(cNumcte,''), correo = NVL(cCorreo,''), celular = NVL(cTelefono,'')
        WHERE cuenta = cCuenta;

        --Ejecutar un commit cada 1000 registros.
        IF (iContador >= 5000) THEN
            COMMIT WORK;	
            LET iContador = 0;            
            BEGIN WORK;
        END IF;	

    END FOREACH;
	
	IF sCommit = -1 THEN
        COMMIT WORK;        
        END IF;
	LET sCommit = 0;

	LET cDesc = 'Proceso Correcto';
    RETURN cCodRet, cDesc;

END;
END PROCEDURE;