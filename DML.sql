/*2018 */
--probar el management
USE editorial2


--1 Inform how many customers have made purchases in the last quarter of 2018 and in the first
-- quarter of 2019. Show two columns and two rows: the first column called “Description” with
-- a legend in the rows with the description of the period and the second column called “amount of
-- customers ”with that calculated value.


SELECT ('Ultimo trimestre 2018') as descripcion, COUNT(distinct fa.cliente_id) as 'Cantidad de Clientes'
FROM Facturas fa
where fa.fecha between '20181001' AND '20181231'
UNION
SELECT ('Primer trimestre 2019') as descripcion, COUNT(distinct fa.cliente_id) as 'Cantidad de Clientes'
FROM Facturas fa
where fa.fecha between '20190101' AND '20190331'

--2 List the daily sales totals that occurred in January 2018. For each day of sale
--report the day number, the total net amount of that day, the total tax of that day, the tax
-- total additional for that day, the total amount taxed for that day and the amount of invoices. Yes there are
--results in null replace them with zero. The columns must have the following names: Dia,
--Net, VAT, Additional, Total, Amount_ invoices.

select day(fecha) as dia,
	sum(subtotal) as neto,
	sum(monto_iva) iva, sum(impuesto_adicional) 'iva adicional',
	sum(subtotal)+sum(monto_iva)+sum(impuesto_adicional) as bruto,
	count(*) as 'Cant. fact.'
from dbo.Facturas
where month(fecha) = 1 AND year(fecha) = 2019
group by day(fecha)
--_____________________________________________________________


--3
select r.rubro_id, r.nombre, z.cantidad
from dbo.rubros as r
inner join(
	select a.rubro_id, sum(f2.cantidad) as cantidad
	from dbo.facturas_detalle as f2
	inner join dbo.Facturas as f1 on f1.punto_venta= f2.punto_venta AND f1.numero = f2.numero
	inner join dbo.Articulos as a on f2.articulo_id = a.id
	where f1.fecha between '20181001' and '20181231'
	group by a.rubro_id
	having sum(f2.cantidad) > 30
	) as z on r.rubro_id = z.rubro_id
order by z.cantidad desc, r.rubro_id asc

--4. List the invoices that were generated on 03/15/2019 and that do not include items of the item
-- 'Perfumery'. For each invoice, list the point of sale and the invoice number.


SELECT fa.punto_venta, fa.numero
FROM Facturas as fa
where fa.numero not in ( -- not exists es
	SELECT fa.numero
	FROM Facturas as fa
	INNER JOIN Facturas_detalle as fd on fd.numero = fa.numero
	inner join Facturas_detalle as fdd on fdd.punto_venta = fa.punto_venta
	INNER JOIN Articulos as ar on ar.id = fd.articulo_id
	INNER JOIN Rubros as ru on ru.rubro_id = ar.rubro_id
	WHERE fa.fecha = '20190315'
	AND fd.punto_venta = fa.punto_venta
	AND ru.nombre = 'Perfumeria'
	group by fa.numero, fa.punto_venta
) AND fa.fecha = '20190315'

--5. Increase commission by 3% to sellers who in some month of 2018 sold more than 100
-- article units.

UPDATE Vendedores
SET comision = comision + 3
select ven.id, SUM(fd.cantidad)
FROM Vendedores as ven
INNER JOIN Facturas as fa on fa.vendedor_id = ven.id
INNER JOIN Facturas_detalle as fd on fd.numero = fa.numero
WHERE YEAR(fa.fecha) = '2018'
GROUP BY ven.id --agregar month(fecha)
HAVING SUM(fd.cantidad) > 100

--Add all vendors to the client entity and set the column values ​​with the
-- following specifications: reason is the sum of the last name and the name, locality: ‘Posadas’,
-- Province: “Misiones”, Zone: “Noroeste” and VAT is “MT” (monotributista)

INSERT INTO Clientes (razon_social, localidad, provincia_id, zona_id, iva)
SELECT (ven.apellido + ' ' + ven.nombres) as Nombres, ('Posadas') as loc, pr.id, z.id, ('MT') as iva   
FROM Vendedores ven, Provincias pr, Zonas z
WHERE pr.nombre = 'Misiones' -- usar =. like usa mucho recurso y es para comparar cadenas.  
AND  z.nombre like 'Noroeste'

--7. Delete customers to whom no sale was made.

DELETE Clientes
FROM clientes as cli
LEFT JOIN Facturas fa 
ON fa.cliente_id = cli.id	
WHERE fa.cliente_id is null  


--2.1. Listar los títulos pertenecientes al editor 1389. Por cada fila, listar el título, el tipo y la
--fecha de publicación. 
SELECT titulo, genero, fecha_publicacion 
FROM titulos 
WHERE editorial_id = 1389
--2.2. Tomando las ventas mostrar el id de título, el título y el total de ventas que se obtiene
--de multiplicar la cantidad por precio. Renombrar a la columna calculada como “Total
--de venta”. 
SELECT ventas.titulo_id as "id titulo", titulos.titulo, ventas.cantidad*titulos.precio as "total venta"
FROM ventas, titulos
where ventas.titulo_id = titulos.titulo_id
group by ventas.titulo_id
--2.3. Listar los id de almacén, números de orden y la cantidad para las ventas que realizo el
--título “Prolonged Data Deprivation: Four Case Studies” el día 29 de mayo de 2013
select distinct titulo, fecha_orden, numero_orden, cantidad 
from ventas, titulos
where titulos.titulo_id = ventas.titulo_id --condicion de junta 
AND titulos.titulo = 'Prolonged Data Deprivation: Four Case Studies'
AND fecha_orden = '20130529'
--AND YEAR(fecha_orden) = '2013'
--AND MONTH(fecha_orden) = '05'
--AND DAY (fecha_orden) = '29'
--2.4. Listar el nombre, la inicial del segundo nombre y el apellido de los empleados de las
--editoriales “Lucerne Publishing” y “New Moon Books”
SELECT distinct nombre, inicial_segundo_nombre, apellido
FROM empleados em, editoriales ed
WHERE em.editorial_id = ed.editorial_id
AND (ed.editorial_nombre = 'Lucerne Publishing'
OR ed.editorial_nombre = 'New Moon Books')
AND em.editorial_id = ed.editorial_id

--2.5. Mostrar los títulos que no sean de la editorial “Algodata Infosystems”. Informar titulo
--y Editorial.

 SELECT titulo, editorial_nombre
 FROM titulos ti, editoriales ed
 WHERE ti.editorial_id = ed.editorial_id
 AND ed.editorial_nombre  != 'Algodata Infosystems'

--2.6. Listar los títulos que tengan más regalías que cualquier otro título. 
select distinct t1.titulo, t1.regalias
from titulos as t1, titulos as t2
where t1.regalias > t2.regalias
--2.7. Informar los empleados contratados en febrero, junio y agosto de cualquier año.
--Mostrar apellido, nombre y fecha de contratación y ordenar por mes empezando por
--los de febrero.
SELECT apellido, nombre, fecha_contratacion
FROM empleados em
WHERE month(em.fecha_contratacion) = '02'
OR MONTH(em.fecha_contratacion) = '06'
OR MONTH(em.fecha_contratacion) = '08'	
ORDER BY MONTH(fecha_contratacion)

--2.8. Informar las ventas de los siguientes títulos: 'Cooking with Computers: Surreptitious
--Balance Sheets', 'The Psychology of Computer Cooking', 'Emotional Security: A New
--Algorithm'. Mostrar titulo, nombre de almacén, fecha de orden, número de orden y
--cantidad. Ordenar por títulos.
SELECT tit.titulo, alm.almacen_nombre, ven.fecha_orden, ven.numero_orden, ven.cantidad
FROM titulos as tit, almacenes as alm, ventas as ven
WHERE ven.titulo_id = tit.titulo_id AND ven.almacen_id = alm.almacen_id
AND( tit.titulo = 'Cooking with Computers: Surreptitious Balance Sheets' 
OR tit.titulo = 'Emotional Security: A New Algorithm' 
OR tit.titulo = 'The Psychology of Computer Cooking')
ORDER BY tit.titulo

--2.9. Informar las publicaciones del año 2011 exceptuando las de los géneros business,
--psychology y trad_cook. Mostrar titulo y género. Ordenar por género y titulo
SELECT titulo, genero 
FROM titulos
WHERE YEAR(fecha_publicacion) = '2011'
AND genero != 'business' AND genero != 'psychology' AND genero != 'trad_cook'
ORDER BY titulo, genero

--3.1. Mostrar aquellos libros que tienen el precio en nulo. Mostrar id de título, nombre y
--nombre del editor.
SELECT distinct titulo_id, titulo, editorial_nombre
FROM titulos tit, editoriales ed
WHERE tit.editorial_id = ed.editorial_id AND precio IS NULL

--3.2. Mostrar todos los libros. Mostrar id de título, nombre y nombre del editor y el precio.
--Aquellos que tienen el precio en nulo cambiarlo por 0.
SELECT titulo_id, titulo, editorial_nombre, ISNULL( precio, '0' ) 
FROM titulos tit, editoriales ed
WHERE tit.editorial_id = ed.editorial_id

--3.3. Mostrar los descuentos que tengan una cantidad mínima establecida. Informar tipo
--descuento, cantidad mínima y descuento

SELECT tipo_descuento, cantidad_minima, descuento
FROM descuentos
WHERE cantidad_minima IS NOT NULL

--3.4. Mostrar los títulos y el adelanto que le corresponde a cada uno, si este valor fuera
--nulo informar le valor predeterminado de 1000 pesos
SELECT titulo, ISNULL(adelanto, 1000) as adelanto
from titulos

--4.1. Mostrar los nombres de los autores que empiecen con “L”
SELECT autor_nombre
FROM autores
WHERE autor_nombre LIKE 'L%'

--4.2. Mostrar los nombres de los autores que tengan una “A” en su nombre.
SELECT autor_nombre
FROM autores
WHERE autor_nombre LIKE '%A%'

--4.3. Mostrar los nombres de los autores que empiecen con letras que van de la T a la Y
SELECT autor_nombre
FROM autores
WHERE autor_nombre LIKE '[T-Y]%'
--4.4. Mostrar los títulos que no tengan un “Computer” en su titulo
SELECT titulo
FROM titulos
WHERE titulo NOT LIKE '%computer%' 

--5.1. Listar los empleados ordenados por apellido, por nombre y por inicial del segundo
--nombre.

SELECT * 
FROM empleados
ORDER BY apellido, nombre, inicial_segundo_nombre

--5.2. Listar los títulos pertenecientes al género ‘business’. Por cada fila, listar el id, el título
--y el precio. Ordenar los datos por precio en forma descendente e id de artículo en
--forma ascendente.

SELECT titulo_id, titulo, precio 
FROM titulos
WHERE genero = 'business'
ORDER BY precio desc, titulo_id asc

--5.3. Informar la venta más importante con forma de pago a 60 días. Mostrar el almacén, el
--número de orden, la fecha de la factura y el título.
--multiplicar la cantidad por el precio de forma ascendente
-- de eso el top 1

select TOP 1 a.almacen_nombre, numero_orden, fecha_orden,
 titulo, total = v.cantidad * precio
from ventas as v, titulos as t, almacenes as a
WHERE v.titulo_id = t.titulo_id
AND v.almacen_id = a.almacen_id
AND forma_pago = '60 días'
ORDER BY v.cantidad * precio desc
 

--6.1. Mostrar el promedio de venta anual de todos los títulos
SELECT AVG(venta_anual) as promedio
FROM titulos
--cuando devuelve 1 valor es xq no tiene gropu by

--6.2. Mostrar el máximo de adelanto de todos los títulos
SELECT MAX(adelanto) as adelanto
FROM titulos

--6.3. Informar cuantos planes de regalías tiene el título MC3021
SELECT COUNT(regalias) as regalias
FROM plan_regalias
WHERE titulo_id = 'MC3021'

--6.4. Obtener el total de ventas realizadas a 30 días en el año 2014

SELECT COUNT(cantidad) as TotalVentas
FROM ventas
WHERE forma_pago = '60 días' AND YEAR(fecha_orden) = '2014'

--6.5. Informar cuantas formas de pago existen

select COUNT(distinct forma_pago) as total 
from ventas 

--7.1. Informar cuantos títulos tiene cada autor. Mostrar código de autor y cantidad de
--libros.
-- sin where
SELECT COUNT(titulo_id) as totalTitulos, autor_id      
FROM titulo_autor
GROUP BY autor_id

--7.2. Informar el total de unidades vendidas por número de orden del almacén 7131.
--Mostrar número de orden y total vendido.

SELECT numero_orden, sum(cantidad) as TotalVendido
FROM ventas
WHERE almacen_id = 7131
GROUP BY numero_orden

--7.3. Informar la última orden generada por cada almacén con forma de pago a 30 días y 60
--días. Mostrar código de almacén, fecha de la orden y forma de pago. Ordenar por
--fecha de orden.
SELECT almacen_id, forma_pago, max(fecha_orden) as ultima 
FROM ventas
WHERE forma_pago = '30 días'
OR forma_pago = '60 días'
GROUP BY almacen_id, forma_pago -- el group debe tener los mismos items que en el select
ORDER BY ultima -- columnas que esten en select o group

--7.4. Informar el nivel de cargo más alto alcanzado por algún empleado de cada editorial.
--Mostrar Nombre de la editorial y nivel de cargo. Ordenar por nivel de cargo máximo
--empezando por el mayor

SELECT ed.editorial_nombre, MAX(emp.nivel_cargo) as NivelCargo 
FROM empleados as emp, editoriales as ed
WHERE ed.editorial_id = emp.editorial_id
GROUP BY ed.editorial_nombre
ORDER BY NivelCargo desc

--7.5. Mostrar los tres primeros géneros más vendidos. Mostrar género y total de ventas
--ordenado por mayor total de venta.

-- count para contar filas
-- sum para contar lo que hay dentro de las filas

SELECT top 3  tit.genero, sum(ven.cantidad) as TotalVentas
FROM titulos as tit, ventas as ven
WHERE tit.titulo_id = ven.titulo_id
group by tit.genero
order by TotalVentas desc


--7.6. Informar aquellos títulos que tengan más de un autor. Mostrar código de título y
--cantidad de autores.

SELECT tit.titulo_id, count(tit.titulo_id) as total
FROM titulo_autor as tit
GROUP BY tit.titulo_id
HAVING count(tit.autor_id) > 1


--7.7. Informar el total de regalías obtenidas por cada título que haya tenido 40 o más
--unidades vendidas. Mostrar el título y el monto en pesos de las regalías y ordenar por
--mayor regalía primero.
--(cantidad*precio*regalias/100)
--from titulos y ventas 
SELECT tit.titulo, SUM(reg.regalias) as TotalRegalias
FROM plan_regalias as reg, titulos as tit
WHERE tit.titulo_id = reg.titulo_id
GROUP BY tit.titulo
having SUM(reg.regalias) > 40
ORDER BY TotalRegalias desc

--7.8. Informar los autores que hayan escrito varios géneros de títulos. Mostrar nombre y
--cantidad de géneros ordenados por esta última columna empezando por el mayor.

SELECT aut.autor_nombre, COUNT(distinct tit.genero) as TotalGeneros
from titulos as tit, titulo_autor as titaut, autores as aut
WHERE tit.titulo_id = titaut.titulo_id AND titaut.autor_id = aut.autor_id
GROUP BY aut.autor_nombre
HAVING COUNT(distinct tit.genero)>1
ORDER BY TotalGeneros desc


-- ejemplo  14/05 inner join

select * 
from cargos
inner join empleados
on cargos.cargo_id = empleados.cargo_id --lo q esta es on es condicion de junta

-- junta externa retonra todas las filas de 1 de las dos relaciones o de las dos
-- mosrtrar los cargos y sus empleados inclusive aquellos que no tienen empleados
select cargos.cargo_id, cargo_descripcion, ISNULL(empleado_id, 'S.E.') as empleado_id
from cargos
left outer join empleados on cargos.cargo_id = empleados.empleado_id
order by apellido

select *
from empleados
right outer join cargos on cargos.cargo_id = empleados.cargo_id
order by apellido

select *
from empleados
inner join editoriales on editoriales.editorial_id =  
right outer join cargos on cargos.cargo_id = empleados.cargo_id 


--primero todos los inner y por ultoimo left o right

--cuando hago 1 junta externa si hago la junta por izquierda lo q esta a la derecha tengo q tratarlos por nulos. "is null" para los valores q vienen por ahi, ponerle un valor neutro
--si el front end maneja nulos ggwpizigame
--si hago junta externa por derecha. trato is null por is null
--outer es opcional

select * from 
autores as a
full join titulo_autor as ta on a.autor_id = ta.autor_id
full join titulos as t on t.titulo_id = ta.titulo_id 

--8.1. Informar las ventas a 60 días. Mostrar el id de título, el título y el total de ventas
--(cantidad por precio). Renombrar a la columna calculada.

SELECT tit.titulo_id, tit.titulo, SUM(ven.cantidad * tit.precio) as totalVentas
FROM ventas as ven 
inner join titulos as tit
on tit.titulo_id = ven.titulo_id 
WHERE ven.forma_pago = '60 días'
GROUP BY tit.titulo_id, tit.titulo

--8.2. Informar los autores que hayan escrito varios géneros de libros. Mostrar nombre y
--cantidad de géneros ordenados por esta última columna empezando por el mayor.

SELECT aut.autor_nombre, COUNT(tit.genero) as TotalGeneros
FROM titulos as tit -- autores
inner join titulo_autor as titaut on tit.titulo_id = titaut.titulo_id
inner join autores as aut on aut.autor_id = titaut.autor_id 
GROUP BY aut.autor_nombre
HAVING COUNT(tit.genero)>1 
ORDER BY TotalGeneros desc

--8.3. Informar para que editorial ha trabajado cada autor. Mostrar Apellido y nombre del
--autor y nombre de la editorial. Ordenar por Apellido y nombre del autor y nombre de
--la editorial.

SELECT distinct aut.autor_apellido, aut.autor_nombre, edit.editorial_nombre
FROM autores as aut 
inner join titulo_autor as titaut on aut.autor_id = titaut.autor_id
inner join titulos as tit on titaut.titulo_id = tit.titulo_id
inner join editoriales as edit on tit.editorial_id = edit.editorial_id

--el orden de los inner no altera el resultado

--8.4. Informar las ventas por título. Mostrar título, fecha de orden y cantidad, si no tienen
--venta al menos mostrar una fila que indique la cantidad en 0. Ordenar por título y
--mayor cantidad vendida primero.

SELECT tit.titulo, ven.fecha_orden, ISNULL(ven.cantidad, 0) as Cantidad
FROM ventas as ven
left outer join titulos as tit on ven.titulo_id = tit.titulo_id
ORDER BY tit.titulo, Cantidad asc

select t.titulo, v.fecha_orden, isnull(sum(v.cantidad),0) as Cantidad
from ventas as v
right join titulos as t on t.titulo_id = v.titulo_id
group by v.titulo_id, t.titulo, fecha_orden
order by titulo, Cantidad desc

--8.5. Informar los autores que no tienen títulos. Mostrar nombre y apellido
SELECT aut.autor_nombre, aut.autor_apellido
FROM autores as aut
left outer join titulo_autor as tit on tit.autor_id = aut.autor_id
WHERE tit.titulo_id is null

--8.6. Informar todos los cargos y los empleados que le corresponden de la editorial 'New
--Moon Books', si algún cargo está vacante informar como 'Vacante' en apellido.
--Mostrar descripción del cargo, apellido y nombre. Ordenar por descripción del cargo,
--apellido y nombre.

select c.cargo_descripcion, ISNULL(e.apellido,'vacante') as Apellido, ISNULL(e.nombre,'Vacante') as Nombre
from empleados e
inner join editoriales d on d.editorial_id = e.editorial_id AND d.editorial_nombre = 'New Moon Books' --traer todo en el inner
right outer join cargos c on c.cargo_id = e.cargo_id
order by cargo_descripcion, apellido, nombre

 
--8.7. Informar cuantos títulos escribió cada autor inclusive aquellos que no lo hayan hecho
--aún. Mostrar nombre y apellido del autor y cantidad. Ordenar por cantidad mayor
--primero, apellido y nombre.
SELECT aut.autor_nombre, aut.autor_apellido, COUNT(tit.titulo_id) as Cantidad
FROM titulo_autor, autores as aut
left outer join titulo_autor tit on tit.autor_id = aut.autor_id
GROUP BY aut.autor_nombre, aut.autor_apellido
ORDER BY Cantidad DESC

--8.8. ¿Informar cuantos títulos “Is Anger the Enemy?” vendió cada almacén. Si un almacén
--no tuvo ventas del mismo informar con un cero. Mostrar código de almacén y
--cantidad.

SELECT alm.almacen_id, ISNULL(SUM(ven.cantidad), 0) as Cantidad
FROM ventas ven 
inner join titulos tit on ven.titulo_id = tit.titulo_id AND tit.titulo = 'Is Anger the Enemy?'
right outer join almacenes alm on ven.almacen_id = alm.almacen_id
GROUP BY alm.almacen_id


--8.9. Informar los totales de ventas (pesos) al contado entre abril y septiembre del 2014
--por cada almacén. Mostrar nombre de almacén, y total de venta. Si un almacén no
--tiene ventas mostrar en cero.

SELECT alm.almacen_id, ISNULL((ven.cantidad*tit.precio),0) as Totales
from almacenes alm

right outer join ventas ven on ven.almacen_id = alm.almacen_id   
where fecha_orden between '20140401' AND '20140930'
 

SELECT alm.almacen_id, ISNULL((ven.cantidad*tit.precio),0) as Totales
FROM ventas ven, titulos tit, almacenes alm
WHERE ven.forma_pago = 'Al contado' AND ven.titulo_id = tit.titulo_id AND alm.almacen_id = ven.almacen_id
GROUP BY alm.almacen_id, ven.cantidad, tit.precio

--8.10. Informar el monto de regalías a pagar por cada autor, inclusive aquellos que no
--tengan ventas, de las ventas del año 2013 de la editorial ‘Binnet & Hardley’. Mostrar
--apellido y nombre del autor y monto a pagar. Tener en cuenta que hay que operar la
--regalía del título y sobre esta la regalía del autor respecto a ese libro.

--9.1. Informar las ciudades y estado donde residen los autores, las editoriales y los
--almacenes descartando valores duplicados. Ordenar por nombre de ciudad.
SELECT distinct ciudad, estado   
FROM autores
UNION
SELECT distinct ciudad, estado
FROM editoriales
--__________________________________________________________________________________________________

--9.2. Informar cuantos títulos se han publicado primer semestre del 2011 y en el primer
--semestre del 2017. Mostrar dos columnas y dos filas: en la primera columna la
--descripción del periodo y en la segunda la cantidad de títulos.
SELECT COUNT(tit.titulo) as 'semestre 2011' 
from titulos tit
where tit.fecha_publicacion between '20110101'AND '20110630'
UNION
SELECT COUNT(tit.titulo) as 'semestre 2017'
from titulos tit
where tit.fecha_publicacion between '20170101' AND '20170630'

--9.3. Emitir un informe comparativo entre las ventas del año 2012 y el año 2014. El informe
--debe tener las siguientes columnas: código de título, titulo, año y cantidad de vendida
--en el año (cada uno correspondiente al código de título de la fila correspondiente).
--Tener presente que un título puede tener ventas en un año y no en el otro, en cuyo
--caso debe aparecer igual en el informe el año sin ventas. Ordenar por título y año.

SELECT tit.titulo_id, tit.titulo, YEAR(tit.fecha_publicacion) as 'fecha publicacion', COUNT(ven.titulo_id) as 'Total Vendidos'  
FROM titulos tit, ventas ven 
WHERE tit.titulo_id = ven.titulo_id AND YEAR(ven.fecha_orden) = '2012'
GROUP BY tit.titulo_id, tit.titulo, tit.fecha_publicacion
UNION
SELECT tit.titulo_id, tit.titulo, YEAR(tit.fecha_publicacion) as 'fecha publicacion', COUNT(ven.titulo_id) as 'Total Vendidos'  
FROM titulos tit, ventas ven 
WHERE tit.titulo_id = ven.titulo_id AND YEAR(ven.fecha_orden) = '2014'
GROUP BY tit.titulo_id, tit.titulo, tit.fecha_publicacion



USE editorial2

-- no se puede hacer order by con sub consulta
--informar los autores que han escrito un libro
select * 
from autores 
where autor_id in (
	select distinct autor_id
	from titulo_autor)


--autores q no escribieron libro

select * 
from autores 
where autor_id not in (
	select distinct autor_id
	from titulo_autor) -- in limitado a una columna

--con exists la comparacion es del exterior al interior de la subconsulta

select * 
from autores as a --por cada tabla de auytores hace el where
where exists (
	select distinct autor_id
	from titulo_autor as ta
	where ta.autor_id = a.autor_id) -- exists 
--true cunado hay filas en la sub consulta

--informar los empleados que tengan mejor nivel de cargo q algun otro empleado
-- empieza escribiendo la sub conbsulta
select * 
from empleados
where nivel_cargo > some (
	select nivel_cargo
	from empleados
	)

select * 
from empleados
where nivel_cargo >= all (
	select nivel_cargo
	from empleados
	)
	--cuando se usa sub consulta en where
	-- las filas obtenidas en la sub consulta no se pueden mostrar = solo para comparar =
	-- 10: 1 2 3 4 5 6 7. 
	-- tratar de no reppetir las tablas

	-- NO PONER SUB CONSULTA EN EL FROM

select a1.autor_apellido, a1.autor_nombre, a2.autor_apellido, a2.autor_nombre
from autores as a1, autores as a2,
 (
	SELECT ta1.autor_id autor1, ta2.autor_id autor2
	from titulo_autor as ta1, titulo_autor as ta2
	where ta1.titulo_id = ta2.titulo_id
	and ta1.autor_id > ta2.autor_id   -- nunca teine que ser igual, estaba en <>
	) as ta where ta.autor1 = a1.autor_id AND ta.autor2 = a2.autor_id
order by a1.autor_apellido, a1.autor_nombre, a2.autor_apellido, a2.autor_nombre

/* informar el nivel de cargo mas alto alcanzado por algun empleado de cada editorial.
mostrar nombre de la editorial y el nivel de cargo.
ordenar  por nivel de cargo macximo empezand por el amyor*/

select editorial_nombre, maximo_nivel_cargo
from editoriales as ed
inner join(
	select editorial_id, maximo_nivel_cargo = max(nivel_cArgo)
	from empleados
	group by editorial_id
) as em on em.editorial_id = ed.editorial_id
/* inner join empleados as e2 on e2.editorial_ed = ed.editorial_id and e2. */ 
order by maximo_nivel_cargo desc

--juntas filtros indices 
--10- se mueve a la serie 8, xq no se puede hacer subconsulta
--tiene q dar 3 ffilas 223 100 50
--separar el negocio de la presentación


select autor_nombre, cantidad
from autores as a
inner join(
	select ta.autor_id, COUNT(distinct genero) as cantidad
	from titulo_autor as ta
	inner join titulos as t on ta.titulo_id = t.titulo_id
	group by autor_id
	having count(distinct genero) > 1
) as g on g.autor_id = a.autor_id
order by cantidad desc

