CREATE PROCEDURE "informix".sp_monitor_folio()
RETURNING CHAR(5);
--Declaracion de variables
DEFINE vcodret           CHAR(5);
DEFINE vcodretdet        CHAR(5);
DEFINE iSecuencia        INTEGER;
DEFINE iSqlErr           INTEGER;
DEFINE sid               INTEGER;
DEFINE snumcte           CHAR(20);
DEFINE sfolio            CHAR(12);
DEFINE sstatus_valua     INTEGER;
DEFINE sempresa          CHAR(3);
DEFINE svalor_param      INTEGER;
DEFINE svalor_param2     INTEGER;
DEFINE svalor_param3     CHAR(12);
DEFINE sfecha_insert     DATE;
DEFINE svt_consecu       FLOAT;
DEFINE svt_base1         CHAR(10);
DEFINE svt_base2         CHAR(4);
DEFINE svt_fecha_hoy     CHAR(10);
DEFINE svt_year          CHAR(4);
DEFINE svt_mes           CHAR(2);
DEFINE svt_dia           CHAR(2);
DEFINE svt_fecha_opera   CHAR(6);
DEFINE svt_cosec_deta    CHAR(4);
DEFINE svt_fecha_opera2  CHAR(10);
DEFINE svt_cuantos       INTEGER;
DEFINE svt_bandera       INTEGER;
DEFINE svt_FechaInsercion CHAR(19);
DEFINE svt_segundos      CHAR(2);
DEFINE svt_minutos       CHAR(2);
DEFINE svte_segundos     INTEGER;
DEFINE svte_minutos      INTEGER;
DEFINE vt_fech_hora      CHAR(19);
DEFINE CsubConsec		 CHAR(4);


--Inicializacion de variables

LET vcodret              = '000';
LET vcodretdet           = "000";
LET iSecuencia           = 0;
LET sid                  = 0;
LET snumcte              = "";
LET sfolio               = "";
LET sstatus_valua        = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET svalor_param2        = 0;
LET sfecha_insert        = "";
LET svt_consecu          = 0;
LET sempresa             = "";
LET svalor_param         = 0;
LET svt_base1            = "";
LET svt_base2            = "";
LET svt_fecha_hoy        = "";
LET svt_year             = "";
LET svt_mes              = "";
LET svt_dia              = "";
LET svt_fecha_opera      = "";
LET svalor_param3        = "";
LET svt_cosec_deta       = "";
LET svt_fecha_opera2     = "";
LET svt_cuantos          = 0;
LET svt_bandera          = 0;
LET svt_segundos         = " ";
LET svt_minutos          = " ";
LET svte_segundos        = 0;
LET svte_minutos         = 0;
LET CsubConsec			 =0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;
--SET debug FILE TO '/informix/VH/PM/sp_monitor_folio.out';
--TRACE ON;

BEGIN
	 ON EXCEPTION SET iSqlErr
		 IF iSqlErr <> 0 THEN
		LET vcodret = iSqlErr;
		RETURN vCodret;
		END IF;
	 END EXCEPTION

	SELECT MIN(empresa)
	INTO sempresa
	FROM si_empresas;

	SELECT fecha_hoy INTO svt_fecha_hoy
	FROM si_fechas
	WHERE empresa = sempresa;

	SELECT MAX(valor) INTO svalor_param
	FROM si_param
	where empresa = sempresa
	AND cod_param = "341";

	SELECT valor INTO svt_fecha_opera2
	FROM si_param
	where empresa = sempresa
	AND cod_param = "342";

	--Valida dia de operacion
	IF svt_fecha_hoy != svt_fecha_opera2 THEN

	   LET svt_fecha_opera2 = svt_fecha_hoy;
	   LET svalor_param    = "0";

	   --Actualiza e Valor en la tabla de parametros.
	   UPDATE si_param
	   SET(valor)=(svt_fecha_opera2)
	   WHERE empresa = sempresa
	   AND cod_param = "342";

	   UPDATE si_param
	   SET(valor)=(svalor_param)
	   WHERE empresa = sempresa
	   AND cod_param = "341";

	END IF;


	LET svt_year = svt_fecha_hoy[9,10];
	LET svt_mes  = svt_fecha_hoy[1,2];
	LET svt_dia  = svt_fecha_hoy[4,5];

	LET svt_fecha_opera = TRIM(svt_dia)||''||TRIM(svt_mes)||''||TRIM(svt_year);


   ---Ejecuta Cursor principal para revisar numero de folio para solicitud movil
	 FOREACH
			SELECT id, numcte, folio,status_valua,fecha_insert
			INTO sid, snumcte,sfolio,sstatus_valua,sfecha_insert
			FROM bdinteg:si_solicitud_movil
			WHERE bdinteg:si_solicitud_movil.folio_procesado = "0"
			AND bdinteg:si_solicitud_movil.status_valua = 0
			AND folio IS NULL
			ORDER BY id

			--Actualiza el valor del parametro
			IF svalor_param = 0 THEN
			   LET svalor_param = 1;
			ELSE
			   LET svalor_param = svalor_param + 1;
			END IF;

			---Arma el Nuevo Folio
			LET svt_consecu=0;
			WHILE svt_consecu<10000
				CALL sp_random() RETURNING svt_consecu;

				LET CsubConsec=SUBSTR(svt_consecu,1,4);

				IF EXISTS (SELECT numcte FROM si_solicitud_movil WHERE SUBSTR(folio,7,4)=SUBSTR(CsubConsec,1,4) and fecha_insert=svt_fecha_hoy) THEN
				   LET svt_consecu=0;
				END IF;

			END WHILE;    
			--LET svalor_param=svalor_param;

			IF LENGTH(CsubConsec)=3 THEN
			  LET CsubConsec='0'||CsubConsec;
			ELIF LENGTH(CsubConsec)=2 THEN
			  LET CsubConsec='00'||CsubConsec;
			ELIF LENGTH(CsubConsec)=1 THEN
			  LET CsubConsec='000'||CsubConsec;
			ELIF LENGTH(CsubConsec)=0 THEN
			  LET CsubConsec='0000';  
			END IF;


			IF LENGTH(svalor_param::CHAR(4))=4 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,2);
			ELIF LENGTH(svalor_param::CHAR(4))=3 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,3);
			ELIF LENGTH(svalor_param::CHAR(4))=2 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			ELIF LENGTH(svalor_param::CHAR(4))=1 THEN
				LET svt_cosec_deta = '0'||svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			END IF


			LET svalor_param3 = TRIM(svt_fecha_opera)||''||TRIM(svt_base2)||''||TRIM(svt_cosec_deta);

		   ---Valida si ya existe el folio
			SELECT count(*) INTO svt_cuantos
			FROM si_solicitud_movil
			WHERE folio = svalor_param3;

			IF svt_cuantos > 0 THEN
				IF svalor_param = 0 THEN
					LET svalor_param = 1;
				ELSE
				   LET svalor_param = svalor_param + 1;
				END IF;

			IF LENGTH(svalor_param::CHAR(4))=4 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,2);
			ELIF LENGTH(svalor_param::CHAR(4))=3 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,3);
			ELIF LENGTH(svalor_param::CHAR(4))=2 THEN
				LET svt_cosec_deta = svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			ELIF LENGTH(svalor_param::CHAR(4))=1 THEN
				LET svt_cosec_deta = '0'||svalor_param;
				LET svt_base2=SUBSTR(CsubConsec,1,4);
			END IF

				LET svalor_param3 = TRIM(svt_fecha_opera)||''||TRIM(svt_base2)||''||TRIM(svt_cosec_deta);
			END IF;


			SELECT DBINFO('utc_to_datetime',sh_curtime) INTO vt_fech_hora
			FROM sysmaster:"informix".sysshmvals;

			--Actualiza el numero de folio del nuevo registro
			UPDATE si_solicitud_movil
			SET(folio,fecha_folio)=(svalor_param3,vt_fech_hora)
			WHERE id = sid;

			--LET svt_bandera = 1;

		  UPDATE si_param
		  SET(valor)=(svalor_param)
		  WHERE empresa = sempresa
		  AND cod_param = "341";

	 END FOREACH;

RETURN vcodret;
END;
END PROCEDURE
;