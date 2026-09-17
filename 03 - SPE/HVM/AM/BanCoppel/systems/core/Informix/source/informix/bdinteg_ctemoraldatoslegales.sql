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