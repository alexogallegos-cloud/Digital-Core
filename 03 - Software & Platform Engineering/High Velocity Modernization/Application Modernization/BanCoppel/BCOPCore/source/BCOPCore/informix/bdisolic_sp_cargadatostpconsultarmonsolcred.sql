CREATE PROCEDURE "informix".sp_cargadatostpconsultarmonsolcred(pEmpresa CHAR(3),pOpcion CHAR(2))
RETURNING
          CHAR(6)         AS cod_ret,
          VARCHAR(80,1)   AS mensaje_ret,
          VARCHAR(4)      AS cod_elemento,
          VARCHAR(250,1)  AS descripcion;

-- * Opciones para la ejecuciÃ³n del procedimiento: 
--      01 - Estado
--      02 - Ciudad
--      03 - RegiÃ³n Cobranza
--      04 - Sucursal
--      05 - Tipo producto
--	     06 - Canal

DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE cCodRet         CHAR(6);
DEFINE cMensajeRet     VARCHAR(80,1);
DEFINE cIdConsulta     VARCHAR(20,1); 
DEFINE cDescripcion    VARCHAR(200,1);
DEFINE cOpcion         CHAR(2);
DEFINE iRegistros      INTEGER;
DEFINE cEstado         CHAR(2);
DEFINE cCiudad         CHAR(3);
DEFINE iRegion         INTEGER;
DEFINE cSucursal       CHAR(4);
DEFINE cNumCd          INTEGER;
DEFINE cNumCol         INTEGER;
DEFINE cElemento       VARCHAR(4);

LET iSqlErr            = 0;
LET iIsamErr           = 0;
LET cErrorInfo         = '';
LET cCodRet            = '000000';
LET cMensajeRet        = 'Se ejecutÃ³ la consulta correctamente';
LET cIdConsulta        = '';
LET cDescripcion       = '';
LET cOpcion            = '';
LET iRegistros         = 0;
LET cEstado            = '';
LET cCiudad            = '';
LET iRegion            = 0;
LET cSucursal          = '';
LET cNumCd             = 0;
LET cNumCol            = 0;
LET cElemento          = "";
     
BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
    RETURN cCodRet, cMensajeRet,cElemento,cDescripcion;
   END IF;
END EXCEPTION;

 --SET DEBUG FILE TO "/tmp/sp_filtro_consultas";
 --TRACE ON;

IF NVL(pEmpresa,'') = '' THEN
   LET cCodRet     = '000001';
   LET cMensajeRet = 'Es necesario indicar la empresa para ejecutar el proceso';

    RETURN cCodRet, cMensajeRet,cElemento,cDescripcion;
END IF;

IF NVL(pOpcion,'') = '' THEN
   LET cCodRet     = '000002';
   LET cMensajeRet = 'Es necesario indicar una opciÃ³n para ejecutar el proceso';

    RETURN cCodRet, cMensajeRet,cElemento,cDescripcion;
END IF;


LET cOpcion = TRIM(pOpcion);
IF cOpcion NOT IN ('01','02','03','04', '05','06') THEN
   LET cCodRet     = '000004';
   LET cMensajeRet = 'La opciÃ³n de consulta indicada no es valida';

    RETURN cCodRet, cMensajeRet,cElemento,cDescripcion;
END IF;

IF pOpcion = "01" THEN
       FOREACH WITH HOLD
            SELECT estado, nombre 
              INTO cElemento,cDescripcion              
              FROM bdinteg:"informix".si_estados
             ORDER BY estado

          RETURN cCodRet, cMensajeRet,cElemento,cDescripcion WITH RESUME;

       END FOREACH;
ELIF pOpcion = "02" THEN
      FOREACH WITH HOLD
            SELECT a.estado, a.ciudad, trim(a.nombre)||' ('|| trim(b.nombre) ||' ' ||trim(a.estado) ||')'
              INTO cEstado, cElemento, cDescripcion              
              FROM bdinteg:"informix".si_ciudades a,
                   bdinteg:"informix".si_estados b
             WHERE a.pais = b.pais
                and a.estado = b.estado
                and a.ciudad = a.ciudad
             ORDER BY a.nombre --ciudad  

            RETURN cCodRet, cMensajeRet,cElemento,cDescripcion WITH RESUME;
       END FOREACH;
ELIF pOpcion = "03" THEN
      FOREACH WITH HOLD
            SELECT numero_region, nombre_region
              INTO cElemento, cDescripcion
              FROM bdinteg:"informix".si_regiones
             ORDER BY numero_region
 
            RETURN cCodRet, cMensajeRet,cElemento,cDescripcion WITH RESUME;           
       END FOREACH;
ELIF pOpcion = "04" THEN
      FOREACH WITH HOLD
            SELECT sucursal, nombre
              INTO cElemento, cDescripcion              
              FROM bdinteg:"informix".si_sucursales
             WHERE pais  = pais
               AND estado = estado
               and ciudad = ciudad
               AND tpo_sucursal = 'S' 
          ORDER BY sucursal

            RETURN cCodRet, cMensajeRet,cElemento,cDescripcion WITH RESUME;
       END FOREACH;
ELIF pOpcion = "05" THEN
      FOREACH WITH HOLD
      		SELECT abrevia_prod, descrip_prod
      		INTO cElemento, cDescripcion
      		FROM bdicred:"informix".sd_tipprod
      		ORDER BY abrevia_prod

            RETURN cCodRet, cMensajeRet,cElemento,cDescripcion WITH RESUME;
       END FOREACH;
ELIF pOpcion = "06" THEN
      FOREACH WITH HOLD
      		SELECT canal_solic, Case when canal_solic = 1 THEN 'Sucursal' WHEN canal_solic = 2 THEN 'Alta movil' ELSE 'Sitio Web' END  AS descrip_prod
      		INTO cElemento, cDescripcion
      		FROM bdisolic:"informix".ss_canales_solic
			WHERE canal_solic IN(1,2,4)
      		ORDER BY canal_solic

            RETURN cCodRet, cMensajeRet,cElemento,cDescripcion WITH RESUME;
       END FOREACH;	   
END IF;

END
END PROCEDURE
