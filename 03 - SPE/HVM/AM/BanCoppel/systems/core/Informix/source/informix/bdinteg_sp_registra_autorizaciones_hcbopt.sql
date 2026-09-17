CREATE PROCEDURE "informix".sp_registra_autorizaciones_hcbopt
		(pEmpresa       CHAR (3),
		 pCliente       CHAR (10), 
		 pSucursal      CHAR (4),
		 pOperador      CHAR (10),
		 pMensajeAviso  VARCHAR (200),
		 pSic           CHAR (1),
		 pAviso         CHAR (1),
		 pINE           CHAR(1), 
		 pGrupoCoppel   CHAR (1),
		 pEdoCta        CHAR (1))

		RETURNING       CHAR (5);
		--***************************************************************************************************************
		--*                                    DEFINICION DE VARIABLES                                                  *
		--***************************************************************************************************************

		DEFINE Cod_ret                CHAR(5);
		DEFINE iSqlErr                INTEGER;
		DEFINE aviso_Aut              CHAR(3);
		DEFINE aut_Coppel             CHAR(3);
		DEFINE aut_Sic                CHAR(5);
		DEFINE secuencia              SMALLINT;
		DEFINE aut_EdoCta             CHAR(5);
		DEFINE stat_edoCta            CHAR(1);
		DEFINE existeAutorizadoAviso INTEGER;

		--***************************************************************************************************************
		--*                                    ASIGNACION DE VARIABLES                                                  *
		--***************************************************************************************************************

		LET Cod_ret                   = "00000";
		LET iSqlErr                   = 0;

		LET aviso_Aut                 = '0';
		LET aut_Coppel                = '0';
		LET aut_Sic                   = '0';
		LET secuencia                 = '0';
		LET aut_EdoCta                = '0';
		LET stat_edoCta               = '0';
		LET existeAutorizadoAviso     = 0;

		--***************************************************************************************************************
		--*                                    CONTROL DE ERRORES                                                       *
		--***************************************************************************************************************

		BEGIN
			ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET Cod_ret = iSqlErr;
				RETURN Cod_ret;
			END IF ;
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/sysifx/sp_registra_autorizaciones_hcbopt.out";
			--TRACE ON;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			
			--***********************************************************************************************************
			--*                                PROGRAMA PRINCIPAL                                                       *
			--***********************************************************************************************************

			IF NVL(pCliente, '') <> "" THEN
				
				--** aviso de privacidad
				IF pAviso = '1' THEN
					
						SELECT count(numcte) into existeAutorizadoAviso 
						FROM bdinteg:"informix".si_autorizacion_privacidad 
						WHERE empresa = pEmpresa AND numcte = pCliente AND respuesta = '1';
					
					IF existeAutorizadoAviso = 0 then
						
						CALL bdinteg:"informix".sp_insert_autor_privacidad(pEmpresa, pCliente,pSucursal,pAviso,pMensajeAviso) RETURNING aviso_Aut;

						IF NVL(aviso_Aut, '') <> "000" THEN
							LET Cod_ret = "00001";
							RETURN  Cod_ret;
						END IF;
					 ELSE
						   LET Cod_ret = "00000";
					 END IF;

				END IF;

				--** Compartir datos con coppel
				IF pGrupoCoppel = '1' THEN
					CALL bdinteg:"informix".sp_autoriza_datos_contacto(pCliente, pOperador, pSucursal, '1', '1', pGrupoCoppel, 2) RETURNING aut_Coppel;
					
					IF NVL(aut_Coppel, '') <> "000" THEN
						LET Cod_ret = "00001";
						RETURN Cod_ret;
					END IF;
				END IF;

				--** autorizacion envio de cuenta por medios electronicos
				IF pEdoCta = '1' THEN
					CALL bdinteg:"informix".sp_registro_aut_envio_edocta(pCliente, pSucursal, pOperador, pEdoCta,"","") RETURNING  aut_EdoCta, stat_edoCta;
				END IF;

			END IF;
			RETURN Cod_ret;
		END;
	END PROCEDURE
	DOCUMENT
	'----------------------------------------------------------------------------',
	'--Autor: Alberto Sanchez',
	'--Folio: 869.1- Cuestionario de PLD en Apertura de Productos Complementaria 5.',
	'--Fecha: 26/09/2022.',
	'--Solicita:', 
	'--Descripcion: Se crea procedimiento almacenado para registrar diferentes tablas',
	'--las autorizaciones que selecciono el cliente',
	'--BD: bdinteg.',
	'-- --------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_cons_datos_contacto(pcliente CHAR(9))
   RETURNING CHAR(3);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);
DEFINE sExiste CHAR(9);

LET iSqlErr = 0;
LET cCodRet = '';
LET sExiste='';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/tmp/anj/sp_autoriza_datos_contacto.sql';
--		TRACE ON;

BEGIN

ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
   IF iSqlErr <> 0 THEN
       LET cCodRet = iSqlErr;
       RETURN cCodRet;
   END IF;
END EXCEPTION;
        --let pcliente=pcliente;
        select count(numcte) INTO sExiste  from si_autoriza_datos_contacto where numcte=pcliente and flag='1';
  
        IF sExiste='0' THEN
           LET cCodRet = '000'; --Muestra la pregunta en OFI
        ELSE
           LET cCodRet = '001'; --Cte ya respondiÃ³, no muestra la pregunta
        END IF          

RETURN cCodRet;

END
END PROCEDURE
DOCUMENT
'Folio:			868',
'Proyecto:		Pre-evaluaciÃ³n de Solicitudes de CrÃ©dito (Complementaria - 4',
'Autor: 		98440021 - Veronica Rodriguez',
'Fecha: 		29/11/2022',
'Solicita:		Fernando Rojas',
'Descripcion:   Consulta autorizaciones de contacto',
'BD: 			bdinteg';

CREATE PROCEDURE "informix".sp_generareplica_catdomssuc()

 returning char(5);

define v_codret        	char(5);
define v_sqlerr        	integer;
define v_isamerr       	integer;
define vdia            	date;
define vhora           	char(8);
define cMensaje        	char(80);
define pUsuario        	char(8);
define pEmpresa        	char(3);
define vtexto_select    char(1000);
define vPath           	char(50);
define cCadena         	char(2500); 
define cCadenadb2       char(2500); 
define vNomarch        	char(80);
define vNomarchdb2     	char(30);
define vfecha_hoy      	char(8);
define vLargoCadena    	integer;
--define vConteo         	smallint;
define vConteo         	integer;
define vfecha_hoy2     	date;
define vf_ultinsercion 	date;
define vf_ultactualiza 	date;
define vCatalogo      	char(20);
define vEjecutarProceso char(1);
define cUPD           	char(1);
define cINS           	char(1);

define i_numerociudad		integer;
define i_numerocolonia		integer;
define c_nombrezona		    char(32);
define c_poblacionzona		char(27);
define c_municipiozona		char(27);
define i_codigopostalzona	integer;
define c_planozona		    char(7);
define c_rumbozona		    char(42);
define i_supervisorzona		integer;
define i_choferzona		    integer; 
define i_jefegrupozona		integer;
define i_gerentezona		integer;
define i_abogadozona		integer;
define c_marcaencuesta30dias char(3);
define i_numerocalle		integer;
define i_numerocasa		    integer;
define c_marcaunidadhabitacional char(3);
define i_numerodivisioncobranzas integer;
define i_claveabogado		integer;
define i_ciudadcobranzas	integer;
define i_numerocobranzas	integer;
define c_clavearagon		char(3);
define i_centro		        integer;
define i_pais               integer;
define i_estado             integer;
define i_ciudad             integer;
define c_nombreciudad       char(50);
define i_numerociudad_2     integer;
define c_localidad          char(8);
define i_tipociudad         integer;
define dFecha_hoy           date;
define cUsr_modifica        char(10);
define iExiste_col          integer;
define iExiste_cd           integer;
define vEjecuta_omnicanal   char(1);
define vPath_ominicanal     char(50);
define vSeparador           char(1);
define cCadena_omni    	char(3500); 

let v_codret            = "00000";
let v_sqlerr            = 0;
let v_isamerr           = 0; 
let vdia                = '01-01-1900';
let vhora               = "";
let cMensaje            = 'PROCESO EXITOSO';
let pUsuario            = user;
let pEmpresa            = '001';
let vtexto_select       = "";
let vPath               = ""; 
let cCadena             = "";
let cCadenadb2          = "";
let vNomarch            = "";
let vNomarchdb2         = "";
let vfecha_hoy          = "";
let vLargoCadena        = 0;
let vConteo             = 0;
let vfecha_hoy2         = '01-01-1900';
let vf_ultinsercion     = '01-01-1900';
let vCatalogo           = "";
let vf_ultactualiza     = '01-01-1900';
let vEjecutarProceso    = '';
let cUPD                = 'U';
let cINS                = 'I';

let i_numerociudad		= 0;
let i_numerocolonia		= 0;
let c_nombrezona		= '';
let c_poblacionzona		= '';
let c_municipiozona		= '';
let i_codigopostalzona	= 0;
let c_planozona		    = '';
let c_rumbozona		    = '';
let i_supervisorzona	= 0;
let i_choferzona		= 0;
let i_jefegrupozona		= 0;
let i_gerentezona		= 0;
let i_abogadozona		= 0;
let c_marcaencuesta30dias = '';
let i_numerocalle		= 0;
let i_numerocasa		= 0;
let c_marcaunidadhabitacional = '';
let i_numerodivisioncobranzas = 0;
let i_claveabogado		= 0;
let i_ciudadcobranzas	= 0;
let i_numerocobranzas	= 0;
let c_clavearagon		= '';
let i_centro		    = 0;
 
let i_pais               = 0;
let i_estado             = 0;
let i_ciudad             = 0;
let c_nombreciudad       = ''; 
let i_numerociudad_2     = 0;
let c_localidad          = ''; 
let i_tipociudad         = 0;
let dFecha_hoy           = date(1);
let cUsr_modifica        = '';
let iExiste_col          = 0;
let iExiste_cd           = 0;
let vEjecuta_omnicanal   = '';
let vPath_ominicanal     = '';
let vSeparador           = '|';
let cCadena_omni         = '';  

  --SET DEBUG FILE TO "/ifxsif01/macf/generareplica_catdomssuc.out";
  --TRACE ON;

begin

   on exception set v_sqlerr, v_isamerr
      if v_sqlerr != 0 then
         let v_codret=v_sqlerr;

	    SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
        SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;

        INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
        VALUES('GENERA SCRIPTS CATDOMS SUC.', v_codret, 'ERROR', 0, pUsuario, vdia, vhora);

         return v_codret;

	 end if;
      

      
   end exception;
   
   
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
   
   select valor into vEjecutarProceso
     from bdinteg:si_param_dom
    where empresa = pEmpresa and cod_param = 25;
   
   if vEjecutarProceso = 'S' then 
       --Generales 
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
    
       INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
            VALUES('GENERA SCRIPTS CATDOMS SUC.', '11111', 'PROCESO INICIALIZADO', 0, pUsuario, vdia, vhora);
    
       select valor into vPath 
         from bdinteg:si_param_dom 
        where empresa = pEmpresa and cod_param = 24;
    
        --select fecha_hoy into vfecha_hoy2 from bdinteg:si_fechas;
        --select to_char(fecha_hoy, "%Y%m%d") into vfecha_hoy 
        --  from bdinteg:si_fechas;

        SELECT to_char(DBINFO('utc_to_datetime', sh_curtime)::DATE, "%Y%m%d"), DBINFO('utc_to_datetime', sh_curtime)::DATE
		INTO vfecha_hoy, dFecha_hoy
        from sysmaster:sysshmvals;
        
		--LET dFecha_hoy = MDY('02','08','2023');  --- SOLO TEST MACF
		--LET vfecha_hoy = '20230208';  --- SOLO TEST MACF
		
        ---- INICIO INSERTS SI_CATZONAS
        let vCatalogo  	= 'si_catzonas';
        let vNomarch 	= 'ins_catzonas_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catzonas_db2_' || vfecha_hoy;

        select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
         where catalogo = vCatalogo
           and tipo_operacion = cINS;
    
        --let vtexto_catzonas = to_char(vf_ultins_catzonas) || ' - ' ||to_char(vf_ultins_ciudades) || ' - ' ||vNomarch;
        --insert into si_bitacora_dom  (mensaje, user_insert, fecha_insert) values(vf_ultins_catzonas, pUsuario, vdia);
    
        foreach with hold
          SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonas_fechains)} 'INSERT INTO public.catzonas values(' ||
                  numerociudad || "," || numerocolonia || ",'" || trim(replace(replace(nombrezona,'"',''''),"'", "")) ||  "','" || nvl(trim(replace(poblacionzona,"'", "")), '')  || "','"  || 
                  nvl(trim(replace(municipiozona,"'", "")), '')  || "'," || nvl(codigopostalzona, 0) || ",'" || nvl(planozona, '') || "','" || 
                  nvl(trim(rumbozona),'') || "'," || nvl(supervisorzona,0) || "," || nvl(choferzona,0) || "," || 
                  nvl(jefegrupozona,0) || "," || nvl(gerentezona,0) || "," || nvl(abogadozona,0) || ",'" || nvl(marcaencuesta30dias, '') 
                  || "'," || nvl(numerocalle, 0) || "," || nvl(numerocasa, 0) || ",'" || nvl(marcaunidadhabitacional, '') || 
                  "'," || nvl(numerodivisioncobranzas,0) || "," || nvl(claveabogado,0) || "," || nvl(ciudadcobranzas,0) || "," || 
                  --nvl(numerocobranzas,0) || ",'" || nvl(clavearagon, '') || "'," || nvl(centro, 0) || ');',
				  nvl(numerocobranzas,0) || ",'" || 1 || "'," || nvl(centro, 0) || ');',
                  numerociudad, numerocolonia, trim(replace(nombrezona,"'", '')), --de aqui en adelante para inserciÃÂ³n (23 campos)
				  nvl(trim(replace(poblacionzona,"'", '')), ''), 
				  nvl(trim(replace(municipiozona,"'", '')), ''), nvl(codigopostalzona, 0), nvl(planozona, ''), 
				  nvl(trim(rumbozona),''), nvl(supervisorzona,0), nvl(choferzona,0), 
				  nvl(jefegrupozona,0), nvl(gerentezona,0), nvl(abogadozona,0), nvl(marcaencuesta30dias,''), 
				  nvl(numerocalle, 0), nvl(numerocasa, 0), nvl(marcaunidadhabitacional, ''), 
				  nvl(numerodivisioncobranzas,0) , nvl(claveabogado,0), nvl(ciudadcobranzas,0), 
				  --nvl(numerocobranzas,0), nvl(clavearagon, ''), nvl(centro, 0), usr_modifica  
				  nvl(numerocobranzas,0), '1', nvl(centro, 0), usr_modifica  

				  INTO vtexto_select,
				  i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
				  c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
				  i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
				  i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas,	i_numerocobranzas, c_clavearagon, i_centro, cUsr_modifica		 				  
			  
          FROM bdinteg:si_catzonas
          WHERE f_inserta >= vf_ultinsercion
            AND usr_modifica <> 'SYSCARTERA'
	        AND nvl(nomzona_spmx,'') <> '' AND NVL(pobzona_spmx,'') <> '' AND NVL(mnpio_spmx,'') <> ''
			
     if nvl(vtexto_select, '') <> '' then
		    let vConteo = vConteo + 1;
              if  vConteo = 1 then
                  let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
				  System cCadena;
				  let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
				elif vConteo > 1 then
                  let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
				 System cCadena;
				 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				 System cCadenadb2;
				end if;
				-- MACF Para inserciÃÂ³n en nueva tabla
				
				select count(*) into iExiste_col
				  from bdinteg:si_catzonas_suc
				  where numerociudad = i_numerociudad and numerocolonia = i_numerocolonia;
				  
				
				if iExiste_col <= 0 then
					begin; 
					  insert into bdinteg:si_catzonas_suc(numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, planozona, 
						rumbozona, supervisorzona, choferzona, jefegrupozona, gerentezona, abogadozona, marcaencuesta30dias, numerocalle, numerocasa, 
						marcaunidadhabitacional, numerodivisioncobranzas, claveabogado, ciudadcobranzas, numerocobranzas, clavearagon, centro, f_inserta,
						usr_modifica) 
					  values(i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
							 c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
							 i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
							 i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas,	i_numerocobranzas, c_clavearagon, i_centro, dFecha_hoy, 
							 cUsr_modifica);
				   commit; 
				end if;
				-- MACF Para inserciÃÂ³n en nueva tabla
          else
              exit foreach;
          end if;
		  
		   
		
    
        end foreach;
				
        if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
        end if;   ----  FIN INSERTS SI_CATZONAS


       ---- INICIO UPDATES SI_CATZONAS
       let vCatalogo  	= 'si_catzonas';
       let vNomarch 	= 'upd_catzonas_' || vfecha_hoy;   
	   let vNomarchdb2 	= 'upd_catzonas_db2_' || vfecha_hoy;   
       let vConteo = 0;
       let vLargoCadena = 0;  --- temporary 
       let vtexto_select = '';
       
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
       
       foreach with hold
            SELECT {+ INDEX (bdinteg:si_catzonas idx_catzonas_fechamodif)} 'UPDATE public.catzonas SET nombrezona =''' || trim(replace(replace(nombrezona,'"',''''),"'", "")) || '''' || ', poblacionzona = ''' || 
                    nvl(trim(replace(poblacionzona,"'", "")), '') || "'" || ', municipiozona = ''' || nvl(trim(replace(municipiozona,"'", "")), '') || "'" || ', codigopostalzona = '
                    || nvl(codigopostalzona, 0) || ', planozona = ' || "'" || nvl(trim(planozona), '') || "'" || ', rumbozona = ' || "'"
                    || nvl(trim(rumbozona), '') || "'" || ', supervisorzona = ' || nvl(supervisorzona,0)  || ', choferzona = ' || nvl(choferzona,0) 
                    || ', jefegrupozona = ' || nvl(jefegrupozona,0) || ', gerentezona = ' || nvl(gerentezona,0) || ', abogadozona = ' || nvl(abogadozona,0)
                    || ', marcaencuesta30dias = ' || "'" || nvl(marcaencuesta30dias,'') || "'" || ', numerocalle = ' || nvl(numerocalle,0)
                    || ', numerocasa = ' || nvl(numerocasa,0) || ', marcaunidadhabitacional = ' || "'" || nvl(marcaunidadhabitacional,'') || "'"
                    || ', numerodivisioncobranzas = ' || nvl(numerodivisioncobranzas,0) || ', claveabogado = ' || nvl(claveabogado,0) || 
                    ', ciudadcobranzas = ' || nvl(ciudadcobranzas,0) || ', numerocobranzas = ' || nvl(numerocobranzas, 0) ||
                    --', clavearagon = ' || "'" || nvl(trim(clavearagon), '') || "'" || ', centro = ' || nvl(centro,0) ||
					', clavearagon = ' || "'" || 1 || "'" || ', centro = ' || nvl(centro,0) ||
                    ' WHERE numerociudad = ' || numerociudad || ' AND numerocolonia = ' || numerocolonia || ';', 
					 numerociudad, numerocolonia, trim(replace(nombrezona,"'", '')), --de aqui en adelante para actualizaciÃÂ³n (23 campos)
				    nvl(trim(replace(poblacionzona,"'", '')), ''), 
				    nvl(trim(replace(municipiozona,"'", '')), ''), nvl(codigopostalzona, 0), nvl(planozona, ''), 
				    nvl(trim(rumbozona),''), nvl(supervisorzona,0), nvl(choferzona,0), 
				    nvl(jefegrupozona,0), nvl(gerentezona,0), nvl(abogadozona,0), nvl(marcaencuesta30dias,''), 
				    nvl(numerocalle, 0), nvl(numerocasa, 0), nvl(marcaunidadhabitacional, ''), 
				    nvl(numerodivisioncobranzas,0) , nvl(claveabogado,0), nvl(ciudadcobranzas,0), 
				    --nvl(numerocobranzas,0), nvl(clavearagon, ''), nvl(centro, 0), usr_modifica  
					nvl(numerocobranzas,0), '1', nvl(centro, 0), usr_modifica  
				
					INTO vtexto_select,
                    i_numerociudad, i_numerocolonia, c_nombrezona, c_poblacionzona, c_municipiozona, i_codigopostalzona,
				    c_planozona, c_rumbozona, i_supervisorzona, i_choferzona, i_jefegrupozona, i_gerentezona,
				    i_abogadozona, c_marcaencuesta30dias, i_numerocalle, i_numerocasa, c_marcaunidadhabitacional,
				    i_numerodivisioncobranzas, i_claveabogado, i_ciudadcobranzas, i_numerocobranzas, c_clavearagon, i_centro, cUsr_modifica
            FROM bdinteg:si_catzonas
            WHERE f_modifica >= vf_ultactualiza
            AND usr_modifica <> 'SYSCARTERA' 
			AND nvl(nomzona_spmx,'') <> '' AND NVL(pobzona_spmx,'') <> '' AND NVL(mnpio_spmx,'') <> ''
			
		    if nvl(vtexto_select, '') <> '' then
				let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
					System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
					System cCadenadb2;
				elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
					System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
					System cCadenadb2;
                    --let vLargoCadena = length(cCadena);
                    --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                    --let vLargoCadena = 0;  
                end if;
				-- MACF Para update  en nueva tabla
				   begin;
                       update bdinteg:si_catzonas_suc set nombrezona= c_nombrezona, poblacionzona= c_poblacionzona, municipiozona= c_municipiozona,
  					      codigopostalzona= i_codigopostalzona, planozona= c_planozona, rumbozona= c_rumbozona, supervisorzona= i_supervisorzona, 
						  choferzona= i_choferzona, jefegrupozona= i_jefegrupozona, gerentezona= i_gerentezona, abogadozona= i_abogadozona, 
						  marcaencuesta30dias= c_marcaencuesta30dias, numerocalle= i_numerocalle, numerocasa= i_numerocasa, marcaunidadhabitacional= c_marcaunidadhabitacional,
						  numerodivisioncobranzas= i_numerodivisioncobranzas, claveabogado= i_claveabogado, ciudadcobranzas= i_ciudadcobranzas,
						  numerocobranzas= i_numerocobranzas, clavearagon= c_clavearagon, centro= i_centro
                        where  numerociudad= i_numerociudad and numerocolonia= i_numerocolonia; 
                   commit;
				   
				-- MACF Para update  en nueva tabla
             else
                exit foreach;
             end if;                  
       end foreach;
       
       if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if; 
       ---- FIN UPDATES SI_CATZONAS

  

      ----- INICIO INSERTS SI_CIUDADES   
       let vCatalogo  = 'si_ciudades';
       let vConteo = 0;
       let vNomarch = 'ins_iciudades_' || vfecha_hoy;
       let vtexto_select =  '';
       
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
      
       foreach with hold
          select 'INSERT INTO public.iciudades values(''' || '001' || ''',''' || pais || ''',''' || estado || ''',''' || ciudad || ''',''' ||
                 --nombre || ''', ' || ciudad_coppel || ',''' || nvl(localidad_banxico,'') || ''',' || nvl(tipo_ciudad,0) || ');',
				 nombre || ''', ' || ciudad_coppel || ',''' || nvl(localidad_banxico,'') || ''',' || '1' || ');',
                 --pais, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, tipo_ciudad
				 pais, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1
				 
				 INTO vtexto_select,
                      i_pais, i_estado, i_ciudad, c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad
          from bdinteg:si_ciudades
          where fecha_insert >= vf_ultinsercion
		    and nvl(d_ciudad,'') <> '' and nvl(elegir,'') = ''
		  
          
          if nvl(vtexto_select, '') <> '' then
              let vConteo = vConteo + 1;
              if  vConteo = 1 then
                  let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                  System cCadena;
              elif vConteo > 1 then
                  let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                  System cCadena;
              end if;
          
              --let vLargoCadena = length(cCadena);
              --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
              --let vLargoCadena = 0;
			  
			  select count(*) into iExiste_cd
			    from bdinteg:si_ciudades_suc
				where empresa = '001' and codigo_pais = i_pais and codigo_estado = i_estado and codigo_ciudad = i_ciudad;
			 
             if iExiste_cd <= 0 then
				  begin;
					   insert into bdinteg:si_ciudades_suc(empresa, codigo_pais, codigo_estado, codigo_ciudad, nombre, numerociudad, localidad, tipo_ciudad)
					   values(pEmpresa, i_pais, i_estado, i_ciudad, c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad);
				  commit;
			 end if;
			  
          else
              exit foreach;
          end if;
      
       end foreach;
    
       if nvl(vtexto_select, '') <> '' then 
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;  ----- FIN  INSERTS SI_CIUDADES
   

       ----  INICIO UPDATE SI_CIUDADES
       let vCatalogo  = 'si_ciudades';
       let vConteo = 0;
       let vNomarch = 'upd_iciudades_' || vfecha_hoy;
       let vtexto_select =  '';
       
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
        
        foreach with hold
            SELECT 'UPDATE public.iciudades SET nombre = ' || "'" || nombre || "'" || ', numerociudad = ' || ciudad_coppel || 
                   --', localidad = ' || "'" || nvl(localidad_banxico,'') || "'" ||  ', tipo_ciudad = ' || nvl(tipo_ciudad,0)  ||
				   ', localidad = ' || "'" || nvl(localidad_banxico,'') || "'" ||  ', tipo_ciudad = 1' ||
                   ' WHERE codigo_estado = ' || estado || ' AND numerociudad = ' || ciudad_coppel || ';',
				   --nombre, ciudad_coppel, nvl(localidad_banxico,''), tipo_ciudad, estado
				   nombre, ciudad_coppel, nvl(localidad_banxico,''), 1, estado
				   INTO vtexto_select,
				   c_nombreciudad, i_numerociudad_2, c_localidad, i_tipociudad, i_estado
				   
            FROM  bdinteg:si_ciudades
            WHERE f_modifica >= vf_ultactualiza
              AND ciudad_coppel <> 0
			  AND nvl(d_ciudad,'') <> '' AND nvl(elegir,'') = ''
        
             if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
                    
                    --let vLargoCadena = length(cCadena);
                    --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                    --let vLargoCadena = 0;  
                end if;
				
				begin;
				  update bdinteg:si_ciudades_suc 
                     set nombre= c_nombreciudad, numerociudad= i_numerociudad_2, localidad= c_localidad, tipo_ciudad= i_tipociudad
				   where codigo_estado= i_estado and numerociudad = i_numerociudad_2; 
                commit;				
				
             else
                exit foreach;
             end if;   
        
        end foreach;
    
       if nvl(vtexto_select, '') <> '' then
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if; ---- FIN UPDATE SI_CIUDADES

 
       ----INSERTS SI_CATCIUDADES      
        let vCatalogo  	= 'si_catciudades';
        let vConteo 	= 0;
        let vNomarch 	= 'ins_catciudades_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catciudades_db2_' || vfecha_hoy;
        let vtexto_select =  '';
         
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
         
      foreach with hold      
            select 'INSERT INTO public.catciudades values(' ||
             numerociudad || ',''' || trim(nombreciudad) || ''',''' || nvl(trim(inicialciudad),'') || ''','  || nvl(tasainteres,0) || ',' || nvl(numeroestado,0) || ',''' ||
             nvl(trim(inicialestado),'') || ''',' || nvl(salariominimo,0) || ',' || nvl(gerentezona,0) || ',' || nvl(regioncobranzas,0) || ',' || nvl(ivaciudad,0) || ',''' || 
             nvl(trim(to_char(antiguedadciudad)),'01-01-1900') || ''',' || nvl(unificaciudadesinformes,0) || ',' || nvl(unificaciudadescobranzas,0) || ',' || nvl(gerentecobranzas,0) || ',''' ||
             nvl(trim(generajobcarteratienda),'') || ''',''' || nvl(trim(inicialcredito),'') || ''',''' || nvl(regionestadodecuenta, '') || ''',' || nvl(tasainteresropa,0) || ',' ||
             nvl(tasainteresmueble12,0) || ',' || nvl(tasainteresmueble18,0) || ',' || nvl(tasainteresprestamo,0) || ',' || nvl(tasainterescelular1,0) || ',' || 
             nvl(tasainterescelular2,0) || ',''' ||  nvl(tipozona, '')  || ''',''' || nvl(fechaultimaactualizacion, '') || ''');' INTO vtexto_select
            from bdinteg:si_catciudades
            where f_inserta >= vf_ultinsercion
            
            if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					 let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				  System cCadenadb2;
                end if;
            
                --let vLargoCadena = length(cCadena);
                --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                --let vLargoCadena = 0;
            else
              exit foreach;
            end if;
          
       end foreach;    
    
       if nvl(vtexto_select, '') <> '' then   
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;    ----INSERTS SI_CATCIUDADES
      
   
       ---- INICIO UPDATE SI_CATCIUDADES
        let vCatalogo  = 'si_catciudades';
        let vConteo = 0;
        let vNomarch = 'upd_catciudades_' || vfecha_hoy;
		let vNomarchdb2 = 'upd_catciudades_db2_' || vfecha_hoy;
        let vtexto_select =  '';
        
        select max(fecha) into vf_ultactualiza
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cUPD;
         
      foreach with hold     
            SELECT 'UPDATE public.catciudades set nombreciudad = ' || "'" || trim(nombreciudad) || "'" || ',inicialciudad = ' 
                   || "'" || nvl(trim(inicialciudad),'') || "'" || ', tasainteres = ' || nvl(tasainteres,0) || ',numeroestado = ' || nvl(numeroestado,0) ||
                   ',inicialestado = ' || "'" || nvl(inicialestado,'') || "'" || ',salariominimo = ' || nvl(salariominimo,0) || ',gerentezona = ' 
                   || nvl(gerentezona,0) || ',regioncobranzas = ' || nvl(regioncobranzas,0) || ',ivaciudad = ' || nvl(ivaciudad,0) || ', antiguedadciudad = '
                   || "'" || nvl(trim(to_char(antiguedadciudad)),'01-01-1900') || "'" || ', unificaciudadesinformes = ' || nvl(unificaciudadesinformes,0) || 
                   ',unificaciudadescobranzas = ' || nvl(unificaciudadescobranzas,0) || ', gerentecobranzas = ' || nvl(gerentecobranzas,0) ||
                   ',generajobcarteratienda = ' || "'" || nvl(trim(generajobcarteratienda),'') || "'" || ',inicialcredito = ' || "'" ||
                    nvl(trim(inicialcredito),'') || "'" || ', regionestadodecuenta = ' || "'" || nvl(regionestadodecuenta, '') || "'" || ',tasainteresropa = '
                   || nvl(tasainteresropa,0) || ', tasainteresmueble12 = ' || nvl(tasainteresmueble12,0) || ',tasainteresmueble18 = ' || 
                   nvl(tasainteresmueble18,0) || ', tasainteresprestamo = ' || nvl(tasainteresprestamo,0) || ', tasainterescelular1 = ' ||
                   nvl(tasainterescelular1,0) || ', tasainterescelular2 = ' || nvl(tasainterescelular2,0) || ', tipozona = ' || "'" ||
                   nvl(tipozona, '') || "' WHERE numerociudad = " || numerociudad || ' AND numeroestado = ' || numeroestado || ';' INTO vtexto_select
             from bdinteg:si_catciudades
            where fechaultimaactualizacion >= vf_ultactualiza
            
            if nvl(vtexto_select, '') <> '' then
                let vConteo = vConteo + 1;
                if  vConteo = 1 then
                    let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				    System cCadenadb2;
                elif vConteo > 1 then
                    let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                    System cCadena;
					let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				   System cCadenadb2;
                end if;
            
                --let vLargoCadena = length(cCadena);
                --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);
                --let vLargoCadena = 0;
            else
              exit foreach;
            end if;
          
       end foreach;
	   
	   if nvl(vtexto_select, '') <> '' then   
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cUPD, vConteo);
       end if;   ---- FIN UPDATE SI_CATCIUDADES
        
     
        ---- INICIO INSERT SI_CATCALLES 
        let vCatalogo  = 'si_catcalles';
        let vConteo = 0;
        let vNomarch = 'ins_catcalles_' || vfecha_hoy;
		let vNomarchdb2 = 'ins_catcalles_db2_' || vfecha_hoy;
        let vtexto_select =  '';
        
       select max(fecha) into vf_ultinsercion
         from bdinteg:si_bitacora_replica_sucs 
        where catalogo = vCatalogo
          and tipo_operacion = cINS;
       
       foreach with hold     
          select {+ INDEX (bdinteg:si_catcalles idx_catcalles_fechains)} 'INSERT INTO public.catcalles values(' ||
                 numerocalle || ',''' || trim(nombrecalle) || ''');'  INTO vtexto_select
           from bdinteg:si_catcalles
          where f_inserta >= vf_ultinsercion
    
          if nvl(vtexto_select, '') <> '' then
            let vConteo = vConteo + 1;
            if  vConteo = 1 then
                let cCadena = 'echo "' || vtexto_select || '">' || trim(vPath) || trim(vNomarch) || '.sql' ;
                System cCadena;
				let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				System cCadenadb2;
            elif vConteo > 1 then
                let cCadena = 'echo "' || vtexto_select || '">>' || trim(vPath) || trim(vNomarch) || '.sql' ;
                System cCadena;
				let cCadenadb2 = 'echo "' || replace(vtexto_select, 'public.', 'DB_BCPL.') || '">>' || trim(vPath) || trim(vNomarchdb2) || '.sql' ;
				System cCadenadb2;
            end if;
            --let vLargoCadena = length(cCadena);                                                         -- this temporary
            --insert into bdinteg:si_bita_cuentaregs (query, largo) values(vtexto_select, vLargoCadena);  
            --let vLargoCadena = 0;                                                                       
          else
            exit foreach;
          end if;
            
       end foreach;
	   
	   if nvl(vtexto_select, '') <> '' then    
           insert into bdinteg:si_bitacora_replica_sucs (catalogo, fecha, tipo_operacion, num_registros)
           values(vCatalogo, vdia, cINS, vConteo);
       end if;    ---- FIN INSERTS SI_CATCALLES
    
 
	   ------------------------------------------  NUEVA DESCARGA CATDOMS PARA OMNICANAL 2022-11-17
	   select valor into vEjecuta_omnicanal
         from bdinteg:si_param_dom
        where empresa = pEmpresa and cod_param = 31;  
	   
	   
	   IF vEjecuta_omnicanal = 'S' THEN
	      
		  --LET vNomarch = 'catalogo_catzonas.txt';
		  LET vNomarch = 'catalogo_catzonas_' || vfecha_hoy || '.txt';

	      select valor into vPath_ominicanal
            from bdinteg:si_param_dom
           where empresa = pEmpresa and cod_param = 30;  

		 LET cCadena_omni = 'echo " UNLOAD TO ' || trim(vPath_ominicanal) || trim(vNomarch)  || ' DELIMITER ''' || vSeparador || ''' SELECT  a.numerociudad, a.numerocolonia, ' 
  || 'trim(replace(a.nomzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.pobzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.mnpio_spmx,chr(39),''' || ''')), ' 
  || 'nvl(a.codigopostalzona, 0), '
  || 'case when nvl(a.planozona,''' || ''') <> ''' || ''' then trim(a.planozona) else null end, case when nvl(a.rumbozona,''' || ''') <> ''' || ''' then trim(a.rumbozona) else null end, '
  || 'nvl(a.supervisorzona,0), nvl(a.choferzona,0), ' 
  || 'nvl(a.jefegrupozona,0), nvl(a.gerentezona,0), ' 
  || 'nvl(a.abogadozona,0), case when nvl(a.marcaencuesta30dias,''' || ''') <> ''' || ''' then trim(a.marcaencuesta30dias) else null end,'
  || 'nvl(a.numerocalle, 0), nvl(a.numerocasa, 0),'
  || 'case when nvl(a.marcaunidadhabitacional,''' || ''') <> ''' || ''' then trim(a.marcaunidadhabitacional) else null end, '
  || 'nvl(a.numerodivisioncobranzas,0), '
  || 'nvl(a.claveabogado,0), nvl(a.ciudadcobranzas,0), '
  || 'nvl(a.numerocobranzas,0), ''' || '1' || ''' clavearagon, '
  || 'nvl(a.centro, 0) '
  || 'FROM si_catzonas a, si_catsepomex b, si_estados c, si_ciudades d '
  || 'where c.estado = d.estado '
  || 'and lpad(a.codigopostalzona,5,''' || '0' || ''') = b.d_codigo '
  || 'and c.estado = b.c_estado '
  || 'and a.numerociudad = d.ciudad_coppel '
  || 'and TRIM(a.nomzona_spmx) = b.d_asenta '
  || 'and TRIM(a.mnpio_spmx) = b.d_mnpio '
  || 'and b.d_ciudad = d.d_ciudad '
  || 'and (d.ciudad_coppel > 0 AND ciudad_coppel <> 6564) '
  || 'and d.elegir IS NULL '
  || 'UNION '
  || 'SELECT a.numerociudad, a.numerocolonia, trim(replace(a.nomzona_spmx,chr(39),''' || ''')),' 
  || 'trim(replace(a.pobzona_spmx,chr(39),''' || ''')), ' 
  || 'trim(replace(a.mnpio_spmx,chr(39),''' || ''')), ' 
  || 'nvl(a.codigopostalzona, 0), '
  || 'case when nvl(a.planozona,''' || ''') <> ''' || ''' then trim(a.planozona) else null end,case when nvl(a.rumbozona,''' || ''') <> ''' || ''' then trim(a.rumbozona) else null end, '
  || 'nvl(a.supervisorzona,0), nvl(a.choferzona,0), ' 
  || 'nvl(a.jefegrupozona,0), nvl(a.gerentezona,0), ' 
  || 'nvl(a.abogadozona,0), case when nvl(a.marcaencuesta30dias,''' || ''') <> ''' || ''' then trim(a.marcaencuesta30dias) else null end,'
  || 'nvl(a.numerocalle, 0), nvl(a.numerocasa, 0),'
  || 'case when nvl(a.marcaunidadhabitacional,''' || ''') <> ''' || ''' then trim(a.marcaunidadhabitacional) else null end, '
  || 'nvl(a.numerodivisioncobranzas,0), '
  || 'nvl(a.claveabogado,0), nvl(a.ciudadcobranzas,0), '
  || 'nvl(a.numerocobranzas,0), ''' || '1' || ''' clavearagon, '
  || 'nvl(a.centro, 0) '
  || 'FROM si_catzonas a, si_catsepomex b, si_estados c, si_ciudades d '
  || 'where c.estado = d.estado ' 
  || 'and lpad(a.codigopostalzona,5,''' || '0' || ''') = b.d_codigo '
  || 'and c.estado = b.c_estado and d.estado = ''' || '09' || ''' and a.numerociudad = d.ciudad_coppel '
  || 'and TRIM(a.nomzona_spmx) = b.d_asenta '
  || 'and TRIM(a.mnpio_spmx) = b.d_mnpio '
  || 'and (d.ciudad_coppel > 0 and d.ciudad_coppel <> 6564) '
  || 'and d.elegir IS NULL '
  || 'and nvl(a.nomzona_spmx,''' || ''') <> ''' || ''' and nvl(a.pobzona_spmx, ''' || ''') <> ''' || ''' and nvl(a.mnpio_spmx, ''' || ''') <> ''''" >' || trim(vPath_ominicanal) ||'corre_si_catzonas.sql'; 

 
         SYSTEM TRIM(cCadena_omni);
         let cCadena_omni = '';
   
         let cCadena = 'dbaccess bdinteg ' || trim(vPath_ominicanal) || 'corre_si_catzonas.sql';
         SYSTEM TRIM(cCadena);
	   
	     let cCadena = '';
         let cCadena = 'rm ' || trim(vPath_ominicanal) || 'corre_si_catzonas.sql';
         SYSTEM TRIM(cCadena);
	   
	     LET cCadena = "";
		 LET cCadena = "gzip -f " || TRIM(vPath_ominicanal) || vNomarch;
		 SYSTEM TRIM(cCadena);
	   
	     --------------------  CIUDADES
		 LET vNomarch = 'catalogo_iciudades_' || vfecha_hoy || '.txt';
	     LET cCadena = '';  
	 
	     LET cCadena = 'echo " UNLOAD TO ' || trim(vPath_ominicanal) || trim(vNomarch)  || ' DELIMITER ''' || vSeparador || ''' SELECT ''' || '001' || ''
	     || ''',1, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1 '
         || 'FROM bdinteg:si_ciudades '
	     || 'WHERE ciudad_coppel > 0 '
	     || 'AND elegir is null AND nvl(d_ciudad,''' || ''') <> ''' || ''' and estado <> ''' || '09' || ''' UNION '
	     || 'SELECT ''' || '001' || ''',1, estado, ciudad, nombre, ciudad_coppel, localidad_banxico, 1 '
	     || 'FROM bdinteg:si_ciudades '
	     || 'WHERE ciudad_coppel <> 6564 '
	     || 'AND elegir is null AND nvl(d_ciudad,''' || ''') <> ''' || ''' and estado = ''' || '09' || '''" >' || trim(vPath_ominicanal) ||'corre_si_ciudades.sql';
	 
	     SYSTEM TRIM(cCadena);
	     let cCadena = '';
  
         let cCadena = 'dbaccess bdinteg ' || trim(vPath_ominicanal) || 'corre_si_ciudades.sql';
         SYSTEM TRIM(cCadena);
	   
	     let cCadena = '';
         let cCadena = 'rm ' || trim(vPath_ominicanal) || 'corre_si_ciudades.sql';
         SYSTEM TRIM(cCadena);  

	     LET cCadena = "";
		 LET cCadena = "gzip -f " || TRIM(vPath_ominicanal) || vNomarch;
		 SYSTEM TRIM(cCadena);
	   
	   END IF;
 
       ----REGISTRO EN BITACORA
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE  INTO vdia from sysmaster:sysshmvals;
       SELECT DBINFO('utc_to_datetime', sh_curtime)::DATETIME HOUR TO SECOND INTO vhora from sysmaster:sysshmvals;
       
       INSERT INTO bdinteg:si_bitacora_dom(proceso, cod_ret, mensaje, reg_insert, user_insert, fecha_insert, hora_insert)
            VALUES('GENERA SCRIPTS CATDOMS SUC.', v_codret, cMensaje, 0, pUsuario, vdia, vhora);
   else
     let v_codret = '00OFF';
   end if;
   
  RETURN v_codret;
END;

END PROCEDURE;