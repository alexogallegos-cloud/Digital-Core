CREATE PROCEDURE "informix".sp_concilatm_concileglounl( pempresa char(3),pfecha   date)
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
DEFINE v_idia CHAR(2);
DEFINE v_imes CHAR(2);
DEFINE v_iano CHAR(4);
DEFINE vfecha_param     		CHAR(8);
DEFINE vfecha_param_menos 		CHAR(8);
DEFINE pfecha_menos       		DATE;
DEFINE pfecha_char      		CHAR(10);
DEFINE vfecha_p                 CHAR(4);
DEFINE vfecha_p_me              CHAR(4);
	--Manejo del error
		ON EXCEPTION SET vsqlerr,iSamErr, cVarDataErr
			IF vsqlerr <> 0 then
				LET vcodret = vsqlerr;
				RETURN vcodret, iSamErr || ' ' ||cVarDataErr;
			END IF
		END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--set debug file to "/tmp/sp_concilatm_concileglounl.out";
	--trace on;
	
		--//Inicializacion de variables
	LET vcodret    = '000';
	LET vpath = '';
	LET vfile = '';
	LET vfile_tar = '';
	LET vfileglo = '';
	LET vfilsif = '';
	LET v_sql = '';
	LET vfecha_param = '';
	LET pfecha_menos = '';
	LET pfecha_char      	  ='';
	LET vfecha_p  			  ='';
	LET vfecha_p_me           ='';
	
	IF pempresa ="" OR pfecha ="" THEN
		LET vcodret = '110';
		RETURN vcodret,'FALTAN PARAMETROS';
	END IF
	
	
	LET v_dia = LPAD(DAY(pfecha),2,'0');   
	LET v_mes = LPAD(MONTH(pfecha),2,'0');
	LET v_ano = YEAR(pfecha);
	
	
	IF v_dia = 01 and  v_mes = 01 THEN
		LET pfecha_menos = 12||"/"||LPAD(DAY(pfecha - 1) ,2,0)||"/"||YEAR(pFecha) -1;   
	ELIF v_dia = 01 AND v_dia <> 01 THEN
		LET pfecha_menos = LPAD(MONTH(pfecha) -1,2,0)||"/"||LPAD(DAY(pfecha - 1) ,2,0)||"/"||YEAR(pFecha);   
	ELSE                           
		LET pfecha_menos = MDY(v_mes,v_dia,v_ano) -1;		
                           
	END IF 
	
	LET v_idia = LPAD(DAY(pfecha_menos),2,'0');   
	LET v_imes = LPAD(MONTH(pfecha_menos),2,'0');
	LET v_iano = YEAR(pfecha_menos);
	LET pfecha_char = pfecha;
   
   	LET vfecha_param     = LPAD(v_dia,2,0)||"/"||LPAD(v_mes,2,0)||"/"||LPAD(substr(v_ano,3,2),2,0);
   	LET vfecha_param_menos = LPAD(v_idia,2,0)||"/"||LPAD(v_imes,2,0)||"/"||LPAD(substr(v_iano,3,2),2,0);	
	LET vfecha_p         = v_mes||v_dia;
	LET vfecha_p_me      = v_imes||v_idia;
	SELECT TRIM(valor) INTO vpath FROM intercard:param_conciliacionauto WHERE keyx= 1; --'REP_EGLOBAL_AIX'

	LET vfile = TRIM(vpath) || '/concilatm_eglopos_'|| v_dia||v_mes||v_ano|| '.unl';

	LET vfile_tar = TRIM(vpath) || '/concilatm_eglopos_'|| v_dia||v_mes||v_ano ;

	LET v_sql = 'rm -f ' || TRIM(vfile_tar) || '.tar.gz';
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;' || '" > ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "UNLOAD TO ' || TRIM(vfile) || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciliacion_atm_es idx05conciliacion_atm_es)} * ' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "  FROM intercard:conciliacion_atm_es ' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo " WHERE fecha_s >=''' || vfecha_param_menos|| '''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "   AND fecha_s <=''' || vfecha_param   || '''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "   AND monto_s <>  0'     || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;	
	LET v_sql = 'echo "   AND fecha_s <> ''''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "   AND fecha_e <> ''''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo " ORDER BY secuenciaut_e,numtarjeta_e ASC; ' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;

    LET v_sql = 'dbaccess intercard ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;
	
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;' || '" > ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "UNLOAD TO ' || TRIM(vfile) ||  '_tmp1' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciliacion_atm_es idx04conciliacion_atm_es)} * ' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo "  FROM intercard:conciliacion_atm_es  ' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo " WHERE fecha_e >= ''' || vfecha_param_menos || '''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "   AND fecha_e <= ''' || vfecha_param || '''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;	
    LET v_sql = 'echo "   AND fecha_s  = ''''' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
    LET v_sql = 'echo " ORDER BY indicadordereversa_e,secuenciaut_e,monto_e,numtarjeta_e ASC; '  || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;

	
    LET v_sql = 'dbaccess intercard ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ;' || '" > ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "UNLOAD TO ' || TRIM(vfile) ||  '_tmp2' || '" >> ' || vpath || '/queryatm.sql';
	SYSTEM v_sql;
	LET v_sql = 'echo "SELECT {+INDEX(conciliacion_atm_es idx05conciliacion_atm_es)} * ' || '" >> ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;
    LET v_sql = 'echo "  FROM intercard:conciliacion_atm_es ' || '" >> ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;
	LET v_sql = 'echo " WHERE fecha_s >= '''  || vfecha_param_menos || '''' || '" >> ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;
	LET v_sql = 'echo "   AND fecha_s <= '''  || vfecha_param || '''' || '" >> ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;	
	LET v_sql = 'echo "   AND fecha_e  = '''''  || '" >> ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;
    LET v_sql = 'echo " ORDER BY secuenciaut_e,monto_s,numtarjeta_s ASC; '  || '" >> ' || vpath || '/queryatm.sql';
    SYSTEM v_sql;

    LET v_sql = "dbaccess intercard " || vpath || "/queryatm.sql";
    SYSTEM v_sql;

    LET v_sql = "cat " || TRIM(vfile) ||  '_tmp1' || " >> " || TRIM(vfile);
    SYSTEM v_sql;

    LET v_sql = "cat " || TRIM(vfile) ||  '_tmp2' || " >> " || TRIM(vfile);
    SYSTEM v_sql;

	LET vfileglo = vpath || "/concilatm_archeglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;

	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfileglo) || 
                      " SELECT  * FROM intercard:concilatm_archegloposacum WHERE fecha_mov>='"|| vfecha_param_menos || "'and fecha_mov<='"|| vfecha_param || "';"">" || vpath || '/queryatm.sql';  
	
	SYSTEM v_sql;
    LET v_sql = 'dbaccess intercard '|| vpath || '/queryatm.sql';
    SYSTEM v_sql;
	
	LET vfilsif = vpath || "/concilatm_sifeglopos_"||
                       v_dia||v_mes||v_ano|| ".unl" ;
					   
	LET v_sql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(vfilsif) ||                                              
                      " SELECT  * FROM intercard:concilatm_sifegloposacum WHERE fecha_mov>='"|| vfecha_p_me ||"' and fecha_mov <= '"|| vfecha_p ||"';"">"  || vpath || '/queryatm.sql';
	
	SYSTEM v_sql;
    LET v_sql =  "dbaccess intercard "|| vpath || "/queryatm.sql";	    
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfile) ||  '_tmp1';
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfile) ||  '_tmp2';
    SYSTEM v_sql;

    LET v_sql = 'ls ' || TRIM(vpath) ||'/concilatm_*' || v_dia || v_mes|| v_ano || '.*' || ' > ' || TRIM(vpath) || '/fl_listatm';
    SYSTEM v_sql;

    LET v_sql = 'tar -cvf ' || TRIM(vfile_tar) || '.tar' ||' -L '||  TRIM(vpath) || '/fl_listatm';
    SYSTEM v_sql;

    LET v_sql = 'gzip -9 ' || TRIM(vfile_tar) || ".tar"  ;
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfile) ;
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfileglo);
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vfilsif);
    SYSTEM v_sql;

    LET v_sql = 'rm -f ' || TRIM(vpath) || '/queryatm.sql';
    SYSTEM v_sql;
	
    LET v_sql = 'rm -f ' || TRIM(vpath) || '/fl_listatm';
    SYSTEM v_sql;

	LET v_sql = 'rm -f ' || TRIM(vpath) || '/parserATM.unl';
    SYSTEM v_sql;
	
	LET v_sql = 'rm -f ' || TRIM(vpath) || '/*.prst';
    SYSTEM v_sql;	
	
	RETURN vcodret,"PROCESO EXITOSO";

END PROCEDURE;