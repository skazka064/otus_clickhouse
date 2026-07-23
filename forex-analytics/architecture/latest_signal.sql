# Логика формирования `latest_signals`

## Схема объединения прогнозов

```mermaid
graph TD
    E[predictions_eur_usd<br/>71,000 записей] --> U[UNION ALL]
    F[predictions_gbp_usd<br/>114,000 записей] --> U
    G[predictions_usd_jpy<br/>99,000 записей] --> U
    
    U --> R[ROW_NUMBER<br/>ORDER BY timestamp DESC]
    R --> W[WHERE rn = 1]
    W --> H[latest_signals<br/>всего 3 строки!]
    
    style E fill:#9cf,stroke:#333,stroke-width:2px
    style F fill:#9cf,stroke:#333,stroke-width:2px
    style G fill:#9cf,stroke:#333,stroke-width:2px
    style H fill:#fc9,stroke:#333,stroke-width:4px
