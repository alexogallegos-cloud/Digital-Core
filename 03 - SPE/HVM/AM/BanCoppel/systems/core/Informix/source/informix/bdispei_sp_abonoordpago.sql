CREATE PROCEDURE "informix".sp_abonoordpago(p_intpkpago integer)

RETURNING char(5), integer, char(40);

-- ***************************************************************************
-- sp_abonoordpago
-- Version              1.0.0
-- Obejtivo:            Abono Ordenes de pago a SPEI
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima Modificacion: Mayo - 2008
--                      Creación de SPL
-- ***************************************************************************

--//Definicion de variables
DEFINE v_codret          char(5);
DEFINE v_monto_abo       money(16,2);
DEFINE sql_err 	         integer;

DEFINE v_TransAbono      char(4);
DEFINE v_TransSuc        char(4);
DEFINE v_AbonaCheq       char(1);
DEFINE v_SucursalCentral char(4);
DEFINE v_Usuario         char(20);
DEFINE v_DivisaMN        char(2);

DEFINE v_intcvetipopago  integer;
DEFINE v_intcvetpoop     integer;
DEFINE v_intcvetipocuenta integer;
DEFINE v_CveTpoOp        char(20);
DEFINE v_TpoCta          integer;
DEFINE v_CtaBenef        char(20);
DEFINE v_NombreBenef     char(40);
DEFINE v_ClaveRastreo    char(30);
DEFINE v_Importe         money(16,2);
DEFINE v_chrFolioLiq     varchar(16);
DEFINE v_chrEstatusEnvio char(1);
DEFINE v_vchrcverastrorig varchar(30);
DEFINE v_intpkdev        integer;

DEFINE v_intpkctabansi   integer;
DEFINE v_intcvetpopagobsi integer;
DEFINE v_intcvetpoopbsi  integer;
DEFINE v_inttipofuncion  integer;

DEFINE v_Ctapaso         CHAR(11);
DEFINE v_Cta             varchar(11);
DEFINE v_StatusCta       char(1);
DEFINE v_sdoccta         money(16,2);
DEFINE v_CodErrStr       char(5);
DEFINE v_Empresa         char(3);
DEFINE v_intcvecausadev  integer;
DEFINE v_Size            smallint;
DEFINE vdtFechaOp        date;
DEFINE v_motivodev       varchar(255);
DEFINE v_chraceptacioncta   char(1);
DEFINE v_chraceptacionbco   char(1);
DEFINE v_cvecesifbco     integer;
DEFINE v_Documento       decimal(7,0);
DEFINE v_vchrconceptopago char(40);
DEFINE v_hora            CHAR(15);
DEFINE v_numtarjeta      char(20);
DEFINE vchrtxop          char(4);
DEFINE vexiste           char(1);
DEFINE vaceptab          char(1);

--//Inicializacion de Variables
LET v_codret      = "000";
LET v_monto_abo   = 0;
LET v_Documento   = 0;
LET v_TransSuc    = "0000";
LET v_TransAbono  = "0000";
LET v_Documento   = 0;
LET v_vchrconceptopago = "";
LET v_Size        = 0;
LET v_intcvecausadev = 0;
LET v_motivodev   = "";
LET v_chraceptacionbco = "";
LET v_chraceptacioncta = "";
LET v_cvecesifbco = 0;
LET v_numtarjeta  = "";
LET v_Cta  = "";


    --SET debug file to "/tmp/sp_abonoordpago.out";
    --TRACE on;

--//INICIA LA FUNCIONALIDAD
BEGIN

        --//Manejo de excepciones
        ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
		   ROLLBACK WORK;
	       LET v_codret = sql_err;
		   RETURN v_codret, v_intcvecausadev, v_monto_abo;
		END IF;
        END EXCEPTION;


	--//Inicia la Transaccion
	BEGIN WORK;

	--//Obtenemos datos del pago
	--//Obtiene la trans., si abona chq, y Tipo de Cuenta
	--//Verifica que el tipo de pago sea permitido por el banco
	SELECT tp.chrabonacheques , tc.intcvetipocuenta, tp.inttipofuncion,
	       pago.intcvetipopago, intcvetpooperacion, trim(vchrcuentabenef), mnyimporte,
	       chrEstatusEnvio, vchrcverastreoorig, nvl(intrefnumerica, 0), nvl(trim(vchrclaverastreo),''),
               tp.chraceptacionbco, tc.chraceptacionbco
          INTO v_AbonaCheq, v_TpoCta, v_inttipofuncion,
	       v_intcvetipopago, v_intcvetpoop, v_CtaBenef, v_Importe,
               v_chrEstatusEnvio, v_vchrcverastrorig, v_documento, v_vchrconceptopago,
               v_chraceptacionbco, v_chraceptacioncta
	  FROM tblpago pago, tbltipopago tp,
         OUTER tbltipocuenta tc
	 WHERE tp.intcvetipopago = pago.intcvetipopago
	   AND pago.intpkpago = p_intpkpago
	   AND pago.intcvetipoctabene = tc.intcvetipocuenta;

        --//Obtiene la Sucursal Central, Ejecutivo Central y Divisa_mn
	SELECT vchrvalor
	  INTO v_SucursalCentral
	  FROM tblparametros
	 WHERE vchrcveparametro ='SUCURSAL_CENTRAL';

	--SELECT vchrvalor
	--  INTO v_Usuario
	--  FROM tblparametros
	-- WHERE vchrcveparametro='EJECUTIVO_CENTRAL';
        LET v_Size = LENGTH(user);
        LET v_Usuario = SUBSTR(user,v_size-7, v_size);

	SELECT vchrvalor
	  INTO v_DivisaMN
	  FROM tblparametros
	 WHERE vchrcveparametro='DIVISA_TP_MN';

	SELECT to_date(vchrValor, '%d/%m/%Y')
          INTO vdtFechaOp
	  FROM tblParametros
	 WHERE vchrCveParametro = 'FECHA_OPERACION';

        --//Obtiene la transaccionde abono a clientes
	SELECT vchrvalor
	  INTO v_TransAbono
	  FROM tblparametros
	 WHERE vchrcveparametro ='TRANSACC_ABONO';


        --//Obtiene la clave del banco beneficiario
	SELECT vchrvalor
	  INTO v_cvecesifbco
	  FROM tblparametros
	 WHERE vchrcveparametro='CESIF_BANCO';

        --//Obtiene la clave de la empresa
 	SELECT empresa
	  INTO v_Empresa
	  FROM bdinteg:si_empresas;

        --//Si es una devolucion obtiene la informacion de la cuenta ordenante.
	IF v_inttipofuncion = 1 THEN
	   SELECT intcvetipopago, intcvetpooperacion, vchrcuentaord,
                  mnyimporte, intcvetipoctaord, chrtxop
	     INTO v_intcvetipopago, v_intcvetpoop, v_CtaBenef,
                  v_Importe, v_TpoCta, vchrtxop
	     FROM tblpago
	    WHERE tblpago.vchrclaverastreo = v_vchrcverastrorig
              AND chrestatusenvio = 'D'
              AND chrsentidopago = 'E'
              AND cvecesifbcoord = v_cvecesifbco
	      AND dtFechaValor = vdtFechaOp;

	   --//Verifica si abona a cheques cuando devolucion
	   SELECT chrDevAbonaChq, chraceptacionbco
	     INTO v_AbonaCheq, v_chraceptacionbco
	     FROM tbltipopago tp
	    WHERE tp.intcvetipopago = v_intcvetipopago;

	    IF v_AbonaCheq="1" then
	      --//Verifica si es un pago manual x Tesoreria
              IF vchrtxop = '0000' THEN
                 LET v_AbonaCheq = '0';
              ELSE
                 --//Obtiene la transaccion de devolucion
	         SELECT vchrvalor
	           INTO v_TransAbono
	           FROM tblparametros
	          WHERE vchrcveparametro ='TRANSACC_DEVOL';

	         --//Verifica que el tipo de cuenta sea aceptado por el banco
	         SELECT chraceptacionbco
                   INTO v_chraceptacioncta
	           FROM tbltipocuenta
	          WHERE intcvetipocuenta = v_TpoCta;
	      END IF;
           END IF;
        END IF;

	--//Verifica que el tipo de pago/cta sea permitido por el banco
	IF v_chraceptacionbco != "1" OR (v_AbonaCheq="1" AND v_chraceptacioncta != "1") THEN
	   LET v_motivodev = "El banco no acepta el tipo de pago o cta recibido.";
	   LET v_intcvecausadev = 15;
	   --//Marcar pago con "D" con causa Dev. correspondiente
	   EXECUTE PROCEDURE sp_generadevpago(p_intpkpago, v_intcvecausadev, v_motivodev)
	      INTO v_codret;

	   IF v_codret != 0 THEN
	      --//Realiza un ROLLBACK WORK
	      ROLLBACK WORK;
	      --//Entrega error 201
	      RETURN v_codret, 0, "0";
	   ELSE
  	      --//Finaliza transaccion y entrega "000".
	      COMMIT WORK;
	      RETURN v_codret, v_intcvecausadev, v_motivodev;
	   END IF;
        END IF;


	--//Verifica si existe el Pago
	IF NOT v_intcvetipopago IS NULL THEN
	   IF v_chrEstatusEnvio = "R" THEN

              --//Recupera el Monto de pago a Abonar
	      LET v_monto_abo = v_Importe;
	      --//Verifica si Abona a Cheques
	      IF v_AbonaCheq="1" then
	   	 --//Verifica si es CLABE ó TD ó CTA
		 IF v_TpoCta = 40 OR v_TpoCta = 3 THEN
                    LET v_CtaBenef = trim(v_CtaBenef);
                    LET v_Cta = "";
		    --//Extrae los 11 digitos correspondientes a la cuenta de CLABE
                    IF LENGTH(v_CtaBenef) = 18 OR LENGTH(v_CtaBenef) = 11 OR LENGTH(v_CtaBenef) = 16  THEN
                       IF LENGTH(v_CtaBenef) = 16 THEN
                          SELECT mae.cuenta, mae.status_cta
                            INTO v_Cta, v_StatusCta
                            FROM bdicheq:sc_maechq mae, bdicheq:sc_tarjeta tarjeta
                           WHERE tarjeta.num_tarjeta = v_CtaBenef
                             AND mae.cuenta = tarjeta.cuenta;
		           LET v_numtarjeta = v_CtaBenef;
                       ELSE
		          IF LENGTH(v_CtaBenef) = 18 THEN
                             LET v_Ctapaso = v_CtaBenef[7,17];
                          ELSE
		             LET v_Ctapaso = v_CtaBenef;
                          END IF;
                          SELECT mae.cuenta, mae.status_cta
                            INTO v_Cta, v_StatusCta
                            FROM bdicheq:sc_maechq mae
                           WHERE mae.cuenta = v_Ctapaso;
                       END IF
                       IF v_Cta = "" OR v_Cta IS NULL THEN
                          LET v_codret = '100';
                       END IF
                       IF v_StatusCta = "2" THEN
                          LET v_codret = '102';
                       END IF
                       IF v_StatusCta = "3" THEN
  	                  SELECT "1" 
                            INTO vexiste
                            FROM bdicheq:sc_ctabloqueo blq 
                           WHERE blq.cuenta = v_Cta;
                           IF vexiste = "1" THEN
            	              SELECT opcion 
                                INTO vaceptab
            	                FROM bdicheq:sc_ctabloqueo cbloq 
                               WHERE cbloq.cuenta = v_Cta;
            	               IF vaceptab=4 THEN
                                  LET v_codret = '103';
                               END IF
                           END IF
                       END IF
                    ELSE
                       LET v_codret = '100';
                    END IF
                    --//La v_Cta es valida
               	    IF v_codret = "000" THEN
		       UPDATE tblpago
                          SET chrCtaCheques = v_Cta
			WHERE intpkpago = p_intpkpago;

		       --//Valida si la cuenta existe en tblCtaBansi????
		       SELECT intpkctabansi, intcvetipopago, intcvetpooperacion
			 INTO v_intpkctabansi, v_intcvetpopagobsi, v_intcvetpoopbsi
			 FROM tblCtaBansi
			WHERE tblCtaBansi.vchrcuenta = v_CtaBenef;
		       IF NOT v_intpkctabansi IS NULL THEN
			  --//Actualiza el Tipo de Pago y el tipo de Operacion
	 		  --// y marca el Pago como  abonado "A"
			  UPDATE tblPago
			     SET --intcvetipopago = v_intcvetpopagobsi,
			         --intcvetpooperacion = v_intcvetpoopbsi,
			         chrEstatusEnvio = "A"
			   WHERE intpkpago=p_intpkpago;
		        ELSE
                          {
			   --//Valida Estatus de la Cuenta
		           EXECUTE PROCEDURE bdicheq:cons_saldo(v_Cta)
			      INTO v_codret, v_sdoccta, v_StatusCta;
			   IF v_codret = "000" THEN
                           }
			   --//Genera FolioLiquidacion
                           SELECT CURRENT HOUR TO FRACTION(2)
                             INTO v_hora
                             FROM bdinteg:dual;
			   LET v_chrFolioLiq = trim(v_Usuario)||v_hora[1,2]||v_hora[4,5]||v_hora[7,8];
                           LET v_chrFolioLiq = trim(v_chrFolioLiq)||SUBSTR(trim(v_vchrconceptopago),-2);

			   --//Actualiza Tabla Pagos con FolioLiq
			   UPDATE tblPago
			      SET chrFolioLiqu = v_chrFolioLiq
			    WHERE intpkpago    = p_intpkpago;

			   --//Ejecuta bdiCheq:abono_ref
			   EXECUTE PROCEDURE bdiCheq:abono_ref(v_empresa, v_SucursalCentral, v_Usuario,
			                                  v_TransAbono, v_TransSuc, v_chrFolioLiq,
			  	    		          v_Cta, v_Documento,v_Importe, v_Importe,
			                    		  0,0,0,v_DivisaMN, v_vchrconceptopago,v_numtarjeta, v_Usuario)
			      INTO v_codret;
			   --//Verifica si el Abono Fue exitoso Retorna CodErr Tipo Char(5)
			   IF trim(v_codret)="000" THEN
			      --//Marca el pago con estatus "A"
			      UPDATE tblPago
				 SET chrEstatusEnvio="A"
			       WHERE intpkpago=p_intpkpago;
			   ELSE
			      --//Buscar el error en tblCausaDev
			      SELECT tblcdev_codret.vchrcodigoerror, tblcausadev.intcvecausadev
			        INTO v_CodErrStr, v_intcvecausadev
			        FROM tblcausadev, tblcdev_codret
			       WHERE tblcdev_codret.intcvecausadev = tblcausadev.intcvecausadev
			         AND tblcdev_codret.vchrcodigoerror= trim(v_codret);
			      IF NOT v_CodErrStr IS NULL THEN
			         LET v_motivodev = "Error (" || v_codret || ") al realizar abono de la orden.";
			         --//Marcar pago con "D" con causa Dev. correspondiente
			         EXECUTE PROCEDURE sp_generadevpago(p_intpkpago, v_intcvecausadev, v_motivodev)
			            INTO v_codret;
				 IF v_codret != 0 THEN
				    --//Realiza un ROLLBACK WORK
				    ROLLBACK WORK;
				    --//Entrega error 201
				    RETURN v_codret, 0, "0";
				 END IF;
			      ELSE
				 --//Realiza un ROLLBACK WORK
				 ROLLBACK WORK;
				 --//Entrega error 201
				 RETURN v_codret, 0, "abono_ref: Error en la Cta. de cheques";
			      END IF; --//NOT v_CodErrStr IS NULL
			   END IF; --//Verifica si el Abono Fue exitoso bdiCheq:abono_ref
		        END IF; --//NOT v_intpkctabansi
		    ELSE --//La v_Cta es valida
 		       --//Buscar el error en tblCausaDev
		       SELECT tblcdev_codret.vchrcodigoerror, tblcausadev.intcvecausadev
		         INTO v_CodErrStr, v_intcvecausadev
		         FROM tblcausadev, tblcdev_codret
		        WHERE tblcdev_codret.intcvecausadev = tblcausadev.intcvecausadev
		          AND tblcdev_codret.vchrcodigoerror= trim(v_codret);

		       IF NOT v_CodErrStr IS NULL THEN
		    	  LET v_motivodev = "Error (" || v_codret || ") al realizar abono de la orden.";
			  --//Marcar pago con "D" con causa Dev. correspondiente
			  EXECUTE PROCEDURE sp_generadevpago(p_intpkpago, v_intcvecausadev, v_motivodev)
			     INTO v_codret;

			  IF v_codret != 0 THEN
			     --//Realiza un ROLLBACK WORK
			     ROLLBACK WORK;
			     --//Entrega error 201
			     RETURN v_codret, 0, "0";
			  END IF;
		       ELSE
		          --//Realiza un ROLLBACK WORK
		          ROLLBACK WORK;
			  --//Entrega error 201
			  RETURN v_codret, 0, "Numero CLABE, TDD ó CTA Beneficiario no valido.";
		       END IF;
		    END IF; --//La v_Cta es valida
		 ELSE  --//Cuenta CLABE ó TD ó CTA *** OK ***
 	  	    --Marca el pago con estatus "A"
		    UPDATE tblPago
		       SET chrEstatusEnvio = "A"
		     WHERE intpkpago = p_intpkpago;
		 END IF; --//Cuenta CLABE o TD
	      ELSE -- AbonaCheq = 1 *** OK ***
                 {
                 IF NOT v_intcvetpoop IS NULL OR trim(v_intcvetpoop) <> "" THEN
		    --Verifica la acpetacion del tipo de operacion
		    SELECT chraceptacionbco INTO v_chraceptacion
		      FROM tbltipooperacion
		     WHERE intcvetpooperacion = LPAD(v_intcvetpoop,2,"0");

		    IF v_chraceptacion != "1" THEN
		       LET v_intcvecausadev = 16;
		       LET v_motivodev = "El tipo de operacion recibido no es aceptado por el banco.";
		       --Marcar pago con "D" con causa Dev. correspondiente
		       EXECUTE PROCEDURE sp_generadevpago(p_intpkpago, v_intcvecausadev, v_motivodev)
		          INTO v_codret;

		       IF v_codret != 0 THEN
		          --Realiza un ROLLBACK WORK
		          ROLLBACK WORK;
		          --Entrega error 201
		          RETURN v_codret, 0, 0;
		       ELSE
		          --Finaliza transaccion y entrega "000".
		          COMMIT WORK;
		          RETURN v_codret, v_intcvecausadev, v_monto_abo;
		       END IF;
		    END IF;
		 END IF;
                 }
	  	 --Marca el pago con estatus "A"
		 UPDATE tblPago
		    SET chrEstatusEnvio = "A"
		  WHERE intpkpago = p_intpkpago;
	      END IF; -- AbonaCheq = 1 *** OK ***
	   ELIF  v_chrEstatusEnvio = "Y" THEN
	      --//Marca el pago con estatus "A"
	      UPDATE tblPago
	         SET chrEstatusEnvio = "A"
	       WHERE intpkpago = p_intpkpago;
	   ELSE -- chrEstatusPago=R
	      --Retorna Error XXX el pago habia sido abonado
	      ROLLBACK WORK;
	      Let v_codret="202";
	      RETURN v_Codret, v_intcvecausadev, "Pago no status por Abonar";
	   END IF;
	ELSE
	   --Retorna Error 200 Pago no Existente
	   ROLLBACK WORK;
	   Let v_codret="200";
	   RETURN v_Codret, v_intcvecausadev, "Pago no existe: "||v_intcvetipopago;
	END IF ;

	--Compromete la Transaccion
	COMMIT WORK;

	RETURN v_codret, v_intcvecausadev, v_Cta;
END

END PROCEDURE;