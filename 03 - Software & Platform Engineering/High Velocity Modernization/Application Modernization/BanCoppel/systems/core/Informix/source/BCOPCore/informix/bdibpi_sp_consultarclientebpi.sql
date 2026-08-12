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