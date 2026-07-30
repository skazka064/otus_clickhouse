# Бизнес-логика принятия решений

## Два ключевых фактора

| Фактор | Потоковый сигнал (Kafka) | Трендовое подтверждение |
|--------|--------------------------|------------------------|
| **Вопрос** | ⚡ "Куда двигаться прямо сейчас?" | 📊 "В каком направлении рынок?" |
| **Сигнал** | BUY / SELL (мгновенно) | UP / DOWN (за час/день) |
| **Основа** | Прогноз vs текущая цена | Часовой график |
| **Источник** | Kafka / MV | Airflow (hourly) |

---

## Схема принятия решений

```mermaid
graph TD
    subgraph SIGNAL[Потоковый сигнал]
        A[Kafka/MV] -->|прогноз| B[BUY или SELL]
    end
    
    subgraph TREND[Трендовое подтверждение]
        C[Airflow hourly] -->|анализ| D[UP или DOWN]
    end
    
    B --> DECISION{Принятие решения}
    D --> DECISION
    
    DECISION -->|BUY + UP| E[✅ Уверенная покупка]
    DECISION -->|SELL + DOWN| F[✅ Уверенная продажа]
    DECISION -->|BUY + DOWN| G[❌ Ложный сигнал — ждать]
    DECISION -->|SELL + UP| H[❌ Ложный сигнал — ждать]
    DECISION -->|сигнал + нейтральный| I[⏸️ Бездействие]
    
    style E fill:#9f9,stroke:#333,stroke-width:2px
    style F fill:#9f9,stroke:#333,stroke-width:2px
    style G fill:#f99,stroke:#333,stroke-width:2px
    style H fill:#f99,stroke:#333,stroke-width:2px
    style I fill:#ff9,stroke:#333,stroke-width:2px
