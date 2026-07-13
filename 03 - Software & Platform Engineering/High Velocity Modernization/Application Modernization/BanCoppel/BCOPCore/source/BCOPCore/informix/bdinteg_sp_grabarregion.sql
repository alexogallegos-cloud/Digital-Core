CREATE PROCEDURE "informix".sp_grabarregion (pIdRegion SMALLINT, pNombreRegion CHAR(30), pUsuario CHAR(9))
    RETURNING CHAR(6), CHAR(80);

    --pIdRegion : Id de la nueva región.
    --pNombreRegion : Nombre de la nueva región.
    --Autor: René Chiquete Elizalde
    --11-01-2010
    --Da de alta una nueva región.

    DEFINE sCodRet CHAR(6);			--CODIGO DE RETORNO PERSONALIZADO
    DEFINE iCodRet INTEGER ;			--CODIGO DE RETORNO INTERNO
    DEFINE sErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE cErrorInfo CHAR(80);			--MENSAJE DE CODIGO DE RETORNO
    DEFINE iIsamErr smallint;                       --VARIABLE PARA CACHAR EL CODIGO DE ERROR
    DEFINE vContador smallint;
    DEFINE vIdRegion smallint;
    DEFINE vNombreRegion CHAR(30);
    DEFINE vFechaActual DATE;

    LET sCodRet = "000";
    LET cErrorInfo="REGION AGREGADA EXITOSAMENTE";
    LET sErrorInfo="";
    LET	iCodRet=0;
    LET vContador  = 0;
    LET vIdRegion = 0;

--SET DEBUG FILE TO '/tmp/Rene/PRUEBA.out';
   --TRACE ON;

    BEGIN
        ON EXCEPTION SET iCodRet, iIsamErr, sErrorInfo
            LET sCodRet = iCodRet;
            LET cErrorInfo = sErrorInfo;
            RETURN sCodRet, cErrorInfo;
        END Exception;
        --Se valida el numero de region
        IF nvl(pIdRegion,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='NUMERO DE REGION NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;
        --Se valida el nombre de region
        IF nvl(pNombreRegion,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='NOMBRE DE REGION NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;

        --Se valida que el número de región recibida no se encuentre dada de alta
        SELECT numero_region
       INTO vIdRegion
        FROM bdinteg:si_regiones
        WHERE numero_region = pIdRegion;
       --Si la consulta regresa algo, quiere decir que la region ya existe.
        IF nvl(vIdRegion,'') <> '' THEN
                LET sCodRet='001';
                LET cErrorInfo='EL NUMERO DE REGION YA EXISTE';
                RETURN sCodRet, cErrorInfo;
        END IF;

        --Se valida el usuario
        IF nvl(pUsuario,'') = '' THEN
                LET sCodRet='001';
                LET cErrorInfo='USUARIO NO VALIDO';
                RETURN sCodRet, cErrorInfo;
        END IF;


         --Se valida que el nombre de región recibida no se encuentre dada de alta
        SELECT nombre_region
        INTO vNombreRegion
        FROM bdinteg:si_regiones
        WHERE TRIM(nombre_region) = Trim(pNombreRegion);
       --Si la consulta regresa algo, quiere decir que el nombre de region ya existe.
        IF nvl(vNombreRegion,'') <> '' THEN
                LET sCodRet='001';
                LET cErrorInfo='EL NOMBRE DE REGION YA EXISTE';
                RETURN sCodRet, cErrorInfo;
        END IF;

        INSERT INTO si_regiones (numero_region,nombre_region,fecha_alta,fecha_mod,usuario_alta, usuario_mod)
        VALUES(pIdRegion,TRIM(pNombreRegion),(SELECT fecha_hoy from si_fechas), (SELECT fecha_hoy from si_fechas),pUsuario, pUsuario ) ;

        RETURN sCodRet, cErrorInfo;

    END ;
    END PROCEDURE ;