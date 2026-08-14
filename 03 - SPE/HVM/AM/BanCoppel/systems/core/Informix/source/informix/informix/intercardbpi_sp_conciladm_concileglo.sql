CREATE PROCEDURE "informix".sp_conciladm_concileglo( pempresa char(3),
										             pfecha   date)
RETURNING VARCHAR(5), VARCHAR(255);

--//Definicion de variables
DEFINE vcodret        CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE iSamErr		  INTEGER;
DEFINE cVarDataErr	  VARCHAR(64);

DEFINE vt_producto 	  CHAR(4);

DEFINE v_secuencia_e        VARCHAR(6);
DEFINE v_nro_tarjeta_s      VARCHAR(20);
DEFINE v_num_cuenta_cred_s  VARCHAR(20);
DEFINE v_importe_s          DECIMAL(18,2);
DEFINE v_secuencia_s        VARCHAR(6);
DEFINE v_fecha_mov_s        DATE; 
DEFINE v_transacc_s         VARCHAR(4); 
DEFINE v_c_cargo_s          VARCHAR(14);
DEFINE v_c_abono_s          VARCHAR(14); 
DEFINE v_rowcount           INTEGER;

DEFINE v_importe_ss          DECIMAL(18,2);
DEFINE v_rowcount_s         INTEGER;

DEFINE btabla1				CHAR(1);
DEFINE btabla2				CHAR(1);
DEFINE vusuario				VARCHAR(8);
DEFINE vnum_reg_ins			INTEGER;
DEFINE vimporte				DECIMAL(18,2);
DEFINE vfecha_mov	        DATE;

   --Manejo del error
    ON EXCEPTION SET vsqlerr,iSamErr, cVarDataErr
		IF(btabla1 = 'T') THEN  DROP TABLE tmp_sc_movhis; END IF;	
		IF(btabla2 = 'T') THEN  DROP TABLE tmp_sd_movhis; END IF;

		IF vsqlerr <> 0 then
			LET vcodret = vsqlerr;
			RETURN vcodret, iSamErr || ' ' ||cVarDataErr;
		END IF
    END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   --set debug file to "/tmp/sp_conciladm_concileglo.out";
   --trace on;

    --//Inicializacion de variables
   LET vcodret    = "000";
   LET v_nro_tarjeta_s = "";	    
   LET v_num_cuenta_cred_s = "";	
   LET v_importe_s = 0.0;
   LET v_secuencia_s = "";	        
   LET v_transacc_s = "";	       
   LET v_c_cargo_s = "";	        
   LET v_c_abono_s = "";	
   LET v_rowcount = 0;  
   LET v_importe_ss = 0.0;  
   LET v_rowcount_s = 0;   
   LET vusuario	= 0; 
   LET vnum_reg_ins	= 0; 
   LET vimporte	= 0; 
   LET vfecha_mov = '';
   
   LET btabla1 = 'F';
   LET btabla2 = 'F';

   IF pempresa ="" OR pfecha ="" THEN
      LET vcodret = "110";
      RETURN vcodret,"FALTAN PARAMETROS";
   END IF

	SELECT {+INDEX(si_prodtran idx01_prodtran)} 	 
			usuario ,num_tarjeta,cuenta,monto_tot,TRIM(folio_suc[11,16]) AS secuencia,fech_alt,b.transaccion,
	        TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) as c_cargo,
	        TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) as c_abono
      FROM bdicheq:sc_movhis a, bdinteg:si_prodtran b
	WHERE a.transacc IN (SELECT DISTINCT transaccion FROM bdinteg:si_prodtran WHERE a_ccmayor='2402' AND a_ccsub='93'
                            AND producto IN (SELECT producto FROM bdicheq:sc_producto))
      AND a.fech_alt = pfecha
      AND a.transacc = b.transaccion
      AND a.usuario in('intercar','sysconau') 
      AND b.transaccion = a.transacc
      AND b.producto= a.producto
      AND a.num_cheq = 0
      AND a.folio_suc[1,1]='i'
	ORDER BY 4,1,2
     INTO TEMP tmp_sc_movhis
     WITH NO LOG;

	LET btabla1 = 'T';

	CREATE INDEX "informix".tmp_sc_movhis ON "informix".tmp_sc_movhis(num_tarjeta) online;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_sc_movhis;
	
	FOREACH 
    SELECT usuario,count(*),nvl(sum(monto_tot),0),fech_alt 
	  INTO vusuario,vnum_reg_ins,vimporte,vfecha_mov
      FROM tmp_sc_movhis
     GROUP BY usuario, fech_alt	
	   INSERT INTO conciladm_sifegloposacum(sistema,usuario,num_reg_ins,importe,fecha_mov)
	   VALUES ('01',vusuario,vnum_reg_ins,vimporte,vfecha_mov);
	END FOREACH;
	
	
	FOREACH 
	SELECT num_tarjeta,cuenta,monto_tot, secuencia,fech_alt,transaccion,c_cargo,c_abono
	  INTO v_nro_tarjeta_s,v_num_cuenta_cred_s,v_importe_s,v_secuencia_s,v_fecha_mov_s,v_transacc_s,v_c_cargo_s,v_c_abono_s         
	  FROM tmp_sc_movhis
	 WHERE 1 = 1

		SELECT COUNT(nro_tarjeta_e) 
          INTO v_rowcount
          FROM intercard:conciladm_eglopos 
         WHERE secuencia_e = v_secuencia_s
           AND tipo_mov_e = '01'
		   AND fecha_mov_s IS NULL
           AND importe_e = v_importe_s 
           AND (nomarchivo_e LIKE '%VND%' OR nomarchivo_e LIKE '%VID%');

		IF v_rowcount = 1 THEN
			UPDATE intercard:conciladm_eglopos SET 
			       nro_tarjeta_s =  v_nro_tarjeta_s, 
				   num_cuenta_cred_s = v_num_cuenta_cred_s,
				   importe_s = v_importe_s,
				   secuencia_s = v_secuencia_s,       
				   fecha_mov_s = v_fecha_mov_s,     
				   transacc_s = v_transacc_s,       
				   c_cargo_s = v_c_cargo_s,         
				   c_abono_s = v_c_abono_s       
	          WHERE secuencia_e = v_secuencia_s
                AND tipo_mov_e = '01'
	            AND fecha_mov_s IS NULL
	            AND importe_e = v_importe_s
                AND (nomarchivo_e LIKE '%VND%' OR nomarchivo_e LIKE '%VID%') ;
		ELSE
			INSERT INTO intercard:conciladm_eglopos(nro_tarjeta_s,num_cuenta_cred_s,importe_s,secuencia_s,fecha_mov_s,transacc_s,c_cargo_s,c_abono_s) 
	              VALUES(v_nro_tarjeta_s,v_num_cuenta_cred_s,v_importe_s,v_secuencia_s,v_fecha_mov_s,v_transacc_s,v_c_cargo_s,v_c_abono_s);

		END IF

	END FOREACH;

	SELECT {+INDEX(si_prodtran idx01_prodtran)}
            nro_tarjeta,num_credito,monto,TRIM(folio_suc[11,16]) AS secuencia,fecha_mov,b.transacc,
	        TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) as c_cargo,
	        TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) as c_abono
	FROM bdicred:sd_movhis a, bdicred:sd_transfun b , bdinteg:si_prodtran c
	WHERE a.codigo_fun = b.codigo_fun
	  AND a.codigo_ref = b.codigo_ref
	  AND a.monto <> 0
	  AND a.fecha_mov = pfecha
	  AND a.usuario='sysconau'
   	  AND b.transacc in (SELECT {+INDEX(si_prodtran idx01_prodtran)}DISTINCT transaccion 
							FROM bdinteg:si_prodtran 
						   WHERE transaccion NOT IN (SELECT DISTINCT transacc 
							                           FROM bdicred:sd_transfun a, bdinteg:si_prodtran b
							                          WHERE a.codigo_fun='334'
							                            AND a.codigo_ref <> 1
							                            AND a.transacc = b.transaccion
							                            AND b.transaccion = a.transacc
							                            AND b.producto = '6001'
							                            AND b.sistema = '06')
							 AND producto = '6001'
							 AND sistema = '06'
							 AND c_ccmayor='2402' 
							 AND c_ccsub='93' 
							UNION
						   SELECT {+INDEX(si_prodtran idx01_prodtran)} DISTINCT transaccion 
							 FROM bdinteg:si_prodtran 
							WHERE transaccion NOT IN (SELECT DISTINCT transacc 
							                           FROM bdicred:sd_transfun a, bdinteg:si_prodtran b
							                          WHERE a.codigo_fun='334'
							                            AND a.codigo_ref <> 1
							                            AND a.transacc = b.transaccion
							                            AND b.transaccion = a.transacc
							                            AND b.producto = '6001'
							                            AND b.sistema = '06')
                              AND transaccion NOT IN (6890,6893,7384) --COMISION Y CONSULTA CAJRED SURCHARGE
							  AND producto = '6001'
							  AND sistema = '06'
							  AND a_ccmayor='2402' 
							  AND a_ccsub='93')
	  AND c.transaccion = b.transacc 
	  AND c.producto = '6001'
	  AND c.sistema = '06'
	  AND (c.a_ccmayor='2402' AND c.a_ccsub='93')
	ORDER BY 4,1,2,3 desc
    INTO TEMP tmp_sd_movhis
    WITH NO LOG;

	CREATE INDEX "informix".tmp_sd_movhis ON "informix".tmp_sd_movhis(nro_tarjeta) online;
	UPDATE STATISTICS MEDIUM FOR TABLE "informix".tmp_sd_movhis;
	
	LET btabla2 = 'T';

	INSERT INTO conciladm_sifegloposacum(sistema,usuario,num_reg_ins,importe,fecha_mov)
    SELECT '06','sysconau',count(*),nvl(sum(monto),0),fecha_mov 
      FROM tmp_sd_movhis
     GROUP BY fecha_mov; 
	
	FOREACH 
	SELECT *
	  INTO v_nro_tarjeta_s,v_num_cuenta_cred_s,v_importe_s,v_secuencia_s,v_fecha_mov_s,v_transacc_s,v_c_cargo_s,v_c_abono_s         
	  FROM tmp_sd_movhis
	  WHERE  1=1
	  ORDER BY secuencia,nro_tarjeta,monto desc
		
	SELECT COUNT(nro_tarjeta) 
          INTO v_rowcount_s
          FROM tmp_sd_movhis 
         WHERE nro_tarjeta = v_nro_tarjeta_s
		   AND num_credito = v_num_cuenta_cred_s
		   AND secuencia = v_secuencia_s
           AND fecha_mov = v_fecha_mov_s;
		         
		IF v_rowcount_s = 2 THEN
			
			SELECT sum(monto)
			  INTO v_importe_ss         
			  FROM tmp_sd_movhis
			  WHERE  nro_tarjeta = v_nro_tarjeta_s
			   AND num_credito = v_num_cuenta_cred_s
			   AND secuencia = v_secuencia_s
			   AND fecha_mov = v_fecha_mov_s;
		     
			
			UPDATE tmp_sd_movhis SET 
			       monto = v_importe_ss    
     		  WHERE nro_tarjeta = v_nro_tarjeta_s
			   AND num_credito = v_num_cuenta_cred_s
			   AND secuencia = v_secuencia_s
			   AND fecha_mov = v_fecha_mov_s
			   AND monto = v_importe_s
			   AND transacc = v_transacc_s
			   AND c_cargo = v_c_cargo_s
			   AND c_abono = v_c_abono_s;
			  
			DELETE 
			  FROM tmp_sd_movhis
			  WHERE nro_tarjeta = v_nro_tarjeta_s
			   AND num_credito = v_num_cuenta_cred_s
			   AND secuencia = v_secuencia_s
			   AND fecha_mov = v_fecha_mov_s
			   AND transacc <> v_transacc_s;
			 
					  
		END IF 
	END FOREACH; 
	 
	FOREACH 
	SELECT *
	  INTO v_nro_tarjeta_s,v_num_cuenta_cred_s,v_importe_s,v_secuencia_s,v_fecha_mov_s,v_transacc_s,v_c_cargo_s,v_c_abono_s         
	  FROM tmp_sd_movhis
	  WHERE  1=1
	  ORDER BY secuencia,nro_tarjeta,monto desc
		
	SELECT COUNT(nro_tarjeta_e) 
          INTO v_rowcount
          FROM intercard:conciladm_eglopos 
         WHERE secuencia_e = v_secuencia_s
           AND tipo_mov_e = '01'
           AND fecha_mov_s IS NULL
           AND importe_e = v_importe_s 
           AND (nomarchivo_e LIKE '%VNC%' OR nomarchivo_e LIKE '%VIC%') ;

		IF v_rowcount = 1 THEN
			UPDATE intercard:conciladm_eglopos SET 
			       nro_tarjeta_s =  v_nro_tarjeta_s, 
				   num_cuenta_cred_s = v_num_cuenta_cred_s,
				   importe_s = v_importe_s,
				   secuencia_s = v_secuencia_s,       
				   fecha_mov_s = v_fecha_mov_s,     
				   transacc_s = v_transacc_s,       
				   c_cargo_s = v_c_cargo_s,         
				   c_abono_s = v_c_abono_s       
			  WHERE secuencia_e = v_secuencia_s
                AND tipo_mov_e = '01'
	            AND fecha_mov_s IS NULL
	            AND importe_e = v_importe_s 
                AND (nomarchivo_e LIKE '%VNC%' OR nomarchivo_e LIKE '%VIC%') ;
		ELSE
			INSERT INTO intercard:conciladm_eglopos(nro_tarjeta_s,num_cuenta_cred_s,importe_s,secuencia_s,fecha_mov_s,transacc_s,c_cargo_s,c_abono_s) 
	              VALUES(v_nro_tarjeta_s,v_num_cuenta_cred_s,v_importe_s,v_secuencia_s,v_fecha_mov_s,v_transacc_s,v_c_cargo_s,v_c_abono_s);

		END IF

	END FOREACH;

	IF(btabla1 = 'T') THEN  DROP TABLE tmp_sc_movhis;	END IF;	
	IF(btabla2 = 'T') THEN  DROP TABLE tmp_sd_movhis;	END IF;

	RETURN vcodret,"PROCESO EXITOSO";

END PROCEDURE;