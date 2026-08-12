CREATE PROCEDURE "informix".sp_obtiene_guiastoken_logify_bei(pNumSolicitud char(10), pNumCliente char(9), pFechaAtencion char(10),pNumeroGuia char(30),pRegistros smallint)
RETURNING CHAR(5),CHAR(10),CHAR(9), CHAR(1), CHAR(10),CHAR(30); 

   --*************************************************************
	--Objetivo:Obtiene guias admtoken para logify.
	--Solicitó: Gabriela Aguilar (BanCoppel).
	--Elaboró Arturo Astorga.
	--Fecha: 2018-05-04.
	--BD:bdibei.
	--*************************************************************   
   
   -- DEFINE
    DEFINE vSolicitud CHAR(10);
	DEFINE sql_err integer;
	DEFINE vCliente CHAR(9);
	DEFINE vFechaAtencion CHAR(10);
	DEFINE vNumGuia CHAR(30);
	DEFINE cod_ret CHAR(5);
	DEFINE vSec_domicilio char(1);
	--INICIALIZA
	LET vSolicitud='';
	LET vCliente='';
	LET vFechaAtencion='';
	LET vNumGuia='';
	LET cod_ret='00000';
	LET vSec_domicilio = '';
	
	--SET DEBUG FILE TO '/informix/gaby/ArchivosOut/sp_obtiene_guiastoken_bei.out';
	--TRACE ON;	
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret, vSolicitud, vCliente, vSec_domicilio, vFechaAtencion, vNumGuia;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;   
		
		IF (pFechaAtencion <> '' AND pFechaAtencion IS NOT NULL) THEN
			FOREACH
		
			SELECT  SKIP pRegistros FIRST 10 
				sk.solicitud,sk.numcte, sk.sec_domicilio, sk.f_atencion::date,te.num_guia
				INTO vSolicitud,vCliente, vSec_domicilio, vFechaAtencion,vNumGuia
				FROM "informix".bei_solicitudtoken sk, "informix".bei_envios te
				WHERE sk.solicitud MATCHES ('*' || pNumSolicitud)
				AND sk.numcte MATCHES ('*' || pNumCliente)
				AND date(sk.f_atencion) = pFechaAtencion::date
				AND te.num_guia MATCHES ('*' || pNumeroGuia)
				AND te.solicitud = sk.solicitud
				AND te.numcte=sk.numcte
				AND te.id_status='120'
				AND sk.id_status='120'
				ORDER BY sk.solicitud ASC
				
				RETURN cod_ret, vSolicitud, vCliente, vSec_domicilio, vFechaAtencion::date, vNumGuia WITH RESUME;
				
			END FOREACH;
		ELSE
		
			FOREACH		
				SELECT  SKIP pRegistros FIRST 10 
					sk.solicitud,sk.numcte, sk.sec_domicilio, sk.f_atencion::date,te.num_guia
					INTO vSolicitud,vCliente, vSec_domicilio, vFechaAtencion,vNumGuia
					FROM "informix".bei_solicitudtoken sk, "informix".bei_envios te
					WHERE sk.solicitud MATCHES ('*' || pNumSolicitud)
					AND sk.numcte MATCHES ('*' || pNumCliente)
					AND te.num_guia MATCHES ('*' || pNumeroGuia)
					AND te.solicitud = sk.solicitud
					AND te.numcte=sk.numcte
					AND te.id_status='120'
					AND sk.id_status='120'
					ORDER BY sk.solicitud ASC
					
					RETURN cod_ret, vSolicitud, vCliente,  vSec_domicilio, vFechaAtencion, vNumGuia WITH RESUME;
					
			END FOREACH;
		END IF;
		IF vSolicitud='' THEN
			LET cod_ret='00001';
			RETURN cod_ret, vSolicitud, vCliente, vSec_domicilio, vFechaAtencion, vNumGuia;
		END IF;
		
	END;	
END PROCEDURE;