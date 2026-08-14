CREATE PROCEDURE "informix".spsp_r24d2441( pEmpresa CHAR(3), pFecha DATE )
RETURNING VARCHAR(5), VARCHAR(255);

 --****************************************************************************************************
 -- DESCRIPCION: GENERA REPORTE REG  R24d241 Informacion General sobre el Uso de Servicios Finacieros 
 -- y R24d2442 Información de Frecuencia de Uso de Servicios Financieros.
 -- AUTOR : René Aldana Hernández
 -- FECHA : 22/11/2012
 -- BD: bdirepaut
 -- SISTEMA : MODULO REPORTE A LAS AUTORIDADES SIF. 
 --***************************************************************************************************
	--Variables Exception

	DEFINE cVarDataErr							VARCHAR(64);
	DEFINE iSqlErr								INTEGER;
	DEFINE iSamErr								INTEGER;
	DEFINE vCodret								CHAR(5);
	DEFINE v_sq01        		                VARCHAR(250);
	DEFINE v_sq02        		                VARCHAR(250);
	DEFINE v_idia                  	 			SMALLINT;
	DEFINE v_iMes                   			SMALLINT;
	DEFINE v_iAnio                  			SMALLINT;	
	DEFINE dFechaAnt							DATE;
	DEFINE vcontador          					INTEGER;
    --Variables Programa

	DEFINE vfolio_suc       CHAR(16);
    DEFINE vcuenta        	CHAR(20);
    DEFINE vtransacc        CHAR(4);
	DEFINE vmonto_tot		DECIMAL(18,2);
	DEFINE vsucursal		CHAR(4);
	DEFINE vnaturaleza      CHAR(1);	
	
	
	--variables trabajo
	DEFINE v_flag              			CHAR(10);
	DEFINE v_flag_old					CHAR(10);
	DEFINE v_flag_old2					CHAR(10);
	DEFINE v_tip_cta_transac 			VARCHAR(2);

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	BEGIN
	ON EXCEPTION
		SET iSqlErr, iSamErr, cVarDataErr
		IF iSqlErr <> 0 THEN
			LET vCodret=iSqlErr;
			RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
	--SET DEBUG FILE TO "/tmp/spsp_r24d2441.out";
	--TRACE ON;
		
	DELETE FROM bdirepaut:sp_r24d2441
	WHERE nombre_form = 'R24d2441';
	 
	DELETE FROM bdirepaut:sp_r24d2442
	WHERE nombre_form = 'R24d2442';
	
	LET v_flag      		= '0';
	LET v_flag_old			= '0';	
	LET vcontador           = '0';

    LET v_idia  = DAY(pFecha);
    LET v_iMes  = MONTH(pFecha);
    LET v_iAnio = YEAR(pFecha);
		
    LET dFechaAnt = MDY(v_iMes,'01',YEAR(pFecha));

	
		-- Parametros para accesar a la Movhis
		SELECT nvl(valor,0) INTO v_flag
		FROM bdicheq:sc_param
		WHERE codparam = 'fechcon_movhis'
		  AND empresa='001';

		-- Parametros para accesar a la Movhis_old
		SELECT nvl(valor,0) INTO v_flag_old
		  FROM bdicheq:sc_param
		 WHERE codparam = 'FechIniCon_movhis_ol'
		   AND empresa='001';

	LET v_tip_cta_transac = '';
	--obtener el tipo de cuenta transaccional "18" Cuenta Bancaria Tradicional (expediente completo) cargar en un parametro para obtener la CLAVE CNBV
	--INSERT INTO bdirepaut:sp_param(claveparam, empresa, descripparam, valorparam)
	--VALUES(244101, '001', 'R24D2441 CUENTA BANCARIA TRADICIONAL (EXPEDIENTE COMPLETO)', '18');
	
	SELECT valorparam
	  INTO v_tip_cta_transac
	  FROM bdirepaut:sp_param
	 WHERE claveparam = 244101;
	
	-- El canal de transaccional.

	TRUNCATE TABLE tmp_ope_cap;
	TRUNCATE TABLE tmp_ope;
	LET vcontador   =1;	
	FOREACH WITH HOLD
	SELECT folio_suc,cuenta,transacc,NVL(ROUND(monto_tot),0),sucursal,naturaleza	
	  INTO  vfolio_suc,vcuenta,vtransacc,vmonto_tot,vsucursal,vnaturaleza
	  FROM bdicheq:sc_movhis_old sc,bdinteg:si_transacc
	 WHERE sc.empresa = '001'
	   AND sc.cuenta <> ''
	   AND fech_alt BETWEEN  dFechaAnt AND pFecha
       AND fech_alt >= v_flag_old
       AND fech_alt < v_flag
	   AND sucursal IN (SELECT sucursal
                          FROM bdinteg:si_sucursales 
                         WHERE tpo_sucursal = 'S'
                            OR sucursal IN ('5003','5005','5007','9290')
						)							
       AND cancelad <> 'S'
	   AND transacc = numero
       AND transacc IN (SELECT numero from bdinteg:si_transacc
                         WHERE sistema = '01'
                           AND naturaleza IN('C','A')) 
     GROUP BY 1,2,3,4,5,6 
		
		IF vcontador=1 THEN
			BEGIN WORK;
		END IF	
				
			INSERT INTO bdirepaut:tmp_ope_cap
			VALUES(vfolio_suc,vcuenta,vtransacc,vmonto_tot,vsucursal,vnaturaleza);
   
   		IF vcontador >= 75000 then
			COMMIT WORK;
			LET vcontador=1;
			UPDATE STATISTICS MEDIUM FOR TABLE 	bdirepaut:tmp_ope_cap;	
		ELSE
			LET vcontador = vcontador + 1 ;
		END IF;
					
		
		CONTINUE FOREACH;
	END FOREACH;
   
   LET vcontador   =1;	
   FOREACH WITH HOLD
	SELECT folio_suc,cuenta,transacc,NVL(ROUND(monto_tot),0),sucursal,naturaleza	
	  INTO  vfolio_suc,vcuenta,vtransacc,vmonto_tot,vsucursal,vnaturaleza
	  FROM bdicheq:sc_movhis sc,bdinteg:si_transacc
	 WHERE sc.empresa = '001'
	   AND sc.cuenta <> ''
	   AND fech_alt BETWEEN  dFechaAnt AND pFecha
       AND fech_alt >= v_flag
	   AND sucursal IN (SELECT sucursal
                          FROM bdinteg:si_sucursales 
                         WHERE tpo_sucursal = 'S'
                            OR sucursal IN ('5003','5005','5007','9290')
						)	
       AND cancelad <> 'S'
	   AND transacc = numero
       AND transacc IN (SELECT numero from bdinteg:si_transacc
                         WHERE sistema = '01'
                           AND naturaleza IN('C','A')) 
     GROUP BY 1,2,3,4,5,6 
	 
		IF vcontador=1 THEN
			BEGIN WORK;
		END IF	
				
			INSERT INTO bdirepaut:tmp_ope_cap
			VALUES(vfolio_suc,vcuenta,vtransacc,vmonto_tot,vsucursal,vnaturaleza);
   
   		IF vcontador >= 75000 then
			COMMIT WORK;
			LET vcontador=1;
			UPDATE STATISTICS MEDIUM FOR TABLE 	bdirepaut:tmp_ope_cap;		
		ELSE
			LET vcontador = vcontador + 1 ;
		END IF;
					
	
		CONTINUE FOREACH;
	END FOREACH;

	 
	 -- CONTABLIZA LAS CUENTAS 

    INSERT INTO  tmp_ope
	SELECT count(cuenta) num_ope, cuenta
	  FROM bdicheq:sc_movhis_old sc,bdinteg:si_transacc
	 WHERE sc.empresa = '001'
	   AND sc.cuenta <> ''
	   AND fech_alt BETWEEN  dFechaAnt AND pFecha
       AND fech_alt >= v_flag_old
       AND fech_alt < v_flag     
       AND cancelad <> 'S'
	   AND transacc = numero
       AND transacc IN (SELECT numero from bdinteg:si_transacc
                         WHERE sistema = '01'
                           AND naturaleza IN('C','A')) 
	   AND sucursal IN (SELECT sucursal
                          FROM bdinteg:si_sucursales 
                         WHERE tpo_sucursal = 'S'
                            OR sucursal IN ('5003','5005','5007','9290'))						   
     GROUP BY cuenta;

	 
    INSERT INTO  tmp_ope
	SELECT count(cuenta) num_ope, cuenta
	  FROM bdicheq:sc_movhis sc,bdinteg:si_transacc
	 WHERE sc.empresa = '001'
	   AND sc.cuenta <> ''	 
	   AND fech_alt BETWEEN  dFechaAnt AND pFecha       
       AND fech_alt >= v_flag
       AND cancelad <> 'S'
	   AND transacc = numero
       AND transacc IN (SELECT numero from bdinteg:si_transacc
                         WHERE sistema = '01'
                           AND naturaleza IN('C','A')) 
	   AND sucursal IN (SELECT sucursal
                          FROM bdinteg:si_sucursales 
                         WHERE tpo_sucursal = 'S'
                            OR sucursal IN ('5003','5005','5007','9290'))						   
     GROUP BY cuenta;	 	 
	-- REALIZA EL AGRUPADO DE CADA REGISTROS PARA IDENTIFICAR LA  OEPRACION QUE REALIZA EL USUARIO. 
	
	-- AGRUPADO PARA OBTENER EL CANAL SUCURSAL
	
		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
			v_tip_cta_transac,
			208, -- SUCURSAl			
			'301', -- CARGO
			SUM(monto_tot) monto,
			count(*) num_ope,
			count(distinct cuenta) num_cli																	
		FROM tmp_ope_cap 
		WHERE sucursal  in (SELECT sucursal
							FROM bdinteg:si_sucursales 
							WHERE tpo_sucursal = 'S'
							AND sucursal NOT IN ('5002','5003','5007'))
           AND naturaleza = 'C'											
		GROUP BY  1,2,3,4;
		
		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
			v_tip_cta_transac,
			208, -- SUCURSAL
			'302', -- ABONO			
			SUM(monto_tot) monto,
			count(*)  num_ope,			
			count(distinct cuenta) num_cli				
		FROM tmp_ope_cap 
		WHERE sucursal  in (SELECT sucursal
							FROM bdinteg:si_sucursales 
							WHERE tpo_sucursal = 'S'
							AND sucursal NOT IN ('5002','5003','5007'))
           AND naturaleza = 'A'											
		GROUP BY  1,2,3,4;		
		
	-- AGRUPADO PARA EL CANAL INTERNET

		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
				v_tip_cta_transac,
				224, -- INTERNET
				'301', -- CARGO
				SUM(monto_tot) monto,
				count(*) num_ope,
				count(distinct cuenta) num_cli
		 FROM tmp_ope_cap 
		WHERE sucursal in ('5002','5003','5007')
		  AND naturaleza = 'C'
		GROUP BY  1,2,3,4;
		
		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
				v_tip_cta_transac,
				224, -- INTERNET
				'302', --ABONO
				SUM(monto_tot) monto,
				count(*) num_ope,
				count(distinct cuenta) num_cli
		 FROM tmp_ope_cap 
		WHERE sucursal in ('5002','5003','5007')
		  AND naturaleza = 'A'
		GROUP BY  1,2,3,4;
		
    -- AGRUPADO	PARA EL CANAL COMISIONISTA. 

		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
				v_tip_cta_transac,
				209, -- COMISIONISTA
				'301', --CARGO
				--ELSE 'ERROR' END) tip_ope,
				SUM(monto_tot) monto,
				count(*) num_ope,
				count(distinct cuenta) num_cli
		FROM tmp_ope_cap 
		WHERE sucursal = '5005'
		  AND transacc = '0282'
		  AND naturaleza = 'C'
		GROUP BY  1,2,3,4;
		
		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
				v_tip_cta_transac,
				209, -- COMISIONISTA
				'302', -- ABONO				
				SUM(monto_tot) monto,
				count(*) num_ope,
				count(distinct cuenta) num_cli
		FROM tmp_ope_cap 
		WHERE sucursal = '5005'
		  AND transacc = '0282'
		  AND naturaleza = 'A'
		GROUP BY  1,2,3,4;
			
	-- AGRUPADO PARA EL CANAL ATM

		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
				v_tip_cta_transac,
				206, -- ATM
				'301', -- CARGO
				SUM(monto_tot) monto,
				count(*) num_ope,
				count(distinct cuenta) num_cli
		  FROM tmp_ope_cap 
		 WHERE sucursal = '9290'
		   AND transacc in ('0871','0873','0800')
		   AND naturaleza = 'C'
		 GROUP BY 1,2,3,4;
		
		INSERT INTO sp_r24D2441 
		SELECT 'R24d2441',
				v_tip_cta_transac,
				206, -- ATM
				'302',  --ABONO
				SUM(monto_tot) monto,
				count(*) num_ope,
				count(distinct cuenta) num_cli
		 FROM tmp_ope_cap 
		WHERE sucursal = '9290'
		  AND transacc in ('0871','0873','0800')
		  AND naturaleza = 'A'
		GROUP BY 1,2,3,4;		
		
		--FILTRA LAS CUENTAS PARA OBTENER EL RANGO DE USO POR CANAL Y TIPO DE OPERACION REALIZADA 
	
		
		INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   208, -- SUCURSAL
              '301', -- CARGO            
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal  IN (SELECT sucursal
							     FROM bdinteg:si_sucursales 
							    WHERE tpo_sucursal = 'S'
							      AND sucursal NOT IN ('5002','5003','5007'))
		   AND naturaleza = 'C' 						  
		GROUP BY 1,2,3,4,5;			
		
				INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   208, -- SUCURSAL
              '302', -- ABONO            
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal  IN (SELECT sucursal
							     FROM bdinteg:si_sucursales 
							    WHERE tpo_sucursal = 'S'
							      AND sucursal NOT IN ('5002','5003','5007'))
		   AND naturaleza = 'A' 						  
		GROUP BY 1,2,3,4,5;		
		
		INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   224, -- INTERNET
               '301', -- CARGO             
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal IN ('5002','5003','5007')
		  AND naturaleza = 'C'
		GROUP BY 1,2,3,4,5;		
		
				INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   224, -- INTERNET
               '302',  -- ABONO          
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal IN ('5002','5003','5007')
		  AND naturaleza = 'A'
		GROUP BY 1,2,3,4,5;	
		
		INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   209, -- COMISIONISTA
              '301', -- CARGO
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal = '5005'
		  AND tc.transacc = '0282'
		  AND naturaleza = 'C'
		GROUP BY 1,2,3,4,5;	
		
		
				INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   209, -- COMISIONISTA
              '302', -- ABONO
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal = '5005'
		  AND tc.transacc = '0282'
		  AND naturaleza = 'A'
		GROUP BY 1,2,3,4,5;	

		INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   206, -- ATM
               '301', --CARGO
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal = '9290'
		  AND tc.transacc IN ('0871','0873','0800')
		  AND naturaleza = 'C'
		GROUP BY 1,2,3,4,5;		
		
		INSERT INTO sp_r24D2442
		SELECT 'R24d2442',
			   v_tip_cta_transac,  -- TIPO CTA TRANSACCIONAL
			   206, -- ATM
               '302', -- ABONO
               (CASE WHEN num_ope = 1 THEN '461'
                     WHEN num_ope >= 2 AND num_ope <= 5  THEN '462'
                     WHEN num_ope >= 6 AND num_ope <= 10 THEN '463'
                     WHEN num_ope > 10 THEN '464'
               ELSE 'ERROR' END)  frecuencia,
               COUNT(distinct t_o.cuenta)
		 FROM tmp_ope_cap tc, tmp_ope t_o
		WHERE tc.cuenta = t_o.cuenta
		  AND tc.sucursal = '9290'
		  AND tc.transacc IN ('0871','0873','0800')
		  AND naturaleza = 'A'
		GROUP BY 1,2,3,4,5;	
			
	 RETURN "000","PROCESO SATISFACTORIO";	  
	 END
END PROCEDURE;