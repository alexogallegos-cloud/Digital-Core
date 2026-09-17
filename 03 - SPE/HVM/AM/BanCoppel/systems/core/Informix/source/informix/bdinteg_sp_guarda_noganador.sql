CREATE PROCEDURE "informix".sp_guarda_noganador(pNumCte CHAR(9), pOperador CHAR(8), pSucursal CHAR(4), pHora CHAR(5))			 
RETURNING 
	CHAR(5) AS codRet

	-- *                        DEFINICION DE VARIABLES                           *
	DEFINE cCodRet 						CHAR(5);

	-- VARIABLES ERROR
	DEFINE iSqlErr                      INTEGER;
    DEFINE iIsamErr                     INTEGER;
	
	DEFINE nombrecte 			CHAR(50);
	DEFINE nombresuc 			CHAR(50);
	
	-- *                        ASIGNACION DE VARIABLES                           *
	LET cCodRet = '00000';
	
	LET iSqlErr    = 0;
	LET iIsamErr   = 0;
	
	LET nombrecte 		='';
	LET nombresuc 		='';
	--
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;				
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/sp_guarda_noganador.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		/*IF NVL(pNumCte,'') = '' OR TRIM(NVL(pOperador,'')) = '' OR TRIM(NVL(pSucursal,'')) = '' THEN
			LET cCodRet = '00001';
			RETURN cCodRet;
		END IF;*/
				
			SELECT  SUBSTR(TRIM(nombre1) ||' '|| TRIM(nombre2)||' '|| TRIM(apell_paterno)||' '||TRIM(apell_materno),1,50)
			INTO nombrecte 
			FROM bdinteg:"informix".si_cliente WHERE numcte = pNumcte;
			
			SELECT {+INDEX (bdinteg:"informix".si_sucursales idx_sucursal)} SUBSTR(TRIM(nombre),1,50) INTO nombresuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = pSucursal;
			
			INSERT INTO bdinteg:si_noganadores(numcte, nombre_cte, usuario, sucursal, nombre_suc, fecha, hora)
			VALUES (pNumcte, nombrecte, pOperador, pSucursal, nombresuc, today, pHora);
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'Codigo de retorno 00001 indica que se han enviado parametros de entrada invalidos', 
'FECHA : 15/Abril/2022',
'BD    : BDINTEG',
'SOLICITO: Abraham Narvaez';

CREATE PROCEDURE "informix".sp_ws_valida_cotel (pUserName CHAR(8), pUserPass CHAR(8),pIdSession CHAR(30), pIpOrigen CHAR(16), pAgentTransTypeCode CHAR(10), pAgentCd CHAR(3), pCorreo CHAR(100), pTelefono CHAR(10), pNombre1 CHAR(26), pNombre2 CHAR(26), pApellido1 CHAR(26), pApellido2 CHAR(26), pFechaNacimiento CHAR(8))


	RETURNING 	CHAR(4)  AS cCodRet , 					-- Indica el cÃÂÃÂÃÂÃÂ³digo de retorno del procedimiento
				CHAR(120) AS cDescrMensaje,				-- DescripciÃÂÃÂÃÂÃÂ³n de la respuesta obtenida	
				CHAR(4)   AS cCodRetCorreo, 			-- CÃÂÃÂÃÂÃÂ³digo de retorno de validaciÃÂÃÂÃÂÃÂ³n de correo
			    CHAR(120) AS cDescrMensajeCorreo,		-- DescripciÃÂÃÂÃÂÃÂ³n de la respuesta obtenida en validaciÃÂÃÂÃÂÃÂ³n de correo
				CHAR(4)	  AS cCodRetTelefono,			-- CÃÂÃÂÃÂÃÂ³digo de retorno de validaciÃÂÃÂÃÂÃÂ³n de telÃÂÃÂÃÂÃÂ©fono
				CHAR(13)  AS cRFC,						-- RFC calculado para el cliente
				CHAR(120) AS cDescrMensajeTelefono,		-- DescripciÃÂÃÂÃÂÃÂ³n de la respuesta obtenida en la validaciÃÂÃÂÃÂÃÂ³n de TelÃÂÃÂÃÂÃÂ©fono	
				CHAR(20)  AS cNumCte;					-- NÃÂÃÂÃÂÃÂºmero de cliente asignado.

				
	DEFINE cCodRet	 				CHAR (4);
	DEFINE cDescrMensaje 			CHAR (120);
	DEFINE cCodRetCorreo 			CHAR (4);
	DEFINE cDescrMensajeCorreo 		CHAR (120);
	DEFINE cCodRetTelefono	 		CHAR (4);
	DEFINE cRFC				 		CHAR (13);
	DEFINE cDescrMensajeTelefono	CHAR (120);
	DEFINE cNumCte					CHAR (20);
	DEFINE iExiste					INTEGER;
	DEFINE cNombre1 				CHAR(26);
	DEFINE cNombre2 				CHAR(26);
	DEFINE cApellido1 				CHAR(26);
	DEFINE cApellido2 				CHAR(26);
	
	
	
	DEFINE iSqlErr			INTEGER;
	DEFINE cNombreCompleto 	CHAR(60);
	DEFINE cCodRetRfc	 	CHAR(5);
	DEFINE cSucursal 		CHAR(4);
	DEFINE cEjecutivo 		CHAR(8) ;
	
	
		
	LET cCodRet  				= '0000';
	LET cDescrMensaje  			= '';
	LET cCodRetCorreo  			= '';
	LET cDescrMensajeCorreo  	= '';
	LET cCodRetTelefono		  	= '';
	LET cRFC				  	= '';
	LET cDescrMensajeTelefono  	= '';
	LET cNombreCompleto			='';
	LET cCodRetRfc				='00000';
	LET cNumCte					='';
	LET iExiste					=0;
	LET cSucursal				='';
	LET cEjecutivo				='';
	LET cNombre1 				='';
	LET cNombre2 				='';
	LET cApellido1 				='';
	LET cApellido2 				='';
	
	
	LET iSqlErr     = 0;

	--SET DEBUG FILE TO '/informix/LIP/logs/sp_ws_valida_cotel.out';
	--TRACE ON;		
	
BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cDescrMensaje = 'Error en base de datos.';
				
				RETURN cCodRet ,cDescrMensaje, cCodRetCorreo, cDescrMensajeCorreo, cCodRetTelefono, cRFC,  cDescrMensajeTelefono , cNumCte;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		
		IF TRIM(NVL(pUserName,'')) <> '' AND TRIM(NVL(pUserPass,'')) <> '' AND TRIM(NVL(pIdSession,'')) <> ''  AND  TRIM(NVL(pIpOrigen,'')) <> '' AND  TRIM(NVL(pAgentTransTypeCode,'')) <> ''  AND TRIM(NVL(pAgentCd,'')) <> ''  AND TRIM(NVL(pCorreo,'')) <> '' AND TRIM(NVL(pTelefono,'')) <> ''  AND TRIM(NVL(pNombre1,'')) <> ''   AND TRIM(NVL(pApellido1,'')) <> ''  AND TRIM(NVL(pFechaNacimiento,'')) <> '' THEN
		
			--VALIDAR EL IDSESSION
			EXECUTE PROCEDURE  bdisac:"informix".sp_valida_session(TRIM(pAgentTransTypeCode), TRIM(pAgentCd), TRIM(pUserName), TRIM(pUserPass), TRIM(pIpOrigen), TRIM(pIdSession) ) INTO cCodRet, cDescrMensaje ;
		
			IF TRIM(cCodRet) ='0000' THEN
				
				--  CALCULAR RFC
				
					LET cNombreCompleto= CASE WHEN TRIM(pNombre2) <> "" THEN TRIM(pNombre1) || " " ||  TRIM(pNombre2) ELSE TRIM(pNombre1) END ;
					EXECUTE PROCEDURE  bdinteg:"informix".sp_calcularrfc(TRIM(pApellido1), TRIM(pApellido2), TRIM(cNombreCompleto), pFechaNacimiento ) INTO cCodRetRfc, cRFC ;
					
					LET cCodRet= SUBSTR(TRIM(cCodRetRfc), 2,4);
				
					IF TRIM(cCodRetRfc) ='00000' THEN							

							--VALIDAR CORREO ELECTRONICO
							EXECUTE PROCEDURE  bdinteg:"informix".sp_valida_correo_so(TRIM(cRFC), TRIM(pCorreo)) INTO cCodRetCorreo ;
						
							--VALIDAR TELEFONO
							EXECUTE PROCEDURE  bdinteg:"informix".sp_valida_telefono_so(TRIM(cRFC), TRIM(pTelefono), 2) INTO cCodRetTelefono ;
							
							IF TRIM(NVL(cCodRetCorreo,'')) IN ('0000', '0002' ) AND  TRIM(NVL(cCodRetTelefono,'')) IN('0000', '0003', '0004','0005','1166', '1169') THEN
								
								SELECT numcte INTO cNumCte FROM bdinteg:"informix".si_cliente WHERE rfc = TRIM(cRFC);
								
								IF TRIM(NVL(cNumCte,'')) = '' THEN
									
									--CONSULTAR SUCURSAL
									SELECT valor INTO cSucursal FROM si_param WHERE cod_param = 480;
									
									--CONSULTAR EJECUTIVO
									SELECT valor INTO cEjecutivo FROM si_param where cod_param = 481;
									
									--EJECUTAR SP
									EXECUTE PROCEDURE bdinteg:ctefisico ('001','A', '', TRIM(cSucursal), TRIM(cEjecutivo), '01', '2', TRIM(pApellido1), TRIM(pApellido2),  TRIM(pNombre1), TRIM(pNombre2), TRIM(cRFC), '32', '000', '', '000', '000', '1', '', '','01' ,'', '', '0000000',  TRIM(pFechaNacimiento), '', '001', '', '', '', '', '', '', '', '', '', '0', '', TRIM(pCorreo), '', '' , '', '', '0', '', '0', '','','', TRIM(cEjecutivo), '','', 'MX'   )  INTO  cCodRet, cNumCte;
									
									IF (cCodRet = '118') THEN
										WHILE (cCodRet = '118') LOOP
											EXECUTE PROCEDURE bdinteg:ctefisico ('001','A', '', TRIM(cSucursal), TRIM(cEjecutivo), '01', '2', TRIM(pApellido1), TRIM(pApellido2),  TRIM(pNombre1), TRIM(pNombre2), TRIM(cRFC), '32', '000', '', '000', '000', '1', '', '','01' ,'', '', '0000000',  TRIM(pFechaNacimiento), '', '001', '', '', '', '', '', '', '', '', '', '0', '', TRIM(pCorreo), '', '' , '', '', '0', '', '0', '','','', TRIM(cEjecutivo), '','', 'MX'   )  INTO  cCodRet, cNumCte;
											IF cCodRet != '118' THEN EXIT;
											ELSE
												CONTINUE;
											END IF
										END LOOP;
									END IF;
								
									IF CAST(cCodRet AS INTEGER)  = 0 THEN
										
										LET cCodRet='0000';
									
									ELSE
										
										LET cCodRetTelefono = cCodRet;
										LET cCodRet='9989';
										
									END IF;
								ELSE
								
									SELECT nombre1,nombre2,apell_paterno,apell_materno
									INTO cNombre1, cNombre2, cApellido1, cApellido2
									FROM bdinteg:si_cliente where numcte = cNumCte;
									
									
									IF (TRIM(cNombre1) = TRIM(pNombre1) AND TRIM(cNombre2) = TRIM(pNombre2)
										AND TRIM(cApellido1) = TRIM(pApellido1) AND TRIM(cApellido2) = TRIM(pApellido2)) THEN
											
											LET cCodRet=cCodRet;
									ELSE
											LET cCodRet = '1001';
									END IF;
									
								
								END IF;
								
							END IF;
							
							SELECT opcode_ds INTO cDescrMensajeCorreo FROM  bdinteg:"informix".si_so_catmensajes WHERE opcode= cCodRetCorreo;
							SELECT opcode_ds INTO cDescrMensajeTelefono FROM  bdinteg:"informix".si_so_catmensajes WHERE opcode= cCodRetTelefono;
						
					END IF;
					
			END IF;  
		 ELSE

			LET cCodRet= "9996";
			
		END IF;
		
		--CONSULTA DE MENSAJES
		SELECT opcode_ds INTO cDescrMensaje FROM  bdinteg:"informix".si_so_catmensajes WHERE opcode= cCodRet;

		--HOMONIMIA
		IF (cCodRet = '1001') THEN 
			LET cDescrMensaje = 'HOMONIMIA IDENTIFICADA'; 
			LET cCodRetCorreo  			= '';
			LET cDescrMensajeCorreo  	= '';
			LET cCodRetTelefono		  	= '';
			LET cDescrMensajeTelefono  	= '';
			LET cRFC					= '';
			LET cNumCte					='';
		END IF;
		
		IF (cCodRet = '9989') THEN 
			LET cCodRetCorreo  			= '';
			LET cDescrMensajeCorreo  	= '';
			--LET cCodRetTelefono		  	= '';
			LET cDescrMensajeTelefono  	= '';
			LET cRFC					= '';
			LET cNumCte					='';
		END IF;

		RETURN cCodRet ,NVL(cDescrMensaje,''), cCodRetCorreo, cDescrMensajeCorreo, cCodRetTelefono, TRIM(cRFC),  cDescrMensajeTelefono, cNumCte ;
	
	END;
	
END PROCEDURE
DOCUMENT
'DESCRIPCION: SP para validar telÃÂÃÂ©fono y correo electronico ' ,
'AUTOR: Selene Campos',   
'FECHA DE CREACION: 14/08/2019',
'FOLIO: 616';

CREATE PROCEDURE "informix".sp_batch_generararchivoplano(cTipoMov CHAR(2), pFechaAct DATE)
	RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vsSQL1 				CHAR (150);
	DEFINE vsSQL2 				CHAR (750) ;
	DEFINE vsSQL3 				CHAR (150) ;
	--DEFINE v_NomArchivo  VARCHAR(50);
	DEFINE vRuta CHAR (90);
	DEFINE vNombre CHAR (90);
	DEFINE vNomCifras CHAR (90);
	DEFINE vsSQL LVARCHAR (32739);
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	-- AAME RQI 27 067 SE AGREGA VARIABLE PARA EL NUEVO ARCHIVO
	DEFINE sAntNomArchivoFinal VARCHAR(100);
	DEFINE sAnterNomArchivoFinal VARCHAR(100);
	DEFINE iCountMovTO INTEGER;
	DEFINE v_TipoMov VARCHAR (20);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	DEFINE cFlag_motoscoppel CHAR(1); --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 06/04/2021
	DEFINE cCtepresento_comping CHAR(1); --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 06/04/2021
	--DEFINE vAux CHAR(50);
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	LET sPreNomArchivoFinal ='';
	LET sNombreArchivoFinal ='';
	-- AAME RQI 27 067 SE INICIALIZA VARIABLE PARA EL NUEVO ARCHIVO
	LET sAntNomArchivoFinal ='';
	LET sAnterNomArchivoFinal='';
	LET vNombre ='';
	LET vNomCifras ='';
	LET cFlag_motoscoppel = 0; --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 06/04/2021
	LET cCtepresento_comping ='';  --RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica 06/04/2021
	--LET vAux = "||1||-99999|99999";

	SET ISOLATION TO DIRTY READ;
	---SET LOCK MODE TO WAIT 10;

	BEGIN

	   ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
					LET v_cod_ret = iSqlErr;
					--EXECUTE PROCEDURE  "informix".sp_desc_ret(20, v_cod_ret)
					--INTO v_cod_ret, vDesErr;
			END IF;
			RETURN v_cod_ret;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;


		--SET DEBUG FILE TO "/tmp/sp_GenerarArchivoPlano.out";
		--TRACE ON;

		LET v_cod_ret = '000000';
		LET vDesErr = '';
		
		SELECT TRIM(valor)
		INTO vRuta
		FROM bdinteg:"informix".si_param
		WHERE cod_param='193';

		SELECT TRIM(valor) 
		INTO vNombre
		FROM bdisolic:"informix".ss_param 
		WHERE secuencia=374;
		
		SELECT TRIM(valor) 
		INTO vNomCifras
		FROM bdisolic:"informix".ss_param 
		WHERE secuencia=375;

		--LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
		LET sNombreArchivoFinal = TRIM(vRuta)|| TRIM(vNombre);
		-- INC 27 047 Se cambia el nombrado de los archivos generados a como se encontraban los productivos.
		
		IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
			LET v_cod_ret = '000001';
			RETURN v_cod_ret;
		END IF;
	
		SELECT COUNT(tipomovto) INTO iCountMovTO FROM bdinteg:"informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct;
		
		SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas;
	
		IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
			IF iCountMovTO > 0 THEN
				IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
						
					IF EXISTS (SELECT DISTINCT secuencia FROM bdinteg:"informix".si_tramasbatch WHERE fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
						LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
						LET sNombreArchivoFinal = TRIM(vRuta)||TRIM(vNombre)|| cFecha_hoy || '.txt' ;
						LET sPreNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica_batch.unl';
						 --AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
						LET sAntNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica2_batch.unl';
						LET sAnterNomArchivoFinal = TRIM(vRuta)||'movimientosaltaunica3_batch.unl';				
						LET vsSQL = ' echo "UNLOAD TO ' ||  TRIM(vRuta)|| 'movimientosaltaunicax_batch.unl' || ' DELIMITER ' || '''|''' || 
									' SELECT clave, caja, area, cliente, trim(replace(nombre1,''|'','''')), trim(replace(nombre2,''|'','''')), trim(replace(apellidopaterno,''|'','''')), trim(replace(apellidomaterno,''|'','''')), trim(replace(curp,''|'','''')), trim(replace(claveelector,''|'','''')), claveidentificacion, trim(replace(identificacion,''|'','''')), ciudad, colonia, calle, casa, trim(replace(deptoointerior,''|'','''')), trim(replace(rumbo,''|'','''')), trim(replace(complemento,''|'','''')), trim(replace(entrecalles,''|'','''')), flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, uhcentrada, telefono, telefonocelular, casapropia, trim(replace(niptitular,''|'','''')), trim(replace(nipadicional,''|'','''')), sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad, tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual, trim(replace(situacionespecial,''|'','''')), causasituacionespecial, claveautrechaza, aceptadosupervisadorechazado, clientenuevo, creditojoven, trim(replace(lugartrabajo,''|'','''')), ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, trim(replace(deptoointeriortrabajo,''|'','''')), rumbotrabajo, trim(replace(complementotrabajo,''|'','''')), trim(replace(entrecallestrabajo,''|'','''')), flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, trim(replace(nombreunoconyuge,''|'','''')), trim(replace(nombredosconyuge,''|'','''')), trim(replace(apellidopaternoconyuge,''|'','''')), trim(replace(apellidomaternoconyuge,''|'','''')), sexoconyuge, trim(replace(lugartrabajoconyuge,''|'','''')), ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, trim(replace(deptoointeriorconyuge,''|'','''')), rumbotrabajoconyuge, trim(replace(complementoconyuge,''|'','''')), trim(replace(entrecallesconyuge,''|'','''')), flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, trim(replace(nombreunoreferencia,''|'','''')), trim(replace(nombredosreferencia,''|'','''')), trim(replace(apellidopaternoreferencia,''|'','''')), trim(replace(apellidomaternoreferencia,''|'','''')), sexoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia, trim(replace(deptoointeriorreferencia,''|'','''')), rumboreferencia, trim(replace(complementoreferencia,''|'','''')), trim(replace(entrecallesreferencia1,''|'','''')), flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1, clientereferencia2, trim(replace(nombreunoreferencia2,''|'','''')), trim(replace(nombredosreferencia2,''|'','''')), trim(replace(apellidopaternoreferencia2,''|'','''')), trim(replace(apellidomaternoreferencia2,''|'','''')), sexoreferencia2, ciudadreferencia2, coloniareferencia2, callereferencia2, casareferencia2, trim(replace(deptoointeriorreferencia2,''|'','''')), rumboreferencia2, trim(replace(complementoreferencia2,''|'','''')), trim(replace(entrecallesreferencia2,''|'','''')), flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2, clavereferencia2, referencia2, referencia3, trim(replace(marcadatosin,''|'','''')), tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, flagnoreconocehuella, foliotienda, trim(replace(rfc,''|'','''')), cveburo, folioaut, trim(replace(folioconsulta,''|'','''')), trim(replace(folioconcir,''|'','''')), negocio, subnegocio, empleadoautorizo, tipo, fechamovto, numerosolicituddecredito, clientebancoppel, tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn, marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo, buropilototestigo, nacionalidad, trim(replace(no_fm3,''|'','''')), trim(replace(email,''|'','''')), trim(replace(apellido_cas,''|'','''')), pais, no_imss, estado, municipio, trim(replace(numinterior,''|'','''')), propietarionegocio, parcelulares, paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, clientereferencia2bcpl,Statusbcpl, Motivobcpl, FlagProspecto, NumCteProspecto, ParAltoRiesgoNvo, PagoUlt12meses, id_situaciones,puntualidad_ref1,puntualidad_ref2,flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal,trim(nvl(num_producto_bco,''0'')), trim(nvl(status_solicitud_bco,''0'')), NVL(monto_lc_bco,0)::CHAR(20), nvl(fecha_resp_bco,date(1)),trim(nvl(canal_origensol,''0'')),trim(nvl(grupo_eval,''0'')),trim(nvl(grupo_hit,''0'')), nvl(flag_productocoppel,1), nvl(flag_motoscoppel,''0''),nvl(ctepresento_comping,''0'')'||
									' FROM bdinteg:"informix".si_tramasbatch '||
									' WHERE fecha_insert = '||''''||pFechaAct||''''||
									' " > ' || TRIM(vRuta)|| 'Ejecutamovimientosaltaunica_batch.sql';
						SYSTEM vsSQL;
						LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutamovimientosaltaunica_batch.sql";
						LET vsSQL = '';
						LET vsSQL = 'dbaccess bdinteg ' || TRIM(vRuta)|| 'Ejecutamovimientosaltaunica_batch.sql';
						SYSTEM vsSQL;

						LET vsSQL = '';
						LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "movimientosaltaunicax_batch.unl > " || sPreNomArchivoFinal;
						SYSTEM vsSQL;					
						LET vsSQL = '';
						LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "movimientosaltaunica_batch.unl > " || sAntNomArchivoFinal;
						SYSTEM vsSQL;
						-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÃ?S
						LET vsSQL = '';
						LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica2_batch.unl > " || sAnterNomArchivoFinal;
						SYSTEM vsSQL;				
						LET vsSQL = '';
						LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "movimientosaltaunica3_batch.unl > " || sNombreArchivoFinal;
						SYSTEM vsSQL;	
						--
						LET vsSQL = '';
						LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "movimientosaltaunicaderechos_batch.txt";
						SYSTEM vsSQL;
						LET vsSQL = '';
						LET vsSQL =  "rm " || TRIM(vRuta)|| "movimientosaltaunicaderechos_batch.txt";
						SYSTEM vsSQL;
						---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO bdinteg:"informix".si_tramasbatch_hist(secuencia,clave, caja, area, cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, ciudad, colonia, calle, casa, deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, uhcentrada, telefono, telefonocelular, casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad, tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual, situacionespecial, causasituacionespecial, claveautrechaza, aceptadosupervisadorechazado, clientenuevo, creditojoven, lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo, rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1, clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2, coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2, flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2, clavereferencia2, referencia2, referencia3, marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, flagnoreconocehuella, foliotienda, rfc, cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto, numerosolicituddecredito, clientebancoppel, tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn, marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo, buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares, paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl,clientereferencia2bcpl,sucursal,fecha_insert,Statusbcpl, Motivobcpl, FlagProspecto, NumCteProspecto, ParAltoRiesgoNvo, PagoUlt12meses,id_situaciones,puntualidad_ref1,puntualidad_ref2,flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal, num_producto_bco, status_solicitud_bco, monto_lc_bco, fecha_resp_bco,canal_origensol,grupo_eval,grupo_hit, flag_productocoppel,flag_motoscoppel,ctepresento_comping)
					SELECT secuencia,clave, caja, area, cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, ciudad, colonia, calle, casa, deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, uhcentrada, telefono, telefonocelular, casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad, tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual, situacionespecial, causasituacionespecial, claveautrechaza, aceptadosupervisadorechazado, clientenuevo, creditojoven, lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo, rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge, telefonocelularconyuge, claveconyugefamilia, clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr, uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1, clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2, coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2, flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2, clavereferencia2, referencia2, referencia3, marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, flagnoreconocehuella, foliotienda, rfc, cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto, numerosolicituddecredito, clientebancoppel, tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn, marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo, buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares, paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, clientereferencia2bcpl,sucursal,fecha_insert,Statusbcpl, Motivobcpl, FlagProspecto, NumCteProspecto, ParAltoRiesgoNvo, PagoUlt12meses,id_situaciones,puntualidad_ref1,puntualidad_ref2,flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal, NVL(num_producto_bco,0), NVL(status_solicitud_bco,'0'), NVL(monto_lc_bco,0.00),NVL(fecha_resp_bco,DATE(1)),NVL(canal_origensol,'0'),NVL(grupo_eval,'0'),NVL(grupo_hit,'0'), nvl(flag_productocoppel,1), nvl(flag_motoscoppel,'0'),nvl(ctepresento_comping,'0') --RQM-598.1
						FROM bdinteg:"informix".si_tramasbatch
						WHERE fecha_insert = pFechaAct;
												
					END IF;
				ELIF cTipoMov = 'TO'  THEN --Valida el tipo de movimiento para generar el archivo de totales
					LET v_cod_ret = '000000';
					IF EXISTS (SELECT DISTINCT tipomovto FROM bdinteg:"informix".si_archivoscopdiario WHERE tipomovto = 'TO' AND fecha_insert = pFechaAct) THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
						LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
						LET sNombreArchivoFinal = TRIM(vRuta)|| TRIM(vNomCifras)|| cFecha_hoy || '.txt';
						LET sPreNomArchivoFinal =  TRIM(vRuta)|| 'cifrasaltaunica_batch.unl';
						-- AAME RQI 27 067 SE AGREGA EL NOMBRE PARA EL NUEVOS ARCHIVOS DE PASO
						LET sAntNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica2_batch.unl';
						LET sAnterNomArchivoFinal = TRIM(vRuta)|| 'cifrasaltaunica3_batch.unl';
						--
						---	GENERA EL ARCHIVO PLANO
						LET vsSQL1 = ' echo "UNLOAD TO ' || TRIM(vRuta)||'cifrasaltaunicax_batch.unl' || ' DELIMITER ' || '''|''';
						LET vsSQL2 = "SELECT  trama FROM  bdinteg:si_archivoscopdiario WHERE  tipomovto = '"||cTipoMov||"' AND fecha_insert ='"||pFechaAct||"';";
						LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'Ejecutacifrasaltaunica_batch.sql'; 
						LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
						SYSTEM vsSQL;
						LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "|| TRIM(vRuta)|| "Ejecutacifrasaltaunica_batch.sql";
						LET vsSQL = '';
						LET vsSQL = 'dbaccess bdinteg '|| TRIM(vRuta)|| 'Ejecutacifrasaltaunica_batch.sql';
						SYSTEM vsSQL;

						LET vsSQL = '';
						LET vsSQL =  "sed 's/\\//g' " || TRIM(vRuta)|| "cifrasaltaunicax_batch.unl > "|| sPreNomArchivoFinal;
						SYSTEM vsSQL;
						LET vsSQL = '';
						LET vsSQL =  "sed 's/|$//g' " || TRIM(vRuta)|| "cifrasaltaunica_batch.unl > "|| sAntNomArchivoFinal;
						SYSTEM vsSQL;
						-- AAME RQI 27 067 SE AGREGA ARCHIVO DE PASO PARA AGREGAR ESPACIOS EN BLANCO A LOS CAMPOS VACÃ?S
						LET vsSQL = '';
						LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "cifrasaltaunica2_batch.unl > " || sAnterNomArchivoFinal;
						SYSTEM vsSQL;
						LET vsSQL = '';
						LET vsSQL =  "sed 's/||/| |/g' " || TRIM(vRuta)|| "cifrasaltaunica3_batch.unl > " || sNombreArchivoFinal;
						SYSTEM vsSQL;
						

						LET vsSQL = '';
						LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| TRIM(vRuta)|| "cifrasaltaunicaderechos_batch.txt";
						SYSTEM vsSQL;
						LET vsSQL = '';
						LET vsSQL =  "rm "|| TRIM(vRuta)|| "cifrasaltaunicaderechos_batch.txt";
						SYSTEM vsSQL;
					
						---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
						INSERT INTO "informix".si_archivoscophist(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
						SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
						FROM bdinteg:"informix".si_archivoscopdiario
						WHERE tipomovto = 'TO'
						AND fecha_insert = pFechaAct;
						
						--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
						DELETE FROM bdinteg:"informix".si_archivoscopdiario
						WHERE tipomovto = 'TO'
						AND fecha_insert = pFechaAct;

					END IF;
				END IF;
			ELSE
				LET v_cod_ret = '000002';
			END IF;
		ELSE
			LET v_cod_ret = '000003';
		END IF;
		RETURN v_cod_ret;
	END;
	--##############################################################################
	--## Procedimiento   : "informix".sp_GenerarArchivoPlanobatch
	--## Version         : 1.0
	--## Creado por      : Maria Elena Angulo
	--## Fecha creacion  : Diciembre de 2014
	--## Descripcion     : Espejo del procedimiento sp_GenerarArchivoPlano que Realiza la generacion del archivo plano con las
	--## adecuaciones para los nuevos procesos que realizan la generaciÃ³Â®Â Â¤e archivos batch.
	--##############################################################################
END PROCEDURE
DOCUMENT
'Descripcion: Se agregaron nuevos campos para insertar en la tabla si_tramasbatch_hist',
'Autor: 96292199-Braulio Angulo',
'BD: bdinteg',
'Fecha: 04/02/2016',
'Solicita:Rodolfo Gomez',
'----------------------------------------------------------------------------------------------------------------',
'FOLIO: PeticiÃÂ³n 598.1 - RQM 09 488-3 IMPLEMENTACION - ADENDUM - Homologacion de Clientes BanCoppel - Coppel en alta unica (Mensaje PP y % inicial de pago)',
'MODIFICACION: SE AGREGA VALIDACION PARA IDENTIFICAR EL CANAL DE ORIGEN DE LA SOLICITUD (SUCURSAL, CALLE O COPPEL.COM)',
'AUTOR: ISARAI BOJORQUEZ',
'BD: BDINTEG',
'AUTOR: 23/07/2019',
'EITQUETA: RQM-598.1',
'----------------------------------------------------------------------------------------------------------------',
'ModificÃÂ³: 97879606 - AdriÃÂ¡n Eduardo LizÃÂ¡rraga CÃÂ¡zares',
'Folio: 660',
'RQM: RQM 09 553 Ofertar CrÃÂ©dito Coppel a todos los solicitantes en Alta Ã?nica',
'DescripciÃÂ³n: Se omite la validaciÃÂ³n que igual a C el estado civil en caso de ser conyuge, ahora puede ser conyuge en uniÃÂ³n libre',
'			  ademÃÂ¡s, se agregar el campo factor_techo a la consulta de la tabla bdisolic: ss_solicitudes para agregarlo en la tabla',
'			  bdinteg: si_tramasbatch.',
'Fecha: 2020/04/13',
'Solicito: Abraham Narvaez',
'BD: BDINTEG',
'----------------------------------------------------------------------------------------------------------------',
'MODIFICACION: 99802102 - Yonaiker Morillo',
'Folio: 747',
'RQM: RQM 09 541-2 CrÃ©dito Motos Coppel en Alta Ãnica ',
'Descripcion: Se contemplaron los campos "flag_motoscoppel", "ctepresento_comping" para insertar en la tabla si_tramasbatch y si_tramasbatch_hist ',
'Fecha: 28/05/2021',
'Solicito: Abraham Narvaez',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_genera_archivosbatch(pempresa CHAR(3), pFechaAct DATE) 
RETURNING CHAR(6);		

DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE vClave,varea, vrumbo, vcasapropia,vsexo,vestadocivil,vescolaridad,vtiposueldo,vsituacionespecial,vclaveautrechaza,vaceptadosupervisadorechazado,vclientenuevo,vcreditojoven,vpuesto,cSexoConyuge,vrumbotrabajoconyuge,vclaveconyugefamilia,cSexoReferencia,  vclavereferencia1 , cSexoReferencia2 ,  vclavereferencia2 , vmarcadatosin , vflagentregotarjeta , vflagnoreconocehuella , vtipo , vTipoOrigen , cBuroPilotoTestig , cModeloCel , cflaguht , cUnidadHabit  CHAR(1);
DEFINE vcaja,vflaguhc,vuhcmanzana,vuhcotros, vuhcandador,vuhcetapa,vuhclote,vuhcedificio,vuhcentrada, vnumerodependientes,vpersonastrabajan, vlimitecredito,vcausasituacionespecial, vopcionpuesto,vflaguhy, vuhymanzana, vuhyotros, vuhyandador, vuhyetapa, vuhylote, vuhyedificio, vuhyentrada, vclaveproducto, vSistsegsocial, vTiposueldoext, vNumempleados, vSubopcionpuesto, vPuestoext, vOpcionpuestoext, vNumempleadosext, vSubopcionpuestoext, sPropNegocio, sParCelulares, sParAltoRiesgo, sParPrestamo, vtiporeposicion, vtiendafolio, vnegocio, vsubnegocio, vtiendafolioanterior, sFlagTestParametrico, sFlagCapCobranza, iFlagLineaCredEsp, sFlagCapHuella,icontador,vingresomensual SMALLINT;
DEFINE vcliente_ref,vlugartrabajo,vclienteconyuge,vlugartrabajoconyuge,vclientereferencia, vnumcte , vclientereferencia2, cClienteConyugebcpl, cClienteReferencia1bcpl , cClienteReferencia2bcpl , vfolio , vnumerosolicituddecredito, cNumSolRef CHAR(20);
DEFINE vnombre1,vnombre2,vapell_paterno,vapell_materno, vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,vnombreunoreferencia,  vnombredosreferencia, vapellidopaternoreferencia, vapellidomaternoreferencia,vnombreunoreferencia2, vnombredosreferencia2, vapellidopaternoreferencia2, vapellidomaternoreferencia2,cApellCasada CHAR(26);
DEFINE vciudad,vcolonia,vcalle,iNumerocasa,vpersonasvivenendomicilio,vextensiontrabajo,vciudadconyuge, vcoloniaconyuge, vcalletrabajoconyuge, iNumerocasaconyuge, vflagactualizacion, vreferencia2, vreferencia3, vefectuo,vefectuoAP,vefectuoMOD,vreposicion, vempleadoautorizo, vfolioanterior, iEmpleadoSubCob, iMontoIngMensual,  iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, vEdad, iSqlErr, iValor, iPuntuacion, iSecuencia,inumSecuencia, iElemento, vciudadbanco, vcoloniabanco, iContConsBuro, iCuentaRegistros, iRowId,vfoliotienda,iRefSecusConyugue,iRefSecuencias1,iRefSecuencias2, iGrupo,icontador2,iSegundaref,iIsamErr,iTopeMax INTEGER;
DEFINE iIngreso DECIMAL(18,2);
DEFINE vdeptointerior,vdeptoointeriorconyuge, vfolioaut,cNumInterior, cFolioSucursal CHAR(4);
DEFINE vcomplemento,vcomplementotrabajo,vcomplementoconyuge CHAR(80);
DEFINE ventrecalles, ventrecallesconyuge, cErrorInfo,cDescError  CHAR(40);
DEFINE vtelefono, vtelefonocelular,vtelefonotrabajo,vtelefonotrabajoconyuge,vtelefonocelularconyuge, vtelefonoreferencia2,iEmpleadoGteAutori INT8;
DEFINE dFechaConsBuro,vfechanacimiento,vfechaaltacliente,vfechamovto, vFecha_Hoy,dFechaAlta,dFechaRespuesta,dFechaEntrada,dFechaSalida DATE;
DEFINE vniptitular,vniptitularm, vnipadicional  CHAR(7);
DEFINE vcveburo,cMarcarConsultado,cFlagConsBuro,vTipo_Dir,cMarcaHit, vclaveidentificacion,cStatus2,cStatus CHAR(2);
DEFINE cfechanac, cfechadesdecuandovive, cfechaantiguedtrab,cfechaaltacte,vfolioconcir,cFechaConsBuro,cFecha_hoy CHAR(10);
DEFINE vcurp,vclaveelector CHAR(18);
DEFINE videntificacion,cEmpleadoGteAutori CHAR(8);
DEFINE vrfc CHAR(13);
DEFINE vfolioconsulta CHAR(9);
DEFINE cfechamovto CHAR (19);
DEFINE vTipoProducto CHAR(5);
DEFINE cNacionalidad,cPais,cEstado,cDelegMunicip CHAR(3);
DEFINE cNoIMSS CHAR(12);
DEFINE vHora DATETIME HOUR TO FRACTION(3);
DEFINE cDescripElemento CHAR(50);
DEFINE vNombre CHAR(104);
DEFINE vsSQL,vVarSeccion2,vVarSeccion1 LVARCHAR (32000);
DEFINE vCodRetorno Char(6);
DEFINE cVarConyuge,cArmadoCadena,cVarReferencia1,cVarReferencia2,cVarDireccion2,cVarDireccion1,vVarOSCALLE,vVarOSCALLE2,vVarSeccion3,vVarSeccion4,vVarSeccion5,vVarSeccEfectuo LVARCHAR(1024);

--DECLARACION DE VARIABLES
--------------------------
LET cVarConyuge  ="";
LET cArmadoCadena ="";
LET vVarOSCALLE ="";
LET vVarOSCALLE2 ="";
LET vVarSeccion3 ="";
LET cVarReferencia1 ="";
LET cVarReferencia2 ="";
LET cVarDireccion2 ="";
LET cVarDireccion1 ="";
LET iRefSecusConyugue=0;
LET iRefSecuencias1 =0;
LET iRefSecuencias2 =0;
LET vClave = '';
LET vcaja = 100;
LET varea = 'N';
LET vcliente_ref = '0';
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = '';
LET vclaveelector = '';
LET vclaveidentificacion = '';
LET videntificacion = '';
LET vciudad = 0;
LET vcolonia = 0;
LET vcalle = 0;
LET iNumerocasa = 0;
LET vdeptointerior = '';
LET vrumbo = '';
LET vcomplemento = '';
LET ventrecalles = '';
LET vflaguhc = 0;
LET vuhcmanzana = 0;
LET vuhcotros = 0;
LET vuhcandador = 0;
LET vuhcetapa = 0; 
LET vuhclote  = 0;
LET vuhcedificio = 0;
LET vuhcentrada = 0;
LET vtelefono = 0;
LET vtelefonocelular = 0;
LET vcasapropia = '';
LET vniptitular = '';
LET vnipadicional = '';
LET vsexo = '';
LET vestadocivil = '';
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0;
LET vescolaridad = '';
LET vtiposueldo = '';
LET vnumerodependientes = 0;
LET vpersonastrabajan = 0;
LET vlimitecredito = 0;
LET vingresomensual = 0;
LET vsituacionespecial = '';
LET vcausasituacionespecial = 0;
LET vclaveautrechaza = '2';
LET vaceptadosupervisadorechazado = 'P';
LET vclientenuevo = 'N';
LET vcreditojoven = '';
LET vlugartrabajo = '';
LET vcomplementotrabajo = '';
LET vtelefonotrabajo = 0;
LET vextensiontrabajo = 0;
LET vpuesto = '0';
LET vopcionpuesto = 0;
LET cfechaantiguedtrab = '1900/01/01';
LET vclienteconyuge = '0';
LET vnombreunoconyuge = '';
LET vnombredosconyuge = '';
LET vapellidopaternoconyuge = '';
LET vapellidomaternoconyuge = '';
LET cSexoConyuge = '';
LET vlugartrabajoconyuge = '';
LET vciudadconyuge = 0;
LET vcoloniaconyuge = 0;
LET vcalletrabajoconyuge = 0;
LET iNumerocasaconyuge = 0;
LET vdeptoointeriorconyuge = '';
LET vrumbotrabajoconyuge = '';
LET vcomplementoconyuge = '';
LET ventrecallesconyuge = '';
LET vflaguhy = 0;
LET vuhymanzana = 0;
LET vuhyotros = 0;
LET vuhyandador  = 0;
LET vuhyetapa = 0;
LET vuhylote = 0;
LET vuhyedificio = 0;
LET vuhyentrada = 0;
LET vtelefonotrabajoconyuge = 0;
LET vtelefonocelularconyuge = 0;
LET vclaveconyugefamilia = 'E';
LET vclientereferencia = '0';
LET vnombreunoreferencia = '';
LET vnombredosreferencia = '';
LET vapellidopaternoreferencia = '';
LET vapellidomaternoreferencia = '';
LET cSexoReferencia = '';
LET vclavereferencia1 = '';
LET vclientereferencia2 = '0';
LET vnombreunoreferencia2 = '';
LET vnombredosreferencia2 = '';
LET vapellidopaternoreferencia2 = '';
LET vapellidomaternoreferencia2 = '';
LET cSexoReferencia2 = '';
LET vtelefonoreferencia2 = 0;
LET vclavereferencia2 = '';
LET vreferencia2 = 0;
LET vreferencia3 = 0;
LET vmarcadatosin = '';
LET vtiporeposicion = 0;
LET vreposicion = 0;
LET vflagentregotarjeta = '';
LET vefectuo = 0;
LET vefectuoAP=0;
LET vefectuoMOD=0;
LET vtiendafolio = 0;
LET vfolio = '0';
LET cfechaaltacte = '1900/01/01';
LET vflagnoreconocehuella = '';
LET vfoliotienda = 0;
LET vrfc = ''; 
LET vcveburo = '';
LET vfolioaut = '';
LET vfolioconsulta = '';
LET vfolioconcir = '';
LET vnegocio = 0;
LET vsubnegocio = 0;
LET vempleadoautorizo = 0;
LET vtipo = '';
LET cfechamovto = '1900/01/01';
LET dFechaRespuesta=DATE(1);
LET dFechaEntrada = DATE(1);
LET dFechaSalida = DATE(1);
LET vnumerosolicituddecredito = '';
LET vnumcte = '';
LET vtiendafolioanterior = 0;
LET vfolioanterior = 0;
LET vclaveproducto = 6500;
LET vflagactualizacion = 0;
LET vSistsegsocial = 0;
LET vTiposueldoext = 0;
LET vNumempleados = 0;
LET vSubopcionpuesto = 99;
LET vPuestoext = 0;
LET vOpcionpuestoext = 0;
LET vNumempleadosext = 0;
LET vSubopcionpuestoext = 0;
LET vTipoOrigen = 'G';
LET vTipoProducto = '01000';
LET iEmpleadoSubCob = 0;
LET sFlagCapHuella = 1;
LET cMarcarConsultado = '';
LET sFlagTestParametrico = 0;
LET sFlagCapCobranza = 0;
LET iEmpleadoGteAutori = 0;
LET cEmpleadoGteAutori ='';
LET cFlagConsBuro = '';
LET cBuroPilotoTestig = '';
LET cNacionalidad = '';
LET cNoFm3 = '';
LET cEmail = '';
LET cApellCasada = '';
LET cPais = '';
LET cNoIMSS = '';
LET cEstado = '';
LET cDelegMunicip = '';
LET cNumInterior = '';
LET sPropNegocio = 0;
LET sParCelulares = 0; 
LET sParAltoRiesgo = 0;
LET sParPrestamo = 0;
LET cModeloCel = '1';
LET dFechaConsBuro = DATE(1);
LET cFechaConsBuro = '';
LET iMontoIngMensual = 0; 
LET iCapSistematicabono = 0;
LET iTopeAbonoCoppel = 0;
LET iLineaCrediTope = 0;
LET iCapMaximaAbono = 0;
LET iCapRealAbono = 0;
LET iLineaCredReal = 0;
LET iCompromisosSic = 0;
LET iFlagLineaCredEsp = 0;
LET cClienteConyugebcpl = '';
LET cClienteReferencia1bcpl = '';
LET cClienteReferencia2bcpl = '';
LET cFolioSucursal = '0';
LET vHora = '';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
LET cUnidadHabit = '';
LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
LET vEdad = 0;
LET vsSQL = "";
LET vVarSeccion2 = "";
LET vVarSeccion1 = "";
LET vVarOSCALLE = "";
LET vVarSeccion4 = "";
LET vVarSeccion5 = "";
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET iValor = 0;
LET iTopeMax=0;
LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET iSecuencia = 0;
LET inumSecuencia= 0;
LET cMarcaHit = '';
LET iElemento = 0;
LET vciudadbanco = 0;
LET vcoloniabanco = 0;
LET iContConsBuro = 0;
LET cDescripElemento = '';
LET iCuentaRegistros = 0;
LET cStatus = '';
LET cStatus2 = '';
LET iRowId = 0;
LET icontador = 0;
LET icontador2 = 0;
LET iSegundaref = 0;
LET cNumSolRef='';
LET cErrorInfo='';
LET iIsamErr='';
LET cDescError='';
LET vVarSeccEfectuo='';

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
set isolation to dirty read;

BEGIN
ON EXCEPTION
	SET iSqlErr,iIsamErr,cErrorInfo
	--SET DEBUG FILE TO '/RESPALDOS/sp_generaarchivosbatch.out';
	--TRACE ON;
			LET vnumerosolicituddecredito = vnumerosolicituddecredito;
	IF iSqlErr <> 0 THEN
		LET vCodRetorno = iSqlErr;
		LET cDescError= cErrorInfo;
		RETURN vCodRetorno;
	END IF;
END EXCEPTION;
SET LOCK MODE TO WAIT 3;

--Set debug file to '/informix/Malena/pruebas_batch.out';
--trace on;	

IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN	
	SELECT fecha_hoy INTO vFecha_Hoy FROM "informix".si_fechas;
	IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
		LET vCodRetorno = '000002';
		LET iCuentaRegistros = 2;
	ELSE	
		UPDATE STATISTICS MEDIUM FOR TABLE si_archivoscopdiario;
		 --Se revisa que la tabla diario no haya quedado con datos de anteriores ejecuciones por causa de algun error en ejecuciÃ³n.
		 IF EXISTS (SELECT 1 FROM "informix".si_archivoscopdiario) THEN 
			DELETE FROM "informix".si_archivoscopdiario;
		 END IF;		
		SELECT secuencia_max INTO inumSecuencia FROM "informix".si_archivosecuenciamax;		
		LET inumSecuencia = inumSecuencia + 1;
		--SE OBTIENE VALOR DE SALARIOS MINIMOS
		SELECT CASE WHEN "informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
		INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
		--SE OBTIENE VALOR DE TOPE MAXIMO DE INGRESO MENSUAL --2013-12-06 RQI 27 096 AAME										
		SELECT CASE WHEN "informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
		INTO iTopeMax FROM bdisolic:"informix".ss_param WHERE secuencia = 373;
					
		FOREACH WITH HOLD
			--AAME INC 27 046 2013-11-29 
			--AAME 2014-06-04 INC 27 074 
			SELECT DISTINCT sss.num_solicitud, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,ssa.status_solicitud, ssos.status, ssos.secuenciaos, ssos.fecha_respuesta,ssa.ejecutivo_auto,sss.user_insert
			INTO vnumerosolicituddecredito, vnumcte, vfechaaltacliente, cFolioSucursal, dFechaAlta,cStatus, vaceptadosupervisadorechazado, vfolio, dFechaRespuesta,cEmpleadoGteAutori,vefectuoMOD
			FROM bdisolic:"informix".ss_autorizacion ssa,
			bdisolic:"informix".ss_solicitudes sss
			LEFT OUTER JOIN bdisolic:"informix".ss_solicitud_os ssos ON (ssos.empresa = '001' AND ssos.status <> 'P' AND ssos.fecha_respuesta = pFechaAct AND ssos.num_solicitud = sss.num_solicitud)
			WHERE sss.empresa = ssa.empresa
			AND sss.num_solicitud = ssa.num_solicitud			
			AND sss.sucursal=sss.sucursal
			AND ssa.ROWID IN(SELECT MIN(ROWID) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=ssa.num_solicitud AND status_solicitud NOT IN ('PC','AN','CC','OS','CE','CM','MC','EC') AND fecha_entrada =pFechaAct)
			AND ssa.status_solicitud NOT IN('PC','AN')    
			AND sss.num_producto = '6500'
			AND sss.fecha_insert=sss.fecha_insert
			AND ssa.fecha_entrada =  pFechaAct				
					
			LET vsSQL = "";						
			LET vcliente_ref = "0";
			LET cVarReferencia1	=  "0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";			
			LET cVarReferencia2="";
			LET cVarDireccion1="";
			LET cVarDireccion2="";			
			LET vclienteconyuge ='0';
			LET vnombreunoconyuge='';
			LET vnombredosconyuge='';
			LET vapellidopaternoconyuge='';
			LET vapellidomaternoconyuge='';
			LET vclaveconyugefamilia='';
			LET cSexoConyuge='';
			LET iRefSecuencias1 =0;
			LET iRefSecuencias2 =0;
			LET vclientereferencia='0';
			LET vnombreunoreferencia='';
			LET vnombredosreferencia='';
			LET vapellidopaternoreferencia='';
			LET vapellidomaternoreferencia='';
			LET vclavereferencia1='';
			LET cSexoReferencia='';		
			LET icontador = 0;
			LET vlugartrabajo = '';
			LET vlugartrabajoconyuge = '';
			LET cVarConyuge = '';
			LET inumSecuencia = inumSecuencia + 1;
			LET vtelefonotrabajoconyuge =0;
			LET vtelefonocelularconyuge =0;
			LET vtelefonoreferencia2 =0;
			LET iSecuencia=0;		
					
			IF (cStatus NOT IN ("RT","OS","AT","AP") AND dFechaAlta <> pFechaAct) and  NVL(dFechaRespuesta,DATE(1)) <> pFechaAct THEN
				--AAME 2014-01-06 INC 27 050 
				IF cStatus= 'BC' THEN
					--AAME 2014-06-04 INC 27 074 
					SELECT DISTINCT status_solicitud
					INTO cStatus
					FROM bdisolic:"informix".ss_autorizacion 
					WHERE ROWID IN(SELECT MIN(ROWID) FROM bdisolic:"informix".ss_autorizacion WHERE num_solicitud=vnumerosolicituddecredito AND status_solicitud NOT IN ('PC','AN','CC','BC','OS','CE','CM','MC','EC') AND fecha_entrada =pFechaAct)	
					AND fecha_entrada =pFechaAct	
					AND num_solicitud=vnumerosolicituddecredito;
				ELSE 
					CONTINUE FOREACH;
				END IF;
			END IF;				
			LET vclave = "";
			IF  dFechaAlta <> vfechaaltacliente THEN --SIGNIFICA QUE SE ORIGINO EN OTRA FECHA, Y NO ES EL PROCESO DE ALTA DE SOLICITUD
				--VALIDAR QUE SI ESTO SE CUMPLE LOS STATUS VALIDOS SON UNICAMENTE AT,RT,AP.
				IF cStatus NOT IN ("RT","AT","AP") AND NVL(vfolio,0) = 0  THEN CONTINUE FOREACH;END IF;
				 IF cStatus = "RT" OR cStatus = "AT" THEN
					--AAME INC 27 046 2013-11-29 
					LET iEmpleadoGteAutori = 0; --DEFAULT BLANCO						 
					LET vClave = 'M';												
					LET vaceptadosupervisadorechazado = DECODE (cStatus,"RT","H","AT","A");	
					--AAME INC 27 081 2014-07-24 
					LET vefectuo=vefectuoMOD;
				ELIF cStatus = "AP"  THEN
					--AAME INC 27 046 2013-11-29 
					LET iEmpleadoGteAutori = cEmpleadoGteAutori::INT8; --DEFAULT BLANCO					
					LET vClave = 'A';					
					LET vaceptadosupervisadorechazado = '';														
					SELECT a.numcte, a.numcte_ref, CASE WHEN "informix".sp_EsNumerico(a.user_insert) = 'V' THEN a.user_insert::INTEGER ELSE 0 END
					INTO vnumcte, vcliente_ref,vefectuoAP
					FROM "informix".si_cliente a, "informix".si_adiccoppel b
					WHERE a.numcte = vnumcte AND a.empresa = pempresa AND b.empresa = pempresa AND a.numcte_ref = b.numctecoppel AND a.numcte = b.numcte;
					IF NVL(vnumcte, '') = '' THEN					
						LET vCodRetorno = '000000';
						LET iCuentaRegistros = 2;
						CONTINUE FOREACH;
					ELSE 
						SELECT fechaasignacion INTO vfechaaltacliente FROM bditarjcop:"informix".tarjetasnumtarcop WHERE empresa=pempresa AND cvesucursal=cvesucursal AND numtarjeta = vcliente_ref;
					END IF; 
					IF vfechaaltacliente IS NULL THEN LET vfechaaltacliente =dFechaAlta; END IF;
					--AAME INC 27 081 2014-07-24 
					LET vefectuo=vefectuoAP;							
				ELSE				
					--AAME INC 27 046 2013-11-29 
					LET iEmpleadoGteAutori = 0; 
						LET vtiendafolio = cFolioSucursal;
					--INI JMAH SE CONSULTA SI SE GENERO UNA OS CALLE PARA LA SOLICITUD EN QUESTION								
					IF NVL(vfolio,0) =  0 THEN
						LET vfechaaltacliente =dFechaAlta;
						LET vaceptadosupervisadorechazado = 'P';
						LET vfolio = 0;
					END IF;
					--INC 27 017 AAME			
					IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito) > 1 THEN
						FOREACH
							SELECT FIRST 1 secuenciaos
							INTO vfolioanterior 
							FROM bdisolic:"informix".ss_solicitud_os
							WHERE num_solicitud = vnumerosolicituddecredito AND secuenciaos < vfolio ORDER BY secuenciaos DESC
						END FOREACH						
						LET vtiendafolioanterior = vtiendafolio;						
					END IF;														
					IF vaceptadosupervisadorechazado = 'R' THEN
						LET vaceptadosupervisadorechazado = 'H';
					END IF;			
					LET vClave = 'M';																		
					LET vaceptadosupervisadorechazado = "";		
					--AAME INC 27 081 2014-07-24 
					LET vefectuo=vefectuoMOD;										
				END IF;		
			ELSE			
				LET vaceptadosupervisadorechazado 	= 'P';				
				--AAME INC 27 046 2013-11-29 
				LET iEmpleadoGteAutori = 0; --DEFAULT BLANCO
				--AAME INC 27 081 2014-07-24 
				LET vefectuo=vefectuoMOD;				
			END IF;
			IF vnumerosolicituddecredito <> '' OR vnumcte <> '' THEN 					
			--SE OBTIENEN DATOS PERSONALES DEL CLIENTE				
				EXECUTE PROCEDURE "informix".consedadcte(pempresa, vnumcte) INTO vCodRetorno, vNombre, vEdad;
				
				SELECT nombre1, nombre2, apell_paterno, apell_materno, numcte, rfc, fecha_insert,
				CASE WHEN "informix".sp_EsNumerico(string2)= 'V' THEN string2::INTEGER ELSE 0 END, apell_casada,user_insert
				INTO vnombre1, vnombre2, vapell_paterno, vapell_materno, vnumcte, vrfc, 
				vfechamovto, vpersonasvivenendomicilio, cApellCasada,vefectuoAP
				FROM "informix".si_cliente cte
				WHERE empresa = pempresa AND numcte = vnumcte;
				--AAME INC 27 081 2014-07-24 
				IF vefectuoAP='' AND cstatus='AP' THEN
					LET vefectuo=vefectuoAP;
				END IF;
				--AAME 20140811 INC 27 082 
				SELECT estado_civil, NVL(TRIM(REPLACE(REPLACE(curp,'|',' '),'//','/')),''), numidentifi, codidentifi, habita_en, sexo, fecha_nac, escolaridad,
				nacionalidad, no_fm3, no_imss
				INTO vestadocivil, vcurp, vclaveelector, vclaveidentificacion, vcasapropia, vsexo, vfechanacimiento, vescolaridad,
				cNacionalidad, cNoFm3, cNoIMSS
				FROM "informix".si_ctepf
				WHERE numcte = vnumcte;									
				-- 20140324 INC 27 061 
				SELECT NVL(correo_elec,'') INTO cEmail 
				FROM bdinteg:"informix".si_correos 
				WHERE numcte = vnumcte 
				AND status_correo = 'A'
				AND ROWID IN (SELECT MAX(ROWID) FROM bdinteg:"informix".si_correos 
								WHERE numcte = vnumcte AND status_correo = 'A');	
				IF cEmail IS NULL THEN LET cEmail='';END IF;
				--CONSULTA LA INFORMACION DE LA DIRECCION DEL CLIENTE					
				FOREACH WITH HOLD
					SELECT CASE WHEN "informix".sp_EsNumerico(dir.numerociudad) = 'V' THEN dir.numerociudad::INTEGER ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.numerocolonia) = 'V' THEN dir.numerocolonia::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.numerocalle) = 'V' THEN dir.numerocalle::INTEGER ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.numeroextcalle) = 'V' THEN dir.numeroextcalle::INTEGER ELSE 0 END,
					NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,'|',' '),'//','/')),''),dir.puntocardinal,NVL(TRIM(REPLACE(REPLACE(dir.observaciones,'|',' '),'//','/')),''),NVL(TRIM(REPLACE(REPLACE(dir.entre_calles,'|',' '),'//','/')),''), 
					DECODE (dir.unidadhabitac,"S","1","0"), 
					CASE WHEN "informix".sp_EsNumerico(dir.manzana) = 'V' THEN dir.manzana::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.otros) = 'V' THEN dir.otros::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.andador) = 'V' THEN dir.andador::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.etapa) = 'V' THEN dir.etapa::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.lote ) = 'V' THEN dir.lote::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(dir.edificio) = 'V' THEN dir.edificio::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(dir.entrada) = 'V' THEN dir.entrada::SMALLINT ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(NVL(tel1.telefono,0)) = 'V' THEN tel1.telefono::INT8 ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(NVL(tel2.telefono,0)) = 'V' THEN tel2.telefono::INT8 ELSE 0 END, dir.tipo_dir, 
					NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,'|',' '),'//','/')),''),	dir.pais, dir.estado, 
					CASE WHEN "informix".sp_EsNumerico(NVL(tel3.telefono,0)) = 'V' THEN tel3.telefono::INT8 ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(NVL(tel3.extension,0)) = 'V' THEN tel3.extension::INTEGER ELSE 0 END
					INTO  vciudadbanco, vcoloniabanco, vcalle, iNumerocasa, vdeptointerior, vrumbo, vcomplemento, ventrecalles, cUnidadHabit, vuhcmanzana,	vuhcotros,vuhcandador, vuhcetapa, vuhclote, vuhcedificio, vuhcentrada, vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, cPais, cEstado,
					vtelefonotrabajo,vextensiontrabajo
					FROM "informix".si_direcciones_actual dir
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )								
					LEFT OUTER JOIN bdinteg:"informix".si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
					WHERE dir.numcte = vnumcte AND dir.tipo_dir IN ('1' ,'2')
					AND dir.secuencia = (SELECT MAX(dir2.secuencia) FROM "informix".si_direcciones_actual dir2 WHERE dir2.numcte = vnumcte AND dir2.tipo_dir = dir.tipo_dir)
					ORDER BY dir.tipo_dir DESC			
					
					-- SE OBTIENE EL NOMBRE DE LA CIUDAD Y COLONIA
					SELECT {+INDEX("informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
					INTO vciudad, vcolonia
					FROM "informix".si_catzonas
					WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
					--SI NO EXISTEN LA CIUDAD Y COLONIA, SE TOMARA DE LA SUCURSAL
					
					--SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
					
					SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad 
                    INTO vciudadbanco 
                    FROM bdinteg:"informix".si_ptf
                    WHERE id_ptf = cFolioSucursal AND tipo='S';
					
					
					IF NVL(vciudad, 0) = 0 THEN
						SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
						IF NVL(vciudad, 0) = 0 THEN						
								SELECT FIRST 1 numerociudadcoppel INTO vciudad FROM "informix".si_catzonas where numerociudadcoppel <> 0;
						END IF;
					END IF;
					IF NVL(vcolonia, 0) = 0 THEN											
						SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
						IF NVL(vcolonia, 0) = 0 THEN
							SELECT FIRST 1 numerocoloniacoppel INTO vcolonia FROM "informix".si_catzonas where numerocoloniacoppel <> 0;
						END IF;
					END IF;
					
					IF iNumerocasa > 32767 THEN 
						LET iNumerocasa = 0;	
					END IF;

					IF iNumerocasa = 0 AND vTipo_Dir ='2' THEN
						LET iNumerocasa =1;							
					ELIF iNumerocasa = 0 AND vTipo_Dir ='1' THEN
						LET iNumerocasa = 1;
					END IF;		
					IF NVL(vcomplemento, '') = '' THEN LET vcomplemento = 'E'; END IF;
					
					LET cArmadoCadena = "";
					LET cArmadoCadena = NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||TRIM(NVL(vrumbo, ''));
					LET cArmadoCadena = TRIM(cArmadoCadena) ||"|"||TRIM(NVL(vcomplemento, ' '))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, '0')||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0);
					
					IF vTipo_Dir= '2' THEN
						LET cVarDireccion2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajo, 0)||"|"||NVL(vextensiontrabajo, 0);								
					ELSE
						LET cVarDireccion1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0);
					END IF;
				END FOREACH;
				IF DBINFO("sqlca.sqlerrd2") =	0 THEN	
					LET cArmadoCadena = NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||TRIM(NVL(vrumbo, ''));
					LET cArmadoCadena = TRIM(cArmadoCadena) ||"|"||TRIM(NVL(vcomplemento, ''))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, '0')||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0);										
					LET cVarDireccion2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajo, 0)||"|"||NVL(vextensiontrabajo, 0);		
					LET cVarDireccion1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0);								
				ELSE 
					IF DBINFO("sqlca.sqlerrd2") =	1 THEN
					LET cArmadoCadena = NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||TRIM(NVL(vrumbo, ''));
					LET cArmadoCadena = TRIM(cArmadoCadena) ||"|"||TRIM(NVL(vcomplemento, ''))||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, '0')||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0);
						IF vTipo_Dir <> '2' THEN
							LET cVarDireccion2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajo, 0)||"|"||NVL(vextensiontrabajo, 0);		
						ELSE
							LET cVarDireccion1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefono, 0)||"|"||NVL(vtelefonocelular, 0);
						END IF;						
					END IF;
				END IF 
				LET cArmadoCadena = "";					
				SELECT ing.nombre_empresa, 
				CASE WHEN "informix".sp_EsNumerico(ing.claveopcionpuesto) = 'V' THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END,
				CASE WHEN "informix".sp_EsNumerico(ing.clavesubopcionpuesto) = 'V' THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END --ing.ingreso_mensual
				INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto 
				FROM "informix".si_ingresos ing
				WHERE ing.numcte = vnumcte
				AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM "informix".si_ingresos WHERE numcte = vnumcte AND tipo_ingreso = 'T');
				
				IF NVL(vopcionpuesto, '') = '' THEN LET vopcionpuesto = '0'; END IF;
				IF NVL(vSubopcionpuesto, '') = '' THEN LET vSubopcionpuesto = '99'; END IF;
				SELECT tp_ingreso INTO vtiposueldo FROM bdisolic:"informix".ss_resum_scor_fin WHERE num_solicitud = vnumerosolicituddecredito;						
			--SE CAMBIA EL FORMATO DE LA FECHA NACIMIENTO, EL ALTA DEL CLIENTE Y OBTENCION DE FECHA DE MOVIMIENTOS
				SELECT DBINFO('utc_to_datetime', sh_curtime) INTO vHora FROM sysmaster:sysshmvals;
				LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
				LET cfechaaltacte = YEAR(vfechaaltacliente)||"/"||LPAD(MONTH(vfechaaltacliente),2,0)||"/"||LPAD(DAY(vfechaaltacliente),2,0);
				IF pFechaAct <> vFecha_Hoy THEN
					LET cfechamovto = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0)||" "||vHora;
					LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
				ELSE
					LET cfechamovto = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0)||" "||vHora;
					LET cFecha_hoy = YEAR(vFecha_Hoy)||"/"||LPAD(MONTH(vFecha_Hoy),2,0)||"/"||LPAD(DAY(vFecha_Hoy),2,0);
				END IF;					
				--SE PONEN VALORES POR DEFAULT
				IF NVL(vcomplementotrabajo, '') = '' THEN
					LET vcomplementotrabajo = 'E';
				END IF;													
				LET cClienteConyugebcpl = '0';
				LET cClienteReferencia1bcpl = '0';
				LET cClienteReferencia2bcpl = '0';				
				--SE OBTIENE NUMERO DE SOLICITUD DE BANCO PARA OBTENER SUS REFERENCIAS EN CASO DE QUE A LA SOLICITUD COPPEL NO SE LE HAYAN HEREDADO POR HABER SIDO RECHAZADA ANTES.
				SELECT num_solicitud
				 INTO cNumSolRef
				FROM bdisolic:"informix".ss_solicitudes
				WHERE empresa = pempresa
				AND numcte  =vnumcte
				AND fecha_insert = dFechaAlta
				AND num_producto = '6001'
				AND status_solicitud NOT IN ('AN','PC')
				AND ROWID IN (SELECT MAX(ROWID)
								FROM bdisolic:"informix".ss_solicitudes
								WHERE empresa = pempresa
								AND numcte  = vnumcte
								AND fecha_insert = dFechaAlta
								AND num_producto = '6001'
								AND status_solicitud NOT IN ('AN','PC'));
				  
				  IF NVL(cNumSolRef,'') = '' THEN
						LET cNumSolRef=vnumerosolicituddecredito;
				  END IF;				
				--INI referencias --JMAH --EN CASO DE ESTAR CASADO CONSULTO AL CONYUGUE
				IF 	vestadocivil = 'C' THEN 
					LET vclaveconyugefamilia = 'E';						
					SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'), nombre1, nombre2, apell_paterno, apell_materno, parentesco, sexo, 
					CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN NVL(secuencia::INTEGER,0) ELSE 0 END
					INTO cClienteConyugebcpl,vclienteconyuge,vnombreunoconyuge,vnombredosconyuge,vapellidopaternoconyuge,vapellidomaternoconyuge,
					vclaveconyugefamilia,cSexoConyuge,iRefSecusConyugue
					FROM "informix".si_refclientes cte2
					WHERE empresa = pempresa AND numcte = vnumcte 
					AND secuencia = (SELECT NVL(MAX(secuencia),0) FROM "informix".si_refclientes WHERE numcte = vnumcte AND parentesco = 'E' AND num_solicitud = cNumSolRef) 
					AND parentesco = 'E' AND num_solicitud = cNumSolRef;							
						IF NVL(vclienteconyuge,'') = '' THEN LET vclienteconyuge = '0'; END IF;
						IF NVL(cClienteConyugebcpl,'')='' THEN LET cClienteConyugebcpl='0'; END IF;
					--INC 27 31 AAME 03-09-13 
					IF NVL(iRefSecusConyugue,0) = 0 THEN					
						let vnombreunoconyuge = ''; 
						let vnombredosconyuge = ''; 
						let vapellidopaternoconyuge = ''; 
						let vapellidomaternoconyuge = ''; 
						let vclaveconyugefamilia = '';
						let csexoconyuge = ''; 
						let irefsecusconyugue = 0;
						-- RQI 27 067 03-10-2013 
						let vestadocivil='S';
					ELSE
						SELECT nombre_empresa 
						INTO vlugartrabajoconyuge 
						FROM bdinteg:"informix".si_ingresos 
						WHERE numcte = vclienteconyuge AND empresa = pempresa AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdinteg:"informix".si_ingresos WHERE numcte = vclienteconyuge AND empresa = pempresa); 
							IF DBINFO("sqlca.sqlerrd2") =	0 THEN														
								LET vlugartrabajoconyuge = '';					
							END IF;
							LET cVarConyuge =TRIM(NVL(vlugartrabajoconyuge, ''));							
					END IF;
				END IF;						
				IF 	vestadocivil <> 'C' THEN--EN CASO DE ESTAR SOLTERO CONSULTO LA PENULTIMA REFERENCIA 
					LET vclaveconyugefamilia = '';
					LET icontador2= 0;
					FOREACH WITH HOLD
						SELECT secuencia
							INTO iSegundaref
						FROM "informix".si_refclientes
						WHERE numcte = vnumcte 
						AND num_solicitud = cNumSolRef	
						ORDER BY secuencia DESC
						LET icontador2=icontador2 + 1;
							IF icontador2 =2 THEN
								EXIT FOREACH;
							END IF;
					END FOREACH;
					LET iSegundaref=iSegundaref;
					SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'),nombre1,nombre2,apell_paterno,apell_materno,parentesco,sexo,
					CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN secuencia::INTEGER ELSE 0 END
					INTO cClienteReferencia1bcpl,vclientereferencia,vnombreunoreferencia,vnombredosreferencia,vapellidopaternoreferencia,vapellidomaternoreferencia,
					vclavereferencia1,cSexoReferencia,iRefSecuencias1
					FROM "informix".si_refclientes cte2
					WHERE empresa = pempresa AND numcte = vnumcte
					AND secuencia = iSegundaref
					AND num_solicitud = cNumSolRef; 
					
					IF NVL(vclientereferencia,'') = '' THEN LET vclientereferencia='0'; END IF;
					IF NVL(cClienteReferencia1bcpl,'') = '' THEN LET cClienteReferencia1bcpl = '0'; END IF;	
					--RQI 27 067 Se agrega validacion para que solo cuando sea diferente de casado obtenga la referencia con maxima secuencia AAME				
					SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'),nombre1,nombre2,apell_paterno,apell_materno,parentesco,sexo,
					CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN secuencia::INTEGER ELSE 0 END
					INTO cClienteReferencia2bcpl,vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
					vclavereferencia2,cSexoReferencia2,iRefSecuencias2
					FROM "informix".si_refclientes cte2					     
					WHERE empresa = pempresa AND numcte = vnumcte
					AND secuencia = (SELECT NVL(MAX(secuencia), 0) FROM "informix".si_refclientes WHERE numcte = vnumcte AND num_solicitud = cNumSolRef) --AND parentesco <> 'E'
					AND num_solicitud = cNumSolRef;						

				ELSE 
					--RQI 27 067 Se agrega validacion para que solo cuando sea casado consulte la segunda referencia como diferente de E AAME				
					--AAME INC 27 046 2013-11-29 
					SELECT NVL(numcte_banco,'0'),NVL(numcte_ref,'0'),nombre1,nombre2,apell_paterno,apell_materno,parentesco,sexo,
					CASE WHEN "informix".sp_EsNumerico(secuencia) = 'V' THEN secuencia::INTEGER ELSE 0 END
					INTO cClienteReferencia2bcpl,vclientereferencia2,vnombreunoreferencia2,vnombredosreferencia2,vapellidopaternoreferencia2,vapellidomaternoreferencia2,
					vclavereferencia2,cSexoReferencia2,iRefSecuencias2
					FROM "informix".si_refclientes cte2					     
					WHERE empresa = pempresa AND numcte = vnumcte
					AND secuencia = (SELECT NVL(MAX(secuencia), 0) FROM "informix".si_refclientes 
					WHERE numcte = vnumcte AND num_solicitud = cNumSolRef and secuencia <> iRefSecusConyugue) 
					AND num_solicitud = cNumSolRef;					
					--AAME INC 27 046 2013-11-29 
					IF NVL(iRefSecuencias2,0) = 0 THEN
						let cClienteReferencia2bcpl = '';
						let vclientereferencia2 = '';
						let vnombreunoreferencia2 = '';
						let vnombredosreferencia2 = '';
						let vapellidopaternoreferencia2 = '';
						let vapellidomaternoreferencia2 = '';
						let vclavereferencia2 = '';
						let cSexoReferencia2 = '';
						let iRefSecuencias2 = 0;						
					END IF;								
				END IF;														
				IF NVL(vclientereferencia2, '') = '' THEN LET vclientereferencia2 = '0'; END IF;
				IF NVL(cClienteReferencia2bcpl, '') = '' THEN LET cClienteReferencia2bcpl = '0'; END IF;
				--SI EL CLIENTE ES CASADO SE OBTIENE INFORMACION DE LA ULTIMA REFERENCIA DESPUES DEL CONYUGUE Y LOS CAMPOS DE REFERENCIA 2 QUEDAN VACÃOS						
				IF 	vestadocivil = 'C' AND NVL(iRefSecusConyugue,0) <> 0 THEN --INC 27 31 AAME 03-09-13 
					LET vclientereferencia= vclientereferencia2;
					LET cClienteReferencia1bcpl = cClienteReferencia2bcpl;
					LET vnombreunoreferencia=vnombreunoreferencia2;
					LET vnombredosreferencia=vnombredosreferencia2;
					LET vapellidopaternoreferencia=vapellidopaternoreferencia2;
					LET vapellidomaternoreferencia=vapellidomaternoreferencia2;
					LET vclavereferencia1=vclavereferencia2;
					LET cSexoReferencia=cSexoReferencia2;
					LET iRefSecuencias1=iRefSecusConyugue;						
					LET vclientereferencia2 = '0';
					LET vnombreunoreferencia2 = '';
					LET vnombredosreferencia2 = '';
					LET vapellidopaternoreferencia2 = '';
					LET vapellidomaternoreferencia2 = '';
					LET cSexoReferencia2 = '';
					LET vclavereferencia2 = '';
					LET cClienteReferencia2bcpl='0';
				END IF;								
				--SE OBTIENE LAS DIRECCIONES DE LAS REFERENCIAS									
				FOREACH WITH HOLD
						SELECT CASE WHEN "informix".sp_EsNumerico(numerociudad) = 'V' THEN numerociudad::INTEGER ELSE 0 END,
						CASE WHEN "informix".sp_EsNumerico(numerocolonia) = 'V' THEN numerocolonia::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(numerocalle) = 'V' THEN numerocalle::INTEGER ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(numeroextcalle) = 'V' THEN numeroextcalle::INTEGER ELSE 0 END, 
						NVL(TRIM(REPLACE(REPLACE(numerointcalle,'|',' '),'//','/')),''),puntocardinal,NVL(TRIM(REPLACE(REPLACE(observaciones,'|',' '),'//','/')),''),NVL(TRIM(REPLACE(REPLACE(entre_calles,'|',' '),'//','/')),''),unidadhabitac,
						CASE WHEN "informix".sp_EsNumerico(manzana) = 'V' THEN manzana::SMALLINT ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(otros) = 'V' THEN otros::SMALLINT ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(andador) = 'V' THEN andador::SMALLINT ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(etapa) = 'V' THEN etapa::SMALLINT ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(lote ) = 'V' THEN lote::SMALLINT ELSE 0 END, 
						CASE WHEN "informix".sp_EsNumerico(edificio) = 'V' THEN edificio::SMALLINT ELSE 0 END,
						CASE WHEN "informix".sp_EsNumerico(entrada) = 'V' THEN entrada::SMALLINT ELSE 0 END,
						CASE WHEN "informix".sp_EsNumerico(telefono3) = 'V' THEN telefono3::INT8 ELSE 0 END,
						CASE WHEN "informix".sp_EsNumerico(telefono2) = 'V' THEN telefono2::INT8 ELSE 0 END,
						CASE WHEN "informix".sp_EsNumerico(telefono1) = 'V' THEN telefono1::INT8 ELSE 0 END,
						secuencia
						INTO vciudadbanco,vcoloniabanco,vcalletrabajoconyuge,iNumerocasaconyuge,vdeptoointeriorconyuge,vrumbotrabajoconyuge,
						vcomplementoconyuge,ventrecallesconyuge,cflaguht,vuhymanzana,vuhyotros,vuhyandador,vuhyetapa,vuhylote,vuhyedificio,
						vuhyentrada,vtelefonotrabajoconyuge,vtelefonocelularconyuge,vtelefonoreferencia2,iSecuencia
						FROM "informix".si_refdirecciones dir2
						WHERE numcte = vnumcte AND secuencia IN(iRefSecuencias1,iRefSecuencias2)									
						--SE OBTIENE EL NOMBRE DE COLONIA Y CIUDAD
						SELECT {+INDEX("informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
						INTO vciudadconyuge, vcoloniaconyuge
						FROM "informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						--EN CASO DE NO EXISTIR COLONIA Y CIUDAD SE OBTIENEN MEDIANTE LA SUCURSAL
						
						--SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
												
						SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad 
						INTO vciudadbanco 
						FROM bdinteg:"informix".si_ptf
						WHERE id_ptf = cFolioSucursal AND tipo='S';
												
						IF NVL(vciudadconyuge, 0) = 0 THEN								
							SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
							IF NVL(vciudadconyuge, 0) = 0 THEN	
								SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas where numerociudadcoppel <> 0;
							END IF;
						END IF;
						IF NVL(vcoloniaconyuge, 0) = 0 THEN
							SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
							IF NVL(vcoloniaconyuge, 0) = 0 THEN
								SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerocoloniacoppel <> 0;
							END IF;
						END IF;						
						IF cflaguht = 'S' THEN
							LET vflaguhy = 1;
						ELSE
							LET vflaguhy = 0;
						END IF;
						
						IF iNumerocasaconyuge > 32767 THEN
							LET iNumerocasaconyuge = 0;
						END IF;
						IF iNumerocasaconyuge = 0 THEN
							LET iNumerocasaconyuge = 1;
						END IF;
						IF NVL(vcomplementoconyuge, '') = '' THEN
							LET vcomplementoconyuge = 'E';
						END IF;
						LET icontador = icontador+1;
						--SE REALIZA EL ARMADO DE LA CADENA CORRESPONDIENTE A LA INFORMACION DEL CONYUGUE Y LAS REFERENCIAS
						LET cArmadoCadena= NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|"||NVL(vcalletrabajoconyuge, 0)||"|"||NVL(iNumerocasaconyuge, 0)||"|"||TRIM(NVL(vdeptoointeriorconyuge, ''))||"|"||TRIM(NVL(vrumbotrabajoconyuge, ''))||"|"||TRIM(NVL(vcomplementoconyuge, ''))||"|"||TRIM(NVL(ventrecallesconyuge,''));
						LET cArmadoCadena = TRIM(cArmadoCadena)||"|"||NVL(vflaguhy, 0)||"|"||NVL(vuhymanzana, 0)||"|"||NVL(vuhyotros, 0)||"|"||NVL(vuhyandador, 0)||"|"||NVL(vuhyetapa, 0)||"|"||NVL(vuhylote, 0)||"|"||NVL(vuhyedificio, 0)||"|"||NVL(vuhyentrada, 0);						
						IF iSecuencia = iRefSecuencias1 AND vestadocivil = 'C' THEN		
							IF NVL(irefsecusconyugue,0)= 0 THEN --INC 27 31 AAME 03-09-13 
								LET cVarReferencia1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia1, ''));	
								LET cVarConyuge = "|0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";									
							ELSE							
								LET cVarReferencia2	= "0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";							
								LET cVarConyuge = TRIM(cVarConyuge)||"|"||TRIM(cArmadoCadena)||"|"||NVL(vtelefonotrabajoconyuge, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclaveconyugefamilia, ''));
							END IF;
						ELIF iSecuencia = iRefSecuencias1 AND vestadocivil <> 'C' THEN	
							LET cVarReferencia1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia1, ''));	
							LET cVarConyuge = "|0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";								
						ELIF iSecuencia = iRefSecuencias2 THEN
							IF vestadocivil <> 'C' THEN
								LET cVarReferencia2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia2, ''));								
							ELSE
								IF NVL(iRefSecusConyugue,0) <> 0 THEN --INC 27 AAME 03-09-13 
									LET cVarReferencia1 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia1, ''));	
								ELSE
									LET cVarReferencia2 = TRIM(cArmadoCadena)||"|"||NVL(vtelefonoreferencia2, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclavereferencia2, ''));								
								END IF;
							END IF;
						END IF;												
				END FOREACH;
				--EN CASO DE NO INGRESAR AL CICLO ANTERIOR SE ANEXAN VALORES POR DEFAULT PARA LAS DIRECCIONES DE LA O LAS REFERENCIAS QUE NO CUENTAN CON UNA DIRECCION
				--INC 27 060 2014-03-18 
				IF icontador =1 THEN			
				
					--SELECT ciudad INTO vciudadbanco FROM "informix".si_sucursales WHERE sucursal = cFolioSucursal;
					
					SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf)} cve_ciudad 
					INTO vciudadbanco 
					FROM bdinteg:"informix".si_ptf
					WHERE id_ptf = cFolioSucursal AND tipo='S';					
				
					SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;								
							IF NVL(vciudadconyuge, 0) = 0 THEN	
								SELECT FIRST 1 numerociudadcoppel INTO vciudadconyuge FROM "informix".si_catzonas WHERE numerociudadcoppel <>0;
							END IF;
					SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerociudad = vciudadbanco;
							IF NVL(vcoloniaconyuge, 0) = 0 THEN
								SELECT FIRST 1 numerocoloniacoppel INTO vcoloniaconyuge FROM "informix".si_catzonas WHERE numerocoloniacoppel <>0;
							END IF;	
						LET cVarReferencia2	=  NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|0|0|||E||0|0|0|0|0|0|0|0|0|0|";
						LET cVarReferencia2	=	TRIM(cVarReferencia2)||TRIM(NVL(vclavereferencia2, ''));	
						--AAME INC 27 054 2014-02-05 
						--AAME INC 27 055 2014-02-12 
						IF iSecuencia = iRefSecuencias2 AND iRefSecuencias1 <> iRefSecuencias2 THEN					
							LET cVarConyuge = TRIM(cVarConyuge)||"|"||NVL(vciudadconyuge, 0)||"|"||NVL(vcoloniaconyuge, 0)||"|0|0|||E||0|0|0|0|0|0|0|0"||"|"||NVL(vtelefonotrabajoconyuge, 0)||"|" ||NVL(vtelefonocelularconyuge, 0)||"|"||TRIM(NVL(vclaveconyugefamilia, ''));													
						END IF;										
				ELIF icontador <1 THEN
							LET cVarConyuge = "|0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";							
							LET cVarReferencia1 = "0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";	
							LET cVarReferencia2	= "0|0|0|0|||E||0|0|0|0|0|0|0|0|0|0|";			
				END IF; --detalle scoring --JMAH -- SE OBTIENE LA RESPUESTA AL PARAMETRICO QUE SE LE REALIZO AL CLIENTE
				FOREACH WITH HOLD
				SELECT ele.rango_minimo,det.grupo,ele.descripcion
				INTO  iElemento,iGrupo,cDescripElemento
				FROM bdisolic:"informix".ss_detalle_scoring det
				INNER JOIN bdisolic:"informix".ss_scoring_element ele ON ( ele.elemento = det.elemento AND activa = 1 AND det.grupo = ele.grupo)
				WHERE num_solicitud = vnumerosolicituddecredito
				AND det.grupo  IN(11,39,6,8,21) AND det.seccion = 2 AND det.tpo_persona = '01' 	
				
				IF iGrupo = 11 THEN
				 LET vnumerodependientes = iElemento;
				ELIF iGrupo = 39 THEN
				 LET vpersonastrabajan = iElemento;
				ELIF iGrupo = 6 THEN
				  LET cfechadesdecuandovive = YEAR(vfechaaltacliente)-iElemento; 
				  LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||'/01/01';
				ELIF iGrupo = 8 THEN
					IF iElemento = -1 THEN
						SELECT elemento INTO iElemento FROM bdisolic:"informix".ss_detalle_scoring 
						WHERE grupo = 7 AND seccion = 2 AND tpo_persona = '01' AND num_solicitud = vnumerosolicituddecredito;							
						
						IF iElemento = 15 THEN --Estudiante
							LET cfechaantiguedtrab = cfechanac;
							IF NVL(cVarDireccion2,'') = '' THEN 
								LET cVarDireccion2= NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||"0|0|||||0|0|0|0|0|0|0|0|0|0";									
							END IF;
						ELIF iElemento = 12 THEN --Ama de Casa
							LET cfechaantiguedtrab =  cfechadesdecuandovive;
							IF NVL(cVarDireccion2,'') = '' THEN 
								LET cVarDireccion2= NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||"0|0|||||0|0|0|0|0|0|0|0|0|0";	
							END IF;
							LET vlugartrabajo = "";  --INC 27 017 AAME
						ELIF iElemento = 6 OR iElemento = 17 THEN --Desempleado, Jubilado o Pensionado
							LET cfechaantiguedtrab = cfechaaltacte; 	
							IF NVL(cVarDireccion2,'') = '' THEN 
								LET cVarDireccion2= NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||"0|0|||||0|0|0|0|0|0|0|0|0|0";	
							END IF;
						END IF;
					ELSE
						LET cfechaantiguedtrab = YEAR(vfechaaltacliente)-iElemento;	
						LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||'/01/01';
					END IF;					
				ELIF iGrupo = 21 THEN
					IF TRIM(cDescripElemento) = "No EstudiÃ³" THEN
						LET vescolaridad = '1';						
					ELIF TRIM(cDescripElemento) = "Primaria" THEN
						LET  vescolaridad = '2';
					ELIF TRIM(cDescripElemento) = "Secundaria" THEN
						LET vescolaridad = '3';
					ELIF TRIM(cDescripElemento) = "Carrera TÃ©cnica" THEN
						LET vescolaridad = '4';
					ELIF TRIM(cDescripElemento) = "Preparatoria" THEN
						LET vescolaridad = '5';
					ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN
						LET vescolaridad = '6'; 
					END IF;
				END IF;
				END FOREACH;				--INC 27 017 AAME 
				SELECT secuenciaos
				INTO  vfolio
				FROM bdisolic:"informix".ss_solicitud_os
				WHERE empresa = pempresa AND status <> 'P' 
				AND fecha_respuesta IN (SELECT MAX(fecha_respuesta) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito)--= pFechaAct
				AND num_solicitud = vnumerosolicituddecredito;	
				IF NVL(vfolio, '') = '' THEN
							LET vfolio = '0';
				END IF;					
				--SE OBTIENE LA RESPUESTA DE BURO
				SELECT NVL(institucion, ''), fecha_sic INTO cFlagConsBuro, dFechaConsBuro FROM bdisolic:"informix".ss_solicitudes_sic 
				WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito
				AND ROWID = (SELECT MAX(ROWID) FROM bdisolic:"informix".ss_solicitudes_sic WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito);
				IF cFlagConsBuro = 'BC' OR cFlagConsBuro = 'CC' THEN
					LET cBuroPilotoTestig = 'P';
				ELSE
					LET cBuroPilotoTestig = 'T';
				END IF;
				IF NVL(dFechaConsBuro, '') <> '' THEN
					LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
				ELSE
					LET cFechaConsBuro = YEAR(dFechaConsBuro)||"/"||LPAD(MONTH(dFechaConsBuro),2,0)||"/"||LPAD(DAY(dFechaConsBuro),2,0);
				END IF;
				SELECT NVL(COUNT(*), 0) INTO iContConsBuro FROM bdisolic:"informix".ss_solicitudes_sic 
				WHERE numcte = vnumcte AND num_solicitud = vnumerosolicituddecredito;
				IF iContConsBuro <> 0 THEN
					LET cMarcarConsultado = 'CO';
				ELSE
					LET cMarcarConsultado = 'NC';
				END IF;
				--SE OBTIENE LA INFORMACION CONSULTADA DEL CLIENTE EN COPPEL--jmah
				SELECT MAX(ROWID) INTO iRowId FROM bdisolic:"informix".ss_nuevo_parametrico WHERE num_solicitud = vnumerosolicituddecredito;
				SELECT CASE WHEN "informix".sp_EsNumerico(ingreso_mensual) = 'V' THEN ingreso_mensual::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(cap_sistematica_abono) = 'V' THEN cap_sistematica_abono::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(tope_abonocoppel) = 'V' THEN tope_abonocoppel::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(lineacreditotope) = 'V' THEN lineacreditotope::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(capmaxima_abono) = 'V' THEN capmaxima_abono::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(capreal_abono) = 'V' THEN capreal_abono::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(lineacredito_real) = 'V' THEN lineacredito_real::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(compromisossic) = 'V' THEN compromisossic::INTEGER ELSE 0 END, 
				CASE WHEN "informix".sp_EsNumerico(flaglineacreditoesp) = 'V' THEN flaglineacreditoesp::INTEGER ELSE 0 END,
				limitecredito, situacion_especial, case when "informix".sp_EsNumerico(causa_sitesp) = 'V' then causa_sitesp::integer else 0 end,
				puntos_parcn
				INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iFlagLineaCredEsp,
				vlimitecredito,vsituacionespecial, vcausasituacionespecial,iPuntuacion
				FROM bdisolic:"informix".ss_nuevo_parametrico
				WHERE empresa = pempresa AND ROWID = iRowId;
				--AAME 2014-01-06 INC 27 050 
				SELECT ingreso_mensual,evalua_cc ,tp_ingreso INTO iIngreso,cMarcaHit,vtiposueldo FROM bdisolic:"informix".ss_resum_scor_fin WHERE empresa = pempresa AND num_solicitud = vnumerosolicituddecredito;
				IF iIngreso > iTopeMax THEN
					LET iIngreso=iTopeMax;	
					LET iMontoIngMensual=iTopeMax;
				END IF;
				LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
				IF TRIM(NVL(cMarcaHit, '')) = 'X' THEN
					LET cMarcaHit = 'HT';
				ELSE	
					LET cMarcaHit = 'NH';
				END IF;
				IF vingresomensual < 1 THEN
					LET vingresomensual = 1;
				END IF;					
				IF (SELECT NVL(COUNT(*), 0) FROM bdisolic:"informix".ss_os_solautdirecta WHERE num_solicitud = vnumerosolicituddecredito) >= 1 THEN
					LET vsituacionespecial = 'S';
					LET vcausasituacionespecial = 50;					
				END IF;
				-- GENERACION DE LA TRAMA FINAL
				LET vsSQL = TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))||"|"||TRIM(NVL(vcurp, ''))||"|"||TRIM(NVL(vclaveelector, ''))||"|"||TRIM(NVL(vclaveidentificacion, ''))||"|"||TRIM(videntificacion);
				LET vsSQL = vsSQL ||"|"||TRIM(cVarDireccion1);
				LET vsSQL = vsSQL ||"|"||TRIM(NVL(vcasapropia, ''))||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(NVL(vsexo, ''))||"|"||TRIM(NVL(vestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)||"|"||TRIM(NVL(vescolaridad, ''))||"|"||TRIM(NVL(vtiposueldo, ''));
				LET vsSQL = vsSQL ||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)||"|"||NVL(vingresomensual, 0)||"|"||TRIM(NVL(vsituacionespecial, ''))||"|"||NVL(vcausasituacionespecial, 0);
				LET vVarSeccion1= TRIM(vsSQL);
				LET vVarOSCALLE = TRIM(vclaveautrechaza)||"|"||TRIM(vaceptadosupervisadorechazado)||"|"||TRIM(vclientenuevo);
				LET vsSQL = "";
				LET vsSQL= TRIM(NVL(vcreditojoven, ''))||"|"||TRIM(NVL(vlugartrabajo, ''));					
				LET vsSQL = vsSQL ||"|"||TRIM(cVarDireccion2);
				LET vsSQL = vsSQL||"|"||TRIM(NVL(vpuesto,''))||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))||"|"||TRIM(NVL(vclienteconyuge,'0'))||"|"||TRIM(NVL(vnombreunoconyuge, ''))||"|"||TRIM(NVL(vnombredosconyuge, ''))||"|"||TRIM(NVL(vapellidopaternoconyuge, ''))||"|"||TRIM(NVL(vapellidomaternoconyuge, ''))||"|"||TRIM(NVL(cSexoConyuge, ''));							
				LET vsSQL = vsSQL ||"|"||TRIM(cVarConyuge);					
				LET vsSQL = vsSQL ||"|"||TRIM(NVL(vclientereferencia,'0'))||"|"||TRIM(NVL(vnombreunoreferencia, ''))||"|"||TRIM(NVL(vnombredosreferencia, ''))||"|"||TRIM(NVL(vapellidopaternoreferencia, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia, ''))||"|"||TRIM(NVL(cSexoReferencia, ''));
				LET vsSQL = vsSQL ||"|"||TRIM(cVarReferencia1);
				LET vsSQL = vsSQL||"|"||TRIM(NVL(vclientereferencia2,'0'))||"|"||TRIM(NVL(vnombreunoreferencia2, ''))||"|"||TRIM(NVL(vnombredosreferencia2, ''))||"|"||TRIM(NVL(vapellidopaternoreferencia2, ''))||"|"||TRIM(NVL(vapellidomaternoreferencia2, ''))||"|" ||TRIM(NVL(cSexoReferencia2, ''));												
				LET vsSQL = vsSQL ||"|"||TRIM(cVarReferencia2);
				LET vsSQL = vsSQL	||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(vmarcadatosin)||"|"||vtiporeposicion||"|"||vreposicion||"|"||TRIM(vflagentregotarjeta);
				LET vVarSeccion2= TRIM(vsSQL);
				LET vsSQL = "";
				LET vsSQL = vsSQL ||"|"||NVL(vefectuo, 0)||"|"||TRIM(NVL(cFolioSucursal, '0')); 
				LET vVarSeccEfectuo = TRIM(vsSQL);
				LET vsSQL = "";
				LET vsSQL = vsSQL ||"|"||TRIM(NVL(cfechaaltacte, '1900/01/01'))||"|"||TRIM(vflagnoreconocehuella)||"|"||vfoliotienda||"|"||TRIM(NVL(vrfc, ''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)||"|"||TRIM(vfolioconcir)||"|"||vnegocio||"|"||vsubnegocio||"|"   
						||vempleadoautorizo||"|"||TRIM(vtipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||TRIM(NVL(vnumerosolicituddecredito, ''))||"|"||TRIM(NVL(vnumcte, ''));
				LET vVarSeccion3= TRIM(vsSQL);
				LET vVarOSCALLE2 = vtiendafolioanterior||"|"||vfolioanterior;
				LET vsSQL = "";
				LET vsSQL = vclaveproducto||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumempleados||"|"||vSubopcionpuesto||"|"||vPuestoext||"|"||vOpcionpuestoext||"|"
						||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(vTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"
						||iEmpleadoSubCob||"|"||sFlagCapHuella||"|"||cMarcarConsultado||"|"||sFlagTestParametrico||"|"||sFlagCapCobranza;
				LET vVarSeccion4 = TRIM(vsSQL);	
				LET vsSQL = "";
				LET vsSQL = NVL(cFlagConsBuro,'')||"|"||cBuroPilotoTestig||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"
						||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(NVL(cDelegMunicip,''))||"|"||TRIM(NVL(cNumInterior,''))||"|"||sPropNegocio||"|"||sParCelulares||"|"||sParAltoRiesgo||"|"||sParPrestamo||"|"||cModeloCel||"|"
						||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"
						||TRIM(cClienteConyugebcpl)||"|"||TRIM(cClienteReferencia1bcpl)||"|"||TRIM(cClienteReferencia2bcpl);					
				LET vVarSeccion5 = TRIM(vsSQL);					
				LET vsSQL = "";
				LET vsSQL =   vclave||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(vcliente_ref)||"|"||TRIM(NVL(vVarSeccion1, ''))||"|"||TRIM(NVL(vVarOSCALLE, ''))||"|"||TRIM(NVL(vVarSeccion2, ''))||TRIM(vVarSeccEfectuo)||"|"||TRIM( NVL(vfolio,0) )||TRIM(NVL(vVarSeccion3, ''))||"|"||TRIM(NVL(vVarOSCALLE2, ''))||"|"||TRIM(NVL(vVarSeccion4, ''))||"|"||iEmpleadoGteAutori||"|"||TRIM(NVL(vVarSeccion5, ''));
				
				INSERT INTO "informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama, tipomovto, fecha_insert)
				VALUES (pempresa, inumSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);  					
				LET iCuentaRegistros = 1;						
				-- SE OBTIENE EL SIGUIENTE ESTATUS DEL CLIENTE 
				FOREACH 
					--AAME INC 27 046 2013-11-29 
					SELECT  status_solicitud, fecha_entrada,fecha_salida,ejecutivo_auto
					INTO cStatus2, dFechaEntrada,dFechaSalida,cEmpleadoGteAutori
					FROM bdisolic:"informix".ss_autorizacion 
					WHERE empresa=pempresa
					AND num_solicitud = vnumerosolicituddecredito
					AND status_solicitud IN('RT','OS','AT','AP')	
				
					IF 	(dFechaEntrada <> pFechaAct AND cStatus2 <>'OS') THEN
						CONTINUE FOREACH;
					ELIF (dFechaEntrada <> pFechaAct AND cStatus2 ='OS') AND cStatus = 'OA' THEN
						CONTINUE FOREACH;
					ELIF (dFechaSalida <> pFechaAct AND cStatus2 ='OS') THEN
						CONTINUE FOREACH;	
					END IF;					
					IF cStatus = cStatus2 AND dFechaAlta <> pFechaAct THEN						
						CONTINUE FOREACH;					
					END IF;					
					LET inumSecuencia = inumSecuencia + 1;						
					LET vsSQL = "";						
					LET vcliente_ref = "0";
					--SE IDENTIFICA QUE ESTATUS SE OBTUVO PARA COLOCAR VALORES POR DEFAULT
					IF cStatus2 = "RT" OR cStatus2 = "AT" THEN
						LET vClave = 'M';												
						LET vclaveautrechaza = '2';
						LET vaceptadosupervisadorechazado = DECODE(cStatus2,"RT","H","AT","A");					
						LET vclientenuevo = 'N'; 
						LET vVarOSCALLE = vclaveautrechaza||"|"||vaceptadosupervisadorechazado||"|"||vclientenuevo;
						--AAME INC 27 046 2013-11-29 
						LET iEmpleadoGteAutori = 0; 
						--AAME INC 27 081 2014-07-24 
						LET vefectuo=vefectuoMOD;						
					ELIF cStatus2 = "AP" THEN
						LET iEmpleadoGteAutori= cEmpleadoGteAutori::INT8;
						--AAME INC 27 081 2014-07-24 
						LET vefectuo=vefectuoAP;
						LET vClave = 'A';							
						LET vclaveautrechaza = '2';
						LET vaceptadosupervisadorechazado = '';
						LET vclientenuevo = 'N';
						LET vVarOSCALLE = vclaveautrechaza||"|"||vaceptadosupervisadorechazado||"|"||vclientenuevo;
						--AAME INC 27  2015-01-12 Se obtiene numero de cliente titular(secuencia=1)
						SELECT numctecoppel INTO vcliente_ref FROM  "informix".si_adiccoppel WHERE empresa = pempresa AND numcte = vnumcte AND secuencia=1;
					ELSE
						--AAME INC 27 046 2013-11-29 
						LET iEmpleadoGteAutori = 0; 
						LET vtiendafolio = cFolioSucursal;						
						--INI JMAH SE CONSULTA SI SE GENERO UNA OS CALLE PARA LA SOLICITUD EN QUESTION
						SELECT fecha_respuesta, status, secuenciaos
						INTO  vfechaaltacliente, vaceptadosupervisadorechazado, vfolio
						FROM bdisolic:"informix".ss_solicitud_os
						WHERE empresa = pempresa AND status <> 'P' AND fecha_respuesta = pFechaAct
						AND num_solicitud = vnumerosolicituddecredito;							
						IF vfechaaltacliente IS NULL THEN 
							CONTINUE FOREACH;
						END IF;							
						IF NVL(vfolio,0) =  0 THEN							
							LET vfechaaltacliente = YEAR(dFechaAlta)||"/"||LPAD(MONTH(dFechaAlta),2,0)||"/"||LPAD(DAY(dFechaAlta),2,0);
							LET vaceptadosupervisadorechazado = 'P';
							LET vfolio = 0;
						END IF;
						--SI EXISTE MAS DE UN REGISTRO EN LA SS_SOLICITUD_OS SE OBTIENE LA SECUENCIA MAYOR
						IF (SELECT COUNT(num_solicitud) FROM bdisolic:"informix".ss_solicitud_os WHERE num_solicitud = vnumerosolicituddecredito) > 1 THEN
							FOREACH
								SELECT FIRST 1 secuenciaos
								INTO vfolioanterior 
								FROM bdisolic:"informix".ss_solicitud_os
								WHERE num_solicitud = vnumerosolicituddecredito AND secuenciaos < vfolio ORDER BY secuenciaos DESC
							END FOREACH						
							LET vtiendafolioanterior = vtiendafolio;						
						END IF;										
						IF vaceptadosupervisadorechazado = 'R' THEN
							LET vaceptadosupervisadorechazado = 'H';
						END IF;
						LET vclaveautrechaza = '2';							
						LET vclientenuevo = 'N';
						LET vVarOSCALLE = vclaveautrechaza||"|"||vaceptadosupervisadorechazado||"|"||vclientenuevo;
						LET vClave = 'M';
						--AAME INC 27 081 2014-07-24 
						LET vefectuo=vefectuoMOD;															
					END IF;		
					
					LET vVarOSCALLE2 = vtiendafolioanterior||"|"||vfolioanterior;												
					LET vsSQL =   vclave||"|"||vcaja||"|"||TRIM(varea)||"|"||TRIM(NVL(vcliente_ref,'0'))||"|"||TRIM(NVL(vVarSeccion1, ''))||"|"||TRIM(NVL(vVarOSCALLE, ''))||"|"||TRIM(NVL(vVarSeccion2, ''))||TRIM(vVarSeccEfectuo)||"|"||TRIM( NVL(vfolio,0) )||TRIM(NVL(vVarSeccion3, ''))||"|"||TRIM(NVL(vVarOSCALLE2, ''))||"|"||TRIM(NVL(vVarSeccion4, ''))||"|"||iEmpleadoGteAutori||"|"||TRIM(NVL(vVarSeccion5, ''));

					INSERT INTO "informix".si_archivoscopdiario (empresa,secuencia, sucursal, trama,tipomovto, fecha_insert)
					VALUES (pempresa, inumSecuencia, cFolioSucursal, vsSQL, vClave, pFechaAct);						
					

				
				END FOREACH;	
				LET vefectuo=0;
				LET vefectuoMOD =0;
				LET vefectuoAP	=0;				
		ELSE
			LET vCodRetorno = '000003';
			LET iCuentaRegistros = 2;
		END IF;			
		END FOREACH;
	END IF;
	IF inumSecuencia > 0 THEN
		UPDATE "informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia;
	END IF;		
ELSE
	LET vCodRetorno = '000001';
	LET iCuentaRegistros = 2;
END IF;
IF iCuentaRegistros = 1 THEN
	LET vCodRetorno = '000000';
ELIF iCuentaRegistros = 0 THEN
	LET vCodRetorno = '000005';
END IF;
RETURN vCodRetorno;
END
END PROCEDURE
DOCUMENT
'--*************************************************************************',
'--| Procedimiento   : "informix".sp_genera_archivosbatch',
'--| Version         : 1.0',
'--| Creado por      : Jesus Manuel Aguilar, Maria Elena Angulo.',
'--| Fecha creacion  : Febrero de 2013',
'--| Descripcion 	: ReingenierÃ­a sobre la generaciÃ³n de las tramas correspondientes a los archivos batch.',
'--*************************************************************************',
'Descripcion: Se modifica campo numeroextcalle, que cuando este traiga un valor que sobre pase los â32767 y 32767, remplazar por el valor default que en este caso serÃ¡ 0',
'Autor: 95992243 - Trinidad Hernandez',
'BD: bdinteg',
'Fecha: 10/08/2021',
'Solicita: Abraham Narvaez',
'---------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_genera_archivosbatch_prospecto(pempresa CHAR(3), pFechaAct DATE) 
RETURNING CHAR(6) AS cod_ret;		
--DECLARACION DE VARIABLES
DEFINE cNoFm3 CHAR(18);
DEFINE cEmail CHAR(60);
DEFINE cClave,cClaveOS,carea, crumbo, cHabitaen,csexo,cestadocivil,cescolaridad,ctiposueldo,csituacionespecial,cclaveautrechaza,caceptadosupervisadorechazado,cclientenuevo,ccreditojoven,cpuesto,cmarcadatosin , cflagentregotarjeta , cflagnoreconocehuella , ctipo , cTipoOrigen , cBuroPilotoTestig , cModeloCel , cflaguht , cUnidadHabit , cFlagProspecto CHAR(1);
DEFINE scaja,vuhcmanzana,vuhcotros, vuhcandador,vuhcetapa,vuhclote,vuhcedificio,vuhcentrada, vnumerodependientes,vpersonastrabajan, vcausasituacionespecial, vopcionpuesto, vclaveproducto, vSistsegsocial, vTiposueldoext, vNumempleados, vSubopcionpuesto, vPuestoext, vOpcionpuestoext, vNumempleadosext, vSubopcionpuestoext, sPropNegocio, sParCelulares, sParAltoRiesgo, sParPrestamo, vtiporeposicion, vnegocio, vsubnegocio, vtiendafolioanterior, sFlagTestParametrico, sFlagCapCobranza, iFlagLineaCredEsp, sFlagCapHuella,icontador,vingresomensual,sFlag_altadirecta_asupervisar,sNuevo_puntajefinal SMALLINT;
DEFINE vcliente_ref,vlugartrabajo,vlugartrabajoconyuge,vclientereferencia, vnumcte, cClienteConyugebcpl, cClienteReferencia1bcpl , cClienteReferencia2bcpl , vfolio ,  vNumCteProspecto,cNumSolRef CHAR(20);
DEFINE vnombre1,vnombre2,vapell_paterno,vapell_materno,cApellCasada CHAR(26);
DEFINE vciudad,vlimitecredito,vcolonia,vcalle,vpersonasvivenendomicilio,vextensiontrabajo,vflagactualizacion, vreferencia2, vreferencia3, vefectuoAP,vreposicion,vfolioanterior,iMontoIngMensual,  iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal, iCompromisosSic, iSqlErr, iValor, iPuntuacion, iSecuencia,inumSecuencia, iElemento, vciudadbanco, vcoloniabanco, iContConsBuro, iCuentaRegistros,vfoliotienda,iGrupo,icontador2,iIsamErr,iTopeMax, iParAltoRiesgoNvo, iPagoUlt12meses,iRowId,iId_Situaciones,iPuntos_Var_Param,iPuntos_Var_SIC,iScore_domicilio INTEGER;
DEFINE iIngreso DECIMAL(18,2);
DEFINE vdeptointerior,vfolioaut,cNumInterior, cFolioSucursal CHAR(4);
DEFINE vcomplemento CHAR(80);
DEFINE ventrecalles,cErrorInfo,cDescError  CHAR(40);
DEFINE vtelefono, vtelefonocelular,vtelefonotrabajo,inumerocasaaux,iNumerocasa,inumerocasatrabajo,icasarefAux,icasatrabajoconyuge INT8;
DEFINE vfechanacimiento,vfechaaltacliente,vfechamovto, vFecha_Hoy,dFechaAlta DATE;
DEFINE vniptitular,vnipadicional  CHAR(7);
DEFINE vcveburo,cMarcarConsultado,cFlagConsBuro,vTipo_Dir,cMarcaHit, vclaveidentificacion,cStatus ,cStatusbcpl, cStatusPenul, 
cStatusAntp,cPuntualidad_ref1,cPuntualidad_ref2 CHAR(2);
DEFINE cfechanac, cfechadesdecuandovive, cfechaantiguedtrab,cfechaaltacte,vfolioconcir,cFechaConsBuro CHAR(10);
DEFINE vcurp,vclaveelector CHAR(18);
DEFINE videntificacion, cEmpleadoSubCob, cEmpleadoGteAutori, vefectuoMOD,vefectuo CHAR(8);
DEFINE vrfc CHAR(13);
DEFINE vfolioconsulta CHAR(9);
DEFINE cfechamovto,cFecha_hoy CHAR (19);
DEFINE vTipoProducto CHAR(5);
DEFINE cNacionalidad,cPais,cEstado,cDelegMunicip,cMotivobcpl CHAR(3);
DEFINE cNoIMSS CHAR(12);
DEFINE vFechaHora DATETIME  YEAR TO SECOND;
DEFINE vFechaHoraMax DATETIME  YEAR TO SECOND;
DEFINE vFechaHoraP DATETIME  YEAR TO SECOND;
DEFINE cDescripElemento CHAR(50);
DEFINE vNombre CHAR(104);
DEFINE vCodRetorno Char(6);
DEFINE bMovimiento BOOLEAN;
--DIRECCION DEL TRABAJO
DEFINE sestadotrabajo SMALLINT;		
DEFINE sciudadtrabajo SMALLINT;		
DEFINE scoloniatrabajo  SMALLINT;             
DEFINE icalletrabajo INTEGER;                 
DEFINE cdeptoointeriortrabajo CHAR(4);           
DEFINE crumbotrabajo CHAR(1);                   
DEFINE ccomplementotrabajo CHAR(80);             
DEFINE centrecallestrabajo CHAR(40);             
DEFINE sflaguht SMALLINT;                               
DEFINE suhtmanzana SMALLINT;                        
DEFINE suhtotros SMALLINT;                            
DEFINE suhtandador SMALLINT;                          
DEFINE suhtetapa SMALLINT;                             
DEFINE suhtlote SMALLINT;                             
DEFINE suhtedificio SMALLINT;                           
DEFINE suhtentrada SMALLINT;         
--DIRECCION DEL AUXILIAR
DEFINE sestadoaux 			SMALLINT;		
DEFINE sciudadaux 			INTEGER;		
DEFINE scoloniaaux  		INTEGER;             
DEFINE icalleaux 			INTEGER;                 
DEFINE cdeptoointerioraux 	CHAR(4);           
DEFINE crumboaux 			CHAR(1);                   
DEFINE ccomplementoaux 		CHAR(80);             
DEFINE centrecallesaux 		CHAR(40);             
DEFINE sflaguhtaux 			SMALLINT;                               
DEFINE suhtmanzanaaux 		SMALLINT;                        
DEFINE suhtotrosaux 		SMALLINT;                            
DEFINE suhtandadoraux 		SMALLINT;                          
DEFINE suhtetapaaux 		SMALLINT;                             
DEFINE suhtloteaux 			SMALLINT;                             
DEFINE suhtedificioaux 		SMALLINT;                           
DEFINE suhtentradaaux 		SMALLINT;     
--Referencia Conyuge							
DEFINE iclienteconyuge              	INT8;   
DEFINE cnombreunoconyuge            	CHAR(26);  
DEFINE cnombredosconyuge            	CHAR(26);  
DEFINE capellidopaternoconyuge      	CHAR(26);  
DEFINE capellidomaternoconyuge      	CHAR(26);  
DEFINE csexoconyuge                 	CHAR(1);   
DEFINE clugartrabajoconyuge         	CHAR(20);  
DEFINE sciudadconyuge               	SMALLINT;  
DEFINE scoloniaconyuge              	SMALLINT;  
DEFINE icalletrabajoconyuge         	INTEGER;   
DEFINE cdeptoointeriorconyuge       	CHAR(4);   
DEFINE crumbotrabajoconyuge         	CHAR(1);   
DEFINE ccomplementoconyuge          	CHAR(80);  
DEFINE centrecallesconyuge          	CHAR(40);  
DEFINE sflaguhy                     	SMALLINT;  
DEFINE suhymanzana                  	SMALLINT;  
DEFINE suhyotros                    	SMALLINT;  
DEFINE suhyandador                  	SMALLINT;  
DEFINE suhyetapa                    	SMALLINT;  
DEFINE suhylote                     	SMALLINT;  
DEFINE suhyedificio                 	SMALLINT;  
DEFINE suhyentrada                  	SMALLINT;  
DEFINE ctelefonotrabajoconyuge      	CHAR(10);   
DEFINE ctelefonocelularconyuge      	CHAR(10);   
DEFINE cclaveconyugefamilia         	CHAR(1);   
--Referencia Auxiliar
DEFINE ictereferenciaAux			   INT8;  
DEFINE cnombre1refAux         	       CHAR(26); 
DEFINE cnombre2refAux          	       CHAR(26); 
DEFINE capellpatrefAux   		       CHAR(26); 
DEFINE capellmatrefAux    		       CHAR(26); 
DEFINE csexorefAux                     CHAR(1);  
DEFINE sciudadrefAux                   SMALLINT; 
DEFINE scoloniarefAux                  INTEGER; 
DEFINE icallerefAux                    INTEGER;  
DEFINE cdeptoointrefAux     	       CHAR(4);  
DEFINE crumborefAux                    CHAR(1);  
DEFINE ccomplementorefAux              CHAR(80); 
DEFINE centrecallesrefAux              CHAR(40); 
DEFINE sflaguhrAux                     SMALLINT; 
DEFINE suhrmanzanaAux                  SMALLINT; 
DEFINE suhrotrosAux                    SMALLINT; 
DEFINE suhrandadorAux                  SMALLINT; 
DEFINE suhretapaAux                    SMALLINT; 
DEFINE suhrloteAux                     SMALLINT; 
DEFINE suhredificioAux                 SMALLINT; 
DEFINE suhrentradaAux                  SMALLINT; 
DEFINE ctelrefAux           	       CHAR(10);  
DEFINE ctelcelrefAux    		       CHAR(10);  
DEFINE cclaverefAux                    CHAR(1);  
DEFINE cCteRefbcplAux			       CHAR(20);  
--Referencia uno							
DEFINE iclientereferencia           	INT8;   
DEFINE cnombreunoreferencia         	CHAR(26);  
DEFINE cnombredosreferencia         	CHAR(26);  
DEFINE capellidopaternoreferencia   	CHAR(26);  
DEFINE capellidomaternoreferencia   	CHAR(26);  
DEFINE csexoreferencia              	CHAR(1);   
DEFINE sciudadreferencia            	SMALLINT;  
DEFINE scoloniareferencia           	SMALLINT;  
DEFINE 	icallereferencia             	INTEGER;   
DEFINE icasareferencia              	INTEGER;   
DEFINE cdeptoointeriorreferencia    	CHAR(4);   
DEFINE crumboreferencia             	CHAR(1);   
DEFINE ccomplementoreferencia       	CHAR(80);  
DEFINE centrecallesreferencia1      	CHAR(40);  
DEFINE sflaguhr                     	SMALLINT;  
DEFINE suhrmanzana                  	SMALLINT;  
DEFINE suhrotros                    	SMALLINT;  
DEFINE suhrandador                  	SMALLINT;  
DEFINE suhretapa                    	SMALLINT;  
DEFINE suhrlote                     	SMALLINT;  
DEFINE suhredificio                 	SMALLINT;  
DEFINE suhrentrada                  	SMALLINT;  
DEFINE ctelefonoreferencia          	CHAR(10);   
DEFINE ctelefonocelularreferencia   	CHAR(10);   
DEFINE cclavereferencia1            	CHAR(1);   
--Referencia 2
DEFINE iclientereferencia2          	INT8;  
DEFINE cnombreunoreferencia2        	CHAR(26); 
DEFINE cnombredosreferencia2        	CHAR(26); 
DEFINE capellidopaternoreferencia2  	CHAR(26); 
DEFINE capellidomaternoreferencia2  	CHAR(26); 
DEFINE csexoreferencia2             	CHAR(1);  
DEFINE sciudadreferencia2           	SMALLINT; 
DEFINE scoloniareferencia2          	SMALLINT; 
DEFINE icallereferencia2            	INTEGER;  
DEFINE icasareferencia2             	INTEGER;  
DEFINE cdeptoointeriorreferencia2   	CHAR(4);  
DEFINE crumboreferencia2            	CHAR(1);  
DEFINE ccomplementoreferencia2      	CHAR(80); 
DEFINE centrecallesreferencia2      	CHAR(40); 
DEFINE sflaguhr2                    	SMALLINT; 
DEFINE suhrmanzana2                 	SMALLINT; 
DEFINE suhrotros2                   	SMALLINT; 
DEFINE suhrandador2                 	SMALLINT; 
DEFINE suhretapa2                   	SMALLINT; 
DEFINE suhrlote2                    	SMALLINT; 
DEFINE suhredificio2                	SMALLINT; 
DEFINE suhrentrada2                 	SMALLINT; 
DEFINE ctelefonoreferencia2         	CHAR(10);  
DEFINE ctelefonocelularreferencia2  	CHAR(10);  
DEFINE cclavereferencia2            	CHAR(1);   	

DEFINE cObservs				char(80);
DEFINE cTrama LVARCHAR		(32000);
DEFINE vNumCteProspectoAnt	CHAR(20);

DEFINE cClaveOSAnt					CHAR(1);
DEFINE cStatusParam					CHAR(1);
DEFINE cSituacionespecial_aut		CHAR(1);
DEFINE iCausasituacionespecial_aut	SMALLINT;
DEFINE dFechaTemp					DATETIME YEAR TO FRACTION(5);
DEFINE dFechaSupervisar				 DATE;
DEFINE cCanal_origensol    	CHAR(4);   --RQM 09 541-2 CrÃÂ©dito Motos Coppel en Alta ÃÂnica 06/04/2021

--INICIALIZACION DE VARIABLES
LET cClave = '';
LET cClaveOS = '';
LET scaja = 100;
LET carea = 'N';
LET vcliente_ref = '0';
LET vnombre1 = '';
LET vnombre2 = '';
LET vapell_paterno = '';
LET vapell_materno = '';
LET vcurp = '';
LET vclaveelector = '';
LET vclaveidentificacion = '';
LET videntificacion = '';
LET vciudad = 0;
LET vcolonia = 0;
LET vcalle = 0;
LET iNumerocasa = 0;
LET vdeptointerior = '';
LET crumbo = '';
LET vcomplemento = '';
LET ventrecalles = '';
LET vuhcmanzana = 0;
LET vuhcotros = 0;
LET vuhcandador = 0;
LET vuhcetapa = 0; 
LET vuhclote  = 0;
LET vuhcedificio = 0;
LET vuhcentrada = 0;
LET vtelefono = 0;
LET vtelefonocelular = 0;
LET cHabitaen = '';
LET vniptitular = '';
LET vnipadicional = '';
LET csexo = '';
LET cestadocivil = '';
LET cfechanac = '1900/01/01';
LET cfechadesdecuandovive = '1900/01/01';
LET vpersonasvivenendomicilio = 0;
LET cescolaridad = '';
LET ctiposueldo = '';
LET vnumerodependientes = 0;
LET vpersonastrabajan = 0;
LET vlimitecredito = 0;
LET vingresomensual = 0;
LET csituacionespecial = '';
LET vcausasituacionespecial = 0;
LET cclaveautrechaza = '2';
LET caceptadosupervisadorechazado = 'P';
LET cclientenuevo = 'N';
LET ccreditojoven = '';
LET vlugartrabajo = '';
LET vtelefonotrabajo = 0;
LET vextensiontrabajo = 0;
LET cpuesto = '0';
LET vopcionpuesto = 0;
LET cfechaantiguedtrab = '1900/01/01';
LET cSexoConyuge = '';
LET vlugartrabajoconyuge = '';
LET crumbotrabajoconyuge = '';
LET cclaveconyugefamilia = 'E';
LET cSexoReferencia = '';
LET cclavereferencia1 = '';
LET cSexoReferencia2 = '';
LET cclavereferencia2 = '';
LET vreferencia2 = 0;
LET vreferencia3 = 0;
LET cmarcadatosin = '';
LET vtiporeposicion = 0;
LET vreposicion = 0;
LET cflagentregotarjeta = '';
LET vefectuo = 0;
LET vefectuoAP=0;
LET vefectuoMOD=0;
LET vfolio = '0';
LET cfechaaltacte = '1900/01/01';
LET cflagnoreconocehuella = '';
LET vfoliotienda = 0;
LET vrfc = ''; 
LET vcveburo = '';
LET vfolioaut = '';
LET vfolioconsulta = '';
LET vfolioconcir = '';
LET vnegocio = 0;
LET vsubnegocio = 0;
LET ctipo = 'A';
LET cfechamovto = '1900/01/01';
LET vnumcte = '';
LET vtiendafolioanterior = 0;
LET vfolioanterior = 0;
LET vclaveproducto = 6500;
LET vflagactualizacion = 0;
LET vSistsegsocial = 0;
LET vTiposueldoext = 0;
LET vNumempleados = 0;
LET vSubopcionpuesto = 0;
LET vPuestoext = 0;
LET vOpcionpuestoext = 0;
LET vNumempleadosext = 0;
LET vSubopcionpuestoext = 0;
LET cTipoOrigen = 'G';
LET vTipoProducto = '00100';
LET cEmpleadoSubCob = '';
LET sFlagCapHuella = 0;
LET cMarcarConsultado = '';
LET sFlagTestParametrico = 0;
LET sFlagCapCobranza = 0;
LET cEmpleadoGteAutori = 0;
LET cFlagConsBuro = '';
LET cBuroPilotoTestig = '';
LET cNacionalidad = '';
LET cNoFm3 = '';
LET cEmail = '';
LET cApellCasada = '';
LET cPais = '';
LET cNoIMSS = '';
LET cEstado = '';
LET cDelegMunicip = '';
LET cNumInterior = '';
LET sPropNegocio = 0;
LET sParCelulares = 0; 
LET sParAltoRiesgo = 0;
LET sParPrestamo = 0;
LET cModeloCel = '1';
LET cFechaConsBuro = '1900/01/01';
LET iMontoIngMensual = 0; 
LET iCapSistematicabono = 0;
LET iTopeAbonoCoppel = 0;
LET iLineaCrediTope = 0;
LET iCapMaximaAbono = 0;
LET iCapRealAbono = 0;
LET iLineaCredReal = 0;
LET iCompromisosSic = 0;
LET iFlagLineaCredEsp = 0;
LET cClienteConyugebcpl = '';
LET cClienteReferencia1bcpl = '';
LET cClienteReferencia2bcpl = '';
LET cFolioSucursal = '0';
LET cflaguht = '';
LET vfechanacimiento = DATE(1); 
LET vfechaaltacliente = DATE(1);
LET vfechamovto = DATE(1);
LET cUnidadHabit = '';
LET vTipo_Dir = '';
LET vFecha_Hoy = DATE(1);
LET vNombre = '';
LET vCodRetorno = '000000';
LET dFechaAlta = DATE(1);
LET iValor = 0;
LET iTopeMax=0;
LET iIngreso = 0;
LET iPuntuacion = 0;
LET cFecha_hoy = '1900/01/01';
LET iSecuencia = 0;
LET inumSecuencia= 0;
LET cMarcaHit = '';
LET iElemento = 0;
LET vciudadbanco = 0;
LET vcoloniabanco = 0;
LET iContConsBuro = 0;
LET cDescripElemento = '';
LET iCuentaRegistros = 0;
LET cStatus = '';
LET icontador = 0;
LET icontador2 = 0;
LET cNumSolRef='';
LET cErrorInfo='';
LET iIsamErr='';
LET cDescError='';
LET cStatusbcpl= "";
LET cMotivobcpl="";
LET cFlagProspecto="";
LET iParAltoRiesgoNvo=-99999;
LET iPagoUlt12meses=99999;
LET vFechaHora = "";
LET vFechaHoraMax = "";
LET cStatusPenul='';
LET cStatusAntp='';
LET vFechaHoraP = "";
LET bMovimiento="F";
LET vNumCteProspecto='';
LET cClave='';
--direccion del trabajo
LET sestadotrabajo			= 0;
LET sciudadtrabajo			= 0;
LET scoloniatrabajo			= 0;
LET icalletrabajo 			= 0;
LET inumerocasatrabajo 		=0;
LET cdeptoointeriortrabajo 	= '';
LET crumbotrabajo			='';
LET ccomplementotrabajo		='';
LET centrecallesTrabajo		='';
LET sflaguht				=0;
LET suhtmanzana				=0;
LET suhtotros				=0;
LET suhtandador				=0;
LET suhtetapa				=0;
LET suhtlote				=0;
LET suhtedificio			=0;
LET suhtentrada				=0;				
-- Direccion Auxiliar
LET sestadoaux 			= 0;
LET sciudadaux 			= 0;
LET scoloniaaux  		= 0;
LET icalleaux 			= 0;
LET inumerocasaaux 		= 0;
LET cdeptoointerioraux 	= '';
LET crumboaux 			='';
LET ccomplementoaux 	='';	
LET centrecallesaux 	='';	
LET sflaguhtaux 		= 0;	
LET suhtmanzanaaux 		= 0;
LET suhtotrosaux 		= 0;
LET suhtandadoraux 		= 0;
LET suhtetapaaux 		= 0;
LET suhtloteaux 		= 0;	
LET suhtedificioaux 	= 0;	
LET suhtentradaaux 		= 0;		
--Referencia Conyuge							
LET iclienteconyuge              	       = 0;
LET cnombreunoconyuge            	       = '';
LET cnombredosconyuge            	       = '';
LET capellidopaternoconyuge      	       = '';
LET capellidomaternoconyuge      	       = '';
LET csexoconyuge                 	       = '';
LET clugartrabajoconyuge         	       = '';
LET sciudadconyuge               	       = 0;
LET scoloniaconyuge              	       = 0;
LET icalletrabajoconyuge         	       = 0;
LET icasatrabajoconyuge          	       = 0;
LET cdeptoointeriorconyuge       	       = '';
LET crumbotrabajoconyuge         	       = '';
LET ccomplementoconyuge          	       = '';
LET centrecallesconyuge          	       = '';
LET sflaguhy                     	       = 0;
LET suhymanzana                  	       = 0;
LET suhyotros                    	       = 0;
LET suhyandador                  	       = 0;
LET suhyetapa                    	       = 0;
LET suhylote                     	       = 0;
LET suhyedificio                 	       = 0;
LET suhyentrada                  	       = 0;
LET ctelefonotrabajoconyuge      	       = 0;
LET ctelefonocelularconyuge      	       = '0';
LET cclaveconyugefamilia         	       = '';
--Referencia uno					       
LET iclientereferencia           	       = 0;
LET cnombreunoreferencia         	       = '';
LET cnombredosreferencia         	       = '';
LET capellidopaternoreferencia   	       = '';
LET capellidomaternoreferencia   	       = '';
LET csexoreferencia              	       = '';
LET sciudadreferencia            	       = 0;
LET scoloniareferencia           	       = 0;
LET icallereferencia             	       = 0;
LET icasareferencia              	       = 0;
LET cdeptoointeriorreferencia    	       = '';
LET crumboreferencia             	       = '';
LET ccomplementoreferencia       	       = 'E';
LET centrecallesreferencia1      	       = '';
LET sflaguhr                     	       = 0;
LET suhrmanzana                  	       = 0;
LET suhrotros                    	       = 0;
LET suhrandador                  	       = 0;
LET suhretapa                    	       = 0;
LET suhrlote                     	       = 0;
LET suhredificio                 	       = 0;
LET suhrentrada                  	       = 0;
LET ctelefonoreferencia          	       = '0';
LET ctelefonocelularreferencia   	       = '0';
LET cclavereferencia1            	       = '';  
--Referencia 2                            
LET iclientereferencia2          	       = 0;
LET cnombreunoreferencia2        	       = '';
LET cnombredosreferencia2        	       = '';
LET capellidopaternoreferencia2  	       = '';
LET capellidomaternoreferencia2  	       = '';
LET csexoreferencia2             	       = '';
LET sciudadreferencia2           	       = 0;
LET scoloniareferencia2          	       = 0;
LET icallereferencia2            	       = 0;
LET icasareferencia2             	       = 0;
LET cdeptoointeriorreferencia2   	       = '';
LET crumboreferencia2            	       = '';
LET ccomplementoreferencia2      	       = 'E';
LET centrecallesreferencia2      	       = '';
LET sflaguhr2                    	       = 0;
LET suhrmanzana2                 	       = 0;
LET suhrotros2                   	       = 0;
LET suhrandador2                 	       = 0;
LET suhretapa2                   	       = 0;
LET suhrlote2                    	       = 0;
LET suhredificio2                	       = 0;
LET suhrentrada2                 	       = 0;
LET ctelefonoreferencia2         	       = '0';
LET ctelefonocelularreferencia2  	       = '0';
LET cclavereferencia2            	       = '';
--Ref Auxiliar
LET ictereferenciaAux		       = 0;
LET cnombre1refAux        	       = '';
LET cnombre2refAux        	       = '';
LET capellpatrefAux   		       = '';
LET capellmatrefAux    		       = '';
LET csexorefAux           	       = '';
LET sciudadrefAux         	       = 0;	
LET scoloniarefAux        	       = 0;	
LET icallerefAux          	       = 0;	
LET icasarefAux           	       = 0;	
LET cdeptoointrefAux     	       = '';
LET crumborefAux          	       = '';
LET ccomplementorefAux    	       = '';
LET centrecallesrefAux    	       = '';
LET sflaguhrAux           	       = 0;	
LET suhrmanzanaAux        	       = 0;	
LET suhrotrosAux          	       = 0;	
LET suhrandadorAux        	       = 0;
LET suhretapaAux          	       = 0;	
LET suhrloteAux           	       = 0;	
LET suhredificioAux       	       = 0;
LET suhrentradaAux        	       = 0;	
LET ctelrefAux           	       = '';	
LET ctelcelrefAux    		       = '';	
LET cclaverefAux          	       = '';
LET cCteRefbcplAux         	       = '';
LET iId_Situaciones				   = 0;
LET cPuntualidad_ref1              = '';
LET cPuntualidad_ref2			   = '';
LET sFlag_altadirecta_asupervisar  = 0;
LET iPuntos_Var_Param			   = 0;
LET iPuntos_Var_SIC				   = 0;
LET iScore_domicilio			   = 0;
LET sNuevo_puntajefinal			   = 0;
LET iRowId 						   = 0;
LET cObservs = '';
LET cTrama = '';

LET vNumCteProspectoAnt = '';
LET cClaveOSAnt = '';
LET cStatusParam = '';

LET cSituacionespecial_aut ='';
LET iCausasituacionespecial_aut =0;
LET dFechaTemp = current;
LET dFechaSupervisar = DATE(1); 
LET cCanal_origensol='';   --RQM 09 541-2 CrÃÂ©dito Motos Coppel en Alta ÃÂnica 06/04/2021

SET ISOLATION TO DIRTY READ;
	BEGIN
		ON EXCEPTION
		SET iSqlErr,iIsamErr,cErrorInfo
		--SET DEBUG FILE TO '/RESPALDOS/sp_generaarchivosbatch.out';
		--TRACE ON;
				LET vNumCteProspecto = vNumCteProspecto;
			IF iSqlErr <> 0 THEN
				LET vCodRetorno = iSqlErr;
				LET cDescError= cErrorInfo;
                IF NOT EXISTS(SELECT numerosolicitud FROM "informix".si_bitacora_errorbatch where numerosolicitud = vNumCteProspecto and numcte = vnumcte) THEN
					INSERT INTO "informix".si_bitacora_errorbatch (numerosolicitud,numcte,error,observaciones,trama,fecha_insert) VALUES (vNumCteProspecto,vnumcte,iSqlErr,cObservs,cTrama,NVL(vFecha_Hoy,DATE(1)));
					RETURN vCodRetorno; --DSB20210705				  
				END IF 
		END IF;
	END EXCEPTION  WITH RESUME;
	
	SET LOCK MODE TO WAIT 3;
	--SET DEBUG FILE TO "/tmp/Victor/sp_genera_archivosbatch_prospecto.out";
	--TRACE ON;
	
	    
	IF pFechaAct <> MDY(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		SELECT fecha_hoy INTO vFecha_Hoy FROM "informix".si_fechas WHERE empresa = '001';
		IF vFecha_Hoy = MDY(1,1,1900) OR vFecha_Hoy IS NULL THEN
				LET vCodRetorno = '000002';
			ELSE	
				UPDATE STATISTICS MEDIUM FOR TABLE bdinteg:"informix".si_archivoscopdiario;
				SELECT secuencia_max INTO inumSecuencia FROM bdinteg:"informix".si_archivosecuenciamax where empresa = '001' and secuencia_max = secuencia_max;
				--SE OBTIENE VALOR DE SALARIOS MINIMOS
				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
				INTO iValor FROM bdisolic:"informix".ss_param WHERE secuencia = 363;
				--SE OBTIENE VALOR DE TOPE MAXIMO DE INGRESO MENSUAL --2013-12-06 RQI 27 096 AAME										
				SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(valor) = 'V' THEN valor::INTEGER ELSE 0 END 
				INTO iTopeMax FROM bdisolic:"informix".ss_param WHERE secuencia = 373;

                LET cObservs = TRIM('Paso 85');
				FOREACH WITH HOLD
					SELECT sss.numcte_pros, sss.numcte, ssa.fecha_entrada, sss.sucursal, sss.fecha_insert,ssa.status_solicitud,
					ssa.ejecutivo_auto,sss.user_insert, ssa.fecha_hora, sss.emp_cob_alta,
					sss.nombre1, sss.nombre2, sss.apell_paterno, sss.apell_materno, sss.rfc,
					CASE WHEN bdinteg:"informix".sp_EsNumerico(string2) = 'V' THEN string2:: INTEGER ELSE 0 END,
					CASE WHEN ssa.status_solicitud = 'PC' THEN '' ELSE 'M' END,
					CASE WHEN ssa.status_solicitud IN('RT','CN') THEN causa_solicitud ELSE '' END,
					CASE WHEN ssa.status_solicitud IN ('PC','EC','AN','CE','CN','EE') THEN '' ELSE
					DECODE (ssa.status_solicitud,'AT','A','OA','D','OS','P','RT','H')
					END,
					CASE WHEN sss.id_empcob = 0 THEN 0 ELSE 1 END,
					CASE WHEN sss.id_empcob = 0 THEN 2 ELSE 3 END,
					ssa.situacion_especial, ssa.causa_situacion --prueba
					INTO vNumCteProspecto, vnumcte, vfechaaltacliente, cFolioSucursal, dFechaAlta,cStatus,cEmpleadoGteAutori,vefectuoMOD, 
					vFechaHora,cEmpleadoSubCob,vnombre1,vnombre2, vapell_paterno, vapell_materno, vrfc, vpersonasvivenendomicilio,cClave,cMotivobcpl
					,cStatusbcpl, sFlagCapCobranza, cFlagProspecto,
					csituacionespecial_aut, icausasituacionespecial_aut 
					FROM bdiprospectos:"informix".pr_autorizacion ssa
					LEFT JOIN bdiprospectos:"informix".pr_cliente sss
					ON sss.numcte_pros = ssa.num_solicitud
					WHERE ssa.fecha_entrada =  pFechaAct
					AND sss.empresa = ssa.empresa
					AND sss.tipo_cliente="3"
					AND sss.empresa = pempresa
					
					IF LEFT(vNumCteProspecto,1) = 'P' THEN
						LET cTipoOrigen = 'N';
					END IF;				
					
					LET inumSecuencia = inumSecuencia + 1;	
					
				--SE OBTIENEN LOS DATOS DEL PROSPECTO
				IF vNumCteProspectoAnt <> vNumCteProspecto  THEN
					
					LET vNumCteProspectoAnt = vNumCteProspecto;
					LET cfechamovto = vFechaHora;
					LET cObservs = TRIM('Paso 86');
					LET vcliente_ref = "0";
					LET cclaveconyugefamilia='';
					LET cSexoConyuge='';
					LET cclavereferencia1='';
					LET cSexoReferencia='';
					LET icontador = 0;
					LET vlugartrabajo = '';
					LET vlugartrabajoconyuge = '';
					LET iSecuencia=0;
					LET cEstado='';
					LET sParCelulares=0;
					LET sParAltoRiesgo=0;
					LET sParPrestamo=0;
					LET cNumSolRef = '';					
					LET cpuesto = '0';
					--CONSULTA LA INFORMACION DE LA DIRECCION DEL CLIENTE
					LET cObservs = TRIM('Paso 87');
					SELECT estado_civil,  habita_en, sexo, fecha_nac, nacionalidad, curp, codidentifi,numidentifi,no_fm3,no_imss
					INTO cestadocivil, cHabitaen, csexo, vfechanacimiento,cNacionalidad,vcurp,vclaveidentificacion,videntificacion,cNoFm3,cnoimss
					FROM bdiprospectos:"informix".pr_ctepf
					WHERE numcte_pros = vNumCteProspecto;
					LET cObservs = TRIM('Paso 88');
					SELECT NVL(correo_elec,"") INTO cEmail 
					FROM bdiprospectos:"informix".pr_correos 
					WHERE numcte_pros = vNumCteProspecto 
					AND status_correo = "A";
					
					IF cEmail IS NULL THEN 
						LET cEmail="";
					END IF;
					
					--DIRECCION Y TELEFONO
					FOREACH WITH HOLD
						SELECT CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerociudad) = "V" THEN dir.numerociudad::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocolonia) = "V" THEN dir.numerocolonia::INTEGER ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numerocalle) = "V" THEN dir.numerocalle::INTEGER ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.numeroextcalle) = "V" THEN dir.numeroextcalle::INT8 ELSE 0 END,
						NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,"|"," "),"//","/")),""),dir.puntocardinal,
						NVL(TRIM(REPLACE(REPLACE(dir.observaciones,"|"," "),"//","/")),""),NVL(TRIM(REPLACE(REPLACE(dir.entre_calles,"|"," "),"//","/")),""), 
						DECODE (dir.unidadhabitac,"S","1","0"), 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.manzana) = "V" THEN dir.manzana::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.otros) = "V" THEN dir.otros::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.andador) = "V" THEN dir.andador::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.etapa) = "V" THEN dir.etapa::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.lote ) = "V" THEN dir.lote::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.edificio) = "V" THEN dir.edificio::SMALLINT ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(dir.entrada) = "V" THEN dir.entrada::SMALLINT ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel1.telefono,0)) = "V" THEN tel1.telefono::INT8 ELSE 0 END, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel2.telefono,0)) = "V" THEN tel2.telefono::INT8 ELSE 0 END, 
						dir.tipo_dir,NVL(TRIM(REPLACE(REPLACE(dir.numerointcalle,"|"," "),"//","/")),""), dir.estado, 
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel3.telefono,0)) = "V" THEN tel3.telefono::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(tel3.extension,0)) = "V" THEN tel3.extension::INTEGER ELSE 0 END,
						pais
						INTO  vciudadbanco, vcoloniabanco, icalleaux, inumerocasaaux, cdeptoointerioraux, crumboaux, ccomplementoaux, centrecallesaux, sflaguhtaux, 
						suhtmanzanaaux,suhtotrosaux,suhtandadoraux, suhtetapaaux, suhtloteaux, suhtedificioaux, suhtentradaaux, 
						vtelefono, vtelefonocelular, vTipo_Dir, cNumInterior, sestadoaux,vtelefonotrabajo,vextensiontrabajo,cpais
						FROM bdiprospectos:"informix".pr_direcciones_actual dir
						LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel1 
						ON ( tel1.numcte_pros = dir.numcte_pros AND tel1.tipo_tel = 1 AND tel1.status_tel="A")
						LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel2 
						ON ( tel2.numcte_pros = dir.numcte_pros AND tel2.tipo_tel = 2 AND tel2.status_tel="A")
						LEFT OUTER JOIN bdiprospectos:"informix".pr_telefonos tel3 ON ( tel3.numcte_pros = dir.numcte_pros AND tel3.tipo_tel = 3 )
						WHERE dir.numcte_pros = vNumCteProspecto AND dir.tipo_dir IN ("1" ,"2")
						AND dir.secuencia = (SELECT MAX(dir2.secuencia) FROM bdiprospectos:"informix".pr_direcciones_actual dir2 
											WHERE dir2.numcte_pros = vNumCteProspecto AND dir2.tipo_dir = dir.tipo_dir)
						ORDER BY dir.tipo_dir DESC
						
						LET cObservs = TRIM('Paso 89');
						--SE OBTIENE DEL ESTADO
						LET cEstado = sestadoaux;
						
						LET cObservs = TRIM('Paso 90');
						-- SE OBTIENE EL NOMBRE DE LA CIUDAD Y COLONIA
						SELECT {+INDEX(bdinteg:"informix".si_catzonas idx_catzonass)} numerociudadcoppel,numerocoloniacoppel
						INTO sciudadaux, scoloniaaux
						FROM bdinteg:"informix".si_catzonas
						WHERE numerociudad = vciudadbanco AND numerocolonia = vcoloniabanco;
						LET cObservs = TRIM('Paso 91');
						--SI NO EXISTEN LA CIUDAD Y COLONIA, SE TOMARA DE LA SUCURSAL
						--SELECT ciudad INTO vciudadbanco FROM bdinteg:"informix".si_sucursales WHERE sucursal = cFolioSucursal;
						SELECT cve_ciudad INTO vciudadbanco FROM bdinteg:"informix".si_ptf WHERE id_ptf = cFolioSucursal AND tipo='S';
						IF NVL(sciudadaux, 0) = 0 THEN
							SELECT FIRST 1 numerociudadcoppel INTO sciudadaux FROM bdinteg:"informix".si_catzonas 
							WHERE numerociudad = vciudadbanco;
							IF NVL(sciudadaux, 0) = 0 THEN
									SELECT FIRST 1 numerociudadcoppel INTO sciudadaux FROM bdinteg:"informix".si_catzonas 
									WHERE numerociudadcoppel <> 0;
							END IF;
						END IF;
						IF NVL(scoloniaaux, 0) = 0 THEN
							SELECT FIRST 1 numerocoloniacoppel INTO scoloniaaux FROM bdinteg:"informix".si_catzonas 
							WHERE numerociudad = vciudadbanco;
							IF NVL(scoloniaaux, 0) = 0 THEN
								SELECT FIRST 1 numerocoloniacoppel INTO scoloniaaux FROM bdinteg:"informix".si_catzonas 
								WHERE numerocoloniacoppel <> 0;
							END IF;
						END IF;
	  
						IF inumerocasaaux > 32767 THEN
							LET inumerocasaaux = 0;
						END IF;
						
						IF vTipo_Dir ="1" THEN
							LET cObservs = TRIM('Paso 92');
							LET vciudad			= NVL(sciudadaux,0);
							LET vcolonia		= NVL(scoloniaaux,0);
							LET vcalle 			= NVL(icalleaux,0);
							LET iNumerocasa 	= DECODE (NVL(inumerocasaaux,0),0,1,inumerocasaaux);
							LET vdeptointerior 	= NVL(cdeptoointerioraux,'');
							LET crumbo			= NVL(crumboaux,'');
							LET vcomplemento	= DECODE (NVL(ccomplementoaux,''),'','E',ccomplementoaux);
							LET ventrecalles	= NVL(centrecallesaux,'');
							LET cUnidadHabit	= NVL(sflaguhtaux,0);
							LET vuhcmanzana		= NVL(suhtmanzanaaux,0);
							LET vuhcotros		= NVL(suhtotrosaux,0);
							LET vuhcandador		= NVL(suhtandadoraux,0);
							LET vuhcetapa		= NVL(suhtetapaaux,0);
							LET vuhclote		= NVL(suhtloteaux,0);
							LET vuhcedificio	= NVL(suhtedificioaux,0);
							LET vuhcentrada		= NVL(suhtentradaaux,0);
						ELIF vTipo_Dir ="2" THEN
							LET cObservs = TRIM('Paso 93');
							LET sestadotrabajo			= NVL(sestadoaux,0);
							LET sciudadtrabajo			= NVL(sciudadaux,0);
							LET scoloniatrabajo			= NVL(scoloniaaux,0);
							LET icalletrabajo 			= NVL(icalleaux,0);
							LET inumerocasatrabajo 		= DECODE (NVL(inumerocasaaux,0),0,1,inumerocasaaux);
							LET cdeptoointeriortrabajo 	= NVL(cdeptoointerioraux,'');
							LET crumbotrabajo			= NVL(crumboaux,'');
							LET ccomplementotrabajo		= DECODE (NVL(ccomplementoaux,''),'','E',ccomplementoaux);
							LET centrecallesTrabajo		= NVL(centrecallesaux,'');
							LET sflaguht				= NVL(sflaguhtaux,0);
							LET suhtmanzana				= NVL(suhtmanzanaaux,0);
							LET suhtotros				= NVL(suhtotrosaux,0);
							LET suhtandador				= NVL(suhtandadoraux,0);
							LET suhtetapa				= NVL(suhtetapaaux,0);
							LET suhtlote				= NVL(suhtloteaux,0);
							LET suhtedificio			= NVL(suhtedificioaux,0);
							LET suhtentrada				= NVL(suhtentradaaux,0);
						END IF;
					END FOREACH;
					
					--INGRESOS DEL CLIENTE 
					LET cObservs = TRIM('Paso 94');
					SELECT ing.nombre_empresa, 
					CASE WHEN "informix".sp_EsNumerico(ing.claveopcionpuesto) = "V" THEN ing.claveopcionpuesto::SMALLINT ELSE 0 END,
					CASE WHEN "informix".sp_EsNumerico(ing.clavesubopcionpuesto) = "V" THEN ing.clavesubopcionpuesto::SMALLINT ELSE 0 END, 
					puesto
					INTO vlugartrabajo, vopcionpuesto, vSubopcionpuesto,cPuesto
					FROM bdiprospectos:"informix".pr_ingresos ing
					WHERE ing.numcte_pros = vNumCteProspecto
					AND ing.sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos 
					WHERE numcte_pros = vNumCteProspecto AND tipo_ingreso = "T");
					
					LET cObservs = TRIM('Paso 95');
					LET vopcionpuesto = NVL(vopcionpuesto,0);
					LET vSubopcionpuesto=NVL(vSubopcionpuesto,0);
					
					--SE CAMBIA EL FORMATO DE LA FECHA NACIMIENTO, EL ALTA DEL CLIENTE Y OBTENCION DE FECHA DE MOVIMIENTOS
					IF vfechanacimiento >= DATE(1) THEN --DSB20180621
						LET cfechanac = YEAR(vfechanacimiento)||"/"||LPAD(MONTH(vfechanacimiento),2,0)||"/"||LPAD(DAY(vfechanacimiento),2,0);
					ELSE
						LET cfechanac = '1900/01/01';
					END IF;
					LET cfechaaltacte = YEAR(dFechaAlta)||"/"||LPAD(MONTH(dFechaAlta),2,0)||"/"||LPAD(DAY(dFechaAlta),2,0);
					
					LET cFecha_hoy = YEAR(pFechaAct)||"/"||LPAD(MONTH(pFechaAct),2,0)||"/"||LPAD(DAY(pFechaAct),2,0);
					LET cClienteConyugebcpl = '';
					LET cClienteReferencia1bcpl = '';
					LET cClienteReferencia2bcpl = '';
					LET cObservs = TRIM('Paso 96');
					/*
					--SE OBTIENE NUMERO DE SOLICITUD DE BANCO PARA OBTENER SUS REFERENCIAS EN CASO DE QUE A LA SOLICITUD COPPEL NO SE LE HAYAN HEREDADO POR HABER SIDO RECHAZADA ANTES.
					IF NVL(vnumcte,'') <> "" THEN 
						SELECT MAX(num_solicitud)
						INTO cNumSolRef
						FROM bdisolic:"informix".ss_solicitudes
						WHERE empresa = pempresa
						AND numcte = vnumcte
						AND fecha_insert = dFechaAlta
						AND num_producto = '6001'
						AND status_solicitud NOT IN ('AN','PC');
						
						IF NVL(cNumSolRef,'') = '' THEN
							LET cNumSolRef = '';
						END IF;
					END IF;
					*/
					LET icontador2= 0;
					
					--DATOS REFERENCIAS
					LET cObservs = TRIM('Paso 97');
					FOREACH WITH HOLD
						SELECT cts.numcte_banco,CASE WHEN bdinteg:"informix".sp_EsNumerico(cts.numcte_ref) = "V" THEN cts.numcte_ref::INT8 ELSE 0 END,cts.nombre1,cts.nombre2,cts.apell_paterno,cts.apell_materno,cts.parentesco,cts.sexo,cts.secuencia,
						dirf.numerociudad,dirf.numerocolonia,dirf.numerocalle,CASE WHEN bdinteg:"informix".sp_EsNumerico(dirf.numeroextcalle) = "V" THEN dirf.numeroextcalle::INT8 ELSE 0 END,dirf.numerointcalle,dirf.puntocardinal,dirf.observaciones,
						dirf.entre_calles,DECODE (dirf.unidadhabitac,'S',1,0),dirf.manzana,dirf.otros,dirf.andador,dirf.etapa,dirf.lote,dirf.edificio,
						dirf.entrada,CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(dirf.telefono1,0)) = 'V' THEN dirf.telefono1::INT8 ELSE 0 END,CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(dirf.telefono2,0)) = 'V' THEN dirf.telefono2::INT8 ELSE 0 END,
						CASE WHEN bdinteg:"informix".sp_EsNumerico(NVL(dirf.telefono3,0)) = 'V' THEN dirf.telefono3::INT8 ELSE 0 END
						INTO cCteRefbcplAux, ictereferenciaAux, cnombre1refAux, cnombre2refAux, capellpatrefAux, capellmatrefAux, cclaverefAux, csexorefAux,isecuencia,
						sciudadrefAux, scoloniarefAux, icallerefAux, icasarefAux, cdeptoointrefAux, crumborefAux, ccomplementorefAux, centrecallesrefAux, sflaguhrAux,
						suhrmanzanaAux, suhrotrosAux, suhrandadorAux, suhretapaAux, suhrloteAux, suhredificioAux, suhrentradaAux, ctelrefAux, ctelcelrefAux,
						ctelefonotrabajoconyuge
						FROM bdiprospectos:"informix".pr_refclientes cts,
							 bdiprospectos:"informix".pr_refdirecciones dirf
						WHERE cts.empresa = pempresa
						AND cts.numcte_pros = TRIM(vNumCteProspecto) -- numero de cliente prospecto Variable
						AND dirf.numcte_pros = cts.numcte_pros
						and dirf.secuencia = cts.secuencia
						ORDER BY cts.secuencia DESC
						
						LET cObservs = TRIM('Paso 98');
						LET icontador2= icontador2 + 1;
						IF icasarefAux > 32767 THEN
							LET icasarefAux = 0;
						END IF;
						
						IF (cestadocivil = 'C' OR cestadocivil = 'U') AND cclaverefAux = 'E' THEN
							LET cObservs = TRIM('Paso 99');
							--Referencia Conyuge
							LET cClienteConyugebcpl		= TRIM(NVL(cCteRefbcplAux,''));
							LET iclienteconyuge			= NVL(ictereferenciaAux,0);
							LET cnombreunoconyuge		= TRIM(NVL(cnombre1refAux,''));
							LET cnombredosconyuge		= TRIM(NVL(cnombre2refAux,''));
							LET capellidopaternoconyuge	= TRIM(NVL(capellpatrefAux,''));
							LET capellidomaternoconyuge	= TRIM(NVL(capellmatrefAux,''));
							LET csexoconyuge			= TRIM(NVL(csexorefAux,''));     
							LET clugartrabajoconyuge	= ''; -- pendiente 
							LET sciudadconyuge			= NVL(sciudadrefAux,0);
							LET scoloniaconyuge			= NVL(scoloniarefAux,0);
							LET icalletrabajoconyuge	= NVL(icallerefAux,0);
							LET icasatrabajoconyuge		= DECODE(NVL(icasarefAux,0),0,1,icasarefAux);
							LET cdeptoointeriorconyuge	= TRIM(NVL(cdeptoointrefAux,''));
							LET crumbotrabajoconyuge	= TRIM(NVL(crumborefAux,''));
							LET ccomplementoconyuge		= TRIM(NVL(ccomplementorefAux,''));
							LET centrecallesconyuge		= TRIM(NVL(centrecallesrefAux,''));
							LET sflaguhy				= NVL(sflaguhrAux,0);
							LET suhymanzana				= NVL(suhrmanzanaAux,0);
							LET suhyotros				= NVL(suhrotrosAux,0);
							LET suhyandador				= NVL(suhrandadorAux,0);
							LET suhyetapa				= NVL(suhretapaAux,0);
							LET suhylote				= NVL(suhrloteAux,0);
							LET suhyedificio			= NVL(suhredificioAux,0);
							LET suhyentrada				= NVL(suhrentradaAux,0);
							LET ctelefonotrabajoconyuge	= ctelefonotrabajoconyuge;
							LET ctelefonocelularconyuge	= TRIM(NVL(ctelcelrefAux,'0'));
							LET cclaveconyugefamilia	= TRIM(cclaverefAux);
						ELif icontador2 = 2 AND cclaverefAux <> 'E' THEN -- referencia 1
							LET cObservs = TRIM('Paso 100');
							--Referencia uno cuando no es conyuge
							LET cClienteReferencia1bcpl		= TRIM(NVL(cCteRefbcplAux,''));
							LET iclientereferencia			= NVL(ictereferenciaAux,0);
							LET cnombreunoreferencia		= TRIM(NVL(cnombre1refAux,''));
							LET cnombredosreferencia		= TRIM(NVL(cnombre2refAux,''));
							LET capellidopaternoreferencia	= TRIM(NVL(capellpatrefAux,''));
							LET capellidomaternoreferencia	= TRIM(NVL(capellmatrefAux,''));
							LET csexoreferencia				= TRIM(NVL(csexorefAux,''));
							LET sciudadreferencia			= NVL(sciudadrefAux,0);
							LET scoloniareferencia			= NVL(scoloniarefAux,0);
							LET icallereferencia			= NVL(icallerefAux,0);
							LET icasareferencia				= NVL(icasarefAux,0);
							LET cdeptoointeriorreferencia	= TRIM(NVL(cdeptoointrefAux,''));
							LET crumboreferencia			= TRIM(NVL(crumborefAux,''));
							LET ccomplementoreferencia		= TRIM(NVL(ccomplementorefAux,''));
							LET centrecallesreferencia1		= TRIM(NVL(centrecallesrefAux,'')); 
							LET sflaguhr					= NVL(sflaguhrAux,0);
							LET suhrmanzana					= NVL(suhrmanzanaAux,0);
							LET suhrotros					= NVL(suhrotrosAux,0);
							LET suhrandador					= NVL(suhrandadorAux,0);
							LET suhretapa					= NVL(suhretapaAux,0);
							LET suhrlote					= NVL(suhrloteAux,0);
							LET suhredificio				= NVL(suhredificioAux,0);
							LET suhrentrada					= NVL(suhrentradaAux,0);
							LET ctelefonoreferencia			= NVL(ctelrefaux,'0');
							LET ctelefonocelularreferencia	= NVL(ctelcelrefAux,'0');
							LET cclavereferencia1			= TRIM(cclaverefAux);
						ELif icontador2 = 1 AND cclaverefAux <> 'E' THEN -- referencia 2
							LET cObservs = TRIM('Paso 101');
							--Referencia 2
							LET cClienteReferencia2bcpl		= TRIM(NVL(cCteRefbcplAux,''));
							LET iclientereferencia2			= NVL(ictereferenciaAux,0);
							LET cnombreunoreferencia2		= TRIM(NVL(cnombre1refAux,''));
							LET cnombredosreferencia2		= TRIM(NVL(cnombre2refAux,''));
							LET capellidopaternoreferencia2	= TRIM(NVL(capellpatrefAux,''));
							LET capellidomaternoreferencia2	= TRIM(NVL(capellmatrefAux,''));
							LET csexoreferencia2			= TRIM(NVL(csexorefAux,''));     
							LET sciudadreferencia2			= NVL(sciudadrefAux,0);
							LET scoloniareferencia2			= NVL(scoloniarefAux,0);
							LET icallereferencia2			= NVL(icallerefAux,0);
							LET icasareferencia2			= NVL(icasarefAux,0);
							LET cdeptoointeriorreferencia2	= TRIM(NVL(cdeptoointrefAux,''));
							LET crumboreferencia2			= TRIM(NVL(crumborefAux,''));
							LET ccomplementoreferencia2		= TRIM(NVL(ccomplementorefAux,''));
							LET centrecallesreferencia2		= TRIM(NVL(centrecallesrefAux,'')); 
							LET sflaguhr2					= NVL(sflaguhrAux,0);
							LET suhrmanzana2				= NVL(suhrmanzanaAux,0);
							LET suhrotros2					= NVL(suhrotrosAux,0);
							LET suhrandador2				= NVL(suhrandadorAux,0);
							LET suhretapa2					= NVL(suhretapaAux,0);
							LET suhrlote2					= NVL(suhrloteAux,0);
							LET suhredificio2				= NVL(suhredificioAux,0);
							LET suhrentrada2				= NVL(suhrentradaAux,0);  
							LET ctelefonoreferencia2		= NVL(ctelrefaux,'0');
							LET ctelefonocelularreferencia2	= NVL(ctelcelrefAux,'0');
							LET cclavereferencia2			= TRIM(cclaverefAux);
						END IF;
					END FOREACH;
					
					--SCORING PROSPECTO
					LET cObservs = TRIM('Paso 102');
					FOREACH WITH HOLD
						SELECT ele.rango_minimo,det.grupo,ele.descripcion
						INTO  iElemento,iGrupo,cDescripElemento
						FROM bdiprospectos:"informix".pr_detalle_scoring det
						INNER JOIN bdiprospectos:"informix".pr_scoring_element ele 
								ON ( ele.elemento = det.elemento AND det.grupo = ele.grupo 
								AND det.empresa = ele.empresa AND det.tpo_persona = ele.tpo_persona) 
						WHERE num_solicitud = vNumCteProspecto
						AND det.grupo  IN(11,39,6,8,21) 
						AND det.seccion = 2 
						AND det.tpo_persona = "01" 
						AND activa = 1  
						
						LET cObservs = TRIM('Paso 103');
						IF iGrupo = 11 THEN
							LET cObservs = TRIM('Paso 104');
							LET vnumerodependientes = iElemento;
						ELIF iGrupo = 39 THEN
							LET cObservs = TRIM('Paso 105');
							LET vpersonastrabajan = iElemento;
						ELIF iGrupo = 6 THEN
							LET cObservs = TRIM('Paso 106');
							LET cfechadesdecuandovive = YEAR(dFechaAlta)-iElemento; 
							LET cfechadesdecuandovive = TRIM(cfechadesdecuandovive)||"/01/01";
						ELIF iGrupo = 8 THEN
							LET cObservs = TRIM('Paso 107');
							IF iElemento = -1 THEN
								LET cObservs = TRIM('Paso 108');
								SELECT elemento INTO iElemento FROM bdiprospectos:"informix".pr_detalle_scoring 
								WHERE grupo = 7 AND seccion = 2 AND tpo_persona = "01" AND num_solicitud = vNumCteProspecto;
								
								IF iElemento = 15 THEN --Estudiante
									LET cObservs = TRIM('Paso 109');
									LET cfechaantiguedtrab = dFechaAlta;
								ELIF iElemento = 12 THEN --Ama de Casa
									LET cObservs = TRIM('Paso 110');
									LET cfechaantiguedtrab =  dFechaAlta;
									LET vlugartrabajo = ""; 
								ELIF iElemento = 6 OR iElemento = 17 THEN --Desempleado, Jubilado o Pensionado
									LET cObservs = TRIM('Paso 111');
									LET cfechaantiguedtrab = dFechaAlta;
								END IF;
							ELSE
								LET cObservs = TRIM('Paso 112');
								LET cfechaantiguedtrab = YEAR(vfechaaltacliente)-iElemento;	
								LET cfechaantiguedtrab = TRIM(cfechaantiguedtrab)||"/01/01";
							END IF;
						ELIF iGrupo = 21 THEN
							LET cObservs = TRIM('Paso 113');
							IF TRIM(cDescripElemento) = "No EstudiÃ³" THEN
								LET cescolaridad = "1";
							ELIF TRIM(cDescripElemento) = "Primaria" THEN
								LET  cescolaridad = "2";
							ELIF TRIM(cDescripElemento) = "Secundaria" THEN
								LET cescolaridad = "3";
							ELIF TRIM(cDescripElemento) = "Carrera TÃ©cnica" THEN
								LET cescolaridad = "4";
							ELIF TRIM(cDescripElemento) = "Preparatoria" THEN
								LET cescolaridad = "5";
							ELIF TRIM(cDescripElemento) = "Licenciatura o Superior" THEN
								LET cescolaridad = "6"; 
							END IF;
						END IF;
					END FOREACH;
					
					LET cObservs = TRIM('Paso 114');
					
					LET vfolio = '';
					LET vfolioanterior = '0';
					LET cClaveOSAnt = '';
					LET cClaveOS = '';
					--SE OBTIENEN LOS FOLIOS ACTUAL Y ANTERIOR
					FOREACH
						SELECT FIRST 2 folio, clave, fechasolicitud
						INTO vfolioanterior, cClaveOSAnt, dFechaSupervisar
						FROM TABLE ( MULTISET(
						SELECT folio, clave, fechasolicitud
						FROM bdisolic:"informix".ss_osclientesupervisar  
						WHERE num_solicitud= vNumCteProspecto 
						AND empresa= pempresa
						))ORDER BY folio DESC
						
						--SI ES EL PRIMERO 
						IF vfolio = '' THEN
							IF dFechaSupervisar <= vfechaaltacliente THEN 
								LET vfolio = NVL(vfolioanterior,'0');
								LET cClaveOS = cClaveOSAnt;
							END IF;
						ELSE
							IF NVL(vfolioanterior,'') = '' THEN
								LET vfolioanterior = '0';
								LET cClaveOSAnt = '';
							END IF;
						END IF;
					END FOREACH;
					
					LET cObservs = TRIM('Paso 115');
					--SE OBTIENE LA RESPUESTA DE BURO
					SELECT NVL(COUNT(*), 0) 
					INTO iContConsBuro 
					FROM bdisolic:"informix".ss_solicitudes_sic 
					WHERE numcte = vnumcte 
					AND num_solicitud = vNumCteProspecto;
					
					LET cObservs = TRIM('Paso 116');
					
					SELECT CASE WHEN "informix".sp_EsNumerico(ingreso_mensual) = "V" THEN ingreso_mensual::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(cap_sistematica_abono) = "V" THEN cap_sistematica_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(tope_abonocoppel) = "V" THEN tope_abonocoppel::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(lineacreditotope) = "V" THEN lineacreditotope::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(capmaxima_abono) = "V" THEN capmaxima_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(capreal_abono) = "V" THEN capreal_abono::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(lineacredito_real) = "V" THEN lineacredito_real::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(compromisossic) = "V" THEN compromisossic::INTEGER ELSE 0 END, 
					CASE WHEN "informix".sp_EsNumerico(flaglineacreditoesp) = "V" THEN flaglineacreditoesp::INTEGER ELSE 0 END,
					limitecredito, situacion_especial, 
					CASE WHEN "informix".sp_EsNumerico(causa_sitesp) = "V" THEN causa_sitesp::INTEGER ELSE 0 END,
					puntos_parcn, par_celulares, par_altoriesgo, par_prestamos,
					id_situaciones,TRIM(puntualidad_ref1),TRIM(puntualidad_ref2),flagtestigoparametricocn::SMALLINT, 
					flag_altadirecta_asupervisar::SMALLINT,puntos_var_param,
					puntos_var_sic,score_domicilio,nuevo_puntajefinal,
					status_solicitud,canal_origenpros
					
					INTO iMontoIngMensual, iCapSistematicabono, iTopeAbonoCoppel, iLineaCrediTope, iCapMaximaAbono, iCapRealAbono, iLineaCredReal,
					iCompromisosSic, iFlagLineaCredEsp,vlimitecredito,csituacionespecial, vcausasituacionespecial,iPuntuacion,sParCelulares,
					sParAltoRiesgo, sParPrestamo,
					iId_Situaciones,cPuntualidad_ref1,cPuntualidad_ref2,sFlagTestParametrico,sFlag_altadirecta_asupervisar,iPuntos_Var_Param,
					iPuntos_Var_SIC,iScore_domicilio,sNuevo_puntajefinal,
					cStatusParam,cCanal_origensol
					
					FROM bdiprospectos:"informix".pr_nuevo_parametrico
					WHERE ROWID = (SELECT MAX(ROWID) FROM bdiprospectos:"informix".pr_nuevo_parametrico
					WHERE empresa = pempresa AND num_solicitud = vNumCteProspecto); --DSB-06/04/2018
					
					LET cObservs = TRIM('Paso 117');
					SELECT ingreso_mensual, periosidad 
					INTO iIngreso, ctiposueldo 
					FROM bdiprospectos:"informix".pr_ingresos 
					WHERE empresa = pempresa 
					AND numcte_pros = vNumCteProspecto
					AND sec_ingreso = (SELECT MAX(sec_ingreso) FROM bdiprospectos:"informix".pr_ingresos WHERE numcte_pros = vNumCteProspecto AND tipo_ingreso = "T");
					IF iIngreso > iTopeMax THEN
						LET iIngreso=iTopeMax;
					END IF;
					
					LET cObservs = TRIM('Paso 118');
					LET vingresomensual = ((((NVL(iIngreso::DECIMAL(18,2),0))+(iValor/2)))/iValor)::INTEGER;
					
					IF vingresomensual < 1 THEN
						LET vingresomensual = 1;
					END IF;
				END IF;
				
				LET cObservs = TRIM('Paso 119');
				IF cClave="M" THEN
					IF cClaveOS = 'R' AND cMotivobcpl = '' AND cStatus = 'RT' THEN 
						LET cMotivobcpl = 'ROS';
					END IF;
					
					IF NVL(csituacionespecial,'') = '' AND NVL(vcausasituacionespecial,0)=0 THEN
						LET cObservs = TRIM('Paso 120');
						IF cClaveOS = 'A' AND sFlagCapCobranza <> 0 THEN
							LET cObservs = TRIM('Paso 121');
							LET csituacionespecial="G";
							LET vcausasituacionespecial=57;
						ELIF cStatus = 'OA' OR cStatus = /*'R'*/'RT' THEN --DSB20180621
							FOREACH
								SELECT FIRST 1 situacionespecialrespuesta,causasituacionespecialrespuesta, fecha_respuesta
								INTO csituacionespecial, vcausasituacionespecial, dFechaTemp
								FROM TABLE ( MULTISET(
								SELECT situacionespecialrespuesta,causasituacionespecialrespuesta , fecha_respuesta
								FROM bdiprospectos:"informix".pr_solicitud_os 
								WHERE num_solicitud = vNumCteProspecto AND status = DECODE(cStatus, /*'R'*/'RT','R','OA','D') --DSB20180621
								AND fecha_respuesta <= pFechaAct))ORDER BY fecha_respuesta DESC
							END FOREACH;
						END IF;
						
						IF cStatusbcpl = 'H' AND NVL(csituacionespecial,'') = ''  THEN
							LET cObservs = TRIM('Paso 122');
							LET csituacionespecial = csituacionespecial_aut;
							LET vcausasituacionespecial = icausasituacionespecial_aut;
						END IF;
						
					ELIF sFlagCapCobranza = 0 AND cstatusparam <> 'R' THEN 
						LET cObservs = TRIM('Paso 123');
						LET csituacionespecial="";
						LET vcausasituacionespecial=0;
					END IF;
					
					IF NVL(cClaveOS,'') = '' THEN
						LET cClaveOS = 'R';
					END IF;
					
					LET cObservs = TRIM('Paso 124');
					SELECT user_insert 
					INTO vefectuo 
					FROM bdisolic:"informix".ss_solicitudes 
					WHERE num_solicitud= vNumCteProspecto; 
					
				ELIF NVL(cClave,'') ='' THEN
					LET cObservs = TRIM('Paso 125');
					
					IF  cStatusParam = 'A' THEN
						IF sFlagCapCobranza = 0 THEN
							LET csituacionespecial ='';
							LET vcausasituacionespecial = 0;
						ELSE
							LET csituacionespecial='G';
							LET vcausasituacionespecial=57;
						END IF;
					END IF;
					
					LET vefectuo=vefectuoMOD;
				END IF;
				
				LET cObservs = TRIM('Paso 126');

--                 --RGH
--                IF LENGTH(CAST(iNumerocasa AS CHAR(10)))>= 10 THEN
--                    LET iNumerocasa = 0;
--                END IF;
--                
--                IF LENGTH(CAST(inumerocasatrabajo AS CHAR(10)))>= 10 THEN
--                    LET inumerocasatrabajo = 0;
--                END IF;
--                --RGH				
				
				LET cTrama = '';
				LET cTrama = inumSecuencia||"|"||NVL(cClave,'')||"|"||scaja||"|"||carea
				||"|"||vcliente_ref::INTEGER||"|"||TRIM(NVL(vnombre1, ''))||"|"||TRIM(NVL(vnombre2, ''))||"|"||TRIM(NVL(vapell_paterno, ''))||"|"||TRIM(NVL(vapell_materno, ''))
				||"|"||TRIM(NVL(vcurp, ''))||"|"||TRIM(NVL(vclaveelector, ''))||"|"||TRIM(NVL(vclaveidentificacion, ''))||"|"||TRIM(videntificacion)
				||"|"||NVL(vciudad, 0)||"|"||NVL(vcolonia, 0)||"|"||NVL(vcalle, 0)||"|"||NVL(iNumerocasa, 0)||"|"||TRIM(NVL(vdeptointerior, ''))||"|"||NVL(crumbo, '')||"|"||TRIM(NVL(vcomplemento,''))
				||"|"||TRIM(NVL(ventrecalles, ''))||"|"||NVL(cUnidadHabit, 0)||"|"||NVL(vuhcmanzana, 0)||"|"||NVL(vuhcotros, 0)||"|"||NVL(vuhcandador, 0)||"|"||NVL(vuhcetapa, 0)||"|"||NVL(vuhclote, 0)
				||"|"||NVL(vuhcedificio, 0)||"|"||NVL(vuhcentrada, 0)
				||"|"||NVL(vtelefono::INT8, 0)||"|"||NVL(vtelefonocelular::INT8, 0)||"|"||TRIM(NVL(cHabitaen, ''))||"|"||TRIM(vniptitular)||"|"||TRIM(vnipadicional)||"|"||TRIM(NVL(csexo, ''))
				||"|"||TRIM(NVL(cestadocivil, ''))||"|"||TRIM(NVL(cfechanac, '1900/01/01'))||"|"||TRIM(NVL(cfechadesdecuandovive, '1900/01/01'))||"|"||NVL(vpersonasvivenendomicilio, 0)
				||"|"||TRIM(NVL(cescolaridad, ''))||"|"||TRIM(NVL(ctiposueldo, ''))||"|"||NVL(vnumerodependientes, 0)||"|"||NVL(vpersonastrabajan, 0)||"|"||NVL(vlimitecredito, 0)
				||"|"||NVL(vingresomensual, 0)
				||"|"||TRIM(NVL(csituacionespecial, ''))||"|"||NVL(vcausasituacionespecial, 0)||"|"||TRIM(cclaveautrechaza)||"|"||TRIM(NVL(caceptadosupervisadorechazado, ''))||"|"||TRIM(cclientenuevo)
				||"|"||TRIM(NVL(ccreditojoven, ''))
				||"|"||TRIM(NVL(vlugartrabajo, ''))||"|"||NVL(sciudadtrabajo,0)||"|"||NVL(scoloniatrabajo, 0)||"|"||NVL(icalletrabajo, 0)
				||"|"||NVL(inumerocasatrabajo, 0)||"|"||TRIM(NVL(cdeptoointeriortrabajo, ''))||"|"||TRIM(NVL(crumbotrabajo, ''))||"|"||TRIM(NVL(ccomplementotrabajo, ''))
				||"|"||TRIM(NVL(centrecallesTrabajo, ''))||"|"||NVL(sflaguht, 0)||"|"||NVL(suhtmanzana, 0)||"|"||NVL(suhtotros, 0)||"|"||NVL(suhtandador, 0)
				||"|"||NVL(suhtetapa, 0)||"|"||NVL(suhtlote, 0)||"|"||NVL(suhtedificio, 0)||"|"||NVL(suhtentrada, 0)||"|"||NVL(vtelefonotrabajo::INT8, 0)||"|"||NVL(vextensiontrabajo, 0)
				||"|"||TRIM(NVL(cpuesto,''))||"|"||NVL(vopcionpuesto, 0)||"|"||TRIM(NVL(cfechaantiguedtrab, '1900/01/01'))
				||"|"||NVL(iclienteconyuge,0)||"|"||TRIM(NVL(cnombreunoconyuge, ''))||"|"||TRIM(NVL(cnombredosconyuge, ''))||"|"||TRIM(NVL(capellidopaternoconyuge, ''))
				||"|"||TRIM(NVL(capellidomaternoconyuge, ''))||"|"||TRIM(NVL(cSexoConyuge, ''))||"|"||TRIM(NVL(clugartrabajoconyuge, ''))||"|"||NVL(sciudadconyuge, 0)
				||"|"||NVL(scoloniaconyuge, 0)||"|"||NVL(icalletrabajoconyuge, 0)||"|"||NVL(icasatrabajoconyuge, 0)||"|"||TRIM(NVL(cdeptoointeriorconyuge, ''))
				||"|"||TRIM(NVL(crumbotrabajoconyuge, ''))||"|"||TRIM(NVL(ccomplementoconyuge, ''))||"|"||TRIM(NVL(centrecallesconyuge,''))||"|"||NVL(sflaguhy, 0)||"|"||NVL(suhymanzana, 0)
				||"|"||NVL(suhyotros, 0)||"|"||NVL(suhyandador, 0)||"|"||NVL(suhyetapa, 0)||"|"||NVL(suhylote, 0)||"|"||NVL(suhyedificio, 0)||"|"||NVL(suhyentrada, 0)||"|"||REPLACE(NVL(TRIM(ctelefonotrabajoconyuge),''),'','0')
				||"|"||REPLACE(NVL(TRIM(ctelefonocelularconyuge),''),'','0')||"|"||NVL(cclaveconyugefamilia,'')
				||"|"||NVL(iclientereferencia,0)||"|"||TRIM(NVL(cnombreunoreferencia, ''))||"|"||TRIM(NVL(cnombredosreferencia, ''))||"|"||TRIM(NVL(capellidopaternoreferencia, ''))
				||"|"||TRIM(NVL(capellidomaternoreferencia, ''))||"|"||TRIM(NVL(cSexoReferencia, ''))||"|"||NVL(sciudadreferencia,0)||"|"||NVL(scoloniareferencia,0)||"|"||NVL(icallereferencia,0)
				||"|"||NVL(icasareferencia,0)||"|"||NVL(cdeptoointeriorreferencia,'')||"|"||NVL(crumboreferencia,'')||"|"||NVL(ccomplementoreferencia,'')||"|"||NVL(centrecallesreferencia1,'')
				||"|"||NVL(sflaguhr,0)||"|"||NVL(suhrmanzana,0)||"|"||NVL(suhrotros,0)||"|"||NVL(suhrandador,0)||"|"||NVL(suhretapa,0)||"|"||NVL(suhrlote,0)||"|"||NVL(suhredificio,0)||"|"||NVL(suhrentrada,0)
				||"|"||REPLACE(NVL(TRIM(ctelefonoreferencia),''),'','0')||"|"||REPLACE(NVL(TRIM(ctelefonocelularreferencia),''),'','0')||"|"||NVL(cclavereferencia1,'')
				||"|"||NVL(iclientereferencia2,0)||"|"||TRIM(NVL(cnombreunoreferencia2, ''))||"|"||TRIM(NVL(cnombredosreferencia2, ''))||"|"||TRIM(NVL(capellidopaternoreferencia2, ''))
				||"|"||TRIM(NVL(capellidomaternoreferencia2, ''))||"|"||TRIM(NVL(cSexoReferencia2, ''))||"|"||NVL(sciudadreferencia2,0)||"|"||NVL(scoloniareferencia2,0)||"|"||NVL(icallereferencia2,0)
				||"|"||NVL(icasareferencia2,0)||"|"||NVL(cdeptoointeriorreferencia2,'')||"|"||NVL(crumboreferencia2,'')||"|"||NVL(ccomplementoreferencia2,'')||"|"||NVL(centrecallesreferencia2,'')
				||"|"||NVL(sflaguhr2,0)||"|"||NVL(suhrmanzana2,0)||"|"||NVL(suhrotros2,0)||"|"||NVL(suhrandador2,0)||"|"||NVL(suhretapa2,0)||"|"||NVL(suhrlote2,0)||"|"||NVL(suhredificio2,0)||"|"||NVL(suhrentrada2,0)
				||"|"||REPLACE(NVL(TRIM(ctelefonoreferencia2),''),'','0')||"|"||REPLACE(NVL(TRIM(ctelefonocelularreferencia2),''),'','0')||"|"||NVL(cclavereferencia2,'')
				||"|"||vreferencia2||"|"||vreferencia3||"|"||TRIM(cmarcadatosin)||"|"||vtiporeposicion||"|"||vreposicion||"|"||TRIM(cflagentregotarjeta)
				||"|"||NVL(vefectuoMOD, 0)||"|"||NVL(cFolioSucursal,'0')||"|"||NVL(vfolio::INTEGER,0)||"|"||NVL(dFechaAlta, '1900/01/01')||"|"||TRIM(cflagnoreconocehuella)
				||"|"||vfoliotienda||"|"||TRIM(NVL(vrfc, ''))||"|"||TRIM(vcveburo)||"|"||TRIM(vfolioaut)||"|"||TRIM(vfolioconsulta)||"|"||TRIM(vfolioconcir)||"|"||vnegocio||"|"||vsubnegocio||"|"||NVL(vefectuo,0)
				||"|"||TRIM(ctipo)||"|"||TRIM(NVL(cfechamovto, '1900/01/01'))||"|"||NVL(cNumSolRef, '')||"|"||TRIM(NVL(vnumcte, ''))||"|"||NVL(vtiendafolioanterior,0)
				||"|"||NVL(vfolioanterior,0)||"|"||NVL(vclaveproducto,0)||"|"||vflagactualizacion||"|"||vSistsegsocial||"|"||vTiposueldoext||"|"||vNumempleados||"|"||vSubopcionpuesto||"|"||vPuestoext
				||"|"||vOpcionpuestoext||"|"||vNumempleadosext||"|"||vSubopcionpuestoext||"|"||TRIM(cTipoOrigen)||"|"||TRIM(vTipoProducto)||"|"||TRIM(NVL(cFolioSucursal, '0'))
				||"|"||TRIM(NVL(cFecha_hoy, '1900/01/01'))||"|"||NVL(iPuntuacion,0)||"|"||NVL(cMarcaHit,'')||"|"||NVL(cEmpleadoSubCob::INTEGER,0)||"|"||NVL(sFlagCapHuella,0)
				||"|"||TRIM(cMarcarConsultado)||"|"||NVL(sFlagTestParametrico,0)||"|"||NVL(sFlagCapCobranza,0)||"|"||NVL(REPLACE(cEmpleadoGteAutori,'sistema','0'),0)||"|"||NVL(cFlagConsBuro,'')
				||"|"||NVL(cBuroPilotoTestig,'')||"|"||TRIM(NVL(cNacionalidad,''))||"|"||TRIM(NVL(cNoFm3,''))||"|"||TRIM(NVL(cEmail,''))||"|"||TRIM(NVL(cApellCasada,''))||"|"||TRIM(NVL(cPais,''))
				||"|"||TRIM(NVL(cNoIMSS,''))||"|"||TRIM(NVL(cEstado,''))||"|"||TRIM(NVL(cDelegMunicip,''))||"|"||TRIM(NVL(cNumInterior,''))||"|"||NVL(sPropNegocio,0)
				||"|"||NVL(sParCelulares,0)||"|"||NVL(sParAltoRiesgo,0)||"|"||NVL(sParPrestamo,0)||"|"||NVL(cModeloCel,'')||"|"||NVL(cFechaConsBuro, '1900/01/01')||"|"||NVL(iMontoIngMensual,0)
				||"|"||NVL(iCapSistematicabono,0)||"|"||NVL(iTopeAbonoCoppel,0)||"|"||NVL(iLineaCrediTope,0)||"|"||NVL(iCapMaximaAbono,0)||"|"||NVL(iCapRealAbono,0)||"|"||NVL(iLineaCredReal,0)
				||"|"||NVL(iCompromisosSic,0)||"|"||NVL(iFlagLineaCredEsp,0)||"|"||TRIM(NVL(cClienteConyugebcpl,'0'))||"|"||TRIM(NVL(cClienteReferencia1bcpl,'0'))
				||"|"||TRIM(NVL(cClienteReferencia2bcpl,'0'))||"|"||TRIM(NVL(cFolioSucursal, '0'))||"|"||NVL(pFechaAct,DATE(1))||"|"||TRIM(NVL(cStatus,''))||"|"||TRIM(NVL(cMotivobcpl,''))
				||"|"||TRIM(NVL(cFlagProspecto,''))||"|"||TRIM(NVL(vNumCteProspecto,''))||"|"||NVL(iParAltoRiesgoNvo,0)||"|"||NVL(iPagoUlt12meses,0)
				||"|"||NVL(iId_Situaciones,0)||"|"||TRIM(NVL(cPuntualidad_ref1,''))||"|"||TRIM(NVL(cPuntualidad_ref2,''))||"|"||NVL(sFlag_altadirecta_asupervisar,0)
				||"|"||NVL(iPuntos_Var_Param,0)||"|"||NVL(iPuntos_Var_SIC,0)||"|"||NVL(iScore_domicilio,0)||"|"||NVL(sNuevo_puntajefinal,0);
				
				LET cObservs = TRIM('Paso 127');
				
				INSERT INTO bdinteg:"informix".si_tramasbatch(secuencia,clave, caja, area,
				--DATOS DEL CLIENTE PROSPECTO
				cliente, nombre1, nombre2, apellidopaterno, apellidomaterno, curp, claveelector, claveidentificacion, identificacion, 
				--DIRECCION
				ciudad, colonia, calle, casa,deptoointerior, rumbo, complemento, entrecalles, flaguhc, uhcmanzana, uhcotros, uhcandador, uhcetapa, uhclote, uhcedificio, 
				uhcentrada, telefono,telefonocelular,
				--Datos Generales del cte
				casapropia, niptitular, nipadicional, sexo, estadocivil, fechanacimiento, fechadesdecuandoviveahi, personasvivenendomicilio, escolaridad,
				tiposueldo, numerodependientes, personastrabajan, limitecredito, ingresomensual,
				--SITUACION DEL CLIENTE
				situacionespecial, causasituacionespecial, claveautrechaza,aceptadosupervisadorechazado, clientenuevo, creditojoven, 
				--OCUPACION Y DIRECCION DEL TRABAJO DEL CTE
				lugartrabajo, ciudadtrabajo, coloniatrabajo, calletrabajo, casatrabajo, deptoointeriortrabajo,
				rumbotrabajo, complementotrabajo, entrecallestrabajo, flaguht, uhtmanzana, uhtotros, uhtandador, uhtetapa, uhtlote, uhtedificio, uhtentrada, 
				telefonotrabajo, extensiontrabajo, puesto, opcionpuesto, fechaantiguedadtrabajo, 
				--DATOS DEL CONYUGE
				clienteconyuge, nombreunoconyuge, nombredosconyuge, apellidopaternoconyuge, apellidomaternoconyuge, sexoconyuge, 
				--DIRECCION DEL CONYUGE
				lugartrabajoconyuge, ciudadconyuge, coloniaconyuge, calletrabajoconyuge, casatrabajoconyuge, deptoointeriorconyuge, rumbotrabajoconyuge, 
				complementoconyuge, entrecallesconyuge, flaguhy, uhymanzana, uhyotros, uhyandador, uhyetapa, uhylote, uhyedificio, uhyentrada, telefonotrabajoconyuge,
				telefonocelularconyuge, claveconyugefamilia,
				--Datos Referencia 1 y direccion
				clientereferencia, nombreunoreferencia, nombredosreferencia, apellidopaternoreferencia, apellidomaternoreferencia, sexoreferencia, ciudadreferencia, 
				coloniareferencia, callereferencia, casareferencia, deptoointeriorreferencia, rumboreferencia, complementoreferencia, entrecallesreferencia1, flaguhr,
				uhrmanzana, uhrotros, uhrandador, uhretapa, uhrlote, uhredificio, uhrentrada, telefonoreferencia, telefonocelularreferencia, clavereferencia1,
				--Datos Referencia 2 y direccion
				clientereferencia2, nombreunoreferencia2, nombredosreferencia2, apellidopaternoreferencia2, apellidomaternoreferencia2, sexoreferencia2, ciudadreferencia2,
				coloniareferencia2, callereferencia2, casareferencia2, deptoointeriorreferencia2, rumboreferencia2, complementoreferencia2, entrecallesreferencia2,
				flaguhr2, uhrmanzana2, uhrotros2, uhrandador2, uhretapa2, uhrlote2, uhredificio2, uhrentrada2, telefonoreferencia2, telefonocelularreferencia2,
				clavereferencia2,
				--OTROS
				referencia2,referencia3,marcadatosin, tiporeposicion, reposicion, flagentregotarjeta, efectuo, tiendafolio, folio, fechaaltacliente, 
				flagnoreconocehuella, foliotienda, rfc,cveburo, folioaut, folioconsulta, folioconcir, negocio, subnegocio, empleadoautorizo, tipo, fechamovto,
				numerosolicituddecredito, clientebancoppel,tiendafolioanterior, folioanterior, claveproducto, flagactualizacion, sistsegsocial, tiposueldoext, 
				numempleados, subopcionpuesto, puestoext, opcionpuestoext, numempleadosext, subopcionpuestoext, tipoorigen, tipoproducto, tienda, fecha, puntosparcn,
				marcahit, empleadosupcob, flagcapturohuella, marcarconsultado, flagtestigoparametricocn, flagcapturacobranza, empleadogteautorizo, flagconsultaburo,
				buropilototestigo, nacionalidad, no_fm3, email, apellido_cas, pais, no_imss, estado, municipio, numinterior, propietarionegocio, parcelulares,
				paraltoriesgo, parprestamo, modelocelulares, fechaconsultaburo, montoingresomensual, capsistematicaabono, topeabonocoppel, lineadecreditope, 
				capmaximaabono, caprealabono, lineadecreditoreal, compromisossic, flaglineacreditoesp, clienteconyugebcpl, clientereferenciabcpl, 
				clientereferencia2bcpl,sucursal,fecha_insert,statusbcpl,motivobcpl,flagprospecto,numcteprospecto,paraltoriesgonvo,pagoult12meses,
				id_situaciones,puntualidad_ref1,puntualidad_ref2,flag_altadirecta_asupervisar,puntos_var_param,puntos_var_sic,score_domicilio,nuevo_puntajefinal,canal_origensol)
				
				VALUES(inumSecuencia,NVL(cClave,''), scaja,carea,
				--DATOS DEL CLIENTE PROSPECTO
				vcliente_ref::INTEGER,TRIM(NVL(vnombre1, '')), TRIM(NVL(vnombre2, '')), TRIM(NVL(vapell_paterno, '')),TRIM(NVL(vapell_materno, '')),
				TRIM(NVL(vcurp, '')),TRIM(NVL(vclaveelector, '')),TRIM(NVL(vclaveidentificacion, '')), TRIM(videntificacion), 
				--DIRECCION DEL CTE
				NVL(vciudad, 0),NVL(vcolonia, 0),NVL(vcalle, 0), NVL(iNumerocasa, 0),TRIM(NVL(vdeptointerior, '')),NVL(crumbo, ''), TRIM(NVL(vcomplemento,'')),
				TRIM(NVL(ventrecalles, '')), NVL(cUnidadHabit, 0),NVL(vuhcmanzana, 0),NVL(vuhcotros, 0), NVL(vuhcandador, 0), NVL(vuhcetapa, 0), NVL(vuhclote, 0), 
				NVL(vuhcedificio, 0), NVL(vuhcentrada, 0),
				--OTROS DATOS
				NVL(vtelefono::INT8, 0),NVL(vtelefonocelular::INT8, 0), TRIM(NVL(cHabitaen, '')),TRIM(vniptitular), TRIM(vnipadicional), TRIM(NVL(csexo, '')),
				TRIM(NVL(cestadocivil, '')), TRIM(NVL(cfechanac, '1900/01/01')),TRIM(NVL(cfechadesdecuandovive, '1900/01/01')), NVL(vpersonasvivenendomicilio, 0), 
				TRIM(NVL(cescolaridad, '')), TRIM(NVL(ctiposueldo, '')),NVL(vnumerodependientes, 0), NVL(vpersonastrabajan, 0), NVL(vlimitecredito, 0),
				NVL(vingresomensual, 0), 
				--Situacion del cte
				TRIM(NVL(csituacionespecial, '')),NVL(vcausasituacionespecial, 0), TRIM(cclaveautrechaza),
				TRIM(NVL(cStatusbcpl,'')), --PRUEBA
				TRIM(cclientenuevo),
				TRIM(NVL(ccreditojoven, '')),
			   ---TRABAJO
				TRIM(NVL(vlugartrabajo, '')),NVL(sciudadtrabajo,0), NVL(scoloniatrabajo, 0),NVL(icalletrabajo, 0),
				NVL(inumerocasatrabajo, 0),TRIM(NVL(cdeptoointeriortrabajo, '')), TRIM(NVL(crumbotrabajo, '')), TRIM(NVL(ccomplementotrabajo, '')),
				TRIM(NVL(centrecallesTrabajo, '')), NVL(sflaguht, 0), NVL(suhtmanzana, 0), NVL(suhtotros, 0), NVL(suhtandador, 0), 
				NVL(suhtetapa, 0), NVL(suhtlote, 0), NVL(suhtedificio, 0),NVL(suhtentrada, 0),NVL(vtelefonotrabajo::INT8, 0), NVL(vextensiontrabajo, 0), 
				TRIM(NVL(cpuesto,'')),NVL(vopcionpuesto, 0), TRIM(NVL(cfechaantiguedtrab, '1900/01/01')),
				--CONYUGE
				NVL(iclienteconyuge,0), TRIM(NVL(cnombreunoconyuge, '')),TRIM(NVL(cnombredosconyuge, '')),TRIM(NVL(capellidopaternoconyuge, '')), 
				TRIM(NVL(capellidomaternoconyuge, '')),TRIM(NVL(cSexoConyuge, '')),TRIM(NVL(clugartrabajoconyuge, '')), NVL(sciudadconyuge, 0), 
				NVL(scoloniaconyuge, 0), NVL(icalletrabajoconyuge, 0),NVL(icasatrabajoconyuge, 0),TRIM(NVL(cdeptoointeriorconyuge, '')), 
				TRIM(NVL(crumbotrabajoconyuge, '')), TRIM(NVL(ccomplementoconyuge, '')),TRIM(NVL(centrecallesconyuge,'')),NVL(sflaguhy, 0),NVL(suhymanzana, 0),
				NVL(suhyotros, 0), NVL(suhyandador, 0), NVL(suhyetapa, 0), NVL(suhylote, 0),NVL(suhyedificio, 0),NVL(suhyentrada, 0),REPLACE(NVL(TRIM(ctelefonotrabajoconyuge),''),'','0'),
				REPLACE(NVL(TRIM(ctelefonocelularconyuge),''),'','0'),NVL(cclaveconyugefamilia,''),
				--REFERENCIA1
				NVL(iclientereferencia,0),TRIM(NVL(cnombreunoreferencia, '')),TRIM(NVL(cnombredosreferencia, '')), TRIM(NVL(capellidopaternoreferencia, '')),
				TRIM(NVL(capellidomaternoreferencia, '')),TRIM(NVL(cSexoReferencia, '')),NVL(sciudadreferencia,0),NVL(scoloniareferencia,0) ,NVL(icallereferencia,0),
				NVL(icasareferencia,0),NVL(cdeptoointeriorreferencia,''),NVL(crumboreferencia,''), NVL(ccomplementoreferencia,''),NVL(centrecallesreferencia1,''),
				NVL(sflaguhr,0),NVL(suhrmanzana,0),NVL(suhrotros,0),NVL(suhrandador,0),NVL(suhretapa,0),NVL(suhrlote,0),NVL(suhredificio,0),NVL(suhrentrada,0),
				REPLACE(NVL(TRIM(ctelefonoreferencia),''),'','0'),REPLACE(NVL(TRIM(ctelefonocelularreferencia),''),'','0'),NVL(cclavereferencia1,''),
				--Referencia 2
				NVL(iclientereferencia2,0), TRIM(NVL(cnombreunoreferencia2, '')),TRIM(NVL(cnombredosreferencia2, '')),TRIM(NVL(capellidopaternoreferencia2, '')),
				TRIM(NVL(capellidomaternoreferencia2, '')),TRIM(NVL(cSexoReferencia2, '')),NVL(sciudadreferencia2,0),NVL(scoloniareferencia2,0),NVL(icallereferencia2,0),
				NVL(icasareferencia2,0),NVL(cdeptoointeriorreferencia2,''),NVL(crumboreferencia2,''),NVL(ccomplementoreferencia2,''),NVL(centrecallesreferencia2,''),
				NVL(sflaguhr2,0),NVL(suhrmanzana2,0),NVL(suhrotros2,0),NVL(suhrandador2,0),NVL(suhretapa2,0),NVL(suhrlote2,0),NVL(suhredificio2,0),NVL(suhrentrada2,0),
				REPLACE(NVL(TRIM(ctelefonoreferencia2),''),'','0'),REPLACE(NVL(TRIM(ctelefonocelularreferencia2),''),'','0'),NVL(cclavereferencia2,''),
				--OTROS
				vreferencia2, vreferencia3, TRIM(cmarcadatosin),vtiporeposicion,vreposicion,TRIM(cflagentregotarjeta),
				NVL(vefectuoMOD, 0),NVL(cFolioSucursal,'0'),NVL(vfolio::INTEGER,0),NVL(dFechaAlta, '1900/01/01'),TRIM(cflagnoreconocehuella),
				vfoliotienda,TRIM(NVL(vrfc, '')),TRIM(vcveburo),TRIM(vfolioaut),TRIM(vfolioconsulta),TRIM(vfolioconcir),vnegocio,vsubnegocio,NVL(vefectuo,0),
				TRIM(ctipo),TRIM(NVL(cfechamovto, '1900/01/01')), NVL(cNumSolRef, ''),TRIM(NVL(vnumcte, '')),NVL(vtiendafolioanterior,0),
				NVL(vfolioanterior,0),NVL(vclaveproducto,0), vflagactualizacion, vSistsegsocial,vTiposueldoext,vNumempleados,vSubopcionpuesto, vPuestoext,
				vOpcionpuestoext,vNumempleadosext,vSubopcionpuestoext, TRIM(cTipoOrigen),TRIM(vTipoProducto),TRIM(NVL(cFolioSucursal, '0')),
				TRIM(NVL(cFecha_hoy, '1900/01/01')),NVL(iPuntuacion,0),NVL(cMarcaHit,''),NVL(cEmpleadoSubCob::INTEGER,0),NVL(sFlagCapHuella,0),
				TRIM(cMarcarConsultado),NVL(sFlagTestParametrico,0),NVL(sFlagCapCobranza,0),NVL(REPLACE(cEmpleadoGteAutori,'sistema','0'),0),NVL(cFlagConsBuro,''),
				NVL(cBuroPilotoTestig,''),TRIM(NVL(cNacionalidad,'')),TRIM(NVL(cNoFm3,'')),TRIM(NVL(cEmail,'')),TRIM(NVL(cApellCasada,'')),TRIM(NVL(cPais,'')),
				TRIM(NVL(cNoIMSS,'')),TRIM(NVL(cEstado,'')),TRIM(NVL(cDelegMunicip,'')),TRIM(NVL(cNumInterior,'')),NVL(sPropNegocio,0), 
				NVL(sParCelulares,0), NVL(sParAltoRiesgo,0), NVL(sParPrestamo,0),NVL(cModeloCel,''),NVL(cFechaConsBuro, '1900/01/01'),NVL(iMontoIngMensual,0),
				NVL(iCapSistematicabono,0),NVL(iTopeAbonoCoppel,0),NVL(iLineaCrediTope,0),NVL(iCapMaximaAbono,0),NVL(iCapRealAbono,0),NVL(iLineaCredReal,0),
				NVL(iCompromisosSic,0),NVL(iFlagLineaCredEsp,0),TRIM(NVL(cClienteConyugebcpl,'0')),TRIM(NVL(cClienteReferencia1bcpl,'0')),
				TRIM(NVL(cClienteReferencia2bcpl,'0')),TRIM(NVL(cFolioSucursal, '0')), NVL(pFechaAct,DATE(1)),
				TRIM(NVL(cStatus,'')),TRIM(NVL(cMotivobcpl,'')),
				TRIM(NVL(cFlagProspecto,'')),TRIM(NVL(vNumCteProspecto,'')),NVL(iParAltoRiesgoNvo,0),NVL(iPagoUlt12meses,0),
				NVL(iId_Situaciones,0),TRIM(NVL(cPuntualidad_ref1,'')),TRIM(NVL(cPuntualidad_ref2,'')),NVL(sFlag_altadirecta_asupervisar,0),
				NVL(iPuntos_Var_Param,0),NVL(iPuntos_Var_SIC,0),NVL(iScore_domicilio,0),NVL(sNuevo_puntajefinal,0),TRIM(NVL(cCanal_origensol,'')));
				
				LET iCuentaRegistros = iCuentaRegistros +1 ;
				
			END FOREACH;
			
		END IF
		IF inumSecuencia > 0 THEN
			UPDATE bdinteg:"informix".si_archivosecuenciamax SET secuencia_max=inumSecuencia;
		END IF;
	ELSE
		LET vCodRetorno = '000001';
	END IF;
	IF iCuentaRegistros >= 1 THEN
		LET vCodRetorno = '000000';
	ELIF iCuentaRegistros = 0 THEN
		LET vCodRetorno = '000005';
	END IF;
RETURN vCodRetorno;
END
END PROCEDURE
DOCUMENT
'Descripcion: Batch clientes prospecto reingenieria',
'Autor: Victor Hugo NuÃ±ez',
'BD: bdinteg',
'Fecha: 01/03/2018',
'Folio: 1875',
'Nombre: INC_BATCH',
'Sustento: Correo Re: Envio archivo de pruebas batch con informacion del 11-01-2018 del dia 22/03/2018',
'Solicita: Juan Olivares',
'fecha: 06/04/2018',
'Descripcion: Se realiza modificacion para tener en consideracion doble registros en la tabla pr_nuevo_parametrico, ademas',
'se realiza limpieza de variable cNumSolRef para evitar una valor incorrecto en solicitudes subsecuentes',
'se realiza modificacion para no incluir numero de solicitud de credito esto a peticion de Martha Gabriela Angulo',
'....... DSB20180621.- Se modifica para cambiar los R por RT y que valide la fecha de nacimiento menor a 1900 y enviar 1900/01/01 ',
'Solicita:Juan Olivares',
'Autor: 94379114 Victor Hugo NuÃ±ez',
'...... 95526749 Jesus Horacio Lopez Gonzalez DSB20180621',
'ModificÃ³: Irma Ureta',
'DescripciÃ³n: Se anexa la validaciÃ³n sobre el tipo de origen, si la solicitud se realizÃ³ desde el dispositivo movil se mandarÃ¡ tipoorigen = M',
'			  si la solicitud se realizÃ³ desde sucursal se mandarÃ¡ tipoorigen = G o si la solicitud fue levantada en cobranza y cliente prospecto',
'			  se mandarÃ¡ tipoorigen = N todas aquellas que comiensen con P y darlas de alta en la tabla bdinteg:si_tramasbatch con es tipoorigen.',
'Fecha: 07/05/2018',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'Modificacion: 99802102 - Yonaiker Morillo',
'Folio: 747',
'RQM: RQM 09 541-2 CrÃÂ©dito Motos Coppel en Alta ÃÂnica ',
'Descripcion: Se contempla el campo "cCanal_origensol", para insertar en la tabla si_tramasbatch, tomando el dato del campo canal_origenpros de la tabla "pr_nuevo_parametrico"',
'Fecha: 28/05/2021',
'Solicito: Abraham Narvaez',
'BD: BDINTEG',
'-------------------------------------------------------------------------------------------------------------------------------------------------',
'Folio: 1977',
'Autor: Jesus Ivan Garcia Guicho',
'Fecha: 05/07/2021',
'Descripcion: Se agrega retorno para en caso de existir algun error al generar el reproceso, lo retorne y no lo marque como exitoso',
'Etiqueta:--DSB20210705',
'BD: bdinteg',
'----------------------------------------------------------------------------------------------------------------',
'Descripcion: Se modifica campo numeroextcalle, que cuando este traiga un valor que sobre pase los â32767 y 32767, remplazar por el valor default que en este caso serÃ¡ 0',
'Autor: 95992243 - Trinidad Hernandez',
'BD: bdinteg',																																								 
'Fecha: 10/08/2021',
'Solicita: Abraham Narvaez',
'---------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_ctehuella(pempresa CHAR(3),
                                         psucursal CHAR(4),
                                         pejecutivo CHAR(8),
                                         pautoriza CHAR(8),
                                         pfecha_alta date,
                                         pfuncion CHAR(1),
                                         pnumcte CHAR(20),
                                         pmapad char(942),
                                         pmapai char(942)) 
										 
  RETURNING CHAR(5),smallint;

define vcodret CHAR(5);
define vsigsec smallint;
define vexiste CHAR(1);
define vtp_persona CHAR(2);
define vsqlerr INTEGER;
define visamerr INTEGER;
define vesfisica CHAR(1);



LET vcodret = "000";
LET vsigsec = 0;
LET vexiste = 0;
LET vtp_persona = "";

--SET DEBUG FILE TO '/informix/logspssql/sp_ctehuellaconcambio.sql';
--TRACE ON;


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vsigsec;
   END IF;
END EXCEPTION;

--- Verifica recepcion correcta de datos
IF pnumcte IS NULL OR Trim(pnumcte) = ""
   OR pmapad IS NULL OR pmapad = ""
   OR pmapai IS NULL OR pmapai = "" then
   LET vcodret = "110";
   RETURN vcodret,vsigsec;
END IF;

SELECT tpo_persona INTO vtp_persona
FROM   si_cliente
WHERE  numcte = pnumcte;

SELECT es_fisica INTO vesfisica
   FROM si_tipper
   WHERE tpo_persona = vtp_persona;
IF UPPER(vesfisica) != "S" THEN
   LET vcodret = "120";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_sucursales
   WHERE sucursal=psucursal;
IF vexiste IS NULL THEN
   LET vcodret="111";
   RETURN vcodret,vsigsec;
END IF;

SELECT 1 INTO vexiste
   FROM si_ejecut
   WHERE ejecutivo=pejecutivo;
IF vexiste IS NULL THEN
   LET vcodret="112";
   RETURN vcodret,vsigsec;
END IF;
if Trim(pautoriza) <> "" then
   SELECT 1 INTO vexiste
     FROM si_ejecut
    WHERE ejecutivo=pautoriza;
   IF vexiste IS NULL THEN
      LET vcodret="112";
      RETURN vcodret,vsigsec;
   END IF;
END IF;

IF pfuncion != "A" and pfuncion != "C" THEN
   let vcodret = "130";
   RETURN vcodret,vsigsec;
END IF
-- ****************** Actualizacion de Parametros *****************
IF pfuncion="A" THEN
   SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte
      AND estado ="A";
   IF vexiste = "1" THEN
      let vcodret = "131";
      RETURN vcodret,vsigsec;
   END IF

   /*SELECT 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; CIB20220428: se comentÃ³ el select debido a que retornaba dos datos*/
	
	SELECT LIMIT 1 1 INTO vexiste FROM si_cte_huella
    WHERE numcte = pnumcte; -- CIB20220428: se agregÃ³ LIMIT 1 esto para limitar el retorno de datos a solo 1  */

   IF vexiste = "1" THEN
      select max(secuencia) + 1 INTO vsigsec
      from   si_cte_huella
      where  numcte = pnumcte;
      /*RETURN vcodret,vsigsec; CIB20220428: se comentÃ³ el return debido a que terminaba el proceso sin agregar los datos en la tabla*/
   ELSE
      LET vsigsec = 1;
   END IF;
   BEGIN
      INSERT INTO si_cte_huella
        (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
      VALUES
         (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
   END;
   RETURN vcodret,vsigsec;
ELIF pfuncion = "C" then
     BEGIN
        UPDATE si_cte_huella SET estado = "I",usuario_camb = pautoriza,
               fecha_camb = pfecha_alta,
	       fech_ult_camb = CURRENT
        WHERE  numcte = pnumcte and estado = "A";
        -- Agrega la Nueva Huella
        select max(secuencia) + 1 INTO vsigsec
          from   si_cte_huella
         where  numcte = pnumcte;
         IF vsigsec is null  THEN
            let vsigsec = 1;
         END IF
         INSERT INTO si_cte_huella
           (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,fech_ult_camb)
         VALUES
           (pnumcte,vsigsec,"A",pmapad,pmapai,pejecutivo,psucursal,pfecha_alta,CURRENT);
     END;
     RETURN vcodret,vsigsec;
END IF;

RETURN vcodret,vsigsec;
END;
END PROCEDURE
DOCUMENT
"Alta, de Huella de cliente persona fisica ",
"AutOR : Procesamiento Interactivo S.A. de C.V.",
"MODIFICO : Mario Escobar",
"FECHA : 04/Enero/2007",
"Ver.  : 1.1",
"BD    : bdinteg",
"VER   : 1.1",
"-----------------------------------------------------",
"Autor: 90231110 - Rolando JosuÃ© UrÃ­as GarcÃ­a",
"Fecha: 28/04/2022 - CIB20220428",
"ModificaciÃ³n: Se modificÃ³ el SELECT 1 INTO vexiste FROM si_cte_huella WHERE numcte = pnumcte ya que cuando se ejecutaba retornaba el error 284",
"..............debido a que se retornaban 2 datos y en la validaciÃ³n de IF vexiste = '1' THEN select max(secuencia) + 1 INTO vsigsec from   si_cte_huella",
"..............where numcte = pnumcte RETURN vcodret,vsigsec ELSE LET vsigsec = 1; END IF; a pesar que ya estaba retornando bien, el return terminaba la ejecuciÃ³n",
"..............sin haber agregado los datos a la tabla por lo que se comentÃ³ el RETURN vcodret,vsigsec",
"Sustento: Se definio por correo electronico el dÃ­a miercoles 27 de abril por Jaime Gonzales Prado",
"Solicita: Jaime Gonzales Prado",
"Folio: 1997",
"Proyecto: INC-SPCTEHUELLA284YNOINSERTA",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_obtener_cel_rep_act(pNumCte CHAR(20),
												   pNumCel CHAR(10)
												  )
RETURNING
	CHAR(5) 	AS codRet,
	CHAR(50) 	AS totRegRep;
	

/*
SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_obtener_cel_rep_act"
Folio.........: 854 - Validacion de numeros de celular en 90 dias.
Autor.........: 90127902 - Epigmenio Martinez Pedraza
Fecha.........: 27/04/2022
Solicita......: Bancoppel
BD............: bdinteg
*/


DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iValidaDiasTu    INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iValidaDiasTu    = 0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet, iCantRep;
        END IF;
    END EXCEPTION; 	
 
--SET DEBUG FILE TO '/informix/LIP/sp_obtener_cel_rep_act.out';
--TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
	
	SELECT COUNT(*) INTO iCantRep FROM bdinteg:"informix".si_telefonos WHERE telefono=pNumCel AND numcte!=pNumCte AND tipo_tel=2 AND status_tel='A' AND verificado='F' AND ((DATE(CURRENT) - DATE(fecha_hora) < iValidaDiasTu) OR (DATE(CURRENT) - DATE(fecha_actualiza) < iValidaDiasTu));
																																									   
		
	    

RETURN sCodRet, iCantRep;

END
END PROCEDURE;