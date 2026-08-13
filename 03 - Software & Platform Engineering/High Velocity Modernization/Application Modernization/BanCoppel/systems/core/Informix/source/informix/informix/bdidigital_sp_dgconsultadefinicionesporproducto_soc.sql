CREATE PROCEDURE "informix".sp_dgconsultadefinicionesporproducto_soc(pEmpresa CHAR(3),pCodSistema CHAR(2),pCodProducto CHAR(4))
	RETURNING CHAR(6),CHAR(3),CHAR(50);

	--DECLARACION DE VARIABLES	    
		DEFINE cEmpresa		CHAR(3);
		DEFINE iSqlErr      INTEGER;
		DEFINE cCodRet      CHAR(6);
		DEFINE cCodSistema  CHAR(2);
		DEFINE cCodProducto CHAR(4);
		DEFINE cCodDefinicion CHAR(3);
		DEFINE cProdNombre  CHAR(50);	
		
	--CREA EL ARCHIVO DE MONITOREO DEL PROCESO
	--SET DEBUG FILE TO "/tmp/sp_DgConsultaDefinicionesPorProducto.out";
	--TRACE ON;

	--INICIALIZACION DE  VARIABLES
		LET cEmpresa= '';
		LET cCodRet= '000000';
	    LET cCodSistema= '';
		LET cCodProducto= '';
		LET cCodDefinicion= '';
        LET cProdNombre= '';
		
	BEGIN
	--CREA EL CONTROL DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr != 0 THEN
				LET cCodRet= iSqlErr;
				RETURN cCodRet,cCodDefinicion,cProdNombre;
			END IF;
		END EXCEPTION;
        
        set isolation to dirty read;
        set lock mode to wait 3;

        IF pEmpresa = '' THEN
            LET cCodRet = '000001'; -- PARAMETRO EMPRESA VACIO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;

        IF pCodSistema = ''  THEN
            LET cCodRet = '000002'; -- PARAMETRO CODIGO SISTEMA ESTA VACIO 
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;
		
		IF pCodProducto = ''  THEN
            LET cCodRet = '000003'; -- PARAMETRO CODIGO PRODUCTO ESTA VACIO 
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;
							       	
		IF LENGTH(pCodSistema) <> 2 THEN
            LET cCodRet = '000004'; -- PARAMETRO CODIGO SISTEMA NO VALIDO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;

        IF LENGTH(pCodProducto) <> 4 THEN
            LET cCodRet = '000005'; -- PARAMETRO CODIGO PRODUCTO NO VALIDO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;				
	    					
		SELECT empresa
		INTO cEmpresa
		FROM BDINTEG:si_empresas
		WHERE empresa = pEmpresa;
        IF cEmpresa IS NULL OR cEmpresa = '' THEN
            LET cCodRet = '000006'; -- EMPRESA NO EXISTE EN CATALOGO
            RETURN cCodRet,cCodDefinicion,cProdNombre;
        END IF;  
						 
		--CONSULTA PARAMETROS DIGITALIZACION
		
		SELECT FIRST 1 cod_definicion,prod_nombre
		INSERT INTO cCodDefinicion,cProdNombre
		FROM BDIDIGITAL@COPPELIMG_TCP:dg_definicion 
		WHERE empresa = pEmpresa
		AND cod_sistema = pCodSistema 
        AND cod_producto = pCodProducto; 

		IF cCodDefinicion='' OR cCodDefinicion IS NULL THEN
		LET cCodRet = '000007';		END IF;			  
		
		RETURN cCodRet,cCodDefinicion,cProdNombre;
		
	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Genera una consulta en las tabla dg_definicion',
'tomando como parametro o dato de entrada, la Empresa,el Codigo de Sistema,el Codigo de Producto',
'para obtener los Parametros necesarios para ejecutar la aplicacion',
'AUTOR: Guadalupe Payan',
'FECHA: Octubre 2010',
'VERSION: 201027',
'BD: BDIDIGITAL';

create procedure "informix".consnomcte(pempresa char(3),pnumcte char(20))
       returning char(5),char(60),char(13),char(20);

define vcodret char(5);
define vesfisica char(1);
define vpaterno char(15);
define vmaterno char(15);
define vnombre1 char(15);
define vnombre2 char(15);
define vrazon_social char(60);
define vnomcte char(60);
define vsqlerr integer;
define vtpo_persona char(2);
define vrfc char(13);
define vcurp char(20);

let vnomcte = " ";
let vcodret = "000";
let vrfc = " ";
let vcurp = " ";

set lock mode  to wait 3;
set  isolation to dirty read;
begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         RETURN vcodret, vnomcte, vrfc, vcurp;
      end if
   end exception;

   SELECT tpo_persona,nvl(apell_paterno," "),nvl(apell_materno," "),
          nvl(nombre1," "),nvl(nombre2," "),nvl(razon_social," "),
          rfc
      into vtpo_persona,vpaterno,vmaterno,vnombre1,vnombre2,vrazon_social,vrfc
      FROM bdinteg:si_cliente
      WHERE empresa = pempresa and numcte = pnumcte;

   if vtpo_persona = " " or vtpo_persona is null then
      let vcodret = "800";
      RETURN vcodret, vnomcte, vrfc, vcurp;
   else
      select es_fisica into vesfisica from bdinteg:si_tipper
         where tpo_persona = vtpo_persona;
      if vesfisica <> "S" then
         let vnomcte = trim(vrazon_social);
      else
         let vnomcte = trim(vnombre1)||" "||trim(vnombre2)||" "||
                       trim(vpaterno)||" "||trim(vmaterno);
      end if;
   end if

   IF vesfisica="S" then
   	SELECT nvl(curp," ")
   	INTO vcurp
      	FROM bdinteg:si_ctepf
      	WHERE empresa = pempresa and numcte = pnumcte;
   END IF

   RETURN vcodret, vnomcte, vrfc, vcurp;

end
end procedure;