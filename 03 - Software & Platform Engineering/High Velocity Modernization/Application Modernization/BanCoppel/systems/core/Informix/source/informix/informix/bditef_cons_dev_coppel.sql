create procedure "informix".cons_dev_coppel(
            pempresa    char(3),
            pfechadevo  char(10),
            pcuenta1    char(20),
            pcuenta2    char(20),
            ptrandev    char(4),
            ptrancom    char(4),
            ptraniva    char(4))
            RETURNING 
            char(5),        -- codret
            char(45),       -- sucursal
            char(100),      -- banco
            char(7),        -- nro cheque
            decimal(16,2),  -- importe
            decimal(8,2),   -- comision
            decimal(8,2),   -- iva
			char(45);       -- Motivodev
			

   DEFINE v_codret      char(5);
   DEFINE v_sucursal    char(45);   
   DEFINE v_banco       char(100);
   DEFINE v_numcheque   char(7);
   DEFINE v_importe     decimal(16,2);
   DEFINE v_com         decimal(8,2);   
   DEFINE v_iva         decimal(8,2);   
   DEFINE v_folio       char(16);   
   DEFINE v_motivodev   char(45);  
   DEFINE v_fechapaso   date;
    
   DEFINE sql_err,isam_err  int;   


-- v1.2 se usa el spl proporcionado por bancoppel
-- Grupo PISA - Eduardo Espinosa Ene 10


-- v1.1 se cambia el parametro pfechadevo de date
-- a char(10) por que crystal marca error en fechas
-- del 2010 usando spls como la fuente de datos
-- Grupo PISA - Eduardo Espinosa Ene 10


-- arma los datos para el reporte de las 
-- devoluciones cuenta coppel colateral
-- Grupo PISA - Eduardo Espinosa Sep 08
-- v1 version inicial



BEGIN
   on exception set sql_err,isam_err
        if sql_err <> 0 or isam_err <> 0 then
            let v_codret = sql_err;
            RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
            v_importe,v_com,v_iva,v_motivodev;
            end if;
   end exception;


-- ****************************************************************************
-- cons_dev_coppel JYDG
-- ****************************************************************************


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
    let v_codret        = "000";
    let v_sucursal      = " ";      
    let v_banco         = " ";
    let v_numcheque     = " ";        
    let v_importe       = 0;
    let v_com           = 0;   
    let v_iva           = 0;    
    let v_fechapaso     = pfechadevo;
	


-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF      pempresa    is null or
            pfechadevo  is null or
            pcuenta1    is null or
            pcuenta2    is null or
            ptrandev    is null or
            ptrancom    is null or
            ptraniva    is null then
    
        -- datos de entrada incompletos     
        LET v_codret = 110; 
        
        RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
                v_importe,v_com,v_iva,v_motivodev;
    END IF;


    
      


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************


    FOREACH

        -- consulta principal

        SELECT  c.sucursal || " " || s.nombre,
                c.cvebanco || ' ' || b.descripcion,
                c.numcheque,c.monto, c.motivo || ' ' || cdev.descripcion
        INTO    v_sucursal,v_banco,v_numcheque,v_importe, v_motivodev                 
        FROM    cce_cheques_dev c, bdinteg:si_bancos b,
                bdinteg:si_sucursales s, bdinteg:si_coddevcam cdev
        WHERE   c.empresa = pempresa
                and c.fecha_alta    = v_fechapaso 
                and c.cvebanco      = b.banco
                and c.sucursal      = s.sucursal
				and cdev.codigo     = c.motivo 
                and c.cta_deposito  = pcuenta2 --pcuenta1 lalo dic08
                order by 1

        let v_folio			="";

        -- las devoluciones quedan registradas en la cta2                
        -- buscar el folio de la dev en sc_movdia

      
        select  folio_suc
        into    v_folio
        from    bdicheq:sc_movdia
        where   empresa     = pempresa
        and     cuenta      = pcuenta2
        and     fech_alt    = v_fechapaso
        and     monto_tot   = v_importe
        and     num_cheq    = v_numcheque
        and     transacc    = ptrandev;
        
        
        IF v_folio <> ""  THEN
        
            -- importe de la comision
            select  monto_tot
            into    v_com
            from    bdicheq:sc_movdia
            where   empresa     = pempresa
            and     folio_suc   = v_folio
            and     transacc    = ptrancom;
            
            -- importe del iva
            select  monto_tot
            into    v_iva
            from    bdicheq:sc_movdia
            where   empresa     = pempresa
            and     folio_suc   = v_folio
            and     transacc    = ptraniva;   
        
        ELSE
        
            -- buscar el folio de la dev en sc_movhis
            
            select  folio_suc
            into    v_folio
            from    bdicheq:sc_movhis
            where   empresa     = pempresa
            and     cuenta      = pcuenta2
            and     fech_alt    = v_fechapaso
            and     monto_tot   = v_importe
            and     num_cheq    = v_numcheque
            and     transacc    = ptrandev;
        
        
            IF v_folio <> ""  THEN
            
                -- importe de la comision
                select  monto_tot
                into    v_com
                from    bdicheq:sc_movhis
                where   empresa     = pempresa
                and     folio_suc   = v_folio
                and     transacc    = ptrancom;
                
                -- importe del iva
                select  monto_tot
                into    v_iva
                from    bdicheq:sc_movhis
                where   empresa     = pempresa
                and     folio_suc   = v_folio
                and     transacc    = ptraniva;   
            
            END IF;    
            
        END IF; 


        RETURN  v_codret,v_sucursal,v_banco,v_numcheque,
                v_importe,v_com,v_iva, v_motivodev
                WITH RESUME;

    END FOREACH     

END;    
END PROCEDURE
DOCUMENT
'MODIFICO :César Valdéz Figueroa',
'DESCRIPCION:  Este Procediemiento se modifico agregando un retorno de un campo  mas, el campo es motivo ',
'  			   de devolucion el cual lo conforma el motivo y la descripcion del motivo.',
'FECHA : SEPTIEMBRE de 2009',
'BD    : BDITEF',
'VERSION: 20090918.1037';

CREATE PROCEDURE "informix".sp_obtenerbancosregistrados()

            RETURNING 
			CHAR(5),
            CHAR(3),        -- BANCO
            CHAR(40);       -- DESCRIPCION BANCO                 
			
DEFINE iSqlErr       INT;
DEFINE cCodret       CHAR(5);
DEFINE cBanco    	 CHAR(3);   
DEFINE cDescripcion  CHAR(40);

LET cCodret			= '00000';
LET cBanco			= '';
LET cDescripcion	= '';
LET iSqlErr         = 0;

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cBanco, cDescripcion;        
        END IF;
   END EXCEPTION;

	FOREACH
		--OBTIENE LOS BANCOS REGISTRADOS ORDENADOS POR DESCRIPCION DE BANCO
		SELECT banco,descripcion 
		INTO cBanco, cDescripcion
		FROM bdinteg:si_bancos 
		ORDER BY 2

		RETURN  cCodRet,cBanco, cDescripcion WITH RESUME;

	END FOREACH     
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÑEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS BANCOS REGISTRADOS ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100303.1158';

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