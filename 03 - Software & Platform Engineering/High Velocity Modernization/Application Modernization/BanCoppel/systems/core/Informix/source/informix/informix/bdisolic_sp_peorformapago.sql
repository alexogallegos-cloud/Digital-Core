CREATE PROCEDURE "informix".sp_peorformapago(p_NumCte CHAR(20), p_Institucion CHAR(2))

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),  -- Codigo de Retorno
	SMALLINT;  -- Peor forma de pago

	DEFINE sql_err 	 INTEGER;
	DEFINE vCodRet 	 CHAR(5);
	DEFINE vRs00 	 INTEGER;
	DEFINE vRs01 	 INTEGER;
	DEFINE vRs02 	 INTEGER;
	DEFINE vRs03 	 INTEGER;
	DEFINE vRs04 	 INTEGER;
	DEFINE vRs05 	 INTEGER;
	DEFINE vRs06 	 INTEGER;
	DEFINE vRs07 	 INTEGER;
	DEFINE vRs3tas 	 INTEGER;
	DEFINE VarMaxVal INTEGER;
	DEFINE iPeorFormaPago SMALLINT;
	DEFINE iRenglonMinimo INT8;
	
	LET sql_err = 0;
	LET vCodRet = '00000';
	LET vRs00 = 0;
	LET vRs01 = 0;
	LET vRs02 = 0;
	LET vRs03 = 0;
	LET vRs04 = 0;
	LET vRs05 = 0;
	LET vRs06 = 0;
	LET vRs07 = 0;
	LET vRs3tas = 0;
	LET VarMaxVal = 0;
	LET iPeorFormaPago = 0;
	LET iRenglonMinimo = 0;

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_peorformapago.out";
	--TRACE ON;
	
	BEGIN
	
		ON EXCEPTION SET sql_err
		
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN  vCodRet, iPeorFormaPago;
			END IF;
			
		END EXCEPTION;
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		--Se modifica la forma de obtener la informacion del segmento rs. RTV - 2012/04/11
		SELECT MIN(rowid) INTO iRenglonMinimo FROM bdiburo:"informix".br_rs
		  WHERE num_cliente = p_NumCte AND institucion = p_Institucion;
		
		IF iRenglonMinimo > 0 THEN
			SELECT rs00, rs01, rs02, rs03, rs04, rs05, rs06, rs07, (rs31+rs32+rs33)
			  INTO vRs00, vRs01, vRs02, vRs03, vRs04, vRs05, vRs06, vRs07, vRs3tas
			  FROM bdiburo:"informix".br_rs
			  WHERE num_cliente = p_NumCte AND institucion = p_Institucion AND rowid = iRenglonMinimo;
			 /*WHERE num_cliente = p_NumCte AND institucion = p_Institucion;*/


			IF vRs01 >= vRs00 THEN
				LET varMaxval = vRs01;
				LET iPeorFormaPago = 06; --rs01
			ELSE
				
				LET varMaxval = vRs00; 
				LET iPeorFormaPago = 07; --rs00
			END IF;

			IF vRs02 >= varMaxval THEN 
				LET varMaxval = vRs02;
				LET iPeorFormaPago = 05; --rs02
			END IF;
			
			IF vRs03 >= varMaxval THEN
				LET varMaxval = vRs03;
				LET iPeorFormaPago = 04; --rs03
			END IF;
			
			IF vRs04 >= varMaxval THEN
				LET varMaxval = vRs04;
				LET iPeorFormaPago = 03; --rs04
			END IF;
			
			IF vRs05 >= varMaxval THEN
				LET varMaxval = vRs05;
				LET iPeorFormaPago = 02; --rs05
			END IF;
			
			IF vRs06 >= varMaxval THEN
				LET varMaxval = vRs06;
				LET iPeorFormaPago = 01; --rs06
			END IF;
			
			IF vRs07 >= varMaxval THEN
				LET varMaxval = vRs07;
				LET iPeorFormaPago = 00; --rs07
			END IF;
			
			IF vRs3tas >= varMaxval THEN
				LET varMaxval = vRs3tas;
				LET iPeorFormaPago = 09; --rs31, rs32, rs33
			END IF;
		END IF;
		
		RETURN  vCodRet, iPeorFormaPago;
	END
	
END PROCEDURE

