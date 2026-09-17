CREATE PROCEDURE "informix".sp_bit_conc_hist_mc(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;

	/*
    *****************************************************************************************************
    -- DESCRIPCION:  GUARDA BITACORA  -------------------------------------------------------------------
	-- AUTOR : Softtek CASE3 ----------------------------------------------------------------------------
	-- FECHA : 05/03/2023  ------------------------------------------------------------------------------
	-- BD: bditarjeta  ----------------------------------------------------------------------------------
    -- SISTEMA : Pase a historico de conciliacion automatica MC  ----------------------------------------
	*****************************************************************************************************
	*/

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);

	/*INICIALIZACION DE VARIABLES*/

	LET visqlerr = 0;
	LET vssqlerr = '00000';

	BEGIN

		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

		--SET DEBUG FILE TO '/RESPALDOSNEW/case/ss_conciliacionautomatica_mc/bit_mc_to_hist.out';
		--TRACE ON;

		-----------------------------------------------------
		-----------------------------------------------------
		-----------------------------------------------------
		-----------------------------------------------------
		---PASE A HISTORICO DE CONCILIACION-AUTOMATICA-MC----
		--------2024/03/05-Softtek case3---------------------
		-----------------------------------------------------
		-----------------------------------------------------
		-----------------------------------------------------
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

        INSERT INTO bditarjeta:"informix".td_bitacora_pase_hist_cnc_mc(elemento, fecha, hora, actividad, cve_usuario)
        VALUES (psElemento
		,DATE((SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals))
		,TO_CHAR((SELECT DBINFO('utc_to_datetime', Sh_Curtime)::DATETIME YEAR TO FRACTION(5) FROM SysMaster:"informix".Sysshmvals),"%H:%M:%S")
		,psActividad
		,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;


	END

END PROCEDURE


;