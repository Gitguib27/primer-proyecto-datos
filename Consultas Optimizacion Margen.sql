
# Tasa media de descuento por numero de unidades pedidas 

select cantidad, avg(Tasa_descuento)
from ventas 
group by cantidad
order by cantidad; 


# Descuento medio por total de ventas por cliente

select ID_cliente AS cliente,  SUM(Precio_total_sin_descuento) as total_ventas, avg(Tasa_descuento)
from ventas
group by ID_cliente
order by total_ventas;




# Vamos a hacer 3 tramos para que se ve mas facil 

WITH ventas_agrupadas AS ( 
select ID_cliente,  SUM(Precio_total_sin_descuento) as total_ventas, avg(Tasa_descuento) AS tasa_media
from ventas
group by ID_cliente
order by total_ventas
), 

ventas_tramos AS ( 
select ID_cliente, total_ventas, tasa_media, case
when total_ventas <=(Select MAX(total_ventas)/ 5 from ventas_agrupadas) THEN "Tramo 1"
when total_ventas <=(Select MAX(total_ventas)/ 5*2 from ventas_agrupadas) THEN "Tramo 2"
when total_ventas <=(Select MAX(total_ventas)/ 5*3 from ventas_agrupadas) THEN "Tramo 3"
when total_ventas <=(Select MAX(total_ventas)/ 5*4 from ventas_agrupadas) THEN "Tramo 4"
else "Tramo 5"
				end as Tramo_ventas
from ventas_agrupadas
)

select Tramo_Ventas, AVG(tasa_media) AS tasa_media
from ventas_tramos
group by Tramo_ventas
order by Tramo_ventas
; 

# Los caschbacks no esten alineados con el total de ventas de cada cliente
# Consulta: Porcentaje de rebates sobre importe total de ventas de cada cliente

#clientes
#ventas 

WITH agredado_cliente AS (

select vnts.ID_cliente AS cliente, SUM(Precio_total_sin_descuento) AS ventas_totales, RebateAcum AS Cashback
from ventas AS vnts
LEFT JOIN clientes AS cli ON vnts.ID_cliente=cli.ID_cliente
group by vnts.ID_cliente
)

select cliente, ventas_totales, ROUND(Cashback/ventas_totales *100,2) AS tasa_cashback
from agredado_cliente
order by ventas_totales ASC;

# Tasa de descuento medio por comercial 
# Alineacion de descuentos en los comerciales
WITH descuento_medio_comercial AS ( 

select ID_comercial, ROUND(AVG(Tasa_descuento),2) AS descuento_medio
from ventas 
group by ID_comercial
order by descuento_medio DESC
) 

select descuento_medio, count(descuento_medio) AS dist_comerciales
from descuento_medio_comercial
group by descuento_medio
;


# Porcentaje de descuento sobre el precio medio sin descuento por comercial comparado con la comision que aplica a (2022)

select v.ID_comercial,
	SUM(Descuento)/SUM(Precio_total_sin_descuento)  AS Descuento_medio,
    ROUND(ComisionAcum/SUM(Precio_total_sin_descuento) *100,2) AS Tasa_comision
from 
	ventas AS v
		join
	comerciales AS c ON v.ID_comercial=c.ID_comercial
where year(Fecha_pedido) = 2022
group by ID_comercial
order by  Tasa_comision ASC
;


# Tasa de descuento medio comparado con el margen medio por cada categoria de producto

# ID_categoria - Tabla productos
# Tasa descuento medio - Ventas 
# Margen Medio - Ventas 

select 
	Nombre_categoria, 
    ROUND(avg(Margen),2) AS margen_medio,
    ROUND(avg(Tasa_descuento),2) AS descuento_medio
from ventas AS v
		join
	productos AS p ON v.ID_producto=p.ID_producto
group by Nombre_categoria
order by margen_medio
;


# Tasa media de descuento por Año y por mes
# 2021/01/01
# 2023/08/31

select date_format(Fecha_pedido, "%Y-%m") AS AnoMes, avg(Tasa_descuento) AS Tasa_media_descuento
from ventas
group by date_format(Fecha_pedido, "%Y-%m")
order by date_format(Fecha_pedido, "%Y-%m")
;




