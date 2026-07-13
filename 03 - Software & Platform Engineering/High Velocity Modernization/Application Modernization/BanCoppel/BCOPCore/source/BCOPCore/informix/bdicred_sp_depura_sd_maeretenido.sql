CREATE PROCEDURE "informix".sp_depura_sd_maeretenido()
RETURNING CHAR(3);

DEFINE vCodRet CHAR(6); 
DEFINE Vnumcred CHAR(20);
DEFINE vSqlErr, vIsamErr INTEGER;


LET vCodRet = '000';
LET vSqlErr = 0;
LET vIsamErr = 0;
LET Vnumcred ='';
 BEGIN

	ON EXCEPTION SET vSqlErr, vIsamErr

	IF vSqlErr != 0 THEN

		LET vCodRet = vSqlErr;

		RETURN vCodRet;

	END IF;
	
	END EXCEPTION;

	FOREACH WITH HOLD

		select distinct (num_credito) into Vnumcred from "informix".sd_maeretenido
		where empresa ='001' 
		and fecha <= mdy('12','31','2010')
		and estatus <> 'P'

		BEGIN WORK;

			delete from  "informix".sd_maeretenido
			where empresa ='001' 
			and num_credito = Vnumcred
			and fecha <= mdy('12','31','2010')
			and estatus <> 'P';

		COMMIT WORK;  

	end FOREACH	

	UPDATE statistics medium FOR TABLE bdicred:"informix".sd_maeretenido;
	
   return  vCodRet;
   
END

END PROCEDURE;