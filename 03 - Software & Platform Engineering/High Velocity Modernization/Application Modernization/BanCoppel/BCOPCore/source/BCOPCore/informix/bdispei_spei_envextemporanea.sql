CREATE PROCEDURE "informix".spei_envextemporanea
(
pClaveRastreo 		CHAR(30),      -- clave de rastreo
pCuentaBeneficiario	CHAR(20),      -- numero de cuenta del beneficiario
pMonto       		DECIMAL(17,2), -- monto de la operación
pCausaDev   		CHAR(2))       -- causa de devolucion
RETURNING 
	CHAR(30), 		-- folio original del sistema pisa
	CHAR(30), 		-- clave de rastreo
	DECIMAL(17,2); 	-- importe del interes

    DEFINE vCodRet1         CHAR(5);
    DEFINE vCodRet2         CHAR(5);
    DEFINE vSqlErr          INTEGER; 
    DEFINE vIsamErr         INTEGER;
    DEFINE cEmpresa         CHAR(3);
    DEFINE iSerialFolio    INTEGER;
    DEFINE cNumTarjeta     CHAR(16);
    DEFINE iMaxSec          SMALLINT;
    DEFINE cSucursal        CHAR(4);
    DEFINE cUsuario         CHAR(8);
    DEFINE cDivisa          CHAR(2);
    DEFINE cTransacc        CHAR(4);
    DEFINE dtFechaCargo     DATE;
    DEFINE dDispo           DECIMAL(18,2);
    DEFINE dCargo           DECIMAL(18,2);
    DEFINE cCuenta          CHAR(20);
    DEFINE dMontoCgoInt		DECIMAL(16,2);
    DEFINE dCargoTotal     	DECIMAL(18,2);
    
    define vcod_ret         char(5);
    define cCuenta1         char(20);
    define vnum_cte         char(20);
    define vapell_pat       char(26);
    define vapell_mat       char(26);
    define vnombre1         char(26);
    define vnombre2         char(26);
    define vrazon_soc       char(60);
    define vedo_cta         char(1);
    define vsdo_disp        money(14,2);
    define vsdo_ret         money(14,2);
    define vsdo_ccc         money(14,2);
    define vsdo_disp_ccc    money(14,2);
    define vsdo_cta         money(14,2);
    define vtipo_linea      char(1);
    define vdescrip1        char(40);
    define vdescrip2        char(40);
    define vsdo_t1          money(14,2);
    define vsdo_cong        money(14,2);
    define vimp_chq_sbc     money(14,2);
    define vusubloq         char(8);
    define vfecbloq         date;
    define vnum_tarjeta     char(16);
    define vcta_clabe       char(18);
    define cTransaccion     integer;
    --DEFINE cProducto        CHAR(4);
    define cCtaOrd          char(20);
	--define cTpoPersona		CHAR(1);
	
	DEFINE cFolioOrigen		CHAR(30);
	DEFINE cClaveRastreo	CHAR(30);
	DEFINE dMontoInteres	DECIMAL(17,2);
	DEFINE cTranCargo		CHAR(4);
	DEFINE cTranCargoInt	CHAR(4);
	DEFINE dTsaPond			DECIMAL(9,6);
	DEFINE iMinutos			INTEGER;
    
    LET vCodRet1 = "000";
    LET vCodRet2 = "000";
    LET vSqlErr  = 0;
    LET vIsamErr = 0;
    let cTransaccion = 0;
    
    LET cEmpresa        = '001';
    LET iSerialFolio   = 0;
    LET cNumTarjeta    = '';
    LET iMaxSec         = 0;
    LET cSucursal       = '9201';
    LET cUsuario        = 'tranSPEI';
    LET cDivisa         = '01';
    LET cTransacc       = '';  
    LET dtFechaCargo    = '';  
    LET dDispo          = 0.00; 
    LET dCargo          = 0.00; 
    LET cCuenta         = "";
    LET dMontoCgoInt = 0.00;
    LET dCargoTotal    = 0.00;
	
    let vcod_ret      = "000";
    let cCuenta1      = '';
    let vnum_cte      = '';
    let vapell_pat    = '';
    let vapell_mat    = '';
    let vnombre1      = '';
    let vnombre2      = '';
    let vrazon_soc    = '';
    let vedo_cta      = '';
    let vsdo_disp     = 0.00;
    let vsdo_ret      = 0.00;
    let vsdo_ccc      = 0.00;
    let vsdo_disp_ccc = 0.00;
    let vsdo_cta      = 0.00;
    let vtipo_linea   = '';
    let vdescrip1     = '';
    let vdescrip2     = '';
    let vsdo_t1       = 0.00;
    let vsdo_cong     = 0.00;
    let vimp_chq_sbc  = 0.00;
    let vusubloq      = '';
    let vfecbloq      = '';
    let vnum_tarjeta  = '';
    let vcta_clabe    = '';
    --let cProducto     = "";
	LET cCtaOrd       = '';
	--let cTpoPersona	  = "";
	
	LET cFolioOrigen	= "0";
	LET cClaveRastreo	= "";
	LET dMontoInteres	= 0;
	LET cTranCargo		= "";
	LET cTranCargoInt	= "";
	LET dTsaPond		= 0.0;
	LET iMinutos		= 0;
	

	--- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_env_extemporanea.out";
	--- TRACE ON;

    BEGIN

    ON EXCEPTION SET vSqlErr, vIsamErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_env_extemporanea.err";
        TRACE ON;
        IF vSqlErr != 0 THEN
            LET vCodRet1 = vSqlErr;
            LET vCodRet2 = vIsamErr;
            if cTransaccion = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            else
                ROLLBACK WORK;
            end if;
			LET cFolioOrigen = '0';
            RETURN cFolioOrigen, cClaveRastreo, dMontoInteres;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET cTransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    IF cTransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF (pMonto IS NULL OR pMonto <= 0) OR (pClaveRastreo IS NULL OR pClaveRastreo = "") OR (pCuentaBeneficiario IS NULL OR pCuentaBeneficiario = "") OR (pCausaDev IS NULL OR pCausaDev = "") THEN
        LET cFolioOrigen = '0';
        IF cTransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF
		RETURN cFolioOrigen, cClaveRastreo, dMontoInteres;
    END IF;

    LET cFolioOrigen='SPEI1110';
    LET cClaveRastreo=pClaveRastreo;
	LET dMontoInteres=1.00;
 	
    RETURN cFolioOrigen, cClaveRastreo, dMontoInteres;
   
   END;
    
END PROCEDURE;