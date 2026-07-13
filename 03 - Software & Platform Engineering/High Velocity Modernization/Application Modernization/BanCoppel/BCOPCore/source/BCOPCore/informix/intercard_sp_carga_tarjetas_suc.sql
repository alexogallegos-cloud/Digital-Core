CREATE PROCEDURE "informix".sp_carga_tarjetas_suc()
 returning char(5);

define v_codret        	char(5);
define v_sqlerr        	integer;
define v_isamerr       	integer;
define vtexto_select    char(1000);
define vPath           	char(50);
define cCadena         	char(2500);
define vNomarchdb2     	char(30);
define vfecha_hoy      	char(8);
define vLargoCadena    	integer;
define vConteo         	smallint;
define vSucursal		VARCHAR(5);
define CodRetorno		VARCHAR(5);
define DescRetorno		VARCHAR(50);
define vFecha			VARCHAR(10);

let v_codret            = "00000";
let v_sqlerr            = 0;
let v_isamerr           = 0;
let vtexto_select       = "";
let vPath               = "";
let cCadena             = "";
let vNomarchdb2         = "";
let vfecha_hoy          = "";
let vLargoCadena        = 0;
let vConteo             = 0;
let vSucursal			= "";
let CodRetorno			= "";
let DescRetorno			= "";
let vFecha				= "";


  --SET DEBUG FILE TO "/informix/sp_carga_tarjetas_suc.out";
  --TRACE ON;

begin
   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;
         return v_codret;
      end if;
   end exception;

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
 
    --Generales
       	SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d")  INTO vfecha_hoy
        from sysmaster:sysshmvals;
	   
        select valor into vPath
         from bdinteg:si_param_dom
        where cod_param = 24;


        ---- INICIO INSERT VTARJETAS
        let vNomarchdb2 = 'ins_vtarjetas_db2_' || vfecha_hoy;
		let vPath = trim(vPath);
		let vNomarchdb2 = trim(vNomarchdb2);
		

		SELECT TO_CHAR(today,'%Y-%m-%d')
			INTO  vFecha
		FROM systables WHERE tabid = 1;

        

		 ---- VALIDA SI HAY TARJETAS PARA INVENTARIAR
        SELECT sucursal
			  INTO vSucursal
		FROM intercard:carga_tarjetas
		WHERE flag_sucursal = 1;

				EXECUTE PROCEDURE "informix".sp_reporte_controltarjetas(vSucursal) INTO CodRetorno, DescRetorno;
				
				UPDATE intercard:carga_tarjetas SET flag_sucursal = 1, fecha_carga = today
				WHERE sucursal = vSucursal;

		IF CodRetorno = '00000' THEN
			foreach
				select 'INSERT INTO DB_BCPL.VTARJETAS VALUES(''' || tt_empresa || ''',''' || substr(tt_sucursal, 2,5) || ''',''' || tt_numerotarjeta || ''','  || tt_numerolote || ','''|| tt_statustarjeta || ''','''','''',' || vFecha || ',' || vFecha || ',' || tt_tipotarjeta || ',' || tt_banderaregistro ||','''');'
					INTO vtexto_select
				FROM intercard:control_inventario
				WHERE tt_sucursal = vSucursal
				if nvl(vtexto_select, '') <> '' then
					let vConteo = vConteo + 1;
				if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || vPath || vNomarchdb2 || '.sql' ;
                    System cCadena;
				elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || vPath || vNomarchdb2 || '.sql' ;
                    System cCadena;
				end if;
          else
              exit foreach;
          end if;
        end foreach;
	ELSE
		let v_codret = '00OFF';
	END IF;
		RETURN v_codret;
END;
END PROCEDURE;