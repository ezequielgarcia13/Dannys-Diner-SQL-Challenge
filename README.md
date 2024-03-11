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


