CREATE PROCEDURE "informix".sp_sv_aprovisionamiento_aclaraciones()
--EXECUTE PROCEDURE "informix".sp_sv_aprovisionamiento_aclaraciones();
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

DEFINE v_dia_tc_ini   	integer;	  		--periodo_tc_ini
DEFINE v_dia_tc_fin   	integer;	  		--periodo_tc_fin
DEFINE v_mes_tc_ini   	integer;	  		--periodo_tc_ini
DEFINE v_mes_tc_fin   	integer;	  		--periodo_tc_fin
DEFINE v_anio_tc_ini   	integer;	  		--periodo_tc_ini
DEFINE v_anio_tc_fin   	integer;	  		--periodo_tc_fin

DEFINE SQLERR		INTEGER;
DEFINE ISAM_ERR		INTEGER;
DEFINE ERROR_INFO	VARCHAR(80); 
DEFINE v_cod_ret_otro	 CHAR(5);
 
LET vCODIGO_RETORNO = '00000';
LET vMENSAJE_RETORNO = 'El proceso es ejecutado exitosamente.';
LET RUTA_ARCHIVOS = '/Interfaces_SmartVista/INTFZ_TDC_008';
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

LET v_dia_tc_ini=0;	  		--periodo_tc_ini
LET v_dia_tc_fin=0;	  		--periodo_tc_fin
LET v_mes_tc_ini=0;	  		--periodo_tc_ini
LET v_mes_tc_fin=0;	  		--periodo_tc_fin
LET v_anio_tc_ini=0;  		--periodo_tc_ini
LET v_anio_tc_fin=0;  		--periodo_tc_fin

    --SET DEBUG FILE TO TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)||"/debug_sp_sv_aprovisionamiento.out";
    --TRACE ON;

    BEGIN

        ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
            
            SET DEBUG FILE TO   TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_LOGS)|| "/excep_sp_sv_aprovisionamiento.err.out" WITH APPEND;
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

   

-------------------------------------------------------------
--Aclaraciones
-------------------------------------------------------------
    --PERIODO ANTERIOR	
	LET vIndicadorProceso =  '5.0.0.0.#';
	EXECUTE PROCEDURE bdicred:sp_mes_siguiente(v_periodo,-1,DAY(v_periodo))
		INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;

	LET vIndicadorProceso =  '5.0.0.1.#';
	--IF v_cod_ret_otro <> "000" AND cod_ret = "000" THEN
	--	LET cod_ret = v_cod_ret_otro;
	--END IF

	--PERIODO
	LET vIndicadorProceso =  '5.0.0.2.#';
	LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
	LET v_periodo_tc_fin = v_periodo;

	--DIAS DEL PERIODO
	LET vIndicadorProceso =  '5.0.0.3.#';
	LET v_dias_periodo_tc = (v_dias_periodo_tc * -1) ;


    LET v_dia_tc_ini=day(v_periodo_tc_ini);
    LET v_mes_tc_ini=month(v_periodo_tc_ini);
    LET v_anio_tc_ini=year(v_periodo_tc_ini);

    LET v_dia_tc_fin=day(v_periodo_tc_fin);
    LET v_mes_tc_fin=month(v_periodo_tc_fin);
    LET v_anio_tc_fin=year(v_periodo_tc_fin);

    LET vsql= '';
    --LET vsql= 'echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3;' ||  
    LET vsql= 'echo " UNLOAD TO '||trim(RUTA_ARCHIVOS)||'/aclaraciones_sv.unl' ||  
              ' with aclaracion (pky_producto,numero_cuenta,num_cliente,numero_tarjeta,fechacaptura,folio_csuac,importereclamado,fky_tipo_evento,fky_producto,pky_aclaracion) as ( ' ||
              ' select pro.pky_producto, ' ||
              ' pro.numero_cuenta, ' ||
              ' pro.num_cliente, ' ||
              ' pro.numero_tarjeta, ' ||
              ' acl.fechacaptura, ' || 
              ' acl.folio_csuac, ' ||
              ' acl.importereclamado, ' ||
              ' acl.fky_tipo_evento, ' ||
              ' acl.fky_producto, ' ||
              ' acl.pky_aclaracion ' ||
              ' from bdiaclaracion:acl_producto pro ' ||
              ' INNER JOIN ' ||    
              ' bdinteg:si_credito_sv s ' ||     
              ' ON ( s.num_producto = ''4900'' ' ||  
              ' and pro.num_cliente=s.numcte) ' ||
              ' inner join ' || 
              ' bdiaclaracion:acl_aclaracion  acl ' || 
              ' on (acl.fky_producto =pro.pky_producto) ' ||
              ' where (acl.fechacaptura >=  mdy('||v_mes_tc_ini||','||v_dia_tc_ini||','||v_anio_tc_ini||') AND acl.fechacaptura <= mdy('|| v_mes_tc_fin||','||v_dia_tc_fin||','||v_anio_tc_fin||'))'||
              ' and acl.fky_estatus_aclaracion = 2 ) ' ||     
              ' select  '||
              ' a.numero_cuenta, ' || 
              ' a.fechacaptura,'||
              ' a.folio_csuac,'||
              ' mov.fechahora, ' || 
              ' eve.descripcion, ' || 
              ' a.importereclamado ' || 
              ' from aclaracion a ' ||  
              ' inner join ' ||
              ' bdiaclaracion:acl_tipo_evento eve ' ||
              ' on (eve.pky_tipo_evento=a.fky_tipo_evento ) ' ||
              ' inner join ' ||
              ' bdiaclaracion:acl_movimiento mov ' ||
              ' on (mov.fky_aclaracion=a.pky_aclaracion)"> '|| TRIM(RUTA_ARCHIVOS) ||'/aclaraciones_sv.sql';
     system vsql;

    LET vIndicadorProceso =  '5.0.0.4.#';
	let vsql='';
    let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||'/aclaraciones_sv.sql';
    system vsql;

    LET vIndicadorProceso =  '5.0.0.5.#';
	let vsql='';
    let vsql= 'dbaccess bdicred '|| TRIM(RUTA_ARCHIVOS) ||  '/aclaraciones_sv.sql';
	system vsql;
    
    IF SQLCODE=0 THEN

        LET vIndicadorProceso =  '5.0.0.6.#';
        let vsql='';
        let vsql= 'chmod +x '|| TRIM(RUTA_ARCHIVOS) ||  '/aclaraciones_sv.unl';
        system vsql;

	end if	  

    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 

    LET vIndicadorProceso =  '6.0.0.0.#';
    LET vsql = '';   
    LET vsql = ' tar -cf ' ||  TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_aclaraciones_sv.tar ' ||  TRIM(RUTA_ARCHIVOS)|| '/*_sv.unl ';
	--LET vsql = ' tar -cvf - '  ||  TRIM(RUTA_ARCHIVOS) || '/*_sv.unl  | compress > ' ||  TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_aclaraciones_sv.tar.Z ';
	--LET vsql = ' tar -cf /Interfaces_SmartVista/INTFZ_TDC_008/Recepcion/aprovisionamiento_aclaraciones_sv.tar ' ||  TRIM(RUTA_ARCHIVOS) || '/ aclaraciones_sv.unl ';
    SYSTEM vsql;

    --......................................
/*
    LET vIndicadorProceso =  '6.0.0.1.#';
    LET vsql = '';
    LET vsql = '  gzip -f -k ' ||  TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/aprovisionamiento_aclaraciones_sv.tar';
    SYSTEM vsql;
*/    
    --......................................

    LET vIndicadorProceso =  '6.0.0.1.#';  
	let vsql='';
    let vsql ='rm  '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.sql';
    system vsql;

    --......................................

    LET vIndicadorProceso =  '6.0.0.2.#';
    let vsql='';
    let vsql ='rm  '|| TRIM(RUTA_ARCHIVOS) || '/*_sv.unl';    
    system vsql;

    --......................................
/*
    LET vIndicadorProceso =  '6.0.0.4.#';
    let vsql='';
    let vsql ='rm  '|| TRIM(RUTA_ARCHIVOS) || TRIM(RUTA_CARPETA) || '/*_sv.tar';    
    system vsql;    
*/
    -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>		
    
    End;
      RETURN vCODIGO_RETORNO, vMENSAJE_RETORNO;
END PROCEDURE;