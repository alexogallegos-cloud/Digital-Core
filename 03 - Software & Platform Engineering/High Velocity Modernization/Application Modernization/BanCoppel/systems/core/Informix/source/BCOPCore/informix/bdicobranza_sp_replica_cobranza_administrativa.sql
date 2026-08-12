CREATE PROCEDURE "informix".sp_replica_cobranza_administrativa()
       RETURNING char(6), char(80);

--declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(80);
DEFINE cMensaje 		            CHAR(80);
DEFINE cCod_ret                     CHAR(6);
define v_fecha_hoy					date;
------------------------------------------------------------
DEFINE pFechaEjecucion              DATE;
DEFINE iDia                         INTEGER;
DEFINE pUsuario                     CHAR(8);
----------------------------------------------------------------------
DEFINE vcliente                     CHAR(20);
DEFINE vcredito                     CHAR(20);
DEFINE vtarjeta                     CHAR(20);
DEFINE vciudad                      CHAR(20);
DEFINE vestado                      CHAR(20);
DEFINE vnombre                      CHAR(110);
DEFINE vsexo                        CHAR(1);
DEFINE vcivil                       CHAR(2);
DEFINE vt_casa                      CHAR(13);
DEFINE vt_celular                   CHAR(13);
DEFINE vt_trabajo                   CHAR(13);
DEFINE vext                         CHAR(5);
DEFINE vnombre_ref                  CHAR(110);
DEFINE vt_ref                       CHAR(13);
DEFINE vsdo_total                   DECIMAL(18,2);
DEFINE vpago_min                    DECIMAL(18,2);
DEFINE vsdo_venc_int_mora           DECIMAL(18,2);
DEFINE vf_ult_pago_monto            CHAR(40);
DEFINE vpago_venc                   INTEGER;
DEFINE vpago_min_sin_vdo            DECIMAL(18,2);        
DEFINE vcausa                       SMALLINT;
DEFINE vsituacion                   CHAR(1);
DEFINE vdia							DATE;
DEFINE vhora						char(8);
DEFINE vdia2    					DATE;
DEFINE vproceso						char(4);
DEFINE Vempresa						char(3);
DEFINE Vnum_campana					smallint;
DEFINE Vproducto					char(4);
DEFINE Vfecha_ejecucion				DATE;
define vcuenta 				char(20);
DEFINE cNombre1				CHAR(26);
DEFINE cNombre2				CHAR(26);
DEFINE cApellPat			CHAR(26);
DEFINE cApellMat			CHAR(26);
DEFINE vfecha_pago 			date;
DEFINE vtipo_transacc 		CHAR(1);
DEFINE vpago_vencido  		DECIMAL(18,2);   
DEFINE vpago_req_sms		DECIMAL(18,2);  
-------------------------------cb_mail_cliente_his
DEFINE 	pempresa 			CHAR(3);
define  ctipo_mensaje    	SMALLINT;
define  cfecha_insert    	DATE;
define  cnumcte          	CHAR(20);
define  cnum_credito     	CHAR(20);
define  cemail           	CHAR(60);
define  cpago_minimo     	DECIMAL(18,2);
define  csaldo_total     	DECIMAL(18,2);
define  cpagos_vencidos  	DECIMAL(18,2);
define  cmonto_convenio  	DECIMAL(18,2);
define  cfecha_convenio  	DATE;
define  cfecha_compac    	DATE;
define  cfecha_primercons	DATE;
define  cestatus         	CHAR(2);
define  cenviado         	SMALLINT;
define  ccumplio_compac  	SMALLINT;
define  vpago_min_sin_venc 	DECIMAL(18,2);   
define  v_sdo_venc_int_mora 	DECIMAL(18,2);

--------------------------------------------
LET Vempresa 			= '';
LET Vnum_campana 		= 0;
LET Vproducto 			= '';
LET Vfecha_ejecucion 	= DATE(1);
let vcuenta 			= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET vfecha_pago 		= date(1);
LET vtipo_transacc		= 0;
LET vpago_vencido  		= 0; 
LET vpago_req_sms		= 0;
---------------------------------------
LET  pempresa 			= '';
LET  ctipo_mensaje    	= 0;
LET  cfecha_insert      = date(1);
LET  cnumcte          	= '';
LET  cnum_credito     	= '';
LET  cemail           	= '';
LET  cpago_minimo     	= 0;
LET  csaldo_total     	= 0;
LET  cpagos_vencidos  	= 0;
LET  cmonto_convenio  	= 0;
LET  cfecha_convenio  	= date(1);
LET  cfecha_compac    	= date(1);
LET  cfecha_primercons	= date(1);
LET  cestatus         	= '';
LET  cenviado         	= 0;
LET  ccumplio_compac  	= 0;
LET  vpago_min_sin_venc 	= 0;
LET  v_sdo_venc_int_mora 	= 0;
--SET DEBUG FILE TO 'sp_calcula_cobranza_administrativa_pbaaaa.out';
--trACE ON;

      LET cCod_ret      = '000000';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';
	  LET vproceso		= '0105';
      LET pUsuario      = user;
      LET pFechaEjecucion = today;
	  let v_fecha_hoy = date(1);
    --LET iDia = day(pFechaEjecucion);

	BEGIN

        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
	        LET cMensaje = error_info;
			CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '02')RETURNING cCod_ret; 

		RETURN cCod_ret, cMensaje;
		END EXCEPTION;
     
--------------------------------------------------------------------------
--se borra cb_info_administrativa datos antiguos
--------------------------------------------------------------------------

    SELECT fecha_hoy INTO v_fecha_hoy FROM bdinteg:si_fechas;
    --SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO v_fecha_hoy from sysmaster:sysshmvals;
    --DELETE cb_info_administrativa WHERE fecha_ejecucion < v_fecha_hoy -1;
/*    SELECT MAX(fecha_ejecucion) INTO vdia2 FROM bdicobranza:cb_info_administrativa_his;
      IF(vdia2 = vdia ) THEN
        DELETE bdicobranza:cb_info_administrativa WHERE fecha_ejecucion = vdia2;
    ELSE
    DELETE bdicobranza:cb_info_administrativa WHERE fecha_ejecucion < vdia2;
     END IF;
*/
    
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 


        --se obtiene la informacion
		SET ISOLATION TO dirty READ;

----------------------------------- Se obtienen DATOS del CLIENTE y SALDOS--------------------------------------------

FOREACH
            SELECT  empresa,num_campania,producto,fecha_ejecucion,cliente,credito, cuenta,tarjeta,ciudad,estado,
			  nombre1 ,nombre2,apell_paterno,apell_materno, t_celular,
			  sdo_total,pago_min,fecha_pago,sdo_venc_int_mora , pago_venc,pago_min_sin_vdo,causa,situacion,
			  tipo_transacc,pago_vencido,pago_req_sms
			INTO Vempresa,Vnum_campana,Vproducto,vfecha_ejecucion,vcliente,vcredito,vcuenta,vtarjeta ,vciudad, vestado,
				cNombre1,cNombre2,cApellPat,cApellMat,vt_celular,
				vsdo_total, vpago_min,vfecha_pago, vsdo_venc_int_mora,vpago_venc,vpago_min_sin_vdo, vcausa, vsituacion,
				vtipo_transacc,vpago_vencido,vpago_req_sms
            FROM bdicobranza:cb_info_administrativa
            WHERE fecha_ejecucion = v_fecha_hoy

---------------SE INCERTAN DATOS GENERADOS----------------------------------------------------------

			 INSERT INTO cb_info_administrativa_his (
			  empresa,num_campania,producto,fecha_ejecucion,cliente,credito, cuenta,tarjeta,ciudad,estado,
			  nombre1 ,nombre2,apell_paterno,apell_materno, t_celular,
			  sdo_total,pago_min,fecha_pago,sdo_venc_int_mora , pago_venc,pago_min_sin_vdo,causa,situacion,tipo_transacc,pago_vencido,pago_req_sms)
			  VALUES(Vempresa,Vnum_campana,Vproducto,vfecha_ejecucion,vcliente,vcredito,vcuenta,vtarjeta ,vciudad, vestado,
				cNombre1,cNombre2,cApellPat,cApellMat,vt_celular,
				vsdo_total, vpago_min,vfecha_pago, vsdo_venc_int_mora,vpago_venc,vpago_min_sin_vdo, vcausa, vsituacion,
				vtipo_transacc,vpago_vencido,vpago_req_sms);
                    
END FOREACH;

-----------------------------------------------INSERTAR----CB_MAIL_CLIENTE_HIS-------------------------------------

	FOREACH
	
		select  empresa,tipo_mensaje, fecha_insert, numcte,num_credito,	email,pago_minimo,
	        saldo_total,pagos_vencidos,	monto_convenio,	fecha_convenio,	fecha_compac, fecha_primercons,
			estatus,enviado ,cumplio_compac , pago_venc , pago_min_sin_venc , sdo_venc_int_mora 
		into 	pempresa,ctipo_mensaje,	cfecha_insert,cnumcte,cnum_credito,cemail,cpago_minimo,
			csaldo_total,cpagos_vencidos ,cmonto_convenio,cfecha_convenio,cfecha_compac, cfecha_primercons,
			cestatus,cenviado,ccumplio_compac,vpago_venc,vpago_min_sin_venc,v_sdo_venc_int_mora
		from bdicobranza:cb_mail_cliente
		where empresa = '001' and fecha_insert = v_fecha_hoy    
			
		insert into bdicobranza:"informix".cb_mail_cliente_his(
	        empresa,tipo_mensaje,fecha_insert,numcte,num_credito,email,pago_minimo,saldo_total,pagos_vencidos ,
			monto_convenio, fecha_convenio,fecha_compac, fecha_primercons,estatus,enviado ,cumplio_compac,
			pago_venc , pago_min_sin_venc , sdo_venc_int_mora )
		values(pempresa,ctipo_mensaje,cfecha_insert,cnumcte,cnum_credito,cemail,cpago_minimo,csaldo_total,cpagos_vencidos,
			cmonto_convenio,cfecha_convenio,cfecha_compac, cfecha_primercons,cestatus,cenviado ,ccumplio_compac,vpago_venc,
			vpago_min_sin_venc,v_sdo_venc_int_mora);
			
	end FOREACH;

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, cCod_ret, cMensaje, '01')RETURNING cCod_ret; 
	RETURN cCod_ret, cMensaje;

	END;
END PROCEDURE;