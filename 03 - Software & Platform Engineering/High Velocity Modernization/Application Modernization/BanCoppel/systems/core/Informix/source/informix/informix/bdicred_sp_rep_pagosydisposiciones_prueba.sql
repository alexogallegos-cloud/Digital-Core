CREATE PROCEDURE "informix".sp_rep_pagosydisposiciones_prueba()

RETURNING char(6),char(80);

    DEFINE cCodRet              char(6);
    DEFINE cMensaje             char(80);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE cNombreArchivo       char(50);
    DEFINE cMesAnio             char(4);

    DEFINE cEmpresa             char(3);
    
    DEFINE cSql                 char(1024);

--Structura
    DEFINE cNumCte              char(20);
    DEFINE cSucursalTar         char(4);
    DEFINE cNumCredito          char(20);
    DEFINE cNumTarjeta          char(20);
    DEFINE dFechaLimitePago     date;
    DEFINE cTIpoMovto           char(1);
    DEFINE dFechaMovto          date;
    DEFINE dHoraMovto           datetime hour to fraction(3);
    DEFINE fImporteDisp         decimal(18,2);
    DEFINE fImportePago         decimal(18,2);
    DEFINE fSdoActual           decimal(18,2);
    DEFINE cSucursalMovto       char(4);
    DEFINE iTipoDisposicion     smallint;
    DEFINE fComisionCons        decimal(18,2);
    DEFINE fComisionDisp        decimal(18,2);
    DEFINE fComisionRet         decimal(18,2);
    DEFINE fIvaComision         decimal(18,2);
    DEFINE fIvaConsulta         decimal(18,2);
    DEFINE fIvaRetiro           decimal(18,2);
    DEFINE cFolioSuc            char(16);
    DEFINE cCodFun              char(3);
    DEFINE iCodRef              smallint;
    DEFINE lSecuencia           integer;
    DEFINE cFolioAux            char(16);
    DEFINE fImporteAux          decimal(18,2);
    DEFINE cNumCreditoAux       char(20);
    DEFINE fComisionAux         decimal(18,2);
    DEFINE fIvaAux              decimal(18,2);
    DEFINE cSucursalMovtoAux    char(4);
    DEFINE dHoraMovtoAux        datetime hour to fraction(3);
    DEFINE cNumTarjetaAux       char(20);
    DEFINE iCodRefUso           smallint;
    DEFINE icontador            INTEGER;
    DEFINE dCapitalVigente      decimal(18,2); 
    DEFINE dCapitalVencido      decimal(18,2); 
    DEFINE dInteresVigente      decimal(18,2); 
    DEFINE dInteresOrdenAbono   decimal(18,2); 
    DEFINE dIvaOrdenAbono       decimal(18,2); 
    DEFINE dInteresMora         decimal(18,2); 
    DEFINE dIvaMora             decimal(18,2);

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
      RETURN cCodRet,cMensaje;
   END EXCEPTION;

    LET cCodRet          = "000000";
    LET cMensaje         = "PROCESO EXITOSO";
    LET cNumCte          = "";
    LET cSucursalTar     ="";
    LET cNumCredito      = "";
    LET cNumTarjeta      = "";
    LET dFechaLimitePago = DATE(1);
    LET cTIpoMovto       = "";
    LET dFechaMovto      = CURRENT::DATE ;
    LET dHoraMovto       = "00:00:00";
    LET fImporteDisp     = 0.00;
    LET fImportePago     = 0.00;
    LET fSdoActual       = 0.00;
    LET cSucursalMovto   = "";
    LET iTipoDisposicion = 0;
    LET fComisionCons    = 0.00;
    LET fComisionDisp    = 0.00;
    LET fComisionRet     = 0.00;
    LET fIvaComision     = 0.00;
    LET fIvaConsulta     = 0.00;
    LET fIvaRetiro       = 0.00;
    LET cFolioSuc        = "";
    LET cCodFun          = "";
    LET iCodRef          = 0;
    LET lSecuencia       = 0;
    LET cFolioAux        = "";
    LET fImporteAux      = 0.00;
    LET cNumCreditoAux   = "";
    LET fComisionAux     = 0.00;
    LET fIvaAux          = 0.00;
    LET cSucursalMovtoAux = "";
    LET dHoraMovtoAux    = "00:00:00";
    LET cNumTarjetaAux   = '';
    LET cSql             = "";
    LET iCodRefUso       = 0.00;
    LET icontador        = 1;

    ---SET DEBUG FILE TO "pagosydisposiciones.out";
    ---TRACE ON;

    DROP TABLE sd_pagosydisposiciones;

    create table sd_pagosydisposiciones
    (
    numcte              char(20),
    sucursal_tarjeta    char(4),
    num_credito         char(20),
    num_tarjeta         char(20),
    fecha_limite_pago   date,
    tipo_movto          char(1),
    fecha_movto         date,
    Hora_movto          datetime hour to second,
    Importe_pago        decimal(18,2),
    Saldo_actual        decimal(18,2),
    sucursal_movto      char(4),
    Tipo_disp           smallint,
    Importe_disp        decimal(18,2),
    comision_cons       decimal(18,2),
    comision_disp       decimal(18,2),
    comision_ret        decimal(18,2),
    Iva_disp            decimal(18,2),
    Iva_ret             decimal(18,2),
    Iva_cons            decimal(18,2),
    capital_vigente     decimal(18,2),
    capital_vencido     decimal(18,2),
    interes_orden_abono	decimal(18,2),
    interes_mora        decimal(18,2),
    iva_mora            decimal(18,2)
    );
--    alter table sd_pagosydisposiciones type(RAW);

    SELECT fecha_ant INTO dFechaMovto FROM bdicred:sd_fechas;

--   let dFechaMovto=today - 16;
   
   FOREACH ----INSERTA PAGOS EN sd_pagosydisposiciones

        SELECT num_credito,monto,sucursal,EXTEND(hora_mov, hour to second),codigo_fun,folio_suc 
        INTO cNumCredito,fImportePago,cSucursalMovto,dHoraMovto,cCodFun,cFolioSuc
        FROM bdicred:sd_movhis WHERE codigo_fun in ('033','334','335','336','337','904') and codigo_ref = 1 and fecha_mov = dFechaMovto  
        and reversado = 'N'

        LET cTipoMovto='P';

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        IF cCodFun='033' or cCodFun='904'  THEN
             LET iTipoDisposicion='2'; --Ventanilla
        ELIF cCodFun='337' THEN
             LET iTipoDisposicion='6'; --Internett 
        ELIF cCodFun='336' THEN
             LET iTipoDisposicion='5'; --Salvo buen cobro
        ELSE
             LET iTipoDisposicion='4'; --Interbancario
        END IF;

        SELECT sucursal,numcte 
        INTO cSucursalTar,cNumCte
        FROM bdicred:sd_maecred 
        WHERE empresa = '001' AND num_credito = cNumCredito;

        IF cSucursalTar IS NULL OR cNumCte IS NULL THEN
            LET cCodRet = '000001';
            LET cMensaje = 'No se encontró crédito en Maestro de Clientes';
            RETURN cCodRet,cMensaje;
        ELSE
            SELECT sdo_cap_insoluto
            INTO fSdoActual
            FROM bdicred:sd_maesdos
            WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

        IF fSdoActual IS NULL THEN
            LET cCodRet = '000002';
            LET cMensaje = 'No se encontró crédito en Maestro de Saldos';
            RETURN cCodRet,cMensaje;
        ELSE
            SELECT NVL(prox_fecha_pago,DATE(1))  INTO dFechaLimitePago FROM bdicred:sd_maecredanexo
            WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

--                SELECT nvl(num_tarjeta,'') into cNumTarjeta from bdicred:sd_tarjeta where empresa = '001' 
 --               AND num_credito = cNumCredito and tipo_tarjeta = 'T' and status_tar = 'A';

        SELECT nvl(num_tarjeta,'') into cNumTarjeta
        from bdicred:sd_tarjeta a
        where empresa = '001'
        AND num_credito = cNumCredito
        and tipo_tarjeta = 'T'
        and secuencia = (SELECT nvl(max(secuencia),0)
                         from bdicred:sd_tarjeta b
                         where b.empresa = a.empresa
                         and b.num_credito = a.num_credito
                         and tipo_tarjeta = 'T');

		    SELECT 
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '13110101010032' OR
                      TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) = '24029014000032' THEN
		              monto ELSE 0 END),-- capital_vigente,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '13110101030032' OR
		              TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) = '13610101010132' or
		              TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) = '13610101010232'THEN
		              monto ELSE 0 END),-- capital_vencido,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '77106101010132' THEN
		              monto ELSE 0 END),-- interes_ORDEN_abono,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '77106101010232'  THEN
		               monto ELSE 0 END),-- interes_mora,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector)= '24020804010111'  THEN
		               monto ELSE 0 END) --IVA_Omora
		      INTO dCapitalVigente, dCapitalVencido, 
                    dInteresOrdenAbono, 
                    dInteresMora, dIvaMora
		      FROM bdicred:sd_movhis a
		      LEFT OUTER JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
		      LEFT OUTER JOIN bdinteg:si_transacc c ON (b.empresa = c.empresa AND b.transacc = c.numero)
		      LEFT OUTER JOIN bdinteg:si_prodtran d ON (b.empresa = d.empresa AND b.transacc = d.transaccion)
		     WHERE a.empresa = '001'
               AND fecha_mov = dFechaMovto
		       AND num_credito = cNumCredito
		       AND reversado   = 'N'
		       AND se_contabiliza  ='S'
		       AND a.codigo_fun in ('033', '334', '335', '336', '337','338','904','040')
		       AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) <> '13110101010032'
               AND folio_suc=cFolioSuc;

        INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora);

        LET cNumCte = "";
        LET cSucursalTar ="";
        LET dFechaLimitePago = DATE(1);
        LET cTIpoMovto = "";
        LET fImporteDisp = 0.00;
        LET fSdoActual = 0.00;
        LET iTipoDisposicion = 0;
        LET fComisionCons = 0.00;
        LET fComisionDisp = 0.00;
        LET fComisionRet = 0.00;
        LET fIvaComision = 0.00;
        LET fIvaConsulta = 0.00;
        LET fIvaRetiro = 0.00;
        LET cFolioAux = "";
        LET fComisionAux = 0.00;
        LET fIvaAux = 0.00;

        LET dCapitalVigente = 0.00;
        LET dCapitalVencido = 0.00;
        LET dInteresVigente = 0.00;
        LET dInteresOrdenAbono = 0.00;
        LET dIvaOrdenAbono = 0.00;
        LET dInteresMora = 0.00;
        LET dIvaMora = 0.00;
        LET cFolioSuc = '';

    IF icontador>=7000 then
        COMMIT WORK; 
        update statistics medium for table bdicred:sd_pagosydisposiciones;
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

    END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

 LET fImportePago = 0.00;
 LET icontador=1;
----------------------------------------------------------------------FIN FOREACH -----------------------------------------------------------------------
 LET  cTipoMovto='D';

---CODIGO_REF 50 MONTO DISPOSICION VENTANILLA
---CODIGO_REF 37 MONTO COMPRA COMERCIO
---CODIGO_REF 30 MONTO RETIRO CAJERO PROPIO
---CODIGO_REF 40 MONTO RETIRO CAJERO RED
---CODIGO_REF 41 MONTO RETIRO CAJERO CONVENIO
---CODIGO_REF 42 MONTO RETIRO CAJERO INTERNACIONAL

   FOREACH  ----INSERTA DISPOSICIONES EN sd_pagosydisposiciones
        
        SELECT num_credito,monto,sucursal,EXTEND(hora_mov, hour to second),codigo_ref, folio_suc,nro_tarjeta 
        INTO cNumCredito,fImporteDisp,cSucursalMovto,dHoraMovto,iCodRef,cFolioSuc,cNumTarjeta
        FROM bdicred:sd_movhis where codigo_fun ='002' and codigo_ref IN (50,37,30,40,41,42)
        AND fecha_mov = dFechaMovto  and reversado = 'N'

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        IF iCodRef=50 THEN

          LET  iTipoDisposicion='2';
                 
                select {+INDEX(sd_movhis inx_movhis)} monto into  fComisionDisp
                from bdicred:sd_movhis  
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '339' and codigo_ref = 50 
                and fecha_mov = dFechaMovto and reversado = 'N' and num_credito = cNumCredito;   -- Disposicion ventanilla - Comision

                if fComisionDisp is null then let fComisionDisp = 0; end if;

                select {+INDEX(sd_movhis inx_movhis)} nvl(monto,0)  into fIvaComision
                from bdicred:sd_movhis
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref = 1 
                and  fecha_mov = dFechaMovto and reversado = 'N' and num_credito = cNumCredito;  -- Disposicion ventanilla - Iva de Comision
                
                if fIvaComision is null then let fIvaComision = 0; end if;

        ELIF iCodRef=37 THEN

           LET  iTipoDisposicion='3';

       ELSE
                IF iCodRef=30 THEN
                    LET iCodRefUso=1; --USO CAJERO PROPIO
                ELIF  iCodRef=40 THEN
                    LET iCodRefUso=17; --USO CAJERO RED
                ELIF  iCodRef=41 THEN
                    LET iCodRefUso=18; --USO CAJERO CONVENIO
                ELIF  iCodRef=42 THEN
                    LET iCodRefUso=19; --USO CAJERO INTERNACIONAL
                END IF;

                select {+INDEX(sd_movhis inx_movhis)} monto into fComisionDisp
                from bdicred:sd_movhis 
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '339' and codigo_ref = 50
                and fecha_mov = dFechaMovto and reversado = 'N'and num_credito = cNumCredito;   -- Disposicion cajero - Comision
                
                if fComisionDisp is null then let fComisionDisp = 0; end if;

                select {+INDEX(sd_movhis inx_movhis)} monto  into fIvaComision
                from bdicred:sd_movhis
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref = 1 
                and fecha_mov = dFechaMovto  and reversado = 'N'and num_credito = cNumCredito;  -- Disposicion cajero - Iva de Comision

                if fIvaComision is null then let fIvaComision = 0; end if;

                select seccomision  into cFolioAux
                from intercard:movimiento
                where secuencia = substr(cFolioSuc,9) and numtarjeta=cNumTarjeta;

                if cFolioAux is null then let cFolioAux = 0; end if;

                select {+INDEX(sd_movhis inx_movhis)} monto  into fComisionRet
                from bdicred:sd_movhis
                where empresa = '001' and substr(folio_suc,9) = cFolioAux 
                and codigo_fun = '339' and codigo_ref = iCodRefUso and fecha_mov = dFechaMovto and reversado = 'N'
                and num_credito = cNumCredito;   -- Disposicion cajero - Comision
                
                if fComisionRet is null then let fComisionRet = 0; end if;

                select {+INDEX(sd_movhis inx_movhis)} nvl(monto,0)  into fIvaRetiro
                from bdicred:sd_movhis
                where empresa = '001' and substr(folio_suc,9) = cFolioAux
                and codigo_fun = '340' and codigo_ref = 2 and fecha_mov = dFechaMovto and reversado = 'N' 
                and num_credito = cNumCredito;  -- Disposicion cajero - Iva de Comision
                
                if fIvaRetiro is null then let fIvaRetiro = 0; end if;

 --               LET fComisionRet = fComisionRet + fComisionAux;
 --               LET fIvaRetiro = fIvaRetiro + fIvaAux;
                LET  iTipoDisposicion='1';

        END IF;

        SELECT sucursal,numcte 
          INTO cSucursalTar,cNumCte
          FROM bdicred:sd_maecred 
         WHERE empresa = '001' AND num_credito = cNumCredito;

        IF cSucursalTar IS NULL OR cNumCte IS NULL THEN
           LET cCodRet = '000001';
           LET cMensaje = 'No se encontró crédito en Maestro de Clientes';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT sdo_cap_insoluto
           INTO fSdoActual
           FROM bdicred:sd_maesdos
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

        IF fSdoActual IS NULL THEN
           LET cCodRet = '000002';
           LET cMensaje = 'No se encontró crédito en Maestro de Saldos';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT NVL(prox_fecha_pago,date(1))  INTO dFechaLimitePago FROM bdicred:sd_maecredanexo
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;


        INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora);

        LET cNumCte = "";
        LET cSucursalTar ="";
        LET dFechaLimitePago = DATE(1);
        LET dHoraMovto = "00:00:00";
        LET fImportePago = 0.00;
        LET fSdoActual = 0.00;
        LET iTipoDisposicion = 0;
        LET fComisionCons = 0.00;
        LET fComisionDisp = 0.00;
        LET fComisionRet = 0.00;
        LET fIvaComision = 0.00;
        LET fIvaConsulta = 0.00;
        LET fIvaRetiro = 0.00;
        LET cFolioAux = "";
        LET fComisionAux = 0.00;
        LET fIvaAux = 0.00;

        LET dCapitalVigente = 0.00;
        LET dCapitalVencido = 0.00;
        LET dInteresVigente = 0.00;
        LET dInteresOrdenAbono = 0.00;
        LET dIvaOrdenAbono = 0.00;
        LET dInteresMora = 0.00;
        LET dIvaMora = 0.00;

    IF icontador>=7000 then
        COMMIT WORK; 
        update statistics medium for table bdicred:sd_pagosydisposiciones;
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;
    
   END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

 LET fImporteDisp = 0.00;
 LET iCodRefUso = 0.00;
 LET iCodRef = 0.00;
 LET icontador=1;
----------------------------------------------------------------------FIN FOREACH -----------------------------------------------------------------------
--  SET DEBUG FILE TO "pagosydisposiciones.out";
--  TRACE ON;

---CODIGO_REF 3 COMISION CONSULTA CAJERO PROPIO
---CODIGO_REF 24 COMISION CONSULTA CAJERO RED
---CODIGO_REF 25 COMISION CONSULTA CAJERO CONVENIO
---CODIGO_REF 26 COMISION CONSULTA CAJERO INTERNACIONAL
    
   LET cTipoMovto='C';
   LET iTipoDisposicion='1';

   FOREACH----INSERTA CONSULTAS EN sd_pagosydisposiciones

        SELECT num_credito,nvl(monto,0),sucursal,EXTEND(hora_mov, hour to second), folio_suc,nro_tarjeta,codigo_ref
        INTO cNumCredito,fComisionAux,cSucursalMovto,dHoraMovto,cFolioSuc,cNumTarjeta,iCodRef
        FROM bdicred:sd_movhis WHERE codigo_fun ='339' and codigo_ref IN (3,24,25,26) and fecha_mov = dFechaMovto 
        and reversado = 'N' ---Trae comision de la consulta
        
        IF icontador=1 then
          BEGIN WORK;
        END IF;

        select {+INDEX(sd_movhis inx_movhis)} monto  into fIvaAux
        from bdicred:sd_movhis
        where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref = 1 
        and fecha_mov = dFechaMovto  and reversado = 'N'and num_credito = cNumCredito;  -- Disposicion cajero - Iva de Comision

        if fIvaAux is null then let fIvaAux = 0; end if;
        
                IF iCodRef=3 THEN
                    LET iCodRefUso=1; --USO CAJERO PROPIO
                ELIF  iCodRef=24 THEN
                    LET iCodRefUso=17; --USO CAJERO RED
                ELIF  iCodRef=25 THEN
                    LET iCodRefUso=18; --USO CAJERO CONVENIO
                ELIF  iCodRef=26 THEN
                    LET iCodRefUso=19; --USO CAJERO INTERNACIONAL
                END IF;

        select seccomision  into cFolioAux
        from intercard:movimiento
        where secuencia = substr(cFolioSuc,9) and numtarjeta=cNumTarjeta;

        if cFolioAux is not null then
            select {+INDEX(sd_movhis inx_movhis)} monto  into fComisionCons
            from bdicred:sd_movhis
            where empresa = '001' and substr(folio_suc,9) = cFolioAux 
            and codigo_fun = '339' and codigo_ref = iCodRefUso and fecha_mov = dFechaMovto and reversado = 'N' 
            and num_credito = cNumCredito;   -- Disposicion cajero - Comision

            if fComisionCons is null then let fComisionCons = 0; end if;

            select {+INDEX(sd_movhis inx_movhis)} nvl(monto,0)  into fIvaConsulta
            from bdicred:sd_movhis
            where empresa = '001' and substr(folio_suc,9) = cFolioAux
            and codigo_fun = '340' and codigo_ref = 2 and fecha_mov = dFechaMovto and reversado = 'N' 
            and num_credito = cNumCredito;  -- Disposicion cajero - Iva de Comision
             
            if fIvaConsulta is null then let fIvaConsulta = 0; end if;

        end if;


        LET fComisionCons = fComisionCons + fComisionAux;
        LET fIvaConsulta = fIvaConsulta + fIvaAux;

        SELECT sucursal,numcte 
        INTO cSucursalTar,cNumCte
        FROM bdicred:sd_maecred 
        WHERE empresa = '001' AND num_credito = cNumCredito;

        IF cSucursalTar IS NULL OR cNumCte IS NULL THEN
           LET cCodRet = '000001';
           LET cMensaje = 'No se encontró crédito en Maestro de Clientes';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT sdo_cap_insoluto
           INTO fSdoActual
           FROM bdicred:sd_maesdos
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

        IF fSdoActual IS NULL THEN
           LET cCodRet = '000002';
           LET cMensaje = 'No se encontró crédito en Maestro de Saldos';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT NVL(prox_fecha_pago,date(1))  INTO dFechaLimitePago FROM bdicred:sd_maecredanexo
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;


        INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora);

        LET cNumCte = "";
        LET cSucursalTar ="";
        LET dFechaLimitePago = DATE(1);
        LET fImporteDisp = 0.00;
        LET fImportePago = 0.00;
        LET fSdoActual = 0.00;
        LET fComisionCons = 0.00;
        LET fComisionDisp = 0.00;
        LET fComisionRet = 0.00;
        LET fIvaComision = 0.00;
        LET fIvaConsulta = 0.00;
        LET fIvaRetiro = 0.00;
        LET cFolioAux = "";
        LET fComisionAux = 0.00;
        LET fIvaAux = 0.00;

        LET dCapitalVigente = 0.00;
        LET dCapitalVencido = 0.00;
        LET dInteresVigente = 0.00;
        LET dInteresOrdenAbono = 0.00;
        LET dIvaOrdenAbono = 0.00;
        LET dInteresMora = 0.00;
        LET dIvaMora = 0.00;

    IF icontador>=7000 then
        COMMIT WORK; 
        update statistics medium for table bdicred:sd_pagosydisposiciones;
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

    END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

        let cSql = '';
        let cSql = 'echo "UNLOAD TO ' || '''Pagos1.unl''' || ' DELIMITER ' || '''|'''|| 
                   ' select * from sd_pagosydisposiciones;'|| 
                   ' " > Pagosydisposiciones2.sql';
        SYSTEM cSql;


              LET cSql = '';
              LET cSql = 'dbaccess bdicred Pagosydisposiciones2.sql';
              SYSTEM cSql;

        let cSql = '';
        LET cNombreArchivo ='PagosyDisposiciones' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
        LET cSql = "sed 's/|$//g' Pagos1.unl > " || cNombreArchivo;
        SYSTEM cSql;

--        let cSql = '';
--        LET cNombreArchivo ='PagosyDisposiciones' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
--        LET cSql = "gzip " || cNombreArchivo;
--        SYSTEM cSql;

        let cSql = '';
        LET cSql = "rm Pagos1.unl Pagosydisposiciones2.sql ";
        SYSTEM cSql;

--        LET cSql = '';
--        LET cSql = "scp " || trim(cNombreArchivo) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
--        SYSTEM cSql;



        LET cSql = '';
        LET cSql = "cp " || trim(cNombreArchivo) || " /resplogifx/archivoscartera";
        SYSTEM cSql;


        let cSql = '';
        LET cNombreArchivo ='PagosyDisposiciones' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
        LET cSql = "rm " || trim(cNombreArchivo) ;
        SYSTEM cSql;

        let cSql = '';
        let cSql = 'echo "UNLOAD TO ' || '''Pagos1cifras.unl''' || ' DELIMITER ' || '''|'''|| 
                   ' SELECT count(*)::INTEGER, sum(Importe_pago), sum(Importe_disp)' ||
                   ' from sd_pagosydisposiciones;'|| 
                   ' " > PagosydisposicionesCifras2.sql';
        SYSTEM cSql;


              LET cSql = '';
              LET cSql = 'dbaccess bdicred PagosydisposicionesCifras2.sql';
              SYSTEM cSql;

        let cSql = '';
        LET cNombreArchivo ='PagosyDisposicionesCifras' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
        LET cSql = "sed 's/|$//g' Pagos1cifras.unl > " || cNombreArchivo;
        SYSTEM cSql;

        let cSql = '';
        LET cSql = "rm Pagos1cifras.unl PagosydisposicionesCifras2.sql ";
        SYSTEM cSql;


--        LET cSql = '';
--        LET cSql = "scp " || trim(cNombreArchivo) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
--        SYSTEM cSql;



        LET cSql = '';
        LET cSql = "cp " || trim(cNombreArchivo) || " /resplogifx/archivoscartera";
        SYSTEM cSql;

 RETURN cCodRet,cMensaje;

  END;

END PROCEDURE;