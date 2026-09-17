CREATE PROCEDURE "informix".obt_datos_caratula(pEmpresa VARCHAR(3), pNumCred VARCHAR(20))
   RETURNING CHAR(5),  DECIMAL(14,2), DECIMAL(14,2), integer, integer, CHAR(18);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cProducto           CHAR(4);
   DEFINE cTipoCred           CHAR(2);
   DEFINE cMonto              DECIMAL(14,2);
   DEFINE cMontoTotal         DECIMAL(14,2);
   DEFINE cFechaPago          INTEGER;
   DEFINE cFechaCorte         INTEGER;
   DEFINE cClabe			  CHAR(18);
   DEFINE cSecuencia		  SMALLINT;
   
   LET cCodRet       ='00000';
   LET cProducto     ='0000';
   LET cTipoCred     ='00';   
   LET cMonto        =0;   
   LET cMontoTotal	 =0;
  LET cFechaPago	 =0;
  LET cFechaCorte	 =0;
  LET cClabe		 =0;
  LET cSecuencia	 =0;
         
BEGIN
            ON EXCEPTION SET iSqlErr
                  IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cMonto, cMontoTotal, cFechaPago, cFechaCorte, cClabe;
                  END IF;
            END EXCEPTION;
			
			--SET DEBUG FILE TO "/tmp/obt_datos_caratula.out";
			--TRACE ON;
			
                
            SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ;
			
			SELECT num_producto
			INTO cProducto
			FROM sd_maecredcrd 
			WHERE num_credito = pNumCred;
			
			IF cProducto = '' THEN			
				SELECT num_producto
				INTO cProducto
				FROM sd_maecred 
				WHERE num_credito = pNumCred;
			END IF;
			
			SELECT cod_tipcred
			INTO cTipoCred
			FROM sd_definicion 
			WHERE num_producto = cProducto;			
			
			-- Se obtiene la secuencia mas alta de la sd_tarjeta y se almacena en la variable cSecuencia para evitar
			-- hacer un select max dentro de un where, con esto se trae la cuenta activa o inactiva tomando en cuenta
			-- la secuencia mas alta
			SELECT MAX(secuencia) 
			INTO cSecuencia
			FROM sd_tarjeta 
			WHERE num_credito = pNumCred;

				
		   IF cTipoCred = '05' THEN					   	
				
			   SELECT 
				sdo_cap_insoluto, mto_capitalizado, dias_fecha_max_pago, dia_corte
			   INTO
			   	cMonto, cMontoTotal, cFechaPago, cFechaCorte
			   FROM  sd_maecredanexocrd a, sd_maesdoscrd b
			   WHERE a.num_credito = b.num_credito
			   AND a.num_credito = pNumCred
			   AND a.empresa = pEmpresa;  

			   IF ((cMonto IS NULL) OR cMonto = 0) AND cProducto = '6800' THEN
					SELECT 
					monto_otorgado, mto_capitalizado, dias_fecha_max_pago, dia_corte
					INTO
					cMonto, cMontoTotal, cFechaPago, cFechaCorte
					FROM  sd_maecredanexocrd a, sd_maesdoscrd b
					WHERE a.num_credito = b.num_credito
					AND a.num_credito = pNumCred
					AND a.empresa = pEmpresa; 
			   END IF;
			ELSE
			
				
				SELECT 
				limite_aut, (dia_corte - dias_gracia_mora) as diapago , dia_corte
				INTO cMonto, cFechaPago, cFechaCorte
				FROM  sd_maecredanexo a, sd_tarjeta b
				WHERE a.num_credito = b.num_credito
				AND a.num_credito = pNumCred
				AND status_tar in ('A', 'I')
				AND a.empresa = pEmpresa
                AND b.tipo_tarjeta ='T'
				AND b.secuencia = cSecuencia;
				
				IF (cMonto IS NULL) OR cMonto = 0 THEN
					SELECT monto_otorgado
					INTO cMonto
					FROM  sd_maecredanexo a, sd_maesdos b
					WHERE a.num_credito = b.num_credito
					AND a.num_credito = pNumCred
					AND a.empresa = pEmpresa; 
               END IF;
				
	       END IF;
		   
		   SELECT 
				cuenta_clabe
		   INTO cClabe
		   FROM  sd_maecredcrd
		   WHERE num_credito = pNumCred
		   AND empresa = pEmpresa;    

		   IF cClabe = "" Or cClabe IS NULL or cClabe = 0 THEN 		
				SELECT 
					cuenta_clabe
			    INTO cClabe
				FROM  sd_maecred
				WHERE num_credito = pNumCred
				AND empresa = pEmpresa;
				
	       END IF;

           IF (cMonto IS NULL) OR cMonto = 0 THEN
              LET  cCodRet = '00001';  
           END IF;

           RETURN cCodRet, cMonto, cMontoTotal, cFechaPago, cFechaCorte, cClabe;

END;
END PROCEDURE;