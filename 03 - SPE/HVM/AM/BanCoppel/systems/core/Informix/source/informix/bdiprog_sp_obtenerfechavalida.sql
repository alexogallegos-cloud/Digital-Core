CREATE PROCEDURE "informix".sp_obtenerfechavalida(pAnoInicio INTEGER,pMesInicio INTEGER,piDiaEspecifico INTEGER)

RETURNING CHAR(5) as Retorno,DATE as FechaFactible;

                                --*************************************************

                                --Creado por: Anselmo Verdugo                   			--*

                                -- Actividad: Obtiene una fecha valida con respecto al número de días que tiene cada mes.

                                --  Solicitó: Anselmo Verdugo                      			--*

                                --     Fecha: 10/NOV/2008                       			--*

                                --*************************************************



DEFINE vdFechaMovil DATE;

DEFINE vdFechaDisp1 DATE;

DEFINE vcMes CHAR(2);

DEFINE vcAno CHAR(4);

DEFINE viEsBisiesto INTEGER;



LET vdFechaMovil =  pMesInicio || '/01/' || pAnoInicio;

LET vcMes     = '';

LET vcAno     = '';



        --SET DEBUG FILE TO "/home/informix/sp_obtenerFechaMensual.out";

        --TRACE ON;



        IF piDiaEspecifico < 1 or piDiaEspecifico > 31 THEN

            RETURN '00001','/01/01/1900';

        END IF;



    

        

        LET vcMes = LPAD(MONTH(vdFechaMovil),2,'0');

        LET vcAno = YEAR(vdFechaMovil);

    

        --  ENERO    --> 31 dias.

        --  FEBRERO  --> 28 dias, 29 en año bisiesto.

        --  MARZO.   --> 31 dias.

        --  ABRIL.   --> 30 dias.

        --  MAYO.    --> 31 dias.

        -- JUNIO.    --> 30 dias.

        -- JULIO.    --> 31 dias.

        -- AGOSTO.   --> 31 dias.

        -- SEPTIEMBRE.-->30 dias.

        -- OCTUBRE.   --> 31 dias.

        -- NOVIEMBRE. --> 30 dias.

        -- DICIEMBRE. --> 31 dias.



        

        -- MESES DE 31 DIAS.

        IF vcMes = '01' or vcMes = '03' or  vcMes = '05' or vcMes = '07' or vcMes = '08' or vcMes = '10' or vcMes = '12'  THEN

				LET vdFechaDisp1 = vcMes || '/' || piDiaEspecifico || '/' || vcAno;



         ELIF vcMes = '04' or vcMes = '06' or vcMes = '09' or vcMes = '11'   THEN

                        -- TIENE 30 DIAS.

                        IF piDiaEspecifico = 31 THEN

                            LET vdFechaDisp1 = vdFechaMovil + 1 UNITS MONTH;

                        ELSE

                            LET vdFechaDisp1 = vcMes || '/' || piDiaEspecifico || '/' || vcAno ;

                        END IF;



        -- MESES DE 28 DIAS.

        ELIF vcMes = '02'  THEN

				-- TIENE 28 DIAS

                -- SI ES AÑO BISIESTO TIENE 29.

                IF piDiaEspecifico = 31 or piDiaEspecifico = 30 THEN

                   LET vdFechaDisp1 = vdFechaMovil + 1 UNITS MONTH;

                ELIF  piDiaEspecifico = 29 THEN

                    LET viEsBisiesto = MOD(vcAno,4);

                    

                   IF viEsBisiesto = 0 THEN

                       LET vdFechaDisp1 = vcMes || '/' || piDiaEspecifico || '/' || vcAno ;

                    ELSE

                        LET vdFechaDisp1 = vdFechaMovil + 1 UNITS MONTH;

                    END IF;

                    

                ELSE

                    LET vdFechaDisp1 = vcMes || '/' || piDiaEspecifico || '/' || vcAno ;

                END IF;



        END IF;





RETURN '00000',vdFechaDisp1;



END PROCEDURE;