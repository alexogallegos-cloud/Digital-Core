CREATE PROCEDURE "informix".sp_esposibleaplicarpagoendiasemana(pdFechaPropuesta DATE,pDiasSemana CHAR(7) )

RETURNING CHAR(5) AS Retorno;

                                --*************************************************

                                --Creado por: Anselmo Verdugo                   			--*

                                -- Actividad: Genera un valor para indicar si es posible aplicar un pago en un día de la semana especificado.

                                --  Solicitó: Anselmo Verdugo                       			--*

                                --     Fecha: 09/NOV/2008                       			--*

                                --*************************************************



DEFINE vcCodRet CHAR(5);

DEFINE sql_err INTEGER;

DEFINE viEsDiaSemana INTEGER;



		 ON EXCEPTION SET sql_err

            LET vcCodRet = sql_err;

            RETURN vcCodRet;

        END EXCEPTION;





      --  SET DEBUG FILE TO "/home/informix/sp_EsPosibleAplicarPagoEnDiaSemana.out";

      --  TRACE ON;



LET vcCodRet = '00001';

LET viEsDiaSemana = -1;





		LET viEsDiaSemana = WEEKDAY(pdFechaPropuesta);

		-- Si se solicita dias LUNES y el dia de la fechaPropuesta es LUNES entones es factible aplicar pago.

		IF substr(pDiasSemana,1,1) = '1' and viEsDiaSemana = 1 THEN

				RETURN '00000';

		END IF;



		-- Si se solicita dias MARTES y el dia de la fechaPropuesta es MARTES entones es factible aplicar pago.

		IF substr(pDiasSemana,2,1) = '1' and viEsDiaSemana = 2 THEN

				RETURN '00000';

		END IF;

		-- Si se solicita dias MIÉRCOLRES y el dia de la fechaPropuesta es MIÉRCOLES entones es factible aplicar pago.

		IF substr(pDiasSemana,3,1) = '1' and viEsDiaSemana = 3 THEN

				RETURN '00000';

		END IF;



		-- Si se solicita dias JUEVES y el dia de la fechaPropuesta es  JUEVES  entones es factible aplicar pago.

		IF substr(pDiasSemana,4,1) = '1' and viEsDiaSemana = 4 THEN

				RETURN '00000';                                              

		END IF;

		-- Si se solicita dias VIERNES  y el dia de la fechaPropuesta es VIERNES entones es factible aplicar pago.

		IF substr(pDiasSemana,5,1) = '1' and  viEsDiaSemana = 5 THEN

				RETURN '00000';                                              

		END IF;



		-- Si se solicita dias SABDADO  y el dia de la fechaPropuesta es SABADO entones es factible aplicar pago.

		IF substr(pDiasSemana,6,1) = '1' and viEsDiaSemana = 6 THEN

				RETURN '00000';                                              

		END IF;

		-- Si se solicita dias DOMINGO y el dia de la fechaPropuesta es DOMINGO  entones es factible aplicar pago.

		IF substr(pDiasSemana,7,1) = '1' and viEsDiaSemana = 0 THEN

				RETURN '00000';                                             

		END IF;

		

	RETURN vcCodRet;    

		

END PROCEDURE;