CREATE PROCEDURE "informix".sp_ctanvl2_genreporte(vfechpri DATE, vfechult DATE)

    RETURNING CHAR(5) ;

    DEFINE vfechpri     DATE;
    DEFINE vfechult     DATE;
    DEFINE cCodRet1     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE vSQL         LVARCHAR(2000);
    DEFINE vcStmt       CHAR(300);
    DEFINE vEmpresa     CHAR(3);
    DEFINE vFechrep     DATE;
    DEFINE vSQL2        CHAR(800);
    DEFINE Vfechac      CHAR(27);

    LET vfechpri    = '';
    LET vfechult    = '';
    LET cCodRet1    = '00000';
    LET iSqlErr        = 0;
    LET vSQL        = '';
    LET vcStmt      = '';
    LET vEmpresa    = '001';
    LET vFechrep    = '';
    LET vSQL2       = '';
    LET Vfechac     = '';

    BEGIN
        ON EXCEPTION SET iSqlErr

        /* PRUEBAS EN DESARROLLO */
        /* Para desarrollo la siguiente linea tiene que estar descomentada */
        --SET DEBUG FILE TO "/RESPALDOSNEW/Alfredo/sp_ctanvl2_genreporte.err";
        /* PRODUCCION */ 
        /* Para producion la linea tiene que estar descomentada  */
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_ctanvl2_genreporte.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1   = iSqlErr;
            RETURN cCodRet1;
        END IF;
        END EXCEPTION;

        /* PRUEBAS EN DESARROLLO */
         -- SET DEBUG FILE TO '/RESPALDOSNEW/Alfredo/sp_ctanvl2_genreporte.out';
        /* PRODUCCION */     
        --SET DEBUG FILE TO '/resplogifx/conciliachq/sp_ctanvl2_genreporte.out';
        --TRACE ON;

        -- valida si las fechas enviadas en el SP estan vacias 
        IF ( vfechpri is null OR vfechpri = '' OR vfechult is null OR vfechult = '' ) THEN
                /*  Consulta el primer dia del mes anterior  y tambien el ultimo dia del mes anterior  */
            SELECT  DATE(pri_dia_mes - 1 UNITS MONTH), DATE(pri_dia_mes - 1  UNITS DAY) 
                into vfechpri,vfechult
            FROM  bdicheq:sc_fechas 
                where empresa = vEmpresa;
        END IF;

        SELECT  fecha_hoy
            into  vFechrep
        from  bdicheq:sc_fechas 
            where empresa = '001';
        
        LET Vfechac = 'ctanvl2_genreporte_'||TO_CHAR(vFechrep,'%d%m%Y');

        --Genera el archivo de reporte 


        LET vSQL = '';
        LET vSQL = 
        'echo "SET ISOLATION TO DIRTY READ; '||
        'UNLOAD TO /RESPALDOSNEW/'|| Vfechac ||'.txt '||
        --'UNLOAD TO /RESPALDOSNEW/Alfredo/CuentaClicReporteMensual.txt '||
        'SELECT a.num_cte,'||
            'd.cod_postal,'||
            'e.nacionalidad,'||
            'a.cuenta,'||
            'f.num_tarjeta,'||
            'f.expiracion,'||
            't.telefono,'||
            'c.tpo_persona,'||
            'e.sexo,'||
            'a.producto,'||
            'a.sucursal,'||
            'a.sdo_actual,'||
            ''''||'0'||''' as intereses,'||
            'TO_CHAR(b.fecha_alta, '''||'%d/%m/%Y'||'''  ) AS fecha_alta,'||
            'a.fecultdep,'||
            'a.fecultret,'||
            'a.status_cta,'||
            'TRIM(c.nombre1) as nombre,'||
            'TRIM(c.nombre2) nombre2,'||
            'TRIM(c.apell_paterno) apellido_paterno , '||
            'TRIM(c.apell_materno) apellido_materno '||
        'FROM  sc_maechq as a '||
        'LEFT  JOIN  sc_maenoc as b ON (b.cuenta = a.cuenta) '||
        'LEFT OUTER JOIN bdinteg:si_cliente as c ON (c.numcte = a.num_cte)  '||
        'LEFT OUTER JOIN bdinteg:si_direcciones_actual  as d  ON ( d.numcte = a.num_cte ) AND  tipo_dir = '''||'1'||'''  '||
        'LEFT OUTER JOIN bdinteg:si_ctepf e ON (e.numcte =  a.num_cte ) '||
        'LEFT OUTER JOIN bdicheq:sc_tarjeta f ON (f.cuenta = a.cuenta) AND status_tar = '''||'A'||''' '||
        'LEFT OUTER JOIN bdinteg:si_telefonos t ON (t.numcte = a.num_cte) AND tipo_tel = '''||'2'||'''  AND status_tel = '''||'A'||'''  '||
        'WHERE  a.producto = '''|| '2900' ||''' '||
        'AND    b.fecha_alta '||
        'BETWEEN '''|| vfechpri ||'''  '||
        'AND '''|| vfechult ||''' ; " > /RESPALDOSNEW/CuentaClicReporteMensual.sql';
        

            SYSTEM vSQL;
            -- ejecuta el SQL de la consulta anterior
            LET vcStmt = '/ifxsif01/bin/dbaccess bdicheq /RESPALDOSNEW/CuentaClicReporteMensual.sql';
            SYSTEM vcStmt;

            RETURN cCodRet1;

    END;

END PROCEDURE;