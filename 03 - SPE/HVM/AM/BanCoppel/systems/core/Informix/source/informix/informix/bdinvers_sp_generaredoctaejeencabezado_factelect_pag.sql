CREATE PROCEDURE "informix".sp_generaredoctaejeencabezado_factelect_pag ( pEmpresa  CHAR(3), 
                                                                          pCuenta   CHAR(20), 
                                                                          pFechafin DATE)
RETURNING CHAR(5)       AS vcodret,     
          CHAR(20)      AS cNum_cte,
          CHAR(150)     AS cNombre_cte,
          CHAR(200)     AS cDireccion_cte,
          CHAR(120)     AS cDireccion_col,
          CHAR(120)     AS cDireccion_del,
          CHAR(120)     AS cEdo_cd,              
          CHAR(40)      AS cSucursal_nombre,
          CHAR(13)      AS cRFC_Cliente,
          CHAR(5)       AS cCP,
          CHAR(60)      AS cCurp,
          DATE          AS dFechaAlta,
          DATE          AS dFechaInicio,
          DATE          AS dFechaFinal,
          CHAR(4)       AS cSucursal,
          DECIMAL(18,2) AS mCapitalInicial,
          DECIMAL(16,2) AS mSaldoFinal,
          DECIMAL(16,2) AS mInteresesPagados,
          DECIMAL(16,2) AS mRetencionIsr,              
          SMALLINT      AS iDias,             
          DECIMAL(9, 6) AS dTasaBruta,
          DECIMAL(9, 6) AS dGAT,
          CHAR(255)     AS cMensajeProducto,
          CHAR(255)     AS cPiePagina,
		  CHAR(4)       AS vestado, 
		  VARCHAR(60)   AS vciudad, 
		  CHAR(14)      AS vtelefono,
		  CHAR(40)      AS vgerente,
		  CHAR(4)       AS cNumProducto,
          DECIMAL(9, 6) AS dGATReal,
          SMALLINT      AS iEnvioMovtos;
		  
    DEFINE cNum_cte             CHAR(20);
    DEFINE cNombre_cte          CHAR(150);
    DEFINE vcodret              CHAR(5);
    DEFINE cCP                  CHAR(5);
    DEFINE cRFC_Cliente         CHAR(13);
    DEFINE cCurp                CHAR(60);
    DEFINE cDireccion_cte       CHAR(200);
    DEFINE cSucursal_nombre     CHAR(40);
    DEFINE v_numeroextcalle     CHAR(10);
    DEFINE cSucursal            CHAR(4);
    DEFINE cNumProducto         CHAR(4);
    DEFINE vexiste_maeinv       CHAR(6);
    DEFINE cDireccion_col       CHAR(120);          
    DEFINE cDireccion_del       CHAR(120);          
    DEFINE cEdo_cd              CHAR(120);  
    DEFINE cMensajeProducto     CHAR(255);  
    DEFINE cPiePagina           CHAR(255);    
    DEFINE dFecha_emision       DATE;
    DEFINE dFechaAlta           DATE;
    DEFINE dFechaInicio         DATE;
    DEFINE vsqlerr              INTEGER;  
    DEFINE visamerr             INTEGER;  
    DEFINE v_numerocolonia      INTEGER;  
    DEFINE v_numerocalle        INTEGER;  
    DEFINE iDias                SMALLINT;             
    DEFINE vsec_dir             SMALLINT; 
    DEFINE v_numerociudad       SMALLINT;   
    DEFINE dTasaBruta           DECIMAL(9, 6);
    DEFINE dGAT                 DECIMAL(9, 6);
    DEFINE mCapitalInicial       DECIMAL(18,2);
    DEFINE mSaldoFinal           DECIMAL(18,2);
    DEFINE mInteresesPagados    DECIMAL(18,2);
    DEFINE mRetencionIsr        DECIMAL(18,2);
	DEFINE vestado 			    CHAR(4);
	DEFINE vciudad 			    VARCHAR(60);  
	DEFINE vtelefono 		    CHAR(14);
	DEFINE vgerente 		    CHAR(40);
	DEFINE vcuantos  		    INTEGER;
	DEFINE vcuantos2  		    INTEGER;
    DEFINE cRFC_alterno         CHAR(13);
    DEFINE dGATReal             DECIMAL(9, 6);
    DEFINE iEnvioMovtos         SMALLINT;
    
    LET vcodret = "000";                                      
    LET cNum_cte = "";                          
    LET cNombre_cte = "";                   
    LET cDireccion_cte = "";                
    LET cDireccion_col = "";                
    LET cDireccion_del = "";
    LET cEdo_cd = "";                       
    LET cCP = "";                               
    LET cRFC_Cliente = "";                  
    LET dFechaInicio = "";
    LET cCurp = "";                         
    LET cSucursal_nombre = "";                  
    LET dFecha_emision = "";                
    LET dFechaAlta = "";                                          
    LET mSaldoFinal = 0;               
    LET mCapitalInicial = 0;                                            
    LET mInteresesPagados = 0;                                    
    LET mRetencionIsr = 0;                                       
    LET iDias = 0;                          
    LET v_numerocolonia = 0;
    LET vsec_dir = 0;     
    LET pCuenta = TRIM(pCuenta);                
    LET v_numerocalle = 0;                                       
    LET v_numeroextcalle = "";
    LET v_numerociudad = 0;                     
    LET cSucursal = "";                                                          
    LET cNumProducto = "";
    LET dGAT = 0;
    LET cMensajeProducto = "";
    LET cPiePagina = "";
	LET vestado 	 = "";
	LET vciudad 	 = "";
	LET vtelefono 	 = "";
	LET vgerente 	 = "";
	LET vcuantos	 = 0;
	LET vcuantos2	 = 0;
    LET cRFC_alterno = "";
    LET dGATReal     = 0;
    LET iEnvioMovtos = 0;
	LET dTasaBruta = 0;
   
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "/resplogifx/conciliachq/edoctacfd/sp_generaredoctaejeencabezado_factelect_pag.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            RETURN vcodret, cNum_cte, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
                   cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
                   cSucursal, mCapitalInicial, mSaldoFinal, mInteresesPagados,  
                   mRetencionIsr, iDias, dTasaBruta, dGAT, cMensajeProducto, cPiePagina,
				   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
        END IF;
    END EXCEPTION;
	
	 --SET debug FILE TO "/RESPALDOSNEW/rsv/encabezado/sp_generaredoctaejeencabezado_factelect.out";
     --trace on;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    -- // Validar que los parÃ¡metros se hayan recibido correctamente
    IF (TRIM(pEmpresa) = "" OR pEmpresa IS NULL) THEN
        LET vcodret = "001";
        RETURN vcodret, cNum_cte, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
               cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
               cSucursal, mCapitalInicial, mSaldoFinal, mInteresesPagados,  
               mRetencionIsr, iDias, dTasaBruta, dGAT, cMensajeProducto, cPiePagina,
			   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
    END IF;
    
    IF (TRIM(pCuenta) = "" OR pCuenta IS NULL) THEN
        LET vcodret = "002";
        RETURN vcodret, cNum_cte, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
               cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
               cSucursal, mCapitalInicial, mSaldoFinal, mInteresesPagados, 
               mRetencionIsr, iDias, dTasaBruta, dGAT, cMensajeProducto, cPiePagina,
			   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
    END IF;
    
	--Valida la existencia de la cuenta
    SELECT FIRST 1 cod_instrum 
    INTO   vexiste_maeinv
    FROM   bdinvers:sv_maeinv mv 
    WHERE  mv.empresa    = pEmpresa 
    AND    mv.cuenta     =  pCuenta 
    AND    mv.fecha_venc = pFechafin;
       
    IF vexiste_maeinv is null OR vexiste_maeinv = '' THEN
        LET vcodret = "003";
        RETURN vcodret, cNum_cte, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
               cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
               cSucursal, mCapitalInicial, mSaldoFinal, mInteresesPagados,   
               mRetencionIsr, iDias, dTasaBruta, dGAT, cMensajeProducto, cPiePagina,
			   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
    END IF
    
    -- // OBTENER EL ESTADO DE CUENTA 
    SELECT LIMIT 1
           TRIM(ap.cod_instrum) || ' ' || TRIM(ap.nombre) AS producto,
           TRIM(mv.num_cte), NVL(mv.fecha_alta, MDY(1, 1, 1900)), NVL(mv.fecha_venc, MDY(1, 1, 1900)),
           NVL(mv.capital, 0), (NVL(mv.capital,0) + NVL(mv.intereses,0)) - NVL(mv.isr,0) , NVL(mv.intereses, 0),
           NVL(mv.isr, 0), NVL(mv.plazo, 0), NVL(mv.tasa, 0), mv.cod_instrum         
    INTO   cMensajeProducto, 
           cNum_cte, dFechaInicio, dFecha_emision, 
           mCapitalInicial, mSaldoFinal, mInteresesPagados,  
           mRetencionIsr, iDias, dTasaBruta, cNumProducto     
    FROM   bdinvers:sv_maeinv  AS mv,
           bdinvers:sv_instrum AS ap
    WHERE  mv.empresa     = pEmpresa 
    AND    mv.cuenta      = pCuenta 
    AND    mv.fecha_venc  = pFechafin
	AND    mv.cod_instrum = ap.cod_instrum
	AND    ap.cod_instrum = '3000';
	
	
	-- // Extrae  EL GAT Y GAT REAL	
	SELECT gat_nomina , gat_real 
	INTO   dGAT,        dGATReal
	FROM   bdinvers:sv_gat 
    WHERE  iDias  BETWEEN plazo_inicio AND plazo_fin;
		

    -- // Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL
    SELECT MAX(secuencia) 
    INTO   vsec_dir
    FROM   bdinteg:si_direcciones_actual
    WHERE  numcte   = cNum_cte 
    AND    tipo_dir = 1;
	  
    IF  vsec_dir IS NULL THEN 
        SELECT MAX(secuencia) 
        INTO   vsec_dir
        FROM   bdinteg:si_direcciones_actual
        WHERE  numcte = cNum_cte 
        AND    tipo_dir = 2;
           
        IF  vsec_dir IS NULL THEN 
            SELECT MAX(secuencia) 
            INTO   vsec_dir
            FROM   bdinteg:si_direcciones_actual
            WHERE  numcte   = cNum_cte 
            AND    tipo_dir = 3;
		ELSE
		    LET vsec_dir = 1;	   
        END IF
    END IF

    IF cNum_cte IS NULL THEN
        SELECT LIMIT 1 TRIM(ap.cod_instrum) || ' ' || TRIM(ap.nombre) AS producto, TRIM(mv.num_cte)
        INTO   cMensajeProducto, cNum_cte
        FROM   bdinvers:sv_maeinv  AS mv,
               bdinvers:sv_instrum AS ap
        WHERE  mv.empresa     = pEmpresa 
        AND    mv.cuenta      = pCuenta 
		AND    mv.cod_instrum = ap.cod_instrum
	    AND    ap.cod_instrum = '3000';
  
            
        SELECT LIMIT 1
               CASE WHEN cte.tpo_persona in("01", "03") THEN 
                   TRIM(NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.nombre2), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")||' '||NVL(TRIM(cte.razon_social), ""))
               ELSE 
                   NVL(TRIM(cte.razon_social), "")||' '||NVL(TRIM(sufijo.descripcion), "") 
               END AS nombrex, 
               suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, 
			   CASE WHEN TRIM(cpf.curp) MATCHES '*[|@#$]*' THEN REPLACE(REPLACE(REPLACE(REPLACE(cpf.curp,'$',''),'#',''),'@','') ,'|','') 
                    ELSE cpf.curp
               END, 
               TRIM(cal.nombrecalle)||" "||NVL(dir.numeroextcalle,0)||" "||NVL(dir.numerointcalle,0),
               TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal, dir.numerocolonia, dir.numerocalle,
               dir.numerociudad, dir.numeroextcalle, cte.sucursal, envio_movtos
        INTO   cNombre_cte, 
               cSucursal_nombre, dFechaAlta, cRFC_Cliente, cRFC_alterno, cCurp, 
               cDireccion_cte,
               cDireccion_col, cDireccion_del, cEdo_cd, cCP, v_numerocolonia, v_numerocalle,
               v_numerociudad, v_numeroextcalle, cSucursal, iEnvioMovtos
        FROM   bdinteg:si_cliente AS cte
               LEFT JOIN bdinteg:si_ctepf cpf ON (cpf.numcte = cte.numcte)
               LEFT OUTER JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte AND dir.secuencia = vsec_dir)
               LEFT OUTER JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
               LEFT OUTER JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
               LEFT OUTER JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
               LEFT OUTER JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
               LEFT OUTER JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
		       LEFT OUTER JOIN bdinteg:si_ctepm AS pm ON (pm.numcte = cte.numcte)
		       LEFT OUTER JOIN bdinteg:si_sufijos AS sufijo ON(sufijo.codigo = pm.sufijo)
        WHERE  cte.empresa = pEmpresa 
        AND    cte.numcte = cNum_cte; 

        LET dFechaInicio = "";
        LET dFecha_emision = "";
        LET mCapitalInicial = 0;
        LET mSaldoFinal = 0;
        LET mInteresesPagados = 0;
        LET mRetencionIsr = 0;
        LET iDias = 0;
        LET dTasaBruta = 0;
    ELSE
        SELECT LIMIT 1
               CASE WHEN cte.tpo_persona in("01", "03") THEN 
                   TRIM(NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.nombre2), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")||' '||NVL(TRIM(cte.razon_social), ""))
               ELSE 
                   NVL(TRIM(cte.razon_social), "")||' '||NVL(TRIM(sufijo.descripcion), "") 
               END AS nombrex,
               suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, 
			   CASE WHEN TRIM(cpf.curp) MATCHES '*[|@#$]*' THEN REPLACE(REPLACE(REPLACE(REPLACE(cpf.curp,'$',''),'#',''),'@','') ,'|','') 
                    ELSE cpf.curp
               END, 
               TRIM(cal.nombrecalle)||" "||NVL(dir.numeroextcalle,0)||" "||NVL(dir.numerointcalle,0),
               TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal, dir.numerocolonia, dir.numerocalle,
               dir.numerociudad, dir.numeroextcalle, cte.sucursal, envio_movtos
        INTO   cNombre_cte, 
               cSucursal_nombre, dFechaAlta, cRFC_Cliente, cRFC_alterno, cCurp, 
               cDireccion_cte, 
               cDireccion_col, cDireccion_del, cEdo_cd, cCP, v_numerocolonia, v_numerocalle,
               v_numerociudad, v_numeroextcalle, cSucursal, iEnvioMovtos
        FROM   bdinteg:si_cliente AS cte
               LEFT JOIN bdinteg:si_ctepf AS cpf ON (cpf.numcte = cte.numcte)
               LEFT OUTER JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte AND dir.secuencia = vsec_dir)
               LEFT OUTER JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
               LEFT OUTER JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
               LEFT OUTER JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
               LEFT OUTER JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
               LEFT OUTER JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
		       LEFT OUTER JOIN bdinteg:si_ctepm AS pm ON (pm.numcte = cte.numcte)
		       LEFT OUTER JOIN bdinteg:si_sufijos AS sufijo ON(sufijo.codigo = pm.sufijo)
        WHERE  cte.empresa = pEmpresa 
        AND    cte.numcte = cNum_cte; 
    END IF;
    
    IF cRFC_alterno is not null AND cRFC_alterno <> "" THEN
       LET cRFC_Cliente = cRFC_alterno;
    END IF;	
    
    -- // Obtener el pie de pagina    
    SELECT LIMIT 1 mensaje
    INTO   cPiePagina
    FROM   bdinvers:sv_mensajes_producto
    WHERE  producto = cNumProducto
	AND    secuencia = '1'
	AND    nlinea = '1';    
	 
	-- SE AGREGAN CAMPOS ADICIONALES DE SUCURSAL
    SELECT LIMIT 1 sucursal
    INTO   cSucursal
    FROM   bdinvers:sv_maeinv
    WHERE  cuenta = pCuenta; 
    
    SELECT nombre 
    INTO   cSucursal_nombre 
    FROM   bdinteg:si_sucursales  
    WHERE  sucursal = cSucursal;
    
    FOREACH 
        EXECUTE PROCEDURE bdicobranza:sp_obtenerposicion(cSucursal_nombre, ",")
        INTO vcuantos , vcuantos2
        
        EXIT FOREACH;
    END FOREACH
			
    IF  vcuantos = -1  THEN

	    SELECT s.nombre,         p.cve_estado, p.cve_ciudad, s.telefono1, s.gerente
	    INTO   cSucursal_nombre, vestado,      vciudad,      vtelefono,   vgerente
        FROM   bdinteg:si_sucursales AS s,
               bdinteg:si_ptf        AS p
        WHERE  s.sucursal = p.id_ptf
	    AND    s.sucursal = cSucursal
        AND    p.tipo     = 'S';
 
    ELSE
	
	    SELECT SUBSTR ( s.nombre, 1, vcuantos - 1),p.cve_estado, p.cve_ciudad, s.telefono1, s.gerente
        INTO   cSucursal_nombre,                   vestado,      vciudad,      vtelefono,   vgerente
        FROM   bdinteg:si_sucursales AS s,
               bdinteg:si_ptf        AS p
        WHERE  s.sucursal = p.id_ptf
		AND    s.sucursal = cSucursal
        AND    p.tipo = 'S';
		 
    END IF
	
    SELECT nombre 
    INTO   vciudad
    FROM   bdinteg:si_ciudades 
    WHERE  estado = vestado
    AND    ciudad = vciudad;
    
    SELECT siglas 
    INTO   vestado
    FROM   bdinteg:si_estados 
    WHERE  estado = vestado;
    
    RETURN vcodret, cNum_cte, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
           cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
           cSucursal, mCapitalInicial, mSaldoFinal, mInteresesPagados, 
           mRetencionIsr, iDias, dTasaBruta, dGAT, cMensajeProducto, cPiePagina,
		   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos; 
    
    END;
END PROCEDURE;