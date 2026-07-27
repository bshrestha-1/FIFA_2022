/* t002_possession_by_outcome — adapted from FIFA2022_analysis.sas (lines 168-182) in this repo.
   The analysis logic is the author's, verbatim. The only change: the input
   dataset the original builds via PROC IMPORT of Fifa_world_cup_matches.csv
   is rebuilt here from that same CSV as an inline DATALINES step (16 analysis
   columns), so the bundle is self-contained and needs no external file. */

/* import_fifa rebuilt inline from Fifa_world_cup_matches.csv (16 analysis columns) */
data work.import_fifa;
    length team1 team2 $30 possession_team1 possession_team2 $8;
    infile datalines dsd dlm='|';
    input team1 $ team2 $ possession_team1 $ possession_team2 $
          goals_team1 goals_team2 attempts_team1 attempts_team2
          conceded_team1 conceded_team2 goal_prevention_team1 goal_prevention_team2
          f_turnovers_team1 f_turnovers_team2 df_pressures_team1 df_pressures_team2;
datalines;
POLAND|ARGENTINA|24%|67%|0|2|4|25|2|0|25|4|67|48|438|141
NETHERLANDS|ARGENTINA|45%|44%|2|2|5|15|2|2|15|5|91|79|401|323
FRANCE|AUSTRALIA|56%|35%|4|1|22|4|1|4|4|22|64|56|250|316
TUNISIA|AUSTRALIA|50%|31%|0|1|13|8|1|0|9|13|81|88|217|273
ARGENTINA|AUSTRALIA|53%|35%|2|1|14|5|1|2|5|14|67|73|240|453
CROATIA|BELGIUM|43%|47%|0|0|11|15|0|0|16|11|70|68|328|346
CAMEROON|BRAZIL|31%|56%|1|0|7|19|0|1|20|7|78|54|321|226
CROATIA|BRAZIL|45%|45%|1|1|9|20|1|1|21|9|95|77|365|423
SWITZERLAND|CAMEROON|43%|46%|1|0|8|7|0|1|7|8|64|79|313|316
BELGIUM|CANADA|46%|43%|1|0|9|21|0|1|21|9|74|47|284|320
CROATIA|CANADA|41%|46%|4|1|13|9|1|4|9|13|87|72|347|316
SPAIN|COSTA RICA|74%|17%|7|0|17|0|0|7|0|17|46|76|185|585
JAPAN|COSTA RICA|48%|39%|0|1|14|4|1|0|4|14|47|66|300|294
MOROCCO|CROATIA|32%|57%|0|0|8|6|0|0|7|8|87|58|391|217
JAPAN|CROATIA|35%|51%|1|1|12|16|1|1|18|11|100|100|405|308
ARGENTINA|CROATIA|34%|54%|3|0|10|12|0|3|12|10|85|63|321|260
FRANCE|DENMARK|44%|44%|2|1|21|10|1|2|10|21|79|61|269|282
AUSTRALIA|DENMARK|24%|60%|1|0|8|14|0|1|14|8|90|74|341|161
QATAR|ECUADOR|42%|50%|0|2|5|6|2|0|6|5|52|72|256|279
NETHERLANDS|ECUADOR|48%|39%|1|1|2|13|1|1|14|2|85|52|254|279
WALES|ENGLAND|33%|58%|0|3|7|17|3|0|17|8|49|56|328|167
TUNISIA|FRANCE|30%|56%|1|0|5|9|0|1|11|6|68|80|400|202
ENGLAND|FRANCE|54%|36%|1|2|14|9|2|1|9|15|49|54|193|308
ARGENTINA|FRANCE|46%|40%|3|3|21|10|3|3|11|21|87|104|280|409
SPAIN|GERMANY|56%|33%|1|1|7|10|1|1|11|7|79|101|275|387
COSTA RICA|GERMANY|27%|60%|2|4|8|32|4|2|32|8|79|77|378|230
PORTUGAL|GHANA|55%|35%|3|2|11|8|2|3|8|11|70|82|286|326
KOREA REPUBLIC|GHANA|53%|32%|2|3|21|8|3|2|8|21|53|75|220|324
ENGLAND|IRAN|72%|19%|6|2|13|8|2|6|8|13|63|72|139|416
WALES|IRAN|51%|33%|0|2|10|21|2|0|21|9|89|84|161|276
GERMANY|JAPAN|65%|22%|1|2|25|10|2|1|12|26|55|87|164|487
URUGUAY|KOREA REPUBLIC|49%|38%|0|0|10|6|0|0|6|10|65|54|240|231
BRAZIL|KOREA REPUBLIC|47%|44%|4|1|18|10|1|4|10|18|73|81|310|329
ARGENTINA|MEXICO|50%|36%|2|0|5|4|0|2|4|5|63|79|220|327
SAUDI ARABIA|MEXICO|29%|55%|1|2|10|25|2|1|26|10|82|76|269|229
BELGIUM|MOROCCO|56%|32%|0|2|10|11|2|0|11|10|38|78|194|360
CANADA|MOROCCO|52%|36%|1|2|5|7|2|1|7|7|66|72|224|324
FRANCE|MOROCCO|34%|55%|2|0|14|13|0|2|13|14|72|47|328|218
CROATIA|MOROCCO|45%|45%|2|1|14|7|1|2|7|14|75|72|288|277
SENEGAL|NETHERLANDS|44%|45%|0|2|14|9|2|0|9|15|63|73|263|251
MEXICO|POLAND|54%|31%|0|0|13|8|0|0|8|15|61|70|193|290
FRANCE|POLAND|48%|42%|3|1|16|11|1|3|11|16|71|64|220|297
KOREA REPUBLIC|PORTUGAL|34%|55%|2|1|12|12|1|2|14|12|54|50|359|233
MOROCCO|PORTUGAL|22%|65%|1|0|9|11|0|1|11|10|88|44|373|165
NETHERLANDS|QATAR|54%|38%|2|0|13|6|0|2|5|14|62|52|319|322
ARGENTINA|SAUDI ARABIA|64%|24%|1|2|14|3|2|1|4|14|65|80|163|361
POLAND|SAUDI ARABIA|30%|57%|2|0|8|16|0|2|16|9|69|53|329|173
QATAR|SENEGAL|42%|48%|1|3|10|12|3|1|12|11|67|67|308|232
ECUADOR|SENEGAL|51%|32%|1|2|8|15|2|1|15|8|59|62|190|243
ENGLAND|SENEGAL|54%|35%|3|0|8|10|0|3|10|8|60|74|230|339
BRAZIL|SERBIA|53%|34%|2|0|24|4|0|2|4|24|72|71|236|338
CAMEROON|SERBIA|38%|49%|3|3|13|16|3|3|16|13|83|81|285|234
JAPAN|SPAIN|14%|78%|2|1|6|14|1|2|14|6|85|49|637|150
MOROCCO|SPAIN|22%|68%|0|0|6|13|0|0|14|6|100|66|573|217
BRAZIL|SWITZERLAND|51%|40%|1|0|9|4|0|1|4|9|85|80|282|344
SERBIA|SWITZERLAND|45%|41%|2|3|11|14|3|2|14|10|74|82|276|253
PORTUGAL|SWITZERLAND|43%|48%|6|1|14|10|1|6|10|15|71|54|357|240
DENMARK|TUNISIA|55%|33%|0|0|11|11|0|0|11|11|76|73|226|287
ENGLAND|UNITED STATES|51%|40%|0|0|8|10|0|0|10|8|52|61|266|350
IRAN|UNITED STATES|42%|45%|0|1|6|12|1|0|13|6|63|74|295|302
NETHERLANDS|UNITED STATES|33%|54%|3|1|11|18|1|3|18|13|101|77|325|256
PORTUGAL|URUGUAY|53%|35%|2|0|14|10|0|2|11|14|68|81|226|362
GHANA|URUGUAY|46%|39%|0|2|9|12|2|0|12|9|92|84|248|293
UNITED STATES|WALES|51%|39%|1|1|6|7|1|1|7|7|81|72|242|292
;
run;

/* Clean possession data by removing % and converting to numeric (author's logic) */
data work.import_fifa;
    set work.import_fifa;
    possession_team1_c = possession_team1;
    possession_team2_c = possession_team2;
    drop possession_team1 possession_team2;
run;

data work.import_fifa;
    set work.import_fifa;
    possession_team1 = input(compress(possession_team1_c, '%'), best12.);
    possession_team2 = input(compress(possession_team2_c, '%'), best12.);
    possession_team1_num = input(compress(possession_team1_c, '%'), best12.);
    possession_team2_num = input(compress(possession_team2_c, '%'), best12.);
    drop possession_team1_c possession_team2_c;
run;
/* Calculate possession difference and determine the winning team */
data possession_analysis;
    set work.import_fifa;
    possession_diff = possession_team1 - possession_team2;

    if goals_team1 > goals_team2 then outcome = "Home Team Wins";
    else if goals_team1 < goals_team2 then outcome = "Away Team Wins";
    else outcome = "Draw";
run;

/* Analyze the relationship between possession and match outcome */
proc means data=possession_analysis mean stddev;
    class outcome;
    var possession_diff;
    title "Possession Difference by Match Outcome";
run;
