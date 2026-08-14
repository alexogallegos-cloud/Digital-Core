CREATE PROCEDURE "informix".ejecutor_diario(pFechaProceso DATE, pCve_Usuario CHAR(8))
---REGRESO
    RETURNING CHAR(5);

--DEFINICION DE VARIABLES
DEFINE v_cCod_Ret       CHAR(5); 
DEFINE vsqlerr          INTEGER ; 

---INICIALIZACION DE VARIABLES
LET v_cCod_Ret  = "00000";
LET vsqlerr 	= 0; 

BEGIN
    ON EXCEPTION  SET vsqlerr
        IF vsqlerr <> 0  THEN
             LET  v_cCod_Ret  = vsqlerr;
            RETURN v_cCod_Ret;
        END IF;
     END  EXCEPTION;
-- Borra los movimientos
    DELETE bdicheq:sc_movdia;
    DELETE bdicred:sd_movdia;

-- Actualiza fechas de Captacion, Credito e Integral
   UPDATE bdinteg:si_fechas SET  fecha_hoy = pFechaProceso;
   UPDATE bdicred:sd_fechas SET  fecha_hoy = pFechaProceso;
   UPDATE bdicheq:sc_fechas SET  fecha_hoy = pFechaProceso;

-- CARGA MOVIMIENTOS DESDE MOVHIS A MOVDIA
--- DEBITO
INSERT INTO bdicheq:sc_movdia  SELECT num_serial, folio_suc, sucursal, usuario, fech_alt, fech_val, fech_hor, transacc,
            suc_cuen, producto, empresa, cuenta, causa_dev, num_cheq, monto_tot, firme, en_sbc, remesas, dias_ret, 
            cancelad, edo_cta, sdo_cuenta, transacc_suc, referencia, tasa_aplicada, num_tarjeta, usuautoriza 
            FROM bdicheq:sc_movhis WHERE fech_alt = pFechaProceso;

--- CREDITO
INSERT INTO bdicred:sd_movdia  SELECT * FROM bdicred:sd_movhis WHERE fecha_mov = pFechaProceso;

END;
RETURN v_cCod_Ret;
END PROCEDURE;