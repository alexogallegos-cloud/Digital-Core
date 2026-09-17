CREATE PROCEDURE "informix".sp_obtiene_intrfz_serv_web( pNumCategoria Char(2),
													pNumConvenio Char(3))
   RETURNING CHAR(5) as CodRet, CHAR(5) as Trans_Interact, CHAR(16) as Ip, INTEGER as Puerto, INTEGER as TimeOut, CHAR(4) as Cod_cons_trama, CHAR(10) as Campo_codresp, CHAR(4) as Cod_cons_codresp, CHAR(4) as Cod_cons_bitacora, CHAR(4) as Cod_cons_validad, CHAR(1) as Noenvia_Resp, CHAR(4) as Cod_eror_noenvia;

-- Declaracion de variables 
DEFINE cCodRet 			 CHAR(5);
DEFINE cTrans_Interact	 CHAR(5);
DEFINE cIp 				 CHAR(16);
DEFINE iPuerto 			 INTEGER;
DEFINE iTimeOut 		 INTEGER;
DEFINE cCod_cons_trama 	 CHAR(4);
DEFINE cCampo_codresp  	 CHAR(10);
DEFINE cCod_cons_codresp CHAR(4);
DEFINE iSqlErr           INTEGER;
DEFINE cNoenvia_Resp	 CHAR (1);
DEFINE cCod_eror_noenvia CHAR(4);
DEFINE cCod_cons_bitacora CHAR (4);
DEFINE cCod_cons_validad CHAR(4);

LET cCodRet 		  = '00001';
LET cTrans_Interact   ='';
LET cIp 			  ='';
LET iPuerto 		  = 0;
LET iTimeOut 		  = 0;
LET cCod_cons_trama   ='';
LET cCampo_codresp 	  ='';
LET cCod_cons_codresp ='';
LET iSqlErr 		  = 0;
LET cNoenvia_Resp	  = '';
LET cCod_eror_noenvia = '';
LET cCod_cons_bitacora = '';
LET cCod_cons_validad ='';
  
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cCampo_codresp, cCod_cons_codresp, cCod_cons_bitacora, cCod_cons_validad, cNoenvia_Resp, cCod_eror_noenvia;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/sp_obtiene_intrfz_serv.out";
	--TRACE ON;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  	

	SELECT trans_interact, ip, puerto, time_out, cod_cons_trama, campo_codresp, cod_cons_codresp,cod_cons_bitacora,cod_cons_valida, noenvia_respuesta, cod_error_noenviada
	INTO cTrans_Interact, cIp, iPuerto, iTimeOut, cCod_cons_trama, cCampo_codresp, cCod_cons_codresp,cCod_cons_bitacora, cCod_cons_validad, cNoenvia_Resp, cCod_eror_noenvia
	FROM bdisac: "informix".sac_intrfz_serv where numcategoria= pNumCategoria and numconvenio= pNumConvenio;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 OR cTrans_Interact= '' OR cIp = '' OR iPuerto= '' OR iTimeOut= '' OR cCod_cons_trama= '' OR cCampo_codresp= '' OR cCod_cons_codresp= '' THEN
		LET cCodRet = '00001';
	ELSE
		LET cCodRet = '00000';
	END IF
	
	RETURN cCodRet, NVL (cTrans_Interact,''), NVL(cIp,''), NVL (iPuerto,0), NVL(iTimeOut,0), NVL(cCod_cons_trama,''), NVL (cCampo_codresp,''), NVL(cCod_cons_codresp,''), NVL(cCod_cons_bitacora,''), NVL(cCod_cons_validad,''), NVL(cNoenvia_Resp,''), NVL(cCod_eror_noenvia,'');
		
	END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION:  Con el numero de categoria y numero de convenio obtendra la configuracion desde la tabla bdisac: sac_intrfz_serv.',
'FOLIO: 1468 - PagosRef_PagoImpEdoMex',
'FECHA : 09/02/2015',
'VERSION: 20150209.1452',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_obtiene_msw_validacion_web( pCodigoRespuesta	Char(40),
												  pNumCategoria  CHAR(2),
												  pNumConvenio	 CHAR(3))
   RETURNING CHAR(5) as cCodRet, CHAR (1) as cReversa, CHAR (4) as cCod_err, CHAR (4) as cCod_err_reversa, CHAR(80) as cEnc_errores;

-- Declaracion de variables 
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE cReversa			CHAR (1);
	DEFINE cCod_err			CHAR (4);
	DEFINE cCod_err_reversa	CHAR (4);
	DEFINE cEnc_errores		CHAR (80);

	LET cCodRet				= '11111';
	LET iSqlErr				= 0;
	LET cReversa			= '';
	LET cCod_err			= '';
	LET cCod_err_reversa	= '';
	LET cEnc_errores		= '';
						
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cReversa, cCod_err, cCod_err_reversa, cEnc_errores;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/isaias/sp_obtiene_msw_validacion.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		  
    IF NVL (pCodigoRespuesta, '') = '' OR NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' THEN
			 LET cCodRet = '00001';
	ELSE
		SELECT reversa, cod_err, cod_err_reversa, enc_errores 
		INTO cReversa, cCod_err, cCod_err_reversa, cEnc_errores 
		FROM bdisac: "informix".sac_msw_validacion  
		WHERE clave= pCodigoRespuesta AND numcategoria= pNumCategoria AND numconvenio= pNumConvenio;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
		ELSE 
			LET cCodRet = '00000';
		END IF;
	END IF;
	
	RETURN cCodRet, NVL(cReversa,''), NVL(cCod_err,''), NVL(cCod_err_reversa,''), NVL(cEnc_errores,'');
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: SP regresa los datos de error que se almacenaron en bdisac: sac_msw_validacion con respecto al codigo de respuesta, numero de categoria, y numero de convenio.',
'FOLIO: 1468-PagosRef_PagoImpEdoMex',
'FECHA : 13 de Febrero de 2015',
'VERSION: 20150212.1621',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_valida_dv_megacable
(
	  pNumRef CHAR (26), pImporte CHAR (10)
)
	
RETURNING CHAR(5) AS codret;


DEFINE cCod_ret         CHAR(5);
DEFINE iSqlErr          INTEGER;
DEFINE cNumRef          Char(26);
DEFINE iSuma            int;
DEFINE iLonNumRef       int;
DEFINE iMult            int; 
DEFINE iSacMov          int; 
DEFINE iSacMovHis       int; 
DEFINE iLongCadRef      int;
DEFINE iResiduo         int;
DEFINE iDigVer          int;
DEFINE iPosCad          int;
DEFINE cImporte         CHAR(7);
--DEFINE vFechaRef        VARCHAR(8);
DEFINE vFecha_Hoy       DATE;
DEFINE cDia             CHAR(2);
DEFINE cMes             CHAR(2);
DEFINE cAnio            CHAR(4);
DEFINE cFechaformat	    DATE;
--DEFINE bandera INTEGER;

LET cCod_ret    ='00000';	--Iniciamos en exitoso cambiara de acuerdo a las validaciones agregadas.
LET iSqlErr     = 0;
LET cNumRef     = pNumRef;
LET iSuma       = 0;
LET iLonNumRef  = 0;
LET iSacMov     = 0;
LET iSacMovHis  = 0;
LET iMult       = 2;
LET iLongCadRef = 1;
LET iResiduo    = 0;
LET iDigVer     = 0;
LET iPosCad     = 0;
LET cImporte    ='';	
--LET vFechaRef ='';	
LET vFecha_Hoy  ='';	
LET cDia        = '';
LET cMes        = '';
LET cAnio       = '';
LET cFechaformat = '';
--LET bandera=0;


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_ret = iSqlErr;
				RETURN cCod_ret;	
				--RETURN bandera;	
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
			--SET DEBUG FILE TO '/informix/noe/sp_valida_dv_megacable.out';
			--TRACE ON;
	
    --VALIDA IMPORTE

        IF LENGTH(TRIM(pImporte)) = 0 OR NVL(TRIM(pImporte),'') = '' THEN

    --VALIDA LONGITUD DE REFERENCIA
                IF  LENGTH(TRIM(pNumRef)) <> 26 OR TRIM(pNumRef) = '' THEN
                    LET cCod_ret = '00002'; --ANTES 00001
                ELSE
    
    --VALIDA QUE LA REFERENCIA NO HAYA SIDO USADA ANTERIORMENTE
                    SELECT count(referencia1) into iSacMov 
                    FROM bdisac:"informix".sac_movimientos 
                    WHERE referencia1 = pNumRef
                    AND numcategoria='06' 
                    AND numconvenio='005' 
                    AND  status_cancelado = 'N' 
                    AND flag_confirmacion_central=1 
                    AND flag_confirmacion_sucursal=1;
    
                    SELECT count(referencia1) into iSacMovHis
                    FROM bdisac:"informix".sac_movimientoshistorial 
                    WHERE referencia1 = pNumRef
                    AND numcategoria='06' 
                    AND numconvenio='005' 
                    AND status_cancelado = 'N' 
                    AND flag_confirmacion_central=1 
                    AND flag_confirmacion_sucursal=1;

                    IF iSacMov >= 1 or iSacMovHis >= 1 THEN
    
                        LET cCod_ret ='00143';
                        
                    ELSE
    --VALIDA FECHA LIMITE DE PAGO
                        LET cDia = SUBSTR(pNumRef,13,2);
						LET cMes = SUBSTR(pNumRef,15,2);
						LET cAnio = SUBSTR(pNumRef,17,2);
						LET cAnio = CAST(cAnio AS INTEGER) + 2000;
						LET cFechaformat = MDY(TRIM(cMes),TRIM(cDia),TRIM(cAnio));

                        SELECT date(fecha_hoy) INTO vFecha_Hoy FROM bdisac:"informix".sac_fechas;

                        IF (vFecha_Hoy - cFechaformat) < 1 THEN

                           LET iLonNumRef = LENGTH(TRIM(cNumRef)) - 1;
                            
              --ALGORITMO PASO 1 (multiplica)
                            WHILE iLongCadRef <= iLonNumRef

                                IF (CAST(SUBSTR(cNumRef,iLongCadRef,1) AS INT) * iMult) < 10 THEN
              --ALGORITMO PASO 2 (Se suman los resultados (los nÃºmeros de 2 cifras se separan y se suman) )
                                    LET iSuma= (CAST(SUBSTR(cNumRef,iLongCadRef,1) AS INT) * iMult) + iSuma; 
                                ELSE 
                                    LET iPosCad = (CAST(SUBSTR(cNumRef,iLongCadRef,1) AS INT) * iMult);
                                    LET iSuma =  (((CAST(SUBSTR(iPosCad ,1,1) AS INT)) + (CAST(SUBSTR(iPosCad ,2,1) AS INT))) + iSuma ); 
                                END IF;

                                IF iMult = 2 THEN 
                                    let iMult = 1;       
                                ELIF iMult = 1  THEN 
                                    let iMult = 2;
                                END IF;  

                                LET iLongCadRef = iLongCadRef + 1;

                            END WHILE;

              --ALGORITMO PASO 3 (Se divide el resultado de la suma entre 10 y se obtiene el residuo)

                            LET iResiduo = MOD(iSuma,10);
              --ALGORITMO PASO 4 

                            IF iResiduo = 0 THEN
                            	--(Si el residuo es igual a cero el DV es cero.)
                                let iDigVer = iResiduo;
                            ELSE
                            	--(Si el residuo es diferente de cero, el DV es el resultado de restarle, a 10, el residuo)
                                let iDigVer = 10 - iResiduo;
                            END IF;

              --VALIDA DIGITO VERIFICADOR
                            IF SUBSTR(cNumRef,26,1)  <>  iDigVer THEN
                                Let cCod_ret = '00109'; --ANTES 00091
                            END IF; 
                        ELSE
                            LET cCod_ret ='00003'; --ANTES 00140 (FECHA DE VENCIMIENTO MENOR A HOY)
                        END IF;     
                    END IF;		
                END IF;
        ELSE

--VALIDA IMPORTE CAPTURADO
                LET cImporte = SUBSTR(cNumRef,19,7);

                IF CAST(TRIM(cImporte) as decimal(12,2)) <> CAST(TRIM(pImporte) as decimal(12,2)) THEN
                    LET cCod_ret = '00108';
                END IF;

        END IF;
        
        RETURN cCod_ret;
	END
END PROCEDURE

DOCUMENT
'AUTOR: Noe Medina R.',
'FOLIO: ',
'DESCRIPCION: Valida referencia de pago Megacable (digito verificador y monto a pagar)',
'FECHA: 13/09/2017',
'VERSION: 20170913.1304',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_valida_dv_megacable_cpl
(
	  pNumRef CHAR (26), pImporte CHAR (10)
)
	
RETURNING CHAR(5) AS codret;


DEFINE cCod_ret         CHAR(5);
DEFINE iSqlErr          INTEGER;
DEFINE cNumRef          Char(26);
DEFINE iSuma            int;
DEFINE iLonNumRef       int;
DEFINE iMult            int; 
DEFINE iSacMov          int; 
DEFINE iSacMovHis       int; 
DEFINE iLongCadRef      int;
DEFINE iResiduo         int;
DEFINE iDigVer          int;
DEFINE iPosCad          int;
DEFINE cImporte         CHAR(7);
--DEFINE vFechaRef        VARCHAR(8);
DEFINE vFecha_Hoy       DATE;
DEFINE cDia             CHAR(2);
DEFINE cMes             CHAR(2);
DEFINE cAnio            CHAR(4);
DEFINE cFechaformat	    DATE;
--DEFINE bandera INTEGER;

LET cCod_ret    ='00000';	--Iniciamos en exitoso cambiara de acuerdo a las validaciones agregadas.
LET iSqlErr     = 0;
LET cNumRef     = pNumRef;
LET iSuma       = 0;
LET iLonNumRef  = 0;
LET iSacMov     = 0;
LET iSacMovHis  = 0;
LET iMult       = 2;
LET iLongCadRef = 1;
LET iResiduo    = 0;
LET iDigVer     = 0;
LET iPosCad     = 0;
LET cImporte    ='';	
--LET vFechaRef ='';	
LET vFecha_Hoy  ='';	
LET cDia        = '';
LET cMes        = '';
LET cAnio       = '';
LET cFechaformat = '';
--LET bandera=0;


	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_ret = iSqlErr;
				RETURN cCod_ret;	
				--RETURN bandera;	
			END IF;
		END EXCEPTION;
		 
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
			--SET DEBUG FILE TO '/informix/noe/hservicios/megacable/sp_valida_dv_megacable_cpl.out';
			--TRACE ON;
	
    --VALIDA IMPORTE

        IF LENGTH(TRIM(pImporte)) = 0 OR NVL(TRIM(pImporte),'') = '' THEN
            LET cCod_ret = '00108';
        ELSE

              --VALIDA LONGITUD DE REFERENCIA
                IF  LENGTH(TRIM(pNumRef)) <> 26 OR TRIM(pNumRef) = '' THEN
                    LET cCod_ret = '00002'; --ANTES 00001
                ELSE
    
              --VALIDA QUE LA REFERENCIA NO HAYA SIDO USADA ANTERIORMENTE
                    SELECT count(referencia1) into iSacMov 
                    FROM bdisac:"informix".sac_movimientos 
                    WHERE referencia1 = pNumRef
                    AND numcategoria='06' 
                    AND numconvenio='005' 
                    AND  status_cancelado = 'N' 
                    AND flag_confirmacion_central=1 
                    AND flag_confirmacion_sucursal=1;
    
                    SELECT count(referencia1) into iSacMovHis
                    FROM bdisac:"informix".sac_movimientoshistorial 
                    WHERE referencia1 = pNumRef
                    AND numcategoria='06' 
                    AND numconvenio='005' 
                    AND status_cancelado = 'N' 
                    AND flag_confirmacion_central=1 
                    AND flag_confirmacion_sucursal=1;

                    IF iSacMov >= 1 or iSacMovHis >= 1 THEN
    
                        LET cCod_ret ='00143';
                        
                    ELSE
                    
              --VALIDA FECHA LIMITE DE PAGO
                        LET cDia = SUBSTR(pNumRef,13,2);
						LET cMes = SUBSTR(pNumRef,15,2);
						LET cAnio = SUBSTR(pNumRef,17,2);
						LET cAnio = CAST(cAnio AS INTEGER) + 2000;
						LET cFechaformat = MDY(TRIM(cMes),TRIM(cDia),TRIM(cAnio));

                        SELECT date(fecha_hoy) INTO vFecha_Hoy FROM bdisac:"informix".sac_fechas;

                        IF (vFecha_Hoy - cFechaformat) < 1 THEN

                           LET iLonNumRef = LENGTH(TRIM(cNumRef)) - 1;
                            
              --ALGORITMO PASO 1 (multiplica)
                            WHILE iLongCadRef <= iLonNumRef

                                IF (CAST(SUBSTR(cNumRef,iLongCadRef,1) AS INT) * iMult) < 10 THEN
              --ALGORITMO PASO 2 (Se suman los resultados (los nÃÂºmeros de 2 cifras se separan y se suman) )
                                    LET iSuma= (CAST(SUBSTR(cNumRef,iLongCadRef,1) AS INT) * iMult) + iSuma; 
                                ELSE 
                                    LET iPosCad = (CAST(SUBSTR(cNumRef,iLongCadRef,1) AS INT) * iMult);
                                    LET iSuma =  (((CAST(SUBSTR(iPosCad ,1,1) AS INT)) + (CAST(SUBSTR(iPosCad ,2,1) AS INT))) + iSuma ); 
                                END IF;

                                IF iMult = 2 THEN 
                                    let iMult = 1;       
                                ELIF iMult = 1  THEN 
                                    let iMult = 2;
                                END IF;  

                                LET iLongCadRef = iLongCadRef + 1;

                            END WHILE;

              --ALGORITMO PASO 3 (Se divide el resultado de la suma entre 10 y se obtiene el residuo)

                            LET iResiduo = MOD(iSuma,10);
              --ALGORITMO PASO 4 

                            IF iResiduo = 0 THEN
                            	--(Si el residuo es igual a cero el DV es cero.)
                                let iDigVer = iResiduo;
                            ELSE
                            	--(Si el residuo es diferente de cero, el DV es el resultado de restarle, a 10, el residuo)
                                let iDigVer = 10 - iResiduo;
                            END IF;

              --VALIDA DIGITO VERIFICADOR
                            IF SUBSTR(cNumRef,26,1)  <>  iDigVer THEN
                                Let cCod_ret = '00109'; --ANTES 00091
                            END IF; 
                        ELSE
                            LET cCod_ret ='00003'; --ANTES 00140 (FECHA DE VENCIMIENTO MENOR A HOY)
                        END IF;     
                    END IF;		
                END IF;

              --VALIDA IMPORTE CAPTURADO
                LET cImporte = SUBSTR(cNumRef,19,7);

                IF CAST(TRIM(cImporte) as decimal(12,2)) <> CAST(TRIM(pImporte) as decimal(12,2)) THEN
                    LET cCod_ret = '00108';
                END IF;

        END IF;
        
        RETURN cCod_ret;
	END
END PROCEDURE

DOCUMENT
'AUTOR: Noe Medina R.',
'FOLIO: ',
'DESCRIPCION: Valida referencia de pago Megacable (digito verificador y monto a pagar)',
'FECHA: 23/01/2020',
'VERSION: 20200117.1004',
'BD:Bdisac';

CREATE PROCEDURE "informix".sp_buscar_nac_migrante(pNumCertificado VARCHAR(20))
RETURNING CHAR(5),CHAR(3),CHAR(100);

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNacionalidad CHAR (3);
DEFINE cCiudad CHAR (100);

LET sql_err = 0;
LET cCodRet = "00001";
LET cNacionalidad = "0";
LET cCiudad = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN cCodRet, NVL(cNacionalidad,''), NVL(cCiudad,'');
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/TMP/sp_buscar_nac_migrante.out";
	--TRACE ON;

		IF NVL(pNumCertificado, '') <> '' THEN
			
			SELECT nacionalidad, ciudad INTO cNacionalidad,cCiudad FROM bdisac:"informix".sac_cardif_migrante
			WHERE num_certificado = pNumCertificado 
			AND estatus in(1,2)
            AND fecha_insert = ( SELECT MAX(fecha_insert) FROM bdisac:"informix".sac_cardif_migrante
                                WHERE num_certificado = pNumCertificado);

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				IF NVL(cNacionalidad, '') <> '' OR cNacionalidad IS NULL THEN
					LET cCodRet = "00002";
				END IF;
            ELSE
				LET cCodRet = "00000";
			END IF;

		ELSE
			LET cCodRet = "00002";
		END IF;
			
		RETURN cCodRet, NVL(cNacionalidad,''), NVL(cCiudad,'');

END;
END PROCEDURE
DOCUMENT
'Folio: 577',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdisac',
'Fecha: 2019-05-23',
'DescripciÃ³n: Se genera Procedimiento Almacenado para regresar la nacionalidad de los asegurados migrantes en la tabla sac_cardif_migrante para la asegurados en Cardiff',
'SolicitÃ³: Abraham Narvaez';

CREATE PROCEDURE "informix".sp_actualiza_estatus_cardif()

RETURNING
CHAR(5)	AS cCodRet;

DEFINE cCodRet	CHAR(5);
DEFINE iSqlErr  INTEGER; 
DEFINE iIsamErr INTEGER; 
DEFINE cInfoErr CHAR(10); 

DEFINE dFechaHoy DATE;
DEFINE dFechaAnt DATE;
DEFINE dFechaDes DATE;
DEFINE iDiasAnt  INTEGER;
DEFINE iDiasDes  INTEGER;

LET cCodRet = "00000";

--SET DEBUG FILE TO "/home/sysifx/MarcoR/bdisac/TraceBdisac/sp_actualiza_estatus_cardif.out";
--TRACE ON;	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr::CHAR(5);
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	ON EXCEPTION IN (-535)	
				COMMIT WORK;							
	END EXCEPTION WITH RESUME;
		
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	BEGIN WORK;	

	SELECT valor INTO iDiasAnt FROM sac_param WHERE cod_param = 128;
	SELECT valor INTO iDiasDes FROM sac_param WHERE cod_param = 129;

	--LET iDiasAnt = (SELECT valor FROM sac_param WHERE cod_param = 128);
	--LET iDiasDes = (SELECT valor FROM sac_param WHERE cod_param = 129);
	
	--Obtiene fechas para determinar el rango de seguros para actualizar.
	SELECT fecha_hoy - iDiasAnt, fecha_hoy + iDiasDes, fecha_hoy 
	INTO dFechaAnt, dFechaDes, dFechaHoy
	FROM bdisac:"informix".sac_fechas;
	
	--Actualiza estatus de apto para renovacion(2) a cancelado(4)
	UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 4
	WHERE estatus = 2 AND (fecha_vencimiento + iDiasDes) < dFechaHoy;
	
	--Actualiza estatus de activo(1) a apto para renovacion(2)
	UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 2
	WHERE estatus = 1 AND fecha_vencimiento BETWEEN dFechaAnt AND dFechaDes;
	
	--Actualiza estatus de activo(1) a cancelado (5) Cuado se detectan caracteristicas de operacion inconclusa
	UPDATE bdisac:"informix".sac_cardif_migrante SET estatus = 5, observ_siniestro = 'Cambio estatus 1 a 5 Operacion Inconclusa'
	WHERE estatus = 1
	AND folio_suc IS NULL
	AND num_certificado = ''
	AND num_poliza = '';
	
	COMMIT WORK;
	RETURN cCodRet;
	
END;
END PROCEDURE;