CREATE PROCEDURE "informix".reversion_td(pSucursal   CHAR(4),
                                     pUsuario    CHAR(8),
                                     pFolioOrig  CHAR(16),
                                     pNumCredito CHAR(20),
                                     pTransacc   CHAR(4),
                                     pImpOrig    MONEY(16,2),
                                     pImpRev     MONEY(16,2),
                                     pFolio      CHAR(16),
                                     pTranSuc    CHAR(4),
                                     pDivisa     CHAR(2))
   RETURNING CHAR(5), DATE;

   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE nrows               SMALLINT;
   DEFINE Mensaje             CHAR(80);
   DEFINE wBegin              CHAR(1);
   DEFINE wEmpresa            CHAR(3);
   DEFINE FechaMov            DATE;
   DEFINE HoraMov             DATETIME HOUR TO FRACTION(3);
   DEFINE wSecuencia          INTEGER;
   DEFINE wMonto              MONEY(16,2);
   DEFINE CodigoFun           CHAR(3);
   DEFINE CodigoRef           SMALLINT;
   DEFINE wReversado          CHAR(1);
   DEFINE NumProducto         CHAR(4);
   DEFINE wDivisa             CHAR(2);
   DEFINE FechaHoy            DATE;
   DEFINE wMtoReversa         MONEY(16,2);
   DEFINE FecAplic            DATE;
   DEFINE vNaturaleza         CHAR(1);
   DEFINE vTpTran	      CHAR(2);
   DEFINE cStatus	      CHAR(2);
   DEFINE vcod_ret  		CHAR(5);
   DEFINE vmontocs            MONEY(16,2);
   DEFINE vsucursal           CHAR(4); --INC 25 019
   DEFINE sdpromtot           SMALLINT; --INC 25 019
   DEFINE limefec			  CHAR(1); --RQM 10 1225
   DEFINE transuc             CHAR(4); --RQM 10 1225
   DEFINE cIndDispEfec        INTEGER; --RQM 10 1225
   DEFINE vNumProd            CHAR(4); --RQM 10 1225

   
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "ReversaLineaCredito.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET cod_ret = sql_err;
      LET FecAplic  = NULL;
      ROLLBACK WORK;
      IF (wBegin = "S") THEN
         BEGIN WORK;
      END IF;
      RETURN cod_ret, FecAplic;
   END EXCEPTION;



   ON EXCEPTION IN (-535)
      LET wBegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

  
   LET wBegin = "N";
   LET FecAplic = NULL;



   BEGIN WORK;
   LET cod_ret = "000";
   LET vmontocs = 0;
   LET cStatus = "";

   LET wEmpresa = pTransacc;
   LET vsucursal = ''; --INC 25 019
   LET sdpromtot = 0; --INC 25 019
   LET limefec	    = ''; --RQM 10 1225
   LET cIndDispEfec = 0; -- RQM 10 1225
   LET transuc      = ''; --RQM 10 1225
   LET vNumProd     = ''; --RQM 10 1225
   
 
FOREACH

   SELECT a.empresa, a.num_credito, a.fecha_mov, a.hora_mov,
	  a.secuencia, a.monto, a.codigo_fun, a.codigo_ref, a.reversado,
	  b.naturaleza, tipo_tran, a.sucursal,	  --INC 25 019
	  a.transacc_suc --RQM 10 1225
     INTO wEmpresa, pNumCredito, FechaMov, HoraMov,
	  wSecuencia, wMonto, CodigoFun, CodigoRef, wReversado,
	  vNaturaleza, vTpTran,vsucursal, -- INC 25 019
	  transuc --RQM 10 1225
     FROM sd_movdia a, bdinteg:si_transacc b
    WHERE a.empresa = wEmpresa
      AND a.folio_suc = pFolioOrig
      AND a.folio_suc = (case when codigo_fun = '002' and codigo_ref = 45 THEN '0' ELSE a.folio_suc END)
      AND b.empresa = a.empresa
      AND b.sistema = "06"
      AND b.numero = a.transacc_suc
	  
 
	 SELECT status_cred, diferimiento_int,num_producto --RQM 10 1225
      INTO cStatus, cIndDispEfec, vNumProd
     FROM bdicred:sd_maecred 
    WHERE empresa = wEmpresa
      AND num_credito = pNumCredito;	  
    
    SELECT limite_efectivo    --RQM 10 1225
	INTO limefec
	FROM bdicred:sd_conceptoscargoscredito
	WHERE transacc =  transuc;















   LET FecAplic = FechaMov;
   IF (wReversado = "S") THEN
      LET cod_ret = "000";
      RETURN cod_ret, FecAplic;
   END IF;

   IF vNaturaleza = "C" THEN
            
			SELECT count(*) INTO sdpromtot FROM bdicred:sd_promocion_credito 
			WHERE empresa = wEmpresa 
			AND num_credito = pNumCredito AND folio_movto = pFolioOrig AND status = 0;
			
            IF sdpromtot > 0 THEN
                  SELECT limit 1 nvl(monto_int_iva,0)
                    INTO vmontocs 
                    FROM sd_promocion_credito  
                   WHERE empresa = wEmpresa
                     AND folio_movto = pFolioOrig
                     AND status = 0;
                 
                   UPDATE sd_maesdos
                      SET sdo_retenido = sdo_retenido - vmontocs
                    WHERE num_credito = pNumCredito
                      AND empresa = wEmpresa;

                   UPDATE sd_promocion_credito
                      SET status = 5
                    WHERE num_credito = pNumCredito
                      AND empresa = wEmpresa
                      AND folio_movto = pFolioOrig
                      AND status = 0;

                   UPDATE sd_maeretenido
                      SET estatus = 'S'
                    WHERE num_credito = pNumCredito
                      AND empresa = wEmpresa
                      AND folio_suc = pFolioOrig
                      AND estatus = 'R';

                   UPDATE sd_movdia
                      SET reversado = 'S'
                    WHERE empresa = wEmpresa
                      AND num_credito = pNumCredito
                      AND folio_suc = pFolioOrig
                      AND codigo_fun = '002' AND codigo_ref = 45;

            END IF;              
                
               UPDATE sd_maesdos
                  SET sdo_capital = CASE WHEN  cStatus = "BT"  THEN  sdo_capital ELSE sdo_capital - wMonto END,--JMAH
                --  SET sdo_capital = sdo_capital - wMonto,
                  sdo_cap_insoluto = sdo_cap_insoluto - wMonto,
                  mto_ministra_cap = mto_ministra_cap - wMonto,
                  cargos_mes_cap = cargos_mes_cap - wMonto,
				  cap_tras_no_venci = CASE WHEN  cStatus = "BT" THEN  cap_tras_no_venci - wMonto ELSE cap_tras_no_venci END --JMAH 
		       WHERE num_credito = pNumCredito
                  AND empresa = wEmpresa;
               
			   --INC 25 019	   
               UPDATE sd_movdia
                  SET reversado = "S"
                WHERE empresa = wEmpresa
                  AND num_credito = pNumCredito
                  AND folio_suc = pFolioOrig
                  --AND sucursal = pSucursal 
				  AND sucursal = vsucursal --INC 25 019
                  AND secuencia = wSecuencia;

                   IF vTpTran IN ("01","02") THEN
                    UPDATE sd_detcomi
                       SET estado_com = "C"
                     WHERE num_credito = pNumCredito
                       AND num_solicitud = pFolioOrig
                       AND monto_com = wMonto;	   
			   END IF
			   			
			IF cIndDispEfec = 1 or cIndDispEfec = 2 THEN --RQM 10 1225-2	
				IF NVL(limefec,'0') = '1' THEN --DISPOSICIONES EN EFECTIVO A NIVEL TRANSACCION
					UPDATE sd_maesdos SET sdo_acum_vencido =  sdo_acum_vencido - wMonto
					WHERE empresa = wEmpresa AND num_credito = pNumCredito;					
			    END IF;
			END IF;
			   






				   IF (CodigoFun = '339' AND  CodigoRef = 96)  THEN
						DELETE  FROM sd_comision_x_apertura_contable  WHERE empresa = wEmpresa	AND num_credito = pNumCredito;

						UPDATE "informix".sd_maecred
						SET campo_trab4 ='' --se actualiza para indicar que ya se realizo el cobro de la comision por apertura
						WHERE empresa =wEmpresa
						AND num_credito = pNumCredito;
				   END IF;

     
   ELIF vNaturaleza = "A" THEN
	IF CodigoFun = "033" OR CodigoFun = "335" OR CodigoFun = "336" THEN
		IF CodigoRef = 2 THEN

		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		ELIF CodigoRef = 3 THEN
		END IF
	   UPDATE sd_movdia
	   SET reversado = "S"
	   WHERE empresa = wEmpresa
	   AND num_credito = pNumCredito
	   AND folio_suc = pFolioOrig;

	ELIF CodigoFun = "650" THEN

	END IF
	IF (vTpTran IN ("00") and vNaturaleza = "C" ) or (vNaturaleza = "A") THEN
           EXECUTE PROCEDURE sp_graba_indicador(wEmpresa, pNumCredito,wMonto, pTranSuc,CodigoFun, CodigoRef, FechaMov,pFolio,0,0,3)
           INTO vcod_ret;
	END IF;	   
   END IF

END FOREACH

      COMMIT WORK;
   IF (wBegin = "S") THEN
     BEGIN WORK;
   END IF;
   RETURN cod_ret, FecAplic;
END PROCEDURE
DOCUMENT
'Esta funcion realiza la reversion de un movimiento ATM ',
'en el producto Insta - Cash, si los importes son iguales y es fecha de hoy',
'Se reversa el movimiento total, marcando en movdia y regresando saldos',
'mediante comparacion entre los saldos del movimiento y las fechas actual y',
'del movimiento, se decide si es una reversion retroactiva, o actual y ',
'si es parcial o total',
'AUTOR : Raul Mendoza',
'FECHA : 8/10/2003',
'BD : bdicred ',
'CLIENTE : CACSI';

CREATE PROCEDURE "informix".sp_administra_tarjetas_ppass(pEmpresa VARCHAR(3), pNumcte VARCHAR(20), pNumCredito VARCHAR(20),
														pNumTarjeta VARCHAR(20), pProducto VARCHAR(4), pEstatus VARCHAR(3),
														pOpcion SMALLINT, pSecuencia INTEGER, pNumEmpleado VARCHAR(8) DEFAULT "",
														pMotivoCancelacion VARCHAR(1) DEFAULT "")
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(20) 	AS cNumCte,
				CHAR(104)	AS cNombre,
				CHAR(13) 	AS cRFC,
				CHAR(13) 	AS cTelefono,
				CHAR(20) 	AS cNumCredito,
				CHAR(2) 	AS cEstatusCred,
				CHAR(20) 	AS cNumTarjetaPlat,
				CHAR(1) 	AS cEstatusTarPlat,
				CHAR(1) 	AS cEstatusTarPlatTit,
				CHAR(4) 	AS cProductoPlat,
				CHAR(1) 	AS cTipoTarjetaPlat,				
				CHAR(45) 	AS cDescripconPlat,
				CHAR(20)	AS cNumTarjetaPPass,
				CHAR(20)	AS cFechaVencimientoPPass,
				CHAR(1) 	AS cEstatusTarPPass,
				CHAR(16) 	AS cFolioCancelacion,
				CHAR(2) 	AS cCancelacionSecuencia;

DEFINE sql_err INTEGER;
DEFINE cCodRet CHAR(6);
DEFINE cNumCte CHAR(20);
DEFINE cNumCteAnt CHAR(20);
DEFINE cNombre CHAR(104);
DEFINE cRFC CHAR(13);
DEFINE cTelefono CHAR(13);
DEFINE cNumCredito CHAR(20);
DEFINE cNumCreditoAnt CHAR(20);
DEFINE cNumTarjetaPlat CHAR(20);
DEFINE cEstatusTarPlat CHAR(1);
DEFINE cEstatusTarPlatTit CHAR(1);
DEFINE cTipoTarjetaPlat CHAR(1);
DEFINE cProductoPlat CHAR(4);
DEFINE cDescripconPlat CHAR(45);
DEFINE cNumTarjetaPPass CHAR(20);
DEFINE cFechaVencimientoPPass CHAR(20);
DEFINE cEstatusTarPPass CHAR(1);
DEFINE cEstatusCred CHAR(2);
DEFINE cFolioCancelacion CHAR(16);
DEFINE iCancelacionSecuencia INTEGER;								 
DEFINE cCancelacionSecuencia CHAR(2);

LET sql_err = 0;
LET cCodRet = "000000";
LET cNumCte = "";
LET cNumCteAnt = "";
LET cNombre = "";
LET cRFC = "";
LET cTelefono = "";
LET cNumCredito = "";
LET cNumCreditoAnt = "";
LET cNumTarjetaPlat = "";
LET cProductoPlat = "";
LET cDescripconPlat = "";
LET cEstatusTarPlat = "";
LET cEstatusTarPlatTit = "";
LET cTipoTarjetaPlat = "";
LET cNumTarjetaPPass = "";
LET cFechaVencimientoPPass = "";
LET cEstatusTarPPass = "";
LET cEstatusCred = "";
LET cFolioCancelacion = "";
LET iCancelacionSecuencia = 0;
LET cCancelacionSecuencia = "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet, ''), NVL(cNumCte, ''), NVL(cNombre, ''), NVL(cRFC, ''),NVL(cTelefono, ''),
				NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
				NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass, ''), NVL(cFechaVencimientoPPass, ''), NVL(cEstatusTarPPass, ''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
		END IF;
	END EXCEPTION;


	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_administra_tarjetas_ppass.out";
	--TRACE ON;

	IF pOpcion = 1 AND TRIM(pEmpresa) <> "" AND TRIM(pNumcte) <> "" AND TRIM(pProducto) <> "" THEN
		FOREACH
			SELECT
					tarjeta_plat.num_credito, tarjeta_plat.status_tar, tarjeta_plat.tipo_tarjeta, maecred.status_cred
				INTO
					cNumCredito, cEstatusTarPlat, cTipoTarjetaPlat, cEstatusCred
			FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_maecred maecred
				ON maecred.num_credito = tarjeta_plat.num_credito
			WHERE tarjeta_plat.empresa = pEmpresa
				AND maecred.empresa = pEmpresa
				AND tarjeta_plat.numcte = pNumcte
				AND tarjeta_plat.prodtarjeta = pProducto
				ORDER BY tarjeta_plat.num_credito ASC, tarjeta_plat.status_tar ASC, tarjeta_plat.secuencia DESC,
				maecred.status_cred ASC
				
			LET cCancelacionSecuencia = "0";
			LET cEstatusTarPlatTit = "";
			LET cEstatusTarPPass = "";
			
			IF TRIM(cNumCredito) <> TRIM(cNumCreditoAnt) THEN
			
				FOREACH
					SELECT
							status_tar
						INTO
							cEstatusTarPPass
					FROM "informix".sd_tarjeta_ppass
					WHERE numcte = pNumcte
					AND num_credito = cNumCredito
					ORDER BY status_tar ASC, secuencia DESC
				END FOREACH;
			
				IF TRIM(cTipoTarjetaPlat) = "T" THEN
					LET cEstatusTarPlatTit = cEstatusTarPlat;
				ELSE
					FOREACH
						SELECT 
								LIMIT 1 status_tar
							INTO
								cEstatusTarPlatTit
						FROM "informix".sd_tarjeta
						WHERE prodtarjeta = pProducto
						AND num_credito = cNumCredito
						AND tipo_tarjeta = 'T'
						ORDER BY status_tar ASC, secuencia DESC
					END FOREACH;
				END IF;
				
				SELECT COUNT(*) INTO cCancelacionSecuencia
					FROM (SELECT numcte, num_credito 
							FROM "informix".sd_tarjeta_ppass
								WHERE num_credito = cNumCredito
								AND status_tar IN ('A','C','R','S')
								GROUP BY numcte, num_credito);
					
				RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
					NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
					NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0') WITH RESUME;
			END IF;
				
			LET cNumCreditoAnt = cNumCredito;
		END FOREACH;
	ELIF pOpcion = 2 AND TRIM(pNumCredito) <> "" THEN
		FOREACH
			SELECT 
					tarjeta_plat.numcte, tarjeta_plat.num_credito, tarjeta_plat.num_tarjeta, tarjeta_plat.status_tar, tarjeta_plat.tipo_tarjeta,
					tarjeta_plat.prodtarjeta, maecred.status_cred
				INTO
					cNumCte, cNumCredito, cNumTarjetaPlat, cEstatusTarPlat, cTipoTarjetaPlat,
					cProductoPlat, cEstatusCred
			FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_maecred maecred
				ON maecred.num_credito = tarjeta_plat.num_credito
			WHERE tarjeta_plat.empresa = pEmpresa
			AND maecred.empresa = pEmpresa
			AND tarjeta_plat.num_credito = pNumCredito
			AND tarjeta_plat.prodtarjeta = pProducto
			ORDER BY tarjeta_plat.tipo_tarjeta DESC, tarjeta_plat.numcte ASC, tarjeta_plat.status_tar ASC, tarjeta_plat.secuencia DESC
							
			LET cCodRet = "000000";
			LET cDescripconPlat = "";
			LET cNombre = "";
			LET cRFC = "";			
			LET cTelefono = "";
			LET cNumTarjetaPPass = "";
			LET cFechaVencimientoPPass = "";
			LET cEstatusTarPPass = "";
			LET cEstatusTarPlatTit = "";
			
			IF TRIM(cNumCteAnt) <> TRIM(cNumCte) THEN
			
				FOREACH
					SELECT 
							numtarjeta_ppass, CAST(expiracion AS CHAR(10)), status_tar
						INTO
							cNumTarjetaPPass, cFechaVencimientoPPass, cEstatusTarPPass
					FROM "informix".sd_tarjeta_ppass
					WHERE numcte = cNumCte
					AND num_credito = pNumCredito
					ORDER BY status_tar ASC
				END FOREACH;
			
				IF TRIM(cEstatusTarPlatTit) = "" THEN
					IF TRIM(cTipoTarjetaPlat) = "T" THEN
						LET cEstatusTarPlatTit = cEstatusTarPlat;
					ELSE
						FOREACH
							SELECT 
									LIMIT 1 status_tar
								INTO
									cEstatusTarPlatTit
							FROM "informix".sd_tarjeta
							WHERE prodtarjeta = pProducto
							AND num_credito = cNumCredito
							AND tipo_tarjeta = 'T'
							ORDER BY status_tar ASC, secuencia DESC
						END FOREACH;
					END IF;
				END IF;
			
				SELECT num_producto || ' ' || nombre_prod INTO cDescripconPlat
				FROM "informix".sd_definicion
					WHERE empresa = pEmpresa
					AND num_producto = cProductoPlat;

				SELECT
						REPLACE(TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), '  ', ' '), rfc
					INTO
						cNombre, cRFC
				FROM bdinteg: "informix".si_cliente WHERE numcte = cNumCte;

				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = "000003";
				ELSE				
					SELECT telefono INTO cTelefono FROM bdinteg: "informix".si_telefonos_actual WHERE NUMCTE = cNumCte AND tipo_tel = '1' AND secuencia = (
						SELECT MAX(SECUENCIA) FROM bdinteg: "informix".si_telefonos_actual
							WHERE NUMCTE = cNumCte
							AND tipo_tel = '1');
							
						RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
						NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
						NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0') WITH RESUME;
				END IF;
				
				LET cNumCteAnt = cNumCte;
			END IF;

		END FOREACH;
	ELIF pOpcion = 3 AND TRIM(pEmpresa) <> "" THEN
		IF TRIM(pNumTarjeta) <> "" THEN
			SELECT LIMIT 1 numcte INTO cNumCte
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_tarjeta = pNumTarjeta
				AND prodtarjeta = pProducto;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000002";
			END IF;	
			
		ELIF TRIM(pNumCredito) <> "" THEN
			SELECT LIMIT 1 numcte INTO cNumCte
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_credito = pNumCredito
				AND tipo_tarjeta = 'T'
				AND prodtarjeta = pProducto;
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000003";
			END IF;	
		END IF;			
		
	ELIF pOpcion = 4 AND TRIM(pNumTarjeta) <> "" AND TRIM(pEstatus) <> "" THEN
		UPDATE "informix".sd_tarjeta_ppass 
		SET status_tar = pEstatus 
		WHERE numtarjeta_ppass = pNumTarjeta;
		
	ELIF pOpcion = 5 AND TRIM(pNumTarjeta) <> "" THEN
		SELECT {+INDEX(bdicred: sd_tarjeta_ppass idx_sd_tarjeta_ppass)} status_tar INTO cEstatusTarPPass 
		FROM "informix".sd_tarjeta_ppass 
			WHERE num_credito IS NOT NULL AND num_tarjeta IS NOT NULL AND numtarjeta_ppass = pNumTarjeta AND secuencia IS NOT NULL;
			
	ELIF pOpcion = 6 AND TRIM(pNumTarjeta) <> "" AND TRIM(pEstatus) <> "" AND TRIM(pNumEmpleado) <> "" THEN 
			LET cFolioCancelacion = TRIM(pNumEmpleado) || TRIM(TO_CHAR(TODAY,'%d%m%y'));
			
			SELECT COUNT(*) INTO iCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass
				WHERE SUBSTR(folio_canc, 1,14) = cFolioCancelacion;

			LET iCancelacionSecuencia = iCancelacionSecuencia + 1;
			LET cFolioCancelacion = TRIM(cFolioCancelacion) || LPAD(iCancelacionSecuencia, 2, '0');
			
			UPDATE "informix".sd_tarjeta_ppass 
			SET status_tar = pEstatus, folio_canc = cFolioCancelacion, motivo_canc = pMotivoCancelacion
			WHERE numtarjeta_ppass = pNumTarjeta;
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000002";
			ELSE
				UPDATE "informix".sd_inven_tarppass 
				SET status_tar = pEstatus, desc_status = "CANCELADA", fecha_modif = CURRENT
				WHERE numtarjeta_ppass = pNumTarjeta;
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					UPDATE "informix".sd_tarjeta_ppass 
					SET status_tar = 'A', folio_canc = '', motivo_canc = ''
					WHERE numtarjeta_ppass = pNumTarjeta;
				END IF;
				
			END IF;
	ELIF pOpcion = 7 AND TRIM(pNumCredito) <> "" AND TRIM(pEmpresa) <> "" THEN
		IF pSecuencia = 1 THEN		
			SELECT COUNT(*) INTO cCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass tarjeta_ppass
			INNER JOIN "informix".sd_tarjeta tarjeta_plat
				ON tarjeta_ppass.numcte = tarjeta_plat.numcte
					AND tarjeta_ppass.num_credito = tarjeta_plat.num_credito
				WHERE tarjeta_ppass.num_credito = pNumCredito
				AND tarjeta_ppass.status_tar IN ('A','C','R','S')
				AND tarjeta_plat.status_tar = 'A';
		ELSE
			SELECT COUNT(*) INTO cCancelacionSecuencia
			FROM "informix".sd_tarjeta_ppass
				WHERE num_credito = pNumCredito
				AND status_tar = 'A';
		END IF;				
	ELIF pOpcion = 8 AND TRIM(pNumCredito) <> "" AND TRIM(pEmpresa) <> "" THEN
		SELECT COUNT(*) INTO cCancelacionSecuencia
		FROM "informix".sd_tarjeta tarjeta_plat
			INNER JOIN "informix".sd_tarjeta_ppass tarjeta_ppass
			ON tarjeta_ppass.num_credito = tarjeta_plat.num_credito
				AND tarjeta_ppass.numcte = tarjeta_plat.numcte
			WHERE tarjeta_plat.num_credito = pNumCredito
			AND tarjeta_plat.tipo_tarjeta <> 'T'
			AND tarjeta_plat.numcte = pNumcte
			AND tarjeta_ppass.tipo_tarjeta <> 'T'
			AND tarjeta_ppass.status_tar IN ('A','C','R','S');
			
	ELIF pOpcion = 9 THEN
		FOREACH
			SELECT
					LIMIT 1 numtarjeta_ppass
				INTO
					cNumTarjetaPPass
			FROM "informix".sd_inven_tarppass
				WHERE status_tar = 'S'
				ORDER BY id_tar_ppass ASC
				
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = "000002";
			ELSE
				IF pSecuencia = 1 THEN
					UPDATE "informix".sd_inven_tarppass 
					SET status_tar = 'A', desc_status = 'ACTIVA', fecha_modif = CURRENT
					WHERE numtarjeta_ppass = cNumTarjetaPPass;
				END IF;
			END IF;
		END FOREACH;
	ELIF pOpcion = 10 THEN
		UPDATE "informix".sd_inven_tarppass 
			SET status_tar = 'S', desc_status = 'SIN ASIGNAR', fecha_modif = CURRENT
			WHERE numtarjeta_ppass = pNumTarjeta;
	ELIF pOpcion = 11 AND TRIM(pNumcte) <> "" THEN
	
		SELECT
				REPLACE(TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), '  ', ' '), rfc
			INTO
				cNombre, cRFC
		FROM bdinteg: "informix".si_cliente WHERE numcte = pNumcte;

		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = "000003";
		ELSE				
			SELECT telefono INTO cTelefono FROM bdinteg: "informix".si_telefonos_actual WHERE NUMCTE = pNumcte AND tipo_tel = '1' AND secuencia = (
				SELECT MAX(SECUENCIA) FROM bdinteg: "informix".si_telefonos_actual
					WHERE NUMCTE = pNumcte
					AND tipo_tel = '1');
					
				RETURN NVL(cCodRet,''), NVL(pNumcte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
				NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
				NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
		END IF;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND pOpcion <> 3 THEN
		LET cCodRet = "000002";
	END IF;

	IF ((pOpcion = 1 OR pOpcion = 2) AND cCodRet != "000000") OR pOpcion > 2 THEN
		RETURN NVL(cCodRet,''), NVL(cNumCte,''), NVL(cNombre,''), NVL(cRFC,''),NVL(cTelefono,''),
			NVL(cNumCredito, ''), NVL(cEstatusCred, ''), NVL(cNumTarjetaPlat, ''), NVL(cEstatusTarPlat, ''), NVL(cEstatusTarPlatTit, ''), NVL(cProductoPlat, ''), NVL(cTipoTarjetaPlat, ''),
			NVL(cDescripconPlat, ''), NVL(cNumTarjetaPPass,''), NVL(cFechaVencimientoPPass,''), NVL(cEstatusTarPPass,''), NVL(cFolioCancelacion, ''), NVL(cCancelacionSecuencia, '0');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 Adrián Eduardo Lizárraga Cázares',
'BD: bdicred',
'Fecha: 2019-11-06',
'Descripción: Se genera procedimiento para administrar las tarjetas Priority Pass',
'Solicitó: Rodolfo Gomez Hernandez',
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 Adrián Eduardo Lizárraga Cázares',
'BD: bdicred',
'Fecha: 2020-01-27',
'Descripción: Se modifica procedimiento almacenado para extraer los datos generales del Cliente desde el aplicativo pl004064.exe',
'Solicitó: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_consulta_accesos_ppass(pNumTarjeta VARCHAR(20), pMesAcceso VARCHAR(7), pSecuencia INTEGER)
	
	RETURNING CHAR(6)  AS cCodRet,
			  CHAR(10) AS cFechaVisita,
			  CHAR(20) AS cNumTarjetaPPas,
			  CHAR(69) AS cPaisSalon,
			  CHAR(11) AS cTotalVisistasTi,
		      CHAR(11) AS cTotalVisitasAdic,
			  CHAR(11) AS cTotalvisitas,
			  CHAR(11) AS cNumVisitasSCost,
			  CHAR(11) AS cNumVisFact,
			  CHAR(25) AS dTotalAPagar;
	
	DEFINE sql_err 				INTEGER;
	DEFINE cCodRet 				CHAR(6);
	DEFINE cCategoria 			CHAR(1);
	DEFINE iAccGratis 			INTEGER;
	DEFINE cFechaVisita 		CHAR(10);
	DEFINE cNumTarjetaPPass 	CHAR(20);
	DEFINE cPaisSalon 			CHAR(69);
	DEFINE cTotalVisistasTi 	CHAR(11);
	DEFINE cTotalVisitasAdic	CHAR(11);
	DEFINE cTotalvisitas		CHAR(11);
	DEFINE cNumVisitasSCost 	CHAR(11);
	DEFINE cNumVisFact 			CHAR(11);
	DEFINE dTotalAPagar 		DECIMAL(18,4);
	DEFINE cCostoAcceso 		CHAR(3);

	LET sql_err				= 0;
	LET cCodRet 			= '000000';
	LET cCategoria 			= '';
	LET iAccGratis 			= 0;
	LET cFechaVisita 		= '';
	LET cNumTarjetaPPass 	= '';
	LET cPaisSalon 			= '';
	LET cTotalVisistasTi 	= '';
	LET cTotalVisitasAdic 	= '';
	LET cTotalvisitas 		= '';
	LET cNumVisitasSCost 	= '';
	LET cNumVisFact 		= '';
	LET dTotalAPagar 		= 0.0;
	LET cCostoAcceso 		= '';


	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN

		

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET cCodRet = sql_err;
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Jesus/sp_consulta_movimientos_ppass.out';
		--TRACE ON;
		
		SELECT FIRST 1 categoria 
		INTO cCategoria
		FROM "informix".sd_tarjeta_ppass
		WHERE numtarjeta_ppass = pNumTarjeta; 	

		SELECT acceso_gratis 
		INTO iAccGratis
		FROM "informix".catcategoriappass
		WHERE id_categoria = cCategoria;		
		
		IF  dbinfo("sqlca.sqlerrd2") = 0 THEN			
			LET cCodRet = '000003';
		ELSE
		
			SELECT valor 
			INTO cCostoAcceso
			FROM "informix".sd_param 
			WHERE cod_param = '074';
			
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN				
				LET cCodRet = '000004';				
			END IF;
		END IF;
		
		IF TRIM(pNumTarjeta) <> "" AND TRIM(pMesAcceso) <> "" THEN
			
				FOREACH
						SELECT SKIP pSecuencia
						TO_CHAR(A.fecha_visita, '%d/%m/%Y') AS fecha_visita,
						TO_CHAR(numtarjeta_ppass) AS num_tarjeta,
						TO_CHAR(id_pais_visita || '  ' || nombre_lounge) AS pais_salon, 
						TO_CHAR(A.totalpp_deslizada) AS vis_titular,
						TO_CHAR(A.total_invitados) AS vis_Adic,
						TO_CHAR(A.total_visitas) AS vis_total, 
						TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE iAccGratis END)) AS vi_sinc,
						TO_CHAR((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END)) AS vi_fact, 
						TO_CHAR(((CASE WHEN (iAccGratis >= A.total_visitas) THEN 0 ELSE (A.total_visitas - iAccGratis) END) * 
						NVL((SELECT precio_venta FROM bdinteg: "informix".si_histdiv WHERE fecha_tc = A.fecha_visita AND divisa = '02' 
						AND hora_tc = (SELECT MAX(hora_tc) FROM bdinteg: "informix".si_histdiv 
						WHERE fecha_tc = A.fecha_visita AND divisa = '02')), 0) * cCostoAcceso )) AS total_facturable
						
						INTO cFechaVisita, cNumTarjetaPPass, cPaisSalon, cTotalVisistasTi, cTotalVisitasAdic,
						cTotalvisitas, cNumVisitasSCost, cNumVisFact, dTotalAPagar
						
						FROM "informix".sd_movmes_ppass AS A 
						WHERE A.numtarjeta_ppass = pNumTarjeta 
						AND MONTH(A.fecha_visita) = SUBSTRB(pMesAcceso, 1, 2) AND YEAR(A.fecha_visita) = SUBSTRB(pMesAcceso, 4, 4)
						ORDER BY A.fecha_visita ASC
					
					RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
					NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'') WITH RESUME;

				END FOREACH;

		ELSE 
			LET cCodRet = '000001';
		END IF;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '000000' THEN
			LET cCodRet = "000002";
		END IF;

		IF TRIM(cCodRet) <> "000000" THEN
				RETURN NVL(cCodRet,''), NVL(cFechaVisita,''), NVL(cNumTarjetaPPass,''), NVL(cPaisSalon,''),	NVL(cTotalVisistasTi,''),
				NVL(cTotalVisitasAdic,''), NVL(cTotalvisitas,''), NVL(cNumVisitasSCost,''),	NVL(cNumVisFact,''), NVL(dTotalAPagar,'');
		END IF;


	END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-18',
'DescripciÃ³n: Se genera procedimiento almacenado para consultar las visitas que el Cliente ha realizado con su tarjeta Priority Pass en un plazo',
'			  no mayor a 12 meses y con un rango de bÃºsqueda de 32 dÃ­as',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_catcausapp(pSecuencia INTEGER)
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(11)	AS cID,
	            CHAR(1)		AS cCausa,
	            CHAR(25)	AS cDescripcion;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(6);
DEFINE cID					CHAR(11);
DEFINE cCausa 				CHAR(1);
DEFINE cDescripcion 		CHAR(25);

LET sql_err					= 0;
LET cCodRet 				= "000000";
LET cID						= "";
LET cCausa 					= "";
LET cDescripcion 			= "";

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
		END IF;
	END EXCEPTION;


	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_catcausapp.out";
	--TRACE ON;


	FOREACH 
		SELECT SKIP pSecuencia 
				id_causa, causa, descripcion
			INTO
				cID, cCausa, cDescripcion
		FROM "informix".catcausapp
		ORDER BY id_causa ASC
		
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'') WITH RESUME;
	END FOREACH;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "000002";
	END IF;

	IF cCodRet <> "000000" THEN
		RETURN NVL(cCodRet,''), NVL(cID,''), NVL(cCausa,''), NVL(cDescripcion,'');
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-26',
'DescripciÃ³n: Se genera procedimiento almacenado para consultar los motivos de cancelaciÃ³n para las tarjetas Priority Pass',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_info_layout_ppass(pEmpresa VARCHAR(3), pNumTarPPassAnt VARCHAR(20), pNumTarPPassNue VARCHAR(20), pNumTarPlat VARCHAR(20), pNumCredito VARCHAR(20),
												 pNumCte VARCHAR(20), pSucursal VARCHAR(4), pEstatusLayout VARCHAR(1), pDestino VARCHAR(1), pBusquedaSuc VARCHAR(20),
												 pOpcion INTEGER, pSecuencia INTEGER)
	RETURNING 	CHAR(6) 	AS cCodRet,
				CHAR(4)		AS cNumeroSucursal,
	            CHAR(40)	AS cNombreSucursal,
	            CHAR(40)	AS cDireccionSucursal,
	            CHAR(40)	AS cColoniaSucursal,
	            CHAR(30)	AS cEstadoSucursal;

DEFINE sql_err 				INTEGER;
DEFINE cCodRet 				CHAR(6);
DEFINE cNumeroSucursal		CHAR(4);
DEFINE cNombreSucursal		CHAR(40);
DEFINE cDireccionSucursal	CHAR(40);
DEFINE cColoniaSucursal		CHAR(40);
DEFINE cEstadoSucursal		CHAR(30);
DEFINE iId_Reg				INTEGER;
DEFINE dFechaAperturaCred	DATE;
DEFINE cNombreTarjeta		CHAR(50);
DEFINE cNombre				CHAR(25);
DEFINE cApellidoPat			CHAR(25);
DEFINE dFechaExp			DATE;
DEFINE cDireccion1			CHAR(40);
DEFINE cDireccion2			CHAR(40);
DEFINE cNumCiudad			CHAR(3);
DEFINE cCiudad				CHAR(3);
DEFINE cNumEstado			CHAR(2);
DEFINE cCalle				CHAR(40);
DEFINE cColonia				CHAR(60);
DEFINE cTipoTarjeta			CHAR(1);
DEFINE cDireccionRecepcion  CHAR(150);
DEFINE cNombreEstado 		CHAR(30);
DEFINE cNombreCiudad 		CHAR(60);
DEFINE cBusquedaSuc 		CHAR(22);
DEFINE iNumCalle 			INTEGER;
DEFINE iNumColonia 			INTEGER;
DEFINE iNumeroExtCalle		INTEGER;


LET sql_err					= 0;
LET cCodRet 				= '000000';
LET cNumeroSucursal 		= '';
LET cNombreSucursal 		= '';
LET cDireccionSucursal 		= '';
LET cColoniaSucursal 		= '';
LET cEstadoSucursal 		= '';
LET iId_Reg 				= 0;
LET dFechaAperturaCred 		= NULL;
LET cNombreTarjeta	 		= '';
LET cNombre	 				= '';
LET cApellidoPat	 		= '';
LET dFechaExp		 		= NULL;
LET cDireccion1				= '';
LET cDireccion2				= '';
LET cNumCiudad				= '';
LET cCiudad					= '';
LET cNumEstado				= '';
LET cCalle					= '';
LET cColonia				= '';
LET cTipoTarjeta			= '';
LET cDireccionRecepcion		= '';
LET cNombreEstado			= '';
LET cNombreCiudad			= '';
LET cBusquedaSuc			= '';
LET iNumCalle				= 0;
LET iNumColonia				= 0;
LET iNumeroExtCalle			= 0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cCodRet = sql_err;
			RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
			TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/home/sysifx/respaldosbd/Adrian/639/sp_info_layout_ppass.out";
	--TRACE ON;
	
	IF pOpcion = 1 THEN
		IF TRIM(pEmpresa) != "" THEN
			LET cBusquedaSuc = '%' || TRIM(pBusquedaSuc) || '%';
			FOREACH
				SELECT SKIP pSecuencia
							suc.sucursal, suc.nombre, suc.direccion1, suc.direccion2, est.nombre
					INTO
						cNumeroSucursal, cNombreSucursal, cDireccionSucursal, cColoniaSucursal, cEstadoSucursal
				FROM bdinteg: "informix".si_sucursales suc
				INNER JOIN bdinteg: "informix".si_estados est
				ON est.estado = suc.estado
				WHERE suc.nombre LIKE cBusquedaSuc OR suc.direccion1 LIKE cBusquedaSuc OR suc.direccion2 LIKE cBusquedaSuc
				AND suc.empresa = pEmpresa
				AND suc.tpo_sucursal = 'S'
				ORDER BY est.nombre ASC, suc.nombre ASC
					
				RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
				TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,'')) WITH RESUME;
			END FOREACH
		ELSE
			LET cCodRet = "000001";
		END IF;
	ELIF pOpcion = 2 THEN
		IF TRIM(pNumCredito) != "" AND TRIM(pNumCte) != "" AND TRIM(pEmpresa) != "" AND TRIM(pNumTarPlat) != "" AND TRIM(pSucursal) != "" THEN
			SELECT
					MAX(id_reg) + 1
				INTO
					iId_Reg
			FROM "informix".sd_info_layout_ppass;
			
			LET iId_Reg = NVL(iId_Reg, 0);
			
			SELECT
					fecha_apertura
				INTO
					dFechaAperturaCred
			FROM "informix".sd_maecred
			WHERE empresa = pEmpresa
			AND num_credito = pNumCredito;
				
			SELECT
					nombretarjeta
				INTO
					cNombreTarjeta
			FROM intercard:"informix".solicitudtarjeta
				WHERE numcliente = pNumCte
				AND numcuenta = pNumCredito;
					
			LET cNombreTarjeta = TRIM(NVL(cNombreTarjeta, ""));
					
			SELECT
					nombre1, apell_paterno
				INTO
					cNombre, cApellidoPat
			FROM bdinteg: "informix".si_cliente
				WHERE empresa = pEmpresa
				AND numcte = pNumCte;
					
			LET cNombre = TRIM(NVL(cNombre, ""));
			LET cApellidoPat = TRIM(NVL(cApellidoPat, ""));
			
			SELECT
					tipo_tarjeta, expiracion
				INTO
					cTipoTarjeta, dFechaExp
			FROM "informix".sd_tarjeta
				WHERE empresa = pEmpresa
				AND num_credito = pNumCredito
				AND num_tarjeta = pNumTarPlat
				AND numcte = pNumCte;
					
			IF pSucursal = '9999' THEN
				FOREACH
					SELECT LIMIT 1
							numeroextcalle, numerocalle, numerocolonia, ciudad, numerociudad, estado
						INTO
							iNumeroExtCalle, iNumCalle, iNumColonia, cCiudad, cNumCiudad, cNumEstado
					FROM bdinteg: "informix".si_direcciones_actual
						WHERE numcte = pNumCte
						AND tipo_dir = 1
						ORDER BY secuencia DESC
						
					SELECT
							nombrezona
						INTO
							cColonia 
					  FROM bdinteg: "informix".si_catzonas
					 WHERE numerociudad = cNumCiudad 
					   and numerocolonia  = iNumColonia;

					SELECT
							nombrecalle
						INTO
							cCalle
					  FROM bdinteg: "informix".si_catcalles
					 WHERE numerocalle = iNumCalle;
						
					SELECT
							nombre
						INTO
							cNombreEstado
					  FROM bdinteg: "informix".si_estados
					 WHERE estado = cNumEstado;
					
					SELECT 
							nombre
						INTO
							cNombreCiudad
					  FROM bdinteg: "informix".si_ciudades
					 WHERE estado = cNumEstado 
					   AND ciudad = cCiudad;
						
					LET cDireccionRecepcion = TRIM(cCalle) || ' ' || iNumeroExtCalle || ', ' || TRIM(cColonia) || ', ' || TRIM(cNombreCiudad) || ', ' || TRIM(cNombreEstado);
				END FOREACH;
			ELSE
				SELECT 
						direccion1, direccion2, ciudad, estado
					INTO
						cDireccion1, cDireccion2, cNumCiudad, cNumEstado
					FROM bdinteg: "informix".si_sucursales
					WHERE sucursal = pSucursal
					AND empresa = pEmpresa
					AND tpo_sucursal = 'S';
					
				SELECT
						nombre
					INTO
						cNombreEstado
				  FROM bdinteg: "informix".si_estados
				 WHERE estado = cNumEstado;
				
				LET cNombreEstado = TRIM(NVL(cNombreEstado, ""));
				
				SELECT 
						nombre
					INTO
						cNombreCiudad
				  FROM bdinteg: "informix".si_ciudades
				 WHERE estado = cNumEstado 
				   AND ciudad = cNumCiudad;
				   
				  LET cNombreCiudad = TRIM(NVL(cNombreCiudad, ""));
					
				LET cDireccionRecepcion = TRIM(cDireccion1) || ', ' || TRIM(cDireccion2) || ', ' || TRIM(cNombreCiudad) || ', ' || TRIM(cNombreEstado);
			END IF;
			
			INSERT INTO "informix".sd_info_layout_ppass (id_reg, pan, miembro_desde, nombrecompleto, nombre_cte, apellido_cte, numcte, fecha_exp, sucursal, direccion, tipo, estatus_layout, destino, fecha_insert, usuario_modif)
			VALUES (iId_Reg, pNumTarPPassNue, dFechaAperturaCred, cNombreTarjeta, cNombre, cApellidoPat, pNumCte, dFechaExp, pSucursal, cDireccionRecepcion, cTipoTarjeta, pEstatusLayout, pDestino, CURRENT, 'informix');
			
			IF dbinfo("sqlca.sqlerrd2") > 0 THEN
				IF TRIM(pDestino) = "C" THEN
					UPDATE sd_tarjeta_ppass
						SET numtarjeta_ppass = pNumTarPPassNue, status_tar = 'A', fecha_modif = CURRENT
						WHERE numcte = pNumCte
						AND numtarjeta_ppass = pNumTarPPassAnt;
				ELSE
					UPDATE sd_tarjeta_ppass
						SET numtarjeta_ppass = pNumTarPPassNue, status_tar = 'S', fecha_modif = CURRENT
						WHERE numcte = pNumCte
						AND numtarjeta_ppass = pNumTarPPassAnt;
				END IF;
			ELSE
				LET cCodRet = "000002";
			END IF;
					
		ELSE
			LET cCodRet = "000001";
		END IF;
	END IF;
	
	IF dbinfo("sqlca.sqlerrd2") = 0 AND cCodRet = '000000' THEN
		LET cCodRet = "000002";
	END IF;

	IF cCodRet <> "000000" OR pOpcion = 2 THEN
		RETURN TRIM(NVL(cCodRet,'')), TRIM(NVL(cNumeroSucursal,'')), TRIM(NVL(cNombreSucursal,'')), TRIM(NVL(cDireccionSucursal,'')),
		TRIM(NVL(cColoniaSucursal,'')), TRIM(NVL(cEstadoSucursal,''));
	END IF;

END;
END PROCEDURE
DOCUMENT
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2019-11-18',
'DescripciÃ³n: Se genera Procedimiento Almacenado (SP) para realizar la funcionalidad de reposiciÃ³n de tarjetas Priority Pass',
'SolicitÃ³: Rodolfo Gomez Hernandez',
'Folio: 639',
'RQM 10 1063 Priority Pass Bancoppel Analisis Tecnico',
'Autor: 97879606 AdriÃ¡n Eduardo LizÃ¡rraga CÃ¡zares',
'BD: bdicred',
'Fecha: 2020-02-13',
'DescripciÃ³n: Se modifica procedimiento a peticiÃ³n del Cliente para que la tarjeta PPass quede activa cuando el Cliente la solicite',
'			  a domicilio, ademÃ¡s, se le agrega el campo Estado a la direcciÃ³n de la sucursal.',
'SolicitÃ³: Rodolfo Gomez Hernandez';

CREATE PROCEDURE "informix".sp_rep_cartera_activa_clon(pEmpresa char(3))
returning 
          CHAR(06) AS resultado,
          CHAR(80) AS mensaje;
--************************ Definicion de variables *****************************
    define iSql_err                  integer;
    define cSql                      char(2080);
    define dPrimerDiaMes             date;
    define dUltimoDiaMesAnterior             date;
    define cNumCte                   char(20);
    define cNum_Credito              char(20);
    define cCreditoREES              char(20);
    define cStatus_CreditoREES       char(20);
    define cStatus_Credito           char(15);
    define cHit                      char(6);
    define dFecha_Nac                date;
    define cRfc                      char(13);
    define cSexo                     char(10);
    define cEstado_Civil             char(15);
    define cEmail                    char(70);
    define cNumeroEstado             char(2);
    define cNombreEstado             char(30);
    define sNumeroCiudad, sNumeroCiudadCpl smallint;
    define cNombreCiudad, cNombreCiudadCpl char(30);
    define iNumeroColonia            integer; 
    define cMunicipioZona            char(27);   
    define cTelefono1                char(13);           
    define cTelefono2                char(13);      
    define cTelefono3                char(13);     
    define cExtension                char(5);       
    define mIngreso_Mensual          money;     
    define cSucursal, cNum_Producto  char(4);    
    define cTiempo_Ocupacion_Act     char(50);     
    define dUltima_Disposicion       date;                        
    define dUltimo_Movimiento        date;                         
    define dUltimo_Vencido           date;               
    define cTipo_Ult_Mov             char(3);
    define dultimo_pago              date;
    define dSaldo_Actual             decimal(18,2);     
    define dSaldo_Vencido            decimal(18,2);     
    define dSdo_Capital              decimal(18,2);     
    define dMonto_Vencido            decimal(18,2);     
    define dMto_Venc_Trasp           decimal(18,2);     
    define dCap_Tras_No_Venci        decimal(18,2);     
    define dSaldo_Cierre             decimal(18,2);     
    define dMeses_Vencidos           decimal(18,2);     
    define cNum_Tarjeta              char(20);           
    define cNumCte_Ref               char(20);            
    define dFecha_Apertura           date;     
    define dSituacion_Pago           decimal(5,2);     
    define sMeses_Historia           smallint;
    define dfecha_hoy                date;
    define cMensajeRet               char(80);
    define cCodRet,vvcCod_ret        char(6); 
	define cCod_ret2				 char(6);
    define cNum_dia                  char(02);
    define cNum_mes                  char(02);
    define cNum_anio,cProceso        char(04);
    define dFechaVtaRees             date;
    define dFecha                    date;
    define contador_commit INTEGER;
    define sCommit      SMALLINT;
    define actualiza_esta integer;
    define cTipoReporte             char(02);
    define dUltDisp_atm             date;
    define dUltDisp_pos             date;
    define dUltDisp_vnt             date;
    define vCurrent                 char(25);
    define vdia                     char(10);
    define vhora                    char(8);
    define vHora3                   char(22); 
    define cPaso                    char(01); 
	define cMotivo					char(5);
	
	DEFINE dEvaluacion1        decimal(18,2);
	DEFINE dEvaluacion2         decimal(18,2);
	DEFINE dEvaluacion3         decimal(18,2);
	DEFINE dEvaluacion4         decimal(18,2);
	DEFINE dEvaluacion5         decimal(18,2);
	DEFINE cStatus_Ini CHAR(2);
	DEFINE cRevisado CHAR(2);
	DEFINE cIdbox smallint;
	DEFINE cIfe CHAR(2);
	DEFINE iNumPagos			INTEGER;
	DEFINE dMontoPagos  		decimal(18,2);
	DEFINE cGrupo				CHAR(2);
	DEFINE sFlag2creditoicc		SMALLINT;
	
	-- RQM 09 476 - 2 ADENDUM 
	DEFINE dLineaOrigen			decimal(18,2);
	DEFINE dLineaActual			decimal(18,2);
	DEFINE iSolicitudOS			integer;
	DEFINE iSolicitudOS_Gpo5	integer;
	DEFINE iSolicitudOS_P		integer;
	DEFINE iMarcaOS				integer;
	DEFINE cTipoFac				char(1);
     
	SET DEBUG FILE TO "/tmp/sp_rep_cartera_activa_clon.out";
	TRACE ON;
	
    let iSql_err = 0;
    let cSql    = '';
    let cNumCte = '';
    let	cNum_Credito = '';
    let cNum_Credito = '';
    let cCreditoREES = '';
    let	cStatus_Credito	= '';
    let cHit = '';
    let dFecha_Nac = DATE(1);
    let cRfc = '';
    let cSexo ='';
    let cEstado_Civil = '';
    let cEmail = '';
    let cNumeroEstado = '';
    let cNombreEstado = '';
    let sNumeroCiudad = 0;
    let cNombreCiudad = '';
    let sNumeroCiudadCpl = 0;
    let cNombreCiudadCpl = '';
    let iNumeroColonia = 0;
    let cMunicipioZona = '';
    let cTelefono1 = '';
    let cTelefono2 = '';
    let cTelefono3 = '';
    let cExtension = '';
    let cSucursal = '';
    let cTiempo_Ocupacion_Act = '';
    let dUltima_Disposicion = DATE(1);
    let dUltimo_Movimiento = DATE(1);
    let dUltimo_Vencido = ' ';
    let cTipo_Ult_Mov = '';
    let dUltimo_pago = DATE(1);
    let dSaldo_Actual = 0.0;
    let dSaldo_Vencido = 0.0;
    let dSdo_Capital = 0.0;
    let dMonto_Vencido = 0.0;
    let dMto_Venc_Trasp = 0.0;
    let dCap_Tras_No_Venci = 0.0;
    let dSaldo_Cierre = 0.0;
    let dMeses_Vencidos = 0.0;
    let cNum_Tarjeta = '';
    let cNumCte_Ref = '';
    let dFecha_Apertura = DATE(1);
    let dSituacion_Pago = 0.0;
    let sMeses_Historia = 0;
    let dFecha_hoy = DATE(1);
    let dPrimerDiaMes = DATE(1);
    let dUltimoDiaMesAnterior = DATE(1);
    let cMensajeRet= 'El reporte de CARTERA ACTIVA se realizo correctamente';
    let cCodRet    = '000000';
	let cCod_ret2  = '000000';
    let cNum_dia   = '';
    let cNum_mes   = '';
    let cNum_anio  = '';
    let dFechaVtaRees  = DATE(1);
    let dFecha         = DATE(1);
    let contador_commit = 0;
    let sCommit         = 0;
    let actualiza_esta = 0;
    let cTipoReporte = '';
    let cProceso = '0033';
    let vvcCod_ret = '';
    let mIngreso_Mensual = 0;
    let dUltDisp_atm = date(1); let dUltDisp_pos = date(1); let dUltDisp_vnt = date(1);
    let vCurrent = ''; let vdia = '';   let vhora = '';  let vHora3 = '';
    let cPaso = '';  LET cNum_Producto = '';
	let cMotivo = '';
	
	let dEvaluacion1        =0;
	let dEvaluacion2        =0;
	let dEvaluacion3        =0;
	let dEvaluacion4        =0;
	let dEvaluacion5        =0;
	LET cStatus_Ini = "";
	LET cRevisado = "";
	LET cIdbox = 0;
	LET cIfe = "";
	LET iNumPagos			= 0;
	LET dMontoPagos			= 0;
	LET cGrupo				= '';
	LET sFlag2creditoicc	= 0;
	
	-- RQM 09 476 - 2 ADENDUM 
	LET dLineaOrigen		= 0.00;
	LET dLineaActual		= 0.00;
	LET iSolicitudOS		= 0;
	LET iSolicitudOS_Gpo5	= 0;
	LET iSolicitudOS_P		= 0;
	LET iMarcaOS			= 0;
	LET cTipoFac			= '';
	
--**************************** Control de errores ******************************
    begin
    on exception set iSql_err
		if iSql_err <> 0 then
           let cCodRet= iSql_err;
           let cMensajeRet= 'ERROR en la ejecucion del reporte de CARTERA ACTIVA' || cNum_Credito;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '02') returning cCod_ret2;
--           SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
           return cCodRet,cMensajeRet;
		end if;
	end exception;


    SELECT today, current INTO vdia, vCurrent 
      FROM systables
      where tabid=1;

      LET vhora = vCurrent[12,19];      


--*************************** Programa principal *******************************
    set isolation to dirty read;
    set lock mode to wait 3;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '01') returning cCod_ret2;	
	
    select fecha_hoy, pri_dia_mes into dFecha_hoy,dPrimerDiaMes from bdicred:sd_fechas where empresa = pEmpresa;

--temporal para pruebas
   --let dFecha_hoy = mdy('11','01','2018');
   --let dPrimerDiaMes = mdy('11','01','2018');
--temporal para pruebas

    let dUltimoDiaMesAnterior = dPrimerDiaMes - 1 units day;
    let dPrimerDiaMes = dPrimerDiaMes - 1 units month;								

    let cNum_dia  = lpad(DAY(dUltimoDiaMesAnterior),2,'0');
    let cNum_mes  = lpad(MONTH(dUltimoDiaMesAnterior),2,'0');
    let cNum_anio = lpad(YEAR(dUltimoDiaMesAnterior),4,'0');
 
/* 
    IF NOT EXISTS (select idxname from sysindices where idxname='idx_numcredito_repcartactiva') THEN
       CREATE INDEX idx_numcredito_repcartactiva on bdicred:"informix".sd_rep_cartera_activa(fecha,tipo_reporte,num_credito);
    END IF;
*/
    select valor into cPaso from bdicred:sd_param where cod_param = '079' and empresa = pEmpresa;

    select first 1 fecha into dFecha from bdicred:"informix".sd_rep_cartera_activa WHERE fecha > DATE(1);

    IF dFecha != dUltimoDiaMesAnterior THEN
        truncate table "informix".sd_rep_cartera_activa;
    END IF;
    
IF cPaso = '1' THEN
    select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcont 
     where fecha = dUltimoDiaMesAnterior 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
	   and empresa = pEmpresa 
       and campo_trab3 <> 'BAJA'
     into temp paso_maecredcont with no log; 

    CREATE INDEX idx_paso_maecredcont on paso_maecredcont (fecha, empresa, num_credito); 
    
	
    FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, nvl(h.grupo,'')
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo
         from paso_maecredcont a
              join bdicred:sd_maesdoscont i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
				
           
           BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos,linea_origen,linea_actual,marca_os,tipo_facturacion)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos,dLineaOrigen,dLineaActual,iMarcaOS,cTipoFac);
          COMMIT WORK;
    
    END FOREACH;
	---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
	
	select 'CA' tipo_reporte, fecha, empresa, num_credito, numcte, sucursal, status_cred, fecha_apertura, num_producto
     from bdicred:sd_maecredcontcrd
     where fecha = dUltimoDiaMesAnterior and empresa = pEmpresa 
       and num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
       and campo_trab3 <> 'BAJA'
	   and num_producto ='6900'
     into temp paso_maecredcontcrd with no log; 

    CREATE INDEX idx_paso_maecredcontcrd on paso_maecredcontcrd (fecha, empresa, num_credito); 
    UPDATE statistics medium FOR TABLE "informix".paso_maecredcontcrd;
	
	
	
	 FOREACH WITH HOLD
        select a.tipo_reporte, a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, 
             a.sucursal,
             0 saldo_actual, 
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido, 
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_cierre, 
             i.mto_fin_ven_trasp meses_vencidos, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto, h.grupo
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto, cGrupo
         from paso_maecredcontcrd a
              join bdicred:sd_maesdoscontcrd i on i.fecha = a.fecha and i.empresa = a.empresa and i.num_credito = a.num_credito
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
    
           
           BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo, flag2credito, grupo, num_pagos, monto_pagos)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cMotivo, sFlag2creditoicc, cGrupo, iNumPagos, dMontoPagos);
          COMMIT WORK;
    
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='2'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '2';
END IF;

IF cPaso = '2' THEN
    FOREACH WITH HOLD
        select  'CV' tipo_reporte,a.numcte, a.num_credito,
             (case when a.status_cred = 'AA' then 'VIGENTE' else
              case when a.status_cred = 'BA' then 'TRANSITORIO' else 
              case when a.status_cred = 'BT' then 'VENCIDO' else
              case when a.status_cred = 'CV' then 'VENDIDO' else
              case when a.status_cred = 'FC' then 'REESTRUCTURADO' else 'LIQUIDADO' end end end end end) estatus_credito,
             (case when h.evalua_cc = '1' then 'Hit' else
              case when h.evalua_cc = '0' then 'Hit' else
              case when h.evalua_cc = '2' then 'Hit' else
              case when h.evalua_cc = '4' then 'Hit' else
              case when h.evalua_cc = 'X' then 'No Hit' else
              case when h.evalua_cc = '' then 'No Hit' else 'No Hit' end end end end end end) hit,
             h.ingreso_mensual, a.sucursal,
             i.sdo_capital + i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_actual,
             i.monto_vencido + i.mto_venc_trasp + i.cap_tras_no_venci saldo_vencido,
             i.sdo_capital, i.monto_vencido, i.mto_venc_trasp, i.cap_tras_no_venci, 0 saldo_cierre,
             i.mto_fin_ven_trasp meses_vencidos, --j.num_tarjeta, 
             a.fecha_apertura, h.situacion_pago, h.meses_historia, a.num_producto
         INTO cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cHit, mIngreso_Mensual, cSucursal, dSaldo_Actual, dSaldo_Vencido, dSdo_Capital,  
              dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, dFecha_Apertura, dSituacion_Pago, sMeses_Historia, cNum_Producto
         from bdicred:sd_maecred_vendida a
              join bdicred:sd_maesdos_vendida i on (a.fecha = i.fecha and a.empresa = i.empresa and a.num_credito = i.num_credito)
              left outer join bdisolic:ss_resum_scor_fin h on (h.empresa = a.empresa and h.num_solicitud = a.num_credito)
        where a.fecha between dPrimerDiaMes and dUltimoDiaMesAnterior and a.empresa = pEmpresa and a.num_credito>=''
          and a.num_credito in (select num_credito from bdicred:"informix".sd_maecred where empresa=pEmpresa and num_credito=a.num_credito and status_cred='CV') 
          and a.num_credito not in (select num_credito from bdicred:sd_rep_cartera_activa)
			
          BEGIN WORK;
               insert into "informix".sd_rep_cartera_activa (fecha, tipo_reporte, numcte, num_credito, estatus_credito, num_producto, hit, fecha_nac, rfc, sexo, estado_civil, 
                  email, numeroestado, nombreestado, numerociudad, nombreciudad, numciudad_cpl, nombreciudad_cpl, numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension, 
                  ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion, ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido,
                  sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta, numcte_ref, fecha_apertura, situacion_pago,
                  meses_historia, motivo)
               values (dUltimoDiaMesAnterior, cTipoReporte, cNumCte, cNum_Credito, cStatus_Credito, cNum_Producto, cHit, dFecha_Nac, cRfc, cSexo, cEstado_Civil,
                  cEmail, cNumeroEstado, cNombreEstado, sNumeroCiudad, cNombreCiudad, sNumeroCiudadCpl, cNombreCiudadCpl, iNumeroColonia, cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension,
                  mIngreso_Mensual, cSucursal, cTiempo_Ocupacion_Act, dUltima_Disposicion, dUltimo_Movimiento, dUltimo_Vencido, cTipo_Ult_Mov, dSaldo_Actual, 
                  dSaldo_Vencido, dSdo_Capital, dMonto_Vencido, dMto_Venc_Trasp, dCap_Tras_No_Venci, dSaldo_Cierre, dMeses_Vencidos, cNum_Tarjeta, cNumCte_Ref, 
                  dFecha_Apertura, dSituacion_Pago, sMeses_Historia,cMotivo);
          COMMIT WORK;
  
    END FOREACH;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='3'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '3';
END IF;

IF cPaso = '3' THEN
    UPDATE statistics medium FOR TABLE "informix".sd_rep_cartera_activa;

    FOREACH WITH HOLD

--        select {+INDEX(bdicred:sd_rep_cartera_activa sd_repcartera_activa1)} tipo_reporte, numcte, num_credito 
        select tipo_reporte, numcte, num_credito 
          INTO cTipoReporte, cNumCte, cNum_Credito  
	        from "informix".sd_rep_cartera_activa 
           where fecha = dUltimoDiaMesAnterior
             and (sexo is null or sexo = '')
         
         select nvl(a.correo_elec,'')  into cEmail 
           from bdinteg:si_correos a
          where a.empresa = pEmpresa
            and a.numcte = cNumCte
            and a.secuencia = (select max(secuencia) from bdinteg:si_correos where empresa = a.empresa and numcte = a.numcte); 

         select c.fecha_nac, b.rfc, (case when c.sexo = 'M' then 'MASCULINO' else 'FEMENINO' end) sexo, 
               (case when c.estado_civil = 'C' then 'Casado' else
                case when c.estado_civil = 'D' then 'Divorciado' else
                case when c.estado_civil = 'S' then 'Soltero' else
                case when c.estado_civil = 'U' then 'Union Libre' else 'Viudo' end end end end) estado_civil,
                b.numcte_ref
             into dFecha_Nac, cRfc, cSexo, cEstado_Civil, cNumCte_Ref
            from bdinteg:si_cliente b 
            left outer join bdinteg:si_ctepf c on (c.numcte = b.numcte)
            where b.numcte = cNumCte;

         select a.num_tarjeta into cNum_Tarjeta
           from bdicred:sd_tarjeta a
          where a.empresa = pEmpresa 
            and a.num_credito = cNum_Credito
            and a.tipo_tarjeta = 'T' and secuencia = (select max(secuencia) from bdicred:sd_tarjeta 
    	                                                 where empresa = a.empresa and num_credito = a.num_credito and tipo_tarjeta = 'T');

         select limit 1 d1.estado, e.nombre, d1.numerociudad CdCpl, catcd.nombreciudad NomCdCpl, d1.ciudad NumCdBcpl,cds.nombre NomCdBcpl,d1.numerocolonia, g.municipiozona,
                nvl(tel1.telefono,''), nvl(tel2.telefono,''), nvl(tel3.telefono,''), nvl(tel3.extension,'')
           into cNumeroEstado, cNombreEstado, sNumeroCiudadCpl, cNombreCiudadCpl, sNumeroCiudad, cNombreCiudad, iNumeroColonia,
                cMunicipioZona, cTelefono1, cTelefono2, cTelefono3, cExtension 
           from bdinteg:si_direcciones_actual d1 
                left outer join bdinteg:si_direcciones_actual d2 on (d2.numcte = d1.numcte and d2.tipo_dir = '2')
                left outer join bdinteg:si_estados e on (e.estado = d1.estado)
                left outer join bdinteg:si_catciudades catcd on (catcd.numerociudad = d1.numerociudad )
                left outer join bdinteg:si_ciudades cds on (cds.estado = d1.estado and cds.ciudad_coppel = d1.numerociudad and cds.ciudad = d1.ciudad)
                left outer join bdinteg:si_catzonas g on (g.numerociudad = d1.numerociudad and g.numerocolonia = d1.numerocolonia)
                Left outer join bdinteg:si_telefonos_actual tel1 on tel1.numcte= d1.numcte 
                     and tel1.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 1 and cofetel ='V')
                     and tel1.tipo_tel = 1 and tel1.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel2 on tel2.numcte= d1.numcte 
                     and tel2.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 2 and cofetel ='V')
                     and tel2.tipo_tel = 2 and tel2.cofetel ='V'
                left outer join bdinteg:si_telefonos_actual tel3 on tel3.numcte= d1.numcte 
                     and tel3.secuencia = (select max(secuencia) from bdinteg:si_telefonos_actual where numcte = d1.numcte and tipo_tel = 3 and cofetel ='V')
                     and tel3.tipo_tel = 3 and tel3.cofetel ='V'    
          where d1.numcte = cNumCte
            and d1.tipo_dir = '1';
 /*
     select fecha_ult_pago,fecha_vencto into dUltimo_pago,dUltimo_Vencido from bdicred:sd_maecredanexo where empresa = pEmpresa and num_credito = cNum_Credito ;

     if dUltimo_pago is null then let dUltimo_pago = ''; end if;
     if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
 */
    -- obtener la ocupacion actual
         select sel.descripcion into cTiempo_Ocupacion_Act from bdisolic:ss_detalle_scoring  dsc 
             inner join bdisolic:ss_scoring_grupo sgr on sgr.empresa=dsc.empresa and sgr.grupo=dsc.grupo and sgr.seccion=dsc.seccion
             inner join bdisolic:ss_scoring_element sel on sel.empresa=dsc.empresa and sel.grupo=dsc.grupo and sel.elemento=dsc.elemento 
                        and sel.seccion=dsc.seccion
          where dsc.empresa = pEmpresa and dsc.grupo = '8' and dsc.seccion = '2' and dsc.num_solicitud = cNum_Credito 
            and sel.elemento = (select max(elemento) 
                                  from bdisolic:ss_detalle_scoring 
                                 where empresa= dsc.empresa and grupo = dsc.grupo and seccion = dsc.seccion and num_solicitud = dsc.num_solicitud); 
/*
-- obtener la ultima disposicion
    select {+INDEX(bdicred:sd_movhis inx_movhis)} nvl(max(fecha_mov),dFecha_Apertura) into dUltima_Disposicion 
      from bdicred:sd_movhis 
     where empresa = pEmpresa 
       AND fecha_mov >= dFecha_Apertura 
       AND fecha_mov <= dUltimoDiaMesAnterior
       and num_credito = cNum_Credito 
       and codigo_fun = '002' 
       and codigo_ref in (50,60,30,40,41,42,61,62,63,64)
       and reversado = 'N';
*/
		---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		IF SUBSTR(cNum_Credito,1,2) = '69' THEN
			let dUltDisp_atm = ''; 
			let dUltDisp_pos = ''; 
			let dUltDisp_vnt = ''; 
			let dUltimo_pago = ''; 
			let dUltimo_Vencido = ''; 
		ELSE
         SELECT nvl(atm_disp_fecha_h,''), nvl(pos_disp_fecha_h,''), nvl(vnt_disp_fecha_h,''), nvl(fecha_ultimo_pago_h,''), 
               nvl(fecha_vencido,'')
          INTO dUltDisp_atm, dUltDisp_pos, dUltDisp_vnt, dUltimo_pago, dUltimo_Vencido
          FROM bdicred:sd_indicador_cred
         WHERE empresa = pEmpresa 
           AND num_credito = cNum_Credito;
		END IF;
		
        if dUltDisp_atm is null then let dUltDisp_atm = ''; end if;
        if dUltDisp_pos is null then let dUltDisp_pos = ''; end if;
        if dUltDisp_vnt is null then let dUltDisp_vnt = ''; end if;
        if dUltimo_pago is null then let dUltimo_pago = ''; end if;
        if dUltimo_Vencido is null then let dUltimo_Vencido = ''; end if;
       
        IF (dUltDisp_atm > dUltDisp_pos) THEN
            IF (dUltDisp_atm >= dUltDisp_vnt) THEN
               LET dUltima_Disposicion = dUltDisp_atm;
            ELSE
               LET dUltima_Disposicion = dUltDisp_vnt;
            END IF;
        ELIF (dUltDisp_atm = dUltDisp_pos) THEN    
            IF (dUltDisp_pos >= dUltDisp_vnt) THEN
                LET dUltima_Disposicion = dUltDisp_pos;
            ELSE
                LET dUltima_Disposicion = dUltDisp_vnt;
            END IF;
        END IF;


    -- obtener ultimo pago
        if(dUltima_Disposicion > dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        elif (dUltimo_pago > dUltima_Disposicion) then
            let dUltimo_Movimiento = dUltimo_pago;
            let cTipo_Ult_Mov = '052';
        elif(dUltima_Disposicion = dUltimo_pago) then
            let dUltimo_Movimiento = dUltima_Disposicion;
            let cTipo_Ult_Mov = '002';
        end if;
		
	-- obtener causa solicitud
		
		select limit 1 nvl(a.causa_solicitud,'') into cMotivo
		from bdisolic:ss_autorizacion a
		where a.empresa = pEmpresa
		and a.num_solicitud = cNum_Credito
		and fecha_hora = (select max(fecha_hora) from bdisolic:ss_autorizacion where num_solicitud = cNum_Credito and status_solicitud = 'AT')
		and a.status_solicitud = 'AT';
			
	 ---Se Agrega bloque de credisoluciones (6900) RQM 09 212-2  Adendum Reporte Cartera Activa JMAH
		SELECT
				nvl(SUM(decode(seccion, '1', nvl(evaluacion,0), 0)),0) AS seccion1,
				nvl(SUM(decode(seccion, '2', nvl(evaluacion,0), 0)),0) AS seccion2,
				nvl(SUM(decode(seccion, '3', nvl(evaluacion,0), 0)),0) AS seccion3,
				nvl(SUM(decode(seccion, '4', nvl(evaluacion,0), 0)),0) AS seccion4,
				nvl(SUM(decode(seccion, '5', nvl(evaluacion,0), 0)),0) AS seccion5                        
		INTO dEvaluacion1, dEvaluacion2, dEvaluacion3, dEvaluacion4,dEvaluacion5
		FROM bdisolic:ss_resumen_scoring
		WHERE empresa= '001'
		AND seccion in ('1', '2','3', '4','5')
		AND num_solicitud = cNum_Credito;
		
					-- MODIFICACION REPORTE RQM 09 459-2 (INICIO)
			SELECT status_ini
			 INTO cStatus_Ini
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cStatus_Ini IS NULL THEN
			   LET cStatus_Ini = ' ';
			END IF;
			
			SELECT CASE WHEN revisado = 'N' THEN 'C'ELSE 'R' END
			 INTO cRevisado
			 FROM bdisolic:"informix".ss_solicitudes_mc
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 
			IF cRevisado IS NULL THEN
			   LET cRevisado = ' ';
			END IF;
			
			SELECT COUNT(*) 
			 INTO cIdbox
			 FROM bdisolic:"informix".ss_solicitudes_mc a
			 RIGHT OUTER JOIN bdinteg:si_bitacora_ife b on ( a.numcte = b.numcte and b.fecha = (select max(fecha) from bdinteg:si_bitacora_ife where numcte=a.numcte))   
			WHERE empresa = '001'
			 AND num_solicitud = cNum_Credito;
			 			
			IF cIdbox >= 1 THEN 
			   LET cIFE = 'Si';
			ELSE   
			   LET cIFE = 'No'; 
			END IF;	
			-- MODIFICACION REPORTE RQM 09 459-2 (FIN)				
		
			SELECT nvl(flag2creditoicc,0) INTO sFlag2creditoicc 
			FROM bdisolic:ss_revision_determinacion
			WHERE empresa = '001'
			  AND num_solicitud = cNum_Credito;

         SELECT nvl(num_pagos,0),nvl(monto_pagos,0)
          INTO iNumPagos, dMontoPagos
          FROM bdicred:sd_indicador_cred_hist
         WHERE empresa = pEmpresa 
		   AND fecha = dUltimoDiaMesAnterior
           AND num_credito = cNum_Credito;
		   
			-- RQM 09 476 - 2 ADENDUM 
			SELECT monto_solicitado INTO dLineaOrigen FROM bdisolic:ss_solicitudes	
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito; 

			SELECT monto_otorgado INTO dLineaActual FROM bdicred:sd_maesdos 
			WHERE empresa=pEmpresa AND num_credito=cNum_Credito; 
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS FROM bdisolic:ss_solicitud_os
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			
			SELECT COUNT(num_solicitud) INTO iSolicitudOS_Gpo5 FROM bdisolic:bitacora_os_gpo5 
			WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito;
			  
			IF iSolicitudOS > 0 THEN 
			
				LET iMarcaOS = 1;		-- ADD
				
				SELECT COUNT(num_solicitud) INTO iSolicitudOS_P FROM bdisolic:ss_solicitud_os
				WHERE empresa=pEmpresa AND num_solicitud=cNum_Credito AND status='P';
				
				IF iSolicitudOS_P > 0 THEN
					LET iMarcaOS = 1;
				ELSE
					IF iSolicitudOS_Gpo5 >0 THEN
						LET iMarcaOS = 2;
					ELSE
						LET iMarcaOS = 0;
					END IF;	
				END IF;
			ELSE	
				IF iSolicitudOS_Gpo5 >0 THEN
					LET iMarcaOS = 2;
				ELSE
					LET iMarcaOS = 0;
				END IF;	
			END IF;
			
			if dUltDisp_atm is null or dUltDisp_atm = '' then let dUltDisp_atm = date(1); end if;
			if dUltDisp_pos is null or dUltDisp_pos = '' then let dUltDisp_pos = date(1); end if;
			if dUltDisp_vnt is null or dUltDisp_vnt = '' then let dUltDisp_vnt = date(1); end if;
			
			--	Indicaremos "D" si el cliente durante el mes realizÃÂÃÂÃÂÃÂ³ SOLO disposiciones en efectivo.((ATM OR VNT)OR (ATM AND VNT))AND NOT POS
			IF ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR  (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) OR
				 ((dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior)))AND	
				 (dUltDisp_pos<dPrimerDiaMes OR dUltDisp_pos>dUltimoDiaMesAnterior)THEN
					LET cTipoFac = 'D';
			-- Indicaremos "C" si el cliente durante el mes realizÃÂÃÂÃÂÃÂ³ SOLO compras en terminal punto de venta.
			--	((POS)AND(ATM<PriDiaMes OR ATM>UltDiaMes) or AMBAS)AND (VNT<PriDiaMes OR VNT>UltDiaMes) or AMBAS)
			ELIF (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND 
				 (dUltDisp_atm<dPrimerDiaMes OR dUltDisp_atm>dUltimoDiaMesAnterior) AND 
				 (dUltDisp_vnt<dPrimerDiaMes OR dUltDisp_vnt>dUltimoDiaMesAnterior ) THEN
					LET cTipoFac = 'C';
			--	Indicaremos "M" si el cliente durante el mes realizÃÂÃÂÃÂÃÂ³ compras y disposiciones (cajero y/o ventanilla) en efectivo.(ATM AND VNT AND POS)
			ELIF (dUltDisp_atm BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND (dUltDisp_vnt BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) AND
				   (dUltDisp_pos BETWEEN dPrimerDiaMes AND dUltimoDiaMesAnterior) THEN
						LET cTipoFac = 'M';
			ELSE 
				LET cTipoFac = ' ';
			END IF;
						
        BEGIN WORK;
            UPDATE "informix".sd_rep_cartera_activa
               SET  fecha_nac = dFecha_Nac, rfc = cRfc, sexo = cSexo, estado_civil = cEstado_Civil, email = cEmail, numeroestado = cNumeroEstado, 
                    nombreestado = cNombreEstado, numerociudad=sNumeroCiudad, nombreciudad=cNombreCiudad, numciudad_cpl=sNumeroCiudadCpl, nombreciudad_cpl=cNombreCiudadCpl, numerocolonia=iNumeroColonia, 
                    municipiozona = cMunicipioZona, telefono1 = cTelefono1, telefono2 = cTelefono2, telefono3 = cTelefono3, extension = cExtension, 
                    tiempo_ocupacion_act = NVL(cTiempo_Ocupacion_Act,''), ultima_disposicion = dUltima_Disposicion, ultimo_movimiento = dUltimo_Movimiento,
                    ultimo_vencido = dUltimo_Vencido, tipo_ult_mov = cTipo_Ult_Mov, num_tarjeta = NVL(cNum_Tarjeta,''), numcte_ref = cNumCte_Ref, motivo = NVL(cMotivo  ,''),
					bscore = dEvaluacion1, scoreprop= dEvaluacion2, ficoscore = dEvaluacion3, ficoextended = dEvaluacion4,icc =dEvaluacion5,
					status = cStatus_Ini, revisado = cRevisado, ife = cIFE, num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0), flag2credito = nvl(sFlag2creditoicc,0),
					num_pagos = nvl(iNumPagos,0), monto_pagos = nvl(dMontoPagos,0),linea_origen=dLineaOrigen,linea_actual=dLineaActual,marca_os=iMarcaOS,tipo_facturacion=nvl(cTipoFac,'')
             WHERE numcte = cNumCte 
			 AND num_credito = cNum_Credito ;
        COMMIT WORK;
    	
    
        let dFecha_Nac = '';
        let cRfc  = '';
        let cSexo = '';
        let cEstado_Civil = '';
        let cEmail = '';
        let cNumeroEstado = '';
        let cNombreEstado = '';
        let sNumeroCiudad = '';
        let cNombreCiudad  = '';
        let sNumeroCiudadCpl=''; let cNombreCiudadCpl='';
        let iNumeroColonia = '';
        let cMunicipioZona = '';
        let cTelefono1 = '';
        let cTelefono2 = '';
        let cTelefono3 = '';
        let cExtension = '';
        let cTiempo_Ocupacion_Act  = '';
        let dUltima_Disposicion  = '';
        let dUltimo_Movimiento = '';
        let dUltimo_Vencido = '';
        let cTipo_Ult_Mov = '';
        let cNum_Tarjeta  = '';
        let cNumCte_Ref  = '';
		let cMotivo = '';
		let sFlag2creditoicc = 0;
        let contador_commit = contador_commit  + 1;
        let actualiza_esta = actualiza_esta + 1;
		let dLineaOrigen=0;
		let dLineaActual=0;
		let iMarcaOS=0;
   end foreach;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='4'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '4';
END IF;


IF cPaso = '4' THEN
   let sCommit = 0;
--Reporte de cartera activa
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_activa_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select num_producto, numcte, num_credito, estatus_credito, hit, numeroestado, nombreestado, ' ||
       ' numciudad_cpl, nombreciudad_cpl, numerociudad, nombreciudad, ' ||
       ' sucursal, saldo_actual, saldo_vencido, sdo_capital, monto_vencido, mto_venc_trasp, cap_tras_no_venci, ' ||
       ' saldo_cierre, meses_vencidos, fecha_apertura, situacion_pago, meses_historia, motivo, ' ||
	   ' case when (select excluye_validacion from bdisolic:'''||'informix'||'''.ss_revision_determinacion where empresa = '''||'001'||''' and num_solicitud = num_credito)  ' || 
	   ' = 1 then '''||'Excepcion de validacion telefonica por puntaje'||'''  else '''||' '||''' end case , ' ||	 
	   ' bscore , scoreprop, ficoscore , ficoextended ,icc,status , revisado, ife, flag2credito, grupo, num_pagos, monto_pagos,	   ' ||	
	   ' linea_origen,linea_actual,marca_os,tipo_facturacion,ultima_disposicion	'||
       ' from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql';
       /*' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia, flag2credito, grupo, num_pagos, monto_pagos from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre > 0;"' ||
       ' > /resplogifx/archivoscartera/query_cartera_activa.sql'; */
--     ' > query_cartera_activa.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_activa.sql';
--  let cSql = 'dbaccess bdicred query_cartera_activa.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_activa.sql';
--  LET cSql = 'rm query_cartera_activa.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='5'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '5';
END IF;

IF cPaso = '5' THEN
--Reporte de creditos inactivos o con saldo a favor
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_clientes_inactivos_'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte = '''||'CA'||''' and saldo_cierre <= 0;"' ||
       ' > /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--     ' > query_clientes_inactivos.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  let cSql = 'dbaccess bdicred query_clientes_inactivos.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_clientes_inactivos.sql';
--  LET cSql = 'rm query_clientes_inactivos.sql';
    SYSTEM cSql;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='6'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
    LET cPaso = '6';
END IF;

IF cPaso = '6' THEN
--Reporte de cartera vendida
    let cSql = 'echo "Set isolation to dirty read; UNLOAD TO ' || '/resplogifx/archivoscartera/Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
--  let cSql = 'echo "UNLOAD TO ' || 'Rep_cartera_vendida'||cNum_dia||cNum_mes||cNum_anio||'.txt ' ||
    'DELIMITER ' || '''|''' ||
       ' select numcte, num_credito, estatus_credito, hit, fecha_nac, rfc, sexo,' ||
       ' estado_civil, email, numeroestado, nombreestado, numerociudad, nombreciudad,' ||
       ' numerocolonia, municipiozona, telefono1, telefono2, telefono3, extension,' ||
       ' ingreso_mensual, sucursal, tiempo_ocupacion_act, ultima_disposicion,' ||
       ' ultimo_movimiento, ultimo_vencido, tipo_ult_mov, saldo_actual, saldo_vencido, sdo_capital,' || 
       ' monto_vencido, mto_venc_trasp, cap_tras_no_venci, saldo_cierre, meses_vencidos, num_tarjeta,' ||
       ' numcte_ref, fecha_apertura, situacion_pago, meses_historia from sd_rep_cartera_activa where tipo_reporte ='''||'CV'||''';"' ||
       ' > /resplogifx/archivoscartera/query_cartera_vendida.sql';
--     ' > query_cartera_vendida.sql';
    system cSql;
    let cSql='';
    let cSql = 'dbaccess bdicred /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  let cSql = 'dbaccess bdicred query_cartera_vendida.sql';
    system cSql;
    LET cSql = 'rm /resplogifx/archivoscartera/query_cartera_vendida.sql';
--  LET cSql = 'rm query_cartera_vendida.sql';
    SYSTEM cSql;
END IF;

    BEGIN WORK;
    UPDATE bdicred:sd_param 
       SET valor='1'
     WHERE empresa = pEmpresa 
       AND cod_param = '079';
    COMMIT WORK;
--    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora3 from sysmaster:sysshmvals;
	CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa, cProceso, cCodRet, cMensajeRet, '03') returning cCod_ret2;
    return cCodRet,cMensajeRet;
end;
end procedure;