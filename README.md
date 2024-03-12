# Dannys-Diner-SQL-Challenge 🍝🍜

![](https://8weeksqlchallenge.com/images/case-study-designs/1.png)

## Introducción 

A Danny le encanta la comida japonesa, así que a principios de 2021 decide embarcarse en una aventura arriesgada y abre un pequeño y bonito restaurante que vende sus 3 comidas favoritas: sushi, curry y ramen.Danny's Diner necesita ayuda para ayudar al restaurante a mantenerse a flote: el restaurante ha recopilado algunos datos muy básicos de sus pocos meses de operación, pero no tiene idea de cómo usar esos datos para ayudarlos a administrar el negocio.

### Planteamiento del problema 

Danny quiere utilizar los datos para responder algunas preguntas sencillas sobre sus clientes, especialmente sobre sus patrones de visita, cuánto dinero han gastado y también qué elementos del menú son sus favoritos. Tener esta conexión más profunda con sus clientes le ayudará a ofrecer una experiencia mejor y más personalizada a sus clientes leales.

### Diagrama entidad relación 

![](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

## Preguntas a responder

Luego de crear la base de datos junto con sus relaciones insertar los registros de cada tabla en MySQL procedo a responder las siguientes preguntas:

### 1. ¿Cuál es el monto total que gastó cada cliente en el restaurante?

```sql
SELECT 
  customer_id,
    SUM(price) as total
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;
```

#### Pasos:

- Usar **JOIN** para unir las tablas menu y sales.
- Sumar el precio de cada producto ordenado con la función **SUM**.
- Agrupar los resultados por cliente con **GROUP BY**.

#### Resultados:

| customer_id  | total |
| ------------- | ------------- |
| A  | 76  |
| B  | 74 |
| C  | 36  |

### 2. ¿Cuántos días ha visitado cada cliente el restaurante?

```sql
SELECT
	customer_id,
	COUNT(DISTINCT(order_date)) AS days
FROM sales
GROUP BY customer_id;
```

#### Pasos:

- Mediante **COUNT(DISTINCT)** se obtiene la cantidad de días diferentes que cada cliente visitó el restaurante.
- Agrupar los resultados por cliente con **GROUP BY**.

#### Resultados:

| customer_id  | days |
| ------------- | ------------- |
| A  | 4  |
| B  | 6 |
| C  | 2  |


### 3. ¿Cuál fue el primer artículo del menú que compró cada cliente?

```sql
WITH sales_order_date AS(
	SELECT 
		customer_id,
        order_date,
        product_name,
        RANK()
        OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS ranking
	FROM sales
    INNER JOIN menu
    ON sales.product_id = menu.product_id
    )
SELECT customer_id, product_name
FROM sales_order_date
WHERE ranking = 1;
```

#### Pasos: 

- Crear una **CTE(common table expression)** con la función **WITH** que contiene datos de clientes, fechas de ordenes y nombres de productos.
- Con las funciones **RANK** y **OVER** se añade columna "ranking", la cual rankea los productos de acuerdo al día que fueron ordenados por cada cliente.
- Extraer datos de la CTE antes mencionada para los productos que tienen ranking = 1.

#### Resultados:

| customer_id  | product_name |
| ------------- | ------------- |
| A  | sushi  |
| A  | curry |
| B  | curry  |
| C  | ramen  |
| C  | ramen  |

### 4. ¿Cuál es el artículo más comprado del menú y cuántas veces lo compraron todos los clientes?

```sql
SELECT 
	product_name,
	COUNT(product_name) AS orders
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY orders DESC
LIMIT 1;
```

#### Pasos:

- Usar **JOIN** para unir tablas sales y menu.
- Contar cantidad de veces que fue ordenado un producto con **COUNT**.
- Agrupar resultados por nombre de producto con función **GROUP BY**
- Con **ORDER BY** ordenar los productos de mayor a menor en cantidad de ordenes y devolver unicamente el primero de la lista con función **LIMIT**.

#### Resultados:

| product_name | orders |
| ------------- | ------------- |
|  ramen | 8  |


### 5. ¿Qué artículo fue el más popular para cada cliente?

```sql
WITH popular_product AS(
	SELECT
		customer_id,
		product_name,
		COUNT(order_date) as orders,
		RANK()
		OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) AS top
	FROM sales 
	INNER JOIN menu
	ON sales.product_id = menu.product_id
	GROUP BY product_name, customer_id
	)
SELECT
	customer_id,
    product_name,
    orders
FROM popular_product
WHERE top = 1;
```

#### Pasos:

- Crear **CTE** que contiene datos de clientes, productos y cantidad de veces que fue ordenado el producto.
- Mediante **RANK** y **OVER** se obtiene un ranking de productos ordenados particionado por cada cliente.
- Extraer datos de la **CTE** cuyo ranking = 1, de esta manera se obtiene el producto más popular para cada cliente.

#### Resultados:

| customer_id  | product_name | orders | 
| ------------- | ------------- | ------------- |
| A  | ramen  | 3 |
| B  | curry | 2 |
| B  | sushi  | 2 |
| B  | ramen  | 2 |
| C  | ramen  | 3 |

### 6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?

```sql
WITH product_member AS(
	SELECT 
		sales.customer_id,
		product_name,
		order_date,
		join_date,
		TIMEDIFF(order_date, join_date) AS time_diff,
		RANK()
		OVER(PARTITION BY sales.customer_id ORDER BY TIMEDIFF(order_date, join_date) ASC) AS ranking
	FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
	WHERE timediff(order_date, join_date) > 0
    )
SELECT 
	customer_id,
    product_name
FROM product_member
WHERE ranking = 1;
```

#### Pasos:

- Crear consulta uniendo tablas sales, menu y members con función **JOIN** que devuelve: cliente, producto, fecha de orden, fecha que el cliente se convirtió en miembro.
- Agregar mediante la función **TIMEDIFF** una columna que indica el tiempo transcurrido desde que el cliente se convirtió en miembro hasta que ordeno un producto.
- Con la cláusula **WHERE** se filtran los resultados para obtener únicamente aquellas ordenes que se hicieron luego de que el cliente se convirtió en miembro.
- Usar **RANK** **OVER** para clasificar las ordenes de los clientes luego de convertirse en miembros siendo 1 la primer orden.
- Agregar consulta adicional que extraiga datos de la CTE antes mencionada pero filtrando los resultados y obteniendo unicamente aquellos que contengan ranking = 1, es decir, el producto que se ordeno primero luego de convertirse en miembro.

#### Resultados:

| customer_id  | product_name |
| ------------- | ------------- |
| A  | ramen |
| B  | sushi  | 

 ### 7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro?

```sql
WITH product_member_bf AS(
	SELECT 
		sales.customer_id,
		product_name,
		order_date,
		join_date,
		TIMEDIFF(order_date, join_date) AS time_diff,
		RANK()
		OVER(PARTITION BY sales.customer_id ORDER BY TIMEDIFF(order_date, join_date) DESC) AS ranking
	FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
	WHERE timediff(order_date, join_date) <= 0
    )
SELECT 
	customer_id,
    product_name
FROM product_member_bf
WHERE ranking = 1;
```

#### Pasos:

- Crear consulta uniendo tablas sales, menu y members con función **JOIN** que devuelve: cliente, producto, fecha de orden, fecha que el cliente se convirtió en miembro.
- Agregar mediante la función **TIMEDIFF** una columna que indica el tiempo transcurrido desde que el cliente se convirtió en miembro hasta que ordeno un producto, en este caso, la columna devuelve valores negativos ya que necesitamos el producto que ordenó antes de convertirse en miembro.
- Con la cláusula **WHERE** se filtran los resultados para obtener únicamente aquellas ordenes que se hicieron antes de que el cliente se convierta en miembro.
- Usar **RANK** **OVER** para clasificar las ordenes de los clientes antes de convertirse en miembros siendo 1 la última orden.
- Agregar consulta adicional que extraiga datos de la CTE antes mencionada pero filtrando los resultados y obteniendo unicamente aquellos que contengan ranking = 1, es decir, el producto que se ordeno último, antes de convertirse en miembro.

#### Resultados:

| customer_id  | product_name |
| ------------- | ------------- |
| A  | curry |
| B  | sushi  | 

### 8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?

```sql
SELECT 
	sales.customer_id,
    COUNT(order_date) AS orders,
    SUM(price) AS total
FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
WHERE timediff(order_date, join_date) < 0
GROUP BY customer_id;
```

#### Pasos: 

- Unir tablas members, sales y menu con función **JOIN**.
- Extraer id de cliente, cantidad de ordenes con función **COUNT** y suma del precio de cada orden con función **SUM**.
- Usar **TIMEDIFF** < 0 en cláusula **WHERE** para obtener solo resultados de órdenes que fueron hechas antes de que el cliente se convierta en miembro.
- Agrupar resultados por cada cliente con función **GROUP BY**.

#### Resultados:

| customer_id  | orders | total | 
| ------------- | ------------- | ------------- |
| B | 3  | 40 |
| A | 2 | 25 |

 ### 9. Si cada dólar gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos x2, ¿cuántos puntos tendría cada cliente?

 ```sql
SELECT 
	sales.customer_id,
    SUM(IF(product_name = 'sushi', price*20, price*10)) AS points
FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;
```

#### Pasos:

- Unir tablas members, sales y menu con función **JOIN**.
- Para obtener puntaje, usar **IF** dentro de función **SUM** donde se indica que si el producto es "sushi" debe multiplicar por 20 y sino por 10.
- Agrupar resultados por cliente con función **GROUP BY**.

#### Resultados:

| customer_id  | points |
| ------------- | ------------- |
| B  | 940 |
| A  | 860  | 

### 10. En la primera semana después de que un cliente se une al programa (incluida su fecha de inscripción), gana el doble de puntos en todos los artículos, no solo en sushi. ¿Cuántos puntos tienen los clientes A y B a finales de enero?

 ```sql
SELECT 
	sales.customer_id,
	SUM(CASE 
			WHEN product_name = 'sushi' THEN price * 20
			WHEN order_date BETWEEN join_date AND DATE_ADD(order_date, INTERVAL 6 DAY)
			THEN price * 20
            ELSE price * 10 
	END) AS points
FROM sales
INNER JOIN members 
ON sales.customer_id = members.customer_id
INNER JOIN menu
ON sales.product_id = menu.product_id
WHERE EXTRACT(MONTH FROM order_date) = 01
GROUP BY sales.customer_id;
```

#### Pasos:

- Unir tablas members, sales y menu con función **JOIN**.
- Para obtener puntaje, usar **CASE** junto con **WHEN** para indicar que si el producto es "sushi" se multiplica el precio por 20 y si la orden fue hecha la semana siguiente a la fecha en que el cliente se convirtió en miembro también se debe multiplicar el precio por 20. Ésto últmo, lo logramos con las funciones **Between** y **DATE_ADD** para indicar un intervalo de tiempo de una semana. En caso de que el producto no sea "sushi" ni la orden haya sido hecha en la semana mencionada, el puntaje será el precio del producto multiplicado por 10.
- Filtrar resultados solo de ordenes hechas en enero con la función **EXTRACT** indicandole qué el mes debe ser = 1.
- Agrupar resultados por cliente con función **GROUP BY**.

#### Resultados:

| customer_id  | points |
| ------------- | ------------- |
| B  | 940 |
| A  | 1370  | 





