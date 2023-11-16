MATCH (n)
DETACH DELETE n;

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
CREATE (:Movie {
    rank: toInteger(row.Rank),
    title: row.Title,
    description: row.Description,
    year: toInteger(row.Year),
    runtime: toInteger(row['Runtime (Minutes)']),
    rating: toFloat(row.Rating),
    votes: toInteger(row.Votes),
    revenue: toFloat(row['Revenue (Millions)']),
    metascore: toInteger(row.Metascore)
});

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
MERGE (d:Director {name: row.Director});

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
WITH row, split(row.Actors, ", ") AS actors
UNWIND actors AS actor
MERGE (a:Actor {name: actor});

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
WITH row, split(row.Genre, ",") AS genres
UNWIND genres AS genre
MERGE (g:Genre {name: trim(genre)});

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
MATCH (d:Director {name: row.Director})
MATCH (m:Movie {title: row.Title})
MERGE (d)-[:DIRECTED]->(m);

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
MERGE (y:Year {year: row.Year});

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
MATCH (y:Year {year: row.Year})
MATCH (m:Movie {title: row.Title})
MERGE (m)-[:RELEASED_IN]->(y);

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
MATCH (y:Year {year: row.Year})
MATCH (m:Movie {title: row.Title})
MERGE (y)-[:RELEASE_OF]->(m);

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
WITH row, split(row.Actors, ", ") AS actors
UNWIND actors AS actor
MATCH (a:Actor {name: actor})
MATCH (m:Movie {title: row.Title})
MERGE (a)-[:ACTED_IN]->(m);

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
WITH row, split(row.Actors, ", ") AS actors
UNWIND actors AS actor
MATCH (m:Movie {title: row.Title})
MERGE (a:Actor {name: actor})
MERGE (m)-[:FEATURES_ACTOR]->(a);

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
WITH row, split(row.Genre, ",") AS genres
UNWIND genres AS genre
MATCH (m:Movie {title: row.Title})
MERGE (g:Genre {name: trim(genre)})
MERGE (m)-[:BELONGS_TO_GENRE]->(g);

LOAD CSV WITH HEADERS FROM 'file:///IMDB-Movie-Data.csv' AS row
MATCH (m:Movie {title: row.Title})
MERGE (d:Director {name: row.Director})
MERGE (m)-[:DIRECTED_BY]->(d);

Match (n)-[r]->(m)
Return n,r,m
LIMIT 1500;

CALL db.index.vector.createNodeIndex('desc-embeddings', 'Movie', 'embedding', 768, 'cosine');

call apoc.load.json("file:///movies_vec.json") yield value
match (m:Movie { title: value.Title }) set m.embedding = value.desc_embedding;