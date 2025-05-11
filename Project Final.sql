# Задание: Список клиентов с непрерывной историей за год, 
# средний чек за период с 01.06.2015 по 01.06.2016, 
# средняя сумма покупок за месяц, количество всех операций по клиенту за период

SELECT 
    t.ID_client, 
    # Проверяем, что клиент имеет транзакции каждый месяц в течение года
    COUNT(DISTINCT EXTRACT(MONTH FROM t.date_new)) AS months_with_transactions,
    # Средний чек за весь период
    SUM(t.Sum_payment) / SUM(t.Count_products) AS avg_check_for_year,
    # Средняя сумма покупок за месяц
    AVG(t.Sum_payment) AS avg_monthly_spend,
    # Общее количество операций по клиенту
    COUNT(*) AS total_transactions_for_client
FROM transactions_info t
# Ограничиваем выборку периодом с 01.06.2015 по 01.06.2016
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
# Группируем по ID клиента
GROUP BY t.ID_client
# Оставляем только тех клиентов, у которых есть транзакции каждый месяц
HAVING months_with_transactions = 12;

# Задание: Информация по месяцам, включая статистику по операциям, клиентам и полу

SELECT 
    EXTRACT(MONTH FROM t.date_new) AS month,
    # Средняя сумма чека в месяц
    AVG(t.Sum_payment / t.Count_products) AS avg_check_per_month,
    
    # Среднее количество операций в месяц
    AVG(t.Count_products) AS avg_operations_per_month,

    # Среднее количество клиентов, совершавших операции в месяц
    COUNT(DISTINCT t.ID_client) / 12 AS avg_clients_per_month,

    # Доля от общего количества операций за год
    (COUNT(*) / (SELECT COUNT(*) FROM transactions_info WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) * 100 AS percentage_of_total_operations,

    # Доля в месяц от общей суммы операций
    (SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions_info WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')) * 100 AS percentage_of_total_amount,

    # Процентное соотношение M/F/NA с их долей затрат по каждому месяцу
    SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS male_percentage,
    SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS female_percentage,
    SUM(CASE WHEN c.Gender IS NULL THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS na_percentage
FROM transactions_info t
# Присоединяем таблицу клиентов для определения пола
JOIN customer_info c ON t.ID_client = c.ID_client
# Ограничиваем выборку периодом с 01.06.2015 по 01.06.2016
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
# Группируем по месяцам
GROUP BY month
ORDER BY month;

# Задание: Возрастные группы клиентов с шагом 10 лет и данные по клиентам, у которых нет информации о возрасте

SELECT 
    # Возрастные группы с шагом 10 лет (от 0-9 лет, 10-19 лет и т.д.)
    CASE
        WHEN c.Age IS NULL THEN 'Unknown'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
        WHEN c.Age >= 80 THEN '80+'
    END AS age_group,
    
    # Сумма всех операций по группе
    SUM(t.Sum_payment) AS total_amount,
    
    # Количество операций по группе
    COUNT(*) AS total_operations,

    # Среднее количество операций поквартально
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 1 THEN t.Count_products ELSE 0 END) AS avg_q1_operations,
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 2 THEN t.Count_products ELSE 0 END) AS avg_q2_operations,
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 3 THEN t.Count_products ELSE 0 END) AS avg_q3_operations,
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 4 THEN t.Count_products ELSE 0 END) AS avg_q4_operations,

    # Средняя сумма за квартал
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 1 THEN t.Sum_payment ELSE 0 END) AS avg_q1_sum,
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 2 THEN t.Sum_payment ELSE 0 END) AS avg_q2_sum,
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 3 THEN t.Sum_payment ELSE 0 END) AS avg_q3_sum,
    AVG(CASE WHEN EXTRACT(QUARTER FROM t.date_new) = 4 THEN t.Sum_payment ELSE 0 END) AS avg_q4_sum,

    # Процентное соотношение по возрастным группам
    SUM(CASE WHEN c.Age IS NULL THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS unknown_percentage,
    SUM(CASE WHEN c.Age BETWEEN 0 AND 9 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_0_9_percentage,
    SUM(CASE WHEN c.Age BETWEEN 10 AND 19 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_10_19_percentage,
    SUM(CASE WHEN c.Age BETWEEN 20 AND 29 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_20_29_percentage,
    SUM(CASE WHEN c.Age BETWEEN 30 AND 39 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_30_39_percentage,
    SUM(CASE WHEN c.Age BETWEEN 40 AND 49 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_40_49_percentage,
    SUM(CASE WHEN c.Age BETWEEN 50 AND 59 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_50_59_percentage,
    SUM(CASE WHEN c.Age BETWEEN 60 AND 69 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_60_69_percentage,
    SUM(CASE WHEN c.Age BETWEEN 70 AND 79 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_70_79_percentage,
    SUM(CASE WHEN c.Age >= 80 THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS age_80_plus_percentage
FROM transactions_info t
# Присоединяем таблицу клиентов для получения возраста
JOIN customer_info c ON t.ID_client = c.ID_client
# Ограничиваем выборку периодом с 01.06.2015 по 01.06.2016
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group
ORDER BY age_group;
