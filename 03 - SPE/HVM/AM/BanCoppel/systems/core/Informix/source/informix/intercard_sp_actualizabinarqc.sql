CREATE PROCEDURE "informix".sp_actualizabinarqc ()
returning char (5),char(100);

--############################################################################################################
--### Creado por: FRG																			  			##
--##  Fecha: 11/Sep/201																			 			##
--##  Descripcion: Se genera SP para actualización masiva del campo intercard:hsmcard.binarqc a los lotes   ##
--##  			  de tarjetas con mal generados por G&D.													##
--##  BD: intercard                                                                                         ##
--############################################################################################################

DEFINE iSqlErr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cInfoErr			CHAR(100);
DEFINE cCodret          CHAR(5);
DEFINE cMensRet         CHAR(40);
DEFINE iRegsAct		    INTEGER;
DEFINE inumerolote		INTEGER;
DEFINE icommit			INTEGER;

LET cInfoErr = '';
LET cCodret = '00000' ;
LET cMensRet = 'Proceso de actualización lotes exitoso.';
LET iRegsAct = 0;
LET inumerolote = 0;
LET icommit = 0;

		--	Set debug file to "/informix/frg/sp_actualizabinarqc.out";
		--	trace on;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				LET cMensRet = 'Error en el proceso, validar.';
				--	Set debug file to "/informix/frg/sp_actualizabinarqc.out";
				--	trace on;
			END IF;
		END EXCEPTION;

		FOREACH WITH HOLD
			SELECT numerolote
				INTO inumerolote--1200
			FROM "informix".hsmcard_paso
			
			let inumerolote = inumerolote;
			
			BEGIN WORK;
				if icommit = 5000
					then
						COMMIT WORK;
						LET icommit = 0;
						CONTINUE FOREACH;
					else
						
				end if;
				
				update "informix".hsmcard 
					set binarqc = '426807'
					where card_no in (select numtarjeta from "informix".tarjeta where numerolote in 
										(select numerolote from "informix".hsmcard_paso where numerolote = inumerolote)
									 );
					LET icommit = icommit+1;
					--	LET iRegsAct = iRegsAct+1;
			COMMIT WORK;
		END FOREACH;
		
		RETURN cCodret,cMensRet;

    END;
END PROCEDURE;