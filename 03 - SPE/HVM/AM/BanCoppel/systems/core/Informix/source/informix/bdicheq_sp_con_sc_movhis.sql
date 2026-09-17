CREATE PROCEDURE "informix".sp_con_sc_movhis(  pFecha DATE )
RETURNING CHAR(5),integer,integer,integer,decimal(18,2),integer,decimal(18,2);
--,CODIGO DE ERROR SQL
--,NUMERO DE CONTRATOS ATM CAPTACION PERSONAS FISICAS
--,NUMERO DE CONTRATMOS ATM CAPTACION PERSONAS MORALES
--,NUMERO DE OPERACIONES ATM CAPTACION PERSONAS FISICAS
--,NUMERO DE OPERACIONES ATM CAPTACION PERSONAS FISICAS MONTO
--,NUMERO OPERACIONES CAPTACION PERSONAS MORALES,NUMERO OPERACIONES CAPTACION PERSONAS MORALES MONTO

	--Variables Exception
	DEFINE vcodret          CHAR(5);
	DEFINE vsqlerr,visamerr INTEGER; 


	DEFINE v_imes1								INTEGER;	
	DEFINE v_imes2								INTEGER;	
	DEFINE v_imes3								INTEGER;	
	DEFINE v_ivano1								INTEGER;
	
	DEFINE v_CON_ATMCAPF                        INTEGER;
	DEFINE v_CON_ATMCAPM						INTEGER;
	DEFINE v_OPE_ATMCAPF						INTEGER;
	DEFINE v_MONTO_TOT1							DECIMAL(18,2);	
	DEFINE v_OPE_ATMCAPM						INTEGER;
	DEFINE v_MONTO_TOT2							DECIMAL(18,2);

	--SET ISOLATION TO DIRTY READ;
	--SET LOCK MODE TO WAIT 3;
	
	LET v_imes1    	   = 0;		
	LET v_imes2		   = 0;	
	LET v_imes3        = MONTH(pFecha);		
	LET vcodret        = "000";
	LET v_CON_ATMCAPF  =0;
	LET v_CON_ATMCAPM  =0;
	LET v_OPE_ATMCAPF  =0;
	LET v_MONTO_TOT1   =0;	
	LET v_OPE_ATMCAPM  =0;
	LET v_MONTO_TOT2   =0;		
	
	BEGIN
    ON EXCEPTION SET vsqlerr,visamerr
    IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,v_CON_ATMCAPF,v_CON_ATMCAPM,v_OPE_ATMCAPF,v_MONTO_TOT1,v_OPE_ATMCAPM ,v_MONTO_TOT2;	
    END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_con_sc_movhis.out";
	--TRACE ON;
	
	
	
	
		IF v_imes3 = 1 THEN 
		  LET v_ivano1 = YEAR(pFecha);	
		  LET v_ivano1 =  v_ivano1 -1; 
		  LET v_imes1 = 11;		
		  LET v_imes2 = 12;
		ELIF v_imes3 = 2 THEN
		  LET v_ivano1 = YEAR(pFecha);	
		  LET v_ivano1 =  v_ivano1 -1; 		                             
		 LET v_imes1 = 12;
         LET v_imes2 = 01;		  
		ELIF (v_imes3 != 1 AND v_imes3 != 2) THEN
	      LET v_ivano1 = YEAR(pFecha);	
		  LET v_imes1 = v_imes3 - 2;		
		  LET v_imes2 = v_imes3 -1 ;
		END IF;  
	
	
			--2.0 3.0 OBTIENE LOS CLIENTES TIPO MORALES Y SUS CUENTA EN CAPTACION
			SELECT NVL(cl.numcte,'') as numcte,NVL(cuenta,'') as cuenta,NVL(razon_social,0) as razon_social,NVL(rfc,0) as rfc
			  FROM bdinteg:si_cliente cl LEFT JOIN bdicheq:sc_maechq ma 
                ON ma.num_cte = cl.numcte                  
			 WHERE cl.empresa = '001'
			   AND tpo_persona = 2
			  INTO temp tmp_clienteCAPM
			  WITH NO LOG;	  
			
			--cliente fisicos.
			SELECT count(*) 
			  INTO v_CON_ATMCAPF	
			  FROM bdicheq:SC_maechq
			 WHERE  fec_ult_mov IS NOT NULL
			   AND cuenta IS NOT NULL
			   AND producto <> 1100
			   AND status_cta <> 2
			   AND status_cta <> 6
			   AND num_cte NOT IN (SELECT numcte FROM tmp_clienteCAPM WHERE cuenta <> '');	

			--clientes morales. 
		    SELECT count(*) 
			  INTO v_CON_ATMCAPM	
			  FROM bdicheq:SC_maechq
			 WHERE fec_ult_mov IS NOT NULL
			   AND cuenta IS NOT NULL
			   AND producto <> 1100
			   AND status_cta <> 2
			   AND status_cta <> 6			   
			   AND num_cte IN (SELECT numcte FROM tmp_clienteCAPM WHERE cuenta <> '');				 
			    
			SELECT  {bdicred:sc_movhis informix.idx_movhisnew3}
					cuenta,fech_alt,cancelad,transacc,usuario,folio_suc,monto_tot
			  FROM bdicheq:sc_movhis a
             WHERE  a.transacc IN ('0871','0873','0800','0893')	              		
			UNION 
			SELECT {bdicred:sc_movhis_old informix.idxmovhistranspba}
					cuenta,fech_alt,cancelad,transacc,usuario,folio_suc,monto_tot		 
			  FROM bdicheq:sc_movhis_old a
             WHERE  a.transacc IN ('0871','0873','0800','0893')	                     
			INTO TEMP tmp_sc_movhis_old
			WITH NO LOG;
			
		CREATE INDEX informix.idx01tmp_sc_movhis_old ON informix.tmp_sc_movhis_old(fech_alt,cuenta,cancelad,usuario,folio_suc);
	
	
		-- MOVMIENTOS ATM CAPTCION PERSONAS FISICAS
		SELECT count(*),SUM(monto_tot)
		  INTO v_OPE_ATMCAPF,v_MONTO_TOT1
		  FROM tmp_sc_movhis_old
		 WHERE fech_alt BETWEEN  MDY(v_imes1,'01',v_ivano1) AND  pFecha
		   AND cuenta NOT IN  (SELECT cuenta FROM tmp_clienteCAPM WHERE cuenta <> '')
		   AND cancelad <> 'S'
		   AND usuario in ('intercar','sysconau')   		
		   AND folio_suc like ('i%') ;   	
	
		-- MOVIMIENTOS ATM CAPTACION PERSONAS MORALES			 
  		SELECT count(*),SUM(monto_tot) 
		  INTO v_OPE_ATMCAPM,v_MONTO_TOT2
		  FROM tmp_sc_movhis_old
		 WHERE fech_alt    BETWEEN  MDY(v_imes1,'01',v_ivano1) AND  pFecha
		   AND cuenta      IN  (SELECT cuenta FROM tmp_clienteCAPM WHERE cuenta <> '')
		   AND cancelad    <> 'S'
		   AND usuario in ('intercar','sysconau')   		
		   AND folio_suc like ('i%') ;   

		RETURN vcodret,v_CON_ATMCAPF,v_CON_ATMCAPM,v_OPE_ATMCAPF,v_MONTO_TOT1,v_OPE_ATMCAPM ,v_MONTO_TOT2;	
		DROP TABLE tmp_clienteCAPM;
	END  
END PROCEDURE;