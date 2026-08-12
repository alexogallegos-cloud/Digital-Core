CREATE PROCEDURE "informix".sp_consultaporasignar(pEmpresa char(3), pConsulta smallint, pParametro char(50), pValidacion smallint, pOrden smallint)
  RETURNING char(5),char(20),char(50),char(50),char(50),char(50),char(50),char(15),char(15),char(50),char(1),char(40);

define vcodret CHAR(5);
define vParam1 CHAR(20);
define vParam2 CHAR(50);
define vParam3 CHAR(50);
define vParam4 CHAR(50);
define vParam5 CHAR(50);
define vParam6 CHAR(50);
define vParam7 CHAR(15);
define vParam8 CHAR(15);
define vParam9 CHAR(50);
define vParam10 CHAR(1);
define vParam11 CHAR(40);
define vParamX CHAR(40);
define vsqlerr integer ;
define visamerr integer ;

LET vcodret = "000";
LET vParam1 ="";
LET vParam2 ="";
LET vParam3 ="";
LET vParam4 ="";
LET vParam5 ="";
LET vParam6 ="";
LET vParam7 ="";
LET vParam8 ="";
LET vParam9 ="";
LET vParam10 ="";
LET vParam11 ="";
LET vParamX = "";
LET vsqlerr = 0 ;
LET visamerr = 0 ;

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11;
   END IF;
END EXCEPTION;

-- *******************************
if pConsulta = 3 then
    if pValidacion = 1 then

        if pOrden = 1 then
            FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR,DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE > '' || pParametro || ''
				AND DIR.NUMEROCALLE IN (0,800000)
                GROUP BY S.NUMCTE,DIR.TIPO_DIR ,DIR.SECUENCIA
                ORDER BY 1 ASC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';

                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,"")
                INTO vParam8, vParam6, vParam7
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';

                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
            END FOREACH ;
        else
          FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR,DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE > '' || pParametro || ''
				AND DIR.NUMEROCALLE IN (0,800000)
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                ORDER BY 1 DESC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,"")
                INTO vParam8, vParam6, vParam7
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';				

                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
            END FOREACH ;
        end if ;

    else

        if pOrden = 1 then
          FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR,DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE < '' || pParametro || ''
				AND DIR.NUMEROCALLE IN (0,800000)
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                ORDER BY 1 ASC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';				
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,"")
                INTO vParam8, vParam6, vParam7
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';				

                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
            END FOREACH ;
        else
          FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR,DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE < '' || pParametro || ''
				AND DIR.NUMEROCALLE IN (0,800000)
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                ORDER BY 1 DESC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';				
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,"")
                INTO vParam8, vParam6, vParam7
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';
				
                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
            END FOREACH ;
       end if ;
    end if ;
elif pConsulta = 2 then
    if pValidacion = 1 then
        if pOrden = 1 then
           FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE > '' || pParametro || ''
				AND DIR.NUMEROCOLONIA IN (0,8000) AND DIR.NUMEROCIUDAD <> 0
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                ORDER BY 1 ASC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,""), NVL(DIR.ENTRE_CALLES,"") 
                INTO vParam8, vParam6, vParam7, vParam11
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';
				
                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
            END FOREACH ;
        else
           FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE > '' || pParametro || ''
				AND DIR.NUMEROCOLONIA IN (0,8000) AND DIR.NUMEROCIUDAD <> 0
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA 
                ORDER BY 1 DESC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';				
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,""), NVL(DIR.ENTRE_CALLES,"") 
                INTO vParam8, vParam6, vParam7, vParam11
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';				
				
                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
           END FOREACH ;
        end if ;
    else
        if pOrden = 1 then
          FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE < '' || pParametro || ''
				AND DIR.NUMEROCOLONIA IN (0,8000) AND DIR.NUMEROCIUDAD <> 0
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                ORDER BY 1 ASC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';				
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,""), NVL(DIR.ENTRE_CALLES,"") 
                INTO vParam8, vParam6, vParam7, vParam11
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';				
				
                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
           END FOREACH ;
        else
          FOREACH

                SELECT FIRST 11 S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                INTO vParam1,vParam10,vParam9
                FROM BDISOLIC:SS_SOLICITUDES S
                JOIN BDINTEG:SI_DIRECCIONES_ACTUAL DIR ON (DIR.NUMCTE=S.NUMCTE)
                WHERE S.EMPRESA = '' || pEmpresa || '' AND S.STATUS_SOLICITUD = 'EE'
                AND S.NUMCTE < '' || pParametro || ''
				AND DIR.NUMEROCOLONIA IN (0,8000) AND DIR.NUMEROCIUDAD <> 0
                GROUP BY S.NUMCTE,DIR.TIPO_DIR, DIR.SECUENCIA
                ORDER BY 1 DESC

                SELECT NVL(CLI.APELL_PATERNO,""),NVL(CLI.APELL_MATERNO,""),NVL(CLI.NOMBRE1,""),NVL(CLI.NOMBRE2,"")
                INTO vParam2,vParam3,vParam4,vParam5
                FROM BDINTEG:SI_CLIENTE CLI
                WHERE CLI.NUMCTE = '' || vParam1 || '';				
				
                SELECT NVL(ZON.NOMBREZONA,""), NVL(CIU.NOMBRE,""), NVL(ES.SIGLAS,""), NVL(DIR.ENTRE_CALLES,"") 
                INTO vParam8, vParam6, vParam7, vParam11
                FROM BDINTEG:SI_DIRECCIONES_ACTUAL DIR
                JOIN BDINTEG:SI_CATZONAS ZON ON (DIR.NUMEROCIUDAD=ZON.NUMEROCIUDAD AND DIR.NUMEROCOLONIA=ZON.NUMEROCOLONIA)
				JOIN BDINTEG:SI_CIUDADES CIU ON (DIR.NUMEROCIUDAD=CIU.CIUDAD AND DIR.ESTADO=CIU.ESTADO)
				JOIN BDINTEG:SI_ESTADOS ES ON (DIR.ESTADO=ES.ESTADO)
                WHERE DIR.NUMCTE = '' || vParam1 || '' AND DIR.TIPO_DIR = '' || vParam10 || '';				
				
                RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
          END FOREACH ;
        end if ;
   end if ;
elif pConsulta = 1 then
    if pValidacion = 1 then
        if pOrden = 1 then
          FOREACH
            SELECT FIRST 11 DISTINCT b.localidad_banxico AS clave, b.nombre AS ciudad, c.nombre AS estado
            INTO vParam1,vParam2,vParam3
            FROM si_direcciones_actual a
            LEFT OUTER JOIN si_ciudades b ON(a.pais = b.pais AND a.estado = b.estado AND a.ciudad=b.ciudad)
            LEFT OUTER JOIN si_estados c ON(b.pais = c.pais AND b.estado = c.estado)
            WHERE a.numerociudad = 0 AND b.localidad_banxico > '' || pParametro || '' ORDER BY 1 ASC

            RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
          END FOREACH ;
        else
          FOREACH
            SELECT FIRST 11 DISTINCT b.localidad_banxico AS clave, b.nombre AS ciudad, c.nombre AS estado
            INTO vParam1,vParam2,vParam3
            FROM si_direcciones_actual a
            LEFT OUTER JOIN si_ciudades b ON(a.pais = b.pais AND a.estado = b.estado AND a.ciudad=b.ciudad)
            LEFT OUTER JOIN si_estados c ON(b.pais = c.pais AND b.estado = c.estado)
            WHERE a.numerociudad = 0 AND b.localidad_banxico > '' || pParametro || '' ORDER BY 1 DESC

            RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
          END FOREACH ;
        end if ;
    else
        if pOrden = 1 then
          FOREACH
            SELECT FIRST 11 DISTINCT b.localidad_banxico AS clave, b.nombre AS ciudad, c.nombre AS estado
            INTO vParam1,vParam2,vParam3
            FROM si_direcciones_actual a
            LEFT OUTER JOIN si_ciudades b ON(a.pais = b.pais AND a.estado = b.estado AND a.ciudad=b.ciudad)
            LEFT OUTER JOIN si_estados c ON(b.pais = c.pais AND b.estado = c.estado)
            WHERE a.numerociudad = 0 AND b.localidad_banxico < '' || pParametro || '' ORDER BY 1 ASC

            RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
          END FOREACH ;
        else
          FOREACH
            SELECT FIRST 11 DISTINCT b.localidad_banxico AS clave, b.nombre AS ciudad, c.nombre AS estado
            INTO vParam1,vParam2,vParam3
            FROM si_direcciones_actual a
            LEFT OUTER JOIN si_ciudades b ON(a.pais = b.pais AND a.estado = b.estado AND a.ciudad=b.ciudad)
            LEFT OUTER JOIN si_estados c ON(b.pais = c.pais AND b.estado = c.estado)
            WHERE a.numerociudad = 0 AND b.localidad_banxico < '' || pParametro || '' ORDER BY 1 DESC

            RETURN vcodret,vParam1,vParam2,vParam3,vParam4,vParam5,vParam6,vParam7,vParam8,vParam9,vParam10,vParam11 WITH RESUME;
          END FOREACH ;
        end if ;
    end if ;
end if ;
END ;
END PROCEDURE ;