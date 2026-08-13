CREATE PROCEDURE "informix".sp_cnsif_cons_expediente(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20),pNumRegistro INTEGER,pRecuperacion INTEGER)
            
			RETURNING   CHAR(5)  AS Cod_Retorno,
						CHAR(3)  AS Codigo_Grupo,
						CHAR(30) AS Desc_Grupo,
						CHAR(4)  AS Codigo_Documento,
						CHAR(35) AS Desc_Documento,
						SMALLINT AS Secuencia,
						CHAR(20) AS Numero_Cuenta,
						CHAR(4)  AS Clave_Producto,
						CHAR(40) AS Desc_Producto,
						DATE     AS Fecha_Alta,
                        CHAR (2) AS SistemaCuenta;


DEFINE v_codret          CHAR(5);
DEFINE v_cuenta          CHAR(20);
DEFINE v_cve_prod        CHAR(4);
DEFINE v_prod_nombre     CHAR(40);
DEFINE v_cod_docto       CHAR(4);
DEFINE v_fecha_alta      DATE;
DEFINE v_cod_grupo       CHAR(3);
DEFINE v_descrip_gpo     CHAR(30);
DEFINE v_descrip_docto   CHAR(35);
DEFINE v_descrip2        CHAR(30);
DEFINE v_multi_img       CHAR(1);   
DEFINE v_secuencia       SMALLINT;
DEFINE iCont             SMALLINT;
DEFINE sql_err,isam_err,iexiste  INT;   
DEFINE v_SistemaC        CHAR(2);
DEFINE cNumCtePrincipal CHAR(20);
DEFINE iTpo_cliente			INT;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

LET v_codret            = "000";
LET v_cuenta            = " ";
LET v_cve_prod          = " ";
LET v_prod_nombre       = " ";
LET v_cod_docto         = " ";        
LET v_fecha_alta        = today;
LET v_cod_grupo         = " ";
LET v_descrip_gpo       = " ";
LET v_descrip_docto     = " ";
LET v_descrip2          = " ";
LET v_multi_img         = " ";
LET v_secuencia         = 0;
LET iCont               = 0;
LET iexiste             = 0;  
LET v_SistemaC          ="";    
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";

--SET debug FILE TO "/tmp/CNSIF/sp_cnsif_cons_expediente.out";
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET sql_err,isam_err
      IF sql_err <> 0 OR isam_err <> 0 THEN
         LET v_codret = sql_err;
         RETURN v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
				v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;
      END IF;
END EXCEPTION;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCLIENTE  = ''	THEN
       -- datos de entrada incompletos     
       LET v_codret = "00054";
       RETURN v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
			  v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;
    END IF;

    IF pNumRegistro<0 THEN
        LET v_codret='00098';
       RETURN v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
			  v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;				
    ELSE
        IF pRecuperacion<=0 THEN
           LET v_codret='00098';
           RETURN v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
                  v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;
        END IF;
    END IF;       
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'11','2')
	INTO
	v_codret;
	IF (v_codret != '00000')  THEN
		RETURN v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
			   v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;						
	END IF;
	-- TERMINA VALIDACION		
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCLIENTE) INTO v_codret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCLIENTE = cNumCtePrincipal;
	END IF;
	
	FOREACH
	SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE empresa = '001' AND  numcte = cNUMCLIENTE
	UNION
	SELECT NVL(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte WHERE empresa = '001' AND  numcte_tf = cNUMCLIENTE
	ORDER BY 1 desc
	END FOREACH;
	IF iexiste  = 0 THEN 
	LET v_codret = "00055";
	RETURN    v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
			  v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;
	END IF;
 

-- ****************************************************************************
-- obtener registros
-- ****************************************************************************
	SELECT NVL(COUNT(cliente),0) INTO iexiste FROM bdidigital@coppelimg_tcp:dg_expediente WHERE empresa = '001' AND  cliente = cNUMCLIENTE; 
	IF iexiste  = 0 THEN 
	LET v_codret = "00093";
	RETURN    v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
			  v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;
	END IF;
	SET ISOLATION TO DIRTY READ;
    FOREACH

        SELECT SKIP pNumRegistro FIRST pRecuperacion  gd.cod_grupo, gd.descripcion, expe.cod_docto,td.descripcion,nvl(expe.descrip2," "),
                expe.secuencia, expe.cuenta,expe.producto , expe.prod_nombre, expe.fecha_alta
        INTO    v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,v_descrip2,
				v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta
        FROM    bdidigital@coppelimg_tcp:dg_expediente expe,
                bdidigital@coppelimg_tcp:dg_grupodocto gd,
                bdidigital@coppelimg_tcp:dg_tipodocumento td
        WHERE   expe.cod_docto       = td.cod_docto 
                and td.cod_grupo    = gd.cod_grupo 
                and expe.empresa     = '001'
                and expe.cliente     = cNUMCLIENTE 
                and expe.descrip2    <> 'firma_borra_da'
                and expe.cod_docto<>'0219'
        ORDER BY 4,1,3
		
		IF v_codret = '000' THEN
			LET v_codret = '00000';
		END IF
		
		IF v_cod_docto IN('0023','0024','0025') THEN
			LET v_descrip_docto = v_descrip2;
		END IF		

        LET iCont = iCont +1;

        SELECT NVL(COUNT(producto),0) INTO iexiste FROM bdicheq:sc_producto
        WHERE producto=v_cve_prod;
        IF iexiste>0 THEN 
            LET v_SistemaC='01';
        ELSE
            SELECT NVL(COUNT(num_producto),0) INTO iexiste FROM bdicred:sd_definicion
            WHERE num_producto=v_cve_prod;
            IF iexiste>0 THEN 
                LET v_SistemaC='06';
            ELSE
                SELECT NVL(COUNT(cod_instrum),0) INTO iexiste FROM bdinvers:sv_instrum
                WHERE cod_instrum=v_cve_prod;
                IF iexiste>0 THEN 
                    LET v_SistemaC='03';
                ELSE
                    LET v_SistemaC='00';
                END IF
            END IF;
       END IF;     
 
                      
        RETURN  v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
				v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC  WITH resume;

    END FOREACH;
	
	IF iCont = 0 THEN
		LET v_codret = '1001'; 
		RETURN  v_codret,v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,
				v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC;
	END IF;

END    
END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÃA",
"FUNCIONAMIENTO:Obtener la informaciÃ³n de los Documentos del Expediente Digital del Cliente. ",
"El SP obtendrÃ¡ la informaciÃ³n de la Base de Datos central de Informix, enviando como parÃ¡metro el  NÃºmero  de cliente",
"FECHA : 28-02-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_bitacora_ife_opt(pnumcte char(9), pejecutivo char(8), psucursal char(5), pcadena_anverso CHAR(2200), 
                  pcadena_reverso CHAR(2200), pflag_idbox char(1), pflag_ws char(1), pflag_captura char(1), presultado char(50), 
                  pcausa_rechazo char(100),  pCod_Resp_IFE char(10), pResp_IFE char(50), pTime_IFE char(30),  pAccess_IFE char(30),
                  pStamp_IFE char(30), pOCR_IFE char(1), pApPat_IFE char(1), pApMat_IFE char(1), pNombre_IFE char(1), pCalleNum_IFE char(1),
                  pColCp_IFE char(1), pMpoEnt_IFE char(1), pFolioNal_IFE char(1), pAnioReg_IFE char(1), pEmision_IFE char(1), pCveElec_IFE char(1),
                  pCurp_IFE char(1), pEstado char(1), pMpio_IFE char(1), pLocalidad_IFE char(1), pSeccion_IFE char(1), pAnioEmision_IFE char(1),
                  pVigencia_IFE char(1), pEdad_IFE char(1), pSexo_IFE char(1), pANSI2_IFE char(1), pANSI7_IFE char(1), pModelo_IFE char(25),
				  pTempANSI2 char(1400), pTempANSI7 char(1400), pCompANSI2 char(6), pCompANSI7 char(6))

RETURNING	 VARCHAR(5) --Codigo de Retorno

	DEFINE iSqlErr			INTEGER;
    DEFINE sErrParseo       CHAR(5);
	DEFINE iValorComp       INTEGER; 		--FOLIO 369
	DEFINE iCompAnsi2       INTEGER;		--FOLIO 369
	DEFINE iCompAnsi7       INTEGER;		--FOLIO 369
	
	DEFINE cCodRet         CHAR(5);
    DEFINE sPonderacion    SMALLINT;
	DEFINE cSituacionCte   CHAR(1);
    DEFINE sCausaCte       SMALLINT;
	DEFINE cTest_1		   CHAR(5);
	DEFINE cTest_2		   CHAR(5);
	DEFINE cTest_3		   CHAR(5);
	DEFINE cTest_4		   CHAR(5);
	DEFINE cTest_5	       CHAR(5);
	DEFINE iConluz		   SMALLINT;
	DEFINE cBandera		   CHAR(1);
	DEFINE cCodidentif	   CHAR(2);
	
    LET iSqlErr = 0;
    LET sErrParseo='';
	LET iCompAnsi2 = NVL(pCompANSI2,0);		--FOLIO 369
	LET iCompAnsi7 = NVL(pCompANSI7,0);		--FOLIO 369
	LET cCodRet='00000';
	LET sPonderacion = "0";
	LET cSituacionCte   ="";
	LET sCausaCte  = 0;
	LET iConluz = 0;
	LET cBandera = '0';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
        --SET DEBUG FILE TO '/home/sysifx/MarcoC/369/bitacora_ife.sql';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	
		--VALIDAR TIPO DE IDENTIFICACION
		SELECT codidentifi INTO cCodidentif FROM bdinteg:"informix".si_ctepf where numcte = pnumcte;
		IF(TRIM(cCodidentif) <> 'A' AND TRIM(cCodidentif) <> 'B') THEN
			RETURN '00000';
		END IF;
		
		
		SELECT valor INTO iValorComp FROM bdinteg:"informix".si_param where cod_param = 457;  --FOLIO 369
		
		IF pTempANSI2 <> '' THEN    --FOLIO 369
			IF iCompAnsi2 >= iValorComp THEN
				LET pANSI2_IFE = 'V';
			ELSE
				LET pANSI2_IFE = 'F';
			END IF;
		ELSE
			LET pANSI2_IFE = '';			
			LET iCompAnsi2 = 0;			
		END IF;
		
		IF pTempANSI7 <> '' THEN
			IF iCompAnsi7 >= iValorComp THEN 
				LET pANSI7_IFE = 'V';
			ELSE
				LET pANSI7_IFE = 'F';
			END IF
		ELSE
			LET pANSI7_IFE = '';
			LET iCompAnsi7 = 0;
		END IF;    --FOLIO 369
		
		LET pModelo_IFE = TRIM(pModelo_IFE);
		IF pModelo_IFE<>'' THEN
			
			--SE DA POR VERDADERO EL RESULTADO PARA LOS NUEVOS MODELOS DE INE (AJUSTE TEMPORAL)
			--IF(pModelo_IFE = '' AND pcadena_anverso = '' AND pcadena_reverso = '') THEN
				--LET presultado = 'Verdadero';
				--LET pModelo_IFE = 'IDMEXG1';
			--END IF;
			
			INSERT INTO bdinteg:"informix".si_bitacora_ife (numcte, ejecutivo, sucursal, cadena_anverso, cadena_reverso, flag_idbox, flag_ws,
										 flag_captura, resultado, causa_rechazo, fecha, cod_resp_ife, resp_ife, time_ife, access_ife, stamp_ife,
										 ocr_ife, appat_ife, apmat_ife, nombre_ife, callenum_ife, colcp_ife, mpoent_ife, folional_ife, anioreg_ife, 
										 emision_ife, cveelec_ife, curp_ife, estado, mpio_ife, localidad_ife, seccion_ife, anioemision_ife, vigencia_ife, 
										 edad_ife, sexo_ife, ansi2_ife, ansi7_ife, modelo_ife, tmpansi2_ife, compansi2_ife, tmpansi7_ife, compansi7_ife)
								  VALUES(pnumcte, pejecutivo, psucursal, pcadena_anverso, pcadena_reverso, pflag_idbox, pflag_ws, 
										 pflag_captura, presultado, pcausa_rechazo, current, pCod_Resp_IFE, pResp_IFE, pTime_IFE,  pAccess_IFE, pStamp_IFE, 
										 pOCR_IFE, pApPat_IFE, pApMat_IFE, pNombre_IFE, pCalleNum_IFE,pColCp_IFE, pMpoEnt_IFE, pFolioNal_IFE, pAnioReg_IFE, 
										 pEmision_IFE, pCveElec_IFE, pCurp_IFE, pEstado, pMpio_IFE, pLocalidad_IFE, pSeccion_IFE, pAnioEmision_IFE, pVigencia_IFE, 
										 pEdad_IFE, pSexo_IFE, pANSI2_IFE, pANSI7_IFE, pModelo_IFE, pTempANSI2, iCompAnsi2, pTempANSI7, iCompAnsi7);

			EXECUTE PROCEDURE bdinteg:"informix".sp_parsea_cadena_idbx_opt(pnumcte) INTO sErrParseo;
			
			SELECT test_uv_reflec_anv, test_uv_shape_anv, test_ir_ink_anv, test_uv_reflectance_rev, test_ir_ink_rev 
			INTO cTest_1, cTest_2, cTest_3, cTest_4, cTest_5
			FROM bdinteg:"informix".si_bitacora_ife WHERE fecha = CURRENT AND numcte = pnumcte;
			
			IF (cTest_1) = 'OK' THEN
				LET iConluz = iConluz + 1;
			END IF;
			IF (cTest_2) = 'OK' THEN
				LET iConluz = iConluz + 1;
			END IF;
			IF (cTest_3) = 'OK' THEN
				LET iConluz = iConluz + 1;
			END IF;
			IF (cTest_4) = 'OK' THEN
				LET iConluz = iConluz + 1;
			END IF;
			IF (cTest_5) = 'OK' THEN
				LET iConluz = iConluz + 1;
			END IF;
			
			
			
			
				/*IF (SUBSTR(pModelo_IFE,6,1)='E') THEN
					LET iConluz = iConluz + 1;
				END IF;*/
			
			
			
			IF iConluz >=3 THEN
				LET cBandera = '1';
			END IF;	
			
			IF	(cBandera = '1') THEN
				LET pCod_Resp_IFE = TRIM(pCod_Resp_IFE);
				IF  pCod_Resp_IFE = '' THEN
					UPDATE 	bdinteg:"informix".si_bitacora_ife SET resultado = 'Verdadero',causa_rechazo = 'Datos Validos de acuerdo al WS del IFE',fecha = CURRENT,cod_resp_ife = '90',resp_ife = 'OCR Vigente',time_ife = 'true',access_ife = 'true',stamp_ife = TO_CHAR(CURRENT, '%Y-%m-%dT%H:%M:%S.'),ocr_ife = 'V',appat_ife = 'V',
					apmat_ife = 'V',nombre_ife = 'V',callenum_ife = 'V',colcp_ife = 'V',mpoent_ife= 'V',folional_ife= 'V',anioreg_ife= 'V',emision_ife= 'V',cveelec_ife= 'V',curp_ife= 'V',estado= 'V',mpio_ife= 'V',localidad_ife= 'V',seccion_ife= 'V',anioemision_ife= 'V',vigencia_ife= 'V',edad_ife= 'V',sexo_ife= 'V',ansi2_ife= 'V'
					WHERE fecha = CURRENT AND numcte = pnumcte;    
					
					LET pANSI2_IFE = 'V';
					LET presultado = 'Verdadero';
				END IF;
			END IF;
				
			IF pCod_Resp_IFE IN ('90','91','92','93','94') THEN
			LET pApPat_IFE = TRIM(pApPat_IFE);
			LET pApMat_IFE = TRIM(pApMat_IFE);
			LET pNombre_IFE = TRIM(pNombre_IFE);
				IF pOCR_IFE='F' OR pApPat_IFE='F' OR pApMat_IFE='F' OR pNombre_IFE='F' THEN
					LET presultado = 'Falso';
					LET pcausa_rechazo = 'Datos NO Validos de Acuerdo al WS del INE';
					UPDATE bdinteg:"informix".si_bitacora_ife SET resultado=presultado, causa_rechazo=pcausa_rechazo WHERE numcte=pnumcte and fecha=current;
				END IF;
			END IF;
			
			LET pANSI2_IFE = TRIM(pANSI2_IFE);
			LET pANSI7_IFE = TRIM(pANSI7_IFE);
			IF (pANSI2_IFE='F' AND pANSI7_IFE='F') OR (pANSI2_IFE='F' AND pANSI7_IFE='') OR (pANSI2_IFE='' AND pANSI7_IFE='F') THEN  --FOLIO 369
				LET presultado = 'Falso';
				LET pcausa_rechazo = 'Datos NO Validos de Acuerdo al WS del INE';
				UPDATE bdinteg:"informix".si_bitacora_ife SET resultado=presultado, causa_rechazo=pcausa_rechazo WHERE numcte=pnumcte and fecha=current;
			END IF;
			LET presultado = TRIM(presultado);
			IF presultado = 'Verdadero' THEN
			 
				 EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(5,'001',pNumCte,'P',109,'', '','', '', '','','')
				 INTO cCodRet, sPonderacion,cSituacionCte,sCausaCte;
			
			END IF;
			 
		END IF;
		RETURN '00000';
	END;
END PROCEDURE
DOCUMENT
'MODIFICA: MARCO CARDENAS',
'NUMERO DE EMPLEADO: 97959456',
'SOLICITA: IVAN ULISES SALCEDO ROJO',
'DESCRIPCION: SE AGREGA TEMPLATE DE LAS HUELLAS 2 Y 7, Y EL VALOR DE COMPARACION CON EL INE A LA TABLA SI_BITACORA_IFE',
'FOLIO: 369.1 - Validar huella de cliente en el INE',
'FECHA: 19/02 /2018',
'MODIFICA: MARCO CARDENAS',
'NUMERO DE EMPLEADO: 97959456',
'SOLICITA: IVAN ULISES SALCEDO ROJO',
'DESCRIPCION: SE MODIFICA PARA GUARDAR EN BITACORA CUANDO NO SE UTILICE EL IDBOX',
'FOLIO: 588.1 - Enrolamiento de clientes 442 en mantenimiento de clientes, mantenimiento de huellas y comparacion unidactilar.',
'FECHA: 08/07 /2019',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_cnsif_cons_expediente_totales(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCLIENTE CHAR(20))
            
			RETURNING   CHAR(5)  AS Cod_Retorno,
						INTEGER  AS NumFilas;


DEFINE v_codret          CHAR(5);
DEFINE v_cuenta          CHAR(20);
DEFINE v_cve_prod        CHAR(4);
DEFINE v_prod_nombre     CHAR(40);
DEFINE v_cod_docto       CHAR(4);
DEFINE v_fecha_alta      DATE;
DEFINE v_cod_grupo       CHAR(3);
DEFINE v_descrip_gpo     CHAR(30);
DEFINE v_descrip_docto   CHAR(35);
DEFINE v_descrip2        CHAR(30);
DEFINE v_multi_img       CHAR(1);   
DEFINE v_secuencia       SMALLINT;
DEFINE iCont             SMALLINT;
DEFINE sql_err,isam_err,iexiste  INT;   
DEFINE v_SistemaC        CHAR(2);
DEFINE cNumCtePrincipal CHAR(20);
DEFINE iTpo_cliente			INT;
DEFINE iNumFilas 		INTEGER;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

LET v_codret            = "000";
LET v_cuenta            = " ";
LET v_cve_prod          = " ";
LET v_prod_nombre       = " ";
LET v_cod_docto         = " ";        
LET v_fecha_alta        = today;
LET v_cod_grupo         = " ";
LET v_descrip_gpo       = " ";
LET v_descrip_docto     = " ";
LET v_descrip2          = " ";
LET v_multi_img         = " ";
LET v_secuencia         = 0;
LET iCont               = 0;
LET iexiste             = 0;  
LET v_SistemaC          ="";    
LET iTpo_cliente=0;
LET cNumCtePrincipal = "";
LET iNumFilas =0;

--SET debug FILE TO "/tmp/mfinis/sp_cnsif_cons_expediente_totales.out";
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
   ON EXCEPTION SET sql_err,isam_err
      IF sql_err <> 0 OR isam_err <> 0 THEN
			LET v_codret = sql_err;
		    UPDATE bdicnweb:"informix".sw_verificastatusexpediente
			SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
         RETURN v_codret,iNumFilas;
      END IF;
END EXCEPTION;


	--LIMPIA TABLAS
    DELETE FROM bdicnweb:"informix".sw_expedientetotales_tmp WHERE usuario_insert = TRIM(cID_USUARIOC);
	
	DELETE FROM bdicnweb:"informix".sw_verificastatusexpediente WHERE usuario_insert = TRIM(cID_USUARIOC);
	INSERT INTO bdicnweb:"informix".sw_verificastatusexpediente(usuario_insert,status,num_registros,error_proceso,error) VALUES(cID_USUARIOC,'I',0,'','00000');
		


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cNUMCLIENTE  = ''	THEN
       -- datos de entrada incompletos    
			UPDATE bdicnweb:"informix".sw_verificastatusexpediente
			SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;	   
			LET v_codret = "00054";
       RETURN v_codret,iNumFilas;
    END IF;
  
	--VALIDACION
	EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCLIENTE,'11','2')
	INTO
	v_codret;
	IF (v_codret != '00000')  THEN
		 UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		 SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
		RETURN v_codret,iNumFilas;						
	END IF;
	-- TERMINA VALIDACION		
	
	
	EXECUTE PROCEDURE bdicnweb:"informix".sp_validacte_transfer(cNUMCLIENTE) INTO v_codret,iTpo_cliente,cNumCtePrincipal;
	IF cNumCtePrincipal IS NOT NULL THEN
		LET cNUMCLIENTE = cNumCtePrincipal;
	END IF;
	
	
	FOREACH
	SELECT FIRST 1 NVL(COUNT(numcte),0) INTO iexiste FROM si_cliente WHERE empresa = '001' AND  numcte = cNUMCLIENTE
	UNION
	SELECT NVL(COUNT(numcte_tf),0) FROM bditransfer:tf_maecte WHERE empresa = '001' AND  numcte_tf = cNUMCLIENTE
	ORDER BY 1 desc
	END FOREACH;
	
	IF iexiste  = 0 THEN 
	LET v_codret = "00055";
		UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
	RETURN v_codret,iNumFilas;	
	END IF;
 

-- ****************************************************************************
-- obtener registros
-- ****************************************************************************
	SELECT NVL(COUNT(cliente),0) INTO iexiste FROM bdidigital@coppelimg_crx:dg_expediente WHERE empresa = '001' AND  cliente = cNUMCLIENTE; 
	IF iexiste  = 0 THEN 
	LET v_codret = "00093";
	  UPDATE bdicnweb:"informix".sw_verificastatusexpediente
	  SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
	RETURN v_codret,iNumFilas;	
	END IF;
	
	SET ISOLATION TO DIRTY READ;
    
	FOREACH

        SELECT  gd.cod_grupo, gd.descripcion, expe.cod_docto,td.descripcion,nvl(expe.descrip2," "),
                expe.secuencia, expe.cuenta,expe.producto , expe.prod_nombre, expe.fecha_alta
        INTO    v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,v_descrip2,
				v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta
        FROM    bdidigital@coppelimg_crx:dg_expediente expe,
                bdidigital@coppelimg_crx:dg_grupodocto gd,
                bdidigital@coppelimg_crx:dg_tipodocumento td
        WHERE   expe.cod_docto       = td.cod_docto 
                and td.cod_grupo    = gd.cod_grupo 
                and expe.empresa     = '001'
                and expe.cliente     = cNUMCLIENTE 
                and expe.descrip2    <> 'firma_borra_da'
				and expe.cod_docto	<> '0219' 
        --ORDER BY 4,1,3
		
		
		IF v_cod_docto IN('0023','0024','0025') THEN
			LET v_descrip_docto = v_descrip2;
		END IF		


        SELECT NVL(COUNT(producto),0) INTO iexiste FROM bdicheq:sc_producto
        WHERE producto=v_cve_prod;
        IF iexiste>0 THEN 
            LET v_SistemaC='01';
        ELSE
            SELECT NVL(COUNT(num_producto),0) INTO iexiste FROM bdicred:sd_definicion
            WHERE num_producto=v_cve_prod;
            IF iexiste>0 THEN 
                LET v_SistemaC='06';
            ELSE
                SELECT NVL(COUNT(cod_instrum),0) INTO iexiste FROM bdinvers:sv_instrum
                WHERE cod_instrum=v_cve_prod;
                IF iexiste>0 THEN 
                    LET v_SistemaC='03';
                ELSE
                    LET v_SistemaC='00';
                END IF
            END IF;
       END IF;  
	   
		LET iNumFilas = iNumFilas +1;
                      
       INSERT INTO bdicnweb:"informix".sw_expedientetotales_tmp (cod_grupo, descrip_gpo, cod_docto, descrip_docto, secuencia, cuenta, cve_prod, prod_nombre, fecha_alta, sistemac, usuario_insert) 
        VALUES(v_cod_grupo,v_descrip_gpo,v_cod_docto,v_descrip_docto,v_secuencia,v_cuenta,v_cve_prod,v_prod_nombre,v_fecha_alta,v_SistemaC,cID_USUARIOC);
		
    END FOREACH;
	
	IF iNumFilas = 0 THEN
		LET v_codret = '1001'; 
		UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		SET status = 'E', error_proceso = 'S', error = v_codret WHERE usuario_insert = cID_USUARIOC;
		RETURN v_codret,iNumFilas;	
	END IF;

		UPDATE bdicnweb:"informix".sw_verificastatusexpediente
		SET status = 'T', error_proceso = 'N', num_registros = iNumFilas WHERE usuario_insert = cID_USUARIOC;
		RETURN v_codret,iNumFilas;

END    
END PROCEDURE
DOCUMENT
"AUTOR : Daniel Reyes Guillen",
"FUNCIONAMIENTO:Obtener la información de los Documentos del Expediente Digital del Cliente. Se agrega hilo. ",
"El SP obtendra la informacion de la Base de Datos central de Informix, enviando como parametro el  Numero  de cliente",
"FECHA : 05/05/2021",
"BD    : bdinteg";

CREATE PROCEDURE "informix".sp_aut_aviso_terminos_cplpay(pEmpresa CHAR(3),pNumCte CHAR(20),pSucursal CHAR(4), pRespuesta CHAR(1),pCodigo_doc CHAR(20))
	RETURNING   CHAR(5)  AS codigo_retorno;	---cod_ret

	-- declara variables 
    DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje			CHAR(300);
	DEFINE cCodigoRespuesta		CHAR(1);
	DEFINE cCodigodoc		CHAR(20);

	
	
	DEFINE iSqlErr				INTEGER;
	
	-- inicia variables 
	LET cCodRet = '00000';
	LET cMensaje = '';
	LET cCodigoRespuesta = '';
	LET cCodigodoc = '';
	
	LET iSqlErr = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO "/home/sysifx/sp_aut_aviso_terminos_cplpay.out";
		--TRACE ON;	
		
		IF pEmpresa = '' OR  pNumCte = '' OR  pSucursal = '' OR pRespuesta  = '' OR pCodigo_doc  = '' THEN
			
			LET cCodRet = '00001';
		
		ELSE
		
			IF pRespuesta  = '1' THEN -- se acepta documento
			
				SELECT  msj_acepta,codigo_acepta,codigo_doc
				into cMensaje, cCodigoRespuesta, cCodigodoc
				FROM bdinteg:"informix".si_param_doc_cplpay
				WHERE empresa = pEmpresa
				AND codigo_doc = pCodigo_doc;
							
			ELSE
			
				LET cCodRet = '00001';				
				RETURN cCodRet;
			
			END IF;	
				
				
			INSERT INTO bdinteg:"informix".si_aut_aviso_terminos_cplpay(empresa,numcte,sucursal,respuesta,mensaje,codigo_doc,fecha)
			VALUES (pempresa,pnumcte,psucursal,cCodigoRespuesta,cMensaje,cCodigodoc,current);
			
			LET cCodRet = '00000';			
			
		END IF;		
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'Creador: 95451706 - Efrain Miranda Miranda',
'RQM: TDC Coppel Pay',
'Descripcion: El procedimiento se encarga de registrar si se acepta o no el aviso, terminos y condicions',
'Solicito: Citlali Guadalupe Dominguez Gomez',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_consulta_param_doc_cplpay(pEmpresa CHAR(3),pTipoConsulta CHAR(1),pCodigo_doc CHAR(20))
	RETURNING   CHAR(5)  AS codigo_retorno,	       --- cod_ret
				CHAR(5)  AS codigo_documento,      --- codigo de documento
				CHAR(200)  AS valor,			   --- valor que se mostrara en pantalla
				CHAR(200)  AS comentario,	       --- descripcion
				CHAR(100)  AS nomdoc,			   --  nombre del documento
				CHAR(1)  AS docactivo;		       --  1= docuemtno activo, 0 = documento inactivo

	-- declara variables 
    DEFINE cCodRet              CHAR(5);
	DEFINE cCodigoDoc           CHAR(5);	
	DEFINE cValor				CHAR(200);	
	DEFINE cCmentarios			CHAR(200);	
	DEFINE cNomdoc				CHAR(100);	
	DEFINE cDocactivo			CHAR(1);	
	
	DEFINE iSqlErr				INTEGER;
	
	
	-- inicia variables 
	LET cCodRet = '00000';
	LET cCodigoDoc = '';
	LET cValor = '';
	LET cCmentarios = '';
	LET cNomdoc = '';
	LET cDocactivo = '';
	
	LET iSqlErr = 0;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
	
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
					LET cCodRet = iSqlErr;
			END IF;
			RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo;
		END EXCEPTION;
		
		
		--SET DEBUG FILE TO "/home/sysifx/sp_consulta_param_doc_cplpay.out";
		--TRACE ON;	
		
		IF pEmpresa = '' OR  pTipoConsulta = '' THEN
			
			LET cCodRet = '00001';
			
		    RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo;
			
		ELIF  pTipoConsulta = '1' THEN
		--pTipoConsulta = 1 se usa para consultar todos los registros de la tabla		
			FOREACH
				SELECT codigo_doc,valor,comentarios , nomdoc, docactivo
				INTO cCodigoDoc, cValor , cCmentarios, cNomdoc, cDocactivo
				FROM bdinteg: "informix".si_param_doc_cplpay 
				WHERE empresa = pEmpresa
					AND docactivo = '1'
				ORDER BY codigo_doc
				
				RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo WITH RESUME;
			
			END FOREACH;
			
		ELIF  pTipoConsulta = '2' AND pCodigo_doc != '' THEN
		--pTipoConsulta = 2 se usa para consultar registro especifico la tabla	
		
			FOREACH
				SELECT codigo_doc,valor,comentarios , nomdoc, docactivo
				INTO cCodigoDoc, cValor , cCmentarios, cNomdoc, cDocactivo
				FROM bdinteg: "informix".si_param_doc_cplpay 
				WHERE empresa = pEmpresa
					AND codigo_doc = pCodigo_doc
					AND docactivo = '1'
				ORDER BY codigo_doc
				
				RETURN cCodRet,cCodigoDoc,cValor,cCmentarios, cNomdoc, cDocactivo WITH RESUME;
			
			END FOREACH;
		ELSE 
			
			LET cCodRet = '00001';
			
		    RETURN cCodRet,cCodigoDoc,cValor,cCmentarios,cNomdoc, cDocactivo;
			
		END IF;		   
	END;
END PROCEDURE
DOCUMENT
'Creador: 95451706 - Efrain Miranda Miranda',
'RQM: TDC Coppel Pay',
'Descripcion: El procedimiento se encarga de consultar los documentos que se deben aprobar',
'Solicito: Citlali Guadalupe Dominguez Gomez',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_obtclavetarjeta(Tipot CHAR(1), pBin CHAR(6),pSubBin CHAR(2), pCodProdCta CHAR(4), pOperacion CHAR(35))
   RETURNING CHAR(5), CHAR(6), CHAR(3), CHAR(3);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   DEFINE cCodBin             CHAR(6);
   DEFINE cCodProdTar            CHAR(3);
   DEFINE cClave            CHAR(3);
     
   LET cCodRet        ='00000';   
   LET cCodBin        ='000000';
   LET cCodProdTar       ='000';
   LET cClave       ='000';
   
BEGIN
                ON EXCEPTION SET iSqlErr
                      IF iSqlErr <> 0 THEN
                         LET cCodRet = iSqlErr;
                                                               
                         RETURN cCodRet, cCodBin, cCodProdTar, cClave;
                      END IF;
                END EXCEPTION;
                
                SET LOCK MODE TO WAIT 3;
                SET ISOLATION TO DIRTY READ;
				
				IF pOperacion <> 'Solicitud de Tarjeta Personalizada' THEN
					SELECT b.bin, b.codproductotarjeta, clave  
					INTO cCodBin, cCodProdTar, cClave
					FROM intercard:binproducto a
					INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
					WHERE a.bin = pBin 
					AND a.producto= pSubBin 
					AND a.codprodcta = pCodProdCta
					AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);
				ELSE
					IF pCodProdCta NOT IN ('7000','8100') THEN
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin and descripcion LIKE 'PERSONALIZADO PREDISE%') ;
					ELSE
						SELECT b.bin, b.codproductotarjeta, clave  
						INTO cCodBin, cCodProdTar, cClave
						FROM intercard:binproducto a
						INNER JOIN intercard:tipotarjeta b ON a.codproductotarjeta=b.codproductotarjeta
						WHERE a.bin = pBin 
						AND a.producto= pSubBin 
						AND a.codprodcta = pCodProdCta
						AND consecutivo = (SELECT max(consecutivo) FROM intercard:tipotarjeta WHERE bin = pBin);
					END IF;
				END IF;
        

           IF cCodBin IS NULL or cCodProdTar IS NULL OR cClave IS NULL THEN
                      LET  cCodRet = '00001';
           END IF;

           RETURN cCodRet, cCodBin, cCodProdTar, cClave;
END;
END PROCEDURE;