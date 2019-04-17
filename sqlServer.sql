altas complejas Xml
----

ALTER procedure [dbo].[TipoTickets_IU]
@doc text,
@sesion text
as
-- Generado autom�gicamente por FrameworkGen 2.0.0.1 el lunes, 30 de mayo de 2016 17:25:25
-- Por GOBIERNO\ynunez en INFOR30

declare @cdTipoOperacion bigint=1

declare @cdResultado bigint

exec Framework..LogAccesos_S @sesion,@cdResultado OUTPUT

if @cdResultado=1
 begin
	declare @idoc int

	exec sp_xml_preparedocument @idoc output, @doc
	-- Execute a SELECT statement using OPENXML rowset provider.
	select *
	  into #NewReg
	  from OPENXML (@idoc, '/rowset/row',1)
	  with ([cdTipoTicket] int,
             [dsTipoTicket] varchar (200),
             [vlValor] decimal,
	     [icIndividual]   smallint,
	     [vlDiasValidez] smallint,
  [cdModalidadVenta] int
	         )

	  exec sp_xml_removedocument @idoc

	declare @n_id int
	declare @NuevosId table (Id int, Op char(1))

	   update [TipoTickets]
		  set [dsTipoTicket]=N.[dsTipoTicket],
          [vlValor]=N.[vlValor],
		[icIndividual]=N.[icIndividual],
		  [vlDiasValidez]=n.[vlDiasValidez]
         
			  OUTPUT inserted.[cdTipoTicket] ,'U'
			  into @NuevosId
		 from #NewReg N
		where [TipoTickets].[cdTipoTicket]=N.[cdTipoTicket]
	   
	   if(@@rowcount>0) 
	      set @cdTipoOperacion=3
	   	   
		 insert [TipoTickets]
				  ([dsTipoTicket],
              [vlValor],
		    [icIndividual],
		    [vlDiasValidez],
		    [cdModalidadVenta])
				  OUTPUT inserted.[cdTipoTicket] ,'I'
				  into @NuevosId
		   select [dsTipoTicket],
              [vlValor],
		    [icIndividual],
		    [vlDiasValidez],
		    [cdModalidadVenta]
            
			 from #NewReg N
			where ISNULL(N.[cdTipoTicket],0)=0

	drop table #NewReg   
	    
	select * from @NuevosId		
end

exec Framework..LogOperaciones_IU_S @sesion,@doc,1,@cdResultado,'TipoTickets_IU'

 If @cdResultado<> 1
   begin
      declare @dsMensaje varchar(200)
	  
       Select @dsMensaje= dsResultado
         from Framework..Resultados 
        where cdResultado=@cdResultado
	         
		RAISERROR(@dsMensaje,17,1)
   end



   ALTER procedure [dbo].[VentasMensual_IU]
      @doc    TEXT,
      @sesion TEXT
AS
   -- Generado autom�gicamente por FrameworkGen 2.0.0.1 el jueves, 26 de mayo de 2016 15:57:47
     -- Por GOBIERNO\ynunez en INFOR30

     DECLARE @cdTipoOperacion BIGINT = 1;
     DECLARE @cdResultado BIGINT;
     EXEC Framework..LogAccesos_S
          @sesion,
          @cdResultado OUTPUT;
     IF @cdResultado = 1
         BEGIN
             DECLARE @idoc INT;
             EXEC sp_xml_preparedocument
                  @idoc OUTPUT,
                  @doc;
             -- Execute a SELECT statement using OPENXML rowset provider.
             SELECT * INTO #NewReg
             FROM OPENXML(@idoc, '/rowset/row', 1) WITH([cdTicket] INT, 
		   [cdTipoTicket] INT, [vlValor] INT, [cdUsuario] INT,[cdFuncionario] INT, [cdModalidadVenta] int , [cdPerfil] int ,
		   [icRetiro] int ,[dtRetiro] datetime);
         
             
          
			      EXEC sp_xml_removedocument
                  @idoc;
	   ----Fecha Validez



             DECLARE @n_id INT;
             DECLARE @NuevosId TABLE( Id INT,
                                      Op CHAR(1));
             DECLARE @cdTransaccion NUMERIC(18, 0) = 1;
             SET @cdTransaccion = ( SELECT MAX(cdTransaccion) + 1
                                    FROM Tickets );
           

		  
           INSERT [Tickets]
                    ( [cdTipoTicket],				 
                      [vlValor],
                      [dtTicket],
                      [cdUsuario],
                      [dtValidez],
                      [cdTransaccion],
				  [cdFuncionario],				
				  [cdModalidadVenta],
				  [cdPerfil],
				  icRetiro,
				  dtRetiro,
				  cdUsuarioEntrega

				  
                    )
             OUTPUT inserted.[cdTicket],
                    'I'
                    INTO @NuevosId
                    SELECT n.[cdTipoTicket],				      
                           n.[vlValor],
                           GETDATE(),
                           n.[cdUsuario],
					   GETDATE(),					 
                           ISNULL(@cdTransaccion, 1),
					   n.[cdFuncionario],
					   N.cdModalidadVenta,
					   N.cdPerfil,
					   1,
					   GETDATE(),
					     n.[cdUsuario]
                    FROM #NewReg N
                     
                    WHERE ISNULL(N.[cdTicket], 0) = 0
                 

      


		   if (   SELECT count(*)  FROM @NuevosId)=0
		   BEGIN
		      RAISERROR( 'Error al intentar grabar', 17, 1 );
		   END
		   Else
		   BEGIN

		    Declare @vlMontoTotal decimal(18,2)
	   declare @vlPagos decimal(18,2)


	   Select @vlMontoTotal=Sum(ISNULL(vlImporte,0))
	   FROM Tickets
	   Where cdFuncionario in (select cdFuncionario from #NewReg)
	   and icBaja=0

	    Select @vlPagos=Sum(ISNULL(vlImporte,0))
	   FROM PagoCuentaCorriente
	   Where cdFuncionario in (select cdFuncionario from #NewReg)




	  

			 insert [PagoCuentaCorriente]
				  ([dtPagoCuentaCorriente],
              [cdFuncionario],
              [vlImporte],
              [cdUsuario],
		     [cdPerfil] ,
			[vlSaldoInicial])
			
		   select GETDATE(),
              [cdFuncionario],
              N.vlValor,
              N.[cdUsuario],
		    N.[cdPerfil] ,
			ISNULL(@vlMontoTotal,0) - ISNULL( @vlPagos,0)
			 from #NewReg N
		
			  


		        SELECT *
                  FROM @NuevosId;
		   END

          
         END;
             EXEC Framework..LogOperaciones_IU_S
                  @sesion,
                  @doc,
                  1,
                  @cdResultado,
                  'VentasMensual_IU';
             IF @cdResultado <> 1
                 BEGIN
                     DECLARE @dsMensaje VARCHAR(200);
                     SELECT @dsMensaje = dsResultado
                     FROM Framework..Resultados
                     WHERE cdResultado = @cdResultado;
                     RAISERROR( @dsMensaje, 17, 1 );
                 END;








----

ALTER procedure [dbo].[VENTASTICKETS_F]
@doc text= null 
as
declare @idoc int

exec sp_xml_preparedocument @idoc output, @doc
select 
		  TRY_CONVERT(datetime,[dtDesde],103) as [dtDesde],
		  TRY_CONVERT(datetime,[dtHasta],103) as [dtHasta],
		    [cdModalidadVenta]

  into #NewReg
  from OPENXML (@idoc, '/rowset/row',1)
  with (      [dtDesde] varchar(20),
	         [dtHasta] varchar(20),
		    [cdModalidadVenta] varchar(100)
	 )
  
  exec sp_xml_removedocument @idoc



  create table #tmp_ModalidadVenta
([cdModalidadVenta] smallint)

insert #tmp_ModalidadVenta
select convert(smallint,word) as [cdModalidadVenta]
  from dbo.split((select max([cdModalidadVenta]) from #NewReg),',')



select 
       dsTipoTicket as [Menu],
	 sum(  e.vlCantidad)
		   
	   [Cantidad Vendida],
	  Sum( e.vlImporte ) as [Importe]




INTO #TEMP
  from  TipoTickets tt
  inner join Tickets e  on e.cdTipoTicket=tt.cdTipoTicket
  left join #tmp_ModalidadVenta mv on
  mv.cdModalidadVenta=e.cdModalidadVenta
  ,
       #NewReg NR   
 where (convert(date,E.[dtTicket]) >=  NR.dtDesde or NR.dtDesde is null)
   and (convert(date,E.[dtTicket]) <= NR.dtHasta or NR.dtHasta is null)
   and (e.cdModalidadVenta =mv.cdModalidadVenta or NR.[cdModalidadVenta] is null )
   and(e.icBaja=0)

   GROUP BY dsTipoTicket



   Select * from #TEMP


   SELECT '<strong>Totales</strong>' as Total,
          SUM([Cantidad Vendida]),
		  SUM( [Importe])
     FROM #TEMP
   





*---------------------
Dependiente

ALTER PROCEDURE [dbo].[AddElemento2]
	@cdElemento bigint,
	@dsNombre varchar(120),
	@dsCateg varchar(10),
	@cdPresentacion int,
	@vlMagnitud decimal(18,2),
	@dsCodigoONC varchar(20),
	@vlStMinimo decimal(18,2),
	@cdManejaVto smallint, 
	@cdBaja int,
	@cdFraccionable smallint,
	@cdUnidadPresentacion int,
	@dsMarca Varchar(200)=null,
	@cdMarca  int =null,
	@cdUsuario int


--@cdMarca bigint=null
AS
	declare @ValidarCodigoONC as smallint
	declare @UnirCadena as varchar(150)
	declare @NombreUnidad as varchar(100)
	declare @NombrePresentacion as varchar(100)
	declare @vlMagnitudMin as decimal(18,2)
	declare @vlCantDiv as decimal(18,2)
	declare @vlCantDiv2 as int

SET NOCOUNT ON

If (@dsCodigoONC='')
	set @validarCodigoONC=0


select @vlMagnitudMin=vlFactorStock*@vlMagnitud from Unidades
where cdUnidad=@cdUnidadPresentacion 

/*set @validarCodigoONC=(select count(*) from elementos 
			where cdElemento<>@cdElemento and 
			dsCodigoONC=@dsCodigoONC and
			dsCodigoONC<>'' and cdBaja=-1)*/
if @cdElemento is NULL
set @validarCodigoONC=(select count(*) from elementos where dsCodigoONC=@dsCodigoONC and
			dsCodigoONC<>'' and cdBaja=-1)
else
set @validarCodigoONC=(select count(*) from elementos where cdElemento<>@cdElemento and 
			dsCodigoONC=@dsCodigoONC and dsCodigoONC<>'' and cdBaja=-1)

If (@validarCodigoONC>0)
Begin 
	RAISERROR('Ya existe un elemento que contiene el mismo codigo ONC. No se puede Grabar',12,1)
	GOTO SALIR
End


If (@cdFraccionable=-1)
	BEGIN
 IF (select
				(
					select CAST((select Sum(vlStCantidad) from V_STOCK
					where cdElemento=@cdElemento) as decimal(18,2))
					/CAST((select vlMagnitudMin from elementos
					where cdElemento=@cdElemento) as decimal(18,2))))!=
(select 
				(
				cast((select
					(
						select CAST((select Sum(vlStCantidad) from V_STOCK
						where cdElemento=@cdElemento) as decimal(18,2))
						/CAST((select vlMagnitudMin from elementos
						where cdElemento=@cdElemento) as decimal(18,2))
					)
					) as int)))
			BEGIN
				RAISERROR('Para que no sea fraccionable el stock de mercader�a debe ser un valor entero',12,1)
				GOTO SALIR
			END 
	END

If (@cdFraccionable=-1)
	BEGIN
		If (select count(*) from PlanillasSemanalesConfig_Elementos
			where cdElemento=@cdElemento and cdUnidad <> 6) > 0 
			BEGIN
				RAISERROR('El elemento debe ser fraccionable debido a que hay planillas semanales definidas en fracciones',12,1)
				GOTO SALIR
			END
	END

/* ARMO LA CADENA QUE VA EN dsDetalleNombre*/
set @NombreUnidad=(select dsUnidad from unidades where cdUnidad=@cdUnidadPresentacion) 
set @NombrePresentacion=(select dsPresentacion from presentaciones where cdPresentacion=@cdPresentacion)
set @UnirCadena=('x ' + CAST(@vlMagnitud AS varchar) + ' ' + CAST(@NombreUnidad AS varchar) +  ' (' + @NombrePresentacion + ')')





if (@cdElemento is null)
begin

	select @cdElemento=isnull(max(cdElemento),0)+1 from elementos
	INSERT INTO [dbo].[Elementos] (
		[cdElemento],
		[dsNombre],
		[dsCateg],
		[cdPresentacion],
		[vlMagnitud],
		[dsCodigoONC],
		[vlStMinimo],
		[cdManejaVto],
		[cdBaja],	
		[cdEsFraccionable],
		[cdUnidadPresentacion],
		[dsDetalleNombre],
		[VlMagnitudMin],
		[cdUsuario],
		[dtAlta]
		
		

	) VALUES (
		@cdElemento,
		@dsNombre,
		@dsCateg,
		@cdPresentacion,
		@vlMagnitud,
		@dsCodigoONC,
		@vlStMinimo,
		@cdManejaVto,
		@cdBaja,
		@cdFraccionable,
		@cdUnidadPresentacion,
		@UnirCadena,
		@vlMagnitudMin,
		@cdUsuario,
		GETDATE()
	--	null
	)

	select @cdElemento=max(cdElemento) from elementos
	IF @cdMarca IS NULL
		BEGIN
		exec dbo.addMarca2 null, @dsMarca,@cdElemento
		END
		ELSE
		exec dbo.addMarca2 @cdMarca, @dsMarca,@cdElemento

	END


else

	UPDATE [dbo].[Elementos] SET
	[dsNombre] = @dsNombre,
	[dsCateg] = @dsCateg,
	[cdPresentacion] = @cdPresentacion,
	[vlMagnitud] = @vlMagnitud,
	[vlMagnitudMin]=@vlMagnitudMin,
	[dsCodigoONC] = @dsCodigoONC,
	[vlStMinimo] = @vlStMinimo,
	[cdManejaVto] = @cdManejaVto,
	[cdBaja] = @cdBaja,
	[cdEsFraccionable] = @cdFraccionable,
	[cdUnidadPresentacion] = @cdUnidadPresentacion,
	[dsDetalleNombre] = @UnirCadena--,
    -- [cdMarca] = @cdMarca
	WHERE
	[cdElemento] = @cdElemento


	IF @cdMarca IS NULL
		BEGIN
		exec dbo.addMarca2 null, @dsMarca,@cdElemento
		END
		ELSE
		exec dbo.addMarca2 @cdMarca, @dsMarca,@cdElemento




SALIR:



-------------------------------
ALTER PROCEDURE [dbo].[Visitascod_BydsNroDocumento]
      @cdTipoDocumento BIGINT,
      @dsNroDocumento  VARCHAR(50) = NULL,
      @dtFecha         DATETIME = NULL,
      @cdAcceso        INT = NULL
AS

     ---Obtengo  maximo ingreso de persona
     DECLARE @cdVisita INT;
     SELECT @cdVisita = MAX(cdVisita)
     FROM Visitas e
     WHERE( e.dsNroDocumento = @dsNroDocumento )
      AND ( e.cdTipoDocumento = @cdTipoDocumento );
	IF @dtFecha =''
	BEGIN
	SET @dtFecha=NULL;
	END 
	
     ---Visita ya ingreso
     IF EXISTS( SELECT 1
                FROM Visitas e
                WHERE cdVisita = @cdVisita
                  AND CONVERT(VARCHAR, E.[dtFechaEntrada], 103) = CONVERT(VARCHAR, @dtFecha, 103) and e.dtFechaSalida is null)
         BEGIN
             IF EXISTS( SELECT 1
                        FROM Visitas
                        WHERE cdVisita = @cdVisita
                          AND icFuncionario = 0 )
                 BEGIN
                     PRINT 'paso 2';
                     IF EXISTS( SELECT 1
                                FROM Visitas
                                WHERE cdVisita = @cdVisita
                                  AND cdAcceso = @cdAcceso )
                         BEGIN
                             PRINT 'paso 3';
                             SELECT cdVisita,
                                    e.dsNroDocumento,
                                    e.cdTipoDocumento,
                                    e.dsVisita,
                                    e.dsFuncion,
                                    e.dsAutoriza,
                                    e.dsAcompa�a,
                                    d.dsDependencia,
                                    e.cdDependencia,
                                    CONVERT( VARCHAR, e.[dtFechaEntrada], 103) AS dtFechaEntrada,
                                    CONVERT( VARCHAR, e.[dtFechaSalida], 103) AS dtFechaSalida,
                                    Hora = REPLACE(STR(DATEPART(HOUR, e.[dtFechaEntrada]), 2), SPACE(1), '0') + ':' + REPLACE(STR(DATEPART(minute, e.[dtFechaEntrada]), 2), SPACE(1), '0'),
                                    HoraS = REPLACE(STR(DATEPART(HOUR, e.[dtFechaSalida]), 2), SPACE(1), '0') + ':' + REPLACE(STR(DATEPART(minute, e.[dtFechaSalida]), 2), SPACE(1), '0'),
                                    e.cdSobre,
                                    e.dsObservacion,
                                    e.icFuncionario,
                                    e.cdUsuarioEntrada,
									e.cdAcceso,
									 Mensaje = 'Registrar salida.'
                             FROM Visitas e
                                  LEFT JOIN Dependencias d ON d.cdDependencia = e.cdDependencia
                                  LEFT JOIN Framework..Usuarios u ON u.cdUsuario = e.cdUsuarioEntrada
                             WHERE e.cdVisita = @cdVisita;
                         END;
                     ELSE
                         BEGIN
                             IF( EXISTS( SELECT 1
                                         FROM Visitas
                                         WHERE cdVisita = @cdVisita
                                           AND cdAcceso IN( 
                                                            SELECT cdAcceso
                                                            FROM Accesos
                                                            WHERE dsAcceso LIKE '%BALCARCE%'
                                                               OR dsAcceso LIKE '%YRIGOYEN%' )
                                           and EXISTS( 
                                                       SELECT 1
                                                       FROM Accesos
                                                       WHERE (dsAcceso LIKE '%BALCARCE%'
                                                          OR dsAcceso LIKE '%YRIGOYEN%')
                                                         AND cdAcceso = @cdAcceso ))
                               )
                                 BEGIN
                                     PRINT 'paso 4';
                                     SELECT e.cdVisita,
                                            e.dsNroDocumento,
                                            e.cdTipoDocumento,
                                            e.dsVisita,
                                            e.dsFuncion,
                                            e.dsAutoriza,
                                            e.dsAcompa�a,
                                            d.dsDependencia,
                                            e.cdDependencia,
                                            CONVERT( VARCHAR, e.[dtFechaEntrada], 103) AS dtFechaEntrada,
                                            CONVERT( VARCHAR, e.[dtFechaSalida], 103) AS dtFechaSalida,
                                            Hora = REPLACE(STR(DATEPART(HOUR, e.[dtFechaEntrada]), 2), SPACE(1), '0') + ':' + REPLACE(STR(DATEPART(minute, e.[dtFechaEntrada]), 2), SPACE(1), '0'),
                                            HoraS = REPLACE(STR(DATEPART(HOUR, e.[dtFechaSalida]), 2), SPACE(1), '0') + ':' + REPLACE(STR(DATEPART(minute, e.[dtFechaSalida]), 2), SPACE(1), '0'),
                                            e.cdSobre,
                                            e.dsObservacion,
                                            e.icFuncionario,
                                            e.cdUsuarioEntrada,
								            e.cdAcceso,
                                            Mensaje = 'Registrar salida.'
                                     FROM Visitas e
                                          LEFT JOIN Dependencias d ON d.cdDependencia = e.cdDependencia
                                          LEFT JOIN Framework..Usuarios u ON u.cdUsuario = e.cdUsuarioEntrada
                                     WHERE e.cdVisita = @cdVisita;
                                 END;
                             ELSE
                                 BEGIN
                                     SELECT 'La Visita ingres� por el de acceso ' + dsAcceso AS Mensaje
                                     FROM Visitas v
                                          LEFT JOIN Accesos a ON a.cdAcceso = v.cdAcceso
                                     WHERE v.cdVisita = @cdVisita;
                                 END;
                         END;
                 END;
             ELSE
                 BEGIN
                     SELECT 'La Visita ingres� por el de acceso ' + dsAcceso AS Mensaje
                     FROM Visitas v
                          LEFT JOIN Accesos a ON a.cdAcceso = v.cdAcceso
                     WHERE v.cdVisita = @cdVisita;
                 END;
         END;
     ELSE
         BEGIN
             SELECT cdVisita = 0,
                    e.dsNroDocumento,
                    e.cdTipoDocumento,
                    e.dsVisita,
                    e.dsFuncion,
                    e.dsAutoriza,
                    e.dsAcompa�a,
                    d.dsDependencia,
                    e.cdDependencia
             FROM Visitas e
                  LEFT JOIN Dependencias d ON d.cdDependencia = e.cdDependencia
                  LEFT JOIN Framework..Usuarios u ON u.cdUsuario = e.cdUsuarioEntrada
             WHERE e.cdVisita = @cdVisita;
         END
	      
		 


  

---------------
ALTER procedure [dbo].[Dependencias_AU]
@term varchar(200)=''
as
-- Generado autom�gicamente por FrameworkGen 2.0.0.1 el mi�rcoles, 14 de octubre de 2015 10:27:15
-- Por GOBIERNO\lvazquez en INFOR32

   select TOP 30
          e.[cdDependencia],
          e.[dsDependencia]
     from [Dependencias] e 
    where (e.[dsDependencia] like '%' + replace(@term,' ','%') + '%')
      and e.icBaja=0
    order 
       by e.[dsDependencia]





---------





