CREATE PROCEDURE "informix".sp_reporte_trimestral_captacion()
    
    RETURNING VARCHAR(6) as CODIGO_RETORNO, VARCHAR(80) as MENSAJE_RETORNO; 

    DEFINE CODIGO_RETORNO VARCHAR(6);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE vsql CHAR(1150);
    DEFINE RUTA_DESTINO VARCHAR(80);
    DEFINE vfecha_hoy DATE;

BEGIN
    
    --Variables sin cambio de asignacion.
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'PROCESO EXITOSO';
    LET RUTA_DESTINO = '/resplogifx/';
    LET vfecha_hoy = '';
    
    --SET DEBUG FILE TO RUTA_DESTINO||"sp_reporte_trimestral_captacion.out";
    --TRACE ON;

    SET ISOLATION TO dirty READ;
    SELECT fecha_hoy INTO vfecha_hoy
        FROM bdinteg:si_fechas
    WHERE empresa = '001';
    
    LET vsql = '';
    LET vsql = 'echo "Id Plantilla | Descripcion |Numero de Clientes|"> '||RUTA_DESTINO||'reporte_trimestral_captacion_'|| LPAD (day(vfecha_hoy),2,"0")||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; ' ||
    ' UNLOAD TO '||RUTA_DESTINO||'reporte_trimestral_captacion.unl' ||
    ' SELECT plantilla, '||
    ' CASE ' ||
    '   WHEN plantilla = \"1\" THEN \"Clientes con tarjeta presente\" ' ||
    '   WHEN plantilla = \"2\" THEN \"Clientes con tarjeta no presente\" ' ||
    '   WHEN plantilla = \"3\" THEN \"Clientes con compra TAG\" ' ||
    '   WHEN plantilla = \"4\" THEN \"Clientes con retiro en cajeros automaticos\" '||
    '   WHEN plantilla = \"5\" THEN \"Clientes en retiros de ventanilla\" '||
    ' END Descripcion,' ||
    ' CAST(COUNT(plantilla) as INTEGER) NumeroDeClientes ' ||
    ' FROM info_reporte_trimestral GROUP BY plantilla;" > '||RUTA_DESTINO||'sc_reporte_trimestral.sql';
    SYSTEM vsql;
    
    LET vsql ='';
    LET vsql= 'dbaccess intercard '||RUTA_DESTINO||'sc_reporte_trimestral.sql';
    SYSTEM vsql;
    
    LET vsql = '';
    LET vsql ='rm '||RUTA_DESTINO||'sc_reporte_trimestral.sql';
    SYSTEM vsql;

    LET vsql ='';
    LET vsql = "sed -e 's/|s//g' "||RUTA_DESTINO||"reporte_trimestral_captacion.unl >> "||RUTA_DESTINO||"reporte_trimestral_captacion_"|| LPAD (day(vfecha_hoy),2,"0")||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.txt';
    SYSTEM vsql;
    
    LET vsql ='';
    LET vsql ='rm '||RUTA_DESTINO||'reporte_trimestral_captacion.unl';
    SYSTEM vsql;
    
    DROP TABLE IF EXISTS info_reporte_trimestral;
    
    RETURN 	CODIGO_RETORNO,MENSAJE_RETORNO;
/*
-- Autor: [ agarciao@bancoppel.com ]
-- Modificado: 22.enero.2018 09:55:00am
-- Base de datos: intercard
-- Job: 533_REPORTE_TRIMESTRAL_CTES_CAPTA_INTERCARD_PRO
-- Descripcion:
-- Plantilla 1: Clientes con compra de tarjeta presente: sp_ctes_tdd_presente crea la tabla info_reporte_trimestral
-- Plantilla 2: Clientes con compra de tarjeta no presente: sp_ctes_tdd_no_presente
-- Plantilla 3: Clientes con compra TAG: sp_ctes_tdd_compratag
-- Plantilla 4: Clientes con retiros en cajeros automaticos: sp_ctes_tdd_retiros_atm
-- Plantilla 5: Clientes retiro o consulta de saldo en ventanilla: sp_ctes_tdd_ventanilla
-- Reporte de Conteo: El sp_reporte_trimestral_captacion borra la tabla info_reporte_trimestral
*/     
END;
END PROCEDURE;