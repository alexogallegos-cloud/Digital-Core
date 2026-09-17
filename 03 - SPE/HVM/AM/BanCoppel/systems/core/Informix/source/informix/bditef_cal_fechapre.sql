create procedure "informix".cal_fechapre(
                       pempresa         char(3),
                       pcvebanco   	char(3),
                       pnumcuenta   	char(20),
                       pnumcheque   	char(7),
                       pfechaofi	date)
                       RETURNING char(5),date;  

   DEFINE v_codret 	char(5);
   DEFINE v_fechapre 	date;
   DEFINE v_horacheque 	char(5);
   DEFINE v_paramhora  	char(5);
   DEFINE v_esferiadox 	char(1);
   DEFINE sql_err,isam_err int;   
   DEFINE inumcheque INTEGER;
   DEFINE inumcuenta DECIMAL(20,0);


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_fechapre    = "";
   let inumcheque = 0;
   let inumcuenta = 0;

   let v_horacheque = '';

   let v_paramhora  = '';
   let v_esferiadox = '';
   let sql_err      = 0;
   let isam_err     = 0;   


BEGIN

   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret,v_fechapre;
      end if;
   end exception;

  --set debug file to "/resplogifx/conciliachq/cal_fechapre.txt";
  --trace on;

set isolation to dirty read;
set lock mode to wait 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    --let pempresa = '001';

	IF  pempresa    	is null or
		pcvebanco       is null or
		pnumcuenta      is null or
		pnumcheque      is null or
		pfechaofi	    is null THEN
	
	   -- datos de entrada incompletos
	   
	   LET v_codret = 210; 
	   RETURN v_codret, v_fechapre; 
	END IF;


-- obtener el parametro de la hora tope t+1
	
	select valor
	into v_paramhora
	from cce_param
	where empresa = pempresa
	and cod_param=1;

	IF v_paramhora is null THEN
	   -- no existe el parametro en cce_param
	   LET v_codret = 220; 
	   RETURN v_codret, v_fechapre; 	
	END IF;


-- obtener la hora de presentacion del cheque
	let pcvebanco = pcvebanco;
	let pnumcuenta = pnumcuenta;
	let pnumcheque = pnumcheque;
	let pfechaofi = pfechaofi;
    
    let inumcheque = pnumcheque;
    let inumcuenta = pnumcuenta;
	
	IF pcvebanco <> '137'THEN
	
		-- MOHA
		select {+INDEX(bdicheq:sc_docret_sbc idx_docret5)} to_char(fech_hor,'%H:%M')
		into v_horacheque
		from bdicheq:sc_docret_sbc  --MOHA
		where empresa=pempresa
		and banco = pcvebanco
		and numcuenta = inumcuenta
		and num_chq = inumcheque
		and cancelado = "T"
		and fecha_alta = pfechaofi;
	

		IF v_horacheque is null THEN
			-- no existe el cheque en central
			LET v_codret = 230; 
			RETURN v_codret, v_fechapre; 	
		END IF;
		
	END IF;	

-- validar feriado, sab o dom

	select "1"
	into v_esferiadox
	from bdinteg:si_feriado
	where fecha=pfechaofi;
	
	IF v_esferiadox is null THEN
		LET v_esferiadox = "0";
	END IF


	
	-- cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
	
	IF v_esferiadox ="1" 
	   or to_char(pfechaofi,"%A") = "Saturday" 
	   or to_char(pfechaofi,"%A") = "Sunday" 
	   or v_horacheque > v_paramhora THEN
	   
		-- calcular la fecha correcta
		call cal_fecha_pre_fh(pfechaofi)
		returning v_codret,v_fechapre;	
		RETURN v_codret,v_fechapre;
		
	END IF

	LET v_fechapre = pfechaofi;	

END;    

RETURN v_codret,v_fechapre;

END PROCEDURE;