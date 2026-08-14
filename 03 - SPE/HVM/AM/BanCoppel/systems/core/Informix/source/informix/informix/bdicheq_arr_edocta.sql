CREATE PROCEDURE "informix".arr_edocta()
RETURNING CHAR(5), CHAR(20);


DEFINE vCuenta CHAR(20);
DEFINE vAnioMes CHAR(6);
DEFINE vAnioDel CHAR(6);
DEFINE vAnioMes1 CHAR(6);
DEFINE Paso      CHAR(6);
DEFINE vIni  DATE;
DEFINE vFIn  DATE;
DEFINE vcodret           CHAR(5);
DEFINE vsqlerr           INTEGER;
DEFINE vAlta             DATE;
DEFINE isam_err          INTEGER;
DEFINE vMotivo       CHAR(1);

   ON EXCEPTION SET vsqlerr, isam_err
      LET vcodret = vsqlerr;
      ROLLBACK WORK;
      RETURN vcodret, vCuenta;
   END EXCEPTION;

 --SET DEBUG FILE TO "/tmp/arr_edocta.out";
 --TRACE ON;

LET vcodret ="000";
	FOREACH xx WITH HOLD FOR
		SELECT cuenta, fecha_alta
		  INTO vCuenta, vAlta
		  FROM sc_maenoc
                  WHERE  DAY(fecha_alta) <> 1
  		   AND tasa_int_ccc IS NULL 
		-- AND cuenta ="10000911262"

	   BEGIN WORK;

	   IF DAY(vAlta) = 1 THEN
		CALL arr_edocta2("001", vCuenta, "12/02/2007", "01/01/2008",
                             "200612", 0)
		RETURNING vcodret;

		IF vcodret <> "000" THEN
		   ROLLBACK WORK;
		   RETURN vcodret, vCuenta;
		END IF

	   END IF

	   IF  DAY(vAlta) = 30 THEN

	      IF DAY(vAlta) = 30 AND MONTH(vAlta) IN (9,11) THEN
                SELECT MIN(aniomes) INTO vAnioDel
                  FROM sc_maehis
                 WHERE empresa = "001"
                  AND cuenta = vCuenta;

                DELETE FROM sc_maehis
                 WHERE empresa = "001"
                  AND cuenta = vCuenta
                  AND aniomes = vAnioDel;
              ELIF MONTH(vAlta) = 12 THEN
                  SELECT MIN(aniomes) INTO vAnioDel
                    FROM sc_maehis
                   WHERE empresa = "001"
                     AND cuenta = vCuenta;

                  IF vAnioDel = '200712' THEN
                     DELETE FROM sc_maehis
                      WHERE empresa = "001"
                        AND cuenta = vCuenta
                        AND aniomes = vAnioDel;
                  END IF;
	      END IF

		UPDATE sc_maehis 
		   SET aniomes = "2006" || SUBSTR(aniomes,5)
		 WHERE empresa = "001"
		  AND cuenta = vCuenta;
               
	   END IF

	   IF  DAY(vAlta) = 31 AND MONTH(vAlta) IN (7,8,10,12,1) THEN
		UPDATE sc_maehis 
		   SET aniomes = "2006" || nvl(SUBSTR(aniomes,5),'00')
		 WHERE empresa = "001"
		  AND cuenta = vCuenta;

		SELECT MIN(aniomes) INTO vAnioDel
		  FROM sc_maehis
		 WHERE empresa = "001"
		  AND cuenta = vCuenta;

		DELETE FROM sc_maehis
		 WHERE empresa = "001"
		  AND cuenta = vCuenta
		  AND aniomes = vAnioDel;

		SELECT MIN(aniomes) INTO vAnioDel
		  FROM sc_maehis
		 WHERE empresa = "001"
		  AND cuenta = vCuenta;

		UPDATE sc_maehis SET fechaini = vAlta
                 WHERE empresa = "001"
                  AND cuenta = vCuenta
                  AND aniomes = vAnioDel;

	   END IF

	   FOREACH
		SELECT aniomes,
		       CASE
			WHEN DAY(vAlta) = 30 AND vAlta <> fechaini THEN
				TO_CHAR(fechafin,"%Y%m")
			ELSE
				  TO_CHAR(fechaini,"%Y%m")
		       END ,
		       fechaini, fechafin,motivo
		     INTO vAnioMes, vAnioMes1, vIni, vFin, vMotivo
		     FROM sc_maehis
		    WHERE empresa = "001"
		      AND cuenta = vCuenta
		  ORDER BY aniomes 

		IF vMotivo = "u" THEN
			CONTINUE FOREACH;
		END IF

		IF NOT vAnioMes IS NULL THEN
		  UPDATE sc_maehis
		     SET aniomes = vAnioMes1,
			 motivo = "u"
		   WHERE empresa = "001"
		     AND cuenta = vCuenta
		     AND aniomes = vAnioMes;
		ELSE
		  UPDATE sc_maehis
		     SET aniomes = vAnioMes1,
			 motivo = "u"
		   WHERE empresa = "001"
		     AND cuenta = vCuenta
		     AND aniomes IS NULL;
		END IF

		UPDATE sc_movhis
		   SET aniomes = vAnioMes1
		 WHERE empresa = "001"
		   AND cuenta = vCuenta
		   AND fech_alt BETWEEN vIni AND vFin;

	   END FOREACH

           IF vAnioMes1 = '200712' THEN
	      UPDATE sc_movhis
	         SET aniomes =  SUBSTR((vAnioMes1 + 89),1,6)
	       WHERE empresa = "001"
	         AND cuenta = vCuenta
	         AND fech_alt > vFin;
           ELSE
	      UPDATE sc_movhis
	         SET aniomes =  SUBSTR((vAnioMes1 + 1),1,6)
	       WHERE empresa = "001"
	         AND cuenta = vCuenta
	         AND fech_alt > vFin;
           END IF
	
	   UPDATE sc_maenoc SET tasa_int_ccc = "1"
	    WHERE empresa = "001"
	      AND cuenta = vCuenta;

           UPDATE sc_maehis
	     SET motivo = NULL
	   WHERE empresa = "001"
	     AND cuenta = vCuenta;

	   COMMIT WORK;

	END FOREACH
	CALL arr_edocta1() RETURNING vcodret,vCuenta;
	IF trim(vcodret) <> "000" THEN
	   RETURN vcodret, vCuenta;
	END IF

	LET vCuenta ="000000000000000";
        RETURN vcodret, vCuenta;



END PROCEDURE
;