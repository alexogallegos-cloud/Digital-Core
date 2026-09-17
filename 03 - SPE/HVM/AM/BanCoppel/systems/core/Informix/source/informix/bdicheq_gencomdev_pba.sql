CREATE PROCEDURE "informix".gencomdev_pba( pempresa   CHAR(3),
                                       pcuenta    CHAR(20),
                                       ptransacc  CHAR(4),
                                       pcheque    INTEGER,
                                       pfolsuc    CHAR(16),
                                       pmonto     MONEY(14,2),
                                       ppropio    CHAR(1),
                                       psucursal  CHAR(4),
                                       pusuario   CHAR(8),
                                       pdivisa    CHAR(2) )
RETURNING CHAR(5);

    DEFINE vsqlerr          INTEGER;
    DEFINE vcodret          CHAR(5);
    DEFINE vfecha_hoy       DATE;
    DEFINE vfechacalENDario DATE;
    DEFINE vcomision        CHAR(4);
    DEFINE vcodigo_param    CHAR(2);
    DEFINE vcalcula_com     CHAR(1);
    DEFINE vmonto_com       MONEY(14,2);
    DEFINE vestado          CHAR(1);
    DEFINE vsuccta          CHAR(4);
    DEFINE vproducto        CHAR(4);
    DEFINE vsdo_actual      MONEY(14,2);
    DEFINE vtrancarref      CHAR(4);
    DEFINE vtranaboref      CHAR(4);
    DEFINE vhorax           DATETIME HOUR TO FRACTION(3);
    DEFINE vmaxsec          SMALLINT;
    DEFINE vnum_tarjeta     CHAR(16);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vComxChqExp      CHAR(4);
    DEFINE vBanco           CHAR(3);
	DEFINE vfecha_operacion DATE;

    ON EXCEPTION SET vsqlerr
        set debug file to "/tmp/gencomdev_pba.err";
        trace on;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF
    END exception;
    
    set debug file to "/tmp/gencomdev_pba.out";
    trace on;

    LET vcodret = "000";
	LET vfecha_operacion = TODAY;

    SELECT {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      INTO vfechacalendario
      FROM sc_fechas 
     WHERE empresa = pempresa;

    SELECT fecha_proceso, status_cta
      INTO vfecha_hoy, vstatus_cta
      FROM sc_maechq
     WHERE empresa = pempresa
       AND cuenta = pcuenta;

    IF (vfecha_hoy IS NULL OR vstatus_cta = '4' OR vstatus_cta = '5') THEN
        LET vfecha_hoy = vfechacalendario;
    END IF    

    IF (vfecha_hoy < vfechacalendario ) THEN
        LET vcodret = "549";
        RETURN  vcodret;
    END IF   
    
    IF (vstatus_cta IN('2','6','7','8') ) THEN
        LET vcodret = "200";
        RETURN  vcodret;
    END IF   

    SELECT MAX(secuencia) 
      INTO vmaxsec
      FROM sc_tarjeta
     WHERE empresa = pempresa 
       AND cuenta = pcuenta 
       AND tipo_tarjeta = "T";

    SELECT num_tarjeta 
      INTO vnum_tarjeta
      FROM sc_tarjeta
     WHERE empresa = pempresa 
       AND cuenta = pcuenta 
       AND secuencia = vmaxsec;

    SELECT valor 
      INTO vBanco
      FROM bdinteg:si_param
     WHERE empresa = pempresa
       AND cod_param = 5;

    IF ppropio = "1" THEN --Cheque propio
        SELECT comision 
          INTO vComxChqExp
          FROM sc_transcomis
         WHERE empresa = pempresa
           AND transacc = ptransacc;

        SELECT sucursal,producto,sdo_actual
          INTO vsuccta,vproducto,vsdo_actual
          FROM sc_maechq
         WHERE empresa = pempresa 
           AND cuenta = pcuenta;

        SELECT valor 
          INTO vtrancarref
          FROM sc_param
         WHERE empresa = pempresa 
           AND codparam = "trancarref";

        SELECT valor 
          INTO vtranaboref
          FROM sc_param
         WHERE empresa = pempresa 
           AND codparam = "tranaboref";

        IF vtranaboref <> " " AND vtranaboref IS NOT NULL THEN
            LET vhorax = CURRENT HOUR TO FRACTION(3);
            
            INSERT INTO sc_movdia VALUES
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
            vhorax,vtranaboref,vsuccta,vproducto,pempresa,pcuenta,
            " ",pcheque,pmonto,0,0,0,0, " ",vstatus_cta,vsdo_actual,"0000",
            "Cheque Devuelto No. "|| trim(pcheque::char(7)) || " Insuf. Fondos",  0," ", " ", "", vfecha_operacion);
        END IF

        IF vtrancarref <> " " AND vtrancarref IS NOT NULL THEN
            LET vhorax = CURRENT HOUR TO FRACTION(3);
            
            INSERT INTO sc_movdia VALUES
            (0,pfolsuc,psucursal,pusuario,vfecha_hoy,vfecha_hoy,
            vhorax,vtrancarref,vsuccta,vproducto,pempresa,pcuenta," ",
            pcheque,pmonto,0,0,0,0, " ",vstatus_cta,vsdo_actual,"0000",
            "Cheque Devuelto No. "|| trim(pcheque::char(7)) || " Insuf. Fondos",  0, " ", " ", "", vfecha_operacion);
        END IF

        UPDATE sc_maechq
           SET chq_dev = chq_dev + 1,
               monto_dev = monto_dev + pmonto,
               fec_ult_mov = vfecha_hoy
         WHERE empresa = pempresa 
           AND cuenta = pcuenta;

        UPDATE {+INDEX(sc_contch idx_contch2)} sc_contch
           SET estado = "U",
               fecha_alta = vfecha_hoy,
               importe = pmonto
         WHERE empresa = pempresa 
           AND cuenta = pcuenta 
           AND numero = pcheque;


        INSERT INTO sc_chequedev(empresa, cuenta, fecha, numerochq, importechq, banco)
        VALUES(pempresa, pcuenta, vfecha_hoy, pcheque, pmonto, vBanco);


        CALL cargo_comisiones_pba(pempresa, pcuenta, vComxChqExp, pmonto, pfolsuc, psucursal, pusuario, pcheque, pdivisa, vfecha_hoy)
        RETURNING vcodret;

    ELSE
        UPDATE sc_maechq
           SET chq_dev_obco = chq_dev_obco + 1,
               fec_ult_mov = vfecha_hoy
         WHERE empresa = pempresa 
           AND cuenta = pcuenta;
    END IF

    RETURN vcodret;

END PROCEDURE

DOCUMENT
"Genera comisiones por devolucion de cheque",
"Realizado Por Procesamiento Interactivo",
"Ver 1.0 10/Marzo/2003 Mod: 27/01/10 Gpo PISA";

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