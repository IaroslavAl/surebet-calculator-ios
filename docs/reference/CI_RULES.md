# CI RULES

Правила и контракт CI для проекта.

## Цели
- Бесплатный CI без self-hosted runners.
- Минимально обязательный quality gate:
  - SwiftLint,
  - Build,
  - Unit Tests,
  - Docs Validation.
- Все обязательные проверки должны быть `green` до merge в основную ветку.

## Workflows
- `.github/workflows/ci.yml`
  - Job `SwiftLint`
  - Job `Build`
  - Job `Unit Tests`
- `.github/workflows/docs-validation.yml`
  - Job `Validate Docs Structure`

## Runner policy
- Использовать только GitHub-hosted runners (`macos-latest`).
- Не добавлять self-hosted runner-специфику в pipeline.

## Required checks policy
В branch protection/ruleset для основной ветки (`main` или `master`, в зависимости от стратегии репозитория) добавить обязательные статусы:
- `SwiftLint`
- `Build`
- `Unit Tests`
- `Validate Docs Structure`

Merge разрешать только если все required checks успешны.

## Масштабирование
- Добавлять новые проверки отдельными job в `ci.yml`.
- Общую shell-логику выносить в `scripts/ci/*`.
- Не дублировать xcodebuild-команды в нескольких workflow-файлах.
- Имена job держать стабильными, чтобы не ломать required checks в GitHub settings.

## Локальная проверка перед PR
```bash
./scripts/ci/swiftlint_ci.sh
./scripts/ci/xcode_ci.sh build
./scripts/ci/xcode_ci.sh test
./scripts/validate-docs.sh
```

## Ограничения
- Не использовать `swift build` (из-за `SwiftLintBuildToolPlugin`).
- Любое изменение CI-контракта должно сопровождаться обновлением:
  - `docs/reference/CI_RULES.md`
  - `docs/reference/BUILD_TEST_COMMANDS.md`
  - релевантного playbook из `docs/agent/PLAYBOOKS/`

Последнее обновление: 2026-02-07
