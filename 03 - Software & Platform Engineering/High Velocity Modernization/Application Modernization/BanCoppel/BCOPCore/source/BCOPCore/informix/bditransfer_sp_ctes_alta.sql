CREATE PROCEDURE "informix".sp_ctes_alta(	pNumCta 			CHAR(11),
											pNumCtaCbe 			CHAR(18),
											pTelefono 			CHAR(12),
											pEsRegistro 		CHAR(1),
											pNombreServ 		CHAR(128),
											pIdentificadorBanco CHAR(3),
											pMetodoAcceso 		CHAR(3),
											pApellidoPaterno 	CHAR(128),
											pApellidoMaterno 	CHAR(128),
											pNombre 			CHAR(64),
											pFechaNac 			CHAR (15),
											pCalle 				CHAR(128),
											pNumExterno 		CHAR(128),
											pIdentificacion 	CHAR(1),
											pNumIdentificacion 	CHAR(15),
											pFechaSistema		DATE)
RETURNING CHAR(6) AS returnCode,
		CHAR(256) AS errorDescription,
		CHAR (12) AS customerNumber;
		  	  
---DECLARACION DE VARIABLES
DEFINE iSqlErr       		INTEGER;
DEFINE iCuentaMae 	 		INTEGER;
DEFINE cPCodRet       		CHAR(6);
DEFINE cCodRetSp       		CHAR(3);
DEFINE cCodRetC       		CHAR(6);
DEFINE cCodRet       		CHAR(3);
DEFINE cDesCodRet       	CHAR(256);
DEFINE cEmpresa       		CHAR(3);
DEFINE cCuenta 	  	 		CHAR(20);
DEFINE cTelefono  	 		CHAR(13);
DEFINE cCta_Clabe 	 		CHAR(10);
DEFINE cNumcte		 		CHAR(20);
DEFINE cNumcteTrf			CHAR(20);
DEFINE cNombre1		 		CHAR(26);
DEFINE cNombre2		 		CHAR(26);
DEFINE cApell_paterno 		CHAR(26);
DEFINE cApell_materno 		CHAR(26);
DEFINE dFecha_Nac   		DATE;
DEFINE cRfcCte		 		CHAR(13);
DEFINE cRfcCteAlt	 		CHAR(13);
DEFINE cCorreo		 		CHAR(100);
DEFINE cCorreoTienda 		CHAR(100);
DEFINE cCurp 		 		CHAR(18);
DEFINE cMet_notificacion 	CHAR(15);
DEFINE cEnt_nac				CHAR(50);
DEFINE cRfcTf		 		CHAR(13);
DEFINE cNumTranfer   		CHAR(20);
DEFINE iBandRfc    	 		INTEGER;
DEFINE iBandTel    	 		INTEGER;
DEFINE cCalle 				CHAR(100);
DEFINE cNum_externo 		CHAR(15);
DEFINE cNum_interno 		CHAR(15);
DEFINE cNum_depto 			CHAR(15);
DEFINE cColonia				CHAR(100);
DEFINE cMunicipio			CHAR(50);
DEFINE cEstado				CHAR(100);
DEFINE cCod_postal			CHAR(5);
DEFINE cEjecutivo           CHAR(9);
DEFINE iSecuencia           INTEGER;
DEFINE cIdentificacion  	CHAR(50);
DEFINE cNum_identificacion	CHAR(15);
DEFINE cNum_tarjeta			CHAR(16);
DEFINE cFec_cancelac		DATE;
DEFINE cFec_modific			DATE;
DEFINE cMSISDNrecepcion		CHAR(12);
DEFINE cTelefonica           CHAR(4);
DEFINE cTipoAsociacion       CHAR(1);

---INICIALIZACION DE VARIABLES
LET iSqlErr       		= 0;
LET iCuentaMae	  		= 0;
LET cPCodRet       		= '0';
LET cCodRetSp      		= '0';
LET cCodRetC       		= '0';
LET cCodRet       		= '0';
LET cEmpresa			= '001';
LET cCuenta       		= '';
LET cTelefono     		= '';
LET cCta_Clabe    		= '';
LET cNumcte 	  		= '';
LET cNumcteTrf			= '';
LET cNombre1 	 	 	= '';
LET cNombre2       		= '';
LET cApell_paterno 		= ''; 
LET cApell_materno 		= '';
LET dFecha_Nac    		= DATE(1);
LET cRfcCte  	  		= '';
LET cRfcCteAlt 	  		= '';
LET cRfcTf  	  		= '';
LET cCorreo  	  		= '';
LET cCorreoTienda 		= '';
LET cCurp 				= '';
LET cMet_notificacion	= '';
LET cEnt_nac			= '';
LET	cNumTranfer  		= 0;
LET iBandRfc   	  		= 0;
LET iBandTel   	  		= 0;
LET cCalle 				= '';
LET cNum_externo 		= '';
LET cNum_interno 		= '';
LET cNum_depto 			= '';
LET cColonia			= '';
LET cMunicipio			= '';
LET cEstado				= '';
LET cCod_postal			= '';
--LET cEjecutivo			= 'CAT-Trf';
LET cCodRetC 			= '';
LET cDesCodRet			= 'Registro exitoso';
LET iSecuencia          = 0;
LET cIdentificacion		='';
LET cNum_identificacion	=0;
LET cNum_tarjeta		='';
LET	cFec_cancelac		='';
LET	cFec_modific			='';
LET cMSISDNrecepcion = '';
LET cTelefonica    = ''; 
LET cTipoAsociacion = '';

--SET DEBUG FILE TO '/tmp/cristo/sp_ctes_alta.out';
--TRACE ON;
	
BEGIN
    ON EXCEPTION SET iSqlErr
		IF 	iSqlErr <> 0 THEN
			LET cCodRet = '950';
			LET cPCodRet = iSqlErr;
			
			SELECT descripcion 
			INTO  cDesCodRet
			FROM  "informix".tf_codret 
			WHERE cod_error = cCodRet;
			
			SELECT MAX(id)
			INTO iSecuencia
			FROM "informix".tf_cte_online
			WHERE cuenta_tf = pNumCta
			AND telefono = pTelefono;
			
			UPDATE "informix".tf_cte_online 
			SET cod_error = cCodRet, desc_error = cDesCodRet  
			WHERE cuenta_tf = pNumCta
			AND telefono = pTelefono
			AND id = iSecuencia;
			RETURN trim(cPCodRet),trim(cDesCodRet),trim(cNumTranfer);
		END IF
END EXCEPTION;

    --SET ISOLATION TO DIRTY READ;
    --SET LOCK MODE TO WAIT 3;
	

	IF 	TRIM(NVL(pNumCta,'')) <> '' 
		AND TRIM(NVL(pNumCtaCbe,'')) <> '' 
		AND TRIM(NVL(pTelefono,'')) <> '' 
		AND TRIM(NVL(pEsRegistro,'')) <> '' 
		AND TRIM(NVL(pNombreServ,''))<>''
		AND TRIM(NVL(pIdentificadorBanco,''))<>''
		AND TRIM(NVL(pMetodoAcceso,''))<>''
		AND TRIM(NVL(pApellidoPaterno,''))<>''
		AND TRIM(NVL(pApellidoMaterno,''))<>''
		AND TRIM(NVL(pNombre,''))<>''
		AND TRIM(NVL(pFechaNac,''))<>''
		AND TRIM(NVL(pCalle,''))<>''
		/*AND TRIM(NVL(pNumExterno,''))<>''
		AND TRIM(NVL(pIdentificacion,''))<>''
		AND TRIM(NVL(pNumIdentificacion ,''))<>'' */
		AND TRIM(NVL(pFechaSistema,''))<>'' 
	THEN
		
		--existe cliente con los mismos valores en la tabla maestra
		SELECT COUNT(cuenta_tf)
		INTO iCuentaMae
		FROM "informix".tf_maecte
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono
		AND cta_clabe = pNumCtaCbe
		AND status_cta=1;
		
		IF iCuentaMae = 0 THEN
			--si es que no, inserta un dato de empresa
			SELECT empresa 
			INTO cEmpresa
			FROM bdinteg:"informix".si_empresas;
			
			
			SELECT upper(nombre1), upper(nombre2), upper(apell_paterno), upper(apell_materno), fecha_nac, upper(rfc), correo,upper(curp), met_notificacion, entidad_nac, calle, num_exterior, num_interno, num_depto, colonia, municipio, estado, cod_postal, identificacion,num_identificacion,num_tarjeta,MSISDNrecepcion,Telefonica,TipoAsociacion
			INTO cNombre1,cNombre2, cApell_Paterno,cApell_Materno,dFecha_Nac,cRfcTf,cCorreo, cCurp, cMet_notificacion, cEnt_nac, cCalle, cNum_externo, cNum_interno, cNum_depto, cColonia, cMunicipio, cEstado, cCod_postal,cIdentificacion,cNum_Identificacion,cNum_tarjeta,cMSISDNrecepcion,cTelefonica,cTipoAsociacion
			FROM "informix".tf_cte_online
			WHERE cuenta_tf = pNumCta
			AND telefono = pTelefono
			AND cta_clabe = pNumCtaCbe
			AND esregistro = pEsRegistro
			AND	fec_sistema= pFechaSistema;
			
			--valida si es un cliente del banco
			SELECT  a.numcte, a.rfc, a.rfc_alterno
			INTO cNumcte, cRfcCte, cRfcCteAlt
			FROM bdinteg:"informix".si_cliente a,
				 bdinteg:"informix".si_ctepf b
			WHERE a.empresa = cEmpresa 
			AND a.nombre1 = TRIM(cNombre1)
			AND a.nombre2 = TRIM(cNombre2)
			AND a.apell_paterno = TRIM(cApell_Paterno)
			AND a.apell_materno = TRIM(cApell_Materno)
			AND b.numcte = a.numcte
			AND b.fecha_nac = dFecha_Nac;

			IF dbinfo("sqlca.sqlerrd2") = 1 THEN 
				IF TRIM (NVL(cRfcTf,'')) <> '' THEN
					IF TRIM(cRfcTf) <> TRIM(cRfcCte) THEN
						IF TRIM (NVL(cRfcCteAlt,'')) <> '' THEN
							IF TRIM(cRfcCteAlt) <> TRIM(cRfcTf) THEN
								LET cCodRet = '951';
							ELSE
								LET iBandRfc = 1;
							END IF;
						ELSE
							UPDATE bdinteg:"informix".si_cliente 
							SET rfc_alterno = TRIM(cRfcTf) 
							WHERE empresa = cEmpresa 
							AND numcte = cNumcte;
							LET iBandRfc = 1; 
						END IF;
					ELSE
						LET iBandRfc = 1;
					END IF;
				ELSE
					LET iBandRfc = 1; 
				END IF;
			ELSE
				IF TRIM (NVL(cRfcTf,'')) <> '' THEN

					SELECT {+INDEX(si_cliente idxr_rfc_alterno)} 
					numcte,rfc,rfc_alterno 
					INTO cNumcte, cRfcCte, cRfcCteAlt
					FROM bdinteg:"informix".si_cliente 
					WHERE numcte <> "" 
					AND (rfc_alterno = TRIM(cRfcTf) OR rfc = TRIM(cRfcTf));
									
					IF TRIM(NVL(cNumcte,'')) = '' THEN
						LET iBandRfc = 1;
					ELSE
						LET cCodRet = '952';
					END IF;
				ELSE
					LET iBandRfc = 1; 
				END IF;
			END IF;
	
			IF iBandRfc = 1 THEN
			
				IF TRIM(NVL(cNumcte,'')) <>  '' THEN
					
					SELECT telefono
					INTO cTelefono 
					FROM bdinteg:"informix".si_telefonos_actual
					WHERE empresa= cEmpresa 
					AND numcte = cNumcte
					AND tipo_tel = 2 
					AND status_tel = 'A';
					
					IF TRIM(NVL(cTelefono,'')) <>  pTelefono THEN
					 	EXECUTE PROCEDURE bdinteg:"informix".sp_registra_telefonos('001', cNumcte,pTelefono, 2, '0', 1,  1, 'CAT-Trf')
						INTO cCodRetSp;
						
						IF TRIM(NVL(cCodRetSp,'')) = '000' THEN
							LET iBandTel = 1;
						ELSE
							--LET cCodRet = '953';
							LET cCodRet = '000';
						END IF;
						
					ELSE
						LET iBandTel = 1;
					END IF;
					
					SELECT LIMIT 1 correo_elec 
					INTO cCorreoTienda
					FROM bdinteg:"informix".si_correos 
					WHERE empresa = cEmpresa 
					AND numcte = cNumcte 
					AND status_correo  = 'A';
					
					IF NVL(cCorreo,'') <> '' AND (TRIM(NVL(cCorreoTienda,'')) <> TRIM(NVL(cCorreo,''))) THEN
						EXECUTE PROCEDURE bdinteg:"informix".sp_registra_correos('001', cNumcte, cCorreo,1,1, 'CAT-Trf')
						INTO cCodRetC;
						IF TRIM(NVL(cCodRetC,'')) <> '000' THEN
							LET cCodRet = '954';
						END IF;
					END IF;
				ELSE
				
					SELECT COUNT(cuenta_tf)
					INTO iCuentaMae
					FROM "informix".tf_maecte
					WHERE empresa = '001' 
					AND telefono = pTelefono
					AND status_cta=1;
				
					IF  iCuentaMae = 0 THEN
						LET iBandTel = 1;
					ELSE
						LET cCodRet = '955';
					END IF
				END IF;
			
			END IF;
			IF iBandTel= 1 THEN
				SELECT valor
				INTO cNumTranfer
				FROM "informix".tf_param
				WHERE empresa = 001
				AND cod_param = 1;

				IF NVL(cNumTranfer,'') <> '' THEN
					LET cNumTranfer = TRIM(cNumTranfer)::INTEGER  + 1;
					
					UPDATE "informix".tf_param SET valor = cNumTranfer WHERE cod_param = '1';
					
					IF pIdentificacion=1 THEN 
						LET cIdentificacion='IFE';
					ELIF pIdentificacion=2 THEN 
						LET cIdentificacion='Cartilla Militar';
					ELIF pIdentificacion=3 THEN 
						LET cIdentificacion='CÃ©dula Profesional';
					ELSE
						LET cIdentificacion='Pasaporte';
					END IF;
					
					INSERT INTO "informix".tf_maecte (cuenta_tf, cta_clabe, telefono, status_cta, numcte, numcte_tf, producto, nombre1, nombre2, apell_paterno, apell_materno, fecha_nac, rfc, correo, curp, met_notificacion, fec_alta,fec_cancelac,fec_modific, empresa, entidad_nac, identificacion,num_identificacion,num_tarjeta,ultimo_saldo,MSISDNrecepcion,Telefonica,TipoAsociacion) 
					VALUES (pNumCta, pNumCtaCbe, pTelefono, '1', cNumcte, cNumTranfer,'8000', cNombre1, cNombre2, cApell_Paterno, cApell_Materno, dFecha_Nac, cRfcTf, cCorreo, cCurp, cMet_notificacion,  CURRENT,cFec_cancelac,cFec_modific, cEmpresa,cEnt_nac,cIdentificacion,cNum_Identificacion,'','0',cMSISDNrecepcion,cTelefonica,cTipoAsociacion);
					
					INSERT INTO "informix".tf_direcciones (cuenta_tf, numcte_tf, calle, num_externo, num_interno, num_depto, colonia, municipio, estado, cod_postal) 
					VALUES(pNumCta, cNumTranfer, cCalle, cNum_externo, cNum_interno, cNum_depto, cColonia, cMunicipio, cEstado, cCod_postal);
				
										--SE INSERTA EN SC_CUENTA_TELEFONO
					IF NVL(cNumcte,'') = '' THEN 
						LET cNumcteTrf = cNumTranfer;
					ELSE
						LET cNumcteTrf = cNumcte;
					END IF;
					
						IF NOT EXISTS(SELECT  telefono FROM bdicheq:"informix".sc_cuenta_telefono WHERE telefono=pTelefono) THEN 
							IF NOT EXISTS(SELECT  num_cte FROM bdicheq:"informix".sc_cuenta_telefono WHERE num_cte=cNumcteTrf) THEN
							
								INSERT INTO bdicheq:"informix".sc_cuenta_telefono (num_cte,cuenta,telefono,canal,es_transfer,user_insert,fecha_hora_insert)
								VALUES (cNumcteTrf,pNumCta,pTelefono,'2','S',USER,CURRENT);
								
							ELSE
							
								INSERT INTO bdicheq:"informix".sc_cuenta_telefono (num_cte,cuenta,telefono,canal,es_transfer,user_insert,fecha_hora_insert)
								VALUES (cNumTranfer,pNumCta,pTelefono,'2','S',USER,CURRENT);
								
							END IF;
						
						END IF;
					
					
				ELSE
					LET cCodRet = '955';
				END IF;
				
			END IF;
		ELSE
			LET cCodRet = '104';
		END IF;
		
		SELECT descripcion 
		INTO  cDesCodRet
		FROM  "informix".tf_codret 
		WHERE cod_error = cCodRet;
		
		SELECT MAX(id)
		INTO iSecuencia
		FROM "informix".tf_cte_online
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono;
		
		UPDATE "informix".tf_cte_online 
		SET cod_error = cCodRet, desc_error = cDesCodRet  
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono
		AND id = iSecuencia;
		
		LET cPCodRet=cCodRet;
		
	ELSE
		LET cPCodRet = '600';
		
		SELECT descripcion 
		INTO  cDesCodRet
		FROM  "informix".tf_codret 
		WHERE cod_error = cPCodRet;
		
		SELECT LIMIT 1 numcte_tf
		INTO cNumTranfer
		FROM "informix".tf_maecte
		where numcte_tf=cNumTranfer;
		
		SELECT MAX(id)
		INTO iSecuencia
		FROM "informix".tf_cte_online
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono;
		
		UPDATE "informix".tf_cte_online 
		SET cod_error = cPCodRet, desc_error = cDesCodRet  
		WHERE cuenta_tf = pNumCta
		AND telefono = pTelefono
		AND id = iSecuencia;
		
	END IF;
	
	RETURN trim(cPCodRet),trim(cDesCodRet),trim(cNumTranfer);
	
END;
END PROCEDURE
DOCUMENT
'Folio:1589',
'Autor:Felipe Urias',
'Fecha:10/03/2014',
'ModificaciÃ³n: Se realiza procedimiento almacenado para realizar el alta del cliente transfer',
'Sustento: RQI 63 049 Procesos Transfer Central.pdf ',
'Solicita: Manuel Osuna',
'Folio:1604',
'Modifico:Felipe Urias',
'Fecha:22/04/2014',
'ModificaciÃ³n: se agrega consulta de maxima secuencia para evitar las actualizacion a mas de un registro',
'Sustento: Evidencias Ciclo 1.ods',
'Solicita: Gabriela GudiÃ±o',
'BD: bditransfer';

create procedure "informix".sp_transfer_bancos ()

returning 	
				char (5)    as codret, 
				char (150)  as mensaje_respuesta,
				char (3)    as id_banco,
				char (35)   as nombre;
				
-- Definicion de retorno
define 	vscodret 				char(5);
define  vsmensaje_respuesta     char(150);
define  vsidbanco               char (3);
define  vsdesc_bco				char (35);

define  visqlerr				integer;
	
begin
	on exception set visqlerr
		
		let vscodret = vsCodRet;
		
		return 	  	
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vsidbanco, '')),
					TRIM(UPPER(NVL(vsdesc_bco,'')));
				
	end exception;
	
--set debug file to "/informix/mgap/sp_transfer_bancos.out";
--trace on;


-- Inicializacion de retorno
Let  vscodret = '00000';
let  vsmensaje_respuesta = '';
let  vsidbanco	 = '';
let  vsdesc_bco	= '';

set isolation to dirty read;

FOREACH cusor1 with hold for
		
			SELECT TRIM(id_banco),trim(nombre) 
		    INTO vsidbanco, vsdesc_bco 
			FROM Bditransfer:"informix".tf_cat_bancos
			
			RETURN 
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vsidbanco, '')),
					TRIM(UPPER(NVL(vsdesc_bco,'')))
			WITH RESUME;
			
END FOREACH;

/*
RETURN 
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vsidbanco, '')),
					TRIM(UPPER(NVL(vsdesc_bco,'')));*/
end
end procedure
DOCUMENT
'AUTOR: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06 539 REPORTE INTERBANCARIO BANKSSETTLEMENT',
'Solicito: Operaciones TRANSFER',
'Descripcion: Recuperar el catalogo de Bancos con relación a la plataforma de Transfer',
'Fecha: 2016/11/18',
'Version: 20161117.1200',
'BD: Bditransfer';

CREATE PROCEDURE "informix".sp_transfer_msettlement2 (
					pdfechaini   date,
					pdfechafin   date,
					psbcoorigen  char(3),
					psbcodestino char(3),
					pRegistros INTEGER, 
					pRecuperacion INTEGER
					)
returning 	
				char (5) 	as codret, 
				char (150) 	as mensaje_respuesta,
				char (50)   as nombre_archivo,
				char (3)    as banco_origen,
				char (3)    as banco_destino,
				money       as monto; 

-- Definicion de retorno
DEFINE 	vscodret 				char(5);
DEFINE  vsmensaje_respuesta     char(150);
DEFINE	vsnombre_file			char  (50); 
DEFINE	vsbcoorigen		        char  (3); 
DEFINE	vsbcodestino		    char  (3); 
DEFINE	vmmonto		            money;
DEFINE  visqlerr				integer;
	
BEGIN
	ON exception SET visqlerr
		
		LET vscodret = vsCodRet;
		
		RETURN 	TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0); 
	
	end exception;
	
--set debug file to "/informix/mgap/sp_transfer_msettlement.out";
--trace on;

-- Inicializacion de retorno
LET vscodret            = '00000';
LET vsmensaje_respuesta = '';
LET	vsnombre_file		= '';
LET	vsbcoorigen     	= '';
LET	vsbcodestino	    = '';
LET	vmmonto		        = 0;


IF  pdfechaini > pdfechafin  THEN
		LET vscodret = '00001';
		LET vsmensaje_respuesta = 'Fecha Inicial no puede ser mayor a la Final';
        RETURN 	
		        TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0); 
END IF;


IF ((psbcoorigen = '' OR psbcoorigen IS NULL) AND (psbcodestino = '' OR psbcodestino IS NULL ) ) THEN
		
		SET  ISOLATION TO DIRTY READ;  
		FOREACH cusor1 with hold FOR   -- GENERAL 
		
		
		    SELECT SKIP pRegistros FIRST pRecuperacion	nombrearchivo,id_banco_origen,id_banco_destino,monto  	 
            INTO    vsnombre_file, vsbcoorigen, vsbcodestino, vmmonto 
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin			
 
        RETURN 	
		        TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0)	
				WITH RESUME;

		END FOREACH;
	

ELSE  -- ESPECÃFICA  

        SET  ISOLATION TO DIRTY READ;  
        FOREACH cusor1 with hold FOR   
		
	        SELECT 	SKIP pRegistros FIRST pRecuperacion nombrearchivo,id_banco_origen,id_banco_destino,monto  	 
            INTO    vsnombre_file, vsbcoorigen, vsbcodestino, vmmonto 
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin
            AND     id_banco_origen  = psbcoorigen 
            AND 	id_banco_destino = psbcodestino            	
					
			RETURN 	
		        TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0)
				WITH RESUME;

		END FOREACH;

END IF;


END
END PROCEDURE
DOCUMENT
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 27/02/2017',
'MODULO: OPERACIONES',
'DESCRIPCION: Se colona SPL bditransfer:sp_transfer_msettlement para el tratado de paginaciÃ³n.',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 23/03/2017',
'DESCRIPCION: Se modifica SPL para eliminar ordenamiento.',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_transfer_msettlement2_totales (
					pdfechaini   date,
					pdfechafin   date,
					psbcoorigen  char(3),
					psbcodestino char(3)
					)
		RETURNING CHAR (5) AS codret, 
				INTEGER AS num_registros; 

-- Definicion de retorno
DEFINE 	vscodret 				CHAR(5);
DEFINE  vsmensaje_respuesta     CHAR(150);
DEFINE	vsnombre_file			CHAR  (50); 
DEFINE	vsbcoorigen		        CHAR  (3); 
DEFINE	vsbcodestino		    CHAR  (3); 
DEFINE	vmmonto		            MONEY;
DEFINE  visqlerr				INTEGER;

DEFINE  iNumRegistros           INTEGER;
	
BEGIN
	ON exception SET visqlerr
		
		LET vscodret = vsCodRet;
		
		RETURN 	TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 
	
	end exception;
	
--set debug file to "/informix/mgap/sp_transfer_msettlement.out";
--trace on;

-- Inicializacion de retorno
LET vscodret            = '00000';
LET vsmensaje_respuesta = '';
LET	vsnombre_file		= '';
LET	vsbcoorigen     	= '';
LET	vsbcodestino	    = '';
LET	vmmonto		        = 0;
LET iNumRegistros       = 0;


IF  pdfechaini > pdfechafin  THEN
		LET vscodret = '00001';
		LET vsmensaje_respuesta = 'Fecha Inicial no puede ser mayor a la Final';
        RETURN TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 
END IF;


IF ((psbcoorigen = '' OR psbcoorigen IS NULL) AND (psbcodestino = '' OR psbcodestino IS NULL ) ) THEN
		
		SET  ISOLATION TO DIRTY READ;  
		--FOREACH cusor1 with hold FOR   -- GENERAL 
		
		
		    SELECT 	COUNT(*)  	 
            INTO    iNumRegistros
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin;
			--ORDER BY 1,2,3 
 
        RETURN TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 

		--END FOREACH;
	

ELSE  -- ESPECÃFICA  

        SET  ISOLATION TO DIRTY READ;  
        --FOREACH cusor1 with hold FOR   
		
	        SELECT 	COUNT(*)  	 
            INTO    iNumRegistros
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin
            AND     id_banco_origen  = psbcoorigen 
            AND 	id_banco_destino = psbcodestino;
            --ORDER BY 1,2,3			
					
			 RETURN TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 

		--END FOREACH;

END IF;


END
END PROCEDURE
DOCUMENT
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 27/02/2017',
'MODULO: OPERACIONES',
'DESCRIPCION: Se realiza la clonaciÃ³n del SPL bditransfer:sp_transfer_msettlement para consultar el nÃºmero total de registros.',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_generaarch_transfer(pNombrearch char(50))
RETURNING  CHAR(5) AS CodRetorno;



--DECLARACION DE VARIABLES
DEFINE viSqlError INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);
DEFINE vsRutaArchRep	  CHAR(150);


--INICIALIZACION DE VARIABLES
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET cSQL1 = ' ';
LET cSQL = ' ';
LET vsRutaArchRep = ' ';

--SET DEBUG FILE TO "/informix/ragomez/sp_generaarch_transfer_pba.out";
--TRACE ON;
BEGIN

	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			RETURN vsCodRetorno;
		END IF;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF (pNombrearch is null) or (pNombrearch = '') THEN
		LET vsCodRetorno = '00042';
		RETURN vsCodRetorno;
	END IF;

	SELECT LIMIT 1 TRIM(VALOR)||'/'
	INTO vsRutaArchRep FROM bdimnsj:"informix".mnsj_param
	WHERE cod_param = '3';

	IF vsRutaArchRep <> ' ' THEN

		LET cSQL1 = 'echo "UNLOAD TO '||trim(vsRutaArchRep)||TRIM(pNombrearch)||' delimiter '' '' SELECT {+INDEX(mnsj_procesos,inx_mnsjsuscpaso)} linea from "informix".mnsj_susc_paso ORDER BY secuencial" >'||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
		SYSTEM cSQL1;

		LET cSQL='dbaccess bditransfer '||trim(vsRutaArchRep)||'Ejecuta_archivo.sql';
		System cSQL;
		
			LET cSQL = '' ;
			LET cSQL = 'zip /'||trim(vsRutaArchRep)||TRIM(pNombrearch)||'.zip '||'-P 12345 /'||TRIM(vsRutaArchRep)||TRIM(pNombrearch);
			SYSTEM cSQL ;

	ELSE
		LET vsCodRetorno = '00043';
		RETURN vsCodRetorno;
	END IF;


RETURN vsCodRetorno;

END;
END PROCEDURE;