CREATE PROCEDURE "informix".sp_adicionalcreditopendiente_web(pempresa CHAR(3), 
														pNumCteTitular CHAR(20),
														pNumTarjetaTitular CHAR(20),
														pNumCteAdicional CHAR(20),
														pCredito CHAR(20),
														pApell_Paterno CHAR(26),
														pApell_Materno CHAR(26),
														pNombre1 CHAR(26),
														pNombre2 CHAR(26),
														pRfc CHAR(13),
														pFechaNacimiento CHAR(10),
														pProductoCredito CHAR(4),
														pTarjetaReposicion CHAR(20),
														pTipoEjecucion CHAR(1))												
RETURNING 
	CHAR (5) AS codRet,
	CHAR (20) AS NumCteAdicional,
	CHAR (20) AS Credito,
	CHAR (26) AS Apell_Paterno,
	CHAR (26) AS Apell_Materno,
	CHAR (26) AS Nombre1,
	CHAR (26) AS Nombre2,
	CHAR (13) AS Rfc,
	CHAR (10) AS FechaNacimiento,
	CHAR (4) AS ProductoCredito,
	CHAR (20) AS TarjetaReposicion;
	

	DEFINE ccodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cNumCteAdicional CHAR(20);
	DEFINE cCredito CHAR(20);
	DEFINE cApell_Paterno CHAR(26);
	DEFINE cApell_Materno CHAR(26);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cRfc CHAR(13);
	DEFINE cFechaNacimiento CHAR(10);
	DEFINE cProductoCredito CHAR(4);
	DEFINE cTarjetaReposicion CHAR(20);
	DEFINE sConreg SMALLINT;
	
	LET ccodRet = '00000';
	LET iSqlErr = 0;
	LET cNumCteAdicional = '';
	LET cCredito = '';
	LET cApell_Paterno = '';
	LET cApell_Materno = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cRfc = '';
	LET cFechaNacimiento = '';
	LET cProductoCredito = '';
	LET cTarjetaReposicion = '';
	LET sConreg = 0;
	
	
    BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET ccodRet = iSqlErr;
			   RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
			END IF;
		END EXCEPTION;

		 --SET DEBUG FILE TO '/respaldosbd/Alexis/trace1.out';
		 --TRACE ON;	
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
	
	IF NVL(pTipoEjecucion,'') <> '' THEN
		
		IF NVL(pTipoEjecucion,'') = '1' Then
			---INSERT
			IF NVL(pNumCteTitular,'') <> '' AND
			NVL(pNumTarjetaTitular,'') <> '' AND
			NVL(pNumCteAdicional,'') <> '' AND
			NVL(pCredito,'') <> '' AND
			NVL(pApell_Paterno,'') <> '' AND
			NVL(pNombre1,'') <> '' AND
			NVL(pRfc,'') <> '' AND
			NVL(pFechaNacimiento,'') <> '' AND
			NVL(pProductoCredito,'') <> '' Then
				
				SELECT NumCteAdicional, Credito, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, FechaNacimiento, ProductoCredito,TarjetaReposicion 
				INTO cNumCteAdicional, cCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2, cRfc,cFechaNacimiento, cProductoCredito,cTarjetaReposicion
				FROM bdicred:"informix".sd_adicionalespendientes 
				WHERE Credito = pCredito 
				AND NumCteTitular = pNumCteTitular 
				AND NumCteAdicional = pNumCteAdicional;
				
				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
					LET cCodRet = '00000';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;	
				
				INSERT INTO bdicred:"informix".sd_adicionalespendientes(empresa,NumCteTitular,NumTarjetaTitular,NumCteAdicional,Credito,Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion)
				VALUES (pempresa,pNumCteTitular,pNumTarjetaTitular,pNumCteAdicional,pCredito,pApell_Paterno,pApell_Materno,pNombre1,pNombre2,pRfc,pFechaNacimiento,pProductoCredito, pTarjetaReposicion);

			ELSE
				LET ccodRet = "00002";
			END IF;
		END IF;
		
		IF NVL(pTipoEjecucion,'') = '2' Then
			--Obtiene datos del cliente
			IF NVL(pNumCteTitular,'') <> '' AND
			NVL(pNumTarjetaTitular, '') = '' AND
			NVL(pCredito,'') <> '' Then
			
				FOREACH
			
							SELECT NumCteAdicional, Credito, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, FechaNacimiento, ProductoCredito,TarjetaReposicion 
							INTO cNumCteAdicional, cCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2, cRfc,cFechaNacimiento, cProductoCredito,cTarjetaReposicion
							FROM bdicred:"informix".sd_adicionalespendientes 
							WHERE Credito = pCredito 
							AND (NumCteTitular = pNumCteTitular 
							OR NumCteAdicional = pNumCteAdicional)
							
							IF DBINFO('sqlca.sqlerrd2') = 0 THEN
								LET cCodRet = '00004';
								RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
							END IF;	

							LET ccodRet = "00000";
							RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito, cTarjetaReposicion WITH RESUME;
							
				END FOREACH;
				
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00004';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;	
				
				RETURN;
				
			ELSE
				LET ccodRet = "00003";
			END IF;
			
			IF NVL(pNumTarjetaTitular,'') <> '' AND
			NVL(pNumCteTitular,'') = '' AND
			NVL(pCredito,'') <> '' Then
			
				FOREACH

						SELECT NumCteAdicional,Credito, Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion
						INTO cNumCteAdicional,cCredito, cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion
						FROM bdicred:"informix".sd_adicionalespendientes
						WHERE NumTarjetaTitular = pNumTarjetaTitular
					
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cCodRet = '00004';
							RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
						END IF;	
						
						LET ccodRet = "00000";
						RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion WITH RESUME;

				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00004';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;
				
				RETURN;
				
			ELSE
				LET ccodRet = "00003";
			END IF;
			

			IF NVL(pCredito,'') <> '' AND
			NVL(pNumTarjetaTitular,'') = '' AND
			NVL(pNumCteTitular,'') = '' Then
				
				FOREACH
				
					SELECT NumCteAdicional,Credito,Apell_Paterno,Apell_Materno,Nombre1,Nombre2,Rfc,FechaNacimiento,ProductoCredito,TarjetaReposicion
					INTO cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion
					FROM bdicred:"informix".sd_adicionalespendientes
					WHERE Credito = pCredito
					
					IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCodRet = '00004';
						RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
					END IF;	
					
					LET ccodRet = "00000";
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion WITH RESUME;

				END FOREACH;
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00004';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;
				
				RETURN;

			Else
				LET ccodRet = "00003";
			END IF;
				
		END IF;
		
		
		IF NVL(pTipoEjecucion,'') = '3' Then
			--Validar si existe
				SELECT NumCteAdicional, Credito, Apell_Paterno, Apell_Materno, Nombre1, Nombre2, Rfc, FechaNacimiento, ProductoCredito,TarjetaReposicion
				INTO cNumCteAdicional, cCredito, cApell_Paterno, cApell_Materno, cNombre1, cNombre2, cRfc, cFechaNacimiento, cProductoCredito,cTarjetaReposicion
				FROM bdicred:"informix".sd_adicionalespendientes 
				WHERE empresa = pempresa
				AND NumCteTitular = pNumCteTitular
				AND NumTarjetaTitular = pNumTarjetaTitular
				AND NumCteAdicional = pNumCteAdicional
				AND Credito = pCredito;

				IF DBINFO('sqlca.sqlerrd2') = 1 THEN
					LET cCodRet = '00007';
					RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
				END IF;	
		END if;
		
		IF NVL(pTipoEjecucion,'') = '4' Then
			--ELIMINA REGISTRO DE sd_adicionalespendientes
			
			DELETE FROM bdicred:"informix".sd_adicionalespendientes
			WHERE empresa = pempresa
			AND NumCteTitular = pNumCteTitular
			AND NumTarjetaTitular = pNumTarjetaTitular
			AND NumCteAdicional = pNumCteAdicional
			AND Credito = pCredito;
			
			LET ccodRet = "00000";
		
		END IF;

		IF NVL(pTipoEjecucion,'') <> '1' AND
		NVL(pTipoEjecucion,'') <> '2' AND
		NVL(pTipoEjecucion,'') <> '3' AND
		NVL(pTipoEjecucion,'') <> '4' Then
				LET ccodRet = "00005";
		End If;

	ELSE
		LET ccodRet = "00001";
	END IF;
	
	RETURN ccodRet,cNumCteAdicional,cCredito,cApell_Paterno,cApell_Materno,cNombre1,cNombre2,cRfc,cFechaNacimiento,cProductoCredito,cTarjetaReposicion;
	
END;
END PROCEDURE

DOCUMENT
'Folio: 226 - RQM 10 810 Solicitud de Tarjetas Adicionales Tarjeta de CrÃ©dito.',
'Autor: 97247642 - Ibarra Verdugo Oscar Alexis',
'BD: bdicred',
'Solicita:	Abraham Narvaez',
'Fecha: 15/11/2017',
'Descripcion: Se crea un procedimiento almacenado el cual guarde y obtenga los datos del cliente que realizÃ³ la solicitud de la tarjeta adicional para los productos oro y platino.';

CREATE PROCEDURE "informix".sp_chi_integra_reg_contables ()
	RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	--Creado por: Isaac Flores Ruiz
	--Fecha de creación: 23/03/2021
	--Peticion: RQM 10 1404
	--Modificado por: Isaac Flores Ruiz
	--Fecha de modificación: 10/08/2021, 24/11/2021
	--Modificación: Cambio de variable Centro de Costos.
	--				Control de error retornado por bdicred:"informix".sp_ce_cointegracion.
	--BD: bdicred
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 INTEGER;
    DEFINE     	isam_err                INTEGER;
    DEFINE     	error_info              CHAR(40);
    DEFINE     	cod_ret                 CHAR(6);
	DEFINE	   	mensaje_ret				VARCHAR(255);
    DEFINE     	cod_ret_aux             CHAR(6);
	DEFINE	   	mensaje_ret_aux			VARCHAR(255);
    DEFINE     	cod_ret_poliza          CHAR(6);
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
	DEFINE 		v_cempresa	            CHAR(4);
	DEFINE 		v_ccosto_orig	        CHAR(4);
	DEFINE 		v_cusuario	            CHAR(8);
	DEFINE 		v_cregional	            CHAR(4);
	DEFINE 		v_csucursal	            CHAR(4);
	DEFINE 		v_cnro_auxiliar	        CHAR(4);
	DEFINE 		v_cprocesado	        CHAR(2);
	DEFINE 		v_cdescmoneda	        CHAR(4);
	DEFINE 		v_mtotalabono           MONEY(18,2);
	DEFINE 		v_mtotalcargo           MONEY(18,2);

	DEFINE 		v_cta	                CHAR(4);
	DEFINE 		v_subcta                CHAR(2);
	DEFINE 		v_subsubcta             CHAR(2);
	DEFINE 		v_ssubsubcta            CHAR(2);
	DEFINE 		v_sssubsubcta           CHAR(2);
	DEFINE 		v_sector                CHAR(2);
	DEFINE 		v_fechacaptura          DATE;
	DEFINE 		v_fechaintegracion      DATE;
	DEFINE 		v_moneda                CHAR(2);
	DEFINE 		v_naturaleza            CHAR(1);
	DEFINE 		v_importe               MONEY(18,2);
	DEFINE 		v_concepto              CHAR(80);
	DEFINE 		v_mensaje               CHAR(50);
	DEFINE 		v_status	            CHAR(8);
	DEFINE 		v_integra               INTEGER;
	DEFINE 		v_numtotal              SMALLINT;
	DEFINE	   	v_control_poliza		INTEGER;
	DEFINE	   	v_idcontrol				INTEGER;
	DEFINE	   	v_idcontrolini			INTEGER;
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE 		cRutaLayout				CHAR(100);
	DEFINE 		cRutaReporte			CHAR(100);
	DEFINE 		cSQL                    CHAR(1000);
	DEFINE 		cNomSQL                 CHAR(100);
	DEFINE 		cDia					CHAR(2);
	DEFINE 		cMes					CHAR(2);
	DEFINE 		cYear				    CHAR(4);
	DEFINE 		cArchivoLay			    CHAR(100);
	DEFINE 		cArchivoRep			    CHAR(100);
	DEFINE 		cNombreArchivo		    CHAR(100);
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';
    LET 	   	cod_ret_aux 			= '00000'; 
	LET 	   	mensaje_ret_aux 		= '';
    LET 	   	cod_ret_poliza			= '00000'; 
-- ****************************************************************************
-- *                    INICIALIZACION DE VARIABLES                           *
-- ****************************************************************************
	LET 		v_cempresa	   	      	= '001';
	LET 		v_ccosto_orig		    = '8510';
	LET 		v_cusuario	   	      	= 'CHICONT';
	LET 		v_cregional	   	      	= '900';
	LET 		v_csucursal	   	      	= '9551';
	LET 		v_cnro_auxiliar	      	= '';
	LET 		v_cprocesado	      	= 'SI';
	LET 		v_mtotalabono			= 0.0;
	LET 		v_mtotalcargo			= 0.0;
	
	LET 		v_subcta      			= '';
	LET 		v_subsubcta   			= '';
	LET 		v_ssubsubcta  			= '';
	LET 		v_sssubsubcta 			= '';
	LET 		v_sector      			= '';
	LET			v_fechacaptura			= today;
	LET			v_fechaintegracion		= today;
	LET 		v_moneda      			= '';
	LET 		v_naturaleza  			= '';
	LET 		v_importe 				= 0.0;
	LET 		v_concepto 				= ' ';
	LET 		v_mensaje 				= ' ';
	LET 		v_status 				= ' ';
	LET 		v_integra 				= 0;
	LET 		v_numtotal 				= 0;
	LET 	   	v_control_poliza 		= 0;
	LET 	   	v_idcontrol		 		= 0;
	LET 	   	v_idcontrolini 			= 0;
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRutaLayout	 			= "/resplogifx/hipotecario_infonavit/operaciones/";
	LET 		cRutaReporte 			= "/RESPALDOSNEW/hipotecario_infonavit/operaciones/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_temp_rep_cont_reg_cont.sql";
	LET 		cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET 		cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		cArchivoLay				= "chi_ope_lay_reg_contables_";
	LET 		cArchivoRep				= "chi_ope_rep_PolizasHITO_";
	LET			cNombreArchivo			= "";
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
    BEGIN
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';	
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;

		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '22222';		
				LET mensaje_ret = 'VERIFICAR RUTA DEL ARCHIVO A EJECUTAR';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'VERIFICAR TIPOS DE DATOS O LONGITUDES';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
				
				DROP TABLE bdicred:"informix".sd_chi_carga_reg_cont;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'VERIFICAR REGISTROS DUPLICADOS';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-391) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '55555';		
				LET mensaje_ret = 'VERIFICAR CAMPOS, INSERCIÓN DE NULOS';
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
		--SET DEBUG FILE TO '/informix/SD/sp_chi_integra_reg_contables.out';
		--TRACE ON;                                                     --*
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	
-- ****************************************************************************
-- *                       IMPORTACIÓN DE ARCHIVO                             *
-- ****************************************************************************	
    
        DELETE FROM bdicred:"informix".sd_chi_carga_reg_cont;
		
		SELECT MAX(id)
		INTO v_idcontrolini
		FROM bdicred:"informix".sd_chi_carga_reg_cont_hist;
		
        IF v_idcontrolini IS NULL THEN 
           LET  v_idcontrolini = 1;
        END if;

            LET v_idcontrol = v_idcontrolini + 1;

		SELECT LPAD(YEAR(fecha_hoy), 4, '0') INTO cYear FROM bdicred:sd_fechas WHERE empresa = '001';
		SELECT LPAD(MONTH(fecha_hoy), 2, '0') INTO cMes FROM bdicred:sd_fechas WHERE empresa = '001';
		SELECT LPAD(DAY(fecha_hoy), 2, '0') INTO cDia FROM bdicred:sd_fechas WHERE empresa = '001';
		
		LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
		LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; LOAD FROM ' || TRIM(cRutaLayout) || TRIM(cNombreArchivo) || 
			' INSERT INTO bdicred:"informix".sd_chi_carga_reg_cont;' || "" || '">'||TRIM(cRutaLayout)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);

		LET cSQL='chmod 777 '|| TRIM(cRutaLayout)|| TRIM(cNomSQL);
		SYSTEM cSQL;

		LET cSQL = 'dbaccess bdicred ' || TRIM(cRutaLayout) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRutaLayout) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
-- ****************************************************************************
-- *                      INTEGRACIÓN DE REGISTROS                            *
-- ****************************************************************************	
		FOREACH WITH HOLD
			
			SELECT cta, subcta, subsubcta, ssubsubcta, sssubsubcta, 
				sector, fechacaptura, fechaintegracion, moneda, naturaleza, 
				importe, concepto, indregistro, numregistros 
			INTO v_cta, v_subcta, v_subsubcta, v_ssubsubcta, v_sssubsubcta, 
				v_sector, v_fechacaptura, v_fechaintegracion, v_moneda, v_naturaleza, 
				v_importe, v_concepto, v_integra, v_numtotal
			FROM bdicred:"informix".sd_chi_carga_reg_cont
			
			EXECUTE PROCEDURE bdicred:"informix".sp_ce_cointegracion ( 
				v_cempresa, v_ccosto_orig, v_cusuario, v_fechacaptura, v_cta, 
				v_subcta, v_subsubcta, v_ssubsubcta, v_sssubsubcta, v_sector, 
				v_cregional, v_csucursal, v_cnro_auxiliar, v_fechaintegracion, v_moneda, 
				v_naturaleza, v_importe, v_concepto, v_cusuario, v_integra,
				v_numtotal
			)
			INTO cod_ret_poliza, mensaje_ret, v_control_poliza;			
			
			EXECUTE PROCEDURE bdicred:"informix".sp_ce_obtendescripcionerror (
				cod_ret_poliza, ''
			)INTO cod_ret_aux, mensaje_ret_aux;
			
			IF mensaje_ret_aux IS NOT NULL THEN
				LET mensaje_ret = mensaje_ret_aux;
			END IF
-- ****************************************************************************
-- *                          PASE A HISTORICO                                *
-- ****************************************************************************	
			IF cod_ret_poliza <> '00000' THEN
				LET v_cprocesado = 'NO';
			END IF
			
			IF v_naturaleza = 'C' THEN 
				LET v_mtotalcargo = v_mtotalcargo + v_importe;
			END IF
			
			IF v_naturaleza = 'D' THEN 
				LET v_mtotalabono = v_mtotalabono + v_importe;
			END IF
			
			SELECT sigla 
			INTO v_cdescmoneda
			FROM bdinteg:"informix".si_divisas
			WHERE divisa = v_moneda;
			
			INSERT INTO bdicred:"informix".sd_chi_carga_reg_cont_hist (
				id, cta, subcta, subsubcta, ssubsubcta, 
				sssubsubcta, sector, fechacaptura, fechaintegracion, moneda, 
				naturaleza, importe, concepto, indregistro, numregistros, 
				procesado, status, usuario, descmoneda, centrocostos, 
				region, cuentaauxiliar, mensaje, poliza 
			) VALUES (
				v_idcontrol, v_cta, v_subcta, v_subsubcta, v_ssubsubcta, 
				v_sssubsubcta, v_sector, v_fechacaptura, v_fechaintegracion, v_moneda, 
				v_naturaleza, v_importe, v_concepto, v_integra, v_numtotal, 
				v_cprocesado, 'ACTIVO', v_cusuario, v_cdescmoneda, v_ccosto_orig, 
				v_cregional, v_cnro_auxiliar, mensaje_ret, v_control_poliza 
			);
			
            LET v_idcontrol= v_idcontrol + 1;
		END FOREACH;
		
-- ****************************************************************************
-- *                       GENERACIÓN DE REPORTE                              *
-- ****************************************************************************	
		UPDATE sd_chi_carga_reg_cont_hist 
		SET poliza = v_control_poliza 
		WHERE id >= v_idcontrolini + 1
			AND fechaintegracion = v_fechaintegracion
			and fechacaptura = v_fechacaptura;
				
		LET cNombreArchivo = TRIM(cArchivoRep) || cDia || cMes || cYear || '.xls ';
		LET cSQL = ' echo "FECHA CAPTURA	FECHA VALIDA	TOTAL CARGOS	TOTAL ABONOS	PROCESADO	STATUS	ID USUARIO ALTA	NUMERO TOTAL REGISTROS	NUMERO CONSECUTIVO	DESCRIPCION MOVIMIENTO	NO. MONEDA	DESCRIPCION CORTA MONEDA	CENTRO COSTOS ORIGEN	CUENTA	SUB-CUENTA	SUB-SUB-CUENTA	SUB-SUB-SUB-CUENTA	SUB-SUB-SUB-SUB-CUENTA	SECTOR	REGION	NUMERO CUENTA AUXILIAR 	CENTRO COSTOS DESTINO	CARGO_ABONO	MONTO	MENSAJE DE RECHAZO	NUMERO POLIZA BANCOPPEL' ||
            "" || '">'||TRIM(cRutaReporte)|| TRIM(cNombreArchivo);
		SYSTEM TRIM(cSQL);

		LET cSQL='chmod 777 '|| TRIM(cRutaReporte)|| TRIM(cNombreArchivo);
		SYSTEM cSQL;

        FOREACH WITH HOLD

			SELECT  fechaintegracion, fechacaptura, status, 
                procesado, usuario, numregistros, id, concepto,  
                moneda, descmoneda, centrocostos, cta, subcta,  
                subsubcta, ssubsubcta, sssubsubcta, sector, region,  
                cuentaauxiliar, naturaleza, importe, mensaje, 
                poliza
            INTO v_fechaintegracion, v_fechacaptura, v_status, 
                v_cprocesado, v_cusuario, v_numtotal, v_idcontrol, v_concepto, 
                v_moneda, v_cdescmoneda, v_ccosto_orig, v_cta, v_subcta, 
                v_subsubcta, v_ssubsubcta, v_sssubsubcta, v_sector, v_cregional, 
                v_cnro_auxiliar, v_naturaleza, v_importe, v_mensaje, 
                v_control_poliza
            FROM bdicred:"informix".sd_chi_carga_reg_cont_hist
            WHERE id >= v_idcontrolini + 1
			
            LET cSQL = ' echo "' || v_fechaintegracion || '	' || v_fechacaptura || '	' || 
                TRIM(REPLACE(CAST(v_mtotalcargo AS CHAR(18)), '$', '')) || '	' ||  TRIM(REPLACE(CAST(v_mtotalabono AS CHAR(18)), '$', '')) || '	' || v_cprocesado || '	' ||  
                'ACTIVO' || '	' || TRIM(v_cusuario) || '	' || v_numtotal || '	' || v_idcontrol || '	' || TRIM(v_concepto) || '	' ||  
                TRIM(v_moneda) || '	' || v_cdescmoneda || '	' || v_ccosto_orig || '	' ||  '''' || v_cta || '	' ||  '''' || v_subcta || '	' ||  '''' || 
                v_subsubcta || '	' ||  '''' || v_ssubsubcta || '	' || '''' || v_sssubsubcta || '	' || '''' || v_sector || '	' || v_cregional || '	' ||  
                TRIM(v_cnro_auxiliar) || '	' || v_ccosto_orig || '	' || (CASE WHEN v_naturaleza =  'D'  THEN  'ABONO'  WHEN v_naturaleza =  'C'  THEN  'CARGO'  ELSE  ''  END) || '	' || 
                TRIM(REPLACE(CAST(v_importe AS CHAR(18)), '$', '')) || '	' ||TRIM(v_mensaje) || '	' || 
                v_control_poliza ||
                "" || '">>'||TRIM(cRutaReporte)|| TRIM(cNombreArchivo);
            SYSTEM TRIM(cSQL);

		END FOREACH;		
        
        DELETE FROM bdicred:"informix".sd_chi_carga_reg_cont;

		RETURN cod_ret;	
    END	
END PROCEDURE;