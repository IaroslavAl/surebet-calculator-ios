# ANALYTICS EVENTS (v2)

Единый source of truth для продуктовой аналитики приложения.

## Принципы
- Схема имен: `snake_case`.
- Миграция: `hard switch` (legacy события удалены, dual-logging не используется).
- Политика данных: `product-only`, без PII и без пользовательских текстовых вводов.
- Детализация: `action-level`.

## Обязательный контекст каждого события
Контекст добавляется автоматически декоратором `ContextualAnalyticsService`:
- `event_version` (`2`)
- `install_id`
- `session_id`
- `session_number`
- `app_language`
- `app_theme`
- `app_version`
- `build_number`
- `platform` (`ios`)

## Каталог событий

| Event name | Триггер | Параметры события (без общего контекста) | Owner |
|---|---|---|---|
| `app_session_started` | Вход сцены в `.active` и старт новой сессии | `start_reason`, `is_first_session`, `feature_onboarding_enabled`, `feature_review_prompt_enabled` | `RootViewModel` |
| `app_session_ended` | Выход сцены из `.active` (`.inactive`/`.background`) | `duration_seconds`, `end_reason` | `RootViewModel` |
| `onboarding_started` | Инициализация onboarding flow | — | `OnboardingViewModel` |
| `onboarding_page_viewed` | Переход на страницу onboarding | `page_index`, `page_id` | `OnboardingViewModel` |
| `onboarding_completed` | Завершение onboarding | `pages_viewed` | `OnboardingViewModel` |
| `onboarding_skipped` | Пропуск onboarding | `last_page_index` | `OnboardingViewModel` |
| `navigation_section_opened` | Тап по разделу в главном меню | `section` | `RootViewModel` |
| `feedback_email_opened` | Тап по feedback в главном меню | `source_screen` | `RootViewModel` |
| `calculator_rows_count_changed` | Изменение количества исходов | `row_count`, `change_direction` | `SurebetCalculatorViewModel` |
| `calculator_mode_selected` | Смена режима расчета (total/rows/row) | `mode` | `SurebetCalculatorViewModel` |
| `calculator_cleared` | Очистка калькулятора | — | `SurebetCalculatorViewModel` |
| `calculator_calculation_performed` | Debounce-лог после расчета | `row_count`, `mode`, `profit_percentage`, `is_profitable` | `SurebetCalculatorViewModel` |
| `settings_theme_changed` | Смена темы в настройках | `theme` | `SettingsViewModel` |
| `settings_language_changed` | Смена языка в настройках | `from_language`, `to_language` | `SettingsView` + `SettingsViewModel` |
| `review_prompt_displayed` | Показ review alert | — | `RootViewModel` |
| `review_prompt_answered` | Ответ в review alert | `answer` | `RootViewModel` |

## Доменные значения параметров
- `start_reason`: `initial_launch`, `foreground_from_background`, `foreground_from_inactive`, `foreground_from_unknown`
- `end_reason`: `entered_background`, `entered_inactive`
- `section`: `calculator`, `settings`, `instructions`
- `source_screen`: `main_menu`
- `change_direction`: `increased`, `decreased`
- `mode`: `total`, `rows`, `row`
- `answer`: `yes`, `no`

## Legacy -> v2 mapping
- `app_opened` -> `app_session_started`
- `review_prompt_shown` -> `review_prompt_displayed`
- `review_response` -> `review_prompt_answered`
- `calculator_row_added` + `calculator_row_removed` -> `calculator_rows_count_changed`
- `calculation_performed` -> `calculator_calculation_performed`
- `onboarding_page_viewed.page_title` -> `onboarding_page_viewed.page_id`
