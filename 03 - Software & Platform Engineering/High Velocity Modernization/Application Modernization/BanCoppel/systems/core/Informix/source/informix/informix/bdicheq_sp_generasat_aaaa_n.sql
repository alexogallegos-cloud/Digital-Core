CREATE PROCEDURE "informix".sp_generasat_aaaa_n( pEjercicio char(4), pEmpresa char(3) )
RETURNING CHAR(5); 

    DEFINE vt_Ejercicio         char(4);
    DEFINE vt_Empresa           char(3);
    DEFINE v_codret 	        char(5);
    DEFINE isql_err    	        INTEGER;
    DEFINE v_campo 		        lvarchar(950);
    DEFINE v_campod 	        lvarchar(460);
    DEFINE v_campoDir 	        lvarchar(295);
    DEFINE vc_campodirSp        lvarchar(295);
    DEFINE v_Tipo		        INTEGER;
    DEFINE v_ConsecReg	        CHAR(8);
    DEFINE v_ConsecDOMI	        CHAR(8);
    DEFINE v_ConsecDir	        CHAR(8);
    DEFINE v_ConsecDET          CHAR(8);
    DEFINE v_iConsecReg	        integer;
    DEFINE v_iConsecDir	        integer;
    DEFINE v_ConsecArc	        CHAR(3);
    DEFINE v_ConsecNom	        CHAR(3);
    DEFINE v_fecha		        CHAR(8);	
    DEFINE v_rfcArc		        CHAR(13);
    DEFINE v_rfcArcC	        CHAR(12);
    DEFINE v_rfcClt		        CHAR(13);
    DEFINE v_moneda		        CHAR(1);
    DEFINE v_usoFut		        CHAR(1);
    DEFINE d_fecha		        date;
    DEFINE vt_sdoprom1          DECIMAL(12,2);
    DEFINE vt_sdoprom2          DECIMAL(12,2);
    DEFINE vt_sdoprom3          DECIMAL(12,2);
    DEFINE vt_sdoprom4          DECIMAL(12,2);
    DEFINE vt_sdoprom5          DECIMAL(12,2);
    DEFINE vt_sdoprom6          DECIMAL(12,2);
    DEFINE vt_sdoprom7          DECIMAL(12,2);
    DEFINE vt_sdoprom8          DECIMAL(12,2);
    DEFINE vt_sdoprom9          DECIMAL(12,2);
    DEFINE vt_sdoprom10         DECIMAL(12,2);
    DEFINE vt_sdoprom11         DECIMAL(12,2);
    DEFINE vt_sdoprom12         DECIMAL(12,2);
    DEFINE vt_cuenta            CHAR(20);
    DEFINE vt_cliente           CHAR(20);
    DEFINE vt_intereses         DECIMAL(12,2);
    DEFINE vt_interesexento     DECIMAL(12,2);
    DEFINE vt_interesrealt      DECIMAL(12,2);
    DEFINE vt_isrt              DECIMAL(12,2);
    DEFINE vt_tasaperiodo_n     DECIMAL(12,6);
    DEFINE vt_perdida           DECIMAL(10,2);
    DEFINE vt_ajus_infla	    DECIMAL(26,2);
    DEFINE vt_ajus_defla   	    DECIMAL(26,2);
    DEFINE vt_inter_nom_tot     DECIMAL(26,2);
    DEFINE vt_inte_nom_gra      DECIMAL(26,2);
    DEFINE vt_inte_nom_ext      DECIMAL(26,2);
    DEFINE vt_inter_nom_totC    CHAR(29);
    DEFINE vt_inte_nom_graC     CHAR(29);
    DEFINE vt_inte_nom_extC     CHAR(29);
    DEFINE vt_razon_social      CHAR(18);
    DEFINE vt_nombre  		    CHAR(50);
    DEFINE vt_materno		    CHAR(50);
    DEFINE vt_paterno		    CHAR(50);
    DEFINE vt_NomCompl		    CHAR(150);
    DEFINE vt_tpo_persona       CHAR(2);
    DEFINE vt_tpo_personaF      CHAR(1);
    DEFINE v_identiReg		    CHAR(1);
    DEFINE vt_curp			    CHAR(1);
    DEFINE v_contnum		    integer;
    DEFINE v_codretdir  	    char(5);
    DEFINE v_calle			    char(130);
    DEFINE v_numext			    char(12);
    DEFINE v_numint			    char(12);
    DEFINE v_colonia		    char(65);
    DEFINE v_cp 			    char(6);
    DEFINE v_municipio		    char(50);
    DEFINE v_estado			    char(20);
    DEFINE v_cNombre 		    CHAR(25);
    DEFINE v_cNombreFinal 		CHAR(25);
    DEFINE sRutaArchivo         CHAR(40);
    DEFINE vsSQL1               CHAR(150);
    DEFINE vsSQL2               CHAR(150);
    DEFINE vsSQL3               CHAR(150);
    DEFINE vsSQL                CHAR(450);
    DEFINE v_contFin            char(8);
    DEFINE v_icontFin           char(8);
    DEFINE v_RestGen            integer;
    DEFINE v_iLongiCuen         integer;
    DEFINE vt_cuenta2           int8;
    DEFINE v_Valor1             char(1);
    DEFINE vc_signo1            char(1);
    DEFINE vc_signo2            CHAR(1);
    DEFINE vc_signo3            CHAR(1);
    DEFINE vc_signo4            CHAR(1);
    DEFINE vc_signo5            CHAR(1);
    DEFINE vc_signo6            CHAR(1);
    DEFINE vc_signo7            CHAR(1);
    DEFINE vc_signo8            CHAR(1);
    DEFINE vc_signo9            CHAR(1);
    DEFINE vc_signo10           CHAR(1);
    DEFINE vc_signo11           CHAR(1);
    DEFINE vc_signo12           CHAR(1);
    DEFINE vc_signoPer          CHAR(1);
    DEFINE vanio                SMALLINT;

    LET v_cNombreFinal      = "";
    LET v_cNombre           = "";
    LET sRutaArchivo        = "";
    LET vt_Ejercicio        = "";
    LET vt_Empresa          = "";
    LET v_codret            = "00000";
    LET v_campo             = "";
    LET v_Tipo              = 1;
    LET v_ConsecReg         = "";
    LET v_ConsecDET         = "";
    LET v_ConsecDOMI        = "";
    LET v_ConsecArc         = "";
    LET v_fecha             = "";
    LET v_rfcArc            = "";
    LET v_moneda            = "";
    LET v_usoFut            = "";
    LET vt_intereses        = "";
    LET vt_interesexento    = "";
    LET vt_interesrealt     = "";
    LET vt_isrt             = "";
    LET vt_perdida          = "";
    LET vt_ajus_infla       = "";
    LET vt_ajus_defla       = "";
    LET vt_inter_nom_tot    = "";
    LET vt_inte_nom_gra     = "";
    LET vt_inte_nom_ext     = "";
    LET vt_inter_nom_totC   = "";
    LET vt_inte_nom_graC    = "";
    LET vt_inte_nom_extC    = "";
    LET vt_razon_social     = "";
    LET vt_nombre           = "";
    LET vt_materno          = "";
    LET vt_paterno          = "";
    LET vt_tpo_persona      = "";
    LET vt_sdoprom1         = 0.0;
    LET vt_sdoprom2         = 0.0;
    LET vt_sdoprom3         = 0.0;
    LET vt_sdoprom4         = 0.0;
    LET vt_sdoprom5         = 0.0;
    LET vt_sdoprom6         = 0.0;
    LET vt_sdoprom7         = 0.0;
    LET vt_sdoprom8         = 0.0;
    LET vt_sdoprom9         = 0.0;
    LET vt_sdoprom10        = 0.0;
    LET vt_sdoprom11        = 0.0;
    LET vt_sdoprom12        = 0.0;
    LET vt_cuenta           = "";
    LET vt_cliente          = "";
    LET v_identiReg         = 2;
    LET vt_curp             = "";
    LET v_contnum           = 0;
    LET v_ConsecDir         = "";
    LET v_codretdir         = "";
    LET v_calle		        = "";
    LET v_numext	        = "";
    LET v_numint	        = "";
    LET v_colonia	        = "";
    LET v_cp 		        = "";
    LET v_municipio	        = "";
    LET v_estado	        = "";
    LET v_cNombre           = "";
    LET sRutaArchivo        = "";
    LET vsSQL               = "";
    LET vsSQL1              = "";
    LET vsSQL2              = "";
    LET vsSQL3              = "";
    LET v_contFin           = "0";
    LET v_RestGen           = 0;
    LET vt_NomCompl         = "";
    LET vt_tpo_personaF     = "";
    LET v_Valor1            = " "; 
    LET v_campod            = "";
    LET v_campoDir          = "";
    LET vc_signo1           = "";
    LET vc_signo2           = "";
    LET vc_signo3           = "";
    LET vc_signo4           = "";
    LET vc_signo5           = "";
    LET vc_signo6           = "";
    LET vc_signo7           = "";
    LET vc_signo8           = "";
    LET vc_signo9           = "";
    LET vc_signo10          = "";
    LET vc_signo11          = "";
    LET vc_signo12          = "";
    LET vc_campodirSp       = "";
    LET vanio               = pEjercicio;
    
    BEGIN
    
    ON EXCEPTION SET isql_err
        IF isql_err <> 0 THEN
            LET v_codret=isql_err;
            RETURN v_codret;
        END IF;
    END EXCEPTION;

	--- set debug file to "/sp_generasat_2012_1.out";
    --- trace on;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    truncate table bdicheq:sc_archivsat;
    
    -- // Se optiene el rfc de la empersa
    SELECT rfc 
      INTO v_rfcArc
      FROM bdinteg:si_empresas  
     WHERE empresa = pEmpresa;
     
    -- // Se genera el consecutivo de registro del archivo
    LET v_ConsecReg =  lpad('1',8,'0');
    
    -- // Se genera el consecutivo del archivo
    LET v_ConsecArc =  lpad('1',3,'0');
    
    -- // se obtiene la fecha
    SELECT fecha_hoy
      INTO d_fecha
      FROM BDINTEG:SI_FECHAS; 
      
    LET v_fecha = substr(d_fecha,7,4) || substr(d_fecha,1,2) || substr(d_fecha,4,2);
    LET v_ConsecNom =  lpad('1',3,'0');
    
    IF LENGTH(v_rfcArc) = 12 THEN
        LET v_rfcArcC = v_rfcArc;
        LET v_cNombre = v_rfcArcC ||  pEjercicio || v_ConsecNom ||  'II';
        LET v_cNombre = TRIM(v_cNombre);
        LET v_cNombreFinal = v_rfcArcC ||  pEjercicio || v_ConsecNom ||  'I';
        LET v_cNombreFinal = TRIM(v_cNombreFinal);
        LET v_campo = v_Tipo || "|" || v_ConsecReg || "|" ||  v_ConsecArc || "|" || v_fecha || "|" || pEjercicio || "|" || v_rfcArcC || "|" || "0" || "|" || "|" ;
    ELSE
        LET v_cNombre = v_rfcArc ||  pEjercicio || v_ConsecNom ||  'II';
        LET v_cNombre = TRIM(v_cNombre);
        LET v_cNombreFinal = v_rfcArc ||  pEjercicio || v_ConsecNom ||  'I';
        LET v_cNombreFinal = TRIM(v_cNombreFinal);
        LET v_campo = v_Tipo || "|" || v_ConsecReg || "|" ||  v_ConsecArc || "|" || v_fecha || "|" || pEjercicio || "|" || v_rfcArc || "|" || "0" || "|" || "|" ;
    END IF;
    
    Insert INTO bdicheq:sc_archivsat(campo)
    VALUES (v_campo);
    
    -- // Se inserta los siguientes datos
    FOREACH
        SELECT isr.empresa, isr.ejercicio, isr.num_cte, isr.cuenta, isr.interes_pagado, isr.interes_exento, isr.interes_real, isr.reten_interes,
               isr.sdo_prom1, isr.sdo_prom2, isr.sdo_prom3, isr.sdo_prom4, isr.sdo_prom5, isr.sdo_prom6, isr.sdo_prom7, isr.sdo_prom8, isr.sdo_prom9, 
			   isr.sdo_prom10, isr.sdo_prom11, isr.sdo_prom12,ROUND(isr.tasa_prom,6), isr.perdida, isr.ajuste_inflacion, isr.ajuste_deflasion, 
			   isr.interes_nominal_total, isr.interes_nominal_exento, isr.interes_nominal_gravado, 
               CASE WHEN REPLACE(cte.rfc_alterno,' ','') = '' THEN cte.rfc WHEN cte.rfc_alterno IS NULL THEN cte.rfc ELSE cte.rfc_alterno END,
			   trim(cte.razon_social), trim(cte.nombre1)||' '||trim(cte.nombre2) as nombre, trim(cte.apell_paterno) as paterno, 
			   trim(cte.apell_materno)as materno, cte.tpo_persona
        INTO   vt_Empresa, vt_Ejercicio, vt_cliente, vt_cuenta2, vt_intereses, vt_interesexento, vt_interesrealt, vt_isrt, 
               vt_sdoprom1, vt_sdoprom2, vt_sdoprom3, vt_sdoprom4, vt_sdoprom5, vt_sdoprom6, vt_sdoprom7, vt_sdoprom8, vt_sdoprom9, 
			   vt_sdoprom10, vt_sdoprom11, vt_sdoprom12, vt_tasaperiodo_n, vt_perdida, vt_ajus_infla, vt_ajus_defla, 
			   vt_inter_nom_tot, vt_inte_nom_ext, vt_inte_nom_gra, 
               v_rfcClt, 
			   vt_razon_social, vt_nombre, vt_paterno, 
			   vt_materno, vt_tpo_persona 
          FROM bdicheq:sc_retenisr isr, 
               bdinteg:si_cliente cte 
         WHERE isr.empresa = pEmpresa
           AND isr.ejercicio = vanio
           AND isr.cuenta >= '10000005016' 
           AND isr.cuenta <  '10013142420'        ----------150000
           AND cte.numcte = isr.num_cte
           AND cte.empresa = isr.empresa
           AND cte.rfc NOT IN('HELR690104L51','RUYM851011DP2','ZAAJ860221TX7','UUSE740809642','LOHA5211301N3','AOLE6905308P8','SOLA6207225M2','CUSG560324M35',
'LARR9207122EA','GAGF880311PX5','LOSR6308309V4','GALS55081128A','HEGC8001132F9','EEAA691229I25','BAMR660908A5A','OICJ780516LG0','HECM861028AB6','XAER820303RK5',
'SOLA741113NY4','CESE6405025V4','PEAL6811108N2','MOTN720723P75','RORM6206152F5','GOZK891215DV2','GASP690723BS0','NALT890115GU8','PECM841108GE6','MOGE910213TCA',
'SIAP630628AE0','VEVD750619AD7','PULA930109DD1','LEVA810918FJ8','MOGJ480624TQ7','AECB900227JR8','MABV550929PE6','HEFN610502UV4','AURG920415J47','TAPB810127UK3',
'LOSE920829J82','GOMR4912277M5','GOYE54122812A','OICJ780516MS4','LURM710126U5A','GAGM480610GU4' ) 
           
        IF vt_inter_nom_tot <= 0 THEN
            continue FOREACH;
        END IF;
        
        -- // se inicializa el tipo de registro = 2
        LET v_Tipo = 2;
        
        -- // Consecutivo del registro 
        LET v_ConsecReg = v_ConsecReg + 1;
        LET v_ConsecReg =  lpad(TRIM((v_ConsecReg::integer)::char(8)),8,'0');

        IF vt_tpo_persona = "01" THEN
            LET vt_NomCompl = vt_nombre || vt_paterno || vt_materno;
            LET vt_tpo_persona = "F";
        ELIF vt_tpo_persona = "02" THEN
            LET vt_NomCompl = vt_razon_social;
            LET vt_tpo_persona = "M";
        ELIF vt_tpo_persona = "03" THEN
            LET vt_NomCompl = vt_nombre || vt_paterno || vt_materno;
            LET vt_tpo_persona = "E";
        ELIF vt_tpo_persona = "X" THEN
            LET vt_NomCompl = vt_nombre || vt_paterno || vt_materno;
            LET vt_tpo_persona = "X";
        ELIF vt_tpo_persona = "S" THEN
            LET vt_NomCompl = vt_nombre || vt_paterno || vt_materno;
            LET vt_tpo_persona = "S";
        ELSE
            LET vt_tpo_persona = "F";
        END IF;
        
        LET v_rfcClt = trim(v_rfcClt);

        -- // SE hacen las validaciones mensuales
        IF vt_sdoprom1 >= 0 THEN
            LET vc_signo1 = " ";
        ELSE
            LET vc_signo1 = "-";
            LET vt_sdoprom1 = vt_sdoprom1 * (-1);
        END IF;
        
        IF vt_sdoprom2 >= 0 THEN
            LET vc_signo2 = " ";
        ELSE
            LET vc_signo2 = "-";
            LET vt_sdoprom2 = vt_sdoprom2 * (-1);
        END IF;
        
        IF vt_sdoprom3 >= 0 THEN
            LET vc_signo3 = " ";
        ELSE
            LET vc_signo3 = "-";
            LET vt_sdoprom3 = vt_sdoprom3 * (-1);
        END IF;
        
        IF vt_sdoprom4 >= 0 THEN
            LET vc_signo4 = " ";
        ELSE
            LET vc_signo4 = "-";
            LET vt_sdoprom4 = vt_sdoprom4 * (-1);
        END IF;
        
        IF vt_sdoprom5 >= 0 THEN
            LET vc_signo5 = " ";
        ELSE
            LET vc_signo5 = "-";
            LET vt_sdoprom5 = vt_sdoprom5 * (-1);
        END IF;
        
        IF vt_sdoprom6 >= 0 THEN
            LET vc_signo6 = " ";
        ELSE
            LET vc_signo6 = "-";
            LET vt_sdoprom6 = vt_sdoprom6 * (-1);
        END IF;
        
        IF vt_sdoprom7 >= 0 THEN
            LET vc_signo7 = " ";
        ELSE
            LET vc_signo7 = "-";
            LET vt_sdoprom7 = vt_sdoprom7 * (-1);
        END IF;
        
        IF vt_sdoprom8 >= 0 THEN
            LET vc_signo8 = " ";
        ELSE
            LET vc_signo8 = "-";
            LET vt_sdoprom8 = vt_sdoprom8 * (-1);
        END IF;
        
        IF vt_sdoprom9 >= 0 THEN
            LET vc_signo9 = " ";
        ELSE
            LET vc_signo9 = "-";
            LET vt_sdoprom9 = vt_sdoprom9 * (-1);
        END IF;
        
        IF vt_sdoprom10 >= 0 THEN
            LET vc_signo10 = " ";
        ELSE
            LET vc_signo10 = "-";
            LET vt_sdoprom10 = vt_sdoprom10 * (-1);
        END IF;
        
        IF vt_sdoprom11 >= 0 THEN
            LET vc_signo11 = " ";
        ELSE
            LET vc_signo11 = "-";
            LET vt_sdoprom11 = vt_sdoprom11 * (-1);
        END IF;
        
        IF vt_sdoprom12 >= 0 THEN
            LET vc_signo12 = " ";
        ELSE
            LET vc_signo12 = "-";
            LET vt_sdoprom12 = vt_sdoprom12 * (-1);
        END IF;
        
        IF vt_perdida >= 0 THEN
            LET vc_signoPer = " ";
        ELSE
            LET vc_signoPer = "-";
            LET vt_perdida = vt_perdida * (-1);
        END IF;
        
        LET vt_tpo_personaF = vt_tpo_persona;
        
        IF vt_inte_nom_gra >= 0 THEN
            IF vt_inte_nom_ext >= 0 THEN
                IF vt_inter_nom_tot >= 0 THEN
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || v_Valor1 || vt_inte_nom_gra || "|" ||  v_Valor1 || vt_inte_nom_ext || "|" || v_Valor1 ||  vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                ELSE
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || v_Valor1 || vt_inte_nom_gra || "|" ||  v_Valor1 || vt_inte_nom_ext || "|" || vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "N"  || "|" ||  "|";
                END IF;
            ELSE
                IF vt_inter_nom_tot >= 0 THEN
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || v_Valor1 || vt_inte_nom_gra || "|" ||   vt_inte_nom_ext || "|" || v_Valor1 ||  vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                ELSE
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || v_Valor1 || vt_inte_nom_gra || "|" ||    vt_inte_nom_ext || "|" || vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                END IF;
            END IF;
        ELSE
            IF vt_inte_nom_ext >= 0 THEN
                IF vt_inter_nom_tot >= 0 THEN
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || vt_inte_nom_gra || "|" ||  v_Valor1 || vt_inte_nom_ext || "|" || v_Valor1 ||  vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                ELSE
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" ||vt_inte_nom_gra || "|" ||  v_Valor1 || vt_inte_nom_ext || "|" || vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                END IF;
            ELSE
                IF vt_inter_nom_tot >= 0 THEN
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || vt_inte_nom_gra || "|" ||   vt_inte_nom_ext || "|" || v_Valor1 ||  vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                ELSE
                    LET v_campo =  v_Tipo || "|" || v_ConsecReg || "|" || v_identiReg || "|" || v_rfcClt || "|" || vt_curp || "|" ||  vt_NomCompl || "|" || vt_tpo_personaF || "|" || 
                                   vt_cuenta2 || "|" || vt_inte_nom_gra || "|" ||    vt_inte_nom_ext || "|" || vt_inter_nom_tot || "|" || vt_ajus_infla || "|" || vt_ajus_defla || "|" || vt_interesrealt || "|" || vc_signoPer || vt_perdida || "|" || 
                                   vt_isrt || "|" || vc_signo1 || vt_sdoprom1 || "|" || vc_signo2 ||  vt_sdoprom2 || "|" ||  vc_signo3 || vt_sdoprom3 || "|" ||  vc_signo4 || vt_sdoprom4 || "|" ||  vc_signo5 || vt_sdoprom5 || "|" || vc_signo6 || vt_sdoprom6 || "|" ||  
                                   vc_signo7 || vt_sdoprom7 || "|" ||  vc_signo8 || vt_sdoprom8 || "|" || vc_signo9 || vt_sdoprom9 || "|" || vc_signo10 || vt_sdoprom10 || "|" ||  vc_signo11 || vt_sdoprom11 || "|" ||  vc_signo12 || vt_sdoprom12 || "|" || "N"  || "|" ||  "|";
                END IF;
            END IF;
        END IF;

        Insert INTO bdicheq:sc_archivsat(campo)
        VALUES (v_campo);
        
        TRUNCATE TABLE bdicheq:sc_directemp;

        -- // Consecutivo del registro 
        LET v_ConsecDOMI = v_ConsecReg;
        
        EXECUTE PROCEDURE cons_dir_cte(vt_cliente,1) 
        INTO v_codretdir;
        
        FOREACH
            select calle,numext,numint,colonia,cp,municipio,estado
              INTO v_calle,v_numext, v_numint, v_colonia, v_cp, v_municipio, v_estado
              FROM bdicheq:sc_directemp
                
            LET v_ConsecReg = v_ConsecReg + 1;
            LET v_ConsecReg =  lpad(trim((v_ConsecReg::integer)::char(8)),8,'0');
            
            -- // Consecutivo de direccion
            LET v_ConsecDir = v_ConsecReg - 1;
            LET v_ConsecDir =  lpad(trim((v_ConsecDir::integer)::char(8)),8,'0');

            IF (v_calle is null) or (v_calle = "") THEN
                LET v_calle = "";
            END IF;
            
            IF (v_numext is null) or (v_numext = "") THEN
                LET v_numext = "";
            END IF;
            
            IF (v_numint is null) or (v_numint = "") THEN
                LET v_numint = "";
            END IF;
            
            IF (v_colonia is null) or (v_colonia = "") THEN
                LET v_colonia = "";
            END IF;
            
            IF (v_cp is null) or (v_cp = "") THEN
                LET v_cp = "S/CP";
            END IF;
            
            IF (v_municipio is null) or (v_municipio = "") THEN
                LET v_municipio = "";
            END IF;
            
            IF (v_estado is null) or (v_estado = "") THEN
                LET v_estado = "S/E";
            END IF;
            
            LET v_Tipo = 3;
            LET v_municipio = v_municipio;
            LET v_estado = v_estado;
            LET v_campoDir =  v_calle || v_numext || v_numint ||  v_colonia ||  v_cp ||  v_municipio ||  v_estado;
            
            EXECUTE PROCEDURE bdicheq:sp_valida_cadena_sat(v_campoDir) 
            INTO vc_campodirSp;
            
            LET v_campod = v_Tipo || "|" || v_ConsecReg	|| "|" || v_ConsecDOMI	|| "|" || vt_cuenta2 ||"|"  ||v_rfcClt	|| "|" || vc_campodirSp || "||"; 
            
            Insert INTO bdicheq:sc_archivsat(campo)
            VALUES (v_campod);	
        END FOREACH;
        
        LET v_contFin = v_contFin + 1;	
    END FOREACH;
    
    LET v_contFin =  lpad(trim((v_contFin::integer)::char(8)),8,'0');
    LET v_ConsecReg = v_ConsecReg + 1;
    LET v_ConsecReg =  lpad(trim((v_ConsecReg::integer)::char(8)),8,'0');
    LET v_Tipo = 9;
    LET v_campo = v_Tipo || "|" || v_ConsecReg || "|" || v_contFin || "|" || "1" || "|||";
    
    Insert INTO bdicheq:sc_archivsat(campo)
    VALUES (v_campo);
    
    LET sRutaArchivo = "/resplogifx/conciliachq/";
    LET sRutaArchivo = trim(sRutaArchivo);
    LET vsSQL1 = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || trim(sRutaArchivo) || TRIM(v_cNombre)  || ' DELIMITER ' || '''?''';
    LET vsSQL2 = ' SELECT campo FROM bdicheq:sc_archivsat ORDER BY keyx ASC;' ;
    LET vsSQL3 = ' " > '|| TRIM(sRutaArchivo) || 'tmp_SAT.sql';
    LET vsSQL1 = TRIM(vsSQL1);
    LET vsSQL3 = TRIM(vsSQL3);
    LET vsSQL = TRIM(vsSQL1) || ' ' ||  TRIM(vsSQL2) || TRIM(vsSQL3);
    
    IF ( vsSQL <> '' ) THEN
        SYSTEM vsSQL ;
        LET vsSQL = '' ;
        LET vsSQL = 'dbaccess bdicheq ' || TRIM(sRutaArchivo) || 'tmp_SAT.sql';
        SYSTEM vsSQL ;
    End IF;
    
    LET vsSQL = '';
    LET vsSQL =  "sed 's/?$//g' /resplogifx/conciliachq/" || v_cNombre || " > " || " " || trim(sRutaArchivo) || v_cNombreFinal;
    SYSTEM vsSQL;
    LET vsSQL = '';
    LET vsSQL = 'rm -f ' || TRIM(sRutaArchivo) ||  'tmp_SAT.sql';
    SYSTEM vsSQL;
    LET vsSQL = '';
    LET vsSQL = 'rm -f ' || TRIM(sRutaArchivo) ||  v_cNombre;
    SYSTEM vsSQL;

    LET v_codret = "00001";
    
    RETURN v_codret;
    
    END;	
    
end procedure;