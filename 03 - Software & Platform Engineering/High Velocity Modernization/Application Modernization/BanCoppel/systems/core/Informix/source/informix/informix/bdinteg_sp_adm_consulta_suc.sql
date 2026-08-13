CREATE PROCEDURE "informix".sp_adm_consulta_suc(e_mac CHAR(12))  
RETURNING CHAR(5),CHAR(4),CHAR(2),CHAR(3),CHAR(40),CHAR(40),CHAR(40),CHAR(2),CHAR(3),CHAR(3),CHAR(3),INTEGER,CHAR(2),CHAR(60),CHAR(30),CHAR(20);

    DEFINE cod_ret           CHAR(5);
    DEFINE s_paseCont        CHAR(5);
    DEFINE sql_err           INTEGER ;

    DEFINE s_sucursal        CHAR(4);
    DEFINE s_area            CHAR(2);
    DEFINE s_depto           CHAR(3);
    DEFINE s_nombre          CHAR(40);
    DEFINE s_direccion1      CHAR(40);
    DEFINE s_direccion2      CHAR(40);
    DEFINE s_estado          CHAR(2);
    DEFINE s_ciudad          CHAR(3);
    DEFINE s_pais            CHAR(3);
    DEFINE s_plaza           CHAR(3);
    DEFINE s_dias_laborables INTEGER;
    DEFINE s_tpo_sucursal    CHAR(2);

    DEFINE s_fecha           DATE;

    DEFINE s_ciudad_n         CHAR(60);
    DEFINE s_pais_n           CHAR(20);
    DEFINE s_estado_n         CHAR(30);

    LET cod_ret           = "00000";
    LET s_sucursal        = "";
    LET s_area            = "";
    LET s_depto           = "";

    LET s_nombre          = "";
    LET s_direccion1      = "";
    LET s_direccion2      = "";
    LET s_estado          = "";
    LET s_ciudad          = "";
    LET s_pais            = "";
    LET s_plaza           = "";
    LET s_dias_laborables = "";
    LET s_tpo_sucursal    = "";
    LET s_ciudad_n        = "";
    LET s_pais_n          = "";
    LET s_estado_n        = "";

    --SET DEBUG FILE TO '/informix/sp_adm_consulta_suc.out';
    --TRACE ON;    

BEGIN
   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
           RETURN  cod_ret,s_sucursal,s_area,s_depto, s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal,s_ciudad_n,s_estado_n,s_pais_n;
      END IF ;
   END EXCEPTION ;

   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;	

	IF NVL(e_mac,'') =='' THEN 
	 	  LET cod_ret = '02000'; -- No contiene Dato de MAC
         RETURN  cod_ret,s_sucursal,s_area,s_depto, s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal,s_ciudad_n,s_estado_n,s_pais_n;
	END IF;	
	
    SELECT sucursal,area,departamento
    INTO s_sucursal,s_area,s_depto
	FROM bdinteg:"informix".si_sucursalesmaquina
	WHERE mac = e_mac;

    IF NVL(s_sucursal,'') =='' THEN 
	 	  LET cod_ret = '02001'; -- No se encontro Sucursal Relacionada
         RETURN  cod_ret,NVL(s_sucursal,''), NVL(s_area,''),
            NVL( s_depto,''), s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,  NVL(s_dias_laborables,0),s_tpo_sucursal,
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
	END IF;

    SELECT fecha_hoy
    INTO s_fecha
    FROM bdinteg:"informix".si_fechas;
    
   /* EXECUTE PROCEDURE bdisuc:sp_valida_pasecont(s_sucursal, s_fecha) INTO s_paseCont;
	
    IF s_paseCont = '00000' THEN
         LET cod_ret = '02500'; -- Se tiene ya pase contable
         RETURN  cod_ret,NVL(s_sucursal,''), NVL(s_area,''),
            NVL( s_depto,''), s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,  NVL(s_dias_laborables,0),s_tpo_sucursal,
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
    END IF;*/

    SELECT  suc.nombre,ptf.calle||' NUM '||ptf.num_ext as direccion1,NVL('COL '||loc.desc_colonia||' C.P. '||loc.cp, '') as direccion2, ptf.cve_estado, ptf.cve_ciudad, ptf.cve_pais, suc.plaza, suc.dias_laborables,suc.tpo_sucursal
    INTO  s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal
    FROM    bdinteg: "informix".si_ptf ptf
    INNER JOIN bdinteg:"informix".si_sucursales suc ON ptf.id_ptf =  suc.sucursal AND ptf.tipo = suc.tipo
    LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.cve_estado = ptf.cve_estado AND 
                                                          loc.cve_mun = ptf.cve_mun AND
                                                          loc.cve_localidad_cnbv = ptf.cve_localidad AND 
                                                          loc.cve_col = ptf.cve_col )
    WHERE ptf.id_ptf =s_sucursal AND ptf.tipo = 'S';

    --LEFT OUTER JOIN "informix".si_localidades loc ON ( loc.id > 0 AND
    --                                                      loc.cp = loc.cp AND
    --                                                      loc.cve_estado = ptf.cve_estado AND
    --                                                      loc.cve_mun = ptf.cve_mun AND
    --                                                      loc.cve_localidad_cnbv = ptf.cve_localidad AND
    --                                                      loc.cve_col = ptf.cve_col )
    --WHERE ptf.id_ptf =s_sucursal AND ptf.tipo = 'S';
    

    /*SELECT  suc.nombre,suc.direccion1,suc.direccion2, suc.estado, suc.ciudad, suc.pais, suc.plaza, suc.dias_laborables,suc.tpo_sucursal
    INTO  s_nombre,s_direccion1,s_direccion2,s_estado,s_ciudad,s_pais, s_plaza,s_dias_laborables,s_tpo_sucursal
	FROM 	bdinteg:"informix".si_sucursales suc
    WHERE suc.sucursal =s_sucursal;*/

    SELECT nombre INTO s_pais_n
    FROM SI_paises WHERE pais =s_pais;

    SELECT nombre INTO s_ciudad_n
    FROM si_ciudades WHERE estado=s_estado AND ciudad =s_ciudad;

    SELECT nombre  INTO s_estado_n
    FROM si_estados WHERE estado =s_estado;


	RETURN  cod_ret,NVL(s_sucursal,''),
            NVL(s_area,''),
            NVL( s_depto,''),
            NVL( s_nombre,''),
            NVL(s_direccion1,''),
            NVL(s_direccion2,''),
            NVL(s_estado,''),
            NVL(s_ciudad,''),
            NVL(s_pais,''), 
            NVL(s_plaza,''),
            NVL(s_dias_laborables,0),
            NVL(s_tpo_sucursal,''),
            NVL(s_ciudad_n,''),
            NVL(s_estado_n,''),
            NVL(s_pais_n,'');
END
END PROCEDURE
DOCUMENT
'Proceso que consulta la mac este registrada en la sucursal',
'BD    : BDINTEG';

CREATE PROCEDURE "informix".sp_genera_folioactivacion_bpi ()
RETURNING CHAR(5),CHAR(12);

	DEFINE codRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE folioClaro CHAR(12);
    DEFINE cFolio0 CHAR(1);
    DEFINE cFolio1 CHAR(1);
    DEFINE cFolio2 CHAR(1);
    DEFINE cFolio3 CHAR(1);
    DEFINE cFolio4 CHAR(1);
    DEFINE cFolio5 CHAR(1);
    DEFINE cFolio6 CHAR(1);
    DEFINE cFolio7 CHAR(1);
    DEFINE cFolio8 CHAR(1);
    DEFINE cFolio9 CHAR(1);
    DEFINE cFolio10 CHAR(1);
    DEFINE cFolio11 CHAR(1);
    DEFINE iFolio0 INTEGER;
    DEFINE iFolio1 INTEGER;
    DEFINE iFolio2 INTEGER;
    DEFINE iFolio3 INTEGER;
    DEFINE iFolio4 INTEGER;
    DEFINE iFolio5 INTEGER;
    DEFINE iFolio6 INTEGER;
    DEFINE iFolio7 INTEGER;
    DEFINE iFolio8 INTEGER;
    DEFINE iFolio9 INTEGER;
    DEFINE iFolio10 INTEGER;
    DEFINE iFolio11 INTEGER;
    DEFINE iAlphaNum0 INTEGER;
    DEFINE iAlphaNum1 INTEGER;
    DEFINE iAlphaNum2 INTEGER;
    DEFINE iAlphaNum3 INTEGER;
    DEFINE iAlphaNum4 INTEGER;
    DEFINE ArregloDetiempo0 CHAR(20);
    DEFINE ArregloDetiempo1 CHAR(20);
    DEFINE ArregloDetiempo2 CHAR(20);
    DEFINE sFecha CHAR(10); 
    DEFINE TestHora INT8; 
    DEFINE TiempoRestar INT8; 
    DEFINE sHora CHAR(10); 
    DEFINE iHoraSumada INT8; 
    DEFINE PrimerValorHora CHAR(20);
    DEFINE SegundoValorHora CHAR(20); 
    DEFINE TercerValorHora INT8;
    DEFINE Intervalo INTEGER;
    DEFINE iRegreso INTEGER;
    DEFINE i INTEGER; 
    DEFINE sNumero CHAR(12);
    DEFINE dValor DECIMAL(10,2);
    DEFINE FechaSistema DATETIME YEAR TO DAY;
    DEFINE Tiempo DATETIME HOUR TO SECOND;
    DEFINE random CHAR(2);


    LET FechaSistema = CURRENT;
    LET Tiempo = CURRENT;
	LET codRet = '00000';
    LET viSqlErr = 0;
    LET folioClaro = '';

    LET cFolio0 = '';
    LET cFolio1 = '';
    LET cFolio2 = '';
    LET cFolio3 = '';
    LET cFolio4 = '';
    LET cFolio5 = '';
    LET cFolio6 = '';
    LET cFolio7 = '';
    LET cFolio8 = '';
    LET cFolio9 = '';
    LET cFolio10 = '';
    LET cFolio11 = '';

    LET iFolio0 = 0;
    LET iFolio1 = 0;
    LET iFolio2 = 0;
    LET iFolio3 = 0;
    LET iFolio4 = 0;
    LET iFolio5 = 0;
    LET iFolio6 = 0;
    LET iFolio7 = 0;
    LET iFolio8 = 0;
    LET iFolio9 = 0;
    LET iFolio10 = 0;
    LET iFolio11 = 0;

    LET iAlphaNum0 = 0;
    LET iAlphaNum1 = 0;
    LET iAlphaNum2 = 0;
    LET iAlphaNum3 = 0;

    LET ArregloDetiempo0 = '';
    LET ArregloDetiempo1 = '';
    LET ArregloDetiempo2 = '';

    LET sFecha = '';
    LET TestHora = 0;
    LET TiempoRestar = 0;
    LET sHora = '';
    LET iHoraSumada = 0;
    LET PrimerValorHora = ''; 
    LET SegundoValorHora = '';
    LET TercerValorHora = 0;
    LET Intervalo = 0;
    LET iRegreso = 0;
    LET i = 0;
    LET sNumero = '';
    LET dValor = 0.00;
    LEt random = '';

--SET DEBUG FILE TO "/informix/JuanRivera/Traces/sp_genera_folioactivacion_bpi.out";
--TRACE ON;	
	 
    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    BEGIN
        ON EXCEPTION SET viSqlErr
            IF viSqlErr <> 0 then
                LET codRet = viSqlErr;
                RETURN codRet, folioClaro;
            END IF;	
        END EXCEPTION; 
        

        --Inicia generaciÃÂ³n de folio de activaciÃÂ³n

        LET PrimerValorHora = '0';
        LET sHora = SUBSTR(CAST(Tiempo AS CHAR(10)), 1, 2);
        IF CAST(sHora AS INTEGER) >= 20 THEN
            LET sHora = '0' || SUBSTR(CAST(Tiempo AS CHAR(10)), 8, 1);
        END IF;
        LET TestHora = CAST(sHora AS INT8) * 60;
        LET TercerValorHora = TestHora;

        LET TestHora = TercerValorHora * 60;

        LET sHora = SUBSTR(CAST(Tiempo AS CHAR(10)), 4, 2);
        LET TestHora = TestHora + CAST(sHora AS INTEGER) * 60;

        LET sHora = SUBSTR(CAST(Tiempo AS CHAR(10)), 7, 2);
        LET TestHora = TestHora + CAST(sHora AS INTEGER);
        
        
        IF TestHora <= 25200 THEN
            LET iHoraSumada = TestHora;
            LET dValor = TestHora;
        ELSE
            LET iHoraSumada = TestHora - 25200;
            LET TestHora = TestHora - 25200;
            LET dValor = TestHora;
        END IF;

        IF TestHora >= 46655 THEN
             LET TiempoRestar = TestHora - 46655;
             LET dValor = dValor - TiempoRestar;
        END IF;


        LET dValor = dValor / 1296;
        LET PrimerValorHora = CAST(dValor AS CHAR(20));
        LET PrimerValorHora = SUBSTR(PrimerValorHora, 1, 2); --PRIMER VALOR
        
        IF SUBSTR(PrimerValorHora, 2, 1) = '.' THEN
            LET PrimerValorHora = SUBSTR(PrimerValorHora, 1, 1);
        END IF;

        LET TestHora = iHoraSumada - (CAST(PrimerValorHora AS INTEGER) * 1296);
        IF SUBSTR(TestHora, 1, 1) = '-' THEN
            LET TestHora = SUBSTR(TestHora, 2, 1);
        END IF;
        LET Intervalo = TestHora;
        LET dValor = TestHora / 36;
        LET SegundoValorHora = CAST(dValor AS CHAR(20));
        LET SegundoValorHora = SUBSTR(SegundoValorHora, 1, 2); --SEGUNDO VALOR
        LET TercerValorHora = Intervalo - (CAST(SegundoValorHora AS INTEGER) * 36); --TERCER VALO
        

        IF (CAST(PrimerValorHora AS INTEGER) >= 0 AND CAST(PrimerValorHora AS INTEGER) <= 9) THEN
            LET ArregloDetiempo0 = ASCII(PrimerValorHora);
            LET i = i;
        ELSE
            LET PrimerValorHora = CAST(PrimerValorHora AS INTEGER) - 9 + 64;
            LET i = i;
            LET ArregloDetiempo0 = PrimerValorHora;
        END IF;
        IF (CAST(SegundoValorHora AS INTEGER) >= 0 AND CAST(SegundoValorHora AS INTEGER) <= 9) THEN
            LET i = i + 1;
            LET ArregloDetiempo1 = ASCII(SegundoValorHora);
        ELSE
            LET SegundoValorHora = CAST(SegundoValorHora AS INTEGER) - 9 + 64;
            LET i = i + 1;
            LET ArregloDetiempo1 = SegundoValorHora;
        END IF;
        IF (CAST(TercerValorHora AS INTEGER) >= 0 AND CAST(TercerValorHora AS INTEGER) <= 9) THEN
            LET i = i + 1;
            LET ArregloDetiempo2 = ASCII(CAST(TercerValorHora AS CHAR));
        ELSE
            LET TercerValorHora = CAST(TercerValorHora AS INTEGER) - 9 + 64;
            LET i = i + 1;
            LET ArregloDetiempo2 = CAST(TercerValorHora AS CHAR(20));
        END IF;
        

        LET sFecha = '';
        LET sFecha = SUBSTR(FechaSistema, 9, 2) || SUBSTR(FechaSistema, 6, 2) || SUBSTR(FechaSistema, 3, 2);

        LET i = 0;

        --EXECUTE PROCEDURE bdinteg:"informix".sp_random() INTO random;
        --LET folioClaro = random || SUBSTR(random, -2);
        --LET random = SUBSTR(random, -2);

        WHILE i <= 5
            --IF random >= 0 AND random <= 86 THEN
                --LET random = random + 3;
            --ELSE
                --LET random = random - 85;
            --END IF;

            SELECT contador INTO random FROM bdibpi:"informix".contador_folio;
            IF random  <> '' AND random <> 'NULL' THEN
                IF random >= 0 AND random <= 89 THEN
                    LET random = random + 1;
                    UPDATE bdibpi:"informix".contador_folio SET contador = random;
                ELSE
                    LET random = random - 89;
                    UPDATE bdibpi:"informix".contador_folio SET contador = random;
                END IF;
            ELSE
                INSERT INTO bdibpi:"informix".contador_folio(contador)
                VALUES(0);
                LET random = 0;
            END IF;

            IF (random > 65 AND random < 90) OR (random > 47 AND random < 58) THEN
                IF i = 0 THEN
                    LET iAlphaNum0 = random;
                ELIF i = 1 THEN
                    LET iAlphaNum1 = random;
                ELIF i = 2 THEN
                    LET iAlphaNum2 = random;
                ELIF i = 3 THEN
                    LET iAlphaNum3 = random;
                ELIF i = 4 THEN
                    LET iAlphaNum4 = random;
                END IF;
                LET i = i + 1;
            END IF;
            IF random >= 0 And random <= 9 THEN
                IF i = 0 THEN
                    LET iAlphaNum0 = ASCII(CAST(random AS CHAR));
                ELIF i = 1 THEN
                    LET iAlphaNum1 = ASCII(CAST(random AS CHAR));
                ELIF i = 2 THEN
                    LET iAlphaNum2 = ASCII(CAST(random AS CHAR));
                ELIF i = 3 THEN
                    LET iAlphaNum3 = ASCII(CAST(random AS CHAR));
                ELIF i = 4 THEN
                    LET iAlphaNum4 = ASCII(CAST(random AS CHAR));
                END IF;
                LET i = i + 1;
            END IF;
        END WHILE;
        


        

        LET iFolio0 = CAST(SUBSTR(sFecha, 1, 1) AS INTEGER);
        IF CAST(ArregloDetiempo0 AS INTEGER) >= 65 THEN
            LET iFolio1 = CAST(ArregloDetiempo0 AS INTEGER) - 64;
        ELSE
            LET iFolio1 = CHR(ArregloDetiempo0);
        END IF;
        LET iFolio2 = CAST(SUBSTR(sFecha, 5, 1) AS INTEGER);
        IF iAlphaNum2 > 65 THEN
            LET iFolio3 = iAlphaNum2 - 64;
        ELSE
            LET iFolio3 = CHR(iAlphaNum2);
        END IF;
        LET iFolio4 = CAST(SUBSTR(sFecha, 2, 1) AS INTEGER);
        IF ArregloDetiempo1 >= 65 THEN
            LET iFolio5 =  CAST(ArregloDetiempo1 AS INTEGER) - 64;
        ELSE
            LET iFolio5 = CHR(ArregloDetiempo1);
        END IF;
        LET iFolio6 = CAST(SUBSTR(sFecha, 3, 1) AS INTEGER);
        IF iAlphaNum4 > 65 THEN
            LET iFolio7 = iAlphaNum4 - 64;
        ELSE
            LET iFolio7 = CHR(iAlphaNum4);
        END IF;
        LET iFolio8 = CAST(SUBSTR(sFecha, 6, 1) AS INTEGER);
        IF ArregloDetiempo2 >= 65 THEN
            LET iFolio9 = CAST(ArregloDetiempo2 AS INTEGER) - 64;
        ELSE
            LET iFolio9 = CHR(ArregloDetiempo2);
        END IF;
        LET iFolio10 = CAST(SUBSTR(sFecha, 4, 1) AS INTEGER);

        LET iFolio11 = iFolio11 + (iFolio0 * 1);
        LET iFolio11 = iFolio11 + (iFolio1 * 5);
        LET iFolio11 = iFolio11 + (iFolio2 * 1);
        LET iFolio11 = iFolio11 + (iFolio3 * 5);
        LET iFolio11 = iFolio11 + (iFolio4 * 1);
        LET iFolio11 = iFolio11 + (iFolio5 * 5);
        LET iFolio11 = iFolio11 + (iFolio6 * 1);
        LET iFolio11 = iFolio11 + (iFolio7 * 5);
        LET iFolio11 = iFolio11 + (iFolio8 * 1);
        LET iFolio11 = iFolio11 + (iFolio9 * 5);
        LET iFolio11 = iFolio11 + (iFolio10 * 1);

        LET iFolio11 = iFolio11 + 137;

        LET iFolio11 = MOD(iFolio11, 7);

        LET cFolio0 = SUBSTR(sFecha, 1, 1);
        LET cFolio1 = CHR(ArregloDetiempo0); --INCFOLREP29072022
        LET cFolio2 = SUBSTR(sFecha, 5, 1);
        LET cFolio3 = CHR(iAlphaNum2);
        LET cFolio4 = SUBSTR(sFecha, 2, 1);
        LET cFolio5 = CHR(ArregloDetiempo1);
        LET cFolio6 = SUBSTR(sFecha, 3, 1);
        LET cFolio7 = CHR(iAlphaNum4);
        LET cFolio8 = SUBSTR(sFecha, 6, 1);
        LET cFolio9 = CHR(ArregloDetiempo2);
        LET cFolio10 = SUBSTR(sFecha, 4, 1);
        LET cFolio11 = CAST(iFolio11 AS CHAR(1));
        

        
        LET sNumero = cFolio0 || cFolio1 || cFolio2 || cFolio3 || cFolio4 || cFolio5 || cFolio6 || cFolio7 || cFolio8 || cFolio9 || cFolio10 || cFolio11;
        

        IF LENGTH(sNumero) = 12 THEN
            LET folioClaro = sNumero;
            LET iRegreso = 1;
        END IF;


        RETURN codRet, folioClaro;
    END;
END PROCEDURE;