CREATE PROCEDURE "informix".sp_actualiza_telssms()
				returning CHAR(5) AS Cod_Retorno;


DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
DEFINE sTelefono        char(10);
DEFINE sNumCte          CHAR(10);

--SISTEMA DE CUENTA 01 VARIABLES
LET cCodRet 			= "00000";
LET iSql_err            =0;
LET sRetCod          	="99999";
LET sTelefono           ='';
LET sNumCte             ='';



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;


	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	FOREACH
		--Paso 1. Traer todos los telefonos con "1111"
        SELECT DISTINCT numcte, telefono INTO sNumCte, sTelefono FROM si_bitsmstels WHERE teclea_ejecut LIKE '1111%'
        AND DATE(fecha)>='08182016'

 
        --Paso 2. Buscar que no exista en la si_bitsmstels un cte y telefono con la bandera en true
        IF NOT EXISTS(SELECT * FROM si_bitsmstels WHERE numcte=sNumCte AND telefono=sTelefono AND bandera='t'
                  AND DATE(fecha)>='08182016')THEN
        
         --Paso3. Si NO existe en la tabla con la bandera en TRUE, se actualiza su valida en si_telefonos     
           --Paso 3.1 Se verifica la si_telefonos, si el campo MARCATEL es Verdadero, se omite actalizacion, caso contrario se cambia a Falso
           IF NOT EXISTS(SELECT * FROM si_telefonos WHERE numcte=sNumCte AND telefono=sTelefono AND tipo_tel='2'
                         AND marcatel='V')THEN
               
                --Paso 4. Actualiza la si_telefonos a FALSO.
                UPDATE si_telefonos SET verificado='F' WHERE numcte=sNumCte AND telefono=sTelefono AND tipo_tel='2';
                INSERT INTO si_tmp_telsact VALUES(sNumCte, sTelefono);
       
           END IF;
        END IF;
        
		 
	END FOREACH;


	RETURN cCodRet;
END
END PROCEDURE;