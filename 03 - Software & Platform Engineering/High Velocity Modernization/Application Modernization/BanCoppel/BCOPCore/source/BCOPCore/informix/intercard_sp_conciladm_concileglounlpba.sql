CREATE PROCEDURE "informix".sp_conciladm_concileglounlpba(pempresa char(3), pfecha  date)
RETURNING VARCHAR(5), VARCHAR(255);

--//Definicion de variables
DEFINE vcodret        CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE iSamErr		  INTEGER;
DEFINE cVarDataErr	  VARCHAR(64);

DEFINE vpath    VARCHAR(90);
DEFINE vfile    VARCHAR(255);
DEFINE vfileglo VARCHAR(255);
DEFINE vfilsif  VARCHAR(255);

DEFINE v_sql LVARCHAR(800);

DEFINE v_dia CHAR(2);
DEFINE v_mes CHAR(2);
DEFINE v_ano CHAR(4);



   --Manejo del error
    ON EXCEPTION SET vsqlerr,iSamErr, cVarDataErr
		IF vsqlerr <> 0 then
			LET vcodret = vsqlerr;
			RETURN vcodret, iSamErr || ' ' ||cVarDataErr;
		END IF
    END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   set debug file to "sp_conciladm_concileglounlpba.out";
   trace on;

    --//Inicializacion de variables
   LET vcodret    = "000";
   LET vpath = '/home/sysconau/conciliacion/eglobal';
   LET vfile = '';
   LET vfileglo = '';
   LET vfilsif = '';
   LET v_sql = '';

   IF pempresa ="" OR pfecha ="" THEN
      LET vcodret = "110";
      RETURN vcodret,"FALTAN PARAMETROS";
   END IF

   LET v_dia = DAY(pfecha);
   LET v_mes = LPAD(MONTH(pfecha),2,'0');
   LET v_ano = YEAR(pfecha);


	SELECT TRIM(valor) INTO vpath FROM intercard:param_conciliacionauto WHERE keyx= 1; --'REP_EGLOBAL_AIX'

	LET vfile = vpath||"/conciladm_eglopos_"||v_dia||v_mes||v_ano||".unl" ;

	LET v_sql = "rm -f " || TRIM(vfile) || ".gz"  ;
    SYSTEM v_sql;

---                                                                                                   1                                                                                                   2         1         2         3                                                                     3         1         2         3
---1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
---LET v_sql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || (vfile) || ' SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * ' || ' FROM intercard:conciladm_eglopos ' || ' WHERE fecha_mov_s=' ||pfecha|| ' AND fecha_mov_s IS NOT NULL ' || ' AND fecha_mov_e IS NOT NULL ' || ' ORDER BY secuencia_e, nro_tarjeta_e ASC'" >   || vpath ||  "/query.sql" ';
LET v_sql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO || trim(vfile) || SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * FROM intercard:conciladm_eglopos WHERE fecha_mov_s= ||pfecha|| AND fecha_mov_s IS NOT NULL  AND fecha_mov_e IS NOT NULL  ORDER BY secuencia_e, nro_tarjeta_e ASC" >   /home/sysconau/conciliacion/eglobal/query2.sql"';

--- LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || '''  ' || trim(vfile) || '  ''' ||
                                ---' SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * FROM intercard:conciladm_eglopos' ||
                                ---' WHERE fecha_mov_s=' || '''  " || pfecha || "  ''' ||
                                ---' AND fecha_mov_s IS NOT NULL ' ||
                                ---' AND fecha_mov_e IS NOT NULL ' ||
                                ---' ORDER BY secuencia_e, nro_tarjeta_e ASC; ' ||
                                ---' " >  /home/sysconau/conciliacion/eglobal/query2.sql';



	SYSTEM v_sql;
    ---LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    ---LET v_sql = "ls -l " || vpath || "/query2.sql ";
    SYSTEM v_sql;


	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfile) ||  '_tmp1' ||
				      " SELECT {+INDEX(conciladm_eglopos idx04conciladm_eglopos)} * " ||
                      " FROM intercard:conciladm_eglopos " ||
	                  " WHERE fecha_mov_e='" || pfecha || "'" ||
                      " AND fecha_mov_s IS NULL " ||
                      " ORDER BY tipo_mov_e,importe_e,nro_tarjeta_e ASC"" > " || vpath || "/query.sql";

	SYSTEM v_sql;
    LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfile) || '_tmp2' ||
	                  " SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * " ||
                      " FROM intercard:conciladm_eglopos " ||
					  " WHERE fecha_mov_s='" || pfecha || "'" ||
					  " AND fecha_mov_e IS NULL " ||
	                  " ORDER BY importe_s,nro_tarjeta_s ASC"" > " || vpath || "/query.sql";

	SYSTEM v_sql;
    LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    SYSTEM v_sql;

    LET v_sql = "cat " || TRIM(vfile) ||  '_tmp1' || " >> " || TRIM(vfile);
    SYSTEM v_sql;

    LET v_sql = "cat " || TRIM(vfile) ||  '_tmp2' || " >> " || TRIM(vfile);
    SYSTEM v_sql;

	LET vfileglo = vpath || "/conciladm_archeglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfileglo) || 
                      " SELECT  * FROM intercard:conciladm_archegloposacum WHERE fecha_mov=' " || pfecha || "'"">" || vpath || "/query.sql";

	SYSTEM v_sql;
    LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    SYSTEM v_sql;

	LET vfilsif = vpath || "/conciladm_sifeglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfilsif) || 
                      " SELECT  * FROM intercard:conciladm_sifegloposacum WHERE fecha_mov=' " || pfecha || "'"">" || vpath || "/query.sql";

	SYSTEM v_sql;
    LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    SYSTEM v_sql;

	LET v_sql = "tar cvf - " || TRIM(vfile) || " " || TRIM(vfileglo) || " " || TRIM(vfilsif) || 
                " | gzip > " || vpath || "/conciladm_eglopos_" || v_dia||v_mes||v_ano|| ".tar.gz" ;

    SYSTEM v_sql;

    LET v_sql = "rm -f " || TRIM(vfile) ||  '_tmp1' || " " || TRIM(vfile) ||  '_tmp2'  || " " || TRIM(vfile) 
						 || " " || TRIM(vfileglo) || " " || TRIM(vfilsif)  ;
    SYSTEM v_sql;


	RETURN vcodret,"PROCESO EXITOSO";

END PROCEDURE;