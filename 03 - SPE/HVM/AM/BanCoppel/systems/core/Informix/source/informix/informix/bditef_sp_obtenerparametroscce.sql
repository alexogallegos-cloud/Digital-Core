CREATE PROCEDURE "informix".sp_obtenerparametroscce(pEmpresa CHAR(3),pUsuario CHAR(8))
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(30),       -- RAZON SOCIAL
            CHAR(45),       -- NOMBRE USUARIO                
			DATE,			-- FECHA HOY
			CHAR(100),		-- NUMERO BANCO
			VARCHAR(100),   -- IP INTERACT
			VARCHAR(100);   -- PUERTO
			
DEFINE iSqlErr       INT;
DEFINE cCodret       CHAR(5);  
DEFINE cDescripcion  CHAR(40);
DEFINE cIPInteract	 VARCHAR(100);
DEFINE cPuerto		 VARCHAR(100);
DEFINE cBanco		 CHAR(100);
DEFINE cFecha_hoy	 DATE;
DEFINE cNombre		 CHAR(45);
DEFINE cRazonSocial	 CHAR(30);

LET cCodret			= '00000';  
LET cDescripcion    ='';
LET cIPInteract	    ='';
LET cPuerto		    ='';
LET cBanco		    ='';
LET cFecha_hoy	    ='';
LET cNombre		    ='';
LET cRazonSocial	='';
LET iSqlErr         = 0;

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto ;     
        END IF;
   END EXCEPTION;

	--EMPRESA
	SELECT razon_social 
	INTO cRazonSocial
	FROM bdinteg:si_empresas 	
	WHERE empresa= pEmpresa;

	--USUARIO
	SELECT nombre 
	INTO cNombre 
	FROM bdinteg:si_ejecut 	
	WHERE ejecutivo = pUsuario;

	--FECHA HOY
	SELECT fecha_hoy 
	INTO cFecha_hoy
	FROM bdinteg:si_fechas 	
	WHERE empresa = pEmpresa;

	--NUMERO BANCO PROPIO
	SELECT valor 
	INTO cBanco 
	FROM bdinteg:si_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='5';

	--CARGA INTERACT IP
	SELECT valor 
	INTO cIPInteract
	FROM bditef:cce_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='3';

	--CARGA INTERACT PORT
	SELECT valor 
	INTO cPuerto
	FROM bditef:cce_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='4';

	IF cPuerto = '' OR cPuerto IS NULL OR cIPInteract= '' OR cIPInteract IS NULL THEN
		LET cCodret= '10000';     
	END IF;
		
	RETURN  cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto ;

	    
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100304.0943';

create procedure "informix".cal_fecharet( pfechaofi  date )
    RETURNING char(5), date;  

    DEFINE v_codret         char(5);
    DEFINE sql_err          integer;
    DEFINE isam_err         integer;  
    DEFINE v_fechapre       date;
    DEFINE v_esferiadox     char(1); 

    LET v_codret = "000";
    LET v_fechapre = " ";

    BEGIN

    on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            return v_codret,v_fechapre;
        end if;
    end exception;

    -- set debug file to "cal_fecharet.txt";
    -- trace on;
    
    set isolation to dirty read;

    -- // Valida la informacion de entrada
    IF pfechaofi is null THEN
        -- // Datos de entrada incompletos
        LET v_codret = 210; 
        RETURN v_codret, v_fechapre; 
    END IF;

    -- // Validar feriado, sab o dom
    select "1"
      into v_esferiadox
      from bdinteg:si_feriado
     where fecha = pfechaofi;

    IF v_esferiadox is null THEN
        LET v_esferiadox = "0";
    END IF

    -- // Cuando es feriado, sab, dom o fuera de horario se pasa al sig habil
    IF v_esferiadox = "1" or 
       to_char(pfechaofi, "%A") = "Saturday" or 
       to_char(pfechaofi, "%A") = "Sunday" THEN 
        -- // Calcular la fecha correcta
        
        call cal_fecha_pre_fh(pfechaofi)
        returning v_codret, v_fechapre;	
        
        RETURN v_codret, v_fechapre;
    END IF

    LET v_fechapre = pfechaofi;	

    END;    

    RETURN v_codret,v_fechapre;

END PROCEDURE;