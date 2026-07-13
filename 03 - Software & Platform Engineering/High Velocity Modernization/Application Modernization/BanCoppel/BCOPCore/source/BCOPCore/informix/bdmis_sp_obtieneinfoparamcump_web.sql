CREATE PROCEDURE "informix".sp_obtieneinfoparamcump_web ( siRegistros SMALLINT)
RETURNING CHAR (05) 	AS  cod_ret		,
		  INTEGER   	AS	Parametro	,
		  DATE 			AS	Fecha		,
		  money(18,4)	AS	Valor		,
		  char (60)	AS	Descripcion ,
		  Char (08)		AS	Usuario		;
--declaracion de variables de retorno
	DEFINE	cod_ret			CHAR (05)	;
	DEFINE	vParametro		Integer		;
	DEFINE	vFecha			Date 		;
	DEFINE	vValor 			MONEY (18,4);	
	DEFINE	vDescripcion	Varchar (60);	
	DEFINE	vUsuario		Char (08)	;
		  
BEGIN
--inicializacion de variables
	let cod_ret			= '00000';
	let	vParametro		= 0 ;
	let	vFecha			= '01/01/1900' ;		
	let	vValor			= 0 ; 		
	let	vDescripcion	= '' ;
	let	vUsuario		= '' ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
		  
-- se valida que existan parametros de cumplimiento a exportar
	IF (SELECT COUNT(*) FROM "informix".mi_paramcump) > 0 THEN 
			foreach	
				SELECT SKIP siRegistros  FIRST 21 parametro, fecha, valor, descripcion, usuario
				INTO	vparametro, vfecha, vvalor, vdescripcion, vusuario
				FROM	"informix".mi_paramcump
				
				RETURN	cod_ret, vparametro, vfecha, vvalor, vdescripcion, vusuario WITH RESUME;
			end foreach
		ELSE
			let cod_ret = '00001';
			let vdescripcion = 'NO existen parametros de cumplimiento';
			RETURN cod_ret, vparametro, vfecha, vvalor, vdescripcion, vusuario WITH RESUME;
	END IF;	  
END;
END PROCEDURE;