create procedure "informix".sp_latinia_contador(pcampania char(10),pcontador integer)
returning VARCHAR(6);

DEFINE cCod_ret  	smallint;
DEFINE cMensaje  	char (100);
DEFINE SQL_ERR         INTEGER;
DEFINE ISAM_ERR        INTEGER;
DEFINE ERROR_INFO      VARCHAR(80);
DEFINE P_COD_RET      	VARCHAR(6);
DEFINE P_MENSAJE       	VARCHAR(80);
define vmaxfecha 		date;
define vfecha			date;

	let P_COD_RET = '000000';
	let cCod_ret = '';
    let cMensaje = '';
	let SQL_ERR            = 0;
	let ISAM_ERR           = 0;
	let ERROR_INFO         = '';
	let P_MENSAJE          = '';
	let vmaxfecha = date(1);
	let vfecha = date(1);


BEGIN 
  
    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
     RETURN P_COD_RET;
     END exception;
-- SET DEBUG FILE TO 'compac.out';
-- TRACE ON;
		
	select fecha_hoy into vfecha from bdicred:sd_fechas where empresa = '001';
		
		if exists (select fecha_insert from  bdicred:sd_totalcte_campania where month(fecha_insert) = month(vfecha)
						and year(fecha_insert) = year(vfecha)	and tipocampania = pcampania) then
		
			update bdicred:sd_totalcte_campania  set total = total + pcontador 
				where month(fecha_insert) = month(vfecha) and year(fecha_insert) = year(vfecha)
				and tipocampania = pcampania ;
		else
			insert into bdicred:sd_totalcte_campania (empresa,fecha_insert,tipocampania,total)  
			values('001',today,pcampania,pcontador);
		end if;
	
	
end
RETURN P_COD_RET;
END PROCEDURE;