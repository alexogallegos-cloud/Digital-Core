CREATE PROCEDURE "informix".sp_ejecuta_catbcpplcppl(p_proceso smallint, pcatalogo CHAR(1), pfecha Date,
                                                             pseparador CHAR(1), pejecucion CHAR(1), pnomarch CHAR(30))
       RETURNING char(6), char(80);
      

DEFINE vCodRet              CHAR(5);
DEFINE vMensaje             CHAR(80);
DEFINE SQL_ERR              INTEGER;
DEFINE ISAM_ERR             INTEGER;
DEFINE ERROR_INFO           VARCHAR(80);
DEFINE vvCodRet             char(5);
DEFINE vvMensaje            char(80);
DEFINE vv_codret            char(5);
DEFINE vv_mensaje           char(80);
DEFINE v_fch_inic           DATE;
DEFINE v_fch_fin            DATE;

    --SET DEBUG FILE TO "/tmp/sp_ejecuta_monitor.out";
    --TRACE ON; 

    LET vCodRet             =   "11111";
    LET vMensaje            =   "PROCESO INICIALIZADO";
  
BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET vCodRet  = SQL_ERR;
        LET vMensaje  = ERROR_INFO;        
        RETURN vCodRet, vMensaje;
    END EXCEPTION;
  
    IF (p_proceso = 1) THEN
       
        CALL bdinteg:SP_ConciliarCatalogoCalles()
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 2) THEN

        CALL bdinteg:SP_ConciliarCatalogoCiudades()
        RETURNING vvCodRet, vvMensaje;
        
    ELIF (p_proceso = 3) THEN

        CALL bdinteg:sp_conciliarcatalogozonas()
        RETURNING vvCodRet, vvMensaje;
       
    ELIF (p_proceso = 4) THEN
    
        CALL bdinteg:sp_ExportarCatalogoCalles(pCatalogo, pFecha, pSeparador , pEjecucion)
        RETURNING vvCodRet, vvMensaje;
        
    ELIF (p_proceso = 5) THEN

        CALL bdinteg:sp_ExportarCatalogoCiudades(pCatalogo, pFecha, pSeparador , pEjecucion)
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 6) THEN

        CALL bdinteg:sp_ExportarCatalogoZonas(pCatalogo, pFecha, pSeparador, pEjecucion)
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 7) THEN

        CALL bdinteg:SP_ImportarCatalogoCalles(pSeparador, pNomArch, pEjecucion )
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 8) THEN

        CALL bdinteg:SP_ImportarCatalogoCiudades(pSeparador, pNomArch, pEjecucion )
        RETURNING vvCodRet, vvMensaje;

    ELIF (p_proceso = 9) THEN

        CALL bdinteg:SP_ImportarCatalogoZonas(pSeparador, pNomArch, pEjecucion )
        RETURNING vvCodRet, vvMensaje;

    END IF

    LET vCodRet = '00000';
    LET vMensaje = 'PROCESO EXITOSO';

END

RETURN vCodRet, vMensaje;

END PROCEDURE;