CREATE PROCEDURE "informix".act_pwd_solpendientes_bc()

RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;

--Declaración de variables.
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);
define v_solicitud  CHAR(12);
define v_cveact, v_cvenva CHAR(8);
define ctas integer;
   
--Inicialización de variables.
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET v_solicitud          = "";
LET v_cveact             = "";
LET v_cvenva             = "";
let ctas                 = 0;

BEGIN
--Errores no controlados.
ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;
	
--SET DEBUG FILE TO  "sp_act_pwdctas_bc.out";
--TRACE ON;

 select num_solicitud,substr(envio,51,8) Cve_actual,(select trim(valor) from bdiburo:br_param where cod_param = "125") cve_nueva
 from bdiburo:br_traslado
where num_solicitud in
(select num_solicitud from bdisolic:ss_solicitudes
 where status_solicitud = 'BC')
and envio not matches '*'||(select trim(valor) from bdiburo:br_param where cod_param = "125")||'*'
and institucion = 'BC'
into temp univ_actualizar WITH NO LOG;

  foreach with hold

select trim(num_solicitud) num_solicitud,Cve_actual,cve_nueva
into v_solicitud, v_cveact, v_cvenva
from  univ_actualizar

begin;
 update bdiburo:br_traslado set envio = replace(envio,substr(envio,51,8),v_cvenva) where num_solicitud = v_solicitud ;
commit;

let ctas = ctas+1;

 end foreach


   LET cCodRet     = "00000";
   LET cMensajeRet = "CTAS ACTUALIZADAS: " || ctas|| " Ok"  ;

	RETURN cCodRet, cMensajeRet;
END;
END PROCEDURE
;