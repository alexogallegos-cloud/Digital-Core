CREATE procedure "informix".sp_actualiza_resumscorfin( pEmpresa char(3), pNumsol char(20),
                                            o_situacion_pago             DECIMAL(5,2),
                                            o_situacion_credito          CHAR(1),
                                            o_meses_historia             SMALLINT,
											o_ingreso                    MONEY(14,2),
											o_linea                      MONEY(14,2),
											o_causa                      SMALLINT,
											o_puntualidad                CHAR(2),
											o_saldoropa                  MONEY(14,2),
											o_saldomuebles               MONEY(14,2),
											o_saldoprestamos             MONEY(14,2),
											o_vencidoropa                MONEY(14,2),
											o_vencidomuebles             MONEY(14,2),
											o_vencidoprestamos           MONEY(14,2),
											o_abonomensualropa           MONEY(14,2),
											o_abonomensualmuebles        MONEY(14,2),
											o_abonomensualprestamos      MONEY(14,2),
											o_ultimacompra               DATE,
											pVencido_total_aire		     INT,
											pAbono_mensual_aire		     INT,
											pSaldo_total_aire		     INT,
											Pvencidoa_total_filiados     INT,
											pAbono_mensual_afiliados     INT,
											pSaldo_total_afiliados       INT,
 											pVencido_total_reestructura  INT, 
											pAbono_mensual_reestructura  INT,
											pSaldo_total_reestructura    INT,
											pScorePuntualidad			 INT)	
RETURNING char (5);

DEFINE scod_ret CHAR(5);
DEFINE vsqlerr  INTEGER;

--DEFINE vsituacion_pago decimal(5,2);
--DEFINE vsituacion_credito char(1);
--DEFINE vmeses_historia smallint;

--LET vsituacion_pago=0;
--LET vsituacion_credito='';
--LET vmeses_historia=0;

LET scod_ret        = "000";
LET vsqlerr         = 0;

		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        --SET DEBUG FILE TO '/pisa/pisabanco/Actualizaresumscorfin.out';
	--TRACE ON;
	
   IF pNumsol IS NULL  or pNumsol='' THEN
       LET scod_ret ="001"; --Parametros de entrada incompletos
       RETURN scod_ret;
   END IF;
   
   INSERT INTO bdisolic: "informix".ss_resum_scor_fin_resprospecteo
	(empresa, num_solicitud, situacion_pago, situacion_credito,
	meses_historia, fuente, ingreso_mensual, linea_tienda, causa,
	puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa,
	vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles,
	abonomensualprestamos,fecha_ultima_compra,origen,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,grupo,vencidototalaire,abonomensualaire,saldototalaire,
	vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
   SELECT 
         empresa, num_solicitud, situacion_pago, situacion_credito,
 	 meses_historia, fuente, ingreso_mensual, linea_tienda, causa,
 	 puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa,
	 vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles,
	 abonomensualprestamos,fecha_ultima_compra,origen,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,grupo,vencidototalaire,abonomensualaire,saldototalaire,
	 vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad
   FROM bdisolic:"informix".ss_resum_scor_fin where num_solicitud=pNumsol ;

--VALUES
	--			(o_empresa, s_numsol, o_porcentaje , o_situacion, o_meses,
--				v_fuente, o_ingreso, o_linea, o_causa, o_puntualidad, o_saldoropa,
		--		o_saldomuebles, o_saldoprestamos, o_vencidoropa, o_vencidomuebles,
--				o_vencidoprestamos, o_abonomensualropa, o_abonomensualmuebles,
		--		o_abonomensualprestamos,o_ultimacompra,'1',cFechaUltimoPago,cPrestamoAutorizado,iMontoAutorizado,iRePrestamo,ptipogrupo);  -- El num. '1' en el campo origen indica que 
															  -- la solicitud nació por caja única
   UPDATE  bdisolic:"informix".ss_resum_scor_fin 
   SET situacion_pago=o_situacion_pago,
       situacion_credito=o_situacion_credito ,
       meses_historia=o_meses_historia,
       --ingreso_mensual=o_ingreso,
       linea_tienda=o_linea,
       causa=o_causa,
       puntualidad=o_puntualidad,
       saldoropa=o_saldoropa,
       saldomuebles=o_saldomuebles,
       saldoprestamos=o_saldoprestamos,
       vencidoropa=o_vencidoropa,
       vencidomuebles=o_vencidomuebles,
       vencidoprestamos=o_vencidoprestamos,
       abonomensualropa=o_abonomensualropa,
       abonomensualmuebles=o_abonomensualmuebles,
       abonomensualprestamos=o_abonomensualprestamos,
       fecha_ultima_compra=o_ultimacompra,
	   vencidototalaire=pVencido_total_aire,
	   abonomensualaire=pAbono_mensual_aire,
	   saldototalaire=pSaldo_total_aire,
	   vencidototalafiliados=Pvencidoa_total_filiados,
	   abonomensualafiliados=pAbono_mensual_afiliados,
	   saldototalafiliados=pSaldo_total_afiliados,
	   vencidototalreestructura=pVencido_total_reestructura,
	   abonomensualreestructura=pAbono_mensual_reestructura,
	   saldototalreestructura=pSaldo_total_reestructura,
	   scorepuntualidad=pScorePuntualidad
      -- origen=origen,
      -- fechaultimopago=fechaultimopago,
      -- prestamoautorizado=prestamoautorizado,
     --  montoautorizado=montoautorizado,
      -- represtamo=represtamo,
     --  grupo=grupo
   WHERE num_solicitud=pNumsol ;

RETURN scod_ret;
END; 

END procedure
