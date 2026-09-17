CREATE PROCEDURE "informix".sp_sv_aprovisionamiento_oltp()
--EXECUTE PROCEDURE "informix".sp_sv_aprovisionamiento_oltp();
RETURNING VARCHAR (5) as rCODIGO_RETORNO, 
          VARCHAR (255) as rMENSAJE_RESPUESTA;

DEFINE vCODIGO_RETORNO VARCHAR(5);
DEFINE vMENSAJE_RETORNO VARCHAR(120);
DEFINE vsql             LVARCHAR(5000);
DEFINE vIndicadorProceso CHAR(10);	
DEFINE RUTA_ARCHIVOS     VARCHAR(100);
DEFINE RUTA_CARPETA      VARCHAR(100); 
DEFINE RUTA_LOGS         VARCHAR(100); 

DEFINE v_periodo_tc_ini   	DATE;	  		--periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  		--periodo_tc_fin
DEFINE v_periodo_anterior   DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 	INTEGER;		--dias_periodo_tc
DEFINE  v_periodo             DATE;

DEFINE SQLERR		INTEGER;
DEFINE ISAM_ERR		INTEGER;
DEFINE ERROR_INFO	VARCHAR(80); 
DEFINE v_cod_ret_otro	 CHAR(5);
 
LET vCODIGO_RETORNO = '00000';
LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
LET RUTA_ARCHIVOS = '/Interfaces_SmartVista/INTFZ_TDC_008';
--LET RUTA_ARCHIVOS = '/RESPALDOSNEW/Interfaces_SmartVista/INTFZ_TDC_008';
LET RUTA_CARPETA = '/Envio';
LET RUTA_LOGS = '/Logs';

  LET SQLERR = '';
  LET ISAM_ERR = '';
  LET ERROR_INFO = '';

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc
LET v_periodo_tc_ini   		  = " ";	--periodo_tc_ini
LET v_periodo_tc_fin   		  = " ";	--periodo_tc_fin
LET v_periodo=mdy(month(current),20, year(current));
LET v_cod_ret_otro = "000";

    --SET DEBUG FILE TO TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)||"/debug_sp_sv_aprovisionamiento_oltp.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO   TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)|| "/excep_sp_sv_aprovisionamiento_oltp.err.out" WITH APPEND;
            TRACE ON;
            
            IF  SQLERR <> 0  THEN
                LET vCODIGO_RETORNO = SQLERR;
                LET vMENSAJE_RETORNO = ISAM_ERR||' '||ERROR_INFO||' '||current ||' '||' Proceso =>'||vIndicadorProceso;
                RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
            END IF;
			
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ; 
        SET LOCK MODE TO WAIT 3;

    
----------------------------------------------------------------------------------

    -- Obtener el nombre completo del cliente
    LET vIndicadorProceso =  '1.0.0.0.#';
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||   
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_cliente_sv.unl' ||
                 ' SELECT a.numcte,' ||
                 ' TRIM(NVL(a.nombre1, '' '')) || '' '' || TRIM(NVL(a.nombre2, '' '')) || '' '' || TRIM(NVL(a.apell_paterno, '' '')) || '' '' || TRIM(NVL(a.apell_materno, '' '')) nombre,'||
                 ' NVL(a.rfc, a.rfc_alterno) rfc,'||
                 ' NVL(SUBSTR(YEAR(a.fecha_alta), 3, 2), '' '') fecha_alta,' ||
                 ' a.fecha_alta,'||
                 ' a.sucursal '||       
                 ' FROM bdinteg:si_cliente a '||
                 ' INNER JOIN '||
                 ' bdinteg:si_credito_sv s ' ||
                 ' ON ( s.num_producto = ''4900'' '||
                 ' and a.numcte=s.numcte); "> '|| TRIM(RUTA_ARCHIVOS) ||'/si_cliente_sv.sql';
    system vsql;   

   LET vIndicadorProceso =  '1.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_cliente_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '1.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_cliente_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '1.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_cliente_sv.unl';
        system vsql;
      
	end if	

    -- Obtener la direcciÃ³n (Ãºltima direcciÃ³n activa tipo 1)
	LET vIndicadorProceso =  '1.0.3.#';
    LET vsql= '';
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_direcciones_sv.unl' ||  
              ' WITH maxsec AS ( '|| 
              ' SELECT a.numcte, MAX(a.secuencia) AS secuencia '||   
              ' FROM bdinteg:si_direcciones_actual a '||  
              ' INNER JOIN '|| 
              ' bdinteg:si_credito_sv s '|| 
              ' ON ( s.num_producto =  ''4900'' '||  
              ' and a.numcte=s.numcte) '||  
              ' WHERE  a.tipo_dir =  ''1'' '||
              ' GROUP BY a.numcte ) '||  	  
              ' SELECT b.numcte, '||  
              ' NVL(b.numeroextcalle,  ''0'') numeroextcalle, '|| 
              ' NVL(b.numerointcalle,  ''0'') numerointcalle, '|| 
              ' NVL(b.departamento,  ''0'') departamento, '|| 
              ' NVL(b.cod_postal,  ''0'') cod_postal, '|| 
              ' NVL(b.entre_calles,  '' '') entre_calles, '|| 
              ' NVL(b.observaciones,  '' '') observaciones, '|| 
              ' NVL(b.numerociudad, '' '') numerociudad, '|| 
              ' NVL(b.numerocolonia,  '' '') numerocolonia, '|| 
              ' NVL(b.numerocalle,  '' '') numerocalle, '|| 
              ' NVL(b.estado, '' '') estado, '||
              ' TRIM(NVL(c.nombrecalle,'' '')) nombrecalle, '||
              ' TRIM(NVL(e.nombre,'' '')) nombreciudad, '||
              ' TRIM(NVL(f.nombre,'' '')) estado, '||
              ' d.nombrezona, '||			
              ' d.centro, '|| 
              ' d.jefegrupozona, '||			
              ' d.supervisorzona, '||
			  ' d.numerociudadcoppel, '||     
              ' d.numerocolonia, '||
              ' LPAD(p.num_region,2,0) num_region ,'||
              ' LPAD(p.num_ciudad_banco,4,0) num_ciudad_banco,'||
              ' LPAD(p.num_ciudad_coppel,3,0) num_ciudad_coppel'||
              ' FROM bdinteg:si_direcciones_actual b '||  
              ' INNER JOIN maxsec s '||   
              ' ON (b.numcte = s.numcte '||   
              ' AND b.secuencia = s.secuencia) '||
			  ' left join '||
              ' bdinteg:si_estados f '||
              ' on (f.estado=b.estado )'||
			  ' LEFT join '||               
			  ' bdinteg:si_ciudades e '||
              ' on( e.pais=b.pais '||
              ' and e.estado=b.estado '||
              ' and e.ciudad_coppel=b.numerociudad ) '|| 			  
              ' LEFT join '|| 
              ' bdinteg:si_catcalles c '||
              ' on (c.numerocalle=b.numerocalle) '||       
              ' left join'||
              ' bdinteg:si_catzonas d'||
              ' on( d.numerociudad=b.numerociudad '||
              ' and d.numerocolonia=b.numerocolonia )'||
              ' inner join'||
              ' bdicred:sd_centrosimpresion_coppel p'||
              ' on(p.num_ciudad_banco =b.numerociudad);"> '|| TRIM(RUTA_ARCHIVOS) ||'/si_direcciones_sv.sql';
    system vsql;   

    LET vIndicadorProceso =  '2.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_direcciones_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '2.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_direcciones_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '2.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_direcciones_sv.unl';
        system vsql;

	end if	  

    -- Obtener el correo electrÃ³nico mÃ¡s reciente
    LET vIndicadorProceso =  '3.0.0.0.#';    
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/si_correos_sv.unl' ||  
              ' with correo(numcte,secuencia) as( ' || 
              ' select a.numcte, NVL(MAX(a.secuencia), 0) ' || 
              ' FROM bdinteg:si_correos a ' || 
              ' inner join ' || 
              ' bdinteg:si_credito_sv s ' || 
              ' ON ( s.num_producto = ''4900'' ' ||  
              ' and a.numcte=s.numcte' || 
              ' and a.status_correo = ''A'') ' ||  
              ' group by  a.numcte) ' ||            
              ' SELECT c.numcte,NVL(c.correo_elec, '' '') ' ||  
              ' FROM bdinteg:si_correos c ' || 
              ' inner join ' || 
              ' correo o' || 
              ' on (c.numcte=o.numcte ' || 
              ' and c.secuencia=o.secuencia ' || 
              ' and c.status_correo = ''A'' ); "> '|| TRIM(RUTA_ARCHIVOS) ||'/si_correos_sv.sql';  
    system vsql;   

    LET vIndicadorProceso =  '3.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/si_correos_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '3.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/si_correos_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '3.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/si_correos_sv.unl';
        system vsql;

	end if	      

    LET vIndicadorProceso =  '4.0.0.0.#';
    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/sucursales_sv.unl' ||  
              ' with cliente(numcte, sucursal ) as( ' || 
              ' select  a.numcte, a.sucursal ' ||         
              ' FROM bdinteg:si_cliente a ' ||   
              ' INNER JOIN ' ||   
              ' bdinteg:si_credito_sv s ' ||   
              ' ON ( s.num_producto = ''4900'' ' || 
              ' and a.numcte=s.numcte) ' ||              
              ' ) SELECT c.numcte,'||
              ' d.sucursal,'||
              ' d.nombre,'||
              ' d.gerente,'||
              ' d.iva,'||
              ' nvl(t.tel1,'' '') tel1 ' ||       
              ' FROM bdinteg:si_sucursales d ' || 
              ' inner join ' || 
              ' cliente c ' || 
              ' on (d.sucursal=c.sucursal) ' || 
              ' left join ' || 
              ' bdinteg:si_ptf t ' || 
              ' on ( t.id_ptf=c.sucursal ' || 
              ' and t.tipo=''S''); "> '|| TRIM(RUTA_ARCHIVOS) ||'/sucursales_sv.sql';
    system vsql;   

    LET vIndicadorProceso =  '4.0.0.1.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/sucursales_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '4.0.0.2.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/sucursales_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '4.0.0.3.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/sucursales_sv.unl';
        system vsql;

	end if	  


    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>   
	
	--......................................
  
    LET vIndicadorProceso =  '6.0.0.0.#';
    let vsql='';
    let vsql ='rm -f '|| TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_oltp_sv.tar';    
    system vsql;  

    --......................................

    LET vIndicadorProceso =  '6.0.0.1.#';
    LET vsql = '';
	LET vsql = ' tar -cf ' ||  TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_oltp_sv.tar ' ||  TRIM(RUTA_ARCHIVOS)|| '/*_sv.unl ';
    SYSTEM vsql;

    --......................................

    LET vIndicadorProceso =  '6.0.0.2.#';  
	let vsql='';
    let vsql ='rm  -f '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.sql';
    system vsql;

    --......................................

    --LET vIndicadorProceso =  '6.0.0.3.#';
    let vsql='';
    let vsql ='rm -f '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.unl';    
    system vsql;

    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
    		
    
    End;
      RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
END PROCEDURE;