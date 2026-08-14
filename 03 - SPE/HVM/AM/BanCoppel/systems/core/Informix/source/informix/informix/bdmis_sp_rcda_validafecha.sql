CREATE PROCEDURE "informix".sp_rcda_validafecha( psfecha CHAR (10) )
RETURNING CHAR (01) as cod_ret,
		  DATE 		as fecha;
		  
--variables de retorno
	DEFINE	cod_ret 	CHAR(01);
	DEFINE	vfecha		DATE;
	
--variable de control de errores
	DEFINE visqlerr INTEGER ;	
	
	LET cod_ret = 'V' ;
	LET vfecha	= '01/01/1900';
	
	
BEGIN	
	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
		IF visqlerr <> 0 THEN
			LET cod_ret = 'F' ;		
		END IF;		
		RETURN cod_ret,vfecha ;
	END EXCEPTION;

	let	vfecha  =   substr (psfecha,6,2) ||'/' ||  substr (psfecha,9,2)  ||'/' || substr (psfecha,1,4);

	RETURN cod_ret,vfecha ;
END
END PROCEDURE	;