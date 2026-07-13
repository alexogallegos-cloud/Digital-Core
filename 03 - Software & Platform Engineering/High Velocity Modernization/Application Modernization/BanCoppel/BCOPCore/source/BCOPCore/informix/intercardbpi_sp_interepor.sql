CREATE PROCEDURE "informix".sp_interepor(pcodgironeg varchar(1),pidreceptor varchar(40),paniome varchar(6))
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vsql                    char(1150);
DEFINE  vcodgironegs            varchar(1);
DEFINE  vinfreceptor            varchar(40);
DEFINE  vaniomes                varchar(6);


-------------- control de errores---------

--SET DEBUG FILE TO "/informix/resplogifx/interepor.out";
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
                  if error_info ='informix.pasoprincipal' then
				     drop table pasoprincipal;
				  end if			
	              if error_info ='informix.paso2' then
				     drop table paso2;
				  end if			   
                  if error_info ='informix.paso3' then
				     drop table paso3;					  
				  end if
				  if error_info ='informix.paso_nego' then
				     drop table paso_nego;					  
				  end if
				   if error_info ='informix.paso_estab' then
				     drop table paso_estab;					  
				  end if
				  if error_info ='informix.paso_camp' then
				     drop table paso_camp;
				  end if		     
				  				   
		    END IF;    
 END EXCEPTION WITH RESUME;
    

LET  vcodgironegs = pcodgironeg;   
LET  vinfreceptor = pidreceptor; 
LET  vaniomes = paniome;


-------Cuerpo de SP Consulta Seguimiento a Campaña.
  IF (vcodgironegs = '' and vinfreceptor = '' and  vaniomes = '' )THEN
 
      EXECUTE PROCEDURE intercard:sp_reportenegocio() INTO vcodret,p_mensaje;
	  
	    return vcodret, p_mensaje;
	
	ELIF ((vcodgironegs is not null) and (vinfreceptor is not null) and ( vaniomes  is not null) ) THEN
	
	  EXECUTE PROCEDURE intercard:sp_segcamp (vcodgironegs,vinfreceptor,vaniomes) INTO vcodret,p_mensaje;

        return vcodret, p_mensaje;
	  
  ELSE
    LET vcodret = '0003';
    LET  p_mensaje  = 'Existe un error';
    return vcodret, p_mensaje;
	 
  END IF;
end;
END PROCEDURE;