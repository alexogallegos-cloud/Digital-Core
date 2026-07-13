CREATE PROCEDURE "informix".sp_actusaldosn2 ()
RETURNING CHAR(5);

    DEFINE vcodret1                         CHAR(5);
    DEFINE vcodret2                         CHAR(5);
    DEFINE vcodret3                         CHAR(50);
    DEFINE sql_err                          INTEGER;
    DEFINE isam_err                         INTEGER;
    DEFINE desc_err                         CHAR(50);
    DEFINE vsql                             CHAR(400);
	DEFINE vAcumExi                         INTEGER;
	DEFINE vAcumNue                         INTEGER;
	DEFINE vTotacum                         INTEGER;
	DEFINE vAcumSdo                         MONEY (18,2);
   	
    LET vcodret1                             = '00000';
    LET vcodret2                             = '000';
    LET vcodret3                             = '';
    LET sql_err                              = 0;
    LET isam_err                             = 0;
    LET desc_err                             = '';
    LET vsql                          	     = '';
	LET vAcumExi                             = 0; 
	LET vAcumNue                             = 0;
	LET vTotacum                             = 0;
	LET vAcumSdo                             = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actusaldosn2.err";
        TRACE ON;
        IF  sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO '/informix/rsv/n2/sp_control_cts_n2.out';
    --TRACE ON;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	SELECT a.cuenta,
	       a.num_cte, 
		   b.fecha_alta,     
		   d.fecha_insert,    
		   a.sdo_dia_ant,  
	       CASE WHEN b.fecha_alta = d.fecha_insert THEN "NUEVO"
                ELSE   "EXISTENTE" 
		   END AS tipo_cliente
    FROM   bdicheq:sc_maechq a, 
           bdicheq:sc_maenoc b, 
           bdinteg:si_cliente d
    WHERE  a.cuenta    = b.cuenta
    AND    a.num_cte   = d.numcte
    AND    a.producto  = "2900"
    AND    b.fecha_alta <  today -2
    INTO TEMP tmp_n2cifras WITH NO LOG;	
	
	--SE OBTIENE LOS CLIENTES EXISTENTES ACUMULADOS
	SELECT COUNT(*)
	INTO   vAcumExi
	FROM  tmp_n2cifras
	WHERE tipo_cliente = "EXISTENTE";
		
	--SE OBTIENE LOS CLIENTES EXISTENTES NUEBOS 
	SELECT COUNT(*)
	INTO   vAcumNue
	FROM  tmp_n2cifras
	WHERE tipo_cliente = "NUEVO";
	
	--SE OBTIENE EL TOTAL DE ALTAS
	SELECT COUNT(*)
	INTO   vTotacum
	FROM  tmp_n2cifras; 
	
	--SE OBTIENE EL ACUMULADO DE SALDO ANTERIOR  DE TODAS LAS ALTAS
	SELECT SUM(sdo_dia_ant)
	INTO   vAcumSdo
	FROM   tmp_n2cifras; 
	
	UPDATE control_altas_cta_n2
	SET    alt_ctes_nuevos_dia = 0,
	       alt_ctes_exist_dia  = 0,
		   altas_del_dia       = 0,
		   saldo_dia           = 0,
		   acum_ctes_exist     = vAcumExi,
		   acum_ctes_nuevo     = vAcumNue,
		   acum_altas          = vTotacum,
		   monto_acum          = vAcumSdo
	WHERE  monto_acum > 0; 
	
	DROP TABLE tmp_n2cifras;

	END;

    RETURN vcodret1;
END PROCEDURE;