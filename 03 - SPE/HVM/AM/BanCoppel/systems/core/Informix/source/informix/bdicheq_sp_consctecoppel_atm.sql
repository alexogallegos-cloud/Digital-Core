CREATE PROCEDURE "informix".sp_consctecoppel_atm (pempresa CHAR(3), pnum_tarjeta CHAR (20), pnum_cajero CHAR(10))

RETURNING 	CHAR (10)	AS codigo_retorno,
			CHAR (30)	AS cliente_BANCOPPEL,
			CHAR (20)	AS cliente_COPPEL,
			CHAR (20)	AS numero_tarjeta,
			CHAR (20)	AS numero_cuenta,
			CHAR (26) 	AS apellido_paterno,
			CHAR (26) 	AS apellido_materno,
			CHAR (26)	AS nombre1,
			CHAR (26) 	AS nombre2;

	DEFINE vcod_ret 	CHAR(50);
	DEFINE vcod_ret2	CHAR(50);
	DEFINE vcod_ret3	CHAR(50);
	DEFINE sql_err		INTEGER;
	DEFINE isam_err		INTEGER;
	DEFINE desc_err		CHAR(50);
	DEFINE vnro_cteb	CHAR(50);
	DEFINE vnro_ctec	CHAR(50);
	DEFINE vempresa		CHAR(3);
	DEFINE vnro_tarj	CHAR(20);
	DEFINE vcajero		CHAR(10);
	DEFINE vcuenta		CHAR(20);
	DEFINE vapell_pat	CHAR(26);
	DEFINE vapell_mat	CHAR(26);
	DEFINE vnombre1		CHAR(26);
	DEFINE vnombre2		CHAR(26);
	DEFINE cCodRet		CHAR(10);
	DEFINE cContador  	INTEGER;
	
	
	LET vcod_ret	= "0000";
	LET vcod_ret2	= " ";
	LET vcod_ret3	= " ";
	LET sql_err		= 0;
	LET isam_err	= 0;
	LET desc_err	= " ";
	LET vnro_cteb	= " ";
	LET vnro_ctec	= " ";
	LET vempresa	= pempresa;
	LET vnro_tarj	= pnum_tarjeta;
	LET vcajero		= pnum_cajero;
	LET vcuenta	= " ";
	LET vapell_pat	= " ";
	LET vapell_mat	= " ";
	LET vnombre1	= " ";
	LET vnombre2	= " ";
	LET cContador = 0;
	
	
	BEGIN
	
	
	ON EXCEPTION SET sql_err, isam_err, desc_err
	
		SET DEBUG FILE TO "/RESPALDOSNEW/sp_consctecoppel_atm.err";
		TRACE ON;
		
		IF sql_err <> 0 THEN 
		LET vcod_ret	= sql_err;
        LET vcod_ret2	= isam_err;
        LET vcod_ret3	= desc_err;
		LET vempresa	= " ";
        LET vnro_tarj	= " ";
		RETURN vcod_ret,vnro_cteb,vnro_ctec,vnro_tarj,vcuenta,vapell_pat,vapell_mat,vnombre1,vnombre2;
		END IF
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

			-- consulta si el cliente tiene un prÃ©stamo digital activo a partir del nÃºmero de tarjeta
			SELECT count(slp.num_credito) INTO cContador
			FROM bdicheq:"informix".sc_tarjeta st, bdicred:"informix".sd_maecredcrd sm, 
			bdicred:"informix".sd_linea_prestamo slp 
			WHERE num_tarjeta = pnum_tarjeta 
			AND st.numcte = sm.numcte
			--AND st.status_tar = "A"
			AND sm.num_producto = '6800'
			AND sm.num_credito = slp.num_credito
			AND slp.fecha_cancela is  null;

			-- si es 1 el contador, el cliente tiene prÃ©stamo digital
			IF cContador = 1
			THEN
				LET vcod_ret = "000000";
				LET cContador = 0;
			END IF

	
			IF vcod_ret='000000' 
			THEN
	
	--Limpia variables
				LET vcod_ret = "000001"; --cliente no es candidado a prestamo personal coppel
				LET vnro_cteb = "cliente tiene Prestamo Digital";
				LET vnro_tarj	= " ";
				LET vnro_ctec	= " ";
				LET vcuenta		= " ";
				LET vapell_pat	= " ";
				LET vapell_mat	= " ";
				LET vnombre1	= " ";
				LET vnombre2	= " ";
				LET vcod_ret2	= " ";
				LET vcod_ret3	= " ";
				LET desc_err	= " ";
				LET vempresa	= " ";
				LET vcajero		= " ";
				
				RETURN vcod_ret,vnro_cteb,vnro_ctec,vnro_tarj,vcuenta,vapell_pat,vapell_mat,vnombre1,vnombre2;
			END IF
	
	IF vnro_ctec is null OR
		vnro_ctec <>"000000"
		THEN 
	--Limpia variables
		LET vcod_ret	= "000000";
		LET vcod_ret2	= " ";
		LET vcod_ret3	= " ";
		LET sql_err		= 0;
		LET isam_err	= 0;
		LET desc_err	= " ";
		LET vnro_cteb	= " ";
		LET vnro_ctec	= " ";
		LET vempresa	= pempresa;
		LET vnro_tarj	= pnum_tarjeta;
		LET vcajero		= pnum_cajero;
		LET vcuenta	= " ";
		LET vapell_pat	= " ";
		LET vapell_mat	= " ";
		LET vnombre1	= " ";
		LET vnombre2	= " ";
		LET cCodRet		= " ";
		
	--obtiene nÃÂºmero de cliente bancoppel
	SELECT numcte, cuenta
		INTO vnro_cteb, vcuenta
		FROM sc_tarjeta 
	WHERE empresa = vempresa
	AND num_tarjeta = vnro_tarj;
	
	--obtiene datos del cliente bancoppel
	
	SELECT apell_paterno, apell_materno, nombre1, nombre2
		INTO vapell_pat,vapell_mat,vnombre1,vnombre2
		FROM bdinteg:si_cliente
	WHERE empresa = vempresa
	AND numcte = vnro_cteb;
	

	--obtiene cliente coppel
	
	SELECT cliente 
		INTO vnro_ctec
		FROM bdinteg:si_relacion_ctebcplcpl
	WHERE empresa = vempresa
	AND numcte_banco = vnro_cteb;
	
	IF vnro_ctec is null OR
		vnro_ctec =" "
	THEN
	LET vcod_ret = "000004"; --cliente no existe
	LET vnro_cteb = "cliente coppel no existe";
    LET vnro_tarj	= " ";
	LET vnro_ctec	= " ";
	LET vcuenta		= " ";
	LET vapell_pat	= " ";
	LET vapell_mat	= " ";
	LET vnombre1	= " ";
	LET vnombre2	= " ";
	RETURN vcod_ret,vnro_cteb,vnro_ctec,vnro_tarj,vcuenta,vapell_pat,vapell_mat,vnombre1,vnombre2;
	END IF
	
	LET vnro_tarj	= SUBSTR(pnum_tarjeta,1,4)||'********'||SUBSTR(pnum_tarjeta,13,4);
	
	RETURN vcod_ret,vnro_cteb,vnro_ctec,vnro_tarj,vcuenta,vapell_pat,vapell_mat,vnombre1,vnombre2;
		END IF
	END;
	END PROCEDURE;