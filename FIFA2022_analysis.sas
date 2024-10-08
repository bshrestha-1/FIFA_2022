libname NewRslt "/home/u63983979/Fifa_analysis/lib";


Filename REFILE '/home/u63983979/Fifa_analysis/Fifa_world_cup_matches.csv';

proc import datafile= REFILE  replace
	dbms= csv
	out=NEWRSLT.import_fifa;
	getnames=yes;	
	guessingrows=32767;;
run;

/* Rename variables to remove spaces */
data NEWRSLT.import_fifa;
	length team1 team2 $30;
    set NEWRSLT.import_fifa;
    rename 
        "number of goals team1"n = goals_team1
        "number of goals team2"n = goals_team2
        "possession team1"n = possession_team1
        "possession team2"n = possession_team2
        "total attempts team1"n = attempts_team1
        "total attempts team2"n = attempts_team2
        "goal preventions team1"n=goal_prevention_team1
        "goal preventions team2"n=goal_prevention_team2
        "forced turnovers team1"n=f_turnovers_team1
        "forced turnovers team2"n=f_turnovers_team2
        "df pressures applied team1"n=df_pressures_team1
        "df pressures applied team2"n=df_pressures_team2
        "conceded team1"n =conceded_team1
        "conceded team2"n =conceded_team2;
       
run;

/* Clean possession data by removing % and converting to numeric */
data NEWRSLT.import_fifa;
    set NEWRSLT.import_fifa;
    possession_team1 = input(compress(possession_team1, '%'), best12.);
    possession_team2 = input(compress(possession_team2, '%'), best12.);
    possession_team1_num = input(compress(possession_team1, '%'), best12.);
    possession_team2_num = input(compress(possession_team2, '%'), best12.);
run;

/* Calculate total goals for each team1 */
proc sort data=NEWRSLT.import_fifa;
    by team1;
run;


proc means data=NEWRSLT.import_fifa noprint sum;
    by team1;
    var goals_team1;
    output out=team1_total_goals sum=goals_team1;
    
run;


/* Calculate total goals for each team2 */
proc sort data=NEWRSLT.import_fifa;
    by team2;
run;

proc means data=NEWRSLT.import_fifa noprint sum;
    by team2;
    var goals_team2;
    output out=team2_total_goals sum=goals_team2;
     

run;

/* Merge */
data total_goals_by_team;
    merge team1_total_goals(rename=(team1=team))
          team2_total_goals(rename=(team2=team));
    by team;
    if goals_team1=. then goals_team1=0;
    if goals_team2=. then goals_team2=0;
    total_goals = sum(goals_team1, goals_team2);
    drop _type_ _freq_;
run;

/* Sort  */
proc sort data=total_goals_by_team;
    by descending total_goals;
run;

/* Display the results */
proc print data=total_goals_by_team;
    var team goals_team1 goals_team2 total_goals;
run;

/* Create the bar chart */
proc sgplot data=total_goals_by_team;
	label goals_team1="Home Goals";
	label goals_team2="Away Goals";
	label total_goals="Total Goals";
    vbar team / response=total_goals;
    vbar team / response=goals_team1;
    vbar team / response=goals_team2;
    xaxis discreteorder=data;
    yaxis label="Total Goals";
    title "Total Goals by Team";
run;


/*-----------------------------------------------------------------------------*/


/* Calculate total goals for each team1 */
proc sort data=NEWRSLT.import_fifa;
    by team1;
run;


proc means data=NEWRSLT.import_fifa noprint sum;
    by team1;
    var conceded_team1;
    output out=team1_total_conceded sum=conceded_team1;
run;


/* Calculate total goals conceded for each team2 */
proc sort data=NEWRSLT.import_fifa;
    by team2;
run;

proc means data=NEWRSLT.import_fifa noprint sum;
    by team2;
    var conceded_team2;
    output out=team2_total_conceded sum=conceded_team2;
run;

/* Merge the results into a single dataset */
data total_conceded_by_team;
    merge team1_total_conceded(rename=(team1=team))
          team2_total_conceded(rename=(team2=team));
    by team;
    if conceded_team1=. then conceded_team1=0;
    if conceded_team2=. then conceded_team2=0;
    total_conceded = sum(conceded_team1, conceded_team2);
    drop _type_ _freq_;
run;

/* Sort  */
proc sort data=total_conceded_by_team;
    by descending total_conceded;
run;

/* Display the results */
proc print data=total_conceded_by_team;
    var team conceded_team1 conceded_team2 total_conceded;
run;

/* Create the bar chart */
proc sgplot data=total_conceded_by_team ;
	label conceded_team2="Goals conceded at away";
	label total_conceded="Total Goals Conceded";
    vbar team / response=total_conceded;
    vbar team / response=conceded_team2;
    xaxis discreteorder=data;
    yaxis label="Total Goals Conceded";
    title "Total Goals Conceded by Team";
run;


/*-----------------------------------------------------------------------------*/

/* Calculate possession difference and determine the winning team */
data NEWRSLT.possession_analysis;
    set NEWRSLT.import_fifa;
    possession_diff = possession_team1 - possession_team2;

    if goals_team1 > goals_team2 then outcome = "Home Team Wins";
    else if goals_team1 < goals_team2 then outcome = "Away Team Wins";
    else outcome = "Draw";
run;

/* Analyze the relationship between possession and match outcome */
proc means data=NEWRSLT.possession_analysis mean stddev;
    class outcome;
    var possession_diff;
run;

/* Create a box plot to visualize possession difference by outcome */
proc sgplot data=NEWRSLT.possession_analysis;
    vbox possession_diff / category=outcome;
    xaxis label="Match Outcome";
    yaxis label="Possession Difference (%)";
    title "Possession Difference by Match Outcome";
run;

/* Logistic regression: Possession difference as a predictor of winning */
data NEWRSLT.logistic_data;
    set NEWRSLT.possession_analysis;
    if outcome in ("Home Team Wins", "Away Team Wins") then do;
        win = (outcome = "Home Team Wins");
    end;
run;

proc logistic data=NEWRSLT.logistic_data descending;
    model win = possession_diff;
    title "Logistic Regression of Winning on Possession Difference";
run;
/*-----------------------------------------------------------------------------*/

proc sort data=NEWRSLT.import_fifa;
    by team1;
run;

/* Step 2A: Calculate total possession for Team 1 */
proc means data=NEWRSLT.import_fifa noprint;
    by team1;
    var possession_team1_num;
    output out=team1_possession mean=avg_possession_team1;
run;

proc sort data=NEWRSLT.import_fifa;
    by team2;
run;

/* Step 2B: Calculate total possession for Team 2 */
proc means data=NEWRSLT.import_fifa noprint;
    by team2;
    var possession_team2_num;
    output out=team2_possession mean=avg_possession_team2;
run;

/* Step 2C: Merge the possession data for both teams */
data NEWRSLT.total_possession;
    merge team1_possession(rename=(team1=team avg_possession_team1=avg_possession))
          team2_possession(rename=(team2=team avg_possession_team2=avg_possession));
    by team;

    /* Handle cases where only one team's data is available */
    if missing(avg_possession) then avg_possession = 0;

    /* Combine data from team1 and team2 */
    avg_possession = mean(avg_possession, avg_possession_team2);
    
    drop _type_ _freq_;
run;

/* Sort by average possession in descending order */
proc sort data=NEWRSLT.total_possession;
    by descending avg_possession;
run;

/* Display the results */
proc print data=NEWRSLT.total_possession;
    var team avg_possession;
    title "Team Average Possession per Match";
run;

/* Create a bar chart for average possession */
proc sgplot data=NEWRSLT.total_possession;
    vbar team / response=avg_possession;
    xaxis discreteorder=data;
    yaxis label="Average Possession (%)";
    title "Team Average Possession per Match";
run;





/*-----------------------------------------------------------------------------*/

/* Calculate shot conversion rates */
data NEWRSLT.conversion_analysis;
    set NEWRSLT.import_fifa;
    
    /* Calculate conversion rate for each team */
    if attempts_team1 > 0 then conversion_rate_team1 = goals_team1 / attempts_team1;
    else conversion_rate_team1 = .;
    
    if attempts_team2 > 0 then conversion_rate_team2 = goals_team2 / attempts_team2;
    else conversion_rate_team2 = .;
run;

/* Sort the data by team1 */
proc sort data=NEWRSLT.conversion_analysis;
    by team1;
run;

/* Calculate average conversion rate for Team 1 */
proc means data=NEWRSLT.conversion_analysis noprint mean;
    by team1;
    var conversion_rate_team1;
    output out=team1_conversion mean=avg_conversion_rate_team1;
run;

/* Sort the data by team2 */
proc sort data=NEWRSLT.conversion_analysis;
    by team2;
run;

/* Calculate average conversion rate for Team 2 */
proc means data=NEWRSLT.conversion_analysis noprint mean;
    by team2;
    var conversion_rate_team2;
    output out=team2_conversion mean=avg_conversion_rate_team2;
run;

/* Merge the results into a single dataset */
data NEWRSLT.total_conversion_rate;
    merge team1_conversion(rename=(team1=team avg_conversion_rate_team1=conversion_rate))
          team2_conversion(rename=(team2=team avg_conversion_rate_team2=conversion_rate));
    by team;
    
    /* Handle cases where only one team data is available */
    if conversion_rate=. then conversion_rate=avg_conversion_rate_team1;
    if avg_conversion_rate_team2 ne . then conversion_rate=mean(conversion_rate, avg_conversion_rate_team2);
    drop _type_ _freq_;
run;

/* Sort by conversion rate in descending order */
proc sort data=NEWRSLT.total_conversion_rate;
    by descending conversion_rate;
run;

/* Display the results */
proc print data=NEWRSLT.total_conversion_rate;
    var team conversion_rate;
    title "Team Efficiency: Shot Conversion Rates";
run;

/* Create a bar chart for shot conversion rates */
proc sgplot data=NEWRSLT.total_conversion_rate;
    vbar team / response=conversion_rate;
    xaxis discreteorder=data;
    yaxis label="Shot Conversion Rate";
    title "Team Efficiency: Shot Conversion Rates";
run;

/*-------------------------------------------------------------------*/

data NEWRSLT.defensive_metrics;
    set NEWRSLT.import_fifa;
    
    /* Calculate clean sheets */
    clean_sheet_team1 = (goals_team2 = 0);
    clean_sheet_team2 = (goals_team1 = 0);  
run;

proc sort data=NEWRSLT.defensive_metrics;
    by team1;
run;

/* Aggregate Metrics for Team 1 */
proc means data=NEWRSLT.defensive_metrics noprint sum;
    by team1;
    var clean_sheet_team1 goal_prevention_team1 df_pressures_team1 f_turnovers_team1;
    output out=team1_defensive_metrics 
        sum=clean_sheets_team1 
        goal_preventions_team1 
        df_pressures_team1 
        f_turnovers_team1;
run;

proc sort data=NEWRSLT.defensive_metrics;
    by team2;
run;

/* Aggregate Metrics for Team 2 */
proc means data=NEWRSLT.defensive_metrics noprint sum;
    by team2;
    var clean_sheet_team2 goal_prevention_team2 df_pressures_team2 f_turnovers_team2;
    output out=team2_defensive_metrics 
        sum=clean_sheets_team2 
        goal_preventions_team2 
        df_pressures_team2 
        f_turnovers_team2;
run;



/* Merge Metrics for Both Teams */
data NEWRSLT.total_defensive_metrics;
    merge team1_defensive_metrics (rename=(team1 =team)) team2_defensive_metrics(rename=(team2 =team));
    by team;
    
    /* Handle cases where data might be missing */
    if clean_sheets_team1 = . then clean_sheets_team1 = 0;
    if goal_preventions_team1 = . then goal_preventions_team1 = 0;
    if df_pressures_team1 = . then df_pressures_team1 = 0;
    if f_turnovers_team1 = . then f_turnovers_team1 = 0;
    if clean_sheets_team2 = . then clean_sheets_team2 = 0;
    if goal_preventions_team2 = . then goal_preventions_team2 = 0;
    if df_pressures_team2 = . then df_pressures_team2 = 0;
    if f_turnovers_team2 = . then f_turnovers_team2 = 0;
    
    
    /* Summing up values from both teams */
    clean_sheets = sum(clean_sheets_team1, clean_sheets_team2);
    goal_preventions = sum(goal_preventions_team1, goal_preventions_team2);
    defensive_pressures = sum(df_pressures_team1, df_pressures_team2);
    forced_turnovers = sum(f_turnovers_team1, f_turnovers_team2);
    drop _type_ _freq_;
	
    /* Create a Composite Defensive Performance Score */
    defensive_performance_score = 
        0.4 * clean_sheets + 
        0.25 * goal_preventions + 
        0.2 * defensive_pressures + 
        0.15 * forced_turnovers;

    run;
    
 /* Sort by Defensive Performance Score in Descending Order */
proc sort data=NEWRSLT.total_defensive_metrics;
    by descending defensive_performance_score;
run;

/* Display the Results */
proc print data=NEWRSLT.total_defensive_metrics;
    var team clean_sheets goal_preventions defensive_pressures forced_turnovers defensive_performance_score;
    title "Defensive Performance Metric by Team";
run;

/* Create a bar chart for defensive performance score */
proc sgplot data=NEWRSLT.total_defensive_metrics;
    vbar team / response=defensive_performance_score;
    xaxis discreteorder=data;
    Label team = "Countries";
    yaxis label="Defensive Performance Score";
    title "Team Defensive Performance Metrics";
run;



