CREATE PROCEDURE "informix".sp_depura_bitacora_bei()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 		INTEGER;
DEFINE isam_err 	INTEGER;
DEFINE error_info	CHAR(150);
DEFINE cMensaje 	CHAR(150);
DEFINE cCod_ret     CHAR(6);
DEFINE Vid_oper		CHAR(4);
DEFINE Vid_usuario  INTEGER;
DEFINE iCont		INTEGER;
DEFINE cValor		CHAR(1);
DEFINE dFecha		DATE;	

DEFINE vcomienza        INTEGER;
DEFINE vcuantos  		INTEGER;
DEFINE vregistros INTEGER;
DEFINE vcontador INTEGER;
		

	--SET DEBUG FILE TO "/home/informix/BereniceOut/sp_depura_bitacora_bei.out";
    --TRACE ON; 

	LET cCod_ret    = '000000';
	LET sql_err     = 0;
	LET isam_err    = 0;
	LET error_info	= '';
	LET cMensaje    = 'PROCESO EXITOSO';
	LET iCont		= 0;
	LET cValor		= '';

	
	LET vcontador = -1;
	LET vcuantos = 0;
	LET vcomienza   = -1;	
	LET vregistros = 1000;
	
	BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;
		LET cMensaje = error_info;
		RETURN cCod_ret;
	END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

	select valor into cValor 
	from bdibpi:"informix".bpi_param
	where id_param = '20';

	select date(fecha_hoy - 1 units day) into dFecha 
	from bdicheq:"informix".sc_fechas
	where empresa = '001';

	select count(*) into iCont 
	from bdibei:"informix".temp_bei_bitacora_depurar;

	if iCont > 0 and cValor = '1' then

		update bdibpi:"informix".bpi_param set valor = '2'
		where id_param = '20';

	ELIF iCont > 0 and cValor = '0' then

		LET cCod_ret = '000001';
		RETURN cCod_ret;

	end if;

    FOREACH WITH HOLD

		select id_cat_oper 
		into Vid_oper  
		from bdibei:"informix".temp_bei_bitacora_depurar

		FOREACH WITH HOLD

			select distinct(id_usuario)
			into Vid_usuario
			from bdibei:"informix".bei_bitacora
			where id_operacion = Vid_oper 
			 AND EXTEND(fecha_oper,YEAR to day) <= dFecha
	
				IF vcomienza = -1 THEN
							BEGIN WORK;
							LET vcontador = 1;
							LET vcomienza = 0;
				END IF;		
						
				DELETE FROM bdibei:"informix".bei_bitacora
				WHERE id_operacion = Vid_oper 
					and id_usuario = Vid_usuario
					and EXTEND(fecha_oper,YEAR to day) <= dFecha;
			
				IF (vcontador = vregistros) THEN
						COMMIT WORK;
						LET vcontador = 0;							
						LET vcomienza = -1;
				ELSE
						LET vcontador = vcontador + 1 ;						
				END IF;		
				
		END FOREACH;

	END FOREACH;

			IF (vcontador > 1) THEN
				COMMIT WORK;
				LET vcontador = 0;							
				LET vcomienza = -1;							
			END IF;		

	update bdibpi:"informix".bpi_param set valor = '0'
	where id_param = '20';

	delete bdibei:"informix".temp_bei_bitacora_depurar;
	
	RETURN cCod_ret;

	END;

END PROCEDURE;