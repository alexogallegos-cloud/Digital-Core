CREATE PROCEDURE "informix".sp_guardabitacora_colaborapp(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;
 
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsFechaHora DATETIME YEAR TO FRACTION(5);
 
	LET visqlerr = 0;
	LET vssqlerr = '00000';
	LET vsFechaHora = CURRENT;

	BEGIN

		ON EXCEPTION SET visqlerr    

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

			--SET DEBUG FILE TO "/informix/mgap/trace_bita_colaborapp.out";
			--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;


		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_colaborapp (elemento, fecha_hora, actividad, cve_usuario)
		VALUES (psElemento,vsFechaHora,psActividad,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;


	END

END PROCEDURE;