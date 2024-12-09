create or replace macro req2path(req) as (
  split_part(req, ' ', 2)
    .regexp_replace('[0-9a-z]{26}', '[ulid]', 'i')
    .regexp_replace('/.+\.png$', '/[image].png', 'i')
    .regexp_replace('/.+\.svg$', '/[image].svg', 'i')
    .regexp_replace('/.+\.ico$', '/[favicon].ico', 'i')
    .regexp_replace('/.+\.js$', '/[script].js', 'i')
    .regexp_replace('/.+\.css$', '/[style].css', 'i')
    .regexp_replace('-?[0-9]+', '[num]', 'g')
);
