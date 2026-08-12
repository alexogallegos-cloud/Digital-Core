CREATE PROCEDURE "informix".sp_ideconsultarecofi(pNumeroCliente CHAR(20), pFecha CHAR(6), pSigRegistro SMALLINT)

		--*******************************************************************************************************
			-- Modifico   :Alejandro Osuna
			-- Actividad : Se modifico todas las variables money, se pasaron de (10,2) a (16,2)
			-- Fecha     : 07 de Enero de 2008
		--*******************************************************************************************************

	-- DATOS A REGRESAR
    RETURNING
    CHAR(5),    -- Codigo de Retorno
    DATE,       -- Fecha_Insert  Recaudaciones
    CHAR(20),   -- Num_cta       Recaudaciones
    CHAR(6),    -- Periodo       Recaudaciones
    MONEY(16,2);

    -- DEFINICION DE VARIABLES
    DEFINE vCantReg     SMALLINT;
    DEFINE vCodRet      CHAR(5);
    define AuxvCodRet   CHAR(6);
    DEFINE vFechainsR   DATE;
    DEFINE vNumctaR     CHAR(20);
    DEFINE vPeriodoR    CHAR(6);
    DEFINE vImprecR     MONEY(16,2);
    DEFINE vNumreg      SMALLINT;
    Define dDiaprimero date;
    Define dDiaUltimo  date;


    --INICIALIZACION DE VARIABLES--
    LET vCantReg = 0;
    LET vCodRet = "000";
    LET vNumctaR = "";
    LET vPeriodoR = "";
    LET vImprecR = 0;
    LET vNumreg = 0;

    execute procedure bdinteg:sp_diaprimeroultimomesanio(substr(pFecha, 5, 2), substr(pFecha, 1, 4) ) into AuxvCodRet, dDiaprimero, dDiaUltimo;
    If AuxvCodRet <> '000000' then
        Let vCodRet = '200'; --Error al calcular rangos de fechas
    End if;

    FOREACH
         SELECT
             fecha_ret, cuenta_ret, aniomes, imp_recaudado
        INTO
            vFechainsR, vNumctaR, vPeriodoR, vImprecR
        FROM
            sl_detlide
        WHERE
            num_cte = pNumeroCliente 
            --aniomes = pFecha 
            AND fecha_ret >= dDiaprimero 
            and fecha_ret <= dDiaUltimo
            
        ORDER BY cuenta_ret

        LET vNumreg = vNumreg + 1;
        IF vNumreg <= pSigRegistro THEN
            CONTINUE FOREACH;
        END IF

        IF vFechainsR IS NULL THEN
            LET vFechainsR = '01-01-1900';
        END IF;
        IF vNumctaR IS NULL THEN
            LET vNumctaR = "";
        END IF;
        IF vPeriodoR IS NULL  THEN
            LET vPeriodoR = "";
        END IF;
        IF vImprecR IS NULL THEN
            LET vImprecR = 0;
        END IF;
        LET vCantReg = vCantReg + 1;
        RETURN vCodRet, vFechainsR, vNumctaR, vPeriodoR, vImprecR WITH RESUME;
    END FOREACH;

    IF vCantReg = 0 THEN
        LET vCodRet = "100";
        LET vFechainsR = '01-01-1900';
        LET vNumctaR = "";
        LET vPeriodoR = "";
        LET vImprecR = 0;
        RETURN vCodRet, vFechainsR, vNumctaR, vPeriodoR, vImprecR;
    END IF
END PROCEDURE;