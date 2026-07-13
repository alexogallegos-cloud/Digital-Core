CREATE PROCEDURE "informix".sp_obtenerocurrenciadia(pcOcurrencia CHAR(2),pcDiaSemana CHAR(2),pdFecha DATE)

RETURNING CHAR(5) as Retorno,DATE as Fecha_Ocurre;

                                --*************************************************

                                --Creado por: Anselmo Verdugo                   			--*

                                -- Actividad: Obtiene la ocurrencia (primero, segundo, tercero ... ultimo) día de un mes dado.

                                --  Solicitó: Anselmo Verdugo                      			--*

                                --     Fecha: 11/NOV/2008                       			--*

                                --*************************************************





DEFINE vcCotRet CHAR(5);

DEFINE I INTEGER;

DEFINE vcEsUltimoDiaMes CHAR(1);

DEFINE vdDiaUltimo DATE;

DEFINE vdFechaElegida DATE;

DEFINE viNumOcurrencia INTEGER;

DEFINE vcFecha DATE;

DEFINE vdOcurreciaFecha DATE;





LET vcCotRet = '00000';

LET I = 0;

LET vcEsUltimoDiaMes = 'N';

LET viNumOcurrencia  = pcOcurrencia::int;

LET vcFecha  = pdFecha;

LET vdOcurreciaFecha = '01/01/1900';



        --SET DEBUG FILE TO "/home/informix/sp_obtenerOcurrenciaDia.out";

       -- TRACE ON;

		

		

            -- se hace transparente los datos de informix con el diseño de tablas. 

            /*if pcOcurrencia = '06' then

		                let pcOcurrencia = '5';

			    end if;

			*/

            if pcDiaSemana = '07' then

                let pcDiaSemana = '00';

            end if;

			--return LPAD(WEEKDAY(pdFecha),2,'0'), '01/01/1900';



			LET vdDiaUltimo = MONTH(pdFecha)  || '/01/' || YEAR(pdFecha);

			LET pdFecha =     vdDiaUltimo;

			

			LET vdDiaUltimo = vdDiaUltimo + 1 UNITS MONTH;

			LET vdDiaUltimo = vdDiaUltimo -1;

			

            WHILE I < viNumOcurrencia and vcEsUltimoDiaMes = 'N'



                IF LPAD(WEEKDAY(pdFecha),2,'0') = pcDiaSemana THEN

                    LET I = I + 1;

					LET vdOcurreciaFecha = pdFecha;

                END IF;

				

				IF vdDiaUltimo = pdFecha THEN

					LET vcEsUltimoDiaMes = 'S';

				END IF;

                

                LET pdFecha = pdFecha + 1;



            END WHILE;

		

			let pdFecha = pdFecha -1;

									-- si la fecha de incio es mayor a la fecha que resulta.

			IF DAY(vcFecha) <> '01' and DAY(vcFecha) > DAY(pdFecha) THEN

				LET vcCotRet = '00001';

			END IF;

			

			-- SI NO SE SOLICITA  EL ULTIMO 

			IF viNumOcurrencia <> 6 THEN

				-- SI NO SE ENCONTRÓ EL NUMERO DE OCURRENCIAS DESEADAS.

	            IF I <> viNumOcurrencia  THEN

					LET vcCotRet = '00001';

				END IF;

			END IF;





	return vcCotRet,vdOcurreciaFecha;

            

END PROCEDURE;