```

cat > /tmp/forex_alpha_hourly.py << 'EOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2026, 7, 20),
    'retries': 2,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='forex_alpha_hourly',
    default_args=default_args,
    description='Загрузка курсов валют из Alpha Vantage (каждый час)',
    schedule='0 * * * *',  # Каждый час (24 запроса/день)
    catchup=False,
    max_active_runs=1,
    tags=['forex', 'alpha_vantage'],
) as dag:

    load = BashOperator(
        task_id='load',
        bash_command="""
            echo "=== Loading Forex data from Alpha Vantage at $(date) ==="

            API_KEY="UDYYSVHYPTLLP2H5"

            # Получаем курсы с паузой между запросами
            curl -s "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=EUR&apikey=$API_KEY" > /tmp/eur_usd.json
            sleep 2

            curl -s "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=GBP&apikey=$API_KEY" > /tmp/gbp_usd.json
            sleep 2

            curl -s "https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=USD&to_currency=JPY&apikey=$API_KEY" > /tmp/usd_jpy.json

            python3 << PYTHON
import json, requests
from datetime import datetime

def get_rate(filename, pair, invert=False):
    try:
        with open(filename) as f:
            data = json.load(f)
        
        if 'Realtime Currency Exchange Rate' in data:
            rate = float(data['Realtime Currency Exchange Rate']['5. Exchange Rate'])
            if invert:
                rate = 1 / rate
            bid = round(rate * 0.999, 6)
            ask = round(rate * 1.001, 6)
            return bid, ask
        else:
            error_msg = data.get('Information', data.get('Note', 'Unknown error'))
            print(f" {pair}: {error_msg}")
            return None, None
    except Exception as e:
        print(f" {pair}: {e}")
        return None, None

ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
rows = []

# EUR/USD — ИНВЕРТИРУЕМ (1 / eur)
eur_bid, eur_ask = get_rate('/tmp/eur_usd.json', 'EUR/USD', invert=True)
if eur_bid:
    rows.append(f"('EUR/USD', {eur_bid}, {eur_ask}, '{ts}')")
    print(f'EUR/USD: {eur_bid} / {eur_ask}')

# GBP/USD — ИНВЕРТИРУЕМ (1 / gbp)
gbp_bid, gbp_ask = get_rate('/tmp/gbp_usd.json', 'GBP/USD', invert=True)
if gbp_bid:
    rows.append(f"('GBP/USD', {gbp_bid}, {gbp_ask}, '{ts}')")
    print(f'GBP/USD: {gbp_bid} / {gbp_ask}')

# USD/JPY — НЕ ИНВЕРТИРУЕМ
jpy_bid, jpy_ask = get_rate('/tmp/usd_jpy.json', 'USD/JPY', invert=False)
if jpy_bid:
    rows.append(f"('USD/JPY', {jpy_bid}, {jpy_ask}, '{ts}')")
    print(f'USD/JPY: {jpy_bid} / {jpy_ask}')

if rows:
    sql = 'INSERT INTO forex_data.ticks (symbol, bid, ask, timestamp) VALUES ' + ', '.join(rows)
    r = requests.post('http://10.0.0.32:8123/', params={'user': 'airflow_user', 'password': 'airflow_pass_2026', 'database': 'forex_data'}, data=sql)
    print(f' Inserted {len(rows)} rows, status: {r.status_code}')
else:
    print(' No data inserted')
PYTHON

            echo "=== Done at $(date) ==="
        """,
    )
EOF

# Копируем DAG
docker cp /tmp/forex_alpha_hourly.py yc-user-airflow-scheduler-1:/opt/airflow/dags/forex_alpha_hourly.py


```
