CREATE PROCEDURE "informix".sp_bitacora_cierresesion_bpi(
pIdOperacion CHAR(4),
pNumCte CHAR(9),
pIdUsuario CHAR(15),
pIpUsuario CHAR(15),
pNavegador CHAR(20),
pSisOperativo CHAR(30),
pIdTipoCierre SMALLINT,
pDescripcionCierre CHAR(50),
pLatitud CHAR(100),
pLongitud CHAR(100),
pVersion CHAR(10),
pFechaRegistro DATETIME year to second)
 returning CHAR(5);

--DefiniciÃ³n de variables
DEFINE cod_ret CHAR(5);
DEFINE sql_err INTEGER;
DEFINE vNumCte CHAR(9);
DEFINE vIdUsuario CHAR(15);
DEFINE vFrecuencia SMALLINT;

--Inicializa variables
LET cod_ret  = "00000";
LET vNumCte = NULL;
LET vIdUsuario = NULL;
LET vFrecuencia = NULL;

   --SET DEBUG FILE TO "/home/sysaccapp/Viridiana/sp_bitacora_cierresesion_bpi.out";
   --TRACE ON;

BEGIN
	
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret;
      END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
    -- Intentar obtener coincidencias existentes
    SELECT FIRST 1
        numcte,
        idusuario,
        frecuencia
    INTO
        vNumCte,
        vIdUsuario,
        vFrecuencia
    FROM bdibpi:bpi_bitacora_cierresesion
    WHERE (numcte = pNumCte OR idusuario = pIdUsuario)
      AND ip_usuario = pIpUsuario
      AND navegador = pNavegador
      AND sis_operativo = pSisOperativo
      AND id_tipo_cierre = pIdTipoCierre
      AND descripcion_cierre = pDescripcionCierre;

    LET vFrecuencia = NVL(vFrecuencia, 1);
	

    -- Validar si se encontrÃ³ un registro
    IF (vNumCte !='null' AND vIdUsuario IS NOT NULL)
    THEN                                              
        UPDATE bdibpi:bpi_bitacora_cierresesion
        SET frecuencia = vFrecuencia + 1,
            dispositivo = pVersion,
            latitud = pLatitud,
            longitud = pLongitud,
            fecha_ultimamod = pFechaRegistro
        WHERE (numcte = pNumCte OR idusuario = pIdUsuario)
          AND ip_usuario = pIpUsuario
          AND navegador = pNavegador
          AND sis_operativo = pSisOperativo
          AND id_tipo_cierre = pIdTipoCierre
          AND descripcion_cierre = pDescripcionCierre;
    ELIF (vNumCte ='null' AND vIdUsuario IS NOT NULL)
    THEN                                               
        UPDATE bdibpi:bpi_bitacora_cierresesion
        SET numcte = pNumCte,
		    frecuencia = vFrecuencia + 1,
            dispositivo = pVersion,
            latitud = pLatitud,
            longitud = pLongitud,
            fecha_ultimamod = pFechaRegistro
        WHERE (numcte = pNumCte OR idusuario = pIdUsuario)
          AND ip_usuario = pIpUsuario
          AND navegador = pNavegador
          AND sis_operativo = pSisOperativo
          AND id_tipo_cierre = pIdTipoCierre
          AND descripcion_cierre = pDescripcionCierre;
    ELSE
        INSERT INTO bdibpi:bpi_bitacora_cierresesion ( 
            numcte,
            idusuario,
            dispositivo,
            ip_usuario,
            navegador,
            sis_operativo,
            id_tipo_cierre,
            descripcion_cierre,
            frecuencia,
            latitud,
            longitud,
            fecha_registro,
            fecha_ultimamod
        ) VALUES (
            pNumCte,
            pIdUsuario,
            pVersion,
            pIpUsuario,
            pNavegador,
            pSisOperativo,
            pIdTipoCierre,
            pDescripcionCierre,
            vFrecuencia,
            pLatitud,
            pLongitud,
            pFechaRegistro,
            pFechaRegistro
        );
    END IF; 
	
	RETURN cod_ret;
END;
END PROCEDURE;