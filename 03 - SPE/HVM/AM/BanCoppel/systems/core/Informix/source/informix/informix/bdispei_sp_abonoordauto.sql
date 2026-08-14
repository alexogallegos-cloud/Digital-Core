CREATE PROCEDURE "informix".sp_abonoordauto(pFechaValor date)

RETURNING char(5);

-- ***************************************************************************
-- sp_abonoordauto
-- Version              1.0.0
-- Obejtivo:            Abono Automatico Ordenes de pago a SPEI
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima Modificacion: Mayo - 2008
--                      Creación de SPL
-- ***************************************************************************

--//Definicion de variables
DEFINE v_codret          char(5);
DEFINE v_monto_abo       money(16,2);
DEFINE sql_err 	         integer;
DEFINE vintPkPago        integer;
DEFINE vcausadev         INTEGER;
DEFINE vmotivo           CHAR(40);


    LET v_codret = "000";

    --SET debug file to "/tmp/sp_abonoordauto.out";
    --TRACE on;

--//INICIA LA FUNCIONALIDAD
BEGIN

        --//Manejo de excepciones
        ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
	       LET v_codret = sql_err;
		   RETURN v_codret;
		END IF;
        END EXCEPTION;
        -- Establece Modo de Lectura
        SET isolation to dirty read;


	--//Envia los pagos pendientes por Abonar,
        --//solo para los tipos de pagos 3ro-3ro y participante-3ro.
        FOREACH WITH HOLD
	   SELECT intPkPago 
             INTO vintPkPago
             FROM vabono 
            WHERE dtfechavalor = pFechaValor
              AND chrEstatusEnvio='R'
              AND intcvetipopago in(1,5)

	   EXECUTE PROCEDURE sp_abonoordpago(vintPkPago)
	      INTO v_codret, vcausadev, vmotivo;


           LET vintPkPago = 0; 
        END FOREACH;
	RETURN v_codret;

END
END PROCEDURE;