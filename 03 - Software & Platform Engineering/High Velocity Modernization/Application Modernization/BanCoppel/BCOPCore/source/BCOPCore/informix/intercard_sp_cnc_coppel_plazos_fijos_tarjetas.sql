CREATE PROCEDURE "informix".sp_cnc_coppel_plazos_fijos_tarjetas()
RETURNING VARCHAR(5) AS rCodigoRetorno, VARCHAR(160) AS mensaje;
 
    
    DEFINE RUTA								VARCHAR(100);
--ARCHIVOS	
    DEFINE NOMBRE_ARCHIVODET				VARCHAR(35);
	DEFINE NOMBRE_ARCHIVO_CARATULA			VARCHAR(50);
	DEFINE ARCHIVO_UNL_CONSULTACNC			VARCHAR(35);
	DEFINE ARCHIVO_UNL_CONSULTACTE			VARCHAR(35);
	DEFINE ARCHIVO_UNL_ID			        VARCHAR(35);
	DEFINE ARCHIVO_INSERTCNC				VARCHAR(35);
	DEFINE ARCHIVO_INSERTCTE				VARCHAR(35);
    DEFINE ARCHIVO_INSERTID					VARCHAR(35);
	DEFINE SCRIPT_EJECUCION_CONSULTACNC		VARCHAR(35);
	DEFINE SCRIPT_EJECUCION_CONSULTACTE		VARCHAR(35);
	DEFINE SCRIPT_EJECUCION_CONSULTAID		VARCHAR(35);

	DEFINE CONTADOR_TRANSACCIONES   		SMALLINT;
	DEFINE ARCHIVO_ERR    					VARCHAR(35);
	DEFINE ARCHIVO_ERRCTE    				VARCHAR(35);
	
	DEFINE vConsecutivoC          			INTEGER;
	DEFINE vNombrearchivo        			VARCHAR(23);
	DEFINE vArchivo_origen       			CHAR(3);
	DEFINE vFechacarga           			DATETIME YEAR to FRACTION(3);
	DEFINE vNumtarjeta           			VARCHAR(16);
	DEFINE vNumtarjetaC          			VARCHAR(16);
	DEFINE vBan_bin              			VARCHAR(3);
	DEFINE vTipotransaccion325   			VARCHAR(2); 
    DEFINE vTipotransaccion325C   			VARCHAR(2); 
	DEFINE vMonto325             			VARCHAR(13);
	DEFINE vInfreceptor		       			VARCHAR(40);
	DEFINE vDivisa325            			VARCHAR(3);
	DEFINE vSecuenciaC            			VARCHAR(7); 
	DEFINE vSecuencia_extendida  			VARCHAR(15);
	DEFINE vSecuencia_extendidaC  			VARCHAR(15);
	DEFINE vTransactionID  					VARCHAR(23);
	DEFINE vNumcte_coppel					VARCHAR(20);
	DEFINE PREFIJO                          VARCHAR(15);
    DEFINE vIdmovcoppel                     VARCHAR(16);
    DEFINE vExecuteSQL				        LVARCHAR(2000);
    DEFINE SQLERR 					        INTEGER;
    DEFINE ISAM_ERR 				        INTEGER;
    DEFINE ERROR_INFO 				        VARCHAR(80);
--VARIABLES DE RETORNO
	DEFINE vCodigoRetorno                   CHAR(5);
    DEFINE vMensaje		                    VARCHAR(250);
--VARIABLES SP
	DEFINE vCommit                          INTEGER;
	DEFINE vFiller1                         CHAR(4);
	--HEADER
	DEFINE  vHeader 				        VARCHAR(7);
	DEFINE  vRelleno1 				        VARCHAR(4);
	DEFINE  vEmpresa 				        VARCHAR(22);
	DEFINE  vReceptor				        VARCHAR(21);
	DEFINE  vFecha 					        VARCHAR(6);
	DEFINE  vFechaTDC 				        VARCHAR(8);
	DEFINE  vRelleno2 				        VARCHAR(13);
	DEFINE  vFechaProceso			        VARCHAR(6);
	DEFINE  vRelleno3 				        VARCHAR(1); 
	DEFINE  vConsecutivo 			        VARCHAR(13);
	DEFINE  vSecuenciaArchivo 		        VARCHAR(6);
	DEFINE  vRelleno4 				        VARCHAR(1); 
	DEFINE  vLeyendaTipoProceso 	        VARCHAR(14);
	DEFINE  vTipoProceso 			        VARCHAR(22);
	DEFINE  vTipoProcesoTot 			    VARCHAR(35);
	
	--BODY
	DEFINE vTransationID			        VARCHAR(23);
	DEFINE vTipoTXN					        VARCHAR(2);
	DEFINE vMonto					        VARCHAR(13);
	DEFINE vSecuenciaextendida		        VARCHAR(23);
	DEFINE vComercio				        VARCHAR(40);
	DEFINE vCliente					        VARCHAR(20);
	DEFINE vSecuencia				        VARCHAR(7);
    DEFINE vImporteOrigen                   VARCHAR(13);
    DEFINE vPosEntrymode                    VARCHAR(2);
    DEFINE vFechaConsumo 	                VARCHAR(40);
    DEFINE vRefTransaccion                  VARCHAR(23);
    DEFINE vAfiCcomercio                    VARCHAR(15);
    DEFINE vGiroComercio                    VARCHAR(4);
    DEFINE vZcodeComercio                   VARCHAR(5);
    DEFINE vPorcentajeComInter              VARCHAR(5);
    DEFINE vImporteComision                 VARCHAR(13);
    DEFINE vBancoReceptor                   VARCHAR(2);
    DEFINE vBancoEmisor                     VARCHAR(4);
    DEFINE vNumAutorizacion                 VARCHAR(7);
    
	--TRAILER
	DEFINE vTotalRegistros			        VARCHAR(8);
	DEFINE vRelleno1T 				        VARCHAR(1);
	DEFINE vRelleno2T 				        VARCHAR(1);
	DEFINE vSumaMonto				        VARCHAR(15);
	DEFINE vRelleno3T 				        VARCHAR(33);
	
	--CARATULA
	DEFINE vSumMontoCompra			        VARCHAR(15);
	DEFINE vSumMontoDev				        VARCHAR(15);
	DEFINE vSumMontoCompraInter			    VARCHAR(15);
	DEFINE vSumMontoDevInter				VARCHAR(15);
	DEFINE vSumMontoPagos				    VARCHAR(15);
	DEFINE vTotalRegistrosCompra	        VARCHAR(8);
	DEFINE vTotalRegistrosCompraInter	    VARCHAR(8);
	DEFINE vTotalRegistrosDev		        VARCHAR(8);
	DEFINE vTotalRegistrosDevInter		    VARCHAR(8);
	DEFINE vTotalRegistrosPagos		        VARCHAR(8);
	DEFINE vIndicadorProceso CHAR(1);
    
	-- LET RUTA = '/tmp/devConci/';
    LET RUTA = '/RESPALDOSNEW/';
    
--ARCHIVOS
	LET PREFIJO = 'cnc_tdc_coppel_';
    LET NOMBRE_ARCHIVODET = 'CONCI_DET_COPPEL_';
	LET NOMBRE_ARCHIVO_CARATULA = 'CONCI_TDC_COPPEL_';
	LET ARCHIVO_UNL_CONSULTACNC = 'descarga_cnc_.unl';
	LET ARCHIVO_UNL_CONSULTACTE = 'descarga_cte_.unl';
	LET ARCHIVO_UNL_ID = 'descarga_id_.unl';
	LET SCRIPT_EJECUCION_CONSULTACNC = 'archivo_consulta_cnc.sql';
	LET SCRIPT_EJECUCION_CONSULTACTE = 'archivo_consulta_cte.sql';
	LET SCRIPT_EJECUCION_CONSULTAID = 'archivo_consulta_id.sql';
	LET ARCHIVO_INSERTCNC = 'archivo_insert_CNC.sql';
	LET ARCHIVO_INSERTCTE = 'archivo_insert_CTE.sql';
	LET ARCHIVO_INSERTID = 'archivo_insert_ID.sql';
	LET ARCHIVO_ERR = 'archivo_error.txt';
	LET ARCHIVO_ERRCTE = 'archivo_error_CTE.txt';
	LET CONTADOR_TRANSACCIONES = 1000;
    LET vExecuteSQL = '';
	
--VARIABLES DE RETORNO
	LET vCodigoRetorno = '00000';
    LET vMensaje = 'TERMINO EXITOSO';
--VARIABLES SP
	LET vCommit = 10;
	
	LET vConsecutivo  ='0';       
	LET vNombrearchivo    ='';   
	LET vArchivo_origen   ='';   
	LET vFechacarga  ='';
	LET vNumtarjeta ='';         
	LET vBan_bin ='';            
	LET vTipotransaccion325  ='';
    LET vTipotransaccion325C  ='';
	LET vMonto325  ='';          
	LET vInfreceptor ='';		             
	LET vDivisa325 ='';      
	LET vSecuencia ='';      
	LET vSecuencia_extendida=''; 
	LET vTransactionID='';  		
	LET vNumcte_coppel='';		
    LET vIdmovcoppel = '';
	
	--HEADER
	LET vHeader = 'HEADER ';
	LET vRelleno1 = '';
	LET vEmpresa = 'BANCOPPEL, S. A ENVIA-A ';
	LET vReceptor = 'COPPEL';
	LET vFecha = 'FECHA:';
	LET vRelleno2 = '';
	LET vFechaProceso = '';
	LET vFechaTDC='';
	LET vRelleno3 = '';
	LET vConsecutivo = 'CONSECUTIVO: ';
	LET vSecuenciaArchivo = '000001';
	LET vRelleno4 = '';
	LET vLeyendaTipoProceso = 'TIPO-PROCESO:';
	LET vTipoProceso = 'TDC COPPEL PLAZO FIJOS';
	LET vTipoProcesoTot = 'TDC COPPEL PLAZO FIJO TOTALES';
	--BODY
	LET vTransationID ='';
	LET vTipoTXN ='';
	LET vMonto ='';
	LET vSecuenciaextendida='';
	LET vSecuencia_extendidaC='';
    LET vCliente ='';
    LET vComercio='';
	LET vSecuencia='';
    LET vImporteOrigen = '';
    LET vPosEntrymode = '';
    LET vFechaConsumo = '';
    LET vRefTransaccion = '';
    LET vAfiCcomercio = '';
    LET vGiroComercio = '';
    LET vZcodeComercio = '';
    LET vPorcentajeComInter = '';
    LET vImporteComision = '';
    LET vBancoReceptor = '';
    LET vBancoEmisor = '';
    LET vNumAutorizacion = '';

	--TRAILER
	LET vTotalRegistros = 0;
	LET vRelleno1T='';
	LET vRelleno2T='';
	LET vSumaMonto='';
	LET vRelleno3T='';
	
	--CARATULA
	LET vSumMontoCompra='';
	LET vSumMontoDev = '';
	LET vSumMontoCompraInter='';
	LET vSumMontoDevInter = '';
	LET vSumMontoPagos = '';
	LET vIndicadorProceso = '0';
    
	---SET DEBUG FILE TO RUTA||PREFIJO||"debug.out";
	--TRACE ON;

	BEGIN 
    
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
				
				SET DEBUG FILE TO RUTA||PREFIJO||"excepcion_coppel_plazos_fijos_tarjetas_detalle.err.out" WITH APPEND;
				TRACE ON;
				
												
				IF ( SQLERR <> 0 ) THEN
					LET vCodigoRetorno = SQLERR;
					LET vMensaje = 'Proceso  '|| vIndicadorProceso || ERROR_INFO;                
					RETURN vCodigoRetorno, vMensaje;
				END IF;
				
		END EXCEPTION;
		
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		TRUNCATE TABLE "informix".td_movimientos_cnc_coppel DROP STORAGE;
		TRUNCATE TABLE "informix".td_cnc_movs_coppel DROP STORAGE;
		TRUNCATE TABLE "informix".td_cnc_movs_ctecoppel DROP STORAGE;
		
        LET vIndicadorProceso = '1';
		--EXTRACCI? DE INFORMACI? DE MOVIMIENTOS DEL BIN 514014
		
		LET vExecuteSQL	= '';
		LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
		'   SET LOCK MODE TO WAIT 3; '||
		'       UNLOAD TO '||RUTA||PREFIJO||ARCHIVO_UNL_CONSULTACNC||
		'   SELECT DISTINCT \"001\", 0, a.nombrearchivo, a.archivo_origen, a.fechacarga, a.numtarjeta, a.ban_bin,'||            
		'			a.tipotransaccion325, a.monto325, a.infreceptor, a.divisa325,'||          
		'			a.secuencia325, b.secuencia_extendida, SUBSTR(a.folio_mov, 2,16),'||           
		'  			a.nomcomercio325,b.importe_origen, b.pos_entrymode, b.fecha_consumo,' ||
		'			a.referencia23_325,b.afi_comercio,b.giro_comercio,b.zcode_comercio, '||
		'			b.porcentaje_com_inter ,b.importe_comision, b.banco_receptor,'||
		'			b.banco_emisor,b.num_autorizacion '||
		'    FROM bditarjeta:\"informix\".td_movimientos_conciliacion a'||
		'    INNER JOIN bditarjeta:\"informix\".td_movimientos_cnc_coppel_pay b'||
		'    ON a.referencia23_325 = b.referencia23_325'||
		" 		WHERE a.archivo_origen in('VNC' ,'PNC','MCC') AND b.conciliacionCoppel in('P')"|| 
		"		 AND a.integridad = 'V' AND a.numtarjeta LIKE '514014%' AND a.conciliacion = 'V';"|| 
		'">'||RUTA||PREFIJO||SCRIPT_EJECUCION_CONSULTACNC;            
		SYSTEM vExecuteSQL; 
       
        LET vIndicadorProceso = '2';
		--descargo la informaci? en un unl
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess bditarjeta '||RUTA||PREFIJO||SCRIPT_EJECUCION_CONSULTACNC;
        SYSTEM vExecuteSQL;
        
        LET vIndicadorProceso = '3';

       --Contrucci? de insert en la tabla
		LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA||PREFIJO||ARCHIVO_UNL_CONSULTACNC|| "' DELIMITER '|' "|| '27'||
                         "; INSERT INTO td_cnc_movs_coppel;"||'"'||' > '||RUTA||PREFIJO||ARCHIVO_INSERTCNC;
        SYSTEM vExecuteSQL;
   
		LET vIndicadorProceso = '4';
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA||PREFIJO||ARCHIVO_INSERTCNC||" -l "||RUTA||PREFIJO||ARCHIVO_ERR||" -n "||CONTADOR_TRANSACCIONES||" -r";
        SYSTEM vExecuteSQL;
		
		LET vIndicadorProceso = '5';
		--Obtiene el cliente coppel de las transacciones del bin 514014
		LET vExecuteSQL	= '';
   
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; '||
        '   SET LOCK MODE TO WAIT 3; '||
        '       UNLOAD TO '||RUTA||PREFIJO||ARCHIVO_UNL_CONSULTACTE||
        '   SELECT DISTINCT \"001\", 0, a.nombrearchivo, a.archivo_origen, a.fechacarga, a.numtarjeta, a.ban_bin,'||            
        '			a.tipotransaccion325,a.monto325, a.infreceptor, a.divisa325,'||          
        '			a.secuencia325, a.secuencia_extendida, c.numcte_ref, a.folio_mov,'||           
		'			a.nomcomercio325, a.importe_origen,a.pos_entrymode,a.fecha_consumo,'||
        '		    a.referencia23_325, a.afi_comercio, a.giro_comercio, a.zcode_comercio,'||
		'			a.porcentaje_com_inter ,a.importe_comision, a.banco_receptor,'||
        '		    a.banco_emisor,a.num_autorizacion  '||
        '    FROM bditarjeta:\"informix\".td_cnc_movs_coppel a'||
		'	INNER JOIN intercard:\"informix\".tarjeta t'||
		'   	ON(a.numtarjeta = t.numtarjeta)'||
		'	INNER JOIN bdinteg:\"informix\".si_cliente c'||
		'				ON(t.numcliente = c.numcte)'||
		" 		WHERE c.empresa = '001'"|| 
        '">'||RUTA||PREFIJO||SCRIPT_EJECUCION_CONSULTACTE;            
        SYSTEM vExecuteSQL;  
		
        LET vIndicadorProceso = '6';
		--descargo la informaci? en un unl
        LET vExecuteSQL   = '';
        LET vExecuteSQL   = 'dbaccess bditarjeta '||RUTA||PREFIJO||SCRIPT_EJECUCION_CONSULTACTE;
        SYSTEM vExecuteSQL;
        
        LET vIndicadorProceso = '7';
        
		--Construcci? de insert en la tabla
		LET vExecuteSQL = '';
        LET vExecuteSQL = "echo "||'"'|| "FILE '"||RUTA||PREFIJO||ARCHIVO_UNL_CONSULTACTE|| "' DELIMITER '|' "|| '28'||
        "; INSERT INTO td_cnc_movs_ctecoppel;"||'"'||' > '||RUTA||PREFIJO||ARCHIVO_INSERTCTE;
		SYSTEM vExecuteSQL;
                         
        
		LET vIndicadorProceso = '8';
        LET vExecuteSQL = '';
        LET vExecuteSQL = "dbload -d bditarjeta -c "||RUTA||PREFIJO||ARCHIVO_INSERTCTE||" -l "||RUTA||PREFIJO||ARCHIVO_ERRCTE||" -n "||CONTADOR_TRANSACCIONES||" -r";
        SYSTEM vExecuteSQL;
		
		update statistics medium for table "informix".td_cnc_movs_coppel;
        update statistics medium for table "informix".td_cnc_movs_ctecoppel;

		FOREACH curRegistrosTDC WITH HOLD FOR
   
            SELECT DISTINCT {+INDEX bditarjeta:td_cnc_movs_ctecoppel idx_td_cnc_movs_ctecoppel_empresa}
                 a.nombrearchivo, a.archivo_origen, a.fechacarga, a.numtarjeta, a.ban_bin,            
                        a.tipotransaccion325, a.monto325, a.infreceptor,  a.divisa325,         
                        a.secuencia325, a.numcte_coppel, a.secuencia_extendida,a.folio_mov,
						a.importe_origen,a.pos_entrymode,a.fecha_consumo,
						a.NomComercio325,a.referencia23_325,a.afi_comercio,a.giro_comercio,a.zcode_comercio,
						a.porcentaje_com_inter ,a.importe_comision, a.banco_receptor,
						a.banco_emisor,a.num_autorizacion
                    INTO vNombrearchivo, vArchivo_origen, vFechacarga, vNumtarjeta, vBan_bin,             
                            vTipotransaccion325, vMonto325, vInfreceptor, vDivisa325,          
                            vSecuenciaC, vNumcte_coppel, vSecuencia_extendidaC,vIdmovcoppel,
							vImporteOrigen, vPosEntrymode, vFechaConsumo, 
							vComercio,vRefTransaccion, vAfiCcomercio, vGiroComercio, vZcodeComercio, 
							vPorcentajeComInter, vImporteComision, vBancoReceptor, 
							vBancoEmisor, vNumAutorizacion
            FROM bditarjeta:"informix".td_cnc_movs_ctecoppel a
                WHERE empresa = '001'
   		       
            --Devoluciones
            IF ( vTipotransaccion325 = '21') THEN

                SELECT secuenciaextendida 
                    INTO  vSecuencia_extendidaC
                FROM intercard:movimiento 
                    WHERE secuencia = '1'||vSecuenciaC AND numtarjeta = vNumtarjeta;
               
            END IF
		
            ---Compras 
            SELECT idmovcoppel
                INTO vIdmovcoppel
            FROM intercard:mov_bancoppel_coppel 
                WHERE secuenciaextendida = vSecuencia_extendidaC;
				
				
			IF vIdmovcoppel IS NULL AND vTipotransaccion325 != '21'  THEN 
			
				SELECT secuenciaextendida
						INTO  vSecuencia_extendidaC
				FROM intercard:movimiento
					WHERE secuencia = '1' || vSecuenciaC AND numtarjeta = vNumtarjeta;
					
			 SELECT idmovcoppel 
					INTO vIdmovcoppel
			 FROM intercard:mov_bancoppel_coppel
					WHERE secuenciaextendida = vSecuencia_extendidaC;
					
			END IF
                    
           BEGIN;

           -- Devoluciones y Compras
			IF (vArchivo_origen='MCC') THEN
				IF (vTipotransaccion325 = '21') THEN
					LET vTipotransaccion325 = '06';
				END IF
				IF (vTipotransaccion325 = '01') THEN
					LET vTipotransaccion325 = '05';
				END IF 
			END IF;

               INSERT INTO bditarjeta:"informix".td_movimientos_cnc_coppel(consecutivo, empresa, nombrearchivo, archivo_origen,
                                                                                fechacarga, numtarjeta, ban_bin, tipotransaccion325,
                                                                                 monto325, infreceptor , divisa325, secuencia325,                                                                              
                                                                                 secuencia_extendida, numcte_coppel, folio_mov,
																				 NomComercio325,importe_origen,pos_entrymode,fecha_consumo,referencia23_325,
																				 afi_comercio,giro_comercio,zcode_comercio,porcentaje_com_inter,
																				 importe_comision,banco_receptor,banco_emisor,
																				 num_autorizacion)
                    VALUES( 0, '001', vNombrearchivo, vArchivo_origen, 
                            vFechacarga, vNumtarjeta, vBan_bin, vTipotransaccion325, 
                            vMonto325, vInfreceptor, vDivisa325, vSecuenciaC, 
                            vSecuencia_extendidaC, vNumcte_coppel, vIdmovcoppel,vComercio,vImporteOrigen,vPosEntrymode,vFechaConsumo,
							vRefTransaccion, vAfiCcomercio, vGiroComercio, vZcodeComercio, 
							vPorcentajeComInter, vImporteComision, vBancoReceptor, 
							vBancoEmisor, vNumAutorizacion);
           
        COMMIT;
        END FOREACH
        
        update statistics medium for table "informix".td_movimientos_cnc_coppel;
        
        SELECT COUNT(*)
			INTO vTotalRegistros
		FROM bditarjeta:"informix".td_movimientos_cnc_coppel
            WHERE empresa = '001';
            
       --Si no hay registros genera el archivo vac?
        IF (vTotalRegistros = 0) THEN
            LET vExecuteSQL = ''; 	   
            LET vExecuteSQL = 'echo""'||'>'||RUTA||NOMBRE_ARCHIVODET||TO_CHAR(TODAY, "%d%m%Y")||'.txt';
		
            SYSTEM vExecuteSQL;
			
			-- Mensaje para cuando hay informacion para mostrar en los archivos de conciliacion.
			LET vMensaje = 'TERMINO EXITOSO SIN INFORMACIÃÂN PARA MOSTRAR';
        ELSE
        
            --CONSTRUCCI? DE ARCHIVO DETALLE
            --Nombre del archivo
            
            LET NOMBRE_ARCHIVODET = NOMBRE_ARCHIVODET||TO_CHAR(TODAY, "%d%m%Y")||'.txt';
            
            LET vRelleno1 = LPAD(vRelleno1,4, '_');
            LET vRelleno2 = LPAD(vRelleno2,13, '_');
            LET vRelleno3 = LPAD(vRelleno3, 1, '_');
            LET vRelleno4 = LPAD(vRelleno4, 1, '_');
            
            LET vEmpresa = RPAD(vEmpresa, 22, '_');
            LET vReceptor = RPAD(vReceptor, 21, '_');
            LET vLeyendaTipoProceso = RPAD(vLeyendaTipoProceso, 14, '_');
    
            
            LET vFechaProceso = TO_CHAR(TODAY, "%d%m%y");
            
            --HEADER
            LET vExecuteSQL = ''; 	   
            LET vExecuteSQL = 'echo "'||vHeader||vRelleno1||vEmpresa||vReceptor||
                                        vFecha||vRelleno2||vFechaProceso||vRelleno3||
                                        vConsecutivo||vSecuenciaArchivo||vRelleno4||
                                        vLeyendaTipoProceso||vTipoProceso||'"'||'>'||RUTA||PREFIJO||"archivo_prueba.txt";
            
            SYSTEM vExecuteSQL;
            
                
            LET vExecuteSQL = '';
            LET vExecuteSQL = "sed 's/_/ /g' "||RUTA||PREFIJO||"archivo_prueba.txt"||">"||RUTA||NOMBRE_ARCHIVODET;
            SYSTEM vExecuteSQL;
		
            --BODY
            FOREACH tarjetas WITH HOLD FOR

                SELECT {+INDEX bditarjeta:td_movimientos_cnc_coppel idx_td_movimientos_cnc_coppel_empresa_tipotransaccion}
                    secuencia_extendida, tipotransaccion325, monto325, 
                        folio_mov, infreceptor, numcte_coppel, secuencia325,
						divisa325,importe_origen,pos_entrymode,fecha_consumo,
						NomComercio325,referencia23_325,afi_comercio,giro_comercio,zcode_comercio,
						porcentaje_com_inter ,importe_comision, banco_receptor,
						banco_emisor,num_autorizacion 
                    INTO vSecuenciaextendida,  vTipoTXN, vMonto,  
                        vIdmovcoppel, vInfreceptor, vCliente,vSecuencia,
						vDivisa325,vImporteOrigen,  vPosEntrymode, vFechaConsumo, vComercio,
						vRefTransaccion, vAfiCcomercio, vGiroComercio, vZcodeComercio, 
						vPorcentajeComInter, vImporteComision, vBancoReceptor, 
						vBancoEmisor, vNumAutorizacion
                FROM bditarjeta:"informix".td_movimientos_cnc_coppel
                    WHERE empresa = '001'
                
                LET vSecuenciaextendida = LPAD(NVL(vSecuenciaextendida, ''), '23','0');
                LET vMonto = LPAD(NVL(vMonto,''), '13','0');
                LET vIdmovcoppel = LPAD(NVL(vIdmovcoppel,''),'16','-');
                LET vInfreceptor = RPAD(NVL(vInfreceptor,''),'40','-');
                LET vCliente = LPAD(NVL(vCliente,''),'20','0');
                LET vSecuencia = LPAD(NVL(vSecuencia,''), '7',' ');		
				LET vImporteOrigen = LPAD(NVL(vImporteOrigen,''),'13','0'); -- NUMERICO
				LET vDivisa325 = LPAD(NVL(vDivisa325,''),'3','0'); -- NUMERICO
				LET vPosEntrymode = LPAD(NVL(vPosEntrymode,''),'2','0'); -- NUMERICO			
				LET vFechaConsumo = LPAD(NVL(vFechaConsumo,''),'8','19000101'); --PAGO INTERBANCARIO FECHA DEFAULT
				LET vRefTransaccion = LPAD(NVL(vRefTransaccion,''),'23','0');                                                                   
				LET vAfiCcomercio = LPAD(NVL(vAfiCcomercio,''),'15','-');
				LET vGiroComercio = LPAD(NVL(vGiroComercio,''),'4','0'); -- NUMERICO
				LET vZcodeComercio = LPAD(NVL(vZcodeComercio,''),'5','0'); -- NUMERICO
				LET vPorcentajeComInter = LPAD(NVL(vPorcentajeComInter,''),'5','0'); -- NUMERICO
				LET vImporteComision = LPAD(NVL(vImporteComision,''),'13','0'); -- NUMERICO
				LET vBancoReceptor = LPAD(NVL(vBancoReceptor,''),'2','0'); -- NUMERICO
				LET vNumAutorizacion = LPAD(NVL(vNumAutorizacion,''),'7','0');
				LET vComercio = RPAD(NVL(vComercio,''),'40','-');
				
			update bditarjeta:"informix".td_movimientos_cnc_coppel_pay
			set conciliacionCoppel='T'
			where referencia23_325=vRefTransaccion;

				LET vExecuteSQL = ''; 	   
                LET vExecuteSQL = 'echo "0097'||vSecuenciaextendida||vTipoTXN||vMonto||vFechaProceso||
											vIdmovcoppel||vInfreceptor/*vComercio*/||vCliente||vSecuencia||
											vImporteOrigen||vDivisa325||vPosEntrymode||vFechaConsumo||vRefTransaccion||
											vAfiCcomercio||vGiroComercio||vZcodeComercio||vPorcentajeComInter||
											vImporteComision||vBancoReceptor||
											'"'||">>"||RUTA||PREFIJO||"archivo_prueba2.txt";
                
                SYSTEM vExecuteSQL;
                
            END FOREACH
            
			-- Mensaje para cuando hay informacion para mostrar en los archivos de conciliacion.
			LET vMensaje = 'TERMINO EXITOSO CON INFORMACIÃÂN PARA MOSTRAR';

            LET vExecuteSQL = '';
            LET vExecuteSQL = "sed 's/-/ /g' "||RUTA||PREFIJO||"archivo_prueba2.txt"||">>"||RUTA||NOMBRE_ARCHIVODET;
            SYSTEM vExecuteSQL;
            
            --TRAILER
            LET vRelleno1T = LPAD(vRelleno1T, 1, '_');
            LET vRelleno2T = LPAD(vRelleno2T, 1, '_');
            LET vRelleno3T = LPAD(vRelleno3T, 1, '_');
            
            SELECT COUNT(*)
                INTO vTotalRegistros
            FROM bditarjeta:"informix".td_movimientos_cnc_coppel
                  WHERE empresa = '001';

            SELECT {+INDEX bditarjeta:td_movimientos_cnc_coppel idx_td_movimientos_cnc_coppel_empresa_tipotransaccion}
                    SUM(CAST(monto325 AS INTEGER))
                INTO vSumaMonto
            FROM bditarjeta:"informix".td_movimientos_cnc_coppel
                 WHERE empresa = '001';
                
            LET vTotalRegistros=LPAD(vTotalRegistros, 8, 0);
            LET vSumaMonto=LPAD(vSumaMonto,15,0);
            
            LET vExecuteSQL = ''; 	   
            LET vExecuteSQL = 'echo "TRAILER'||vRelleno1T||vTotalRegistros||vRelleno2T||vSumaMonto||
                                        vRelleno3T||'"'||'>'||RUTA||PREFIJO||"archivo_prueba3.txt";
            
            SYSTEM vExecuteSQL;
            
            LET vExecuteSQL = '';
            LET vExecuteSQL = "sed 's/_/ /g' "||RUTA||PREFIJO||"archivo_prueba3.txt"||">>"||RUTA||NOMBRE_ARCHIVODET;
            SYSTEM vExecuteSQL;
        END IF   
		
		--CONSTRUCCI? DE LA CARATULA
		--nombrearchivo
		LET NOMBRE_ARCHIVO_CARATULA = NOMBRE_ARCHIVO_CARATULA||TO_CHAR(TODAY, "%d%m%Y")||'.txt';
		--COMPRAS
		SELECT COUNT(*), ROUND(SUM(CAST(monto325 AS INTEGER)/100),2)
			INTO vTotalRegistrosCompra, vSumMontoCompra
		FROM bditarjeta:"informix".td_movimientos_cnc_coppel
			WHERE empresa = '001'
                AND tipotransaccion325 = '01' ;
		
		--COMPRAS INTERNACIONALES
		SELECT COUNT(*), ROUND(SUM(CAST(monto325 AS INTEGER)/100),2)
			INTO vTotalRegistrosCompraInter, vSumMontoCompraInter
		FROM bditarjeta:"informix".td_movimientos_cnc_coppel
			WHERE empresa = '001'
                AND tipotransaccion325 = '05' AND archivo_origen = 'MCC' ;
				
		--PAGOS
		SELECT COUNT(*), ROUND(SUM(CAST(monto325 AS INTEGER)/100),2)
			INTO vTotalRegistrosPagos, vSumMontoPagos
		FROM bditarjeta:"informix".td_movimientos_cnc_coppel
			WHERE empresa = '001'
                AND tipotransaccion325 = '20' ;
            
		--DEVOLUCIONES	
		SELECT COUNT(*), ROUND(SUM(CAST(monto325 AS INTEGER)/100),2)
			INTO vTotalRegistrosDev, vSumMontoDev
		FROM bditarjeta:"informix".td_movimientos_cnc_coppel
			WHERE empresa = '001' 
                AND tipotransaccion325 = '21';

		--DEVOLUCIONES INTERNACIONALES	
		SELECT COUNT(*), ROUND(SUM(CAST(monto325 AS INTEGER)/100),2)
			INTO vTotalRegistrosDevInter, vSumMontoDevInter
		FROM bditarjeta:"informix".td_movimientos_cnc_coppel
			WHERE empresa = '001' 
                AND tipotransaccion325 = '06' AND archivo_origen = 'MCC' ;																	  
		
        LET vSumMontoCompra = NVL(vSumMontoCompra, 0);
        LET vSumMontoDev =NVL(vSumMontoDev,0);
		LET vSumMontoCompraInter = NVL(vSumMontoCompraInter, 0);
        LET vSumMontoDevInter =NVL(vSumMontoDevInter,0);	
		Let vSumMontoPagos =NVL(vSumMontoPagos,0);
       					
		LET vTotalRegistros = CAST(vTotalRegistrosCompra AS INTEGER);
		LET vTotalRegistros = CAST(vTotalRegistrosCompraInter AS INTEGER);
		LET vTotalRegistros = CAST(vTotalRegistrosPagos AS INTEGER);
		LET vTotalRegistros = CAST(vTotalRegistrosDev AS INTEGER);
		LET vTotalRegistros = CAST(vTotalRegistrosDevInter AS INTEGER);
		
		
		LET vFechaTDC = TO_CHAR(TODAY, "%d")||'/'||TO_CHAR(TODAY, "%m")||'/'||TO_CHAR(TODAY, "%y");

		
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "'||vEmpresa||vFecha||vRelleno3||vFechaProceso||vRelleno3||vConsecutivo||vSecuenciaArchivo||
									vRelleno3||vLeyendaTipoProceso||vTipoProcesoTot||'"'||'>'||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "ICA 32020 Coppel"'||'>>'||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "Detalles de transacciones totales"'||'>>'||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "BIN: 5140140"'||'>>'||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;
		
		
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "Tipo de transaccion: Compras [ 01 ] Cantidad:[ '||vTotalRegistrosCompra||" ] "|| 
								"Monto:[ \$ "||vSumMontoCompra||' MXN ] "'||">>"||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;

				LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "Tipo de transaccion: Compras Internacionales [ 05 ] Cantidad:[ '||vTotalRegistrosCompraInter||" ] "|| 
								"Monto:[ \$ "||vSumMontoCompraInter||' MXN ] "'||">>"||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;			 
		
						
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "Tipo de transaccion: Pagos Interbancarios [ 20 ] Cantidad:[ '||vTotalRegistrosPagos||" ] "|| 
								"Monto:[ \$ "||vSumMontoPagos||' MXN ] "'||">>"||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "Tipo de transaccion: Devoluciones [ 21 ] Cantidad:[ '||vTotalRegistrosDev||" ] "|| 
								"Monto:[ \$ "||vSumMontoDev||' MXN ] "'||">>"||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "Tipo de transaccion: Devoluciones Internacionales [ 06 ] Cantidad:[ '||vTotalRegistrosDevInter||" ] "|| 
								"Monto:[ \$ "||vSumMontoDevInter||' MXN ] "'||">>"||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;
			
		LET vExecuteSQL = ''; 	   
		LET vExecuteSQL = 'echo "'||vFecha||vFechaTDC||'"'||'>>'||RUTA||PREFIJO||"archivo_pruebaTOT.txt";
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "sed 's/_/ /g' "||RUTA||PREFIJO||"archivo_pruebaTOT.txt"||">"||RUTA||NOMBRE_ARCHIVO_CARATULA;
		SYSTEM vExecuteSQL;
		
		
		 LET vExecuteSQL = '';
		 LET vExecuteSQL = 'rm -f '||RUTA||PREFIJO||'*';
		 SYSTEM vExecuteSQL;
		
		RETURN vCodigoRetorno, vMensaje;
			
	END
	
END PROCEDURE
DOCUMENT
'Autor: Kenya Itzel Alonso Sanchez',
'Objetivo: GeneraciÃÂ³n de los archivos con el detalle de las compras de tarjeta de crÃÂ©dito Coppel MC ',
'y los totales de las transacciones con la siguiente nomenclatura: ',
'Detalle de las transacciones: CONCI_DET_COPPEL_DDMMAAAA.txt',
'Totales: CONCI_TDC_COPPEL_DDMMAAAA.txt',
'Fecha de CreaciÃÂ³n: 15/07/2022',
'#2',
'Fecha de modificaciÃÂ³n: 16/nov/2022',
'Busqueda de secuencia extendida para compras y devoluciones, asÃÂ­ como la secuencia de coppel (idmovcoppel)',
'#3',
'Autor: Paul Antonio Garcia Gastelum',
'Objetivo: GeneraciÃÂ³n de los archivos con el detalle de compras, devoluciones y pagos interbancarios',
'de tarjeta de crÃÂ©dito Coppel pay con los campos nuevos solicitados y los totales de las transacciones de pagos interbancarios en el archivo',
'de caratula',
'Fecha de modificaciÃÂ³n: 13/03/2023'
;

CREATE PROCEDURE "informix".sp_homologacion_estatus_tarjetas(
    opcionTabla INTEGER ---  Tipo de caso para canelacion en intercard (1), bdicred (2) o bdicheq (3)
)
RETURNING CHAR(5) AS oCodigoRetorno, VARCHAR(250) AS oMensaje;

	-- Variables de Retorno
	DEFINE vstatus_proc     CHAR(1);
	DEFINE vcod_ret         VARCHAR(10);
	DEFINE sql_err          INTEGER;
	DEFINE isam_err         INTEGER;
	DEFINE error_info       CHAR(40);
	
	DEFINE vCodigoRetorno   CHAR(5);
	DEFINE vMensaje             VARCHAR(250);
	DEFINE ReturnValue      CHAR(1);
	
	DEFINE v_sql            CHAR(250);
	
	DEFINE Contador_commit	SMALLINT;
	DEFINE vFlagTransaccion	CHAR(1);
	
	DEFINE var_status_tar           CHAR(1);
	DEFINE var_codstatustarjeta     VARCHAR(3);
	DEFINE var_codstatusasignada    VARCHAR(3);
	DEFINE var_numtarjeta           VARCHAR(16);
	
	DEFINE validaciontarjetacuencta INTEGER;
	
	DEFINE vExecuteSQL      	CHAR(250);
	DEFINE nomRut           	CHAR(250);
	DEFINE nomArch          	CHAR(250);
	DEFINE vNombreCompTXT   	CHAR(250);
	DEFINE vNombreCompLog   	CHAR(250);
	DEFINE vNombreEjecucionLog  CHAR(250);

    -- MANEJO DEL ERROR
    ON EXCEPTION SET sql_err, isam_err, error_info
		
		DROP TABLE IF EXISTS intercard:temp_cancelacionparahomologacion;
		
		IF (vFlagTransaccion = 'V') THEN
			COMMIT;
			LET vFlagTransaccion = 'F';
		END IF;
		
		IF ( sql_err <> 0 ) THEN
			LET vCodigoRetorno = sql_err;
			LET vMensaje = 'Error:  '|| isam_err || error_info;
		
			RETURN vCodigoRetorno, vMensaje;
		END IF;

    END EXCEPTION;

    --SET DEBUG FILE TO "/RESPALDOSNEW/sp_cancelacion_homologacion.out";
    --TRACE ON;

	-- Definicion de variables
	LET vstatus_proc		= '';
	LET vcod_ret			= '000';
	LET sql_err				= 0;
	LET isam_err			= 0;
	LET error_info			= '';
	LET ReturnValue			= "0";
	
	LET nomRut				= '/RESPALDOSNEW/';
	LET vNombreCompTXT		= 'paso1.txt';
	LET vNombreCompLog		= 'paso1.log';
	LET vNombreEjecucionLog	= 'paso1_rep.log';
	
	LET Contador_commit		= 0;
	LET vFlagTransaccion	= 'F';

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    CREATE TABLE IF NOT EXISTS intercard:temp_cancelacionparahomologacion(
        numtarjeta			CHAR(16),
        codstatustarjeta	VARCHAR(3),
        codstatusasignada	VARCHAR(3),
        status_tar			CHAR(1)
    );

    TRUNCATE TABLE intercard:temp_cancelacionparahomologacion;
    
	-- Homologacion de estatus de tarjetas de debito y credito dada su cancelacion en intercard
	
    -- Homologacion en la Base de Datos bdicheq:sc_tarjeta (debito)
    IF(opcionTabla = 1) THEN
		LET nomArch = 'tarjetas_debito_bdicheq.unl';

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(nomRut) || TRIM(nomArch) || "' delimiter '" || '|' || "' " || '4' || "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";" || '"' || ' > '|| TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 " || TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || TRIM(nomRut) || TRIM(vNombreCompTXT) || " -l " || TRIM(nomRut) || TRIM(vNombreCompLog) || " -n " || 1000 || " -r > " || TRIM(nomRut) || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';

		LET vFlagTransaccion = 'V';
		
        BEGIN WORK;
            FOREACH WITH HOLD
                SELECT numtarjeta
                    INTO var_numtarjeta
                FROM intercard:temp_cancelacionparahomologacion

                SELECT FIRST 1 a.status_tar
                    INTO var_status_tar
                FROM bdicheq:sc_tarjeta a
				JOIN bdicheq:sc_maechq b
				ON a.cuenta = b.cuenta
                WHERE a.num_tarjeta = var_numtarjeta;

                IF var_status_tar = 'A' THEN

                    SELECT codstatustarjeta
                        INTO var_codstatustarjeta
                    FROM  intercard:tarjeta
                    WHERE numtarjeta = var_numtarjeta;

                    IF var_codstatustarjeta IN ('CAN', 'FAL', 'ROB','EXT','DAN') THEN

						UPDATE bdicheq:sc_tarjeta SET status_tar = 'C' WHERE num_tarjeta = var_numtarjeta;
						
						LET Contador_commit = Contador_commit + 1;
						
						IF Contador_commit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET Contador_commit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;

                    END IF;

                END IF;
				
            END FOREACH;

        COMMIT;
		
		LET vFlagTransaccion = 'F';

    END IF;

    -- Homologacion en la Base de Datos bdicred:sd_tarjeta (credito)
    IF(opcionTabla = 2) THEN
		LET nomArch = 'tarjetas_credito_bdicred.unl';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '" || TRIM(nomRut) || TRIM(nomArch) || "' delimiter '" || '|' || "' " || '4' || "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";" || '"' || ' > '|| TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 " || TRIM(nomRut) || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || TRIM(nomRut) || TRIM(vNombreCompTXT) || " -l " || TRIM(nomRut) || TRIM(vNombreCompLog) || " -n " || 1000 || " -r > " || TRIM(nomRut) || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		
		LET vFlagTransaccion = 'V';
		
        BEGIN WORK;
        
			FOREACH WITH HOLD
				SELECT numtarjeta
					INTO var_numtarjeta
				FROM intercard:temp_cancelacionparahomologacion
			
				SELECT FIRST 1 a.status_tar
					INTO var_status_tar
				FROM bdicred:sd_tarjeta a
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
				WHERE a.num_tarjeta = var_numtarjeta;

				IF var_status_tar = 'A' THEN

					SELECT codstatustarjeta
					INTO var_codstatustarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = var_numtarjeta;

					IF var_codstatustarjeta IN ('CAN', 'FAL', 'ROB','EXT','DAN') THEN

						UPDATE bdicred:sd_tarjeta SET status_tar = 'C' WHERE num_tarjeta = var_numtarjeta;  
						
						LET Contador_commit = Contador_commit + 1;

						IF Contador_commit = 1000 THEN
							COMMIT;
							LET vFlagTransaccion = 'F';
							LET Contador_commit = 0;
							BEGIN WORK;
							LET vFlagTransaccion = 'V';
						END IF;
						
					END IF;
					
				END IF;
			
			END FOREACH;

        COMMIT;

		LET vFlagTransaccion = 'F';
		
	END IF;

    -- Homologacion en la Base de Datos intercard:tarjeta (debito)
	IF(opcionTabla = 3) THEN

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '/RESPALDOSNEW/tarjetas_debito_intercard.unl' delimiter '"|| '|' ||"' "|| '4'|| "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";"||'"'||' > '|| '/RESPALDOSNEW/paso1.txt';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/paso1.txt";
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || '/RESPALDOSNEW/paso1.txt' || " -l " || '/RESPALDOSNEW/paso1.log' || " -n " || 1000 ||" -r > "|| '/RESPALDOSNEW/paso1_rep.log';
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';

		LET vFlagTransaccion = 'V';
		
        BEGIN WORK;
            FOREACH WITH HOLD
				SELECT numtarjeta
					INTO var_numtarjeta
				FROM intercard:temp_cancelacionparahomologacion

                SELECT FIRST 1 a.status_tar
					INTO var_status_tar
                FROM bdicheq:sc_tarjeta a
				JOIN bdicheq:sc_maechq b
				ON a.cuenta = b.cuenta
                WHERE a.num_tarjeta = var_numtarjeta;

                IF var_status_tar = 'C' THEN

                    SELECT codstatustarjeta
					INTO var_codstatustarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = var_numtarjeta;

                    IF var_codstatustarjeta in ('ACT', 'BLO', 'BLT') THEN

						LET Contador_commit = Contador_commit + 1;

						SELECT COUNT(numcuenta)
						INTO validaciontarjetacuencta
						FROM intercard:tarjetacuenta
						WHERE numtarjeta = var_numtarjeta;

						IF validaciontarjetacuencta = 1 THEN

                            UPDATE intercard:tarjeta
							SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'intercar', numtarjeta = NVL(numtarjeta, ''), numcliente = NVL(numcliente, '') , titular = NVL(titular, '')
							WHERE numtarjeta = var_numtarjeta;

							IF Contador_commit = 1000 THEN
								COMMIT;
								LET vFlagTransaccion = 'F';
								LET Contador_commit = 0;
								BEGIN WORK;
								LET vFlagTransaccion = 'V';
							END IF;
							
                        END IF;

                    END IF;

                END IF;

            END FOREACH;

        COMMIT;
		
		LET vFlagTransaccion = 'F';

    END IF;

    -- Homologacion en la Base de Datos intercard:tarjeta (credito)
    IF(opcionTabla = 4) THEN

		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '/RESPALDOSNEW/tarjetas_credito_intercard.unl' delimiter '"|| '|' ||"' "|| '4'|| "; INSERT INTO "|| 'temp_cancelacionparahomologacion' || ";"||'"'||' > '|| '/RESPALDOSNEW/paso1.txt';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/paso1.txt";
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d intercard -c " || '/RESPALDOSNEW/paso1.txt' || " -l " || '/RESPALDOSNEW/paso1.log' || " -n " || 1000 ||" -r > "|| '/RESPALDOSNEW/paso1_rep.log';
		SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "chmod 777 /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompTXT);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreCompLog);
		SYSTEM vExecuteSQL;

		LET vExecuteSQL = '';
		LET vExecuteSQL = "rm -r /RESPALDOSNEW/" || TRIM(vNombreEjecucionLog);
		SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
		
		LET vFlagTransaccion = 'V';

        BEGIN WORK;
			FOREACH WITH HOLD
				SELECT numtarjeta
				INTO var_numtarjeta
				FROM intercard:temp_cancelacionparahomologacion

                SELECT FIRST 1 a.status_tar
				INTO var_status_tar
				FROM bdicred:sd_tarjeta a
				JOIN bdicred:sd_maecred b
				ON a.num_credito = b.num_credito
				WHERE a.num_tarjeta = var_numtarjeta;

				IF var_status_tar = 'C' THEN

					SELECT codstatustarjeta
					INTO var_codstatustarjeta
					FROM  intercard:tarjeta
					WHERE numtarjeta = var_numtarjeta;

					IF var_codstatustarjeta IN ('ACT', 'BLO', 'BLT') THEN

						LET Contador_commit = Contador_commit + 1;

						SELECT COUNT(numcuenta)
						INTO validaciontarjetacuencta
						FROM intercard:tarjetacuenta
						WHERE numtarjeta = var_numtarjeta;

						IF validaciontarjetacuencta = 1 THEN

							UPDATE intercard:tarjeta
							SET codstatustarjeta = 'CAN', fechaultmodif = CURRENT, usuarioultmodif = 'intercar', numtarjeta = NVL(numtarjeta, ''), numcliente = NVL(numcliente, '') , titular = NVL(titular, '')
							WHERE numtarjeta = var_numtarjeta;

							IF Contador_commit = 1000 THEN
								COMMIT;
								LET vFlagTransaccion = 'F';
								LET Contador_commit = 0;
								BEGIN WORK;
								LET vFlagTransaccion = 'V';
							END IF;
						END IF;

					END IF;

				END IF;

			END FOREACH;

        COMMIT;
		
		LET vFlagTransaccion = 'F';

    END IF;
	
	DROP TABLE IF EXISTS intercard:temp_cancelacionparahomologacion;

	LET vCodigoRetorno = "00000";
	LET vMensaje = "Proceso completado";

	RETURN vCodigoRetorno, vMensaje;

END PROCEDURE;