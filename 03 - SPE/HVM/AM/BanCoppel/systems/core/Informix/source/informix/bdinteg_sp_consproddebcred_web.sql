CREATE PROCEDURE "informix".sp_consproddebcred_web(pEmpresa CHAR(3), pSistema SMALLINT, pNumCta CHAR(20), pNumTarjeta CHAR(20))
	RETURNING CHAR(5), CHAR(4), CHAR(40);

	-- *DEFINICION DE VARIABLES*
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cProducto CHAR(4);
	DEFINE cDescProducto CHAR(40);
	DEFINE cNumCuenta CHAR(20);

	-- *ASIGNACION DE VARIABLES*
	LET cCodRet = "00000";
	LET iSqlErr = 0;
	LET cProducto = "";
	LET cDescProducto = "";
	LET cNumCuenta = "";

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, cProducto, cDescProducto;
			END IF;
		END EXCEPTION;

	--	SET DEBUG FILE TO "/tmp/sp_ConsProdDebCred.out";
	--	TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- Valida Parametros de Entrada
		IF NVL(pEmpresa, "") = "" OR NVL(pSistema, 0) = 0 THEN
			LET cCodRet = "00110";
			RETURN cCodRet, cProducto, cDescProducto;
		END IF

		IF pSistema = 1 then -- Sistema de Cheques
			IF NVL(pNumCta, "") <> "" THEN
				SELECT producto INTO cProducto
				FROM bdicheq:sc_maechq
				WHERE empresa = pEmpresa AND cuenta = pNumCta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "00100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT nombre INTO cDescProducto
				FROM bdicheq:sc_producto
				WHERE empresa = pEmpresa AND producto = cProducto;
			ELIF NVL(pNumTarjeta, "") <> "" THEN
				SELECT cuenta INTO cNumCuenta
				FROM bdicheq:sc_tarjeta
				WHERE empresa = pEmpresa AND num_tarjeta = pNumTarjeta;

				IF cNumCuenta IS NULL OR cNumCuenta = "" THEN
					LET cCodRet = "00100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT producto INTO cProducto
				FROM bdicheq:sc_maechq
				WHERE empresa = pEmpresa AND cuenta = cNumCuenta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "00100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT nombre INTO cDescProducto
				FROM bdicheq:sc_producto
				WHERE empresa = pEmpresa AND producto = cProducto;
			ELSE
				LET cCodRet = "00110";
				RETURN cCodRet, cProducto, cDescProducto;
			END IF;
		ELIF pSistema = 6 then -- Sistema de Credito
			IF NVL(pNumCta, "") <> "" THEN
				SELECT num_producto INTO cProducto
				FROM bdicred:sd_maecred
				WHERE empresa = pEmpresa AND num_credito = pNumCta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "00100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT nombre_prod INTO cDescProducto
				FROM bdicred:sd_definicion
				WHERE empresa = pEmpresa AND num_producto = cProducto;
			ELIF NVL(pNumTarjeta, "") <> "" THEN
				SELECT num_credito INTO cNumCuenta
				FROM bdicred:sd_tarjeta
				WHERE empresa = pEmpresa AND num_tarjeta = pNumTarjeta;

				IF cNumCuenta IS NULL OR cNumCuenta = "" THEN
					LET cCodRet = "00100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT num_producto INTO cProducto
				FROM bdicred:sd_maecred
				WHERE empresa = pEmpresa AND num_credito = cNumCuenta;

				IF cProducto IS NULL OR cProducto = "" THEN
					LET cCodRet = "00100";
					RETURN cCodRet, cProducto, cDescProducto;
				END IF;

				SELECT nombre_prod INTO cDescProducto
				FROM bdicred:sd_definicion
				WHERE empresa = pEmpresa AND num_producto = cProducto;
			ELSE
				LET cCodRet = "00110";
				RETURN cCodRet, cProducto, cDescProducto;
			END IF;
		END IF;
		RETURN cCodRet, cProducto, cDescProducto;
	END
END PROCEDURE
DOCUMENT
"DESCRIPCION: Consulta el Numero y Descripcion del Producto de la Cuenta o Tarjeta",
"AUTOR: Iris Arias Zazueta",
"FECHA: 08/11/2010",
"BD: bdicred";

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