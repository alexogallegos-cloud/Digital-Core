CREATE PROCEDURE "informix".sp_con_sd_movhis(  pFecha DATE )
RETURNING CHAR(5),integer,integer,integer,decimal(18,2),integer,decimal(18,2);

	--Variables Exception
	DEFINE vcodret          CHAR(5);
	DEFINE vsqlerr,visamerr INTEGER; 

	DEFINE v_imes1								INTEGER;
	DEFINE v_imes2								INTEGER;	
	DEFINE v_imes3								INTEGER;	
	DEFINE v_ivano1								INTEGER;

	DEFINE v_CON_ATMCREF                        INTEGER;
	DEFINE v_CON_ATMCREM						INTEGER;
	DEFINE v_OPE_ATMCREF						INTEGER;
	DEFINE v_MONTO_TOT1							DECIMAL(18,2);	
	DEFINE v_OPE_ATMCREM						INTEGER;
	DEFINE v_MONTO_TOT2							DECIMAL(18,2);
	DEFINE vproducto							VARCHAR(4);
	DEFINE vproducto1							VARCHAR(4);
	DEFINE vproducto2							VARCHAR(4);
	DEFINE vproducto3							VARCHAR(4);
	

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
    ON EXCEPTION SET vsqlerr,visamerr
    IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,v_CON_ATMCREF,v_CON_ATMCREM,v_OPE_ATMCREF,v_MONTO_TOT1,v_OPE_ATMCREM ,v_MONTO_TOT2;	
    END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/sp_con_sd_movhis.out";
	--TRACE ON;
	
	LET v_imes1                 = 0;
	LET v_imes2                 = 0;
	LET v_imes3                 = MONTH(pFecha);		
	LET v_ivano1  		        = 0;
	
	LET vcodret         = "000";
	LET v_CON_ATMCREF  =0;
	LET v_CON_ATMCREM  =0;
	LET v_OPE_ATMCREF  =0;
	LET v_MONTO_TOT1    =0;	
	LET v_OPE_ATMCREM  =0;
	LET v_MONTO_TOT2    =0;	
	LET vproducto       =0;	
	LET vproducto1      =0;	
	LET vproducto2      =0;	
	LET vproducto3      =0;		
	

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


	
		-- resolvio en 4 minuts-- optimizar la busqueda secuencial y verificar si exste alguna directiva		
			--SELECT {bdicred:sd_maecred idx_maecreda} 
			SELECT  NVL(cl.numcte,'') as numcte,NVL(num_credito,'') as cuenta,NVL(razon_social,0) as razon_social,NVL(rfc,0) as rfc
			  FROM   bdinteg:si_cliente cl LEFT JOIN bdicred:sd_maecred ma 
                   ON --ma.empresa = '001' AND
					ma.numcte = cl.numcte 
			 WHERE --cl.empresa = '001' AND 
			    tpo_persona = '02' 
			  INTO temp tmp_clientePM
			  WITH NO LOG;	     		
			
			
		-- 3.1 OBTIENE EL NUMERO DE CONTRATOS PARA LAS CUENTAS DE CREDITO PERSONAS FISICAS		
			
		    SELECT count(*) as num_contratos,num_producto	
			  INTO v_CON_ATMCREF,vproducto		
              FROM bdicred:sd_maecred m
	         WHERE m.num_credito  NOT IN( SELECT num_credito
                                            --FROM bdicred:sd_maecred_vendida
											FROM bdicred:sd_maecred_vend_total
                                           WHERE --empresa= '001' AND
                                             fecha <= pFecha
                                             AND num_credito > '0'
	    								     AND credito_externo = '')
			   AND m.num_credito NOT IN (SELECT num_credito
										   FROM bdicred:sd_maecredcrd)
			   AND m.numcte NOT IN (SELECT numcte FROM tmp_clientePM WHERE numcte <> '')											   
			   AND SUBSTR (m.num_credito,1,4) <>'6300'
	    	   AND  m.empresa = '001'
			   GROUP BY num_producto;
			  --INTO TEMP tmp_CON_ATMCREF
			  --WITH NO LOG;

		-- 3.3 OBTIENE EL NUMERO DE CONTRATOS PARA LAS CUENTAS DE CREDITO PERSONAS MORALES
		
		    SELECT count(*) as num_contratos,num_producto	
			  INTO v_CON_ATMCREM,vproducto1		
              FROM bdicred:sd_maecred m
	         WHERE m.num_credito  NOT IN( SELECT num_credito
                                           -- FROM bdicred:sd_maecred_vendida
										   FROM bdicred:sd_maecred_vend_total
                                           WHERE --empresa= '001' AND
                                              fecha <= pFecha
                                             AND num_credito > '0'
	    								     AND credito_externo = '')
			   AND SUBSTR (m.num_credito,1,4) <>'6300'
	    	   AND  m.empresa = '001'
	    	   AND  m.num_credito NOT IN (SELECT num_credito
                                         FROM bdicred:sd_maecredcrd)
			   AND m.numcte  IN (SELECT numcte FROM tmp_clientePM WHERE numcte <> '')											 
	    	   AND m.empresa = '001'
			  GROUP BY num_producto;
			  --INTO TEMP tmp_CON_ATMCREM
			  --WITH NO LOG;		 
	
		-- 3.2 OBTIENE EL NUMERO DE OPERACIONES MOVIMIENTOS CREDITO  ATM CREDITO FISICAS
			
			 SELECT {bdicred:sd_movhis informix.inx_movhis}
				 count(*) AS ope_atmcref,num_producto,monto
			 INTO v_OPE_ATMCREF,vproducto2,v_MONTO_TOT1 
			 FROM bdicred:sd_movhis 
			 where empresa = '001'
			   AND num_credito in (select num_credito from tmp_clientePM WHERE numcte <> '')
			   AND codigo_fun = '002'
			   AND codigo_ref in ('34','35','36','30')
			   AND fecha_mov >= MDY(v_imes1,'01',v_ivano1)
			   AND fecha_mov <= pFecha
			   AND reversado <> 'S'
			 group by num_producto,monto;
			 --INTO TEMP tmp_OPE_ATMCREF
			 --WITH NO LOG;			
	
		-- 3.4 OBTIENE NUMERO DE OPERACIONES PARA MOVIMIENTOS CREDITO ATM PERSONAS MORALES	  

			SELECT {bdicred:sd_movhis informix.inx_movhis}
				count(*) as ope_atmcrem,num_producto,monto
			 INTO v_OPE_ATMCREM,vproducto3,v_MONTO_TOT2 
			 FROM bdicred:sd_movhis 
			 where empresa = '001'
			   AND num_credito in (select num_credito from tmp_clientePM WHERE numcte <> '')
			   AND codigo_fun = '002'
			   AND codigo_ref in ('34','35','36','30')
			   AND fecha_mov >= MDY(v_imes1,'01',v_ivano1)
			   AND fecha_mov <= pFecha
			   AND reversado <> 'S'
			 group by num_producto,monto;
			 --INTO TEMP tmp_OPE_ATMCREM
			 --WITH NO LOG;		
			
		RETURN vcodret,v_CON_ATMCREF,v_CON_ATMCREM,v_OPE_ATMCREF,v_MONTO_TOT1,v_OPE_ATMCREM ,v_MONTO_TOT2;	
		DROP TABLE tmp_clientePM;
	END  
END PROCEDURE;