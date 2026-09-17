create procedure "informix".sp_sdodiario_mensual_resp()
       returning char(5);

   define vfecha_reporte            char(8);
   define vcodret                   char(6);
   define vsql                      char(500);
   define iSqlErr                   integer;
   define vfecha_hoy                date;
   define vdia                      char(2);
   define vmes                      char(2);
   define vanio                     char(4);
   define vflag                     char(1);
   define c_nom_archivo             char(100);
   define d_PrimerDiaMes            date;
   define d_PrimerDiaMesAnterior    date;
   define d_UltDiaMesAnterior       date;
   define cEmpresa                  char(3);
   define cRuta                     char(100);
   define c_num_proceso             char(4);
   define c_mensaje 		            char(80);
   define isam_err 		              integer;
   define error_info		            char(80);
   define vCod_ret                  char(6);
   define i_regs_x_arch             integer;
   define i_num_archs               integer;
   define i_cantregs_tabla          integer;
   define i                         smallint;
   define i_skip                    integer;
   define i_residuo                 integer;

   let vcodret                = "00000";
   let vsql                   = '';
   let iSqlErr                = 0;
   let vdia                   = '';
   let vmes                   = '';
   let vanio                  = '';
   let c_nom_archivo          = '';
   let d_PrimerDiaMes         = date(1);
   let d_PrimerDiaMesAnterior = date(1);
   let d_UltDiaMesAnterior    = date(1);
   let cEmpresa               = '001';
   let cRuta                  = '';
   let c_num_proceso          = '0400';
   let c_mensaje              = '';
   let isam_err               = 0;
   let error_info             = '';
   let vCod_ret               = '';
   let i_regs_x_arch          = 0;
   let i_num_archs            = 0;
   let i_cantregs_tabla       = 0;
   let i                      = 0;
   let i_skip                 = 0;
   let i_residuo              = 0;
   
BEGIN

   on exception set iSqlErr, isam_err, error_info
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
         let c_mensaje = error_info;
         
         CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, c_num_proceso, vcodret, c_mensaje, '02')
            RETURNING vCod_ret;
         
         return trim(vcodret);
      end if;
   end exception;

   
  --SET DEBUG FILE TO "/informix/macf/sp_sdodiario_mensual_resp.trc";
  --TRACE ON; 

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(cEmpresa, c_num_proceso, vcodret, c_mensaje, '01')
         RETURNING vCod_ret;

 
  select fecha_hoy,pri_dia_mes into vfecha_hoy, d_PrimerDiaMes from bdicred:sd_fechas where empresa = cEmpresa;

    
      
  let d_UltDiaMesAnterior    = d_PrimerDiaMes - 1 units day;
  let d_PrimerDiaMesAnterior = mdy(month(d_UltDiaMesAnterior),1,year(d_UltDiaMesAnterior));
 
   SELECT valor into cRuta  FROM "informix".sd_param  WHERE cod_param = '039';
   
   let vanio = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vanio;
     
   SET ISOLATION TO DIRTY READ;
  
 -- Créditos Reolventes
  --Obtener el número de registros que tendrá cada archivo de respaldo.
  SELECT valor::int INTO i_regs_x_arch
    FROM bdicred:sd_param
   WHERE cod_param = '410';
  
  SELECT count(*) INTO i_cantregs_tabla
    FROM bdicred:sd_sdodiario
   WHERE fecha = d_PrimerDiaMesAnterior;
  
   let i_num_archs = (i_cantregs_tabla/i_regs_x_arch);
   
   let i_residuo = mod(i_cantregs_tabla,i_regs_x_arch);
   
   if i_residuo > 0 then
      let i_num_archs = i_num_archs + 1; 
   end if;
   
 
    for i = 0 to i_num_archs - 1

        LET c_nom_archivo = TRIM(cRuta) || 'sd_sdodiario_'|| vfecha_reporte || '_' || i  || '.txt';
        
        if i = 0 then
            LET vsql = 'echo " unload to  ' || TRIM(c_nom_archivo) ||
                       ' SELECT limit ' ||  i_regs_x_arch || ' *'||
                        '  FROM bdicred:sd_sdodiario'||
                        ' WHERE fecha = ''' || d_PrimerDiaMesAnterior || ''' '||
                       ' " >' || TRIM(cRuta) || 'gen_sdodiario.sql';
            SYSTEM TRIM(vsql);
        else
            let i_skip = i_regs_x_arch * i; 

            LET vsql = 'echo " unload to  ' || TRIM(c_nom_archivo) ||
                       ' SELECT skip ' || i_skip || ' limit ' ||  i_regs_x_arch || ' *'||
                        '  FROM bdicred:sd_sdodiario'||
                        ' WHERE fecha = ''' || d_PrimerDiaMesAnterior || ''' '||
                       ' " >' || TRIM(cRuta) || 'gen_sdodiario.sql';
            SYSTEM TRIM(vsql);
     
        end if;
        
        LET vsql = '';
        LET vsql ='chmod 777 '|| TRIM(cRuta) ||'gen_sdodiario.sql';
        SYSTEM TRIM(vsql);
      
        LET vsql = '';
        LET vsql = 'dbaccess bdicred ' || TRIM(cRuta) || 'gen_sdodiario.sql';
        SYSTEM TRIM(vsql);
        
        LET vsql =  'gzip '||TRIM(c_nom_archivo);
        SYSTEM trim(vsql);
      
        LET vsql = '';
        LET vsql = 'rm ' || TRIM(cRuta) || 'gen_sdodiario.sql';
        SYSTEM TRIM(vsql);
   
        let c_nom_archivo = '';
        
    end for;

    --- Créditos a Plazo
     let i_regs_x_arch    = 0;
     let i_cantregs_tabla = 0;
     let i_num_archs      = 0;
     
     SELECT valor::int INTO i_regs_x_arch
      FROM bdicred:sd_param
     WHERE cod_param = '411';
  
    SELECT count(*) INTO i_cantregs_tabla
      FROM bdicred:sd_sdodiariocrd
     WHERE fecha = d_PrimerDiaMesAnterior;
    
     let i_num_archs = (i_cantregs_tabla/i_regs_x_arch);
    
     let i_residuo = mod(i_cantregs_tabla,i_regs_x_arch);
   
    if i_residuo > 0 then
      let i_num_archs = i_num_archs + 1; 
    end if;
    
    
     for i = 0 to i_num_archs - 1

        LET c_nom_archivo = TRIM(cRuta) || 'sd_sdodiariocrd_'|| vfecha_reporte || '_' || i  || '.txt';
        
        if i = 0 then
            LET vsql = 'echo " UNLOAD TO  ' || TRIM(c_nom_archivo) ||
                       ' SELECT LIMIT ' ||  i_regs_x_arch || ' *'||
                        '  FROM bdicred:sd_sdodiariocrd'||
                        ' WHERE fecha = ''' || d_PrimerDiaMesAnterior || ''' '||
                       ' " >' || TRIM(cRuta) || 'gen_sdodiario.sql';
            SYSTEM TRIM(vsql);
        else
            let i_skip = i_regs_x_arch * i; 

            LET vsql = 'echo " UNLOAD TO  ' || TRIM(c_nom_archivo) ||
                       ' SELECT skip ' || i_skip || ' limit ' ||  i_regs_x_arch || ' *'||
                        '  FROM bdicred:sd_sdodiariocrd'||
                        ' WHERE fecha = ''' || d_PrimerDiaMesAnterior || ''' '||
                       ' " >' || TRIM(cRuta) || 'gen_sdodiario.sql';
            SYSTEM TRIM(vsql);
     
        end if;
        
        LET vsql = '';
        LET vsql ='chmod 777 '|| TRIM(cRuta) ||'gen_sdodiario.sql';
        SYSTEM TRIM(vsql);
      
        LET vsql = '';
        LET vsql = 'dbaccess bdicred ' || TRIM(cRuta) || 'gen_sdodiario.sql';
        SYSTEM TRIM(vsql);
        
        LET vsql =  'gzip '||TRIM(c_nom_archivo);
        SYSTEM trim(vsql);
      
        LET vsql = '';
        LET vsql = 'rm ' || TRIM(cRuta) || 'gen_sdodiario.sql';
        SYSTEM TRIM(vsql);
   
        let c_nom_archivo = '';
        
    end for;
    
 
    CALL bdicobranza:sp_inserta_bitacora_cob(cEmpresa, c_num_proceso,'', '','03' ) RETURNING vCod_ret;

  return trim(vcodret);

END;
end procedure;