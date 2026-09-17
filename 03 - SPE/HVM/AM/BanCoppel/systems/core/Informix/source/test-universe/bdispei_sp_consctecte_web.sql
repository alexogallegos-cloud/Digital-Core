CREATE PROCEDURE "informix".sp_consctecte_web( pchrSucursal      CHAR(4),
                                           pvchrClaveRastreo CHAR(30),
                                           pvchrCuentaOrd    CHAR(20),
                                           pintContador      INTEGER,
                                           pfecini           CHAR(10),
                                           pfecfin           CHAR(10) )

RETURNING CHAR(5),  CHAR(100), CHAR(40),      CHAR(20),      CHAR(20),  CHAR(40),
          CHAR(20), CHAR(18),  CHAR(40),      DECIMAL(10,0), INTEGER,   CHAR(20),
          CHAR(20), CHAR(30),  CHAR(20),      CHAR(20),      CHAR(255), DECIMAL(14,2),
          CHAR(10), CHAR(8),   DECIMAL(14,2), DECIMAL(14,2);
    
    -- // Definicion de variables
    DEFINE vchrcodret         CHAR(5);
    DEFINE vchrcodret2        CHAR(5);
    DEFINE vchrcodret3        CHAR(50);
    DEFINE sql_err            INTEGER;
    DEFINE isam_err           INTEGER;
    DEFINE desc_err           CHAR(50);
    DEFINE cVarDataErr        CHAR(100);

    DEFINE vvchrNombreOrd      CHAR(40);
    DEFINE vvchrCuentaOrd      CHAR(20);
    DEFINE vvchrcteOrd         CHAR(20);
    DEFINE vvchrNombreBenef    CHAR(40);
    DEFINE vvchrCuentaBenef    CHAR(20);
    DEFINE vvchrRFCBenef       CHAR(18);
    DEFINE vvchrConceptoPago2  CHAR(40);
    DEFINE vintRefNumerica     DECIMAL(10,0);
    DEFINE vcveCesifbcodest    INTEGER;
    DEFINE vvchrNombrecorto    CHAR(20);
    DEFINE vvchrEstatusenvio   CHAR(20);
    DEFINE vvchrClaverastreo   CHAR(30);
    DEFINE vdtmHoraCargo       CHAR(20);
    DEFINE vdtmHoraCancela     CHAR(20);
    DEFINE vvchrMotivodev      CHAR(255);
    DEFINE lcta                SMALLINT;
    DEFINE btipo               SMALLINT;
    DEFINE vintcontador        INTEGER;
    DEFINE vMonto              DECIMAL(14,2);
    DEFINE vMontoComis         DECIMAL(14,2);
    DEFINE vMontoIva           DECIMAL(14,2);
    DEFINE vcausadev           INTEGER;
    DEFINE vdescausadev        CHAR(100);
    DEFINE vfechahoy           DATE;
    DEFINE vdfechavalor        DATE;
    DEFINE vcfechavalor        CHAR(10);
    DEFINE vusuario            CHAR(8);
    DEFINE vcuenta             CHAR(20);
    DEFINE vtrancomis          CHAR(4);
    DEFINE vtraniva            CHAR(4);
    
    DEFINE vchrCtaClabe        CHAR(18);
    DEFINE vchrNumTarjeta      CHAR(16);
    DEFINE vchrCuenta          CHAR(20);
    DEFINE vcEstatusenvio      CHAR(1);
    DEFINE vpri_dia_mes        DATE;
    DEFINE vfechaini           DATE;
	DEFINE vfechaini_valida    DATE;
    DEFINE vfechafin           DATE;
	DEFINE vfechafin_valida    DATE;
	DEFINE vcuentaord          CHAR(20);
    DEFINE vchrTelefono        CHAR(10);
    DEFINE vexiste             SMALLINT;

    -- // Inicializa Variables
    LET vchrcodret 	       = '00000';
    LET vchrcodret2	       = '';
    LET vchrcodret3	       = '';
    LET sql_err            = 0;
    LET isam_err           = 0;
    LET desc_err           = '';
    LET cVarDataErr        = '';
    LET vvchrNombreOrd     = '';
    LET vvchrCuentaOrd     = '';
    LET vvchrcteOrd        = '';
    LET vvchrNombreBenef   = '';
    LET vvchrCuentaBenef   = '';
    LET vvchrRFCBenef      = '';
    LET vvchrConceptoPago2 = '';
    LET vintRefNumerica    = 0;
    LET vcveCesifbcodest   = 0;
    LET vvchrNombrecorto   = '';
    LET vvchrEstatusenvio  = '';
    LET vvchrClaverastreo  = '';
    LET vdtmHoraCargo      = current::CHAR(25);
    LET vdtmHoraCancela    = current::CHAR(25);
    LET vvchrMotivodev     = '';
    LET lcta               = 0;
    LET btipo              = 0;
    LET vintcontador       = 0;
    LET vMonto             = 0;
    LET vMontoComis        = 0;
    LET vMontoIva          = 0;
    LET vcausadev          = 0;
    LET vdescausadev       = "";
    LET vdfechavalor       = "";
    LET vcfechavalor       = "";
    LET vusuario           = "";
    LET vcuenta            = "";
    LET vtrancomis         = "";
    LET vtraniva           = "";

    LET vdtmHoraCargo   = SUBSTR(vdtmHoraCargo,12,8);
    LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);
    
    LET vchrCtaClabe   = '';
    LET vchrNumTarjeta = '';
    LET vchrCuenta     = '';
    LET vcEstatusenvio = '';
    LET vpri_dia_mes   = '';
    LET vfechaini      = '';
    LET vfechafin      = ''; 
	LET vcuentaord     = '';
    LET vchrTelefono   = '';
    LET vexiste        = 0;
    
   -- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consctecte.out";
   --SET DEBUG FILE TO "/informix/sp_consctecte.out";
   --TRACE ON;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consctecte.err";
        TRACE ON;
        IF sql_err <>  0 THEN
            LET vchrcodret  = sql_err;
            LET vchrcodret2 = isam_err;
            LET vchrcodret3 = desc_err;
            RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva;
        END IF
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET pchrSucursal = TRIM(pchrSucursal);
    LET pvchrClaveRastreo = TRIM(pvchrClaveRastreo);
    LET pvchrCuentaOrd = TRIM(pvchrCuentaOrd);
    LET pintContador = pintContador;
    LET pfecini = TRIM(pfecini);
    LET pfecfin = TRIM(pfecfin);
    
    -- // DEFINE EL TIPO DE BUSQUEDA QUE SE VA A REALIZAR
    IF trim(pvchrClaveRastreo) = '' THEN
        LET lcta = LENGTH(trim(pvchrCuentaOrd));
        
        IF lcta > 0 THEN
            -- // Cuenta Clabe
            IF lcta = 18 THEN 
                LET bTipo = 1;
                LET vchrCtaClabe = TRIM(pvchrCuentaOrd);
				LET vchrCuenta = SUBSTR(pvchrCuentaOrd,7,11);
            -- // Tarjeta
            ELIF lcta = 16 THEN 
                LET bTipo = 2;
                LET vchrNumTarjeta = TRIM(pvchrCuentaOrd);
                
                SELECT cuenta 
                  INTO vcuenta
                  FROM bdicheq:sc_tarjeta
                 WHERE empresa = '001'
                   AND num_tarjeta = vchrNumTarjeta
                   AND status_tar ='A';
                   
                IF TRIM(vcuenta) = '' OR vcuenta IS NULL THEN
                    LET vchrcodret = '00031';
                    LET cVarDataErr = "La tarjeta no existe o no esta activa";
                ELSE
                    LET vchrCuenta = vcuenta;
                END IF;
            -- // Cuenta de Cheques
            ELIF lcta = 11 THEN 
                LET bTipo = 2;
                LET vchrCuenta = TRIM(pvchrCuentaOrd);
            ELSE
                LET vchrcodret = '00031';
                LET cVarDataErr = "La longitud de la cuenta es incorrecto";
            END IF;
        -- // Busqueda Por Sucursal
        ELIF pchrSucursal <> '' THEN 
            LET bTipo = 3;
            
            IF pchrSucursal = '0000' THEN
                LET bTipo = 4;
            END IF;
        ELSE
            LET vchrcodret = '00031';
            LET cVarDataErr = "La longitud de la cuenta es incorrecto";
        END IF;
    ELSE
        LET bTipo = 0;
    END IF;
    
    -- // termina el proceso para el caso de no haber pasado la validacion de la cuenta
    IF vchrcodret <> '00000' THEN
        RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva;
    END IF;

    -- // Carga los Codigos de la Transaccion de Comision e IVA 
    -- // Trae la transaccion de la Comision
    SELECT vchrValor
      INTO vtrancomis
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_COMISION';

    IF vtrancomis IS NULL OR vtrancomis = '' THEN
        LET vtrancomis = '0000'; --Falta parametro de transaccion comision.
    END IF;
    
    -- // Trae la transaccion del IVA de la Comision
    SELECT vchrValor
      INTO vtraniva
      FROM tblparametros
     WHERE vchrcveparametro = 'TRANSACC_IVACOM';
     
    IF vtraniva IS NULL OR vtraniva = '' THEN
        LET vtraniva = '0000'; --Falta parametro de transaccion iva.
    END IF;
    
    -- // seleccion la fecha de hoy vfechahoy
    SELECT vchrValor 
      INTO vcfechavalor
      FROM tblParametros
     WHERE vchrCveParametro = 'FECHA_OPERACION';
     
    LET vfechahoy = vcfechavalor[4,5]||"/"||vcfechavalor[1,2]||"/"||vcfechavalor[7,10];
    LET vpri_dia_mes = vcfechavalor[4,5]||'/'||'01'||'/'||vcfechavalor[7,10];
    
	
	/*
    IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN
        LET vfechaini = vpri_dia_mes - 3 UNITS MONTH;
    ELSE
        LET vfechaini = pfecini;
    END IF;
    
    IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN
        LET vfechafin = vfechahoy - 1 UNITS DAY;
    ELSE
        LET vfechafin = pfecfin;
    END IF;
	*/
	
	--VALIDA SI LA FECHA INICIO ESTA EN BLANCO 
	IF pfecini is null OR pfecini = '' OR pfecini = ' ' THEN 
	   LET vfechaini = vfechahoy - 2 UNITS MONTH;
	ELSE 
	   LET vfechaini = pfecini;
	END IF; 
	
	--VALIDA SI LA FECHA FIN ESTA EN BLANCO
	IF pfecfin is null OR pfecfin = '' OR pfecfin = ' ' THEN
	   LET vfechafin = vfechahoy - 1 UNITS DAY;
	ELSE 
	   LET vfechafin = pfecfin;
	END IF;
	
	--VALIDA SI LA FECHA INICIO ES MENOR A 2 MESES ATRAS 
	LET vfechaini_valida =  vfechahoy - 2 UNITS MONTH;
		
    IF vfechaini_valida <= vfechaini THEN 
	   LET vfechaini = vfechaini; 
	   LET vfechafin = vfechafin;
	ELSE 
	   LET vfechaini = vfechahoy - 2 UNITS MONTH;
	   LET vfechafin = vfechahoy - 1 UNITS DAY; 
	END IF;
   
    
    -- // BUSQUEDA POR CLAVE DE RASTREO
    IF bTipo = 0 THEN 
        SELECT UNIQUE cuenta
          INTO vchrCuenta
          FROM tbldetranpago
         WHERE clave_rastreo = pvchrClaveRastreo
           AND sucursal > '0000'; 
        
        FOREACH
            SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              INTO vvchrNombreOrd, vvchrCuentaOrd, vvchrcteOrd, vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2, vintRefNumerica, vcveCesifbcodest,
                   vvchrNombrecorto, vMonto, vcEstatusenvio, vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev, vcausadev, vusuario, vdfechavalor
              FROM bdicheq:sc_maechq mto,
                   tblpago pago,
                   tblbanco bco
             WHERE mto.cuenta = vchrCuenta
               AND pago.vchrclaverastreo = pvchrClaveRastreo
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
			   AND pago.cvecesifbcodest = bco.cvecesif
            UNION ALL
            SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              FROM bdicheq:sc_maechq mto,
                   tblhistpago pago,
                   tblbanco bco
             WHERE mto.cuenta = vchrCuenta
               AND pago.vchrclaverastreo = pvchrClaveRastreo
               AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
			   AND pago.cvecesifbcodest = bco.cvecesif
             ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo
        END FOREACH;
        
        IF   vcEstatusenvio = 'L' THEN LET vvchrEstatusenvio = 'LIQUIDADO';
        ELIF vcEstatusenvio = 'A' THEN LET vvchrEstatusenvio = 'ABONADO';
        ELIF vcEstatusenvio = 'D' THEN LET vvchrEstatusenvio = 'DEVUELTO';
        ELIF vcEstatusenvio = 'E' THEN LET vvchrEstatusenvio = 'ENVIADO';
        ELIF vcEstatusenvio = 'R' THEN LET vvchrEstatusenvio = 'RECIBIDO';
        ELIF vcEstatusenvio = 'N' THEN LET vvchrEstatusenvio = 'PENDIENTE ENVIO';
        ELIF vcEstatusenvio = 'C' THEN LET vvchrEstatusenvio = 'CANCELADO';
        ELSE                           LET vvchrEstatusenvio = 'OTRO'; END IF;
        
        LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');
        
        IF NOT (vcausadev IS NULL or vcausadev = 0) THEN
            SELECT vchrdescripcion 
              INTO vdescausadev
              FROM tblcausadev
             WHERE intcvecausadev = vcausadev;
            
            IF Trim(vdescausadev) != "" THEN
                LET vvchrMotivodev = Trim(vdescausadev);
            END IF
        END IF
        
        LET vdtmHoraCargo = SUBSTR(vdtmHoraCargo,12,8);
        LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);

        SELECT NVL(monto_tot,0) 
          INTO vMontoComis
          FROM tbldetranpago
         WHERE clave_rastreo = vvchrClaverastreo
           AND transacc = vtrancomis;

        SELECT NVL(monto_tot,0) 
          INTO vMontoIva
          FROM tbldetranpago
         WHERE clave_rastreo = vvchrClaverastreo
           AND transacc = vtraniva;
           
        SELECT COUNT(*)
          INTO vexiste
          FROM bdicheq:sc_cuenta_telefono
         WHERE telefono = vvchrCuentaOrd;
         
        IF vexiste > 0 THEN
            LET vvchrCuentaOrd = vvchrCuentaOrd;
        ELSE
            LET vvchrCuentaOrd = SUBSTR(vvchrCuentaOrd,7,11);
        END IF;

        RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva;
    END IF;
    
    -- // BUSQUEDA POR CUENTA CLABE
    IF bTipo = 1 THEN
		--RQI 27 218 Optimiza costo Rec BD
		 SELECT mto.num_cte, mto.cuenta_clabe
		 FROM bdicheq:sc_maechq  mto 
		 WHERE mto.cuenta = vchrCuenta
		 INTO TEMP sc_maechq_temp with no log;
		 CREATE INDEX sc_maechq_temp_idx on sc_maechq_temp (cuenta_clabe);
	
        FOREACH
            SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              INTO vvchrNombreOrd, vvchrCuentaOrd, vvchrcteOrd, vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2, vintRefNumerica, vcveCesifbcodest,
                   vvchrNombrecorto, vMonto, vcEstatusenvio, vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev, vcausadev, vusuario, vdfechavalor
              FROM bdicheq:sc_maechq_temp mto,
                   tblpago pago,
                   tblbanco bco
             WHERE mto.cuenta_clabe = pago.vchrcuentaord
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
			   AND pago.cvecesifbcodest = bco.cvecesif
            UNION ALL
            SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              FROM bdicheq:sc_maechq_temp mto,
                   tblhistpago pago,
                   tblbanco bco
             WHERE mto.cuenta_clabe = pago.vchrcuentaord
               AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin 
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
			   AND pago.cvecesifbcodest = bco.cvecesif
             ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo
             
            IF   vcEstatusenvio = 'L' THEN LET vvchrEstatusenvio = 'LIQUIDADO';
            ELIF vcEstatusenvio = 'A' THEN LET vvchrEstatusenvio = 'ABONADO';
            ELIF vcEstatusenvio = 'D' THEN LET vvchrEstatusenvio = 'DEVUELTO';
            ELIF vcEstatusenvio = 'E' THEN LET vvchrEstatusenvio = 'ENVIADO';
            ELIF vcEstatusenvio = 'R' THEN LET vvchrEstatusenvio = 'RECIBIDO';
            ELIF vcEstatusenvio = 'N' THEN LET vvchrEstatusenvio = 'PENDIENTE ENVIO';
            ELIF vcEstatusenvio = 'C' THEN LET vvchrEstatusenvio = 'CANCELADO';
            ELSE                           LET vvchrEstatusenvio = 'OTRO'; END IF;
            
            LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');
             
            IF NOT (vcausadev IS NULL or vcausadev = 0) then
                SELECT vchrdescripcion 
                  INTO vdescausadev
                  FROM tblcausadev
                 WHERE intcvecausadev = vcausadev;
                
                IF TRIM(vdescausadev) != "" THEN
                    LET vvchrMotivodev = TRIM(vdescausadev);
                END IF;
            END IF;
            
            LET vdtmHoraCargo = SUBSTR(vdtmHoraCargo,12,8);
            LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);

            SELECT NVL(monto_tot,0) 
              INTO vMontoComis
              FROM tbldetranpago
             WHERE clave_rastreo = vvchrClaverastreo
               AND transacc = vtrancomis;

            SELECT NVL(monto_tot,0) 
              INTO vMontoIva
              FROM tbldetranpago
             WHERE clave_rastreo = vvchrClaverastreo
               AND transacc = vtraniva;

            LET vintcontador = vintcontador + 1;
            
            IF vintcontador <= pintContador THEN
                CONTINUE FOREACH;
            ELSE
                RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva WITH RESUME;
            END IF;
        END FOREACH;
    END IF;
    
    -- // BUSQUEDA POR CUENTA DE CHEQUES
    IF bTipo = 2 THEN
        SELECT telefono
          INTO vchrTelefono
          FROM bdicheq:sc_cuenta_telefono
         WHERE cuenta = vchrCuenta;
		 --RQI 27 218 Optimiza costo Reco BD
		 SELECT mto.num_cte, mto.cuenta, mto.cuenta_clabe
		 FROM bdicheq:sc_maechq  mto --, tblpago pago 
		 WHERE mto.cuenta = vchrCuenta
		 INTO TEMP sc_maechq_temp2 with no log;
		 CREATE INDEX sc_maechq_temp2_idx on sc_maechq_temp2 (cuenta);
		 CREATE INDEX sc_maechq_temp2_idx2 on sc_maechq_temp2 (cuenta_clabe);
         
        IF vchrTelefono is not null OR vchrTelefono <> '' THEN
            FOREACH
                SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                       pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                       pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                       nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
                  INTO vvchrNombreOrd, vvchrCuentaOrd, vvchrcteOrd, vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2, vintRefNumerica, vcveCesifbcodest,
                       vvchrNombrecorto, vMonto, vcEstatusenvio, vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev, vcausadev, vusuario, vdfechavalor
                  FROM bdicheq:sc_maechq_temp2 mto,
                       tblpago pago,
                       tblbanco bco
                 WHERE mto.cuenta_clabe = pago.vchrcuentaord
                   AND pago.chrsentidopago = 'E'
                   AND pago.intcvetipopago = 1
                   AND pago.cvecesifbcodest = bco.cvecesif
                UNION ALL
                SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                       pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                       pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                       nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
                  FROM bdicheq:sc_maechq_temp2 mto,
                       tblhistpago pago,
                       tblbanco bco
                 WHERE mto.cuenta_clabe = pago.vchrcuentaord
                   AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin 
                   AND pago.chrsentidopago = 'E'
                   AND pago.intcvetipopago = 1
                   AND pago.cvecesifbcodest = bco.cvecesif
                UNION ALL
                SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                       pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                       pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                       nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
                  FROM bdicheq:sc_maechq_temp2 mto,
                       tblpago pago,
                       tblbanco bco
                 WHERE mto.cuenta = vchrCuenta
                   AND pago.chrsentidopago = 'E'
                   AND pago.intcvetipopago = 1
                   AND pago.cvecesifbcodest = bco.cvecesif
                   AND pago.vchrcuentaord = vchrTelefono
                UNION ALL
                SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                       pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                       pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                       nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
                  FROM bdicheq:sc_maechq_temp2 mto,
                       tblhistpago pago,
                       tblbanco bco
                 WHERE mto.cuenta = vchrCuenta
                   AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin 
                   AND pago.chrsentidopago = 'E'
                   AND pago.intcvetipopago = 1
                   AND pago.cvecesifbcodest = bco.cvecesif
                   AND pago.vchrcuentaord = vchrTelefono
                 ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo
                 
                IF   vcEstatusenvio = 'L' THEN LET vvchrEstatusenvio = 'LIQUIDADO';
                ELIF vcEstatusenvio = 'A' THEN LET vvchrEstatusenvio = 'ABONADO';
                ELIF vcEstatusenvio = 'D' THEN LET vvchrEstatusenvio = 'DEVUELTO';
                ELIF vcEstatusenvio = 'E' THEN LET vvchrEstatusenvio = 'ENVIADO';
                ELIF vcEstatusenvio = 'R' THEN LET vvchrEstatusenvio = 'RECIBIDO';
                ELIF vcEstatusenvio = 'N' THEN LET vvchrEstatusenvio = 'PENDIENTE ENVIO';
                ELIF vcEstatusenvio = 'C' THEN LET vvchrEstatusenvio = 'CANCELADO';
                ELSE                           LET vvchrEstatusenvio = 'OTRO'; END IF;
                
                LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');
                 
                IF NOT (vcausadev IS NULL or vcausadev = 0) THEN
                    SELECT vchrdescripcion 
                      INTO vdescausadev
                      FROM tblcausadev
                     WHERE intcvecausadev = vcausadev;
                    
                    IF TRIM(vdescausadev) != "" THEN
                        LET vvchrMotivodev = TRIM(vdescausadev);
                    END IF;
                END IF;
                
                LET vdtmHoraCargo = SUBSTR(vdtmHoraCargo,12,8);
                LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);

                SELECT NVL(monto_tot,0) 
                  INTO vMontoComis
                  FROM tbldetranpago
                 WHERE clave_rastreo = vvchrClaverastreo
                   AND transacc = vtrancomis;

                SELECT NVL(monto_tot,0) 
                  INTO vMontoIva
                  FROM tbldetranpago
                 WHERE clave_rastreo = vvchrClaverastreo
                   AND transacc = vtraniva;

                LET vintcontador = vintcontador + 1;
                
                IF vintcontador <= pintContador THEN
                    CONTINUE FOREACH;
                ELSE
                    RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva WITH RESUME;
                END IF;
            END FOREACH;
        ELSE
            FOREACH
                SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                       pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                       pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                       nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
                  INTO vvchrNombreOrd, vvchrCuentaOrd, vvchrcteOrd, vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2, vintRefNumerica, vcveCesifbcodest,
                       vvchrNombrecorto, vMonto, vcEstatusenvio, vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev, vcausadev, vusuario, vdfechavalor
                  FROM bdicheq:sc_maechq_temp2 mto,
                       tblpago pago,
                       tblbanco bco
                 WHERE mto.cuenta_clabe = pago.vchrcuentaord
                   AND pago.chrsentidopago = 'E'
                   AND pago.intcvetipopago = 1
                   AND pago.cvecesifbcodest = bco.cvecesif
                UNION ALL
                SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                       pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                       pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                       nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
                  FROM bdicheq:sc_maechq_temp2 mto,
                       tblhistpago pago,
                       tblbanco bco
                 WHERE mto.cuenta_clabe = pago.vchrcuentaord
                   AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin 
                   AND pago.chrsentidopago = 'E'
                   AND pago.intcvetipopago = 1
                   AND pago.cvecesifbcodest = bco.cvecesif
                 ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo
                 
                IF   vcEstatusenvio = 'L' THEN LET vvchrEstatusenvio = 'LIQUIDADO';
                ELIF vcEstatusenvio = 'A' THEN LET vvchrEstatusenvio = 'ABONADO';
                ELIF vcEstatusenvio = 'D' THEN LET vvchrEstatusenvio = 'DEVUELTO';
                ELIF vcEstatusenvio = 'E' THEN LET vvchrEstatusenvio = 'ENVIADO';
                ELIF vcEstatusenvio = 'R' THEN LET vvchrEstatusenvio = 'RECIBIDO';
                ELIF vcEstatusenvio = 'N' THEN LET vvchrEstatusenvio = 'PENDIENTE ENVIO';
                ELIF vcEstatusenvio = 'C' THEN LET vvchrEstatusenvio = 'CANCELADO';
                ELSE                           LET vvchrEstatusenvio = 'OTRO'; END IF;
                
                LET vcfechavalor = to_char(vdfechavalor, '%d/%m/%Y');
                 
                IF NOT (vcausadev IS NULL or vcausadev = 0) THEN
                    SELECT vchrdescripcion 
                      INTO vdescausadev
                      FROM tblcausadev
                     WHERE intcvecausadev = vcausadev;
                    
                    IF TRIM(vdescausadev) != "" THEN
                        LET vvchrMotivodev = TRIM(vdescausadev);
                    END IF;
                END IF;
                
                LET vdtmHoraCargo = SUBSTR(vdtmHoraCargo,12,8);
                LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);

                SELECT NVL(monto_tot,0) 
                  INTO vMontoComis
                  FROM tbldetranpago
                 WHERE clave_rastreo = vvchrClaverastreo
                   AND transacc = vtrancomis;

                SELECT NVL(monto_tot,0) 
                  INTO vMontoIva
                  FROM tbldetranpago
                 WHERE clave_rastreo = vvchrClaverastreo
                   AND transacc = vtraniva;

                LET vintcontador = vintcontador + 1;
                
                IF vintcontador <= pintContador THEN
                    CONTINUE FOREACH;
                ELSE
                    RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva WITH RESUME;
                END IF;
            END FOREACH;
        END IF;
    END IF;
    
    -- AAME 06022020 RQI 27 218 Contemplar solo los estatus Liquidado(L), Cancelado(C) y Devuelto(D)
    -- // BUSQUEDA POR SUCURSAL
    IF bTipo = 3 THEN
        FOREACH
            SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd /*, mto.num_cte*/, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              INTO vvchrNombreOrd, vvchrCuentaOrd, /*vvchrcteOrd,*/ vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2, vintRefNumerica, vcveCesifbcodest,
                   vvchrNombrecorto, vMonto, vcEstatusenvio, vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev, vcausadev, vusuario, vdfechavalor
              FROM tblpago pago,
                   tblbanco bco,
                   tbldetranpago det
             WHERE pago.cvecesifbcodest = bco.cvecesif
               AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin
               AND pago.chrsentidopago = 'E'
			   AND det.empresa = '001'
               AND pago.intcvetipopago = 1
               AND pago.vchrclaverastreo = det.clave_rastreo
               AND det.transacc = "0274"	
               AND det.sucursal = pchrSucursal		
			   AND pago.chrestatusenvio IN ('L','D','C')			   
             UNION ALL
            SELECT DISTINCT {+INDEX(tblbanco xak1tblbanco2)} pago.vchrNombreOrd, pago.vchrCuentaOrd /*, mto.num_cte*/, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              FROM tblhistpago pago,
                   tblbanco bco,
                   tblhistdetranpago det
             WHERE pago.cvecesifbcodest = bco.cvecesif
               AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
			   AND det.empresa = '001'
               AND pago.vchrclaverastreo = det.clave_rastreo
			   AND det.transacc = "0274"
               AND det.sucursal = pchrSucursal
			   AND pago.chrestatusenvio IN ('L','D','C')
             ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo

            IF LENGTH(TRIM(vvchrCuentaOrd)) > 10 THEN
				LET vvchrCuentaOrd = SUBSTR(vvchrCuentaOrd,7,11) ;
				SELECT num_cte 
				 INTO vvchrcteOrd
				 FROM bdicheq:sc_maechq 
				WHERE empresa='001' 
		        AND cuenta = vvchrCuentaOrd;
			ELSE
				SELECT num_cte 
				 INTO vvchrcteOrd
			     FROM bdicheq:sc_cuenta_telefono
				WHERE telefono =  vvchrCuentaOrd;
			END IF;
             
            IF   vcEstatusenvio = 'L' THEN LET vvchrEstatusenvio = 'LIQUIDADO';
            ELIF vcEstatusenvio = 'A' THEN LET vvchrEstatusenvio = 'ABONADO';
            ELIF vcEstatusenvio = 'D' THEN LET vvchrEstatusenvio = 'DEVUELTO';
            ELIF vcEstatusenvio = 'E' THEN LET vvchrEstatusenvio = 'ENVIADO';
            ELIF vcEstatusenvio = 'R' THEN LET vvchrEstatusenvio = 'RECIBIDO';
            ELIF vcEstatusenvio = 'N' THEN LET vvchrEstatusenvio = 'PENDIENTE ENVIO';
            ELIF vcEstatusenvio = 'C' THEN LET vvchrEstatusenvio = 'CANCELADO';
            ELSE                           LET vvchrEstatusenvio = 'OTRO'; END IF;
            
            LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');
            
            IF NOT (vcausadev IS NULL or vcausadev = 0) THEN
                SELECT vchrdescripcion 
                  INTO vdescausadev
                  FROM tblcausadev
                 WHERE intcvecausadev = vcausadev;
                
                IF TRIM(vdescausadev) != "" THEN
                    LET vvchrMotivodev = TRIM(vdescausadev);
                END IF;
            END IF;
            
            LET vdtmHoraCargo = SUBSTR(vdtmHoraCargo,12,8);
            LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);

            SELECT NVL(monto_tot,0) 
              INTO vMontoComis
              FROM tbldetranpago
             WHERE clave_rastreo = vvchrClaverastreo
               AND transacc = vtrancomis;

            SELECT NVL(monto_tot,0) 
              INTO vMontoIva
              FROM tbldetranpago
             WHERE clave_rastreo = vvchrClaverastreo
               AND transacc = vtraniva;

            LET vintcontador = vintcontador + 1;
            
            IF vintcontador <= pintContador THEN
                CONTINUE FOREACH;
            ELSE
                RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva WITH RESUME;
            END IF;
			
        END FOREACH;
		LET vchrcodret = '00001';
                RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva WITH RESUME;
    END IF;
    
    -- // BUSQUEDA POR FECHA (reporte de operaciones)
    IF bTipo = 4 THEN 
       /*
        FOREACH
            SELECT DISTINCT pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              INTO vvchrNombreOrd, vvchrCuentaOrd, vvchrcteOrd, vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2, vintRefNumerica, vcveCesifbcodest,
                   vvchrNombrecorto, vMonto, vcEstatusenvio, vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev, vcausadev, vusuario, vdfechavalor
              FROM bdicheq:sc_maechq mto,
                   tblpago pago,
                   tblbanco bco
             WHERE mto.empresa = '001'
               AND mto.cuenta = SUBSTR(pago.vchrcuentaord,7,11)
			   AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
               AND pago.cvecesifbcodest = bco.cvecesif
               AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin
            UNION ALL
            SELECT DISTINCT pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              FROM bdicheq:sc_maechq mto,
                   tblhistpago pago,
                   tblbanco bco
             WHERE mto.empresa = '001'
               AND mto.cuenta = SUBSTR(pago.vchrcuentaord,7,11)
			   AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin 
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
               AND pago.cvecesifbcodest = bco.cvecesif
            UNION ALL
            SELECT DISTINCT pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              FROM bdicheq:sc_maechq mto,
                   tblpago pago,
                   tblbanco bco,
                   bdicheq:sc_cuenta_telefono tel
             WHERE mto.empresa = '001'
               AND mto.cuenta = tel.cuenta
			   AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
               AND pago.cvecesifbcodest = bco.cvecesif 
               AND tel.telefono = pago.vchrcuentaord
			   AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin
            UNION ALL
            SELECT DISTINCT pago.vchrNombreOrd, pago.vchrCuentaOrd, mto.num_cte, pago.vchrNombreBenef, pago.vchrCuentaBenef, pago.vchrRFCBenef,
                   pago.vchrConceptoPago2, pago.intRefNumerica, pago.cvecesifbcodest, bco.vchrnombrecorto, pago.mnyimporte, pago.chrestatusenvio,
                   pago.vchrclaverastreo, nvl(pago.dtmhoracargo::char(20),''), nvl(pago.dtmhoracancela::char(20),''), nvl(pago.vchrmotivodev,''),
                   nvl(pago.intcvecausadev,0), pago.chrusuarioprom, pago.dtfechacaptura
              FROM bdicheq:sc_maechq mto,
                   tblhistpago pago,
                   tblbanco bco,
                   bdicheq:sc_cuenta_telefono tel
             WHERE mto.empresa = '001'
               AND mto.cuenta = tel.cuenta
			   AND pago.dtfechacaptura BETWEEN vfechaini AND vfechafin 
               AND pago.chrsentidopago = 'E'
               AND pago.intcvetipopago = 1
               AND pago.cvecesifbcodest = bco.cvecesif
               AND tel.telefono = pago.vchrcuentaord
             ORDER BY pago.dtfechacaptura, pago.vchrclaverastreo
             
            IF   vcEstatusenvio = 'L' THEN LET vvchrEstatusenvio = 'LIQUIDADO';
            ELIF vcEstatusenvio = 'A' THEN LET vvchrEstatusenvio = 'ABONADO';
            ELIF vcEstatusenvio = 'D' THEN LET vvchrEstatusenvio = 'DEVUELTO';
            ELIF vcEstatusenvio = 'E' THEN LET vvchrEstatusenvio = 'ENVIADO';
            ELIF vcEstatusenvio = 'R' THEN LET vvchrEstatusenvio = 'RECIBIDO';
            ELIF vcEstatusenvio = 'N' THEN LET vvchrEstatusenvio = 'PENDIENTE ENVIO';
            ELIF vcEstatusenvio = 'C' THEN LET vvchrEstatusenvio = 'CANCELADO';
            ELSE                           LET vvchrEstatusenvio = 'OTRO'; END IF;
            
            LET vcfechavalor = TO_CHAR(vdfechavalor, '%d/%m/%Y');
             
            IF NOT (vcausadev IS NULL or vcausadev = 0) THEN
                SELECT vchrdescripcion 
                  INTO vdescausadev
                  FROM tblcausadev
                 WHERE intcvecausadev = vcausadev;
                
                IF TRIM(vdescausadev) != "" THEN
                    LET vvchrMotivodev = TRIM(vdescausadev);
                END IF;
            END IF;
            
            LET vdtmHoraCargo = SUBSTR(vdtmHoraCargo,12,8);
            LET vdtmHoraCancela = SUBSTR(vdtmHoraCancela,12,8);

            SELECT NVL(monto_tot,0) 
              INTO vMontoComis
              FROM tbldetranpago
             WHERE clave_rastreo = vvchrClaverastreo
               AND transacc = vtrancomis;

            SELECT NVL(monto_tot,0) 
              INTO vMontoIva
              FROM tbldetranpago
             WHERE clave_rastreo = vvchrClaverastreo
               AND transacc = vtraniva;

            LET vintcontador = vintcontador + 1;
            
            IF vintcontador <= pintContador THEN
                CONTINUE FOREACH;
            ELSE
                RETURN vchrcodret, cVarDataErr, vvchrNombreOrd, SUBSTR(vvchrCuentaOrd,7,11), vvchrcteOrd,
                       vvchrNombreBenef, vvchrCuentaBenef, vvchrRFCBenef, vvchrConceptoPago2,
                       vintRefNumerica, vcveCesifbcodest, vvchrNombrecorto, vvchrEstatusenvio,
                       vvchrClaverastreo, vdtmHoraCargo, vdtmHoraCancela, vvchrMotivodev,vMonto,
                       vcfechavalor, vusuario, vMontoComis, vMontoIva WITH RESUME;
            END IF;
        END FOREACH
       */
		
		
    END IF;
    END;    
END PROCEDURE;