CREATE PROCEDURE "informix".sp_consultaproductos(pEmpresa CHAR(3), pTipo CHAR(1), pPlaza CHAR(3))

RETURNING CHAR(5), -- Código de retorno 
		  CHAR(4), --Código de Producto
          CHAR(60),-- Descripción del producto 
		  CHAR(2); --Sistema

-- Declaración de variables
DEFINE cCodRet					CHAR(5);
DEFINE iSqlErr          		INTEGER;
DEFINE cProducto			    CHAR(60);
DEFINE cDescripcionProducto     CHAR(60);
DEFINE cSistema					CHAR(2);

-- Asignación variables
LET cCodRet        			= "00000";
LET iSqlErr          		= 0;
LET cProducto             	= "";
LET cDescripcionProducto	= "";
LET cSistema 				= "";

BEGIN

	ON EXCEPTION SET iSqlErr
		LET cCodRet = iSqlErr;
		RETURN cCodRet, cProducto, cDescripcionProducto, cSistema;
	END EXCEPTION;
   
	---SET DEBUG FILE TO "/tmp/sp_consultaproductos.out";
	---TRACE ON;
	
	IF pTipo = "1" THEN --Consulta por Region
		IF pPlaza IS NOT NULL OR pPlaza <> '' THEN
			FOREACH
				SELECT DISTINCT(Prod.producto), Prod.nombre, tram.sistema
				INTO cProducto, cDescripcionProducto, cSistema
				FROM bdicheq:sc_producto Prod, bdisolic:ss_tramite_productos_clasif tram,
				     bdinteg:si_sucursales sc, bdinteg:si_plazas sp
				WHERE Prod.empresa = pEmpresa
				AND Prod.empresa = tram.empresa
				AND Prod.producto = tram.prod_ofrecer
				AND sc.plaza=sp.plaza
				AND sc.plaza= pPlaza
				AND sc.tpo_sucursal='S'
				UNION
				SELECT DISTINCT(Def.num_producto), Def.nombre_prod, tram.sistema
				FROM bdicred:sd_definicion Def, bdisolic:ss_tramite_productos_clasif tram,
				     bdinteg:si_sucursales sc, bdinteg:si_plazas sp
				WHERE Def.empresa = pEmpresa
				AND Def.empresa = tram.empresa
				AND Def.num_producto = tram.prod_ofrecer
				AND sc.plaza=sp.plaza
				AND sc.plaza= pPlaza
				AND sc.tpo_sucursal='S'
				UNION
				SELECT DISTINCT(inst.cod_instrum), inst.nombre, tram.sistema 
				FROM bdinvers:sv_instrum inst, bdisolic:ss_tramite_productos_clasif tram,
				     bdinteg:si_sucursales sc, bdinteg:si_plazas sp
				WHERE inst.empresa = pEmpresa
				AND inst.empresa = tram.empresa
				AND inst.cod_instrum = tram.prod_ofrecer
				AND sc.plaza=sp.plaza
				AND sc.plaza= pPlaza
				AND sc.tpo_sucursal='S'

				RETURN cCodRet, cProducto, cDescripcionProducto, cSistema WITH resume;
			END FOREACH;
		ELSE
			LET cCodRet = '00001';
		END IF;
	
	ELIF pTipo = "2" THEN --Consulta por Sucursal
		FOREACH
			SELECT DISTINCT(Prod.producto), Prod.nombre, tram.sistema
			INTO cProducto, cDescripcionProducto, cSistema
			FROM bdicheq:sc_producto Prod, bdisolic:ss_tramite_productos_clasif tram
			WHERE Prod.empresa = pEmpresa
			AND Prod.empresa = tram.empresa
			AND Prod.producto = tram.prod_ofrecer
			UNION
			SELECT DISTINCT(Def.num_producto), Def.nombre_prod, tram.sistema
			FROM bdicred:sd_definicion Def, bdisolic:ss_tramite_productos_clasif tram
			WHERE Def.empresa = pEmpresa
			AND Def.empresa = tram.empresa
			AND Def.num_producto = tram.prod_ofrecer
			UNION
			SELECT DISTINCT(inst.cod_instrum), inst.nombre, tram.sistema 
			FROM bdinvers:sv_instrum inst, bdisolic:ss_tramite_productos_clasif tram
			WHERE inst.empresa = pEmpresa
			AND inst.empresa = tram.empresa
			AND inst.cod_instrum = tram.prod_ofrecer
			
			RETURN cCodRet, cProducto, cDescripcionProducto, cSistema WITH resume;
		END FOREACH;
	END IF;

   IF cCodRet <> '00000' THEN
       RETURN cCodRet, cProducto, cDescripcionProducto, cSistema;
   END IF;
   
END;
END PROCEDURE;