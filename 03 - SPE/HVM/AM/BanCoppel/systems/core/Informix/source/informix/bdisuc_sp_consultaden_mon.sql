CREATE PROCEDURE "informix".sp_consultaden_mon(
		pempresa          CHAR(3),
		psucursal         CHAR(4),
  		ptransaccion      CHAR(4),
        pTipo             CHAR(2),
        pFecha            CHAR(8),
        Pfolio            CHAR(16),
		pcant1  		  FLOAT(8),
		pcant2  		  FLOAT(8),
		pcant3  		  FLOAT(8),
		pcant4  		  FLOAT(8),
		pcant5  		  FLOAT(8),
		pcant6  		  FLOAT(8),
		pcant7  		  FLOAT(8),
        pmonto            FLOAT(8),
        psecuencia        CHAR(8)
           ) 


--RETURNING CHAR(500);

RETURNING CHAR(5),CHAR(8),CHAR(8),CHAR(8);

DEFINE vcodret			   CHAR(5);
DEFINE vsqlerr             INTEGER;
DEFINE visamerr            INTEGER;
DEFINE vhora  			   CHAR(5);
DEFINE vproveedor 		   CHAR(4);
DEFINE vfecha              DATE;
DEFINE vmensaje			   CHAR(8);
DEFINE pcant_1  		   FLOAT(8);
DEFINE pcant_2  		   FLOAT(8);
DEFINE pcant_3  		   FLOAT(8);
DEFINE pcant_4  		   FLOAT(8);
DEFINE pcant_5  		   FLOAT(8);
DEFINE pcant_6  		   FLOAT(8);
DEFINE pcant_7  		   FLOAT(8);
DEFINE psaldo_total        CHAR(20);
DEFINE cant1  		       FLOAT(8);
DEFINE cant2  		       FLOAT(8);
DEFINE cant3  		       FLOAT(8);
DEFINE cant4  	       	  FLOAT(8);
DEFINE cant5  		      FLOAT(8);
DEFINE cant6  		      FLOAT(8);
DEFINE cant7  		      FLOAT(8);
DEFINE cantdev1  		  FLOAT(8);
DEFINE cantdev2  		  FLOAT(8);
DEFINE cantdev3  		  FLOAT(8);
DEFINE cantdev4  	      FLOAT(8);
DEFINE cantdev5  		  FLOAT(8);
DEFINE cantdev6  		  FLOAT(8);
DEFINE cantdev7  		  FLOAT(8);
DEFINE CantFaltante       CHAR(8);
DEFINE CantNum            CHAR(8);


LET vcodret = "000";
LET vproveedor = "";
LET vhora = substr(current,12,5);
LET vmensaje ='CORRECTO';
LET psaldo_total = 0;

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
   END IF;
END EXCEPTION;

   SET ISOLATION DIRTY READ ;
   SET LOCK MODE TO WAIT 3;

---SET debug file to "/pisa/pisabanco/pisa_ftes/sucursal/sp_consultaden_mon.out";
--trace on;


 IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   ptransaccion = '0' or ptransaccion = ''  or pTipo = '0' or pTipo = '' or
   pmonto = 0 or pmonto = '' THEN
   LET vcodret = "110";
 ELSE
  LET CantFaltante = '';
  LET pFecha = pFecha;
    SELECT p.cod_proveedor
    INTO vproveedor
	FROM bdisuc:ss_proveedores p, bdinteg:si_sucursales s
    WHERE p.plaza = s.plaza_cajagen
    AND s.empresa = pempresa
	AND s.sucursal = psucursal;

	SELECT fecha_hoy 
		into vfecha
	FROM bdinteg:si_fechas;

  IF EXISTS (select cod_proveedor from  bdisuc:ss_proveedores where cod_proveedor = vproveedor) THEN
	    IF ptransaccion = '27' and pTipo = "1" THEN
              LET cant1 = 0;
              LET cant2 = 0;
              LET cant3 = 0;
              LET cant4 = 0;
              LET cant5 = 0;
              LET cant6 = 0;
              LET cant7 = 0;
              
             --Suma las cantidades de cajageneral
              SELECT sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7) INTO
              pcant_1,pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,pcant_7 
              FROM bdisuc:ss_cajageneral WHERE cod_proveedor = vproveedor; 


              IF pcant_1 is null  or pcant_1 < 0 THEN
                 LET pcant_1=0;
               END IF;

              IF pcant_2 is null or pcant_2 <  0 THEN
                 LET pcant_2=0;
               END IF;

               IF pcant_3 is null or  pcant_3 < 0 THEN
                 LET pcant_3=0;
               END IF;

                IF pcant_4  is null or pcant_4 < 0 THEN
                 LET pcant_4=0;
               END IF;
              
               IF pcant_5 is null or pcant_5  < 0 THEN
                 LET pcant_5=0;
               END IF;
               
               IF pcant_6 is null or  pcant_6  < 0 THEN
                 LET pcant_6=0;
               END IF;
               
              IF pcant_7 is null or  pcant_7 < 0 THEN
                 LET pcant_7=0;
              END IF;


			select sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7)INTO
			cant1,cant2,cant3,cant4,cant5,cant6,cant7 
			from bdisuc:ss_operaciones a  where a.folio_sucursal in (select b.folio_sucursal 
			from bdisuc:ss_mae_entradasalida b where b.cod_proveedor = vproveedor and b.fecha_solicitud = vfecha  and  b.status = '01') and a.cod_trans = '0001';

		   
		   ---Si valor es null iguala a 0
               IF cant1   is null THEN
                 LET cant1=0;
               END IF;

              IF cant2 is null THEN
                 LET cant2=0;
               END IF;

               IF cant3 is null THEN
                 LET cant3=0;
               END IF;

                IF cant4 is null THEN
                 LET cant4=0;
               END IF;
              
               IF cant5 is null THEN
                 LET cant5=0;
               END IF;
               
               IF cant6 is null THEN
                 LET cant6=0;
               END IF;
               
              IF cant7 is null THEN
                 LET cant7=0;
              END IF;

        
		
			select sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7)INTO
			cantdev1,cantdev2,cantdev3,cantdev4,cantdev5,cantdev6,cantdev7 
			from bdisuc:ss_operaciones a  where a.folio_sucursal in (select b.folio_sucursal 
			from bdisuc:ss_mae_entradasalida b where b.cod_proveedor = vproveedor and b.fecha_solicitud = vfecha and b.status = '07') and a.cod_trans = '0002';

              IF cantdev1   is null THEN
                 LET cantdev1=0;
               END IF;

              IF cantdev2 is null THEN
                 LET cantdev2=0;
               END IF;

               IF cantdev3 is null THEN
                 LET cantdev3=0;
               END IF;

                IF cantdev4 is null THEN
                 LET cantdev4=0;
               END IF;
              
               IF cantdev5 is null THEN
                 LET cantdev5=0;
               END IF;
               
               IF cantdev6 is null THEN
                 LET cantdev6=0;
               END IF;
               
              IF cantdev7 is null THEN
                 LET cantdev7=0;
              END IF;






             IF pcant7 <> 0 AND pcant7 >(pcant_7 - cant7 ) THEN
                LET CantNum = '';
                LET CantFaltante = "1";
                LET CantNum = pcant_7 - cant7;  
              END IF


             IF pcant6 <> 0 AND pcant6 >(pcant_6 - cant6 ) THEN
               LET CantNum = '';
               LET CantFaltante = "20";
               LET CantNum = pcant_6 - cant6;  
              END IF


              IF pcant5 <>0 AND pcant5 >(pcant_5 - cant5 ) THEN
                   LET CantNum = '';
                  LET CantFaltante = "50";
                  LET CantNum = pcant_5 - cant5;  
              END IF

              	

              IF pcant4 <> 0 AND  pcant4 >(pcant_4 - cant4 ) THEN
                LET CantNum = '';
                LET CantFaltante = "100";
                LET CantNum = pcant_4 - cant4;  
              END IF
              IF pcant3 <> 0 AND pcant3 > (pcant_3 - cant3) THEN
                LET  CantNum = '';
                LET CantFaltante = "200";
                LET CantNum = pcant_3 - cant3;               
              END IF
       
             IF pcant2 <>0 AND pcant2 >(pcant_2 - cant2 ) THEN
                LET CantNum = '';
                LET CantFaltante = "500";
                LET CantNum= pcant_2 - cant2;  
              END IF ;

              IF pcant1 <>0 AND pcant1 >(pcant_1 - cant1 ) THEN
                LET CantNum = '';
                LET CantFaltante = "1000";
                LET CantNum = pcant_1 - cant1;  
              END IF ;
            







             IF pcant1  <= 0 THEN
                 LET pcant1=0;
             END IF;

              IF pcant2  <=  0 THEN
                 LET pcant2=0;
               END IF;

               IF  pcant3  <= 0 THEN
                 LET pcant3=0;
               END IF;

                IF pcant4  < 0 THEN
                 LET pcant4=0;
               END IF;
              
               IF pcant5   <= 0 THEN
                 LET pcant5=0;
               END IF;
               
               IF   pcant6   <= 0 THEN
                 LET pcant6=0;
               END IF;
               
              IF  pcant7  <= 0 THEN
                 LET pcant7=0;
              END IF;


        END IF;


  
                    
      ELSE 
          LET vcodret = "105";
  END IF;

 END IF;

RETURN vcodret,vmensaje,CantFaltante,CantNum;
--RETURN vcodret;
END;
END PROCEDURE;