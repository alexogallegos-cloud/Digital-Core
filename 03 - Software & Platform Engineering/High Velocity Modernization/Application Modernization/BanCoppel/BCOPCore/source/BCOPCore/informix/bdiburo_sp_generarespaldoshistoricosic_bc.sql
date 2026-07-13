CREATE PROCEDURE "informix".sp_generarespaldoshistoricosic_bc(pNumCte CHAR(20), pInstitucion   CHAR(2))
RETURNING CHAR(6)  AS COD_RET,
		  CHAR(80) AS MENSAJE_EJEC;

--DECLARACIÓN DE VARIABLES
DEFINE iSqlErr         		INTEGER;
DEFINE iIsamErr        		INTEGER;
DEFINE iCantReg        		INTEGER;
DEFINE cErrorInfo      		CHAR(80);
DEFINE cCodRet         		CHAR(6);
DEFINE cMensajeRet          CHAR(80);

--INICIALIZACIÓN DE VARIABLES
LET iSqlErr            	= 0;
LET iIsamErr           	= 0;
LET iCantReg           	= 0;
LET cErrorInfo         	= "";
LET cCodRet            	= "000000";
LET cMensajeRet         = "RESPALDO REALIZADO EXITOSAMENTE";

BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET cCodRet = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN TRIM(cCodRet), TRIM(cMensajeRet);
	   END IF;
	END EXCEPTION;

	-- SET DEBUG FILE TO "/informix/jesus/sp_generarespaldoshistoricosic_bc";
	-- TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		-- SE VALIDA SI EL NUMERO DE CLIENTE SE RECIBE VACIO
		IF NVL(pNumCte, "") = "" THEN
			LET cCodRet = "000003";
			LET cMensajeRet = "EL NÚMERO DE CLIENTE RECIBIDO ES INCORRECTO";
			RETURN cCodRet, TRIM(cMensajeRet);
		END IF;
			
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_tl_bc_hist			 
		SELECT * 
		FROM "informix".br_tl_bc
		WHERE num_cliente = pNumCte
		AND institucion = pInstitucion ;
		
		LET iCantReg = DBINFO("sqlca.sqlerrd2");

		-- SE VALIDA SI EXISTEN REGISTROS PARA CONTINUAR CON EL RESPALDO
		IF iCantReg = 0 THEN
			LET cCodRet = "000002";
			LET cMensajeRet = "NO SE ENCONTRARON REGISTROS PARA RESPALDAR";
			RETURN cCodRet, TRIM(cMensajeRet);
		END IF
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_tl_bc
			WHERE num_cliente = pNumCte
			AND institucion = pInstitucion ;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_cr_bc_hist			
		SELECT *
		FROM "informix".br_cr_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_cr_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_hi_bc_hist			
		SELECT *
		FROM "informix".br_hi_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_hi_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_hr_bc_hist
		SELECT *
		FROM "informix".br_hr_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_hr_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_iq_bc_hist
		SELECT *
		FROM "informix".br_iq_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_iq_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_pa_bc_hist
		SELECT *
		FROM "informix".br_pa
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_pa_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_pe_bc_hist			
		SELECT *
		FROM "informix".br_pe_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_pe_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_pn_bc_hist
		SELECT *	
		FROM "informix".br_pn_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_pn_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;

		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_rs_bc_hist
		SELECT *
		FROM "informix".br_rs_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_rs_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;		
		
		-- SE REALIZA EL TRASPASO DEL REGISTRO DEL CLIENTE (E INSTITUCION SI ES QUE SE RECIBE) A SU RESPECTIVO HISTORICO
		INSERT INTO "informix".br_sc_bc_hist			
		SELECT *
		FROM "informix".br_sc_bc
		WHERE numcte = pNumCte
		AND institucion = pInstitucion ;
		
			-- SE ELIMINA LA INFORMACION PREVIAMENTE RESPALDADA
			DELETE FROM "informix".br_sc_bc
			WHERE numcte = pNumCte
			AND institucion = pInstitucion ;		
	
	RETURN cCodRet, TRIM(cMensajeRet);
END
END PROCEDURE 
DOCUMENT
'Realiza el respaldo de las tablas donde se registra la información de las SIC de incrementos',
'AUTOR : Jesus Manuel Aguilar Heredia',
'FECHA : 27/Marzo/2011',
'BD    : BDIBURO';

create procedure "informix".sp_burofisicas_mensual_resp()
       returning char(5);

 define vfecha_reporte char(8);

   define vcodret                   char(5);
   define vsql                      char(1500);
   define vsql2                     char(2204);
   define iSqlErr                   integer;
   define vfecha_hoy                date;
   define vdia                      char(02);
   define vmes                      char(02);
   define vanio                     char(4);
   define vflag                     char(1);
   define vflag_sql                 char(1);
   define vflag_filetmp             char(1);
   define vflag_file                char(1);
   define vflag_zip                 char(1);
   define cnomarchivo               char(100);

BEGIN

   on exception set iSqlErr
      if iSqlErr != 0 then
         let vcodret = iSqlErr;
         return vcodret;
      end if;
   end exception;

   let vcodret = "000";
   LET vsql = '';
   LET vsql2 = '';
   let vdia  = '';
   let vmes  = '';
   let vanio = '';
let cnomarchivo = '';


--SET DEBUG FILE TO "burofisicas_respaldo.out";
--TRACE ON; 

 select pri_dia_mes - 1
      into vfecha_hoy
      from bdinteg:si_fechas
     where empresa = '001';

   
   let vanio = year(vfecha_hoy);
   let vmes = lpad(month(vfecha_hoy),2,"0");
   let vdia = lpad(day(vfecha_hoy),2,"0");
   let vfecha_reporte = vdia||vmes||vanio;


--REVOLVENTES
 --EXTRACCIÓN BR_BUROFISICAS

SELECT valor 
  INTO vflag
FROM bdiburo:br_param
WHERE cod_param = 129;

IF vflag = 0 then

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_'||vfecha_reporte||'.txt';

 LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofis.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor= '1'
  WHERE cod_param = 129;
 commit;

LET vflag = '1';

END IF;

 --EXTRACCIÓN BR_BUROFISICAS_DESCRIBE
IF vflag = 1 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_describe_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_describe'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des.sql";
  SYSTEM vsql;
 
 begin;
  UPDATE bdiburo:br_param
  SET valor = '2'
  WHERE cod_param = 129;
 commit;
 
LET vflag = '2';

END IF;



 --EXTRACCIÓN BR_BUROFISICAS_CONCILIA
IF vflag = 2 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_concilia_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_concilia'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor = '3'
  WHERE cod_param = 129;
 commit; 

LET vflag = '3';

END IF;


--NO REVOLVENTES
 --EXTRACCIÓN BR_BUROFISICAS_CNR

IF vflag = 3 then

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_cnr_'||vfecha_reporte||'.txt';

 LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofis_cnr.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor= '4'
  WHERE cod_param = 129;
 commit; 

LET vflag = '4';

END IF;


 --EXTRACCIÓN BR_BUROFISICAS_DESCRIBE_CNR
IF vflag = 4 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo ='/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_describe_cnr_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_describe_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_des_cnr.sql";
  SYSTEM vsql;
  
 begin;
  UPDATE bdiburo:br_param
  SET valor = '5'
  WHERE cod_param = 129;
 commit;
 
LET vflag = '5';

END IF;

 --EXTRACCIÓN BR_BUROFISICAS_CONCILIA_CNR
IF vflag = 5 THEN

 LET cnomarchivo ='';
 LET vsql = ''; 

 LET cnomarchivo = '/resplogifx/burodecredito/Respaldo_tablas/br_burofisicas_concilia_cnr_'||vfecha_reporte||'.txt';

  LET vsql = 'echo " unload to '||TRIM(cnomarchivo) ||
             ' select *'||
             ' from bdiburo:br_burofisicas_concilia_cnr'||
             ' " > /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||'/resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql';
  SYSTEM vsql2;

  LET vsql = 'dbaccess bdiburo /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql';
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo) ;
  SYSTEM vsql2;

  LET vsql =  'gzip '||TRIM(cnomarchivo);
  SYSTEM vsql;

  LET vsql2 = '';
  LET vsql2 ='chmod 777 '||TRIM(cnomarchivo)|| '.gz';
  SYSTEM vsql2;

  LET vsql = "rm /resplogifx/burodecredito/Respaldo_tablas/gen_burofisi_con_cnr.sql";
  SYSTEM vsql;  

 begin;
  UPDATE bdiburo:br_param
  SET valor = '0'
  WHERE cod_param = 129;
 commit;
 
END IF;

  return vcodret;

END;
end procedure;