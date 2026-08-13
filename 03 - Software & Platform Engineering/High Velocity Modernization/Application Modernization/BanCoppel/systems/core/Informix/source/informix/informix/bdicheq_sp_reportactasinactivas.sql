CREATE PROCEDURE "informix".sp_reportactasinactivas()
RETURNING VARCHAR(5);

    DEFINE Sql_Err      INTEGER;
    DEFINE Isam_Err     INTEGER;
    DEFINE Desc_Err     VARCHAR(50);
    DEFINE vCodRet1     VARCHAR(5);
    DEFINE vCodRet2     VARCHAR(5);
    DEFINE vCodRet3     VARCHAR(50);
    DEFINE vFechaHoy    DATE;
    DEFINE vCuenta      VARCHAR(20);
    DEFINE vSucursal    VARCHAR(4);
    DEFINE vSdoActual   DECIMAL(18,2);
    DEFINE vProducto    VARCHAR(4);
    DEFINE vNombreCte   VARCHAR(104);
    DEFINE vTelCasa     VARCHAR(13);
	DEFINE vTelCasa1    VARCHAR(13);
    DEFINE vTelMovil    VARCHAR(13);
    DEFINE vTelOficina  VARCHAR(13);
    DEFINE vCorreo      VARCHAR(100);
    DEFINE vFecha       VARCHAR(8);
    DEFINE vSql         LVARCHAR(400);
    DEFINE vStmt        VARCHAR(200);
    DEFINE vContador    INTEGER;
    DEFINE vContador2   INTEGER;
    DEFINE vNumCte 	    VARCHAR(20);
	DEFINE vTelTipov    INTEGER;
	
	DEFINE vComienza      INTEGER;
    DEFINE vEnTransacc    INTEGER;
    DEFINE vComienza1     INTEGER;
    DEFINE vEnTransacc1   INTEGER;
	
    
    LET Sql_Err	     = 0;
    LET Isam_Err     = 0;
    LET Desc_Err     = '';
    LET vCodRet1     = '000';
    LET vCodRet2     = '000';
    LET vCodRet3     = '';
    LET vFechaHoy    = '';
    LET vCuenta      = '';
    LET vSucursal    = '';
    LET vSdoActual   = 0.00;
    LET vProducto    = '';
    LET vNombreCte   = '';
    LET vTelCasa     = '';
	LET vTelCasa1    = '';
    LET vTelMovil    = '';
    LET vTelOficina  = '';
    LET vCorreo      = '';
    LET vFecha       = '';
    LET vSql         = '';
    LET vStmt        = '';
    LET vContador    = 0;
    LET vContador2   = 0;
    LET vNumCte      = '';
	
	LET vComienza        = -1;
    LET vEnTransacc      = 0; 
    LET vComienza1       = -1;
    LET vEnTransacc1     = 0;
    LET vTelTipov        = 0;
/*
No. ticket:          2200008
Motivo modificaciÃ³n: Problema actual:
	El drop table se sustituye por TRUNCATE esto favorece al motor de BBDD
Se cambia el indice explÃ­cito: idx_sc_maechq(va por cuenta y producto)  por: mae1 , que va por cliente
ModificaciÃ³n por:    Accenture
Fecha:               Julio-2025

EPVP : Se agrega el campo de num_cte a la tabla sc_reportactasinactivas_p que se crea dentro del SPL
       se inserta y despues se actualiza los campos de telefono y correo para la descarga de la informacion
Fecha:               Agosto-2025
*/

BEGIN

    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        
        IF Sql_Err <> 0 THEN
		    SET DEBUG FILE TO "/resplogifx/conciliachq/sp_reportactasinactivas.err";
            TRACE ON;
			
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	--SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_reportactasinactivas.out";
    --TRACE ON;

    SELECT fecha_hoy
      INTO vFechaHoy
      FROM bdicheq:sc_fechas
     WHERE empresa = '001';
	 
	--35,000 registros
    IF EXISTS(SELECT dbsname, tabname
              FROM sysmaster:systabnames
              WHERE partnum > 0
              AND tabname = 'sc_reportactasinactivas_p') THEN
       TRUNCATE TABLE bdicheq:sc_reportactasinactivas_p;

	ELSE
  		CREATE TABLE bdicheq:sc_reportactasinactivas_p
      (
        num_cte                 VARCHAR(20)     NOT NULL,
        producto                VARCHAR(4)      NOT NULL,
        nombre_cte              VARCHAR(104),
        cuenta                  VARCHAR(20)     NOT NULL,
        tel_casa                VARCHAR(13),
        tel_movil               VARCHAR(13),
        tel_oficina             VARCHAR(13),
        correo                  VARCHAR(100),
        sucursal                VARCHAR(4)      NOT NULL,
        saldo_cta               DECIMAL(18,2)   NOT NULL,
        fecha                   DATE
      )IN dbs_datos05 EXTENT SIZE 1500 NEXT SIZE 150 LOCK MODE ROW;
    CREATE INDEX idx_repctasinac_prodcta_p2 ON sc_reportactasinactivas_p(num_cte) IN dbs_idxinteg ONLINE;
	CREATE INDEX idx_repctasinac_prodcta_p1 ON sc_reportactasinactivas_p(producto, cuenta) IN dbs_idxinteg ONLINE;
	END IF;

	FOREACH cur_01 WITH HOLD FOR

		SELECT TRIM(mae.num_cte), TRIM(mae.cuenta), mae.sucursal, mae.sdo_actual, mae.producto,
		TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno),tel1.tipo_tel,tel1.telefono,tel2.telefono,tel3.telefono
		INTO vNumCte, vCuenta, vSucursal, vSdoActual, vProducto,vNombreCte,vTelTipov, vTelCasa,vTelMovil,vTelOficina
		FROM bdicheq:sc_maechq mae
		INNER JOIN bdinteg:si_cliente cte ON cte.numcte = mae.num_cte
		LEFT JOIN  bdinteg:si_telefonos_actual tel1 on mae.num_cte = tel1.numcte AND  tel1.tipo_tel IN (1)
		LEFT JOIN  bdinteg:si_telefonos_actual tel2 on mae.num_cte = tel2.numcte AND  tel2.tipo_tel IN (2)
		LEFT JOIN  bdinteg:si_telefonos_actual tel3 on mae.num_cte = tel3.numcte AND  tel3.tipo_tel IN (3)
		WHERE mae.status_cta = '4'
		AND mae.sdo_actual >= 5000.00
		
		IF vTelTipov = 1 THEN
          LET vTelCasa1 = vTelCasa;
        END IF

        IF vTelTipov = 2 THEN
          LET vTelMovil = vTelCasa;
        END IF

        IF vTelTipov = 3 THEN
          LET vTelOficina = vTelCasa;
        END IF
		
		
	    IF (vComienza = -1) THEN
		  LET vComienza = 0;
		  LET vEnTransacc = 1;
		  BEGIN WORK;
	    END IF;

       INSERT INTO bdicheq:sc_reportactasinactivas_p (num_cte, producto, nombre_cte, cuenta,tel_casa,tel_movil,tel_oficina,sucursal, saldo_cta, fecha)
		                              VALUES (vNumCte, vProducto, vNombreCte, vCuenta,vTelCasa1,vTelMovil,vTelOficina, vSucursal, vSdoActual, vFechaHoy);
        
		UPDATE bdicheq:sc_reportactasinactivas_p
        SET tel_casa = vTelCasa,
           tel_movil = vTelMovil,
           tel_oficina = vTelOficina,
           correo = vCorreo
        WHERE num_cte = vNumCte
        AND cuenta = vCuenta;

       LET vContador = vContador + 1;

       IF vContador >= 1000 THEN
          LET vContador = 0;
          COMMIT WORK;
          BEGIN WORK;
       END IF;

       LET vCuenta     = '';
       LET vSucursal   = '';
       LET vSdoActual  = 0.00;
       LET vProducto   = '';
       LET vNombreCte  = '';
       LET vTelCasa    = '';
       LET vTelMovil   = '';
       LET vTelOficina = '';
       LET vCorreo     = '';
	END FOREACH;
	
	
		IF (vEnTransacc = 1) THEN
		  LET vEnTransacc = 0;
		  COMMIT WORK;
		END IF;
		
	
	   LET vCuenta     = '';
       LET vSucursal   = '';
       LET vSdoActual  = 0.00;
       LET vProducto   = '';
       LET vNombreCte  = '';
       LET vTelCasa    = '';
       LET vTelMovil   = '';
       LET vTelOficina = '';
       LET vCorreo     = '';
	
	
    FOREACH cur_02 WITH HOLD FOR
	   
	   SELECT Trim(rcta.num_cte),Trim(rcta.producto),Trim(rcta.nombre_cte),Trim(rcta.cuenta),
			  Trim(rcta.tel_casa),Trim(rcta.tel_movil),Trim(rcta.tel_oficina),Trim(mail.correo_elec), rcta.sucursal,rcta.saldo_cta,rcta.fecha
		 INTO vNumCte,vProducto,vNombreCte,vCuenta, 
		      vTelCasa,vTelMovil,vTelOficina,vCorreo,vSucursal,vSdoActual,vFechaHoy
	    FROM bdicheq:sc_reportactasinactivas_p rcta, bdinteg:si_correos mail
	    WHERE rcta.num_cte = mail.numcte
		AND mail.tipo_correo = 1
		AND mail.status_correo = 'A'	
		
		IF (vComienza1 = -1) THEN
          LET vComienza1 = 0;
          LET vEnTransacc1 = 1;
          BEGIN WORK;
       END IF;

		--Actualizamos el campo del email de la tabla sc_reportactasinactivas_p
		  UPDATE bdicheq:sc_reportactasinactivas_p
		         SET correo = vCorreo
				 WHERE num_cte = vNumCte
				 AND cuenta = vCuenta;

       LET vContador = vContador + 1;

       IF vContador >= 1000 THEN
          LET vContador = 0;
          COMMIT WORK;
          BEGIN WORK;
       END IF;
	   
	   
    END FOREACH;

		IF (vEnTransacc1 = 1) THEN
			LET vEnTransacc1 = 0;
			COMMIT WORK;
		END IF;

    UPDATE STATISTICS MEDIUM FOR TABLE bdicheq:sc_reportactasinactivas_p;

    LET vProducto = '';
    LET vFecha = TO_CHAR(vFechaHoy, '%d%m%Y');

    FOREACH
        --SELECT UNIQUE producto
		SELECT  producto
        INTO vProducto
        FROM bdicheq:sc_reportactasinactivas_p
		GROUP BY 1

        LET vSql = '';
        LET vSql = 'echo "SET ISOLATION TO DIRTY READ; '||
                   'UNLOAD TO /resplogifx/conciliachq/cuentasinactivas5000_prod'||vProducto||'_'||vFecha||'.unl '||
                   'SELECT trim(nombre_cte), trim(cuenta), trim(tel_casa), trim(tel_movil), trim(tel_oficina),trim(correo), sucursal, saldo_cta '||
                   'FROM bdicheq:sc_reportactasinactivas_p WHERE producto = '''||vProducto||''' ORDER BY cuenta;" > /resplogifx/conciliachq/repctasinac.sql';
        SYSTEM vSql;
        LET vSql = '';
        
        LET vStmt = '';
        LET vStmt = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/repctasinac.sql"; 
        SYSTEM vStmt;
        LET vStmt = '';
		
		LET vStmt = '';
        LET vStmt = "sed 's/\\//g' /resplogifx/conciliachq/cuentasinactivas5000_prod"||vProducto||'_'||vFecha||'.unl '|| " >  /resplogifx/conciliachq/cuentasinactivas5000_prod"||vProducto||'_'||vFecha||'.txt';
		SYSTEM vStmt;
        LET vStmt = '';
		
		LET vStmt = '';
        LET vStmt = "rm /resplogifx/conciliachq/cuentasinactivas5000_prod"||vProducto||'_'||vFecha||'.unl '; 
        SYSTEM vStmt;
        LET vStmt = '';
		
		
		LET vStmt = '';
        LET vStmt = "rm /resplogifx/conciliachq/repctasinac.sql"; 
        SYSTEM vStmt;
        LET vStmt = '';
		
		LET vProducto = '';

		
    END FOREACH;
   
END;

    RETURN vCodRet1;

END PROCEDURE;