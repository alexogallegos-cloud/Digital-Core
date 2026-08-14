CREATE PROCEDURE "informix".sp_cilocinsertamarca(	pOrigen CHAR(1), --1 SUCURSAL/PLATAFORMA, 2 CENTRAL, 3 BPI
										pTpoMarca CHAR(4), --  LV, CM, 3BL
										pSucursal CHAR(4),
										pNumcte CHAR(20),
										pTpoDir CHAR(1),
										pCalle CHAR(40),
										pColonia CHAR(60),
										pEntre_calles CHAR(40),
										pPais CHAR(3),
										pEstado CHAR(2),
										pCiudad CHAR(3),
										pMunicipio CHAR(5),
										pCodPostal CHAR(5),
										pApartadoPostal CHAR(11),
										pTpoTel1 CHAR(1),
										pTel1 CHAR(13),
										pTpoTel2 CHAR(1),
										pTel2 CHAR(13),
										pTpoTel3 CHAR(1),
										pTel3 CHAR(13),
										pExtension CHAR(5),
										pEdoInegi CHAR(2),
										pMunicipioInegi CHAR(3),
										pLocalidadInegi CHAR(4),
										pNumCd SMALLINT,
										pNumExtCalle CHAR(10),
										pNumIntCalle CHAR(10),
										pDepto CHAR(6),
										pNumCalle INTEGER,
										pNumColonia INTEGER,
										pPuntoCardinal CHAR(1),
										pUnidadHab CHAR(1),
										pManzana SMALLINT,
										pOtros SMALLINT,
										pAndador SMALLINT,
										pEtapa SMALLINT,
										pLote SMALLINT,
										pEdificio SMALLINT,
										pEntrada SMALLINT,
										pObservaciones CHAR(80),
										pUserInsert CHAR(8),
										pIndCofetel1 CHAR(1), --DEFAULT F
										pIndCofetel2 CHAR(1),
										pIndCofetel3 CHAR(1),
										pDomCerificado CHAR(1),
										pLugarTrabajo	char(80)
										)
RETURNING CHAR(5);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			    INTEGER;
DEFINE isam_err 		    INTEGER;
DEFINE error_info		    CHAR(80);
DEFINE cCod_ret             CHAR(6);
DEFINE dFechaHoy			DATE;
DEFINE iBandera				INTEGER;
DEFINE cNumcte				CHAR(20);
DEFINE cTpoDir				CHAR(1);
DEFINE cCalle				CHAR(40);
DEFINE cColonia				CHAR(60);
DEFINE cEntre_calles		CHAR(40);
DEFINE cPais				CHAR(3);
DEFINE cEstado				CHAR(2);
DEFINE cMunicipio			CHAR(5);
DEFINE cCodPostal			CHAR(5);
DEFINE cApartadoPostal		CHAR(11);
DEFINE cTpoTel1				CHAR(1);
DEFINE cTel1				CHAR(13);
DEFINE cTpoTel2				CHAR(1);
DEFINE cTel2				CHAR(13);
DEFINE cTpoTel3				CHAR(1);
DEFINE cTel3				CHAR(13);
DEFINE cExtension			CHAR(5);
DEFINE cEdoInegi			CHAR(2);
DEFINE cMunicipioInegi		CHAR(3);
DEFINE cLocalidadInegi		CHAR(4);
DEFINE sNumCd				SMALLINT;
DEFINE cNumExtCalle			CHAR(10);
DEFINE cNumIntCalle			CHAR(10);
DEFINE cDepto				CHAR(6);
DEFINE iNumCalle			INTEGER;
DEFINE iNumColonia			INTEGER;
DEFINE cPuntoCardinal		CHAR(1);
DEFINE cUnidadHab			CHAR(1);
DEFINE sManzana				SMALLINT;
DEFINE sOtros				SMALLINT;
DEFINE sAndador				SMALLINT;
DEFINE sEtapa				SMALLINT;
DEFINE sLote				SMALLINT;
DEFINE sEdificio			SMALLINT;
DEFINE sEntrada				SMALLINT;
DEFINE cObservaciones		CHAR(80);
DEFINE cIndCofetel1			CHAR(1);
DEFINE cIndCofetel2			CHAR(1);
DEFINE cIndCofetel3			CHAR(1);
DEFINE cSituacion			CHAR(1);
DEFINE cCausa				SMALLINT;
DEFINE cNombre				CHAR(40);
DEFINE iSecuencia			INTEGER;
DEFINE iSecuencia2			INTEGER;
DEFINE cSucursal			CHAR(4);
-----------------------------------------------------
LET cCod_ret  		= '00000';
LET sql_err   		= 0;
LET dFechaHoy		= '';	
LET iBandera		= 0;
LET cNumcte			= '';
LET cTpoDir			= '';
LET cCalle			= '';
LET cColonia		= '';
LET cEntre_calles 	= '';
LET cPais			= '';
LET cEstado			= '';
LET cMunicipio		= '';
LET cCodPostal		= '';
LET cApartadoPostal = '';
LET cTpoTel1		= '';
LET cTel1			= '';
LET cTpoTel2		= '';
LET cTel2			= '';
LET cTpoTel3		= '';
LET cTel3			= '';
LET cExtension		= '';
LET cEdoInegi		= '';
LET cMunicipioInegi	= '';
LET cLocalidadInegi	= '';
LET sNumCd			= '';
LET cNumExtCalle	= '';
LET cNumIntCalle	= '';
LET cDepto			= '';
LET iNumCalle		= 0;
LET iNumColonia		= 0;
LET cPuntoCardinal	= '';
LET cUnidadHab		= '';
LET sManzana		= 0;
LET sOtros			= 0;
LET sAndador		= 0;
LET sEtapa			= 0;
LET sLote			= 0;
LET sEdificio		= 0;
LET sEntrada		= 0;
LET cObservaciones	= '';
LET cIndCofetel1	= '';
LET cIndCofetel2	= '';
LET cIndCofetel3	= '';
LET cSituacion		= '';
LET cCausa			= 0;
LET cNombre			= '';
LET iSecuencia		= 0;
LET iSecuencia2		= 0;
LET cSucursal		= '';
		
  BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		LET cCod_ret = sql_err;		
		IF iBandera = 1 THEN
			ROLLBACK WORK;					
		END IF;
		RETURN cCod_ret;		
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/home/sysifx/Antonio/sp_CiLocInsertaMarca.out";
	--TRACE ON;
	
	IF pOrigen = '' OR pTpoMarca = '' OR pSucursal = '' OR pNumcte = '' OR pTpoDir = '' THEN
		LET cCod_ret= '00002';
		RETURN cCod_ret;	
	END IF;
	
	SELECT fecha_hoy
	INTO dFechaHoy
	FROM bdinteg: si_fechas;	
	
	IF NOT EXISTS(SELECT 1 FROM bdicobranza:cb_tipo_marca WHERE tipo = pTpoMarca) THEN
		LET cCod_ret= '00001';
		RETURN cCod_ret;
	END IF;
	
	IF EXISTS(SELECT 1 FROM bdicobranza:cb_marcacliente 
		WHERE tipo_marca = pTpoMarca 
		AND fecha_insert = dFechaHoy 
		AND numcte = pNumcte 
		AND tipo_domicilio = pTpoDir) THEN
		LET cCod_ret= '00003';
		RETURN cCod_ret;
	END IF;
	
	BEGIN WORK;
	
		LET iBandera = 1;
		IF pTpoMarca= 'BL' THEN
		
			IF EXISTS(SELECT 1 FROM bdinteg:si_direcciones_loc WHERE numcte =  pNumcte
			AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_direcciones_loc WHERE numcte= pNumcte AND tipo_dir = pTpoDir
			AND dom_verificado= 'N')
			AND tipo_dir = pTpoDir
			AND dom_verificado= 'N'	) THEN
			
			SET ISOLATION TO DIRTY READ;
			
				SELECT numcte, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal,
					apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, estado_inegi,
					municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle,
					numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
					ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3
				INTO cNumcte,  cTpoDir, cCalle, cColonia, cEntre_calles, cPais, cEstado, pCiudad ,cMunicipio, cCodPostal,
					cApartadoPostal, cTpoTel1, cTel1, cTpoTel2, cTel2, cTpoTel3, cTel3, cExtension, cEdoInegi, cMunicipioInegi, cLocalidadInegi,
					sNumCd, cNumExtCalle, cNumIntCalle, cDepto, iNumCalle, iNumColonia, cPuntoCardinal, cUnidadHab, sManzana, sOtros, sAndador,
					sEtapa, sLote, sEdificio, sEntrada, cObservaciones, cIndCofetel1, cIndCofetel2, cIndCofetel3
				FROM	bdinteg:si_direcciones_loc
				WHERE numcte =  pNumcte
				AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_direcciones_loc WHERE numcte= pNumcte AND tipo_dir = pTpoDir AND dom_verificado= 'N')
				AND tipo_dir = pTpoDir
				AND dom_verificado= 'N';
			
				SELECT MAX(secuencia) 
				INTO iSecuencia2
				FROM bdinteg:si_direcciones_loc 
				WHERE numcte= pNumcte 
				AND tipo_dir = pTpoDir 
				AND dom_verificado= 'N';
				
				SET LOCK MODE TO WAIT 3;
				
				UPDATE bdinteg:si_direcciones_loc SET dom_verificado = 'S' WHERE numcte = pNumcte AND tipo_dir = pTpoDir AND 
				secuencia = iSecuencia2;
				
				SELECT MAX(secuencia)
				INTO iSecuencia
				FROM bdinteg:si_direcciones
				WHERE numcte= pNumcte;
				
				LET iSecuencia = iSecuencia + 1;			
			
				EXECUTE PROCEDURE bdinteg:direcciones(  '001',
														'A',
														cNumcte,
														iSecuencia,
														cTpoDir,
														cCalle,
														cColonia,
														cMunicipio,
														cEntre_calles,
														cPais,
														cEstado,
														pCiudad , 
														cCodPostal,
														cTpoTel1, 
														cTel1, 
														cTpoTel2, 
														cTel2, 
														cTpoTel3, 
														cTel3, 
														cExtension,
														cEdoInegi,
														cMunicipioInegi,
														cLocalidadInegi,
														sNumCd,
														cNumExtCalle, 
														cNumIntCalle, 
														cDepto, 
														iNumCalle, 
														iNumColonia, 
														cPuntoCardinal,
														cUnidadHab, 
														sManzana, 
														sOtros, 
														sAndador,
														sEtapa,
														sLote, 
														sEdificio,
														sEntrada,
														cObservaciones, 
														pUserInsert,
														dFechaHoy, 
														cSucursal
													 )
					INTO cCod_ret;		

					IF cCod_ret <> 0 THEN
						IF iBandera = 1 THEN
							ROLLBACK WORK;					
						END IF;
						RETURN cCod_ret;
					END IF;	
			END IF;
		
		SET LOCK MODE TO WAIT 3;

			IF EXISTS ( SELECT 1 FROM bdicobranza:cb_marcacliente WHERE numcte= pNumcte AND estatus = 'SA' AND tipo_domicilio = pTpoDir) THEN
				UPDATE cb_marcacliente SET estatus = 'AT', fecha_modificacion= dFechaHoy, usuario_desmarca = pUserInsert
				WHERE numcte= pNumcte AND estatus = 'SA' AND tipo_domicilio= pTpoDir;
			END IF;		
			
			INSERT INTO bdicobranza:cb_marcacliente ( numcte, tipo_domicilio, tipo_marca, fecha_insert, estatus, fecha_modificacion, usuario_marca, 
										usuario_desmarca, origen, sucursal)
			VALUES( pNumcte, pTpoDir, pTpoMarca, dFechaHoy, 'AT', '', pUserInsert, pUserInsert, pOrigen ,pSucursal);		--Origen: 1 SUC/PLATAFORMA, 2 CENTRAL, 3 BPI	
						
		ELIF pTpoMarca= 'LV' THEN	
			
			IF EXISTS ( SELECT 1 FROM bdicobranza:cb_marcacliente WHERE numcte= pNumcte AND estatus = 'SA' AND tipo_domicilio= pTpoDir ) THEN
			
			 SET LOCK MODE TO WAIT 3;
			
				UPDATE cb_marcacliente SET estatus = 'NA', fecha_modificacion= dFechaHoy, usuario_desmarca = pUserInsert
				WHERE numcte= pNumcte AND estatus = 'SA' AND tipo_domicilio= pTpoDir;	
				
				IF EXISTS( SELECT 1 FROM bdinteg:si_direcciones_loc WHERE numcte = pNumcte  AND tipo_dir = pTpoDir AND dom_verificado= 'N') THEN
					SELECT MAX(secuencia) 
					INTO iSecuencia
					FROM bdinteg:si_direcciones_loc 
					WHERE numcte= pNumcte 
					AND tipo_dir = pTpoDir 
					AND dom_verificado= 'N';
					
					UPDATE bdinteg:si_direcciones_loc SET dom_verificado = 'S' WHERE numcte = pNumcte AND tipo_dir = pTpoDir AND 
					secuencia = iSecuencia;
				END IF;				
			END IF;
			
			SELECT MAX(secuencia) 
			INTO iSecuencia2
			FROM bdinteg:si_direcciones_loc 
			WHERE numcte= pNumcte;
			
			IF iSecuencia2 IS NULL OR iSecuencia2 = '' THEN
					LET iSecuencia2 = 1;
				ELSE			
					LET iSecuencia2 = iSecuencia2 + 1;
			END IF;
			
			SELECT ciudad_coppel INTO sNumCd FROM bdinteg:si_ciudades WHERE pais = pPais  AND estado = pEstado AND ciudad = pCiudad;
			
			INSERT INTO bdinteg:si_direcciones_loc (numcte, secuencia, tipo_dir, calle, colonia, entre_calles, pais, estado, ciudad, municipio, cod_postal,
						apart_postal, tipo_telef1, telefono1, tipo_telef2, telefono2, tipo_telef3, telefono3, extension, estado_inegi,
						municipio_inegi, localidad_inegi, numerociudad, numeroextcalle, numerointcalle, departamento, numerocalle,
						numerocolonia, puntocardinal, unidadhabitac, manzana, otros, andador, etapa, lote, edificio, entrada, observaciones,
						user_insert, fecha_insert, ind_cofeteltel1, ind_cofeteltel2, ind_cofeteltel3, dom_verificado, lugar_trabajo)
				VALUES (pNumcte, iSecuencia2, pTpoDir, pCalle, pColonia, pEntre_calles, pPais, pEstado, pCiudad ,pMunicipio, pCodPostal,
						pApartadoPostal, pTpoTel1, pTel1, pTpoTel2, pTel2, pTpoTel3, pTel3, pExtension, pEdoInegi, pMunicipioInegi, pLocalidadInegi,
						sNumCd, pNumExtCalle, pNumIntCalle, pDepto, pNumCalle, pNumColonia, pPuntoCardinal, pUnidadHab, pManzana, pOtros, pAndador,
						pEtapa, pLote, pEdificio, pEntrada, pObservaciones, pUserInsert, dFechaHoy, pIndCofetel1, pIndCofetel2, pIndCofetel3,
						pDomCerificado, pLugarTrabajo);			
				
			INSERT INTO cb_marcacliente ( numcte, tipo_domicilio, tipo_marca, fecha_insert, estatus, fecha_modificacion, usuario_marca, 
										usuario_desmarca, origen, sucursal)
				VALUES (pNumcte, pTpoDir, pTpoMarca, dFechaHoy, 'SA', '', pUserInsert, '', pOrigen ,pSucursal);
		
		ELIF pTpoMarca= 'CM' THEN
		  SET LOCK MODE TO WAIT 3;
			IF EXISTS ( SELECT 1 FROM cb_marcacliente WHERE numcte= pNumcte AND estatus = 'SA' AND tipo_domicilio= pTpoDir ) THEN
			
				UPDATE cb_marcacliente SET estatus = 'NA', fecha_modificacion= dFechaHoy, usuario_desmarca = pUserInsert
				WHERE numcte= pNumcte AND estatus = 'SA' AND tipo_domicilio= pTpoDir;						
			END IF;
			
			INSERT INTO cb_marcacliente ( numcte, tipo_domicilio, tipo_marca, fecha_insert, estatus, fecha_modificacion, usuario_marca, 
										usuario_desmarca, origen, sucursal)
				 VALUES (pNumcte, pTpoDir, pTpoMarca, dFechaHoy, 'SA', '', pUserInsert, '', pOrigen ,pSucursal);
			
		END IF;
		
		IF cCod_ret <> 0 THEN
			IF iBandera = 1 THEN
				ROLLBACK WORK;					
			END IF;
			RETURN cCod_ret;
		END IF;	
		
	COMMIT WORK;
	
	RETURN cCod_ret;
END;
END PROCEDURE

DOCUMENT
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION: PROCEDIMIENTO ENCARGADO DE REGISTRAR LAS MARCAS.',
'BD: BDICOBRANZA',
'VERSION: 20110317.1834',
'MODIFICO:ABIGAIL VASAVILBAZO CAÑEDO',
'MODIFICACION: SE AGREGA PARAMETRO DE ENTRADA "LUGAR TRABAJO" Y SE AGREGA EN EL INSERT A LA SI_DIRECCIONES_LOC',
'MODIFICO:Antonio Bastidas',
'MODIFICACION: Se consulta la cuidad de Coppel en la si_ciudades';

create procedure "informix".sp_mail_inserta_cliente( pempresa CHAR(3), ptipo_mensaje SMALLINT, pnumcte CHAR(20), 
                                                     pnum_credito CHAR(20), pemail CHAR(60),ppago_minimo DECIMAL(18,2), 
                                                     psaldo_total DECIMAL(18,2), ppagos_vencidos DECIMAL(18,2), 
                                                     pmonto_convenio DECIMAL(18,2), pfecha_convenio DATE, pfecha_compac DATE, 
                                                     pfecha_primercons DATE, penviado SMALLINT,pcumplio_compac SMALLINT ,
													 ppago_venc DECIMAL(18,2), ppago_min_sin_venc DECIMAL(18,2), psdo_venc_int_mora DECIMAL(18,2))
returning VARCHAR(6);

DEFINE pfechahoy          DATE;
DEFINE pestatus           char (2);
DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);

BEGIN 
   ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
     LET P_COD_RET = SQL_ERR;
     LET P_MENSAJE = ERROR_INFO;
     rollback work;
     RETURN P_COD_RET;
   END exception;
 let P_COD_RET = '000000';
  Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = '001';
LET pestatus = 'AC';

    if nvl(pempresa,'') = '' then
        let P_COD_RET ="200000";
    end if
    if nvl(pnumcte,'') = '' then
        let P_COD_RET ="200001";
    end if
     if nvl(pnum_credito,'') = '' then
        let P_COD_RET ="200002";
    end if
    if nvl(pemail,'') = '' then
        let P_COD_RET ="200003";
    end if

    INSERT INTO bdicobranza:cb_mail_cliente (empresa , tipo_mensaje,fecha_insert, numcte , 
                                         num_credito , email ,pago_minimo , saldo_total , 
                                         pagos_vencidos ,monto_convenio ,fecha_convenio, 
                                         fecha_compac, fecha_primercons, estatus, enviado, cumplio_compac,
										  pago_venc , pago_min_sin_venc , sdo_venc_int_mora )
    VALUES(pempresa , ptipo_mensaje,pfechahoy, pnumcte ,  
            pnum_credito , pemail ,ppago_minimo , psaldo_total ,  
            ppagos_vencidos , pmonto_convenio , pfecha_convenio,  
            pfecha_compac, pfecha_primercons, pestatus, penviado, pcumplio_compac,
			ppago_venc , ppago_min_sin_venc , psdo_venc_int_mora);
 let P_COD_RET = '000000';
end
RETURN P_COD_RET;
END PROCEDURE;