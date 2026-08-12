CREATE PROCEDURE "informix".sp_sac_alta_ctesremesas(
							pIdCanal 					CHAR(3),
							pejecutivo  				CHAR(8),
							pautoriza   				CHAR(8),
							pfecha_alta 				CHAR (20),
							pfuncion    				CHAR(1),
							pmapad      				CHAR(942),
							pmapai      				CHAR(942),
							pNumcte     				CHAR(20), 
							pNombre1 					CHAR(26),
							pNombre2 					CHAR(26),
							pApellPat 					CHAR(26),
							pApellMat					CHAR(26),
							pFechaNac					CHAR(20),
							pCodIdent					CHAR(2),
							pNumIdentificacion			CHAR(30),
							pClaveElector				CHAR(20),
							pNumEmision					CHAR(3),
							pPaisEmision				CHAR(3),
							pFechaVence					CHAR(20),
							pNacionalidad				CHAR(3),
							pPaisNac					CHAR(3),
							pEdoNac						CHAR(50),
							pCiudadNac					CHAR(50),
							pSexo						CHAR(1),
							pEdoDom						CHAR(2),
							pCiudadDom					CHAR(3),
							pMunicipioDom				CHAR(5),
							pColoniaDom					CHAR(60),
							pNroColDom					INTEGER,
							pCalleDom					CHAR(40),
							pNroCalleDom				INTEGER,
							pNroExte					CHAR(10),
							pNroInt						CHAR(10),
							pCodPostal					CHAR(5),
							pTelCasa					CHAR(13),
							pTelCelular					CHAR(13),
							pRfc						CHAR(13),
							pNumEnvios					CHAR(7),
							pEmpleado					CHAR(8), -- Sin uso
							psucursal   				CHAR(4),
							pTipoCliente				INTEGER,
							pTipoCteRem					CHAR(2),
							pEmpresa					CHAR(3),
							pfecha						CHAR(20), -- Sin uso
							pCodOcupacion				INTEGER,
							pOcupacion					CHAR(30),
							pDepartamento   			CHAR(6),

							pIP 						CHAR(15),
							pTipoMov 					CHAR(2),
							pVerificacion 				CHAR(2), 
							pSensor 					CHAR(2),
							pTicket 					CHAR(20), -- Sin uso

							pid_sol_mov        			CHAR(20), -- Sin uso
							pcadena_anverso    			CHAR(2200), 
							pcadena_reverso    			CHAR(2200), 
							pflag_idbox        			CHAR(1), -- Sin uso
							pflag_ws           			CHAR(1), -- Sin uso
							pflag_captura      			CHAR(1), -- Sin uso
							presultado         			CHAR(50), -- Sin uso
							pcausa_rechazo     			CHAR(100), -- Sin uso
							pCod_Resp_IFE      			CHAR(10),
							pResp_IFE          			CHAR(50), 
							pTime_IFE          			CHAR(30),  
							pAccess_IFE        			CHAR(30),
							pStamp_IFE         			CHAR(30), 
							pOCR_IFE           			CHAR(1), 
							pApPat_IFE         			CHAR(1), 
							pApMat_IFE         			CHAR(1), 
							pNombre_IFE        			CHAR(1), 
							pCalleNum_IFE      			CHAR(1),
							pColCp_IFE         			CHAR(1), 
							pMpoEnt_IFE        			CHAR(1), 
							pFolioNal_IFE      			CHAR(1), 
							pAnioReg_IFE       			CHAR(1), 
							pEmision_IFE       			CHAR(1), 
							pCveElec_IFE       			CHAR(1),
							pCurp_IFE          			CHAR(1), 
							pEstado            			CHAR(1), 
							pMpio_IFE          			CHAR(1), 
							pLocalidad_IFE     			CHAR(1), 
							pSeccion_IFE       			CHAR(1), 
							pAnioEmision_IFE   			CHAR(1),
							pVigencia_IFE      			CHAR(1), 
							pEdad_IFE          			CHAR(1), 
							pSexo_IFE          			CHAR(1),
							pANSI2_IFE         			CHAR(1), 
							pANSI7_IFE         			CHAR(1),  
							pModelo_IFE        			CHAR(25),

							pTempANSI2         			CHAR(1400), -- Sin uso
							pTempANSI7         			CHAR(1400), -- Sin uso
							pCompANSI2         			CHAR(6), 
							pCompANSI7         			CHAR(6),
							
							Pcic         				CHAR(20),

							Ptmpansi2_ife               CHAR(1400), -- Sin uso
							Ptmpansi7_ife               CHAR(1400), -- Sin uso
							Platitud                    CHAR(10),
							Plongitud                   CHAR(11),
							Pcurp 						CHAR(20),

							pstatusGral					INTEGER,
							pstatusCanal				INTEGER,
							pservicioINE				INTEGER,
							pservicioHuellas			INTEGER,
							phuellasBDD					INTEGER,

							pOp1 						CHAR(100),
							pOp2 						CHAR(200),
							pOp3 						CHAR(300))
														
						--DATOS DE SALIDA							
						RETURNING
							CHAR(5)  					AS cCodRet,
							CHAR(30)   					AS cDescCod,       
							CHAR(5)  					AS cCodRetSec,
							CHAR(30)   					AS cDescCodSec ,    
							CHAR(20) 					AS pNumcte,
							CHAR(1)	 					AS sFlagTel,
							CHAR(2000) 					AS cTramaSalida,
							CHAR (100) 					AS cOp1,
							CHAR (200) 					AS cOp2,
							CHAR (300) 					AS cOp3;
	
							--DECLARACION DE VARIABLES
							DEFINE cRfc					CHAR(20);
							DEFINE pNombre3				CHAR(40);
							DEFINE pNombreEfectuo		CHAR(40);
							DEFINE cTramaSalida			CHAR(2000);
							DEFINE cCodRetBitacora		CHAR(5);
							DEFINE cCodRetRfc			CHAR(5);
							DEFINE vcodret				CHAR(5);
							DEFINE vsigsec				CHAR(5);
							DEFINE iSqlErr        		INTEGER;
							DEFINE iIsamErr         	INTEGER;
							DEFINE cCodRet        		CHAR(5);
							DEFINE cCodRetSec        	CHAR(5);
							DEFINE cDescCod        		CHAR(50);
							DEFINE cDescCodSec       	CHAR(50);
							DEFINE sPonderacion			CHAR(10);
							DEFINE cSituacionCte		CHAR(10);
							DEFINE sCausaCte			CHAR(30);
							DEFINE iSignumcte 			INTEGER;
							DEFINE v_CodRetTel			CHAR(5);
							DEFINE v_CodRetCofetel		CHAR(5);
							DEFINE v_CorRetAper			CHAR(5);
							DEFINE v_SecAper			INTEGER;
							DEFINE v_ErrAper			INTEGER;
							DEFINE iSecuenciaDom		INTEGER;
							DEFINE cFlagCofetelCasa		CHAR(1);
							DEFINE cFlagCofetelCel		CHAR(1);
							DEFINE cSecOcupa			INTEGER;
							DEFINE sLong_cte			SMALLINT;
							DEFINE sDiferencia			SMALLINT;
							DEFINE sI 					SMALLINT;
							DEFINE sFlagTel				CHAR(1);
							DEFINE iTipoDir				INTEGER;
							DEFINE cExiste				CHAR(5);
							DEFINE cDummy 				CHAR(1);
							DEFINE vexiste				CHAR(2);
							DEFINE iTelRepetido			CHAR(2); 
							DEFINE flag_idbox           CHAR(1);
							DEFINE CompMapad			CHAR(942);
							DEFINE CompMapai			CHAR(942); 
							DEFINE	cOp1				CHAR (100);
							DEFINE	cOp2				CHAR (200);
							DEFINE	cOp3 				CHAR (300);

							-- SET DEBUG FILE TO '/informix/ENP/spHuellas/out/sp_sac_alta_ctesremesas.out';

							-- TRACE ON;

							--INICIALIZACION DE VARIABLES
							LET iSqlErr     			= 0;
							LET iIsamErr    			= 0;
							LET cCodRet	    			= '00000';
							LET cCodRetSec	    		= '00000';
							LET cDescCod				= "";
							LET cDescCodSec 			= "";
							LET cCodRetRfc   			= "";
							LET sPonderacion			= "";
							LET cSituacionCte 			= "";
							LET sCausaCte	 			= "";
							LET iSignumcte  			= 0;
							LET v_CodRetTel 			= "";
							LET cCodRetBitacora 		= "";
							LET v_CodRetCofetel 		= "";
							LET vcodret					= "";
							LET vsigsec					= "";
							
							LET v_CorRetAper			= "";
							LET cFlagCofetelCasa 		= "0";
							LET cFlagCofetelCel 		= "0";
							LET cSecOcupa 				= 0;
							LET sFlagTel				= "0";
							LET cTramaSalida 			= "0";
							LET pNombreEfectuo 			= "";
							LET cRfc 				    = "";
							LET pnombre3 				= "";
							LET iTipoDir 				= 0;
							LET cDummy					="";
							LET vexiste					='';
							LET iTelRepetido			='';

							LET flag_idbox      		= "0";
							
							LET pAutoriza				= NVL(pAutoriza, "");
							LET pNombre2				= NVL(pNombre2, "");
							LET pApellMat				= NVL(pApellMat,"");
							LET pEdoNac					= NVL(pEdoNac, "");
							LET pCiudadNac				= NVL(pCiudadNac, "");
							LET pMunicipioDom			= NVL(pMunicipioDom, "");
							LET pColoniaDom				= NVL(pColoniaDom, "");
							LET pCalleDom				= NVL(pCalleDom, "");
							LET pNroExte				= NVL(pNroExte, "");
							LET pNroInt					= NVL(pNroInt, "");
							LET pTelCasa				= NVL(pTelCasa, "");
							LET pNumEnvios				= NVL(pNumEnvios, "");
							LET pTipoCteRem				= NVL(pTipoCteRem, "");
							LET pCodOcupacion			= NVL(pCodOcupacion, 0);
							LET pOcupacion				= NVL(pOcupacion, "");
							LET pDepartamento			= NVL(pDepartamento, "");
							LET pIp						= NVL(pIp, "");
							LET pTipoMov				= NVL(pTipoMov, "");
							LET pVerificacion			= NVL(pVerificacion, "");
							LET pSensor					= NVL(pSensor, "");
							LET pcadena_anverso			= NVL(pcadena_anverso, "");
							LET pcadena_reverso			= NVL(pcadena_reverso, "");
							LET pModelo_IFE				= NVL(pModelo_IFE, "");
							LET Platitud     			= NVL(Platitud, "");
							LET Plongitud    			= NVL(Plongitud, "");
							LET pCurp					= NVL(pCurp, "");

							LET	cOp1					= '';
							LET	cOp2					= '';
							LET	cOp3					= '';
							LET CompMapad        		= "";
							LET CompMapai        		= "";

							SET ISOLATION TO DIRTY READ;	
							SET LOCK MODE TO WAIT 3;
            
BEGIN
    --CONTROL DE ERRORES 'INFORMIX' NO CONTROLADOS
    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
        END IF;
    END EXCEPTION;
        
		IF  NVL(pIdCanal ,"") = "" OR -- Canal requerido
			NVL(pejecutivo ,"") = "" OR -- Ejecutivo requerido
			NVL(pfecha_alta ,"") = "" OR -- Fecha de Alta requerido
			NVL(pfuncion ,"") = "" OR -- funcion requerido
			(pfuncion = 'A' AND (
				NVL(pNombre1 ,"") = "" OR NVL(pApellPat ,"") = "" OR
				(NVL(pmapad,"") = "" OR NVL(pmapai,"") = "")
				)) OR-- nombre1 y apellido paterno condicional, si es Alta debe recibirse
			NVL(pFechaNac,"") = "" OR -- Fecha de nacimiento requerido
			NVL(pCodIdent,"") = "" OR -- Codigo Identificacion / tipo identificacion requerido
			NVL(pNumIdentificacion ,"") = "" OR -- numero identificacion requerido
			(pCodIdent = 'A' AND NVL(pClaveElector ,"") = "") OR -- clave elector condicional
			(pCodIdent = 'A' AND LENGTH(pNumIdentificacion) = 13 AND NVL(pNumEmision ,"") = "")  OR -- numero de emision condicional con OCR
			NVL(pPaisEmision ,"") = "" OR -- Pais emision requerido
			NVL(pFechaVence,"") = "" OR -- Fecha Vence requerido
			NVL(pTelCelular,"") = "" OR -- Celular requerido
			NVL(pstatusGral ,"") = "" OR -- Se envia del motor, segun como esten en la BD RemesasWeb
			NVL(pstatusCanal ,"") = "" OR -- Se envia del motor, segun como esten en la BD RemesasWeb
			NVL(pservicioINE ,"") = "" OR -- Se envia del motor, segun como esten en la BD RemesasWeb
			NVL(pservicioHuellas ,"") = "" OR -- Se envia del motor, segun como esten en la BD RemesasWeb
			NVL(phuellasBDD ,"") = "" OR -- Se envia del motor, segun como esten en la BD RemesasWeb
			NVL(pSexo ,"") = "" THEN -- Requerido
			LET cCodRet = '00080';
			LET cDescCod = 'Falta campo requerido';
			LET cCodRetSec = "00000";
			LET cDescCodSec  = "";
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
		ELIF pfuncion = "C" AND NVL(pNumcte ,"") = "" THEN
			LET cCodRet = '00088';
			LET cDescCod = 'Num Cte no debe estar vacio';
			LET cCodRetSec = "00000";
			LET cDescCodSec  = "";	
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
		END IF;

		-- Condicionales:
		-- Alta: pfuncion = A, pNumcte = "", pTipoCliente = "3"
		-- Cambio: pfuncion = C, pNumcte = "012345678", pTipoCliente = "1" o "2"

        ---------------------------Valida que la identificacion no esta vencida---------------------------
		IF pFechaVence < TODAY THEN
            LET cCodRet = '00090';
            LET cDescCod = 'Identificacion Vencida';
            LET cCodRetSec = "00000";
            LET cDescCodSec  = "";
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
        END IF;

        IF pCodIdent <> 'A' AND (pNumEmision <> '' OR pClaveElector <> '' ) THEN
            LET cCodRet = '00099';
            LET cDescCod = 'Enviar vacio Emision/C.Elector';
            RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
        END IF;
        
		---------------------------Valida que exista Ejectivo y Sucursal---------------------------
		-- sys_hrem: Cajas
		-- sysbex: BEX
		SELECT 1 INTO vexiste
		FROM bdinteg:"informix".si_ejecut
		WHERE ejecutivo = pejecutivo;
		IF vexiste IS NULL THEN
			LET cCodRet = '10001';
			LET cDescCod = 'No existe Ejecutivo';
			LET cCodRetSec = '00000';
			LET cDescCodSec = '';
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 	
		END IF;

		-- BEX: 5011
		-- CAJAS: 8505
		SELECT 1 INTO vexiste
        FROM bdinteg:"informix".si_sucursales
		WHERE sucursal = psucursal;
		IF vexiste IS NULL THEN
			LET cCodRet = '10002';
			LET cDescCod = 'No existe sucursal';
			LET cCodRetSec = '00000';
			LET cDescCodSec  = '';	
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
		END IF;

		---------------------------Valida que el servicio del INE este DUMMY---------------------------
        SELECT oper_dummy  INTO cDummy
        FROM intercard:"informix".mc_operaciones  WHERE  id_ws ='20' AND id_oper = '89';

		-- Relacion entre flag ine con respecto a la respuesta del servicio ine
        IF (TRIM(cDummy) = 'V' OR pservicioINE = 0) and pCodIdent = 'A' THEN
            LET pFechaVence= TODAY;
        END IF;

		--------------------------- Calcula RFC --------------------------------------------------------
		IF pfuncion = "C" AND NVL(pNumCte, "") <> "" THEN
			SELECT nombre1, nombre2, apell_paterno, apell_materno
			INTO pNombre1, pNombre2, pApellPat, pApellMat
			FROM bdinteg: "informix".si_cliente 
			WHERE numcte = pNumCte;
		END IF;

		LET pNombre1 =  TRIM(pNombre1);
		LET pNombre2 =  TRIM(pNombre2);
		LET pNombre3 = pNombre1||' '||pNombre2;
		LET pApellPat = TRIM(pApellPat);
		LET pApellMat = TRIM(pApellMat);

		EXECUTE PROCEDURE bdinteg:sp_calcularrfc(pApellPat,pApellMat,pNombre3,pFechaNac::DATE) 
		INTO cCodRetRfc, cRfc;	
			
		IF NVL(cCodRetRfc,'') <> '00000' THEN
			LET cCodRet = '00220';
			LET cDescCod = 'No se pudo generar el RFC';
			LET cCodRetSec = "00000";
			LET cDescCodSec  = "";
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
		END IF;

        ---------------------------PROCESO DE ALTA/ENROLAMIENTO REMESAS---------------------------
		IF pTipoCliente = 3 AND pfuncion = 'A' THEN --Usuario Nuevo
			---------------------------Valida Clientes REPETIDOS---------------------------
			SELECT 1, numcte 
			INTO cExiste, pNumcte
			FROM bdinteg:"informix".si_cliente cte
			WHERE cte.rfc = cRfc;

			IF cExiste = 1 THEN
				LET cCodRet = '12000';
				LET cDescCod = 'Cte ya Registrado';
				LET cCodRetSec = "00000";
				LET cDescCodSec  = "";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
			END IF;

			---------------------------Valida Identificaciones Repetidas ------------------------------
			SELECT COUNT(numcte)
			INTO cExiste
			FROM bdinteg:"informix".si_ctepf ctepf
			WHERE ctepf.numidentifi = pNumIdentificacion;

			IF cExiste >= 1 THEN
				LET cCodRet = '13000';
				LET cDescCod = 'Identificacion duplicada';
				LET cCodRetSec = "00000";
				LET cDescCodSec  = "";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
			END IF;

			---------------------------Valida telefonos REPETIDOS---------------------------
			SELECT COUNT(telefono) INTO iTelRepetido
			FROM bdinteg:"informix".si_telefonos 
			WHERE telefono = pTelCelular 
			AND tipo_tel='2' 
			AND status_tel='A' 
			AND verificado != 'V';
			
			IF iTelRepetido > 0 THEN
				LET cCodRet = '50000';
				LET cDescCod = 'REVISE sp_registra_telefonos';
				LET cCodRetSec = '50002';
				LET cDescCodSec  ='Celular Registrado Previamente';
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
			END IF;
			
			---------------------------Calcula el nuevo numero de cliente---------------
			SELECT valor INTO sLong_cte
			FROM bdinteg:"informix".si_param
			WHERE cod_param = 7
			AND empresa = pEmpresa;

			SELECT valor INTO iSignumcte
			FROM bdinteg:"informix".si_param 
			WHERE empresa = pEmpresa 
			AND cod_param = 6;

			IF iSignumcte IS NULL THEN
				LET iSignumcte = 1;
			END IF;
				
			LET pNumcte = iSignumcte;
			LET iSignumcte =iSignumcte + 1;
			LET sDiferencia = sLong_cte - LENGTH(pNumcte);

			IF sDiferencia > 0 THEN
				FOR sI = 1 TO sDiferencia
					LET pNumcte = "0" || pNumcte;
				END FOR;
			END IF;
			
			UPDATE bdinteg:"informix".si_param
			SET (valor) = (iSignumcte)
			WHERE empresa = pEmpresa
			AND cod_param = 6;
			
			--------------------------- Registra los datos del cliente ---------------
			--si_cliente
			INSERT INTO bdinteg:"informix".si_cliente(Empresa, numcte, status_cte, sucursal, ejecutivo, tpo_persona, tipo_cliente, apell_paterno, apell_materno, nombre1, nombre2, razon_social,
			rfc, sector, segmento, actividad_princ, grupo, subgrupo, residencia, fecha_alta, apell_casada, distrito, numcte_ref, string1, string2, numeric1, numeric2, money1, date1, puesto_ppes, familiar_ppes,
			actividad_esp, ejecut_autoriza, user_insert, fecha_insert, rfc_alterno, tpo_biometria, cliente_pros, envio_movtos)
			VALUES(pEmpresa, pNumcte, "AL", psucursal, pejecutivo, "01", "2", UPPER(TRIM(pApellPat)), UPPER(TRIM(pApellMat)), UPPER(TRIM(pNombre1)), UPPER(TRIM(pNombre2)), "", cRfc, "32", "000", "000", "000", 
			"000","1", pfecha_alta::DATE, "", "01", "", "", "", 0, 0, 0, pfecha_alta::DATE, "", "", "0000000", pejecutivo, pejecutivo, DATE(current), "", "0", "", 0);
			--si_ctepf
			INSERT INTO bdinteg:"informix".si_ctepf(empresa, numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss, dependientes,
			tutor, nom_conyuge, seguro_defunc, escolaridad, habita_en,anios_habita, nombre_prop, imp_hipo_renta, actividadogiro, numeroife, numerotutor, numeroconyuge, string1, string2, numeric1, numeric2, money1,
			date1, user_insert, fecha_insert, sms_cel, hora_insert, validacurp, id_pais)
			VALUES(pEmpresa, pNumcte, pFechaNac::date, pEdoNac, pNacionalidad, "", "", "", "", pSexo, Pcurp, pCodIdent, pNumIdentificacion, "", 0, "", "", 0, "", "", "", "", 0, "", "", "", "", "", "", 0, 0, 0, NULL, 
			pejecutivo, pfecha_alta::DATE, "", CURRENT, "", pPaisNac);
			--si_direcciones
			INSERT INTO bdinteg:"informix".si_direcciones(numcte,secuencia,tipo_dir,calle,colonia,entre_calles,pais,estado,ciudad,municipio,cod_postal,apart_postal,estado_inegi,municipio_inegi,
			localidad_inegi,numerociudad, numeroextcalle, numerointcalle,departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, 
			entrada, observaciones, user_insert, fecha_insert)
			VALUES(pNumcte, "1", "1", pCalleDom, pColoniaDom, "", "001", pEdoDom, pCiudadDom, pMunicipioDom, pCodPostal, "", "", "", "", 0, pNroExte, pNroInt, pDepartamento, pNroCalleDom, pNroColDom, "", 
			"", 0, 0, 0, 0, 0, 0, 0, "", pejecutivo, pfecha_alta::DATE);
			--Inserta en sac_cte_remesas
			INSERT INTO bdisac:"informix".sac_cte_remesas(numcte, fecha_alta, sucursal, status_cte, tipo_cte, pais_emision, fecha_vencimiento, usuario, fecha_insert, numenvios, ciudadnacimiento, claveelector, pnumemision, ocupacion)
			VALUES(pNumcte, pfecha_alta::DATE, psucursal, "A", pTipoCteRem, pPaisEmision, pFechaVence::DATE, pejecutivo, current, pNumEnvios, pCiudadNac, pClaveElector, pNumEmision, pOcupacion); 
			
			---------------------------- Guarda ocupacion --------------------------
			SELECT MAX(id_secuencia) INTO cSecOcupa 
			FROM bdinteg:"informix".si_bitacoraapertura 
			WHERE rfc = cRfc;
                    
			IF NVL(cSecOcupa,"") = "" THEN
				LET cSecOcupa  = 1;
			ELSE
				LET cSecOcupa = cSecOcupa + 1;
			END IF;
    
			CALL bdinteg:"informix".sp_bitacoraapertura (cRfc, pNumcte, 6, "", pCodOcupacion, pOp1, "", pfecha_alta::DATE, psucursal, cSecOcupa, "", "") 
			RETURNING v_CorRetAper, v_SecAper, v_ErrAper;
			
			IF v_CorRetAper <> 0 THEN 
				LET cCodRetSec = "40000";
				LET cDescCodSec  = "Error al insertar en bitacora de apertura";
			END IF;

			EXECUTE PROCEDURE bdinteg:"informix".sp_ctehuella(pempresa, psucursal, pejecutivo, pautoriza, pfecha_alta, pfuncion, pNumcte, pmapad, pmapai) 
			INTO vcodret, vsigsec;

			IF vcodret  = 131  THEN
				LET cCodRet = '70000';
				LET cDescCod = 'REVISE sp_ctehuella';
				LET cCodRetSec = '70006';
				LET cDescCodSec  ='Ya existe huella registrada';
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			ELIF vcodret  = 110  THEN
				LET cCodRet = '70000';
				LET cDescCod = 'REVISE sp_ctehuella';
				LET cCodRetSec = '70004';
				LET cDescCodSec  ='Campo NumCte o Huellas Vacio';
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			ELIF vcodret = 120 THEN
				LET cCodRet = '70000';
				LET cDescCod = 'REVISE sp_ctehuella';
				LET cCodRetSec = '70002';
				LET cDescCodSec  ='No es persona fisica';
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			ELIF vcodret = 130 THEN
				LET cCodRet = '70000';
				LET cDescCod = 'REVISE sp_ctehuella';
				LET cCodRetSec = '70003';
				LET cDescCodSec  ='Funcion diferente de A o C';
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			END IF
		---------------------------PROCESO DE ACTUALIZACION REMESAS--------------------------
		ELIF (pTipoCliente = 1 OR pTipoCliente = 2) AND pfuncion = 'C' THEN
			-- Valida si esta activa la bandera para comparar con las huellas registradas en BD
			IF phuellasBDD = 1 THEN -- Nacimiento de canales: Cajas (Apagado), BEX (Apagado)
				 EXECUTE PROCEDURE sp_valida_ctehuella_comp(pNumcte) INTO vcodret,CompMapad,CompMapai;
				 IF vcodret <> '00000'  THEN
					LET cCodRet  = '50000';
                    LET cDescCod = 'Revise sp_valida_ctehuella_comp';
                    RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;				
				 END IF;
				
				IF pmapad <> CompMapad AND pmapai <> CompMapai THEN
					LET cCodRet = '00070';
					LET cDescCod = 'Huellas NO COINCIDEN CON BD';
					RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
				END IF;
			END IF;
			
			--Actualiza rfc en si_cliente
			UPDATE bdinteg:"informix".si_cliente 
			SET rfc = cRfc
			WHERE numcte = pNumcte;

			---------------------------Valida Identificaciones Repetidas ------------------------------
			SELECT COUNT(numcte)
			INTO cExiste
			FROM bdinteg:"informix".si_ctepf ctepf
			WHERE ctepf.numcte <> pNumcte AND ctepf.numidentifi = pNumIdentificacion;

			IF cExiste >= 1 THEN
				LET cCodRet = '13000';
				LET cDescCod = 'Identificacion duplicada';
				LET cCodRetSec = "00000";
				LET cDescCodSec  = "";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
			END IF;

			--Actualiza si_ctepf
			UPDATE bdinteg:"informix".si_ctepf 
			SET fecha_nac = pFechaNac::Date, nacionalidad = pNacionalidad, sexo = pSexo, codidentifi = pCodIdent, numidentifi = pNumIdentificacion, id_pais = pPaisNac
			WHERE numcte = pNumcte;
						
			--Actualiza al cliente enrolado sac_ctes_remesas
			IF pTipoCliente = 1 THEN
					UPDATE bdisac:"informix".sac_cte_remesas 
					SET numcte = pNumcte, fecha_actualizacion = current::DATE, sucursal = psucursal, status_cte = "A", tipo_cte = pTipoCteRem, pais_emision = pPaisEmision, fecha_vencimiento = pFechaVence::DATE,
					usuario = pejecutivo, fecha_insert = current, rfc = cRfc, numenvios = pNumEnvios, ciudadnacimiento = pCiudadNac, claveelector = pClaveElector, pnumemision = pNumEmision, ocupacion = pOcupacion
					WHERE numcte = pNumcte;
			ELSE -- Enrola al cliente que no habia sido enrolado (TIPO CLIENTE 2)
				INSERT INTO bdisac:"informix".sac_cte_remesas(numcte,fecha_alta,sucursal,status_cte,tipo_cte,pais_emision,fecha_vencimiento,usuario,fecha_insert,numenvios,ciudadnacimiento, claveelector,pnumemision,ocupacion)
				VALUES(pNumcte, pfecha_alta::DATE, psucursal, "A", pTipoCteRem, pPaisEmision, pFechaVence::DATE, pejecutivo, current, pNumEnvios, pCiudadNac, pClaveElector, pNumEmision, pOcupacion); 
			END IF;

			--Se verifica si el cliente tiene tipo de direccion 1, si no, se inserta nueva direccion de tipo 1
			SELECT tipo_dir, secuencia INTO iTipoDir, iSecuenciaDom
			FROM bdinteg:"informix".si_direcciones_actual 
			WHERE numcte = pNumcte 
			AND tipo_dir = 1 
			AND secuencia = (
				SELECT MAX(secuencia) 
				FROM bdinteg:"informix".si_direcciones_actual 
				WHERE numcte = pNumcte 
				AND tipo_dir = 1);

			IF NVL(iTipoDir,0) = 0 THEN
				SELECT MAX(secuencia) INTO iSecuenciaDom 
				FROM bdinteg:"informix".si_direcciones_actual 
				WHERE numcte = pNumcte;

				IF NVL(iSecuenciaDom,0) = 0 THEN
					LET iSecuenciaDom = 1;
				ELSE
					LET iSecuenciaDom = iSecuenciaDom + 1;
				END IF;
				
				INSERT INTO bdinteg:"informix".si_direcciones(numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal, apart_postal, estado_inegi, municipio_inegi, 
				localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle, numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones, user_insert, fecha_insert)
				VALUES(pNumcte, iSecuenciaDom, "1", pCalleDom, pColoniaDom, "", "001", pEdoDom, pCiudadDom, pMunicipioDom, pCodPostal, "", "", "", "", 0, pNroExte, pNroInt, pDepartamento, pNroCalleDom, 
					pNroColDom, "", "", 0, 0, 0, 0, 0, 0, 0, "", pejecutivo, pfecha_alta::DATE);
			ELSE				
				UPDATE bdinteg:"informix".si_direcciones_actual	SET
				calle = pCalleDom, colonia = pColoniaDom, estado = pEdoDom, ciudad = pCiudadDom, municipio = pMunicipioDom, cod_postal = pCodPostal, 
				numeroextcalle = pNroExte, numerointcalle = pNroInt, departamento = pDepartamento, numerocalle = pNroCalleDom, numerocolonia = pNroColDom
				WHERE numcte = pNumcte AND tipo_dir = iTipoDir AND secuencia = iSecuenciaDom;  
			END IF;

			IF pservicioHuellas = 1 THEN
				--Inserta en genera huella linea
				CALL bdinteg:"informix".sp_generahuellalinea_outbound(pNumCte, pIP, pTipoMov, pejecutivo, pVerificacion, pSensor)
				RETURNING cCodRet, cTramaSalida;

				IF cCodRet <> 00000 THEN
					LET cDescCod ='Error al insertar en si_huella_linea';
					LET cCodRetSec = '11000';
					RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
				END IF;
			END IF;
		ELSE 
			LET cCodRet  = '80000';
			LET cDescCod    = 'No Valido';
			LET cCodRetSec  = "80001";
			LET cDescCodSec = "Funcion o Tipo de Cliente";
			RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 
		END IF;	

		----------------------------Validaciones telefonos--------------------------
		--- solo aplica la insercion o actualizacion de telefonos para canales diferentes de BEX
		IF TRIM(pTelCasa) <> "" AND pIdCanal <> 2 THEN
			--Registra telefono de casa y valida con cofetel.
			CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumcte, pTelCasa, 1, "", 0, 1, pejecutivo) 
			RETURNING v_CodRetTel;

			IF  v_CodRetTel <> 0 THEN 
				LET cCodRet = '50000';
				LET cDescCod = 'REVISE sp_registra_telefonos';
				LET cCodRetSec = "50001";
				LET cDescCodSec  = "Telefono de Casa Invalido";
				LET sFlagTel = "1";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			END IF;
		
			SELECT "1" INTO cFlagCofetelCasa
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = pNumcte 
			AND telefono = pTelCasa 
			AND status_tel = "A" 
			AND tipo_tel = "1";
		
			IF NVL(cFlagCofetelCasa,"") = "" THEN
				LET cFlagCofetelCasa = "0";
			END IF;
		END IF;
					
		--Registra celular y valida con cofetel.
		--- solo aplica la insercion o actualizacion de telefonos para canales diferentes de BEX

		IF  pIdCanal <> 2 THEN
			CALL bdinteg:"informix".sp_registra_telefonos(pEmpresa, pNumcte, pTelCelular, 2, "", 0, 1, pejecutivo) 
			RETURNING v_CodRetTel;
			
			IF v_CodRetTel  = 1166  THEN
				LET cCodRet = '50000';
				LET cDescCod = 'REVISE sp_registra_telefonos';
				LET cCodRetSec = '50002';
				LET cDescCodSec  ='Celular Registrado Previamente';
				LET sFlagTel = "2";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			ELIF v_CodRetTel = 104 THEN
				LET cCodRet = '50000';
				LET cDescCod = 'REVISE sp_registra_telefonos';
				LET cCodRetSec = '50003';
				LET cDescCodSec  ='Celular Invalido';
				LET sFlagTel = "2";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			ELIF v_CodRetTel = 1169 THEN
				LET cCodRet = '50000';
				LET cDescCod = 'REVISE sp_registra_telefonos';
				LET cCodRetSec = '50004';
				LET cDescCodSec  ='Celular cancelado';
				LET sFlagTel = "2";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			ELIF v_CodRetTel = 1168 THEN
				LET cCodRet      = '50000';
				LET cDescCod     = 'REVISE sp_registra_telefonos';
				LET cCodRetSec   = '50004';
				LET cDescCodSec  ='Celular no Validado';
				LET sFlagTel     = "2";
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;
			END IF;
			
			--Validacion cofetel
			SELECT 1 INTO cFlagCofetelCel
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = pNumcte 
			AND telefono = pTelCasa 
			AND status_tel = "A" 
			AND tipo_tel = "2";
			
			IF NVL(cFlagCofetelCel,"") = "" THEN
				LET cFlagCofetelCel = "0";
			END IF
			
			CALL bdinteg:"informix".sp_actvalidacioncofetel (pEmpresa, pNumcte, cFlagCofetelCasa, cFlagCofetelCel, "0", "1", "1") 
			RETURNING v_CodRetCofetel;
			
			IF  v_CodRetCofetel <> 0 THEN 
				LET cCodRetSec = "60000";
				LET cDescCod = 'REVISE sp_actvalidacioncofetel';
			END IF;
		END IF;
		--Inserta registros pendientes por validar ante el INE
		IF pCodIdent = 'A' THEN
			IF pservicioINE = 0 OR TRIM(cDummy) = 'V' OR pCod_Resp_IFE = '89' THEN 
				CALL bdinteg: "informix".sp_registra_consultas_ine_pendiente(Pnumcte, pApellPat, pApellMat, pNombre1, Pcurp, 
				pAnioReg_IFE, pNumEmision, pClaveElector, pNumIdentificacion, Pcadena_anverso, Pcadena_reverso, pmapad, pmapai, 
				psucursal, 0, Pejecutivo, Pflag_idbox, Pflag_ws, Pflag_captura, Pmodelo_ife, Platitud, Plongitud, Pcic)
				RETURNING cCodRet;
			ELIF (pservicioINE = 1 AND TRIM(cDummy) ='F') AND pCodIdent='A' THEN
				IF pcadena_anverso <> "" OR pcadena_reverso <> "" THEN
					LET flag_idbox = "1";
				END IF;

				--valida huella en INE
				CALL bdinteg:"informix".sp_bitacora_ife(pNumcte, pejecutivo, psucursal, pcadena_anverso, pcadena_reverso, flag_idbox, pservicioINE, '', '', '',
				pCod_Resp_IFE, pResp_IFE, pTime_IFE,  pAccess_IFE, pStamp_IFE, pOCR_IFE, pApPat_IFE, pApMat_IFE, pNombre_IFE, pCalleNum_IFE,
				pColCp_IFE, pMpoEnt_IFE, pFolioNal_IFE, pAnioReg_IFE, pEmision_IFE, pCveElec_IFE, pCurp_IFE, pEstado, pMpio_IFE, pLocalidad_IFE, pSeccion_IFE, pAnioEmision_IFE,
				pVigencia_IFE, pEdad_IFE, pSexo_IFE, pANSI2_IFE, pANSI7_IFE, pModelo_IFE, pmapad, pmapai, pCompANSI2, pCompANSI7)
				RETURNING cCodRetBitacora;
				--SI se llega a presentar este caso para el canal de BEX se hace rollback de la tabla sac_cte_remesas
				IF cCodRetBitacora <> '00000' and pIdCanal = 2 THEN
					LET cDescCod ='Error al insertar en bitacora_ife';
					LET cCodRetSec = '80000';
					DELETE FROM bdisac:sac_cte_remesas where numcte = pNumcte;
					RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;  
				ELIF cCodRetBitacora <> '00000' and pIdCanal <> 2 THEN
					LET cDescCod ='Error al insertar en bitacora_ife';
					LET cCodRetSec = '80000';
					RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;  
				END IF;
			END IF;

			--inserta en bitacora huella ine
			CALL bdinteg:"informix".sp_bitacora_huella_ine (Pnumcte,pNumIdentificacion,psucursal,Pejecutivo)
			RETURNING cCodRet;
			--SI se llega a presentar este caso para el canal de BEX se hace rollback de la tabla sac_cte_remesas

			IF cCodRet <> '00000' and pIdCanal = 2 THEN
			  	LET cCodRet = '00000';
				LET cDescCod ='Error al insertar en sp_bitacora_huella_ine';
				LET cCodRetSec = '90000';
				DELETE FROM bdisac:sac_cte_remesas where numcte = pNumcte;
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;  
			ELIF cCodRet <> '00000' and pIdCanal <> 2 THEN
				LET cDescCod ='Error al insertar en sp_bitacora_huella_ine';
				LET cCodRetSec = '90000';
				RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3;  
			END IF;
		END IF;
		
		IF pfuncion = 'A' THEN
			LET cCodRet = '00000';
			LET cDescCod = 'Alta Exitosa';									
			LET cCodRetSec = '00000';
			LET cDescCodSec  ='OK';
		ELSE 
			LET cDescCod ='Cliente Actualizado';
			LET cCodRetSec = '00000';
		END IF;

		RETURN cCodRet, cDescCod, cCodRetSec, cDescCodSec, pNumcte, sFlagTel, cTramaSalida, cOp1, cOp2, cOp3; 			
END;
END PROCEDURE;