create procedure "informix".val_fechas_web(pempresa char(3), pfecha date)
	returning char(5);

	-- Define variables de trabajo
	define vcodret char(5);
	define vsqlerr integer;
	define vfecha_hoy date;

	begin
		on exception set vsqlerr
			if vsqlerr <> 0 then
				let vcodret = vsqlerr;
				return vcodret;
			end if
		end exception;

		-- Inicializa Variables
		let vcodret = "00000";

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--
		if pfecha = mdy('04','08','2014') then
			let vcodret = "00000";
			return vcodret;
		end if

		-- extrae fecha del sistema integral
		select fecha_hoy into vfecha_hoy
		from si_fechas where empresa = pempresa;
		if pfecha != vfecha_hoy then
			let vcodret = "00809";
			return vcodret;
		end if

		return vcodret;
	end
end procedure
DOCUMENT
"Valida fecha de OFI contra fechas del central",
"Autor : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Manuel HernÂ ndez",
"FECHA : 12/Septiembre/2006",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1";

CREATE PROCEDURE "informix".sp_actualiza_status_token_bpi_web(pEmpresa char (3), pNumCte char(9), pStatus integer, pNSToken char(10))
	RETURNING char (5), integer;

--Realizo: Javier Calderon
--Fecha: 02/01/09
--Solicito: Mauricio Leon
--Actividad: Actualiza el status y fecha de status del token asignado al cliente

--Define variables
define sql_err integer;
define cod_ret char (5);


--Inicializa variables
LET sql_err = '';
LET cod_ret = '00000';


BEGIN

 ON EXCEPTION SET sql_err
          LET cod_ret = sql_err;
      RETURN  cod_ret, 0;
   END EXCEPTION;
   
   SET ISOLATION DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   IF EXISTS(SELECT numcte FROM bdinteg:si_bpiusuarios WHERE numcte = pNumcte AND empresa = pEmpresa) THEN
	IF pStatus = '160' THEN --Valida si el estatus es de Desbloqueo, lo cambia a activo 140 para poder ingresar al portal
            UPDATE bdinteg:si_bpitoken set id_status_token = '140', f_status = CURRENT
			WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;

        ELSE
            UPDATE bdinteg:si_bpitoken SET id_status_token = pStatus, f_status = CURRENT
			WHERE empresa = pEmpresa AND num_cliente = pNumCte AND ns_token = pNSToken;
	END IF
	ELSE
		LET cod_ret = '00001'; -- El cliente No existe
	END IF;

	RETURN cod_ret, pStatus;

END;

END PROCEDURE;