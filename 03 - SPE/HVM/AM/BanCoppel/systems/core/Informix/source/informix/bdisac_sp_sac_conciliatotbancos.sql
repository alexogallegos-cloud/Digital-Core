CREATE PROCEDURE "informix".sp_sac_conciliatotbancos(pfecha DATE)
	returning 	char(5)  	as CodRetorno,
				CHAR(90)	as mensaje,
				CHAR(15)		as banamex,
				CHAR(15)		as bancomer,
				CHAR(15)		as prosa,
				INTEGER		as totalbana,
				INTEGER		as totalbanc,
				INTEGER		as totalprosa,
				MONEY(14,2) as importebana,
				MONEY(14,2) as importebanc,
				MONEY(14,2) as importeprosa;
	
	--Elaboró: Alejandro Osuna Iza
	--Actividad: Genera la información para mostrar en el Reporte totalizado de los registros conciliados de Banamex, Bancomer y PROSA (todos los demás).
	--Solicito: Jorge Nuñez
	--Fecha: 22 de Marzo de 2010

	--Declaracion de variables
	
	DEFINE vCodRet 			CHAR(5);
	DEFINE cSqlErr			INTEGER;
	DEFINE vmensaje			CHAR(90);
	DEFINE vBancoBan		CHAR(15);
	DEFINE vBancoBanco		CHAR(15);
	DEFINE vBnacoProsa		CHAR(15);
	DEFINE itotalBan		integer;
	DEFINE itotalBanco		integer;
	DEFINE itotalProsa		integer;
	DEFINE importeBan		MONEY(14,2);
	DEFINE vimporteBanco	MONEY(14,2);
	DEFINE vimporteProsa	MONEY(14,2);
    	DEFINE vconsmovhis      CHAR(10);


	--inicializacion de variables
	LET vCodRet 			= '00000';
	LET cSqlErr				= 0;
	LET vmensaje			= '';
	LET vBancoBan			= '';
	LET vBancoBanco			= '';
	LET vBnacoProsa			= '';
	LET itotalBan			= 0;
	LET itotalBanco			= 0;
	LET itotalProsa			= 0;
	LET importeBan			= 0.00;
	LET vimporteBanco		= 0.00;
	LET vimporteProsa		= 0.00;

	--SET DEBUG FILE TO "/tmp/sp_sac_conciliatotbancos.out";
	--TRACE ON;

	BEGIN
		 ON EXCEPTION SET cSqlErr
	        IF cSqlerr <> 0 THEN
				LET vmensaje = 'Error de Informix';
	            Let vCodRet = cSqlErr;
				RETURN vCodRet,vmensaje,nvl(vBancoBan,0),nvl(vBancoBanco,0),nvl(vBnacoProsa,0),
						nvl(itotalBan,0),nvl(itotalBanco,0),nvl(itotalProsa,0),nvl(importeBan,0),
						nvl(vimporteBanco,0),nvl(vimporteProsa,0);
			END IF;
		END EXCEPTION;
		--Se validan los datos de entrada...
		IF (pfecha is null ) THEN
			Let vCodRet = '07001';  
			SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE cod_ret = vCodRet and modulo is not null;
			RETURN vCodRet,vmensaje,nvl(vBancoBan,0),nvl(vBancoBanco,0),nvl(vBnacoProsa,0),nvl(itotalBan,0),nvl(itotalBanco,0),
					nvl(itotalProsa,0),nvl(importeBan,0),nvl(vimporteBanco,0),nvl(vimporteProsa,0);
		END IF;
            SELECT valor
              INTO vconsmovhis
              FROM bdicheq:sc_param
             WHERE codparam = 'fechcon_movhis'
               AND  empresa = '001';


		--1.- El Sistema valida que existe el registro de algún Archivo de Bancos que coincide con la Fecha recibida como dato de entrada.
			--1.a.- El Sistema validó que no existe el registro de algún Archivo de Bancos que coincide con la Fecha recibida como dato de entrada.				
		IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos where fecha_archivo = pfecha) THEN
			--2.- El Sistema valida que el Archivo de Bancos obtenido tiene estatus de Transmitido.
			--2.a.- El Sistema validó que el Archivo obtenido no tiene estatus de Transmitido.
			IF EXISTS(SELECT conciliado FROM bdisac:sac_eglobal_archivos where fecha_archivo = pfecha and estatus = '1') THEN
                if pfecha >= vconsmovhis then
                    --se extraen los datos para banamex
                    SELECT Count(sac_det.cod_txn),sum(sac_det.importe_txn::integer)
                    INTO itotalBan,importeBan
                    FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis AS movhis
                    WHERE sac_det.fecha_archivo = pfecha
                    AND sac_det.folio_suc = movhis.folio_suc
                    AND sac_det.conciliado ='1'
                    AND codigo_registro = '1'
                    AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007') );

                    --se extraen los datos para bancomer
                    SELECT Count(sac_det.cod_txn),sum(sac_det.importe_txn::integer)
                    INTO itotalBanco,vimporteBanco
                    FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis AS movhis
                    WHERE sac_det.fecha_archivo = pfecha
                    AND sac_det.folio_suc = movhis.folio_suc
                    AND sac_det.conciliado ='1'
                    AND codigo_registro = '2'
                    AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007') );
                    --se extraen los datos para prosa
                    SELECT Count(sac_det.cod_txn),sum(sac_det.importe_txn::integer)
                    INTO itotalProsa,vimporteProsa
                    FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis AS movhis
                    WHERE sac_det.fecha_archivo = pfecha
                    AND sac_det.folio_suc = movhis.folio_suc
                    AND sac_det.conciliado ='1'
                    AND codigo_registro = '3'
                    AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007') );
                 else
                    --se extraen los datos para banamex
                    SELECT Count(sac_det.cod_txn),sum(sac_det.importe_txn::integer)
                    INTO itotalBan,importeBan
                    FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis_old AS movhis
                    WHERE sac_det.fecha_archivo = pfecha
                    AND sac_det.folio_suc = movhis.folio_suc
                    AND sac_det.conciliado ='1'
                    AND codigo_registro = '1'
                    AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007') );

                    --se extraen los datos para bancomer
                    SELECT Count(sac_det.cod_txn),sum(sac_det.importe_txn::integer)
                    INTO itotalBanco,vimporteBanco
                    FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis_old AS movhis
                    WHERE sac_det.fecha_archivo = pfecha
                    AND sac_det.folio_suc = movhis.folio_suc
                    AND sac_det.conciliado ='1'
                    AND codigo_registro = '2'
                    AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007') );
                    --se extraen los datos para prosa
                    SELECT Count(sac_det.cod_txn),sum(sac_det.importe_txn::integer)
                    INTO itotalProsa,vimporteProsa
                    FROM bdisac:sac_eglobal_detalle AS sac_det, bdicheq:sc_movhis_old AS movhis
                    WHERE sac_det.fecha_archivo = pfecha
                    AND sac_det.folio_suc = movhis.folio_suc
                    AND sac_det.conciliado ='1'
                    AND codigo_registro = '3'
                    AND movhis.Transacc IN (SELECT TRIM(NVL(Valor, '')) FROM BdiSac:Sac_Param WHERE Empresa = '001' AND Cod_Param IN ('33004', '33005', '33006', '33007') );
                 end if;
				LET vBancoBan = 'Banamex';
				LET vBancoBanco = 'Bancomer';
				LET vBnacoProsa = 'PROSA';
				
				LET vCodRet = '00000';
				SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE cod_ret = '00000' and modulo is not null;
				RETURN vCodRet,vmensaje,nvl(vBancoBan,0),nvl(vBancoBanco,0),nvl(vBnacoProsa,0),nvl(itotalBan,0),nvl(itotalBanco,0),	
						nvl(itotalProsa,0),nvl(importeBan,0),nvl(vimporteBanco,0),nvl(vimporteProsa,0);
			ELSE
				LET vCodRet = '07002';
				SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE cod_ret = vCodRet and modulo is not null;
				RETURN vCodRet,vmensaje,nvl(vBancoBan,0),nvl(vBancoBanco,0),nvl(vBnacoProsa,0),nvl(itotalBan,0),nvl(itotalBanco,0),
					nvl(itotalProsa,0),nvl(importeBan,0),nvl(vimporteBanco,0),nvl(vimporteProsa,0);
			END IF;
		ELSE
		
			LET vCodRet = '07000';
			SELECT {+INDEX (bdisac:sac_eglobal_mensajes_error idx_eg_mensajes)} TRIM(descripcion) INTO vmensaje FROM bdisac:sac_eglobal_mensajes_error WHERE cod_ret = vCodRet and modulo is not null;
			RETURN vCodRet,vmensaje,nvl(vBancoBan,0),nvl(vBancoBanco,0),nvl(vBnacoProsa,0),nvl(itotalBan,0),nvl(itotalBanco,0),
					nvl(itotalProsa,0),nvl(importeBan,0),nvl(vimporteBanco,0),nvl(vimporteProsa,0);
		END IF;
	END;		
END PROCEDURE
 DOCUMENT
'AUTOR: Alejandro Osuna Iza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Genera la información para mostrar en el Reporte totalizado de los registros conciliados de Banamex, Bancomer y PROSA (todos los demás).',
'Fecha: 2010/03/16',
'Version: 20100316.0953',
'BD: BdiSac',
'Modifico: Alejandro Osuna Iza',
'Proyecto: Pago interbancario de tarjetas de credito',
'Folio: 1113',
'Solicito: Jaime Gonzalez Prado',
'Descripcion: Se modifica variables para que no regresen valores nulos.',
'Fecha: 2010/04/07',
'Version: 20100407.1155',
'BD: BdiSac';

CREATE PROCEDURE "informix".sp_actualizadatosusrl 
		(statconn CHAR (1), agtranstcode CHAR(4), --	agt_cd CHAR (3), 
		rqst_dt CHAR(8), rqst_tm CHAR(6), 
		op_code CHAR(4), 
		--	prcs_msg CHAR(255), errprmfll_nm CHAR(255),
		prcs_dt CHAR(8), prcs_tm CHAR(6), 
		sesn_id CHAR(80), sesn_tmout CHAR(10), 
		usrinsrt CHAR(8))
		--	, fch_insert DATE)
		
returning CHAR (5);	--	, CHAR (200);
	--*******************************************************************--
	--**	Elaboró: F.R.G.                                            **--
	--**	Actividad: Actualiza tabla URSL con Id_sesion Conexion     **--
	--**	Solicito: Código Test                                      **--
	--**	Fecha: 09/11/10                                            **--
	--**    opcode_ds: Este SP hace una actualizacion a la tabla de      **--
	--**             loggeo bdisac:sac_bts_usrl para actualizar        **--
	--**             el valor del id de seion de loggeo de BCP a BTS.  **--
	--**             Si algún parámetro es incorrecto o no             **--
	--**             encontrado en la consulta, manda un código        **--
	--**             de error relacionado con la tabla                 **--
	--**             bdisac:sac_bts_catmensajes                        **--
        --**                                                               **--
	--*******************************************************************--

	DEFINE sql_err			INTEGER;
	DEFINE cod_err			CHAR(5);
	DEFINE descri                   CHAR(200);
	DEFINE deta_salida		CHAR(200);
	DEFINE err_param                CHAR(4);
	DEFINE param_nll		CHAR(5);
	DEFINE agtxcode                 CHAR(4);
	DEFINE msg_rqst			CHAR(4);
	DEFINE v_opcode                 CHAR(4);
	DEFINE ag_code                  CHAR(5);
	DEFINE agt_cd                   CHAR(3);
	DEFINE v_from                   CHAR(15);
	DEFINE v_to                     CHAR(15);
	DEFINE vt_from                  CHAR(5);
	DEFINE vt_to                    CHAR(5);
	DEFINE v_usrname                CHAR(15);
	DEFINE v_psswrd                 CHAR(15);
	DEFINE vt_usrname               CHAR(5);
	DEFINE vt_psswrd                CHAR(5);
		
	LET cod_err			= "00000";
	LET err_param			= "S999";
	LET param_nll			= "99999";
	LET descri                      = ' ';
	LET deta_salida			= ' ';
	LET agtxcode			= ' ';
	LET msg_rqst			= ' ';
	LET v_opcode                    = ' ';
	LET agt_cd                      = ' ';
	LET ag_code                     = 87005;
	LET v_from                      = ' '; 
	LET v_to                        = ' ';
	LET vt_from                     = 87000;
	LET vt_to                       = 87001;
	LET v_usrname                   = ' '; 
	LET v_psswrd                    = ' ';
	LET vt_usrname                  = 87003;
	LET vt_psswrd                   = 87004;
		
-----------------------------------------------------------------------------
--	SET DEBUG FILE TO "/ids10_1uc5/tmp/bts/sp_actualizadatosusrl.out";
--	TRACE ON;
-----------------------------------------------------------------------------


 BEGIN
  ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_err = sql_err;
            RETURN cod_err;	--	, deta_salida;
      END IF;
  END EXCEPTION;

	LET msg_rqst = agtranstcode;


    	IF statconn = ' '
    	   or agtranstcode = ' ' --	or agt_cd = ' ' 
    	   or rqst_dt = ' ' or rqst_tm = ' ' 
    	   or op_code = ' ' 
    	   or prcs_dt = ' ' 
    	   or prcs_tm = ' '
    	   or sesn_id = ' '
    	   or usrinsrt = ' ' 
    	       		
    	    THEN
        	LET cod_err = param_nll;      	
        
        RETURN cod_err;	--	, deta_salida;
    	END IF;

LET v_opcode = op_code;

SELECT opcode_sd, opcode_ds 
	into descri, deta_salida
	from bdisac:sac_bts_catmensajes
	where 
	agent_trans_type_code = msg_rqst and
	opcode = v_opcode;

SELECT valor
	INTO agt_cd
	FROM bdisac:sac_param 
	where cod_param = ag_code;

SELECT valor
	INTO v_from
	FROM bdisac:sac_param 
	where cod_param = vt_from;

SELECT valor
	INTO v_to
	FROM bdisac:sac_param 
	where cod_param = vt_to;

SELECT valor
	INTO v_usrname
	FROM bdisac:sac_param 
	where cod_param = vt_usrname;

SELECT valor
	INTO v_psswrd
	FROM bdisac:sac_param 
	where cod_param = vt_psswrd;


UPDATE BDISAC:sac_bts_usrl
	SET cnxn_status = statconn, agent_trans_type_code = agtranstcode, 
	    agent_cd = agt_cd, 
	    request_date = rqst_dt, request_time = rqst_tm, 
	    opcode = v_opcode, 
	    process_msg = descri, error_param_full_name = deta_salida, 
	    process_dt = prcs_dt, process_tm = prcs_tm, 
	    session_id = sesn_id, session_timeout = sesn_tmout, 
	    user_insert = usrinsrt, 
	    fecha_insert = TO_CHAR(CURRENT::DATE);
	    
UPDATE bdisac:sac_bts_encabezado
	SET session_id = sesn_id, 
	from = v_from, 
	to = v_to, 
	user_name = v_usrname, 
	user_pass = v_psswrd, 
	user_insert = usrinsrt, 
	fecha_insert = TO_CHAR(CURRENT::DATE);

    RETURN cod_err;	--	, deta_salida;
   END;
END PROCEDURE;