CREATE PROCEDURE "informix".sp_generagestionadmin( pFInicial date  )
RETURNING CHAR(5);


/*Fecha de Modificación: 16/05/2010
  Faviola Martínez Juárez
  Generación de concentrado de resultados de clientes con seguimiento de cobranza CAT 
*/
 

DEFINE vcCodRet CHAR(5);
DEFINE viSqlErr INTEGER;
DEFINE vdFInicial DATE;
DEFINE vdFFinal   DATE;
DEFINE vdFPeriodo DATE;

DEFINE cMensaje CHAR(80);
DEFINE isam_err INTEGER;
DEFINE error_info CHAR(80);
DEFINE vProceso CHAR(50);

DEFINE vcEsTransaccion CHAR(1);
DEFINE vlCliente        char(20);         
DEFINE vlCredito        char(20); 
DEFINE vlImp_Conveniado Decimal(16,2);
DEFINE vlNumConvenio    Smallint;
DEFINE vlImp_pagado     Decimal(16,2); 
DEFINE vlNumConvCump    Smallint;
DEFINE vlImp_Conv_pag   Decimal (16,2);
DEFINE vlImp_Minimo     Decimal (16,2);
DEFINE vlImp_SdoTotal   Decimal (16,2);
DEFINE vlMonto          Decimal (16,2);
DEFINE vlperiodo        Integer;

DEFINE vdia DATE;
DEFINE vHora CHAR(8); 

LET viSqlErr = 0;
 LET vProceso = 'Obtiene Resultados CV';
LET cMensaje = 'PROCESO EXITOSO';
LET isam_err = 0;
LET error_info = '';
  
LET vdFInicial ='01/01/1900';
LET vdFFinal   ='01/01/1900';
LET vdFPeriodo ='01/01/1900';
LET vlperiodo =1;



LET vcCodRet = '00000';
--LET vcNumCuenta = '';
--LET vmSumaPagos = 0.00;
--LET vmCatidadAcordada = 0.00;
--LET vmSuma = 0.00;
LET vcEsTransaccion = 'N';

--INSERT CB_BITACORA_COB 'PROCESO INICIALIZADO'

    BEGIN    
        ON EXCEPTION SET viSqlErr, isam_err, error_info

            IF vcEsTransaccion = 'S' THEN
                ROLLBACK WORK;
            END IF;
            LET vcCodRet = viSqlErr;
            LET cMensaje = error_info;        
           
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
            SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
           
            
            INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, vcCodRet, cMensaje, user, vdia, vHora, null); 
            
            RETURN vcCodRet;
            
        END EXCEPTION;

      -- SET DEBUG FILE TO "/home/informix/sp_marcarAcuerdo.out";
      -- TRACE ON;
        
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
        VALUES (vProceso,'11111' , 'PROCESO INICIALIZADO', user, vdia, vHora, null); 


    IF vcCodRet = '00000' THEN
        BEGIN WORK;
        LET vcEsTransaccion = 'S';      

        LET vlperiodo = to_char (pFInicial,'%Y%m');
        LET vdFInicial =date(to_char (pFInicial,'%m-21-%Y'));                 
        LET vdFFinal   =date(to_char (today +30,'%m') || '-20-'|| to_char (today,'%Y')); 
        ----to_char (pFInicial,'20/%m/%Y');
        LET vdFPeriodo =date(to_char (pFInicial,'%m-20-%Y'));
          
        FOREACH
          --Convenios
          select  cr.numcte Cliente ,cr.num_credito Credito, sum(cc.importe) Imp_Conveniado, 
                  count(cc.numcliente) Num_Convenio , sum(imp_pagado) Imp_Pagado, sum(flag_pago*1) Num_conv_Cumplido
            into  vlCliente, vlCredito, vlImp_Conveniado, vlNumConvenio, vlImp_Conv_pag, vlNumConvCump       
            from cb_resgestionadmin cr, cb_compac_his cc
           where cc.empresa = '001' 
             and Trim(cr.numcte) = trim(cc.numcliente)
             and Trim(cr.num_credito) = Trim(cc.numcuenta)
             and cc.fecha_compac between vdFInicial and vdFFinal
          group by cr.numcte ,cr.num_credito

                UPDATE BDICOBRANZA:cb_resgestionadmin 
                   set num_convenio = vlNumConvenio, 
                       num_conv_cumplido = vlNumConvCump,
                       imp_convenio = vlImp_Conveniado ,
                       imp_pag_convenio = vlImp_Conv_pag  
                 WHERE periodo = vlperiodo
                   and numcte      = vlCliente 
                   and num_credito = vlCredito ;
        END FOREACH;

        FOREACH
          --Convenios
          select  cr.numcte Cliente ,cr.num_credito Credito,
                  sum (ec.capital_tc + (ec.capital_ven_tc + ec.interes_ven_tc +
                  ec.iva_interes_ven_tc +ec.moratorios_tc + ec.iva_moratorios_tc)) Minimo, 
                  sum(ec.interes_pago_total_tc) Saldo_Total
            into  vlCliente, vlCredito,vlImp_Minimo, vlImp_SdoTotal     
            from cb_resgestionadmin cr, bdicred:sd_encabezado2_edocta ec
           where ec.fecha_emision = vdFPeriodo  
             and cr.num_credito = ec.num_credito  
           group by cr.numcte ,cr.num_credito

                UPDATE BDICOBRANZA:cb_resgestionadmin 
                   set monto_minimo = vlImp_Minimo, 
                       saldo_total = vlImp_SdoTotal                         
                 WHERE periodo = vlperiodo 
                   and numcte      = vlCliente 
                   and num_credito = vlCredito ;
        END FOREACH;
--/*
        FOREACH
          --Convenios
          select cr.numcte ,cr.num_credito , NVL(SUM(monto),0)
            into vlCliente, vlCredito, vlMonto  
            from cb_resgestionadmin cr,  bdicred:sd_movhis sm
           where sm.empresa ='001'
             and cr.num_credito = sm.num_credito
             and sm.codigo_fun in ('033', '334', '335', '336', '337') 
             and sm.codigo_ref = 1
             and sm.fecha_mov between vdFInicial and vdFFinal 
             and sm.reversado = 'N'  
          group by cr.numcte ,cr.num_credito

                UPDATE BDICOBRANZA:cb_resgestionadmin 
                   set imp_pagado_total = vlMonto                         
                 WHERE periodo = vlperiodo
                   and numcte      = vlCliente 
                   and num_credito = vlCredito ;
        END FOREACH;

        -- El sistema elimina los compromisos marcados como cumplidos y los compromisos vencidos de la tabla de movimientos.
        COMMIT WORK;
        LET vcEsTransaccion = 'N';
        
        --INSERT CB_BITACORA_COB 'PROCESO EXITOSO'        
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, vcCodRet, cMensaje, user, vdia, vHora, null); 
--*/
    RETURN vcCodRet;        
  
END IF;

  IF vcCodRet <> '00000' then

        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia FROM sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vHora FROM sysmaster:sysshmvals;
        
        INSERT INTO bdicobranza:cb_bitacora_cob (proceso, cod_ret, mensaje, user_insert, fecha_insert, hora_insert, num_ult_reg_proc)
            VALUES (vProceso, vcCodRet, cMensaje, user, vdia, vHora, null);
         
  END IF;

  RETURN vcCodRet;
END;
END PROCEDURE;