CREATE PROCEDURE "informix".sp_cnsif_pasesucursal2(cID_USUARIOC CHAR(8), cID_FUNCIONC CHAR(10), Num_Sucursal CHAR(4))
	RETURNING CHAR(5) AS Cod_Retorno,
		CHAR(3) AS Id_Plaza,
		CHAR(4) AS No_Sucursal,
		CHAR(40) AS Nom_Sucursal,
		CHAR(40) AS Gte_Sucursal,
		CHAR(14) AS Tel_Sucursal,
		CHAR(8) AS Estat_Suc,
		CHAR(2) AS Poliza_Suc;

	DEFINE cCodRet       CHAR(5);
	DEFINE iSql_err      INT;
	DEFINE Id_Plaza      CHAR(3);
	DEFINE No_Sucursal   CHAR(4);
	DEFINE Nom_Sucursal  CHAR(40);
	DEFINE Gte_Sucursal  CHAR(40);
	DEFINE Tel_Sucursal  CHAR(14);
	DEFINE Estat_Suc     CHAR(8);
	DEFINE fechadia      DATE;
	DEFINE Flag_abrio    INTEGER;
	DEFINE Flag_cerro    INTEGER;
	DEFINE cUsuario      CHAR(8);
	DEFINE Poliza_Suc    CHAR(2);
    DEFINE iCont         INT;
	
	LET cCodRet          = "00000";
	LET iSql_err         = 0;
	LET Id_Plaza         = '';
	LET No_Sucursal      = '0000';
	LET Nom_Sucursal     = '';
	LET Gte_Sucursal     = '';
	LET Tel_Sucursal     = '';
	LET Estat_Suc        = '';
	LET fechadia         = '01-01-1900';
	LET Flag_abrio       = 0;
	LET Flag_cerro       = 0;
	LET cUsuario         = '';
	LET Poliza_Suc       = '';
	LET iCont            = 0;
	
	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				LET cCodRet = iSql_err;
				RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
			END IF;
		END EXCEPTION;
		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,cID_FUNCIONC) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;

		--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_pasesucursal2.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT ps_idplaza,ps_no_sucursal,ps_nom_sucursal,ps_gte_sucursal,ps_tel_sucursal,ps_estat_suc,ps_poliza_suc
			INTO Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc
			FROM bdinteg:"informix".sw_detallemonitorps
			WHERE ps_usuario_insert = cID_USUARIOC
			ORDER BY ps_no_sucursal
			
			LET iCont = iCont + 1;
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc WITH RESUME;
		END FOREACH;
		
		IF NVL(iCont,0) = 0 THEN
			LET cCodRet = "00105";
			RETURN cCodRet, Id_Plaza, No_Sucursal, Nom_Sucursal, Gte_Sucursal, Tel_Sucursal, Estat_Suc, Poliza_Suc;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT  'AUTOR: L. Montserrat León Amador',
'FECHA: 24/10/2016',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: MONITOR DE PASES CONTABLES DE SUCURSALES', 
'DESCRIPCION: Consulta detalle de Sucursales de acuerdo a criterios (Numero de Sucursal).',
'Se realiza la clonación del spl original a la base bdicont para agregar la columna al grid con la consulta de las pólizas contables.',
'AUTOR: TASF',
'FECHA: 10/11/2016',
'DESCRIPCION: De acuerdo a indicaciones se realiza el cambio de variables al momento de realizar el cruce con la tabla co_poliza (cUsuario por No_Sucursal).',
'AUTOR: L. Montserrat León Amador',
'FECHA: 05/03/2018',
'DESCRIPCION: Se implementa el tratado de la información en segundo plano.',
'AUTOR: L. Montserrat Leon Amador',
'FECHA: 06/01/2020',
'DESCRIPCION: Se aplica optimización de querys.',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_valida_folio_sms_coppel(pEmpresa CHAR(3), pSucursal CHAR(4), pProducto CHAR(8),pNumCte CHAR(20), pEjecutivo CHAR(8))
RETURNING CHAR(6)        AS codigo_retorno,
		  INTEGER        AS flag_bton_sms,
          INTEGER        AS flag_dll,
          INTEGER        AS cont_rpte;

	DEFINE cCodRet		CHAR(6);
	DEFINE iSqlErr		INTEGER;
	DEFINE iSamErr		INTEGER;
	DEFINE cErrorInfo	VARCHAR(80,1);
	DEFINE iReqVal      INTEGER; 
	DEFINE iFlag        INTEGER;   
	DEFINE cTelefono    CHAR(13);
	DEFINE iFlagSMS    	INTEGER;
	DEFINE iContador	INTEGER;
	DEFINE iParamCont	INTEGER;
	DEFINE iTotTel		INTEGER;
	DEFINE iFlagDll		INTEGER;
	DEFINE iContRepte	INTEGER;
	DEFINE cVerificado    CHAR(1);
    DEFINE ccampocuatro INTEGER;
	DEFINE cGrupo  CHAR(1);
	DEFINE cNumSolic VARCHAR(20);
	DEFINE dEvaluacion DECIMAL(5,2);
	DEFINE iScorePropietario INTEGER;
	DEFINE sParamSMS    CHAR(1);
	DEFINE cProducto         CHAR(4);
	DEFINE cValSms           CHAR(1);

	LET cCodRet			= "000000";
	LET iSqlErr			= 0;
	LET iSamErr			= 0;
	LET cErrorInfo		= "";
	LET iReqVal         = 0;
	LET iFlag           = 0;
	LET cTelefono       = '';
	LET iFlagSMS       	= 0;
	LET iContador       = 0;
	LET iParamCont      = 0;
	LET iTotTel      	= 0;
	LET iFlagDll      	= 0;
	LET iContRepte      = 0;
	LET cVerificado       = '';
    LET ccampocuatro    = "";
	LET cGrupo          = "";
	LET cNumSolic  		= "";
	LET dEvaluacion 	= 0;
	LET iScorePropietario = 0;
	LET sParamSMS 		= "0";
	LET cProducto     ='0000';
	LET cValSms     = "";

	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
			IF iSqlErr != 0 THEN
				LET cCodRet = iSqlErr::CHAR(8);
				RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);
			END IF;
		END EXCEPTION; 	

		--SET DEBUG FILE TO "/tmp/sp_valida_folio_sms.out";
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;		
		
		--VALIDANDO EL PARAMETRO POR CONTINGENCIA -- ANJ
		  --SELECT valor INTO sParamSMS FROM bdinteg:si_param WHERE cod_param='469';
		  --IF sParamSMS = "1" THEN
			-- RETURN NVL(cCodRet,''),0,0,0;
		  --END IF;	
		--VALIDANDO EL PARAMETRO POR CONTINGENCIA -- ANJ		
		
		--RQI 23 496 
		SELECT num_producto, valida_sms
		INTO cProducto, cValSms
		FROM bdicred:sd_definicion 
		WHERE num_producto = pProducto;
			
		IF cProducto = '' or cProducto is null THEN			
			SELECT producto, valida_sms
			INTO cProducto, cValSms
			FROM bdicheq:sc_producto
			WHERE producto = pProducto;
		END IF;
			
		IF cValSms = 0 THEN
			RETURN NVL(cCodRet,''),0,0,0;
		END IF;		
		
		--Fin RQI 23 496		

		IF TRIM(NVL(pEmpresa,"")) = "" OR TRIM(NVL(pSucursal,"")) = "" OR TRIM(NVL(pProducto,"")) = ""  OR  TRIM(NVL(pNumCte,"")) = "" OR TRIM(NVL(pEjecutivo,"")) = "" THEN
			LET cCodRet  = "000001";
			RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);
		END IF;
				
		IF pProducto='6500' THEN
            SELECT nvl(b.campo_4,'0')
                INTO  ccampocuatro
        		FROM  bdisolic: ss_solicitudes a inner join 
            		  bdisolic: ss_nuevo_parametrico b 
                	  on a.num_solicitud=b.num_solicitud
                WHERE a.empresa=pEmpresa
            		and a.numcte=pNumCte
            		and a.sucursal=pSucursal
                    and a.num_producto = '6500'
                    and a.status_solicitud='AP';
            IF (ccampocuatro = "1") THEN
        			LET iFlagDll=0;
            	RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);	 
             END IF;
		End if;		

		SELECT LIMIT 1 1 
		INTO iReqVal
		FROM "informix".si_prod_sucursal_sms
		WHERE empresa = pEmpresa
		AND num_producto = pProducto
		AND sucursal = pSucursal;
		 
		IF NVL(iReqVal,0) = 0 THEN	

			SELECT count(telefono)
			INTO iTotTel
			FROM "informix".si_telefonos
			WHERE numcte = pNumCte
			AND status_tel = 'A'
			AND tipo_tel IN (1,2);
				
			IF NVL(iTotTel,0) = 1 THEN
				SELECT NVL(telefono ,'')
				INTO cTelefono
				FROM "informix".si_telefonos
				WHERE numcte = pNumCte AND tipo_tel = 1 
				AND status_tel = 'A' AND NVL(verificado,'F') = 'F';

				IF NVL(cTelefono,'') <> '' THEN
					LET iFlagDll = 1;

					SELECT NVL(cont_rpte,0) INTO iContRepte
					FROM "informix".si_bit_intentos_ivr
					WHERE numcte = pNumCte
					AND numtel = TRIM(cTelefono)
					AND empresa = pEmpresa;
				END IF;
			END IF;
			
			IF NVL(iFlagDll,0) = 0 THEN
			
			
			-- RQI 27 008 20/01/2016 Se agrega validación para relacionar la tabla si_telefonos donde el telefono haya sido verificado JMA
				SELECT LIMIT 1 a.telefono
				  INTO cTelefono
				  FROM "informix".si_telefonos_actual a
				  INNER JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
														   AND b.tipo_tel   = a.tipo_tel
														   AND b.status_tel = a.status_tel
														   AND b.telefono = a.telefono 
														   AND b.verificado = 'V')
				 WHERE a.numcte     = pNumCte
				   AND a.tipo_tel   = 1
				   AND a.status_tel = 'A';
				   
				   IF NVL(cTelefono,'') = '' THEN
						LET iFlag = 0;
				   ELSE		
						LET iFlag = 1;	   
				   END IF;
			
				IF iFlag = 0 THEN
					SELECT LIMIT 1 a.telefono, b.verificado 
					  INTO cTelefono,cVerificado 
					  FROM "informix".si_telefonos_actual a
					  LEFT JOIN  "informix".si_telefonos b on (b.numcte     = a.numcte 
														   AND b.tipo_tel   = a.tipo_tel
														   AND b.status_tel = a.status_tel
														   AND b.telefono = a.telefono 
														   )
					 WHERE a.numcte     = pNumCte
					   AND a.tipo_tel   = 2
					   AND a.status_tel = 'A';
					   
					   IF NVL(cTelefono,'') = '' or  cVerificado = 'V' THEN
							LET iFlag = 1;
					   END IF;
				END IF;	   
				IF iFlag = 0 THEN
						FOREACH 
							SELECT LIMIT 1 1
							   INTO iFlag
							   FROM "informix".si_bitsmstels b
							  WHERE b.numcte     = pNumCte
							   AND b.telefono   = cTelefono
							   AND b.bandera    = 't'
						  ORDER BY b.fecha DESC
						END FOREACH
				END IF;
				
				IF NVL(iReqVal,0) = 0 AND NVL(iFlag,0) = 0 THEN
					LET iFlagDll = 2;
				END IF;
			END IF;

			IF NVL(iFlagDll,0) = 2 THEN
				IF NVL(cTelefono,'') <> '' THEN
					
					SELECT NVL(valor,0)::integer INTO iParamCont
					FROM "informix".si_param
					WHERE cod_param = 404;
						
					SELECT NVL(cont_sms,0) INTO iContador
					FROM "informix".si_bit_intentos_ivr
					WHERE empresa = pEmpresa
					AND numcte = pNumCte
					AND numtel = TRIM(cTelefono);
					
					IF dbinfo("sqlca.sqlerrd2") = 0 THEN
						LET iContador = 0; --No se encontraron registros
					END IF;
					
					IF NVL(iContador,0) < NVL(iParamCont,0) THEN
						LET iFlagSMS = 1;
					END IF;
					
				ELSE
					LET iFlagSMS = 1;
				END IF;
			END IF;
		END IF;
		
		IF iFlagDll <> 0 THEN 
				IF pProducto = '6001' THEN
					SELECT b.grupo, a.num_solicitud
					  INTO cGrupo, cNumSolic
					  FROM bdisolic:"informix".ss_solicitudes a, bdisolic:"informix".ss_resum_scor_fin b
						WHERE a.empresa = b.empresa
						  AND a.num_solicitud = b.num_solicitud
						  and a.numcte = pNumCte
						  --and a.sucursal = pSucursal
						  and a.num_producto = '6001'
						  and a.status_solicitud = 'AT';
						  
						  IF NVL(cGrupo,'') IN ('1','2','A') THEN
						  
								SELECT valor 
								  INTO iScorePropietario 
								  FROM bdisolic:"informix".ss_param 
								 WHERE empresa = pEmpresa 
								   AND secuencia = 385;
							
							  SELECT evaluacion
								 INTO dEvaluacion
								 FROM bdisolic:"informix".ss_resumen_scoring 
								WHERE empresa = pEmpresa
								  and num_solicitud = cNumSolic
								  and seccion = 2;						  
								  
								  IF NVL(dEvaluacion,0) >= iScorePropietario THEN
									  UPDATE bdisolic:"informix".ss_revision_determinacion
										 SET excluye_validacion = 1
									   WHERE empresa = pEmpresa
										 AND num_solicitud = cNumSolic;
										 
										 LET iFlagDll=0;
										 RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);	 													  
								  END IF;
						  END IF;		
				END IF;
		END IF;	
		
		RETURN NVL(cCodRet,''),NVL(iFlagSMS,0),NVL(iFlagDll,0),NVL(iContRepte,0);

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Procedimiento para revisar si el folio sms ya fue validado',
'FECHA: 12/NOV/2015',
'BD: bdinteg',
'AUTOR: PAUL IVAN QUINTERO VARELA',
'MODIFICACION: Se agrega bandera para saber si el reenvio del sms ya alcanzo el limite permitido',
'FECHA: 29/DIC/2015',
'AUTOR: ERNESTO AGUILERA';

CREATE PROCEDURE  "informix".cons_tarjetas_cte_web(pempresa     CHAR(3),
                                              pnumcte      CHAR(20),
                                              pregistros   SMALLINT)

RETURNING CHAR(5),       -- Codigo de Retorno
          CHAR(20),      -- Nro de Cliente
          CHAR(26),      -- Nombre1
	      CHAR(26),      -- Nombre2
	      CHAR(26),      -- Apellido Paterno
          CHAR(26),      -- Apellido Materno
          DATE,  	     -- Fecha Nacimiento
	      CHAR(13),      -- RFC
	      CHAR(20),      -- CUENTA
	      CHAR(20),      -- TARJETA
	      CHAR(1),       -- STATUS APLICATIVO
	      SMALLINT,      -- SISTEMA
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR (3);      -- STATUS DE INTERCARD

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE s_numcte        CHAR(20);
DEFINE s_nombre1       CHAR(26);
DEFINE s_nombre2       CHAR(26);
DEFINE s_paterno       CHAR(26);
DEFINE s_materno       CHAR(26);
DEFINE s_fechanac      DATE;
DEFINE s_rfc           CHAR(13);
DEFINE s_cuenta        CHAR(20);
DEFINE s_tarjeta       CHAR(20);
DEFINE v_cuantos       SMALLINT;
DEFINE s_status        CHAR(1);
DEFINE s_sistema       SMALLINT;
DEFINE s_status_cta    CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE s_rfc_alterno   CHAR(13);
DEFINE cProdTransfer   CHAR(4);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
SET OPTIMIZATION HIGH;
SET OPTIMIZATION ALL_ROWS;
LET scod_ret      = "00000";
LET vsqlerr       = 0;
LET v_cuantos     = 0;
LET s_numcte      = "";
LET s_nombre1	= "";
LET s_nombre2	= "";
LET s_paterno	= "";
LET s_materno	= "";
LET s_fechanac	= "";
LET s_rfc	      = "";
LET s_cuenta	= "";
LET s_tarjeta	= "";
LET s_status      = "";
LET s_sistema     = 0;
LET s_status_cta  = "";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta = "";
LET s_rfc_alterno = "";
LET cProdTransfer	= "";
--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO dirty READ;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/integral/cons_tarjetas_cte.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   LET pempresa = pempresa;
   LET pnumcte = pnumcte;


  -- Valida Parametros de Entrada

  IF pempresa = "" or
     pnumcte = ""  then
     LET scod_ret = "00110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta;
  END IF


	SELECT valor 
	INTO cProdTransfer
	FROM bditransfer:"informix".tf_param 
	WHERE empresa = pempresa 
	AND	cod_param = 4;

  -- Extrae las Tarjeta de Cheques
	-- Se agrega la validaciÃ³n a la sc_firmantes para solo buscar tarjetas autorizadas
	-- CGP 10032015
  FOREACH
     SELECT a.cuenta, a.num_tarjeta, a.numcte, a.status_tar, e.producto || " " || e.nombre,f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno  
       INTO s_cuenta, s_tarjeta, s_numcte,s_status, s_producto, s_divisa,
            s_nombre1,s_nombre2,s_paterno,s_materno,s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicheq:"informix".sc_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicheq:"informix".sc_maechq d,
            bdicheq:"informix".sc_producto e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar,
			bdicheq:"informix".sc_firmantes as firm
      WHERE a.empresa = b.empresa
            AND a.numcte = b.numcte
            AND a.empresa = c.empresa
            AND a.numcte = c.numcte
            AND a.empresa = d.empresa
            AND a.cuenta = d.cuenta
            AND e.empresa = a.empresa
            AND e.producto = a.prodtarjeta
            AND f.empresa = a.empresa
            AND f.divisa = e.divisa
			and (firm.cuenta = a.cuenta)
			and (firm.numcte = a.numcte)
            AND (a.num_tarjeta = tar.numtarjeta)

            AND ((a.empresa=pempresa)
--            AND (a.tipo_tarjeta='T')
            AND (d.status_cta = "1")
            AND (a.numcte=pnumcte))
			AND a.prodtarjeta <> cProdTransfer  order by a.num_tarjeta

     LET s_sistema = 1;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF;

	 IF s_rfc_alterno is not null and s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

  -- Extrae las Tarjeta de Credito
  FOREACH
SELECT a.num_credito, a.num_tarjeta, a.numcte, a.status_tar,  e.num_producto || " " || e.nombre_prod, f.divisa || " " || f.descripcion,
            b.nombre1, b.nombre2, b.apell_paterno, b.apell_materno, b.rfc,
            c.fecha_nac, tar.codstatustarjeta, b.rfc_alterno 
       INTO s_cuenta,  s_tarjeta, s_numcte,  s_status, s_producto, s_divisa,
            s_nombre1, s_nombre2, s_paterno, s_materno, s_rfc,
            s_fechanac, s_codstatustarjeta, s_rfc_alterno
       FROM bdicred:"informix".sd_maecred d,
            bdicred:"informix".sd_tarjeta a,
            bdinteg:"informix".si_cliente b,
            bdinteg:"informix".si_ctepf c,
            bdicred:"informix".sd_definicion e,
            bdinteg:"informix".si_divisas f,
            intercard:"informix".tarjeta tar
      WHERE d.numcte=pnumcte
            and d.numcte = b.numcte
            AND d.numcte = c.numcte
            and a.empresa = d.empresa
            and a.num_credito = d.num_credito  
            AND e.empresa = d.empresa
            AND e.num_producto = d.num_producto
            and f.empresa=pempresa
            AND f.divisa = d.divisa
            AND a.num_tarjeta = tar.numtarjeta
            AND d.status_cred <> "FF"
	ORDER BY a.num_tarjeta    

     LET s_sistema = 6;

     LET v_cuantos = v_cuantos + 1;
     IF v_cuantos <= pregistros THEN
        CONTINUE FOREACH;
     END IF

	 IF s_rfc_alterno is not null or s_rfc_alterno <> "" THEN
        LET s_rfc = s_rfc_alterno;
     END IF;	
	 
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_sistema,s_producto,s_divisa,s_codstatustarjeta
            WITH RESUME;


  END FOREACH

END

END PROCEDURE

DOCUMENT
"Especificacion: Se modifico para que consulte el status de la",
"                tarjeta en la tabla intercard:tarjeta y se regrese como retorno",
"Base de Datos : bdinteg",
"AUTOR : Jesus Manuel Perea Heredia",
"FECHA : 19/Nov/2010",
"Descripcion: Se actualiza a la nueva version de reglas.", 
"Base de Datos : bdinteg",
"Autor : Marcos Cuevas",
"Fecha : 16/Febrero/2011",
'',
'FOLIO: 1611',
'FECHA : 26/06/2014',
'MODIFICO : 94972834',
'MODIFICACION: se modifica para excluir las tarjetas que pertenecen a un producto transfer',
'SUSTENTO: modificaciones_promotoria.pdf',
'SOLICITA: Rodolfo Gomez',
'BD: bdinteg',
--------------REINGENIERIA-----------
'Descripcion: Se genera un clon del sp "sp_clona_tdc_upgrade" para que este tenga un cod ret de 5 caracteres',
'AUTOR : Efrain MIranda Miranda',
'FECHA : 15/08/2019',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_valida_sms_cte_web( pNumCte CHAR(9))
 RETURNING CHAR(5) as CodRet ,
		   SMALLINT  as valido,
		   CHAR(13) as telefono;

DEFINE cCodret   CHAR(5);
DEFINE iSql_err  INTEGER;
DEFINE iValido   INTEGER;
DEFINE cTel      CHAR(13);

LET cCodret     = '00000';
LET iSql_err    = 0;
LET iValido     = 0;
LET cTel        = '';

BEGIN
	ON EXCEPTION SET iSql_err
		--LET cCodret = CAST(iSql_err AS CHAR);
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			RETURN cCodret,iValido,cTel;
		END IF;
	END EXCEPTION;	
	
	--SET DEBUG FILE TO '/informix/jesus/sp_valida_sms_cte.sql';
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    
	IF (SELECT COUNT(b.numcte)
		FROM bdinteg:"informix".si_telefonos_actual a
		LEFT JOIN bdinteg:"informix".si_bitsmstels b ON a.numcte=b.numcte AND a.telefono=b.telefono AND  b.bandera='t' AND  b.fecha::DATE = TODAY		
		WHERE a.numcte=pNumCte
		AND a.tipo_tel=2 AND a.status_tel='A'
		and fecha = (SELECT max(fecha) from bdinteg:"informix".si_bitsmstels c 
                        where c.numcte=a.numcte AND a.telefono=a.telefono 
                        AND  c.fecha::DATE = TODAY)
		) 
 > 0 THEN		
			LET iValido =1;
		
	END IF 
    
    SELECT  LIMIT 1 telefono
    INTO cTel
    FROM bdinteg:"informix".si_telefonos_actual a
    WHERE a.numcte=pNumCte
    AND a.tipo_tel=2 AND a.status_tel='A';
		
	RETURN cCodret,iValido, cTel;

END;
END PROCEDURE
DOCUMENT
'Autor:	JESUS MANUEL AGUILAR HEREDIA',
'FECHA:	30/SEP/2016',
'DESCRIPCION: se crea procedimiento para ser usado en el flujo de 2 credito.',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_valida_confirmacion_movil_web(pNumCte CHAR(9), pUsuario CHAR(8),pTelefono CHAR(10))
RETURNING CHAR(5) As cCodRet;

--Definicion de Variables 
DEFINE cCodRet			CHAR (5);
DEFINE cBandera         BOOLEAN;
DEFINE iSqlErr          INTEGER;
--Inicializacion de Variables

LET cCodRet      = '00000';
LET cBandera     = 'F';
LET iSqlErr      = 0;

BEGIN	
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			let cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/respaldosbd/Braulio/sp_valida_confirmacion_movil.out";
	--TRACE ON; 
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(pNumCte,'') <> '' AND NVL(pUsuario,'') <> '' AND NVL(pTelefono,'') <> '' THEN

			SELECT bandera 
			INTO cBandera
			FROM bdinteg:"informix".si_bitsmstels
			WHERE numcte = pNumCte 
			AND telefono = pTelefono 
			AND ejecutivo = pUsuario
			AND fecha IN (SELECT MAX(FECHA) FROM bdinteg:"informix".si_bitsmstels 
						  WHERE numcte = pNumCte
						  AND telefono = pTelefono
						  AND ejecutivo = pUsuario);

			IF dbinfo ("sqlca.sqlerrd2") = 0 then-- No hay informacion
				LET cCodRet = '01289';
				RETURN cCodRet;
			END IF;

			IF cBandera = 'F' THEN
				LET cCodRet = '01386';
			ELIF cBandera = 'T' THEN
				LET cCodRet = '00000';
			END IF;
	ELSE
		LET cCodRet = '00001';
	END IF; 

RETURN cCodRet;
END;
END PROCEDURE;