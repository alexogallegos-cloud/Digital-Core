CREATE PROCEDURE "informix".sp_extraectascap(vdatefecoper DATE)
RETURNING VARCHAR(5), VARCHAR(50), INTEGER;
-----------------------------------------------------------------------------------
--Definicion de variables del proceso, operaciones con fechas y manejo de errores--
-----------------------------------------------------------------------------------
--//Variables de Proceso
DEFINE vcodret1         VARCHAR(5);
DEFINE vcodret2         VARCHAR(5);
DEFINE error_info		VARCHAR(50);
DEFINE sql_err          INTEGER;
DEFINE isam_err         INTEGER;
DEFINE vcontador1       INTEGER;
DEFINE vcontador2       INTEGER;
--DEFINE vdatefecoper     DATE;
DEFINE vcharcta   		VARCHAR(20);
DEFINE vdatefeccan		DATE;
--//Variables de Opereaciones
DEFINE vrb_producto    	VARCHAR(4);
DEFINE vrb_cuenta      	VARCHAR(20);
DEFINE vrb_num_cte     	VARCHAR(20);
DEFINE vrb_status      	VARCHAR(1);
DEFINE vrb_saldo       	VARCHAR(2);
DEFINE vrb_fech_ult_mov	DATE; 
DEFINE feculmesant		DATE;
DEFINE vfechames        DATE;
DEFINE vaniomes			CHAR(6);
DEFINE vcampo           VARCHAR(8);
DEFINE vcamp0           VARCHAR(8);
DEFINE vcamp1           VARCHAR(8);
DEFINE vcamp2           VARCHAR(8);
DEFINE vcamp3           VARCHAR(8);
---------------------------
--Inicializando variables--
---------------------------
--SET DEBUG FILE TO "/informix/ifg/sp_cancela_ctas_benef.out"; --Se genera log en un archivo .out
--TRACE ON;
LET error_info		= 'INICIA PROCESO, SE CARGAN VARIABLES';
LET vcodret1        = '00000';
LET vcodret2        = '00000';
LET sql_err	        = 0;
LET isam_err        = 0;
LET vcontador1      = -1;
LET vcontador2      = 0;
--LET vdatefecoper    = TODAY;
LET vcharcta   		= '';
LET vdatefeccan		= TODAY;
LET feculmesant		= LAST_DAY((EXTEND(vdatefecoper, YEAR TO MONTH) -1 UNITS MONTH)::DATE);
LET vfechames 		= (EXTEND(vdatefecoper, YEAR TO MONTH) -1 UNITS MONTH)::DATE;
LET vaniomes 		= SUBSTRING (vfechames FROM 7 FOR 4)||SUBSTRING (vfechames FROM 1 FOR 2);
LET vcampo 			= 'capvig'||SUBSTRING (feculmesant FROM 4 FOR 2);
LET vcamp0 			= 'capvig28';
LET vcamp1 			= 'capvig29';
LET vcamp2 			= 'capvig30';
LET vcamp3 			= 'capvig31';
-------------
--Inicia SP--
-------------
	BEGIN
		-------------------------
		--Manejo de excepciones--
		-------------------------
		ON EXCEPTION SET sql_err, isam_err, error_info
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET error_info = error_info;
			END IF;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		--//se valida si existe la tabla para eliminarla
			IF EXISTS (SELECT dbsname, tabname FROM sysmaster:systabnames WHERE tabname = 'sc_tblmstcap')
			THEN 	
						DROP TABLE "informix".sc_tblmstcap;
						LET error_info = 'Se borro tabla sc_tblmstcap';
			END IF;
		--//se crea tabla tabla
		CREATE TABLE "informix".sc_tblmstcap ( 
												producto    	char(4),
												cuenta      	char(20),
												num_cte     	char(20),
												status      	char(1),
												saldo       	char(2),
												fech_ult_mov	date 
											 )
											 IN datos00 EXTENT SIZE 1523440 NEXT SIZE 32 LOCK MODE ROW;
		LET error_info = 'Se crea tabla sc_tblmstcap';
		--//Inicia SPL
		IF (vcampo = vcamp0) THEN
							SET ISOLATION TO DIRTY READ;
							SET LOCK MODE TO WAIT 4;
							FOREACH WITH HOLD
										SELECT A.producto, A.cuenta, A.num_cte,
														CASE 
															WHEN B.statuscta28 != '' THEN  b.statuscta28
															WHEN B.statuscta28 = '' THEN  A.status_cta
														END AS status,
														CASE 
															WHEN B.capvig28 <= 0 THEN  'S1'
															WHEN B.capvig28 BETWEEN 0.01 AND 999.99 THEN  'S2'
															WHEN B.capvig28 >= 1000 THEN  'S3'
														END AS saldo,
														CASE
															WHEN A.fecultret IS NULL THEN A.fecultdep
															WHEN A.fecultdep IS NULL THEN A.fecultret 
															WHEN (A.fecultdep IS NULL AND A.fecultret IS NULL) THEN A.fecha_proceso
															WHEN A.fecultdep = A.fecultret THEN A.fecultdep
															WHEN A.fecultdep > A.fecultret THEN A.fecultdep
															WHEN A.fecultdep < A.fecultret THEN A.fecultret
														END AS fech_ult_mov
														INTO vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov
											FROM sc_maechq A 
											 INNER JOIN sc_sdodiarioc b ON A.cuenta = b.cuenta 
											  WHERE A.empresa = '001'
													AND A.producto IN ('2000',
																	'1300',
																	'1400',
																	'1800',
																	'1500',
																	'1700',
																	'1900',
																	'2500',
																	'2400')
													AND A.status_cta != 2
													AND B.aniomes = vaniomes
											--/SE ACTIVA CONTADOR 1 	
											IF vcontador1 = -1 THEN
													LET vcontador1 = 0;
													BEGIN WORK;
											END IF;
											--//INSERTA REGISTRO 
											INSERT INTO "informix".sc_tblmstcap(producto, cuenta, num_cte, status, saldo, fech_ult_mov)
												VALUES(vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov);
											 --/incrementea contadores
										   LET vcontador1 = vcontador1 + 1;
										   LET vcontador2 = vcontador2 + 1; 
										   --/CADA 1000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
											IF vcontador2 >= 1000 THEN
														LET vcontador2 = 0;
														COMMIT WORK;
														BEGIN WORK;
											 END IF;
							END FOREACH;
							IF (vcontador2 > 0) THEN		
										COMMIT WORK;
							END IF; 
							LET error_info = 'TOTAL DE CUENTAS '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||'.';
		END IF;
		IF (vcampo = vcamp1) THEN
							SET ISOLATION TO DIRTY READ;
							SET LOCK MODE TO WAIT 4;
							FOREACH WITH HOLD
										SELECT A.producto, A.cuenta, A.num_cte,
														CASE 
															WHEN B.statuscta29 != '' THEN  b.statuscta29
															WHEN B.statuscta29 = '' THEN  A.status_cta
														END AS status,
														CASE 
															WHEN B.capvig29 <= 0 THEN  'S1'
															WHEN B.capvig29 BETWEEN 0.01 AND 999.99 THEN  'S2'
															WHEN B.capvig29 >= 1000 THEN  'S3'
														END AS saldo,
														CASE
															WHEN A.fecultret IS NULL THEN A.fecultdep
															WHEN A.fecultdep IS NULL THEN A.fecultret 
															WHEN (A.fecultdep IS NULL AND A.fecultret IS NULL) THEN A.fecha_proceso
															WHEN A.fecultdep = A.fecultret THEN A.fecultdep
															WHEN A.fecultdep > A.fecultret THEN A.fecultdep
															WHEN A.fecultdep < A.fecultret THEN A.fecultret
														END AS fech_ult_mov
														INTO vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov
											FROM sc_maechq A 
											 INNER JOIN sc_sdodiarioc b ON A.cuenta = b.cuenta 
											  WHERE A.empresa = '001'
													AND A.producto IN ('2000',
																	'1300',
																	'1400',
																	'1800',
																	'1500',
																	'1700',
																	'1900',
																	'2500',
																	'2400')
													AND A.status_cta != 2
													AND B.aniomes = vaniomes
											--/SE ACTIVA CONTADOR 1 	
											IF vcontador1 = -1 THEN
													LET vcontador1 = 0;
													BEGIN WORK;
											END IF;
											--//INSERTA REGISTRO 
											INSERT INTO "informix".sc_tblmstcap(producto, cuenta, num_cte, status, saldo, fech_ult_mov)
												VALUES(vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov);
											 --/incrementea contadores
										   LET vcontador1 = vcontador1 + 1;
										   LET vcontador2 = vcontador2 + 1; 
										   --/CADA 1000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
											IF vcontador2 >= 1000 THEN
														LET vcontador2 = 0;
														COMMIT WORK;
														BEGIN WORK;
											 END IF;
							END FOREACH;
							IF (vcontador2 > 0) THEN		
										COMMIT WORK;
							END IF; 
							LET error_info = 'TOTAL DE CUENTAS '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||'.';
		END IF;
		IF (vcampo = vcamp2) THEN
							SET ISOLATION TO DIRTY READ;
							SET LOCK MODE TO WAIT 4;
							FOREACH WITH HOLD
										SELECT A.producto, A.cuenta, A.num_cte,
														CASE 
															WHEN B.statuscta30 != '' THEN  b.statuscta30
															WHEN B.statuscta30 = '' THEN  A.status_cta
														END AS status,
														CASE 
															WHEN B.capvig30 <= 0 THEN  'S1'
															WHEN B.capvig30 BETWEEN 0.01 AND 999.99 THEN  'S2'
															WHEN B.capvig30 >= 1000 THEN  'S3'
														END AS saldo,
														CASE
															WHEN A.fecultret IS NULL THEN A.fecultdep
															WHEN A.fecultdep IS NULL THEN A.fecultret 
															WHEN (A.fecultdep IS NULL AND A.fecultret IS NULL) THEN A.fecha_proceso
															WHEN A.fecultdep = A.fecultret THEN A.fecultdep
															WHEN A.fecultdep > A.fecultret THEN A.fecultdep
															WHEN A.fecultdep < A.fecultret THEN A.fecultret
														END AS fech_ult_mov
														INTO vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov
											FROM sc_maechq A 
											 INNER JOIN sc_sdodiarioc b ON A.cuenta = b.cuenta 
											  WHERE A.empresa = '001'
													AND A.producto IN ('2000',
																	'1300',
																	'1400',
																	'1800',
																	'1500',
																	'1700',
																	'1900',
																	'2500',
																	'2400')
													AND A.status_cta != 2
													AND B.aniomes = vaniomes
											--/SE ACTIVA CONTADOR 1 	
											IF vcontador1 = -1 THEN
													LET vcontador1 = 0;
													BEGIN WORK;
											END IF;
											--//INSERTA REGISTRO 
											INSERT INTO "informix".sc_tblmstcap(producto, cuenta, num_cte, status, saldo, fech_ult_mov)
												VALUES(vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov);
											 --/incrementea contadores
										   LET vcontador1 = vcontador1 + 1;
										   LET vcontador2 = vcontador2 + 1; 
										   --/CADA 1000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
											IF vcontador2 >= 1000 THEN
														LET vcontador2 = 0;
														COMMIT WORK;
														BEGIN WORK;
											 END IF;
							END FOREACH;
							IF (vcontador2 > 0) THEN		
										COMMIT WORK;
							END IF; 
							LET error_info = 'TOTAL DE CUENTAS '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||'.';
		END IF;
		IF (vcampo = vcamp3) THEN
							SET ISOLATION TO DIRTY READ;
							SET LOCK MODE TO WAIT 4;
							FOREACH WITH HOLD
										SELECT A.producto, A.cuenta, A.num_cte,
														CASE 
															WHEN B.statuscta31 != '' THEN  b.statuscta31
															WHEN B.statuscta31 = '' THEN  A.status_cta
														END AS status,
														CASE 
															WHEN B.capvig31 <= 0 THEN  'S1'
															WHEN B.capvig31 BETWEEN 0.01 AND 999.99 THEN  'S2'
															WHEN B.capvig31 >= 1000 THEN  'S3'
														END AS saldo,
														CASE
															WHEN A.fecultret IS NULL THEN A.fecultdep
															WHEN A.fecultdep IS NULL THEN A.fecultret 
															WHEN (A.fecultdep IS NULL AND A.fecultret IS NULL) THEN A.fecha_proceso
															WHEN A.fecultdep = A.fecultret THEN A.fecultdep
															WHEN A.fecultdep > A.fecultret THEN A.fecultdep
															WHEN A.fecultdep < A.fecultret THEN A.fecultret
														END AS fech_ult_mov
														INTO vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov
											FROM sc_maechq A 
											 INNER JOIN sc_sdodiarioc b ON A.cuenta = b.cuenta 
											  WHERE A.empresa = '001'
													AND A.producto IN ('2000',
																	'1300',
																	'1400',
																	'1800',
																	'1500',
																	'1700',
																	'1900',
																	'2500',
																	'2400')
													AND A.status_cta != 2
													AND B.aniomes = vaniomes
											--/SE ACTIVA CONTADOR 1 	
											IF vcontador1 = -1 THEN
													LET vcontador1 = 0;
													BEGIN WORK;
											END IF;
											--//INSERTA REGISTRO 
											INSERT INTO "informix".sc_tblmstcap(producto, cuenta, num_cte, status, saldo, fech_ult_mov)
												VALUES(vrb_producto, vrb_cuenta, vrb_num_cte, vrb_status, vrb_saldo, vrb_fech_ult_mov);
											 --/incrementea contadores
										   LET vcontador1 = vcontador1 + 1;
										   LET vcontador2 = vcontador2 + 1; 
										   --/CADA 1000 REGISTROS ACTUALIZADOS SE TERMINA EL TRABAJO E INICA DE NUEVO
											IF vcontador2 >= 1000 THEN
														LET vcontador2 = 0;
														COMMIT WORK;
														BEGIN WORK;
											 END IF;
							END FOREACH;
							IF (vcontador2 > 0) THEN		
										COMMIT WORK;
							END IF; 
							LET error_info = 'TOTAL DE CUENTAS '||substr(vdatefecoper, 4,2) || '/'|| substr(vdatefecoper, 1,2) || '/'|| substr(vdatefecoper, 7,4)||'.';
		END IF;
		RETURN vcodret1, error_info, vcontador1;
	END;
END PROCEDURE
DOCUMENT
'AUTOR: Israel Flores Gonzalez',
'Descripcion: Proceso automativo que crea la tabla sc_tblmstcap',
'             para gurdar en ella todolos los registros de las',
'             cuentas de captacion de los prosuctos listados en el',
'			  RQM 10 814',
'Fecha: 2017/08/28',
'Peticion:RQM 10 814 - Número de Cuentas de Captación',
'Version: 20170828.1',
'BD: BDICHEQ',
'AUTOR: Israel Flores Gonzalez',
'Descripcion: Se modifica el proceso para que se pueda usar por',
'             medio de un Job en Control-M y tome la fecha del',
'             último día del mes sin imporetar el día del mes en el',
'			  que se ejecute',
'Fecha: 2017/10/24',
'Peticion:RQM 10 814 - Número de Cuentas de Captación',
'Version: 20171014.1',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_edoctagenerales_bei(pempresa CHAR(3), 
											   pcuenta CHAR(20), 
											   paniomes CHAR(6), 
											   ptipo CHAR(1))

  RETURNING CHAR(5), CHAR(45), CHAR(10), CHAR(16), CHAR(18), DATE, DATE,
			MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),
			MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2), MONEY(14, 2),
			SMALLINT, DECIMAL(9, 6), CHAR(20), CHAR(107), CHAR(10),
			CHAR(10), CHAR(30), CHAR(30), CHAR(30), CHAR(30),
			CHAR(5), CHAR(13), DATE, CHAR(40);
			
			
			
    DEFINE cCodret, cCodPostal CHAR(5);
    DEFINE cNumExt, cNumInt, cNumProducto CHAR(10);
    DEFINE cRFC CHAR(13);
    DEFINE cNumTarjeta CHAR(16);
    DEFINE cClabe CHAR(18);
    DEFINE cNumcte CHAR(20);
    DEFINE cNomCalle, cNomColonia, cNomCiudad, cNomEstado CHAR(30);
    DEFINE cNomSucursal CHAR(40);
    DEFINE cProducto CHAR(45);
    DEFINE cNomcte CHAR(107);
    DEFINE dFechaini, dFechafin, dFechaAlta DATE;
    DEFINE mSaldoAnterior, mDepositos, mRetiros, mInteresesPagados MONEY(14, 2);
    DEFINE mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, mAux1 MONEY(14, 2);
    DEFINE mSaldoPromedio, mRetencionIsr, mInteresesNetos MONEY(14, 2);
    DEFINE dTasaBruta DECIMAL(9, 6);
    DEFINE sDias, sSec_dir SMALLINT;
    DEFINE iSqlerr, iIsamerr INTEGER;
    DEFINE cMes, cMes2 CHAR(2);
	

    LET cCodret = "000";
    LET cProducto = "";
    LET cNumProducto = "";
    LET cNumTarjeta = "";
    LET cClabe = "";
    LET cNumcte = "";
    LET cNomcte = "";
    LET cNumExt = "";
    LET cNumInt = "";
    LET cNomCalle = "";
    LET cNomColonia = "";
    LET cNomCiudad = "";
    LET cNomEstado = "";
    LET cCodPostal = "";
    LET cRFC = "";
    LET cNomSucursal = "";
    LET dFechaini = "";
    LET dFechafin = "";
    LET dFechaAlta = "";
    LET mSaldoPromedio= 0;
    LET mInteresesNetos = 0;
    LET mSaldoAnterior = 0;
    LET mDepositos = 0;
    LET mRetiros = 0;
    LET mInteresesPagados = 0;
    LET mOtrosCargos = 0;
    LET mIvaOtrosCargos = 0;
    LET mSaldoCorte = 0;
    LET mRetencionIsr = 0;
    LET sDias = 0;
    LET dTasaBruta = 0;
    LET mAux1 = 0;
    LET sSec_dir = 0;    
    LET pcuenta = TRIM(pcuenta);

    BEGIN
	

    ON EXCEPTION SET iSqlerr, iIsamerr
	IF iSqlerr != 0 THEN

	    LET cCodret=iSqlerr;

	    RETURN cCodret, cProducto, cNumProducto, cNumTarjeta, cClabe, 
			dFechaini, dFechafin,
		   mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
		   mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
		   sDias, dTasaBruta, cNumcte, cNomcte, cNumExt,
		   cNumInt, cNomCalle, cNomColonia, cNomCiudad, cNomEstado,
		   cCodPostal, cRFC, dFechaAlta, cNomSucursal;
	END IF;
    END EXCEPTION;
	
	
	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_edoctagenerales_bei.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT ;
	SET ISOLATION DIRTY READ ;
	
    IF EXISTS (SELECT cuenta 
		 FROM bdicheq:"informix".sc_maechq 
		WHERE cuenta = pcuenta) THEN	

		IF ptipo = '0' THEN

		    -- // OBTENER EL ESTADO DE CUENTA

		    -- // SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
			
		    SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, chq.producto, --mc.num_tarjeta, -- tj.num_tarjeta,
	        	   TRIM(chq.num_cte), chq.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin, MDY(1, 1, 1900)),
	        	   NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), --NVL(totintpag, 0), 
				   NVL(totretiros, 0)
	        	  -- NVL(totcomcobrada, 0), NVL(totivacobrado, 0), NVL(sdo_actual, 0), NVL(totisrcobrado, 0),
	        	   --NVL(dia_sdo_pos, 0), (NVL(tasabruta, 0)*100), NVL(acum_sdo_pos, 0)
		      INTO cProducto, cNumProducto, --cNumTarjeta, 
					cNumcte, cClabe, dFechaini, dFechafin,
	        	   mSaldoAnterior, mDepositos,-- mInteresesPagados, 
				   mRetiros
	        	   --mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
	        	  -- mRetencionIsr, sDias, dTasaBruta, mAux1
		      FROM bdicheq:"informix".sc_maehis_factelect AS mc,
	        	   bdicheq:"informix".sc_producto AS ap,
				   bdicheq:sc_maechq AS chq
	        	-- sc_tarjeta AS tj
		     WHERE mc.empresa = pempresa 
	               AND mc.cuenta = pcuenta 
	               AND mc.aniomes = paniomes 
	               AND mc.empresa = ap.empresa 
				   AND chq.cuenta = pcuenta
	               AND ap.producto = chq.producto;
	            -- AND mc.empresa = tj.empresa
	            -- AND mc.cuenta = tj.cuenta
	            -- AND tipo_tarjeta = "T"
	            -- AND tj.num_tarjeta = (SELECT num_tarjeta
	            --       	               FROM sc_tarjeta
	            --       	              WHERE cuenta = pcuenta 
	            -- 			        AND secuencia = (SELECT MAX(secuencia) FROM sc_tarjeta WHERE cuenta = pcuenta));

		ELIF ptipo = '1'  THEN

		    LET dFechaini = "";
		    LET dFechafin = "";
		    LET cMes = "";
		    LET cMes2 = "";

		    -- // SE MODIFICO PARA QUE MOSTRARA EL NUMERO DE TARJETA DE LA CUENTA MAS ACTUAL DEL CLIENTE
					
			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
					
			SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto, -- tj.num_tarjeta,
				TRIM(mc.num_cte), mc.cuenta_clabe, MDY(1, 1, 1900), MDY(1, 1, 1900),
				NVL(mc.sdo_dia_ant, 0), NVL(mc.depositos_cantidad, 0), 0, NVL(mc.retiros_cantidad, 0),
				0, 0, NVL(mc.sdo_actual, 0), 0, 0, 0, 0
			INTO cProducto, cNumProducto, -- cNumTarjeta, 
				cNumcte, cClabe, 
				dFechaini, dFechafin,
				mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros,
				mOtrosCargos, mIvaOtrosCargos, mSaldoCorte,
				mRetencionIsr, sDias, dTasaBruta, mAux1
			FROM bdicheq:"informix".sc_maechq AS mc,
				bdicheq:"informix".sc_producto AS ap
				-- sc_tarjeta AS tj
			WHERE mc.empresa = pempresa 
				AND mc.cuenta = pcuenta 
				AND mc.empresa = ap.empresa
				AND mc.producto = ap.producto;
				-- AND mc.empresa = tj.empresa 
				-- AND mc.cuenta = tj.cuenta 
				-- AND tipo_tarjeta = "T" 
				-- AND tj.num_tarjeta = (SELECT num_tarjeta
				--		               FROM sc_tarjeta
				--			      WHERE cuenta = pcuenta
				--				AND secuencia = (SELECT MAX(secuencia) FROM sc_tarjeta WHERE cuenta = pcuenta));

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
				
			IF NOT EXISTS(SELECT num_tarjeta 
				FROM bdicheq:"informix".sc_tarjeta 
			    WHERE empresa = pempresa 
				AND cuenta = pcuenta
				AND secuencia = (SELECT MAX(secuencia) 
				FROM sc_tarjeta
				WHERE empresa = pempresa
				AND cuenta = pcuenta)) THEN

				LET cNumTarjeta = " ";

			ELSE 

				SELECT tj.num_tarjeta 
				INTO cNumTarjeta
				FROM bdicheq:"informix".sc_tarjeta AS tj
				WHERE tj.empresa = pempresa 
				AND tj.num_tarjeta = (SELECT num_tarjeta
				FROM bdicheq:"informix".sc_tarjeta
				WHERE empresa = pempresa 
				AND cuenta = pcuenta 
				AND secuencia = (SELECT MAX(secuencia) 
				FROM bdicheq:"informix".sc_tarjeta 
				WHERE empresa = pempresa 
				AND cuenta = pcuenta))
				AND tj.cuenta = pcuenta
				AND tipo_tarjeta = "T";

			END IF;

			-- Se obtiene la fecha de inicio para presentar los Movimientos, fecha fin de su ultimo mesiversario
			If Exists (SELECT MAX(fechafin) FROM bdicheq:"informix".sc_maehis_factelect WHERE empresa = pempresa AND cuenta = pcuenta) then
				SELECT MAX(fechafin) INTO dFechaini 
				FROM bdicheq:"informix".sc_maehis_factelect 
				WHERE empresa = pempresa 
				AND cuenta = pcuenta;
			Else -- Si la cuenta no ha tenido un mesiversario se toma la fecha de alta de la cuenta
				SELECT fecha_alta INTO dFechaini 
				FROM bdicheq:"informix".sc_maenoc 
				WHERE empresa = pempresa 
				AND cuenta = pcuenta;
			End If				
			
			-- Se obtiene la fecha de hoy que es la fecha fin al consultar Movimientos
			SELECT fecha_hoy INTO dFechafin 
			FROM bdicheq:"informix".sc_fechas;
			
			--A la fecha de inicio se le suma 1 dia para que no considere los movtos que ya aparecen en el EdoCta
			LET dFechaini = dFechaini + 1 units day;		    					   
							    
		ELSE
		    LET cCodret = "005";
		END IF;

		IF cCodret <> '005' THEN

		    -- // Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL

			SET LOCK MODE TO WAIT ;
			SET ISOLATION DIRTY READ ;
			
		    SELECT MAX(secuencia) 
		    INTO sSec_dir
		    FROM bdinteg:"informix".si_direcciones
		    WHERE numcte = cnumcte 
		    AND tipo_dir = 1;
				   
		    IF sSec_dir IS NULL THEN
				LET sSec_dir = 1;
		    END IF

		    IF sDias = 0 THEN
		       LET mSaldoPromedio= 0;
		    ELSE
		       LET mSaldoPromedio= mAux1 / sDias;
		    END IF;

		    LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

		    IF cNumcte IS NULL THEN

				LET cCodret= "003";
					
				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;
					
				SELECT TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.producto,
					TRIM(mc.num_cte), mc.cuenta_clabe
				INTO cProducto, cNumProducto, cNumcte, cClabe
				FROM bdicheq:"informix".sc_maechq AS mc,
					bdicheq:"informix".sc_producto AS ap
				WHERE mc.empresa = pempresa 
					AND mc.cuenta = pcuenta 
					AND mc.empresa = ap.empresa 
					AND mc.producto = ap.producto;

				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;
					
				SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
				    suc.nombre, cte.fecha_insert, cte.rfc, dir.numeroextcalle, dir.numerointcalle,
				    TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
				INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cNumExt, cNumInt, cNomCalle,
					cNomColonia, cNomCiudad, cNomEstado, cCodPostal
				FROM bdinteg:"informix".si_cliente AS cte
					LEFT JOIN bdinteg:"informix".si_ctepm cpm ON (cpm.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_direcciones AS dir ON (dir.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
					LEFT JOIN bdinteg:"informix".si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
					LEFT JOIN bdinteg:"informix".si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
					LEFT JOIN bdinteg:"informix".si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
					LEFT JOIN bdinteg:"informix".si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
				WHERE cte.empresa = pempresa 
					AND cte.numcte = cNumcte 
					AND dir.secuencia = sSec_dir;
				   
				LET dFechaini = "";
				LET dFechafin = "";
				LET mSaldoAnterior = 0;
				LET mDepositos = 0;
				LET mInteresesPagados = 0;
				LET mRetiros = 0;
				LET mOtrosCargos = 0;
				LET mIvaOtrosCargos = 0;
				LET mSaldoCorte = 0;
				LET mSaldoPromedio = 0;
				LET mRetencionIsr = 0;
				LET mInteresesNetos = 0;
				LET sDias = 0;
				LET dTasaBruta = 0;

		    ELSE

				SET LOCK MODE TO WAIT ;
				SET ISOLATION DIRTY READ ;
			
				SELECT NVL(TRIM(cte.razon_social), "") || NVL(TRIM(cte.nombre1), "") || ' ' || NVL(TRIM(cte.nombre2), "") || ' ' || NVL(TRIM(cte.apell_paterno), "") || ' ' || NVL(TRIM(cte.apell_materno), "") AS nombrex,
					suc.nombre, cte.fecha_insert, cte.rfc, dir.numeroextcalle, dir.numerointcalle,
					TRIM(cal.nombrecalle), TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal
				INTO cNomcte, cNomSucursal, dFechaAlta, cRFC, cNumExt, cNumInt, cNomCalle, cNomColonia,
					cNomCiudad, cNomEstado, cCodPostal
				FROM bdinteg:"informix".si_cliente AS cte
					LEFT JOIN bdinteg:"informix".si_ctepm AS cpm ON (cpm.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_direcciones AS dir ON (dir.numcte = cte.numcte)
					LEFT JOIN bdinteg:"informix".si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
					LEFT JOIN bdinteg:"informix".si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
					LEFT JOIN bdinteg:"informix".si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
					LEFT JOIN bdinteg:"informix".si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
					LEFT JOIN bdinteg:"informix".si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
				WHERE cte.empresa = pempresa 
					AND cte.numcte = cNumcte 
					AND dir.secuencia = sSec_dir;

		    END IF;
		END IF;
    ELSE
		LET cCodret = "100";
    END IF;

    RETURN  cCodret, cProducto, cNumProducto, cNumTarjeta, cClabe, dFechaini, dFechafin,
			mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos,
			mIvaOtrosCargos, mSaldoCorte, mSaldoPromedio, mRetencionIsr, mInteresesNetos,
			sDias, dTasaBruta, cNumcte, cNomcte, cNumExt,
			cNumInt, cNomCalle, cNomColonia, cNomCiudad, cNomEstado,
			cCodPostal, cRFC, dFechaAlta, cNomSucursal;
	
    END;

END PROCEDURE
DOCUMENT
'CAMBIO     : Armando Mercado F.',
'DESCRIPCION: Se modifico para consultar los movimientos de cuenta a partir de su ultima fecha de corte,',
'             esto sin importar que su ultima fecha corte sea en el mismo mes que se desea consultar',
'Captacion',
'FECHA      : Septiembre 2009',
'VERSION    : 20090908',
'BD         : BDICHEQ',
'Modificó: Héctor Bojórquez',
'Descripción: Para obtener el dato de tasabruta de la tabla "sc_maehis" multiplicado por 100.',
'Fecha: 26/Octubre/2009',
' Modifico  : Gabriela Aguilar',
'Activdad  : Cambio de tabla de sc_maehis hacia  sc_maehis_factelect',
'fecha     : 10/11/2017';

CREATE PROCEDURE "informix".sp_obt_fec_edo_cta_deb(pCuenta char(20))
        RETURNING char(5), char(6), date, date;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener fechas para estado de cuenta de debito
    -- Solicitó  : Diana Castellanos
    -- Fecha     :  17/07/2008
	
	--------------------------------------------------------------------
	-- Modifico  : Gabriela Aguilar
	-- Activdad  : Cambio de tabla de sc_maehis hacia  sc_maehis_factelect
	-- fecha     : 10/11/2017
	
	
	

       DEFINE vcodret   char(5);
       DEFINE vAnioMes  char(6);
       DEFINE vFechaFin date;
       DEFINE vFechaIni date;
       DEFINE sql_err integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vAnioMes = '000000';
LET vFechaIni = '01/01/1900';
LET vFechaFin = '01/01/1900';
BEGIN

	--SET DEBUG FILE TO "/informix/gaby/ArchivosOut/sp_obt_fec_edo_cta_deb.out";
	--TRACE ON;


   SET ISOLATION DIRTY READ ;
   set lock mode to wait 3;

    FOREACH
        SELECT LIMIT 3 aniomes, fechaini, fechafin
        INTO vAnioMes, vFechaIni, vFechaFin
        --FROM sc_maehis
		FROM sc_maehis_factelect
        WHERE empresa = '001'
        AND cuenta = pCuenta
        ORDER BY fechaini DESC


        --IF vAnioMes IS NULL THEN
        --  LET vcodret = '100';
        --  RETURN vcodret, vAnioMes, vFechaIni, vFechaFin;
        --END IF;
        RETURN vcodret, vAnioMes, vFechaIni, vFechaFin WITH RESUME;
    END FOREACH;
END;

END PROCEDURE;