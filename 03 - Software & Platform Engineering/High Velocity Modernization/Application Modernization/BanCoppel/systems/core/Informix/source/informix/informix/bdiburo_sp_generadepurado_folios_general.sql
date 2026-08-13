CREATE PROCEDURE "informix".sp_generadepurado_folios_general(pFechaIni DATE, pFechaFin DATE) 
RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cCod_ret         CHAR(6); 
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125); 
DEFINE vnum_folio       CHAR(25);
DEFINE icontador_commit INTEGER;
DEFINE dFecha			DATE;
DEFINE icontador_filas  INTEGER;
DEFINE icomienza		INTEGER;
DEFINE itransacc		INTEGER;
DEFINE bInTransaction 	BOOLEAN;
DEFINE i 				INTEGER;

--Inicializacion de variables
LET sql_err        	 = 0;
LET isam_err       	 = 0;
LET error_info     	 = "";
LET cEmpresa       	 = "";
LET cCod_Ret       	 = '000000';
LET cCod_retBit    	 = '000000';
LET cMensajeRet    	 = 'PROCESO EXITOSO';
LET vnum_folio     	 = "";
LET icontador_commit = 0;
LET dFecha			 = DATE(1);
LET icontador_filas  = 0;
LET icomienza		 = -1;
LET itransacc 		 = 0;
LET bInTransaction   = 'f';
LET i 				 = 0;

--SET DEBUG FILE TO "/tmp/mfinis/sp_generadepurado_folios_general.out";
--TRACE ON; 

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;    
		IF bInTransaction THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;		
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;
	
	ON EXCEPTION IN (-535)
        LET bInTransaction = 't';
    END EXCEPTION WITH RESUME;
	
	IF bInTransaction THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 
		
        select a.numcte from bdiburo:br_respuesta a
		inner join bdinteg:si_solicitud_movil_online b
		on a.num_solicitud= b.numero_control 
		where b.fecha_hora >= pFechaIni and b.fecha_hora <= pFechaFin
		UNION 
		select a.numcte from bdiburo:br_traslado a
		inner join bdinteg:si_solicitud_movil_online b
		on a.num_solicitud= b.numero_control 
		where b.fecha_hora >= pFechaIni and b.fecha_hora <= pFechaFin
			
		into temp univ_ree with no log ;

                
        FOREACH WITH HOLD
            select *
            INTO vnum_folio
            FROM univ_ree

                   -- Abre la transaccion 
				IF  (icomienza = -1) THEN
					LET icomienza = 0;
					LET itransacc = 1;
					COMMIT;
					BEGIN WORK;
				END IF;

                    DELETE FROM bdiburo:br_cr WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_hi WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_hr WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_iq WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_pa WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_pe WHERE num_cliente = vnum_folio;
                    DELETE FROM bdiburo:br_pn WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_tl WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_rs WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_sc WHERE num_cliente = vnum_folio;
                    DELETE FROM bdiburo:br_es WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_ar WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_ur WHERE num_cliente = vnum_folio; 
                    DELETE FROM bdiburo:br_error WHERE num_cliente = vnum_folio; 	
					
					
					--Se inserta respuesta y traslado
						
					INSERT INTO "informix".br_respuesta_hist_auditoria(idrespuesta,institucion,numcte,num_solicitud,fecha_insert,secuencia,regreso) 
					SELECT 0,institucion,numcte,num_solicitud,fecha_insert,secuencia,regreso
					FROM "informix".br_respuesta
					WHERE institucion IN ('BC','CC')
					AND numcte = vnum_folio;
	
					INSERT INTO "informix".br_traslado_hist_auditoria(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					SELECT institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert
					FROM "informix".br_traslado
					WHERE institucion IN ('BC','CC')
					AND numcte = vnum_folio;
					
					
					--Se borran las tablas de respuesta y traslado 
					
					DELETE FROM "informix".br_respuesta
					WHERE institucion IN ('BC','CC')
					AND numcte = vnum_folio;
	
					DELETE FROM "informix".br_respuesta_aprocesar
					WHERE institucion IN ('BC','CC')
					AND numcte = vnum_folio;
											
					DELETE FROM "informix".br_respuesta_aprocesar_aux
					WHERE institucion IN ('BC','CC')
					AND numcte = vnum_folio;
	
					DELETE FROM "informix".br_traslado
					WHERE institucion IN ('BC','CC')
					AND numcte = vnum_folio;
						
					LET icontador_filas = icontador_filas + 1;
		
					LET icontador_commit = icontador_commit + 1;
				
				--Realiza commit cada 50 registros 
				IF (icontador_commit >= 50) THEN
					LET icontador_commit = 0;
					COMMIT WORK;
					BEGIN WORK;
				END IF; 

		END FOREACH;            	

		--Si la transaccion esta abierta realiza el commit
		IF  itransacc = 1 THEN
			LET itransacc = 0;
			COMMIT WORK;
			BEGIN WORK;
		END IF;	   
	
		drop table univ_ree;

		
		LET cCod_Ret = '000000';
		LET cMensajeRet = 'PROCESO CONCLUIDO, '||icontador_filas||' folios eliminados.';
	

    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;