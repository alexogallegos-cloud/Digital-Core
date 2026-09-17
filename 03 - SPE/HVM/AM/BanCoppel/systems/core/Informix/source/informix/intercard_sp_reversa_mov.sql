CREATE PROCEDURE "informix".sp_reversa_mov(pNumEmpleado CHAR(8), pTipoMov CHAR(3), pTipoReversa INTEGER)
RETURNING CHAR(6);

--Definicion de variables
DEFINE chrcodret        CHAR(6);
DEFINE intcodret          INT;
DEFINE vRegresa   INTEGER ;

BEGIN

    ON EXCEPTION SET intcodret
        IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            RETURN chrcodret;
        END IF;
    END EXCEPTION;

--Inicializacion de variables
    LET chrcodret  = '000';
    LET vRegresa = 0;

    IF pTipoMov <> 'TMC' AND pTipoMov <> 'TMD' AND pTipoMov <> 'VNC' AND pTipoMov <> 'VND' AND pTipoMov <> 'VIC' 
        AND pTipoMov <> 'VID' AND pTipoMov <> 'PNC' AND pTipoMov <> 'TCC' AND pTipoMov <> 'TCD' THEN

        LET chrcodret  = '001';

    ELSE

        SET ISOLATION TO DIRTY READ ;

        UPDATE movimiento set movconciliado = 'F'  WHERE secuencia IN (SELECT claveautdetransaccion FROM MovConciliados
        WHERE fechadeconciliacion LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' AND tipomovimiento = pTipoMov);

        DELETE FROM MovConciliados WHERE fechadeconciliacion LIKE '' || CAST(TO_CHAR(current, '%Y%m%d') as char(8)) || '%' AND tipomovimiento =  pTipoMov;

        DELETE FROM central WHERE FechaConciliacion >=  CAST ( TO_CHAR ( CURRENT, '%Y-%m-%d 00:00:00.0') as char (31) ) AND archivoorigen = pTipoMov ;

        IF pTipoMov = 'TMC' OR pTipoMov = 'TMD' THEN
            DELETE FROM conciliacion_atm_in WHERE FechaConciliacion >=  CAST ( TO_CHAR ( CURRENT, '%Y-%m-%d 00:00:00.0') as char (31) ) AND archivoorigen = pTipoMov;
            IF pTipoReversa = 1 THEN
                DELETE FROM log_atm WHERE FechaConciliacion >=  CAST ( TO_CHAR ( CURRENT, '%Y-%m-%d 00:00:00.0') as char (31) ) AND archivoorigen = pTipoMov;
            END IF ;
       ELSE
            DELETE FROM conciliacion_pos_in WHERE FechaConciliacion >=  CAST ( TO_CHAR ( CURRENT, '%Y-%m-%d 00:00:00.0') as char (31) ) AND archivoorigen = pTipoMov;
             IF pTipoReversa = 1 THEN
                DELETE FROM log_pos WHERE FechaConciliacion >=  CAST ( TO_CHAR ( CURRENT, '%Y-%m-%d 00:00:00.0') as char (31) ) AND archivoorigen = pTipoMov;
            END IF ;
       END IF ;

        EXECUTE PROCEDURE sp_insertar_bitacora(pNumEmpleado,pTipoMov,'REVERSA CONCILIACION','') INTO vRegresa;

    END IF ;

    RETURN chrcodret;

END;

END PROCEDURE;