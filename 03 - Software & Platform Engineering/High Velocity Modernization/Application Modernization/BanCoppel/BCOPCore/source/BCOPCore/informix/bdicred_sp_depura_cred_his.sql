CREATE PROCEDURE "informix".sp_depura_cred_his()
RETURNING 
CHAR(6),     -- código de retorno
CHAR(150);    -- mensaje


DEFINE cCodRet      CHAR(6); 
DEFINE cMensaje     CHAR(150); 
DEFINE vNumCred     VARCHAR(20,1);
DEFINE vNumCredAux  VARCHAR(20,1);
DEFINE iSqlErr      INTEGER;
DEFINE iIsamErr     INTEGER;
DEFINE Error_Info   VARCHAR(80);
DEFINE dFechaDepura DATE;
--Pruebas IPCB
DEFINE vFecha DATE;
DEFINE dFechaAProcesar DATE;
DEFINE vnum_credito CHAR(20);
DEFINE vfecha_corte DATE;
DEFINE cFechaDepura char(10);
DEFINE iDepura		integer;
DEFINE cHoraInicial		CHAR(8);
DEFINE cHoraFinal		CHAR(8);
DEFINE sHoraInicial		SMALLINT;
DEFINE sHoraFinal		SMALLINT;
DEFINE sMinutoInicial	SMALLINT;
DEFINE sMinutoFinal		SMALLINT;


DEFINE sHorasProceso	SMALLINT;
DEFINE cTerminaProceso	CHAR(1);
DEFINE iCuentasProcesadas			INTEGER;
DEFINE iCount_sd_maesdoshist_old	INTEGER;
DEFINE iCount_sd_maecredcont_old	INTEGER;
DEFINE iCount_sd_maesdoscont_old	INTEGER;
DEFINE iCount_sd_hist_reserva_old	INTEGER;
DEFINE iCount_sd_movhis_calif_old	INTEGER;
DEFINE cProceso		CHAR(04);
DEFINE P_COD_RET    VARCHAR(6);
DEFINE P_MENSAJE    VARCHAR(150);

LET cCodRet      = '000000';
LET cMensaje     = '';
LET iSqlErr      = 0;
LET iIsamErr     = 0;
LET Error_Info   = '';
LET vNumCred     = '';
LET vNumCredAux  = '';
LET dFechaDepura = DATE(1);
--Pruebas IPCB
LET vFecha 			= date(1);
LET dFechaAProcesar = date(1);
LET vnum_credito	= '';
LET vfecha_corte	= DATE(1);
LET cFechaDepura	= '';
LET iDepura			= 0;
LET cHoraInicial	= '';
LET cHoraFinal		= '';
LET sHoraInicial	= 0;
LET sHoraFinal		= 0;
LET sMinutoInicial	= 0;
LET sMinutoFinal	= 0;

LET sHorasProceso	= 0;
LET cTerminaProceso = '0';
LET iCuentasProcesadas			= 0;
LET iCount_sd_maesdoshist_old	= 0;
LET iCount_sd_maecredcont_old	= 0;
LET iCount_sd_maesdoscont_old	= 0;
LET iCount_sd_hist_reserva_old	= 0;
LET iCount_sd_movhis_calif_old	= 0;
LET cProceso		= '0001';
LET P_COD_RET   	= '000000';
LET P_MENSAJE		= 'El proceso MUEVE A TABLAS HISTORICAS terminó exitosamente. Cuentas procesadas ';


BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, Error_Info
        IF iSqlErr != 0 THEN
			LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_maecredcont_old : ' ||iCount_sd_maecredcont_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
			LET cMensaje = 'Cuentas respaldadas sd_hist_reserva_old : ' ||iCount_sd_hist_reserva_old;
			LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_calif_old : ' ||iCount_sd_movhis_calif_old;
		CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;

		LET cCodRet = iSqlErr;		
            LET cMensaje = 'Error --> '||Error_Info||'	'||vNumCred;

			CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '02') RETURNING P_COD_RET;

            RETURN cCodRet,cMensaje;
        END IF;
    END EXCEPTION;

    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '01') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;
	
--SET DEBUG FILE TO 'sp_depura_cred_his.out';
--TRACE ON;

    select fecha_hoy into vFecha
    from bdicred:sd_fechas;

--temporal solo para pruebas
--LET vFecha = today; --mdy ('11','10','2013');
--temporal solo para pruebas

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraInicial from sysmaster:sysshmvals;

	LET sHoraInicial = SUBSTR(cHoraInicial,1,2);
	LET sMinutoInicial = SUBSTR(cHoraInicial,4,2);
	
    SELECT num_credito
      INTO vNumCredAux
      FROM "informix".sd_param_movhis_dep
     WHERE proceso = 3;

    IF vNumCredAux IS NULL THEN 
       LET vNumCredAux = ""; 
       INSERT INTO "informix".sd_param_movhis_dep VALUES(3,'');
    END IF;

--Pruebas IPCB

    SELECT valor::date
      INTO dFechaDepura
      FROM bdicred:sd_param
     WHERE cod_param = '048';

    IF dFechaDepura IS NULL THEN 
        LET cCodRet = '100100';
        LET P_MENSAJE = 'No existe parámetro de fecha a depurar.';
        RETURN cCodRet,P_MENSAJE;
    END IF;

	SELECT valor::smallint
      INTO sHorasProceso
      FROM bdicred:sd_param
     WHERE cod_param = '053';

	 IF sHorasProceso IS NULL THEN 
        LET cCodRet = '100200';
        LET P_MENSAJE = 'No existe parámetro de horas a procesar.';
        RETURN cCodRet,P_MENSAJE;
    END IF;
	 
    if vNumCredAux = '' then
        execute PROCEDURE bdicred:monthadd(vFecha, -18) into dFechaDepura;

        let dFechaDepura = mdy(month(dFechaDepura),1,year(dFechaDepura)) - 1;

        UPDATE bdicred:sd_param
           SET valor = dFechaDepura
         WHERE cod_param = '048';

    end if;

    FOREACH WITH HOLD

       SELECT TRIM(num_credito)
           INTO vNumCred 
           FROM bdicred:"informix".sd_maecred
          WHERE empresa     = '001' 
            AND num_credito > vNumCredAux
       ORDER BY num_credito ASC

	   LET iCuentasProcesadas = iCuentasProcesadas + 1;
	   
        BEGIN WORK;
--maesdoshist
            insert into bdicred:sd_maesdoshist_old
            select * from bdicred:sd_maesdoshist
            where empresa = '001'
            and fecha    <= mdy(month(dFechaDepura),20,year(dFechaDepura))
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoshist
            where empresa = '001'
            and fecha    <= mdy(month(dFechaDepura),20,year(dFechaDepura))
            and num_credito = vNumCred;

			LET iCount_sd_maesdoshist_old	= iCount_sd_maesdoshist_old + 1;
			
--maecredcont
            insert into bdicred:sd_maecredcont_old
            select * from bdicred:sd_maecredcont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

            delete from bdicred:sd_maecredcont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;
--            and num_credito <= vNumCred;
			
			LET iCount_sd_maecredcont_old	= iCount_sd_maecredcont_old + 1;
			
--maesdoscont
            insert into bdicred:sd_maesdoscont_old
            select * from bdicred:sd_maesdoscont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

            delete from bdicred:sd_maesdoscont
            where empresa = '001'
            and fecha    <= dFechaDepura
            and num_credito = vNumCred;

			LET iCount_sd_maesdoscont_old	= iCount_sd_maesdoscont_old + 1;

--hist_reserva
--Pruebas IPCB

         insert into bdicred:sd_hist_reserva_old
            select *  
              from bdicred:sd_hist_reserva
             where empresa = '001'
               and fecha_corte <= dFechaDepura
               and fecha_corte not in (mdy('05','20','2011'),mdy('06','20','2011'),mdy('07','20','2011'),mdy('08','20','2011'),mdy('09','20','2011'),mdy('03','20','2012'),mdy('03','31','2012'),mdy('04','20','2012'),mdy('04','30','2012'),mdy('05','20','2012'),mdy('05','31','2012'),mdy('06','20','2012'),mdy('07','20','2012'),mdy('08','20','2012'))
               and num_credito = vNumCred;

             delete from bdicred:sd_hist_reserva
              where empresa = '001'
                and fecha_corte <= dFechaDepura
                and num_credito = vNumCred;

		LET iCount_sd_hist_reserva_old	= iCount_sd_hist_reserva_old + 1;
				
--sd_movhis_calif
            insert into bdicred:sd_movhis_calif_old
--            select {+INDEX(sd_movhis_calif inx_movhis_calif_1)} * from bdicred:sd_movhis_calif
            select * from bdicred:sd_movhis_calif
            where empresa = '001'
             and fecha_mov = dFechaDepura
/*            and fecha_mov in (
                mdy('06','30','2012'),
                mdy('07','31','2012'),
                mdy('08','31','2012'),
                mdy('09','30','2012'),
                mdy('10','31','2012'),
                mdy('11','30','2012'),
                mdy('12','31','2012'))*/
            and num_credito = vNumCred;

            delete from bdicred:sd_movhis_calif
            where empresa = '001'
            and fecha_mov = dFechaDepura
/*            and fecha_mov in (
                mdy('06','30','2012'),
                mdy('07','31','2012'),
                mdy('08','31','2012'),
                mdy('09','30','2012'),
                mdy('10','31','2012'),
                mdy('11','30','2012'),
                mdy('12','31','2012'))*/
            and num_credito = vNumCred;

			LET iCount_sd_movhis_calif_old	= iCount_sd_movhis_calif_old + 1;
			
            UPDATE "informix".sd_param_movhis_dep
               SET num_credito = vNumCred
             WHERE proceso = 3;
        COMMIT WORK;  
        let iDepura = 0;

		SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO cHoraFinal from sysmaster:sysshmvals;

		LET	sHoraFinal = SUBSTR(cHoraFinal,1,2);
		LET	sMinutoFinal = SUBSTR(cHoraFinal,4,2);
		LET	sHoraFinal = sHoraFinal - sHoraInicial;

		IF sHoraFinal >= sHorasProceso AND sMinutoFinal > sMinutoInicial THEN
			LET cTerminaProceso = '1';
			EXIT FOREACH;
		END IF;
	END FOREACH;

	IF cTerminaProceso = '0' THEN
		UPDATE "informix".sd_param_movhis_dep
		SET num_credito = ''
		WHERE proceso = 3;
	END IF;

	LET cMensaje = 'TOTAL Cuentas procesadas : ' ||iCuentasProcesadas;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoshist_old : ' ||iCount_sd_maesdoshist_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_maecredcont_old : ' ||iCount_sd_maecredcont_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_maesdoscont_old : ' ||iCount_sd_maesdoscont_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	LET cMensaje = 'Cuentas respaldadas sd_hist_reserva_old : ' ||iCount_sd_hist_reserva_old;
	LET cMensaje = trim(cMensaje) ||'    Cuentas respaldadas sd_movhis_calif_old : ' ||iCount_sd_movhis_calif_old;
	CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, trim(cMensaje), '02') RETURNING P_COD_RET;
	
    CALL bdicred:"informix".sp_inserta_bitacora('001', cProceso, cCodRet, cMensaje, '03') RETURNING P_COD_RET;

    IF P_COD_RET != '000000' THEN
       LET P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    END IF;

	LET P_MENSAJE = P_MENSAJE || ' ' || iCuentasProcesadas;
	
    RETURN cCodRet,P_MENSAJE;

    END
END PROCEDURE;