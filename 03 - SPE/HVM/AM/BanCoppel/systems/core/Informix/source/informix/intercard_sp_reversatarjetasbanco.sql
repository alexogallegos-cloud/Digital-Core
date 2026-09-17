CREATE PROCEDURE "informix".sp_reversatarjetasbanco(pEmpresa CHAR(3), pSucursal CHAR(4), pLote INTEGER, pTarjetaini CHAR(16), pTarjetafin CHAR(16))
RETURNING CHAR(5) AS codigo_retorno;

	DEFINE cCodRet CHAR(5);
	DEFINE cSucursal CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE dFechapermRecepcion DATE;
	DEFINE dFechaHoy DATE;
	DEFINE iNumeroLote1 INTEGER;
	DEFINE iNumeroLote2 INTEGER;
	DEFINE iClaveTipotarjeta INTEGER;
	DEFINE iSolicitadas INTEGER;
	
	LET cCodRet = '00000';
	LET cSucursal = LPAD(pSucursal,5,'0');
	LET iSqlErr = 0;
	LET dFechapermRecepcion = NULL;
	LET dFechaHoy = NULL;
	LET iNumeroLote1 = 0;
	LET iNumeroLote2 = 0;
	LET iClaveTipotarjeta = 0;
	LET iSolicitadas = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr		
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN TRIM(NVL(cCodRet,''));
			END IF;			
		END EXCEPTION; 	

		--SET DEBUG FILE TO "/informix/christ.OUT";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pSucursal,'')) = '' OR TRIM(NVL(pLote,'')) = '' OR 
		TRIM(NVL(pTarjetaini,'')) = '' OR TRIM(NVL(pTarjetafin,'')) = ''  THEN		
			LET cCodRet = '00001';
		ELSE		
			SELECT a.fechapermrecepcion INTO dFechapermRecepcion 
			FROM intercard:"informix".tipotarjeta a, intercard:"informix".lote b
			WHERE b.numerolote = pLote
			AND a.clave_tipotarjeta = b.clave_tipotarjeta 
			AND CURRENT >= fechapermrecepcion;
			
			SELECT fecha_hoy INTO dFechaHoy FROM bdinteg:"informix".si_fechas WHERE empresa = pEmpresa;
			
			IF dFechaHoy >= dFechapermRecepcion THEN
			
				
				SELECT numerolote,cantidadtarjetassol INTO iNumeroLote1,iSolicitadas
				FROM intercard:"informix".lote
				WHERE numerolote = pLote
				AND clave_sucursal = cSucursal;
			
				
				SELECT DISTINCT(numerolote) INTO iNumeroLote2
				FROM intercard:"informix".tarjeta 
				WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin 
				AND numerolote = pLote;
				
				IF iNumeroLote1 = iNumeroLote2 THEN
				
					SELECT clave_tipotarjeta INTO iClaveTipotarjeta
					FROM intercard:"informix".lote 
					WHERE numerolote = pLote
					AND clave_sucursal = cSucursal;

					IF DBINFO('sqlca.sqlerrd2') > 0 THEN
					
						DELETE FROM intercard:"informix".flujolote
						WHERE numerolote = pLote;

						DELETE FROM intercard:"informix".rangos_lote 
						WHERE numlote = pLote
						AND tarjetaini = pTarjetaini 
						AND tarjetafin = pTarjetafin;
						
						UPDATE intercard:"informix".sucursal_tipotarjeta SET
						solicitadas= solicitadas + iSolicitadas , existencia= existencia - iSolicitadas
						WHERE clave_sucursal = cSucursal 
						AND clave_tipotarjeta = iClaveTipotarjeta;
						
						UPDATE intercard:"informix".tarjeta SET
						codStatusAsignada= 'NOE'
						WHERE numtarjeta >= pTarjetaini AND numtarjeta <= pTarjetafin  AND codStatusAsignada= 'NOA';
			
					ELSE
						LET cCodRet = '00004';
					END IF;				
				ELSE
					LET cCodRet = '00003';
				END IF;				
			ELSE
				LET cCodRet = '00002';
			END IF;			
		END IF;		
		RETURN TRIM(NVL(cCodRet,''));		
	END;
END PROCEDURE
DOCUMENT
'Autor: 97343331 Ismael Lizarraga',
'Folio: 144 - ControlRegistrTarjetasSucursal',
'Fecha: 07-12-2016',
'ModificaciÃ³n: Se crea procedimiento para reversar la recepcion de tarjetas BanCoppel',
'Sustento: 144.1 RQM 06 220 Control y Registro de Tarjetas en Sucursal-Contrato',
'Solicita: Abraham Narvaez',
'Base de datos: Intercard';

CREATE PROCEDURE "informix".sp_depuracion_historica()
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
    
	--  Variables para datos de primary key
	define  vfechacargaini      DATE;
	define  vfechacargafin      DATE;
	define  vfechacargainihora  DATETIME YEAR to FRACTION(5);
	define  vfechacargafinhora  DATETIME YEAR to FRACTION(5);	
	define  vfechahorabase      DATETIME YEAR to FRACTION(5);
	DEFINE   RUTA_ORIGEN  VARCHAR(80);      
    DEFINE vExecuteSQL LVARCHAR(8000);	 
    DEFINE PREFIJO_SCRIPTS CHAR(18);
	DEFINE RUTA_UNLOAD_RESPALDOS VARCHAR(15);
    DEFINE CONTADOR_TRANSACCIONES SMALLINT;

	let     vfechahorabase = '';
    let     vfechacargaini = '';
	let     vfechacargafin = '';
    let     vfechacargainihora  = '';
	let     vfechacargafinhora  = '';
	let     p_cod_ret = '00000';
	let     p_mensaje = 'Proceso Exitoso';

	LET vExecuteSQL = '';
	LET PREFIJO_SCRIPTS = 'movimientohis_resp';
	LET RUTA_UNLOAD_RESPALDOS = '/RESPALDOSNEW/';
    LET CONTADOR_TRANSACCIONES = 1000;
		 
    --LET RUTA_ORIGEN = '/resplogifx/';  -- Alternativa 1  	
	--LET RUTA_ORIGEN = '/pisa/pisabanco/pisa_ftes/syndein/coppel/InterActSW/bin/authorizerj/cron/'; -- Pruebas
      LET RUTA_ORIGEN = '/RESPALDOSNEW/'; 
	 	 
    --SET DEBUG FILE TO RUTA_ORIGEN || "inidep.out";
    --TRACE ON;
 
 BEGIN
 
          ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO RUTA_ORIGEN || "excepcion_sp_depuracion_historica.err.out";
            TRACE ON;
            
            IF ( SQL_ERR <> 0 ) THEN
                LET P_COD_RET = SQL_ERR;
                LET P_MENSAJE = ERROR_INFO;
                 RETURN P_COD_RET, P_MENSAJE;
            END IF;
            
           END EXCEPTION;
--------------------------------------------------------------	
	
SET ISOLATION TO DIRTY READ;	
SET LOCK MODE TO WAIT 3;

        SELECT MIN(fechahorainauth)  
        INTO vfechahorabase
		FROM intercard:"informix".MovimientoHistorico; 
 
 		LET vfechacargainihora = SUBSTRING(vfechahorabase FROM  1 FOR 10) || ' 00:00:00.00000';
		--LET vfechacargafinhora = SUBSTRING(vfechahorabase FROM  1 FOR 10) || ' 10:00:00.00000'; --   Pruebas	 
        LET vfechacargafinhora = SUBSTRING(vfechahorabase FROM  1 FOR 10) || ' 23:59:59.99999'; -- Productivo	 
 
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
 
        LET vExecuteSQL = '';
        LET vExecuteSQL = ' rm -f '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'*';		
        SYSTEM vExecuteSQL;
 
        LET vExecuteSQL  = '';
		LET vExecuteSQL = 'echo "SET ISOLATION DIRTY READ; SET LOCK MODE TO WAIT 3; UNLOAD TO '||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'.unl '  ||         		 
		' SELECT * FROM intercard:movimientohistorico  where fechahorainauth  ' ||
        ' between  ''"'||vfechacargainihora||'"'' and ''"'||vfechacargafinhora||'"'' ;"> '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL;
 
  		LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_unl.sql';
        SYSTEM vExecuteSQL;
        ----------------------
	    -- Ejecuta Shell para la generaciÃ³n del Script con las tarjetas a eliminar. 
        LET vExecuteSQL = ''; 
	    LET vExecuteSQL = 'cd '||RUTA_ORIGEN||''; 		
		SYSTEM vExecuteSQL;
		
		LET  vExecuteSQL = ''; 
		LET  vExecuteSQL = 'chmod 777 gen_depuracion_his.sh';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = ''; 
		LET vExecuteSQL = 'sh gen_depuracion_his.sh';
        SYSTEM vExecuteSQL;
	    ----------------------
		---Elimina los registros de la tabla origen 
		LET vExecuteSQL = '';
        LET vExecuteSQL = ' dbaccess intercard '||RUTA_UNLOAD_RESPALDOS||'delete_depuracion_his.sql';
        SYSTEM vExecuteSQL;				
		---------------------
        --- Genera dbload para la carga de registros a la tabla historica destino
 	    LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "file '"||RUTA_UNLOAD_RESPALDOS||PREFIJO_SCRIPTS||'.unl' || "' delimiter '|' "|| '81'||                          
                          "; INSERT INTO movimientohistorico_dep" || ";"||'"'||' > '||PREFIJO_SCRIPTS||'file_movs.txt';
        SYSTEM vExecuteSQL; 

        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d intercard -c "||PREFIJO_SCRIPTS||"file_movs.txt -l "||PREFIJO_SCRIPTS||"err_tarj_paso.log -n "||CONTADOR_TRANSACCIONES||" -k";
        SYSTEM vExecuteSQL;  
 
  
        RETURN 	P_COD_RET,P_MENSAJE;
 END;

END PROCEDURE;