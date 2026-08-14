Create Procedure "informix".sp_rptpagarerisk()

    Returning char(5);

    Define vFecha_hoy date;
    Define vCodRet char(5);
    Define vSqlErr integer;
    Define vsql Char(500);
    Define v_directorio Char(30);

      -- Inicializa Variables de Salida
      Let vCodRet = "000";

      Begin
            On Exception Set vSqlErr
                    If vSqlErr <> 0 Then
                            Let  vCodRet = vSqlErr;
                            Return  vCodRet;
                    End If
            End Exception;               

            --Set Debug File To "/tmp/sp_RptPagareRisk.out"; 
            --Trace On;

            If exists( Select dbsname, tabname From sysmaster:systabnames  Where tabname = 'sv_rptpagarerisk' ) Then
                    Drop Table sv_rptpagarerisk;
            End If;

            Create Table bdinvers:sv_rptpagarerisk (tipo_intrum char(10),
													fecha_inicio date,
													fecha_vence date,
													tasa_pactada decimal(9,6),
													dias_x_vencer char(4),
													dias_trancurridos char(4),
													monto decimal(11,3),
                                                                              interes decimal(9,3),
                                                                              --isr decimal(9,3),
													plazo char(4));

            Select fecha_hoy into vFecha_hoy From sv_fechas;									

            Insert Into sv_rptpagarerisk	
            Select 'PAGARE' tipo_Instrum, fecha_alta, fecha_venc, nvl(tasa,0) tasa, 
                            ( fecha_venc - vFecha_hoy ) dias_x_vencer, 
                            ( vFecha_hoy - fecha_alta ) dias_transcurridos, 
                            nvl(capital,0) capital, 
                            --nvl(sdo_mes_ant - sdo_ult_corte, 0) interes,
                            nvl(sdo_mes_ant, 0) interes,
                            --nvl(sdo_ult_corte,0) isr,
                            nvl(plazo, 0)
            From bdinvers:sv_maeinv
            Where status_cta = 1;

        Let v_directorio   =  "/tmp/rptpagarerisk.txt";  
        Let vsql = ''; 

        Let  vsql = 'echo "UNLOAD TO '   || (v_directorio) || 
        ' Select tipo_intrum,  to_char(fecha_inicio, ''' || '%Y/%m/%d' || ''' ),  to_char(fecha_vence, ''' || '%Y/%m/%d' || ''' ), tasa_pactada, dias_x_vencer, dias_trancurridos, monto, interes, plazo FROM bdinvers:sv_rptpagarerisk" > /tmp/query.sql';
                                    --' SELECT * FROM bdinvers:sv_ocimn" > /tmp/query.sql';  
        SYSTEM vsql;
        Let vsql = '';
        Let vsql = "dbaccess bdinvers /tmp/query.sql ";

        SYSTEM vsql;
        Drop Table bdinvers:sv_rptpagarerisk;

        Return  vCodRet;
    End;
End Procedure;