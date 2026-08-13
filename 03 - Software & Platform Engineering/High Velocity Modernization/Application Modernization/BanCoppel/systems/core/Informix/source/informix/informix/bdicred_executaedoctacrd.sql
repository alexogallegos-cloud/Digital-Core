CREATE PROCEDURE "informix".executaedoctacrd(pempresa  CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);

DEFINE v_cod_ret	    CHAR(5);
DEFINE sql_err          INTEGER;
DEFINE v_cuantos		INTEGER;
DEFINE vStProc         	CHAR(1);
DEFINE v_nameProcess	CHAR(20);

LET v_cuantos = 0;

--SET DEBUG FILE TO "executaedoctacrd.out";
--TRACE ON;

BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

			UPDATE "informix".sd_contproc
			   SET status_proc = "C",
                   hora_fin    = CURRENT,
                   cod_ret     = v_cod_ret,
			       mensaje     = "Estados de Cuenta de Reestructura Sin Generar"
			 WHERE empresa     = pEmpresa			
			   AND proceso     = v_nameProcess
			   AND fecha       = pfechahoy;
                       
			UPDATE bdinteg:sx_contproc
			   SET status_proc = "C",
                   hora_fin    = CURRENT,
			 	   codret      = v_cod_ret
			 WHERE proceso  = v_nameProcess
			   AND fecha    = pfechahoy
			   AND sistema = '06';

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

	LET v_nameProcess = "GeneraEdoCtaREES";
	LET v_cod_ret = "000";

	--     PREGUNTA POR EL CONTROL  DE PROCESOS     --

	SELECT status_proc INTO vStProc
	  FROM "informix".sd_contproc
	 WHERE empresa = pEmpresa
	   AND proceso  = v_nameProcess
	   AND fecha    = pfechahoy;
	   
	IF vStProc IS NULL OR vStProc = '' THEN
        	INSERT INTO "informix".sd_contproc (empresa, proceso, fecha, 
  	 	 		                     status_proc, ejecutivo,
          	  	                     hora_inicio, hora_fin, 
          	  	                     cod_ret, mensaje)
        	VALUES (pEmpresa, v_nameProcess, pfechahoy, 
	 	 		    'I', USER,
	 	 		    CURRENT, NULL, 
	 	 		    NULL, NULL);

			INSERT INTO bdinteg:sx_contproc (empresa, proceso, fecha, 
		 		                             sistema, status_proc,
	        	                             ejecutivo, hora_ini, 
	        	                             hora_fin, codret)
			     VALUES (pEmpresa, v_nameProcess, pfechahoy, 
		 		         '06', 'I', 
		 		         USER, CURRENT, 
		 		         NULL, '000');
	ELIF vStProc = "F" THEN
         	RETURN v_cod_ret;
	END IF
	
     EXECUTE PROCEDURE executaedoctageneralcrd (pempresa, pfechahoy) 
	 INTO v_cod_ret;

    IF v_cod_ret <> "000" THEN
        UPDATE sd_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               cod_ret     = v_cod_ret,
               mensaje     = v_cuantos || "Estados de Cuenta de Reestructura Sin Generar"
         WHERE empresa     = pEmpresa
           AND proceso     = v_nameProcess
           AND fecha       = pfechahoy;

        UPDATE bdinteg:sx_contproc
           SET status_proc = "C",
               hora_fin    = CURRENT,
               codret      = v_cod_ret
         WHERE proceso  = v_nameProcess
           AND fecha       = pfechahoy
           AND sistema = '06';
    ELSE
	    UPDATE sd_contproc
	       SET status_proc = "F",
	           hora_fin    = CURRENT,
        	   cod_ret     = v_cod_ret,
      	       mensaje     = "Proceso Concluido"
  	     WHERE empresa     = pEmpresa
	       AND proceso     = v_nameProcess
	       AND fecha       = pfechahoy;

          UPDATE bdinteg:sx_contproc
             SET status_proc = "F",
                 hora_fin = CURRENT,
                 codret   = v_cod_ret
           WHERE proceso  = v_nameProcess
             AND fecha    = pfechahoy
             AND sistema = '06';
    END IF
END;

	RETURN v_cod_ret;

END PROCEDURE
DOCUMENT
"Se crea procedimiento para realizar la consulta",
"a la bitacora de control de procesos y comenzar",
"con el proceso de generación de Edo. Cta.",
"reestructura",
"base de datos : bdicred",
"AUTOR : Jose de Jesus Almeida",
"FECHA : 20/Julio/2009";

CREATE PROCEDURE "informix".sp_credisoluciones_revol(pempresa CHAR(3), pFolioMovto CHAR(20) DEFAULT "")
   RETURNING CHAR(6), CHAR(80);

	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr                       INTEGER;
	DEFINE iIsamErr                      INTEGER;
	DEFINE cErrorInfo                    CHAR(100);
	DEFINE CodRet                        CHAR(6);
	DEFINE Mensaje                  	 CHAR(80);
	DEFINE CSnum_credito,cCredito_promo  CHAR(20);
	DEFINE v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva 	DECIMAL(14,2);
	DEFINE cfolio_mov_promo,cfolio_suc_promo CHAR(16);
	DEFINE cCharAux          			 CHAR(80);
	DEFINE dtDateAux         			 DATE;
	DEFINE dDecAux           			 DECIMAL(18,2);
	DEFINE iIntAux           			 INTEGER;
	DEFINE dPagoCom,dPagoIvaCom,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,vcap_vig,dSdoAdeudTotalAct   DECIMAL(18,2);
	DEFINE dtFechaApertura,dtFechaProxPago  DATE;
	DEFINE dPagoMinAct        			 DECIMAL(18,2);


	--INICIALIZACION DE VARIABLES.

	LET iSqlErr       = 0;
	LET iIsamErr      = 0;
	LET cErrorInfo    = "";
	LET CodRet       = "000000";
	LET Mensaje   = "Se realiz?? proceso exitosamente";
	LET CSnum_credito,cCredito_promo = '','';
	LET v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva = 0,0,0,0,0,0,0,0;
	LET cfolio_mov_promo,cfolio_suc_promo = '','';
	LET cCharAux       = "";
	LET dtDateAux      = DATE(1);
	LET dDecAux        = 0; LET iIntAux = 0; LET dPagoCom = 0; LET dPagoIvaCom = 0; LET dSdoAdeudTotal = 0; LET dIntDevengado = 0; LET dIvaIntDevengado = 0; LET vcap_vig = 0;
	LET dtFechaApertura  = DATE(1); LET dtFechaProxPago = DATE(1); LET dPagoMinAct = 0; LET dSdoAdeudTotalAct = 0;

	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
				  LET CodRet     = iSqlErr;
				  LET Mensaje = cErrorInfo;
			   RETURN CodRet,Mensaje;
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/tmp/sp_credisoluciones_revol.out";
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

			FOREACH
				SELECT b.num_credito,a.num_sol_prestamo, a.monto_actual, a.monto_int_iva,a.folio_movto,a.folio_suc
				  INTO CSnum_credito,cCredito_promo, v_monto_actual, v_monto_int_iva,cfolio_mov_promo,cfolio_suc_promo
				  FROM bdicred:"informix".sd_promocion_credito a,
					   bdicred:"informix".sd_maecred b
				 WHERE a.empresa = pEmpresa
				   AND a.empresa = b.empresa
				   AND a.sistema = '06'
				   AND a.num_credito = b.num_credito
				   AND a.status = 2
				   AND b.status_cred = 'AA'
				   AND a.folio_movto = DECODE(pFolioMovto, "", a.folio_movto, pFolioMovto)

				--SE OBTIENE EL ADEUDO DEL CLIENTE DE CREDISOLUCIONES HASTA ESE MOMENTO

				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cCredito_promo)
					INTO CodRet,Mensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
					  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,vcap_vig,dDecAux,dDecAux,dDecAux,
					  dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,dDecAux,
					  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
					  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
					  cCharAux,cCharAux,iIntAux,cCharAux;

				IF  dSdoAdeudTotalAct > 0 THEN
					--SE REALIZA EL PAGO POR EL MONTO CORRESPONDIENTE AL MES CORRIENTE DE CREDISOLUCIONES
					CALL "informix".sp_cargo_abono_palzo(pEmpresa,cCredito_promo,'',dSdoAdeudTotalAct,USER,'9290','4210',3,'')
					RETURNING CodRet, Mensaje;

					IF CodRet::INTEGER <> 0 THEN
						RETURN CodRet,Mensaje;
					ELSE
						LET CodRet = "000";
					END IF;

					IF (SELECT sdo_retenido FROM "informix".sd_maesdos WHERE empresa = '001' and num_credito = CSnum_credito) >= (v_monto_actual + v_monto_int_iva) THEN

						UPDATE "informix".sd_maesdos
						   SET sdo_retenido = sdo_retenido - (v_monto_actual + v_monto_int_iva)
						 WHERE empresa = '001' and num_credito = CSnum_credito;

						UPDATE "informix".sd_promocion_credito
						   SET status = 7
						 WHERE empresa = '001'
						   AND num_sol_prestamo = cCredito_promo
						   AND folio_movto = pFolioMovto;

						UPDATE "informix".sd_maeretenido
						   SET estatus = 'S'
						 WHERE empresa = '001'
						   AND num_credito = CSnum_credito
						   AND folio_suc = cfolio_mov_promo; --Revizar con cliente si se cambia por cfolio_suc_promo.

						UPDATE "informix".sd_maeretenido
						   SET estatus = 'S'
						 WHERE empresa = '001'
						   AND num_credito = CSnum_credito
						   AND nvl(substr(referencia,1,16),'') = cfolio_suc_promo;

					END IF;

					IF dIvaIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntDevengado,USER,'9290','4202',1,'')
						RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
							RETURN CodRet,Mensaje;
						ELSE
							LET CodRet = "000";
						END IF;
					END IF;

					IF dIntDevengado <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntDevengado,USER,'9290','4201',1,'')
						  RETURNING CodRet, Mensaje;

						  IF CodRet::INTEGER <> 0 THEN
							   RETURN CodRet,Mensaje;
						  ELSE
							 LET CodRet = "000";
						  END IF;
					END IF;

					IF vcap_vig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',vcap_vig,USER,'9290','4200',1,'')
						  RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
						   RETURN CodRet,Mensaje;
						ELSE
						 LET CodRet = "000";
						END IF;
					END IF;
				END IF;

				LET dSdoAdeudTotalAct = 0;
				LET vcap_vig = 0;
				LET dIntDevengado = 0;
				LET dIvaIntDevengado = 0;

			END FOREACH;

		RETURN CodRet,Mensaje;
	END;
END PROCEDURE
DOCUMENT
'NOMBRE: Mario Olivo',
'DESCRIPCION: Se agrega parametro pFolioMovto con (DEFAULT = '') para agregar el filtro',
' 			(AND a.folio_movto = DECODE(pFolioMovto, "", a.folio_movto, pFolioMovto)) en la consulta de',
'			la tabla sd_promocion_credito.',
'			Se implementan reglas de informix.',
'			Se castea el codret por integer para compactar el codigo de retorno y entrar a las validaciones',
'FECHA DE MODIFICACION: 11/junio/2013',
'BASE DE DATOS: bdicred',
'FOLIO DE PROYECTO: 1373';

CREATE PROCEDURE "informix".sp_depura_sd_movhis_3()
RETURNING CHAR(6);

DEFINE cCodRet      CHAR(6); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE vStatusCred  CHAR(02);
DEFINE vcantidad    INTEGER;

LET cCodRet      = '000000';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET vNumCred     = '';
LET vNumCredAux  = '';
LET vStatusCred  = '';
LET vcantidad    = 0;


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;		
            RETURN cCodRet;
        END IF;
    END EXCEPTION;

--    SET DEBUG FILE TO '/INFORMIXDUMP/sp_depura_sd_movhis2.out';
--    TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 4;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(4,'');
    END IF;

    FOREACH WITH HOLD
       SELECT TRIM(num_credito)
         INTO vNumCred
         FROM bdicred:sd_maecred_vendida
        WHERE empresa = '001'
          AND fecha <  mdy('07','01','2013')
          AND num_credito > vNumCredAux
       ORDER BY num_credito ASC

       SELECT status_cred
         INTO vStatusCred
         FROM bdicred:sd_maecred
        WHERE empresa = '001'
          AND num_credito = vNumCred;

       LET vcantidad = 0;

       IF NVL(vStatusCred,"") = 'CV' THEN
           SELECT count(*)
             INTO vcantidad
             FROM bdicred:sd_movhis
            WHERE empresa = '001'
              AND num_credito = vNumCred;
       END IF;

       IF NVL(vStatusCred,"") = 'CV' and vcantidad > 0 THEN
            BEGIN WORK;
                insert into bdicred:sd_movhis_new
                select * from bdicred:sd_movhis
                where empresa = '001'
                and num_credito = vNumCred;

                DELETE FROM "informix".sd_movhis
                where empresa = '001'
                  and num_credito = vNumCred;

                UPDATE "informix".sd_param_movhis_dep
                   SET num_credito = vNumCred
                 where proceso = 4;

            COMMIT WORK;  
       ELSE
            BEGIN WORK;
                UPDATE "informix".sd_param_movhis_dep
                   SET num_credito = vNumCred
                 where proceso = 4;
            COMMIT WORK;  

       END IF;
            
    END FOREACH;

    RETURN cCodRet;

    END
END PROCEDURE;