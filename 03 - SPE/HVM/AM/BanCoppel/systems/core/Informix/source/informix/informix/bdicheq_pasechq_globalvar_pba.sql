CREATE PROCEDURE "informix".pasechq_globalvar_pba(pempresa char(3))
    returning char(5);

    DEFINE GLOBAL vgcodigo_mn           CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vg_sistema            CHAR(2)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t1         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_t2         CHAR(4)     DEFAULT ' ';
    DEFINE GLOBAL vgcta_iva             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgcta_itr             CHAR(20)    DEFAULT ' ';
    DEFINE GLOBAL vgtransacc_corresp    CHAR(4)     DEFAULT ' ';
	DEFINE GLOBAL vfecha_hoy            DATE        DEFAULT TODAY;
	
	DEFINE vcodret 						CHAR(5);
	
	LET vcodret = '000';

	-- // Extrae parametros globales
    select valor 
      into vgcodigo_mn
      from bdinteg:si_param
     where cod_param > 0
       and empresa = pempresa 
       and descripcion = "codigo mn";
    
    select sistema 
      into vg_sistema
      from bdinteg:si_sistema
     where sistema <> '00'
       and siglas = "SC";

    select valor 
      into vgtransacc_t1
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibsbc";

    select valor 
      into vgtransacc_t2
      from sc_param
     where empresa = pempresa 
       and codparam = "tranlibdomi";

    select valor 
      into vgcta_iva
      from sc_param
     where empresa = pempresa 
       and codparam = "ctaiva";

    select valor 
      into vgcta_itr
      from sc_param
     where empresa = pempresa 
       and codparam = "ctaitr";

    select valor 
      into vgtransacc_corresp
      from sc_param
     where empresa = pempresa 
       and codparam = "trancorrespchq";
	   
	 return vcodret;

end procedure;