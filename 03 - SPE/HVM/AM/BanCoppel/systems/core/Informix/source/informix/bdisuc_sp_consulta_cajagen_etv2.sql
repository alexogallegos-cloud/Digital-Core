CREATE PROCEDURE "informix".sp_consulta_cajagen_etv2( pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(4), CHAR(60);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE vcod_proveedor CHAR(4);
DEFINE vdescripcion CHAR(60);

LET cod_ret = '00000';
LET vcod_proveedor = '';
LET vdescripcion = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR;

        RETURN cod_ret,vcod_proveedor,vdescripcion;
    END EXCEPTION;

    set isolation to dirty read;

        --SET debug file to "/informix/1170/calizarraga/sp_consulta_cajagen_etv.out";
        --trace on;

        --SET DEBUG FILE TO "/tmp/mfinis/sp_consulta_cajagen_etv2.out";
        --TRACE ON;

    FOREACH
        SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor,descripcion
        INTO vcod_proveedor, vdescripcion
        FROM bdisuc:"informix".ss_proveedores
        ORDER BY cod_proveedor

        RETURN cod_ret,vcod_proveedor,vdescripcion WITH resume;
    END FOREACH;
END;

END PROCEDURE
DOCUMENT 'AUTOR:Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'DESCRIPCION: Se clona spl para sp_consulta_cajagen_etv agregar paginaciÃ³n.',
'AUTOR:Martha Salgado',
'FECHA: 06/08/2018',
'DESCRIPCION: Se agrega el orden por campo cod_proveedor',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consulta_ccpanamericano_etv2(pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5),CHAR(4),CHAR (30);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE vcentro_costos CHAR(4);
DEFINE vcaja_general CHAR (30);

LET cod_ret = '00000';
LET vcentro_costos = '';
LET vcaja_general = '';

BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR; 
		
        RETURN cod_ret,vcentro_costos,vcaja_general;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/mfinis/sp_consulta_ccpanamericano_etv2.out";
	--TRACE ON;

    FOREACH
        SELECT SKIP pRegistros FIRST pRecuperacion centro_costos,caja_general
        INTO vcentro_costos,vcaja_general
        FROM bdisuc:"informix".ss_sucursales_panamericano
        ORDER BY centro_costos

        RETURN cod_ret,vcentro_costos,vcaja_general WITH resume;
    END FOREACH;
END;

END PROCEDURE
DOCUMENT 'AUTOR:Rodolfo Conde Flores',
'FECHA: 20/03/2018',
'DESCRIPCION: Se clona spl sp_consulta_ccpanamericano_etv para agregar paginaciÃ³n.';

CREATE PROCEDURE "informix".sp_consulta_sucursal_atm_etv2(pRegistros INTEGER, pRecuperacion INTEGER)
							
RETURNING CHAR(6),CHAR(4);

DEFINE SQL_ERR   	  			INTEGER;
DEFINE ISAM_ERR   	 			INTEGER;
DEFINE vcodret 					CHAR(6);
DEFINE vcentro_costos        	CHAR(4);


LET vcodret='';
LET vcentro_costos = '';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR
      LET vcodret    = SQL_ERR;
      
      RETURN vcodret,vcentro_costos;
   END EXCEPTION;
 

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT sucursal 
	INTO vcentro_costos
	FROM bdisuc:"informix".ss_operaciones WHERE 
	cod_trans in ('0026','0002','0041')
	--and fecha_operacion = today
	ORDER BY sucursal

	RETURN vcodret,vcentro_costos WITH RESUME;
END FOREACH;
	
end;						
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 11/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SPL clon que consulta el centro de costos por Concentaciones del Monitor de Efectivo en Línea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_consulta_sucursal_atm_etv2_2(pRegistros INTEGER, pRecuperacion INTEGER)
							
RETURNING CHAR(6),CHAR(4);

DEFINE SQL_ERR   	  			INTEGER;
DEFINE ISAM_ERR   	 			INTEGER;
DEFINE vcodret 					CHAR(6);
DEFINE vcentro_costos        	CHAR(4);


LET vcodret='';
LET vcentro_costos = '';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR
      LET vcodret    = SQL_ERR;
      
      RETURN vcodret,vcentro_costos;
   END EXCEPTION;
 

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT SKIP pRegistros FIRST pRecuperacion DISTINCT sucursal 
	INTO vcentro_costos
	FROM bdisuc:"informix".ss_operaciones WHERE 
	cod_trans in ('0001','0010','0036')
	--and fecha_operacion = today
	ORDER BY sucursal

	RETURN vcodret,vcentro_costos WITH RESUME;
END FOREACH;
	
end;						
END PROCEDURE
DOCUMENT 'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 11/04/2018',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: Monitor de Efectivo en Línea Bancoppel',
'DESCRIPCION: SP clon que consulta el centro de costos por Dotaciones del Monitor de Efectivo en Línea Bancoppel',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_tipo_operacion_etv()

RETURNING CHAR(5),CHAR(20);

DEFINE SQL_ERR INTEGER;
DEFINE ISAM_ERR INTEGER;
DEFINE ERROR_INFO VARCHAR(80);
DEFINE cod_ret CHAR(5);
DEFINE vtipo_operacion CHAR(20);


LET cod_ret = '00000';
LET vtipo_operacion = '';


BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET cod_ret = SQL_ERR; 
		
        RETURN cod_ret,vtipo_operacion;
    END EXCEPTION;

    set isolation to dirty read;
	
	--SET debug file to "/informix/1170/calizarraga/sp_tipo_operacion_etv.out";
	--trace on;

    FOREACH
        SELECT tipo_operacion
        INTO vtipo_operacion
        FROM bdisuc:"informix".ss_cat_tipo_operacion_etv
        ORDER BY tipo_operacion

        RETURN cod_ret,vtipo_operacion WITH resume;
    END FOREACH;
END;

END PROCEDURE;