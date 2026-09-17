CREATE PROCEDURE "informix".sp_insertactesitesp(pEmpresa char(3), pSucursal char(4), pOrigen smallint, pNumCliente char(20), pSituacion char(1), pCausa smallint, pusuarioalta char(8),
 pEmpleadoEfectuo char(8), pNombreEfectuo char(40))

    	RETURNING
    CHAR(6)   -- Codigo de Retorno

    --Elaboró : Diana Castellanos L.
    --Actividad : Inserta o actualiza el cambio de situacion esp
    -- en la tabla si_ctesitesp e inserta si_ctesitesphis

    DEFINE cVarDataErr      VARCHAR(64);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;

    DEFINE vCodRet                CHAR(6);
    --DEFINE pusuarioalta  CHAR(8);

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
            LET vCodRet=iSqlErr;
            Rollback;
            RETURN vCodRet;
        END IF;
    END EXCEPTION;


--    SET DEBUG FILE TO "grabacompromisosacuerdos.out";
--    TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET vCodRet        = "000";

BEGIN WORK;

IF pEmpresa <> '' AND pSucursal <> '' AND pusuarioalta <> ''  AND pNumCliente <> ''
    AND pSituacion  <> ''  AND pEmpleadoEfectuo  <> ''  AND pNombreEfectuo <> '' AND pOrigen <> 0 THEN

       IF NOT EXISTS(select numcte from bdisitesp:se_ctessitespcte where numcte = pNumCliente) then

            insert into bdisitesp:se_ctessitespcte (empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, 
	                                            nombreefectuo, fechamovto, usralta, fchalta, usrmodifica, fchmodifica)
            
	                values (pEmpresa, pNumCliente, pSituacion, pCausa, pOrigen, pSucursal, 'M', pEmpleadoEfectuo, pNombreEfectuo, current, pusuarioalta, TODAY, '', '');

             insert into bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo,
                                                         usralta, fchalta, usrmodifica, fchmodifica)
            values ('M', pNumCliente, pEmpresa, pSituacion, pCausa, pOrigen, pSucursal, pEmpleadoEfectuo, pusuarioalta, current,'','');

       ELSE

             IF pSituacion = 'C' THEN

                   Delete from bdisitesp:se_ctessitespcte  where numcte = pNumCliente;

                   insert into bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo,
                                                         usralta, fchalta, usrmodifica, fchmodifica)
            values ('E', pNumCliente, pEmpresa, pSituacion, pCausa, pOrigen, pSucursal, pEmpleadoEfectuo, pusuarioalta, current,'','');

            ELSE

                   Update bdisitesp:se_ctessitespcte
                    set empresa = pEmpresa, sucursal = pSucursal, cvesitesporigen = pOrigen, situacion = pSituacion, causa = pCausa, usralta = pusuarioalta,
                           empleadoefectuo = pEmpleadoEfectuo, nombreefectuo = pNombreEfectuo, fechamovto = current
                    where numcte = pNumCliente;

                   insert into bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo,
                                                               usralta, fchalta, usrmodifica, fchmodifica)
            values ('S', pNumCliente, pEmpresa, pSituacion, pCausa, pOrigen, pSucursal, pEmpleadoEfectuo, pusuarioalta, current,'','');

            END IF;

       END IF;
ELSE
    LET vCodRet        = "001";   --Falta algun parametro
END IF;

COMMIT WORK;

    RETURN vCodRet;

END;
END PROCEDURE;