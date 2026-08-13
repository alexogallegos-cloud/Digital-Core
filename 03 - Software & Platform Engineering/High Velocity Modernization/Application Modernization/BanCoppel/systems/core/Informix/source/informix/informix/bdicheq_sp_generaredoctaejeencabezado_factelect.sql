CREATE PROCEDURE "informix".sp_generaredoctaejeencabezado_factelect( pEmpresa CHAR(3), 
                                                                     pCuenta CHAR(20), 
                                                                     pAniomes CHAR(6) )
RETURNING CHAR(5)       AS vcodret, 
          DATE          AS dFecha_emision,
          CHAR(20)      AS cNum_cte,
          CHAR(16)      AS cNum_Tarjeta,
          CHAR(254)     AS cNombre_cte,
          CHAR(200)     AS cDireccion_cte,
          CHAR(120)     AS cDireccion_col,
          CHAR(120)     AS cDireccion_del,
          CHAR(120)     AS cEdo_cd,              
          CHAR(40)      AS cSucursal_nombre,
          CHAR(13)      AS cRFC_Cliente,
          CHAR(5)       AS cCP,
          CHAR(60)      AS cClabe,
          CHAR(60)      AS cCurp,
          DATE          AS dFechaAlta,
          DATE          AS dFechaInicio,
          DATE          AS dFechaFinal,
          CHAR(4)       AS cSucursal,
          DECIMAL(16,2) AS mSaldoAnterior,
          DECIMAL(16,2) AS mDepositos,
          DECIMAL(16,2) AS mInteresesPagados,
          DECIMAL(16,2) AS mRetiros,
          DECIMAL(16,2) AS mOtrosCargos,
          DECIMAL(16,2) AS mIvaOtrosCargos,
          DECIMAL(16,2) AS mSaldoCorte,
          DECIMAL(16,2) AS mSaldoPromedio,
          DECIMAL(16,2) AS mRetencionIsr,              
          DECIMAL(16,2) AS mInteresesNetos,
          SMALLINT      AS iDias,             
          DECIMAL(9, 6) AS dTasaBruta,
          DECIMAL(16,2) AS mTotRetirosEfec,  
          DECIMAL(16,2) AS mTotOtrosCargos,
          DECIMAL(9, 6) AS dGAT,
          CHAR(255)     AS cMensajeProducto,
          CHAR(255)     AS cPiePagina,
          CHAR(4)       AS vestado, -- EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
          VARCHAR(60)   AS vciudad, 
          CHAR(14)      AS vtelefono,
          CHAR(40)      AS vgerente,
          CHAR(4)       AS cNumProducto,
          DECIMAL(9, 6) AS dGATReal,
          SMALLINT      AS iEnvioMovtos;
		  
    DEFINE cNum_cte             CHAR(20);
    DEFINE cNombre_cte          CHAR(254);
    DEFINE vcodret              CHAR(5);
    DEFINE cCP                  CHAR(5);
    DEFINE cNum_Tarjeta         CHAR(16);
    DEFINE cRFC_Cliente         CHAR(13);
    DEFINE cClabe               CHAR(60);
    DEFINE cCurp                CHAR(60);
    DEFINE cDireccion_cte       CHAR(200);
    DEFINE cSucursal_nombre     CHAR(40);
    DEFINE v_numeroextcalle     CHAR(10);
    DEFINE cSucursal            CHAR(4);
    DEFINE cNumProducto         CHAR(4);
    DEFINE vexiste_maehis       CHAR(6);
    DEFINE cDireccion_col       CHAR(120);          
    DEFINE cDireccion_del       CHAR(120);          
    DEFINE cEdo_cd              CHAR(120);  
    DEFINE cMensajeProducto     CHAR(255);  
    DEFINE cPiePagina           CHAR(255);    
    DEFINE dFecha_emision       DATE;
    DEFINE dFechaAlta           DATE;
    DEFINE dFechaInicio         DATE;
    DEFINE tPeriodoAnterior     DATE;
    DEFINE vsqlerr              INTEGER;  
    DEFINE visamerr             INTEGER;  
    DEFINE v_numerocolonia      INTEGER;  
    DEFINE v_numerocalle        INTEGER;  
    DEFINE v_centro             INTEGER; 
    DEFINE iDias                SMALLINT;             
    DEFINE vsec_dir             SMALLINT; 
    DEFINE v_numerociudad       SMALLINT;   
    DEFINE dTasaBruta           DECIMAL(9, 6);
    DEFINE dGAT                 DECIMAL(9, 6);
    DEFINE mSaldoAnterior       DECIMAL(18,2);
    DEFINE mDepositos           DECIMAL(18,2);
    DEFINE mInteresesPagados    DECIMAL(18,2);
    DEFINE mRetiros             DECIMAL(18,2);
    DEFINE mOtrosCargos         DECIMAL(18,2);
    DEFINE mIvaOtrosCargos      DECIMAL(18,2);
    DEFINE mSaldoCorte          DECIMAL(18,2);
    DEFINE mSaldoPromedio       DECIMAL(18,2);
    DEFINE mRetencionIsr        DECIMAL(18,2);
    DEFINE mInteresesNetos      DECIMAL(18,2);
    DEFINE mAux1                DECIMAL(18,2);
    DEFINE mTotRetirosEfec      DECIMAL(18,2);
    DEFINE mTotOtrosCargos      DECIMAL(18,2);
	
	-- // EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
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
    LET cNum_Tarjeta = "";
    LET cClabe = "";                        
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
    LET mSaldoPromedio= 0;                  
    LET mDepositos = 0;
    LET mInteresesNetos = 0;                
    LET mSaldoAnterior = 0;                     
    LET mRetiros = 0;                       
    LET mInteresesPagados = 0;                  
    LET mOtrosCargos = 0;                   
    LET mRetencionIsr = 0;
    LET mIvaOtrosCargos = 0;                
    LET mSaldoCorte = 0;                        
    LET iDias = 0;                          
    LET dTasaBruta = 0;                         
    LET mAux1 = 0;                          
    LET v_numerocolonia = 0;
    LET vsec_dir = 0;     
    LET pCuenta = TRIM(pCuenta);                
    LET v_numerocalle = 0;                  
    LET v_centro = 0;                           
    LET v_numeroextcalle = "";
    LET v_numerociudad = 0;                     
    LET cSucursal = "";                                                          
    LET cNumProducto = "";
    LET tPeriodoAnterior = "";     
    LET mTotRetirosEfec = 0;
    LET mTotOtrosCargos = 0;
    LET dGAT = 0;
    LET cMensajeProducto = "";
    LET cPiePagina = "";
	-- // EMPIEZAN LAS VARIABLES DE LOS CAMPOS NUEVOS
	LET vestado 	 = "";
	LET vciudad 	 = "";
	LET vtelefono 	 = "";
	LET vgerente 	 = "";
	LET vcuantos	 = 0;
	LET vcuantos2	 = 0;
    LET cRFC_alterno = "";
    LET dGATReal     = 0;
    LET iEnvioMovtos = 0;

    --- SET debug FILE TO "/tmp/sp_generaredoctaejeencabezado_factelect.out";
    --- trace on;

    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr != 0 THEN
            SET DEBUG FILE TO "./sp_generaredoctaejeencabezado_factelect.err";
            TRACE ON;
            LET vcodret = vsqlerr;
            RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
                   cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cClabe, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
                   cSucursal, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, 
                   mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, mTotRetirosEfec, mTotOtrosCargos, dGAT, cMensajeProducto, cPiePagina,
				   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;

    -- // Validar que los parÃ¡metros se hayan recibido correctamente
    IF (TRIM(pEmpresa) = "" OR pEmpresa IS NULL) THEN
        LET vcodret = "001";
        RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
               cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cClabe, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
               cSucursal, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, 
               mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, mTotRetirosEfec, mTotOtrosCargos, dGAT, cMensajeProducto, cPiePagina,
			   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
    END IF;
    
    IF (TRIM(pCuenta) = "" OR pCuenta IS NULL) THEN
        LET vcodret = "002";
        RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
               cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cClabe, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
               cSucursal, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, 
               mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, mTotRetirosEfec, mTotOtrosCargos, dGAT, cMensajeProducto, cPiePagina,
			   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
    END IF;
    
    SELECT FIRST 1 aniomes 
      INTO vexiste_maehis
      FROM bdicheq:sc_maehis mc 
     WHERE mc.empresa = pEmpresa 
       AND mc.cuenta = pCuenta 
       AND mc.aniomes = pAniomes;
       
    IF vexiste_maehis is null OR vexiste_maehis = '' THEN
        LET vcodret = "003";
        RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
               cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cClabe, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
               cSucursal, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, 
               mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, mTotRetirosEfec, mTotOtrosCargos, dGAT, cMensajeProducto, cPiePagina,
			   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos;
    END IF
    
    -- // OBTENER EL ESTADO DE CUENTA
    SELECT LIMIT 1
           TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, mc.num_tarjeta, 
           TRIM(mc.num_cte), mc.cuenta_clabe, NVL(mc.fechaini, MDY(1, 1, 1900)), NVL(mc.fechafin, MDY(1, 1, 1900)),
           NVL(sdo_mes_ant, 0), NVL(totdepositos, 0), NVL(totintpag, 0), NVL(totretiros, 0), NVL(totcomcobrada, 0), NVL(totivacobrado, 0), 
           NVL(sdo_actual, 0), NVL(totisrcobrado, 0), NVL(dia_sdo_pos, 0), NVL(tasabruta, 0), NVL(acum_sdo_pos, 0), mc.producto,
           NVL(totretirosefec, 0), NVL(tototroscargos, 0), NVL(gat, 0), NVL(gat_real, 0)  
      INTO cMensajeProducto, cNum_Tarjeta, 
           cNum_cte, cClabe, dFechaInicio, dFecha_emision, 
           mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, 
           mSaldoCorte, mRetencionIsr, iDias, dTasaBruta, mAux1, cNumProducto,
           mTotRetirosEfec, mTotOtrosCargos, dGAT, dGATReal
      FROM bdicheq:sc_maehis AS mc,
           bdicheq:sc_producto AS ap
     WHERE mc.empresa = pEmpresa 
       AND mc.cuenta = pCuenta 
       AND mc.aniomes = pAniomes 
       AND ap.empresa = mc.empresa 
       AND ap.producto = mc.producto;

    -- // Extrae la Ultima Secuencia de Tipo casa de Direcciones MEL
    SELECT MAX(secuencia) 
      INTO vsec_dir
      FROM bdinteg:si_direcciones_actual
     WHERE numcte = cNum_cte 
       AND tipo_dir = 1;
	  
    IF vsec_dir IS NULL THEN 
        SELECT MAX(secuencia) 
          INTO vsec_dir
          FROM bdinteg:si_direcciones_actual
         WHERE numcte = cNum_cte 
           AND tipo_dir = 2;
           
        IF vsec_dir IS NULL THEN 
            SELECT MAX(secuencia) 
              INTO vsec_dir
              FROM bdinteg:si_direcciones_actual
             WHERE numcte = cNum_cte 
               AND tipo_dir = 3;
		ELSE
		   LET vsec_dir = 1;	   
        END IF
    END IF

    IF iDias = 0 THEN
        LET mSaldoPromedio = 0;
    ELSE
        LET mSaldoPromedio = mAux1 / iDias;
    END IF;

    LET mInteresesNetos = mInteresesPagados - mRetencionIsr;

    IF cNum_cte IS NULL THEN
        SELECT LIMIT 1 TRIM(ap.producto) || ' ' || TRIM(ap.nombre) AS producto, TRIM(mc.num_cte), mc.cuenta_clabe
          INTO cMensajeProducto, cNum_cte, cClabe
          FROM bdicheq:sc_maechq AS mc,
               bdicheq:sc_producto AS ap
         WHERE mc.empresa = pEmpresa 
           AND mc.cuenta = pCuenta 
           AND ap.empresa = mc.empresa 
           AND ap.producto = mc.producto;

        SELECT  LIMIT 1
				CASE  
                    WHEN cte.tpo_persona in("01", "03")  AND cte.nombre2 = "" THEN  TRIM(NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")||' '||NVL(TRIM(cte.razon_social), ""))
			        WHEN cte.tpo_persona in("01", "03")  AND cte.nombre2 <> "" THEN  TRIM(NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.nombre2), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")||' '||NVL(TRIM(cte.razon_social), "")) 
			    ELSE 
                  -- NVL(TRIM(cte.razon_social), "")||' '||NVL(TRIM(sufijo.descripcion), "")
                     NVL(TRIM(sf.nom_razon_soc), "")				  
                END AS nombrex,
               suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, 
			   CASE WHEN TRIM(cpf.curp) MATCHES '*[|@#$]*' THEN REPLACE(REPLACE(REPLACE(REPLACE(cpf.curp,'$',''),'#',''),'@','') ,'|','') 
                    ELSE cpf.curp
               END, 
               TRIM(cal.nombrecalle)||" "||NVL(dir.numeroextcalle,0)||" "||NVL(dir.numerointcalle,0),
               TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal, dir.numerocolonia, dir.numerocalle,
               dir.numerociudad, dir.numeroextcalle, cte.sucursal, NVL(envio_movtos,0)
          INTO cNombre_cte, 
               cSucursal_nombre, dFechaAlta, cRFC_Cliente, cRFC_alterno, cCurp, 
               cDireccion_cte,
               cDireccion_col, cDireccion_del, cEdo_cd, cCP, v_numerocolonia, v_numerocalle,
               v_numerociudad, v_numeroextcalle, cSucursal, iEnvioMovtos
          FROM bdinteg:si_cliente AS cte
          LEFT JOIN bdinteg:si_ctepf cpf ON (cpf.numcte = cte.numcte)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte AND dir.secuencia = vsec_dir)
          LEFT OUTER JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
          LEFT OUTER JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
          LEFT OUTER JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
          LEFT OUTER JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
		  LEFT OUTER JOIN bdinteg:si_ctepm AS pm ON (pm.numcte = cte.numcte)
		  LEFT OUTER JOIN bdinteg:si_sufijos AS sufijo ON(sufijo.codigo = pm.sufijo)
          Left Outer Join bdinteg:si_fiscal As sf on (cte.numcte = sf.numcte)
          WHERE cte.empresa = pEmpresa 
          AND cte.numcte = cNum_cte; 

        LET dFechaInicio = "";
        LET dFecha_emision = "";
        LET mSaldoAnterior = 0;
        LET mDepositos = 0;
        LET mInteresesPagados = 0;
        LET mRetiros = 0;
        LET mOtrosCargos = 0;
        LET mIvaOtrosCargos = 0;
        LET mSaldoCorte = 0;
        LET mSaldoPromedio = 0;
        LET mRetencionIsr = 0;
        LET mInteresesNetos = 0;
        LET iDias = 0;
        LET dTasaBruta = 0;
    ELSE
        SELECT LIMIT 1			   
			   CASE  
              WHEN cte.tpo_persona in("01", "03")  AND cte.nombre2 = "" THEN  TRIM(NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")||' '||NVL(TRIM(cte.razon_social), ""))
			        WHEN cte.tpo_persona in("01", "03")  AND cte.nombre2 <> "" THEN  TRIM(NVL(TRIM(cte.nombre1), "")||' '||NVL(TRIM(cte.nombre2), "")||' '||NVL(TRIM(cte.apell_paterno), "")||' '||NVL(TRIM(cte.apell_materno), "")||' '||NVL(TRIM(cte.razon_social), "")) 
			    ELSE 
                  -- NVL(TRIM(cte.razon_social), "")||' '||NVL(TRIM(sufijo.descripcion), "")
                     NVL(TRIM(sf.nom_razon_soc), "")				  
                END AS nombrex,
               suc.nombre, cte.fecha_insert, cte.rfc, cte.rfc_alterno, 
			   CASE WHEN TRIM(cpf.curp) MATCHES '*[|@#$]*' THEN REPLACE(REPLACE(REPLACE(REPLACE(cpf.curp,'$',''),'#',''),'@','') ,'|','') 
                    ELSE cpf.curp
               END, 
               TRIM(cal.nombrecalle)||" "||NVL(dir.numeroextcalle,0)||" "||NVL(dir.numerointcalle,0),
               TRIM(zon.nombrezona), TRIM(ciu.nombre), TRIM(edo.nombre), dir.cod_postal, dir.numerocolonia, dir.numerocalle,
               dir.numerociudad, dir.numeroextcalle, cte.sucursal, NVL(envio_movtos,0)
          INTO cNombre_cte, 
               cSucursal_nombre, dFechaAlta, cRFC_Cliente, cRFC_alterno, cCurp, 
               cDireccion_cte, 
               cDireccion_col, cDireccion_del, cEdo_cd, cCP, v_numerocolonia, v_numerocalle,
               v_numerociudad, v_numeroextcalle, cSucursal, iEnvioMovtos
          FROM bdinteg:si_cliente AS cte
          LEFT JOIN bdinteg:si_ctepf AS cpf ON (cpf.numcte = cte.numcte)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual AS dir ON (dir.numcte = cte.numcte AND dir.secuencia = vsec_dir)
          LEFT OUTER JOIN bdinteg:si_estados AS edo ON (edo.estado = dir.estado AND edo.pais = "001")
          LEFT OUTER JOIN bdinteg:si_ciudades AS ciu ON (ciu.ciudad = dir.ciudad AND ciu.estado = dir.estado AND ciu.pais = "001")
          LEFT OUTER JOIN bdinteg:si_catzonas AS zon ON (zon.numerociudad = dir.numerociudad AND zon.numerocolonia = dir.numerocolonia )
          LEFT OUTER JOIN bdinteg:si_catcalles AS cal ON (cal.numerocalle = dir.numerocalle)
          LEFT OUTER JOIN bdinteg:si_sucursales AS suc ON (suc.sucursal = cte.sucursal)
		  LEFT OUTER JOIN bdinteg:si_ctepm AS pm ON (pm.numcte = cte.numcte)
		  LEFT OUTER JOIN bdinteg:si_sufijos AS sufijo ON(sufijo.codigo = pm.sufijo)
		  Left Outer Join bdinteg:si_fiscal As sf on (cte.numcte = sf.numcte)
          WHERE cte.empresa = pEmpresa 
          AND cte.numcte = cNum_cte; 
    END IF;
    
    IF cRFC_alterno is not null AND cRFC_alterno <> "" THEN
       LET cRFC_Cliente = cRFC_alterno;
    END IF;	
    
    -- // Obtener el pie de pagina    
    SELECT LIMIT 1 mensaje
      INTO cPiePagina
      FROM sc_mensajes_producto
     WHERE producto = cNumProducto
	 and secuencia = '1'
	 and nlinea = '1';   -- se tiene que agregar tmb el nunmero de linea y la secuencia 
	 
	-- SE AGREGAN CAMPOS ADICIONALES DE SUCURSAL
    select sucursal
      into cSucursal
      from bdicheq:sc_maechq
     where cuenta = pCuenta;
    
    select nombre 
      into cSucursal_nombre 
      from bdinteg:si_sucursales  
     where sucursal = cSucursal;
    
    foreach 
        EXECUTE PROCEDURE bdicobranza:sp_obtenerposicion(cSucursal_nombre, ",")
        into vcuantos , vcuantos2
        
        exit foreach;
    end foreach
			
    IF vcuantos = -1  THEN
	
        -- select nombre, estado,ciudad, telefono1, gerente
          -- into cSucursal_nombre, vestado,vciudad, vtelefono, vgerente
          -- from bdinteg:si_sucursales  
         -- where sucursal = cSucursal;
		 
		select NVL(TRIM(s.nombre), " "), NVL(TRIM(p.cve_estado), " "), NVL(TRIM(p.cve_ciudad), " "), NVL(TRIM(s.telefono1), " "), NVL(TRIM(s.gerente), " ")
		  into cSucursal_nombre, vestado,vciudad, vtelefono, vgerente
          from bdinteg:si_sucursales AS s,
               bdinteg:si_ptf        AS p
         where s.sucursal = p.id_ptf
		   and s.sucursal = cSucursal
           and p.tipo = 'S';
 
    ELSE
        -- select substr ( nombre, 1, vcuantos - 1), estado,ciudad, telefono1, gerente
          -- into cSucursal_nombre, vestado,vciudad, vtelefono, vgerente
          -- from bdinteg:si_sucursales  
         -- where sucursal = cSucursal;
				 
	    select NVL(TRIM(substr ( s.nombre, 1, vcuantos - 1)), " "), NVL(TRIM(p.cve_estado), " "), NVL(TRIM(p.cve_ciudad), " "), NVL(TRIM(s.telefono1), " "), NVL(TRIM(s.gerente), " ")
          into cSucursal_nombre, vestado,vciudad, vtelefono, vgerente
          from bdinteg:si_sucursales AS s,
               bdinteg:si_ptf        AS p
         where s.sucursal = p.id_ptf
		   and s.sucursal = cSucursal
           and p.tipo = 'S';
		 
    END IF
	
    select NVL(TRIM(nombre), " ") 
      into vciudad
      from bdinteg:si_ciudades 
     where estado = vestado
       and ciudad = vciudad;
     
    select NVL(TRIM(siglas), " ") 
      into vestado
      from bdinteg:si_estados 
     where estado = vestado;
	 
	IF cSucursal_nombre is null or cSucursal_nombre = "" THEN
	   LET cSucursal_nombre = " ";
	END IF;

	IF vestado is null or vestado = "" THEN
	   LET vestado = " ";
	END IF;

	IF vciudad is null or vciudad = "" THEN
	   LET vciudad = " ";
	END IF;

	IF vtelefono is null or vtelefono = "" THEN
	   LET vtelefono = " ";
	END IF;

	IF vgerente is null or vgerente = "" THEN
	   LET vgerente = " ";
	END IF;	   
    
    RETURN vcodret, dFecha_emision, cNum_cte, cNum_Tarjeta, cNombre_cte, cDireccion_cte, cDireccion_col, cDireccion_del, 
           cEdo_cd, cSucursal_nombre, cRFC_Cliente, cCP, cClabe, cCurp, dFechaAlta, dFechaInicio, dFecha_emision, 
           cSucursal, mSaldoAnterior, mDepositos, mInteresesPagados, mRetiros, mOtrosCargos, mIvaOtrosCargos, mSaldoCorte, 
           mSaldoPromedio, mRetencionIsr, mInteresesNetos, iDias, dTasaBruta, mTotRetirosEfec, mTotOtrosCargos, dGAT, cMensajeProducto, cPiePagina,
		   vestado,vciudad, vtelefono, vgerente, cNumProducto, dGATReal, iEnvioMovtos; --campos nuevos a retornar
    
    END;
    
END PROCEDURE;