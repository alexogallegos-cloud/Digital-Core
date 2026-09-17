CREATE PROCEDURE "informix".sp_grababitacoraact(cTipoConsulta CHAR(1), 
												cEmpresa CHAR(3), 
												cNumTarjeta CHAR(20), 
												cSucursal CHAR(4), 
												cNumGerente CHAR(8), 
												cNumEmpleado CHAR(8), 
												dFecha DATE, 
												cTipoAsignacion CHAR(1))

RETURNING CHAR(5) AS CodRetorno;

--Definicion de Variables
DEFINE iSqlErr  INTEGER;
DEFINE cCodRet  CHAR(5);
DEFINE cTarjeta CHAR(20);

DEFINE cBinTar  CHAR(10);
DEFINE cCredDev CHAR(5);
DEFINE cNumCte  CHAR(20);
DEFINE cCorreoCli CHAR(100);
DEFINE cCodRetSp1 CHAR(5);
DEFINE cCodRetSp2 CHAR(5);
DEFINE cCelularCli CHAR(13);
DEFINE cNumCred CHAR(20);
DEFINE iNumProd INTEGER;
DEFINE cDescProd CHAR(70);
--Inicializacion de Variables
LET iSqlErr = 0;
LET cCodRet = '00000';
LET	cTarjeta = '';

LET cCredDev = '';
LET cNumCte ='';
LET cCorreoCli = '';
LET cCodRetSp1 = '00000';
LET cCodRetSp2 = '00000';
LET cCelularCli ='';
LET cNumCred    ='';
LET iNumProd    =0;
LET cDescProd   ='';

--SET DEBUG FILE TO '/home/e95451706/bdicred/sp_grababitacoraact_prueba_coppelpay.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		SET DEBUG FILE TO "/RESPALDOSNEW/excep_sp_grababitacora.err.out" WITH APPEND;
		TRACE ON;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF NVL(cEmpresa,'') = '' OR NVL(cNumTarjeta,'') = '' OR NVL(cSucursal,'') = '' OR 
	NVL(cNumEmpleado,'') = '' OR NVL(dFecha,'') = '' OR NVL(cTipoAsignacion,'') = '' THEN
		LET cCodRet = '00479';
	ELSE
		IF cTipoConsulta = '1' THEN
			INSERT INTO bdicred:"informix".bitacora_activacion (empresa,numtarjeta,suc_asigna,no_gerente_asigna,no_empleado_asigna,fecha_asigna,tipo_asignacion) 
			VALUES (cEmpresa,cNumTarjeta,cSucursal,cNumGerente,cNumEmpleado,current,cTipoAsignacion);
			
			LET cBinTar = SUBSTR(cNumTarjeta,1,6);  --Obtiene el bin de la tarjeta
				
				SELECT creditodebito INTO cCredDev 
				FROM intercard:"informix".bines 
				WHERE bin=cBinTar;
				
				IF (cCredDev = 'C') THEN
				
				---Inicio TDC PAY
				IF 	cBinTar = '514014'	THEN
				
					SELECT {AVOID FULL(intercard:"informix".tarjeta)} numcliente
					INTO cNumCte
					FROM intercard:"informix".tarjeta 
					WHERE numtarjeta = cNumTarjeta;	
					
				ELSE
			---Fin TDC PAY
			
					SELECT numcte,num_credito INTO cNumCte,cNumCred
					FROM bdicred:"informix".sd_tarjeta --Obtiene el numero del cliente
					WHERE num_tarjeta=cNumTarjeta;
			
				END IF; --TDC PAY
					
					SELECT LIMIT 1 correo_elec --Obtiene el correo que del cliente
					INTO cCorreoCli 
					FROM bdinteg:"informix".si_correos 
					WHERE numcte=cNumCte AND tipo_correo=1 AND status_correo='A'; 
				
				---Inicio TDC PAY	
				IF 	cBinTar = '514014'	THEN --TDC PAY
					LET iNumProd = '6500';
				ELSE
				---Fin TDC PAY
				
					SELECT LIMIT 1 num_producto INTO iNumProd 
					FROM bdisolic:"informix".ss_solicitudes 
					WHERE num_solicitud=cNumCred AND numcte=cNumCte; --Obtiene el numero del producto
				
				END IF; --TDC PAY
					
					SELECT LIMIT 1 descrip_prod INTO cDescProd 
					FROM  bdicred:"informix".sd_tipprod  --Obtiene el la descripcion del producto
					WHERE abrevia_prod=iNumProd;

					IF NVL(cCorreoCli,'') <> '' THEN
					
						/*SELECT 'TARJETA '||descproducto  FROM intercard:productotarjeta a, intercard:tarjeta b WHERE 
						a.codproductotarjeta= b.codproductotarjeta and b.numtarjeta='4169160333597202'
						*/
						EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','MAIL_ACTTC',TRIM(cNumCte),'','','1','APERTURA','',
						'','',TRIM(cDescProd),'','','','','',TRIM(cCorreoCli),'',1,0,0,0,0,'','')INTO cCodRetSp1;
					
					ELSE
						SELECT LIMIT 1 telefono  --Obtiene el numero de celular del cliente
						INTO cCelularCli 
						FROM bdinteg:"informix".si_telefonos_actual 
						WHERE numcte = cNumCte	AND tipo_tel='2' AND status_tel='A'; 
			
						IF NVL(cCelularCli,'') <> '' THEN

							EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_ACTTC',TRIM(cNumCte),'','','1','APERTURA','','','',TRIM(cDescProd),'','','','','',
							'',TRIM(cCelularCli),1,0,0,0,0,'','')INTO cCodRetSp2; -------- NOTIFICACION DE CUALQUIER PRODUCTO O SERVICIO (SMS)
		
						END IF;
					END IF;
				END IF;
				
		ELIF cTipoConsulta = '2' THEN
			SELECT numtarjeta INTO cTarjeta 
			FROM bdicred:"informix".bitacora_activacion 
			WHERE empresa = cEmpresa AND numtarjeta = cNumTarjeta
            AND fecha_asigna in (select max(fecha_asigna) from bitacora_activacion where numtarjeta = cNumTarjeta);

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00481';
			ELSE
				UPDATE bitacora_activacion 
				SET suc_activa = cSucursal, no_gerente_activa = cNumGerente, no_empleado_activa = cNumEmpleado, fecha_activa = current 
				WHERE empresa = cEmpresa AND numtarjeta = cNumTarjeta
                AND fecha_asigna in (select max(fecha_asigna) from bitacora_activacion where numtarjeta = cNumTarjeta);
			END IF;
		
		ELIF cTipoConsulta = '3' THEN
			SELECT numtarjeta INTO cTarjeta 
			FROM bdicred:"informix".bitacora_activacion 
			WHERE empresa = cEmpresa AND numtarjeta = cNumTarjeta
            AND fecha_asigna in (select max(fecha_asigna) from bitacora_activacion where numtarjeta = cNumTarjeta);

			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00481';
			ELSE
				UPDATE bitacora_activacion 
				SET tipo_asignacion = cTipoAsignacion, suc_activa = cSucursal, no_gerente_activa = cNumGerente, no_empleado_activa = cNumEmpleado, fecha_activa = current 
				WHERE empresa = cEmpresa AND numtarjeta = cNumTarjeta
                AND fecha_asigna in (select max(fecha_asigna) from bitacora_activacion where numtarjeta = cNumTarjeta);
			END IF;
		ELSE
			LET cCodRet = '00480';
		END IF;
	END IF;
	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado: Para grabar una bitacora de la Activación',
'de las Tarjetas de Credito Bancoppel en Ventanilla.',
'AUTOR: Martín Eduardo Miranda Miranda',
'FECHA: 11/04/2012',
'VERSION: 1.0',
'BD: bdicred';

CREATE PROCEDURE "informix".cons_cta_o_tar_per(pempresa     CHAR(3),
			    		                   psistema     SMALLINT,
										   ptipoctatar  CHAR(1),
					                       pctatar      CHAR(20),
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
		  CHAR(1),       -- STATUS APLICATIVOS
          CHAR(50),      -- PRODUCTO
          CHAR(50),      -- DIVISA
          CHAR(3);       --STATUS INTERCARD


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
DEFINE s_status_cta	   CHAR(1);
DEFINE s_producto      CHAR(50);
DEFINE s_divisa        CHAR(50);
DEFINE s_codstatustarjeta CHAR(3);
DEFINE bValCuenta       BOOLEAN;
DEFINE cValor           CHAR(2);
DEFINE cValorCred       CHAR(2);
DEFINE cStatusCred       CHAR(2);
DEFINE cProdTransfer   CHAR(4);
DEFINE cProdTarjeta    CHAR(4);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_cuantos    = 0;
LET s_numcte     = "";
LET s_nombre1	= "";
LET s_nombre2	= "";
LET s_paterno	= "";
LET s_materno	= "";
LET s_fechanac	= "";
LET s_rfc	= "";
LET s_cuenta	= "";
LET s_tarjeta	= "";
LET s_status    = "";
LET s_status_cta ="";
LET s_producto    = "";
LET s_divisa      = "";
LET s_codstatustarjeta =  "";
LET bValCuenta    = "T";
LET cValor        = "";
LET cValorCred    = "";
LET cStatusCred   = "";
LET cProdTransfer = '';
LET cProdTarjeta  = '';

--scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa;


-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
   END IF;
END EXCEPTION;



	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


   LET pempresa = pempresa;
   LET psistema = psistema;
   LET ptipoctatar = ptipoctatar;
   LET pctatar = pctatar;


  -- Valida Parametros de Entrada

  IF pempresa = "" OR
     psistema = "" OR
     ptipoctatar = "" OR
     pctatar = "" THEN
     LET scod_ret = "110";
     RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
  END IF
  
		-----------------------------------VALIDA SI LA TARJETA ES PRODUCTO TRANSFER 8000------------------------------ 
		SELECT valor
		INTO cProdTransfer
		FROM bditransfer:"informix".tf_param
		WHERE empresa = pempresa AND cod_param = 4;

		SELECT prodtarjeta 
		INTO cProdTarjeta
		FROM bdicheq:"informix".sc_tarjeta
		WHERE empresa = pempresa AND num_tarjeta = pctatar;


		IF TRIM(cProdTransfer) = TRIM(cProdTarjeta) THEN
		
			LET scod_ret = "858";
			
			RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
			
		END IF
---------------------------TERMINA VALIDA SI LA TARJETA ES PRODUCTO TRANSFER 8000-------------------------------- 

  IF psistema = 1 THEN -- Sistema de Cheques
  
                SELECT valor  INTO cValor
				FROM bdicheq:"informix".sc_param WHERE codparam = 'longcta';

     IF ptipoctatar = "C" THEN

        --Valida que la cuenta exista en cheques

        SELECT mae.status_cta, mae.num_cte, mae.cuenta, prod.producto || " " || prod.nombre, div.divisa || " " || div.descripcion,
               clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc
          INTO s_status, s_numcte, s_cuenta, s_producto, s_divisa,
               s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc
          FROM bdicheq:"informix".sc_maechq mae,
               bdinteg:"informix".si_cliente clie,
               bdinteg:"informix".si_ctepf cte,
               bdinteg:"informix".si_divisas div,
               bdicheq:"informix".sc_producto prod
         WHERE mae.empresa = clie.empresa
               AND mae.empresa = cte.empresa
               AND mae.num_cte = clie.numcte
               AND mae.num_cte = cte.numcte
               AND prod.empresa = mae.empresa
               AND prod.producto = mae.producto
               AND div.empresa = mae.empresa
               AND div.divisa = prod.divisa
               AND ((mae.empresa= pempresa) AND (mae.cuenta= pctatar));

		 --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
		EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
		INTO bValCuenta;						

		IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
			LET scod_ret = "002";
			RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
		END IF	
		
        IF s_status IS NULL OR s_status  = "" THEN
           LET scod_ret = "100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status = "2" THEN
           LET scod_ret = "200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status = "3" THEN
           LET scod_ret = "100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        -- Busca las Tarjetas Relacionadas a las Cuentas
		-- Se agrega la validacion a la sc_firmantes para solo buscar tarjetas autorizadas
		-- CGP 10032015
        FOREACH
            SELECT tardeb.num_tarjeta, tardeb.cuenta, tardeb.status_tar, tar.codstatustarjeta
            INTO s_tarjeta, s_cuenta, s_status, s_codstatustarjeta
            FROM bdicheq:"informix".sc_tarjeta tardeb, intercard:"informix".tarjeta tar, bdicheq:"informix".sc_firmantes as firm
			WHERE (tardeb.empresa= pempresa)
            AND (tardeb.cuenta= pctatar)
            AND(tardeb.num_tarjeta = tar.numtarjeta )
			and (firm.cuenta = tardeb.cuenta)
			and (firm.numcte = tardeb.numcte)
            ORDER BY num_tarjeta ASC

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF

           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;


        END FOREACH
     END IF

     IF ptipoctatar = "T" THEN

        FOREACH
           SELECT tarj.cuenta, tarj.numcte, tarj.num_tarjeta, tarj.status_tar, prod.producto || " " || prod.nombre, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta, mae.status_cta
             INTO s_cuenta, s_numcte, s_tarjeta, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta, s_status_cta
             FROM bdicheq:"informix".sc_tarjeta tarj,
				  bdicheq:"informix".sc_maechq mae, --se agrega la tabla maechq para validar el estatus de la cuenta de la tarjeta que se desliza	
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdinteg:"informix".si_divisas div,
                  bdicheq:"informix".sc_producto prod,
                  intercard:"informix".tarjeta tar
            WHERE tarj.empresa = clie.empresa
                  AND tarj.numcte = clie.numcte
                  AND tarj.empresa = cte.empresa
                  AND tarj.numcte = cte.numcte
				  AND tarj.cuenta = mae.cuenta
                  AND prod.empresa = tarj.empresa
                  AND prod.producto = tarj.prodtarjeta
                  AND div.empresa = tarj.empresa
                  AND div.divisa = prod.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
               -- AND (tarj.tipo_tarjeta='T')
               -- AND (tarj.status_tar='A')
                  AND (tarj.num_tarjeta=pctatar))
            ORDER BY tarj.num_tarjeta ASC

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
		   
		   	   
			--Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
			EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
			INTO bValCuenta;	
		--se valida el estatus de la cuenta de la tarjeta que se esta deslizando
			IF s_status_cta IS NULL OR s_status_cta  = "" THEN
           LET scod_ret = "100"; -- No existe la cuenta
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

        IF s_status_cta = "2" THEN
           LET scod_ret = "200"; -- Cuenta Cancelada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF


        IF s_status_cta = "3" THEN
           LET scod_ret = "100"; -- Cuenta Bloqueada
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
        END IF

			IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" THEN 
				LET scod_ret = "002";
			END IF
	
			--dsb 28/05/2012
			IF scod_ret <> "002" THEN
				SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
				EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
				INTO bValCuenta;						

				IF LENGTH(s_cuenta) != cValor  OR bValCuenta  = "F" OR s_cuenta IS NULL THEN 
					LET scod_ret = "002";
				END IF
			END IF
			
			
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

			
        END FOREACH
     END IF
  END IF

  IF psistema = 6 THEN -- Sistema de Credito

                SELECT valor INTO cValorCred
				FROM bdicred:"informix".sd_param WHERE cod_param = '8';
				
     IF ptipoctatar = "T" THEN

        FOREACH
           SELECT tarj.num_credito, tarj.num_tarjeta, tarj.numcte, tarj.status_tar, def.num_producto || " " || def.nombre_prod, div.divisa || " " || div.descripcion,
                  clie.nombre1, clie.nombre2, clie.apell_paterno, clie.apell_materno, cte.fecha_nac, clie.rfc, tar.codstatustarjeta
             INTO s_cuenta, s_tarjeta, s_numcte, s_status, s_producto, s_divisa,
                  s_nombre1, s_nombre2, s_paterno, s_materno, s_fechanac, s_rfc, s_codstatustarjeta
             FROM bdicred:"informix".sd_tarjeta tarj,
                  bdinteg:"informix".si_cliente clie,
                  bdinteg:"informix".si_ctepf cte,
                  bdicred:"informix".sd_maecred mae,
                  bdicred:"informix".sd_definicion def,
                  bdinteg:"informix".si_divisas div,
                  intercard:"informix".tarjeta tar
            WHERE tarj.empresa = clie.empresa
                  AND tarj.numcte = clie.numcte
                  AND tarj.empresa = cte.empresa
                  AND tarj.numcte = cte.numcte
                  AND mae.empresa = tarj.empresa
                  AND mae.num_credito = tarj.num_credito
                  AND def.empresa = tarj.empresa
                  AND def.num_producto = mae.num_producto
                  AND div.empresa = mae.empresa
                  AND div.divisa = mae.divisa
                  AND tarj.num_tarjeta = tar.numtarjeta
                  AND ((tarj.empresa=pempresa)
                  --AND (tarj.tipo_tarjeta='T')
                  AND (tarj.num_tarjeta=pctatar))

           LET v_cuantos = v_cuantos + 1;
           IF v_cuantos <= pregistros THEN
              CONTINUE FOREACH;
           END IF
           
           
          LET cStatusCred = (SELECT status_cred FROM sd_maecred WHERE num_credito=s_cuenta);
 
          IF cStatusCred NOT IN ("AA","BA","BT","E1","E2","E3") THEN
                LET scod_ret = "279";
                RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta;
           END IF

			 --Valida que cuenta sea numerica y longitud de la cuenta DSB 14/03/2012
			EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
			INTO bValCuenta;						

			IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" THEN 
				LET scod_ret = "002";
			END IF
			
			--dsb 28/05/2012
			--Se valida la cuenta en tarjetacuenta 
			-----------------------------
			IF scod_ret <> "002" THEN
				SELECT numcuenta INTO s_cuenta FROM intercard:"informix".tarjetacuenta WHERE numtarjeta =  pctatar;
			-- RQI 23 1352 Otorgamiento de Préstamo digital. Error No. 2 La cuenta no puede quedar en ceros
			-- Se agrega validación en caso de no tener datos en intercard:tarjetacuenta, si no tiene se insertan.
			---------------------------------
					IF s_cuenta IS NULL THEN
						SELECT num_credito INTO s_cuenta FROM bdicred:sd_maecred WHERE numcte = s_numcte;
						INSERT INTO intercard:tarjetacuenta(numcuenta, numtarjeta) VALUES(s_cuenta, s_tarjeta);
					END IF;
			---------------------------------
				EXECUTE PROCEDURE bdinteg:"informix".val_num(s_cuenta)
				INTO bValCuenta;						

				IF LENGTH(s_cuenta) != cValorCred  OR bValCuenta  = "F" OR s_cuenta IS NULL  THEN 
					LET scod_ret = "002";
				END IF
			END IF
			-----------------------------
           RETURN scod_ret,s_numcte,s_nombre1,s_nombre2,s_paterno,s_materno,s_fechanac,s_rfc,s_cuenta,s_tarjeta,s_status,s_producto,s_divisa,s_codstatustarjeta
                  WITH RESUME;

        END FOREACH
     END IF
  END IF
END
END PROCEDURE
DOCUMENT
"Especificacion: Se modifico para que consulte el status de la tarjeta en",
"                la tabla intercard:tarjeta y se regrese como codigo de retorno",
"Base de Datos : bdicred",
"AUTOR : Elmer López Valenzuela",
"FECHA : 12/Oct/2016";

create procedure "informix".sp_carga_infoedocta_calif()
       returning char(5),CHAR(100),char(60);


    DEFINE vcodret          CHAR(5);
	DEFINE iSqlErr      	INTEGER;
	DEFINE iIsamErr         INTEGER;
	DEFINE cErrorInfo       CHAR(100);
	DEFINE cMensajeRet    	CHAR(100);
		
    DEFINE vsql             CHAR(1500);
	DEFINE vsql2            CHAR(1500);
	DEFINE vsh             CHAR(1500);
	
	DEFINE vfecha_carga				DATE;

	DEFINE nom_arch			CHAR(100);
	DEFINE nom_arch_zip		CHAR(100);
	DEFINE nom_sql			CHAR(100);
	DEFINE nom_sh			CHAR(100);
	DEFINE bandera_arch CHAR(1);
	DEFINE bandera_periodo  CHAR(6);
	DEFINE ruta_archivo		CHAR(100);
	DEFINE ruta_script		CHAR(100);
	DEFINE cred_del   VARCHAR(20);
	DEFINE fec_del 	 	DATE;
	DEFINE v_periodo CHAR(6);
	
	DEFINE cMensajeRet2    	CHAR(60); DEFINE Ini_proc char(22);  	DEFINE Fin_proc char(22); 	
	
	
	LET vcodret     = "00111";
	LET cMensajeRet = "Erro:No se realizo la carga";
    LET vsql = "";
	LET v_periodo = "";
	LET nom_arch="";
	LET nom_arch_zip ="";

	
BEGIN

ON EXCEPTION SET iSqlErr
   IF iSqlErr != 0 THEN
	  LET vcodret=  iSqlErr;
	  LET cMensajeRet2 = '';
    RETURN vcodret,cMensajeRet,cMensajeRet2;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/RESPALDOS/INFOSAT/Riesgos/25abr/sp_carga_infoedocta_calif.out";
--TRACE ON; 

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT DBINFO('utc_to_datetime', sh_curtime) INTO Ini_proc 
  FROM sysmaster:sysshmvals;

	SELECT mdy(month(fecha_hoy),'20',year(fecha_hoy))
	INTO vfecha_carga
	FROM sd_fechas;
	
	--let vfecha_carga = mdy('02','20','2019');
		
	LET v_periodo = lpad(MONTH(vfecha_carga),2,0)||year(vfecha_carga);
	LET ruta_archivo = "/resplogifx/archivoscartera/";
	LET ruta_script = "/resplogifx/archivoscartera/";

	
	IF (SELECT count(*) FROM  sd_info_edocta_calif WHERE fecha_emision = vfecha_carga) > 0 THEN
		SELECT num_credito ,fecha_emision
		FROM sd_info_edocta_calif
		WHERE fecha_emision = vfecha_carga
		into temp ctas_del with no log;
		

		CREATE INDEX idx_ctas_del ON ctas_del (num_credito) ONLINE;
	
		FOREACH WITH HOLD
			SELECT num_credito , fecha_emision
			INTO cred_del, fec_del
			FROM ctas_del
			
			BEGIN WORK;
				DELETE FROM sd_info_edocta_calif
	             WHERE fecha_emision  = fec_del
                   AND num_credito = cred_del;		
			COMMIT WORK;
		END FOREACH;  
			
		DROP TABLE ctas_del;
		
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_info_edocta_calif;		
	END IF;
	
	IF (SELECT count(*) FROM  sd_info_edocta_calif WHERE fecha_emision = vfecha_carga) = 0 THEN
--Descomprime el archivo
		LET nom_arch_zip = 'info_edocta_insumos'||trim(v_periodo)||'.unl.gz';	
		LET vsh ='gunzip '||trim(ruta_archivo)||trim(nom_arch_zip);
		SYSTEM vsh;	 	
--Valida existencia del sql de la carga de existir lo borra				
		LET nom_sh ='v_sql_carga_infoedoctacalif.sh';	
		LET vsh = trim(ruta_script)||trim(nom_sh);
		SYSTEM vsh;	
--Crea archivo sql para la carga		
		LET nom_arch ='';
		LET vsql = ''; 
	 
		LET nom_arch = 'info_edocta_insumos'||trim(v_periodo)||'.unl';
		LET nom_sql ='carga_infoedoctacalif_sql.sql'; 
			
		LET vsql = 'echo " FILE '||trim(ruta_archivo)||trim(nom_arch)||" delimiter '|' 9;"||
		' INSERT INTO sd_info_edocta_calif; '||
		'" > '||trim(ruta_script)||trim(nom_sql);
		SYSTEM vsql;
			
		LET vsql2 = '';
		LET vsql2 ='chmod 777 '||trim(ruta_script)||trim(nom_sql);
		SYSTEM vsql2;
		
--Ejecuta shell de carga		
		LET nom_sh ='carga_infoedoctacalif_sh.sh';
		LET vsh = trim(ruta_script)||trim(nom_sh);
		SYSTEM vsh;	 
			
		UPDATE STATISTICS MEDIUM FOR TABLE "informix".sd_info_edocta_calif;	

--Borra archivo cargado		
		LET vsh ='rm '||trim(ruta_archivo)||trim(nom_arch);
		SYSTEM vsh;	 					
		
		LET vcodret     = "00000";
		LET cMensajeRet = "CARGA INFORMACION EDOCTA "||v_periodo|| " Ok.";	
	END IF;	
	
	SELECT DBINFO('utc_to_datetime', sh_curtime) INTO fin_proc 
  FROM sysmaster:sysshmvals;
  
  LET cMensajeRet2= 'Inicio: '||Ini_proc||' Fin: '||fin_proc ;
	
    RETURN vcodret, cMensajeRet,cMensajeRet2;

END;
END PROCEDURE;