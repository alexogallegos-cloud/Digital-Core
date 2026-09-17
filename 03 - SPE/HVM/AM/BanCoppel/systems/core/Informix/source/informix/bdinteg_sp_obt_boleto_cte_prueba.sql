CREATE PROCEDURE "informix".sp_obt_boleto_cte_prueba(pPerido char(2), pDato char(16),pRegistros INTEGER)

        RETURNING char(5), char(60),char(16),char(40),char(20),char(1);
	
       DEFINE vcodret    char(5);
	   DEFINE sql_err Integer;
       DEFINE vNomEnmasc CHAR(60);
       DEFINE vCtaEnmasc CHAR(16);
	   DEFINE vNomPro    CHAR(40);
	   DEFINE vBoleto    CHAR(20);
	   DEFINE vNumCte    CHAR(9);
	   DEFINE vBoletoGan Char(1);
	   DEFINE fechaActual	DATE;
       DEFINE iDiaActual	int;
	   DEFINE iMesActual	int;
	   DEFINE iAnioActual   int;
	   DEFINE fechaServidor DATE;
	   

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan;
       END IF;
END EXCEPTION; 

	-- Actividad: Obtener boletos de un perido por cliente o nÃºmero de tarjeta
	-- Fecha:  22/02/2018

	--     Campo1- vCodRet            00000                    CHAR(5);   
	--     Campo2- vNomEnmasc         [A******** V******  ]    CHAR(60);
    --     Campo3- vCtaEnmasc         [**** ***1234]           CHAR(11);
    --     Campo4- vNomPro            [Cuenta Efectiva]        CHAR(40);
    --     Campo5- vBoleto            1 a 99999999999999999999 CHAR(20);
	--	   Campo6- vBoletoGan         0 Ã³ 1                    Char(1);
	         
	-- DefiniciÃ³n de variables

LET vcodret    = '00000';
LET vNomEnmasc = "";
LET vCtaEnmasc = "";
LET vNomPro    = "";
LET vBoleto    = "";
LET vBoletoGan = "";
LET vNumCte = "";


BEGIN

--SET DEBUG FILE TO "/home/informix/raldana/sp_obt_boleto_cte.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 5;

	LET iDiaActual = DAY(current);
	LET iMesActual = MONTH(current);
	LET iAnioActual = YEAR(current);
	
	LET fechaServidor = iMesActual || "/" || iDiaActual || "/" || iAnioActual;

	IF iDiaActual < 21 THEN
		if iMesActual == 1 THEN
			LET iMesActual = 12;
			LET iAnioActual = iAnioActual - 1;
		ELSE 
			LET iMesActual = iMesActual - 1;
		END IF;
		
	END IF;

	LET fechaActual = iMesActual || "/20/" || iAnioActual;
	IF (pPerido) = 01 THEN
	    LET pPerido = 12;
	ELIF (pPerido) = 02 THEN
	    LET pPerido = 01;
	ELIF (pPerido) = 03 THEN
	    LET pPerido = 02;	
	ELIF (pPerido) = 04 THEN
	    LET pPerido = 03;			
	ELIF (pPerido) = 05 THEN
	    LET pPerido = 04;					
	ELIF (pPerido) = 06 THEN
	    LET pPerido = 05;							
	ELIF (pPerido) = 07 THEN
	    LET pPerido = 06;									
	ELIF (pPerido) = 08 THEN
	    LET pPerido = 07;											
	ELIF (pPerido) = 09 THEN
	    LET pPerido = 08;													
	ELIF (pPerido) = 10 THEN
	    LET pPerido = 09;															
	ELIF (pPerido) = 11 THEN
	    LET pPerido = 10;																	
	ELIF (pPerido) = 12 THEN
	    LET pPerido = 11;																			
	END IF;
		
			IF LENGTH(trim(pDato)) =9 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo a
				 WHERE num_cliente = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
			END IF;
			 IF LENGTH(trim(pDato)) =11 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo a
				 WHERE  num_cuenta = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
			END IF;	 
			IF LENGTH(trim(pDato)) =16 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo a
				 WHERE  num_tarjeta = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
				 
			END IF;
			
			IF(vNumCte <> "")THEN
				SELECT  
				CASE WHEN (nombre2 = '' or nombre2 is null) THEN
							RPAD(SUBSTR( trim(nombre1), 1,1)      , LENGTH(trim(nombre1)), '*') || ' ' ||            
							RPAD(SUBSTR( trim(apell_paterno), 1,1), LENGTH(trim(apell_paterno)), '*') || ' ' ||  
							RPAD(SUBSTR( trim(apell_materno), 1,1), LENGTH(trim(apell_materno)), '*')          
						ELSE 
							RPAD(SUBSTR( trim(nombre1), 1,1)      , LENGTH(trim(nombre1)), '*') || ' ' ||  
							RPAD(SUBSTR( trim(nombre2), 1,1)      , LENGTH(trim(nombre2)), '*') || ' ' ||  
							RPAD(SUBSTR( trim(apell_paterno), 1,1), LENGTH(trim(apell_paterno)), '*') || ' ' ||  
							RPAD(SUBSTR( trim(apell_materno), 1,1), LENGTH(trim(apell_materno)), '*')
						END CASE  
				INTO vNomEnmasc
				FROM bdinteg:si_cliente 
				WHERE numcte = vNumCte;


				FOREACH			   
					SELECT SKIP pRegistros FIRST 10				        
						LPAD(SUBSTR( trim(a.num_tarjeta), 14,3), LENGTH(trim(a.num_tarjeta)), '*'),
						'PRODUCTO BANCOPPEL',				  
						To_Char(a.num_boleto, '&&&&&&&&&&&&&&&&&&&&'),		   
						NVL(generico2,0)
					INTO vCtaEnmasc,vNomPro,vBoleto,vBoletoGan				
					FROM bdinteg@stag_ids1170:si_sorteo_efectivo a
					WHERE a.num_cliente = vNumCte
					AND MONTH(a.fecha_carga) = pPerido

					RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan WITH RESUME;
				End FOREACH;
				
			ELSE 
				LET vcodret='00001';
			  RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan;		
			END IF;
END;

END PROCEDURE;