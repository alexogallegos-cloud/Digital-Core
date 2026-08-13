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