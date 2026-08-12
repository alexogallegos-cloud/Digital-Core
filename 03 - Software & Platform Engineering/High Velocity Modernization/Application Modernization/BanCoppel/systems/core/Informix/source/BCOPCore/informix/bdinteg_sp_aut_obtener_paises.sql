CREATE PROCEDURE "informix".sp_aut_obtener_paises( pNumRegistros SMALLINT)
        RETURNING CHAR(9) AS cod_ret,
				  CHAR(13) AS pais,
				  CHAR(8)  AS clave_pais,
				  CHAR(20) AS nombre;

        DEFINE cCodRet 	  	CHAR(9);
		DEFINE cPais	  	CHAR(13);
		DEFINE cClavePais  	CHAR(8);
		DEFINE cNombre	 	CHAR(20);
        DEFINE iSqlErr 		INTEGER;

        LET cCodRet = '000000000';
		LET cPais = '';
		LET cClavePais = '';
		LET cNombre = '';
        LET iSqlErr = 0;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cPais, NVL(cClavePais,''), cNombre;
                END EXCEPTION;

                --SET DEBUG FILE TO '/home/sysifx/MarcoRivera/logs/sp_aut_obtener_paises.out';
                --TRACE ON;
				
				IF EXISTS(SELECT * FROM bdinteg:si_paises) THEN
					FOREACH
						SELECT SKIP pNumRegistros FIRST 10 pais, clave_pais ,nombre INTO cPais, cClavePais, cNombre 
						FROM bdinteg:si_paises
						ORDER BY pais ASC 
						
						RETURN cCodRet, cPais, NVL(cClavePais,''), cNombre WITH RESUME;
					END FOREACH;
				
					IF pNumRegistros <> 0 AND cNombre = '' THEN
						LET ccodret = '99999999'; --termino de realizar busquedas paginadas
					END IF;
				ELSE
					LET cCodRet = '000000001'; --Sin registros
					RETURN cCodRet, cPais, NVL(cClavePais,''), cNombre;
				END IF;
        END;

END PROCEDURE
DOCUMENT
'AUTOR: Marco Rivera',
'FECHA: 19/01/2022',
'DESCRIPCION: Procedimiento para obtener el catalogo de si_paises';

CREATE PROCEDURE "informix".sp_aut_valida_preguntas_autenticacion(pempresa VARCHAR(3), pnum_cliente VARCHAR(13))
        RETURNING CHAR(9) 		AS cod_ret,
				  CHAR(13) 	AS rfc,
                  DATE 			AS fecha_nac,
				  CHAR(100) 	AS correo_elec,
				  CHAR(13)	AS telefono_casa,
				  CHAR(13) 	AS telefono_cel,
				  CHAR(2)	AS estado_vive,
				  CHAR(2)	AS estado_nac,
				  CHAR(3)	AS pais_vive,
				  CHAR(3)	AS pais_nac,
				  CHAR(30)	AS calle,
				  CHAR(32)	AS colonia;
				  

        DEFINE cCodRet 	  	CHAR(9);
		DEFINE cRfc			CHAR(13);
		DEFINE cFechaNac  	DATE;
		DEFINE cCorreo		CHAR(100);
		DEFINE cTelCasa		CHAR(13);
		DEFINE cTelCel	  	CHAR(13);
		DEFINE cEstadoVive 	CHAR(2);
		DEFINE cEstadoNac 	CHAR(2);
		DEFINE cPaisVive	CHAR(3);
		DEFINE cPaisNac		CHAR(3);
		DEFINE cCalle		CHAR(30);
		DEFINE cColonia		CHAR(32);
		
		DEFINE iContador	INTEGER;
        DEFINE iSqlErr 		INTEGER;

        LET cCodRet = '000000000';
		LET cRfc = '';		
        LET cFechaNac = null; 	
		LET cCorreo	= '';
		LET cTelCasa = '';	
		LET cTelCel = '';
		LET cEstadoVive = '';	
		LET cEstadoNac = '';
		LET cPaisVive = '';
		LET cPaisNac = '';
		LET cCalle = '';
		LET cColonia = '';	
		
		LET iSqlErr = 0;
		LET iContador = 1;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet,NVL(cRfc,''),cFechaNac,NVL(cCorreo,''),NVL(cTelCasa,''),NVL(cTelCel,''),NVL(cEstadoVive,''),NVL(cEstadoNac,''),NVL(cPaisVive,''),NVL(cPaisNac,''),NVL(cCalle,''), NVL(cColonia,'');
                END EXCEPTION;

                --SET DEBUG FILE TO '/home/sysifx/MarcoRivera/logs/sp_aut_valida_preguntas_autenticacion.out';
                --TRACE ON;

                IF pempresa = '' OR pnum_cliente = '' THEN
                        LET cCodRet = '000000001'; --Parametros incompletos
                         RETURN cCodRet,NVL(cRfc,''),cFechaNac,NVL(cCorreo,''),NVL(cTelCasa,''),NVL(cTelCel,''),NVL(cEstadoVive,''),NVL(cEstadoNac,''),NVL(cPaisVive,''),NVL(cPaisNac,''),NVL(cCalle,''), NVL(cColonia,'');
                END IF;
				
				SELECT LIMIT 1 rfc INTO cRfc FROM bdinteg:si_cliente
				WHERE empresa = pempresa AND numcte = pnum_cliente; 

                SELECT LIMIT 1 fecha_nac, lugar_nac, nacionalidad INTO cFechaNac, cEstadoNac, cPaisNac
				FROM bdinteg:si_ctepf WHERE empresa = pempresa AND numcte = pnum_cliente;
				
				SELECT LIMIT 1 correo_elec INTO cCorreo FROM bdinteg:si_correos 
				WHERE empresa = pempresa AND numcte = pnum_cliente AND tipo_correo = 1 AND status_correo = 'A';
				
				SELECT LIMIT 1 telefono INTO cTelCasa FROM bdinteg:si_telefonos_actual 
				WHERE empresa = pempresa AND numcte = pnum_cliente AND tipo_tel = 1 AND status_tel = 'A';
				
				SELECT LIMIT 1 telefono INTO cTelCel FROM bdinteg:si_telefonos_actual 
				WHERE empresa = pempresa AND numcte = pnum_cliente AND tipo_tel = 2 AND status_tel = 'A';
				
				SELECT LIMIT 1 d.estado, d.pais, c.nombrecalle, cz.nombrezona
				INTO cEstadoVive, cPaisVive, cCalle, cColonia
				FROM bdinteg:si_direcciones_actual d LEFT JOIN
				bdinteg:si_catcalles c ON c.numerocalle = d.numerocalle LEFT join
				bdinteg:si_catzonas cz ON cz.numerociudad = d.numerociudad AND cz.numerocolonia = d.numerocolonia  
				WHERE d.tipo_dir = 1 AND d.numcte = pnum_cliente;
				
				RETURN cCodRet,NVL(cRfc,''),cFechaNac,NVL(cCorreo,''),NVL(cTelCasa,''),NVL(cTelCel,''),NVL(cEstadoVive,''),NVL(cEstadoNac,''),NVL(cPaisVive,''),NVL(cPaisNac,''),NVL(cCalle,''), NVL(cColonia,'');
        END;

END PROCEDURE
DOCUMENT
'AUTOR: Marco Rivera',
'FECHA: 19/01/2022',
'DESCRIPCION: Procedimiento para obtener los datos del cliente para las preguntas de inicio de sesion';

CREATE PROCEDURE "informix".sp_iccat_tarjetasactivascliente(pnum_cliente VARCHAR(13))
        RETURNING CHAR(9) AS cod_ret,
				  CHAR(16) AS numtarjeta;

        DEFINE cCodRet 	  	CHAR(9);
		DEFINE cNumTarjeta 	CHAR(16);
        DEFINE iSqlErr 		INTEGER;

        LET cCodRet = '000000000';
		LET cNumTarjeta = '';
        LET iSqlErr = 0;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN

			ON EXCEPTION SET iSqlErr
					LET cCodRet = iSqlErr;
					RETURN cCodRet, NVL(cNumTarjeta,'');
			END EXCEPTION;

			--SET DEBUG FILE TO '/home/sysifx/MarcoRivera/logs/sp_iccat_tarjetasActivasCliente.out';
			--TRACE ON;

			IF NVL(pnum_cliente,'') = '' THEN
					LET cCodRet = '000000001'; --Parametros incompletos
					RETURN cCodRet, cNumTarjeta;
			END IF;
			
			IF EXISTS(SELECT numtarjeta FROM intercard:tarjeta WHERE numcliente = pnum_cliente AND codstatustarjeta = 'ACT') THEN
				FOREACH
					SELECT numtarjeta INTO cNumTarjeta FROM intercard:tarjeta 
					WHERE numcliente = pnum_cliente AND codstatustarjeta = 'ACT'
					
					RETURN cCodRet, NVL(cNumTarjeta,'') WITH RESUME;
					
				END FOREACH;
			ELSE
				LET cCodRet = '000000002'; --No se encontraron tarjetas para el cliente
				RETURN cCodRet, NVL(cNumTarjeta,'');
			END IF;
        END;

END PROCEDURE
DOCUMENT
'AUTOR: Marco Rivera',
'FECHA: 24/01/2022',
'DESCRIPCION: Procedimiento para obtener las tarjetas activas del cliente ICCAT';

CREATE PROCEDURE "informix".sp_obtieneinfprod2(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pClavetp CHAR(3))
   RETURNING CHAR(5), CHAR(5), CHAR(6), CHAR(2), CHAR(3), CHAR(4), CHAR(3);
      
   DEFINE cCodRet       CHAR(5);
   DEFINE iSqlErr       INTEGER;
   DEFINE cIdBin        CHAR(5);
   DEFINE cCodBin       CHAR(6);
   DEFINE cProd         CHAR(2);
   DEFINE cCodProd      CHAR(3);
   DEFINE cCodProdCta	CHAR(4);
   DEFINE cClavetp      CHAR(3);
   DEFINE cProdCuenta	CHAR(4);
     
   LET cCodRet        ='00000';   
   LET cIdBin		  ='00000';
   LET cCodBin        ='000000';
   LET cProd		  ='00';
   LET cCodProd       ='000';
   LET cCodProdCta    ='0000';
   LET cClavetp       ='000';
   LET cProdCuenta    ='0000';
   
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
										   
			RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF pBin='416916' AND pSubBin='10' THEN
		LET pClavetp='042';
	END IF;

	IF pBin='416916' AND pSubBin='10' AND pClavetp = '003'  THEN
		LET pClavetp='042';
	END IF;	

	SELECT DISTINCT codprodcta 
	INTO cProdCuenta
	FROM intercard:binproducto a INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
	WHERE a.bin= pBin AND codprodcta = pCodProdCta;

	IF cProdCuenta <> '' OR cProdCuenta IS NOT NULL THEN 

		SELECT DISTINCT idbinproducto, a.bin, a.producto, a.codproductotarjeta, a.codprodcta, clave 
		INTO cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp
		FROM intercard:binproducto a
		INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
		WHERE a.bin = pBin 
		AND a.producto= pSubBin 
		AND b.clave = pClavetp
		AND a.codprodcta = pCodProdCta;
	ELSE
		--RETURN '00002';
		LET  cCodRet = '00001';
	END IF;         

	IF cCodBin IS NULL or cCodProd IS NULL THEN
		LET  cCodRet = '00001';
	END IF;

	RETURN cCodRet, cIdBin, cCodBin, cProd, cCodProd, cCodProdCta, cClavetp;
END;
END PROCEDURE;