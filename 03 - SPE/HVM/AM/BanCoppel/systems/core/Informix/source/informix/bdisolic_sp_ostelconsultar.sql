CREATE PROCEDURE "informix".sp_ostelconsultar(siRegistros SMALLINT)
                RETURNING CHAR(5) as CodRet,
                          INTEGER as Secuencia,
                          CHAR (7500) as TramaXML;

---Elaborado por : Lorenzo Ibarra García
--Fecha: 30-12-2008
--Regresa una trama XML con los datos de las Ordenes de Supervision que se encuentren como No Enviadas.
---Modificó : Lorenzo Ibarra García
--Fecha: 23-10-2009
--Se corrige validación para indicar cuando no hay registros que mostrar.
--Se agrega validación para que no se reciban valores negativos en el parámetro de entrada.
--Se modifica el FOREACH para que no obtenga todos los registros y se salte solo a los que debe mostrar.


DEFINE vCod_Ret  VARCHAR (5);
DEFINE iSqlErr   INTEGER;

DEFINE v_ostelefonica INTEGER;
DEFINE v_TramaXML CHAR (7500);
DEFINE siCiclo SMALLINT;
DEFINE iTotalTramas SMALLINT;

LET vCod_Ret = "000";
LET iSqlErr = 0;

LET v_ostelefonica = 0;
LET v_TramaXML = "";
LET siCiclo = 0;
LET iTotalTramas = 0;

--SET debug FILE TO "/respaldosbd/Lorenzo/sp_OSTelConsultar.out";
--trace on;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCod_Ret = iSqlErr;
            RETURN vCod_Ret, v_ostelefonica, v_TramaXML;
        END IF;
    END EXCEPTION;

    --checar que el parametro se haya enviado correctamente
    IF (siRegistros IS NULL) OR siRegistros < 0 THEN
        LET vCod_Ret = "001"; --el parámetro es incorrecto
        RETURN vCod_Ret, v_ostelefonica, v_TramaXML;
    END IF;
    
    --obtener el número total de tramas
    SELECT {+INDEX(bdisolic:ss_osclientesupervisartel_xml idx_stcte_xml)} COUNT(secuenciaostel) 
    INTO iTotalTramas
    FROM ss_osclientesupervisartel_xml 
    WHERE generar_os = "V";
    
    --comprobar que haya mas registros de los que se pide que no se obtengan con el parámetro
    IF iTotalTramas <= siRegistros THEN
        LET vCod_Ret = "002"; --no hay registros
        RETURN vCod_Ret, v_ostelefonica, v_TramaXML;
    END IF;
    
    --regresar todas las secuencias y tramas XML
    FOREACH
        SELECT {+INDEX(bdisolic:ss_osclientesupervisartel_xml idx_stcte_xml)} 
        skip siRegistros secuenciaostel, tramaxml
        INTO v_ostelefonica, v_TramaXML
        FROM bdisolic:ss_osclientesupervisartel_xml
        WHERE generar_os = "V"
        
        RETURN vCod_Ret, v_ostelefonica, v_TramaXML WITH RESUME;

    END FOREACH;
END;
END PROCEDURE;