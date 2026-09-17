CREATE PROCEDURE "informix".sp_ctas_max_sdo_diario()
RETURNING CHAR(5);

    DEFINE vcodret    CHAR(5);
    DEFINE vcodret2   CHAR(5);
    DEFINE vcodret3   CHAR(80);
    DEFINE vsqlerr    INTEGER;  
    DEFINE visamerr   INTEGER;  
    DEFINE vdescerr   CHAR(80);
    DEFINE vsql       CHAR(600);
    DEFINE vsq2       CHAR(600);
    DEFINE vfecha     DATE; 
    DEFINE vaniomes   CHAR(6);
	DEFINE vaniomes1  CHAR(6);
    DEFINE vdia       CHAR(2);
	DEFINE vdia1      CHAR(2);
	DEFINE pempresa   CHAR(3);
	DEFINE vfecha_hoy DATE;
    DEFINE vctamin    CHAR(20);
    DEFINE vctamax    CHAR(20);
	DEFINE vstatuscierrechq  CHAR(1);
    DEFINE vstatuscierrechq1 CHAR(1);
    DEFINE vstatuscierrechq2 CHAR(1);
    DEFINE vstatuscierrechq3 CHAR(1);
    
    LET vcodret    = "000";
    LET vcodret2   = "";
    LET vcodret3   = "";
    LET vsqlerr    = 0;
    LET visamerr   = 0;
    LET vdescerr   = '';
    LET vsql       = '';
    LET vsq2       = '';
    LET vfecha     = '';
    LET vaniomes   = '';
    LET vaniomes1  = '';
	LET vdia       = '';
	LET vdia1      = '';
	LET pempresa   = '001';
	LET vfecha_hoy = '';
    LET vctamin    = '';
    LET vctamax    = '';
	LET vstatuscierrechq  = '';
    LET vstatuscierrechq1 = '';
    LET vstatuscierrechq2 = '';
    LET vstatuscierrechq3 = '';
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctas_max_sdo_diario.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret  = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctas_max_sdo_diario.out";
    --- TRACE ON;  

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
	SELECT fecha_ant, fecha_hoy
      INTO vfecha, vfecha_hoy
      FROM sc_fechas
     WHERE empresa = "001";
	 
	SELECT status_proc
      INTO vstatuscierrechq
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'sdoschqdes'
       AND fecha   = vfecha_hoy
       AND sistema = '01';
    
    SELECT status_proc
      INTO vstatuscierrechq1
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'sdoschqdescomp1'
       AND fecha   = vfecha_hoy
       AND sistema = '01';
       
    SELECT status_proc
      INTO vstatuscierrechq2
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'sdoschqdescomp2'
       AND fecha   = vfecha_hoy
       AND sistema = '01';
       
    SELECT status_proc
      INTO vstatuscierrechq3
      FROM bdinteg:sx_contproc
     WHERE empresa = pempresa
       AND proceso = 'sdoschqdescomp3'
       AND fecha   = vfecha_hoy
       AND sistema = '01';
    
    IF (vstatuscierrechq  is null OR vstatuscierrechq  <> 'F') OR 
       (vstatuscierrechq1 is null OR vstatuscierrechq1 <> 'F') OR
       (vstatuscierrechq2 is null OR vstatuscierrechq2 <> 'F') OR 
       (vstatuscierrechq3 is null OR vstatuscierrechq3 <> 'F') THEN
        LET vcodret = "959";
        RETURN vcodret;
	END IF;

    LET vdia = SUBSTR(vfecha,4,2);
    LET vdia = vdia;
    LET vaniomes = SUBSTR(vfecha,7,4) || SUBSTR(vfecha,1,2);
    LET vaniomes = vaniomes;
	LET vdia1 = SUBSTR(vfecha_hoy,4,2);
    LET vdia1 = vdia1;
    LET vaniomes1 = SUBSTR(vfecha_hoy,7,4) || SUBSTR(vfecha_hoy,1,2);
    LET vaniomes1 = vaniomes1;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vctamin, vctamax
      FROM sc_maechq;

    IF LPAD(vdia,2,'0') = '01' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig1, c.intprovnp1 '||
                   'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                   'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                   'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia1, c.ipa_dia1 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '02' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig2, c.intprovnp2 '||
                   'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                   'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                   'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia2, c.ipa_dia2 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '03' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig3, c.intprovnp3 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia3, c.ipa_dia3 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
    
    ELIF LPAD(vdia,2,'0') = '04' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig4, c.intprovnp4 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia4, c.ipa_dia4 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '05' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig5, c.intprovnp5 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia5, c.ipa_dia5 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        LET vsq2 = "";
        
    ELIF LPAD(vdia,2,'0') = '06' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig6, c.intprovnp6 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia6, c.ipa_dia6 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '07' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig7, c.intprovnp7 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia7, c.ipa_dia7 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '08' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig8, c.intprovnp8 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia8, c.ipa_dia8 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '09' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig9, c.intprovnp9 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia9, c.ipa_dia9 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '10' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig10, c.intprovnp10 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia10, c.ipa_dia10 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '11' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig11, c.intprovnp11 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia11, c.ipa_dia11 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '12' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig12, c.intprovnp12 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia12, c.ipa_dia12 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '13' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig13, c.intprovnp13 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia13, c.ipa_dia13 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '14' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig14, c.intprovnp14 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia14, c.ipa_dia14 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '15' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig15, c.intprovnp15 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia15, c.ipa_dia15 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
                
    ELIF LPAD(vdia,2,'0') = '16' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig16, c.intprovnp16 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia16, c.ipa_dia16 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '17' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig17, c.intprovnp17 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia17, c.ipa_dia17 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
                
    ELIF LPAD(vdia,2,'0') = '18' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig18, c.intprovnp18 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia18, c.ipa_dia18 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '19' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig19, c.intprovnp19 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia19, c.ipa_dia19 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
                
    ELIF LPAD(vdia,2,'0') = '20' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig20, c.intprovnp20 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia20, c.ipa_dia20 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '21' THEN
        
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig21, c.intprovnp21 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia21, c.ipa_dia21 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '22' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig22, c.intprovnp22 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia22, c.ipa_dia22 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '23' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig23, c.intprovnp23 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia23, c.ipa_dia23 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||   
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '24' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig24, c.intprovnp24 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia24, c.ipa_dia24 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '25' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig25, c.intprovnp25 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia25, c.ipa_dia25 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '26' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig26, c.intprovnp26 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia26, c.ipa_dia26 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '27' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig27, c.intprovnp27 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia27, c.ipa_dia27 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '28' THEN
    
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig28, c.intprovnp28 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia28, c.ipa_dia28 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '29' THEN
    
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig29, c.intprovnp29 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia29, c.ipa_dia29 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '30' THEN
    
        LET vsql = "";
        LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig30, c.intprovnp30 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia30, c.ipa_dia30 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELIF LPAD(vdia,2,'0') = '31' THEN
        
        LET vsql =  ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_V_'||vaniomes1||''||vdia1||'.unl '||
                    'select a.num_cte, a.cuenta, a.producto, b.fecha_ant, c.capvig31, c.intprovnp31 '||
                    'from bdicheq:sc_maechq a, bdicheq:sc_fechas b, bdicheq:sc_sdodiarioc c '||
                    'where a.cuenta between '''||vctamin||''' and '''||vctamax||''' and b.empresa = a.empresa '||
                    'and c.cuenta = a.cuenta and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_v.sql';
        SYSTEM vsql;
        LET vsql = "";
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_v.sql";
        SYSTEM vsql;
        
        LET vsq2 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/saldos_importantes_P_'||vaniomes1||''||vdia1||'.unl '||
                   'select a.num_cte, a.cuenta, a.cod_instrum, b.fecha_ant, c.cv_dia31, c.ipa_dia31 '||
                   'from bdinvers:sv_maeinv a, bdinvers:sv_fechas b, bdinvers:sv_provdia c '||
                   'where a.empresa = '''||pempresa||''' and a.cuenta = c.cuenta and a.secuencia = c.secuencia '||  
                   'and c.aniomes = '''||vaniomes||''';" > /resplogifx/conciliachq/query_saldos_p.sql';
        SYSTEM vsq2;
        LET vsq2 = "";
        LET vsq2 = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/query_saldos_p.sql";
        SYSTEM vsq2;
        
    ELSE
        
        LET vcodret = '200';  
        
    END IF;
    
    END;
    
    RETURN vcodret;
    
END PROCEDURE;