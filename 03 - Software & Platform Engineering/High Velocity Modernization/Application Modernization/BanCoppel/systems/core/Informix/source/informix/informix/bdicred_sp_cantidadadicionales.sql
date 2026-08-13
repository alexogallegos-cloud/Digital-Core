CREATE PROCEDURE "informix".sp_cantidadadicionales(pNumeroCuenta char(13))
        -- DATOS A REGRESAR

        RETURNING
        char(5),        -- Codigo de retorno
        char(3);
        -- Declaracion de variables

        DEFINE vCodRet          char(5);
        DEFINE vCanReg          char(3);

        -- Se Inicializan las Variables

        LET vCodRet  = "00000";
        LET vCanReg = "000";

        BEGIN
                 -- Se verifica que exista el número de cuenta
                IF EXISTS (SELECT TRIM(num_credito) from bdicred:sd_tarjeta WHERE TRIM(num_credito) = TRIM(pnumerocuenta)) THEN

                        SELECT COUNT(num_credito)
                                INTO vCanReg
                                FROM bdicred:sd_tarjeta
                                WHERE TRIM(num_credito) = TRIM(pnumerocuenta) AND tipo_tarjeta='A' AND status_tar = 'A';

                        IF vCanReg IS NULL OR vCanReg = 0 THEN

                                LET vCanReg ="001";
                                LET vCodRet = "00000";

                        ELSE

                                IF (vCanReg = 1) THEN

                                        LET vCanReg ="002";
                                        LET vCodRet = "00000";
                                ELSE
                                        LET vCanReg ="003";
                                        LET vCodRet = "00000";
                                END IF;
                        END IF;

                ELSE  --Cuenta No existe

                        LET vCodRet = "100";
                        LET vCanReg ="";
                END IF;
                RETURN vCodRet , vCanReg;
        END;

END PROCEDURE

DOCUMENT
"Elaboro : Adrian Acosta Solis",
"FECHA : 16/Marzo/2007",
"Ver.  : 1.1",
"BD    : bdicred",
"VER   : 1.1";

create procedure "informix".cal_habil_ant(
			pfecha date)
                       	RETURNING char(5),date;

   DEFINE v_codret 	char(5);
   DEFINE v_habil_ant 	date;
   DEFINE v_esferiado 	char(1);
   DEFINE v_bandera	char(1);
   DEFINE v_fecha	date;
   DEFINE sql_err,isam_err int;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_habil_ant = " ";
   LET v_esferiado = "0";




-- ****************************************************************************
-- valida datos de entrada
-- ****************************************************************************

	IF  	pfecha is null THEN
		-- datos de entrada incompletos
		LET v_codret = 110;
		RETURN v_codret,v_habil_ant;
	END IF;


BEGIN

	on exception set sql_err,isam_err
	if sql_err <> 0 or isam_err <> 0 then
	 let v_codret = sql_err;
	 return v_codret,v_habil_ant;
	end if;
	end exception;

	LET v_fecha = pfecha;


	select "1"
	into v_esferiado
	from bdinteg:si_feriado
	where fecha=v_fecha;

	IF v_esferiado is null THEN
		LET v_esferiado = "0";
	END IF

	IF v_esferiado <>"1" and to_char(v_fecha,"%A") <> "Saturday" and to_char(v_fecha,"%A") <> "Sunday"  THEN
		LET v_fecha = v_fecha - 1;
	END IF


	IF v_esferiado = "1"   THEN
		LET v_fecha = v_fecha - 1;
	END IF

	IF to_char(v_fecha,"%A") = "Saturday"  THEN
		LET v_fecha = v_fecha - 1;
	END IF

	IF to_char(v_fecha,"%A") = "Sunday"  THEN
		LET v_fecha = v_fecha - 2;
	END IF




	-- barrer hasta obtener el sig. habil

	LET v_bandera = "0";
	WHILE v_bandera = "0"

		-- validar si es feriado la nueva fecha
		select "1"
		into v_esferiado
		from bdinteg:si_feriado
		where fecha=v_fecha;

		IF v_esferiado is null THEN
			LET v_esferiado = "0";
		END IF

		IF v_esferiado <> "1" and to_char(v_fecha,"%A") <> "Saturday" and to_char(v_fecha,"%A") <> "Sunday" THEN
			-- salir
			LET v_bandera = "1";
		ELSE

			LET v_fecha = v_fecha - 1;
		END IF

	END WHILE



	LET v_habil_ant = v_fecha;

END;

RETURN v_codret,v_habil_ant;

END PROCEDURE;