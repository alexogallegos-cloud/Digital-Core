CREATE PROCEDURE "informix".sp_act_cuentas_bloqueadas()
RETURNING VARCHAR(5),VARCHAR(5),INTEGER;

    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     VARCHAR(50);
    DEFINE vCodRet1     VARCHAR(5);
    DEFINE vCodRet2     VARCHAR(5);
    DEFINE vCodRet3     VARCHAR(50);

    DEFINE vContador    INTEGER;	
	DEFINE vComienza      INTEGER;
    DEFINE vEnTransacc    INTEGER;
	DEFINE dHora  datetime hour to fraction(3);
	DEFINE vCuenta VARCHAR(20);
	DEFINE cStatus_blo CHAR(1);
	DEFINE cStatus_cta CHAR(1);
	DEFINE cMotivo CHAR(2);
	DEFINE dFecha DATE;
	DEFINE iNum_cuentas_update INTEGER;
	
	
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
	LET vCodRet2     = '000';
	
	LET vComienza    = -1;
    LET vEnTransacc  = 0; 
	LET vContador = 0;

	
	LET dHora  = '';
	LET vCuenta = '';
	LET cStatus_blo = '';
	LET cStatus_cta ='';
	LET cMotivo ='';
	LET dFecha = '';
	LET iNum_cuentas_update = 0;
	

BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        
        IF Sql_Err <> 0 THEN
		    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_act_cuentas_bloqueadas.err";
            TRACE ON;
			
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
			LET vCodRet3 = iNum_cuentas_update;
            RETURN vCodRet1,vCodRet2,iNum_cuentas_update;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/c98789058/sp_act_cuentas_bloqueadas.out";
    --TRACE ON;

	--500 registros
	DROP TABLE IF EXISTS ctas_bloqueadas_universo;
  	
	
	
	CREATE TABLE bdicheq:ctas_bloqueadas_universo
      (
        hora datetime hour to fraction(3),
        cuenta VARCHAR(20),
		status_blo CHAR(1),
		status_cta CHAR(1),
		motivo CHAR(2),
		fecha DATE
      )IN dbs_datos05 EXTENT SIZE 1500 NEXT SIZE 150 LOCK MODE ROW;
    
	CREATE INDEX idx_ctas_bloqueadas ON ctas_bloqueadas_universo(cuenta) IN dbs_idxinteg ONLINE;

	UPDATE STATISTICS MEDIUM FOR TABLE ctas_bloqueadas_universo;
	----------------------Inicio Universo base de cuentas bloqueadas------------------------
	
	select a.hora,a.fecha,a.cuenta,a.status_blo
	from bdicheq:sc_histbloq a
	where  a.fecha in(select max(fecha) from bdicheq:sc_histbloq b where a.cuenta = b.cuenta)
	and a.fecha >='01/01/2025'
	into temp tmp_cta_fecha with no log;


	CREATE INDEX idxctabloqueo ON tmp_cta_fecha(cuenta) ONLINE;
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_cta_fecha;

	
			
	select a.hora,a.fecha,a.cuenta,a.status_blo
	from tmp_cta_fecha a
	where a.hora in(select max(hora)  from tmp_cta_fecha b where a.cuenta = b.cuenta)
	into temp tmp_cta_fecha_hora with no log;


	CREATE INDEX idxctabloq ON tmp_cta_fecha_hora(cuenta) ONLINE;
	UPDATE STATISTICS MEDIUM FOR TABLE tmp_cta_fecha_hora;


	select a.hora,a.cuenta,a.status_blo,a.fecha,b.status_cta,b.motivo
	from tmp_cta_fecha_hora  a , bdicheq:sc_maechq b
	where a.cuenta = b.cuenta
	and a.status_blo = 'B'
	into temp tmp_cuenta_vs_maechq with no log;
	
	insert into ctas_bloqueadas_universo
	select hora,cuenta,status_blo,status_cta,motivo,fecha
	from tmp_cuenta_vs_maechq
	where status_blo ='B'
	and status_cta ='1';
		
	
	
	---------------Cierre Universo base de cuentas bloqueadas----
-----------------------------------------------------------------------------

	FOREACH cur_01 WITH HOLD FOR

		SELECT cuenta
		INTO vCuenta
		FROM ctas_bloqueadas_universo
		
		
		
	    IF (vComienza = -1) THEN
		  LET vComienza = 0;
		  LET vEnTransacc = 1;
		  BEGIN WORK;
	    END IF;

			--UPDATE bdicheq:sc_maechq_cuentas_bloqueadas --para prueba de ejecuciÃ³n
			UPDATE bdicheq:sc_maechq
			SET status_cta = '3',
				motivo = '09'
			WHERE cuenta = vCuenta
			AND status_cta = '1';
        
	   LET iNum_cuentas_update = iNum_cuentas_update + 1;
       LET vContador = vContador + 1;

       IF vContador >= 10 THEN
          LET vContador = 0;
          COMMIT WORK;
          BEGIN WORK;
       END IF;

	END FOREACH;
	
	
		IF (vEnTransacc = 1) THEN
		  LET vEnTransacc = 0;
		  COMMIT WORK;
		END IF;
		

   
END;

    RETURN vCodRet1,vCodRet2,iNum_cuentas_update;

END PROCEDURE;