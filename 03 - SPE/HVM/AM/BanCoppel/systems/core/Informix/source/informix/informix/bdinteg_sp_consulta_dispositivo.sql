CREATE PROCEDURE "informix".sp_consulta_dispositivo(pMac CHAR(12))

RETURNING   CHAR(5)  AS codigoRetorno,
            CHAR(40) AS descripcionCodRet,
            CHAR(4)  AS sucursal, 
            CHAR(12) AS mac, 
            CHAR(16) AS ipmaquina, 
            CHAR(2)  AS area, 
            CHAR(50) AS tipodispositivo, 
            CHAR(25) AS marcadispositivo, 
            CHAR(25) AS modelodispositivo, 
            CHAR(40) AS descripciondispositivo, 
            CHAR(15) AS seriedispositivo,
            CHAR(16) AS ipdispositivo;

--definicion de variables--               
DEFINE  codigoRetorno           CHAR(5);
DEFINE  iSql_err                 INTEGER;
DEFINE  descripcionCodRet       CHAR(40);
DEFINE  sucursal                CHAR(4);
DEFINE  mac                     CHAR(12);
DEFINE  ipmaquina               CHAR(16);
DEFINE  area                    CHAR(2);
DEFINE  tipodispositivo         CHAR(50);
DEFINE  marcadispositivo        CHAR(25);
DEFINE  modelodispositivo       CHAR(25);
DEFINE  descripciondispositivo  CHAR(40);
DEFINE  seriedispositivo        CHAR(15);
DEFINE  ipdispositivo           CHAR(16);
        
-- InicializaciÃÂ³n de las variables.
LET  codigoRetorno           = '00000';
LET  iSql_err                = 0;
LET  descripcionCodRet       = '';
LET  sucursal                = '';
LET  mac                     = '';
LET  ipmaquina               = '';
LET  area                    = '';
LET  tipodispositivo         = '';
LET  marcadispositivo        = '';
LET  modelodispositivo       = '';
LET  descripciondispositivo  = '';
LET  seriedispositivo        = '';
LET  ipdispositivo           = '';

BEGIN

    ON EXCEPTION SET iSql_err
        IF iSql_err <> 0 THEN
            LET codigoRetorno = iSql_err;
            LET descripcionCodRet = 'Consulta No exitosa';
            RETURN codigoRetorno, descripcionCodRet, sucursal, mac, ipmaquina, area, tipodispositivo, marcadispositivo, modelodispositivo, descripciondispositivo, seriedispositivo, ipdispositivo;
        END IF;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    IF NVL(pMac,'') = '' THEN
		LET codigoRetorno = '00001';
        LET descripcionCodRet = 'Consulta No exitosa';
		RETURN codigoRetorno, descripcionCodRet, sucursal, mac, ipmaquina, area, tipodispositivo, marcadispositivo, modelodispositivo, descripciondispositivo, seriedispositivo, ipdispositivo;
    END IF;

        FOREACH
                 SELECT ssm.sucursal, 
                       ssm.mac, 
                       ssm.ipmaquina, 
                       ssm.area,
                       scm.tipodispositivo,
                       smad.marcadispositivo, 
                       smod.modelodispositivo, 
                       std.descripciondispositivo, 
                       std.seriedispositivo,
                       std.ipdispositivo
                    INTO sucursal, mac, ipmaquina, area, tipodispositivo, marcadispositivo, modelodispositivo, descripciondispositivo, seriedispositivo, ipdispositivo
                    FROM si_sucursalesmaquina ssm 
                    INNER JOIN si_configuracionmaquina scm ON scm.mac = ssm.mac 
                    INNER JOIN si_tipodispositivo std ON std.idtipodispositivo = scm.idtipodispositivo 
                    INNER JOIN si_marcadispositivo smad ON smad.idmarcadispositivo = std.idmarcadispositivo
                    INNER JOIN si_modelodispositivo smod ON smod.idmodelodispositivo = std.idmodelodispositivo
                    WHERE ssm.mac = pMac

             LET descripcionCodRet = 'Consulta exitosa';
            RETURN codigoRetorno, descripcionCodRet, sucursal, mac, ipmaquina, area, tipodispositivo, marcadispositivo, modelodispositivo, descripciondispositivo, seriedispositivo, ipdispositivo WITH resume;
        END FOREACH;
    END
END PROCEDURE;