CREATE PROCEDURE "informix".conscreciente(pEmpresa CHAR(3),
                                    pNumeroCuenta CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	DATE,     -- Fecha Inicio
	DATE,     -- Fecha Fin
	CHAR(1),  -- Tipo de Tasa M Mes P Meta
	DECIMAL(9,6), -- Valor Tasa
	DECIMAL(14,2), -- Interes Acumulado
	DECIMAL(14,2), -- Monto ISR
	DECIMAL(9,6); -- Tasa ISR


	--DEFINICION DE VARIABLES--
	DEFINE vCantReg		SMALLINT;
	DEFINE vCodRet		CHAR(5);
	DEFINE vFecha1	        DATE;
	DEFINE vFecha2    	DATE;
	DEFINE vTipo_Tasa       CHAR(1);
	DEFINE vTasaInt		DECIMAL(9,6);
	DEFINE vMontoInt	DECIMAL(14,2);
	DEFINE vMontoIsr	DECIMAL(14,2);
	DEFINE vTasaIsr		DECIMAL(9,6);

	--INICIALIZACION DE VARIABLES--
	LET vCodRet = "000";
	LET vCantReg = 0;
        LET vFecha1 = "";
        LET vFecha2 = "";
        LET vTipo_Tasa = "";
        LET vTasaInt = 0;
        LET vMontoInt = 0;
        LET vMontoIsr = 0;
        LET vTasaIsr = 0;


	FOREACH
		SELECT  inicio_periodo,fin_periodo,tipo_tasa,
                        valor_tasa,int_acum,isr,tasa_isr
		INTO
			vFecha1, vFecha2, vTipo_Tasa,
                        vTasaInt, vMontoInt, vMontoIsr, vTasaIsr
		FROM
                        sc_tasa_variable
		WHERE
			empresa = pEmpresa AND
			cuenta = pNumeroCuenta
		ORDER BY 3,1

			LET vCantReg = vCantReg + 1;

			RETURN vCodRet,vFecha1, vFecha2, vTipo_Tasa,
                        vTasaInt, vMontoInt, vMontoIsr, vTasaIsr WITH RESUME;
	END FOREACH;

	IF vCantReg = 0 THEN
           LET vCodRet		= "100";
           RETURN vCodRet,vFecha1, vFecha2, vTipo_Tasa,
                  vTasaInt, vMontoInt, vMontoIsr, vTasaIsr;
	END IF
END PROCEDURE;