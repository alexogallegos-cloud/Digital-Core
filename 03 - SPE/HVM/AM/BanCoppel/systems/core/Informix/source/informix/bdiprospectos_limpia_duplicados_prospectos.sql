CREATE PROCEDURE "informix".limpia_duplicados_prospectos()
RETURNING VARCHAR(10) AS p_cod_ret, 
			VARCHAR(80) AS p_mensaje

DEFINE  p_cod_ret       VARCHAR(10);
DEFINE	p_mensaje       VARCHAR(80);

DEFINE 	sql_err   	  	INTEGER;
DEFINE 	isam_err		INTEGER;
DEFINE 	error_info  	VARCHAR(80);
DEFINE 	vcadena     	INTEGER;
DEFINE 	vSucOri     	CHAR(4);
DEFINE 	strnumcte		varchar(10);
DEFINE 	dfecha_hora		DATE;
DEFINE  dfecha_hora2	DATE;

--DECLARACION DE VARIABLES DE ERROR
LET sql_err = 0;
LET isam_err = 0;
LET error_info = 'PROCESO EXITOSO';
LET vcadena = 0;
LET vSucOri = '';
LET strnumcte = '';
LET dfecha_hora = '';
LET dfecha_hora2 = '';


/*********************************************************
	Author: JOSE ALEJANDRO HERNANDEZ JIMENEZ
	Fecha : 15/11/2022
	Observaciones:  Detecta registros duplicados en bdiprospectos.prcliente
		Elimina registros que esten duplicandos dejando solo el mas reciente.
		OPTIMIZATION 24/11/2022
 *******************************************************/

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET p_cod_ret  = sql_err;
        LET p_mensaje  = error_info;
        RETURN p_cod_ret,p_mensaje;
    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	

	Create temp table tmp_duplicados
						(numcte  char(9),
						primary key (numcte))with no log;
	
	INSERT INTO tmp_duplicados
	SELECT  numcte
		FROM "informix".pr_cliente
	WHERE  (trim(numcte) is not null and  trim(numcte) <> '')  			
	GROUP BY  numcte
	HAVING COUNT(numcte) >=2;


   FOREACH cur1 FOR SELECT numcte INTO strnumcte 
						FROM tmp_duplicados
		SELECT 
			 min(a.fecha_hora)
			,max(a.fecha_hora)
		INTO dfecha_hora,
			dfecha_hora2
			FROM "informix".pr_cliente a
			INNER JOIN tmp_duplicados b ON a.numcte = b.numcte
		WHERE b.numcte = strnumcte
		GROUP BY a.numcte;

		DELETE "informix".pr_cliente 
		WHERE numcte = strnumcte 
			AND (fecha_hora >= dfecha_hora 
			AND  fecha_hora < dfecha_hora2);
			
		 CONTINUE FOREACH;
		 
   END FOREACH

	LET p_cod_ret      = '000';
	LET p_mensaje      = 'PROCESO EXITOSO';
		
	drop table tmp_duplicados;
	
    RETURN p_cod_ret,p_mensaje;

END

END PROCEDURE
;