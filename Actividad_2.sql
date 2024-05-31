use AdventureWorks2017

/*
DROP TABLE EC_Territorio;
DROP TABLE EC_Clientes;
DROP TABLE EC_Clientes_IN;
DROP TABLE EC_Clientes_EM;
DROP TABLE EC_Productos;
DROP TABLE EC_Cat_Productos;
DROP TABLE EC_Facturas;
DROP TABLE EC_Transacciones;
*/

-- Proporcionar un listado de productos compuesto por nombre,
-- numero de producto y color para aquellos con un precio superior a 20 euros y con tallas de XS-XL.
SELECT Nombre, NumeroProducto, Color
FROM EC_Productos
WHERE Precio > 20
	AND Talla_disponibles = 'XS-XL'


-- Proporcionar un listado de clientes individuos compuesto por IDCliente, nombre, apellidos 
-- y género que hayan nacido entre 1970 y 1980, cuya ocupación no sea investigador, 
-- ordenados por fecha de primera compra de forma descendente.

SELECT IDCliente, Nombre, Apellidos, Genero
FROM EC_Clientes_IN
WHERE YEAR(Fecha_Nacimiento) BETWEEN 1970 AND 1980 
		AND Ocupacion <> 'Investigador'
ORDER BY Fecha_Primera_Compra DESC

-- Obtener un listado compuesto por factura, fecha de pedido, 
-- fecha de envío y estado de pedido que contengan los códigos 9658 y 4568 en las observaciones. 
-- Pista: Utilizar OR

SELECT FechaPedido, FechaEnvio, EstadoPedido
FROM EC_Facturas
WHERE Observaciones LIKE '%9658%' 
		OR Observaciones LIKE  '%4568%'

-- Proporcionar un listado de IDFactura, IDCliente, 
-- fecha de pedido y total con impuestos cuyo estado sea cancelado y el total con impuestos sea mayor que 1000.

SELECT IDFactura, IDCliente, FechaPedido, Total_con_Impuestos
FROM EC_Facturas
WHERE EstadoPedido = 'Cancelado'
	AND Total_con_Impuestos > 1000

-- Utilizando como base la consulta anterior, 
-- y utilizándola como una subconsulta, obtener el denominación social y teléfono de esos clientes. 

--SELECT DenominacionSocial, Telefono
SELECT *
FROM EC_Clientes_EM AS CL_EM
INNER JOIN (SELECT IDFactura, IDCliente, FechaPedido, Total_con_Impuestos
FROM EC_Facturas
WHERE EstadoPedido = 'Cancelado'
	AND Total_con_Impuestos > 1000) AS IMP
	ON CL_EM.IDCliente = IMP.IDCliente

-- Obtener un listado compuesto por factura, nombre de producto, color, precio unitario, 
-- cantidad y el % de descuento de las transacciones realizadas entre el abril y septiembre de 2019.

-------------------------Dudas: La fecha de la transacción es la fecha de envio?-------------------------------------------

SELECT FACT.IDFactura, PROD.Nombre, PROD.Color, PROD.Precio, TRANS.Cantidad, TRANS.Descuento
FROM EC_Productos AS PROD
INNER JOIN EC_Transacciones AS TRANS
ON PROD.IDProducto = TRANS.IDProducto
INNER JOIN EC_Facturas AS FACT
ON TRANS.IDFactura = FACT.IDFactura
WHERE FechaEnvio BETWEEN '20190401' AND '20190930'

-- Se desea saber cuántos productos hay por cada categoría de productos, así como el precio máximo, 
-- precio mínimo y precio medio por cada categoría, ordenados de mayor a menor en función del recuento por categoría.

SELECT  PROD.GrupoProductoID AS Categoria,
		COUNT(PROD.GrupoProductoID) AS Cantidad_de_productos,
		MAX(PROD.Precio) AS MaximoPrecio,
		MIN(PROD.precio) AS MinimoPrecio,
		AVG(PROD.precio) AS PrecioPromedio
FROM EC_Productos AS PROD
INNER JOIN EC_Cat_Productos AS CAT_PROD
ON PROD.GrupoProductoID = CAT_PROD.GrupoProductoID
GROUP BY PROD.GrupoProductoID
ORDER BY Cantidad_de_productos DESC



-- Obtener las ventas totales con impuestos por país y región. 
-- Excluyendo los pedidos cancelados. Ordenados de menor a mayor por el total de las ventas. 

SELECT TERR.Pais, TERR.Region, SUM(FACT.Total_con_Impuestos) AS Venta_Total
FROM EC_Facturas AS FACT
INNER JOIN EC_Clientes AS CLI
ON FACT.IDCliente = CLI.IDCliente
INNER JOIN EC_Territorio AS TERR
ON CLI.TerritorioID = TERR.TerritorioID
WHERE FACT.EstadoPedido <> 'Cancelado'
GROUP BY TERR.Pais, TERR.Region
ORDER BY Venta_Total 

-- Se desea saber el número de pedidos, el montante total sin impuestos para clientes individuos, así como el nombre 
-- y el número de cuenta de los mismos.  Solo queremos aquellos cuyo montante total supera los 1500 euros. 
-- Ordenar el resultado de mayor a menor en función del montante total calculado.

SELECT COUNT(FACT.IDFactura) AS NumeroPedidos , 
	SUM(FACT.Total) AS MontanteTotal,
	CLI_IN.Nombre,
	CLI.NumeroCuenta
FROM EC_Facturas AS FACT
INNER JOIN EC_Clientes_IN AS CLI_IN
ON FACT.IDCliente = CLI_IN.IDCliente
INNER JOIN EC_Clientes AS CLI
ON FACT.IDCliente = CLI.IDCliente
GROUP BY CLI_IN.Nombre, CLI.NumeroCuenta
HAVING SUM(FACT.Total) > 1500
ORDER BY MontanteTotal DESC
--------------------------- ensayo con left-------------------------------
SELECT CL_IN.Nombre, 
		CL.NumeroCuenta, 
		COUNT(FACT.IDFactura) AS NUMERO_COMPRAS,
		SUM(FACT.Total) AS MONTANTE_TOTAL
FROM EC_Facturas AS FACT
LEFT JOIN EC_Clientes AS CL
ON FACT.IDCliente = CL.IDCliente
LEFT JOIN EC_Clientes_IN AS CL_IN
ON FACT.IDCliente = CL_IN.IDCliente
GROUP BY CL_IN.Nombre, CL.NumeroCuenta, CL.IDCliente
HAVING SUM(FACT.Total) > 1500
ORDER BY MONTANTE_TOTAL DESC

-------------------------otra forma (o la correcta)
-- Se desea saber el número de pedidos, el montante total sin impuestos para clientes individuos, así como el nombre 
-- y el número de cuenta de los mismos.  Solo queremos aquellos cuyo montante total supera los 1500 euros. 
-- Ordenar el resultado de mayor a menor en función del montante total calculado.

SELECT C_IN.Nombre,
		C.NumeroCuenta,
		SUM(F.Total) AS MonteTotal,
		COUNT(F.IDFactura) AS NUMERO_PEDIDOS
FROM EC_Clientes_IN AS C_IN
LEFT JOIN EC_Clientes AS C
ON C_IN.IDCliente = C.IDCliente
LEFT JOIN EC_Facturas AS F
ON C_IN.IDCliente = F.IDCliente
WHERE F.EstadoPedido = 'Enviado'
GROUP BY C_IN.Nombre, C.NumeroCuenta
HAVING SUM(F.Total) > 1500
ORDER BY MonteTotal DESC

