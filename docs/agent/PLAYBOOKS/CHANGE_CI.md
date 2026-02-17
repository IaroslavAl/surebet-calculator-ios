# PLAYBOOK: CHANGE CI

Когда применять: любая задача по изменению pipeline, job, условий запуска, required checks или CI-скриптов.

## 1. Scope
1. Определи тип изменения:
   - новая job,
   - изменение существующей job,
   - изменение условий trigger,
   - изменение required checks,
   - оптимизация времени/стабильности,
   - релизная manual job (archive/upload/signing).
2. Проверь source of truth:
   - `docs/reference/CI_RULES.md`
   - `docs/reference/BUILD_TEST_COMMANDS.md`

## 2. Реализация
1. Меняй workflow в `.github/workflows/*.yml`.
2. Переиспользуемую логику выноси в `scripts/ci/*`.
3. Держи имена обязательных job стабильными (`SwiftLint`, `Build`, `Unit Tests`, `Validate Docs Structure`).
4. Для iOS команд используй `xcodebuild` (не `swift build`).

## 3. Проверка
1. Локально запусти:
   - `./scripts/ci/secret_scan.sh`
   - `./scripts/ci/swiftlint_ci.sh`
   - `./scripts/ci/xcode_ci.sh build`
   - `./scripts/ci/xcode_ci.sh test`
   - `./scripts/ci/xcode_ci.sh test-ui` (если менялся UI и UI-тесты)
   - `./scripts/validate-docs.sh`
2. Если есть runtime-конфиги через build settings (например `APPMETRICA_API_KEY`), проверь что они приходят из CI secrets, а не из scheme env.
3. Если менялся релизный workflow/скрипт (`release-app-store.yml`, `release_app_store.sh`), проверь shell-валидность:
   - `bash -n ./scripts/ci/release_app_store.sh`
4. Убедись, что workflow-файлы валидны и не содержат дублирующих job.

## 4. Документация
При любом изменении CI-контракта обнови:
1. `docs/reference/CI_RULES.md`
2. `docs/reference/BUILD_TEST_COMMANDS.md`
3. `docs/agent/POLICIES.md` (если меняется правило уровня MUST/SHOULD)

## 5. DoD
- Pipeline проходит на PR.
- Required checks соответствуют документации.
- Нет self-hosted runner-зависимостей.
- Документация синхронизирована.

Последнее обновление: 2026-02-16
