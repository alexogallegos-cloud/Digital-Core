CREATE PROCEDURE "informix".sp_rep_pagosydisposiciones_menu(pFecha date)

RETURNING char(6),char(80);

    DEFINE cCodRet              char(6);
    DEFINE cMensaje             char(80);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE cNombreArchivo       char(500);
    DEFINE cMesAnio             char(4);
    DEFINE cEmpresa             char(3);
    DEFINE cSql                 char(2054);

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
	DEFINE dnum_producto		char(4);
    DEFINE cNum_Proceso         char(4);   
    DEFINE cCod_retBit          CHAR(6);

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
	LET dnum_producto 	 = ''; 	LET dCapitalVigente = 0;let dCapitalVencido = 0; let dInteresOrdenAbono = 0;let dInteresMora = 0;let  dIvaMora = 0;
    LET cNum_Proceso     = '0047';
	LET cEmpresa         = '001'; 
	LET cCod_retBit      = '000000';  
  --SET DEBUG FILE TO "pagosydisposiciones.out";
  --TRACE ON;

  BEGIN

    ON EXCEPTION SET sql_err,isam_err,cMensaje
      LET cCodRet = sql_err;
	  
	  CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cNum_Proceso, cCodRet, cMensaje, '02') RETURNING cCod_retBit;
	  
      RETURN cCodRet,cMensaje;
    END EXCEPTION;

    LET cMensaje = pFecha;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob_2(cEmpresa, cNum_Proceso, cCodRet, cMensaje, '01') RETURNING cCod_retBit;

    --DROP TABLE sd_pagosydisposiciones;
	IF EXISTS (SELECT tabname FROM "informix".systables WHERE tabname = 'sd_pagosydisposiciones' AND tabid > 1 AND tabtype="T") THEN
	      TRUNCATE TABLE sd_pagosydisposiciones;
          --DROP  TABLE tmeacuerdos;
    ELSE
        create table sd_pagosydisposiciones(
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
		iva_mora            decimal(18,2),
		num_producto		char(4)
		) extent size 27900 next size 16740 LOCK MODE ROW;
 
    END IF;

    
    --SELECT fecha_ant INTO dFechaMovto 
	--FROM bdicred:sd_fechas WHERE empresa ='001';

     -- let dFechaMovto= '09-20-2011';-----SOLO PARA PRUEBAS
	
    IF pFecha IS NULL OR pFecha = '' THEN
		LET cCodRet = '000003';
		LET cMensaje = 'Fecha invalida.';
		RETURN cCodRet,cMensaje;
	END IF;
	
	LET dFechaMovto = pFecha; 
   
   FOREACH with hold----INSERTA PAGOS EN sd_pagosydisposiciones

        SELECT num_credito,monto,sucursal,EXTEND(hora_mov, hour to second),codigo_fun,folio_suc 
        INTO cNumCredito,fImportePago,cSucursalMovto,dHoraMovto,cCodFun,cFolioSuc
        FROM bdicred:sd_movhis WHERE codigo_fun in ('033','334','335','336','337','904') and codigo_ref = 1 and fecha_mov = dFechaMovto  
        and reversado = 'N'
		/*
		 concepto                       transacc     cod_fun    
 -----------------------------  -----------  ---------- 
 Pago en Ventanilla             1234         033        
 Pago Interbancario             1234         334        
 Pago Ajustes Operaciones       1234         335        
 Pago SBC                       6246         336        
 IdentificaciÃÂ³n canal internet  7100         337        
 DevoluciÃÂ³n INTERCARD           6813         904    
 */

        LET cTipoMovto='P';

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        IF cCodFun='033' or cCodFun='904'  THEN
             LET iTipoDisposicion='2'; --Ventanilla
        ELIF cCodFun='337' THEN
             LET iTipoDisposicion='6'; --Internet
        ELIF cCodFun='336' THEN
             LET iTipoDisposicion='5'; --Salvo buen cobro
        ELSE
             LET iTipoDisposicion='4'; --Interbancario
        END IF;

        SELECT sucursal,numcte , num_producto
        INTO cSucursalTar,cNumCte,dnum_producto
        FROM bdicred:sd_maecred 
        WHERE empresa = '001' AND num_credito = cNumCredito;

        IF cSucursalTar IS NULL OR cNumCte IS NULL THEN
            LET cCodRet = '000001';
            LET cMensaje = 'No se encontro credito en Maestro de Clientes';
            RETURN cCodRet,cMensaje;
        ELSE
            SELECT sdo_cap_insoluto
            INTO fSdoActual
            FROM bdicred:sd_maesdos
            WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

        IF fSdoActual IS NULL THEN
            LET cCodRet = '000002';
            LET cMensaje = 'No se encontro credito en Maestro de Saldos';
            RETURN cCodRet,cMensaje;
        ELSE
            SELECT NVL(prox_fecha_pago,DATE(1))  INTO dFechaLimitePago FROM bdicred:sd_maecredanexo
            WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;



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
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110101010032', '13110103010032',
																																	      '13120101010132','13120101030132') OR ---capital vigente ok
                      TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('24029014000032', '24029018000032') THEN --saldo a favor ok
		              monto ELSE 0 END),-- capital_vigente,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110101030032', '13110103030032',
																																	     '13120101010332','13120101030332') OR---ok recuperacion capital vencido transitorio
		              TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13610101010132', '13610103010132',
																														      '13120201010332','13120201030332',
																															  '13120301010332','13120301030332') or ---ok recuperacion capital vencido exigible
		              TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13610101010232', '13610103010232',
																															  '13120201010132','13120201030132',
																															  '13120301010132','13120301030132') THEN  ---??? traspaso de capital vencido no exig a vig.
		              monto ELSE 0 END),-- capital_vencido,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('77106101010132','77106101030132') THEN ---recuperacion interes vencido traspasado
		              monto ELSE 0 END),-- interes_ORDEN_abono,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('77106101010232','77106101030232')  THEN --recuperacion de interes moratorio
		               monto ELSE 0 END),-- interes_mora,
		           SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('24020804010111','24020804010411')  THEN ---recuperacion de iva de interes moratorio
		               monto ELSE 0 END) --IVA_Omora
		      INTO dCapitalVigente, dCapitalVencido, 
                    dInteresOrdenAbono, 
                    dInteresMora, dIvaMora
		      FROM bdicred:sd_movhis a
		      LEFT OUTER JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
		      LEFT OUTER JOIN bdinteg:si_transacc c ON (b.empresa = c.empresa AND b.transacc = c.numero and c.sistema ='06')
		      LEFT OUTER JOIN bdinteg:si_prodtran d ON (b.empresa = d.empresa AND b.transacc = d.transaccion AND d.producto = a.num_producto) 
		     WHERE a.empresa = '001'
               AND fecha_mov = dFechaMovto
		       AND num_credito = cNumCredito
		       AND reversado   = 'N'
		       AND se_contabiliza  ='S'
		       AND a.codigo_fun in ('033','334','335','336','337','904')
		       AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) NOT IN ('13110101010032','13110103010032',
																															   '13120101010332','13120101030332',
																															   '13120101010132','13120101030132',
																															   '13120201010332','13120201030332',
																															   '13120301010332','13120301030332',
																															   '13120201010132','13120201030132',
																															   '13120301010132','13120301030132')
               AND folio_suc=cFolioSuc;

        INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);

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
-- 57 COMPRA EN COMER. INTER_RED (LIB)
---CODIGO_REF 50 MONTO DISPOSICION VENTANILLA
---CODIGO_REF 37 MONTO COMPRA COMERCIO
---CODIGO_REF 30 MONTO RETIRO CAJERO PROPIO
---CODIGO_REF 40 MONTO RETIRO CAJERO RED
---CODIGO_REF 41 MONTO RETIRO CAJERO CONVENIO
---CODIGO_REF 42 MONTO RETIRO CAJERO INTERNACIONAL

   FOREACH with hold----INSERTA DISPOSICIONES EN sd_pagosydisposiciones
        
        SELECT num_credito,monto,sucursal,EXTEND(hora_mov, hour to second),codigo_ref, folio_suc,nro_tarjeta 
        INTO cNumCredito,fImporteDisp,cSucursalMovto,dHoraMovto,iCodRef,cFolioSuc,cNumTarjeta
        FROM bdicred:sd_movhis where codigo_fun ='002' and codigo_ref IN (57,50,37,30,40,41,42)
        AND fecha_mov = dFechaMovto  and reversado = 'N'

        IF icontador=1 then
          BEGIN WORK;
        END IF;

        IF iCodRef=50 THEN

          LET  iTipoDisposicion='2';
                 
                --select {+INDEX(sd_movhis inx_movhis)} monto into  fComisionDisp 
				select monto into  fComisionDisp   --MACF
                from bdicred:sd_movhis  
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '339' and codigo_ref = 50
                and fecha_mov = dFechaMovto and reversado = 'N' and num_credito = cNumCredito;   -- Disposicion ventanilla - Comision

                if fComisionDisp is null then let fComisionDisp = 0; end if;

                --select {+INDEX(sd_movhis inx_movhis)} monto into fIvaComision
				select monto into fIvaComision --MACF
                from bdicred:sd_movhis
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref in (1,2) 
                and  fecha_mov = dFechaMovto and reversado = 'N' and num_credito = cNumCredito;  -- Disposicion ventanilla - Iva de Comision
                
                if fIvaComision is null then let fIvaComision = 0; end if;

        ELIF iCodRef in (37,57,937,938) THEN

           LET  iTipoDisposicion='3';

        ELSE
/*
                IF iCodRef=30 THEN
                    LET iCodRefUso=1; --USO CAJERO PROPIO
                ELIF  iCodRef=40 THEN
                    LET iCodRefUso=17; --USO CAJERO RED
                ELIF  iCodRef=41 THEN
                    LET iCodRefUso=18; --USO CAJERO CONVENIO
                ELIF  iCodRef=42 THEN
                    LET iCodRefUso=19; --USO CAJERO INTERNACIONAL
                END IF;
*/
                --select {+INDEX(sd_movhis inx_movhis)} monto into fComisionDisp
				select monto into fComisionDisp  --MACF
                from bdicred:sd_movhis 
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '339' and codigo_ref = 50
                and fecha_mov = dFechaMovto and reversado = 'N'and num_credito = cNumCredito;   -- Disposicion cajero - Comision
                
                if fComisionDisp is null then let fComisionDisp = 0; end if;

                --select {+INDEX(sd_movhis inx_movhis)} monto into fIvaComision
				select monto into fIvaComision --MACF
                from bdicred:sd_movhis
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref = 1 
                and fecha_mov = dFechaMovto  and reversado = 'N'and num_credito = cNumCredito;  -- Disposicion cajero - Iva de Comision

                if fIvaComision is null then let fIvaComision = 0; end if;

--

                let cFolioSuc = substr(cFolioSuc,1,9)||"2"||substr(cFolioSuc,11);

                --select {+INDEX(sd_movhis inx_movhis)} monto into fComisionRet
				select monto into fComisionRet  --MACF
                from bdicred:sd_movhis 
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '339' and codigo_ref in (17,18,19,90,91,92)
                and fecha_mov = dFechaMovto and reversado = 'N'and num_credito = cNumCredito;   -- Disposicion cajero - Comision

                if fComisionRet is null then let fComisionRet = 0; end if;

                --select {+INDEX(sd_movhis inx_movhis)} monto into fIvaRetiro
				select monto into fIvaRetiro  --MACF
                from bdicred:sd_movhis 
                where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref in (1,2)
                and fecha_mov = dFechaMovto and reversado = 'N'and num_credito = cNumCredito;   -- Disposicion cajero - Comision

                if fIvaRetiro is null then let fIvaRetiro = 0; end if;


                LET fComisionRet = fComisionRet + fComisionAux;
                LET fIvaRetiro = fIvaRetiro + fIvaAux;
                LET iTipoDisposicion='1';
        END IF;

        SELECT sucursal,numcte , num_producto
        INTO cSucursalTar,cNumCte,dnum_producto
          FROM bdicred:sd_maecred 
         WHERE empresa = '001' AND num_credito = cNumCredito;

        IF cSucursalTar IS NULL OR cNumCte IS NULL THEN
           LET cCodRet = '000001';
           LET cMensaje = 'No se encontro credito en Maestro de Clientes';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT sdo_cap_insoluto
           INTO fSdoActual
           FROM bdicred:sd_maesdos
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

        IF fSdoActual IS NULL THEN
           LET cCodRet = '000002';
           LET cMensaje = 'No se encontro credito en Maestro de Saldos';
          RETURN cCodRet,cMensaje;
        ELSE
           SELECT NVL(prox_fecha_pago,date(1))  INTO dFechaLimitePago FROM bdicred:sd_maecredanexo
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;


        INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);

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
---CODIGO_REF 24, 93 COMISION CONSULTA CAJERO RED
---CODIGO_REF 25, 94 COMISION CONSULTA CAJERO CONVENIO
---CODIGO_REF 26, 95 COMISION CONSULTA CAJERO INTERNACIONAL
    
   LET cTipoMovto='C';
   LET iTipoDisposicion='1';

   FOREACH with hold----INSERTA CONSULTAS EN sd_pagosydisposiciones

        SELECT num_credito,nvl(monto,0),sucursal,EXTEND(hora_mov, hour to second), folio_suc,nro_tarjeta,codigo_ref
        INTO cNumCredito,fComisionAux,cSucursalMovto,dHoraMovto,cFolioSuc,cNumTarjeta,iCodRef
        FROM bdicred:sd_movhis WHERE codigo_fun ='339' and codigo_ref IN (3,24,25,26,93,94,95) and fecha_mov = dFechaMovto 
        and reversado = 'N' ---Trae comision de la consulta
        
        IF icontador=1 then
          BEGIN WORK;
        END IF;

        --select {+INDEX(sd_movhis inx_movhis)} monto into fIvaAux
		select monto into fIvaAux  --MACF
        from bdicred:sd_movhis
        where empresa = '001' and folio_suc = cFolioSuc and codigo_fun = '340' and codigo_ref in (1,2)
        and fecha_mov = dFechaMovto  and reversado = 'N' and num_credito = cNumCredito;  -- Disposicion cajero - Iva de Comision

        if fIvaAux is null then let fIvaAux = 0; end if;


--        LET fComisionCons = fComisionCons + fComisionAux;
--        LET fIvaConsulta = fIvaConsulta + fIvaAux;

        LET fComisionCons = fComisionAux;
        LET fIvaConsulta = fIvaAux;

        SELECT sucursal,numcte , num_producto
        INTO cSucursalTar,cNumCte,dnum_producto
        FROM bdicred:sd_maecred 
        WHERE empresa = '001' AND num_credito = cNumCredito;

        IF cSucursalTar IS NULL OR cNumCte IS NULL THEN
           LET cCodRet = '000001';
           LET cMensaje = 'No se encontro credito en Maestro de Clientes';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT sdo_cap_insoluto
           INTO fSdoActual
           FROM bdicred:sd_maesdos
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;

        IF fSdoActual IS NULL THEN
           LET cCodRet = '000002';
           LET cMensaje = 'No se encontro credito en Maestro de Saldos';
           RETURN cCodRet,cMensaje;
        ELSE
           SELECT NVL(prox_fecha_pago,date(1))  INTO dFechaLimitePago FROM bdicred:sd_maecredanexo
           WHERE empresa = '001' AND num_credito = cNumCredito;
        END IF;


        INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);

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

 LET fImporteDisp = 0.00;
 LET iCodRefUso = 0.00;
 LET iCodRef = 0.00;
 LET icontador=1;
 
	set isolation to dirty read;
    FOREACH with hold -----------------------------------PAGOS REESTRUCTURA------------------------------
	SELECT cr.numcte, cr.sucursal, A.num_credito,nvl(tar.num_cta,'') Tarjeta,
		( SELECT NVL(prox_fecha_pago,DATE(1))  FROM bdicred:sd_maecredanexocrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito)FechaProxPago ,
		'P' Tipo,fecha_mov,EXTEND(A.hora_mov, hour to second) Hora ,A.monto,
		( SELECT sdo_cap_insoluto FROM bdicred:sd_maesdoscrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito)SaldoInsoluto ,A.sucursal SucMov,
		decode (A.codigo_fun, '7970',1,'7998',1, '7432', 2,'7431',2) TipoPago, A.folio_suc,a.num_producto
	INTO cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,
		 dFechaLimitePago,cTipoMovto,dFechaMovto,dHoraMovto,fImportePago,
		 fSdoActual,cSucursalMovto,
		 iTipoDisposicion , cFolioSuc,dnum_producto
    FROM   bdicred:sd_maecredcrd cr, bdicred:sd_ctascarg tar,bdicred:sd_movhiscrd a 		
	WHERE a.empresa = '001'
		AND cr.empresa = a.empresa
		and cr.num_credito = a.num_credito
		and tar.empresa=cr.empresa  
		and tar.num_credito = cr.num_credito  
		and tar.naturaleza = 'A'		
		and A.codigo_fun in ('222','225') 
		and A.codigo_ref = 1 
		--and fecha_mov >= mdy('01','01','2012') and   fecha_mov <= mdy('01','31','2012')
		and fecha_mov = dFechaMovto
        and A.reversado = 'N'
	
	IF icontador=1 then
          BEGIN WORK;
    END IF;
		
	set isolation to dirty read;
	SELECT  --a.num_credito, a.folio_suc,
		SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110102010032','13120101020132','13120201020132','13120301020132') 
        THEN MONTO ELSE 0 END) capital_vigente, ---capital vigente ok                  
		SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110102030032','13120101020332') OR---ok recuperacion capital vencido transitorio
		    TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13610102010132','13610102010232' ,  --Exig 2,3
			                                                                                                        '13120201020332','13120301020332') or ---ok recuperacion capital vencido exigible
		    TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13610102010232') THEN  ---??? traspaso de capital vencido no exig a vig.
		    monto ELSE 0 END)capital_vencido,
		SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('77106101020132','78376101020132','13110102020032','14020305110432') THEN ---recuperacion interes vencido traspasado
		    monto ELSE 0 END) interes_ORDEN_abono,
--SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('')  THEN --recuperacion de interes moratorio
		               --monto ELSE 0 END) 
                       0 interes_mora,
--SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('','')  THEN ---recuperacion de iva de interes moratorio
		              -- monto ELSE 0 END) 
                      0 IVA_mora	
	INTO dCapitalVigente,dCapitalVencido,dInteresOrdenAbono,dInteresMora, dIvaMora
	FROM bdicred:sd_movhiscrd a
		LEFT OUTER JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
		LEFT OUTER JOIN bdinteg:si_transacc c ON (b.empresa = c.empresa AND b.transacc = c.numero and c.sistema ='06')
		LEFT OUTER JOIN bdinteg:si_prodtran d ON (b.empresa = d.empresa AND b.transacc = d.transaccion AND d.producto = a.num_producto) 
	WHERE a.empresa = '001'
        --AND fecha_mov >= mdy('01','01','2012') and   fecha_mov <= mdy('01','31','2012')
		and fecha_mov = dFechaMovto
		AND reversado   = 'N'
		AND c.se_contabiliza  ='S'
		AND a.codigo_fun in  ('222','225') 
		AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) NOT IN ('13110102010032','13120101020132','13120201020132','13120301020132',
																														                 '13120101020332','13120201020332','13120301020332')
        and folio_suc = cFolioSuc 
        and a.num_credito = cNumCredito;
	--group by a.num_credito, a.folio_suc
	
		INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);

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

    IF icontador>=5000 then
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
	
	set isolation to dirty read;
	FOREACH with hold ----BUSCA  INFORMACION  REESTRCUTURA APERTURA
	SELECT cr.numcte , cr.sucursal, A.num_credito,nvl(tar.num_cta,'') Tarjeta,
		( SELECT NVL(prox_fecha_pago,DATE(1))  FROM bdicred:sd_maecredanexocrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito) FechaLimitePago,
		'D' TipoMovto,fecha_mov,EXTEND(A.hora_mov, hour to second) HoraMovto ,0 ImportePago, --
		( SELECT sdo_cap_insoluto FROM bdicred:sd_maesdoscrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito) SdoActual,
		A.sucursal SucursalMovto,
		2 TipoDisposicion ,  A.monto ImporteDisp,a.num_producto
		--,0 ComisionCons ,		0 ComisionDisp,		0 ComisionRet ,		0 IvaComision ,		0 IvaRetiro ,		0 IvaConsulta ,0,0,0,0,0
	INTO cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,
		 dFechaLimitePago,cTipoMovto,dFechaMovto,dHoraMovto,fImportePago,
		 fSdoActual,cSucursalMovto,iTipoDisposicion,fImporteDisp,dnum_producto
	FROM  bdicred:sd_maecredcrd cr, bdicred:sd_ctascarg tar,
		bdicred:sd_movhiscrd a 		
	WHERE a.empresa = '001'
		AND cr.empresa = a.empresa
		and cr.num_credito = a.num_credito		
		and tar.empresa=cr.empresa  
		and tar.num_credito = cr.num_credito  
		and tar.naturaleza = 'A'	
		and a.codigo_fun ='002' and a.codigo_ref =1
		--AND a.fecha_mov =  mdy('02','27','2012')
		and a.fecha_mov = dFechaMovto
		and reversado = 'N'
	
	IF icontador=1 then
          BEGIN WORK;
    END IF;
	
	INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);
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
		
		IF icontador>=5000 then
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
	
	--let dFechaMovto = '12-03-2011';---------------------PRUEBAS PRESTAMO PERSONAL---------------------------------------------
	set isolation to dirty read;
	
	FOREACH with hold  ----INFORMACION  PRESTAMO PERSONAL.......... EXTRACCION DE PAGOS 
    SELECT cr.numcte, cr.sucursal, A.num_credito,nvl(tar.num_cta,'') Tarjeta,
		( SELECT NVL(prox_fecha_pago,DATE(1))  FROM bdicred:sd_maecredanexocrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito)FechaProxPago ,
		'P' Tipo,fecha_mov,EXTEND(A.hora_mov, hour to second) Hora ,A.monto,
        ( SELECT sdo_cap_insoluto FROM bdicred:sd_maesdoscrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito)SaldoInsoluto ,A.sucursal SucMov,
        Decode (A.codigo_fun, '7998',1,'7970',1,2) TipoPago, A.folio_suc,a.num_producto
	INTO cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,
		 dFechaLimitePago,cTipoMovto,dFechaMovto,dHoraMovto,fImportePago,
		 fSdoActual,cSucursalMovto,
		 iTipoDisposicion , cFolioSuc,dnum_producto
    FROM   bdicred:sd_maecredcrd cr, bdicred:sd_ctascarg tar,bdicred:sd_movhiscrd a                       
    WHERE a.empresa = '001'
        AND cr.empresa = a.empresa
        and cr.num_credito = a.num_credito
        and tar.empresa=cr.empresa 
        and tar.num_credito = cr.num_credito 
        and tar.naturaleza = 'A'             
        and A.codigo_fun in ('023','021','023','027','028')  --and --status_cred = 'BT'
        and A.codigo_ref = 1 
		--and fecha_mov >= mdy('03','01','2012') and   fecha_mov <= mdy('03','05','2012')
		and fecha_mov = dFechaMovto
        and A.reversado = 'N'  
	
	IF icontador=1 then
          BEGIN WORK;
    END IF;
	
	----------------------DESGLOSE DEL PAGO-----------------------------------------
	set isolation to dirty read;
	SELECT  --a.num_credito, a.folio_suc,
        SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110202010032','13120102020132','13120202020132','13120302020132')
        THEN MONTO ELSE 0 END) capital_vigente, ---capital vigente ok                 
        SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110202030032','13120102020332') OR---ok recuperacion capital vencido transitorio
        TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13610202010132','13120202020332') or ---ok recuperacion capital vencido exigible
        TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13610202010232','13120302020332') THEN  ---??? traspaso de capital vencido no exig a vig.
        monto ELSE 0 END)capital_vencido,
		SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('13110202020032','14020305110232') THEN ---recuperacion interes vencido traspasado
		monto ELSE 0 END) interes_ORDEN_abono,
		SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('77106102020132')  THEN --recuperacion de interes moratorio
        monto ELSE 0 END)interes_mora,
        SUM(CASE WHEN TRIM(a_ccmayor)||TRIM(a_ccsub)||TRIM(a_ccsubsub)||TRIM(a_ccsssub)||TRIM(a_ccssssub)||TRIM(a_sector) IN ('78376102020132')  THEN ---recuperacion de iva de interes moratorio
        monto ELSE 0 END)IVA_Omora  
	INTO dCapitalVigente,dCapitalVencido,dInteresOrdenAbono,dInteresMora, dIvaMora					   
    FROM bdicred:sd_movhiscrd a
        LEFT OUTER JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
        LEFT OUTER JOIN bdinteg:si_transacc c ON (b.empresa = c.empresa AND b.transacc = c.numero and c.sistema ='06')
        LEFT OUTER JOIN bdinteg:si_prodtran d ON (b.empresa = d.empresa AND b.transacc = d.transaccion AND d.producto = a.num_producto)
    WHERE a.empresa = '001'
        --AND fecha_mov >= mdy('01','03','2012') and   fecha_mov <= mdy('05','03','2012')
		and fecha_mov = dFechaMovto
        AND reversado   = 'N'
        AND c.se_contabiliza  ='S'
        AND a.codigo_fun in  ('023','021','023','027','028')
        AND TRIM(c_ccmayor)||TRIM(c_ccsub)||TRIM(c_ccsubsub)||TRIM(c_ccsssub)||TRIM(c_ccssssub)||TRIM(c_sector) NOT IN ('13110202010032','13120102020132','13120202020132','13120302020132',
																														                 '13120102020332','13120202020332','13120302020332')
        and folio_suc = cFolioSuc 
        and a.num_credito = cNumCredito;
	--group by a.num_credito, a.folio_suc;
		
	    
	INSERT INTO sd_pagosydisposiciones 
    VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);
		         
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
		
		IF icontador>=5000 then
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
	
	set isolation to dirty read;
	
	FOREACH with hold ----BUSCA  INFORMACION  PRESTAMO PERSONAL APERTURA
	SELECT cr.numcte , cr.sucursal, A.num_credito,nvl(tar.num_cta,'') Tarjeta,
		(SELECT NVL(prox_fecha_pago,DATE(1))  FROM bdicred:sd_maecredanexocrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito) FechaLimitePago,
		'D' TipoMovto,fecha_mov,EXTEND(A.hora_mov, hour to second) HoraMovto ,0 ImportePago, --
        (SELECT sdo_cap_insoluto FROM bdicred:sd_maesdoscrd  WHERE empresa = cr.empresa AND num_credito = cr.num_credito) SdoActual,
		A.sucursal SucursalMovto,
        2 TipoDisposicion ,  A.monto ImporteDisp,a.num_producto
		--,0 ComisionCons ,		0 ComisionDisp,		0 ComisionRet ,		0 IvaComision ,		0 IvaRetiro ,		0 IvaConsulta ,0,0,0,0,0
	INTO cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,
		 dFechaLimitePago,cTipoMovto,dFechaMovto,dHoraMovto,fImportePago,
		 fSdoActual,cSucursalMovto,iTipoDisposicion,fImporteDisp,dnum_producto
	FROM  bdicred:sd_maecredcrd cr, bdicred:sd_ctascarg tar,
		bdicred:sd_movhiscrd a                  
	WHERE a.empresa = '001'
		AND cr.empresa = a.empresa
		and cr.num_credito = a.num_credito               
		and tar.empresa=cr.empresa 
		and tar.num_credito = cr.num_credito 
		and tar.naturaleza = 'A'           
		and a.codigo_fun ='002' and a.codigo_ref =66
		and fecha_mov = dFechaMovto
		and reversado = 'N'
	
	IF icontador=1 then
          BEGIN WORK;
    END IF;
	
	INSERT INTO sd_pagosydisposiciones 
        VALUES(cNumCte,cSucursalTar,cNumCredito,cNumTarjeta,dFechaLimitePago,cTipoMovto,dFechaMovto, dHoraMovto, fImportePago,fSdoActual,
               cSucursalMovto, iTipoDisposicion,fImporteDisp, fComisionCons,fComisionDisp,fComisionRet,fIvaComision,fIvaRetiro,fIvaConsulta,
               dCapitalVigente, dCapitalVencido, dInteresOrdenAbono, dInteresMora, dIvaMora,dnum_producto);
			   
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
		
		IF icontador>=5000 then
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
----------------------------------CREAR ARCHIVO----------------------------------
        let cSql = '';
        let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1.unl''' || ' DELIMITER ' || '''|'''|| 
                   ' select * from sd_pagosydisposiciones;'|| 
                   ' " > /resplogifx/archivoscartera/Pagosydisposiciones2.sql';
        SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/Pagosydisposiciones2.sql';
              SYSTEM cSql;

        let cSql = '';
        LET cNombreArchivo ='/resplogifx/archivoscartera/PagosyDisposiciones' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
        LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1.unl > " || trim(cNombreArchivo);
        SYSTEM cSql;

--        let cSql = '';
--        LET cNombreArchivo ='PagosyDisposiciones' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
--        LET cSql = "gzip " || cNombreArchivo;
--        SYSTEM cSql;

        let cSql = '';
        LET cSql = "rm /resplogifx/archivoscartera/Pagos1.unl /resplogifx/archivoscartera/Pagosydisposiciones2.sql ";
        SYSTEM cSql;

--        LET cSql = '';
--        LET cSql = "scp " || trim(cNombreArchivo) || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
--        SYSTEM cSql;


----ini cas ya no se hace la copia porque se genera directamente en la ruta
     --   LET cSql = '';
     --   LET cSql = "cp " || trim(cNombreArchivo) || " /resplogifx/archivoscartera";
     --   SYSTEM cSql;
----fin cas ya no se hace la copia porque se genera directamente en la ruta

        let cSql = '';
        LET cNombreArchivo ='/resplogifx/archivoscartera/PagosyDisposiciones' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
       -- LET cSql = "rm " || trim(cNombreArchivo) ;
       -- SYSTEM cSql;

        let cSql = '';
        let cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/Pagos1cifras.unl''' || ' DELIMITER ' || '''|'''|| 
                   ' SELECT count(*)::INTEGER, sum(Importe_pago), sum(Importe_disp)' ||
                   ' from sd_pagosydisposiciones;'|| 
                   ' " > /resplogifx/archivoscartera/PagosydisposicionesCifras2.sql';
        SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/PagosydisposicionesCifras2.sql';
              SYSTEM cSql;

        let cSql = '';
        LET cNombreArchivo ='/resplogifx/archivoscartera/PagosyDisposicionesCifras' || LPAD(TRIM(DAY(dFechaMovto::DATE)::CHAR(2)),2,'0')|| LPAD(TRIM(MONTH(dFechaMovto::DATE)::CHAR(2)),2,'0') ||YEAR(dFechaMovto::DATE) || '.txt';
        LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/Pagos1cifras.unl > " || trim(cNombreArchivo);
        SYSTEM cSql;

        let cSql = '';
        LET cSql = "rm /resplogifx/archivoscartera/Pagos1cifras.unl /resplogifx/archivoscartera/PagosydisposicionesCifras2.sql ";
        SYSTEM cSql;
		
		LET cMensaje = "PROCESO EXITOSO";
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, cNum_Proceso, cCodRet, cMensaje, '03') RETURNING cCod_retBit;


 RETURN cCodRet,cMensaje;

END;
END PROCEDURE;