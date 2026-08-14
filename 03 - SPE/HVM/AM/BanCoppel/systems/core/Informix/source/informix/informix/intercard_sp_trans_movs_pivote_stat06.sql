CREATE PROCEDURE "informix".sp_trans_movs_pivote_stat06( pFechaBusqInicial DATETIME YEAR to FRACTION(5), pFechaBusqFinal DATETIME YEAR to FRACTION(5) )
    RETURNING CHAR (5) as rCODIGO_RETORNO, CHAR(120) as rMENSAJE_RESPUESTA;
    
    DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);
    
	DEFINE vCODIGO_RETORNO CHAR(5);
    DEFINE vMENSAJE_RETORNO CHAR(120);
    DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(80);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;    
    DEFINE NOMBRE_UNL_ARCHIVO VARCHAR(33);
    DEFINE SCRIPT_EJECUCION VARCHAR(34);
    DEFINE SCRIPT_UPD_STS VARCHAR(40);
    DEFINE PREFIJO_ARCHIVO VARCHAR(13);
    DEFINE NOM_ARCH_REG_CNC_PIV VARCHAR(33);
    DEFINE NOM_ARCH_ERR_CNC_PIV VARCHAR(33);    
    DEFINE vExecuteSQL LVARCHAR(5000);    
    DEFINE vIndicadorProceso CHAR(1);        
    DEFINE vAnio VARCHAR(7);
      
    LET vCODIGO_RETORNO = '00000';
    LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
    LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET SQLERR = '';
	LET ISAM_ERR = '';
	LET ERROR_INFO = '';
    
    LET vExecuteSQL = '';
    LET CONTADOR_TRANSACCIONES = 1000;
    
    LET vAnio = YEAR(pFechaBusqInicial);
    
    LET NOMBRE_UNL_ARCHIVO = '';
    LET NOM_ARCH_REG_CNC_PIV = '';
    LET NOM_ARCH_ERR_CNC_PIV = '';
    LET PREFIJO_ARCHIVO = 'tran_piv_';
    LET vIndicadorProceso = '0';
    
    --SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "debug_sp_trans_movs_pivote_stat06.out";                                                
    --TRACE ON;        
	
    BEGIN 		

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_UNLOAD_RESPALDOS || "excep_sp_trans_movs_pivote_stat06.err.out" WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current||' '||'vIndicadorProceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;


        LET NOMBRE_UNL_ARCHIVO = PREFIJO_ARCHIVO||'piv_'||vAnio||'.unl';
        LET SCRIPT_EJECUCION = PREFIJO_ARCHIVO||'ejec_piv_'||vAnio||'.sql';
        LET SCRIPT_UPD_STS = PREFIJO_ARCHIVO||'ejec_upd_sts_piv_'||vAnio||'.sql';
        LET NOM_ARCH_REG_CNC_PIV = PREFIJO_ARCHIVO||'reg_piv_'||vAnio||'.txt';
        LET NOM_ARCH_ERR_CNC_PIV = PREFIJO_ARCHIVO||'err_piv_'||vAnio||'.log';           

        TRUNCATE TABLE intercard:"informix".tbl_cnc_stat_06_pivote DROP STORAGE;
        
        LET vIndicadorProceso = '1';
        
        LET vExecuteSQL	= '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO||
        ' SELECT keyx, fechaconciliacion, secuencia, numtarjeta, 0 '  ||
        '    FROM intercard:"informix".conciliacion_atm_stat06_'||vAnio||
        ' WHERE fechaconciliacion  BETWEEN '''||pFechaBusqInicial||''' AND '''||pFechaBusqFinal||''' '||
         '" >'||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;            
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_EJECUCION;
        SYSTEM vExecuteSQL;

        LET vIndicadorProceso = '2';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA_UNLOAD_RESPALDOS||NOMBRE_UNL_ARCHIVO|| "' delimiter '|' "|| '5'||                          
                          "; INSERT INTO tbl_cnc_stat_06_pivote; "||'"'||' > '||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_CNC_PIV;
        SYSTEM vExecuteSQL;        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_REG_CNC_PIV||" -l "||RUTA_UNLOAD_RESPALDOS||NOM_ARCH_ERR_CNC_PIV||" -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = ' echo UPDATE STATISTICS MEDIUM FOR TABLE intercard:"informix".conciliacion_atm_stat06_'||vAnio||' > '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;    
         
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||SCRIPT_UPD_STS;
        SYSTEM vExecuteSQL;
        
        LET vIndicadorProceso = '3';
            
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm -f ' ||RUTA_UNLOAD_RESPALDOS||PREFIJO_ARCHIVO||'*';
        SYSTEM vExecuteSQL;
        
        

        RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;	
		
	END
END PROCEDURE
DOCUMENT
'Base de datos: intercard',
'Fecha de creacion: 15 de abril del 2021',
'Armando Garcia Ortiz',
'Coordinacion de Tarjetas - Gerencia I',
'Descripcion: Componente principal para registrar la informacion a la tabla pivote del stat 06'
;

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_rep_iccat_exp(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info varchar(104);
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
DEFINE cproductotar char (4);
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta char (3);
DeFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnombre1 char(20);
DEFINE cnombre2 char(20);
DEFINE paterno char(20);
DEFINE materno char(20);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
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
LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuenta, ctitular, ccodestatus,cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SET DEBUG FILE TO '/tmp/sp_consultartarjetas_debcred_rep_iccat.out';
	TRACE ON;

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
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
				cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta
			WHERE cta.num_cte = pnumcte
			AND cta.producto = '2400'

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
				cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta
			WHERE cta.numcte = pnumcte
			AND cta.num_producto IN ('7000', '8100')

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
	
		FOREACH WITH HOLD SELECT  {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

		END FOREACH;
		
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')
				

				INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
				VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	

	FOREACH WITH HOLD 
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
	
		--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
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
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
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
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
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

		IF TRIM(ctipotar) = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF TRIM(ctipotar) = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		LET cnombre1='';
		LET cnombre2='';
		LET paterno='';
		LET materno='';

		FOREACH
			SELECT FIRST 1 s.nombre1,s.nombre2,s.apaterno,s.amaterno
			INTO cnombre1,cnombre2,paterno,materno
			FROM "informix".solicitudtarjeta s INNER JOIN "informix".detalle_maquila d ON (s.idsolicitud = d.idsolicitud)
			WHERE s.numcuenta = cnumcuenta AND d.numtarjeta = cnumtarjeta
			ORDER BY s.fechasolicitud DESC
		END FOREACH
		--ExtracciÃ³n de nombre de tabla alterna
		IF TRIM(NVL(cnombre1,''))='' AND TRIM(NVL(cnombre2,''))='' THEN
			--SELECT s.nombre1,s.nombre2,s.apaterno,s.amaterno
			--INTO cnombre1,cnombre2,paterno,materno
			SELECT s.nombre1, SUBSTRING( TRIM(s.apaterno) FROM 1 FOR ( 20 - char_length(TRIM(s.nombre1)) ) ) AS apaterno
			INTO cnombre1,paterno
			FROM "informix".solicitudtarjeta s INNER JOIN bdicred:"informix".sd_credito_upgrade cu ON (s.numcliente = cu.numcte AND s.numcuenta = cu.num_credito)
			INNER JOIN intercard:"informix".detalle_maquila de ON (s.idsolicitud = de.idsolicitud AND de.numtarjeta = cnumtarjeta)
			WHERE cu.numero_credito_upgrade = cnumcuenta AND cu.numerotarjeta_upgrade = cnumtarjeta;
			
			IF char_length(TRIM(NVL(cnombre1,'')))<=1 OR char_length(TRIM(NVL(paterno,'')))<=1 THEN
				SELECT nombre1, SUBSTRING( TRIM(apell_paterno) FROM 1 FOR ( 20 - char_length(TRIM(nombre1)) ) ) AS apaterno
				INTO cnombre1,paterno
				FROM bdinteg:si_cliente WHERE numcte=pnumcte;
			END IF;
		END IF;
		
		IF TRIM(NVL(cnombre1,''))='' THEN
			LET cnombre1='-';
		END IF;
		IF TRIM(NVL(cnombre2,''))='' THEN
			LET cnombre2='-';
		END IF;
		IF TRIM(NVL(paterno,''))='' THEN
			LET paterno='-';
		END IF;
		IF TRIM(NVL(materno,''))='' THEN
			LET materno='-';
		END IF;
		LET cnomcliente = cnombre1||'|'||cnombre2||'|'||paterno||'|'||materno;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
    DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;
                --DROP TABLE IF EXISTS tbl_cuentascliente;
                --DROP TABLE IF EXISTS tbl_tarjetascliente;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	consultar las tarjetas debito platino, credito oro y platino relacionadas al cliente o su cuenta ',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/07/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica la tabla de donde valida el numero de producto',
'AUTOR:		Arturo Astorga',
'FECHA : 	28/09/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el nombre que se rotulara en la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/11/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la cuenta',
'AUTOR:		Arturo Astorga',
'FECHA : 	20/02/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	23/04/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	optimizar las consultas para obtencion de la informacion',
'AUTOR:		Elmer Lopez Valenzuela',
'FECHA : 	27/01/2020',
'SolicitÃ³:  jose luis polanco',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_consultartarjetas_debcred_rep_iccat(pempresa CHAR(3), pnumcte CHAR(9), pNumRegistros SMALLINT)
RETURNING char(9),char(104),char(16), char(1), char(50), char(4), char(20), char(60), char(1), char(3),char(9),char(9);

--@comment: Declaracion variables para responder
DEFINE ccodret char(9);
DEFINE isam_err integer;
DEFINE error_info varchar(104);
DEFINE isql_err integer;
DEFINE cnomcliente char (104);
DEFINE cnumtarjeta char (16);
DEFINE ctipotar char(1);
DEFINE cestatustar char (50);
DEFINE cproductotar char (4);
DEFINE cnumcuenta char (20);
DEFINE cnumcuentaAux char (20);
DEFINE cstatuscuenta char (3);
DeFINE cstatuscuentadesc char (60);
DEFINE ctitular char (1);
DEFINE ccodestatus char (3);
DEFINE cnombre1 char(20);
DEFINE cnombre2 char(20);
DEFINE paterno char(20);
DEFINE materno char(20);
DEFINE cnumCteTitularCuenta char(9);
DEFINE cnumCteTarjeta char(9);
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
LET cstatuscuenta = "";
LET cstatuscuentadesc = "";
LET ctitular = "";
LET ccodestatus = "";
LET cnumCteTitularCuenta="";
LET cnumCteTarjeta="";
LET iExiste = 0;
LET cExisteCta = 0;

BEGIN

	ON EXCEPTION SET isql_err,isam_err, error_info
		IF isql_err <> 0 THEN
			LET ccodret = isql_err;
			LET cnomcliente = error_info;
			
			DROP TABLE IF EXISTS tbl_cuentascliente;
			DROP TABLE IF EXISTS tbl_tarjetascliente;
			
			RETURN ccodret,cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuenta, ctitular, ccodestatus,cnumCteTitularCuenta,cnumCteTarjeta;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO '/tmp/sp_consultartarjetas_debcred_rep_iccat.out';
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
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_maechq mae1)}
				cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicheq:'informix'.sc_maechq cta
			WHERE cta.num_cte = pnumcte
			AND cta.producto = '2400'

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con cuentas de credito del cliente
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_maecred idx_maecreda)}
				cta.numcte, cta.num_producto, cta.status_cred, 'C', cta.num_credito
			INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta
			FROM bdicred:'informix'.sd_maecred cta
			WHERE cta.numcte = pnumcte
			AND cta.num_producto IN ('7000', '8100')

		INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
		VALUES (cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuenta);

	END FOREACH;

	--Se llena tabla de paso con tarjetas de debito del cliente y de los clientes que tienen cuentas relacionadas al cliente titulares o adicionales
	FOREACH WITH HOLD
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'D'
	
		FOREACH WITH HOLD SELECT  {+INDEX(bdicheq:'informix'.sc_tarjeta ix_tarjeta4)}
				trjasig.num_tarjeta, trjasig.numcte
				INTO cnumtarjeta, cnumCteTarjeta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.cuenta = cnumcuenta
				AND trjasig.numcte != pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')

			INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
			VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

		END FOREACH;
		
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicheq:'informix'.sc_tarjeta idx_sd_tarjeta1)}
				trjasig.num_tarjeta, trjasig.numcte, trjasig.cuenta
				INTO cnumtarjeta, cnumCteTarjeta, cnumcuenta
				FROM bdicheq:'informix'.sc_tarjeta trjasig
				WHERE trjasig.numcte = pnumcte
				AND trjasig.tipo_tarjeta IN ('T','A')
				

				INSERT INTO 'informix'.tbl_tarjetascliente(numtarjeta, cuenta, numcte)
				VALUES (cnumtarjeta, cnumcuenta, cnumCteTarjeta);

			--En caso de que se encuentre una tarjeta a la que el cliente es adicional, se debe consultar su titular y los datos de la cuenta de debito relacionada
			SELECT count(*) INTO cExisteCta FROM 'informix'.tbl_cuentascliente WHERE cuenta = cnumcuenta;
			IF cExisteCta = 0 THEN
				
				FOREACH WITH HOLD
				SELECT {+INDEX(bdicheq:'informix'.sc_maechq idx_sc_maechq)} cta.num_cte, cta.producto, cta.status_cta, 'D', cta.cuenta
				INTO cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux
				FROM bdicheq:'informix'.sc_maechq cta WHERE cta.cuenta = cnumcuenta AND producto = '2400'
				
					INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
					VALUES( cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux );
					
				END FOREACH;
				
			END IF;

	END FOREACH;
	
	
	

	FOREACH WITH HOLD 
	SELECT DISTINCT(cuenta)
	INTO cnumcuenta
	FROM 'informix'.tbl_cuentascliente WHERE tipotar = 'C'
	
		--Se llena tabla de paso con tarjetas de debito del cliente y de los credito que tienen cuentas relacionadas al cliente titulares o adicionales
		FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta pry_tarjeta)}
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
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
				INSERT INTO 'informix'.tbl_cuentascliente(numcte, producto, statuscta, tipotar, cuenta)
				VALUES(cnumCteTitularCuenta, cproductotar, cstatuscuenta, ctipotar, cnumcuentaAux);
				
				END FOREACH;
				
			END IF;

		END FOREACH;
	END FOREACH;
	
	FOREACH WITH HOLD SELECT {+INDEX(bdicred:'informix'.sd_tarjeta idx_sd_tarjeta1)}
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
				FROM bdicred:'informix'.sd_maecred cta WHERE empresa = pempresa AND cta.num_credito = cnumcuenta AND num_producto IN ('7000', '8100')
				
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

		IF TRIM(ctipotar) = 'D' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicheq:'informix'.sc_mae_estatus ctaest WHERE ctaest.cod_estatus = cstatuscuenta;
		ELIF TRIM(ctipotar) = 'C' THEN
			SELECT ctaest.descripcion INTO cstatuscuentadesc FROM bdicred:'informix'.sd_tipocartera ctaest WHERE ctaest.status_cred = cstatuscuenta;
		END IF;

		LET cnombre1='';
		LET cnombre2='';
		LET paterno='';
		LET materno='';

		FOREACH
			SELECT FIRST 1 s.nombre1,s.nombre2,s.apaterno,s.amaterno
			INTO cnombre1,cnombre2,paterno,materno
			FROM "informix".solicitudtarjeta s INNER JOIN "informix".detalle_maquila d ON (s.idsolicitud = d.idsolicitud)
			WHERE s.numcuenta = cnumcuenta AND d.numtarjeta = cnumtarjeta
			ORDER BY s.fechasolicitud DESC
		END FOREACH
		--ExtracciÃ³n de nombre de tabla alterna
		IF TRIM(NVL(cnombre1,''))='' AND TRIM(NVL(cnombre2,''))='' THEN
			--SELECT s.nombre1,s.nombre2,s.apaterno,s.amaterno
			--INTO cnombre1,cnombre2,paterno,materno
			SELECT s.nombre1, SUBSTRING( TRIM(s.apaterno) FROM 1 FOR ( 20 - char_length(TRIM(s.nombre1)) ) ) AS apaterno
			INTO cnombre1,paterno
			FROM "informix".solicitudtarjeta s INNER JOIN bdicred:"informix".sd_credito_upgrade cu ON (s.numcliente = cu.numcte AND s.numcuenta = cu.num_credito)
			INNER JOIN intercard:"informix".detalle_maquila de ON (s.idsolicitud = de.idsolicitud AND de.numtarjeta = cnumtarjeta)
			WHERE cu.numero_credito_upgrade = cnumcuenta AND cu.numerotarjeta_upgrade = cnumtarjeta;
			
			--IF char_length(TRIM(NVL(cnombre1,'')))<=1 OR char_length(TRIM(NVL(paterno,'')))<=1 THEN	--Se modifica funcion
			IF LENGTH(TRIM(NVL(cnombre1,'')))<=1 OR LENGTH(TRIM(NVL(paterno,'')))<=1 THEN
				SELECT nombre1, SUBSTRING( TRIM(apell_paterno) FROM 1 FOR ( 20 - char_length(TRIM(nombre1)) ) ) AS apaterno
				INTO cnombre1,paterno
				FROM bdinteg:si_cliente WHERE numcte=pnumcte;
			END IF;
		END IF;
		
		IF TRIM(NVL(cnombre1,''))='' THEN
			LET cnombre1='-';
		END IF;
		IF TRIM(NVL(cnombre2,''))='' THEN
			LET cnombre2='-';
		END IF;
		IF TRIM(NVL(paterno,''))='' THEN
			LET paterno='-';
		END IF;
		IF TRIM(NVL(materno,''))='' THEN
			LET materno='-';
		END IF;
		LET cnomcliente = cnombre1||'|'||cnombre2||'|'||paterno||'|'||materno;

		IF cnumtarjeta IS NOT NULL THEN -- TARJETA != 'SIA'
			RETURN ccodret, cnomcliente, cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta WITH RESUME;
                        --DROP TABLE IF EXISTS tbl_cuentascliente;
                        --DROP TABLE IF EXISTS tbl_tarjetascliente;
		END IF;

		LET iExiste = iExiste + 1;

	END FOREACH
	
	DROP TABLE IF EXISTS tbl_cuentascliente;
    DROP TABLE IF EXISTS tbl_tarjetascliente;

	--En caso de que el cliente no tenga ninguna tarjeta
	IF iExiste = 0 THEN
		RETURN '000000001', 'No tiene tarjetas', cnumtarjeta, ctipotar, cestatustar, cproductotar, cnumcuenta, cstatuscuentadesc, ctitular, ccodestatus, cnumCteTitularCuenta, cnumCteTarjeta;
                --DROP TABLE IF EXISTS tbl_cuentascliente;
                --DROP TABLE IF EXISTS tbl_tarjetascliente;
	END IF;

END
END PROCEDURE
DOCUMENT
'OBJETIVO: 	consultar las tarjetas debito platino, credito oro y platino relacionadas al cliente o su cuenta ',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/07/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica la tabla de donde valida el numero de producto',
'AUTOR:		Arturo Astorga',
'FECHA : 	28/09/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el nombre que se rotulara en la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	27/11/2018',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la cuenta',
'AUTOR:		Arturo Astorga',
'FECHA : 	20/02/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	se modifica el sp para que retorne el numero de cliente titular de la tarjeta',
'AUTOR:		Arturo Astorga',
'FECHA : 	23/04/2019',
'SolicitÃ³: jose luis polanco',
'BD : 		intercard',
'OBJETIVO: 	optimizar las consultas para obtencion de la informacion',
'AUTOR:		Elmer Lopez Valenzuela',
'FECHA : 	27/01/2020',
'SolicitÃ³:  jose luis polanco',
'BD : 		intercard';

CREATE PROCEDURE "informix".sp_centinela_rst()
    RETURNING CHAR(5) AS rCodigoRetorno, VARCHAR(160) AS rMensaje, DATETIME YEAR TO FRACTION(3) AS rFechaEjecucion, INTEGER as rTotalTrxs;
    
    DEFINE SQLERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(80);
    DEFINE vCodigoRetorno CHAR(5);
    DEFINE vMensajeRetorno VARCHAR(160);

    DEFINE vTotalTransaccionesMov SMALLINT;
    DEFINE vFechaInicial DATETIME YEAR TO FRACTION(3);
    DEFINE vFechaFinal DATETIME YEAR TO FRACTION(3);
    DEFINE RUTA_UNLOAD VARCHAR(100);
    DEFINE vFecha DATE;
    DEFINE vHora VARCHAR(5);
    DEFINE vTransaccPromedio INTEGER;
    DEFINE vCondBusqHorario VARCHAR(30);
    
    LET vFechaInicial = '';
    LET vFechaFinal = '';
    LET vTotalTransaccionesMov = 0;
    LET vTransaccPromedio = 0;

    LET RUTA_UNLOAD = '/RESPALDOSNEW/';
    LET vCodigoRetorno = '';
    LET vMensajeRetorno = '';
    LET vHora = '';
    LET vFecha = '';
    LET vCondBusqHorario = '';
    
    --SET DEBUG FILE TO RUTA_UNLOAD || "debug_sp_centinela_rst.out";
	--TRACE ON;
    
	BEGIN 

		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            SET DEBUG FILE TO RUTA_UNLOAD || "excepcion_sp_centinela_rst.err.out" WITH APPEND;
            TRACE ON;

            IF ( SQLERR <> 0 ) THEN
            LET vCodigoRetorno = SQLERR;
            LET vMensajeRetorno = ERROR_INFO;
            RETURN vCodigoRetorno, vMensajeRetorno, vFechaFinal, vTotalTransaccionesMov;
            END IF;

		END EXCEPTION;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		
		SELECT ( DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND ) - 30 units minute,
                DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND
            INTO vFechaInicial, vFechaFinal
        FROM sysmaster:"informix".sysshmvals;

        SELECT LIMIT 1 cr_cobrado_fecha::date as fecha, 
                TO_CHAR( EXTEND(cr_cobrado_fecha, HOUR TO HOUR), '%H:%M') as hora, 
                    COUNT(*) as total_trxs
            INTO vFecha, vHora, vTotalTransaccionesMov
        FROM bdirst:"informix".claves_retiro
            WHERE cr_cobrado_fecha BETWEEN vFechaInicial AND vFechaFinal
                AND cr_status = 'C'
        GROUP BY 1, 2;
        
        LET vCodigoRetorno = '00000';
		LET vMensajeRetorno = 'Transaccionalidad correcta.';
        
        IF ( vHora IN ('00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00' ) ) THEN
            LET vCondBusqHorario = 'rst_horario_a';
        END IF

        IF ( vHora IN ('09:00','10:00') ) THEN
            LET vCondBusqHorario = 'rst_horario_b';
        END IF
        
        IF ( vHora IN ('11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00' ) ) THEN
            LET vCondBusqHorario = 'rst_horario_c';
            
        END IF
        
        IF ( vHora IN ('21:00','22:00','23:00') ) THEN
            LET vCondBusqHorario = 'rst_horario_d';
        END IF
        
        SELECT valores 
            INTO vTransaccPromedio
        FROM intercard:"informix".tbl_inter_parametros
            WHERE cond_busqueda = vCondBusqHorario;
            
        IF ( vTotalTransaccionesMov > vTransaccPromedio ) THEN
            LET vCodigoRetorno = '00001';
            LET vMensajeRetorno = 'Promedio mayor a '||vTotalTransaccionesMov || ' transacciones.';
        END IF

        RETURN vCodigoRetorno, vMensajeRetorno, vFechaFinal, NVL(vTotalTransaccionesMov,0);

    END

END PROCEDURE
DOCUMENT
'Armando García Ortiz',
'Gerencia I. Coord. Admón Tarjetas',
'BD...intercard',
'Descripcion: Consulta de OTPs cobradas y validacion de transacciones promedio.',
'Si las transacciones son mayores a los promedios configurables el codigo de retorno es 00001 para enviar un SMS'
;

CREATE PROCEDURE "informix".sp_stock_tjts_sucursales()
---ASIGNACION DE NOMBRE A LAS VARIABLRES DE RETORNO.
RETURNING VARCHAR(5) AS CODIGO_RETORNO, VARCHAR (50) AS MENSAJE_RETORNO;
	
	--Definicion de variables
    DEFINE  codigo_retorno      CHAR(5);				
	DEFINE  mensaje_retorno     CHAR(50);
	DEFINE	rpt_fecha			CHAR(8);
    DEFINE  sfecha_hoy			DATE; 
    DEFINE	TIPO_PLANTILLA 		VARCHAR(20);   
	DEFINE	RUTA_DESTINO 		VARCHAR(80);
	DEFINE	vsql				CHAR(1150);
	DEFINE SQLERR		INTEGER;
	DEFINE ISAM_ERR		INTEGER;
	DEFINE ERROR_INFO	VARCHAR(80);  
	
	DEFINE vclave_sucursal  VARCHAR(5);
	DEFINE vclave_tipotarjeta INTEGER;
	DEFINE vproducto          VARCHAR(7);
	DEFINE vexistentes        INTEGER;
	DEFINE vsolicitadas       INTEGER;
	DEFINE vdescripcion       VARCHAR(28);
	--new
	DEFINE vConteo             INTEGER;
	DEFINE vcommit  varchar(50);
	DEFINE vempresa CHAR(3);
	DEFINE vclave_sucursal1    VARCHAR(5);
	DEFINE vclave_tipotarjeta1 INTEGER;
	DEFINE vtipo         CHAR(1); 
	DEFINE vproducto1    VARCHAR(7);
	DEFINE vestatus      CHAR(10);
	DEFINE vdescripcion1 CHAR(40);
	DEFINE vcodstatustarjeta CHAR(3);
	DEFINE vtotal INTEGER;
	DEFINE vsFlagEnTransaccion VARCHAR(1);
 
    LET RUTA_DESTINO	 = '/RESPALDOSNEW/';
	LET TIPO_PLANTILLA	 = 'Inventario_suc';
	--Asignacion de valores a las variables de retorno
    LET rpt_fecha='';
    LET codigo_retorno = '00000';
    LET mensaje_retorno = 'PROCESO EXITOSO';
    LET	vclave_sucursal = '';
	LET vclave_tipotarjeta = 0;
	LET vproducto          = '';
	LET vexistentes  = 0;
	LET vsolicitadas = 0;
	LET vdescripcion = '';
	--new
    LET vConteo  = 0;
	LET vcommit = '';
	LET vempresa  = '';
	LET vclave_sucursal1    = '';
	LET vclave_tipotarjeta1 = 0;
	LET vtipo         = '';
	LET vproducto1    = '';
	LET vestatus     = '';
	LET vdescripcion1 = '';
	LET vcodstatustarjeta = '';
    LET vtotal = 0; 
	LET vsFlagEnTransaccion = 'F';

     --SET DEBUG FILE TO RUTA_DESTINO || "sp_stock_tjts_sucursales.out";
     --TRACE ON;        
	
    BEGIN 
		
        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO

            SET DEBUG FILE TO RUTA_DESTINO || "excepcion_sp_stock_tjts_sucursales.out"  WITH APPEND;
            TRACE ON;
            
            IF ( SQLERR <> 0 ) THEN
                LET CODIGO_RETORNO = SQLERR;
                LET MENSAJE_RETORNO = ERROR_INFO;                
                RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;
 

	    SET ISOLATION TO DIRTY READ; 
	    SET LOCK MODE TO WAIT 3;
	
	    SELECT valores INTO vcommit FROM "informix".tbl_inter_parametros where cond_busqueda = 'Commits_N1';
	
	
		SELECT fecha_hoy  INTO  sfecha_hoy FROM bdinteg:si_fechas WHERE empresa='001';    
        LET rpt_fecha = LPAD(DAY(sfecha_hoy),2,'0')||LPAD(MONTH(sfecha_hoy),2, '0')||YEAR(sfecha_hoy);
		
		--LET rpt_fecha = substr (sfecha_hoy, 4,2)||substr (sfecha_hoy, 0,2)||substr (sfecha_hoy, 7,4);  
		 
		-- NEW
		   TRUNCATE TABLE "informix".tbl_paso_inventario_suc  DROP STORAGE;   
		   TRUNCATE TABLE "informix".sucursales_base_tmp      DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp2      DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp_noa   DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_tmp_noe   DROP STORAGE;   
		   TRUNCATE TABLE "informix".inventario_suc_final     DROP STORAGE;  
	 
	 foreach cur_F1_main WITH hold for
          ---1) query principal
		 select 
        --'001' as empresa, 
        lot.clave_sucursal as clave_sucursal,
        lot.clave_tipotarjeta,
        tt.tipo as tipo,
        case when tt.tipo = 'C' then 'CREDITO' 
        when tt.tipo ='D' then  'DEBITO' end as producto,
        tjt.codstatusasignada as estatus,
        tt.descripcion,
        tjt.codstatustarjeta as codstatustarjeta
		INTO 
		--vempresa,
		vclave_sucursal1,
		vclave_tipotarjeta1,
		vtipo,
		vproducto1,
		vestatus,
		vdescripcion1,
		vcodstatustarjeta
        from tarjeta tjt 
        inner join lote lot on tjt.numerolote = lot.numerolote 
        inner join tipotarjeta tt on lot.clave_tipotarjeta = tt.clave_tipotarjeta
        where 
		 tt.chip in ('F','V') 
        AND tjt.codstatusasignada in ('NOE','NOA')  
        AND tjt.codstatustarjeta = 'INA'
        AND lot.tipoenvio = 'S'
		ORDER BY clave_sucursal
         
		 
            IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
			 
			    INSERT INTO "informix".tbl_paso_inventario_suc  
				 values ('001',vclave_sucursal1,vclave_tipotarjeta1,vtipo,vproducto1,vestatus,vdescripcion1,vcodstatustarjeta);

				  LET vConteo = vConteo +1;  
													 
					  IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                   END IF;
			
    end foreach;
        --TRACE 'T2_'|| vConteo;
		
				   IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".tbl_paso_inventario_suc;    
		-----------------------
		
        --2   generacion de sucursales base con las que trabajar
         LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtipo = '';
		 LET vdescripcion = '';
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
		
		foreach cur_F2_suc WITH hold for
		
		    Select 
			distinct clave_sucursal,
		    producto,
		    clave_tipotarjeta,
			tipo,
			descripcion
            INTO vclave_sucursal,vproducto,vclave_tipotarjeta,vtipo,vdescripcion
			from tbl_paso_inventario_suc
		    where empresa = '001' 
            AND tipo IN ('C', 'D')
			order by clave_sucursal
   
		     IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
		   
		   	INSERT INTO "informix".sucursales_base_tmp  (clave_sucursal,producto,clave_tipotarjeta,tipo,descripcion)
		    VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtipo,vdescripcion);
			
				  LET vConteo = vConteo +1;  
													 
				    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                    END IF;
			
        end foreach; 

				   IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".sucursales_base_tmp;   		
		--------------------------
 
         LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vestatus = '';
		 LET vclave_tipotarjeta = '';
		 LET vdescripcion = '';
		 LET vtotal = 0; 
 		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --3   Agrupacion por sucursal y stock 
		 foreach cur_F3_stock WITH hold for
		 
             select clave_sucursal,producto,estatus, clave_tipotarjeta,descripcion,count(*) as total 
             INTO vclave_sucursal,vproducto,vestatus,vclave_tipotarjeta,vdescripcion,vtotal 
		     from tbl_paso_inventario_suc
              group by 1,2,3,4,5
              order by clave_sucursal
			  
			 IF (vsFlagEnTransaccion = 'F') THEN
                 BEGIN WORK;
			   --TRACE 'T0_'|| vConteo;
                 LET vsFlagEnTransaccion = 'V';
             END IF;
           
		    INSERT INTO "informix".inventario_suc_tmp2  (clave_sucursal,producto,estatus,clave_tipotarjeta,descripcion,total)
		    VALUES  (vclave_sucursal,vproducto,vestatus,vclave_tipotarjeta,vdescripcion,vtotal);
			
			  LET vConteo = vConteo +1;  
													 
			    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                END IF;
 
         end foreach;  
		 
		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp2;   
		-------------------------
	     LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtotal = 0; 
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --4   agrupacion de existentes por sucursal
		foreach cur_F4_noa WITH hold for
                 Select clave_sucursal,producto,clave_tipotarjeta, total as total_noa 
				 INTO  vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal
				 from inventario_suc_tmp2  
                 where estatus = 'NOA'
				 order by clave_sucursal 
			   
			    IF (vsFlagEnTransaccion = 'F') THEN
                    BEGIN WORK;
			        --TRACE 'T0_'|| vConteo;
                     LET vsFlagEnTransaccion = 'V';
                END IF;
 
 		        INSERT INTO "informix".inventario_suc_tmp_noa  ( clave_sucursal,producto,clave_tipotarjeta, total_noa )
		        VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal);
   
   				  LET vConteo = vConteo +1;  
													 
					  IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                   END IF;
  
		 end foreach;  
		 
		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp_noa;  
			--------------------------
		 LET vclave_sucursal = '';
		 LET vproducto = '';
		 LET vclave_tipotarjeta = '';
		 LET vtotal = 0; 
		 LET vConteo = 0; 
		 LET vsFlagEnTransaccion = 'F';
        --5  agrupacion de solicitadas por sucursal
		    foreach cur_F5_noa WITH hold for 
                      Select clave_sucursal,producto,clave_tipotarjeta, total as total_noe  
		              INTO vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal
					  from inventario_suc_tmp2  
                      where estatus = 'NOE'
					  order by clave_sucursal
                   
				   	   IF (vsFlagEnTransaccion = 'F') THEN
                           BEGIN WORK;
			               --TRACE 'T0_'|| vConteo;
                           LET vsFlagEnTransaccion = 'V';
                        END IF;
 
					  INSERT INTO "informix".inventario_suc_tmp_noe  ( clave_sucursal,producto,clave_tipotarjeta, total_noe )
		              VALUES  (vclave_sucursal,vproducto,vclave_tipotarjeta,vtotal);  
					  
					    LET vConteo = vConteo +1;  
													 
					    IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                        END IF;
					  
		    end foreach; 
 
 		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_tmp_noe;  
           -------
			LET vclave_sucursal= '';
			LET vclave_tipotarjeta = '';
			LET vproducto = '';
			LET vexistentes = 0;
			LET vsolicitadas = 0;
			LET vdescripcion = '';
		    LET vConteo = 0; 
		    LET vsFlagEnTransaccion = 'F';
			
       --6  concentrado final 
           foreach cur_F6_fin WITH hold for

            Select suc.clave_sucursal, 
            suc.clave_tipotarjeta, 
            suc.producto,
            NVL(total_noa,'0') as existentes, 
            NVL(total_noe,'0') as solicitadas, 
            TRIM(suc.descripcion) 
			INTO  vclave_sucursal,vclave_tipotarjeta,vproducto,vexistentes,vsolicitadas,vdescripcion
            from sucursales_base_tmp as suc
            LEFT JOIN  inventario_suc_tmp_noa as noa ON suc.clave_sucursal = noa.clave_sucursal and suc.clave_tipotarjeta = noa.clave_tipotarjeta
            LEFT JOIN  inventario_suc_tmp_noe as noe ON suc.clave_sucursal = noe.clave_sucursal and suc.clave_tipotarjeta = noe.clave_tipotarjeta
           	order by clave_sucursal  		

  			IF (vsFlagEnTransaccion = 'F') THEN
                  BEGIN WORK;
			      --TRACE 'T0_'|| vConteo;
                  LET vsFlagEnTransaccion = 'V';
            END IF;
					
		    INSERT INTO "informix".inventario_suc_final  (clave_sucursal,clave_tipotarjeta,producto,existentes,solicitadas,descripcion)
		    VALUES  (vclave_sucursal,vclave_tipotarjeta,vproducto,vexistentes,vsolicitadas,vdescripcion);
		   
		     LET vConteo = vConteo +1;  
													 
				IF (vConteo >= vcommit) THEN    
                           COMMIT WORK;
							--TRACE 'T1_'|| vConteo;
                            LET vConteo = 0;
                            LET vsFlagEnTransaccion = 'F';                
                           CONTINUE FOREACH;
                END IF;
		   
		    end foreach;  
  
   		 		    IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN
                      COMMIT WORK;
                        LET vsFlagEnTransaccion = 'F';
                    END IF; 
  
           UPDATE STATISTICS MEDIUM FOR TABLE "informix".inventario_suc_final;  
  
            -----------------------------------------------------------------------------------------------------------------
			--Elimina reportes anteriores
	        let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||TIPO_PLANTILLA||'*';
            system vsql;
           ----------------------------------------------------------------------------------------------------------------- 
		    let vsql = ''; 	   
		    let vsql = 'echo "clave_sucursal|clave_tipotarjeta|producto|existentes|solicitadas|descripcion|">'||RUTA_DESTINO||TIPO_PLANTILLA||'_'||rpt_fecha||'.txt';  
		    system vsql;
           -----------------------------------------------------------------------------------------------------------------
            let vsql = '';
            let vsql = ' echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_DESTINO ||'inventario_base_'||rpt_fecha||'.txt '||
                      ' SELECT  * FROM   intercard:inventario_suc_final order by 1,2 asc;">'||RUTA_DESTINO||'script_inventario.sql';  
            system vsql;	
            -----------------------------------------------------------------------------------------------------------------	
			---Asigancion de permisos del archivo .sql
			let vsql ='';			
			let vsql= 'chmod 777 ' ||RUTA_DESTINO||'script_inventario.sql';
			system vsql;
		    
		    let vsql = '';
            let vsql = 'dbaccess intercard '||RUTA_DESTINO||'script_inventario.sql';
            system vsql;	
			-----------------------------------------------------------------------------------------------------------------
		    --Resultado del unload se complementa con el encabezado del reporte
			let vsql ='';
            let vsql = "sed 's/|s//g' "||RUTA_DESTINO||'inventario_base_'||rpt_fecha||".txt >> "||RUTA_DESTINO||TIPO_PLANTILLA||'_'||rpt_fecha||".txt";
            system vsql;
 
			-----------------------------------------------------------------------------------------------------------------
			--eliminaciÃ³n de archivos
			let vsql = '';
            let vsql ='rm -f '||RUTA_DESTINO||'script_inventario.sql';
            system vsql;
		 
		    let vsql = '';
			let vsql ='rm -f '||RUTA_DESTINO||'inventario_base_'||rpt_fecha||'.txt';  
			system vsql;
		 		   
          ------------------------------------------------------------------------------------------------------------------------
      
    RETURN 	CODIGO_RETORNO, MENSAJE_RETORNO;


END;
END PROCEDURE
---CoordinaciÃ³n de Tarjetas e Interfaces Transaccionales | Gerencia Mantenimiento I
---Autor: Marcos Gerardo Ayala Ponce
---Fecha de creacion: 21 de septiembre del 2021
---Base de datos: intercard
---Este proceso corresponde al job 828
----EXECUTE PROCEDURE "informix".sp_stock_tjts_sucursales();
;

CREATE PROCEDURE "informix".sp_tarj_det_vcas_exp()
    RETURNING VARCHAR(10), VARCHAR(255)

    DEFINE vfecha DATETIME YEAR TO FRACTION(5);
    DEFINE vfechaTime DATETIME YEAR TO FRACTION(5);


    DEFINE vstatus_proc 	CHAR(1);
    DEFINE vcod_ret         VARCHAR(10);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE error_info       CHAR(40);

    DEFINE v_dia         	CHAR(2);
    DEFINE v_mes         	CHAR(2);
    DEFINE v_ano         	CHAR(4);
    DEFINE v_hora 			DATETIME HOUR TO SECOND;
    DEFINE v_hora2 			CHAR(8);
    DEFINE v_sql         	CHAR(250);
    DEFINE cEncabezado   	CHAR(250);

    DEFINE cRuta 			CHAR(250);
    DEFINE cRuta2 			CHAR(250);
    DEFINE cNombreArchivo 	CHAR(250);
    DEFINE cNombreArchivo1 	CHAR(250);
    DEFINE cNombreArchivo2 	CHAR(250);

    DEFINE var_action 		CHAR(6);
    DEFINE var_numtarjeta   VARCHAR(16);
    DEFINE var_telefono     CHAR(13);
    DEFINE var_correo_elec 	CHAR(100);
    DEFINE var_fecha        DATETIME YEAR to SECOND;

    DEFINE iContador_pay    SMALLINT;
    DEFINE vreg_ins INTEGER;

    --MANEJO DEL ERROR.
    ON EXCEPTION SET sql_err, isam_err, error_info
            
        SET DEBUG FILE TO "/RESPALDOSNEW/exc_sp_tarj_det_vcas.err.out" WITH APPEND;
        TRACE ON;
        
        UPDATE intercard:ctrl_info_ctes_vcas
        SET status_proc = '0';

        IF sql_err <> 0 THEN
            LET vcod_ret=sql_err;
            UPDATE intercard:ctrl_info_ctes_vcas
            SET(cod_err, descripcion_err) = (vcod_ret, isam_err||' ' ||error_info);
            RETURN vcod_ret, isam_err||' ' ||error_info;
        END IF;
    END EXCEPTION;

        SET DEBUG FILE TO "/RESPALDOSNEW/sp_tarj_det_vcas.out";
        TRACE ON;

    LET vfecha = TODAY;
    LET vfechaTime = TODAY;
    LET vstatus_proc = '';

    LET vcod_ret = '000';          
    LET sql_err = 0;          
    LET isam_err = 0;        
    LET error_info = '';
    LET iContador_pay = 0;

    LET v_dia           = "";
    LET v_mes           = "";
    LET v_ano           = "";  
    LET v_hora 			= CURRENT;
    LET v_hora2 		= "";
    LET v_sql           = "";

    LET cEncabezado     = "";
    LET cRuta 			= "/tmp/";
    LET cRuta2 			= "/RESPALDOSNEW/VCAS_resultados/";
    LET cNombreArchivo 	= "";
    LET cNombreArchivo1 = "";
    LET cNombreArchivo2 = "";

    LET var_action 		= "";
    LET var_numtarjeta  = "";
    LET var_telefono    = "";
    LET var_correo_elec = "";
    LET var_fecha       = CURRENT;
    LET vreg_ins 		= 0;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
     
    SELECT status_proc
        INTO vstatus_proc
    FROM intercard:ctrl_info_ctes_vcas;

    IF(vstatus_proc = '1') THEN
            UPDATE intercard:ctrl_info_ctes_vcas
            SET(cod_err, descripcion_err) = (vcod_ret, 'DESCARGA EN PROCESO');
        
        RETURN vcod_ret, 'DESCARGA EN PROCESO';
    END IF;
   
    UPDATE intercard:ctrl_info_ctes_vcas SET status_proc = '1';  
 
    SELECT fecha, fecha  - 1 units hour
        INTO vfecha, vfechaTime
    FROM intercard:ctrl_info_ctes_vcas;

-- ELIMINA REGISTROS DE TABLA DE RESULTADOS EN CASO DE QUE HAYA FALLADO EL SP Y HAYA GENERADO INFORMACION.
   
   TRUNCATE TABLE intercard:ctas_vcas;

  -- CREAR TEMPORALES PARA RESULTADO FINAL
    SELECT numtarjeta, fechaasignacion
    FROM intercard:info_tarjeta_pyt
    WHERE codstatustarjeta = 'ACT'
    AND fechaasignacion >= vfecha
    INTO temp tmptarj with no log;

    CREATE INDEX "informix".tmp_tartarj_vcas ON tmptarj(numtarjeta) ONLINE;
    
    /*
	SELECT bin
	FROM intercard:bines WHERE (marca  = 'VS' or bin in (510148, 554948 ,559471)) --
	INTO temp BIN_VISA with no log;
    */
    SELECT bin 
        FROM intercard:bines 
            WHERE bin IN ('400819', '426807', '559471', '554948', '510148', '416916')
    INTO TEMP BIN_VISA WITH NO LOG;

    CREATE INDEX "informix".tmp_bin_visa ON BIN_VISA(bin) ONLINE;
    
    --TARJETAS DE CREDITO
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta)
    INTO temp tmpctestarj with no log;

    CREATE INDEX "informix".tmp_cte_pt ON tmpctestarj(numcte,num_tarjeta) ONLINE;

    -- CREATE INDEX "informix".tmp_tarj_pt ON tmpctestarj(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO
    INSERT INTO tmpctestarj
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND num_tarjeta IN (SELECT numtarjeta FROM tmptarj GROUP BY numtarjeta);

    -- TABLA TELEONOS TIPO 2
	SELECT telefono, numcte, status_tel, fecha_hora
    FROM bdinteg:si_telefonos_actual
    --WHERE (tipo_tel = 2 and  fecha_hora >=vfecha) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))
	WHERE ((fecha_hora >=vfechaTime) or (numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1))) and tipo_tel = 2
    INTO temp tmptelefono_tipo2 with no log;

    CREATE INDEX "informix".tmptelefono_tipo2_idx1  ON tmptelefono_tipo2(status_tel,fecha_hora) ONLINE;
    --CREATE INDEX "informix".tmptelefono_tipo2_idx2  ON tmptelefono_tipo2(numcte) ONLINE;


    --TEMPORAL DE TELEONOS
	SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE status_tel = 'A' and fecha_hora >= vfechaTime
    GROUP BY telefono, numcte
    UNION
    SELECT telefono, numcte
    FROM tmptelefono_tipo2 WHERE numcte IN (SELECT numcte FROM tmpctestarj WHERE 1=1) AND status_tel = 'A'
    GROUP BY telefono, numcte
    INTO temp tmptelefono with no log;

    CREATE INDEX "informix".tmptelefono_idx1 ON tmptelefono(numcte,telefono) ONLINE;
    --CREATE INDEX "informix".tmptelefono_idx2 ON tmptelefono(numcte) ONLINE;


    -- TABLA CORREOS  TIPO 1
	SELECT tipo_correo, status_correo, secuencia, valido, numcte, correo_elec, fecha_hora
    FROM bdinteg:si_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1 AND C.fecha_hora >= vfechaTime
	INTO temp tmpsi_correos with no log;

	--CREATE INDEX "informix".tmpsi_correos_idx1 ON tmpsi_correos(tipo_correo,status_correo,fecha_hora, valido);
	CREATE INDEX "informix".tmpsi_correos_idx2 ON tmpsi_correos(numcte,tipo_correo,status_correo,valido);

	--TEMPORAL DE CORREOS

	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE numcte IN  (SELECT numcte FROM tmpctestarj WHERE 1=1)
	AND C.tipo_correo = 1 AND C.status_correo = 'A' AND C.valido = 1
    GROUP BY correo_elec, numcte
	UNION
	SELECT correo_elec, numcte
    FROM bdinteg:tmpsi_correos C
    WHERE C.tipo_correo = 1 AND C.status_correo = 'A' AND fecha_hora >= vfechaTime AND C.valido = 1
	GROUP BY correo_elec, numcte
	INTO temp tmpcorreo with no log;

    CREATE INDEX "informix".tmp_correlec_vcas ON tmpcorreo(numcte,correo_elec) ONLINE;
    --CREATE INDEX "informix".tmp_numctecorr_vcas ON tmpcorreo(numcte) ONLINE;

   --TARJETAS DE CREDITO CTES
    SELECT numcte,num_tarjeta
    FROM bdicred:sd_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono)
    INTO temp tmpctestarjfin with no log;

    CREATE INDEX "informix".tmp_cte_pts ON tmpctestarjfin(numcte,num_tarjeta) ONLINE;
	--CREATE INDEX "informix".tmp_tarj_pts ON tmpctestarjfin(num_tarjeta) ONLINE;

    --TARJETAS DE DEBITO CTES
    INSERT INTO tmpctestarjfin
    SELECT numcte, num_tarjeta
    FROM bdicheq:sc_tarjeta
    WHERE empresa= '001' AND numcte IN (SELECT numcte FROM tmpcorreo UNION ALL SELECT numcte FROM tmptelefono);

	--CTES CON TARJETAS ACTUALIZADAS
    SELECT numtarjeta, A.fechaasignacion, B.numcte
    FROM intercard:info_tarjeta_pyt A, tmpctestarjfin B
    WHERE A.numtarjeta=B.num_tarjeta AND codstatustarjeta = 'ACT'
    GROUP BY A.numtarjeta, A.fechaasignacion, B.numcte
    INTO temp tmptarjeta with no log;

    CREATE INDEX "informix".tmp_numtarj_vcas ON tmptarjeta(numcte,numtarjeta) ONLINE;
    --CREATE INDEX "informix".tmp_numclient_vcas ON tmptarjeta(numcte) ONLINE;
    CREATE INDEX "informix".tmp_fechasig_vcas ON tmptarjeta(fechaasignacion) ONLINE;
   
-- INFORMACION QUE SE EJECUTARA CADA DETERMINADO TIEMPO.
    BEGIN WORK;
        FOREACH WITH HOLD
            SELECT 
                CASE 
                    WHEN A.fechaasignacion >= vfecha THEN 'ADD' ELSE 'UPDATE' END 
                AS action,
                A.numtarjeta,B.telefono AS telefono,
                C.correo_elec AS correo_elec,
                CURRENT AS fecha
                INTO var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha
            FROM tmptarjeta A
                LEFT JOIN tmptelefono B ON A.numcte=B.numcte
                LEFT JOIN tmpcorreo C ON A.numcte=C.numcte
            WHERE SUBSTR(A.numtarjeta,1,6) IN (SELECT bin FROM BIN_VISA )
            AND((B.telefono IS NOT NULL)OR(C.correo_elec IS NOT NULL))            
            GROUP BY A.numtarjeta, B.telefono, C.correo_elec,fecha,action

            LET iContador_pay = iContador_pay + 1;

            INSERT INTO "informix".ctas_vcas(action, numtarjeta, telefono, correo_elec, fecha)
            VALUES(var_action, var_numtarjeta, var_telefono, var_correo_elec, var_fecha);
               
            IF iContador_pay = 1000 THEN
                COMMIT;
                LET iContador_pay = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_vcas;
                BEGIN WORK;
            END IF;
        END FOREACH;
    COMMIT;

        UPDATE STATISTICS MEDIUM FOR TABLE "informix".ctas_vcas;
    
	-- DESCARGAR ARCHIVO.
	LET v_dia = LPAD(DAY(CURRENT),2,'0');  
	LET v_mes = LPAD(MONTH(CURRENT),2,'0');
	LET v_ano = year(CURRENT);
    LET v_hora2 = v_hora::CHAR(8);
	LET cNombreArchivo = TRIM(cRuta2)||'ISSUERNAME'||v_ano||v_mes||v_dia||SUBSTR(v_hora2,1,2)||SUBSTR(v_hora2,4,2)||SUBSTR(v_hora2,7,2)||'.csv';
	LET cNombreArchivo1 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux.csv';
    LET cNombreArchivo2 = TRIM(cRuta)||'ISSUERNAME'||v_ano||v_mes||v_dia||'_aux2.csv';
         
	-- DESCARGA DEL ARCHIVO .CSV.
	LET cEncabezado = 'echo "action,pan,mobilenumber,email,segmentationindicator," > /tmp/queryenc.sql';
    System cEncabezado;

	LET v_sql = 'echo "UNLOAD TO ' || TRIM (cNombreArchivo1) || ' DELIMITER '',''" > /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo "SELECT action,numtarjeta AS pan, ''+52''||RIGHT(LTRIM(RTRIM(telefono)),10) AS mobilenumber," >> /tmp/queryhist.sql ';
	System v_sql;

    LET v_sql = 'echo "LTRIM(RTRIM(correo_elec)) AS email, ''01'' AS segmentationindicator" >> /tmp/queryhist.sql ';
	System v_sql;

	LET v_sql = 'echo " from intercard:ctas_vcas  where numtarjeta <> ''''" >> /tmp/queryhist.sql';
	System v_sql;

	LET v_sql = "dbaccess intercard /tmp/queryhist.sql";
	System v_sql;

	LET v_sql="";

	--SE AÃ?Â?ADEN LOS ENCABEZADOS Y LOS RESULTADOS EXTRAIDOS AL ARCHIVO AUXILIAR.
	LET v_sql = "sed 's/$//g' "|| TRIM(cRuta) || "queryenc.sql >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    LET v_sql="";

	LET v_sql = "sed 's/$//g' "|| TRIM (cNombreArchivo1) || " >> " || TRIM (cNombreArchivo2);
    SYSTEM TRIM(v_sql);

    --SE PASA LA INFORMACION DESCARGADA AL ARCHIVO FINAL.
    LET v_sql = "";
    LET v_sql = "sed -e 's/.$//' "|| TRIM(cNombreArchivo2) || " >> " || TRIM (cNombreArchivo);
    SYSTEM v_sql;

	--BORRADO DE SCRIPTS GENERADOS EN EL PROCESO.
    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryhist.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cRuta) || "queryenc.sql";
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo1);
    SYSTEM TRIM(v_sql);

    LET v_sql = "";
    LET v_sql = "rm " || TRIM(cNombreArchivo2);
    SYSTEM TRIM(v_sql);

	-- DATOS PARA LA TABLA CONTROL.
	SELECT MAX(fecha::DATETIME YEAR TO SECOND + INTERVAL (01) SECOND(2) TO SECOND )
	INTO vfecha
	FROM intercard:ctas_vcas;

	IF  vfecha  IS NULL THEN
		LET vfecha = CURRENT;
	END IF

	-- CONTEO DE REGISTROS.
	SELECT COUNT(*)
	INTO vreg_ins
	FROM intercard:ctas_vcas;

	-- ELIMINA REGISTROS DE TABLA DE RESULTADOS Y TEMPORALES.
    --TRUNCATE TABLE intercard:ctas_vcas;
    TRUNCATE TABLE intercard:ctas_vcas DROP STORAGE;

	DROP TABLE BIN_VISA;
	DROP TABLE tmpctestarj;
    DROP TABLE tmptelefono;
    DROP TABLE tmpcorreo;
	DROP TABLE tmptarjeta;
    DROP TABLE tmptarj;
    DROP TABLE tmpctestarjfin;

	-- ACTUALIZAR TABLA CONTROL.
	UPDATE intercard:ctrl_info_ctes_vcas
	SET ( fecha, status_proc,cod_err, descripcion_err, reg_insertados) = ( vfecha, '0', vcod_ret, 'DESCARGA EXITOSA', vreg_ins);

 
    RETURN vcod_ret, 'DESCARGA EXITOSA';
END PROCEDURE;