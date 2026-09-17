CREATE PROCEDURE "informix".sp_porta_identifica_can_auto(p_empresa char(3))
    RETURNING   CHAR(5);
    
    DEFINE v_c_vcomienza       SMALLINT;
    DEFINE ven_transacc        SMALLINT;
    DEFINE v_c_vcontador       INTEGER;
    DEFINE vsqlerr             INTEGER;
    DEFINE iIsamErr            SMALLINT;
    DEFINE cErrorInfo          CHAR(80);
	DEFINE vErrorInfo          CHAR(80);
    DEFINE vcodret             CHAR(5);
    DEFINE vsql                CHAR(500);
	DEFINE v_cta_orden         CHAR(20);
	DEFINE v_cta_orden_lim     CHAR(20);
	DEFINE v_cuenta            CHAR(20);
	DEFINE v_valida_mov        INTEGER;
	DEFINE v_valida_mov_old    INTEGER;
	DEFINE v_valida_mov_old2   INTEGER;
	DEFINE v_fecha_ini         DATE;
    DEFINE v_fecha_fin         DATE;
	DEFINE v_ultimo_dia_mes    DATE;
	DEFINE v_fecha_ult_dep     DATE;
	DEFINE v_valida_tabla      INTEGER;
	DEFINE v_fecha_movhis      DATE; 
	DEFINE v_fecha_movhis_old  DATE;
    DEFINE v_fecha_movhis_old2 DATE;
	DEFINE v_num_cte           CHAR(20);
	DEFINE v_dias_cance        INTEGER;
	DEFINE vSp_CodRet2         DATE;
	DEFINE v_fecha_alta        DATE; 
	DEFINE v_trasanc           CHAR(1);
	DEFINE v_cadena            CHAR(26);
	DEFINE v_clave_tipo        CHAR(4);
	DEFINE v_ind_cancela       CHAR(1);
	DEFINE v_libre             CHAR(4);
	DEFINE v_sucursal_cta      CHAR(4);
	DEFINE v_fecha_cancela     CHAR(8);
	DEFINE v_idenFechultDiaHab DATE;
 
    LET v_c_vcomienza           = -1;	
    LET ven_transacc            = 0;
    LET v_c_vcontador           = 0;
    LET vsqlerr                 = 0; 
    LET iIsamErr                = 0;
    LET cErrorInfo              = "";   
	LET vErrorInfo              = "INICIO DEL PROCESO";
    LET vcodret                 = "00000";
    LET vsql                    = '';
	LET v_cta_orden             = '';
	LET v_cta_orden_lim         = '';
	LET v_cuenta                = ''; 
	LET v_valida_mov            = 0;
	LET v_valida_mov_old        = 0;
	LET v_num_cte               = ' ';
	LET v_dias_cance            = 10;
	LET v_trasanc 				= "0";
	LET v_cadena                = ' ';
	LET v_clave_tipo            = ' ';
	LET v_ind_cancela           = 'C';
	LET v_libre                 = '0000';
	LET v_sucursal_cta          = ' ';

	
    BEGIN
	ON EXCEPTION SET vsqlerr, iIsamErr, cErrorInfo
	    IF  vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/porta_ca.err";
	 	    TRACE ON;
			LET vcodret     = vsqlerr;
            LET vErrorInfo  = cErrorInfo;
            LET v_cuenta    = v_cuenta;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodRet;
        END IF;
    END EXCEPTION;
	
	ON EXCEPTION IN(-535) 
	   LET v_trasanc = '1';
	END EXCEPTION WITH RESUME;
	
    --SET   DEBUG FILE TO '/RESPALDOSNEW/rsv/portabilidad/porta.txt';
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;   
			
	IF v_trasanc = "1" THEN 
       COMMIT WORK; 
       BEGIN WORK; 
	ELSE 
	   BEGIN WORK;
	END IF; 
			
	SELECT DATE(fecha_hoy - 6 UNITS MONTH), fecha_hoy   , ult_dia_mes
    INTO   v_fecha_ini                    , v_fecha_fin , v_ultimo_dia_mes               
    FROM   sc_fechas; 		
		
	SELECT valor
    INTO   v_fecha_movhis
	FROM   sc_param 
	WHERE  codparam = "fechcon_movhis";
	
    SELECT valor
    INTO   v_fecha_movhis_old
	FROM   sc_param 
	WHERE  codparam = "FechIniCon_movhis_ol";
		
	SELECT COUNT(*) 
	INTO   v_valida_tabla
	FROM   sysmaster:systabnames 
    WHERE  partnum > 0 
	AND    tabname = 'sc_porta_cancel_auto';
		
    SELECT clave_tipo
	INTO   v_clave_tipo
	FROM   bdicheq:sc_portacec_tipo_operacion
	WHERE  clave_tipo = 'CA';
			
		
	--INICIALIZA LA TABLA 	   
	IF  v_valida_tabla > 0 THEN 
	    TRUNCATE TABLE sc_porta_cancel_auto;
	END IF; 
	
	COMMIT WORK; 
    BEGIN WORK; 
	
	--OBTIENE EL ULTIMO DIA HABIL DEL MES 
	EXECUTE PROCEDURE bdicheq:sp_porta_cal_ult_dia_hab("001",v_ultimo_dia_mes)
	INTO vcodret,v_idenFechultDiaHab; 
		
	-- OBTIENE EL DIA HABIL SUMANDOLE 10 DIAS HABILES AL ULTIMO DIA HABIL DEL MES
    EXECUTE PROCEDURE bdicheq:sp_calFechAbil (v_idenFechultDiaHab,v_dias_cance)
	INTO vcodret,vSp_CodRet2;
	
	--ARMA LA FECHA CANCELA
	LET v_fecha_cancela = SUBSTR(vSp_CodRet2,7,4)||SUBSTR(vSp_CodRet2,0,2)||SUBSTR(vSp_CodRet2,4,2);
	
	FOREACH WITH HOLD
	      SELECT cta_ordenante, num_cte
	        INTO v_cta_orden  , v_num_cte
            FROM bdicheq:sc_portacec_solicitud ps
           WHERE estatus_portabilidad  ='1'             
             AND bco_ordenante         ='40137'         
             AND clave_origen          IN ('1','2','3')  
             AND clave_sentido         ='1'             
	         AND cod_operacion         IN ('20','21')   
	  
	          -- INICIA LA TRANSACCION 
	          IF (v_c_vcomienza = -1) THEN
                  LET v_c_vcomienza = 0;
                  LET ven_transacc = 1;
                  IF v_trasanc = "1" THEN 
				     COMMIT WORK; 
				     BEGIN WORK; 
	              ELSE 
	                 BEGIN WORK;
	              END IF; 
              END IF;
		      
			  --ARMA LA CADENA PARA EL FOLIO DE CANCELACION 
		      SELECT SUBSTR(vSp_CodRet2,7,4)||SUBSTR(vSp_CodRet2,0,2)||SUBSTR(vSp_CodRet2,4,2)||SUBSTR(CURRENT,12,2)||SUBSTR(CURRENT,15,2)||SUBSTR(CURRENT,18,2)||cvecesif||TRIM(v_clave_tipo)||v_ind_cancela||v_libre 
	          INTO   v_cadena
	          FROM   bdispei:tblbanco
              WHERE  cvecesif = '40137';

		      LET v_cta_orden_lim = TRIM(v_cta_orden);
			  --CUENTA CLABE 
			  IF LEN(v_cta_orden_lim) = '18' THEN 
			     SELECT FIRST 1 cuenta, fecultdep
				 INTO   v_cuenta      , v_fecha_ult_dep
				 FROM   bdicheq:sc_maechq 
				 WHERE  cuenta_clabe  = v_cta_orden_lim;
				  
				    IF v_cuenta IS NOT NULL OR v_cuenta <> '' THEN 
				        IF v_fecha_ult_dep = ' ' THEN 
					       SELECT fecha_alta
					       INTO   v_fecha_alta 
					       FROM   sc_maenoc
						   WHERE  cuenta = v_cuenta;
						   LET v_fecha_ult_dep  = v_fecha_alta;
				        END IF;

		                IF  v_fecha_ult_dep < v_fecha_ini THEN 
					    	SELECT sucursal 
					    	INTO   v_sucursal_cta
					    	FROM   sc_maechq 
					    	WHERE  num_cte = v_num_cte
					    	AND    cuenta  = v_cuenta;				 
				            INSERT INTO bdicheq:sc_porta_cancel_auto VALUES (v_cta_orden_lim,v_cuenta,v_num_cte,v_fecha_cancela,(v_cadena||v_sucursal_cta),'C');
				        ELSE 
					     
						    SELECT COUNT(*)
				            INTO  v_valida_mov
				            FROM  bdicheq:sc_movhis 
						    WHERE empresa = p_empresa
				            AND   cuenta  = v_cuenta
						    AND   fech_alt BETWEEN  v_fecha_ini AND v_fecha_fin  
						    AND   cancelad <> 'S'
						    AND   transacc IN('0293','0287','0273');
							
							IF  v_valida_mov = 0 THEN 
			                    SELECT COUNT(*)
				                INTO   v_valida_mov_old
				                FROM   bdicheq:sc_movhis_old 
				                WHERE  empresa = p_empresa
				                AND    cuenta  = v_cuenta
							    AND    fech_alt BETWEEN  v_fecha_ini AND v_fecha_fin  
							    AND    cancelad <> 'S'
							    AND    transacc IN('0293','0287','0273');
									
									IF  v_valida_mov_old  = 0 THEN 
									    IF  v_fecha_ini <  v_fecha_movhis_old THEN 
							                SELECT COUNT(*)
				                            INTO  v_valida_mov_old2
				                            FROM  bdicheq:sc_movhis_old2 
				                            WHERE empresa = p_empresa
				                            AND   cuenta  = v_cuenta
							                AND   fech_alt BETWEEN  v_fecha_ini AND v_fecha_fin  
							                AND   cancelad <> 'S'
							                AND   transacc IN('0293','0287','0273');

				                            IF  v_valida_mov_old2 = 0 THEN  
											    SELECT sucursal 
												INTO   v_sucursal_cta
												FROM   sc_maechq 
												WHERE  num_cte = v_num_cte
												AND    cuenta = v_cuenta;
					                            INSERT INTO bdicheq:sc_porta_cancel_auto VALUES (v_cta_orden_lim,v_cuenta,v_num_cte,v_fecha_cancela,(v_cadena||v_sucursal_cta),'C');
					                        END IF;
											
								        ELSE
											SELECT sucursal 
											INTO   v_sucursal_cta
											FROM   sc_maechq 
											WHERE  num_cte = v_num_cte
											AND    cuenta = v_cuenta;
									        INSERT INTO bdicheq:sc_porta_cancel_auto VALUES (v_cta_orden_lim,v_cuenta,v_num_cte,v_fecha_cancela,(v_cadena||v_sucursal_cta),'C');
										END IF;
					                END IF;
				            END IF;
				        END IF;
				    END IF;
              --POR TARJETA 
		      ELIF  LEN(v_cta_orden_lim) = '16' THEN 
			        SELECT FIRST 1 cuenta 
				    INTO v_cuenta
				    FROM bdicheq:sc_tarjeta 
				    WHERE num_tarjeta = v_cta_orden_lim;
				   
				    IF  v_cuenta IS NOT NULL OR v_cuenta <> '' THEN 
					    SELECT COUNT(*)
				        INTO   v_valida_mov
				        FROM   bdicheq:sc_movhis 
				        WHERE  empresa = p_empresa
					    AND    cuenta  = v_cuenta
						AND    fech_alt BETWEEN  v_fecha_ini AND v_fecha_fin  
						AND    cancelad <> 'S'
						AND    transacc IN('0293','0287','0273');
				  
				        IF  v_valida_mov = 0 THEN 
			                SELECT COUNT(*)
				            INTO   v_valida_mov_old
				            FROM   bdicheq:sc_movhis_old 
				            WHERE  empresa = p_empresa
				            AND    cuenta  = v_cuenta
							AND    fech_alt BETWEEN  v_fecha_ini AND v_fecha_fin  
							AND    cancelad <> 'S'
							AND    transacc IN('0293','0287','0273');
								   
						    IF  v_valida_mov_old = 0 THEN 
								IF  v_fecha_ini <  v_fecha_movhis_old THEN 
							        SELECT COUNT(*)
				                    INTO v_valida_mov_old2
				                    FROM bdicheq:sc_movhis_old2 
				                    WHERE empresa = p_empresa
				                    AND cuenta  = v_cuenta
							        AND fech_alt BETWEEN  v_fecha_ini AND v_fecha_fin  
							        AND cancelad <> 'S'
							        AND transacc IN('0293','0287','0273');
                                              
								    IF  v_valida_mov_old2 = 0 THEN  	
									    SELECT sucursal 
										INTO   v_sucursal_cta
										FROM   sc_maechq 
										WHERE  num_cte = v_num_cte
										AND    cuenta  = v_cuenta;

										IF  v_sucursal_cta IS NULL THEN 
										    CONTINUE FOREACH;    
										END IF;
										
                                        INSERT INTO bdicheq:sc_porta_cancel_auto VALUES (v_cta_orden_lim,v_cuenta,v_num_cte,v_fecha_cancela,(v_cadena||v_sucursal_cta),'T');	
                                    END IF; 												  
								ELSE 
								    SELECT sucursal 
									INTO   v_sucursal_cta
									FROM   sc_maechq 
									WHERE  num_cte = v_num_cte
									AND    cuenta = v_cuenta; 
									
									IF  v_sucursal_cta IS NULL THEN 
										CONTINUE FOREACH;    
								    END IF;

									
								    INSERT INTO bdicheq:sc_porta_cancel_auto VALUES (v_cta_orden_lim,v_cuenta,v_num_cte,v_fecha_cancela,(v_cadena||v_sucursal_cta),'T');
							    END IF;
						    END IF;
					    END IF;
				    END IF; 
		       END IF;
 
			    LET v_c_vcontador = v_c_vcontador + 1;
			    IF (v_c_vcontador >= 1000) THEN
                    LET v_c_vcontador = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF; 
    END FOREACH;
   
	--SI LA TRANSACCION ESTA ABIERTA REALIZA EL COMMIT
	IF  ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;	 

	IF v_trasanc = "1" THEN 
	   BEGIN WORK; 
	END IF;
    RETURN  vcodret;
END; 
END PROCEDURE;