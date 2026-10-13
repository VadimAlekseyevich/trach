/*
  Лабораторная работа № 2. Вариант 2: «Туристическое агентство».
  Экспертная система на SWI-Prolog: подбор туристического направления.
  8 вопросов, 18 вариантов рекомендации, обработка неизвестного случая.
  Запуск: swipl -q -s main.pl -g main -t halt
*/

:- encoding(utf8).
:- use_module(library(readutil)).

% ------------------------ Анкета туриста ------------------------
% question(Ключ, Формулировка, [option(Значение, Подпись), ...]).

question(climate, 'Какой климат вы предпочитаете?', [
    option(warm, 'Теплый'),
    option(moderate, 'Умеренный'),
    option(cold, 'Холодный')
]).

question(rest, 'Какой вид отдыха вам интересен?', [
    option(beach, 'Пляжный отдых'),
    option(culture, 'Музеи, культура и достопримечательности'),
    option(nature, 'Природа и красивые пейзажи'),
    option(active, 'Активный отдых и спорт')
]).

question(budget, 'Какой у вас бюджет поездки?', [
    option(economy, 'Экономный'),
    option(medium, 'Средний'),
    option(premium, 'Высокий')
]).

question(season, 'В какое время года планируется поездка?', [
    option(summer, 'Лето'),
    option(winter, 'Зима')
]).

question(duration, 'Какую длительность поездки вы планируете?', [
    option(short, 'До 4 дней'),
    option(week, '5–10 дней'),
    option(long, '11 дней и более')
]).

question(transport, 'Каким транспортом предпочитаете добираться?', [
    option(plane, 'Самолет'),
    option(train, 'Поезд'),
    option(car, 'Автомобиль')
]).

question(lodging, 'Какое проживание вы предпочитаете?', [
    option(hotel, 'Отель'),
    option(apartment, 'Апартаменты или гостевой дом'),
    option(camping, 'Кемпинг или палатка')
]).

question(company, 'С кем вы планируете путешествовать?', [
    option(solo, 'Один / одна'),
    option(couple, 'Вдвоем'),
    option(family, 'С семьей'),
    option(friends, 'С друзьями')
]).

% Фиксированный порядок восьми вопросов.
question_keys([climate, rest, budget, season, duration, transport, lodging, company]).

% ------------------------- База знаний --------------------------
% Категории условные, не являются актуальными ценами и визовыми правилами.

destination('Турция — Анталья',
    'Теплое побережье, пляжи и инфраструктура для семейного отпуска.', [
    climate-[warm],
    rest-[beach],
    budget-[economy, medium],
    season-[summer],
    duration-[week, long],
    transport-[plane],
    lodging-[hotel, apartment],
    company-[family, couple, friends]
]).

destination('Египет — Хургада',
    'Теплое море зимой и гостиничный пляжный отдых.', [
    climate-[warm],
    rest-[beach],
    budget-[economy, medium],
    season-[winter],
    duration-[week, long],
    transport-[plane],
    lodging-[hotel],
    company-[family, couple]
]).

destination('Таиланд — Пхукет',
    'Тропические пляжи и природные экскурсии для продолжительного отдыха.', [
    climate-[warm],
    rest-[beach, nature],
    budget-[medium, premium],
    season-[winter],
    duration-[week, long],
    transport-[plane],
    lodging-[hotel],
    company-[solo, couple, friends]
]).

destination('ОАЭ — Дубай',
    'Пляжи, современная архитектура и комфортные отели.', [
    climate-[warm],
    rest-[beach, culture],
    budget-[premium],
    season-[winter],
    duration-[short, week],
    transport-[plane],
    lodging-[hotel],
    company-[couple, family, friends]
]).

destination('Италия — Рим',
    'Исторические памятники, архитектура и насыщенная культурная программа.', [
    climate-[moderate],
    rest-[culture],
    budget-[medium, premium],
    season-[summer, winter],
    duration-[short, week],
    transport-[plane, train],
    lodging-[hotel, apartment],
    company-[solo, couple, friends]
]).

destination('Франция — Париж',
    'Музеи, знаменитые достопримечательности и городские прогулки.', [
    climate-[moderate],
    rest-[culture],
    budget-[premium],
    season-[summer, winter],
    duration-[short, week],
    transport-[plane, train],
    lodging-[hotel],
    company-[couple, friends]
]).

destination('Чехия — Прага',
    'Старинный центр города и культурные маршруты с умеренными затратами.', [
    climate-[moderate],
    rest-[culture],
    budget-[economy, medium],
    season-[summer, winter],
    duration-[short, week],
    transport-[plane, train],
    lodging-[hotel, apartment],
    company-[solo, couple, friends]
]).

destination('Япония — Токио',
    'Сочетание современных кварталов, музеев и традиционной культуры.', [
    climate-[moderate],
    rest-[culture],
    budget-[premium],
    season-[summer, winter],
    duration-[long],
    transport-[plane],
    lodging-[hotel, apartment],
    company-[solo, couple, friends]
]).

destination('Грузия — Казбеги',
    'Горные ландшафты, прогулки и активные маршруты на природе.', [
    climate-[moderate, cold],
    rest-[nature, active],
    budget-[economy, medium],
    season-[summer],
    duration-[week],
    transport-[plane, car],
    lodging-[apartment, camping],
    company-[solo, friends]
]).

destination('Норвегия — фьорды',
    'Северные пейзажи, фьорды и походы среди гор.', [
    climate-[cold, moderate],
    rest-[nature],
    budget-[premium],
    season-[summer],
    duration-[week, long],
    transport-[plane, car],
    lodging-[hotel, camping],
    company-[solo, couple, friends]
]).

destination('Швейцария — Альпы',
    'Горнолыжный и активный отдых среди альпийских пейзажей.', [
    climate-[cold],
    rest-[active, nature],
    budget-[premium],
    season-[winter],
    duration-[week],
    transport-[plane, train],
    lodging-[hotel],
    company-[couple, friends]
]).

destination('Австрия — Тироль',
    'Зимние виды спорта и горные курорты.', [
    climate-[cold],
    rest-[active],
    budget-[medium, premium],
    season-[winter],
    duration-[week],
    transport-[plane, train, car],
    lodging-[hotel, apartment],
    company-[family, friends]
]).

destination('Исландия — Рейкьявик',
    'Вулканические ландшафты, водопады и необычная северная природа.', [
    climate-[cold],
    rest-[nature],
    budget-[premium],
    season-[summer, winter],
    duration-[week],
    transport-[plane],
    lodging-[hotel],
    company-[solo, couple, friends]
]).

destination('Испания — Барселона',
    'Сочетание городской культуры, архитектуры и пляжей.', [
    climate-[warm, moderate],
    rest-[culture, beach],
    budget-[medium, premium],
    season-[summer],
    duration-[short, week],
    transport-[plane],
    lodging-[hotel, apartment],
    company-[couple, family, friends]
]).

destination('Черногория — Будва',
    'Адриатическое побережье и прогулки по природным местам.', [
    climate-[warm],
    rest-[beach, nature],
    budget-[economy, medium],
    season-[summer],
    duration-[week],
    transport-[plane, car],
    lodging-[hotel, apartment],
    company-[family, couple, friends]
]).

destination('Россия — Карелия',
    'Озера, лесные маршруты и путешествие на автомобиле или поезде.', [
    climate-[moderate, cold],
    rest-[nature, active],
    budget-[economy, medium],
    season-[summer],
    duration-[short, week],
    transport-[car, train],
    lodging-[camping, apartment],
    company-[solo, family, friends]
]).

destination('Финляндия — Лапландия',
    'Зимние северные пейзажи и семейный природный отдых.', [
    climate-[cold],
    rest-[nature],
    budget-[premium],
    season-[winter],
    duration-[week],
    transport-[plane, train],
    lodging-[hotel],
    company-[family, couple]
]).

destination('Марокко — Марракеш',
    'Атмосфера старого города, рынки и культурные достопримечательности.', [
    climate-[warm],
    rest-[culture],
    budget-[medium],
    season-[winter],
    duration-[week],
    transport-[plane],
    lodging-[hotel],
    company-[couple, friends]
]).


% -------------------------- Правила вывода -----------------------
% Рекурсивно сопоставляем каждый ответ с ограничениями направления.
% Несовпадение вызывает откат к следующему факту destination/3.

compatible([], _Conditions).
compatible([Key-Value | Remaining], Conditions) :-
    memberchk(Key-Allowed, Conditions),
    memberchk(Value, Allowed),
    compatible(Remaining, Conditions).

recommend(Answers, Name, Description) :-
    destination(Name, Description, Conditions),
    compatible(Answers, Conditions).

% --------------------- Диалог с пользователем --------------------
% Некорректный номер не засчитывается — вопрос повторяется.

valid_choice(Raw, Options, Value) :-
    normalize_space(string(Text), Raw),
    catch(number_string(Number, Text), _, fail),
    integer(Number),
    nth1(Number, Options, option(Value, _Label)).

print_options(Options) :-
    forall(nth1(Index, Options, option(_Value, Label)),
           format('  ~d. ~w~n', [Index, Label])).

read_choice(Options, Value) :-
    write('Ваш ответ (номер): '),
    flush_output,
    read_line_to_string(user_input, Raw),
    Raw \== end_of_file,
    ( valid_choice(Raw, Options, Value)
    -> true
    ;  writeln('Некорректный ввод. Введите номер из списка.'),
       read_choice(Options, Value)
    ).

ask_questions([], []).
ask_questions([Key | Rest], [Key-Value | Answers]) :-
    question(Key, Text, Options),
    nl,
    format('~w~n', [Text]),
    print_options(Options),
    read_choice(Options, Value),
    ask_questions(Rest, Answers).

main :-
    writeln('=== Экспертная система «Туристическое агентство» ==='),
    writeln('Ответьте на 8 вопросов, выбирая номер ответа.'),
    question_keys(Keys),
    ( ask_questions(Keys, Answers)
    -> ( once(recommend(Answers, Name, Description))
       -> nl,
          format('Рекомендованное направление: ~w~n', [Name]),
          format('Почему: ~w~n', [Description])
       ;  nl,
          writeln('Экспертная система не знает подходящего направления'),
          writeln('для такого сочетания предпочтений.')
       )
    ;  nl,
       writeln('Ввод прерван: ответы получены не на все вопросы.')
    ).
