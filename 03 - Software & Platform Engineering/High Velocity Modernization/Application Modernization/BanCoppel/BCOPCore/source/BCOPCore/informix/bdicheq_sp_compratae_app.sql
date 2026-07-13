CREATE PROCEDURE "informix".sp_compratae_app(
pempresa    char(3),
psucursal   char(4),
pusuario    char(8),
ptransacc   char(4),
ptransuc    char(4),
pfolsuc     char(16),
pcuenta     char(20),
pcheque     integer,
pmonto      money(14,2),
pdivisa     char(2),
preferencia char(40),
pnum_tarjeta char(16),
pusuautoriza char(8) )

RETURNING CHAR(5), CHAR(4), DATE, MONEY(14,2), MONEY(14,2);

    -- Realizo   : Ivan Rafael Escalona Benitez
    -- Actividad : Control de ejecucion de proceso cargo_ref
    -- SolicitÃ³  : Luis Barragan
    -- Fecha     : 29/01/2023
	--******************************************************
	

       DEFINE vcodret   	char(5);
       DEFINE vcodretRev   	char(5);
       DEFINE sql_err   	integer;
       DEFINE vTrans    	char(4);
       DEFINE vFechaHoy 	date;
       DEFINE vSdoDisp  	money(14,2);
       DEFINE vMontoRet 	money(14,2);
       DEFINE vPasoCargo 	char(1);
       DEFINE vMensajeRet 	char(100);
	   
	    LET vTrans		= '';
		LET vFechaHoy	= '';
		LET vSdoDisp	= '0';
		LET vMontoRet	= '0';
	   
	   LET vPasoCargo 	= '0';
	   LET vcodret 		= '000';
	   LET vcodretRev 	= '000';
	   LET vMensajeRet 	= '';
	   LET vPasoCargo 	= '0';
       LET vcodret 		= '000';
	   LET vcodretRev 	= '000';
	   LET vMensajeRet 	= '';




BEGIN

   ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
				
        LET vcodret = sql_err;
        RETURN vcodret,vTrans,vFechaHoy,vSdoDisp,vMontoRet;
       END IF;
END EXCEPTION;

--set debug file to '/ifxsif01/ireb/sp_compratae_app.out';
--trace on;

            EXECUTE PROCEDURE cargo_ref(pEmpresa,
                                        pSucursal,
                                        pUsuario,
                                        ptransacc,
                                        ptransuc,
                                        pfolsuc,
                                        pcuenta,
                                        pcheque,
                                        pmonto,
                                        pdivisa,
                                        preferencia,
                                        pnum_tarjeta,
                                        pusuautoriza) INTO vcodret,
                                                           vTrans,
                                                           vFechaHoy,
                                                           vSdoDisp,
                                                           vMontoRet;

            IF vcodret <> '000' THEN
                RETURN vcodret,vTrans,vFechaHoy,vSdoDisp,vMontoRet;
            ELSE
                LET vPasoCargo = '1';
            END IF;
END;
RETURN vcodret,vTrans,vFechaHoy,vSdoDisp,vMontoRet;

END PROCEDURE;