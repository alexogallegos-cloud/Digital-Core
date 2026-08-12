CREATE PROCEDURE "informix".sp_ostelconsultarvencidas()
                RETURNING CHAR(5) as CodRet,
                          INTEGER as Secuencia,
                          char(20) as Numcte,
                          INTEGER as Ciudad,
                          CHAR(40) as NombreCiudad,
                          smallint as Tipociudad,
                          datetime year to second as FechaHoraInicio,
                          datetime year to second as FechaHoraFin,
                          char(512) as InteractionID;

---Elaborado por : Lorenzo Ibarra García
--Fecha: 30-12-2008
--Regresa una trama XML con los datos de las Ordenes de Supervision que se encuentren como No Enviadas.
---Modificó : Lorenzo Ibarra García
--Fecha: 23-10-2009
--Se corrige validación para indicar cuando no hay registros que mostrar.
--Se agrega validación para que no se reciban valores negativos en el parámetro de entrada.
--Se modifica el FOREACH para que no obtenga todos los registros y se salte solo a los que debe mostrar.
---Modificó : Jesús Manuel Aguilar Heredia
--se modifca para no devolver valores null, debido a que no puede ser recibido por el webservice del CAT
--Fecha: 06-04-2011

DEFINE vCod_Ret  VARCHAR (5);
DEFINE iSqlErr   INTEGER;

DEFINE v_ostelefonica INTEGER;
DEFINE v_TramaXML CHAR (2000);
DEFINE siCiclo SMALLINT;
DEFINE iTotalTramas SMALLINT;

DEFINE v_Numcte char(20);
DEFINE v_Ciudad INTEGER;
DEFINE v_NombreCiudad CHAR(40);
DEFINE v_Tipociudad smallint;
DEFINE v_FechaHoraInicio datetime year to second;
DEFINE v_FechaHoraFin datetime year to second;
DEFINE v_InteractionID char(512);

LET vCod_Ret = "000";
LET iSqlErr = 0;

LET v_ostelefonica = 0;
LET v_TramaXML = "";
LET siCiclo = 0;
LET iTotalTramas = 0;

--SET debug FILE TO "/tmp/sp_OSTelConsultarVencidas.out";
--trace on;

BEGIN
    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET vCod_Ret = iSqlErr;
             RETURN vCod_Ret, NVL(v_ostelefonica," "), NVL(v_Numcte," "), NVL(v_Ciudad,0), NVL(v_NombreCiudad," "), NVL(v_Tipociudad,0), NVL(v_FechaHoraInicio," "), 
            NVL(v_FechaHoraFin," "), NVL(v_InteractionID," ");
        END IF;
    END EXCEPTION;

    --regresar todas las secuencias y tramas XML
    FOREACH
        SELECT {+INDEX(bdisolic:ss_ostelSolVigenciaVencida idx_ostelvigven)}
SecuenciaOSTel, Numcte, Ciudad, NombreCiudad, Tipociudad, FechaHoraInicio, FechaHoraFin, InteractionID-- Enviada
        INTO v_ostelefonica, v_Numcte, v_Ciudad, v_NombreCiudad, v_Tipociudad, v_FechaHoraInicio, v_FechaHoraFin, v_InteractionID
        FROM bdisolic:ss_ostelSolVigenciaVencida
        WHERE Enviada = '0'
     
        RETURN vCod_Ret, NVL(v_ostelefonica," "), NVL(v_Numcte," "), NVL(v_Ciudad,0), NVL(v_NombreCiudad," "), NVL(v_Tipociudad,0), NVL(v_FechaHoraInicio,DATE(1)), 
            NVL(v_FechaHoraFin,DATE(1)), NVL(v_InteractionID," ") WITH RESUME;

    END FOREACH;
END;
END PROCEDURE;