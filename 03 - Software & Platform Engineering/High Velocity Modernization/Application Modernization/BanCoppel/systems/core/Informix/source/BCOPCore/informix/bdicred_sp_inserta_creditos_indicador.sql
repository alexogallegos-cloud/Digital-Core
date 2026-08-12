create procedure "informix".sp_inserta_creditos_indicador(pempresa CHAR(3), pFechaI DATE ,pFechaF DATE ) 
       RETURNING char(6);

--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
--DEFINE	vIndicador		LIKE bdicred:sd_indicador_cred.row;
DEFINE	vCodFun         CHAR(3);
DEFINE	vCodRef         SMALLINT;
DEFINE	vPagoCliente	CHAR(1);

------------------------------------------------
DEFINE vlFecha	DATE; 
DEFINE	vlEmpresa	CHAR(3);
DEFINE	vlNumCredito	CHAR(20);
DEFINE	vlFechaApertura	DATE;


------------------------------------------------

--SET DEBUG FILE TO '/temp/sp_graba_indicador.out';
--TRACE ON;

    LET cCod_ret      = '000000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';
	LET vCodFun       = '';
	LET vCodRef       = '';
	LET vPagoCliente  = '';		  
    LET vlFecha = '05-21-2007';
	
	LET	vlEmpresa	='001';
	LET	vlNumCredito =	'';
	LET	vlFechaApertura	=DATE(1);
	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            RETURN cCod_ret;
        END EXCEPTION;
				
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		LET vlFecha =pFechaI;
		FOREACH WITH HOLD
		SELECT EMPRESA, NUM_CREDITO , fecha_apertura
		  INTO vlEmpresa, vlNumCredito, vlFechaApertura
		  FROM bdicred:sd_maecred
		  where empresa ='001'
		    and fecha_apertura >= vlFecha AND fecha_apertura <=pFechaF
			--and status_cred in ('BT','BA','AA')
			and status_cred in ('BT','BA','AA','E1','E2','E3')   --IFRS MACF
			and num_credito not in( select num_credito from bdicred:"informix".sd_indicador_cred) 
		
		BEGIN WORK;		    
		  INSERT INTO bdicred:"informix".sd_indicador_cred
		       (empresa,num_credito, fecha_alta)
            VALUES(vlempresa,vlNumCredito, vlFechaApertura);			
			--LET vlFecha =	vlFecha +1 UNITS DAY;
		  COMMIT WORK;	
		END FOREACH;
    RETURN cCod_ret;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se inserta o actualiza el indicador de CrÃ©dito',
'AUTOR : Faviola MartÃ­nez JuÃ¡rez',
'FECHA : 01/Agosto/2011',
'BD: BDICRED',
'VERSION:201108.1805';

CREATE PROCEDURE "informix".sp_liquida_pp(c_empresa CHAR(3),
                                          c_sucursal CHAR(4),
			                              c_usuario CHAR(8),
                                          c_num_credito CHAR(20),
                                          c_monto   DECIMAL(14,2))

RETURNING CHAR(5),CHAR(16)

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE GLOBAL g_dtFechaHoy           DATE           DEFAULT "";
DEFINE scod_ret             CHAR(5);
DEFINE vcod_ret             CHAR(5);
DEFINE smen_ret             CHAR(125);
DEFINE vsqlerr              INTEGER;
DEFINE v_folio              CHAR(16);
DEFINE v_val                DECIMAL(18,2);
DEFINE v_val1               CHAR(20);
DEFINE v_val2               CHAR(17);
DEFINE v_val3               DECIMAL(18,2);
DEFINE vIvaSuc              DECIMAL(9,6);
DEFINE vFecCuota            DATE;
DEFINE vFechaHoy            DATE;
DEFINE dAplicaReverso       INTEGER;
DEFINE dSeAplicoReverso     INTEGER;
DEFINE v_montopago          DECIMAL(14,2);
DEFINE v_pagominsal         DECIMAL(18,2);
DEFINE v_pagominamor        DECIMAL(18,2);
DEFINE v_cuentavenci        INTEGER;
DEFINE v_accesoriosa        DECIMAL(18,2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret              = "000";
LET vcod_ret              = "000";
LET vsqlerr               = 0;
LET vFechaHoy             = "";
LET v_folio               = "";
LET vFecCuota             = '';
LET smen_ret              = '';
LET dAplicaReverso        = 0;
LET dSeAplicoReverso      = 0;
LET v_val1                = '';
LET v_val2                = '';
LET v_val3                = 0;
LET v_montopago           = 0;
LET v_pagominsal          = 0;
LET v_pagominamor         = 0;
LET v_cuentavenci         = 0;
LET v_accesoriosa         = 0;
LET vIvaSuc               = 0;
LET g_dtFechaHoy          = DATE(1);

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      ROLLBACK WORK;
      LET scod_ret=vsqlerr;
      RETURN scod_ret,v_folio;
   END IF;
END EXCEPTION;

-- SET DEBUG FILE TO "/pisa/cas/sp_liquida_pp.out";
-- TRACE ON;

-- Valida los Nulos en los Parametros de Entrada
IF c_empresa = "" OR c_sucursal = "" OR c_usuario = "" OR
   c_num_credito = "" OR c_monto = "" THEN
   LET scod_ret = "110";
   RETURN scod_ret,v_folio;
END IF;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

    SELECT valor::decimal(9,6)
      INTO vIvaSuc
      FROM bdinteg:si_param 
     WHERE cod_param=47;

     IF vIvaSuc IS NULL THEN
       LET scod_ret = "110";
       RETURN scod_ret,v_folio;
     END IF;

  SELECT fecha_hoy
    INTO vFechaHoy
    FROM sd_fechas
   WHERE empresa=c_empresa;
  LET g_dtFechaHoy=vFechaHoy;

  LET v_folio = "SIFPP"||SUBSTR(CURRENT HOUR TO FRACTION(2),1,2) ||
      SUBSTR(CURRENT HOUR TO FRACTION(2),4,2) ||
      SUBSTR(CURRENT HOUR TO FRACTION(2),7,2);

    SELECT nvl(monto_financiado,0)
      INTO v_pagominsal
      FROM bdicred:sd_maesdoscrd
     WHERE empresa=c_empresa
       AND num_credito=c_num_credito;

    SELECT sum(capital_debe-capital_pagado),
           sum(interes_debe - interes_pagado + iva_debe - iva_pagado + mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)+
           (sum(mora_sdo_ordi - mora_sdo_ordi_pag + mora_sdo_cope - mora_sdo_cope_pag)* vIvaSuc),
           count(*)
      INTO v_pagominamor,v_accesoriosa,v_cuentavenci
      FROM bdicred:sd_amortiza_creditocrd
     WHERE empresa=c_empresa
       AND num_credito=c_num_credito
       AND capital_status IN ('1','2','7','6');

    IF v_pagominsal IS NULL THEN LET v_pagominsal=0; END IF;
    IF v_pagominamor IS NULL THEN LET v_pagominamor=0; END IF;
    IF v_accesoriosa IS NULL THEN LET v_accesoriosa=0; END IF;
    IF v_cuentavenci IS NULL THEN LET v_cuentavenci=0; END IF;

    IF v_pagominsal <> v_pagominamor THEN ---Validació® °ara detectar si el credito esta descuadrado
       LET scod_ret="111";
       RETURN scod_ret,v_folio;
    END IF;

    LET v_pagominsal = v_pagominsal + v_accesoriosa;

  IF c_monto > 0  AND v_cuentavenci = 0 THEN
      EXECUTE PROCEDURE "informix".sp_pago_anticipado_pp(c_empresa,c_num_credito,c_usuario,c_sucursal,v_folio,'7469',c_monto,'1')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6300'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;

       Insert into "informix".sd_log_cobroaut
       (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
       values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

        RETURN scod_ret,v_folio;
      ELSE
          -- Por si tiene que hacer algo
         LET c_monto = 0;
         LET scod_ret='000';
      END IF;
   ELIF c_monto > 0 AND v_cuentavenci > 0 AND v_pagominsal > 0 AND c_monto <= v_pagominsal  THEN
      EXECUTE PROCEDURE "informix".sp_principal_pp(c_empresa,c_num_credito,1,c_monto,c_usuario,c_sucursal,v_folio,'7506')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6300'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;

       Insert into "informix".sd_log_cobroaut
       (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
       values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

          RETURN scod_ret,v_folio;
      ELSE
          -- Por si tiene que hacer algo
         LET c_monto = 0;
         LET scod_ret='000';
      END IF;
   ELIF c_monto > 0 AND v_cuentavenci > 0 AND v_pagominsal > 0 AND c_monto > v_pagominsal THEN

      LET v_montopago = c_monto - v_pagominsal;

      EXECUTE PROCEDURE "informix".sp_principal_pp(c_empresa,c_num_credito,1,v_pagominsal,c_usuario,c_sucursal,v_folio,'7506')
      INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;
      IF scod_ret <> "00000" THEN
           select aplica_reverso
             into dAplicaReverso
             from sd_reversa_error
             where num_producto='6300'
               and codigo=scod_ret;

            IF dAplicaReverso>0 THEN
               EXECUTE PROCEDURE bdicheq:reversion (c_empresa,c_sucursal,c_usuario, v_folio,"A")
               INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;
            END IF;

       Insert into "informix".sd_log_cobroaut
       (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
       values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

          RETURN scod_ret,v_folio;

      ELSE

        SELECT COUNT(*)
          INTO v_cuentavenci
          FROM bdicred:sd_amortiza_creditocrd
         WHERE empresa=c_empresa
           AND num_credito=c_num_credito
           AND capital_status IN ('1','2','7','6');

           IF v_cuentavenci > 0  and c_monto > 0 THEN

              LET scod_ret='112';

              Insert into "informix".sd_log_cobroaut
              (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
              values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

              RETURN scod_ret,v_folio;

           END IF;

          EXECUTE PROCEDURE "informix".sp_pago_anticipado_pp(c_empresa,c_num_credito,c_usuario,c_sucursal,v_folio,'7469',v_montopago,'0')
          INTO scod_ret,smen_ret,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val,v_val3,v_val1,v_val,v_val,v_val2;

          IF scod_ret <> "00000" THEN
            EXECUTE PROCEDURE "informix".reversioncrd(c_empresa,c_sucursal,c_usuario,v_folio,"A")
            INTO vcod_ret;
               IF vcod_ret<>"000" THEN
                  LET dSeAplicoReverso = 0;
               ELSE
                  LET dSeAplicoReverso = 1;
               END IF;

              Insert into "informix".sd_log_cobroaut
              (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
              values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

              RETURN scod_ret,v_folio;
          END IF;
          -- Por si tiene que hacer algo
         LET c_monto = 0;
         LET scod_ret='000';
      END IF;
   END IF;

   Insert into "informix".sd_log_cobroaut
   (sistema,proceso,fecha_proceso,hora_proceso,usuario_proceso,num_credito,cuenta,reverso_cap,folio,monto,codretcred,codretcheq,descripcion)
   values ('06','CobroAnSIF',vFechaHoy,current,c_usuario,c_num_credito,v_val1,dSeAplicoReverso,v_folio,v_val3,scod_ret,vcod_ret,v_val2);

END
   RETURN scod_ret,v_folio;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_mantto_relcteemp(pempresa CHAR(3),pproducto CHAR(4),popcion CHAR(1))
RETURNING CHAR(5) AS cod_ret,VARCHAR(80) AS mens_ret,VARCHAR(80) AS mens_ctrl;

--*****************************************************
-- DECLARACION DE VARIABLES
--*****************************************************
DEFINE iSqlErr		INTEGER;
DEFINE iIsamErr		INTEGER;
DEFINE cErrorInfo	CHAR(80);
DEFINE cCodRet		CHAR(5);
DEFINE cMensaje		CHAR(80);
DEFINE cMensajeCtrl	CHAR(80);
DEFINE cStatus_emp	CHAR(1);

DEFINE v_numcte_banco	CHAR(20);
DEFINE v_num_empleado	CHAR(10);
DEFINE v_fecha_hoy		DATE;
DEFINE iContInacNoExis	INTEGER;
DEFINE iContInacExis	INTEGER;
DEFINE iContInexis		INTEGER;
DEFINE v_valor			DECIMAL (10,2);
DEFINE v_num_credito	CHAR(20);
DEFINE dTasa_Interes	DECIMAL(9,6);		--	RQM 10 1224
DEFINE dTasa_Int_Aux	DECIMAL(9,6);		
DEFINE dTasa_Mora       DECIMAL(9,6);	
DEFINE cCodRetTDif		CHAR(6);

--*****************************************************
--- Inicializar variables
--*****************************************************
LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "00000";
LET cMensaje           	  = "";
LET cMensajeCtrl       	  = "Validar";

LET v_numcte_banco = '';
LET v_num_empleado = '';
LET cStatus_emp = '';
LET v_fecha_hoy = '';
LET iContInacNoExis = 0;
LET iContInacExis = 0;
LET iContInexis = 0;
LET v_valor = 0;
LET v_num_credito = '';
LET dTasa_Interes = 0;						--	RQM 10 1224
LET dTasa_Int_Aux = 0;	
LET dTasa_Mora    = 0;
LET cCodRetTDif	  = '';



BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET cCodRet     = iSqlErr;
			LET cMensaje = cErrorInfo;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/aplicacion/ifxsif01/Control-M/sp_mantto_relcteemp.out";
	--TRACE ON;

	set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	--- Se validan los parametros de entrada con los cuales se ejecuta en SP
	--- Se valida parametro de EMPRESA	
	IF pempresa IS NULL OR pempresa = '' THEN
		LET cCodRet = '00001'; LET cMensaje = 'Parametro -EMPRESA- incorrecto';
	
	--- Se valida parametro de NUMERO CREDITO
	ELIF pproducto IS NULL OR pproducto = '' THEN
		LET cCodRet = '00002'; LET cMensaje = 'Parametro -PRODUCTO- incorrecto';
	
	--- Se valida parametro de NUMERO CREDITO
	ELIF popcion NOT IN ('2') THEN
		LET cCodRet = '00003'; LET cMensaje = 'Parametro -OPCION- incorrecto';
	
	--- Opciones correctas o con valores permitidos
	ELSE
		
		SELECT fecha_hoy
		INTO v_fecha_hoy
		FROM bdicred:"informix".sd_fechas
		WHERE empresa = pempresa;				

		SELECT b.valor
		INTO dTasa_Int_Aux
		FROM bdicred:"informix".sd_definicion a, bdinteg:"informix".si_fechavalor b
		WHERE --a.empresa = pempresa AND
		      a.num_producto = pproducto
		  AND b.empresa = pempresa  	  
		  AND b.tasa = a.cod_tasa_base
		  AND b.fecha = (SELECT MAX(r.fecha) FROM bdinteg:si_fechavalor r
						WHERE r.empresa = pempresa
						AND r.tasa = a.cod_tasa_base);

		
		FOREACH

			SELECT numcte_banco, num_empleado 
			INTO v_numcte_banco, v_num_empleado
			FROM bdinteg:"informix".si_baja_rel_cte_emp
			WHERE fecha_registro = 	v_fecha_hoy
			
			FOREACH
					
				--- Se actualiza (INACTIVA)la relación cliente-empleado	
				EXECUTE PROCEDURE bdicred:"informix".inserta_rel_cte_emp(pempresa,v_numcte_banco,v_num_empleado, popcion, 'BAJA EMPLEADO', '', '', '', '')
				INTO cCodRet,cStatus_emp,cMensaje
				
				IF cCodRet = '00000' THEN
					LET iContInacNoExis = iContInacNoExis + 1;

					---Se actualiza la tasa de interes del crédito, de tasa preferencial a tasa base, de acuerdo al producto
					SELECT first 1 num_credito INTO v_num_credito FROM bdicred:"informix".sd_maecred WHERE numcte = v_numcte_banco AND num_producto = pproducto AND status_cred in ('AA','BA','BT','E1','E2','E3');
						
					EXECUTE PROCEDURE bdicred:"informix".sp_obtiene_tasa_int_diferenciadas(pempresa, v_num_credito, pproducto) INTO cCodRetTDif, dTasa_Interes, dTasa_Mora;
					IF cCodRetTDif <> '000000' OR NVL(dTasa_Interes,0) = 0 THEN
						LET v_valor = dTasa_Int_Aux;
					ELSE
						LET v_valor = dTasa_Interes;
					END IF;
						
					UPDATE bdicred:"informix".sd_maecred  
					SET tasa_interes = v_valor  
					where empresa = pempresa and numcte = v_numcte_banco and num_producto = pproducto;
						
					--EXECUTE PROCEDURE bdicred:sp_registra_crecta_cobroaut(pempresa,v_num_credito,'','0',popcion)
					--INTO cCodRet,cMensaje;
						
				ELIF cCodRet  = '00006' THEN
					LET iContInacExis = iContInacExis + 1; 
	
				ELIF cCodRet = '00007' THEN
					LET iContInexis = iContInexis + 1; 
				END IF
			END FOREACH
			
		END FOREACH
		
		LET cCodRet = '00000'; LET cMensaje = "Se realizo el proceso correctamente";	
		LET cMensajeCtrl = 'Actualizados : '||cast(iContInacNoExis as char(6))||', No Actualizados : '||cast(iContInacExis as char(6))||', No Existentes : '||cast(iContInexis as char(6))||'';
			   
	END IF

	RETURN cCodRet,cMensaje,cMensajeCtrl;
END
END PROCEDURE;