CREATE PROCEDURE "informix".sp_validapass_bex(pNumCte char(20))
returning char(5),char(50),smallint;

	-- ***************************************************************************
    -- Define variables
    -- ***************************************************************************
    define cod_ret char(5);
    define sql_err integer;
    define v_usuario, v_pass, v_pass1, v_pass2, v_pass3 char(50);
	define sBandera smallint;
	
	
	--DescripciÃ³n: Valida Pass
	--22/04/2015
    
    -- ***************************************************************************
    -- Inicializa variables
    -- ***************************************************************************
    let cod_ret = "00000";
    let v_usuario = "";
    let v_pass  = "";
    let v_pass1 = "";
    let v_pass2 = "";
    let v_pass3 = "";
	let sBandera="";

    
	--SET DEBUG FILE TO "/informix/ireb/bdibpi/bex/sp_validapass_bex.out";
	--TRACE ON;
	
    BEGIN
    
    on exception set sql_err
        if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret, v_usuario, sBandera;
        end if
    end exception;
	
	SET LOCK MODE TO WAIT ;

	
    IF EXISTS ( SELECT num_cliente FROM  bdibpi:"informix".bpi_registro_bex  WHERE num_cliente = pNumCte ) THEN
        SELECT LIMIT 1 no_celular, contrasenia, contrasenia1, contrasenia2
          INTO v_usuario, v_pass, v_pass1, v_pass2
          FROM bdibpi:"informix".bpi_registro_bex 
         WHERE estatus_servicio <> '2'
            AND num_cliente = pNumCte;
		   
		IF (NVL(v_pass,'') == '' AND NVL(v_pass1,'') == '' AND NVL(v_pass2,'') == '' )THEN
			let sBandera="1";
		ELSE
			let sBandera="2";
		END IF;
		         
    ELSE
        LET cod_ret = '00001';
    END IF;
    
    return cod_ret, nvl(v_usuario,''),sBandera;
    
    END
    
END PROCEDURE
;