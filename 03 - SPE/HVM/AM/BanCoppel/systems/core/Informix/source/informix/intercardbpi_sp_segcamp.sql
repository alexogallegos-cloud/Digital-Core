CREATE PROCEDURE "informix".sp_segcamp(pcodgironeg varchar(1),pinfreceptor varchar(40),paniome varchar(6))
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vsql                    char(1150);
DEFINE  vinfreceptor            varchar(40);
DEFINE  vcodgironegs            varchar(4);
DEFINE  vaniomes                varchar(6);

-------------- control de errores---------

--SET DEBUG FILE TO "/informix/resplogifx/segcamp.out";
--TRACE ON;
BEGIN 
 ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
 END EXCEPTION; 
 
 ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
                  if error_info ='informix.paso_camp' then
				     drop table paso_camp;
				  end if		    END IF;    
 END EXCEPTION WITH RESUME;

LET  vaniomes = paniome; 
LET  vinfreceptor = pinfreceptor;
LET  vcodgironegs = pcodgironeg;
        
            

    CREATE TABLE "informix".paso_camp(
	        codgironeg          varchar(4),
		    descgironeg       	varchar(80),
			idreceptor          varchar(4),
			infreceptor         varchar(40),
	        transacciones     	integer,
			monto               decimal(19,4),
			promedio			decimal(19,4),
			producto            varchar(4),
			periodo             varchar(6)
	)EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
----------------------------------------------------
-------Cuerpo de SP Consulta Seguimiento a Campaña.
 IF (vcodgironegs <> '' and vinfreceptor <> '' and  vaniomes <> '' )THEN
 
 
 set isolation to dirty read;
    insert  into paso_camp(codgironeg,descgironeg,idreceptor,infreceptor,transacciones,monto,promedio,producto,periodo)
	select codgironeg,descgironeg,idreceptor,infreceptor,transacciones,monto,promedio,producto,periodo 
	from intercard:tempfac_establecimiento
	where periodo = vaniomes
	and infreceptor LIKE  '%'||vinfreceptor||'%';

			  
			    
	   let vsql = '';
	   let vsql = ' echo "Giro de Comercio|Descripción de Giro Comercio|Receptor|Establecimiento|Número de Transacciones|Monto de Facturación|Compra Promedio|Producto|Periodo|">/resplogifx/SegCamp_'||vinfreceptor||'_'||vaniomes||'.unl'; 
	   system vsql; 							
	   let vsql = '';
	   let vsql = '';
	   let vsql=  'echo "UNLOAD TO /resplogifx/SegCamp_.unl select * from paso_camp order by producto,transacciones desc;">/resplogifx/segcamp.sql'; 
	   system vsql;
	   let vsql = '';
	   let vsql= 'dbaccess intercard /resplogifx/segcamp.sql';
	   system vsql;
	   let vsql ='';
	   let vsql ='rm /resplogifx/segcamp.sql';
	   system vsql;
	   let vsql ='';
	   let vsql = "sed 's/|$//g' /resplogifx/SegCamp_.unl >>/resplogifx/SegCamp_"||vinfreceptor||'_'||vaniomes||".unl";
	   system vsql;
	   let vsql ='rm /resplogifx/SegCamp_.unl';
	   system vsql;
     
       drop table paso_camp;
	   
      
   else
    LET vcodret = '0001';
    LET  p_mensaje  = 'Alguno de los campos es vacio. Favor de Validar ';
    return vcodret, p_mensaje;
 
  end if;

  LET vcodret = '0002';
  LET  p_mensaje  = 'Proceso Exitoso ';
  return vcodret, p_mensaje;

end;
END PROCEDURE;