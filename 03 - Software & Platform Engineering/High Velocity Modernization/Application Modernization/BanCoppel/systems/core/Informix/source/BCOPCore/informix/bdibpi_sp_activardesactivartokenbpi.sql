CREATE PROCEDURE "informix".sp_activardesactivartokenbpi(psTipo CHAR(1), psEmpresa CHAR(3), psNumCte CHAR(20), psStatusToken SMALLINT,
                    psSucursal CHAR(4), psNumEmpleado CHAR(9))
    RETURNING CHAR(5), CHAR(10);

--Declaracion de variables

DEFINE vsCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE viEdoCte SMALLINT;
DEFINE vsSolicitud CHAR(10);
DEFINE vdFecha  DATE;

--SET DEBUG FILE TO "/tmp/sp_ActivarDesactivarTokenBPI.out";
--TRACE ON;

--Asignacion de variables

LET vsCodRet = '00000';
LET viSqlErr = 0;
LET vsSolicitud = '';
LET vdFecha = '01-01-1900';

IF NVL(psTipo, '') = '' OR  NVL(psEmpresa, '') = '' OR NVL(psNumCte, '') = ''  OR  NVL(psStatusToken, '') = '' OR NVL(psSucursal, '') = '' OR NVL(psNumEmpleado, '') = '' THEN --Valida que  no sean nulo o espacio en blanco
    LET vsCodRet = '-2';
END IF;

--Inicio del procedimiento

BEGIN

    ON EXCEPTION SET viSqlErr --Manejador de Errores
        IF viSqlErr <> 0 then
            LET vsCodRet = viSqlErr;
            RETURN vsCodRet, vsSolicitud;
        END IF;
    END EXCEPTION;

    IF vsCodRet = '00000' THEN
        IF psTipo = '1' THEN        ---activavión

            LET vsSolicitud = (SELECT MAX(solicitud) FROM bdibpi:bpi_tokensolicitud WHERE numcte = psNumCte AND empresa = psEmpresa);

            UPDATE bdibpi:bpi_tokensolicitud SET id_status =  psStatusToken, f_solicitud = CURRENT, sucursal = psSucursal, usr_solicita = psNumEmpleado
            WHERE numcte = psNumCte AND empresa = psEmpresa AND solicitud = vsSolicitud;

            LET vdFecha = (SELECT MAX(f_registro::DATE) FROM bdinteg:si_bpitoken WHERE num_cliente =  psNumCte AND  empresa = psEmpresa);

            UPDATE bdinteg:si_bpitoken SET id_status_token = psStatusToken, f_status = CURRENT  WHERE empresa = TRIM(psEmpresa) AND num_cliente = TRIM(psNumCte)
            AND f_registro::DATE = vdFecha;

      --  ELIF psTipo = '2' OR psTipo = '3' THEN        -- Desactivacion    ---Consulta el último número de solicitud del cliente
         ELIF psTipo = '3' THEN
            LET vsSolicitud = (SELECT MAX(solicitud) FROM bdibpi:bpi_tokensolicitud WHERE numcte = psNumCte AND empresa = psEmpresa);

         --   IF psTipo = '2' THEN
         --       UPDATE bdibpi:bpi_tokensolicitud SET id_status =  psStatusToken
         --       WHERE numcte = psNumCte AND empresa = psEmpresa AND solicitud = vsSolicitud;
         --   END IF;

         ELSE
            LET vsCodRet = '-1';
        END IF
    END IF

   RETURN vsCodRet, vsSolicitud;

END
END PROCEDURE
DOCUMENT
"Realiza el envio de solicitud a central, y/o la consulta de la solicitud mas reciente del cliente",
"Autor : Dulce Ramírez",
"FECHA : Noviembre de 2009",
"Ver.  : 1.0",
"BD    : bdibpi",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_consultarclientebpi(pTipo CHAR(1), pEmpresa CHAR(3), pNumCte CHAR(20))

    --DATOS A REGRESAR---
    RETURNING
    CHAR(5),   -- Codigo de Retorno
    CHAR(10), -- Fecha Nacimiento
    CHAR(20), -- Numero de Cliente
    CHAR(26), -- Apellido Paterno
    CHAR(26), -- Apellido Materno
    CHAR(26), -- Nombre1
    CHAR(26), -- Nombre2
    CHAR(2),  -- Id Status
    CHAR(40), -- Descripción Status
    CHAR(165); -- Descrición Validación

    --DEFINICION DE VARIABLES--
    DEFINE sql_err      INT;
    DEFINE vCodRet      CHAR(5);
    DEFINE vFechaNac    CHAR(10);
    DEFINE vNumCte      CHAR(20);
    DEFINE vApePat      CHAR(26);
    DEFINE vApeMat      CHAR(26);
    DEFINE vNombre1     CHAR(26);
    DEFINE vNombre2     CHAR(26);
    DEFINE vStatus      CHAR(2);
    DEFINE vDescStatus  CHAR(40);
    DEFINE vMensValid   CHAR(165);
    DEFINE vTipoPersona CHAR(2);
    DEFINE cOperacion   CHAR(4);

        --INICIALIZACION DE VARIABLES--
    LET sql_err =   0;
    LET vCodRet =   '000';
    LET vFechaNac = '01/01/1900';
    LET vNumCte =   '';
    LET vApePat =   '';
    LET vApeMat =   '';
    LET vNombre1 =  '';
    LET vNombre2 =  '';
    LET vStatus     = '';
    LET vDescStatus = '';
    LET vMensValid  = '';
    LET vTipoPersona = '';
    LET cOperacion = '';

    --SET DEBUG FILE TO "/tmp/SP_ConsultarClienteBPI.out";
    --TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET vCodRet = sql_err;
            RETURN vCodRet, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vMensValid;
        END IF;
    END EXCEPTION;

    IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = pNumCte and tpo_persona = '01') THEN
        IF pTipo = '1' THEN
            IF (SELECT count(id_status) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte AND id_status <> '99') = 0 THEN
                IF (SELECT count(cuenta) FROM bdicheq:sc_maechq WHERE num_cte = pNumCte AND producto IN (SELECT producto FROM bdibpi:bpi_pprod WHERE id_oper = '1012')) > 0 THEN
                    IF EXISTS(SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sibpi.id_status
                              FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf, bdinteg:si_bpiusuarios bdi_sibpi
                              WHERE bdi_sicte.numcte = pNumCte
                              AND bdi_sicte.empresa = pEmpresa
                              AND bdi_sicte.tpo_persona = '01'
                              AND bdi_sicte.numcte = bdi_sictepf.numcte
                              AND bdi_sicte.numcte  = bdi_sibpi.numcte) THEN

                        SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sibpi.id_status
                        INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus
                        FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf, bdinteg:si_bpiusuarios bdi_sibpi
                        WHERE bdi_sicte.numcte = pNumCte
                        AND bdi_sicte.empresa = pEmpresa
                        AND bdi_sicte.tpo_persona = '01'
                        AND bdi_sicte.numcte = bdi_sictepf.numcte
                        AND bdi_sicte.numcte  = bdi_sibpi.numcte;
                    ELSE
                        SELECT bdi_sictepf.fecha_nac, bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2
                        INTO vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2
                        FROM bdinteg:si_cliente bdi_sicte, bdinteg:si_ctepf bdi_sictepf
                        WHERE bdi_sicte.numcte = pNumCte
                        AND bdi_sicte.empresa = pEmpresa
                        AND bdi_sicte.tpo_persona = '01'
                        AND bdi_sicte.numcte = bdi_sictepf.numcte
                        AND bdi_sicte.numcte = bdi_sictepf.numcte;
                    END IF;

                ELSE
                    LET vCodRet = '003';
                    LET vMensValid =   'Este usuario no puede ser pre-activado ya que aún no cuenta con alguno de los productos establecidos para otorgarle este servicio';
                END IF;
            ELSE
                LET vCodRet = '002';
                LET vMensValid =   'El Cliente ya tiene activado el servicio';
            END IF;
        ELIF pTipo = '2' THEN
            IF (SELECT count(id_status) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte) > 0 THEN
                IF (SELECT count(cuenta) FROM bdicheq:sc_maechq WHERE num_cte = pNumCte AND producto IN (SELECT producto FROM bdibpi:bpi_pprod WHERE id_oper = '1012')) > 0 THEN
                    SELECT id_status INTO vStatus FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCte;

                    IF vStatus = '99' THEN
                        LET vCodRet = '005';
                        LET vMensValid =   'El cliente presenta estatus de cancelado, si requiere el servicio de banca por internet es necesario ingresar a la sección de Activación de servicio por Internet';
                    ELSE
                        SELECT bdi_sicte.numcte, bdi_sicte.apell_paterno, bdi_sicte.apell_materno, bdi_sicte.nombre1, bdi_sicte.nombre2, bdi_sibpi.id_status, bdi_sista.desc_status
                        INTO vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus
                        FROM bdinteg:si_cliente bdi_sicte,
                            bdinteg:si_ctepf bdi_sictepf,
                            bdinteg:si_bpiusuarios bdi_sibpi,
                            bdinteg:si_bpistatus bdi_sista
                        WHERE bdi_sicte.numcte = pNumCte
                        AND bdi_sicte.empresa = pEmpresa
                        AND bdi_sicte.tpo_persona = '01'
                        AND bdi_sicte.numcte = bdi_sictepf.numcte
                        AND bdi_sicte.numcte = bdi_sibpi.numcte
                        AND bdi_sista.id_status = vStatus;
                    END IF;
                ELSE
                    LET vCodRet = '006';
                    LET vMensValid =  'Este usuario no puede ser bloqueado/desbloqueado ya que aún no cuenta con alguno de los productos establecidos para otorgarle este servicio';
                END IF;
            ELSE
                LET vCodRet =   '004';
                LET vMensValid =   'El Cliente no tiene activado el servicio';
            END IF;
        END IF;
    ELSE
        SELECT tpo_persona
        INTO vTipoPersona
        FROM bdinteg:si_cliente
        WHERE numcte = pNumcte;

        IF vTipoPersona = '02' THEN
            LET vCodRet = '002';
            LET vMensValid = 'Cliente Moral, verifique';
        ELSE
            LET vCodRet =   '001';
            LET vMensValid = 'Cliente no Existe';
        END IF
    END IF;
    RETURN vCodRet, vFechaNac, vNumCte, vApePat, vApeMat, vNombre1, vNombre2, vStatus, vDescStatus, vMensValid;
END
END PROCEDURE;