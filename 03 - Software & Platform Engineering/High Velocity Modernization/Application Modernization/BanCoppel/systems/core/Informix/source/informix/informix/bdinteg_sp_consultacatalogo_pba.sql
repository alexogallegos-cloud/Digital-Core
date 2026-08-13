CREATE PROCEDURE "informix".sp_consultacatalogo_pba( pCatalogo smallint, pPais char(3), pNumeroEstado char(2), pNumeroCiudad char(3), pNombre char(100),  pNumeroCalle int, pNumeroColonia int, pClaveDomicilio int, pComplementoClave int, pMovimiento smallint, pRangoInicial char(20), pRangoFinal char(20), pTotalRegistros smallint )
RETURNING CHAR(6), CHAR(2), CHAR(3), CHAR(100), INT, INT, INT, INT ;
--pMovimiento = 1 - Avance Pagina
--              2 - Retroceso Pagina
--pTotalRegistros = Cantidad de Registros a mostrar por el query
--------------------------------------------------------------
--ACTIVIDAD: Consulta los Estados
--------------------------------------------------------------

--Definicion de variables
define v_codret        char(6) ;
define v_numeroestado  char(2) ;
define v_numerociudad  char(3) ;
define v_numerociudad_coppel  int ;
define v_nombre        char(100) ;
define v_numerocalle   int ;
define v_intcodret     int ;
define v_intflag       int ;
define v_iClaveDomicilio   int ;
define v_iComplementoClave int ;
define v_cuantos int;
define i int;

--SET DEBUG FILE TO "/tmp/consultacatalogo.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET v_intcodret
   IF v_intcodret <> 0 THEN
      LET v_codret = v_intcodret ;
      RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel ;
   END IF ;
END EXCEPTION ;

--Inicializacion de variables
let v_codret        = '000' ;
let v_numeroestado  = '' ;
let v_numerociudad  = '' ;
let v_numerociudad_coppel = 0 ;
let v_nombre        = '' ;
let v_numerocalle   = 0  ;
let v_intflag         = 0 ;
let v_iClaveDomicilio  = 0 ;
let v_iComplementoClave = 0 ;
let v_cuantos = 0;
let i=0;

let v_cuantos = pTotalRegistros;

IF v_cuantos > 50 THEN
    let v_cuantos = 50;
--SE TRUNCA A 50 PUESTO QUE LA ESTRUCTURA DEL INET ESTA DECLARADA CON MAXIMO DE 50, SINO SE VALIDARA EN ESTA PARTE, TRONARIA EL PROGRAMA.
END IF;

IF pCatalogo = 1 THEN

    IF pNumeroEstado != '' THEN
        IF EXISTS ( SELECT nombre FROM bdinteg:si_estados WHERE pais = pPais AND estado = pNumeroEstado ) THEN

                SELECT estado,NVL(TRIM(nombre),'')
                INTO  v_numeroestado,v_nombre
                FROM bdinteg:si_estados
                WHERE pais = pPais AND estado = pNumeroEstado ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        ELSE
                LET v_codret = '001' ;  -- No existe el estado en el catalogo

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        END IF;
    ELSE
        IF pMovimiento = 1 THEN
            FOREACH
                SELECT FIRST 50 estado,NVL(TRIM(nombre),'')
                INTO  v_numeroestado,v_nombre
                FROM bdinteg:si_estados
                WHERE TRIM(nombre) LIKE '%' || TRIM(pNombre) || '%' AND pais = pPais
                AND estado < '' || TRIM(pRangoInicial) || '' ORDER BY 1 DESC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        ELSE
            FOREACH
                SELECT FIRST 50 estado,NVL(TRIM(nombre),'')
                INTO  v_numeroestado,v_nombre
                FROM bdinteg:si_estados
                WHERE TRIM(nombre) LIKE '%' || TRIM(pNombre) || '%' AND pais = pPais
                AND estado > '' || TRIM(pRangoFinal) || '' ORDER BY 1 ASC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        END IF;

        IF v_intflag = 0 THEN

          LET v_codret = '002' ;  -- No existen Estados con ese criterio
          RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;

        END IF ;
    END IF ;
ELSE
  IF pCatalogo = 2 THEN

    IF pNumeroCiudad != '' THEN
        IF EXISTS ( SELECT nombre FROM bdinteg:si_ciudades WHERE pais = pPais AND estado = pNumeroEstado AND ciudad = pNumeroCiudad ) THEN

                SELECT ciudad,ciudad_coppel,NVL(TRIM(nombre),'')
                INTO  v_numerociudad,v_numerociudad_coppel,v_nombre
                FROM bdinteg:si_ciudades
                WHERE pais = pPais AND estado = pNumeroEstado AND ciudad = pNumeroCiudad ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        ELSE
                LET v_codret = '003' ;  -- No existe la ciudad en el catalogo

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        END IF;
    ELSE
        IF pMovimiento = 1 THEN
            FOREACH
                SELECT FIRST 50 ciudad,ciudad_coppel,NVL(TRIM(nombre),'')
                INTO  v_numerociudad,v_numerociudad_coppel,v_nombre
                FROM bdinteg:si_ciudades
                WHERE TRIM(nombre) LIKE '%' || TRIM(pNombre) || '%' AND pais = pPais AND estado = pNumeroEstado
                AND ciudad < '' || TRIM(pRangoInicial) || '' ORDER BY 1 DESC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        ELSE
            FOREACH
                SELECT FIRST 50 ciudad,ciudad_coppel,NVL(TRIM(nombre),'')
                INTO  v_numerociudad,v_numerociudad_coppel,v_nombre
                FROM bdinteg:si_ciudades
                WHERE TRIM(nombre) LIKE '%' || TRIM(pNombre) || '%' AND pais = pPais AND estado = pNumeroEstado
                AND ciudad > '' || TRIM(pRangoFinal) || '' ORDER BY 1 ASC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        END IF;

        IF v_intflag = 0 THEN

          LET v_codret = '004' ;  -- No existen Ciudades con ese criterio
          RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;

        END IF ;
    END IF ;
  ELSE
   IF pCatalogo = 3 THEN

     IF pNumeroCalle != 0 THEN
        IF EXISTS ( SELECT nombrecalle FROM bdinteg:si_catcalles WHERE numerocalle = pNumeroCalle ) THEN

                SELECT numerocalle,NVL(TRIM(nombrecalle),'')
                INTO  v_numerocalle,v_nombre
                FROM bdinteg:si_catcalles
                WHERE numerocalle = pNumeroCalle ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        ELSE
                LET v_codret = '005' ;  -- No existe la calle en el catalogo

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        END IF;
     ELSE
        IF pMovimiento = 1 THEN
            FOREACH
                SELECT FIRST 50 numerocalle,NVL(TRIM(nombrecalle),'')
                INTO  v_numerocalle,v_nombre
                FROM bdinteg:si_catcalles
                WHERE TRIM(nombrecalle) LIKE '%' || TRIM(pNombre) || '%'
                AND numerocalle < '' || TRIM(pRangoInicial) || '' ORDER BY 1 DESC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        ELSE
            FOREACH
                SELECT FIRST 50 numerocalle,NVL(TRIM(nombrecalle),'')
                INTO  v_numerocalle,v_nombre
                FROM bdinteg:si_catcalles
                WHERE TRIM(nombrecalle) LIKE '%' || TRIM(pNombre) || '%'
                AND numerocalle > '' || TRIM(pRangoFinal) || '' ORDER BY 1 ASC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        END IF;
        IF v_intflag = 0 THEN

          LET v_codret = '006' ;  -- No existen Calles con ese criterio
          RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;

        END IF ;
     END IF ;
   ELSE
    IF pCatalogo = 4 THEN

      IF pClaveDomicilio != 0 AND pComplementoClave != 0 THEN
        IF EXISTS ( SELECT nombredomicilio FROM bdinteg:si_catdomicilios WHERE numerociudad = pNumeroCiudad AND numerocolonia = pNumeroColonia AND clavedomicilio = pClaveDomicilio AND complementoclave = pComplementoClave ) THEN

                SELECT clavedomicilio, complementoclave, NVL(TRIM(nombredomicilio),'')
                INTO  v_iClaveDomicilio,v_iComplementoClave,v_nombre
                FROM bdinteg:si_catdomicilios
                WHERE numerociudad = pNumeroCiudad AND numerocolonia = pNumeroColonia AND clavedomicilio = pClaveDomicilio AND complementoclave = pComplementoClave ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        ELSE
                LET v_codret = '007' ;  -- No existe la Coordenada en el catalogo

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
        END IF;
      ELSE
        IF pMovimiento = 1 THEN
            FOREACH
                SELECT FIRST 50 clavedomicilio, complementoclave, NVL(TRIM(nombredomicilio),'')
                INTO   v_iClaveDomicilio,v_iComplementoClave,v_nombre
                FROM bdinteg:si_catdomicilios
                WHERE TRIM(nombredomicilio) LIKE '%' || TRIM(pNombre) || '%' AND numerociudad = pNumeroCiudad AND numerocolonia = pNumeroColonia AND clavedomicilio = pClaveDomicilio
                AND clavedomicilio < '' || TRIM(pRangoInicial) || '' ORDER BY 1 DESC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        ELSE
            FOREACH
                SELECT FIRST 50 clavedomicilio, complementoclave, NVL(TRIM(nombredomicilio),'')
                INTO   v_iClaveDomicilio,v_iComplementoClave,v_nombre
                FROM bdinteg:si_catdomicilios
                WHERE TRIM(nombredomicilio) LIKE '%' || TRIM(pNombre) || '%' AND numerociudad = pNumeroCiudad AND numerocolonia = pNumeroColonia AND clavedomicilio = pClaveDomicilio
                AND clavedomicilio > '' || TRIM(pRangoFinal) || '' ORDER BY 1 ASC

                LET v_intflag = 1 ;
                LET i = i + 1 ;

                RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;
                IF i = v_cuantos THEN
                    EXIT FOREACH;
                END IF;
            END FOREACH ;
        END IF;

        IF v_intflag = 0 THEN

          LET v_codret = '008' ;  -- No existen Coordenadas con ese nombre
          RETURN v_codret, v_numeroestado, v_numerociudad, v_nombre, v_numerocalle, v_iClaveDomicilio, v_iComplementoClave, v_numerociudad_coppel WITH RESUME ;

        END IF ;
    END IF ;
   END IF ;
   END IF;
  END IF;
END IF ;
END ;
END PROCEDURE ;