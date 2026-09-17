CREATE PROCEDURE "informix".sp_obt_boleto_cte(pPerido char(2), pDato char(16),pRegistros INTEGER)

        RETURNING char(5), char(60),char(16),char(40),char(20),char(1);
	
       DEFINE vcodret    char(5);
	   DEFINE sql_err Integer;
       DEFINE vNomEnmasc CHAR(60);
       DEFINE vCtaEnmasc CHAR(16);
	   DEFINE vNomPro    CHAR(40);
	   DEFINE vBoleto    CHAR(20);
	   DEFINE vNumCte    CHAR(9);
	   DEFINE vBoletoGan Char(1); 
	   DEFINE n1Cliente    CHAR(26);
	   DEFINE n2Cliente    CHAR(26);
	   DEFINE apCliente    CHAR(26);
	   DEFINE amCliente    CHAR(26);
	   

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNomEnmasc, vCtaEnmasc, vNomPro, vBoleto, vBoletoGan;
       END IF;
END EXCEPTION; 

	-- Actividad: Obtener boletos de un perido por cliente o nÃÂºmero de tarjeta
	-- Fecha:  22/02/2018

	--     Campo1- vCodRet            00000                    CHAR(5);   
	--     Campo2- vNomEnmasc         [A******** V******  ]    CHAR(60);
    --     Campo3- vCtaEnmasc         [**** ***1234]           CHAR(11);
    --     Campo4- vNomPro            [Cuenta Efectiva]        CHAR(40);
    --     Campo5- vBoleto            1 a 99999999999999999999 CHAR(20);
	--	   Campo6- vBoletoGan         0 ÃÂ³ 1                    Char(1);
	         
	-- DefiniciÃÂ³n de variables

LET vcodret    = '00000';
LET vNomEnmasc = "";
LET vCtaEnmasc = "";
LET vNomPro    = "";
LET vBoleto    = "";
LET vBoletoGan = "";
LET vNumCte = "";
LET n1Cliente = "";
LET n2Cliente = "";
LET apCliente = "";
LET amCliente = "";

BEGIN

--SET DEBUG FILE TO "/home/informix/raldana/sp_obt_boleto_cte.out";
--TRACE ON;

set isolation to dirty read;
set lock mode to wait 5;
 
	
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
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a				 
				 WHERE num_cliente = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
			END IF;
			 IF LENGTH(trim(pDato)) =11 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a				 
				 WHERE  num_cuenta = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
			END IF;	 
			IF LENGTH(trim(pDato)) =16 THEN	
				SELECT LIMIT 1 num_cliente INTO vNumCte
				 FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a				 
				 WHERE  num_tarjeta = trim(pDato) 
				 AND month(fecha_carga) = pPerido;
				 
			END IF;
			
			IF(vNumCte <> "")THEN
				SELECT  nombre1,nombre2,apell_paterno,apell_materno
				INTO n1Cliente, n2Cliente, apCliente, amCliente
				FROM bdinteg:si_cliente 
				WHERE numcte = vNumCte;

				IF(n1Cliente <> "") THEN
					 LET n1Cliente = RPAD(SUBSTR( trim(n1Cliente), 1,1)      , LENGTH(trim(n1Cliente)), '*') ;
				
				END IF;	
				
				IF(n2Cliente <> "") THEN
					LET n2Cliente = RPAD(SUBSTR( trim(n2Cliente), 1,1)      , LENGTH(trim(n2Cliente)), '*') ;
				ELSE 
					LET n2Cliente 	= "";
				END IF;				
				
				IF(apCliente <> "") THEN
					LET apCliente = RPAD(SUBSTR( trim(apCliente), 1,1)      , LENGTH(trim(apCliente)), '*') ;
					
				END IF;				
				
				IF(amCliente <> "") THEN
					LET amCliente = RPAD(SUBSTR( trim(amCliente), 1,1)      , LENGTH(trim(amCliente)), '*') ;
				ELSE
					LET amCliente ="";
				END IF;				
				
				LET vNomEnmasc = TRIM(n1Cliente) || ' '|| TRIM(n2Cliente)|| ' '||TRIM(apCliente)|| ' '|| TRIM(amCliente);
					 
				FOREACH			   
					SELECT SKIP pRegistros FIRST 10				        
						LPAD(SUBSTR( trim(a.num_tarjeta), 14,3), LENGTH(trim(a.num_tarjeta)), '*'),
						--'PRODUCTO BANCOPPEL',				  
						LPAD(SUBSTR( trim(a.num_cuenta), 8,4), LENGTH(trim(a.num_cuenta)), '*'),
						To_Char(a.num_boleto, '&&&&&&&&&&&&&&&&&&&&'),		   
						NVL(generico2,0)
					INTO vCtaEnmasc,vNomPro,vBoleto,vBoletoGan				
					FROM bdinteg@stag_ids1170:si_sorteo_efectivo_his a					
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