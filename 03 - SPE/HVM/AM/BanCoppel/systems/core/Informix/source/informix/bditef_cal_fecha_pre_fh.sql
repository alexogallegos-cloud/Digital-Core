create procedure "informix".cal_fecha_pre_fh(
			v_fechai char(10))
                       	RETURNING char(5),date;  

   DEFINE v_codret 	char(5);
   DEFINE v_fecha_pre 	date;
   DEFINE v_esferiado 	char(1);
   DEFINE v_bandera	char(1);
   DEFINE v_fecha	date;
   DEFINE sql_err,isam_err int;   


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fecha_pre = " ";
   LET v_esferiado = "0";

--set debug file to "cal_fecha.txt";
--trace on;
   


-- ****************************************************************************
-- valida datos de entrada
-- ****************************************************************************

	IF  	v_fechai is null THEN
		-- datos de entrada incompletos   
		LET v_codret = 110; 
		RETURN v_codret,v_fecha_pre; 
	END IF;


BEGIN

	on exception set sql_err,isam_err
	if sql_err <> 0 or isam_err <> 0 then
	 let v_codret = sql_err;
	 return v_codret,v_fecha_pre;
	end if;
	end exception;
	
	LET v_fecha = to_date(v_fechai,"%m/%d/%Y");

	
	select "1"
	into v_esferiado
	from bdinteg:si_feriado
	where fecha=v_fecha;
	
	IF v_esferiado is null THEN
		LET v_esferiado = "0";
	END IF

	IF v_esferiado <>"1" and to_char(v_fecha,"%A") <> "Saturday" and to_char(v_fecha,"%A") <> "Sunday"  THEN
		LET v_fecha = v_fecha + 1;
	END IF


	IF v_esferiado = "1"   THEN
		LET v_fecha = v_fecha + 1;
	END IF

	IF to_char(v_fecha,"%A") = "Saturday"  THEN
		LET v_fecha = v_fecha + 2;	
	END IF
	
	IF to_char(v_fecha,"%A") = "Sunday"  THEN
		LET v_fecha = v_fecha + 1;
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
			
			LET v_fecha = v_fecha + 1;
		END IF
	
	END WHILE


	
	LET v_fecha_pre = v_fecha;
	
END;    

RETURN v_codret,v_fecha_pre;

END PROCEDURE;