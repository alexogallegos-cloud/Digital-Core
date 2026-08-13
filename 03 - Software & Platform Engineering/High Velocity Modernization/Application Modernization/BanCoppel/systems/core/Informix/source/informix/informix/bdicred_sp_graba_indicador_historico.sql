CREATE PROCEDURE "informix".sp_graba_indicador_historico( pIndicador SMALLINT, 	pProducto CHAR(4) )  
       RETURNING char(5);
   
---pIndicador  0 Corte, 1 Mensual

--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);

--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vPagoCliente	CHAR(1);
DEFINE	vcantReg		SMALLINT;
------------------------------------------------
------------------------------------------------
DEFINE	vtipotrans			char(1);
DEFINE	vlSentido		    char(1);
DEFINE  vlTransaccion		CHAR(4);
DEFINE vMtoReversion		DECIMAL(16,2);
DEFINE	vlfult_respaldo		DATE;

DEFINE vFecha               DATE; 
DEFINE vlCredito            CHAR(20);
DEFINE vlIndicador          SMALLINT;



DEFINE vTransPrimerCompra 	CHAR(4);
DEFINE vfecPrimerDisp		DATE; 
DEFINE vMontoPrimerDisp		DECIMAL(16,2); 
DEFINE vTransPrimerDisp		CHAR(4);
DEFINE vFolioPosDisp		CHAR(16);  
DEFINE vFolioAtmDisp		CHAR(16);  
DEFINE vFolioVntDisp		CHAR(16); 		  			  
DEFINE vFecUltPago			DATE; 
DEFINE vMtoUltPago			DECIMAL(16,2);
DEFINE vTransUltPago		CHAR(4);	
DEFINE vFolioUltPago		CHAR(16); 
DEFINE vAtmDispMto			DECIMAL(16,2);
DEFINE vAtmDispFec			DATE;
DEFINE vAtmDispTransacc		CHAR(4);
DEFINE vPosDispMto			DECIMAL(16,2);
DEFINE vPosDispFecha		DATE;
DEFINE vPosDispTransacc		CHAR(4);
DEFINE vvntDispMto			DECIMAL(16,2);
DEFINE vvntDispFec			DATE; 
DEFINE vFecUltPagoRev		DATE; 
DEFINE vMtoUltPagoRev		DECIMAL(16,2);      
DEFINE vTransUltPagoRev		CHAR(4);
DEFINE UltPagoRev		CHAR(16); 
DEFINE vatmDispMtoRev		DECIMAL(16,2);
DEFINE vAtmDispFecRev		DATE;
DEFINE vAtmDispTransaccRev	CHAR(4);
DEFINE vFolioAtmDispRev		CHAR(16); 
DEFINE vPosDispMtoRev		DECIMAL(16,2);
DEFINE vPosDispFecRev		DATE;
DEFINE vPosDispTransaccRev	CHAR(4); 
DEFINE vFolioPosDispRev		CHAR(16); 	    
DEFINE vvntDispMtoRev		DECIMAL(16,2);
DEFINE vvntDispFecRev		DATE; 
DEFINE vFolioVntDispRev		CHAR(16);
DEFINE vfolioultpagorev		CHAR(16);
DEFINE vRevPAGO				CHAR(1);
DEFINE vRevATM				CHAR(1);
DEFINE vRevPOS				CHAR(1);
DEFINE vRevVTN				CHAR(1);
DEFINE vlnum_avisos         CHAR(1);
DEFINE vlSaldoMaximo		DECIMAL (16,2);
DEFINE	pEmpresa	char(3);

DEFINE  vMtoAcumulado	DECIMAL(18,2);
DEFINE	vNumTrans	INTEGER;
DEFINE	bContinua	Char(1);
DEFINE	vlNumVencidos		SMALLINT;


--vPagoCliente|| '-Indicador-'||pIndicador||'-vtipotrans-'|| vtipotrans  

------------------------------------------------

  --SET DEBUG FILE TO '/ifxsif01/macf/sp_graba_indicador.out';
  --TRACE ON;

    LET cCod_ret      = '0000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';	
	
	LET vPagoCliente  = '';
	
	
	LET vtipotrans = '';		
	
	LET vTransPrimerCompra 	='';
	LET vfecPrimerDisp		=DATE(1);
	LET vMontoPrimerDisp	=0;
	LET vTransPrimerDisp	='';
	LET vFolioUltPago		='';
	LET vFolioPosDisp		='';
	LET vFolioAtmDisp		='';
	LET vFolioVntDisp		='';
	LET vFecUltPago			=DATE(1);
	LET vMtoUltPago			=0;
	LET vTransUltPago		='';
	LET vFolioUltPago		='';
	LET vAtmDispMto			=0;
	LET vAtmDispFec			=DATE(1);
	LET vAtmDispTransacc	='';
	LET vFolioAtmDisp		='';
	LET vPosDispMto			=0;
	LET vPosDispFecha		=DATE(1);
	LET vPosDispTransacc	='';
	LET vvntDispMto			=0;
	LET vvntDispFec			=DATE(1);	
	LET vFecUltPagoRev		=DATE(1);
	LET vMtoUltPagoRev		=0;
	LET vTransUltPagoRev	='';
	LET vFolioUltPagoRev	='';
	    
	LET vatmDispMtoRev		=0;
	LET vAtmDispFecRev		=DATE(1);
	LET vAtmDispTransaccRev	='';
	LET vFolioAtmDispRev	='';
	LET vPosDispMtoRev		=0;
	LET vPosDispFecRev		=DATE(1);
	LET vPosDispTransaccRev	='';
	LET vFolioPosDispRev	='';
	LET vvntDispMtoRev		=0;
	LET vvntDispFecRev		=DATE(1);
	LET vFolioVntDispRev	='';	
	LET bContinua = 'V';		
	LET vlSentido = '';
	LET vMtoReversion = 0;  
	LET	vlNumVencidos = 0;
	LET vRevPAGO = '';
	LET vRevATM = '';
	LET vRevPOS = '';
	LET vRevVTN = '';
    LET vlnum_avisos = 0;
	LET vlSaldoMaximo = 0.0;
	let pEmpresa = '001';
    LET vlIndicador = 10;
	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);		
            RETURN cCod_ret;
        END EXCEPTION;		
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;		
		
		select max(fecha_ult_respaldo) 
		 into vlfult_respaldo
  		  from sd_indicador_cred
          where fecha_ult_respaldo is not null;
         
          IF DAY (vlfult_respaldo) = 20 THEN 
            LET vlIndicador = 0; 
          ELSE 
            LET vlIndicador = 1; 
          END IF;
		  
		  
        IF pProducto = '6001' THEN  
        FOREACH WITH HOLD
          SELECT a.num_credito
            into vlCredito
            FROM sd_indicador_cred a
           where a.empresa =pEmpresa             
			 and num_credito not in ( select num_credito from sd_indicador_cred_hist 
                                                    where empresa  = '001'													
                                                     and fecha = vlfult_respaldo  )
			 and fecha_ult_respaldo = vlfult_respaldo
													  
			 
			IF vlIndicador = 0 THEN 
			  BEGIN WORK; 
				INSERT INTO sd_indicador_cred_hist			
				(empresa,   fecha,  num_credito,    num_vencidos,   fecha_ultimo_pago,  monto_ultimo_pago,
				fecha_ultima_compra,   monto_ultima_compra,        atm_disp_monto,     atm_disp_fecha , 
				pos_disp_monto,             pos_disp_fecha,     
				vnt_disp_monto,        vnt_disp_fecha,             saldo_maximo,       fecha_sdo_maximo, 
				saldo_max_facturado,   pago_mayor, num_atm,        monto_atm,          num_pos,    
				monto_pos,             num_vtn,                    monto_vtn,          num_pagos,
				monto_pagos,           monto_capitalizado, comportamiento,dias_atraso,
                sdo_tot_liquidar, pago_minimo, sdo_tot_vencido, limite_credito, comision_anualidad, fecha_comision_anualidad,
                comision_disp_efectivo_ch, comision_apertura, fecha_comision_apertura, intereses_periodo, monto_devoluciones, 
                monto_otras_trnx, total_comisiones, max_mora_hist, saldo_maximo_hist, num_veces_mora1, num_veces_mora2,
                num_veces_mora3, num_veces_mora4, peor_mora_12m, fecha_ultima_mora, fecha_promesa_rota, num_pagos_hist,
                num_convenios_hist, promesa_pago, dias_act)
				select  empresa,	vlfult_respaldo,	num_credito,    num_vencidos,   fecha_ultimo_pago_ch,  monto_ultimo_pago_ch,
				 fecha_ultima_compra_ch,   			monto_ultima_compra_ch,        		   atm_disp_monto_ch,     
				 atm_disp_fecha_ch, pos_disp_monto_ch,              pos_disp_fecha_ch,     vnt_disp_monto_ch,       		    
				 vnt_disp_fecha_ch, saldo_maximo_ch,fecha_sdo_maximo_ch,				   saldo_max_facturado_ch,   
				 pago_mayor_ch, 	num_atm_ch,     monto_atm_ch,	num_pos_ch,			   monto_pos_ch,             
				 num_vtn_ch,		monto_vtn_ch,	num_pagos_ch,	monto_pagos_ch,        monto_capitalizado_ch, comportamiento,dias_atraso,
                 sdo_tot_liquidar_ch, pago_minimo_ch, sdo_tot_vencido_ch, limite_credito_ch, comision_anualidad, fecha_comision_anualidad,
                 comision_disp_efectivo_ch, comision_apertura, fecha_comision_apertura, intereses_periodo_ch, monto_devoluciones_ch,
                 monto_otras_trnx_ch, total_comisiones_ch, max_mora_hist, saldo_maximo_hist, num_veces_mora1, num_veces_mora2,
                 num_veces_mora3, num_veces_mora4, peor_mora_12m, fecha_ultima_mora, fecha_promesa_rota, num_pagos_hist,
                 num_convenios_hist, promesa_pago, dias_act
				FROM "informix".sd_indicador_cred
				WHERE empresa = pEmpresa
				 and num_credito = vlCredito;  
			  COMMIT WORK;	 
			ELSE
				BEGIN WORK;
				INSERT INTO sd_indicador_cred_hist			
				(empresa,   fecha,  num_credito,    num_vencidos,   fecha_ultimo_pago,  monto_ultimo_pago,
				fecha_ultima_compra,   monto_ultima_compra,        atm_disp_monto,     atm_disp_fecha , 
				atm_disp_transacc,     pos_disp_monto,             pos_disp_fecha,     pos_disp_transacc,
				vnt_disp_monto,        vnt_disp_fecha,             saldo_maximo,       fecha_sdo_maximo, 
				saldo_max_facturado,   pago_mayor, num_atm,        monto_atm,          num_pos,    
				monto_pos,             num_vtn,                    monto_vtn,          num_pagos,
				monto_pagos,           monto_ult_convenio  ,       fecha_ult_convenio, comportamiento,dias_atraso,impagos_consec_h,moras_hist_h,
				
				sdo_tot_liquidar, pago_minimo, sdo_tot_vencido, limite_credito, comision_anualidad, fecha_comision_anualidad,
                --comision_disp_efectivo, comision_apertura, fecha_comision_apertura, monto_devoluciones,
				comision_disp_efectivo_ch, comision_apertura, fecha_comision_apertura, monto_devoluciones,
                monto_otras_trnx, total_comisiones, max_mora_hist, saldo_maximo_hist, num_veces_mora1, num_veces_mora2,
                num_veces_mora3, num_veces_mora4, peor_mora_12m, fecha_ultima_mora, fecha_promesa_rota, num_pagos_hist,
                num_convenios_hist, promesa_pago, dias_act)
				select   
				empresa,   vlfult_respaldo,  num_credito,    num_vencidos_his,   fecha_ultimo_pago_h,  monto_ultimo_pago_h,
				fecha_ultima_compra_h,   monto_ultima_compra_h,        atm_disp_monto_h,     atm_disp_fecha_h , 
				atm_disp_transacc_h,     pos_disp_monto_h,             pos_disp_fecha_h,     pos_disp_transacc_h,
				vnt_disp_monto_h,        vnt_disp_fecha_h,             saldo_maximo_h,       fecha_sdo_maximo_h, 
				saldo_max_facturado_h,   pago_mayor_h, num_atm_h,        monto_atm_h,          num_pos_h,    
				monto_pos_h,             num_vtn_h,                    monto_vtn_h,          num_pagos_h,
				monto_pagos_h,           monto_ult_convenio_h,			fecha_ult_convenio_h,comportamiento,dias_atraso,impagos_consec_h,moras_hist_h,
                sdo_tot_liquidar_h, pago_minimo_h, sdo_tot_vencido_h, limite_credito_h, comision_anualidad, fecha_comision_anualidad,
                --comision_disp_efectivo, comision_apertura, fecha_comision_apertura, monto_devoluciones,
				comision_disp_efectivo_ch, comision_apertura, fecha_comision_apertura, monto_devoluciones,
                monto_otras_trnx, total_comisiones, max_mora_hist, saldo_maximo_hist, num_veces_mora1, num_veces_mora2,
                num_veces_mora3, num_veces_mora4, peor_mora_12m, fecha_ultima_mora, fecha_promesa_rota, num_pagos_hist,
                num_convenios_hist, promesa_pago, dias_act
				FROM "informix".sd_indicador_cred
				WHERE empresa = pEmpresa
				  and num_credito = vlCredito;  
				COMMIT WORK;  
			END IF;
        END FOREACH;     
END IF;
		--insert into bdicobranza:cb_bitacora (mensaje) values  (pCodigoFun||'-Primer Compra-'||pTransacc);		
		---Consulta indicadores que pueden tener reversión
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se agregan indicadores del Triad',
'AUTOR : Marco A. Campos',
'FECHA : 2018/08/30',
'DESCRIPCION: Se inserta o actualiza el indicador de Crédito',
'AUTOR : Faviola Martínez Juárez',
'FECHA : 17/Septiembre/2012',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".pasecont(pempresa     CHAR(3),
                                     fecha_pase   DATE,
                                     pusuario     CHAR(8),
                                     pusuariopase CHAR(8),
                                     pproceso     CHAR(10))
   RETURNING CHAR(5), varchar(80);

   DEFINE wcod_ret                      CHAR(5);
   DEFINE P_MENSAJE                     VARCHAR(80);
   DEFINE sql_err                       SMALLINT;
   DEFINE isam_err                      SMALLINT;
   DEFINE error_info                    CHAR(40);
   DEFINE v_error                       smallint;

   DEFINE wbegin                        CHAR(1);
   DEFINE wusuario                      CHAR(8);
   DEFINE wejecutivo                    CHAR(8);
   DEFINE wfecha_hoy                    DATE;
   DEFINE nrows                         SMALLINT;
   DEFINE wproceso                      CHAR(10);
   DEFINE valor_cambio                  DECIMAL(6,4);
   DEFINE wdivisa_cambio                CHAR(2);
   DEFINE wsecuenciamn                  INTEGER;
   DEFINE wsecuenciadl                  INTEGER;
   DEFINE wnro_auxiliar                 CHAR(9);
   DEFINE wdescripcion_det              CHAR(50);
   DEFINE wnumpolmn                     SMALLINT;
   DEFINE wnumpoldl                     SMALLINT;
   DEFINE wfecha                        CHAR(10);
   DEFINE wbanco                        CHAR(3);

{****************************************************************************
 **         INICIA REGISTRO DE PASE CONTABLE                               **
 ****************************************************************************}

   DEFINE wregional                     CHAR(3);
   DEFINE wsucursal                     CHAR(4);
   DEFINE wdivisa                       CHAR(2);
   DEFINE wcodigo_fun                   CHAR(3);
   DEFINE wcodigo_ref                   SMALLINT;
   DEFINE wnum_cuota                    SMALLINT;
   DEFINE wtransacc                     CHAR(4);
   DEFINE wapell_paterno                CHAR(15);
   DEFINE wapell_materno                CHAR(15);
   DEFINE wnombre1                      CHAR(15);
   DEFINE wnombre2                      CHAR(15);
   DEFINE wrazon_social                 CHAR(40);
   DEFINE wabreviatura                  CHAR(50);
   DEFINE wsecuencia                    SMALLINT;
   DEFINE wvaloriza                     CHAR(1);
   DEFINE wcmayor                       CHAR(4);
   DEFINE wcsub1                        CHAR(3);
   DEFINE wcsub2                        CHAR(3);
   DEFINE wcsub3                        CHAR(3);
   DEFINE wcsub4                        CHAR(3);
   DEFINE wcsector                      CHAR(3);

   DEFINE wamayor                       CHAR(4);
   DEFINE wasub1                        CHAR(3);
   DEFINE wasub2                        CHAR(3);
   DEFINE wasub3                        CHAR(3);
   DEFINE wasub4                        CHAR(3);
   DEFINE wasector                      CHAR(3);
    DEFINE var_cuenta_contable	CHAR(16);

   DEFINE wmonto                        MONEY(14,2);
{****************************************************************************
 **      TERMINA REGISTRO DE PASE CONTABLE                                 **
 **      INICIA REGISTRO DETPOL                                            **
 ****************************************************************************}

   DEFINE detusuario                    CHAR(11);
   DEFINE detcontrol_poliza             SMALLINT;
   DEFINE detfecha_captura              DATE;
   DEFINE detsecuencia                  INTEGER;
   DEFINE detempresa                    CHAR(3);
   DEFINE detmayor                      CHAR(4);
   DEFINE detsub1                       CHAR(3);
   DEFINE detsub2                       CHAR(3);
   DEFINE detsub3                       CHAR(3);
   DEFINE detsub4                       CHAR(3);
   DEFINE detsector                     CHAR(3);
   DEFINE detciudad                     CHAR(3);
   DEFINE detsucursal                   CHAR(4);
   DEFINE detnro_auxiliar               CHAR(9);
   DEFINE detnaturaleza                 CHAR(1);
   DEFINE detmonto                      MONEY(14,2);
   DEFINE detdescripcion_det            CHAR(50);
   DEFINE detfecha_valida               DATE;
   DEFINE detmoneda                     CHAR(2);
   DEFINE detvalor_cambio               MONEY(12,7);
   DEFINE detvalor_div_cambio           MONEY(12,7);
   DEFINE detmca_aplica                 CHAR(1);
   DEFINE detpoliza_usuario             CHAR(11);
   DEFINE dettipo_mov                   CHAR(1);
   
{***************************************************************************
 **   TERMINA REGISTRO DE DETPOL                                          **
 **   INICIA REGISTRO DE ENCABEZADO DE POLIZA                             **
 ***************************************************************************}

   DEFINE polcifra_control              MONEY(14,2);
   DEFINE polcargo                      MONEY(14,2);
   DEFINE polabono                      MONEY(14,2);
{***************************************************************************
 **   TERMINA REGISTRO DE ENCABEZADO DE POLIZA                            **
 ***************************************************************************}

   DEFINE wsectoriza                    CHAR(1);
   DEFINE dsecuencia                    INTEGER;
   DEFINE dcontrol_poliza               SMALLINT;
   DEFINE wsucorigen			CHAR(4);
   DEFINE dccosto_orig			CHAR(4);
   DEFINE icontador INTEGER;
   
   --IFSR se agrega bandera para saber si se encuentra activo el IFSR
   DEFINE cBanderaIFSR 					CHAR(1);


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET wcod_ret = sql_err;
      SET DEBUG FILE TO "pasecont.err";
      TRACE sql_err||" * "||isam_err|| " * "||error_info;
      IF (wbegin = "S") THEN
         ROLLBACK WORK;
         BEGIN WORK;
      ELSE
         ROLLBACK WORK;
      END IF;
      RETURN wcod_ret, P_MENSAJE;
   END EXCEPTION;


   ON EXCEPTION IN (-535)
      LET wbegin = "S";
      ROLLBACK WORK;
      BEGIN WORK;
   END EXCEPTION WITH RESUME;

--  SET DEBUG FILE TO "/RESPALDOS/PruebasIFSR/pasecont.out";
--  TRACE ON;


   LET wbegin = "S";
   LET wnum_cuota = 0;
   LET wproceso = ""; --NULL;
   LET P_MENSAJE = 'PROCESO EXITOSO';
   
   --LET detusuario = 'credito';
   LET detusuario = pusuariopase;
    LET icontador=1;
	

   BEGIN WORK;
      LET wcod_ret = "000";
      LET wproceso = pproceso;  -- "PaseCont";
 
	let fecha_pase = fecha_pase;	
	
	-- IFSR se inicializa la bandera de IFSR
	LET cBanderaIFSR = 'I';

      IF fecha_pase IS NULL OR fecha_pase = " "THEN
         SELECT fecha_hoy
           INTO wfecha_hoy
           FROM sd_fechas
          WHERE empresa = pempresa;
      ELSE
	LET wfecha_hoy = fecha_pase;
      END IF


      IF pusuariopase IS NULL OR pusuariopase = " " THEN
         LET wcod_ret = "821";
         RETURN wcod_ret, P_MENSAJE;
      END IF

--      SELECT proceso
--        INTO wproceso
--        FROM sd_contproc
--       WHERE empresa = pempresa
--         AND proceso = wproceso
--         AND fecha = fecha_pase;

      SELECT proceso
        INTO wproceso
        FROM bdinteg:sx_contproc
       WHERE empresa = pempresa
         AND proceso = wproceso
         AND sistema = "06"
         AND fecha = fecha_pase;


      --borra lo existente en la base de contabilidad
         delete from bdicont:co_poldet
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_detpol
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      delete from bdicont:co_poliza
       where empresa = pempresa
         and fecha_captura = fecha_pase
         and usuario = pusuariopase;   --'credito';

      SELECT ejecutivo
        INTO wejecutivo
        FROM bdinteg:si_ejecut
       WHERE empresa = pempresa
         AND ejecutivo = pusuario;

      LET nrows = dbinfo("sqlca.sqlerrd2");

      IF (nrows = 0) THEN
         LET wcod_ret = "090";
         LET P_MENSAJE = 'Usuario no Valido para ejecutar el proceso';
         IF (wbegin = "S") THEN
            ROLLBACK WORK;
            BEGIN WORK;
         ELSE
            ROLLBACK WORK;
         END IF;
         RETURN wcod_ret, P_MENSAJE;
      END IF;

      if wproceso is NULL then

        LET wproceso = pproceso;   --"PaseCont";

        INSERT INTO sd_contproc
        VALUES (pempresa, wproceso, fecha_pase, "I", USER,
                CURRENT, CURRENT, "  ", "Proceso Iniciado");
                
        INSERT INTO bdinteg:sx_contproc 
	   (empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,
	    hora_fin,codret)
        VALUES 
	   (pempresa, wproceso, fecha_pase, "06","I", USER,CURRENT, 
	    CURRENT, "  ");
                
      else
        UPDATE sd_contproc
               set ejecutivo = user
                  ,hora_inicio = current
                  ,hora_fin = current
                  ,status_proc = 'I'
                  ,mensaje = 'PROCESO INICIADO'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   fecha = fecha_pase;
        
        UPDATE bdinteg:sx_contproc
               set ejecutivo = user
                  ,hora_ini = current
                  ,hora_fin = current
                  ,status_proc = 'I'
        WHERE empresa = pempresa
        AND   proceso = wproceso
        AND   sistema = "06"
        AND   fecha = fecha_pase;

      end if;

   commit work;
   LET wbegin = "N";

{************************************************************************
 ** INICIA CREACION DE TABLAS TEMPORALES Y CARGA DE PARAMETROS         **
 ** NECESARIOS PARA EL PASE CONTABLE                                   **
 ************************************************************************}

      CREATE TEMP TABLE tdetpol
         ( usuario               CHAR(11)  NOT NULL ,
          control_poliza        SMALLINT NOT NULL ,
          fecha_captura         DATE     NOT NULL ,
          secuencia             INTEGER  NOT NULL ,
          empresa               CHAR(3),
          ccmayor               CHAR(4),
          ccsub                 CHAR(3),
          ccsubsub              CHAR(3),
          ccssubsub             CHAR(3),
          ccsssubsub            CHAR(3),
          sector                CHAR(3),
          ciudad                CHAR(3),
          sucursal              CHAR(4),
          nro_auxiliar          CHAR(9),
          naturaleza            CHAR(1),
          monto                 MONEY(19,2),
          descripcion_det       CHAR(50),
          fecha_valida          DATE,
          moneda                CHAR(2),
          valor_cambio          MONEY(12,7),
          valor_div_cambio      MONEY(12,7),
          mca_aplic             CHAR(1),
          poliza_usuario        CHAR(11),
          tipo_mov              CHAR(1),
          ccosto_orig           CHAR(4)) with no log;

      SET ISOLATION TO DIRTY READ;

      SELECT valor
        INTO wbanco
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param = "5";

      SELECT valor
        INTO wdivisa_cambio
        FROM bdinteg:si_param
       WHERE empresa = pempresa
         AND cod_param  = "17";

      SELECT tipo_cpa_mn_div
        INTO valor_cambio
        FROM bdinteg:si_tpcambio
       WHERE empresa = pempresa
         AND divisa = wdivisa_cambio
         AND fecha_tpcambio = wfecha_hoy
         AND clase_tpcambio = "O";
		 
		--IFSR se recupera el valor de la bandera para plan IFSR
		SELECT NVL(valor,'I')
        INTO cBanderaIFSR
        FROM bdicred:sd_param
		WHERE empresa = pempresa
         AND cod_param = "700"; 

      LET nrows = dbinfo("sqlca.sqlerrd2");
      IF  (nrows = 0) THEN
      {   SELECT tipo_cpa_mn_div
           INTO valor_cambio
           FROM bdinteg:si_histdiv
          WHERE empresa = pempresa
            AND divisa = wdivisa_cambio
            AND fecha_tc = wfecha_hoy
            AND clase_tpcambio = "O";}

         LET nrows = dbinfo("sqlca.sqlerrd2");
--         IF (nrows = 0) THEN
--            LET wcod_ret ="017";
--            IF (wbegin = "S") THEN
--               ROLLBACK WORK;
--               BEGIN WORK;
--            ELSE
--               ROLLBACK WORK;
--            END IF;
--            RETURN wcod_ret, P_MENSAJE;
--         END IF;
      END IF;

      LET wusuario = pusuariopase;   --"credito";  
      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET wnro_auxiliar = " ";
      LET wdescripcion_det = "MOVIMIENTOS DE CREDITO DEL DIA ";
      LET wfecha = wfecha_hoy;
      LET wdescripcion_det = TRIM(wdescripcion_det)||" "||TRIM(wfecha);

      SELECT MAX(control_poliza)
        INTO wnumpolmn
        FROM bdicont:co_detpol
       WHERE usuario = wusuario
         AND fecha_captura = wfecha_hoy
         AND moneda = "00"
         AND empresa = pempresa;

      IF (wnumpolmn IS NULL or wnumpolmn = 0) THEN
         LET wnumpolmn = 1;
      ELSE
         LET wnumpolmn = wnumpolmn + 1;
      END IF;

      LET wnumpoldl = wnumpolmn + 1;
      IF pusuariopase = "califcar" OR pusuariopase  = "canccart" then
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(a.monto) monto, a.sucursal,b.num_producto
           FROM sd_movhis_calif a,sd_maecred b,bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = fecha_pase
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      ELSE
         SELECT c.regional, a.suc_origen, a.codigo_fun, a.codigo_ref,
                a.divisa, sum(monto) monto, a.sucursal,b.num_producto
           FROM sd_movdia a, sd_maecred b, bdinteg:si_plazas c
          WHERE a.empresa = pempresa
            AND a.empresa = b.empresa
            AND a.num_credito = b.num_credito
            AND a.plaza = c.plaza
            AND a.reversado = 'N'
            AND TRIM(a.folio_suc) NOT IN ("CalifCartReserva","CalifCart")
            AND a.fecha_mov = fecha_pase
            AND a.monto > 0
            group by 1,2,3,4,5,7,8
           INTO TEMP x WITH NO LOG;
      END IF

	  -- IFSR se valida si la bandera estÃÂ¡ activa, si no se encuentra activa  sigue su proceso normal y i estÃÂ¡ prendida se crea una tabla temporal con los datos de ifsr
	  IF(cBanderaIFSR = 'I') THEN
		SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           FROM x a, sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun
            AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa
            AND c.numero = b.transacc
            AND c.sistema = "06"
            AND d.empresa = b.empresa
            AND d.producto = a.num_producto
            AND d.sistema = c.sistema
            AND d.transaccion = b.transacc
            AND d.secuencia>0
          --ORDER BY 1,2,3,4,5,6
		  INTO temp univ_movs WITH NO LOG;
		  
	  ELSE
		SELECT a.regional, a.sucursal, a.divisa, a.codigo_fun, a.codigo_ref,
                a.suc_origen, c.descripcion, d.secuencia, c.valoriza,
                d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub,
                d.c_ccssssub, d.c_sector, d.a_ccmayor, d.a_ccsub,
                d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector,a.monto
           FROM x a, sd_transfun b,bdinteg:si_transacc c, bdinteg:si_prodtran d
          WHERE b.empresa= pempresa
            AND b.codigo_fun=a.codigo_fun
            AND b.codigo_ref=a.codigo_ref
            AND c.empresa = b.empresa
            AND c.numero = b.transacc_ifrs
            AND c.sistema = "06"
            AND d.empresa = b.empresa
            AND d.producto = a.num_producto
            AND d.sistema = c.sistema
            AND d.transaccion = b.transacc_ifrs
            AND d.secuencia>0
          --ORDER BY 1,2,3,4,5,6
		  INTO temp univ_movs WITH NO LOG;
	 END IF;

      FOREACH
         SELECT regional, sucursal, divisa, codigo_fun, codigo_ref,
                suc_origen, descripcion, secuencia, valoriza,
                c_ccmayor, c_ccsub, c_ccsubsub, c_ccsssub,
                c_ccssssub, c_sector, a_ccmayor, a_ccsub,
                a_ccsubsub, a_ccsssub, a_ccssssub, a_sector,monto
           INTO wregional, wsucursal, wdivisa, wcodigo_fun,
                wcodigo_ref, wsucorigen, wabreviatura, wsecuencia, wvaloriza, 
	            wcmayor, wcsub1, wcsub2, wcsub3, wcsub4, wcsector,
                wamayor, wasub1, wasub2, wasub3, wasub4, wasector,
                wmonto
           FROM univ_movs
		   ORDER BY 1,2,3,4,5,6

            LET wdescripcion_det = wabreviatura;

            IF (wvaloriza = "S" AND wsecuencia = 2
                AND wdivisa <> "00") THEN
               LET wmonto = wmonto * valor_cambio;
               LET wdivisa = "00";
            END IF;

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;
			
	


   LET wcmayor = trim(wcmayor);
   IF wcmayor[1,2] = "95" THEN

           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_hoy,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal 
	--	wsucorigen
               );
   ELSE
     
           INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_hoy,
                dsecuencia,
                "001",
                wcmayor,
                wcsub1,
                wcsub2,
                wcsub3,
                wcsub4,
                wcsector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "D",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
  
   END IF; 

            IF (wdivisa = "00") THEN
               LET dsecuencia = wsecuenciamn;
               LET dcontrol_poliza = wnumpolmn;
               LET wsecuenciamn = wsecuenciamn + 1;
            ELSE
               LET dsecuencia = wsecuenciadl;
               LET dcontrol_poliza = wnumpoldl;
               LET wsecuenciadl = wsecuenciadl + 1;
            END IF;

  LET wamayor = trim(wamayor); 
  IF wamayor[1,2] = "95" THEN

            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_hoy,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
                wsucursal,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
                wsucursal
	--	wsucorigen
               );
   ELSE
            INSERT INTO tdetpol VALUES
               (
                wusuario,
                dcontrol_poliza,
                wfecha_hoy,
                dsecuencia,
                "001",
                wamayor,
                wasub1,
                wasub2,
                wasub3,
                wasub4,
                wasector,
                wregional,
--                wsucursal,
                wsucorigen,
                wnro_auxiliar,
                "C",
                wmonto,
                wdescripcion_det,
                wfecha_hoy,
                wdivisa,
                0,
                0,
                " ",
                wusuario,
                " ",
--                wsucorigen
                wsucursal
               );
   END IF;

      END FOREACH;

      LET wsecuenciamn = 1;
      LET wsecuenciadl = 1;
      LET detsecuencia = 1;
      LET detvalor_cambio = 0;
      LET detvalor_div_cambio = 0;
      LET detmca_aplica = " ";
      LET dettipo_mov = " ";


      FOREACH with hold
         SELECT usuario, control_poliza, fecha_captura ,
            empresa, ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub,
            sector, ciudad, sucursal, nro_auxiliar, naturaleza, sum(monto),
            descripcion_det, fecha_valida, moneda, ccosto_orig
         INTO detusuario, detcontrol_poliza, detfecha_captura,
            detempresa, detmayor, detsub1, detsub2, detsub3, detsub4,
            detsector, detciudad, detsucursal, detnro_auxiliar,
            detnaturaleza, detmonto, detdescripcion_det, detfecha_valida,
            detmoneda, dccosto_orig
         FROM
            tdetpol
         GROUP BY
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19
         ORDER BY
            11, 12, 5, 6, 7, 8, 9, 10

			
		--Asignacion de Centro de Costos Destinos para corresponsales en cuentas contables afectadas
			--LET var_cuenta_contable = detmayor+detsub1+detsub2+detsub3+detsub4;
			LET var_cuenta_contable = trim(detmayor)||trim(detsub1)||trim(detsub2)||trim(detsub3)||trim(detsub4);
			
			 IF (var_cuenta_contable = "140290141101" OR
				 var_cuenta_contable = "140290141102" OR
				 var_cuenta_contable = "140290140301") THEN
				Select centro_costo
			    INTO detsucursal
				FROM sd_catcentrocosto
				WHERE cuenta_contable = var_cuenta_contable;
            END IF;
			
         IF (detmoneda = "00") THEN
            LET detcontrol_poliza = wnumpolmn;
            LET detsecuencia = wsecuenciamn;
            LET wsecuenciamn = wsecuenciamn + 1;
         ELSE
            LET detcontrol_poliza = wnumpoldl;
            LET detsecuencia = wsecuenciadl;
            LET wsecuenciadl = wsecuenciadl + 1;
         END IF;
        
			
			
        IF icontador=1 then
          BEGIN WORK;
        END IF;
		
				
			
         LET detpoliza_usuario = detusuario;
         INSERT INTO
            bdicont:co_poldet
         VALUES
           (detusuario,
            detfecha_captura,
            detsecuencia,
            detempresa,
            detmayor,
            detsub1,
            detsub2,
            detsub3,
            detsub4,
            detsector,
            detciudad,
            detsucursal,
			detnro_auxiliar,
            detnaturaleza,
            detmonto,
            detdescripcion_det,
            detfecha_valida,
            detmoneda,
	    	dccosto_orig);

    IF icontador>=70000 then
        COMMIT WORK; 
        LET icontador=1;
    ELSE
        LET icontador=icontador+1;
    END IF;

      END FOREACH;

  IF icontador > 1 THEN
        COMMIT WORK; 
  END IF;

      DROP TABLE tdetpol;
      DROP TABLE x;

--   IF (wbegin = "S") THEN
--      COMMIT WORK;
--      BEGIN WORK;
--   ELSE
--      COMMIT WORK;
--   END IF;

   --EJECUTA EL PROCESO DE AUDITOR

   EXECUTE PROCEDURE BDICONT:AUDITAPASE(FECHA_PASE,PEMPRESA,detusuario)
           INTO WCOD_RET;

    IF wcod_ret = "00000" THEN
       LET wcod_ret = "000";
    END IF	

   let v_error = wcod_ret;

   IF v_error = 0 then
      UPDATE sd_contproc
      SET status_proc = "F",
          mensaje = 'PROCESO EXITOSO',
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "F",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   ELSE
      UPDATE sd_contproc
      SET status_proc = "C",
          mensaje = 'ERROR: ' || P_MENSAJE,
          hora_fin = CURRENT,
          cod_ret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   fecha = fecha_pase;
      
      UPDATE bdinteg:sx_contproc
      SET status_proc = "C",
          hora_fin = CURRENT,
          codret   = wcod_ret
      WHERE proceso = wproceso
      AND   empresa = pempresa
      AND   sistema = "06"
      AND   fecha = fecha_pase;

      
   END IF;

--   commit work;
   RETURN wcod_ret, P_MENSAJE;

END PROCEDURE;