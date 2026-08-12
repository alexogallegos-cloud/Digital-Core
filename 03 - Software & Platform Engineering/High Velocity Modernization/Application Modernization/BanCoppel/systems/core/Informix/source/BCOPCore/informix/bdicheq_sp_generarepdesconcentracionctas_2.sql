CREATE PROCEDURE "informix".sp_generarepdesconcentracionctas_2(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS archivo_generado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	DEFINE iRegistros INTEGER;
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cReporte CHAR(100);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	LET iRegistros = 0;
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;
	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cReporte = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --		
				END IF;
				
				RETURN cCodRet,cNombreArchivo;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		SET DEBUG FILE TO '/tmp/sp_generarepdesconcentracionctas.out';
		TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE
		LET pRuta = TRIM(pRuta) || '/';
		LET cReporte = 'DESCONCENTRACION_'||TO_CHAR(CURRENT, '%d%m%Y')||'_DETALLE';
		LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.xls';
		LET cNombreArchivo = TRIM(cReporte)||'.xls';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cCmd1 ="";
			LET cCmd1 = "SELECT 'FECHA','FOLIO CSUAC','ASIGNADO A','PRODUCTO','ORIGEN','EVENTO','NO. CLIENTE','NUMERO CUENTA','ESTATUS CORPORATIVO','ESTATUS ANALISIS','NUMERO TARJETA','VENCIMIENTO EN','INDICADOR SEMAFORO','IMPORTE CONCENTRADO','IMPORTE DESCONCENTRADO','RESULTADO','ESTATUS' FROM systables WHERE tabid = 1";	
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT fecha,folio_csuac,asignado_a,producto,UPPER(origen),UPPER(evento),''''||num_cliente,''''||num_cuenta,UPPER(estatus_corp),UPPER(estatus_analisis),''''||num_tarjeta,UPPER(vencimiento_en),UPPER(id_semaforo),importe_conc::CHAR(16),importe_desc::CHAR(16),resultado,estatus";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sw_det_desconcentracionmasiva WHERE usuario_insert = '"||pUsuario||"' ORDER BY id_registro ASC);";
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)|| ' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicheq '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 15/01/2019',
'MODULO: TRANSACCIONES',
'FUNCIONALIDAD: DESCONCENTRACIÓN DE CUENTAS CARGA MASIVA',
'DESCRIPCION: SPL encargado de generar el reporte con el detalle de las cuentas de desconcentración.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_generarepdesconcentracionctas(pUsuario CHAR(8), pIdFuncion CHAR(10), pRuta CHAR(100))
    RETURNING CHAR(5) AS codRet,
		CHAR(100) AS archivo_generado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INT;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescCodRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE iIdRegistro INTEGER;
	
	DEFINE iSerial INTEGER;
	DEFINE cRespMensaje CHAR(45);
	DEFINE iRegistros INTEGER;
	DEFINE cQuery CHAR(255);
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cRutaInformix CHAR(100);
	DEFINE cUsrBin CHAR(100);
	DEFINE iCountRep INTEGER;
	DEFINE iProcesaRep INT;
	DEFINE iArmaReporte INT;
	DEFINE cArchivoCP CHAR(45);
	DEFINE cCmdQuery CHAR(2500);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE cReporte CHAR(100);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cDescCodRet = '';
	LET cEmpresa = '001';
	LET iIdRegistro = 0;
	
	LET iSerial = 0;
	LET cRespMensaje = '';
	LET iRegistros = 0;
	LET cQuery = '';
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cRutaInformix = '/ifxsif01/bin/';
	LET cUsrBin = '/usr/bin/';
	LET iCountRep = 0;
	LET iProcesaRep = 0;
	LET iArmaReporte = 0;
	LET cArchivoCP = '';
	LET cCmdQuery = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET cReporte = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				
				IF ven_transacc = 1 THEN
					ROLLBACK WORK; --		
				END IF;
				
				RETURN cCodRet,cNombreArchivo;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535,-255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/sp_generarepdesconcentracionctas.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRuta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cNombreArchivo;
		END IF;
		
		-- SE DEFINE NOMENCLATURA DEL REPORTE
		LET pRuta = TRIM(pRuta) || '/';
		LET cReporte = 'DESCONCENTRACION_'||TO_CHAR(CURRENT, '%d%m%Y')||'_DETALLE';
		LET cRutaGral = TRIM(pRuta)||TRIM(cReporte)||'.xls';
		LET cNombreArchivo = TRIM(cReporte)||'.xls';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cCmd1 ="";
			LET cCmd1 = "SELECT 'FECHA','FOLIO CSUAC','ASIGNADO A','PRODUCTO','ORIGEN','EVENTO','NO. CLIENTE','NUMERO CUENTA','ESTATUS CORPORATIVO','ESTATUS ANALISIS','NUMERO TARJETA','VENCIMIENTO EN','INDICADOR SEMAFORO','IMPORTE CONCENTRADO','IMPORTE DESCONCENTRADO','RESULTADO','ESTATUS' FROM systables WHERE tabid = 1";	
			LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL SELECT * FROM (SELECT fecha,folio_csuac,asignado_a,producto,UPPER(origen),UPPER(evento),''''||num_cliente,''''||num_cuenta,UPPER(estatus_corp),UPPER(estatus_analisis),''''||num_tarjeta,UPPER(vencimiento_en),UPPER(id_semaforo),importe_conc::CHAR(16),importe_desc::CHAR(16),resultado,estatus";
			LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicheq:""informix"".sw_det_desconcentracionmasiva WHERE usuario_insert = '"||pUsuario||"' ORDER BY id_registro ASC);";
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)|| ' DELIMITER '|| '''	'''|| ' ' ||TRIM(cCmd1)||' " > '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cRutaInformix)||'dbaccess bdicheq '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo query.sql
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(pRuta)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la línea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de línea
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = TRIM(cUsrBin)||'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat León Amador',
'FECHA: 15/01/2019',
'MODULO: TRANSACCIONES',
'FUNCIONALIDAD: DESCONCENTRACIÓN DE CUENTAS CARGA MASIVA',
'DESCRIPCION: SPL encargado de generar el reporte con el detalle de las cuentas de desconcentración.',
'BD: bdicheq';

CREATE PROCEDURE "informix".sp_cons_mov_atm( pempresa char(10), pnum_tarjeta char(16), pterm_id char(10))

RETURNING CHAR(5), CHAR(10), CHAR(40), CHAR(40),CHAR(40),CHAR(40),CHAR(40),CHAR(40);
	
    --VARIABLES DE CONTROL DE ERRORES
    DEFINE iSqlErr		INTEGER;		
    DEFINE vIsamErr		INTEGER;
    DEFINE vpaso		INTEGER;
    DEFINE vErrorInfo	VARCHAR(90);
    
    --VARIABLES DE SALIDA
    DEFINE vCodRet  	CHAR(4);		
    DEFINE vfechamov    CHAR(10);
    DEFINE vreferencia  CHAR(40);
    DEFINE vdescripcion CHAR(50);
    DEFINE vsucursal    CHAR(50);
    DEFINE vtransacc    CHAR(40);
    DEFINE vretiro     	DECIMAL(14,2);
    DEFINE vdeposito    CHAR(40);
    DEFINE vsaldo       CHAR(40);
    DEFINE vmonto       CHAR(40);
    DEFINE vPagoMin     CHAR(40);
    DEFINE vSdoDeudor   CHAR(40);
    DEFINE vIntMora     DECIMAL(14,2);
    DEFINE vIvaIntMora  DECIMAL(14,2);
    
    --VARIABLES DE USO
    DEFINE vempresa     CHAR(10);
    DEFINE vnum_tarjeta	CHAR(16);
    DEFINE vterm_id     CHAR(10);
    DEFINE vnum_cuenta  CHAR(19);
    DEFINE vproducto    CHAR(2);
    DEFINE vciclo      SMALLINT;
    DEFINE vultmovto   SMALLINT;
	
	DEFINE vfecha_hoy	DATE;
	DEFINE vfecha_pmes	DATE;
	DEFINE vano	        varchar (4);
	DEFINE vmes	        varchar (2);
	DEFINE vdia         varchar (2);
	DEFINE vdma         varchar (8);
	DEFINE vdmar		varchar (10);

	DEFINE vano2        varchar (4);
	DEFINE vmes2        varchar (2);
	DEFINE vdia2        varchar (2);
	DEFINE vdma2        varchar (8);
	DEFINE vdmar2		varchar (10);
    
    -- SE INICIALIZA VARIABLES
    let vnum_tarjeta = pnum_tarjeta;
    let vterm_id 	= pterm_id;
    let vCodRet 	= '';
    let vfechamov 	= '';
    let vreferencia = '';
    let vdescripcion= '';
    let vretiro 	= 0;
    let vdeposito 	= 0; 
    let vsaldo 		= 0;
    let vsucursal 	= '';
    LET vtransacc 	= '';
    let vempresa 	= '001';
    LET vmonto      = 0;
    LET vPagoMin    = 0;
    LET vSdoDeudor  = 0;
    LET vIntMora    = 0;
    LET vIvaIntMora = 0;
    LET vciclo     	= 0;
    LET vultmovto  	= 4;
    
    --TRACE
    --SET DEBUG FILE TO "/informix/c98288075/sp_cons_mov_atm.out";
    --TRACE ON; 
    
    --INICIA PROCEDIMIENTO
    BEGIN
    
	ON EXCEPTION SET iSqlErr, vIsamErr
        IF iSqlErr != 0 THEN
            LET vCodRet = iSqlErr;
            RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal;
        END IF;
    END EXCEPTION;
		
		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET vpaso = 0;
    
    --Obtener nÃºmero de cuenta
    SELECT numcuenta 
        INTO vnum_cuenta 
    FROM intercard:tarjetacuenta 
    WHERE numtarjeta  = vnum_tarjeta; 
    
    IF (vnum_cuenta is NULL) THEN
        LET vnum_cuenta = '';
		RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal;
	END IF;
    
	SELECT creditodebito 
      INTO vproducto 
      FROM intercard:bines 
     WHERE SUBSTR(vnum_tarjeta,1,6) = bin;
    
    LET vpaso = 1;
    --Si es crÃ©dito		
		
		IF( vproducto = 'C') THEN 
			FOREACH
				EXECUTE PROCEDURE bdicred:consultmovs(vempresa,vnum_cuenta,'') 
				INTO vCodRet, vfechamov, vtransacc, vmonto, vPagoMin, vSdoDeudor, vIntMora, vIvaIntMora
				 RETURN vCodRet, vfechamov, SUBSTR(vtransacc,6,30), vmonto, vPagoMin, vSdoDeudor, vIntMora, vIvaIntMora WITH RESUME;
			END FOREACH;
		END IF;
    
    --Si es dÃ©bito
		
		IF( vproducto = 'D') THEN 
			
			SELECT fecha_hoy, pri_dia_mes INTO vfecha_hoy, vfecha_pmes 
			FROM bdinteg:si_fechas; 
		
		
			let vano =  SUBSTR(vfecha_hoy,9,2);
			let vmes =  SUBSTR(vfecha_hoy,1,2);
			let vdia =  SUBSTR(vfecha_hoy,4,2);
			let vfecha_hoy = vmes||'-'||vdia||'-'||vano;
			
			let vfecha_pmes = extend (vfecha_pmes - 1 units MONTH) - 0 units day;
			
			let vano2 = SUBSTR(vfecha_pmes,9,2);
			let vmes2 = SUBSTR(vfecha_pmes,1,2);
			let vdia2 = SUBSTR(vfecha_pmes,4,2);
			let vfecha_pmes =  vmes2||'-'||vdia2||'-'||vano2;
			
			
			
			
			FOREACH
				EXECUTE PROCEDURE bdicheq:sp_edoctamovimientos(vempresa, vnum_cuenta, vfecha_pmes, vfecha_hoy,0,'', '') 
				INTO vCodRet, vfechamov, vreferencia, vdescripcion, vretiro, vdeposito, vsaldo, vsucursal
				
			   RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal WITH RESUME;
				
				LET vciclo = vciclo+1;
				IF vciclo > vultmovto THEN
					EXIT FOREACH;
				END IF	
			END FOREACH;

		--	Si los SPL no regresan valores
			
			IF (vCodRet = '') THEN
				LET vCodRet = '777';
					RETURN vCodRet, vfechamov, vreferencia, vdescripcion, vdeposito,vretiro, vsaldo, vsucursal;
			END IF;


		END IF;
    END;
	
END PROCEDURE;