CREATE PROCEDURE "informix".tc_concilia_credito_especial (pEmpresa CHAR(03), pTransacc CHAR(04))
		--  Fecha 		 8 caracter MMDDYYYY
RETURNING CHAR(100);

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
	--	Varibale Proceso Conciliacion
	--------------------------------------------------------
	DEFINE v_cuenta				CHAR(20);
	DEFINE v_tarjeta				CHAR(20);
	DEFINE v_sucursal				CHAR(4);
	DEFINE v_usuario				CHAR(8);

	DEFINE v_tp_movto				CHAR(1);
	DEFINE v_tran_central			VARCHAR(4);
	DEFINE v_folio_mov			CHAR(16);
	DEFINE v_monto				DECIMAL(14,2);
	DEFINE v_monto2				DECIMAL(14,2);
	DEFINE v_retenido				DECIMAL(14,2);

	DEFINE v_moneda				CHAR(2);
	DEFINE v_referencia			VARCHAR	(40);
	DEFINE v_folio_original		VARCHAR	(16);
	DEFINE v_rfc_comer			VARCHAR	(20);
	DEFINE v_referencia23 		VARCHAR	(23);

	DEFINE v_archivo				VARCHAR(30);
	DEFINE v_consecutivo			INTEGER;
	DEFINE v_fecha				DATE;
	DEFINE v_tabla				VARCHAR	(40);


	DEFINE vBandera	      	CHAR(1);
	DEFINE v_NumTransacc	VARCHAR(4);
	DEFINE v_MontoConcilia	DECIMAL(14,2);
	DEFINE v_FormaAplica	CHAR(1);

	--------------------------------------------------------
	--	Variables ley de Transparencia
	--------------------------------------------------------

	DEFINE v_transparencia		VARCHAR(40);
	DEFINE v_divisa         	CHAR(3);
	DEFINE v_monto_divisa   	DECIMAL(12,2);
	DEFINE v_num_cajero     	CHAR(14);
	DEFINE v_forma_pago     	CHAR(1);
	DEFINE v_desc_forma_pago  VARCHAR(8);


	DEFINE v_codigo_fun				CHAR(3);
	DEFINE v_codigo_ref				INT;

  --//Variables para ubicar folio diferente transaccion en linea
    DEFINE vtamanio      SMALLINT;
    DEFINE vt_indicador  CHAR(1);
    DEFINE vt_newfolio   CHAR(16);
    DEFINE vt_folsucorig CHAR(16);
    DEFINE vg_estatus    VARCHAR(5);
    DEFINE v_MontoConcilia_sdofavor   DECIMAL(14,2);

    DEFINE vCantReg            INTEGER;
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
	--	Varibale Proceso Conciliacion
	--------------------------------------------------------
	LET v_cuenta		= "";
	LET v_sucursal		= "";
	LET v_usuario		= "";

	LET v_tp_movto		= "";
	LET v_tran_central	= "";
	LET v_folio_mov		= "";
	LET v_monto			= 0;
	LET v_monto2        = 0;

	LET v_moneda			= "";
	LET v_referencia		= "";
	LET v_folio_original	= "";
	LET v_rfc_comer			= "";
	LET v_referencia23 		= "";

	LET v_archivo		= "";
	LET v_consecutivo	= 0;
	LET v_fecha			= " ";
	LET v_tabla			= "";


	LET vBandera	    = "C";
	LET v_NumTransacc	= "";
	LET v_MontoConcilia	= 0;
	LET v_FormaAplica	= "";
	--------------------------------------------------------
	--	Variables ley de Transparencia
	--------------------------------------------------------

	LET v_transparencia 			 = "";
	LET v_divisa               = "";
	LET v_monto_divisa         = 0;
	LET v_num_cajero           = "";
	LET v_forma_pago           = "";
	LET v_desc_forma_pago      = "";

	LET v_codigo_fun				= "";
	LET v_codigo_ref				= 0;
    LET v_MontoConcilia_sdofavor	 = 0;
    let vCantReg = 0;
    

BEGIN


   -- *************************************************************************
   -- *                      CONTROL DE ERRORES                               *
   -- *************************************************************************
   ON EXCEPTION SET sql_err
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;

-- SET DEBUG FILE TO "tc_concilia_credito";
-- TRACE ON;

  SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- *                 	INICA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	-- Obtengo parametros
	--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	SELECT fecha_hoy 		INTO vFechaHoy
	FROM bdinteg:si_fechas WHERE empresa = pEmpresa;

	LET v_divisa               = "";
	LET v_monto_divisa         = 0;
	LET v_num_cajero           = "";
	LET v_forma_pago           = "";

	FOREACH WITH HOLD
        select num_credito, folio_suc, monto, num_tarjeta, referencia
          into v_cuenta, v_folio_mov, v_monto, v_tarjeta, v_referencia
          from bdicred:sd_carga_pos    
         where indicador = '0'
--           and num_credito = '600002921036'

           select num_tarjeta
             into v_tarjeta
             from bdicred:sd_tarjeta
            where empresa = pEmpresa
              and num_tarjeta[1,15] = v_tarjeta[1,15];

           select sdo_retenido
             into v_retenido
             from bdicred:Sd_maesdos
            where empresa = pEmpresa
              and num_credito = v_cuenta;


        begin work;
		
	   update bdicred:sd_carga_pos    
          set indicador = '1'
        where num_credito = v_cuenta
          and folio_suc = v_folio_mov
          and monto = v_monto
          and num_tarjeta[1,15] = v_tarjeta[1,15];

         let vCantReg = 0;
		 
         SELECT SUM(monto) 
		   INTO v_monto2
           FROM bdicred:sd_maeretenido
          WHERE empresa = pEmpresa
            AND num_credito = v_cuenta
            AND folio_suc = v_folio_mov
            and estatus = "P"
            AND transacc = pTransacc;
			
			IF v_monto2 IS NULL THEN
			   LET v_monto2 = 0;
            END IF;	
		 
         UPDATE bdicred:sd_maeretenido SET estatus = "L"
          WHERE empresa = pEmpresa
            AND num_credito = v_cuenta
            AND folio_suc = v_folio_mov
            and estatus = "P"
            AND transacc = pTransacc;
            
             LET vCantReg = DBINFO("sqlca.sqlerrd2");

             if ( vCantReg <= 0 ) then let v_retenido = 0; end if;
             let v_folio_mov = substr(v_folio_mov,1,9)||'2'||substr(v_folio_mov,11);

			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			-- Executa SPL de conciliacion de credito
			--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		  	EXECUTE PROCEDURE bdicred:conciliatc
                  (
                  	pEmpresa, 		v_tarjeta, 		'9290', 		'sysconau',
                   	'C',		pTransacc,  v_folio_mov,    	v_monto,
                   	'01',  		v_referencia,   '000000000000000', 	'A',
                   	'', 	'')
            INTO cod_ret, vBandera;

            if ( cod_ret <> '000') then
                rollback work;
                continue FOREACH;
--                RETURN cod_ret||" tarjeta: "||v_tarjeta||" monto: "||v_monto||" folio: "||v_folio_mov;
            End if;
            

            if ( v_retenido is null or v_retenido < 0) then let v_retenido = 0; end if;

            if ( v_retenido < v_monto ) then
               let v_monto = v_retenido;
            end if;

			IF vCantReg > 0 THEN -- SE VALIDA QUE SOLO ACTUALICE EL SALDO RETENIDO SI HAY RETENIDOS PENDIENTES PIQV
				update bdicred:Sd_maesdos set sdo_retenido = sdo_retenido - v_monto2
				 where empresa = pEmpresa
				   and num_credito = v_cuenta;
		    END IF;

      commit work;

	END FOREACH;

	LET cod_ret = "000";
	
	RETURN cod_ret;
-- ****************************************************************************
-- *                 FINALIZA PROGRAMA PRINCIPAL                              *
-- ****************************************************************************
END;

END PROCEDURE;