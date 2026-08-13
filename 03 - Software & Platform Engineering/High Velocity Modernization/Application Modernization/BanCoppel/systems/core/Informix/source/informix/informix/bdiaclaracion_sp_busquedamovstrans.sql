CREATE PROCEDURE "informix".sp_busquedamovstrans(
						pOrigenEvento	INTEGER,
						pTipoEvento 	INTEGER,
						pFechaInicial	DATE,
						pFechaFinal		DATE,
						pNumeroCliente	CHAR(9),
						pNumeroCuenta	CHAR(30),
						pNumeroTarjeta	CHAR(16),
                        p_skip INTEGER,
                        p_recuperacion INTEGER)

	RETURNING
	CHAR(3) 						AS cCodRet,
	DATE 							AS fechaMovimiento,
	DATETIME HOUR to FRACTION(3) 	AS horaMovimiento ,
	money(16,2) 					AS monto,
	CHAR(30) 						AS folioSuc,
	CHAR(4) 						AS sucursal,
	CHAR(30) 						AS nombre,
	CHAR(5) 						AS claveTipo,
	CHAR(40) 						AS tipo,
   	CHAR(30) 					    AS referencia23,
	CHAR(1) 						AS reversado,
	CHAR(40) 						AS refComercio,
	DATE 							AS fechaConsumo,
	DATETIME HOUR to FRACTION(3)  	AS horaConsumo,
	CHAR(1) 						AS tipomovimiento,
	CHAR(2) 						AS modoentrada;

	--Variables--
		DEFINE sql_err 						INTEGER;
		DEFINE v_cod_ret 					CHAR(4);

		DEFINE tipo_producto 				INTEGER;

		--Variables SP
		DEFINE s_fechamovimiento			DATE;
		DEFINE s_horamovimiento				DATETIME HOUR to FRACTION(3);
		DEFINE s_monto 						money(16,2);
		DEFINE s_foliosuc					CHAR(30);
		DEFINE s_sucursal					CHAR(4);
		DEFINE s_nombre						CHAR(30);
		DEFINE s_clavetipo 					CHAR(5);
		DEFINE s_tipo 						CHAR(40);
        DEFINE s_referencia23 				CHAR(30);
		DEFINE s_reversado 					CHAR(1);
		DEFINE s_refcomercio 				CHAR(40);
		DEFINE s_fechaconsumo 				DATE;
		DEFINE s_horaconsumo 				DATETIME HOUR to FRACTION(3);
		DEFINE s_tipomovimiento				CHAR(1);
		DEFINE s_modoentrada 				VARCHAR(2);
	    DEFINE tmp_str, ret_val             CHAR(255);
        DEFINE ret_str                      LVARCHAR;
        DEFINE s_telefono					CHAR(13);

        DEFINE s_nombreOrigenEvento			VARCHAR(15);
        DEFINE s_fechaString				CHAR(20);
        --CHAR(40) AS refComercio, DATE AS fechaConsumo, DATETIME HOUR to FRACTION(3) AS horaConsumo;

        --Variables dummy
        DEFINE dummy_horamovimiento				DATETIME HOUR to FRACTION(3);
		DEFINE dummy_monto 						money(16,2);
		DEFINE dummy_foliosuc					CHAR(30);
		DEFINE dummy_sucursal					CHAR(4);
		DEFINE dummy_nombre						CHAR(30);
		DEFINE dummy_clavetipo 					CHAR(5);
		DEFINE dummy_tipo 						CHAR(40);
        DEFINE dummy_referencia23 				CHAR(30);
		DEFINE dummy_reversado 					CHAR(1);
		DEFINE dummy_refcomercio 				CHAR(40);
		DEFINE dummy_fechaconsumo 				DATE;
		DEFINE dummy_horaconsumo 				DATETIME HOUR to FRACTION(3);
		DEFINE dummy_tipomovimiento				CHAR(1);
		DEFINE dummy_modoentrada 				VARCHAR(2);
        --Variables SKIP
        DEFINE iRecuperacion INTEGER;


        LET v_cod_ret 					= "000";
		LET tipo_producto 				=0;
		LET s_telefono					="";
		--Variable SP
        LET s_referencia23              ="";
		LET s_fechamovimiento			="";
		LET s_horamovimiento			="";
		LET s_monto 					="";
		LET s_foliosuc					="";
		LET s_sucursal					="";
		LET s_nombre					="";
		LET s_clavetipo 				="";
		LET s_tipo 						="";
		LET s_reversado 				="";
		LET s_refcomercio 				="";
		LET s_fechaconsumo 				="";
		LET s_horaconsumo 				="";
		LET s_tipomovimiento			="";
		LET s_modoentrada 				="";
		LET ret_str = "";
        LET ret_val = "";
        LET tmp_str = "";

        LET s_nombreOrigenEvento		="";
        LET s_fechaString = "";

        --
        LET dummy_horamovimiento = "";
		LET dummy_monto          = "";
		LET dummy_foliosuc       = "";
		LET dummy_sucursal		= "";
		LET dummy_nombre		= "";
		LET dummy_clavetipo 	= "";
		LET dummy_tipo 			= "";
        LET dummy_referencia23 	= "";
		LET dummy_reversado 	= "";
		LET dummy_refcomercio 	= "";
		LET dummy_fechaconsumo 	= "";
		LET dummy_horaconsumo 	= "";
		LET dummy_tipomovimiento = "";
		LET dummy_modoentrada 	= "";
        --Variables SKIP
        LET iRecuperacion = 0;
        
		--SET DEBUG FILE TO "/informix/traces/sp_aplica_movtran.out";
		--TRACE ON;


		BEGIN
		  ON EXCEPTION SET sql_err
		     IF sql_err <> 0 THEN
		   	     LET v_cod_ret = sql_err;
			     RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada;
		     END IF;
		   END EXCEPTION;

           -- VALIDACION DE LA PAGINACION
            IF p_skip < 0 OR p_recuperacion < 0 THEN
                LET v_cod_ret = '098'; --PAGINACION INVALIDA
                RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
            END IF;

		   SET ISOLATION TO DIRTY READ;
           SET LOCK MODE TO WAIT 3;
------Se agrega numero del clientes a la consulta
		   select first 1 (tprod.tipo_producto)
		   		into tipo_producto
		   		from acl_producto prod
				inner join acl_tipo_producto tprod on prod.fky_tipo_producto=tprod.pky_tipo_producto
			WHERE prod.numero_cuenta = pNumeroCuenta and prod.num_cliente = pNumeroCliente;

		/*31-05-2024 - Se cambia la obtención del dato para atender el incidente con el cliente 024715557 y similares*/
		--Obtiene el numero transfer
           SELECT first 1  telefono
                INTO s_telefono
                FROM bditransfer:tf_maecte
                WHERE empresa = '001'
                AND numcte = pNumeroCliente;
		/*31-05-2024 - FIN Se cambia la obtención del dato para atender el incidente con el cliente 024715557 similares*/
			--Obtener Array de transacciones en base al pky del evento
           FOREACH  select DISTINCT (transaccion)  into  ret_val from acl_tipo_movimiento where
                fky_origen_evento = (select fky_origen_evento from acl_tipo_evento where  pky_tipo_evento = pTipoEvento)
                and  fky_tipo_transaccion = (select fky_tipo_transaccion from acl_tipo_evento where  pky_tipo_evento = pTipoEvento)
                and activo = 1
                LET tmp_str = ret_str;
                LET ret_str = TRIM(tmp_str) ||"," || TRIM(ret_val);
           END FOREACH
           LET ret_str = SUBSTR (ret_str, 2);

			-- credito
			IF (tipo_producto = 1) THEN
                FOREACH
                    SELECT SKIP p_skip FIRST p_recuperacion fechaMovimiento, horaMovimiento, monto, folioSuc,  sucursal,  nombre,  claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo
                    INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc,  s_sucursal, s_nombre, s_clavetipo, s_tipo,  s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE(FUNCTION bdinteg:sp_buscar_movimientos_credito_dia3(pNumeroCuenta, pFechaInicial,  pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001') )
                                AS a(fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo)
                    union all
                    SELECT  fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo
                    --INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo,  s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE( FUNCTION bdinteg:sp_buscar_movimientos_credito_his3(pNumeroCuenta, pFechaInicial, pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001') )
                                AS a(fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo)
                    union all
                    SELECT  fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo
                    --INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo,  s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE( FUNCTION bdinteg:sp_buscar_movimientos_creditocrd_his(pNumeroCuenta, pFechaInicial, pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001'))
                            AS a(fechaMovimiento, horaMovimiento, monto, folioSuc, sucursal, nombre, claveTipo, tipo, referencia23, reversado, refComercio, fechacConsumo, horaConsumo)

                    CALL sp_consulta_tipo_movimiento(substr(s_foliosuc,2,length(s_foliosuc)),pNumeroTarjeta,pOrigenEvento)
				    RETURNING s_tipomovimiento, s_modoentrada;

                    LET iRecuperacion = iRecuperacion + 1;
                    RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
                END FOREACH;

			-- debito
			ELIF(tipo_producto = 2) THEN
				FOREACH

					--sp_buscar_movimientos_cheques_dia3
					SELECT SKIP p_skip FIRST p_recuperacion fechamovimiento, horamovimiento, monto, foliosuc,  sucursal,  nombre,  clavetipo, tipo, reversado, refcomercio, fechaconsumo, horaconsumo
                    INTO s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc,  s_sucursal, s_nombre, s_clavetipo, s_tipo, s_reversado, s_refcomercio, s_fechaconsumo, s_horaconsumo
                    FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_cheques_dia3(pNumeroCuenta, pFechaInicial,  pFechaFinal, null, 0, pNumeroTarjeta, TRIM (ret_str), '001') )
                    			AS a(fechamovimiento, horamovimiento, monto, foliosuc,  sucursal,  nombre,  clavetipo, tipo, reversado, refcomercio, fechaconsumo, horaconsumo)

                    union all
                    SELECT  a.fechamovimiento, a.horamovimiento, a.monto, a.foliosuc, a.sucursal, a.nombre, a.clavetipo, a.tipo, a.reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_inversion_dia2(pNumeroCuenta, pFechaInicial, pFechaFinal , null , 0, TRIM (ret_str) , '001') )
                    			AS a (fechamovimiento, horamovimiento, monto, foliosuc, sucursal, nombre, clavetipo, tipo, reversado )

                    --union all
                    --sp_buscar_movimientos_inversion_his2
                    --dummy_horamovimiento as horamovimiento, dummy_monto  as monto, dummy_foliosuc as foliosuc, dummy_sucursal as sucursal,
                    --dummy_nombre as nombre, dummy_clavetipo as clavetipo, dummy_tipo as tipo, dummy_reversado as reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    --SELECT  fechamovimiento, dummy_horamovimiento as horamovimiento, dummy_monto  as monto, dummy_foliosuc as foliosuc, dummy_sucursal as sucursal, dummy_nombre as nombre, dummy_clavetipo as clavetipo, dummy_tipo as tipo, dummy_reversado as reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    --FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_inversion_his2(pNumeroCuenta, pFechaInicial , pFechaFinal , null , 0 , TRIM (ret_str) , '001') )
                    --			AS a(fechamovimiento)
                    union all
                    --sp_buscar_movimientos_transfer
                    SELECT  fechamovimiento, horamovimiento, monto, foliosuc, sucursal, dummy_nombre as nombre, clavetipo, tipo, dummy_reversado as reversado, dummy_refcomercio as refcomercio, dummy_fechaconsumo as fechaconsumo, dummy_horaconsumo as horaconsumo
                    FROM TABLE (FUNCTION bdinteg:sp_buscar_movimientos_transfer(pNumeroCuenta, s_telefono, pFechaInicial, pFechaFinal, null , 0 , pNumeroTarjeta , TRIM (ret_str) ,  '001' ) )
                    			AS a(fechamovimiento, horamovimiento, monto, foliosuc, sucursal,  clavetipo, tipo)
                   	CALL sp_consulta_tipo_movimiento(substr(s_foliosuc,2,length(s_foliosuc)),pNumeroTarjeta,pOrigenEvento)
				    RETURNING s_tipomovimiento, s_modoentrada;

				    LET s_tipomovimiento = s_tipomovimiento;
				    LET s_modoentrada = s_modoentrada;

				    SELECT nombre
				    into s_nombreOrigenEvento
				    FROM acl_origen_evento WHERE pky_origen_evento = pOrigenEvento;

				    IF ( TRIM(s_nombreOrigenEvento) == 'POS' ) THEN
				    	LET s_fechaString = '';
                        LET s_fechaString = year (s_fechamovimiento) || '-' || month (s_fechamovimiento) || '-' || day (s_fechamovimiento); 
				    	SELECT limit 1 TO_CHAR(TO_DATE(s_fechaString,'%Y-%m-%d'), '%d%m%Y')
				    		into s_fechaString
				    	FROM systables;
						------Se agregar la obtención de las referencia 23 con las adecaucione solicitadas
						CALL bdinteg:sp_obten_referencia23_cheques(s_foliosuc, 'VID1'||s_fechaString,'VND1'||s_fechaString,'001')
						RETURNING s_referencia23;
						LET s_referencia23 = s_referencia23;
				    END IF;

                    LET iRecuperacion = iRecuperacion + 1;
					RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;

				END FOREACH;
			END IF;
           --PAGINACION
           IF iRecuperacion = 0 AND p_skip = 0 THEN
			LET v_cod_ret = '017'; --NO SE ENCONTRARON REGISTROS Y NO SE ESPECIFICÓ LA PAGINACIÓN
			RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
           ELIF iRecuperacion = 0 AND p_skip > 0 THEN
			LET v_cod_ret = '101';			RETURN v_cod_ret, s_fechamovimiento, s_horamovimiento, s_monto, s_foliosuc, s_sucursal, s_nombre, s_clavetipo, s_tipo, s_referencia23, s_reversado, s_refcomercio, s_fechaconsumo,s_horaconsumo, s_tipomovimiento, s_modoentrada WITH RESUME;
           END IF;	
		END;
END PROCEDURE
DOCUMENT
'Sp sp_busquedamovstrans',
'Sistema: Aclaraciones',
'AUTOR : Root',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 05/Junio/2018',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion';

CREATE PROCEDURE "informix".sp_consulta_tipo_movimiento(p_FolioSuc CHAR(20),p_NumTarjeta CHAR(20),p_OrigenEvento INTEGER)

    RETURNING CHAR(1) AS resultado_origen,VARCHAR(2) AS modo_entrada;
    DEFINE resultado_origen 	CHAR(1);
    DEFINE iSqlErr      		INTEGER;
	DEFINE nombre_origen 		CHAR(50);
    DEFINE imodo_entrada        VARCHAR(2);
	
    LET resultado_origen 		= '';
	LET nombre_origen 			= '';
   	LET imodo_entrada           = '';
	SET ISOLATION TO DIRTY READ;
			
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
				LET resultado_origen = '';
				RETURN  iSqlErr,'Er'; --RETURNING
			END IF;
        END EXCEPTION;

     -- SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_tipomovimiento"||"_"||""||TRIM(p_FolioSuc)||""||"_36.out"; --> TRACE DESDE APP
     -- TRACE ON;

     -- SET DEBUG FILE TO "/RESPALDOSNEW/sp_tipomovimiento"||"_"||""||TRIM(p_FolioSuc)||""||"_36.out"; --> TRACE DESDE APP
     -- TRACE ON;
 	SELECT nombre 
        INTO nombre_origen 
		FROM "informix".acl_origen_evento 
        WHERE pky_origen_evento = p_OrigenEvento;
	
    IF nombre_origen = 'POS' or nombre_origen = 'ATMS' Then
            
            SELECT intercard:movimiento.esnacional, intercard:movimiento.metodocaptura
            INTO resultado_origen, imodo_entrada
            FROM intercard:movimiento
            WHERE intercard:movimiento.secuenciaextendida=p_FolioSuc
            AND intercard:movimiento.numtarjeta=p_NumTarjeta;
             
                IF ( resultado_origen IS NULL OR resultado_origen='') THEN
                    SELECT intercard:movimientohistorico.esnacional, intercard:movimientohistorico.metodocaptura
                    INTO resultado_origen, imodo_entrada
                    FROM intercard:movimientohistorico
                    WHERE intercard:movimientohistorico.secuenciaextendida=p_FolioSuc
                    AND intercard:movimientohistorico.numtarjeta=p_NumTarjeta;
                ELSE
                    RETURN resultado_origen,imodo_entrada; -- RETURNING
                END IF; 


             --RETURN resultado_origen,imodo_entrada; -- RETURNING


                 IF ( resultado_origen IS NULL OR resultado_origen='') THEN
                    LET resultado_origen = 'N';
                 END IF;

                 IF ( imodo_entrada IS NULL OR imodo_entrada='') THEN
                    LET imodo_entrada = 'NN';
                 END IF;
	ELSE
		LET resultado_origen = 'V';
        LET imodo_entrada= 'NN';
	END IF;
    
    RETURN resultado_origen,imodo_entrada;

    END
END PROCEDURE;