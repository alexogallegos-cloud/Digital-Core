CREATE PROCEDURE "informix".sp_circulocred_intl(pApePaterno CHAR(26),pApeMaterno CHAR(26),pNombres CHAR(50),
pFecNac CHAR(10),pRFC CHAR(13),pTipoRes CHAR(1),pEdoCivil CHAR(1),pSexo CHAR(1),
pDependientes CHAR(2),pDireccion CHAR(40),pColonia CHAR(40),pDelegacion CHAR(40),pCiudad CHAR(40),
pEstado CHAR(4),pCodigoPostal CHAR(5),pTipoDomicilio CHAR(1),pFolio CHAR(25))
RETURNING  CHAR(05) AS codret;

    ---------------DECLARACION DE VARIABLES
	DEFINE vregistro CHAR(255);
	DEFINE vregistro1 CHAR(255);
    DEFINE vregistro2 CHAR(255);
	DEFINE vcliente CHAR(20);
	DEFINE vlen INTEGER;
	DEFINE vpos CHAR(2);
	DEFINE vpo1 CHAR(5);
	DEFINE vdia CHAR(2);
	DEFINE vmes CHAR(2);
	DEFINE vanio CHAR(4);
	-- Variables para ver si se va a Buro o no --
	DEFINE vf1mes DATE;
	DEFINE vstatus CHAR(2);
	DEFINE vcodret CHAR(5);
	DEFINE vecampo1 CHAR(4);
	DEFINE vecampo2 CHAR(2);
	DEFINE vecampo3 CHAR(25);
	DEFINE vecampo4 CHAR(3);
	DEFINE vecampo5 CHAR(2);
	DEFINE vecampo6 CHAR(4);
	DEFINE vecampo7 CHAR(10);
	DEFINE vecampo8 CHAR(8);
	DEFINE vecampo9 CHAR(1);
	DEFINE vecampo10 CHAR(2);
	DEFINE vecampo11 CHAR(2);
	DEFINE vecampo12 CHAR(9);
	DEFINE vecampo13 CHAR(2);
	DEFINE vecampo14 CHAR(2);
	DEFINE vecampo15 CHAR(1);
	DEFINE vecampo16 CHAR(4);
	DEFINE vecampo17 CHAR(7);
	DEFINE vexiste INTEGER;
	DEFINE vcodini INTEGER;
	DEFINE vcodfin INTEGER;
	-- Datos del Cliente --
	DEFINE vdcampo1 CHAR(2);
	DEFINE vdcampo2 CHAR(26);
	DEFINE vdcampo3 CHAR(26);
	DEFINE vdcampo4 CHAR(26);
	DEFINE vdcampo5 CHAR(26);
	DEFINE vdcampo6 CHAR(10);
	DEFINE vdcampo7 CHAR(13);
	DEFINE vdcampo8 CHAR(2);
	DEFINE vdcampo9 CHAR(1);
	DEFINE vdcampo10 CHAR(1);
	DEFINE vdcampo11 CHAR(1);
	DEFINE vdcampo12 CHAR(2);
	DEFINE vscampo1 CHAR(2);
	DEFINE vscampo2 CHAR(40);
	DEFINE vscampo3 CHAR(40);
	DEFINE vscampo4 CHAR(40);
	DEFINE vscampo5 CHAR(40);
	DEFINE vscampo6 CHAR(40);
	DEFINE vscampo7 CHAR(4);
	DEFINE vscampo8 CHAR(5);
	DEFINE vscampo8a INTEGER;
	DEFINE vscampo9 CHAR(1);
	DEFINE vexiste1 SMALLINT;
	DEFINE vquita CHAR(40);
	DEFINE vespacio CHAR(1);
	DEFINE vmanzana SMALLINT;
	DEFINE vandador SMALLINT;
	DEFINE vlote SMALLINT;
	DEFINE vedificio SMALLINT;
	DEFINE ventrada SMALLINT;
	DEFINE vsecuencia SMALLINT;
	DEFINE vcomentario CHAR(80);
	DEFINE vhora datetime HOUR TO fraction(3);
	DEFINE vfecha DATE;
	DEFINE status_1 CHAR(2);  ---cambio CAS
	DEFINE status_2 CHAR(2);  ---cambio CAS
	DEFINE producto_sol CHAR(20);
	DEFINE siglas_producto CHAR(2);
	DEFINE cResultado CHAR(6);
	DEFINE cMensajeRes CHAR(8);
	DEFINE iSql_err INTEGER;
    DEFINE vnumerocalle INTEGER;
	DEFINE iFlag2credito SMALLINT;
	DEFINE valida_hit CHAR(1);
	DEFINE vfechaServ DATE;
	
---------------INICIALIZACION DE VARIABLES
	LET vhora = extend(CURRENT,HOUR TO fraction(3));
	LET vregistro ="";
	LET vregistro1="";
	LET vregistro2="";
	LET vcliente ="";
	LET vlen =0;
	LET vpos="";
	LET vdia="";
	LET vmes="";
	LET vanio="";
	LET vf1mes="";
	LET vstatus="";
	LET vcodret="000";
    LET status_1="00";
    LET status_2="00";
    LET producto_sol = "";
    LET siglas_producto = "";
	LET cResultado = "";
	LET cMensajeRes = "";
	LET iSql_err        = 0 ;
	LET vpo1 = "";
	LET vecampo1 = "";
	LET vecampo2 = "";
	LET vecampo3 = "";
	LET vecampo4 = "";
	LET vecampo5 = "";
	LET vecampo6 = "";
	LET vecampo7 = "";
	LET vecampo8 = "";
	LET vecampo9 = "";
	LET vecampo10 = "";
	LET vecampo11 = "";
	LET vecampo12 = "";
	LET vecampo13 = "";
	LET vecampo14 = "";
	LET vecampo15 = "";
	LET vecampo16 = "";
	LET vecampo17 = "";
	LET vexiste = 0;
	LET vcodini = 0;
	LET vcodfin = 0;
	LET vdcampo1 = "";
	LET vdcampo2 = "";
	LET vdcampo3 = "";
	LET vdcampo4 = "";
	LET vdcampo5 = "";
	LET vdcampo6 = "";
	LET vdcampo7 = "";
	LET vdcampo8 = "";
	LET vdcampo9 = "";
	LET vdcampo10 = "";
	LET vdcampo11 = "";
	LET vdcampo12 = "";
	LET vscampo1 = "";
	LET vscampo2 = "";
	LET vscampo3 = "";
	LET vscampo4 = "";
	LET vscampo5 = "";
	LET vscampo6 = "";
	LET vscampo7 = "";
	LET vscampo8 = "";
	LET vscampo8a = 0;
	LET vscampo9 = "";
	LET vexiste1 = 0;
	LET vquita = "";
	LET vespacio = "";
	LET vmanzana = 0;
	LET vandador = 0;
	LET vlote = 0;
	LET vedificio = 0;
	LET ventrada = 0;
	LET vsecuencia = 0;
	LET vcomentario = "";
    LET vnumerocalle = 0;
	LET iFlag2credito = 0;
	LET valida_hit ="";

BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err 
		IF iSql_err <> 0 THEN
			LET vcodret = iSql_err;		
			RETURN vcodret;
		END IF;
	END EXCEPTION;
	
	
	--SET DEBUG FILE TO '/informix/IPCB/AUTENTICA/sp_circulocred_intl_'||trim(pRFC)||'.out';   
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	SELECT fecha_hoy 
	INTO vfecha 
	FROM bdicred:"informix".sd_fechas;
	
	--RQI 21 246  Originación de solicitudes 24 x 7 INI
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;
	
	IF vfecha < vfechaServ THEN
		LET vfecha = vfechaServ;
	END IF;
	--RQI 21 246  Originación de solicitudes 24 x 7 FIN
	
	LET vstatus = 'BC';
	
	SELECT TRIM(valor) INTO vecampo7
	FROM "informix".br_param
	WHERE cod_param = 1;
	
	SELECT TRIM(valor) INTO vecampo8
	FROM "informix".br_param
	WHERE cod_param = 2;
	
	--SE AJUSTA CLAVE ESTADO EN CASO DE BAJA CALIFORNIA NORTE PARA CICRCULO
	IF pEstado ='BC' THEN
		LET pEstado ='BCN';
	END IF;
	
    -- Declaracion de Constantes para Generacion de Registros desea ver que significa cada campo
    -- Favor de consultar el manual -->
	LET vecampo1="INTL";
	LET vecampo2="11";
	--- COLOCACION DE NUMERO DE SOLICITUD
	LET vecampo3 =pFolio||"     ";
	LET vecampo4="001";
	LET vecampo5="MX";
	LET vecampo6="0000";
	--LET vecampo7 = "";
	--LET vecampo8 = "";
	LET vecampo9="I";
	LET vecampo10="";	
	LET vecampo11="MX";
	LET vecampo12="0"; --monto solicitado
	LET vecampo13="SP";
	LET vecampo14="03";	
	LET vecampo15=" ";
	LET vecampo16="    ";
	LET vecampo17="0000000";
	LET vexiste=0;
	LET vcomentario = "";
	
	SELECT TRIM(valor) INTO vecampo4
    FROM "informix".br_param
    WHERE cod_param = 152;  
	
	--IPCB falto asignacion de valor CC
	LET siglas_producto = 'CC';
    LET vecampo10 = siglas_producto;
	LET status_2 = 'CC';
	
	--IPCB Falto completado de 0 en el campo 12
	LET vecampo12=LPAD(round(vecampo12,0),9,"0");
	
	LET vregistro= vecampo1||vecampo2||vecampo3||vecampo4||vecampo5||
	    vecampo6||vecampo7||vecampo8||vecampo9||vecampo10||vecampo11||vecampo12||vecampo13||
	    vecampo14||vecampo15||vecampo16||vecampo17;
	-- Datos del Cliente --
	LET vdcampo1="PN"; --Identificador de cadena--
	LET vdcampo2=pApePaterno; --Apellido Paterno PN--
	LET vdcampo3=pApeMaterno; --Apellido Materno 00--
	LET vdcampo4=pNombres;
	--LET vdcampo4=pPrimerNom; --Primer Nombre 02--
	--LET vdcampo5=pSegundoNom; --Segundo Nombre 03--
	LET vdcampo6=pFecNac; --Fecha de Nacimiento 04--
	LET vdcampo7=pRFC; --RFC 05--
	LET vdcampo8="MX"; --Nacionalidad MX o EX 08--
	LET vdcampo9=pTipoRes; --Residencia o Tipo Vivienda 09 1=Prop 2=Renta 3=Pension--
	LET vdcampo10=pEdoCivil; --Estado Civil 11 --
	LET vdcampo11=pSexo; --Sexo 12--
	LET vdcampo12=pDependientes; --Dependiente 17--
	-- Direccion del Cliente --
	LET vscampo1="PA"; --Identificador de cadena--
	LET vscampo2=pDireccion;
	--LET vscampo2=pDireccion1; --Direccion Linea 1 PA--
	--LET vscampo3=pDireccion2; --Direccion Linea 2 00--
	LET vscampo4=pColonia; --Colonia o Poblacion 01--
	LET vscampo5=pDelegacion; --Delegacion o Municipio 02--
	LET vscampo6=pCiudad; --Nombre Ciudad 03--
	LET vscampo7=pEstado; --Estado 04--
	LET vscampo8=pCodigoPostal; --Codigo Postal 05--
	LET vscampo9=pTipoDomicilio; --Tipo de Domicilio 10--
	
	-- Cambia las Ã?Â?Ã?Â?Ã?Â?Ã?Â? de los Nombres y Apellidos --
    IF vdcampo2 IS NULL THEN LET vdcampo2 = ""; LET vcomentario = "Apellido paterno nulo"; END IF;
    IF vdcampo3 IS NULL THEN LET vdcampo3 = "NO PROPORCIONADO"; END IF;
    IF vdcampo4 IS NULL THEN LET vdcampo4 = ""; LET vcomentario = TRIM(vcomentario)||" Sin nombre"; END IF;
    IF vdcampo5 IS NULL THEN LET vdcampo5 = ""; END IF;
    IF vdcampo6 IS NULL THEN LET vdcampo6 = ""; END IF;
    IF vdcampo7 IS NULL THEN LET vdcampo7 = ""; END IF;
    IF vdcampo9 IS NULL THEN LET vdcampo9 = ""; END IF;
    IF vdcampo10 IS NULL THEN LET vdcampo10 = ""; END IF;
    IF vdcampo11 IS NULL THEN LET vdcampo11 = ""; END IF;
    IF vdcampo12 IS NULL THEN LET vdcampo12 = "0"; END IF;
    LET vexiste = LENGTH(vdcampo2);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vdcampo2[1,1]="~" OR vdcampo2[1,1]=" " OR vdcampo2[1,1]="." OR
		vdcampo2[1,1]="-"  THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vdcampo2[1,1];
				END IF
				LET vespacio ="";
			ELSE
				IF vdcampo2[1,1] = "#" OR vdcampo2[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vdcampo2[1,1];
				END IF
			END IF
		END IF;
		LET vdcampo2 = vdcampo2[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vdcampo2 = TRIM(vquita);
    LET vexiste = LENGTH(vdcampo3);
    --- CAMBIO DE APELLIDO MATERNO
	IF vexiste = 0 THEN
		LET vdcampo3 = "NO PROPORCIONADO";
		LET vexiste = LENGTH(vdcampo3);
	END IF
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vdcampo3[1,1]="~" OR vdcampo3[1,1]=" " OR vdcampo3[1,1]="." OR
		vdcampo3[1,1]="-" THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vdcampo3[1,1];
				END IF
				LET vespacio ="";
			ELSE
				IF vdcampo3[1,1] = "#" OR vdcampo3[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vdcampo3[1,1];
				END IF
			END IF
		END IF;
		LET vdcampo3 = vdcampo3[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vdcampo3 = TRIM(vquita);
    LET vexiste = LENGTH(vdcampo4);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vdcampo4[1,1]="~" OR vdcampo4[1,1]=" "  OR vdcampo4[1,1]="." OR
		vdcampo4[1,1]="-" THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vdcampo4[1,1];
				END IF
				LET vespacio ="";
			ELSE
				IF vdcampo4[1,1] = "#" OR vdcampo4[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vdcampo4[1,1];
				END IF
			END IF
		END IF;
		LET vdcampo4 = vdcampo4[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vdcampo4 = TRIM(vquita);
    LET vexiste = LENGTH(vdcampo5);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio =" ";
    WHILE vexiste1 < vexiste
		IF vdcampo5[1,1]="~" OR vdcampo5[1,1]=" " OR vdcampo5[1,1]="." OR
		vdcampo5[1,1]="-" THEN
			LET vespacio ="F";
		ELSE
			IF vespacio = "F" THEN
				IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vdcampo5[1,1];
				END IF
				LET vespacio ="";
			ELSE
				IF vdcampo5[1,1] = "#" OR vdcampo5[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vdcampo5[1,1];
				END IF
			END IF
		END IF;
		LET vdcampo5 = vdcampo5[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vdcampo5 = TRIM(vquita);
    
	IF vdcampo9 ="P" OR vdcampo9 ="G" THEN
		LET vdcampo9="1";
	ELSE
		IF vdcampo9 ="R" THEN 
			LET vdcampo9="2";
		ELSE
			IF vdcampo9 ="F"  OR vdcampo9 = "H" THEN 
				LET vdcampo9="3";
			ELSE
				LET vdcampo9="";
			END IF
		END IF
	END IF
    IF vdcampo10 ="D" THEN
		LET vdcampo10="D";
	ELSE
		IF vdcampo10 ="U" THEN
			LET vdcampo10="F";
		ELSE
			IF vdcampo10 ="C" THEN
				LET vdcampo10="M";
			ELSE
				IF vdcampo10 ="S" THEN
					LET vdcampo10="S";
				ELSE
					IF vdcampo10 ="V" THEN
						LET vdcampo10="W";
					END IF
				END IF
			END IF
		END IF
	END IF
	
    IF vscampo2 IS NULL THEN LET vscampo2 = "";  LET vcomentario = TRIM(vcomentario)||" Sin calle "; END IF;
    IF vscampo3 IS NULL THEN LET vscampo3 = ""; END IF;
    IF vscampo4 IS NULL THEN LET vscampo4 = ""; END IF;
    IF vscampo5 IS NULL THEN LET vscampo5 = ""; END IF;
    IF vscampo6 IS NULL THEN LET vscampo6 = ""; LET vcomentario = TRIM(vcomentario)||" Sin localidad "; END IF;
    IF vscampo7 IS NULL THEN LET vscampo7 = ""; LET vcomentario = TRIM(vcomentario)||" Sin estado "; END IF;
    IF vscampo8 IS NULL THEN LET vscampo8 = ""; LET vcomentario = TRIM(vcomentario)||" Sin codigo postal "; END IF;
    IF vscampo9 IS NULL THEN LET vscampo9 = ""; END IF;
	
	LET vscampo2 = TRIM(vscampo2)||" "||TRIM(vscampo3);
	LET vexiste = LENGTH(vscampo2);
	IF vexiste < 26 THEN
		LET vscampo3 = "";
        IF vmanzana > 0 THEN
			LET vscampo3 ="mza "||vmanzana;
        END IF
        IF vandador > 0 THEN
			LET vscampo3 =TRIM(vscampo3)||"AND "||vandador;
        END IF
        IF vlote > 0 THEN
			LET vscampo3 =TRIM(vscampo3)||"lt "||vlote;
        END IF
		IF vedificio > 0 THEN
			LET vscampo3 =TRIM(vscampo3)||"ed "||vedificio;
        END IF
        IF ventrada > 0 THEN
			LET vscampo3 =TRIM(vscampo3)||"ent "||ventrada;
        END IF
		LET vscampo2 = TRIM(vscampo2)||' '||TRIM(vscampo3);
    END IF
    LET vscampo2 = TRIM(vscampo2);
    LET vexiste = LENGTH(vscampo2);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
	WHILE vexiste1 < vexiste
		IF vscampo2[1,1]="~" OR vscampo2[1,1]=" " OR vscampo2[1,1]="." OR
        vscampo2[1,1]="-" THEN
			LET vespacio = "F";
        ELSE
			IF vespacio = "F" THEN
				IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vscampo2[1,1];
				END IF
				LET vespacio = "";
			ELSE
				IF vscampo2[1,1] = "#" OR vscampo2[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vscampo2[1,1];
				END IF
			END IF
        END IF;
        LET vscampo2 = vscampo2[2,26];
        LET vexiste1 = vexiste1 + 1;
    END WHILE;
	LET vscampo2 = TRIM(vquita);
	IF vscampo9 ="1" THEN
		LET vscampo9="H";
	ELSE
		IF vscampo9 ="2" THEN
			LET vscampo9="B";
		ELSE
			LET vscampo9="H";
		END IF
	END IF
	
    LET vregistro=TRIM(vregistro)||vdcampo1;
    LET vlen=LENGTH(vdcampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||vpos||vdcampo2;
    LET vlen=LENGTH(vdcampo3);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"00"||vpos||vdcampo3;
    LET vlen=LENGTH(vdcampo4);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"02"||vpos||vdcampo4;
    LET vlen=LENGTH(vdcampo5);
    LET vpos=LPAD(vlen,2,"0");
    IF vlen  > 0 THEN
		LET vregistro=TRIM(vregistro)||"03"||vpos||vdcampo5;
    END IF
	
    LET vlen=LENGTH(vdcampo6);
    IF vlen  > 0 THEN
		--LET vdia=vdcampo6[4,5]; --IPCB
		LET vdia=vdcampo6[1,2];
		LET vdia=LPAD(vdia,2,"0");
		--LET vmes=vdcampo6[1,2]; --IPCB
		LET vmes=vdcampo6[4,5];
		LET vmes=LPAD(vmes,2,"0");
		LET vanio=vdcampo6[7,10];
		LET vdcampo6=vdia||vmes||vanio;
		LET vlen=LENGTH(vdcampo6);
		LET vpos=LPAD(vlen,2,"0");
		LET vregistro=TRIM(vregistro)||"04"||vpos||vdcampo6;
    END IF;
    LET vlen=LENGTH(vdcampo7);
    IF vlen  > 0 THEN
		LET vpos=LPAD(vlen,2,"0");
		LET vregistro=TRIM(vregistro)||"05"||vpos||vdcampo7;
    END IF;
    LET vlen=LENGTH(vdcampo8);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro=TRIM(vregistro)||"08"||vpos||vdcampo8;
	--- Este es el campo correspondiente a la residencia
    IF vdcampo9 = "1" OR vdcampo9 = "2" OR vdcampo9 = "3" THEN
		LET vlen=LENGTH(vdcampo9);
		LET vpos=LPAD(vlen,2,"0");
		LET vregistro=TRIM(vregistro)||"09"||vpos||vdcampo9;
    END IF
    LET vlen =LENGTH(vdcampo10);
    IF vlen  > 0 THEN
		LET vpos=LPAD(vlen,2,"0");
		LET vregistro=TRIM(vregistro)||"11"||vpos||vdcampo10;
    END IF
    LET vlen=LENGTH(vdcampo11);
    IF vlen  > 0 THEN
		LET vpos=LPAD(vlen,2,"0");
		LET vregistro=TRIM(vregistro)||"12"||vpos||vdcampo11;
    END IF
    IF TRIM(vdcampo12) != "0" THEN
		IF LENGTH(TRIM(vdcampo12)) < 2 THEN
			LET vdcampo12 = "0"||TRIM(vdcampo12);
		END IF
		LET vlen=LENGTH(vdcampo12);
		LET vpos=LPAD(vlen,2,"0");
		LET vregistro=TRIM(vregistro)||"17"||vpos||vdcampo12;
    ELSE
		LET vregistro=TRIM(vregistro)||"170201";
    END IF
    LET vregistro=TRIM(vregistro)||vscampo1;
    LET vlen=LENGTH(vscampo2);
    LET vpos=LPAD(vlen,2,"0");
    LET vregistro1=vpos||vscampo2;
    LET vscampo3 = "";
    LET vexiste = LENGTH(vscampo3);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vscampo3[1,1]="~" OR vscampo3[1,1]=" " OR vscampo3[1,1]="." OR
		vscampo3[1,1]="-" THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vscampo3[1,1];
				END IF
				LET vespacio = "";
			ELSE
				IF vscampo3[1,1] = "#" OR vscampo3[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vscampo3[1,1];
				END IF
			END IF
		END IF;
		LET vscampo3 = vscampo3[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo3 = TRIM(vquita);
    LET vlen=LENGTH(vscampo3);
    LET vpos=LPAD(vlen,2,"0");
    --LET vregistro1='00'||vpos|| vscampo3;
    LET vexiste = LENGTH(vscampo4);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vscampo4[1,1]="~" OR vscampo4[1,1]=" " OR vscampo4[1,1]="." OR
		vscampo4[1,1]="-" THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||" "||vscampo4[1,1];
				END IF
				LET vespacio = "";
			ELSE
				IF vscampo4[1,1] = "#" OR vscampo4[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vscampo4[1,1];
				END IF
			END IF
		END IF;
		LET vscampo4 = vscampo4[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo4= TRIM(vquita);
    LET vlen=LENGTH(vscampo4);
    LET vpos= LPAD(vlen,2,"0");
    IF vlen > 0 THEN
		LET vregistro1= TRIM(vregistro1)||"01"||vpos|| vscampo4;
    END IF
{   LET vexiste = LENGTH(vscampo5);
	LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vscampo5[1,1]="~" OR vscampo5[1,1]=" " OR vscampo5[1,1]="." THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â? ";
					LET vespacio = "";
				ELSE
					LET vquita = TRIM(vquita)||" "||vscampo5[1,1];
					LET vespacio = "";
				END IF
			ELSE
				IF vscampo5[1,1] = "#" OR vscampo5[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vscmpo5[1,1];
				END IF
			END IF
		END IF;
		LET vscampo5 = vscampo5[2,26];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo5 = TRIM(vquita);
    LET vlen= LENGTH(vscampo5);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||'02'||vpos||vscampo5;
}
    LET vexiste = LENGTH(vscampo6);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vscampo6[1,1]="~" OR vscampo6[1,1]=" " OR vscampo6[1,1]="." OR
		vscampo6[1,1]="-" THEN
			LET vespacio = "F";
			LET vexiste1 = vexiste1 + 1;
			LET vscampo6 = vscampo6[2,26];
		ELSE
			IF vespacio = "F" THEN
				IF vscampo6[1,22] = "MUNICIPIO DE ( OTROS )" THEN
					LET vquita = TRIM(vquita);
					LET vexiste1 = vexiste1 + 22;
					LET vscampo6 = vscampo6[23,26];
				ELSE
					IF vscampo6[1,12] = "MUNICIPIO DE"  THEN
						LET vquita = TRIM(vquita);
						LET vexiste1 = vexiste1 + 12;
						LET vscampo6 = vscampo6[13,26];
					ELSE
						IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Ã?Â?Ã?Â¥" THEN
							LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
						ELSE
							LET vquita = TRIM(vquita)||" "||vscampo6[1,1];
						END IF
						LET vespacio = "";
						LET vexiste1 = vexiste1 + 1;
						LET vscampo6 = vscampo6[2,26];
					END IF;
				END IF;
			ELSE
				IF vscampo6[1,1] = "#" OR vscampo6[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||"Ã?Â?Ã?Â?";
				ELSE
					LET vquita = TRIM(vquita)||vscampo6[1,1];
				END IF
				LET vexiste1 = vexiste1 + 1;
				LET vscampo6 = vscampo6[2,26];
			END IF
		END IF;
    END WHILE;
    LET vscampo6 = TRIM(vquita);
    LET vlen= LENGTH(vscampo6);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro1= TRIM(vregistro1)||"03"||vpos||vscampo6;
    LET vexiste = LENGTH(vscampo7);
    LET vexiste1 = 0;
    LET vquita = "";
    LET vespacio = " ";
    WHILE vexiste1 < vexiste
		IF vscampo7[1,1]="~" OR vscampo7[1,1]=" " OR vscampo7[1,1]="." OR
		vscampo7[1,1]="-" THEN
			LET vespacio = "F";
		ELSE
			IF vespacio = "F" THEN
				IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||" Ã?Â?Ã?Â?";
					LET vespacio = "";
				ELSE
					LET vquita = TRIM(vquita)||" "||vscampo7[1,1];
					LET vespacio = "";
				END IF
			ELSE
				IF vscampo7[1,1] = "#" OR vscampo7[1,1] = "Ã?Â?Ã?Â¥" THEN
					LET vquita = TRIM(vquita)||vscampo7[1,1];
				ELSE
					LET vquita = TRIM(vquita)||vscampo7[1,1];
				END IF
			END IF
		END IF;
		LET vscampo7 = vscampo7[2,4];
		LET vexiste1 = vexiste1 + 1;
    END WHILE;
    LET vscampo7 = TRIM(vquita);
    LET vlen= LENGTH(vscampo7);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro1= TRIM(vregistro1)||"04"||vpos||vscampo7;
{   IF vscampo8[1,1] = 1 OR vscampo8[1,1] = 2 OR vscampo8[1,1] = 3 OR vscampo8[1,1] = 4 OR vscampo8[1,1] = 5 OR vscampo8[1,1] = 6 OR
    vscampo8[1,1] = 7 OR vscampo8[1,1] = 8 OR vscampo8[1,1] = 9  THEN
		LET vscampo8a = vscampo8[1,1] * 10000;
    ELSE
		LET vscampo8a = 0;
    END IF
    IF vscampo8[2,2] = 1 OR vscampo8[2,2] = 2 OR vscampo8[2,2] = 3 OR vscampo8[2,2] = 4 OR vscampo8[2,2] = 5 OR vscampo8[2,2] = 6 OR
    vscampo8[2,2] = 7 OR vscampo8[2,2] = 8 OR vscampo8[2,2] = 9  THEN
		LET vscampo8a = vscampo8a + vscampo8[2,2] * 1000;
    ELSE
		LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[3,3] = 1 OR vscampo8[3,3] = 2 OR vscampo8[3,3] = 3 OR vscampo8[3,3] = 4 OR vscampo8[3,3] = 5 OR vscampo8[3,3] = 6 OR
    vscampo8[3,3] = 7 OR vscampo8[3,3] = 8 OR vscampo8[3,3] = 9  THEN
		LET vscampo8a = vscampo8a + vscampo8[3,3] * 100;
    ELSE
		LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[4,4] = 1 OR vscampo8[4,4] = 2 OR vscampo8[4,4] = 3 OR vscampo8[4,4] = 4 OR vscampo8[4,4] = 5 OR vscampo8[4,4] = 6 OR
    vscampo8[4,4] = 7 OR vscampo8[4,4] = 8 OR vscampo8[4,4] = 9  THEN
		LET vscampo8a = vscampo8a + vscampo8[4,4] * 10;
    ELSE
		LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8[5,5] = 1 OR vscampo8[5,5] = 2 OR vscampo8[5,5] = 3 OR vscampo8[5,5] = 4 OR vscampo8[5,5] = 5 OR vscampo8[5,5] = 6 OR
    vscampo8[5,5] = 7 OR vscampo8[5,5] = 8 OR vscampo8[5,5] = 9  THEN
		LET vscampo8a = vscampo8a + vscampo8[5,5] ;
    ELSE
		LET vscampo8a = vscampo8a + 0;
    END IF
    IF vscampo8a < vcodini OR vscampo8a > vcodfin THEN
		LET vscampo8 = LPAD(round(vcodini),5,"0");
    END IF }
    LET vlen= LENGTH(vscampo8);
    LET vpos= LPAD(vlen,2,"0");
    LET vregistro2='05'||vpos||vscampo8;
    LET vlen= LENGTH(vscampo9);
    LET vpos= LPAD(vlen,2,'0');
    LET vregistro2=TRIM(vregistro2)||'10'||vpos||vscampo9;
    -- Marca el FIN de Trailer -->
	LET vlen= LENGTH(vregistro)+LENGTH(vregistro1)+LENGTH(vregistro2);
	LET vlen= TRUNC(vlen + 15);
	LET vpo1= LPAD(vlen,5,'0');
	LET vregistro2=TRIM(vregistro2)||'ES05'||vpo1||'0002**';
	
	IF LENGTH(NVL(vcomentario,"")) = 0 THEN
		INSERT INTO "informix".br_traslado(institucion,numcte,num_solicitud,envio,envio1,envio2,status,fecha_insert)
		VALUES(status_2,pFolio,pFolio,vregistro,vregistro1,vregistro2,0,vfecha);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET vcodret = '001'; --LA INSERCION NO SE REALIZO
		END IF;
	ELSE
		LET vcodret = '001'; --LA INSERCION NO SE REALIZO
	END IF;
	
	LET vexiste1 = 0;
	LET vexiste = 10;
	
	RETURN vcodret;
	
END;
END PROCEDURE
DOCUMENT
' Autor: TASF SA DE CV - Lucrecia Montserrat Leon Amador' ,
' Modificacion: Se realiza clonacion de SPL burocred_test para la generacion de trama de envio' ,
' Fecha de modificacion: 31-07-2020' ,
' Proyecto: Servicio de autenticacion de circulo de credito' ;

CREATE PROCEDURE "informix".sp_chi_cre_layout_sics()
    RETURNING CHAR(5) as codigo_retorno;

--  CONTROL DE CAMBIOS
	-------------------------------------------------------------------------------------
	-- Creado por: Gutberto Gomez Guadarrama
	-- Fecha de creacion: 23/04/2021
	-- Peticion: 
	-- Modificado por: 
	-- Fecha de modificaciÃ³n: 
	-- ModificaciÃ³n: 
	-- BD: 
	-- ID Rational
	-------------------------------------------------------------------------------------
	-- Peticion: RQM 10 1404 - Hipotecario Infonavit
	-- Modificado por: Miguel Alejandro SÃ¡nchez Mojica
	-- Fecha de modificaciÃ³n: 14/11/2021
	-- ModificaciÃ³n: Se agrega depuraciÃ³n de tablas en las ejecuciones para evitar registros duplicados, cambio en nomenclatura de archivo de BurÃ³ y CÃ­rculo, generaciÃ³n del archivo para CÃ­rculo de CrÃ©dito y archivo de cifras
	-- BD: bdiburo
	-- ID Rational: 54486
	-------------------------------------------------------------------------------------
	-- Peticion: RQI 28 291 - Hipotecario Infonavit - Cambio en generaciÃ³n de cinta de buro, producto Mejoravit
	-- Modificado por: Miguel Alejandro SÃ¡nchez Mojica
	-- Fecha de modificaciÃ³n: 27/01/2022
	-- ModificaciÃ³n: Se complementa la generaciÃ³n de las cintas y se consideran solo los crÃ©ditos de Mejoravit
	-- BD: bdiburo
	-- ID Rational: 55313
	-------------------------------------------------------------------------------------
	-- Peticion: RQI 28 297 - Hipotecario Infonavit - Complemento Cinta de BurÃ³ ( MOP y Clave de observaciÃ³n)
	-- Modificado por: Arturo HernÃ¡ndez GarcÃ­a
	-- Fecha de modificaciÃ³n: 24/02/2022
	-- ModificaciÃ³n: Se complementa la generaciÃ³n de las cintas con los campos MOP y clave de observaciÃ³n
	-- BD: bdiburo
	-- ID Rational: 56017
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-- Peticion: RQI 28 302 - Hipotecario Infonavit - ModificaciÃ³n Cinta de BurÃ³ (Campo Colonia segmento PA y PE)
	-- Modificado por: Arturo HernÃ¡ndez GarcÃ­a
	-- Fecha de modificaciÃ³n: 08/03/2022
	-- ModificaciÃ³n: Se realiza modificaciÃ³n para considerar los parÃ©ntesis en el campo de colonia
	-- BD: bdiburo
	-- ID Rational: 56248
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-- Peticion: INC 28 320 -Hipotecario Infonavit - Error en campo Fecha Cierre segmento TL
	-- Modificado por: Arturo HernÃ¡ndez GarcÃ­a
	-- Fecha de modificaciÃ³n: 26/05/2022
	-- ModificaciÃ³n: Se realiza ajuste a la validaciÃ³n de longitud del campo fecha cierre
	-- BD: bdiburo
	-- ID Rational: 58650
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-- Peticion: INC 28 350 - Error en proceso de generaciÃ³n de Cintas Hipotecario
	-- Modificado por: Juan Carlos Martinez Olivares
	-- Fecha de modificaciÃ³n: 31/10/2022
	-- ModificaciÃ³n: Se realiza modificaciÃ³n para utilizar fecha correcta para validaciÃ³n 
	-- BD: bdiburo
	-- ID Rational: 63136
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Peticion: INC 28 350 - Error en proceso de generaciÃ³n de Cintas Hipotecario
	-- Modificado por: Juan Carlos Martinez Olivares
	-- Fecha de modificaciÃ³n: 10/11/2022
	-- ModificaciÃ³n: Se realiza modificaciÃ³n para utilizar fecha correcta para validaciÃ³n 
	-- BD: bdiburo
	-- ID Rational: 63136
	-------------------------------------------------------------------------------------
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES ERROR                        *
-- ****************************************************************************
    DEFINE     	sql_err                 	INTEGER;
    DEFINE     	isam_err                	INTEGER;
    DEFINE     	error_info              	CHAR(40);
    DEFINE     	cod_ret                 	CHAR(6);
	DEFINE	   	mensaje_ret					VARCHAR(255);
    DEFINE     	cod_ret_aux             	CHAR(6);
	DEFINE	   	mensaje_ret_aux				VARCHAR(255);
-- ****************************************************************************
-- *                     DEFINICION DE VARIABLES RUTAS                        *
-- ****************************************************************************
	DEFINE		vsql						CHAR(1500);
	DEFINE 		cRuta				    	CHAR(100);
	DEFINE 		cRutaCintas			    	CHAR(100);
	DEFINE 		cRutaCifras			    	CHAR(100);
	DEFINE 		cSQL                    	CHAR(1000);
	DEFINE 		cNomSQL                 	CHAR(100);
	DEFINE 		cDia						CHAR(2);
	DEFINE 		cMes						CHAR(2);
	DEFINE 		cYear				    	CHAR(4);
	DEFINE 		cDiaRep						CHAR(2);
	DEFINE 		cMesRep						CHAR(2);
	DEFINE 		cYearRep				    CHAR(4);
	DEFINE 		cFechaActual				DATE;
	DEFINE 		cArchivoLay			    	CHAR(100);
	DEFINE 		cArchivoRep			    	CHAR(100);
	DEFINE 		cArchivoRep2		    	CHAR(100);
	DEFINE 		cArchivoCifras		    	CHAR(100);
	DEFINE 		cNombreArchivo		    	CHAR(100);
	DEFINE 		cNombreBuro		    		CHAR(100);
	DEFINE 		cNombreCirculo		    	CHAR(100);
	DEFINE 		cNombreCifras		    	CHAR(100);
	DEFINE		v_total_registros			DECIMAL(9,0);
	DEFINE 		v_pass_buro		    		CHAR(200);
	DEFINE 		v_pass_cinta		    	CHAR(200);
	DEFINE		v_tl_num_credito			VARCHAR(20);
	DEFINE		v_ap_paterno				VARCHAR(50);
	DEFINE		v_ap_materno				VARCHAR(50);
	DEFINE		v_nombres					VARCHAR(80);
	DEFINE		v_fecha_nac					VARCHAR(10);
	DEFINE		v_rfc						VARCHAR(13);
	DEFINE		v_num_credito				VARCHAR(20);
	DEFINE		v_ind_listas_negras			VARCHAR(1);
	DEFINE		v_intf_eti_segmento			VARCHAR(4);
	DEFINE		v_intf_version				VARCHAR(2);
	DEFINE		v_intf_clave_usuario		VARCHAR(10);
	DEFINE		v_intf_nombre_usuario		VARCHAR(16);
	DEFINE		v_inft_reservado1			VARCHAR(2);
	DEFINE		v_intf_fecha_reporte		VARCHAR(8);
	DEFINE		v_intf_reservado2			VARCHAR(10);
	DEFINE		v_intf_info_adicional		VARCHAR(98);
	DEFINE		v_pn_num_credito 			VARCHAR(20);
	DEFINE		v_pn_apell_paterno 			VARCHAR(26);
	DEFINE		v_pn_apell_materno 			VARCHAR(26);
	DEFINE		v_pn_nombre1 				VARCHAR(26);
	DEFINE		v_pn_nombre2 				VARCHAR(26);
	DEFINE		v_pn_fecha_nac 				VARCHAR(8);
	DEFINE		v_pn_rfc 					VARCHAR(13);
	DEFINE		v_pn_nacionalidad 			VARCHAR(2);
	DEFINE		v_pn_estado_civil 			VARCHAR(1);
	DEFINE		v_pn_sexo 					VARCHAR(1);
	DEFINE		v_pa_calle 					VARCHAR(40);
	DEFINE		v_pa_colonia 				VARCHAR(40);
	DEFINE		v_pa_delegacion 			VARCHAR(40);
	DEFINE		v_pa_ciudad 				VARCHAR(40);
	DEFINE		v_pa_estado 				VARCHAR(4);
	DEFINE		v_pa_cod_postal 			VARCHAR(5);
	DEFINE		v_pa_num_tel_empleo 		VARCHAR(11);
	DEFINE		v_pa_origen_dom 			VARCHAR(2);
	DEFINE		v_pe_razon_social 			VARCHAR(99);
	DEFINE		v_pe_calle_pe 				VARCHAR(40);
	DEFINE		v_pe_colonia_pe 			VARCHAR(40);
	DEFINE		v_pe_delegacion_pe 			VARCHAR(40);
	DEFINE		v_pe_ciudad_pe 				VARCHAR(40);
	DEFINE		v_pe_estado_pe 				VARCHAR(4);
	DEFINE		v_pe_cod_postal_pe			VARCHAR(5);
	DEFINE		v_pe_num_tel_empleo 		VARCHAR(11);
	DEFINE		v_pe_origen_razon_soc 		VARCHAR(2);
	DEFINE		v_tl_responsabilidad 		VARCHAR(1);
	DEFINE		v_tl_tipo_cuenta 			VARCHAR(1);
	DEFINE		v_tl_tipo_producto 			VARCHAR(2);
	DEFINE		v_tl_clave_monetaria 		VARCHAR(2);
	DEFINE		v_tl_num_pagos 				DECIMAL(4,0);
	DEFINE		v_tl_frecpago 				VARCHAR(10);
	DEFINE		v_tl_monto_pagar 			DECIMAL(9,0);
	DEFINE		v_tl_fecha_apertura 		VARCHAR(8);
	DEFINE		v_tl_fecha_ult_pago 		VARCHAR(8);
	DEFINE		v_tl_fecha_ult_compra 		VARCHAR(8);
	DEFINE		v_tl_fecha_cierre 			VARCHAR(8);
	DEFINE		v_tl_fecha_reporte 			VARCHAR(8);
	DEFINE		v_tl_garantia 				VARCHAR(40);
	DEFINE		v_tl_credito_maximo 		DECIMAL(9,0);
	DEFINE		v_tl_saldo_actual 			DECIMAL(10,0);
	DEFINE		v_tl_saldo_venc 			DECIMAL(9,0);
	DEFINE		v_tl_cuotas_ven 			VARCHAR(4);
	DEFINE		v_tl_fecha_incumplimiento 	VARCHAR(8);
	DEFINE		v_tl_int_calculo 			DECIMAL(9,0);
	DEFINE		v_tl_monto_insoluto 		DECIMAL(10,0);
	DEFINE		v_tl_ultimo_pago 			DECIMAL(9,0);
	DEFINE		v_tl_plazo_meses 			DECIMAL(6,0);
	DEFINE		v_tl_monto_originacion 		DECIMAL(9,0);
	DEFINE		v_tl_correo_electronico		VARCHAR(99);
	DEFINE		v_tl_correo_longitud		INTEGER;
	DEFINE		v_tl_mop					VARCHAR(2);
	DEFINE      v_tl_clave_observacion      VARCHAR(2);
	DEFINE      v_tl_clave_ult_observacion      VARCHAR(2);
	DEFINE		v_trlr_etiqueta_segmento 		VARCHAR(4);
	DEFINE		v_trlr_total_saldos_actuales 	DECIMAL(14,0);
	DEFINE		v_trlr_total_saldos_vencidos 	DECIMAL(14,0);
	DEFINE		v_trlr_total_segmentos_intf 	DECIMAL(3,0);
	DEFINE		v_trlr_total_segmentos_pn 		DECIMAL(9,0);
	DEFINE		v_trlr_total_segmentos_pa 		DECIMAL(9,0);
	DEFINE		v_trlr_total_segmentos_pe 		DECIMAL(9,0);
	DEFINE		v_trlr_total_segmentos_tl 		DECIMAL(9,0);
	DEFINE		v_trlr_contador_bloques 		DECIMAL(6,0);
	DEFINE		v_trlr_usaurio_dev 				VARCHAR(16);
	DEFINE		v_trlr_direccion_usuario_dev 	VARCHAR(160);
	DEFINE		v_trlr_segmento_tr 				VARCHAR(4);
					
    DEFINE     	v_id_segmento             	VARCHAR(4);
    DEFINE     	v_counter               	INTEGER;
	DEFINE		v_counter_cb	         	INTEGER;
	DEFINE		v_concat_seg				VARCHAR(255);
-- ****************************************************************************
-- *                INICIALIZACION DE VARIABLES ERRORES                       *
-- ****************************************************************************
	LET 		sql_err      			= 0;
	LET 		isam_err     			= 0;
    LET 	   	cod_ret 				= '00000'; 
	LET 	   	mensaje_ret 			= 'PROCESO EXITOSO';
    LET 	   	cod_ret_aux 			= '00000'; 
	LET 	   	mensaje_ret_aux 		= '';
	LET			v_counter				= 0;
	LET			v_counter_cb	        = 0;
	LET			v_concat_seg			= '';
	LET 		v_tl_correo_longitud	= 0;
	
	LET			v_trlr_total_saldos_actuales 	= 0;
	LET			v_trlr_total_saldos_vencidos 	= 0;
	LET			v_trlr_total_segmentos_intf 	= 0;
	LET			v_trlr_total_segmentos_pn 		= 0;
	LET			v_trlr_total_segmentos_pa 		= 0;
	LET			v_trlr_total_segmentos_pe 		= 0;
	LET			v_trlr_total_segmentos_tl 		= 0;
	LET			v_trlr_contador_bloques 		= 0;
	LET			v_trlr_usaurio_dev 				='';
	LET			v_trlr_direccion_usuario_dev 	='';
	LET			v_trlr_segmento_tr 				='';
-- ****************************************************************************
-- *                  INICIALIZACION DE VARIABLES RUTAS                       *
-- ****************************************************************************
	LET 		cRuta		 			= "/resplogifx/hipotecario_infonavit/sics/";
	LET 		cRutaCintas		 		= "/RESPALDOSNEW/hipotecario_infonavit/sics/";
	LET 		cRutaCifras		 		= "/RESPALDOSNEW/hipotecario_infonavit/sics/cifras/";
	LET 		cSQL					= "";
	LET 		cNomSQL					= "sd_temp_chi_cre_layout_sics.sql";
	LET 		cDia					= LPAD(DAY(DATE(1)), 2, '0');
	LET 		cMes					= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		cYear					= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		cDiaRep					= LPAD(DAY(DATE(1)), 2, '0');
	LET 		cMesRep					= LPAD(MONTH(DATE(1)), 2, '0');
	LET 		cYearRep				= LPAD(YEAR(DATE(1)), 4, '0');
	LET 		cArchivoLay				= "chi_cre_layout_sics_";
	LET 		cArchivoRep				= "cinta_buroCH";
	LET 		cArchivoRep2			= "cinta_circuloCH";
	LET 		cArchivoCifras			= "chi_cre_cifras_buro_";
	LET			cNombreArchivo			= "";
	LET			cNombreBuro				= "";
	LET			cNombreCirculo			= "";
	LET			cNombreCifras			= "";
	
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '11111';
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO, CODIGO RETORNO 11111';

				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;	
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic;		
				TRUNCATE TABLE bdiburo:"informix".br_chi_burofisicas;	
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_intf;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pn;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pa;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pe;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tl;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tr;
							
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668) SET sql_err, isam_err
			IF sql_err != 0 THEN
			
				LET cod_ret = '22222';		
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO, EXISTEN VALORES DUPLICADOS. CODIGO RETORNO 22222';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;	
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic;		
				TRUNCATE TABLE bdiburo:"informix".br_chi_burofisicas;	
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_intf;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pn;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pa;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pe;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tl;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tr;
					
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-1207) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '33333';		
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO. CODIGO RETORNO 33333';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;	
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic;		
				TRUNCATE TABLE bdiburo:"informix".br_chi_burofisicas;	
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_intf;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pn;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pa;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pe;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tl;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tr;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-268) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '44444';		
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO. CODIGO RETORNO 44444';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;	
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic;		
				TRUNCATE TABLE bdiburo:"informix".br_chi_burofisicas;	
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_intf;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pn;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pa;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pe;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tl;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tr;
				
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		ON EXCEPTION IN (-691) SET sql_err, isam_err
			IF sql_err != 0 THEN
				LET cod_ret = '55555';		
				LET mensaje_ret = 'NO SE PUEDE PROCESAR EL ARCHIVO. CODIGO RETORNO 55555';
				
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;	
				DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic;			
				TRUNCATE TABLE bdiburo:"informix".br_chi_burofisicas;	
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_intf;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pn;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pa;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pe;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tl;
				TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tr;
								
				RETURN cod_ret;
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
        --*****************************************************************
        --*						Debug del Procedure                     --*        
        --*****************************************************************
--		/*SET DEBUG FILE TO '/resplogifx/hipotecario_infonavit/sics/sp_chi_cre_layout_sics.out';
--  	TRACE ON;  */                                                
		
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************	

-- ****************************************************************************
-- *                      SE OBTIENE FECHA DE PROCESO                         *
-- ****************************************************************************	
		SELECT LPAD(YEAR(fecha_hoy), 4, '0') INTO cYear FROM bdicred:sd_fechas WHERE empresa = '001';
		SELECT LPAD(MONTH(fecha_hoy), 2, '0') INTO cMes FROM bdicred:sd_fechas WHERE empresa = '001';
		SELECT LPAD(DAY(fecha_hoy), 2, '0') INTO cDia FROM bdicred:sd_fechas WHERE empresa = '001';	
		
		-- Fecha Actual
		LET cFechaActual = mdy(cMes, cDia, cYear);
	
-- ****************************************************************************
-- *                SE OBTIENE FECHA QUE DEBE MOSTRAR LOS ARCHIVOS            *
-- ****************************************************************************	
		-- Calcular mes y aÃ±o anterior
		-- SI el mes actual es 01 (ENERO) asignar en automatico el mes 12 y restar un aÃ±o al aÃ±o actual, si NO, restar un mes al mes actual
		IF (cMes = 1) THEN
			
			LET cMesRep = '12';
			LET cYearRep = YEAR(cFechaActual) - 1;
			
		ELSE
		
			LET cMesRep = LPAD(MONTH(cFechaActual)-1, 2, '0');
			LET cYearRep = YEAR(cFechaActual);
			
		END IF;
		
		-- Obtener la utima fecha del mes anterior
		LET cDiaRep = DAY(LAST_DAY(mdy(cMesRep,01,cYearRep)));
		
		LET cNombreBuro = TRIM(cArchivoRep) || cDiaRep || cMesRep || cYearRep || '.txt ';
		LET cNombreCirculo = TRIM(cArchivoRep2) || cDiaRep || cMesRep || cYearRep || '.txt ';
		LET cNombreCifras = TRIM(cArchivoCifras) || cDiaRep || cMesRep || cYearRep || '.txt ';

-- ****************************************************************************
-- *                          PASE A HISTORICO                                *
-- ****************************************************************************
		INSERT INTO bdicred:"informix".sd_chi_cre_layout_sic_paso_hist 
		SELECT CURRENT::datetime year to second,* FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;
		
		INSERT INTO bdicred:"informix".sd_chi_cre_layout_sic_hist 
		SELECT * FROM bdicred:"informix".sd_chi_cre_layout_sic;
	
		INSERT INTO  bdiburo:br_chi_bc_seg_intf_hist		
		SELECT * FROM bdiburo:br_chi_bc_seg_intf ;
		
		INSERT INTO  bdiburo:br_chi_bc_seg_pn_hist		
		SELECT * FROM bdiburo:br_chi_bc_seg_pn ;
		
		INSERT INTO bdiburo:br_chi_bc_seg_pa_hist
		SELECT * FROM bdiburo:br_chi_bc_seg_pa ;
		
		INSERT INTO bdiburo:br_chi_bc_seg_pe_hist
		SELECT * FROM bdiburo:br_chi_bc_seg_pe ;
		
		INSERT INTO bdiburo:br_chi_bc_seg_tl_hist
		SELECT * FROM bdiburo:br_chi_bc_seg_tl ;
		
		INSERT INTO  bdiburo:br_chi_bc_seg_tr_hist		
		SELECT * FROM bdiburo:br_chi_bc_seg_tr ;
			
-- ****************************************************************************
-- *                     ELIMINAR REGISTROS ACTUALES                          *
-- *                        ELIMINAR TABLA DE PASO                            *
-- ****************************************************************************
			
		DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic_paso;	
		DELETE FROM bdicred:"informix".sd_chi_cre_layout_sic;		
		TRUNCATE TABLE bdiburo:"informix".br_chi_burofisicas;	
		TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_intf;
		TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pn;
		TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pa;
		TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_pe;
		TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tl;
		TRUNCATE TABLE bdiburo:"informix".br_chi_bc_seg_tr;
	
-- ****************************************************************************
-- *               IMPORTACION DE ARCHIVO A TABLA DE PASO                     *
-- ****************************************************************************	
			
		LET cNombreArchivo = TRIM(cArchivoLay) || cYear || cMes || cDia || '.txt ';
		LET cSQL = ' echo "SET ISOLATION TO DIRTY READ; SET LOCK MODE TO WAIT 3; LOAD FROM ' || TRIM(cRuta) || TRIM(cNombreArchivo) || 
			' INSERT INTO bdicred:"informix".sd_chi_cre_layout_sic_paso;' || "" || '">'||TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM TRIM(cSQL);
	
		LET cSQL='chmod 777 '|| TRIM(cRuta)|| TRIM(cNomSQL);
		SYSTEM cSQL;
	
		LET cSQL = 'dbaccess bdicred ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
		
		LET cSQL = 'rm ' || TRIM(cRuta) || TRIM(cNomSQL);
		SYSTEM cSQL;
	
-- ****************************************************************************
-- *                            CREAR SEGMENTO INTF                           *
-- ****************************************************************************	
		select upper(valor) into v_intf_eti_segmento
		from bdiburo:"informix".br_param
		where cod_param = 3;
	
		select upper(valor) into v_intf_version
		from bdiburo:"informix".br_param
		where cod_param = 4;
		
		select upper(valor) into v_intf_clave_usuario
		from bdiburo:"informix".br_param
		where cod_param = 1;	LET  v_intf_clave_usuario = 'BM30560001'; 
		
		select upper(valor) into v_intf_nombre_usuario
		from bdiburo:"informix".br_param
		where cod_param = 6;
		LET v_intf_nombre_usuario = 'BANCOPPEL'; 
		
		LET v_inft_reservado1 = '&&';
		
		LET v_intf_fecha_reporte = cDiaRep || cMesRep || cYearRep;
		
		LET v_intf_reservado2 = '0000000000';
		
		LET v_intf_info_adicional = '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&';
		
		LET v_intf_nombre_usuario = RPAD(v_intf_nombre_usuario,16,' ');
	
/*
   select upper(valor) into vciclo
      from bdiburo:"informix".br_param
      where cod_param = 7;

   select upper(valor) into vuso_futuro
      from bdiburo:"informix".br_param
      where cod_param = 8;

   select upper(valor) into vclave_usu_bc
      from bdiburo:"informix".br_param
      where cod_param = 127;
*/	  
	
		LET v_id_segmento = 'INTF';		
		LET v_trlr_total_segmentos_intf = v_trlr_total_segmentos_intf +1;
			INSERT INTO bdiburo:"informix".br_chi_bc_seg_intf VALUES
			(
				v_intf_eti_segmento,
				v_intf_version,
				v_intf_clave_usuario,
				v_intf_nombre_usuario,
				v_inft_reservado1,
				v_intf_fecha_reporte,
				v_intf_reservado2,
				v_intf_info_adicional,
				CURRENT::datetime year to second
			);	
			--- insertar en tabla de cinta
			LET v_counter_cb = v_counter_cb + 1;
			LET v_concat_seg = 
				v_intf_eti_segmento||
				TRIM(v_intf_version)||
				v_intf_clave_usuario||
				v_intf_nombre_usuario||
				v_inft_reservado1||
				v_intf_fecha_reporte||
				v_intf_reservado2||
				v_intf_info_adicional;
			INSERT INTO bdiburo:"informix".br_chi_burofisicas VALUES (v_counter_cb,v_concat_seg);

-- ****************************************************************************
-- *                    PASE A TABLA DE PROCESO ACTUAL                        *
-- ****************************************************************************	

		FOREACH WITH HOLD
			SELECT  	A.tl_num_credito, B.apell_paterno, B.apell_materno, B.nombre1, B.nombre2, 
						A.pn_fecha_nac, A.pn_rfc, A.pn_nacionalidad, A.pn_estado_civil, A.pn_sexo, 
						A.pa_calle, A.pa_colonia, A.pa_delegacion, A.pa_ciudad, A.pa_estado,
						A.pa_cod_postal, A.pa_num_tel_empleo, A.pa_origen_dom, A.pe_razon_social, A.pe_calle_pe, 
						A.pe_colonia_pe, A.pe_delegacion_pe, A.pe_ciudad_pe, A.pe_estado_pe, A.pe_cod_postal_pe, 
						A.pe_num_tel_empleo, A.pe_origen_razon_soc, A.tl_responsabilidad, A.tl_tipo_cuenta, 'HI', 
						A.tl_clave_monetaria, A.tl_num_pagos, A.tl_frecpago, A.tl_monto_pagar, A.tl_fecha_apertura, 
						A.tl_fecha_ult_pago, A.tl_fecha_ult_compra, A.tl_fecha_cierre, A.tl_fecha_reporte, A.tl_garantia, 
						A.tl_credito_maximo, A.tl_saldo_actual, A.tl_saldo_venc, A.tl_cuotas_ven, A.tl_fecha_incumplimiento, 
						A.tl_int_calculo, A.tl_monto_insoluto, A.tl_ultimo_pago, A.tl_plazo_meses, A.tl_monto_originacion, 
						A.tl_correo_electronico,nvl(D.tl_clave_observacion,'')
			INTO  		v_tl_num_credito, v_pn_apell_paterno, v_pn_apell_materno, v_pn_nombre1, v_pn_nombre2,
						v_pn_fecha_nac, v_pn_rfc, v_pn_nacionalidad, v_pn_estado_civil, v_pn_sexo,
						v_pa_calle, v_pa_colonia, v_pa_delegacion, v_pa_ciudad, v_pa_estado,
						v_pa_cod_postal, v_pa_num_tel_empleo, v_pa_origen_dom, v_pe_razon_social, v_pe_calle_pe,
						v_pe_colonia_pe, v_pe_delegacion_pe, v_pe_ciudad_pe, v_pe_estado_pe, v_pe_cod_postal_pe,
						v_pe_num_tel_empleo, v_pe_origen_razon_soc, v_tl_responsabilidad , v_tl_tipo_cuenta, v_tl_tipo_producto,
						v_tl_clave_monetaria, v_tl_num_pagos, v_tl_frecpago, v_tl_monto_pagar, v_tl_fecha_apertura,
						v_tl_fecha_ult_pago, v_tl_fecha_ult_compra, v_tl_fecha_cierre, v_tl_fecha_reporte, v_tl_garantia,
						v_tl_credito_maximo, v_tl_saldo_actual, v_tl_saldo_venc, v_tl_cuotas_ven, v_tl_fecha_incumplimiento,
						v_tl_int_calculo, v_tl_monto_insoluto, v_tl_ultimo_pago, v_tl_plazo_meses, v_tl_monto_originacion,
						v_tl_correo_electronico,v_tl_clave_ult_observacion
			FROM 		bdicred:"informix".sd_chi_cre_layout_sic_paso A
			INNER JOIN	bdicred:"informix".sd_chi_cre_carga_consic_hist B 
			ON A.tl_num_credito = B.num_credito 
			AND B.producto = 'MV'
			LEFT JOIN (
			    SELECT tl_num_credito,MAX(fecha_carga_sist)AS fecha_ult_proc_buro
			    FROM bdiburo:"informix".br_chi_bc_seg_tl_hist
                GROUP BY tl_num_credito
			) C
			ON A.tl_num_credito = C.tl_num_credito
			LEFT JOIN bdiburo:"informix".br_chi_bc_seg_tl_hist D
			ON C.tl_num_credito = D.tl_num_credito
			AND C.fecha_ult_proc_buro = D.fecha_carga_sist
			
			LET v_pn_apell_paterno    = UPPER(v_pn_apell_paterno);
			LET v_pn_apell_materno    = UPPER(v_pn_apell_materno);
			LET v_pn_nombre1          = UPPER(v_pn_nombre1);
			LET v_pn_nombre2          = UPPER(v_pn_nombre2);
			LET v_pn_nacionalidad     = UPPER(v_pn_nacionalidad);
			LET v_pn_estado_civil     = UPPER(v_pn_estado_civil);
			LET v_pn_sexo             = UPPER(v_pn_sexo);
			LET v_pa_calle            = UPPER(v_pa_calle);
			LET v_pa_colonia          = UPPER(v_pa_colonia);
			LET v_pa_delegacion       = UPPER(v_pa_delegacion);
			LET v_pa_ciudad           = UPPER(v_pa_ciudad);
			LET v_pa_estado           = UPPER(v_pa_estado);
			LET v_pe_razon_social     = UPPER(v_pe_razon_social);
			LET v_pe_calle_pe         = UPPER(v_pe_calle_pe);
			LET v_pe_colonia_pe       = UPPER(v_pe_colonia_pe);
			LET v_pe_delegacion_pe    = UPPER(v_pe_delegacion_pe);
			LET v_pe_ciudad_pe        = UPPER(v_pe_ciudad_pe);
			LET v_pe_estado_pe        = UPPER(v_pe_estado_pe);
			LET v_pe_origen_razon_soc = UPPER(v_pe_origen_razon_soc);
						
			IF(TRIM(v_tl_frecpago) IN('ROA','EXT')) THEN
			
				LET v_tl_frecpago = 'B';
			
			ELIF (TRIM(v_tl_frecpago) = 'REA') THEN
			
				LET v_tl_frecpago = 'M';
				
			END IF;
			
			IF TRIM(v_tl_cuotas_ven) = 0
			    THEN LET v_tl_mop = '01';
			    
			ELIF TRIM(v_tl_cuotas_ven) = '1'
			    THEN LET v_tl_mop = '02';
			    
			ELIF TRIM(v_tl_cuotas_ven) = '2'
			    THEN LET v_tl_mop = '03';
            
            ELIF TRIM(v_tl_cuotas_ven) = '3'
			    THEN LET v_tl_mop = '04';
			    
            ELIF TRIM(v_tl_cuotas_ven) = '4'
			    THEN LET v_tl_mop = '05';
			    
            ELIF TRIM(v_tl_cuotas_ven) = '5'
			    THEN LET v_tl_mop = '06';
			    
            ELIF (TRIM(v_tl_cuotas_ven) IN('6','7','8','9','10','11','12'))
                THEN LET v_tl_mop = '07';
            
            ELIF (CAST(TRIM(v_tl_cuotas_ven) AS NUMERIC) > 12)
                THEN LET v_tl_mop = '96';
			
			----pendiente 97
			
            END IF;
            
            LET v_tl_clave_observacion = '';
            
            IF (nvl(v_tl_saldo_actual,0) = 0 
                AND nvl(v_tl_saldo_venc,0) = 0 
                AND TRIM(v_tl_mop) = '01' 
                AND nvl(v_tl_monto_pagar,0) = 0
                AND TRIM(v_tl_fecha_cierre) <> '00000000'
                )
                THEN LET v_tl_clave_observacion = 'CC';
                
			ELIF (nvl(v_tl_saldo_actual,0) > 0 
                AND nvl(v_tl_saldo_venc,0) > 0 
                AND TRIM(v_tl_mop) IN('02','03','04','05','06','07','96') 
                AND nvl(v_tl_monto_pagar,0) > 0
                AND TRIM(v_tl_fecha_cierre) = '00000000' 
                )
                THEN LET v_tl_clave_observacion = 'PC';
                
            ELIF (TRIM(v_tl_mop) = '01' AND TRIM(v_tl_clave_ult_observacion) = 'PC') 
                THEN LET v_tl_clave_observacion = 'EL';
                
            ELIF TRIM(v_tl_mop) = '01'
			    THEN LET v_tl_clave_observacion = '';
			      
			END IF;
			--Se valida si ya existe el registro en la tabla del dÃ­a			
			SELECT COUNT (*) into v_counter
			FROM bdicred:"informix".sd_chi_cre_layout_sic
			WHERE tl_num_credito = v_tl_num_credito;
				
			IF v_counter > 0 THEN 
				---- SE INSERTA INFORMACION EN TABLAS DE ERROR POR DUPLICADOS
	
				INSERT INTO bdicred:"informix".sd_chi_cre_layout_sic_err VALUES
				(
					v_tl_num_credito,
					v_pn_apell_paterno,
					v_pn_apell_materno,
					v_pn_nombre1,
					v_pn_nombre2,
					v_pn_fecha_nac,
					v_pn_rfc,
					v_pn_nacionalidad,
					v_pn_estado_civil,
					v_pn_sexo,
					v_pa_calle,
					v_pa_colonia,
					v_pa_delegacion,
					v_pa_ciudad,
					v_pa_estado,
					v_pa_cod_postal,
					v_pa_num_tel_empleo,
					v_pa_origen_dom,
					v_pe_razon_social,
					v_pe_calle_pe,
					v_pe_colonia_pe,
					v_pe_delegacion_pe,
					v_pe_ciudad_pe,
					v_pe_estado_pe,
					v_pe_cod_postal_pe,
					v_pe_num_tel_empleo,
					v_pe_origen_razon_soc,
					v_tl_responsabilidad ,
					v_tl_tipo_cuenta,
					v_tl_tipo_producto,
					v_tl_clave_monetaria,
					v_tl_num_pagos,
					v_tl_frecpago,
					v_tl_monto_pagar,
					v_tl_fecha_apertura,
					v_tl_fecha_ult_pago,
					v_tl_fecha_ult_compra,
					v_tl_fecha_cierre,
					v_tl_fecha_reporte,
					v_tl_garantia,
					v_tl_credito_maximo,
					v_tl_saldo_actual,
					v_tl_saldo_venc,
					v_tl_cuotas_ven,
					v_tl_fecha_incumplimiento,
					v_tl_int_calculo,
					v_tl_monto_insoluto,
					v_tl_ultimo_pago,
					v_tl_plazo_meses,
					v_tl_monto_originacion,
					v_tl_correo_electronico,
					CURRENT::datetime year to second
				);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_pn_err VALUES
				(
					
					v_tl_num_credito,
					v_pn_apell_paterno,
					v_pn_apell_materno,
					v_pn_nombre1,
					v_pn_nombre2,
					v_pn_fecha_nac,
					v_pn_rfc,
					v_pn_nacionalidad,
					v_pn_estado_civil,
					v_pn_sexo,
					CURRENT::datetime year to second
				);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_pa_err VALUES
				(
					v_tl_num_credito,
					v_pa_calle,
					v_pa_colonia,
					v_pa_delegacion,
					v_pa_ciudad,
					v_pa_estado,
					v_pa_cod_postal,
					v_pa_num_tel_empleo,
					v_pa_origen_dom,
					CURRENT::datetime year to second
				);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_pe_err VALUES
				(
					v_tl_num_credito,
					v_pe_razon_social,
					v_pe_calle_pe,
					v_pe_colonia_pe,
					v_pe_delegacion_pe,
					v_pe_ciudad_pe,
					v_pe_estado_pe,
					v_pe_cod_postal_pe,
					v_pe_num_tel_empleo,
					v_pe_origen_razon_soc,
					CURRENT::datetime year to second
				);
						
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_tl_err VALUES
				(
					v_tl_num_credito,
					v_tl_responsabilidad ,
					v_tl_tipo_cuenta,
					v_tl_tipo_producto,
					v_tl_clave_monetaria,
					v_tl_num_pagos,
					v_tl_frecpago,
					v_tl_monto_pagar,
					v_tl_fecha_apertura,
					v_tl_fecha_ult_pago,
					v_tl_fecha_ult_compra,
					v_tl_fecha_cierre,
					v_tl_fecha_reporte,
					v_tl_garantia,
					v_tl_credito_maximo,
					v_tl_saldo_actual,
					v_tl_saldo_venc,
					v_tl_cuotas_ven,
					v_tl_fecha_incumplimiento,
					v_tl_int_calculo,
					v_tl_monto_insoluto,
					v_tl_ultimo_pago,
					v_tl_plazo_meses,
					v_tl_monto_originacion,
					v_tl_correo_electronico,
					CURRENT::datetime year to second,
					v_tl_mop,
	                v_tl_clave_observacion
				);

			ELSE
				INSERT INTO bdicred:"informix".sd_chi_cre_layout_sic VALUES
				(
					v_tl_num_credito,
					v_pn_apell_paterno,
					v_pn_apell_materno,
					v_pn_nombre1,
					v_pn_nombre2,
					v_pn_fecha_nac,
					v_pn_rfc,
					v_pn_nacionalidad,
					v_pn_estado_civil,
					v_pn_sexo,
					v_pa_calle,
					v_pa_colonia,
					v_pa_delegacion,
					v_pa_ciudad,
					v_pa_estado,
					v_pa_cod_postal,
					v_pa_num_tel_empleo,
					v_pa_origen_dom,
					v_pe_razon_social,
					v_pe_calle_pe,
					v_pe_colonia_pe,
					v_pe_delegacion_pe,
					v_pe_ciudad_pe,
					v_pe_estado_pe,
					v_pe_cod_postal_pe,
					v_pe_num_tel_empleo,
					v_pe_origen_razon_soc,
					v_tl_responsabilidad ,
					v_tl_tipo_cuenta,
					v_tl_tipo_producto,
					v_tl_clave_monetaria,
					v_tl_num_pagos,
					v_tl_frecpago,
					v_tl_monto_pagar,
					v_tl_fecha_apertura,
					v_tl_fecha_ult_pago,
					v_tl_fecha_ult_compra,
					v_tl_fecha_cierre,
					v_tl_fecha_reporte,
					v_tl_garantia,
					v_tl_credito_maximo,
					v_tl_saldo_actual,
					v_tl_saldo_venc,
					v_tl_cuotas_ven,
					v_tl_fecha_incumplimiento,
					v_tl_int_calculo,
					v_tl_monto_insoluto,
					v_tl_ultimo_pago,
					v_tl_plazo_meses,
					v_tl_monto_originacion,
					v_tl_correo_electronico,
					CURRENT::datetime year to second
				);
					
				LET v_id_segmento = 'PN';		
				
				 --- insertar en tabla de cinta
				
				IF v_pn_apell_materno IS NULL OR v_pn_apell_materno = '' THEN 
					LET v_pn_apell_materno = 'NO PROPORCIONADO';
				END IF;
				
				LET v_trlr_total_segmentos_pn = v_trlr_total_segmentos_pn + 1;
				LET v_counter_cb = v_counter_cb + 1;
				LET v_pn_apell_paterno = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pn_apell_paterno,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'Ã','#');
				LET v_pn_apell_materno = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pn_apell_materno,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'Ã','#');
				LET v_pn_nombre1 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pn_nombre1,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'Ã','#');
				LET v_pn_nombre2 = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pn_nombre2,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'Ã','#');
				LET v_concat_seg = 
					TRIM(v_id_segmento)||lpad(length(TRIM(v_pn_apell_paterno)),2,"0")||TRIM(v_pn_apell_paterno)||
					'00'||lpad(length(TRIM(v_pn_apell_materno)),2,"0")||TRIM(v_pn_apell_materno)||
					'02'||lpad(length(TRIM(v_pn_nombre1)),2,"0")||TRIM(v_pn_nombre1);
					
				IF v_pn_nombre2 IS NULL OR v_pn_nombre2 = '' THEN 
					LET v_pn_nombre2 = '00';
					LET v_concat_seg =	v_concat_seg ||	'03'||TRIM(v_pn_nombre2);
				ELSE
					LET v_concat_seg =	v_concat_seg ||	'03'||lpad(length(TRIM(v_pn_nombre2)),2,"0")||TRIM(v_pn_nombre2);
				END IF;
				
				LET v_concat_seg =	v_concat_seg ||
					'04'||lpad(length(TRIM(v_pn_fecha_nac)),2,"0")||TRIM(v_pn_fecha_nac)||
					'05'||lpad(length(TRIM(v_pn_rfc)),2,"0")||TRIM(v_pn_rfc)||
					'08'||lpad(length(TRIM(v_pn_nacionalidad)),2,"0")||TRIM(v_pn_nacionalidad)||
					'11'||lpad(length(TRIM(v_pn_estado_civil)),2,"0")||TRIM(v_pn_estado_civil)||
					'12'||lpad(length(TRIM(v_pn_sexo)),2,"0")||TRIM(v_pn_sexo);
					
				INSERT INTO bdiburo:"informix".br_chi_burofisicas VALUES (v_counter_cb,v_concat_seg);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_pn VALUES
				(
					v_tl_num_credito,
					v_pn_apell_paterno,
					v_pn_apell_materno,
					v_pn_nombre1,
					v_pn_nombre2,
					v_pn_fecha_nac,
					v_pn_rfc,
					v_pn_nacionalidad,
					v_pn_estado_civil,
					v_pn_sexo,
					CURRENT::datetime year to second
				);
				-----------------------------------------------------------------------------------------------------------------------
				LET v_id_segmento = 'PA';			
				
				 --- insertar en tabla de cinta
				LET v_trlr_total_segmentos_pa = v_trlr_total_segmentos_pa + 1;
				LET v_counter_cb = v_counter_cb + 1;
				--LET v_pa_calle = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pa_calle,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pa_calle = 'DOMICILIO CONOCIDO SN';
				--LET v_pa_colonia = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pa_colonia,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pa_colonia = REPLACE(REPLACE(REPLACE(REPLACE(v_pa_colonia,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A');
				LET v_pa_delegacion = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pa_delegacion,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pa_ciudad = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pa_ciudad,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pa_cod_postal = lpad(v_pa_cod_postal,5,"0");
				LET v_concat_seg =
					TRIM(v_id_segmento)||lpad(length(TRIM(v_pa_calle)),2,"0")||TRIM(v_pa_calle)||
					'01'||lpad(length(TRIM(v_pa_colonia)),2,"0")||TRIM(v_pa_colonia)||
					'02'||lpad(length(TRIM(v_pa_delegacion)),2,"0")||TRIM(v_pa_delegacion)||
					'03'||lpad(length(TRIM(v_pa_ciudad)),2,"0")||TRIM(v_pa_ciudad)||
					'04'||lpad(length(TRIM(v_pa_estado)),2,"0")||TRIM(v_pa_estado)||
					'05'||lpad(length(TRIM(v_pa_cod_postal)),2,"0")||TRIM(v_pa_cod_postal)||
					--'07'||lpad(length(TRIM(v_pa_num_tel_empleo)),2,"0")||TRIM(v_pa_num_tel_empleo)||
					'12'||lpad(length(TRIM(v_pa_origen_dom)),2,"0")||TRIM(v_pa_origen_dom);

				INSERT INTO bdiburo:"informix".br_chi_burofisicas VALUES (v_counter_cb,v_concat_seg);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_pa VALUES
				(
					v_tl_num_credito,
					v_pa_calle,
					v_pa_colonia,
					v_pa_delegacion,
					v_pa_ciudad,
					v_pa_estado,
					v_pa_cod_postal,
					v_pa_num_tel_empleo,
					v_pa_origen_dom,
					CURRENT::datetime year to second
				);
				-----------------------------------------------------------------------------------------------------------------------
				LET v_id_segmento = 'PE';								
				
				 --- insertar en tabla de cinta 
				LET v_trlr_total_segmentos_pe = v_trlr_total_segmentos_pe + 1;
				LET v_counter_cb = v_counter_cb + 1;
				LET v_pe_razon_social = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pe_razon_social,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				--LET v_pe_calle_pe = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pe_calle_pe,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pe_calle_pe = 'DOMICILIO CONOCIDO SN';
				--LET v_pe_colonia_pe = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pe_colonia_pe,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pe_colonia_pe = REPLACE(REPLACE(REPLACE(REPLACE(v_pe_colonia_pe,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A');
				LET v_pe_delegacion_pe = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pe_delegacion_pe,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pe_ciudad_pe = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(v_pe_ciudad_pe,'Ã','A'),'Â¥','I'),'Â©','E'),'Ã','A'),'(',''),')','');
				LET v_pe_cod_postal_pe = lpad(v_pe_cod_postal_pe,5,"0");
				LET v_concat_seg =
					TRIM(v_id_segmento)||lpad(length(TRIM(v_pe_razon_social)),2,"0")||TRIM(v_pe_razon_social)||
					'00'||lpad(length(TRIM(v_pe_calle_pe)),2,"0")||TRIM(v_pe_calle_pe)||
					'02'||lpad(length(TRIM(v_pe_colonia_pe)),2,"0")||TRIM(v_pe_colonia_pe)||
					'03'||lpad(length(TRIM(v_pe_delegacion_pe)),2,"0")||TRIM(v_pe_delegacion_pe)||
					'04'||lpad(length(TRIM(v_pe_ciudad_pe)),2,"0")||TRIM(v_pe_ciudad_pe)||
					'05'||lpad(length(TRIM(v_pe_estado_pe)),2,"0")||TRIM(v_pe_estado_pe)||
					'06'||lpad(length(TRIM(v_pe_cod_postal_pe)),2,"0")||TRIM(v_pe_cod_postal_pe)||
					--'07'||lpad(length(TRIM(v_pe_num_tel_empleo)),2,"0")||TRIM(v_pe_num_tel_empleo)||
					'18'||lpad(length(TRIM(v_pe_origen_razon_soc)),2,"0")||TRIM(v_pe_origen_razon_soc);

				INSERT INTO bdiburo:"informix".br_chi_burofisicas VALUES (v_counter_cb,v_concat_seg);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_pe VALUES
				(
					v_tl_num_credito,
					v_pe_razon_social,
					v_pe_calle_pe,
					v_pe_colonia_pe,
					v_pe_delegacion_pe,
					v_pe_ciudad_pe,
					v_pe_estado_pe,
					v_pe_cod_postal_pe,
					v_pe_num_tel_empleo,
					v_pe_origen_razon_soc,
					CURRENT::datetime year to second
				);
				-----------------------------------------------------------------------------------------------------------------------
				LET v_id_segmento = 'TL';									
				
				 --- insertar en tabla de cinta
				LET v_trlr_total_saldos_actuales = v_trlr_total_saldos_actuales + v_tl_saldo_actual;
				LET v_trlr_total_saldos_vencidos = v_trlr_total_saldos_vencidos + v_tl_saldo_venc;
				LET v_trlr_total_segmentos_tl =  v_trlr_total_segmentos_tl + 1;
				LET v_counter_cb = v_counter_cb + 1;
				LET v_tl_correo_longitud = length(TRIM(v_tl_correo_electronico)) - 1;
								
				LET v_concat_seg = 
					TRIM(v_id_segmento)||
					'02TL'||
					'01'||lpad(length(TRIM(v_intf_clave_usuario)),2,"0")||TRIM(v_intf_clave_usuario)||
					'02'||lpad(length(TRIM(v_intf_nombre_usuario)),2,"0")||TRIM(v_intf_nombre_usuario)||
					'04'||lpad(length(TRIM(v_tl_num_credito)),2,"0")||TRIM(v_tl_num_credito)||
					'05'||lpad(length(TRIM(v_tl_responsabilidad)),2,"0")||TRIM(v_tl_responsabilidad)||
					'06'||lpad(length(TRIM(v_tl_tipo_cuenta)),2,"0")||TRIM(v_tl_tipo_cuenta)||
					'07'||lpad(length(TRIM(v_tl_tipo_producto)),2,"0")||TRIM(v_tl_tipo_producto)||
					'08'||lpad(length(TRIM(v_tl_clave_monetaria)),2,"0")||TRIM(v_tl_clave_monetaria)||
					'10'||lpad(length(CAST(v_tl_num_pagos as char(4))),2,"0")||TRIM(CAST(v_tl_num_pagos as char(4)))||
					'11'||lpad(length(TRIM(v_tl_frecpago)),2,"0")||TRIM(v_tl_frecpago)||
					'12'||lpad(length(CAST(v_tl_monto_pagar as char(9))),2,"0")||TRIM(CAST(v_tl_monto_pagar as char(9)))||
					'13'||lpad(length(TRIM(v_tl_fecha_apertura)),2,"0")||TRIM(v_tl_fecha_apertura);
				
				IF(TRIM(v_tl_fecha_ult_pago) = '01011900') THEN
					
					LET v_tl_fecha_ult_pago = '00';
					LET v_concat_seg =	v_concat_seg || '14'||TRIM(v_tl_fecha_ult_pago);
					
				ELSE
				
					LET v_concat_seg =	v_concat_seg || '14'||lpad(length(TRIM(v_tl_fecha_ult_pago)),2,"0")||TRIM(v_tl_fecha_ult_pago);
				
				END IF;
				
				IF(TRIM(v_tl_fecha_ult_compra) = '01011900' AND TRIM(v_tl_fecha_ult_pago) = '00') THEN
				
					LET v_tl_fecha_ult_compra = '00';
					LET v_concat_seg =	v_concat_seg || '15'||TRIM(v_tl_fecha_ult_compra);
					
				ELSE
				
					LET v_concat_seg =	v_concat_seg || '15'||lpad(length(TRIM(v_tl_fecha_ult_compra)),2,"0")||TRIM(v_tl_fecha_ult_compra);
					
				END IF;
					
				IF (TRIM(v_tl_fecha_cierre) <> '00000000') THEN
				
					LET v_concat_seg =	v_concat_seg ||'16'||lpad(length(TRIM(v_tl_fecha_cierre)),2,"0")||TRIM(v_tl_fecha_cierre);
				
				END IF;
				
				LET v_concat_seg =	v_concat_seg ||
					'17'||lpad(length(TRIM(v_tl_fecha_reporte)),2,"0")||TRIM(v_tl_fecha_reporte)||
					'20'||lpad(length(TRIM(v_tl_garantia)),2,"0")||TRIM(v_tl_garantia)||
					'21'||lpad(length(CAST(v_tl_credito_maximo as char(9))),2,"0")||TRIM(CAST(v_tl_credito_maximo as char(9)))||
					'22'||lpad(length(CAST(v_tl_saldo_actual as char(10))),2,"0")||TRIM(CAST(v_tl_saldo_actual as char(10)))||
					'2300'||
					'24'||lpad(length(CAST(v_tl_saldo_venc as char(9))),2,"0")||TRIM(CAST(v_tl_saldo_venc as char(9)))||
					'25'||lpad(length(TRIM(v_tl_cuotas_ven)),2,"0")||TRIM(v_tl_cuotas_ven)||
					'26'||lpad(length(TRIM(v_tl_mop)),2,"0")||TRIM(v_tl_mop);
					
					IF (TRIM(nvl(v_tl_clave_observacion,'')) <> '')
					    THEN LET v_concat_seg =	v_concat_seg || 
					    '30'||lpad(length(TRIM(v_tl_clave_observacion)),2,"0")||TRIM(v_tl_clave_observacion);
				    END IF;
				    
                LET v_concat_seg =	v_concat_seg ||
					'43'||lpad(length(TRIM(v_tl_fecha_incumplimiento)),2,"0")||TRIM(v_tl_fecha_incumplimiento)||
					'44'||lpad(length(CAST(v_tl_monto_insoluto as char(9))),2,"0")||TRIM(CAST(v_tl_monto_insoluto as char(9)))||
					'45'||lpad(length(CAST(v_tl_ultimo_pago as char(10))),2,"0")||TRIM(CAST(v_tl_ultimo_pago as char(10)))||
					'47'||lpad(length(CAST(v_tl_int_calculo as char(9))),2,"0")||TRIM(CAST(v_tl_int_calculo as char(9)))||
					'50'||lpad(length(CAST(v_tl_plazo_meses as char(6))),2,"0")||TRIM(CAST(v_tl_plazo_meses as char(6)))||
					'51'||lpad(length(CAST(v_tl_monto_originacion as char(9))),2,"0")||TRIM(CAST(v_tl_monto_originacion as char(9)))||
					--'52'||lpad(length(TRIM(v_tl_correo_electronico))-1,2,"0")||substr(TRIM(v_tl_correo_electronico),1,v_tl_correo_longitud)||
					'9903FIN';
					
				INSERT INTO bdiburo:"informix".br_chi_burofisicas VALUES (v_counter_cb,v_concat_seg);
				
				INSERT INTO bdiburo:"informix".br_chi_bc_seg_tl VALUES
				(
					v_tl_num_credito,
					v_tl_responsabilidad,
					v_tl_tipo_cuenta,
					v_tl_tipo_producto,
					v_tl_clave_monetaria,
					v_tl_num_pagos,
					v_tl_frecpago,
					v_tl_monto_pagar,
					v_tl_fecha_apertura,
					v_tl_fecha_ult_pago,
					v_tl_fecha_ult_compra,
					v_tl_fecha_cierre,
					v_tl_fecha_reporte,
					v_tl_garantia,
					v_tl_credito_maximo,
					v_tl_saldo_actual,
					v_tl_saldo_venc,
					v_tl_cuotas_ven,
					v_tl_fecha_incumplimiento,
					v_tl_int_calculo,
					v_tl_monto_insoluto,
					v_tl_ultimo_pago,
					v_tl_plazo_meses,
					v_tl_monto_originacion,
					v_tl_correo_electronico,
					CURRENT::datetime year to second,
					v_tl_mop,
	                v_tl_clave_observacion
				);
					
			END IF;		
		END FOREACH;
	
-- ****************************************************************************
-- *                            CREAR SEGMENTO TRLR                           *
-- ****************************************************************************	
		LET v_id_segmento = 'TRLR';		
		LET v_trlr_etiqueta_segmento = 'TRLR';
		LET v_trlr_usaurio_dev = 'BANCOPPEL       ';
		LET v_trlr_direccion_usuario_dev = 'INSURGENTES SUR 553 PISO 6 COL. ESCANDON C.P. 11800 MEXICO D.F.&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&';
		
		INSERT INTO bdiburo:"informix".br_chi_bc_seg_tr VALUES
		(
			v_trlr_etiqueta_segmento,
			v_trlr_total_saldos_actuales,
			v_trlr_total_saldos_vencidos,
			v_trlr_total_segmentos_intf,
			v_trlr_total_segmentos_pn,
			v_trlr_total_segmentos_pa,
			v_trlr_total_segmentos_pe,
			v_trlr_total_segmentos_tl,
			v_trlr_contador_bloques,
			v_trlr_usaurio_dev,
			v_trlr_direccion_usuario_dev,
			v_trlr_segmento_tr,
			CURRENT::datetime year to second
		);	
		--- insertar en tabla de cinta
		LET v_counter_cb = 0;				
		LET v_concat_seg = 
			v_trlr_etiqueta_segmento||
			lpad(TRIM(CAST(v_trlr_total_saldos_actuales as char(14))),14,"0")||
			lpad(TRIM(CAST(v_trlr_total_saldos_vencidos as char(14))),14,"0")||
			lpad(TRIM(CAST(v_trlr_total_segmentos_intf as char(3))),3,"0")||
			lpad(TRIM(CAST(v_trlr_total_segmentos_pn as char(9))),9,"0")||
			lpad(TRIM(CAST(v_trlr_total_segmentos_pa as char(9))),9,"0")||
			lpad(TRIM(CAST(v_trlr_total_segmentos_pe as char(9))),9,"0")||
			lpad(TRIM(CAST(v_trlr_total_segmentos_tl as char(9))),9,"0")||
			lpad(TRIM(CAST(v_trlr_contador_bloques as char(6))),6,"0")||
			v_trlr_usaurio_dev ||
			v_trlr_direccion_usuario_dev;
			
		INSERT INTO bdiburo:"informix".br_chi_burofisicas VALUES (v_counter_cb,v_concat_seg);
	

-- ****************************************************************************
-- *                            GENERA CINTA                                  *
-- ****************************************************************************	
-- ExtracciÃ³n CÃ­rculo de CrÃ©dito
		let vsql = 'echo " unload to '''|| TRIM(cRutaCintas) || 'xburofis.unl'''||" delimiter '|' "||
					'" > ' || TRIM(cRutaCintas) || 'genburofisXX.sql';
		
		system vsql;
		
		let vsql = 'echo "'||
					' SELECT registro FROM bdiburo:br_chi_burofisicas WHERE  numreg IN(1)' ||
					' union ' ||
					' select case when substr(a.registro,1,2)='||'''TL'''||' and a.registro matches '||'''*3002CV9903FIN'''||' ' ||  
					' THEN  (select registro from bdiburo:br_chi_burofisicas where numreg=a.numreg-3)::lvarchar ||' || 
						  ' (select registro from bdiburo:br_chi_burofisicas where numreg=a.numreg-2)::lvarchar ||' ||
						  ' (select registro from bdiburo:br_chi_burofisicas where numreg=a.numreg-1)::lvarchar||' || 
		                  ' replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||')::lvarchar ' ||  
						  --' replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||''')::lvarchar ' ||  
					 ' ELSE (select registro from bdiburo:br_chi_burofisicas where numreg=a.numreg-3)::lvarchar||' ||
						  ' (select registro from bdiburo:br_chi_burofisicas where numreg=a.numreg-2)::lvarchar||' ||  
						  ' (select registro from bdiburo:br_chi_burofisicas where numreg=a.numreg-1)::lvarchar||' ||  
		                  ' replace(registro,'||'''BC30560001'''||','||'''TGD0924BAN'''||')::lvarchar' ||  
						 --' replace(registro,'''||vclave_usu_bc||''','''||vclave_usu||''')::lvarchar' ||  
					 ' END' ||  
					 ' from bdiburo:br_chi_burofisicas a where substr(a.registro,1,2)='||'''TL'''||' '|| 
					' union ' ||  
					' SELECT registro FROM bdiburo:br_chi_burofisicas WHERE  numreg IN(0);' ||
					' " >> '|| TRIM(cRutaCintas) ||'genburofisXX.sql';
		
		system vsql;
		
		let vsql = 'dbaccess bdiburo '|| TRIM(cRutaCintas) ||'genburofisXX.sql';
		system vsql;
		
		let vsql = "sed 's/&/ /g' "|| TRIM(cRutaCintas) ||"xburofis.unl > "|| TRIM(cRutaCintas) ||"xburofisXX.unl ";
		system vsql;
		
		let vsql = "sed 's/[~]*|//g' "|| TRIM(cRutaCintas) ||"xburofisXX.unl > "|| TRIM(cRutaCintas) ||"xburofisXX2.unl ";
		system vsql;
		
		let vsql = "sed 's/|//g' "|| TRIM(cRutaCintas) ||"xburofisXX2.unl > "|| TRIM(cRutaCintas) ||"xburofisXX.unl ";
		system vsql;
		
		LET vsql = "cat "|| TRIM(cRutaCintas) ||"xburofisXX.unl | tr -d '\n' > "|| TRIM(cRutaCintas) || TRIM(cNombreBuro);
		SYSTEM vsql;
		
		LET vsql = "cat "|| TRIM(cRutaCintas) ||"xburofisXX.unl | tr -d '\n' > "|| TRIM(cRutaCintas) || TRIM(cNombreCirculo);
		SYSTEM vsql;
		
		let vsql = "rm "|| TRIM(cRutaCintas) ||"xburofis.unl "|| TRIM(cRutaCintas) ||"xburofisXX.unl "|| TRIM(cRutaCintas) ||"xburofisXX2.unl";     
		system vsql;

		LET vsql='chmod 777 '|| TRIM(cRutaCintas) || TRIM(cNombreBuro);
		SYSTEM vsql;
				
		LET vsql='chmod 777 '|| TRIM(cRutaCintas) || TRIM(cNombreCirculo);
		SYSTEM vsql;
		
		let vsql = "gzip "|| TRIM(cRutaCintas) || TRIM(cNombreBuro);
		system vsql;
		
		let vsql = "gzip "|| TRIM(cRutaCintas) || TRIM(cNombreCirculo);
		system vsql;
		
		LET vsql='chmod 777 '|| TRIM(cRutaCintas) || TRIM(cNombreBuro) || ".gz";
		SYSTEM vsql;
				
		LET vsql='chmod 777 '|| TRIM(cRutaCintas) || TRIM(cNombreCirculo) || ".gz";
		SYSTEM vsql;		

-- ****************************************************************************
-- *                       GENERACION DE REPORTE                              *
-- ****************************************************************************	
		
		SELECT 	trlr_total_segmentos_pn
		INTO	v_total_registros
		FROM 	bdiburo:"informix".br_chi_bc_seg_tr;
		
		SELECT	llave
		INTO	v_pass_buro
		FROM 	bdinteg:"informix".si_configura_pgp
		WHERE 	codigo = 'BURO_CHI';
		
		SELECT	llave
		INTO	v_pass_cinta
		FROM 	bdinteg:"informix".si_configura_pgp
		WHERE 	codigo = 'CIRCULO_CHI';
		
		-- Imprimir encabezados dentro del reporte (45 columnas)
		LET vsql = 	' echo "SE REPORTAN ' || v_total_registros || ' REGISTROS AL '|| cDiaRep ||'/'||cMesRep||'/'||cYearRep|| 
					', password de acceso al archivo de BurÃ³: '|| TRIM(v_pass_buro) ||' y password de acceso al archivo de CÃ­rculo: '|| TRIM(v_pass_cinta) || '">'||TRIM(cRutaCifras)|| TRIM(cNombreCifras);
		SYSTEM TRIM(vsql);
		
		LET vsql='chmod 777 '||TRIM(cRutaCifras)|| TRIM(cNombreCifras);
		SYSTEM vsql;
		
		let vsql = '';

		RETURN cod_ret;	
    END	
END PROCEDURE;