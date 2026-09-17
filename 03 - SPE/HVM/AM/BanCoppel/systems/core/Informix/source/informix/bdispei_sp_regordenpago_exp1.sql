CREATE PROCEDURE "informix".sp_regordenpago_exp1(
			chrUsuario CHAR(8),
			chrSucursal CHAR(4),
			chrFolio_suc CHAR(16),
			intBancoRec INTEGER,
			chrvalconvenio CHAR(1),
			dFechaValor DATE,
			intTipoPago INTEGER,
			intTipoOper INTEGER,
			mnyImporteOP MONEY(18,2),
			vchrCuentaOrd VARCHAR(20),
			vchrNombreBenef VARCHAR(40),
			vchrCtaBenef VARCHAR(20),
			vchrRFCBenef VARCHAR(18),
			mnyImporteIVA MONEY(18,2),
			decRefNum DECIMAL(7,0),
			vchrRefCobranza1 VARCHAR(40),
			vchrConceptoPago VARCHAR(210),
			vchrClavePago VARCHAR(10),
			vchrNombreBenef2 VARCHAR(40),
			vchrRFCBenef2 VARCHAR(18),
			vchrCtaBenef2 VARCHAR(20),
			vchrConceptoPago2 VARCHAR(40),
			vchrCveRastreo VARCHAR(30),
			chrTransaccion CHAR(4),
                        vchrNumCte VARCHAR(20))
			RETURNING CHAR(5), CHAR(30);
{
CREADO POR : Arturo Salinas
FECHA DE CREACION : 22 de Septiembre del 2003
FUNCIONALIDAD : Registra un pago de SPEI en tblpago dependiendo del tipo de pago
MODIFICADO POR : Alejandro Rueda S.
FECHA DE CREACION : 20 de Octubre del 2006

}

--Definicion de variables
DEFINE vchrparametro     VARCHAR(255);
DEFINE chrcodret         CHAR(5);
DEFINE intcodret         INTEGER;
DEFINE vchrFechaOper     VARCHAR(10);
DEFINE chrEstadoProceso  CHAR(1);
DEFINE intcontador       INTEGER;
DEFINE inttpooper        INTEGER;
DEFINE vchrnombre        VARCHAR(40);
DEFINE vchrrazonsocial   VARCHAR(40);
DEFINE vchrnombreord     VARCHAR(40);
DEFINE intpktblpago      INTEGER;
DEFINE chrspl            CHAR(7);
DEFINE chrtopologia      CHAR(1);
DEFINE intBancoOrd       INTEGER;
DEFINE vchrCLABEOrd      VARCHAR(18);
DEFINE intTipoCta        INTEGER;
DEFINE intTpoCtaOpcional INTEGER;
DEFINE chrabonachq       CHAR(1);
DEFINE chrCodSistema     CHAR(2);
DEFINE chrCodSisSPEI     CHAR(2);
DEFINE vchrRFCOrd        VARCHAR(18);
DEFINE vintCveCesif      INTEGER;
DEFINE vsintLongCveRast  SMALLINT;
DEFINE vintfolioop	 INTEGER;
DEFINE v_montomin	 MONEY;

 ON EXCEPTION SET intcodret
   IF intcodret <> 0 THEN
     LET chrcodret= intcodret;
     RETURN chrcodret, vchrCveRastreo;
   END IF;
 END EXCEPTION;

-- DEBUG FLAG
--SET debug file to "/tmp/sp_regordenpago.out";
--TRACE ON;

--Asignacion de valor de constantes
LET intTipoCta = 1;
LET chrCodSisSPEI = '21';
LET vchrRFCOrd = '';
LET vchrrazonsocial = '';
LET vchrnombre = '';
LET vchrnombreord = '';

--Inicializacion de variables
LET chrcodret = '000';
LET intcontador = 0;
LET v_montomin = 0;
LET chrCodSistema = chrCodSisSPEI;

  IF TRIM(chrTransaccion) <> '' THEN
     LET chrTransaccion = LPAD(TRIM(chrTransaccion), 4, '0');
  END IF;

  IF vchrCveRastreo IS NULL OR
	vchrCveRastreo = '' THEN
	EXECUTE PROCEDURE sp_obtsigfolioop('FOLIO_CVERASTREO') INTO chrCodRet, vintfolioop;
	LET vchrCveRastreo = 'BSI' || TRIM(chrSucursal) || UPPER(TRIM(chrUsuario)) || LPAD(vintfolioop||'', 9, '0');
	--LET vchrCveRastreo = chrFolio_suc;
  END IF;

  --Obtiene la fecha de operacion
  SELECT vchrvalor INTO vchrparametro FROM tblparametros
    WHERE vchrcveparametro='FECHA_OPERACION';
  IF vchrparametro IS NULL THEN
    RETURN '001', vchrCveRastreo; --regresa error de parametro no encontrado
  END IF;
  LET vchrFechaOper = SUBSTR(TRIM(vchrparametro),4,2) || '/' ||
    SUBSTR(TRIM(vchrparametro),0,2) || '/' || SUBSTR(TRIM(vchrparametro),7,4);

{ALEX-->
  --Valida que no esté bloqueada la base de datos
  SELECT vchrvalor INTO vchrparametro FROM tblparametros
    WHERE vchrcveparametro='BLOQUEO_A_USUARIOS';
  IF vchrparametro IS NULL THEN
    RETURN '001', vchrCveRastreo; --regresa error de parametro no encontrado
  END IF;
  IF (vchrparametro * 1) = 1 THEN
    RETURN '002', vchrCveRastreo; --regresa error de que la base de datos esta bloqueada
  END IF;


  --Verifica que la operacion se encuentre dentro del horario de servicio.
  SELECT COUNT(*) INTO intcontador
  FROM tblhorario
    WHERE CURRENT BETWEEN tmhorainicio AND tmhoralimite;
  IF intcontador = 0 THEN
    RETURN '876', vchrCveRastreo; --regresa error operacion fuera de horario
  END IF;
-->}

  --Obtiene la topologia por default
  SELECT vchrvalor INTO vchrparametro FROM tblparametros
    WHERE vchrcveparametro='DEFAULT_TOPOLOGIA';
  IF vchrparametro IS NULL THEN
    RETURN '001', vchrCveRastreo; --regresa error de parametro no encontrado
  END IF;
  LET chrtopologia = TRIM(vchrparametro);

  --Obtiene el banco ordenante (Bansi)
  SELECT vchrvalor INTO vchrparametro FROM tblparametros
    WHERE vchrcveparametro='@CVECESIFBCO';
  IF vchrparametro IS NULL THEN
    RETURN '001', vchrCveRastreo; --regresa error de parametro no encontrado
  END IF;
  LET intBancoOrd = (vchrparametro * 1);

{ALEX-->
  --valida que se haya realizado el inicio de dia
  SELECT chrstatus INTO chrEstadoProceso FROM tblctrlproceso
    WHERE intcveproceso = 1 AND dtfecha = vchrFechaOper;
  IF chrEstadoProceso IS NULL THEN
    RETURN '001', vchrCveRastreo; --regresa error de parametro no encontrado
  END IF;
  IF NOT chrEstadoProceso = '1' THEN
    RETURN '003', vchrCveRastreo; --regresa error de no se ha realizado el inicio de dia
  END IF;
  --valida que no se haya realizado el pase contable
  SELECT chrstatus INTO chrEstadoProceso FROM tblctrlproceso
    WHERE intcveproceso = 2 AND dtfecha = vchrFechaOper;
  IF chrEstadoProceso = '1' THEN
    RETURN '004', vchrCveRastreo; --regresa error de ya se realizo el pase contable
  END IF;
}
  --Valida que exista la sucursal en central
  --->SELECT count(*) INTO intcontador FROM bdicent:si_sucursales
  SELECT count(*) INTO intcontador FROM bdinteg:si_sucursales
    WHERE sucursal = chrSucursal;
  IF intcontador = 0 THEN
    RETURN '005', vchrCveRastreo; --regresa error de sucursal no valida
  END IF;

  -- Valida que exista el usuario en central
  --->SELECT count(*) INTO intcontador FROM bdicent:si_ejecut
  SELECT count(*) INTO intcontador FROM bdinteg:si_ejecut
    WHERE ejecutivo = chrUsuario;
  IF intcontador = 0 THEN
    RETURN '006', vchrCveRastreo; --regresa error de usuario no valido
  END IF;

  --Valida que el importe no sea menor que el monto minimo permitido
  {El monto minimo se cambio a la tabla de tipo pago.
  SELECT vchrvalor INTO vchrparametro FROM tblparametros
    WHERE vchrcveparametro='MONTOMINIMO';
  IF vchrparametro IS NULL THEN
    RETURN '001', vchrCveRastreo; --regresa error de parametro no encontrado
  END IF;
  IF mnyImporteOP < (vchrparametro * 1) THEN
    RETURN '007', vchrCveRastreo; --regresa error de que el importe es menor al permitido
  END IF;}

  --Valida que exista el tipo de pago
  SELECT COUNT(*) INTO intcontador FROM tbltipopago
    WHERE intcvetipopago = intTipoPago;
  IF intcontador = 0 THEN
    RETURN '008', vchrCveRastreo; --regresa error de que no existe el tipo de pago
  END IF;

  --Valida que exista el tipo de operacion
  SELECT intcontatoper,chrdevabonachq INTO inttpooper,chrabonachq FROM tbltipopago
    WHERE intcvetipopago = intTipoPago;
  IF inttpooper = 1 THEN
    SELECT COUNT(*) INTO intcontador FROM tbltipooperacion
      WHERE intcvetpooperacion = intTipoOper;
    IF intcontador = 0 THEN
      RETURN '009', vchrCveRastreo; --regresa error de no existe tipo de operacion
    END IF;
  END IF;

  --Valida monto minimo permitido para la operacion
  SELECT mnymontomin INTO v_montomin FROM tbltipopago
    WHERE intcvetipopago = intTipoPago;
  IF mnyImporteOP < v_montomin THEN
    RETURN '007', vchrCveRastreo; --monto menor al minimo permitido para el tipo de pago
  END IF;

  --Valida el banco
  SELECT cvecesif INTO vintCveCesif FROM tblbanco
    WHERE intcvebsi = intBancoRec;
  IF vintCveCesif IS NULL THEN
    RETURN '010', vchrCveRastreo; --regresa error de banco no valido
  END IF;

  -- Obtiene el nombre del cliente (ordenante)
--  IF chrabonachq = '1' THEN
    --SELECT TRIM(nombre1) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno), TRIM(razon_social), rfc
    SELECT TRIM(nombre1) || ' ' || TRIM(nombre2) || ' ' || TRIM(apell_paterno) || ' ' || TRIM(apell_materno),
           TRIM(razon_social), rfc
      INTO vchrnombre, vchrrazonsocial, vchrRFCOrd
      --FROM bdinteg:si_cliente, bdicheq:sc_maechq
      FROM bdinteg:si_cliente
      WHERE numcte = LPAD(vchrNumCte,11,'0');
    IF vchrnombre IS NULL OR TRIM(vchrnombre) = '' THEN
      IF vchrrazonsocial IS NULL OR TRIM(vchrrazonsocial) = '' THEN
         IF intTipoPago <> 7 THEN
            RETURN '012', vchrCveRastreo; --No se encontro el cliente
         END IF
      ELSE
        LET vchrnombreord = vchrrazonsocial;
      END IF;
    ELSE
      LET vchrnombreord = vchrnombre;
    END IF;
--  END IF;

  --Valida que error si la transaccion no tiene valor
  IF chrTransaccion IS NULL OR chrTransaccion = '' THEN
    RETURN '011', vchrCveRastreo;
  END IF;

  --Valida que no se repita el folio de promocion para la fecha de operacion
  SELECT COUNT(*) INTO intcontador FROM tblpago
    WHERE chrfolioprom = chrFolio_suc AND dtfechacaptura = vchrFechaOper;
  IF intcontador > 0 THEN
    RETURN '013', vchrCveRastreo; --Folio repetido
  END IF;
  --Valida que no se repita la clave de rastreo para la fecha de operacion
  SELECT COUNT(*) INTO intcontador FROM tblpago
    WHERE chrfolioprom = vchrCveRastreo AND dtfechacaptura = vchrFechaOper;
  IF intcontador > 0 THEN
    RETURN '014', vchrCveRastreo; --Clave de rastreo repetida
  END IF;

{
  IF intTipoPago = 1 OR intTipoPago = 2 OR intTipoPago = 3 OR intTipoPago = 4 THEN
    LET chrCodSistema = '33';
    --Obtiene la clabe del ordenante
    EXECUTE PROCEDURE bditef:spobtenerccc('060','14001',vchrCuentaOrd) INTO intcodret,chrspl,vchrCLABEOrd;
    IF intcodret <> 0 THEN
      LET chrcodret = intcodret;
      RETURN chrcodret, vchrCveRastreo;
    END IF;
    LET chrCodSistema = chrCodSisSPEI;
    LET vchrCuentaOrd = vchrCLABEOrd;
  END IF;
}

--TRACE vchrCuentaOrd;
--TRACE vchrNombreBenef;
--TRACE vchrCtaBenef;
--TRACE vchrConceptoPago2;
--TRACE Length(vchrConceptoPago2);

  LET vsintLongCveRast = LENGTH(vchrcverastreo);

  IF intTipoPago = 1 THEN --TERCERO a TERCERO
    IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL OR
      vchrNombreBenef = '' OR vchrCtaBenef IS NULL OR vchrCtaBenef = '' OR vchrConceptoPago2 IS NULL
      OR vchrConceptoPago2 = '' THEN --OR decRefNum IS NULL OR decRefNum = 0
      RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
    END IF;

    IF SUBSTR(vchrCtaBenef, 1, 3) <> intBancoRec THEN
    	LET chrcodret = '800';
    	return chrcodret, vchrCveRastreo;
{
    ELSE
            LET chrCodSistema = '33';
	    --Valida CLABE del beneficiario
	    EXECUTE PROCEDURE bditef:spvalidaccc(vchrCtaBenef) INTO intcodret,chrspl;
	    IF intcodret <> 0 THEN
	      LET chrcodret = intcodret;
	      RETURN chrcodret, vchrCveRastreo;
	    END IF;
}
    END IF;

    LET chrCodSistema = chrCodSisSPEI;
    IF UPPER(chrvalconvenio) = 'S' THEN --Si se solicito validar convenio
      LET chrCodSistema = '26';
      EXECUTE PROCEDURE terceros:val_convenio_spei(SUBSTR(vchrCuentaOrd,7,11),mnyImporteOP,'01',vchrCtaBenef) INTO chrcodret;
      IF (chrcodret * 1) <> 0 THEN
        RETURN chrcodret, vchrCveRastreo;
      END IF;
      LET chrCodSistema = chrCodSisSPEI;
    END IF;
    --Obtiene folio del pago
    EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
    IF (chrcodret * 1) <> 0 THEN
      RETURN chrcodret, vchrCveRastreo;
    END IF;
    --IF decRefNum IS NULL or decRefNum = 0 THEN
    	LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    --END IF;
    INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,vchrnombreord,vchrcuentaord,
      vchrrfcord,intcvetipoctaord,vchrnombrebenef,intcvetipoctabene,vchrcuentabenef,vchrrfcbenef,
      mnyiva,intrefnumerica,vchrconceptopago2,vchrrefcobranza,chrusuarioprom,intcvetipopago,
      chrsentidopago,dtfechavalor,vchrclaverastreo,chrfolioprom,dtfechacaptura,chrmotivocanc,
      chrmotivodev,chrtopologia,chrprioridad,cvecesifbcoord,cvecesifbcodest,chrtxop, sintlongcverastreo)
      VALUES (intpktblpago,mnyImporteOP,'P',vchrnombreord,vchrCuentaOrd,vchrRFCOrd,intTipoCta,
      vchrNombreBenef,intTipoCta,vchrCtaBenef,vchrRFCBenef,mnyImporteIVA,decRefNum,
      vchrConceptoPago2,vchrRefCobranza1,chrUsuario,intTipoPago,'E',dFechaValor,vchrCveRastreo,
      chrFolio_suc,vchrFechaOper,'','',chrtopologia,'0',intBancoOrd,vintCveCesif,chrTransaccion, vsintLongCveRast);
  ELSE
    IF intTipoPago = 2 THEN --TERCERO a VENTANILLA
      IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL
        OR vchrNombreBenef = '' OR vchrConceptoPago IS NULL OR vchrConceptoPago = ''
        OR vchrClavePago IS NULL OR vchrClavePago = '' THEN
        RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
      END IF;
      --Obtiene folio del pago
      EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
      IF (chrcodret * 1) <> 0 THEN
        RETURN chrcodret, vchrCveRastreo;
      END IF;
      --IF decRefNum IS NULL or decRefNum = 0 THEN
      	  LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
      --END IF;
      INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,vchrnombreord,vchrcuentaord,
        vchrrfcord,intcvetipoctaord,vchrnombrebenef,mnyiva,vchrConceptoPago,vchrclavepago,
        chrusuarioprom,intcvetipopago,chrsentidopago,dtfechavalor,vchrclaverastreo,chrfolioprom,
        dtfechacaptura,chrmotivocanc,chrmotivodev,chrtopologia,chrprioridad,cvecesifbcoord,
        cvecesifbcodest,chrtxop,sintlongcverastreo) VALUES (intpktblpago,mnyImporteOP,'P',vchrnombreord,
        vchrCuentaOrd,vchrRFCOrd,intTipoCta,vchrNombreBenef,mnyImporteIVA,vchrConceptoPago,
        vchrClavePago,chrUsuario,intTipoPago,'E',dFechaValor,vchrCveRastreo,chrFolio_suc,
        vchrFechaOper,'','',chrtopologia,'0',intBancoOrd,vintCveCesif,chrTransaccion, vsintLongCveRast);
    ELSE
      IF intTipoPago = 3 THEN --TERCERO a TERCERO VOSTRO
        IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR vchrNombreBenef IS NULL OR vchrNombreBenef = ''
          OR vchrCtaBenef IS NULL OR vchrCtaBenef = '' OR vchrCtaBenef2 IS NULL OR vchrCtaBenef2= '' 
          OR vchrConceptoPago IS NULL
          OR vchrConceptoPago = '' OR decRefNum IS NULL OR decRefNum = 0 THEN
          RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
        END IF;
{
        LET chrCodSistema = '33';
        --Valida CLABE del beneficiario
        EXECUTE PROCEDURE bditef:spvalidaccc(vchrCtaBenef) INTO intcodret,chrspl;
        IF intcodret <> 0 THEN
          LET chrcodret = intcodret;
          RETURN chrcodret, vchrCveRastreo;
        END IF;
        LET chrCodSistema = chrCodSisSPEI;
        IF NOT vchrCtaBenef2 IS NULL OR LENGTH(vchrCtaBenef2) > 0 THEN
          LET chrCodSistema = '33';
          --Valida CLABE del beneficiario 2
          EXECUTE PROCEDURE bditef:spvalidaccc(vchrCtaBenef2) INTO intcodret,chrspl;
          IF intcodret <> 0 THEN
            LET chrcodret = intcodret;
            RETURN chrcodret, vchrCveRastreo;
          END IF;
          LET chrCodSistema = chrCodSisSPEI;
          LET intTpoCtaOpcional = intTipoCta;
        ELSE
          LET intTpoCtaOpcional = NULL;
        END IF;
}
          LET intTpoCtaOpcional = intTipoCta;
        --Obtiene folio del pago
        EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
        IF (chrcodret * 1) <> 0 THEN
          RETURN chrcodret, vchrCveRastreo;
        END IF;

        --IF decRefNum IS NULL or decRefNum = 0 THEN
    		LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    	--END IF;

        INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,vchrnombreord,vchrcuentaord,
          vchrrfcord,intcvetipoctaord,vchrnombrebenef,intcvetipoctabene,vchrcuentabenef,
          vchrnombrebenef2,vchrrfcbenef2,intcvetipoctabene2,vchrcuentabenef2,vchrConceptoPago,
          vchrconceptopago2,mnyiva,intrefnumerica,chrusuarioprom,intcvetipopago,chrsentidopago,
          dtfechavalor,vchrclaverastreo,chrfolioprom,dtfechacaptura,chrmotivocanc,chrmotivodev,
          chrtopologia,chrprioridad,cvecesifbcoord,cvecesifbcodest,chrtxop, sintlongcverastreo)
          VALUES(intpktblpago,
          mnyImporteOP,'P',vchrnombreord,vchrCuentaOrd,vchrRFCOrd,intTipoCta,vchrNombreBenef,
          intTipoCta,vchrCtaBenef,vchrNombreBenef2,vchrRFCBenef2,intTpoCtaOpcional,vchrCtaBenef2,
          vchrConceptoPago,vchrConceptoPago2,mnyImporteIVA,decRefNum,chrUsuario,intTipoPago,
          'E',dFechaValor,vchrCveRastreo,chrFolio_suc,vchrFechaOper,'','',chrtopologia,'0',
          intBancoOrd,vintCveCesif,chrTransaccion, vsintLongCveRast);

      ELSE
        IF intTipoPago = 4 THEN --TERCERO a BANCO
          IF vchrCuentaOrd IS NULL OR vchrCuentaOrd = '' OR intTipoOper IS NULL
            OR vchrConceptoPago IS NULL OR vchrConceptoPago = ''
            OR decRefNum IS NULL OR decRefNum = 0 THEN
            RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
          END IF;
          --Obtiene folio del pago
          EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
          IF (chrcodret * 1) <> 0 THEN
            RETURN chrcodret, vchrCveRastreo;
          END IF;
		  --IF decRefNum IS NULL or decRefNum = 0 THEN
    		LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    	  --END IF;
          INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,vchrnombreord,vchrcuentaord,
           vchrrfcord,intcvetipoctaord,mnyiva,vchrConceptoPago,intrefnumerica,chrusuarioprom,
           intcvetipopago,chrsentidopago,dtfechavalor,vchrclaverastreo,chrfolioprom,dtfechacaptura,
           chrmotivocanc,chrmotivodev,chrtopologia,chrprioridad,cvecesifbcoord,cvecesifbcodest,chrtxop, sintlongcverastreo)
           VALUES (intpktblpago,mnyImporteOP,'P',vchrnombreord,vchrCuentaOrd,vchrRFCOrd,intTipoCta,
           mnyImporteIVA,vchrConceptoPago,decRefNum,chrUsuario,intTipoPago,'E',dFechaValor,vchrCveRastreo,
           chrFolio_suc,vchrFechaOper,'','',chrtopologia,'0',intBancoOrd,vintCveCesif,chrTransaccion, vsintLongCveRast);
        ELSE
          IF intTipoPago = 5 THEN --BANCO a TERCERO
            IF vchrNombreBenef IS NULL OR vchrNombreBenef = '' OR vchrCtaBenef IS NULL OR vchrCtaBenef = ''  OR
            vchrConceptoPago2 IS NULL OR vchrConceptoPago2 = '' THEN
              RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
            END IF;
{
            LET chrCodSistema = '33';
            --Valida CLABE del beneficiario
            EXECUTE PROCEDURE bditef:spvalidaccc(vchrCtaBenef) INTO intcodret,chrspl;
            IF intcodret <> 0 THEN
              LET chrcodret = intcodret;
              RETURN chrcodret, vchrCveRastreo;
            END IF;
}
            LET chrCodSistema = chrCodSisSPEI;
            --Obtiene folio del pago
            EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
            IF (chrcodret * 1) <> 0 THEN
              RETURN chrcodret, vchrCveRastreo;
            END IF;
		    --IF decRefNum IS NULL or decRefNum = 0 THEN
    			LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    		--END IF;
            INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,vchrnombrebenef,
              intcvetipoctabene,vchrcuentabenef,vchrrfcbenef,mnyiva,vchrconceptopago2,
              intrefnumerica,chrusuarioprom,intcvetipopago,chrsentidopago,dtfechavalor,
              vchrclaverastreo,chrfolioprom,dtfechacaptura,chrmotivocanc,chrmotivodev,
              chrtopologia,chrprioridad,cvecesifbcoord,cvecesifbcodest,chrtxop,sintlongcverastreo)
              VALUES (intpktblpago,mnyImporteOP,'P',vchrNombreBenef,intTipoCta,
              vchrCtaBenef,vchrRFCBenef,mnyImporteIVA,vchrConceptoPago2,decRefNum,
              chrUsuario,intTipoPago,'E',dFechaValor,vchrCveRastreo,chrFolio_suc,
              vchrFechaOper,'','',chrtopologia,'0',intBancoOrd,vintCveCesif,chrTransaccion,vsintLongCveRast);
          ELSE
            IF intTipoPago = 6 THEN --BANCO a TERCERO VOSTRO
              IF vchrNombreBenef IS NULL OR vchrNombreBenef = '' OR vchrCtaBenef IS NULL
              OR vchrCtaBenef = '' OR decRefNum IS NULL OR decRefNum = 0
              OR vchrConceptoPago IS NULL OR vchrConceptoPago = '' THEN
                RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
              END IF;
{
              LET chrCodSistema = '33';
              EXECUTE PROCEDURE bditef:spvalidaccc(vchrCtaBenef) INTO intcodret,chrspl;
              IF intcodret <> 0 THEN
                LET chrcodret = intcodret;
                RETURN chrcodret, vchrCveRastreo;
              END IF;
              LET chrCodSistema = chrCodSisSPEI;
              IF NOT vchrCtaBenef2 IS NULL OR LENGTH(vchrCtaBenef2) > 0 THEN
                LET chrCodSistema = '33';
                --Valida CLABE del beneficiario 2
                EXECUTE PROCEDURE bditef:spvalidaccc(vchrCtaBenef2) INTO intcodret,chrspl;
                IF intcodret <> 0 THEN
                  LET chrcodret = intcodret;
                  RETURN chrcodret, vchrCveRastreo;
                END IF;
                LET chrCodSistema = chrCodSisSPEI;
                LET intTpoCtaOpcional = intTipoCta;
              ELSE
                LET intTpoCtaOpcional = NULL;
              END IF;
}
              LET intTpoCtaOpcional = intTipoCta;
              --Obtiene folio del pago
              EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
              IF (chrcodret * 1) <> 0 THEN
                RETURN chrcodret, vchrCveRastreo;
              END IF;
		  --IF decRefNum IS NULL or decRefNum = 0 THEN
    		    LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    		  --END IF;
              INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,vchrnombrebenef,
                intcvetipoctabene,vchrcuentabenef,vchrnombrebenef2,intcvetipoctabene2,
                vchrcuentabenef2,vchrrfcbenef2,mnyiva,vchrConceptoPago,vchrconceptopago2,
                intrefnumerica,chrusuarioprom,intcvetipopago,chrsentidopago,dtfechavalor,
                vchrclaverastreo,chrfolioprom,dtfechacaptura,chrmotivocanc,chrmotivodev,
                chrtopologia,chrprioridad,cvecesifbcoord,cvecesifbcodest,chrtxop, sintlongcverastreo)
                VALUES (intpktblpago,mnyImporteOP,'P',vchrNombreBenef,intTipoCta,
                vchrCtaBenef,vchrNombreBenef2,intTpoCtaOpcional,vchrCtaBenef2,vchrRFCBenef2,
                mnyImporteIVA,vchrConceptoPago,vchrConceptoPago2,decRefNum,chrUsuario,
                intTipoPago,'E',dFechaValor,vchrCveRastreo,chrFolio_suc,vchrFechaOper,
                '','',chrtopologia,'0',intBancoOrd,vintCveCesif,chrTransaccion, vsintLongCveRast);
            ELSE
              IF intTipoPago = 7 THEN --BANCO a BANCO
                IF intTipoOper IS NULL --OR decRefNum IS NULL OR decRefNum = 0
                  OR vchrConceptoPago IS NULL OR vchrConceptoPago = '' THEN
                  RETURN '011', vchrCveRastreo; --regresa error de faltan campos obligatorios
                END IF;
                --Obtiene folio del pago
                EXECUTE PROCEDURE sp_obtsigfolioop('TBLPAGO') INTO chrcodret, intpktblpago;
                IF (chrcodret * 1) <> 0 THEN
                  RETURN chrcodret, vchrCveRastreo;
                END IF;
		    --IF decRefNum IS NULL or decRefNum = 0 THEN
    			LET decRefNum = substr(LPAD(intpktblpago, 12, '0'), -7);
    		   --END IF;
                INSERT INTO tblpago(intpkpago,mnyimporte,chrestatusenvio,mnyiva,vchrConceptoPago,
                  intrefnumerica,chrusuarioprom,intcvetipopago,intcvetpooperacion,chrsentidopago,
                  dtfechavalor,vchrclaverastreo,chrfolioprom,dtfechacaptura,chrmotivocanc,
                  chrmotivodev,chrtopologia,chrprioridad,cvecesifbcoord,cvecesifbcodest,chrtxop,sintlongcverastreo)
                  VALUES (intpktblpago,mnyImporteOP,'P',mnyImporteIVA,vchrConceptoPago,decRefNum,
                  chrUsuario,intTipoPago,intTipoOper,'E',dFechaValor,vchrCveRastreo,chrFolio_suc,
                  vchrFechaOper,'','',chrtopologia,'0',intBancoOrd,vintCveCesif,chrTransaccion,vsintLongCveRast);
              ELSE
                RETURN '008', vchrCveRastreo; --regresa el error de que no existe el tipo de pago
              END IF;  --IF intTipoPago = 7
            END IF;  --IF intTipoPago = 6
          END IF;  --IF intTipoPago = 5
        END IF;  --IF intTipoPago = 4
      END IF;  --IF intTipoPago = 3
    END IF;  --IF intTipoPago = 2
  END IF;  --IF intTipoPago = 1

  RETURN chrcodret, vchrCveRastreo;

END PROCEDURE;