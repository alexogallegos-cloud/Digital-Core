CREATE PROCEDURE "informix".reversion(pempresa  char(3),
                                      psucursal char(4),
                                      pusuario  char(8),
                                      pfolio    char(16),
                                      ptiporev  char(1))

   RETURNING char(5);

   DEFINE sql_err             integer;
   DEFINE isam_err            integer;
   DEFINE cod_ret             char(5);
   DEFINE contador            smallint;
   DEFINE wtransacc           char(4);
   DEFINE wmonto_tot          money(14,2);
   DEFINE wnaturaleza         char(1);
   DEFINE wtipo               char(1);
   DEFINE wfolio_oper         char(8);
   DEFINE fecha_hora          datetime hour to minute;
   define wfechoy			  date;



   LET sql_err 		= 0;
   LET isam_err 	= 0;
   LET cod_ret 		= '000';
   LET contador 	= 0;
   LET wtransacc 	= '0000';
   LET wnaturaleza 	= '0';
   LET wtipo 		= '0';
   LET wfolio_oper 	= '00000000';
   LET fecha_hora = " ";
   --let wfechoy  = today;
	BEGIN
		ON EXCEPTION
		SET sql_err, isam_err
		IF (sql_err <> 0) THEN
			SET DEBUG FILE TO "reversiondot.err";
			TRACE sql_err || " * " || isam_err;
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF;
	END EXCEPTION;

	SELECT fecha_hoy into wfechoy
	FROM bdinteg:"informix".si_fechas where empresa = pempresa;
 

    SELECT COUNT(*) INTO contador
	FROM "informix".ss_operaciones m, bdinteg:"informix".si_transacc t
	WHERE m.empresa = pempresa and folio_sucursal = pfolio and
		m.empresa = t.empresa and m.cod_trans = t.numero and
		reversable = "S" and m.reversado <> "1" AND 
		m.fecha_operacion = wfechoy;
		
IF (contador = 0) THEN
		RETURN cod_ret;
	ELSE -- Checa si hay Dotaciones y en Status de Reversarse 
		SELECT folio_oper,current INTO wfolio_oper, fecha_hora
		FROM   bdisuc:"informix".ss_operaciones
		WHERE  empresa = pempresa AND folio_sucursal = pfolio
		AND    fecha_operacion = wfechoy;
		SELECT COUNT(*) INTO contador 
		FROM   bdisuc:"informix".ss_mae_entradasalida 
		WHERE  folio_oper = wfolio_oper
		AND    status in ('01','06');
		IF contador = 0 THEN 
			LET cod_ret = "888"; 
			RETURN cod_ret;
		ELSE  -- Reversa si es Falso el Maestro y el Movimiento
			-- Se cambia 'S' por '1' para evitar el error -1213 al reintentar de nuevo realizar la devolucion


			UPDATE bdisuc:"informix".ss_operaciones SET reversado = '1'  
			WHERE  empresa = pempresa AND folio_sucursal = pfolio
			AND    fecha_operacion = wfechoy;
			UPDATE bdisuc:"informix".ss_mae_entradasalida SET status = '08',
			fecha_reversion = wfechoy,hora_reversion = rpad(fecha_hora,8,'0'),
			usuario_reversion = pusuario
			WHERE  folio_oper = wfolio_oper;
		END IF
	end if
   RETURN cod_ret;
END;
END PROCEDURE;