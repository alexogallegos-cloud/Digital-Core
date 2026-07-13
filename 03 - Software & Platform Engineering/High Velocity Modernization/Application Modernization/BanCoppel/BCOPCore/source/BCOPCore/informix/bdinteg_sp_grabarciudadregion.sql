CREATE PROCEDURE "informix".sp_grabarciudadregion (pIdCiudad SMALLINT, pIdRegion SMALLINT, pTipo SMALLINT)
    RETURNING CHAR(6), CHAR(80);

    --pIdCiudad : Id de Ciudad
    --pIdRegion : Id de region.
    -- pTipo: Accion a realizarse: 0 - Actualizar region de ciudad indicada a 0, 1 - Asignar region indicada a la ciudad recibida..
    --Autor: René Chiquete Elizalde
    --11-01-2010
    --Asigna o desasigna regiones a ciudades.

    DEFINE sCodRet CHAR(6);			--CODIGO DE RETORNO PERSONALIZADO
    DEFINE iCodRet INTEGER ;			--CODIGO DE RETORNO INTERNO
    DEFINE sErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE cErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE iIsamErr smallint;                       --VARIABLE PARA CACHAR EL CODIGO DE ERROR
    DEFINE vContador smallint;
    DEFINE vIdCiudad smallint;
    DEFINE vIdRegion smallint;

    LET sCodRet = "000";
    LET cErrorInfo="CIUDAD ASIGNADA A REGION CON EXITO";
    LET sErrorInfo="";
    LET	iCodRet=0;
    LET vContador  = 0;
    LET vIdCiudad = 0;
    LET vIdRegion = 0;
--SET DEBUG FILE TO '/tmp/Rene/PRUEBA.out';
   -- TRACE ON;

    BEGIN
        ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
            LET sCodRet = iCodRet;
                    LET cErrorInfo = sErrorInfo;
            RETURN sCodRet, cErrorInfo;

        END Exception;

            --VALIDAMOS DATOS DE ENTRADA
            --Validamos la ciudad
            IF nvl(pIdCiudad,0)='' then
                    LET sCodRet='001';
                    LET cErrorInfo='CIUDAD NO VALIDA';
                    RETURN sCodRet, cErrorInfo;
            --Validamos la region
            ELIF nvl(pIdRegion,0)='' then
                    LET sCodRet='001';
                    LET cErrorInfo='REGION NO VALIDA';
                    RETURN sCodRet, cErrorInfo;
           --Validamos el tipo
           ELIF NOT( (nvl(pTipo,'')<>'') AND (pTipo = 0 OR pTipo = 1) ) then
                    LET sCodRet='001';
                    LET cErrorInfo='TIPO NO VALIDO';
                    RETURN sCodRet, cErrorInfo;
            ELSE
                    --Se verifica si la ciudad recibida existe en el catalogo.
                   
                            SELECT LIMIT 1{ + INDEX (si_catciudades numerociudad)}  numerociudad,numero_region
                            INTO vIdCiudad , vIdRegion
                            FROM bdinteg:si_catciudades 
                            WHERE numerociudad = pIdCiudad;
                          

                            IF (nvl(vIdCiudad,'') <> '') THEN
                                   --Se verifica si la region recibida existe en el catalogo.
                                    SELECT  count(*)
                                    INTO vContador 
                                    FROM bdinteg:si_regiones
                                    WHERE numero_region = pIdRegion;

                                    IF (vContador <> 0) THEN
                                            IF (pTipo = 0) THEN
                                                     --Se verifica si la region recibida como parametro es la misma que la que tiene actualmente la ciudad
                                                     IF (nvl(vIdRegion,0) <> pIdRegion) THEN
                                                            LET sCodRet='001';
                                                            LET cErrorInfo='REGION INDICADA NO COINCIDE CON REGION ASIGNADA';
                                                            RETURN sCodRet, cErrorInfo;
                                                    END IF;

                                                    update si_catciudades set numero_region = 0 where numerociudad = pIdCiudad; 

                                            ELIF (pTipo = 1) THEN
                                                    update si_catciudades set numero_region = pIdRegion where numerociudad = pIdCiudad; 
                                            END IF;
                                    ELSE
                                            LET sCodRet='001';
                                            LET cErrorInfo='REGION NO VALIDA';
                                            RETURN sCodRet, cErrorInfo;
                                    END IF;
                            ELSE
                                    LET sCodRet='001';
                                    LET cErrorInfo='CIUDAD NO VALIDA';
                                    RETURN sCodRet, cErrorInfo;
                            END IF;   
           
            END IF;
            RETURN sCodRet, cErrorInfo;
    END ;
    END PROCEDURE ;