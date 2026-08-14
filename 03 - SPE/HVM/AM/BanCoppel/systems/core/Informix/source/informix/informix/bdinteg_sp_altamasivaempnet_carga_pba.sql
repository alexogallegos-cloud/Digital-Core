CREATE PROCEDURE "informix".sp_altamasivaempnet_carga_pba( pNombreArchivo CHAR(30) )
RETURNING CHAR(5);
       
    DEFINE Sql_Err          INTEGER;
    DEFINE Isam_Err         INTEGER;
    DEFINE Desc_Err         CHAR(50);
    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vCodRet3         CHAR(50);
    DEFINE vRuta            CHAR(50);
    DEFINE cSQL             CHAR(300);
    DEFINE vdFechaHoy       DATE;
    DEFINE vContador1       INTEGER;
    DEFINE vContador2       INTEGER;
    DEFINE vComienza        SMALLINT;
    DEFINE vTrxAbierta      SMALLINT;
    DEFINE vcNumEmp         CHAR(3);
    DEFINE vcExistArch      SMALLINT;
    DEFINE vcve_cte         CHAR(15);
    DEFINE vnombre1         CHAR(30);
    DEFINE vnombre2         CHAR(30);
    DEFINE vape_pat         CHAR(30);
    DEFINE vape_mat         CHAR(30);
    DEFINE vfecha_nac       CHAR(8);
    DEFINE vrfc             CHAR(15);
    DEFINE vcurp            CHAR(30);
    DEFINE vgenero          CHAR(1);
    DEFINE vtipo_id         CHAR(1);
    DEFINE vnum_id          CHAR(30);
    DEFINE vcalle           CHAR(30);
    DEFINE vno_ext          INTEGER;
    DEFINE vno_int          INTEGER;
    DEFINE vcolonia         CHAR(30);
    DEFINE vdel_mun         CHAR(30);
    DEFINE vciudad          CHAR(30);
    DEFINE vestado          CHAR(30);
    DEFINE vcod_pos         CHAR(10);
    DEFINE vpais            CHAR(4);
    DEFINE vocupacion       INTEGER;
    
    DEFINE vcValNulos       CHAR(1);
    DEFINE vcValNumeros     CHAR(1);
    DEFINE vcValFechas      CHAR(1);
    DEFINE vcValLetras      CHAR(1);
    DEFINE vcodretint01     SMALLINT;
    DEFINE vcodretint02     SMALLINT;
    DEFINE vcodretint03     SMALLINT;
    DEFINE vcodretint04     SMALLINT;
    DEFINE vcodretint05     SMALLINT;
    DEFINE vcodretint06     SMALLINT;
    DEFINE vcodretint07     SMALLINT;
    DEFINE vcodretint08     SMALLINT;
    DEFINE vcodretint09     SMALLINT;
    DEFINE vcodretint10     SMALLINT;
    DEFINE vcodretint11     SMALLINT;
    DEFINE vcodretint12     SMALLINT;
    DEFINE vcodretint13     SMALLINT;
    DEFINE viExisteCP       SMALLINT;
    
    DEFINE vArchivoCom          CHAR(15);  
    DEFINE vcNombreArchivoVal   CHAR(30);
    
    LET Sql_Err	    = 0;
    LET Isam_Err    = 0;
    LET Desc_Err    = '';
    LET vCodRet1    = '000';
    LET vCodRet2    = '';
    LET vCodRet3    = '';
    LET vRuta       = '';
    LET cSQL        = '';
    LET vdFechaHoy  = '';
    LET vContador1  = 0;
    LET vContador2  = 0;
    LET vComienza   = -1;
    LET vTrxAbierta = 0;
    LET vcNumEmp    = '';
    LET vcExistArch = 0;
    LET vcve_cte    = '';
    LET vnombre1    = '';
    LET vnombre2    = '';
    LET vape_pat    = '';
    LET vape_mat    = '';
    LET vfecha_nac  = '';
    LET vrfc        = '';
    LET vcurp       = '';
    LET vgenero     = '';
    LET vtipo_id    = '';
    LET vnum_id     = '';
    LET vcalle      = '';
    LET vno_ext     = 0;
    LET vno_int     = 0;
    LET vcolonia    = '';
    LET vdel_mun    = '';
    LET vciudad     = '';
    LET vestado     = '';
    LET vcod_pos    = '';
    LET vpais       = '';
    LET vocupacion  = 0;
    
    LET vcValNulos    = '0';
    LET vcValNumeros  = '0';
    LET vcValFechas   = '0';
    LET vcValLetras   = '0';
    LET vcodretint01  = -1;
    LET vcodretint02  = -1;
    LET vcodretint03  = -1;
    LET vcodretint04  = -1;
    LET vcodretint05  = -1;
    LET vcodretint06  = -1;
    LET vcodretint07  = -1;
    LET vcodretint08  = -1;
    LET vcodretint09  = -1;
    LET vcodretint10  = -1;
    LET vcodretint11  = -1;
    LET vcodretint12  = -1;
    LET vcodretint13  = -1;
    LET viExisteCP    = 0;
    
    LET vArchivoCom = 'quitarctrlm.cmd';
    LET vcNombreArchivoVal = TRIM(pNombreArchivo)||'.val'; 
    
    BEGIN
    
    ON EXCEPTION SET Sql_Err, Isam_Err, Desc_Err
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_carga.err";
        TRACE ON;
        IF Sql_Err <> 0 THEN
            LET vCodRet1 = Sql_Err;
            LET vCodRet2 = Isam_Err;
            LET vCodRet3 = Desc_Err;
            IF vTrxAbierta = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_carga.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 5; 
    
    IF EXISTS(SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'si_altamasivaempnet_tmp') THEN
        DROP TABLE bdinteg:"informix".si_altamasivaempnet_tmp;
    END IF;  
    
    CREATE TABLE bdinteg:"informix".si_altamasivaempnet_tmp  
      ( 
        cve_cte     char(15)    not null,
        nombre1     char(30)    not null,
        nombre2     char(30)            ,
        ape_pat     char(30)    not null,
        ape_mat     char(30)    not null,
        fecha_nac   char(8)     not null,
        rfc         char(15)    not null,
        curp        char(30)            ,
        genero      char(1)     not null,
        tipo_id     char(1)     not null,
        num_id      char(30)    not null,
        calle       char(30)    not null,
        no_ext      integer     not null,
        no_int      integer             ,
        colonia     char(30)    not null,
        del_mun     char(30)    not null,
        ciudad      char(30)    not null,
        estado      char(30)    not null,
        cod_pos     char(10)    not null,
        pais        char(4)     not null,
        ocupacion   integer
      )
    EXTENT SIZE 128 NEXT SIZE 64 LOCK MODE ROW;
    
    SELECT valor
      INTO vRuta
      FROM bdinteg:si_param
     WHERE empresa = '001'
       AND cod_param = 50;
    
    LET cSQL = '';
    LET cSQL = "sed -f "||TRIM(vRuta)||TRIM(vArchivoCom)||" "||TRIM(vRuta)||TRIM(pNombreArchivo)||" > "||TRIM(vRuta)||TRIM(vcNombreArchivoVal);
    SYSTEM cSQL;
    
    LET cSQL = '';
    LET cSQL = 'echo "LOAD FROM '||TRIM(vRuta)||TRIM(vcNombreArchivoVal)||' INSERT INTO si_altamasivaempnet_tmp" > '||TRIM(vRuta)||'altmasempnet.sql';
    SYSTEM cSQL;
    
    LET cSQL = '';
    LET cSQL = '/ifxsif01/bin/dbaccess bdinteg '||TRIM(vRuta)||'altmasempnet.sql';
    SYSTEM cSQL;
    
    CREATE INDEX "informix".idx_tmp_altmas ON "informix".si_altamasivaempnet_tmp(cve_cte) ONLINE; 

    ---UPDATE STATISTICS HIGH FOR TABLE si_altamasivaempnet_tmp;
    
    SELECT fecha_hoy
      INTO vdFechaHoy
      FROM bdinteg:si_fechas
     WHERE empresa = '001';
     
    SELECT COUNT(*)
      INTO vContador1
      FROM bdinteg:si_altamasivaempnet_tmp;
      
    IF vContador1 <= 0 THEN
        LET vCodRet1 = '180';
        RETURN vCodRet1;
    END IF;
    
    LET vcNumEmp = SUBSTR(pNombreArchivo, 2, 3);
    
    FOREACH WITH HOLD
        SELECT TRIM(cve_cte), TRIM(nombre1), TRIM(nombre2), TRIM(ape_pat), TRIM(ape_mat), fecha_nac, TRIM(rfc), TRIM(curp), TRIM(genero), tipo_id, 
               TRIM(num_id), TRIM(calle), no_ext, no_int, TRIM(colonia), TRIM(del_mun), TRIM(ciudad), TRIM(estado), TRIM(cod_pos), TRIM(pais), ocupacion 
          INTO vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vfecha_nac, vrfc, vcurp, vgenero, vtipo_id,
               vnum_id, vcalle, vno_ext, vno_int, vcolonia, vdel_mun, vciudad, vestado, vcod_pos, vpais, vocupacion 
          FROM bdinteg:si_altamasivaempnet_tmp
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
        END IF; 
        
        BEGIN WORK;
        LET vTrxAbierta = 1;
          
        IF ( vno_ext    is null ) OR 
           ( vcve_cte   is null   OR  vcve_cte = ''   ) OR 
           ( vnombre1   is null   OR  vnombre1 = ''   ) OR 
           ( vape_pat   is null   OR  vape_pat = ''   ) OR 
           ( vape_mat   is null   OR  vape_mat = ''   ) OR 
           ( vfecha_nac is null   OR  vfecha_nac = '' ) OR 
           ( vrfc       is null   OR  vrfc = ''       ) OR 
           ( vgenero    is null   OR  vgenero = ''    ) OR 
           ( vtipo_id   is null   OR  vtipo_id = ''   ) OR
           ( vnum_id    is null   OR  vnum_id = ''    ) OR 
           ( vcalle     is null   OR  vcalle = ''     ) OR 
           ( vcolonia   is null   OR  vcolonia = ''   ) OR 
           ( vdel_mun   is null   OR  vdel_mun = ''   ) OR 
           ( vciudad    is null   OR  vciudad = ''    ) OR 
           ( vestado    is null   OR  vestado = ''    ) OR 
           ( vcod_pos   is null   OR  vcod_pos = ''   ) OR 
           ( vpais      is null   OR  vpais = ''      ) THEN 
            LET vcValNulos = '0';
        ELSE
            LET vcValNulos = '1';
        END IF;
        
        CALL bdiprog:isnumeric(vno_ext)  RETURNING vcodretint01;
        
        IF ( vcodretint01 <> 1 ) THEN
            LET vcValNumeros = '0';
        ELSE
            LET vcValNumeros = '1';
        END IF;
        
        IF NOT ( ( SUBSTR(vfecha_nac, 1, 2) > 0    AND SUBSTR(vfecha_nac, 1, 2) < 32 ) AND 
                 ( SUBSTR(vfecha_nac, 3, 2) > 0    AND SUBSTR(vfecha_nac, 3, 2) < 13 ) AND 
                 ( SUBSTR(vfecha_nac, 5, 4) > 1900 AND SUBSTR(vfecha_nac, 5, 4) < 3000 ) ) THEN
            LET vcValFechas = '0';
        ELSE
            LET vcValFechas = '1';
        END IF;
        
        CALL bdiprog:isnumeric(vnombre1) RETURNING vcodretint02;
        CALL bdiprog:isnumeric(vnombre2) RETURNING vcodretint03;
        CALL bdiprog:isnumeric(vape_pat) RETURNING vcodretint04;
        CALL bdiprog:isnumeric(vape_mat) RETURNING vcodretint05;
        CALL bdiprog:isnumeric(vrfc)     RETURNING vcodretint06;
        CALL bdiprog:isnumeric(vgenero)  RETURNING vcodretint07;
        CALL bdiprog:isnumeric(vtipo_id) RETURNING vcodretint08;
        CALL bdiprog:isnumeric(vcalle)   RETURNING vcodretint09;
        CALL bdiprog:isnumeric(vcolonia) RETURNING vcodretint10;
        CALL bdiprog:isnumeric(vdel_mun) RETURNING vcodretint11;
        CALL bdiprog:isnumeric(vciudad)  RETURNING vcodretint12;
        CALL bdiprog:isnumeric(vestado)  RETURNING vcodretint13;
        
        IF ( vcodretint02 <> 0 ) OR ( vcodretint03 <> 0 ) OR ( vcodretint04 <> 0 ) OR ( vcodretint05 <> 0 ) OR ( vcodretint06 <> 0 ) OR ( vcodretint07 <> 0 ) OR 
           ( vcodretint08 <> 0 ) OR ( vcodretint09 <> 0 ) OR ( vcodretint10 <> 0 ) OR ( vcodretint11 <> 0 ) OR ( vcodretint12 <> 0 ) OR ( vcodretint13 <> 0 )  THEN
            LET vcValLetras = '0';
        ELSE
            LET vcValLetras = '1';
        END IF;
        
        SELECT COUNT(*)
          INTO viExisteCP
          FROM bdinteg:si_catsepomex
         WHERE d_codigo = vcod_pos
           AND d_asenta = d_asenta;
        
        IF vcValNulos = '1' AND vcValNumeros = '1' AND vcValFechas = '1' AND vcValLetras = '1' AND viExisteCP > 0 THEN
            INSERT INTO bdinteg:si_altamasivaempnet_det
            ( nombre_archivo, cod_empresa, cve_cte, nombre1, nombre2, ape_pat, ape_mat, fecha_nac, rfc, curp, genero,  
              tipo_id, num_id, calle, no_ext, no_int, colonia, del_mun, ciudad, estado, cod_pos, pais, ocupacion, status, numcte, cuenta, fecha_registro )
            VALUES
            ( pNombreArchivo, vcNumEmp, vcve_cte, vnombre1, vnombre2, vape_pat, vape_mat, vfecha_nac, vrfc, vcurp, vgenero, 
              vtipo_id, vnum_id, vcalle, vno_ext, vno_int, vcolonia, vdel_mun, vciudad, vestado, vcod_pos, vpais, vocupacion, '0', '', '', vdFechaHoy );
        END IF;
          
        COMMIT WORK;
        LET vTrxAbierta = 0;
    END FOREACH;
    
    SELECT COUNT(*)
      INTO vContador2
      FROM bdinteg:si_altamasivaempnet_det
     WHERE cod_empresa = vcNumEmp
       AND nombre_archivo = pNombreArchivo;
      
    IF vContador2 > 0 THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '1'
         WHERE cod_empresa = vcNumEmp
           AND nombre_archivo = pNombreArchivo;
    END IF;
    
    END;
    
    RETURN vCodRet1;
    
END PROCEDURE;