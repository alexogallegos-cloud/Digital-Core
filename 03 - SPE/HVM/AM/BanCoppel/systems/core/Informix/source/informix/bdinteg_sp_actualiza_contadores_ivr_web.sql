CREATE PROCEDURE "informix".sp_actualiza_contadores_ivr_web(pEmpresa CHAR(3), pNumCte CHAR(20), pNumTel CHAR(13), pOpcion CHAR(1))

	RETURNING	CHAR(5) AS CodRet;
			
	DEFINE 	cCodRet		 CHAR(5);
	DEFINE	iSqlErr	 	 INTEGER;
	DEFINE	iContSMS	 SMALLINT;
	DEFINE	iContLlamada SMALLINT;
	DEFINE	iActSms		 SMALLINT;
	DEFINE	iActRpt		 SMALLINT;
	DEFINE iIntentosMax	 SMALLINT;	DEFINE iIntentos	 SMALLINT;
	LET	cCodRet		 = '00000';
	LET iSqlErr		 = 0;
	LET iContSMS	 = 0;
	LET iContLlamada = 0;
	LET iActSms 	 = 0;
	LET iActRpt 	 = 0; 
	LET iIntentosMax = 0;
	LET iIntentos	 = 0;

	BEGIN
		
		--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_actualiza_contadores_ivr.out';
		--TRACE ON;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumTel,'') = '' OR NVL(pOpcion,'') = '' THEN
			LET cCodRet='00001';
		ELSE
			IF pOpcion = 2 THEN
				--DSB-13/06/2016
				--OBTIENE EL NUMERO DE INTENTOS MAX EN LLAMADA
				SELECT CAST(TRIM(valor) AS SMALLINT) INTO iIntentosMax FROM "informix".si_param WHERE cod_param = 389;
				
				SELECT COUNT(numcte) INTO iIntentos FROM "informix".si_bitllamada_ivr 
				WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte) AND numtel = pNumTel 
				AND fecha_insert > CURRENT YEAR TO DAY;
				
				IF iIntentos < iIntentosMax THEN
					UPDATE "informix".si_bit_intentos_ivr
					SET cont_sms = cont_sms + 1, cont_llamada = cont_llamada + 1,fecha_mov = CURRENT
					WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte)
					AND numtel = pNumTel;
				ELSE
					LET cCodRet='00002';
				END IF;
			ELSE
				IF pOpcion = 1 THEN
					LET iActSms = 1;
				ELSE
					LET iActRpt = 1;
				END IF;
				
				IF EXISTS(SELECT numcte FROM "informix".si_bit_intentos_ivr WHERE empresa = pEmpresa AND numcte = TRIM(pNumCte) AND numtel = pNumTel) THEN
					
					UPDATE "informix".si_bit_intentos_ivr
					SET cont_sms = cont_sms + iActSms, cont_rpte = cont_rpte + iActRpt, fecha_mov = CURRENT
					WHERE empresa = pEmpresa AND numcte = pNumCte
					AND numtel = pNumTel;
					
				ELSE
					INSERT INTO "informix".si_bit_intentos_ivr (empresa,numcte,numtel,cont_sms,cont_llamada,fecha_insert,fecha_mov,cont_rpte) VALUES (pEmpresa,TRIM(pNumCte),pNumTel,iActSms,0,CURRENT,CURRENT,iActRpt);
				END IF;
			END IF;
		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FECHA:	28/DIC/2015',
'DESCRIPCION: Actualizar contadores de sms y llamada',
'BD: BDINTEG',
'MODIFICO:	VICTOR HUGO NUNEZ',
'FECHA:	13/06/2016',
'DESCRIPCION: Se modifica para poder validar la cantidad maxima de llamas a realizar por dia',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_bitacora_actividades_web( pcanal       CHAR(02),
                                                     ptransaccion CHAR(04),
                                                     psucursal    CHAR(04),
                                                     pusuario     CHAR(08),
                                                     pfolio_suc   CHAR(16),
                                                     pctataotro   CHAR(20) )
RETURNING CHAR(5);
    
	DEFINE vcodret1         	CHAR(5);
    DEFINE vcodret2         	CHAR(5);
    DEFINE vcodret3         	CHAR(50);
    DEFINE sql_err          	INTEGER;
    DEFINE isam_err         	INTEGER;
    DEFINE desc_err         	CHAR(50);
    DEFINE vcontador        	INTEGER;
    DEFINE ven_transacc     	SMALLINT; 
	DEFINE vsql             	CHAR(400);
    
	
    LET  vcodret1         		= '00000';
    LET  vcodret2         		= '000';
    LET  vcodret3         		= '';
    LET  sql_err	       		= 0 ;
    LET  isam_err         		= 0 ;
    LET  desc_err         		= '';
    LET  vcontador        		= 0 ;
    LET  ven_transacc     		= 0 ;
	LET  vsql             		= '';
    
	
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bitacora_actividades.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
  
    --- SET DEBUG FILE TO "/informix/resplogifx/conciliachq/sp_bitacora_actividades.out";
    --- TRACE ON;
	
    IF ( ( SELECT COUNT(*) FROM si_bitacora_actividades WHERE folio_suc = pfolio_suc ) > 0 ) THEN
					SET ISOLATION TO DIRTY READ;
                   UPDATE si_bitacora_actividades 
                   SET valor = pctataotro ,
                   hora_fin = (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinteg:si_fechas)
                   WHERE folio_suc = pfolio_suc;
        
        
    ELSE
					SET ISOLATION TO DIRTY READ; 
                   INSERT INTO si_bitacora_actividades  
				   VALUES (pcanal,ptransaccion,psucursal,pusuario,pfolio_suc,NULL, (SELECT CURRENT + (fecha_hoy - CURRENT) FROM bdinteg:si_fechas), NULL);
        
    END IF
    
    END;
    
    RETURN vcodret1;
    
END PROCEDURE;