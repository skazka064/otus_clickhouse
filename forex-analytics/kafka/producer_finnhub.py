#!/usr/bin/env python3
import json
import websocket
from kafka import KafkaProducer
from datetime import datetime

# ===== Настройки Kafka =====
producer = KafkaProducer(
    bootstrap_servers='10.0.0.21:9092',
    value_serializer=lambda v: v.encode('utf-8')
)

# ===== Бесплатный ключ Finnhub =====
API_KEY = 'd9ermlpr01qq0pmhoaa0d9ermlpr01qq0pmhoaag'

def send_to_kafka(symbol, bid, ask, timestamp):
    csv_line = f"{symbol},{bid:.6f},{ask:.6f},{timestamp}\n"
    producer.send('forex_ticks', csv_line)
    print(f" Sent: {csv_line.strip()}")

def on_message(ws, message):
    try:
        data = json.loads(message)
        if 'data' in data:
            for item in data['data']:
                symbol = item.get('s', '')
                price = item.get('p', 0.0)
                if symbol and price:
                    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    # Формат: OANDA:EUR_USD → EUR/USD
                    clean_symbol = symbol.replace('OANDA:', '').replace('_', '/')
                    bid = float(price) * 0.999
                    ask = float(price) * 1.001
                    send_to_kafka(clean_symbol, bid, ask, ts)
    except Exception as e:
        print(f" Error: {e}")

def on_error(ws, error):
    print(f" WebSocket error: {error}")

def on_close(ws, close_status_code, close_msg):
    print(" WebSocket closed")

def on_open(ws):
    print(" Connected to Finnhub!")
    pairs = ['OANDA:EUR_USD', 'OANDA:GBP_USD', 'OANDA:USD_JPY']
    for pair in pairs:
        ws.send(json.dumps({'type': 'subscribe', 'symbol': pair}))
        print(f"📡 Subscribed to {pair}")

# ===== Запуск =====
if __name__ == '__main__':
    print("🚀 Starting Finnhub WebSocket Producer (Forex)...")
    ws = websocket.WebSocketApp(
        f'wss://ws.finnhub.io?token={API_KEY}',
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.run_forever()

