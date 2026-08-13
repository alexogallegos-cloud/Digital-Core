CREATE PROCEDURE "informix".sp_estadisticas_tdc_cpl()
RETURNING
	CHAR(20)  AS Concepto,
	INTEGER AS Tarjetas_Entregadas,
	INTEGER AS Tarjetas_Estimadas;
	
    DEFINE iIsamErr        INTEGER;
    DEFINE iSqlErr         INTEGER;
    DEFINE cCodRet         INTEGER;
    DEFINE iHora           INTEGER;

    DEFINE iConcepto       CHAR(20);
    DEFINE iEsperadas         INTEGER;
    DEFINE iEntregadas   INTEGER;
   

    LET iSqlErr             = 0;
    LET iIsamErr            = 0;
    LET cCodRet             = 0;
    LET iHora               = 0;
    LET iConcepto        = '';
    LET iEsperadas          = 0;
    LET iEntregadas    = 0;
    --LET iEsperadas_despues  = 0;

BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
       IF iSqlErr != 0 THEN
          LET cCodRet = iSqlErr;
		  RETURN 'Error',0,0;
       END IF;
    END EXCEPTION;

	---SET DEBUG FILE TO "/tmp/anj/sp_estadisticas_tdc_cpl.out";
	---TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

--Obteniendo la hora en la que se esta ejecutando
    SELECT to_char(EXTEND(CURRENT, HOUR TO SECOND),'%H')AS HORA 
        INTO iHora 
    FROM bdinteg:si_fechas;
FOREACH
    SELECT 'Corriente' Concepto, sum(total) Tarjetas_Entregadas,
        (SELECT sum(numero) AS numero_antes FROM ss_estadisticas_cpl WHERE hora<(iHora)) AS Tarjetas_Estimadas
INTO iConcepto, iEsperadas, iEntregadas
        FROM (SELECT count(*)AS total from 
              (SELECT num_solicitud, to_char(extend(fecha_hora, HOUR TO SECOND),'%H')AS HORA FROM bdisolic:ss_solicitudes 
                        WHERE num_producto='6500' AND fecha_insert= (today)) A
                INNER JOIN ss_autorizacion B ON a.num_solicitud=b.num_solicitud AND b.status_solicitud='AP'
                WHERE a.hora<iHora
            GROUP BY a.HORA ) A
    UNION ALL            
        SELECT 'Anterior' Concepto, sum(total) Tarjetas_Entregadas,
        (SELECT sum(numero) AS numero_antes FROM ss_estadisticas_cpl WHERE hora<(iHora-1)) AS Tarjetas_Estimadas
        FROM (SELECT count(*)AS total FROM 
              (SELECT num_solicitud, to_char(extend(fecha_hora, HOUR TO SECOND),'%H')AS HORA FROM bdisolic:ss_solicitudes 
                        WHERE num_producto='6500' AND fecha_insert= (today)) A
                INNER JOIN ss_autorizacion B ON a.num_solicitud=b.num_solicitud AND b.status_solicitud='AP'
                WHERE a.hora<iHora-1
            GROUP BY a.HORA ) A
     UNION ALL
        SELECT 'Siguiente' Concepto, 0 Tarjetas_Entregadas,
        (SELECT sum(numero) AS numero_antes FROM ss_estadisticas_cpl WHERE hora<(iHora+1)) AS Tarjetas_Estimadas
        FROM ss_estadisticas_cpl WHERE hora=iHora
     UNION ALL
        SELECT 'Acumulado' Concepto, sum(total) Tarjetas_Entregadas,
        (SELECT sum(numero) AS numero_antes FROM ss_estadisticas_cpl WHERE hora<=(iHora+1)) AS Tarjetas_Estimadas
          FROM (SELECT count(*)AS total FROM 
              (SELECT num_solicitud, to_char(extend(fecha_hora, HOUR TO SECOND),'%H')AS HORA FROM bdisolic:ss_solicitudes 
                        WHERE num_producto='6500' AND fecha_insert= (today)) A
                INNER JOIN ss_autorizacion B ON a.num_solicitud=b.num_solicitud AND b.status_solicitud='AP'
                WHERE a.hora<=iHora
            GROUP BY a.HORA ) A

	RETURN iConcepto, NVL(iEsperadas,'0'), NVL(iEntregadas,'0') WITH RESUME;
END FOREACH;
END;
END PROCEDURE;