CREATE PROCEDURE "informix".sp_agregarbitacora_amy(

pNum_cliente    char(9),
pNumSuc 		char(4),
pNumTrans 		char(4),
pFechaOper 		datetime year to second,
pCgen1 			char(50),
pCgen2 			char(50),
pCgen3 			char(50)  
)
 returning char(5);

 --DEFINICION DE VARIABLES
DEFINE cod_ret char(5);
DEFINE sql_err integer;

--INICIALIZA VARIABLES
LET cod_ret  	= '00000';

BEGIN
  ON EXCEPTION SET sql_err
	  IF sql_err <> 0 THEN
			let cod_ret = sql_err;
			RETURN cod_ret;
	  END IF ;
   END EXCEPTION ;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;


	INSERT INTO bdibpi:"informix".bpi_bitacora_amy(num_cliente,
				 sucursal,
				 id_operacion,
				 fecha_oper,
				 cgenerico1,
				 cgenerico2,
				 cgenerico3) 
				 VALUES (pNum_cliente,
						 pNumSuc,
						 pNumTrans,
						 pFechaOper,
						 pCgen1,
						 pCgen2,
						 pCgen3);
		
	RETURN cod_ret;
END;
END PROCEDURE;