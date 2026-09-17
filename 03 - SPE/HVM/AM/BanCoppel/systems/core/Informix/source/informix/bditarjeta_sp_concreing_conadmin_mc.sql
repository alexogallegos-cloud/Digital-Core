CREATE PROCEDURE "informix".sp_concreing_conadmin_mc(
           psistema 				CHAR(1),
           pfecha_archivo 			DATE,
           pbandera_reverso 		CHAR(1),
           pnumtarjeta 				CHAR(16),
           pfolio_mov 				CHAR(16),
           parchivo_origen 			CHAR(3),
           pnombrearchivo 			CHAR(30),
           ptipo_mov      			CHAR(1),
           pmonto325     			MONEY(16,2),
           psecuencia_extendida 	CHAR(15),
           pfechatransaccion 		DATETIME YEAR TO FRACTION (5) ,
           pmontointercard 			MONEY(16,2),
           pidterminal 				CHAR(16),
           ptransacion_aplica 		CHAR(4),
           pnomArchivoCom 			CHAR(23),
           pnumempleado 			CHAR (8),
           psIdProcesador 			CHAR (5)
    )
	
    RETURNING VARCHAR(6), VARCHAR(80), INTEGER;

    DEFINE  SQL_ERR          INTEGER;
    DEFINE  ISAM_ERR         INTEGER;
    DEFINE  ERROR_INFO       VARCHAR(80);
    DEFINE  P_COD_RET        VARCHAR(6);
    DEFINE  P_MENSAJE        VARCHAR(80);
    DEFINE  P_BANDERA        VARCHAR(1);
    DEFINE  id_proceso       INTEGER;


    DEFINE vsTarjeta CHAR (20);
    DEFINE vsCuenta CHAR (20);
    DEFINE vsTxnLiberacion CHAR (4);
    DEFINE vsFolioSIF CHAR (16);
    DEFINE vmMontoSIF MONEY(16,6);
    DEFINE vsTransacC CHAR(4);
    DEFINE vsSecuenciaAut CHAR(15);
    DEFINE vsProdTarjeta CHAR (4);
    DEFINE vsCuentaC CHAR (40);
    DEFINE vsCuentaA CHAR (40);
    DEFINE vsSucursal CHAR (4);
    DEFINE vsTipoOperacion CHAR (1);
    DEFINE vsIdTerminal CHAR (4);
    DEFINE vsSecIntercard CHAR (15);
    DEFINE vdtFechaHoraInAuth DATETIME YEAR TO FRACTION (5) ;
    DEFINE vmMontoIntercard MONEY(16,6);
    DEFINE dtFecha_Hoy_Integral DATE;
	DEFINE vsProducto CHAR(1);


    BEGIN
	
        ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
          LET P_COD_RET    = SQL_ERR;
          LET P_MENSAJE  = ERROR_INFO;
          RETURN P_COD_RET, P_MENSAJE,id_proceso;
        END EXCEPTION;

       --SET DEBUG FILE TO "/informix/LVRQ/seven_new/debug/CONADMIN.out";
       --TRACE ON;

        LET id_proceso = 8;
        LET P_COD_RET = '00000';
        LET P_MENSAJE = 'PROCESO EXITOSO';
        LET vsCuenta = '';
        LET vsTxnLiberacion = '';
        LET vsFolioSIF = '';
        LET vmMontoSIF = 0.00;
        LET vsSecuenciaAut = '';
        LET vsTransacC = '';
        LET vsProdTarjeta = '';
        LET vsCuentaC = '';
        LET vsCuentaA = '';
        LET vsTarjeta = '';
        LET vsTipoOperacion = '';
        LET vsIdTerminal = '';
        LET vsSecIntercard = '';
        LET vdtFechaHoraInAuth = CURRENT;
        LET vmMontoIntercard = 0.00;
        LET dtFecha_Hoy_Integral = '';
		LET vsProducto = ''; 

		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
		--TRACE 'Este es el Folio_regulatorio = ' || psecuencia_extendida;
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy 
            INTO dtFecha_Hoy_Integral 
                FROM bdinteg:"informix".Si_Fechas
                    WHERE empresa = '001';
                    
        LET dtFecha_Hoy_Integral = CURRENT::DATE;
	
 
        IF (parchivo_origen <> 'MCO' ) THEN  -- TXN ATM'S
            
            LET P_COD_RET = '00001';
            LET P_MENSAJE = 'Registro no corresponde a MCO o el monto es menor o igual a cero';
            
            RETURN P_COD_RET, P_MENSAJE, id_proceso;
			
        END IF;
   
   
        LET vsTarjeta = pnumtarjeta;
		
		--TRACE 'pfolio_mov = ' || pfolio_mov;
	
	IF ( pmontointercard > 0.00 ) THEN
	
        IF (psistema == 'D') THEN --DEBITO

            
			SELECT FIRST 1 Cuenta, ProdTarjeta, psistema
                INTO vsCuenta, vsProdTarjeta,vsProducto
            FROM BdiCheq:"informix".Sc_Tarjeta
                WHERE Empresa = '001' 
                AND Num_Tarjeta = vsTarjeta;

			IF (psIdProcesador ='OXXO') THEN 
			
			SELECT FIRST 1 Cuenta, Transacc_Suc, Folio_Suc, Monto_Tot, TransacC,cancelad
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC,pbandera_reverso
			FROM BdiCheq:"informix".Sc_Movhis
				WHERE Empresa = '001'
				AND transacc = '0482'
				AND cuenta = vsCuenta
				AND Folio_Suc = pfolio_mov;
				
			ELIF (psIdProcesador ='SEVEN') THEN 
			
			SELECT FIRST 1 Cuenta, Transacc_Suc, Folio_Suc, Monto_Tot, TransacC,cancelad
				INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC,pbandera_reverso
				FROM BdiCheq:"informix".Sc_Movhis
				WHERE Empresa = '001'
				AND transacc = '0491'
				AND cuenta = vsCuenta
			AND Folio_Suc = pfolio_mov;
			
			END IF;
              
		ELSE  -- 'C' -- CREDITO
        
			SELECT FIRST 1 num_credito, ProdTarjeta, psistema
                INTO vsCuenta, vsProdTarjeta, vsProducto
            FROM BdiCred:"informix".Sd_Tarjeta
                WHERE Empresa = '001' 
                AND Num_Tarjeta = vsTarjeta;
				
			IF (psIdProcesador ='OXXO') THEN 
			
				SELECT FIRST 1 Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc,reversado
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC,pbandera_reverso
				FROM BdiCred:"informix".Sd_Movhis
					WHERE Empresa = '001'
					AND Transacc_Suc ='6283'
					AND codigo_ref = '1'
					AND codigo_fun = 701
					AND Folio_Suc = pfolio_mov
					AND Num_Credito = vsCuenta;
				
			ELIF (psIdProcesador ='SEVEN') THEN 
			
				SELECT FIRST 1 Num_Credito, Transacc_Suc, Folio_Suc, Monto, TransacC_Suc,reversado
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC,pbandera_reverso
				FROM BdiCred:"informix".Sd_Movhis
					WHERE Empresa = '001'
					AND Transacc_Suc ='6284'
					AND codigo_ref = '1'
					AND codigo_fun = 702
					AND Folio_Suc = pfolio_mov
					AND Num_Credito = vsCuenta;
			END IF;
            
		END IF;
	
				LET parchivo_origen =	NVL (parchivo_origen, '');
                LET pnombrearchivo = 	(TRIM(NVL (pnombrearchivo, '')));
                LET pnomArchivoCom = 	TRIM(NVL (pnomArchivoCom, ''));
                LET vsProducto = 		NVL (vsProducto, '');
                LET pfecha_archivo = 	NVL (pfecha_archivo, CURRENT::DATE);
                LET vsProdTarjeta = 	NVL (vsProdTarjeta, '');
                LET vsTarjeta = 		 NVL (vsTarjeta, '');
                LET vsCuenta = 			 NVL (vsCuenta, '');
                LET ptipo_mov = 		 NVL (ptipo_mov, '');
                LET ptransacion_aplica = NVL (ptransacion_aplica, '');
                LET pfolio_mov = NVL (pfolio_mov, '');
                LET pmonto325 = NVL (pmonto325, 0.0);
                LET pbandera_reverso = NVL (pbandera_reverso, '');
                LET vsTxnLiberacion = NVL (vsTxnLiberacion, '');
                LET vsCuentaC = NVL (vsCuentaC, '');
                LET vsCuentaA = NVL (vsCuentaA, '');
                LET vsFolioSIF = NVL (vsFolioSIF, '');
                LET vmMontoSIF = NVL (vmMontoSIF, 0.0);
                LET vsSecIntercard = NVL (vsSecIntercard, '');
                LET vmMontoIntercard = NVL (vmMontoIntercard, 0.0);
                LET vdtFechaHoraInAuth = NVL (vdtFechaHoraInAuth, CURRENT);
                LET vsIdTerminal = NVL (vsIdTerminal, '');
                LET vsTipoOperacion = NVL (vsTipoOperacion, '');
                LET pnumempleado = NVL (pnumempleado, '');
				
            --GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
            INSERT INTO InterCard:"informix".conciliacion_admin_mc
            (
                ArchivOorigen,
                NomArchivo325,
                NomArchivocom,
                FechaRegistro,
                Producto,
                Fecha,
                ProdTarjeta,
                Tarjeta,
                Cuenta,
                TipoMov,
                Tran_Central,
                Folio325,
                Monto325,
                Estatus,
                TxnLiberacion,
                CuentaC,
                CuentaA,
                FolioSIF,
                MontoSIF,
                SecIntercard,
                MontoIntcrd,
                FechaHoraInAuth,
                IdTerminal,
                TipoOperacion,
                Usuario
            )
            VALUES
            (
                parchivo_origen,
                pnombrearchivo,
                pnomArchivoCom,
                CURRENT::DATE,
                vsProducto,
                pfecha_archivo,
                vsProdTarjeta,
                vsTarjeta,
                vsCuenta,
                ptipo_mov,
                ptransacion_aplica,
                pfolio_mov,
                pmonto325,
                pbandera_reverso,
                vsTxnLiberacion,
                vsCuentaC,
                vsCuentaA,
                vsFolioSIF,
                vmMontoSIF,
                vsSecIntercard,
                vmMontoIntercard,
                vdtFechaHoraInAuth,
                vsIdTerminal,
                vsTipoOperacion,
                pnumempleado
            );
         
	END IF;
		
		RETURN P_COD_RET, P_MENSAJE, id_proceso;
		
    END

END PROCEDURE;