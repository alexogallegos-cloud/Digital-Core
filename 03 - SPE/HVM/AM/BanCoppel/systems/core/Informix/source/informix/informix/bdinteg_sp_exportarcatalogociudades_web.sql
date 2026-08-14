CREATE PROCEDURE "informix".sp_exportarcatalogociudades_web(pCatalogo CHAR(1),  pFechaAct DATE, pSeparador CHAR(1),pEjecucion CHAR(1))
RETURNING  CHAR(6), CHAR(80);
    
--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err 			                INTEGER;
DEFINE isam_err 		                INTEGER;
DEFINE error_info		                CHAR(80);
DEFINE cCod_ret                         CHAR(6);
DEFINE cMensaje                         CHAR(80);
DEFINE cCadena                          CHAR (1000);
DEFINE vFechaArch                       DATE;
DEFINE vNomArch                         CHAR(50);
DEFINE vNomArchAux                      CHAR(50);
DEFINE vPath                            CHAR(50);
------------------------------------------------------------

-- Creado: Josï¿½ de Jesï¿½s Almeida Inzunza
-- Fecha: 19 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de obtener el total o una parcialidad de las ciudades del catalogo

-- Modificado por: MACF
-- Fecha: 07/06/2010
-- Agregar parï¿½metro pEjecucion para determinar si es Autmï¿½tica o Manual

LET cCod_ret      = '00000';
LET sql_err       = 0;
LET cMensaje      = '';
LET cCadena       = '';
LET vNomArch      = 'si_catciudades_web';
LET vNomArchAux   = 'si_catciudades_web_Aux';
LET vPath         = '';

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
	        LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			RETURN cCod_ret, cMensaje;
	    END EXCEPTION;

--SET DEBUG FILE TO "/informix/vic/sp_ExportarCatalogoCiudadesWeb.out";
--TRACE ON;

    SELECT fecha_hoy
    INTO   vFechaArch
    FROM   bdinteg:si_fechas
    WHERE empresa = '001';
    
   -- LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';
    
    if pEjecucion = 'A' then
           select trim(valor) into vPath 
          from bdinteg:si_param_dom 
          where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    else
        select trim(valor) || '/tmp/' into vPath 
        from bdinteg:si_param_dom 
        where cod_param = 24; ---CAMBIAR PARAMETRO A NUMERO CORRECTO EN PRODUCCION
    end if;
    LET vPath = TRIM(vPath);

    LET vNomArchAux = TRIM(vNomArchAux) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArchAux = TRIM(vNomArchAux);
    LET vNomArch = TRIM(vNomArch) || TO_CHAR(vFechaArch,'%Y%m%d') || '.txt';    
    LET vNomArch = TRIM(vNomArch);    

IF (pCatalogo = 1) THEN
    
        LET cCadena = 'echo "unload to ' ||trim(vPath) || trim(vNomArchAux) || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, upper(limpia_cadenaweb(nombreciudad)), '
                  || 'case when nvl(inicialciudad,''' || ''') <> ''' || ''' then upper(limpia_cadenaweb(inicialciudad)) else inicialciudad end,'
                  || 'tasainteres, numeroestado, inicialestado, salariominimo, gerentezona, regioncobranzas, '
                  || 'ivaciudad, TO_CHAR(antiguedadciudad,'|| '''%Y%m%d'')' || ', unificaciudadesinformes, unificaciudadescobranzas, gerentecobranzas, '
                  || 'generajobcarteratienda, inicialcredito, regionestadodecuenta, tasainteresropa, tasainteresmueble12, '
                  || 'tasainteresmueble18, tasainteresprestamo, tasainterescelular1, tasainterescelular2, tipozona, TO_CHAR(fechaultimaactualizacion,'|| '''%Y-%m-%d'')' || ''                  
                  || 'FROM BDINTEG:si_catciudades a '
                  --|| ', BDINTEG:si_ciudades b where a.numerociudad = b.ciudad_coppel ' 
                  --|| 'and b.ciudad_coppel > 0 and b.elegir is null ' VALIDACION SEPOMEX                  
                  || '" >' ||trim(vPath) || 'corre_si_catciudades_web.sql';  
                  
        System TRIM(cCadena);
        let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catciudades_web.sql';
        System TRIM(cCadena);

        LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
        SYSTEM cCadena;
        
        let cCadena = 'rm ' || trim(vPath) || 'corre_si_catciudades_web.sql';
        System cCadena;

        let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
        System cCadena; 
    
ELIF (pCatalogo = 0) THEN

        LET cCadena = 'echo "unload to ' ||trim(vPath) || trim(vNomArchAux) || ' DELIMITER ''' || pSeparador || ''' SELECT numerociudad, upper(limpia_cadenaweb(nombreciudad)), '
                  || 'case when nvl(inicialciudad,''' || ''') <> ''' || ''' then upper(limpia_cadenaweb(inicialciudad)) else inicialciudad end,'
                  || 'tasainteres, numeroestado, inicialestado, salariominimo, gerentezona, regioncobranzas, '
                  || 'ivaciudad, TO_CHAR(antiguedadciudad,'|| '''%Y/%m/%d'')' || ', unificaciudadesinformes, unificaciudadescobranzas, gerentecobranzas, '
                  || 'generajobcarteratienda, inicialcredito, regionestadodecuenta, tasainteresropa, tasainteresmueble12, '
                  || 'tasainteresmueble18, tasainteresprestamo, tasainterescelular1, tasainterescelular2, tipozona, TO_CHAR(fechaultimaactualizacion,'|| '''%Y-%m-%d'')' || ''                  
                  || 'FROM BDINTEG:si_catciudades a '
                  --|| ', BDINTEG:si_ciudades b where a.numerociudad = b.ciudad_coppel ' 
                  -- || 'and b.ciudad_coppel > 0 and b.elegir is null ' VALIDACION SEPOMEX
                  || '  where  f_inserta >= ''' || pFechaAct || ''''
                  || '" >' ||trim(vPath) || 'corre_si_catciudades_web.sql';                         

                  
        System TRIM(cCadena);
        let cCadena = 'dbaccess bdinteg ' || trim(vPath) || 'corre_si_catciudades_web.sql';
        System TRIM(cCadena);

        LET cCadena = "sed 's/"||pSeparador ||"$//g' "|| trim(vPath) || trim(vNomArchAux) || " >> " ||  trim(vPath) || trim(vNomArch);
        SYSTEM cCadena;
        
        let cCadena = 'rm ' || trim(vPath) || 'corre_si_catciudades_web.sql';
        System cCadena;

        let cCadena = 'rm ' || trim(vPath) || trim(vNomArchAux );
        System cCadena;
     
     
     
ELSE

    LET cCod_ret = '00001';
    LET cMensaje = 'Parï¿½metro de Catï¿½logo Invalido';    
    RETURN cCod_ret, cMensaje;
   
END IF;    

LET cMensaje = TRIM(vNomArch);
RETURN cCod_ret, cMensaje;

END;
END PROCEDURE
DOCUMENT
'MODIFICACION: Victor D. Vazquez',
'FECHA: 2023/04/04',
'DESCRIPCION: Se modifica para agregar la depuraciï¿½n de caracteres especiales en algunos campos en SIWEB',
'BD: bdinteg',
'VERSION:20230404.100';

CREATE PROCEDURE "informix".sp_consulta_telefonos_pru1( pEmpresa  CHAR(3),
                                                   pNumCte   CHAR(20),
                                                   pTipoTel  SMALLINT,
                                                   pConsulta CHAR(1) )
RETURNING CHAR(5)  AS vcodret1,
          CHAR(13) AS vTelefono,
          SMALLINT AS vTipoTel,
          SMALLINT AS vSecuencia,
          CHAR(1)  AS vStatus_Tel,
          CHAR(5)  AS vExtension,
          SMALLINT AS vCarrier,
          CHAR(20) AS vNombreCarrier,
          SMALLINT AS StatusValidacion;

    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);

    DEFINE vExisteCte       INTEGER;
    DEFINE vTelefono        CHAR(13);
    DEFINE vTipoTel         SMALLINT;
    DEFINE vStatus_Tel      CHAR(1);
    DEFINE vExtension       CHAR(5);
    DEFINE vCarrier         SMALLINT;
    DEFINE vContacto        SMALLINT;
    DEFINE vNombreCarrier   CHAR(30);
    DEFINE StatusValidacion SMALLINT;
    DEFINE vSecuencia       SMALLINT;
    DEFINE vCofetel         CHAR(1);

    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    LET vExisteCte       = 0;
    LET vTelefono        = '';
    LET vTipoTel         = 0;
    LET vStatus_Tel      = '';
    LET vExtension       = '';
    LET vCarrier         = 0;
    LET vContacto        = 0;
    LET vNombreCarrier   = '';
    LET StatusValidacion = 0;
    LET vSecuencia       = 0;
    LET vCofetel         = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_telefonos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_consulta_telefonos.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pTipoTel is null OR pTipoTel = 0) THEN
        LET vcodret1 = '110'; --- DATOS INSUFICIENTES
        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    END IF;

    -- // VALIDA EXISTA NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte;

    IF vExisteCte = 0 THEN
        LET vcodret1 = '104'; --- NO DE CLIENTE NO EXISTE
        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    END IF;

    -- // OBTIENE INFORMACION DE ACUERDO AL TIPO DE CONSULTA
    IF pConsulta = '0' THEN
        -- // -- TELEFONO MAS RECIENTE DEL TIPO ESPECIFICADO
        SELECT telefono, tipo_tel, secuencia, status_tel, extension, carrier, contacto, cofetel
          INTO vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vContacto, vCofetel
          FROM bdinteg:"informix".si_telefonos_actual
         WHERE numcte = pNumCte
           AND tipo_tel = pTipoTel
           AND status_tel = 'A';

        SELECT NVL(nombre_carrier, ' ')
          INTO vNombreCarrier
          FROM bdinteg:"informix".si_carriers
         WHERE cve_carrier = vCarrier;

        IF vNombreCarrier is null THEN
            LET vNombreCarrier = '';
        END IF;
        
        IF vCofetel = 'V' THEN
            LET StatusValidacion = 1;
        ELSE
            LET StatusValidacion = 0;
        END IF;

        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    ELIF pConsulta = '1' THEN
        -- // TODOS LOS TELEFONOS DEL TIPO ESPECIFICADO
        FOREACH
            SELECT telefono, tipo_tel, secuencia, status_tel, extension, carrier, contacto, cofetel
              INTO vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vContacto, vCofetel
              FROM bdinteg:"informix".si_telefonos
             WHERE numcte = pNumCte
               AND tipo_tel = pTipoTel
             ORDER BY secuencia DESC

            SELECT NVL(nombre_carrier, ' ')
              INTO vNombreCarrier
              FROM bdinteg:"informix".si_carriers
             WHERE cve_carrier = vCarrier;

            IF vNombreCarrier is null THEN
                LET vNombreCarrier = '';
            END IF;
            
            IF vCofetel = 'V' THEN
                LET StatusValidacion = 1;
            ELSE
                LET StatusValidacion = 0;
            END IF;

            RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion WITH RESUME;
        END FOREACH;
    ELIF pConsulta = '2' THEN
        -- // TODOS LOS TELEFONOS
        FOREACH
            SELECT telefono, tipo_tel, secuencia, status_tel, extension, carrier, contacto, cofetel
              INTO vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vContacto, vCofetel
              FROM bdinteg:"informix".si_telefonos
             WHERE numcte = pNumCte
             ORDER BY secuencia DESC

            SELECT NVL(nombre_carrier, ' ')
              INTO vNombreCarrier
              FROM bdinteg:"informix".si_carriers
             WHERE cve_carrier = vCarrier;

            IF vNombreCarrier is null THEN
                LET vNombreCarrier = '';
            END IF;
            
            IF vCofetel = 'V' THEN
                LET StatusValidacion = 1;
            ELSE
                LET StatusValidacion = 0;
            END IF;

            RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion WITH RESUME;
        END FOREACH;
    ELSE
        -- // TIPO DE CONSULTA INVALIDO
        LET vcodret1 = '109';
        RETURN vcodret1, vTelefono, vTipoTel, vSecuencia, vStatus_Tel, vExtension, vCarrier, vNombreCarrier, StatusValidacion;
    END IF;

    END;

END PROCEDURE;