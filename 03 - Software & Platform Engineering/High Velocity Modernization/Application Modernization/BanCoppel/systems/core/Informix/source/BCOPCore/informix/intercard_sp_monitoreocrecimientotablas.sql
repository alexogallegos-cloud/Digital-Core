CREATE PROCEDURE "informix".sp_monitoreocrecimientotablas ()
RETURNING 
VARCHAR(5) as Cod_ret, VARCHAR(80) as Men_ret, 
char (20) as Nombre_tabla, integer as Total_Registros, 
char (20) as Nombre_tabla2, integer as Total_Registros2, 
DATETIME YEAR to FRACTION(5) as FechaHoraConsulta;

	define  sql_err          		integer;
	define  isam_err         		integer;
	define  error_info       		varchar(80);
	define  ccodret 	       		varchar(5); 
	define  cmensajeretorno    		varchar(80);
	define 	cnombretabla			char (20);
	define 	itotalregistros		 	integer;
	define 	cnombretabla2			char (20);
	define 	itotalregistros2	 	integer;
	define  dtfechahoraconsulta     DATETIME YEAR to FRACTION(5);
		
 -- SET DEBUG FILE TO "/tmp/sp_monitoreocrecimientotablas.out";
 -- TRACE ON;

	let  sql_err          		= 0;
	let  isam_err         		= 0;
	let  error_info       		= '';
	let  ccodret 	       		= '00000';
	let  cmensajeretorno    	= 'Ejecucion sp_monitoreocrecimientotablas exitosa.';
	let  cnombretabla			= 'arqcvalidos';
	let  itotalregistros		= 0;
	let  cnombretabla2			= 'bitacoraatc';
	let  itotalregistros2		= 0;
	let  dtfechahoraconsulta    = current;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET ccodret     	= SQL_ERR;
	LET cmensajeretorno = ERROR_INFO;
    RETURN ccodret, cmensajeretorno, cnombretabla, itotalregistros, cnombretabla2, itotalregistros2, dtfechahoraconsulta;
    END EXCEPTION;
		
	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	select
		count (*) 
		into itotalregistros
	from "informix".arqcvalidos;
	
	select
		count (*) 
		into itotalregistros2
	from "informix".bitacoraatc;
	
	let  dtfechahoraconsulta    = current;
	
	RETURN ccodret, cmensajeretorno, cnombretabla, itotalregistros, cnombretabla2, itotalregistros2, dtfechahoraconsulta;

END;

END PROCEDURE;