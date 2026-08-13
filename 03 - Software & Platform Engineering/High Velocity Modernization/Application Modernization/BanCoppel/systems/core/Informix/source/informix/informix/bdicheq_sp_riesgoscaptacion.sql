CREATE PROCEDURE "informix".sp_riesgoscaptacion()
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    -------------------------------------------------
    -- Recopila los datos de captacion del cliente, 
    -- como el saldo disponible hasta el dia de hoy 
    -- y los guarda en la tabla sc_riesgoscap.
    -------------------------------------------------
    
    DEFINE GLOBAL vgcuenta      CHAR(20)     DEFAULT " ";
    DEFINE GLOBAL vgfechahoy    DATE         DEFAULT " ";
    DEFINE GLOBAL vgtasavar     CHAR(1)      DEFAULT "";
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vdescerr         CHAR(50);
    DEFINE vcomienza        SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vpri_dia_mes     DATE;
    DEFINE vult_dia_mes_ant DATE;
    DEFINE vanio            CHAR(4);
    DEFINE vmes             CHAR(2);
    DEFINE vaniomes         CHAR(6);
    DEFINE vresiduo         SMALLINT;
    
    DEFINE vnumcte          CHAR(20);
    DEFINE vrfc             CHAR(15);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vsucursal	    CHAR(4);
    DEFINE vplazo		    CHAR(3);
    DEFINE vproducto	    CHAR(4);
    DEFINE vedocivil		CHAR(2);
    DEFINE vsexo	  	    CHAR(1);
    DEFINE vocupacion       CHAR(30);
    DEFINE vciudad          CHAR(15);
    DEFINE vtasa			CHAR(8);
    DEFINE vdiaspos         SMALLINT;
    DEFINE vdiasposmes      SMALLINT;
    DEFINE vacumsdopos		MONEY(18,2);
    DEFINE vacumsdoposmes	MONEY(18,2);
    DEFINE vsdoprom		    MONEY(18,2);
    DEFINE vsdoprommes	    MONEY(18,2);
    DEFINE vsdoactual	    MONEY(18,2);
    DEFINE vsdoret		    MONEY(18,2);
    DEFINE vsdocong		    MONEY(18,2);
    DEFINE vsdo_sbg         MONEY(18,2);
    DEFINE vsdodisp         MONEY(18,2);
    DEFINE vfecha_aniv      DATE;
    DEFINE vfecha_altacte   DATE;
    DEFINE vfecha_primermov DATE;
    DEFINE vfecha_ultimomov DATE;
    DEFINE ves_fisica       CHAR(1);
    DEFINE vtipper          CHAR(1);
    DEFINE vvaltasa         DECIMAL(9,6);
    DEFINE vintinvcrec      DECIMAL(14,2);
    DEFINE vcapvig1         DECIMAL(14,2);
    DEFINE vcapvig2         DECIMAL(14,2);
    DEFINE vcapvig3         DECIMAL(14,2);
    DEFINE vcapvig4         DECIMAL(14,2);
    DEFINE vcapvig5         DECIMAL(14,2);
    DEFINE vcapvig6         DECIMAL(14,2);
    DEFINE vcapvig7         DECIMAL(14,2);
    DEFINE vcapvig8         DECIMAL(14,2);
    DEFINE vcapvig9         DECIMAL(14,2);
    DEFINE vcapvig10        DECIMAL(14,2);
    DEFINE vcapvig11        DECIMAL(14,2);
    DEFINE vcapvig12        DECIMAL(14,2);
    DEFINE vcapvig13        DECIMAL(14,2);
    DEFINE vcapvig14        DECIMAL(14,2);
    DEFINE vcapvig15        DECIMAL(14,2);
    DEFINE vcapvig16        DECIMAL(14,2);
    DEFINE vcapvig17        DECIMAL(14,2);
    DEFINE vcapvig18        DECIMAL(14,2);
    DEFINE vcapvig19        DECIMAL(14,2);
    DEFINE vcapvig20        DECIMAL(14,2);
    DEFINE vcapvig21        DECIMAL(14,2);
    DEFINE vcapvig22        DECIMAL(14,2);
    DEFINE vcapvig23        DECIMAL(14,2);
    DEFINE vcapvig24        DECIMAL(14,2);
    DEFINE vcapvig25        DECIMAL(14,2);
    DEFINE vcapvig26        DECIMAL(14,2);
    DEFINE vcapvig27        DECIMAL(14,2);
    DEFINE vcapvig28        DECIMAL(14,2);
    DEFINE vcapvig29        DECIMAL(14,2);
    DEFINE vcapvig30        DECIMAL(14,2);
    DEFINE vcapvig31        DECIMAL(14,2);
	--RQM 09 704. Se agregan las variables para el retorno de consulta de saldo.
	DEFINE cCodRetSpCons	CHAR(5);
	DEFINE cMensajeRet		CHAR(50);
	DEFINE mSdoSbc			MONEY(14,2);
    
    LET vcodret1        = '';
    LET vcodret2        = '';
    LET vcodret3        = '';
    LET vsqlerr         = 0;
    LET visamerr        = 0;
    LET vdescerr        = '';
    LET vcomienza       = -1;
    LET vcontador1      = 0;
    LET vcontador2      = 0;
    LET vcontador3      = 0;
    LET ven_transacc    = 0; 
    
    LET vpri_dia_mes     = '';
    LET vult_dia_mes_ant = '';
    LET vanio            = '';
    LET vmes             = '';
    LET vaniomes         = '';
    LET vresiduo         = 0;
    
    LET vnumcte          = "";
    LET vrfc             = '';
    LET vstatus_cta      = '';
    LET vsucursal        = "";
    LET vplazo           = "";
    LET vproducto        = "";
    LET vedocivil        = "";
    LET vsexo            = "";
    LET vocupacion       = "";
    LET vciudad          = "";
    LET vtasa            = 0;
    LET vdiaspos         = 0;
    LET vdiasposmes      = 0;
    LET vacumsdopos      = 0;
    LET vacumsdoposmes   = 0;
    LET vsdoprom         = 0;
    LET vsdoprommes      = 0;
    LET vsdoactual       = 0;
    LET vsdoret		     = 0;
    LET vsdocong		 = 0;
    LET vsdo_sbg         = 0;
    LET vsdodisp         = 0;
    LET vfecha_aniv      = '';
    LET vfecha_altacte   = '';
    LET vfecha_primermov = '';
    LET vfecha_ultimomov = '';
    LET ves_fisica       = '';
    LET vtipper          = '';
    LET vvaltasa         = 0;
    LET vintinvcrec      = 0;
    LET vcapvig1         = 0;
    LET vcapvig2         = 0;
    LET vcapvig3         = 0;
    LET vcapvig4         = 0;
    LET vcapvig5         = 0;
    LET vcapvig6         = 0;
    LET vcapvig7         = 0;
    LET vcapvig8         = 0;
    LET vcapvig9         = 0;
    LET vcapvig10        = 0;
    LET vcapvig11        = 0;
    LET vcapvig12        = 0;
    LET vcapvig13        = 0;
    LET vcapvig14        = 0;
    LET vcapvig15        = 0;
    LET vcapvig16        = 0;
    LET vcapvig17        = 0;
    LET vcapvig18        = 0;
    LET vcapvig19        = 0;
    LET vcapvig20        = 0;
    LET vcapvig21        = 0;
    LET vcapvig22        = 0;
    LET vcapvig23        = 0;
    LET vcapvig24        = 0;
    LET vcapvig25        = 0;
    LET vcapvig26        = 0;
    LET vcapvig27        = 0;
    LET vcapvig28        = 0;
    LET vcapvig29        = 0;
    LET vcapvig30        = 0;
    LET vcapvig31        = 0;
	--RQM 09 704. Se inicializan las variables para el retorno de consulta de saldo.
	LET cCodRetSpCons	= '00000';
	LET cMensajeRet		= '';
	LET mSdoSbc			= 0.0;

    BEGIN

    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET debug file to "/resplogifx/conciliachq/sp_riesgoscaptacion.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            LET vnumcte = vnumcte;
            LET vgcuenta = vgcuenta;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/home/c90301007/Traza/sp_riesgoscaptacion.out";
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- Obtiene la fecha del dia de hoy
    SELECT fecha_ant, pri_dia_mes
      INTO vgfechahoy, vpri_dia_mes
      FROM sc_fechas
     WHERE empresa = '001';
     
    LET vult_dia_mes_ant = vpri_dia_mes - 1 units day;
    LET vanio = YEAR(vult_dia_mes_ant);
    LET vmes = LPAD(MONTH(vult_dia_mes_ant), 2, '0');
    LET vaniomes = YEAR(vult_dia_mes_ant) || LPAD(MONTH(vult_dia_mes_ant), 2, '0');
    LET vresiduo = MOD(vanio, 4);
    
    CREATE TEMP TABLE sc_riesgoscap_tmp
        (
            numcte          char(20),
            cuenta          char(20),
            sucursal        char(4),
            plazo           char(3),
            producto        char(4),
            tasa            decimal(9,6),
            ocupacion       char(30),
            edocivil        char(2),
            sexo            char(1),
            ciudad          char(15),
            sdoprom         money(18,2),
            sdodisp         money(18,2),
            fecha_aniv      date,
            fecha_altacte   date,
            fecha_primermov date,
            fecha_ultimomov date,
            fecha           date,
            rfc             char(15),
            status_cta      char(1),
            sdo_prom_mesant money(18,2)
        ) 
    WITH NO LOG;
    
    -- CLIENTES  DEL  SISTEMA  DE  CAPTACION  (CHEQUES) 
    FOREACH WITH HOLD
        SELECT UNIQUE mae.num_cte
          INTO vnumcte
          FROM sc_maechq mae
         WHERE mae.status_cta NOT IN('2','6','7','8')
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        -- Obtiene los datos socioeconomicos del cliente 
        SELECT LIMIT 1 cli.fecha_alta, cli.rfc, cte.estado_civil, cte.sexo, pfs.descripcion, tip.es_fisica, ciu.nombreciudad
          INTO vfecha_altacte, vrfc, vedocivil, vsexo, vocupacion, ves_fisica, vciudad
          FROM bdinteg:si_cliente cli
         INNER JOIN bdinteg:si_tipper tip ON (tip.tpo_persona = cli.tpo_persona)
          LEFT OUTER JOIN bdinteg:si_ctepf cte ON (cli.numcte = cte.numcte AND cli.empresa = cte.empresa)
          LEFT OUTER JOIN bdinteg:si_direcciones_actual dir ON (dir.numcte = cli.numcte AND dir.tipo_dir = '1')
          LEFT OUTER JOIN bdinteg:si_catciudades ciu ON (ciu.numerociudad = dir.numerociudad)
          LEFT OUTER JOIN bdinteg:si_profesion pfs ON (cte.profesion = pfs.profesion)
         WHERE cli.numcte = vnumcte;
           
        -- ASIGNA TIPO DE PERSONA 
        IF ves_fisica = "S" THEN
            LET vtipper = "F";
        ELSE
            LET vtipper = "M";
        END IF;
        
        -- CUENTAS  DEL  SISTEMA  DE  CAPTACION  (CHEQUES) 
        FOREACH 
            SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.producto, mae.sdo_actual, mae.sdo_retenido, mae.sdo_cong, mae.imp_chq_sbg, mae.fec_ult_mov, 
                   noc.fecha_alta, noc.acum_sdo_pos, noc.dia_sdo_pos, pro.tasa, pro.paga_dividendo, mae.saldo_sbc
              INTO vgcuenta, vstatus_cta, vsucursal, vproducto, vsdoactual, vsdoret, vsdocong, vsdo_sbg, vfecha_ultimomov, 
                   vfecha_aniv, vacumsdopos, vdiaspos, vtasa, vgtasavar, mSdoSbc
              FROM bdicheq:sc_maechq mae,
                   bdicheq:sc_maenoc noc,
                   bdicheq:sc_producto pro
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta NOT IN('2','6','7','8')
               AND noc.empresa = mae.empresa
               AND noc.cuenta = mae.cuenta
               AND pro.empresa = mae.empresa
               AND pro.producto = mae.producto
               
            -- Calcula el saldo promedio actual de la cuenta
            IF vdiaspos > 0 THEN
                LET vsdoprom = vacumsdopos / vdiaspos;
            ELSE
                LET vsdoprom = vsdoactual;
            END IF;
            
            -- Obtiene el valor de la tasa 
            CALL calc_tasa('001', vtasa, vtipper, vsdoprom)
            RETURNING vcodret1, vvaltasa, vintinvcrec;
        
            -- Calcula el saldo promedio del mes anterior de la cuenta
            SELECT LIMIT 1 capvig1, capvig2, capvig3, capvig4, capvig5, capvig6, capvig7, capvig8, 
                   capvig9, capvig10, capvig11, capvig12, capvig13, capvig14, capvig15, capvig16,  
                   capvig17, capvig18, capvig19, capvig20, capvig21, capvig22, capvig23, capvig24, 
                   capvig25, capvig26, capvig27, capvig28, capvig29, capvig30, capvig31
              INTO vcapvig1, vcapvig2, vcapvig3, vcapvig4, vcapvig5, vcapvig6, vcapvig7, vcapvig8, 
                   vcapvig9, vcapvig10, vcapvig11, vcapvig12, vcapvig13, vcapvig14, vcapvig15, vcapvig16,  
                   vcapvig17, vcapvig18, vcapvig19, vcapvig20, vcapvig21, vcapvig22, vcapvig23, vcapvig24, 
                   vcapvig25, vcapvig26, vcapvig27, vcapvig28, vcapvig29, vcapvig30, vcapvig31
              FROM sc_sdodiarioc
             WHERE aniomes = vaniomes
               AND cuenta = vgcuenta;
            
            IF vmes IN('01','03','05','07','08','10','12') THEN
                LET vdiasposmes = 31;
                LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                     vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                     vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                     vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28 + vcapvig29 + vcapvig30 + vcapvig31;
                LET vsdoprommes = vacumsdoposmes / vdiasposmes;
            ELIF vmes IN('04','06','09','11') THEN
                LET vdiasposmes = 30;
                LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                     vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                     vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                     vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28 + vcapvig29 + vcapvig30;
                LET vsdoprommes = vacumsdoposmes / vdiasposmes;
            ELIF vmes = '02' THEN
                IF vresiduo = 0 THEN
                    LET vdiasposmes = 29;
                    LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                         vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                         vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                         vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28 + vcapvig29;
                    LET vsdoprommes = vacumsdoposmes / vdiasposmes;
                ELSE
                    LET vdiasposmes = 28;
                    LET vacumsdoposmes = vcapvig1 + vcapvig2 + vcapvig3 + vcapvig4 + vcapvig5 + vcapvig6 + vcapvig7 + vcapvig8 + 
                                         vcapvig9 + vcapvig10 + vcapvig11 + vcapvig12 + vcapvig13 + vcapvig14 + vcapvig15 + vcapvig16 + 
                                         vcapvig17 + vcapvig18 + vcapvig19 + vcapvig20 + vcapvig21 + vcapvig22 + vcapvig23 + vcapvig24 +            
                                         vcapvig25 + vcapvig26 + vcapvig27 + vcapvig28;
                    LET vsdoprommes = vacumsdoposmes / vdiasposmes;
                END IF
            END IF;
            
            -- Calcula el saldo disponible del cliente 
            --LET vsdodisp = vsdoactual - (vsdoret + vsdocong + vsdo_sbg);
			
			-- RQM 09 704. Se agrega el SP para calcular el saldo disponible tomando en cuenta el saldo_sbc.
			EXECUTE PROCEDURE bdicheq:"informix".sp_cons_sdodisp_x_tpcalculo
			('', vsdoactual, vsdoret, vsdocong, mSdoSbc, vsdo_sbg, NULL, NULL, 'F', '1') INTO cCodRetSpCons, cMensajeRet, vsdodisp;

            -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
            IF (cCodRetSpCons <> '00000') THEN
                CONTINUE FOREACH;      
            END IF;

            LET vplazo = ' ';
            LET vfecha_primermov = vfecha_aniv;

            -- Inserta datos en tabla sc_riesgoscap_tmp 
            INSERT INTO sc_riesgoscap_tmp 
            ( numcte, cuenta, sucursal, plazo, producto, tasa, ocupacion, edocivil, sexo, ciudad, 
              sdoprom, sdodisp, fecha_aniv, fecha_altacte, fecha_primermov, fecha_ultimomov, fecha,
              rfc, status_cta, sdo_prom_mesant )
            VALUES 
            ( vnumcte, vgcuenta, vsucursal, vplazo, vproducto, vvaltasa, vocupacion, vedocivil, vsexo, vciudad, 
              vsdoprom, vsdodisp, vfecha_aniv, vfecha_altacte, vfecha_primermov, vfecha_ultimomov, vgfechahoy,
              vrfc, vstatus_cta, vsdoprommes );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vgcuenta	     = "";
            LET vsucursal        = "";
            LET vplazo           = "";
            LET vproducto        = "";
            LET vtasa            = 0;
            LET vgtasavar        = "";
            LET vdiaspos         = 0;
            LET vacumsdopos      = 0;
            LET vsdoprom         = 0;
            LET vsdoactual       = 0;
            LET vsdoret		     = 0;
            LET vsdocong		 = 0;
            LET vsdo_sbg         = 0;
            LET vsdodisp         = 0;
            LET vfecha_aniv      = '';
            LET vfecha_primermov = '';
            LET vfecha_ultimomov = '';
            LET vvaltasa         = 0;
            LET vintinvcrec      = 0;
            LET vcapvig1         = 0;
            LET vcapvig2         = 0;
            LET vcapvig3         = 0;
            LET vcapvig4         = 0;
            LET vcapvig5         = 0;
            LET vcapvig6         = 0;
            LET vcapvig7         = 0;
            LET vcapvig8         = 0;
            LET vcapvig9         = 0;
            LET vcapvig10        = 0;
            LET vcapvig11        = 0;
            LET vcapvig12        = 0;
            LET vcapvig13        = 0;
            LET vcapvig14        = 0;
            LET vcapvig15        = 0;
            LET vcapvig16        = 0;
            LET vcapvig17        = 0;
            LET vcapvig18        = 0;
            LET vcapvig19        = 0;
            LET vcapvig20        = 0;
            LET vcapvig21        = 0;
            LET vcapvig22        = 0;
            LET vcapvig23        = 0;
            LET vcapvig24        = 0;
            LET vcapvig25        = 0;
            LET vcapvig26        = 0;
            LET vcapvig27        = 0;
            LET vcapvig28        = 0;
            LET vcapvig29        = 0;
            LET vcapvig30        = 0;
            LET vcapvig31        = 0;
        END FOREACH;
        
        -- CUENTAS  DEL  SISTEMA  DE  CAPTACION  (INVERSIONES) 
        FOREACH 
            SELECT mae.cuenta, mae.status_cta, mae.sucursal, mae.cod_instrum, mae.capital, mae.fec_ult_mov, mae.fecha_alta, mae.tasa, mae.plazo
              INTO vgcuenta, vstatus_cta, vsucursal, vproducto, vsdoactual, vfecha_ultimomov, vfecha_aniv, vvaltasa, vplazo
              FROM bdinvers:sv_maeinv mae
             WHERE mae.num_cte = vnumcte
               AND mae.status_cta = '1'
        
            -- Calcula el saldo promedio del cliente 
            LET vsdoprom = vsdoactual;
            LET vsdoprommes = vsdoactual;
            
            -- Calcula el saldo disponible del cliente 
            LET vsdodisp = vsdoactual;
            
            LET vfecha_primermov = vfecha_aniv;

            -- Inserta datos en tabla sc_riesgoscap_tmp 
            INSERT INTO sc_riesgoscap_tmp 
            ( numcte, cuenta, sucursal, plazo, producto, tasa, ocupacion, edocivil, sexo, ciudad, 
              sdoprom, sdodisp, fecha_aniv, fecha_altacte, fecha_primermov, fecha_ultimomov, fecha,
              rfc, status_cta, sdo_prom_mesant )
            VALUES 
            ( vnumcte, vgcuenta, vsucursal, vplazo, vproducto, vvaltasa, vocupacion, vedocivil, vsexo, vciudad, 
              vsdoprom, vsdodisp, vfecha_aniv, vfecha_altacte, vfecha_primermov, vfecha_ultimomov, vgfechahoy,
              vrfc, vstatus_cta, vsdoprommes );
              
            LET vcontador2 = vcontador2 + 1;
            LET vcontador3 = vcontador3 + 1;
            
            LET vgcuenta	     = "";
            LET vsucursal        = "";
            LET vplazo           = "";
            LET vproducto        = "";
            LET vsdoprom         = 0;
            LET vsdoactual       = 0;
            LET vsdodisp         = 0;
            LET vfecha_aniv      = '';
            LET vfecha_primermov = '';
            LET vfecha_ultimomov = '';
            LET vvaltasa         = 0;
            LET vstatus_cta      = '';
            LET vsdoprommes      = 0;
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF vcontador3 >= 10000 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vnumcte         = "";
        LET vedocivil       = "";
        LET vsexo           = "";
        LET vocupacion      = "";
        LET vciudad         = "";
        LET vfecha_altacte  = '';
        LET ves_fisica      = '';
        LET vtipper         = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_riesgoscap_tmp;
    
    LET vcodret1 = "000";
    LET vcodret2 = "000";
    LET vcodret3 = "EL PROCESO SE REALIZO SATISFACTORIAMENTE";

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
    END;

END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		bdicheq',
'FECHA :        07-07-2025',
'MODIFICACION : Se modifica la formula de calculo de saldo disponible para considerar un nuevo campo llamado saldo_sbc',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'VERSION :      1.0.2',
'MODIFICADO:    Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   07-01-2026',
'MODIFICACION : Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'               cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO :     RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    :        bdicheq',
'VER   :        1.0.3';

CREATE PROCEDURE "informix".spscvalidatransfctaspropias(pEmpresa char(3),
                                                        pUsuario char(50),
                                                        pCtaOrigen char(20),
                                                        pCtaDestino char(20),
                                                        pMonto money(14,2))
        RETURNING char(5), char(20), char(20);


       DEFINE vcodret   char(5);
       DEFINE vUsuStatus smallint;
       DEFINE vSdoReal money(14,2);
       DEFINE vSdoActual money(14,2);
       DEFINE vSdoRetenido money(14,2);
       DEFINE vSdoCongelado money(14,2);
       DEFINE vNumTarjOrigen char(20);
       DEFINE vNumTarjDestino char(20);
       DEFINE sql_err   integer;
       --RQM 09 704. Se agregan las siguientes variable DFTL 
       DEFINE mSaldoSbc       MONEY(14,2);
       DEFINE cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
       DEFINE cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;
       END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;


LET vcodret = '000';
LET vNumTarjOrigen = '0';
LET vNumTarjDestino = '0';
--RQM 09 704. Se agregan las siguientes variable DFTL
LET mSaldoSbc           = 0;
LET cCodRetConsSdo      = '00000';
LET cMensajeRetConsSdo  = '';

--Set debug file to '/tmp/traspasobanco/bpi_trasacciones.out';
--trace on;
BEGIN
    --Se valida el status del usuario sea completamente activado
    SELECT id_status INTO vUsuStatus FROM bdinteg:si_bpiusuarios WHERE usuario = pUsuario;
    IF vUsuStatus <> 30 THEN
        RETURN '100', vNumTarjOrigen, vNumTarjDestino;
    END IF;

    --Se valida que el monto de la transferencia no sea mayor al saldo de la cuenta origen
    SELECT sdo_actual, sdo_retenido, sdo_cong, saldo_sbc INTO vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc FROM sc_maechq WHERE cuenta = pCtaOrigen;
    --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
    EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', vSdoActual, vSdoRetenido, vSdoCongelado, mSaldoSbc, null, null, null, 'F', 2) 
    INTO cCodRetConsSdo, cMensajeRetConsSdo, vSdoReal;

    -- RQM 09 704 Se agrega la validacion del codigo de retorno no exitoso(diferente de '00000')
        IF (cCodRetConsSdo <> '00000') THEN
            LET vcodret = '420'; --SUMA DE MONTOS ERRONEA
            RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;
        END IF;    

    IF pMonto > vSdoReal THEN
        RETURN '200', vNumTarjOrigen, vNumTarjDestino;
    END IF;

    --Se obtiene el numero de tarjeta de la cuenta origen
    SELECT tr.num_tarjeta
    INTO vNumTarjOrigen
    FROM sc_maechq mc
    INNER JOIN sc_tarjeta tr
    on mc.empresa = pEmpresa  AND
    mc.empresa = tr.empresa AND
    mc.cuenta = pCtaOrigen AND
    tr.cuenta = mc.cuenta AND
    tr.tipo_tarjeta = 'T' AND
    tr.status_tar = 'A';

    --Se obtiene el numero de tarjeta de la cuenta destino
    SELECT tr.num_tarjeta
    INTO vNumTarjDestino
    FROM sc_maechq mc
    INNER JOIN sc_tarjeta tr
    on mc.empresa = pEmpresa  AND
    mc.empresa = tr.empresa AND
    mc.cuenta = pCtaDestino AND
    tr.cuenta = mc.cuenta AND
    tr.tipo_tarjeta = 'T' AND
    tr.status_tar = 'A';

    if 	vNumTarjDestino is null then
	let vNumTarjDestino = '';
    end if;	

   if 	vNumTarjOrigen is null then
	let vNumTarjOrigen = '';
    end if;	


END;
RETURN vcodret, vNumTarjOrigen, vNumTarjDestino;

END PROCEDURE
DOCUMENT
'Realizo   :  Javier Humberto Calderon Zazueta',
'Actividad :  Pago Tarjeta Credito Bancoppel',
'Solicita  :  Diana Castellanos',
'Fecha     :  02/06/2008',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/16',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   07-01-2026',
'MODIFICACION:          Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'                       cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO  :            RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD        :            bdicheq',
'VER       :            1.3';

create procedure "informix".total_colateral( pempresa char(3), pcuenta char(20) )
returning money(14,2), smallint;

    define vcodret char(5);
    define vsqlerr integer;
    define vctacol char(20);
    define vsdototcol,vsaldo money(14,2);
    define vnumcol smallint;
    define vfecha_hoy date;
    define vfechacalendario date;
    define vfecvenccc date;
    define vdispccc money(14,2);
    define vstatus_cta char(1);
    --RQM 09 704. Se agregan las siguientes variable DFTL 
    define mSdoActual      money(14,2);
    define mSdoRetenido        money(14,2);
    define mSdoCongelado       money(14,2);
    define mSaldoSbc       MONEY(14,2);
    define cCodRetConsSdo       CHAR(5); --Codigo de retorno de SP de consulta de saldo.
    define cMensajeRetConsSdo   CHAR(50); --Mensaje de retorno de SP de consulta de saldo.

    let vsdototcol = 0;
    let vnumcol = 0;
    let vcodret = "000";
    --RQM 09 704. Se agregan las siguientes variable DFTL
    let mSdoActual         = 0;
    let mSdoRetenido           = 0;
    let mSdoCongelado          = 0;
    let mSaldoSbc           = 0;
    let cCodRetConsSdo      = '00000';
    let cMensajeRetConsSdo  = '';

    --SET DEBUG FILE TO "/home/c90402536/Traza/total_colateral_modif.out";
    --TRACE ON; 

    select {+INDEX(sc_fechas idx_fechas1)} fecha_hoy 
      into vfechacalendario
      from sc_fechas 
     where empresa = pempresa;

    select fecha_proceso, status_cta  
      into vfecha_hoy, vstatus_cta
      from sc_maechq
     where empresa = pempresa
       and cuenta = pcuenta;

    if ( vfecha_hoy is null or vstatus_cta = '4' ) then
        let vfecha_hoy = vfechacalendario;
    end if       

    if ( vfecha_hoy < vfechacalendario ) then
        let vcodret = "549";
        --- return  vcodret,vtranret;
    end if   
    
    if ( vstatus_cta in('2','6','7','8') ) then
        let vcodret = "200";
        --- return  vcodret,vtranret;
    end if   

    begin

    on exception set vsqlerr
        if vsqlerr <> 0 then
            let vcodret = vsqlerr;
            return vsdototcol, vnumcol;
        end if
    end exception;

    foreach
        select {+INDEX(sc_colateral idx_colat1)} cta_col 
          into vctacol 
          from sc_colateral
         where empresa = pempresa 
           and cuenta = pcuenta 


        select sdo_actual,sdo_retenido,sdo_cong,fech_venc_ccc,lim_sbg_ccc-imp_sbg_ccc,saldo_sbc
          into mSdoActual,mSdoRetenido,mSdoCongelado,vfecvenccc,vdispccc,mSaldoSbc
          from sc_maechq
         where empresa = pempresa 
           and cuenta = vctacol;

        --RQM 09 704. Se executa el siguiente SP para el calculo del saldo disponible DFTL 
        EXECUTE PROCEDURE sp_cons_sdodisp_x_tpcalculo('', mSdoActual, mSdoRetenido, mSdoCongelado, mSaldoSbc, null, null, null, 'F', 2) 
        INTO cCodRetConsSdo, cMensajeRetConsSdo, vsaldo;

        --RQM 09 704. Se agrega la validacion para el codigo de retorno del SPL sp_cons_sdodisp_x_tpcalculo. EEAP.
        if(cCodRetConsSdo <> '00000') then
            --Registramos el error en el TRACE para saber quÃ© colateral fallÃ³
            CONTINUE FOREACH;
        end if;

        if vdispccc > 0 and vfecvenccc >= vfecha_hoy then
            let vsaldo = vsaldo + vdispccc;
        end if;

        let vsdototcol = vsdototcol + vsaldo;
        let vnumcol = vnumcol + 1;
    end foreach;

    return vsdototcol, vnumcol;

    end

end procedure
DOCUMENT
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   2025/07/07',
'RAZON:                 Se agrega la nueva variable sdo_sbc (saldo buen cobro)',
'                       a la operacion aritmetica para el nuevo calculo de',
'                       saldo disponible.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.2',
'MODIFICADO:            Donovan F. Torres Landeros',
'ULTIMA MODIFICACION:   07-01-2026',
'RAZON:                 Se agrega la validacion de codigo de retorno para el SPL sp_cons_sdodisp_x_tpcalculo',
'                       cuando el SPL retorne un codigo diferente a 00000.',
'PROYECTO:              RQM 09 704   Cobranza Automatica en cuentas de captacion',
'BD:                    bdicheq',
'VER:                   1.3';

CREATE PROCEDURE "informix".sp_conciliainv(pempresa CHAR(3), pcuenta VARCHAR(20))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

-- // DECLARACION DE VARIABLES
DEFINE vcodret1           CHAR(5);
DEFINE vcodret2           CHAR(5);
DEFINE vcodret3           VARCHAR(50);
DEFINE sql_err            SMALLINT;
DEFINE isam_err           SMALLINT;
DEFINE desc_err           VARCHAR(50);
DEFINE vcomienza          SMALLINT;
DEFINE vcomienza1         SMALLINT;
DEFINE ven_transacc       SMALLINT;
DEFINE ven_transacc1      SMALLINT;
DEFINE vsecuencia         SMALLINT;
DEFINE vplazo             SMALLINT;
DEFINE vcontador          INTEGER;
DEFINE vcontador1         INTEGER;
DEFINE vcontador2         INTEGER;
DEFINE vcontador3         INTEGER;
DEFINE vconta             INTEGER;
DEFINE vsucursal          CHAR(4);
DEFINE vejecutivo         CHAR(8);
DEFINE vcap_anterior      MONEY(15,2);
DEFINE vcap_calculado     MONEY(15,2);
DEFINE vcap_actual        MONEY(15,2);
DEFINE vdif_capital       MONEY(15,2);
DEFINE vint_anterior      MONEY(15,2);
DEFINE vint_calculado     MONEY(15,2);
DEFINE vint_actual        MONEY(15,2);
DEFINE vdif_interes       MONEY(15,2);
DEFINE vsql               LVARCHAR(850);
DEFINE vmontocargocap     MONEY(15,2);
DEFINE vmontoabonocap     MONEY(15,2);
DEFINE vmontocargoint     MONEY(15,2);
DEFINE vmontoabonoint     MONEY(15,2);
DEFINE vcta_cargo         VARCHAR(14);
DEFINE vcta_abono         VARCHAR(14);
DEFINE vcuenta            VARCHAR(20);
DEFINE vnum_cte           VARCHAR(20);
DEFINE vfecha             CHAR(8);
DEFINE vanio              CHAR(4);
DEFINE vproducto          CHAR(4);
DEFINE vgenero            CHAR(1);
DEFINE vfecha_hoy         DATE;
DEFINE vfecha_ant         DATE;
DEFINE vfecha_actual      DATE;
DEFINE vpri_hab_mes       DATE;

-- // Definicion de variables para sv_movsinver
DEFINE sv_fecha_ant       DATE;
DEFINE sv_sucursal        CHAR(4);
DEFINE sv_fech_alt        DATE;
DEFINE sv_transacc        CHAR(4);
DEFINE sv_cuenta          CHAR(20);
DEFINE sv_num_cte         CHAR(20);
DEFINE sv_monto_tot       DECIMAL(18,2);
DEFINE sv_cta_cargo       CHAR(14);
DEFINE sv_cta_abono       CHAR(14);
DEFINE sv_secuencia       SMALLINT;

-- // INICIALIZACION DE VARIABLES
LET vcodret1           = '000';
LET vcodret2           = '000';
LET vcodret3           = '';
LET sql_err            = 0;
LET isam_err           = 0;
LET desc_err           = '';
LET vcomienza          = -1;
LET ven_transacc        = 0;
LET vcontador1         = 0;
LET vcontador2         = 0;
LET vcontador3         = 0;
LET vcuenta            = '';
LET vsecuencia         = 0;
LET vconta             = 0;
LET vnum_cte           = '';
LET vsucursal          = '';
LET vejecutivo         = '';
LET vcap_anterior      = 0.00;
LET vcap_calculado     = 0.00;
LET vcap_actual        = 0.00;
LET vdif_capital       = 0.00;
LET vint_anterior      = 0.00;
LET vint_calculado     = 0.00;
LET vint_actual        = 0.00;
LET vdif_interes       = 0.00;
LET vmontocargocap     = 0.00;
LET vmontoabonocap     = 0.00;
LET vmontocargoint     = 0.00;
LET vmontoabonoint     = 0.00;
LET vcta_cargo         = '';
LET vcta_abono         = '';
LET vfecha_hoy         = '';
LET vfecha_ant         = '';
LET vfecha_actual      = '';
LET vpri_hab_mes       = '';
LET vfecha             = '';
LET vanio              = '';
LET vproducto          = '';
LET vplazo             = 0;
LET vgenero            = '';

-- // Inicializacion de variables para sv_movsinver
LET sv_fecha_ant       = '';
LET sv_sucursal        = '';
LET sv_fech_alt        = '';
LET sv_transacc        = '';
LET sv_cuenta          = '';
LET sv_num_cte         = '';
LET sv_monto_tot       = 0;
LET sv_cta_cargo       = '';
LET sv_cta_abono       = '';
LET sv_secuencia       = 0;
LET vcomienza1 		   = -1;
LET ven_transacc1      = 0;

BEGIN

   ON EXCEPTION SET sql_err, isam_err, desc_err
      SET DEBUG FILE TO "/resplogifx/conciliachq/sp_conciliainv.err";
      TRACE ON;

      IF sql_err <> 0 THEN
         LET vcodret1 = sql_err;
         LET vcodret2 = isam_err;
         LET vcodret3 = desc_err;

         IF ven_transacc = 1 THEN
            ROLLBACK WORK;
         END IF;

         RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
      END IF
   END EXCEPTION;

   ON EXCEPTION IN (-668)
      LET vcodret1 = '00668';
      LET vcodret2 = '00668';
   END EXCEPTION WITH RESUME;

   --- SET DEBUG FILE TO "/home/c98789058/SPL_ACCENTURE/sp_conciliainv.out";
   --- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;


   -- // CREA TABLA PARA TODOS LOS PAGARES
   IF EXISTS (SELECT dbsname, tabname
                FROM sysmaster:systabnames
               WHERE partnum > 0
                 AND tabname = 'conciliainv') THEN

      TRUNCATE TABLE bdinvers:conciliainv;
   ELSE
      CREATE TABLE bdinvers:conciliainv
         (
          fecha            DATE,
          cuenta           CHAR(20),
          secuencia        SMALLINT,
          plazo            SMALLINT,
          producto         CHAR(4),
          num_cte          CHAR(20),
          genero           CHAR(1),
          sucursal         CHAR(4),
          ejecutivo        CHAR(8),
          cap_anterior     MONEY(15,2),
          movscargocap     MONEY(15,2),
          movsabonocap     MONEY(15,2),
          cap_calculado    MONEY(15,2),
          cap_actual       MONEY(15,2),
          dif_sdos         MONEY(15,2),
          int_anterior     MONEY(15,2),
          movscargoint     MONEY(15,2),
          movsabonoint     MONEY(15,2),
          int_calculado    MONEY(15,2),
          int_actual       MONEY(15,2),
          dif_ints         MONEY(15,2)
         )
      EXTENT SIZE 16000 NEXT SIZE 2000 LOCK MODE ROW;

      CREATE INDEX idx_conciliainv_cta ON bdinvers:conciliainv(cuenta) ONLINE;
      CREATE INDEX idx_conciliainv_fch ON bdinvers:conciliainv(fecha) ONLINE;
   END IF;

   -- // TABLA DE DIFERENCIAS
   IF EXISTS (SELECT dbsname, tabname
                FROM sysmaster:systabnames
               WHERE partnum > 0
                 AND tabname = 'conciliainvdif') THEN

      TRUNCATE TABLE bdinvers:conciliainvdif;
   ELSE
      CREATE TABLE bdinvers:conciliainvdif
         (
          fecha            DATE,
          cuenta           CHAR(20),
          secuencia        SMALLINT,
          plazo            SMALLINT,
          producto         CHAR(4),
          num_cte          CHAR(20),
          genero           CHAR(1),
          sucursal         CHAR(4),
          ejecutivo        CHAR(8),
          cap_anterior     MONEY(15,2),
          movscargocap     MONEY(15,2),
          movsabonocap     MONEY(15,2),
          cap_calculado    MONEY(15,2),
          cap_actual       MONEY(15,2),
          dif_sdos         MONEY(15,2),
          int_anterior     MONEY(15,2),
          movscargoint     MONEY(15,2),
          movsabonoint     MONEY(15,2),
          int_calculado    MONEY(15,2),
          int_actual       MONEY(15,2),
          dif_ints         MONEY(15,2)
         )
      EXTENT SIZE 500 NEXT SIZE 125 LOCK MODE ROW;

      CREATE INDEX idx_conciliainvdif_cta ON bdinvers:conciliainvdif(cuenta) ONLINE;
      CREATE INDEX idx_conciliainvdif_fch ON bdinvers:conciliainvdif(fecha) ONLINE;
   END IF;

   -- // OBTIENE LAS FECHAS DEL SISTEMA
   SELECT fecha_hoy, fecha_ant, fecha_hoy, pri_hab_mes
     INTO vfecha_hoy, vfecha_ant, vfecha_actual, vpri_hab_mes
     FROM bdinvers:sv_fechas
    WHERE empresa = pempresa;

	--LET vfecha_hoy = '01/06/2026'; --para pruebas
	--LET vfecha_actual = '01/06/2026'; --para pruebas
	--LET vfecha_ant = '01/05/2026'; --para pruebas

   -- // VALIDA LAS FECHAS HABILES
   LET vfecha_hoy = vfecha_hoy - 1 UNITS DAY;
   LET vfecha_ant = vfecha_ant - 1 UNITS DAY;

   EXECUTE PROCEDURE bdicheq:sp_valfechabil(vfecha_hoy, '-')
      INTO vcodret1, vfecha_hoy;

   EXECUTE PROCEDURE bdicheq:sp_valfechabil(vfecha_ant, '-')
      INTO vcodret1, vfecha_ant;

   -- // TABLA TEMPORAL DE MOVIMIENTOS
   SELECT mov.cuenta, mov.secuencia, mov.transacc, mov.monto_tot, tran.descripcion, tran.se_contabiliza,
          TRIM(prod.c_ccmayor)||TRIM(prod.c_ccsub)||TRIM(prod.c_ccsubsub)||TRIM(prod.c_ccsssub)||TRIM(prod.c_ccssssub)||TRIM(prod.c_sector) AS cta_cargo,
          TRIM(prod.a_ccmayor)||TRIM(prod.a_ccsub)||TRIM(prod.a_ccsubsub)||TRIM(prod.a_ccsssub)||TRIM(prod.a_ccssssub)||TRIM(prod.a_sector) AS cta_abono
     FROM bdinvers:sv_movhis mov, bdinvers:sv_maeinv mae, bdinvers:sv_plazotasa pla, bdinteg:si_prodtran prod, bdinteg:si_transacc tran
    WHERE mov.empresa = pempresa
      AND mov.cuenta >= '30000000015'
      AND mov.fech_alt = vfecha_hoy
      AND mov.cancelad <> 'S'
      AND mae.empresa = mov.empresa
      AND mae.cuenta = mov.cuenta
      AND mae.secuencia = mov.secuencia
      AND mae.plazo <= pla.plazo_max
      AND mae.plazo >= pla.plazo_min
      AND pla.plaza = mae.plaza
      AND pla.secuencia = prod.secuencia
      AND prod.transaccion = mov.transacc
      AND prod.producto = mov.cod_instrum
      AND prod.sistema = '03'
      AND tran.empresa = mov.empresa
      AND tran.numero = prod.transaccion
      AND tran.se_contabiliza = 'S'
      AND tran.sistema = '03'
     INTO TEMP tmp_concilia WITH NO LOG;

    CREATE INDEX idx_concilia ON tmp_concilia(cuenta) ONLINE;


   -- // PROCESAMIENTO DE LOS PAGARES ACTIVOS O VIGENTES
   FOREACH cur_001a WITH HOLD FOR
      SELECT mae.cuenta, mae.secuencia, mae.cod_instrum, mae.num_cte, mae.sucursal, mae.promotor, mae.plazo,
             CASE WHEN (SELECT COUNT(*) FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte) > 0 THEN
                  (SELECT sexo FROM bdinteg:si_ctepf WHERE numcte = mae.num_cte)
             ELSE
                'E'
             END
        INTO vcuenta, vsecuencia, vproducto, vnum_cte, vsucursal, vejecutivo, vplazo, vgenero
        FROM bdinvers:sv_maeinv mae
       WHERE mae.empresa = pempresa
         AND mae.cuenta >= '30000000015'
         AND (mae.status_cta = '1' OR mae.fecha_venc = vfecha_hoy)

      IF (vcomienza = -1) THEN
         BEGIN WORK;
         LET vcomienza = 0;
         LET ven_transacc = 1;
      END IF;

      -- // OBTIENE SALDOS ANTERIORES
      EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_ant, vsecuencia)
         INTO vcodret1, vcodret2, vcap_anterior, vint_anterior;

      IF vcodret1 <> '000' OR vcodret2 <> '000' THEN
         INSERT INTO bdinvers:conciliainvdif (fecha, cuenta, secuencia, plazo, producto, num_cte, genero,
                                              sucursal, ejecutivo, cap_anterior, movscargocap, movsabonocap,
                                              cap_calculado, cap_actual, dif_sdos, int_anterior, movscargoint,
                                              movsabonoint, int_calculado, int_actual, dif_ints)
              VALUES (vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vgenero, vsucursal,
                      vejecutivo, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

         LET vcodret1 = '000';
         LET vcodret2 = '000';
         LET vcontador2 = vcontador2 + 1;
         LET vcontador1 = vcontador1 + 1;
         CONTINUE FOREACH;
      END IF;

      LET vcap_calculado = vcap_anterior;
      LET vint_calculado = vint_anterior;

      -- // RESTA CAPITAL
      SELECT NVL(SUM(tmp.monto_tot), 0.00) INTO vmontocargocap
        FROM tmp_concilia tmp
       WHERE tmp.cuenta = vcuenta
         AND tmp.secuencia = vsecuencia
         AND tmp.cta_cargo IN (SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

      LET vcap_calculado = vcap_calculado - vmontocargocap;

      -- // SUMA CAPITAL
      SELECT NVL(SUM(tmp.monto_tot), 0.00) INTO vmontoabonocap
        FROM tmp_concilia tmp
       WHERE tmp.cuenta = vcuenta
         AND tmp.secuencia = vsecuencia
         AND tmp.cta_abono IN (SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'CAPITAL');

      LET vcap_calculado = vcap_calculado + vmontoabonocap;

      -- // RESTA INTERES
      SELECT NVL(SUM(tmp.monto_tot), 0.00) INTO vmontocargoint
        FROM tmp_concilia tmp
       WHERE tmp.cuenta = vcuenta
         AND tmp.secuencia = vsecuencia
         AND tmp.cta_cargo IN (SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

      LET vint_calculado = vint_calculado - vmontocargoint;

      -- // SUMA INTERES
      SELECT NVL(SUM(tmp.monto_tot), 0.00) INTO vmontoabonoint
        FROM tmp_concilia tmp
       WHERE tmp.cuenta = vcuenta
         AND tmp.secuencia = vsecuencia
         AND tmp.cta_abono IN (SELECT cta_contable FROM bdinvers:sv_ctascontinv WHERE tipo = 'INTERES');

      LET vint_calculado = vint_calculado + vmontoabonoint;

      -- // OBTIENE SALDOS ACTUALES
      EXECUTE PROCEDURE bdinvers:sp_capintafecha(vcuenta, vfecha_hoy, vsecuencia)
         INTO vcodret1, vcodret2, vcap_actual, vint_actual;

      IF vcodret1 <> '000' OR vcodret2 <> '000' THEN
         INSERT INTO bdinvers:conciliainvdif (fecha, cuenta, secuencia, plazo, producto, num_cte, genero,
                                              sucursal, ejecutivo, cap_anterior, movscargocap, movsabonocap,
                                              cap_calculado, cap_actual, dif_sdos, int_anterior, movscargoint,
                                              movsabonoint, int_calculado, int_actual, dif_ints)
              VALUES (vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                      0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00);

         LET vcodret1 = '000';
         LET vcodret2 = '000';
         LET vcontador2 = vcontador2 + 1;
         LET vcontador1 = vcontador1 + 1;
         CONTINUE FOREACH;
      END IF;

      LET vdif_capital = vcap_actual - vcap_calculado;
      LET vdif_interes = vint_actual - vint_calculado;

      -- // LLENA TABLA DE TODAS LAS CUENTAS
      INSERT INTO bdinvers:conciliainv (fecha, cuenta, secuencia, plazo, producto, num_cte, genero, sucursal,
                                        ejecutivo, cap_anterior, movscargocap, movsabonocap, cap_calculado,
                                        cap_actual, dif_sdos, int_anterior, movscargoint, movsabonoint,
                                        int_calculado, int_actual, dif_ints)
           VALUES (vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                   vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital,
                   vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);

      -- // LLENA TABLA DE DIFERENCIAS
      IF (vdif_capital <> 0 OR vdif_interes <> 0) THEN
         INSERT INTO bdinvers:conciliainvdif (fecha, cuenta, secuencia, plazo, producto, num_cte, genero,
                                              sucursal, ejecutivo, cap_anterior, movscargocap, movsabonocap,
                                              cap_calculado, cap_actual, dif_sdos, int_anterior, movscargoint,
                                              movsabonoint, int_calculado, int_actual, dif_ints)
              VALUES (vfecha_hoy, vcuenta, vsecuencia, vplazo, vproducto, vnum_cte, vgenero, vsucursal, vejecutivo,
                      vcap_anterior, vmontocargocap, vmontoabonocap, vcap_calculado, vcap_actual, vdif_capital,
                      vint_anterior, vmontocargoint, vmontoabonoint, vint_calculado, vint_actual, vdif_interes);

         LET vcontador2 = vcontador2 + 1;
      END IF;

      LET vcontador1 = vcontador1 + 1;
      LET vcontador3 = vcontador3 + 1;

      IF (vcontador3 >= 1000) THEN
         LET vcontador3 = 0;
         COMMIT WORK;
         BEGIN WORK;
      END IF;

      LET vcuenta         = '';
      LET vsecuencia      = 0;
      LET vnum_cte        = '';
      LET vsucursal       = '';
      LET vejecutivo      = '';
      LET vcap_anterior   = 0.00;
      LET vmontocargocap  = 0.00;
      LET vmontoabonocap  = 0.00;
      LET vcap_calculado  = 0.00;
      LET vcap_actual     = 0.00;
      LET vdif_capital    = 0.00;
      LET vint_anterior   = 0.00;
      LET vmontocargoint  = 0.00;
      LET vmontoabonoint  = 0.00;
      LET vint_calculado  = 0.00;
      LET vint_actual     = 0.00;
      LET vdif_interes    = 0.00;
      LET vplazo          = 0;
   END FOREACH;

   IF (ven_transacc = 1) THEN
      LET ven_transacc = 0;
      COMMIT WORK;
   END IF;

   UPDATE STATISTICS MEDIUM FOR TABLE bdinvers:conciliainv;
   UPDATE STATISTICS MEDIUM FOR TABLE bdinvers:conciliainvdif;

   -- // DESCARGA LA INFORMACION
   LET vfecha = TO_CHAR(vfecha_hoy, '%m%d%Y');

   -- // ARCHIVO DE TODAS LAS CUENTAS DE LA CONCILIACION
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliainv_'||vfecha||'.txt '||
              'SELECT fecha, cuenta, secuencia, plazo, producto, num_cte, sucursal, ejecutivo, '||
              'cap_anterior, movscargocap, movsabonocap, cap_calculado, cap_actual, dif_sdos, '||
              'int_anterior, movscargoint, movsabonoint, int_calculado, int_actual, dif_ints '||
              'FROM bdinvers:conciliainv WHERE fecha = '''||vfecha_hoy||''';" > /resplogifx/conciliachq/conciliainv.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/conciliainv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/conciliainv.sql";
   SYSTEM vsql;


   -- // ARCHIVO DE TODAS LAS CUENTAS DE LA CONCILIACION - CONTABILIDAD R2124
   IF vfecha_actual = vpri_hab_mes THEN
      LET vsql = '';
      LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliainv_R2124_'||vfecha||'.txt'||
                 ' SELECT sucursal, producto, genero, COUNT(*), SUM(cap_actual), SUM(int_actual) '||
                 'FROM bdinvers:conciliainv WHERE fecha = '''||vfecha_hoy||''' GROUP BY sucursal, '||
                 'producto, genero;" > /resplogifx/conciliachq/conciliainv.sql';

      SYSTEM vsql;

      LET vsql = '';
      LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/conciliainv.sql";
      SYSTEM vsql;

      LET vsql = '';
      LET vsql = "rm /resplogifx/conciliachq/conciliainv.sql";
      SYSTEM vsql;

   END IF;

   -- // ARCHIVO DE DIFERENCIAS DE LA CONCILIACION
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliainvdif_'||vfecha||'.txt '||
              'SELECT fecha, cuenta, secuencia, plazo, producto, num_cte, sucursal, ejecutivo, '||
              'cap_anterior, movscargocap, movsabonocap, cap_calculado, cap_actual, dif_sdos, '||
              'int_anterior, movscargoint, movsabonoint, int_calculado, int_actual, dif_ints '||
              'FROM bdinvers:conciliainvdif WHERE fecha = '''||vfecha_hoy||''';" > /resplogifx/conciliachq/conciliainv.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/conciliainv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/conciliainv.sql";
   SYSTEM vsql;


   -- // LLENA TABLA PARA EL SOC - TASF
   INSERT INTO bdinvers:sv_conciliainvdif
   SELECT fecha, cuenta, secuencia, plazo, producto, num_cte, sucursal, ejecutivo,
          cap_anterior, movscargocap, movsabonocap, cap_calculado, cap_actual, dif_sdos,
          int_anterior, movscargoint, movsabonoint, int_calculado, int_actual, dif_ints
     FROM bdinvers:conciliainvdif
    WHERE fecha = vfecha_hoy;

   -- // ARCHIVO GLOBALES DE LA CONCILIACION
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/conciliainvglob_'||vfecha||'.txt'||
              ' SELECT producto, COUNT(*), SUM(cap_anterior), SUM(cap_calculado), SUM(cap_actual),'||
              ' SUM(int_anterior), SUM(int_calculado), SUM(int_actual) FROM bdinvers:conciliainv '||
              ' WHERE fecha = '''||vfecha_hoy||''' GROUP BY producto;" > /resplogifx/conciliachq/conciliainv.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/conciliainv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/conciliainv.sql";
   SYSTEM vsql;


   -- // LLENA TABLA PARA EL SOC - TASF
   INSERT INTO bdinvers:sv_conciliainvglob
   SELECT fecha, producto, COUNT(*), SUM(cap_anterior), SUM(cap_calculado),
          SUM(cap_actual), SUM(int_anterior), SUM(int_calculado), SUM(int_actual)
     FROM bdinvers:conciliainv
    WHERE fecha = vfecha_hoy
    GROUP BY fecha, producto;

   -- // ARCHIVO DE MOVIMIENTOS DE INVERSIONES
   LET vsql = '';
   LET vsql = '> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movsinver_'||vfecha||'.txt" >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "SELECT a.sucursal, a.fech_alt, a.transacc, a.cuenta, b.num_cte, a.monto_tot, a.cancelad, " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "d.c_ccmayor, d.c_ccsub, d.c_ccsubsub, d.c_ccsssub, d.c_ccssssub, d.c_sector, " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "d.a_ccmayor, d.a_ccsub, d.a_ccsubsub, d.a_ccsssub, d.a_ccssssub, d.a_sector, b.secuencia " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "FROM sv_movhis a, sv_maeinv b, sv_plazotasa c, bdinteg:si_prodtran d, bdinteg:si_transacc e " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "WHERE a.empresa = ''"001"'' AND a.cuenta = b.cuenta AND a.cancelad != ''"S"'' AND a.fech_alt = ''"'||vfecha_hoy||'"'' " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "AND b.empresa = a.empresa AND b.cuenta = a.cuenta AND b.secuencia = a.secuencia " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "AND e.sistema = ''"03"'' AND b.plazo BETWEEN c.plazo_min AND c.plazo_max AND c.plaza = b.plaza " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "AND c.secuencia = d.secuencia AND d.transaccion = a.transacc AND d.producto = b.cod_instrum " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = ' echo "AND d.sistema = ''"03"'' AND e.empresa = a.empresa AND e.numero = d.transaccion AND e.se_contabiliza = ''"S"''; " >> /resplogifx/conciliachq/movs_inv.sql';
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/movs_inv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/movs_inv.sql";
   SYSTEM vsql;


   FOREACH cur_001b WITH HOLD FOR
      SELECT f.fecha_ant, a.sucursal, a.fech_alt, a.transacc, a.cuenta, b.num_cte, a.monto_tot,
             TRIM(d.c_ccmayor)||TRIM(d.c_ccsub)||TRIM(d.c_ccsubsub)||TRIM(d.c_ccsssub)||TRIM(d.c_ccssssub)||TRIM(d.c_sector),
             TRIM(d.a_ccmayor)||TRIM(d.a_ccsub)||TRIM(d.a_ccsubsub)||TRIM(d.a_ccsssub)||TRIM(d.a_ccssssub)||TRIM(d.a_sector),
             b.secuencia
        INTO sv_fecha_ant, sv_sucursal, sv_fech_alt, sv_transacc, sv_cuenta, sv_num_cte,
             sv_monto_tot, sv_cta_cargo, sv_cta_abono, sv_secuencia
        FROM bdinvers:sv_movhis a, bdinvers:sv_maeinv b, bdinvers:sv_plazotasa c,
             bdinteg:si_prodtran d, bdinteg:si_transacc e, bdinvers:sv_fechas f
       WHERE a.empresa = '001'
         AND a.cuenta = b.cuenta
         AND a.cancelad <> 'S'
         AND a.fech_alt = f.fecha_ant
         AND b.empresa = a.empresa
         AND b.cuenta = a.cuenta
         AND b.secuencia = a.secuencia
         AND b.plazo BETWEEN c.plazo_min AND c.plazo_max
         AND c.plaza = b.plaza
         AND c.secuencia = d.secuencia
         AND d.transaccion = a.transacc
         AND d.producto = b.cod_instrum
         AND d.sistema = '03'
         AND e.empresa = a.empresa
         AND e.numero = d.transaccion
         AND e.se_contabiliza = 'S'
         AND f.empresa = a.empresa
         AND e.sistema = '03'

       -- Abre la transaccion
       IF (vcomienza1 = -1) THEN
          LET vcomienza1 = 0;
          LET ven_transacc1 = 1;
          BEGIN WORK;
       END IF;

       INSERT INTO bdinvers:sv_movsinver (fecha, sucursal, fech_alt, transacc, cuenta, num_cte,
                                          monto_tot, cta_cargo, cta_abono, secuencia)
            VALUES (sv_fecha_ant, sv_sucursal, sv_fech_alt, sv_transacc, sv_cuenta,
                    sv_num_cte, sv_monto_tot, sv_cta_cargo, sv_cta_abono, sv_secuencia);

       LET vconta = vconta + 1;

	   --Realiza commit cada 1000 registros
       IF (vconta >= 1000) THEN
          LET vconta = 0;
          COMMIT WORK;
          BEGIN WORK;
       END IF;

   END FOREACH;

   IF (ven_transacc1 = 1) THEN
      LET ven_transacc1 = 0;
      COMMIT WORK;
   END IF;


   -- // ARCHIVO DE ALTAS DE INVERSIONES NO REFLEJADAS EN HISTORICO DE CHEQUES
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/altainvsintranchq_'||vfecha||'.txt '||
              ' SELECT * FROM bdinvers:sv_maeinv WHERE fecha_alta = '''||vfecha_hoy||''' AND secuencia = 1'||
              ' AND cta_cheques NOT IN (SELECT cuenta FROM bdicheq:sc_movhis WHERE transacc = ''0235'''||
              ' AND cancelad != ''S'' AND fech_alt = '''||vfecha_hoy||''')" > /resplogifx/conciliachq/altas_inv.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/altas_inv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/altas_inv.sql";
   SYSTEM vsql;


   -- // -- // LLENA TABLA PARA EL SOC - TASF
   INSERT INTO bdinvers:sv_altainvsintranchq
   SELECT b.fecha_ant, a.empresa, a.cuenta, a.secuencia, a.cod_instrum, a.num_cte, a.status_cta, a.motivo, a.fec_ult_mov,
          a.fec_cancelac, a.fec_reinversion, a.capital, a.sdo_retenido, a.sdo_cong, a.plazo, a.fecha_venc, a.opcion_retiro,
          a.intereses, a.isr, a.tasa, a.sobretasa, a.dia_sdo_pos, a.acum_sdo_pos, a.sdo_prom_mesant, a.sdo_mes_ant,
          a.sdo_dia_ant, a.sdo_ult_corte, a.adicionado, a.fecha_alta, a.fecha_val, a.modificado, a.fecha_mod,
          a.cta_cheques, a.sucursal, a.plaza, a.promotor, a.tipo_banca, a.reg_firmas, a.envio, a.direcc_envio,
          a.cobraisr, a.per_acred_int  
     FROM bdinvers:sv_maeinv a
    INNER JOIN bdinvers:sv_fechas b ON a.empresa = b.empresa
    WHERE a.fecha_alta = vfecha_hoy
      AND a.secuencia = 1
      AND a.cta_cheques NOT IN (SELECT cuenta
                                  FROM bdicheq:sc_movhis
                                 WHERE transacc = '0235'
                                   AND cancelad <> 'S'
                                   AND fech_alt = vfecha_hoy);


   -- // ARCHIVO DE CARGOS PROCEDENTES DE CHEQUES NO REFLEJADOS EN ALTAS DE INVERSIONES
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/cargochqsinaltainv_'||vfecha||'.txt '||
              ' SELECT * FROM bdicheq:sc_movhis WHERE transacc = ''0235'' AND fech_alt = '''||vfecha_hoy||''''||
              ' AND cancelad != ''S'' AND cuenta NOT IN (SELECT cta_cheques FROM bdinvers:sv_maeinv'||
              ' WHERE fecha_alta = '''||vfecha_hoy||''' AND status_cta = ''1'');" > /resplogifx/conciliachq/cargos_inv.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/cargos_inv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/cargos_inv.sql";
   SYSTEM vsql;


   -- // -- // LLENA TABLA PARA EL SOC - TASF
   /*INSERT INTO bdinvers:sv_cargochqsinaltainv
   SELECT b.fecha_ant, a.aniomes, a.num_serial, a.folio_suc, a.sucursal, a.usuario, a.fech_alt, a.fech_val, a.fech_hor,
          a.transacc, a.suc_cuen, a.producto, a.empresa, a.cuenta, a.causa_dev, a.num_cheq, a.monto_tot, a.firme, a.en_sbc,
          a.remesas, a.dias_ret, a.cancelad, a.edo_cta, a.sdo_cuenta, a.transacc_suc, a.referencia, a.tasa_aplicada,
          a.num_tarjeta, a.usuautoriza, a.referencia_23
     FROM bdicheq:sc_movhis a, bdinvers:sv_fechas b
    WHERE a.transacc = '0235'
      AND a.fech_alt = vfecha_hoy
      AND a.cancelad <> 'S'
      AND a.cuenta NOT IN (SELECT cta_cheques
                             FROM bdinvers:sv_maeinv
                            WHERE fecha_alta = vfecha_hoy
                              AND status_cta = '1')
      AND a.empresa = b.empresa;*/
	  
   INSERT INTO bdinvers:sv_cargochqsinaltainv
   SELECT (select fecha_ant from bdinvers:sv_fechas where empresa='001') as fecha,a.aniomes, a.num_serial, a.folio_suc, a.sucursal, a.usuario, a.fech_alt, a.fech_val, a.fech_hor,
          a.transacc, a.suc_cuen, a.producto, a.empresa, a.cuenta, a.causa_dev, a.num_cheq, a.monto_tot, a.firme, a.en_sbc,
          a.remesas, a.dias_ret, a.cancelad, a.edo_cta, a.sdo_cuenta, a.transacc_suc, a.referencia, a.tasa_aplicada,
          a.num_tarjeta, a.usuautoriza, a.referencia_23
     FROM bdicheq:sc_movhis a, bdinvers:sv_fechas b
    WHERE a.transacc = '0235'
      AND a.fech_alt = vfecha_hoy
      AND a.cancelad <> 'S'
      AND a.cuenta NOT IN (SELECT cta_cheques
                             FROM bdinvers:sv_maeinv
                            WHERE fecha_alta = vfecha_hoy
                              AND status_cta = '1')
      AND a.empresa = b.empresa;
	  
	  

   -- // ARCHIVO DE CARGOS REVERSADOS DE ALTAS DE INVERSIONES
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/cargoreverinv_'||vfecha||'.txt '||
              ' SELECT cuenta, sucursal, monto_tot FROM bdicheq:sc_movhis WHERE transacc = ''0235'''||
              ' AND cancelad = ''S'' AND fech_alt = '''||vfecha_hoy||''' AND monto_tot > 0;" > /resplogifx/conciliachq/rever_inv.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/rever_inv.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/rever_inv.sql";
   SYSTEM vsql;

   -- // LLENA TABLA PARA EL SOC - TASF
   INSERT INTO bdinvers:sv_cargoreverinv
   SELECT fech_alt, cuenta, sucursal, monto_tot
     FROM bdicheq:sc_movhis
    WHERE transacc = '0235'
      AND cancelad = 'S'
      AND fech_alt = vfecha_hoy
      AND monto_tot > 0;

   -- // ARCHIVO DE MOVIMIENTOS PROCEDENTES DE INVERSIONES NO APLICADOS EN CHEQUES
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movinvernoaplichq_'||vfecha||'.txt '||
              ' SELECT * FROM bdicheq:sc_movinver WHERE fecha_apli = '''||vfecha_actual||''''||
              ' AND procesado = ''N'';" > /resplogifx/conciliachq/movs_inver.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/movs_inver.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/movs_inver.sql";
   SYSTEM vsql;

   --//Se crea el index para el campo 'fecha_apli' se borra el sequential scan
   -- // LLENA TABLA PARA EL SOC - TASF
   INSERT INTO bdinvers:sv_movinvernoaplichq
   SELECT fecha_apli, *
     FROM bdicheq:sc_movinver
    WHERE fecha_apli = vfecha_actual
      AND procesado = 'N';

   -- // ARCHIVO DE INVERSIONES VENCIDAS VIGENTES (STATUS 1)
   LET vsql = '';
   LET vsql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/invvencvig_'||vfecha||'.txt '||
              ' SELECT * FROM bdinvers:sv_maeinv WHERE status_cta = ''1'''||
              ' AND fecha_venc < '''||vfecha_actual||''';" > /resplogifx/conciliachq/venc_vig.sql';

   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/venc_vig.sql";
   SYSTEM vsql;

   LET vsql = '';
   LET vsql = "rm /resplogifx/conciliachq/venc_vig.sql";
   SYSTEM vsql;

   LET vsql = '';


   -- // LLENA TABLA PARA EL SOC - TASF
   /*INSERT INTO bdinvers:sv_invvencvig
   SELECT (SELECT fecha_hoy FROM bdinvers:sv_fechas WHERE empresa = '001') AS fecha_hoy, a.empresa, a.cuenta, a.secuencia,
          a.cod_instrum, a.num_cte, a.status_cta, a.motivo, a.fec_ult_mov, a.fec_cancelac, a.fec_reinversion, a.capital,
		  a.sdo_retenido, a.sdo_cong, a.plazo, a.fecha_venc, a.opcion_retiro, a.intereses, a.isr, a.tasa, a.sobretasa,
		  a.dia_sdo_pos, a.acum_sdo_pos, a.sdo_prom_mesant, a.sdo_mes_ant, a.sdo_dia_ant, a.sdo_ult_corte, a.adicionado,
		  a.fecha_alta, a.fecha_val, a.modificado, a.fecha_mod, a.cta_cheques, a.sucursal, a.plaza, a.promotor, a.tipo_banca,
          a.reg_firmas, a.envio, a.direcc_envio, a.cobraisr, a.per_acred_int
     FROM bdinvers:sv_maeinv a
    WHERE a.status_cta = '1' 
	  AND a.fecha_venc < vfecha_actual;*/
	  
   INSERT INTO bdinvers:sv_invvencvig
   SELECT (SELECT fecha_hoy FROM bdinvers:sv_fechas WHERE empresa = '001') AS fecha, a.empresa, a.cuenta, a.secuencia,
          a.cod_instrum, a.num_cte, a.status_cta, a.motivo, a.fec_ult_mov, a.fec_cancelac, a.fec_reinversion, a.capital,
		  a.sdo_retenido, a.sdo_cong, a.plazo, a.fecha_venc, a.opcion_retiro, a.intereses, a.isr, a.tasa, a.sobretasa,
		  a.dia_sdo_pos, a.acum_sdo_pos, a.sdo_prom_mesant, a.sdo_mes_ant, a.sdo_dia_ant, a.sdo_ult_corte, a.adicionado,
		  a.fecha_alta, a.fecha_val, a.modificado, a.fecha_mod, a.cta_cheques, a.sucursal, a.plaza, a.promotor, a.tipo_banca,
          a.reg_firmas, a.envio, a.direcc_envio, a.cobraisr, a.per_acred_int
     FROM bdinvers:sv_maeinv a
    WHERE a.status_cta = '1' 
	  AND a.fecha_venc < vfecha_actual;

   -- // ARCHIVO DE SALDOS DIARIOS DE INVERSIONES
   CALL sdos_diarios_inv()
      RETURNING vcodret1;

END;

RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;