CREATE PROCEDURE "informix".sp_cons_tarjeta_upgrade(pEmpresa CHAR(3),pNumerotarjeta CHAR(20))
RETURNING CHAR(6)         AS codigo_retorno,
		  CHAR(20)		  AS NumCreditoOro,
		  CHAR(4)         AS num_producto,
		  CHAR(1) 		  AS cbanderatarjpersonal;


DEFINE nrows         INTEGER;
DEFINE iSqlErr       INTEGER;
DEFINE iIsamErr      INTEGER;
DEFINE cErrorInfo    CHAR(80);
DEFINE cCodRet       CHAR(6);
DEFINE cMensajeRet   VARCHAR(100,1);
DEFINE cEmpresa      CHAR(3);
DEFINE cNumcreditooro CHAR(20);
DEFINE cbanderatarjpersonal CHAR(1);
DEFINE cnumproducto  CHAR(4);
--AAME 26022018 Se modifica para obtener el número de crédito de la tarjeta deslizada
DEFINE cNumCredito   CHAR(20);
DEFINE cNumtarjetamarca CHAR(20);
DEFINE cResultado CHAR(1);
DEFINE ctipotar CHAR(3);


LET nrows         = 0;
LET iSqlErr       = 0;
LET iIsamErr      = 0;
LET cErrorInfo    = '';
LET cCodRet       = '000000';
LET cMensajeRet   = 'Se realizó la consulta correctamente.';

LET cEmpresa      = pEmpresa;
LET cNumcreditooro = '';
LET cbanderatarjpersonal = '0';
LET cnumproducto  = '';
--AAME 26022018
LET cNumCredito= '';
LET cNumtarjetamarca = '';
LET cResultado = '0';
LET ctipotar = '';

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
      LET cCodRet     = iSqlErr;
      LET cMensajeRet = cErrorInfo;
      RETURN cCodRet, NVL(cNumcreditooro,''),NVL(cnumproducto,''), NVL(cbanderatarjpersonal,'0');
    END IF;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_cons_tarjeta_upgrade';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

IF NVL(pNumerotarjeta,'') = '' THEN
    --AAME 26022018 No se proporciono parametro de entrada correcto
    LET cCodRet='00001';
    RETURN cCodRet, NVL(cNumcreditooro,''),NVL(cnumproducto,''), NVL(cbanderatarjpersonal,'0');
END IF;

    --AAME 26022018 Se obtiene el numero de crédito de la tarjeta deslizada
    SELECT num_credito INTO cNumCredito
    FROM bdicred:"informix".sd_tarjeta a
    WHERE a.num_tarjeta = pNumerotarjeta
    AND a.tipo_tarjeta ='T'
    AND a.secuencia IN (select MAX(secuencia) FROM bdicred:"informix".sd_tarjeta 
                       WHERE num_credito = a.num_credito AND tipo_tarjeta ='T');

    IF NVL(cNumCredito,'') = '' THEN
        --AAME 26022018 Se retorna 0 si la tarjeta deslizada no es la última del cliente
        RETURN cCodRet, NVL(cNumcreditooro,''),NVL(cnumproducto,''), NVL(cbanderatarjpersonal,'0');
    ELSE 
        --AAME 26022018 Si no existe marcada la tarjeta deslizada se actualiza la marca por la nueva tarjeta del cliente 
        SELECT numerotarjeta INTO cNumtarjetamarca 
        FROM bdicred:"informix".sd_credito_upgrade where num_credito=cNumCredito AND tipotar='TIT';

        IF  NVL(cNumtarjetamarca,'') <> '' THEN  
			--AAME 19022020 Solo cambiara el plástico si la tarjeta deslizada es visa
            IF NVL(pNumerotarjeta,'') <> NVL(cNumtarjetamarca,'') AND substr(pNumerotarjeta,1,6)='426807' THEN          
                UPDATE bdicred:"informix".sd_credito_upgrade SET numerotarjeta= pNumerotarjeta 
                WHERE num_credito=cNumCredito AND tipotar='TIT';
            END IF;
        END IF;
    END IF;
	--AAME 19022020 Se obtiene el valor de Resultado para validar si no esta cancelada
	SELECT numero_credito_upgrade, tipotar, bandtarjpersonal, num_producto_upgrade, resultado
	INTO cNumcreditooro, ctipotar, cbanderatarjpersonal, cnumproducto, cResultado
	FROM bdicred:"informix".sd_credito_upgrade
	WHERE empresa = cEmpresa
    AND numerotarjeta = pNumerotarjeta;
	-- INC 56 411 se quita el case del select por observacion de BD
	IF ctipotar <> 'TIT' THEN
		LET cbanderatarjpersonal = '0';
	END IF;
	--AAME 19022020
	IF cResultado = '3' THEN
		--LET cbanderatarjpersonal = '0';
		-- AAME 07042020 RQI 27 221 Se contempla el estado de marca cancelado para mostrar msj en apertp
        LET cbanderatarjpersonal = '3';
		--INC 56 411 para que tome el numero de producto correcto cuando la marca esta cancelada
		LET cnumproducto = '';
	END IF;

	RETURN cCodRet, NVL(cNumcreditooro,''),NVL(cnumproducto,''), NVL(cbanderatarjpersonal,'0');

END
END PROCEDURE
DOCUMENT
'Se crea nuevo procedimiento para consultar si la tarjeta a reponer pertenece a una solicitud de UPGRADE',
'AUTOR : Maria Elena Angulo Aispuro',
'FECHA : 14/04/2016',
'BD    : BDICRED';

create procedure "informix".sp_can_programa_masivo()
       returning char(5),char(100);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

	DEFINE sqlerr           INTEGER; 
   
	DEFINE vcodret     		CHAR(5);
	DEFINE vMensaje     	CHAR(100);
	
	DEFINE cSql     		CHAR(150);
	DEFINE v_ruta        	CHAR(50);
	DEFINE v_numcte			CHAR(20);
	DEFINE cCodRetSp		CHAR(5);
	DEFINE i				INTEGER;
	DEFINE dFechaHoy		DATE;
	
   
   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************   
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret,vMensaje;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	  SET ISOLATION TO DIRTY READ;
	  SET LOCK MODE TO WAIT 3;

--	 SET DEBUG FILE TO "/ifxsif01/Israel/sp_can_programa_masivo.out";
--	 TRACE ON;

	   LET vcodret 			= '00000';
	   LET vMensaje 		= '';
	   LET cSql 			= '';
	   LET v_ruta			= '';
	   LET v_numcte			= '';
	   LET cCodRetSp		= '';
	   LET i				= 0;
	   LET dFechaHoy		= DATE(0);
	   
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************		   
		
		SELECT fecha_hoy INTO dFechaHoy FROM bdicred:sd_fechas WHERE empresa = '001';
		SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE cod_param = '033';
		
		system ' echo "cat ' ||TRIM(v_ruta) || 'Clientes_Baja_Apoyo.txt' || ' | sed ' || "'" ||'s/ //g'|| "'" ||'| awk -F \"|\" '|| "'" ||'{if(NF>0) print \$1'|| '\"|\"' ||'\$2\"'||'A|||\"}'|| "'" ||' > '|| TRIM(v_ruta) || 'Clientes_Baja_Apoyo_aux.txt;' ||'">' || TRIM(v_ruta) || 'baja_apoyo.sh';	
		system 'chmod 777 ' || TRIM(v_ruta)|| 'baja_apoyo.sh';
		system TRIM(v_ruta)|| 'baja_apoyo.sh';

			let cSql = 'echo "load from '||TRIM(v_ruta)||'Clientes_Baja_Apoyo_aux.txt' ||
					   ' insert into bdicred:sd_cancela_masivo;' ||
					   ' " > cancela_masivo.sql';
			SYSTEM cSql;

			  LET cSql = '';
			  LET cSql = 'dbaccess bdicred cancela_masivo.sql';
			  SYSTEM cSql;  
			  
		FOREACH WITH HOLD

			SELECT numcte
			INTO v_numcte
			FROM sd_cancela_masivo

			EXECUTE PROCEDURE bdicred:sp_diferir_cancela(v_numcte,'','',19) 
				INTO cCodRetSp,vMensaje;

			IF cCodRetSp::INTEGER = 0 OR cCodRetSp  in ('00010','00011') THEN
				LET i=i+1;
			END IF; 
			
			UPDATE bdicred:sd_cancela_masivo 
				SET  estatus = 'B',
				fecha_insert = dFechaHoy,
				descripcion = vMensaje
			WHERE numcte = v_numcte AND estatus = 'A';
		END FOREACH;
		
			LET cSql = '';
			LET cSql = "rm cancela_masivo.sql";
			SYSTEM cSql;
			
			LET cSql = '';
			LET cSql = "rm baja_apoyo.sh";
			SYSTEM cSql;
			
		IF i > 1 THEN
			LET vMensaje = 'PROCESO DE CANCELACION SE REALIZO DE FORMA EXITOSA A '||i||' CREDITOS';
		ELIF i = 0 THEN
			LET vMensaje = 'NO SE PROCESO CANCELACION DE NINGUN CLIENTE';
		END IF;
			
		RETURN vcodret, vMensaje;
	END;
END PROCEDURE
DOCUMENT
'PROCESO PARA CARGAR CANCELACION DE PROGRAMA DE APOYO MASIVO',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : JUN/2020',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_concurso()
    RETURNING CHAR(6);



   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

	DEFINE vcodret          	CHAR(6);
	DEFINE sqlerr           	INTEGER;

	DEFINE v_producto 			CHAR (4);
	DEFINE v_nombre_prod		CHAR (50); 
	DEFINE v_num_credito		CHAR (20); 
	DEFINE v_numcte				CHAR (20); 
	DEFINE v_monto_financiado	MONEY(14,2);
	DEFINE v_monto				MONEY(14,2);
	DEFINE v_fecha_mov			DATE; 
	DEFINE v_hora_mov			CHAR (20); 
	DEFINE v_folio_suc			CHAR (20); 
	DEFINE vCiudad				CHAR (25); 
	DEFINE vNombre				CHAR (20); 
	DEFINE vNombre2				CHAR (20); 
	DEFINE vApellido			CHAR (20); 
	DEFINE vNombreCompleto		CHAR (80); 
	DEFINE v_telefono			CHAR (10);
	DEFINE v_correo				CHAR (40);
	DEFINE v_credito_mas		CHAR (20);
	DEFINE monto_suma			MONEY(14,2);
	
	DEFINE FechaHoy				DATE;
	DEFINE vFechahist 			DATE;
	DEFINE vFechahistini		DATE;
	DEFINE vFechahistfin		DATE;
	
	DEFINE v_pri_dia_mes 		DATE;
	DEFINE v_ult_dia_mes		DATE;
	DEFINE dia_recorre			DATE;
	DEFINE v_fecha_pago			DATE;
	
	DEFINE r_fecha_folio		CHAR (30);
	DEFINE max_folio			INTEGER;
	DEFINE max_folio2			INTEGER;
	DEFINE v_sql				CHAR(50);
	DEFINE v_sql1				CHAR(300);
	DEFINE v_sql2				CHAR(220);
	
	DEFINE ruta					CHAR(50);
	DEFINE r_mes				INT;
	DEFINE r_ano				INT;

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
--	  SET DEBUG FILE TO "/ifxsif01/sp_reporte_concurso.out";
--	  TRACE ON;
	   
	LET vcodret    =  "000000";
	LET v_producto = '';
	LET v_nombre_prod = '';
	
	LET v_producto 			= '';
	LET v_nombre_prod		= '';
	LET v_num_credito		= '';
	LET v_numcte			= '';
	LET v_monto_financiado	= 0;
	LET v_monto				= 0;
	LET v_fecha_mov			= '';
	LET v_hora_mov			= '';
	LET v_folio_suc			= '';
	LET vCiudad				= '';
	LET vNombre				= '';
	LET vNombre2			= ''; 
	LET vApellido			= '';
	LET vNombreCompleto		= '';
	LET v_telefono			= '';
	LET v_correo			= '';
	LET v_credito_mas		= '';
	LET monto_suma 			= 0; 
	
	LET FechaHoy			= DATE (1);
	LET vFechahist 			= DATE (1);
	LET vFechahistini		= DATE (1);
	LET vFechahistfin		= DATE (1);
	
	LET v_pri_dia_mes 		= DATE (1);
	LET v_ult_dia_mes		= DATE (1);
	LET dia_recorre			= DATE (1);
	LET v_fecha_pago		= DATE (1);
	
	LET r_fecha_folio		= '';
	LET max_folio			= 0;
	LET max_folio2			= 0;
	LET v_sql				= '';
	LET v_sql1				= '';
	LET v_sql2				= '';
	LET ruta 				= '/RESPALDOSNEW/';
	LET r_mes				= 0;
	LET r_ano				= 0;
	
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	

	SELECT fecha_hoy,pri_dia_mes,ult_dia_mes 
	INTO FechaHoy,v_pri_dia_mes,v_ult_dia_mes
	FROM bdicred:sd_fechas;
	
		FOREACH WITH HOLD
		
			SELECT num_producto,nombre_prod 
				INTO v_producto,v_nombre_prod
			FROM bdicred:sd_definicion 
			WHERE  num_producto in 	('8100','6001')
			
			IF v_producto = '8100' THEN
			
				LET vFechahist = mdy(month(FechaHoy)-2,18,year(FechaHoy));
				LET vFechahistini = mdy(month(FechaHoy)-2,19,year(FechaHoy));
				LET vFechahistfin = mdy(month(FechaHoy)-1,18,year(FechaHoy));
			
			ELIF  v_producto = '6001' THEN

				LET vFechahist = mdy(month(FechaHoy)-2,20,year(FechaHoy));
				LET vFechahistini = mdy(month(FechaHoy)-2,21,year(FechaHoy));
				LET vFechahistfin = mdy(month(FechaHoy)-1,20,year(FechaHoy));	
			
			END IF;
			
			
			IF v_producto in ('8100','6001') THEN
			
				CREATE TABLE  maesdoshist1 (num_credito char (20),monto_financiado DECIMAL(18,2))
				 fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
                 extent size 1024000 next size 512000 lock mode row;
                 
					CREATE UNIQUE INDEX maesdoshist1_idx
					ON maesdoshist1(num_credito) IN dbs_movhis_idx6;
					
					UPDATE STATISTICS MEDIUM FOR TABLE maesdoshist1;
			
					---- obtengo el monto financiado al inicio y valido capital_insoluto al inicio del periodo
				INSERT INTO maesdoshist1 
				SELECT a.num_credito ,a.monto_financiado
				FROM bdicred:sd_maesdoshist a
					JOIN bdicred:sd_maecred b on (a.num_credito = b.num_credito)
				WHERE a.fecha = vFechahist
					AND a.sdo_capital = a.sdo_cap_insoluto
					AND a.sdo_cap_insoluto > 0
					AND b.num_producto = v_producto;
					
					
				CREATE TABLE  maesdoshist2 (num_credito char (20),monto_financiado DECIMAL(18,2))
				 fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
                 extent size 1024000 next size 512000 lock mode row;
                 
				CREATE UNIQUE INDEX maesdoshist2_idx
					ON maesdoshist2(num_credito) IN dbs_movhis_idx6;
					
				UPDATE STATISTICS MEDIUM FOR TABLE maesdoshist2;
				
				---  arrastro el monto financiado al inicio y valido capital_insoluto del final del periodo
				INSERT INTO maesdoshist2 
				SELECT a.num_credito, b.monto_financiado
				FROM bdicred:sd_maesdoshist a
					JOIN maesdoshist1 b on (a.num_credito = b.num_credito)
				WHERE a.fecha = vFechahistfin
					AND a.sdo_capital = a.sdo_cap_insoluto
					AND a.sdo_cap_insoluto > 0; 
					

				CREATE TABLE  movimientos (num_credito char (20),folio_suc char(16),monto DECIMAL(18,2),
												fecha_mov date,hora_mov DATETIME HOUR to FRACTION(3),monto_financiado DECIMAL(18,2))
				 fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
                 extent size 1024000 next size 512000 lock mode row;	

				CREATE INDEX movimientos_idx
					ON movimientos(num_credito) IN dbs_movhis_idx6;
					
				UPDATE STATISTICS MEDIUM FOR TABLE movimientos;				 

				--- obtengo todos los movimintos de pago de los creditos vigentes con saldo
				INSERT INTO movimientos 
				SELECT a.num_credito,b.folio_suc,monto,fecha_mov,hora_mov,a.monto_financiado
				FROM maesdoshist2 a
					join bdicred:sd_movhis b on (a.num_credito = b.num_credito)
					join bdicred:sd_conceptospagomanual c on (b.codigo_fun = c.cod_fun AND b.codigo_ref = 1)
				WHERE  b.fecha_mov between vFechahistini and vFechahistfin
					AND b.reversado= 'N';
				

				--- obtengo los que realizaron solo un pago
				SELECT num_credito
				FROM movimientos 
					group by 1
					having count (*) = 1
				INTO temp un_movimiento with no log;
			
				--- aplica solo para un pago
				FOREACH WITH HOLD
					--- se trae datos de los que solo tienen un pago 
					SELECT a.num_credito,c.numcte,b.monto_financiado,b.monto,b.fecha_mov,b.hora_mov,b.folio_suc
						INTO v_num_credito,v_numcte,v_monto_financiado,v_monto,v_fecha_mov,v_hora_mov,v_folio_suc
					FROM un_movimiento a
						JOIN movimientos b on (a.num_credito = b.num_credito)
						JOIN bdicred:sd_maecred c on (b.num_credito = c.num_credito)
						
						SELECT  ciu.nombre
							INTO vCiudad
						FROM bdinteg:si_direcciones_actual dir
							LEFT OUTER JOIN bdinteg:si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
							LEFT OUTER JOIN bdinteg:si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
						WHERE dir.numcte = v_numcte AND dir.tipo_dir='1';	
						
						IF 	vCiudad IS NULL THEn
							LET vCiudad = 'SIN CIUDAD';
						END IF;
						
						LET vCiudad =TRIM (vCiudad);
						
						SELECT nombre1, nombre2,apell_paterno  
							INTO  vNombre,vNombre2, vApellido
						FROM bdinteg:si_cliente 
							WHERE numcte = v_numcte;
							
							IF LENGTH(vNombre) < 4 AND LENGTH(vNombre2) > 0 THEN
								LET vNombre =  vNombre2;
								LET vNombreCompleto = TRIM(vNombre)||' '||TRIM(vApellido);
							ELSE
								LET vNombreCompleto = TRIM(vNombre)||' '||TRIM(vApellido);
							END IF;
						
						SELECT telefono
							INTO v_telefono
						FROM bdinteg:"informix".si_telefonos_actual 
						WHERE numcte = v_numcte 
							AND tipo_tel = 2
							AND status_tel = 'A';
							
						IF 	v_telefono IS NULL THEN
							LET v_telefono = '';
						END IF;
							
						SELECT correo_elec
							INTO v_correo
						FROM bdinteg:si_correos 
						WHERE numcte = v_numcte
							AND status_correo = 'A'
							AND valido = 1
							AND secuencia in (SELECT MAX (secuencia) 
								FROM bdinteg:si_correos 
								WHERE numcte = v_numcte AND  status_correo = 'A'
								and valido = 1);
						
							IF v_correo IS NULL THEN
								LET v_correo = 'NO EXISTE';
							END IF;
							
							LET v_correo = TRIM (v_correo);
						
						--- insert tabla reporte
						BEGIN;
						INSERT INTO bdicred:sd_reporte_concurso 
							VALUES(0,v_numcte,v_num_credito,vCiudad,v_nombre_prod,v_fecha_mov||' '|| v_hora_mov,vNombreCompleto,v_telefono,v_correo,v_monto_financiado,v_monto,v_fecha_mov,v_folio_suc,FechaHoy);
						COMMIT;
			
				END FOREACH
			
				--- aplica para mas pagos en el periodo
				FOREACH WITH HOLD
					
					--- se trae datos de los que realizaron mas de 1 pago			
					SELECT b.num_credito
						INTO v_credito_mas
					FROM  movimientos b 
						where b.num_credito not in (SELECT num_credito FROM un_movimiento )
						group by num_credito
				
					LET monto_suma = 0;
				
					FOREACH WITH HOLD
			
						SELECT b.num_credito,c.numcte,b.monto_financiado,b.monto,b.fecha_mov,b.hora_mov,b.folio_suc
							INTO v_num_credito,v_numcte,v_monto_financiado,v_monto,v_fecha_mov,v_hora_mov,v_folio_suc
						FROM  movimientos b 
							JOIN bdicred:sd_maecred c on (b.num_credito = c.num_credito)
						where b.num_credito = v_credito_mas
							order by fecha_mov,hora_mov
						
						LET monto_suma = v_monto + monto_suma;
						
						IF monto_suma >= v_monto_financiado THEN
							
							SELECT  ciu.nombre
								INTO vCiudad
							FROM bdinteg:si_direcciones_actual dir
								LEFT OUTER JOIN bdinteg:si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
								LEFT OUTER JOIN bdinteg:si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
							WHERE dir.numcte = v_numcte AND dir.tipo_dir='1';	
							
							IF 	vCiudad IS NULL THEn
								LET vCiudad = 'SIN CIUDAD';
							END IF;	
							
							LET vCiudad =TRIM (vCiudad);
							
							SELECT nombre1, nombre2,apell_paterno  
								INTO  vNombre,vNombre2, vApellido
							FROM bdinteg:si_cliente 
								WHERE numcte = v_numcte;
								
								IF LENGTH(vNombre) < 4 AND LENGTH(vNombre2) > 0 THEN
									LET vNombre =  vNombre2;
									LET vNombreCompleto = TRIM(vNombre)||' '||TRIM(vApellido);
								ELSE
									LET vNombreCompleto = TRIM(vNombre)||' '||TRIM(vApellido);
								END IF;
							
							SELECT telefono
								INTO v_telefono
							FROM bdinteg:"informix".si_telefonos_actual 
							WHERE numcte = v_numcte 
								AND tipo_tel = 2
								AND status_tel = 'A';
								
								IF 	v_telefono IS NULL THEn
									LET v_telefono = '';
								END IF;
								
							SELECT correo_elec
								INTO v_correo
							FROM bdinteg:si_correos 
							WHERE numcte = v_numcte
								AND status_correo = 'A'
								AND valido = 1
								AND secuencia in (SELECT MAX (secuencia) 
									FROM bdinteg:si_correos 
									WHERE numcte = v_numcte AND  status_correo = 'A'
									and valido = 1);
							
								IF v_correo IS NULL THEN
									LET v_correo = 'NO EXISTE';
								END IF;
							
							--- insert tabla reporte
							BEGIN;
							INSERT INTO bdicred:sd_reporte_concurso 
								VALUES(0,v_numcte,v_num_credito,vCiudad,v_nombre_prod,v_fecha_mov||' '|| v_hora_mov,vNombreCompleto,v_telefono,v_correo,v_monto_financiado,monto_suma,v_fecha_mov,v_folio_suc,FechaHoy);
							COMMIT;
					
							EXIT FOREACH;
						ELSE 
							CONTINUE FOREACH;
							
						END IF;
						
					END FOREACH;

				END FOREACH;
				
				DROP TABLE maesdoshist1;
				DROP TABLE maesdoshist2;
				DROP TABLE movimientos;
				DROP TABLE un_movimiento;
				
			END IF;	
			
		END FOREACH;		
	END;
	
	----- REACOMODA LOS REGISTROS POR FECHA Y HORA PARA ASIGNAR FOLIO
	--- AL MOMENTO DE LLEGAR A ESTA PARTE EL PROCESO DE PP YA TERMINO SU EJECUCION
	FOREACH WITH HOLD
	
		SELECT numcte,num_credito,ciudad,nombre_producto,fecha_folio,nombre,num_celular,correo,fecha_mov,foliso_suc
			INTO v_numcte,v_num_credito,vCiudad,v_nombre_prod,r_fecha_folio,vNombreCompleto,v_telefono,v_correo,v_fecha_mov,v_folio_suc
		FROM bdicred:sd_reporte_concurso WHERE fecha_insert = FechaHoy
			ORDER BY fecha_folio
			--- EL CAMPO FOLIO ES SERIAL POR LO QUE AL INSERTAR SE GENERA EL CONSECUTIVO, INSERTA TODOS LOS PRODUCTOS TDC Y PP
			BEGIN;
			INSERT INTO bdicred:sd_reporte_concurso_folio 
				VALUES(0,v_numcte,v_num_credito,vCiudad,v_nombre_prod,r_fecha_folio,vNombreCompleto,v_telefono,v_correo,v_fecha_mov,v_folio_suc,FechaHoy);
			COMMIT;
			
	END FOREACH;
	
	LET r_mes = MONTH (FechaHoy) -1 ;
	LET r_ano = YEAR (FechaHoy);
	
			----- DESCARGA REPORTE 
		LET v_sql1 = ' echo "UNLOAD TO '||trim(ruta)||'reporte_premia_tu_esfuerzo_0'||r_mes||r_ano||'.unl ';
		LET v_sql2 = ' SELECT folio,ciudad,nombre_producto,fecha_folio,nombre,num_celular,correo FROM bdicred:sd_reporte_concurso_folio '||
					 ' where fecha_insert = mdy ('||month (FechaHoy)||','||day (FechaHoy)||','||year (FechaHoy)||'); " > '||trim(ruta)||'query.sql';
		
		LET v_sql1 = trim (v_sql1)||' '||trim(v_sql2);		
		system v_sql1;

		LET v_sql = "dbaccess bdicred "||trim(ruta)||"query.sql";
		system v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||trim(ruta)||"query.sql";
		SYSTEM v_sql;
		
				----- DESCARGA REPORTE 2 
			LET v_sql1 = ' echo "UNLOAD TO '||trim(ruta)||'reporte_premia_tu_esfuerzo_0'||r_mes||r_ano||'_interno.unl ';
			LET v_sql2 = ' SELECT numcte,num_credito,folio,ciudad,nombre_producto,fecha_folio,nombre,num_celular,correo FROM bdicred:sd_reporte_concurso_folio '||
						 ' where fecha_insert = mdy ('||month (FechaHoy)||','||day (FechaHoy)||','||year (FechaHoy)||'); " > '||trim(ruta)||'query.sql';
			
			LET v_sql1 = trim (v_sql1)||' '||trim(v_sql2);		
			system v_sql1;

			LET v_sql = "dbaccess bdicred "||trim(ruta)||"query.sql";
			system v_sql;
			
			LET v_sql = '';
			LET v_sql = "rm "||trim(ruta)||"query.sql";
			SYSTEM v_sql;
			

	RETURN vcodret;

END PROCEDURE
DOCUMENT
'GENERA REPORTE CONCURSO BANCOPPEL PARA PRODUCTOS DE CREDITO',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : MAY/2020',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_reporte_concurso_2()
    RETURNING CHAR(6);



   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************

	DEFINE vcodret          	CHAR(6);
	DEFINE sqlerr           	INTEGER;

	DEFINE v_producto 			CHAR (4);
	DEFINE v_nombre_prod		CHAR (50); 
	DEFINE v_num_credito		CHAR (20); 
	DEFINE v_numcte				CHAR (20); 
	DEFINE v_monto_financiado	MONEY(14,2);
	DEFINE v_monto				MONEY(14,2);
	DEFINE v_fecha_mov			DATE; 
	DEFINE v_hora_mov			CHAR (20); 
	DEFINE v_folio_suc			CHAR (20); 
	DEFINE vCiudad				CHAR (25); 
	DEFINE vNombre				CHAR (20); 
	DEFINE vNombre2				CHAR (20); 
	DEFINE vApellido			CHAR (20); 
	DEFINE vNombreCompleto		CHAR (80); 
	DEFINE v_telefono			CHAR (10);
	DEFINE v_correo				CHAR (40);
	DEFINE v_credito_mas		CHAR (20);
	DEFINE monto_suma			MONEY(14,2);
	
	DEFINE FechaHoy				DATE;
	DEFINE vFechahist 			DATE;
	DEFINE vFechahistini		DATE;
	DEFINE vFechahistfin		DATE;
	
	DEFINE v_pri_dia_mes 		DATE;
	DEFINE v_ult_dia_mes		DATE;
	DEFINE dia_recorre			DATE;
	DEFINE v_fecha_pago			DATE;
	DEFINE dia_finmes_cierre	INT;
	DEFINE dia_finmes_cierreAnt INT;
	
	DEFINE r_fecha_folio		CHAR (30);
	DEFINE max_folio			INTEGER;
	DEFINE max_folio2			INTEGER;
	DEFINE v_sql				CHAR(50);
	DEFINE v_sql1				CHAR(300);
	DEFINE v_sql2				CHAR(200);
	
	DEFINE ruta					CHAR(50);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************
   
	BEGIN
	   ON EXCEPTION
		  SET sqlerr
		  LET vcodret = sqlerr;
		  RETURN vcodret;
	   END EXCEPTION;

	-- **************************************************************************
	-- *                      ASIGNACION DE VARIABLES                           *
	-- **************************************************************************
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	  
--	  SET DEBUG FILE TO "/ifxsif01/Israel/sp_reporte_concurso.out";
--	  TRACE ON;
	   
	LET vcodret    =  "000000";
	LET v_producto = '';
	LET v_nombre_prod = '';
	
	LET v_producto 			= '';
	LET v_nombre_prod		= '';
	LET v_num_credito		= '';
	LET v_numcte			= '';
	LET v_monto_financiado	= 0;
	LET v_monto				= 0;
	LET v_fecha_mov			= '';
	LET v_hora_mov			= '';
	LET v_folio_suc			= '';
	LET vCiudad				= '';
	LET vNombre				= '';
	LET vNombre2			= ''; 
	LET vApellido			= '';
	LET vNombreCompleto		= '';
	LET v_telefono			= '';
	LET v_correo			= '';
	LET v_credito_mas		= '';
	LET monto_suma 			= 0; 
	
	LET FechaHoy			= DATE (1);
	LET vFechahist 			= DATE (1);
	LET vFechahistini		= DATE (1);
	LET vFechahistfin		= DATE (1);
	
	LET v_pri_dia_mes 		= DATE (1);
	LET v_ult_dia_mes		= DATE (1);
	LET dia_recorre			= DATE (1);
	LET v_fecha_pago		= DATE (1);
	LET dia_finmes_cierre	= 0;
	LET dia_finmes_cierreAnt	= 0;
	
	LET r_fecha_folio		= '';
	LET max_folio			= 0;
	LET max_folio2			= 0;
	LET v_sql				= '';
	LET v_sql1				= '';
	LET v_sql2				= '';
	LET ruta 				= '/RESPALDOSNEW/';
	
	-- ****************************************************************************
	-- *                        PROGRAMA PRINCIPAL                                *
	-- ****************************************************************************	

	SELECT fecha_hoy,pri_dia_mes,ult_dia_mes 
	INTO FechaHoy,v_pri_dia_mes,v_ult_dia_mes
	FROM bdicred:sd_fechas;
	
		FOREACH WITH HOLD
		
			SELECT num_producto,nombre_prod 
				INTO v_producto,v_nombre_prod
			FROM bdicred:sd_definicion 
			WHERE  num_producto in 	('6300','7600','7700','6800')

----- PROCESO PARA PP		
		
	
			CALL bdicred:"informix".monthadd(v_pri_dia_mes,-1) RETURNING vFechahistini;
			-- CALL bdicred:"informix".monthadd(v_ult_dia_mes,-1) RETURNING vFechahistfin;
			LET vFechahistfin = v_pri_dia_mes - 1 units day;
			
			-- LET dia_recorre = vFechahistini;
			LET dia_finmes_cierre = day (vFechahistfin);
			
			CREATE TABLE  maesdoshist1_crd (num_credito char (20),numcte char (20),fecha date)
			 fragment by round robin in dbs_movhis1, dbs_movhis2, dbs_movhis3
			 extent size 1024000 next size 512000 lock mode row;
			 
				CREATE UNIQUE INDEX maesdoshist1_crd_idx
				ON maesdoshist1_crd(num_credito) IN dbs_movhis_idx6;
				
				UPDATE STATISTICS MEDIUM FOR TABLE maesdoshist1_crd;
			
			INSERT INTO maesdoshist1_crd 
				select * from			
					(SELECT a.num_credito ,b.numcte,a.fecha
					FROM bdicred:sd_maesdoshistcrd a
						JOIN bdicred:sd_maecredcrd b on (a.num_credito = b.num_credito)
						JOIN bdicred:sd_maecredanexocrd c on (a.num_credito = c.num_credito)
					WHERE a.fecha BETWEEN vFechahistini AND vFechahistfin
						AND a.sdo_capital = a.sdo_cap_insoluto
						AND a.monto_financiado = 0
						AND a.fecha = MDY (MONTH (vFechahistini),day (c.dia_corte),year (vFechahistini))
						AND c.dia_corte <> 31
						AND b.num_producto = v_producto
					UNION ALL
					SELECT a.num_credito ,b.numcte,a.fecha
					FROM bdicred:sd_maesdoshistcrd a
						JOIN bdicred:sd_maecredcrd b on (a.num_credito = b.num_credito)
						JOIN bdicred:sd_maecredanexocrd c on (a.num_credito = c.num_credito)
					WHERE a.fecha BETWEEN vFechahistini AND vFechahistfin
						AND a.sdo_capital = a.sdo_cap_insoluto
						AND a.monto_financiado = 0
						AND a.fecha = MDY (MONTH (vFechahistini),dia_finmes_cierre,year (vFechahistini))
						AND c.dia_corte = 31
						AND b.num_producto = v_producto);

			FOREACH WITH HOLD
			
				SELECT *
				INTO v_num_credito,v_numcte,v_fecha_pago
				FROM maesdoshist1_crd
	
					SELECT b.folio_suc,fecha_mov,hora_mov
						INTO v_folio_suc,v_fecha_mov,v_hora_mov
					FROM bdicred:sd_movhiscrd b 
					WHERE b.num_credito = v_num_credito
						AND b.fecha_mov = v_fecha_pago
						AND b.codigo_fun in (select cod_fun from sd_conceptospagomanualcrd )
						AND b.codigo_ref = 1
						AND b.reversado= 'N'
						AND b.secuencia = (SELECT MAX (secuencia) FROM  bdicred:sd_movhiscrd 
											WHERE b.num_credito = num_credito
												AND b.fecha_mov = fecha_mov
												AND codigo_fun in (select cod_fun from sd_conceptospagomanualcrd)
												AND codigo_ref = 1
												AND reversado= 'N');
			
					IF v_folio_suc IS NULL THEN
						CONTINUE FOREACH;
					END IF;
					
					SELECT SUM (b.monto)
						INTO v_monto
					FROM bdicred:sd_movhiscrd b 
					WHERE b.num_credito = v_num_credito
						AND b.fecha_mov = v_fecha_pago
						AND b.codigo_fun in (select cod_fun from sd_conceptospagomanualcrd )
						AND b.codigo_ref = 1
						AND b.reversado= 'N';
					
					
					LET dia_recorre = v_fecha_pago - 1 units day;
					
					SELECT monto_financiado
						INTO v_monto_financiado
					FROM bdicred:sd_maesdoshistcrd 
					WHERE num_credito = v_num_credito 
						AND fecha = dia_recorre;
					
					SELECT  ciu.nombre
						INTO vCiudad
					FROM bdinteg:si_direcciones_actual dir
						LEFT OUTER JOIN bdinteg:si_ciudades ciu ON(ciu.pais=dir.pais and ciu.estado=dir.estado and ciu.ciudad=dir.ciudad)
						LEFT OUTER JOIN bdinteg:si_catciudades catciu ON (dir.numerociudad = catciu.numerociudad)
					WHERE dir.numcte = v_numcte AND dir.tipo_dir='1';	
					
					IF 	vCiudad IS NULL THEn
						LET vCiudad = 'SIN CIUDAD';
					END IF;
					
					LET vCiudad =TRIM (vCiudad);
					
					SELECT nombre1, nombre2,apell_paterno  
						INTO  vNombre,vNombre2, vApellido
					FROM bdinteg:si_cliente 
						WHERE numcte = v_numcte;
						
						IF LENGTH(vNombre) < 4 AND LENGTH(vNombre2) > 0 THEN
							LET vNombre =  vNombre2;
							LET vNombreCompleto = TRIM(vNombre)||' '||TRIM(vApellido);
						ELSE
							LET vNombreCompleto = TRIM(vNombre)||' '||TRIM(vApellido);
						END IF;
					
					SELECT telefono
						INTO v_telefono
					FROM bdinteg:"informix".si_telefonos_actual 
					WHERE numcte = v_numcte 
						AND tipo_tel = 2
						AND status_tel = 'A';
						
					IF 	v_telefono IS NULL THEN
						LET v_telefono = '';
					END IF;
						
					SELECT correo_elec
						INTO v_correo
					FROM bdinteg:si_correos 
					WHERE numcte = v_numcte
						AND status_correo = 'A'
						AND valido = 1
						AND secuencia in (SELECT MAX (secuencia) 
							FROM bdinteg:si_correos 
							WHERE numcte = v_numcte AND  status_correo = 'A'
							and valido = 1);
					
						IF v_correo IS NULL THEN
							LET v_correo = 'NO EXISTE';
						END IF;
						
						LET v_correo = TRIM (v_correo);
					
					--- insert tabla reporte
					BEGIN;
					INSERT INTO bdicred:sd_reporte_concurso 
					VALUES(0,v_numcte,v_num_credito,vCiudad,v_nombre_prod,v_fecha_mov||' '|| v_hora_mov,vNombreCompleto,v_telefono,v_correo,v_monto_financiado,v_monto,v_fecha_mov,v_folio_suc,FechaHoy);
					COMMIT;

			END FOREACH;
			
			DROP TABLE maesdoshist1_crd;
			
		END FOREACH;		
	END;
	
	RETURN vcodret;

END PROCEDURE
DOCUMENT
'GENERA REPORTE CONCURSO BANCOPPEL PARA PRODUCTOS DE PP, SE DIVIDE PROCESO PARA REDUCIR TIEMPO',
'ESTE PROCESO NO GENERA REPORTE YA QUE EL PROCESO DE TDC TARDA HORA Y MEDIA Y ESTE 50 MINUTOS',
'SE DEJA EL REPORTE PARA QUIEN TARDA MAS Y ASI TENER TODO EL UNIVERSO',
'AUTOR : ISRAEL TRAVIESO DIAZ',
'FECHA : MAY/2020',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_diferir(pcte CHAR(20), pcel CHAR(10), ptar CHAR(20), pcanal SMALLINT)
	RETURNING CHAR(5) as codret, CHAR(100) as desc_err;

    DEFINE vcodret CHAR(5);
	DEFINE vtermcdto CHAR(4);
    DEFINE vsqlerr, vcant, vcantr,vcantp, vsumavencidosr, vsumavencidosp, auxBaja INTEGER;
	DEFINE vCredito	CHAR(20);
	DEFINE cEmpresa CHAR(3);
	DEFINE vcadena CHAR(500);
	DEFINE vCliente	CHAR(20);
	DEFINE cCodRetSp CHAR (5);
	DEFINE dPagoMinimo DECIMAL(18,2);
	DEFINE dSdoActCap DECIMAL(18,2);
	DEFINE dPagoNoIntereses DECIMAL(14,2);
	DEFINE vSoloConsulta CHAR(1);

	DEFINE vSaldoGenNull INTEGER;
	DEFINE vSaldoGenOK INTEGER;

    LET vcodret    = '00000';
	LET vtermcdto   ='';
	LET vCredito   = '';
	LET cEmpresa 	= '001';
	LET vcadena	   = '';

	LET vSaldoGenNull = 0;
	LET vSaldoGenOK = 0;
	LET cCodRetSp='00000';
	
	LET dPagoMinimo = NULL;
	LET dSdoActCap = NULL;
	LET dPagoNoIntereses = NULL;

    LET vcant = 0;
    LET vcantr = 0;
    LET vcantp = 0;
    LET vsumavencidosr = 0;
    LET vsumavencidosp = 0;
	LET vSoloConsulta = '';
    
    BEGIN

		ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret,'';
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


	LET vcodret = "00008";
	RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';


		IF (nvl(ptar,'') = 'CONSULTAR') THEN
			LET vSoloConsulta = '1';
			LET ptar = '';
		END IF;

		IF (LENGTH(pcel) = 0 OR pcel is null) AND (LENGTH(pcte) = 0 OR pcte is null) AND (LENGTH(ptar) = 0 OR ptar is null)  THEN
			LET vcodret = "00001";
			RETURN vcodret,'DATOS DE ENTRADA INVALIDOS, VERIFIQUE.';
        END IF;
			
		IF LENGTH(pcel) > 0 AND NOT pcel is null  THEN -- Obtiene cliente por numero de celular

		   SELECT COUNT(DISTINCT(numcte))  INTO vcant 
			FROM bdinteg:si_telefonos_actual 
			WHERE telefono=pcel  AND tipo_tel='2' AND status_tel='A' ;		

		--SI HAY MAS DE UN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
		    IF vcant > 1 THEN 
	           LET vcodret = "00002";
	           RETURN vcodret,'NUMERO CELULAR ASOCIADO A MAS DE UN CLIENTE';

	       --SI NO HAY NINGUN NUMERO DE CLIENTE ASOCIADO TERMINA EL PROCESO
	        ELIF vcant < 1 THEN 
	           LET vcodret = "00003";
	           RETURN vcodret,'NUMERO DE TELEFONO NO ASIGNADO A UN CLIENTE.';
  	       END IF;
		   
		   -- OBTENEMOS EL NUMERO DE CLIENTE
		    SELECT numcte  INTO vCliente
			FROM bdinteg:si_telefonos_actual a
			WHERE telefono=pcel  AND tipo_tel='2' AND status_tel='A' ;
		ELIF LENGTH(ptar) > 0 AND NOT ptar is null  THEN -- Obtiene cliente por el numero de tarjeta
            SELECT first 1 numcte INTO vCliente 
            FROM  bdicheq:sc_tarjeta b	
            WHERE b.num_tarjeta = ptar
              AND tipo_tarjeta = 'T'
              AND status_tar = 'A'; 	

            IF (nvl(vCliente,'') = '') THEN
                SELECT first 1 numcte INTO vCliente 
                FROM  bdicred:sd_tarjeta b	
                WHERE b.num_tarjeta = ptar
                  AND tipo_tarjeta = 'T'
                  AND status_tar = 'A'; 	
            END IF;

            IF (nvl(vCliente,'') = '') THEN
	           LET vcodret = "00004";
	           RETURN vcodret,'NUMERO DE TARJETA INVALIDA.';
            END IF;
        ELSE -- ASIGNA POR NUMERO DE CLIENTE PROPORCIONADO
            SELECT numcte INTO vCliente
            FROM bdinteg:si_cliente
            WHERE numcte=pcte;

            IF (nvl(vCliente,'')) = '' THEN
                LET vcodret = "00007";
                RETURN vcodret,'CLIENTE NO EXISTE.';
            END IF;
        END IF;

		-- SE VALIDA QUE EL CLIENTE YA ESTE REGISTRADO
        SELECT numcte,canal_baja INTO vcant,auxBaja
        FROM  bdicred:sd_diferir b	
        WHERE b.numcte=vCliente; 	
		
		IF auxBaja is NULL THEN
			LET auxBaja = 0;
		END IF;
		
		IF vSaldoGenNull <> auxBaja THEN
			LET vcodret = '00011';
			RETURN vcodret,'LA SOLICITUD DE CANCELACION YA SE REGISTRO PREVIAMENTE.';
		END IF;

        IF vSaldoGenNull <> vcant  THEN
	       LET vcodret = "00005";
           RETURN vcodret, 'TU SOLICITUD YA SE REGISTRO PREVIAMENTE.';
        END IF;
		
        --VALIDA QUE ESTE AL CORRIENTE AL 29 DE FEBRERO DEL 2020 y AL DIA DE HOY
	    SELECT COUNT(*), sum(case when c.status_cred <> 'AA' then 1 else 0 end), sum(case when b.status_cred not in ('AA','FF') then 1 else 0 end)
        INTO vcantr, vsumavencidosr, vsumavencidosp
        FROM  bdicred:sd_maecred b,
              bdicred:sd_maecredcont c
        WHERE b.numcte=vCliente
        AND b.num_producto IN ('6001','8100') 
        and b.num_credito = c.num_credito
        and b.fecha_apertura <= mdy('03','31','2020')
        and c.fecha = mdy('03','31','2020');


		IF (vSaldoGenNull <> nvl(vsumavencidosr,0))  THEN
            LET vcodret = "00008";
			RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
		END IF;

		IF (vSaldoGenNull <> nvl(vsumavencidosp,0))  THEN
            LET vcodret = "00009";
			RETURN vcodret,'CLIENTE NECESITA ESTAR AL CORRIENTE PARA ENTRAR AL PROGRAMA.';
		END IF;

	    SELECT COUNT(*), sum(case when c.status_cred <> 'AA' then 1 else 0 end), sum(case when b.status_cred not in ('AA','FF') then 1 else 0 end)
        INTO vcantp, vsumavencidosr, vsumavencidosp
        FROM  bdicred:sd_maecredcrd b,
              bdicred:sd_maecredcontcrd c
        WHERE b.numcte=vCliente
        AND b.num_producto IN ('6300','6800','7600','7700') 
        and b.num_credito = c.num_credito
        and b.fecha_apertura <= mdy('03','31','2020')
        and c.fecha = mdy('03','31','2020');

		IF (vSaldoGenNull <> nvl(vsumavencidosr,0))  THEN
            LET vcodret = "00008";
			RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
		END IF;

		IF (vSaldoGenNull <> nvl(vsumavencidosp,0))  THEN
            LET vcodret = "00009";
			RETURN vcodret,'CLIENTE NECESITA ESTAR AL CORRIENTE PARA ENTRAR AL PROGRAMA.';
		END IF;

		IF (vSaldoGenNull = vcantp)  THEN
        --- Valida linea de credito flexible
            select count(*)
            into vcantp
            from bdicred:sd_maecredcrd a,
                 bdicred:sd_linea_prestamo b
            where a.numcte = vCliente
              and a.num_credito = b.num_credito
              and b.fecha_otorga <= mdy('03','31','2020')
              and fecha_cancela is null;

            IF (vcantp > vSaldoGenNull) THEN
				SELECT COUNT(*), sum(case when c.status_cred <> 'AA' then 1 else 0 end), 
				sum(case when b.status_cred not in ('AA','FF') then 1 else 0 end)
				INTO vcantp, vsumavencidosr, vsumavencidosp
				FROM  bdicred:sd_maecredcrd b,
					  bdicred:sd_maecredcontcrd c
				WHERE b.numcte=vCliente
				AND b.num_producto = '6800'
				and b.num_credito = c.num_credito
				and c.fecha = mdy('03','31','2020');			
				
				IF (vSaldoGenNull <> nvl(vsumavencidosr,0))  THEN
					LET vcodret = "00008";
					RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
				END IF;

				IF (vSaldoGenNull <> nvl(vsumavencidosp,0))  THEN
					LET vcodret = "00009";
					RETURN vcodret,'CLIENTE NECESITA ESTAR AL CORRIENTE PARA ENTRAR AL PROGRAMA.';
				END IF;			
			END IF;


            IF (vSaldoGenNull = vcantp  + vcantr) THEN
                LET vcodret = "00008";
                RETURN vcodret,'TU SOLICITUD NO PUEDE SER RECIBIDA, NO CUENTAS CON UN CREDITO PARTICIPANTE EN EL PLAN DE APOYO.';
            END IF;
		END IF;

		IF (vSoloConsulta = '1') THEN
			LET vcodret = "00010";
            RETURN vcodret,'CLIENTE ES CANDIDATO AL APOYO.';
		ELSE
			INSERT INTO "informix".sd_diferir (numcte, num_tarjeta, fecha, canal, telefono)
				VALUES(vCliente, ptar,CURRENT,pcanal,pcel);
			RETURN vcodret, 'SOLICITUD RECIBIDA DE MANERA EXITOSA. CONSULTA TERMINOS Y CONDICIONES EN www.bancoppel.com';
		END IF;
	END;
END PROCEDURE;