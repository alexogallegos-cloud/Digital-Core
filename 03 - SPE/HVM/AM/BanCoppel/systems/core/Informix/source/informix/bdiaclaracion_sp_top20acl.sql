CREATE PROCEDURE "informix".sp_top20acl() Returning char(7);

	/*DEFINICIÓN DE VARIABLES*/
	Define  vsql        char(1150);
	Define vcodret		char(7);	
	Define vsqlerr		integer;
	
	---Verificar tabla fisica
		if exists( select * from systables where tabname ='acl_reporte_top20') then
			drop table "informix".acl_reporte_top20;
		end if; 
		--creacion de tabla
			CREATE TABLE "informix".acl_reporte_top20( 		      	
				fechacaptura  		DATE,
				folio_csuac			varchar(11),
				sucursal	 		varchar(4),
				monto		 		money,
				status_corp    		varchar(255),
				fecha_de_cargo      date,
				evento	          	varchar(50)			
			) extent size 74707 next size 11767 lock mode row;
		
				
	let vcodret = "";	
	let vsqlerr = 0;
		
	begin
	
		On exception set vsqlerr		
			if vsqlerr<>0 then
				let vcodret = vsqlerr;				
				return vcodret;
			end if;
		end exception;
		
		--Pendientes
			
		
		select limit 20 a.fechacaptura, a.folio_csuac, j.sucursal as sucursal, a.importeoriginal as monto, g.descripcion as status_corp, date(i.fechahora) as fecha_de_cargo,
			f.descripcion as evento
		from bdiaclaracion:acl_aclaracion a, bdiaclaracion:acl_tipo_evento f, bdiaclaracion:acl_estatus_corporativo g,
			bdiaclaracion:acl_movimiento i, bdinteg:si_sucursales j
		where a.fky_estatus_corp_general = g.pky_estatus_corporativo
			and a.pky_aclaracion = i.fky_aclaracion
			and f.pky_tipo_evento = a.fky_tipo_evento
			and a.folio_csuac is not null
			and a.fky_estatus_aclaracion = 2
			and j.sucursal =a.num_sucursal
			and ((a.fechacaptura between '05052011' and today)
			or (a.fechacaptura between '05052011' and today and date (a.fecha_dictamen) between '05052011' and today))
			order by a.importeoriginal desc
		into temp top20tpen  WITH NO LOG;
	
		INSERT INTO "informix".acl_reporte_top20 (fechacaptura, folio_csuac, sucursal, monto, status_corp, fecha_de_cargo, evento)
		select * from top20tpen;
			
	
		--Generacion del archivo pendientes
			let vsql = ' echo "FechaCaptura|FolioCsuac|Sucursal|Monto|EstatusComporativo|FechaDeCargo|Evento">/resplogifx/repaclaraciones/Top20_pendientes_'||LPAD(day(today), 2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.unl';
			system vsql; 
			let vsql = '';
			let vsql=  'echo "UNLOAD TO top20.unl  select fechacaptura, folio_csuac, sucursal, monto, status_corp, fecha_de_cargo, evento  from acl_reporte_top20;">top20.sql'; 
			system vsql;
			let vsql = '';
			let vsql= 'dbaccess bdiaclaracion  top20.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  top20.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' top20.unl >>/resplogifx/repaclaraciones/Top20_pendientes_"||LPAD(day(today), 2,"0")||LPAD (MONTH(today),2,"0")||year(today)||".unl";
			system vsql;
			let vsql ='rm  top20.unl';
			system vsql; 
			
			
		truncate table acl_reporte_top20 REUSE STORAGE;
			
		--No procedentes
	
		select limit 20 a.fechacaptura, a.folio_csuac,j.sucursal as sucursal, a.importeoriginal as monto, g.descripcion as status_corp, date(i.fechahora) as fecha_de_cargo,
			f.descripcion as evento
		from bdiaclaracion:acl_aclaracion a, bdiaclaracion:acl_tipo_evento f, bdiaclaracion:acl_estatus_corporativo g,
			bdiaclaracion:acl_movimiento i,bdinteg:si_sucursales j
		where a.fky_estatus_corp_general = g.pky_estatus_corporativo
			and a.pky_aclaracion = i.fky_aclaracion
			and f.pky_tipo_evento = a.fky_tipo_evento
			and j.sucursal =a.num_sucursal
			and a.folio_csuac is not null
			and a.fky_estatus_aclaracion >= 3
			and a.procede = 0
			and ((a.fechacaptura between '05052011' and today)
			or (a.fechacaptura between '05052011' and today and date (a.fecha_dictamen) between '05052011' and today))
			order by a.importeoriginal desc		
		into temp top20tnp  WITH NO LOG;
	
		INSERT INTO "informix".acl_reporte_top20 (fechacaptura, folio_csuac, sucursal, monto, status_corp, fecha_de_cargo, evento)
		select * from top20tnp;
			
			let vsql = ' echo "FechaCaptura|FolioCsuac|Sucursal|Monto|EstatusComporativo|FechaDeCargo|Evento">/resplogifx/repaclaraciones/Top20_noprocedentes_'||LPAD(day(today), 2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.unl';
			system vsql;
			let vsql = '';	
			let vsql=  'echo "UNLOAD TO top202.unl  select fechacaptura,folio_csuac,sucursal,monto,status_corp,fecha_de_cargo,evento from acl_reporte_top20;">top202.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess bdiaclaracion  top202.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  top202.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' top202.unl >>/resplogifx/repaclaraciones/Top20_noprocedentes_"||LPAD(day(today), 2,"0")||LPAD (MONTH(today),2,"0")||year(today)||".unl";
			system vsql;
			let vsql ='rm  top202.unl';
			system vsql;
			
			
		truncate table acl_reporte_top20 REUSE STORAGE;		
		--Procedentes
		select limit 20 a.fechacaptura, a.folio_csuac,j.sucursal as sucursal, a.importeoriginal as monto, g.descripcion as status_corp, date(i.fechahora) as fecha_de_cargo,
			f.descripcion as evento
		from bdiaclaracion:acl_aclaracion a, bdiaclaracion:acl_tipo_evento f, bdiaclaracion:acl_estatus_corporativo g,
			bdiaclaracion:acl_movimiento i,bdinteg:si_sucursales j
		where a.fky_estatus_corp_general = g.pky_estatus_corporativo
			and a.pky_aclaracion = i.fky_aclaracion
			and f.pky_tipo_evento = a.fky_tipo_evento
			and j.sucursal =a.num_sucursal
			and a.folio_csuac is not null
			and a.fky_estatus_aclaracion >= 3
			and a.procede = 1
			and ((a.fechacaptura between '05052011' and today)
			or (a.fechacaptura between '05052011' and today and date (a.fecha_dictamen) between '05052011' and today))
			order by a.importeoriginal desc
		into temp top20tproc WITH NO LOG;
		
	
		INSERT INTO "informix".acl_reporte_top20 (fechacaptura, folio_csuac, sucursal, monto, status_corp, fecha_de_cargo, evento)
		select * from top20tproc;
				
			let vsql = ' echo "FechaCaptura|FolioCsuac|Sucursal|Monto|EstatusComporativo|FechaDeCargo|Evento">/resplogifx/repaclaraciones/Top20_procedentes_'||LPAD (day(today),2,"0")||LPAD (MONTH(today),2,"0")||year(today)||'.unl';
			system vsql;
			let vsql = '';	
			let vsql=  'echo "UNLOAD TO top201.unl  select fechacaptura,folio_csuac,sucursal,monto,status_corp,date(fecha_de_cargo),evento from acl_reporte_top20;">top201.sql'; 
			system vsql;
			let vsql ='';
			let vsql= 'dbaccess bdiaclaracion  top201.sql';
			system vsql;
			let vsql ='';
			let vsql ='rm  top201.sql';
			system vsql;
			let vsql ='';
			let vsql = "sed 's/|$//g' top201.unl >>/resplogifx/repaclaraciones/Top20_procedentes_"||LPAD(day(today), 2,"0")||LPAD (MONTH(today),2,"0")||year(today)||".unl";
			system vsql;
			let vsql ='rm  top201.unl';
			system vsql;
				
			let vcodret = "0000000";
						
		drop table acl_reporte_top20;	
		drop table top20tpen;
		drop table top20tnp;
		drop table top20tproc;
		
		return vcodret;
						
	end;
end procedure
DOCUMENT
'Sp para  generacion de Reporte TOP20 Aclaraciones',
'Es llamado desde desde la opcion 173 del menu de produccion',
'Aclaraciones',
'AUTOR : Bernardo Beltrán Herrera',
'Area: Sistemas Administrativos y Perifericos',
'Gerencia de Mtto y Soporte II',
'Coordinador:Norberto Corona Berruecos',
'FECHA : 07/Marzo/2012',
'VERSION: 1.0.0',
'BD    :  bdiaclaracion',


'Se modifica SP para dar formato correcto a la fecha en nombre archivo generado',
'Por: Adilene Lara',
'Fecha: 06/05/2016';

CREATE PROCEDURE "informix".sp_consulta_recuperacion (folio VARCHAR(11))

	RETURNING  MONEY AS AbonoTot, MONEY AS AbonoRecup, MONEY AS ComisionTot, MONEY AS ComisionRecup,MONEY AS IvaTot, MONEY AS IvaRecup;
    

    /* Variables para la salida del SP*/
    DEFINE v_AbonoTot MONEY;
    DEFINE v_AbonoRecup MONEY;
    DEFINE v_ComisionTot MONEY;
    DEFINE v_ComisionRecup MONEY;
    DEFINE v_IvaTot MONEY;
    DEFINE v_IvaRecup MONEY;

    /* Variables para el cÃÂ¡lculo del IVA*/
    DEFINE v_ComisionA MONEY;
    DEFINE v_IvaA MONEY;
    DEFINE v_Porcentaje INTEGER;
    DEFINE v_Ciento INTEGER;

	SET ISOLATION TO DIRTY READ;
	
    BEGIN

    LET v_ComisionA = 0;
    LET v_IvaA = 0;
    LET v_Ciento = 100;
    LET v_Porcentaje = 116;
    
    /* AsignaciÃÂ³n a las variables ComisiÃÂ³n e Iva*/
    LET v_ComisionTot= (SELECT total_comision 
                        FROM bdiaclaracion:acl_recuperacion_saldos 
                        WHERE folio_csuac = folio);

    LET v_IvaTot = (SELECT total_iva 
                        FROM bdiaclaracion:acl_recuperacion_saldos 
                        WHERE folio_csuac = folio);


    /* Variables para el cÃÂ¡lculo del IVA*/
    IF v_IvaTot == 0 THEN
        let v_ComisionA = (v_ComisionTot * v_Ciento) / v_Porcentaje;
        leT v_IvaA = v_ComisionTot - v_ComisionA;
        update bdiaclaracion:acl_recuperacion_saldos set total_comision = v_ComisionA, total_iva = v_IvaA where folio_csuac = folio;
    END IF;

    /* Consulta a la tabla acl_recuperacion_saldos*/
    SELECT total_abono AS AbonoTot, 
           abono_recuperado AS AbonoRecup, 
           total_comision AS ComisionTot, 
           comision_recuperada AS ComisionRecup, 
           total_iva AS IvaTot, 
           iva_recuperada AS IvaRecup
    INTO  v_AbonoTot,v_AbonoRecup, v_ComisionTot, v_ComisionRecup, v_IvaTot,v_IvaRecup  
    FROM bdiaclaracion:acl_recuperacion_saldos 
    WHERE folio_csuac = folio;

    RETURN v_AbonoTot, v_AbonoRecup, v_ComisionTot, v_ComisionRecup, v_IvaTot, v_IvaRecup;
    
    END;
END PROCEDURE;