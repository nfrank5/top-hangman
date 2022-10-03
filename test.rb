require 'yaml'
def save_game(game)
  g = YAML.dump(game) 
  saved_game = File.open("sample.yaml", "w")
  saved_game.puts g
  saved_game.close
  g
end

def load_game(g)
  YAML::load(g)
end



x =  save_game(123)

p load_game(x)