CREATE PROCEDURE "informix".sp_ctessincaptacion(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vdesccodret      CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vfechahoy        DATE; 
    DEFINE vfecha_inicial   DATE;
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    DEFINE vmincred         CHAR(20);
    DEFINE vmaxcred         CHAR(20);
    DEFINE vfecha           CHAR(8);
    DEFINE vsql             CHAR(500);
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vfecha_alta      DATE;
    DEFINE vapell_paterno   CHAR(26);
    DEFINE vapell_materno   CHAR(26);
    DEFINE vnombre          CHAR(52);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vtelefono1       CHAR(13);
    DEFINE vtelefono2       CHAR(13);
    DEFINE vtelefono3       CHAR(13);
    DEFINE vextension	    CHAR(5);
    
    LET vcodret1        = "000";
    LET vcodret2        = "000";
    LET vdesccodret     = " ";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vfechahoy       = "";
    LET vfecha_inicial  = "";
    LET vmincta         = '';
    LET vmaxcta         = '';
    LET vmincred        = '';
    LET vmaxcred        = '';
    LET vfecha          = '';
    LET vsql            = '';
    
    LET vnumcte         = "";
    LET vfecha_alta     = "";
    LET vapell_paterno  = "";
    LET vapell_materno  = "";
    LET vnombre         = "";
    LET vsexo           = "";
    LET vtelefono1      = "";
    LET vtelefono2      = "";
    LET vtelefono3      = "";
    LET vextension      = "";

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vdesccodret, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET debug file to "/tmp/sp_ctessincaptacion.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // Obtiene la fecha del dia de hoy
    SELECT fecha_hoy
      INTO vfechahoy
      FROM bdinteg:si_fechas
     WHERE empresa = pempresa;
     
    IF LPAD(DAY(vfechahoy), 2, '0') IN('01','02','03','04','05','06','07') THEN
    
        TRUNCATE TABLE bdicheq:sc_ctessincaptacion;
        
        SELECT MIN(num_credito), MAX(num_credito)
          INTO vmincred, vmaxcred
          FROM bdicred:sd_maecred;
        
        SELECT UNIQUE numcte
          FROM bdicred:sd_maecred a,
		       bdicred:sd_maesdos b
         WHERE a.empresa = pempresa
		   AND a.num_credito = b.num_credito
           AND a.num_credito BETWEEN vmincred AND vmaxcred
           AND a.num_credito NOT IN(SELECT credito_externo FROM bdicred:sd_maecredcrd)
           AND a.status_cred IN ('AA','E1')
		   AND (b.monto_vencido + b.mto_venc_trasp) = 0
          INTO TEMP tmp_ctes_cred WITH NO LOG;
        CREATE INDEX idx_ctescred ON tmp_ctes_cred(numcte) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_cred;
        
        SELECT MIN(cuenta), MAX(cuenta)
          INTO vmincta, vmaxcta
          FROM sc_maechq;
          
        SELECT UNIQUE num_cte
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND status_cta <> '2'
           AND producto <> '2000'
          INTO TEMP tmp_ctes_chq WITH NO LOG;
        CREATE INDEX idx_cteschq ON tmp_ctes_chq(num_cte) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctes_chq;
        
        SELECT numcte
          FROM tmp_ctes_cred
         WHERE numcte NOT IN(SELECT num_cte FROM tmp_ctes_chq)
          INTO TEMP tmp_ctessinchq WITH NO LOG;
        CREATE INDEX idx_ctessinchq ON tmp_ctessinchq(numcte) USING BTREE FILLFACTOR 99;
        UPDATE STATISTICS MEDIUM FOR TABLE tmp_ctessinchq;
        
        FOREACH WITH HOLD
            SELECT ctes.numcte
              INTO vnumcte
              FROM bdinteg:si_cliente ctes,
                   tmp_ctessinchq tmp
             WHERE ctes.numcte = tmp.numcte 
               AND TRUNC((vfechahoy - ctes.fecha_alta) / 30) = 6
            
            IF vcomienza = -1 THEN
                LET vcomienza = 0;
                LET ven_transacc = 1; 
                BEGIN WORK;
            END IF;
            
            -- // Obtiene los datos personales del cliente
            SELECT cte.fecha_alta, TRIM(cte.apell_paterno), TRIM(cte.apell_materno), TRIM(cte.nombre1)||' '||TRIM(cte.nombre2),
                   pf.sexo, tel1.telefono, tel2.telefono, tel3.telefono, tel3.extension
              INTO vfecha_alta, vapell_paterno, vapell_materno, vnombre,vsexo, vtelefono1, vtelefono2, vtelefono3, vextension
              FROM bdinteg:si_cliente cte
              left outer join bdinteg:si_telefonos_actual tel1 on (tel1.numcte = cte.numcte and tel1.tipo_tel = 1)
			  left outer join bdinteg:si_telefonos_actual tel2 on (tel2.numcte = cte.numcte and tel2.tipo_tel = 2)
			  left outer join bdinteg:si_telefonos_actual tel3 on (tel3.numcte = cte.numcte and tel3.tipo_tel = 3)
			  LEFT OUTER JOIN bdinteg:si_ctepf pf ON (pf.numcte = cte.numcte)
             WHERE cte.numcte = vnumcte;
               
            -- // Inserta datos en tabla sc_ctessincaptacion
            INSERT INTO sc_ctessincaptacion 
            ( numcte, fecha_alta, apell_paterno, apell_materno, nombre, sexo, telefono1, telefono2, telefono3, extension ) 
            VALUES 
            ( vnumcte, vfecha_alta, vapell_paterno, vapell_materno, vnombre, vsexo, vtelefono1, vtelefono2, vtelefono3, vextension );
            
            LET vcontador1 = vcontador1 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            IF vcontador3 >= 5000 THEN
                LET vcontador3 = 0;
                UPDATE STATISTICS MEDIUM FOR TABLE sc_ctessincaptacion;
                COMMIT WORK;
                BEGIN WORK;
            END IF;
            
            LET vnumcte         = "";
            LET vfecha_alta     = "";
            LET vapell_paterno  = "";
            LET vapell_materno  = "";
            LET vnombre         = "";
            LET vsexo           = "";
            LET vtelefono1      = "";
            LET vtelefono2      = "";
            LET vtelefono3      = "";
            LET vextension      = "";
            
        END FOREACH;
        
        IF ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
        
        LET vfecha = TO_CHAR(vfechahoy, '%d%m%Y');
        
        LET vsql = '';
        LET vsql = 'echo "UNLOAD TO /resplogifx/conciliachq/ctessincaptacion_'||vfecha||'.txt'||
                   ' SELECT numcte, fecha_alta, apell_paterno, apell_materno, nombre, sexo, telefono1, telefono2, telefono3, extension'||
                   ' FROM sc_ctessincaptacion;" > /resplogifx/conciliachq/ctessinchq.sql';
        SYSTEM vsql;
        LET vsql = '';
        --- LET vsql = "dbaccess bdicheq /resplogifx/conciliachq/ctessinchq.sql"; 
        LET vsql = "/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctessinchq.sql"; 
        SYSTEM vsql;
        LET vsql = '';
        
        LET vdesccodret = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";
        
    ELSE
        
        LET vcodret1 = "908";
        
        SELECT descripcion
          INTO vdesccodret
          FROM bdinteg:si_codret
         WHERE codigo_retorno = vcodret1
           AND sistema = '01';
          
        RETURN vcodret1, vcodret2, vdesccodret, vcontador1;
        
    END IF;

    RETURN vcodret1, vcodret2, vdesccodret, vcontador1;
    
    END;

END PROCEDURE;