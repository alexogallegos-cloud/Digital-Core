CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_blodesb_iccat(pempresa CHAR(3), pnumcte CHAR(9), pusuario CHAR(8), pNumRegistros SMALLINT)
RETURNING CHAR(9),CHAR(104),CHAR(16), CHAR(1), CHAR(50), CHAR(4), CHAR(20), CHAR(60), CHAR(1), CHAR(3),CHAR(9),CHAR(9),CHAR(1);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE error_info varchar(104);
DEFINE isam_err integer;
DEFINE isql_err integer;
DEFINE cnomcliente char(104);
DEFINE cnumtarjeta char(16);
DEFINE ctipotar char(1);
DEFINE cestatustar char(50);
DEFINE cproductotar char(4);
DEFINE cnumcuenta char(20);
DEFINE cnumcuentaAux char(20);
DEFINE cstatuscuenta varchar(3);
DEFINE cstatuscuentadesc char(60);
DEFINE ctitular char(1);
DEFINE ccodestatus char(3);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
DEFINE tarjetaBloq CHAR(20);
DEFINE bandBloqueo CHAR(1);
DEFINE cFecha DATETIME YEAR TO FRACTION(3);
DEFINE iExiste INTEGER;
DEFINE cExisteCta INTEGER;

LET ccodret = "000000000";
LET cnomcliente = "";
LET cnumtarjeta = "";
LET ctipotar = "";
LET cestatustar = "";
LET cproductotar = "";
LET cnumcuenta = "";
LET cnumcuentaAux = "";
--LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET tarjetaBloq = "";
LET bandBloqueo = "";
LET cFecha = DATE(1);
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			let ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta, bandBloqueo;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/home/sysifx/Elmer/713-714/sp_consultartarjetas_debcred_can_iccat.out';
	--TRACE ON;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	CREATE TEMP TABLE tbl_cuentascliente(
		numcte CHAR(20),
		producto CHAR(4),
		statuscta CHAR(3),
		tipotar CHAR(1),
		cuenta CHAR(20)
	) WITH NO LOG;

	DROP TABLE IF EXISTS tbl_tarjetascliente;
	CREATE TEMP TABLE tbl_tarjetascliente(
		numtarjeta CHAR(20),
		cuenta CHAR(20),
		numcte CHAR(20)
	) WITH NO LOG;

	--Se llena tabla de paso con cuentas de debito del cliente
	FOREACH WITH HOLD
		SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
			cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
		INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
		FROM bdicheq:'informix'.sc_maechq cta
		WHERE cta.num_cte = pnumcte

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD
		SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
			cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
		INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
		FROM bdicred:'informix'.sd_maecred cta
		WHERE empresa = pempresa AND cta.numcte = pnumcte

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	FOREACH WITH HOLD
		SELECT DISTINCT(cuenta)
		INTO cnumcuenta
		FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'

		--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD
			SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
			INTO cnumtarjeta, cnumCteTarjeta
			FROM bdicheq:'informix'.sc_tarjeta trjasig
			WHERE trjasig.cuenta = cnumcuenta
			AND trjasig.numcte != pnumcte
			AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN

				FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq) } cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
					INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
					FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta

						INSERT INTO tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
						VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);

				END FOREACH;

			END IF;

		END FOREACH;
	END FOREACH;

	FOREACH WITH HOLD
		SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
		trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
		INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
		FROM bdicheq:'informix'.sc_tarjeta trjasig
		WHERE trjasig.numcte = pnumcte
		AND trjasig.tipo_tarjeta IN ('T','A')

		INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
		VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

		--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
		SELECT COUNT(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
		IF cExisteCta = 0 THEN

			FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq) } cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta

					INSERT INTO tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);

			END FOREACH;

		END IF;
	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales

	FOREACH WITH HOLD
		SELECT DISTINCT(cuenta)
		INTO cnumcuenta
		FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'

		FOREACH WITH HOLD
			SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
				trjasig.num_tarjeta, trjasig.numcte
			INTO cnumtarjeta, cnumCteTarjeta
			FROM  bdicred:'informix'.sd_tarjeta trjasig
			WHERE trjasig.num_credito = cnumcuenta
			AND trjasig.numcte != pnumcte
			AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN

				FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicred:'informix'.sd_maecred cta WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta

					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);

				END FOREACH;
			END IF;

		END FOREACH;
	END FOREACH;

	FOREACH WITH HOLD
		SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
			trjasig.num_tarjeta, trjasig.numcte, trjasig.num_credito
		INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
		FROM  bdicred:'informix'.sd_tarjeta trjasig
		WHERE trjasig.numcte = pnumcte
		AND trjasig.tipo_tarjeta IN ('T','A')

		INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
		VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

		--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de credito relacionada
		SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
		IF cExisteCta = 0 THEN

			FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_idx_maecredb)} cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
			FROM bdicred:'informix'.sd_maecred cta WHERE cta.empresa = pempresa AND cta.num_credito = cnumcuenta

				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);

			END FOREACH;
		END IF;

	END FOREACH;

	--Una vez obtenidos los datos anteriores se recorren tarjeta por tarjeta y se obtienen los datos faltantes para regresarlos en el retorno del SPL
	FOREACH WITH HOLD
		SELECT SKIP pNumRegistros FIRST 10
			trjasig.numtarjeta, trjasig.cuenta, trjasig.numcte, cta.numcte, cta.producto, cta.statuscta, cta.tipotar
		INTO cnumtarjeta, cnumcuenta, cnumCteTarjeta, cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar
		FROM 'informix'.tbl_tarjetascliente trjasig INNER JOIN 'informix'.tbl_cuentascliente cta
		ON cta.cuenta = trjasig.cuenta
		WHERE ((cta.numcte = pnumcte)
		OR (cta.numcte <> pnumcte AND trjasig.numcte = pnumcte))
		ORDER BY cta.tipotar DESC, trjasig.numtarjeta ASC

		SELECT trj.nombre, trj.codstatustarjeta, trj.titular, trj.numtarjeta
		INTO cnomcliente, ccodestatus, ctitular, cnumtarjeta
		FROM 'informix'.tarjeta trj
		WHERE trj.numtarjeta = cnumtarjeta AND trj.codstatusasignada = 'SIA';

		SELECT trjest.codstatustarjeta, trjest.descstatustarjeta
		INTO ccodestatus, cestatustar
		FROM 'informix'.statustarjeta trjest
		WHERE trjest.codstatustarjeta = ccodestatus;

		IF ctipotar = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF ctipotar = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		SELECT MAX(fechahora) INTO cFecha
		FROM intercard: bitacoracambiosstatustarjeta
		WHERE tarjeta = cnumtarjeta;

		SELECT tarjeta
		INTO tarjetaBloq
		FROM intercard: bitacoracambiosstatustarjeta
		WHERE fechahora = cFecha
		AND codstatustarjetanvo = 'BLT'
		AND usuario = pusuario
		AND tarjeta = cnumtarjeta;

		LET tarjetaBloq = NVL(tarjetaBloq,'');
		IF (tarjetaBloq <> '')  THEN
			LET bandBloqueo = 'T';
		ELSE
			LET bandBloqueo = 'F';
		END IF;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			LET iExiste = iExiste + 1;
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta, bandBloqueo WITH RESUME;
		END IF;

	END FOREACH;

	DROP TABLE IF EXISTS tbl_cuentascliente;
	DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta, bandBloqueo;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	Consultar las Tarjetas de los clientes',
'AUTOR:		 ',
'FECHA : 	07/05/2018',
'Solicitï¿½:  Ivan Manjarrez',
'BD : 		INTERCARD';

CREATE PROCEDURE "informix".sp_notifica_tjtsporexpirar ()	

RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;	

	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80); 
    DEFINE RUTA_DESTINO VARCHAR(80);	
	
	DEFINE valerta1             varchar(10);
    DEFINE valerta2             varchar(10);
    DEFINE vIdPlantilla1        varchar(15); 
    DEFINE vIdPlantilla2        varchar(15); 
	DEFINE vestatusenvio        char(1);
	DEFINE vstipoenvio          char(1); 
    DEFINE cStr1                char(4);	
	
	DEFINE vNumTarjeta          Varchar(16);
    DEFINE  vfechexp            DATE;
	DEFINE  vfechexp2           VARCHAR(6);	
	DEFINE  vfechexp3           VARCHAR(4);	
	DEFINE pIdProceso           varchar(50); 
	DEFINE vdFechaInsert        DATETIME YEAR TO FRACTION(5);
	DEFINE vFechaProc           DATETIME YEAR TO FRACTION(5);
	DEFINE vsecuencial          integer; 
	DEFINE cCodRet              CHAR(5);
	DEFINE vsCodRet1            CHAR(5);
    DEFINE vsCodRet2            CHAR(5);
    DEFINE vsnumcte 	        CHAR (20);
	DEFINE cStr5                VARCHAR(150);
    DEFINE vstelefono	        CHAR(13);
    DEFINE vstipotel 	        SMALLINT;
    DEFINE vsSecuencia          SMALLINT;
    DEFINE vsStatustel	        CHAR(1);
    DEFINE vsextension 	   	    CHAR(5);
    DEFINE vscarrier	   	    SMALLINT;
    DEFINE vsnombrecarrier 	    CHAR(20);
    DEFINE vsStatusvalidacion   SMALLINT;
    DEFINE vscorreo			    CHAR(100);
    DEFINE vstipocorreo		    SMALLINT;
    DEFINE vsStatuscorreo       CHAR(1);
    DEFINE vsMensaje            CHAR(200);
	DEFINE vfecha  char(10);
	DEFINE vhora   char(8);
	
	LET vNumTarjeta = '';
    LET vfechexp    = '';
	LET vfechexp2   = '';
    LET vfechexp3   = '';	
	LET RUTA_DESTINO  = '/RESPALDOSNEW/';
	LET pIdProceso         = 'NOTIF_EXP_TJT';
	LET vdFechaInsert      =  sysdate; 
    LET vFechaProc         =  current;	
	LET vsecuencial        =  0; 
	LET cCodRet           =  '00000';
	LET vsCodRet1          = '00000';
    LET vsCodRet2          = '00000';
    LET vstelefono         = '';
    LET vstipotel          = 0;
    LET vsSecuencia        = 0;
    LET vsStatustel        = '';
    LET vsextension        = '';
    LET vscarrier          = 0;   
    LET vsnombrecarrier    = '';
    LET vsStatusvalidacion = 0;
    LET vsnumcte           = '';
	LET cStr5              = ''; 
    LET vscorreo           = '';
    LET vsStatuscorreo     = '';
    LET vstipocorreo       = 0;
    LET vsMensaje          = ''; 
	LET codigo_retorno  = '00000';
	LET mensaje_retorno = 'PROCESO EXITOSO';
	LET vstipoenvio     = '';
	LET cStr1           = '';
	LET vfecha          = '';
    LET vhora           = '';
	
	
	--SET DEBUG FILE TO RUTA_DESTINO || "sp_notifica_tjtsporexpirar.out";
    --TRACE ON;        	
	
BEGIN 
	
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_DESTINO || "sp_notifica_tjtsporexpirar.out";
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;	

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
------------------------------------------------------------------------------------------------------------------------
		
		 LET vIdPlantilla1 ='EXPTJTMAIL';    -- plantilla email   
		 LET valerta1      ='CMPC_BATCH';    -- alerta email 
		 LET vIdPlantilla2 ='EXPTJT_SMS';    -- plantilla sms    
         LET valerta2      ='CMPS_BATCH';    -- alerta sms   
         LET vestatusenvio = 'V';			 
		
		
	    BEGIN;
		DROP TABLE IF EXISTS "informix".tarjetas_exp1;
		DROP TABLE IF EXISTS "informix".clientes_email;
		DROP TABLE IF EXISTS "informix".clientes_tel;
		DROP TABLE IF EXISTS "informix".concentrado_ctes;	
		COMMIT;
				
		SELECT (extend(fecha_hoy + 1 units MONTH)) 
		INTO   vfechexp  FROM bdinteg:si_fechas WHERE empresa= '001';  
		      
	    LET vfechexp2  = YEAR(vfechexp)||LPAD(MONTH(vfechexp),2, '0');			
	    LET vfechexp3  = SUBSTR(vfechexp2,3,2)||SUBSTR(vfechexp2,5,2); 
		--LET vfechexp3  = '1601'; -- test
		
       LET vFechaProc = vFechaProc;		
       LET vfecha =  CAST(TO_CHAR(vFechaProc,'%d-%m-%Y') as char(10)); 
	   LET vhora  =  EXTEND(vFechaProc,hour to second);
	   
	   --LET vfecha = vfecha;
	   --LET vhora = vhora;
	   
		Select  tjt.numtarjeta, tjt.numcliente, tjt.codproductotarjeta, pt.descproducto
        from intercard:tarjeta  tjt
        inner join  productotarjeta pt 
        on  tjt.codproductotarjeta = pt.codproductotarjeta
        where tjt.fechaexp =  vfechexp3
        and tjt.codstatustarjeta in ('ACT','BLO','BLT')
	    INTO TEMP tarjetas_exp1 with no log;
		
		Select  tjt.numtarjeta, tjt.numcliente, NVL(sic.correo_elec, 0) as correo 
        from intercard:tarjetas_exp1 tjt 
		inner join bdinteg:"informix".si_correos sic 
		   ON( tjt.numcliente = sic.numcte)
          and sic.tipo_correo = '1'
          and sic.status_correo = 'A'
		  into temp clientes_email with no log;
		  
		Select  tjt.numtarjeta, tjt.numcliente, NVL(sit.telefono, 0) as telefono
        from intercard:tarjetas_exp1 tjt 
		inner join bdinteg:"informix".si_telefonos_actual sit 
		   ON( tjt.numcliente = sit.numcte)
           AND sit.status_tel = 'A'
           AND sit.tipo_tel = '2'
		  into temp clientes_tel with no log;

		Select '001' as empresa, tar.numtarjeta, tar.descproducto, tar.numcliente,  NVL(em.correo, 0) as correo , 
		        NVL(ce.telefono, 0) as telefono  from tarjetas_exp1  tar  
        LEFT JOIN  clientes_email em  ON em.numtarjeta = tar.numtarjeta
        LEFT JOIN  clientes_tel   ce  ON tar.numtarjeta = ce.numtarjeta
        into temp concentrado_ctes with no log;
		
		CREATE INDEX "informix".idx_concentrado_cte1
        ON "informix".concentrado_ctes(numtarjeta,numcliente) ONLINE;
		
	
	FOREACH WITH HOLD

		   Select 
           tjt.numtarjeta,  
           tjt.numcliente,
		   tjt.descproducto,
		   tjt.correo,
		   tjt.telefono
		   INTO  
		   vNumTarjeta,    
		   vsnumcte,
		   cStr5,
		   vscorreo,
		   vstelefono
		   from concentrado_ctes tjt 
		   Where empresa = '001'
  
            LET cStr1 = SUBSTR(vNumTarjeta,13,4); 
			
            IF    (vscorreo = '0' and vstelefono = '0')   THEN 
			  
			                LET vsCodRet1 = '002';
							LET vsMensaje = 'Titular no tiene registrado celular o correo electronico.';
                            LET vestatusenvio = 'P';	
							LET vstipoenvio = '';
			    
			ELIF ( (vscorreo <> '0' AND vscorreo is not null) ) THEN 	
 
					--email 
                  EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('1',valerta1,vIdPlantilla1,vsnumcte,'',TRIM(cStr1),'2',TRIM(vfecha),TRIM(vhora),'','',TRIM(cStr5),'','','','','','','',1,'','','','',current,'')					
					INTO 	cCodRet;
					
					    LET  vsCodRet1     = '000';	
						LET  vestatusenvio = 'V';
			            LET  vstipoenvio   = '2';
						LET  vsMensaje     = 'Se envio Correo al titular.';
		
			        IF  ( cCodRet <> '00000' )  THEN 
					 
                            LET vsCodRet1 = '004';
							LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                            LET vestatusenvio = 'E';							  
					END IF; 	   
							
            ELIF   ( (vstelefono <> '0' AND vstelefono is not null) ) THEN  
		
					-- sms 
                    EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('2',valerta2,vIdPlantilla2,vsnumcte,'',TRIM(cStr1),'2','','','','','','','','','','','','',1,'','','','','','')					
					INTO 	cCodRet;
					

					    LET  vsCodRet1     = '000';	
						LET  vestatusenvio = 'V';
			            LET  vstipoenvio   = '1';
						LET  vsMensaje = 'Se envio SMS al titular.'; 
					
					IF  ( cCodRet <> '00000' )  THEN 
					 
                            LET vsCodRet1 = '004';
							LET vsMensaje = 'Hubo un error al registrarse en bdimnsj.';
                            LET vestatusenvio = 'E';							
					END IF; 		

					LET cStr1 = '';  
					
			END IF; 
			
 
		 INSERT  INTO intercard:"informix".bitacoraenvios_tjts
		 VALUES ( 0, pIdProceso,vNumTarjeta,vdFechaInsert,vestatusenvio,vstipoenvio,vsCodRet1,vsMensaje);   

		END FOREACH;   
	
	    UPDATE STATISTICS MEDIUM FOR TABLE "informix".bitacoraenvios_tjts;
------------------------------------------------------------------------------------------------------------------------

    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;


END;
END PROCEDURE
---CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 29 de octubre del 2020
---Base de datos: intercard
---Este proceso corresponde al job 855
----EXECUTE PROCEDURE "informix".sp_notifica_tjtsporexpirar();
;

CREATE PROCEDURE "informix".sp_pase_historico_atm()

RETURNING CHAR(5),INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
    DEFINE vcodret1         		CHAR(5);
    DEFINE error_info       		CHAR(50);
    DEFINE sql_err          		INTEGER;
    DEFINE isam_err         		INTEGER;
    DEFINE vcontador1       		INTEGER;
    DEFINE vcontador2       		INTEGER;
    DEFINE vRegistros       		INTEGER;
    DEFINE vId              		INTEGER;
    DEFINE vfecha_oper      		DATE;
    DEFINE vsecuencia 				VARCHAR(7) ;
    DEFINE vnumtarjeta 				VARCHAR(16);
    DEFINE vfechalocaltransaccion 	VARCHAR(4);
    DEFINE vhoralocaltransaccion 	VARCHAR(6);
	
	/* DEFINICION DE VARIABLES PARA CALCULAR EL RANGO DE EXTRACCION */
	
	DEFINE vsFechaInicio	CHAR (10);
	DEFINE vsFechaFin	 	CHAR (10);
	DEFINE vsFecha_Inicio	DATETIME YEAR TO FRACTION (5);
	DEFINE vsFecha_Fin	 	DATETIME YEAR TO FRACTION (5);
	DEFINE vsDias			VARCHAR(3);
	DEFINE vExecuteSQL 		LVARCHAR(2000);
	
	/* DEFINICION VARIABLES PARA INSERT Y DELETE DE REGISTROS */
	
	DEFINE vsKeyx 				INTEGER;
	DEFINE vsFechaconciliacion 	DATETIME YEAR TO FRACTION (5);
	DEFINE vsArchivoorigen		VARCHAR (3);
	DEFINE vsNombrearchivo		VARCHAR (23);
	DEFINE vsNumtarjeta			VARCHAR (16);
	DEFINE vsAutorizacion		VARCHAR (7);
	DEFINE vsnumero				VARCHAR (1);
	
	

---------------------------
--Inicializando variables--
---------------------------
        --SET DEBUG FILE TO "/home/c98188925/pase_historico/debug/sp_pase_historico_atm.out"; --Se genera log en un archivo .out
        --TRACE ON;

        LET vcodret1        		= '00000';
        LET sql_err         		= 0;
        LET isam_err        		= 0;
        LET vcontador1      		= -1;
        LET vcontador2      		= 0;
        LET vRegistros      		= 0;
        LET vId             		= 0;
        LET vsecuencia      		='';
        LET vnumtarjeta     		='';
        LET vfechalocaltransaccion 	='';
        LET vhoralocaltransaccion  	='';
		
		/* DEFINICION DE VARIABLES PARA CALCULAR EL RANGO DE EXTRACCION */
		
        LET vsFechaInicio  	='';
        LET vsFechaFin  	='';
        LET vsFecha_Inicio 	= CURRENT;
        LET vsFecha_Fin  	= CURRENT;
        LET vsDias  		='';
		
		/* DEFINICION VARIABLES PARA INSERT Y DELETE DE REGISTROS */
		
		LET vsKeyx 					= 0;	
		LET vsFechaconciliacion 	= CURRENT;
		LET vsArchivoorigen			='';
		LET vsNombrearchivo			='';
        LET vsNumtarjeta			='';
        LET vsAutorizacion			='';
        LET vsnumero				='';

		
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
		
		SELECT valor INTO vsDias FROM bditarjeta:td_param_conciliacion_concreing WHERE codigo='753';


		SELECT TO_CHAR (min(fechaconciliacion ), '%Y-%m-%d') AS fecha_ini,
		   TO_CHAR (min(fechaconciliacion) + vsDias UNITS DAY, '%Y-%m-%d') AS fecha_fin
		   INTO vsFechaInicio,vsFechaFin
		FROM conciliacion_atm_stat06 ;
		
		IF ( (SELECT COUNT(*) FROM intercard:systables WHERE tabname = 'tbl_pase_historico_atm') = 1 ) THEN

			TRUNCATE TABLE tbl_pase_historico_atm DROP STORAGE;

		END IF;
		
		--------------------------------
		-- ExtracciÃ³n de transacciones--
		--------------------------------
		
		LET vsFecha_Inicio = vsFechaInicio || ' 00:00:00.00000';
		LET vsFecha_Fin    = vsFechaFin || ' 00:59:59.99999';
					
					
					/* SE DESCARGA TRANSACCIONES A PASAR A HISTORICO */

					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'echo "UNLOAD TO /RESPALDOSNEW/cnc_stat06.unl'||
					' SELECT keyx,fechaconciliacion,archivoorigen,nombrearchivo,numtarjeta,autorizacion,0'||
								' FROM Intercard:conciliacion_atm_stat06 '||
								' WHERE fechaconciliacion BETWEEN '||"'"|| vsFecha_Inicio||"'"||' AND '||"'"|| vsFecha_Fin ||"'"||
								';" >'|| 
								' /RESPALDOSNEW/'||'mov_cnc_atm.sql';
					SYSTEM vExecuteSQL;
					
					---Paso #2
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'dbaccess intercard '||'/RESPALDOSNEW/'||'mov_cnc_atm.sql';
					SYSTEM vExecuteSQL;
					
					---Paso #3
					LET vExecuteSQL = '';
					LET vExecuteSQL = "echo "||'"'|| "file '"|| '/RESPALDOSNEW' ||
							"/" || 'cnc_stat06.unl' || "' delimiter '|' "|| '7'||
								"; insert into tbl_pase_historico_atm" || ";"||'"'||' > carga_mov_stat.txt';
						SYSTEM vExecuteSQL;
					
					---Paso #4
					LET vExecuteSQL = '';
					LET vExecuteSQL = "dbload -d intercard -c carga_mov_stat.txt -l err_carga.log -n 1000 -k";
					SYSTEM vExecuteSQL;			
					
					
	
						---Paso #5
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/cnc_stat06.unl';
					SYSTEM vExecuteSQL;
					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm  -f /RESPALDOSNEW/mov_cnc_atm.sql'; 
					SYSTEM vExecuteSQL;
					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm -f  carga_mov_stat.txt';
					SYSTEM vExecuteSQL;
					
					
					LET vExecuteSQL = '';
					LET vExecuteSQL = 'rm -f  err_carga.log';
					SYSTEM vExecuteSQL;
		
	

		FOREACH WITH HOLD
		

			SELECT  keyx,fechaconciliacion,archivoorigen,nombrearchivo,numtarjeta,autorizacion,numero 
			INTO    vsKeyx,vsFechaconciliacion,vsArchivoorigen,vsNombrearchivo,vsNumtarjeta,vsAutorizacion,vsnumero
			FROM "informix".tbl_pase_historico_atm where numero=0

			IF vcontador1 = -1 THEN
			LET vcontador1 = 0;
			BEGIN WORK;
			END IF;

			/********************* INSERT A CONCILIACION_ATM_STAT06_HIS *********************************************************************************************/
			
			INSERT INTO intercard:conciliacion_atm_stat06_his (
				keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
				secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
				pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify)
				SELECT 
				keyx, fechaconciliacion, archivoorigen, nombrearchivo, emisor, numcajero, numtarjeta, numcuenta, indicadordereversa, descripcion, respuesta, codigoiso, 
				secuencia, fecha, hora, orden, red, monto, dolares, comisionsurcharge, donativo, emp, autorizacion, compania, comision_loyaltyfee, comision_usolinea, 
				pos_entry_mode, service_code, terminal_capability, arqc, arpc, arqc_verify
				FROM intercard:conciliacion_atm_stat06 
				WHERE keyx = vsKeyx AND fechaconciliacion = vsFechaconciliacion  
			AND numtarjeta = vsNumtarjeta and autorizacion = vsAutorizacion ;
			

			/********************************************************************************************************************************************************/
			
			DELETE FROM "informix".conciliacion_atm_stat06
				WHERE keyx = vsKeyx 
				AND fechaconciliacion = vsFechaconciliacion  
				AND numtarjeta = vsNumtarjeta 
			AND autorizacion = vsAutorizacion ;

			UPDATE "informix".tbl_pase_historico_atm 
				SET numero =1 
				WHERE keyx = vsKeyx 
				AND fechaconciliacion = vsFechaconciliacion  
				AND numtarjeta = vsNumtarjeta 
			AND autorizacion = vsAutorizacion;

			LET vcontador1 = vcontador1 + 1;
			LET vcontador2 = vcontador2 + 1;

			IF vcontador2 >= 10 THEN
				LET vcontador2 = 0;
				COMMIT WORK;
				BEGIN WORK;
			END IF;

		END FOREACH;
		
			IF vcontador1 > -1 THEN
			COMMIT WORK;
			END IF;

			RETURN vcodret1, vcontador1;
			
		END;

	
END PROCEDURE;