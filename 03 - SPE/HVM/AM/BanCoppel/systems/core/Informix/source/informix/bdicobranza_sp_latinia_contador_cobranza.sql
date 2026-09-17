create procedure "informix".sp_latinia_contador_cobranza(pcampania char(10),pcontador integer,ptotalsintelosinmail integer)
returning VARCHAR(6);

--execute procedure "informix".sp_latinia_contador_cobranza('001',9000,8999)
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
--SET DEBUG FILE TO 'sp_latinia_contador_cobranza.out';
--TRACE ON;

    insert into  "informix".cb_totalcte_campania2 (empresa,fecha_insert,id_campania,total,total_sintel_o_sinmail)  
	values('001',today,pcampania,pcontador,ptotalsintelosinmail);

end
RETURN P_COD_RET;
END PROCEDURE;