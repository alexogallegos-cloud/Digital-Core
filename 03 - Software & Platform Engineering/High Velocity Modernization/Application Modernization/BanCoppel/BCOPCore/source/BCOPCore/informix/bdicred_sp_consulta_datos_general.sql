CREATE PROCEDURE "informix".sp_consulta_datos_general(pEmpresa      CHAR(3), 
                                                      pNumCte       CHAR(20),
                                                      pNumCredito   CHAR(20),
                                                      pNumTarjeta   CHAR(20),
                                                      pApellidosPat CHAR(26),
                                                      pApellidosMat CHAR(26),
													  pNumProd      CHAR(4))
RETURNING CHAR(6)   AS codigo_retorno,
          CHAR(80)  AS mensaje_retorno,
          CHAR(20)  AS numero_credito,
          CHAR(20)  AS numero_cliente,
          CHAR(40)  AS nombre_producto,
          CHAR(20)  AS numero_tarjeta,
          CHAR(150) AS nombre_cliente;

DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   CHAR(80);

DEFINE cNumCredito   CHAR(20);
DEFINE cNumCte       CHAR(20);
DEFINE cNomProducto  CHAR(40);
DEFINE cNumTarjeta   CHAR(20);
DEFINE cNomCte       CHAR(150);
DEFINE cCodprod        CHAR(2);

LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '';
LET cMensajeRet   = '';

LET cNumCredito   = '';
LET cNumCte       = '';
LET cNomProducto  = '';
LET cNumTarjeta   = '';
LET cNomCte       = '';
LET cCodprod      = '';

BEGIN 

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_consulta_datos_general';
--TRACE ON;

--Fecha: 25/06/2009
-- Modificacion: Se separo el query principal 
-- Autor: Roque Solis C.

-- Fecha. 05/10/2009
-- Modificacion: Se duplicaron querys para consultar los datos para prestamos personales
-- Autor: Roque Solis C.

LET cCodRet= '000000';
LET cMensajeRet= 'Se realizó la consulta correctamente.';

IF pNumProd = '' THEN
   LET pNumProd = NULL;
END IF;

IF NVL(pNumCte,'') = '' THEN
  LET pNumCte = NULL; 
END IF;

IF NVL(pNumCredito,'') = '' THEN
  LET pNumCredito = NULL;
END IF;

IF NVL(pNumTarjeta,'') = '' THEN
  LET pNumTarjeta = NULL;
ELSE 
    SELECT num_credito
      INTO pNumCredito
      FROM "informix".sd_tarjeta
     WHERE empresa     = pEmpresa
       AND num_tarjeta = pNumTarjeta;
END IF;

IF NVL(pApellidosPat,'') = '' THEN
  LET pApellidosPat = NULL;
END IF;

IF NVL(pApellidosMat,'') = '' THEN
  LET pApellidosMat = NULL;
END IF;

IF pNumCte IS NULL AND pNumCredito IS NULL AND pNumTarjeta IS NULL AND pApellidosPat IS NULL AND pApellidosMat IS NULL THEN
   LET cCodRet= '000001';
   LET cMensajeRet= 'No hay información para realizar la consulta';
   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
END IF;

SET ISOLATION TO dirty READ;

    IF pNumCredito IS NOT NULL THEN
    
	   -- consulta por numero de credito para creditos normales
      -- FOREACH


                SELECT num_credito,b.cod_prod
                  INTO cNumCredito,cCodprod
                  FROM bdicred:sd_maecred a,
                       bdicred:sd_tipprod b
                 WHERE a.num_credito = pNumCredito
                   AND a.empresa=pEmpresa
                   AND a.empresa=b.empresa 
                   AND a.num_producto=b.abrevia_prod;

                    IF cNumCredito IS NULL OR cCodprod IS NULL THEN
                        SELECT num_credito,b.cod_prod
                          INTO cNumCredito,cCodprod
                          FROM bdicred:sd_maecredcrd a,
                               bdicred:sd_tipprod b
                         WHERE a.num_credito = pNumCredito
                           AND a.empresa=pEmpresa
                           AND a.empresa=b.empresa 
                           AND a.num_producto=b.abrevia_prod;
                        IF cNumCredito IS NULL OR cCodprod IS NULL THEN
                           LET cCodRet     = '000001';
                           LET cMensajeRet = 'EL PRODUCTO NO EXISTE FAVOR DE CONFIRMAR';
                           RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
                        END IF;
                    END IF;

       IF cCodprod ='T' THEN
	   
		 IF SUBSTR(cNumCredito,1,2) = "78" THEN 
			SELECT a.num_credito,
					   a.numcte,
					   '',
					   c.nombre_prod,
					   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
				  INTO cNumCredito,
					   cNumCte,
					   cNumTarjeta,
					   cNomProducto, 
					   cNomCte
				  FROM "informix".sd_maecred a,
					   bdinteg:"informix".si_cliente b, 
					   "informix".sd_definicion c
					 
				 WHERE c.num_producto = a.num_producto
				   AND c.empresa = a.empresa
				   AND b.empresa = a.empresa
				   AND c.num_producto = a.num_producto
				   AND b.numcte = a.numcte
				   AND b.apell_paterno=  b.apell_paterno 
				   AND b.apell_materno=  b.apell_materno 				   
				   AND a.empresa = pEmpresa
				   AND a.num_credito= pNumCredito;  
				   
				   IF cNumCredito IS NOT NULL THEN
					   LET nrows=nrows+1;
					   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
				   END IF;
		   --END FOREACH;
			ELSE
			   SELECT a.num_credito,
					   a.numcte,
					   d.num_tarjeta,
					   c.nombre_prod,
					   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
				  INTO cNumCredito,
					   cNumCte,
					   cNumTarjeta,
					   cNomProducto, 
					   cNomCte
				  FROM "informix".sd_maecred a,
					   bdinteg:"informix".si_cliente b, 
					   "informix".sd_definicion c, 
					   "informix".sd_tarjeta d
				 WHERE c.num_producto = a.num_producto
				   AND c.empresa = a.empresa
				   AND b.empresa = a.empresa
				   AND d.empresa = a.empresa
				   AND c.num_producto = a.num_producto
				   AND b.numcte = a.numcte
				   AND b.apell_paterno=  b.apell_paterno 
				   AND b.apell_materno=  b.apell_materno 
				   AND d.num_credito = a.num_credito
				   AND d.tipo_tarjeta = 'T'
				   and d.secuencia = (SELECT MAX(secuencia) 
										FROM bdicred:sd_tarjeta 
									   WHERE a.empresa = empresa 
										 AND a.num_credito = num_credito 
										 AND tipo_tarjeta = 'T')
				   AND a.empresa = pEmpresa
				   AND a.num_credito= pNumCredito;  
				   
				   IF cNumCredito IS NOT NULL THEN
					   LET nrows=nrows+1;
					   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
				   END IF;
		   --END FOREACH;
		   END IF;
       END IF;

       IF cCodprod IN ('P','R') THEN
	          --consulta de por numero de credito para prestamos personales
		      --FOREACH
	           SELECT a.num_credito,
	                   a.numcte,
	                   c.nombre_prod,
	                   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	              INTO cNumCredito,
	                   cNumCte,
	                   cNomProducto, 
	                   cNomCte
	              FROM "informix".sd_maecredcrd a,
	                   bdinteg:"informix".si_cliente b, 
	                   "informix".sd_definicion c
	             WHERE c.num_producto = a.num_producto
	               AND c.empresa = a.empresa
	               AND b.empresa = a.empresa
	               AND c.num_producto = a.num_producto
           --        and c.num_producto in ('6300'
	               AND b.numcte = a.numcte
	               AND b.apell_paterno=  b.apell_paterno 
	               AND b.apell_materno=  b.apell_materno 
	               AND a.empresa = pEmpresa
	               AND a.num_credito = pNumCredito  
				   AND a.num_producto = (CASE WHEN pNumProd IS NULL THEN a.num_producto ELSE pNumProd END);
	               
	               IF cNumCredito IS NOT NULL THEN
	    	           LET nrows=nrows+1;
	                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
	               END IF;
	          --END FOREACH; 
       END IF;
	   
    ELIF pNumCte IS NOT NULL THEN
         --consulta por numero de cliente para creditos normales
         FOREACH
              SELECT num_credito
                INTO pNumCredito
                FROM "informix".sd_maecred
               WHERE numcte = pNumCte
                 AND empresa = pEmpresa 
                 AND num_producto = (CASE WHEN pNumProd IS NULL THEN num_producto ELSE pNumProd END)		 				 
              
	              --FOREACH
	              
	                 SELECT a.num_credito,
	                       a.numcte,
	                       d.num_tarjeta,
	                       c.nombre_prod,
	                       TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	                  INTO cNumCredito,
	                       cNumCte,
	                       cNumTarjeta,
	                       cNomProducto, 
	                       cNomCte
	                  FROM "informix".sd_maecred a,
	                       bdinteg:"informix".si_cliente b, 
	                       "informix".sd_definicion c, 
	                       "informix".sd_tarjeta d
	                 WHERE c.num_producto = a.num_producto
	                   AND c.empresa = a.empresa
	                   AND b.empresa = a.empresa
	                   AND d.empresa = a.empresa
	                   AND b.numcte = a.numcte
	                   AND b.apell_paterno=  b.apell_paterno 
	                   AND b.apell_materno=  b.apell_materno 
	                   AND d.num_credito = a.num_credito
	                   AND d.tipo_tarjeta = 'T'
	                   AND d.secuencia = (SELECT MAX(secuencia) 
					                        FROM bdicred:sd_tarjeta 
										   WHERE a.empresa = empresa 
										     AND a.num_credito = num_credito 
											 AND tipo_tarjeta = 'T')
	                   AND d.empresa = a.empresa
	                   AND a.empresa = pEmpresa
	                   AND a.num_credito = pNumCredito;
                        					   
	                   
	                   IF cNumCredito IS NOT NULL THEN
	        	           LET nrows=nrows+1;
	                       RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
	                   END IF;
	                      
	                  --END FOREACH;                  
	              
	        END FOREACH;
			
			LET cNumTarjeta='';
			    --consulta por numero de credito para prestamos personales
			    FOREACH
	              SELECT num_credito
	                INTO pNumCredito
	                FROM "informix".sd_maecredcrd
	               WHERE numcte=pNumCte
	                 AND empresa=pEmpresa
                     AND num_producto = (CASE WHEN pNumProd IS NULL THEN num_producto ELSE pNumProd END)		 
	              
	              --FOREACH
	              
	                 SELECT a.num_credito,
	                       a.numcte,
	                       c.nombre_prod,
	                       TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	                  INTO cNumCredito,
	                       cNumCte,
	                       cNomProducto, 
	                       cNomCte
	                  FROM "informix".sd_maecredcrd a,
	                       bdinteg:"informix".si_cliente b, 
	                       "informix".sd_definicion c 
	                 WHERE c.num_producto = a.num_producto
                   --    and c.num_producto='6300'
	                   AND c.empresa = a.empresa
	                   AND b.empresa = a.empresa
	                   AND b.numcte = a.numcte
	                   AND b.apell_paterno=  b.apell_paterno 
	                   AND b.apell_materno=  b.apell_materno 
	                   AND a.empresa = pEmpresa
	                   AND a.num_credito= pNumCredito;  
	                   
	                   IF cNumCredito IS NOT NULL THEN
	        	           LET nrows=nrows+1;
	                       RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
	                   END IF;
	                      
	                  --END FOREACH;                  
	              
	              END FOREACH;
         
    ELIF pApellidosPat IS NOT NULL OR pApellidosMat IS NOT NULL THEN 
         --consulta por nombre para credito normales
       FOREACH 
         SELECT a.num_credito
           INTO pNumCredito
           FROM bdicred:sd_maecred a, bdinteg:"informix".si_cliente b
          WHERE b.apell_paterno = pApellidosPat 
            AND b.apell_materno = (CASE WHEN pApellidosMat IS NULL THEN b.apell_materno ELSE pApellidosMat END)
            AND a.empresa= b.empresa
            AND b.numcte = a.numcte
            AND a.empresa= pEmpresa
			AND a.num_producto = (CASE WHEN pNumProd IS NULL THEN a.num_producto ELSE pNumProd END)
        
           --FOREACH
               
               SELECT a.num_credito,
                   a.numcte,
                   d.num_tarjeta,
                   c.nombre_prod,
                   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
              INTO cNumCredito,
                   cNumCte,
                   cNumTarjeta,
                   cNomProducto, 
                   cNomCte
              FROM "informix".sd_maecred a,
                   bdinteg:"informix".si_cliente b, 
                   "informix".sd_definicion c, 
                   "informix".sd_tarjeta d
             WHERE c.num_producto = a.num_producto
               AND c.empresa = a.empresa
               AND b.empresa = a.empresa
               AND d.empresa = a.empresa
               AND b.numcte = a.numcte
               AND b.apell_paterno=  b.apell_paterno 
               AND b.apell_materno=  b.apell_materno 
               AND d.num_credito = a.num_credito
               AND d.tipo_tarjeta = 'T'
               AND d.secuencia = (SELECT MAX(secuencia) 
			                        FROM bdicred:sd_tarjeta 
								   WHERE a.empresa = empresa 
								     AND a.num_credito = num_credito 
									 AND tipo_tarjeta = 'T')
               AND d.empresa = a.empresa
               AND a.empresa = pEmpresa
               AND a.num_credito= pNumCredito;  
               
               IF cNumCredito IS NOT NULL THEN
    	           LET nrows=nrows+1;
                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
               END IF;
           --END FOREACH;           
       END FOREACH;
	   
	      --CONSULTA POR NOMBRE PARA PRESTAMOS PERSONALES
		  LET cNumTarjeta='';
	      FOREACH 
	         SELECT a.num_credito
	           INTO pNumCredito
	           FROM bdicred:sd_maecredcrd a, bdinteg:"informix".si_cliente b
	          WHERE b.apell_paterno = pApellidosPat 
	            AND b.apell_materno = (CASE WHEN pApellidosMat IS NULL THEN b.apell_materno ELSE pApellidosMat END)
	            AND a.empresa= b.empresa
	            AND b.numcte = a.numcte
	            AND a.empresa= pEmpresa
				AND a.num_producto = (CASE WHEN pNumProd IS NULL THEN a.num_producto ELSE pNumProd END)
	        
	           --FOREACH
	               
	               SELECT a.num_credito,
	                   a.numcte,
	                   c.nombre_prod,
	                   TRIM(NVL(razon_social,' ')) || ' ' || TRIM(NVL(nombre1,' ')) || ' ' || TRIM(NVL(nombre2,' ')) || ' ' || TRIM(NVL(apell_paterno,' ')) || ' ' || TRIM(NVL(apell_materno,' ')) AS nombre_cte
	              INTO cNumCredito,
	                   cNumCte,
	                   cNomProducto, 
	                   cNomCte
	              FROM "informix".sd_maecredcrd a,
	                   bdinteg:"informix".si_cliente b, 
	                   "informix".sd_definicion c 
	             WHERE c.num_producto = a.num_producto
                   --and c.num_producto='6300'
	               AND c.empresa = a.empresa
	               AND b.empresa = a.empresa
	               AND b.numcte = a.numcte
	               AND b.apell_paterno=  b.apell_paterno 
	               AND b.apell_materno=  b.apell_materno 
	               AND a.empresa = pEmpresa
	               AND a.num_credito= pNumCredito;  
	               
	               IF cNumCredito IS NOT NULL THEN
	    	           LET nrows=nrows+1;
	                   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'') WITH RESUME;
	               END IF;
	           END FOREACH;           
	       --END FOREACH;
    END IF
  
IF nrows= 0 THEN
   LET cCodRet= '000002';
   LET cMensajeRet= 'No hay datos con la información indicada';
   RETURN cCodRet, cMensajeRet, cNumCredito, cNumCte, NVL(cNomProducto,''), cNumTarjeta, NVL(cNomCte,'');
END IF;

END
END PROCEDURE
DOCUMENT
'Se realiza procedimiento para realizar una consulta general',
'para obtener la información basica del cliente',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 17/06/2009',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_dias_vencido(pempresa char (3), pnum_credito char(20))
	returning char(6), Integer;
---bdicred
--10-10-2008
--Creado por:
--Juan Andres
--Obtener dias de vencido de un credito

--17-10-2008
--Modifico:
--Abraham Ayala
--No se antepuso la base de datos a la que corresponden las tablas de los select

--24-06-2009
--Modifico: Lorenzo Ibarra Garcia
--Se eliminó la condición de si la fecha de vencido es null para que regrese un código
--de retorno "000" con 0 dias de vencido y no un código "002" como se venia haciendo.

--11-12-2009
--Modifico: Walber Castro
--Se cambió el tipo de dato de la variable iDiasVenc de smallint a integer

	define dFecha_Hoy       date;
	define dFecha_Venc      date;
	define iDiasVenc        Integer;
	define sCodRet          char(6);
	define isql_err         Integer;

	--Set debug file to '/tmp/sp_dias_vencidos.out';
	--trace on;

	Begin
	    On Exception set isql_err
	        Let sCodRet = isql_err;
	        return sCodRet, 0;
	    End Exception;

	    Let sCodRet = '000';
	    Let iDiasVenc = 0;

	    Select fecha_hoy
	    Into dFecha_Hoy
	    From bdicred:sd_fechas
	    Where empresa = pempresa;

	    select fecha_vencto
	    Into dFecha_Venc
	    From bdicred:sd_maecredanexo
	    Where empresa     = pempresa  and
	          num_credito = pnum_credito;

	    If not dFecha_Venc is null then
	        Let iDiasVenc = dFecha_Hoy - dFecha_Venc;
	    end if
        
	    return sCodRet , iDiasVenc;
	End;
End procedure;