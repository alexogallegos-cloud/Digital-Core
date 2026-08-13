CREATE PROCEDURE "informix".sp_abonocanelapago(p_intpkpago INTEGER)

RETURNING char(5), integer, money(16,2);

-- ***************************************************************************
-- sp_abonocanelapago
-- Version              1.0.0
-- Obejtivo:            Abonao una cancelacion de Orden de pago a SPEI
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima Modificacion: Octubre - 2007
--                      Creación de SPL
-- ***************************************************************************

--//Definicion de variables
DEFINE v_codret          char(5);
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
DEFINE v_ClaveRastreo    char(30);
DEFINE v_Importe         money(16,2);
DEFINE v_chrFolioLiq     varchar(16);
DEFINE v_chrEstatusEnvio char(1);
DEFINE v_vchrcverastrorig varchar(30);
DEFINE v_intpkdev        integer;

DEFINE v_inttipofuncion  integer;

DEFINE v_spl             char(6);
DEFINE v_Cta             varchar(20);
DEFINE v_StatusCta       char(1);
DEFINE v_sdoccta         money(16,2);
DEFINE v_CodErrStr       char(5);
DEFINE v_Empresa         char(3);
DEFINE v_intcvecausadev  integer;
DEFINE v_Size            smallint;
DEFINE vdtFechaOp        date;
DEFINE v_chraceptacion   char(1);
DEFINE v_cvecesifbco     integer;
DEFINE v_Documento       decimal(7,0);
DEFINE v_vchrconceptopago char(40);
DEFINE v_hora            CHAR(15);
DEFINE v_numtarjeta      CHAR(20);


--//Inicializacion de Variables
LET v_codret ="000";
LET v_Importe=0;
LET v_TransSuc="0000";
LET v_TransAbono="0000";
LET v_Documento = 0;
LET v_vchrconceptopago = "";
LET v_Size=0;
LET v_intcvecausadev=0;
LET v_chraceptacion = "";
LET v_cvecesifbco   = 0;
LET v_numtarjeta    = "";

    --set debug file to "/tmp/sp_abonocancelapago.out";
    --trace on;

--//INICIA LA FUNCIONALIDAD
BEGIN

        --//Manejo de excepciones
        ON EXCEPTION SET sql_err
	 	IF sql_err <> 0 THEN
		   ROLLBACK WORK;
	        LET v_codret = sql_err;
		   RETURN v_codret, v_intcvecausadev, v_Importe;
		END IF;
        END EXCEPTION;


	--//Inicia la Transaccion
	BEGIN WORK;

	--//Obtiene la trans., si abona chq, y Tipo de Cuenta
	SELECT tp.chrabonacheques , tc.intcvetipocuenta, tp.inttipofuncion
          INTO v_AbonaCheq, v_TpoCta, v_inttipofuncion
	  FROM tblpago pago, tbltipopago tp,
         OUTER tbltipocuenta tc
	 WHERE tp.intcvetipopago = pago.intcvetipopago
	   AND pago.intpkpago = p_intpkpago
	   AND pago.intcvetipoctaord = tc.intcvetipocuenta;

        --//Obtiene la Sucursal Central, Ejecutivo Central y Divisa_mn
	SELECT vchrvalor
	  INTO v_SucursalCentral
	  FROM tblparametros
	 WHERE vchrcveparametro ='SUCURSAL_CENTRAL';

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

        --//Obtiene la transaccion de abono a clientes
	SELECT vchrvalor
	  INTO v_transabono
	  FROM tblparametros
	 WHERE vchrcveparametro ='TRANSACC_ABONO';

        --//Obtiene la clave del banco origen
	SELECT vchrvalor
	  INTO v_cvecesifbco
	  FROM tblparametros
	 WHERE vchrcveparametro='CESIF_BANCO';

        --//Obtiene la clave de la empresa
 	SELECT empresa
	  INTO v_Empresa
	  FROM bdinteg:si_empresas;

	--//Obtenemos datos del pago
	SELECT intcvetipopago, intcvetpooperacion, 
               trim(vchrcuentaord), mnyimporte,
	       chrEstatusEnvio, vchrconceptopago2, 
               nvl(intrefnumerica, 0), nvl(trim(vchrclaverastreo),'')
	  INTO v_intcvetipopago, v_intcvetpoop, 
               v_Cta, v_Importe, 
               v_chrEstatusEnvio, v_vchrcverastrorig, 
               v_documento, v_vchrconceptopago
	  FROM tblpago 
         WHERE tblpago.intpkpago = p_intpkpago;
        

        --//Obtiene la cuenta de cheques de la tarjeta de debito.
        IF v_TpoCta = 3 THEN
           IF LENGTH(v_Cta) > 11 THEN
              LET v_numtarjeta = trim(v_Cta);
              SELECT mae.cuenta
                INTO v_Cta
                FROM bdicheq:sc_maechq mae, 
                     bdicheq:sc_tarjeta tarjeta
               WHERE tarjeta.num_tarjeta = v_numtarjeta
                 AND mae.cuenta = tarjeta.cuenta;
           ELSE
              SELECT tarjeta.num_tarjeta
                INTO v_numtarjeta
                FROM bdicheq:sc_tarjeta tarjeta
               WHERE tarjeta.cuenta = v_Cta;
           END IF;
        END IF;
        LET v_Cta = trim(v_Cta);

        --//Obtiene la trans. de devolucion para el tipo de operacion
	SELECT chrDevAbonaChq
	  INTO v_AbonaCheq
	  FROM tbltipopago tp
	 WHERE tp.intcvetipopago=v_intcvetipopago;

	--//Verifica si existe el Pago
	IF NOT v_intcvetipopago IS NULL THEN
            --//Verifica si Abona a Cheques
	    IF v_AbonaCheq="1" then
	       --//Verifica que el tipo de cuenta sea aceptado por el banco
	       SELECT chraceptacionbco 
                 INTO v_chraceptacion
	         FROM tbltipocuenta
	        WHERE intcvetipocuenta = v_TpoCta;

	       IF v_chraceptacion != "1" THEN
	          --//Finaliza transaccion y entrega "000".
		  COMMIT WORK;
		  RETURN v_codret, v_intcvecausadev, v_Importe;
	       END IF; --// v_chraceptacion != "1" 

	       --//Valida Estatus de la Cuenta
	       EXECUTE PROCEDURE bdicheq:cons_saldo(v_Cta)
	          INTO v_codret, v_sdoccta, v_StatusCta;
	       IF v_codret = "000" THEN
	          --//Genera FolioLiquidacion
                  SELECT CURRENT HOUR TO FRACTION(2)
                    INTO v_hora
                    FROM bdinteg:dual;
		  --LET v_chrFolioLiq = trim(v_Usuario)||v_hora[1,2]||v_hora[4,5]||v_hora[7,8]||v_hora[10,11];
		  LET v_chrFolioLiq = trim(v_Usuario)||v_hora[1,2]||v_hora[4,5]||v_hora[7,8];
		  LET v_chrFolioLiq = trim(v_chrFolioLiq)||SUBSTR(trim(v_vchrconceptopago),-2);

		  --//Actualiza Tabla Pagos con FolioLiq
		  UPDATE tblPago
		     SET chrFolioLiqu = v_chrFolioLiq,
                         dtmhoracancela = current
		   WHERE intpkpago    = p_intpkpago;
            	  --//Ejecuta bdiCheq:abono_ref
		  EXECUTE PROCEDURE bdiCheq:abono_ref(v_empresa, v_SucursalCentral, v_Usuario,
		                                      v_TransAbono, v_TransSuc, v_chrFolioLiq,
			              	              v_Cta, v_Documento,v_Importe, v_Importe,
						      0,0,0,v_DivisaMN, v_vchrconceptopago,v_numtarjeta,v_Usuario)
			       INTO v_codret;
		  --//Verifica si el Abono no fue exitoso
		  IF trim(v_codret) <> "000" THEN
		     --//Buscar el error en tblCausaDev
		     SELECT vchrdescripcion, tblcausadev.intcvecausadev
		       INTO v_CodErrStr, v_intcvecausadev
		       FROM tblcausadev, tblcdev_codret
		      WHERE tblcdev_codret.intcvecausadev = tblcausadev.intcvecausadev
		        AND tblcdev_codret.vchrcodigoerror= trim(v_codret);
		     --//Realiza un ROLLBACK WORK
		     ROLLBACK WORK;
		     RETURN v_codret, v_CodErrStr, 0;
		  END IF;
	       END IF;
           ELSE
	       --//Genera FolioLiquidacion
               SELECT CURRENT HOUR TO FRACTION(2)
                 INTO v_hora
                 FROM bdinteg:dual;
	       LET v_chrFolioLiq = trim(v_Usuario)||v_hora[1,2]||v_hora[4,5]||v_hora[7,8];
	       LET v_chrFolioLiq = trim(v_chrFolioLiq)||SUBSTR(trim(v_vchrconceptopago),-2);

               --//Actualiza Tabla Pagos con FolioLiq
	       UPDATE tblPago
	          SET chrFolioLiqu = v_chrFolioLiq,
                      dtmhoracancela = current
  	        WHERE intpkpago    = p_intpkpago;
	   END IF; --// No abona a cheques
	END IF ; --//No existe el pago
	--//Compromete la Transaccion
	COMMIT WORK;

	RETURN v_codret, v_intcvecausadev, v_Importe;

END

END PROCEDURE;