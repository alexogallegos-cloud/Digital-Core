CREATE PROCEDURE "informix".sp_actualizavalidatelefono() 
RETURNING CHAR(5);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INT;
DEFINE cNumcte          CHAR(20);

DEFINE iContador        INTEGER;
DEFINE sCommit          SMALLINT;

-------------------------------------------

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET cNumcte='';

LET iContador = 0;
LET sCommit = 0;

--------------------------------------------
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr 
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;	
            RETURN vc_CodRet;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/OMC/sp_actualizavalidatelefono.out";
    --TRACE ON;
	

    SET ISOLATION TO DIRTY READ;
    FOREACH WITH HOLD	
		SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_cliente)} a.numcte 
		INTO cNumcte FROM bdinteg:si_cliente a INNER JOIN si_telefonos b
		ON a.numcte = b.numcte
		WHERE a.tpo_persona = '01' AND a.tipo_cliente=2 AND b.tipo_tel = 2 AND b.status_tel='A' AND b.verificado='V'	

		IF (sCommit = 0) THEN
			BEGIN WORK;
			LET iContador = 0;
			LET sCommit = -1;
		END IF;
		
		UPDATE bdinteg:si_telefonos SET verificado = 'F' WHERE numcte = cNumcte AND tipo_tel = 2 AND status_tel='A' AND verificado='V';
			
		LET iContador = iContador  + 1;	

		--Ejecutar un commit cada 5000 registros.
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

    RETURN vc_CodRet;

END;
END PROCEDURE;