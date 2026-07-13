CREATE PROCEDURE "informix".sp_conciladm_concileglounl_pba( pempresa char(3),
										                pfecha   date)
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

   --set debug file to "sp_conciladm_concileglounl_pba.out";
   --trace on;

    --//Inicializacion de variables
   LET vcodret    = "000";
   LET vpath = '';
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

	LET vfile = TRIM(vpath) || "/conciladm_eglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;

	LET v_sql = "rm -f " || TRIM(vfile) || ".gz"  ;
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || vfile || '" > ' || vpath || "/query.sql";
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
	LET v_sql = 'echo "FROM intercard:conciladm_eglopos ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
    LET v_sql = 'echo "WHERE fecha_mov_s=''' || pfecha || '''' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
	LET v_sql = 'echo "AND fecha_mov_s IS NOT NULL ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
	LET v_sql = 'echo "AND fecha_mov_e IS NOT NULL ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
    LET v_sql = 'echo "ORDER BY secuencia_e,nro_tarjeta_e ASC; ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;

    LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || vfile ||  '_tmp1' || '" > ' || vpath || "/query.sql";
    SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciladm_eglopos idx04conciladm_eglopos)} * ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
    LET v_sql = 'echo "FROM intercard:conciladm_eglopos ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
	LET v_sql = 'echo "WHERE fecha_mov_e=''' || pfecha || '''' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
    LET v_sql = 'echo "AND fecha_mov_s IS NULL ' || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;
    LET v_sql = 'echo "ORDER BY tipo_mov_e,importe_e,nro_tarjeta_e ASC; '  || '" >> ' || vpath || "/query.sql";
	SYSTEM v_sql;

    LET v_sql = "dbaccess intercard " || vpath || "/query.sql ";
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfile) || '_tmp2' || '" > ' || vpath || "/query.sql";
    SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * ' || '" >> ' || vpath || "/query.sql";
    SYSTEM v_sql;
    LET v_sql = 'echo "FROM intercard:conciladm_eglopos ' || '" >> ' || vpath || "/query.sql";
    SYSTEM v_sql;
	LET v_sql = 'echo "WHERE fecha_mov_s='''  || pfecha || '''' || '" >> ' || vpath || "/query.sql";
    SYSTEM v_sql;
	LET v_sql = 'echo "AND fecha_mov_e IS NULL ' || '" >> ' || vpath || "/query.sql";
    SYSTEM v_sql;
    LET v_sql = 'echo "ORDER BY importe_s,nro_tarjeta_s ASC; '  || '" >> ' || vpath || "/query.sql";
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