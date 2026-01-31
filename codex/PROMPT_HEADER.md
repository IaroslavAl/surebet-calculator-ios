ОБЯЗАТЕЛЬНО ПЕРЕД ЛЮБЫМИ ИЗМЕНЕНИЯМИ:
1) Прочитай AGENTS.md и следуй ему.
2) Прочитай codex/REFRACTORING_BRIEF.md.
3) Источники правды (приоритет): docs/rules/* и docs/architecture/*.
4) Если есть противоречия — следуй docs/*, не текущему коду.
5) Если решение неоднозначно — остановись и задай вопрос.

Шаг 2 (Root): перенести banner fetch из View в ViewModel через send, с защитой от повторов.
Контракт: следуй codex/REFRACTORING_BRIEF.md и правилам в docs/*.
Scope строго Root.

Можно менять только:
- SurebetCalculatorPackage/Sources/Root/RootViewModel.swift
- SurebetCalculatorPackage/Sources/Root/RootView.swift
- (если нужно для тестов) SurebetCalculatorPackage/Tests/RootTests/*

Сделай:
1) Если в RootView есть .task / асинхронный fetch баннера — убери его.
2) В RootViewModel добавь Action для старта загрузки баннера (например .task / .fetchBannerOnce) и обрабатывай через send.
3) Защита от повторов:
   - повторный send не должен стартовать новый запрос, если уже выполняется/уже загружено
   - желательно хранить Task? и корректно обнулять/отменять
4) Поведение не менять: баннер должен работать как раньше.
5) Не трогай Banner модуль и его public API.

После изменений:
- запусти xcodebuild build
- и xcodebuild test (так как меняется VM и возможно тесты)
Критерий: BUILD SUCCEEDED / TEST SUCCEEDED.

В конце:
- список изменённых файлов
- как реализована защита от повторов
- подтверждение, что docs/* соблюдены
