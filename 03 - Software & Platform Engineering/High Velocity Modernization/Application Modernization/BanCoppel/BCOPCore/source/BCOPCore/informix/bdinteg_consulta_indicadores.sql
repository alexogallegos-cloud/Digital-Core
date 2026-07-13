CREATE PROCEDURE "informix".consulta_indicadores()
RETURNING CHAR(5),   --- CODIGO DE RETORNO
          CHAR(40),  --- EMPRESA
          DATE,      --- FECHA
          CHAR(1),   --- INDICADOR CIERRE CHEQUES
          CHAR(1),   --- INDICADOR DISPONIBILIDAD CHEQUES
          CHAR(1),   --- INDICADOR CIERRE CREDITO
          CHAR(1),   --- INDICADOR DISPONIBILIDAD CREDITO
          CHAR(1),   --- INDICADOR CIERRE INVERSIONES
          CHAR(1),   --- INDICADOR DISPONIBILIDAD INVERSIONES
          CHAR(1),   --- INDICADOR CIERRE SERVICIOS
          CHAR(20),  --- FECHA HORA
          CHAR(50);  --- DESCRIPCION CAMBIO
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    
    DEFINE vcEmpresa    CHAR(40);
    DEFINE vdFechaHoy   DATE;
    DEFINE vcCierreCred CHAR(1);
    DEFINE vcDisponCred CHAR(1);
    DEFINE vcCierreCheq CHAR(1);
    DEFINE vcDisponCheq CHAR(1);
    DEFINE vcCierreInv  CHAR(1);
    DEFINE vcDisponInv  CHAR(1);
    DEFINE vcCierreServ CHAR(1);
    DEFINE vcFechaHora  CHAR(20);
    DEFINE vcDescMotivo CHAR(50);
    
    LET viSqlErr     = 0;
    LET viIsamErr    = 0;
    LET vcDescErr    = '';
    LET vcCodRet     = '000';
    LET vcCodRet2    = '';
    LET vcCodRet3    = '';
    
    LET vcEmpresa    = '';
    LET vdFechaHoy   = '';
    LET vcCierreCred = '';
    LET vcDisponCred = '';
    LET vcCierreCheq = '';
    LET vcDisponCheq = '';
    LET vcCierreInv  = '';
    LET vcDisponInv  = '';
    LET vcCierreServ = '';
    LET vcFechaHora  = '';
    LET vcDescMotivo = '';
    
    --- SET DEBUG FILE TO "/tmp/consulta_indicadores.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/consulta_indicadores.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet, vcEmpresa, vdFechaHoy, vcCierreCheq, vcDisponCheq, vcCierreCred, vcDisponCred, vcCierreInv, vcDisponInv, vcCierreServ, vcFechaHora, vcDescMotivo;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT TRIM(empresa)||' '||TRIM(razon_social)
      INTO vcEmpresa
      FROM si_empresas
     WHERE empresa = '001';
     
    SELECT fecha_hoy, fecha_insert
      INTO vdFechaHoy, vcFechaHora
      FROM si_fechas
     WHERE empresa = '001';
    
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreCheq, vcDisponCheq
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreCred, vcDisponCred
      FROM bdicred:sd_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0'), NVL(ind_disponible, '0')
      INTO vcCierreInv, vcDisponInv
      FROM bdinvers:sv_fechas
     WHERE empresa = '001';
     
    SELECT NVL(ind_cierre, '0')
      INTO vcCierreServ
      FROM bdisac:sac_fechas
     WHERE empresa = '001';
     
    SELECT motivo_cambio
      INTO vcDescMotivo
      FROM si_bitacora_cierre
     WHERE fecha_cambio::date = vdFechaHoy
       AND fecha_cambio = ( SELECT MAX(fecha_cambio) FROM si_bitacora_cierre WHERE fecha_cambio::date = vdFechaHoy );
    
    RETURN vcCodRet, vcEmpresa, vdFechaHoy, vcCierreCheq, vcDisponCheq, vcCierreCred, vcDisponCred, vcCierreInv, vcDisponInv, vcCierreServ, vcFechaHora, vcDescMotivo;

    END;

END PROCEDURE;