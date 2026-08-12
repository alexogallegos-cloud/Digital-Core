CREATE PROCEDURE "informix".sp_concreing_conadmin_atms(
           psistema char(1),
           pfecha_archivo date,
           pbandera_reverso char(1),
           pnumtarjeta char(16),
           pfolio_mov char(16),
           parchivo_origen char(3),
           pnombrearchivo char(23),
           ptipo_mov      char(1),
           pmonto325      money(16,2),
           psecuencia_extendida char(15),
           pfechatransaccion DATETIME YEAR TO FRACTION (5) ,
           pmontointercard money(16,2),
           pidterminal char(16),
           ptransacion_aplica char(4),
           pnomArchivoCom CHAR(23),
           pnumempleado CHAR (8)
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

        --SET DEBUG FILE TO "/ifxsif01/LVRQ/debug/CONADMIN.out";
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

		
		--TRACE 'Esto es Folio Suc '||  pfolio_mov||psecuencia_extendida||'monto ' || pmontointercard;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
        
        --OBTIENE LA FECHA HOY DEL SISTEMA CENTRAL INTEGRAL
        SELECT LIMIT 1 Fecha_Hoy 
            INTO dtFecha_Hoy_Integral 
                FROM bdinteg:"informix".Si_Fechas
                    WHERE empresa = '001';
                    
        LET dtFecha_Hoy_Integral = CURRENT::DATE;
	
 
        IF (parchivo_origen <> 'IST' ) THEN  -- TXN ATM'S
            
            LET P_COD_RET = '00001';
            LET P_MENSAJE = 'Registro no corresponde a IST o el monto es menor o igual a cero';
            
            RETURN P_COD_RET, P_MENSAJE, id_proceso;
			
        END IF;
   
   
        LET vsTarjeta = pnumtarjeta;
		
	--TRACE 'Aqui esta tarjeta '|| pnumtarjeta;
	--TRACE 'Aqui esta reverso** '|| pbandera_reverso||'*** aqui';
	--TRACE 'Aqui esta monto ** '|| pmontointercard;
	
	
	IF ( pmontointercard > 0.00 AND pbandera_reverso != 'F') THEN
	
        IF (psistema == 'D') THEN --DEBITO
            
			SELECT FIRST 1 Cuenta, ProdTarjeta, psistema
                INTO vsCuenta, vsProdTarjeta,vsProducto
            FROM BdiCheq:"informix".Sc_Tarjeta
                WHERE Empresa = '001' 
                AND Num_Tarjeta = vsTarjeta;
					
			SELECT FIRST 1 Cuenta, Transacc_Suc, Folio_Suc, Monto_Tot, TransacC,cancelad
					INTO vsCuenta, vsTxnLiberacion, vsFolioSIF, vmMontoSIF, vsTransacC,pbandera_reverso
			FROM BdiCheq:"informix".Sc_Movhis
				WHERE Empresa = '001'
				AND transacc = '0952'
				AND cuenta = vsCuenta
				AND Folio_Suc = pfolio_mov;
                
		ELSE  -- 'C' -- CREDITO
			SELECT FIRST 1 num_credito, ProdTarjeta, psistema
			INTO vsCuenta, vsProdTarjeta, vsProducto
			FROM BdiCred:"informix".Sd_Tarjeta
			WHERE Empresa = '001' 
			AND Num_Tarjeta = vsTarjeta;
			
		
			SELECT  '6952', folio_suc, reversado, sum(Monto)
			INTO vsTxnLiberacion, vsFolioSIF, pbandera_reverso, vmMontoSIF
			FROM BdiCred:"informix".Sd_Movhis
			WHERE codigo_fun = '002'
			and codigo_ref in (113,114)
			and num_credito = vsCuenta
			AND Folio_Suc = pfolio_mov
			AND Nro_Tarjeta = vsTarjeta
			group by 1,2,3;
            
		END IF;
	
            --GUARDA EL REGISTRO EN LA TABLA DE CONCILIACION ADMINISTRATIVA INTERREDES
            INSERT INTO InterCard:"informix".atm_conciliacion_admin
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
                NVL (parchivo_origen, ''),
                (TRIM(NVL (pnombrearchivo, ''))),
                TRIM(NVL (pnomArchivoCom, '')),
                CURRENT::DATE,
                NVL (vsProducto, ''),
                NVL (pfecha_archivo, CURRENT::DATE),
                NVL (vsProdTarjeta, ''),
                NVL (vsTarjeta, ''),
                NVL (vsCuenta, ''),
                NVL (ptipo_mov, ''),
                NVL (ptransacion_aplica, ''),
                NVL (pfolio_mov, ''),
                NVL (pmonto325, 0.0),
                NVL (pbandera_reverso, ''),
                NVL (vsTxnLiberacion, ''),
                NVL (vsCuentaC, ''),
                NVL (vsCuentaA, ''),
                NVL (vsFolioSIF, ''),
                NVL (vmMontoSIF, 0.0),
                NVL (vsSecIntercard, ''),
                NVL (vmMontoIntercard, 0.0),
                NVL (vdtFechaHoraInAuth, CURRENT),
                NVL (vsIdTerminal, ''),
                NVL (vsTipoOperacion, ''),
                NVL (pnumempleado, '')
            );
         
	END IF;
		
		RETURN P_COD_RET, P_MENSAJE, id_proceso;
		
    END

END PROCEDURE;