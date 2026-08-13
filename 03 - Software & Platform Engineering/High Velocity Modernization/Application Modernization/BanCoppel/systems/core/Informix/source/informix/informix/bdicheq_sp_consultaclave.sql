Create procedure "informix".sp_consultaclave(cClave char(35), dFecha1 char(10), dFecha2 char(10))
    Returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200);
		
	define cCodret char(5);
	define cCuenta char(20);
	define mImporte money ; --(14,2);
	define dFecha date ;
	define dHora DateTime Hour to Second ;
	define cDescripcion char(35);
	define cDescripcion2 char(35);
	define cNombre char(200);
	define cRfc char(20);
	define cSQL_ERR integer;

	let cCuenta = "";
	let mImporte= 0;
	let cDescripcion = "";
	let cDescripcion2 = "";
	let cNombre = "";
	let cRfc = "";
	let cSQL_ERR = 100 ;
	let cCodret  = "000";
	let dFecha = "" ;
	let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET cSQL_ERR
	LET cCodret = cSQL_ERR;
	RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
	END EXCEPTION;

    FOREACH
        Select hb.cuenta, NVL(TRIM(si_cliente.nombre1),"") ||' '|| NVL(TRIM(si_cliente.nombre2),"") ||' '
            || NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
            rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
        INTO cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
        From bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
			INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
			INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
			INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
        Where cb.descripcion = cClave
			And hb.fecha >= dFecha1 And hb.fecha <= dFecha2
        Order by hb.fecha desc,hb.hora desc

        RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume;

    END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por clave de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".desbloq_cuentas(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vstatus 	CHAR(1);
   DEFINE vmotivo 	CHAR(2);
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vfolio	CHAR(20);

   LET vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./desbloq_cuentas.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
   
   FOREACH
       SELECT UNIQUE cuenta
	 INTO vcuenta
         FROM cuentas_desbloq
        WHERE cuenta IS NOT NULL

	SELECT status_cta, motivo
	  INTO vstatus, vmotivo
	  FROM sc_maechq
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

	IF vstatus = "3" AND vmotivo = "09" THEN

            UPDATE sc_maechq
               SET status_cta = "1",
	           motivo = "00"
	     WHERE empresa = pempresa
               AND cuenta = vcuenta;

	    INSERT INTO sc_histbloq VALUES(
			pempresa, vcuenta, "D", "00", " ",
	                0.00, "informix", vfecha,
			current hour to fraction,
			"1111", "D", vfolio, " ");

	    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", 4);

            DELETE FROM sc_ctabloqueo
	     WHERE cuenta = vcuenta;

	END IF;

   END FOREACH

   END;

   RETURN vcodret;

END PROCEDURE;