CREATE PROCEDURE "informix".sp_reporte_tarjetas()
RETURNING varchar(6), varchar(80);
----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  SQL_ERR                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vaniomes                char(6);
DEFINE  vfecha_hoy              date;
DEFINE  vsql                    char(1150);
DEFINE  p_cod_ret               varchar(6);
DEFINE  dias                    integer;
  
---------------------------------------------------
DEFINE ultimo_dia_mes DATE;
DEFINE primer_dia_mes DATE;
DEFINE primer_hora_dia_hora DATETIME YEAR TO FRACTION(5);
DEFINE ultima_hora_dia_hora DATETIME YEAR TO FRACTION(5);
DEFINE FechaAux DATETIME YEAR TO FRACTION(5);

DEFINE ultima_hora_dia DATE;
DEFINE primer_hora_dia DATE;
                   
         

 --SET DEBUG FILE TO "/informix/c94796696/reportetarjetas.out";
-- TRACE ON;
 

 
BEGIN
  
	  ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 and vsqlerr <> -958  then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
    END EXCEPTION;
	  
	   ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr = -958  then	
                   if error_info ='informix.asignadastar' or error_info ='asignadastar' then
					 drop table asignadastar;
				   end if
                   			   
	 	    END IF;    
      END EXCEPTION WITH RESUME; 

   LET P_COD_RET = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO';

-----------***********cuerpo**************-------------------  
set isolation to dirty read;
select fecha_hoy into vfecha_hoy from bdinteg:si_fechas;

  ----operaciones de fechas un día anterior Si hoy es 2012-12-12 se realiza la extracción del 2012-12-11
     LET ultima_hora_dia = extend(extend(vfecha_hoy  - 1 units DAY));
     -- LET ultima_hora_dia_hora = extend(extend(vfecha_hoy  - 1 units DAY));
     --LET ultima_hora_dia_hora = SUBSTRING(ultima_hora_dia_hora FROM 1 FOR 10) || ' 23:59:59';
	 
	 
	 LET primer_hora_dia = extend(extend(vfecha_hoy  - 7 units DAY));
     --LET primer_hora_dia_hora = extend(extend(vfecha_hoy  - 7 units DAY));
     --LET primer_hora_dia_hora = SUBSTRING(primer_hora_dia_hora FROM 1 FOR 10) || ' 23:59:59';
 
 
    let vaniomes =  year(primer_hora_dia) || LPAD (MONTH(primer_hora_dia),2,"0");
	let dias = day(primer_hora_dia);

    
	
	     CREATE TABLE "informix".asignadastar (
           	clave_sucursal               varchar(5),
		    clave_tipotarjeta       	 varchar(2),
			total_asignacion             integer
	     )EXTENT SIZE 320 NEXT SIZE 320 LOCK MODE ROW;
 
--Cuerpo del SP--
--1) 
	
	   --2)Gneración
            let vsql = ''; 	   
			let vsql = 'echo "Clave Sucursal|Clave Tipo Tarjeta|Existencia|Solicitadas|Sucursal en Operación|">/resplogifx/Reporte_Tarjetas'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Reporte_Tarjetas.unl SELECT  st.clave_sucursal,st.clave_tipotarjeta,st.existencia,st.solicitadas,suc.enoperacion FROM intercard:sucursal_tipotarjeta as st,intercard:sucursal as suc WHERE clave_tipotarjeta IN ( select clave_tipotarjeta from intercard:tipotarjeta) AND suc.clave_sucursal = st.clave_sucursal;">/resplogifx/reportetarjetas.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/reportetarjetas.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/reportetarjetas.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Reporte_Tarjetas.unl >>/resplogifx/Reporte_Tarjetas"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
			system vsql;
			let vsql ='rm /resplogifx/Reporte_Tarjetas.unl';
			system vsql;
			
			SET ISOLATION TO DIRTY READ;
			INSERT INTO asignadastar (clave_sucursal,clave_tipotarjeta,total_asignacion)
			select distinct clave_sucursal,clave_tipotarjeta, sum(consumo)
				from Intercard:"informix".estadisticatarjetasuc
			where  fecha between (primer_hora_dia) and (ultima_hora_dia) 
			group by 1,2
			order by 1,2;
			/*
			SELECT {+INDEX(intercard:tarjeta idx_tarjeta1)} COUNT(tar.numtarjeta ) as total_asignacion,lt.clave_sucursal,lt.clave_tipotarjeta 
			FROM intercard:tarjeta tar, intercard:lote lt WHERE  tar.codstatusasignada = 'SIA' 
			AND tar.fechaasignacion BETWEEN  primer_hora_dia_hora  AND  ultima_hora_dia_hora 
			AND lt.clave_tipotarjeta IN ( SELECT  clave_tipotarjeta from intercard:tipotarjeta) 
			AND lt.numerolote=tar.numerolote 
			GROUP  BY 2,3;*/
			
			
			 --7)Generar archivo por Giro de Negocio GN_201203
            let vsql = ''; 	   
			let vsql = 'echo "Clave Sucursal|Clave Tipo Tarjeta|Total Asignadas">/resplogifx/Reporte_Asignadas'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||'.unl';
			system vsql;
			let vsql = '';
			let vsql = '';
			let vsql=  'echo "UNLOAD TO /resplogifx/Reporte_Asignadas.unl select * from intercard:asignadastar;">/resplogifx/asignatarjetas.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess intercard /resplogifx/asignatarjetas.sql';
			system vsql;
			let vsql = '';
			let vsql ='rm /resplogifx/asignatarjetas.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' /resplogifx/Reporte_Asignadas.unl >>/resplogifx/Reporte_Asignadas"|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)||".unl";
			system vsql;
			let vsql ='rm /resplogifx/Reporte_Asignadas.unl';
			system vsql;

			
			DROP TABLE asignadastar;
			

		
 	RETURN 	P_COD_RET,P_MENSAJE;  

END;
END PROCEDURE
DOCUMENT
'Modifico: L.I.A. Ricardo Resendiz Martinez',
'Proyecto: Calculo de maquila automatico ',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se actualiza forma de obtener reporte de consumo de tarjetas  ',
'Fecha: 2015/09/08',
'Version: 20150908.1400',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_actualizabinarqc ()
returning char (5),char(100);

--############################################################################################################
--### Creado por: FRG																			  			##
--##  Fecha: 11/Sep/201																			 			##
--##  Descripcion: Se genera SP para actualización masiva del campo intercard:hsmcard.binarqc a los lotes   ##
--##  			  de tarjetas con mal generados por G&D.													##
--##  BD: intercard                                                                                         ##
--############################################################################################################

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cInfoErr			CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cMensRet         CHAR(40);
DEFINE iRegsAct		    INTEGER;
DEFINE inumerolote		INTEGER;
DEFINE icommit			INTEGER;

LET cInfoErr = '';
LET cCodret = '00000' ;
LET cMensRet = 'Proceso de actualización lotes exitoso.';
LET iRegsAct = 0;
LET inumerolote = 0;
LET icommit = 0;

		--	Set debug file to "/informix/frg/sp_actualizabinarqc.out";
		--	trace on;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
				--	Set debug file to "/informix/frg/sp_actualizabinarqc.out";
				--	trace on;
			END IF;
		END EXCEPTION;

		FOREACH WITH HOLD
			SELECT numerolote
				INTO inumerolote--1200
			FROM "informix".hsmcard_paso
			
			let inumerolote = inumerolote;
			
			BEGIN WORK;
				if icommit = 5000
					then
						COMMIT WORK;
						LET icommit = 0;
						CONTINUE FOREACH;
					else
						
				end if;
				
				update "informix".hsmcard 
					set binarqc = '426807'
					where card_no in (select numtarjeta from "informix".tarjeta where numerolote in 
										(select numerolote from "informix".hsmcard_paso where numerolote = inumerolote)
									 );
					LET icommit = icommit+1;
					--	LET iRegsAct = iRegsAct+1;
			COMMIT WORK;
		END FOREACH;
		
		RETURN cCodret,cMensRet;

    END;
END PROCEDURE;