CREATE PROCEDURE "informix".sp_conspros_dirtel_piloto( pEmpresa CHAR(3), pNumCte CHAR(20), pTipoDir SMALLINT )
RETURNING CHAR(5),      -- CODIGO DE RETORNO
          CHAR(20),     -- NO. CLIENTE
          CHAR(2),      -- ESTADO
          SMALLINT,     -- NUMERO CIUDAD
          CHAR(5),      -- DELEGACION
          INTEGER,      -- COLONIA
          INTEGER,      -- CALLE
          CHAR(10),     -- NUM EXTERIOR
          CHAR(10),     -- NUM INTERIOR
          CHAR(6),      -- DEPARTAMENTO
          CHAR(5),      -- CODIGO POSTAL
          CHAR(1),      -- PUNTO CARDINAL
          SMALLINT,     -- MANZANA
          SMALLINT,     -- OTROS
          SMALLINT,     -- ANDADOR
          SMALLINT,     -- ETAPA
          SMALLINT,     -- EDIFICIO
          SMALLINT,     -- ENTRADA
          SMALLINT,     -- LOTE
          CHAR(80),     -- OBSERVACIONES
          CHAR(40),     -- ENTRE CALLES
          CHAR(13),     -- TELEFONO CASA
          CHAR(13),     -- TELEFONO CELULAR
          SMALLINT,     -- CARRIER
          CHAR(13),     -- TELEFONO TRABAJO
          CHAR(5),      -- EXTENSION TRABAJO
          CHAR(3),      -- CIUDAD
          CHAR(1);      -- UNIDAD HABITACIONAL
          
    DEFINE viSqlErr         INTEGER;
    DEFINE viIsamErr        INTEGER;
    DEFINE vcDescErr        CHAR(50);
    DEFINE vcCodRet         CHAR(5);
    DEFINE vcCodRet2        CHAR(5);
    DEFINE vcCodRet3        CHAR(50);
    
    DEFINE vcNumPros        CHAR(20);
    DEFINE vcEstado         CHAR(2);
    DEFINE viCiudad         SMALLINT;
    DEFINE vcMunicipio      CHAR(5);
    DEFINE viColonia        INTEGER;
    DEFINE viCalle          INTEGER;
    DEFINE vcNumExt         CHAR(10);
    DEFINE vcNumInt         CHAR(10);
    DEFINE vcDepto          CHAR(6);
    DEFINE vcCodPos         CHAR(5);
    DEFINE vcPuntoCard      CHAR(1);
    DEFINE viManzana        SMALLINT;
    DEFINE viOtros          SMALLINT;
    DEFINE viAndador        SMALLINT;
    DEFINE viEtapa          SMALLINT;
    DEFINE viEdificio       SMALLINT;
    DEFINE viEntrada        SMALLINT;
    DEFINE viLote           SMALLINT;
    DEFINE vcObservaciones  CHAR(80);
    DEFINE vcEntreCalles    CHAR(40);
    DEFINE vcTelCasa        CHAR(13);
    DEFINE vcTelCelular     CHAR(13);
    DEFINE viCarrier        SMALLINT;
    DEFINE vcTelTrabajo     CHAR(13);
    DEFINE vcExtTrabajo     CHAR(5);
    DEFINE vcCiudad         CHAR(3);
    DEFINE vcUnidadHab      CHAR(1);
    
    LET viSqlErr       = 0;
    LET viIsamErr      = 0;
    LET vcDescErr      = 0;
    LET vcCodRet       = '00000';
    LET vcCodRet2      = '';
    LET vcCodRet3      = '';
    
    LET vcNumPros       = '';
    LET vcEstado        = ''; 
    LET viCiudad        = 0; 
    LET vcMunicipio     = ''; 
    LET viColonia       = 0; 
    LET viCalle         = 0; 
    LET vcNumExt        = ''; 
    LET vcNumInt        = ''; 
    LET vcDepto         = ''; 
    LET vcCodPos        = ''; 
    LET vcPuntoCard     = ''; 
    LET viManzana       = 0;  
    LET viOtros         = 0;  
    LET viAndador       = 0;  
    LET viEtapa         = 0;  
    LET viEdificio      = 0;  
    LET viEntrada       = 0;  
    LET viLote          = 0;  
    LET vcObservaciones = '';
    LET vcEntreCalles   = ''; 
    LET vcTelCasa       = ''; 
    LET vcTelCelular    = ''; 
    LET viCarrier       = 0;  
    LET vcTelTrabajo    = '';
    LET vcExtTrabajo    = '';
    LET vcCiudad        = '';
    LET vcUnidadHab     = '';

    --- SET DEBUG FILE TO "/tmp/sp_conspros_dirtel.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        --SET DEBUG FILE TO "/tmp/sp_conspros_dirtel.err";
        --TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            LET vcNumPros  = '';
            RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
                   viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' ) OR ( pNumCte  is null OR pNumCte = '' ) OR ( pTipoDir is null OR pTipoDir = 0 ) THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
               viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
    END IF;
    
    SELECT numcte_pros
      INTO vcNumPros
      FROM pr_cliente
     WHERE numcte_pros = pNumCte;
     
    IF vcNumPros is null OR vcNumPros = '' OR vcNumPros <> pNumCte THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
               viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
    END IF;
    
    SELECT estado, numerociudad, municipio, numerocolonia, numerocalle, numeroextcalle, numerointcalle, departamento, cod_postal, 
           puntocardinal, manzana, otros, andador, etapa, edificio, entrada, lote, observaciones, entre_calles, ciudad, unidadhabitac
      INTO vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, 
           vcPuntoCard, viManzana, viOtros, viAndador, viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcCiudad, vcUnidadHab
      FROM pr_direcciones_actual 
     WHERE numcte_pros = vcNumPros
       AND tipo_dir = pTipoDir;
       --AND secuencia = (SELECT MAX(secuencia) FROM pr_direcciones WHERE numcte_pros = vcNumPros AND tipo_dir = pTipoDir);
	   
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET vcCodRet = '00111';	--El Cliente No tiene direccion en la tabla pr_direcciones
		RETURN vcCodRet, vcNumPros, vcEstado, viCiudad, vcMunicipio, viColonia, viCalle, vcNumExt, vcNumInt, vcDepto, vcCodPos, vcPuntoCard, viManzana, viOtros, viAndador, 
               viEtapa, viEdificio, viEntrada, viLote, vcObservaciones, vcEntreCalles, vcTelCasa, vcTelCelular, viCarrier, vcTelTrabajo, vcExtTrabajo, vcCiudad, vcUnidadHab;
	END IF;
     
    SELECT telefono
      INTO vcTelCasa
      FROM pr_telefonos  
     WHERE numcte_pros = vcNumPros
       AND tipo_tel = 1
       AND status_tel = 'A'
       AND secuencia = ( SELECT MAX(secuencia) FROM pr_telefonos WHERE numcte_pros = vcNumPros AND tipo_tel = 1 );
       
    SELECT telefono, carrier
      INTO vcTelCelular, viCarrier
      FROM pr_telefonos  
     WHERE numcte_pros = vcNumPros
       AND tipo_tel = 2
       AND status_tel = 'A'
       AND secuencia = ( SELECT MAX(secuencia) FROM pr_telefonos WHERE numcte_pros = vcNumPros AND tipo_tel = 2 );
    
    SELECT telefono, extension
      INTO vcTelTrabajo, vcExtTrabajo
      FROM pr_telefonos  
     WHERE numcte_pros = vcNumPros
       AND tipo_tel = 3
       AND status_tel = 'A'
       AND secuencia = ( SELECT MAX(secuencia) FROM pr_telefonos WHERE numcte_pros = vcNumPros AND tipo_tel = 3 );
    
    RETURN vcCodRet, nvl(vcNumPros,''), nvl(vcEstado,''), nvl(viCiudad,0), nvl(vcMunicipio,''), nvl(viColonia,0), nvl(viCalle,0), nvl(vcNumExt,''), nvl(vcNumInt,''), nvl(vcDepto,''), 
		nvl(vcCodPos,''), nvl(vcPuntoCard,''), nvl(viManzana,0), nvl(viOtros,0), nvl(viAndador,0), nvl(viEtapa,0), nvl(viEdificio,0), nvl(viEntrada,''), nvl(viLote,0), 
		nvl(vcObservaciones,''), nvl(vcEntreCalles,''), nvl(vcTelCasa,''), nvl(vcTelCelular,''), nvl(viCarrier,0), nvl(vcTelTrabajo,''), nvl(vcExtTrabajo,''), nvl(vcCiudad,''), 
		nvl(vcUnidadHab,'');
    
    END;
    
END PROCEDURE;