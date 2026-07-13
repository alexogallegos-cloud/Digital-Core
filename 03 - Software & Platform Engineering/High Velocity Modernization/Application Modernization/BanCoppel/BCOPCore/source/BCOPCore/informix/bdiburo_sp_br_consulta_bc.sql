CREATE PROCEDURE "informix".sp_br_consulta_bc(pEmpresa CHAR(3), pNumProd CHAR(4))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;
		  
DEFINE vregistro         CHAR(255);
DEFINE vregistro1        CHAR(255);
DEFINE vregistro2        CHAR(255);
DEFINE Num_Cte           VARCHAR(20);
DEFINE NumCred           VARCHAR(20);
DEFINE LineaS            DECIMAL;
DEFINE vlen              INTEGER;
DEFINE vpos              CHAR(2);
DEFINE vpo1              CHAR(5);
DEFINE vdia              CHAR(2);
DEFINE vmes              CHAR(2);
DEFINE vanio             CHAR(4);
-- Variables para ver si se va a Buro o no 
DEFINE vfconbr           DATE;
DEFINE vf1mes            DATE;
DEFINE vstatus           CHAR(2);
DEFINE cCodRet           CHAR(6);
DEFINE cMensajeRet       CHAR(80);
DEFINE vapell_pat        CHAR(15);
DEFINE vecampo1          CHAR(4);
DEFINE vecampo2          CHAR(2);
DEFINE vecampo3          CHAR(25);
DEFINE vecampo4          CHAR(3);
DEFINE vecampo5          CHAR(2);
DEFINE vecampo6          CHAR(4);
DEFINE vecampo7          CHAR(10);
DEFINE vecampo8          CHAR(8);
DEFINE vecampo9          CHAR(1);
DEFINE vecampo10         CHAR(2);
DEFINE vecampo11         CHAR(2);
DEFINE vecampo12         CHAR(9);
DEFINE vecampo13         CHAR(2);
DEFINE vecampo14         CHAR(2);
DEFINE vecampo15         CHAR(1);
DEFINE vecampo16         CHAR(4);
DEFINE vecampo17         CHAR(7);
DEFINE vexiste           INTEGER;
DEFINE vcodini           INTEGER;
DEFINE vcodfin           INTEGER;
-- Datos del Cliente --
DEFINE vdcampo1          CHAR(2);
DEFINE vdcampo2          CHAR(26);
DEFINE vdcampo3          CHAR(26);
DEFINE vdcampo4          CHAR(26);
DEFINE vdcampo5          CHAR(26);
DEFINE vdcampo6          CHAR(10);
DEFINE vdcampo7          CHAR(13);
DEFINE vdcampo8          CHAR(2);
DEFINE vdcampo9          CHAR(1);
DEFINE vdcampo10         CHAR(1);
DEFINE vdcampo11         CHAR(1);
DEFINE vdcampo12         CHAR(2);
DEFINE vscampo1          CHAR(2);
DEFINE vscampo2          CHAR(40);
DEFINE vscampo3          CHAR(40);
DEFINE vscampo4          CHAR(40);
DEFINE vscampo5          CHAR(40);
DEFINE vscampo6          CHAR(40);
DEFINE vscampo7          CHAR(4);
DEFINE vscampo8          CHAR(5);
DEFINE vscampo8a         INTEGER;
DEFINE vscampo9          CHAR(1);
DEFINE vexiste1          SMALLINT;
DEFINE vquita            CHAR(40);
DEFINE vespacio          CHAR(1);
DEFINE vmanzana          SMALLINT;
DEFINE vandador          SMALLINT;
DEFINE vlote             SMALLINT;
DEFINE vedificio         SMALLINT;
DEFINE ventrada          SMALLINT;
DEFINE vsecuencia        SMALLINT;
DEFINE vcomentario       CHAR(80);
DEFINE vfecha            DATE;
DEFINE statuscom         INTEGER;
DEFINE siglas_producto   CHAR(2);
DEFINE numprod           CHAR(20);
DEFINE iSqlErr      	 INTEGER;
DEFINE iIsamErr          INTEGER;
DEFINE cErrorInfo        CHAR(80);
DEFINE vCont             INTEGER;
DEFINE cTable            CHAR(1);
DEFINE sCommit                       SMALLINT;
DEFINE contador_commit               INTEGER;
DEFINE pFechaHoyAumlincred  DATE;


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
--      LET cMensajeRet= cErrorInfo;
      IF (sCommit = -1) THEN
          rollback work;
      END IF;
	  RETURN cCodRet, cMensajeRet;     
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO 'sp_br_consulta_bc.out';
-- TRACE ON;

LET vregistro         = "";
LET vregistro1        = "";
LET vregistro2        = "";
LET Num_Cte           = "";
LET NumCred           = "" ;
LET LineaS            = 0;
LET vlen              = 0;
LET vpos              = "";
LET vdia              = "";
LET vmes              = "";
LET vanio             = "";
LET vfconbr           = "";
LET vf1mes            = "";
LET vstatus           = "";
LET vapell_pat        = "";
LET statuscom         = 0;
LET vCont             = 0;
LET iSqlErr           = 0;
LET iIsamErr          = 0;
LET cErrorInfo        = "";
LET cCodRet           = "000000";
LET cMensajeRet       = "Se realizó la consulta correctamente";
LET siglas_producto   = "";
LET numprod           = "";
LET sCommit                 = 0;
LET contador_commit         = 0;

-- Declaracion de Constantes para Generacion de Registro s desea ver que significa cada campo
-- Favor de consultar el manual -->
LET vecampo1          = "INTL";
LET vecampo2          = "11";
LET vecampo3          = "     ";
LET vecampo4          = "001";
LET vecampo5          = "MX";
LET vecampo6          = "0000";	
LET vecampo7          = "";	
LET vecampo8          = "";	
LET vecampo9          = "I";
LET vecampo10         = "";
LET vecampo11         = "MX";
LET vecampo12         = "0";
LET vecampo13         = "SP";
LET vecampo14         = "01";	
LET vecampo15         = " ";
LET vecampo16         = "    ";
LET vecampo17         = "0000000";
LET vexiste           = 0;
LET vcomentario       = "";

-- Datos del Cliente --
LET vdcampo1          = "PN"; --Identificador de cadena--
LET vdcampo2          = ""; --Apellido Paterno PN--
LET vdcampo3          = ""; --Apellido Materno 00--
LET vdcampo4          = ""; --Primer Nombre 02--
LET vdcampo5          = ""; --Segundo Nombre 03--
LET vdcampo6          = ""; --Fecha de Nacimiento 04--
LET vdcampo7          = ""; --RFC 05--
LET vdcampo8          = "MX"; --Nacionalidad MX o EX 08--
LET vdcampo9          = ""; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
LET vdcampo10         = ""; --Estado Civil 11 --
LET vdcampo11         = ""; --Sexo 12--
LET vdcampo12         = ""; --Dependiente 17--

-- Direccion del Cliente --
LET vscampo1          = "PA"; --Identificador de cadena--
LET vscampo2          = ""; --Direccion Linea 1 PA--
LET vscampo3          = ""; --Direccion Linea 2 00--
LET vscampo4          = ""; --Colonia o Poblacion 01--
LET vscampo5          = ""; --Delegacion o Municipio 02--
LET vscampo6          = ""; --Nombre Ciudad 03--
LET vscampo7          = ""; --Estado 04--
LET vscampo8          = ""; --Codigo Postal 05--
LET vscampo9          = ""; --Tipo de Domicilio 10--
LET cTable            = "N";
LET pFechaHoyAumlincred = DATE(1);


IF NVL(pEmpresa,"") = "" THEN
   LET cCodRet     = "000011";
   LET cMensajeRet = "parametro requerido esta vacio";
   RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del usuario de buro
SELECT TRIM(valor) 
  INTO vecampo7
  FROM bdiburo:br_param
 WHERE cod_param = 124;

-- validacion de los parametros.
IF NVL(vecampo7,"") = "" THEN
    LET cCodRet     = "000008";
    LET cMensajeRet = "Error al obtener el usuario de buro";
    RETURN cCodRet, cMensajeRet;
END IF;

-- obtencion del password usuario de buro
SELECT TRIM(valor)
  INTO vecampo8
  FROM bdiburo:br_param
 WHERE cod_param = 125;

IF NVL(vecampo8,"") = "" then
   LET cCodRet     = "000009";
   LET cMensajeRet = "Error al obtener el password de buro";
   RETURN cCodRet, cMensajeRet;
END IF;
/*
SELECT fecha_hoy 
  INTO vfecha
  FROM bdicred:sd_fechas
 WHERE empresa = pEmpresa;
*/
SELECT codigo
  INTO siglas_producto
  FROM bdiburo:br_tltco
 WHERE num_producto = pNumProd;	

SELECT fecha_hoy 
  INTO pFechaHoyAumlincred
  FROM bdicred:"informix".sd_fechas_aumlincred
 WHERE empresa = pEmpresa;

  LET vecampo10 = siglas_producto;

FOREACH WITH HOLD

    SELECT numcte, num_solicitud, num_producto, lincred_sugerida
      INTO Num_Cte, NumCred, numprod, LineaS
      FROM bdicred:sd_bitacora_aumlincred 
     WHERE empresa      = pEmpresa
       and num_solicitud > ""
       and status       = "BC"
       AND fecha_insert = pFechaHoyAumlincred
       AND num_producto = pNumProd      

/*
     WHERE status       = "BC"
       AND num_producto = pNumProd
       AND fecha_insert = pFechaHoyAumlincred
       AND empresa      = pEmpresa
*/


    LET cMensajeRet = NumCred || '  consulta_buro';

    IF (sCommit = 0) THEN
        BEGIN WORK;
        LET contador_commit = 0;
        LET sCommit = -1;
    END IF; 


       LET vecampo3  = NumCred;
       LET vecampo12 = LPAD(ROUND(LineaS,0),9,"0");
       LET vregistro = vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||vecampo6||vecampo7||
                       vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
                       vecampo14||vecampo15||vecampo16||vecampo17;

	SELECT TRIM(apell_paterno), TRIM(apell_materno), TRIM(nombre1),
		   TRIM(nombre2),fecha_nac, TRIM(rfc), TRIM(habita_en),
		   TRIM(estado_civil),TRIM(sexo), NVL(dependientes,"0")
	  INTO vdcampo2,vdcampo3,vdcampo4,vdcampo5,
           vdcampo6,vdcampo7,vdcampo9,vdcampo10,
           vdcampo11,vdcampo12
      FROM bdinteg:si_cliente a,
           bdinteg:si_ctepf b
	 WHERE a.numcte = b.numcte  
       AND b.numcte = Num_Cte;

	 -- Cambia las Ñ de los Nombres y Apellidos --
        IF vdcampo2  IS NULL THEN LET vdcampo2  = "";  LET vcomentario = "Apellido paterno nulo"; END IF;
        IF vdcampo3  IS NULL THEN LET vdcampo3  = "NO PROPORCIONADO"; END IF;
        IF vdcampo4  IS NULL THEN LET vdcampo4  = "";  LET vcomentario = TRIM(vcomentario)||" Sin nombre"; END IF;
        IF vdcampo5  IS NULL THEN LET vdcampo5  = "";  END IF;
        IF vdcampo6  IS NULL THEN LET vdcampo6  = "";  END IF;
        IF vdcampo7  IS NULL THEN LET vdcampo7  = "";  END IF;
        IF vdcampo9  IS NULL THEN LET vdcampo9  = "";  END IF;
        IF vdcampo10 IS NULL THEN LET vdcampo10 = "";  END IF;
        IF vdcampo11 IS NULL THEN LET vdcampo11 = "";  END IF;
        IF vdcampo12 IS NULL THEN LET vdcampo12 = "0"; END IF;
        LET vexiste   = LENGTH(vdcampo2);
        LET vexiste1  = 0;
        LET vquita    = "";
        LET vespacio  = " ";

		WHILE vexiste1 < vexiste
           IF vdcampo2[1,1]= "~" OR vdcampo2[1,1]= " " OR vdcampo2[1,1]= "." OR vdcampo2[1,1]= "-"  THEN
                 LET vespacio = "F";
           ELSE
                 IF vespacio = "F" THEN
                       IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "¥" THEN
                         LET vquita = TRIM(vquita)||" Ñ";
                       ELSE
                         LET vquita = TRIM(vquita)||" "||vdcampo2[1,1];
                       END IF;
                       LET vespacio = "";
                 ELSE
                       IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "¥" THEN
                         LET vquita = TRIM(vquita)||"Ñ";
                       ELSE
                         LET vquita = trim(vquita)||vdcampo2[1,1];
                       END IF;
                 END IF;
           END IF;
           LET vdcampo2 = vdcampo2[2,26];
           LET vexiste1 = vexiste1 + 1;
        END WHILE;
        LET vdcampo2 = TRIM(vquita);
        LET vexiste  = LENGTH(vdcampo3);

     --- CAMBIO DE APELLIDO MATERNO
        IF vexiste = 0 THEN
           LET vdcampo3 = "NO PROPORCIONADO";
           LET vexiste  = LENGTH(vdcampo3);
        END IF;
        LET vexiste1 = 0;
        LET vquita   = "";
        LET vespacio = " ";

        WHILE vexiste1 < vexiste
           IF vdcampo3[1,1]= "~" OR vdcampo3[1,1]= " " OR vdcampo3[1,1]= "." OR vdcampo3[1,1]= "-" THEN
                 LET vespacio = "F";
           ELSE
                 IF vespacio = "F" THEN
                       IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "¥" THEN
                         LET vquita = TRIM(vquita)||" Ñ";
                       ELSE
                         LET vquita = TRIM(vquita)||" "||vdcampo3[1,1];
                       END IF;
                       LET vespacio = "";
                 ELSE
                       IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "¥" THEN
                         LET vquita = TRIM(vquita)||"Ñ";
                       ELSE
                         LET vquita = TRIM(vquita)||vdcampo3[1,1];
                       END IF;
                 END IF;
           END IF;
           LET vdcampo3 = vdcampo3[2,26];
           LET vexiste1 = vexiste1 + 1;
        END WHILE;
        LET vdcampo3 = TRIM(vquita);
        LET vexiste  = LENGTH(vdcampo4);
        LET vexiste1 = 0;
        LET vquita   = "";
        LET vespacio = " ";
        WHILE vexiste1 < vexiste
           IF vdcampo4[1,1]= "~" OR vdcampo4[1,1]= " " OR vdcampo4[1,1]= "." OR vdcampo4[1,1]= "-" THEN
                 LET vespacio = "F";
           ELSE
                 IF vespacio = "F" THEN
                       IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "¥" THEN
                         LET vquita = TRIM(vquita)||" Ñ";
                       ELSE
                         LET vquita = TRIM(vquita)||" "||vdcampo4[1,1];
                       END IF;
                       LET vespacio = "";
                 ELSE
                       IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "¥" THEN
                         LET vquita = TRIM(vquita)||"Ñ";
                       ELSE
                         LET vquita = TRIM(vquita)||vdcampo4[1,1];
                       END IF;
                 END IF;
           END IF;
           LET vdcampo4 = vdcampo4[2,26];
           LET vexiste1 = vexiste1 + 1;
        END WHILE;

        LET vdcampo4 = TRIM(vquita);
        LET vexiste  = LENGTH(vdcampo5);
        LET vexiste1 = 0;
        LET vquita   = "";
        LET vespacio = " ";

        WHILE vexiste1 < vexiste
           IF vdcampo5[1,1]= "~" or vdcampo5[1,1]= " " or vdcampo5[1,1]= "." or vdcampo5[1,1]= "-" THEN
              LET vespacio ="F";
           ELSE
                IF vespacio = "F" THEN
                   IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "¥" THEN
                     LET vquita = TRIM(vquita)||" Ñ";
                   ELSE
                     LET vquita = TRIM(vquita)||" "||vdcampo5[1,1];
                   END IF;
                   LET vespacio = "";
                ELSE
                   IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "¥" THEN
                     LET vquita = TRIM(vquita)||"Ñ";
                   ELSE
                     LET vquita = TRIM(vquita)||vdcampo5[1,1];
                   END IF;
                END IF;
            END IF;
            LET vdcampo5 = vdcampo5[2,26];
            LET vexiste1 = vexiste1 + 1;
        END WHILE;
		LET vdcampo5 = TRIM(vquita);
        IF vdcampo9 = "P" OR vdcampo9 = "G" THEN
              LET vdcampo9= "1";
        ELSE
              IF vdcampo9 ="R" THEN
                   LET vdcampo9= "2";
              ELSE
                   IF vdcampo9 = "F" OR vdcampo9 = "H" THEN
                      LET vdcampo9= "3";
                   ELSE
                      LET vdcampo9= "";
                   END IF;
              END IF;
        END IF;
        IF vdcampo10 = "D" THEN
            LET vdcampo10="D";
        ELSE
            IF vdcampo10 = "U" THEN
                LET vdcampo10="F";
            ELSE
                IF vdcampo10 = "C" THEN
                   LET vdcampo10= "M";
                ELSE
                   IF vdcampo10 = "S" THEN
                      LET vdcampo10="S";
                   ELSE
                      IF vdcampo10 = "V" THEN
                         LET vdcampo10= "W";
                      END IF;
                   END IF;
                END IF;
            END IF;
        END IF;

	    -- Carga los datos de la Direccion del Cliente --
/*
		SELECT MAX(secuencia) 
          INTO vsecuencia
		  FROM bdinteg:si_direcciones
		 WHERE numcte   = Num_Cte 
           AND tipo_dir = '1';
*/
  		SELECT TRIM(f.nombrecalle), NVL(TRIM(a.numeroextcalle),' ')||' '||NVL(TRIM(a.numerointcalle),' '),
		       TRIM(g.nombrezona), --TRIM(d.nombre_inegi),
			   TRIM(g.municipiozona), TRIM(c.estado), a.cod_postal, a.tipo_dir,
		       manzana,andador,lote,edificio,entrada,codini,codfin
		  INTO vscampo2, vscampo3, vscampo4,--vscampo5,
		       vscampo6, vscampo7,vscampo8,vscampo9,
		       vmanzana,vandador,vlote,vedificio,ventrada,vcodini,vcodfin
--		  FROM bdinteg:si_direcciones as a,
		  FROM bdinteg:si_direcciones_actual as a,
		       bdisolic:ss_circulo_edos as c,
		       bdinteg:si_catcalles f,
		       bdinteg:si_catzonas g
		 WHERE a.numcte        = Num_Cte 
--           AND a.secuencia     = vsecuencia
           AND a.tipo_dir="1"
		   AND c.clave         = a.estado 
		   AND g.numerociudad  = a.numerociudad
		   AND g.numerocolonia = a.numerocolonia
		   AND f.numerocalle   = a.numerocalle;
		
           IF vscampo2 IS NULL THEN LET vscampo2 = ""; LET vcomentario = TRIM(vcomentario)||" Sin calle "; END IF;
           IF vscampo3 IS NULL THEN LET vscampo3 = ""; END IF;
           IF vscampo4 IS NULL THEN LET vscampo4 = ""; END IF;
           IF vscampo5 IS NULL THEN LET vscampo5 = ""; END IF;
           IF vscampo6 IS NULL THEN LET vscampo6 = ""; LET vcomentario = TRIM(vcomentario)||" Sin localidad "; END IF;
           IF vscampo7 IS NULL THEN LET vscampo7 = ""; LET vcomentario = TRIM(vcomentario)||" Sin estado "; END IF;
           IF vscampo8 IS NULL THEN LET vscampo8 = ""; LET vcomentario = TRIM(vcomentario)||" Sin codigo postal "; END IF;
           IF vscampo9 IS NULL THEN LET vscampo9 = ""; END IF;
          
           LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
           LET vexiste  = LENGTH(vscampo2);

           IF vexiste < 26 THEN
                 LET vscampo3 = "";
                 IF vmanzana > 0 THEN
                   LET vscampo3 ="mza "||vmanzana;
                 END IF;
                 IF vandador > 0 THEN
                   LET vscampo3 = TRIM(vscampo3)||"and "||vandador;
                 END IF;
                 IF vlote > 0 THEN
                   LET vscampo3 = TRIM(vscampo3)||"lt "||vlote;
                 END IF;
                 IF vedificio > 0 THEN
                   LET vscampo3 = TRIM(vscampo3)||"ed "||vedificio;
                 END IF;
                 IF ventrada > 0 THEN
                   LET vscampo3 = TRIM(vscampo3)||"ent "||ventrada;
                 END IF;
                 LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
           END IF;

           LET vscampo2  = TRIM(vscampo2);
           LET vexiste   = LENGTH(vscampo2);
           LET vexiste1  = 0;
           LET vquita    = "";
           LET vespacio  = " ";

           WHILE vexiste1 < vexiste
                IF vscampo2[1,1]= "~" OR vscampo2[1,1]= " " OR vscampo2[1,1]= "." OR vscampo2[1,1]= "-" THEN
                    LET vespacio = "F";
                ELSE
                      IF vespacio = "F" THEN
                            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "¥" THEN
                               LET vquita = TRIM(vquita)||" Ñ";
                            ELSE
                               LET vquita = TRIM(vquita)||" "||vscampo2[1,1];
                            END IF;
                            LET vespacio = "";
                      ELSE
                            IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "¥" THEN
                               LET vquita = TRIM(vquita)||"Ñ";
                            ELSE
                               LET vquita = TRIM(vquita)||vscampo2[1,1];
                            END IF;
                      END IF;
                END IF;
                LET vscampo2 = vscampo2[2,26];
                LET vexiste1 = vexiste1 + 1;
           END WHILE;

           LET vscampo2 = TRIM(vquita);
           
           IF vscampo9 ="1" THEN
              LET vscampo9="H";
           ELSE
              IF vscampo9 = "2" THEN
                 LET vscampo9 = "B";
              ELSE
                 LET vscampo9 = "H";
              END IF;
           END IF;

           LET vregistro   = TRIM(vregistro)||vdcampo1;
           LET vlen        = LENGTH(vdcampo2);
           LET vpos        = LPAD(vlen,2,'0');
           LET vregistro   = TRIM(vregistro)||vpos||vdcampo2;
           LET vlen        = LENGTH(vdcampo3);
           LET vpos        = LPAD(vlen,2,'0');
           LET vregistro   = TRIM(vregistro)||'00'||vpos||vdcampo3;
           LET vlen        = LENGTH(vdcampo4);
           LET vpos        = LPAD(vlen,2,'0');
           LET vregistro   = TRIM(vregistro)||'02'||vpos||vdcampo4;
           LET vlen        = LENGTH(vdcampo5);
           LET vpos        = LPAD(vlen,2,'0');

		   IF vlen  > 0 THEN
		      LET vregistro = TRIM(vregistro)||'03'||vpos||vdcampo5;
		   END IF;

		   LET vlen = LENGTH(vdcampo6);
		   IF vlen > 0 THEN
			     LET vdia      = vdcampo6[4,5];
			     LET vdia      = lpad(vdia,2,'0');
			     LET vmes      = vdcampo6[1,2];
			     LET vmes      = lpad(vmes,2,'0');
			     LET vanio     = vdcampo6[7,10];
			     LET vdcampo6  = vdia||vmes||vanio;
			     LET vlen      = LENGTH(vdcampo6);
			     LET vpos      = LPAD(vlen,2,'0');
			     LET vregistro = TRIM(vregistro)||'04'||vpos||vdcampo6;
		    END IF;

		   LET vlen = LENGTH(vdcampo7);
		   IF vlen  > 0 THEN
			    LET vpos      = lpad(vlen,2,'0');
			    LET vregistro = TRIM(vregistro)||'05'||vpos||vdcampo7;
		   END IF;

           LET vlen      = LENGTH(vdcampo8);
           LET vpos      = LPAD(vlen,2,'0');
           LET vregistro = TRIM(vregistro)||'08'||vpos||vdcampo8;

		 --- Este es el campo correspondiente a la residencia
            IF vdcampo9 = "1" OR vdcampo9 = "2" OR vdcampo9 = "3" THEN
                 LET vlen      = LENGTH(vdcampo9);
                 LET vpos      = LPAD(vlen,2,'0');
                 LET vregistro = TRIM(vregistro)||'09'||vpos||vdcampo9;
            END IF;

            LET vlen = LENGTH(vdcampo10);
		    IF vlen  > 0 THEN
			     LET vpos      = LPAD(vlen,2,'0');
			     LET vregistro = TRIM(vregistro)||'11'||vpos||vdcampo10;
		    END IF;

    		LET vlen = LENGTH(vdcampo11);
		    IF vlen  > 0 THEN
			    LET vpos      = lpad(vlen,2,'0');
			    LET vregistro = TRIM(vregistro)||'12'||vpos||vdcampo11;
            END IF;

		    IF TRIM(vdcampo12) != "0" THEN
		       IF LENGTH(TRIM(vdcampo12)) < 2 THEN
			      LET vdcampo12 = "0"||TRIM(vdcampo12);
		       END IF;
               LET vlen      = LENGTH(vdcampo12);
               LET vpos      = LPAD(vlen,2,'0');
               LET vregistro = TRIM(vregistro)||'17'||vpos||vdcampo12;
		    ELSE
		       LET vregistro = TRIM(vregistro)||'170201';
		    END IF;

            LET vregistro   = TRIM(vregistro)||vscampo1;
            LET vlen        = LENGTH(vscampo2);
            LET vpos        = LPAD(vlen,2,'0');
            LET vregistro1  = vpos||vscampo2;
            LET vscampo3    = "";
            LET vexiste     = LENGTH(vscampo3);
            LET vexiste1    = 0;
            LET vquita      = "";
            LET vespacio    = " ";

		    WHILE vexiste1 < vexiste
                IF vscampo3[1,1]= "~" OR vscampo3[1,1]= " " OR vscampo3[1,1]= "." OR vscampo3[1,1]= "-" THEN
                      LET vespacio = "F";
                ELSE
                      IF vespacio = "F" THEN
                            IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "¥" THEN
                               LET vquita = TRIM(vquita)||" Ñ";
                            ELSE
                               LET vquita = TRIM(vquita)||" "||vscampo3[1,1];
                            END IF;
                            LET vespacio = "";
                      ELSE
                            IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "¥" THEN
                               LET vquita = TRIM(vquita)||"Ñ";
                            ELSE
                               LET vquita = TRIM(vquita)||vscampo3[1,1];
                            END IF;
                      END IF;
                 END IF;
                 LET vscampo3 = vscampo3[2,26];
                 LET vexiste1 = vexiste1 + 1;
		    END WHILE;

		    LET vscampo3  = TRIM(vquita);
		    LET vlen      = LENGTH(vscampo3);
		    LET vpos      = LPAD(vlen,2,'0');
		    LET vexiste   = LENGTH(vscampo4);
		    LET vexiste1  = 0;
		    LET vquita    = "";
		    LET vespacio  = " ";

		    WHILE vexiste1 < vexiste
                 IF vscampo4[1,1]= "~" OR vscampo4[1,1]= " " OR vscampo4[1,1]= "." OR vscampo4[1,1]= "-" THEN
                    LET vespacio = "F";
                 ELSE
                      IF vespacio = "F" THEN
                            IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "¥" THEN
                                LET vquita = TRIM(vquita)||" Ñ";
                            ELSE
                                LET vquita = TRIM(vquita)||" "||vscampo4[1,1];
                            END IF;
                            LET vespacio = "";
                      ELSE
                            IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "¥" THEN
                                LET vquita = TRIM(vquita)||"Ñ";
                            ELSE
                                LET vquita = TRIM(vquita)||vscampo4[1,1];
                            END IF;
                      END IF;
                 END IF;
                 LET vscampo4 = vscampo4[2,26];
                 LET vexiste1 = vexiste1 + 1;
		    END WHILE;

		    LET vscampo4 = TRIM(vquita);
		    LET vlen     = LENGTH(vscampo4);
		    LET vpos     = LPAD(vlen,2,'0');

		    IF vlen > 0 THEN
                LET vregistro1 = TRIM(vregistro1)||'01'||vpos|| vscampo4;
		    END IF;

		    LET vexiste   = LENGTH(vscampo6);
		    LET vexiste1  = 0;
		    LET vquita    = "";
		    LET vespacio  = " ";

		    WHILE vexiste1 < vexiste
                 IF vscampo6[1,1]= "~" OR vscampo6[1,1]= " " OR vscampo6[1,1]= "." OR vscampo6[1,1]="-" THEN
                    LET vespacio = "F";
                    LET vexiste1 = vexiste1 + 1;
                    LET vscampo6 = vscampo6[2,26];
                 ELSE
                      IF vespacio = "F" THEN
                            IF vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" THEN
                                LET vquita   = TRIM(vquita);
                                LET vexiste1 = vexiste1 + 22;
                                LET vscampo6 = vscampo6[23,26];
                            ELSE
                               IF vscampo6[1,12] = "MUNICIPIO DE"  THEN
                                    LET vquita   = TRIM(vquita);
                                    LET vexiste1 = vexiste1 + 12;
                                    LET vscampo6 = vscampo6[13,26];
                               ELSE
                                    IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "¥" THEN
                                        LET vquita = TRIM(vquita)||" Ñ";
                                    ELSE
                                        LET vquita = TRIM(vquita)||" "||vscampo6[1,1];
                                    END IF;
                                    LET vespacio = "";
                                    LET vexiste1 = vexiste1 + 1;
                                    LET vscampo6 = vscampo6[2,26];
                               END IF;
                            END IF;
                      ELSE
                            IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "¥" THEN
                                LET vquita = TRIM(vquita)||"Ñ";
                            ELSE
                                LET vquita = TRIM(vquita)||vscampo6[1,1];
                            END IF;
                            LET vexiste1 = vexiste1 + 1;
                            LET vscampo6 = vscampo6[2,26];
                      END IF;
                 END IF;
		    END WHILE;

		    LET vscampo6    = TRIM(vquita);
		    LET vlen        = LENGTH(vscampo6);
		    LET vpos        = LPAD(vlen,2,'0');
		    LET vregistro1  = TRIM(vregistro1)||'03'||vpos||vscampo6;
		    LET vexiste     = LENGTH(vscampo7);
		    LET vexiste1    = 0;
		    LET vquita      = "";
		    LET vespacio    = " ";

            WHILE vexiste1 < vexiste
                 IF vscampo7[1,1]= "~" OR vscampo7[1,1]= " " OR vscampo7[1,1]= "." OR vscampo7[1,1]= "-" THEN
                      LET vespacio = "F";
                 ELSE
                      IF vespacio = "F" THEN
                            IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "¥" THEN
                                  LET vquita   = TRIM(vquita)||" Ñ";
                                  LET vespacio = "";
                            ELSE
                                  LET vquita   = TRIM(vquita)||" "||vscampo7[1,1];
                                  LET vespacio = "";
                            END IF;
                      ELSE
                            IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "¥" THEN
                                LET vquita = TRIM(vquita)||vscampo7[1,1];
                            ELSE
                                LET vquita = TRIM(vquita)||vscampo7[1,1];
                            END IF;
                      END IF;
                 END IF;
                 LET vscampo7 = vscampo7[2,4];
                 LET vexiste1 = vexiste1 + 1;
		    END WHILE;

		    LET vscampo7     = TRIM(vquita);
		    LET vlen         = LENGTH(vscampo7);
		    LET vpos         = LPAD(vlen,2,'0');
		    LET vregistro1   = TRIM(vregistro1)||'04'||vpos||vscampo7;
		    LET vlen         = LENGTH(vscampo8);
		    LET vpos         = LPAD(vlen,2,'0');
		    LET vregistro2   = '05'||vpos||vscampo8;
		    LET vlen         = LENGTH(vscampo9);
		    LET vpos         = LPAD(vlen,2,'0');
		    LET vregistro2   = TRIM(vregistro2)||'10'||vpos||vscampo9;
		    -- Marca el FIN de Trailer -->
		    LET vlen         = LENGTH(vregistro) + LENGTH(vregistro1) + LENGTH(vregistro2);
		    LET vlen         = TRUNC(vlen + 15);
		    LET vpo1         = LPAD(vlen,5,'0');
		    LET vregistro2   = TRIM(vregistro2)||'ES05'||vpo1||'0002**';
		  
            IF LENGTH(NVL(vcomentario,"")) = 0 THEN
                LET statuscom =0;
            ELSE
                LET statuscom =3;
            END IF;
		                       
            INSERT INTO bdiburo:br_consulta_bc(institucion,numcte,num_solicitud,fecha_insert,envio,envio1,envio2,status)
                 VALUES ("BC",Num_Cte,NumCred,pFechaHoyAumlincred,vregistro,vregistro1,vregistro2,statuscom);

     LET contador_commit = contador_commit  + 1;

     IF (contador_commit >= 7000) THEN
        COMMIT WORK;
        UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_consulta_bc;
        LET contador_commit = 0;
        BEGIN WORK;
     END IF;

END FOREACH;
/*	   
LET vCont = DBINFO("sqlca.sqlerrd2");
IF vCont = 0 THEN
    LET cCodRet     = "000012";
    LET cMensajeRet = "No se encontraron registros";
    RETURN cCodRet, cMensajeRet;
END IF;
*/
  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;

  UPDATE STATISTICS MEDIUM FOR TABLE "informix".br_consulta_bc;

  LET cMensajeRet       = "Se realizó la consulta correctamente";
  RETURN cCodRet, cMensajeRet;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para insertar la información necesaria para consulta a buró en la tabla br_consulta_bc de credito de los clientes prospectos',
'de la tabla sd_clientes_prospectos que su nueva linea de credito sugerida sea mayor a 6sm de la zona c',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 16/JUNIO/2010',
'BD    : bdiburo';

CREATE PROCEDURE "informix".sp_archivo_consulta_bc(pEmpresa CHAR(3))
RETURNING CHAR(6)  AS codigo_retorno,
          CHAR(80) AS mensaje_retorno;
          
DEFINE cCodRet            CHAR(6); 
DEFINE cMensajeRet        CHAR(80);
DEFINE iSqlErr      	  INTEGER;
DEFINE iIsamErr           INTEGER;
DEFINE cErrorInfo         CHAR(80);
DEFINE iParamRuta         CHAR(3);
DEFINE iParamNombre		  CHAR(3);
DEFINE cSql               CHAR(2024);
DEFINE cSql2              CHAR(2024);
DEFINE cNombreArchivo1	  CHAR(50);
DEFINE var_rga            CHAR(05);
DEFINE cRuta			  CHAR(100);
DEFINE p_FechaHoy		  DATE;
DEFINE vFechaIni		  DATE;
DEFINE numreg             INTEGER;
DEFINE pFechaHoyAumlincred DATE;

LET iSqlErr               = 0;
LET iIsamErr              = 0;
LET cErrorInfo            = "";
LET cCodRet               = "000000";
LET cMensajeRet           = "Se realizó la consulta correctamente";
--LET iParamRuta      	  = "020";
LET cRuta				  = "";
LET cNombreArchivo1		  = "";
LET p_FechaHoy			  = DATE(1);
LET vFechaIni			  = DATE(1);
LET numreg                = 0;
LET cSql               ="";
let pFechaHoyAumlincred = DATE(1);


BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet;
   END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO 'sp_archivo_consulta_bc.out';
-- TRACE ON;

-- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
SELECT valor 
  INTO cRuta
  FROM bdiburo:br_param 
 WHERE cod_param = 13;
	
IF NVL(cRuta,"")    = "" THEN
    LET cCodRet     = "000011";
    LET cMensajeRet = "Error al obtener la ruta para almacenar el archivo";
    RETURN cCodRet, cMensajeRet;
END IF;

SELECT fecha_hoy 
  INTO pFechaHoyAumlincred
  FROM bdicred:"informix".sd_fechas_aumlincred
 WHERE empresa = pEmpresa;

LET vFechaIni = pFechaHoyAumlincred - 22 UNITS DAY;

-- modificar esta condicion para hacerlo por mes	
SELECT {+INDEX(bdiburo:br_consulta_bc idx_consultar_fhinsert)} COUNT(numcte) 
  INTO numreg
  FROM bdiburo:br_consulta_bc
 WHERE fecha_insert = pFechaHoyAumlincred;
-- WHERE fecha_insert BETWEEN vFechaIni AND pFechaHoyAumlincred;

IF numreg = 0 THEN
    LET cCodRet = '000000';
    LET cMensajeRet = 'No se genero archivo, ya que no hubo clientes a enviar a buro en este mes';                                           
    RETURN cCodRet, cMensajeRet;
ELSE
    -- para generar el archivo 
     LET cNombreArchivo1= 'consulta_bc_' || DAY(pFechaHoyAumlincred) || LPAD(TRIM(MONTH(pFechaHoyAumlincred)::CHAR(2)),2,'0') || YEAR(pFechaHoyAumlincred) || '.txt';
     LET cSql = ' UNLOAD TO ' || TRIM(cRuta) || cNombreArchivo1;
    CALL bdicred:sp_genera_archivo ( TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;
     LET cSql =  ' delimiter "" SELECT ' ;
    CALL bdicred:sp_genera_archivo (TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;
     LET cSql =  '  NVL"("trim"("a.envio")",' || '''" "''' || '")"';
    CALL bdicred:sp_genera_archivo (TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;
     LET cSql =  ' "||" NVL"("trim"("a.envio1")",' || '''" "''' || '")"';
    CALL bdicred:sp_genera_archivo (TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;
     LET cSql =  ' "||" NVL"("trim"("a.envio2")",' || '''" "''' || '")"';
    CALL bdicred:sp_genera_archivo (TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;	
     LET cSql =' FROM bdiburo:br_consulta_bc a ';
    CALL bdicred:sp_genera_archivo (TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;
     LET cSql =' WHERE a.fecha_insert = ' || '''"''' || pFechaHoyAumlincred ||  '''"''' ||''';''';
    CALL bdicred:sp_genera_archivo (TRIM(cRuta) || 'archivoquery.sql',cSql) returning var_rga;

    IF (cSql <> '') THEN 
        LET cSql = '';
        LET cSql = "dbaccess bdiburo " ||TRIM(cRuta)||'archivoquery.sql';
        SYSTEM cSql;
        -- borrado de temporales que fueron usados para la creacion del archivo a enviar a buro de credito
        LET cSql = '';
        LET cSQL = "rm " ||TRIM(cRuta)||'archivoquery.sql';		
        SYSTEM cSql; 

        LET cCodRet = "000000";
        LET cSql    = "";

             -- registarar en  sd_envios_solicitudes   el archivo que se envio con los registros consultados
        INSERT INTO bdicred:sd_envios_solicitudes(institucion, nombre_archivo, fecha_envio, fecha_recepcion,num_registros) 
             VALUES ("BC", cNombreArchivo1, pFechaHoyAumlincred,"",numreg);
--                  VALUES ("BC", cNombreArchivo1, p_FechaHoy,"",numreg);
             
             -- update a br_consulta_bc para acutalizar el nombre del archivo en que se fueron los registros
        UPDATE bdiburo:br_consulta_bc
           SET nombre_archivo = cNombreArchivo1
         WHERE fecha_insert BETWEEN vFechaIni AND pFechaHoyAumlincred;
--               WHERE fecha_insert BETWEEN vFechaIni AND p_FechaHoy;
    ELSE
        LET cCodRet      = "000001";
        LET cMensajeRet  = "Error Generar el archivo";
    END IF;
END IF;

    RETURN cCodRet, cMensajeRet;
END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para extraer la informacion registrada',
'en la tabla br_consulta_bc y alamacenarla en un archivo .txt',
'ademas de grabar en la tabla sd_envios_solicitudes un registro',
'para identificar el archivo y fecha de envio a BC',
'AUTOR : Jesús Manuel Aguilar Heredia',
'FECHA : 16/JUNIO/2010',
'BD    : bdiburo';

CREATE PROCEDURE "informix".sp_valida_respuesta_bc_repro(pEmpresa CHAR(3),pFechaHoyAumlincred DATE)

RETURNING CHAR(6), 	 -- Codigo de Retorno
		  VARCHAR(255);  -- Descripcion del error

--------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Se valida la respuesta de buro de crédito para los clientes que  fueron prospectos a un incremento en su linea de crédito.
-- Fecha de Creación: Junio-2010
-- Proyecto: Aumento de lineas de credito folio 1159
--------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Modificación: Se modifica para contemplar los incrementos automaticos para clientes que tengan activa esta opcion, 
-- Fecha de modificación: 04-03-2011
-- Proyecto: 1229-IncrementosAutLinCredTDC
----------------------------------------------------------------------------------
-- Autor: Jesús Manuel Aguilar Heredia
-- Modificación: Se modifica para activar la opcion de envio a supervicion cac  a clientes que requieran ser consultados
-- Fecha de modificación: 28-09-2011
-- Proyecto: 1286-IncrementoLinCredSIF
----------------------------------------------------------------------------------
-- Autor: Josué Remberto Zazueta Acosta
-- Modificación: Se borra código comentado,se agregan informix y bd a las tablas que no tenían, Se implementan reglas de informix
-- Fecha de modificación: 02/Octubre/2012
-- BD : bdicred
----------------------------------------------------------------------------------

--****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret      CHAR(5);
DEFINE cCodRet       CHAR(6); 
DEFINE vsqlerr       INTEGER;
DEFINE sql_err       SMALLINT;
DEFINE isam_err      SMALLINT;

DEFINE error_info    CHAR(100);
DEFINE s_califica    CHAR(1);
DEFINE s_compromisos DECIMAL(14,2);
DEFINE vStatus	     CHAR(2);
DEFINE cUser         CHAR(10);

DEFINE vStatusAnt    CHAR(2);
DEFINE vMensaje      VARCHAR(255);
DEFINE vCuantos      SMALLINT;
DEFINE vMoneda       CHAR(2);

DEFINE vMonto        DECIMAL(14,2);
DEFINE vMontoUdis    DECIMAL(14,2);
DEFINE vCodUdi       CHAR(2);
DEFINE vCodUs        CHAR(2);
DEFINE vClase        CHAR(1);

DEFINE vTpCambioUdi  DECIMAL(14,6);
DEFINE vTpCambioUs   DECIMAL(14,6);
DEFINE vMaxMtoUdi    DECIMAL(14,2);
DEFINE vTl11         CHAR(1);
DEFINE vTl16         DATE;
DEFINE vTl17         DATE;
DEFINE vfecha        DATE;
--DEFINE vFechaHoy     DATE;

DEFINE vTl26         CHAR(2);
DEFINE vTl27		CHAR(24);
DEFINE vTl30         CHAR(2);
define vRespuesta    INTEGER;
DEFINE cTpSolicitud     CHAR(1);
define vDescripcion_status char(40);
define i            integer;
define vmesescon    integer;
define vmescuenta   integer;
define v_sc01       varchar(04);
DEFINE sCommit                       SMALLINT;
DEFINE contador_commit               INTEGER;
DEFINE 	cNumcliente		 CHAR(20);
DEFINE 	cNumcred		     CHAR(20);
DEFINE cstatus           CHAR(2);
DEFINE vCausa			 CHAR(3);
DEFINE cComentario       CHAR(80);
DEFINE vSC01         CHAR(4);
DEFINE sLineaCreditoCAC      INTEGER;
DEFINE dLineaSugerida        DECIMAL(18,2);
DEFINE cIncreAuto CHAR(1);
DEFINE cSucursal CHAR(4);
DEFINE cPregunta CHAR(200);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret      = "00000";
LET cCodRet       = "000000";
LET vsqlerr       = 0;
LET s_califica    = "X";
LET s_compromisos = 0;

LET vStatus       = "";
LET vStatusAnt    = "";
LET vMontoUdis    = 0;
LET vTpCambioUs    = 0;
LET cTpSolicitud  = "";
let vDescripcion_status = "";
let v_sc01       = "";
--LET vFechaHoy     = DATE(1);
LET vClase       = "";
LET sCommit                 = 0;
LET contador_commit         = 0;
LET	cNumcliente	= "";
LET	cNumcred		= "";
LET	cstatus     = "";
LET	vCausa		= "";
LET	cComentario = "";
LET vSC01       = "";
LET cUser                    = USER;
LET sLineaCreditoCAC  = 0;
LET dLineaSugerida  		 = 0;
LET cIncreAuto  		 = "";
LET cSucursal  		 = "";
LET cPregunta  		 = "";

--SET DEBUG FILE TO "sp_valida_respuesta_bc_prueba.out";
--TRACE ON;

SELECT TRIM(valor)::integer
  INTO vmesescon
  FROM bdiburo:"informix".br_param
 WHERE cod_param = 12;

   IF vmesescon IS NULL THEN
      LET vmesescon=12;
   END IF;

      -- *****************************************

      --       Extrae Tipo de Cmabio Divisa      *
      -- *****************************************
SELECT TRIM(valor) 
  INTO vCodUdi
  FROM bdinteg:"informix".si_param
 WHERE empresa = pEmpresa
   AND cod_param = 16;

SELECT TRIM(valor) 
  INTO vCodUs
  FROM bdinteg:"informix".si_param
 WHERE empresa = pEmpresa
   AND cod_param = 17;

SELECT valor 
  INTO sLineaCreditoCAC
  FROM bdicred:"informix".sd_param 
 WHERE cod_param = '028'
   AND empresa = pEmpresa ;


      -- *****************************************
      -- Extrae Clase de Tipo de Cmabio para UDI *
      -- *****************************************
      SELECT TRIM(valor) INTO vClase
	    FROM bdicred:"informix".sd_param
       WHERE empresa = pEmpresa
	     AND cod_param = "336";

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, pFechaHoyAumlincred,vCodUdi,vClase,'0')
    INTO scod_ret,vTpCambioUdi;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, "NO SE ENCONTRO VALOR DE UDI";
    END IF;

    EXECUTE PROCEDURE bdinteg:"informix".valor_divisa_pesos(pEmpresa, pFechaHoyAumlincred,vCodUs,vClase,'1')
    INTO scod_ret,vTpCambioUs;

    IF scod_ret<>'00000' THEN
      RETURN scod_ret, "NO SE ENCONTRO VALOR DE USA";
    END IF;

SELECT valor 
  INTO vMaxMtoUdi
  FROM bdisolic:ss_param
 WHERE empresa = pEmpresa
   AND secuencia = "309";

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
--      SET DEBUG FILE TO "CargoLineaCredito.err";
      LET scod_ret = sql_err;

      IF (sCommit = -1) THEN
          rollback work;
      END IF;

      RETURN scod_ret, vMensaje;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

-- ***********************************************
-- Ini Caja Unica
-- ***********************************************

LET vMensaje      = "";
--se modifica la consulta principal para obtener el valor de la sucursal deonde se origino el credito y el valor que indica si tiene activo los incrementos automaticos.
FOREACH WITH HOLD
    SELECT a.numcte, a.num_solicitud,b.ajuste_de_cuota,b.sucursal,a.institucion
		INTO cNumcliente, cNumcred ,cIncreAuto,cSucursal, vDescripcion_status
	FROM bdiburo:"informix".br_respuesta_bc a
    INNER JOIN bdisolic:"informix".ss_solicitudes b on b.empresa = '001' AND b.num_solicitud = a.num_solicitud 
	 WHERE a.institucion='BC' 
       AND a.fecha_insert = pFechaHoyAumlincred

    LET s_califica  = "X";
    LET vMensaje = cNumcred || ' VALIDA_RESPUESTA_BURÓ';

    IF EXISTS (SELECT num_solicitud FROM bdicred:"informix".sd_bitacora_aumlincred WHERE fecha_insert = pFechaHoyAumlincred AND num_solicitud = cNumcred AND empresa = pEmpresa AND status = "RT" AND origen = "C") THEN CONTINUE FOREACH; END IF; 

    SELECT lincred_sugerida INTO dLineaSugerida 
    FROM bdicred:"informix".sd_bitacora_aumlincred 
    WHERE empresa = pEmpresa
    AND num_solicitud = cNumcred 
    AND status = "BC"
    AND fecha_insert = pFechaHoyAumlincred 
    AND origen = "C";

    IF dLineaSugerida IS NULL or dLineaSugerida = '' THEN CONTINUE FOREACH; END IF; 

--Se cancelan las solicitudes cuya respuesta de Buró hayan sido por error
    IF cNumcliente IS NULL THEN
		LET s_califica = "1";
		LET vMensaje = 'SOLICITUD CON ERROR EN BURÓ DE CRÉDITO';

		LET cstatus     = "CN";
		LET vCausa      = "CEV";
		LET cComentario = "CANCELADO POR EVENTUALIDADES";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

       CONTINUE FOREACH;
	END IF


    IF (sCommit = 0) THEN
        BEGIN WORK;
        LET contador_commit = 0;
        LET sCommit = -1;
    END IF; 

     LET contador_commit = contador_commit  + 1;

     IF (contador_commit >= 7000) THEN
        COMMIT WORK;
--        UPDATE STATISTICS MEDIUM FOR TABLE bdicred:"informix".sd_bitacora_aumlincred;
        LET contador_commit = 0;
        BEGIN WORK;
     END IF;

	LET vCuantos = 0;
	LET vMensaje = "CREDITOS CON ANTECEDENTES EN "|| trim(vDescripcion_status)|| ":" ;
	FOREACH
            SELECT tl11, 
                   NVL(tl26,''), 
                   NVL(substr(NVL(tl27,''),1,vmesescon),''),
                   round(CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN  (NVL(b.tl24,0) * factor)/vTpCambioUdi
                              WHEN tl08 = 'US'                THEN ((NVL(b.tl24,0) * vTpCambioUs) * factor) /vTpCambioUdi
                              WHEN tl08 = 'UD'                THEN   NVL(b.tl24,0) * factor
                              ELSE NVL(b.tl24,0) * factor
                          END,2),
                   tl16,tl17,fecha
              INTO vTl11, vTl26, vTl27, vMontoUdis,vTl16,vTl17,vfecha
          	  FROM bdiburo:"informix".br_tl_bc b, bdisolic:"informix".ss_circulo_frecpag c
         	 WHERE b.numcte  = cNumcliente
          	   AND NVL(tl26,'') <> ''
               AND b.tl11=c.tipo
             ORDER BY tl26 DESC
-- MOP ACTUAL

        IF vMontoUdis >= vMaxMtoUdi AND vTl26 = '03' THEN -- Solo aplica para MOP 02
            LET vCuantos = 1;
            LET vMensaje = trim(vMensaje)||"Mto Max Udi:" || vMaxMtoUdi ||"Mto Udi Cte MOP_03:" || vMontoUdis;
            EXIT FOREACH;
        END IF

       IF NOT EXISTS(SELECT codigo
                       FROM bdiburo:br_tlmop
                      WHERE codigo = vTl26
                        AND status_cons IN (0,2,3)) THEN
          LET vCuantos = 1;
          LET vMensaje = TRIM(vMensaje) || ' P:' || TRIM(vTl26);

          EXIT FOREACH;
       END IF;

-- MOP HISTORICO

       let i = 0;
      
       IF vTl17 IS NOT NULL AND vfecha IS NOT NULL THEN
          LET vmescuenta = ROUND((vfecha-vTl17)/30,0);
           IF vmescuenta > vmesescon THEN
              LET vmescuenta = -1;
           ELSE
              LET vmescuenta = vmesescon - vmescuenta;
           END IF;
       END IF;

       for i = 1 TO LENGTH(TRIM(vTl27))  -- se revisan los últimos 12 meses
          let vTl26 = SUBSTR(vTl27,i,1);

          IF NOT EXISTS(SELECT codigo FROM bdiburo:"informix".br_tlphp
                          WHERE codigo=vTl26
                            AND status_cons in (-1,0,2,3)) THEN
                 IF vTl26 = 4 THEN
                    IF i <= vmescuenta AND vTl17 IS NULL AND vMontoUdis >= vMaxMtoUdi THEN
                         LET vCuantos = 1;
                         LET vMensaje = TRIM(vMensaje) || ' P:' || TRIM(vTl26);
                         EXIT FOREACH;
                    END IF;
                 ELSE
                     LET vCuantos = 1;
                     LET vMensaje = TRIM(vMensaje) || ' P:' || TRIM(vTl26);
                     EXIT FOREACH;
                 END IF;
           END IF;
       END FOR;

	END FOREACH;

	IF vCuantos > 0 THEN
		LET s_califica = "1";
		LET vMensaje = trim(vMensaje);

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "Rechazado Por Buro de Crédito";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

         CONTINUE FOREACH;
	END IF

	-- *******************+*******************************************
	-- Determina si el Cliente tiene claves de exclusion eb BC-SCORE *
	-- ***************************************************************

	LET vCuantos = 0;
--	LET vMensaje = "Rechazo por malos antecedentes en Buro de Credito";

    select sc01
      into v_sc01
      from bdiburo:"informix".br_sc_bc
     where numcte = cNumcliente;

    IF ( v_sc01 is not null ) then
         IF EXISTS(SELECT codigo
                     FROM bdiburo:"informix".br_scvsc
                    WHERE codigo = v_sc01
                      AND status_cons = 1) THEN
            LET vCuantos = 1;
         END IF;
    END IF;

	IF vCuantos > 0 THEN
		LET s_califica = "1";
		LET vMensaje = "RECHAZO POR MALOS ANTECEDENTES " || trim(vDescripcion_status) || ":" || vMensaje;

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "RECHAZADO POR BURO DE CRÉDITO";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

         CONTINUE FOREACH;
	END IF
	-- *******************+*********************************
	-- Determina si el Cliente tiene creditos inaceptables *
	-- *****************************************************
   LET vCuantos = 0;
  --LET vMensaje = "Creditos con Claves de Prevencion:";
   FOREACH 
      SELECT b.tl30 
        INTO vStatus
        FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl_bc b
       WHERE b.numcte  = cNumcliente
         AND a.status = b.tl30
         AND a.rango_rechazo = "1"

       LET vCuantos = vCuantos + 1;

       IF vStatus <> vStatusAnt THEN
           LET vMensaje = TRIM(vMensaje) || ' ' || TRIM(vStatus);
           LET vStatusAnt = vStatus;
       END IF
   END FOREACH

   IF vCuantos > 0 THEN
       LET s_califica = "1";
	   LET vMensaje = "CREDITOS CON CLAVES DE PREVENCION " || trim(vDescripcion_status) || ":" || vMensaje;

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "RECHAZADO POR BURO DE CRÉDITO";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

        CONTINUE FOREACH;
   END IF

    -- *****************************************************
    -- Determina si el Cliente tiene creditos inaceptables *
    -- por status de circulo de credito	               *
    -- *****************************************************
   LET vCuantos = 0;
   LET vMensaje = "";

   FOREACH 
     SELECT tl11,tl26, tl30 
       INTO vTl11,vTl26, vTl30
       FROM bdiburo:"informix".br_tl_bc b
      WHERE b.numcte  = cNumcliente
 --        AND NVL(tl11,'') <> '' -- finalidad de descartar los creditos de los cuales requiere una
        AND NVL(tl26,'') <> '' -- una autorizacion del analista

       LET vRespuesta = 0;
       SELECT count(status)
         INTO vRespuesta
         FROM bdisolic:"informix".ss_circulo_status 
        WHERE status = vTl30              -- se agrega la validacion del status
          AND rango_rechazo IN ('2','3'); --  y el rango de rechazo sea diferente de 2 con la

       IF vRespuesta IS NULL OR vRespuesta = 0 THEN
           IF NOT EXISTS(SELECT status 
                           FROM bdisolic:"informix".ss_circulo_exceppago
                          WHERE empresa=pEmpresa
                            AND status <> 0
                            AND frecpago = vTl11
                            AND perpago = vTl26) THEN

                   LET vCuantos = vCuantos + 1;
                   LET vMensaje = TRIM(vMensaje)
                               || ' F:' || TRIM(vTl11)
                               || ' P:' || TRIM(vTl26);
           END IF;
       END IF;
   END FOREACH

   IF vCuantos > 0 THEN
       LET s_califica = "1";
	   LET vMensaje = "CREDITOS CON ANTECEDENTES " || trim(vDescripcion_status) || ":" || vMensaje;
		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "RECHAZADO POR BURO DE CRÉDITO";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

        CONTINUE FOREACH;
   END IF
    -- *******************+**************************************
    -- Determina si el Cliente tiene creditos con los cuales se *
    -- requiera una autorizacion de analista		    *
    -- *******************+***************************************
   LET vCuantos = 0;
   LET vMensaje = "";
   FOREACH 
     SELECT b.tl30 
       INTO vStatus -- SELECT b.tl07 INTO vStatus
       FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl_bc b
      WHERE b.numcte  = cNumcliente
        AND a.status = b.tl30 -- se modifica a.status = b.tl07
        AND a.rango_rechazo = "2"

       LET vCuantos = vCuantos + 1;
       IF vStatus <> VstatusAnt THEN
           LET vMensaje = TRIM(vMensaje) || ' ' || TRIM(vStatus);
           LET vStatusAnt = vStatus;
       END IF
   END FOREACH

   IF vCuantos > 0 THEN
       LET s_califica = "2";
	   LET vMensaje = "CREDITOS CON ANTECEDENTES " || trim(vDescripcion_status) || ":" || vMensaje;
   END IF

    -- **************************************************************
    -- Determina crediitos que se encuentren en status con rango de *
    -- rechazo 3 y no excedan del monto en udis determinado		*
    -- **************************************************************
   LET vCuantos = 0;
   LET vMensaje = "";
    --- se modifica el FOREACH en el campo vMonto para la condicion de la sumatoria

        SELECT ROUND(SUM(CASE WHEN b.tl30 <> 'CV' AND tl08 = 'N$' OR tl08 = 'MX' THEN ((NVL(b.tl36,0) + NVL(b.tl24,0)) * factor)/vTpCambioUdi
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'N$' OR tl08 = 'MX' THEN (NVL(b.tl36,0)* factor)/vTpCambioUdi
                                           ELSE CASE WHEN tl08 = 'N$' OR tl08 = 'MX' THEN (NVL(b.tl21,0)* factor)/vTpCambioUdi 
                                                      ELSE 0 END END
                           END +
                           CASE WHEN b.tl30 <> 'CV' AND tl08 = 'US' THEN (((NVL(b.tl36,0) + NVL(b.tl24,0))* vTpCambioUs) * factor) /vTpCambioUdi
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'US' THEN (NVL(b.tl36,0) * vTpCambioUs) * factor/vTpCambioUdi
                                          ELSE CASE WHEN tl08 = 'US' THEN (NVL(b.tl21,0) * vTpCambioUs) * factor/vTpCambioUdi 
                                                    ELSE 0 END END
                           END +
                           CASE WHEN b.tl30 <> 'CV' AND tl08 = 'UD' THEN (NVL(b.tl36,0) + NVL(b.tl24,0)) * factor
                                ELSE CASE WHEN b.tl36 <> 0.00 AND tl08 = 'UD' THEN NVL(b.tl36,0) * factor
                                           ELSE CASE WHEN tl08 = 'UD' THEN NVL(b.tl21,0) * factor 
                                                     ELSE 0 END END  
                           END),2)
        INTO vMontoUdis 
        FROM bdisolic:"informix".ss_circulo_status a, bdiburo:"informix".br_tl_bc b, bdisolic:"informix".ss_circulo_frecpag c 
        WHERE b.numcte  = cNumcliente
        AND a.status = b.tl30  -- se modifica a.status = b.tl07
        AND b.tl11 = c.tipo
        AND a.rango_rechazo = "3"
        AND tl02 <> 'SIC';

   IF vMontoUdis IS NULL OR vMontoUdis = '' THEN LET vMontoUdis = 0; END IF;

   IF vMontoUdis > vMaxMtoUdi THEN
       LET s_califica = "1";
		LET vMensaje = "Creditos con Antecedentes " || trim(vDescripcion_status) || ":" ||  "Mto Max Udi:" || vMaxMtoUdi ||
       				"Mto Udi Cte:" || vMontoUdis;

		LET cstatus     = "RT";
		LET vCausa      = "RBC";
		LET cComentario = "Rechazado Por Buro de Crédito";

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

         CONTINUE FOREACH;
   END IF

   IF vCuantos > 0 AND s_califica = "2" THEN
       LET s_califica = "4";
   ELIF vCuantos > 0 AND s_califica = "0" THEN
       LET s_califica = "3";
   END IF

    SELECT round(NVL(sum(case when tl08 = 'N$' or tl08 = 'MX'  then tl12 * b.factor  else 0 end),0) +
           NVL(sum(case when tl08 = 'UD' then (tl12 * b.factor) * vTpCambioUdi else 0 end),0) +
           NVL(sum(case when tl08 = 'US' then (tl12 * b.factor) * vTpCambioUs else 0 end),0),2),
           count(numcte)
    INTO s_compromisos, vCuantos
    FROM bdiburo:"informix".br_tl_bc a, bdisolic:"informix".ss_circulo_frecpag b
    WHERE a.tl11 = b.tipo
    AND numcte = cNumcliente 
    AND tl02 <> 'SIC'; 

   IF s_compromisos IS NULL THEN
      LET s_compromisos = 0;
   END IF

   IF vCuantos > 0 AND s_califica = "X" THEN
       LET s_califica = "0";
   END IF

   IF s_califica = "0" THEN
		LET vMensaje ="BUEN COMPORTAMIENTO " || trim(vDescripcion_status);
   ELIF s_califica = "X" THEN
		LET vMensaje ="COMPORTAMIENTO NULO EN SIC";
   END IF
/*
    SELECT lincred_sugerida INTO dLineaSugerida 
    FROM bdicred:"informix".sd_bitacora_aumlincred 
    WHERE empresa = pEmpresa
    AND num_solicitud = cNumcred 
    AND status = "BC"
    AND fecha_insert = pFechaHoyAumlincred 
    AND origen = "C";
*/
--Determina si la solicitud se va al CAC para análisis o se autoriza
--temporalmente se autorizan todas las solicitudes hasta que se genere la pantalla de determinación de línea del CAC
   IF (dLineaSugerida > sLineaCreditoCAC) THEN --se compara en pesos y no en salarios mínimos
      LET cstatus     = "AC";      LET vCausa      = "";
      LET cComentario = "En análisis por el CAC";	
   ELSE
      LET cstatus     = "AT";
      LET vCausa      = "";
      LET cComentario = "Requiere Autorización del cliente para su aplicación";
   END IF;

		UPDATE bdicred:"informix".sd_bitacora_aumlincred 
	       SET califica_buro = s_califica,
               status        = cstatus,
               mensaje       = vMensaje,
               causa_status  = vCausa,
			   fecha_status  = today,
               hora_status   = current
        WHERE empresa = pEmpresa
        AND num_solicitud = cNumcred 
        AND status = "BC"
        AND fecha_insert = pFechaHoyAumlincred; 

       INSERT INTO bdicred:"informix".sd_autorizacion_aumlincred(empresa, num_solicitud, status, causa_status, user_insert, fecha_status, fecha_insert, revision_cac) 
            VALUES(pEmpresa, cNumcred, cstatus, vCausa, cUser, today, pFechaHoyAumlincred, 0);

	--se agrega validacion para ver si el cliente cuenta con incrementos automaticos, si es asi se manda llamar al procedimiento sp_registrarrespuestacte para simular la respuesta de autorizacion del cliente.
	IF cIncreAuto ='S' AND  cstatus= "AT" THEN
	
		LET cPregunta= "Autorizo expresamente a BanCoppel a incrementar mi linea de crédito a $" ||dLineaSugerida|| ", así mismo, acepto las nuevas condiciones y términos aplicables a partir de esta fecha.";
		EXECUTE PROCEDURE bdicred:"informix".sp_registrarrespuestacte(pEmpresa,cNumcred,'1',cPregunta,cSucursal,'sistema') INTO scod_ret, vMensaje;
		
		IF scod_ret <> "00000" THEN
			LET scod_ret = "00001";
			LET vMensaje = "Error al realizar incremento automático de línea para el crédito  " || cNumcred;
			
			RETURN scod_ret, vMensaje;
		END IF;	
	END IF;
	
	LET cstatus     = "";
	LET vCausa      = "";
	LET cComentario = "";
    LET vMensaje    = "";
    LET dLineaSugerida = 0;

END FOREACH;

  IF sCommit = -1 THEN
     COMMIT WORK;
  END IF;
  LET sCommit = 0;

  LET vMensaje     = "Se realizó la consulta correctamente";

END
    LET cCodRet = "000000";
    RETURN cCodRet, vMensaje;
END PROCEDURE;