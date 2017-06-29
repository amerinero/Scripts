BEGIN {
  NOMBRE="";
  PATH1="";
  PATH2="";
}
  {
    if ($1 == "Pseudo")
      {
        # Nueva disco, imprimilos lo anterior
        print NOMBRE,PATH1,PATH2;
        PATH1="";
        PATH2="";
        # Nos quedamos con el nuevo NOMBRE
        NOMBRE=$2;
        next;
      }

    if ($1 == "0")
      {
        PATH1=$3;
        next;
      }

    if ($1 == "1")
        {
          PATH2=$3;
          next;
        }
  }
END { print NOMBRE,PATH1,PATH2; }
