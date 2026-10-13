/* Автоматические проверки: swipl -q -s tests.pl -g run_tests -t halt */
:- encoding(utf8).
:- consult('main.pl').
:- use_module(library(plunit)).

:- begin_tests(tourism_expert).

test(exactly_eight_questions) :-
    question_keys(Keys),
    length(Keys, 8),
    sort(Keys, Sorted),
    length(Sorted, 8),
    forall(member(Key, Keys),
           ( question(Key, _, Options), length(Options, Count), Count >= 2 )).

test(at_least_ten_known_destinations) :-
    findall(Name, destination(Name, _, _), Names),
    sort(Names, Unique),
    length(Unique, Count),
    Count >= 10.

test(every_destination_has_all_eight_rules_and_can_match) :-
    question_keys(Keys),
    forall(destination(Name, _, Conditions),
        ( findall(Key-Value,
                  (member(Key, Keys), memberchk(Key-[Value|_], Conditions)),
                  Answers),
          length(Conditions, 8),
          length(Answers, 8),
          once(recommend(Answers, Name, _))
        )).

test(known_turkey) :-
    Answers = [climate-warm, rest-beach, budget-medium, season-summer,
               duration-week, transport-plane, lodging-hotel, company-family],
    once(recommend(Answers, Name, _)),
    assertion(Name == 'Турция — Анталья').

test(known_japan) :-
    Answers = [climate-moderate, rest-culture, budget-premium, season-winter,
               duration-long, transport-plane, lodging-hotel, company-solo],
    once(recommend(Answers, Name, _)),
    assertion(Name == 'Япония — Токио').

test(unknown_combination, [fail]) :-
    Answers = [climate-cold, rest-beach, budget-economy, season-summer,
               duration-short, transport-car, lodging-camping, company-solo],
    recommend(Answers, _, _).

test(valid_numeric_answer) :-
    question(climate, _, Options),
    valid_choice(" 2 ", Options, moderate).

test(reject_out_of_range_answer, [fail]) :-
    question(climate, _, Options),
    valid_choice("5", Options, _).

test(reject_text_answer, [fail]) :-
    question(climate, _, Options),
    valid_choice("привет", Options, _).

:- end_tests(tourism_expert).
