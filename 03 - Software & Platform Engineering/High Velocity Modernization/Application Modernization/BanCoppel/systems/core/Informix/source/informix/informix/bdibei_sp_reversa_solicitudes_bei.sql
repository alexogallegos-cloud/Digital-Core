CREATE PROCEDURE "informix".sp_reversa_solicitudes_bei()
   RETURNING CHAR(5),DATE;  
   --*************************************************************
	--Objetivo:proceso que elimina reversa las solicitudes con estatus 110 a su estado original,sin tokens y regresa los tokens a disponibles.
	--Solicitó: José de Jesús Nevarez.
	--Elaboró Jose Ruben Lopez.
	--Fecha: 2013-08-14.
	--BD:bdibei.
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------
	--Objetivo: Se modifica para que no realice el reverso de solicitudes con status 110 sin token asignado con fecha de atención menor a 20 minutos.
	--Solicitó: Walber Castro.
	--Elaboró Manuel Ramos Figueroa.
	--Fecha: 2015-06-12.
	--BD:bdibei.
	--*************************************************************   
      
   -- DEFINE
    DEFINE cod_ret CHAR(5);
    DEFINE sql_err INTEGER;
	DEFINE vSolicitud CHAR(10);
	DEFINE vStatusSolOr SMALLINT;
	DEFINE vFechaSol  DATE;
	DEFINE vNumSerieTknA CHAR(10);
	DEFINE vUserAtendio CHAR(8);
	DEFINE vCod_Ret_Token CHAR(5);
	DEFINE vNumCte CHAR(9);
	DEFINE vCod_Ret_Sol CHAR(5);
	DEFINE vCanToken INTEGER;
	DEFINE votraFecha DATE;
	DEFINE vFechaAtencion date;
	DEFINE vHoraAtencion DATETIME HOUR TO SECOND;
	DEFINE vFechaHoraAtencion DATETIME YEAR TO FRACTION;
	
	-- INICIALIZAR
	LET cod_ret = '00000';
	LET vSolicitud='';
	LET vStatusSolOr=0;
	LET vFechaSol='';
	LET vNumSerieTknA='';
	LET vUserAtendio='';
	LET vCod_Ret_Token='00000';
	LET vNumCte='';
	LET vCod_Ret_Sol='';
	LET vCanToken=0;
	LET votraFecha='';
	
	
	--SET DEBUG FILE TO '/home/sysifx/Ramos/trace/sp_reversa_solicitudes_bei.out';
	--TRACE ON;
	
	BEGIN	
		ON EXCEPTION SET sql_err
		  IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret,vFechaSol;
		  END IF ;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			SELECT solicitud,f_atencion,usr_atiende,numcte, date(f_atencion), f_atencion::datetime hour to second
			INTO vSolicitud,vFechaSol,vUserAtendio,vNumCte, vFechaAtencion, vHoraAtencion
			FROM "informix".bei_solicitudtoken 
			WHERE id_status='110'
			
			LET vFechaHoraAtencion = ( YEAR(vFechaAtencion) || '-' || MONTH(vFechaAtencion) || '-' || DAY(vFechaAtencion) || ' ' || vHoraAtencion)::DATETIME YEAR TO FRACTION;
			
			IF (current - vFechaHoraAtencion) > '0 00:20:00' THEN
			
			--Se saca el estatus original de la solicitud
				FOREACH
				SELECT anterior 
				INTO vStatusSolOr 
				FROM "informix".bei_stasolicitud
				WHERE f_registro::date=vFechaSol AND solicitud=vSolicitud		
				END FOREACH;
				
			--REGRESA LOS TOKENS AL ESTADO 105 Y LOS BORRA DE LA TABLA bei_tokensolicitud
				-- contabiliza los tokens asignados a la solicitud.
				SELECT COUNT(ns_token)
				INTO vCanToken
				FROM "informix".bei_tokensolicitud
				WHERE solicitud=vSolicitud AND numcte=vNumCte;
				
				-- aplica si se asignaron tokens a la solicitud.
				IF (vCanToken > 0 ) THEN	
				FOREACH
				
					SELECT ns_token
					INTO vNumSerieTknA
					FROM "informix".bei_tokensolicitud
					WHERE solicitud=vSolicitud AND id_status='110' AND numcte=vNumCte

					--CAMBIA EL ESTATUS  DEL TOKEN A 105 en tkn_nseries e inserta el historico.
					EXECUTE PROCEDURE bdibpi:"informix".sp_set_statustoken_admtoken(vNumSerieTknA,'110', '105',vUserAtendio,'04')
					INTO  vCod_Ret_Token;	
					IF (vCod_Ret_Token <>'000') THEN
						LET cod_ret='00002';
						RETURN cod_ret,vFechaSol;
					END IF;
					
					--BORRADO DE LA TABLA DE ASIGNACIONES DE TOKEN
					DELETE FROM "informix".bei_tokensolicitud WHERE solicitud=vSolicitud AND ns_token=vNumSerieTknA;
				END FOREACH;
				END IF;
				
				--CAMBIA EL ESTATUS DE LA SOLICITUD AL ANTERIOR (100)
				EXECUTE PROCEDURE "informix".sp_set_solicitudstatus_admtoken_bei(vSolicitud,vNumCte,vUserAtendio,'110',vStatusSolOr)
				INTO vCod_Ret_Sol;	
				IF (vCod_Ret_Sol <>'000')THEN
					LET cod_ret='00003';
					RETURN cod_ret,vFechaSol;
				END IF;	
			END IF;
		END FOREACH;
		RETURN cod_ret,vFechaSol;
		
	END;	
END PROCEDURE;