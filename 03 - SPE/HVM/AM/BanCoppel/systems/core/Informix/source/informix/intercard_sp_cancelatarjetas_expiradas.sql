CREATE PROCEDURE "informix".sp_cancelatarjetas_expiradas 
                  (
				  pcEmpresa  char(3),  
				  pTipoProceso   char(1),   
				  prangominexp   char(4),
				  prangomaxexp   char(4) 
				  )	

---ASIGNACION DE NOMBRE A LAS VARIABLRES DE RETORNO
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;						 
 
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	DEFINE	rpt_fecha			CHAR(8);
    DEFINE  sfecha_hoy			DATE; 
    DEFINE	TIPO_PLANTILLA 		VARCHAR(20);   
	DEFINE	RUTA_DESTINO 		VARCHAR(80);
	
	--Primer ciclo 
    DEFINE	vnumtarjeta1          VARCHAR(16);
    DEFINE  vbin1                     CHAR(6);
    DEFINE  vfechaexp1             VARCHAR(4);
    DEFINE  vnumcliente1	      VARCHAR(13);
    DEFINE  vcodproductotarjeta1   VARCHAR(3);
    DEFINE  vcodstatustarjeta1 	   VARCHAR(3);
    DEFINE  vproducto1                CHAR(1); 
    DEFINE  vtipoproc1             VARCHAR(7);
    DEFINE  vestatus_can1             CHAR(1);
    DEFINE  vnumerolote1              integer;
    DEFINE	vfecha_proc1              DATETIME YEAR to FRACTION(5);
	
	DEFINE	vnumtarjetad        VARCHAR(16);
	DEFINE	vnumtarjetac        VARCHAR(16);	
	DEFINE  vcodproductotarjeta VARCHAR(3);
	DEFINE  vfechexp            DATE;
	DEFINE  vfechexp2           VARCHAR(6);	
	DEFINE  vfechexp3           VARCHAR(4);	
    DEFINE  vproducto	        CHAR(1);
	DEFINE	vsql				CHAR(1150);
	DEFINE  vTipoProceso        VARCHAR(7); 
	DEFINE  vfecha_proc         DATETIME YEAR to FRACTION(5);
	DEFINE  vestatus_can        CHAR(1);
    DEFINE  vsubbin             CHAR(2);
	DEFINE  vprodtarjeta        VARCHAR(4);
	
	--Reporte
	DEFINE vclave_sucursal   VARCHAR(5);
    DEFINE vnombre_sucursal  VARCHAR(50);
    DEFINE vclave_estado     CHAR(2);
    DEFINE vnombre_estado    CHAR(30);
    DEFINE vcodprodcta       VARCHAR(50);
    DEFINE vdescodprodcta    VARCHAR(50);
 
	DEFINE  icommit			 INTEGER;
	
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);  
 
    DEFINE vConteo  INTEGER;
    DEFINE vsFlagEnTransaccion 	VARCHAR(1);
 
    LET RUTA_DESTINO     = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA	 = 'TarjetasCanExp'; 
	
    -- primer ciclo	
    LET  vnumtarjeta1          = '';
    LET  vbin1                 = '';
    LET  vfechaexp1            = '';
    LET  vnumcliente1	       = '';
    LET  vcodproductotarjeta1  = '';
    LET  vcodstatustarjeta1    = '';
    LET  vproducto1            = '';
    LET  vtipoproc1            = '';
    LET  vestatus_can1         = '';
    LET  vnumerolote1          = 0; 
    LET	 vfecha_proc1    	   = '';
	
	LET	vnumtarjetad = '';
	LET	vnumtarjetac = '';	
	LET vcodproductotarjeta = '';
	LET vfechexp   = '';
	LET vfechexp2   = '';
    LET vfechexp3   = '';	
	LET vproducto	= ''; 
	LET vTipoProceso = '';
	LET vfecha_proc  = ''; 
	LET vestatus_can = ''; 
	LET vsubbin      = '';
    LET vprodtarjeta = '';

	--Reporte
	LET vclave_sucursal   = '';
    LET vnombre_sucursal  = '';
    LET vclave_estado     = '';
    LET vnombre_estado    = '';
    LET vcodprodcta       = '';
	LET vdescodprodcta    = '';
 
	LET icommit 		  = 0;
	
    LET rpt_fecha       = '';
    LET codigo_retorno  = '00000';
    LET mensaje_retorno = 'PROCESO EXITOSO';
	
	LET vConteo  = 0;
    LET vsFlagEnTransaccion = 'F';
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_cancelatarjetas_expiradas.out";
    --TRACE ON;        

BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "sp_cancelatarjetas_expiradas.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;
		
        ON EXCEPTION IN (-284) SET SQLERR            
                INSERT INTO intercard:errores_tarjeta VALUES ( vnumtarjetad );            
        END EXCEPTION WITH RESUME;
		
	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;

		IF pTipoProceso = '1' then 
		         LET  vTipoProceso = 'Mensual'; 
		   ELSE  
		         LET  vTipoProceso = 'Masiva';
		END IF;
		
		SELECT fecha_hoy, (extend(fecha_hoy - 1 units MONTH)) 
		INTO  sfecha_hoy,vfechexp  FROM bdinteg:si_fechas WHERE empresa= pcEmpresa;  
		
        LET rpt_fecha  = LPAD(DAY(sfecha_hoy),2,'0')||LPAD(MONTH(sfecha_hoy),2, '0')||YEAR(sfecha_hoy);	        
	    LET vfechexp2  = YEAR(vfechexp)||LPAD(MONTH(vfechexp),2, '0');			
	    LET vfechexp3  = SUBSTR(vfechexp2,3,2)||SUBSTR(vfechexp2,5,2); 
		 ------------------------------
         /*
		    DROP TABLE IF EXISTS bines_tt;

			SELECT bin,creditodebito
			FROM intercard:bines
			INTO TEMP bines_tt;  			
	    */	
        ------------------------------
	IF pTipoProceso = '2' THEN  -- Masivo 
	
	    LET prangominexp = TRIM(prangominexp);	
		LET prangomaxexp = TRIM(prangomaxexp);	
		
		IF ((substring(prangominexp from 3 for 2) < 1 
		     OR substring(prangominexp from 3 for 2) > 12)) 
			 OR prangominexp = '' THEN 

		 LET         CODIGO_RETORNO = '00002'; 
		 LET         MENSAJE_RETORNO = 'FECHA EXP MIN INVALIDA'; 
	     RETURN 	 CODIGO_RETORNO, MENSAJE_RETORNO;
		 
		END IF; 
	
		IF ((substring(prangomaxexp from 3 for 2) < 1 
		     OR substring(prangomaxexp from 3 for 2) > 12)) 
			 OR prangomaxexp = '' THEN 

		        LET         CODIGO_RETORNO = '00003'; 
		        LET         MENSAJE_RETORNO = 'FECHA EXP MAX INVALIDA'; 
	     RETURN         	CODIGO_RETORNO, MENSAJE_RETORNO;
		 
		END IF; 
	 
	   FOREACH WITH HOLD
	
           Select 
           tjt.numtarjeta, 
           tjt.fechaexp,
           tjt.numcliente,
           tjt.codproductotarjeta,
           tjt.codstatustarjeta,
           b.creditodebito,
		   'MASIVO', 
		   'P',
		   numerolote,
		   current
		   INTO   vnumtarjeta1,
 				  vfechaexp1,    vnumcliente1, vcodproductotarjeta1, 
		          vcodstatustarjeta1,      vproducto1,      vtipoproc1, vestatus_can1, vnumerolote1, vfecha_proc1
           from tarjeta tjt 
           inner join intercard:bines b  on substr(tjt.numtarjeta,1,6) = b.bin
           where (tjt.fechaexp  between  prangominexp and prangomaxexp)
           and codstatustarjeta  in ('ACT','BLO','BLT') -- = 'ACT'  test 

		   LET vbin1  =  substr(vnumtarjeta1,1,6); 
		   LET vsubbin = substr(vnumtarjeta1,7,2); 
		   ---------------------------------------------
		   
		        IF NOT EXISTS ( SELECT numtarjeta FROM bitacora_can_fecha_exp
				                WHERE numtarjeta = vnumtarjeta1 ) THEN

	                         INSERT INTO "informix".bitacora_can_fecha_exp 
		                     (numtarjeta,  bin,   subbin,  fechaexp,  numcliente,  codproductotarjeta,  estatus_ant,        producto,   tipoproc,   estatus_can,   numerolote,   fecha_proc)
                             VALUES  (vnumtarjeta1,vbin1, vsubbin, vfechaexp1,vnumcliente1,vcodproductotarjeta1,vcodstatustarjeta1, vproducto1, vtipoproc1, vestatus_can1, vnumerolote1, vfecha_proc1);
 	 						 
                END IF;    						
		   -----------------------------------------------
		   LET vbin1   =  '';  
		   LET vsubbin =  ''; 
		   
		END FOREACH;  
	 
	ELIF pTipoProceso = '1' THEN  -- Mensual   
	
		FOREACH WITH HOLD
	
	
	       Select 
           tjt.numtarjeta, 
           tjt.fechaexp,
           tjt.numcliente,
           tjt.codproductotarjeta,
           tjt.codstatustarjeta,
           b.creditodebito,
		   'MENSUAL', 
		   'P',
		   numerolote,
		   current
		   INTO   vnumtarjeta1, 
				  vfechaexp1,    vnumcliente1, vcodproductotarjeta1, 
		          vcodstatustarjeta1,      vproducto1,      vtipoproc1, vestatus_can1, vnumerolote1, vfecha_proc1
           from tarjeta tjt 
           inner join intercard:bines b  on substr(tjt.numtarjeta,1,6) = b.bin
           where tjt.fechaexp = vfechexp3   
           --and codstatustarjeta = 'ACT' -- test 
		   -- and numtarjeta in ('4268070266463225')  -- test
		   and codstatustarjeta in ('ACT','BLO','BLT') 
 
           LET vbin1 =  substr(vnumtarjeta1,1,6); 
		   LET vsubbin = substr(vnumtarjeta1,7,2); 
 
 		   ---------------------------------------------
		   
		        IF NOT EXISTS ( SELECT numtarjeta FROM bitacora_can_fecha_exp
				                WHERE numtarjeta = vnumtarjeta1 ) THEN

	                 INSERT INTO "informix".bitacora_can_fecha_exp 
		                     (numtarjeta,  bin,   subbin,  fechaexp,  numcliente,  codproductotarjeta,  estatus_ant,        producto,   tipoproc,   estatus_can,   numerolote,   fecha_proc)
                     VALUES  (vnumtarjeta1,vbin1, vsubbin, vfechaexp1,vnumcliente1,vcodproductotarjeta1,vcodstatustarjeta1, vproducto1, vtipoproc1, vestatus_can1, vnumerolote1, vfecha_proc1);
  
                END IF;    						
		   ----------------------------------------------- 
            LET vbin1 =  '';  
		    LET vsubbin =  ''; 
  
        END FOREACH;   
 
	 ELSE 
	     
		 LET        CODIGO_RETORNO = '00001'; 
		 LET        MENSAJE_RETORNO = 'TIPO PROCESO INVALIDO'; 
	     RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;
		 
	END IF;  	
  
	 --paso 2: Inciar Ciclo de Cancelacion 
	   
	    IF  pTipoProceso  = 1  THEN 
		    LET  prangominexp  = vfechexp3; 
			LET  prangomaxexp  = vfechexp3; 
		END IF; 	
 
         ---valida la existencia de tarjetas con irregulares en la tabla tarjetacuenta para excluirlas del proceso
		 FOREACH cur_F0_ctas WITH HOLD FOR 
		 
           select distinct numtarjeta 
		    INTO vnumtarjetad
			from tarjetacuenta  where numtarjeta in 
		   ( select numtarjeta from bitacora_can_fecha_exp where fechaexp   
		            between  prangominexp and prangomaxexp AND estatus_can = 'P')
           group by numtarjeta having count(numtarjeta)>1

		         UPDATE bitacora_can_fecha_exp 
		         SET
				    estatus_can = 'E' , 
		            fecha_proc = current  
		         WHERE  numtarjeta = vnumtarjetad;  
		   
		   
		 END FOREACH;  
		 
		  
         ---valida la existencia de tarjetas con valores NULOS necesarios para el proceso de cancelacion y para excluirlas del proceso
		 FOREACH cur_F1_ctas WITH HOLD FOR 
		 
           select distinct numtarjeta 
		    INTO vnumtarjetad
			from tarjeta  where numtarjeta in 
		   ( select numtarjeta from bitacora_can_fecha_exp where fechaexp   
		            between  prangominexp and prangomaxexp AND estatus_can = 'P')
            and titular is null

		         UPDATE bitacora_can_fecha_exp 
		         SET
				    estatus_can = 'E' , 
		            fecha_proc = current  
		         WHERE  numtarjeta = vnumtarjetad;  
		   
		   
		 END FOREACH; 
-------------------------------------------------------------------------------------------------	 
	   FOREACH cur_F1_tarjetas WITH HOLD FOR 
  
		        Select distinct t1.numtarjeta, codproductotarjeta , producto, fecha_proc, estatus_can 
			       INTO vnumtarjetad,  vcodproductotarjeta, vproducto, vfecha_proc, vestatus_can
			     FROM bitacora_can_fecha_exp as t1 
			     where  estatus_can = 'P'  and (fechaexp  between  prangominexp and prangomaxexp)  --- ++ 
				 order by 1

			       IF (vsFlagEnTransaccion = 'F') THEN
                      BEGIN WORK;
                      LET vsFlagEnTransaccion = 'V';
                   END IF
				 
			IF  vproducto = 'D' THEN 

			        UPDATE bdicheq:sc_tarjeta 
			        SET status_tar = 'C' WHERE empresa = pcEmpresa AND num_tarjeta = vnumtarjetad;

			ELIF  vproducto = 'C' THEN 
			
			        UPDATE bdicred:sd_tarjeta 
			        SET status_tar = 'C' WHERE empresa = pcEmpresa AND num_tarjeta = vnumtarjetad; 
			END IF; 
   
			UPDATE intercard:"informix".tarjeta 
			SET  codstatustarjeta = 'CAN', usuarioultmodif = 'informix', fechaultmodif = current WHERE numtarjeta = vnumtarjetad;
 
 			INSERT INTO intercard:bitacoracancelaciontarjetas(tarjeta, codigoproductotarjeta,fecha, resultado, descripcion, usuario)
			VALUES(vnumtarjetad, vcodproductotarjeta ,current, '4', 'Cancelacion '||vTipoProceso||' de tarjetas por vencimiento','INFORMIX');
 
 	        UPDATE  bitacora_can_fecha_exp  SET estatus_can = 'T' ,  fecha_proc = current 
			WHERE  numtarjeta = vnumtarjetad AND fecha_proc = vfecha_proc AND  estatus_can = vestatus_can ; 
  
  
              IF (vConteo >= 1000) THEN
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';                
                CONTINUE FOREACH;
            END IF
            
	    END FOREACH;  

            IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
               COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
            END IF;

		  UPDATE STATISTICS MEDIUM FOR TABLE "informix".bitacora_can_fecha_exp;
 
 -----------------------------------------
--- BLOQUE DE REPORTERIA: 		
                             
  -- Obtiene el  productotarjeta 
  
 FOREACH WITH HOLD  -- debito 
 
          SELECT 
		  numtarjeta, 
		  sc.prodtarjeta, 
		  sc.prodtarjeta ||' '|| sp.nombre, 
		  fecha_proc
		  INTO  
		  vnumtarjetac, 
		  vprodtarjeta, 
		  vdescodprodcta,  
		  vfecha_proc
	      FROM bitacora_can_fecha_exp tt1 
		  INNER JOIN bdicheq:sc_tarjeta sc  ON tt1.numtarjeta = sc.num_tarjeta
          INNER JOIN bdicheq:sc_producto sp ON sc.prodtarjeta = sp.producto 		  
		  WHERE estatus_reporte = 'P'  and  estatus_can = 'T'
		  and fechaexp  between  prangominexp and prangomaxexp  -- ++  
 
          UPDATE bitacora_can_fecha_exp 
		         SET
				    codprodcta = vprodtarjeta , 
		         descodprodcta = vdescodprodcta,   
				    fecha_proc = current  
		  WHERE  numtarjeta = vnumtarjetac AND estatus_reporte = 'P' AND fecha_proc = vfecha_proc;  
	
   END FOREACH;   

 FOREACH WITH HOLD  -- Credito 
  
          SELECT 
		  numtarjeta,
		  mc.num_producto,
		  mc.num_producto ||' '|| sp.descrip_prod,     
		  fecha_proc 
		  INTO 
		  vnumtarjetac, 
		  vprodtarjeta, 
	   	  vdescodprodcta,
		  vfecha_proc
	      FROM bitacora_can_fecha_exp tt2 
		  INNER JOIN  bdicred:sd_tarjeta sd ON tt2.numtarjeta  = sd.num_tarjeta 
		  INNER JOIN  bdicred:sd_maecred mc ON sd.num_credito  = mc.num_credito 
		  INNER JOIN  bdicred:sd_tipprod sp ON mc.num_producto = sp.abrevia_prod 
		  WHERE estatus_reporte = 'P'  and  estatus_can = 'T'
		  AND sp.empresa = '001'
		  and fechaexp  between  prangominexp and prangomaxexp   --- ++ 
 
	          UPDATE bitacora_can_fecha_exp 
		         SET 
				    codprodcta = vprodtarjeta , 
		         descodprodcta = vdescodprodcta,      
				    fecha_proc = current  
		      WHERE  numtarjeta = vnumtarjetac AND estatus_reporte = 'P' AND fecha_proc = vfecha_proc; 

   END FOREACH;   	   
----------------------------------------- 
   -- Obtiene las sucursales y estados de la republica de las tarjetas 
   
    LET vnumtarjetac = ''; 
    LET vfecha_proc = ''; 
 
  FOREACH WITH HOLD 
 
   SELECT  tjt.numtarjeta,
           suc.clave_sucursal,
           suc.nombre_sucursal, 
		   se.estado as clave_estado,
           se.nombre as nombre_estado,
		   fecha_proc
           INTO   vnumtarjetac,vclave_sucursal,vnombre_sucursal, vclave_estado, vnombre_estado,vfecha_proc	   
		   from   bitacora_can_fecha_exp  tjt 
           inner join lote lot        on   tjt.numerolote = lot.numerolote	
           inner join sucursal suc    on   lot.clave_sucursal = suc.clave_sucursal	
           left join bdinteg:si_sucursales sc on suc.clave_sucursal = LPAD((sc.sucursal),5,'0')  
           left join bdinteg:si_estados se  on   sc.estado          =   se.estado	
           WHERE  estatus_reporte = 'P'  and  estatus_can = 'T'
		   AND suc.tipo_sucursal IN ('1','2')
		   AND (fechaexp  between  prangominexp and prangomaxexp)  ---- ++ 		   
 
        UPDATE bitacora_can_fecha_exp    SET clave_sucursal = vclave_sucursal, nombre_sucursal = vnombre_sucursal,
                                      		 clave_estado   = vclave_estado,   nombre_estado =  vnombre_estado
		WHERE  numtarjeta = vnumtarjetac AND estatus_reporte = 'P' AND fecha_proc = vfecha_proc; 
 
  END FOREACH;   
-----------------------------------------------------------------------------------------------------------------
    IF pTipoProceso = '1'  THEN  
-----------------------------------------------------------------------------------------------------------------
		--Elimina reportes anteriores
	     let vsql = '';
         let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
         system vsql;
----------------------------------------------------------------------------------------------------------------- 
	     let vsql = '';
	     let vsql = 'echo "cve_sucursal|nom_sucursal|cve_estado|nom_estado|producto|bin|sub-bin|estatus_ant|total|">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vfechexp3||'_'||rpt_fecha||'.txt';
	     system vsql;
-----------------------------------------------------------------------------------------------------------------
         let vsql = '';
         let vsql = ' echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_DESTINO ||'rpt_cancelacion_base_'||rpt_fecha||'.txt '||
                      ' SELECT  clave_sucursal,nombre_sucursal,clave_estado,nombre_estado, NVL(descodprodcta,''"'||'NA'||'"''),bin, subbin,estatus_ant, COUNT(*) '||
					  ' FROM   bitacora_can_fecha_exp  WHERE fechaexp = ''"'||vfechexp3||'"''  and  estatus_can = ''"'||'T'||'"'' and estatus_reporte = ''"'||'P'||'"''  '||
					  '  group by 1,2,3,4,5,6,7,8   order by 1,3,5,6,7,8  asc;">'||RUTA_DESTINO||'script_vencimiento.sql';  		 	  						
         system vsql;                                                                                                        
-----------------------------------------------------------------------------------------------------------------	
		---Asigancion de permisos del archivo .sql
		let vsql ='';			
		let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_vencimiento.sql';
		system vsql;
		
		let vsql = '';
        let vsql = 'dbaccess intercard '||RUTA_DESTINO||'script_vencimiento.sql';
        system vsql;	 
-----------------------------------------------------------------------------------------------------------------
		--Resultado del unload se complementa con el encabezado del reporte
		let vsql ='';
        let vsql = "sed 's/|s//g' "||RUTA_DESTINO||'rpt_cancelacion_base_'||rpt_fecha||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||vfechexp3||'_'||rpt_fecha||'.txt';
        system vsql; 
-----------------------------------------------------------------------------------------------------------------
		--eliminacion de archivos
		let vsql = '';
        let vsql ='rm -f '||RUTA_DESTINO||'script_vencimiento.sql';
        system vsql;
		
		let vsql = '';
		let vsql ='rm -f '||RUTA_DESTINO||'rpt_cancelacion_base_'||rpt_fecha||'.txt';
		system vsql;
-----------------------------------------------------------------------------------------------------------------

        UPDATE bitacora_can_fecha_exp SET estatus_reporte = 'T' WHERE  fechaexp  =  vfechexp3 AND  estatus_can = 'T';
		
	ELSE 	
-----------------------------------------------------------------------------------------------------------------
		--Elimina reportes anteriores
	     let vsql = '';
         let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
         system vsql;
----------------------------------------------------------------------------------------------------------------- 
	     let vsql = '';
	     let vsql = 'echo "cve_sucursal|nom_sucursal|cve_estado|nom_estado|producto|bin|sub-bin|estatus_ant|total|">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||prangominexp||'_'||prangomaxexp||'_'||rpt_fecha||'.txt'; 
	     system vsql;
-----------------------------------------------------------------------------------------------------------------
	     let vsql = '';
         let vsql = ' echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_DESTINO ||'rpt_cancelacion_base_'||rpt_fecha||'.txt '||
                      ' SELECT  clave_sucursal,nombre_sucursal,clave_estado,nombre_estado, NVL(descodprodcta,''"'||'NA'||'"''),bin, subbin ,estatus_ant, COUNT(*) '||
					  ' FROM   bitacora_can_fecha_exp  WHERE   fechaexp   BETWEEN ''"'||prangominexp||'"'' AND ''"'||prangomaxexp||'"''   '||    
					  ' and estatus_can = ''"'||'T'||'"'' and estatus_reporte = ''"'||'P'||'"''  group by 1,2,3,4,5,6,7,8   order by 1,3,5,6,7,8  asc;">'||RUTA_DESTINO||'script_vencimiento.sql';  		 	  						
         system vsql;
-----------------------------------------------------------------------------------------------------------------
		---Asigancion de permisos del archivo .sql
		let vsql ='';			
		let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_vencimiento.sql';
		system vsql;
		
		let vsql = '';
        let vsql = 'dbaccess intercard '||RUTA_DESTINO||'script_vencimiento.sql';
        system vsql;	
-----------------------------------------------------------------------------------------------------------------		
		--Resultado del unload se complementa con el encabezado del reporte
		let vsql ='';
        let vsql = "sed 's/|s//g' "||RUTA_DESTINO||'rpt_cancelacion_base_'||rpt_fecha||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||prangominexp||'_'||prangomaxexp||'_'||rpt_fecha||'.txt'; 
        system vsql; 
-----------------------------------------------------------------------------------------------------------------
		--eliminacion de archivos
		let vsql = '';
        let vsql ='rm -f '||RUTA_DESTINO||'script_vencimiento.sql';
        system vsql;
		
		let vsql = '';
		let vsql ='rm -f '||RUTA_DESTINO||'rpt_cancelacion_base_'||rpt_fecha||'.txt';
		system vsql;
-----------------------------------------------------------------------------------------------------------------
        UPDATE bitacora_can_fecha_exp SET estatus_reporte = 'T' WHERE (fechaexp between prangominexp and  prangomaxexp ) AND estatus_can = 'T';

    END IF; 
 ------------------------------------------------------------------------------------------------------------------------
 		--Eliminacion de la tablas temporales
		/*	Begin;
             DROP TABLE IF EXISTS bines_tt;
			Commit;
			*/
------------------------------------------------------------------------------------------------------------------------
 
    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;


END;
END PROCEDURE
---Coordinacion de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 8 de octubre del 2020
---Base de datos: intercard
---Este proceso corresponde al job 856
----EXECUTE PROCEDURE "informix".sp_cancelatarjetas_expiradas('001','1','','');
;

CREATE PROCEDURE "informix".sp_depura_movimientohistorico()
RETURNING CHAR(5),INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         CHAR(5);
    DEFINE error_info           CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vRegistros               INTEGER;
    DEFINE vId                              INTEGER;
    DEFINE vfecha_oper      DATE;
    DEFINE vsecuencia varchar(7) ;
    DEFINE vnumtarjeta varchar(16);
    DEFINE vfechalocaltransaccion varchar(4);
    DEFINE vhoralocaltransaccion varchar(6);

---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/informix/ireb/bdibpi/spl/sp_depura_si_bitsmstelsms_bpi.out"; --Se genera log en un archivo .out
        --TRACE ON;

                LET vcodret1        = '00000';
                LET sql_err             = 0;
                LET isam_err        = 0;
                LET vcontador1      = -1;
                LET vcontador2      = 0;
                LET vRegistros      = 0;
                LET vId                         = 0;
                LET vsecuencia      ='';
                LET vnumtarjeta     ='';
                LET vfechalocaltransaccion ='';
                LET vhoralocaltransaccion  ='';


        /*Incia SP*/
BEGIN

                ON EXCEPTION SET sql_err, isam_err
                        IF sql_err <> 0 THEN
                                LET vcodret1 = sql_err;
                                LET vcontador1 = isam_err;
                                RETURN vcodret1, vcontador1;
                        END IF;
                END EXCEPTION;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 4;


                        FOREACH WITH HOLD

                        SELECT secuencia,numtarjeta,fechalocaltransaccion,horalocaltransaccion INTO vsecuencia,vnumtarjeta,vfechalocaltransaccion,vhoralocaltransaccion
            FROM "informix".pivote19  where numero =0

                        IF vcontador1 = -1 THEN
                                LET vcontador1 = 0;
                                BEGIN WORK;
                        END IF;

                        DELETE FROM "informix".movimientohistorico
            WHERE secuencia= vsecuencia AND
                  numtarjeta = vnumtarjeta AND
                  fechalocaltransaccion = vfechalocaltransaccion AND
                  horalocaltransaccion = vhoralocaltransaccion AND
                  fechahorainauth between  '2020-01-01 00:00:00.00000' and '2020-06-30 23:59:59.99999';



            UPDATE "informix".pivote19 set numero =1 where secuencia= vsecuencia AND
                                                           numtarjeta = vnumtarjeta AND
                                                           fechalocaltransaccion = vfechalocaltransaccion AND
                                                           horalocaltransaccion = vhoralocaltransaccion;

                        LET vcontador1 = vcontador1 + 1;
                        LET vcontador2 = vcontador2 + 1;

                         IF vcontador2 >= 1000 THEN
                                LET vcontador2 = 0;
                                COMMIT WORK;
                                BEGIN WORK;
                         END IF;

                        COMMIT WORK;
                        BEGIN WORK;

                        END FOREACH;
                        IF vcontador1 > -1 THEN
                                COMMIT WORK;
                        END IF;

                RETURN vcodret1, vcontador1;
        END;
END PROCEDURE;