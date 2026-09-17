CREATE PROCEDURE "informix".tc_consulta_detalle_concilia 
		(
		pEmpresa CHAR(3), 
		pArchivo CHAR(12) 
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter 
		--	Consecutivo  1 caracter 
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5),					DATE,
					VARCHAR(20,0),		VARCHAR(4,0),				CHAR(4),
					CHAR(16),					CHAR(20),						VARCHAR(20),
					DECIMAL(14,2),		CHAR(2),						VARCHAR(40,0),
					VARCHAR(16,0),		SMALLINT,						VARCHAR(18,0),
					VARCHAR(15,0),		VARCHAR(20,0),			VARCHAR(23,0),
					VARCHAR(20,0),		VARCHAR(5,0),				CHAR(3),
					DECIMAL(14,2),		CHAR(14),						CHAR(10),
					CHAR(4),					DECIMAL(14,2),			CHAR(1),
					DATE;
	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------
	DEFINE v_fecha							DATE;
	DEFINE v_tp_movto						CHAR(1);
	DEFINE v_tran_central				VARCHAR(4,0);
	DEFINE v_tran_sucursal			CHAR(4);
	DEFINE v_folio_mov					CHAR(16);
	DEFINE v_cuenta							CHAR(20);
	DEFINE v_tran_secuencia			VARCHAR(20);
	DEFINE v_monto							DECIMAL(14,2);
	DEFINE v_moneda							CHAR(2);
	DEFINE v_referencia					VARCHAR(40,0);
	DEFINE v_folio_original			VARCHAR(16,0);
	DEFINE v_documento					SMALLINT;
	DEFINE v_cod_autorizacion		VARCHAR(18,0);
	DEFINE v_campo_trabajo			VARCHAR(15,0);
	DEFINE v_rfc_comer					VARCHAR(20,0);
	DEFINE v_referencia23				VARCHAR(23,0);
	DEFINE v_bandera_proceso		CHAR(1);
	DEFINE v_cod_retorno				VARCHAR(5,0);
	DEFINE v_divisa							CHAR(3);
	DEFINE v_monto_divisa				DECIMAL(14,2);
	DEFINE v_num_cajero					CHAR(14);
	DEFINE v_convenio						CHAR(10);
	DEFINE v_tipo_tran_emp			CHAR(4);
	DEFINE v_monto_com_emp			DECIMAL(14,2);
	DEFINE v_forma_pago					CHAR(1);
	DEFINE v_fecha_aplica				DATE;
	
	
	DEFINE v_tipo_movimiento		VARCHAR(20,0);
	DEFINE v_status							VARCHAR(20,0);
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	DEFINE vArchivo  	VARCHAR(3);
	DEFINE vTabla  	 	VARCHAR(30);
	DEFINE vTipo		CHAR(1);	
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------
	LET v_fecha								= " ";
	LET v_tp_movto						=	"";
	LET v_tran_central				=	"";
	LET v_tran_sucursal				=	"";
	LET v_folio_mov						=	"";
	LET v_cuenta							=	"";
	LET v_tran_secuencia			=	"";
	LET v_monto								= 0;
	LET v_moneda							=	"";
	LET v_referencia					=	"";
	LET v_folio_original			=	"";
	LET v_documento						= 0;
	LET v_cod_autorizacion		=	"";
	LET v_campo_trabajo				=	"";
	LET v_rfc_comer						=	"";
	LET v_referencia23				=	"";
	LET v_bandera_proceso			=	"";
	LET v_cod_retorno					=	"";
	LET v_divisa							=	"";
	LET v_monto_divisa				= 0;
	LET v_num_cajero					=	"";
	LET v_convenio						=	"";
	LET v_tipo_tran_emp				=	"";
	LET v_monto_com_emp				= 0;
	LET v_forma_pago					=	"";
	LET v_fecha_aplica				= " ";

	LET v_tipo_movimiento			= "";
	LET v_status							= "";	
	
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	LET vArchivo  	= "";
	LET vTabla  	= "";
	LET vTipo		= "";	
BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN 	cod_ret,		" ",
      				"",		"",		"",
      				"",		"",		"",
      				0 , 	"",		"",
      				"", 	0 ,		"",
      				"",		"",		"",
      				"",		"",		"",
      				0 ,		"",		"",
      				"",		0 ,		"",
      				" ";
	   END EXCEPTION;

 --SET DEBUG FILE TO "tc_aplica_concilia.out";
 --TRACE ON;

  SET LOCK MODE TO WAIT 4;
  set isolation to dirty read;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo tipo de conciliacion
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	LET vArchivo =	SUBSTR(pArchivo,1,3);
	SELECT archivo,tabla,tipo  INTO vArchivo,vTabla,vTipo
	FROM td_archivos 
	WHERE empresa =  pEmpresa
	AND archivo = vArchivo;
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- No se encuentra definicion para el archivo proporcionado
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vTabla IS NULL OR vTabla = "" THEN
		RETURN 	'001',												NVL(v_fecha,""),
						NVL(v_tipo_movimiento,""),		NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
						NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
						NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
						NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
						NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
						NVL(v_status,""),							NVL(v_cod_retorno,""),						NVL(v_divisa,""),
						NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
						NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
						NVL(v_fecha_aplica," ");
 	END IF

	--------------------------------------------------------
	--	POS
	--------------------------------------------------------
	-- PAGOS NACIONALES INTERBANCARIOS
	IF vTabla = "td_conpospnc" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conpospnc
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),		NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),							NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;


		END FOREACH;

	-- VENTAS NACIONALES CREDITO
	ELIF  vTabla = "td_conposvnc" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conposvnc
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),		NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),							NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;

		END FOREACH;

	-- VENTAS NACIONALES DEBITO
	ELIF  vTabla = "td_conposvnd" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conposvnd
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),						NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),		NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;

		END FOREACH;

	-- VENTAS INTERNACIONALES CREDITO
	ELIF  vTabla = "td_conposvic" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conposvic
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),						NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),		NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;

		END FOREACH;

	-- VENTAS INTERNACIONALES DEBITO
	ELIF  vTabla = "td_conposvid" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conposvid
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),						NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),		NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;

		END FOREACH;
	--------------------------------------------------------
	--	ATM
	--------------------------------------------------------
	-- RETIROS CREDITO
	ELIF  vTabla = "td_conatmc" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conatmc
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),						NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),		NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;

		END FOREACH;

	-- RETIROS DEBITO
	ELIF  vTabla = "td_conatmd" THEN
	
		FOREACH 
			SELECT 	fecha,
							tp_movto,						tran_central,						tran_sucursal,
							folio_mov,					cuenta,									tran_secuencia,
							monto,							moneda,									referencia,
							folio_original,			documento,							cod_autorizacion,
							campo_trabajo,			rfc_comer,							referencia23,
							bandera_proceso,		cod_retorno,						divisa,
							monto_divisa,				num_cajero,							convenio,
							tipo_tran_emp,			monto_com_emp,					forma_pago,
							fecha_aplica
			INTO 		v_fecha,
							v_tp_movto,						v_tran_central,						v_tran_sucursal,
							v_folio_mov,					v_cuenta,									v_tran_secuencia,
							v_monto,							v_moneda,									v_referencia,
							v_folio_original,			v_documento,							v_cod_autorizacion,
							v_campo_trabajo,			v_rfc_comer,							v_referencia23,
							v_bandera_proceso,		v_cod_retorno,						v_divisa,
							v_monto_divisa,				v_num_cajero,							v_convenio,
							v_tipo_tran_emp,			v_monto_com_emp,					v_forma_pago,
							v_fecha_aplica
			FROM  td_conatmd
			WHERE	empresa = pEmpresa AND archivo = pArchivo
			ORDER BY tp_movto,bandera_proceso
			
			 
			LET v_tipo_movimiento			= DECODE(v_tp_movto,'C','Cargo','A','Abono','R','Reversión','');
			LET v_status							= DECODE(v_bandera_proceso,'C','Conciliado','A','Aplicado','E','Error '||v_cod_retorno,'Sin Procesar');
			 
			RETURN 	cod_ret,											NVL(v_fecha,""),
							NVL(v_tipo_movimiento,""),						NVL(v_tran_central,""),						NVL(v_tran_sucursal,""),
							NVL(v_folio_mov,""),					NVL(v_cuenta,""),									NVL(v_tran_secuencia,""),
							NVL(v_monto,0),								NVL(v_moneda,""),									NVL(v_referencia,""),
							NVL(v_folio_original,""),			NVL(v_documento,0),								NVL(v_cod_autorizacion,""),
							NVL(v_campo_trabajo,""),			NVL(v_rfc_comer,""),							NVL(v_referencia23,""),
							NVL(v_status,""),		NVL(v_cod_retorno,""),						NVL(v_divisa,""),
							NVL(v_monto_divisa,0),				NVL(v_num_cajero,""),							NVL(v_convenio,""),
							NVL(v_tipo_tran_emp,""),			NVL(v_monto_com_emp,0),						NVL(v_forma_pago,""),
							NVL(v_fecha_aplica," ") WITH RESUME;


		END FOREACH;

	END IF



	

-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE
DOCUMENT
'ESTA FUNCION APLICA EL PROCESO DE CONCILIACION ',
'AUTOR : Cristian Campos Diaz ',
'FECHA : 29 Mayo 2008',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".sp_buscatemporal(pTabla Char(50))

RETURNING
          CHAR (5) ,   
	  CHAR(20) ,
          INTEGER  ;


--##############################################################################
--## Procedimiento       : sp_buscatemporal
--## Version             : 1.0.0
--## Objetivo            : Valida si existe una temporal
--## Base Datos          : bicheq
--## Supuestos           :
--## Valores Entrada     : pTabla -->   Nombre de la tabla
--## Valores Retorno     : CodRet -->   Código de Retorno.
--##                       Desc   -->   Descricpion del Error
--##                       Registros->  Cantidad de Registros
--## Creado por          : Alejandro Rueda Sanchez
--## Fecha creacion      : Enero de 2007
--##############################################################################


    DEFINE cod_ret                char(5);
    DEFINE iSqlErr                integer;

    DEFINE cCodErr                CHAR(5);
    DEFINE vDesErr                VARCHAR(60);

    --Variables de retorno
    DEFINE v_registros             INTEGER;

    ON EXCEPTION
        SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cod_ret = iSqlErr;
        END IF;
        RETURN cod_ret, vDesErr, NULL;

    END EXCEPTION;



    LET cod_ret = "000";
    LET vDesErr = "";
    LET v_registros = 0;

    --// ********************************************************************
    --// Obtiene Registros de la tabla 
    --// ********************************************************************

    IF pTabla = 'temp_sd_movhis' THEN --//Conciliacion de saldos.
       SELECT  count(*) INTO v_registros  FROM temp_sd_movhis;
    END IF
    IF pTabla = 'tempo_movhis' THEN --//Conciliacion de saldos.
       SELECT  count(*) INTO v_registros  FROM tempo_movhis;
    END IF

    RETURN cod_ret, vDesErr, v_registros;
END PROCEDURE DOCUMENT "Version: 1.00.000";

CREATE PROCEDURE "informix".tc_aplica_concilia
		(
		pEmpresa CHAR(3),
		pArchivo CHAR(12)
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter
		--	Consecutivo  1 caracter
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5);

	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------
	DEFINE vArchivo  	VARCHAR(3);
	DEFINE vTabla  	 	VARCHAR(30);
	DEFINE vTipo		CHAR(1);
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------
	LET vArchivo  	= "";
	LET vTabla  	= "";
	LET vTipo		= "";

BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

-- SET DEBUG FILE TO "/pisa/pisabanco/pisa_ftes/Tichan/conciliacion/logs/tc_aplica_concilia.out";
 --TRACE ON;

  SET LOCK MODE TO WAIT 10;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo tipo de conciliacion
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	LET vArchivo =	SUBSTR(pArchivo,1,3);

	SELECT archivo,tabla,tipo  INTO vArchivo,vTabla,vTipo
	FROM td_archivos
	WHERE empresa =  pEmpresa
	AND archivo = vArchivo;
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- No se encuentra definicion para el archivo proporcionado
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vTabla IS NULL OR vTabla = "" THEN
 		RETURN '001';
 	END IF

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Valida la Carga del Archivo
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	IF NOT EXISTS (SELECT * FROM td_conciliaarchivos WHERE archivo = pArchivo) THEN
 		RETURN '002';
	END IF
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Aplica la conciliacion
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- CONCILIACION CREDITO    ---- se comenta codigo para ejecion por fuera
	IF vTipo = "C" THEN
	  EXECUTE PROCEDURE tc_concilia_credito
   		 (
   		   pEmpresa,pArchivo
   		  )INTO cod_ret;
   	
--	 CONCILIACION DEBITO
	ELIF  vTipo = "D" THEN
	   EXECUTE PROCEDURE tc_concilia_debito
   		 (
   		   pEmpresa,pArchivo
   		  )INTO cod_ret;
	END IF


   RETURN cod_ret;

-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE
DOCUMENT
'ESTA FUNCION APLICA EL PROCESO DE CONCILIACION ',
'AUTOR : Cristian Campos Diaz ',
'FECHA : 29 Mayo 2008',
'BD : bdicred ',
'CLIENTE : COPPEL';

CREATE PROCEDURE "informix".sp_consulta_devoluciones_pos_detalle (psNomArchivo VARCHAR(23), pdtFecha DATE)

RETURNING  VARCHAR(16) AS NumTarjeta, VARCHAR(10) AS Fecha, VARCHAR(10) AS Tipo_Operacion, VARCHAR(60) AS Motivo, VARCHAR(60) AS NomComercio, VARCHAR(40) AS Referencia, MONEY AS Monto;

--****************************************************************************************************
-- DESCRIPCION: OBTIENE EL DETALLE DE LOS REGISTROS DE DEVOLUCIONES POS.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 02/09/2011
-- BD: BdiTarjeta
-- SISTEMA : Conciliacion Automatica -- DEVOLUCIONES
-- MODIFICADO : Casanova Edeza Hector Juan  2011/10/24 --SE CAMBIO EL ORIGEN DEL MONTO DEL REPORTE DE MONTOINTERCARD POR EL DE MONTOARCHIVO
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;

DEFINE vsNumTarjeta VARCHAR(16);
DEFINE vsNomComercio VARCHAR(30);
DEFINE vsMotivo VARCHAR(60);
DEFINE vsReferencia VARCHAR(40);
DEFINE vmMonto MONEY;



/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;

LET vsNumTarjeta = '';
LET vsNomComercio = '';
LET vsReferencia = '';
LET vsMotivo = '';
LET vmMonto = 0.0;


BEGIN

ON EXCEPTION SET viSQLerr
	
	RETURN viSQLerr, '01/01/1900', '', '', '', '', 0.0;
	
END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	--OBTIENE LOS REGISTROS CORRESPONDIENTE AL FILTRO INDICADO
	--RETURN  
	FOREACH SELECT NumTarjeta, NomComercio, Motivo, Referencia, MontoArchivo
	INTO vsNumTarjeta, vsNomComercio, vsMotivo, vsReferencia, vmMonto 
	FROM BdiTarjeta:"informix".Td_DevolucionesPOS 
	WHERE NomArchivo = psNomArchivo
	AND Fecha = pdtFecha
		
		RETURN vsNumTarjeta, pdtFecha, 'ABONO', vsMotivo, vsNomComercio, vsReferencia, vmMonto WITH RESUME;
		
	END FOREACH;
	
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: DEVOLUCIONES POS',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE EL DETALLE DE LOS REGISTROS DE DEVOLUCIONES POS.',
'Fecha: 2011/09/02',
'Version: 20110902.0933',
'BD: BdiTarjeta',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: DEVOLUCIONES POS',
'Solicito: Jose Luis Puebla',
'Descripcion: SE CAMBIO EL ORIGEN DEL MONTO DEL REPORTE DE MONTOINTERCARD POR EL DE MONTOARCHIVO.',
'Fecha: 2011/10/24',
'Version: 20111024.1601',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_consulta_devoluciones_pos_general (pdtFecha DATE, piTipoConsulta INTEGER, psTipoArchivo VARCHAR(1))

RETURNING VARCHAR (23) AS Nombre, VARCHAR(10) AS Fecha, INTEGER AS Reg_Recibidos, INTEGER AS Reg_Conciliados, INTEGER AS Reg_Aplicados, INTEGER AS Reg_Error, INTEGER AS Reg_Faltantes;

--****************************************************************************************************
-- DESCRIPCION: OBTIENE LOS TOTALES CORRESPONDIENTES A LA CONSULTA DE DEVOLUCIONES POS.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 31/08/2011
-- BD: BdiTarjeta
-- SISTEMA : Conciliacion Automatica -- DEVOLUCIONES
-- MODIFICADO : Casanova Edeza Hector Juan  02/12/2011 --SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS DEACUERDO CON LAS MODIFICACIONES SOLICITADAS POR EL USUARIO
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viSQLerr INTEGER;


DEFINE vsNombre VARCHAR(23);
DEFINE vsFecha VARCHAR(10);
DEFINE viReg_Recibidos INTEGER;
DEFINE viReg_Conciliados INTEGER;
DEFINE viReg_Aplicados INTEGER;
DEFINE viReg_Error INTEGER;
DEFINE viReg_Faltantes INTEGER;


/* INICIALIZACION DE VARIABLES */
LET viSQLerr = 0;


LET vsNombre = '';
LET vsFecha = '';
LET viReg_Recibidos = 0;
LET viReg_Conciliados = 0;
LET viReg_Aplicados = 0;
LET viReg_Error = 0;
LET viReg_Faltantes = 0;


BEGIN

ON EXCEPTION SET viSQLerr
	
	RETURN viSQLerr, '01/01/1900', 0, 0, 0, 0, 0;
	
END EXCEPTION;
	
	--VALIDA KE LOS PARAMETROS SEAN VALIDOS
	IF ((psTipoArchivo IN ('C', 'D', 'T')) OR (piTipoConsulta BETWEEN 1 AND 4)) THEN 
	
		--1 - APLICADOS  (Aplicado = 'V')
		--2 - FORZADOS (Estado = 'F')
		--3 - NO APLICADOS (Aplicado = 'F')
		--4 - TODOS (COUNT(NomArchivo) > 0)
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--OBTIENE LOS REGISTROS CORRESPONDIENTE AL FILTRO INDICADO
		--RETURN  
		FOREACH 
		SELECT UNIQUE (NomArchivo), 
		COUNT(NomArchivo) AS Reg_Recibidos, 
		SUM(CASE WHEN ((Estado IN ('A', 'F')) AND (Aplicado IN ('F', 'E'))) THEN 1 ELSE 0 END) AS Reg_Conciliados, 
		SUM(CASE WHEN ((Estado IN ('A', 'F')) AND (Aplicado = 'V')) THEN 1 ELSE 0 END) AS Reg_Aplicados, 
		SUM(DECODE(Estado, 'P',1,0)) AS Reg_Error, 
		SUM(CASE WHEN (Aplicado IN ('F', 'E')) THEN 1 ELSE 0 END) AS Reg_Faltantes
		INTO vsNombre, 
		viReg_Recibidos, 
		viReg_Conciliados, 
		viReg_Aplicados, 
		viReg_Error, 
		viReg_Faltantes
		FROM BdiTarjeta:"informix".Td_DevolucionesPOS 
		WHERE Fecha = pdtFecha
		AND TipoArchivo <> (CASE WHEN (psTipoArchivo = 'C') THEN 'D' WHEN (psTipoArchivo = 'D') THEN 'C' ELSE psTipoArchivo END)
		GROUP BY NomArchivo
		HAVING
		SUM(DECODE(Estado, 'F',1,0)) > DECODE(piTipoConsulta, 2, 0, 999999999) -- FORZADOS --2
		OR SUM(CASE WHEN (Aplicado = 'V' AND piTipoConsulta = 1) THEN 1 -- APLICADOS  --1
			 WHEN (Aplicado = 'F' AND piTipoConsulta = 3) THEN 1 -- NO APLICADO  --3
			 ELSE 0 END) > 	DECODE(piTipoConsulta, 2, 999999999, 0)  -- 1 Y 3 PARA KE EL VALOR SEA 0
		OR COUNT(NomArchivo) > DECODE(piTipoConsulta, 4, 0, 999999999) -- TODOS --4
			
			RETURN vsNombre, pdtFecha, viReg_Recibidos, viReg_Conciliados, viReg_Aplicados, viReg_Error, viReg_Faltantes WITH RESUME;
			
		END FOREACH;
		
	END IF;
	
END;

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: DEVOLUCIONES POS',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE LOS TOTALES CORRESPONDIENTES A LA CONSULTA DE DEVOLUCIONES POS.',
'Fecha: 2011/08/31',
'Version: 20110831.1022',
'BD: BdiTarjeta',
'',
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica - DEVOLUCIONES',
'Solicito: Jose Luis Puebla',
'Descripcion: SE MODIFICA LA LOGICA PARA LA CLASIFICACION DE MOVIMIENTOS DEACUERDO CON LAS MODIFICACIONES SOLICITADAS POR EL USUARIO.',
'Fecha: 2011/12/01',
'Version: 20111201.1900',
'BD: Intercard';

CREATE PROCEDURE "informix".tc_sube_concilia 
		(
		pEmpresa CHAR(3), 
		pArchivo CHAR(12) 
		)
		--El Archivo se estructura de la siguiente manera
		--	Tipo Archivo 3 caracter 
		--	Consecutivo  1 caracter 
		--  Fecha 		 8 caracter MMDDYYYY
		--	Ejemplo:	 ATM106121981
RETURNING CHAR(5);

	-- *************************************************************************
	-- *                      DEFINICION DE VARIABLES                          *
	-- *************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	DEFINE cod_ret      CHAR(5);
	DEFINE sql_err      SMALLINT;
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------   
	DEFINE vFechaHoy	DATE;
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	DEFINE vArchivo  	VARCHAR(3);
	DEFINE vTabla  	 	VARCHAR(30);
	DEFINE vTipo		CHAR(1);
	--------------------------------------------------------
	--	Varibales de Control de Encabezado
	--------------------------------------------------------   
	DEFINE vSucursal 	VARCHAR(3);
	DEFINE vUsuario		VARCHAR(8);
	DEFINE vFecha		DATE;
	DEFINE vTotMovs		CHAR(16);
	DEFINE vTotCgo		CHAR(20);
	DEFINE vTotAbono	VARCHAR(20);
	DEFINE vTotRev		DECIMAL(14,2);
	DEFINE vBandera		CHAR(2);
	--------------------------------------------------------
	--	Variables de Control de Detalles
	--------------------------------------------------------   
	DEFINE vTotMovsDet	INTEGER;
	DEFINE vTotCgoDet	INTEGER;
	DEFINE vTotAbonoDet	INTEGER;
	DEFINE vTotRevDet	INTEGER;
  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************
	--------------------------------------------------------
	--	Variables de Control de Errores
	--------------------------------------------------------   
	LET cod_ret       = "000";
	LET sql_err       = "";
	--------------------------------------------------------
	--	Varibale de Control de Fecha Proceso
	--------------------------------------------------------   
	LET vFechaHoy	= " ";
	--------------------------------------------------------
	--	Varibales de Tipo de Conciliazion
	--------------------------------------------------------   
	LET vArchivo  	= "";
	LET vTabla  	= "";
	LET vTipo		= "";
	--------------------------------------------------------
	--	Varibales de Control de Encabezado
	--------------------------------------------------------   
	LET vSucursal 	= "";
	LET vUsuario	= "";
	LET vFecha		= " ";
	LET vTotMovs	= "";
	LET vTotCgo		= "";
	LET vTotAbono	= "";
	LET vTotRev		= 0;
	LET vBandera	= "";
	--------------------------------------------------------
	--	Variables de Control de Detalles
	--------------------------------------------------------   
	LET vTotMovsDet		= 0;
	LET vTotCgoDet		= 0;
	LET vTotAbonoDet	= 0;
	LET vTotRevDet		= 0;

BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;


--SET DEBUG FILE TO '/home/sysifx/conciliacion/TraceSUBECONCILIA.sql';
--TRACE ON ;
 
  SET LOCK MODE TO WAIT 10;
  SET ISOLATION TO DIRTY READ ;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************

	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo parametros
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT fecha_hoy::DATE 		INTO vFechaHoy
	FROM bdinteg:si_fechas WHERE empresa = pEmpresa;
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo tipo de conciliacion
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	LET vArchivo =	SUBSTR(pArchivo,1,3);
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT archivo,tabla,tipo  INTO vArchivo,vTabla,vTipo
	FROM BdiTarjeta:td_archivos 
	WHERE empresa =  pEmpresa
	AND archivo = vArchivo;
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- No se encuentra definicion para el archivo proporcionado
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vTabla IS NULL OR vTabla = "" THEN
 		RETURN '001';
 	END IF
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Validacion de encabezado
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT  tp_movto, 	tran_central, 	tran_sucursal::DATE, 
			folio_mov,  cuenta,	       	tran_secuencia, 
			monto, 		moneda
  	INTO 	vSucursal, 	vUsuario, 		vFecha, 
  			vTotMovs, 	vTotCgo, 		vTotAbono,
       		vTotRev, 	vBandera
  	FROM BdiTarjeta:td_pasoconcilia
 	WHERE filename = pArchivo AND tp_renglon = "E";
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- El Encabezado no Existe o esta corrupto
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vSucursal IS NULL OR vUsuario IS NULL  OR vFecha IS NULL  OR
 	   vTotMovs IS NULL OR vTotCgo IS NULL  OR vTotAbono IS NULL  OR
 	   vTotRev IS NULL OR vBandera IS NULL  OR vUsuario IS NULL  
 	THEN
 		RETURN '002';
 	END IF
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Validacion de Encabezado con detalle
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	SELECT COUNT(*),
		   SUM(CASE WHEN tp_movto   = 'C' THEN  1 ELSE 0 END),
		   SUM(CASE WHEN tp_movto   = 'A' THEN  1 ELSE 0 END),
		   SUM(CASE WHEN tp_movto   = 'R' THEN  1 ELSE 0 END)
	INTO   vTotMovsDet,vTotCgoDet,vTotAbonoDet,vTotRevDet
 	FROM BdiTarjeta:td_pasoconcilia
 	WHERE filename = pArchivo AND tp_renglon <> "E";
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- No coincide el encabezado con el detalle
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 	IF vTotMovs::INTEGER <> vTotMovsDet OR vTotCgo::INTEGER <> vTotCgoDet OR
 	   vTotAbono::INTEGER <> vTotAbonoDet OR vTotRev::INTEGER <> vTotRevDet THEN
 		RETURN '003';
 	 END IF
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserta Registro de Control de Carga
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	INSERT INTO BdiTarjeta:td_conciliaarchivos
		(
		empresa, 			archivo, 			fecha, 		
		recibidos_total, 	recibidos_cargo,	recibidos_abono, 	
		recibidos_reversa, 	fecha_recepcion,	bandera_procesa,
	  	procesados,			cargo_concilia,		cargo_aplica,
	  	cargo_error,		abono_concilia,		abono_aplica,
	  	abono_error,		reversa_concilia,	reversa_aplica,
	  	reversa_error,		usuario,			sucursal,
	  	tipoarchivo
	  	)
	VALUES
	 	(
	 	pEmpresa, 			pArchivo, 			vFecha, 
	 	vTotMovs, 			vTotCgo, 			vTotAbono,
	  	vTotRev, 			vFechaHoy, 			"0",
	  	"0",				"0",				"0",
	  	"0",				"0",				"0",
	  	"0",				"0",				"0",
	  	"0",				vUsuario,			vSucursal,
	  	vArchivo
	  	);
	
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Inserta Movimiento a Conciliar
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	--------------------------------------------------------
	--	POS
	--------------------------------------------------------
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	-- PAGOS NACIONALES INTERBANCARIOS
	IF vTabla = "td_conpospnc" THEN
		INSERT INTO BdiTarjeta:td_conpospnc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
		
	-- VENTAS NACIONALES CREDITO
	ELIF  vTabla = "td_conposvnc" THEN
		INSERT INTO BdiTarjeta:td_conposvnc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		--AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
		/*
		---/// MODIFICACION TEMPORAL;
		INSERT INTO BdiTarjeta:td_conposvnc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
			cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
         */
		
	-- VENTAS NACIONALES DEBITO
	ELIF  vTabla = "td_conposvnd" THEN
		INSERT INTO BdiTarjeta:td_conposvnd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		--AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
		/*
		---/// MODIFICACION TEMPORAL;		
		INSERT INTO BdiTarjeta:td_conposvnd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
			cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0
		AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
        */
			

	-- VENTAS INTERNACIONALES CREDITO
	ELIF  vTabla = "td_conposvic" THEN
		INSERT INTO BdiTarjeta:td_conposvic
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		--AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
		
        /* 
		---/// MODIFICACION TEMPORAL;
		INSERT INTO BdiTarjeta:td_conposvic
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
			cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0
		AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
        */
				
	
	-- VENTAS INTERNACIONALES DEBITO
	ELIF  vTabla = "td_conposvid" THEN
        
        --//// SE AJUSTA TEMPORALMENTE PARA EXCUILR TODOS LAS DEVOLUCIONES DEL ARCHIVO VID
		INSERT INTO BdiTarjeta:td_conposvid
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
        --AND tran_central <> '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;

        /*
		--- /// MODIFICACION TEMPORAL
        INSERT INTO BdiTarjeta:td_conposvid
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso,
            cod_retorno
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			'E',
            '88888'
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0
        AND tran_central = '0813'; ---/// TEMPORAL PARA FILTRAR ABONOS;
        */
		
	--------------------------------------------------------
	--	ATM
	--------------------------------------------------------
	-- RETIROS CREDITO
	ELIF  vTabla = "td_conatmc" THEN
		INSERT INTO BdiTarjeta:td_conatmc
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;

	-- RETIROS DEBITO
	ELIF  vTabla = "td_conatmd" THEN
		INSERT INTO BdiTarjeta:td_conatmd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
 
			
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
		--MOVIMIENTOS CORRESPONSAL BCPLCCP
	ELIF  vTabla = "td_concorrp" THEN
		INSERT INTO BdiTarjeta:td_concorrp
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
 
			
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
		--MOVIMIENTOS CORRESPONSAL BCPLCCD
	ELIF  vTabla = "td_concorrd" THEN
		INSERT INTO BdiTarjeta:td_concorrd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
			
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
	ELIF  vTabla = "td_contpd" THEN
		INSERT INTO BdiTarjeta:td_contpd
			(
			empresa, 			archivo, 			fecha,
			consecutivo, 		tp_movto,		  	tran_central,
			tran_sucursal, 		folio_mov,		  	cuenta,
			tran_secuencia, 	monto, 				moneda,
			referencia, 		folio_original, 	documento,
			cod_autorizacion, 	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			bandera_proceso
			)
		SELECT 
			pEmpresa,			filename,			vFecha,
			0,					tp_movto, 			tran_central, 
			tran_sucursal, 		folio_mov,	       	cuenta, 
			tran_secuencia, 	monto, 				moneda, 
			referencia,     	folio_original, 	documento, 
			cod_autorizacion,	campo_trabajo, 		rfc_comer,
			referencia23,		divisa,				monto_divisa,
			num_cajero,			convenio,			tipo_tran_emp,
			monto_com_emp,		forma_pago,			0
		FROM BdiTarjeta:td_pasoconcilia 
		WHERE filename = pArchivo 
		AND tp_renglon <> "E" AND bandera_proceso = 0;
		
	END IF

	DELETE FROM BdiTarjeta:td_pasoconcilia 
	WHERE filename = pArchivo AND bandera_proceso = 0;


   RETURN cod_ret;

-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;
END PROCEDURE;