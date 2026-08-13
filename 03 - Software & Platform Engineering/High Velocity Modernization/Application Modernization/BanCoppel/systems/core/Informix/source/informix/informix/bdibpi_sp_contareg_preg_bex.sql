CREATE PROCEDURE "informix".sp_contareg_preg_bex(pNumCte char(20) ,pNumTel  char(20))
	RETURNING 	INTEGER, INTEGER;
--DEFINICION DE VARIABLES
DEFINE iSqlErr 		INTEGER;
DEFINE vSesion 		INTEGER;
DEFINE vEncuentado 	INTEGER;
DEFINE desPreg 		VARCHAR(200);
DEFINE iCont		INTEGER;
DEFINE iCont1		INTEGER;
DEFINE iSesion		INTEGER;

--INICIALIZACION DE VARIABLES
LET iSqlErr 	 = 0;
LET vSesion 	 = 0;
LET vEncuentado	 = 0;	
LET desPreg 	 = " ";
LET iCont 		 = 0;
LET iCont1 		 = 0;
LET iSesion		 = 0;	


--SET DEBUG FILE TO '/informix/ireb/bdibpi/sp_contareg_preg_bex2.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vSesion = iSqlErr;			
			RETURN vSesion, vEncuentado;
		END IF;
	END EXCEPTION;	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF pNumCte='' OR pNumTel= '' THEN
		LET iSesion	 = '';
		RETURN iSesion, vEncuentado;
	END IF
	
	IF NOT EXISTS(SELECT num_cliente FROM bpi_registro_bex WHERE num_cliente = pNumCte AND no_celular = pNumTel AND servicio='activo') THEN 
		LET iSesion	 = '';
		RETURN iSesion, vEncuentado;
	END IF 
		
	SELECT num_inicia_sesion, encuestado INTO vSesion, vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel;
	
	IF vSesion IS NULL THEN 
		LET vSesion = 0;
	END IF	
	
	IF vSesion > 0 THEN
		IF vSesion < 14 THEN
			
			LET iSesion = vSesion+1;
			
			IF iSesion = 13 AND vEncuentado = 0 THEN 
				UPDATE  bpi_reg_usuarioencuestados_bex SET encuestado=2,num_inicia_sesion=iSesion WHERE num_cte=pNumCte and num_tel=pNumTel;
			ELSE
				UPDATE  bpi_reg_usuarioencuestados_bex SET num_inicia_sesion=iSesion WHERE num_cte=pNumCte and num_tel=pNumTel;
			END IF
			
			SELECT num_inicia_sesion, encuestado into vSesion, vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel;
			
			RETURN vSesion, vEncuentado;
		END IF		
	ELSE
			LET iCont = iCont + 1;
			INSERT INTO bpi_reg_usuarioencuestados_bex(num_cte, num_tel, num_inicia_sesion, encuestado) VALUES(pNumCte,pNumTel,iCont,'0');
	END IF
	
	
	SELECT num_inicia_sesion, encuestado into vSesion, vEncuentado FROM bpi_reg_usuarioencuestados_bex where num_cte=pNumCte and num_tel=pNumTel;

RETURN vSesion, vEncuentado;
END;
END PROCEDURE;