## 1. Создаём таблицу с действиями пользователей
```sql
CREATE TABLE IF NOT EXISTS user_actions (
    user_id UInt64,
    action String,
    expense UInt64
) ENGINE = MergeTree()
ORDER BY user_id;
```

## 2. Вставляем данные с низкокардинальными значениями action и повторяющимися строками
```sql
INSERT INTO user_actions VALUES
(1, 'view', 100), (1, 'click', 50), (1, 'view', 75), (1, 'purchase', 500), (1, 'click', 30),
(2, 'view', 200), (2, 'click', 80), (2, 'view', 120), (2, 'purchase', 300), (2, 'click', 45),
(3, 'view', 150), (3, 'click', 60), (3, 'view', 90), (3, 'purchase', 450), (3, 'click', 35),
(4, 'view', 180), (4, 'click', 70), (4, 'view', 110), (4, 'purchase', 600), (4, 'click', 40),
(5, 'view', 220), (5, 'click', 90), (5, 'view', 130), (5, 'purchase', 350), (5, 'click', 55);
```
### SELECT
```sql
SELECT 
    dictGet('user_emails_dict', 'email', user_id) AS email,
    action,
    expense,
    sum(expense) OVER (PARTITION BY action ORDER BY user_id, expense) AS cumulative_expense_by_action
FROM user_actions
ORDER BY email, action, expense;
```
|email|action|expense|cumulative_expense_by_action|
|-----|------|-------|----------------------------|
|user1@example.com|click|30|30|
|user1@example.com|click|50|80|
|user1@example.com|purchase|500|500|
|user1@example.com|view|75|75|
|user1@example.com|view|100|175|
|user2@example.com|click|45|125|
|user2@example.com|click|80|205|
|user2@example.com|purchase|300|800|
|user2@example.com|view|120|295|
|user2@example.com|view|200|495|
|user3@example.com|click|35|240|
|user3@example.com|click|60|300|
|user3@example.com|purchase|450|1250|
|user3@example.com|view|90|585|
|user3@example.com|view|150|735|
|user4@example.com|click|40|340|
|user4@example.com|click|70|410|
|user4@example.com|purchase|600|1850|
|user4@example.com|view|110|845|
|user4@example.com|view|180|1025|
|user5@example.com|click|55|465|
|user5@example.com|click|90|555|
|user5@example.com|purchase|350|2200|
|user5@example.com|view|130|1155|
|user5@example.com|view|220|1375|
