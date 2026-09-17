CREATE PROCEDURE "informix".bloqueoctas_corr2(pUsuario CHAR(8), pEmpresa char(3))
	RETURNING CHAR(5);

    DEFINE vcodret CHAR(5);
    DEFINE sql_err INTEGER;
    --DEFINE vcuenta CHAR(20);
    DEFINE vfecha DATE;
    DEFINE vhora CHAR(15);
    DEFINE vsql CHAR(100);
    DEFINE vfolio CHAR(20);
	
	DEFINE cCuenta CHAR(20);
	DEFINE cImporte CHAR(20);
	DEFINE mImporte MONEY(14,2);
	DEFINE cDescripcion CHAR(40);
	DEFINE cFecha CHAR(10);	
	DEFINE dFecha DATE;
	DEFINE iContador INTEGER;
	
	LET vcodret = "00000";
	LET cCuenta = '';
	LET cImporte = '';
	LET mImporte = 0.00;
	LET cDescripcion = '';
	LET cFecha = '';
	LET dFecha = '';
	LET iContador = 0;
	
	BEGIN
	
		ON EXCEPTION
		SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/bloqueoctas_corr2.out';
	    --TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT fecha_hoy
		INTO vfecha
		FROM sc_fechas
		WHERE empresa = pEmpresa;

		LET vhora = current hour to fraction;
		LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];

		/*{   
		   
		   CREATE TABLE "informix".cuentasbloq1(cuenta CHAR(20));

		   LET vsql = "";
		   LET vsql = 'echo "LOAD FROM cuentasabloquear.txt INSERT INTO cuentasbloq1" > ctas_bloq.sql';
		   SYSTEM vsql;

		   LET vsql = "";
		   LET vsql = "dbaccess bdicheq ctas_bloq.sql";
		   -- LET vsql = "/ifxsif01/bin/dbaccess bdicheq ctas_bloq.sql";
		   SYSTEM vsql;
		   LET vsql = "";

		}*/
		
		FOREACH
			
			SELECT cuenta,importe,descripcion,fecha
			INTO cCuenta,cImporte,cDescripcion,cFecha
			FROM bdicnweb:"informix".sw_mc_ctascanceladas_tmp
			WHERE usuario = pUsuario
			ORDER BY id_registro ASC

			INSERT INTO sc_ctabloqueo VALUES(cCuenta, "09", 3, " ", " ", " ", " ");

			INSERT INTO sc_histbloq VALUES(pEmpresa, cCuenta, "B", "09", 3,	0.00, "informix", vfecha, current hour to fraction, "1111", "B", vfolio, " ", " ", " ", " ", " ");
			
			LET mImporte = REPLACE((REPLACE(TRIM(cImporte),'$','')),',','');
			LET dFecha = TO_DATE(cFecha,'%d/%m/%Y');
			
			-- SE AGREGA INSERT A TABLA "informix".cuentas
			INSERT INTO "informix".cuentas(cuenta,importe,descripcion,fecha)
			VALUES(cCuenta,mImporte,cDescripcion,dFecha);
			
			-- 
			INSERT INTO bdicnweb:"informix".sw_mc_detallectascanceladas(usuario_insert,fecha_insert,cuenta,importe,descripcion,fecha)
			VALUES(pUsuario,DATE(CURRENT),cCuenta,mImporte,cDescripcion,dFecha);
			
			UPDATE sc_maechq
			SET status_cta = "3",
			motivo = "09"
			WHERE empresa = pEmpresa
			AND cuenta = cCuenta;
			
			LET iContador = iContador + 1;
			
		END FOREACH
		
		IF NVL(iContador,0) = 0 THEN
			LET vcodret = '00001'; --NO HAY CUENTAS POR CARGAR
		END IF;
		
	END;

	/*DROP TABLE "informix".cuentasbloq1;*/
	
	RETURN vcodret;

END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 02/07/2018', 
'DESCRIPCION: Se realiza clonación de SPL bloqueoctas_corr',
'para aplicar consideraciones: RQI 11 2070 Mantenimiento a cuentas de recuperación especial.',
'BD: bdicheq';

CREATE PROCEDURE "informix".desbloq_cuentas_corresp2(pCuenta CHAR(20), pEmpresa CHAR(3))
	RETURNING CHAR(5);
	
	DEFINE vcodret CHAR(5);
	DEFINE sql_err INTEGER;
	--DEFINE vcuenta CHAR(20);
	DEFINE vstatus CHAR(1);
	DEFINE vmotivo CHAR(2);
	DEFINE vfecha DATE;
	DEFINE vhora CHAR(15);
	DEFINE vfolio CHAR(20);
	DEFINE vsql CHAR(500);
	DEFINE cRegistro LVARCHAR;
	DEFINE cCuenta CHAR(20);
	DEFINE iContador INTEGER;
	
	LET vcodret = "00000";
	LET cRegistro = '';
	LET cCuenta = '';
	LET iContador = 0;
	
	BEGIN
	
		ON EXCEPTION
			SET sql_err
			IF sql_err <> 0 THEN
				LET vcodret = sql_err;
				RETURN vcodret;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/desbloq_cuentas_corresp2.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT fecha_hoy
		INTO vfecha
		FROM sc_fechas
		WHERE empresa = pEmpresa;
		
		LET vhora = current hour to fraction;
		LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
		
		/*CREATE TABLE "informix".desbloqcuentas(cuenta CHAR(20));
		
		LET vsql = "";
		LET vsql = 'echo "LOAD FROM cuentasadesbloquear.txt INSERT INTO desbloqcuentas" > ctas_desbloq.sql';
		SYSTEM vsql;
		
		LET vsql = "";
		LET vsql = "dbaccess bdicheq ctas_desbloq.sql";
		-- LET vsql = "/ifxsif01/bin/dbaccess bdicheq ctas_bloq.sql";
		SYSTEM vsql;
		LET vsql = "";*/
		
		FOREACH
		
			/*SELECT cuenta
			INTO cCuenta
			FROM desbloqcuentas
			WHERE cuenta IS NOT NULL*/
						
			--SELECT cuenta
			--INTO cCuenta
			--FROM "informix".sw_mc_detallectasrecuperacionesp
			--WHERE usuario_insert = pUsuario
			--AND cuenta = pCuenta
			
			SELECT status_cta, motivo
			INTO vstatus, vmotivo
			FROM sc_maechq
			WHERE empresa = pEmpresa
			AND cuenta = pCuenta
			
			IF vstatus = "3" AND vmotivo = "09" THEN
			
				UPDATE sc_maechq
				SET status_cta = "1",
				motivo = "00"
				WHERE empresa = pEmpresa
				AND cuenta = pCuenta;
				
				INSERT INTO sc_histbloq VALUES(pEmpresa, pCuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", " ", " ", " ", " ");
				
				DELETE FROM sc_ctabloqueo WHERE cuenta = pCuenta;
			 
			END IF;
		
			DELETE FROM "informix".cuentas WHERE cuenta = pCuenta;
			
			LET iContador = iContador + 1;
			
		END FOREACH
		
		IF NVL(iContador,0) = 0 THEN
			LET vcodret = '00001'; --NO HAY CUENTAS POR DESBLOQUEAR
		END IF;
		
	END;
	
	/*DROP TABLE "informix".desbloqcuentas;*/
	
	RETURN vcodret;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 06/07/2018', 
'DESCRIPCION: Se realiza clonación de SPL desbloq_cuentas_corresp',
'para aplicar consideraciones: RQI 11 2070 Mantenimiento a cuentas de recuperación especial.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_reporte_men_caritas()
    RETURNING    CHAR(5);
	--//DEFINICION DE VARIABLES LOCALES    
    DEFINE vsqlerr        INTEGER;
    DEFINE vpdia          DATE ;
    DEFINE vpultimo_dia   DATE ;
	DEFINE vnumdias       INT;
	DEFINE vfecha_hoy     DATE;
	DEFINE vfecha2	      CHAR(6);
                 
    DEFINE vsql           CHAR(500);
    DEFINE vcodret        VARCHAR(5);
	DEFINE vcodret_1      VARCHAR(5);
	DEFINE valida_1       INT;
    DEFINE valida_2       INT;
	
	
	
	
	--SET DEBUG FILE TO "/informix/Raull/reporte_men_caritas.unl";
    -- TRACE ON;
	   
    LET vcodret     = "00000";
	LET vfecha_hoy  = '';
	LET vfecha2     = '';
	LET valida_1  = 0;
	LET valida_2  = 0;
	
	
   		
    BEGIN
	ON EXCEPTION SET vsqlerr
	   SET DEBUG FILE TO "/resplogifx/conciliachq/caritas.err";
		   TRACE ON;
           IF vsqlerr <> 0 THEN
              LET vcodret = vsqlerr;
           RETURN vcodret;
           END IF;
    END EXCEPTION;
	   	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SE OBTIENE EL PRIMER DIA DEL MES ANTERIOR
	SELECT DATE(pri_dia_mes - 1 UNITS MONTH),  
	       DATE(pri_dia_mes - 1 UNITS MONTH),
		   fecha_hoy
	  INTO vpdia, vpultimo_dia,vfecha_hoy
      FROM sc_fechas;
 
    --SE OBTIENE EL ULTIMO DIA DEL MES ANTERIOR  
	CALL calcula_fechapago(vpultimo_dia,0,31)
	     RETURNING vcodret_1, 
		           vpultimo_dia, 
				   vnumdias;
				   
	--SE VALIDA QUE NO EXISTA LA TABLA DE LO CONTRARIO LA BORRA			   
    
	SELECT COUNT(*) 
	  INTO valida_1
	  FROM "informix".tmp_mov_caritas;
	  
	    IF valida_1 IS NULL OR valida_1 = ''
		   THEN LET valida_1 = 0; 
	   END IF 
	   
	    IF valida_1 > 0 THEN 
		   DROP TABLE "informix".tmp_mov_caritas;
		   
		   	--TABLA  PARA MANIPULAR LA INFORMACION 			   
	      CREATE  RAW TABLE  "informix".tmp_mov_caritas
                   (
					cuenta     CHAR(20),
					sucursal   CHAR(4),
					monto_tot  MONEY
					)
           EXTENT SIZE 7536 NEXT SIZE 752 LOCK MODE ROW;
		   		   
	   END IF; 
	   
	
	--SE VALIDA QUE NO EXISTA LA TABLA DE LO CONTRARIO LA BORRA	
   
    SELECT COUNT(*)
	  INTO valida_2
	  FROM "informix".tmp_mov_caritas_totales;
 	  
      IF valida_2 IS NULL OR valida_2 = ''
		 THEN LET valida_2 = 0; 
	 END IF 	  

	  
	  IF valida_2 > 0 THEN 
	     DROP TABLE "informix".tmp_mov_caritas_totales;
		 		
         --TABLA  PARA MANIPULAR LA INFORMACION		
	      CREATE  RAW TABLE  "informix".tmp_mov_caritas_totales
                   (
					sucursal CHAR(4),
					monto    MONEY
					)
           EXTENT SIZE 7536 NEXT SIZE 752 LOCK MODE ROW;
		 
	  END IF; 


    
	INSERT INTO tmp_mov_caritas
         SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                cuenta,
                sucursal,
                monto_tot
           FROM sc_movhis
		  WHERE cancelad <> "S"
		    AND transacc = "0202"
			AND sucursal IN ('0002','0003','0004','0005','0007','0008','0009','0011',
                            '0013','0014','0015','0017','0019','0030','0081','0106',
                            '0183','0185','0204','0230','0237','0238','0239','0342',
                            '0374','0390','0391','0392','0393','0415','0421','0422',
                            '0423','0469','0490','0554','0632','0633','0678','0697',
                            '0772','0783','0803','0820','0844','0932','0948','0966',
                            '1002','1018','1123','1207','1252','1310','1312','1328',
                            '1329','1344','1358','1372','1391','1481','1495','6510',
                            '6525','6542','6581')
			AND cuenta = "22000001060"
			AND fech_alt >= vpdia
			AND fech_alt <= vpultimo_dia;
				
	INSERT INTO tmp_mov_caritas
         SELECT {+INDEX(sc_movhis idx_movhisnew6)}
                cuenta,
                sucursal,
                monto_tot
           FROM sc_movhis_old
		  WHERE cancelad <> "S"
		    AND transacc = "0202"
			AND sucursal IN ('0002','0003','0004','0005','0007','0008','0009','0011',
                             '0013','0014','0015','0017','0019','0030','0081','0106',
                             '0183','0185','0204','0230','0237','0238','0239','0342',
                             '0374','0390','0391','0392','0393','0415','0421','0422',
                             '0423','0469','0490','0554','0632','0633','0678','0697',
                             '0772','0783','0803','0820','0844','0932','0948','0966',
                             '1002','1018','1123','1207','1252','1310','1312','1328',
                             '1329','1344','1358','1372','1391','1481','1495','6510',
                             '6525','6542','6581')					
			AND	cuenta    = "22000001060"
			AND fech_alt >= vpdia
			AND fech_alt <= vpultimo_dia;

	--/TABLA FINAL PARA DESCARGA DE INFORMACION 		
    INSERT INTO tmp_mov_caritas_totales
		 SELECT sucursal, 
		        SUM(monto_tot) monto
           FROM tmp_mov_caritas 
       GROUP BY sucursal;
	   
	              
	LET vfecha2 = TO_CHAR(vpdia, '%m%Y');
	
	--GENERA EL ARCHIVO QUE REALIZARA LA CONSULTA PARA LA SALIDA DE INFORMACION 
    LET vsql = '';
    LET vsql = 'echo "SET ISOLATION TO DIRTY READ; '||
			   'UNLOAD TO /resplogifx/conciliachq/572_REPORTE_MEN_CARITAS_PRO_'||vfecha2||'.txt '||
		       'SELECT a.sucursal,b.nombre,a.monto '||
			   'FROM tmp_mov_caritas_totales a, bdinteg:si_sucursales b '||
               'WHERE a.sucursal = b.sucursal" > /resplogifx/conciliachq/572_REPORTE_MEN_CARITAS_PRO.sql';
	SYSTEM vsql; 

	--/EJECUCION DEL ARCHIVO .SQL 
    LET vsql = '';
    LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/572_REPORTE_MEN_CARITAS_PRO.sql"; 
    SYSTEM vsql;	
		
	RETURN vcodret;
    END;    
END PROCEDURE;