--18  Top 5 Batters Every Season
WITH match_runs AS
(
SELECT 
   match_id,
   batter,
   season,
   SUM(batsman_runs) AS total_runs
FROM deliveries
JOIN matches
ON matches.id = deliveries.match_id
GROUP BY batter,season,match_id
),

ranked_players AS
(
SELECT 
    match_id,
	batter,
	season,
	total_runs,
	ROW_NUMBER() OVER(
              PARTITION BY season
			  	ORDER BY total_runs DESC
			) AS rn
       FROM match_runs
)

SELECT 
    match_id,
	batter,
	season,
	total_runs,
	rn
FROM ranked_players
WHERE rn = 1
ORDER BY total_runs DESC;

--19 Orange Cap

WITH season_runs AS
(
SELECT 
     batter,
	 season,
	 SUM(batsman_runs) AS total_runs
FROM deliveries
JOIN matches
ON matches.id = deliveries.match_id
GROUP BY batter,season
),

ranked_player AS
(
SELECT
    batter,
	season,
	total_runs,
    RANK() OVER( 
	       PARTITION BY season
		   ORDER BY total_runs DESC
		   )  AS player_rank
	FROM season_runs
)

SELECT
    batter,
	season,
	total_runs
FROM ranked_player
WHERE player_rank = 1
ORDER BY season;

--20 Purple Cap

WITH season_bowler AS
(
SELECT
    bowler,
	season,
	SUM(is_wicket) AS total_wickets
FROM deliveries
JOIN matches
ON matches.id = deliveries.match_id
WHERE dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
GROUP BY bowler,season
),

ranked_player AS
(
SELECT 
   bowler,
   season,
   total_wickets,
   DENSE_RANK() OVER(
          PARTITION BY season
		  ORDER BY total_wickets DESC
        ) AS player_rank
   FROM season_bowler
)

SELECT
   bowler,
   season,
   total_wickets,
   player_rank
FROM ranked_player
WHERE player_rank = 1
ORDER BY season;

--21 Best Batting Average

WITH batting_stats AS
(
    SELECT
        batter,
        SUM(batsman_runs) AS total_runs,
        COUNT(CASE
                WHEN player_dismissed = batter
                THEN 1
              END) AS times_out
    FROM deliveries
    GROUP BY batter
)

SELECT
    batter,
    total_runs,
    times_out,
    ROUND(
        total_runs::NUMERIC /
        NULLIF(times_out,0),
        2
    ) AS batting_average
FROM batting_stats
WHERE total_runs >= 500
ORDER BY batting_average DESC;

--22 Highest Successful Chase
SELECT
    id AS match_id,
    season,
    team1 AS defending_team,
    team2 AS chasing_team,
    SUM(total_runs) AS chased_score
FROM matches 
JOIN deliveries 
ON id = match_id
WHERE inning = 2
AND winner = team2
GROUP BY
    id,
    season,
    team1,
    team2
ORDER BY chased_score DESC
LIMIT 1;

--23 Best Economy Rate

WITH bowling_stats AS
(
    SELECT
        bowler,
        COUNT(*) AS balls_bowled,
        SUM(total_runs) AS runs_conceded
    FROM deliveries
    WHERE extras_type <> 'wides'
       OR extras_type IS NULL
    GROUP BY bowler
)

SELECT
    bowler,
    ROUND(balls_bowled / 6.0,2) AS overs_bowled,
    runs_conceded,
    ROUND(
        runs_conceded * 1.0 /
        (balls_bowled / 6.0),
        2
    ) AS economy_rate
FROM bowling_stats
WHERE (balls_bowled / 6.0) >= 30
ORDER BY economy_rate ASC;

--24 Top 5 Batters Every Season

WITH season_runs AS
(
    SELECT
        season,
        batter,
        SUM(batsman_runs) AS total_runs
    FROM deliveries 
    JOIN matches 
        ON match_id = id
    GROUP BY
        season,
        batter
),

ranked_batters AS
(
    SELECT
        season,
        batter,
        total_runs,
        RANK() OVER (
            PARTITION BY season
            ORDER BY total_runs DESC
        ) AS player_rank
    FROM season_runs
)

SELECT
    season,
    batter,
    total_runs,
    player_rank
FROM ranked_batters
WHERE player_rank <= 5
ORDER BY
    season,
    player_rank;



--  25 Top 5 Bowlers Every Season

WITH season_wickets AS
(
    SELECT
        season,
        bowler,
        SUM(
            CASE
                WHEN is_wicket = 1
                 AND dismissal_kind NOT IN
                 (
                    'run out',
                    'retired hurt',
                    'obstructing the field'
                 )
                THEN 1
                ELSE 0
            END
        ) AS total_wickets
    FROM deliveries 
    JOIN matches 
        ON match_id = id
    GROUP BY
       season,
       bowler
),

ranked_bowlers AS
(
    SELECT
        season,
        bowler,
        total_wickets,
        DENSE_RANK() OVER (
            PARTITION BY season
            ORDER BY total_wickets DESC
        ) AS bowler_rank
    FROM season_wickets
)

SELECT
    season,
    bowler,
    total_wickets,
    bowler_rank
FROM ranked_bowlers
WHERE bowler_rank <= 5
ORDER BY
    season,
    bowler_rank;