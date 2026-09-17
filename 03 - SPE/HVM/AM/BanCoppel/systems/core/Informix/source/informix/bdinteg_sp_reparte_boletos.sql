CREATE PROCEDURE "informix".sp_reparte_boletos(p_cve_sorteo char(5),p_numcte char(9),p_sucursal char(4),p_area char(1),p_caja int,p_tipomov char(10),
p_foliosuc char(16),p_importe money(16,2),p_telefono char(10),p_fecha date,p_origen char(10),p_bolped int)
RETURNING VARCHAR(6),VARCHAR(80);

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  P_COD_RET        VARCHAR(6);
DEFINE  P_MENSAJE        VARCHAR(80);

DEFINE ciclo INTEGER;
DEFINE CodRet char(5);
DEFINE num1 integer;

let SQL_ERR          = 0;
let ISAM_ERR         = 0;
let ERROR_INFO       = '';
let P_COD_RET        = '';
let P_MENSAJE        = '';

let ciclo = 0;
let CodRet = '';
let num1 = 0;

BEGIN

 ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;	  
      RETURN P_COD_RET, P_MENSAJE;
   END EXCEPTION;
   
   --Set debug file to "/home/informix/man/manuel.out";
   --Trace on;
   
   let ciclo = 1;

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

   SET LOCK MODE TO WAIT 3;
   for ciclo = 1 to p_bolped
	insert into bdinteg:si_boleto values(p_cve_sorteo,sec_boleto.nextval ,CURRENT,p_numcte,'2',p_sucursal,p_area,p_caja,p_tipomov,
										 p_foliosuc,p_importe,p_telefono,'','',p_fecha,p_origen,ciclo);
   end for;

 RETURN P_COD_RET, P_MENSAJE;
END;
END PROCEDURE;