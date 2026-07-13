CREATE PROCEDURE "informix".sp_mc_cie_tri(dFecha DATE, cTrimestreC CHAR(5),iMes INTEGER)
       RETURNING CHAR (5), CHAR(1000);

---####################################################################################
---#  Autor: Bancoppel (RMS)                                                          #
---#  Fecha:                                                                          #
---#  Descripcion: Genera cierre trimestral para el Reporte ídem                      #
---#  de MASTERCARD De Crédito. Producto = 7000 (Crédito) 2400 (Débito) 8100(Oro)     #
---#                                                                                  #
---#                                                                                  #
---####################################################################################


--MANEJO DE ERRORES
DEFINE iSqlErr                    INTEGER;
DEFINE cVarDataErr                CHAR(500);
DEFINE cVarDataErr1               CHAR(100);
DEFINE cVarDataErr2               CHAR(100);
DEFINE cVarDataErr3               CHAR(100);
DEFINE cVarDataErr4               CHAR(100);
DEFINE cVarDataErr5               CHAR(100);
DEFINE cVarDataErr6               CHAR(100);
DEFINE cVarDataErr7               CHAR(100);
DEFINE cVarDataErr8               CHAR(100);
DEFINE cVarDataErr9               CHAR(100);
DEFINE cVarDataErr10              CHAR(100);
DEFINE cVarDataErr11              CHAR(100);
DEFINE cVarDataErr12              CHAR(100);
DEFINE cVarDataErr13              CHAR(100);
DEFINE cVarDataErr14              CHAR(100);
DEFINE cVarDataErr15              CHAR(100);
DEFINE cVarDataErr16              CHAR(100);
DEFINE cVarDataErr17              CHAR(100);
DEFINE cVarDataErr18              CHAR(100);
DEFINE cVarDataErr19              CHAR(100);
DEFINE cVarDataErr20              CHAR(100);
DEFINE cVarDataErr21              CHAR(100);
DEFINE cVarDataErr22              CHAR(100);
DEFINE cVarDataErr23              CHAR(100);

DEFINE cCodret                    CHAR(5);

--GENERALES
DEFINE cNumProducto               CHAR(4);
DEFINE cCodFila                   CHAR(3);
DEFINE cNombreArc                 CHAR(24);
DEFINE cFecha1                    CHAR(50);
DEFINE cFecha2                    CHAR(50);
DEFINE dFechaAtmInicio            DATETIME YEAR TO FRACTION (5);
DEFINE dFechaAtmFin               DATETIME YEAR TO FRACTION (5);
DEFINE dFechaInicio               DATETIME YEAR TO FRACTION (5);
DEFINE dFechaFin                  DATETIME YEAR TO FRACTION (5);
DEFINE dfechaIniTri               DATE;
DEFINE dfechaFinTri               DATE;
DEFINE fechaIniTri_Ant            CHAR(10);
DEFINE fechaFinTri_Ant            CHAR(10);
DEFINE dfechaIniTri_Ant            DATE;
DEFINE dfechaFinTri_Ant            DATE;
DEFINE VanioTri                   CHAR(4);
DEFINE VanioTriN                  SMALLINT;
DEFINE Vtrimestre                 SMALLINT;
DEFINE Vid_tipo                   CHAR(1);
DEFINE Vtipo_cta                  CHAR(30);
DEFINE Vcta_act_C                 SMALLINT;
DEFINE Vcta_bloq_C                SMALLINT;
DEFINE Vcta_nva_C                 SMALLINT;
DEFINE Vcta_canc_C                SMALLINT;
DEFINE Vcta_act_CF                SMALLINT;
DEFINE Vcta_bloq_CF               SMALLINT;
DEFINE Vcta_tran_C                SMALLINT;
DEFINE Vtot_tran_C                MONEY(16,2);
DEFINE Vtar_act_CF                SMALLINT;
DEFINE Vtar_bloq_CF               SMALLINT;
DEFINE Vcta_act_D                 SMALLINT;
DEFINE Vcta_bloq_D                SMALLINT;
DEFINE Vcta_nva_D                 SMALLINT;
DEFINE Vcta_canc_D                SMALLINT;
DEFINE Vcta_act_DF                SMALLINT;
DEFINE Vcta_bloq_DF               SMALLINT;
DEFINE Vcta_tran_D                SMALLINT;
DEFINE Vtar_act_D                 SMALLINT;
DEFINE Vtar_bloq_D                SMALLINT;
DEFINE Vtar_nvas_D                SMALLINT;
DEFINE Vtar_act_DF                SMALLINT;
DEFINE Vtar_bloq_DF               SMALLINT;
DEFINE Vtar_tran_D                SMALLINT;
DEFINE Vtot_tran_D                MONEY(16,2);
DEFINE VCod_Deb                   CHAR(1);
DEFINE cTrimestre                 SMALLINT;

DEFINE FechaInicioTrimestreActual			     DATE;
DEFINE FechafinTrimestreActual			         DATE;
DEFINE FechaInicioTrimestreAnterior			     DATE;
DEFINE FechafinTrimestreAnterior			     DATE;

DEFINE FechaInicioTrimestreActual2			     DATE;
DEFINE FechafinTrimestreActual2			         DATE;
DEFINE FechaInicioTrimestreAnterior2		     DATE;
DEFINE FechafinTrimestreAnterior2			     DATE;

DEFINE Fech_Inic_Act							CHAR(50);
DEFINE Fech_Fin_Act 							CHAR(50);
DEFINE Fech_Inic_Anterior						CHAR(50);
DEFINE Fech_Fin_Anterior						CHAR(50);

DEFINE Fech_Inic_Act2							CHAR(50);
DEFINE Fech_Fin_Act2							CHAR(50);
DEFINE Fech_Inic_Anterior2						CHAR(50);
DEFINE Fech_Fin_Anterior2						CHAR(50);
DEFINE dFecha2									DATE;

--DEFINE dFechaInicioTrimestre     DATETIME YEAR TO FRACTION (5);
--DEFINE dFechaFinalTrimestre      DATETIME YEAR TO FRACTION (5);

ON EXCEPTION SET iSqlErr

   SET DEBUG FILE TO "/respaldos/sp_mc_cie_tri.err";

   IF iSqlErr <> 0 THEN
      LET cVarDataErr = cVarDataErr||'ERROR NO CONTROLADO('||iSqlErr||').' ;
      LET cCodret='-1';

      INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                    ultima_actualizacion,
                                                    estatus_actualizacion,
                                                    dias_pendientes,
                                                    ultimo_error)
             VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cVarDataErr);

      RETURN cCodret, cVarDataErr;
   END IF;
END EXCEPTION;



SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/informix/ilopez/MASTERCARD/sp_mc_cie_tri.out";
--TRACE ON;

 
LET  cVarDataErr = '';
LET  cVarDataErr2 = '';
LET  cVarDataErr3 = '';
LET  cVarDataErr4 = '';
LET  cVarDataErr5 = '';
LET  cVarDataErr6 = '';
LET  cVarDataErr7 = '';
LET  cVarDataErr8 = '';
LET  cVarDataErr9 = '';
LET  cVarDataErr10 = '';
LET  cVarDataErr11 = '';
LET  cVarDataErr12 = '';
LET  cVarDataErr13 = '';
LET  cVarDataErr14 = '';
LET  cVarDataErr15 = '';
LET  cVarDataErr16 = '';
LET  cVarDataErr17 = '';
LET  cVarDataErr18 = '';
LET  cVarDataErr19 = '';
LET  cVarDataErr20 = '';
LET  cVarDataErr21 = '';
LET  cVarDataErr22 = '';
LET  cVarDataErr23 = '';

LET VanioTri  = '';
LET Vtrimestre = '';

LET cTrimestre = cTrimestreC;

LET Vcta_act_C   = 0;
LET Vcta_bloq_C  = 0;
LET Vcta_nva_C   = 0;
LET Vcta_canc_C  = 0;
LET Vcta_act_CF  = 0;
LET Vcta_bloq_CF = 0;
LET Vcta_tran_C  = 0;
LET Vtot_tran_C  = 0;
LET Vtar_act_CF = 0;
LET Vtar_bloq_CF= 0;
LET Vcta_act_D  = 0;
LET Vcta_bloq_D = 0;
LET Vcta_nva_D  = 0;
LET Vcta_canc_D = 0;
LET Vcta_act_DF = 0;
LET Vcta_bloq_DF = 0;
LET Vcta_tran_D  = 0;
LET Vtar_act_D   = 0;
LET Vtar_bloq_D  = 0;
LET Vtar_nvas_D  = 0;
LET Vtar_act_DF  = 0;
LET Vtar_bloq_DF = 0;
LET Vtar_tran_D  = 0;
LET Vtot_tran_D  = 0;

LET FechaInicioTrimestreActual='';
LET FechafinTrimestreActual='';
LET FechaInicioTrimestreAnterior='';
LET FechafinTrimestreAnterior='';


LET FechaInicioTrimestreActual2='';
LET FechafinTrimestreActual2='';
LET FechaInicioTrimestreAnterior2='';
LET FechafinTrimestreAnterior2='';


LET Fech_Inic_Act='';
LET Fech_Fin_Act='';							
LET Fech_Inic_Anterior='';					
LET Fech_Fin_Anterior='';

						
LET Fech_Inic_Act2='';							
LET Fech_Fin_Act2='';							
LET Fech_Inic_Anterior2='';
LET Fech_Fin_Anterior2='';	

LET dFecha2='';			
---------------------------------------------------------------
--- # CÁLCULO DE LAS FECHAS INICIAL Y FINAL POR TRIMESTRE # ---
---------------------------------------------------------------

LET VanioTri = cTrimestreC[1,4];
LET VanioTriN = VanioTri;
LET Vtrimestre = cTrimestreC[5,5];

--IF EXISTS ( SELECT dbsname, tabname
             -- FROM sysmaster:SysTabNames
            -- WHERE partnum IS NOT NULL
               --AND tabname = 'tmp_rpt_mc_trim'
              -- AND dbsname= 'bdireports') THEN
--DROP TABLE bdireports:tmp_rpt_mc_trim;
--END IF;

CREATE TEMP TABLE tmp_rpt_mc_trim
(
trimestre        SMALLINT,
fechaIni         DATE,
fechaFin         DATE,
fechaIniAnt      DATE,
fechaFinAnt      DATE)
WITH NO LOG;

IF Vtrimestre = 1 THEN
   LET VanioTriN = VanioTri - 1;
   LET dFechaIniTri = '01/01/'||VanioTri;
   LET dFechaFinTri = '03/31/'||VanioTri;
   LET dFechaIniTri_Ant = '10/01/'||VanioTriN;
   LET dFechaFinTri_Ant = '12/31/'||VanioTriN;
END IF;

IF Vtrimestre = 2 THEN
   LET dFechaIniTri = '04/01/'||VanioTri;
   LET dFechaFinTri = '06/30/'||VanioTri;
   LET dFechaIniTri_Ant = '01/01/'||VanioTri;
   LET dFechaFinTri_Ant = '03/31/'||VanioTri;
END IF;

IF Vtrimestre = 3 THEN
   LET dFechaIniTri = '07/01/'||VanioTri;
   LET dFechaFinTri = '09/30/'||VanioTri;
   LET dFechaIniTri_Ant = '04/01/'||VanioTri;
   LET dFechaFinTri_Ant = '06/30/'||VanioTri;
END IF;

IF Vtrimestre = 4 THEN
   LET dFechaIniTri = '10/01/'||VanioTri;
   LET dFechaFinTri = '12/31/'||VanioTri;
   LET dFechaIniTri_Ant = '07/01/'||VanioTri;
   LET dFechaFinTri_Ant = '09/30/'||VanioTri;
END IF;


--CONVERTIR A FECHA para la Tabla Movimientos_Conciliación
IF Vtrimestre = 1 THEN
  
  --Trimestre Inicio Actual
  LET Fech_Inic_Act=VanioTriN || '-' || '01' || '-' ||
                 '01' || ' 00:00:00.00000';	
  
  LET FechaInicioTrimestreActual = CAST (Fech_Inic_Act AS DATETIME year to fraction(5));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act=VanioTriN || '-' || '03' || '-' ||
                 '31' || ' 23:59:59.00000';
	
  
  LET FechafinTrimestreActual = CAST (Fech_Fin_Act AS DATETIME year to fraction(5)); 
  
  
 
  --Trimestre Inicio Anterior
  LET VanioTriN = VanioTri - 1;
  LET Fech_Inic_Anterior=VanioTriN || '-' || '10' || '-' ||
                 '01' ||' 00:00:00.00000';	
 
   LET FechaInicioTrimestreAnterior = CAST (Fech_Inic_Anterior AS DATETIME year to fraction(5));			 

   
   --Trimestre Fin Anterior
  LET Fech_Fin_Anterior=VanioTriN || '-' || '12' || '-' ||
                 '31' || ' 23:59:59.00000';
    
  LET FechafinTrimestreAnterior= CAST (Fech_Fin_Anterior AS DATETIME year to fraction(5));
  
  
END IF;

IF Vtrimestre = 2 THEN
  --Trimestre Inicio Actual
  LET Fech_Inic_Act=VanioTriN || '-' || '04' || '-' ||
                 '01' || ' 00:00:00.00000';	
  
  LET FechaInicioTrimestreActual = CAST (Fech_Inic_Act AS DATETIME year to fraction(5));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act=VanioTriN || '-' || '06' || '-' ||
                 '30' || ' 23:59:59.00000';
	
  
  LET FechafinTrimestreActual = CAST (Fech_Fin_Act AS DATETIME year to fraction(5)); 
  
  
  
  --Trimestre Inicio Anterior
  
  LET Fech_Inic_Anterior=VanioTriN || '-' || '01' || '-' ||
                 '01' ||' 00:00:00.00000';	
 
   LET FechaInicioTrimestreAnterior = CAST (Fech_Inic_Anterior AS DATETIME year to fraction(5));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior=VanioTriN || '-' || '03' || '-' ||
                 '31' || ' 23:59:59.00000';
    
  LET FechafinTrimestreAnterior= CAST (Fech_Fin_Anterior AS DATETIME year to fraction(5));
END IF;



IF Vtrimestre = 3 THEN
 --Trimestre Inicio Actual
  LET Fech_Inic_Act=VanioTriN || '-' || '07' || '-' ||
                 '01' || ' 00:00:00.00000';	
  
  LET FechaInicioTrimestreActual = CAST (Fech_Inic_Act AS DATETIME year to fraction(5));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act=VanioTriN || '-' || '09' || '-' ||
                 '30' || ' 23:59:59.00000';
	
  
  LET FechafinTrimestreActual = CAST (Fech_Fin_Act AS DATETIME year to fraction(5)); 
  
  
  
  --Trimestre Inicio Anterior
  
  LET Fech_Inic_Anterior=VanioTriN || '-' || '04' || '-' ||
                 '01' ||' 00:00:00.00000';	
 
   LET FechaInicioTrimestreAnterior = CAST (Fech_Inic_Anterior AS DATETIME year to fraction(5));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior=VanioTriN || '-' || '06' || '-' ||
                 '30' || ' 23:59:59.00000';
    
  LET FechafinTrimestreAnterior= CAST (Fech_Fin_Anterior AS DATETIME year to fraction(5));
END IF;

IF Vtrimestre = 4 THEN

--Trimestre Inicio Actual
  LET Fech_Inic_Act=VanioTriN || '-' || '10' || '-' ||
                 '01' || ' 00:00:00.00000';	
  
  LET FechaInicioTrimestreActual = CAST (Fech_Inic_Act AS DATETIME year to fraction(5));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act=VanioTriN || '-' || '12' || '-' ||
                 '31' || ' 23:59:59.00000';
	
  
  LET FechafinTrimestreActual = CAST (Fech_Fin_Act AS DATETIME year to fraction(5)); 
  
  
  
  --Trimestre Inicio Anterior
  
  LET Fech_Inic_Anterior=VanioTriN || '-' || '07' || '-' ||
                 '01' ||' 00:00:00.00000';	
 
   LET FechaInicioTrimestreAnterior = CAST (Fech_Inic_Anterior AS DATETIME year to fraction(5));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior=VanioTriN || '-' || '09' || '-' ||
                 '30' || ' 23:59:59.00000';
    
  LET FechafinTrimestreAnterior= CAST (Fech_Fin_Anterior AS DATETIME year to fraction(5));  
  
END IF;

-------------------------------------------------------tabla bitasignacionactivaciontarjeta
IF Vtrimestre = 1 THEN
 
  --Trimestre Inicio Actual
  LET Fech_Inic_Act2=VanioTriN || '-' || '01' || '-' ||
                 '01' || ' 00:00:00.000';	
  
  LET FechaInicioTrimestreActual2 = CAST (Fech_Inic_Act2 AS DATETIME year to fraction(3));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act2=VanioTriN || '-' || '03' || '-' ||
                 '31' || ' 23:59:59.000';
	
  
  LET FechafinTrimestreActual2 = CAST (Fech_Fin_Act2 AS DATETIME year to fraction(3)); 
  
  
  
  --Trimestre Inicio Anterior
   LET VanioTriN = VanioTri - 1;
   LET Fech_Inic_Anterior2=VanioTriN || '-' || '10' || '-' ||
                 '01' ||' 00:00:00.000';	
 
   LET FechaInicioTrimestreAnterior2 = CAST (Fech_Inic_Anterior2 AS DATETIME year to fraction(3));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior2=VanioTriN || '-' || '12' || '-' ||
                 '31' || ' 23:59:59.000';
    
  LET FechafinTrimestreAnterior2= CAST (Fech_Fin_Anterior2 AS DATETIME year to fraction(3));
  
  
END IF;

IF Vtrimestre = 2 THEN
  --Trimestre Inicio Actual
  LET Fech_Inic_Act2=VanioTriN || '-' || '04' || '-' ||
                 '01' || ' 00:00:00.000';	
  
  LET FechaInicioTrimestreActual2 = CAST (Fech_Inic_Act2 AS DATETIME year to fraction(3));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act2=VanioTriN || '-' || '06' || '-' ||
                 '30' || ' 23:59:59.000';
	
  
  LET FechafinTrimestreActual2 = CAST (Fech_Fin_Act2 AS DATETIME year to fraction(3)); 
  
  
  
  --Trimestre Inicio Anterior
  
  LET Fech_Inic_Anterior2=VanioTriN || '-' || '01' || '-' ||
                 '01' ||' 00:00:00.000';	
 
   LET FechaInicioTrimestreAnterior2 = CAST (Fech_Inic_Anterior2 AS DATETIME year to fraction(3));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior2=VanioTriN || '-' || '03' || '-' ||
                 '31' || ' 23:59:59.000';
    
  LET FechafinTrimestreAnterior2= CAST (Fech_Fin_Anterior2 AS DATETIME year to fraction(3));
END IF;



IF Vtrimestre = 3 THEN
 --Trimestre Inicio Actual
  LET Fech_Inic_Act2=VanioTriN || '-' || '07' || '-' ||
                 '01' || ' 00:00:00.000';	
  
  LET FechaInicioTrimestreActual2 = CAST (Fech_Inic_Act2 AS DATETIME year to fraction(3));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act2=VanioTriN || '-' || '09' || '-' ||
                 '30' || ' 23:59:59.000';
	
  
  LET FechafinTrimestreActual2 = CAST (Fech_Fin_Act2 AS DATETIME year to fraction(3)); 
  
  
  
  --Trimestre Inicio Anterior
  
  LET Fech_Inic_Anterior2=VanioTriN || '-' || '04' || '-' ||
                 '01' ||' 00:00:00.000';	
 
   LET FechaInicioTrimestreAnterior2 = CAST (Fech_Inic_Anterior2 AS DATETIME year to fraction(3));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior2=VanioTriN || '-' || '06' || '-' ||
                 '30' || ' 23:59:59.000';
    
  LET FechafinTrimestreAnterior2= CAST (Fech_Fin_Anterior2 AS DATETIME year to fraction(3));
END IF;

IF Vtrimestre = 4 THEN

--Trimestre Inicio Actual
  LET Fech_Inic_Act2=VanioTriN || '-' || '10' || '-' ||
                 '01' || ' 00:00:00.000';	
  
  LET FechaInicioTrimestreActual2 = CAST (Fech_Inic_Act2 AS DATETIME year to fraction(3));
  
 
 --Trimestre Fin Actual
  LET Fech_Fin_Act2=VanioTriN || '-' || '12' || '-' ||
                 '31' || ' 23:59:59.000';
	
  
  LET FechafinTrimestreActual2 = CAST (Fech_Fin_Act2 AS DATETIME year to fraction(3)); 
  
  
  
  --Trimestre Inicio Anterior
  
  LET Fech_Inic_Anterior2=VanioTriN || '-' || '07' || '-' ||
                 '01' ||' 00:00:00.000';	
 
   LET FechaInicioTrimestreAnterior2 = CAST (Fech_Inic_Anterior2 AS DATETIME year to fraction(3));			 

   
   --Trimestre Fin Anterior
   
   
  LET Fech_Fin_Anterior2=VanioTriN || '-' || '09' || '-' ||
                 '30' || ' 23:59:59.000';
    
  LET FechafinTrimestreAnterior2= CAST (Fech_Fin_Anterior2 AS DATETIME year to fraction(3));  
  
END IF;
-------------------------------------------------------tabla bitasignacionactivaciontarjeta


/*--CONVERTIR FECHA A FRACTION 5
LET FechaInicioTrimestreActual=YEAR(dFechaIniTri) || '-' || LPAD ( MONTH(dFechaIniTri), 2, '0') || '-' ||
                 LPAD (DAY (dFechaIniTri), 2, '0') || ' 00:00:00.00000';			   
	
LET FechafinTrimestreActual=YEAR(dFechaFinTri) || '-' || LPAD ( MONTH(dFechaFinTri), 2, '0') || '-' ||
             LPAD (DAY (dFechaFinTri), 2, '0') || '23:59:59.00000';
	
LET FechaInicioTrimestreAnterior=YEAR(dFechaIniTri_Ant) || '-' || LPAD ( MONTH(dFechaIniTri_Ant), 2, '0') || '-' ||
                 LPAD (DAY (dFechaIniTri_Ant), 2, '0') || ' 00:00:00.00000';	
				 

LET FechafinTrimestreAnterior=YEAR(dFechaFinTri_Ant) || '-' || LPAD ( MONTH(dFechaFinTri_Ant), 2, '0') || '-' ||
				LPAD (DAY (dFechaFinTri_Ant), 2, '0') || '23:59:59.00000';	*/



INSERT INTO bdireports:tmp_rpt_mc_trim (trimestre, fechaIni, fechaFin,
                                        fechaIniAnt, fechaFinAnt)
     VALUES (Vtrimestre, dFechaIniTri, dFechaFinTri, dFechaIniTri_Ant, 
             dFechaFinTri_Ant);

			 
			 
			 
--------------------------------------------------
----# INICIA CÁLCULO PARA TOTALES DE CRÉDITO #----
--------------------------------------------------

    -----------------------------------------------
--- CUENTAS AL INICIO DEL TRIMESTRE ACTIVAS ---
-----------------------------------------------
LET cCodFila = 'CAC';
LET cNumProducto = '7000';
LET Vid_tipo = 'C';
LET Vtipo_cta = 'ACTIVAS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

 

   --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(a.num_credito)
     INTO Vcta_act_C
     FROM bdicred:sd_maecred a
	 INNER JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
    WHERE a.empresa = '001'
      AND a.num_producto = cNumProducto
      AND a.status_cred IN ('AA','E1')
	  AND (b.monto_vencido + b.mto_venc_trasp) = 0
      AND a.fecha_apertura <=dFechaFinTri_Ant;
	  
   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                        id_col, mes, fecha_reg,
                                        id_tipo, total_cuentas,
                                        tipo_cuenta, id_reporte)
           VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                   Vid_tipo, Vcta_act_C, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr2 = 'REGISTRO EXITOSO en rpt_mc_cta_tri '||trim(cCodFila)||' '||trim(cTrimestreC)||'Tot: '||Vcta_act_C||'.';
ELSE
   LET cCodret = '00100';
   LET cVarDataErr2 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
          VALUES ('sp_mc_cie_tri',iMes,dFecha,'',0,cCodret||cVarDataErr2);
END IF;


--------------------------------------------------
--- CUENTAS AL INICIO DEL TRIMESTRE BLOQUEADAS ---
--------------------------------------------------
LET cCodFila = 'CBC';
LET Vtipo_cta = 'BLOQUEADAS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

  
	
	   --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(a.num_credito)
     INTO Vcta_bloq_C
     FROM bdicred:sd_maecred a
	 INNER JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
    WHERE a.empresa = '001'
      AND a.num_producto  = cNumProducto
	  AND a.status_cred IN('BA','BT','E1','E2','E3')
	  AND (b.monto_vencido + b.mto_venc_trasp) > 0
      AND a.fecha_apertura <= dFechaFinTri_Ant ;
	

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
        VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, Vid_tipo,
                Vcta_bloq_C, Vtipo_cta, 0);
       LET cCodret = '00000';
       LET cVarDataErr3 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_bloq_C||'.';
ELSE
   LET cCodret = '00102';
   LET cVarDataErr3 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0 , cCodret||cVarDataErr3);
END IF;


-------------------------------------------
--- CUENTAS NUEVAS DURANTE EL TRIMESTRE ---
-------------------------------------------
LET cCodFila = 'CNC';
LET Vtipo_cta = 'NUEVAS';

--SET ISOLATION TO DIRTY READ;
LET dFecha2=dFecha -1 UNITS MONTH;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN

 
	 
	 -- SET ISOLATION TO DIRTY READ;
   SELECT COUNT(num_credito)
   INTO Vcta_nva_C
     FROM bdicred:sd_maecred
    WHERE empresa = '001'
      AND LEFT(num_credito,4) = cNumProducto
      AND fecha_apertura BETWEEN dFechaIniTri AND dFechaFinTri;
	 

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
           Vid_tipo, Vcta_nva_C, Vtipo_cta, 0);
       LET cCodret = '00000';
       LET cVarDataErr4 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_nva_C||'.';
ELSE
   LET cCodret = '00103';
   LET cVarDataErr4 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha2 ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha2, '', 0, cCodret||cVarDataErr4);
END IF;



-----------------------------------------------
--- CUENTAS CANCELADAS DURANTE EL TRIMESTRE ---
-----------------------------------------------
LET cCodFila = 'CCC';
LET Vtipo_cta = 'CANCELADAS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN


		SELECT COUNT(num_credito)
		INTO Vcta_canc_C
		FROM bdicred:sd_maecred 
		WHERE LEFT(num_credito,4) =cNumProducto
		AND status_cred IN ('FC','FF','FI','CV')
		AND fecha_apertura BETWEEN dFechaIniTri
		AND dFechaFinTri;  
		  
	/*--SET ISOLATION TO DIRTY READ;
		SELECT COUNT(cr.num_credito)
		INTO Vcta_canc_C
		FROM bdicred:sd_maecred cr, bdicred:sd_maecredanexo ax
		WHERE LEFT(cr.num_credito,4) =cNumProducto
		AND left(cr.num_credito,4) = LEFT(ax.num_credito,4)
		AND cr.status_cred IN ('FC','FF','FI','CV')
		AND ax.fecha_proceso BETWEEN dFechaIniTri
		AND dFechaFinTri;*/
	  
		  

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
           Vid_tipo, Vcta_canc_C, Vtipo_cta, 0);

       LET cCodret = '00000';
       LET cVarDataErr5 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_canc_C||'.';
ELSE
   LET cCodret = '00104';
   LET cVarDataErr5 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha2 ||'.';
INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                              ultima_actualizacion,
                                              estatus_actualizacion,
                                              dias_pendientes,
                                               ultimo_error)
VALUES ('sp_mc_cie_tri', iMes, dFecha2, '', 0 , cCodret||cVarDataErr5);
END IF;


-----------------------------------------------
--- CUENTAS ACTIVAS AL FINAL DEL TRIMESTRE  ---
-----------------------------------------------
	LET cCodFila = 'CAC';
    LET Vtipo_cta = 'ACTIVAS';
	
--SET ISOLATION TO DIRTY READ;

    IF NOT EXISTS ( SELECT num_producto
                      FROM bdireports:rpt_mc_cta_tri
                     WHERE num_producto = cNumProducto
                       AND trimestre = cTrimestre
                       AND id_col = cCodFila
                       AND mes = iMes
                       AND fecha_reg = dFecha ) THEN

	  SELECT COUNT(a.num_credito)
     INTO Vcta_act_CF
     FROM bdicred:sd_maecred a
	 INNER JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
    WHERE a.empresa = '001'
      AND a.num_producto = cNumProducto
      AND a.status_cred IN ('AA','E1')
	  AND (b.monto_vencido + b.mto_venc_trasp) = 0
      AND a.fecha_apertura <=dFechaFinTri;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
          VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                  Vid_tipo, Vcta_act_CF, Vtipo_cta, 0);
       LET cCodret = '00000';
       LET cVarDataErr6 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_act_CF||'.';
ELSE
   LET cCodret = '00105';
   LET cVarDataErr6 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0 , cCodret||cVarDataErr6);
END IF;


--------------------------------------------------
--- CUENTAS BLOQUEADAS AL FINAL DEL TRIMESTRE  ---
--------------------------------------------------
LET cCodFila = 'CBC';
LET Vtipo_cta = 'BLOQUEADAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN


	
--SET ISOLATION TO DIRTY READ;
   SELECT COUNT(a.num_credito)
     INTO Vcta_bloq_CF
     FROM bdicred:sd_maecred a
	 INNER JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
    WHERE a.empresa = '001'
      AND a.num_producto = cNumProducto
	  AND a.status_cred IN('BA','BT','E1','E2','E3')
	  AND (b.monto_vencido + b.mto_venc_trasp) > 0
      AND a.fecha_apertura <= dFechaFinTri;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
          VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                  Vid_tipo, Vcta_bloq_CF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr7 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_bloq_CF||'.';
ELSE
LET cCodret = '00106';
LET cVarDataErr7 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                              ultima_actualizacion,
  estatus_actualizacion,
  dias_pendientes,
  ultimo_error)
VALUES ( 'sp_mc_cie_tri',iMes,dFecha,'', 0 ,cCodret||cVarDataErr7);
END IF;


----------------------------------------------------------------------
--- CUENTAS CON POR LO MENOS UNA TRANSACCIÓN DURANTE EL TRIMESTRE  ---
----------------------------------------------------------------------
LET cCodFila = 'CTC';
LET Vtipo_cta = 'CON AL MENOS UNA TRANSACCION';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

       IF EXISTS ( SELECT dbsname, tabname
                     FROM sysmaster:SysTabNames
                    WHERE partnum IS NOT NULL
                      AND tabname = 'total_ctas'
                      AND dbsname= 'bdireports') THEN
          DROP TABLE bdireports:total_ctas;
       END IF;

	   

       SELECT a.numtarjeta numtarjeta,
              NVL(SUM(b.Monto325::MONEY/100),0) monto_total
         FROM intercard:tarjeta a, bditarjeta:td_movimientos_conciliacion b
		  WHERE  b.fechatransaccion between FechaInicioTrimestreActual
		  AND FechafinTrimestreActual
		  AND a.numtarjeta LIKE '554948%'
          AND a.numtarjeta = b.numtarjeta
          AND a.numtarjeta NOT IN (SELECT numtarjeta FROM rpt_mc_tar_pru)
          AND b.monto325 <> 0
          --AND b.fechacarga::date BETWEEN dfechaIniTri AND dfechaFinTri
          AND b.movreversado = 'F'
          AND b.movconciliado = 'V'
          AND b.ban_bin = 'MCR'
          AND a.codstatustarjeta = 'ACT'
          AND a.codstatusasignada = 'SIA'
        GROUP BY a.numtarjeta
         INTO TEMP total_ctas WITH NO LOG;
		 
		 

   SELECT COUNT(*), NVL(SUM(monto_total), 0)
      INTO Vcta_tran_C, Vtot_tran_C
          FROM total_ctas;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vcta_tran_C, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr8 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_tran_C||'.';
ELSE
   LET cCodret = '00107';
   LET cVarDataErr18 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr8);
END IF;


------------------------------------------------
--- TARJETAS ACTIVAS AL FINAL DEL TRIMESTRE  ---
------------------------------------------------
LET cCodFila = 'TAC';
    LET Vid_tipo = 'T';
LET Vtipo_cta = 'ACTIVAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

				   
		
		SELECT 
		count(*) 
		INTO Vtar_act_CF
		FROM intercard:bitasignacionactivaciontarjeta 
		WHERE numtarjeta like '554948%'
		AND fecharegistro between FechaInicioTrimestreActual2
		AND FechafinTrimestreActual2;

	
	/*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}
	COUNT(numtarjeta)
	INTO Vtar_act_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date >= dFechaIniTri
	AND fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='554948'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT';*/


		
    /*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
	COUNT(numtarjeta)
	INTO Vtar_act_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='554948'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT';*/
	  
   /*SELECT COUNT(numtarjeta)
     INTO Vtar_act_CF
     FROM intercard:tarjeta
    WHERE LEFT(numtarjeta,6)='554948'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT'
      AND fechaasignacion::date <=dFechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
          Vid_tipo, Vtar_act_CF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr9 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_act_CF||'.';
ELSE
   LET cCodret = '00108';
   LET cVarDataErr9 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr9);
END IF;


------------------------------------------------
--- TARJETAS BLOQUEADAS AL FINAL DEL TRIMESTRE  ---
------------------------------------------------
LET cCodFila = 'TBC';
    LET Vtipo_cta = 'BLOQUEADAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN


	
			SELECT COUNT(*)
			INTO Vtar_bloq_CF
			FROM intercard:bitacoracambiosstatustarjeta 
			WHERE tarjeta like '554948%'
			AND fechahora between  FechaInicioTrimestreActual
			AND FechafinTrimestreActual
			AND codstatustarjetanvo='BLT';
				
				   
	/*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}
	COUNT(numtarjeta)
	INTO Vtar_bloq_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date >= dFechaIniTri
	AND fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='554948'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/
				   
				   
	/*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
	COUNT(numtarjeta)
	INTO Vtar_bloq_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='554948'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/



   /*SELECT COUNT(numtarjeta)
     INTO Vtar_bloq_CF
     FROM intercard:tarjeta
    WHERE LEFT(numtarjeta,6)='554948'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO'
      AND fechaasignacion::date <=dFechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
    VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
            Vid_tipo, Vtar_bloq_CF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr10 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_bloq_CF||'.';
ELSE
   LET cCodret = '00109';
   LET cVarDataErr10 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ( 'sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr10);
END IF;
-----------------------------
-------PRODUCTO 8100---------
-----------------------------
-----------------------------------------------
--- CUENTAS AL INICIO DEL TRIMESTRE ACTIVAS ---
-----------------------------------------------
LET cCodFila = 'CAC';
LET cNumProducto = '8100';
LET Vid_tipo = 'C';
LET Vtipo_cta = 'ACTIVAS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

				   
   --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(a.num_credito)
     INTO Vcta_act_C
     FROM bdicred:sd_maecred a
	 INNER JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
    WHERE a.empresa = '001'
      AND a.num_producto  = cNumProducto
      AND a.status_cred IN ('AA','E1')
	  AND (b.monto_vencido + b.mto_venc_trasp) = 0
      AND a.fecha_apertura <= dFechaFinTri_Ant ;
	  
   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                        id_col, mes, fecha_reg,
                                        id_tipo, total_cuentas,
                                        tipo_cuenta, id_reporte)
           VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                   Vid_tipo, Vcta_act_C, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr2 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||'Tot: '||Vcta_act_C||'.';
ELSE
   LET cCodret = '00100';
   LET cVarDataErr2 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
          VALUES ('sp_mc_cie_tri',iMes,dFecha,'',0,cCodret||cVarDataErr2);
END IF;


--------------------------------------------------
--- CUENTAS AL INICIO DEL TRIMESTRE BLOQUEADAS ---
--------------------------------------------------
LET cCodFila = 'CBC';
LET Vtipo_cta = 'BLOQUEADAS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN


	
  --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(a.num_credito)
     INTO Vcta_bloq_C
     FROM bdicred:sd_maecred a
	 INNER JOIN bdicred:sd_maesdos b on ( a.num_credito = b.num_credito)
    WHERE a.empresa = '001'
      AND a.num_producto = cNumProducto
	  AND a.status_cred IN('BA','BT','E1','E2','E3')
	  AND (b.monto_vencido + b.mto_venc_trasp) > 0
      AND a.fecha_apertura <= dFechaFinTri_Ant ;
	

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
        VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha, Vid_tipo,
                Vcta_bloq_C, Vtipo_cta, 0);
       LET cCodret = '00000';
       LET cVarDataErr3 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_bloq_C||'.';
ELSE
   LET cCodret = '00102';
   LET cVarDataErr3 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                      trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla,ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0 , cCodret||cVarDataErr3);
END IF;


-------------------------------------------
--- CUENTAS NUEVAS DURANTE EL TRIMESTRE ---
-------------------------------------------
LET cCodFila = 'CNC';
LET Vtipo_cta = 'NUEVAS';



IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN

   
	 
	  --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(num_credito)
   INTO Vcta_nva_C
     FROM bdicred:sd_maecred
    WHERE empresa = '001'
      AND LEFT(num_credito,4) = cNumProducto
      AND fecha_apertura BETWEEN dFechaIniTri AND dFechaFinTri;
	 

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
           Vid_tipo, Vcta_nva_C, Vtipo_cta, 0);
       LET cCodret = '00000';
       LET cVarDataErr4 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_nva_C||'.';
ELSE
   LET cCodret = '00103';
   LET cVarDataErr4 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha2 ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha2, '', 0, cCodret||cVarDataErr4);
END IF;



-----------------------------------------------
--- CUENTAS CANCELADAS DURANTE EL TRIMESTRE ---
-----------------------------------------------
LET cCodFila = 'CCC';
LET Vtipo_cta = 'CANCELADAS';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN

		 

		
		SELECT COUNT(num_credito)
		INTO Vcta_canc_C
		FROM bdicred:sd_maecred 
		WHERE LEFT(num_credito,4) =cNumProducto
		AND status_cred IN ('FC','FF','FI','CV')
		AND fecha_apertura BETWEEN dFechaIniTri
		AND dFechaFinTri;


		 
	/*--SET ISOLATION TO DIRTY READ;
		SELECT COUNT(cr.num_credito)
		INTO Vcta_canc_C
		FROM bdicred:sd_maecred cr, bdicred:sd_maecredanexo ax
		WHERE LEFT(cr.num_credito,4) =cNumProducto
		AND left(cr.num_credito,4) = LEFT(ax.num_credito,4)
		AND cr.status_cred IN ('FC','FF','FI','CV')
		AND ax.fecha_proceso BETWEEN dFechaIniTri
		AND dFechaFinTri;*/
	  
		  

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
           Vid_tipo, Vcta_canc_C, Vtipo_cta, 0);

       LET cCodret = '00000';
       LET cVarDataErr5 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_canc_C||'.';
ELSE
   LET cCodret = '00104';
   LET cVarDataErr5 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha2 ||'.';
INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                              ultima_actualizacion,
                                              estatus_actualizacion,
                                              dias_pendientes,
                                               ultimo_error)
VALUES ('sp_mc_cie_tri', iMes, dFecha2, '', 0 , cCodret||cVarDataErr5);
END IF;


-----------------------------------------------
--- CUENTAS ACTIVAS AL FINAL DEL TRIMESTRE  ---
-----------------------------------------------
	LET cCodFila = 'CAC';
    LET Vtipo_cta = 'ACTIVAS';

--SET ISOLATION TO DIRTY READ;

    IF NOT EXISTS ( SELECT num_producto
                      FROM bdireports:rpt_mc_cta_tri
                     WHERE num_producto = cNumProducto
                       AND trimestre = cTrimestre
                       AND id_col = cCodFila
                       AND mes = iMes
                       AND fecha_reg = dFecha ) THEN

 
	  
	  SELECT COUNT(a.num_credito)
      INTO Vcta_act_CF
      FROM bdicred:sd_maecred a
	  JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
      WHERE a.empresa = '001'
      AND a.num_producto = cNumProducto
      AND a.status_cred IN ('AA','E1')
	  AND (b.monto_vencido + b.mto_venc_trasp) = 0
      AND a.fecha_apertura <=dFechaFinTri;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
          VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                  Vid_tipo, Vcta_act_CF, Vtipo_cta, 0);
       LET cCodret = '00000';
       LET cVarDataErr6 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_act_CF||'.';
ELSE
   LET cCodret = '00105';
   LET cVarDataErr6 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0 , cCodret||cVarDataErr6);
END IF;


--------------------------------------------------
--- CUENTAS BLOQUEADAS AL FINAL DEL TRIMESTRE  ---
--------------------------------------------------
LET cCodFila = 'CBC';
LET Vtipo_cta = 'BLOQUEADAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

 
	
   --SET ISOLATION TO DIRTY READ;
   SELECT COUNT(a.num_credito)
     INTO Vcta_bloq_CF
     FROM bdicred:sd_maecred a
	  JOIN bdicred:sd_maesdos b on (a.num_credito = b.num_credito)
     WHERE a.empresa = '001'
      AND a.num_producto = cNumProducto
	  AND a.status_cred IN ('BA','BT','E1','E2','E3')
	  AND (b.monto_vencido + b.mto_venc_trasp) > 0
      AND a.fecha_apertura <= dFechaFinTri;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
          VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
                  Vid_tipo, Vcta_bloq_CF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr7 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_bloq_CF||'.';
ELSE
LET cCodret = '00106';
LET cVarDataErr7 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                              ultima_actualizacion,
  estatus_actualizacion,
  dias_pendientes,
  ultimo_error)
VALUES ( 'sp_mc_cie_tri',iMes,dFecha,'', 0 ,cCodret||cVarDataErr7);
END IF;


----------------------------------------------------------------------
--- CUENTAS CON POR LO MENOS UNA TRANSACCIÓN DURANTE EL TRIMESTRE  ---
----------------------------------------------------------------------
LET cCodFila = 'CTC';
LET Vtipo_cta = 'CON AL MENOS UNA TRANSACCION';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

       IF EXISTS ( SELECT dbsname, tabname
                     FROM sysmaster:SysTabNames
                    WHERE partnum IS NOT NULL
                      AND tabname = 'total_ctas'
                      AND dbsname= 'bdireports') THEN
          DROP TABLE bdireports:total_ctas;
       END IF;

       SELECT a.numtarjeta numtarjeta,
              NVL(SUM(b.Monto325::MONEY/100),0) monto_total
         FROM intercard:tarjeta a, bditarjeta:td_movimientos_conciliacion b
        WHERE b.fechatransaccion  between FechaInicioTrimestreActual
		  AND FechafinTrimestreActual
		  AND a.numtarjeta LIKE '510148%'
          AND a.numtarjeta = b.numtarjeta
          AND a.numtarjeta NOT IN (SELECT numtarjeta FROM rpt_mc_tar_pru)
          AND b.monto325 <> 0
          --AND b.fechacarga::date BETWEEN dfechaIniTri AND dfechaFinTri
          AND b.movreversado = 'F'
          AND b.movconciliado = 'V'
          AND b.ban_bin = 'MCR'
          AND a.codstatustarjeta = 'ACT'
          AND a.codstatusasignada = 'SIA'
        GROUP BY a.numtarjeta
         INTO TEMP total_ctas WITH NO LOG;

   SELECT COUNT(*), NVL(SUM(monto_total), 0)
      INTO Vcta_tran_C, Vtot_tran_C
          FROM total_ctas;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vcta_tran_C, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr8 = 'REGISTRO EXITOSO en rpt_mc_cta_tri '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_tran_C||'.';
ELSE
   LET cCodret = '00107';
   LET cVarDataErr18 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr8);
END IF;


------------------------------------------------
--- TARJETAS ACTIVAS AL FINAL DEL TRIMESTRE  ---
------------------------------------------------
LET cCodFila = 'TAC';
    LET Vid_tipo = 'T';
LET Vtipo_cta = 'ACTIVAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

				   
	
	    SELECT 
		count(*)
		INTO Vtar_act_CF
		 FROM intercard:bitasignacionactivaciontarjeta 
		WHERE numtarjeta like '510148%'
		AND fecharegistro between FechaInicioTrimestreActual2
		AND FechafinTrimestreActual2;
	
	/*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}			   
	COUNT(numtarjeta)
	INTO Vtar_act_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date >= dFechaIniTri
	AND fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='510148'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT';	*/		   
				   
   /*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
	COUNT(numtarjeta)
	INTO Vtar_act_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='510148'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT';*/
   
   
   /*SELECT COUNT(numtarjeta)
     INTO Vtar_act_CF
     FROM intercard:tarjeta
    WHERE LEFT(numtarjeta,6)='510148'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT'
      AND fechaasignacion <=dFechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
          Vid_tipo, Vtar_act_CF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr9 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_act_CF||'.';
ELSE
   LET cCodret = '00108';
   LET cVarDataErr9 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr9);
END IF;


------------------------------------------------
--- TARJETAS BLOQUEADAS AL FINAL DEL TRIMESTRE  ---
------------------------------------------------
LET cCodFila = 'TBC';
    LET Vtipo_cta = 'BLOQUEADAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestreC
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

   
			SELECT COUNT(*)
			INTO Vtar_bloq_CF
			FROM intercard:bitacoracambiosstatustarjeta 
			WHERE tarjeta like '510148%'
			AND fechahora between  FechaInicioTrimestreActual
			AND FechafinTrimestreActual
			AND codstatustarjetanvo='BLT';
   
	/*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}	
	COUNT(numtarjeta)
	INTO Vtar_bloq_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date >= dFechaIniTri
	AND fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='510148'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/
	  
	  
   /*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
	COUNT(numtarjeta)
	INTO Vtar_bloq_CF
     FROM intercard:tarjeta
    WHERE fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='510148'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/
   
   
   /*SELECT COUNT(numtarjeta)
     INTO Vtar_bloq_CF
     FROM intercard:tarjeta
    WHERE LEFT(numtarjeta,6)='510148'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO'
      AND fechaasignacion::date <=dFechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
    VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
            Vid_tipo, Vtar_bloq_CF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr10 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_bloq_CF||'.';
ELSE
   LET cCodret = '00109';
   LET cVarDataErr10 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ( 'sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr10);
END IF;



/*-----------------------------------------------
----# INICIA CÁLCULO DE TOTALES DE DÉBITO 2400#----
-----------------------------------------------
    ----------------------------------------------
--- CUENTAS AL INICIO DEL TRIMESTRE ACTIVAS ---
-----------------------------------------------*/
LET cCodFila = 'CAD';
LET cNumProducto = '2400';
LET Vid_tipo = 'C';
LET Vtipo_cta = 'ACTIVAS';
LET VCod_Deb = '1';

-----------COSTO ELEVADO
IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

	  
	  SELECT COUNT(b.cuenta) 
		INTO Vcta_act_D	
		FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b 
		WHERE a.cuenta=b.cuenta
		AND a.producto='2400'
		AND a.status_cta =VCod_Deb
		AND fec_ult_mov <= dFechaFinTri_Ant;
	  
	  
	  	/*SELECT COUNT(b.cuenta) 
		INTO Vcta_act_D	
		FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b 
		WHERE b.empresa='001'
		AND b.cuenta=a.cuenta
		AND b.fecha_alta dFechaIniTri_Ant 
		AND b.fecha_alta <=dFechaFinTri_Ant
		AND a.producto='2400'
		AND a.status_cta =VCod_Deb;*/
	  
	  
	/*SELECT COUNT(num_credito)
    INTO Vcta_act_D
     FROM bdicred:sd_maecred
    WHERE empresa = '001'
      AND SUBSTRING(num_credito FROM 1 FOR 4) = cNumProducto
      AND status_cred = 'AA'
      AND fecha_apertura <=dFechaFinTri_Ant;*/
	  
	  
	 /*SELECT COUNT(chq.cuenta)
     INTO Vcta_act_D
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
	 WHERE empresa='001'
	  AND chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND noc.fecha_alta::date >=dFechaIniTri_Ant
	  AND noc.fecha_alta::date <= dFechaFinTri_Ant
      AND chq.status_cta = VCod_Deb;*/
	  
	  
   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
       VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
               Vid_tipo, Vcta_act_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr11 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_act_D||'.';
ELSE
   LET cCodret = '00110';
   LET cVarDataErr11 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr11);
END IF;


/*--------------------------------------------------
--- CUENTAS AL INICIO DEL TRIMESTRE BLOQUEADAS ---
--------------------------------------------------*/
LET cCodFila = 'CBD';
LET Vid_tipo = 'C';
LET Vtipo_cta = 'BLOQUEADAS';
LET VCod_Deb = '3';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

   
	 
	 
	   SELECT COUNT(b.cuenta) 
		INTO Vcta_bloq_D
		FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b 
		WHERE a.cuenta=b.cuenta
		AND a.producto='2400'
		AND a.status_cta =VCod_Deb
		AND fec_ult_mov <= dFechaFinTri_Ant;
	 
	 
	 /*SELECT COUNT(*)
     INTO Vcta_bloq_D
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
      WHERE chq.cuenta=noc.cuenta
	  AND chq.producto = cNumProducto
	  --AND noc.empresa='001'
	  --AND noc.cuenta = chq.cuenta
	  AND noc.fecha_alta between dFechaIniTri_Ant
	  AND dFechaFinTri_Ant
      AND chq.status_cta = VCod_Deb;*/
	  
	 /*SELECT COUNT(chq.cuenta)
     INTO Vcta_bloq_D
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
    WHERE chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND noc.fecha_alta::date >=dFechaIniTri_Ant
	  AND noc.fecha_alta::date <= dFechaFinTri_Ant
      AND chq.status_cta = VCod_Deb;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vcta_bloq_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr12 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_bloq_D||'.';
ELSE
   LET cCodret = '00112';
   LET cVarDataErr12 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr12);
END IF;

-------------------------------------------
--- CUENTAS NUEVAS DURANTE EL TRIMESTRE ---
-------------------------------------------
LET cCodFila = 'CND';
LET Vtipo_cta = 'NUEVAS';

--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN

   
     SELECT COUNT(a.cuenta) 
		INTO Vcta_nva_D	
		FROM   bdicheq:sc_maechq a,bdicheq:sc_maenoc b
		WHERE a.cuenta=b.cuenta
		AND a.producto='2400'
		AND a.status_cta ='1'
		AND b.fecha_alta between dFechaIniTri
		AND dFechaFinTri;
   
   
   
   /*SELECT COUNT(chq.cuenta)
     INTO Vcta_nva_D
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
    WHERE chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND noc.fecha_alta BETWEEN dfechaIniTri AND dfechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
           Vid_tipo, Vcta_nva_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr13 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_nva_D||'.';
ELSE
   LET cCodret = '00113';
   LET cVarDataErr13 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha2, '', 0, cCodret||cVarDataErr13);
END IF;

 -----------------------------------------------
--- CUENTAS CANCELADAS DURANTE EL TRIMESTRE ---
-----------------------------------------------
LET cCodFila = 'CCD';
LET Vtipo_cta = 'CANCELADAS';
LET VCod_Deb = '2';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN

				   
	   SELECT COUNT(b.cuenta) 
		INTO Vcta_canc_D
		FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b 
		WHERE a.cuenta=b.cuenta
		AND a.producto='2400'
		AND a.status_cta =VCod_Deb
		AND fec_ult_mov between dFechaIniTri
		AND dFechaFinTri;
				   
   /*--SET ISOLATION TO DIRTY READ;
   SELECT COUNT(chq.cuenta)
     INTO Vcta_canc_D
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
    WHERE chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND noc.fecha_alta BETWEEN dfechaIniTri AND dfechaFinTri
      AND chq.status_cta = VCod_Deb;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre, id_col,
                                          mes, fecha_reg, id_tipo,
                                          total_cuentas, tipo_cuenta,
                                          id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
        Vid_tipo, Vcta_canc_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr14 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_canc_D||'.';
ELSE
   LET cCodret = '00114';
   LET cVarDataErr14 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0 , cCodret||cVarDataErr14);
END IF;


----------------------------------------------
--- CUENTAS AL FINAL DEL TRIMESTRE ACTIVAS ---
-----------------------------------------------
LET cCodFila = 'CAD';
LET cNumProducto = '2400';
LET Vid_tipo = 'C';
LET Vtipo_cta = 'ACTIVAS';
LET VCod_Deb = '1';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

	  
	SELECT COUNT(b.cuenta) 
		INTO Vcta_act_DF	
		FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b 
		WHERE a.cuenta=b.cuenta
		AND a.producto='2400'
		AND a.status_cta =VCod_Deb;
		--AND a.fec_ult_mov <= dFechaFinTri ;
	  
	  
	  
	  /*--SET ISOLATION TO DIRTY READ;
   SELECT COUNT(chq.cuenta)
     INTO Vcta_act_DF
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
    WHERE chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND noc.fecha_alta between dfechaIniTri
	  AND dFechaFinTri
      AND chq.status_cta = VCod_Deb;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vcta_act_DF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr15 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_act_DF||'.';
ELSE
   LET cCodret = '00115';
   LET cVarDataErr15 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr15);
END IF;

-------------------------------------------------
--- CUENTAS AL FINAL DEL TRIMESTRE BLOQUEADAS ---
-------------------------------------------------
LET cCodFila = 'CBD';
LET Vid_tipo = 'C';
LET Vtipo_cta = 'BLOQUEADAS';
LET VCod_Deb = '3';

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN
	  
	  
	SELECT COUNT(b.cuenta) 
		INTO Vcta_bloq_DF	
		FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b 
		WHERE a.cuenta=b.cuenta
		AND a.producto='2400'
		AND a.status_cta =VCod_Deb;
		--AND fec_ult_mov <= dFechaFinTri ;
 
	 /*SELECT COUNT(num_credito)
	 INTO Vcta_bloq_DF
     FROM bdicred:sd_maecred
     WHERE empresa = '001'
      AND SUBSTRING(num_credito FROM 1 FOR 4) = cNumProducto
	  AND status_cred IN('BA','BT')
      AND fecha_apertura <= dFechaFinTri;*/
	  
	  /*--SET ISOLATION TO DIRTY READ;
   SELECT COUNT(chq.cuenta)
     INTO Vcta_bloq_DF
     FROM bdicheq:sc_maenoc noc, bdicheq:sc_maechq chq
    WHERE chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND noc.fecha_alta <= dfechaFinTri
      AND chq.status_cta = VCod_Deb;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vcta_bloq_DF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr16 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_bloq_DF||'.';
ELSE
   LET cCodret = '00116';
   LET cVarDataErr16 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr16);
END IF;

----------------------------------------------------------------------
--- CUENTAS CON POR LO MENOS UNA TRANSACCIÓN DURANTE EL TRIMESTRE  ---
----------------------------------------------------------------------
LET cCodFila = 'CTD';
LET Vtipo_cta = 'CON AL MENOS UNA TRANSACCION';


		
					
--SET ISOLATION TO DIRTY READ;

IF NOT EXISTS ( SELECT num_producto
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

				SELECT COUNT(*)
					INTO Vcta_tran_D
					FROM bdicheq:sc_maenoc noc,bdicheq:sc_maechq chq,bdicheq:sc_tarjeta tar
					WHERE chq.cuenta = noc.cuenta
					AND chq.cuenta=tar.cuenta
					AND chq.producto = cNumProducto			  
					AND chq.fec_ult_mov between dfechaIniTri
					AND dfechaFinTri;
	   
   
  /*SELECT COUNT(*)
     INTO Vcta_tran_D
     FROM bdicheq:sc_maenoc noc,bdicheq:sc_maechq chq,bdicheq:sc_tarjeta tar
	 WHERE chq.cuenta = noc.cuenta
      AND chq.producto = cNumProducto
      AND chq.cuenta = tar.cuenta
	  AND tar.num_tarjeta IN (SELECT b.numtarjeta
                                FROM  bditarjeta:td_movimientos_conciliacion b,intercard:tarjeta a     
                                WHERE  b.fechatransaccion between FechaInicioTrimestreActual
								 AND FechafinTrimestreActual
								AND b.numtarjeta = a.numtarjeta
								 AND archivo_origen  = 'VNC'
								 AND movreversado IN ('F','V')
								 AND movconciliado = 'V'
                                 AND b.monto325 <> 0
								 --AND b.fechacarga::date BETWEEN dfechaIniTri
                                 --AND dfechaFinTri
                                 AND a.codstatustarjeta = 'ACT'
                                 AND a.codstatusasignada = 'SIA');
		

	SELECT COUNT(*)
	INTO Vcta_tran_D
		 FROM bdicheq:sc_maenoc noc,bdicheq:sc_maechq chq,bdicheq:sc_tarjeta tar
			 WHERE chq.cuenta = noc.cuenta
			  AND chq.cuenta=tar.cuenta
			  AND chq.producto = cNumProducto			  
			  AND chq.fec_ult_mov between dfechaIniTri
			  AND dfechaFinTri*/
		 

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vcta_tran_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr17 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_tran_D||'.';
ELSE
   LET cCodret = '00117';
   LET cVarDataErr17 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr17);
END IF;


------------------------------------------------
--- TARJETAS ACTIVAS AL INICIO DEL TRIMESTRE  ---
------------------------------------------------
LET cCodFila = 'TAD';
LET Vid_tipo = 'T';
LET Vtipo_cta = 'ACTIVAS';

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

	  
		SELECT 
		count(*) 
		INTO Vtar_act_D
		FROM intercard:bitasignacionactivaciontarjeta
		WHERE numtarjeta like '559471%'
		AND fecharegistro between FechaInicioTrimestreAnterior2
		AND FechafinTrimestreAnterior2;
	  
	  
	  /*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}
		COUNT(numtarjeta)
		INTO Vtar_act_D
		FROM intercard:tarjeta
	  WHERE fechaasignacion::date >= dFechaIniTri_Ant
	AND fechaasignacion::date <= dFechaFinTri_Ant
		  AND LEFT(numtarjeta,6)='559471'
		  AND codstatusasignada = 'SIA'
		  AND codstatustarjeta = 'ACT';*/
	  
	  /*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
		COUNT(numtarjeta)
		INTO Vtar_act_D
		FROM intercard:tarjeta
		WHERE fechaasignacion::date <= dFechaFinTri_Ant
		  AND LEFT(numtarjeta,6)='559471'
		  AND codstatusasignada = 'SIA'
		  AND codstatustarjeta = 'ACT';*/
		  
	  
	  --SET ISOLATION TO DIRTY READ;
   /*SELECT COUNT(numtarjeta)
     INTO Vtar_act_D
     FROM intercard:tarjeta
    WHERE SUBSTRING(numtarjeta FROM 1 for 6) IN ('559471')
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT'
      AND fechaasignacion::date <= dFechaFinTri_Ant;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vtar_act_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr18 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vcta_act_D||'.';
ELSE
   LET cCodret = '00118';
   LET cVarDataErr18 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr18);
END IF;

----------------------------------------------------
--- TARJETAS BLOQUEADAS AL INICIO DEL TRIMESTRE  ---
----------------------------------------------------
LET cCodFila = 'TBD';
LET Vid_tipo = 'T';
LET Vtipo_cta = 'BLOQUEADAS';

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN
	  
	
	
	     SELECT COUNT(*)
		 INTO Vtar_bloq_D
			FROM intercard:bitacoracambiosstatustarjeta 
			WHERE tarjeta like '559471%'
			AND fechahora between  FechaInicioTrimestreAnterior
			AND FechafinTrimestreAnterior 
			AND codstatustarjetanvo='BLT';
	
	/*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}
	COUNT(numtarjeta)
	 INTO Vtar_bloq_D
     FROM intercard:tarjeta
    WHERE fechaasignacion::date >= dFechaIniTri_Ant
	AND fechaasignacion::date <= dFechaFinTri_Ant
      AND LEFT(numtarjeta,6)='559471'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/
	 
	/*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
		COUNT(numtarjeta)
	 INTO Vtar_bloq_D
     FROM intercard:tarjeta
    WHERE fechaasignacion::date <= dFechaFinTri_Ant
      AND LEFT(numtarjeta,6)='559471'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/


	 
	  /*SELECT COUNT(numtarjeta)
     INTO Vtar_bloq_D
     FROM intercard:tarjeta
    WHERE SUBSTRING(numtarjeta FROM 1 for 6) IN ('559471')
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO'
      AND fechaasignacion::date <= dFechaFinTri_Ant;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vtar_bloq_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr19 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_bloq_D||'.';
ELSE
   LET cCodret = '00119';
   LET cVarDataErr19 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                     trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ( 'sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr19);
END IF;


---------------------------------------------
--- TARJETAS NUEVAS DURANTE EL TRIMESTRE  ---
---------------------------------------------
LET cCodFila = 'TND';
LET Vid_tipo = 'T';
LET Vtipo_cta = 'NUEVAS';

IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha2 ) THEN
			   
		
	SELECT 
		count(*) 
		INTO Vtar_nvas_D
		FROM intercard:bitasignacionactivaciontarjeta 
		WHERE numtarjeta like '559471%'
		AND fecharegistro between FechaInicioTrimestreActual2
		AND FechafinTrimestreActual2;
		
				   
   /*--SET ISOLATION TO DIRTY READ;
   SELECT COUNT(numtarjeta)
     INTO Vtar_nvas_D
     FROM intercard:tarjeta
    WHERE SUBSTRING(numtarjeta FROM 1 FOR 6) = '559471'
      AND fechaasignacion BETWEEN dfechaIniTri AND dfechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
    VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha2,
            Vid_tipo, Vtar_nvas_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr20 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_nvas_D||'.';
ELSE
   LET cCodret = '00120';
   LET cVarDataErr20 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ( 'sp_mc_cie_tri', iMes, dFecha2, '', 0, cCodret||cVarDataErr20);
END IF;



------------------------------------------------
--- TARJETAS ACTIVAS AL FINAL DEL TRIMESTRE  ---
------------------------------------------------
LET cCodFila = 'TAD';
LET Vid_tipo = 'T';
LET Vtipo_cta = 'ACTIVAS';

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

	  
		
		SELECT 
		count(*) 
		INTO Vtar_act_DF
		FROM intercard:bitasignacionactivaciontarjeta
		WHERE numtarjeta like '559471%'
		AND fecharegistro between FechaInicioTrimestreActual2
		AND FechafinTrimestreActual2;
		
		/*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}
		COUNT(numtarjeta)
		INTO Vtar_act_DF
		FROM intercard:tarjeta
		WHERE fechaasignacion::date >= dFechaIniTri
	    AND fechaasignacion::date <= dFechaFinTri
		AND LEFT(numtarjeta,6)='559471'
		AND codstatusasignada = 'SIA'
		AND codstatustarjeta = 'ACT';*/
	  
	  
	  
		/*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
		COUNT(numtarjeta)
		INTO Vtar_act_DF
		FROM intercard:tarjeta
		WHERE fechaasignacion::date <= dFechaFinTri
		AND LEFT(numtarjeta,6)='559471'
		AND codstatusasignada = 'SIA'
		AND codstatustarjeta = 'ACT';*/


	--SET ISOLATION TO DIRTY READ;
   /*SELECT COUNT(numtarjeta)
     INTO Vtar_act_DF
     FROM intercard:tarjeta
    WHERE SUBSTRING(numtarjeta FROM 1 for 6) IN ('559471')
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'ACT'
      AND fechaasignacion::date <= dFechaFinTri;*/
	  

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vtar_act_DF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr21 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_act_DF||'.';
ELSE
   LET cCodret = '00121';
   LET cVarDataErr21 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                       trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr21);
END IF;



----------------------------------------------------
--- TARJETAS BLOQUEADAS AL FINAL DEL TRIMESTRE  ---
----------------------------------------------------
LET cCodFila = 'TBD';
    LET Vid_tipo = 'T';
LET Vtipo_cta = 'BLOQUEADAS';

    IF NOT EXISTS ( SELECT num_producto FROM bdireports:rpt_mc_cta_tri
                     WHERE num_producto = cNumProducto
                       AND trimestre = cTrimestre
                       AND id_col = cCodFila
                       AND mes = iMes
                       AND fecha_reg = dFecha ) THEN

	  
	  
	    SELECT COUNT(*)
		 INTO Vtar_bloq_DF
			FROM intercard:bitacoracambiosstatustarjeta 
			WHERE tarjeta like '559471%'
			AND fechahora between  FechaInicioTrimestreActual
			AND FechafinTrimestreActual 
			AND codstatustarjetanvo='BLT';
	  
	  /*SELECT {+index(intercard:tarjeta idx_fechaasignacion_tarjeta)}
	  COUNT(numtarjeta)
	  INTO Vtar_bloq_DF
      FROM intercard:tarjeta
      WHERE fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='559471'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/
	  
	  /*SELECT {+index(intercard:tarjeta idx_tarjeta1)}
	  COUNT(numtarjeta)
	  INTO Vtar_bloq_DF
      FROM intercard:tarjeta
      WHERE fechaasignacion::date <= dFechaFinTri
      AND LEFT(numtarjeta,6)='559471'
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO';*/
	  
	  /*SELECT COUNT(numtarjeta)
     INTO Vtar_bloq_DF
     FROM intercard:tarjeta
    WHERE SUBSTRING(numtarjeta FROM 1 for 6) IN ('559471')
      AND codstatusasignada = 'SIA'
      AND codstatustarjeta = 'BLO'
      AND fechaasignacion::date <= dFechaFinTri;*/

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vtar_bloq_DF, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr22 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_bloq_DF||'.';
ELSE
   LET cCodret = '00122';
   LET cVarDataErr22 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
   VALUES ( 'sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr22);
END IF;



-------------------------------------------------------------------
--- TARJETAS CON AL MENOS UNA TRANSACCION DURANTE EL TRIMESTRE  ---
-------------------------------------------------------------------

LET cCodFila = 'TTD';
LET Vid_tipo = 'T';
LET Vtipo_cta = 'CON AL MENOS UNA TRANSACCION';

IF NOT EXISTS ( SELECT num_producto 
                  FROM bdireports:rpt_mc_cta_tri
                 WHERE num_producto = cNumProducto
                   AND trimestre = cTrimestre
                   AND id_col = cCodFila
                   AND mes = iMes
                   AND fecha_reg = dFecha ) THEN

   IF EXISTS ( SELECT dbsname, tabname
                 FROM sysmaster:SysTabNames
                WHERE partnum IS NOT NULL
                  AND tabname = 'valida_trjs_D'
                  AND dbsname= 'bdireports') THEN
      DROP TABLE bdireports:valida_trjs_D;
   END IF;


   SELECT a.numtarjeta numtarjetaD,
          NVL(SUM(b.Monto325::MONEY/100), 0) total_tjsD
     FROM intercard:tarjeta a, bditarjeta:td_movimientos_conciliacion b
      WHERE b.fechatransaccion between FechaInicioTrimestreActual
	  AND FechafinTrimestreActual
	  AND a.numtarjeta like '559471%'
      AND a.numtarjeta = b.numtarjeta
      AND b.monto325 <> 0
	  --AND b.fechacarga::date BETWEEN dfechaIniTri AND dfechaFinTri
      --AND b.movreversado = 'F'
      AND b.movconciliado = 'V'
      AND b.ban_bin = 'MDE'
      AND a.codstatustarjeta = 'ACT'
      AND a.codstatusasignada = 'SIA'
    GROUP BY a.numtarjeta
     INTO TEMP valida_trjs_D WITH NO LOG;

   SELECT COUNT(*), NVL(SUM(total_tjsD), 0)
     INTO Vtar_tran_D, Vtot_tran_D
     FROM valida_trjs_D;

   --Inserta en la base de datos
   INSERT INTO bdireports:rpt_mc_cta_tri (num_producto, trimestre,
                                          id_col, mes, fecha_reg,
                                          id_tipo, total_cuentas,
                                          tipo_cuenta, id_reporte)
   VALUES (cNumProducto, cTrimestre, cCodFila, iMes, dFecha,
           Vid_tipo, Vtar_tran_D, Vtipo_cta, 0);
   LET cCodret = '00000';
   LET cVarDataErr23 = 'REGISTRO EXITOSO en rpt_mc_cta_trim '||trim(cCodFila)||' '||trim(cTrimestreC)||' Tot: '||Vtar_tran_D||'.';
ELSE
   LET cCodret = '00123';
   LET cVarDataErr23 = '.DATOS DUPLICADOS: '||trim(cCodFila)|| ','||
                        trim(cNumProducto)||','|| dFecha ||'.';
   INSERT INTO bdireports:rpt_param_reportevisa (nom_tabla, ultimo_mes,
                                                 ultima_actualizacion,
                                                 estatus_actualizacion,
                                                 dias_pendientes,
                                                 ultimo_error)
    VALUES ('sp_mc_cie_tri', iMes, dFecha, '', 0, cCodret||cVarDataErr23);
END IF;


LET cVarDataErr = trim(cVarDataErr2)||trim(cVarDataErr3)||
                  trim(cVarDataErr4)||trim(cVarDataErr5)||
                  trim(cVarDataErr6)||trim(cVarDataErr7)||
                  trim(cVarDataErr8)||trim(cVarDataErr9)||
                  trim(cVarDataErr10)||trim(cVarDataErr11)||
                  trim(cVarDataErr12)||trim(cVarDataErr13)||
                  trim(cVarDataErr14)||trim(cVarDataErr15)||
                  trim(cVarDataErr16)||trim(cVarDataErr17)||
                  trim(cVarDataErr18)||trim(cVarDataErr19)||
                  trim(cVarDataErr20)||trim(cVarDataErr21)||
                  trim(cVarDataErr22)||trim(cVarDataErr23);

RETURN cCodret,cVarDataErr;

END PROCEDURE;