CREATE PROCEDURE "informix".sp_reportes_conciliacion
(
	pvindica 			VARCHAR(1),---parametro que indica el reporte que se va a generar. (F) Transacciones forzadas
	pvfecha_inicio 		VARCHAR(10),---Fecha inicio del periodo que abarca el reporte(dd-mm-yyyy).
	pvfecha_fin   		VARCHAR(10),---Fecha fin del periodo que abarca el reporte(dd-mm-yyyy).
	pvbin				VARCHAR(6)--Parametro si el BIN es de débito o crédito
)
RETURNING VARCHAR(6), VARCHAR(80)
/*
#####################################################################################
#   Descripcion: SP con el menú para la creación de reportes de conciliación.		#
#   Creado por: María del Rosario Montes Villa.										#
#   Fecha: 26/08/2014																#
#####################################################################################
#   Modificado por: 																#
#   Fecha de modificacion: 															#
#   Motivo:																			#
#####################################################################################
*/
DEFINE visqlerr 		INTEGER;
DEFINE visam_err		INTEGER;
DEFINE vverror_info		VARCHAR(80);
DEFINE vvcodret			VARCHAR(6);
DEFINE vvmensaje		VARCHAR(80);
DEFINE vdfecha_inicio	DATE;
DEFINE vidia			INTEGER;
DEFINE vimes			INTEGER;
DEFINE vianio			INTEGER;
DEFINE vdfecha_fin		DATE;
DEFINE vidia2			INTEGER;
DEFINE vimes2			INTEGER;
DEFINE vianio2			INTEGER;
DEFINE vibin_valido		INTEGER;


	--SET DEBUG FILE TO "/resplogifx/txsforzadas_1.sql";
	--TRACE ON;
	BEGIN
	
		ON EXCEPTION SET visqlerr, visam_err, vverror_info
			IF visqlerr <> 0 AND visqlerr <> -958 THEN 
				LET vvcodret	= 	visqlerr;
				LET vvmensaje	=	vverror_info;
				RETURN vvcodret, vvmensaje;
			END IF;
		END EXCEPTION;
		---Valida pvindica.
		IF (pvindica IN ('F')) THEN
					------------------------------------------------------------------------------------------------------------------------
					---Valida pvfecha_inicio
					------------------------------------------------------------------------------------------------------------------------
					IF ( LENGTH(pvfecha_inicio) = 10 OR  pvfecha_inicio = '') THEN
							LET vidia			=	SUBSTR(pvfecha_inicio,1,2);
							LET vimes			=	SUBSTR(pvfecha_inicio,4,2);
							LET vianio			=	SUBSTR(pvfecha_inicio,7,4);
							IF  (pvfecha_inicio = '') THEN 
								LET vidia			=	0;
								LET vimes			=	0;
								LET vianio			=	0;
							END IF;
							
							---Valida año.
							IF ( vianio	> 2007 OR vianio = 0)THEN
								---Valida mes.
								IF (( vimes>=1  AND vimes<=12) OR  vimes = 0)THEN
									---Valida días
									IF  (( (vimes IN (1,3, 5, 7, 8, 10, 12) AND vidia>= 1 AND vidia<=31) OR 
										  (vimes IN (4,6,9,11) AND vidia>= 1 AND vidia<=30) OR 
										  (vimes = 2 AND ((MOD( vianio,4) = 0 AND (vidia>= 1 AND vidia<=29)) OR (vidia>= 1 AND vidia<=28))))
										  OR ( vidia = 0) )THEN 
										  LET  vdfecha_inicio = SUBSTR(pvfecha_inicio,4,2)||'-'||SUBSTR(pvfecha_inicio,1,2)||'-'||SUBSTR(pvfecha_inicio,7,4);										  --LET  vdfecha_inicio = SUBSTR(pvfecha_inicio,4,2)||'-'||SUBSTR(pvfecha_inicio,1,2)||'-'||SUBSTR(	pvfecha_inicio,7,4);--(aaaa-mm-dd) para aqua
										---------------------------------------------------------------------------------------------------
										---Valida pvfecha_fin
										---------------------------------------------------------------------------------------------------
										IF ( LENGTH(pvfecha_fin) = 10 OR pvfecha_fin = '' ) THEN
												LET vidia2			=	SUBSTR(pvfecha_fin,1,2);
												LET vimes2			=	SUBSTR(pvfecha_fin,4,2);
												LET vianio2			=	SUBSTR(pvfecha_fin,7,4);
												 
												IF  (pvfecha_fin = '') THEN 
													LET vidia2			=	0;
													LET vimes2			=	0;
													LET vianio2			=	0;
												END IF;
												
												---Valida año.
												IF ( vianio2	> 2007  OR  vianio2 = 0)THEN
													---Valida mes.
													IF ( (vimes2>=1  AND vimes2<=12) OR (vimes2 = 0)) THEN
														---Valida días
														IF  (( (vimes2 IN (1,3, 5, 7, 8, 10, 12) AND vidia2>= 1 AND vidia<=31) OR 
															   (vimes2 IN (4,6,9,11) AND vidia2>= 1 AND vidia2<=30) OR 
															   (vimes2 = 2 AND ((MOD( vianio2,4) = 0 AND (vidia2>= 1 AND vidia2<=29)) OR (vidia2>= 1 AND vidia2<=28))))
															  OR (vidia2 = 0) )THEN 
															 
															 LET  vdfecha_fin = SUBSTR(	pvfecha_fin,4,2)||'-'||SUBSTR(pvfecha_fin,1,2)||'-'||SUBSTR(pvfecha_fin,7,4);															 --LET  vdfecha_fin = SUBSTR(pvfecha_fin,4,2)||'-'||SUBSTR(pvfecha_fin,1,2)||'-'||SUBSTR(pvfecha_fin,7,4);--(aaaa-mm-dd) para a
															 
															 ---Valida que la fecha inicio sea menor a la fecha fin
															 IF (	(pvfecha_inicio<>'' AND pvfecha_inicio <> '') AND (vdfecha_inicio>vdfecha_fin)) THEN 
																LET vvcodret	=	'006';
																LET vvmensaje	=	'La fecha fin tiene que ser  mayor a la fecha inicio.';
																RETURN vvcodret, vvmensaje;
															 END IF;
															 
															 ---Valida BIN
															 SET ISOLATION TO DIRTY READ;
															 SELECT COUNT(*) INTO  vibin_valido FROM intercard:bines WHERE bin=pvbin;
															 
															 IF( pvbin='' OR (LENGTH(pvbin)= 6 AND vibin_valido>0)) THEN
																	 -------------------------------------------------------------------------------------
																	 ---------------MENÚ DE REPORTES
																	 -------------------------------------------------------------------------------------
																	 --- Reporte de transacciones forzadas; ruta del archivo:/resplogifx/forzadas_ddmmyyyy.txt.
																	 IF ( pvindica = 'F' ) THEN
																			EXECUTE PROCEDURE intercard:sp_txn_forzadas(pvindica, pvfecha_inicio) INTO vvcodret, vvmensaje;
																			RETURN vvcodret, vvmensaje;
																	END IF;
																
															 END IF;
															 LET vvcodret	=	'000';
															 LET vvmensaje	=	 'BIN invalido';
															 RETURN vvcodret, vvmensaje;
																
															
														END IF;
														LET vvcodret	=	'005';
														LET vvmensaje	=	'El día de fecha fin es invalido.';
														RETURN vvcodret, vvmensaje;
													END IF;
													LET vvcodret	=	'004';
													LET vvmensaje	=	'El mes de fecha fin es invalido.';
													RETURN vvcodret, vvmensaje;							
												END IF;
												LET vvcodret	=	'003';
												LET vvmensaje	=	 'El año de fecha fin es invalido.';
												RETURN vvcodret, vvmensaje;
										END IF;
										LET vvcodret	=	'002';
										LET vvmensaje	=	'Parametro '||pvfecha_fin||' de fecha fin es invalido.';
										RETURN vvcodret, vvmensaje;
										
										-----------------------------------------------------------------------------------------------------
									END IF;
									LET vvcodret	=	'005';
									LET vvmensaje	=	'El día de fecha inicio es invalido.';
									RETURN vvcodret, vvmensaje;
								END IF;
								LET vvcodret	=	'004';
								LET vvmensaje	=	'El mes de fecha inicio es invalido.';
								RETURN vvcodret, vvmensaje;								
							END IF;
							LET vvcodret	=	'003';
							LET vvmensaje	=	'El año de fecha inicio es invalido.';
							RETURN vvcodret, vvmensaje;
					END IF;
					LET vvcodret	=	'002';
					LET vvmensaje	=	'Parametro '||pvfecha_inicio||' de fecha inicio es invalido.';
					RETURN vvcodret, vvmensaje;		
		END IF;
		LET vvcodret	=	'001';
		LET vvmensaje	=	'Parametro '||pvindica||' invalido.';
		RETURN vvcodret, vvmensaje;		
	END;
END PROCEDURE;