CREATE PROCEDURE "informix".cobranza (pempresa char(3),pnum_credito char(20),v_fechahoy date)
RETURNING CHAR(5),char(51);

--Modificacion 05112009
--Homologar uso de valor "tipo de casa" (habita_en) a nuevo catalogo (claves en letras) en paso 02 alta unica

--DECLARACION DE VARIABLES:


DEFINE cod_ret         		CHAR(5);
DEFINE sql_err         		INTEGER;
DEFINE v_cl_cobranza        CHAR(51);

DEFINE v_tp_cliente         CHAR(2);
DEFINE v_situacion          CHAR(1);
DEFINE v_estado_civil       CHAR(1);
DEFINE v_tp_casa            CHAR(1);
DEFINE v_sexo               CHAR(1);
DEFINE v_cantidad           CHAR(2);
DEFINE v_antiguedad         CHAR(2);
DEFINE v_nacimiento         CHAR(2);
DEFINE v_mto_tot_adeudo     CHAR(5);
DEFINE v_adeudo_vencido     CHAR(5);
DEFINE v_fec_ult_pago       CHAR(4);
DEFINE v_fec_ult_pago_month CHAR(2);
DEFINE v_fec_ult_pago_year  CHAR(2);
DEFINE v_cuantos_avisos		INTEGER;

DEFINE v_monto_ult_convenio CHAR(5);
DEFINE v_fecha_ult_convenio CHAR(4);
DEFINE v_est_cumpl_convenio CHAR(1);
DEFINE v_avisos 	    	CHAR(1);
DEFINE v_nivel_eficiencia     	CHAR(2);


DEFINE v_numcte             CHAR(10);


DEFINE v_sec_ingreso        CHAR(2);
DEFINE v_salario            DECIMAL(18,2);
DEFINE v_monto_adeudo       DECIMAL(18,2);
DEFINE v_mto_adeudo_venc    DECIMAL(18,2);

DEFINE v_clave1		    	VARCHAR(40);
DEFINE v_clave2		    	VARCHAR(40);
DEFINE v_clave3		    	VARCHAR(40);
DEFINE v_clave4		    	VARCHAR(40);
DEFINE v_clave5         	VARCHAR(40);


--INICIALIZO VARIABLES:

LET cod_ret        		 = "";
LET sql_err        		 = "";
LET v_cl_cobranza        = "";

LET v_tp_cliente         = "";
LET v_situacion          = "";
LET v_estado_civil       = "";
LET v_tp_casa            = "";
LET v_sexo               = "";
LET v_cantidad           = "";
LET v_antiguedad         = "";
LET v_nacimiento         = "";
LET v_mto_tot_adeudo     = "";
LET v_adeudo_vencido     = "";
LET v_fec_ult_pago       = "";
LET v_fec_ult_pago_month = "";
LET v_fec_ult_pago_year  = "";

LET v_monto_ult_convenio = "";
LET v_fecha_ult_convenio = "";
LET v_est_cumpl_convenio = "";
LET v_avisos 	    	 = "0";

LET v_numcte             = "";

LET v_sec_ingreso        = "";
LET v_salario            = 0;
LET v_monto_adeudo		 = 0;
LET v_mto_adeudo_venc    = 0;

LET v_clave1		 	= "";
LET v_clave2		 	= "";
LET v_clave3			= "";
LET v_clave4		 	= "";
LET v_clave5         	= "";
LET v_cuantos_avisos	= 0;
LET v_nivel_eficiencia	= 0;


--SET DEBUG FILE TO "cobranza.out";
--TRACE ON;

BEGIN


  ----------------------CONTROLO LOS ERRORES------------------------------------------
  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret,'';
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

    --------------------------------------------------------
    --	1.--TIPO DE CLIENTE: (2 Numero)
    --------------------------------------------------------
	SELECT numcte,'01',
			CASE 
                WHEN ((a.status_cred in ('AA','E1')) and (b.mto_venc_trasp + b.monto_vencido <= 0)) THEN '0'
                WHEN ((a.status_cred in ('BA','E1')) and (b.mto_venc_trasp + b.monto_vencido > 0)) THEN '1'
                WHEN ((a.status_cred in ('BT','E2','E3')) and (b.mto_venc_trasp + b.monto_vencido > 0)) THEN '2'
                ELSE '0'
           END
		INTO   v_numcte,v_tp_cliente,v_avisos
	FROM   bdicred:sd_maecred a
    inner join bdicred:sd_maesdos b ON (a.num_credito = b.num_credito)
		WHERE a.num_credito = pnum_credito
		AND a.empresa = pempresa;

  	IF LENGTH(TRIM(v_tp_cliente)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "206";
  		END IF
  	END IF
    --------------------------------------------------------
    --	2.--SITUACION ESPECIAL: (1 letra)
    --------------------------------------------------------
	LET v_situacion = " ";
    --------------------------------------------------------
    --3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Año Nacimiento (2 Numeros)
    --------------------------------------------------------
	SELECT 	TRIM(NVL(estado_civil,'')),
			--TRIM(NVL(SUBSTR(habita_en, 2,1),'1')), --usado hasta antes de paso2 de alta unica, catalogo con valores 01, 02, etc
            nvl(substr(TRIM(habita_en),1,1), 'P'),  --Cambio a catalgo, ahora usa letras, paso 02 alta unica, default propia
		  	TRIM(NVL(sexo,'')),
		  	NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	INTO 	v_estado_civil,
			v_tp_casa,
			v_sexo,
			v_nacimiento
    FROM   bdinteg:si_ctepf
	WHERE  numcte = v_numcte;

  	IF LENGTH(TRIM(v_estado_civil)) <> 1 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "207	";
  		END IF
  	END IF

  	IF LENGTH(TRIM(v_tp_casa)) <> 1 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "208";
  		END IF
  	END IF

  	IF LENGTH(TRIM(v_sexo)) <> 1 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "209";
  		END IF
  	END IF

  	IF LENGTH(TRIM(v_nacimiento)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "210";
		END IF
  	END IF
    --------------------------------------------------------
    --6.--SALARIO (2 NUMEROS):
    --------------------------------------------------------
    SELECT NVL(ingreso_mensual,0) / (SELECT valor FROM bdisolic:ss_param where secuencia = 303)
		INTO   v_salario
	FROM   bdisolic:ss_resum_scor_fin
		WHERE  empresa = pempresa
		AND num_solicitud = pnum_credito ;

	IF v_salario <= 0  OR v_salario IS NULL THEN
  		IF cod_ret = "000" THEN
	  		LET cod_ret = "211";
	  	END IF
	ELSE
        IF v_salario >= 20 THEN
            LET v_cantidad = LPAD(20,2,'0');
		ELSE
			LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
		END IF
	END IF
    --------------------------------------------------------
    --7.-ANTIGUEDAD: (2 NUMEROS)
    --------------------------------------------------------
	SELECT NVL(SUBSTR(YEAR(fecha_alta), 3, 2),'')
		INTO   v_antiguedad
	FROM   bdinteg:si_cliente
		WHERE  numcte = v_numcte;

  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "212";
  		END IF
  	END IF
    --------------------------------------------------------
    --9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)
    --------------------------------------------------------
	SELECT NVL(sdo_cap_insoluto,0),NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)
		INTO   v_monto_adeudo,v_mto_adeudo_venc
	FROM   bdicred:sd_maesdoshist
		WHERE  fecha = v_fechahoy
		AND empresa = pempresa
		AND num_credito = pnum_credito;

	IF v_monto_adeudo >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "213";
  		END IF
	ELSE
		IF v_monto_adeudo < 0 THEN
			LET v_mto_tot_adeudo = LPAD(0,5,'0');
		ELSE
			LET v_mto_tot_adeudo = LPAD(v_monto_adeudo::INTEGER::VARCHAR(5),5,'0');
		END IF

	END IF
    --------------------------------------------------------
    --10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)
    --------------------------------------------------------
	IF v_mto_adeudo_venc >= 100000 THEN
  		IF cod_ret = "000" THEN
  			LET cod_ret = "214";
  		END IF
	ELSE
		LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF
    --------------------------------------------------------
    --11.-FECHA DE ULT. PAGO: (4 NUMEROS)
    --------------------------------------------------------
	SELECT MONTH(MAX(fecha_mov)) , SUBSTR(YEAR(MAX(fecha_mov)),3,2)
	INTO v_fec_ult_pago_month,v_fec_ult_pago_year
	FROM sd_movhisedocta
	WHERE empresa = pempresa
		AND num_credito = pnum_credito
		AND codigo_fun IN ('033','334')
		AND codigo_ref = 1
      	AND reversado <> "S";


	IF v_fec_ult_pago_month IS NULL OR v_fec_ult_pago_year IS NULL THEN
		LET v_fec_ult_pago = "NDND";
	ELSE
		LET v_fec_ult_pago = LPAD(NVL(TRIM(v_fec_ult_pago_month),0),2,'0') ||
							 LPAD(NVL(TRIM(v_fec_ult_pago_year),0),2,'0');
	END IF


    --------------------------------------------------------
    --12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)
    --------------------------------------------------------
	LET v_monto_ult_convenio =  LPAD("0",5,'0');
    --------------------------------------------------------
    --13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)
    --------------------------------------------------------
	LET v_fecha_ult_convenio =  "NDND";
    --------------------------------------------------------
    --14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)
    --------------------------------------------------------
	LET v_est_cumpl_convenio =  "-";
    --------------------------------------------------------
    --15.-NUMERO DE AVISOS: (1 LETRA)
    --------------------------------------------------------

	LET v_avisos = 0;

	SELECT COUNT(*)
		INTO v_cuantos_avisos
	FROM sd_amortiza_credito
		WHERE empresa = pempresa
		AND num_credito = pnum_credito
		AND	capital_status IN ('2','7','6');

	IF v_cuantos_avisos = 1 THEN
		LET v_avisos =  "1";
	ELIF v_cuantos_avisos = 2 THEN
		LET v_avisos =  "2";
	ELIF v_cuantos_avisos = 3 OR v_cuantos_avisos = 4 THEN
		LET v_avisos =  "3";
	ELIF v_cuantos_avisos >= 5 THEN
		LET v_avisos =  "4";
	END IF;

	if v_cuantos_avisos = 0 or v_cuantos_avisos = 1 or v_cuantos_avisos = 2 then
		let v_nivel_eficiencia = "01";
        elif v_cuantos_avisos = 3 then
		let v_nivel_eficiencia = "02";
	elif v_cuantos_avisos = 4 then
		let v_nivel_eficiencia = "03";
        elif v_cuantos_avisos = 5 or v_cuantos_avisos = 6 then
		let v_nivel_eficiencia = "04";
	elif v_cuantos_avisos > 6 then
		let v_nivel_eficiencia = "05";
	end if;



    --------------------------------------------------------
    --	ARMO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	LET v_clave1 = v_nivel_eficiencia 	||"/"|| v_situacion	||"/"|| v_estado_civil;
	LET v_clave2 = v_tp_casa		||"/"|| v_sexo		||"/"|| v_cantidad;
	LET v_clave3 = v_antiguedad		||"/"|| v_nacimiento ||"/"|| v_mto_tot_adeudo;
	LET v_clave4 = v_adeudo_vencido	||"/"|| v_fec_ult_pago||"/"||v_monto_ult_convenio;
	LET v_clave5 = v_fecha_ult_convenio||"/"|| v_est_cumpl_convenio||"/"||v_avisos  ;

	LET v_cl_cobranza = v_clave1 || "/" || v_clave2 || "/" || v_clave3 || "/" || v_clave4 || "/" || v_clave5;
    --------------------------------------------------------
    --	GENERO LA CLAVE DE COBRANZA:
    --------------------------------------------------------
	IF TRIM(v_cl_cobranza) = "" OR v_cl_cobranza IS NULL THEN
  		IF cod_ret = "000" THEN
	    	LET cod_ret = "215";
	    END IF
	END IF
END
RETURN cod_ret,v_cl_cobranza;
END PROCEDURE DOCUMENT "Version 1.00.000";

create procedure "informix".cons_cred_bpi_app(pempresa char(3),
                                     pnum_cte char(20),
                                     pmoneda char(2))
   returning char(5),char(20),char(20), char(2),char(20),char(1),char(40),char(1);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define sql_err integer;
   define v_numcte,v_cuenta, v_numtarjeta char(20);
   define v_status_tar char(1);
   define v_status_cred char(2);
   define v_nombre_prod char(40);
   define v_secuencia integer;
   DEFINE vstatus_serv CHAR(1);
   define iCont		integer;

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   let cod_ret       = "000";
   let v_cuenta      = null;
   let v_numcte = " ";
   let v_numtarjeta = " ";
   let v_status_tar = ' ';
   let v_status_cred = " ";
   let v_nombre_prod = " ";
   LET vstatus_serv	= "";
   let iCont =0;
   
   -- *****************************************************************************************************        
   -- Obejtivo:            Consulta de Estados de Cuenta Electronicos
   -- Creado por:			Autor desconocido
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2014/03/24    
   -- Razón:				Se agrega parámetro de salida del status del servicio
   --						de emisión de estados de cuenta CFDI
   -- *****************************************************************************************************
   -- Obejtivo:            Mostrar mas de 1 tarjeta en bpi (VISA y PLATINO)
   -- Modificacion por:    Roberto Castro
   -- Ultima Modificacion: 2015/01/12    
   -- Razón:				Se agrega FOREACH para recorrer todas las posibles cuentas de credito de un cliente.
   --						
   -- *****************************************************************************************************

--set debug file to "/home/informix/bibiana/cons_cre_bpi.out";
--trace on;

LET v_numcte = pnum_cte;

begin
   on exception set sql_err
      if sql_err <> 0 then
            let cod_ret = sql_err;
            return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,vstatus_serv;
      end if
   end exception;


       SET ISOLATION DIRTY READ ;
       set lock mode to wait 3;
		--Se agrega FOREACH para consultar mas de 1 tarjeta de credito.
	   FOREACH
       SELECT mc.num_credito, 
              mc.status_cred, 
              tr.num_tarjeta, tr.status_tar, 
              TRIM(df.num_producto) || ' ' || TRIM(df.nombre_prod) AS nombre_prod
        into v_cuenta, 
             v_status_cred, 
             v_numtarjeta, 
             v_status_tar, 
             v_nombre_prod
       FROM bdicred:"informix".sd_maecred mc
       join bdicred:"informix".sd_tarjeta tr on (tr.empresa = pempresa and mc.num_credito = tr.num_credito and tipo_tarjeta = 'T' and mc.status_cred in ('AA','BA','BT','E1','E2','E3') and secuencia = (select max(secuencia) from bdicred:"informix".sd_tarjeta where empresa = pempresa and mc.num_credito = num_credito and tipo_tarjeta = 'T'))
       join bdicred:"informix".sd_definicion df on (df.num_producto = mc.num_producto)
       WHERE mc.numcte = pnum_cte
	   --Se busca para saber si tiene activo el servicio de estados de cuenta CFDI
	  SELECT status_serv_elec
	  INTO vstatus_serv
	  FROM bdiedoelec:"informix".edelec_alta_serv
	  WHERE cuenta = v_cuenta;
		
		LET iCont = iCont + 1;
		IF(iCont < 10 ) THEN
			return cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"") WITH RESUME;
		END IF;	
    END FOREACH;
    
	IF ( iCont = 0 ) THEN
        LET cod_ret = '101'; --- Cliente No tiene cuentas
        RETURN cod_ret,v_numcte, v_cuenta, v_status_cred, v_numtarjeta, v_status_tar,v_nombre_prod,NVL(vstatus_serv,"");
    END IF  

end
end procedure;