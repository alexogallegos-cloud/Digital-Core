CREATE PROCEDURE "informix".uencabezado2layout_edocuenta(
				pempresa char(3),
				pnum_credito char(20),
				pfechahoy date)
RETURNING CHAR(5);



DEFINE cod_ret             char(5);
DEFINE sql_err             integer;

DEFINE v_monto_financiado   decimal(18,2);
DEFINE v_sdo_cap_insoluto   decimal(18,2);
DEFINE v_credito_disponible decimal(18,2);
DEFINE v_prox_fecha_pago   	date;
DEFINE v_abonos_mes_cap     decimal(18,2);
DEFINE v_compras            decimal(18,2);
DEFINE v_disposiciones      decimal(18,2);
DEFINE v_masintereses       decimal(18,2);
DEFINE v_usted_debe_ant     decimal(18,2);
DEFINE v_mas_iva	          decimal(18,2);

DEFINE v_suma_his           decimal(18,2);
DEFINE v_suma_comi_his      decimal(18,2);
DEFINE v_suma2	            decimal(18,2);
DEFINE v_compras_his        decimal(18,2);
DEFINE v_monto_otorgado     decimal(18,2);
DEFINE v_sdo_retenido       decimal(18,2);
DEFINE v_fecha_ultimo_corte		date;
DEFINE v_dias_apertura		date;
DEFINE v_texto		     nchar(600);
DEFINE v_mensaje1		char(100);
DEFINE v_mensaje2		char(100);
DEFINE v_mensaje3		char(100);
DEFINE v_mensaje4		char(100);
DEFINE v_mensaje5		char(100);
DEFINE v_mensaje6		char(100);
DEFINE v_fechamov 		 char(10);

--INICIALIZO VARIABLES


LET v_monto_financiado    = 0;
LET v_sdo_cap_insoluto    = 0;
LET v_credito_disponible  = 0;
LET v_abonos_mes_cap      = 0;
LET v_compras          	  = 0;
LET v_disposiciones       = 0;
LET v_masintereses        = 0;
LET v_usted_debe_ant      = 0;
LET v_mas_iva	        = 0;

LET v_suma_his            = 0;
LET v_suma_comi_his       = 0;
LET v_suma2	          	  = 0;
LET v_compras_his         = 0;
LET v_monto_otorgado      = 0;
LET v_sdo_retenido        = 0;
LET v_mensaje1 = "";
LET v_mensaje2 = "";
LET v_mensaje3 = "";
LET v_mensaje4 = "";
LET v_mensaje5 = "";
LET v_mensaje6 = "";
LET v_texto = "";
LET v_fechamov = "";

 --SET DEBUG FILE TO "uencabezado2layout_edocuenta.out";
 --TRACE ON;


BEGIN

  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;


   SELECT Valor INTO v_mensaje1
   FROM bdicred:sd_param WHERE cod_param IN ('500');

   SELECT Valor INTO v_mensaje2
   FROM bdicred:sd_param WHERE cod_param IN ('501');

   SELECT Valor INTO v_mensaje3
   FROM bdicred:sd_param WHERE cod_param IN ('502');

   SELECT Valor INTO v_mensaje4
   FROM bdicred:sd_param WHERE cod_param IN ('503');

   SELECT Valor INTO v_mensaje5
   FROM bdicred:sd_param WHERE cod_param IN ('504');

   SELECT Valor INTO v_mensaje6
   FROM bdicred:sd_param WHERE cod_param IN ('505');

   LET v_texto = v_mensaje1||v_mensaje2||v_mensaje3||v_mensaje4||v_mensaje5||v_mensaje6;

   LET cod_ret = "000";

    --------------------------------------------------------
    --OBTENGO LOS MONTOS A PROCESAR
    --------------------------------------------------------
	SELECT a.monto_financiado,
		   a.sdo_cap_insoluto,
		   a.monto_otorgado,
		   a.sdo_retenido,
		   a.abonos_mes_cap,
		   b.prox_fecha_pago,
		   pfechahoy - 1 UNITS MONTH
	INTO   v_monto_financiado,
		   v_sdo_cap_insoluto,
		   v_monto_otorgado,
		   v_sdo_retenido,
		   v_abonos_mes_cap,
		   v_prox_fecha_pago,
		   v_fecha_ultimo_corte
	FROM   sd_maesdoshist a
		INNER JOIN sd_maecredanexo b
		ON a.num_credito = b.num_credito
		AND a.empresa = b.empresa
	WHERE a.fecha = pfechahoy
		AND a.empresa = pempresa
		AND a.num_credito = pnum_credito;




	    --------------------------------------------------------
	    --VERIFICO QUE TODOS LOS CAMPOS CONTENGAN INFORMACION CONDICION
	    --------------------------------------------------------
		IF NOT (v_monto_financiado IS NOT NULL AND
		   v_sdo_cap_insoluto IS NOT NULL AND
		   v_monto_otorgado   IS NOT NULL AND
		   v_sdo_retenido     IS NOT NULL AND
		   v_abonos_mes_cap   IS NOT NULL AND
		   v_prox_fecha_pago  IS NOT NULL) THEN

			IF cod_ret = "000" THEN
		    	LET cod_ret = "240";
		    END IF

		ELSE
		    --------------------------------------------------------
		    --CALCULO EL CREDITO DISPONIBLE
		    --------------------------------------------------------

			IF v_sdo_cap_insoluto < 0 THEN
				LET v_credito_disponible  = ((v_sdo_cap_insoluto * -1) + v_monto_otorgado) - v_sdo_retenido;
			ELSE
				LET v_credito_disponible = v_monto_otorgado - (v_sdo_cap_insoluto + v_sdo_retenido);
				IF v_credito_disponible < 0 THEN
					LET v_credito_disponible = 0;
				END IF
			END IF

		    --------------------------------------------------------
		    --OBTENGO SALDO ANTERIOR
		    --------------------------------------------------------
			SELECT sdo_cap_insoluto
				INTO v_usted_debe_ant
			FROM sd_maesdoshist
            	WHERE fecha = v_fecha_ultimo_corte
            	AND empresa= pempresa
                AND num_credito = pnum_credito;

			LET v_usted_debe_ant = NVL(v_usted_debe_ant,0);
		    --------------------------------------------------------
		    --(DISPOSICIONES) MAS COMISIONES V_SUMA_HIS
		    --------------------------------------------------------
			--Se agregan nuevos codigos de IFRS
			SELECT 	SUM(CASE WHEN codigo_fun   = '002' THEN
					CASE WHEN codigo_ref IN (30,34,35,36,38,39,50)  THEN  monto ELSE 0 END
					ELSE  0 END),
					SUM(CASE WHEN codigo_fun   = '605' THEN
					CASE WHEN codigo_ref  IN  (2,125,127)  THEN  monto ELSE 0 END
					ELSE  0 END),
					SUM(CASE WHEN codigo_fun   = '605' THEN
					CASE WHEN codigo_ref IN (3,126,128)  THEN  monto ELSE 0 END
					ELSE  0 END),
					SUM(CASE WHEN codigo_fun   = '002' THEN
					CASE WHEN codigo_ref  IN (37,937,938)  THEN  monto ELSE 0 END
					ELSE  0 END),
					SUM(CASE WHEN codigo_fun   IN ('033','334')  THEN
					CASE WHEN codigo_ref = 1  THEN  monto ELSE 0 END
					ELSE  0 END)
			INTO v_suma_his ,v_suma2,v_mas_iva,v_compras_his,v_abonos_mes_cap
			FROM   	sd_movhisedocta
			WHERE  	empresa = pempresa
			AND num_credito = pnum_credito
			AND fecha_mov > v_fecha_ultimo_corte
			AND fecha_mov <= pfechahoy
			AND reversado <> "S";


			LET v_disposiciones =  NVL(v_suma_his,0) ;
		    --------------------------------------------------------
			--MAS OTROS CARGOS
		    --------------------------------------------------------
			SELECT 	SUM(a.monto)
				INTO v_suma_comi_his
			FROM sd_movhisedocta  a
			INNER JOIN sd_transfun c
				ON a.empresa = c.empresa
				AND a.codigo_fun = c.codigo_fun
				AND  a.codigo_ref = c.codigo_ref
			INNER JOIN  bdinteg:si_transacc b
				ON c.empresa = b.empresa
				AND c.transacc = b.numero
				AND b.sistema = "06"
			WHERE  a.empresa = pempresa
				AND a.num_credito = pnum_credito
				AND a.fecha_mov > v_fecha_ultimo_corte
				AND	a.fecha_mov <= pfechahoy
				AND a.reversado <> "S"
				AND b.tipo_tran IN ('01','02','31','32');
		    --------------------------------------------------------
		    --SE OBTIENE FECHA HOY MENOS UN MES
		    --------------------------------------------------------
		    CALL CALCULAFECHA(PFECHAHOY) RETURNING V_FECHAMOV;	    
		    --------------------------------------------------------
		    --NUMERO DE DIAS APERTURADOS DE LA CUENTA
		    --(MAS INTERESES)(MAS IVA)
		    --------------------------------------------------------
			IF EXISTS(SELECT fecha_apertura FROM sd_maecred
					  WHERE  empresa = pempresa
					  AND num_credito = pnum_credito
					  AND fecha_apertura > v_fechamov
					  AND fecha_apertura = pfechahoy) THEN

				LET v_mas_iva = 0;
				LET v_masintereses = 0;
			ELSE
				LET v_masintereses = NVL(v_suma2,0);
				LET v_mas_iva = NVL(v_mas_iva,0);
			END IF

		    --------------------------------------------------------
			--(MAS COMPRAS)
		    --------------------------------------------------------

			LET v_compras = NVL(v_compras_his,0);
		    --------------------------------------------------------
			--(ABONOS DEL MES)
		    --------------------------------------------------------
			IF v_abonos_mes_cap  IS NULL THEN
				LET v_abonos_mes_cap =0;
			END IF
		    --------------------------------------------------------
			--COMIENZA LA INSERCION DE DATOS
		    --------------------------------------------------------
			INSERT INTO sd_encabezado2_edocta(
						fecha_emision,num_credito,sdo_pagar,
					    sdo_debe,sdo_disponible,pago_antes_de,
					    fecha_corte,menos_abonos,menos_o_abonos,
					    mas_compras,mas_o_cargos,mas_disp_efectivo,
					    mas_intereses,usted_debia,mas_iva,
					    usted_debe,mas_rendimientos,mensajes
					   )
				VALUES(
						pfechahoy,TRIM(pnum_credito),v_monto_financiado,
					    v_sdo_cap_insoluto,v_credito_disponible,v_prox_fecha_pago,
					    pfechahoy,v_abonos_mes_cap,"0",
					    v_compras,NVL(v_suma_comi_his,0),v_disposiciones,
					    v_masintereses,v_usted_debe_ant,v_mas_iva ,
					    v_sdo_cap_insoluto,"0",v_texto
					   );
		END IF;

  END;

  RETURN cod_ret;

--Procedimiento para el cambio de mensajes
--AUTOR : Cristian Campos Diaz',
--FECHA : 22/Noviembre/2007',
--BD    : BDICRED'
END PROCEDURE;