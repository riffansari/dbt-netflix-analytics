WITH raw_movies AS (
    SELECT *
    FROM Movielens.raw.raw_movies
)

SELECT 
    movieID AS movie_id,
    title,
    genres
FROM raw_movies