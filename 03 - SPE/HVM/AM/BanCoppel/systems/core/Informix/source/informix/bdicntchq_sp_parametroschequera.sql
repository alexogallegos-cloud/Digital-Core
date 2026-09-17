CREATE PROCEDURE "informix".sp_parametroschequera (pEmpresa CHAR(3), pNumEmpleado CHAR(8))

RETURNING
        CHAR( 5) AS RETORNO,            -- CODIGO DE RETORNO
        CHAR( 2) AS LONGITUDCLIENTE,    -- LONGITUD DEL CLIENTE
        CHAR( 2) AS CODMONNAC,          -- CODIGO DE LA MONEDA NACIONAL
       CHAR(100) AS CODPATHREP,         -- VALOR PATH DEL REPORTE
        CHAR(45) AS NOMUSUARIO,         -- NOMBRE DEL USUARIO
        CHAR(30) AS NOMEMPRESA,         -- NOMBRE DE LA EMPRESA               
        CHAR( 2) AS SISTEMA,            -- CODIGO DEL SISTEMA	
        CHAR( 2) AS SISTEMACHEQUES,     -- CODIGO DEL SISTEMA CHEQUES
        CHAR(11) AS LONGITUDCTA,        -- LONGITUD DE LA CUENTA
		CHAR( 3) AS CVEBANCOPPEL,       -- CLABE DE BANCO DE BANCOPPEL
		    DATE AS FECHAHOY,           -- FECHA HOY
            DATE AS FECHAANT,           -- FECHA ANTERIOR
            DATE AS PROXFECHA,          -- FECHA PROXIMA
            DATE AS PRIDIAMES,          -- PRIMER DIA DEL MES
            DATE AS PRIMHABMES,         -- PRIMER DIA HABIL MES
            DATE AS ULTDIAMES,          -- ULTIMO DIA DEL MES
            DATE AS ULTHABMES;          -- ULTIMO DIA HABIL DEL MES         
		 
    --DECLARACION DE VARIABLES
    DEFINE iSqlErr              INTEGER;
    DEFINE cCodRet              CHAR( 5);
    DEFINE cLongitudCliente     CHAR( 2);
    DEFINE cCodMonNac           CHAR( 2);
    DEFINE cPathRep             CHAR(100);
    DEFINE cNombreUsuario       CHAR(45);
    DEFINE cNombreEmpresa       CHAR(30);    
    DEFINE cSistema             CHAR( 2);	
	DEFINE cSistemaCheques      CHAR( 2);
    DEFINE cLongCta             CHAR(11);
	DEFINE cCveBanCoppel        CHAR(3);
	DEFINE dFecha_Hoy           DATE;
    DEFINE dFecha_ant           DATE;
    DEFINE dProx_fecha          DATE;
    DEFINE dPri_dia_mes         DATE;
    DEFINE dPri_hab_mes         DATE;
    DEFINE dUlt_dia_mes         DATE;
    DEFINE dUlt_hab_mes         DATE;	
            
			
	--Crea el control de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, cLongitudCliente, cCodMonNac, cPathRep, cNombreUsuario, cNombreEmpresa, cSistema,cSistemaCheques, cLongCta, cCveBanCoppel,
			dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes;
		END IF;
	END EXCEPTION; 		
			
    --INICIALIZAR VARIABLES
    LET cCodRet 		  	= '00000';
    LET cLongitudCliente	= '';
    LET cCodMonNac			= '';
    LET cPathRep			= '';
    LET cNombreUsuario		= '';
    LET cNombreEmpresa 		= '';
    LET dFecha_Hoy 			= '';
    LET cSistema 			= '';
	LET cSistemaCheques     = '';
    LET cLongCta			= '';
    LET dFecha_ant			= '';
    LET dProx_fecha 		= '';
    LET dPri_dia_mes		= '';
    LET dPri_hab_mes		= '';
    LET dUlt_dia_mes		= '';
    LET dUlt_hab_mes		= '';
    LET cCveBanCoppel       = '';	
    
    --SET DEBUG FILE TO "/respaldosbd/Lorenzo/sp_ParametrosChequera.out";
    --TRACE ON;
         
BEGIN

    --Validacion de parametros de entrada	
    IF pEmpresa is null OR length(pEmpresa) < 3 OR pNumEmpleado is null OR length(pNumEmpleado) < 8 then
		Let cCodRet = '001';
		RETURN cCodRet, cLongitudCliente, cCodMonNac, cPathRep, cNombreUsuario, cNombreEmpresa, cSistema,cSistemaCheques, cLongCta, cCveBanCoppel,
			dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes;
    END IF;

    --Obtengo el valor longitud del numero de cliente	
	SELECT TRIM(valor)
	INTO cLongitudCliente 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('longitud cliente'); 
	
	--Obtengo el valor codigo de la moneda nacional
	SELECT TRIM(valor)
	INTO cCodMonNac 
	FROM bdinteg:"informix".si_param 
	WHERE empresa = pEmpresa AND descripcion = ('codigo mn');
		 
    --Obtengo el valor path de reportes	
	SELECT NVL(TRIM(valor), '')
	INTO cPathRep
	FROM bdicntchq:"informix".sq_param 
	WHERE cod_param = 19;

	--Obtengo el nombre del usuario o ejecutivo
	SELECT NVL(nombre, '')
	INTO cNombreUsuario
	FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pNumEmpleado;
		 
	--Obtengo el nombre de la empresa
	SELECT NVL(razon_social, '')
	INTO cNombreEmpresa
	FROM bdinteg:"informix".si_empresas 
	WHERE empresa = pEmpresa;
    
	--Obtengo el valor longitud de la cuenta de cheques
	SELECT NVL(valor, '')
	INTO cLongCta
	FROM bdicheq:"informix".sc_param 
	WHERE codparam = 'longcta' and empresa ='001' ;
		
	-- Obtengo Fecha de integral para la Captura de Parametros
	SELECT fecha_hoy, fecha_ant, prox_fecha, pri_dia_mes, pri_hab_mes, ult_dia_mes, ult_hab_mes  
	INTO dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes
	FROM bdicheq:"informix".sc_fechas;

	--Obtengo codigo del sistema
	SELECT NVL(sistema, '')
	INTO cSistema
	FROM bdinteg:"informix".si_sistema 
	WHERE siglas = 'CH';
		
	SELECT NVL(sistema,'')
    INTO cSistemaCheques	
	FROM bdinteg:"informix".si_sistema 
	WHERE siglas = 'SC';
	 
	
	--Obtengo el codigo de banco de BanCoppel
	SELECT NVL(TRIM(valor), '')
	INTO cCveBanCoppel
	FROM bdinteg:"informix".si_param 
	WHERE cod_param = '5';
		
	RETURN cCodRet, cLongitudCliente, cCodMonNac, cPathRep, cNombreUsuario, cNombreEmpresa, cSistema,cSistemaCheques, cLongCta, cCveBanCoppel,
			dFecha_Hoy, dFecha_ant, dProx_fecha, dPri_dia_mes, dPri_hab_mes, dUlt_dia_mes, dUlt_hab_mes;
		
END
END PROCEDURE
DOCUMENT
'CREACION     : ARMANDO MERCADO FIGUEROA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL SISTEMA DE CHEQUERAS',
'FECHA    	  : MAYO 2011',
'BASE DE DATOS: BDICNTCHQ',
'VERSION  	  : 20110506';

CREATE PROCEDURE "informix".sp_validar_promedio_chequera(pCuenta char(20), pNumParam integer)
        RETURNING char(5), char(60);
    
    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener parametro saldo promedio minimo para obtener chequera y 
	--             validar si el saldo de la cuenta promedio es mayor
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 19/03/2010

    --Modificado
    --Fecha: 24/Agosto/2011
    --Por:   Berenice Noriega Guevara
    --Actividad: se modifico para que se tomen en cuenta los clientes 
    --que aun no cumplen con un mes de antiguedad y desean una nueva chequera.

   DEFINE v_hoy  date;
   DEFINE vdummy char(100);
   DEFINE vdummy1 char(100);
   DEFINE vfechames DATE;
   DEFINE vCodret   char(5);
   DEFINE vValorPromedio  char(60);
   DEFINE vSdoPromedio money;
   DEFINE vfecha_alta  DATE;
   DEFINE sql_err integer;


	ON EXCEPTION SET sql_err
	   IF sql_err <> 0 THEN
		LET vCodret = sql_err;
		RETURN vCodret, vValorPromedio;
	   END IF;
	END EXCEPTION;

	LET vCodret = '000';
	LET vValorPromedio = '';
	LET vSdoPromedio = 0;
    LET vdummy = " ";
    LET vdummy1 = " ";

	
	BEGIN

		--- Selecciona la fecha del dia.
            SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

        --- Obtener Valor
			SELECT valor 
			INTO vValorPromedio
			FROM sq_param 
			WHERE cod_param = pNumParam;

        --- valor vacio
            IF (vValorPromedio = '') THEN
            	LET vCodret = '001';
            	RETURN vCodret, vValorPromedio;
            END IF;
		
		--- Saldo Promedio
			SELECT sdo_prom_mesant, fecha_alta 
			INTO vSdoPromedio, vfecha_alta
			FROM bdicheq:sc_maenoc 
			WHERE cuenta = pCuenta;

       --- Saldo nulo
            IF (vSdoPromedio='') THEN
            	LET vCodret = '002';
            	RETURN vCodret, vValorPromedio;
            END IF;

      --//Si tiene saldo promedio mayor a 0, no es apertura reciente
          IF vSdoPromedio > 0 THEN
              IF (vSdoPromedio < vValorPromedio::money) THEN 
                  LET vCodret = '003';
                  RETURN vCodret, vValorPromedio;
             END IF
          ELSE --//Verifica que no sea cuenta reciente para saldo promedio = 0
             EXECUTE PROCEDURE bdicheq:sp_mes_siguiente(vfecha_alta,1,day(vfecha_alta))
                      INTO vdummy, vfechames, vdummy1;
            
             IF v_hoy > vfechames THEN
                IF (vSdoPromedio < vValorPromedio::money) THEN 
                      LET vCodret = '003';
                      RETURN vCodret, vValorPromedio;
                 END IF
             END IF
         END IF

		RETURN vCodret, vValorPromedio;
	END;

END PROCEDURE;