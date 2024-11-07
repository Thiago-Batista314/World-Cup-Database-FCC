#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Cleans the tables
echo "$($PSQL "TRUNCATE TABLE teams, games;")"

# Starts id count
TEAM_ID=1
GAME_ID=1

# Reads the file and sets up the variables
cat "games.csv" | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]] 
  then
    # Check if there's the winner in the teams' table
    CHECK_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Insert if winner is not in the table
    if [[ -z $CHECK_WINNER ]]
    then 
      INSERT_WINNER=$($PSQL "INSERT INTO teams(team_id, name) VALUES ($TEAM_ID, '$WINNER')")
      TEAM_ID=$(($TEAM_ID + 1))
    fi

    # Check if opponent is in the teams table
    CHECK_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert opponent
    if [[ -z $CHECK_OPPONENT ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(team_id, name) VALUES ($TEAM_ID, '$OPPONENT')")
      TEAM_ID=$(($TEAM_ID + 1))
    fi
  fi
done

cat "games.csv" | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Insert each game inside games database
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAME=$($PSQL "INSERT INTO games(game_id, year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($GAME_ID, $YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    GAME_ID=$(($GAME_ID + 1))
  fi
done
