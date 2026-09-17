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