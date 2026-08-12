CREATE PROCEDURE "informix".sp_valida_comportamiento_tabla_temporal(pAnio CHAR(5),pNum_credito CHAR(20), pDiaCorte char(2))
RETURNING CHAR(5)
	--11-11-2013
	--Realizo: Jose Ruben Lopez
	--calcula el comportamiento de los credito a plazo 
	--Solicito:Jose de Jesus Nevarez
	--BD: bdimonitorcob
	--------------------------------------------------------
DEFINE cCod_Ret           CHAR(5);
DEFINE iSqlErr            INTEGER;
DEFINE iSamErr            INTEGER;
DEFINE vDesErr            CHAR(60);
DEFINE anioAux   		  INTEGER;
DEFINE ciclo 			  INTEGER;

DEFINE montoC2				MONEY(16,2);
DEFINE eneC				  MONEY(16,2);
DEFINE febC				  MONEY(16,2);
DEFINE marC				  MONEY(16,2);
DEFINE abrC				  MONEY(16,2);
DEFINE mayC				  MONEY(16,2);
DEFINE junC				  MONEY(16,2);
DEFINE julC				  MONEY(16,2);
DEFINE agoC				  MONEY(16,2);
DEFINE sepC				  MONEY(16,2);
DEFINE octC				  MONEY(16,2);
DEFINE novC				  MONEY(16,2);
DEFINE dicC				  MONEY(16,2);

LET montoC2=0;
LET eneC=0;
LET febC=0;
LET marC=0;
LET abrC=0;
LET mayC=0;
LET junC=0;
LET julC=0;
LET agoC=0;
LET sepC=0;
LET octC=0;
LET novC=0;
LET dicC=0;

LET anioAux=0;
LET cCod_Ret='00000';
--SET DEBUG FILE TO "/informix/ALL/sp_valida_comportamiento_tabla_temporal.out";
--TRACE ON;

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET cCod_Ret = iSqlErr;
        END IF;
        RETURN cCod_Ret;
    END EXCEPTION;
	ON EXCEPTION IN (-206) --ERROR TABLA TEMPORAL NO EXISTE
        LET cCod_Ret = '00002';        RETURN cCod_Ret;
    END EXCEPTION;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	/*
	SELECT dia_corte 
	INTO diaCorte
	FROM bdicred:"informix".sd_maecredanexocrd WHERE num_credito= pNum_credito--'640000000508'
	*/
					--RETORNA FORMATO CORRECTO DEL COMPORTAMIENTO
					--P=1,I=2,NP=3 ESOS DATOS SE MANEJARAN EN EL SISTEMA PARA DARLE EL FORMATO CORRECTO.
					LET anioAux=pAnio;
					FOR  ciclo = 1 TO 3 --SON TRES ANIOS LOS QUE SE MANEJAN 
							
							SELECT ene,feb,mar,abr,may,jun,jul,ago,sep,octu,nov,dic 
							INTO eneC,febC,marC,abrC,mayC,junC,julC,agoC,sepC,octC,novC,dicC
							FROM tTempInd 
							where anio=anioAux 
							AND id_concepto='230';
							
							--ENERO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=1
							and day (fecha_emision) = pDiaCorte;							
							IF eneC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET ene=0 where anio=anioAux AND id_concepto='230';
							ELIF eneC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET ene=1 where anio=anioAux AND id_concepto='230';
							ELIF eneC > 0 AND eneC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET ene=2 where anio=anioAux AND id_concepto='230';
							ELIF eneC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET ene=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET ene=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--FEBRERO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=2
							and day (fecha_emision) = pDiaCorte;
							
							IF febC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET feb=0 where anio=anioAux AND id_concepto='230';
							ELIF febC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET feb=1 where anio=anioAux AND id_concepto='230';
							ELIF febC > 0 AND febC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET feb=2 where anio=anioAux AND id_concepto='230';
							ELIF febC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET feb=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET feb=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--MARZO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=3
							and day (fecha_emision) = pDiaCorte; 
							
							IF marC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET mar=0 where anio=anioAux AND id_concepto='230';
							ELIF marC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET mar=1 where anio=anioAux AND id_concepto='230';
							ELIF marC > 0 AND marC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET mar=2 where anio=anioAux AND id_concepto='230';
							ELIF marC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET mar=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET mar=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--ABRIL
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=4
							and day (fecha_emision) = pDiaCorte; 
							
							IF abrC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET abr=0 where anio=anioAux AND id_concepto='230';
							ELIF abrC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET abr=1 where anio=anioAux AND id_concepto='230';
							ELIF abrC > 0 AND abrC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET abr=2 where anio=anioAux AND id_concepto='230';
							ELIF abrC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET abr=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET abr=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--MAYO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=5
							and day (fecha_emision) = pDiaCorte; 
							
							IF mayC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET may=0 where anio=anioAux AND id_concepto='230';
							ELIF mayC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET may=1 where anio=anioAux AND id_concepto='230';
							ELIF mayC > 0 AND mayC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET may=2 where anio=anioAux AND id_concepto='230';
							ELIF mayC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET may=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET may=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--JUNIO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=6
							and day (fecha_emision) = pDiaCorte; 
							
							IF junC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET jun=0 where anio=anioAux AND id_concepto='230';
							ELIF junC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET jun=1 where anio=anioAux AND id_concepto='230';
							ELIF junC > 0 AND junC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET jun=2 where anio=anioAux AND id_concepto='230';
							ELIF junC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET jun=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET jun=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--JULIO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=7
							and day (fecha_emision) = pDiaCorte; 
							
							IF julC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET jul=0 where anio=anioAux AND id_concepto='230';
							ELIF julC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET jul=1 where anio=anioAux AND id_concepto='230';
							ELIF julC > 0 AND julC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET jul=2 where anio=anioAux AND id_concepto='230';
							ELIF julC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET jul=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET jul=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--AGOSTO
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=8
							and day (fecha_emision) = pDiaCorte; 
							
							IF agoC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET ago=0 where anio=anioAux AND id_concepto='230';
							ELIF agoC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET ago=1 where anio=anioAux AND id_concepto='230';
							ELIF agoC > 0 AND agoC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET ago=2 where anio=anioAux AND id_concepto='230';
							ELIF agoC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET ago=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET ago=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--SEPTIEMBRE
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=9
							and day (fecha_emision) = pDiaCorte; 
							
							IF sepC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET sep=0 where anio=anioAux AND id_concepto='230';
							ELIF sepC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET sep=1 where anio=anioAux AND id_concepto='230';
							ELIF sepC > 0 AND sepC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET sep=2 where anio=anioAux AND id_concepto='230';
							ELIF sepC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET sep=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET sep=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--OCTUBRE
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=10
							and day (fecha_emision) = pDiaCorte; 
							
							IF octC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET octu=0 where anio=anioAux AND id_concepto='230';
							ELIF octC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET octu=1 where anio=anioAux AND id_concepto='230';
							ELIF octC > 0 AND octC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET octu=2 where anio=anioAux AND id_concepto='230';
							ELIF octC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET octu=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET octu=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--NOVIEMBRE
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=11
							and day (fecha_emision) = pDiaCorte; 
							
							IF novC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET nov=0 where anio=anioAux AND id_concepto='230';
							ELIF novC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET nov=1 where anio=anioAux AND id_concepto='230';
							ELIF novC > 0 AND novC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET nov=2 where anio=anioAux AND id_concepto='230';
							ELIF novC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET nov=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET nov=0 where anio=anioAux AND id_concepto='230';
							END IF;
							--DICIEMBRE
							SELECT pago_total_tc
							INTO montoC2
							FROM bdicred:"informix".sd_encabezado2_edoctacrd
							WHERE YEAR(fecha_emision)=anioAux
							AND num_credito=pNum_credito
							AND MONTH(fecha_emision)=12
							and day (fecha_emision) = pDiaCorte; 
							
							IF dicC = 0 AND montoC2 = 0 THEN
								UPDATE tTempInd SET dic=0 where anio=anioAux AND id_concepto='230';
							ELIF dicC >= montoC2 THEN-- P=Pago Completo del Periodo
								UPDATE tTempInd SET dic=1 where anio=anioAux AND id_concepto='230';
							ELIF dicC > 0 AND dicC < montoC2 THEN--I= Incompleto si el pago fue incompleto en el periodo
								UPDATE tTempInd SET dic=2 where anio=anioAux AND id_concepto='230';
							ELIF dicC=0 AND montoC2 > 0 THEN--NP=No pago en el periodo
								UPDATE tTempInd SET dic=3 where anio=anioAux AND id_concepto='230';
							ELIF montoC2 is null then --Cuando el monto sea null del estado de cuenta que pinte cero
								UPDATE tTempInd SET dic=0 where anio=anioAux AND id_concepto='230';
							END IF;
							LET anioAux = anioAux+1;
					END FOR;

				RETURN cCod_Ret;
END;
END PROCEDURE;