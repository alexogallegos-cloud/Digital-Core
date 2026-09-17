CREATE PROCEDURE "informix".spregresahuellac_per( ptipo CHAR(1), pnumcte CHAR(20), pfechaini DATE, pfechafin DATE )
RETURNING INTEGER, char(20), SMALLINT, CHAR(1), CHAR(942), CHAR(942), CHAR(8), CHAR(4), DATE, CHAR(8), DATE, CHAR(1), char(20);

    define vcodret INTEGER;
    define vcodret2 INTEGER;
    define vcodret3 CHAR(40);
    define vexiste CHAR(1);
    define vsqlerr INTEGER;
    define visamerr INTEGER;
    define vinfoerr CHAR(40);

    define vcliente char(20);
    define vsecuencia smallint ;
    define vstatus char(1);
    define vmapad  char(942);
    define vmapai  char(942);
    define vusuario char(8);
    define vsucursal char(4);
    define vfechaalta date ;
    define vusuariocambio char(8);
    define vfechacambio date ;
    define vsexo char(1);
    define vclienteref char(20);
    define vfecha_hoy date;
    
    --- SET DEBUG FILE TO "/tmp/spregresahuellac.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr,visamerr,vinfoerr
        IF vsqlerr != 0 THEN
            --SET DEBUG FILE TO "/resplogifx/conciliachq/spregresahuellac.err";
            --TRACE ON;
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vinfoerr;
            RETURN vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref;
        END IF;
    END EXCEPTION;

    LET vcodret = 1;
    LET vcodret2 = 0;
    LET vcodret3 = '';
    LET vexiste = 0;

    LET vcliente = '';
    LET vsecuencia = 0;
    LET vstatus = '';
    LET vmapad = '';
    LET vmapai = '';
    LET vusuario = '';
    LET vsucursal = '';
    LET vfechaalta = '';
    LET vusuariocambio = '';
    LET vfechacambio = '';
    LET vsexo = '';
    LET vclienteref = '';

    set isolation to dirty read;

    /* Verifica recepcion correcta de datos */
    if ptipo is null or Trim(ptipo) = '' then
        let vcodret = 110;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    elif pfechaini is null  then
        let vcodret = 120;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    elif pfechafin is null  then
        let vcodret = 130;
        return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref ;
    end if;
    
    create temp table tmp_huellas_ctes(
        numcte          char(20),
        secuencia       smallint,
        estado          char(1),
        dmapa           char(942),
        imapa           char(942),
        usuario         char(8),
        sucursal        char(4),
        fecha_alta      date,
        usuario_camb    char(8),
        fecha_camb      date,
        sexo            char(1),
        numcte_ref      char(20)   
    ) with no log;

--A PETICION DE BASE DE DATOS SE COMENTAN INDICES	
--begin;
    --create index idx_fecalta_tmp on tmp_huellas_ctes(fecha_alta) online;
--commit;
--begin;
    --create index idx_feccamb_tmp on tmp_huellas_ctes(fecha_camb) online;
--commit;
    --update statistics medium for table tmp_huellas_ctes(fecha_alta,fecha_camb) resolution 1.5;
    
    select fecha_hoy
      into vfecha_hoy
      from si_fechas
     where empresa = '001';
    
    -- // POR FECHA DE ALTA
    if ptipo = '1' then
        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue2)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''), 
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_alta > pfechaini
               and ch.fecha_alta <= vfecha_hoy

            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0') 
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert > pfechaini
               and sol.fecha_insert <= vfecha_hoy
            
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''), 
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);

            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0') 
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // INACTIVAS
    elif ptipo = '2' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue3)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_camb >= pfechaini 
               and ch.fecha_camb <= vfecha_hoy
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini
               and sol.fecha_insert <= vfecha_hoy
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // POR CLIENTE
    elif ptipo = '3' then

        foreach
            select nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = trim(pnumcte)
               and ch.estado = "A"
               
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
             
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    -- // ENTRE FECHAS
    elif ptipo = '4' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue2)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_alta >= pfechaini 
               and ch.fecha_alta <= pfechafin
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini
               and sol.fecha_insert <= pfechafin
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
    -- // INACTIVAS ENTRE FECHAS
    elif ptipo = '5' then

        foreach
            select {+INDEX(si_cte_huella idx_si_cte_hue3)}
                   nvl(ch.numcte,''), nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.fecha_camb >= pfechaini 
               and ch.fecha_camb <= pfechafin
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;
        
        foreach
            select {+INDEX(bdisolic:ss_solicitudes ix_soln4)}
                   sol.numcte
              into vcliente
              from bdisolic:ss_solicitudes sol
             where sol.fecha_insert >= pfechaini 
               and sol.fecha_insert <= pfechafin
        
            select {+INDEX(si_cte_huella ix_huellanew)}
                   nvl(ch.secuencia,0), nvl(ch.estado,''), nvl(ch.dmapa,''), nvl(ch.imapa,''), nvl(ch.usuario,''),
                   nvl(ch.sucursal,''), nvl(ch.fecha_alta,mdy(1,1,1900)), nvl(ch.usuario_camb,''), nvl(ch.fecha_camb,mdy(1,1,1900))
              into vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio
              from si_cte_huella ch
             where ch.numcte = vcliente
               and ch.secuencia = (select max(secuencia) from si_cte_huella where numcte = vcliente);
             
            select nvl(cp.sexo,''), nvl(trim(ct.numcte_ref),'0')
              into vsexo, vclienteref
              from si_cliente ct,
                   si_ctepf cp
             where ct.numcte = vcliente
               and cp.numcte = ct.numcte;
               
            insert into tmp_huellas_ctes (numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref)
            values(vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref);
        end foreach;

    end if;
    
    --update statistics medium for table tmp_huellas_ctes;
  update statistics medium for table tmp_huellas_ctes FORCE;

    
    if ptipo in('1','3','4') then 
    
        foreach
            select numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref
              from tmp_huellas_ctes
             order by fecha_alta asc
            
            return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref with resume;
        end foreach;
        
    elif ptipo in('2','5') then 
    
        foreach
            select numcte, secuencia, estado, dmapa, imapa, usuario, sucursal, fecha_alta, usuario_camb, fecha_camb, sexo, numcte_ref
              into vcliente, vsecuencia, vstatus, vmapad, vmapai, vusuario, vsucursal, vfechaalta, vusuariocambio, vfechacambio, vsexo, vclienteref
              from tmp_huellas_ctes
             order by fecha_camb asc
            
            return vcodret,vcliente,vsecuencia,vstatus,vmapad,vmapai,vusuario,vsucursal,vfechaalta,vusuariocambio,vfechacambio,vsexo,vclienteref with resume;
        end foreach;
    
    end if;

    END;
    
END PROCEDURE

DOCUMENT
"DESCRIPCION: Consulta de huellas de cliente para replicacion ",
"AUTOR : Daniel Zambada ",
"MODIFICO : Daniel Zambada",
"FECHA : 21/01/2008",
"MODIFICO : Saul Ivanhoe",
"FECHA : 01/02/2008",
"BD    : bdinteg",
"VER   : 1.3",
"MODIFICO : JICS",
"FECHA : 14/Marzo/2011",
"BD    : bdinteg",
"VER   : 2.0";

CREATE PROCEDURE "informix".sp_consultapreasignacionhuella_web_442(cEmpresa CHAR(3), cNumCte CHAR(20))

	--DATOS A REGRESAR---
	RETURNING
	CHAR (5),  ---- Código de Retorno
	CHAR (20), ---- Número de Cliente
	SMALLINT,  ---- Secuencia
	CHAR (1),  ---- Status
	CHAR (8),  ---- User insert
	CHAR (8),  ---- Empleado
	CHAR (8),  ---- Usuario3
	CHAR (4),  ---- Sucursal
	DATE;      ---- Fecha insert

	--DEFINICION DE VARIABLES--
	DEFINE cCodRet      CHAR (5);
	DEFINE cNumCliente  CHAR (20);
	DEFINE smSecuencia  SMALLINT;
	DEFINE cStatus      CHAR (1);
	DEFINE cUser_Insert CHAR (8);
	DEFINE cEmpleado    CHAR (8);
	DEFINE cUsuario3    CHAR (8);
	DEFINE cSucursal    CHAR (4);
	DEFINE dFecha_Insert  DATE;
	DEFINE smSecuenciaMax SMALLINT;

	--INICIALIZACION DE VARIABLES--
	LET cCodRet = "00000";
	LET cNumCliente = "";
	LET smSecuencia = 0;
	LET cStatus = "";
	LET cUser_Insert = "";
	LET cEmpleado = "";
	LET cUsuario3 = "";
	LET cSucursal = "";
	LET dFecha_Insert = "";
	LET smSecuenciaMax = 0;
	
	--SET DEBUG FILE TO "/informix/sp_consultapreasignacionhuella_web_442.out";
	--TRACE ON;
	BEGIN

		IF cNumCte IS NULL OR Trim(cNumCte) = "" THEN
			LET cCodRet = "00110";
			RETURN cCodRet, cNumCliente, smSecuencia, cStatus, cUser_Insert, cEmpleado, cUsuario3, cSucursal, dFecha_Insert;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF (SELECT count(numcte)  FROM bdinteg:si_cte_huella_dec_temp WHERE numcte = cNumCte) = 0 THEN
			LET cCodRet = "00001";
		END IF;

		SELECT MAX(secuencia)
		INTO smSecuenciaMax
		FROM bdinteg:si_cte_huella_dec_temp
		WHERE numcte = cNumCte;

		SELECT first 1 numcte, secuencia, status, user_insert, empleado, usuario3, sucursal, fecha_insert
		INTO cNumCliente, smSecuencia, cStatus, cUser_Insert, cEmpleado, cUsuario3, cSucursal, dFecha_Insert            
		FROM bdinteg:si_cte_huella_dec_temp
		WHERE numcte = cNumCte
		AND secuencia = smSecuenciaMax;

		RETURN NVL(cCodRet,"00001"), NVL(cNumCliente,""), NVL(smSecuencia,""), NVL(cStatus,""), NVL(cUser_Insert,""), NVL(cEmpleado,""), NVL(cUsuario3,""), NVL(cSucursal,""), dFecha_Insert;
	END;
END PROCEDURE;