-- 1
SELECT batter, SUM(batsman_runs) AS total_runs
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 20;

--2
SELECT bowler,SUM(is_wicket) AS total_wickets
FROM deliveries
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;

--3
SELECT batter,COUNT(*) AS sixes
FROM deliveries
WHERE batsman_runs = 6
GROUP BY batter
ORDER BY sixes DESC
LIMIT 1;

--4

SELECT
    batter,
    COUNT(*) AS fours
FROM deliveries
WHERE batsman_runs = 4
GROUP BY batter
ORDER BY fours DESC
LIMIT 10;

--5

SELECT batter,match_id,SUM(batsman_runs) AS highest_individual_score
FROM deliveries
GROUP BY batter,match_id
ORDER BY highest_individual_score DESC
LIMIT 1;

--6

SELECT season,batter,SUM(batsman_runs) AS total_runs
FROM matches
JOIN deliveries
ON deliveries.match_id = matches.id
GROUP BY season,batter
ORDER BY total_runs DESC
LIMIT 10;

--7

SELECT player_of_match, COUNT(*) AS awards
FROM matches
WHERE player_of_match IS NOT NULL
GROUP BY player_of_match
ORDER BY awards DESC
LIMIT 10;

--8

SELECT winner,COUNT(*) AS wins
FROM matches
WHERE winner IS NOT NULL
GROUP BY winner
ORDER BY wins DESC
LIMIT 10;

--9
SELECT winner,COUNT(*) AS successful_chases
FROM matches
WHERE toss_decision = 'field' AND winner IS NOT NULL
GROUP BY winner
ORDER BY successful_chases DESC
LIMIT 10;

--10
SELECT winner,COUNT(*) AS defending_teams
FROM matches
WHERE toss_decision = 'bat' AND winner IS NOT NULL
GROUP BY winner
ORDER BY defending_teams DESC
LIMIT 10;

--11
SELECT bowler,SUM(total_runs) AS most_runs_conceded
FROM deliveries
GROUP BY bowler
ORDER BY most_runs_conceded DESC
LIMIT 10;

--12
SELECT venue,COUNT(*) AS venue_hosting_most_matches
FROM matches
GROUP BY venue
ORDER BY venue_hosting_most_matches DESC
LIMIT 10;

--13
SELECT winner,
  COUNT(*) AS head_to_head
FROM matches
WHERE (team1 = 'Chennai Super Kings' OR team2 = 'Chennai Super kings')
AND Winner <> 'Chennai Super Kings'
AND winner IS NOT NULL
GROUP BY winner
ORDER BY head_to_head DESC
LIMIT 10;

--14
SELECT toss_winner,COUNT(*) AS toss_and_matchwins
FROM matches
WHERE toss_winner = winner
GROUP BY toss_winner
ORDER BY toss_and_matchwins DESC;

--15
SELECT
    batter,
    SUM(batsman_runs) AS runs,
    COUNT(*) AS balls_faced,
    ROUND(
        (SUM(batsman_runs)::numeric / COUNT(*)) * 100,
        2
    ) AS strike_rate
FROM deliveries
GROUP BY batter
HAVING COUNT(*) >= 500
ORDER BY strike_rate DESC
LIMIT 10;

--16
SELECT
     bowler,
	 SUM(total_runs) AS runs_conceded,
	 COUNT(*) AS balls_bowled,
	 ROUND( 
        SUM(total_runs)::numeric /
        (COUNT(*) / 6.0),
        2
     ) AS economy
FROM deliveries
GROUP BY bowler
HAVING COUNT(*) >= 500
ORDER BY economy DESC
LIMIT 10;