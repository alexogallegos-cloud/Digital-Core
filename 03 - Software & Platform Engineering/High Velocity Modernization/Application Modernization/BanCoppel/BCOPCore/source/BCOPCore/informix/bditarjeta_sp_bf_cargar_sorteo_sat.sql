CREATE PROCEDURE "informix".sp_bf_cargar_sorteo_sat( pAnioFiscal CHAR(4) )

    RETURNING CHAR (5) AS CODIGO_RETORNO, VARCHAR(250) AS MENSAJE_RETORNO;
    
    DEFINE CODIGO_RETORNO CHAR(5);
    DEFINE MENSAJE_RETORNO VARCHAR(80);
    DEFINE RUTA_ORIGEN VARCHAR(50);
    DEFINE SQL_ERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(100);    
    DEFINE vConteo INTEGER;
    DEFINE vConsecutivo INTEGER;
    DEFINE vContadorTransacciones SMALLINT;
    DEFINE vscadena 			VARCHAR(100);
    DEFINE vTotalRegistros		INTEGER;    
    DEFINE vsFlagEnTransaccion 	VARCHAR(1);
    DEFINE viContadorRegistros 	INTEGER;
    DEFINE vNumRefeTrans CHAR(12);
    DEFINE vTipoBin CHAR(6);
    DEFINE vTipoTarjeta CHAR(1);
    DEFINE ABREVIATURA_CREDITO CHAR(1);
    DEFINE ABREVIATURA_DEBITO  CHAR(1);
	
	DEFINE vTporeg             	CHAR(2);
	DEFINE vBanemisor          	CHAR(4);
	DEFINE vFechatransaccion   	CHAR(10);
	DEFINE vNumtarjeta         	CHAR(16);
	DEFINE vMontotxn           	DECIMAL(12,2);
	DEFINE vSecuencia          	CHAR(6);
	DEFINE vReferencia          CHAR(12);
	DEFINE vMontopremio        	INTEGER;
	DEFINE vAfiliacion 			CHAR(7);

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        --SET DEBUG FILE TO RUTA_ORIGEN || 'excepcion_sp_bf_cargar_sorteo_sat.out';
        --TRACE ON;
		
		IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN            
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';            
        END IF;
        LET CODIGO_RETORNO   = SQL_ERR;
        LET MENSAJE_RETORNO  = error_info   ||   ISAM_ERR   || '  mensaje de excepcion';
        RETURN CODIGO_RETORNO , MENSAJE_RETORNO;
	END EXCEPTION;

    
    LET CODIGO_RETORNO  = '00000';
    LET MENSAJE_RETORNO = 'Proceso exitoso.';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET vConteo = 0;
    LET vConsecutivo = 0;
    LET vContadorTransacciones = 1000;    
    LET vscadena = '';
    LET vTotalRegistros = 0;
    LET vsFlagEnTransaccion = 'F';
    LET viContadorRegistros = 0;
    LET vNumRefeTrans = '000000000000'; -- Numero de referencia de la transaccion. 
    LET vTipoBin = '';
    LET vTipoTarjeta = '';
    LET ABREVIATURA_CREDITO = 'C';
    LET ABREVIATURA_DEBITO  = 'D';
        
   --SET DEBUG FILE TO RUTA_ORIGEN || 'sp_bf_cargar_sorteo_sat.out';
    --TRACE ON;        
	
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:tbl_bf_sorteo_sat;
    
    SELECT COUNT(*)
		INTO vConteo 
	FROM bditarjeta:tbl_bf_sorteo_sat 
	WHERE periodofiscal = pAnioFiscal;
	
    IF(vConteo > 0 AND vConteo IS NOT NULL) THEN    
        LET CODIGO_RETORNO = '00001';
        LET MENSAJE_RETORNO  = 'Los registros correspondientes al periodo fiscal  '||  pAnioFiscal ||' ya fueron registrados.';
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
    END IF;
    
	
	UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:td_carga_archivo_sat;
	
    --Al menos debe existir un registro independiente al encabezado y pie de pagina.
    SELECT 
		COUNT(*)
        INTO vTotalRegistros
    FROM bditarjeta:td_carga_archivo_sat;

    IF(vTotalRegistros = 0) THEN
        LET CODIGO_RETORNO = '00002';
        LET MENSAJE_RETORNO  = 'No existen registros para procesar el periodo fiscal '  || pAnioFiscal;
        RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
    END IF;
    
    LET vConteo = 0;
    
    FOREACH WITH HOLD 
    
        SELECT 
	 Tporeg,Banemisor,Fechatransaccion,Numtarjeta,Montotxn,Secuencia,Referencia,Montopremio,Afiliacion	
            INTO 
	 vTporeg,vBanemisor,vFechatransaccion,vNumtarjeta,vMontotxn,vSecuencia,vReferencia,vMontopremio,vAfiliacion
        FROM bditarjeta:td_carga_archivo_sat
        
            IF (vsFlagEnTransaccion = 'F') THEN 
                BEGIN WORK;
                LET vsFlagEnTransaccion = 'V';
            END IF;               
            
            --El valro vNumRefeTrans debe tener 12 caracteres en caso contrario se rellena de ceros.
            LET vNumRefeTrans = LPAD(vReferencia, 12, '0');
            LET vTipoBin = vNumtarjeta[1,6];         
            
            LET vTipoTarjeta = (
                CASE
                    WHEN vTipoBin IN (
                            SELECT bin FROM intercard:bines WHERE creditodebito = ABREVIATURA_DEBITO
                    ) THEN ABREVIATURA_DEBITO
                    WHEN vTipoBin IN (
                            SELECT bin FROM intercard:bines WHERE creditodebito = ABREVIATURA_CREDITO
                    ) THEN ABREVIATURA_CREDITO
                END
                );            
            
            -- Transacciones premiadas.            

			IF ( vMontopremio <> 0.0 ) THEN
                INSERT INTO bditarjeta:tbl_bf_sorteo_sat
                    (
                        periodofiscal, tporeg, banemisor, fechatransaccion, numtarjeta, 
                        montoarchivo, secuenciaarchivo, numrefarchivo, idretailer_archivo, tipo_tarjeta,
                        montopremio, validaciones, observacion
                    )
                    VALUES
                    (
                        pAnioFiscal,									-- Del encabezado
                        vTporeg,					 					-- Del detalle tipo de registro
                        vBanemisor,										-- Numero del Banco
                        --SUBSTR(REPLACE(vFechatransaccion,'-',''),3,6),	-- Fecha de la transaccion
		        vFechatransaccion,
                        vNumtarjeta,									-- Numero de la tarjeta
                        REPLACE(REPLACE(TO_CHAR(vMontotxn,"**********.**"),'*','0'),'.',''), -- Monto de transaccion
                       vSecuencia,										-- Secuencia de transaccion
                       vNumRefeTrans,									-- Referencia de POS de transaccion
                       vAfiliacion,										-- Id Retailer de la transacciÃ³n	
                        vTipoTarjeta,
						REPLACE(TO_CHAR(vMontopremio,"************"),'*','0'),		-- Monto del Premio otorgado a la transaccion
                        'V', 								-- Se coloca bandera para acortar busqueda 
                        'Transaccion Premiada'				-- Leyenda temporal 
                    );
            END IF;
            
            LET vConteo = vConteo +1;

            IF (vConteo >= vContadorTransacciones) THEN
                COMMIT WORK;
                LET vsFlagEnTransaccion = 'F';
                LET vConteo = 0;                
                CONTINUE FOREACH;
            END IF;
        END FOREACH;
		
        IF ((vConteo > 0) OR (vsFlagEnTransaccion = 'V')) THEN            
            COMMIT WORK;
            LET vsFlagEnTransaccion = 'F';            
        END IF;
        
        UPDATE STATISTICS MEDIUM FOR TABLE bditarjeta:tbl_bf_sorteo_sat;
    
	RETURN CODIGO_RETORNO, MENSAJE_RETORNO;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Armando Garcia Ortiz',
'Proyecto: Sorteo El Buen Fin',
'Fecha de creacion: 30.noviembre.2018',
'Fecha de modificacion: 04.diciembre.2019',
'Descripcion: Insercion de los campos correspondientes obtenidos de la tabla de paso',
'donde la informacion del archivo fue almacenado',
'Base de datos: bditarjeta',
'#2',
'Fecha de modificacion: 18.diciembre.2020',
'Se agrega update statistics cuando el conteo sea mayor o igual a 1000.',
'OptimizaciÃ³n de ejecuciÃ³n', 
'#3',
'Fecha de modificacion: 20.diciembre.2021',
'Implementacion para validar y extraer los decimales recibidos en el archivo del sorteo: monto de transaccion y monto premiado)',
'#4',
'Fecha de modificacion: 20.diciembre.2022',
'Se cambian las posiciones entre los campos id_retailer y monto_premio',
'#5',
'Fecha de modificacion: 19.diciembre.2025',
'Se conserva el valor de la varible vFechatransaccion '
;

CREATE PROCEDURE "informix".sp_bf_aplicar_premios ( pAnioFiscal CHAR(4) )
    
    RETURNING CHAR (5) AS CODIGO_RETORNO, CHAR(120) AS MENSAJE_RETORNO;

    DEFINE CODIGO_RETORNO 	CHAR(5);    
    DEFINE MENSAJE_RETORNO 	CHAR(120);
    DEFINE RUTA_ORIGEN      VARCHAR(50);
    DEFINE NUMERO_TRANSACCION_DEBITO CHAR(4);
    DEFINE NUMERO_TRANSACCION_CREDITO CHAR(4);
    DEFINE LEYENDA_DEFINIDA_BUEN_FIN VARCHAR(60);
    DEFINE SQL_ERR INTEGER;
    DEFINE ISAM_ERR INTEGER;
    DEFINE ERROR_INFO VARCHAR(100);    
    DEFINE PREFIJO_SCRIPTS CHAR(8);
    
    DEFINE vConsecutivo INTEGER;
    DEFINE vPeriodoFiscal	CHAR(4);
    DEFINE vstporeg		VARCHAR(2);
    DEFINE vsemisor		VARCHAR(4);
    DEFINE vsfecha		VARCHAR(6);
    DEFINE vNumTarjeta	VARCHAR(16);
    DEFINE vMontoTrx		VARCHAR(12);
    DEFINE vSecuencia	VARCHAR(6);
    DEFINE vsreferencia	VARCHAR(12);
    DEFINE vIdRetailer	CHAR(7);
    DEFINE vMontoPremio VARCHAR(12);    
    DEFINE vNumeroCta VARCHAR(13);    
    DEFINE vFolioSuc CHAR(23);
    DEFINE vCodigoDevolucion CHAR(1); 
    DEFINE vTipoTarjeta CHAR(1);
    DEFINE vTransaccionAplicada CHAR(4);
    DEFINE vFlujoEnTransaccion CHAR(1);
    DEFINE ABREVIATURA_CREDITO CHAR(1);
    DEFINE ABREVIATURA_DEBITO  CHAR(1);
    DEFINE APLICAR_PREMIO_MAYOR  CHAR(1);
    DEFINE MONTO_MAX_PREMIO_MAYOR CHAR(12);
    DEFINE SI_APLICA  CHAR(1);
    DEFINE NO_APLICA  CHAR(1);
    DEFINE rCodigoRetornoSP	CHAR(3);

    DEFINE 	g_Remanente		MONEY;
    DEFINE  g_IntMoraCob   	MONEY;
    DEFINE  g_IntVencCob	MONEY;
    DEFINE  g_CapVencCob    MONEY;
    DEFINE  g_IntVigCob		MONEY;
    DEFINE  g_CapVigCob		MONEY;
    DEFINE  g_Impuesto		MONEY;
    DEFINE  g_Comision		MONEY;
    DEFINE	g_Seguro		MONEY;
    
    DEFINE vNumCliente CHAR(20);
    DEFINE vNumCuenta CHAR(20);   
    DEFINE vExecuteSQL CHAR(1150);    
    DEFINE vFechaActualIntegral   DATE;
    DEFINE vFechaEncabezado CHAR(10);
	
	DEFINE vContadorRegistros INTEGER;
	DEFINE vContadorRegistrosMonto DECIMAL;
	DEFINE vContadorRegistrosNoPagado INTEGER;
	DEFINE vContadorRegistrosMontoNoPagado DECIMAL;
    
    LET NUMERO_TRANSACCION_DEBITO  = '0326'; --Numero obtenido de bdinteg:si_transacc
    LET NUMERO_TRANSACCION_CREDITO = '7860'; --Numero obtenido de bdinteg:si_transacc
    LET LEYENDA_DEFINIDA_BUEN_FIN = 'Premio Hacienda Buen Fin';
    LET CODIGO_RETORNO = '00000';
    LET MENSAJE_RETORNO = 'Aplicacion de premios.';
    LET RUTA_ORIGEN = '/RESPALDOSNEW/';
    LET ABREVIATURA_CREDITO = 'C';
    LET ABREVIATURA_DEBITO  = 'D';
    LET APLICAR_PREMIO_MAYOR = '';
    LET SI_APLICA = 'S';
    LET NO_APLICA = 'N';
    LET PREFIJO_SCRIPTS = 'buenfin_';
    
    LET vTipoTarjeta = '';
    LET vTransaccionAplicada = '';
    LET vConsecutivo = 0;
    LET vPeriodoFiscal = '';
    LET vstporeg = '';
    LET vsemisor = '';
    LET vsfecha = '';
    LET vNumTarjeta = '';
    LET vMontoTrx = '';
    LET vSecuencia	= '';
    LET vsreferencia = '';
    LET vIdRetailer	= '';
    LET vMontoPremio = '';
    LET vCodigoDevolucion = '0'; 
    LET vNumeroCta = '';    
    LET vFolioSuc = '';
    LET vFlujoEnTransaccion = 'F';
    
    LET vNumCliente = NULL;
    LET vNumCuenta = NULL;
    LET MONTO_MAX_PREMIO_MAYOR = '000000000000';
    LET rCodigoRetornoSP = '';
    LET vContadorRegistros = 0;
    LET vExecuteSQL	= '';
    LET vFechaActualIntegral = NULL;
    LET vFechaEncabezado = '';
	
	LET vContadorRegistrosMonto = 0 ;
	LET vContadorRegistrosNoPagado = 0;
	LET vContadorRegistrosMontoNoPagado = 0;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        
           --SET DEBUG FILE TO RUTA_ORIGEN || 'excepcion_sp_bf_aplicar_premios.out';
           --TRACE ON;            
            
            EXECUTE PROCEDURE bditarjeta:sp_bf_registrar_bitacora(vNumTarjeta,CODIGO_RETORNO, MENSAJE_RETORNO );
            
            LET CODIGO_RETORNO   = SQL_ERR;
            LET MENSAJE_RETORNO  = ERROR_INFO;            
            RETURN CODIGO_RETORNO, NVL(MENSAJE_RETORNO,'');

        END EXCEPTION;

        	--SET DEBUG FILE TO RUTA_ORIGEN || 'sp_bf_aplicar_premios.out';
        	--TRACE ON;
       
       
        IF( pAnioFiscal IS NULL) THEN
            LET CODIGO_RETORNO   = '0001';
            LET MENSAJE_RETORNO  = 'Es indispensable ingresar el aÃ±o fiscal.';
            RETURN CODIGO_RETORNO, NVL(MENSAJE_RETORNO,'');
        END IF
       
        FOREACH  WITH HOLD

            SELECT
                consecutivo, periodofiscal, numtarjeta, montoarchivo, 
                    secuenciaarchivo, idretailer_archivo, montopremio,
                        tipo_tarjeta, numcuenta, tranaplica, ordenabono
            INTO
                vConsecutivo, vPeriodoFiscal, vNumTarjeta, vMontoTrx,
                    vSecuencia, vIdRetailer, vMontoPremio,
                        vTipoTarjeta, vNumeroCta,  vTransaccionAplicada, vFolioSuc
            FROM bditarjeta:tbl_bf_sorteo_sat
                WHERE periodofiscal = pAnioFiscal
                    AND montopremio <> '000000000000'
                        AND ordenabono <> '00000000000000000000000'
                            AND validaciones IN ('V', 'P')
            ORDER BY consecutivo

            BEGIN WORK;
                
                LET APLICAR_PREMIO_MAYOR = NO_APLICA;
            
                SELECT valor3 
                    INTO MONTO_MAX_PREMIO_MAYOR
                FROM bditarjeta:td_parametro 
                    WHERE clave = 'max_premio_buenfin';                
            

                IF (vTransaccionAplicada = '0000') THEN        
                    LET CODIGO_RETORNO = '00001';
                    LET MENSAJE_RETORNO = 'El numero de tarjeta no tiene transaccion asignada para el premio.';
                    EXECUTE PROCEDURE bditarjeta:sp_bf_registrar_bitacora(vNumTarjeta,CODIGO_RETORNO, MENSAJE_RETORNO );            
                    
                ELIF (vTransaccionAplicada = NUMERO_TRANSACCION_DEBITO) THEN
                    
                    EXECUTE PROCEDURE bdicheq:abono_ref(
                                    '001',						-- empresa
                                    '9290',						-- sucursal
                                    'informix', 				-- usuario
                                    NUMERO_TRANSACCION_DEBITO,	-- transaccion aplica
                                    '0000', 					-- transaccion sucursal
                                    TRIM(vFolioSuc), 			-- Folio suc
                                    vNumeroCta, 			-- numero de cuenta
                                    '0', 						-- numero de documento
                                    ((vMontoPremio::MONEY)),		-- monto total
                                    ((vMontoPremio::MONEY)),		-- monto firme
                                    0,							-- monto sbc
                                    0,							-- monto remesa
                                    0,							-- Dias retenido
                                    '01',						-- divisa
                                    LEYENDA_DEFINIDA_BUEN_FIN,	-- Referencia
                                    ' ',						-- numero de tarjeta
                                    ' ' 						-- usuario autoriza
                        )
                    INTO rCodigoRetornoSP;
                                                        
                        IF (rCodigoRetornoSP <> '000') THEN
                            
                            UPDATE bditarjeta:tbl_bf_sorteo_sat
                                SET retcentral = rCodigoRetornoSP,
                                codigodevolucion = '0'
                            WHERE
                                consecutivo = vConsecutivo;
                                
                            LET CODIGO_RETORNO = '00001';
                            LET MENSAJE_RETORNO = 'Error|sp abono_ref|debito|Sin devolucion del premio';                             
                            EXECUTE PROCEDURE bditarjeta:sp_bf_registrar_bitacora(vNumTarjeta,CODIGO_RETORNO, MENSAJE_RETORNO );
                            
                        ELSE
                    
                            LET CODIGO_RETORNO = '00000';
                            UPDATE bditarjeta:tbl_bf_sorteo_sat
                                SET retcentral = CODIGO_RETORNO,
                                codigodevolucion = '1'
                            WHERE
                                consecutivo = vConsecutivo;
                    
                        END IF
            
                    ---Creditos
                ELIF ( vTransaccionAplicada = NUMERO_TRANSACCION_CREDITO ) THEN
                    
                    LET rCodigoRetornoSP = '';
                    
                    EXECUTE PROCEDURE bdicred:principal(
                                                '001',							-- Empresa
                                                vNumeroCta,					-- Numero de credito
                                                1,								-- Tipo de pago
                                                ((vMontoPremio::MONEY)),	    -- Monto
                                                'informix',						-- Usuario
                                                '9290',							-- Sucursal
                                                TRIM(vFolioSuc),			    -- Folio_suc
                                                NUMERO_TRANSACCION_CREDITO		-- Transaccion aplica
                        )
                    INTO rCodigoRetornoSP, g_Remanente, g_IntMoraCob, g_IntVencCob, g_CapVencCob, g_IntVigCob, g_CapVigCob, g_Impuesto, g_Comision, g_Seguro;
                    
                    IF (rCodigoRetornoSP <> '000') THEN
                        
                        UPDATE bditarjeta:tbl_bf_sorteo_sat
                            SET retcentral = rCodigoRetornoSP,
                                codigodevolucion = '0'
                        WHERE consecutivo = vConsecutivo;                        
                        
                        LET MENSAJE_RETORNO = 'Error|sp principal|credito';
                        EXECUTE PROCEDURE bditarjeta:sp_bf_registrar_bitacora(vNumTarjeta,CODIGO_RETORNO, MENSAJE_RETORNO );                     
                    
                    ELSE
                        LET CODIGO_RETORNO = '00000';
                        
                        UPDATE bditarjeta:tbl_bf_sorteo_sat
                            SET retcentral = CODIGO_RETORNO,
                                codigodevolucion = '1'
                        WHERE consecutivo = vConsecutivo;                   
        
                    END IF;  --Cierre de creditos 

            END IF;

                    LET APLICAR_PREMIO_MAYOR = '';
                    LET vMontoPremio = '';
                    LET vNumCuenta = '';
                    LET vNumeroCta = '';
                    LET vFolioSuc = '';
                    LET vNumCliente = '';
                    LET vNumeroCta = '';
                    LET vNumCuenta = '';
                    LET vFolioSuc = '';
                    LET rCodigoRetornoSP = '';
                    COMMIT WORK;
                    
            END FOREACH;
       
        ---C) Generacion del archivo de salida y que es entregado a eglobal.    
        SELECT fecha_hoy
            INTO vFechaActualIntegral
        FROM bdinteg:si_fechas
            WHERE empresa = '001';        
    
        --Este numero consiste en el total de registros que debe presentarse en el pie del archivo.
        --Y el numero debe tener 12 caracteres en caso contrario se rellena de ceros.
        
		

		---Premios Pagados
		LET vContadorRegistros = 0;	
		LET vContadorRegistrosMonto = 0 ;
      
	    SELECT NVL(SUM(montointercard),0.0) AS monto, NVL(COUNT(codigodevolucion),0.0) as num_txn
		INTO vContadorRegistrosMonto ,vContadorRegistros
        FROM bditarjeta:tbl_bf_sorteo_sat
            WHERE
                codigodevolucion = '1'
				AND periodofiscal = pAnioFiscal;
				
		----- Premios No Pagados		
		LET vContadorRegistrosMontoNoPagado = 0 ;
		LET vContadorRegistrosNoPagado = 0 ;			
	    SELECT NVL(SUM(montointercard),0.0) AS monto, NVL(COUNT(codigodevolucion),0.0) as num_txn
		INTO vContadorRegistrosMontoNoPagado ,vContadorRegistrosNoPagado
        FROM bditarjeta:tbl_bf_sorteo_sat
            WHERE
                codigodevolucion = '0'
				AND periodofiscal = pAnioFiscal;
		

    --/ rm -f sin advertencia en consola en caso de no existir el archivo
        LET vExecuteSQL = '';
        LET vExecuteSQL ='rm -f '||RUTA_ORIGEN||'EntregaSAT'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL ='rm -f '||RUTA_ORIGEN||'ReporteGeneralBuenFin'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vFechaEncabezado = DAY(vFechaActualIntegral)||'/'||LPAD(MONTH(vFechaActualIntegral),2,"0")||'/'||YEAR(vFechaActualIntegral);
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "00|1|           SAT|FECHA|'||TRIM(vFechaEncabezado)||'|" >> '||RUTA_ORIGEN||'EntregaSAT'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = 'chmod 777 ' ||RUTA_ORIGEN||'EntregaSAT'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
        
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||
                    ' UNLOAD TO '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'SAT_BuenFin.unl '||
                    ' SELECT tporeg, banemisor, '||
                    '     fechatransaccion, ' ||
                    '     numtarjeta, ' ||
                    '	case when montoarchivo = \"000000000000\" then \"000000000000\" '||
					'	when montoarchivo <> \"000000000000\" '||
					'   then LPAD( ( substr (montoarchivo, 1, 10)::INTEGER||\".\"||substr (montoarchivo, 11, 2)), 12, \"0\")'||
					'   end as monto_archivo, ' ||
					'   secuenciaarchivo, numrefarchivo, ' || 
					'	case when montopremio = \"000000000000\" then \"000000000000\" '||
					'	when montopremio <> \"000000000000\" '||
					'   then LPAD( ( substr (montopremio, 1, 12)::INTEGER||\".\"||substr (montopremio, 11, 2)), 12, \"0\")'||
					'   end as monto_premio, ' ||
					'   ordenabono, ' ||
                    '   codigodevolucion, codpostal, estado, poblacion, ' ||
					' CASE ' ||
					'     WHEN LENGTH(idretailer_archivo) = 4  THEN \"   \"||idretailer_archivo' ||
					'     WHEN LENGTH(idretailer_archivo) = 5  THEN \"  \"||idretailer_archivo' ||
					'     WHEN LENGTH(idretailer_archivo) = 6  THEN \" \"||idretailer_archivo' ||
                    '     ELSE idretailer_archivo ' ||
                    '     END as id_negocio ' ||
                    ' FROM bditarjeta:tbl_bf_sorteo_sat '||
                    '      WHERE periodofiscal = ''"'|| pAnioFiscal ||'"'';">'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_sat_buenfin.sql';
        SYSTEM vExecuteSQL;
		
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'chmod 777 ' ||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_sat_buenfin.sql';
        SYSTEM vExecuteSQL;
        
		
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "Sorteo|Fecha|Descripcion|NÃºmero de transacciones| Monto de premio|" >> '||RUTA_ORIGEN||'ReporteGeneralBuenFin'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = 'chmod 777 ' ||RUTA_ORIGEN||'ReporteGeneralBuenFin'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
		
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; ' ||
                ' UNLOAD TO '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'reporte_buen_fin.unl '||
                '    SELECT periodofiscal, fechatransaccion, '||
                ' CASE '||
                '      WHEN codigodevolucion = \"0\" THEN \"No premiadas\" '||
                '      WHEN codigodevolucion = \"1\" THEN \"Premiadas\" '||
                ' END as Descripcion,'||
                '  COUNT(montopremio)::INTEGER as numero_transacciones, SUM(montopremio::MONEY) as monto_premios '|| 
                '        FROM bditarjeta:tbl_bf_sorteo_sat  '||                
                '      WHERE periodofiscal = ''"'|| pAnioFiscal ||'"'' GROUP BY 1, 2, 3  ORDER BY 2, 3 DESC;">'||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_reporte_buen_fin.sql';                
        SYSTEM vExecuteSQL;
		
		LET vExecuteSQL = '';
        LET vExecuteSQL = 'chmod 777 ' ||RUTA_ORIGEN||PREFIJO_SCRIPTS||'script_reporte_buen_fin.sql'; 
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_ORIGEN||PREFIJO_SCRIPTS||"script_sat_buenfin.sql";
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'dbaccess bditarjeta '||RUTA_ORIGEN||PREFIJO_SCRIPTS||"script_reporte_buen_fin.sql";
        SYSTEM vExecuteSQL;

        LET vExecuteSQL = '';
        LET vExecuteSQL = 'cat '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'SAT_BuenFin.unl >> '||RUTA_ORIGEN||'EntregaSAT'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'cat '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'reporte_buen_fin.unl >> '||RUTA_ORIGEN||'ReporteGeneralBuenFin'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'echo "'||vContadorRegistros||'|'||vContadorRegistrosMonto||'|'||vContadorRegistrosNoPagado||'|'||vContadorRegistrosMontoNoPagado||'|"  >> '||RUTA_ORIGEN||'EntregaSAT'||pAnioFiscal||'.txt';
        SYSTEM vExecuteSQL;
        
        LET vExecuteSQL = '';
        LET vExecuteSQL = 'rm '||RUTA_ORIGEN||PREFIJO_SCRIPTS||'*';
        SYSTEM vExecuteSQL;
		

        LET  MENSAJE_RETORNO = 'Proceso completado y archivos generados: EntregaSAT'||pAnioFiscal||'.txt';


        RETURN CODIGO_RETORNO, NVL(MENSAJE_RETORNO,'');
        
    END

END PROCEDURE
DOCUMENT
'AUTOR: Armando Garcia Ortiz',
'Proyecto: Sorteo El Buen Fin',
'Fecha de creacion: 19.noviembre.2019',
'Descripcion: Procedimiento principal que inicia el proceso, carga e invocacion para otorgar los premios.',
'Se generan dos archivos: Uno para entregar a el SAT y el segundo es un reporte general de premiados y no premiados.',
'Base de datos: bditarjeta',
'#2. Actualizacion',
'Fecha de modificacion: 23.diciembre.2020',
'Se actualiza el nombre de la ruta donde se guarda el archivo del sorteo El Buen Fin',
'#3. Actualizacion',
'Fecha de modificacion: 22.Diciembre.2021',
'Se actualiza el SP para informar centavos y de adecua fecha transaccion en todos los registros dentro del proceso Buen Fin 2021.',
'#4. Actualizacion',
'Fecha de modificacion 20-12-2022 MBG',
'Se actualiza SP para cuadrar layout enviado por eglobal para enviar archivo cuadrado a SAT',
'#5. Actualizacion',
'Fecha de modificacion 26-12-2023 LDBZ',
'Se actualiza SP para manejar los montos a tipo MONEY sin los 0 de relleno ',
'#6. actualizaciÃ³n',
'Fecha de modificaciÃ³n 19-12-2025',
'Se actualiza SP quitando la divisiÃ³n del valor de lo monto de Tipo MONEY'
;

CREATE PROCEDURE "informix".sp_acumuladocheques(pindica VARCHAR(1))
--Parametro "B" indica que es reporte mensual de tarjetas de banda
RETURNING CHAR(5), CHAR(100)

	DEFINE sql_err				INTEGER;
	DEFINE isam_err				INTEGER;
	DEFINE error_info			CHAR(100);
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensajeRetorno		CHAR(100);
	DEFINE vfecha_inicio		DATETIME YEAR to FRACTION(5);
	DEFINE vfecha_fin		    DATETIME YEAR to FRACTION(5);

	DEFINE vDiaActual			CHAR(2);	
	DEFINE vEsLunes				INTEGER;

	DEFINE vProducto		CHAR(4);
	DEFINE vTransacc		CHAR(4);
	DEFINE vMonto			MONEY;
	DEFINE vCantidad		INTEGER;
	DEFINE vDescripcion		CHAR(50);
	DEFINE vPeriodo			CHAR(6);

	LET sql_err			= 0;
	LET isam_err		= 0;
	LET error_info		= '';
	LET vCodigoRetorno	= '0000';
	LET vMensajeRetorno = 'Proceso Exitoso';

	LET vProducto		= '';
	LET vTransacc		= '';
	LET vMonto			= 0;
	LET vCantidad		= 0;
	LET vDescripcion	= '';
	LET vPeriodo		= '';

BEGIN

	-- MANEJO DEL ERROR
	ON EXCEPTION SET sql_err, isam_err, error_info

		--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
		--TRACE ON;

		RETURN sql_err, isam_err || ' ' || error_info;

	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;  
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/resplogifx/sp_acumuladocheques_err_" || YEAR(CURRENT) || MONTH(CURRENT) || DAY(CURRENT) || ".out" WITH APPEND;
	--TRACE ON;

	IF ((
		NOT EXISTS (
			SELECT fecha 
			FROM bdicheq:sc_contproc 
			WHERE proceso = 'pasomovshist' 
			AND Fecha = TODAY - 1 
		)
	)) THEN 
		-- Se valida el estatus del pase de movimientos historico de cheques
		LET vCodigoRetorno = '0001';
		LET vMensajeRetorno = 'No se ha realizado el pase de movimientos historicos de debito';
		RETURN vCodigoRetorno, vMensajeRetorno;	
	END IF;

	IF pindica = 'B' THEN

		LET vDiaActual = LPAD(DAY(CURRENT),2,'0');
					--PARA PRUEBAS SE IGUALA EL IF
					  --IF '02' = '02' THEN
					--IF vDiaActual = '02' THEN	

		--	IF vDiaActual = '02' OR '01' = '01' THEN	  /*Prueba desarrollo*/
		 IF vDiaActual = '02' OR vDiaActual = '01' THEN	  

						SELECT fecha_inicio::DATE,fecha_final::DATE
						INTO vfecha_inicio,vfecha_fin
						FROM intercard:tb_control_reporteria_general 
						WHERE nombre_reporte ='AcumuladoChequesM';

								IF vfecha_fin < CURRENT THEN
									UPDATE intercard:tb_control_reporteria_general	
									SET fecha_inicio_creacion_reporte = CURRENT
									WHERE nombre_reporte = 'AcumuladoChequesM';
									EXECUTE PROCEDURE bditarjeta:sp_acumuladocheques_mensual (vfecha_inicio,vfecha_fin) INTO vCodigoRetorno, vMensajeRetorno;
										IF vCodigoRetorno = '0000' THEN 
											UPDATE intercard:tb_control_reporteria_general 
											SET fecha_inicio = ADD_MONTHS(fecha_inicio,+1),
											fecha_final = ADD_MONTHS(fecha_final,+1),
											reporte_creado = 'T',codigo_devuelto_spl = vCodigoRetorno
											WHERE nombre_reporte = 'AcumuladoChequesM';
											INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_mensual',vCodigoRetorno ||' '||  vMensajeRetorno);

										ELSE
											LET vCodigoRetorno	= '0004';
											LET vMensajeRetorno = 'Fallo en SPL acumuladocheques_mensual';	
											INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_mensual',vCodigoRetorno ||' '||  vMensajeRetorno);
		END IF;
								ELSE
									LET vCodigoRetorno	= '0003';
									LET vMensajeRetorno = 'El reporte mensual se creo con anterioridad';

									INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_mensual',vCodigoRetorno ||' '||  vMensajeRetorno);

		END IF;
		ELSE 
					
						SELECT fecha_inicio,fecha_final
						INTO vfecha_inicio,vfecha_fin
						FROM intercard:tb_control_reporteria_general 
						WHERE nombre_reporte = 'AcumuladoChequesS';

						IF vfecha_fin <= CURRENT THEN 
									UPDATE intercard:tb_control_reporteria_general	
									SET fecha_inicio_creacion_reporte = CURRENT
									WHERE nombre_reporte = 'AcumuladoChequesS';
									EXECUTE PROCEDURE bditarjeta:sp_acumuladocheques_semanal (vfecha_inicio,vfecha_fin) INTO vCodigoRetorno, vMensajeRetorno;
									IF vCodigoRetorno = '0000' THEN 
										UPDATE intercard:tb_control_reporteria_general 
										SET fecha_inicio = DATE(vfecha_inicio) + 7 UNITS DAY,
										fecha_final=DATE(vfecha_inicio) + 14 UNITS DAY,
										reporte_creado = 'T',codigo_devuelto_spl = vCodigoRetorno
										WHERE nombre_reporte = 'AcumuladoChequesS';
										 INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_semanal',vCodigoRetorno ||' '||  vMensajeRetorno);
									ELSE
										LET vCodigoRetorno	= '0004';
										LET vMensajeRetorno = 'Error Controlado';	
                                        INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_semanal',vCodigoRetorno ||' '||  vMensajeRetorno);
									END IF;
						ELSE
									LET vCodigoRetorno	= '0003';
									LET vMensajeRetorno = 'Error Controlado fecha final es mayor que la fecha actual';		

                                    INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques_semanal',vCodigoRetorno ||' '|| vMensajeRetorno);

			END IF;

		END IF;

	ELSE 

		LET vCodigoRetorno	= '0002';
		LET vMensajeRetorno = 'El paremetro de ejecucion no es el correcto, valor diferente de B';

		  INSERT INTO intercard:tb_bitacora_reporteria_tarjetas(fecha, nombre_spl, mensaje) VALUES(CURRENT,'sp_acumuladocheques',vCodigoRetorno || vMensajeRetorno);
		RETURN vCodigoRetorno, vMensajeRetorno;

	END IF;

	RETURN vCodigoRetorno, vMensajeRetorno;
END;

END PROCEDURE;