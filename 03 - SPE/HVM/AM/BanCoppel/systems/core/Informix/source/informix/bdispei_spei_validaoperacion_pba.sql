CREATE PROCEDURE "informix".spei_validaoperacion_pba(pcuenta char(20), pmonto  decimal(17,2), pcanal char(4))
RETURNING 	CHAR(5),  --CODIGO RETORNO
            CHAR(2);  --TIPO DE CUENTA
    
	DEFINE cSqlerr			INTEGER;
	DEFINE cCodret  		CHAR(5);
	DEFINE cFlagSpei		CHAR(1);
	DEFINE iMaxSec			INTEGER;
	DEFINE cEmpresa			CHAR(3);
	DEFINE cCtaOper			CHAR(11);
	DEFINE cCtaMovil		CHAR(10);
	DEFINE cTpoCta			CHAR(2);
	DEFINE vmonto			VARCHAR(10);
	DEFINE iFlagDiaFeria	INTEGER;
	DEFINE iMontoMax		INTEGER;
	DEFINE iMontoDiaCta		INTEGER;
	DEFINE iMontoDiaTot		INTEGER;
	DEFINE iFlagDiaLabo		INTEGER;
    DEFINE iHorario			INTEGER;
    DEFINE vchrparametro    VARCHAR(255);

	--VALORES INICIALES
	LET cSqlerr 		= 0;
	LET cCodret 		= '000';
	LET cFlagSpei		= '';
	LET iMaxSec			= 0;
	LET cEmpresa		= '001';
	LET cCtaOper		= '';
	LET cCtaMovil		= '';
	LET cTpoCta			= 0;
	LET	vmonto			= '';
	LET iFlagDiaFeria	= 0;
	LET iMontoMax		= 0;
	LET iMontoDiaCta	= 0;
	LET iMontoDiaTot	= 0;
	LET iFlagDiaLabo	= 0;
	LET iHorario		= 0;
    LET vchrparametro   = '';
 
    BEGIN

	------  Control de Errores no Controlados
    ON EXCEPTION SET cSqlerr
        IF cSqlerr <> 0 THEN
            Let cCodret = cSqlerr;    
            RETURN cCodret, cTpoCta;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/informix/Jess/spei_validaOperacion.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    LET pcuenta = trim(pcuenta);
    LET vmonto = length(trim(pmonto::varchar(10)));

    IF length(pcuenta) = 0 OR vmonto = 0 OR vmonto is null  THEN
        LET cCodret = '004';   -- Faltan parametros de entrada
        RETURN cCodret, cTpoCta;
    END IF;
    {
    -- // Valida que no estÃÂ© bloqueada la base de datos
    SELECT vchrvalor
      INTO vchrparametro
      FROM tblparametros
     WHERE vchrcveparametro = 'BLOQUEO_A_USUARIOS';

    IF vchrparametro IS NULL THEN
        LET cCodret = '011'; 
        RETURN cCodret, cTpoCta;
    END IF;

    IF (vchrparametro * 1) = 1 THEN
        LET cCodret = '013'; 
        RETURN cCodret, cTpoCta;
    END IF;  
    }
    -- VERIFICA DIA Y HORARIO HABIL 
    SELECT {+INDEX(tblhorario ix284_1)}
           COUNT(*)
      INTO cFlagSpei
      FROM 'informix'.tblhorario
     WHERE intpkhorario = 1
       AND CURRENT BETWEEN tmhorainicio AND tmhoralimite
       AND WEEKDAY(CURRENT) BETWEEN 1 AND 5;

    -- VERIFICA DIA FERIADO
    SELECT COUNT(*)
      INTO iFlagDiaFeria
      FROM bdinteg:'informix'.si_feriado
     WHERE empresa = cEmpresa
       AND fecha = TODAY;

    --//Valida la longitud de la cuenta origen 
    IF LENGTH(TRIM(pcuenta)) = 16 THEN
        SELECT NVL(MAX(secuencia), ' ')
          INTO iMaxSec
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = cEmpresa
           AND num_tarjeta = pcuenta
           AND tipo_tarjeta = 'T';
            
        SELECT NVL(cuenta, ' ')
          INTO cCtaOper
          FROM bdicheq:"informix".sc_tarjeta
         WHERE empresa = cEmpresa
           AND num_tarjeta = pcuenta
           AND secuencia = iMaxSec
           AND status_tar = 'A';

        LET cTpoCta = 3;
    ELIF LENGTH(TRIM(pcuenta)) = 18 THEN
        LET cCtaOper = SUBSTR(pcuenta, 7, 11);
        LET cTpoCta = 40;
    ELIF LENGTH(TRIM(pcuenta)) = 11 THEN
        LET cCtaOper = TRIM(pcuenta);
        LET cTpoCta = 40;
    ELIF LENGTH(TRIM(pcuenta)) = 10 THEN
        SELECT cuenta
          INTO cCtaOper
          FROM bdicheq:'informix'.sc_cuenta_telefono
         WHERE telefono = pcuenta;

        LET cTpoCta = 10;
    ELSE
        LET cTpoCta = 0;
        LET cCodret = '004';

        RETURN cCodret, cTpoCta;
    END IF;

    IF cFlagSpei = 0 OR iFlagDiaFeria > 0 THEN   -- horario extendido
        LET iHorario = 2;
    ELSE 
        LET iHorario = 1;
    END IF;
    
    IF ((pcanal <> '5003') AND (pcanal <> '5008') AND (pcanal <> '5007') AND (pcanal <> '8501') AND (pcanal <> '5011') ) THEN
        LET pcanal ='0000';
    END IF
    
    SELECT limite_importe 
      INTO iMontoMax
      FROM 'informix'.tblimites
     WHERE horario_operativo = iHorario
       AND cve_canal = pcanal;

    IF pmonto > iMontoMax THEN
        LET cCodret = '003';   
        LET cTpoCta = 0;
    ELSE
        LET cCodret = '000';   
    END IF;
    
	RETURN cCodret, cTpoCta;
    
    END;
    
END PROCEDURE;