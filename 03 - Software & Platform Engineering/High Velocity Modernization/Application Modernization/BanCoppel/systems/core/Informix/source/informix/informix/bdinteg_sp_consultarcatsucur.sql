CREATE PROCEDURE "informix".sp_consultarcatsucur( p_sEmpresa CHAR(3), p_sSucursal CHAR(4), p_sTipoSucursal CHAR(2) )
RETURNING CHAR(6)  AS retorno,
          CHAR(3)  AS empresa,
          CHAR(4)  AS sucursal,
          CHAR(40) AS nombre,
          CHAR(40) AS direccion1,
          CHAR(40) AS direccion2,
          CHAR(14) AS telefono,
          CHAR(40) AS gerente,
          CHAR(40) AS subgerente,
          CHAR(2)  AS tpo_sucursal;
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE iDesErr          CHAR(80);
    DEFINE v_sValRetorno    CHAR(6);
    DEFINE v_sEmpresa       CHAR(3);
    DEFINE v_sSucursal      CHAR(4);
    DEFINE v_sNombre        CHAR(40);
    DEFINE v_sDireccion1    CHAR(40);
    DEFINE v_sDireccion2    CHAR(40);
    DEFINE v_sTelefono1     CHAR(14);
    DEFINE v_sGerente       CHAR(40);
    DEFINE v_sSubgerente    CHAR(40);
    DEFINE v_sTipo_sucursal CHAR(2);
    
    LET iSqlErr          = 0;
    LET iSamErr          = 0;
    LET iDesErr          = '';
    LET v_sValRetorno    = '000001';
    LET v_sEmpresa       = '';
    LET v_sSucursal      = '';
    LET v_sNombre        = '';
    LET v_sDireccion1    = '';
    LET v_sDireccion2    = '';
    LET v_sTelefono1     = '';
    LET v_sGerente       = '';
    LET v_sSubgerente    = '';
    LET v_sTipo_sucursal = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, iDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_generarchivo_cecoban.err";
        TRACE ON;
        LET iSqlErr = iSqlErr;
        LET iSamErr = iSamErr;
        LET iDesErr = iDesErr;
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr,'','','','','','','','','';
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_generarchivo_cecoban.out";
    --- TRACE ON;
    
    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;
    
    -- // DEBE PROPORCIONARSE LA EMPRESA
    IF NVL(p_sEmpresa,'') = '' THEN
        RETURN v_sValRetorno,'','','','','','','','','';
    END IF;
    
    IF p_sSucursal = '' AND p_sTipoSucursal = '' THEN
        
        FOREACH
            SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf), +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   suc.empresa, ptf.id_ptf, suc.nombre, ptf.calle||' NUM '||ptf.num_ext as direccion1,
                   'COL. '||loc.desc_colonia||' C.P. '||loc.cp as direccion2, ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
              INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
              FROM bdinteg:si_ptf ptf
             INNER JOIN bdinteg:si_sucursales suc ON ( suc.sucursal = ptf.id_ptf AND ptf.tipo = suc.tipo )
              LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND loc.cp = loc.cp AND loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_localidad_cnbv = ptf.cve_localidad AND loc.cve_col = ptf.cve_col )
             WHERE ptf.id_ptf = ptf.id_ptf
             ORDER BY ptf.id_ptf
             
            IF v_sDireccion2 is null THEN
                LET v_sDireccion2 = '';
            END IF;
            
            LET v_sValRetorno = '000000';
            RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
        END FOREACH;
        
    ELIF p_sSucursal = '' AND p_sTipoSucursal <> '' THEN
    
        FOREACH
            SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf), +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   suc.empresa, ptf.id_ptf, suc.nombre, ptf.calle||' NUM '||ptf.num_ext as direccion1,
                   'COL. '||loc.desc_colonia||' C.P. '||loc.cp as direccion2, ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
              INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
              FROM bdinteg:si_ptf ptf
             INNER JOIN bdinteg:si_sucursales suc ON ( suc.sucursal = ptf.id_ptf AND ptf.tipo = suc.tipo AND suc.tpo_sucursal = p_sTipoSucursal )
              LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND loc.cp = loc.cp AND loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_localidad_cnbv = ptf.cve_localidad AND loc.cve_col = ptf.cve_col )
             WHERE ptf.id_ptf = ptf.id_ptf
             ORDER BY ptf.id_ptf
            
            IF v_sDireccion2 is null THEN
                LET v_sDireccion2 = '';
            END IF;
            
            LET v_sValRetorno = '000000';
            RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
        END FOREACH;
    
    ELIF p_sSucursal <> '' AND p_sTipoSucursal = '' THEN
        
        FOREACH
            SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf), +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   suc.empresa, ptf.id_ptf, suc.nombre, ptf.calle||' NUM '||ptf.num_ext as direccion1, 
                   'COL. '||loc.desc_colonia||' C.P. '||loc.cp as direccion2, ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
              INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
              FROM bdinteg:si_ptf ptf
             INNER JOIN bdinteg:si_sucursales suc ON ( suc.sucursal = ptf.id_ptf AND ptf.tipo = suc.tipo )
              LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND loc.cp = loc.cp AND loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_localidad_cnbv = ptf.cve_localidad AND loc.cve_col = ptf.cve_col )
             WHERE ptf.id_ptf = p_sSucursal
             ORDER BY ptf.id_ptf
            
            IF v_sDireccion2 is null THEN
                LET v_sDireccion2 = '';
            END IF;
            
            LET v_sValRetorno = '000000';
            
            RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
        END FOREACH;
    
    ELIF p_sSucursal <> '' AND p_sTipoSucursal <> '' THEN
    
        FOREACH
            SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf), +INDEX(bdinteg:si_sucursales idx_sucursal)}
                   suc.empresa, ptf.id_ptf, suc.nombre, ptf.calle||' NUM '||ptf.num_ext as direccion1,
                   'COL. '||loc.desc_colonia||' C.P. '||loc.cp as direccion2, ptf.tel1, suc.gerente, suc.subger, suc.tpo_sucursal
              INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
              FROM bdinteg:si_ptf ptf
             INNER JOIN bdinteg:si_sucursales suc ON ( suc.sucursal = ptf.id_ptf AND ptf.tipo = suc.tipo AND suc.tpo_sucursal = p_sTipoSucursal )
              LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND loc.cp = loc.cp AND loc.cve_estado = ptf.cve_estado AND loc.cve_mun = ptf.cve_mun AND loc.cve_localidad_cnbv = ptf.cve_localidad AND loc.cve_col = ptf.cve_col )
             WHERE ptf.id_ptf = p_sSucursal
             ORDER BY ptf.id_ptf
            
            IF v_sDireccion2 is null THEN
                LET v_sDireccion2 = '';
            END IF;
            
            LET v_sValRetorno = '000000';
            
            RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
        END FOREACH;
        
    END IF;
    
    /* ###################################################################################################################################################
    FOREACH
        SELECT {+INDEX(bdinteg:si_ptf idx_si_ptf_id_ptf),
                +INDEX(bdinteg:si_sucursales idx_sucursal)}
               suc.empresa, 
               ptf.id_ptf, 
               suc.nombre, 
               ptf.calle||' NUM '||ptf.num_ext as direccion1,
               NVL('COL. '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2, 
               ptf.tel1, 
               suc.gerente, 
               suc.subger, 
               suc.tpo_sucursal
          INTO v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal
          FROM bdinteg:si_ptf ptf
         INNER JOIN bdinteg:si_sucursales suc ON ( suc.sucursal = ptf.id_ptf AND 
                                                   ptf.tipo = suc.tipo )
          LEFT OUTER JOIN bdinteg:si_localidades loc ON ( loc.id > 0 AND 
                                                          loc.cp = loc.cp AND
                                                          loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
         WHERE ptf.id_ptf = NVL(p_sSucursal, ptf.id_ptf) 
           AND suc.tpo_sucursal = NVL(p_sTipoSucursal, suc.tpo_sucursal)
         ORDER BY ptf.id_ptf
        
        LET p_sTipoSucursal = p_sTipoSucursal;
        LET v_sValRetorno = '000000';
        
        RETURN v_sValRetorno, v_sEmpresa, v_sSucursal, v_sNombre, v_sDireccion1, v_sDireccion2, v_sTelefono1, v_sGerente, v_sSubgerente, v_sTipo_sucursal WITH RESUME;
    END FOREACH;
    ################################################################################################################################################### */
    
    END;
    
END PROCEDURE;