let
  attr = {
    "a" = 1;
    "b" = 2;
    "c" = 3;
  };

  list = [
    {
      "a" = 1;
      "b" = 2;
      "c" = 3;
    }
    {
      "a" = 1;
      "b" = 2;
      "c" = 3;
    }
    {
      "a" = 1;
      "b" = 2;
      "c" = 3;
    }
  ];

  fun = name: "Hello, " + name + "!";
  greeting = greeting: name: "Hello ${greeting} ${name}";

  makeObject = value: {
    myValue = value;
  };

  makeAttrOf = { value, ... }: {
    myValue = value;
  };

  makeAttrOfKeyValue = { key, value }: {
    # ${key} = value;
    inherit key value;
  };
in
# nix eval --file name.nix # to evaluate a file 
{
  #   attr = attr;
  #   list = list;
  #   fun = fun "world";
  #   greeting =  greeting "There" "Akib";

  # makeObject = makeObject {
  #    name = "Akib";
  #    age = 22;
  #    address = "Dhaka";
  #  };

  # makeAttrOf = makeAttrOf {
  #   value = "Akib";
  #   age = 22;
  #   address = "Dhaka";
  # };

  makeAttrOfKeyValue = makeAttrOfKeyValue {
    key = "Akib";
    value = 22;
  };
}
