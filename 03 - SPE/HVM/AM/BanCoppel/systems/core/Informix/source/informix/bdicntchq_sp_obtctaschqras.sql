CREATE PROCEDURE "informix".sp_obtctaschqras( pEmpresa CHAR(3), pNumCte CHAR(20) )

--DATOS A REGRESAR--
RETURNING CHAR(5)       AS CodRet, 
		  VARCHAR(100)  AS Mensaje,
		  CHAR(20)		AS Cuenta;
		  
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCodRet      	 CHAR(5);
	DEFINE iSqlErr			 INTEGER;
	DEFINE cCuenta 			 CHAR(20);
	
	DEFINE vCodRet 	 		 VARCHAR(5);
	DEFINE vMsjRetorno 		 VARCHAR(100);
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet				= "00000";
	LET iSqlErr 			= 0;
	LET cCuenta 			= "";
	
	LET vCodRet 	 		= "00000";
	LET vMsjRetorno  		= "Ejecución Exitosa";
	
	-- SET DEBUG FILE TO '/home/sysifx/vlv/sp_obtctaschqras.out';
	-- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr::CHAR(5), '', '';
			END IF;
		END EXCEPTION;		
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR  TRIM(NVL(pNumCte,'')) = '' THEN 
		
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('01','050')
			INTO vCodRet, vMsjRetorno;
			LET cCodRet = '00001';
			
			RETURN cCodRet, TRIM(vMsjRetorno), TRIM(NVL(cCuenta,''));
		END IF
		
		-- CONSULTAMOS LAS CUENTAS CON CHEQUERAS.
		FOREACH WITH HOLD
			SELECT cuenta INTO cCuenta
			FROM bdicheq:"informix".sc_maechq mae, bdicheq:"informix".sc_producto prod  
			WHERE mae.empresa = pEmpresa
		      AND mae.num_cte = pNumCte
			  AND mae.producto = prod.producto 
			  AND prod.val_chequeras = 'S' 
			ORDER BY cuenta
			
			RETURN cCodRet, TRIM(vMsjRetorno), TRIM(NVL(cCuenta,'')) WITH RESUME;
			
	    END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('01','023')
			INTO vCodRet, vMsjRetorno;
			LET cCodRet = '00002';
			
			RETURN cCodRet, TRIM(vMsjRetorno), TRIM(NVL(cCuenta,''));
			
		END IF
		
	END
END PROCEDURE 
DOCUMENT
"DESCRIPCION: Procedimiento para obtener las cuentas de chequeras que tiene el cliente solicitado.",
"REALIZÓ: Valentin Lopez",
"FECHA: 20/Agosto/2012",
"BD: bdicntchq ",
'VERSION: 20120820.1516';

CREATE PROCEDURE "informix".sp_obtinfocte(pEmpresa CHAR(3), pNumCte CHAR(20), pCuenta CHAR(20))	

--DATOS A REGRESAR--
RETURNING CHAR(5)       AS CodRet, 
		  VARCHAR(100)  AS Mensaje,
		  CHAR(20)      AS Cliente, 
		  CHAR(20)      AS Cuenta,
		  CHAR(80)      AS Nombre,
		  INTEGER       AS CheqActivos,
		  CHAR(1)       AS AltCons,
		  INTEGER		AS ChqSolicitados;
		  
		  
	-- DEFINICION DE VARIABLES
	DEFINE cCodRet      	 CHAR(5);
	DEFINE iSqlErr			 INTEGER;
	DEFINE cNumCte 			 CHAR(20);
	DEFINE cCuenta 			 CHAR(20);
	DEFINE iChqAct 			 INTEGER;
	DEFINE cAltCons 		 CHAR(1);
	DEFINE iChqSolic 		 INTEGER;
	DEFINE cNombre 	 		 CHAR(80);
	DEFINE vCodRet 	 		 VARCHAR(5);
	DEFINE vMsjRetorno 		 VARCHAR(100);
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet				= "00000";
	LET iSqlErr 			= 0;
	LET cNumCte 			= "";
	LET cCuenta 			= "";
	LET iChqAct 			= 0;
	LET cAltCons 		    = "";
	LET iChqSolic 			= 0;
	LET cNombre 	 		= "";
	LET vCodRet 	 		= "00000";
	LET vMsjRetorno  		= "Ejecución Exitosa";
	
	 -- SET DEBUG FILE TO '/home/sysifx/vlv/sp_obtinfocte.out';
	 -- TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- INICIO DEL PROCEDIMIENTO
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr, '', '', '','', 0, '', 0;
			END IF;
		END EXCEPTION;		
		
		IF TRIM(NVL(pEmpresa,'')) = '' OR TRIM(NVL(pNumCte,'')) = '' OR TRIM(NVL(pCuenta,'')) = '' THEN
		
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('01','050')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00001';
			RETURN cCodRet, TRIM(vMsjRetorno), TRIM(NVL(cNumCte,'')), TRIM(NVL(cCuenta,'')), TRIM(NVL(cNombre,'')), NVL(iChqAct,0), TRIM(NVL(cAltCons,'')), NVL(iChqSolic,0);
		END IF
		
		-- VERIFICAMOS SI EXISTE LA CUENTA EN LA MAESTRO DE CHEQUES.
		SELECT num_cte, cuenta
		INTO cNumCte, cCuenta
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = TRIM(pEmpresa) 
		  AND cuenta = TRIM(pCuenta)
		  AND num_cte = TRIM(pNumCte);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret('01','100')
			INTO vCodRet, vMsjRetorno;
			
			LET cCodRet = '00002';
			
			RETURN cCodRet, TRIM(vMsjRetorno), TRIM(NVL(cNumCte,'')), TRIM(NVL(cCuenta,'')), TRIM(NVL(cNombre,'')), NVL(iChqAct,0), TRIM(NVL(cAltCons,'')), NVL(iChqSolic,0);
		ELSE
		
			-- CONSULTAMOS LOS CLIENTES CON ALTO CONSUMO.
			SELECT cheques_activos, alt_consumo, chequeras_sol
			INTO iChqAct, cAltCons, iChqSolic
			FROM bdicntchq:"informix".sq_ctealtconsumo
			WHERE empresa = TRIM(pEmpresa) 
			  AND numcte = TRIM(pNumCte) 
			  AND cuenta = TRIM(pCuenta);
			
			-- CONSULTAMOS EL NOMBRE DEL CLIENTE SELECCIONADO.
			SELECT TRIM(nombre1)||' '||TRIM(nombre2)||' '||TRIM(apell_paterno)||' '||TRIM(apell_materno)||' '||TRIM(razon_social)
			INTO cNombre
			FROM bdinteg:"informix".si_cliente 
			WHERE empresa = TRIM(pEmpresa) 
			  AND numcte = TRIM(cNumCte);
			
		    RETURN cCodRet, TRIM(vMsjRetorno), TRIM(NVL(cNumCte,'')), TRIM(NVL(cCuenta,'')), TRIM(NVL(cNombre,'')), NVL(iChqAct,0), TRIM(NVL(cAltCons,'')), NVL(iChqSolic,0);
		END IF
		
	END
END PROCEDURE             
DOCUMENT
"DESCRIPCION: Consulta el cliente de alto consumo de chequeras.",
"REALIZÓ: Valentin Lopez",
"FECHA: 07/Agosto/2012",
"BD: bdicntchq ",
'VERSION: 20120807.1516';

CREATE PROCEDURE "informix".sp_agenda_clientes(pempresa CHAR(3),ptipo CHAR(1))
RETURNING     CHAR(5)   AS CodRet,   			-- cCodRet
              CHAR(15)  AS NumCte,  			-- vnumcte = cliente
              CHAR(105) AS Nombre_Razon_Social, -- vnombre = nombre/razon Social
              CHAR(45)  AS Domicilio,  			-- vdomicilio = calle y numero
              CHAR(30)  AS Complemento,  		-- vcomplemento = referencia
              CHAR(60)  AS Colonia,  			-- vcolonia = colonia
              CHAR(60)  AS Ciudad,  			-- vciudad = 60
              CHAR(5)   AS CP,   				-- vcp = c.p.
              CHAR(26)  AS Telefono, 			-- vtel = telefono
              CHAR(60)  AS Email,  				-- vemail= correo electronico
              CHAR(1)   AS TpoCP,  				-- vtpocp
              CHAR(1)   AS VTM,  				-- vtm
              CHAR(20)  AS Cuenta,  			-- vcuenta
              INTEGER   AS Consecutivo,  		-- vconsec
              CHAR(60)  AS Estado,  			-- estado
              CHAR(60)  AS MUN;  				-- MUN
			  
   -- ********************************************************************
   --
   -- Nombre:              sp_agenda_clientes
   --
   -- Version              1.0.1
   -- Objetivo:            Consulta la informacion para el catalogo clientes mensajeria
   -- Supuestos:           Ninguno
   -- Creado por:          Alejandro Rueda Sanchez
   -- ModIFicado por:
   -- ModIFicado por:
   -- Ultima Modificacion: Marzo  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************
	
	-- // Definicion de variables
	DEFINE cCodRet          CHAR(5);
	DEFINE vsqlerr          INTEGER;
	DEFINE vcuenta          CHAR(20);
	DEFINE vnumcte          CHAR(20);
	DEFINE vconsec          INTEGER;
	DEFINE vpais            CHAR(3);
	
	DEFINE vnombre          CHAR(105); 	-- vnombre = nombre/razon Social
	DEFINE vdomicilio       CHAR(45);  	-- vdomicilio = calle y numero
	DEFINE vcomplemento     CHAR(30);  	-- vcomplemento = referencia
	DEFINE vcolonia         CHAR(60);  	-- vcolonia = colonia
	DEFINE vciudad          CHAR(60);  	-- vciudad = 60
	DEFINE vcp              CHAR(5);   	-- vcp = c.p.
	DEFINE vtel             CHAR(26);  	-- vtel = telefono
	DEFINE vemail           CHAR(60);  	-- vemail= correo electronico
	DEFINE vtpocp           CHAR(1);   	-- vtpocp
	DEFINE vtm              CHAR(1);   	-- vtm
	DEFINE vdummy           CHAR(100);
	DEFINE vdummy1          CHAR(100);
	DEFINE vdummy2          CHAR(100);
	DEFINE vdummy3          CHAR(100);
	DEFINE vnomcte          CHAR(52); 	-- nombre separado
	DEFINE vpaterno         CHAR(26); 	-- apellido paterno
	DEFINE vmaterno         CHAR(26); 	-- apellido materno
	DEFINE v_calle	        CHAR(30);
	DEFINE v_numext	        CHAR(10);
	DEFINE v_numint         CHAR(10);
	DEFINE v_depto	        CHAR(6);
	DEFINE v_tel1           CHAR(13);
	DEFINE v_tel2           CHAR(13);
	DEFINE v_tel3           CHAR(13);
	DEFINE v_ext 	        CHAR(10);
	DEFINE v_tpdir          CHAR(1);
	DEFINE vt_direcc_envio  SMALLINT;
	DEFINE vmun             CHAR(60);
	
	
	LET cCodRet     		= " ";
	LET vcuenta     		= " ";
	LET vnumcte     		= " ";
	LET vconsec     		= 0;
	LET vnombre     		= " ";
	LET vdomicilio  		= " ";
	LET vcomplemento		= " ";
	LET vcolonia    		= " ";
	LET vciudad     		= " ";
	LET vcp         		= " ";
	LET vtel        		= " ";
	LET vemail       		= " ";
	LET vtpocp      		= " ";
	LET vtm         		= " ";
	LET vmun       	 		= " "; 
	LET v_calle      		= " "; 
	LET v_numext      		= " "; 
	LET v_numint      		= " "; 
	LET v_depto      		= " "; 
	LET vdummy      		= " "; 
	LET vdummy1      		= " "; 
	LET vdummy2      		= " "; 
	LET vdummy3      		= " "; 
	LET v_tel1      		= " "; 
	LET v_tel2      		= " "; 
	LET v_tel3      		= " "; 
	LET v_ext      			= " "; 
	LET v_tpdir      		= " ";
	LET vpais        		= " ";
	LET vnomcte         	= " ";
	LET vpaterno      		= " ";
	LET vmaterno       		= " ";
	
	
	--SET DEBUG FILE TO "/home/sysifx/vlv/sp_agenda_clientes.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET vsqlerr
		IF vsqlerr <> 0 THEN
			LET cCodRet = vsqlerr;
			RETURN cCodRet, TRIM(NVL(vnumcte,'')), TRIM(NVL(vnombre,'')), TRIM(NVL(vdomicilio,'')), TRIM(NVL(vcomplemento,'')), TRIM(NVL(vcolonia,'')), TRIM(NVL(vciudad,'')), TRIM(NVL(vcp,'')), TRIM(NVL(vtel,'')), TRIM(NVL(vemail,'')), TRIM(NVL(vtpocp,'')), TRIM(NVL(vtm,'')), TRIM(NVL(vcuenta,'')), NVL(vconsec,0), TRIM(NVL(vdummy,'')), TRIM(NVL(vmun,''));
		END IF;
	END EXCEPTION;
	
	IF NVL(ptipo,"") = "" THEN
		LET ptipo = "G";
	END IF
	
    LET vt_direcc_envio = 0;
	
	-- CONSULTAMOS LAS CUENTAS CON PERFIL DE ALTO CONSUMO CHEQUERAS
    FOREACH
		SELECT a.cuenta, DECODE(NVL(b.chequeras_sol,''),'', 1, b.chequeras_sol)
		INTO vcuenta, vconsec
		FROM bdicntchq:sq_maechqra a
			 LEFT JOIN bdicntchq:"informix".sq_ctealtconsumo b ON (a.empresa = b.empresa AND a.cuenta = b.cuenta AND b.alt_consumo = '1' )
		WHERE a.status = ptipo
		GROUP BY a.cuenta, b.chequeras_sol
		
		--//Extrae el numero de cliente
		SELECT num_cte, direcc_envio
		  INTO vnumcte, vt_direcc_envio
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = pempresa
		  AND cuenta = vcuenta;
		
		--//Busca los datos del cliente
		EXECUTE PROCEDURE bdicntchq:cons_nom_cte(pempresa,vnumcte)
		INTO cCodRet, vdummy, vnomcte, vpaterno, vmaterno, vdummy, vdummy, vdummy, vdummy, vdummy, vemail;
		
		LET vnombre = TRIM(vnomcte)||" "||TRIM(vpaterno)||" "||TRIM(vmaterno);
		LET vemail = TRIM(vemail);
		
		IF vemail IS NULL OR vemail = "" THEN
			LET vtm = "F";
		ELSE
			LET vtm = "V";
		END IF;
		
		--//Busca la direccion del cliente
		IF vt_direcc_envio = 0 OR vt_direcc_envio IS NULL THEN
			LET vt_direcc_envio = 1;
		END IF
		
		FOREACH
			EXECUTE PROCEDURE bdicntchq:cons_dir_cte(pempresa,vnumcte,vt_direcc_envio)
			INTO cCodRet, v_calle, v_numext, v_numint, v_depto, vcolonia, vciudad, vdummy, vcp, vdummy1, vcomplemento, v_tel1, v_tel2, v_tel3, v_ext, vdummy2 ,vdummy3, v_tpdir, vpais, vmun
		END FOREACH
		
		LET vdomicilio = TRIM(v_calle);
		LET v_numext = TRIM(v_numext);
		
		IF v_numext <> "" THEN
			LET vdomicilio = TRIM(vdomicilio)||" No. "||TRIM(v_numext);
		END IF
		
		LET v_numint = TRIM(v_numint);
		
		IF v_numint <> "" THEN
			LET vdomicilio = TRIM(vdomicilio)||" - "||TRIM(v_numint);
		END IF
		
		LET v_depto = TRIM(v_depto);
		
		IF v_depto <> "" THEN
			LET vdomicilio = TRIM(vdomicilio)||" Dep. "||TRIM(v_depto);
		END IF
		
		LET v_tel1 = TRIM(v_tel1);
		LET v_tel2 = TRIM(v_tel2);
		LET v_tel3 = TRIM(v_tel3);
		LET v_ext = TRIM(v_ext);
		
		IF v_tel1 <> "" THEN
			LET vtel = v_tel1;
		ELIF v_tel2 <> "" THEN
			LET vtel = v_tel2;
		ELIF v_tel3 <> "" THEN
			LET vtel = v_tel3;
			
			IF v_ext <> "" THEN
				LET vtel = v_tel3||" Ext "||v_ext;
			END IF
		END IF;
		
		LET vtpocp = "N";
		
		IF vpais =  "003" THEN
			LET vtpocp = "E";
		ELIF vpais <>  "001" THEN
			LET vtpocp = "R";
		END IF
		
		RETURN cCodRet, TRIM(NVL(vnumcte,'')), TRIM(NVL(vnombre,'')), TRIM(NVL(vdomicilio,'')), TRIM(NVL(vcomplemento,'')), TRIM(NVL(vcolonia,'')), TRIM(NVL(vciudad,'')), TRIM(NVL(vcp,'')), TRIM(NVL(vtel,'')), TRIM(NVL(vemail,'')), TRIM(NVL(vtpocp,'')), TRIM(NVL(vtm,'')), TRIM(NVL(vcuenta,'')), NVL(vconsec,0), TRIM(NVL(vdummy,'')), TRIM(NVL(vmun,'')) WITH RESUME;
		
    END FOREACH
END
END PROCEDURE 
DOCUMENT
"DESCRIPCION: Se agrego una consulta a la tabla bdicntchq:sq_ctealtconsum ", 
"             para retornar solamente las cuentas con perfil de alto consumo chequeras.",
"MODIFICO: Valentin Lopez",
"FECHA: 27/Agosto/2012",
"BD: bdicntchq ",
'VERSION: 20120827.1626',
"DESCRIPCION: Se modifica procedimiento para que solo obtenga el primer registro de chequeres solicitadas y no el maximo como se tenia ", 
"MODIFICO: Armando Morales",
"FECHA: 13/Septiembre/2012",
"BD: bdicntchq ",
'VERSION: 20120913.1000';

create procedure "informix".cons_dir_cte(
	       	pempresa  	char(20),
	       	pcliente  	char(20),
            ptipodir        char(2))
		RETURNING
		char(5),char(50),char(10),char(10),
		char(10),char(30),char(60),
		char(30),char(80),char(40),
		char(100),char(100),char(13),
		char(13),char(10),char(10),
                char(10), char(1), char(3), char(60);
-- ********************************************************************
--
-- Nombre:              cons_dir_cte
--
-- Version              1.0.0
-- Objetivo:            Consulta la direccion de un cliente
-- Supuestos:           Ninguno
-- Creado por:          Alejandro Rueda Sanchez
-- ModIFicado por:
-- Ultima Modificacion: Febrero  - 2010
--
--                      Reingenieria de SPL
--
-- ********************************************************************


-- // Definicion de variables
DEFINE v_codret         char(5);
DEFINE v_calle		char(30);
DEFINE v_numext	    	char(10);
DEFINE v_numint       	char(10);
DEFINE v_depto	      	char(6);
DEFINE v_colonia       	char(30);
DEFINE v_ciudad	     	char(60);
DEFINE v_estado	   	char(30);
DEFINE v_obs	   	char(80);
DEFINE v_entrecalles   	char(40);
DEFINE v_cp	   	char(5);
DEFINE v_tel1   	char(13);
DEFINE v_tel2   	char(13);
DEFINE v_tel3   	char(13);
DEFINE v_ext 	  	char(10);
DEFINE v_tpdir 	  	char(1);
DEFINE v_tipodir  	char(10);
DEFINE v_fechacap  	char(10);
DEFINE v_contador       smallint;
DEFINE v_pais           char(3);
DEFINE v_mun        char(60);
DEFINE sql_err,isam_err  int;

--VARIABLE PARA LOS TELEFONOS
DEFINE	vcodrett         CHAR(5);
DEFINE	vTelefono        CHAR(13);
DEFINE	vTipoTel         SMALLINT;
DEFINE	vSecuenciaTel    SMALLINT;
DEFINE	vStatus_Tel      CHAR(1);
DEFINE	vExtensionTel    CHAR(5);
DEFINE	vNombreCarrier   CHAR(20);
DEFINE	StatusValidacion SMALLINT;
DEFINE vCarrier         SMALLINT;



LET v_codret    = "000";
LET v_calle		="";
LET v_numext	="";
LET v_numint	="";
LET v_depto		="";
LET v_colonia	="";
LET v_ciudad	="";
LET v_estado	="";
LET v_cp		="";
LET v_obs		="";
LET v_entrecalles="";
LET	v_tel1		="";
LET v_tel2		="";
LET v_tel3		="";
LET v_ext		="";
LET v_tipodir	="";
LET v_fechacap	="";
LET v_tpdir		="";
LET v_pais		="";
LET v_mun		="";



--variables para los telefonos
LET	vcodrett         = "";
LET	vTelefono        = "";
LET	vTipoTel         = 0;
LET	vSecuenciaTel    = 0;
LET	vStatus_Tel      = "";
LET	vExtensionTel    = "";
LET	vNombreCarrier   = "";
LET	StatusValidacion = 0;
LET	vCarrier = 0;


BEGIN
	on exception set sql_err,isam_err
	if sql_err <> 0 or isam_err <> 0 then
		let v_codret = sql_err;
		RETURN  v_codret,v_calle,v_numext,v_numint,v_depto,
			v_colonia,v_ciudad,v_estado,v_obs,v_entrecalles,
			v_cp,v_tel1,v_tel2,v_tel3,v_ext,v_tipodir,
                        v_fechacap, v_tpdir, v_pais,v_mun;
	end if;
	end exception;

   --SET DEBUG FILE TO "/tmp/cons_dir_cte.out";
   --TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

	IF  	pcliente is null then

		   -- datos de entrada incompletos
		LET v_codret = 110;
		RETURN  v_codret,v_calle,v_numext,v_numint,v_depto,
			v_colonia,v_ciudad,v_estado,v_obs,v_entrecalles,
			v_cp,v_tel1,v_tel2,v_tel3,v_ext,v_tipodir,
                        v_fechacap, v_tpdir, v_pais,v_mun;
	END IF;


-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************

        let v_contador      	= 0;
        let v_ciudad		=" ";


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

	FOREACH

		-- direcciones completas del cliente

		SELECT 	cal.nombrecalle as calle,dir.numeroextcalle,
			dir.numerointcalle, dir.departamento,
			zon.nombrezona as colonia,nvl(cds.nombre," ") as cd,
			edo.nombre as edo, dir.cod_postal, dir.observaciones,
			dir.entre_calles,
			decode(dir.tipo_dir,'1','Particular','2','Oficina'),
                        dir.fecha_insert, dir.tipo_dir, dir.pais, nvl(mun.nombre," ") as mun
		INTO	v_calle,v_numext,v_numint,v_depto,v_colonia,
			v_ciudad,v_estado,v_cp,v_obs,v_entrecalles,
			v_tipodir,v_fechacap,
                        v_tpdir, v_pais, v_mun
               FROM bdinteg:si_direcciones dir,
                        outer  bdinteg:si_estados edo ,
                        outer bdinteg:si_ciudades cds,
                        outer bdinteg:si_catzonas zon,
                        outer bdinteg:si_catcalles cal,
                        outer bdinteg:si_municipios mun
                WHERE  dir.numcte = pcliente
                    AND edo.estado=dir.estado
                    AND cds.pais = 1
                    AND cds.estado=dir.estado
                    AND cds.ciudad=dir.ciudad
                    AND zon.numerociudad =dir.numerociudad
                    AND zon.numerocolonia = dir.numerocolonia
                    AND cal.numerocalle=dir.numerocalle
                    AND dir.secuencia = ptipodir
                    AND mun.municipio=substring (dir.municipio from 2 for 3)
                    AND mun.ciudad=dir.ciudad
                    AND mun.estado=dir.estado

                order by dir.secuencia

		EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001',pcliente,1,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET v_tel1 = vTelefono;
		
		EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001',pcliente,2,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET v_tel2 = vTelefono;
		LET v_ext = vExtensionTel;
		
		EXECUTE PROCEDURE bdinteg:sp_consulta_telefonos('001',pcliente,3,'0')
		INTO
		vcodrett, vTelefono, vTipoTel, vSecuenciaTel, vStatus_Tel, vExtensionTel,vCarrier, vNombreCarrier, StatusValidacion;
		
		LET v_tel3 = vTelefono;



		RETURN  v_codret,v_calle,v_numext,v_numint,v_depto,
			v_colonia,v_ciudad,v_estado,v_cp,v_obs,v_entrecalles,
			v_tel1,v_tel2,v_tel3,v_ext,v_tipodir,v_fechacap, v_tpdir, v_pais,v_mun WITH resume;

	END FOREACH

END;
END PROCEDURE;