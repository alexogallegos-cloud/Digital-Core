CREATE PROCEDURE "informix".sp_replica_ordensupervision(lMaximo integer)
RETURNING
char(5) as CodRet,
char(20) as num_solicitud,
date as fechasolicitud, 
integer as secuencia;

DEFINE cCodRet char(5);
DEFINE sql_err integer;
DEFINE cNum_solicitud char(20);
DEFINE dfechasolicitud date;
DEFINE iSecuencia integer;

LET cCodRet = "00000";
LET sql_err = 0;
LET cNum_solicitud ="";
LET dfechasolicitud ="";
LET iSecuencia =0;
BEGIN
	--MANEJO DE EXCEPCIONES (ERRORES) 57 RET
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			let cCodRet = sql_err;
			RETURN cCodRet, '','','';
		END IF;
	END EXCEPTION;

/*Select {+INDEX(ss_osclientesupervisar idx_ss_osclientesupervisar2)} num_solicitud, fechasolicitud, secuencia 
		INTO cNum_solicitud, dfechasolicitud, iSecuencia
		From ss_osclientesupervisar
		Where secuencia <= lMaximo and nvl(clave, '') = '' order by secuencia desc*/
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	FOREACH		
        Select sup.num_solicitud, sup.fechasolicitud, sup.secuencia 
		INTO cNum_solicitud, dfechasolicitud, iSecuencia
		From bdisolic:ss_osclientesupervisar sup, bdisolic:ss_solicitudes os
		Where --sup.secuencia <= lMaximo 
             sup.num_solicitud = os.num_solicitud
         and os.status_solicitud = 'OS'
        -- and (fechamovto) <  today
         and nvl(clave, '') = ''          
		 UNION ALL
		 SELECT a.num_solicitud, a.fechasolicitud, a.secuencia 		 
           FROM "informix".ss_osclientesupervisar a ,           
                bdiprospectos:"informix".pr_cliente pr
          WHERE a.empresa ='001'       
            and  a.num_solicitud = pr.numcte_pros            
            and nvl(a.clave, '') = ''
            and  pr.estado_os = 1
         order by secuencia desc


		RETURN  cCodRet, cNum_solicitud, dfechasolicitud, iSecuencia WITH RESUME;


	END FOREACH;

END

END PROCEDURE
