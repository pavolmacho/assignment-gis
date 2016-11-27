+![Preview](/2016-11-25.png)

## Môj projekt
Popis aplikácie:

Táto webová aplikácia vznikla na základe zadania z predmetu Pokročilé databázové systémy na FIIT STU v Bratislave.
Obsahuje nasledujúce funkcionality, ktoré sa týkajú vodných plôch na Slovensku:

- Zobrazenie 3 najbližších vodných plôch vzhľadom na našu aktuálnu pozíciu.
- Zobrazenie vodných plôch vo vybranom okrese, vysvieti aj hranicu vybraného okresu
- Zobrazenie najbližších parkoviskách pri vodných plochách vzhľadom na plohu pohyblivého kurzotu na mape

Zdroj dát:
openstreetmaps.org

Použité technológie:

- ASP.NET 4.5.2
- C#
- javascript
- ajax
- Postgis
- Mapbox GL JS

Implementácia:
Backend aplikácie je vykonávyný v jazyku C#, kde dochádza ku všetkým dopytom na Databázu a spätnému zaslaniu dát v tvare Geojson na stranu webu.

Frontend aplikácie obsahuje len dve tlačidlá na spustenie daných funkcionalít a jednu vnorenú ponuku na výber okresu zo zoznamu. Zvyšok stránky
obsahuje zobrazenú mapu.
