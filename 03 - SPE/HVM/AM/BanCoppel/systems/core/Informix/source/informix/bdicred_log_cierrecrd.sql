CREATE PROCEDURE "informix".log_cierrecrd(vEmpresa CHAR(3),
			    vNumCred CHAR(20),
			    vCodRet  CHAR(5),
			    vFecha   DATE,
			    vDesc    VARCHAR(200,1))
RETURNING SMALLINT;


DEFINE vContador SMALLINT;
DEFINE vParamPara SMALLINT;

	SELECT valor INTO vParamPara
	  FROM sd_param
	 WHERE empresa = vEmpresa
	   AND cod_param ="79";

	INSERT INTO sd_valcierrecrd
	 (empresa, cod_ret, num_credito, secuencia, fecha_proc,
	  desc_err)
	VALUES
	 (vEmpresa, vCodRet, vNumCred, 0, vFecha, vDesc);


	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(*) INTO vContador
	  FROM sd_valcierrecrd
	 WHERE empresa = vEmpresa
	   AND fecha_proc = vFecha;

	IF vContador >= vParamPara THEN
		RETURN vContador;
	ELSE
		LET vContador = 0;
	END IF

	RETURN vContador;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".sp_cal_fecha
					(
					pFecha 		DATE,	-->Fecha  a Calcular
					pTipoSuma 	INT,    -->Tipo para sumar Dia, Mes, Anio
								-->Dia =1, Mes = 2, Anio =3
					pSuma		INT,	-->Cuanto va sumar
				        pUltDiaLab	INT,	-->Ultimo dia laboral L=0,M=1,M=2,J=3,V=4,S=5,D=6
					pDiaHab 	INT 	-->Dia habil anterior=0, o posterior=1
					)

RETURNING CHAR(5),-->Codigo de Retorno
	  DATE ,  -->Fecha de Calculada
	  INT  ,  -->Periodo en que regresara (mes,añio,dias)
	  INT ;   -->Numero de dias Transcurridos

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr          INTEGER;

DEFINE vFechaCalculada	DATE;
DEFINE vPeriodo 	INT;
dEFINE vDiaTras		INT;
DEFINE vUltimoDiaMes    DATE;
DEFINE vDias 		INT;
DEFINE vUltDiaLab       INT;
DEFINE vUltDiaMes	DATE;
DEFINE vAnio		int;


--SET DEBUG FILE TO "sp_cal_fecha.out";
--TRACE ON;

BEGIN

	ON EXCEPTION
	   SET vsqlerr
	   LET vcodret = vsqlerr;

	   RETURN vcodret,--> Codigo de Retorno
	          vFechaCalculada,	-->FechaCaluculada
	          vPeriodo,		-->Fecha regresa
		  vDiaTras;		-->Dias Transcurridos
	END EXCEPTION;

LET vcodret = "00000";
LET vUltDiaLab      = 0;
LET vFechaCalculada = " ";
LET vUltimoDiaMes   = " ";
LET vPeriodo 	    = 0;
LET vDiaTras	    = 0;
LET vDias           = 0;
let pFecha          = pFecha;
Let vAnio 	    = 0;

--Calculo por dia =1

	IF pTipoSuma = '1' THEN

		LET	vFechaCalculada = MONTH(pFecha)||"/"||DAY(pFecha)||"/"||YEAR(pFecha);
		LET	vFechaCalculada = vFechaCalculada + pSuma UNITS DAY;
		LET	vPeriodo = 1;
	END IF;

--Calculo por mes =2

	IF pTipoSuma = '2' THEN

	LET	vPeriodo = 2;

	select {+INDEX (sd_fechas idx_sdfechas)} ult_dia_mes
	into vUltDiaMes
	from sd_fechas where empresa='001';


--Fin de Mes
	If pFecha = vUltDiaMes Then
           IF MONTH(pfecha) = 12 THEN
              LET vFechaCalculada  = "01/01/"|| YEAR(pFecha)+1;
           ELSE
              LET vFechaCalculada  = MONTH(pFecha)+1 ||"/01/"|| YEAR(pFecha);
           END IF
	   LET vFechaCalculada = (vFechaCalculada + pSuma UNITS MONTH); ---1 UNITS DAY;
	   LET vFechaCalculada = (vFechaCalculada - 1 UNITS DAY); ---1 UNITS DAY;
--Si es bisiesto
	Else
	        LET vFechaCalculada = MONTH(pFecha) ||"/01/"|| YEAR(pFecha);
        	LET vFechaCalculada = vFechaCalculada + pSuma UNITS MONTH;


        	IF day(pFecha) >= 29 AND MONTH(vFechaCalculada) = 2 THEN
                   IF MOD(YEAR(vFechaCalculada),4) = 0 THEN
              	      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| "29" ||"/"|| YEAR(vFechaCalculada);
                   ELSE
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| "28" ||"/"|| YEAR(vFechaCalculada);
                   END IF
               ELSE
                     LET vUltimoDiaMes = (vFechaCalculada + 1 UNITS MONTH) - 1 UNITS DAY;
                   IF day(pFecha) <= DAY(vUltimoDiaMes) THEN
                     -- LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| day(pFecha) ||"/"|| YEAR(vFechaCalculada);
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| day(vUltimoDiaMes) ||"/"|| YEAR(vFechaCalculada);
                   ELSE
                      LET vFechaCalculada = MONTH(vFechaCalculada) ||"/"|| DAY(vUltimoDiaMes) ||"/"|| YEAR(vFechaCalculada);
                  END IF

             end if;
        END IF;
 END IF;
--Calculo por anio =3

	LET pFecha = pfecha;
	LET psuma = pSuma;

	IF pTipoSuma = '3' THEN
		LET vAnio = YEAR(pFecha) + psuma;
                   IF MOD(vAnio,4) = 0 THEN
              	      LET vFechaCalculada = MONTH(pFecha) ||"/"|| "29" ||"/"|| vAnio;
                   ELSE
                      LET vFechaCalculada = MONTH(pFecha) ||"/"|| "28" ||"/"|| vAnio;
                   END IF
		LET	vPeriodo = 3;
	END IF;

	--****Calculo del dia habil y fecha porsterior o anterior***--
        LET vUltDiaLab = WeekDay(vFechaCalculada);
        IF pUltDiaLab = vUltDiaLab THEN
	   if pDiaHab = 0 then
	--	LET vFechaCalculada = vFechaCalculada - 1 UNITS DAY;
	     Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
	   Else
	     Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
	   end if
	Elif pUltDiaLab < vUltDiaLab and pUltDiaLab <> 0 Then

	    if pDiaHab = 0 then
               LET vFechaCalculada = vFechaCalculada - (vUltDiaLab - pUltDiaLab) UNITS DAY;
               Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
       	    Else
               LET vFechaCalculada = vFechaCalculada + (vUltDiaLab - pUltDiaLab) UNITS DAY;
               Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
       	   end if
	---Si es Domigo - Sabado

	Elif pUltDiaLab > vUltDiaLab and vUltDiaLab = 0 Then
	    if pDiaHab = 0 then

		 if   pUltDiaLab = 5 then
	         	Let vFechaCalculada = (vFechaCalculada - 2 UNITS DAY);
		 end if

		 if pUltDiaLab = 6 then
	   --      	Let vFechaCalculada = (vFechaCalculada -  1 UNITS DAY);
		 end if

                 Call sp_valfechabil(vFechaCalculada,"-") returning vCodret,vFechaCalculada;
            Else

		 if   pUltDiaLab = 5 then
	         	Let vFechaCalculada = (vFechaCalculada +  1 UNITS DAY);
		 end if

		 if pUltDiaLab = 6 then
	--       	Let vFechaCalculada = (vFechaCalculada +  2 UNITS DAY);
		 end if

                 Call sp_valfechabil(vFechaCalculada,"") returning vCodret,vFechaCalculada;
       	   end if
        END IF;

	--Calcula los dias Transcurridos--

      LET     vDiaTras= ( vFechaCalculada - pFecha );

        RETURN
	vcodret,              --> Codigo de Retorno
        vFechaCalculada,      -->FechaCaluculada
        vPeriodo,             -->Fecha regresa
        vDiaTras;             -->Dias Transcurridos


END
END PROCEDURE
;