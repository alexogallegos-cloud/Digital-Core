CREATE PROCEDURE "informix".sp_generadepurado_folios(cEmpresa CHAR(3),pInstitucion CHAR(2)) 
RETURNING  CHAR(6) AS Cod_Ret,  CHAR(80) AS Mens_Ret;

DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE error_info       CHAR(80);
DEFINE cEmpresa         CHAR(3);
DEFINE cProceso         CHAR(4);
DEFINE cCod_ret         CHAR(6); 
DEFINE cCod_retBit      CHAR(6);
DEFINE cMensajeRet      CHAR(125); 
DEFINE vnum_folio      CHAR(25);
DEFINE contador_commit  INTEGER;
DEFINE iDiasVig			INTEGER;
DEFINE dFecha			DATE;

--Inicializacion de variables
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = "";
LET cEmpresa        = "";
LET cProceso        = '0024';
LET cCod_Ret        = '000000';
LET cCod_retBit     = '000000';
LET cMensajeRet     = 'PROCESO EXITOSO';
LET vnum_folio     = "";
LET contador_commit = 0;
LET iDiasVig 		= 0;

--SET DEBUG FILE TO "/tmp/mfinis/sp_generadepurado_folios.out";
--TRACE ON; 

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensajeRet = error_info;        
        RETURN cCod_ret,cMensajeRet;
    END EXCEPTION;

    --Directiva para lectura de tablas bloqueadas.
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 

    IF pInstitucion = 'BC' THEN	
	
		
		SELECT valor INTO iDiasVig FROM bdiburo:br_param WHERE cod_param = '158';
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCod_ret = '000002'; --No existe parametro
			LET cMensajeRet ='EL PARAMETRO DIAS DE VIGENCIA NO EXISTE';
			RETURN cCod_ret,cMensajeRet;
		END IF;
		
		SELECT fecha_hoy INTO dFecha FROM bdicred:sd_fechas where empresa= '001';
		
        select num_cliente from bdiburo:br_pn where LENGTH(num_cliente)=25 AND institucion = pInstitucion  AND fecha_consulta < dFecha - iDiasVig UNION 
        select num_cliente from bdiburo:br_error where  LENGTH(num_cliente)=25 AND institucion = pInstitucion  AND fecha < dFecha - iDiasVig
			into temp univ_ree with no log ;
                
        FOREACH WITH HOLD
            select *
            INTO vnum_folio
            FROM univ_ree

                BEGIN WORK;

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
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
	
					INSERT INTO "informix".br_traslado_hist_auditoria(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					SELECT institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert
					FROM "informix".br_traslado
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
					
					
					--Se borran las tablas de respuesta y traslado 
					
					DELETE FROM "informix".br_respuesta
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
	
					DELETE FROM "informix".br_respuesta_aprocesar
					WHERE institucion = pInstitucion 
					AND numcte = vnum_folio;
											
					DELETE FROM "informix".br_respuesta_aprocesar_aux
					WHERE institucion = pInstitucion 
					AND numcte = vnum_folio;
	
					DELETE FROM "informix".br_traslado
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
						
					LET contador_commit = contador_commit + 1;
					
					COMMIT WORK;    
                
        END FOREACH;

        drop table univ_ree;
        --LET cCod_Ret = '000000';
        --LET cMensajeRet = 'PROCESO CONCLUIDO, '||contador_commit||' folios eliminados.';
		
		LET pInstitucion = 'CC';
		
		select num_cliente from bdiburo:br_pn where LENGTH(num_cliente)=25 AND institucion = pInstitucion  AND fecha_consulta < dFecha - iDiasVig UNION 
        select num_cliente from bdiburo:br_error where  LENGTH(num_cliente)=25 AND institucion = pInstitucion  AND fecha < dFecha - iDiasVig
			into temp univ_ree with no log ;
                
        FOREACH WITH HOLD
            select *
            INTO vnum_folio
            FROM univ_ree

                BEGIN WORK;

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
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
	
					INSERT INTO "informix".br_traslado_hist_auditoria(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
					SELECT institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert
					FROM "informix".br_traslado
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
					
					
					--Se borran las tablas de respuesta y traslado 
					
					DELETE FROM "informix".br_respuesta
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
	
					DELETE FROM "informix".br_respuesta_aprocesar
					WHERE institucion = pInstitucion 
					AND numcte = vnum_folio;
											
					DELETE FROM "informix".br_respuesta_aprocesar_aux
					WHERE institucion = pInstitucion 
					AND numcte = vnum_folio;
	
					DELETE FROM "informix".br_traslado
					WHERE institucion = pInstitucion
					AND numcte = vnum_folio;
						
					LET contador_commit = contador_commit + 1;
					
					COMMIT WORK;    
                
        END FOREACH;

        drop table univ_ree;
		LET cCod_Ret = '000000';
        LET cMensajeRet = 'PROCESO CONCLUIDO, '||contador_commit||' folios eliminados.';
    
    ELSE
		LET cCod_Ret = "000001";
		LET cMensajeRet = "LA INSTITUCION INGRESADA ES INCORRECTA";
	END IF;

    RETURN cCod_ret,cMensajeRet;

END;
END PROCEDURE;