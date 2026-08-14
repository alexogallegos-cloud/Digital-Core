CREATE PROCEDURE "informix".sp_conciladm_concileglounl( pempresa char(3),
										                pfecha   date)
RETURNING VARCHAR(5), VARCHAR(255);

--//Definicion de variables
DEFINE vcodret        CHAR(5);
DEFINE vsqlerr        INTEGER;
DEFINE iSamErr		  INTEGER;
DEFINE cVarDataErr	  VARCHAR(64);

DEFINE vpath     VARCHAR(90);
DEFINE vfile     VARCHAR(255);
DEFINE vfile_tar VARCHAR(255);
DEFINE vfileglo  VARCHAR(255);
DEFINE vfilsif   VARCHAR(255);

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

   --set debug file to "sp_conciladm_concileglounl.out";
   --trace on;

    --//Inicializacion de variables
   LET vcodret    = '000';
   LET vpath = '';
   LET vfile = '';
   LET vfile_tar = '';
   LET vfileglo = '';
   LET vfilsif = '';
   LET v_sql = '';

   IF pempresa ="" OR pfecha ="" THEN
      LET vcodret = '110';
      RETURN vcodret,'FALTAN PARAMETROS';
   END IF

   LET v_dia = LPAD(DAY(pfecha),2,'0');
   LET v_mes = LPAD(MONTH(pfecha),2,'0');
   LET v_ano = YEAR(pfecha);

	SELECT TRIM(valor) INTO vpath FROM intercard:param_conciliacionauto WHERE keyx= 1; --'REP_EGLOBAL_AIX'

	LET vfile = TRIM(vpath) || '/conciladm_eglopos_'|| v_dia||v_mes||v_ano|| '.unl';

	LET vfile_tar = TRIM(vpath) || '/conciladm_eglopos_'|| v_dia||v_mes||v_ano ;

	LET v_sql = 'rm -f ' || TRIM(vfile_tar) || '.tar.gz';
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;' || '" > ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "UNLOAD TO ' || TRIM(vfile) || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "FROM intercard:conciladm_eglopos ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo "WHERE fecha_mov_s=''' || pfecha || '''' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "AND fecha_mov_s IS NOT NULL ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "AND fecha_mov_e IS NOT NULL ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo "ORDER BY secuencia_e,nro_tarjeta_e ASC; ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;

    LET v_sql = 'dbaccess intercard ' || vpath || '/query.sql';
    SYSTEM v_sql;
	
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;' || '" > ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "UNLOAD TO ' || TRIM(vfile) ||  '_tmp1' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciladm_eglopos idx04conciladm_eglopos)} * ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo "FROM intercard:conciladm_eglopos ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "WHERE fecha_mov_e=''' || pfecha || '''' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo "AND fecha_mov_s IS NULL ' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo "ORDER BY tipo_mov_e,importe_e,nro_tarjeta_e ASC; '  || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;

    LET v_sql = 'dbaccess intercard ' || vpath || '/query.sql';
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;' || '" > ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "UNLOAD TO ' || TRIM(vfile) ||  '_tmp2' || '" >> ' || vpath || '/query.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciladm_eglopos idx05conciladm_eglopos)} * ' || '" >> ' || vpath || '/query.sql';
    SYSTEM v_sql;
    LET v_sql = 'echo "FROM intercard:conciladm_eglopos ' || '" >> ' || vpath || '/query.sql';
    SYSTEM v_sql;
	LET v_sql = 'echo "WHERE fecha_mov_s='''  || pfecha || '''' || '" >> ' || vpath || '/query.sql';
    SYSTEM v_sql;
	LET v_sql = 'echo "AND fecha_mov_e IS NULL ' || '" >> ' || vpath || '/query.sql';
    SYSTEM v_sql;
    LET v_sql = 'echo "ORDER BY importe_s,nro_tarjeta_s ASC; '  || '" >> ' || vpath || '/query.sql';
    SYSTEM v_sql;

    LET v_sql = "dbaccess intercard " || vpath || "/query.sql";
    SYSTEM v_sql;

    LET v_sql = "cat " || TRIM(vfile) ||  '_tmp1' || " >> " || TRIM(vfile);
    SYSTEM v_sql;

    LET v_sql = "cat " || TRIM(vfile) ||  '_tmp2' || " >> " || TRIM(vfile);
    SYSTEM v_sql;

	LET vfileglo = vpath || "/conciladm_archeglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfileglo) || 
                      " SELECT  * FROM intercard:conciladm_archegloposacum WHERE fecha_mov=' " || pfecha || "'"">" || vpath || '/query.sql';

	SYSTEM v_sql;
    LET v_sql = 'dbaccess intercard ' || vpath || '/query.sql';
    SYSTEM v_sql;

	LET vfilsif = vpath || "/conciladm_sifeglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfilsif) || 
                      " SELECT  * FROM intercard:conciladm_sifegloposacum WHERE fecha_mov=' " || pfecha || "'"">" || vpath || '/query.sql';

	SYSTEM v_sql;
    LET v_sql = 'dbaccess intercard ' || vpath || '/query.sql';
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfile) ||  '_tmp1';
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfile) ||  '_tmp2';
    SYSTEM v_sql;

    LET v_sql = 'ls ' || TRIM(vpath) ||'/conciladm_*' || v_dia || v_mes|| v_ano || '.*' || ' > ' || TRIM(vpath) || '/fl_list';
    SYSTEM v_sql;

    LET v_sql = 'tar -cvf ' || TRIM(vfile_tar) || '.tar' ||' -L '||  TRIM(vpath) || '/fl_list';
    SYSTEM v_sql;

    LET v_sql = 'gzip -9 ' || TRIM(vfile_tar) || ".tar"  ;
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfile) ;
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfileglo);
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfilsif);
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vpath) || '/query.sql';
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vpath) || '/fl_list';
    SYSTEM v_sql;
	
	LET v_sql = 'rm -f ' || TRIM(vpath) || '/Exec_sp_conciladm_paserarchivo.sql';
    SYSTEM v_sql;
	
	LET v_sql = 'rm -f ' || TRIM(vpath) || '/file.bus';
    SYSTEM v_sql;
	
	LET v_sql = 'rm -f ' || TRIM(vpath) || '/parser.unl';
    SYSTEM v_sql;
	
	LET v_sql = 'rm -f ' || TRIM(vpath) || '/*.prs';
    SYSTEM v_sql;
	
	RETURN vcodret,"PROCESO EXITOSO";

END PROCEDURE;