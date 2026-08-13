CREATE PROCEDURE "informix".valida_abono_ref( pempresa     CHAR(3),
                                              psucursal    CHAR(4),
                                              pusuario     CHAR(8),
                                              ptransacc    CHAR(4),
                                              ptransuc     CHAR(4),                                   
                                              pcuenta      CHAR(20),
                                              pmto_tot     MONEY(14,2),
                                              pdias_ret    SMALLINT )
RETURNING CHAR(5);
    
    -- ********************************************************************
    -- Nombre:              valida_abono_ref
    -- Version:             1.0.0
    -- Objetivo:            Valida Limites de deposito 204 y 209
    -- Supuestos:           Ninguno
    -- Creado por:          Concepcion Alvarez Carrillo
    -- Ultima Modificacion: Enero 2016
    -- ********************************************************************

    DEFINE vcodret              CHAR(5);
    DEFINE vcodret2             CHAR(5);
    DEFINE vcodret3             CHAR(50);
    DEFINE vsqlerr              INTEGER;
    DEFINE visamerr             INTEGER;
    DEFINE vdescerr             CHAR(50);
    DEFINE vsuccta              CHAR(4);
    DEFINE vproducto            CHAR(4);
    DEFINE vvaldoc              CHAR(1);
    DEFINE vnat                 CHAR(1);
    DEFINE vstatus              CHAR(1);
    DEFINE vfecha_hoy           DATE;
    DEFINE vfecha_prox          DATE;
    DEFINE vfecha_sistema       DATE;
    DEFINE vnumcte              CHAR(20);
    DEFINE vtransaccion         INTEGER;
    DEFINE vestado_oper         CHAR(2);
    DEFINE vestado_cta          CHAR(2);
    DEFINE vmonto_acum          DECIMAL(18,2);
    DEFINE vmonto_perm          DECIMAL(16,2);
    DEFINE vtpo_per_valida      CHAR(1);
    DEFINE vlimdepefec          DECIMAL(18,2);
    DEFINE vmtodepacum          DECIMAL(18,2);
    DEFINE vCteExcluido         CHAR(20);
    DEFINE vlimdepinterpza      DECIMAL(18,2);
    DEFINE vind_dispon          CHAR(1);
    DEFINE vSQL                 CHAR(10);
    DEFINE vTpoValidacion       CHAR(1);
    DEFINE iNoTrxsPerm          INTEGER;
    DEFINE iNoTrxsHechas        INTEGER;
    DEFINE vpri_dia_mes         DATE;

    LET vcodret         = "000";
    LET vcodret2        = "";
    LET vcodret3        = "";
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vtransaccion    = 0;
    LET vmonto_acum     = 0;
    LET vmonto_perm     = 0;
    LET vtpo_per_valida = '';
    LET vlimdepefec     = 0.00;
    LET vmtodepacum     = 0.00;
    LET vCteExcluido    = '';
    LET vlimdepinterpza = 0.00;
    LET vind_dispon     = '0';
    LET vSQL            = '';
    LET vTpoValidacion  = '';
    LET iNoTrxsPerm     = 0;
    LET iNoTrxsHechas   = 0;
    LET vpri_dia_mes    = '';

    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/tmp/abono_ref.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF SUBSTR(pcuenta, 1, 2) <> '80' THEN
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
            END IF;
            RETURN vcodret;
        END IF
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET vtransaccion = 1;
    END EXCEPTION WITH RESUME;
    
    --- SET ISOLATION TO CURSOR STABILITY;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --- SET DEBUG FILE TO "/tmp/abono_ref.out";
    --- TRACE ON;
    
    --  PARA CUENTAS DEL BANCO
 
    IF vtransaccion = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
            
    --  Valida la informacion de entrada
    IF psucursal  = "" OR pusuario   = "" OR 
       ptransacc  = "" OR pcuenta    = "" OR 
       pdias_ret  < 0  THEN
        LET vcodret = 110;
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;
    
    --  Obtiene fechas del sistema de cheques
    SELECT {+INDEX(sc_fechas idx_fechas1)} 
           fecha_hoy, prox_fecha, fecha_hoy, ind_disponible, pri_dia_mes
      INTO vfecha_hoy, vfecha_prox, vfecha_sistema, vind_dispon, vpri_dia_mes
      FROM sc_fechas 
     WHERE empresa = pempresa;
     
    IF vind_dispon = '0' THEN
        LET vcodret = '004';
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;
            
    --  Valida que exista la transaccion de abono
    SELECT naturaleza, valida_docto, dias_ret
      INTO vnat, vvaldoc, pdias_ret
      FROM bdinteg:si_transacc
     WHERE empresa = pempresa 
       AND numero = ptransacc
       AND sistema = '01'
       AND naturaleza = 'A';
    
    IF vnat IS NULL THEN
        LET vcodret = "552";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;
    
    --  Valida que la naturaleza sea de abono
    IF vnat != "A" THEN
        LET vcodret = "552";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF;
    
    --  Inicializa los dias de retencion
    IF pdias_ret IS NULL THEN
        LET pdias_ret = 0;
    END IF;
    
    -- Valida exista la cuenta
    SELECT status_cta, fecha_proceso, producto, sucursal, num_cte
      INTO vstatus, vfecha_hoy, vproducto, vsuccta, vnumcte
      FROM sc_maechq
     WHERE empresa = pempresa 
       AND cuenta = pcuenta;
       
    SELECT tpper_valida
      INTO vtpo_per_valida
      FROM sc_producto
     WHERE producto = vproducto;
    
    IF vproducto = '2300' AND ptransacc = '0202' THEN
       LET vcodret = '100';
       RETURN vcodret;
    END IF
    
    IF vproducto = '2800' AND ptransacc = '0202' THEN
       LET vcodret = '403';
       RETURN vcodret;
    END IF
       
    IF vstatus IS NULL THEN
        LET vcodret = "100";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF
    
    IF vstatus = '6' AND ptransacc = '0324' THEN
        LET vstatus = '1';
        LET vfecha_hoy = vfecha_sistema;
    END IF;

    --  Valida que la cuenta no este cancelada
    IF vstatus in ("2","6","7","8") THEN
        LET vcodret = "200";
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcodret;
    END IF
    
    --  Valida cuentas inactivas
    IF vstatus IN("4","5") THEN
        LET vfecha_hoy = vfecha_sistema;
    END IF

    --  Trae la fecha del dia de hoy en cheques...
    IF vfecha_hoy IS NULL THEN
        LET vfecha_hoy = vfecha_sistema;
    END IF

  --  SOLICITUD DE EXCEPCION PARA OMITIR VALIDACIONES DE CONTROL DE DEPOSITOS EN EFECTIVO
    SELECT COUNT(*)
      INTO vCteExcluido
      FROM sc_exentos_dep_efec
     WHERE num_cte = vnumcte;
    
    IF vCteExcluido = 0 THEN
        
        IF ptransacc = '0202' AND vtpo_per_valida IN('1','3') AND vproducto <> '1100' THEN
                
            -- // VALIDA MONTO MENSUAL PERMITIDO POR CLIENTE 
            SELECT valor
              INTO vlimdepefec
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = 'LimDepositosEfetivo';
            
            SELECT SUM(monto)
              INTO vmtodepacum
              FROM sc_depositosefectivo
             WHERE num_cte = vnumcte;
            
            IF vmtodepacum is null THEN
                LET vmtodepacum = 0.00;
            END IF;
            
            LET vmtodepacum = vmtodepacum + pmto_tot;
            
            IF vmtodepacum > vlimdepefec THEN
                LET vcodret = '397';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
            
            -- // VALIDACIONES INTERESTADO
             SELECT cve_estado
              INTO vestado_oper
              FROM bdinteg:si_ptf
             WHERE id_ptf = psucursal 
               AND tipo = 'S';

            /*
            SELECT estado
              INTO vestado_oper
              FROM bdinteg:si_sucursales
             WHERE sucursal = psucursal;
            */
             
            SELECT cve_estado
              INTO vestado_cta
              FROM bdinteg:si_ptf
             WHERE id_ptf = vsuccta 
               AND tipo = 'S'; 

            /*
            SELECT estado
              INTO vestado_cta
              FROM bdinteg:si_sucursales
             WHERE sucursal = vsuccta;
            */
             
            IF vestado_oper <> vestado_cta THEN
                SELECT valor 
                  INTO vTpoValidacion
                  FROM sc_param
                 WHERE empresa  = pempresa
                   AND codparam = 'LimDepositoInterEsta'; 
                   
                IF vTpoValidacion is null OR vTpoValidacion = '' THEN
                    LET vTpoValidacion = 'O';
                END IF;
                
                IF vTpoValidacion = 'S' THEN  
                    IF ( ( SELECT COUNT(*) FROM sc_limitedeposito WHERE sucursal = psucursal ) > 0 ) THEN  
                        SELECT monto
                          INTO vmonto_perm
                          FROM sc_limitedeposito 
                         WHERE sucursal = psucursal;
                    ELSE 
                        SELECT monto
                          INTO vmonto_perm
                          FROM sc_limitedeposito 
                         WHERE sucursal = '9999';
                    END IF; 
                ELIF vTpoValidacion = 'G' THEN  
                    SELECT monto
                      INTO vmonto_perm
                      FROM sc_limitedeposito 
                     WHERE sucursal = '9999';
                ELSE
                    SELECT valor
                      INTO vmonto_perm
                      FROM sc_param
                     WHERE empresa = pempresa
                       AND codparam = 'MontoDepInterPlaza';
                END IF;
                    
                SELECT SUM(monto_acum)
                  INTO vmonto_acum
                  FROM sc_depinterpza
                 WHERE num_cte = vnumcte
                   AND fecha >= vpri_dia_mes;
                   
                IF vmonto_acum is null THEN
                    LET vmonto_acum = 0.00;
                END IF;
                   
                LET vmonto_acum = vmonto_acum + pmto_tot;
                   
                IF vmonto_acum > vmonto_perm THEN
                    LET vcodret = '371';
                    IF vtransaccion = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    RETURN vcodret;
                END IF;      
            END IF;
        END IF;
        
        
        IF ptransacc = '0325' THEN 
            -- // VALIDA MONTO MENSUAL ACUMULADO POR CLIENTE 
            SELECT valor
              INTO vlimdepefec
              FROM sc_param
             WHERE empresa = pempresa
               AND codparam = 'LimDepositosEfetivo';
            
            SELECT SUM(monto)
              INTO vmtodepacum
              FROM sc_depositosefectivo
             WHERE num_cte = vnumcte;
            
            IF vmtodepacum is null THEN
                LET vmtodepacum = 0.00;
            END IF;
            
            LET vmtodepacum = vmtodepacum + pmto_tot;
            
            IF vmtodepacum > vlimdepefec THEN
                LET vcodret = '397';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
            
            -- // VALIDA QUE EL TIPO DE PERSONA SEA FISICA
            IF vtpo_per_valida IN ('2','4') THEN
                LET vcodret = '375';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
            
            -- // VALIDA QUE LA TRANSACCION SEA INTER-ESTADO
            SELECT cve_estado
              INTO vestado_oper
              FROM bdinteg:"informix".si_ptf
             WHERE id_ptf = psucursal 
               AND tipo = 'S';

            /*
            SELECT estado
              INTO vestado_oper
              FROM bdinteg:"informix".si_sucursales
             WHERE sucursal = psucursal;
            */
             
            SELECT cve_estado
              INTO vestado_cta
              FROM bdinteg:"informix".si_ptf
             WHERE id_ptf = vsuccta 
               AND tipo = 'S';
              
            /*
            SELECT estado
              INTO vestado_cta
              FROM bdinteg:"informix".si_sucursales
             WHERE sucursal = vsuccta;
            */
             
            IF vestado_oper = vestado_cta THEN
                LET vcodret = '374';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;  
            
            -- // OBTIENE MONTO MINIMO PERMITIDO PARA UTILIZAR TRANSACCION 0325 
            SELECT valor 
              INTO vTpoValidacion
              FROM sc_param
             WHERE empresa  = pempresa
               AND codparam = 'LimDepositoInterEsta'; 
               
            IF vTpoValidacion is null OR vTpoValidacion = '' THEN
                LET vTpoValidacion = 'O';
            END IF;
            
            IF vTpoValidacion = 'S' THEN  
                IF ( ( SELECT COUNT(*) FROM sc_limitedeposito WHERE sucursal = psucursal ) > 0 ) THEN  
                    SELECT monto, num_transaccion
                      INTO vmonto_perm, iNoTrxsPerm
                      FROM sc_limitedeposito 
                     WHERE sucursal = psucursal;
                ELSE 
                    SELECT monto, num_transaccion
                      INTO vmonto_perm, iNoTrxsPerm
                      FROM sc_limitedeposito 
                     WHERE sucursal = '9999';
                END IF; 
            ELIF vTpoValidacion = 'G' THEN  
                SELECT monto, num_transaccion
                  INTO vmonto_perm, iNoTrxsPerm
                  FROM sc_limitedeposito 
                 WHERE sucursal = '9999';
            ELSE
                SELECT valor
                  INTO vmonto_perm
                  FROM sc_param
                 WHERE empresa = pempresa
                   AND codparam = 'MontoDepInterPlaza';
                   
                LET iNoTrxsPerm = 999999;
            END IF;
               
            -- // OBTIENE ACUMULADO MENSUAL INTER-ESTADO POR CLIENTE
            SELECT SUM(monto_acum)
              INTO vmonto_acum
              FROM sc_depinterpza
             WHERE num_cte = vnumcte
               AND fecha >= vpri_dia_mes;
               
            IF vmonto_acum is null THEN
                LET vmonto_acum = 0.00;
            END IF;
               
            LET vmonto_acum = vmonto_acum + pmto_tot;
               
            -- // VALIDA MONTO MINIMO PARA DEPOSITOS INTERESTADO
            IF vmonto_acum < vmonto_perm THEN 
                LET vcodret = '374';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
            
            -- // OBTIENE MONTO LIMITE PERMITIDO PARA UTILIZAR LA TRANSACCION 0325
            LET vlimdepinterpza = vlimdepefec - vmonto_perm;
            
            -- // OBTIENE TRANSACCIONES INTER-ESTADO REALIZADAS POR EL CLIENTE
            SELECT COUNT(*), SUM(monto) 
              INTO iNoTrxsHechas, vmtodepacum
              FROM sc_depositosefectivo
             WHERE num_cte = vnumcte
               AND transacc = '0325';
               
            IF vmtodepacum is null THEN
                LET vmtodepacum = 0.00;
            END IF;
             
            LET iNoTrxsHechas = iNoTrxsHechas + 1;
            LET vmtodepacum = vmtodepacum + pmto_tot;
            
            -- // VALIDA LIMITES PERMITIDOS PARA MONTOS Y NUMERO DE TRANSACCIONES
            IF ( ( vmtodepacum > vlimdepinterpza ) OR ( iNoTrxsHechas > iNoTrxsPerm ) ) THEN
                LET vcodret = '397';
                IF vtransaccion = 1 THEN
                    ROLLBACK WORK;
                    BEGIN WORK;
                ELSE
                    ROLLBACK WORK;
                END IF;
                RETURN vcodret;
            END IF;
        END IF;    
    END IF;

    IF vcodret = "000" THEN
        IF vtransaccion = 1 THEN
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            COMMIT WORK;
        END IF;
       
    ELSE
        IF vtransaccion = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
    END IF
    
    RETURN vcodret;
    
    END;
    
END PROCEDURE
DOCUMENT
'AUTOR:	      Concepcion Alvarez Carrillo',
'FECHA:	      enero/2016',
'DESCRIPCION: Se consulta los limites de deposito de la transaccion 204 y 209',
'VERSION:     1.0',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".cuenta1( pempresa 			 CHAR(3),
									 pusuario    		 CHAR(8),
									 psucursal   		 CHAR(4),
									 pproducto    		 CHAR(4),
									 pnum_cte      		 CHAR(20),
									 pnum_cot      		 CHAR(2),
									 pclase_cta   		 CHAR(1),
									 preg_firmas  		 CHAR(1),
									 ptipo_bca     		 CHAR(3),
									 pejecutivo    		 CHAR(8),
									 penvio_direcc 		 CHAR(1),
									 pcuenta      		 CHAR(20),
									 pdirecc_envio  	 SMALLINT,
									 pcliente2     		 CHAR(20),
									 pnombre      		 CHAR(50),
									 pinstcap     		 CHAR(2),
									 pcuentacap   		 CHAR(20),
									 pinstint     		 CHAR(2),
									 pcuentaint   	     CHAR(20),
									 pplazo        		 SMALLINT,
									 pcobraISr   	     CHAR(1),
									 pproced_aperturacta CHAR(2),
									 pproced_mantenercta CHAR(2),
									 pmonto_mensual 	 CHAR(2),
									 pdepositos_cantidad CHAR(2),
									 pdepositos_monto	 CHAR(2),
									 pretiros_cantidad   CHAR(2),
									 pretiros_monto 	 CHAR(2),
									 pformaapert         CHAR(2),
									 pmtoapertura        MONEY(14,2))

RETURNING CHAR(5),CHAR(20),CHAR(18);

	DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
	DEFINE vcodret3         CHAR(6);
	DEFINE vdesccodret3     CHAR(80);
	DEFINE vpago_capital,
	       vpago_interes,
		   vpaga_interes,
           vpaga_capital,
		   vexiste CHAR(1);
	DEFINE vplaza CHAR(3);
	DEFINE vdIFerencia,
	       vlongcta SMALLINT;
	DEFINE vfecha,
	       vfecha_ini,
		   vfecha_fin DATE;
	DEFINE vfecpagoint,
	       vfecpagocap,
		   vfeciniape,
		   vfecfinape DATEtime MONTH TO DAY;
	DEFINE i SMALLINT;
	DEFINE vplazomin,
	       vplazomax SMALLINT;
	DEFINE vsqlerr INTEGER;
	DEFINE vultpagocap,
           vultpagoint DATE;
	DEFINE vdivISa,
	       vdivISacta CHAR(2);
	DEFINE vsistcap,
	       vsIStint,
		   vsiglas CHAR(2);
	DEFINE vrequiere_cta CHAR(1);
	DEFINE vtipocte1,
	       vtipocte2,
		   vtipocte3,
		   vtipocte4,
		   vtipocte5 CHAR(1);
	DEFINE ves_fisica,
	       vtipo_cliente,
		   vtpper_valida,
		   vtpcte_valido CHAR(1);
	DEFINE vsignumcta INTEGER;
	DEFINE vdigverif CHAR(1);
	DEFINE vctaclabe CHAR(18);
	DEFINE vparamsigcta   CHAR(20);
	DEFINE vidcta         CHAR(1);
	DEFINE vtasavariable  CHAR(1);
	DEFINE vtasaprod      CHAR(8);
	DEFINE vvalorvariable DECIMAL(9,6);
	DEFINE vtipotasa      CHAR(1);
	DEFINE vfechaperiodo  DATE;
	DEFINE vProdCrec      CHAR(4);
	DEFINE vMtoMinimo     DECIMAL(14,2);
	DEFINE vmarca_ret     CHAR (1);
	DEFINE vAlchepro      CHAR(1);
	DEFINE vTipocheq      CHAR(2);
	DEFINE iMaxCtas	       	INTEGER;
    DEFINE iNCuentas       	INTEGER;
    DEFINE iExiste			INTEGER;
    DEFINE cStatus_cta		CHAR(1);
    DEFINE sSecuencia		SMALLINT;
	DEFINE cPROACProducto	CHAR(4);
	DEFINE cFecFormat2 		CHAR(25);
	DEFINE cFecFormat1 		CHAR(25);
	DEFINE dFecha_siganio	DATE;
	DEFINE cProducto		CHAR(10);
	DEFINE cRecValor		CHAR(20);
	DEFINE cCodRetSp        CHAR(5);
    DEFINE correoCli        CHAR(100);
	DEFINE celularCli       CHAR(13);
	DEFINE cCodRetSp1       CHAR(5);
	DEFINE cCodRetSp2       CHAR(5);
	DEFINE nombreCuenta     CHAR(100);
	
	LET vcodret3 		= '000000';
	LET vdesccodret3    = 'PROCESO EXITOSO';
	LET cCodRetSp        = '00000';
	LET correoCli         ='';
	LET celularCli        ='';
	LET cCodRetSp1        = '00000';
	LET cCodRetSp2        = '00000';
	LET nombreCuenta      ='';
	
BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret,pcuenta,vctaclabe;
      END IF;
   END EXCEPTION;


    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;   
   
--     SET DEBUG FILE TO "/respaldosbd/hectorb/cuenta1.out";
--     TRACE ON;

-- Inicializa variables
	LET vcodret  = "000";
	LET vctaclabe = "";
	LET pcobraISr = "S"; -- Para Bancoppel

	LET vparamsigcta   ="?";
	LET vidcta         ="?";
	LET vtasavariable  = "?";
	LET vtasaprod      = "?";
	LET vvalorvariable = 0;
	LET vtipotasa      = "?";
	LET vfechaperiodo  = "";
	LET vplazomax      = 0;

	LET iMaxCtas		= 0;
	LET iNCuentas		= 0;
	LET iExiste			= 0;
	LET cStatus_cta		= "";
	LET sSecuencia		= 0;
	LET  cPROACProducto	= "";

	LET  cFecFormat2 	= "";
	LET  cFecFormat1 	= "";
	LET  dFecha_siganio	= "01/01/1900";
	LET  cProducto		= "";
	LET  cRecValor		= "";

	LET vcodret2 		= '';


   --******************************			PROAC			************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--Consulta el parametro del producto de PROAC.
	SELECT valor INTO cPROACProducto FROM bdicheq:"informix".sc_param WHERE codparam = 'PROACPRODUCTO';
	IF cPROACProducto = '' OR cPROACProducto IS NULL THEN
		LET vcodret = '90001';
		LET vctaclabe = 'PRODUCTO NO IDENTIFICADO';
        RETURN vcodret, pcuenta, vctaclabe;
	END IF;

	IF TRIM(cPROACProducto) = TRIM(pproducto) THEN
		--VALIDAR QUE VENGA LA CUENTA EJE PARA ASOCIAR LA CUENTA PROAC
		IF pCliente2 = '' OR pCliente2 IS NULL THEN
			LET vcodret = '90007';
			LET vctaclabe = 'ES NECESARIO CUENTA EJE';
		END IF;

		--Consulta cuantas cuentas por cliente puede tener el PROAC
		SELECT valor INTO iMaxCtas FROM bdicheq:"informix".sc_param WHERE codparam = 'PROACMAXCTAS';

		SELECT COUNT(cuenta) INTO iNCuentas
		FROM bdicheq:"informix".sc_proac
		WHERE num_cte = pnum_cte
		AND status_cta ='1';

		IF	iNCuentas >= iMaxCtas  THEN
			LET iExiste = 0;
			LET vcodret = "90002";
			LET vctaclabe = "Cliente Con El Maximo De Cuentas Permitidas";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;

		--Valida que no exista la cuenta eje en alguna otra cuenta PROAC
		SELECT status_cta INTO cStatus_cta
		FROM bdicheq:"informix".sc_proac
		WHERE cta_eje = pCliente2
		AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_proac WHERE cta_eje = pCliente2);

		IF	cStatus_cta = "1"  THEN
			LET vcodret = "90003";
			LET vctaclabe = "Cuenta Eje ya Tiene Cuenta PROAC";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
		IF	cStatus_cta = "2"  THEN

		END IF;
		IF	cStatus_cta = "3"  THEN
			LET vcodret = "90004";
			LET vctaclabe = "Bloqueada Cuenta PROAC";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
		IF	cStatus_cta = "4"  THEN
			LET vcodret = "90005";
			LET vctaclabe = "Cuenta Eje ya Tiene Reinscrita la Cuenta PROAC";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;

		SELECT COUNT(cta_eje) INTO iNCuentas
		FROM bdicheq:"informix".sc_proac
		WHERE cta_eje = pCliente2;
		LET iNCuentas = iNCuentas;

		--Obtener la secuencia maxima.
		SELECT 1,NVL(MAX(secuencia),0) INTO iExiste,sSecuencia
		FROM bdicheq:"informix".sc_proac
		WHERE cta_eje = pCliente2
		AND secuencia = (SELECT MAX(secuencia) FROM bdicheq:"informix".sc_proac WHERE cta_eje = pCliente2)
		AND status_cta <> '1';

		IF	iExiste = 1  THEN
			LET iExiste = 0;
			LET sSecuencia = sSecuencia +1;
		END IF;
		IF sSecuencia = "" THEN
			LET sSecuencia = 1;
		END IF;

		--Consulta los datos que va a heredar de la cuenta eje
		SELECT  CobraISr,proced_aperturacta,proced_mantenercta,monto_mensual,depositos_cantidad,
				depositos_monto,retiros_cantidad,retiros_monto,'PROAC_'|| TRIM(producto)
		INTO 	pcobraISr,pproced_aperturacta, pproced_mantenercta, pmonto_mensual, pdepositos_cantidad,
				pdepositos_monto, pretiros_cantidad, pretiros_monto,cProducto
		FROM bdicheq:"informix".sc_maechq Mae
		WHERE mae.cuenta = pCliente2;

		--Consulta y valida el producto para verificar si participa o no en el PROAC
		LET cProducto = TRIM(cProducto) ;
		SELECT valor INTO cRecValor FROM bdicheq:"informix".sc_param WHERE codparam = TRIM(cProducto);

		IF cRecValor IS NULL THEN
			LET vcodret = "90006";
			LET vctaclabe = "El Producto No Es Participante";
			RETURN vcodret,pcuenta,vctaclabe;
			LET iExiste = 0;
		END IF;
	END IF;

	--******************************			FIN PROAC			********************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************

	EXECUTE PROCEDURE "informix".valcteprod(pempresa,
								pnum_cte,
								pproducto)
	INTO vcodret;

	IF vcodret <> "000" THEN

		RETURN vcodret,pcuenta,vctaclabe;
	END IF;


	SELECT sIStema
	INTO vsistcap
	FROM bdinteg:"informix".si_sistema
	WHERE siglas = "SC";

	LET vsIStint = vsistcap;


	SELECT fecha_hoy
	INTO vfecha
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = pempresa;

	LET vultpagocap = vfecha;
	LET vultpagoint = vfecha;

	IF pcuenta IS NULL THEN
	   LET pcuenta = " ";
	END IF

--IF penvio_direcc = "0" THEN
--   LET pdirecc_envio = "1";
--END IF;


-- Valida la informacion de entrada
   IF pusuario       = "" OR
      psucursal      = "" OR
      pproducto      = "" OR
      pnum_cte       = "" OR
      pnum_cot       = "" OR
      pclase_cta     = "" OR
      ptipo_bca      = "" OR
      pejecutivo     = "" OR
      penvio_direcc  = "" OR
      pdirecc_envio  = "" OR
	  pproced_aperturacta 	= "" OR
	  pproced_mantenercta 	= "" OR
	  pmonto_mensual 		= "" OR
	  pdepositos_cantidad 	= "" OR
	  pdepositos_monto 		= "" OR
	  pretiros_cantidad 	= "" OR
	  pretiros_monto 		= "" THEN
		LET vcodret = "110";
		RETURN vcodret,pcuenta,vctaclabe;
   END IF;

    SELECT TRIM(valor)
	INTO vProdCrec
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pempresa
	AND codparam ="PRODCREC";

	IF vProdCrec IS NULL THEN
		LET vcodret = "106";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

	IF pproducto = vProdCrec THEN
		SELECT mtominape INTO vMtoMinimo
		FROM bdicheq:"informix".sc_producto
		WHERE empresa = pempresa
		AND producto = pproducto;

		IF vMtoMinimo > pmtoapertura THEN
			LET vcodret = "310";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF
	END IF

	SELECT 1 INTO vexiste FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pusuario;
	IF vexiste IS NULL THEN
		LET vcodret = "106";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Valida la clase de cuenta 1 = cuenta normal,2 = cuenta de cortesia
	IF pclase_cta != 1 AND pclase_cta != 2 THEN
		LET vcodret = "011";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Valida el regimen de firmas 1 = individual,2 = indIStinta,3 = mancomunada
	IF preg_firmas != "1" AND
		preg_firmas != "2" AND
		preg_firmas != "3" THEN
		LET vcodret = "112";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Validar el envio de direccion 0 = Domicilio,1 = Sucursal  3 = Sucursal s/imp
	IF penvio_direcc != "0" AND penvio_direcc != "1" AND
		penvio_direcc != "3" THEN
		LET vcodret = "113";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Valida el numero de cliente contra la tabla bdinteg:si_cliente
	SELECT es_fisica,tipo_cliente INTO ves_fisica,vtipo_cliente
	FROM bdinteg:"informix".si_cliente cl, bdinteg:"informix".si_tipper tp
	WHERE numcte = pnum_cte AND cl.tpo_persona = tp.tpo_persona;
	
	IF ves_fisica IS NULL THEN
		LET vcodret = "104";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Validar la direccion de envio
	IF penvio_direcc =  "0" THEN
		LET pdirecc_envio = pdirecc_envio;
		LET pnum_cte = pnum_cte;

		SELECT 1 INTO vexiste FROM bdinteg:"informix".si_direcciones
		WHERE numcte = pnum_cte AND secuencia = pdirecc_envio;
		
		IF vexiste IS NULL THEN
			LET vcodret = "130";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
	END IF;

	IF ves_fisica = "N" THEN
		--Se quito para que la informacion se guarde con la sucursal con la cual se da de alta la cuenta....HMBR
		--LET psucursal = "5001";
		LET vmarca_ret = "1";
	ELSE
		LET vmarca_ret = "0";
	END IF;
	
	IF pproducto = "2400" THEN
	   LET vmarca_ret = "1";
    END IF;	   

-- Valida la sucursal contra la tabla bdinteg:si_sucursales
	SELECT 1,plaza INTO vexiste,vplaza
	FROM bdinteg:"informix".si_sucursales
	WHERE empresa = pempresa AND sucursal = psucursal;
	
	IF vexiste IS NULL THEN
		LET vcodret = "102";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Validar el tipo de banca contra la tabla bdinteg:si_tpbanca
	SELECT 1 INTO vexiste FROM bdinteg:"informix".si_tpbanca
	WHERE banca = ptipo_bca;

	IF vexiste IS NULL THEN
		LET vcodret = "105";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Validar el ejecutivo contra la tabla bdinteg:si_ejecut
	SELECT 1 INTO vexiste FROM bdinteg:"informix".si_ejecut
	WHERE ejecutivo = pejecutivo;

	IF vexiste IS NULL THEN
		LET vcodret = "106";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Valida la Longitud a Considerar para el Numero de Cuenta
	SELECT valOR INTO vlongcta
	FROM bdicheq:"informix".sc_param
	WHERE empresa = pempresa AND codparam = "longcta";
	
	IF vlongcta IS NULL THEN
		LET vcodret = "107";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Valida el producto

   -- *************************************************************************
   -- La columna manten_valOR contiene el identIFicadOR de la cuenta axl'07
   -- La columna paga dividENDos identIFica si la cluenta maneja tasa variable

   -- *************************************************************************
	SELECT paga_interes,tipo_dias_calc,feciniape,fecfinape,paga_capital,
	fecpagocap,fecpagoint,divISa,pago_capital,plazomin,plazomax,
	tpper_valida,tpcte_valido, manten_valor, paga_dividENDo,
	tasa,val_chequeras
	INTO vpaga_interes,vpago_interes,vfeciniape,vfecfinape,vpaga_capital,
	vfecpagocap,vfecpagoint,vdivISa,vpago_capital,vplazomin,vplazomax,
	vtpper_valida,vtpcte_valido, vidcta, vtasavariable, vtasaprod, vAlchepro
	FROM bdicheq:"informix".sc_producto
	WHERE empresa = pempresa AND producto = TRIM(pproducto);
	
	IF vpaga_interes IS NULL THEN
		LET vcodret = "103";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;

-- Valida el tipo de persona permitido
  -- IF ves_fisica = "N" AND vtpper_valida = "1" THEN
    --  LET vcodret = "020";
     -- RETURN vcodret,pcuenta,vctaclabe;
  -- END IF

-- Valida el tipo de cliente permitido
	LET vtpcte_valido = RPAD(TRIM(vtpcte_valido),5,"X");
	LET vtipocte1 = SUBSTR(vtpcte_valido,1,1);
	LET vtipocte2 = SUBSTR(vtpcte_valido,2,1);
	LET vtipocte3 = SUBSTR(vtpcte_valido,3,1);
	LET vtipocte4 = SUBSTR(vtpcte_valido,4,1);
	LET vtipocte5 = SUBSTR(vtpcte_valido,5,1);

	IF vtipo_cliente <> vtipocte1 AND vtipo_cliente <> vtipocte2 AND
		vtipo_cliente <> vtipocte3 AND vtipo_cliente <> vtipocte4 AND
		vtipo_cliente <> vtipocte5 THEN
		LET vcodret = "021";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF

-- Valida el periodo de apertura de la cuenta
	LET vfecha_ini = mdy(MONTH(vfeciniape),DAY(vfeciniape),YEAR(vfecha));
	LET vfecha_fin = mdy(MONTH(vfecfinape),DAY(vfecfinape),YEAR(vfecha));

	IF vfecha_ini > vfecha THEN
		LET vfecha_ini = vfecha_ini - 1 UNITS YEAR;
	END IF

	IF vfecha_fin <= vfecha_ini THEN
		LET vfecha_fin = vfecha_fin + 1 UNITS YEAR;
	END IF

	IF vfecha BETWEEN vfecha_ini AND vfecha_fin THEN

	ELSE
		LET vcodret = "402";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF

-- Valida pago de capital
	IF vpaga_capital = "S" THEN
		IF pinstcap <> "" THEN
			SELECT sIStema,requiere_cta INTO vsistcap,vrequiere_cta
			FROM bdicheq:"informix".sc_instrucc
			WHERE empresa = pempresa AND instrucc = pinstcap;
			
			IF vrequiere_cta = "S" THEN
				SELECT siglas INTO vsiglas
				FROM bdinteg:"informix".si_sistema
				WHERE sIStema = vsistcap;

				IF vsiglas = "SC" THEN
					SELECT divISa INTO vdivISacta
					FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
					WHERE mc.empresa = pempresa AND cuenta = pcuentacap 
					AND pr.empresa = mc.empresa AND pr.producto = mc.producto;
					
					IF vdivISacta IS NULL THEN
						LET vcodret = "100";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF

					IF vdivISacta <> vdivISa THEN
						LET vcodret = "905";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF
				END IF
			ELSE
				LET pcuentacap = " ";
			END IF
		END IF
	END IF

-- Valida pago de interes
	IF vpaga_interes = "S" THEN
		IF pinstint <> "" THEN


			SELECT sIStema,requiere_cta INTO vsIStint,vrequiere_cta
			FROM bdicheq:"informix".sc_instrucc
			WHERE empresa = pempresa AND instrucc = pinstint;
			
			IF vrequiere_cta = "S" THEN
				SELECT siglas INTO vsiglas
				FROM bdinteg:"informix".si_sistema
				WHERE sIStema = vsIStint;

				IF vsiglas = "SC" THEN
					SELECT divISa INTO vdivISacta
					FROM bdicheq:"informix".sc_maechq mc, bdicheq:"informix".sc_producto pr
					WHERE mc.empresa = pempresa AND cuenta = pcuentaint AND
					pr.empresa = mc.empresa AND pr.producto = mc.producto;
					IF vdivISacta IS NULL THEN
						LET vcodret = "100";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF;
					IF vdivISacta <> vdivISa THEN
						LET vcodret = "905";
						RETURN vcodret,pcuenta,vctaclabe;
					END IF;
				END IF;
			ELSE
				LET pcuentaint = " ";
			END IF;
		END IF;
	END IF;

	-- Determina numero de cuenta

   -- ******************************************
   -- Extra consecutivo de acuerdo al producto *
   -- ******************************************
   IF pproducto <= '2000' THEN
       LET vparamsigcta = "signumcta" || TRIM(vidcta);
   ELSE
        LET vparamsigcta = "signumcta" || SUBSTR(pproducto, 1, 2);
    END IF;

	IF pcuenta = " " THEN
		SELECT valOR
		INTO vsignumcta
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pempresa
		AND codparam = TRIM(vparamsigcta);
		IF vsignumcta IS NULL THEN
			LET vcodret = "933";
			RETURN vcodret,pcuenta,vctaclabe;
		END IF;
		LET pcuenta = vsignumcta;
		LET vsignumcta = vsignumcta + 1;

		UPDATE bdicheq:"informix".sc_param
		SET valor = vsignumcta
		WHERE empresa = pempresa
		AND codparam =  TRIM(vparamsigcta);
		
	   LET vdIFerencia = vlongcta - LENGTH(pcuenta) - 3;

		IF vdIFerencia > 0 THEN
			FOR i = 1 TO vdIFerencia
				LET pcuenta = "0" || pcuenta; --,vctaclabe; MEL...
			END FOR;
		END IF

	IF pproducto <= '2000' THEN
		LET pcuenta = "1" || TRIM(vidcta) || TRIM(pcuenta);
    ELSE
        LET pcuenta = SUBSTR(pproducto, 1, 2) || TRIM(pcuenta);
	END IF;	

    CALL "informix".digver11(pcuenta)
		RETURNING vcodret,vdigverif;
		LET pcuenta = TRIM(pcuenta)||vdigverif;
	END IF

--Se valida que la longitud de la cuenta sea la correcta y que solo sean nÃºmeros
	
	IF length(pcuenta) = vlongcta AND bdinteg:"informix".val_num(pcuenta) THEN


			SELECT 1 INTO vexiste
			FROM bdicheq:"informix".sc_maechq WHERE empresa = pempresa AND cuenta = pcuenta;
			IF vexiste IS NOT NULL THEN
				LET vcodret = "405";
				RETURN vcodret,pcuenta,vctaclabe;
			END IF;

		 -- Genera Cuenta CLABE
			IF pproducto = vProdCrec THEN
				LET vctaclabe = "";
			ELSE


				CALL "informix".ctaclabe(pempresa,pcuenta,psucursal)
				RETURNING vcodret,vctaclabe;
				IF vcodret <> "000" THEN
					LET vcodret = "170";
					RETURN vcodret,pcuenta,vctaclabe;
				END IF;
			END IF;

			--06/03/2008
			--Martha Aguirre

			--Se extraen los datos procedencia de la apaertura, procedencia para mantener la cuenta,, monto mensual, cantidad de depositos,
			--cantidad de depositos, cantidad de retiros, monto de retiros

			IF pproducto = "1100" THEN
				SELECT proced_aperturacta, proced_mantenercta, monto_mensual, depositos_cantidad,
				depositos_monto, retiros_cantidad, retiros_monto
				INTO  pproced_aperturacta,pproced_mantenercta, pmonto_mensual,pdepositos_cantidad,
				pdepositos_monto,pretiros_cantidad,pretiros_monto
				FROM bdicheq:"informix".sc_maechq
				WHERE cuenta = pcuentacap AND num_cte = pnum_cte;
			END IF;
			INSERT INTO bdicheq:"informix".sc_maechq
			VALUES (pempresa,pcuenta,psucursal,vplaza,pproducto,
			pnum_cte,"1"," ",0,"N",vfecha," ",0,0," "," ",
			0,pmtoapertura," "," ",0,0,"0"," "," ",0,0,0,0,0,0,0,0,0,
			0,0,0,0,vmarca_ret,pdirecc_envio,0,0,0," "," ",0,"",
			"",vultpagocap,vultpagoint,pplazo,pcobraISr,
			pproced_aperturacta,pproced_mantenercta,
			pmonto_mensual,pdepositos_cantidad,
			pdepositos_monto,pretiros_cantidad,pretiros_monto,
			vctaclabe);
			
			INSERT INTO bdicheq:"informix".sc_maenoc
			VALUES(pempresa,pcuenta,"00",pclase_cta,preg_firmas,ptipo_bca,
			pejecutivo,penvio_direcc,0,0," ",0," "," ",0,0,0,0,
			0,0,0,0,pusuario,vfecha," "," ",0,0,vpago_interes,
			" ",0,0,0,0);
	ELSE
		LET vcodret = "131";
		RETURN vcodret,pcuenta,vctaclabe;
	END IF;
   --******************************			PROAC			************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************

	IF cPROACProducto = TRIM(pproducto) THEN
		CALL "informix".sp_PROAC_Calc_ProximoAnio(vfecha) RETURNING vcodret2,dFecha_siganio,cFecFormat1,cFecFormat2 ;

		IF iNCuentas >= 1 THEN
			UPDATE bdicheq:"informix".sc_proac SET status_cta = '4' WHERE cta_eje = pCliente2 AND secuencia = sSecuencia -1 ;
		END IF;

		INSERT INTO bdicheq:"informix".sc_proac
		(cuenta,num_cte,cta_eje,secuencia,status_cta,fecha_alta,fecha_canc,sucursal,saldo,prem_proac)
		VALUES
		(pcuenta,pnum_cte,pCliente2,sSecuencia,1,vfecha,dFecha_siganio,pSucursal,0.00,0.00);

		SELECT cuenta_clabe INTO vctaclabe
		FROM bdicheq:"informix".sc_maechq
		WHERE empresa = '001'
		AND cuenta = pcuenta;

	END IF;

	--******************************		FIN PROAC		****************************************
	--**********************************************************************************************
	--**********************************************************************************************
	--**********************************************************************************************

	IF pinstcap <> "" THEN

		INSERT INTO bdicheq:"informix".sc_maeinstrucc
		VALUES(pempresa,pcuenta,"C",pinstcap,vsistcap,pcuentacap,"N");
	END IF

	IF pinstint <> "" THEN

		INSERT INTO bdicheq:"informix".sc_maeinstrucc
		VALUES(pempresa,pcuenta,"I",pinstint,vsIStint,pcuentaint,"N");
	END IF

	IF vProdCrec = pproducto THEN

		INSERT INTO bdicheq:"informix".sc_maeinstrucc
		VALUES(pempresa,pcuenta,"R",pformaapert,"01",pcuentacap,"N");
	END IF

	-- Genera comISiones pOR apertura en caso de que exIStan
	CALL "informix".gencomape(pempresa,pcuenta,pproducto) RETURNING vcodret;

	--  LLAMADO AL PROCESO QUE DA DE ALTA LA CUENTA EN LOS INDICADORES
	EXECUTE PROCEDURE "informix".sp_insertar_fila_indicador(pcuenta,vfecha,pproducto,psucursal)
	INTO vcodret3,vdesccodret3;

/*
0555
0561
0785
*/

	IF ((psucursal='0555') or (psucursal='0561') or (psucursal='0785')) then
		update sc_maechq set marca_ret=1 where empresa=pempresa and cuenta=pcuenta and sucursal=psucursal;
	end if;
	
	SELECT LIMIT 1 correo_elec --Obtiene el correo que del cliente
	INTO correoCli 
	FROM bdinteg:"informix".si_correos 
	WHERE numcte=pnum_cte and tipo_correo=1 and status_correo='A';	
	SELECT LIMIT 1 nombre INTO nombreCuenta FROM bdicheq:"informix".sc_producto WHERE producto = pproducto;
	
	IF NVL(correoCli,'') <> '' THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','MAIL_CONT',TRIM(pnum_cte),'','','1','CONTRATACION',TRIM(nombreCuenta),'','','','','','','','',TRIM(correoCli),'',1,0,0,0,0,'','') INTO cCodRetSp1;
	ELSE
		SELECT LIMIT 1 telefono  --Obtiene el numero de celular del cliente
		INTO celularCli 
		FROM bdinteg:"informix".si_telefonos_actual 
		WHERE numcte = pnum_cte	AND tipo_tel='2' AND status_tel='A'; 
		
		IF NVL(celularCli,'') <> '' THEN
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_CONT',TRIM(pnum_cte),'','','1','CONTRATACION',TRIM(nombreCuenta),'','','','','','','','','',TRIM(celularCli),1,0,0,0,0,'','') INTO cCodRetSp2; -------- NOTIFICACION DE CUALQUIER PRODUCTO O SERVICIO (SMS)
		END IF;
	END IF;

RETURN vcodret,pcuenta,vctaclabe;
END
END procedure
DOCUMENT
'DESCRIPCION: Se le agrega un llamado al sp valcteprod donde este sp valida la edad del cliente en cuestion',
'MODIFICO: Jose Angel Rodriguez Rodriguez',
'FECHA: 26/01/2010',
'VERSION: 20100126.1828',
'BD: BDICHEQ',
'MODIFICO: ABIGAIL VASAVILBAZO CAÃ?EDO',
'MODIFICACION: SE AGREGA LA FUNCIONALIDAD DE LAS CUENTAS PROAC LAS CUALES SE DETERMINÃ? ESTE PROCEDIMIENTO',
			  'COMO SU ALTA DE CLIENTE',
'FECHA: NOVIEMBRE 2010',
'VERSION: 20101103.1642',
'MODIFICO: HÃ©ctor Manuel Bojorquez Ruelas',
'MODIFICACION: Se quita codifo duro que iguala la sucursal a 5001 cuando el tipode cliente es Moral',
'FECHA: 23 Marzo 2012',
'VERSION: 20120323.1542';

CREATE PROCEDURE "informix".sp_consulta_info_soc_tasf(p_empresa char(3))
RETURNING   CHAR(5);

DEFINE v_c_vcomienza       SMALLINT;
DEFINE ven_transacc        SMALLINT;
DEFINE v_c_vcontador       INTEGER;

DEFINE vsqlerr              INTEGER;
DEFINE vcodret              CHAR(5);
			  
DEFINE   v_aniomes      	CHAR(6); 
DEFINE   v_num_serial   	CHAR(20); 
DEFINE   v_folio_suc    	CHAR(16);
DEFINE   v_sucursal     	CHAR(4);
DEFINE   v_usuario      	CHAR(8);
DEFINE   v_fech_alt     	DATE;
DEFINE   v_fech_val     	DATE;
DEFINE   v_fech_hor     	DATETIME HOUR to FRACTION(3);
DEFINE   v_transacc     	CHAR(4);
DEFINE   v_suc_cuen     	CHAR(4);
DEFINE   v_producto     	CHAR(4);
DEFINE   v_empresa      	CHAR(3);
DEFINE   v_cuenta       	CHAR(20);
DEFINE   v_causa_dev    	CHAR(2);
DEFINE   v_num_cheq     	INTEGER;
DEFINE   v_monto_tot    	MONEY;
DEFINE   v_firme        	MONEY;
DEFINE   v_en_sbc       	MONEY;
DEFINE   v_remesas      	MONEY;
DEFINE   v_dias_ret     	SMALLINT;
DEFINE   v_cancelad     	CHAR(1);
DEFINE   v_edo_cta      	CHAR(1);
DEFINE   v_sdo_cuenta   	MONEY;
DEFINE   v_transacc_suc 	CHAR(4);
DEFINE   v_referencia   	CHAR(40);
DEFINE   v_tasa_aplicada	DECIMAL(9,6);
DEFINE   v_num_tarjeta  	CHAR(16);
DEFINE   v_usuautoriza  	CHAR(8);
DEFINE   v_referencia_23    CHAR(23);
DEFINE   v_descripcion	    CHAR(50);
DEFINE   v_cuenta_cargo	    CHAR(60);
DEFINE   v_cuenta_abono	    CHAR(60);


LET vsqlerr      = 0; 
LET vcodret      = "000";

LET v_c_vcomienza        = -1;
LET ven_transacc         = 0;
LET v_c_vcontador        = 0;


BEGIN
	 ON EXCEPTION SET vsqlerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/desk_info_op.err";
	 	    TRACE ON;
            IF vsqlerr <> 0 THEN
               LET vcodret = vsqlerr;
			   IF ven_transacc = 1 THEN
                  ROLLBACK WORK;
               END IF;
            RETURN vcodret;
            END IF;
     END EXCEPTION;
	
     --SET DEBUG FILE TO '/informix/rsv/descarga/err.txt';
	 --TRACE ON;
	
	  SET ISOLATION TO DIRTY READ;
	  	  		
      FOREACH WITH HOLD
	        -- Realiza la consulta principal de informacion 
	        SELECT a.fech_alt,    a.aniomes,     a.num_serial,    a.folio_suc,   a.sucursal,     a.usuario,                        a.fech_val,       a.fech_hor,
                   a.transacc,    a.suc_cuen,    a.producto,      a.empresa,     a.cuenta,       a.causa_dev,    a.num_cheq,       a.monto_tot,      a.firme,
                   a.en_sbc,      a.remesas,     a.dias_ret,      a.cancelad,    a.edo_cta,      a.sdo_cuenta,   a.transacc_suc,   a.referencia,     a.tasa_aplicada, 
				   a.num_tarjeta, a.usuautoriza, a.referencia_23, a.descripcion, a.cuenta_cargo, a.cuenta_abono
			  INTO v_fech_alt,    v_aniomes,     v_num_serial,    v_folio_suc,   v_sucursal,     v_usuario,                        v_fech_val,       v_fech_hor,
                   v_transacc,    v_suc_cuen,    v_producto,      v_empresa,     v_cuenta,       v_causa_dev,    v_num_cheq,       v_monto_tot,      v_firme,
                   v_en_sbc,      v_remesas,     v_dias_ret,      v_cancelad,    v_edo_cta,      v_sdo_cuenta,   v_transacc_suc,   v_referencia,     v_tasa_aplicada, 
				   v_num_tarjeta, v_usuautoriza, v_referencia_23, v_descripcion, v_cuenta_cargo, v_cuenta_abono
			  FROM tmp_mov a
			  			  
			   -- Abre la transaccion 
			   IF (v_c_vcomienza = -1) THEN
                   LET v_c_vcomienza = 0;
                   LET ven_transacc = 1;
                   BEGIN WORK;
               END IF;

              --Inserta regristro 
             INSERT INTO sc_movs2402  VALUES( v_fech_alt,    v_aniomes,     v_num_serial,    v_folio_suc,   v_sucursal,     v_usuario,      v_fech_alt,       v_fech_val,       v_fech_hor,
                                              v_transacc,    v_suc_cuen,    v_producto,      v_empresa,     v_cuenta,       v_causa_dev,    v_num_cheq,       v_monto_tot,      v_firme,
                                              v_en_sbc,      v_remesas,     v_dias_ret,      v_cancelad,    v_edo_cta,      v_sdo_cuenta,   v_transacc_suc,   v_referencia,     v_tasa_aplicada, 
				                              v_num_tarjeta, v_usuautoriza, v_referencia_23, v_descripcion, v_cuenta_cargo, v_cuenta_abono, ' ',               ' ');  

			   LET v_c_vcontador = v_c_vcontador + 1;
			   --Realiza commit cada 1000 registros 
			     IF (v_c_vcontador >= 1000) THEN
                    LET v_c_vcontador = 0;
                    COMMIT WORK;
                    BEGIN WORK;
                END IF;  
				
	   END FOREACH;
	   --Si la transaccion esta abierta realiza el commit
	    IF  ven_transacc = 1 THEN
            LET ven_transacc = 0;
            COMMIT WORK;
        END IF;
				  
RETURN  vcodret;
END; 
END PROCEDURE;