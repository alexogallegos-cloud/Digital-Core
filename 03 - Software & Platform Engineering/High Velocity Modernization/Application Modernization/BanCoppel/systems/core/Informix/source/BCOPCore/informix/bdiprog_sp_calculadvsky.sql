CREATE PROCEDURE  "informix".sp_calculadvsky(pNumReferencia CHAR(12))
RETURNING 
	CHAR (5) AS CodigoRetorno,	
	SMALLINT AS sDigVerCalculado;
	
--DEFINICION DE LAS VARIABLES


DEFINE iSqlerr			INTEGER;
DEFINE sI				SMALLINT;
DEFINE sNoPeso			SMALLINT;
DEFINE sSuma			SMALLINT;
DEFINE sValorDigito		SMALLINT;
DEFINE sAux				SMALLINT;
DEFINE cCodRet			CHAR(5);
DEFINE sFlagLetra		SMALLINT; 
DEFINE cNum1			CHAR(2);
DEFINE cNum2			CHAR(2);
DEFINE sDigVerCapturado SMALLINT;
DEFINE sDigVerCalculado SMALLINT;
DEFINE sIerrcomCodigo   SMALLINT;
DEFINE sIerrcomSistema  SMALLINT;


--INICIALIZACION DE LAS VARIABLES
LET iSqlerr 			= 0;
LET sI 					= 0;
LET sNoPeso 			= 0;
LET sSuma 				= 0;
LET sValorDigito 		= 0;
LET sAux 				= 0;
LET cCodRet 			= '004';
LET sFlagLetra 			= 0;
LET cNum1 				= '';	
LET cNum2 				= '';
LET sDigVerCalculado 	= 0;
LET sDigVerCapturado 	= 0;
LET sIerrcomCodigo  	= 0;
LET sIerrcomSistema 	= 0;

		
BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet, sDigVerCalculado;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/antoniocebreros/1483/migrado/sp_calculadvsky.out';
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF LENGTH(TRIM(pNumReferencia))= 12 THEN	

		LET sDigVerCapturado = SUBSTR(pNumReferencia,12,1)::SMALLINT;
          
	    FOR sI = 1 TO 11
	   --FOR i IN 1..11 LOOP
	       IF MOD(sI,2)= 0 THEN
	          LET sNoPeso = 1;
	       ELSE
			  LET sNoPeso = 2;
	       END IF;
		  

                IF (ASCII(UPPER (SUBSTR(pNumReferencia,sI,1)) ) > 64 AND ASCII(UPPER (SUBSTR(pNumReferencia,sI,1)) ) < 91) OR ASCII(SUBSTR(pNumReferencia,sI,1) ) = 241 OR ASCII(SUBSTR(pNumReferencia,sI,1) ) = 209 THEN
					
					IF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'A' THEN
						LET sValorDigito = 1;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'B' THEN
						LET sValorDigito = 2;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'C' THEN
						LET sValorDigito = 3;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'D' THEN
						LET sValorDigito = 4;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'E' THEN
						LET sValorDigito = 5;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'F' THEN
						LET sValorDigito = 6;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'H' THEN
						LET sValorDigito = 7;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'I' THEN
						LET sValorDigito = 8;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'J' THEN
						LET sValorDigito = 9;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'K' THEN
						LET sValorDigito = 1;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'L' THEN
						LET sValorDigito = 2;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'M' THEN
						LET sValorDigito = 3;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'N' THEN
						LET sValorDigito = 4;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'O' THEN
						LET sValorDigito = 5;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'P' THEN
						LET sValorDigito = 6;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'Q' THEN
						LET sValorDigito = 7;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'R' THEN
						LET sValorDigito = 8;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'S' THEN
						LET sValorDigito = 9;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'T' THEN
						LET sValorDigito = 1;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'U' THEN
						LET sValorDigito = 2;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'V' THEN
						LET sValorDigito = 3;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'W' THEN
						LET sValorDigito = 4;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'X' THEN
						LET sValorDigito = 5;
					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'Y' THEN

						LET sValorDigito = 6;

					ELIF UPPER(SUBSTR(pNumReferencia,sI,1)) = 'Z' THEN
						LET sValorDigito = 7;
					ELSE 
						LET sValorDigito = 1;
					END IF;
					
					
                  
                  IF sValorDigito IS NULL THEN
                    LET sFlagLetra = 1;
                    EXIT;
                  END IF;
                ELIF ASCII(SUBSTR(pNumReferencia,sI,1)) > 47 AND ASCII(SUBSTR(pNumReferencia,sI,1)) < 58 THEN
                   LET sValorDigito = SUBSTR(pNumReferencia,sI,1)::SMALLINT;
                END IF;

			LET sAux = sValorDigito * sNoPeso;
               
	       IF sAux > 9 THEN
	          --raise notice ''Multiplicacion Mayor a 9 = %'', sAux ;
	          LET cNum1 = SUBSTR(sAux::CHAR(2),1,1) ;
	          LET cNum2 = SUBSTR(sAux::CHAR(2),2,1) ;
	          LET sAux = cNum1::SMALLINT + cNum2::SMALLINT;
	       END IF; 

           --LET cReferenciaSky[sI] = sAux::CHAR;
	       LET sSuma = sSuma + sAux;
	       --raise notice ''Valor #%'', i || ''='' || cReferenciaSky[i] ; 
		END FOR;
	   --END LOOP;

           --raise notice ''Suma =%'', sSuma; 
        IF sFlagLetra = 0 THEN
			  IF SUBSTR(sSuma::CHAR(10),2,1)=1 THEN
				 LET sDigVerCalculado = 9;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=2 THEN
				  LET sDigVerCalculado = 8;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=3 THEN
				  LET sDigVerCalculado = 7;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=4 THEN
				  LET sDigVerCalculado = 6;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=5 THEN
				  LET sDigVerCalculado = 5;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=6 THEN
				  LET sDigVerCalculado = 4;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=7 THEN
				  LET sDigVerCalculado = 3;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=8 THEN
				  LET sDigVerCalculado = 2;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=9 THEN
				  LET sDigVerCalculado = 1;
			  ELIF SUBSTR(sSuma::CHAR(10),2,1)=0 THEN
				  LET sDigVerCalculado = 0;
			  END IF; 

			  IF sDigVerCapturado = sDigVerCalculado THEN
				 LET cCodRet = '000';  
			  ELSE
				 LET cCodRet = '001';
				 
			  END IF; 

        ELIF sFlagLetra = 1 THEN
              LET  cCodRet = '003'; --ESCENARIO: LA REFERENCIA DE CAPTURA NO ES VALIDA.
			  
        END IF;
    ELSE
            --raise notice ''Referencia no es de 12 digitos''; 
			--ESCENARIO: LONGITUD DE REFERENCIA INCORRECTA.
            LET cCodRet = '002';
			
    END IF;
	--END IF;
	
	--IF cCodRet = '004' THEN
	--	LET cCodRet = '000';
	--END IF;
	
    RETURN cCodRet,sDigVerCalculado;

END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se convierte una funcion de sucursal a una rutina de central, atendiendo el folio 1483-MttoValRefPagServAVON, (procedimiento en central para validar el digito verificador para pago de servicios SKY)',
'MODIFICO: Antonio Cebreros Perez',
'FECHA: 24/02/2015',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_consulctafrecuentes_manco_bei(pIdOperacion INTEGER)
	RETURNING CHAR(5), CHAR(20), CHAR(20), MONEY(14,2), CHAR(40), CHAR(40),
	CHAR(100), INTEGER, INTEGER, CHAR(3), CHAR(4), CHAR(4), INTEGER,
	CHAR(40), CHAR(18), CHAR(40), CHAR(100), CHAR(2),
	CHAR(3), CHAR(20), CHAR(20), CHAR(17), CHAR(1), CHAR(9),CHAR(2);

DEFINE sql_err 						INTEGER;
DEFINE cCod_ret 					CHAR(5);
DEFINE vcuenta_origen 				CHAR(20);
DEFINE vcuenta_destino 				CHAR(20);
DEFINE vimporte 					MONEY(14, 2);
DEFINE vreferencia 					CHAR(40);
DEFINE vreferenciabe 				CHAR(40);
DEFINE vnombre_beneficiario 		CHAR(100);
DEFINE vid_usuario 					INTEGER;
DEFINE vid_cat_operacion 			INTEGER;
DEFINE vempresa 					CHAR(3);
DEFINE vsucursal_virtual 			CHAR(4);
DEFINE vusuario_virtual 			CHAR(4);
DEFINE vclave_banco 				INTEGER;
DEFINE vnombre_usuario 				CHAR(40);
DEFINE vrfc 						CHAR(18);
DEFINE vtipo_cuenta_beneficiario 	CHAR(40);
DEFINE vbanco_receptor 				CHAR(100);
DEFINE vcategoria 					CHAR(2);
DEFINE vconvenio 					CHAR(3);
DEFINE vreftelefono 				CHAR(20);
DEFINE vrefverificador 				CHAR(20);
DEFINE vnombre_archivo 				CHAR(17);
DEFINE vstatusoperacion 			CHAR(1);
DEFINE vid_cliente 					CHAR(9);
DEFINE vCveCta                      CHAR(2);

LET cCod_ret 					= '00000';
LET vcuenta_origen 				= '';
LET vcuenta_destino 			= '';
LET vimporte 					= 0;
LET vreferencia 				= '';
LET vreferenciabe 				= '';
LET vnombre_beneficiario 		= '';
LET vid_usuario 				= 0;
LET vid_cat_operacion 			= 0;
LET vempresa 					= '';
LET vsucursal_virtual 			= '';
LET vusuario_virtual 			= '';
LET vclave_banco 				= 0;
LET vnombre_usuario 			= '';
LET vrfc 						= '';
LET vtipo_cuenta_beneficiario 	= '';
LET vbanco_receptor 			= '';
LET vcategoria 					= '';
LET vconvenio 					= '';
LET vreftelefono 				= '';
LET vrefverificador 			= '';
LET vnombre_archivo 			= '';
LET vstatusoperacion 			= '';
LET vid_cliente 				= '';
LET vCveCta                     = '';

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCod_ret = sql_err;
			
			RETURN cCod_ret, vcuenta_origen, vcuenta_destino, vimporte,
				vreferencia, vreferenciabe, vnombre_beneficiario, vid_usuario,
				vid_cat_operacion, vempresa, vsucursal_virtual, vusuario_virtual,
				vclave_banco, vnombre_usuario, vrfc, vtipo_cuenta_beneficiario,
				vbanco_receptor, vcategoria, vconvenio, vreftelefono,
				vrefverificador, vnombre_archivo, vstatusoperacion, vid_cliente,vCveCta;
		END IF;
	END EXCEPTION;
	
	SELECT cuenta_origen, cuenta_destino, importe, referencia, referenciabe,
		nombre_beneficiario, id_usuario, id_cat_operacion, empresa,
		sucursal_virtual, usuario_virtual, clave_banco, nombre_usuario, rfc,
		tipo_cuenta_beneficiario, banco_receptor, categoria, convenio,
        reftelefono, refverificador, numtransferenciacargo, statusoperacion, id_cliente, moneda
	INTO vcuenta_origen, vcuenta_destino, vimporte, vreferencia, vreferenciabe,
		vnombre_beneficiario, vid_usuario, vid_cat_operacion, vempresa,
		vsucursal_virtual, vusuario_virtual, vclave_banco, vnombre_usuario,
        vrfc, vtipo_cuenta_beneficiario, vbanco_receptor, vcategoria, vconvenio,
		vreftelefono, vrefverificador, vnombre_archivo, vstatusoperacion,
        vid_cliente, vCveCta
	FROM bei_operacionesmancomunadasoperador
	WHERE ID_OPERACION = pIdOperacion;

	RETURN NVL(cCod_ret, ''), NVL(vcuenta_origen, ''), NVL(vcuenta_destino, ''),
		NVL(vimporte, 0.0), NVL(vreferencia, ''), NVL(vreferenciabe, ''),
		NVL(vnombre_beneficiario, ''), NVL(vid_usuario, 0),
		NVL(vid_cat_operacion, 0), NVL(vempresa, ''), NVL(vsucursal_virtual, ''),
		NVL(vusuario_virtual, ''), NVL(vclave_banco, 0), NVL(vnombre_usuario, ''),
		NVL(vrfc, ''), NVL(vtipo_cuenta_beneficiario, ''), NVL(vbanco_receptor, ''),
        NVL(vcategoria, ''), NVL(vconvenio, ''), NVL(vreftelefono, ''),
		NVL(vrefverificador, ''), NVL(vnombre_archivo, ''),
        NVL(vstatusoperacion, ''), NVL(vid_cliente, ''),NVL(vCveCta,'');
	END
END PROCEDURE;