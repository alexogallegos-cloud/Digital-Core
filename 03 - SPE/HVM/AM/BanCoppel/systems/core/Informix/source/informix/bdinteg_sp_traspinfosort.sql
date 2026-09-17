CREATE PROCEDURE "informix".sp_traspinfosort(pdcve_sorteo CHAR(5), pfecha DATE)
	RETURNING CHAR(5) AS CodRetorno, CHAR(80) AS mensaje, INT AS reverso, CHAR(80) AS storedprocedure;
------------------------------------------------------------------------
--  Definicion de variables del proceso y operaciones con fechas
------------------------------------------------------------------------
	DEFINE		v_codigo_retorno 			CHAR(5);
	DEFINE		v_mensaje 					CHAR(80);
	DEFINE		v_reverso  					INT;
	DEFINE		v_store_pro 				CHAR(80);
	DEFINE		vcontador_fin 				INT;
	DEFINE		vcontador_ini				INT;
	DEFINE		vvalida 					DATE;
	DEFINE		vfsorteo 					DATE;
	DEFINE		vF_ini 						DATE;
	DEFINE		vF_Fin 						DATE;
	DEFINE 		vsqlerr			            INTEGER;
------------------------------------------------------------------------
--  Definicion de variables del proceso y manejo de errores
------------------------------------------------------------------------
	DEFINE		v_cve_sorteo				CHAR(5);
	DEFINE		v_valor						CHAR(5);
	DEFINE		v_boleto_ini				INT8;
	DEFINE		v_boleto_fin				INT8;
	DEFINE		v_f_registro				DATETIME YEAR to SECOND;
	DEFINE		v_numcte    				CHAR(9);
	DEFINE		v_status					INTEGER;	DEFINE		v_estado    				INTEGER;	DEFINE		v_sucursal  				CHAR(4);
	DEFINE		v_area      				CHAR(1);
	DEFINE		v_caja      				INT;
	DEFINE		v_tipomov   				CHAR(10);
	DEFINE		v_foliosuc  				CHAR(16);
	DEFINE		v_importe   				MONEY;
	DEFINE		v_fecha     				DATE;
	DEFINE		v_origen    				CHAR(10);
	DEFINE		v_secuencia 				INTEGER;
	DEFINE		v_numerocalle  				INT;
	DEFINE		v_numerociudad 				SMALLINT;
	DEFINE		v_numerocolonia				INT;
	DEFINE		v_nomestado       			CHAR(25);
	DEFINE		v_telefono1 				CHAR(10);
	DEFINE		v_telefono2 				CHAR(13);
	DEFINE 		v_nomcalle			        CHAR(20);
	DEFINE		v_nomcolonia			    CHAR(20);
	DEFINE		v_nomciudad			        CHAR(20);
	DEFINE		v_numeroextcalle			CHAR(10);
	DEFINE		v_numerointcalle			CHAR(10);
	DEFINE 		v_nombre_cte 				CHAR(45);
	DEFINE 		v_domicilio 				CHAR(50);
------------------------------------------------------------------------
--  Inicializando variables de manejo de errores
------------------------------------------------------------------------
    --SET DEBUG FILE TO "/informix/ifg/sp_traspinfosort.out";
    --TRACE ON;
	LET			v_codigo_retorno = '00000';
	LET 		v_mensaje = 'Proceso Inicia Correctamente';
	LET 		v_reverso = '0';
	LET 		v_store_pro = 'sp_traspinfosort';
	LET 		vcontador_fin     = 0;
	LET 		vvalida  = (pfecha - 1 units day);
	--LET 		vfsorteo = (vvalida - 1 units day);
	LET 		vcontador_ini = 0;
	LET 		vsqlerr = 0;

	BEGIN
		ON EXCEPTION SET vsqlerr          
			IF vsqlerr <> 0 THEN         
				LET v_codigo_retorno = "00045";
				LET v_mensaje = "Se Genero Error de Exceptio, Verifique Datos SQL!";
				LET v_reverso = '1';         
				LET v_store_pro = 'sp_traspinfosort';
				RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
	
		IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = pdcve_sorteo AND flag_sort = 2) THEN
					
					SELECT {+INDEX(si_param ix_si_param)} valor
					INTO v_valor
					FROM bdinteg:si_param
					WHERE empresa = '001'
					AND cod_param = 118;
					
					SELECT {+INDEX (si_sorteo idx_si_sorteo2)} cve_sorteo, f_ini, f_fin
					INTO v_cve_sorteo, vf_ini, vf_fin
					FROM bdinteg:si_sorteo
					WHERE cve_sorteo = v_valor;
					
					IF (v_valor IS NULL OR v_valor = '') OR -- Valida clave sorteo vigente
					   (v_valor <> pdcve_sorteo) THEN
							LET v_codigo_retorno = '00040';
							LET v_mensaje = 'NO EXISTE SORTEO';
							LET v_reverso = '1'; 
							RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;    -- Termina proceso del SP
					ELSE
						IF (vF_ini IS NULL OR vF_ini = '') OR      -- Valida fecha sorteo vigente
						   (vF_Fin IS NULL OR vF_Fin = '') OR
						   (pfecha NOT BETWEEN vF_ini AND vF_Fin) THEN
								LET v_codigo_retorno = '00042';
								LET v_mensaje = 'SORTEO NAVIDEÑO NO ESTA VIGENTE';
								RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;    -- Termina proceso del SP
						END IF;
					END IF;
					

					TRUNCATE TABLE si_boleto_dir;
					
					FOREACH cursor_inserta WITH HOLD FOR
							SELECT {+index (si_boleto idx_si_bol_clte)} numcte, foliosuc
									INTO v_numcte, v_foliosuc
									FROM bdinteg:si_boleto 
									WHERE fecha = vvalida 
									AND numcte > '0000000'
									
									BEGIN WORK;
									/*SE BUSCA LA INFORMACIÓN DEL CLIENTE*/
										SELECT {+index (si_boleto idx_si_bol_clte)} boleto_ini, boleto_fin, f_registro, estado, sucursal, area, caja, tipomov, importe, fecha, origen, secuencia   --FMV 8-NOV-10: SE ADICIONA INDICE               
										INTO v_boleto_ini, v_boleto_fin, v_f_registro, v_status, v_sucursal, v_area, v_caja, v_tipomov, v_importe, v_fecha, v_origen, v_secuencia  
										 FROM bdinteg:si_boleto 
										  WHERE numcte = v_numcte 
										  AND foliosuc = v_foliosuc;
										SELECT {+INDEX (si_direcciones_actual idx_diract_ctetpo)} numerocalle, numerociudad, numerocolonia, estado, numeroextcalle, numerointcalle
										INTO v_numerocalle, v_numerociudad, v_numerocolonia, v_estado, v_numeroextcalle, v_numerointcalle
										 FROM si_direcciones_actual
										  WHERE numcte = v_numcte AND tipo_dir = 1;
										SELECT {+INDEX (si_telefonos_actual idx_telact_cte)}
											CASE										/*SE AGREGA CASE PARA PONER EN 0*/
												WHEN telefono  = '' THEN  '0' 
												WHEN telefono  IS NULL THEN '0' 
												WHEN telefono = telefono THEN telefono
											END
										INTO v_telefono1
										 FROM si_telefonos_actual
										  WHERE numcte = v_numcte
											AND tipo_tel = 1
											AND status_tel = 'A';
										SELECT {+INDEX (si_telefonos_actual idx_telact_cte)}
											CASE										/*SE AGREGA CASE PARA PONER EN 0*/
													WHEN telefono  = '' THEN  '0' 
													WHEN telefono  IS NULL THEN '0' 
													WHEN telefono = telefono THEN telefono
											END
										INTO v_telefono2
										 FROM si_telefonos_actual
										  WHERE numcte = v_numcte
											AND tipo_tel = 2
											AND status_tel = 'A';
										SELECT {+INDEX (si_catcalles idx_catcalles)} nombrecalle
										INTO v_nomcalle
										 FROM si_catcalles
										  WHERE numerocalle = v_numerocalle;
										SELECT {+INDEX (si_catzonas idx_catzonass)} nombrezona 
										INTO v_nomcolonia
										 FROM si_catzonas
										  WHERE numerociudad = v_numerociudad
											AND numerocolonia = v_numerocolonia;
										SELECT {+INDEX (si_catciudades inx_ciudades)} nombreciudad
										INTO v_nomciudad
										 FROM si_catciudades
										 WHERE numerociudad = v_numerociudad;
										SELECT {+INDEX (si_estados inx_estado)}nombre
										INTO v_nomestado
										 FROM si_estados
										  WHERE estado = v_estado;
										/*SE ARMA EL NOMBRE DEL CLIENTE*/ 
										LET v_nombre_cte = (SELECT trim(nombre1)||' '||   
												trim(nombre2)||' '||    
												trim(apell_paterno)||' '|| 
												trim(apell_materno)                                            
												FROM bdinteg:si_cliente WHERE numcte = v_numcte);
										 
										/*SE ARMA DOMICIOLO DEL CLIENTE*/
										LET v_domicilio =  trim(v_nomcalle)||' '||
												trim(v_numeroextcalle)||' '||  
												trim(v_numerointcalle)||' '||  												
												trim(v_nomcolonia);
										/*INSERTA LOS REGISTROS*/
										INSERT INTO "informix".si_boleto_dir(cve_sorteo, boleto_ini, boleto_fin, f_registro, numcte, estado, sucursal, area, caja, tipomov, foliosuc, importe, telefono1, telefono2, nombre, ciudad, domicilio, fecha, origen, secuencia, ent_fed)
										VALUES(v_cve_sorteo, v_boleto_ini, v_boleto_fin, v_f_registro, v_numcte, v_status, v_sucursal, v_area, v_caja, v_tipomov, v_foliosuc, v_importe, v_telefono1, v_telefono2, v_nombre_cte, v_nomciudad, v_domicilio, v_fecha, v_origen, v_secuencia, v_nomestado);
									COMMIT WORK;
					END FOREACH;
				EXECUTE PROCEDURE sp_traslada_boletos_test(pdcve_sorteo, pfecha)
				INTO  v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
		ELSE
					LET v_codigo_retorno = "22222";
					LET v_mensaje = "¡EL SORTEO NAVIDEÑO NO ESTA ACTIVO!";
					LET v_reverso = '1';
					LET v_store_pro = v_store_pro;     
		END IF;	


	END;   --begin        
    
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
    
END PROCEDURE
DOCUMENT
'CREADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE CREACIÓN: 20 FEBRERO DE 2016',
'OBJETIVO: SE MODIFICA LA BUSQUEDA DE LAS DIRECCIONES',
'          DE LOS CLIENTES Y EN VEZ DE ACTUALIZAR LA TABLA si_sorteo',
'          SE HACE UN RESPALDO EN LA TABLA NUEVA si_sorteo_dir',
'          POR MEDIO DE UN CURSOR Y EL CURSOR DE INSERCION PARA',
'          LA TABLA  si_sorteo_hist SE EJECUTA EL EL SP ',
'          sp_translada_boletos',
'BD: BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZÁLEZ',
'FECHA DE MODIFICACIÓN: 11 NOVIEMBRE DE 2016',
'OBJETIVO: SE AGREGA LA VALIDACION DE PONER EN 0 LOS NUMEROS',
'          TELEFONICOS NULOS Y BLANCOS',
'          Y SE MANDA A EJECUTAR EL SP sp_traslada_boletos ',
'BD: BDINTEG';

CREATE PROCEDURE "informix".ctemoraldatoslegales( 
												 eEmpresa      	CHAR(3),
												 eNumCte       	CHAR(20),
												 eEscConstitu  	CHAR(30),
												 eNombNotario  	CHAR(30),
												 eNumNotaria   	CHAR(5),
												 eCdNotaria    	CHAR(30),
												 eFecInscrip   	DATE,
												 eFecConstitu  	DATE,
												 eNumFolMerca  	CHAR(30),
												 eCdFolMerca   	CHAR(30),
												 eEscriPoder   	CHAR(30),
												 eNombNotpd    	CHAR(30),
												 eNumNotariopd 	CHAR(30),
												 eCdNotariopd  	CHAR(30),
												 eFecInscripd  	DATE,
												 eFecEscritupd 	DATE,
												 eFolMercapd   	CHAR(30),
												 eCdFolMercaPd 	CHAR(30),
												 eNomSociedad  	CHAR(30),
												 eEmail        	CHAR(100),
												 eSat_fea      	CHAR(25),
												 pDoc_legal	   	CHAR(100),
												 pTpo_Poder	   	CHAR(3),
												 pTpo_Admin		CHAR(3),
												 pTpo_Org		CHAR(3))

	RETURNING CHAR(5);
	--DECLARACION DE VARIABLES.
	DEFINE vcod_ret CHAR(5);
	DEFINE vsqlerr	INTEGER;

	--INICIALIZACION DE VARIABLES.
	LET vcod_ret 	='00000';
	LET vsqlerr  	= 0;

	BEGIN
		--Control de errores de informix.
		ON EXCEPTION SET vsqlerr
		  IF vsqlerr != 0 THEN
			 LET vcod_ret=vsqlerr;
			RETURN vcod_ret;
		  END IF;
		END EXCEPTION;		
		
		--Valida si viene con transaccion abierta, la cierra y continua.
		ON EXCEPTION SET vsqlerr
		  IF vsqlerr = -535 THEN
			COMMIT WORK;
		  END IF;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO "/tmp/ctemoral.out";
		--TRACE ON;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		BEGIN WORK;
			UPDATE "informix".si_ctepm SET escritura_constitutiva  = eEscConstitu ,
										   nombre_notarioct        = eNombNotario ,
										   numero_notarioct        = eNumNotaria  ,
										   ciudad_notarioct        = eCdNotaria   ,
										   fecha_inscrip           = eFecInscrip  ,
										   fecha_constitct         = eFecConstitu ,
										   numero_foliomercantilct = eNumFolMerca ,
										   ciudad_foliomercantilct = eCdFolMerca  ,
										   escritura_poderes       = eEscriPoder  ,
										   nombre_notariopd        = eNombNotpd   ,
										   numero_notariopd        = eNumNotariopd,
										   ciudad_notariopd        = eCdNotariopd ,
										   fecha_inscrippd         = eFecInscripd ,
										   fecha_escritpd          = eFecEscritupd,
										   numero_foliomercantilpd = eFolMercapd  ,
										   ciudad_foliomercantilpd = eCdFolMercaPd,
										   nombre_sociedad         = eNomSociedad,
										   emailpm                 = eEmail,
										   sat_fea                 = eSat_fea,
										   doc_constitucion	       = pDoc_legal,
										   tipo_poder			   = pTpo_Poder,
										   tipo_admon			   = pTpo_Admin,
										   tipo_org			       = pTpo_Org
			WHERE empresa = eEmpresa
			AND numcte = eNumCte;
			
			IF DBINFO('SQLCA.SQLERRD2') = 0 THEN
				LET vcod_ret = '00001';
			END IF;
			
		COMMIT WORK;
		RETURN vcod_ret;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se actualiza para que reciba 4 nuevos parametros: 1.-pTipoPoder CHAR(3), 2.-pTipoAdmon CHAR(3), 3.-pTipoOrg CHAR(3) y', 
'4.-pDocConstitucion CHAR(100),para actualizarlos en la tabla "bdinteg:si_ctepm", para esto al update se le tienen que',
'agregar los nuevos campos "tipo_poder","tipo_admon","tipo_org" y "doc_constitucion", que son los datos que caracteriza',
'a la persona moral de gobierno.',
'AUTOR: Josue Remberto Zazueta Acosta',
'FECHA: 25 de julio de 2013',
'AUTOR: M.D.S.Sandra Cano',
'FECHA: 03/10/2016',
'DESCRIPCION: Se actualiza para cambiar firma del SPL, se amplia campo email a CHAR de 100',
'ID REQUERIMIENTO TASF: CON-01-02-03-B-0448',
'BASE DE DATOS: bdinteg';

CREATE PROCEDURE "informix".sp_validatarjetacurp(cEmpresa CHAR(3),cTarjeta CHAR(20),cFechaExpTarj CHAR(4))	
			
RETURNING 
CHAR(7),
CHAR(5),
CHAR (20),
CHAR (20);
					
-- DEFINICION DE VARIABLES
define cCodret2      CHAR(7);
define cCodisam      CHAR(5);
define iIsamErr      INTEGER;
define cAux1      CHAR(10);


DEFINE cNumCredito   CHAR(20);
DEFINE cNumTarjeta   CHAR(20);
DEFINE cNumCte       CHAR(20);
DEFINE cNomProducto  CHAR(60);
DEFINE cProductoTarj CHAR(4);
DEFINE cCurp         CHAR(20);
DEFINE cFecha_Hoy 	 CHAR(10);
DEFINE cFecha_Exp    CHAR(10);
DEFINE cAnioActual   CHAR(2);
DEFINE cMesActual    CHAR(2);
DEFINE cMesExp       CHAR(2);
DEFINE cAnioExp      CHAR(4);
DEFINE cAnioTarj     CHAR(2);
DEFINE cMesTarj      CHAR(2);
DEFINE iFlagFecha    INTEGER;
DEFINE cProducto     CHAR(4);
DEFINE cBin          CHAR(6);
DEFINE cValidaBin    CHAR(6);
DEFINE cStatusCta    CHAR(1);
DEFINE iUnidadProd   INTEGER;
DEFINE iSqlErr 		 INTEGER;
DEFINE cPalabra      VARCHAR(100,1);
DEFINE cLetra        CHAR(1);
DEFINE iLongitud     INTEGER;
DEFINE iflag         INTEGER;
DEFINE cSucursal 	 CHAR(4);
DEFINE cOperador 	 CHAR(8);
DEFINE cHora_tran 	 CHAR(6);
DEFINE cFecha_insert CHAR(2); 
DEFINE cFolioSuc 	 CHAR(16);
DEFINE cCodigoFun	 CHAR(3);
DEFINE iCodigoRef	 INTEGER;
DEFINE cSucursalCta  CHAR(4);
DEFINE mSdoActual	 MONEY(14,2);
DEFINE cTransac		 CHAR(4);
DEFINE cMenGenmov	 CHAR(80);
--DEFINE dFechaInsert	 DATETIME;
DEFINE cCredito   CHAR(20);
DEFINE dtFechaOperacion DATE;
		

--INICIALIZACION DE VARIABLES
LET cCodret2 = '0000000';
LET cAux1 = '0000000000';
LET cCodisam = '00000';
LET cNumCredito = '';
LET cCredito = '';
LET cNumTarjeta = '';
LET cNumCte = '';
LET cNomProducto = '';
LET cProductoTarj = '';
LET cCurp = '';
LET cFecha_Hoy = '';
LET cFecha_Exp = '';
LET cAnioActual = '';
LET cMesActual = '';
LET cMesExp = '';
LET cAnioExp = '';
LET cAnioTarj = '';
LET cMesTarj = '';
LET iFlagFecha = 0;
LET cProducto = '';
LET cBin = '';
LET cValidaBin = '';
LET cStatusCta = '';
LET iUnidadProd = 0;
LET iSqlErr = 0;
LET cPalabra   = '';
LET cLetra     = '';
LET iLongitud  = 0;
LET cSucursal 		= ''; 
LET cOperador 		= ''; 
LET cHora_tran 		= ''; 
LET cFecha_insert 	= ''; 
LET cFolioSuc 		= ''; 
LET cCodigoFun 		= '';
LET iCodigoRef 		= 0;
LET cSucursalCta 	= '';
LET mSdoActual 		= 0.00;
LET cTransac		= '';
LET cMenGenmov		= '';
LET dtFechaOperacion = TODAY;

--SET DEBUG FILE TO '/home/sysifx/Nancy/sp_validatarjetacurp.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION
			SET iSqlErr,iIsamErr
			IF iSqlErr <> 0 THEN
				LET cCodret2 = iSqlErr;
				LET cCodisam = iIsamErr;
				RETURN cCodret2, cCodisam, cNumCte, cNumTarjeta;
			END IF;
		END EXCEPTION;

	IF TRIM(cTarjeta) = '' THEN
		LET cCodret2 = 'MPE0583'; --Informar el No. de Tarjeta	
	ELIF TRIM (cEmpresa) = '' OR cFechaExpTarj = ''  THEN
		LET cCodret2 = 'MCE0005'; --El campo @@ es obligatorio para opcion @ 
    ELIF cTarjeta IS NULL OR cEmpresa IS NULL OR cFechaExpTarj IS NULL THEN
		LET cCodret2 = 'MCE0002'; --Opción inválida/parámetros de entrada nulos
	ELIF TRIM(cTarjeta) = ''  OR TRIM (cEmpresa) = '' OR cFechaExpTarj = '' THEN
		LET cCodret2 = 'MCE0196'; --Tipo de petición errónea/parámetros de entrada vacíos
	ELIF cTarjeta <> '' OR cTarjeta IS NOT NULL OR cFechaExpTarj <> '' OR cFechaExpTarj IS NOT NULL THEN
		
        IF NOT(val_num(cTarjeta) OR val_num(cFechaExpTarj)) THEN
            LET cCodret2 = 'MCE0024'; --Campo informado erróneamente
            RETURN cCodret2, cCodIsam, cNumCte, cNumTarjeta;
        END IF;
/*
		LET iLongitud = 1;		
		LET iflag = 1;
		LET cPalabra = TRIM(cTarjeta);
		WHILE iflag <= 2 
			WHILE iLongitud <= LENGTH(cPalabra) + 1
				LET cLetra = SUBSTR(cPalabra,iLongitud,1);
				IF cLetra <> '' THEN
					IF NOT (cLETRA BETWEEN '0' AND '9') THEN					
						LET cCodret2 = 'MCE0024'; --Campo informado erróneamente
						LET iflag = 3;
					END IF;
				END IF;
				LET iLongitud = iLongitud + 1;
			END WHILE;
		LET cPalabra = TRIM(cFechaExpTarj);
		LET iflag = iflag + 1;
		LET iLongitud  = 1;
		END WHILE;
*/
--		IF iflag <= 3 THEN
		
			SELECT fecha_hoy, substr(year(fecha_hoy),3,2), lpad(month(fecha_hoy),2,'0')
			INTO cFecha_Hoy, cAnioActual, cMesActual
			FROM bdinteg:"informix".si_fechas;
			
			SELECT SUBSTR(fechaexp,1,2), SUBSTR(fechaexp,3,2)
			INTO cAnioExp, cMesExp 
			FROM intercard:"informix".tarjeta 
			WHERE numtarjeta = cTarjeta;		
		
--			LET cAnioActual = SUBSTR(cFecha_Hoy,9,2);
--			LET cMesActual = SUBSTR(cfecha_hoy,1,2);			
--			LET cAnioExp = SUBSTR(cFecha_Exp,1,2);
--			LET cMesExp = SUBSTR(cFecha_Exp,3,2);
			LET cBin = SUBSTR(cTarjeta,1,6);
			LET cAnioTarj = SUBSTR(cFechaExpTarj,1,2);
			LET cMesTarj = SUBSTR(cFechaExpTarj,3,2);
			
			
			IF cAnioActual < cAnioTarj THEN
				LET iFlagFecha = 1;
			ELIF cAnioActual = cAnioTarj THEN
				IF cMesActual <= cMesTarj THEN
					LET iFlagFecha = 1;
				ELSE
					LET iFlagFecha = 0;
				END IF
			ELSE
				LET iFlagFecha = 0;
			END IF
				
			IF cMesTarj > '00' OR cMesTarj < '12' OR cMesTarj = '12' OR cAnioTarj > '00' THEN 		
				IF cAnioTarj = cAnioExp AND cMesTarj = cMesExp THEN	--Valida fecha de caducidad recibido con fecha de caducidad de tabla de tarjeta			
					IF iFlagFecha = 1  THEN --Valida fecha de caducidad recibido con registro de si_fechas
						SELECT creditodebito INTO cValidaBin FROM bdicheq:"informix".sc_bines WHERE bin = cBin;
						IF TRIM(cValidaBin) <> '' AND cValidaBin IS NOT NULL THEN 
							
							--DSB 14/07/2011
							SELECT sucursal,num_usuario,hora_transac,fecha_insert::datetime second to second::char(2)
							INTO  cSucursal, cOperador, cHora_tran, cFecha_insert
							FROM  bdinteg:"informix".si_folioafore
							WHERE num_tarjeta = cTarjeta
							AND fecha_insert = (SELECT MAX(fecha_insert) 
							FROM   bdinteg:"informix".si_folioafore
							WHERE num_tarjeta = cTarjeta);	
							
							--Se valida si el usuario es de bancoppel sino se le agrega el usuario informix
							IF TRIM(cOperador) = '' OR cOperador IS NULL THEN
								LET cOperador = 'informix';
							END IF

							IF TRIM(cHora_tran) = '' OR cHora_tran IS NULL THEN
								LET cHora_tran = current::datetime hour to hour::char(2) || current::datetime minute to minute::char(2) || current::datetime second to second::char(2);
							END IF							

							IF TRIM(cFecha_insert) = '' OR cFecha_insert IS NULL THEN
								LET cFecha_insert = current::datetime second to second::char(2);
							END IF
							
							
							--Se arma el FolioSuc
							LET  cFolioSuc =  TRIM(cOperador) || TRIM(cHora_tran) || cFecha_insert;							
							
							IF cValidaBin = 'c' THEN 
							
								SELECT num_tarjeta, num_credito, prodtarjeta, numcte
								INTO cNumTarjeta, cNumCredito,cProducto,cNumCte
								FROM bdicred:"informix".sd_tarjeta
--								WHERE empresa   = cEmpresa
								WHERE  num_tarjeta = cTarjeta
--								AND num_credito > 0
								AND status_tar = 'A'
								AND tipo_tarjeta = 'T';
											
								IF cNumTarjeta <> ""  OR cNumTarjeta IS NOT NULL THEN				
									SELECT id_unidad_prod,num_credito INTO iUnidadProd,cCredito FROM bdicred:"informix".sd_maecred WHERE num_credito = cNumCredito;							
									IF iUnidadProd IS NULL AND cCredito <> '' AND cCredito IS NOT NULL  THEN -- checa que no tenga el credito bloqueado			
											LET cCodret2 = 'MCA0010';
											--INSERT INTO bdicred:"informix".sd_movdia (empresa, fecha_mov, hora_mov, sucursal, 
											--							   num_credito,plaza, transacc_suc, usuario, monto, 
											--							   codigo_fun, codigo_ref, divisa, reversado, folio_suc, 
											--							   num_producto, nro_tarjeta, referencia, tipo_cambio, 
											--							   monto_dls, suc_origen, rfc_comer, referencia23)
											--VALUES(cEmpresa,cFecha_Hoy, current,'',
											--									cNumCredito,'000','0000',user,0.00, 
											--									'033',1,'01','N','inform01',cProducto,
											--									cNumTarjeta,'Consulta FOLIO AFORE','','','',
											--									'','');
																				
											-- Falta armar folio_suc y mandar los valores correctos al sp genmov
											--DSB 14/07/2011
											SELECT codigo_fun, codigo_ref
											INTO CCodigoFun, iCodigoRef
											FROM bdicred:"informix".sd_transfun
											WHERE transacc = '7272';
																						
											EXECUTE PROCEDURE bdicred:"informix".genmov(cEmpresa, cNumCredito,cProducto,iCodigoRef,CCodigoFun,
																		        cFecha_Hoy,0.00,cFolioSuc,cSucursal,'01','0000' )
											INTO cAux1, cMenGenmov;
											
											IF LPAD (TRIM(cAux1),10,'0') <> '0000000000' THEN
												LET cCodret2 = cAux1; --SUBSTR(LPAD (TRIM(cAux1),10,'0'),4);
											END IF;
											
									ELSE
										LET cCodret2 = 'MPE547';
									END IF;
								ELSE
									LET cCodret2 = 'MPE0591'; --No existe número de tarjeta
								END IF;
							ELSE
								
								SELECT num_tarjeta, cuenta,prodtarjeta,numcte
								INTO cNumTarjeta,cNumCredito,cProducto,cNumCte
								FROM bdicheq:"informix".sc_tarjeta 
								WHERE empresa= cEmpresa
								AND num_tarjeta = cTarjeta
								AND tipo_tarjeta = 'T';
														
								IF cNumTarjeta <> ""  OR cNumTarjeta IS NOT NULL THEN	
									SELECT  status_cta, Sucursal, sdo_actual INTO  cStatusCta, cSucursalCta, mSdoActual 
									FROM bdicheq:"informix".sc_maechq 
									WHERE empresa = cEmpresa and cuenta = cNumCredito;

									IF cStatusCta = 1 THEN
											LET cCodret2 = 'MCA0010';
											SELECT valor INTO cTransac FROM bdinteg:"informix".si_param WHERE cod_param = '134';
											INSERT INTO bdicheq:"informix".sc_movdia (num_serial,folio_suc,sucursal,usuario,fech_alt,
																		  fech_val,fech_hor,transacc,suc_cuen,producto,
																		  empresa,cuenta,causa_dev,num_cheq,monto_tot,
																		  firme,en_sbc,remesas,dias_ret,cancelad,
																		  edo_cta,sdo_cuenta,transacc_suc,referencia,
																		  tasa_aplicada,num_tarjeta,usuautoriza,referencia_23,fech_oper)
											                       VALUES(0,cFolioSuc,cSucursal,cOperador,current,current,
																		  current,cTransac,cSucursalCta,cProducto,cEmpresa,cNumCredito,'',0,
																		  0.00,0.00,0.00,0.00,0,'','',mSdoActual,'0000',
																		  'Consulta FOLIO AFORE', 0.000000,cNumTarjeta,'',"",dtFechaOperacion);
																		
									ELSE
										LET cCodret2 = 'MPE0547'; --No existe cuenta vinculada
									END IF;
								ELSE
									LET cCodret2 = 'MPE0591'; --No existe número de tarjeta
								END IF;	
							END IF; 
						END IF;
					ELSE
						LET cCodret2 = 'MCE0191'; --Error fecha caducidad
					END IF;
				ELSE
					LET cCodret2 = 'MPE0320'; --La fecha de caducidad no coincide con la de la tarjeta
				END IF;
			ELSE
				LET cCodret2 = 'MPE5546'; --Error en fecha de caducidad(MMAA)
			END IF;
--		END IF;
	END IF;					

	RETURN cCodret2, cCodIsam, cNumCte, cNumTarjeta;

	END
	END PROCEDURE;