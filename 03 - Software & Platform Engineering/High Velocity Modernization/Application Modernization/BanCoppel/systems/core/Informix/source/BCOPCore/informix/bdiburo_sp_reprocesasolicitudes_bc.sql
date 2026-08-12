CREATE PROCEDURE "informix".sp_reprocesasolicitudes_bc(vfecha date)

RETURNING   CHAR(6) 	AS retorno,
            CHAR(100)   AS mensaje_ret;

--Declaración de variables.
DEFINE iSqlErr      		INTEGER;
DEFINE iIsamErr         	INTEGER;
DEFINE cErrorInfo       	CHAR(100);
DEFINE cCodRet          	CHAR(6);
DEFINE cMensajeRet    		CHAR(100);
DEFINE vinstitucion       	CHAR(2);
DEFINE vsolicitud          	CHAR(20);
DEFINE vregreso          	CHAR(10000);
DEFINE vstatus           	CHAR(1);
DEFINE ctas                 SMALLINT;
DEFINE pnum_cliente         CHAR(20);
   
--Inicialización de variables.
LET iSqlErr              = 0;
LET iIsamErr             = 0;
LET cErrorInfo           = "";
LET vinstitucion         = "";
LET vsolicitud           = "";
LET vregreso             = "";
LET vstatus              = "";
LET ctas                 = 0;
LET pnum_cliente         = "";

BEGIN
--Errores no controlados.
ON EXCEPTION SET iSqlErr, iIsamErr , cErrorInfo
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;  
      RETURN cCodRet, cMensajeRet;
END EXCEPTION;
	
--SET DEBUG FILE TO  "sp_reprocesasolicitudes_bc.out";
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 4;

select * from bdiburo:sb_regreso 
where institucion='BC' and num_solicitud in (select  s.num_solicitud
from bdisolic:ss_solicitudes s 
inner join bdiburo:br_traslado b on s.num_solicitud = b.num_solicitud and b.institucion = 'BC' and b.status = 1
where s.fecha_insert = vfecha --today-1
and s.status_solicitud=b.institucion )
and substr(regreso,1,4)='INTL'
into temp univ_solicitudes WITH NO LOG;

CREATE INDEX idx_regreso ON univ_solicitudes(institucion,num_solicitud) ONLINE;   

UPDATE STATISTICS MEDIUM FOR TABLE univ_solicitudes;

  foreach with hold

   select  institucion,num_solicitud,regreso,status
   into vinstitucion,vsolicitud,vregreso,vstatus 
   from  univ_solicitudes

   select numcte 
   into pnum_cliente
   from bdisolic:ss_solicitudes
   where empresa = '001'
   and num_solicitud = vsolicitud;


   begin;
	   DELETE bdiburo:"informix".sb_regreso where num_solicitud = vsolicitud and institucion='BC';

	   DELETE FROM bdiburo:"informix".br_cr WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_hi WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_hr WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_iq WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_pa WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_pe WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_pn WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_rs WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_sc WHERE institucion = 'BC' AND num_cliente= pnum_cliente;
	   DELETE FROM bdiburo:"informix".br_tl WHERE institucion = 'BC' AND num_cliente= pnum_cliente;

     insert into bdiburo:"informix".sb_regreso 
     select institucion,num_solicitud,regreso,status  
       from univ_solicitudes
      where num_solicitud = vsolicitud
        and institucion = vinstitucion;
   commit;

   LET ctas = ctas+1;

  end foreach

drop table univ_solicitudes;

   LET cCodRet     = "00000";
   LET cMensajeRet = "REPROCESO SOLICITUDES BC Ok " || ctas ;

	RETURN cCodRet, cMensajeRet;
END;
END PROCEDURE;